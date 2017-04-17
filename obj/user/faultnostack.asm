
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 80 03 80 00       	push   $0x800380
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 d7 04 00 00       	call   80057c <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 ea 22 80 00       	push   $0x8022ea
  80011e:	6a 23                	push   $0x23
  800120:	68 07 23 80 00       	push   $0x802307
  800125:	e8 01 14 00 00       	call   80152b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 ea 22 80 00       	push   $0x8022ea
  80019f:	6a 23                	push   $0x23
  8001a1:	68 07 23 80 00       	push   $0x802307
  8001a6:	e8 80 13 00 00       	call   80152b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 ea 22 80 00       	push   $0x8022ea
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 07 23 80 00       	push   $0x802307
  8001e8:	e8 3e 13 00 00       	call   80152b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 ea 22 80 00       	push   $0x8022ea
  800223:	6a 23                	push   $0x23
  800225:	68 07 23 80 00       	push   $0x802307
  80022a:	e8 fc 12 00 00       	call   80152b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 ea 22 80 00       	push   $0x8022ea
  800265:	6a 23                	push   $0x23
  800267:	68 07 23 80 00       	push   $0x802307
  80026c:	e8 ba 12 00 00       	call   80152b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 ea 22 80 00       	push   $0x8022ea
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 07 23 80 00       	push   $0x802307
  8002ae:	e8 78 12 00 00       	call   80152b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 ea 22 80 00       	push   $0x8022ea
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 07 23 80 00       	push   $0x802307
  8002f0:	e8 36 12 00 00       	call   80152b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 ea 22 80 00       	push   $0x8022ea
  80034d:	6a 23                	push   $0x23
  80034f:	68 07 23 80 00       	push   $0x802307
  800354:	e8 d2 11 00 00       	call   80152b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800367:	ba 00 00 00 00       	mov    $0x0,%edx
  80036c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800371:	89 d1                	mov    %edx,%ecx
  800373:	89 d3                	mov    %edx,%ebx
  800375:	89 d7                	mov    %edx,%edi
  800377:	89 d6                	mov    %edx,%esi
  800379:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800380:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800381:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  800386:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800388:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  80038b:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80038d:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  800390:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  800393:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  800396:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  800399:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80039c:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80039f:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  8003a2:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  8003a5:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  8003a8:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  8003ab:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  8003ae:	61                   	popa   
	popfl
  8003af:	9d                   	popf   
	ret
  8003b0:	c3                   	ret    

008003b1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8003bc:	c1 e8 0c             	shr    $0xc,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	05 00 00 00 30       	add    $0x30000000,%eax
  8003cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003d1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003de:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003e3:	89 c2                	mov    %eax,%edx
  8003e5:	c1 ea 16             	shr    $0x16,%edx
  8003e8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ef:	f6 c2 01             	test   $0x1,%dl
  8003f2:	74 11                	je     800405 <fd_alloc+0x2d>
  8003f4:	89 c2                	mov    %eax,%edx
  8003f6:	c1 ea 0c             	shr    $0xc,%edx
  8003f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800400:	f6 c2 01             	test   $0x1,%dl
  800403:	75 09                	jne    80040e <fd_alloc+0x36>
			*fd_store = fd;
  800405:	89 01                	mov    %eax,(%ecx)
			return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 17                	jmp    800425 <fd_alloc+0x4d>
  80040e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800413:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800418:	75 c9                	jne    8003e3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80041a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800420:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80042d:	83 f8 1f             	cmp    $0x1f,%eax
  800430:	77 36                	ja     800468 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800432:	c1 e0 0c             	shl    $0xc,%eax
  800435:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80043a:	89 c2                	mov    %eax,%edx
  80043c:	c1 ea 16             	shr    $0x16,%edx
  80043f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800446:	f6 c2 01             	test   $0x1,%dl
  800449:	74 24                	je     80046f <fd_lookup+0x48>
  80044b:	89 c2                	mov    %eax,%edx
  80044d:	c1 ea 0c             	shr    $0xc,%edx
  800450:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800457:	f6 c2 01             	test   $0x1,%dl
  80045a:	74 1a                	je     800476 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80045c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045f:	89 02                	mov    %eax,(%edx)
	return 0;
  800461:	b8 00 00 00 00       	mov    $0x0,%eax
  800466:	eb 13                	jmp    80047b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046d:	eb 0c                	jmp    80047b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800474:	eb 05                	jmp    80047b <fd_lookup+0x54>
  800476:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80047b:	5d                   	pop    %ebp
  80047c:	c3                   	ret    

0080047d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800486:	ba 94 23 80 00       	mov    $0x802394,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80048b:	eb 13                	jmp    8004a0 <dev_lookup+0x23>
  80048d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800490:	39 08                	cmp    %ecx,(%eax)
  800492:	75 0c                	jne    8004a0 <dev_lookup+0x23>
			*dev = devtab[i];
  800494:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800497:	89 01                	mov    %eax,(%ecx)
			return 0;
  800499:	b8 00 00 00 00       	mov    $0x0,%eax
  80049e:	eb 2e                	jmp    8004ce <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004a0:	8b 02                	mov    (%edx),%eax
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	75 e7                	jne    80048d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8004ab:	8b 40 48             	mov    0x48(%eax),%eax
  8004ae:	83 ec 04             	sub    $0x4,%esp
  8004b1:	51                   	push   %ecx
  8004b2:	50                   	push   %eax
  8004b3:	68 18 23 80 00       	push   $0x802318
  8004b8:	e8 47 11 00 00       	call   801604 <cprintf>
	*dev = 0;
  8004bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ce:	c9                   	leave  
  8004cf:	c3                   	ret    

008004d0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	56                   	push   %esi
  8004d4:	53                   	push   %ebx
  8004d5:	83 ec 10             	sub    $0x10,%esp
  8004d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e1:	50                   	push   %eax
  8004e2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004e8:	c1 e8 0c             	shr    $0xc,%eax
  8004eb:	50                   	push   %eax
  8004ec:	e8 36 ff ff ff       	call   800427 <fd_lookup>
  8004f1:	83 c4 08             	add    $0x8,%esp
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	78 05                	js     8004fd <fd_close+0x2d>
	    || fd != fd2)
  8004f8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004fb:	74 0c                	je     800509 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004fd:	84 db                	test   %bl,%bl
  8004ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800504:	0f 44 c2             	cmove  %edx,%eax
  800507:	eb 41                	jmp    80054a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	ff 36                	pushl  (%esi)
  800512:	e8 66 ff ff ff       	call   80047d <dev_lookup>
  800517:	89 c3                	mov    %eax,%ebx
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	85 c0                	test   %eax,%eax
  80051e:	78 1a                	js     80053a <fd_close+0x6a>
		if (dev->dev_close)
  800520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800523:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80052b:	85 c0                	test   %eax,%eax
  80052d:	74 0b                	je     80053a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80052f:	83 ec 0c             	sub    $0xc,%esp
  800532:	56                   	push   %esi
  800533:	ff d0                	call   *%eax
  800535:	89 c3                	mov    %eax,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	56                   	push   %esi
  80053e:	6a 00                	push   $0x0
  800540:	e8 b0 fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	89 d8                	mov    %ebx,%eax
}
  80054a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80054d:	5b                   	pop    %ebx
  80054e:	5e                   	pop    %esi
  80054f:	5d                   	pop    %ebp
  800550:	c3                   	ret    

00800551 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800557:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 c4 fe ff ff       	call   800427 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	78 10                	js     80057a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	6a 01                	push   $0x1
  80056f:	ff 75 f4             	pushl  -0xc(%ebp)
  800572:	e8 59 ff ff ff       	call   8004d0 <fd_close>
  800577:	83 c4 10             	add    $0x10,%esp
}
  80057a:	c9                   	leave  
  80057b:	c3                   	ret    

0080057c <close_all>:

void
close_all(void)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	53                   	push   %ebx
  800580:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800583:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800588:	83 ec 0c             	sub    $0xc,%esp
  80058b:	53                   	push   %ebx
  80058c:	e8 c0 ff ff ff       	call   800551 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800591:	83 c3 01             	add    $0x1,%ebx
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	83 fb 20             	cmp    $0x20,%ebx
  80059a:	75 ec                	jne    800588 <close_all+0xc>
		close(i);
}
  80059c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80059f:	c9                   	leave  
  8005a0:	c3                   	ret    

008005a1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a1:	55                   	push   %ebp
  8005a2:	89 e5                	mov    %esp,%ebp
  8005a4:	57                   	push   %edi
  8005a5:	56                   	push   %esi
  8005a6:	53                   	push   %ebx
  8005a7:	83 ec 2c             	sub    $0x2c,%esp
  8005aa:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b0:	50                   	push   %eax
  8005b1:	ff 75 08             	pushl  0x8(%ebp)
  8005b4:	e8 6e fe ff ff       	call   800427 <fd_lookup>
  8005b9:	83 c4 08             	add    $0x8,%esp
  8005bc:	85 c0                	test   %eax,%eax
  8005be:	0f 88 c1 00 00 00    	js     800685 <dup+0xe4>
		return r;
	close(newfdnum);
  8005c4:	83 ec 0c             	sub    $0xc,%esp
  8005c7:	56                   	push   %esi
  8005c8:	e8 84 ff ff ff       	call   800551 <close>

	newfd = INDEX2FD(newfdnum);
  8005cd:	89 f3                	mov    %esi,%ebx
  8005cf:	c1 e3 0c             	shl    $0xc,%ebx
  8005d2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005d8:	83 c4 04             	add    $0x4,%esp
  8005db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005de:	e8 de fd ff ff       	call   8003c1 <fd2data>
  8005e3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005e5:	89 1c 24             	mov    %ebx,(%esp)
  8005e8:	e8 d4 fd ff ff       	call   8003c1 <fd2data>
  8005ed:	83 c4 10             	add    $0x10,%esp
  8005f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005f3:	89 f8                	mov    %edi,%eax
  8005f5:	c1 e8 16             	shr    $0x16,%eax
  8005f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ff:	a8 01                	test   $0x1,%al
  800601:	74 37                	je     80063a <dup+0x99>
  800603:	89 f8                	mov    %edi,%eax
  800605:	c1 e8 0c             	shr    $0xc,%eax
  800608:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80060f:	f6 c2 01             	test   $0x1,%dl
  800612:	74 26                	je     80063a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800614:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061b:	83 ec 0c             	sub    $0xc,%esp
  80061e:	25 07 0e 00 00       	and    $0xe07,%eax
  800623:	50                   	push   %eax
  800624:	ff 75 d4             	pushl  -0x2c(%ebp)
  800627:	6a 00                	push   $0x0
  800629:	57                   	push   %edi
  80062a:	6a 00                	push   $0x0
  80062c:	e8 82 fb ff ff       	call   8001b3 <sys_page_map>
  800631:	89 c7                	mov    %eax,%edi
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	85 c0                	test   %eax,%eax
  800638:	78 2e                	js     800668 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80063d:	89 d0                	mov    %edx,%eax
  80063f:	c1 e8 0c             	shr    $0xc,%eax
  800642:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800649:	83 ec 0c             	sub    $0xc,%esp
  80064c:	25 07 0e 00 00       	and    $0xe07,%eax
  800651:	50                   	push   %eax
  800652:	53                   	push   %ebx
  800653:	6a 00                	push   $0x0
  800655:	52                   	push   %edx
  800656:	6a 00                	push   $0x0
  800658:	e8 56 fb ff ff       	call   8001b3 <sys_page_map>
  80065d:	89 c7                	mov    %eax,%edi
  80065f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800662:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800664:	85 ff                	test   %edi,%edi
  800666:	79 1d                	jns    800685 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 00                	push   $0x0
  80066e:	e8 82 fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800673:	83 c4 08             	add    $0x8,%esp
  800676:	ff 75 d4             	pushl  -0x2c(%ebp)
  800679:	6a 00                	push   $0x0
  80067b:	e8 75 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	89 f8                	mov    %edi,%eax
}
  800685:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800688:	5b                   	pop    %ebx
  800689:	5e                   	pop    %esi
  80068a:	5f                   	pop    %edi
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    

0080068d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	53                   	push   %ebx
  800691:	83 ec 14             	sub    $0x14,%esp
  800694:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800697:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80069a:	50                   	push   %eax
  80069b:	53                   	push   %ebx
  80069c:	e8 86 fd ff ff       	call   800427 <fd_lookup>
  8006a1:	83 c4 08             	add    $0x8,%esp
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	78 6d                	js     800717 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b0:	50                   	push   %eax
  8006b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b4:	ff 30                	pushl  (%eax)
  8006b6:	e8 c2 fd ff ff       	call   80047d <dev_lookup>
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	85 c0                	test   %eax,%eax
  8006c0:	78 4c                	js     80070e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006c5:	8b 42 08             	mov    0x8(%edx),%eax
  8006c8:	83 e0 03             	and    $0x3,%eax
  8006cb:	83 f8 01             	cmp    $0x1,%eax
  8006ce:	75 21                	jne    8006f1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006d0:	a1 08 40 80 00       	mov    0x804008,%eax
  8006d5:	8b 40 48             	mov    0x48(%eax),%eax
  8006d8:	83 ec 04             	sub    $0x4,%esp
  8006db:	53                   	push   %ebx
  8006dc:	50                   	push   %eax
  8006dd:	68 59 23 80 00       	push   $0x802359
  8006e2:	e8 1d 0f 00 00       	call   801604 <cprintf>
		return -E_INVAL;
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006ef:	eb 26                	jmp    800717 <read+0x8a>
	}
	if (!dev->dev_read)
  8006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f4:	8b 40 08             	mov    0x8(%eax),%eax
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	74 17                	je     800712 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006fb:	83 ec 04             	sub    $0x4,%esp
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	ff 75 0c             	pushl  0xc(%ebp)
  800704:	52                   	push   %edx
  800705:	ff d0                	call   *%eax
  800707:	89 c2                	mov    %eax,%edx
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	eb 09                	jmp    800717 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80070e:	89 c2                	mov    %eax,%edx
  800710:	eb 05                	jmp    800717 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800712:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800717:	89 d0                	mov    %edx,%eax
  800719:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	57                   	push   %edi
  800722:	56                   	push   %esi
  800723:	53                   	push   %ebx
  800724:	83 ec 0c             	sub    $0xc,%esp
  800727:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80072d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800732:	eb 21                	jmp    800755 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800734:	83 ec 04             	sub    $0x4,%esp
  800737:	89 f0                	mov    %esi,%eax
  800739:	29 d8                	sub    %ebx,%eax
  80073b:	50                   	push   %eax
  80073c:	89 d8                	mov    %ebx,%eax
  80073e:	03 45 0c             	add    0xc(%ebp),%eax
  800741:	50                   	push   %eax
  800742:	57                   	push   %edi
  800743:	e8 45 ff ff ff       	call   80068d <read>
		if (m < 0)
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	85 c0                	test   %eax,%eax
  80074d:	78 10                	js     80075f <readn+0x41>
			return m;
		if (m == 0)
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 0a                	je     80075d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800753:	01 c3                	add    %eax,%ebx
  800755:	39 f3                	cmp    %esi,%ebx
  800757:	72 db                	jb     800734 <readn+0x16>
  800759:	89 d8                	mov    %ebx,%eax
  80075b:	eb 02                	jmp    80075f <readn+0x41>
  80075d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80075f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800762:	5b                   	pop    %ebx
  800763:	5e                   	pop    %esi
  800764:	5f                   	pop    %edi
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	53                   	push   %ebx
  80076b:	83 ec 14             	sub    $0x14,%esp
  80076e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800771:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800774:	50                   	push   %eax
  800775:	53                   	push   %ebx
  800776:	e8 ac fc ff ff       	call   800427 <fd_lookup>
  80077b:	83 c4 08             	add    $0x8,%esp
  80077e:	89 c2                	mov    %eax,%edx
  800780:	85 c0                	test   %eax,%eax
  800782:	78 68                	js     8007ec <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078a:	50                   	push   %eax
  80078b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078e:	ff 30                	pushl  (%eax)
  800790:	e8 e8 fc ff ff       	call   80047d <dev_lookup>
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	85 c0                	test   %eax,%eax
  80079a:	78 47                	js     8007e3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80079c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80079f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007a3:	75 21                	jne    8007c6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8007aa:	8b 40 48             	mov    0x48(%eax),%eax
  8007ad:	83 ec 04             	sub    $0x4,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	50                   	push   %eax
  8007b2:	68 75 23 80 00       	push   $0x802375
  8007b7:	e8 48 0e 00 00       	call   801604 <cprintf>
		return -E_INVAL;
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007c4:	eb 26                	jmp    8007ec <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c9:	8b 52 0c             	mov    0xc(%edx),%edx
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 17                	je     8007e7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007d0:	83 ec 04             	sub    $0x4,%esp
  8007d3:	ff 75 10             	pushl  0x10(%ebp)
  8007d6:	ff 75 0c             	pushl  0xc(%ebp)
  8007d9:	50                   	push   %eax
  8007da:	ff d2                	call   *%edx
  8007dc:	89 c2                	mov    %eax,%edx
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	eb 09                	jmp    8007ec <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	89 c2                	mov    %eax,%edx
  8007e5:	eb 05                	jmp    8007ec <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ec:	89 d0                	mov    %edx,%eax
  8007ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007f9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007fc:	50                   	push   %eax
  8007fd:	ff 75 08             	pushl  0x8(%ebp)
  800800:	e8 22 fc ff ff       	call   800427 <fd_lookup>
  800805:	83 c4 08             	add    $0x8,%esp
  800808:	85 c0                	test   %eax,%eax
  80080a:	78 0e                	js     80081a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80080c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800812:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	53                   	push   %ebx
  800820:	83 ec 14             	sub    $0x14,%esp
  800823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800826:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800829:	50                   	push   %eax
  80082a:	53                   	push   %ebx
  80082b:	e8 f7 fb ff ff       	call   800427 <fd_lookup>
  800830:	83 c4 08             	add    $0x8,%esp
  800833:	89 c2                	mov    %eax,%edx
  800835:	85 c0                	test   %eax,%eax
  800837:	78 65                	js     80089e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083f:	50                   	push   %eax
  800840:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800843:	ff 30                	pushl  (%eax)
  800845:	e8 33 fc ff ff       	call   80047d <dev_lookup>
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	85 c0                	test   %eax,%eax
  80084f:	78 44                	js     800895 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800851:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800854:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800858:	75 21                	jne    80087b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80085a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80085f:	8b 40 48             	mov    0x48(%eax),%eax
  800862:	83 ec 04             	sub    $0x4,%esp
  800865:	53                   	push   %ebx
  800866:	50                   	push   %eax
  800867:	68 38 23 80 00       	push   $0x802338
  80086c:	e8 93 0d 00 00       	call   801604 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800871:	83 c4 10             	add    $0x10,%esp
  800874:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800879:	eb 23                	jmp    80089e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80087b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80087e:	8b 52 18             	mov    0x18(%edx),%edx
  800881:	85 d2                	test   %edx,%edx
  800883:	74 14                	je     800899 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	50                   	push   %eax
  80088c:	ff d2                	call   *%edx
  80088e:	89 c2                	mov    %eax,%edx
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	eb 09                	jmp    80089e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800895:	89 c2                	mov    %eax,%edx
  800897:	eb 05                	jmp    80089e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800899:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80089e:	89 d0                	mov    %edx,%eax
  8008a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	53                   	push   %ebx
  8008a9:	83 ec 14             	sub    $0x14,%esp
  8008ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b2:	50                   	push   %eax
  8008b3:	ff 75 08             	pushl  0x8(%ebp)
  8008b6:	e8 6c fb ff ff       	call   800427 <fd_lookup>
  8008bb:	83 c4 08             	add    $0x8,%esp
  8008be:	89 c2                	mov    %eax,%edx
  8008c0:	85 c0                	test   %eax,%eax
  8008c2:	78 58                	js     80091c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ca:	50                   	push   %eax
  8008cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ce:	ff 30                	pushl  (%eax)
  8008d0:	e8 a8 fb ff ff       	call   80047d <dev_lookup>
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	78 37                	js     800913 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008df:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008e3:	74 32                	je     800917 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008e5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008e8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ef:	00 00 00 
	stat->st_isdir = 0;
  8008f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008f9:	00 00 00 
	stat->st_dev = dev;
  8008fc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800902:	83 ec 08             	sub    $0x8,%esp
  800905:	53                   	push   %ebx
  800906:	ff 75 f0             	pushl  -0x10(%ebp)
  800909:	ff 50 14             	call   *0x14(%eax)
  80090c:	89 c2                	mov    %eax,%edx
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	eb 09                	jmp    80091c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800913:	89 c2                	mov    %eax,%edx
  800915:	eb 05                	jmp    80091c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800917:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800928:	83 ec 08             	sub    $0x8,%esp
  80092b:	6a 00                	push   $0x0
  80092d:	ff 75 08             	pushl  0x8(%ebp)
  800930:	e8 0c 02 00 00       	call   800b41 <open>
  800935:	89 c3                	mov    %eax,%ebx
  800937:	83 c4 10             	add    $0x10,%esp
  80093a:	85 c0                	test   %eax,%eax
  80093c:	78 1b                	js     800959 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	ff 75 0c             	pushl  0xc(%ebp)
  800944:	50                   	push   %eax
  800945:	e8 5b ff ff ff       	call   8008a5 <fstat>
  80094a:	89 c6                	mov    %eax,%esi
	close(fd);
  80094c:	89 1c 24             	mov    %ebx,(%esp)
  80094f:	e8 fd fb ff ff       	call   800551 <close>
	return r;
  800954:	83 c4 10             	add    $0x10,%esp
  800957:	89 f0                	mov    %esi,%eax
}
  800959:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	89 c6                	mov    %eax,%esi
  800967:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800969:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800970:	75 12                	jne    800984 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800972:	83 ec 0c             	sub    $0xc,%esp
  800975:	6a 01                	push   $0x1
  800977:	e8 56 16 00 00       	call   801fd2 <ipc_find_env>
  80097c:	a3 00 40 80 00       	mov    %eax,0x804000
  800981:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800984:	6a 07                	push   $0x7
  800986:	68 00 50 80 00       	push   $0x805000
  80098b:	56                   	push   %esi
  80098c:	ff 35 00 40 80 00    	pushl  0x804000
  800992:	e8 e7 15 00 00       	call   801f7e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800997:	83 c4 0c             	add    $0xc,%esp
  80099a:	6a 00                	push   $0x0
  80099c:	53                   	push   %ebx
  80099d:	6a 00                	push   $0x0
  80099f:	e8 71 15 00 00       	call   801f15 <ipc_recv>
}
  8009a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a7:	5b                   	pop    %ebx
  8009a8:	5e                   	pop    %esi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c9:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ce:	e8 8d ff ff ff       	call   800960 <fsipc>
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f0:	e8 6b ff ff ff       	call   800960 <fsipc>
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	83 ec 04             	sub    $0x4,%esp
  8009fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8b 40 0c             	mov    0xc(%eax),%eax
  800a07:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a11:	b8 05 00 00 00       	mov    $0x5,%eax
  800a16:	e8 45 ff ff ff       	call   800960 <fsipc>
  800a1b:	85 c0                	test   %eax,%eax
  800a1d:	78 2c                	js     800a4b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a1f:	83 ec 08             	sub    $0x8,%esp
  800a22:	68 00 50 80 00       	push   $0x805000
  800a27:	53                   	push   %ebx
  800a28:	e8 5c 11 00 00       	call   801b89 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a2d:	a1 80 50 80 00       	mov    0x805080,%eax
  800a32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a38:	a1 84 50 80 00       	mov    0x805084,%eax
  800a3d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a43:	83 c4 10             	add    $0x10,%esp
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	53                   	push   %ebx
  800a54:	83 ec 08             	sub    $0x8,%esp
  800a57:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5d:	8b 52 0c             	mov    0xc(%edx),%edx
  800a60:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a66:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a6b:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a70:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a73:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a79:	53                   	push   %ebx
  800a7a:	ff 75 0c             	pushl  0xc(%ebp)
  800a7d:	68 08 50 80 00       	push   $0x805008
  800a82:	e8 94 12 00 00       	call   801d1b <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  800a87:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a91:	e8 ca fe ff ff       	call   800960 <fsipc>
  800a96:	83 c4 10             	add    $0x10,%esp
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	78 1d                	js     800aba <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  800a9d:	39 d8                	cmp    %ebx,%eax
  800a9f:	76 19                	jbe    800aba <devfile_write+0x6a>
  800aa1:	68 a8 23 80 00       	push   $0x8023a8
  800aa6:	68 b4 23 80 00       	push   $0x8023b4
  800aab:	68 a3 00 00 00       	push   $0xa3
  800ab0:	68 c9 23 80 00       	push   $0x8023c9
  800ab5:	e8 71 0a 00 00       	call   80152b <_panic>
	return r;
}
  800aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 40 0c             	mov    0xc(%eax),%eax
  800acd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ad2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ad8:	ba 00 00 00 00       	mov    $0x0,%edx
  800add:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae2:	e8 79 fe ff ff       	call   800960 <fsipc>
  800ae7:	89 c3                	mov    %eax,%ebx
  800ae9:	85 c0                	test   %eax,%eax
  800aeb:	78 4b                	js     800b38 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aed:	39 c6                	cmp    %eax,%esi
  800aef:	73 16                	jae    800b07 <devfile_read+0x48>
  800af1:	68 d4 23 80 00       	push   $0x8023d4
  800af6:	68 b4 23 80 00       	push   $0x8023b4
  800afb:	6a 7c                	push   $0x7c
  800afd:	68 c9 23 80 00       	push   $0x8023c9
  800b02:	e8 24 0a 00 00       	call   80152b <_panic>
	assert(r <= PGSIZE);
  800b07:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800b0c:	7e 16                	jle    800b24 <devfile_read+0x65>
  800b0e:	68 db 23 80 00       	push   $0x8023db
  800b13:	68 b4 23 80 00       	push   $0x8023b4
  800b18:	6a 7d                	push   $0x7d
  800b1a:	68 c9 23 80 00       	push   $0x8023c9
  800b1f:	e8 07 0a 00 00       	call   80152b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b24:	83 ec 04             	sub    $0x4,%esp
  800b27:	50                   	push   %eax
  800b28:	68 00 50 80 00       	push   $0x805000
  800b2d:	ff 75 0c             	pushl  0xc(%ebp)
  800b30:	e8 e6 11 00 00       	call   801d1b <memmove>
	return r;
  800b35:	83 c4 10             	add    $0x10,%esp
}
  800b38:	89 d8                	mov    %ebx,%eax
  800b3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	53                   	push   %ebx
  800b45:	83 ec 20             	sub    $0x20,%esp
  800b48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b4b:	53                   	push   %ebx
  800b4c:	e8 ff 0f 00 00       	call   801b50 <strlen>
  800b51:	83 c4 10             	add    $0x10,%esp
  800b54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b59:	7f 67                	jg     800bc2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b61:	50                   	push   %eax
  800b62:	e8 71 f8 ff ff       	call   8003d8 <fd_alloc>
  800b67:	83 c4 10             	add    $0x10,%esp
		return r;
  800b6a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	78 57                	js     800bc7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b70:	83 ec 08             	sub    $0x8,%esp
  800b73:	53                   	push   %ebx
  800b74:	68 00 50 80 00       	push   $0x805000
  800b79:	e8 0b 10 00 00       	call   801b89 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b81:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b89:	b8 01 00 00 00       	mov    $0x1,%eax
  800b8e:	e8 cd fd ff ff       	call   800960 <fsipc>
  800b93:	89 c3                	mov    %eax,%ebx
  800b95:	83 c4 10             	add    $0x10,%esp
  800b98:	85 c0                	test   %eax,%eax
  800b9a:	79 14                	jns    800bb0 <open+0x6f>
		fd_close(fd, 0);
  800b9c:	83 ec 08             	sub    $0x8,%esp
  800b9f:	6a 00                	push   $0x0
  800ba1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba4:	e8 27 f9 ff ff       	call   8004d0 <fd_close>
		return r;
  800ba9:	83 c4 10             	add    $0x10,%esp
  800bac:	89 da                	mov    %ebx,%edx
  800bae:	eb 17                	jmp    800bc7 <open+0x86>
	}

	return fd2num(fd);
  800bb0:	83 ec 0c             	sub    $0xc,%esp
  800bb3:	ff 75 f4             	pushl  -0xc(%ebp)
  800bb6:	e8 f6 f7 ff ff       	call   8003b1 <fd2num>
  800bbb:	89 c2                	mov    %eax,%edx
  800bbd:	83 c4 10             	add    $0x10,%esp
  800bc0:	eb 05                	jmp    800bc7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bc2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bc7:	89 d0                	mov    %edx,%eax
  800bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 08 00 00 00       	mov    $0x8,%eax
  800bde:	e8 7d fd ff ff       	call   800960 <fsipc>
}
  800be3:	c9                   	leave  
  800be4:	c3                   	ret    

00800be5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800beb:	68 e7 23 80 00       	push   $0x8023e7
  800bf0:	ff 75 0c             	pushl  0xc(%ebp)
  800bf3:	e8 91 0f 00 00       	call   801b89 <strcpy>
	return 0;
}
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	53                   	push   %ebx
  800c03:	83 ec 10             	sub    $0x10,%esp
  800c06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800c09:	53                   	push   %ebx
  800c0a:	e8 fc 13 00 00       	call   80200b <pageref>
  800c0f:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800c12:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c17:	83 f8 01             	cmp    $0x1,%eax
  800c1a:	75 10                	jne    800c2c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	ff 73 0c             	pushl  0xc(%ebx)
  800c22:	e8 c0 02 00 00       	call   800ee7 <nsipc_close>
  800c27:	89 c2                	mov    %eax,%edx
  800c29:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c2c:	89 d0                	mov    %edx,%eax
  800c2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c39:	6a 00                	push   $0x0
  800c3b:	ff 75 10             	pushl  0x10(%ebp)
  800c3e:	ff 75 0c             	pushl  0xc(%ebp)
  800c41:	8b 45 08             	mov    0x8(%ebp),%eax
  800c44:	ff 70 0c             	pushl  0xc(%eax)
  800c47:	e8 78 03 00 00       	call   800fc4 <nsipc_send>
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c54:	6a 00                	push   $0x0
  800c56:	ff 75 10             	pushl  0x10(%ebp)
  800c59:	ff 75 0c             	pushl  0xc(%ebp)
  800c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5f:	ff 70 0c             	pushl  0xc(%eax)
  800c62:	e8 f1 02 00 00       	call   800f58 <nsipc_recv>
}
  800c67:	c9                   	leave  
  800c68:	c3                   	ret    

00800c69 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c6f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c72:	52                   	push   %edx
  800c73:	50                   	push   %eax
  800c74:	e8 ae f7 ff ff       	call   800427 <fd_lookup>
  800c79:	83 c4 10             	add    $0x10,%esp
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	78 17                	js     800c97 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c83:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c89:	39 08                	cmp    %ecx,(%eax)
  800c8b:	75 05                	jne    800c92 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800c90:	eb 05                	jmp    800c97 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c92:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c97:	c9                   	leave  
  800c98:	c3                   	ret    

00800c99 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 1c             	sub    $0x1c,%esp
  800ca1:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ca3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca6:	50                   	push   %eax
  800ca7:	e8 2c f7 ff ff       	call   8003d8 <fd_alloc>
  800cac:	89 c3                	mov    %eax,%ebx
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	78 1b                	js     800cd0 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800cb5:	83 ec 04             	sub    $0x4,%esp
  800cb8:	68 07 04 00 00       	push   $0x407
  800cbd:	ff 75 f4             	pushl  -0xc(%ebp)
  800cc0:	6a 00                	push   $0x0
  800cc2:	e8 a9 f4 ff ff       	call   800170 <sys_page_alloc>
  800cc7:	89 c3                	mov    %eax,%ebx
  800cc9:	83 c4 10             	add    $0x10,%esp
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	79 10                	jns    800ce0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cd0:	83 ec 0c             	sub    $0xc,%esp
  800cd3:	56                   	push   %esi
  800cd4:	e8 0e 02 00 00       	call   800ee7 <nsipc_close>
		return r;
  800cd9:	83 c4 10             	add    $0x10,%esp
  800cdc:	89 d8                	mov    %ebx,%eax
  800cde:	eb 24                	jmp    800d04 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ce0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cee:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cf5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cf8:	83 ec 0c             	sub    $0xc,%esp
  800cfb:	50                   	push   %eax
  800cfc:	e8 b0 f6 ff ff       	call   8003b1 <fd2num>
  800d01:	83 c4 10             	add    $0x10,%esp
}
  800d04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	e8 50 ff ff ff       	call   800c69 <fd2sockid>
		return r;
  800d19:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	78 1f                	js     800d3e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d1f:	83 ec 04             	sub    $0x4,%esp
  800d22:	ff 75 10             	pushl  0x10(%ebp)
  800d25:	ff 75 0c             	pushl  0xc(%ebp)
  800d28:	50                   	push   %eax
  800d29:	e8 12 01 00 00       	call   800e40 <nsipc_accept>
  800d2e:	83 c4 10             	add    $0x10,%esp
		return r;
  800d31:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d33:	85 c0                	test   %eax,%eax
  800d35:	78 07                	js     800d3e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d37:	e8 5d ff ff ff       	call   800c99 <alloc_sockfd>
  800d3c:	89 c1                	mov    %eax,%ecx
}
  800d3e:	89 c8                	mov    %ecx,%eax
  800d40:	c9                   	leave  
  800d41:	c3                   	ret    

00800d42 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d48:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4b:	e8 19 ff ff ff       	call   800c69 <fd2sockid>
  800d50:	85 c0                	test   %eax,%eax
  800d52:	78 12                	js     800d66 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d54:	83 ec 04             	sub    $0x4,%esp
  800d57:	ff 75 10             	pushl  0x10(%ebp)
  800d5a:	ff 75 0c             	pushl  0xc(%ebp)
  800d5d:	50                   	push   %eax
  800d5e:	e8 2d 01 00 00       	call   800e90 <nsipc_bind>
  800d63:	83 c4 10             	add    $0x10,%esp
}
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <shutdown>:

int
shutdown(int s, int how)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	e8 f3 fe ff ff       	call   800c69 <fd2sockid>
  800d76:	85 c0                	test   %eax,%eax
  800d78:	78 0f                	js     800d89 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d7a:	83 ec 08             	sub    $0x8,%esp
  800d7d:	ff 75 0c             	pushl  0xc(%ebp)
  800d80:	50                   	push   %eax
  800d81:	e8 3f 01 00 00       	call   800ec5 <nsipc_shutdown>
  800d86:	83 c4 10             	add    $0x10,%esp
}
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    

00800d8b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	e8 d0 fe ff ff       	call   800c69 <fd2sockid>
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	78 12                	js     800daf <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d9d:	83 ec 04             	sub    $0x4,%esp
  800da0:	ff 75 10             	pushl  0x10(%ebp)
  800da3:	ff 75 0c             	pushl  0xc(%ebp)
  800da6:	50                   	push   %eax
  800da7:	e8 55 01 00 00       	call   800f01 <nsipc_connect>
  800dac:	83 c4 10             	add    $0x10,%esp
}
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <listen>:

int
listen(int s, int backlog)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800db7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dba:	e8 aa fe ff ff       	call   800c69 <fd2sockid>
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	78 0f                	js     800dd2 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dc3:	83 ec 08             	sub    $0x8,%esp
  800dc6:	ff 75 0c             	pushl  0xc(%ebp)
  800dc9:	50                   	push   %eax
  800dca:	e8 67 01 00 00       	call   800f36 <nsipc_listen>
  800dcf:	83 c4 10             	add    $0x10,%esp
}
  800dd2:	c9                   	leave  
  800dd3:	c3                   	ret    

00800dd4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dda:	ff 75 10             	pushl  0x10(%ebp)
  800ddd:	ff 75 0c             	pushl  0xc(%ebp)
  800de0:	ff 75 08             	pushl  0x8(%ebp)
  800de3:	e8 3a 02 00 00       	call   801022 <nsipc_socket>
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	78 05                	js     800df4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800def:	e8 a5 fe ff ff       	call   800c99 <alloc_sockfd>
}
  800df4:	c9                   	leave  
  800df5:	c3                   	ret    

00800df6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	53                   	push   %ebx
  800dfa:	83 ec 04             	sub    $0x4,%esp
  800dfd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dff:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800e06:	75 12                	jne    800e1a <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	6a 02                	push   $0x2
  800e0d:	e8 c0 11 00 00       	call   801fd2 <ipc_find_env>
  800e12:	a3 04 40 80 00       	mov    %eax,0x804004
  800e17:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e1a:	6a 07                	push   $0x7
  800e1c:	68 00 60 80 00       	push   $0x806000
  800e21:	53                   	push   %ebx
  800e22:	ff 35 04 40 80 00    	pushl  0x804004
  800e28:	e8 51 11 00 00       	call   801f7e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e2d:	83 c4 0c             	add    $0xc,%esp
  800e30:	6a 00                	push   $0x0
  800e32:	6a 00                	push   $0x0
  800e34:	6a 00                	push   $0x0
  800e36:	e8 da 10 00 00       	call   801f15 <ipc_recv>
}
  800e3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e48:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e50:	8b 06                	mov    (%esi),%eax
  800e52:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e57:	b8 01 00 00 00       	mov    $0x1,%eax
  800e5c:	e8 95 ff ff ff       	call   800df6 <nsipc>
  800e61:	89 c3                	mov    %eax,%ebx
  800e63:	85 c0                	test   %eax,%eax
  800e65:	78 20                	js     800e87 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	ff 35 10 60 80 00    	pushl  0x806010
  800e70:	68 00 60 80 00       	push   $0x806000
  800e75:	ff 75 0c             	pushl  0xc(%ebp)
  800e78:	e8 9e 0e 00 00       	call   801d1b <memmove>
		*addrlen = ret->ret_addrlen;
  800e7d:	a1 10 60 80 00       	mov    0x806010,%eax
  800e82:	89 06                	mov    %eax,(%esi)
  800e84:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e87:	89 d8                	mov    %ebx,%eax
  800e89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8c:	5b                   	pop    %ebx
  800e8d:	5e                   	pop    %esi
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	53                   	push   %ebx
  800e94:	83 ec 08             	sub    $0x8,%esp
  800e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ea2:	53                   	push   %ebx
  800ea3:	ff 75 0c             	pushl  0xc(%ebp)
  800ea6:	68 04 60 80 00       	push   $0x806004
  800eab:	e8 6b 0e 00 00       	call   801d1b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800eb0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800eb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800ebb:	e8 36 ff ff ff       	call   800df6 <nsipc>
}
  800ec0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec3:	c9                   	leave  
  800ec4:	c3                   	ret    

00800ec5 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ece:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800edb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee0:	e8 11 ff ff ff       	call   800df6 <nsipc>
}
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <nsipc_close>:

int
nsipc_close(int s)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ef5:	b8 04 00 00 00       	mov    $0x4,%eax
  800efa:	e8 f7 fe ff ff       	call   800df6 <nsipc>
}
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	53                   	push   %ebx
  800f05:	83 ec 08             	sub    $0x8,%esp
  800f08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800f13:	53                   	push   %ebx
  800f14:	ff 75 0c             	pushl  0xc(%ebp)
  800f17:	68 04 60 80 00       	push   $0x806004
  800f1c:	e8 fa 0d 00 00       	call   801d1b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f21:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f27:	b8 05 00 00 00       	mov    $0x5,%eax
  800f2c:	e8 c5 fe ff ff       	call   800df6 <nsipc>
}
  800f31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f34:	c9                   	leave  
  800f35:	c3                   	ret    

00800f36 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f47:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f4c:	b8 06 00 00 00       	mov    $0x6,%eax
  800f51:	e8 a0 fe ff ff       	call   800df6 <nsipc>
}
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	56                   	push   %esi
  800f5c:	53                   	push   %ebx
  800f5d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f60:	8b 45 08             	mov    0x8(%ebp),%eax
  800f63:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f68:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f71:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f76:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7b:	e8 76 fe ff ff       	call   800df6 <nsipc>
  800f80:	89 c3                	mov    %eax,%ebx
  800f82:	85 c0                	test   %eax,%eax
  800f84:	78 35                	js     800fbb <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f86:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f8b:	7f 04                	jg     800f91 <nsipc_recv+0x39>
  800f8d:	39 c6                	cmp    %eax,%esi
  800f8f:	7d 16                	jge    800fa7 <nsipc_recv+0x4f>
  800f91:	68 f3 23 80 00       	push   $0x8023f3
  800f96:	68 b4 23 80 00       	push   $0x8023b4
  800f9b:	6a 62                	push   $0x62
  800f9d:	68 08 24 80 00       	push   $0x802408
  800fa2:	e8 84 05 00 00       	call   80152b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800fa7:	83 ec 04             	sub    $0x4,%esp
  800faa:	50                   	push   %eax
  800fab:	68 00 60 80 00       	push   $0x806000
  800fb0:	ff 75 0c             	pushl  0xc(%ebp)
  800fb3:	e8 63 0d 00 00       	call   801d1b <memmove>
  800fb8:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	53                   	push   %ebx
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fd6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fdc:	7e 16                	jle    800ff4 <nsipc_send+0x30>
  800fde:	68 14 24 80 00       	push   $0x802414
  800fe3:	68 b4 23 80 00       	push   $0x8023b4
  800fe8:	6a 6d                	push   $0x6d
  800fea:	68 08 24 80 00       	push   $0x802408
  800fef:	e8 37 05 00 00       	call   80152b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800ff4:	83 ec 04             	sub    $0x4,%esp
  800ff7:	53                   	push   %ebx
  800ff8:	ff 75 0c             	pushl  0xc(%ebp)
  800ffb:	68 0c 60 80 00       	push   $0x80600c
  801000:	e8 16 0d 00 00       	call   801d1b <memmove>
	nsipcbuf.send.req_size = size;
  801005:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80100b:	8b 45 14             	mov    0x14(%ebp),%eax
  80100e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801013:	b8 08 00 00 00       	mov    $0x8,%eax
  801018:	e8 d9 fd ff ff       	call   800df6 <nsipc>
}
  80101d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801020:	c9                   	leave  
  801021:	c3                   	ret    

00801022 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801028:	8b 45 08             	mov    0x8(%ebp),%eax
  80102b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801030:	8b 45 0c             	mov    0xc(%ebp),%eax
  801033:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801038:	8b 45 10             	mov    0x10(%ebp),%eax
  80103b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801040:	b8 09 00 00 00       	mov    $0x9,%eax
  801045:	e8 ac fd ff ff       	call   800df6 <nsipc>
}
  80104a:	c9                   	leave  
  80104b:	c3                   	ret    

0080104c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	ff 75 08             	pushl  0x8(%ebp)
  80105a:	e8 62 f3 ff ff       	call   8003c1 <fd2data>
  80105f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801061:	83 c4 08             	add    $0x8,%esp
  801064:	68 20 24 80 00       	push   $0x802420
  801069:	53                   	push   %ebx
  80106a:	e8 1a 0b 00 00       	call   801b89 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80106f:	8b 46 04             	mov    0x4(%esi),%eax
  801072:	2b 06                	sub    (%esi),%eax
  801074:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80107a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801081:	00 00 00 
	stat->st_dev = &devpipe;
  801084:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80108b:	30 80 00 
	return 0;
}
  80108e:	b8 00 00 00 00       	mov    $0x0,%eax
  801093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801096:	5b                   	pop    %ebx
  801097:	5e                   	pop    %esi
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    

0080109a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	53                   	push   %ebx
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010a4:	53                   	push   %ebx
  8010a5:	6a 00                	push   $0x0
  8010a7:	e8 49 f1 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010ac:	89 1c 24             	mov    %ebx,(%esp)
  8010af:	e8 0d f3 ff ff       	call   8003c1 <fd2data>
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	50                   	push   %eax
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 36 f1 ff ff       	call   8001f5 <sys_page_unmap>
}
  8010bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	57                   	push   %edi
  8010c8:	56                   	push   %esi
  8010c9:	53                   	push   %ebx
  8010ca:	83 ec 1c             	sub    $0x1c,%esp
  8010cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010d0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010d2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010d7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010da:	83 ec 0c             	sub    $0xc,%esp
  8010dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8010e0:	e8 26 0f 00 00       	call   80200b <pageref>
  8010e5:	89 c3                	mov    %eax,%ebx
  8010e7:	89 3c 24             	mov    %edi,(%esp)
  8010ea:	e8 1c 0f 00 00       	call   80200b <pageref>
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	39 c3                	cmp    %eax,%ebx
  8010f4:	0f 94 c1             	sete   %cl
  8010f7:	0f b6 c9             	movzbl %cl,%ecx
  8010fa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010fd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801103:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801106:	39 ce                	cmp    %ecx,%esi
  801108:	74 1b                	je     801125 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80110a:	39 c3                	cmp    %eax,%ebx
  80110c:	75 c4                	jne    8010d2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80110e:	8b 42 58             	mov    0x58(%edx),%eax
  801111:	ff 75 e4             	pushl  -0x1c(%ebp)
  801114:	50                   	push   %eax
  801115:	56                   	push   %esi
  801116:	68 27 24 80 00       	push   $0x802427
  80111b:	e8 e4 04 00 00       	call   801604 <cprintf>
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	eb ad                	jmp    8010d2 <_pipeisclosed+0xe>
	}
}
  801125:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112b:	5b                   	pop    %ebx
  80112c:	5e                   	pop    %esi
  80112d:	5f                   	pop    %edi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	53                   	push   %ebx
  801136:	83 ec 28             	sub    $0x28,%esp
  801139:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80113c:	56                   	push   %esi
  80113d:	e8 7f f2 ff ff       	call   8003c1 <fd2data>
  801142:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	bf 00 00 00 00       	mov    $0x0,%edi
  80114c:	eb 4b                	jmp    801199 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80114e:	89 da                	mov    %ebx,%edx
  801150:	89 f0                	mov    %esi,%eax
  801152:	e8 6d ff ff ff       	call   8010c4 <_pipeisclosed>
  801157:	85 c0                	test   %eax,%eax
  801159:	75 48                	jne    8011a3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80115b:	e8 f1 ef ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801160:	8b 43 04             	mov    0x4(%ebx),%eax
  801163:	8b 0b                	mov    (%ebx),%ecx
  801165:	8d 51 20             	lea    0x20(%ecx),%edx
  801168:	39 d0                	cmp    %edx,%eax
  80116a:	73 e2                	jae    80114e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80116c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801173:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801176:	89 c2                	mov    %eax,%edx
  801178:	c1 fa 1f             	sar    $0x1f,%edx
  80117b:	89 d1                	mov    %edx,%ecx
  80117d:	c1 e9 1b             	shr    $0x1b,%ecx
  801180:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801183:	83 e2 1f             	and    $0x1f,%edx
  801186:	29 ca                	sub    %ecx,%edx
  801188:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80118c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801190:	83 c0 01             	add    $0x1,%eax
  801193:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801196:	83 c7 01             	add    $0x1,%edi
  801199:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80119c:	75 c2                	jne    801160 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80119e:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a1:	eb 05                	jmp    8011a8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011a3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5f                   	pop    %edi
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	57                   	push   %edi
  8011b4:	56                   	push   %esi
  8011b5:	53                   	push   %ebx
  8011b6:	83 ec 18             	sub    $0x18,%esp
  8011b9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011bc:	57                   	push   %edi
  8011bd:	e8 ff f1 ff ff       	call   8003c1 <fd2data>
  8011c2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011cc:	eb 3d                	jmp    80120b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011ce:	85 db                	test   %ebx,%ebx
  8011d0:	74 04                	je     8011d6 <devpipe_read+0x26>
				return i;
  8011d2:	89 d8                	mov    %ebx,%eax
  8011d4:	eb 44                	jmp    80121a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011d6:	89 f2                	mov    %esi,%edx
  8011d8:	89 f8                	mov    %edi,%eax
  8011da:	e8 e5 fe ff ff       	call   8010c4 <_pipeisclosed>
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	75 32                	jne    801215 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011e3:	e8 69 ef ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011e8:	8b 06                	mov    (%esi),%eax
  8011ea:	3b 46 04             	cmp    0x4(%esi),%eax
  8011ed:	74 df                	je     8011ce <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ef:	99                   	cltd   
  8011f0:	c1 ea 1b             	shr    $0x1b,%edx
  8011f3:	01 d0                	add    %edx,%eax
  8011f5:	83 e0 1f             	and    $0x1f,%eax
  8011f8:	29 d0                	sub    %edx,%eax
  8011fa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801202:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801205:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801208:	83 c3 01             	add    $0x1,%ebx
  80120b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80120e:	75 d8                	jne    8011e8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801210:	8b 45 10             	mov    0x10(%ebp),%eax
  801213:	eb 05                	jmp    80121a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801215:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80121a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	56                   	push   %esi
  801226:	53                   	push   %ebx
  801227:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80122a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	e8 a5 f1 ff ff       	call   8003d8 <fd_alloc>
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	89 c2                	mov    %eax,%edx
  801238:	85 c0                	test   %eax,%eax
  80123a:	0f 88 2c 01 00 00    	js     80136c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	68 07 04 00 00       	push   $0x407
  801248:	ff 75 f4             	pushl  -0xc(%ebp)
  80124b:	6a 00                	push   $0x0
  80124d:	e8 1e ef ff ff       	call   800170 <sys_page_alloc>
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	89 c2                	mov    %eax,%edx
  801257:	85 c0                	test   %eax,%eax
  801259:	0f 88 0d 01 00 00    	js     80136c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80125f:	83 ec 0c             	sub    $0xc,%esp
  801262:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801265:	50                   	push   %eax
  801266:	e8 6d f1 ff ff       	call   8003d8 <fd_alloc>
  80126b:	89 c3                	mov    %eax,%ebx
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	0f 88 e2 00 00 00    	js     80135a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801278:	83 ec 04             	sub    $0x4,%esp
  80127b:	68 07 04 00 00       	push   $0x407
  801280:	ff 75 f0             	pushl  -0x10(%ebp)
  801283:	6a 00                	push   $0x0
  801285:	e8 e6 ee ff ff       	call   800170 <sys_page_alloc>
  80128a:	89 c3                	mov    %eax,%ebx
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	0f 88 c3 00 00 00    	js     80135a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801297:	83 ec 0c             	sub    $0xc,%esp
  80129a:	ff 75 f4             	pushl  -0xc(%ebp)
  80129d:	e8 1f f1 ff ff       	call   8003c1 <fd2data>
  8012a2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a4:	83 c4 0c             	add    $0xc,%esp
  8012a7:	68 07 04 00 00       	push   $0x407
  8012ac:	50                   	push   %eax
  8012ad:	6a 00                	push   $0x0
  8012af:	e8 bc ee ff ff       	call   800170 <sys_page_alloc>
  8012b4:	89 c3                	mov    %eax,%ebx
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	85 c0                	test   %eax,%eax
  8012bb:	0f 88 89 00 00 00    	js     80134a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012c1:	83 ec 0c             	sub    $0xc,%esp
  8012c4:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c7:	e8 f5 f0 ff ff       	call   8003c1 <fd2data>
  8012cc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012d3:	50                   	push   %eax
  8012d4:	6a 00                	push   $0x0
  8012d6:	56                   	push   %esi
  8012d7:	6a 00                	push   $0x0
  8012d9:	e8 d5 ee ff ff       	call   8001b3 <sys_page_map>
  8012de:	89 c3                	mov    %eax,%ebx
  8012e0:	83 c4 20             	add    $0x20,%esp
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 55                	js     80133c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012e7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012fc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801302:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801305:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	ff 75 f4             	pushl  -0xc(%ebp)
  801317:	e8 95 f0 ff ff       	call   8003b1 <fd2num>
  80131c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80131f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801321:	83 c4 04             	add    $0x4,%esp
  801324:	ff 75 f0             	pushl  -0x10(%ebp)
  801327:	e8 85 f0 ff ff       	call   8003b1 <fd2num>
  80132c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	ba 00 00 00 00       	mov    $0x0,%edx
  80133a:	eb 30                	jmp    80136c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	56                   	push   %esi
  801340:	6a 00                	push   $0x0
  801342:	e8 ae ee ff ff       	call   8001f5 <sys_page_unmap>
  801347:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	ff 75 f0             	pushl  -0x10(%ebp)
  801350:	6a 00                	push   $0x0
  801352:	e8 9e ee ff ff       	call   8001f5 <sys_page_unmap>
  801357:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	ff 75 f4             	pushl  -0xc(%ebp)
  801360:	6a 00                	push   $0x0
  801362:	e8 8e ee ff ff       	call   8001f5 <sys_page_unmap>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80136c:	89 d0                	mov    %edx,%eax
  80136e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801371:	5b                   	pop    %ebx
  801372:	5e                   	pop    %esi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	ff 75 08             	pushl  0x8(%ebp)
  801382:	e8 a0 f0 ff ff       	call   800427 <fd_lookup>
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	85 c0                	test   %eax,%eax
  80138c:	78 18                	js     8013a6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	ff 75 f4             	pushl  -0xc(%ebp)
  801394:	e8 28 f0 ff ff       	call   8003c1 <fd2data>
	return _pipeisclosed(fd, p);
  801399:	89 c2                	mov    %eax,%edx
  80139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139e:	e8 21 fd ff ff       	call   8010c4 <_pipeisclosed>
  8013a3:	83 c4 10             	add    $0x10,%esp
}
  8013a6:	c9                   	leave  
  8013a7:	c3                   	ret    

008013a8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    

008013b2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013b8:	68 3f 24 80 00       	push   $0x80243f
  8013bd:	ff 75 0c             	pushl  0xc(%ebp)
  8013c0:	e8 c4 07 00 00       	call   801b89 <strcpy>
	return 0;
}
  8013c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	57                   	push   %edi
  8013d0:	56                   	push   %esi
  8013d1:	53                   	push   %ebx
  8013d2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013d8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013dd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013e3:	eb 2d                	jmp    801412 <devcons_write+0x46>
		m = n - tot;
  8013e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013e8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013ea:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013ed:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013f2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013f5:	83 ec 04             	sub    $0x4,%esp
  8013f8:	53                   	push   %ebx
  8013f9:	03 45 0c             	add    0xc(%ebp),%eax
  8013fc:	50                   	push   %eax
  8013fd:	57                   	push   %edi
  8013fe:	e8 18 09 00 00       	call   801d1b <memmove>
		sys_cputs(buf, m);
  801403:	83 c4 08             	add    $0x8,%esp
  801406:	53                   	push   %ebx
  801407:	57                   	push   %edi
  801408:	e8 a7 ec ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80140d:	01 de                	add    %ebx,%esi
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	89 f0                	mov    %esi,%eax
  801414:	3b 75 10             	cmp    0x10(%ebp),%esi
  801417:	72 cc                	jb     8013e5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801419:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5e                   	pop    %esi
  80141e:	5f                   	pop    %edi
  80141f:	5d                   	pop    %ebp
  801420:	c3                   	ret    

00801421 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	83 ec 08             	sub    $0x8,%esp
  801427:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80142c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801430:	74 2a                	je     80145c <devcons_read+0x3b>
  801432:	eb 05                	jmp    801439 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801434:	e8 18 ed ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801439:	e8 94 ec ff ff       	call   8000d2 <sys_cgetc>
  80143e:	85 c0                	test   %eax,%eax
  801440:	74 f2                	je     801434 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801442:	85 c0                	test   %eax,%eax
  801444:	78 16                	js     80145c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801446:	83 f8 04             	cmp    $0x4,%eax
  801449:	74 0c                	je     801457 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80144b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80144e:	88 02                	mov    %al,(%edx)
	return 1;
  801450:	b8 01 00 00 00       	mov    $0x1,%eax
  801455:	eb 05                	jmp    80145c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801457:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801464:	8b 45 08             	mov    0x8(%ebp),%eax
  801467:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80146a:	6a 01                	push   $0x1
  80146c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80146f:	50                   	push   %eax
  801470:	e8 3f ec ff ff       	call   8000b4 <sys_cputs>
}
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	c9                   	leave  
  801479:	c3                   	ret    

0080147a <getchar>:

int
getchar(void)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801480:	6a 01                	push   $0x1
  801482:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801485:	50                   	push   %eax
  801486:	6a 00                	push   $0x0
  801488:	e8 00 f2 ff ff       	call   80068d <read>
	if (r < 0)
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	85 c0                	test   %eax,%eax
  801492:	78 0f                	js     8014a3 <getchar+0x29>
		return r;
	if (r < 1)
  801494:	85 c0                	test   %eax,%eax
  801496:	7e 06                	jle    80149e <getchar+0x24>
		return -E_EOF;
	return c;
  801498:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80149c:	eb 05                	jmp    8014a3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80149e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    

008014a5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	ff 75 08             	pushl  0x8(%ebp)
  8014b2:	e8 70 ef ff ff       	call   800427 <fd_lookup>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 11                	js     8014cf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c7:	39 10                	cmp    %edx,(%eax)
  8014c9:	0f 94 c0             	sete   %al
  8014cc:	0f b6 c0             	movzbl %al,%eax
}
  8014cf:	c9                   	leave  
  8014d0:	c3                   	ret    

008014d1 <opencons>:

int
opencons(void)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	e8 f8 ee ff ff       	call   8003d8 <fd_alloc>
  8014e0:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 3e                	js     801527 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014e9:	83 ec 04             	sub    $0x4,%esp
  8014ec:	68 07 04 00 00       	push   $0x407
  8014f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f4:	6a 00                	push   $0x0
  8014f6:	e8 75 ec ff ff       	call   800170 <sys_page_alloc>
  8014fb:	83 c4 10             	add    $0x10,%esp
		return r;
  8014fe:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801500:	85 c0                	test   %eax,%eax
  801502:	78 23                	js     801527 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801504:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80150a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80150f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801512:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801519:	83 ec 0c             	sub    $0xc,%esp
  80151c:	50                   	push   %eax
  80151d:	e8 8f ee ff ff       	call   8003b1 <fd2num>
  801522:	89 c2                	mov    %eax,%edx
  801524:	83 c4 10             	add    $0x10,%esp
}
  801527:	89 d0                	mov    %edx,%eax
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	56                   	push   %esi
  80152f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801530:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801533:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801539:	e8 f4 eb ff ff       	call   800132 <sys_getenvid>
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	ff 75 0c             	pushl  0xc(%ebp)
  801544:	ff 75 08             	pushl  0x8(%ebp)
  801547:	56                   	push   %esi
  801548:	50                   	push   %eax
  801549:	68 4c 24 80 00       	push   $0x80244c
  80154e:	e8 b1 00 00 00       	call   801604 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801553:	83 c4 18             	add    $0x18,%esp
  801556:	53                   	push   %ebx
  801557:	ff 75 10             	pushl  0x10(%ebp)
  80155a:	e8 54 00 00 00       	call   8015b3 <vcprintf>
	cprintf("\n");
  80155f:	c7 04 24 38 24 80 00 	movl   $0x802438,(%esp)
  801566:	e8 99 00 00 00       	call   801604 <cprintf>
  80156b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80156e:	cc                   	int3   
  80156f:	eb fd                	jmp    80156e <_panic+0x43>

00801571 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	53                   	push   %ebx
  801575:	83 ec 04             	sub    $0x4,%esp
  801578:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80157b:	8b 13                	mov    (%ebx),%edx
  80157d:	8d 42 01             	lea    0x1(%edx),%eax
  801580:	89 03                	mov    %eax,(%ebx)
  801582:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801585:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801589:	3d ff 00 00 00       	cmp    $0xff,%eax
  80158e:	75 1a                	jne    8015aa <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801590:	83 ec 08             	sub    $0x8,%esp
  801593:	68 ff 00 00 00       	push   $0xff
  801598:	8d 43 08             	lea    0x8(%ebx),%eax
  80159b:	50                   	push   %eax
  80159c:	e8 13 eb ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8015a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8015a7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8015aa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8015ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015c3:	00 00 00 
	b.cnt = 0;
  8015c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015d0:	ff 75 0c             	pushl  0xc(%ebp)
  8015d3:	ff 75 08             	pushl  0x8(%ebp)
  8015d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015dc:	50                   	push   %eax
  8015dd:	68 71 15 80 00       	push   $0x801571
  8015e2:	e8 54 01 00 00       	call   80173b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015e7:	83 c4 08             	add    $0x8,%esp
  8015ea:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015f0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	e8 b8 ea ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8015fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80160a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80160d:	50                   	push   %eax
  80160e:	ff 75 08             	pushl  0x8(%ebp)
  801611:	e8 9d ff ff ff       	call   8015b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	57                   	push   %edi
  80161c:	56                   	push   %esi
  80161d:	53                   	push   %ebx
  80161e:	83 ec 1c             	sub    $0x1c,%esp
  801621:	89 c7                	mov    %eax,%edi
  801623:	89 d6                	mov    %edx,%esi
  801625:	8b 45 08             	mov    0x8(%ebp),%eax
  801628:	8b 55 0c             	mov    0xc(%ebp),%edx
  80162b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80162e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801631:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801634:	bb 00 00 00 00       	mov    $0x0,%ebx
  801639:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80163c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80163f:	39 d3                	cmp    %edx,%ebx
  801641:	72 05                	jb     801648 <printnum+0x30>
  801643:	39 45 10             	cmp    %eax,0x10(%ebp)
  801646:	77 45                	ja     80168d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801648:	83 ec 0c             	sub    $0xc,%esp
  80164b:	ff 75 18             	pushl  0x18(%ebp)
  80164e:	8b 45 14             	mov    0x14(%ebp),%eax
  801651:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801654:	53                   	push   %ebx
  801655:	ff 75 10             	pushl  0x10(%ebp)
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165e:	ff 75 e0             	pushl  -0x20(%ebp)
  801661:	ff 75 dc             	pushl  -0x24(%ebp)
  801664:	ff 75 d8             	pushl  -0x28(%ebp)
  801667:	e8 e4 09 00 00       	call   802050 <__udivdi3>
  80166c:	83 c4 18             	add    $0x18,%esp
  80166f:	52                   	push   %edx
  801670:	50                   	push   %eax
  801671:	89 f2                	mov    %esi,%edx
  801673:	89 f8                	mov    %edi,%eax
  801675:	e8 9e ff ff ff       	call   801618 <printnum>
  80167a:	83 c4 20             	add    $0x20,%esp
  80167d:	eb 18                	jmp    801697 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80167f:	83 ec 08             	sub    $0x8,%esp
  801682:	56                   	push   %esi
  801683:	ff 75 18             	pushl  0x18(%ebp)
  801686:	ff d7                	call   *%edi
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	eb 03                	jmp    801690 <printnum+0x78>
  80168d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801690:	83 eb 01             	sub    $0x1,%ebx
  801693:	85 db                	test   %ebx,%ebx
  801695:	7f e8                	jg     80167f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	56                   	push   %esi
  80169b:	83 ec 04             	sub    $0x4,%esp
  80169e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8016a4:	ff 75 dc             	pushl  -0x24(%ebp)
  8016a7:	ff 75 d8             	pushl  -0x28(%ebp)
  8016aa:	e8 d1 0a 00 00       	call   802180 <__umoddi3>
  8016af:	83 c4 14             	add    $0x14,%esp
  8016b2:	0f be 80 6f 24 80 00 	movsbl 0x80246f(%eax),%eax
  8016b9:	50                   	push   %eax
  8016ba:	ff d7                	call   *%edi
}
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c2:	5b                   	pop    %ebx
  8016c3:	5e                   	pop    %esi
  8016c4:	5f                   	pop    %edi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016ca:	83 fa 01             	cmp    $0x1,%edx
  8016cd:	7e 0e                	jle    8016dd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016cf:	8b 10                	mov    (%eax),%edx
  8016d1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016d4:	89 08                	mov    %ecx,(%eax)
  8016d6:	8b 02                	mov    (%edx),%eax
  8016d8:	8b 52 04             	mov    0x4(%edx),%edx
  8016db:	eb 22                	jmp    8016ff <getuint+0x38>
	else if (lflag)
  8016dd:	85 d2                	test   %edx,%edx
  8016df:	74 10                	je     8016f1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016e1:	8b 10                	mov    (%eax),%edx
  8016e3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016e6:	89 08                	mov    %ecx,(%eax)
  8016e8:	8b 02                	mov    (%edx),%eax
  8016ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ef:	eb 0e                	jmp    8016ff <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016f1:	8b 10                	mov    (%eax),%edx
  8016f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016f6:	89 08                	mov    %ecx,(%eax)
  8016f8:	8b 02                	mov    (%edx),%eax
  8016fa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016ff:	5d                   	pop    %ebp
  801700:	c3                   	ret    

00801701 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801707:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80170b:	8b 10                	mov    (%eax),%edx
  80170d:	3b 50 04             	cmp    0x4(%eax),%edx
  801710:	73 0a                	jae    80171c <sprintputch+0x1b>
		*b->buf++ = ch;
  801712:	8d 4a 01             	lea    0x1(%edx),%ecx
  801715:	89 08                	mov    %ecx,(%eax)
  801717:	8b 45 08             	mov    0x8(%ebp),%eax
  80171a:	88 02                	mov    %al,(%edx)
}
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801724:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801727:	50                   	push   %eax
  801728:	ff 75 10             	pushl  0x10(%ebp)
  80172b:	ff 75 0c             	pushl  0xc(%ebp)
  80172e:	ff 75 08             	pushl  0x8(%ebp)
  801731:	e8 05 00 00 00       	call   80173b <vprintfmt>
	va_end(ap);
}
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	57                   	push   %edi
  80173f:	56                   	push   %esi
  801740:	53                   	push   %ebx
  801741:	83 ec 2c             	sub    $0x2c,%esp
  801744:	8b 75 08             	mov    0x8(%ebp),%esi
  801747:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80174a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80174d:	eb 12                	jmp    801761 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80174f:	85 c0                	test   %eax,%eax
  801751:	0f 84 89 03 00 00    	je     801ae0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	53                   	push   %ebx
  80175b:	50                   	push   %eax
  80175c:	ff d6                	call   *%esi
  80175e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801761:	83 c7 01             	add    $0x1,%edi
  801764:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801768:	83 f8 25             	cmp    $0x25,%eax
  80176b:	75 e2                	jne    80174f <vprintfmt+0x14>
  80176d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801771:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801778:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80177f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801786:	ba 00 00 00 00       	mov    $0x0,%edx
  80178b:	eb 07                	jmp    801794 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801790:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801794:	8d 47 01             	lea    0x1(%edi),%eax
  801797:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80179a:	0f b6 07             	movzbl (%edi),%eax
  80179d:	0f b6 c8             	movzbl %al,%ecx
  8017a0:	83 e8 23             	sub    $0x23,%eax
  8017a3:	3c 55                	cmp    $0x55,%al
  8017a5:	0f 87 1a 03 00 00    	ja     801ac5 <vprintfmt+0x38a>
  8017ab:	0f b6 c0             	movzbl %al,%eax
  8017ae:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  8017b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8017b8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8017bc:	eb d6                	jmp    801794 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017c9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017cc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017d0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017d3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017d6:	83 fa 09             	cmp    $0x9,%edx
  8017d9:	77 39                	ja     801814 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017db:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017de:	eb e9                	jmp    8017c9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e3:	8d 48 04             	lea    0x4(%eax),%ecx
  8017e6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017e9:	8b 00                	mov    (%eax),%eax
  8017eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017f1:	eb 27                	jmp    80181a <vprintfmt+0xdf>
  8017f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017fd:	0f 49 c8             	cmovns %eax,%ecx
  801800:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801803:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801806:	eb 8c                	jmp    801794 <vprintfmt+0x59>
  801808:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80180b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801812:	eb 80                	jmp    801794 <vprintfmt+0x59>
  801814:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801817:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80181a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80181e:	0f 89 70 ff ff ff    	jns    801794 <vprintfmt+0x59>
				width = precision, precision = -1;
  801824:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801827:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80182a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801831:	e9 5e ff ff ff       	jmp    801794 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801836:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801839:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80183c:	e9 53 ff ff ff       	jmp    801794 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801841:	8b 45 14             	mov    0x14(%ebp),%eax
  801844:	8d 50 04             	lea    0x4(%eax),%edx
  801847:	89 55 14             	mov    %edx,0x14(%ebp)
  80184a:	83 ec 08             	sub    $0x8,%esp
  80184d:	53                   	push   %ebx
  80184e:	ff 30                	pushl  (%eax)
  801850:	ff d6                	call   *%esi
			break;
  801852:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801858:	e9 04 ff ff ff       	jmp    801761 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80185d:	8b 45 14             	mov    0x14(%ebp),%eax
  801860:	8d 50 04             	lea    0x4(%eax),%edx
  801863:	89 55 14             	mov    %edx,0x14(%ebp)
  801866:	8b 00                	mov    (%eax),%eax
  801868:	99                   	cltd   
  801869:	31 d0                	xor    %edx,%eax
  80186b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80186d:	83 f8 0f             	cmp    $0xf,%eax
  801870:	7f 0b                	jg     80187d <vprintfmt+0x142>
  801872:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  801879:	85 d2                	test   %edx,%edx
  80187b:	75 18                	jne    801895 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80187d:	50                   	push   %eax
  80187e:	68 87 24 80 00       	push   $0x802487
  801883:	53                   	push   %ebx
  801884:	56                   	push   %esi
  801885:	e8 94 fe ff ff       	call   80171e <printfmt>
  80188a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80188d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801890:	e9 cc fe ff ff       	jmp    801761 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801895:	52                   	push   %edx
  801896:	68 c6 23 80 00       	push   $0x8023c6
  80189b:	53                   	push   %ebx
  80189c:	56                   	push   %esi
  80189d:	e8 7c fe ff ff       	call   80171e <printfmt>
  8018a2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018a8:	e9 b4 fe ff ff       	jmp    801761 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8018ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b0:	8d 50 04             	lea    0x4(%eax),%edx
  8018b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8018b8:	85 ff                	test   %edi,%edi
  8018ba:	b8 80 24 80 00       	mov    $0x802480,%eax
  8018bf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018c6:	0f 8e 94 00 00 00    	jle    801960 <vprintfmt+0x225>
  8018cc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018d0:	0f 84 98 00 00 00    	je     80196e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8018dc:	57                   	push   %edi
  8018dd:	e8 86 02 00 00       	call   801b68 <strnlen>
  8018e2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018e5:	29 c1                	sub    %eax,%ecx
  8018e7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018ea:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018ed:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018f4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018f7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018f9:	eb 0f                	jmp    80190a <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	53                   	push   %ebx
  8018ff:	ff 75 e0             	pushl  -0x20(%ebp)
  801902:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801904:	83 ef 01             	sub    $0x1,%edi
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	85 ff                	test   %edi,%edi
  80190c:	7f ed                	jg     8018fb <vprintfmt+0x1c0>
  80190e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801911:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801914:	85 c9                	test   %ecx,%ecx
  801916:	b8 00 00 00 00       	mov    $0x0,%eax
  80191b:	0f 49 c1             	cmovns %ecx,%eax
  80191e:	29 c1                	sub    %eax,%ecx
  801920:	89 75 08             	mov    %esi,0x8(%ebp)
  801923:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801926:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801929:	89 cb                	mov    %ecx,%ebx
  80192b:	eb 4d                	jmp    80197a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80192d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801931:	74 1b                	je     80194e <vprintfmt+0x213>
  801933:	0f be c0             	movsbl %al,%eax
  801936:	83 e8 20             	sub    $0x20,%eax
  801939:	83 f8 5e             	cmp    $0x5e,%eax
  80193c:	76 10                	jbe    80194e <vprintfmt+0x213>
					putch('?', putdat);
  80193e:	83 ec 08             	sub    $0x8,%esp
  801941:	ff 75 0c             	pushl  0xc(%ebp)
  801944:	6a 3f                	push   $0x3f
  801946:	ff 55 08             	call   *0x8(%ebp)
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	eb 0d                	jmp    80195b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80194e:	83 ec 08             	sub    $0x8,%esp
  801951:	ff 75 0c             	pushl  0xc(%ebp)
  801954:	52                   	push   %edx
  801955:	ff 55 08             	call   *0x8(%ebp)
  801958:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80195b:	83 eb 01             	sub    $0x1,%ebx
  80195e:	eb 1a                	jmp    80197a <vprintfmt+0x23f>
  801960:	89 75 08             	mov    %esi,0x8(%ebp)
  801963:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801966:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801969:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80196c:	eb 0c                	jmp    80197a <vprintfmt+0x23f>
  80196e:	89 75 08             	mov    %esi,0x8(%ebp)
  801971:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801974:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801977:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80197a:	83 c7 01             	add    $0x1,%edi
  80197d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801981:	0f be d0             	movsbl %al,%edx
  801984:	85 d2                	test   %edx,%edx
  801986:	74 23                	je     8019ab <vprintfmt+0x270>
  801988:	85 f6                	test   %esi,%esi
  80198a:	78 a1                	js     80192d <vprintfmt+0x1f2>
  80198c:	83 ee 01             	sub    $0x1,%esi
  80198f:	79 9c                	jns    80192d <vprintfmt+0x1f2>
  801991:	89 df                	mov    %ebx,%edi
  801993:	8b 75 08             	mov    0x8(%ebp),%esi
  801996:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801999:	eb 18                	jmp    8019b3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80199b:	83 ec 08             	sub    $0x8,%esp
  80199e:	53                   	push   %ebx
  80199f:	6a 20                	push   $0x20
  8019a1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8019a3:	83 ef 01             	sub    $0x1,%edi
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	eb 08                	jmp    8019b3 <vprintfmt+0x278>
  8019ab:	89 df                	mov    %ebx,%edi
  8019ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8019b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019b3:	85 ff                	test   %edi,%edi
  8019b5:	7f e4                	jg     80199b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019ba:	e9 a2 fd ff ff       	jmp    801761 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019bf:	83 fa 01             	cmp    $0x1,%edx
  8019c2:	7e 16                	jle    8019da <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c7:	8d 50 08             	lea    0x8(%eax),%edx
  8019ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8019cd:	8b 50 04             	mov    0x4(%eax),%edx
  8019d0:	8b 00                	mov    (%eax),%eax
  8019d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019d8:	eb 32                	jmp    801a0c <vprintfmt+0x2d1>
	else if (lflag)
  8019da:	85 d2                	test   %edx,%edx
  8019dc:	74 18                	je     8019f6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019de:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e1:	8d 50 04             	lea    0x4(%eax),%edx
  8019e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8019e7:	8b 00                	mov    (%eax),%eax
  8019e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ec:	89 c1                	mov    %eax,%ecx
  8019ee:	c1 f9 1f             	sar    $0x1f,%ecx
  8019f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019f4:	eb 16                	jmp    801a0c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f9:	8d 50 04             	lea    0x4(%eax),%edx
  8019fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8019ff:	8b 00                	mov    (%eax),%eax
  801a01:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a04:	89 c1                	mov    %eax,%ecx
  801a06:	c1 f9 1f             	sar    $0x1f,%ecx
  801a09:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801a0c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a0f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801a12:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801a17:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801a1b:	79 74                	jns    801a91 <vprintfmt+0x356>
				putch('-', putdat);
  801a1d:	83 ec 08             	sub    $0x8,%esp
  801a20:	53                   	push   %ebx
  801a21:	6a 2d                	push   $0x2d
  801a23:	ff d6                	call   *%esi
				num = -(long long) num;
  801a25:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a28:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a2b:	f7 d8                	neg    %eax
  801a2d:	83 d2 00             	adc    $0x0,%edx
  801a30:	f7 da                	neg    %edx
  801a32:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a35:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a3a:	eb 55                	jmp    801a91 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a3c:	8d 45 14             	lea    0x14(%ebp),%eax
  801a3f:	e8 83 fc ff ff       	call   8016c7 <getuint>
			base = 10;
  801a44:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a49:	eb 46                	jmp    801a91 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a4b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a4e:	e8 74 fc ff ff       	call   8016c7 <getuint>
                        base = 8;
  801a53:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a58:	eb 37                	jmp    801a91 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a5a:	83 ec 08             	sub    $0x8,%esp
  801a5d:	53                   	push   %ebx
  801a5e:	6a 30                	push   $0x30
  801a60:	ff d6                	call   *%esi
			putch('x', putdat);
  801a62:	83 c4 08             	add    $0x8,%esp
  801a65:	53                   	push   %ebx
  801a66:	6a 78                	push   $0x78
  801a68:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a6a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6d:	8d 50 04             	lea    0x4(%eax),%edx
  801a70:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a73:	8b 00                	mov    (%eax),%eax
  801a75:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a7a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a7d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a82:	eb 0d                	jmp    801a91 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a84:	8d 45 14             	lea    0x14(%ebp),%eax
  801a87:	e8 3b fc ff ff       	call   8016c7 <getuint>
			base = 16;
  801a8c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a98:	57                   	push   %edi
  801a99:	ff 75 e0             	pushl  -0x20(%ebp)
  801a9c:	51                   	push   %ecx
  801a9d:	52                   	push   %edx
  801a9e:	50                   	push   %eax
  801a9f:	89 da                	mov    %ebx,%edx
  801aa1:	89 f0                	mov    %esi,%eax
  801aa3:	e8 70 fb ff ff       	call   801618 <printnum>
			break;
  801aa8:	83 c4 20             	add    $0x20,%esp
  801aab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801aae:	e9 ae fc ff ff       	jmp    801761 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	53                   	push   %ebx
  801ab7:	51                   	push   %ecx
  801ab8:	ff d6                	call   *%esi
			break;
  801aba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801abd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ac0:	e9 9c fc ff ff       	jmp    801761 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ac5:	83 ec 08             	sub    $0x8,%esp
  801ac8:	53                   	push   %ebx
  801ac9:	6a 25                	push   $0x25
  801acb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	eb 03                	jmp    801ad5 <vprintfmt+0x39a>
  801ad2:	83 ef 01             	sub    $0x1,%edi
  801ad5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ad9:	75 f7                	jne    801ad2 <vprintfmt+0x397>
  801adb:	e9 81 fc ff ff       	jmp    801761 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae3:	5b                   	pop    %ebx
  801ae4:	5e                   	pop    %esi
  801ae5:	5f                   	pop    %edi
  801ae6:	5d                   	pop    %ebp
  801ae7:	c3                   	ret    

00801ae8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	83 ec 18             	sub    $0x18,%esp
  801aee:	8b 45 08             	mov    0x8(%ebp),%eax
  801af1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801af4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801af7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801afb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801afe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b05:	85 c0                	test   %eax,%eax
  801b07:	74 26                	je     801b2f <vsnprintf+0x47>
  801b09:	85 d2                	test   %edx,%edx
  801b0b:	7e 22                	jle    801b2f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b0d:	ff 75 14             	pushl  0x14(%ebp)
  801b10:	ff 75 10             	pushl  0x10(%ebp)
  801b13:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b16:	50                   	push   %eax
  801b17:	68 01 17 80 00       	push   $0x801701
  801b1c:	e8 1a fc ff ff       	call   80173b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b21:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b24:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2a:	83 c4 10             	add    $0x10,%esp
  801b2d:	eb 05                	jmp    801b34 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b3c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b3f:	50                   	push   %eax
  801b40:	ff 75 10             	pushl  0x10(%ebp)
  801b43:	ff 75 0c             	pushl  0xc(%ebp)
  801b46:	ff 75 08             	pushl  0x8(%ebp)
  801b49:	e8 9a ff ff ff       	call   801ae8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b56:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5b:	eb 03                	jmp    801b60 <strlen+0x10>
		n++;
  801b5d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b64:	75 f7                	jne    801b5d <strlen+0xd>
		n++;
	return n;
}
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    

00801b68 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b71:	ba 00 00 00 00       	mov    $0x0,%edx
  801b76:	eb 03                	jmp    801b7b <strnlen+0x13>
		n++;
  801b78:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b7b:	39 c2                	cmp    %eax,%edx
  801b7d:	74 08                	je     801b87 <strnlen+0x1f>
  801b7f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b83:	75 f3                	jne    801b78 <strnlen+0x10>
  801b85:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	53                   	push   %ebx
  801b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b93:	89 c2                	mov    %eax,%edx
  801b95:	83 c2 01             	add    $0x1,%edx
  801b98:	83 c1 01             	add    $0x1,%ecx
  801b9b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b9f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ba2:	84 db                	test   %bl,%bl
  801ba4:	75 ef                	jne    801b95 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ba6:	5b                   	pop    %ebx
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    

00801ba9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	53                   	push   %ebx
  801bad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bb0:	53                   	push   %ebx
  801bb1:	e8 9a ff ff ff       	call   801b50 <strlen>
  801bb6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bb9:	ff 75 0c             	pushl  0xc(%ebp)
  801bbc:	01 d8                	add    %ebx,%eax
  801bbe:	50                   	push   %eax
  801bbf:	e8 c5 ff ff ff       	call   801b89 <strcpy>
	return dst;
}
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	56                   	push   %esi
  801bcf:	53                   	push   %ebx
  801bd0:	8b 75 08             	mov    0x8(%ebp),%esi
  801bd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd6:	89 f3                	mov    %esi,%ebx
  801bd8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bdb:	89 f2                	mov    %esi,%edx
  801bdd:	eb 0f                	jmp    801bee <strncpy+0x23>
		*dst++ = *src;
  801bdf:	83 c2 01             	add    $0x1,%edx
  801be2:	0f b6 01             	movzbl (%ecx),%eax
  801be5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801be8:	80 39 01             	cmpb   $0x1,(%ecx)
  801beb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bee:	39 da                	cmp    %ebx,%edx
  801bf0:	75 ed                	jne    801bdf <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bf2:	89 f0                	mov    %esi,%eax
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	56                   	push   %esi
  801bfc:	53                   	push   %ebx
  801bfd:	8b 75 08             	mov    0x8(%ebp),%esi
  801c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c03:	8b 55 10             	mov    0x10(%ebp),%edx
  801c06:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c08:	85 d2                	test   %edx,%edx
  801c0a:	74 21                	je     801c2d <strlcpy+0x35>
  801c0c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c10:	89 f2                	mov    %esi,%edx
  801c12:	eb 09                	jmp    801c1d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c14:	83 c2 01             	add    $0x1,%edx
  801c17:	83 c1 01             	add    $0x1,%ecx
  801c1a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c1d:	39 c2                	cmp    %eax,%edx
  801c1f:	74 09                	je     801c2a <strlcpy+0x32>
  801c21:	0f b6 19             	movzbl (%ecx),%ebx
  801c24:	84 db                	test   %bl,%bl
  801c26:	75 ec                	jne    801c14 <strlcpy+0x1c>
  801c28:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c2a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c2d:	29 f0                	sub    %esi,%eax
}
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c39:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c3c:	eb 06                	jmp    801c44 <strcmp+0x11>
		p++, q++;
  801c3e:	83 c1 01             	add    $0x1,%ecx
  801c41:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c44:	0f b6 01             	movzbl (%ecx),%eax
  801c47:	84 c0                	test   %al,%al
  801c49:	74 04                	je     801c4f <strcmp+0x1c>
  801c4b:	3a 02                	cmp    (%edx),%al
  801c4d:	74 ef                	je     801c3e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c4f:	0f b6 c0             	movzbl %al,%eax
  801c52:	0f b6 12             	movzbl (%edx),%edx
  801c55:	29 d0                	sub    %edx,%eax
}
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    

00801c59 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	53                   	push   %ebx
  801c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c60:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c63:	89 c3                	mov    %eax,%ebx
  801c65:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c68:	eb 06                	jmp    801c70 <strncmp+0x17>
		n--, p++, q++;
  801c6a:	83 c0 01             	add    $0x1,%eax
  801c6d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c70:	39 d8                	cmp    %ebx,%eax
  801c72:	74 15                	je     801c89 <strncmp+0x30>
  801c74:	0f b6 08             	movzbl (%eax),%ecx
  801c77:	84 c9                	test   %cl,%cl
  801c79:	74 04                	je     801c7f <strncmp+0x26>
  801c7b:	3a 0a                	cmp    (%edx),%cl
  801c7d:	74 eb                	je     801c6a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c7f:	0f b6 00             	movzbl (%eax),%eax
  801c82:	0f b6 12             	movzbl (%edx),%edx
  801c85:	29 d0                	sub    %edx,%eax
  801c87:	eb 05                	jmp    801c8e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c89:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c8e:	5b                   	pop    %ebx
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	8b 45 08             	mov    0x8(%ebp),%eax
  801c97:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c9b:	eb 07                	jmp    801ca4 <strchr+0x13>
		if (*s == c)
  801c9d:	38 ca                	cmp    %cl,%dl
  801c9f:	74 0f                	je     801cb0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ca1:	83 c0 01             	add    $0x1,%eax
  801ca4:	0f b6 10             	movzbl (%eax),%edx
  801ca7:	84 d2                	test   %dl,%dl
  801ca9:	75 f2                	jne    801c9d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    

00801cb2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cbc:	eb 03                	jmp    801cc1 <strfind+0xf>
  801cbe:	83 c0 01             	add    $0x1,%eax
  801cc1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cc4:	38 ca                	cmp    %cl,%dl
  801cc6:	74 04                	je     801ccc <strfind+0x1a>
  801cc8:	84 d2                	test   %dl,%dl
  801cca:	75 f2                	jne    801cbe <strfind+0xc>
			break;
	return (char *) s;
}
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cda:	85 c9                	test   %ecx,%ecx
  801cdc:	74 36                	je     801d14 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cde:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ce4:	75 28                	jne    801d0e <memset+0x40>
  801ce6:	f6 c1 03             	test   $0x3,%cl
  801ce9:	75 23                	jne    801d0e <memset+0x40>
		c &= 0xFF;
  801ceb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cef:	89 d3                	mov    %edx,%ebx
  801cf1:	c1 e3 08             	shl    $0x8,%ebx
  801cf4:	89 d6                	mov    %edx,%esi
  801cf6:	c1 e6 18             	shl    $0x18,%esi
  801cf9:	89 d0                	mov    %edx,%eax
  801cfb:	c1 e0 10             	shl    $0x10,%eax
  801cfe:	09 f0                	or     %esi,%eax
  801d00:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d02:	89 d8                	mov    %ebx,%eax
  801d04:	09 d0                	or     %edx,%eax
  801d06:	c1 e9 02             	shr    $0x2,%ecx
  801d09:	fc                   	cld    
  801d0a:	f3 ab                	rep stos %eax,%es:(%edi)
  801d0c:	eb 06                	jmp    801d14 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d11:	fc                   	cld    
  801d12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d14:	89 f8                	mov    %edi,%eax
  801d16:	5b                   	pop    %ebx
  801d17:	5e                   	pop    %esi
  801d18:	5f                   	pop    %edi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	57                   	push   %edi
  801d1f:	56                   	push   %esi
  801d20:	8b 45 08             	mov    0x8(%ebp),%eax
  801d23:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d29:	39 c6                	cmp    %eax,%esi
  801d2b:	73 35                	jae    801d62 <memmove+0x47>
  801d2d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d30:	39 d0                	cmp    %edx,%eax
  801d32:	73 2e                	jae    801d62 <memmove+0x47>
		s += n;
		d += n;
  801d34:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d37:	89 d6                	mov    %edx,%esi
  801d39:	09 fe                	or     %edi,%esi
  801d3b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d41:	75 13                	jne    801d56 <memmove+0x3b>
  801d43:	f6 c1 03             	test   $0x3,%cl
  801d46:	75 0e                	jne    801d56 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d48:	83 ef 04             	sub    $0x4,%edi
  801d4b:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d4e:	c1 e9 02             	shr    $0x2,%ecx
  801d51:	fd                   	std    
  801d52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d54:	eb 09                	jmp    801d5f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d56:	83 ef 01             	sub    $0x1,%edi
  801d59:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d5c:	fd                   	std    
  801d5d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d5f:	fc                   	cld    
  801d60:	eb 1d                	jmp    801d7f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	09 c2                	or     %eax,%edx
  801d66:	f6 c2 03             	test   $0x3,%dl
  801d69:	75 0f                	jne    801d7a <memmove+0x5f>
  801d6b:	f6 c1 03             	test   $0x3,%cl
  801d6e:	75 0a                	jne    801d7a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d70:	c1 e9 02             	shr    $0x2,%ecx
  801d73:	89 c7                	mov    %eax,%edi
  801d75:	fc                   	cld    
  801d76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d78:	eb 05                	jmp    801d7f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d7a:	89 c7                	mov    %eax,%edi
  801d7c:	fc                   	cld    
  801d7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d86:	ff 75 10             	pushl  0x10(%ebp)
  801d89:	ff 75 0c             	pushl  0xc(%ebp)
  801d8c:	ff 75 08             	pushl  0x8(%ebp)
  801d8f:	e8 87 ff ff ff       	call   801d1b <memmove>
}
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	56                   	push   %esi
  801d9a:	53                   	push   %ebx
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da1:	89 c6                	mov    %eax,%esi
  801da3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801da6:	eb 1a                	jmp    801dc2 <memcmp+0x2c>
		if (*s1 != *s2)
  801da8:	0f b6 08             	movzbl (%eax),%ecx
  801dab:	0f b6 1a             	movzbl (%edx),%ebx
  801dae:	38 d9                	cmp    %bl,%cl
  801db0:	74 0a                	je     801dbc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801db2:	0f b6 c1             	movzbl %cl,%eax
  801db5:	0f b6 db             	movzbl %bl,%ebx
  801db8:	29 d8                	sub    %ebx,%eax
  801dba:	eb 0f                	jmp    801dcb <memcmp+0x35>
		s1++, s2++;
  801dbc:	83 c0 01             	add    $0x1,%eax
  801dbf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dc2:	39 f0                	cmp    %esi,%eax
  801dc4:	75 e2                	jne    801da8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dcb:	5b                   	pop    %ebx
  801dcc:	5e                   	pop    %esi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    

00801dcf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	53                   	push   %ebx
  801dd3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dd6:	89 c1                	mov    %eax,%ecx
  801dd8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801ddb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ddf:	eb 0a                	jmp    801deb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801de1:	0f b6 10             	movzbl (%eax),%edx
  801de4:	39 da                	cmp    %ebx,%edx
  801de6:	74 07                	je     801def <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801de8:	83 c0 01             	add    $0x1,%eax
  801deb:	39 c8                	cmp    %ecx,%eax
  801ded:	72 f2                	jb     801de1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801def:	5b                   	pop    %ebx
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    

00801df2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	57                   	push   %edi
  801df6:	56                   	push   %esi
  801df7:	53                   	push   %ebx
  801df8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dfe:	eb 03                	jmp    801e03 <strtol+0x11>
		s++;
  801e00:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e03:	0f b6 01             	movzbl (%ecx),%eax
  801e06:	3c 20                	cmp    $0x20,%al
  801e08:	74 f6                	je     801e00 <strtol+0xe>
  801e0a:	3c 09                	cmp    $0x9,%al
  801e0c:	74 f2                	je     801e00 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e0e:	3c 2b                	cmp    $0x2b,%al
  801e10:	75 0a                	jne    801e1c <strtol+0x2a>
		s++;
  801e12:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e15:	bf 00 00 00 00       	mov    $0x0,%edi
  801e1a:	eb 11                	jmp    801e2d <strtol+0x3b>
  801e1c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e21:	3c 2d                	cmp    $0x2d,%al
  801e23:	75 08                	jne    801e2d <strtol+0x3b>
		s++, neg = 1;
  801e25:	83 c1 01             	add    $0x1,%ecx
  801e28:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e2d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e33:	75 15                	jne    801e4a <strtol+0x58>
  801e35:	80 39 30             	cmpb   $0x30,(%ecx)
  801e38:	75 10                	jne    801e4a <strtol+0x58>
  801e3a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e3e:	75 7c                	jne    801ebc <strtol+0xca>
		s += 2, base = 16;
  801e40:	83 c1 02             	add    $0x2,%ecx
  801e43:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e48:	eb 16                	jmp    801e60 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e4a:	85 db                	test   %ebx,%ebx
  801e4c:	75 12                	jne    801e60 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e4e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e53:	80 39 30             	cmpb   $0x30,(%ecx)
  801e56:	75 08                	jne    801e60 <strtol+0x6e>
		s++, base = 8;
  801e58:	83 c1 01             	add    $0x1,%ecx
  801e5b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e60:	b8 00 00 00 00       	mov    $0x0,%eax
  801e65:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e68:	0f b6 11             	movzbl (%ecx),%edx
  801e6b:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e6e:	89 f3                	mov    %esi,%ebx
  801e70:	80 fb 09             	cmp    $0x9,%bl
  801e73:	77 08                	ja     801e7d <strtol+0x8b>
			dig = *s - '0';
  801e75:	0f be d2             	movsbl %dl,%edx
  801e78:	83 ea 30             	sub    $0x30,%edx
  801e7b:	eb 22                	jmp    801e9f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e7d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e80:	89 f3                	mov    %esi,%ebx
  801e82:	80 fb 19             	cmp    $0x19,%bl
  801e85:	77 08                	ja     801e8f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e87:	0f be d2             	movsbl %dl,%edx
  801e8a:	83 ea 57             	sub    $0x57,%edx
  801e8d:	eb 10                	jmp    801e9f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e8f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e92:	89 f3                	mov    %esi,%ebx
  801e94:	80 fb 19             	cmp    $0x19,%bl
  801e97:	77 16                	ja     801eaf <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e99:	0f be d2             	movsbl %dl,%edx
  801e9c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e9f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ea2:	7d 0b                	jge    801eaf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ea4:	83 c1 01             	add    $0x1,%ecx
  801ea7:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eab:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ead:	eb b9                	jmp    801e68 <strtol+0x76>

	if (endptr)
  801eaf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eb3:	74 0d                	je     801ec2 <strtol+0xd0>
		*endptr = (char *) s;
  801eb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eb8:	89 0e                	mov    %ecx,(%esi)
  801eba:	eb 06                	jmp    801ec2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ebc:	85 db                	test   %ebx,%ebx
  801ebe:	74 98                	je     801e58 <strtol+0x66>
  801ec0:	eb 9e                	jmp    801e60 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ec2:	89 c2                	mov    %eax,%edx
  801ec4:	f7 da                	neg    %edx
  801ec6:	85 ff                	test   %edi,%edi
  801ec8:	0f 45 c2             	cmovne %edx,%eax
}
  801ecb:	5b                   	pop    %ebx
  801ecc:	5e                   	pop    %esi
  801ecd:	5f                   	pop    %edi
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ed7:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801ede:	75 28                	jne    801f08 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  801ee0:	e8 4d e2 ff ff       	call   800132 <sys_getenvid>
  801ee5:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  801ee7:	83 ec 04             	sub    $0x4,%esp
  801eea:	6a 06                	push   $0x6
  801eec:	68 00 f0 bf ee       	push   $0xeebff000
  801ef1:	50                   	push   %eax
  801ef2:	e8 79 e2 ff ff       	call   800170 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801ef7:	83 c4 08             	add    $0x8,%esp
  801efa:	68 80 03 80 00       	push   $0x800380
  801eff:	53                   	push   %ebx
  801f00:	e8 b6 e3 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801f05:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f08:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0b:	a3 00 70 80 00       	mov    %eax,0x807000
}
  801f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f13:	c9                   	leave  
  801f14:	c3                   	ret    

00801f15 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	56                   	push   %esi
  801f19:	53                   	push   %ebx
  801f1a:	8b 75 08             	mov    0x8(%ebp),%esi
  801f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801f23:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f25:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801f2a:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801f2d:	83 ec 0c             	sub    $0xc,%esp
  801f30:	50                   	push   %eax
  801f31:	e8 ea e3 ff ff       	call   800320 <sys_ipc_recv>

	if (r < 0) {
  801f36:	83 c4 10             	add    $0x10,%esp
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	79 16                	jns    801f53 <ipc_recv+0x3e>
		if (from_env_store)
  801f3d:	85 f6                	test   %esi,%esi
  801f3f:	74 06                	je     801f47 <ipc_recv+0x32>
			*from_env_store = 0;
  801f41:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801f47:	85 db                	test   %ebx,%ebx
  801f49:	74 2c                	je     801f77 <ipc_recv+0x62>
			*perm_store = 0;
  801f4b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f51:	eb 24                	jmp    801f77 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801f53:	85 f6                	test   %esi,%esi
  801f55:	74 0a                	je     801f61 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801f57:	a1 08 40 80 00       	mov    0x804008,%eax
  801f5c:	8b 40 74             	mov    0x74(%eax),%eax
  801f5f:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801f61:	85 db                	test   %ebx,%ebx
  801f63:	74 0a                	je     801f6f <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801f65:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6a:	8b 40 78             	mov    0x78(%eax),%eax
  801f6d:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801f6f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f74:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801f77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 0c             	sub    $0xc,%esp
  801f87:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f90:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f92:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f97:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f9a:	ff 75 14             	pushl  0x14(%ebp)
  801f9d:	53                   	push   %ebx
  801f9e:	56                   	push   %esi
  801f9f:	57                   	push   %edi
  801fa0:	e8 58 e3 ff ff       	call   8002fd <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fab:	75 07                	jne    801fb4 <ipc_send+0x36>
			sys_yield();
  801fad:	e8 9f e1 ff ff       	call   800151 <sys_yield>
  801fb2:	eb e6                	jmp    801f9a <ipc_send+0x1c>
		} else if (r < 0) {
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	79 12                	jns    801fca <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801fb8:	50                   	push   %eax
  801fb9:	68 80 27 80 00       	push   $0x802780
  801fbe:	6a 51                	push   $0x51
  801fc0:	68 8d 27 80 00       	push   $0x80278d
  801fc5:	e8 61 f5 ff ff       	call   80152b <_panic>
		}
	}
}
  801fca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    

00801fd2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fd8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fdd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fe0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe6:	8b 52 50             	mov    0x50(%edx),%edx
  801fe9:	39 ca                	cmp    %ecx,%edx
  801feb:	75 0d                	jne    801ffa <ipc_find_env+0x28>
			return envs[i].env_id;
  801fed:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ff0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ff5:	8b 40 48             	mov    0x48(%eax),%eax
  801ff8:	eb 0f                	jmp    802009 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ffa:	83 c0 01             	add    $0x1,%eax
  801ffd:	3d 00 04 00 00       	cmp    $0x400,%eax
  802002:	75 d9                	jne    801fdd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802004:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    

0080200b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802011:	89 d0                	mov    %edx,%eax
  802013:	c1 e8 16             	shr    $0x16,%eax
  802016:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80201d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802022:	f6 c1 01             	test   $0x1,%cl
  802025:	74 1d                	je     802044 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802027:	c1 ea 0c             	shr    $0xc,%edx
  80202a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802031:	f6 c2 01             	test   $0x1,%dl
  802034:	74 0e                	je     802044 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802036:	c1 ea 0c             	shr    $0xc,%edx
  802039:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802040:	ef 
  802041:	0f b7 c0             	movzwl %ax,%eax
}
  802044:	5d                   	pop    %ebp
  802045:	c3                   	ret    
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80205b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80205f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 f6                	test   %esi,%esi
  802069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80206d:	89 ca                	mov    %ecx,%edx
  80206f:	89 f8                	mov    %edi,%eax
  802071:	75 3d                	jne    8020b0 <__udivdi3+0x60>
  802073:	39 cf                	cmp    %ecx,%edi
  802075:	0f 87 c5 00 00 00    	ja     802140 <__udivdi3+0xf0>
  80207b:	85 ff                	test   %edi,%edi
  80207d:	89 fd                	mov    %edi,%ebp
  80207f:	75 0b                	jne    80208c <__udivdi3+0x3c>
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	31 d2                	xor    %edx,%edx
  802088:	f7 f7                	div    %edi
  80208a:	89 c5                	mov    %eax,%ebp
  80208c:	89 c8                	mov    %ecx,%eax
  80208e:	31 d2                	xor    %edx,%edx
  802090:	f7 f5                	div    %ebp
  802092:	89 c1                	mov    %eax,%ecx
  802094:	89 d8                	mov    %ebx,%eax
  802096:	89 cf                	mov    %ecx,%edi
  802098:	f7 f5                	div    %ebp
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	39 ce                	cmp    %ecx,%esi
  8020b2:	77 74                	ja     802128 <__udivdi3+0xd8>
  8020b4:	0f bd fe             	bsr    %esi,%edi
  8020b7:	83 f7 1f             	xor    $0x1f,%edi
  8020ba:	0f 84 98 00 00 00    	je     802158 <__udivdi3+0x108>
  8020c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	89 c5                	mov    %eax,%ebp
  8020c9:	29 fb                	sub    %edi,%ebx
  8020cb:	d3 e6                	shl    %cl,%esi
  8020cd:	89 d9                	mov    %ebx,%ecx
  8020cf:	d3 ed                	shr    %cl,%ebp
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e0                	shl    %cl,%eax
  8020d5:	09 ee                	or     %ebp,%esi
  8020d7:	89 d9                	mov    %ebx,%ecx
  8020d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020dd:	89 d5                	mov    %edx,%ebp
  8020df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020e3:	d3 ed                	shr    %cl,%ebp
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e2                	shl    %cl,%edx
  8020e9:	89 d9                	mov    %ebx,%ecx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	09 c2                	or     %eax,%edx
  8020ef:	89 d0                	mov    %edx,%eax
  8020f1:	89 ea                	mov    %ebp,%edx
  8020f3:	f7 f6                	div    %esi
  8020f5:	89 d5                	mov    %edx,%ebp
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	f7 64 24 0c          	mull   0xc(%esp)
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	72 10                	jb     802111 <__udivdi3+0xc1>
  802101:	8b 74 24 08          	mov    0x8(%esp),%esi
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e6                	shl    %cl,%esi
  802109:	39 c6                	cmp    %eax,%esi
  80210b:	73 07                	jae    802114 <__udivdi3+0xc4>
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	75 03                	jne    802114 <__udivdi3+0xc4>
  802111:	83 eb 01             	sub    $0x1,%ebx
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 d8                	mov    %ebx,%eax
  802118:	89 fa                	mov    %edi,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	31 ff                	xor    %edi,%edi
  80212a:	31 db                	xor    %ebx,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 d8                	mov    %ebx,%eax
  802142:	f7 f7                	div    %edi
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 c3                	mov    %eax,%ebx
  802148:	89 d8                	mov    %ebx,%eax
  80214a:	89 fa                	mov    %edi,%edx
  80214c:	83 c4 1c             	add    $0x1c,%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5f                   	pop    %edi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	39 ce                	cmp    %ecx,%esi
  80215a:	72 0c                	jb     802168 <__udivdi3+0x118>
  80215c:	31 db                	xor    %ebx,%ebx
  80215e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802162:	0f 87 34 ff ff ff    	ja     80209c <__udivdi3+0x4c>
  802168:	bb 01 00 00 00       	mov    $0x1,%ebx
  80216d:	e9 2a ff ff ff       	jmp    80209c <__udivdi3+0x4c>
  802172:	66 90                	xchg   %ax,%ax
  802174:	66 90                	xchg   %ax,%ax
  802176:	66 90                	xchg   %ax,%ax
  802178:	66 90                	xchg   %ax,%ax
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80218b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80218f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 d2                	test   %edx,%edx
  802199:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80219d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021a1:	89 f3                	mov    %esi,%ebx
  8021a3:	89 3c 24             	mov    %edi,(%esp)
  8021a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021aa:	75 1c                	jne    8021c8 <__umoddi3+0x48>
  8021ac:	39 f7                	cmp    %esi,%edi
  8021ae:	76 50                	jbe    802200 <__umoddi3+0x80>
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	f7 f7                	div    %edi
  8021b6:	89 d0                	mov    %edx,%eax
  8021b8:	31 d2                	xor    %edx,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	89 d0                	mov    %edx,%eax
  8021cc:	77 52                	ja     802220 <__umoddi3+0xa0>
  8021ce:	0f bd ea             	bsr    %edx,%ebp
  8021d1:	83 f5 1f             	xor    $0x1f,%ebp
  8021d4:	75 5a                	jne    802230 <__umoddi3+0xb0>
  8021d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021da:	0f 82 e0 00 00 00    	jb     8022c0 <__umoddi3+0x140>
  8021e0:	39 0c 24             	cmp    %ecx,(%esp)
  8021e3:	0f 86 d7 00 00 00    	jbe    8022c0 <__umoddi3+0x140>
  8021e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021f1:	83 c4 1c             	add    $0x1c,%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	85 ff                	test   %edi,%edi
  802202:	89 fd                	mov    %edi,%ebp
  802204:	75 0b                	jne    802211 <__umoddi3+0x91>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f7                	div    %edi
  80220f:	89 c5                	mov    %eax,%ebp
  802211:	89 f0                	mov    %esi,%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	f7 f5                	div    %ebp
  802217:	89 c8                	mov    %ecx,%eax
  802219:	f7 f5                	div    %ebp
  80221b:	89 d0                	mov    %edx,%eax
  80221d:	eb 99                	jmp    8021b8 <__umoddi3+0x38>
  80221f:	90                   	nop
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	83 c4 1c             	add    $0x1c,%esp
  802227:	5b                   	pop    %ebx
  802228:	5e                   	pop    %esi
  802229:	5f                   	pop    %edi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	8b 34 24             	mov    (%esp),%esi
  802233:	bf 20 00 00 00       	mov    $0x20,%edi
  802238:	89 e9                	mov    %ebp,%ecx
  80223a:	29 ef                	sub    %ebp,%edi
  80223c:	d3 e0                	shl    %cl,%eax
  80223e:	89 f9                	mov    %edi,%ecx
  802240:	89 f2                	mov    %esi,%edx
  802242:	d3 ea                	shr    %cl,%edx
  802244:	89 e9                	mov    %ebp,%ecx
  802246:	09 c2                	or     %eax,%edx
  802248:	89 d8                	mov    %ebx,%eax
  80224a:	89 14 24             	mov    %edx,(%esp)
  80224d:	89 f2                	mov    %esi,%edx
  80224f:	d3 e2                	shl    %cl,%edx
  802251:	89 f9                	mov    %edi,%ecx
  802253:	89 54 24 04          	mov    %edx,0x4(%esp)
  802257:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	89 e9                	mov    %ebp,%ecx
  80225f:	89 c6                	mov    %eax,%esi
  802261:	d3 e3                	shl    %cl,%ebx
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 d0                	mov    %edx,%eax
  802267:	d3 e8                	shr    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	09 d8                	or     %ebx,%eax
  80226d:	89 d3                	mov    %edx,%ebx
  80226f:	89 f2                	mov    %esi,%edx
  802271:	f7 34 24             	divl   (%esp)
  802274:	89 d6                	mov    %edx,%esi
  802276:	d3 e3                	shl    %cl,%ebx
  802278:	f7 64 24 04          	mull   0x4(%esp)
  80227c:	39 d6                	cmp    %edx,%esi
  80227e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802282:	89 d1                	mov    %edx,%ecx
  802284:	89 c3                	mov    %eax,%ebx
  802286:	72 08                	jb     802290 <__umoddi3+0x110>
  802288:	75 11                	jne    80229b <__umoddi3+0x11b>
  80228a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80228e:	73 0b                	jae    80229b <__umoddi3+0x11b>
  802290:	2b 44 24 04          	sub    0x4(%esp),%eax
  802294:	1b 14 24             	sbb    (%esp),%edx
  802297:	89 d1                	mov    %edx,%ecx
  802299:	89 c3                	mov    %eax,%ebx
  80229b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80229f:	29 da                	sub    %ebx,%edx
  8022a1:	19 ce                	sbb    %ecx,%esi
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 f0                	mov    %esi,%eax
  8022a7:	d3 e0                	shl    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	d3 ea                	shr    %cl,%edx
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	d3 ee                	shr    %cl,%esi
  8022b1:	09 d0                	or     %edx,%eax
  8022b3:	89 f2                	mov    %esi,%edx
  8022b5:	83 c4 1c             	add    $0x1c,%esp
  8022b8:	5b                   	pop    %ebx
  8022b9:	5e                   	pop    %esi
  8022ba:	5f                   	pop    %edi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    
  8022bd:	8d 76 00             	lea    0x0(%esi),%esi
  8022c0:	29 f9                	sub    %edi,%ecx
  8022c2:	19 d6                	sbb    %edx,%esi
  8022c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022cc:	e9 18 ff ff ff       	jmp    8021e9 <__umoddi3+0x69>
