
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
  80005b:	68 40 32 80 00       	push   $0x803240
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
  80007f:	68 4f 32 80 00       	push   $0x80324f
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
  8000ab:	68 5d 32 80 00       	push   $0x80325d
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
  8000d8:	68 62 32 80 00       	push   $0x803262
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
  8000f6:	68 73 32 80 00       	push   $0x803273
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
  800126:	68 67 32 80 00       	push   $0x803267
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
  80014c:	68 6f 32 80 00       	push   $0x80326f
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
  80017b:	68 7b 32 80 00       	push   $0x80327b
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
  800273:	68 85 32 80 00       	push   $0x803285
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
  8002a7:	68 d0 33 80 00       	push   $0x8033d0
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
  8002c1:	e8 21 20 00 00       	call   8022e7 <open>
  8002c6:	89 c7                	mov    %eax,%edi
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	79 1b                	jns    8002ea <runcmd+0xe1>
				cprintf("open %s for read: %e", t, fd);
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	50                   	push   %eax
  8002d3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d6:	68 99 32 80 00       	push   $0x803299
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
  8002f8:	e8 4a 1a 00 00       	call   801d47 <dup>
				close(fd);
  8002fd:	89 3c 24             	mov    %edi,(%esp)
  800300:	e8 f2 19 00 00       	call   801cf7 <close>
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
  800323:	68 f8 33 80 00       	push   $0x8033f8
  800328:	e8 c1 07 00 00       	call   800aee <cprintf>
				exit();
  80032d:	e8 c9 06 00 00       	call   8009fb <exit>
  800332:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	68 01 03 00 00       	push   $0x301
  80033d:	ff 75 a4             	pushl  -0x5c(%ebp)
  800340:	e8 a2 1f 00 00       	call   8022e7 <open>
  800345:	89 c7                	mov    %eax,%edi
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 19                	jns    800367 <runcmd+0x15e>
				cprintf("open %s for write: %e", t, fd);
  80034e:	83 ec 04             	sub    $0x4,%esp
  800351:	50                   	push   %eax
  800352:	ff 75 a4             	pushl  -0x5c(%ebp)
  800355:	68 ae 32 80 00       	push   $0x8032ae
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
  800376:	e8 cc 19 00 00       	call   801d47 <dup>
				close(fd);
  80037b:	89 3c 24             	mov    %edi,(%esp)
  80037e:	e8 74 19 00 00       	call   801cf7 <close>
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	e9 9f fe ff ff       	jmp    80022a <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038b:	83 ec 0c             	sub    $0xc,%esp
  80038e:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800394:	50                   	push   %eax
  800395:	e8 8b 28 00 00       	call   802c25 <pipe>
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	85 c0                	test   %eax,%eax
  80039f:	79 16                	jns    8003b7 <runcmd+0x1ae>
				cprintf("pipe: %e", r);
  8003a1:	83 ec 08             	sub    $0x8,%esp
  8003a4:	50                   	push   %eax
  8003a5:	68 c4 32 80 00       	push   $0x8032c4
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
  8003cf:	68 cd 32 80 00       	push   $0x8032cd
  8003d4:	e8 15 07 00 00       	call   800aee <cprintf>
  8003d9:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003dc:	e8 2d 15 00 00       	call   80190e <fork>
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	79 16                	jns    8003fd <runcmd+0x1f4>
				cprintf("fork: %e", r);
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	50                   	push   %eax
  8003eb:	68 03 38 80 00       	push   $0x803803
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
  800411:	e8 31 19 00 00       	call   801d47 <dup>
					close(p[0]);
  800416:	83 c4 04             	add    $0x4,%esp
  800419:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041f:	e8 d3 18 00 00       	call   801cf7 <close>
  800424:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800430:	e8 c2 18 00 00       	call   801cf7 <close>
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
  80044e:	e8 f4 18 00 00       	call   801d47 <dup>
					close(p[1]);
  800453:	83 c4 04             	add    $0x4,%esp
  800456:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045c:	e8 96 18 00 00       	call   801cf7 <close>
  800461:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800464:	83 ec 0c             	sub    $0xc,%esp
  800467:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046d:	e8 85 18 00 00       	call   801cf7 <close>
				goto runit;
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	eb 17                	jmp    80048e <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800477:	50                   	push   %eax
  800478:	68 da 32 80 00       	push   $0x8032da
  80047d:	6a 78                	push   $0x78
  80047f:	68 f6 32 80 00       	push   $0x8032f6
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
  8004a2:	68 00 33 80 00       	push   $0x803300
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
  8004f0:	a1 24 54 80 00       	mov    0x805424,%eax
  8004f5:	8b 40 48             	mov    0x48(%eax),%eax
  8004f8:	83 ec 08             	sub    $0x8,%esp
  8004fb:	50                   	push   %eax
  8004fc:	68 0f 33 80 00       	push   $0x80330f
  800501:	e8 e8 05 00 00       	call   800aee <cprintf>
  800506:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb 11                	jmp    80051f <runcmd+0x316>
			cprintf(" %s", argv[i]);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	50                   	push   %eax
  800512:	68 97 33 80 00       	push   $0x803397
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
  80052c:	68 60 32 80 00       	push   $0x803260
  800531:	e8 b8 05 00 00       	call   800aee <cprintf>
  800536:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 a8             	pushl  -0x58(%ebp)
  800543:	e8 53 1f 00 00       	call   80249b <spawn>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	0f 89 c3 00 00 00    	jns    800618 <runcmd+0x40f>
		cprintf("spawn %s: %e\n", argv[0], r);
  800555:	83 ec 04             	sub    $0x4,%esp
  800558:	50                   	push   %eax
  800559:	ff 75 a8             	pushl  -0x58(%ebp)
  80055c:	68 1d 33 80 00       	push   $0x80331d
  800561:	e8 88 05 00 00       	call   800aee <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800566:	e8 b7 17 00 00       	call   801d22 <close_all>
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb 4c                	jmp    8005bc <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	53                   	push   %ebx
  800579:	ff 75 a8             	pushl  -0x58(%ebp)
  80057c:	50                   	push   %eax
  80057d:	68 2b 33 80 00       	push   $0x80332b
  800582:	e8 67 05 00 00       	call   800aee <cprintf>
  800587:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058a:	83 ec 0c             	sub    $0xc,%esp
  80058d:	53                   	push   %ebx
  80058e:	e8 18 28 00 00       	call   802dab <wait>
		if (debug)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059d:	0f 84 8c 00 00 00    	je     80062f <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a3:	a1 24 54 80 00       	mov    0x805424,%eax
  8005a8:	8b 40 48             	mov    0x48(%eax),%eax
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	50                   	push   %eax
  8005af:	68 40 33 80 00       	push   $0x803340
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
  8005c9:	a1 24 54 80 00       	mov    0x805424,%eax
  8005ce:	8b 40 48             	mov    0x48(%eax),%eax
  8005d1:	83 ec 04             	sub    $0x4,%esp
  8005d4:	57                   	push   %edi
  8005d5:	50                   	push   %eax
  8005d6:	68 56 33 80 00       	push   $0x803356
  8005db:	e8 0e 05 00 00       	call   800aee <cprintf>
  8005e0:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	57                   	push   %edi
  8005e7:	e8 bf 27 00 00       	call   802dab <wait>
		if (debug)
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f6:	74 19                	je     800611 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005f8:	a1 24 54 80 00       	mov    0x805424,%eax
  8005fd:	8b 40 48             	mov    0x48(%eax),%eax
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	50                   	push   %eax
  800604:	68 40 33 80 00       	push   $0x803340
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
  800618:	e8 05 17 00 00       	call   801d22 <close_all>
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
  800643:	68 20 34 80 00       	push   $0x803420
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
  80066c:	e8 92 13 00 00       	call   801a03 <argstart>
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
  8006b8:	e8 76 13 00 00       	call   801a33 <argnext>
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
  8006da:	e8 18 16 00 00       	call   801cf7 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006df:	83 c4 08             	add    $0x8,%esp
  8006e2:	6a 00                	push   $0x0
  8006e4:	ff 77 04             	pushl  0x4(%edi)
  8006e7:	e8 fb 1b 00 00       	call   8022e7 <open>
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	79 1b                	jns    80070e <umain+0xb7>
			panic("open %s: %e", argv[1], r);
  8006f3:	83 ec 0c             	sub    $0xc,%esp
  8006f6:	50                   	push   %eax
  8006f7:	ff 77 04             	pushl  0x4(%edi)
  8006fa:	68 73 33 80 00       	push   $0x803373
  8006ff:	68 28 01 00 00       	push   $0x128
  800704:	68 f6 32 80 00       	push   $0x8032f6
  800709:	e8 07 03 00 00       	call   800a15 <_panic>
		assert(r == 0);
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 19                	je     80072b <umain+0xd4>
  800712:	68 7f 33 80 00       	push   $0x80337f
  800717:	68 86 33 80 00       	push   $0x803386
  80071c:	68 29 01 00 00       	push   $0x129
  800721:	68 f6 32 80 00       	push   $0x8032f6
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
  800746:	bf 9b 33 80 00       	mov    $0x80339b,%edi
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
  80076c:	68 9e 33 80 00       	push   $0x80339e
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
  80078b:	68 a7 33 80 00       	push   $0x8033a7
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
  8007a7:	68 b1 33 80 00       	push   $0x8033b1
  8007ac:	e8 d4 1c 00 00       	call   802485 <printf>
  8007b1:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b4:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bb:	74 10                	je     8007cd <umain+0x176>
			cprintf("BEFORE FORK\n");
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	68 b7 33 80 00       	push   $0x8033b7
  8007c5:	e8 24 03 00 00       	call   800aee <cprintf>
  8007ca:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007cd:	e8 3c 11 00 00       	call   80190e <fork>
  8007d2:	89 c6                	mov    %eax,%esi
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	79 15                	jns    8007ed <umain+0x196>
			panic("fork: %e", r);
  8007d8:	50                   	push   %eax
  8007d9:	68 03 38 80 00       	push   $0x803803
  8007de:	68 40 01 00 00       	push   $0x140
  8007e3:	68 f6 32 80 00       	push   $0x8032f6
  8007e8:	e8 28 02 00 00       	call   800a15 <_panic>
		if (debug)
  8007ed:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f4:	74 11                	je     800807 <umain+0x1b0>
			cprintf("FORK: %d\n", r);
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	50                   	push   %eax
  8007fa:	68 c4 33 80 00       	push   $0x8033c4
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
  800825:	e8 81 25 00 00       	call   802dab <wait>
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
  800842:	68 41 34 80 00       	push   $0x803441
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
  800912:	e8 1c 15 00 00       	call   801e33 <read>
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
  80093c:	e8 8c 12 00 00       	call   801bcd <fd_lookup>
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
  800965:	e8 14 12 00 00       	call   801b7e <fd_alloc>
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
  8009a7:	e8 ab 11 00 00       	call   801b57 <fd2num>
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
  8009d2:	a3 24 54 80 00       	mov    %eax,0x805424

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
  800a01:	e8 1c 13 00 00       	call   801d22 <close_all>
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
  800a33:	68 58 34 80 00       	push   $0x803458
  800a38:	e8 b1 00 00 00       	call   800aee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3d:	83 c4 18             	add    $0x18,%esp
  800a40:	53                   	push   %ebx
  800a41:	ff 75 10             	pushl  0x10(%ebp)
  800a44:	e8 54 00 00 00       	call   800a9d <vcprintf>
	cprintf("\n");
  800a49:	c7 04 24 60 32 80 00 	movl   $0x803260,(%esp)
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
  800b51:	e8 5a 24 00 00       	call   802fb0 <__udivdi3>
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
  800b94:	e8 47 25 00 00       	call   8030e0 <__umoddi3>
  800b99:	83 c4 14             	add    $0x14,%esp
  800b9c:	0f be 80 7b 34 80 00 	movsbl 0x80347b(%eax),%eax
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
  800c98:	ff 24 85 c0 35 80 00 	jmp    *0x8035c0(,%eax,4)
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
  800d5c:	8b 14 85 20 37 80 00 	mov    0x803720(,%eax,4),%edx
  800d63:	85 d2                	test   %edx,%edx
  800d65:	75 18                	jne    800d7f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800d67:	50                   	push   %eax
  800d68:	68 93 34 80 00       	push   $0x803493
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
  800d80:	68 98 33 80 00       	push   $0x803398
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
  800da4:	b8 8c 34 80 00       	mov    $0x80348c,%eax
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
  80104e:	68 98 33 80 00       	push   $0x803398
  801053:	6a 01                	push   $0x1
  801055:	e8 14 14 00 00       	call   80246e <fprintf>
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
  80108e:	68 7f 37 80 00       	push   $0x80377f
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
  801512:	68 8f 37 80 00       	push   $0x80378f
  801517:	6a 23                	push   $0x23
  801519:	68 ac 37 80 00       	push   $0x8037ac
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
  801593:	68 8f 37 80 00       	push   $0x80378f
  801598:	6a 23                	push   $0x23
  80159a:	68 ac 37 80 00       	push   $0x8037ac
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
  8015d5:	68 8f 37 80 00       	push   $0x80378f
  8015da:	6a 23                	push   $0x23
  8015dc:	68 ac 37 80 00       	push   $0x8037ac
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
  801617:	68 8f 37 80 00       	push   $0x80378f
  80161c:	6a 23                	push   $0x23
  80161e:	68 ac 37 80 00       	push   $0x8037ac
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
  801659:	68 8f 37 80 00       	push   $0x80378f
  80165e:	6a 23                	push   $0x23
  801660:	68 ac 37 80 00       	push   $0x8037ac
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
  80169b:	68 8f 37 80 00       	push   $0x80378f
  8016a0:	6a 23                	push   $0x23
  8016a2:	68 ac 37 80 00       	push   $0x8037ac
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
  8016dd:	68 8f 37 80 00       	push   $0x80378f
  8016e2:	6a 23                	push   $0x23
  8016e4:	68 ac 37 80 00       	push   $0x8037ac
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
  801741:	68 8f 37 80 00       	push   $0x80378f
  801746:	6a 23                	push   $0x23
  801748:	68 ac 37 80 00       	push   $0x8037ac
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

0080175a <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	53                   	push   %ebx
  80175e:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  801761:	89 d3                	mov    %edx,%ebx
  801763:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  801766:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  80176d:	f6 c5 04             	test   $0x4,%ch
  801770:	74 38                	je     8017aa <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  801772:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801779:	83 ec 0c             	sub    $0xc,%esp
  80177c:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  801782:	52                   	push   %edx
  801783:	53                   	push   %ebx
  801784:	50                   	push   %eax
  801785:	53                   	push   %ebx
  801786:	6a 00                	push   $0x0
  801788:	e8 1f fe ff ff       	call   8015ac <sys_page_map>
  80178d:	83 c4 20             	add    $0x20,%esp
  801790:	85 c0                	test   %eax,%eax
  801792:	0f 89 b8 00 00 00    	jns    801850 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  801798:	50                   	push   %eax
  801799:	68 ba 37 80 00       	push   $0x8037ba
  80179e:	6a 4e                	push   $0x4e
  8017a0:	68 cb 37 80 00       	push   $0x8037cb
  8017a5:	e8 6b f2 ff ff       	call   800a15 <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  8017aa:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8017b1:	f6 c1 02             	test   $0x2,%cl
  8017b4:	75 0c                	jne    8017c2 <duppage+0x68>
  8017b6:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  8017bd:	f6 c5 08             	test   $0x8,%ch
  8017c0:	74 57                	je     801819 <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  8017c2:	83 ec 0c             	sub    $0xc,%esp
  8017c5:	68 05 08 00 00       	push   $0x805
  8017ca:	53                   	push   %ebx
  8017cb:	50                   	push   %eax
  8017cc:	53                   	push   %ebx
  8017cd:	6a 00                	push   $0x0
  8017cf:	e8 d8 fd ff ff       	call   8015ac <sys_page_map>
  8017d4:	83 c4 20             	add    $0x20,%esp
  8017d7:	85 c0                	test   %eax,%eax
  8017d9:	79 12                	jns    8017ed <duppage+0x93>
			panic("sys_page_map: %e", r);
  8017db:	50                   	push   %eax
  8017dc:	68 ba 37 80 00       	push   $0x8037ba
  8017e1:	6a 56                	push   $0x56
  8017e3:	68 cb 37 80 00       	push   $0x8037cb
  8017e8:	e8 28 f2 ff ff       	call   800a15 <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  8017ed:	83 ec 0c             	sub    $0xc,%esp
  8017f0:	68 05 08 00 00       	push   $0x805
  8017f5:	53                   	push   %ebx
  8017f6:	6a 00                	push   $0x0
  8017f8:	53                   	push   %ebx
  8017f9:	6a 00                	push   $0x0
  8017fb:	e8 ac fd ff ff       	call   8015ac <sys_page_map>
  801800:	83 c4 20             	add    $0x20,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	79 49                	jns    801850 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  801807:	50                   	push   %eax
  801808:	68 ba 37 80 00       	push   $0x8037ba
  80180d:	6a 58                	push   $0x58
  80180f:	68 cb 37 80 00       	push   $0x8037cb
  801814:	e8 fc f1 ff ff       	call   800a15 <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  801819:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801820:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  801826:	75 28                	jne    801850 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  801828:	83 ec 0c             	sub    $0xc,%esp
  80182b:	6a 05                	push   $0x5
  80182d:	53                   	push   %ebx
  80182e:	50                   	push   %eax
  80182f:	53                   	push   %ebx
  801830:	6a 00                	push   $0x0
  801832:	e8 75 fd ff ff       	call   8015ac <sys_page_map>
  801837:	83 c4 20             	add    $0x20,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	79 12                	jns    801850 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  80183e:	50                   	push   %eax
  80183f:	68 ba 37 80 00       	push   $0x8037ba
  801844:	6a 5e                	push   $0x5e
  801846:	68 cb 37 80 00       	push   $0x8037cb
  80184b:	e8 c5 f1 ff ff       	call   800a15 <_panic>
	}
	return 0;
}
  801850:	b8 00 00 00 00       	mov    $0x0,%eax
  801855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	53                   	push   %ebx
  80185e:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  801866:	89 d8                	mov    %ebx,%eax
  801868:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  80186b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801872:	6a 07                	push   $0x7
  801874:	68 00 f0 7f 00       	push   $0x7ff000
  801879:	6a 00                	push   $0x0
  80187b:	e8 e9 fc ff ff       	call   801569 <sys_page_alloc>
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	85 c0                	test   %eax,%eax
  801885:	79 12                	jns    801899 <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  801887:	50                   	push   %eax
  801888:	68 d6 37 80 00       	push   $0x8037d6
  80188d:	6a 2b                	push   $0x2b
  80188f:	68 cb 37 80 00       	push   $0x8037cb
  801894:	e8 7c f1 ff ff       	call   800a15 <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  801899:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  80189f:	83 ec 04             	sub    $0x4,%esp
  8018a2:	68 00 10 00 00       	push   $0x1000
  8018a7:	53                   	push   %ebx
  8018a8:	68 00 f0 7f 00       	push   $0x7ff000
  8018ad:	e8 46 fa ff ff       	call   8012f8 <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  8018b2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018b9:	53                   	push   %ebx
  8018ba:	6a 00                	push   $0x0
  8018bc:	68 00 f0 7f 00       	push   $0x7ff000
  8018c1:	6a 00                	push   $0x0
  8018c3:	e8 e4 fc ff ff       	call   8015ac <sys_page_map>
  8018c8:	83 c4 20             	add    $0x20,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	79 12                	jns    8018e1 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  8018cf:	50                   	push   %eax
  8018d0:	68 ba 37 80 00       	push   $0x8037ba
  8018d5:	6a 33                	push   $0x33
  8018d7:	68 cb 37 80 00       	push   $0x8037cb
  8018dc:	e8 34 f1 ff ff       	call   800a15 <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	68 00 f0 7f 00       	push   $0x7ff000
  8018e9:	6a 00                	push   $0x0
  8018eb:	e8 fe fc ff ff       	call   8015ee <sys_page_unmap>
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	79 12                	jns    801909 <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  8018f7:	50                   	push   %eax
  8018f8:	68 e9 37 80 00       	push   $0x8037e9
  8018fd:	6a 37                	push   $0x37
  8018ff:	68 cb 37 80 00       	push   $0x8037cb
  801904:	e8 0c f1 ff ff       	call   800a15 <_panic>
}
  801909:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  801916:	68 5a 18 80 00       	push   $0x80185a
  80191b:	e8 da 14 00 00       	call   802dfa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801920:	b8 07 00 00 00       	mov    $0x7,%eax
  801925:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  801927:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	85 c0                	test   %eax,%eax
  80192f:	79 12                	jns    801943 <fork+0x35>
		panic("sys_exofork: %e", envid);
  801931:	50                   	push   %eax
  801932:	68 fc 37 80 00       	push   $0x8037fc
  801937:	6a 7c                	push   $0x7c
  801939:	68 cb 37 80 00       	push   $0x8037cb
  80193e:	e8 d2 f0 ff ff       	call   800a15 <_panic>
		return envid;
	}
	if (envid == 0) {
  801943:	85 c0                	test   %eax,%eax
  801945:	75 1e                	jne    801965 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  801947:	e8 df fb ff ff       	call   80152b <sys_getenvid>
  80194c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801951:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801954:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801959:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  80195e:	b8 00 00 00 00       	mov    $0x0,%eax
  801963:	eb 7d                	jmp    8019e2 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801965:	83 ec 04             	sub    $0x4,%esp
  801968:	6a 07                	push   $0x7
  80196a:	68 00 f0 bf ee       	push   $0xeebff000
  80196f:	50                   	push   %eax
  801970:	e8 f4 fb ff ff       	call   801569 <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801975:	83 c4 08             	add    $0x8,%esp
  801978:	68 3f 2e 80 00       	push   $0x802e3f
  80197d:	ff 75 f4             	pushl  -0xc(%ebp)
  801980:	e8 2f fd ff ff       	call   8016b4 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801985:	be 04 70 80 00       	mov    $0x807004,%esi
  80198a:	c1 ee 0c             	shr    $0xc,%esi
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	bb 00 08 00 00       	mov    $0x800,%ebx
  801995:	eb 0d                	jmp    8019a4 <fork+0x96>
		duppage(envid, pn);
  801997:	89 da                	mov    %ebx,%edx
  801999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199c:	e8 b9 fd ff ff       	call   80175a <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  8019a1:	83 c3 01             	add    $0x1,%ebx
  8019a4:	39 f3                	cmp    %esi,%ebx
  8019a6:	76 ef                	jbe    801997 <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  8019a8:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019ab:	c1 ea 0c             	shr    $0xc,%edx
  8019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b1:	e8 a4 fd ff ff       	call   80175a <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8019b6:	83 ec 08             	sub    $0x8,%esp
  8019b9:	6a 02                	push   $0x2
  8019bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019be:	e8 6d fc ff ff       	call   801630 <sys_env_set_status>
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	79 15                	jns    8019df <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  8019ca:	50                   	push   %eax
  8019cb:	68 0c 38 80 00       	push   $0x80380c
  8019d0:	68 9c 00 00 00       	push   $0x9c
  8019d5:	68 cb 37 80 00       	push   $0x8037cb
  8019da:	e8 36 f0 ff ff       	call   800a15 <_panic>
		return r;
	}

	return envid;
  8019df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8019e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <sfork>:

// Challenge!
int
sfork(void)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8019ef:	68 23 38 80 00       	push   $0x803823
  8019f4:	68 a7 00 00 00       	push   $0xa7
  8019f9:	68 cb 37 80 00       	push   $0x8037cb
  8019fe:	e8 12 f0 ff ff       	call   800a15 <_panic>

00801a03 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	8b 55 08             	mov    0x8(%ebp),%edx
  801a09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a0c:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a0f:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a11:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a14:	83 3a 01             	cmpl   $0x1,(%edx)
  801a17:	7e 09                	jle    801a22 <argstart+0x1f>
  801a19:	ba 61 32 80 00       	mov    $0x803261,%edx
  801a1e:	85 c9                	test   %ecx,%ecx
  801a20:	75 05                	jne    801a27 <argstart+0x24>
  801a22:	ba 00 00 00 00       	mov    $0x0,%edx
  801a27:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801a2a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <argnext>:

int
argnext(struct Argstate *args)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	53                   	push   %ebx
  801a37:	83 ec 04             	sub    $0x4,%esp
  801a3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801a3d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801a44:	8b 43 08             	mov    0x8(%ebx),%eax
  801a47:	85 c0                	test   %eax,%eax
  801a49:	74 6f                	je     801aba <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801a4b:	80 38 00             	cmpb   $0x0,(%eax)
  801a4e:	75 4e                	jne    801a9e <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801a50:	8b 0b                	mov    (%ebx),%ecx
  801a52:	83 39 01             	cmpl   $0x1,(%ecx)
  801a55:	74 55                	je     801aac <argnext+0x79>
		    || args->argv[1][0] != '-'
  801a57:	8b 53 04             	mov    0x4(%ebx),%edx
  801a5a:	8b 42 04             	mov    0x4(%edx),%eax
  801a5d:	80 38 2d             	cmpb   $0x2d,(%eax)
  801a60:	75 4a                	jne    801aac <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801a62:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801a66:	74 44                	je     801aac <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801a68:	83 c0 01             	add    $0x1,%eax
  801a6b:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801a6e:	83 ec 04             	sub    $0x4,%esp
  801a71:	8b 01                	mov    (%ecx),%eax
  801a73:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801a7a:	50                   	push   %eax
  801a7b:	8d 42 08             	lea    0x8(%edx),%eax
  801a7e:	50                   	push   %eax
  801a7f:	83 c2 04             	add    $0x4,%edx
  801a82:	52                   	push   %edx
  801a83:	e8 70 f8 ff ff       	call   8012f8 <memmove>
		(*args->argc)--;
  801a88:	8b 03                	mov    (%ebx),%eax
  801a8a:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801a8d:	8b 43 08             	mov    0x8(%ebx),%eax
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	80 38 2d             	cmpb   $0x2d,(%eax)
  801a96:	75 06                	jne    801a9e <argnext+0x6b>
  801a98:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801a9c:	74 0e                	je     801aac <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801a9e:	8b 53 08             	mov    0x8(%ebx),%edx
  801aa1:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801aa4:	83 c2 01             	add    $0x1,%edx
  801aa7:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801aaa:	eb 13                	jmp    801abf <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801aac:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801ab3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ab8:	eb 05                	jmp    801abf <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801aba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801abf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac2:	c9                   	leave  
  801ac3:	c3                   	ret    

00801ac4 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 04             	sub    $0x4,%esp
  801acb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801ace:	8b 43 08             	mov    0x8(%ebx),%eax
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	74 58                	je     801b2d <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801ad5:	80 38 00             	cmpb   $0x0,(%eax)
  801ad8:	74 0c                	je     801ae6 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801ada:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801add:	c7 43 08 61 32 80 00 	movl   $0x803261,0x8(%ebx)
  801ae4:	eb 42                	jmp    801b28 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801ae6:	8b 13                	mov    (%ebx),%edx
  801ae8:	83 3a 01             	cmpl   $0x1,(%edx)
  801aeb:	7e 2d                	jle    801b1a <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801aed:	8b 43 04             	mov    0x4(%ebx),%eax
  801af0:	8b 48 04             	mov    0x4(%eax),%ecx
  801af3:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801af6:	83 ec 04             	sub    $0x4,%esp
  801af9:	8b 12                	mov    (%edx),%edx
  801afb:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b02:	52                   	push   %edx
  801b03:	8d 50 08             	lea    0x8(%eax),%edx
  801b06:	52                   	push   %edx
  801b07:	83 c0 04             	add    $0x4,%eax
  801b0a:	50                   	push   %eax
  801b0b:	e8 e8 f7 ff ff       	call   8012f8 <memmove>
		(*args->argc)--;
  801b10:	8b 03                	mov    (%ebx),%eax
  801b12:	83 28 01             	subl   $0x1,(%eax)
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	eb 0e                	jmp    801b28 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801b1a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b21:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801b28:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b2b:	eb 05                	jmp    801b32 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801b32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b35:	c9                   	leave  
  801b36:	c3                   	ret    

00801b37 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	83 ec 08             	sub    $0x8,%esp
  801b3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801b40:	8b 51 0c             	mov    0xc(%ecx),%edx
  801b43:	89 d0                	mov    %edx,%eax
  801b45:	85 d2                	test   %edx,%edx
  801b47:	75 0c                	jne    801b55 <argvalue+0x1e>
  801b49:	83 ec 0c             	sub    $0xc,%esp
  801b4c:	51                   	push   %ecx
  801b4d:	e8 72 ff ff ff       	call   801ac4 <argnextvalue>
  801b52:	83 c4 10             	add    $0x10,%esp
}
  801b55:	c9                   	leave  
  801b56:	c3                   	ret    

00801b57 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	05 00 00 00 30       	add    $0x30000000,%eax
  801b62:	c1 e8 0c             	shr    $0xc,%eax
}
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801b6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6d:	05 00 00 00 30       	add    $0x30000000,%eax
  801b72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801b77:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b84:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801b89:	89 c2                	mov    %eax,%edx
  801b8b:	c1 ea 16             	shr    $0x16,%edx
  801b8e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801b95:	f6 c2 01             	test   $0x1,%dl
  801b98:	74 11                	je     801bab <fd_alloc+0x2d>
  801b9a:	89 c2                	mov    %eax,%edx
  801b9c:	c1 ea 0c             	shr    $0xc,%edx
  801b9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ba6:	f6 c2 01             	test   $0x1,%dl
  801ba9:	75 09                	jne    801bb4 <fd_alloc+0x36>
			*fd_store = fd;
  801bab:	89 01                	mov    %eax,(%ecx)
			return 0;
  801bad:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb2:	eb 17                	jmp    801bcb <fd_alloc+0x4d>
  801bb4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801bb9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801bbe:	75 c9                	jne    801b89 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801bc0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801bc6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801bd3:	83 f8 1f             	cmp    $0x1f,%eax
  801bd6:	77 36                	ja     801c0e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801bd8:	c1 e0 0c             	shl    $0xc,%eax
  801bdb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801be0:	89 c2                	mov    %eax,%edx
  801be2:	c1 ea 16             	shr    $0x16,%edx
  801be5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bec:	f6 c2 01             	test   $0x1,%dl
  801bef:	74 24                	je     801c15 <fd_lookup+0x48>
  801bf1:	89 c2                	mov    %eax,%edx
  801bf3:	c1 ea 0c             	shr    $0xc,%edx
  801bf6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801bfd:	f6 c2 01             	test   $0x1,%dl
  801c00:	74 1a                	je     801c1c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c05:	89 02                	mov    %eax,(%edx)
	return 0;
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0c:	eb 13                	jmp    801c21 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c13:	eb 0c                	jmp    801c21 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c1a:	eb 05                	jmp    801c21 <fd_lookup+0x54>
  801c1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	83 ec 08             	sub    $0x8,%esp
  801c29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2c:	ba b8 38 80 00       	mov    $0x8038b8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801c31:	eb 13                	jmp    801c46 <dev_lookup+0x23>
  801c33:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801c36:	39 08                	cmp    %ecx,(%eax)
  801c38:	75 0c                	jne    801c46 <dev_lookup+0x23>
			*dev = devtab[i];
  801c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3d:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c44:	eb 2e                	jmp    801c74 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801c46:	8b 02                	mov    (%edx),%eax
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	75 e7                	jne    801c33 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801c4c:	a1 24 54 80 00       	mov    0x805424,%eax
  801c51:	8b 40 48             	mov    0x48(%eax),%eax
  801c54:	83 ec 04             	sub    $0x4,%esp
  801c57:	51                   	push   %ecx
  801c58:	50                   	push   %eax
  801c59:	68 3c 38 80 00       	push   $0x80383c
  801c5e:	e8 8b ee ff ff       	call   800aee <cprintf>
	*dev = 0;
  801c63:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    

00801c76 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 10             	sub    $0x10,%esp
  801c7e:	8b 75 08             	mov    0x8(%ebp),%esi
  801c81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801c84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c87:	50                   	push   %eax
  801c88:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801c8e:	c1 e8 0c             	shr    $0xc,%eax
  801c91:	50                   	push   %eax
  801c92:	e8 36 ff ff ff       	call   801bcd <fd_lookup>
  801c97:	83 c4 08             	add    $0x8,%esp
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	78 05                	js     801ca3 <fd_close+0x2d>
	    || fd != fd2)
  801c9e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801ca1:	74 0c                	je     801caf <fd_close+0x39>
		return (must_exist ? r : 0);
  801ca3:	84 db                	test   %bl,%bl
  801ca5:	ba 00 00 00 00       	mov    $0x0,%edx
  801caa:	0f 44 c2             	cmove  %edx,%eax
  801cad:	eb 41                	jmp    801cf0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801caf:	83 ec 08             	sub    $0x8,%esp
  801cb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb5:	50                   	push   %eax
  801cb6:	ff 36                	pushl  (%esi)
  801cb8:	e8 66 ff ff ff       	call   801c23 <dev_lookup>
  801cbd:	89 c3                	mov    %eax,%ebx
  801cbf:	83 c4 10             	add    $0x10,%esp
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	78 1a                	js     801ce0 <fd_close+0x6a>
		if (dev->dev_close)
  801cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	74 0b                	je     801ce0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	56                   	push   %esi
  801cd9:	ff d0                	call   *%eax
  801cdb:	89 c3                	mov    %eax,%ebx
  801cdd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ce0:	83 ec 08             	sub    $0x8,%esp
  801ce3:	56                   	push   %esi
  801ce4:	6a 00                	push   $0x0
  801ce6:	e8 03 f9 ff ff       	call   8015ee <sys_page_unmap>
	return r;
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	89 d8                	mov    %ebx,%eax
}
  801cf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    

00801cf7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cfd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d00:	50                   	push   %eax
  801d01:	ff 75 08             	pushl  0x8(%ebp)
  801d04:	e8 c4 fe ff ff       	call   801bcd <fd_lookup>
  801d09:	83 c4 08             	add    $0x8,%esp
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 10                	js     801d20 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801d10:	83 ec 08             	sub    $0x8,%esp
  801d13:	6a 01                	push   $0x1
  801d15:	ff 75 f4             	pushl  -0xc(%ebp)
  801d18:	e8 59 ff ff ff       	call   801c76 <fd_close>
  801d1d:	83 c4 10             	add    $0x10,%esp
}
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <close_all>:

void
close_all(void)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	53                   	push   %ebx
  801d26:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d29:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	53                   	push   %ebx
  801d32:	e8 c0 ff ff ff       	call   801cf7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d37:	83 c3 01             	add    $0x1,%ebx
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	83 fb 20             	cmp    $0x20,%ebx
  801d40:	75 ec                	jne    801d2e <close_all+0xc>
		close(i);
}
  801d42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	57                   	push   %edi
  801d4b:	56                   	push   %esi
  801d4c:	53                   	push   %ebx
  801d4d:	83 ec 2c             	sub    $0x2c,%esp
  801d50:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801d53:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801d56:	50                   	push   %eax
  801d57:	ff 75 08             	pushl  0x8(%ebp)
  801d5a:	e8 6e fe ff ff       	call   801bcd <fd_lookup>
  801d5f:	83 c4 08             	add    $0x8,%esp
  801d62:	85 c0                	test   %eax,%eax
  801d64:	0f 88 c1 00 00 00    	js     801e2b <dup+0xe4>
		return r;
	close(newfdnum);
  801d6a:	83 ec 0c             	sub    $0xc,%esp
  801d6d:	56                   	push   %esi
  801d6e:	e8 84 ff ff ff       	call   801cf7 <close>

	newfd = INDEX2FD(newfdnum);
  801d73:	89 f3                	mov    %esi,%ebx
  801d75:	c1 e3 0c             	shl    $0xc,%ebx
  801d78:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801d7e:	83 c4 04             	add    $0x4,%esp
  801d81:	ff 75 e4             	pushl  -0x1c(%ebp)
  801d84:	e8 de fd ff ff       	call   801b67 <fd2data>
  801d89:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801d8b:	89 1c 24             	mov    %ebx,(%esp)
  801d8e:	e8 d4 fd ff ff       	call   801b67 <fd2data>
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801d99:	89 f8                	mov    %edi,%eax
  801d9b:	c1 e8 16             	shr    $0x16,%eax
  801d9e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801da5:	a8 01                	test   $0x1,%al
  801da7:	74 37                	je     801de0 <dup+0x99>
  801da9:	89 f8                	mov    %edi,%eax
  801dab:	c1 e8 0c             	shr    $0xc,%eax
  801dae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801db5:	f6 c2 01             	test   $0x1,%dl
  801db8:	74 26                	je     801de0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801dba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dc1:	83 ec 0c             	sub    $0xc,%esp
  801dc4:	25 07 0e 00 00       	and    $0xe07,%eax
  801dc9:	50                   	push   %eax
  801dca:	ff 75 d4             	pushl  -0x2c(%ebp)
  801dcd:	6a 00                	push   $0x0
  801dcf:	57                   	push   %edi
  801dd0:	6a 00                	push   $0x0
  801dd2:	e8 d5 f7 ff ff       	call   8015ac <sys_page_map>
  801dd7:	89 c7                	mov    %eax,%edi
  801dd9:	83 c4 20             	add    $0x20,%esp
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 2e                	js     801e0e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801de0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801de3:	89 d0                	mov    %edx,%eax
  801de5:	c1 e8 0c             	shr    $0xc,%eax
  801de8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801def:	83 ec 0c             	sub    $0xc,%esp
  801df2:	25 07 0e 00 00       	and    $0xe07,%eax
  801df7:	50                   	push   %eax
  801df8:	53                   	push   %ebx
  801df9:	6a 00                	push   $0x0
  801dfb:	52                   	push   %edx
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 a9 f7 ff ff       	call   8015ac <sys_page_map>
  801e03:	89 c7                	mov    %eax,%edi
  801e05:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e08:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e0a:	85 ff                	test   %edi,%edi
  801e0c:	79 1d                	jns    801e2b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e0e:	83 ec 08             	sub    $0x8,%esp
  801e11:	53                   	push   %ebx
  801e12:	6a 00                	push   $0x0
  801e14:	e8 d5 f7 ff ff       	call   8015ee <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e19:	83 c4 08             	add    $0x8,%esp
  801e1c:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e1f:	6a 00                	push   $0x0
  801e21:	e8 c8 f7 ff ff       	call   8015ee <sys_page_unmap>
	return r;
  801e26:	83 c4 10             	add    $0x10,%esp
  801e29:	89 f8                	mov    %edi,%eax
}
  801e2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5e                   	pop    %esi
  801e30:	5f                   	pop    %edi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	53                   	push   %ebx
  801e37:	83 ec 14             	sub    $0x14,%esp
  801e3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e40:	50                   	push   %eax
  801e41:	53                   	push   %ebx
  801e42:	e8 86 fd ff ff       	call   801bcd <fd_lookup>
  801e47:	83 c4 08             	add    $0x8,%esp
  801e4a:	89 c2                	mov    %eax,%edx
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	78 6d                	js     801ebd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e50:	83 ec 08             	sub    $0x8,%esp
  801e53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e56:	50                   	push   %eax
  801e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e5a:	ff 30                	pushl  (%eax)
  801e5c:	e8 c2 fd ff ff       	call   801c23 <dev_lookup>
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	85 c0                	test   %eax,%eax
  801e66:	78 4c                	js     801eb4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801e68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e6b:	8b 42 08             	mov    0x8(%edx),%eax
  801e6e:	83 e0 03             	and    $0x3,%eax
  801e71:	83 f8 01             	cmp    $0x1,%eax
  801e74:	75 21                	jne    801e97 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801e76:	a1 24 54 80 00       	mov    0x805424,%eax
  801e7b:	8b 40 48             	mov    0x48(%eax),%eax
  801e7e:	83 ec 04             	sub    $0x4,%esp
  801e81:	53                   	push   %ebx
  801e82:	50                   	push   %eax
  801e83:	68 7d 38 80 00       	push   $0x80387d
  801e88:	e8 61 ec ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801e8d:	83 c4 10             	add    $0x10,%esp
  801e90:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801e95:	eb 26                	jmp    801ebd <read+0x8a>
	}
	if (!dev->dev_read)
  801e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e9a:	8b 40 08             	mov    0x8(%eax),%eax
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	74 17                	je     801eb8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ea1:	83 ec 04             	sub    $0x4,%esp
  801ea4:	ff 75 10             	pushl  0x10(%ebp)
  801ea7:	ff 75 0c             	pushl  0xc(%ebp)
  801eaa:	52                   	push   %edx
  801eab:	ff d0                	call   *%eax
  801ead:	89 c2                	mov    %eax,%edx
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	eb 09                	jmp    801ebd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801eb4:	89 c2                	mov    %eax,%edx
  801eb6:	eb 05                	jmp    801ebd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801eb8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801ebd:	89 d0                	mov    %edx,%eax
  801ebf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	57                   	push   %edi
  801ec8:	56                   	push   %esi
  801ec9:	53                   	push   %ebx
  801eca:	83 ec 0c             	sub    $0xc,%esp
  801ecd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ed3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ed8:	eb 21                	jmp    801efb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801eda:	83 ec 04             	sub    $0x4,%esp
  801edd:	89 f0                	mov    %esi,%eax
  801edf:	29 d8                	sub    %ebx,%eax
  801ee1:	50                   	push   %eax
  801ee2:	89 d8                	mov    %ebx,%eax
  801ee4:	03 45 0c             	add    0xc(%ebp),%eax
  801ee7:	50                   	push   %eax
  801ee8:	57                   	push   %edi
  801ee9:	e8 45 ff ff ff       	call   801e33 <read>
		if (m < 0)
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	78 10                	js     801f05 <readn+0x41>
			return m;
		if (m == 0)
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	74 0a                	je     801f03 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ef9:	01 c3                	add    %eax,%ebx
  801efb:	39 f3                	cmp    %esi,%ebx
  801efd:	72 db                	jb     801eda <readn+0x16>
  801eff:	89 d8                	mov    %ebx,%eax
  801f01:	eb 02                	jmp    801f05 <readn+0x41>
  801f03:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f08:	5b                   	pop    %ebx
  801f09:	5e                   	pop    %esi
  801f0a:	5f                   	pop    %edi
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    

00801f0d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	53                   	push   %ebx
  801f11:	83 ec 14             	sub    $0x14,%esp
  801f14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f17:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f1a:	50                   	push   %eax
  801f1b:	53                   	push   %ebx
  801f1c:	e8 ac fc ff ff       	call   801bcd <fd_lookup>
  801f21:	83 c4 08             	add    $0x8,%esp
  801f24:	89 c2                	mov    %eax,%edx
  801f26:	85 c0                	test   %eax,%eax
  801f28:	78 68                	js     801f92 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f2a:	83 ec 08             	sub    $0x8,%esp
  801f2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f30:	50                   	push   %eax
  801f31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f34:	ff 30                	pushl  (%eax)
  801f36:	e8 e8 fc ff ff       	call   801c23 <dev_lookup>
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	78 47                	js     801f89 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801f42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f45:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801f49:	75 21                	jne    801f6c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801f4b:	a1 24 54 80 00       	mov    0x805424,%eax
  801f50:	8b 40 48             	mov    0x48(%eax),%eax
  801f53:	83 ec 04             	sub    $0x4,%esp
  801f56:	53                   	push   %ebx
  801f57:	50                   	push   %eax
  801f58:	68 99 38 80 00       	push   $0x803899
  801f5d:	e8 8c eb ff ff       	call   800aee <cprintf>
		return -E_INVAL;
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801f6a:	eb 26                	jmp    801f92 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801f6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f6f:	8b 52 0c             	mov    0xc(%edx),%edx
  801f72:	85 d2                	test   %edx,%edx
  801f74:	74 17                	je     801f8d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801f76:	83 ec 04             	sub    $0x4,%esp
  801f79:	ff 75 10             	pushl  0x10(%ebp)
  801f7c:	ff 75 0c             	pushl  0xc(%ebp)
  801f7f:	50                   	push   %eax
  801f80:	ff d2                	call   *%edx
  801f82:	89 c2                	mov    %eax,%edx
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	eb 09                	jmp    801f92 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f89:	89 c2                	mov    %eax,%edx
  801f8b:	eb 05                	jmp    801f92 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801f8d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801f92:	89 d0                	mov    %edx,%eax
  801f94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f97:	c9                   	leave  
  801f98:	c3                   	ret    

00801f99 <seek>:

int
seek(int fdnum, off_t offset)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801fa2:	50                   	push   %eax
  801fa3:	ff 75 08             	pushl  0x8(%ebp)
  801fa6:	e8 22 fc ff ff       	call   801bcd <fd_lookup>
  801fab:	83 c4 08             	add    $0x8,%esp
  801fae:	85 c0                	test   %eax,%eax
  801fb0:	78 0e                	js     801fc0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801fb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801fb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801fbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc0:	c9                   	leave  
  801fc1:	c3                   	ret    

00801fc2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801fc2:	55                   	push   %ebp
  801fc3:	89 e5                	mov    %esp,%ebp
  801fc5:	53                   	push   %ebx
  801fc6:	83 ec 14             	sub    $0x14,%esp
  801fc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801fcc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fcf:	50                   	push   %eax
  801fd0:	53                   	push   %ebx
  801fd1:	e8 f7 fb ff ff       	call   801bcd <fd_lookup>
  801fd6:	83 c4 08             	add    $0x8,%esp
  801fd9:	89 c2                	mov    %eax,%edx
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	78 65                	js     802044 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fdf:	83 ec 08             	sub    $0x8,%esp
  801fe2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe5:	50                   	push   %eax
  801fe6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe9:	ff 30                	pushl  (%eax)
  801feb:	e8 33 fc ff ff       	call   801c23 <dev_lookup>
  801ff0:	83 c4 10             	add    $0x10,%esp
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	78 44                	js     80203b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801ff7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ffa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801ffe:	75 21                	jne    802021 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802000:	a1 24 54 80 00       	mov    0x805424,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802005:	8b 40 48             	mov    0x48(%eax),%eax
  802008:	83 ec 04             	sub    $0x4,%esp
  80200b:	53                   	push   %ebx
  80200c:	50                   	push   %eax
  80200d:	68 5c 38 80 00       	push   $0x80385c
  802012:	e8 d7 ea ff ff       	call   800aee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802017:	83 c4 10             	add    $0x10,%esp
  80201a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80201f:	eb 23                	jmp    802044 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802021:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802024:	8b 52 18             	mov    0x18(%edx),%edx
  802027:	85 d2                	test   %edx,%edx
  802029:	74 14                	je     80203f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80202b:	83 ec 08             	sub    $0x8,%esp
  80202e:	ff 75 0c             	pushl  0xc(%ebp)
  802031:	50                   	push   %eax
  802032:	ff d2                	call   *%edx
  802034:	89 c2                	mov    %eax,%edx
  802036:	83 c4 10             	add    $0x10,%esp
  802039:	eb 09                	jmp    802044 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80203b:	89 c2                	mov    %eax,%edx
  80203d:	eb 05                	jmp    802044 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80203f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802044:	89 d0                	mov    %edx,%eax
  802046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802049:	c9                   	leave  
  80204a:	c3                   	ret    

0080204b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	53                   	push   %ebx
  80204f:	83 ec 14             	sub    $0x14,%esp
  802052:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802055:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802058:	50                   	push   %eax
  802059:	ff 75 08             	pushl  0x8(%ebp)
  80205c:	e8 6c fb ff ff       	call   801bcd <fd_lookup>
  802061:	83 c4 08             	add    $0x8,%esp
  802064:	89 c2                	mov    %eax,%edx
  802066:	85 c0                	test   %eax,%eax
  802068:	78 58                	js     8020c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80206a:	83 ec 08             	sub    $0x8,%esp
  80206d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802070:	50                   	push   %eax
  802071:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802074:	ff 30                	pushl  (%eax)
  802076:	e8 a8 fb ff ff       	call   801c23 <dev_lookup>
  80207b:	83 c4 10             	add    $0x10,%esp
  80207e:	85 c0                	test   %eax,%eax
  802080:	78 37                	js     8020b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802082:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802085:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802089:	74 32                	je     8020bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80208b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80208e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802095:	00 00 00 
	stat->st_isdir = 0;
  802098:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80209f:	00 00 00 
	stat->st_dev = dev;
  8020a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8020a8:	83 ec 08             	sub    $0x8,%esp
  8020ab:	53                   	push   %ebx
  8020ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8020af:	ff 50 14             	call   *0x14(%eax)
  8020b2:	89 c2                	mov    %eax,%edx
  8020b4:	83 c4 10             	add    $0x10,%esp
  8020b7:	eb 09                	jmp    8020c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020b9:	89 c2                	mov    %eax,%edx
  8020bb:	eb 05                	jmp    8020c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8020bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8020c2:	89 d0                	mov    %edx,%eax
  8020c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020c7:	c9                   	leave  
  8020c8:	c3                   	ret    

008020c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	56                   	push   %esi
  8020cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8020ce:	83 ec 08             	sub    $0x8,%esp
  8020d1:	6a 00                	push   $0x0
  8020d3:	ff 75 08             	pushl  0x8(%ebp)
  8020d6:	e8 0c 02 00 00       	call   8022e7 <open>
  8020db:	89 c3                	mov    %eax,%ebx
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	78 1b                	js     8020ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8020e4:	83 ec 08             	sub    $0x8,%esp
  8020e7:	ff 75 0c             	pushl  0xc(%ebp)
  8020ea:	50                   	push   %eax
  8020eb:	e8 5b ff ff ff       	call   80204b <fstat>
  8020f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8020f2:	89 1c 24             	mov    %ebx,(%esp)
  8020f5:	e8 fd fb ff ff       	call   801cf7 <close>
	return r;
  8020fa:	83 c4 10             	add    $0x10,%esp
  8020fd:	89 f0                	mov    %esi,%eax
}
  8020ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802102:	5b                   	pop    %ebx
  802103:	5e                   	pop    %esi
  802104:	5d                   	pop    %ebp
  802105:	c3                   	ret    

00802106 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	56                   	push   %esi
  80210a:	53                   	push   %ebx
  80210b:	89 c6                	mov    %eax,%esi
  80210d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80210f:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802116:	75 12                	jne    80212a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802118:	83 ec 0c             	sub    $0xc,%esp
  80211b:	6a 01                	push   $0x1
  80211d:	e8 0b 0e 00 00       	call   802f2d <ipc_find_env>
  802122:	a3 20 54 80 00       	mov    %eax,0x805420
  802127:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80212a:	6a 07                	push   $0x7
  80212c:	68 00 60 80 00       	push   $0x806000
  802131:	56                   	push   %esi
  802132:	ff 35 20 54 80 00    	pushl  0x805420
  802138:	e8 9c 0d 00 00       	call   802ed9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80213d:	83 c4 0c             	add    $0xc,%esp
  802140:	6a 00                	push   $0x0
  802142:	53                   	push   %ebx
  802143:	6a 00                	push   $0x0
  802145:	e8 26 0d 00 00       	call   802e70 <ipc_recv>
}
  80214a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214d:	5b                   	pop    %ebx
  80214e:	5e                   	pop    %esi
  80214f:	5d                   	pop    %ebp
  802150:	c3                   	ret    

00802151 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802151:	55                   	push   %ebp
  802152:	89 e5                	mov    %esp,%ebp
  802154:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802157:	8b 45 08             	mov    0x8(%ebp),%eax
  80215a:	8b 40 0c             	mov    0xc(%eax),%eax
  80215d:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802162:	8b 45 0c             	mov    0xc(%ebp),%eax
  802165:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80216a:	ba 00 00 00 00       	mov    $0x0,%edx
  80216f:	b8 02 00 00 00       	mov    $0x2,%eax
  802174:	e8 8d ff ff ff       	call   802106 <fsipc>
}
  802179:	c9                   	leave  
  80217a:	c3                   	ret    

0080217b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80217b:	55                   	push   %ebp
  80217c:	89 e5                	mov    %esp,%ebp
  80217e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802181:	8b 45 08             	mov    0x8(%ebp),%eax
  802184:	8b 40 0c             	mov    0xc(%eax),%eax
  802187:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  80218c:	ba 00 00 00 00       	mov    $0x0,%edx
  802191:	b8 06 00 00 00       	mov    $0x6,%eax
  802196:	e8 6b ff ff ff       	call   802106 <fsipc>
}
  80219b:	c9                   	leave  
  80219c:	c3                   	ret    

0080219d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80219d:	55                   	push   %ebp
  80219e:	89 e5                	mov    %esp,%ebp
  8021a0:	53                   	push   %ebx
  8021a1:	83 ec 04             	sub    $0x4,%esp
  8021a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8021a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8021ad:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8021b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8021b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8021bc:	e8 45 ff ff ff       	call   802106 <fsipc>
  8021c1:	85 c0                	test   %eax,%eax
  8021c3:	78 2c                	js     8021f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8021c5:	83 ec 08             	sub    $0x8,%esp
  8021c8:	68 00 60 80 00       	push   $0x806000
  8021cd:	53                   	push   %ebx
  8021ce:	e8 93 ef ff ff       	call   801166 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8021d3:	a1 80 60 80 00       	mov    0x806080,%eax
  8021d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8021de:	a1 84 60 80 00       	mov    0x806084,%eax
  8021e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8021e9:	83 c4 10             	add    $0x10,%esp
  8021ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021f4:	c9                   	leave  
  8021f5:	c3                   	ret    

008021f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8021f6:	55                   	push   %ebp
  8021f7:	89 e5                	mov    %esp,%ebp
  8021f9:	53                   	push   %ebx
  8021fa:	83 ec 08             	sub    $0x8,%esp
  8021fd:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802200:	8b 55 08             	mov    0x8(%ebp),%edx
  802203:	8b 52 0c             	mov    0xc(%edx),%edx
  802206:	89 15 00 60 80 00    	mov    %edx,0x806000
  80220c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802211:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  802216:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  802219:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  80221f:	53                   	push   %ebx
  802220:	ff 75 0c             	pushl  0xc(%ebp)
  802223:	68 08 60 80 00       	push   $0x806008
  802228:	e8 cb f0 ff ff       	call   8012f8 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  80222d:	ba 00 00 00 00       	mov    $0x0,%edx
  802232:	b8 04 00 00 00       	mov    $0x4,%eax
  802237:	e8 ca fe ff ff       	call   802106 <fsipc>
  80223c:	83 c4 10             	add    $0x10,%esp
  80223f:	85 c0                	test   %eax,%eax
  802241:	78 1d                	js     802260 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  802243:	39 d8                	cmp    %ebx,%eax
  802245:	76 19                	jbe    802260 <devfile_write+0x6a>
  802247:	68 c8 38 80 00       	push   $0x8038c8
  80224c:	68 86 33 80 00       	push   $0x803386
  802251:	68 a3 00 00 00       	push   $0xa3
  802256:	68 d4 38 80 00       	push   $0x8038d4
  80225b:	e8 b5 e7 ff ff       	call   800a15 <_panic>
	return r;
}
  802260:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802263:	c9                   	leave  
  802264:	c3                   	ret    

00802265 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802265:	55                   	push   %ebp
  802266:	89 e5                	mov    %esp,%ebp
  802268:	56                   	push   %esi
  802269:	53                   	push   %ebx
  80226a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80226d:	8b 45 08             	mov    0x8(%ebp),%eax
  802270:	8b 40 0c             	mov    0xc(%eax),%eax
  802273:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802278:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80227e:	ba 00 00 00 00       	mov    $0x0,%edx
  802283:	b8 03 00 00 00       	mov    $0x3,%eax
  802288:	e8 79 fe ff ff       	call   802106 <fsipc>
  80228d:	89 c3                	mov    %eax,%ebx
  80228f:	85 c0                	test   %eax,%eax
  802291:	78 4b                	js     8022de <devfile_read+0x79>
		return r;
	assert(r <= n);
  802293:	39 c6                	cmp    %eax,%esi
  802295:	73 16                	jae    8022ad <devfile_read+0x48>
  802297:	68 df 38 80 00       	push   $0x8038df
  80229c:	68 86 33 80 00       	push   $0x803386
  8022a1:	6a 7c                	push   $0x7c
  8022a3:	68 d4 38 80 00       	push   $0x8038d4
  8022a8:	e8 68 e7 ff ff       	call   800a15 <_panic>
	assert(r <= PGSIZE);
  8022ad:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022b2:	7e 16                	jle    8022ca <devfile_read+0x65>
  8022b4:	68 e6 38 80 00       	push   $0x8038e6
  8022b9:	68 86 33 80 00       	push   $0x803386
  8022be:	6a 7d                	push   $0x7d
  8022c0:	68 d4 38 80 00       	push   $0x8038d4
  8022c5:	e8 4b e7 ff ff       	call   800a15 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8022ca:	83 ec 04             	sub    $0x4,%esp
  8022cd:	50                   	push   %eax
  8022ce:	68 00 60 80 00       	push   $0x806000
  8022d3:	ff 75 0c             	pushl  0xc(%ebp)
  8022d6:	e8 1d f0 ff ff       	call   8012f8 <memmove>
	return r;
  8022db:	83 c4 10             	add    $0x10,%esp
}
  8022de:	89 d8                	mov    %ebx,%eax
  8022e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5e                   	pop    %esi
  8022e5:	5d                   	pop    %ebp
  8022e6:	c3                   	ret    

008022e7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8022e7:	55                   	push   %ebp
  8022e8:	89 e5                	mov    %esp,%ebp
  8022ea:	53                   	push   %ebx
  8022eb:	83 ec 20             	sub    $0x20,%esp
  8022ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8022f1:	53                   	push   %ebx
  8022f2:	e8 36 ee ff ff       	call   80112d <strlen>
  8022f7:	83 c4 10             	add    $0x10,%esp
  8022fa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8022ff:	7f 67                	jg     802368 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802301:	83 ec 0c             	sub    $0xc,%esp
  802304:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802307:	50                   	push   %eax
  802308:	e8 71 f8 ff ff       	call   801b7e <fd_alloc>
  80230d:	83 c4 10             	add    $0x10,%esp
		return r;
  802310:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802312:	85 c0                	test   %eax,%eax
  802314:	78 57                	js     80236d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802316:	83 ec 08             	sub    $0x8,%esp
  802319:	53                   	push   %ebx
  80231a:	68 00 60 80 00       	push   $0x806000
  80231f:	e8 42 ee ff ff       	call   801166 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802324:	8b 45 0c             	mov    0xc(%ebp),%eax
  802327:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80232c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80232f:	b8 01 00 00 00       	mov    $0x1,%eax
  802334:	e8 cd fd ff ff       	call   802106 <fsipc>
  802339:	89 c3                	mov    %eax,%ebx
  80233b:	83 c4 10             	add    $0x10,%esp
  80233e:	85 c0                	test   %eax,%eax
  802340:	79 14                	jns    802356 <open+0x6f>
		fd_close(fd, 0);
  802342:	83 ec 08             	sub    $0x8,%esp
  802345:	6a 00                	push   $0x0
  802347:	ff 75 f4             	pushl  -0xc(%ebp)
  80234a:	e8 27 f9 ff ff       	call   801c76 <fd_close>
		return r;
  80234f:	83 c4 10             	add    $0x10,%esp
  802352:	89 da                	mov    %ebx,%edx
  802354:	eb 17                	jmp    80236d <open+0x86>
	}

	return fd2num(fd);
  802356:	83 ec 0c             	sub    $0xc,%esp
  802359:	ff 75 f4             	pushl  -0xc(%ebp)
  80235c:	e8 f6 f7 ff ff       	call   801b57 <fd2num>
  802361:	89 c2                	mov    %eax,%edx
  802363:	83 c4 10             	add    $0x10,%esp
  802366:	eb 05                	jmp    80236d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802368:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80236d:	89 d0                	mov    %edx,%eax
  80236f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802372:	c9                   	leave  
  802373:	c3                   	ret    

00802374 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802374:	55                   	push   %ebp
  802375:	89 e5                	mov    %esp,%ebp
  802377:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80237a:	ba 00 00 00 00       	mov    $0x0,%edx
  80237f:	b8 08 00 00 00       	mov    $0x8,%eax
  802384:	e8 7d fd ff ff       	call   802106 <fsipc>
}
  802389:	c9                   	leave  
  80238a:	c3                   	ret    

0080238b <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80238b:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80238f:	7e 37                	jle    8023c8 <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
  802394:	53                   	push   %ebx
  802395:	83 ec 08             	sub    $0x8,%esp
  802398:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80239a:	ff 70 04             	pushl  0x4(%eax)
  80239d:	8d 40 10             	lea    0x10(%eax),%eax
  8023a0:	50                   	push   %eax
  8023a1:	ff 33                	pushl  (%ebx)
  8023a3:	e8 65 fb ff ff       	call   801f0d <write>
		if (result > 0)
  8023a8:	83 c4 10             	add    $0x10,%esp
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	7e 03                	jle    8023b2 <writebuf+0x27>
			b->result += result;
  8023af:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8023b2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8023b5:	74 0d                	je     8023c4 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8023b7:	85 c0                	test   %eax,%eax
  8023b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8023be:	0f 4f c2             	cmovg  %edx,%eax
  8023c1:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8023c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023c7:	c9                   	leave  
  8023c8:	f3 c3                	repz ret 

008023ca <putch>:

static void
putch(int ch, void *thunk)
{
  8023ca:	55                   	push   %ebp
  8023cb:	89 e5                	mov    %esp,%ebp
  8023cd:	53                   	push   %ebx
  8023ce:	83 ec 04             	sub    $0x4,%esp
  8023d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8023d4:	8b 53 04             	mov    0x4(%ebx),%edx
  8023d7:	8d 42 01             	lea    0x1(%edx),%eax
  8023da:	89 43 04             	mov    %eax,0x4(%ebx)
  8023dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023e0:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8023e4:	3d 00 01 00 00       	cmp    $0x100,%eax
  8023e9:	75 0e                	jne    8023f9 <putch+0x2f>
		writebuf(b);
  8023eb:	89 d8                	mov    %ebx,%eax
  8023ed:	e8 99 ff ff ff       	call   80238b <writebuf>
		b->idx = 0;
  8023f2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8023f9:	83 c4 04             	add    $0x4,%esp
  8023fc:	5b                   	pop    %ebx
  8023fd:	5d                   	pop    %ebp
  8023fe:	c3                   	ret    

008023ff <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8023ff:	55                   	push   %ebp
  802400:	89 e5                	mov    %esp,%ebp
  802402:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802408:	8b 45 08             	mov    0x8(%ebp),%eax
  80240b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802411:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802418:	00 00 00 
	b.result = 0;
  80241b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802422:	00 00 00 
	b.error = 1;
  802425:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80242c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80242f:	ff 75 10             	pushl  0x10(%ebp)
  802432:	ff 75 0c             	pushl  0xc(%ebp)
  802435:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80243b:	50                   	push   %eax
  80243c:	68 ca 23 80 00       	push   $0x8023ca
  802441:	e8 df e7 ff ff       	call   800c25 <vprintfmt>
	if (b.idx > 0)
  802446:	83 c4 10             	add    $0x10,%esp
  802449:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802450:	7e 0b                	jle    80245d <vfprintf+0x5e>
		writebuf(&b);
  802452:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802458:	e8 2e ff ff ff       	call   80238b <writebuf>

	return (b.result ? b.result : b.error);
  80245d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802463:	85 c0                	test   %eax,%eax
  802465:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80246c:	c9                   	leave  
  80246d:	c3                   	ret    

0080246e <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80246e:	55                   	push   %ebp
  80246f:	89 e5                	mov    %esp,%ebp
  802471:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802474:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802477:	50                   	push   %eax
  802478:	ff 75 0c             	pushl  0xc(%ebp)
  80247b:	ff 75 08             	pushl  0x8(%ebp)
  80247e:	e8 7c ff ff ff       	call   8023ff <vfprintf>
	va_end(ap);

	return cnt;
}
  802483:	c9                   	leave  
  802484:	c3                   	ret    

00802485 <printf>:

int
printf(const char *fmt, ...)
{
  802485:	55                   	push   %ebp
  802486:	89 e5                	mov    %esp,%ebp
  802488:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80248b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80248e:	50                   	push   %eax
  80248f:	ff 75 08             	pushl  0x8(%ebp)
  802492:	6a 01                	push   $0x1
  802494:	e8 66 ff ff ff       	call   8023ff <vfprintf>
	va_end(ap);

	return cnt;
}
  802499:	c9                   	leave  
  80249a:	c3                   	ret    

0080249b <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80249b:	55                   	push   %ebp
  80249c:	89 e5                	mov    %esp,%ebp
  80249e:	57                   	push   %edi
  80249f:	56                   	push   %esi
  8024a0:	53                   	push   %ebx
  8024a1:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8024a7:	6a 00                	push   $0x0
  8024a9:	ff 75 08             	pushl  0x8(%ebp)
  8024ac:	e8 36 fe ff ff       	call   8022e7 <open>
  8024b1:	89 c7                	mov    %eax,%edi
  8024b3:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8024b9:	83 c4 10             	add    $0x10,%esp
  8024bc:	85 c0                	test   %eax,%eax
  8024be:	0f 88 ae 04 00 00    	js     802972 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8024c4:	83 ec 04             	sub    $0x4,%esp
  8024c7:	68 00 02 00 00       	push   $0x200
  8024cc:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8024d2:	50                   	push   %eax
  8024d3:	57                   	push   %edi
  8024d4:	e8 eb f9 ff ff       	call   801ec4 <readn>
  8024d9:	83 c4 10             	add    $0x10,%esp
  8024dc:	3d 00 02 00 00       	cmp    $0x200,%eax
  8024e1:	75 0c                	jne    8024ef <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8024e3:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8024ea:	45 4c 46 
  8024ed:	74 33                	je     802522 <spawn+0x87>
		close(fd);
  8024ef:	83 ec 0c             	sub    $0xc,%esp
  8024f2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8024f8:	e8 fa f7 ff ff       	call   801cf7 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8024fd:	83 c4 0c             	add    $0xc,%esp
  802500:	68 7f 45 4c 46       	push   $0x464c457f
  802505:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80250b:	68 f2 38 80 00       	push   $0x8038f2
  802510:	e8 d9 e5 ff ff       	call   800aee <cprintf>
		return -E_NOT_EXEC;
  802515:	83 c4 10             	add    $0x10,%esp
  802518:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80251d:	e9 b0 04 00 00       	jmp    8029d2 <spawn+0x537>
  802522:	b8 07 00 00 00       	mov    $0x7,%eax
  802527:	cd 30                	int    $0x30
  802529:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80252f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802535:	85 c0                	test   %eax,%eax
  802537:	0f 88 3d 04 00 00    	js     80297a <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80253d:	89 c6                	mov    %eax,%esi
  80253f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802545:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802548:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80254e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802554:	b9 11 00 00 00       	mov    $0x11,%ecx
  802559:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80255b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802561:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802567:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80256c:	be 00 00 00 00       	mov    $0x0,%esi
  802571:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802574:	eb 13                	jmp    802589 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802576:	83 ec 0c             	sub    $0xc,%esp
  802579:	50                   	push   %eax
  80257a:	e8 ae eb ff ff       	call   80112d <strlen>
  80257f:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802583:	83 c3 01             	add    $0x1,%ebx
  802586:	83 c4 10             	add    $0x10,%esp
  802589:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802590:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802593:	85 c0                	test   %eax,%eax
  802595:	75 df                	jne    802576 <spawn+0xdb>
  802597:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80259d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025a3:	bf 00 10 40 00       	mov    $0x401000,%edi
  8025a8:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8025aa:	89 fa                	mov    %edi,%edx
  8025ac:	83 e2 fc             	and    $0xfffffffc,%edx
  8025af:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8025b6:	29 c2                	sub    %eax,%edx
  8025b8:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8025be:	8d 42 f8             	lea    -0x8(%edx),%eax
  8025c1:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8025c6:	0f 86 be 03 00 00    	jbe    80298a <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8025cc:	83 ec 04             	sub    $0x4,%esp
  8025cf:	6a 07                	push   $0x7
  8025d1:	68 00 00 40 00       	push   $0x400000
  8025d6:	6a 00                	push   $0x0
  8025d8:	e8 8c ef ff ff       	call   801569 <sys_page_alloc>
  8025dd:	83 c4 10             	add    $0x10,%esp
  8025e0:	85 c0                	test   %eax,%eax
  8025e2:	0f 88 a9 03 00 00    	js     802991 <spawn+0x4f6>
  8025e8:	be 00 00 00 00       	mov    $0x0,%esi
  8025ed:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8025f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8025f6:	eb 30                	jmp    802628 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8025f8:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8025fe:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802604:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802607:	83 ec 08             	sub    $0x8,%esp
  80260a:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80260d:	57                   	push   %edi
  80260e:	e8 53 eb ff ff       	call   801166 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802613:	83 c4 04             	add    $0x4,%esp
  802616:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802619:	e8 0f eb ff ff       	call   80112d <strlen>
  80261e:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802622:	83 c6 01             	add    $0x1,%esi
  802625:	83 c4 10             	add    $0x10,%esp
  802628:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80262e:	7f c8                	jg     8025f8 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  802630:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802636:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80263c:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802643:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802649:	74 19                	je     802664 <spawn+0x1c9>
  80264b:	68 50 39 80 00       	push   $0x803950
  802650:	68 86 33 80 00       	push   $0x803386
  802655:	68 f2 00 00 00       	push   $0xf2
  80265a:	68 0c 39 80 00       	push   $0x80390c
  80265f:	e8 b1 e3 ff ff       	call   800a15 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802664:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80266a:	89 f8                	mov    %edi,%eax
  80266c:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802671:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802674:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80267a:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80267d:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  802683:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802689:	83 ec 0c             	sub    $0xc,%esp
  80268c:	6a 07                	push   $0x7
  80268e:	68 00 d0 bf ee       	push   $0xeebfd000
  802693:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802699:	68 00 00 40 00       	push   $0x400000
  80269e:	6a 00                	push   $0x0
  8026a0:	e8 07 ef ff ff       	call   8015ac <sys_page_map>
  8026a5:	89 c3                	mov    %eax,%ebx
  8026a7:	83 c4 20             	add    $0x20,%esp
  8026aa:	85 c0                	test   %eax,%eax
  8026ac:	0f 88 0e 03 00 00    	js     8029c0 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8026b2:	83 ec 08             	sub    $0x8,%esp
  8026b5:	68 00 00 40 00       	push   $0x400000
  8026ba:	6a 00                	push   $0x0
  8026bc:	e8 2d ef ff ff       	call   8015ee <sys_page_unmap>
  8026c1:	89 c3                	mov    %eax,%ebx
  8026c3:	83 c4 10             	add    $0x10,%esp
  8026c6:	85 c0                	test   %eax,%eax
  8026c8:	0f 88 f2 02 00 00    	js     8029c0 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8026ce:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8026d4:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8026db:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8026e1:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8026e8:	00 00 00 
  8026eb:	e9 88 01 00 00       	jmp    802878 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8026f0:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8026f6:	83 38 01             	cmpl   $0x1,(%eax)
  8026f9:	0f 85 6b 01 00 00    	jne    80286a <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8026ff:	89 c7                	mov    %eax,%edi
  802701:	8b 40 18             	mov    0x18(%eax),%eax
  802704:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80270a:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80270d:	83 f8 01             	cmp    $0x1,%eax
  802710:	19 c0                	sbb    %eax,%eax
  802712:	83 e0 fe             	and    $0xfffffffe,%eax
  802715:	83 c0 07             	add    $0x7,%eax
  802718:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80271e:	89 f8                	mov    %edi,%eax
  802720:	8b 7f 04             	mov    0x4(%edi),%edi
  802723:	89 f9                	mov    %edi,%ecx
  802725:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80272b:	8b 78 10             	mov    0x10(%eax),%edi
  80272e:	8b 50 14             	mov    0x14(%eax),%edx
  802731:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  802737:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80273a:	89 f0                	mov    %esi,%eax
  80273c:	25 ff 0f 00 00       	and    $0xfff,%eax
  802741:	74 14                	je     802757 <spawn+0x2bc>
		va -= i;
  802743:	29 c6                	sub    %eax,%esi
		memsz += i;
  802745:	01 c2                	add    %eax,%edx
  802747:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80274d:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80274f:	29 c1                	sub    %eax,%ecx
  802751:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802757:	bb 00 00 00 00       	mov    $0x0,%ebx
  80275c:	e9 f7 00 00 00       	jmp    802858 <spawn+0x3bd>
		if (i >= filesz) {
  802761:	39 df                	cmp    %ebx,%edi
  802763:	77 27                	ja     80278c <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802765:	83 ec 04             	sub    $0x4,%esp
  802768:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80276e:	56                   	push   %esi
  80276f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802775:	e8 ef ed ff ff       	call   801569 <sys_page_alloc>
  80277a:	83 c4 10             	add    $0x10,%esp
  80277d:	85 c0                	test   %eax,%eax
  80277f:	0f 89 c7 00 00 00    	jns    80284c <spawn+0x3b1>
  802785:	89 c3                	mov    %eax,%ebx
  802787:	e9 13 02 00 00       	jmp    80299f <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80278c:	83 ec 04             	sub    $0x4,%esp
  80278f:	6a 07                	push   $0x7
  802791:	68 00 00 40 00       	push   $0x400000
  802796:	6a 00                	push   $0x0
  802798:	e8 cc ed ff ff       	call   801569 <sys_page_alloc>
  80279d:	83 c4 10             	add    $0x10,%esp
  8027a0:	85 c0                	test   %eax,%eax
  8027a2:	0f 88 ed 01 00 00    	js     802995 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8027a8:	83 ec 08             	sub    $0x8,%esp
  8027ab:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8027b1:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8027b7:	50                   	push   %eax
  8027b8:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8027be:	e8 d6 f7 ff ff       	call   801f99 <seek>
  8027c3:	83 c4 10             	add    $0x10,%esp
  8027c6:	85 c0                	test   %eax,%eax
  8027c8:	0f 88 cb 01 00 00    	js     802999 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8027ce:	83 ec 04             	sub    $0x4,%esp
  8027d1:	89 f8                	mov    %edi,%eax
  8027d3:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8027d9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8027de:	ba 00 10 00 00       	mov    $0x1000,%edx
  8027e3:	0f 47 c2             	cmova  %edx,%eax
  8027e6:	50                   	push   %eax
  8027e7:	68 00 00 40 00       	push   $0x400000
  8027ec:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8027f2:	e8 cd f6 ff ff       	call   801ec4 <readn>
  8027f7:	83 c4 10             	add    $0x10,%esp
  8027fa:	85 c0                	test   %eax,%eax
  8027fc:	0f 88 9b 01 00 00    	js     80299d <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802802:	83 ec 0c             	sub    $0xc,%esp
  802805:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80280b:	56                   	push   %esi
  80280c:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  802812:	68 00 00 40 00       	push   $0x400000
  802817:	6a 00                	push   $0x0
  802819:	e8 8e ed ff ff       	call   8015ac <sys_page_map>
  80281e:	83 c4 20             	add    $0x20,%esp
  802821:	85 c0                	test   %eax,%eax
  802823:	79 15                	jns    80283a <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  802825:	50                   	push   %eax
  802826:	68 18 39 80 00       	push   $0x803918
  80282b:	68 25 01 00 00       	push   $0x125
  802830:	68 0c 39 80 00       	push   $0x80390c
  802835:	e8 db e1 ff ff       	call   800a15 <_panic>
			sys_page_unmap(0, UTEMP);
  80283a:	83 ec 08             	sub    $0x8,%esp
  80283d:	68 00 00 40 00       	push   $0x400000
  802842:	6a 00                	push   $0x0
  802844:	e8 a5 ed ff ff       	call   8015ee <sys_page_unmap>
  802849:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80284c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802852:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802858:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80285e:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  802864:	0f 87 f7 fe ff ff    	ja     802761 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80286a:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  802871:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  802878:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80287f:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  802885:	0f 8c 65 fe ff ff    	jl     8026f0 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80288b:	83 ec 0c             	sub    $0xc,%esp
  80288e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802894:	e8 5e f4 ff ff       	call   801cf7 <close>
  802899:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  80289c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028a1:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_P) && (uvpt[PGNUM(i)] & PTE_U) && (uvpt[PGNUM(i)] & PTE_SHARE)){
  8028a7:	89 d8                	mov    %ebx,%eax
  8028a9:	c1 e8 16             	shr    $0x16,%eax
  8028ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8028b3:	a8 01                	test   $0x1,%al
  8028b5:	74 46                	je     8028fd <spawn+0x462>
  8028b7:	89 d8                	mov    %ebx,%eax
  8028b9:	c1 e8 0c             	shr    $0xc,%eax
  8028bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8028c3:	f6 c2 01             	test   $0x1,%dl
  8028c6:	74 35                	je     8028fd <spawn+0x462>
  8028c8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8028cf:	f6 c2 04             	test   $0x4,%dl
  8028d2:	74 29                	je     8028fd <spawn+0x462>
  8028d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8028db:	f6 c6 04             	test   $0x4,%dh
  8028de:	74 1d                	je     8028fd <spawn+0x462>
			sys_page_map(0, (void*)i,child, (void*)i,(uvpt[PGNUM(i)] | PTE_SYSCALL));
  8028e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8028e7:	83 ec 0c             	sub    $0xc,%esp
  8028ea:	0d 07 0e 00 00       	or     $0xe07,%eax
  8028ef:	50                   	push   %eax
  8028f0:	53                   	push   %ebx
  8028f1:	56                   	push   %esi
  8028f2:	53                   	push   %ebx
  8028f3:	6a 00                	push   $0x0
  8028f5:	e8 b2 ec ff ff       	call   8015ac <sys_page_map>
  8028fa:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t i;
	for (i = 0; i < USTACKTOP; i += PGSIZE){
  8028fd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802903:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802909:	75 9c                	jne    8028a7 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80290b:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802912:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802915:	83 ec 08             	sub    $0x8,%esp
  802918:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80291e:	50                   	push   %eax
  80291f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802925:	e8 48 ed ff ff       	call   801672 <sys_env_set_trapframe>
  80292a:	83 c4 10             	add    $0x10,%esp
  80292d:	85 c0                	test   %eax,%eax
  80292f:	79 15                	jns    802946 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  802931:	50                   	push   %eax
  802932:	68 35 39 80 00       	push   $0x803935
  802937:	68 86 00 00 00       	push   $0x86
  80293c:	68 0c 39 80 00       	push   $0x80390c
  802941:	e8 cf e0 ff ff       	call   800a15 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802946:	83 ec 08             	sub    $0x8,%esp
  802949:	6a 02                	push   $0x2
  80294b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802951:	e8 da ec ff ff       	call   801630 <sys_env_set_status>
  802956:	83 c4 10             	add    $0x10,%esp
  802959:	85 c0                	test   %eax,%eax
  80295b:	79 25                	jns    802982 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  80295d:	50                   	push   %eax
  80295e:	68 0c 38 80 00       	push   $0x80380c
  802963:	68 89 00 00 00       	push   $0x89
  802968:	68 0c 39 80 00       	push   $0x80390c
  80296d:	e8 a3 e0 ff ff       	call   800a15 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802972:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  802978:	eb 58                	jmp    8029d2 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  80297a:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802980:	eb 50                	jmp    8029d2 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  802982:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  802988:	eb 48                	jmp    8029d2 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  80298a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  80298f:	eb 41                	jmp    8029d2 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  802991:	89 c3                	mov    %eax,%ebx
  802993:	eb 3d                	jmp    8029d2 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802995:	89 c3                	mov    %eax,%ebx
  802997:	eb 06                	jmp    80299f <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802999:	89 c3                	mov    %eax,%ebx
  80299b:	eb 02                	jmp    80299f <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  80299d:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  80299f:	83 ec 0c             	sub    $0xc,%esp
  8029a2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029a8:	e8 3d eb ff ff       	call   8014ea <sys_env_destroy>
	close(fd);
  8029ad:	83 c4 04             	add    $0x4,%esp
  8029b0:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8029b6:	e8 3c f3 ff ff       	call   801cf7 <close>
	return r;
  8029bb:	83 c4 10             	add    $0x10,%esp
  8029be:	eb 12                	jmp    8029d2 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8029c0:	83 ec 08             	sub    $0x8,%esp
  8029c3:	68 00 00 40 00       	push   $0x400000
  8029c8:	6a 00                	push   $0x0
  8029ca:	e8 1f ec ff ff       	call   8015ee <sys_page_unmap>
  8029cf:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  8029d2:	89 d8                	mov    %ebx,%eax
  8029d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029d7:	5b                   	pop    %ebx
  8029d8:	5e                   	pop    %esi
  8029d9:	5f                   	pop    %edi
  8029da:	5d                   	pop    %ebp
  8029db:	c3                   	ret    

008029dc <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  8029dc:	55                   	push   %ebp
  8029dd:	89 e5                	mov    %esp,%ebp
  8029df:	56                   	push   %esi
  8029e0:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029e1:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  8029e4:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029e9:	eb 03                	jmp    8029ee <spawnl+0x12>
		argc++;
  8029eb:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  8029ee:	83 c2 04             	add    $0x4,%edx
  8029f1:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  8029f5:	75 f4                	jne    8029eb <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  8029f7:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  8029fe:	83 e2 f0             	and    $0xfffffff0,%edx
  802a01:	29 d4                	sub    %edx,%esp
  802a03:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a07:	c1 ea 02             	shr    $0x2,%edx
  802a0a:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a11:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a16:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a1d:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a24:	00 
  802a25:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a27:	b8 00 00 00 00       	mov    $0x0,%eax
  802a2c:	eb 0a                	jmp    802a38 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802a2e:	83 c0 01             	add    $0x1,%eax
  802a31:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802a35:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a38:	39 d0                	cmp    %edx,%eax
  802a3a:	75 f2                	jne    802a2e <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802a3c:	83 ec 08             	sub    $0x8,%esp
  802a3f:	56                   	push   %esi
  802a40:	ff 75 08             	pushl  0x8(%ebp)
  802a43:	e8 53 fa ff ff       	call   80249b <spawn>
}
  802a48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a4b:	5b                   	pop    %ebx
  802a4c:	5e                   	pop    %esi
  802a4d:	5d                   	pop    %ebp
  802a4e:	c3                   	ret    

00802a4f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802a4f:	55                   	push   %ebp
  802a50:	89 e5                	mov    %esp,%ebp
  802a52:	56                   	push   %esi
  802a53:	53                   	push   %ebx
  802a54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802a57:	83 ec 0c             	sub    $0xc,%esp
  802a5a:	ff 75 08             	pushl  0x8(%ebp)
  802a5d:	e8 05 f1 ff ff       	call   801b67 <fd2data>
  802a62:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802a64:	83 c4 08             	add    $0x8,%esp
  802a67:	68 78 39 80 00       	push   $0x803978
  802a6c:	53                   	push   %ebx
  802a6d:	e8 f4 e6 ff ff       	call   801166 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802a72:	8b 46 04             	mov    0x4(%esi),%eax
  802a75:	2b 06                	sub    (%esi),%eax
  802a77:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802a7d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802a84:	00 00 00 
	stat->st_dev = &devpipe;
  802a87:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802a8e:	40 80 00 
	return 0;
}
  802a91:	b8 00 00 00 00       	mov    $0x0,%eax
  802a96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a99:	5b                   	pop    %ebx
  802a9a:	5e                   	pop    %esi
  802a9b:	5d                   	pop    %ebp
  802a9c:	c3                   	ret    

00802a9d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802a9d:	55                   	push   %ebp
  802a9e:	89 e5                	mov    %esp,%ebp
  802aa0:	53                   	push   %ebx
  802aa1:	83 ec 0c             	sub    $0xc,%esp
  802aa4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802aa7:	53                   	push   %ebx
  802aa8:	6a 00                	push   $0x0
  802aaa:	e8 3f eb ff ff       	call   8015ee <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802aaf:	89 1c 24             	mov    %ebx,(%esp)
  802ab2:	e8 b0 f0 ff ff       	call   801b67 <fd2data>
  802ab7:	83 c4 08             	add    $0x8,%esp
  802aba:	50                   	push   %eax
  802abb:	6a 00                	push   $0x0
  802abd:	e8 2c eb ff ff       	call   8015ee <sys_page_unmap>
}
  802ac2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ac5:	c9                   	leave  
  802ac6:	c3                   	ret    

00802ac7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802ac7:	55                   	push   %ebp
  802ac8:	89 e5                	mov    %esp,%ebp
  802aca:	57                   	push   %edi
  802acb:	56                   	push   %esi
  802acc:	53                   	push   %ebx
  802acd:	83 ec 1c             	sub    $0x1c,%esp
  802ad0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802ad3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802ad5:	a1 24 54 80 00       	mov    0x805424,%eax
  802ada:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802add:	83 ec 0c             	sub    $0xc,%esp
  802ae0:	ff 75 e0             	pushl  -0x20(%ebp)
  802ae3:	e8 7e 04 00 00       	call   802f66 <pageref>
  802ae8:	89 c3                	mov    %eax,%ebx
  802aea:	89 3c 24             	mov    %edi,(%esp)
  802aed:	e8 74 04 00 00       	call   802f66 <pageref>
  802af2:	83 c4 10             	add    $0x10,%esp
  802af5:	39 c3                	cmp    %eax,%ebx
  802af7:	0f 94 c1             	sete   %cl
  802afa:	0f b6 c9             	movzbl %cl,%ecx
  802afd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802b00:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802b06:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b09:	39 ce                	cmp    %ecx,%esi
  802b0b:	74 1b                	je     802b28 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802b0d:	39 c3                	cmp    %eax,%ebx
  802b0f:	75 c4                	jne    802ad5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802b11:	8b 42 58             	mov    0x58(%edx),%eax
  802b14:	ff 75 e4             	pushl  -0x1c(%ebp)
  802b17:	50                   	push   %eax
  802b18:	56                   	push   %esi
  802b19:	68 7f 39 80 00       	push   $0x80397f
  802b1e:	e8 cb df ff ff       	call   800aee <cprintf>
  802b23:	83 c4 10             	add    $0x10,%esp
  802b26:	eb ad                	jmp    802ad5 <_pipeisclosed+0xe>
	}
}
  802b28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b2e:	5b                   	pop    %ebx
  802b2f:	5e                   	pop    %esi
  802b30:	5f                   	pop    %edi
  802b31:	5d                   	pop    %ebp
  802b32:	c3                   	ret    

00802b33 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b33:	55                   	push   %ebp
  802b34:	89 e5                	mov    %esp,%ebp
  802b36:	57                   	push   %edi
  802b37:	56                   	push   %esi
  802b38:	53                   	push   %ebx
  802b39:	83 ec 28             	sub    $0x28,%esp
  802b3c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802b3f:	56                   	push   %esi
  802b40:	e8 22 f0 ff ff       	call   801b67 <fd2data>
  802b45:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b47:	83 c4 10             	add    $0x10,%esp
  802b4a:	bf 00 00 00 00       	mov    $0x0,%edi
  802b4f:	eb 4b                	jmp    802b9c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802b51:	89 da                	mov    %ebx,%edx
  802b53:	89 f0                	mov    %esi,%eax
  802b55:	e8 6d ff ff ff       	call   802ac7 <_pipeisclosed>
  802b5a:	85 c0                	test   %eax,%eax
  802b5c:	75 48                	jne    802ba6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802b5e:	e8 e7 e9 ff ff       	call   80154a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802b63:	8b 43 04             	mov    0x4(%ebx),%eax
  802b66:	8b 0b                	mov    (%ebx),%ecx
  802b68:	8d 51 20             	lea    0x20(%ecx),%edx
  802b6b:	39 d0                	cmp    %edx,%eax
  802b6d:	73 e2                	jae    802b51 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b72:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802b76:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802b79:	89 c2                	mov    %eax,%edx
  802b7b:	c1 fa 1f             	sar    $0x1f,%edx
  802b7e:	89 d1                	mov    %edx,%ecx
  802b80:	c1 e9 1b             	shr    $0x1b,%ecx
  802b83:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802b86:	83 e2 1f             	and    $0x1f,%edx
  802b89:	29 ca                	sub    %ecx,%edx
  802b8b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802b8f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802b93:	83 c0 01             	add    $0x1,%eax
  802b96:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b99:	83 c7 01             	add    $0x1,%edi
  802b9c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802b9f:	75 c2                	jne    802b63 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802ba1:	8b 45 10             	mov    0x10(%ebp),%eax
  802ba4:	eb 05                	jmp    802bab <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802ba6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bae:	5b                   	pop    %ebx
  802baf:	5e                   	pop    %esi
  802bb0:	5f                   	pop    %edi
  802bb1:	5d                   	pop    %ebp
  802bb2:	c3                   	ret    

00802bb3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802bb3:	55                   	push   %ebp
  802bb4:	89 e5                	mov    %esp,%ebp
  802bb6:	57                   	push   %edi
  802bb7:	56                   	push   %esi
  802bb8:	53                   	push   %ebx
  802bb9:	83 ec 18             	sub    $0x18,%esp
  802bbc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802bbf:	57                   	push   %edi
  802bc0:	e8 a2 ef ff ff       	call   801b67 <fd2data>
  802bc5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802bc7:	83 c4 10             	add    $0x10,%esp
  802bca:	bb 00 00 00 00       	mov    $0x0,%ebx
  802bcf:	eb 3d                	jmp    802c0e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802bd1:	85 db                	test   %ebx,%ebx
  802bd3:	74 04                	je     802bd9 <devpipe_read+0x26>
				return i;
  802bd5:	89 d8                	mov    %ebx,%eax
  802bd7:	eb 44                	jmp    802c1d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802bd9:	89 f2                	mov    %esi,%edx
  802bdb:	89 f8                	mov    %edi,%eax
  802bdd:	e8 e5 fe ff ff       	call   802ac7 <_pipeisclosed>
  802be2:	85 c0                	test   %eax,%eax
  802be4:	75 32                	jne    802c18 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802be6:	e8 5f e9 ff ff       	call   80154a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802beb:	8b 06                	mov    (%esi),%eax
  802bed:	3b 46 04             	cmp    0x4(%esi),%eax
  802bf0:	74 df                	je     802bd1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802bf2:	99                   	cltd   
  802bf3:	c1 ea 1b             	shr    $0x1b,%edx
  802bf6:	01 d0                	add    %edx,%eax
  802bf8:	83 e0 1f             	and    $0x1f,%eax
  802bfb:	29 d0                	sub    %edx,%eax
  802bfd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c05:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802c08:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c0b:	83 c3 01             	add    $0x1,%ebx
  802c0e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802c11:	75 d8                	jne    802beb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c13:	8b 45 10             	mov    0x10(%ebp),%eax
  802c16:	eb 05                	jmp    802c1d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c18:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c20:	5b                   	pop    %ebx
  802c21:	5e                   	pop    %esi
  802c22:	5f                   	pop    %edi
  802c23:	5d                   	pop    %ebp
  802c24:	c3                   	ret    

00802c25 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c25:	55                   	push   %ebp
  802c26:	89 e5                	mov    %esp,%ebp
  802c28:	56                   	push   %esi
  802c29:	53                   	push   %ebx
  802c2a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c30:	50                   	push   %eax
  802c31:	e8 48 ef ff ff       	call   801b7e <fd_alloc>
  802c36:	83 c4 10             	add    $0x10,%esp
  802c39:	89 c2                	mov    %eax,%edx
  802c3b:	85 c0                	test   %eax,%eax
  802c3d:	0f 88 2c 01 00 00    	js     802d6f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c43:	83 ec 04             	sub    $0x4,%esp
  802c46:	68 07 04 00 00       	push   $0x407
  802c4b:	ff 75 f4             	pushl  -0xc(%ebp)
  802c4e:	6a 00                	push   $0x0
  802c50:	e8 14 e9 ff ff       	call   801569 <sys_page_alloc>
  802c55:	83 c4 10             	add    $0x10,%esp
  802c58:	89 c2                	mov    %eax,%edx
  802c5a:	85 c0                	test   %eax,%eax
  802c5c:	0f 88 0d 01 00 00    	js     802d6f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802c62:	83 ec 0c             	sub    $0xc,%esp
  802c65:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c68:	50                   	push   %eax
  802c69:	e8 10 ef ff ff       	call   801b7e <fd_alloc>
  802c6e:	89 c3                	mov    %eax,%ebx
  802c70:	83 c4 10             	add    $0x10,%esp
  802c73:	85 c0                	test   %eax,%eax
  802c75:	0f 88 e2 00 00 00    	js     802d5d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c7b:	83 ec 04             	sub    $0x4,%esp
  802c7e:	68 07 04 00 00       	push   $0x407
  802c83:	ff 75 f0             	pushl  -0x10(%ebp)
  802c86:	6a 00                	push   $0x0
  802c88:	e8 dc e8 ff ff       	call   801569 <sys_page_alloc>
  802c8d:	89 c3                	mov    %eax,%ebx
  802c8f:	83 c4 10             	add    $0x10,%esp
  802c92:	85 c0                	test   %eax,%eax
  802c94:	0f 88 c3 00 00 00    	js     802d5d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802c9a:	83 ec 0c             	sub    $0xc,%esp
  802c9d:	ff 75 f4             	pushl  -0xc(%ebp)
  802ca0:	e8 c2 ee ff ff       	call   801b67 <fd2data>
  802ca5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802ca7:	83 c4 0c             	add    $0xc,%esp
  802caa:	68 07 04 00 00       	push   $0x407
  802caf:	50                   	push   %eax
  802cb0:	6a 00                	push   $0x0
  802cb2:	e8 b2 e8 ff ff       	call   801569 <sys_page_alloc>
  802cb7:	89 c3                	mov    %eax,%ebx
  802cb9:	83 c4 10             	add    $0x10,%esp
  802cbc:	85 c0                	test   %eax,%eax
  802cbe:	0f 88 89 00 00 00    	js     802d4d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cc4:	83 ec 0c             	sub    $0xc,%esp
  802cc7:	ff 75 f0             	pushl  -0x10(%ebp)
  802cca:	e8 98 ee ff ff       	call   801b67 <fd2data>
  802ccf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802cd6:	50                   	push   %eax
  802cd7:	6a 00                	push   $0x0
  802cd9:	56                   	push   %esi
  802cda:	6a 00                	push   $0x0
  802cdc:	e8 cb e8 ff ff       	call   8015ac <sys_page_map>
  802ce1:	89 c3                	mov    %eax,%ebx
  802ce3:	83 c4 20             	add    $0x20,%esp
  802ce6:	85 c0                	test   %eax,%eax
  802ce8:	78 55                	js     802d3f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802cea:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802cf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cf3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cf8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802cff:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d08:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d0d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d14:	83 ec 0c             	sub    $0xc,%esp
  802d17:	ff 75 f4             	pushl  -0xc(%ebp)
  802d1a:	e8 38 ee ff ff       	call   801b57 <fd2num>
  802d1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d22:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d24:	83 c4 04             	add    $0x4,%esp
  802d27:	ff 75 f0             	pushl  -0x10(%ebp)
  802d2a:	e8 28 ee ff ff       	call   801b57 <fd2num>
  802d2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d32:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802d35:	83 c4 10             	add    $0x10,%esp
  802d38:	ba 00 00 00 00       	mov    $0x0,%edx
  802d3d:	eb 30                	jmp    802d6f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802d3f:	83 ec 08             	sub    $0x8,%esp
  802d42:	56                   	push   %esi
  802d43:	6a 00                	push   $0x0
  802d45:	e8 a4 e8 ff ff       	call   8015ee <sys_page_unmap>
  802d4a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802d4d:	83 ec 08             	sub    $0x8,%esp
  802d50:	ff 75 f0             	pushl  -0x10(%ebp)
  802d53:	6a 00                	push   $0x0
  802d55:	e8 94 e8 ff ff       	call   8015ee <sys_page_unmap>
  802d5a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802d5d:	83 ec 08             	sub    $0x8,%esp
  802d60:	ff 75 f4             	pushl  -0xc(%ebp)
  802d63:	6a 00                	push   $0x0
  802d65:	e8 84 e8 ff ff       	call   8015ee <sys_page_unmap>
  802d6a:	83 c4 10             	add    $0x10,%esp
  802d6d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802d6f:	89 d0                	mov    %edx,%eax
  802d71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d74:	5b                   	pop    %ebx
  802d75:	5e                   	pop    %esi
  802d76:	5d                   	pop    %ebp
  802d77:	c3                   	ret    

00802d78 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802d78:	55                   	push   %ebp
  802d79:	89 e5                	mov    %esp,%ebp
  802d7b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d81:	50                   	push   %eax
  802d82:	ff 75 08             	pushl  0x8(%ebp)
  802d85:	e8 43 ee ff ff       	call   801bcd <fd_lookup>
  802d8a:	83 c4 10             	add    $0x10,%esp
  802d8d:	85 c0                	test   %eax,%eax
  802d8f:	78 18                	js     802da9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802d91:	83 ec 0c             	sub    $0xc,%esp
  802d94:	ff 75 f4             	pushl  -0xc(%ebp)
  802d97:	e8 cb ed ff ff       	call   801b67 <fd2data>
	return _pipeisclosed(fd, p);
  802d9c:	89 c2                	mov    %eax,%edx
  802d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802da1:	e8 21 fd ff ff       	call   802ac7 <_pipeisclosed>
  802da6:	83 c4 10             	add    $0x10,%esp
}
  802da9:	c9                   	leave  
  802daa:	c3                   	ret    

00802dab <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802dab:	55                   	push   %ebp
  802dac:	89 e5                	mov    %esp,%ebp
  802dae:	56                   	push   %esi
  802daf:	53                   	push   %ebx
  802db0:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802db3:	85 f6                	test   %esi,%esi
  802db5:	75 16                	jne    802dcd <wait+0x22>
  802db7:	68 97 39 80 00       	push   $0x803997
  802dbc:	68 86 33 80 00       	push   $0x803386
  802dc1:	6a 09                	push   $0x9
  802dc3:	68 a2 39 80 00       	push   $0x8039a2
  802dc8:	e8 48 dc ff ff       	call   800a15 <_panic>
	e = &envs[ENVX(envid)];
  802dcd:	89 f3                	mov    %esi,%ebx
  802dcf:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802dd5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802dd8:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802dde:	eb 05                	jmp    802de5 <wait+0x3a>
		sys_yield();
  802de0:	e8 65 e7 ff ff       	call   80154a <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802de5:	8b 43 48             	mov    0x48(%ebx),%eax
  802de8:	39 c6                	cmp    %eax,%esi
  802dea:	75 07                	jne    802df3 <wait+0x48>
  802dec:	8b 43 54             	mov    0x54(%ebx),%eax
  802def:	85 c0                	test   %eax,%eax
  802df1:	75 ed                	jne    802de0 <wait+0x35>
		sys_yield();
}
  802df3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802df6:	5b                   	pop    %ebx
  802df7:	5e                   	pop    %esi
  802df8:	5d                   	pop    %ebp
  802df9:	c3                   	ret    

00802dfa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802dfa:	55                   	push   %ebp
  802dfb:	89 e5                	mov    %esp,%ebp
  802dfd:	53                   	push   %ebx
  802dfe:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802e01:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802e08:	75 28                	jne    802e32 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802e0a:	e8 1c e7 ff ff       	call   80152b <sys_getenvid>
  802e0f:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802e11:	83 ec 04             	sub    $0x4,%esp
  802e14:	6a 06                	push   $0x6
  802e16:	68 00 f0 bf ee       	push   $0xeebff000
  802e1b:	50                   	push   %eax
  802e1c:	e8 48 e7 ff ff       	call   801569 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802e21:	83 c4 08             	add    $0x8,%esp
  802e24:	68 3f 2e 80 00       	push   $0x802e3f
  802e29:	53                   	push   %ebx
  802e2a:	e8 85 e8 ff ff       	call   8016b4 <sys_env_set_pgfault_upcall>
  802e2f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802e32:	8b 45 08             	mov    0x8(%ebp),%eax
  802e35:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802e3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e3d:	c9                   	leave  
  802e3e:	c3                   	ret    

00802e3f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802e3f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802e40:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802e45:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802e47:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802e4a:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802e4c:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802e4f:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802e52:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802e55:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802e58:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802e5b:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802e5e:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802e61:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802e64:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802e67:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802e6a:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802e6d:	61                   	popa   
	popfl
  802e6e:	9d                   	popf   
	ret
  802e6f:	c3                   	ret    

00802e70 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802e70:	55                   	push   %ebp
  802e71:	89 e5                	mov    %esp,%ebp
  802e73:	56                   	push   %esi
  802e74:	53                   	push   %ebx
  802e75:	8b 75 08             	mov    0x8(%ebp),%esi
  802e78:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802e7e:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802e80:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802e85:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  802e88:	83 ec 0c             	sub    $0xc,%esp
  802e8b:	50                   	push   %eax
  802e8c:	e8 88 e8 ff ff       	call   801719 <sys_ipc_recv>

	if (r < 0) {
  802e91:	83 c4 10             	add    $0x10,%esp
  802e94:	85 c0                	test   %eax,%eax
  802e96:	79 16                	jns    802eae <ipc_recv+0x3e>
		if (from_env_store)
  802e98:	85 f6                	test   %esi,%esi
  802e9a:	74 06                	je     802ea2 <ipc_recv+0x32>
			*from_env_store = 0;
  802e9c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802ea2:	85 db                	test   %ebx,%ebx
  802ea4:	74 2c                	je     802ed2 <ipc_recv+0x62>
			*perm_store = 0;
  802ea6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802eac:	eb 24                	jmp    802ed2 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802eae:	85 f6                	test   %esi,%esi
  802eb0:	74 0a                	je     802ebc <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802eb2:	a1 24 54 80 00       	mov    0x805424,%eax
  802eb7:	8b 40 74             	mov    0x74(%eax),%eax
  802eba:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  802ebc:	85 db                	test   %ebx,%ebx
  802ebe:	74 0a                	je     802eca <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  802ec0:	a1 24 54 80 00       	mov    0x805424,%eax
  802ec5:	8b 40 78             	mov    0x78(%eax),%eax
  802ec8:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  802eca:	a1 24 54 80 00       	mov    0x805424,%eax
  802ecf:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  802ed2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ed5:	5b                   	pop    %ebx
  802ed6:	5e                   	pop    %esi
  802ed7:	5d                   	pop    %ebp
  802ed8:	c3                   	ret    

00802ed9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802ed9:	55                   	push   %ebp
  802eda:	89 e5                	mov    %esp,%ebp
  802edc:	57                   	push   %edi
  802edd:	56                   	push   %esi
  802ede:	53                   	push   %ebx
  802edf:	83 ec 0c             	sub    $0xc,%esp
  802ee2:	8b 7d 08             	mov    0x8(%ebp),%edi
  802ee5:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ee8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  802eeb:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802eed:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802ef2:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802ef5:	ff 75 14             	pushl  0x14(%ebp)
  802ef8:	53                   	push   %ebx
  802ef9:	56                   	push   %esi
  802efa:	57                   	push   %edi
  802efb:	e8 f6 e7 ff ff       	call   8016f6 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802f00:	83 c4 10             	add    $0x10,%esp
  802f03:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802f06:	75 07                	jne    802f0f <ipc_send+0x36>
			sys_yield();
  802f08:	e8 3d e6 ff ff       	call   80154a <sys_yield>
  802f0d:	eb e6                	jmp    802ef5 <ipc_send+0x1c>
		} else if (r < 0) {
  802f0f:	85 c0                	test   %eax,%eax
  802f11:	79 12                	jns    802f25 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802f13:	50                   	push   %eax
  802f14:	68 ad 39 80 00       	push   $0x8039ad
  802f19:	6a 51                	push   $0x51
  802f1b:	68 ba 39 80 00       	push   $0x8039ba
  802f20:	e8 f0 da ff ff       	call   800a15 <_panic>
		}
	}
}
  802f25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f28:	5b                   	pop    %ebx
  802f29:	5e                   	pop    %esi
  802f2a:	5f                   	pop    %edi
  802f2b:	5d                   	pop    %ebp
  802f2c:	c3                   	ret    

00802f2d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802f2d:	55                   	push   %ebp
  802f2e:	89 e5                	mov    %esp,%ebp
  802f30:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802f33:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802f38:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802f3b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802f41:	8b 52 50             	mov    0x50(%edx),%edx
  802f44:	39 ca                	cmp    %ecx,%edx
  802f46:	75 0d                	jne    802f55 <ipc_find_env+0x28>
			return envs[i].env_id;
  802f48:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802f4b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802f50:	8b 40 48             	mov    0x48(%eax),%eax
  802f53:	eb 0f                	jmp    802f64 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802f55:	83 c0 01             	add    $0x1,%eax
  802f58:	3d 00 04 00 00       	cmp    $0x400,%eax
  802f5d:	75 d9                	jne    802f38 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802f5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f64:	5d                   	pop    %ebp
  802f65:	c3                   	ret    

00802f66 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f66:	55                   	push   %ebp
  802f67:	89 e5                	mov    %esp,%ebp
  802f69:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f6c:	89 d0                	mov    %edx,%eax
  802f6e:	c1 e8 16             	shr    $0x16,%eax
  802f71:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802f78:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f7d:	f6 c1 01             	test   $0x1,%cl
  802f80:	74 1d                	je     802f9f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802f82:	c1 ea 0c             	shr    $0xc,%edx
  802f85:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802f8c:	f6 c2 01             	test   $0x1,%dl
  802f8f:	74 0e                	je     802f9f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802f91:	c1 ea 0c             	shr    $0xc,%edx
  802f94:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802f9b:	ef 
  802f9c:	0f b7 c0             	movzwl %ax,%eax
}
  802f9f:	5d                   	pop    %ebp
  802fa0:	c3                   	ret    
  802fa1:	66 90                	xchg   %ax,%ax
  802fa3:	66 90                	xchg   %ax,%ax
  802fa5:	66 90                	xchg   %ax,%ax
  802fa7:	66 90                	xchg   %ax,%ax
  802fa9:	66 90                	xchg   %ax,%ax
  802fab:	66 90                	xchg   %ax,%ax
  802fad:	66 90                	xchg   %ax,%ax
  802faf:	90                   	nop

00802fb0 <__udivdi3>:
  802fb0:	55                   	push   %ebp
  802fb1:	57                   	push   %edi
  802fb2:	56                   	push   %esi
  802fb3:	53                   	push   %ebx
  802fb4:	83 ec 1c             	sub    $0x1c,%esp
  802fb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  802fbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  802fbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802fc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802fc7:	85 f6                	test   %esi,%esi
  802fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802fcd:	89 ca                	mov    %ecx,%edx
  802fcf:	89 f8                	mov    %edi,%eax
  802fd1:	75 3d                	jne    803010 <__udivdi3+0x60>
  802fd3:	39 cf                	cmp    %ecx,%edi
  802fd5:	0f 87 c5 00 00 00    	ja     8030a0 <__udivdi3+0xf0>
  802fdb:	85 ff                	test   %edi,%edi
  802fdd:	89 fd                	mov    %edi,%ebp
  802fdf:	75 0b                	jne    802fec <__udivdi3+0x3c>
  802fe1:	b8 01 00 00 00       	mov    $0x1,%eax
  802fe6:	31 d2                	xor    %edx,%edx
  802fe8:	f7 f7                	div    %edi
  802fea:	89 c5                	mov    %eax,%ebp
  802fec:	89 c8                	mov    %ecx,%eax
  802fee:	31 d2                	xor    %edx,%edx
  802ff0:	f7 f5                	div    %ebp
  802ff2:	89 c1                	mov    %eax,%ecx
  802ff4:	89 d8                	mov    %ebx,%eax
  802ff6:	89 cf                	mov    %ecx,%edi
  802ff8:	f7 f5                	div    %ebp
  802ffa:	89 c3                	mov    %eax,%ebx
  802ffc:	89 d8                	mov    %ebx,%eax
  802ffe:	89 fa                	mov    %edi,%edx
  803000:	83 c4 1c             	add    $0x1c,%esp
  803003:	5b                   	pop    %ebx
  803004:	5e                   	pop    %esi
  803005:	5f                   	pop    %edi
  803006:	5d                   	pop    %ebp
  803007:	c3                   	ret    
  803008:	90                   	nop
  803009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803010:	39 ce                	cmp    %ecx,%esi
  803012:	77 74                	ja     803088 <__udivdi3+0xd8>
  803014:	0f bd fe             	bsr    %esi,%edi
  803017:	83 f7 1f             	xor    $0x1f,%edi
  80301a:	0f 84 98 00 00 00    	je     8030b8 <__udivdi3+0x108>
  803020:	bb 20 00 00 00       	mov    $0x20,%ebx
  803025:	89 f9                	mov    %edi,%ecx
  803027:	89 c5                	mov    %eax,%ebp
  803029:	29 fb                	sub    %edi,%ebx
  80302b:	d3 e6                	shl    %cl,%esi
  80302d:	89 d9                	mov    %ebx,%ecx
  80302f:	d3 ed                	shr    %cl,%ebp
  803031:	89 f9                	mov    %edi,%ecx
  803033:	d3 e0                	shl    %cl,%eax
  803035:	09 ee                	or     %ebp,%esi
  803037:	89 d9                	mov    %ebx,%ecx
  803039:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80303d:	89 d5                	mov    %edx,%ebp
  80303f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803043:	d3 ed                	shr    %cl,%ebp
  803045:	89 f9                	mov    %edi,%ecx
  803047:	d3 e2                	shl    %cl,%edx
  803049:	89 d9                	mov    %ebx,%ecx
  80304b:	d3 e8                	shr    %cl,%eax
  80304d:	09 c2                	or     %eax,%edx
  80304f:	89 d0                	mov    %edx,%eax
  803051:	89 ea                	mov    %ebp,%edx
  803053:	f7 f6                	div    %esi
  803055:	89 d5                	mov    %edx,%ebp
  803057:	89 c3                	mov    %eax,%ebx
  803059:	f7 64 24 0c          	mull   0xc(%esp)
  80305d:	39 d5                	cmp    %edx,%ebp
  80305f:	72 10                	jb     803071 <__udivdi3+0xc1>
  803061:	8b 74 24 08          	mov    0x8(%esp),%esi
  803065:	89 f9                	mov    %edi,%ecx
  803067:	d3 e6                	shl    %cl,%esi
  803069:	39 c6                	cmp    %eax,%esi
  80306b:	73 07                	jae    803074 <__udivdi3+0xc4>
  80306d:	39 d5                	cmp    %edx,%ebp
  80306f:	75 03                	jne    803074 <__udivdi3+0xc4>
  803071:	83 eb 01             	sub    $0x1,%ebx
  803074:	31 ff                	xor    %edi,%edi
  803076:	89 d8                	mov    %ebx,%eax
  803078:	89 fa                	mov    %edi,%edx
  80307a:	83 c4 1c             	add    $0x1c,%esp
  80307d:	5b                   	pop    %ebx
  80307e:	5e                   	pop    %esi
  80307f:	5f                   	pop    %edi
  803080:	5d                   	pop    %ebp
  803081:	c3                   	ret    
  803082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803088:	31 ff                	xor    %edi,%edi
  80308a:	31 db                	xor    %ebx,%ebx
  80308c:	89 d8                	mov    %ebx,%eax
  80308e:	89 fa                	mov    %edi,%edx
  803090:	83 c4 1c             	add    $0x1c,%esp
  803093:	5b                   	pop    %ebx
  803094:	5e                   	pop    %esi
  803095:	5f                   	pop    %edi
  803096:	5d                   	pop    %ebp
  803097:	c3                   	ret    
  803098:	90                   	nop
  803099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8030a0:	89 d8                	mov    %ebx,%eax
  8030a2:	f7 f7                	div    %edi
  8030a4:	31 ff                	xor    %edi,%edi
  8030a6:	89 c3                	mov    %eax,%ebx
  8030a8:	89 d8                	mov    %ebx,%eax
  8030aa:	89 fa                	mov    %edi,%edx
  8030ac:	83 c4 1c             	add    $0x1c,%esp
  8030af:	5b                   	pop    %ebx
  8030b0:	5e                   	pop    %esi
  8030b1:	5f                   	pop    %edi
  8030b2:	5d                   	pop    %ebp
  8030b3:	c3                   	ret    
  8030b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8030b8:	39 ce                	cmp    %ecx,%esi
  8030ba:	72 0c                	jb     8030c8 <__udivdi3+0x118>
  8030bc:	31 db                	xor    %ebx,%ebx
  8030be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8030c2:	0f 87 34 ff ff ff    	ja     802ffc <__udivdi3+0x4c>
  8030c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8030cd:	e9 2a ff ff ff       	jmp    802ffc <__udivdi3+0x4c>
  8030d2:	66 90                	xchg   %ax,%ax
  8030d4:	66 90                	xchg   %ax,%ax
  8030d6:	66 90                	xchg   %ax,%ax
  8030d8:	66 90                	xchg   %ax,%ax
  8030da:	66 90                	xchg   %ax,%ax
  8030dc:	66 90                	xchg   %ax,%ax
  8030de:	66 90                	xchg   %ax,%ax

008030e0 <__umoddi3>:
  8030e0:	55                   	push   %ebp
  8030e1:	57                   	push   %edi
  8030e2:	56                   	push   %esi
  8030e3:	53                   	push   %ebx
  8030e4:	83 ec 1c             	sub    $0x1c,%esp
  8030e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8030eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8030ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8030f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8030f7:	85 d2                	test   %edx,%edx
  8030f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8030fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803101:	89 f3                	mov    %esi,%ebx
  803103:	89 3c 24             	mov    %edi,(%esp)
  803106:	89 74 24 04          	mov    %esi,0x4(%esp)
  80310a:	75 1c                	jne    803128 <__umoddi3+0x48>
  80310c:	39 f7                	cmp    %esi,%edi
  80310e:	76 50                	jbe    803160 <__umoddi3+0x80>
  803110:	89 c8                	mov    %ecx,%eax
  803112:	89 f2                	mov    %esi,%edx
  803114:	f7 f7                	div    %edi
  803116:	89 d0                	mov    %edx,%eax
  803118:	31 d2                	xor    %edx,%edx
  80311a:	83 c4 1c             	add    $0x1c,%esp
  80311d:	5b                   	pop    %ebx
  80311e:	5e                   	pop    %esi
  80311f:	5f                   	pop    %edi
  803120:	5d                   	pop    %ebp
  803121:	c3                   	ret    
  803122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803128:	39 f2                	cmp    %esi,%edx
  80312a:	89 d0                	mov    %edx,%eax
  80312c:	77 52                	ja     803180 <__umoddi3+0xa0>
  80312e:	0f bd ea             	bsr    %edx,%ebp
  803131:	83 f5 1f             	xor    $0x1f,%ebp
  803134:	75 5a                	jne    803190 <__umoddi3+0xb0>
  803136:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80313a:	0f 82 e0 00 00 00    	jb     803220 <__umoddi3+0x140>
  803140:	39 0c 24             	cmp    %ecx,(%esp)
  803143:	0f 86 d7 00 00 00    	jbe    803220 <__umoddi3+0x140>
  803149:	8b 44 24 08          	mov    0x8(%esp),%eax
  80314d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803151:	83 c4 1c             	add    $0x1c,%esp
  803154:	5b                   	pop    %ebx
  803155:	5e                   	pop    %esi
  803156:	5f                   	pop    %edi
  803157:	5d                   	pop    %ebp
  803158:	c3                   	ret    
  803159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803160:	85 ff                	test   %edi,%edi
  803162:	89 fd                	mov    %edi,%ebp
  803164:	75 0b                	jne    803171 <__umoddi3+0x91>
  803166:	b8 01 00 00 00       	mov    $0x1,%eax
  80316b:	31 d2                	xor    %edx,%edx
  80316d:	f7 f7                	div    %edi
  80316f:	89 c5                	mov    %eax,%ebp
  803171:	89 f0                	mov    %esi,%eax
  803173:	31 d2                	xor    %edx,%edx
  803175:	f7 f5                	div    %ebp
  803177:	89 c8                	mov    %ecx,%eax
  803179:	f7 f5                	div    %ebp
  80317b:	89 d0                	mov    %edx,%eax
  80317d:	eb 99                	jmp    803118 <__umoddi3+0x38>
  80317f:	90                   	nop
  803180:	89 c8                	mov    %ecx,%eax
  803182:	89 f2                	mov    %esi,%edx
  803184:	83 c4 1c             	add    $0x1c,%esp
  803187:	5b                   	pop    %ebx
  803188:	5e                   	pop    %esi
  803189:	5f                   	pop    %edi
  80318a:	5d                   	pop    %ebp
  80318b:	c3                   	ret    
  80318c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803190:	8b 34 24             	mov    (%esp),%esi
  803193:	bf 20 00 00 00       	mov    $0x20,%edi
  803198:	89 e9                	mov    %ebp,%ecx
  80319a:	29 ef                	sub    %ebp,%edi
  80319c:	d3 e0                	shl    %cl,%eax
  80319e:	89 f9                	mov    %edi,%ecx
  8031a0:	89 f2                	mov    %esi,%edx
  8031a2:	d3 ea                	shr    %cl,%edx
  8031a4:	89 e9                	mov    %ebp,%ecx
  8031a6:	09 c2                	or     %eax,%edx
  8031a8:	89 d8                	mov    %ebx,%eax
  8031aa:	89 14 24             	mov    %edx,(%esp)
  8031ad:	89 f2                	mov    %esi,%edx
  8031af:	d3 e2                	shl    %cl,%edx
  8031b1:	89 f9                	mov    %edi,%ecx
  8031b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8031b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8031bb:	d3 e8                	shr    %cl,%eax
  8031bd:	89 e9                	mov    %ebp,%ecx
  8031bf:	89 c6                	mov    %eax,%esi
  8031c1:	d3 e3                	shl    %cl,%ebx
  8031c3:	89 f9                	mov    %edi,%ecx
  8031c5:	89 d0                	mov    %edx,%eax
  8031c7:	d3 e8                	shr    %cl,%eax
  8031c9:	89 e9                	mov    %ebp,%ecx
  8031cb:	09 d8                	or     %ebx,%eax
  8031cd:	89 d3                	mov    %edx,%ebx
  8031cf:	89 f2                	mov    %esi,%edx
  8031d1:	f7 34 24             	divl   (%esp)
  8031d4:	89 d6                	mov    %edx,%esi
  8031d6:	d3 e3                	shl    %cl,%ebx
  8031d8:	f7 64 24 04          	mull   0x4(%esp)
  8031dc:	39 d6                	cmp    %edx,%esi
  8031de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8031e2:	89 d1                	mov    %edx,%ecx
  8031e4:	89 c3                	mov    %eax,%ebx
  8031e6:	72 08                	jb     8031f0 <__umoddi3+0x110>
  8031e8:	75 11                	jne    8031fb <__umoddi3+0x11b>
  8031ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8031ee:	73 0b                	jae    8031fb <__umoddi3+0x11b>
  8031f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8031f4:	1b 14 24             	sbb    (%esp),%edx
  8031f7:	89 d1                	mov    %edx,%ecx
  8031f9:	89 c3                	mov    %eax,%ebx
  8031fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8031ff:	29 da                	sub    %ebx,%edx
  803201:	19 ce                	sbb    %ecx,%esi
  803203:	89 f9                	mov    %edi,%ecx
  803205:	89 f0                	mov    %esi,%eax
  803207:	d3 e0                	shl    %cl,%eax
  803209:	89 e9                	mov    %ebp,%ecx
  80320b:	d3 ea                	shr    %cl,%edx
  80320d:	89 e9                	mov    %ebp,%ecx
  80320f:	d3 ee                	shr    %cl,%esi
  803211:	09 d0                	or     %edx,%eax
  803213:	89 f2                	mov    %esi,%edx
  803215:	83 c4 1c             	add    $0x1c,%esp
  803218:	5b                   	pop    %ebx
  803219:	5e                   	pop    %esi
  80321a:	5f                   	pop    %edi
  80321b:	5d                   	pop    %ebp
  80321c:	c3                   	ret    
  80321d:	8d 76 00             	lea    0x0(%esi),%esi
  803220:	29 f9                	sub    %edi,%ecx
  803222:	19 d6                	sbb    %edx,%esi
  803224:	89 74 24 04          	mov    %esi,0x4(%esp)
  803228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80322c:	e9 18 ff ff ff       	jmp    803149 <__umoddi3+0x69>
