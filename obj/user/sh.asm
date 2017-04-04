
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
  80002c:	e8 47 09 00 00       	call   800978 <libmain>
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
  80005b:	68 a0 31 80 00       	push   $0x8031a0
  800060:	e8 4c 0a 00 00       	call   800ab1 <cprintf>
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
  80007f:	68 af 31 80 00       	push   $0x8031af
  800084:	e8 28 0a 00 00       	call   800ab1 <cprintf>
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
  8000ab:	68 bd 31 80 00       	push   $0x8031bd
  8000b0:	e8 7c 11 00 00       	call   801231 <strchr>
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
  8000d8:	68 c2 31 80 00       	push   $0x8031c2
  8000dd:	e8 cf 09 00 00       	call   800ab1 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ea:	e9 a7 00 00 00       	jmp    800196 <_gettoken+0x163>
	}
	if (strchr(SYMBOLS, *s)) {
  8000ef:	83 ec 08             	sub    $0x8,%esp
  8000f2:	0f be c0             	movsbl %al,%eax
  8000f5:	50                   	push   %eax
  8000f6:	68 d3 31 80 00       	push   $0x8031d3
  8000fb:	e8 31 11 00 00       	call   801231 <strchr>
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
  800126:	68 c7 31 80 00       	push   $0x8031c7
  80012b:	e8 81 09 00 00       	call   800ab1 <cprintf>
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
  80014c:	68 cf 31 80 00       	push   $0x8031cf
  800151:	e8 db 10 00 00       	call   801231 <strchr>
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
  80017b:	68 db 31 80 00       	push   $0x8031db
  800180:	e8 2c 09 00 00       	call   800ab1 <cprintf>
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
  80023b:	0f 84 8f 00 00 00    	je     8002d0 <runcmd+0xc7>
  800241:	83 f8 3e             	cmp    $0x3e,%eax
  800244:	7f 12                	jg     800258 <runcmd+0x4f>
  800246:	85 c0                	test   %eax,%eax
  800248:	0f 84 fe 01 00 00    	je     80044c <runcmd+0x243>
  80024e:	83 f8 3c             	cmp    $0x3c,%eax
  800251:	74 3e                	je     800291 <runcmd+0x88>
  800253:	e9 e2 01 00 00       	jmp    80043a <runcmd+0x231>
  800258:	83 f8 77             	cmp    $0x77,%eax
  80025b:	74 0e                	je     80026b <runcmd+0x62>
  80025d:	83 f8 7c             	cmp    $0x7c,%eax
  800260:	0f 84 e8 00 00 00    	je     80034e <runcmd+0x145>
  800266:	e9 cf 01 00 00       	jmp    80043a <runcmd+0x231>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026b:	83 fe 10             	cmp    $0x10,%esi
  80026e:	75 15                	jne    800285 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	68 e5 31 80 00       	push   $0x8031e5
  800278:	e8 34 08 00 00       	call   800ab1 <cprintf>
				exit();
  80027d:	e8 3c 07 00 00       	call   8009be <exit>
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
  800294:	8d 45 a4             	lea    -0x5c(%ebp),%eax
  800297:	50                   	push   %eax
  800298:	6a 00                	push   $0x0
  80029a:	e8 ff fe ff ff       	call   80019e <gettoken>
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	83 f8 77             	cmp    $0x77,%eax
  8002a5:	74 15                	je     8002bc <runcmd+0xb3>
				cprintf("syntax error: < not followed by word\n");
  8002a7:	83 ec 0c             	sub    $0xc,%esp
  8002aa:	68 38 33 80 00       	push   $0x803338
  8002af:	e8 fd 07 00 00       	call   800ab1 <cprintf>
				exit();
  8002b4:	e8 05 07 00 00       	call   8009be <exit>
  8002b9:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			panic("< redirection not implemented");
  8002bc:	83 ec 04             	sub    $0x4,%esp
  8002bf:	68 f9 31 80 00       	push   $0x8031f9
  8002c4:	6a 3a                	push   $0x3a
  8002c6:	68 17 32 80 00       	push   $0x803217
  8002cb:	e8 08 07 00 00       	call   8009d8 <_panic>
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  8002d0:	83 ec 08             	sub    $0x8,%esp
  8002d3:	53                   	push   %ebx
  8002d4:	6a 00                	push   $0x0
  8002d6:	e8 c3 fe ff ff       	call   80019e <gettoken>
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	83 f8 77             	cmp    $0x77,%eax
  8002e1:	74 15                	je     8002f8 <runcmd+0xef>
				cprintf("syntax error: > not followed by word\n");
  8002e3:	83 ec 0c             	sub    $0xc,%esp
  8002e6:	68 60 33 80 00       	push   $0x803360
  8002eb:	e8 c1 07 00 00       	call   800ab1 <cprintf>
				exit();
  8002f0:	e8 c9 06 00 00       	call   8009be <exit>
  8002f5:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  8002f8:	83 ec 08             	sub    $0x8,%esp
  8002fb:	68 01 03 00 00       	push   $0x301
  800300:	ff 75 a4             	pushl  -0x5c(%ebp)
  800303:	e8 41 1f 00 00       	call   802249 <open>
  800308:	89 c7                	mov    %eax,%edi
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 19                	jns    80032a <runcmd+0x121>
				cprintf("open %s for write: %e", t, fd);
  800311:	83 ec 04             	sub    $0x4,%esp
  800314:	50                   	push   %eax
  800315:	ff 75 a4             	pushl  -0x5c(%ebp)
  800318:	68 21 32 80 00       	push   $0x803221
  80031d:	e8 8f 07 00 00       	call   800ab1 <cprintf>
				exit();
  800322:	e8 97 06 00 00       	call   8009be <exit>
  800327:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  80032a:	83 ff 01             	cmp    $0x1,%edi
  80032d:	0f 84 f7 fe ff ff    	je     80022a <runcmd+0x21>
				dup(fd, 1);
  800333:	83 ec 08             	sub    $0x8,%esp
  800336:	6a 01                	push   $0x1
  800338:	57                   	push   %edi
  800339:	e8 6b 19 00 00       	call   801ca9 <dup>
				close(fd);
  80033e:	89 3c 24             	mov    %edi,(%esp)
  800341:	e8 13 19 00 00       	call   801c59 <close>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 dc fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800357:	50                   	push   %eax
  800358:	e8 2a 28 00 00       	call   802b87 <pipe>
  80035d:	83 c4 10             	add    $0x10,%esp
  800360:	85 c0                	test   %eax,%eax
  800362:	79 16                	jns    80037a <runcmd+0x171>
				cprintf("pipe: %e", r);
  800364:	83 ec 08             	sub    $0x8,%esp
  800367:	50                   	push   %eax
  800368:	68 37 32 80 00       	push   $0x803237
  80036d:	e8 3f 07 00 00       	call   800ab1 <cprintf>
				exit();
  800372:	e8 47 06 00 00       	call   8009be <exit>
  800377:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  80037a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800381:	74 1c                	je     80039f <runcmd+0x196>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  800383:	83 ec 04             	sub    $0x4,%esp
  800386:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80038c:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800392:	68 40 32 80 00       	push   $0x803240
  800397:	e8 15 07 00 00       	call   800ab1 <cprintf>
  80039c:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  80039f:	e8 cc 14 00 00       	call   801870 <fork>
  8003a4:	89 c7                	mov    %eax,%edi
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	79 16                	jns    8003c0 <runcmd+0x1b7>
				cprintf("fork: %e", r);
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	50                   	push   %eax
  8003ae:	68 63 37 80 00       	push   $0x803763
  8003b3:	e8 f9 06 00 00       	call   800ab1 <cprintf>
				exit();
  8003b8:	e8 01 06 00 00       	call   8009be <exit>
  8003bd:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003c0:	85 ff                	test   %edi,%edi
  8003c2:	75 3c                	jne    800400 <runcmd+0x1f7>
				if (p[0] != 0) {
  8003c4:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	74 1c                	je     8003ea <runcmd+0x1e1>
					dup(p[0], 0);
  8003ce:	83 ec 08             	sub    $0x8,%esp
  8003d1:	6a 00                	push   $0x0
  8003d3:	50                   	push   %eax
  8003d4:	e8 d0 18 00 00       	call   801ca9 <dup>
					close(p[0]);
  8003d9:	83 c4 04             	add    $0x4,%esp
  8003dc:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003e2:	e8 72 18 00 00       	call   801c59 <close>
  8003e7:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  8003ea:	83 ec 0c             	sub    $0xc,%esp
  8003ed:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003f3:	e8 61 18 00 00       	call   801c59 <close>
				goto again;
  8003f8:	83 c4 10             	add    $0x10,%esp
  8003fb:	e9 25 fe ff ff       	jmp    800225 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  800400:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800406:	83 f8 01             	cmp    $0x1,%eax
  800409:	74 1c                	je     800427 <runcmd+0x21e>
					dup(p[1], 1);
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	6a 01                	push   $0x1
  800410:	50                   	push   %eax
  800411:	e8 93 18 00 00       	call   801ca9 <dup>
					close(p[1]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80041f:	e8 35 18 00 00       	call   801c59 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800430:	e8 24 18 00 00       	call   801c59 <close>
				goto runit;
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	eb 17                	jmp    800451 <runcmd+0x248>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  80043a:	50                   	push   %eax
  80043b:	68 4d 32 80 00       	push   $0x80324d
  800440:	6a 70                	push   $0x70
  800442:	68 17 32 80 00       	push   $0x803217
  800447:	e8 8c 05 00 00       	call   8009d8 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  80044c:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800451:	85 f6                	test   %esi,%esi
  800453:	75 22                	jne    800477 <runcmd+0x26e>
		if (debug)
  800455:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80045c:	0f 84 96 01 00 00    	je     8005f8 <runcmd+0x3ef>
			cprintf("EMPTY COMMAND\n");
  800462:	83 ec 0c             	sub    $0xc,%esp
  800465:	68 69 32 80 00       	push   $0x803269
  80046a:	e8 42 06 00 00       	call   800ab1 <cprintf>
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	e9 81 01 00 00       	jmp    8005f8 <runcmd+0x3ef>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  800477:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80047a:	80 38 2f             	cmpb   $0x2f,(%eax)
  80047d:	74 23                	je     8004a2 <runcmd+0x299>
		argv0buf[0] = '/';
  80047f:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	50                   	push   %eax
  80048a:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  800490:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  800496:	50                   	push   %eax
  800497:	e8 8d 0c 00 00       	call   801129 <strcpy>
		argv[0] = argv0buf;
  80049c:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004a2:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004a9:	00 

	// Print the command.
	if (debug) {
  8004aa:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004b1:	74 49                	je     8004fc <runcmd+0x2f3>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004b3:	a1 24 54 80 00       	mov    0x805424,%eax
  8004b8:	8b 40 48             	mov    0x48(%eax),%eax
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	50                   	push   %eax
  8004bf:	68 78 32 80 00       	push   $0x803278
  8004c4:	e8 e8 05 00 00       	call   800ab1 <cprintf>
  8004c9:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	eb 11                	jmp    8004e2 <runcmd+0x2d9>
			cprintf(" %s", argv[i]);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	50                   	push   %eax
  8004d5:	68 00 33 80 00       	push   $0x803300
  8004da:	e8 d2 05 00 00       	call   800ab1 <cprintf>
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  8004e5:	8b 43 fc             	mov    -0x4(%ebx),%eax
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	75 e5                	jne    8004d1 <runcmd+0x2c8>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  8004ec:	83 ec 0c             	sub    $0xc,%esp
  8004ef:	68 c0 31 80 00       	push   $0x8031c0
  8004f4:	e8 b8 05 00 00       	call   800ab1 <cprintf>
  8004f9:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800502:	50                   	push   %eax
  800503:	ff 75 a8             	pushl  -0x58(%ebp)
  800506:	e8 f2 1e 00 00       	call   8023fd <spawn>
  80050b:	89 c3                	mov    %eax,%ebx
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	0f 89 c3 00 00 00    	jns    8005db <runcmd+0x3d2>
		cprintf("spawn %s: %e\n", argv[0], r);
  800518:	83 ec 04             	sub    $0x4,%esp
  80051b:	50                   	push   %eax
  80051c:	ff 75 a8             	pushl  -0x58(%ebp)
  80051f:	68 86 32 80 00       	push   $0x803286
  800524:	e8 88 05 00 00       	call   800ab1 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800529:	e8 56 17 00 00       	call   801c84 <close_all>
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	eb 4c                	jmp    80057f <runcmd+0x376>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800533:	a1 24 54 80 00       	mov    0x805424,%eax
  800538:	8b 40 48             	mov    0x48(%eax),%eax
  80053b:	53                   	push   %ebx
  80053c:	ff 75 a8             	pushl  -0x58(%ebp)
  80053f:	50                   	push   %eax
  800540:	68 94 32 80 00       	push   $0x803294
  800545:	e8 67 05 00 00       	call   800ab1 <cprintf>
  80054a:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	53                   	push   %ebx
  800551:	e8 b7 27 00 00       	call   802d0d <wait>
		if (debug)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800560:	0f 84 8c 00 00 00    	je     8005f2 <runcmd+0x3e9>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800566:	a1 24 54 80 00       	mov    0x805424,%eax
  80056b:	8b 40 48             	mov    0x48(%eax),%eax
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	50                   	push   %eax
  800572:	68 a9 32 80 00       	push   $0x8032a9
  800577:	e8 35 05 00 00       	call   800ab1 <cprintf>
  80057c:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  80057f:	85 ff                	test   %edi,%edi
  800581:	74 51                	je     8005d4 <runcmd+0x3cb>
		if (debug)
  800583:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80058a:	74 1a                	je     8005a6 <runcmd+0x39d>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  80058c:	a1 24 54 80 00       	mov    0x805424,%eax
  800591:	8b 40 48             	mov    0x48(%eax),%eax
  800594:	83 ec 04             	sub    $0x4,%esp
  800597:	57                   	push   %edi
  800598:	50                   	push   %eax
  800599:	68 bf 32 80 00       	push   $0x8032bf
  80059e:	e8 0e 05 00 00       	call   800ab1 <cprintf>
  8005a3:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	57                   	push   %edi
  8005aa:	e8 5e 27 00 00       	call   802d0d <wait>
		if (debug)
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005b9:	74 19                	je     8005d4 <runcmd+0x3cb>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005bb:	a1 24 54 80 00       	mov    0x805424,%eax
  8005c0:	8b 40 48             	mov    0x48(%eax),%eax
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	50                   	push   %eax
  8005c7:	68 a9 32 80 00       	push   $0x8032a9
  8005cc:	e8 e0 04 00 00       	call   800ab1 <cprintf>
  8005d1:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  8005d4:	e8 e5 03 00 00       	call   8009be <exit>
  8005d9:	eb 1d                	jmp    8005f8 <runcmd+0x3ef>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %e\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  8005db:	e8 a4 16 00 00       	call   801c84 <close_all>
	if (r >= 0) {
		if (debug)
  8005e0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005e7:	0f 84 60 ff ff ff    	je     80054d <runcmd+0x344>
  8005ed:	e9 41 ff ff ff       	jmp    800533 <runcmd+0x32a>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005f2:	85 ff                	test   %edi,%edi
  8005f4:	75 b0                	jne    8005a6 <runcmd+0x39d>
  8005f6:	eb dc                	jmp    8005d4 <runcmd+0x3cb>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  8005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fb:	5b                   	pop    %ebx
  8005fc:	5e                   	pop    %esi
  8005fd:	5f                   	pop    %edi
  8005fe:	5d                   	pop    %ebp
  8005ff:	c3                   	ret    

00800600 <usage>:
}


void
usage(void)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800606:	68 88 33 80 00       	push   $0x803388
  80060b:	e8 a1 04 00 00       	call   800ab1 <cprintf>
	exit();
  800610:	e8 a9 03 00 00       	call   8009be <exit>
}
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	c9                   	leave  
  800619:	c3                   	ret    

0080061a <umain>:

void
umain(int argc, char **argv)
{
  80061a:	55                   	push   %ebp
  80061b:	89 e5                	mov    %esp,%ebp
  80061d:	57                   	push   %edi
  80061e:	56                   	push   %esi
  80061f:	53                   	push   %ebx
  800620:	83 ec 30             	sub    $0x30,%esp
  800623:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800626:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800629:	50                   	push   %eax
  80062a:	57                   	push   %edi
  80062b:	8d 45 08             	lea    0x8(%ebp),%eax
  80062e:	50                   	push   %eax
  80062f:	e8 31 13 00 00       	call   801965 <argstart>
	while ((r = argnext(&args)) >= 0)
  800634:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800637:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80063e:	be 3f 00 00 00       	mov    $0x3f,%esi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800643:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800646:	eb 2f                	jmp    800677 <umain+0x5d>
		switch (r) {
  800648:	83 f8 69             	cmp    $0x69,%eax
  80064b:	74 25                	je     800672 <umain+0x58>
  80064d:	83 f8 78             	cmp    $0x78,%eax
  800650:	74 07                	je     800659 <umain+0x3f>
  800652:	83 f8 64             	cmp    $0x64,%eax
  800655:	75 14                	jne    80066b <umain+0x51>
  800657:	eb 09                	jmp    800662 <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800659:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  800660:	eb 15                	jmp    800677 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  800662:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  800669:	eb 0c                	jmp    800677 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  80066b:	e8 90 ff ff ff       	call   800600 <usage>
  800670:	eb 05                	jmp    800677 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  800672:	be 01 00 00 00       	mov    $0x1,%esi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800677:	83 ec 0c             	sub    $0xc,%esp
  80067a:	53                   	push   %ebx
  80067b:	e8 15 13 00 00       	call   801995 <argnext>
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	79 c1                	jns    800648 <umain+0x2e>
			break;
		default:
			usage();
		}

	if (argc > 2)
  800687:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  80068b:	7e 05                	jle    800692 <umain+0x78>
		usage();
  80068d:	e8 6e ff ff ff       	call   800600 <usage>
	if (argc == 2) {
  800692:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800696:	75 56                	jne    8006ee <umain+0xd4>
		close(0);
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	6a 00                	push   $0x0
  80069d:	e8 b7 15 00 00       	call   801c59 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006a2:	83 c4 08             	add    $0x8,%esp
  8006a5:	6a 00                	push   $0x0
  8006a7:	ff 77 04             	pushl  0x4(%edi)
  8006aa:	e8 9a 1b 00 00       	call   802249 <open>
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	85 c0                	test   %eax,%eax
  8006b4:	79 1b                	jns    8006d1 <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	50                   	push   %eax
  8006ba:	ff 77 04             	pushl  0x4(%edi)
  8006bd:	68 dc 32 80 00       	push   $0x8032dc
  8006c2:	68 20 01 00 00       	push   $0x120
  8006c7:	68 17 32 80 00       	push   $0x803217
  8006cc:	e8 07 03 00 00       	call   8009d8 <_panic>
		assert(r == 0);
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	74 19                	je     8006ee <umain+0xd4>
  8006d5:	68 e8 32 80 00       	push   $0x8032e8
  8006da:	68 ef 32 80 00       	push   $0x8032ef
  8006df:	68 21 01 00 00       	push   $0x121
  8006e4:	68 17 32 80 00       	push   $0x803217
  8006e9:	e8 ea 02 00 00       	call   8009d8 <_panic>
	}
	if (interactive == '?')
  8006ee:	83 fe 3f             	cmp    $0x3f,%esi
  8006f1:	75 0f                	jne    800702 <umain+0xe8>
		interactive = iscons(0);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	6a 00                	push   $0x0
  8006f8:	e8 f5 01 00 00       	call   8008f2 <iscons>
  8006fd:	89 c6                	mov    %eax,%esi
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	85 f6                	test   %esi,%esi
  800704:	b8 00 00 00 00       	mov    $0x0,%eax
  800709:	bf 04 33 80 00       	mov    $0x803304,%edi
  80070e:	0f 44 f8             	cmove  %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	57                   	push   %edi
  800715:	e8 e3 08 00 00       	call   800ffd <readline>
  80071a:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 c0                	test   %eax,%eax
  800721:	75 1e                	jne    800741 <umain+0x127>
			if (debug)
  800723:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80072a:	74 10                	je     80073c <umain+0x122>
				cprintf("EXITING\n");
  80072c:	83 ec 0c             	sub    $0xc,%esp
  80072f:	68 07 33 80 00       	push   $0x803307
  800734:	e8 78 03 00 00       	call   800ab1 <cprintf>
  800739:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  80073c:	e8 7d 02 00 00       	call   8009be <exit>
		}
		if (debug)
  800741:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800748:	74 11                	je     80075b <umain+0x141>
			cprintf("LINE: %s\n", buf);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	53                   	push   %ebx
  80074e:	68 10 33 80 00       	push   $0x803310
  800753:	e8 59 03 00 00       	call   800ab1 <cprintf>
  800758:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  80075b:	80 3b 23             	cmpb   $0x23,(%ebx)
  80075e:	74 b1                	je     800711 <umain+0xf7>
			continue;
		if (echocmds)
  800760:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800764:	74 11                	je     800777 <umain+0x15d>
			printf("# %s\n", buf);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	68 1a 33 80 00       	push   $0x80331a
  80076f:	e8 73 1c 00 00       	call   8023e7 <printf>
  800774:	83 c4 10             	add    $0x10,%esp
		if (debug)
  800777:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80077e:	74 10                	je     800790 <umain+0x176>
			cprintf("BEFORE FORK\n");
  800780:	83 ec 0c             	sub    $0xc,%esp
  800783:	68 20 33 80 00       	push   $0x803320
  800788:	e8 24 03 00 00       	call   800ab1 <cprintf>
  80078d:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  800790:	e8 db 10 00 00       	call   801870 <fork>
  800795:	89 c6                	mov    %eax,%esi
  800797:	85 c0                	test   %eax,%eax
  800799:	79 15                	jns    8007b0 <umain+0x196>
			panic("fork: %e", r);
  80079b:	50                   	push   %eax
  80079c:	68 63 37 80 00       	push   $0x803763
  8007a1:	68 38 01 00 00       	push   $0x138
  8007a6:	68 17 32 80 00       	push   $0x803217
  8007ab:	e8 28 02 00 00       	call   8009d8 <_panic>
		if (debug)
  8007b0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007b7:	74 11                	je     8007ca <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	50                   	push   %eax
  8007bd:	68 2d 33 80 00       	push   $0x80332d
  8007c2:	e8 ea 02 00 00       	call   800ab1 <cprintf>
  8007c7:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  8007ca:	85 f6                	test   %esi,%esi
  8007cc:	75 16                	jne    8007e4 <umain+0x1ca>
			runcmd(buf);
  8007ce:	83 ec 0c             	sub    $0xc,%esp
  8007d1:	53                   	push   %ebx
  8007d2:	e8 32 fa ff ff       	call   800209 <runcmd>
			exit();
  8007d7:	e8 e2 01 00 00       	call   8009be <exit>
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	e9 2d ff ff ff       	jmp    800711 <umain+0xf7>
		} else
			wait(r);
  8007e4:	83 ec 0c             	sub    $0xc,%esp
  8007e7:	56                   	push   %esi
  8007e8:	e8 20 25 00 00       	call   802d0d <wait>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	e9 1c ff ff ff       	jmp    800711 <umain+0xf7>

008007f5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800805:	68 a9 33 80 00       	push   $0x8033a9
  80080a:	ff 75 0c             	pushl  0xc(%ebp)
  80080d:	e8 17 09 00 00       	call   801129 <strcpy>
	return 0;
}
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	c9                   	leave  
  800818:	c3                   	ret    

00800819 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	57                   	push   %edi
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800825:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80082a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800830:	eb 2d                	jmp    80085f <devcons_write+0x46>
		m = n - tot;
  800832:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800835:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800837:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80083a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80083f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800842:	83 ec 04             	sub    $0x4,%esp
  800845:	53                   	push   %ebx
  800846:	03 45 0c             	add    0xc(%ebp),%eax
  800849:	50                   	push   %eax
  80084a:	57                   	push   %edi
  80084b:	e8 6b 0a 00 00       	call   8012bb <memmove>
		sys_cputs(buf, m);
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	53                   	push   %ebx
  800854:	57                   	push   %edi
  800855:	e8 16 0c 00 00       	call   801470 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80085a:	01 de                	add    %ebx,%esi
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	89 f0                	mov    %esi,%eax
  800861:	3b 75 10             	cmp    0x10(%ebp),%esi
  800864:	72 cc                	jb     800832 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800866:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800869:	5b                   	pop    %ebx
  80086a:	5e                   	pop    %esi
  80086b:	5f                   	pop    %edi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800879:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80087d:	74 2a                	je     8008a9 <devcons_read+0x3b>
  80087f:	eb 05                	jmp    800886 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800881:	e8 87 0c 00 00       	call   80150d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800886:	e8 03 0c 00 00       	call   80148e <sys_cgetc>
  80088b:	85 c0                	test   %eax,%eax
  80088d:	74 f2                	je     800881 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80088f:	85 c0                	test   %eax,%eax
  800891:	78 16                	js     8008a9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800893:	83 f8 04             	cmp    $0x4,%eax
  800896:	74 0c                	je     8008a4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089b:	88 02                	mov    %al,(%edx)
	return 1;
  80089d:	b8 01 00 00 00       	mov    $0x1,%eax
  8008a2:	eb 05                	jmp    8008a9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008a4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008b7:	6a 01                	push   $0x1
  8008b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008bc:	50                   	push   %eax
  8008bd:	e8 ae 0b 00 00       	call   801470 <sys_cputs>
}
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <getchar>:

int
getchar(void)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8008cd:	6a 01                	push   $0x1
  8008cf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008d2:	50                   	push   %eax
  8008d3:	6a 00                	push   $0x0
  8008d5:	e8 bb 14 00 00       	call   801d95 <read>
	if (r < 0)
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 0f                	js     8008f0 <getchar+0x29>
		return r;
	if (r < 1)
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	7e 06                	jle    8008eb <getchar+0x24>
		return -E_EOF;
	return c;
  8008e5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8008e9:	eb 05                	jmp    8008f0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8008eb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008fb:	50                   	push   %eax
  8008fc:	ff 75 08             	pushl  0x8(%ebp)
  8008ff:	e8 2b 12 00 00       	call   801b2f <fd_lookup>
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	85 c0                	test   %eax,%eax
  800909:	78 11                	js     80091c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80090b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800914:	39 10                	cmp    %edx,(%eax)
  800916:	0f 94 c0             	sete   %al
  800919:	0f b6 c0             	movzbl %al,%eax
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <opencons>:

int
opencons(void)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800924:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800927:	50                   	push   %eax
  800928:	e8 b3 11 00 00       	call   801ae0 <fd_alloc>
  80092d:	83 c4 10             	add    $0x10,%esp
		return r;
  800930:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800932:	85 c0                	test   %eax,%eax
  800934:	78 3e                	js     800974 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800936:	83 ec 04             	sub    $0x4,%esp
  800939:	68 07 04 00 00       	push   $0x407
  80093e:	ff 75 f4             	pushl  -0xc(%ebp)
  800941:	6a 00                	push   $0x0
  800943:	e8 e4 0b 00 00       	call   80152c <sys_page_alloc>
  800948:	83 c4 10             	add    $0x10,%esp
		return r;
  80094b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80094d:	85 c0                	test   %eax,%eax
  80094f:	78 23                	js     800974 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800951:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80095c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800966:	83 ec 0c             	sub    $0xc,%esp
  800969:	50                   	push   %eax
  80096a:	e8 4a 11 00 00       	call   801ab9 <fd2num>
  80096f:	89 c2                	mov    %eax,%edx
  800971:	83 c4 10             	add    $0x10,%esp
}
  800974:	89 d0                	mov    %edx,%eax
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800980:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800983:	e8 66 0b 00 00       	call   8014ee <sys_getenvid>
  800988:	25 ff 03 00 00       	and    $0x3ff,%eax
  80098d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800990:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800995:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80099a:	85 db                	test   %ebx,%ebx
  80099c:	7e 07                	jle    8009a5 <libmain+0x2d>
		binaryname = argv[0];
  80099e:	8b 06                	mov    (%esi),%eax
  8009a0:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009a5:	83 ec 08             	sub    $0x8,%esp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	e8 6b fc ff ff       	call   80061a <umain>

	// exit gracefully
	exit();
  8009af:	e8 0a 00 00 00       	call   8009be <exit>
}
  8009b4:	83 c4 10             	add    $0x10,%esp
  8009b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8009c4:	e8 bb 12 00 00       	call   801c84 <close_all>
	sys_env_destroy(0);
  8009c9:	83 ec 0c             	sub    $0xc,%esp
  8009cc:	6a 00                	push   $0x0
  8009ce:	e8 da 0a 00 00       	call   8014ad <sys_env_destroy>
}
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8009dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8009e0:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8009e6:	e8 03 0b 00 00       	call   8014ee <sys_getenvid>
  8009eb:	83 ec 0c             	sub    $0xc,%esp
  8009ee:	ff 75 0c             	pushl  0xc(%ebp)
  8009f1:	ff 75 08             	pushl  0x8(%ebp)
  8009f4:	56                   	push   %esi
  8009f5:	50                   	push   %eax
  8009f6:	68 c0 33 80 00       	push   $0x8033c0
  8009fb:	e8 b1 00 00 00       	call   800ab1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a00:	83 c4 18             	add    $0x18,%esp
  800a03:	53                   	push   %ebx
  800a04:	ff 75 10             	pushl  0x10(%ebp)
  800a07:	e8 54 00 00 00       	call   800a60 <vcprintf>
	cprintf("\n");
  800a0c:	c7 04 24 c0 31 80 00 	movl   $0x8031c0,(%esp)
  800a13:	e8 99 00 00 00       	call   800ab1 <cprintf>
  800a18:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a1b:	cc                   	int3   
  800a1c:	eb fd                	jmp    800a1b <_panic+0x43>

00800a1e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	53                   	push   %ebx
  800a22:	83 ec 04             	sub    $0x4,%esp
  800a25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a28:	8b 13                	mov    (%ebx),%edx
  800a2a:	8d 42 01             	lea    0x1(%edx),%eax
  800a2d:	89 03                	mov    %eax,(%ebx)
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a36:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a3b:	75 1a                	jne    800a57 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a3d:	83 ec 08             	sub    $0x8,%esp
  800a40:	68 ff 00 00 00       	push   $0xff
  800a45:	8d 43 08             	lea    0x8(%ebx),%eax
  800a48:	50                   	push   %eax
  800a49:	e8 22 0a 00 00       	call   801470 <sys_cputs>
		b->idx = 0;
  800a4e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a54:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a57:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800a69:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800a70:	00 00 00 
	b.cnt = 0;
  800a73:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800a7a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800a7d:	ff 75 0c             	pushl  0xc(%ebp)
  800a80:	ff 75 08             	pushl  0x8(%ebp)
  800a83:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800a89:	50                   	push   %eax
  800a8a:	68 1e 0a 80 00       	push   $0x800a1e
  800a8f:	e8 54 01 00 00       	call   800be8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800a94:	83 c4 08             	add    $0x8,%esp
  800a97:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800a9d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800aa3:	50                   	push   %eax
  800aa4:	e8 c7 09 00 00       	call   801470 <sys_cputs>

	return b.cnt;
}
  800aa9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aaf:	c9                   	leave  
  800ab0:	c3                   	ret    

00800ab1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800ab7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800aba:	50                   	push   %eax
  800abb:	ff 75 08             	pushl  0x8(%ebp)
  800abe:	e8 9d ff ff ff       	call   800a60 <vcprintf>
	va_end(ap);

	return cnt;
}
  800ac3:	c9                   	leave  
  800ac4:	c3                   	ret    

00800ac5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 1c             	sub    $0x1c,%esp
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800adb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ae1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ae6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800ae9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800aec:	39 d3                	cmp    %edx,%ebx
  800aee:	72 05                	jb     800af5 <printnum+0x30>
  800af0:	39 45 10             	cmp    %eax,0x10(%ebp)
  800af3:	77 45                	ja     800b3a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	ff 75 18             	pushl  0x18(%ebp)
  800afb:	8b 45 14             	mov    0x14(%ebp),%eax
  800afe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800b01:	53                   	push   %ebx
  800b02:	ff 75 10             	pushl  0x10(%ebp)
  800b05:	83 ec 08             	sub    $0x8,%esp
  800b08:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b0b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b0e:	ff 75 dc             	pushl  -0x24(%ebp)
  800b11:	ff 75 d8             	pushl  -0x28(%ebp)
  800b14:	e8 f7 23 00 00       	call   802f10 <__udivdi3>
  800b19:	83 c4 18             	add    $0x18,%esp
  800b1c:	52                   	push   %edx
  800b1d:	50                   	push   %eax
  800b1e:	89 f2                	mov    %esi,%edx
  800b20:	89 f8                	mov    %edi,%eax
  800b22:	e8 9e ff ff ff       	call   800ac5 <printnum>
  800b27:	83 c4 20             	add    $0x20,%esp
  800b2a:	eb 18                	jmp    800b44 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b2c:	83 ec 08             	sub    $0x8,%esp
  800b2f:	56                   	push   %esi
  800b30:	ff 75 18             	pushl  0x18(%ebp)
  800b33:	ff d7                	call   *%edi
  800b35:	83 c4 10             	add    $0x10,%esp
  800b38:	eb 03                	jmp    800b3d <printnum+0x78>
  800b3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b3d:	83 eb 01             	sub    $0x1,%ebx
  800b40:	85 db                	test   %ebx,%ebx
  800b42:	7f e8                	jg     800b2c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b44:	83 ec 08             	sub    $0x8,%esp
  800b47:	56                   	push   %esi
  800b48:	83 ec 04             	sub    $0x4,%esp
  800b4b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b4e:	ff 75 e0             	pushl  -0x20(%ebp)
  800b51:	ff 75 dc             	pushl  -0x24(%ebp)
  800b54:	ff 75 d8             	pushl  -0x28(%ebp)
  800b57:	e8 e4 24 00 00       	call   803040 <__umoddi3>
  800b5c:	83 c4 14             	add    $0x14,%esp
  800b5f:	0f be 80 e3 33 80 00 	movsbl 0x8033e3(%eax),%eax
  800b66:	50                   	push   %eax
  800b67:	ff d7                	call   *%edi
}
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b77:	83 fa 01             	cmp    $0x1,%edx
  800b7a:	7e 0e                	jle    800b8a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800b7c:	8b 10                	mov    (%eax),%edx
  800b7e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800b81:	89 08                	mov    %ecx,(%eax)
  800b83:	8b 02                	mov    (%edx),%eax
  800b85:	8b 52 04             	mov    0x4(%edx),%edx
  800b88:	eb 22                	jmp    800bac <getuint+0x38>
	else if (lflag)
  800b8a:	85 d2                	test   %edx,%edx
  800b8c:	74 10                	je     800b9e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800b8e:	8b 10                	mov    (%eax),%edx
  800b90:	8d 4a 04             	lea    0x4(%edx),%ecx
  800b93:	89 08                	mov    %ecx,(%eax)
  800b95:	8b 02                	mov    (%edx),%eax
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	eb 0e                	jmp    800bac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800b9e:	8b 10                	mov    (%eax),%edx
  800ba0:	8d 4a 04             	lea    0x4(%edx),%ecx
  800ba3:	89 08                	mov    %ecx,(%eax)
  800ba5:	8b 02                	mov    (%edx),%eax
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bb4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bb8:	8b 10                	mov    (%eax),%edx
  800bba:	3b 50 04             	cmp    0x4(%eax),%edx
  800bbd:	73 0a                	jae    800bc9 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bbf:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bc2:	89 08                	mov    %ecx,(%eax)
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc7:	88 02                	mov    %al,(%edx)
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800bd1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800bd4:	50                   	push   %eax
  800bd5:	ff 75 10             	pushl  0x10(%ebp)
  800bd8:	ff 75 0c             	pushl  0xc(%ebp)
  800bdb:	ff 75 08             	pushl  0x8(%ebp)
  800bde:	e8 05 00 00 00       	call   800be8 <vprintfmt>
	va_end(ap);
}
  800be3:	83 c4 10             	add    $0x10,%esp
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 2c             	sub    $0x2c,%esp
  800bf1:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf7:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bfa:	eb 12                	jmp    800c0e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	0f 84 89 03 00 00    	je     800f8d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800c04:	83 ec 08             	sub    $0x8,%esp
  800c07:	53                   	push   %ebx
  800c08:	50                   	push   %eax
  800c09:	ff d6                	call   *%esi
  800c0b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c0e:	83 c7 01             	add    $0x1,%edi
  800c11:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c15:	83 f8 25             	cmp    $0x25,%eax
  800c18:	75 e2                	jne    800bfc <vprintfmt+0x14>
  800c1a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c1e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c25:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c2c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	eb 07                	jmp    800c41 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c3d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c41:	8d 47 01             	lea    0x1(%edi),%eax
  800c44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c47:	0f b6 07             	movzbl (%edi),%eax
  800c4a:	0f b6 c8             	movzbl %al,%ecx
  800c4d:	83 e8 23             	sub    $0x23,%eax
  800c50:	3c 55                	cmp    $0x55,%al
  800c52:	0f 87 1a 03 00 00    	ja     800f72 <vprintfmt+0x38a>
  800c58:	0f b6 c0             	movzbl %al,%eax
  800c5b:	ff 24 85 20 35 80 00 	jmp    *0x803520(,%eax,4)
  800c62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c65:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800c69:	eb d6                	jmp    800c41 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c73:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800c76:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800c79:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800c7d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800c80:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800c83:	83 fa 09             	cmp    $0x9,%edx
  800c86:	77 39                	ja     800cc1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c88:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c8b:	eb e9                	jmp    800c76 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c90:	8d 48 04             	lea    0x4(%eax),%ecx
  800c93:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800c96:	8b 00                	mov    (%eax),%eax
  800c98:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800c9e:	eb 27                	jmp    800cc7 <vprintfmt+0xdf>
  800ca0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800caa:	0f 49 c8             	cmovns %eax,%ecx
  800cad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cb3:	eb 8c                	jmp    800c41 <vprintfmt+0x59>
  800cb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cb8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cbf:	eb 80                	jmp    800c41 <vprintfmt+0x59>
  800cc1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cc4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800cc7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ccb:	0f 89 70 ff ff ff    	jns    800c41 <vprintfmt+0x59>
				width = precision, precision = -1;
  800cd1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800cd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800cd7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800cde:	e9 5e ff ff ff       	jmp    800c41 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800ce3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800ce9:	e9 53 ff ff ff       	jmp    800c41 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800cee:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf1:	8d 50 04             	lea    0x4(%eax),%edx
  800cf4:	89 55 14             	mov    %edx,0x14(%ebp)
  800cf7:	83 ec 08             	sub    $0x8,%esp
  800cfa:	53                   	push   %ebx
  800cfb:	ff 30                	pushl  (%eax)
  800cfd:	ff d6                	call   *%esi
			break;
  800cff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d05:	e9 04 ff ff ff       	jmp    800c0e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0d:	8d 50 04             	lea    0x4(%eax),%edx
  800d10:	89 55 14             	mov    %edx,0x14(%ebp)
  800d13:	8b 00                	mov    (%eax),%eax
  800d15:	99                   	cltd   
  800d16:	31 d0                	xor    %edx,%eax
  800d18:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d1a:	83 f8 0f             	cmp    $0xf,%eax
  800d1d:	7f 0b                	jg     800d2a <vprintfmt+0x142>
  800d1f:	8b 14 85 80 36 80 00 	mov    0x803680(,%eax,4),%edx
  800d26:	85 d2                	test   %edx,%edx
  800d28:	75 18                	jne    800d42 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d2a:	50                   	push   %eax
  800d2b:	68 fb 33 80 00       	push   $0x8033fb
  800d30:	53                   	push   %ebx
  800d31:	56                   	push   %esi
  800d32:	e8 94 fe ff ff       	call   800bcb <printfmt>
  800d37:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d3d:	e9 cc fe ff ff       	jmp    800c0e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d42:	52                   	push   %edx
  800d43:	68 01 33 80 00       	push   $0x803301
  800d48:	53                   	push   %ebx
  800d49:	56                   	push   %esi
  800d4a:	e8 7c fe ff ff       	call   800bcb <printfmt>
  800d4f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d55:	e9 b4 fe ff ff       	jmp    800c0e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5d:	8d 50 04             	lea    0x4(%eax),%edx
  800d60:	89 55 14             	mov    %edx,0x14(%ebp)
  800d63:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800d65:	85 ff                	test   %edi,%edi
  800d67:	b8 f4 33 80 00       	mov    $0x8033f4,%eax
  800d6c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800d6f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d73:	0f 8e 94 00 00 00    	jle    800e0d <vprintfmt+0x225>
  800d79:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800d7d:	0f 84 98 00 00 00    	je     800e1b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d83:	83 ec 08             	sub    $0x8,%esp
  800d86:	ff 75 d0             	pushl  -0x30(%ebp)
  800d89:	57                   	push   %edi
  800d8a:	e8 79 03 00 00       	call   801108 <strnlen>
  800d8f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800d92:	29 c1                	sub    %eax,%ecx
  800d94:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800d97:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800d9a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800d9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800da1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800da4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800da6:	eb 0f                	jmp    800db7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	53                   	push   %ebx
  800dac:	ff 75 e0             	pushl  -0x20(%ebp)
  800daf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800db1:	83 ef 01             	sub    $0x1,%edi
  800db4:	83 c4 10             	add    $0x10,%esp
  800db7:	85 ff                	test   %edi,%edi
  800db9:	7f ed                	jg     800da8 <vprintfmt+0x1c0>
  800dbb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dbe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800dc1:	85 c9                	test   %ecx,%ecx
  800dc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc8:	0f 49 c1             	cmovns %ecx,%eax
  800dcb:	29 c1                	sub    %eax,%ecx
  800dcd:	89 75 08             	mov    %esi,0x8(%ebp)
  800dd0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800dd3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800dd6:	89 cb                	mov    %ecx,%ebx
  800dd8:	eb 4d                	jmp    800e27 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800dda:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800dde:	74 1b                	je     800dfb <vprintfmt+0x213>
  800de0:	0f be c0             	movsbl %al,%eax
  800de3:	83 e8 20             	sub    $0x20,%eax
  800de6:	83 f8 5e             	cmp    $0x5e,%eax
  800de9:	76 10                	jbe    800dfb <vprintfmt+0x213>
					putch('?', putdat);
  800deb:	83 ec 08             	sub    $0x8,%esp
  800dee:	ff 75 0c             	pushl  0xc(%ebp)
  800df1:	6a 3f                	push   $0x3f
  800df3:	ff 55 08             	call   *0x8(%ebp)
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	eb 0d                	jmp    800e08 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800dfb:	83 ec 08             	sub    $0x8,%esp
  800dfe:	ff 75 0c             	pushl  0xc(%ebp)
  800e01:	52                   	push   %edx
  800e02:	ff 55 08             	call   *0x8(%ebp)
  800e05:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e08:	83 eb 01             	sub    $0x1,%ebx
  800e0b:	eb 1a                	jmp    800e27 <vprintfmt+0x23f>
  800e0d:	89 75 08             	mov    %esi,0x8(%ebp)
  800e10:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e13:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e16:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e19:	eb 0c                	jmp    800e27 <vprintfmt+0x23f>
  800e1b:	89 75 08             	mov    %esi,0x8(%ebp)
  800e1e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e21:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e24:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e27:	83 c7 01             	add    $0x1,%edi
  800e2a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e2e:	0f be d0             	movsbl %al,%edx
  800e31:	85 d2                	test   %edx,%edx
  800e33:	74 23                	je     800e58 <vprintfmt+0x270>
  800e35:	85 f6                	test   %esi,%esi
  800e37:	78 a1                	js     800dda <vprintfmt+0x1f2>
  800e39:	83 ee 01             	sub    $0x1,%esi
  800e3c:	79 9c                	jns    800dda <vprintfmt+0x1f2>
  800e3e:	89 df                	mov    %ebx,%edi
  800e40:	8b 75 08             	mov    0x8(%ebp),%esi
  800e43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e46:	eb 18                	jmp    800e60 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	53                   	push   %ebx
  800e4c:	6a 20                	push   $0x20
  800e4e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e50:	83 ef 01             	sub    $0x1,%edi
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	eb 08                	jmp    800e60 <vprintfmt+0x278>
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800e5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e60:	85 ff                	test   %edi,%edi
  800e62:	7f e4                	jg     800e48 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e67:	e9 a2 fd ff ff       	jmp    800c0e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e6c:	83 fa 01             	cmp    $0x1,%edx
  800e6f:	7e 16                	jle    800e87 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800e71:	8b 45 14             	mov    0x14(%ebp),%eax
  800e74:	8d 50 08             	lea    0x8(%eax),%edx
  800e77:	89 55 14             	mov    %edx,0x14(%ebp)
  800e7a:	8b 50 04             	mov    0x4(%eax),%edx
  800e7d:	8b 00                	mov    (%eax),%eax
  800e7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e82:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800e85:	eb 32                	jmp    800eb9 <vprintfmt+0x2d1>
	else if (lflag)
  800e87:	85 d2                	test   %edx,%edx
  800e89:	74 18                	je     800ea3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800e8b:	8b 45 14             	mov    0x14(%ebp),%eax
  800e8e:	8d 50 04             	lea    0x4(%eax),%edx
  800e91:	89 55 14             	mov    %edx,0x14(%ebp)
  800e94:	8b 00                	mov    (%eax),%eax
  800e96:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e99:	89 c1                	mov    %eax,%ecx
  800e9b:	c1 f9 1f             	sar    $0x1f,%ecx
  800e9e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ea1:	eb 16                	jmp    800eb9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800ea3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ea6:	8d 50 04             	lea    0x4(%eax),%edx
  800ea9:	89 55 14             	mov    %edx,0x14(%ebp)
  800eac:	8b 00                	mov    (%eax),%eax
  800eae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eb1:	89 c1                	mov    %eax,%ecx
  800eb3:	c1 f9 1f             	sar    $0x1f,%ecx
  800eb6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800eb9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ebc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ebf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ec4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ec8:	79 74                	jns    800f3e <vprintfmt+0x356>
				putch('-', putdat);
  800eca:	83 ec 08             	sub    $0x8,%esp
  800ecd:	53                   	push   %ebx
  800ece:	6a 2d                	push   $0x2d
  800ed0:	ff d6                	call   *%esi
				num = -(long long) num;
  800ed2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ed5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800ed8:	f7 d8                	neg    %eax
  800eda:	83 d2 00             	adc    $0x0,%edx
  800edd:	f7 da                	neg    %edx
  800edf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ee2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ee7:	eb 55                	jmp    800f3e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ee9:	8d 45 14             	lea    0x14(%ebp),%eax
  800eec:	e8 83 fc ff ff       	call   800b74 <getuint>
			base = 10;
  800ef1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ef6:	eb 46                	jmp    800f3e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800ef8:	8d 45 14             	lea    0x14(%ebp),%eax
  800efb:	e8 74 fc ff ff       	call   800b74 <getuint>
                        base = 8;
  800f00:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800f05:	eb 37                	jmp    800f3e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	53                   	push   %ebx
  800f0b:	6a 30                	push   $0x30
  800f0d:	ff d6                	call   *%esi
			putch('x', putdat);
  800f0f:	83 c4 08             	add    $0x8,%esp
  800f12:	53                   	push   %ebx
  800f13:	6a 78                	push   $0x78
  800f15:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f17:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1a:	8d 50 04             	lea    0x4(%eax),%edx
  800f1d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f20:	8b 00                	mov    (%eax),%eax
  800f22:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f27:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f2a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f2f:	eb 0d                	jmp    800f3e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f31:	8d 45 14             	lea    0x14(%ebp),%eax
  800f34:	e8 3b fc ff ff       	call   800b74 <getuint>
			base = 16;
  800f39:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800f45:	57                   	push   %edi
  800f46:	ff 75 e0             	pushl  -0x20(%ebp)
  800f49:	51                   	push   %ecx
  800f4a:	52                   	push   %edx
  800f4b:	50                   	push   %eax
  800f4c:	89 da                	mov    %ebx,%edx
  800f4e:	89 f0                	mov    %esi,%eax
  800f50:	e8 70 fb ff ff       	call   800ac5 <printnum>
			break;
  800f55:	83 c4 20             	add    $0x20,%esp
  800f58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f5b:	e9 ae fc ff ff       	jmp    800c0e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f60:	83 ec 08             	sub    $0x8,%esp
  800f63:	53                   	push   %ebx
  800f64:	51                   	push   %ecx
  800f65:	ff d6                	call   *%esi
			break;
  800f67:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800f6d:	e9 9c fc ff ff       	jmp    800c0e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800f72:	83 ec 08             	sub    $0x8,%esp
  800f75:	53                   	push   %ebx
  800f76:	6a 25                	push   $0x25
  800f78:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	eb 03                	jmp    800f82 <vprintfmt+0x39a>
  800f7f:	83 ef 01             	sub    $0x1,%edi
  800f82:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800f86:	75 f7                	jne    800f7f <vprintfmt+0x397>
  800f88:	e9 81 fc ff ff       	jmp    800c0e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800f8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 18             	sub    $0x18,%esp
  800f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fa1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fa4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800fa8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	74 26                	je     800fdc <vsnprintf+0x47>
  800fb6:	85 d2                	test   %edx,%edx
  800fb8:	7e 22                	jle    800fdc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800fba:	ff 75 14             	pushl  0x14(%ebp)
  800fbd:	ff 75 10             	pushl  0x10(%ebp)
  800fc0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	68 ae 0b 80 00       	push   $0x800bae
  800fc9:	e8 1a fc ff ff       	call   800be8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800fce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fd1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	eb 05                	jmp    800fe1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800fdc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800fe1:	c9                   	leave  
  800fe2:	c3                   	ret    

00800fe3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800fe9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800fec:	50                   	push   %eax
  800fed:	ff 75 10             	pushl  0x10(%ebp)
  800ff0:	ff 75 0c             	pushl  0xc(%ebp)
  800ff3:	ff 75 08             	pushl  0x8(%ebp)
  800ff6:	e8 9a ff ff ff       	call   800f95 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	57                   	push   %edi
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  801009:	85 c0                	test   %eax,%eax
  80100b:	74 13                	je     801020 <readline+0x23>
		fprintf(1, "%s", prompt);
  80100d:	83 ec 04             	sub    $0x4,%esp
  801010:	50                   	push   %eax
  801011:	68 01 33 80 00       	push   $0x803301
  801016:	6a 01                	push   $0x1
  801018:	e8 b3 13 00 00       	call   8023d0 <fprintf>
  80101d:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	6a 00                	push   $0x0
  801025:	e8 c8 f8 ff ff       	call   8008f2 <iscons>
  80102a:	89 c7                	mov    %eax,%edi
  80102c:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  80102f:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  801034:	e8 8e f8 ff ff       	call   8008c7 <getchar>
  801039:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80103b:	85 c0                	test   %eax,%eax
  80103d:	79 29                	jns    801068 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  80103f:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  801044:	83 fb f8             	cmp    $0xfffffff8,%ebx
  801047:	0f 84 9b 00 00 00    	je     8010e8 <readline+0xeb>
				cprintf("read error: %e\n", c);
  80104d:	83 ec 08             	sub    $0x8,%esp
  801050:	53                   	push   %ebx
  801051:	68 df 36 80 00       	push   $0x8036df
  801056:	e8 56 fa ff ff       	call   800ab1 <cprintf>
  80105b:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80105e:	b8 00 00 00 00       	mov    $0x0,%eax
  801063:	e9 80 00 00 00       	jmp    8010e8 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801068:	83 f8 08             	cmp    $0x8,%eax
  80106b:	0f 94 c2             	sete   %dl
  80106e:	83 f8 7f             	cmp    $0x7f,%eax
  801071:	0f 94 c0             	sete   %al
  801074:	08 c2                	or     %al,%dl
  801076:	74 1a                	je     801092 <readline+0x95>
  801078:	85 f6                	test   %esi,%esi
  80107a:	7e 16                	jle    801092 <readline+0x95>
			if (echoing)
  80107c:	85 ff                	test   %edi,%edi
  80107e:	74 0d                	je     80108d <readline+0x90>
				cputchar('\b');
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	6a 08                	push   $0x8
  801085:	e8 21 f8 ff ff       	call   8008ab <cputchar>
  80108a:	83 c4 10             	add    $0x10,%esp
			i--;
  80108d:	83 ee 01             	sub    $0x1,%esi
  801090:	eb a2                	jmp    801034 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801092:	83 fb 1f             	cmp    $0x1f,%ebx
  801095:	7e 26                	jle    8010bd <readline+0xc0>
  801097:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80109d:	7f 1e                	jg     8010bd <readline+0xc0>
			if (echoing)
  80109f:	85 ff                	test   %edi,%edi
  8010a1:	74 0c                	je     8010af <readline+0xb2>
				cputchar(c);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	53                   	push   %ebx
  8010a7:	e8 ff f7 ff ff       	call   8008ab <cputchar>
  8010ac:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8010af:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8010b5:	8d 76 01             	lea    0x1(%esi),%esi
  8010b8:	e9 77 ff ff ff       	jmp    801034 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  8010bd:	83 fb 0a             	cmp    $0xa,%ebx
  8010c0:	74 09                	je     8010cb <readline+0xce>
  8010c2:	83 fb 0d             	cmp    $0xd,%ebx
  8010c5:	0f 85 69 ff ff ff    	jne    801034 <readline+0x37>
			if (echoing)
  8010cb:	85 ff                	test   %edi,%edi
  8010cd:	74 0d                	je     8010dc <readline+0xdf>
				cputchar('\n');
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	6a 0a                	push   $0xa
  8010d4:	e8 d2 f7 ff ff       	call   8008ab <cputchar>
  8010d9:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8010dc:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  8010e3:	b8 20 50 80 00       	mov    $0x805020,%eax
		}
	}
}
  8010e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8010f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fb:	eb 03                	jmp    801100 <strlen+0x10>
		n++;
  8010fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801100:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801104:	75 f7                	jne    8010fd <strlen+0xd>
		n++;
	return n;
}
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801111:	ba 00 00 00 00       	mov    $0x0,%edx
  801116:	eb 03                	jmp    80111b <strnlen+0x13>
		n++;
  801118:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80111b:	39 c2                	cmp    %eax,%edx
  80111d:	74 08                	je     801127 <strnlen+0x1f>
  80111f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801123:	75 f3                	jne    801118 <strnlen+0x10>
  801125:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	53                   	push   %ebx
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
  801130:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801133:	89 c2                	mov    %eax,%edx
  801135:	83 c2 01             	add    $0x1,%edx
  801138:	83 c1 01             	add    $0x1,%ecx
  80113b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80113f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801142:	84 db                	test   %bl,%bl
  801144:	75 ef                	jne    801135 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801146:	5b                   	pop    %ebx
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	53                   	push   %ebx
  80114d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801150:	53                   	push   %ebx
  801151:	e8 9a ff ff ff       	call   8010f0 <strlen>
  801156:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801159:	ff 75 0c             	pushl  0xc(%ebp)
  80115c:	01 d8                	add    %ebx,%eax
  80115e:	50                   	push   %eax
  80115f:	e8 c5 ff ff ff       	call   801129 <strcpy>
	return dst;
}
  801164:	89 d8                	mov    %ebx,%eax
  801166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801169:	c9                   	leave  
  80116a:	c3                   	ret    

0080116b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	56                   	push   %esi
  80116f:	53                   	push   %ebx
  801170:	8b 75 08             	mov    0x8(%ebp),%esi
  801173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801176:	89 f3                	mov    %esi,%ebx
  801178:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80117b:	89 f2                	mov    %esi,%edx
  80117d:	eb 0f                	jmp    80118e <strncpy+0x23>
		*dst++ = *src;
  80117f:	83 c2 01             	add    $0x1,%edx
  801182:	0f b6 01             	movzbl (%ecx),%eax
  801185:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801188:	80 39 01             	cmpb   $0x1,(%ecx)
  80118b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80118e:	39 da                	cmp    %ebx,%edx
  801190:	75 ed                	jne    80117f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801192:	89 f0                	mov    %esi,%eax
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a3:	8b 55 10             	mov    0x10(%ebp),%edx
  8011a6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8011a8:	85 d2                	test   %edx,%edx
  8011aa:	74 21                	je     8011cd <strlcpy+0x35>
  8011ac:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8011b0:	89 f2                	mov    %esi,%edx
  8011b2:	eb 09                	jmp    8011bd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8011b4:	83 c2 01             	add    $0x1,%edx
  8011b7:	83 c1 01             	add    $0x1,%ecx
  8011ba:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8011bd:	39 c2                	cmp    %eax,%edx
  8011bf:	74 09                	je     8011ca <strlcpy+0x32>
  8011c1:	0f b6 19             	movzbl (%ecx),%ebx
  8011c4:	84 db                	test   %bl,%bl
  8011c6:	75 ec                	jne    8011b4 <strlcpy+0x1c>
  8011c8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8011ca:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8011cd:	29 f0                	sub    %esi,%eax
}
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8011dc:	eb 06                	jmp    8011e4 <strcmp+0x11>
		p++, q++;
  8011de:	83 c1 01             	add    $0x1,%ecx
  8011e1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8011e4:	0f b6 01             	movzbl (%ecx),%eax
  8011e7:	84 c0                	test   %al,%al
  8011e9:	74 04                	je     8011ef <strcmp+0x1c>
  8011eb:	3a 02                	cmp    (%edx),%al
  8011ed:	74 ef                	je     8011de <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8011ef:	0f b6 c0             	movzbl %al,%eax
  8011f2:	0f b6 12             	movzbl (%edx),%edx
  8011f5:	29 d0                	sub    %edx,%eax
}
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	53                   	push   %ebx
  8011fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801200:	8b 55 0c             	mov    0xc(%ebp),%edx
  801203:	89 c3                	mov    %eax,%ebx
  801205:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801208:	eb 06                	jmp    801210 <strncmp+0x17>
		n--, p++, q++;
  80120a:	83 c0 01             	add    $0x1,%eax
  80120d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801210:	39 d8                	cmp    %ebx,%eax
  801212:	74 15                	je     801229 <strncmp+0x30>
  801214:	0f b6 08             	movzbl (%eax),%ecx
  801217:	84 c9                	test   %cl,%cl
  801219:	74 04                	je     80121f <strncmp+0x26>
  80121b:	3a 0a                	cmp    (%edx),%cl
  80121d:	74 eb                	je     80120a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80121f:	0f b6 00             	movzbl (%eax),%eax
  801222:	0f b6 12             	movzbl (%edx),%edx
  801225:	29 d0                	sub    %edx,%eax
  801227:	eb 05                	jmp    80122e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801229:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80122e:	5b                   	pop    %ebx
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	8b 45 08             	mov    0x8(%ebp),%eax
  801237:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80123b:	eb 07                	jmp    801244 <strchr+0x13>
		if (*s == c)
  80123d:	38 ca                	cmp    %cl,%dl
  80123f:	74 0f                	je     801250 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801241:	83 c0 01             	add    $0x1,%eax
  801244:	0f b6 10             	movzbl (%eax),%edx
  801247:	84 d2                	test   %dl,%dl
  801249:	75 f2                	jne    80123d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80124b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	8b 45 08             	mov    0x8(%ebp),%eax
  801258:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80125c:	eb 03                	jmp    801261 <strfind+0xf>
  80125e:	83 c0 01             	add    $0x1,%eax
  801261:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801264:	38 ca                	cmp    %cl,%dl
  801266:	74 04                	je     80126c <strfind+0x1a>
  801268:	84 d2                	test   %dl,%dl
  80126a:	75 f2                	jne    80125e <strfind+0xc>
			break;
	return (char *) s;
}
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	8b 7d 08             	mov    0x8(%ebp),%edi
  801277:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80127a:	85 c9                	test   %ecx,%ecx
  80127c:	74 36                	je     8012b4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80127e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801284:	75 28                	jne    8012ae <memset+0x40>
  801286:	f6 c1 03             	test   $0x3,%cl
  801289:	75 23                	jne    8012ae <memset+0x40>
		c &= 0xFF;
  80128b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80128f:	89 d3                	mov    %edx,%ebx
  801291:	c1 e3 08             	shl    $0x8,%ebx
  801294:	89 d6                	mov    %edx,%esi
  801296:	c1 e6 18             	shl    $0x18,%esi
  801299:	89 d0                	mov    %edx,%eax
  80129b:	c1 e0 10             	shl    $0x10,%eax
  80129e:	09 f0                	or     %esi,%eax
  8012a0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8012a2:	89 d8                	mov    %ebx,%eax
  8012a4:	09 d0                	or     %edx,%eax
  8012a6:	c1 e9 02             	shr    $0x2,%ecx
  8012a9:	fc                   	cld    
  8012aa:	f3 ab                	rep stos %eax,%es:(%edi)
  8012ac:	eb 06                	jmp    8012b4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8012ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b1:	fc                   	cld    
  8012b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8012b4:	89 f8                	mov    %edi,%eax
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    

008012bb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	57                   	push   %edi
  8012bf:	56                   	push   %esi
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8012c9:	39 c6                	cmp    %eax,%esi
  8012cb:	73 35                	jae    801302 <memmove+0x47>
  8012cd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8012d0:	39 d0                	cmp    %edx,%eax
  8012d2:	73 2e                	jae    801302 <memmove+0x47>
		s += n;
		d += n;
  8012d4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8012d7:	89 d6                	mov    %edx,%esi
  8012d9:	09 fe                	or     %edi,%esi
  8012db:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8012e1:	75 13                	jne    8012f6 <memmove+0x3b>
  8012e3:	f6 c1 03             	test   $0x3,%cl
  8012e6:	75 0e                	jne    8012f6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8012e8:	83 ef 04             	sub    $0x4,%edi
  8012eb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8012ee:	c1 e9 02             	shr    $0x2,%ecx
  8012f1:	fd                   	std    
  8012f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8012f4:	eb 09                	jmp    8012ff <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8012f6:	83 ef 01             	sub    $0x1,%edi
  8012f9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8012fc:	fd                   	std    
  8012fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8012ff:	fc                   	cld    
  801300:	eb 1d                	jmp    80131f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801302:	89 f2                	mov    %esi,%edx
  801304:	09 c2                	or     %eax,%edx
  801306:	f6 c2 03             	test   $0x3,%dl
  801309:	75 0f                	jne    80131a <memmove+0x5f>
  80130b:	f6 c1 03             	test   $0x3,%cl
  80130e:	75 0a                	jne    80131a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801310:	c1 e9 02             	shr    $0x2,%ecx
  801313:	89 c7                	mov    %eax,%edi
  801315:	fc                   	cld    
  801316:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801318:	eb 05                	jmp    80131f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80131a:	89 c7                	mov    %eax,%edi
  80131c:	fc                   	cld    
  80131d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801326:	ff 75 10             	pushl  0x10(%ebp)
  801329:	ff 75 0c             	pushl  0xc(%ebp)
  80132c:	ff 75 08             	pushl  0x8(%ebp)
  80132f:	e8 87 ff ff ff       	call   8012bb <memmove>
}
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	56                   	push   %esi
  80133a:	53                   	push   %ebx
  80133b:	8b 45 08             	mov    0x8(%ebp),%eax
  80133e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801341:	89 c6                	mov    %eax,%esi
  801343:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801346:	eb 1a                	jmp    801362 <memcmp+0x2c>
		if (*s1 != *s2)
  801348:	0f b6 08             	movzbl (%eax),%ecx
  80134b:	0f b6 1a             	movzbl (%edx),%ebx
  80134e:	38 d9                	cmp    %bl,%cl
  801350:	74 0a                	je     80135c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801352:	0f b6 c1             	movzbl %cl,%eax
  801355:	0f b6 db             	movzbl %bl,%ebx
  801358:	29 d8                	sub    %ebx,%eax
  80135a:	eb 0f                	jmp    80136b <memcmp+0x35>
		s1++, s2++;
  80135c:	83 c0 01             	add    $0x1,%eax
  80135f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801362:	39 f0                	cmp    %esi,%eax
  801364:	75 e2                	jne    801348 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801366:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80136b:	5b                   	pop    %ebx
  80136c:	5e                   	pop    %esi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	53                   	push   %ebx
  801373:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801376:	89 c1                	mov    %eax,%ecx
  801378:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80137b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80137f:	eb 0a                	jmp    80138b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801381:	0f b6 10             	movzbl (%eax),%edx
  801384:	39 da                	cmp    %ebx,%edx
  801386:	74 07                	je     80138f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801388:	83 c0 01             	add    $0x1,%eax
  80138b:	39 c8                	cmp    %ecx,%eax
  80138d:	72 f2                	jb     801381 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80138f:	5b                   	pop    %ebx
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	57                   	push   %edi
  801396:	56                   	push   %esi
  801397:	53                   	push   %ebx
  801398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80139e:	eb 03                	jmp    8013a3 <strtol+0x11>
		s++;
  8013a0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013a3:	0f b6 01             	movzbl (%ecx),%eax
  8013a6:	3c 20                	cmp    $0x20,%al
  8013a8:	74 f6                	je     8013a0 <strtol+0xe>
  8013aa:	3c 09                	cmp    $0x9,%al
  8013ac:	74 f2                	je     8013a0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013ae:	3c 2b                	cmp    $0x2b,%al
  8013b0:	75 0a                	jne    8013bc <strtol+0x2a>
		s++;
  8013b2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8013b5:	bf 00 00 00 00       	mov    $0x0,%edi
  8013ba:	eb 11                	jmp    8013cd <strtol+0x3b>
  8013bc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8013c1:	3c 2d                	cmp    $0x2d,%al
  8013c3:	75 08                	jne    8013cd <strtol+0x3b>
		s++, neg = 1;
  8013c5:	83 c1 01             	add    $0x1,%ecx
  8013c8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8013cd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8013d3:	75 15                	jne    8013ea <strtol+0x58>
  8013d5:	80 39 30             	cmpb   $0x30,(%ecx)
  8013d8:	75 10                	jne    8013ea <strtol+0x58>
  8013da:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8013de:	75 7c                	jne    80145c <strtol+0xca>
		s += 2, base = 16;
  8013e0:	83 c1 02             	add    $0x2,%ecx
  8013e3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8013e8:	eb 16                	jmp    801400 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8013ea:	85 db                	test   %ebx,%ebx
  8013ec:	75 12                	jne    801400 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8013ee:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8013f3:	80 39 30             	cmpb   $0x30,(%ecx)
  8013f6:	75 08                	jne    801400 <strtol+0x6e>
		s++, base = 8;
  8013f8:	83 c1 01             	add    $0x1,%ecx
  8013fb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
  801405:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801408:	0f b6 11             	movzbl (%ecx),%edx
  80140b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80140e:	89 f3                	mov    %esi,%ebx
  801410:	80 fb 09             	cmp    $0x9,%bl
  801413:	77 08                	ja     80141d <strtol+0x8b>
			dig = *s - '0';
  801415:	0f be d2             	movsbl %dl,%edx
  801418:	83 ea 30             	sub    $0x30,%edx
  80141b:	eb 22                	jmp    80143f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80141d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801420:	89 f3                	mov    %esi,%ebx
  801422:	80 fb 19             	cmp    $0x19,%bl
  801425:	77 08                	ja     80142f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801427:	0f be d2             	movsbl %dl,%edx
  80142a:	83 ea 57             	sub    $0x57,%edx
  80142d:	eb 10                	jmp    80143f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80142f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801432:	89 f3                	mov    %esi,%ebx
  801434:	80 fb 19             	cmp    $0x19,%bl
  801437:	77 16                	ja     80144f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801439:	0f be d2             	movsbl %dl,%edx
  80143c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80143f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801442:	7d 0b                	jge    80144f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801444:	83 c1 01             	add    $0x1,%ecx
  801447:	0f af 45 10          	imul   0x10(%ebp),%eax
  80144b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80144d:	eb b9                	jmp    801408 <strtol+0x76>

	if (endptr)
  80144f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801453:	74 0d                	je     801462 <strtol+0xd0>
		*endptr = (char *) s;
  801455:	8b 75 0c             	mov    0xc(%ebp),%esi
  801458:	89 0e                	mov    %ecx,(%esi)
  80145a:	eb 06                	jmp    801462 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80145c:	85 db                	test   %ebx,%ebx
  80145e:	74 98                	je     8013f8 <strtol+0x66>
  801460:	eb 9e                	jmp    801400 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801462:	89 c2                	mov    %eax,%edx
  801464:	f7 da                	neg    %edx
  801466:	85 ff                	test   %edi,%edi
  801468:	0f 45 c2             	cmovne %edx,%eax
}
  80146b:	5b                   	pop    %ebx
  80146c:	5e                   	pop    %esi
  80146d:	5f                   	pop    %edi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	57                   	push   %edi
  801474:	56                   	push   %esi
  801475:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801476:	b8 00 00 00 00       	mov    $0x0,%eax
  80147b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80147e:	8b 55 08             	mov    0x8(%ebp),%edx
  801481:	89 c3                	mov    %eax,%ebx
  801483:	89 c7                	mov    %eax,%edi
  801485:	89 c6                	mov    %eax,%esi
  801487:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5f                   	pop    %edi
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <sys_cgetc>:

int
sys_cgetc(void)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	57                   	push   %edi
  801492:	56                   	push   %esi
  801493:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801494:	ba 00 00 00 00       	mov    $0x0,%edx
  801499:	b8 01 00 00 00       	mov    $0x1,%eax
  80149e:	89 d1                	mov    %edx,%ecx
  8014a0:	89 d3                	mov    %edx,%ebx
  8014a2:	89 d7                	mov    %edx,%edi
  8014a4:	89 d6                	mov    %edx,%esi
  8014a6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014a8:	5b                   	pop    %ebx
  8014a9:	5e                   	pop    %esi
  8014aa:	5f                   	pop    %edi
  8014ab:	5d                   	pop    %ebp
  8014ac:	c3                   	ret    

008014ad <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	57                   	push   %edi
  8014b1:	56                   	push   %esi
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014bb:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c3:	89 cb                	mov    %ecx,%ebx
  8014c5:	89 cf                	mov    %ecx,%edi
  8014c7:	89 ce                	mov    %ecx,%esi
  8014c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	7e 17                	jle    8014e6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	50                   	push   %eax
  8014d3:	6a 03                	push   $0x3
  8014d5:	68 ef 36 80 00       	push   $0x8036ef
  8014da:	6a 23                	push   $0x23
  8014dc:	68 0c 37 80 00       	push   $0x80370c
  8014e1:	e8 f2 f4 ff ff       	call   8009d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8014e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e9:	5b                   	pop    %ebx
  8014ea:	5e                   	pop    %esi
  8014eb:	5f                   	pop    %edi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    

008014ee <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	57                   	push   %edi
  8014f2:	56                   	push   %esi
  8014f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014fe:	89 d1                	mov    %edx,%ecx
  801500:	89 d3                	mov    %edx,%ebx
  801502:	89 d7                	mov    %edx,%edi
  801504:	89 d6                	mov    %edx,%esi
  801506:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    

0080150d <sys_yield>:

void
sys_yield(void)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	57                   	push   %edi
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801513:	ba 00 00 00 00       	mov    $0x0,%edx
  801518:	b8 0b 00 00 00       	mov    $0xb,%eax
  80151d:	89 d1                	mov    %edx,%ecx
  80151f:	89 d3                	mov    %edx,%ebx
  801521:	89 d7                	mov    %edx,%edi
  801523:	89 d6                	mov    %edx,%esi
  801525:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5f                   	pop    %edi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	57                   	push   %edi
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
  801532:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801535:	be 00 00 00 00       	mov    $0x0,%esi
  80153a:	b8 04 00 00 00       	mov    $0x4,%eax
  80153f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801542:	8b 55 08             	mov    0x8(%ebp),%edx
  801545:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801548:	89 f7                	mov    %esi,%edi
  80154a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80154c:	85 c0                	test   %eax,%eax
  80154e:	7e 17                	jle    801567 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801550:	83 ec 0c             	sub    $0xc,%esp
  801553:	50                   	push   %eax
  801554:	6a 04                	push   $0x4
  801556:	68 ef 36 80 00       	push   $0x8036ef
  80155b:	6a 23                	push   $0x23
  80155d:	68 0c 37 80 00       	push   $0x80370c
  801562:	e8 71 f4 ff ff       	call   8009d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801567:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156a:	5b                   	pop    %ebx
  80156b:	5e                   	pop    %esi
  80156c:	5f                   	pop    %edi
  80156d:	5d                   	pop    %ebp
  80156e:	c3                   	ret    

0080156f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	57                   	push   %edi
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801578:	b8 05 00 00 00       	mov    $0x5,%eax
  80157d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801580:	8b 55 08             	mov    0x8(%ebp),%edx
  801583:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801586:	8b 7d 14             	mov    0x14(%ebp),%edi
  801589:	8b 75 18             	mov    0x18(%ebp),%esi
  80158c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80158e:	85 c0                	test   %eax,%eax
  801590:	7e 17                	jle    8015a9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801592:	83 ec 0c             	sub    $0xc,%esp
  801595:	50                   	push   %eax
  801596:	6a 05                	push   $0x5
  801598:	68 ef 36 80 00       	push   $0x8036ef
  80159d:	6a 23                	push   $0x23
  80159f:	68 0c 37 80 00       	push   $0x80370c
  8015a4:	e8 2f f4 ff ff       	call   8009d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5f                   	pop    %edi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    

008015b1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	57                   	push   %edi
  8015b5:	56                   	push   %esi
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8015c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ca:	89 df                	mov    %ebx,%edi
  8015cc:	89 de                	mov    %ebx,%esi
  8015ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	7e 17                	jle    8015eb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	50                   	push   %eax
  8015d8:	6a 06                	push   $0x6
  8015da:	68 ef 36 80 00       	push   $0x8036ef
  8015df:	6a 23                	push   $0x23
  8015e1:	68 0c 37 80 00       	push   $0x80370c
  8015e6:	e8 ed f3 ff ff       	call   8009d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8015eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5f                   	pop    %edi
  8015f1:	5d                   	pop    %ebp
  8015f2:	c3                   	ret    

008015f3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	57                   	push   %edi
  8015f7:	56                   	push   %esi
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801601:	b8 08 00 00 00       	mov    $0x8,%eax
  801606:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801609:	8b 55 08             	mov    0x8(%ebp),%edx
  80160c:	89 df                	mov    %ebx,%edi
  80160e:	89 de                	mov    %ebx,%esi
  801610:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801612:	85 c0                	test   %eax,%eax
  801614:	7e 17                	jle    80162d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801616:	83 ec 0c             	sub    $0xc,%esp
  801619:	50                   	push   %eax
  80161a:	6a 08                	push   $0x8
  80161c:	68 ef 36 80 00       	push   $0x8036ef
  801621:	6a 23                	push   $0x23
  801623:	68 0c 37 80 00       	push   $0x80370c
  801628:	e8 ab f3 ff ff       	call   8009d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80162d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801630:	5b                   	pop    %ebx
  801631:	5e                   	pop    %esi
  801632:	5f                   	pop    %edi
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	57                   	push   %edi
  801639:	56                   	push   %esi
  80163a:	53                   	push   %ebx
  80163b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80163e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801643:	b8 09 00 00 00       	mov    $0x9,%eax
  801648:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80164b:	8b 55 08             	mov    0x8(%ebp),%edx
  80164e:	89 df                	mov    %ebx,%edi
  801650:	89 de                	mov    %ebx,%esi
  801652:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801654:	85 c0                	test   %eax,%eax
  801656:	7e 17                	jle    80166f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801658:	83 ec 0c             	sub    $0xc,%esp
  80165b:	50                   	push   %eax
  80165c:	6a 09                	push   $0x9
  80165e:	68 ef 36 80 00       	push   $0x8036ef
  801663:	6a 23                	push   $0x23
  801665:	68 0c 37 80 00       	push   $0x80370c
  80166a:	e8 69 f3 ff ff       	call   8009d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80166f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5f                   	pop    %edi
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	57                   	push   %edi
  80167b:	56                   	push   %esi
  80167c:	53                   	push   %ebx
  80167d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801680:	bb 00 00 00 00       	mov    $0x0,%ebx
  801685:	b8 0a 00 00 00       	mov    $0xa,%eax
  80168a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80168d:	8b 55 08             	mov    0x8(%ebp),%edx
  801690:	89 df                	mov    %ebx,%edi
  801692:	89 de                	mov    %ebx,%esi
  801694:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801696:	85 c0                	test   %eax,%eax
  801698:	7e 17                	jle    8016b1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80169a:	83 ec 0c             	sub    $0xc,%esp
  80169d:	50                   	push   %eax
  80169e:	6a 0a                	push   $0xa
  8016a0:	68 ef 36 80 00       	push   $0x8036ef
  8016a5:	6a 23                	push   $0x23
  8016a7:	68 0c 37 80 00       	push   $0x80370c
  8016ac:	e8 27 f3 ff ff       	call   8009d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5e                   	pop    %esi
  8016b6:	5f                   	pop    %edi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	57                   	push   %edi
  8016bd:	56                   	push   %esi
  8016be:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016bf:	be 00 00 00 00       	mov    $0x0,%esi
  8016c4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8016c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8016d5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8016d7:	5b                   	pop    %ebx
  8016d8:	5e                   	pop    %esi
  8016d9:	5f                   	pop    %edi
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	57                   	push   %edi
  8016e0:	56                   	push   %esi
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016ea:	b8 0d 00 00 00       	mov    $0xd,%eax
  8016ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f2:	89 cb                	mov    %ecx,%ebx
  8016f4:	89 cf                	mov    %ecx,%edi
  8016f6:	89 ce                	mov    %ecx,%esi
  8016f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	7e 17                	jle    801715 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016fe:	83 ec 0c             	sub    $0xc,%esp
  801701:	50                   	push   %eax
  801702:	6a 0d                	push   $0xd
  801704:	68 ef 36 80 00       	push   $0x8036ef
  801709:	6a 23                	push   $0x23
  80170b:	68 0c 37 80 00       	push   $0x80370c
  801710:	e8 c3 f2 ff ff       	call   8009d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801715:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801718:	5b                   	pop    %ebx
  801719:	5e                   	pop    %esi
  80171a:	5f                   	pop    %edi
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	56                   	push   %esi
  801721:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	// Check if page is writable or COW
	pte_t pte = uvpt[pn];
  801722:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	uint32_t perm = PTE_P | PTE_U;
	if (pte && (PTE_COW | PTE_W)) {
		perm |= PTE_COW;
  801729:	83 f9 01             	cmp    $0x1,%ecx
  80172c:	19 f6                	sbb    %esi,%esi
  80172e:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  801734:	81 c6 05 08 00 00    	add    $0x805,%esi
	}

	// Map page
	void *va = (void *) (pn * PGSIZE);
  80173a:	c1 e2 0c             	shl    $0xc,%edx
  80173d:	89 d3                	mov    %edx,%ebx
	// Map on the child
	if ((r = sys_page_map(0, va, envid, va, perm)) < 0) {
  80173f:	83 ec 0c             	sub    $0xc,%esp
  801742:	56                   	push   %esi
  801743:	52                   	push   %edx
  801744:	50                   	push   %eax
  801745:	52                   	push   %edx
  801746:	6a 00                	push   $0x0
  801748:	e8 22 fe ff ff       	call   80156f <sys_page_map>
  80174d:	83 c4 20             	add    $0x20,%esp
  801750:	85 c0                	test   %eax,%eax
  801752:	79 12                	jns    801766 <duppage+0x49>
		panic("sys_page_alloc: %e", r);
  801754:	50                   	push   %eax
  801755:	68 1a 37 80 00       	push   $0x80371a
  80175a:	6a 56                	push   $0x56
  80175c:	68 2d 37 80 00       	push   $0x80372d
  801761:	e8 72 f2 ff ff       	call   8009d8 <_panic>
		return r;
	}

	// Change the permission on the parent
	if ((r = sys_page_map(0, va, 0, va, perm)) < 0) {
  801766:	83 ec 0c             	sub    $0xc,%esp
  801769:	56                   	push   %esi
  80176a:	53                   	push   %ebx
  80176b:	6a 00                	push   $0x0
  80176d:	53                   	push   %ebx
  80176e:	6a 00                	push   $0x0
  801770:	e8 fa fd ff ff       	call   80156f <sys_page_map>
  801775:	83 c4 20             	add    $0x20,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	79 12                	jns    80178e <duppage+0x71>
		panic("sys_page_alloc: %e", r);
  80177c:	50                   	push   %eax
  80177d:	68 1a 37 80 00       	push   $0x80371a
  801782:	6a 5c                	push   $0x5c
  801784:	68 2d 37 80 00       	push   $0x80372d
  801789:	e8 4a f2 ff ff       	call   8009d8 <_panic>
		return r;
	}

	return 0;
}
  80178e:	b8 00 00 00 00       	mov    $0x0,%eax
  801793:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801796:	5b                   	pop    %ebx
  801797:	5e                   	pop    %esi
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	53                   	push   %ebx
  80179e:	83 ec 04             	sub    $0x4,%esp
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8017a4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  8017a6:	89 da                	mov    %ebx,%edx
  8017a8:	c1 ea 0c             	shr    $0xc,%edx
	pte_t pte = uvpt[pn];
  8017ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(err & FEC_WR) || !(pte & PTE_COW)) {
  8017b2:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8017b6:	74 05                	je     8017bd <pgfault+0x23>
  8017b8:	f6 c6 08             	test   $0x8,%dh
  8017bb:	75 14                	jne    8017d1 <pgfault+0x37>
		panic("fork pgfault handler: does not handle this fault");
  8017bd:	83 ec 04             	sub    $0x4,%esp
  8017c0:	68 9c 37 80 00       	push   $0x80379c
  8017c5:	6a 1f                	push   $0x1f
  8017c7:	68 2d 37 80 00       	push   $0x80372d
  8017cc:	e8 07 f2 ff ff       	call   8009d8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  8017d1:	83 ec 04             	sub    $0x4,%esp
  8017d4:	6a 07                	push   $0x7
  8017d6:	68 00 f0 7f 00       	push   $0x7ff000
  8017db:	6a 00                	push   $0x0
  8017dd:	e8 4a fd ff ff       	call   80152c <sys_page_alloc>
  8017e2:	83 c4 10             	add    $0x10,%esp
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	79 12                	jns    8017fb <pgfault+0x61>
		panic("sys_page_alloc: %e", r);
  8017e9:	50                   	push   %eax
  8017ea:	68 1a 37 80 00       	push   $0x80371a
  8017ef:	6a 2b                	push   $0x2b
  8017f1:	68 2d 37 80 00       	push   $0x80372d
  8017f6:	e8 dd f1 ff ff       	call   8009d8 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  8017fb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  801801:	83 ec 04             	sub    $0x4,%esp
  801804:	68 00 10 00 00       	push   $0x1000
  801809:	53                   	push   %ebx
  80180a:	68 00 f0 7f 00       	push   $0x7ff000
  80180f:	e8 a7 fa ff ff       	call   8012bb <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  801814:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80181b:	53                   	push   %ebx
  80181c:	6a 00                	push   $0x0
  80181e:	68 00 f0 7f 00       	push   $0x7ff000
  801823:	6a 00                	push   $0x0
  801825:	e8 45 fd ff ff       	call   80156f <sys_page_map>
  80182a:	83 c4 20             	add    $0x20,%esp
  80182d:	85 c0                	test   %eax,%eax
  80182f:	79 12                	jns    801843 <pgfault+0xa9>
		panic("sys_page_map: %e", r);
  801831:	50                   	push   %eax
  801832:	68 38 37 80 00       	push   $0x803738
  801837:	6a 33                	push   $0x33
  801839:	68 2d 37 80 00       	push   $0x80372d
  80183e:	e8 95 f1 ff ff       	call   8009d8 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801843:	83 ec 08             	sub    $0x8,%esp
  801846:	68 00 f0 7f 00       	push   $0x7ff000
  80184b:	6a 00                	push   $0x0
  80184d:	e8 5f fd ff ff       	call   8015b1 <sys_page_unmap>
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	85 c0                	test   %eax,%eax
  801857:	79 12                	jns    80186b <pgfault+0xd1>
		panic("sys_page_unmap: %e", r);
  801859:	50                   	push   %eax
  80185a:	68 49 37 80 00       	push   $0x803749
  80185f:	6a 37                	push   $0x37
  801861:	68 2d 37 80 00       	push   $0x80372d
  801866:	e8 6d f1 ff ff       	call   8009d8 <_panic>
}
  80186b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	56                   	push   %esi
  801874:	53                   	push   %ebx
  801875:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801878:	68 9a 17 80 00       	push   $0x80179a
  80187d:	e8 da 14 00 00       	call   802d5c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801882:	b8 07 00 00 00       	mov    $0x7,%eax
  801887:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801889:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	85 c0                	test   %eax,%eax
  801891:	79 12                	jns    8018a5 <fork+0x35>
		panic("sys_exofork: %e", envid);
  801893:	50                   	push   %eax
  801894:	68 5c 37 80 00       	push   $0x80375c
  801899:	6a 7d                	push   $0x7d
  80189b:	68 2d 37 80 00       	push   $0x80372d
  8018a0:	e8 33 f1 ff ff       	call   8009d8 <_panic>
		return envid;
	}
	if (envid == 0) {
  8018a5:	85 c0                	test   %eax,%eax
  8018a7:	75 1e                	jne    8018c7 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  8018a9:	e8 40 fc ff ff       	call   8014ee <sys_getenvid>
  8018ae:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018b3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8018b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018bb:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  8018c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c5:	eb 7d                	jmp    801944 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	6a 07                	push   $0x7
  8018cc:	68 00 f0 bf ee       	push   $0xeebff000
  8018d1:	50                   	push   %eax
  8018d2:	e8 55 fc ff ff       	call   80152c <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  8018d7:	83 c4 08             	add    $0x8,%esp
  8018da:	68 a1 2d 80 00       	push   $0x802da1
  8018df:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e2:	e8 90 fd ff ff       	call   801677 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8018e7:	be 04 70 80 00       	mov    $0x807004,%esi
  8018ec:	c1 ee 0c             	shr    $0xc,%esi
  8018ef:	83 c4 10             	add    $0x10,%esp
  8018f2:	bb 00 08 00 00       	mov    $0x800,%ebx
  8018f7:	eb 0d                	jmp    801906 <fork+0x96>
		duppage(envid, pn);
  8018f9:	89 da                	mov    %ebx,%edx
  8018fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fe:	e8 1a fe ff ff       	call   80171d <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801903:	83 c3 01             	add    $0x1,%ebx
  801906:	39 f3                	cmp    %esi,%ebx
  801908:	76 ef                	jbe    8018f9 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  80190a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80190d:	c1 ea 0c             	shr    $0xc,%edx
  801910:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801913:	e8 05 fe ff ff       	call   80171d <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801918:	83 ec 08             	sub    $0x8,%esp
  80191b:	6a 02                	push   $0x2
  80191d:	ff 75 f4             	pushl  -0xc(%ebp)
  801920:	e8 ce fc ff ff       	call   8015f3 <sys_env_set_status>
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	85 c0                	test   %eax,%eax
  80192a:	79 15                	jns    801941 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  80192c:	50                   	push   %eax
  80192d:	68 6c 37 80 00       	push   $0x80376c
  801932:	68 9d 00 00 00       	push   $0x9d
  801937:	68 2d 37 80 00       	push   $0x80372d
  80193c:	e8 97 f0 ff ff       	call   8009d8 <_panic>
		return r;
	}

	return envid;
  801941:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801944:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801947:	5b                   	pop    %ebx
  801948:	5e                   	pop    %esi
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <sfork>:

// Challenge!
int
sfork(void)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801951:	68 83 37 80 00       	push   $0x803783
  801956:	68 a8 00 00 00       	push   $0xa8
  80195b:	68 2d 37 80 00       	push   $0x80372d
  801960:	e8 73 f0 ff ff       	call   8009d8 <_panic>

00801965 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	8b 55 08             	mov    0x8(%ebp),%edx
  80196b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80196e:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801971:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801973:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801976:	83 3a 01             	cmpl   $0x1,(%edx)
  801979:	7e 09                	jle    801984 <argstart+0x1f>
  80197b:	ba c1 31 80 00       	mov    $0x8031c1,%edx
  801980:	85 c9                	test   %ecx,%ecx
  801982:	75 05                	jne    801989 <argstart+0x24>
  801984:	ba 00 00 00 00       	mov    $0x0,%edx
  801989:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  80198c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801993:	5d                   	pop    %ebp
  801994:	c3                   	ret    

00801995 <argnext>:

int
argnext(struct Argstate *args)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	53                   	push   %ebx
  801999:	83 ec 04             	sub    $0x4,%esp
  80199c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  80199f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  8019a6:	8b 43 08             	mov    0x8(%ebx),%eax
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	74 6f                	je     801a1c <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  8019ad:	80 38 00             	cmpb   $0x0,(%eax)
  8019b0:	75 4e                	jne    801a00 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  8019b2:	8b 0b                	mov    (%ebx),%ecx
  8019b4:	83 39 01             	cmpl   $0x1,(%ecx)
  8019b7:	74 55                	je     801a0e <argnext+0x79>
		    || args->argv[1][0] != '-'
  8019b9:	8b 53 04             	mov    0x4(%ebx),%edx
  8019bc:	8b 42 04             	mov    0x4(%edx),%eax
  8019bf:	80 38 2d             	cmpb   $0x2d,(%eax)
  8019c2:	75 4a                	jne    801a0e <argnext+0x79>
		    || args->argv[1][1] == '\0')
  8019c4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8019c8:	74 44                	je     801a0e <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  8019ca:	83 c0 01             	add    $0x1,%eax
  8019cd:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8019d0:	83 ec 04             	sub    $0x4,%esp
  8019d3:	8b 01                	mov    (%ecx),%eax
  8019d5:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8019dc:	50                   	push   %eax
  8019dd:	8d 42 08             	lea    0x8(%edx),%eax
  8019e0:	50                   	push   %eax
  8019e1:	83 c2 04             	add    $0x4,%edx
  8019e4:	52                   	push   %edx
  8019e5:	e8 d1 f8 ff ff       	call   8012bb <memmove>
		(*args->argc)--;
  8019ea:	8b 03                	mov    (%ebx),%eax
  8019ec:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8019ef:	8b 43 08             	mov    0x8(%ebx),%eax
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	80 38 2d             	cmpb   $0x2d,(%eax)
  8019f8:	75 06                	jne    801a00 <argnext+0x6b>
  8019fa:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8019fe:	74 0e                	je     801a0e <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801a00:	8b 53 08             	mov    0x8(%ebx),%edx
  801a03:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801a06:	83 c2 01             	add    $0x1,%edx
  801a09:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801a0c:	eb 13                	jmp    801a21 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801a0e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801a15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801a1a:	eb 05                	jmp    801a21 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801a1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801a30:	8b 43 08             	mov    0x8(%ebx),%eax
  801a33:	85 c0                	test   %eax,%eax
  801a35:	74 58                	je     801a8f <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801a37:	80 38 00             	cmpb   $0x0,(%eax)
  801a3a:	74 0c                	je     801a48 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801a3c:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801a3f:	c7 43 08 c1 31 80 00 	movl   $0x8031c1,0x8(%ebx)
  801a46:	eb 42                	jmp    801a8a <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801a48:	8b 13                	mov    (%ebx),%edx
  801a4a:	83 3a 01             	cmpl   $0x1,(%edx)
  801a4d:	7e 2d                	jle    801a7c <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801a4f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a52:	8b 48 04             	mov    0x4(%eax),%ecx
  801a55:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801a58:	83 ec 04             	sub    $0x4,%esp
  801a5b:	8b 12                	mov    (%edx),%edx
  801a5d:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801a64:	52                   	push   %edx
  801a65:	8d 50 08             	lea    0x8(%eax),%edx
  801a68:	52                   	push   %edx
  801a69:	83 c0 04             	add    $0x4,%eax
  801a6c:	50                   	push   %eax
  801a6d:	e8 49 f8 ff ff       	call   8012bb <memmove>
		(*args->argc)--;
  801a72:	8b 03                	mov    (%ebx),%eax
  801a74:	83 28 01             	subl   $0x1,(%eax)
  801a77:	83 c4 10             	add    $0x10,%esp
  801a7a:	eb 0e                	jmp    801a8a <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801a7c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801a83:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801a8a:	8b 43 0c             	mov    0xc(%ebx),%eax
  801a8d:	eb 05                	jmp    801a94 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801a8f:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801a94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a97:	c9                   	leave  
  801a98:	c3                   	ret    

00801a99 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	83 ec 08             	sub    $0x8,%esp
  801a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801aa2:	8b 51 0c             	mov    0xc(%ecx),%edx
  801aa5:	89 d0                	mov    %edx,%eax
  801aa7:	85 d2                	test   %edx,%edx
  801aa9:	75 0c                	jne    801ab7 <argvalue+0x1e>
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	51                   	push   %ecx
  801aaf:	e8 72 ff ff ff       	call   801a26 <argnextvalue>
  801ab4:	83 c4 10             	add    $0x10,%esp
}
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801abc:	8b 45 08             	mov    0x8(%ebp),%eax
  801abf:	05 00 00 00 30       	add    $0x30000000,%eax
  801ac4:	c1 e8 0c             	shr    $0xc,%eax
}
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801acc:	8b 45 08             	mov    0x8(%ebp),%eax
  801acf:	05 00 00 00 30       	add    $0x30000000,%eax
  801ad4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801ad9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ae6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801aeb:	89 c2                	mov    %eax,%edx
  801aed:	c1 ea 16             	shr    $0x16,%edx
  801af0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801af7:	f6 c2 01             	test   $0x1,%dl
  801afa:	74 11                	je     801b0d <fd_alloc+0x2d>
  801afc:	89 c2                	mov    %eax,%edx
  801afe:	c1 ea 0c             	shr    $0xc,%edx
  801b01:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b08:	f6 c2 01             	test   $0x1,%dl
  801b0b:	75 09                	jne    801b16 <fd_alloc+0x36>
			*fd_store = fd;
  801b0d:	89 01                	mov    %eax,(%ecx)
			return 0;
  801b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b14:	eb 17                	jmp    801b2d <fd_alloc+0x4d>
  801b16:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801b1b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801b20:	75 c9                	jne    801aeb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801b22:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801b28:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801b35:	83 f8 1f             	cmp    $0x1f,%eax
  801b38:	77 36                	ja     801b70 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801b3a:	c1 e0 0c             	shl    $0xc,%eax
  801b3d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801b42:	89 c2                	mov    %eax,%edx
  801b44:	c1 ea 16             	shr    $0x16,%edx
  801b47:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b4e:	f6 c2 01             	test   $0x1,%dl
  801b51:	74 24                	je     801b77 <fd_lookup+0x48>
  801b53:	89 c2                	mov    %eax,%edx
  801b55:	c1 ea 0c             	shr    $0xc,%edx
  801b58:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b5f:	f6 c2 01             	test   $0x1,%dl
  801b62:	74 1a                	je     801b7e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801b64:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b67:	89 02                	mov    %eax,(%edx)
	return 0;
  801b69:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6e:	eb 13                	jmp    801b83 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801b70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b75:	eb 0c                	jmp    801b83 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801b77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b7c:	eb 05                	jmp    801b83 <fd_lookup+0x54>
  801b7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801b83:	5d                   	pop    %ebp
  801b84:	c3                   	ret    

00801b85 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	83 ec 08             	sub    $0x8,%esp
  801b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b8e:	ba 4c 38 80 00       	mov    $0x80384c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801b93:	eb 13                	jmp    801ba8 <dev_lookup+0x23>
  801b95:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801b98:	39 08                	cmp    %ecx,(%eax)
  801b9a:	75 0c                	jne    801ba8 <dev_lookup+0x23>
			*dev = devtab[i];
  801b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba6:	eb 2e                	jmp    801bd6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ba8:	8b 02                	mov    (%edx),%eax
  801baa:	85 c0                	test   %eax,%eax
  801bac:	75 e7                	jne    801b95 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801bae:	a1 24 54 80 00       	mov    0x805424,%eax
  801bb3:	8b 40 48             	mov    0x48(%eax),%eax
  801bb6:	83 ec 04             	sub    $0x4,%esp
  801bb9:	51                   	push   %ecx
  801bba:	50                   	push   %eax
  801bbb:	68 d0 37 80 00       	push   $0x8037d0
  801bc0:	e8 ec ee ff ff       	call   800ab1 <cprintf>
	*dev = 0;
  801bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801bd6:	c9                   	leave  
  801bd7:	c3                   	ret    

00801bd8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	83 ec 10             	sub    $0x10,%esp
  801be0:	8b 75 08             	mov    0x8(%ebp),%esi
  801be3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801be6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be9:	50                   	push   %eax
  801bea:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801bf0:	c1 e8 0c             	shr    $0xc,%eax
  801bf3:	50                   	push   %eax
  801bf4:	e8 36 ff ff ff       	call   801b2f <fd_lookup>
  801bf9:	83 c4 08             	add    $0x8,%esp
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	78 05                	js     801c05 <fd_close+0x2d>
	    || fd != fd2)
  801c00:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801c03:	74 0c                	je     801c11 <fd_close+0x39>
		return (must_exist ? r : 0);
  801c05:	84 db                	test   %bl,%bl
  801c07:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0c:	0f 44 c2             	cmove  %edx,%eax
  801c0f:	eb 41                	jmp    801c52 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801c11:	83 ec 08             	sub    $0x8,%esp
  801c14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c17:	50                   	push   %eax
  801c18:	ff 36                	pushl  (%esi)
  801c1a:	e8 66 ff ff ff       	call   801b85 <dev_lookup>
  801c1f:	89 c3                	mov    %eax,%ebx
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	85 c0                	test   %eax,%eax
  801c26:	78 1a                	js     801c42 <fd_close+0x6a>
		if (dev->dev_close)
  801c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801c33:	85 c0                	test   %eax,%eax
  801c35:	74 0b                	je     801c42 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801c37:	83 ec 0c             	sub    $0xc,%esp
  801c3a:	56                   	push   %esi
  801c3b:	ff d0                	call   *%eax
  801c3d:	89 c3                	mov    %eax,%ebx
  801c3f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801c42:	83 ec 08             	sub    $0x8,%esp
  801c45:	56                   	push   %esi
  801c46:	6a 00                	push   $0x0
  801c48:	e8 64 f9 ff ff       	call   8015b1 <sys_page_unmap>
	return r;
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	89 d8                	mov    %ebx,%eax
}
  801c52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c55:	5b                   	pop    %ebx
  801c56:	5e                   	pop    %esi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c62:	50                   	push   %eax
  801c63:	ff 75 08             	pushl  0x8(%ebp)
  801c66:	e8 c4 fe ff ff       	call   801b2f <fd_lookup>
  801c6b:	83 c4 08             	add    $0x8,%esp
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	78 10                	js     801c82 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801c72:	83 ec 08             	sub    $0x8,%esp
  801c75:	6a 01                	push   $0x1
  801c77:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7a:	e8 59 ff ff ff       	call   801bd8 <fd_close>
  801c7f:	83 c4 10             	add    $0x10,%esp
}
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <close_all>:

void
close_all(void)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	53                   	push   %ebx
  801c88:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801c90:	83 ec 0c             	sub    $0xc,%esp
  801c93:	53                   	push   %ebx
  801c94:	e8 c0 ff ff ff       	call   801c59 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801c99:	83 c3 01             	add    $0x1,%ebx
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	83 fb 20             	cmp    $0x20,%ebx
  801ca2:	75 ec                	jne    801c90 <close_all+0xc>
		close(i);
}
  801ca4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    

00801ca9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	57                   	push   %edi
  801cad:	56                   	push   %esi
  801cae:	53                   	push   %ebx
  801caf:	83 ec 2c             	sub    $0x2c,%esp
  801cb2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801cb5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801cb8:	50                   	push   %eax
  801cb9:	ff 75 08             	pushl  0x8(%ebp)
  801cbc:	e8 6e fe ff ff       	call   801b2f <fd_lookup>
  801cc1:	83 c4 08             	add    $0x8,%esp
  801cc4:	85 c0                	test   %eax,%eax
  801cc6:	0f 88 c1 00 00 00    	js     801d8d <dup+0xe4>
		return r;
	close(newfdnum);
  801ccc:	83 ec 0c             	sub    $0xc,%esp
  801ccf:	56                   	push   %esi
  801cd0:	e8 84 ff ff ff       	call   801c59 <close>

	newfd = INDEX2FD(newfdnum);
  801cd5:	89 f3                	mov    %esi,%ebx
  801cd7:	c1 e3 0c             	shl    $0xc,%ebx
  801cda:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801ce0:	83 c4 04             	add    $0x4,%esp
  801ce3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ce6:	e8 de fd ff ff       	call   801ac9 <fd2data>
  801ceb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801ced:	89 1c 24             	mov    %ebx,(%esp)
  801cf0:	e8 d4 fd ff ff       	call   801ac9 <fd2data>
  801cf5:	83 c4 10             	add    $0x10,%esp
  801cf8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801cfb:	89 f8                	mov    %edi,%eax
  801cfd:	c1 e8 16             	shr    $0x16,%eax
  801d00:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d07:	a8 01                	test   $0x1,%al
  801d09:	74 37                	je     801d42 <dup+0x99>
  801d0b:	89 f8                	mov    %edi,%eax
  801d0d:	c1 e8 0c             	shr    $0xc,%eax
  801d10:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801d17:	f6 c2 01             	test   $0x1,%dl
  801d1a:	74 26                	je     801d42 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801d1c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d23:	83 ec 0c             	sub    $0xc,%esp
  801d26:	25 07 0e 00 00       	and    $0xe07,%eax
  801d2b:	50                   	push   %eax
  801d2c:	ff 75 d4             	pushl  -0x2c(%ebp)
  801d2f:	6a 00                	push   $0x0
  801d31:	57                   	push   %edi
  801d32:	6a 00                	push   $0x0
  801d34:	e8 36 f8 ff ff       	call   80156f <sys_page_map>
  801d39:	89 c7                	mov    %eax,%edi
  801d3b:	83 c4 20             	add    $0x20,%esp
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 2e                	js     801d70 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801d42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801d45:	89 d0                	mov    %edx,%eax
  801d47:	c1 e8 0c             	shr    $0xc,%eax
  801d4a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d51:	83 ec 0c             	sub    $0xc,%esp
  801d54:	25 07 0e 00 00       	and    $0xe07,%eax
  801d59:	50                   	push   %eax
  801d5a:	53                   	push   %ebx
  801d5b:	6a 00                	push   $0x0
  801d5d:	52                   	push   %edx
  801d5e:	6a 00                	push   $0x0
  801d60:	e8 0a f8 ff ff       	call   80156f <sys_page_map>
  801d65:	89 c7                	mov    %eax,%edi
  801d67:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801d6a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801d6c:	85 ff                	test   %edi,%edi
  801d6e:	79 1d                	jns    801d8d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d70:	83 ec 08             	sub    $0x8,%esp
  801d73:	53                   	push   %ebx
  801d74:	6a 00                	push   $0x0
  801d76:	e8 36 f8 ff ff       	call   8015b1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d7b:	83 c4 08             	add    $0x8,%esp
  801d7e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801d81:	6a 00                	push   $0x0
  801d83:	e8 29 f8 ff ff       	call   8015b1 <sys_page_unmap>
	return r;
  801d88:	83 c4 10             	add    $0x10,%esp
  801d8b:	89 f8                	mov    %edi,%eax
}
  801d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	53                   	push   %ebx
  801d99:	83 ec 14             	sub    $0x14,%esp
  801d9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801da2:	50                   	push   %eax
  801da3:	53                   	push   %ebx
  801da4:	e8 86 fd ff ff       	call   801b2f <fd_lookup>
  801da9:	83 c4 08             	add    $0x8,%esp
  801dac:	89 c2                	mov    %eax,%edx
  801dae:	85 c0                	test   %eax,%eax
  801db0:	78 6d                	js     801e1f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801db2:	83 ec 08             	sub    $0x8,%esp
  801db5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db8:	50                   	push   %eax
  801db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dbc:	ff 30                	pushl  (%eax)
  801dbe:	e8 c2 fd ff ff       	call   801b85 <dev_lookup>
  801dc3:	83 c4 10             	add    $0x10,%esp
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	78 4c                	js     801e16 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801dca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dcd:	8b 42 08             	mov    0x8(%edx),%eax
  801dd0:	83 e0 03             	and    $0x3,%eax
  801dd3:	83 f8 01             	cmp    $0x1,%eax
  801dd6:	75 21                	jne    801df9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801dd8:	a1 24 54 80 00       	mov    0x805424,%eax
  801ddd:	8b 40 48             	mov    0x48(%eax),%eax
  801de0:	83 ec 04             	sub    $0x4,%esp
  801de3:	53                   	push   %ebx
  801de4:	50                   	push   %eax
  801de5:	68 11 38 80 00       	push   $0x803811
  801dea:	e8 c2 ec ff ff       	call   800ab1 <cprintf>
		return -E_INVAL;
  801def:	83 c4 10             	add    $0x10,%esp
  801df2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801df7:	eb 26                	jmp    801e1f <read+0x8a>
	}
	if (!dev->dev_read)
  801df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfc:	8b 40 08             	mov    0x8(%eax),%eax
  801dff:	85 c0                	test   %eax,%eax
  801e01:	74 17                	je     801e1a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801e03:	83 ec 04             	sub    $0x4,%esp
  801e06:	ff 75 10             	pushl  0x10(%ebp)
  801e09:	ff 75 0c             	pushl  0xc(%ebp)
  801e0c:	52                   	push   %edx
  801e0d:	ff d0                	call   *%eax
  801e0f:	89 c2                	mov    %eax,%edx
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	eb 09                	jmp    801e1f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e16:	89 c2                	mov    %eax,%edx
  801e18:	eb 05                	jmp    801e1f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801e1a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801e1f:	89 d0                	mov    %edx,%eax
  801e21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e24:	c9                   	leave  
  801e25:	c3                   	ret    

00801e26 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	57                   	push   %edi
  801e2a:	56                   	push   %esi
  801e2b:	53                   	push   %ebx
  801e2c:	83 ec 0c             	sub    $0xc,%esp
  801e2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e32:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e35:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e3a:	eb 21                	jmp    801e5d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801e3c:	83 ec 04             	sub    $0x4,%esp
  801e3f:	89 f0                	mov    %esi,%eax
  801e41:	29 d8                	sub    %ebx,%eax
  801e43:	50                   	push   %eax
  801e44:	89 d8                	mov    %ebx,%eax
  801e46:	03 45 0c             	add    0xc(%ebp),%eax
  801e49:	50                   	push   %eax
  801e4a:	57                   	push   %edi
  801e4b:	e8 45 ff ff ff       	call   801d95 <read>
		if (m < 0)
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	85 c0                	test   %eax,%eax
  801e55:	78 10                	js     801e67 <readn+0x41>
			return m;
		if (m == 0)
  801e57:	85 c0                	test   %eax,%eax
  801e59:	74 0a                	je     801e65 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801e5b:	01 c3                	add    %eax,%ebx
  801e5d:	39 f3                	cmp    %esi,%ebx
  801e5f:	72 db                	jb     801e3c <readn+0x16>
  801e61:	89 d8                	mov    %ebx,%eax
  801e63:	eb 02                	jmp    801e67 <readn+0x41>
  801e65:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e6a:	5b                   	pop    %ebx
  801e6b:	5e                   	pop    %esi
  801e6c:	5f                   	pop    %edi
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    

00801e6f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	53                   	push   %ebx
  801e73:	83 ec 14             	sub    $0x14,%esp
  801e76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e7c:	50                   	push   %eax
  801e7d:	53                   	push   %ebx
  801e7e:	e8 ac fc ff ff       	call   801b2f <fd_lookup>
  801e83:	83 c4 08             	add    $0x8,%esp
  801e86:	89 c2                	mov    %eax,%edx
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	78 68                	js     801ef4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e8c:	83 ec 08             	sub    $0x8,%esp
  801e8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e92:	50                   	push   %eax
  801e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e96:	ff 30                	pushl  (%eax)
  801e98:	e8 e8 fc ff ff       	call   801b85 <dev_lookup>
  801e9d:	83 c4 10             	add    $0x10,%esp
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	78 47                	js     801eeb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801eab:	75 21                	jne    801ece <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ead:	a1 24 54 80 00       	mov    0x805424,%eax
  801eb2:	8b 40 48             	mov    0x48(%eax),%eax
  801eb5:	83 ec 04             	sub    $0x4,%esp
  801eb8:	53                   	push   %ebx
  801eb9:	50                   	push   %eax
  801eba:	68 2d 38 80 00       	push   $0x80382d
  801ebf:	e8 ed eb ff ff       	call   800ab1 <cprintf>
		return -E_INVAL;
  801ec4:	83 c4 10             	add    $0x10,%esp
  801ec7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ecc:	eb 26                	jmp    801ef4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ece:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ed1:	8b 52 0c             	mov    0xc(%edx),%edx
  801ed4:	85 d2                	test   %edx,%edx
  801ed6:	74 17                	je     801eef <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801ed8:	83 ec 04             	sub    $0x4,%esp
  801edb:	ff 75 10             	pushl  0x10(%ebp)
  801ede:	ff 75 0c             	pushl  0xc(%ebp)
  801ee1:	50                   	push   %eax
  801ee2:	ff d2                	call   *%edx
  801ee4:	89 c2                	mov    %eax,%edx
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	eb 09                	jmp    801ef4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801eeb:	89 c2                	mov    %eax,%edx
  801eed:	eb 05                	jmp    801ef4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801eef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801ef4:	89 d0                	mov    %edx,%eax
  801ef6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef9:	c9                   	leave  
  801efa:	c3                   	ret    

00801efb <seek>:

int
seek(int fdnum, off_t offset)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f01:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801f04:	50                   	push   %eax
  801f05:	ff 75 08             	pushl  0x8(%ebp)
  801f08:	e8 22 fc ff ff       	call   801b2f <fd_lookup>
  801f0d:	83 c4 08             	add    $0x8,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 0e                	js     801f22 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801f14:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801f17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f1a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801f1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f22:	c9                   	leave  
  801f23:	c3                   	ret    

00801f24 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	53                   	push   %ebx
  801f28:	83 ec 14             	sub    $0x14,%esp
  801f2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f31:	50                   	push   %eax
  801f32:	53                   	push   %ebx
  801f33:	e8 f7 fb ff ff       	call   801b2f <fd_lookup>
  801f38:	83 c4 08             	add    $0x8,%esp
  801f3b:	89 c2                	mov    %eax,%edx
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 65                	js     801fa6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f41:	83 ec 08             	sub    $0x8,%esp
  801f44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f47:	50                   	push   %eax
  801f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f4b:	ff 30                	pushl  (%eax)
  801f4d:	e8 33 fc ff ff       	call   801b85 <dev_lookup>
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 44                	js     801f9d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f5c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801f60:	75 21                	jne    801f83 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801f62:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801f67:	8b 40 48             	mov    0x48(%eax),%eax
  801f6a:	83 ec 04             	sub    $0x4,%esp
  801f6d:	53                   	push   %ebx
  801f6e:	50                   	push   %eax
  801f6f:	68 f0 37 80 00       	push   $0x8037f0
  801f74:	e8 38 eb ff ff       	call   800ab1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f81:	eb 23                	jmp    801fa6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801f83:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f86:	8b 52 18             	mov    0x18(%edx),%edx
  801f89:	85 d2                	test   %edx,%edx
  801f8b:	74 14                	je     801fa1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801f8d:	83 ec 08             	sub    $0x8,%esp
  801f90:	ff 75 0c             	pushl  0xc(%ebp)
  801f93:	50                   	push   %eax
  801f94:	ff d2                	call   *%edx
  801f96:	89 c2                	mov    %eax,%edx
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	eb 09                	jmp    801fa6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f9d:	89 c2                	mov    %eax,%edx
  801f9f:	eb 05                	jmp    801fa6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801fa1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801fa6:	89 d0                	mov    %edx,%eax
  801fa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fab:	c9                   	leave  
  801fac:	c3                   	ret    

00801fad <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801fad:	55                   	push   %ebp
  801fae:	89 e5                	mov    %esp,%ebp
  801fb0:	53                   	push   %ebx
  801fb1:	83 ec 14             	sub    $0x14,%esp
  801fb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fb7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fba:	50                   	push   %eax
  801fbb:	ff 75 08             	pushl  0x8(%ebp)
  801fbe:	e8 6c fb ff ff       	call   801b2f <fd_lookup>
  801fc3:	83 c4 08             	add    $0x8,%esp
  801fc6:	89 c2                	mov    %eax,%edx
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	78 58                	js     802024 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fcc:	83 ec 08             	sub    $0x8,%esp
  801fcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd2:	50                   	push   %eax
  801fd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fd6:	ff 30                	pushl  (%eax)
  801fd8:	e8 a8 fb ff ff       	call   801b85 <dev_lookup>
  801fdd:	83 c4 10             	add    $0x10,%esp
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	78 37                	js     80201b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801feb:	74 32                	je     80201f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801fed:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ff0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801ff7:	00 00 00 
	stat->st_isdir = 0;
  801ffa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802001:	00 00 00 
	stat->st_dev = dev;
  802004:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80200a:	83 ec 08             	sub    $0x8,%esp
  80200d:	53                   	push   %ebx
  80200e:	ff 75 f0             	pushl  -0x10(%ebp)
  802011:	ff 50 14             	call   *0x14(%eax)
  802014:	89 c2                	mov    %eax,%edx
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	eb 09                	jmp    802024 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80201b:	89 c2                	mov    %eax,%edx
  80201d:	eb 05                	jmp    802024 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80201f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802024:	89 d0                	mov    %edx,%eax
  802026:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802029:	c9                   	leave  
  80202a:	c3                   	ret    

0080202b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80202b:	55                   	push   %ebp
  80202c:	89 e5                	mov    %esp,%ebp
  80202e:	56                   	push   %esi
  80202f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802030:	83 ec 08             	sub    $0x8,%esp
  802033:	6a 00                	push   $0x0
  802035:	ff 75 08             	pushl  0x8(%ebp)
  802038:	e8 0c 02 00 00       	call   802249 <open>
  80203d:	89 c3                	mov    %eax,%ebx
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	85 c0                	test   %eax,%eax
  802044:	78 1b                	js     802061 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802046:	83 ec 08             	sub    $0x8,%esp
  802049:	ff 75 0c             	pushl  0xc(%ebp)
  80204c:	50                   	push   %eax
  80204d:	e8 5b ff ff ff       	call   801fad <fstat>
  802052:	89 c6                	mov    %eax,%esi
	close(fd);
  802054:	89 1c 24             	mov    %ebx,(%esp)
  802057:	e8 fd fb ff ff       	call   801c59 <close>
	return r;
  80205c:	83 c4 10             	add    $0x10,%esp
  80205f:	89 f0                	mov    %esi,%eax
}
  802061:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802064:	5b                   	pop    %ebx
  802065:	5e                   	pop    %esi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    

00802068 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802068:	55                   	push   %ebp
  802069:	89 e5                	mov    %esp,%ebp
  80206b:	56                   	push   %esi
  80206c:	53                   	push   %ebx
  80206d:	89 c6                	mov    %eax,%esi
  80206f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802071:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802078:	75 12                	jne    80208c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80207a:	83 ec 0c             	sub    $0xc,%esp
  80207d:	6a 01                	push   $0x1
  80207f:	e8 0b 0e 00 00       	call   802e8f <ipc_find_env>
  802084:	a3 20 54 80 00       	mov    %eax,0x805420
  802089:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80208c:	6a 07                	push   $0x7
  80208e:	68 00 60 80 00       	push   $0x806000
  802093:	56                   	push   %esi
  802094:	ff 35 20 54 80 00    	pushl  0x805420
  80209a:	e8 9c 0d 00 00       	call   802e3b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80209f:	83 c4 0c             	add    $0xc,%esp
  8020a2:	6a 00                	push   $0x0
  8020a4:	53                   	push   %ebx
  8020a5:	6a 00                	push   $0x0
  8020a7:	e8 26 0d 00 00       	call   802dd2 <ipc_recv>
}
  8020ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5d                   	pop    %ebp
  8020b2:	c3                   	ret    

008020b3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8020b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8020bf:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8020c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c7:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8020cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8020d1:	b8 02 00 00 00       	mov    $0x2,%eax
  8020d6:	e8 8d ff ff ff       	call   802068 <fsipc>
}
  8020db:	c9                   	leave  
  8020dc:	c3                   	ret    

008020dd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8020dd:	55                   	push   %ebp
  8020de:	89 e5                	mov    %esp,%ebp
  8020e0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8020e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8020e9:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8020ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8020f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8020f8:	e8 6b ff ff ff       	call   802068 <fsipc>
}
  8020fd:	c9                   	leave  
  8020fe:	c3                   	ret    

008020ff <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	53                   	push   %ebx
  802103:	83 ec 04             	sub    $0x4,%esp
  802106:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802109:	8b 45 08             	mov    0x8(%ebp),%eax
  80210c:	8b 40 0c             	mov    0xc(%eax),%eax
  80210f:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802114:	ba 00 00 00 00       	mov    $0x0,%edx
  802119:	b8 05 00 00 00       	mov    $0x5,%eax
  80211e:	e8 45 ff ff ff       	call   802068 <fsipc>
  802123:	85 c0                	test   %eax,%eax
  802125:	78 2c                	js     802153 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802127:	83 ec 08             	sub    $0x8,%esp
  80212a:	68 00 60 80 00       	push   $0x806000
  80212f:	53                   	push   %ebx
  802130:	e8 f4 ef ff ff       	call   801129 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802135:	a1 80 60 80 00       	mov    0x806080,%eax
  80213a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802140:	a1 84 60 80 00       	mov    0x806084,%eax
  802145:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802156:	c9                   	leave  
  802157:	c3                   	ret    

00802158 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802158:	55                   	push   %ebp
  802159:	89 e5                	mov    %esp,%ebp
  80215b:	53                   	push   %ebx
  80215c:	83 ec 08             	sub    $0x8,%esp
  80215f:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802162:	8b 55 08             	mov    0x8(%ebp),%edx
  802165:	8b 52 0c             	mov    0xc(%edx),%edx
  802168:	89 15 00 60 80 00    	mov    %edx,0x806000
  80216e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802173:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  802178:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80217b:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  802181:	53                   	push   %ebx
  802182:	ff 75 0c             	pushl  0xc(%ebp)
  802185:	68 08 60 80 00       	push   $0x806008
  80218a:	e8 2c f1 ff ff       	call   8012bb <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80218f:	ba 00 00 00 00       	mov    $0x0,%edx
  802194:	b8 04 00 00 00       	mov    $0x4,%eax
  802199:	e8 ca fe ff ff       	call   802068 <fsipc>
  80219e:	83 c4 10             	add    $0x10,%esp
  8021a1:	85 c0                	test   %eax,%eax
  8021a3:	78 1d                	js     8021c2 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8021a5:	39 d8                	cmp    %ebx,%eax
  8021a7:	76 19                	jbe    8021c2 <devfile_write+0x6a>
  8021a9:	68 5c 38 80 00       	push   $0x80385c
  8021ae:	68 ef 32 80 00       	push   $0x8032ef
  8021b3:	68 a3 00 00 00       	push   $0xa3
  8021b8:	68 68 38 80 00       	push   $0x803868
  8021bd:	e8 16 e8 ff ff       	call   8009d8 <_panic>
	return r;
}
  8021c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021c5:	c9                   	leave  
  8021c6:	c3                   	ret    

008021c7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8021c7:	55                   	push   %ebp
  8021c8:	89 e5                	mov    %esp,%ebp
  8021ca:	56                   	push   %esi
  8021cb:	53                   	push   %ebx
  8021cc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8021cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d2:	8b 40 0c             	mov    0xc(%eax),%eax
  8021d5:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8021da:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8021e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8021e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8021ea:	e8 79 fe ff ff       	call   802068 <fsipc>
  8021ef:	89 c3                	mov    %eax,%ebx
  8021f1:	85 c0                	test   %eax,%eax
  8021f3:	78 4b                	js     802240 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8021f5:	39 c6                	cmp    %eax,%esi
  8021f7:	73 16                	jae    80220f <devfile_read+0x48>
  8021f9:	68 73 38 80 00       	push   $0x803873
  8021fe:	68 ef 32 80 00       	push   $0x8032ef
  802203:	6a 7c                	push   $0x7c
  802205:	68 68 38 80 00       	push   $0x803868
  80220a:	e8 c9 e7 ff ff       	call   8009d8 <_panic>
	assert(r <= PGSIZE);
  80220f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802214:	7e 16                	jle    80222c <devfile_read+0x65>
  802216:	68 7a 38 80 00       	push   $0x80387a
  80221b:	68 ef 32 80 00       	push   $0x8032ef
  802220:	6a 7d                	push   $0x7d
  802222:	68 68 38 80 00       	push   $0x803868
  802227:	e8 ac e7 ff ff       	call   8009d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80222c:	83 ec 04             	sub    $0x4,%esp
  80222f:	50                   	push   %eax
  802230:	68 00 60 80 00       	push   $0x806000
  802235:	ff 75 0c             	pushl  0xc(%ebp)
  802238:	e8 7e f0 ff ff       	call   8012bb <memmove>
	return r;
  80223d:	83 c4 10             	add    $0x10,%esp
}
  802240:	89 d8                	mov    %ebx,%eax
  802242:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802245:	5b                   	pop    %ebx
  802246:	5e                   	pop    %esi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    

00802249 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802249:	55                   	push   %ebp
  80224a:	89 e5                	mov    %esp,%ebp
  80224c:	53                   	push   %ebx
  80224d:	83 ec 20             	sub    $0x20,%esp
  802250:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802253:	53                   	push   %ebx
  802254:	e8 97 ee ff ff       	call   8010f0 <strlen>
  802259:	83 c4 10             	add    $0x10,%esp
  80225c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802261:	7f 67                	jg     8022ca <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802263:	83 ec 0c             	sub    $0xc,%esp
  802266:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802269:	50                   	push   %eax
  80226a:	e8 71 f8 ff ff       	call   801ae0 <fd_alloc>
  80226f:	83 c4 10             	add    $0x10,%esp
		return r;
  802272:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802274:	85 c0                	test   %eax,%eax
  802276:	78 57                	js     8022cf <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802278:	83 ec 08             	sub    $0x8,%esp
  80227b:	53                   	push   %ebx
  80227c:	68 00 60 80 00       	push   $0x806000
  802281:	e8 a3 ee ff ff       	call   801129 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802286:	8b 45 0c             	mov    0xc(%ebp),%eax
  802289:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80228e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802291:	b8 01 00 00 00       	mov    $0x1,%eax
  802296:	e8 cd fd ff ff       	call   802068 <fsipc>
  80229b:	89 c3                	mov    %eax,%ebx
  80229d:	83 c4 10             	add    $0x10,%esp
  8022a0:	85 c0                	test   %eax,%eax
  8022a2:	79 14                	jns    8022b8 <open+0x6f>
		fd_close(fd, 0);
  8022a4:	83 ec 08             	sub    $0x8,%esp
  8022a7:	6a 00                	push   $0x0
  8022a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ac:	e8 27 f9 ff ff       	call   801bd8 <fd_close>
		return r;
  8022b1:	83 c4 10             	add    $0x10,%esp
  8022b4:	89 da                	mov    %ebx,%edx
  8022b6:	eb 17                	jmp    8022cf <open+0x86>
	}

	return fd2num(fd);
  8022b8:	83 ec 0c             	sub    $0xc,%esp
  8022bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8022be:	e8 f6 f7 ff ff       	call   801ab9 <fd2num>
  8022c3:	89 c2                	mov    %eax,%edx
  8022c5:	83 c4 10             	add    $0x10,%esp
  8022c8:	eb 05                	jmp    8022cf <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8022ca:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8022cf:	89 d0                	mov    %edx,%eax
  8022d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022d4:	c9                   	leave  
  8022d5:	c3                   	ret    

008022d6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8022dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8022e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8022e6:	e8 7d fd ff ff       	call   802068 <fsipc>
}
  8022eb:	c9                   	leave  
  8022ec:	c3                   	ret    

008022ed <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8022ed:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8022f1:	7e 37                	jle    80232a <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	53                   	push   %ebx
  8022f7:	83 ec 08             	sub    $0x8,%esp
  8022fa:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8022fc:	ff 70 04             	pushl  0x4(%eax)
  8022ff:	8d 40 10             	lea    0x10(%eax),%eax
  802302:	50                   	push   %eax
  802303:	ff 33                	pushl  (%ebx)
  802305:	e8 65 fb ff ff       	call   801e6f <write>
		if (result > 0)
  80230a:	83 c4 10             	add    $0x10,%esp
  80230d:	85 c0                	test   %eax,%eax
  80230f:	7e 03                	jle    802314 <writebuf+0x27>
			b->result += result;
  802311:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802314:	3b 43 04             	cmp    0x4(%ebx),%eax
  802317:	74 0d                	je     802326 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  802319:	85 c0                	test   %eax,%eax
  80231b:	ba 00 00 00 00       	mov    $0x0,%edx
  802320:	0f 4f c2             	cmovg  %edx,%eax
  802323:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802329:	c9                   	leave  
  80232a:	f3 c3                	repz ret 

0080232c <putch>:

static void
putch(int ch, void *thunk)
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	53                   	push   %ebx
  802330:	83 ec 04             	sub    $0x4,%esp
  802333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802336:	8b 53 04             	mov    0x4(%ebx),%edx
  802339:	8d 42 01             	lea    0x1(%edx),%eax
  80233c:	89 43 04             	mov    %eax,0x4(%ebx)
  80233f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802342:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802346:	3d 00 01 00 00       	cmp    $0x100,%eax
  80234b:	75 0e                	jne    80235b <putch+0x2f>
		writebuf(b);
  80234d:	89 d8                	mov    %ebx,%eax
  80234f:	e8 99 ff ff ff       	call   8022ed <writebuf>
		b->idx = 0;
  802354:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80235b:	83 c4 04             	add    $0x4,%esp
  80235e:	5b                   	pop    %ebx
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    

00802361 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  802361:	55                   	push   %ebp
  802362:	89 e5                	mov    %esp,%ebp
  802364:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80236a:	8b 45 08             	mov    0x8(%ebp),%eax
  80236d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802373:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80237a:	00 00 00 
	b.result = 0;
  80237d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802384:	00 00 00 
	b.error = 1;
  802387:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80238e:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802391:	ff 75 10             	pushl  0x10(%ebp)
  802394:	ff 75 0c             	pushl  0xc(%ebp)
  802397:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80239d:	50                   	push   %eax
  80239e:	68 2c 23 80 00       	push   $0x80232c
  8023a3:	e8 40 e8 ff ff       	call   800be8 <vprintfmt>
	if (b.idx > 0)
  8023a8:	83 c4 10             	add    $0x10,%esp
  8023ab:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8023b2:	7e 0b                	jle    8023bf <vfprintf+0x5e>
		writebuf(&b);
  8023b4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8023ba:	e8 2e ff ff ff       	call   8022ed <writebuf>

	return (b.result ? b.result : b.error);
  8023bf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8023c5:	85 c0                	test   %eax,%eax
  8023c7:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8023ce:	c9                   	leave  
  8023cf:	c3                   	ret    

008023d0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8023d6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8023d9:	50                   	push   %eax
  8023da:	ff 75 0c             	pushl  0xc(%ebp)
  8023dd:	ff 75 08             	pushl  0x8(%ebp)
  8023e0:	e8 7c ff ff ff       	call   802361 <vfprintf>
	va_end(ap);

	return cnt;
}
  8023e5:	c9                   	leave  
  8023e6:	c3                   	ret    

008023e7 <printf>:

int
printf(const char *fmt, ...)
{
  8023e7:	55                   	push   %ebp
  8023e8:	89 e5                	mov    %esp,%ebp
  8023ea:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8023ed:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8023f0:	50                   	push   %eax
  8023f1:	ff 75 08             	pushl  0x8(%ebp)
  8023f4:	6a 01                	push   $0x1
  8023f6:	e8 66 ff ff ff       	call   802361 <vfprintf>
	va_end(ap);

	return cnt;
}
  8023fb:	c9                   	leave  
  8023fc:	c3                   	ret    

008023fd <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8023fd:	55                   	push   %ebp
  8023fe:	89 e5                	mov    %esp,%ebp
  802400:	57                   	push   %edi
  802401:	56                   	push   %esi
  802402:	53                   	push   %ebx
  802403:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802409:	6a 00                	push   $0x0
  80240b:	ff 75 08             	pushl  0x8(%ebp)
  80240e:	e8 36 fe ff ff       	call   802249 <open>
  802413:	89 c7                	mov    %eax,%edi
  802415:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80241b:	83 c4 10             	add    $0x10,%esp
  80241e:	85 c0                	test   %eax,%eax
  802420:	0f 88 ae 04 00 00    	js     8028d4 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802426:	83 ec 04             	sub    $0x4,%esp
  802429:	68 00 02 00 00       	push   $0x200
  80242e:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802434:	50                   	push   %eax
  802435:	57                   	push   %edi
  802436:	e8 eb f9 ff ff       	call   801e26 <readn>
  80243b:	83 c4 10             	add    $0x10,%esp
  80243e:	3d 00 02 00 00       	cmp    $0x200,%eax
  802443:	75 0c                	jne    802451 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802445:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80244c:	45 4c 46 
  80244f:	74 33                	je     802484 <spawn+0x87>
		close(fd);
  802451:	83 ec 0c             	sub    $0xc,%esp
  802454:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80245a:	e8 fa f7 ff ff       	call   801c59 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80245f:	83 c4 0c             	add    $0xc,%esp
  802462:	68 7f 45 4c 46       	push   $0x464c457f
  802467:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80246d:	68 86 38 80 00       	push   $0x803886
  802472:	e8 3a e6 ff ff       	call   800ab1 <cprintf>
		return -E_NOT_EXEC;
  802477:	83 c4 10             	add    $0x10,%esp
  80247a:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80247f:	e9 b0 04 00 00       	jmp    802934 <spawn+0x537>
  802484:	b8 07 00 00 00       	mov    $0x7,%eax
  802489:	cd 30                	int    $0x30
  80248b:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802491:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802497:	85 c0                	test   %eax,%eax
  802499:	0f 88 3d 04 00 00    	js     8028dc <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80249f:	89 c6                	mov    %eax,%esi
  8024a1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8024a7:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8024aa:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8024b0:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8024b6:	b9 11 00 00 00       	mov    $0x11,%ecx
  8024bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8024bd:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8024c3:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8024c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8024ce:	be 00 00 00 00       	mov    $0x0,%esi
  8024d3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024d6:	eb 13                	jmp    8024eb <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8024d8:	83 ec 0c             	sub    $0xc,%esp
  8024db:	50                   	push   %eax
  8024dc:	e8 0f ec ff ff       	call   8010f0 <strlen>
  8024e1:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8024e5:	83 c3 01             	add    $0x1,%ebx
  8024e8:	83 c4 10             	add    $0x10,%esp
  8024eb:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8024f2:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8024f5:	85 c0                	test   %eax,%eax
  8024f7:	75 df                	jne    8024d8 <spawn+0xdb>
  8024f9:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8024ff:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802505:	bf 00 10 40 00       	mov    $0x401000,%edi
  80250a:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80250c:	89 fa                	mov    %edi,%edx
  80250e:	83 e2 fc             	and    $0xfffffffc,%edx
  802511:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  802518:	29 c2                	sub    %eax,%edx
  80251a:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802520:	8d 42 f8             	lea    -0x8(%edx),%eax
  802523:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802528:	0f 86 be 03 00 00    	jbe    8028ec <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80252e:	83 ec 04             	sub    $0x4,%esp
  802531:	6a 07                	push   $0x7
  802533:	68 00 00 40 00       	push   $0x400000
  802538:	6a 00                	push   $0x0
  80253a:	e8 ed ef ff ff       	call   80152c <sys_page_alloc>
  80253f:	83 c4 10             	add    $0x10,%esp
  802542:	85 c0                	test   %eax,%eax
  802544:	0f 88 a9 03 00 00    	js     8028f3 <spawn+0x4f6>
  80254a:	be 00 00 00 00       	mov    $0x0,%esi
  80254f:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802555:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802558:	eb 30                	jmp    80258a <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  80255a:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802560:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802566:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802569:	83 ec 08             	sub    $0x8,%esp
  80256c:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80256f:	57                   	push   %edi
  802570:	e8 b4 eb ff ff       	call   801129 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802575:	83 c4 04             	add    $0x4,%esp
  802578:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80257b:	e8 70 eb ff ff       	call   8010f0 <strlen>
  802580:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802584:	83 c6 01             	add    $0x1,%esi
  802587:	83 c4 10             	add    $0x10,%esp
  80258a:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  802590:	7f c8                	jg     80255a <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802592:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802598:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80259e:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  8025a5:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8025ab:	74 19                	je     8025c6 <spawn+0x1c9>
  8025ad:	68 e4 38 80 00       	push   $0x8038e4
  8025b2:	68 ef 32 80 00       	push   $0x8032ef
  8025b7:	68 f2 00 00 00       	push   $0xf2
  8025bc:	68 a0 38 80 00       	push   $0x8038a0
  8025c1:	e8 12 e4 ff ff       	call   8009d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8025c6:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8025cc:	89 f8                	mov    %edi,%eax
  8025ce:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8025d3:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8025d6:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8025dc:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8025df:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8025e5:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8025eb:	83 ec 0c             	sub    $0xc,%esp
  8025ee:	6a 07                	push   $0x7
  8025f0:	68 00 d0 bf ee       	push   $0xeebfd000
  8025f5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8025fb:	68 00 00 40 00       	push   $0x400000
  802600:	6a 00                	push   $0x0
  802602:	e8 68 ef ff ff       	call   80156f <sys_page_map>
  802607:	89 c3                	mov    %eax,%ebx
  802609:	83 c4 20             	add    $0x20,%esp
  80260c:	85 c0                	test   %eax,%eax
  80260e:	0f 88 0e 03 00 00    	js     802922 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802614:	83 ec 08             	sub    $0x8,%esp
  802617:	68 00 00 40 00       	push   $0x400000
  80261c:	6a 00                	push   $0x0
  80261e:	e8 8e ef ff ff       	call   8015b1 <sys_page_unmap>
  802623:	89 c3                	mov    %eax,%ebx
  802625:	83 c4 10             	add    $0x10,%esp
  802628:	85 c0                	test   %eax,%eax
  80262a:	0f 88 f2 02 00 00    	js     802922 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  802630:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802636:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80263d:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802643:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  80264a:	00 00 00 
  80264d:	e9 88 01 00 00       	jmp    8027da <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  802652:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802658:	83 38 01             	cmpl   $0x1,(%eax)
  80265b:	0f 85 6b 01 00 00    	jne    8027cc <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802661:	89 c7                	mov    %eax,%edi
  802663:	8b 40 18             	mov    0x18(%eax),%eax
  802666:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80266c:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80266f:	83 f8 01             	cmp    $0x1,%eax
  802672:	19 c0                	sbb    %eax,%eax
  802674:	83 e0 fe             	and    $0xfffffffe,%eax
  802677:	83 c0 07             	add    $0x7,%eax
  80267a:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802680:	89 f8                	mov    %edi,%eax
  802682:	8b 7f 04             	mov    0x4(%edi),%edi
  802685:	89 f9                	mov    %edi,%ecx
  802687:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80268d:	8b 78 10             	mov    0x10(%eax),%edi
  802690:	8b 50 14             	mov    0x14(%eax),%edx
  802693:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802699:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80269c:	89 f0                	mov    %esi,%eax
  80269e:	25 ff 0f 00 00       	and    $0xfff,%eax
  8026a3:	74 14                	je     8026b9 <spawn+0x2bc>
		va -= i;
  8026a5:	29 c6                	sub    %eax,%esi
		memsz += i;
  8026a7:	01 c2                	add    %eax,%edx
  8026a9:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8026af:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8026b1:	29 c1                	sub    %eax,%ecx
  8026b3:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8026b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026be:	e9 f7 00 00 00       	jmp    8027ba <spawn+0x3bd>
		if (i >= filesz) {
  8026c3:	39 df                	cmp    %ebx,%edi
  8026c5:	77 27                	ja     8026ee <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8026c7:	83 ec 04             	sub    $0x4,%esp
  8026ca:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8026d0:	56                   	push   %esi
  8026d1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8026d7:	e8 50 ee ff ff       	call   80152c <sys_page_alloc>
  8026dc:	83 c4 10             	add    $0x10,%esp
  8026df:	85 c0                	test   %eax,%eax
  8026e1:	0f 89 c7 00 00 00    	jns    8027ae <spawn+0x3b1>
  8026e7:	89 c3                	mov    %eax,%ebx
  8026e9:	e9 13 02 00 00       	jmp    802901 <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8026ee:	83 ec 04             	sub    $0x4,%esp
  8026f1:	6a 07                	push   $0x7
  8026f3:	68 00 00 40 00       	push   $0x400000
  8026f8:	6a 00                	push   $0x0
  8026fa:	e8 2d ee ff ff       	call   80152c <sys_page_alloc>
  8026ff:	83 c4 10             	add    $0x10,%esp
  802702:	85 c0                	test   %eax,%eax
  802704:	0f 88 ed 01 00 00    	js     8028f7 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  80270a:	83 ec 08             	sub    $0x8,%esp
  80270d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802713:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  802719:	50                   	push   %eax
  80271a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802720:	e8 d6 f7 ff ff       	call   801efb <seek>
  802725:	83 c4 10             	add    $0x10,%esp
  802728:	85 c0                	test   %eax,%eax
  80272a:	0f 88 cb 01 00 00    	js     8028fb <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802730:	83 ec 04             	sub    $0x4,%esp
  802733:	89 f8                	mov    %edi,%eax
  802735:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  80273b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802740:	ba 00 10 00 00       	mov    $0x1000,%edx
  802745:	0f 47 c2             	cmova  %edx,%eax
  802748:	50                   	push   %eax
  802749:	68 00 00 40 00       	push   $0x400000
  80274e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802754:	e8 cd f6 ff ff       	call   801e26 <readn>
  802759:	83 c4 10             	add    $0x10,%esp
  80275c:	85 c0                	test   %eax,%eax
  80275e:	0f 88 9b 01 00 00    	js     8028ff <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802764:	83 ec 0c             	sub    $0xc,%esp
  802767:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80276d:	56                   	push   %esi
  80276e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802774:	68 00 00 40 00       	push   $0x400000
  802779:	6a 00                	push   $0x0
  80277b:	e8 ef ed ff ff       	call   80156f <sys_page_map>
  802780:	83 c4 20             	add    $0x20,%esp
  802783:	85 c0                	test   %eax,%eax
  802785:	79 15                	jns    80279c <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802787:	50                   	push   %eax
  802788:	68 ac 38 80 00       	push   $0x8038ac
  80278d:	68 25 01 00 00       	push   $0x125
  802792:	68 a0 38 80 00       	push   $0x8038a0
  802797:	e8 3c e2 ff ff       	call   8009d8 <_panic>
			sys_page_unmap(0, UTEMP);
  80279c:	83 ec 08             	sub    $0x8,%esp
  80279f:	68 00 00 40 00       	push   $0x400000
  8027a4:	6a 00                	push   $0x0
  8027a6:	e8 06 ee ff ff       	call   8015b1 <sys_page_unmap>
  8027ab:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8027ae:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8027b4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8027ba:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8027c0:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  8027c6:	0f 87 f7 fe ff ff    	ja     8026c3 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027cc:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8027d3:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8027da:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8027e1:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8027e7:	0f 8c 65 fe ff ff    	jl     802652 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8027ed:	83 ec 0c             	sub    $0xc,%esp
  8027f0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8027f6:	e8 5e f4 ff ff       	call   801c59 <close>
  8027fb:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  8027fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  802803:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  802809:	89 d8                	mov    %ebx,%eax
  80280b:	c1 e8 16             	shr    $0x16,%eax
  80280e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802815:	a8 01                	test   $0x1,%al
  802817:	74 46                	je     80285f <spawn+0x462>
  802819:	89 d8                	mov    %ebx,%eax
  80281b:	c1 e8 0c             	shr    $0xc,%eax
  80281e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802825:	f6 c2 01             	test   $0x1,%dl
  802828:	74 35                	je     80285f <spawn+0x462>
  80282a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802831:	f6 c2 04             	test   $0x4,%dl
  802834:	74 29                	je     80285f <spawn+0x462>
  802836:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80283d:	f6 c6 04             	test   $0x4,%dh
  802840:	74 1d                	je     80285f <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] & PTE_SYSCALL));
  802842:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802849:	83 ec 0c             	sub    $0xc,%esp
  80284c:	25 07 0e 00 00       	and    $0xe07,%eax
  802851:	50                   	push   %eax
  802852:	53                   	push   %ebx
  802853:	56                   	push   %esi
  802854:	53                   	push   %ebx
  802855:	6a 00                	push   $0x0
  802857:	e8 13 ed ff ff       	call   80156f <sys_page_map>
  80285c:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  80285f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802865:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80286b:	75 9c                	jne    802809 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80286d:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802874:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802877:	83 ec 08             	sub    $0x8,%esp
  80287a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802880:	50                   	push   %eax
  802881:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802887:	e8 a9 ed ff ff       	call   801635 <sys_env_set_trapframe>
  80288c:	83 c4 10             	add    $0x10,%esp
  80288f:	85 c0                	test   %eax,%eax
  802891:	79 15                	jns    8028a8 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  802893:	50                   	push   %eax
  802894:	68 c9 38 80 00       	push   $0x8038c9
  802899:	68 86 00 00 00       	push   $0x86
  80289e:	68 a0 38 80 00       	push   $0x8038a0
  8028a3:	e8 30 e1 ff ff       	call   8009d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  8028a8:	83 ec 08             	sub    $0x8,%esp
  8028ab:	6a 02                	push   $0x2
  8028ad:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8028b3:	e8 3b ed ff ff       	call   8015f3 <sys_env_set_status>
  8028b8:	83 c4 10             	add    $0x10,%esp
  8028bb:	85 c0                	test   %eax,%eax
  8028bd:	79 25                	jns    8028e4 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  8028bf:	50                   	push   %eax
  8028c0:	68 6c 37 80 00       	push   $0x80376c
  8028c5:	68 89 00 00 00       	push   $0x89
  8028ca:	68 a0 38 80 00       	push   $0x8038a0
  8028cf:	e8 04 e1 ff ff       	call   8009d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8028d4:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  8028da:	eb 58                	jmp    802934 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8028dc:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8028e2:	eb 50                	jmp    802934 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  8028e4:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  8028ea:	eb 48                	jmp    802934 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8028ec:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  8028f1:	eb 41                	jmp    802934 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  8028f3:	89 c3                	mov    %eax,%ebx
  8028f5:	eb 3d                	jmp    802934 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8028f7:	89 c3                	mov    %eax,%ebx
  8028f9:	eb 06                	jmp    802901 <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8028fb:	89 c3                	mov    %eax,%ebx
  8028fd:	eb 02                	jmp    802901 <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8028ff:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  802901:	83 ec 0c             	sub    $0xc,%esp
  802904:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80290a:	e8 9e eb ff ff       	call   8014ad <sys_env_destroy>
	close(fd);
  80290f:	83 c4 04             	add    $0x4,%esp
  802912:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802918:	e8 3c f3 ff ff       	call   801c59 <close>
	return r;
  80291d:	83 c4 10             	add    $0x10,%esp
  802920:	eb 12                	jmp    802934 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802922:	83 ec 08             	sub    $0x8,%esp
  802925:	68 00 00 40 00       	push   $0x400000
  80292a:	6a 00                	push   $0x0
  80292c:	e8 80 ec ff ff       	call   8015b1 <sys_page_unmap>
  802931:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802934:	89 d8                	mov    %ebx,%eax
  802936:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802939:	5b                   	pop    %ebx
  80293a:	5e                   	pop    %esi
  80293b:	5f                   	pop    %edi
  80293c:	5d                   	pop    %ebp
  80293d:	c3                   	ret    

0080293e <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80293e:	55                   	push   %ebp
  80293f:	89 e5                	mov    %esp,%ebp
  802941:	56                   	push   %esi
  802942:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802943:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802946:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80294b:	eb 03                	jmp    802950 <spawnl+0x12>
		argc++;
  80294d:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802950:	83 c2 04             	add    $0x4,%edx
  802953:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802957:	75 f4                	jne    80294d <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802959:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802960:	83 e2 f0             	and    $0xfffffff0,%edx
  802963:	29 d4                	sub    %edx,%esp
  802965:	8d 54 24 03          	lea    0x3(%esp),%edx
  802969:	c1 ea 02             	shr    $0x2,%edx
  80296c:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802973:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802975:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802978:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  80297f:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802986:	00 
  802987:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802989:	b8 00 00 00 00       	mov    $0x0,%eax
  80298e:	eb 0a                	jmp    80299a <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802990:	83 c0 01             	add    $0x1,%eax
  802993:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802997:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  80299a:	39 d0                	cmp    %edx,%eax
  80299c:	75 f2                	jne    802990 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  80299e:	83 ec 08             	sub    $0x8,%esp
  8029a1:	56                   	push   %esi
  8029a2:	ff 75 08             	pushl  0x8(%ebp)
  8029a5:	e8 53 fa ff ff       	call   8023fd <spawn>
}
  8029aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029ad:	5b                   	pop    %ebx
  8029ae:	5e                   	pop    %esi
  8029af:	5d                   	pop    %ebp
  8029b0:	c3                   	ret    

008029b1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8029b1:	55                   	push   %ebp
  8029b2:	89 e5                	mov    %esp,%ebp
  8029b4:	56                   	push   %esi
  8029b5:	53                   	push   %ebx
  8029b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8029b9:	83 ec 0c             	sub    $0xc,%esp
  8029bc:	ff 75 08             	pushl  0x8(%ebp)
  8029bf:	e8 05 f1 ff ff       	call   801ac9 <fd2data>
  8029c4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8029c6:	83 c4 08             	add    $0x8,%esp
  8029c9:	68 0c 39 80 00       	push   $0x80390c
  8029ce:	53                   	push   %ebx
  8029cf:	e8 55 e7 ff ff       	call   801129 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8029d4:	8b 46 04             	mov    0x4(%esi),%eax
  8029d7:	2b 06                	sub    (%esi),%eax
  8029d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8029df:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8029e6:	00 00 00 
	stat->st_dev = &devpipe;
  8029e9:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8029f0:	40 80 00 
	return 0;
}
  8029f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8029f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029fb:	5b                   	pop    %ebx
  8029fc:	5e                   	pop    %esi
  8029fd:	5d                   	pop    %ebp
  8029fe:	c3                   	ret    

008029ff <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8029ff:	55                   	push   %ebp
  802a00:	89 e5                	mov    %esp,%ebp
  802a02:	53                   	push   %ebx
  802a03:	83 ec 0c             	sub    $0xc,%esp
  802a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802a09:	53                   	push   %ebx
  802a0a:	6a 00                	push   $0x0
  802a0c:	e8 a0 eb ff ff       	call   8015b1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802a11:	89 1c 24             	mov    %ebx,(%esp)
  802a14:	e8 b0 f0 ff ff       	call   801ac9 <fd2data>
  802a19:	83 c4 08             	add    $0x8,%esp
  802a1c:	50                   	push   %eax
  802a1d:	6a 00                	push   $0x0
  802a1f:	e8 8d eb ff ff       	call   8015b1 <sys_page_unmap>
}
  802a24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802a27:	c9                   	leave  
  802a28:	c3                   	ret    

00802a29 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802a29:	55                   	push   %ebp
  802a2a:	89 e5                	mov    %esp,%ebp
  802a2c:	57                   	push   %edi
  802a2d:	56                   	push   %esi
  802a2e:	53                   	push   %ebx
  802a2f:	83 ec 1c             	sub    $0x1c,%esp
  802a32:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802a35:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802a37:	a1 24 54 80 00       	mov    0x805424,%eax
  802a3c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802a3f:	83 ec 0c             	sub    $0xc,%esp
  802a42:	ff 75 e0             	pushl  -0x20(%ebp)
  802a45:	e8 7e 04 00 00       	call   802ec8 <pageref>
  802a4a:	89 c3                	mov    %eax,%ebx
  802a4c:	89 3c 24             	mov    %edi,(%esp)
  802a4f:	e8 74 04 00 00       	call   802ec8 <pageref>
  802a54:	83 c4 10             	add    $0x10,%esp
  802a57:	39 c3                	cmp    %eax,%ebx
  802a59:	0f 94 c1             	sete   %cl
  802a5c:	0f b6 c9             	movzbl %cl,%ecx
  802a5f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802a62:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802a68:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802a6b:	39 ce                	cmp    %ecx,%esi
  802a6d:	74 1b                	je     802a8a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802a6f:	39 c3                	cmp    %eax,%ebx
  802a71:	75 c4                	jne    802a37 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802a73:	8b 42 58             	mov    0x58(%edx),%eax
  802a76:	ff 75 e4             	pushl  -0x1c(%ebp)
  802a79:	50                   	push   %eax
  802a7a:	56                   	push   %esi
  802a7b:	68 13 39 80 00       	push   $0x803913
  802a80:	e8 2c e0 ff ff       	call   800ab1 <cprintf>
  802a85:	83 c4 10             	add    $0x10,%esp
  802a88:	eb ad                	jmp    802a37 <_pipeisclosed+0xe>
	}
}
  802a8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a90:	5b                   	pop    %ebx
  802a91:	5e                   	pop    %esi
  802a92:	5f                   	pop    %edi
  802a93:	5d                   	pop    %ebp
  802a94:	c3                   	ret    

00802a95 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802a95:	55                   	push   %ebp
  802a96:	89 e5                	mov    %esp,%ebp
  802a98:	57                   	push   %edi
  802a99:	56                   	push   %esi
  802a9a:	53                   	push   %ebx
  802a9b:	83 ec 28             	sub    $0x28,%esp
  802a9e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802aa1:	56                   	push   %esi
  802aa2:	e8 22 f0 ff ff       	call   801ac9 <fd2data>
  802aa7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802aa9:	83 c4 10             	add    $0x10,%esp
  802aac:	bf 00 00 00 00       	mov    $0x0,%edi
  802ab1:	eb 4b                	jmp    802afe <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802ab3:	89 da                	mov    %ebx,%edx
  802ab5:	89 f0                	mov    %esi,%eax
  802ab7:	e8 6d ff ff ff       	call   802a29 <_pipeisclosed>
  802abc:	85 c0                	test   %eax,%eax
  802abe:	75 48                	jne    802b08 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802ac0:	e8 48 ea ff ff       	call   80150d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802ac5:	8b 43 04             	mov    0x4(%ebx),%eax
  802ac8:	8b 0b                	mov    (%ebx),%ecx
  802aca:	8d 51 20             	lea    0x20(%ecx),%edx
  802acd:	39 d0                	cmp    %edx,%eax
  802acf:	73 e2                	jae    802ab3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802ad1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ad4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802ad8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802adb:	89 c2                	mov    %eax,%edx
  802add:	c1 fa 1f             	sar    $0x1f,%edx
  802ae0:	89 d1                	mov    %edx,%ecx
  802ae2:	c1 e9 1b             	shr    $0x1b,%ecx
  802ae5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802ae8:	83 e2 1f             	and    $0x1f,%edx
  802aeb:	29 ca                	sub    %ecx,%edx
  802aed:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802af1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802af5:	83 c0 01             	add    $0x1,%eax
  802af8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802afb:	83 c7 01             	add    $0x1,%edi
  802afe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802b01:	75 c2                	jne    802ac5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802b03:	8b 45 10             	mov    0x10(%ebp),%eax
  802b06:	eb 05                	jmp    802b0d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b08:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802b0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b10:	5b                   	pop    %ebx
  802b11:	5e                   	pop    %esi
  802b12:	5f                   	pop    %edi
  802b13:	5d                   	pop    %ebp
  802b14:	c3                   	ret    

00802b15 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802b15:	55                   	push   %ebp
  802b16:	89 e5                	mov    %esp,%ebp
  802b18:	57                   	push   %edi
  802b19:	56                   	push   %esi
  802b1a:	53                   	push   %ebx
  802b1b:	83 ec 18             	sub    $0x18,%esp
  802b1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802b21:	57                   	push   %edi
  802b22:	e8 a2 ef ff ff       	call   801ac9 <fd2data>
  802b27:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b29:	83 c4 10             	add    $0x10,%esp
  802b2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b31:	eb 3d                	jmp    802b70 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802b33:	85 db                	test   %ebx,%ebx
  802b35:	74 04                	je     802b3b <devpipe_read+0x26>
				return i;
  802b37:	89 d8                	mov    %ebx,%eax
  802b39:	eb 44                	jmp    802b7f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802b3b:	89 f2                	mov    %esi,%edx
  802b3d:	89 f8                	mov    %edi,%eax
  802b3f:	e8 e5 fe ff ff       	call   802a29 <_pipeisclosed>
  802b44:	85 c0                	test   %eax,%eax
  802b46:	75 32                	jne    802b7a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802b48:	e8 c0 e9 ff ff       	call   80150d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802b4d:	8b 06                	mov    (%esi),%eax
  802b4f:	3b 46 04             	cmp    0x4(%esi),%eax
  802b52:	74 df                	je     802b33 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802b54:	99                   	cltd   
  802b55:	c1 ea 1b             	shr    $0x1b,%edx
  802b58:	01 d0                	add    %edx,%eax
  802b5a:	83 e0 1f             	and    $0x1f,%eax
  802b5d:	29 d0                	sub    %edx,%eax
  802b5f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802b64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b67:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802b6a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b6d:	83 c3 01             	add    $0x1,%ebx
  802b70:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802b73:	75 d8                	jne    802b4d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802b75:	8b 45 10             	mov    0x10(%ebp),%eax
  802b78:	eb 05                	jmp    802b7f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b7a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b82:	5b                   	pop    %ebx
  802b83:	5e                   	pop    %esi
  802b84:	5f                   	pop    %edi
  802b85:	5d                   	pop    %ebp
  802b86:	c3                   	ret    

00802b87 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802b87:	55                   	push   %ebp
  802b88:	89 e5                	mov    %esp,%ebp
  802b8a:	56                   	push   %esi
  802b8b:	53                   	push   %ebx
  802b8c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802b8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b92:	50                   	push   %eax
  802b93:	e8 48 ef ff ff       	call   801ae0 <fd_alloc>
  802b98:	83 c4 10             	add    $0x10,%esp
  802b9b:	89 c2                	mov    %eax,%edx
  802b9d:	85 c0                	test   %eax,%eax
  802b9f:	0f 88 2c 01 00 00    	js     802cd1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ba5:	83 ec 04             	sub    $0x4,%esp
  802ba8:	68 07 04 00 00       	push   $0x407
  802bad:	ff 75 f4             	pushl  -0xc(%ebp)
  802bb0:	6a 00                	push   $0x0
  802bb2:	e8 75 e9 ff ff       	call   80152c <sys_page_alloc>
  802bb7:	83 c4 10             	add    $0x10,%esp
  802bba:	89 c2                	mov    %eax,%edx
  802bbc:	85 c0                	test   %eax,%eax
  802bbe:	0f 88 0d 01 00 00    	js     802cd1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802bc4:	83 ec 0c             	sub    $0xc,%esp
  802bc7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bca:	50                   	push   %eax
  802bcb:	e8 10 ef ff ff       	call   801ae0 <fd_alloc>
  802bd0:	89 c3                	mov    %eax,%ebx
  802bd2:	83 c4 10             	add    $0x10,%esp
  802bd5:	85 c0                	test   %eax,%eax
  802bd7:	0f 88 e2 00 00 00    	js     802cbf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bdd:	83 ec 04             	sub    $0x4,%esp
  802be0:	68 07 04 00 00       	push   $0x407
  802be5:	ff 75 f0             	pushl  -0x10(%ebp)
  802be8:	6a 00                	push   $0x0
  802bea:	e8 3d e9 ff ff       	call   80152c <sys_page_alloc>
  802bef:	89 c3                	mov    %eax,%ebx
  802bf1:	83 c4 10             	add    $0x10,%esp
  802bf4:	85 c0                	test   %eax,%eax
  802bf6:	0f 88 c3 00 00 00    	js     802cbf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802bfc:	83 ec 0c             	sub    $0xc,%esp
  802bff:	ff 75 f4             	pushl  -0xc(%ebp)
  802c02:	e8 c2 ee ff ff       	call   801ac9 <fd2data>
  802c07:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c09:	83 c4 0c             	add    $0xc,%esp
  802c0c:	68 07 04 00 00       	push   $0x407
  802c11:	50                   	push   %eax
  802c12:	6a 00                	push   $0x0
  802c14:	e8 13 e9 ff ff       	call   80152c <sys_page_alloc>
  802c19:	89 c3                	mov    %eax,%ebx
  802c1b:	83 c4 10             	add    $0x10,%esp
  802c1e:	85 c0                	test   %eax,%eax
  802c20:	0f 88 89 00 00 00    	js     802caf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c26:	83 ec 0c             	sub    $0xc,%esp
  802c29:	ff 75 f0             	pushl  -0x10(%ebp)
  802c2c:	e8 98 ee ff ff       	call   801ac9 <fd2data>
  802c31:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802c38:	50                   	push   %eax
  802c39:	6a 00                	push   $0x0
  802c3b:	56                   	push   %esi
  802c3c:	6a 00                	push   $0x0
  802c3e:	e8 2c e9 ff ff       	call   80156f <sys_page_map>
  802c43:	89 c3                	mov    %eax,%ebx
  802c45:	83 c4 20             	add    $0x20,%esp
  802c48:	85 c0                	test   %eax,%eax
  802c4a:	78 55                	js     802ca1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802c4c:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c55:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c5a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802c61:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c6a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c6f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802c76:	83 ec 0c             	sub    $0xc,%esp
  802c79:	ff 75 f4             	pushl  -0xc(%ebp)
  802c7c:	e8 38 ee ff ff       	call   801ab9 <fd2num>
  802c81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c84:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802c86:	83 c4 04             	add    $0x4,%esp
  802c89:	ff 75 f0             	pushl  -0x10(%ebp)
  802c8c:	e8 28 ee ff ff       	call   801ab9 <fd2num>
  802c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c94:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802c97:	83 c4 10             	add    $0x10,%esp
  802c9a:	ba 00 00 00 00       	mov    $0x0,%edx
  802c9f:	eb 30                	jmp    802cd1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802ca1:	83 ec 08             	sub    $0x8,%esp
  802ca4:	56                   	push   %esi
  802ca5:	6a 00                	push   $0x0
  802ca7:	e8 05 e9 ff ff       	call   8015b1 <sys_page_unmap>
  802cac:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802caf:	83 ec 08             	sub    $0x8,%esp
  802cb2:	ff 75 f0             	pushl  -0x10(%ebp)
  802cb5:	6a 00                	push   $0x0
  802cb7:	e8 f5 e8 ff ff       	call   8015b1 <sys_page_unmap>
  802cbc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802cbf:	83 ec 08             	sub    $0x8,%esp
  802cc2:	ff 75 f4             	pushl  -0xc(%ebp)
  802cc5:	6a 00                	push   $0x0
  802cc7:	e8 e5 e8 ff ff       	call   8015b1 <sys_page_unmap>
  802ccc:	83 c4 10             	add    $0x10,%esp
  802ccf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802cd1:	89 d0                	mov    %edx,%eax
  802cd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802cd6:	5b                   	pop    %ebx
  802cd7:	5e                   	pop    %esi
  802cd8:	5d                   	pop    %ebp
  802cd9:	c3                   	ret    

00802cda <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802cda:	55                   	push   %ebp
  802cdb:	89 e5                	mov    %esp,%ebp
  802cdd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802ce0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ce3:	50                   	push   %eax
  802ce4:	ff 75 08             	pushl  0x8(%ebp)
  802ce7:	e8 43 ee ff ff       	call   801b2f <fd_lookup>
  802cec:	83 c4 10             	add    $0x10,%esp
  802cef:	85 c0                	test   %eax,%eax
  802cf1:	78 18                	js     802d0b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802cf3:	83 ec 0c             	sub    $0xc,%esp
  802cf6:	ff 75 f4             	pushl  -0xc(%ebp)
  802cf9:	e8 cb ed ff ff       	call   801ac9 <fd2data>
	return _pipeisclosed(fd, p);
  802cfe:	89 c2                	mov    %eax,%edx
  802d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d03:	e8 21 fd ff ff       	call   802a29 <_pipeisclosed>
  802d08:	83 c4 10             	add    $0x10,%esp
}
  802d0b:	c9                   	leave  
  802d0c:	c3                   	ret    

00802d0d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802d0d:	55                   	push   %ebp
  802d0e:	89 e5                	mov    %esp,%ebp
  802d10:	56                   	push   %esi
  802d11:	53                   	push   %ebx
  802d12:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802d15:	85 f6                	test   %esi,%esi
  802d17:	75 16                	jne    802d2f <wait+0x22>
  802d19:	68 2b 39 80 00       	push   $0x80392b
  802d1e:	68 ef 32 80 00       	push   $0x8032ef
  802d23:	6a 09                	push   $0x9
  802d25:	68 36 39 80 00       	push   $0x803936
  802d2a:	e8 a9 dc ff ff       	call   8009d8 <_panic>
	e = &envs[ENVX(envid)];
  802d2f:	89 f3                	mov    %esi,%ebx
  802d31:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802d37:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802d3a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802d40:	eb 05                	jmp    802d47 <wait+0x3a>
		sys_yield();
  802d42:	e8 c6 e7 ff ff       	call   80150d <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802d47:	8b 43 48             	mov    0x48(%ebx),%eax
  802d4a:	39 c6                	cmp    %eax,%esi
  802d4c:	75 07                	jne    802d55 <wait+0x48>
  802d4e:	8b 43 54             	mov    0x54(%ebx),%eax
  802d51:	85 c0                	test   %eax,%eax
  802d53:	75 ed                	jne    802d42 <wait+0x35>
		sys_yield();
}
  802d55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d58:	5b                   	pop    %ebx
  802d59:	5e                   	pop    %esi
  802d5a:	5d                   	pop    %ebp
  802d5b:	c3                   	ret    

00802d5c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802d5c:	55                   	push   %ebp
  802d5d:	89 e5                	mov    %esp,%ebp
  802d5f:	53                   	push   %ebx
  802d60:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802d63:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802d6a:	75 28                	jne    802d94 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802d6c:	e8 7d e7 ff ff       	call   8014ee <sys_getenvid>
  802d71:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802d73:	83 ec 04             	sub    $0x4,%esp
  802d76:	6a 06                	push   $0x6
  802d78:	68 00 f0 bf ee       	push   $0xeebff000
  802d7d:	50                   	push   %eax
  802d7e:	e8 a9 e7 ff ff       	call   80152c <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802d83:	83 c4 08             	add    $0x8,%esp
  802d86:	68 a1 2d 80 00       	push   $0x802da1
  802d8b:	53                   	push   %ebx
  802d8c:	e8 e6 e8 ff ff       	call   801677 <sys_env_set_pgfault_upcall>
  802d91:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802d94:	8b 45 08             	mov    0x8(%ebp),%eax
  802d97:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802d9c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d9f:	c9                   	leave  
  802da0:	c3                   	ret    

00802da1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802da1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802da2:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802da7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802da9:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802dac:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802dae:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802db1:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802db4:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802db7:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802dba:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802dbd:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802dc0:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802dc3:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802dc6:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802dc9:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802dcc:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802dcf:	61                   	popa   
	popfl
  802dd0:	9d                   	popf   
	ret
  802dd1:	c3                   	ret    

00802dd2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802dd2:	55                   	push   %ebp
  802dd3:	89 e5                	mov    %esp,%ebp
  802dd5:	56                   	push   %esi
  802dd6:	53                   	push   %ebx
  802dd7:	8b 75 08             	mov    0x8(%ebp),%esi
  802dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802de0:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802de2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802de7:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802dea:	83 ec 0c             	sub    $0xc,%esp
  802ded:	50                   	push   %eax
  802dee:	e8 e9 e8 ff ff       	call   8016dc <sys_ipc_recv>

	if (r < 0) {
  802df3:	83 c4 10             	add    $0x10,%esp
  802df6:	85 c0                	test   %eax,%eax
  802df8:	79 16                	jns    802e10 <ipc_recv+0x3e>
		if (from_env_store)
  802dfa:	85 f6                	test   %esi,%esi
  802dfc:	74 06                	je     802e04 <ipc_recv+0x32>
			*from_env_store = 0;
  802dfe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802e04:	85 db                	test   %ebx,%ebx
  802e06:	74 2c                	je     802e34 <ipc_recv+0x62>
			*perm_store = 0;
  802e08:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802e0e:	eb 24                	jmp    802e34 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802e10:	85 f6                	test   %esi,%esi
  802e12:	74 0a                	je     802e1e <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802e14:	a1 24 54 80 00       	mov    0x805424,%eax
  802e19:	8b 40 74             	mov    0x74(%eax),%eax
  802e1c:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802e1e:	85 db                	test   %ebx,%ebx
  802e20:	74 0a                	je     802e2c <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802e22:	a1 24 54 80 00       	mov    0x805424,%eax
  802e27:	8b 40 78             	mov    0x78(%eax),%eax
  802e2a:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802e2c:	a1 24 54 80 00       	mov    0x805424,%eax
  802e31:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802e34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e37:	5b                   	pop    %ebx
  802e38:	5e                   	pop    %esi
  802e39:	5d                   	pop    %ebp
  802e3a:	c3                   	ret    

00802e3b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802e3b:	55                   	push   %ebp
  802e3c:	89 e5                	mov    %esp,%ebp
  802e3e:	57                   	push   %edi
  802e3f:	56                   	push   %esi
  802e40:	53                   	push   %ebx
  802e41:	83 ec 0c             	sub    $0xc,%esp
  802e44:	8b 7d 08             	mov    0x8(%ebp),%edi
  802e47:	8b 75 0c             	mov    0xc(%ebp),%esi
  802e4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802e4d:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802e4f:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802e54:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802e57:	ff 75 14             	pushl  0x14(%ebp)
  802e5a:	53                   	push   %ebx
  802e5b:	56                   	push   %esi
  802e5c:	57                   	push   %edi
  802e5d:	e8 57 e8 ff ff       	call   8016b9 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802e62:	83 c4 10             	add    $0x10,%esp
  802e65:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802e68:	75 07                	jne    802e71 <ipc_send+0x36>
			sys_yield();
  802e6a:	e8 9e e6 ff ff       	call   80150d <sys_yield>
  802e6f:	eb e6                	jmp    802e57 <ipc_send+0x1c>
		} else if (r < 0) {
  802e71:	85 c0                	test   %eax,%eax
  802e73:	79 12                	jns    802e87 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802e75:	50                   	push   %eax
  802e76:	68 41 39 80 00       	push   $0x803941
  802e7b:	6a 51                	push   $0x51
  802e7d:	68 4e 39 80 00       	push   $0x80394e
  802e82:	e8 51 db ff ff       	call   8009d8 <_panic>
		}
	}
}
  802e87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e8a:	5b                   	pop    %ebx
  802e8b:	5e                   	pop    %esi
  802e8c:	5f                   	pop    %edi
  802e8d:	5d                   	pop    %ebp
  802e8e:	c3                   	ret    

00802e8f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802e8f:	55                   	push   %ebp
  802e90:	89 e5                	mov    %esp,%ebp
  802e92:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802e95:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802e9a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802e9d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802ea3:	8b 52 50             	mov    0x50(%edx),%edx
  802ea6:	39 ca                	cmp    %ecx,%edx
  802ea8:	75 0d                	jne    802eb7 <ipc_find_env+0x28>
			return envs[i].env_id;
  802eaa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802ead:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802eb2:	8b 40 48             	mov    0x48(%eax),%eax
  802eb5:	eb 0f                	jmp    802ec6 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802eb7:	83 c0 01             	add    $0x1,%eax
  802eba:	3d 00 04 00 00       	cmp    $0x400,%eax
  802ebf:	75 d9                	jne    802e9a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802ec1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ec6:	5d                   	pop    %ebp
  802ec7:	c3                   	ret    

00802ec8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802ec8:	55                   	push   %ebp
  802ec9:	89 e5                	mov    %esp,%ebp
  802ecb:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ece:	89 d0                	mov    %edx,%eax
  802ed0:	c1 e8 16             	shr    $0x16,%eax
  802ed3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802eda:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802edf:	f6 c1 01             	test   $0x1,%cl
  802ee2:	74 1d                	je     802f01 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ee4:	c1 ea 0c             	shr    $0xc,%edx
  802ee7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802eee:	f6 c2 01             	test   $0x1,%dl
  802ef1:	74 0e                	je     802f01 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802ef3:	c1 ea 0c             	shr    $0xc,%edx
  802ef6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802efd:	ef 
  802efe:	0f b7 c0             	movzwl %ax,%eax
}
  802f01:	5d                   	pop    %ebp
  802f02:	c3                   	ret    
  802f03:	66 90                	xchg   %ax,%ax
  802f05:	66 90                	xchg   %ax,%ax
  802f07:	66 90                	xchg   %ax,%ax
  802f09:	66 90                	xchg   %ax,%ax
  802f0b:	66 90                	xchg   %ax,%ax
  802f0d:	66 90                	xchg   %ax,%ax
  802f0f:	90                   	nop

00802f10 <__udivdi3>:
  802f10:	55                   	push   %ebp
  802f11:	57                   	push   %edi
  802f12:	56                   	push   %esi
  802f13:	53                   	push   %ebx
  802f14:	83 ec 1c             	sub    $0x1c,%esp
  802f17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802f1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802f1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802f27:	85 f6                	test   %esi,%esi
  802f29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802f2d:	89 ca                	mov    %ecx,%edx
  802f2f:	89 f8                	mov    %edi,%eax
  802f31:	75 3d                	jne    802f70 <__udivdi3+0x60>
  802f33:	39 cf                	cmp    %ecx,%edi
  802f35:	0f 87 c5 00 00 00    	ja     803000 <__udivdi3+0xf0>
  802f3b:	85 ff                	test   %edi,%edi
  802f3d:	89 fd                	mov    %edi,%ebp
  802f3f:	75 0b                	jne    802f4c <__udivdi3+0x3c>
  802f41:	b8 01 00 00 00       	mov    $0x1,%eax
  802f46:	31 d2                	xor    %edx,%edx
  802f48:	f7 f7                	div    %edi
  802f4a:	89 c5                	mov    %eax,%ebp
  802f4c:	89 c8                	mov    %ecx,%eax
  802f4e:	31 d2                	xor    %edx,%edx
  802f50:	f7 f5                	div    %ebp
  802f52:	89 c1                	mov    %eax,%ecx
  802f54:	89 d8                	mov    %ebx,%eax
  802f56:	89 cf                	mov    %ecx,%edi
  802f58:	f7 f5                	div    %ebp
  802f5a:	89 c3                	mov    %eax,%ebx
  802f5c:	89 d8                	mov    %ebx,%eax
  802f5e:	89 fa                	mov    %edi,%edx
  802f60:	83 c4 1c             	add    $0x1c,%esp
  802f63:	5b                   	pop    %ebx
  802f64:	5e                   	pop    %esi
  802f65:	5f                   	pop    %edi
  802f66:	5d                   	pop    %ebp
  802f67:	c3                   	ret    
  802f68:	90                   	nop
  802f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802f70:	39 ce                	cmp    %ecx,%esi
  802f72:	77 74                	ja     802fe8 <__udivdi3+0xd8>
  802f74:	0f bd fe             	bsr    %esi,%edi
  802f77:	83 f7 1f             	xor    $0x1f,%edi
  802f7a:	0f 84 98 00 00 00    	je     803018 <__udivdi3+0x108>
  802f80:	bb 20 00 00 00       	mov    $0x20,%ebx
  802f85:	89 f9                	mov    %edi,%ecx
  802f87:	89 c5                	mov    %eax,%ebp
  802f89:	29 fb                	sub    %edi,%ebx
  802f8b:	d3 e6                	shl    %cl,%esi
  802f8d:	89 d9                	mov    %ebx,%ecx
  802f8f:	d3 ed                	shr    %cl,%ebp
  802f91:	89 f9                	mov    %edi,%ecx
  802f93:	d3 e0                	shl    %cl,%eax
  802f95:	09 ee                	or     %ebp,%esi
  802f97:	89 d9                	mov    %ebx,%ecx
  802f99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802f9d:	89 d5                	mov    %edx,%ebp
  802f9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802fa3:	d3 ed                	shr    %cl,%ebp
  802fa5:	89 f9                	mov    %edi,%ecx
  802fa7:	d3 e2                	shl    %cl,%edx
  802fa9:	89 d9                	mov    %ebx,%ecx
  802fab:	d3 e8                	shr    %cl,%eax
  802fad:	09 c2                	or     %eax,%edx
  802faf:	89 d0                	mov    %edx,%eax
  802fb1:	89 ea                	mov    %ebp,%edx
  802fb3:	f7 f6                	div    %esi
  802fb5:	89 d5                	mov    %edx,%ebp
  802fb7:	89 c3                	mov    %eax,%ebx
  802fb9:	f7 64 24 0c          	mull   0xc(%esp)
  802fbd:	39 d5                	cmp    %edx,%ebp
  802fbf:	72 10                	jb     802fd1 <__udivdi3+0xc1>
  802fc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  802fc5:	89 f9                	mov    %edi,%ecx
  802fc7:	d3 e6                	shl    %cl,%esi
  802fc9:	39 c6                	cmp    %eax,%esi
  802fcb:	73 07                	jae    802fd4 <__udivdi3+0xc4>
  802fcd:	39 d5                	cmp    %edx,%ebp
  802fcf:	75 03                	jne    802fd4 <__udivdi3+0xc4>
  802fd1:	83 eb 01             	sub    $0x1,%ebx
  802fd4:	31 ff                	xor    %edi,%edi
  802fd6:	89 d8                	mov    %ebx,%eax
  802fd8:	89 fa                	mov    %edi,%edx
  802fda:	83 c4 1c             	add    $0x1c,%esp
  802fdd:	5b                   	pop    %ebx
  802fde:	5e                   	pop    %esi
  802fdf:	5f                   	pop    %edi
  802fe0:	5d                   	pop    %ebp
  802fe1:	c3                   	ret    
  802fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802fe8:	31 ff                	xor    %edi,%edi
  802fea:	31 db                	xor    %ebx,%ebx
  802fec:	89 d8                	mov    %ebx,%eax
  802fee:	89 fa                	mov    %edi,%edx
  802ff0:	83 c4 1c             	add    $0x1c,%esp
  802ff3:	5b                   	pop    %ebx
  802ff4:	5e                   	pop    %esi
  802ff5:	5f                   	pop    %edi
  802ff6:	5d                   	pop    %ebp
  802ff7:	c3                   	ret    
  802ff8:	90                   	nop
  802ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803000:	89 d8                	mov    %ebx,%eax
  803002:	f7 f7                	div    %edi
  803004:	31 ff                	xor    %edi,%edi
  803006:	89 c3                	mov    %eax,%ebx
  803008:	89 d8                	mov    %ebx,%eax
  80300a:	89 fa                	mov    %edi,%edx
  80300c:	83 c4 1c             	add    $0x1c,%esp
  80300f:	5b                   	pop    %ebx
  803010:	5e                   	pop    %esi
  803011:	5f                   	pop    %edi
  803012:	5d                   	pop    %ebp
  803013:	c3                   	ret    
  803014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803018:	39 ce                	cmp    %ecx,%esi
  80301a:	72 0c                	jb     803028 <__udivdi3+0x118>
  80301c:	31 db                	xor    %ebx,%ebx
  80301e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803022:	0f 87 34 ff ff ff    	ja     802f5c <__udivdi3+0x4c>
  803028:	bb 01 00 00 00       	mov    $0x1,%ebx
  80302d:	e9 2a ff ff ff       	jmp    802f5c <__udivdi3+0x4c>
  803032:	66 90                	xchg   %ax,%ax
  803034:	66 90                	xchg   %ax,%ax
  803036:	66 90                	xchg   %ax,%ax
  803038:	66 90                	xchg   %ax,%ax
  80303a:	66 90                	xchg   %ax,%ax
  80303c:	66 90                	xchg   %ax,%ax
  80303e:	66 90                	xchg   %ax,%ax

00803040 <__umoddi3>:
  803040:	55                   	push   %ebp
  803041:	57                   	push   %edi
  803042:	56                   	push   %esi
  803043:	53                   	push   %ebx
  803044:	83 ec 1c             	sub    $0x1c,%esp
  803047:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80304b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80304f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803057:	85 d2                	test   %edx,%edx
  803059:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80305d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803061:	89 f3                	mov    %esi,%ebx
  803063:	89 3c 24             	mov    %edi,(%esp)
  803066:	89 74 24 04          	mov    %esi,0x4(%esp)
  80306a:	75 1c                	jne    803088 <__umoddi3+0x48>
  80306c:	39 f7                	cmp    %esi,%edi
  80306e:	76 50                	jbe    8030c0 <__umoddi3+0x80>
  803070:	89 c8                	mov    %ecx,%eax
  803072:	89 f2                	mov    %esi,%edx
  803074:	f7 f7                	div    %edi
  803076:	89 d0                	mov    %edx,%eax
  803078:	31 d2                	xor    %edx,%edx
  80307a:	83 c4 1c             	add    $0x1c,%esp
  80307d:	5b                   	pop    %ebx
  80307e:	5e                   	pop    %esi
  80307f:	5f                   	pop    %edi
  803080:	5d                   	pop    %ebp
  803081:	c3                   	ret    
  803082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803088:	39 f2                	cmp    %esi,%edx
  80308a:	89 d0                	mov    %edx,%eax
  80308c:	77 52                	ja     8030e0 <__umoddi3+0xa0>
  80308e:	0f bd ea             	bsr    %edx,%ebp
  803091:	83 f5 1f             	xor    $0x1f,%ebp
  803094:	75 5a                	jne    8030f0 <__umoddi3+0xb0>
  803096:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80309a:	0f 82 e0 00 00 00    	jb     803180 <__umoddi3+0x140>
  8030a0:	39 0c 24             	cmp    %ecx,(%esp)
  8030a3:	0f 86 d7 00 00 00    	jbe    803180 <__umoddi3+0x140>
  8030a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8030ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8030b1:	83 c4 1c             	add    $0x1c,%esp
  8030b4:	5b                   	pop    %ebx
  8030b5:	5e                   	pop    %esi
  8030b6:	5f                   	pop    %edi
  8030b7:	5d                   	pop    %ebp
  8030b8:	c3                   	ret    
  8030b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8030c0:	85 ff                	test   %edi,%edi
  8030c2:	89 fd                	mov    %edi,%ebp
  8030c4:	75 0b                	jne    8030d1 <__umoddi3+0x91>
  8030c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8030cb:	31 d2                	xor    %edx,%edx
  8030cd:	f7 f7                	div    %edi
  8030cf:	89 c5                	mov    %eax,%ebp
  8030d1:	89 f0                	mov    %esi,%eax
  8030d3:	31 d2                	xor    %edx,%edx
  8030d5:	f7 f5                	div    %ebp
  8030d7:	89 c8                	mov    %ecx,%eax
  8030d9:	f7 f5                	div    %ebp
  8030db:	89 d0                	mov    %edx,%eax
  8030dd:	eb 99                	jmp    803078 <__umoddi3+0x38>
  8030df:	90                   	nop
  8030e0:	89 c8                	mov    %ecx,%eax
  8030e2:	89 f2                	mov    %esi,%edx
  8030e4:	83 c4 1c             	add    $0x1c,%esp
  8030e7:	5b                   	pop    %ebx
  8030e8:	5e                   	pop    %esi
  8030e9:	5f                   	pop    %edi
  8030ea:	5d                   	pop    %ebp
  8030eb:	c3                   	ret    
  8030ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030f0:	8b 34 24             	mov    (%esp),%esi
  8030f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8030f8:	89 e9                	mov    %ebp,%ecx
  8030fa:	29 ef                	sub    %ebp,%edi
  8030fc:	d3 e0                	shl    %cl,%eax
  8030fe:	89 f9                	mov    %edi,%ecx
  803100:	89 f2                	mov    %esi,%edx
  803102:	d3 ea                	shr    %cl,%edx
  803104:	89 e9                	mov    %ebp,%ecx
  803106:	09 c2                	or     %eax,%edx
  803108:	89 d8                	mov    %ebx,%eax
  80310a:	89 14 24             	mov    %edx,(%esp)
  80310d:	89 f2                	mov    %esi,%edx
  80310f:	d3 e2                	shl    %cl,%edx
  803111:	89 f9                	mov    %edi,%ecx
  803113:	89 54 24 04          	mov    %edx,0x4(%esp)
  803117:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80311b:	d3 e8                	shr    %cl,%eax
  80311d:	89 e9                	mov    %ebp,%ecx
  80311f:	89 c6                	mov    %eax,%esi
  803121:	d3 e3                	shl    %cl,%ebx
  803123:	89 f9                	mov    %edi,%ecx
  803125:	89 d0                	mov    %edx,%eax
  803127:	d3 e8                	shr    %cl,%eax
  803129:	89 e9                	mov    %ebp,%ecx
  80312b:	09 d8                	or     %ebx,%eax
  80312d:	89 d3                	mov    %edx,%ebx
  80312f:	89 f2                	mov    %esi,%edx
  803131:	f7 34 24             	divl   (%esp)
  803134:	89 d6                	mov    %edx,%esi
  803136:	d3 e3                	shl    %cl,%ebx
  803138:	f7 64 24 04          	mull   0x4(%esp)
  80313c:	39 d6                	cmp    %edx,%esi
  80313e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803142:	89 d1                	mov    %edx,%ecx
  803144:	89 c3                	mov    %eax,%ebx
  803146:	72 08                	jb     803150 <__umoddi3+0x110>
  803148:	75 11                	jne    80315b <__umoddi3+0x11b>
  80314a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80314e:	73 0b                	jae    80315b <__umoddi3+0x11b>
  803150:	2b 44 24 04          	sub    0x4(%esp),%eax
  803154:	1b 14 24             	sbb    (%esp),%edx
  803157:	89 d1                	mov    %edx,%ecx
  803159:	89 c3                	mov    %eax,%ebx
  80315b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80315f:	29 da                	sub    %ebx,%edx
  803161:	19 ce                	sbb    %ecx,%esi
  803163:	89 f9                	mov    %edi,%ecx
  803165:	89 f0                	mov    %esi,%eax
  803167:	d3 e0                	shl    %cl,%eax
  803169:	89 e9                	mov    %ebp,%ecx
  80316b:	d3 ea                	shr    %cl,%edx
  80316d:	89 e9                	mov    %ebp,%ecx
  80316f:	d3 ee                	shr    %cl,%esi
  803171:	09 d0                	or     %edx,%eax
  803173:	89 f2                	mov    %esi,%edx
  803175:	83 c4 1c             	add    $0x1c,%esp
  803178:	5b                   	pop    %ebx
  803179:	5e                   	pop    %esi
  80317a:	5f                   	pop    %edi
  80317b:	5d                   	pop    %ebp
  80317c:	c3                   	ret    
  80317d:	8d 76 00             	lea    0x0(%esi),%esi
  803180:	29 f9                	sub    %edi,%ecx
  803182:	19 d6                	sbb    %edx,%esi
  803184:	89 74 24 04          	mov    %esi,0x4(%esp)
  803188:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80318c:	e9 18 ff ff ff       	jmp    8030a9 <__umoddi3+0x69>
