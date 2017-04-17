
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 93 02 00 00       	call   8002c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 42 27 80 00       	push   $0x802742
  80005f:	e8 b3 19 00 00       	call   801a17 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 3a                	je     8000a5 <ls1+0x72>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 a8 27 80 00       	mov    $0x8027a8,%eax
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1e                	je     800093 <ls1+0x60>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 cb 08 00 00       	call   800949 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
		else
			sep = "";
  800081:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800086:	ba a8 27 80 00       	mov    $0x8027a8,%edx
  80008b:	b8 40 27 80 00       	mov    $0x802740,%eax
  800090:	0f 44 c2             	cmove  %edx,%eax
		printf("%s%s", prefix, sep);
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	50                   	push   %eax
  800097:	53                   	push   %ebx
  800098:	68 4b 27 80 00       	push   $0x80274b
  80009d:	e8 75 19 00 00       	call   801a17 <printf>
  8000a2:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	ff 75 14             	pushl  0x14(%ebp)
  8000ab:	68 de 2b 80 00       	push   $0x802bde
  8000b0:	e8 62 19 00 00       	call   801a17 <printf>
	if(flag['F'] && isdir)
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000bf:	74 16                	je     8000d7 <ls1+0xa4>
  8000c1:	89 f0                	mov    %esi,%eax
  8000c3:	84 c0                	test   %al,%al
  8000c5:	74 10                	je     8000d7 <ls1+0xa4>
		printf("/");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 40 27 80 00       	push   $0x802740
  8000cf:	e8 43 19 00 00       	call   801a17 <printf>
  8000d4:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 a7 27 80 00       	push   $0x8027a7
  8000df:	e8 33 19 00 00       	call   801a17 <printf>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
  8000f4:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fd:	6a 00                	push   $0x0
  8000ff:	57                   	push   %edi
  800100:	e8 74 17 00 00       	call   801879 <open>
  800105:	89 c3                	mov    %eax,%ebx
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	85 c0                	test   %eax,%eax
  80010c:	79 41                	jns    80014f <lsdir+0x61>
		panic("open %s: %e", path, fd);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	57                   	push   %edi
  800113:	68 50 27 80 00       	push   $0x802750
  800118:	6a 1d                	push   $0x1d
  80011a:	68 5c 27 80 00       	push   $0x80275c
  80011f:	e8 00 02 00 00       	call   800324 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800124:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012b:	74 28                	je     800155 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012d:	56                   	push   %esi
  80012e:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800134:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013b:	0f 94 c0             	sete   %al
  80013e:	0f b6 c0             	movzbl %al,%eax
  800141:	50                   	push   %eax
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	e8 e9 fe ff ff       	call   800033 <ls1>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	eb 06                	jmp    800155 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014f:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800155:	83 ec 04             	sub    $0x4,%esp
  800158:	68 00 01 00 00       	push   $0x100
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	e8 f2 12 00 00       	call   801456 <readn>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016c:	74 b6                	je     800124 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 12                	jle    800184 <lsdir+0x96>
		panic("short read in directory %s", path);
  800172:	57                   	push   %edi
  800173:	68 66 27 80 00       	push   $0x802766
  800178:	6a 22                	push   $0x22
  80017a:	68 5c 27 80 00       	push   $0x80275c
  80017f:	e8 a0 01 00 00       	call   800324 <_panic>
	if (n < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	79 16                	jns    80019e <lsdir+0xb0>
		panic("error reading directory %s: %e", path, n);
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	50                   	push   %eax
  80018c:	57                   	push   %edi
  80018d:	68 ac 27 80 00       	push   $0x8027ac
  800192:	6a 24                	push   $0x24
  800194:	68 5c 27 80 00       	push   $0x80275c
  800199:	e8 86 01 00 00       	call   800324 <_panic>
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b9:	50                   	push   %eax
  8001ba:	53                   	push   %ebx
  8001bb:	e8 9b 14 00 00       	call   80165b <stat>
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	79 16                	jns    8001dd <ls+0x37>
		panic("stat %s: %e", path, r);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	53                   	push   %ebx
  8001cc:	68 81 27 80 00       	push   $0x802781
  8001d1:	6a 0f                	push   $0xf
  8001d3:	68 5c 27 80 00       	push   $0x80275c
  8001d8:	e8 47 01 00 00       	call   800324 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	74 1a                	je     8001fe <ls+0x58>
  8001e4:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  8001eb:	75 11                	jne    8001fe <ls+0x58>
		lsdir(path, prefix);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	53                   	push   %ebx
  8001f4:	e8 f5 fe ff ff       	call   8000ee <lsdir>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb 17                	jmp    800215 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 ec             	pushl  -0x14(%ebp)
  800202:	85 c0                	test   %eax,%eax
  800204:	0f 95 c0             	setne  %al
  800207:	0f b6 c0             	movzbl %al,%eax
  80020a:	50                   	push   %eax
  80020b:	6a 00                	push   $0x0
  80020d:	e8 21 fe ff ff       	call   800033 <ls1>
  800212:	83 c4 10             	add    $0x10,%esp
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <usage>:
	printf("\n");
}

void
usage(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800220:	68 8d 27 80 00       	push   $0x80278d
  800225:	e8 ed 17 00 00       	call   801a17 <printf>
	exit();
  80022a:	e8 db 00 00 00       	call   80030a <exit>
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <umain>:

void
umain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 14             	sub    $0x14,%esp
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	56                   	push   %esi
  800244:	8d 45 08             	lea    0x8(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 48 0d 00 00       	call   800f95 <argstart>
	while ((i = argnext(&args)) >= 0)
  80024d:	83 c4 10             	add    $0x10,%esp
  800250:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800253:	eb 1e                	jmp    800273 <umain+0x3f>
		switch (i) {
  800255:	83 f8 64             	cmp    $0x64,%eax
  800258:	74 0a                	je     800264 <umain+0x30>
  80025a:	83 f8 6c             	cmp    $0x6c,%eax
  80025d:	74 05                	je     800264 <umain+0x30>
  80025f:	83 f8 46             	cmp    $0x46,%eax
  800262:	75 0a                	jne    80026e <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800264:	83 04 85 20 40 80 00 	addl   $0x1,0x804020(,%eax,4)
  80026b:	01 
			break;
  80026c:	eb 05                	jmp    800273 <umain+0x3f>
		default:
			usage();
  80026e:	e8 a7 ff ff ff       	call   80021a <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	53                   	push   %ebx
  800277:	e8 49 0d 00 00       	call   800fc5 <argnext>
  80027c:	83 c4 10             	add    $0x10,%esp
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 d2                	jns    800255 <umain+0x21>
  800283:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800288:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028c:	75 2a                	jne    8002b8 <umain+0x84>
		ls("/", "");
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	68 a8 27 80 00       	push   $0x8027a8
  800296:	68 40 27 80 00       	push   $0x802740
  80029b:	e8 06 ff ff ff       	call   8001a6 <ls>
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	eb 18                	jmp    8002bd <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	50                   	push   %eax
  8002ac:	50                   	push   %eax
  8002ad:	e8 f4 fe ff ff       	call   8001a6 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b2:	83 c3 01             	add    $0x1,%ebx
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002bb:	7c e8                	jl     8002a5 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002cf:	e8 73 0a 00 00       	call   800d47 <sys_getenvid>
  8002d4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002dc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e1:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e6:	85 db                	test   %ebx,%ebx
  8002e8:	7e 07                	jle    8002f1 <libmain+0x2d>
		binaryname = argv[0];
  8002ea:	8b 06                	mov    (%esi),%eax
  8002ec:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f1:	83 ec 08             	sub    $0x8,%esp
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	e8 39 ff ff ff       	call   800234 <umain>

	// exit gracefully
	exit();
  8002fb:	e8 0a 00 00 00       	call   80030a <exit>
}
  800300:	83 c4 10             	add    $0x10,%esp
  800303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800310:	e8 9f 0f 00 00       	call   8012b4 <close_all>
	sys_env_destroy(0);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	6a 00                	push   $0x0
  80031a:	e8 e7 09 00 00       	call   800d06 <sys_env_destroy>
}
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	c9                   	leave  
  800323:	c3                   	ret    

00800324 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800329:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800332:	e8 10 0a 00 00       	call   800d47 <sys_getenvid>
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	ff 75 0c             	pushl  0xc(%ebp)
  80033d:	ff 75 08             	pushl  0x8(%ebp)
  800340:	56                   	push   %esi
  800341:	50                   	push   %eax
  800342:	68 d8 27 80 00       	push   $0x8027d8
  800347:	e8 b1 00 00 00       	call   8003fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034c:	83 c4 18             	add    $0x18,%esp
  80034f:	53                   	push   %ebx
  800350:	ff 75 10             	pushl  0x10(%ebp)
  800353:	e8 54 00 00 00       	call   8003ac <vcprintf>
	cprintf("\n");
  800358:	c7 04 24 a7 27 80 00 	movl   $0x8027a7,(%esp)
  80035f:	e8 99 00 00 00       	call   8003fd <cprintf>
  800364:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800367:	cc                   	int3   
  800368:	eb fd                	jmp    800367 <_panic+0x43>

0080036a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	53                   	push   %ebx
  80036e:	83 ec 04             	sub    $0x4,%esp
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800374:	8b 13                	mov    (%ebx),%edx
  800376:	8d 42 01             	lea    0x1(%edx),%eax
  800379:	89 03                	mov    %eax,(%ebx)
  80037b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800382:	3d ff 00 00 00       	cmp    $0xff,%eax
  800387:	75 1a                	jne    8003a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	68 ff 00 00 00       	push   $0xff
  800391:	8d 43 08             	lea    0x8(%ebx),%eax
  800394:	50                   	push   %eax
  800395:	e8 2f 09 00 00       	call   800cc9 <sys_cputs>
		b->idx = 0;
  80039a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bc:	00 00 00 
	b.cnt = 0;
  8003bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c9:	ff 75 0c             	pushl  0xc(%ebp)
  8003cc:	ff 75 08             	pushl  0x8(%ebp)
  8003cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	68 6a 03 80 00       	push   $0x80036a
  8003db:	e8 54 01 00 00       	call   800534 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e0:	83 c4 08             	add    $0x8,%esp
  8003e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	e8 d4 08 00 00       	call   800cc9 <sys_cputs>

	return b.cnt;
}
  8003f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800403:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800406:	50                   	push   %eax
  800407:	ff 75 08             	pushl  0x8(%ebp)
  80040a:	e8 9d ff ff ff       	call   8003ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 1c             	sub    $0x1c,%esp
  80041a:	89 c7                	mov    %eax,%edi
  80041c:	89 d6                	mov    %edx,%esi
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800427:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80042a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80042d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800435:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800438:	39 d3                	cmp    %edx,%ebx
  80043a:	72 05                	jb     800441 <printnum+0x30>
  80043c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80043f:	77 45                	ja     800486 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800441:	83 ec 0c             	sub    $0xc,%esp
  800444:	ff 75 18             	pushl  0x18(%ebp)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80044d:	53                   	push   %ebx
  80044e:	ff 75 10             	pushl  0x10(%ebp)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 e4             	pushl  -0x1c(%ebp)
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff 75 dc             	pushl  -0x24(%ebp)
  80045d:	ff 75 d8             	pushl  -0x28(%ebp)
  800460:	e8 4b 20 00 00       	call   8024b0 <__udivdi3>
  800465:	83 c4 18             	add    $0x18,%esp
  800468:	52                   	push   %edx
  800469:	50                   	push   %eax
  80046a:	89 f2                	mov    %esi,%edx
  80046c:	89 f8                	mov    %edi,%eax
  80046e:	e8 9e ff ff ff       	call   800411 <printnum>
  800473:	83 c4 20             	add    $0x20,%esp
  800476:	eb 18                	jmp    800490 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 18             	pushl  0x18(%ebp)
  80047f:	ff d7                	call   *%edi
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	eb 03                	jmp    800489 <printnum+0x78>
  800486:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f e8                	jg     800478 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	pushl  -0x1c(%ebp)
  80049a:	ff 75 e0             	pushl  -0x20(%ebp)
  80049d:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a3:	e8 38 21 00 00       	call   8025e0 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 fb 27 80 00 	movsbl 0x8027fb(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c3:	83 fa 01             	cmp    $0x1,%edx
  8004c6:	7e 0e                	jle    8004d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 02                	mov    (%edx),%eax
  8004d1:	8b 52 04             	mov    0x4(%edx),%edx
  8004d4:	eb 22                	jmp    8004f8 <getuint+0x38>
	else if (lflag)
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 10                	je     8004ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	eb 0e                	jmp    8004f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 02                	mov    (%edx),%eax
  8004f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f8:	5d                   	pop    %ebp
  8004f9:	c3                   	ret    

008004fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800500:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800504:	8b 10                	mov    (%eax),%edx
  800506:	3b 50 04             	cmp    0x4(%eax),%edx
  800509:	73 0a                	jae    800515 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050e:	89 08                	mov    %ecx,(%eax)
  800510:	8b 45 08             	mov    0x8(%ebp),%eax
  800513:	88 02                	mov    %al,(%edx)
}
  800515:	5d                   	pop    %ebp
  800516:	c3                   	ret    

00800517 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800520:	50                   	push   %eax
  800521:	ff 75 10             	pushl  0x10(%ebp)
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 05 00 00 00       	call   800534 <vprintfmt>
	va_end(ap);
}
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 2c             	sub    $0x2c,%esp
  80053d:	8b 75 08             	mov    0x8(%ebp),%esi
  800540:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800543:	8b 7d 10             	mov    0x10(%ebp),%edi
  800546:	eb 12                	jmp    80055a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800548:	85 c0                	test   %eax,%eax
  80054a:	0f 84 89 03 00 00    	je     8008d9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	53                   	push   %ebx
  800554:	50                   	push   %eax
  800555:	ff d6                	call   *%esi
  800557:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80055a:	83 c7 01             	add    $0x1,%edi
  80055d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800561:	83 f8 25             	cmp    $0x25,%eax
  800564:	75 e2                	jne    800548 <vprintfmt+0x14>
  800566:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80056a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800571:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800578:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057f:	ba 00 00 00 00       	mov    $0x0,%edx
  800584:	eb 07                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800589:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8d 47 01             	lea    0x1(%edi),%eax
  800590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800593:	0f b6 07             	movzbl (%edi),%eax
  800596:	0f b6 c8             	movzbl %al,%ecx
  800599:	83 e8 23             	sub    $0x23,%eax
  80059c:	3c 55                	cmp    $0x55,%al
  80059e:	0f 87 1a 03 00 00    	ja     8008be <vprintfmt+0x38a>
  8005a4:	0f b6 c0             	movzbl %al,%eax
  8005a7:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b5:	eb d6                	jmp    80058d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005cc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005cf:	83 fa 09             	cmp    $0x9,%edx
  8005d2:	77 39                	ja     80060d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005d4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d7:	eb e9                	jmp    8005c2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8005df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ea:	eb 27                	jmp    800613 <vprintfmt+0xdf>
  8005ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f6:	0f 49 c8             	cmovns %eax,%ecx
  8005f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ff:	eb 8c                	jmp    80058d <vprintfmt+0x59>
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800604:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80060b:	eb 80                	jmp    80058d <vprintfmt+0x59>
  80060d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800610:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800613:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800617:	0f 89 70 ff ff ff    	jns    80058d <vprintfmt+0x59>
				width = precision, precision = -1;
  80061d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800620:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800623:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80062a:	e9 5e ff ff ff       	jmp    80058d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800635:	e9 53 ff ff ff       	jmp    80058d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 50 04             	lea    0x4(%eax),%edx
  800640:	89 55 14             	mov    %edx,0x14(%ebp)
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	ff 30                	pushl  (%eax)
  800649:	ff d6                	call   *%esi
			break;
  80064b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800651:	e9 04 ff ff ff       	jmp    80055a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	99                   	cltd   
  800662:	31 d0                	xor    %edx,%eax
  800664:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800666:	83 f8 0f             	cmp    $0xf,%eax
  800669:	7f 0b                	jg     800676 <vprintfmt+0x142>
  80066b:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	75 18                	jne    80068e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 13 28 80 00       	push   $0x802813
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 94 fe ff ff       	call   800517 <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800689:	e9 cc fe ff ff       	jmp    80055a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80068e:	52                   	push   %edx
  80068f:	68 de 2b 80 00       	push   $0x802bde
  800694:	53                   	push   %ebx
  800695:	56                   	push   %esi
  800696:	e8 7c fe ff ff       	call   800517 <printfmt>
  80069b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a1:	e9 b4 fe ff ff       	jmp    80055a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	b8 0c 28 80 00       	mov    $0x80280c,%eax
  8006b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bf:	0f 8e 94 00 00 00    	jle    800759 <vprintfmt+0x225>
  8006c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c9:	0f 84 98 00 00 00    	je     800767 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d5:	57                   	push   %edi
  8006d6:	e8 86 02 00 00       	call   800961 <strnlen>
  8006db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f2:	eb 0f                	jmp    800703 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fd:	83 ef 01             	sub    $0x1,%edi
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 ff                	test   %edi,%edi
  800705:	7f ed                	jg     8006f4 <vprintfmt+0x1c0>
  800707:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	0f 49 c1             	cmovns %ecx,%eax
  800717:	29 c1                	sub    %eax,%ecx
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	89 cb                	mov    %ecx,%ebx
  800724:	eb 4d                	jmp    800773 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800726:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072a:	74 1b                	je     800747 <vprintfmt+0x213>
  80072c:	0f be c0             	movsbl %al,%eax
  80072f:	83 e8 20             	sub    $0x20,%eax
  800732:	83 f8 5e             	cmp    $0x5e,%eax
  800735:	76 10                	jbe    800747 <vprintfmt+0x213>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	6a 3f                	push   $0x3f
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 0d                	jmp    800754 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	52                   	push   %edx
  80074e:	ff 55 08             	call   *0x8(%ebp)
  800751:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	eb 1a                	jmp    800773 <vprintfmt+0x23f>
  800759:	89 75 08             	mov    %esi,0x8(%ebp)
  80075c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800762:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800765:	eb 0c                	jmp    800773 <vprintfmt+0x23f>
  800767:	89 75 08             	mov    %esi,0x8(%ebp)
  80076a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800773:	83 c7 01             	add    $0x1,%edi
  800776:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077a:	0f be d0             	movsbl %al,%edx
  80077d:	85 d2                	test   %edx,%edx
  80077f:	74 23                	je     8007a4 <vprintfmt+0x270>
  800781:	85 f6                	test   %esi,%esi
  800783:	78 a1                	js     800726 <vprintfmt+0x1f2>
  800785:	83 ee 01             	sub    $0x1,%esi
  800788:	79 9c                	jns    800726 <vprintfmt+0x1f2>
  80078a:	89 df                	mov    %ebx,%edi
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800792:	eb 18                	jmp    8007ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 20                	push   $0x20
  80079a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079c:	83 ef 01             	sub    $0x1,%edi
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 08                	jmp    8007ac <vprintfmt+0x278>
  8007a4:	89 df                	mov    %ebx,%edi
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ac:	85 ff                	test   %edi,%edi
  8007ae:	7f e4                	jg     800794 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b3:	e9 a2 fd ff ff       	jmp    80055a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b8:	83 fa 01             	cmp    $0x1,%edx
  8007bb:	7e 16                	jle    8007d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 08             	lea    0x8(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c6:	8b 50 04             	mov    0x4(%eax),%edx
  8007c9:	8b 00                	mov    (%eax),%eax
  8007cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d1:	eb 32                	jmp    800805 <vprintfmt+0x2d1>
	else if (lflag)
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	74 18                	je     8007ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 04             	lea    0x4(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e5:	89 c1                	mov    %eax,%ecx
  8007e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ed:	eb 16                	jmp    800805 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fd:	89 c1                	mov    %eax,%ecx
  8007ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800802:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800805:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800808:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800810:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800814:	79 74                	jns    80088a <vprintfmt+0x356>
				putch('-', putdat);
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	53                   	push   %ebx
  80081a:	6a 2d                	push   $0x2d
  80081c:	ff d6                	call   *%esi
				num = -(long long) num;
  80081e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800821:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800824:	f7 d8                	neg    %eax
  800826:	83 d2 00             	adc    $0x0,%edx
  800829:	f7 da                	neg    %edx
  80082b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80082e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800833:	eb 55                	jmp    80088a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	e8 83 fc ff ff       	call   8004c0 <getuint>
			base = 10;
  80083d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800842:	eb 46                	jmp    80088a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800844:	8d 45 14             	lea    0x14(%ebp),%eax
  800847:	e8 74 fc ff ff       	call   8004c0 <getuint>
                        base = 8;
  80084c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800851:	eb 37                	jmp    80088a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 30                	push   $0x30
  800859:	ff d6                	call   *%esi
			putch('x', putdat);
  80085b:	83 c4 08             	add    $0x8,%esp
  80085e:	53                   	push   %ebx
  80085f:	6a 78                	push   $0x78
  800861:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8d 50 04             	lea    0x4(%eax),%edx
  800869:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80086c:	8b 00                	mov    (%eax),%eax
  80086e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800873:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800876:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80087b:	eb 0d                	jmp    80088a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80087d:	8d 45 14             	lea    0x14(%ebp),%eax
  800880:	e8 3b fc ff ff       	call   8004c0 <getuint>
			base = 16;
  800885:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80088a:	83 ec 0c             	sub    $0xc,%esp
  80088d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800891:	57                   	push   %edi
  800892:	ff 75 e0             	pushl  -0x20(%ebp)
  800895:	51                   	push   %ecx
  800896:	52                   	push   %edx
  800897:	50                   	push   %eax
  800898:	89 da                	mov    %ebx,%edx
  80089a:	89 f0                	mov    %esi,%eax
  80089c:	e8 70 fb ff ff       	call   800411 <printnum>
			break;
  8008a1:	83 c4 20             	add    $0x20,%esp
  8008a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a7:	e9 ae fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	51                   	push   %ecx
  8008b1:	ff d6                	call   *%esi
			break;
  8008b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008b9:	e9 9c fc ff ff       	jmp    80055a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	6a 25                	push   $0x25
  8008c4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c6:	83 c4 10             	add    $0x10,%esp
  8008c9:	eb 03                	jmp    8008ce <vprintfmt+0x39a>
  8008cb:	83 ef 01             	sub    $0x1,%edi
  8008ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008d2:	75 f7                	jne    8008cb <vprintfmt+0x397>
  8008d4:	e9 81 fc ff ff       	jmp    80055a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5f                   	pop    %edi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	83 ec 18             	sub    $0x18,%esp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fe:	85 c0                	test   %eax,%eax
  800900:	74 26                	je     800928 <vsnprintf+0x47>
  800902:	85 d2                	test   %edx,%edx
  800904:	7e 22                	jle    800928 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800906:	ff 75 14             	pushl  0x14(%ebp)
  800909:	ff 75 10             	pushl  0x10(%ebp)
  80090c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090f:	50                   	push   %eax
  800910:	68 fa 04 80 00       	push   $0x8004fa
  800915:	e8 1a fc ff ff       	call   800534 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800920:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	eb 05                	jmp    80092d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800928:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800935:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800938:	50                   	push   %eax
  800939:	ff 75 10             	pushl  0x10(%ebp)
  80093c:	ff 75 0c             	pushl  0xc(%ebp)
  80093f:	ff 75 08             	pushl  0x8(%ebp)
  800942:	e8 9a ff ff ff       	call   8008e1 <vsnprintf>
	va_end(ap);

	return rc;
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb 03                	jmp    800959 <strlen+0x10>
		n++;
  800956:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800959:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095d:	75 f7                	jne    800956 <strlen+0xd>
		n++;
	return n;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	eb 03                	jmp    800974 <strnlen+0x13>
		n++;
  800971:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800974:	39 c2                	cmp    %eax,%edx
  800976:	74 08                	je     800980 <strnlen+0x1f>
  800978:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80097c:	75 f3                	jne    800971 <strnlen+0x10>
  80097e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80098c:	89 c2                	mov    %eax,%edx
  80098e:	83 c2 01             	add    $0x1,%edx
  800991:	83 c1 01             	add    $0x1,%ecx
  800994:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800998:	88 5a ff             	mov    %bl,-0x1(%edx)
  80099b:	84 db                	test   %bl,%bl
  80099d:	75 ef                	jne    80098e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a9:	53                   	push   %ebx
  8009aa:	e8 9a ff ff ff       	call   800949 <strlen>
  8009af:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009b2:	ff 75 0c             	pushl  0xc(%ebp)
  8009b5:	01 d8                	add    %ebx,%eax
  8009b7:	50                   	push   %eax
  8009b8:	e8 c5 ff ff ff       	call   800982 <strcpy>
	return dst;
}
  8009bd:	89 d8                	mov    %ebx,%eax
  8009bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d4:	89 f2                	mov    %esi,%edx
  8009d6:	eb 0f                	jmp    8009e7 <strncpy+0x23>
		*dst++ = *src;
  8009d8:	83 c2 01             	add    $0x1,%edx
  8009db:	0f b6 01             	movzbl (%ecx),%eax
  8009de:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e1:	80 39 01             	cmpb   $0x1,(%ecx)
  8009e4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e7:	39 da                	cmp    %ebx,%edx
  8009e9:	75 ed                	jne    8009d8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009eb:	89 f0                	mov    %esi,%eax
  8009ed:	5b                   	pop    %ebx
  8009ee:	5e                   	pop    %esi
  8009ef:	5d                   	pop    %ebp
  8009f0:	c3                   	ret    

008009f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fc:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a01:	85 d2                	test   %edx,%edx
  800a03:	74 21                	je     800a26 <strlcpy+0x35>
  800a05:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a09:	89 f2                	mov    %esi,%edx
  800a0b:	eb 09                	jmp    800a16 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a0d:	83 c2 01             	add    $0x1,%edx
  800a10:	83 c1 01             	add    $0x1,%ecx
  800a13:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a16:	39 c2                	cmp    %eax,%edx
  800a18:	74 09                	je     800a23 <strlcpy+0x32>
  800a1a:	0f b6 19             	movzbl (%ecx),%ebx
  800a1d:	84 db                	test   %bl,%bl
  800a1f:	75 ec                	jne    800a0d <strlcpy+0x1c>
  800a21:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a23:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a26:	29 f0                	sub    %esi,%eax
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a35:	eb 06                	jmp    800a3d <strcmp+0x11>
		p++, q++;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3d:	0f b6 01             	movzbl (%ecx),%eax
  800a40:	84 c0                	test   %al,%al
  800a42:	74 04                	je     800a48 <strcmp+0x1c>
  800a44:	3a 02                	cmp    (%edx),%al
  800a46:	74 ef                	je     800a37 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a48:	0f b6 c0             	movzbl %al,%eax
  800a4b:	0f b6 12             	movzbl (%edx),%edx
  800a4e:	29 d0                	sub    %edx,%eax
}
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	53                   	push   %ebx
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a61:	eb 06                	jmp    800a69 <strncmp+0x17>
		n--, p++, q++;
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a69:	39 d8                	cmp    %ebx,%eax
  800a6b:	74 15                	je     800a82 <strncmp+0x30>
  800a6d:	0f b6 08             	movzbl (%eax),%ecx
  800a70:	84 c9                	test   %cl,%cl
  800a72:	74 04                	je     800a78 <strncmp+0x26>
  800a74:	3a 0a                	cmp    (%edx),%cl
  800a76:	74 eb                	je     800a63 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a78:	0f b6 00             	movzbl (%eax),%eax
  800a7b:	0f b6 12             	movzbl (%edx),%edx
  800a7e:	29 d0                	sub    %edx,%eax
  800a80:	eb 05                	jmp    800a87 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a87:	5b                   	pop    %ebx
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a94:	eb 07                	jmp    800a9d <strchr+0x13>
		if (*s == c)
  800a96:	38 ca                	cmp    %cl,%dl
  800a98:	74 0f                	je     800aa9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	75 f2                	jne    800a96 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab5:	eb 03                	jmp    800aba <strfind+0xf>
  800ab7:	83 c0 01             	add    $0x1,%eax
  800aba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800abd:	38 ca                	cmp    %cl,%dl
  800abf:	74 04                	je     800ac5 <strfind+0x1a>
  800ac1:	84 d2                	test   %dl,%dl
  800ac3:	75 f2                	jne    800ab7 <strfind+0xc>
			break;
	return (char *) s;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad3:	85 c9                	test   %ecx,%ecx
  800ad5:	74 36                	je     800b0d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800add:	75 28                	jne    800b07 <memset+0x40>
  800adf:	f6 c1 03             	test   $0x3,%cl
  800ae2:	75 23                	jne    800b07 <memset+0x40>
		c &= 0xFF;
  800ae4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	c1 e3 08             	shl    $0x8,%ebx
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	c1 e6 18             	shl    $0x18,%esi
  800af2:	89 d0                	mov    %edx,%eax
  800af4:	c1 e0 10             	shl    $0x10,%eax
  800af7:	09 f0                	or     %esi,%eax
  800af9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800afb:	89 d8                	mov    %ebx,%eax
  800afd:	09 d0                	or     %edx,%eax
  800aff:	c1 e9 02             	shr    $0x2,%ecx
  800b02:	fc                   	cld    
  800b03:	f3 ab                	rep stos %eax,%es:(%edi)
  800b05:	eb 06                	jmp    800b0d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	fc                   	cld    
  800b0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0d:	89 f8                	mov    %edi,%eax
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b22:	39 c6                	cmp    %eax,%esi
  800b24:	73 35                	jae    800b5b <memmove+0x47>
  800b26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b29:	39 d0                	cmp    %edx,%eax
  800b2b:	73 2e                	jae    800b5b <memmove+0x47>
		s += n;
		d += n;
  800b2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	09 fe                	or     %edi,%esi
  800b34:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3a:	75 13                	jne    800b4f <memmove+0x3b>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 0e                	jne    800b4f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b41:	83 ef 04             	sub    $0x4,%edi
  800b44:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b47:	c1 e9 02             	shr    $0x2,%ecx
  800b4a:	fd                   	std    
  800b4b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4d:	eb 09                	jmp    800b58 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b4f:	83 ef 01             	sub    $0x1,%edi
  800b52:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b55:	fd                   	std    
  800b56:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b58:	fc                   	cld    
  800b59:	eb 1d                	jmp    800b78 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5b:	89 f2                	mov    %esi,%edx
  800b5d:	09 c2                	or     %eax,%edx
  800b5f:	f6 c2 03             	test   $0x3,%dl
  800b62:	75 0f                	jne    800b73 <memmove+0x5f>
  800b64:	f6 c1 03             	test   $0x3,%cl
  800b67:	75 0a                	jne    800b73 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b69:	c1 e9 02             	shr    $0x2,%ecx
  800b6c:	89 c7                	mov    %eax,%edi
  800b6e:	fc                   	cld    
  800b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b71:	eb 05                	jmp    800b78 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	fc                   	cld    
  800b76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b7f:	ff 75 10             	pushl  0x10(%ebp)
  800b82:	ff 75 0c             	pushl  0xc(%ebp)
  800b85:	ff 75 08             	pushl  0x8(%ebp)
  800b88:	e8 87 ff ff ff       	call   800b14 <memmove>
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9a:	89 c6                	mov    %eax,%esi
  800b9c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9f:	eb 1a                	jmp    800bbb <memcmp+0x2c>
		if (*s1 != *s2)
  800ba1:	0f b6 08             	movzbl (%eax),%ecx
  800ba4:	0f b6 1a             	movzbl (%edx),%ebx
  800ba7:	38 d9                	cmp    %bl,%cl
  800ba9:	74 0a                	je     800bb5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bab:	0f b6 c1             	movzbl %cl,%eax
  800bae:	0f b6 db             	movzbl %bl,%ebx
  800bb1:	29 d8                	sub    %ebx,%eax
  800bb3:	eb 0f                	jmp    800bc4 <memcmp+0x35>
		s1++, s2++;
  800bb5:	83 c0 01             	add    $0x1,%eax
  800bb8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbb:	39 f0                	cmp    %esi,%eax
  800bbd:	75 e2                	jne    800ba1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bcf:	89 c1                	mov    %eax,%ecx
  800bd1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd8:	eb 0a                	jmp    800be4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bda:	0f b6 10             	movzbl (%eax),%edx
  800bdd:	39 da                	cmp    %ebx,%edx
  800bdf:	74 07                	je     800be8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be1:	83 c0 01             	add    $0x1,%eax
  800be4:	39 c8                	cmp    %ecx,%eax
  800be6:	72 f2                	jb     800bda <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be8:	5b                   	pop    %ebx
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf7:	eb 03                	jmp    800bfc <strtol+0x11>
		s++;
  800bf9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfc:	0f b6 01             	movzbl (%ecx),%eax
  800bff:	3c 20                	cmp    $0x20,%al
  800c01:	74 f6                	je     800bf9 <strtol+0xe>
  800c03:	3c 09                	cmp    $0x9,%al
  800c05:	74 f2                	je     800bf9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c07:	3c 2b                	cmp    $0x2b,%al
  800c09:	75 0a                	jne    800c15 <strtol+0x2a>
		s++;
  800c0b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c13:	eb 11                	jmp    800c26 <strtol+0x3b>
  800c15:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c1a:	3c 2d                	cmp    $0x2d,%al
  800c1c:	75 08                	jne    800c26 <strtol+0x3b>
		s++, neg = 1;
  800c1e:	83 c1 01             	add    $0x1,%ecx
  800c21:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c2c:	75 15                	jne    800c43 <strtol+0x58>
  800c2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c31:	75 10                	jne    800c43 <strtol+0x58>
  800c33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c37:	75 7c                	jne    800cb5 <strtol+0xca>
		s += 2, base = 16;
  800c39:	83 c1 02             	add    $0x2,%ecx
  800c3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c41:	eb 16                	jmp    800c59 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	75 12                	jne    800c59 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c47:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4f:	75 08                	jne    800c59 <strtol+0x6e>
		s++, base = 8;
  800c51:	83 c1 01             	add    $0x1,%ecx
  800c54:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c59:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c61:	0f b6 11             	movzbl (%ecx),%edx
  800c64:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 09             	cmp    $0x9,%bl
  800c6c:	77 08                	ja     800c76 <strtol+0x8b>
			dig = *s - '0';
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 30             	sub    $0x30,%edx
  800c74:	eb 22                	jmp    800c98 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c76:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 08                	ja     800c88 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 57             	sub    $0x57,%edx
  800c86:	eb 10                	jmp    800c98 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c88:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	80 fb 19             	cmp    $0x19,%bl
  800c90:	77 16                	ja     800ca8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c92:	0f be d2             	movsbl %dl,%edx
  800c95:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c98:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c9b:	7d 0b                	jge    800ca8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ca6:	eb b9                	jmp    800c61 <strtol+0x76>

	if (endptr)
  800ca8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cac:	74 0d                	je     800cbb <strtol+0xd0>
		*endptr = (char *) s;
  800cae:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb1:	89 0e                	mov    %ecx,(%esi)
  800cb3:	eb 06                	jmp    800cbb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb5:	85 db                	test   %ebx,%ebx
  800cb7:	74 98                	je     800c51 <strtol+0x66>
  800cb9:	eb 9e                	jmp    800c59 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cbb:	89 c2                	mov    %eax,%edx
  800cbd:	f7 da                	neg    %edx
  800cbf:	85 ff                	test   %edi,%edi
  800cc1:	0f 45 c2             	cmovne %edx,%eax
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 c3                	mov    %eax,%ebx
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	89 c6                	mov    %eax,%esi
  800ce0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf7:	89 d1                	mov    %edx,%ecx
  800cf9:	89 d3                	mov    %edx,%ebx
  800cfb:	89 d7                	mov    %edx,%edi
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d14:	b8 03 00 00 00       	mov    $0x3,%eax
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 cb                	mov    %ecx,%ebx
  800d1e:	89 cf                	mov    %ecx,%edi
  800d20:	89 ce                	mov    %ecx,%esi
  800d22:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 17                	jle    800d3f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 03                	push   $0x3
  800d2e:	68 ff 2a 80 00       	push   $0x802aff
  800d33:	6a 23                	push   $0x23
  800d35:	68 1c 2b 80 00       	push   $0x802b1c
  800d3a:	e8 e5 f5 ff ff       	call   800324 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	b8 02 00 00 00       	mov    $0x2,%eax
  800d57:	89 d1                	mov    %edx,%ecx
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	89 d7                	mov    %edx,%edi
  800d5d:	89 d6                	mov    %edx,%esi
  800d5f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_yield>:

void
sys_yield(void)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d76:	89 d1                	mov    %edx,%ecx
  800d78:	89 d3                	mov    %edx,%ebx
  800d7a:	89 d7                	mov    %edx,%edi
  800d7c:	89 d6                	mov    %edx,%esi
  800d7e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	b8 04 00 00 00       	mov    $0x4,%eax
  800d98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da1:	89 f7                	mov    %esi,%edi
  800da3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 17                	jle    800dc0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	50                   	push   %eax
  800dad:	6a 04                	push   $0x4
  800daf:	68 ff 2a 80 00       	push   $0x802aff
  800db4:	6a 23                	push   $0x23
  800db6:	68 1c 2b 80 00       	push   $0x802b1c
  800dbb:	e8 64 f5 ff ff       	call   800324 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	8b 75 18             	mov    0x18(%ebp),%esi
  800de5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 17                	jle    800e02 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	50                   	push   %eax
  800def:	6a 05                	push   $0x5
  800df1:	68 ff 2a 80 00       	push   $0x802aff
  800df6:	6a 23                	push   $0x23
  800df8:	68 1c 2b 80 00       	push   $0x802b1c
  800dfd:	e8 22 f5 ff ff       	call   800324 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 17                	jle    800e44 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	50                   	push   %eax
  800e31:	6a 06                	push   $0x6
  800e33:	68 ff 2a 80 00       	push   $0x802aff
  800e38:	6a 23                	push   $0x23
  800e3a:	68 1c 2b 80 00       	push   $0x802b1c
  800e3f:	e8 e0 f4 ff ff       	call   800324 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e47:	5b                   	pop    %ebx
  800e48:	5e                   	pop    %esi
  800e49:	5f                   	pop    %edi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	b8 08 00 00 00       	mov    $0x8,%eax
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 17                	jle    800e86 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	50                   	push   %eax
  800e73:	6a 08                	push   $0x8
  800e75:	68 ff 2a 80 00       	push   $0x802aff
  800e7a:	6a 23                	push   $0x23
  800e7c:	68 1c 2b 80 00       	push   $0x802b1c
  800e81:	e8 9e f4 ff ff       	call   800324 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 17                	jle    800ec8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	50                   	push   %eax
  800eb5:	6a 09                	push   $0x9
  800eb7:	68 ff 2a 80 00       	push   $0x802aff
  800ebc:	6a 23                	push   $0x23
  800ebe:	68 1c 2b 80 00       	push   $0x802b1c
  800ec3:	e8 5c f4 ff ff       	call   800324 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ec8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecb:	5b                   	pop    %ebx
  800ecc:	5e                   	pop    %esi
  800ecd:	5f                   	pop    %edi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ede:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 de                	mov    %ebx,%esi
  800eed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	7e 17                	jle    800f0a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	50                   	push   %eax
  800ef7:	6a 0a                	push   $0xa
  800ef9:	68 ff 2a 80 00       	push   $0x802aff
  800efe:	6a 23                	push   $0x23
  800f00:	68 1c 2b 80 00       	push   $0x802b1c
  800f05:	e8 1a f4 ff ff       	call   800324 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	be 00 00 00 00       	mov    $0x0,%esi
  800f1d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 08             	mov    0x8(%ebp),%edx
  800f28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f2e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f43:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	89 cb                	mov    %ecx,%ebx
  800f4d:	89 cf                	mov    %ecx,%edi
  800f4f:	89 ce                	mov    %ecx,%esi
  800f51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f53:	85 c0                	test   %eax,%eax
  800f55:	7e 17                	jle    800f6e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	50                   	push   %eax
  800f5b:	6a 0d                	push   $0xd
  800f5d:	68 ff 2a 80 00       	push   $0x802aff
  800f62:	6a 23                	push   $0x23
  800f64:	68 1c 2b 80 00       	push   $0x802b1c
  800f69:	e8 b6 f3 ff ff       	call   800324 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f81:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f86:	89 d1                	mov    %edx,%ecx
  800f88:	89 d3                	mov    %edx,%ebx
  800f8a:	89 d7                	mov    %edx,%edi
  800f8c:	89 d6                	mov    %edx,%esi
  800f8e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f9e:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fa1:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800fa3:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fa6:	83 3a 01             	cmpl   $0x1,(%edx)
  800fa9:	7e 09                	jle    800fb4 <argstart+0x1f>
  800fab:	ba a8 27 80 00       	mov    $0x8027a8,%edx
  800fb0:	85 c9                	test   %ecx,%ecx
  800fb2:	75 05                	jne    800fb9 <argstart+0x24>
  800fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb9:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800fbc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <argnext>:

int
argnext(struct Argstate *args)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	53                   	push   %ebx
  800fc9:	83 ec 04             	sub    $0x4,%esp
  800fcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800fcf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800fd6:	8b 43 08             	mov    0x8(%ebx),%eax
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	74 6f                	je     80104c <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800fdd:	80 38 00             	cmpb   $0x0,(%eax)
  800fe0:	75 4e                	jne    801030 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800fe2:	8b 0b                	mov    (%ebx),%ecx
  800fe4:	83 39 01             	cmpl   $0x1,(%ecx)
  800fe7:	74 55                	je     80103e <argnext+0x79>
		    || args->argv[1][0] != '-'
  800fe9:	8b 53 04             	mov    0x4(%ebx),%edx
  800fec:	8b 42 04             	mov    0x4(%edx),%eax
  800fef:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ff2:	75 4a                	jne    80103e <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800ff4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800ff8:	74 44                	je     80103e <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800ffa:	83 c0 01             	add    $0x1,%eax
  800ffd:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801000:	83 ec 04             	sub    $0x4,%esp
  801003:	8b 01                	mov    (%ecx),%eax
  801005:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80100c:	50                   	push   %eax
  80100d:	8d 42 08             	lea    0x8(%edx),%eax
  801010:	50                   	push   %eax
  801011:	83 c2 04             	add    $0x4,%edx
  801014:	52                   	push   %edx
  801015:	e8 fa fa ff ff       	call   800b14 <memmove>
		(*args->argc)--;
  80101a:	8b 03                	mov    (%ebx),%eax
  80101c:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80101f:	8b 43 08             	mov    0x8(%ebx),%eax
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	80 38 2d             	cmpb   $0x2d,(%eax)
  801028:	75 06                	jne    801030 <argnext+0x6b>
  80102a:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80102e:	74 0e                	je     80103e <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801030:	8b 53 08             	mov    0x8(%ebx),%edx
  801033:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801036:	83 c2 01             	add    $0x1,%edx
  801039:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  80103c:	eb 13                	jmp    801051 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  80103e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801045:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80104a:	eb 05                	jmp    801051 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  80104c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	53                   	push   %ebx
  80105a:	83 ec 04             	sub    $0x4,%esp
  80105d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801060:	8b 43 08             	mov    0x8(%ebx),%eax
  801063:	85 c0                	test   %eax,%eax
  801065:	74 58                	je     8010bf <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801067:	80 38 00             	cmpb   $0x0,(%eax)
  80106a:	74 0c                	je     801078 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  80106c:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  80106f:	c7 43 08 a8 27 80 00 	movl   $0x8027a8,0x8(%ebx)
  801076:	eb 42                	jmp    8010ba <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801078:	8b 13                	mov    (%ebx),%edx
  80107a:	83 3a 01             	cmpl   $0x1,(%edx)
  80107d:	7e 2d                	jle    8010ac <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  80107f:	8b 43 04             	mov    0x4(%ebx),%eax
  801082:	8b 48 04             	mov    0x4(%eax),%ecx
  801085:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	8b 12                	mov    (%edx),%edx
  80108d:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801094:	52                   	push   %edx
  801095:	8d 50 08             	lea    0x8(%eax),%edx
  801098:	52                   	push   %edx
  801099:	83 c0 04             	add    $0x4,%eax
  80109c:	50                   	push   %eax
  80109d:	e8 72 fa ff ff       	call   800b14 <memmove>
		(*args->argc)--;
  8010a2:	8b 03                	mov    (%ebx),%eax
  8010a4:	83 28 01             	subl   $0x1,(%eax)
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	eb 0e                	jmp    8010ba <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8010ac:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010b3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8010ba:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010bd:	eb 05                	jmp    8010c4 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c7:	c9                   	leave  
  8010c8:	c3                   	ret    

008010c9 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	83 ec 08             	sub    $0x8,%esp
  8010cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010d2:	8b 51 0c             	mov    0xc(%ecx),%edx
  8010d5:	89 d0                	mov    %edx,%eax
  8010d7:	85 d2                	test   %edx,%edx
  8010d9:	75 0c                	jne    8010e7 <argvalue+0x1e>
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	51                   	push   %ecx
  8010df:	e8 72 ff ff ff       	call   801056 <argnextvalue>
  8010e4:	83 c4 10             	add    $0x10,%esp
}
  8010e7:	c9                   	leave  
  8010e8:	c3                   	ret    

008010e9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f4:	c1 e8 0c             	shr    $0xc,%eax
}
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ff:	05 00 00 00 30       	add    $0x30000000,%eax
  801104:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801109:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801116:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80111b:	89 c2                	mov    %eax,%edx
  80111d:	c1 ea 16             	shr    $0x16,%edx
  801120:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801127:	f6 c2 01             	test   $0x1,%dl
  80112a:	74 11                	je     80113d <fd_alloc+0x2d>
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	c1 ea 0c             	shr    $0xc,%edx
  801131:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801138:	f6 c2 01             	test   $0x1,%dl
  80113b:	75 09                	jne    801146 <fd_alloc+0x36>
			*fd_store = fd;
  80113d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80113f:	b8 00 00 00 00       	mov    $0x0,%eax
  801144:	eb 17                	jmp    80115d <fd_alloc+0x4d>
  801146:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80114b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801150:	75 c9                	jne    80111b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801152:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801158:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801165:	83 f8 1f             	cmp    $0x1f,%eax
  801168:	77 36                	ja     8011a0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80116a:	c1 e0 0c             	shl    $0xc,%eax
  80116d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801172:	89 c2                	mov    %eax,%edx
  801174:	c1 ea 16             	shr    $0x16,%edx
  801177:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117e:	f6 c2 01             	test   $0x1,%dl
  801181:	74 24                	je     8011a7 <fd_lookup+0x48>
  801183:	89 c2                	mov    %eax,%edx
  801185:	c1 ea 0c             	shr    $0xc,%edx
  801188:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118f:	f6 c2 01             	test   $0x1,%dl
  801192:	74 1a                	je     8011ae <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801194:	8b 55 0c             	mov    0xc(%ebp),%edx
  801197:	89 02                	mov    %eax,(%edx)
	return 0;
  801199:	b8 00 00 00 00       	mov    $0x0,%eax
  80119e:	eb 13                	jmp    8011b3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a5:	eb 0c                	jmp    8011b3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ac:	eb 05                	jmp    8011b3 <fd_lookup+0x54>
  8011ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	83 ec 08             	sub    $0x8,%esp
  8011bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011be:	ba ac 2b 80 00       	mov    $0x802bac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c3:	eb 13                	jmp    8011d8 <dev_lookup+0x23>
  8011c5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011c8:	39 08                	cmp    %ecx,(%eax)
  8011ca:	75 0c                	jne    8011d8 <dev_lookup+0x23>
			*dev = devtab[i];
  8011cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d6:	eb 2e                	jmp    801206 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d8:	8b 02                	mov    (%edx),%eax
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	75 e7                	jne    8011c5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011de:	a1 20 44 80 00       	mov    0x804420,%eax
  8011e3:	8b 40 48             	mov    0x48(%eax),%eax
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	51                   	push   %ecx
  8011ea:	50                   	push   %eax
  8011eb:	68 2c 2b 80 00       	push   $0x802b2c
  8011f0:	e8 08 f2 ff ff       	call   8003fd <cprintf>
	*dev = 0;
  8011f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 10             	sub    $0x10,%esp
  801210:	8b 75 08             	mov    0x8(%ebp),%esi
  801213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801220:	c1 e8 0c             	shr    $0xc,%eax
  801223:	50                   	push   %eax
  801224:	e8 36 ff ff ff       	call   80115f <fd_lookup>
  801229:	83 c4 08             	add    $0x8,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 05                	js     801235 <fd_close+0x2d>
	    || fd != fd2)
  801230:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801233:	74 0c                	je     801241 <fd_close+0x39>
		return (must_exist ? r : 0);
  801235:	84 db                	test   %bl,%bl
  801237:	ba 00 00 00 00       	mov    $0x0,%edx
  80123c:	0f 44 c2             	cmove  %edx,%eax
  80123f:	eb 41                	jmp    801282 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801241:	83 ec 08             	sub    $0x8,%esp
  801244:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801247:	50                   	push   %eax
  801248:	ff 36                	pushl  (%esi)
  80124a:	e8 66 ff ff ff       	call   8011b5 <dev_lookup>
  80124f:	89 c3                	mov    %eax,%ebx
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 1a                	js     801272 <fd_close+0x6a>
		if (dev->dev_close)
  801258:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80125e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801263:	85 c0                	test   %eax,%eax
  801265:	74 0b                	je     801272 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	56                   	push   %esi
  80126b:	ff d0                	call   *%eax
  80126d:	89 c3                	mov    %eax,%ebx
  80126f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801272:	83 ec 08             	sub    $0x8,%esp
  801275:	56                   	push   %esi
  801276:	6a 00                	push   $0x0
  801278:	e8 8d fb ff ff       	call   800e0a <sys_page_unmap>
	return r;
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	89 d8                	mov    %ebx,%eax
}
  801282:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801285:	5b                   	pop    %ebx
  801286:	5e                   	pop    %esi
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80128f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801292:	50                   	push   %eax
  801293:	ff 75 08             	pushl  0x8(%ebp)
  801296:	e8 c4 fe ff ff       	call   80115f <fd_lookup>
  80129b:	83 c4 08             	add    $0x8,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 10                	js     8012b2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	6a 01                	push   $0x1
  8012a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8012aa:	e8 59 ff ff ff       	call   801208 <fd_close>
  8012af:	83 c4 10             	add    $0x10,%esp
}
  8012b2:	c9                   	leave  
  8012b3:	c3                   	ret    

008012b4 <close_all>:

void
close_all(void)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	53                   	push   %ebx
  8012b8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c0:	83 ec 0c             	sub    $0xc,%esp
  8012c3:	53                   	push   %ebx
  8012c4:	e8 c0 ff ff ff       	call   801289 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c9:	83 c3 01             	add    $0x1,%ebx
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	83 fb 20             	cmp    $0x20,%ebx
  8012d2:	75 ec                	jne    8012c0 <close_all+0xc>
		close(i);
}
  8012d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d7:	c9                   	leave  
  8012d8:	c3                   	ret    

008012d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	57                   	push   %edi
  8012dd:	56                   	push   %esi
  8012de:	53                   	push   %ebx
  8012df:	83 ec 2c             	sub    $0x2c,%esp
  8012e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e8:	50                   	push   %eax
  8012e9:	ff 75 08             	pushl  0x8(%ebp)
  8012ec:	e8 6e fe ff ff       	call   80115f <fd_lookup>
  8012f1:	83 c4 08             	add    $0x8,%esp
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	0f 88 c1 00 00 00    	js     8013bd <dup+0xe4>
		return r;
	close(newfdnum);
  8012fc:	83 ec 0c             	sub    $0xc,%esp
  8012ff:	56                   	push   %esi
  801300:	e8 84 ff ff ff       	call   801289 <close>

	newfd = INDEX2FD(newfdnum);
  801305:	89 f3                	mov    %esi,%ebx
  801307:	c1 e3 0c             	shl    $0xc,%ebx
  80130a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801310:	83 c4 04             	add    $0x4,%esp
  801313:	ff 75 e4             	pushl  -0x1c(%ebp)
  801316:	e8 de fd ff ff       	call   8010f9 <fd2data>
  80131b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80131d:	89 1c 24             	mov    %ebx,(%esp)
  801320:	e8 d4 fd ff ff       	call   8010f9 <fd2data>
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80132b:	89 f8                	mov    %edi,%eax
  80132d:	c1 e8 16             	shr    $0x16,%eax
  801330:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801337:	a8 01                	test   $0x1,%al
  801339:	74 37                	je     801372 <dup+0x99>
  80133b:	89 f8                	mov    %edi,%eax
  80133d:	c1 e8 0c             	shr    $0xc,%eax
  801340:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801347:	f6 c2 01             	test   $0x1,%dl
  80134a:	74 26                	je     801372 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80134c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	25 07 0e 00 00       	and    $0xe07,%eax
  80135b:	50                   	push   %eax
  80135c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80135f:	6a 00                	push   $0x0
  801361:	57                   	push   %edi
  801362:	6a 00                	push   $0x0
  801364:	e8 5f fa ff ff       	call   800dc8 <sys_page_map>
  801369:	89 c7                	mov    %eax,%edi
  80136b:	83 c4 20             	add    $0x20,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 2e                	js     8013a0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801372:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801375:	89 d0                	mov    %edx,%eax
  801377:	c1 e8 0c             	shr    $0xc,%eax
  80137a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801381:	83 ec 0c             	sub    $0xc,%esp
  801384:	25 07 0e 00 00       	and    $0xe07,%eax
  801389:	50                   	push   %eax
  80138a:	53                   	push   %ebx
  80138b:	6a 00                	push   $0x0
  80138d:	52                   	push   %edx
  80138e:	6a 00                	push   $0x0
  801390:	e8 33 fa ff ff       	call   800dc8 <sys_page_map>
  801395:	89 c7                	mov    %eax,%edi
  801397:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80139a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80139c:	85 ff                	test   %edi,%edi
  80139e:	79 1d                	jns    8013bd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	53                   	push   %ebx
  8013a4:	6a 00                	push   $0x0
  8013a6:	e8 5f fa ff ff       	call   800e0a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ab:	83 c4 08             	add    $0x8,%esp
  8013ae:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b1:	6a 00                	push   $0x0
  8013b3:	e8 52 fa ff ff       	call   800e0a <sys_page_unmap>
	return r;
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	89 f8                	mov    %edi,%eax
}
  8013bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5e                   	pop    %esi
  8013c2:	5f                   	pop    %edi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	53                   	push   %ebx
  8013c9:	83 ec 14             	sub    $0x14,%esp
  8013cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013cf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d2:	50                   	push   %eax
  8013d3:	53                   	push   %ebx
  8013d4:	e8 86 fd ff ff       	call   80115f <fd_lookup>
  8013d9:	83 c4 08             	add    $0x8,%esp
  8013dc:	89 c2                	mov    %eax,%edx
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 6d                	js     80144f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ec:	ff 30                	pushl  (%eax)
  8013ee:	e8 c2 fd ff ff       	call   8011b5 <dev_lookup>
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 4c                	js     801446 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fd:	8b 42 08             	mov    0x8(%edx),%eax
  801400:	83 e0 03             	and    $0x3,%eax
  801403:	83 f8 01             	cmp    $0x1,%eax
  801406:	75 21                	jne    801429 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801408:	a1 20 44 80 00       	mov    0x804420,%eax
  80140d:	8b 40 48             	mov    0x48(%eax),%eax
  801410:	83 ec 04             	sub    $0x4,%esp
  801413:	53                   	push   %ebx
  801414:	50                   	push   %eax
  801415:	68 70 2b 80 00       	push   $0x802b70
  80141a:	e8 de ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801427:	eb 26                	jmp    80144f <read+0x8a>
	}
	if (!dev->dev_read)
  801429:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142c:	8b 40 08             	mov    0x8(%eax),%eax
  80142f:	85 c0                	test   %eax,%eax
  801431:	74 17                	je     80144a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801433:	83 ec 04             	sub    $0x4,%esp
  801436:	ff 75 10             	pushl  0x10(%ebp)
  801439:	ff 75 0c             	pushl  0xc(%ebp)
  80143c:	52                   	push   %edx
  80143d:	ff d0                	call   *%eax
  80143f:	89 c2                	mov    %eax,%edx
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	eb 09                	jmp    80144f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801446:	89 c2                	mov    %eax,%edx
  801448:	eb 05                	jmp    80144f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80144a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80144f:	89 d0                	mov    %edx,%eax
  801451:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801454:	c9                   	leave  
  801455:	c3                   	ret    

00801456 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801456:	55                   	push   %ebp
  801457:	89 e5                	mov    %esp,%ebp
  801459:	57                   	push   %edi
  80145a:	56                   	push   %esi
  80145b:	53                   	push   %ebx
  80145c:	83 ec 0c             	sub    $0xc,%esp
  80145f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801462:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801465:	bb 00 00 00 00       	mov    $0x0,%ebx
  80146a:	eb 21                	jmp    80148d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80146c:	83 ec 04             	sub    $0x4,%esp
  80146f:	89 f0                	mov    %esi,%eax
  801471:	29 d8                	sub    %ebx,%eax
  801473:	50                   	push   %eax
  801474:	89 d8                	mov    %ebx,%eax
  801476:	03 45 0c             	add    0xc(%ebp),%eax
  801479:	50                   	push   %eax
  80147a:	57                   	push   %edi
  80147b:	e8 45 ff ff ff       	call   8013c5 <read>
		if (m < 0)
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 10                	js     801497 <readn+0x41>
			return m;
		if (m == 0)
  801487:	85 c0                	test   %eax,%eax
  801489:	74 0a                	je     801495 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80148b:	01 c3                	add    %eax,%ebx
  80148d:	39 f3                	cmp    %esi,%ebx
  80148f:	72 db                	jb     80146c <readn+0x16>
  801491:	89 d8                	mov    %ebx,%eax
  801493:	eb 02                	jmp    801497 <readn+0x41>
  801495:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5f                   	pop    %edi
  80149d:	5d                   	pop    %ebp
  80149e:	c3                   	ret    

0080149f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	53                   	push   %ebx
  8014a3:	83 ec 14             	sub    $0x14,%esp
  8014a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	53                   	push   %ebx
  8014ae:	e8 ac fc ff ff       	call   80115f <fd_lookup>
  8014b3:	83 c4 08             	add    $0x8,%esp
  8014b6:	89 c2                	mov    %eax,%edx
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	78 68                	js     801524 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c6:	ff 30                	pushl  (%eax)
  8014c8:	e8 e8 fc ff ff       	call   8011b5 <dev_lookup>
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 47                	js     80151b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014db:	75 21                	jne    8014fe <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014dd:	a1 20 44 80 00       	mov    0x804420,%eax
  8014e2:	8b 40 48             	mov    0x48(%eax),%eax
  8014e5:	83 ec 04             	sub    $0x4,%esp
  8014e8:	53                   	push   %ebx
  8014e9:	50                   	push   %eax
  8014ea:	68 8c 2b 80 00       	push   $0x802b8c
  8014ef:	e8 09 ef ff ff       	call   8003fd <cprintf>
		return -E_INVAL;
  8014f4:	83 c4 10             	add    $0x10,%esp
  8014f7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fc:	eb 26                	jmp    801524 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801501:	8b 52 0c             	mov    0xc(%edx),%edx
  801504:	85 d2                	test   %edx,%edx
  801506:	74 17                	je     80151f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801508:	83 ec 04             	sub    $0x4,%esp
  80150b:	ff 75 10             	pushl  0x10(%ebp)
  80150e:	ff 75 0c             	pushl  0xc(%ebp)
  801511:	50                   	push   %eax
  801512:	ff d2                	call   *%edx
  801514:	89 c2                	mov    %eax,%edx
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	eb 09                	jmp    801524 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151b:	89 c2                	mov    %eax,%edx
  80151d:	eb 05                	jmp    801524 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80151f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801524:	89 d0                	mov    %edx,%eax
  801526:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <seek>:

int
seek(int fdnum, off_t offset)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801531:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	ff 75 08             	pushl  0x8(%ebp)
  801538:	e8 22 fc ff ff       	call   80115f <fd_lookup>
  80153d:	83 c4 08             	add    $0x8,%esp
  801540:	85 c0                	test   %eax,%eax
  801542:	78 0e                	js     801552 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801544:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801547:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80154d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	53                   	push   %ebx
  801558:	83 ec 14             	sub    $0x14,%esp
  80155b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	53                   	push   %ebx
  801563:	e8 f7 fb ff ff       	call   80115f <fd_lookup>
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	89 c2                	mov    %eax,%edx
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 65                	js     8015d6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801571:	83 ec 08             	sub    $0x8,%esp
  801574:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157b:	ff 30                	pushl  (%eax)
  80157d:	e8 33 fc ff ff       	call   8011b5 <dev_lookup>
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	85 c0                	test   %eax,%eax
  801587:	78 44                	js     8015cd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801589:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801590:	75 21                	jne    8015b3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801592:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801597:	8b 40 48             	mov    0x48(%eax),%eax
  80159a:	83 ec 04             	sub    $0x4,%esp
  80159d:	53                   	push   %ebx
  80159e:	50                   	push   %eax
  80159f:	68 4c 2b 80 00       	push   $0x802b4c
  8015a4:	e8 54 ee ff ff       	call   8003fd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b1:	eb 23                	jmp    8015d6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b6:	8b 52 18             	mov    0x18(%edx),%edx
  8015b9:	85 d2                	test   %edx,%edx
  8015bb:	74 14                	je     8015d1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	ff 75 0c             	pushl  0xc(%ebp)
  8015c3:	50                   	push   %eax
  8015c4:	ff d2                	call   *%edx
  8015c6:	89 c2                	mov    %eax,%edx
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	eb 09                	jmp    8015d6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cd:	89 c2                	mov    %eax,%edx
  8015cf:	eb 05                	jmp    8015d6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015d1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015d6:	89 d0                	mov    %edx,%eax
  8015d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 14             	sub    $0x14,%esp
  8015e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	ff 75 08             	pushl  0x8(%ebp)
  8015ee:	e8 6c fb ff ff       	call   80115f <fd_lookup>
  8015f3:	83 c4 08             	add    $0x8,%esp
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 58                	js     801654 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801606:	ff 30                	pushl  (%eax)
  801608:	e8 a8 fb ff ff       	call   8011b5 <dev_lookup>
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	85 c0                	test   %eax,%eax
  801612:	78 37                	js     80164b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801614:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801617:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80161b:	74 32                	je     80164f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80161d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801620:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801627:	00 00 00 
	stat->st_isdir = 0;
  80162a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801631:	00 00 00 
	stat->st_dev = dev;
  801634:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	53                   	push   %ebx
  80163e:	ff 75 f0             	pushl  -0x10(%ebp)
  801641:	ff 50 14             	call   *0x14(%eax)
  801644:	89 c2                	mov    %eax,%edx
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	eb 09                	jmp    801654 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164b:	89 c2                	mov    %eax,%edx
  80164d:	eb 05                	jmp    801654 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80164f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801654:	89 d0                	mov    %edx,%eax
  801656:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	56                   	push   %esi
  80165f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	6a 00                	push   $0x0
  801665:	ff 75 08             	pushl  0x8(%ebp)
  801668:	e8 0c 02 00 00       	call   801879 <open>
  80166d:	89 c3                	mov    %eax,%ebx
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 1b                	js     801691 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	ff 75 0c             	pushl  0xc(%ebp)
  80167c:	50                   	push   %eax
  80167d:	e8 5b ff ff ff       	call   8015dd <fstat>
  801682:	89 c6                	mov    %eax,%esi
	close(fd);
  801684:	89 1c 24             	mov    %ebx,(%esp)
  801687:	e8 fd fb ff ff       	call   801289 <close>
	return r;
  80168c:	83 c4 10             	add    $0x10,%esp
  80168f:	89 f0                	mov    %esi,%eax
}
  801691:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801694:	5b                   	pop    %ebx
  801695:	5e                   	pop    %esi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	56                   	push   %esi
  80169c:	53                   	push   %ebx
  80169d:	89 c6                	mov    %eax,%esi
  80169f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a8:	75 12                	jne    8016bc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016aa:	83 ec 0c             	sub    $0xc,%esp
  8016ad:	6a 01                	push   $0x1
  8016af:	e8 7c 0d 00 00       	call   802430 <ipc_find_env>
  8016b4:	a3 00 40 80 00       	mov    %eax,0x804000
  8016b9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016bc:	6a 07                	push   $0x7
  8016be:	68 00 50 80 00       	push   $0x805000
  8016c3:	56                   	push   %esi
  8016c4:	ff 35 00 40 80 00    	pushl  0x804000
  8016ca:	e8 0d 0d 00 00       	call   8023dc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016cf:	83 c4 0c             	add    $0xc,%esp
  8016d2:	6a 00                	push   $0x0
  8016d4:	53                   	push   %ebx
  8016d5:	6a 00                	push   $0x0
  8016d7:	e8 97 0c 00 00       	call   802373 <ipc_recv>
}
  8016dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016df:	5b                   	pop    %ebx
  8016e0:	5e                   	pop    %esi
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801701:	b8 02 00 00 00       	mov    $0x2,%eax
  801706:	e8 8d ff ff ff       	call   801698 <fsipc>
}
  80170b:	c9                   	leave  
  80170c:	c3                   	ret    

0080170d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80170d:	55                   	push   %ebp
  80170e:	89 e5                	mov    %esp,%ebp
  801710:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801713:	8b 45 08             	mov    0x8(%ebp),%eax
  801716:	8b 40 0c             	mov    0xc(%eax),%eax
  801719:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80171e:	ba 00 00 00 00       	mov    $0x0,%edx
  801723:	b8 06 00 00 00       	mov    $0x6,%eax
  801728:	e8 6b ff ff ff       	call   801698 <fsipc>
}
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	53                   	push   %ebx
  801733:	83 ec 04             	sub    $0x4,%esp
  801736:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801739:	8b 45 08             	mov    0x8(%ebp),%eax
  80173c:	8b 40 0c             	mov    0xc(%eax),%eax
  80173f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801744:	ba 00 00 00 00       	mov    $0x0,%edx
  801749:	b8 05 00 00 00       	mov    $0x5,%eax
  80174e:	e8 45 ff ff ff       	call   801698 <fsipc>
  801753:	85 c0                	test   %eax,%eax
  801755:	78 2c                	js     801783 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	68 00 50 80 00       	push   $0x805000
  80175f:	53                   	push   %ebx
  801760:	e8 1d f2 ff ff       	call   800982 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801765:	a1 80 50 80 00       	mov    0x805080,%eax
  80176a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801770:	a1 84 50 80 00       	mov    0x805084,%eax
  801775:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801786:	c9                   	leave  
  801787:	c3                   	ret    

00801788 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	83 ec 08             	sub    $0x8,%esp
  80178f:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801792:	8b 55 08             	mov    0x8(%ebp),%edx
  801795:	8b 52 0c             	mov    0xc(%edx),%edx
  801798:	89 15 00 50 80 00    	mov    %edx,0x805000
  80179e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017a3:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  8017a8:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  8017ab:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8017b1:	53                   	push   %ebx
  8017b2:	ff 75 0c             	pushl  0xc(%ebp)
  8017b5:	68 08 50 80 00       	push   $0x805008
  8017ba:	e8 55 f3 ff ff       	call   800b14 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8017bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c9:	e8 ca fe ff ff       	call   801698 <fsipc>
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 1d                	js     8017f2 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8017d5:	39 d8                	cmp    %ebx,%eax
  8017d7:	76 19                	jbe    8017f2 <devfile_write+0x6a>
  8017d9:	68 c0 2b 80 00       	push   $0x802bc0
  8017de:	68 cc 2b 80 00       	push   $0x802bcc
  8017e3:	68 a3 00 00 00       	push   $0xa3
  8017e8:	68 e1 2b 80 00       	push   $0x802be1
  8017ed:	e8 32 eb ff ff       	call   800324 <_panic>
	return r;
}
  8017f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	56                   	push   %esi
  8017fb:	53                   	push   %ebx
  8017fc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	8b 40 0c             	mov    0xc(%eax),%eax
  801805:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80180a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 03 00 00 00       	mov    $0x3,%eax
  80181a:	e8 79 fe ff ff       	call   801698 <fsipc>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	85 c0                	test   %eax,%eax
  801823:	78 4b                	js     801870 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801825:	39 c6                	cmp    %eax,%esi
  801827:	73 16                	jae    80183f <devfile_read+0x48>
  801829:	68 ec 2b 80 00       	push   $0x802bec
  80182e:	68 cc 2b 80 00       	push   $0x802bcc
  801833:	6a 7c                	push   $0x7c
  801835:	68 e1 2b 80 00       	push   $0x802be1
  80183a:	e8 e5 ea ff ff       	call   800324 <_panic>
	assert(r <= PGSIZE);
  80183f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801844:	7e 16                	jle    80185c <devfile_read+0x65>
  801846:	68 f3 2b 80 00       	push   $0x802bf3
  80184b:	68 cc 2b 80 00       	push   $0x802bcc
  801850:	6a 7d                	push   $0x7d
  801852:	68 e1 2b 80 00       	push   $0x802be1
  801857:	e8 c8 ea ff ff       	call   800324 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80185c:	83 ec 04             	sub    $0x4,%esp
  80185f:	50                   	push   %eax
  801860:	68 00 50 80 00       	push   $0x805000
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	e8 a7 f2 ff ff       	call   800b14 <memmove>
	return r;
  80186d:	83 c4 10             	add    $0x10,%esp
}
  801870:	89 d8                	mov    %ebx,%eax
  801872:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801875:	5b                   	pop    %ebx
  801876:	5e                   	pop    %esi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	53                   	push   %ebx
  80187d:	83 ec 20             	sub    $0x20,%esp
  801880:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801883:	53                   	push   %ebx
  801884:	e8 c0 f0 ff ff       	call   800949 <strlen>
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801891:	7f 67                	jg     8018fa <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801893:	83 ec 0c             	sub    $0xc,%esp
  801896:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801899:	50                   	push   %eax
  80189a:	e8 71 f8 ff ff       	call   801110 <fd_alloc>
  80189f:	83 c4 10             	add    $0x10,%esp
		return r;
  8018a2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 57                	js     8018ff <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	53                   	push   %ebx
  8018ac:	68 00 50 80 00       	push   $0x805000
  8018b1:	e8 cc f0 ff ff       	call   800982 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018c6:	e8 cd fd ff ff       	call   801698 <fsipc>
  8018cb:	89 c3                	mov    %eax,%ebx
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	79 14                	jns    8018e8 <open+0x6f>
		fd_close(fd, 0);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	6a 00                	push   $0x0
  8018d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018dc:	e8 27 f9 ff ff       	call   801208 <fd_close>
		return r;
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	89 da                	mov    %ebx,%edx
  8018e6:	eb 17                	jmp    8018ff <open+0x86>
	}

	return fd2num(fd);
  8018e8:	83 ec 0c             	sub    $0xc,%esp
  8018eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ee:	e8 f6 f7 ff ff       	call   8010e9 <fd2num>
  8018f3:	89 c2                	mov    %eax,%edx
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	eb 05                	jmp    8018ff <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018fa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018ff:	89 d0                	mov    %edx,%eax
  801901:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80190c:	ba 00 00 00 00       	mov    $0x0,%edx
  801911:	b8 08 00 00 00       	mov    $0x8,%eax
  801916:	e8 7d fd ff ff       	call   801698 <fsipc>
}
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80191d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801921:	7e 37                	jle    80195a <writebuf+0x3d>
};


static void
writebuf(struct printbuf *b)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	53                   	push   %ebx
  801927:	83 ec 08             	sub    $0x8,%esp
  80192a:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80192c:	ff 70 04             	pushl  0x4(%eax)
  80192f:	8d 40 10             	lea    0x10(%eax),%eax
  801932:	50                   	push   %eax
  801933:	ff 33                	pushl  (%ebx)
  801935:	e8 65 fb ff ff       	call   80149f <write>
		if (result > 0)
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	7e 03                	jle    801944 <writebuf+0x27>
			b->result += result;
  801941:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801944:	3b 43 04             	cmp    0x4(%ebx),%eax
  801947:	74 0d                	je     801956 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801949:	85 c0                	test   %eax,%eax
  80194b:	ba 00 00 00 00       	mov    $0x0,%edx
  801950:	0f 4f c2             	cmovg  %edx,%eax
  801953:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801959:	c9                   	leave  
  80195a:	f3 c3                	repz ret 

0080195c <putch>:

static void
putch(int ch, void *thunk)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	83 ec 04             	sub    $0x4,%esp
  801963:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801966:	8b 53 04             	mov    0x4(%ebx),%edx
  801969:	8d 42 01             	lea    0x1(%edx),%eax
  80196c:	89 43 04             	mov    %eax,0x4(%ebx)
  80196f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801972:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801976:	3d 00 01 00 00       	cmp    $0x100,%eax
  80197b:	75 0e                	jne    80198b <putch+0x2f>
		writebuf(b);
  80197d:	89 d8                	mov    %ebx,%eax
  80197f:	e8 99 ff ff ff       	call   80191d <writebuf>
		b->idx = 0;
  801984:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80198b:	83 c4 04             	add    $0x4,%esp
  80198e:	5b                   	pop    %ebx
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    

00801991 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80199a:	8b 45 08             	mov    0x8(%ebp),%eax
  80199d:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019a3:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019aa:	00 00 00 
	b.result = 0;
  8019ad:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019b4:	00 00 00 
	b.error = 1;
  8019b7:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019be:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019c1:	ff 75 10             	pushl  0x10(%ebp)
  8019c4:	ff 75 0c             	pushl  0xc(%ebp)
  8019c7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019cd:	50                   	push   %eax
  8019ce:	68 5c 19 80 00       	push   $0x80195c
  8019d3:	e8 5c eb ff ff       	call   800534 <vprintfmt>
	if (b.idx > 0)
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019e2:	7e 0b                	jle    8019ef <vfprintf+0x5e>
		writebuf(&b);
  8019e4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019ea:	e8 2e ff ff ff       	call   80191d <writebuf>

	return (b.result ? b.result : b.error);
  8019ef:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a06:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a09:	50                   	push   %eax
  801a0a:	ff 75 0c             	pushl  0xc(%ebp)
  801a0d:	ff 75 08             	pushl  0x8(%ebp)
  801a10:	e8 7c ff ff ff       	call   801991 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <printf>:

int
printf(const char *fmt, ...)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a1d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a20:	50                   	push   %eax
  801a21:	ff 75 08             	pushl  0x8(%ebp)
  801a24:	6a 01                	push   $0x1
  801a26:	e8 66 ff ff ff       	call   801991 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a33:	68 ff 2b 80 00       	push   $0x802bff
  801a38:	ff 75 0c             	pushl  0xc(%ebp)
  801a3b:	e8 42 ef ff ff       	call   800982 <strcpy>
	return 0;
}
  801a40:	b8 00 00 00 00       	mov    $0x0,%eax
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	53                   	push   %ebx
  801a4b:	83 ec 10             	sub    $0x10,%esp
  801a4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a51:	53                   	push   %ebx
  801a52:	e8 12 0a 00 00       	call   802469 <pageref>
  801a57:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a5a:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a5f:	83 f8 01             	cmp    $0x1,%eax
  801a62:	75 10                	jne    801a74 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a64:	83 ec 0c             	sub    $0xc,%esp
  801a67:	ff 73 0c             	pushl  0xc(%ebx)
  801a6a:	e8 c0 02 00 00       	call   801d2f <nsipc_close>
  801a6f:	89 c2                	mov    %eax,%edx
  801a71:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a74:	89 d0                	mov    %edx,%eax
  801a76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a81:	6a 00                	push   $0x0
  801a83:	ff 75 10             	pushl  0x10(%ebp)
  801a86:	ff 75 0c             	pushl  0xc(%ebp)
  801a89:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8c:	ff 70 0c             	pushl  0xc(%eax)
  801a8f:	e8 78 03 00 00       	call   801e0c <nsipc_send>
}
  801a94:	c9                   	leave  
  801a95:	c3                   	ret    

00801a96 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a9c:	6a 00                	push   $0x0
  801a9e:	ff 75 10             	pushl  0x10(%ebp)
  801aa1:	ff 75 0c             	pushl  0xc(%ebp)
  801aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa7:	ff 70 0c             	pushl  0xc(%eax)
  801aaa:	e8 f1 02 00 00       	call   801da0 <nsipc_recv>
}
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    

00801ab1 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ab7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801aba:	52                   	push   %edx
  801abb:	50                   	push   %eax
  801abc:	e8 9e f6 ff ff       	call   80115f <fd_lookup>
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	78 17                	js     801adf <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acb:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801ad1:	39 08                	cmp    %ecx,(%eax)
  801ad3:	75 05                	jne    801ada <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ad5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad8:	eb 05                	jmp    801adf <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ada:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	56                   	push   %esi
  801ae5:	53                   	push   %ebx
  801ae6:	83 ec 1c             	sub    $0x1c,%esp
  801ae9:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801aeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aee:	50                   	push   %eax
  801aef:	e8 1c f6 ff ff       	call   801110 <fd_alloc>
  801af4:	89 c3                	mov    %eax,%ebx
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	85 c0                	test   %eax,%eax
  801afb:	78 1b                	js     801b18 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801afd:	83 ec 04             	sub    $0x4,%esp
  801b00:	68 07 04 00 00       	push   $0x407
  801b05:	ff 75 f4             	pushl  -0xc(%ebp)
  801b08:	6a 00                	push   $0x0
  801b0a:	e8 76 f2 ff ff       	call   800d85 <sys_page_alloc>
  801b0f:	89 c3                	mov    %eax,%ebx
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	85 c0                	test   %eax,%eax
  801b16:	79 10                	jns    801b28 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b18:	83 ec 0c             	sub    $0xc,%esp
  801b1b:	56                   	push   %esi
  801b1c:	e8 0e 02 00 00       	call   801d2f <nsipc_close>
		return r;
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	89 d8                	mov    %ebx,%eax
  801b26:	eb 24                	jmp    801b4c <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b28:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b31:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b36:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b3d:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b40:	83 ec 0c             	sub    $0xc,%esp
  801b43:	50                   	push   %eax
  801b44:	e8 a0 f5 ff ff       	call   8010e9 <fd2num>
  801b49:	83 c4 10             	add    $0x10,%esp
}
  801b4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5e                   	pop    %esi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	e8 50 ff ff ff       	call   801ab1 <fd2sockid>
		return r;
  801b61:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 1f                	js     801b86 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b67:	83 ec 04             	sub    $0x4,%esp
  801b6a:	ff 75 10             	pushl  0x10(%ebp)
  801b6d:	ff 75 0c             	pushl  0xc(%ebp)
  801b70:	50                   	push   %eax
  801b71:	e8 12 01 00 00       	call   801c88 <nsipc_accept>
  801b76:	83 c4 10             	add    $0x10,%esp
		return r;
  801b79:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 07                	js     801b86 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b7f:	e8 5d ff ff ff       	call   801ae1 <alloc_sockfd>
  801b84:	89 c1                	mov    %eax,%ecx
}
  801b86:	89 c8                	mov    %ecx,%eax
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b90:	8b 45 08             	mov    0x8(%ebp),%eax
  801b93:	e8 19 ff ff ff       	call   801ab1 <fd2sockid>
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	78 12                	js     801bae <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b9c:	83 ec 04             	sub    $0x4,%esp
  801b9f:	ff 75 10             	pushl  0x10(%ebp)
  801ba2:	ff 75 0c             	pushl  0xc(%ebp)
  801ba5:	50                   	push   %eax
  801ba6:	e8 2d 01 00 00       	call   801cd8 <nsipc_bind>
  801bab:	83 c4 10             	add    $0x10,%esp
}
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <shutdown>:

int
shutdown(int s, int how)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb9:	e8 f3 fe ff ff       	call   801ab1 <fd2sockid>
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 0f                	js     801bd1 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bc2:	83 ec 08             	sub    $0x8,%esp
  801bc5:	ff 75 0c             	pushl  0xc(%ebp)
  801bc8:	50                   	push   %eax
  801bc9:	e8 3f 01 00 00       	call   801d0d <nsipc_shutdown>
  801bce:	83 c4 10             	add    $0x10,%esp
}
  801bd1:	c9                   	leave  
  801bd2:	c3                   	ret    

00801bd3 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdc:	e8 d0 fe ff ff       	call   801ab1 <fd2sockid>
  801be1:	85 c0                	test   %eax,%eax
  801be3:	78 12                	js     801bf7 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801be5:	83 ec 04             	sub    $0x4,%esp
  801be8:	ff 75 10             	pushl  0x10(%ebp)
  801beb:	ff 75 0c             	pushl  0xc(%ebp)
  801bee:	50                   	push   %eax
  801bef:	e8 55 01 00 00       	call   801d49 <nsipc_connect>
  801bf4:	83 c4 10             	add    $0x10,%esp
}
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <listen>:

int
listen(int s, int backlog)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bff:	8b 45 08             	mov    0x8(%ebp),%eax
  801c02:	e8 aa fe ff ff       	call   801ab1 <fd2sockid>
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 0f                	js     801c1a <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c0b:	83 ec 08             	sub    $0x8,%esp
  801c0e:	ff 75 0c             	pushl  0xc(%ebp)
  801c11:	50                   	push   %eax
  801c12:	e8 67 01 00 00       	call   801d7e <nsipc_listen>
  801c17:	83 c4 10             	add    $0x10,%esp
}
  801c1a:	c9                   	leave  
  801c1b:	c3                   	ret    

00801c1c <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c22:	ff 75 10             	pushl  0x10(%ebp)
  801c25:	ff 75 0c             	pushl  0xc(%ebp)
  801c28:	ff 75 08             	pushl  0x8(%ebp)
  801c2b:	e8 3a 02 00 00       	call   801e6a <nsipc_socket>
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	85 c0                	test   %eax,%eax
  801c35:	78 05                	js     801c3c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c37:	e8 a5 fe ff ff       	call   801ae1 <alloc_sockfd>
}
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	53                   	push   %ebx
  801c42:	83 ec 04             	sub    $0x4,%esp
  801c45:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c47:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c4e:	75 12                	jne    801c62 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	6a 02                	push   $0x2
  801c55:	e8 d6 07 00 00       	call   802430 <ipc_find_env>
  801c5a:	a3 04 40 80 00       	mov    %eax,0x804004
  801c5f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c62:	6a 07                	push   $0x7
  801c64:	68 00 60 80 00       	push   $0x806000
  801c69:	53                   	push   %ebx
  801c6a:	ff 35 04 40 80 00    	pushl  0x804004
  801c70:	e8 67 07 00 00       	call   8023dc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c75:	83 c4 0c             	add    $0xc,%esp
  801c78:	6a 00                	push   $0x0
  801c7a:	6a 00                	push   $0x0
  801c7c:	6a 00                	push   $0x0
  801c7e:	e8 f0 06 00 00       	call   802373 <ipc_recv>
}
  801c83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    

00801c88 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	56                   	push   %esi
  801c8c:	53                   	push   %ebx
  801c8d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c90:	8b 45 08             	mov    0x8(%ebp),%eax
  801c93:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c98:	8b 06                	mov    (%esi),%eax
  801c9a:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c9f:	b8 01 00 00 00       	mov    $0x1,%eax
  801ca4:	e8 95 ff ff ff       	call   801c3e <nsipc>
  801ca9:	89 c3                	mov    %eax,%ebx
  801cab:	85 c0                	test   %eax,%eax
  801cad:	78 20                	js     801ccf <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801caf:	83 ec 04             	sub    $0x4,%esp
  801cb2:	ff 35 10 60 80 00    	pushl  0x806010
  801cb8:	68 00 60 80 00       	push   $0x806000
  801cbd:	ff 75 0c             	pushl  0xc(%ebp)
  801cc0:	e8 4f ee ff ff       	call   800b14 <memmove>
		*addrlen = ret->ret_addrlen;
  801cc5:	a1 10 60 80 00       	mov    0x806010,%eax
  801cca:	89 06                	mov    %eax,(%esi)
  801ccc:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801ccf:	89 d8                	mov    %ebx,%eax
  801cd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    

00801cd8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	53                   	push   %ebx
  801cdc:	83 ec 08             	sub    $0x8,%esp
  801cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cea:	53                   	push   %ebx
  801ceb:	ff 75 0c             	pushl  0xc(%ebp)
  801cee:	68 04 60 80 00       	push   $0x806004
  801cf3:	e8 1c ee ff ff       	call   800b14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cf8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cfe:	b8 02 00 00 00       	mov    $0x2,%eax
  801d03:	e8 36 ff ff ff       	call   801c3e <nsipc>
}
  801d08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0b:	c9                   	leave  
  801d0c:	c3                   	ret    

00801d0d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d13:	8b 45 08             	mov    0x8(%ebp),%eax
  801d16:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d23:	b8 03 00 00 00       	mov    $0x3,%eax
  801d28:	e8 11 ff ff ff       	call   801c3e <nsipc>
}
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    

00801d2f <nsipc_close>:

int
nsipc_close(int s)
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d35:	8b 45 08             	mov    0x8(%ebp),%eax
  801d38:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d3d:	b8 04 00 00 00       	mov    $0x4,%eax
  801d42:	e8 f7 fe ff ff       	call   801c3e <nsipc>
}
  801d47:	c9                   	leave  
  801d48:	c3                   	ret    

00801d49 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	53                   	push   %ebx
  801d4d:	83 ec 08             	sub    $0x8,%esp
  801d50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d53:	8b 45 08             	mov    0x8(%ebp),%eax
  801d56:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d5b:	53                   	push   %ebx
  801d5c:	ff 75 0c             	pushl  0xc(%ebp)
  801d5f:	68 04 60 80 00       	push   $0x806004
  801d64:	e8 ab ed ff ff       	call   800b14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d69:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d6f:	b8 05 00 00 00       	mov    $0x5,%eax
  801d74:	e8 c5 fe ff ff       	call   801c3e <nsipc>
}
  801d79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d84:	8b 45 08             	mov    0x8(%ebp),%eax
  801d87:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d94:	b8 06 00 00 00       	mov    $0x6,%eax
  801d99:	e8 a0 fe ff ff       	call   801c3e <nsipc>
}
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	56                   	push   %esi
  801da4:	53                   	push   %ebx
  801da5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801da8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dab:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801db0:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801db6:	8b 45 14             	mov    0x14(%ebp),%eax
  801db9:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801dbe:	b8 07 00 00 00       	mov    $0x7,%eax
  801dc3:	e8 76 fe ff ff       	call   801c3e <nsipc>
  801dc8:	89 c3                	mov    %eax,%ebx
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 35                	js     801e03 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801dce:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801dd3:	7f 04                	jg     801dd9 <nsipc_recv+0x39>
  801dd5:	39 c6                	cmp    %eax,%esi
  801dd7:	7d 16                	jge    801def <nsipc_recv+0x4f>
  801dd9:	68 0b 2c 80 00       	push   $0x802c0b
  801dde:	68 cc 2b 80 00       	push   $0x802bcc
  801de3:	6a 62                	push   $0x62
  801de5:	68 20 2c 80 00       	push   $0x802c20
  801dea:	e8 35 e5 ff ff       	call   800324 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801def:	83 ec 04             	sub    $0x4,%esp
  801df2:	50                   	push   %eax
  801df3:	68 00 60 80 00       	push   $0x806000
  801df8:	ff 75 0c             	pushl  0xc(%ebp)
  801dfb:	e8 14 ed ff ff       	call   800b14 <memmove>
  801e00:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e03:	89 d8                	mov    %ebx,%eax
  801e05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    

00801e0c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	53                   	push   %ebx
  801e10:	83 ec 04             	sub    $0x4,%esp
  801e13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e1e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e24:	7e 16                	jle    801e3c <nsipc_send+0x30>
  801e26:	68 2c 2c 80 00       	push   $0x802c2c
  801e2b:	68 cc 2b 80 00       	push   $0x802bcc
  801e30:	6a 6d                	push   $0x6d
  801e32:	68 20 2c 80 00       	push   $0x802c20
  801e37:	e8 e8 e4 ff ff       	call   800324 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e3c:	83 ec 04             	sub    $0x4,%esp
  801e3f:	53                   	push   %ebx
  801e40:	ff 75 0c             	pushl  0xc(%ebp)
  801e43:	68 0c 60 80 00       	push   $0x80600c
  801e48:	e8 c7 ec ff ff       	call   800b14 <memmove>
	nsipcbuf.send.req_size = size;
  801e4d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e53:	8b 45 14             	mov    0x14(%ebp),%eax
  801e56:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e5b:	b8 08 00 00 00       	mov    $0x8,%eax
  801e60:	e8 d9 fd ff ff       	call   801c3e <nsipc>
}
  801e65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e68:	c9                   	leave  
  801e69:	c3                   	ret    

00801e6a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e70:	8b 45 08             	mov    0x8(%ebp),%eax
  801e73:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e78:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7b:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e80:	8b 45 10             	mov    0x10(%ebp),%eax
  801e83:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e88:	b8 09 00 00 00       	mov    $0x9,%eax
  801e8d:	e8 ac fd ff ff       	call   801c3e <nsipc>
}
  801e92:	c9                   	leave  
  801e93:	c3                   	ret    

00801e94 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	56                   	push   %esi
  801e98:	53                   	push   %ebx
  801e99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	ff 75 08             	pushl  0x8(%ebp)
  801ea2:	e8 52 f2 ff ff       	call   8010f9 <fd2data>
  801ea7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ea9:	83 c4 08             	add    $0x8,%esp
  801eac:	68 38 2c 80 00       	push   $0x802c38
  801eb1:	53                   	push   %ebx
  801eb2:	e8 cb ea ff ff       	call   800982 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801eb7:	8b 46 04             	mov    0x4(%esi),%eax
  801eba:	2b 06                	sub    (%esi),%eax
  801ebc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ec2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ec9:	00 00 00 
	stat->st_dev = &devpipe;
  801ecc:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ed3:	30 80 00 
	return 0;
}
  801ed6:	b8 00 00 00 00       	mov    $0x0,%eax
  801edb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	5d                   	pop    %ebp
  801ee1:	c3                   	ret    

00801ee2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	53                   	push   %ebx
  801ee6:	83 ec 0c             	sub    $0xc,%esp
  801ee9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eec:	53                   	push   %ebx
  801eed:	6a 00                	push   $0x0
  801eef:	e8 16 ef ff ff       	call   800e0a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ef4:	89 1c 24             	mov    %ebx,(%esp)
  801ef7:	e8 fd f1 ff ff       	call   8010f9 <fd2data>
  801efc:	83 c4 08             	add    $0x8,%esp
  801eff:	50                   	push   %eax
  801f00:	6a 00                	push   $0x0
  801f02:	e8 03 ef ff ff       	call   800e0a <sys_page_unmap>
}
  801f07:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	57                   	push   %edi
  801f10:	56                   	push   %esi
  801f11:	53                   	push   %ebx
  801f12:	83 ec 1c             	sub    $0x1c,%esp
  801f15:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f18:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f1a:	a1 20 44 80 00       	mov    0x804420,%eax
  801f1f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f22:	83 ec 0c             	sub    $0xc,%esp
  801f25:	ff 75 e0             	pushl  -0x20(%ebp)
  801f28:	e8 3c 05 00 00       	call   802469 <pageref>
  801f2d:	89 c3                	mov    %eax,%ebx
  801f2f:	89 3c 24             	mov    %edi,(%esp)
  801f32:	e8 32 05 00 00       	call   802469 <pageref>
  801f37:	83 c4 10             	add    $0x10,%esp
  801f3a:	39 c3                	cmp    %eax,%ebx
  801f3c:	0f 94 c1             	sete   %cl
  801f3f:	0f b6 c9             	movzbl %cl,%ecx
  801f42:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f45:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801f4b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f4e:	39 ce                	cmp    %ecx,%esi
  801f50:	74 1b                	je     801f6d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f52:	39 c3                	cmp    %eax,%ebx
  801f54:	75 c4                	jne    801f1a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f56:	8b 42 58             	mov    0x58(%edx),%eax
  801f59:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f5c:	50                   	push   %eax
  801f5d:	56                   	push   %esi
  801f5e:	68 3f 2c 80 00       	push   $0x802c3f
  801f63:	e8 95 e4 ff ff       	call   8003fd <cprintf>
  801f68:	83 c4 10             	add    $0x10,%esp
  801f6b:	eb ad                	jmp    801f1a <_pipeisclosed+0xe>
	}
}
  801f6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	57                   	push   %edi
  801f7c:	56                   	push   %esi
  801f7d:	53                   	push   %ebx
  801f7e:	83 ec 28             	sub    $0x28,%esp
  801f81:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f84:	56                   	push   %esi
  801f85:	e8 6f f1 ff ff       	call   8010f9 <fd2data>
  801f8a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	bf 00 00 00 00       	mov    $0x0,%edi
  801f94:	eb 4b                	jmp    801fe1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f96:	89 da                	mov    %ebx,%edx
  801f98:	89 f0                	mov    %esi,%eax
  801f9a:	e8 6d ff ff ff       	call   801f0c <_pipeisclosed>
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	75 48                	jne    801feb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fa3:	e8 be ed ff ff       	call   800d66 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fa8:	8b 43 04             	mov    0x4(%ebx),%eax
  801fab:	8b 0b                	mov    (%ebx),%ecx
  801fad:	8d 51 20             	lea    0x20(%ecx),%edx
  801fb0:	39 d0                	cmp    %edx,%eax
  801fb2:	73 e2                	jae    801f96 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fbb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fbe:	89 c2                	mov    %eax,%edx
  801fc0:	c1 fa 1f             	sar    $0x1f,%edx
  801fc3:	89 d1                	mov    %edx,%ecx
  801fc5:	c1 e9 1b             	shr    $0x1b,%ecx
  801fc8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fcb:	83 e2 1f             	and    $0x1f,%edx
  801fce:	29 ca                	sub    %ecx,%edx
  801fd0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fd4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fd8:	83 c0 01             	add    $0x1,%eax
  801fdb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fde:	83 c7 01             	add    $0x1,%edi
  801fe1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fe4:	75 c2                	jne    801fa8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fe6:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe9:	eb 05                	jmp    801ff0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801feb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ff0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    

00801ff8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	57                   	push   %edi
  801ffc:	56                   	push   %esi
  801ffd:	53                   	push   %ebx
  801ffe:	83 ec 18             	sub    $0x18,%esp
  802001:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802004:	57                   	push   %edi
  802005:	e8 ef f0 ff ff       	call   8010f9 <fd2data>
  80200a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802014:	eb 3d                	jmp    802053 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802016:	85 db                	test   %ebx,%ebx
  802018:	74 04                	je     80201e <devpipe_read+0x26>
				return i;
  80201a:	89 d8                	mov    %ebx,%eax
  80201c:	eb 44                	jmp    802062 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80201e:	89 f2                	mov    %esi,%edx
  802020:	89 f8                	mov    %edi,%eax
  802022:	e8 e5 fe ff ff       	call   801f0c <_pipeisclosed>
  802027:	85 c0                	test   %eax,%eax
  802029:	75 32                	jne    80205d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80202b:	e8 36 ed ff ff       	call   800d66 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802030:	8b 06                	mov    (%esi),%eax
  802032:	3b 46 04             	cmp    0x4(%esi),%eax
  802035:	74 df                	je     802016 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802037:	99                   	cltd   
  802038:	c1 ea 1b             	shr    $0x1b,%edx
  80203b:	01 d0                	add    %edx,%eax
  80203d:	83 e0 1f             	and    $0x1f,%eax
  802040:	29 d0                	sub    %edx,%eax
  802042:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80204a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80204d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802050:	83 c3 01             	add    $0x1,%ebx
  802053:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802056:	75 d8                	jne    802030 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802058:	8b 45 10             	mov    0x10(%ebp),%eax
  80205b:	eb 05                	jmp    802062 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80205d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802062:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802065:	5b                   	pop    %ebx
  802066:	5e                   	pop    %esi
  802067:	5f                   	pop    %edi
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    

0080206a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80206a:	55                   	push   %ebp
  80206b:	89 e5                	mov    %esp,%ebp
  80206d:	56                   	push   %esi
  80206e:	53                   	push   %ebx
  80206f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802075:	50                   	push   %eax
  802076:	e8 95 f0 ff ff       	call   801110 <fd_alloc>
  80207b:	83 c4 10             	add    $0x10,%esp
  80207e:	89 c2                	mov    %eax,%edx
  802080:	85 c0                	test   %eax,%eax
  802082:	0f 88 2c 01 00 00    	js     8021b4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802088:	83 ec 04             	sub    $0x4,%esp
  80208b:	68 07 04 00 00       	push   $0x407
  802090:	ff 75 f4             	pushl  -0xc(%ebp)
  802093:	6a 00                	push   $0x0
  802095:	e8 eb ec ff ff       	call   800d85 <sys_page_alloc>
  80209a:	83 c4 10             	add    $0x10,%esp
  80209d:	89 c2                	mov    %eax,%edx
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	0f 88 0d 01 00 00    	js     8021b4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020a7:	83 ec 0c             	sub    $0xc,%esp
  8020aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020ad:	50                   	push   %eax
  8020ae:	e8 5d f0 ff ff       	call   801110 <fd_alloc>
  8020b3:	89 c3                	mov    %eax,%ebx
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	85 c0                	test   %eax,%eax
  8020ba:	0f 88 e2 00 00 00    	js     8021a2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c0:	83 ec 04             	sub    $0x4,%esp
  8020c3:	68 07 04 00 00       	push   $0x407
  8020c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8020cb:	6a 00                	push   $0x0
  8020cd:	e8 b3 ec ff ff       	call   800d85 <sys_page_alloc>
  8020d2:	89 c3                	mov    %eax,%ebx
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	85 c0                	test   %eax,%eax
  8020d9:	0f 88 c3 00 00 00    	js     8021a2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020df:	83 ec 0c             	sub    $0xc,%esp
  8020e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8020e5:	e8 0f f0 ff ff       	call   8010f9 <fd2data>
  8020ea:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ec:	83 c4 0c             	add    $0xc,%esp
  8020ef:	68 07 04 00 00       	push   $0x407
  8020f4:	50                   	push   %eax
  8020f5:	6a 00                	push   $0x0
  8020f7:	e8 89 ec ff ff       	call   800d85 <sys_page_alloc>
  8020fc:	89 c3                	mov    %eax,%ebx
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	85 c0                	test   %eax,%eax
  802103:	0f 88 89 00 00 00    	js     802192 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802109:	83 ec 0c             	sub    $0xc,%esp
  80210c:	ff 75 f0             	pushl  -0x10(%ebp)
  80210f:	e8 e5 ef ff ff       	call   8010f9 <fd2data>
  802114:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80211b:	50                   	push   %eax
  80211c:	6a 00                	push   $0x0
  80211e:	56                   	push   %esi
  80211f:	6a 00                	push   $0x0
  802121:	e8 a2 ec ff ff       	call   800dc8 <sys_page_map>
  802126:	89 c3                	mov    %eax,%ebx
  802128:	83 c4 20             	add    $0x20,%esp
  80212b:	85 c0                	test   %eax,%eax
  80212d:	78 55                	js     802184 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80212f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802135:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802138:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80213a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802144:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80214a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80214d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80214f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802152:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802159:	83 ec 0c             	sub    $0xc,%esp
  80215c:	ff 75 f4             	pushl  -0xc(%ebp)
  80215f:	e8 85 ef ff ff       	call   8010e9 <fd2num>
  802164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802167:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802169:	83 c4 04             	add    $0x4,%esp
  80216c:	ff 75 f0             	pushl  -0x10(%ebp)
  80216f:	e8 75 ef ff ff       	call   8010e9 <fd2num>
  802174:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802177:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80217a:	83 c4 10             	add    $0x10,%esp
  80217d:	ba 00 00 00 00       	mov    $0x0,%edx
  802182:	eb 30                	jmp    8021b4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802184:	83 ec 08             	sub    $0x8,%esp
  802187:	56                   	push   %esi
  802188:	6a 00                	push   $0x0
  80218a:	e8 7b ec ff ff       	call   800e0a <sys_page_unmap>
  80218f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802192:	83 ec 08             	sub    $0x8,%esp
  802195:	ff 75 f0             	pushl  -0x10(%ebp)
  802198:	6a 00                	push   $0x0
  80219a:	e8 6b ec ff ff       	call   800e0a <sys_page_unmap>
  80219f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021a2:	83 ec 08             	sub    $0x8,%esp
  8021a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a8:	6a 00                	push   $0x0
  8021aa:	e8 5b ec ff ff       	call   800e0a <sys_page_unmap>
  8021af:	83 c4 10             	add    $0x10,%esp
  8021b2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021b4:	89 d0                	mov    %edx,%eax
  8021b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021b9:	5b                   	pop    %ebx
  8021ba:	5e                   	pop    %esi
  8021bb:	5d                   	pop    %ebp
  8021bc:	c3                   	ret    

008021bd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021bd:	55                   	push   %ebp
  8021be:	89 e5                	mov    %esp,%ebp
  8021c0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021c6:	50                   	push   %eax
  8021c7:	ff 75 08             	pushl  0x8(%ebp)
  8021ca:	e8 90 ef ff ff       	call   80115f <fd_lookup>
  8021cf:	83 c4 10             	add    $0x10,%esp
  8021d2:	85 c0                	test   %eax,%eax
  8021d4:	78 18                	js     8021ee <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021d6:	83 ec 0c             	sub    $0xc,%esp
  8021d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8021dc:	e8 18 ef ff ff       	call   8010f9 <fd2data>
	return _pipeisclosed(fd, p);
  8021e1:	89 c2                	mov    %eax,%edx
  8021e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e6:	e8 21 fd ff ff       	call   801f0c <_pipeisclosed>
  8021eb:	83 c4 10             	add    $0x10,%esp
}
  8021ee:	c9                   	leave  
  8021ef:	c3                   	ret    

008021f0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    

008021fa <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021fa:	55                   	push   %ebp
  8021fb:	89 e5                	mov    %esp,%ebp
  8021fd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802200:	68 57 2c 80 00       	push   $0x802c57
  802205:	ff 75 0c             	pushl  0xc(%ebp)
  802208:	e8 75 e7 ff ff       	call   800982 <strcpy>
	return 0;
}
  80220d:	b8 00 00 00 00       	mov    $0x0,%eax
  802212:	c9                   	leave  
  802213:	c3                   	ret    

00802214 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802214:	55                   	push   %ebp
  802215:	89 e5                	mov    %esp,%ebp
  802217:	57                   	push   %edi
  802218:	56                   	push   %esi
  802219:	53                   	push   %ebx
  80221a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802220:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802225:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80222b:	eb 2d                	jmp    80225a <devcons_write+0x46>
		m = n - tot;
  80222d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802230:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802232:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802235:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80223a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80223d:	83 ec 04             	sub    $0x4,%esp
  802240:	53                   	push   %ebx
  802241:	03 45 0c             	add    0xc(%ebp),%eax
  802244:	50                   	push   %eax
  802245:	57                   	push   %edi
  802246:	e8 c9 e8 ff ff       	call   800b14 <memmove>
		sys_cputs(buf, m);
  80224b:	83 c4 08             	add    $0x8,%esp
  80224e:	53                   	push   %ebx
  80224f:	57                   	push   %edi
  802250:	e8 74 ea ff ff       	call   800cc9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802255:	01 de                	add    %ebx,%esi
  802257:	83 c4 10             	add    $0x10,%esp
  80225a:	89 f0                	mov    %esi,%eax
  80225c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80225f:	72 cc                	jb     80222d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802264:	5b                   	pop    %ebx
  802265:	5e                   	pop    %esi
  802266:	5f                   	pop    %edi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    

00802269 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802269:	55                   	push   %ebp
  80226a:	89 e5                	mov    %esp,%ebp
  80226c:	83 ec 08             	sub    $0x8,%esp
  80226f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802274:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802278:	74 2a                	je     8022a4 <devcons_read+0x3b>
  80227a:	eb 05                	jmp    802281 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80227c:	e8 e5 ea ff ff       	call   800d66 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802281:	e8 61 ea ff ff       	call   800ce7 <sys_cgetc>
  802286:	85 c0                	test   %eax,%eax
  802288:	74 f2                	je     80227c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80228a:	85 c0                	test   %eax,%eax
  80228c:	78 16                	js     8022a4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80228e:	83 f8 04             	cmp    $0x4,%eax
  802291:	74 0c                	je     80229f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802293:	8b 55 0c             	mov    0xc(%ebp),%edx
  802296:	88 02                	mov    %al,(%edx)
	return 1;
  802298:	b8 01 00 00 00       	mov    $0x1,%eax
  80229d:	eb 05                	jmp    8022a4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80229f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022a4:	c9                   	leave  
  8022a5:	c3                   	ret    

008022a6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022a6:	55                   	push   %ebp
  8022a7:	89 e5                	mov    %esp,%ebp
  8022a9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8022af:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022b2:	6a 01                	push   $0x1
  8022b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022b7:	50                   	push   %eax
  8022b8:	e8 0c ea ff ff       	call   800cc9 <sys_cputs>
}
  8022bd:	83 c4 10             	add    $0x10,%esp
  8022c0:	c9                   	leave  
  8022c1:	c3                   	ret    

008022c2 <getchar>:

int
getchar(void)
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8022c8:	6a 01                	push   $0x1
  8022ca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022cd:	50                   	push   %eax
  8022ce:	6a 00                	push   $0x0
  8022d0:	e8 f0 f0 ff ff       	call   8013c5 <read>
	if (r < 0)
  8022d5:	83 c4 10             	add    $0x10,%esp
  8022d8:	85 c0                	test   %eax,%eax
  8022da:	78 0f                	js     8022eb <getchar+0x29>
		return r;
	if (r < 1)
  8022dc:	85 c0                	test   %eax,%eax
  8022de:	7e 06                	jle    8022e6 <getchar+0x24>
		return -E_EOF;
	return c;
  8022e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022e4:	eb 05                	jmp    8022eb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022eb:	c9                   	leave  
  8022ec:	c3                   	ret    

008022ed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022ed:	55                   	push   %ebp
  8022ee:	89 e5                	mov    %esp,%ebp
  8022f0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022f6:	50                   	push   %eax
  8022f7:	ff 75 08             	pushl  0x8(%ebp)
  8022fa:	e8 60 ee ff ff       	call   80115f <fd_lookup>
  8022ff:	83 c4 10             	add    $0x10,%esp
  802302:	85 c0                	test   %eax,%eax
  802304:	78 11                	js     802317 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802306:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802309:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80230f:	39 10                	cmp    %edx,(%eax)
  802311:	0f 94 c0             	sete   %al
  802314:	0f b6 c0             	movzbl %al,%eax
}
  802317:	c9                   	leave  
  802318:	c3                   	ret    

00802319 <opencons>:

int
opencons(void)
{
  802319:	55                   	push   %ebp
  80231a:	89 e5                	mov    %esp,%ebp
  80231c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80231f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802322:	50                   	push   %eax
  802323:	e8 e8 ed ff ff       	call   801110 <fd_alloc>
  802328:	83 c4 10             	add    $0x10,%esp
		return r;
  80232b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80232d:	85 c0                	test   %eax,%eax
  80232f:	78 3e                	js     80236f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802331:	83 ec 04             	sub    $0x4,%esp
  802334:	68 07 04 00 00       	push   $0x407
  802339:	ff 75 f4             	pushl  -0xc(%ebp)
  80233c:	6a 00                	push   $0x0
  80233e:	e8 42 ea ff ff       	call   800d85 <sys_page_alloc>
  802343:	83 c4 10             	add    $0x10,%esp
		return r;
  802346:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802348:	85 c0                	test   %eax,%eax
  80234a:	78 23                	js     80236f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80234c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802355:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80235a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802361:	83 ec 0c             	sub    $0xc,%esp
  802364:	50                   	push   %eax
  802365:	e8 7f ed ff ff       	call   8010e9 <fd2num>
  80236a:	89 c2                	mov    %eax,%edx
  80236c:	83 c4 10             	add    $0x10,%esp
}
  80236f:	89 d0                	mov    %edx,%eax
  802371:	c9                   	leave  
  802372:	c3                   	ret    

00802373 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802373:	55                   	push   %ebp
  802374:	89 e5                	mov    %esp,%ebp
  802376:	56                   	push   %esi
  802377:	53                   	push   %ebx
  802378:	8b 75 08             	mov    0x8(%ebp),%esi
  80237b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80237e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802381:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802383:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802388:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80238b:	83 ec 0c             	sub    $0xc,%esp
  80238e:	50                   	push   %eax
  80238f:	e8 a1 eb ff ff       	call   800f35 <sys_ipc_recv>

	if (r < 0) {
  802394:	83 c4 10             	add    $0x10,%esp
  802397:	85 c0                	test   %eax,%eax
  802399:	79 16                	jns    8023b1 <ipc_recv+0x3e>
		if (from_env_store)
  80239b:	85 f6                	test   %esi,%esi
  80239d:	74 06                	je     8023a5 <ipc_recv+0x32>
			*from_env_store = 0;
  80239f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8023a5:	85 db                	test   %ebx,%ebx
  8023a7:	74 2c                	je     8023d5 <ipc_recv+0x62>
			*perm_store = 0;
  8023a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8023af:	eb 24                	jmp    8023d5 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8023b1:	85 f6                	test   %esi,%esi
  8023b3:	74 0a                	je     8023bf <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8023b5:	a1 20 44 80 00       	mov    0x804420,%eax
  8023ba:	8b 40 74             	mov    0x74(%eax),%eax
  8023bd:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8023bf:	85 db                	test   %ebx,%ebx
  8023c1:	74 0a                	je     8023cd <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8023c3:	a1 20 44 80 00       	mov    0x804420,%eax
  8023c8:	8b 40 78             	mov    0x78(%eax),%eax
  8023cb:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8023cd:	a1 20 44 80 00       	mov    0x804420,%eax
  8023d2:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8023d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5d                   	pop    %ebp
  8023db:	c3                   	ret    

008023dc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023dc:	55                   	push   %ebp
  8023dd:	89 e5                	mov    %esp,%ebp
  8023df:	57                   	push   %edi
  8023e0:	56                   	push   %esi
  8023e1:	53                   	push   %ebx
  8023e2:	83 ec 0c             	sub    $0xc,%esp
  8023e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8023ee:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8023f0:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8023f5:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8023f8:	ff 75 14             	pushl  0x14(%ebp)
  8023fb:	53                   	push   %ebx
  8023fc:	56                   	push   %esi
  8023fd:	57                   	push   %edi
  8023fe:	e8 0f eb ff ff       	call   800f12 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802403:	83 c4 10             	add    $0x10,%esp
  802406:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802409:	75 07                	jne    802412 <ipc_send+0x36>
			sys_yield();
  80240b:	e8 56 e9 ff ff       	call   800d66 <sys_yield>
  802410:	eb e6                	jmp    8023f8 <ipc_send+0x1c>
		} else if (r < 0) {
  802412:	85 c0                	test   %eax,%eax
  802414:	79 12                	jns    802428 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802416:	50                   	push   %eax
  802417:	68 63 2c 80 00       	push   $0x802c63
  80241c:	6a 51                	push   $0x51
  80241e:	68 70 2c 80 00       	push   $0x802c70
  802423:	e8 fc de ff ff       	call   800324 <_panic>
		}
	}
}
  802428:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80242b:	5b                   	pop    %ebx
  80242c:	5e                   	pop    %esi
  80242d:	5f                   	pop    %edi
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    

00802430 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802430:	55                   	push   %ebp
  802431:	89 e5                	mov    %esp,%ebp
  802433:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802436:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80243b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80243e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802444:	8b 52 50             	mov    0x50(%edx),%edx
  802447:	39 ca                	cmp    %ecx,%edx
  802449:	75 0d                	jne    802458 <ipc_find_env+0x28>
			return envs[i].env_id;
  80244b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80244e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802453:	8b 40 48             	mov    0x48(%eax),%eax
  802456:	eb 0f                	jmp    802467 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802458:	83 c0 01             	add    $0x1,%eax
  80245b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802460:	75 d9                	jne    80243b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802462:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802467:	5d                   	pop    %ebp
  802468:	c3                   	ret    

00802469 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802469:	55                   	push   %ebp
  80246a:	89 e5                	mov    %esp,%ebp
  80246c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80246f:	89 d0                	mov    %edx,%eax
  802471:	c1 e8 16             	shr    $0x16,%eax
  802474:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80247b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802480:	f6 c1 01             	test   $0x1,%cl
  802483:	74 1d                	je     8024a2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802485:	c1 ea 0c             	shr    $0xc,%edx
  802488:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80248f:	f6 c2 01             	test   $0x1,%dl
  802492:	74 0e                	je     8024a2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802494:	c1 ea 0c             	shr    $0xc,%edx
  802497:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80249e:	ef 
  80249f:	0f b7 c0             	movzwl %ax,%eax
}
  8024a2:	5d                   	pop    %ebp
  8024a3:	c3                   	ret    
  8024a4:	66 90                	xchg   %ax,%ax
  8024a6:	66 90                	xchg   %ax,%ax
  8024a8:	66 90                	xchg   %ax,%ax
  8024aa:	66 90                	xchg   %ax,%ax
  8024ac:	66 90                	xchg   %ax,%ax
  8024ae:	66 90                	xchg   %ax,%ax

008024b0 <__udivdi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 f6                	test   %esi,%esi
  8024c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024cd:	89 ca                	mov    %ecx,%edx
  8024cf:	89 f8                	mov    %edi,%eax
  8024d1:	75 3d                	jne    802510 <__udivdi3+0x60>
  8024d3:	39 cf                	cmp    %ecx,%edi
  8024d5:	0f 87 c5 00 00 00    	ja     8025a0 <__udivdi3+0xf0>
  8024db:	85 ff                	test   %edi,%edi
  8024dd:	89 fd                	mov    %edi,%ebp
  8024df:	75 0b                	jne    8024ec <__udivdi3+0x3c>
  8024e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e6:	31 d2                	xor    %edx,%edx
  8024e8:	f7 f7                	div    %edi
  8024ea:	89 c5                	mov    %eax,%ebp
  8024ec:	89 c8                	mov    %ecx,%eax
  8024ee:	31 d2                	xor    %edx,%edx
  8024f0:	f7 f5                	div    %ebp
  8024f2:	89 c1                	mov    %eax,%ecx
  8024f4:	89 d8                	mov    %ebx,%eax
  8024f6:	89 cf                	mov    %ecx,%edi
  8024f8:	f7 f5                	div    %ebp
  8024fa:	89 c3                	mov    %eax,%ebx
  8024fc:	89 d8                	mov    %ebx,%eax
  8024fe:	89 fa                	mov    %edi,%edx
  802500:	83 c4 1c             	add    $0x1c,%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    
  802508:	90                   	nop
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	39 ce                	cmp    %ecx,%esi
  802512:	77 74                	ja     802588 <__udivdi3+0xd8>
  802514:	0f bd fe             	bsr    %esi,%edi
  802517:	83 f7 1f             	xor    $0x1f,%edi
  80251a:	0f 84 98 00 00 00    	je     8025b8 <__udivdi3+0x108>
  802520:	bb 20 00 00 00       	mov    $0x20,%ebx
  802525:	89 f9                	mov    %edi,%ecx
  802527:	89 c5                	mov    %eax,%ebp
  802529:	29 fb                	sub    %edi,%ebx
  80252b:	d3 e6                	shl    %cl,%esi
  80252d:	89 d9                	mov    %ebx,%ecx
  80252f:	d3 ed                	shr    %cl,%ebp
  802531:	89 f9                	mov    %edi,%ecx
  802533:	d3 e0                	shl    %cl,%eax
  802535:	09 ee                	or     %ebp,%esi
  802537:	89 d9                	mov    %ebx,%ecx
  802539:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80253d:	89 d5                	mov    %edx,%ebp
  80253f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802543:	d3 ed                	shr    %cl,%ebp
  802545:	89 f9                	mov    %edi,%ecx
  802547:	d3 e2                	shl    %cl,%edx
  802549:	89 d9                	mov    %ebx,%ecx
  80254b:	d3 e8                	shr    %cl,%eax
  80254d:	09 c2                	or     %eax,%edx
  80254f:	89 d0                	mov    %edx,%eax
  802551:	89 ea                	mov    %ebp,%edx
  802553:	f7 f6                	div    %esi
  802555:	89 d5                	mov    %edx,%ebp
  802557:	89 c3                	mov    %eax,%ebx
  802559:	f7 64 24 0c          	mull   0xc(%esp)
  80255d:	39 d5                	cmp    %edx,%ebp
  80255f:	72 10                	jb     802571 <__udivdi3+0xc1>
  802561:	8b 74 24 08          	mov    0x8(%esp),%esi
  802565:	89 f9                	mov    %edi,%ecx
  802567:	d3 e6                	shl    %cl,%esi
  802569:	39 c6                	cmp    %eax,%esi
  80256b:	73 07                	jae    802574 <__udivdi3+0xc4>
  80256d:	39 d5                	cmp    %edx,%ebp
  80256f:	75 03                	jne    802574 <__udivdi3+0xc4>
  802571:	83 eb 01             	sub    $0x1,%ebx
  802574:	31 ff                	xor    %edi,%edi
  802576:	89 d8                	mov    %ebx,%eax
  802578:	89 fa                	mov    %edi,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	31 ff                	xor    %edi,%edi
  80258a:	31 db                	xor    %ebx,%ebx
  80258c:	89 d8                	mov    %ebx,%eax
  80258e:	89 fa                	mov    %edi,%edx
  802590:	83 c4 1c             	add    $0x1c,%esp
  802593:	5b                   	pop    %ebx
  802594:	5e                   	pop    %esi
  802595:	5f                   	pop    %edi
  802596:	5d                   	pop    %ebp
  802597:	c3                   	ret    
  802598:	90                   	nop
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	89 d8                	mov    %ebx,%eax
  8025a2:	f7 f7                	div    %edi
  8025a4:	31 ff                	xor    %edi,%edi
  8025a6:	89 c3                	mov    %eax,%ebx
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	89 fa                	mov    %edi,%edx
  8025ac:	83 c4 1c             	add    $0x1c,%esp
  8025af:	5b                   	pop    %ebx
  8025b0:	5e                   	pop    %esi
  8025b1:	5f                   	pop    %edi
  8025b2:	5d                   	pop    %ebp
  8025b3:	c3                   	ret    
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	39 ce                	cmp    %ecx,%esi
  8025ba:	72 0c                	jb     8025c8 <__udivdi3+0x118>
  8025bc:	31 db                	xor    %ebx,%ebx
  8025be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025c2:	0f 87 34 ff ff ff    	ja     8024fc <__udivdi3+0x4c>
  8025c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025cd:	e9 2a ff ff ff       	jmp    8024fc <__udivdi3+0x4c>
  8025d2:	66 90                	xchg   %ax,%ax
  8025d4:	66 90                	xchg   %ax,%ax
  8025d6:	66 90                	xchg   %ax,%ax
  8025d8:	66 90                	xchg   %ax,%ax
  8025da:	66 90                	xchg   %ax,%ax
  8025dc:	66 90                	xchg   %ax,%ax
  8025de:	66 90                	xchg   %ax,%ax

008025e0 <__umoddi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	57                   	push   %edi
  8025e2:	56                   	push   %esi
  8025e3:	53                   	push   %ebx
  8025e4:	83 ec 1c             	sub    $0x1c,%esp
  8025e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025f7:	85 d2                	test   %edx,%edx
  8025f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802601:	89 f3                	mov    %esi,%ebx
  802603:	89 3c 24             	mov    %edi,(%esp)
  802606:	89 74 24 04          	mov    %esi,0x4(%esp)
  80260a:	75 1c                	jne    802628 <__umoddi3+0x48>
  80260c:	39 f7                	cmp    %esi,%edi
  80260e:	76 50                	jbe    802660 <__umoddi3+0x80>
  802610:	89 c8                	mov    %ecx,%eax
  802612:	89 f2                	mov    %esi,%edx
  802614:	f7 f7                	div    %edi
  802616:	89 d0                	mov    %edx,%eax
  802618:	31 d2                	xor    %edx,%edx
  80261a:	83 c4 1c             	add    $0x1c,%esp
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	5d                   	pop    %ebp
  802621:	c3                   	ret    
  802622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802628:	39 f2                	cmp    %esi,%edx
  80262a:	89 d0                	mov    %edx,%eax
  80262c:	77 52                	ja     802680 <__umoddi3+0xa0>
  80262e:	0f bd ea             	bsr    %edx,%ebp
  802631:	83 f5 1f             	xor    $0x1f,%ebp
  802634:	75 5a                	jne    802690 <__umoddi3+0xb0>
  802636:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80263a:	0f 82 e0 00 00 00    	jb     802720 <__umoddi3+0x140>
  802640:	39 0c 24             	cmp    %ecx,(%esp)
  802643:	0f 86 d7 00 00 00    	jbe    802720 <__umoddi3+0x140>
  802649:	8b 44 24 08          	mov    0x8(%esp),%eax
  80264d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802651:	83 c4 1c             	add    $0x1c,%esp
  802654:	5b                   	pop    %ebx
  802655:	5e                   	pop    %esi
  802656:	5f                   	pop    %edi
  802657:	5d                   	pop    %ebp
  802658:	c3                   	ret    
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	85 ff                	test   %edi,%edi
  802662:	89 fd                	mov    %edi,%ebp
  802664:	75 0b                	jne    802671 <__umoddi3+0x91>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f7                	div    %edi
  80266f:	89 c5                	mov    %eax,%ebp
  802671:	89 f0                	mov    %esi,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	f7 f5                	div    %ebp
  802677:	89 c8                	mov    %ecx,%eax
  802679:	f7 f5                	div    %ebp
  80267b:	89 d0                	mov    %edx,%eax
  80267d:	eb 99                	jmp    802618 <__umoddi3+0x38>
  80267f:	90                   	nop
  802680:	89 c8                	mov    %ecx,%eax
  802682:	89 f2                	mov    %esi,%edx
  802684:	83 c4 1c             	add    $0x1c,%esp
  802687:	5b                   	pop    %ebx
  802688:	5e                   	pop    %esi
  802689:	5f                   	pop    %edi
  80268a:	5d                   	pop    %ebp
  80268b:	c3                   	ret    
  80268c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802690:	8b 34 24             	mov    (%esp),%esi
  802693:	bf 20 00 00 00       	mov    $0x20,%edi
  802698:	89 e9                	mov    %ebp,%ecx
  80269a:	29 ef                	sub    %ebp,%edi
  80269c:	d3 e0                	shl    %cl,%eax
  80269e:	89 f9                	mov    %edi,%ecx
  8026a0:	89 f2                	mov    %esi,%edx
  8026a2:	d3 ea                	shr    %cl,%edx
  8026a4:	89 e9                	mov    %ebp,%ecx
  8026a6:	09 c2                	or     %eax,%edx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 14 24             	mov    %edx,(%esp)
  8026ad:	89 f2                	mov    %esi,%edx
  8026af:	d3 e2                	shl    %cl,%edx
  8026b1:	89 f9                	mov    %edi,%ecx
  8026b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026bb:	d3 e8                	shr    %cl,%eax
  8026bd:	89 e9                	mov    %ebp,%ecx
  8026bf:	89 c6                	mov    %eax,%esi
  8026c1:	d3 e3                	shl    %cl,%ebx
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 d0                	mov    %edx,%eax
  8026c7:	d3 e8                	shr    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	09 d8                	or     %ebx,%eax
  8026cd:	89 d3                	mov    %edx,%ebx
  8026cf:	89 f2                	mov    %esi,%edx
  8026d1:	f7 34 24             	divl   (%esp)
  8026d4:	89 d6                	mov    %edx,%esi
  8026d6:	d3 e3                	shl    %cl,%ebx
  8026d8:	f7 64 24 04          	mull   0x4(%esp)
  8026dc:	39 d6                	cmp    %edx,%esi
  8026de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026e2:	89 d1                	mov    %edx,%ecx
  8026e4:	89 c3                	mov    %eax,%ebx
  8026e6:	72 08                	jb     8026f0 <__umoddi3+0x110>
  8026e8:	75 11                	jne    8026fb <__umoddi3+0x11b>
  8026ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ee:	73 0b                	jae    8026fb <__umoddi3+0x11b>
  8026f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026f4:	1b 14 24             	sbb    (%esp),%edx
  8026f7:	89 d1                	mov    %edx,%ecx
  8026f9:	89 c3                	mov    %eax,%ebx
  8026fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026ff:	29 da                	sub    %ebx,%edx
  802701:	19 ce                	sbb    %ecx,%esi
  802703:	89 f9                	mov    %edi,%ecx
  802705:	89 f0                	mov    %esi,%eax
  802707:	d3 e0                	shl    %cl,%eax
  802709:	89 e9                	mov    %ebp,%ecx
  80270b:	d3 ea                	shr    %cl,%edx
  80270d:	89 e9                	mov    %ebp,%ecx
  80270f:	d3 ee                	shr    %cl,%esi
  802711:	09 d0                	or     %edx,%eax
  802713:	89 f2                	mov    %esi,%edx
  802715:	83 c4 1c             	add    $0x1c,%esp
  802718:	5b                   	pop    %ebx
  802719:	5e                   	pop    %esi
  80271a:	5f                   	pop    %edi
  80271b:	5d                   	pop    %ebp
  80271c:	c3                   	ret    
  80271d:	8d 76 00             	lea    0x0(%esi),%esi
  802720:	29 f9                	sub    %edi,%ecx
  802722:	19 d6                	sbb    %edx,%esi
  802724:	89 74 24 04          	mov    %esi,0x4(%esp)
  802728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80272c:	e9 18 ff ff ff       	jmp    802649 <__umoddi3+0x69>
