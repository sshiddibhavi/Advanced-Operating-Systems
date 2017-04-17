
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 51 28 80 00       	push   $0x802851
  800049:	68 20 28 80 00       	push   $0x802820
  80004e:	e8 77 06 00 00       	call   8006ca <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 30 28 80 00       	push   $0x802830
  80005c:	68 34 28 80 00       	push   $0x802834
  800061:	e8 64 06 00 00       	call   8006ca <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 44 28 80 00       	push   $0x802844
  800077:	e8 4e 06 00 00       	call   8006ca <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 48 28 80 00       	push   $0x802848
  80008e:	e8 37 06 00 00       	call   8006ca <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 52 28 80 00       	push   $0x802852
  8000a6:	68 34 28 80 00       	push   $0x802834
  8000ab:	e8 1a 06 00 00       	call   8006ca <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 44 28 80 00       	push   $0x802844
  8000c3:	e8 02 06 00 00       	call   8006ca <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 48 28 80 00       	push   $0x802848
  8000d5:	e8 f0 05 00 00       	call   8006ca <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 56 28 80 00       	push   $0x802856
  8000ed:	68 34 28 80 00       	push   $0x802834
  8000f2:	e8 d3 05 00 00       	call   8006ca <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 44 28 80 00       	push   $0x802844
  80010a:	e8 bb 05 00 00       	call   8006ca <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 48 28 80 00       	push   $0x802848
  80011c:	e8 a9 05 00 00       	call   8006ca <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 5a 28 80 00       	push   $0x80285a
  800134:	68 34 28 80 00       	push   $0x802834
  800139:	e8 8c 05 00 00       	call   8006ca <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 44 28 80 00       	push   $0x802844
  800151:	e8 74 05 00 00       	call   8006ca <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 48 28 80 00       	push   $0x802848
  800163:	e8 62 05 00 00       	call   8006ca <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 5e 28 80 00       	push   $0x80285e
  80017b:	68 34 28 80 00       	push   $0x802834
  800180:	e8 45 05 00 00       	call   8006ca <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 44 28 80 00       	push   $0x802844
  800198:	e8 2d 05 00 00       	call   8006ca <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 48 28 80 00       	push   $0x802848
  8001aa:	e8 1b 05 00 00       	call   8006ca <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 62 28 80 00       	push   $0x802862
  8001c2:	68 34 28 80 00       	push   $0x802834
  8001c7:	e8 fe 04 00 00       	call   8006ca <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 44 28 80 00       	push   $0x802844
  8001df:	e8 e6 04 00 00       	call   8006ca <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 48 28 80 00       	push   $0x802848
  8001f1:	e8 d4 04 00 00       	call   8006ca <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 66 28 80 00       	push   $0x802866
  800209:	68 34 28 80 00       	push   $0x802834
  80020e:	e8 b7 04 00 00       	call   8006ca <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 44 28 80 00       	push   $0x802844
  800226:	e8 9f 04 00 00       	call   8006ca <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 48 28 80 00       	push   $0x802848
  800238:	e8 8d 04 00 00       	call   8006ca <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 6a 28 80 00       	push   $0x80286a
  800250:	68 34 28 80 00       	push   $0x802834
  800255:	e8 70 04 00 00       	call   8006ca <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 44 28 80 00       	push   $0x802844
  80026d:	e8 58 04 00 00       	call   8006ca <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 48 28 80 00       	push   $0x802848
  80027f:	e8 46 04 00 00       	call   8006ca <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 6e 28 80 00       	push   $0x80286e
  800297:	68 34 28 80 00       	push   $0x802834
  80029c:	e8 29 04 00 00       	call   8006ca <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 44 28 80 00       	push   $0x802844
  8002b4:	e8 11 04 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 75 28 80 00       	push   $0x802875
  8002c4:	68 34 28 80 00       	push   $0x802834
  8002c9:	e8 fc 03 00 00       	call   8006ca <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 48 28 80 00       	push   $0x802848
  8002e3:	e8 e2 03 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 75 28 80 00       	push   $0x802875
  8002f3:	68 34 28 80 00       	push   $0x802834
  8002f8:	e8 cd 03 00 00       	call   8006ca <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 44 28 80 00       	push   $0x802844
  800312:	e8 b3 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 79 28 80 00       	push   $0x802879
  800322:	e8 a3 03 00 00       	call   8006ca <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 48 28 80 00       	push   $0x802848
  800338:	e8 8d 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 79 28 80 00       	push   $0x802879
  800348:	e8 7d 03 00 00       	call   8006ca <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 44 28 80 00       	push   $0x802844
  80035a:	e8 6b 03 00 00       	call   8006ca <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 48 28 80 00       	push   $0x802848
  80036c:	e8 59 03 00 00       	call   8006ca <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 44 28 80 00       	push   $0x802844
  80037e:	e8 47 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 79 28 80 00       	push   $0x802879
  80038e:	e8 37 03 00 00       	call   8006ca <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 e0 28 80 00       	push   $0x8028e0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 87 28 80 00       	push   $0x802887
  8003c6:	e8 26 02 00 00       	call   8005f1 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 9f 28 80 00       	push   $0x80289f
  800435:	68 ad 28 80 00       	push   $0x8028ad
  80043a:	b9 40 40 80 00       	mov    $0x804040,%ecx
  80043f:	ba 98 28 80 00       	mov    $0x802898,%edx
  800444:	b8 80 40 80 00       	mov    $0x804080,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 f3 0b 00 00       	call   801052 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 b4 28 80 00       	push   $0x8028b4
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 87 28 80 00       	push   $0x802887
  800473:	e8 79 01 00 00       	call   8005f1 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 d8 0d 00 00       	call   801262 <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004ab:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b1:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004b7:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004bd:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c3:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004c9:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004ce:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004e4:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004ea:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f0:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004f6:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004fc:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800502:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800507:	89 25 28 40 80 00    	mov    %esp,0x804028
  80050d:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800513:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800519:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80051f:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800525:	8b 15 94 40 80 00    	mov    0x804094,%edx
  80052b:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800531:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800536:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 24 40 80 00       	mov    %eax,0x804024
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 14 29 80 00       	push   $0x802914
  800559:	e8 6c 01 00 00       	call   8006ca <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  800566:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 c7 28 80 00       	push   $0x8028c7
  800573:	68 d8 28 80 00       	push   $0x8028d8
  800578:	b9 00 40 80 00       	mov    $0x804000,%ecx
  80057d:	ba 98 28 80 00       	mov    $0x802898,%edx
  800582:	b8 80 40 80 00       	mov    $0x804080,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
}
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80059c:	e8 73 0a 00 00       	call   801014 <sys_getenvid>
  8005a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ae:	a3 b4 40 80 00       	mov    %eax,0x8040b4

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7e 07                	jle    8005be <libmain+0x2d>
		binaryname = argv[0];
  8005b7:	8b 06                	mov    (%esi),%eax
  8005b9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	e8 b2 fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005c8:	e8 0a 00 00 00       	call   8005d7 <exit>
}
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005dd:	e8 c1 0e 00 00       	call   8014a3 <close_all>
	sys_env_destroy(0);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	6a 00                	push   $0x0
  8005e7:	e8 e7 09 00 00       	call   800fd3 <sys_env_destroy>
}
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	c9                   	leave  
  8005f0:	c3                   	ret    

008005f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	56                   	push   %esi
  8005f5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8005ff:	e8 10 0a 00 00       	call   801014 <sys_getenvid>
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	ff 75 0c             	pushl  0xc(%ebp)
  80060a:	ff 75 08             	pushl  0x8(%ebp)
  80060d:	56                   	push   %esi
  80060e:	50                   	push   %eax
  80060f:	68 40 29 80 00       	push   $0x802940
  800614:	e8 b1 00 00 00       	call   8006ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800619:	83 c4 18             	add    $0x18,%esp
  80061c:	53                   	push   %ebx
  80061d:	ff 75 10             	pushl  0x10(%ebp)
  800620:	e8 54 00 00 00       	call   800679 <vcprintf>
	cprintf("\n");
  800625:	c7 04 24 50 28 80 00 	movl   $0x802850,(%esp)
  80062c:	e8 99 00 00 00       	call   8006ca <cprintf>
  800631:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800634:	cc                   	int3   
  800635:	eb fd                	jmp    800634 <_panic+0x43>

00800637 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 04             	sub    $0x4,%esp
  80063e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800641:	8b 13                	mov    (%ebx),%edx
  800643:	8d 42 01             	lea    0x1(%edx),%eax
  800646:	89 03                	mov    %eax,(%ebx)
  800648:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800654:	75 1a                	jne    800670 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	68 ff 00 00 00       	push   $0xff
  80065e:	8d 43 08             	lea    0x8(%ebx),%eax
  800661:	50                   	push   %eax
  800662:	e8 2f 09 00 00       	call   800f96 <sys_cputs>
		b->idx = 0;
  800667:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80066d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800670:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800682:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800689:	00 00 00 
	b.cnt = 0;
  80068c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800693:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	ff 75 08             	pushl  0x8(%ebp)
  80069c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a2:	50                   	push   %eax
  8006a3:	68 37 06 80 00       	push   $0x800637
  8006a8:	e8 54 01 00 00       	call   800801 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ad:	83 c4 08             	add    $0x8,%esp
  8006b0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	e8 d4 08 00 00       	call   800f96 <sys_cputs>

	return b.cnt;
}
  8006c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d3:	50                   	push   %eax
  8006d4:	ff 75 08             	pushl  0x8(%ebp)
  8006d7:	e8 9d ff ff ff       	call   800679 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	57                   	push   %edi
  8006e2:	56                   	push   %esi
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 1c             	sub    $0x1c,%esp
  8006e7:	89 c7                	mov    %eax,%edi
  8006e9:	89 d6                	mov    %edx,%esi
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800702:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800705:	39 d3                	cmp    %edx,%ebx
  800707:	72 05                	jb     80070e <printnum+0x30>
  800709:	39 45 10             	cmp    %eax,0x10(%ebp)
  80070c:	77 45                	ja     800753 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80070e:	83 ec 0c             	sub    $0xc,%esp
  800711:	ff 75 18             	pushl  0x18(%ebp)
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80071a:	53                   	push   %ebx
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	ff 75 e4             	pushl  -0x1c(%ebp)
  800724:	ff 75 e0             	pushl  -0x20(%ebp)
  800727:	ff 75 dc             	pushl  -0x24(%ebp)
  80072a:	ff 75 d8             	pushl  -0x28(%ebp)
  80072d:	e8 5e 1e 00 00       	call   802590 <__udivdi3>
  800732:	83 c4 18             	add    $0x18,%esp
  800735:	52                   	push   %edx
  800736:	50                   	push   %eax
  800737:	89 f2                	mov    %esi,%edx
  800739:	89 f8                	mov    %edi,%eax
  80073b:	e8 9e ff ff ff       	call   8006de <printnum>
  800740:	83 c4 20             	add    $0x20,%esp
  800743:	eb 18                	jmp    80075d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	ff 75 18             	pushl  0x18(%ebp)
  80074c:	ff d7                	call   *%edi
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	eb 03                	jmp    800756 <printnum+0x78>
  800753:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800756:	83 eb 01             	sub    $0x1,%ebx
  800759:	85 db                	test   %ebx,%ebx
  80075b:	7f e8                	jg     800745 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	56                   	push   %esi
  800761:	83 ec 04             	sub    $0x4,%esp
  800764:	ff 75 e4             	pushl  -0x1c(%ebp)
  800767:	ff 75 e0             	pushl  -0x20(%ebp)
  80076a:	ff 75 dc             	pushl  -0x24(%ebp)
  80076d:	ff 75 d8             	pushl  -0x28(%ebp)
  800770:	e8 4b 1f 00 00       	call   8026c0 <__umoddi3>
  800775:	83 c4 14             	add    $0x14,%esp
  800778:	0f be 80 63 29 80 00 	movsbl 0x802963(%eax),%eax
  80077f:	50                   	push   %eax
  800780:	ff d7                	call   *%edi
}
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5f                   	pop    %edi
  80078b:	5d                   	pop    %ebp
  80078c:	c3                   	ret    

0080078d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800790:	83 fa 01             	cmp    $0x1,%edx
  800793:	7e 0e                	jle    8007a3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800795:	8b 10                	mov    (%eax),%edx
  800797:	8d 4a 08             	lea    0x8(%edx),%ecx
  80079a:	89 08                	mov    %ecx,(%eax)
  80079c:	8b 02                	mov    (%edx),%eax
  80079e:	8b 52 04             	mov    0x4(%edx),%edx
  8007a1:	eb 22                	jmp    8007c5 <getuint+0x38>
	else if (lflag)
  8007a3:	85 d2                	test   %edx,%edx
  8007a5:	74 10                	je     8007b7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007ac:	89 08                	mov    %ecx,(%eax)
  8007ae:	8b 02                	mov    (%edx),%eax
  8007b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b5:	eb 0e                	jmp    8007c5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b7:	8b 10                	mov    (%eax),%edx
  8007b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007bc:	89 08                	mov    %ecx,(%eax)
  8007be:	8b 02                	mov    (%edx),%eax
  8007c0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007cd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d1:	8b 10                	mov    (%eax),%edx
  8007d3:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d6:	73 0a                	jae    8007e2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007db:	89 08                	mov    %ecx,(%eax)
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	88 02                	mov    %al,(%edx)
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ea:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007ed:	50                   	push   %eax
  8007ee:	ff 75 10             	pushl  0x10(%ebp)
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	ff 75 08             	pushl  0x8(%ebp)
  8007f7:	e8 05 00 00 00       	call   800801 <vprintfmt>
	va_end(ap);
}
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	57                   	push   %edi
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	83 ec 2c             	sub    $0x2c,%esp
  80080a:	8b 75 08             	mov    0x8(%ebp),%esi
  80080d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800810:	8b 7d 10             	mov    0x10(%ebp),%edi
  800813:	eb 12                	jmp    800827 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800815:	85 c0                	test   %eax,%eax
  800817:	0f 84 89 03 00 00    	je     800ba6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	53                   	push   %ebx
  800821:	50                   	push   %eax
  800822:	ff d6                	call   *%esi
  800824:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800827:	83 c7 01             	add    $0x1,%edi
  80082a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80082e:	83 f8 25             	cmp    $0x25,%eax
  800831:	75 e2                	jne    800815 <vprintfmt+0x14>
  800833:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800837:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80083e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800845:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80084c:	ba 00 00 00 00       	mov    $0x0,%edx
  800851:	eb 07                	jmp    80085a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800853:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800856:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085a:	8d 47 01             	lea    0x1(%edi),%eax
  80085d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800860:	0f b6 07             	movzbl (%edi),%eax
  800863:	0f b6 c8             	movzbl %al,%ecx
  800866:	83 e8 23             	sub    $0x23,%eax
  800869:	3c 55                	cmp    $0x55,%al
  80086b:	0f 87 1a 03 00 00    	ja     800b8b <vprintfmt+0x38a>
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	ff 24 85 a0 2a 80 00 	jmp    *0x802aa0(,%eax,4)
  80087b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80087e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800882:	eb d6                	jmp    80085a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800884:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800887:	b8 00 00 00 00       	mov    $0x0,%eax
  80088c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800892:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800896:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800899:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80089c:	83 fa 09             	cmp    $0x9,%edx
  80089f:	77 39                	ja     8008da <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008a4:	eb e9                	jmp    80088f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8d 48 04             	lea    0x4(%eax),%ecx
  8008ac:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008af:	8b 00                	mov    (%eax),%eax
  8008b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b7:	eb 27                	jmp    8008e0 <vprintfmt+0xdf>
  8008b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c3:	0f 49 c8             	cmovns %eax,%ecx
  8008c6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008cc:	eb 8c                	jmp    80085a <vprintfmt+0x59>
  8008ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d8:	eb 80                	jmp    80085a <vprintfmt+0x59>
  8008da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008dd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e4:	0f 89 70 ff ff ff    	jns    80085a <vprintfmt+0x59>
				width = precision, precision = -1;
  8008ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f7:	e9 5e ff ff ff       	jmp    80085a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008fc:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800902:	e9 53 ff ff ff       	jmp    80085a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	8d 50 04             	lea    0x4(%eax),%edx
  80090d:	89 55 14             	mov    %edx,0x14(%ebp)
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	53                   	push   %ebx
  800914:	ff 30                	pushl  (%eax)
  800916:	ff d6                	call   *%esi
			break;
  800918:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80091e:	e9 04 ff ff ff       	jmp    800827 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8d 50 04             	lea    0x4(%eax),%edx
  800929:	89 55 14             	mov    %edx,0x14(%ebp)
  80092c:	8b 00                	mov    (%eax),%eax
  80092e:	99                   	cltd   
  80092f:	31 d0                	xor    %edx,%eax
  800931:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800933:	83 f8 0f             	cmp    $0xf,%eax
  800936:	7f 0b                	jg     800943 <vprintfmt+0x142>
  800938:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  80093f:	85 d2                	test   %edx,%edx
  800941:	75 18                	jne    80095b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800943:	50                   	push   %eax
  800944:	68 7b 29 80 00       	push   $0x80297b
  800949:	53                   	push   %ebx
  80094a:	56                   	push   %esi
  80094b:	e8 94 fe ff ff       	call   8007e4 <printfmt>
  800950:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800953:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800956:	e9 cc fe ff ff       	jmp    800827 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80095b:	52                   	push   %edx
  80095c:	68 3e 2d 80 00       	push   $0x802d3e
  800961:	53                   	push   %ebx
  800962:	56                   	push   %esi
  800963:	e8 7c fe ff ff       	call   8007e4 <printfmt>
  800968:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096e:	e9 b4 fe ff ff       	jmp    800827 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800973:	8b 45 14             	mov    0x14(%ebp),%eax
  800976:	8d 50 04             	lea    0x4(%eax),%edx
  800979:	89 55 14             	mov    %edx,0x14(%ebp)
  80097c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80097e:	85 ff                	test   %edi,%edi
  800980:	b8 74 29 80 00       	mov    $0x802974,%eax
  800985:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800988:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098c:	0f 8e 94 00 00 00    	jle    800a26 <vprintfmt+0x225>
  800992:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800996:	0f 84 98 00 00 00    	je     800a34 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80099c:	83 ec 08             	sub    $0x8,%esp
  80099f:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a2:	57                   	push   %edi
  8009a3:	e8 86 02 00 00       	call   800c2e <strnlen>
  8009a8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009ab:	29 c1                	sub    %eax,%ecx
  8009ad:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009b0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009ba:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009bd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bf:	eb 0f                	jmp    8009d0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009c1:	83 ec 08             	sub    $0x8,%esp
  8009c4:	53                   	push   %ebx
  8009c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ca:	83 ef 01             	sub    $0x1,%edi
  8009cd:	83 c4 10             	add    $0x10,%esp
  8009d0:	85 ff                	test   %edi,%edi
  8009d2:	7f ed                	jg     8009c1 <vprintfmt+0x1c0>
  8009d4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009da:	85 c9                	test   %ecx,%ecx
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e1:	0f 49 c1             	cmovns %ecx,%eax
  8009e4:	29 c1                	sub    %eax,%ecx
  8009e6:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009ec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009ef:	89 cb                	mov    %ecx,%ebx
  8009f1:	eb 4d                	jmp    800a40 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f7:	74 1b                	je     800a14 <vprintfmt+0x213>
  8009f9:	0f be c0             	movsbl %al,%eax
  8009fc:	83 e8 20             	sub    $0x20,%eax
  8009ff:	83 f8 5e             	cmp    $0x5e,%eax
  800a02:	76 10                	jbe    800a14 <vprintfmt+0x213>
					putch('?', putdat);
  800a04:	83 ec 08             	sub    $0x8,%esp
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	6a 3f                	push   $0x3f
  800a0c:	ff 55 08             	call   *0x8(%ebp)
  800a0f:	83 c4 10             	add    $0x10,%esp
  800a12:	eb 0d                	jmp    800a21 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a14:	83 ec 08             	sub    $0x8,%esp
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	52                   	push   %edx
  800a1b:	ff 55 08             	call   *0x8(%ebp)
  800a1e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a21:	83 eb 01             	sub    $0x1,%ebx
  800a24:	eb 1a                	jmp    800a40 <vprintfmt+0x23f>
  800a26:	89 75 08             	mov    %esi,0x8(%ebp)
  800a29:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a2c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a2f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a32:	eb 0c                	jmp    800a40 <vprintfmt+0x23f>
  800a34:	89 75 08             	mov    %esi,0x8(%ebp)
  800a37:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a3a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a3d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a40:	83 c7 01             	add    $0x1,%edi
  800a43:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a47:	0f be d0             	movsbl %al,%edx
  800a4a:	85 d2                	test   %edx,%edx
  800a4c:	74 23                	je     800a71 <vprintfmt+0x270>
  800a4e:	85 f6                	test   %esi,%esi
  800a50:	78 a1                	js     8009f3 <vprintfmt+0x1f2>
  800a52:	83 ee 01             	sub    $0x1,%esi
  800a55:	79 9c                	jns    8009f3 <vprintfmt+0x1f2>
  800a57:	89 df                	mov    %ebx,%edi
  800a59:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5f:	eb 18                	jmp    800a79 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a61:	83 ec 08             	sub    $0x8,%esp
  800a64:	53                   	push   %ebx
  800a65:	6a 20                	push   $0x20
  800a67:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a69:	83 ef 01             	sub    $0x1,%edi
  800a6c:	83 c4 10             	add    $0x10,%esp
  800a6f:	eb 08                	jmp    800a79 <vprintfmt+0x278>
  800a71:	89 df                	mov    %ebx,%edi
  800a73:	8b 75 08             	mov    0x8(%ebp),%esi
  800a76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a79:	85 ff                	test   %edi,%edi
  800a7b:	7f e4                	jg     800a61 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a80:	e9 a2 fd ff ff       	jmp    800827 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a85:	83 fa 01             	cmp    $0x1,%edx
  800a88:	7e 16                	jle    800aa0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8d:	8d 50 08             	lea    0x8(%eax),%edx
  800a90:	89 55 14             	mov    %edx,0x14(%ebp)
  800a93:	8b 50 04             	mov    0x4(%eax),%edx
  800a96:	8b 00                	mov    (%eax),%eax
  800a98:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a9b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a9e:	eb 32                	jmp    800ad2 <vprintfmt+0x2d1>
	else if (lflag)
  800aa0:	85 d2                	test   %edx,%edx
  800aa2:	74 18                	je     800abc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa7:	8d 50 04             	lea    0x4(%eax),%edx
  800aaa:	89 55 14             	mov    %edx,0x14(%ebp)
  800aad:	8b 00                	mov    (%eax),%eax
  800aaf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab2:	89 c1                	mov    %eax,%ecx
  800ab4:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800aba:	eb 16                	jmp    800ad2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800abc:	8b 45 14             	mov    0x14(%ebp),%eax
  800abf:	8d 50 04             	lea    0x4(%eax),%edx
  800ac2:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac5:	8b 00                	mov    (%eax),%eax
  800ac7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aca:	89 c1                	mov    %eax,%ecx
  800acc:	c1 f9 1f             	sar    $0x1f,%ecx
  800acf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ad5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800add:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ae1:	79 74                	jns    800b57 <vprintfmt+0x356>
				putch('-', putdat);
  800ae3:	83 ec 08             	sub    $0x8,%esp
  800ae6:	53                   	push   %ebx
  800ae7:	6a 2d                	push   $0x2d
  800ae9:	ff d6                	call   *%esi
				num = -(long long) num;
  800aeb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800aee:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800af1:	f7 d8                	neg    %eax
  800af3:	83 d2 00             	adc    $0x0,%edx
  800af6:	f7 da                	neg    %edx
  800af8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800afb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b00:	eb 55                	jmp    800b57 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b02:	8d 45 14             	lea    0x14(%ebp),%eax
  800b05:	e8 83 fc ff ff       	call   80078d <getuint>
			base = 10;
  800b0a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b0f:	eb 46                	jmp    800b57 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b11:	8d 45 14             	lea    0x14(%ebp),%eax
  800b14:	e8 74 fc ff ff       	call   80078d <getuint>
                        base = 8;
  800b19:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800b1e:	eb 37                	jmp    800b57 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b20:	83 ec 08             	sub    $0x8,%esp
  800b23:	53                   	push   %ebx
  800b24:	6a 30                	push   $0x30
  800b26:	ff d6                	call   *%esi
			putch('x', putdat);
  800b28:	83 c4 08             	add    $0x8,%esp
  800b2b:	53                   	push   %ebx
  800b2c:	6a 78                	push   $0x78
  800b2e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b30:	8b 45 14             	mov    0x14(%ebp),%eax
  800b33:	8d 50 04             	lea    0x4(%eax),%edx
  800b36:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b39:	8b 00                	mov    (%eax),%eax
  800b3b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b40:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b43:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b48:	eb 0d                	jmp    800b57 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b4a:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4d:	e8 3b fc ff ff       	call   80078d <getuint>
			base = 16;
  800b52:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b5e:	57                   	push   %edi
  800b5f:	ff 75 e0             	pushl  -0x20(%ebp)
  800b62:	51                   	push   %ecx
  800b63:	52                   	push   %edx
  800b64:	50                   	push   %eax
  800b65:	89 da                	mov    %ebx,%edx
  800b67:	89 f0                	mov    %esi,%eax
  800b69:	e8 70 fb ff ff       	call   8006de <printnum>
			break;
  800b6e:	83 c4 20             	add    $0x20,%esp
  800b71:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b74:	e9 ae fc ff ff       	jmp    800827 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b79:	83 ec 08             	sub    $0x8,%esp
  800b7c:	53                   	push   %ebx
  800b7d:	51                   	push   %ecx
  800b7e:	ff d6                	call   *%esi
			break;
  800b80:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b86:	e9 9c fc ff ff       	jmp    800827 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b8b:	83 ec 08             	sub    $0x8,%esp
  800b8e:	53                   	push   %ebx
  800b8f:	6a 25                	push   $0x25
  800b91:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b93:	83 c4 10             	add    $0x10,%esp
  800b96:	eb 03                	jmp    800b9b <vprintfmt+0x39a>
  800b98:	83 ef 01             	sub    $0x1,%edi
  800b9b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b9f:	75 f7                	jne    800b98 <vprintfmt+0x397>
  800ba1:	e9 81 fc ff ff       	jmp    800827 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 18             	sub    $0x18,%esp
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bba:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bbd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	74 26                	je     800bf5 <vsnprintf+0x47>
  800bcf:	85 d2                	test   %edx,%edx
  800bd1:	7e 22                	jle    800bf5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd3:	ff 75 14             	pushl  0x14(%ebp)
  800bd6:	ff 75 10             	pushl  0x10(%ebp)
  800bd9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bdc:	50                   	push   %eax
  800bdd:	68 c7 07 80 00       	push   $0x8007c7
  800be2:	e8 1a fc ff ff       	call   800801 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf0:	83 c4 10             	add    $0x10,%esp
  800bf3:	eb 05                	jmp    800bfa <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bf5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c02:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c05:	50                   	push   %eax
  800c06:	ff 75 10             	pushl  0x10(%ebp)
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	ff 75 08             	pushl  0x8(%ebp)
  800c0f:	e8 9a ff ff ff       	call   800bae <vsnprintf>
	va_end(ap);

	return rc;
}
  800c14:	c9                   	leave  
  800c15:	c3                   	ret    

00800c16 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c21:	eb 03                	jmp    800c26 <strlen+0x10>
		n++;
  800c23:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c26:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c2a:	75 f7                	jne    800c23 <strlen+0xd>
		n++;
	return n;
}
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c34:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c37:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3c:	eb 03                	jmp    800c41 <strnlen+0x13>
		n++;
  800c3e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c41:	39 c2                	cmp    %eax,%edx
  800c43:	74 08                	je     800c4d <strnlen+0x1f>
  800c45:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c49:	75 f3                	jne    800c3e <strnlen+0x10>
  800c4b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	53                   	push   %ebx
  800c53:	8b 45 08             	mov    0x8(%ebp),%eax
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c59:	89 c2                	mov    %eax,%edx
  800c5b:	83 c2 01             	add    $0x1,%edx
  800c5e:	83 c1 01             	add    $0x1,%ecx
  800c61:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c65:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c68:	84 db                	test   %bl,%bl
  800c6a:	75 ef                	jne    800c5b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	53                   	push   %ebx
  800c73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c76:	53                   	push   %ebx
  800c77:	e8 9a ff ff ff       	call   800c16 <strlen>
  800c7c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c7f:	ff 75 0c             	pushl  0xc(%ebp)
  800c82:	01 d8                	add    %ebx,%eax
  800c84:	50                   	push   %eax
  800c85:	e8 c5 ff ff ff       	call   800c4f <strcpy>
	return dst;
}
  800c8a:	89 d8                	mov    %ebx,%eax
  800c8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    

00800c91 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	8b 75 08             	mov    0x8(%ebp),%esi
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	89 f3                	mov    %esi,%ebx
  800c9e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca1:	89 f2                	mov    %esi,%edx
  800ca3:	eb 0f                	jmp    800cb4 <strncpy+0x23>
		*dst++ = *src;
  800ca5:	83 c2 01             	add    $0x1,%edx
  800ca8:	0f b6 01             	movzbl (%ecx),%eax
  800cab:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cae:	80 39 01             	cmpb   $0x1,(%ecx)
  800cb1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb4:	39 da                	cmp    %ebx,%edx
  800cb6:	75 ed                	jne    800ca5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cb8:	89 f0                	mov    %esi,%eax
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	8b 55 10             	mov    0x10(%ebp),%edx
  800ccc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cce:	85 d2                	test   %edx,%edx
  800cd0:	74 21                	je     800cf3 <strlcpy+0x35>
  800cd2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cd6:	89 f2                	mov    %esi,%edx
  800cd8:	eb 09                	jmp    800ce3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cda:	83 c2 01             	add    $0x1,%edx
  800cdd:	83 c1 01             	add    $0x1,%ecx
  800ce0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ce3:	39 c2                	cmp    %eax,%edx
  800ce5:	74 09                	je     800cf0 <strlcpy+0x32>
  800ce7:	0f b6 19             	movzbl (%ecx),%ebx
  800cea:	84 db                	test   %bl,%bl
  800cec:	75 ec                	jne    800cda <strlcpy+0x1c>
  800cee:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cf0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf3:	29 f0                	sub    %esi,%eax
}
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cff:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d02:	eb 06                	jmp    800d0a <strcmp+0x11>
		p++, q++;
  800d04:	83 c1 01             	add    $0x1,%ecx
  800d07:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d0a:	0f b6 01             	movzbl (%ecx),%eax
  800d0d:	84 c0                	test   %al,%al
  800d0f:	74 04                	je     800d15 <strcmp+0x1c>
  800d11:	3a 02                	cmp    (%edx),%al
  800d13:	74 ef                	je     800d04 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d15:	0f b6 c0             	movzbl %al,%eax
  800d18:	0f b6 12             	movzbl (%edx),%edx
  800d1b:	29 d0                	sub    %edx,%eax
}
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	53                   	push   %ebx
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d29:	89 c3                	mov    %eax,%ebx
  800d2b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d2e:	eb 06                	jmp    800d36 <strncmp+0x17>
		n--, p++, q++;
  800d30:	83 c0 01             	add    $0x1,%eax
  800d33:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d36:	39 d8                	cmp    %ebx,%eax
  800d38:	74 15                	je     800d4f <strncmp+0x30>
  800d3a:	0f b6 08             	movzbl (%eax),%ecx
  800d3d:	84 c9                	test   %cl,%cl
  800d3f:	74 04                	je     800d45 <strncmp+0x26>
  800d41:	3a 0a                	cmp    (%edx),%cl
  800d43:	74 eb                	je     800d30 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d45:	0f b6 00             	movzbl (%eax),%eax
  800d48:	0f b6 12             	movzbl (%edx),%edx
  800d4b:	29 d0                	sub    %edx,%eax
  800d4d:	eb 05                	jmp    800d54 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d4f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    

00800d57 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d61:	eb 07                	jmp    800d6a <strchr+0x13>
		if (*s == c)
  800d63:	38 ca                	cmp    %cl,%dl
  800d65:	74 0f                	je     800d76 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d67:	83 c0 01             	add    $0x1,%eax
  800d6a:	0f b6 10             	movzbl (%eax),%edx
  800d6d:	84 d2                	test   %dl,%dl
  800d6f:	75 f2                	jne    800d63 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d82:	eb 03                	jmp    800d87 <strfind+0xf>
  800d84:	83 c0 01             	add    $0x1,%eax
  800d87:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d8a:	38 ca                	cmp    %cl,%dl
  800d8c:	74 04                	je     800d92 <strfind+0x1a>
  800d8e:	84 d2                	test   %dl,%dl
  800d90:	75 f2                	jne    800d84 <strfind+0xc>
			break;
	return (char *) s;
}
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
  800d9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da0:	85 c9                	test   %ecx,%ecx
  800da2:	74 36                	je     800dda <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800daa:	75 28                	jne    800dd4 <memset+0x40>
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 23                	jne    800dd4 <memset+0x40>
		c &= 0xFF;
  800db1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db5:	89 d3                	mov    %edx,%ebx
  800db7:	c1 e3 08             	shl    $0x8,%ebx
  800dba:	89 d6                	mov    %edx,%esi
  800dbc:	c1 e6 18             	shl    $0x18,%esi
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	c1 e0 10             	shl    $0x10,%eax
  800dc4:	09 f0                	or     %esi,%eax
  800dc6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800dc8:	89 d8                	mov    %ebx,%eax
  800dca:	09 d0                	or     %edx,%eax
  800dcc:	c1 e9 02             	shr    $0x2,%ecx
  800dcf:	fc                   	cld    
  800dd0:	f3 ab                	rep stos %eax,%es:(%edi)
  800dd2:	eb 06                	jmp    800dda <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd7:	fc                   	cld    
  800dd8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dda:	89 f8                	mov    %edi,%eax
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
  800de9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800def:	39 c6                	cmp    %eax,%esi
  800df1:	73 35                	jae    800e28 <memmove+0x47>
  800df3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df6:	39 d0                	cmp    %edx,%eax
  800df8:	73 2e                	jae    800e28 <memmove+0x47>
		s += n;
		d += n;
  800dfa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dfd:	89 d6                	mov    %edx,%esi
  800dff:	09 fe                	or     %edi,%esi
  800e01:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e07:	75 13                	jne    800e1c <memmove+0x3b>
  800e09:	f6 c1 03             	test   $0x3,%cl
  800e0c:	75 0e                	jne    800e1c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e0e:	83 ef 04             	sub    $0x4,%edi
  800e11:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e14:	c1 e9 02             	shr    $0x2,%ecx
  800e17:	fd                   	std    
  800e18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e1a:	eb 09                	jmp    800e25 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e1c:	83 ef 01             	sub    $0x1,%edi
  800e1f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e22:	fd                   	std    
  800e23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e25:	fc                   	cld    
  800e26:	eb 1d                	jmp    800e45 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e28:	89 f2                	mov    %esi,%edx
  800e2a:	09 c2                	or     %eax,%edx
  800e2c:	f6 c2 03             	test   $0x3,%dl
  800e2f:	75 0f                	jne    800e40 <memmove+0x5f>
  800e31:	f6 c1 03             	test   $0x3,%cl
  800e34:	75 0a                	jne    800e40 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e36:	c1 e9 02             	shr    $0x2,%ecx
  800e39:	89 c7                	mov    %eax,%edi
  800e3b:	fc                   	cld    
  800e3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3e:	eb 05                	jmp    800e45 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e40:	89 c7                	mov    %eax,%edi
  800e42:	fc                   	cld    
  800e43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e4c:	ff 75 10             	pushl  0x10(%ebp)
  800e4f:	ff 75 0c             	pushl  0xc(%ebp)
  800e52:	ff 75 08             	pushl  0x8(%ebp)
  800e55:	e8 87 ff ff ff       	call   800de1 <memmove>
}
  800e5a:	c9                   	leave  
  800e5b:	c3                   	ret    

00800e5c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e67:	89 c6                	mov    %eax,%esi
  800e69:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6c:	eb 1a                	jmp    800e88 <memcmp+0x2c>
		if (*s1 != *s2)
  800e6e:	0f b6 08             	movzbl (%eax),%ecx
  800e71:	0f b6 1a             	movzbl (%edx),%ebx
  800e74:	38 d9                	cmp    %bl,%cl
  800e76:	74 0a                	je     800e82 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e78:	0f b6 c1             	movzbl %cl,%eax
  800e7b:	0f b6 db             	movzbl %bl,%ebx
  800e7e:	29 d8                	sub    %ebx,%eax
  800e80:	eb 0f                	jmp    800e91 <memcmp+0x35>
		s1++, s2++;
  800e82:	83 c0 01             	add    $0x1,%eax
  800e85:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e88:	39 f0                	cmp    %esi,%eax
  800e8a:	75 e2                	jne    800e6e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	53                   	push   %ebx
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e9c:	89 c1                	mov    %eax,%ecx
  800e9e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ea5:	eb 0a                	jmp    800eb1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea7:	0f b6 10             	movzbl (%eax),%edx
  800eaa:	39 da                	cmp    %ebx,%edx
  800eac:	74 07                	je     800eb5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eae:	83 c0 01             	add    $0x1,%eax
  800eb1:	39 c8                	cmp    %ecx,%eax
  800eb3:	72 f2                	jb     800ea7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb5:	5b                   	pop    %ebx
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
  800ebe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec4:	eb 03                	jmp    800ec9 <strtol+0x11>
		s++;
  800ec6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec9:	0f b6 01             	movzbl (%ecx),%eax
  800ecc:	3c 20                	cmp    $0x20,%al
  800ece:	74 f6                	je     800ec6 <strtol+0xe>
  800ed0:	3c 09                	cmp    $0x9,%al
  800ed2:	74 f2                	je     800ec6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed4:	3c 2b                	cmp    $0x2b,%al
  800ed6:	75 0a                	jne    800ee2 <strtol+0x2a>
		s++;
  800ed8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800edb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ee0:	eb 11                	jmp    800ef3 <strtol+0x3b>
  800ee2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ee7:	3c 2d                	cmp    $0x2d,%al
  800ee9:	75 08                	jne    800ef3 <strtol+0x3b>
		s++, neg = 1;
  800eeb:	83 c1 01             	add    $0x1,%ecx
  800eee:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ef9:	75 15                	jne    800f10 <strtol+0x58>
  800efb:	80 39 30             	cmpb   $0x30,(%ecx)
  800efe:	75 10                	jne    800f10 <strtol+0x58>
  800f00:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f04:	75 7c                	jne    800f82 <strtol+0xca>
		s += 2, base = 16;
  800f06:	83 c1 02             	add    $0x2,%ecx
  800f09:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f0e:	eb 16                	jmp    800f26 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f10:	85 db                	test   %ebx,%ebx
  800f12:	75 12                	jne    800f26 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f14:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f19:	80 39 30             	cmpb   $0x30,(%ecx)
  800f1c:	75 08                	jne    800f26 <strtol+0x6e>
		s++, base = 8;
  800f1e:	83 c1 01             	add    $0x1,%ecx
  800f21:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f2e:	0f b6 11             	movzbl (%ecx),%edx
  800f31:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f34:	89 f3                	mov    %esi,%ebx
  800f36:	80 fb 09             	cmp    $0x9,%bl
  800f39:	77 08                	ja     800f43 <strtol+0x8b>
			dig = *s - '0';
  800f3b:	0f be d2             	movsbl %dl,%edx
  800f3e:	83 ea 30             	sub    $0x30,%edx
  800f41:	eb 22                	jmp    800f65 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f43:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f46:	89 f3                	mov    %esi,%ebx
  800f48:	80 fb 19             	cmp    $0x19,%bl
  800f4b:	77 08                	ja     800f55 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f4d:	0f be d2             	movsbl %dl,%edx
  800f50:	83 ea 57             	sub    $0x57,%edx
  800f53:	eb 10                	jmp    800f65 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f55:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f58:	89 f3                	mov    %esi,%ebx
  800f5a:	80 fb 19             	cmp    $0x19,%bl
  800f5d:	77 16                	ja     800f75 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f5f:	0f be d2             	movsbl %dl,%edx
  800f62:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f65:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f68:	7d 0b                	jge    800f75 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f6a:	83 c1 01             	add    $0x1,%ecx
  800f6d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f71:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f73:	eb b9                	jmp    800f2e <strtol+0x76>

	if (endptr)
  800f75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f79:	74 0d                	je     800f88 <strtol+0xd0>
		*endptr = (char *) s;
  800f7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f7e:	89 0e                	mov    %ecx,(%esi)
  800f80:	eb 06                	jmp    800f88 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f82:	85 db                	test   %ebx,%ebx
  800f84:	74 98                	je     800f1e <strtol+0x66>
  800f86:	eb 9e                	jmp    800f26 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f88:	89 c2                	mov    %eax,%edx
  800f8a:	f7 da                	neg    %edx
  800f8c:	85 ff                	test   %edi,%edi
  800f8e:	0f 45 c2             	cmovne %edx,%eax
}
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa7:	89 c3                	mov    %eax,%ebx
  800fa9:	89 c7                	mov    %eax,%edi
  800fab:	89 c6                	mov    %eax,%esi
  800fad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fba:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbf:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc4:	89 d1                	mov    %edx,%ecx
  800fc6:	89 d3                	mov    %edx,%ebx
  800fc8:	89 d7                	mov    %edx,%edi
  800fca:	89 d6                	mov    %edx,%esi
  800fcc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe1:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe9:	89 cb                	mov    %ecx,%ebx
  800feb:	89 cf                	mov    %ecx,%edi
  800fed:	89 ce                	mov    %ecx,%esi
  800fef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	7e 17                	jle    80100c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff5:	83 ec 0c             	sub    $0xc,%esp
  800ff8:	50                   	push   %eax
  800ff9:	6a 03                	push   $0x3
  800ffb:	68 5f 2c 80 00       	push   $0x802c5f
  801000:	6a 23                	push   $0x23
  801002:	68 7c 2c 80 00       	push   $0x802c7c
  801007:	e8 e5 f5 ff ff       	call   8005f1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80100c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100f:	5b                   	pop    %ebx
  801010:	5e                   	pop    %esi
  801011:	5f                   	pop    %edi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	57                   	push   %edi
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101a:	ba 00 00 00 00       	mov    $0x0,%edx
  80101f:	b8 02 00 00 00       	mov    $0x2,%eax
  801024:	89 d1                	mov    %edx,%ecx
  801026:	89 d3                	mov    %edx,%ebx
  801028:	89 d7                	mov    %edx,%edi
  80102a:	89 d6                	mov    %edx,%esi
  80102c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5f                   	pop    %edi
  801031:	5d                   	pop    %ebp
  801032:	c3                   	ret    

00801033 <sys_yield>:

void
sys_yield(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	57                   	push   %edi
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801039:	ba 00 00 00 00       	mov    $0x0,%edx
  80103e:	b8 0b 00 00 00       	mov    $0xb,%eax
  801043:	89 d1                	mov    %edx,%ecx
  801045:	89 d3                	mov    %edx,%ebx
  801047:	89 d7                	mov    %edx,%edi
  801049:	89 d6                	mov    %edx,%esi
  80104b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80104d:	5b                   	pop    %ebx
  80104e:	5e                   	pop    %esi
  80104f:	5f                   	pop    %edi
  801050:	5d                   	pop    %ebp
  801051:	c3                   	ret    

00801052 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	57                   	push   %edi
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
  801058:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105b:	be 00 00 00 00       	mov    $0x0,%esi
  801060:	b8 04 00 00 00       	mov    $0x4,%eax
  801065:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801068:	8b 55 08             	mov    0x8(%ebp),%edx
  80106b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106e:	89 f7                	mov    %esi,%edi
  801070:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801072:	85 c0                	test   %eax,%eax
  801074:	7e 17                	jle    80108d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	50                   	push   %eax
  80107a:	6a 04                	push   $0x4
  80107c:	68 5f 2c 80 00       	push   $0x802c5f
  801081:	6a 23                	push   $0x23
  801083:	68 7c 2c 80 00       	push   $0x802c7c
  801088:	e8 64 f5 ff ff       	call   8005f1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
  80109b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109e:	b8 05 00 00 00       	mov    $0x5,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010af:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	7e 17                	jle    8010cf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	50                   	push   %eax
  8010bc:	6a 05                	push   $0x5
  8010be:	68 5f 2c 80 00       	push   $0x802c5f
  8010c3:	6a 23                	push   $0x23
  8010c5:	68 7c 2c 80 00       	push   $0x802c7c
  8010ca:	e8 22 f5 ff ff       	call   8005f1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8010ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f0:	89 df                	mov    %ebx,%edi
  8010f2:	89 de                	mov    %ebx,%esi
  8010f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	7e 17                	jle    801111 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	50                   	push   %eax
  8010fe:	6a 06                	push   $0x6
  801100:	68 5f 2c 80 00       	push   $0x802c5f
  801105:	6a 23                	push   $0x23
  801107:	68 7c 2c 80 00       	push   $0x802c7c
  80110c:	e8 e0 f4 ff ff       	call   8005f1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801114:	5b                   	pop    %ebx
  801115:	5e                   	pop    %esi
  801116:	5f                   	pop    %edi
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801122:	bb 00 00 00 00       	mov    $0x0,%ebx
  801127:	b8 08 00 00 00       	mov    $0x8,%eax
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112f:	8b 55 08             	mov    0x8(%ebp),%edx
  801132:	89 df                	mov    %ebx,%edi
  801134:	89 de                	mov    %ebx,%esi
  801136:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801138:	85 c0                	test   %eax,%eax
  80113a:	7e 17                	jle    801153 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113c:	83 ec 0c             	sub    $0xc,%esp
  80113f:	50                   	push   %eax
  801140:	6a 08                	push   $0x8
  801142:	68 5f 2c 80 00       	push   $0x802c5f
  801147:	6a 23                	push   $0x23
  801149:	68 7c 2c 80 00       	push   $0x802c7c
  80114e:	e8 9e f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801156:	5b                   	pop    %ebx
  801157:	5e                   	pop    %esi
  801158:	5f                   	pop    %edi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	57                   	push   %edi
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801164:	bb 00 00 00 00       	mov    $0x0,%ebx
  801169:	b8 09 00 00 00       	mov    $0x9,%eax
  80116e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801171:	8b 55 08             	mov    0x8(%ebp),%edx
  801174:	89 df                	mov    %ebx,%edi
  801176:	89 de                	mov    %ebx,%esi
  801178:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80117a:	85 c0                	test   %eax,%eax
  80117c:	7e 17                	jle    801195 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117e:	83 ec 0c             	sub    $0xc,%esp
  801181:	50                   	push   %eax
  801182:	6a 09                	push   $0x9
  801184:	68 5f 2c 80 00       	push   $0x802c5f
  801189:	6a 23                	push   $0x23
  80118b:	68 7c 2c 80 00       	push   $0x802c7c
  801190:	e8 5c f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	57                   	push   %edi
  8011a1:	56                   	push   %esi
  8011a2:	53                   	push   %ebx
  8011a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b6:	89 df                	mov    %ebx,%edi
  8011b8:	89 de                	mov    %ebx,%esi
  8011ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011bc:	85 c0                	test   %eax,%eax
  8011be:	7e 17                	jle    8011d7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c0:	83 ec 0c             	sub    $0xc,%esp
  8011c3:	50                   	push   %eax
  8011c4:	6a 0a                	push   $0xa
  8011c6:	68 5f 2c 80 00       	push   $0x802c5f
  8011cb:	6a 23                	push   $0x23
  8011cd:	68 7c 2c 80 00       	push   $0x802c7c
  8011d2:	e8 1a f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011da:	5b                   	pop    %ebx
  8011db:	5e                   	pop    %esi
  8011dc:	5f                   	pop    %edi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	57                   	push   %edi
  8011e3:	56                   	push   %esi
  8011e4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e5:	be 00 00 00 00       	mov    $0x0,%esi
  8011ea:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011fb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5f                   	pop    %edi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	57                   	push   %edi
  801206:	56                   	push   %esi
  801207:	53                   	push   %ebx
  801208:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801210:	b8 0d 00 00 00       	mov    $0xd,%eax
  801215:	8b 55 08             	mov    0x8(%ebp),%edx
  801218:	89 cb                	mov    %ecx,%ebx
  80121a:	89 cf                	mov    %ecx,%edi
  80121c:	89 ce                	mov    %ecx,%esi
  80121e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801220:	85 c0                	test   %eax,%eax
  801222:	7e 17                	jle    80123b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	50                   	push   %eax
  801228:	6a 0d                	push   $0xd
  80122a:	68 5f 2c 80 00       	push   $0x802c5f
  80122f:	6a 23                	push   $0x23
  801231:	68 7c 2c 80 00       	push   $0x802c7c
  801236:	e8 b6 f3 ff ff       	call   8005f1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80123b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123e:	5b                   	pop    %ebx
  80123f:	5e                   	pop    %esi
  801240:	5f                   	pop    %edi
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	57                   	push   %edi
  801247:	56                   	push   %esi
  801248:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801249:	ba 00 00 00 00       	mov    $0x0,%edx
  80124e:	b8 0e 00 00 00       	mov    $0xe,%eax
  801253:	89 d1                	mov    %edx,%ecx
  801255:	89 d3                	mov    %edx,%ebx
  801257:	89 d7                	mov    %edx,%edi
  801259:	89 d6                	mov    %edx,%esi
  80125b:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	53                   	push   %ebx
  801266:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801269:	83 3d b8 40 80 00 00 	cmpl   $0x0,0x8040b8
  801270:	75 28                	jne    80129a <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801272:	e8 9d fd ff ff       	call   801014 <sys_getenvid>
  801277:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801279:	83 ec 04             	sub    $0x4,%esp
  80127c:	6a 06                	push   $0x6
  80127e:	68 00 f0 bf ee       	push   $0xeebff000
  801283:	50                   	push   %eax
  801284:	e8 c9 fd ff ff       	call   801052 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801289:	83 c4 08             	add    $0x8,%esp
  80128c:	68 a7 12 80 00       	push   $0x8012a7
  801291:	53                   	push   %ebx
  801292:	e8 06 ff ff ff       	call   80119d <sys_env_set_pgfault_upcall>
  801297:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80129a:	8b 45 08             	mov    0x8(%ebp),%eax
  80129d:	a3 b8 40 80 00       	mov    %eax,0x8040b8
}
  8012a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012a7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012a8:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	call *%eax
  8012ad:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012af:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  8012b2:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  8012b4:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  8012b7:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  8012ba:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  8012bd:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  8012c0:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  8012c3:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  8012c6:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  8012c9:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  8012cc:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  8012cf:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  8012d2:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  8012d5:	61                   	popa   
	popfl
  8012d6:	9d                   	popf   
	ret
  8012d7:	c3                   	ret    

008012d8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012db:	8b 45 08             	mov    0x8(%ebp),%eax
  8012de:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e3:	c1 e8 0c             	shr    $0xc,%eax
}
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8012f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012f8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801305:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80130a:	89 c2                	mov    %eax,%edx
  80130c:	c1 ea 16             	shr    $0x16,%edx
  80130f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801316:	f6 c2 01             	test   $0x1,%dl
  801319:	74 11                	je     80132c <fd_alloc+0x2d>
  80131b:	89 c2                	mov    %eax,%edx
  80131d:	c1 ea 0c             	shr    $0xc,%edx
  801320:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801327:	f6 c2 01             	test   $0x1,%dl
  80132a:	75 09                	jne    801335 <fd_alloc+0x36>
			*fd_store = fd;
  80132c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80132e:	b8 00 00 00 00       	mov    $0x0,%eax
  801333:	eb 17                	jmp    80134c <fd_alloc+0x4d>
  801335:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80133a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80133f:	75 c9                	jne    80130a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801341:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801347:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801354:	83 f8 1f             	cmp    $0x1f,%eax
  801357:	77 36                	ja     80138f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801359:	c1 e0 0c             	shl    $0xc,%eax
  80135c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801361:	89 c2                	mov    %eax,%edx
  801363:	c1 ea 16             	shr    $0x16,%edx
  801366:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80136d:	f6 c2 01             	test   $0x1,%dl
  801370:	74 24                	je     801396 <fd_lookup+0x48>
  801372:	89 c2                	mov    %eax,%edx
  801374:	c1 ea 0c             	shr    $0xc,%edx
  801377:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137e:	f6 c2 01             	test   $0x1,%dl
  801381:	74 1a                	je     80139d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801383:	8b 55 0c             	mov    0xc(%ebp),%edx
  801386:	89 02                	mov    %eax,(%edx)
	return 0;
  801388:	b8 00 00 00 00       	mov    $0x0,%eax
  80138d:	eb 13                	jmp    8013a2 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80138f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801394:	eb 0c                	jmp    8013a2 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801396:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139b:	eb 05                	jmp    8013a2 <fd_lookup+0x54>
  80139d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ad:	ba 0c 2d 80 00       	mov    $0x802d0c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013b2:	eb 13                	jmp    8013c7 <dev_lookup+0x23>
  8013b4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013b7:	39 08                	cmp    %ecx,(%eax)
  8013b9:	75 0c                	jne    8013c7 <dev_lookup+0x23>
			*dev = devtab[i];
  8013bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c5:	eb 2e                	jmp    8013f5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013c7:	8b 02                	mov    (%edx),%eax
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	75 e7                	jne    8013b4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013cd:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8013d2:	8b 40 48             	mov    0x48(%eax),%eax
  8013d5:	83 ec 04             	sub    $0x4,%esp
  8013d8:	51                   	push   %ecx
  8013d9:	50                   	push   %eax
  8013da:	68 8c 2c 80 00       	push   $0x802c8c
  8013df:	e8 e6 f2 ff ff       	call   8006ca <cprintf>
	*dev = 0;
  8013e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	56                   	push   %esi
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 10             	sub    $0x10,%esp
  8013ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801402:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801408:	50                   	push   %eax
  801409:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80140f:	c1 e8 0c             	shr    $0xc,%eax
  801412:	50                   	push   %eax
  801413:	e8 36 ff ff ff       	call   80134e <fd_lookup>
  801418:	83 c4 08             	add    $0x8,%esp
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 05                	js     801424 <fd_close+0x2d>
	    || fd != fd2)
  80141f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801422:	74 0c                	je     801430 <fd_close+0x39>
		return (must_exist ? r : 0);
  801424:	84 db                	test   %bl,%bl
  801426:	ba 00 00 00 00       	mov    $0x0,%edx
  80142b:	0f 44 c2             	cmove  %edx,%eax
  80142e:	eb 41                	jmp    801471 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801436:	50                   	push   %eax
  801437:	ff 36                	pushl  (%esi)
  801439:	e8 66 ff ff ff       	call   8013a4 <dev_lookup>
  80143e:	89 c3                	mov    %eax,%ebx
  801440:	83 c4 10             	add    $0x10,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 1a                	js     801461 <fd_close+0x6a>
		if (dev->dev_close)
  801447:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80144d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801452:	85 c0                	test   %eax,%eax
  801454:	74 0b                	je     801461 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	56                   	push   %esi
  80145a:	ff d0                	call   *%eax
  80145c:	89 c3                	mov    %eax,%ebx
  80145e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	56                   	push   %esi
  801465:	6a 00                	push   $0x0
  801467:	e8 6b fc ff ff       	call   8010d7 <sys_page_unmap>
	return r;
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	89 d8                	mov    %ebx,%eax
}
  801471:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801474:	5b                   	pop    %ebx
  801475:	5e                   	pop    %esi
  801476:	5d                   	pop    %ebp
  801477:	c3                   	ret    

00801478 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	ff 75 08             	pushl  0x8(%ebp)
  801485:	e8 c4 fe ff ff       	call   80134e <fd_lookup>
  80148a:	83 c4 08             	add    $0x8,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 10                	js     8014a1 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	6a 01                	push   $0x1
  801496:	ff 75 f4             	pushl  -0xc(%ebp)
  801499:	e8 59 ff ff ff       	call   8013f7 <fd_close>
  80149e:	83 c4 10             	add    $0x10,%esp
}
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <close_all>:

void
close_all(void)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	53                   	push   %ebx
  8014b3:	e8 c0 ff ff ff       	call   801478 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b8:	83 c3 01             	add    $0x1,%ebx
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	83 fb 20             	cmp    $0x20,%ebx
  8014c1:	75 ec                	jne    8014af <close_all+0xc>
		close(i);
}
  8014c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	57                   	push   %edi
  8014cc:	56                   	push   %esi
  8014cd:	53                   	push   %ebx
  8014ce:	83 ec 2c             	sub    $0x2c,%esp
  8014d1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014d7:	50                   	push   %eax
  8014d8:	ff 75 08             	pushl  0x8(%ebp)
  8014db:	e8 6e fe ff ff       	call   80134e <fd_lookup>
  8014e0:	83 c4 08             	add    $0x8,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	0f 88 c1 00 00 00    	js     8015ac <dup+0xe4>
		return r;
	close(newfdnum);
  8014eb:	83 ec 0c             	sub    $0xc,%esp
  8014ee:	56                   	push   %esi
  8014ef:	e8 84 ff ff ff       	call   801478 <close>

	newfd = INDEX2FD(newfdnum);
  8014f4:	89 f3                	mov    %esi,%ebx
  8014f6:	c1 e3 0c             	shl    $0xc,%ebx
  8014f9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014ff:	83 c4 04             	add    $0x4,%esp
  801502:	ff 75 e4             	pushl  -0x1c(%ebp)
  801505:	e8 de fd ff ff       	call   8012e8 <fd2data>
  80150a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80150c:	89 1c 24             	mov    %ebx,(%esp)
  80150f:	e8 d4 fd ff ff       	call   8012e8 <fd2data>
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80151a:	89 f8                	mov    %edi,%eax
  80151c:	c1 e8 16             	shr    $0x16,%eax
  80151f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801526:	a8 01                	test   $0x1,%al
  801528:	74 37                	je     801561 <dup+0x99>
  80152a:	89 f8                	mov    %edi,%eax
  80152c:	c1 e8 0c             	shr    $0xc,%eax
  80152f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801536:	f6 c2 01             	test   $0x1,%dl
  801539:	74 26                	je     801561 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80153b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801542:	83 ec 0c             	sub    $0xc,%esp
  801545:	25 07 0e 00 00       	and    $0xe07,%eax
  80154a:	50                   	push   %eax
  80154b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80154e:	6a 00                	push   $0x0
  801550:	57                   	push   %edi
  801551:	6a 00                	push   $0x0
  801553:	e8 3d fb ff ff       	call   801095 <sys_page_map>
  801558:	89 c7                	mov    %eax,%edi
  80155a:	83 c4 20             	add    $0x20,%esp
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 2e                	js     80158f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801561:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801564:	89 d0                	mov    %edx,%eax
  801566:	c1 e8 0c             	shr    $0xc,%eax
  801569:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801570:	83 ec 0c             	sub    $0xc,%esp
  801573:	25 07 0e 00 00       	and    $0xe07,%eax
  801578:	50                   	push   %eax
  801579:	53                   	push   %ebx
  80157a:	6a 00                	push   $0x0
  80157c:	52                   	push   %edx
  80157d:	6a 00                	push   $0x0
  80157f:	e8 11 fb ff ff       	call   801095 <sys_page_map>
  801584:	89 c7                	mov    %eax,%edi
  801586:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801589:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80158b:	85 ff                	test   %edi,%edi
  80158d:	79 1d                	jns    8015ac <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	53                   	push   %ebx
  801593:	6a 00                	push   $0x0
  801595:	e8 3d fb ff ff       	call   8010d7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80159a:	83 c4 08             	add    $0x8,%esp
  80159d:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015a0:	6a 00                	push   $0x0
  8015a2:	e8 30 fb ff ff       	call   8010d7 <sys_page_unmap>
	return r;
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	89 f8                	mov    %edi,%eax
}
  8015ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5f                   	pop    %edi
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 14             	sub    $0x14,%esp
  8015bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	53                   	push   %ebx
  8015c3:	e8 86 fd ff ff       	call   80134e <fd_lookup>
  8015c8:	83 c4 08             	add    $0x8,%esp
  8015cb:	89 c2                	mov    %eax,%edx
  8015cd:	85 c0                	test   %eax,%eax
  8015cf:	78 6d                	js     80163e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015db:	ff 30                	pushl  (%eax)
  8015dd:	e8 c2 fd ff ff       	call   8013a4 <dev_lookup>
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	78 4c                	js     801635 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ec:	8b 42 08             	mov    0x8(%edx),%eax
  8015ef:	83 e0 03             	and    $0x3,%eax
  8015f2:	83 f8 01             	cmp    $0x1,%eax
  8015f5:	75 21                	jne    801618 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f7:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8015fc:	8b 40 48             	mov    0x48(%eax),%eax
  8015ff:	83 ec 04             	sub    $0x4,%esp
  801602:	53                   	push   %ebx
  801603:	50                   	push   %eax
  801604:	68 d0 2c 80 00       	push   $0x802cd0
  801609:	e8 bc f0 ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801616:	eb 26                	jmp    80163e <read+0x8a>
	}
	if (!dev->dev_read)
  801618:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161b:	8b 40 08             	mov    0x8(%eax),%eax
  80161e:	85 c0                	test   %eax,%eax
  801620:	74 17                	je     801639 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801622:	83 ec 04             	sub    $0x4,%esp
  801625:	ff 75 10             	pushl  0x10(%ebp)
  801628:	ff 75 0c             	pushl  0xc(%ebp)
  80162b:	52                   	push   %edx
  80162c:	ff d0                	call   *%eax
  80162e:	89 c2                	mov    %eax,%edx
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	eb 09                	jmp    80163e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801635:	89 c2                	mov    %eax,%edx
  801637:	eb 05                	jmp    80163e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801639:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80163e:	89 d0                	mov    %edx,%eax
  801640:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	57                   	push   %edi
  801649:	56                   	push   %esi
  80164a:	53                   	push   %ebx
  80164b:	83 ec 0c             	sub    $0xc,%esp
  80164e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801651:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801654:	bb 00 00 00 00       	mov    $0x0,%ebx
  801659:	eb 21                	jmp    80167c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	89 f0                	mov    %esi,%eax
  801660:	29 d8                	sub    %ebx,%eax
  801662:	50                   	push   %eax
  801663:	89 d8                	mov    %ebx,%eax
  801665:	03 45 0c             	add    0xc(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	57                   	push   %edi
  80166a:	e8 45 ff ff ff       	call   8015b4 <read>
		if (m < 0)
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 10                	js     801686 <readn+0x41>
			return m;
		if (m == 0)
  801676:	85 c0                	test   %eax,%eax
  801678:	74 0a                	je     801684 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167a:	01 c3                	add    %eax,%ebx
  80167c:	39 f3                	cmp    %esi,%ebx
  80167e:	72 db                	jb     80165b <readn+0x16>
  801680:	89 d8                	mov    %ebx,%eax
  801682:	eb 02                	jmp    801686 <readn+0x41>
  801684:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801686:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801689:	5b                   	pop    %ebx
  80168a:	5e                   	pop    %esi
  80168b:	5f                   	pop    %edi
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	53                   	push   %ebx
  801692:	83 ec 14             	sub    $0x14,%esp
  801695:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801698:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	53                   	push   %ebx
  80169d:	e8 ac fc ff ff       	call   80134e <fd_lookup>
  8016a2:	83 c4 08             	add    $0x8,%esp
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	78 68                	js     801713 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b5:	ff 30                	pushl  (%eax)
  8016b7:	e8 e8 fc ff ff       	call   8013a4 <dev_lookup>
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 47                	js     80170a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016ca:	75 21                	jne    8016ed <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016cc:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8016d1:	8b 40 48             	mov    0x48(%eax),%eax
  8016d4:	83 ec 04             	sub    $0x4,%esp
  8016d7:	53                   	push   %ebx
  8016d8:	50                   	push   %eax
  8016d9:	68 ec 2c 80 00       	push   $0x802cec
  8016de:	e8 e7 ef ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016eb:	eb 26                	jmp    801713 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016f0:	8b 52 0c             	mov    0xc(%edx),%edx
  8016f3:	85 d2                	test   %edx,%edx
  8016f5:	74 17                	je     80170e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f7:	83 ec 04             	sub    $0x4,%esp
  8016fa:	ff 75 10             	pushl  0x10(%ebp)
  8016fd:	ff 75 0c             	pushl  0xc(%ebp)
  801700:	50                   	push   %eax
  801701:	ff d2                	call   *%edx
  801703:	89 c2                	mov    %eax,%edx
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	eb 09                	jmp    801713 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170a:	89 c2                	mov    %eax,%edx
  80170c:	eb 05                	jmp    801713 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80170e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801713:	89 d0                	mov    %edx,%eax
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <seek>:

int
seek(int fdnum, off_t offset)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801720:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801723:	50                   	push   %eax
  801724:	ff 75 08             	pushl  0x8(%ebp)
  801727:	e8 22 fc ff ff       	call   80134e <fd_lookup>
  80172c:	83 c4 08             	add    $0x8,%esp
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 0e                	js     801741 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801733:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801736:	8b 55 0c             	mov    0xc(%ebp),%edx
  801739:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80173c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801741:	c9                   	leave  
  801742:	c3                   	ret    

00801743 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	53                   	push   %ebx
  801747:	83 ec 14             	sub    $0x14,%esp
  80174a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801750:	50                   	push   %eax
  801751:	53                   	push   %ebx
  801752:	e8 f7 fb ff ff       	call   80134e <fd_lookup>
  801757:	83 c4 08             	add    $0x8,%esp
  80175a:	89 c2                	mov    %eax,%edx
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 65                	js     8017c5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801766:	50                   	push   %eax
  801767:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176a:	ff 30                	pushl  (%eax)
  80176c:	e8 33 fc ff ff       	call   8013a4 <dev_lookup>
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	85 c0                	test   %eax,%eax
  801776:	78 44                	js     8017bc <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801778:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177f:	75 21                	jne    8017a2 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801781:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801786:	8b 40 48             	mov    0x48(%eax),%eax
  801789:	83 ec 04             	sub    $0x4,%esp
  80178c:	53                   	push   %ebx
  80178d:	50                   	push   %eax
  80178e:	68 ac 2c 80 00       	push   $0x802cac
  801793:	e8 32 ef ff ff       	call   8006ca <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a0:	eb 23                	jmp    8017c5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a5:	8b 52 18             	mov    0x18(%edx),%edx
  8017a8:	85 d2                	test   %edx,%edx
  8017aa:	74 14                	je     8017c0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017ac:	83 ec 08             	sub    $0x8,%esp
  8017af:	ff 75 0c             	pushl  0xc(%ebp)
  8017b2:	50                   	push   %eax
  8017b3:	ff d2                	call   *%edx
  8017b5:	89 c2                	mov    %eax,%edx
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	eb 09                	jmp    8017c5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bc:	89 c2                	mov    %eax,%edx
  8017be:	eb 05                	jmp    8017c5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017c5:	89 d0                	mov    %edx,%eax
  8017c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 14             	sub    $0x14,%esp
  8017d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d9:	50                   	push   %eax
  8017da:	ff 75 08             	pushl  0x8(%ebp)
  8017dd:	e8 6c fb ff ff       	call   80134e <fd_lookup>
  8017e2:	83 c4 08             	add    $0x8,%esp
  8017e5:	89 c2                	mov    %eax,%edx
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 58                	js     801843 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f1:	50                   	push   %eax
  8017f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f5:	ff 30                	pushl  (%eax)
  8017f7:	e8 a8 fb ff ff       	call   8013a4 <dev_lookup>
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 37                	js     80183a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801803:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801806:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80180a:	74 32                	je     80183e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80180c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80180f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801816:	00 00 00 
	stat->st_isdir = 0;
  801819:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801820:	00 00 00 
	stat->st_dev = dev;
  801823:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	53                   	push   %ebx
  80182d:	ff 75 f0             	pushl  -0x10(%ebp)
  801830:	ff 50 14             	call   *0x14(%eax)
  801833:	89 c2                	mov    %eax,%edx
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	eb 09                	jmp    801843 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183a:	89 c2                	mov    %eax,%edx
  80183c:	eb 05                	jmp    801843 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80183e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801843:	89 d0                	mov    %edx,%eax
  801845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	56                   	push   %esi
  80184e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	6a 00                	push   $0x0
  801854:	ff 75 08             	pushl  0x8(%ebp)
  801857:	e8 0c 02 00 00       	call   801a68 <open>
  80185c:	89 c3                	mov    %eax,%ebx
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	85 c0                	test   %eax,%eax
  801863:	78 1b                	js     801880 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801865:	83 ec 08             	sub    $0x8,%esp
  801868:	ff 75 0c             	pushl  0xc(%ebp)
  80186b:	50                   	push   %eax
  80186c:	e8 5b ff ff ff       	call   8017cc <fstat>
  801871:	89 c6                	mov    %eax,%esi
	close(fd);
  801873:	89 1c 24             	mov    %ebx,(%esp)
  801876:	e8 fd fb ff ff       	call   801478 <close>
	return r;
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	89 f0                	mov    %esi,%eax
}
  801880:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801883:	5b                   	pop    %ebx
  801884:	5e                   	pop    %esi
  801885:	5d                   	pop    %ebp
  801886:	c3                   	ret    

00801887 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	56                   	push   %esi
  80188b:	53                   	push   %ebx
  80188c:	89 c6                	mov    %eax,%esi
  80188e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801890:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801897:	75 12                	jne    8018ab <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801899:	83 ec 0c             	sub    $0xc,%esp
  80189c:	6a 01                	push   $0x1
  80189e:	e8 6c 0c 00 00       	call   80250f <ipc_find_env>
  8018a3:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018a8:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ab:	6a 07                	push   $0x7
  8018ad:	68 00 50 80 00       	push   $0x805000
  8018b2:	56                   	push   %esi
  8018b3:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018b9:	e8 fd 0b 00 00       	call   8024bb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018be:	83 c4 0c             	add    $0xc,%esp
  8018c1:	6a 00                	push   $0x0
  8018c3:	53                   	push   %ebx
  8018c4:	6a 00                	push   $0x0
  8018c6:	e8 87 0b 00 00       	call   802452 <ipc_recv>
}
  8018cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ce:	5b                   	pop    %ebx
  8018cf:	5e                   	pop    %esi
  8018d0:	5d                   	pop    %ebp
  8018d1:	c3                   	ret    

008018d2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018db:	8b 40 0c             	mov    0xc(%eax),%eax
  8018de:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f5:	e8 8d ff ff ff       	call   801887 <fsipc>
}
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801902:	8b 45 08             	mov    0x8(%ebp),%eax
  801905:	8b 40 0c             	mov    0xc(%eax),%eax
  801908:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80190d:	ba 00 00 00 00       	mov    $0x0,%edx
  801912:	b8 06 00 00 00       	mov    $0x6,%eax
  801917:	e8 6b ff ff ff       	call   801887 <fsipc>
}
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	53                   	push   %ebx
  801922:	83 ec 04             	sub    $0x4,%esp
  801925:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	8b 40 0c             	mov    0xc(%eax),%eax
  80192e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801933:	ba 00 00 00 00       	mov    $0x0,%edx
  801938:	b8 05 00 00 00       	mov    $0x5,%eax
  80193d:	e8 45 ff ff ff       	call   801887 <fsipc>
  801942:	85 c0                	test   %eax,%eax
  801944:	78 2c                	js     801972 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801946:	83 ec 08             	sub    $0x8,%esp
  801949:	68 00 50 80 00       	push   $0x805000
  80194e:	53                   	push   %ebx
  80194f:	e8 fb f2 ff ff       	call   800c4f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801954:	a1 80 50 80 00       	mov    0x805080,%eax
  801959:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80195f:	a1 84 50 80 00       	mov    0x805084,%eax
  801964:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801972:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801975:	c9                   	leave  
  801976:	c3                   	ret    

00801977 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	53                   	push   %ebx
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801981:	8b 55 08             	mov    0x8(%ebp),%edx
  801984:	8b 52 0c             	mov    0xc(%edx),%edx
  801987:	89 15 00 50 80 00    	mov    %edx,0x805000
  80198d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801992:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801997:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  80199a:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  8019a0:	53                   	push   %ebx
  8019a1:	ff 75 0c             	pushl  0xc(%ebp)
  8019a4:	68 08 50 80 00       	push   $0x805008
  8019a9:	e8 33 f4 ff ff       	call   800de1 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  8019ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b8:	e8 ca fe ff ff       	call   801887 <fsipc>
  8019bd:	83 c4 10             	add    $0x10,%esp
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	78 1d                	js     8019e1 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  8019c4:	39 d8                	cmp    %ebx,%eax
  8019c6:	76 19                	jbe    8019e1 <devfile_write+0x6a>
  8019c8:	68 20 2d 80 00       	push   $0x802d20
  8019cd:	68 2c 2d 80 00       	push   $0x802d2c
  8019d2:	68 a3 00 00 00       	push   $0xa3
  8019d7:	68 41 2d 80 00       	push   $0x802d41
  8019dc:	e8 10 ec ff ff       	call   8005f1 <_panic>
	return r;
}
  8019e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	56                   	push   %esi
  8019ea:	53                   	push   %ebx
  8019eb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019f9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801a04:	b8 03 00 00 00       	mov    $0x3,%eax
  801a09:	e8 79 fe ff ff       	call   801887 <fsipc>
  801a0e:	89 c3                	mov    %eax,%ebx
  801a10:	85 c0                	test   %eax,%eax
  801a12:	78 4b                	js     801a5f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a14:	39 c6                	cmp    %eax,%esi
  801a16:	73 16                	jae    801a2e <devfile_read+0x48>
  801a18:	68 4c 2d 80 00       	push   $0x802d4c
  801a1d:	68 2c 2d 80 00       	push   $0x802d2c
  801a22:	6a 7c                	push   $0x7c
  801a24:	68 41 2d 80 00       	push   $0x802d41
  801a29:	e8 c3 eb ff ff       	call   8005f1 <_panic>
	assert(r <= PGSIZE);
  801a2e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a33:	7e 16                	jle    801a4b <devfile_read+0x65>
  801a35:	68 53 2d 80 00       	push   $0x802d53
  801a3a:	68 2c 2d 80 00       	push   $0x802d2c
  801a3f:	6a 7d                	push   $0x7d
  801a41:	68 41 2d 80 00       	push   $0x802d41
  801a46:	e8 a6 eb ff ff       	call   8005f1 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a4b:	83 ec 04             	sub    $0x4,%esp
  801a4e:	50                   	push   %eax
  801a4f:	68 00 50 80 00       	push   $0x805000
  801a54:	ff 75 0c             	pushl  0xc(%ebp)
  801a57:	e8 85 f3 ff ff       	call   800de1 <memmove>
	return r;
  801a5c:	83 c4 10             	add    $0x10,%esp
}
  801a5f:	89 d8                	mov    %ebx,%eax
  801a61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	53                   	push   %ebx
  801a6c:	83 ec 20             	sub    $0x20,%esp
  801a6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a72:	53                   	push   %ebx
  801a73:	e8 9e f1 ff ff       	call   800c16 <strlen>
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a80:	7f 67                	jg     801ae9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a82:	83 ec 0c             	sub    $0xc,%esp
  801a85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a88:	50                   	push   %eax
  801a89:	e8 71 f8 ff ff       	call   8012ff <fd_alloc>
  801a8e:	83 c4 10             	add    $0x10,%esp
		return r;
  801a91:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a93:	85 c0                	test   %eax,%eax
  801a95:	78 57                	js     801aee <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a97:	83 ec 08             	sub    $0x8,%esp
  801a9a:	53                   	push   %ebx
  801a9b:	68 00 50 80 00       	push   $0x805000
  801aa0:	e8 aa f1 ff ff       	call   800c4f <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab5:	e8 cd fd ff ff       	call   801887 <fsipc>
  801aba:	89 c3                	mov    %eax,%ebx
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	85 c0                	test   %eax,%eax
  801ac1:	79 14                	jns    801ad7 <open+0x6f>
		fd_close(fd, 0);
  801ac3:	83 ec 08             	sub    $0x8,%esp
  801ac6:	6a 00                	push   $0x0
  801ac8:	ff 75 f4             	pushl  -0xc(%ebp)
  801acb:	e8 27 f9 ff ff       	call   8013f7 <fd_close>
		return r;
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	89 da                	mov    %ebx,%edx
  801ad5:	eb 17                	jmp    801aee <open+0x86>
	}

	return fd2num(fd);
  801ad7:	83 ec 0c             	sub    $0xc,%esp
  801ada:	ff 75 f4             	pushl  -0xc(%ebp)
  801add:	e8 f6 f7 ff ff       	call   8012d8 <fd2num>
  801ae2:	89 c2                	mov    %eax,%edx
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	eb 05                	jmp    801aee <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ae9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aee:	89 d0                	mov    %edx,%eax
  801af0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af3:	c9                   	leave  
  801af4:	c3                   	ret    

00801af5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801afb:	ba 00 00 00 00       	mov    $0x0,%edx
  801b00:	b8 08 00 00 00       	mov    $0x8,%eax
  801b05:	e8 7d fd ff ff       	call   801887 <fsipc>
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b12:	68 5f 2d 80 00       	push   $0x802d5f
  801b17:	ff 75 0c             	pushl  0xc(%ebp)
  801b1a:	e8 30 f1 ff ff       	call   800c4f <strcpy>
	return 0;
}
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b24:	c9                   	leave  
  801b25:	c3                   	ret    

00801b26 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 10             	sub    $0x10,%esp
  801b2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b30:	53                   	push   %ebx
  801b31:	e8 12 0a 00 00       	call   802548 <pageref>
  801b36:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b39:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b3e:	83 f8 01             	cmp    $0x1,%eax
  801b41:	75 10                	jne    801b53 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b43:	83 ec 0c             	sub    $0xc,%esp
  801b46:	ff 73 0c             	pushl  0xc(%ebx)
  801b49:	e8 c0 02 00 00       	call   801e0e <nsipc_close>
  801b4e:	89 c2                	mov    %eax,%edx
  801b50:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b53:	89 d0                	mov    %edx,%eax
  801b55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b60:	6a 00                	push   $0x0
  801b62:	ff 75 10             	pushl  0x10(%ebp)
  801b65:	ff 75 0c             	pushl  0xc(%ebp)
  801b68:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6b:	ff 70 0c             	pushl  0xc(%eax)
  801b6e:	e8 78 03 00 00       	call   801eeb <nsipc_send>
}
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b7b:	6a 00                	push   $0x0
  801b7d:	ff 75 10             	pushl  0x10(%ebp)
  801b80:	ff 75 0c             	pushl  0xc(%ebp)
  801b83:	8b 45 08             	mov    0x8(%ebp),%eax
  801b86:	ff 70 0c             	pushl  0xc(%eax)
  801b89:	e8 f1 02 00 00       	call   801e7f <nsipc_recv>
}
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b96:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b99:	52                   	push   %edx
  801b9a:	50                   	push   %eax
  801b9b:	e8 ae f7 ff ff       	call   80134e <fd_lookup>
  801ba0:	83 c4 10             	add    $0x10,%esp
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	78 17                	js     801bbe <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801baa:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801bb0:	39 08                	cmp    %ecx,(%eax)
  801bb2:	75 05                	jne    801bb9 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bb4:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb7:	eb 05                	jmp    801bbe <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801bb9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 1c             	sub    $0x1c,%esp
  801bc8:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bcd:	50                   	push   %eax
  801bce:	e8 2c f7 ff ff       	call   8012ff <fd_alloc>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 1b                	js     801bf7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bdc:	83 ec 04             	sub    $0x4,%esp
  801bdf:	68 07 04 00 00       	push   $0x407
  801be4:	ff 75 f4             	pushl  -0xc(%ebp)
  801be7:	6a 00                	push   $0x0
  801be9:	e8 64 f4 ff ff       	call   801052 <sys_page_alloc>
  801bee:	89 c3                	mov    %eax,%ebx
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	79 10                	jns    801c07 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	56                   	push   %esi
  801bfb:	e8 0e 02 00 00       	call   801e0e <nsipc_close>
		return r;
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	89 d8                	mov    %ebx,%eax
  801c05:	eb 24                	jmp    801c2b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c07:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c10:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c15:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c1c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c1f:	83 ec 0c             	sub    $0xc,%esp
  801c22:	50                   	push   %eax
  801c23:	e8 b0 f6 ff ff       	call   8012d8 <fd2num>
  801c28:	83 c4 10             	add    $0x10,%esp
}
  801c2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2e:	5b                   	pop    %ebx
  801c2f:	5e                   	pop    %esi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c38:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3b:	e8 50 ff ff ff       	call   801b90 <fd2sockid>
		return r;
  801c40:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c42:	85 c0                	test   %eax,%eax
  801c44:	78 1f                	js     801c65 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c46:	83 ec 04             	sub    $0x4,%esp
  801c49:	ff 75 10             	pushl  0x10(%ebp)
  801c4c:	ff 75 0c             	pushl  0xc(%ebp)
  801c4f:	50                   	push   %eax
  801c50:	e8 12 01 00 00       	call   801d67 <nsipc_accept>
  801c55:	83 c4 10             	add    $0x10,%esp
		return r;
  801c58:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	78 07                	js     801c65 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c5e:	e8 5d ff ff ff       	call   801bc0 <alloc_sockfd>
  801c63:	89 c1                	mov    %eax,%ecx
}
  801c65:	89 c8                	mov    %ecx,%eax
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    

00801c69 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c72:	e8 19 ff ff ff       	call   801b90 <fd2sockid>
  801c77:	85 c0                	test   %eax,%eax
  801c79:	78 12                	js     801c8d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c7b:	83 ec 04             	sub    $0x4,%esp
  801c7e:	ff 75 10             	pushl  0x10(%ebp)
  801c81:	ff 75 0c             	pushl  0xc(%ebp)
  801c84:	50                   	push   %eax
  801c85:	e8 2d 01 00 00       	call   801db7 <nsipc_bind>
  801c8a:	83 c4 10             	add    $0x10,%esp
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <shutdown>:

int
shutdown(int s, int how)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	e8 f3 fe ff ff       	call   801b90 <fd2sockid>
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	78 0f                	js     801cb0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ca1:	83 ec 08             	sub    $0x8,%esp
  801ca4:	ff 75 0c             	pushl  0xc(%ebp)
  801ca7:	50                   	push   %eax
  801ca8:	e8 3f 01 00 00       	call   801dec <nsipc_shutdown>
  801cad:	83 c4 10             	add    $0x10,%esp
}
  801cb0:	c9                   	leave  
  801cb1:	c3                   	ret    

00801cb2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbb:	e8 d0 fe ff ff       	call   801b90 <fd2sockid>
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	78 12                	js     801cd6 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801cc4:	83 ec 04             	sub    $0x4,%esp
  801cc7:	ff 75 10             	pushl  0x10(%ebp)
  801cca:	ff 75 0c             	pushl  0xc(%ebp)
  801ccd:	50                   	push   %eax
  801cce:	e8 55 01 00 00       	call   801e28 <nsipc_connect>
  801cd3:	83 c4 10             	add    $0x10,%esp
}
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <listen>:

int
listen(int s, int backlog)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	e8 aa fe ff ff       	call   801b90 <fd2sockid>
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	78 0f                	js     801cf9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801cea:	83 ec 08             	sub    $0x8,%esp
  801ced:	ff 75 0c             	pushl  0xc(%ebp)
  801cf0:	50                   	push   %eax
  801cf1:	e8 67 01 00 00       	call   801e5d <nsipc_listen>
  801cf6:	83 c4 10             	add    $0x10,%esp
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d01:	ff 75 10             	pushl  0x10(%ebp)
  801d04:	ff 75 0c             	pushl  0xc(%ebp)
  801d07:	ff 75 08             	pushl  0x8(%ebp)
  801d0a:	e8 3a 02 00 00       	call   801f49 <nsipc_socket>
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	85 c0                	test   %eax,%eax
  801d14:	78 05                	js     801d1b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d16:	e8 a5 fe ff ff       	call   801bc0 <alloc_sockfd>
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	53                   	push   %ebx
  801d21:	83 ec 04             	sub    $0x4,%esp
  801d24:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d26:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  801d2d:	75 12                	jne    801d41 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d2f:	83 ec 0c             	sub    $0xc,%esp
  801d32:	6a 02                	push   $0x2
  801d34:	e8 d6 07 00 00       	call   80250f <ipc_find_env>
  801d39:	a3 b0 40 80 00       	mov    %eax,0x8040b0
  801d3e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d41:	6a 07                	push   $0x7
  801d43:	68 00 60 80 00       	push   $0x806000
  801d48:	53                   	push   %ebx
  801d49:	ff 35 b0 40 80 00    	pushl  0x8040b0
  801d4f:	e8 67 07 00 00       	call   8024bb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d54:	83 c4 0c             	add    $0xc,%esp
  801d57:	6a 00                	push   $0x0
  801d59:	6a 00                	push   $0x0
  801d5b:	6a 00                	push   $0x0
  801d5d:	e8 f0 06 00 00       	call   802452 <ipc_recv>
}
  801d62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d65:	c9                   	leave  
  801d66:	c3                   	ret    

00801d67 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	56                   	push   %esi
  801d6b:	53                   	push   %ebx
  801d6c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d77:	8b 06                	mov    (%esi),%eax
  801d79:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d83:	e8 95 ff ff ff       	call   801d1d <nsipc>
  801d88:	89 c3                	mov    %eax,%ebx
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	78 20                	js     801dae <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d8e:	83 ec 04             	sub    $0x4,%esp
  801d91:	ff 35 10 60 80 00    	pushl  0x806010
  801d97:	68 00 60 80 00       	push   $0x806000
  801d9c:	ff 75 0c             	pushl  0xc(%ebp)
  801d9f:	e8 3d f0 ff ff       	call   800de1 <memmove>
		*addrlen = ret->ret_addrlen;
  801da4:	a1 10 60 80 00       	mov    0x806010,%eax
  801da9:	89 06                	mov    %eax,(%esi)
  801dab:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801dae:	89 d8                	mov    %ebx,%eax
  801db0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5e                   	pop    %esi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	53                   	push   %ebx
  801dbb:	83 ec 08             	sub    $0x8,%esp
  801dbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801dc9:	53                   	push   %ebx
  801dca:	ff 75 0c             	pushl  0xc(%ebp)
  801dcd:	68 04 60 80 00       	push   $0x806004
  801dd2:	e8 0a f0 ff ff       	call   800de1 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dd7:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ddd:	b8 02 00 00 00       	mov    $0x2,%eax
  801de2:	e8 36 ff ff ff       	call   801d1d <nsipc>
}
  801de7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
  801df5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e02:	b8 03 00 00 00       	mov    $0x3,%eax
  801e07:	e8 11 ff ff ff       	call   801d1d <nsipc>
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <nsipc_close>:

int
nsipc_close(int s)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e1c:	b8 04 00 00 00       	mov    $0x4,%eax
  801e21:	e8 f7 fe ff ff       	call   801d1d <nsipc>
}
  801e26:	c9                   	leave  
  801e27:	c3                   	ret    

00801e28 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	53                   	push   %ebx
  801e2c:	83 ec 08             	sub    $0x8,%esp
  801e2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e32:	8b 45 08             	mov    0x8(%ebp),%eax
  801e35:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e3a:	53                   	push   %ebx
  801e3b:	ff 75 0c             	pushl  0xc(%ebp)
  801e3e:	68 04 60 80 00       	push   $0x806004
  801e43:	e8 99 ef ff ff       	call   800de1 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e48:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e4e:	b8 05 00 00 00       	mov    $0x5,%eax
  801e53:	e8 c5 fe ff ff       	call   801d1d <nsipc>
}
  801e58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e63:	8b 45 08             	mov    0x8(%ebp),%eax
  801e66:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e73:	b8 06 00 00 00       	mov    $0x6,%eax
  801e78:	e8 a0 fe ff ff       	call   801d1d <nsipc>
}
  801e7d:	c9                   	leave  
  801e7e:	c3                   	ret    

00801e7f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e87:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e8f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e95:	8b 45 14             	mov    0x14(%ebp),%eax
  801e98:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e9d:	b8 07 00 00 00       	mov    $0x7,%eax
  801ea2:	e8 76 fe ff ff       	call   801d1d <nsipc>
  801ea7:	89 c3                	mov    %eax,%ebx
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 35                	js     801ee2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801ead:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801eb2:	7f 04                	jg     801eb8 <nsipc_recv+0x39>
  801eb4:	39 c6                	cmp    %eax,%esi
  801eb6:	7d 16                	jge    801ece <nsipc_recv+0x4f>
  801eb8:	68 6b 2d 80 00       	push   $0x802d6b
  801ebd:	68 2c 2d 80 00       	push   $0x802d2c
  801ec2:	6a 62                	push   $0x62
  801ec4:	68 80 2d 80 00       	push   $0x802d80
  801ec9:	e8 23 e7 ff ff       	call   8005f1 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ece:	83 ec 04             	sub    $0x4,%esp
  801ed1:	50                   	push   %eax
  801ed2:	68 00 60 80 00       	push   $0x806000
  801ed7:	ff 75 0c             	pushl  0xc(%ebp)
  801eda:	e8 02 ef ff ff       	call   800de1 <memmove>
  801edf:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ee2:	89 d8                	mov    %ebx,%eax
  801ee4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    

00801eeb <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	53                   	push   %ebx
  801eef:	83 ec 04             	sub    $0x4,%esp
  801ef2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801efd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f03:	7e 16                	jle    801f1b <nsipc_send+0x30>
  801f05:	68 8c 2d 80 00       	push   $0x802d8c
  801f0a:	68 2c 2d 80 00       	push   $0x802d2c
  801f0f:	6a 6d                	push   $0x6d
  801f11:	68 80 2d 80 00       	push   $0x802d80
  801f16:	e8 d6 e6 ff ff       	call   8005f1 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f1b:	83 ec 04             	sub    $0x4,%esp
  801f1e:	53                   	push   %ebx
  801f1f:	ff 75 0c             	pushl  0xc(%ebp)
  801f22:	68 0c 60 80 00       	push   $0x80600c
  801f27:	e8 b5 ee ff ff       	call   800de1 <memmove>
	nsipcbuf.send.req_size = size;
  801f2c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f32:	8b 45 14             	mov    0x14(%ebp),%eax
  801f35:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f3a:	b8 08 00 00 00       	mov    $0x8,%eax
  801f3f:	e8 d9 fd ff ff       	call   801d1d <nsipc>
}
  801f44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f52:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f5f:	8b 45 10             	mov    0x10(%ebp),%eax
  801f62:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f67:	b8 09 00 00 00       	mov    $0x9,%eax
  801f6c:	e8 ac fd ff ff       	call   801d1d <nsipc>
}
  801f71:	c9                   	leave  
  801f72:	c3                   	ret    

00801f73 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f7b:	83 ec 0c             	sub    $0xc,%esp
  801f7e:	ff 75 08             	pushl  0x8(%ebp)
  801f81:	e8 62 f3 ff ff       	call   8012e8 <fd2data>
  801f86:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f88:	83 c4 08             	add    $0x8,%esp
  801f8b:	68 98 2d 80 00       	push   $0x802d98
  801f90:	53                   	push   %ebx
  801f91:	e8 b9 ec ff ff       	call   800c4f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f96:	8b 46 04             	mov    0x4(%esi),%eax
  801f99:	2b 06                	sub    (%esi),%eax
  801f9b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fa1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fa8:	00 00 00 
	stat->st_dev = &devpipe;
  801fab:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801fb2:	30 80 00 
	return 0;
}
  801fb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801fba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fbd:	5b                   	pop    %ebx
  801fbe:	5e                   	pop    %esi
  801fbf:	5d                   	pop    %ebp
  801fc0:	c3                   	ret    

00801fc1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	53                   	push   %ebx
  801fc5:	83 ec 0c             	sub    $0xc,%esp
  801fc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fcb:	53                   	push   %ebx
  801fcc:	6a 00                	push   $0x0
  801fce:	e8 04 f1 ff ff       	call   8010d7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fd3:	89 1c 24             	mov    %ebx,(%esp)
  801fd6:	e8 0d f3 ff ff       	call   8012e8 <fd2data>
  801fdb:	83 c4 08             	add    $0x8,%esp
  801fde:	50                   	push   %eax
  801fdf:	6a 00                	push   $0x0
  801fe1:	e8 f1 f0 ff ff       	call   8010d7 <sys_page_unmap>
}
  801fe6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe9:	c9                   	leave  
  801fea:	c3                   	ret    

00801feb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	57                   	push   %edi
  801fef:	56                   	push   %esi
  801ff0:	53                   	push   %ebx
  801ff1:	83 ec 1c             	sub    $0x1c,%esp
  801ff4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ff7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ff9:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801ffe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  802001:	83 ec 0c             	sub    $0xc,%esp
  802004:	ff 75 e0             	pushl  -0x20(%ebp)
  802007:	e8 3c 05 00 00       	call   802548 <pageref>
  80200c:	89 c3                	mov    %eax,%ebx
  80200e:	89 3c 24             	mov    %edi,(%esp)
  802011:	e8 32 05 00 00       	call   802548 <pageref>
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	39 c3                	cmp    %eax,%ebx
  80201b:	0f 94 c1             	sete   %cl
  80201e:	0f b6 c9             	movzbl %cl,%ecx
  802021:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802024:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  80202a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80202d:	39 ce                	cmp    %ecx,%esi
  80202f:	74 1b                	je     80204c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802031:	39 c3                	cmp    %eax,%ebx
  802033:	75 c4                	jne    801ff9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802035:	8b 42 58             	mov    0x58(%edx),%eax
  802038:	ff 75 e4             	pushl  -0x1c(%ebp)
  80203b:	50                   	push   %eax
  80203c:	56                   	push   %esi
  80203d:	68 9f 2d 80 00       	push   $0x802d9f
  802042:	e8 83 e6 ff ff       	call   8006ca <cprintf>
  802047:	83 c4 10             	add    $0x10,%esp
  80204a:	eb ad                	jmp    801ff9 <_pipeisclosed+0xe>
	}
}
  80204c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80204f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802052:	5b                   	pop    %ebx
  802053:	5e                   	pop    %esi
  802054:	5f                   	pop    %edi
  802055:	5d                   	pop    %ebp
  802056:	c3                   	ret    

00802057 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802057:	55                   	push   %ebp
  802058:	89 e5                	mov    %esp,%ebp
  80205a:	57                   	push   %edi
  80205b:	56                   	push   %esi
  80205c:	53                   	push   %ebx
  80205d:	83 ec 28             	sub    $0x28,%esp
  802060:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802063:	56                   	push   %esi
  802064:	e8 7f f2 ff ff       	call   8012e8 <fd2data>
  802069:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80206b:	83 c4 10             	add    $0x10,%esp
  80206e:	bf 00 00 00 00       	mov    $0x0,%edi
  802073:	eb 4b                	jmp    8020c0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802075:	89 da                	mov    %ebx,%edx
  802077:	89 f0                	mov    %esi,%eax
  802079:	e8 6d ff ff ff       	call   801feb <_pipeisclosed>
  80207e:	85 c0                	test   %eax,%eax
  802080:	75 48                	jne    8020ca <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802082:	e8 ac ef ff ff       	call   801033 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802087:	8b 43 04             	mov    0x4(%ebx),%eax
  80208a:	8b 0b                	mov    (%ebx),%ecx
  80208c:	8d 51 20             	lea    0x20(%ecx),%edx
  80208f:	39 d0                	cmp    %edx,%eax
  802091:	73 e2                	jae    802075 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802093:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802096:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80209a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80209d:	89 c2                	mov    %eax,%edx
  80209f:	c1 fa 1f             	sar    $0x1f,%edx
  8020a2:	89 d1                	mov    %edx,%ecx
  8020a4:	c1 e9 1b             	shr    $0x1b,%ecx
  8020a7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020aa:	83 e2 1f             	and    $0x1f,%edx
  8020ad:	29 ca                	sub    %ecx,%edx
  8020af:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020b7:	83 c0 01             	add    $0x1,%eax
  8020ba:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020bd:	83 c7 01             	add    $0x1,%edi
  8020c0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020c3:	75 c2                	jne    802087 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c8:	eb 05                	jmp    8020cf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020ca:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d2:	5b                   	pop    %ebx
  8020d3:	5e                   	pop    %esi
  8020d4:	5f                   	pop    %edi
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    

008020d7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	57                   	push   %edi
  8020db:	56                   	push   %esi
  8020dc:	53                   	push   %ebx
  8020dd:	83 ec 18             	sub    $0x18,%esp
  8020e0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020e3:	57                   	push   %edi
  8020e4:	e8 ff f1 ff ff       	call   8012e8 <fd2data>
  8020e9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020eb:	83 c4 10             	add    $0x10,%esp
  8020ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020f3:	eb 3d                	jmp    802132 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020f5:	85 db                	test   %ebx,%ebx
  8020f7:	74 04                	je     8020fd <devpipe_read+0x26>
				return i;
  8020f9:	89 d8                	mov    %ebx,%eax
  8020fb:	eb 44                	jmp    802141 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020fd:	89 f2                	mov    %esi,%edx
  8020ff:	89 f8                	mov    %edi,%eax
  802101:	e8 e5 fe ff ff       	call   801feb <_pipeisclosed>
  802106:	85 c0                	test   %eax,%eax
  802108:	75 32                	jne    80213c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80210a:	e8 24 ef ff ff       	call   801033 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80210f:	8b 06                	mov    (%esi),%eax
  802111:	3b 46 04             	cmp    0x4(%esi),%eax
  802114:	74 df                	je     8020f5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802116:	99                   	cltd   
  802117:	c1 ea 1b             	shr    $0x1b,%edx
  80211a:	01 d0                	add    %edx,%eax
  80211c:	83 e0 1f             	and    $0x1f,%eax
  80211f:	29 d0                	sub    %edx,%eax
  802121:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802126:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802129:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80212c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80212f:	83 c3 01             	add    $0x1,%ebx
  802132:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802135:	75 d8                	jne    80210f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802137:	8b 45 10             	mov    0x10(%ebp),%eax
  80213a:	eb 05                	jmp    802141 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80213c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802141:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    

00802149 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	56                   	push   %esi
  80214d:	53                   	push   %ebx
  80214e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802151:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802154:	50                   	push   %eax
  802155:	e8 a5 f1 ff ff       	call   8012ff <fd_alloc>
  80215a:	83 c4 10             	add    $0x10,%esp
  80215d:	89 c2                	mov    %eax,%edx
  80215f:	85 c0                	test   %eax,%eax
  802161:	0f 88 2c 01 00 00    	js     802293 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802167:	83 ec 04             	sub    $0x4,%esp
  80216a:	68 07 04 00 00       	push   $0x407
  80216f:	ff 75 f4             	pushl  -0xc(%ebp)
  802172:	6a 00                	push   $0x0
  802174:	e8 d9 ee ff ff       	call   801052 <sys_page_alloc>
  802179:	83 c4 10             	add    $0x10,%esp
  80217c:	89 c2                	mov    %eax,%edx
  80217e:	85 c0                	test   %eax,%eax
  802180:	0f 88 0d 01 00 00    	js     802293 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802186:	83 ec 0c             	sub    $0xc,%esp
  802189:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80218c:	50                   	push   %eax
  80218d:	e8 6d f1 ff ff       	call   8012ff <fd_alloc>
  802192:	89 c3                	mov    %eax,%ebx
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	85 c0                	test   %eax,%eax
  802199:	0f 88 e2 00 00 00    	js     802281 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80219f:	83 ec 04             	sub    $0x4,%esp
  8021a2:	68 07 04 00 00       	push   $0x407
  8021a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8021aa:	6a 00                	push   $0x0
  8021ac:	e8 a1 ee ff ff       	call   801052 <sys_page_alloc>
  8021b1:	89 c3                	mov    %eax,%ebx
  8021b3:	83 c4 10             	add    $0x10,%esp
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	0f 88 c3 00 00 00    	js     802281 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021be:	83 ec 0c             	sub    $0xc,%esp
  8021c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8021c4:	e8 1f f1 ff ff       	call   8012e8 <fd2data>
  8021c9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021cb:	83 c4 0c             	add    $0xc,%esp
  8021ce:	68 07 04 00 00       	push   $0x407
  8021d3:	50                   	push   %eax
  8021d4:	6a 00                	push   $0x0
  8021d6:	e8 77 ee ff ff       	call   801052 <sys_page_alloc>
  8021db:	89 c3                	mov    %eax,%ebx
  8021dd:	83 c4 10             	add    $0x10,%esp
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	0f 88 89 00 00 00    	js     802271 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e8:	83 ec 0c             	sub    $0xc,%esp
  8021eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ee:	e8 f5 f0 ff ff       	call   8012e8 <fd2data>
  8021f3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021fa:	50                   	push   %eax
  8021fb:	6a 00                	push   $0x0
  8021fd:	56                   	push   %esi
  8021fe:	6a 00                	push   $0x0
  802200:	e8 90 ee ff ff       	call   801095 <sys_page_map>
  802205:	89 c3                	mov    %eax,%ebx
  802207:	83 c4 20             	add    $0x20,%esp
  80220a:	85 c0                	test   %eax,%eax
  80220c:	78 55                	js     802263 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80220e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802214:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802217:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802223:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802229:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80222c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80222e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802231:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802238:	83 ec 0c             	sub    $0xc,%esp
  80223b:	ff 75 f4             	pushl  -0xc(%ebp)
  80223e:	e8 95 f0 ff ff       	call   8012d8 <fd2num>
  802243:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802246:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802248:	83 c4 04             	add    $0x4,%esp
  80224b:	ff 75 f0             	pushl  -0x10(%ebp)
  80224e:	e8 85 f0 ff ff       	call   8012d8 <fd2num>
  802253:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802256:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802259:	83 c4 10             	add    $0x10,%esp
  80225c:	ba 00 00 00 00       	mov    $0x0,%edx
  802261:	eb 30                	jmp    802293 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802263:	83 ec 08             	sub    $0x8,%esp
  802266:	56                   	push   %esi
  802267:	6a 00                	push   $0x0
  802269:	e8 69 ee ff ff       	call   8010d7 <sys_page_unmap>
  80226e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802271:	83 ec 08             	sub    $0x8,%esp
  802274:	ff 75 f0             	pushl  -0x10(%ebp)
  802277:	6a 00                	push   $0x0
  802279:	e8 59 ee ff ff       	call   8010d7 <sys_page_unmap>
  80227e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802281:	83 ec 08             	sub    $0x8,%esp
  802284:	ff 75 f4             	pushl  -0xc(%ebp)
  802287:	6a 00                	push   $0x0
  802289:	e8 49 ee ff ff       	call   8010d7 <sys_page_unmap>
  80228e:	83 c4 10             	add    $0x10,%esp
  802291:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802293:	89 d0                	mov    %edx,%eax
  802295:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    

0080229c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a5:	50                   	push   %eax
  8022a6:	ff 75 08             	pushl  0x8(%ebp)
  8022a9:	e8 a0 f0 ff ff       	call   80134e <fd_lookup>
  8022ae:	83 c4 10             	add    $0x10,%esp
  8022b1:	85 c0                	test   %eax,%eax
  8022b3:	78 18                	js     8022cd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022b5:	83 ec 0c             	sub    $0xc,%esp
  8022b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8022bb:	e8 28 f0 ff ff       	call   8012e8 <fd2data>
	return _pipeisclosed(fd, p);
  8022c0:	89 c2                	mov    %eax,%edx
  8022c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c5:	e8 21 fd ff ff       	call   801feb <_pipeisclosed>
  8022ca:	83 c4 10             	add    $0x10,%esp
}
  8022cd:	c9                   	leave  
  8022ce:	c3                   	ret    

008022cf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022cf:	55                   	push   %ebp
  8022d0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    

008022d9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022df:	68 b7 2d 80 00       	push   $0x802db7
  8022e4:	ff 75 0c             	pushl  0xc(%ebp)
  8022e7:	e8 63 e9 ff ff       	call   800c4f <strcpy>
	return 0;
}
  8022ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8022f1:	c9                   	leave  
  8022f2:	c3                   	ret    

008022f3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022f3:	55                   	push   %ebp
  8022f4:	89 e5                	mov    %esp,%ebp
  8022f6:	57                   	push   %edi
  8022f7:	56                   	push   %esi
  8022f8:	53                   	push   %ebx
  8022f9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022ff:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802304:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80230a:	eb 2d                	jmp    802339 <devcons_write+0x46>
		m = n - tot;
  80230c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80230f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802311:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802314:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802319:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80231c:	83 ec 04             	sub    $0x4,%esp
  80231f:	53                   	push   %ebx
  802320:	03 45 0c             	add    0xc(%ebp),%eax
  802323:	50                   	push   %eax
  802324:	57                   	push   %edi
  802325:	e8 b7 ea ff ff       	call   800de1 <memmove>
		sys_cputs(buf, m);
  80232a:	83 c4 08             	add    $0x8,%esp
  80232d:	53                   	push   %ebx
  80232e:	57                   	push   %edi
  80232f:	e8 62 ec ff ff       	call   800f96 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802334:	01 de                	add    %ebx,%esi
  802336:	83 c4 10             	add    $0x10,%esp
  802339:	89 f0                	mov    %esi,%eax
  80233b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80233e:	72 cc                	jb     80230c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802340:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    

00802348 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802348:	55                   	push   %ebp
  802349:	89 e5                	mov    %esp,%ebp
  80234b:	83 ec 08             	sub    $0x8,%esp
  80234e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802353:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802357:	74 2a                	je     802383 <devcons_read+0x3b>
  802359:	eb 05                	jmp    802360 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80235b:	e8 d3 ec ff ff       	call   801033 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802360:	e8 4f ec ff ff       	call   800fb4 <sys_cgetc>
  802365:	85 c0                	test   %eax,%eax
  802367:	74 f2                	je     80235b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802369:	85 c0                	test   %eax,%eax
  80236b:	78 16                	js     802383 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80236d:	83 f8 04             	cmp    $0x4,%eax
  802370:	74 0c                	je     80237e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802372:	8b 55 0c             	mov    0xc(%ebp),%edx
  802375:	88 02                	mov    %al,(%edx)
	return 1;
  802377:	b8 01 00 00 00       	mov    $0x1,%eax
  80237c:	eb 05                	jmp    802383 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80237e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802383:	c9                   	leave  
  802384:	c3                   	ret    

00802385 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802385:	55                   	push   %ebp
  802386:	89 e5                	mov    %esp,%ebp
  802388:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80238b:	8b 45 08             	mov    0x8(%ebp),%eax
  80238e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802391:	6a 01                	push   $0x1
  802393:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802396:	50                   	push   %eax
  802397:	e8 fa eb ff ff       	call   800f96 <sys_cputs>
}
  80239c:	83 c4 10             	add    $0x10,%esp
  80239f:	c9                   	leave  
  8023a0:	c3                   	ret    

008023a1 <getchar>:

int
getchar(void)
{
  8023a1:	55                   	push   %ebp
  8023a2:	89 e5                	mov    %esp,%ebp
  8023a4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8023a7:	6a 01                	push   $0x1
  8023a9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023ac:	50                   	push   %eax
  8023ad:	6a 00                	push   $0x0
  8023af:	e8 00 f2 ff ff       	call   8015b4 <read>
	if (r < 0)
  8023b4:	83 c4 10             	add    $0x10,%esp
  8023b7:	85 c0                	test   %eax,%eax
  8023b9:	78 0f                	js     8023ca <getchar+0x29>
		return r;
	if (r < 1)
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	7e 06                	jle    8023c5 <getchar+0x24>
		return -E_EOF;
	return c;
  8023bf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023c3:	eb 05                	jmp    8023ca <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023c5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023ca:	c9                   	leave  
  8023cb:	c3                   	ret    

008023cc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d5:	50                   	push   %eax
  8023d6:	ff 75 08             	pushl  0x8(%ebp)
  8023d9:	e8 70 ef ff ff       	call   80134e <fd_lookup>
  8023de:	83 c4 10             	add    $0x10,%esp
  8023e1:	85 c0                	test   %eax,%eax
  8023e3:	78 11                	js     8023f6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023ee:	39 10                	cmp    %edx,(%eax)
  8023f0:	0f 94 c0             	sete   %al
  8023f3:	0f b6 c0             	movzbl %al,%eax
}
  8023f6:	c9                   	leave  
  8023f7:	c3                   	ret    

008023f8 <opencons>:

int
opencons(void)
{
  8023f8:	55                   	push   %ebp
  8023f9:	89 e5                	mov    %esp,%ebp
  8023fb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802401:	50                   	push   %eax
  802402:	e8 f8 ee ff ff       	call   8012ff <fd_alloc>
  802407:	83 c4 10             	add    $0x10,%esp
		return r;
  80240a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80240c:	85 c0                	test   %eax,%eax
  80240e:	78 3e                	js     80244e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802410:	83 ec 04             	sub    $0x4,%esp
  802413:	68 07 04 00 00       	push   $0x407
  802418:	ff 75 f4             	pushl  -0xc(%ebp)
  80241b:	6a 00                	push   $0x0
  80241d:	e8 30 ec ff ff       	call   801052 <sys_page_alloc>
  802422:	83 c4 10             	add    $0x10,%esp
		return r;
  802425:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802427:	85 c0                	test   %eax,%eax
  802429:	78 23                	js     80244e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80242b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802431:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802434:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802439:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802440:	83 ec 0c             	sub    $0xc,%esp
  802443:	50                   	push   %eax
  802444:	e8 8f ee ff ff       	call   8012d8 <fd2num>
  802449:	89 c2                	mov    %eax,%edx
  80244b:	83 c4 10             	add    $0x10,%esp
}
  80244e:	89 d0                	mov    %edx,%eax
  802450:	c9                   	leave  
  802451:	c3                   	ret    

00802452 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802452:	55                   	push   %ebp
  802453:	89 e5                	mov    %esp,%ebp
  802455:	56                   	push   %esi
  802456:	53                   	push   %ebx
  802457:	8b 75 08             	mov    0x8(%ebp),%esi
  80245a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80245d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  802460:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  802462:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  802467:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  80246a:	83 ec 0c             	sub    $0xc,%esp
  80246d:	50                   	push   %eax
  80246e:	e8 8f ed ff ff       	call   801202 <sys_ipc_recv>

	if (r < 0) {
  802473:	83 c4 10             	add    $0x10,%esp
  802476:	85 c0                	test   %eax,%eax
  802478:	79 16                	jns    802490 <ipc_recv+0x3e>
		if (from_env_store)
  80247a:	85 f6                	test   %esi,%esi
  80247c:	74 06                	je     802484 <ipc_recv+0x32>
			*from_env_store = 0;
  80247e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  802484:	85 db                	test   %ebx,%ebx
  802486:	74 2c                	je     8024b4 <ipc_recv+0x62>
			*perm_store = 0;
  802488:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80248e:	eb 24                	jmp    8024b4 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  802490:	85 f6                	test   %esi,%esi
  802492:	74 0a                	je     80249e <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  802494:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802499:	8b 40 74             	mov    0x74(%eax),%eax
  80249c:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  80249e:	85 db                	test   %ebx,%ebx
  8024a0:	74 0a                	je     8024ac <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8024a2:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8024a7:	8b 40 78             	mov    0x78(%eax),%eax
  8024aa:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8024ac:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8024b1:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8024b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b7:	5b                   	pop    %ebx
  8024b8:	5e                   	pop    %esi
  8024b9:	5d                   	pop    %ebp
  8024ba:	c3                   	ret    

008024bb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024bb:	55                   	push   %ebp
  8024bc:	89 e5                	mov    %esp,%ebp
  8024be:	57                   	push   %edi
  8024bf:	56                   	push   %esi
  8024c0:	53                   	push   %ebx
  8024c1:	83 ec 0c             	sub    $0xc,%esp
  8024c4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  8024cd:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8024cf:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  8024d4:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  8024d7:	ff 75 14             	pushl  0x14(%ebp)
  8024da:	53                   	push   %ebx
  8024db:	56                   	push   %esi
  8024dc:	57                   	push   %edi
  8024dd:	e8 fd ec ff ff       	call   8011df <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  8024e2:	83 c4 10             	add    $0x10,%esp
  8024e5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024e8:	75 07                	jne    8024f1 <ipc_send+0x36>
			sys_yield();
  8024ea:	e8 44 eb ff ff       	call   801033 <sys_yield>
  8024ef:	eb e6                	jmp    8024d7 <ipc_send+0x1c>
		} else if (r < 0) {
  8024f1:	85 c0                	test   %eax,%eax
  8024f3:	79 12                	jns    802507 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  8024f5:	50                   	push   %eax
  8024f6:	68 c3 2d 80 00       	push   $0x802dc3
  8024fb:	6a 51                	push   $0x51
  8024fd:	68 d0 2d 80 00       	push   $0x802dd0
  802502:	e8 ea e0 ff ff       	call   8005f1 <_panic>
		}
	}
}
  802507:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80250a:	5b                   	pop    %ebx
  80250b:	5e                   	pop    %esi
  80250c:	5f                   	pop    %edi
  80250d:	5d                   	pop    %ebp
  80250e:	c3                   	ret    

0080250f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80250f:	55                   	push   %ebp
  802510:	89 e5                	mov    %esp,%ebp
  802512:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802515:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80251a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80251d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802523:	8b 52 50             	mov    0x50(%edx),%edx
  802526:	39 ca                	cmp    %ecx,%edx
  802528:	75 0d                	jne    802537 <ipc_find_env+0x28>
			return envs[i].env_id;
  80252a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80252d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802532:	8b 40 48             	mov    0x48(%eax),%eax
  802535:	eb 0f                	jmp    802546 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802537:	83 c0 01             	add    $0x1,%eax
  80253a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80253f:	75 d9                	jne    80251a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802541:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802546:	5d                   	pop    %ebp
  802547:	c3                   	ret    

00802548 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802548:	55                   	push   %ebp
  802549:	89 e5                	mov    %esp,%ebp
  80254b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80254e:	89 d0                	mov    %edx,%eax
  802550:	c1 e8 16             	shr    $0x16,%eax
  802553:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80255a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80255f:	f6 c1 01             	test   $0x1,%cl
  802562:	74 1d                	je     802581 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802564:	c1 ea 0c             	shr    $0xc,%edx
  802567:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80256e:	f6 c2 01             	test   $0x1,%dl
  802571:	74 0e                	je     802581 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802573:	c1 ea 0c             	shr    $0xc,%edx
  802576:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80257d:	ef 
  80257e:	0f b7 c0             	movzwl %ax,%eax
}
  802581:	5d                   	pop    %ebp
  802582:	c3                   	ret    
  802583:	66 90                	xchg   %ax,%ax
  802585:	66 90                	xchg   %ax,%ax
  802587:	66 90                	xchg   %ax,%ax
  802589:	66 90                	xchg   %ax,%ax
  80258b:	66 90                	xchg   %ax,%ax
  80258d:	66 90                	xchg   %ax,%ax
  80258f:	90                   	nop

00802590 <__udivdi3>:
  802590:	55                   	push   %ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	83 ec 1c             	sub    $0x1c,%esp
  802597:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80259b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80259f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8025a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025a7:	85 f6                	test   %esi,%esi
  8025a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025ad:	89 ca                	mov    %ecx,%edx
  8025af:	89 f8                	mov    %edi,%eax
  8025b1:	75 3d                	jne    8025f0 <__udivdi3+0x60>
  8025b3:	39 cf                	cmp    %ecx,%edi
  8025b5:	0f 87 c5 00 00 00    	ja     802680 <__udivdi3+0xf0>
  8025bb:	85 ff                	test   %edi,%edi
  8025bd:	89 fd                	mov    %edi,%ebp
  8025bf:	75 0b                	jne    8025cc <__udivdi3+0x3c>
  8025c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c6:	31 d2                	xor    %edx,%edx
  8025c8:	f7 f7                	div    %edi
  8025ca:	89 c5                	mov    %eax,%ebp
  8025cc:	89 c8                	mov    %ecx,%eax
  8025ce:	31 d2                	xor    %edx,%edx
  8025d0:	f7 f5                	div    %ebp
  8025d2:	89 c1                	mov    %eax,%ecx
  8025d4:	89 d8                	mov    %ebx,%eax
  8025d6:	89 cf                	mov    %ecx,%edi
  8025d8:	f7 f5                	div    %ebp
  8025da:	89 c3                	mov    %eax,%ebx
  8025dc:	89 d8                	mov    %ebx,%eax
  8025de:	89 fa                	mov    %edi,%edx
  8025e0:	83 c4 1c             	add    $0x1c,%esp
  8025e3:	5b                   	pop    %ebx
  8025e4:	5e                   	pop    %esi
  8025e5:	5f                   	pop    %edi
  8025e6:	5d                   	pop    %ebp
  8025e7:	c3                   	ret    
  8025e8:	90                   	nop
  8025e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025f0:	39 ce                	cmp    %ecx,%esi
  8025f2:	77 74                	ja     802668 <__udivdi3+0xd8>
  8025f4:	0f bd fe             	bsr    %esi,%edi
  8025f7:	83 f7 1f             	xor    $0x1f,%edi
  8025fa:	0f 84 98 00 00 00    	je     802698 <__udivdi3+0x108>
  802600:	bb 20 00 00 00       	mov    $0x20,%ebx
  802605:	89 f9                	mov    %edi,%ecx
  802607:	89 c5                	mov    %eax,%ebp
  802609:	29 fb                	sub    %edi,%ebx
  80260b:	d3 e6                	shl    %cl,%esi
  80260d:	89 d9                	mov    %ebx,%ecx
  80260f:	d3 ed                	shr    %cl,%ebp
  802611:	89 f9                	mov    %edi,%ecx
  802613:	d3 e0                	shl    %cl,%eax
  802615:	09 ee                	or     %ebp,%esi
  802617:	89 d9                	mov    %ebx,%ecx
  802619:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80261d:	89 d5                	mov    %edx,%ebp
  80261f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802623:	d3 ed                	shr    %cl,%ebp
  802625:	89 f9                	mov    %edi,%ecx
  802627:	d3 e2                	shl    %cl,%edx
  802629:	89 d9                	mov    %ebx,%ecx
  80262b:	d3 e8                	shr    %cl,%eax
  80262d:	09 c2                	or     %eax,%edx
  80262f:	89 d0                	mov    %edx,%eax
  802631:	89 ea                	mov    %ebp,%edx
  802633:	f7 f6                	div    %esi
  802635:	89 d5                	mov    %edx,%ebp
  802637:	89 c3                	mov    %eax,%ebx
  802639:	f7 64 24 0c          	mull   0xc(%esp)
  80263d:	39 d5                	cmp    %edx,%ebp
  80263f:	72 10                	jb     802651 <__udivdi3+0xc1>
  802641:	8b 74 24 08          	mov    0x8(%esp),%esi
  802645:	89 f9                	mov    %edi,%ecx
  802647:	d3 e6                	shl    %cl,%esi
  802649:	39 c6                	cmp    %eax,%esi
  80264b:	73 07                	jae    802654 <__udivdi3+0xc4>
  80264d:	39 d5                	cmp    %edx,%ebp
  80264f:	75 03                	jne    802654 <__udivdi3+0xc4>
  802651:	83 eb 01             	sub    $0x1,%ebx
  802654:	31 ff                	xor    %edi,%edi
  802656:	89 d8                	mov    %ebx,%eax
  802658:	89 fa                	mov    %edi,%edx
  80265a:	83 c4 1c             	add    $0x1c,%esp
  80265d:	5b                   	pop    %ebx
  80265e:	5e                   	pop    %esi
  80265f:	5f                   	pop    %edi
  802660:	5d                   	pop    %ebp
  802661:	c3                   	ret    
  802662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802668:	31 ff                	xor    %edi,%edi
  80266a:	31 db                	xor    %ebx,%ebx
  80266c:	89 d8                	mov    %ebx,%eax
  80266e:	89 fa                	mov    %edi,%edx
  802670:	83 c4 1c             	add    $0x1c,%esp
  802673:	5b                   	pop    %ebx
  802674:	5e                   	pop    %esi
  802675:	5f                   	pop    %edi
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    
  802678:	90                   	nop
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	89 d8                	mov    %ebx,%eax
  802682:	f7 f7                	div    %edi
  802684:	31 ff                	xor    %edi,%edi
  802686:	89 c3                	mov    %eax,%ebx
  802688:	89 d8                	mov    %ebx,%eax
  80268a:	89 fa                	mov    %edi,%edx
  80268c:	83 c4 1c             	add    $0x1c,%esp
  80268f:	5b                   	pop    %ebx
  802690:	5e                   	pop    %esi
  802691:	5f                   	pop    %edi
  802692:	5d                   	pop    %ebp
  802693:	c3                   	ret    
  802694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802698:	39 ce                	cmp    %ecx,%esi
  80269a:	72 0c                	jb     8026a8 <__udivdi3+0x118>
  80269c:	31 db                	xor    %ebx,%ebx
  80269e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8026a2:	0f 87 34 ff ff ff    	ja     8025dc <__udivdi3+0x4c>
  8026a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8026ad:	e9 2a ff ff ff       	jmp    8025dc <__udivdi3+0x4c>
  8026b2:	66 90                	xchg   %ax,%ax
  8026b4:	66 90                	xchg   %ax,%ax
  8026b6:	66 90                	xchg   %ax,%ax
  8026b8:	66 90                	xchg   %ax,%ax
  8026ba:	66 90                	xchg   %ax,%ax
  8026bc:	66 90                	xchg   %ax,%ax
  8026be:	66 90                	xchg   %ax,%ax

008026c0 <__umoddi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	57                   	push   %edi
  8026c2:	56                   	push   %esi
  8026c3:	53                   	push   %ebx
  8026c4:	83 ec 1c             	sub    $0x1c,%esp
  8026c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026d7:	85 d2                	test   %edx,%edx
  8026d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026e1:	89 f3                	mov    %esi,%ebx
  8026e3:	89 3c 24             	mov    %edi,(%esp)
  8026e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ea:	75 1c                	jne    802708 <__umoddi3+0x48>
  8026ec:	39 f7                	cmp    %esi,%edi
  8026ee:	76 50                	jbe    802740 <__umoddi3+0x80>
  8026f0:	89 c8                	mov    %ecx,%eax
  8026f2:	89 f2                	mov    %esi,%edx
  8026f4:	f7 f7                	div    %edi
  8026f6:	89 d0                	mov    %edx,%eax
  8026f8:	31 d2                	xor    %edx,%edx
  8026fa:	83 c4 1c             	add    $0x1c,%esp
  8026fd:	5b                   	pop    %ebx
  8026fe:	5e                   	pop    %esi
  8026ff:	5f                   	pop    %edi
  802700:	5d                   	pop    %ebp
  802701:	c3                   	ret    
  802702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802708:	39 f2                	cmp    %esi,%edx
  80270a:	89 d0                	mov    %edx,%eax
  80270c:	77 52                	ja     802760 <__umoddi3+0xa0>
  80270e:	0f bd ea             	bsr    %edx,%ebp
  802711:	83 f5 1f             	xor    $0x1f,%ebp
  802714:	75 5a                	jne    802770 <__umoddi3+0xb0>
  802716:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80271a:	0f 82 e0 00 00 00    	jb     802800 <__umoddi3+0x140>
  802720:	39 0c 24             	cmp    %ecx,(%esp)
  802723:	0f 86 d7 00 00 00    	jbe    802800 <__umoddi3+0x140>
  802729:	8b 44 24 08          	mov    0x8(%esp),%eax
  80272d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802731:	83 c4 1c             	add    $0x1c,%esp
  802734:	5b                   	pop    %ebx
  802735:	5e                   	pop    %esi
  802736:	5f                   	pop    %edi
  802737:	5d                   	pop    %ebp
  802738:	c3                   	ret    
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	85 ff                	test   %edi,%edi
  802742:	89 fd                	mov    %edi,%ebp
  802744:	75 0b                	jne    802751 <__umoddi3+0x91>
  802746:	b8 01 00 00 00       	mov    $0x1,%eax
  80274b:	31 d2                	xor    %edx,%edx
  80274d:	f7 f7                	div    %edi
  80274f:	89 c5                	mov    %eax,%ebp
  802751:	89 f0                	mov    %esi,%eax
  802753:	31 d2                	xor    %edx,%edx
  802755:	f7 f5                	div    %ebp
  802757:	89 c8                	mov    %ecx,%eax
  802759:	f7 f5                	div    %ebp
  80275b:	89 d0                	mov    %edx,%eax
  80275d:	eb 99                	jmp    8026f8 <__umoddi3+0x38>
  80275f:	90                   	nop
  802760:	89 c8                	mov    %ecx,%eax
  802762:	89 f2                	mov    %esi,%edx
  802764:	83 c4 1c             	add    $0x1c,%esp
  802767:	5b                   	pop    %ebx
  802768:	5e                   	pop    %esi
  802769:	5f                   	pop    %edi
  80276a:	5d                   	pop    %ebp
  80276b:	c3                   	ret    
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	8b 34 24             	mov    (%esp),%esi
  802773:	bf 20 00 00 00       	mov    $0x20,%edi
  802778:	89 e9                	mov    %ebp,%ecx
  80277a:	29 ef                	sub    %ebp,%edi
  80277c:	d3 e0                	shl    %cl,%eax
  80277e:	89 f9                	mov    %edi,%ecx
  802780:	89 f2                	mov    %esi,%edx
  802782:	d3 ea                	shr    %cl,%edx
  802784:	89 e9                	mov    %ebp,%ecx
  802786:	09 c2                	or     %eax,%edx
  802788:	89 d8                	mov    %ebx,%eax
  80278a:	89 14 24             	mov    %edx,(%esp)
  80278d:	89 f2                	mov    %esi,%edx
  80278f:	d3 e2                	shl    %cl,%edx
  802791:	89 f9                	mov    %edi,%ecx
  802793:	89 54 24 04          	mov    %edx,0x4(%esp)
  802797:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80279b:	d3 e8                	shr    %cl,%eax
  80279d:	89 e9                	mov    %ebp,%ecx
  80279f:	89 c6                	mov    %eax,%esi
  8027a1:	d3 e3                	shl    %cl,%ebx
  8027a3:	89 f9                	mov    %edi,%ecx
  8027a5:	89 d0                	mov    %edx,%eax
  8027a7:	d3 e8                	shr    %cl,%eax
  8027a9:	89 e9                	mov    %ebp,%ecx
  8027ab:	09 d8                	or     %ebx,%eax
  8027ad:	89 d3                	mov    %edx,%ebx
  8027af:	89 f2                	mov    %esi,%edx
  8027b1:	f7 34 24             	divl   (%esp)
  8027b4:	89 d6                	mov    %edx,%esi
  8027b6:	d3 e3                	shl    %cl,%ebx
  8027b8:	f7 64 24 04          	mull   0x4(%esp)
  8027bc:	39 d6                	cmp    %edx,%esi
  8027be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027c2:	89 d1                	mov    %edx,%ecx
  8027c4:	89 c3                	mov    %eax,%ebx
  8027c6:	72 08                	jb     8027d0 <__umoddi3+0x110>
  8027c8:	75 11                	jne    8027db <__umoddi3+0x11b>
  8027ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027ce:	73 0b                	jae    8027db <__umoddi3+0x11b>
  8027d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027d4:	1b 14 24             	sbb    (%esp),%edx
  8027d7:	89 d1                	mov    %edx,%ecx
  8027d9:	89 c3                	mov    %eax,%ebx
  8027db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027df:	29 da                	sub    %ebx,%edx
  8027e1:	19 ce                	sbb    %ecx,%esi
  8027e3:	89 f9                	mov    %edi,%ecx
  8027e5:	89 f0                	mov    %esi,%eax
  8027e7:	d3 e0                	shl    %cl,%eax
  8027e9:	89 e9                	mov    %ebp,%ecx
  8027eb:	d3 ea                	shr    %cl,%edx
  8027ed:	89 e9                	mov    %ebp,%ecx
  8027ef:	d3 ee                	shr    %cl,%esi
  8027f1:	09 d0                	or     %edx,%eax
  8027f3:	89 f2                	mov    %esi,%edx
  8027f5:	83 c4 1c             	add    $0x1c,%esp
  8027f8:	5b                   	pop    %ebx
  8027f9:	5e                   	pop    %esi
  8027fa:	5f                   	pop    %edi
  8027fb:	5d                   	pop    %ebp
  8027fc:	c3                   	ret    
  8027fd:	8d 76 00             	lea    0x0(%esi),%esi
  802800:	29 f9                	sub    %edi,%ecx
  802802:	19 d6                	sbb    %edx,%esi
  802804:	89 74 24 04          	mov    %esi,0x4(%esp)
  802808:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80280c:	e9 18 ff ff ff       	jmp    802729 <__umoddi3+0x69>
