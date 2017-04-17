
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 a6 04 00 00       	call   800541 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 6a 22 80 00       	push   $0x80226a
  800114:	6a 23                	push   $0x23
  800116:	68 87 22 80 00       	push   $0x802287
  80011b:	e8 d0 13 00 00       	call   8014f0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 6a 22 80 00       	push   $0x80226a
  800195:	6a 23                	push   $0x23
  800197:	68 87 22 80 00       	push   $0x802287
  80019c:	e8 4f 13 00 00       	call   8014f0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 6a 22 80 00       	push   $0x80226a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 87 22 80 00       	push   $0x802287
  8001de:	e8 0d 13 00 00       	call   8014f0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 6a 22 80 00       	push   $0x80226a
  800219:	6a 23                	push   $0x23
  80021b:	68 87 22 80 00       	push   $0x802287
  800220:	e8 cb 12 00 00       	call   8014f0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 6a 22 80 00       	push   $0x80226a
  80025b:	6a 23                	push   $0x23
  80025d:	68 87 22 80 00       	push   $0x802287
  800262:	e8 89 12 00 00       	call   8014f0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 6a 22 80 00       	push   $0x80226a
  80029d:	6a 23                	push   $0x23
  80029f:	68 87 22 80 00       	push   $0x802287
  8002a4:	e8 47 12 00 00       	call   8014f0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 6a 22 80 00       	push   $0x80226a
  8002df:	6a 23                	push   $0x23
  8002e1:	68 87 22 80 00       	push   $0x802287
  8002e6:	e8 05 12 00 00       	call   8014f0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 6a 22 80 00       	push   $0x80226a
  800343:	6a 23                	push   $0x23
  800345:	68 87 22 80 00       	push   $0x802287
  80034a:	e8 a1 11 00 00       	call   8014f0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	b8 0e 00 00 00       	mov    $0xe,%eax
  800367:	89 d1                	mov    %edx,%ecx
  800369:	89 d3                	mov    %edx,%ebx
  80036b:	89 d7                	mov    %edx,%edi
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	05 00 00 00 30       	add    $0x30000000,%eax
  800381:	c1 e8 0c             	shr    $0xc,%eax
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	05 00 00 00 30       	add    $0x30000000,%eax
  800391:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800396:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 ea 16             	shr    $0x16,%edx
  8003ad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b4:	f6 c2 01             	test   $0x1,%dl
  8003b7:	74 11                	je     8003ca <fd_alloc+0x2d>
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	c1 ea 0c             	shr    $0xc,%edx
  8003be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c5:	f6 c2 01             	test   $0x1,%dl
  8003c8:	75 09                	jne    8003d3 <fd_alloc+0x36>
			*fd_store = fd;
  8003ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d1:	eb 17                	jmp    8003ea <fd_alloc+0x4d>
  8003d3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003dd:	75 c9                	jne    8003a8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f2:	83 f8 1f             	cmp    $0x1f,%eax
  8003f5:	77 36                	ja     80042d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f7:	c1 e0 0c             	shl    $0xc,%eax
  8003fa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 16             	shr    $0x16,%edx
  800404:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 24                	je     800434 <fd_lookup+0x48>
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 0c             	shr    $0xc,%edx
  800415:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	74 1a                	je     80043b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 02                	mov    %eax,(%edx)
	return 0;
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	eb 13                	jmp    800440 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800432:	eb 0c                	jmp    800440 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800439:	eb 05                	jmp    800440 <fd_lookup+0x54>
  80043b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044b:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800450:	eb 13                	jmp    800465 <dev_lookup+0x23>
  800452:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800455:	39 08                	cmp    %ecx,(%eax)
  800457:	75 0c                	jne    800465 <dev_lookup+0x23>
			*dev = devtab[i];
  800459:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
  800463:	eb 2e                	jmp    800493 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	85 c0                	test   %eax,%eax
  800469:	75 e7                	jne    800452 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80046b:	a1 08 40 80 00       	mov    0x804008,%eax
  800470:	8b 40 48             	mov    0x48(%eax),%eax
  800473:	83 ec 04             	sub    $0x4,%esp
  800476:	51                   	push   %ecx
  800477:	50                   	push   %eax
  800478:	68 98 22 80 00       	push   $0x802298
  80047d:	e8 47 11 00 00       	call   8015c9 <cprintf>
	*dev = 0;
  800482:	8b 45 0c             	mov    0xc(%ebp),%eax
  800485:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800493:	c9                   	leave  
  800494:	c3                   	ret    

00800495 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 10             	sub    $0x10,%esp
  80049d:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a6:	50                   	push   %eax
  8004a7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ad:	c1 e8 0c             	shr    $0xc,%eax
  8004b0:	50                   	push   %eax
  8004b1:	e8 36 ff ff ff       	call   8003ec <fd_lookup>
  8004b6:	83 c4 08             	add    $0x8,%esp
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	78 05                	js     8004c2 <fd_close+0x2d>
	    || fd != fd2)
  8004bd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004c0:	74 0c                	je     8004ce <fd_close+0x39>
		return (must_exist ? r : 0);
  8004c2:	84 db                	test   %bl,%bl
  8004c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c9:	0f 44 c2             	cmove  %edx,%eax
  8004cc:	eb 41                	jmp    80050f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d4:	50                   	push   %eax
  8004d5:	ff 36                	pushl  (%esi)
  8004d7:	e8 66 ff ff ff       	call   800442 <dev_lookup>
  8004dc:	89 c3                	mov    %eax,%ebx
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	85 c0                	test   %eax,%eax
  8004e3:	78 1a                	js     8004ff <fd_close+0x6a>
		if (dev->dev_close)
  8004e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	74 0b                	je     8004ff <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f4:	83 ec 0c             	sub    $0xc,%esp
  8004f7:	56                   	push   %esi
  8004f8:	ff d0                	call   *%eax
  8004fa:	89 c3                	mov    %eax,%ebx
  8004fc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	56                   	push   %esi
  800503:	6a 00                	push   $0x0
  800505:	e8 e1 fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	89 d8                	mov    %ebx,%eax
}
  80050f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800512:	5b                   	pop    %ebx
  800513:	5e                   	pop    %esi
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80051c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051f:	50                   	push   %eax
  800520:	ff 75 08             	pushl  0x8(%ebp)
  800523:	e8 c4 fe ff ff       	call   8003ec <fd_lookup>
  800528:	83 c4 08             	add    $0x8,%esp
  80052b:	85 c0                	test   %eax,%eax
  80052d:	78 10                	js     80053f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	6a 01                	push   $0x1
  800534:	ff 75 f4             	pushl  -0xc(%ebp)
  800537:	e8 59 ff ff ff       	call   800495 <fd_close>
  80053c:	83 c4 10             	add    $0x10,%esp
}
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <close_all>:

void
close_all(void)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	53                   	push   %ebx
  800545:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800548:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80054d:	83 ec 0c             	sub    $0xc,%esp
  800550:	53                   	push   %ebx
  800551:	e8 c0 ff ff ff       	call   800516 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800556:	83 c3 01             	add    $0x1,%ebx
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	83 fb 20             	cmp    $0x20,%ebx
  80055f:	75 ec                	jne    80054d <close_all+0xc>
		close(i);
}
  800561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800564:	c9                   	leave  
  800565:	c3                   	ret    

00800566 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800566:	55                   	push   %ebp
  800567:	89 e5                	mov    %esp,%ebp
  800569:	57                   	push   %edi
  80056a:	56                   	push   %esi
  80056b:	53                   	push   %ebx
  80056c:	83 ec 2c             	sub    $0x2c,%esp
  80056f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800572:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800575:	50                   	push   %eax
  800576:	ff 75 08             	pushl  0x8(%ebp)
  800579:	e8 6e fe ff ff       	call   8003ec <fd_lookup>
  80057e:	83 c4 08             	add    $0x8,%esp
  800581:	85 c0                	test   %eax,%eax
  800583:	0f 88 c1 00 00 00    	js     80064a <dup+0xe4>
		return r;
	close(newfdnum);
  800589:	83 ec 0c             	sub    $0xc,%esp
  80058c:	56                   	push   %esi
  80058d:	e8 84 ff ff ff       	call   800516 <close>

	newfd = INDEX2FD(newfdnum);
  800592:	89 f3                	mov    %esi,%ebx
  800594:	c1 e3 0c             	shl    $0xc,%ebx
  800597:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80059d:	83 c4 04             	add    $0x4,%esp
  8005a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a3:	e8 de fd ff ff       	call   800386 <fd2data>
  8005a8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005aa:	89 1c 24             	mov    %ebx,(%esp)
  8005ad:	e8 d4 fd ff ff       	call   800386 <fd2data>
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b8:	89 f8                	mov    %edi,%eax
  8005ba:	c1 e8 16             	shr    $0x16,%eax
  8005bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c4:	a8 01                	test   $0x1,%al
  8005c6:	74 37                	je     8005ff <dup+0x99>
  8005c8:	89 f8                	mov    %edi,%eax
  8005ca:	c1 e8 0c             	shr    $0xc,%eax
  8005cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d4:	f6 c2 01             	test   $0x1,%dl
  8005d7:	74 26                	je     8005ff <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e8:	50                   	push   %eax
  8005e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ec:	6a 00                	push   $0x0
  8005ee:	57                   	push   %edi
  8005ef:	6a 00                	push   $0x0
  8005f1:	e8 b3 fb ff ff       	call   8001a9 <sys_page_map>
  8005f6:	89 c7                	mov    %eax,%edi
  8005f8:	83 c4 20             	add    $0x20,%esp
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	78 2e                	js     80062d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800602:	89 d0                	mov    %edx,%eax
  800604:	c1 e8 0c             	shr    $0xc,%eax
  800607:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060e:	83 ec 0c             	sub    $0xc,%esp
  800611:	25 07 0e 00 00       	and    $0xe07,%eax
  800616:	50                   	push   %eax
  800617:	53                   	push   %ebx
  800618:	6a 00                	push   $0x0
  80061a:	52                   	push   %edx
  80061b:	6a 00                	push   $0x0
  80061d:	e8 87 fb ff ff       	call   8001a9 <sys_page_map>
  800622:	89 c7                	mov    %eax,%edi
  800624:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800627:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800629:	85 ff                	test   %edi,%edi
  80062b:	79 1d                	jns    80064a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 00                	push   $0x0
  800633:	e8 b3 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063e:	6a 00                	push   $0x0
  800640:	e8 a6 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	89 f8                	mov    %edi,%eax
}
  80064a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	53                   	push   %ebx
  800656:	83 ec 14             	sub    $0x14,%esp
  800659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80065c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	53                   	push   %ebx
  800661:	e8 86 fd ff ff       	call   8003ec <fd_lookup>
  800666:	83 c4 08             	add    $0x8,%esp
  800669:	89 c2                	mov    %eax,%edx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	78 6d                	js     8006dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800675:	50                   	push   %eax
  800676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800679:	ff 30                	pushl  (%eax)
  80067b:	e8 c2 fd ff ff       	call   800442 <dev_lookup>
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	78 4c                	js     8006d3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800687:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068a:	8b 42 08             	mov    0x8(%edx),%eax
  80068d:	83 e0 03             	and    $0x3,%eax
  800690:	83 f8 01             	cmp    $0x1,%eax
  800693:	75 21                	jne    8006b6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800695:	a1 08 40 80 00       	mov    0x804008,%eax
  80069a:	8b 40 48             	mov    0x48(%eax),%eax
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	50                   	push   %eax
  8006a2:	68 d9 22 80 00       	push   $0x8022d9
  8006a7:	e8 1d 0f 00 00       	call   8015c9 <cprintf>
		return -E_INVAL;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b4:	eb 26                	jmp    8006dc <read+0x8a>
	}
	if (!dev->dev_read)
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	8b 40 08             	mov    0x8(%eax),%eax
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	74 17                	je     8006d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	ff 75 10             	pushl  0x10(%ebp)
  8006c6:	ff 75 0c             	pushl  0xc(%ebp)
  8006c9:	52                   	push   %edx
  8006ca:	ff d0                	call   *%eax
  8006cc:	89 c2                	mov    %eax,%edx
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 09                	jmp    8006dc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d3:	89 c2                	mov    %eax,%edx
  8006d5:	eb 05                	jmp    8006dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006dc:	89 d0                	mov    %edx,%eax
  8006de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	57                   	push   %edi
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 0c             	sub    $0xc,%esp
  8006ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f7:	eb 21                	jmp    80071a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f9:	83 ec 04             	sub    $0x4,%esp
  8006fc:	89 f0                	mov    %esi,%eax
  8006fe:	29 d8                	sub    %ebx,%eax
  800700:	50                   	push   %eax
  800701:	89 d8                	mov    %ebx,%eax
  800703:	03 45 0c             	add    0xc(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	57                   	push   %edi
  800708:	e8 45 ff ff ff       	call   800652 <read>
		if (m < 0)
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	85 c0                	test   %eax,%eax
  800712:	78 10                	js     800724 <readn+0x41>
			return m;
		if (m == 0)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 0a                	je     800722 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800718:	01 c3                	add    %eax,%ebx
  80071a:	39 f3                	cmp    %esi,%ebx
  80071c:	72 db                	jb     8006f9 <readn+0x16>
  80071e:	89 d8                	mov    %ebx,%eax
  800720:	eb 02                	jmp    800724 <readn+0x41>
  800722:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800724:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800727:	5b                   	pop    %ebx
  800728:	5e                   	pop    %esi
  800729:	5f                   	pop    %edi
  80072a:	5d                   	pop    %ebp
  80072b:	c3                   	ret    

0080072c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	53                   	push   %ebx
  800730:	83 ec 14             	sub    $0x14,%esp
  800733:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800736:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	53                   	push   %ebx
  80073b:	e8 ac fc ff ff       	call   8003ec <fd_lookup>
  800740:	83 c4 08             	add    $0x8,%esp
  800743:	89 c2                	mov    %eax,%edx
  800745:	85 c0                	test   %eax,%eax
  800747:	78 68                	js     8007b1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074f:	50                   	push   %eax
  800750:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800753:	ff 30                	pushl  (%eax)
  800755:	e8 e8 fc ff ff       	call   800442 <dev_lookup>
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	85 c0                	test   %eax,%eax
  80075f:	78 47                	js     8007a8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800761:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800764:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800768:	75 21                	jne    80078b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076a:	a1 08 40 80 00       	mov    0x804008,%eax
  80076f:	8b 40 48             	mov    0x48(%eax),%eax
  800772:	83 ec 04             	sub    $0x4,%esp
  800775:	53                   	push   %ebx
  800776:	50                   	push   %eax
  800777:	68 f5 22 80 00       	push   $0x8022f5
  80077c:	e8 48 0e 00 00       	call   8015c9 <cprintf>
		return -E_INVAL;
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800789:	eb 26                	jmp    8007b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078e:	8b 52 0c             	mov    0xc(%edx),%edx
  800791:	85 d2                	test   %edx,%edx
  800793:	74 17                	je     8007ac <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800795:	83 ec 04             	sub    $0x4,%esp
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	ff 75 0c             	pushl  0xc(%ebp)
  80079e:	50                   	push   %eax
  80079f:	ff d2                	call   *%edx
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c4 10             	add    $0x10,%esp
  8007a6:	eb 09                	jmp    8007b1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a8:	89 c2                	mov    %eax,%edx
  8007aa:	eb 05                	jmp    8007b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007b1:	89 d0                	mov    %edx,%eax
  8007b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c1:	50                   	push   %eax
  8007c2:	ff 75 08             	pushl  0x8(%ebp)
  8007c5:	e8 22 fc ff ff       	call   8003ec <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 0e                	js     8007df <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 14             	sub    $0x14,%esp
  8007e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ee:	50                   	push   %eax
  8007ef:	53                   	push   %ebx
  8007f0:	e8 f7 fb ff ff       	call   8003ec <fd_lookup>
  8007f5:	83 c4 08             	add    $0x8,%esp
  8007f8:	89 c2                	mov    %eax,%edx
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	78 65                	js     800863 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800804:	50                   	push   %eax
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	ff 30                	pushl  (%eax)
  80080a:	e8 33 fc ff ff       	call   800442 <dev_lookup>
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	85 c0                	test   %eax,%eax
  800814:	78 44                	js     80085a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800816:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800819:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081d:	75 21                	jne    800840 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800824:	8b 40 48             	mov    0x48(%eax),%eax
  800827:	83 ec 04             	sub    $0x4,%esp
  80082a:	53                   	push   %ebx
  80082b:	50                   	push   %eax
  80082c:	68 b8 22 80 00       	push   $0x8022b8
  800831:	e8 93 0d 00 00       	call   8015c9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083e:	eb 23                	jmp    800863 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800840:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800843:	8b 52 18             	mov    0x18(%edx),%edx
  800846:	85 d2                	test   %edx,%edx
  800848:	74 14                	je     80085e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	50                   	push   %eax
  800851:	ff d2                	call   *%edx
  800853:	89 c2                	mov    %eax,%edx
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	eb 09                	jmp    800863 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	89 c2                	mov    %eax,%edx
  80085c:	eb 05                	jmp    800863 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800863:	89 d0                	mov    %edx,%eax
  800865:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800868:	c9                   	leave  
  800869:	c3                   	ret    

0080086a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	83 ec 14             	sub    $0x14,%esp
  800871:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800874:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800877:	50                   	push   %eax
  800878:	ff 75 08             	pushl  0x8(%ebp)
  80087b:	e8 6c fb ff ff       	call   8003ec <fd_lookup>
  800880:	83 c4 08             	add    $0x8,%esp
  800883:	89 c2                	mov    %eax,%edx
  800885:	85 c0                	test   %eax,%eax
  800887:	78 58                	js     8008e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088f:	50                   	push   %eax
  800890:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800893:	ff 30                	pushl  (%eax)
  800895:	e8 a8 fb ff ff       	call   800442 <dev_lookup>
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	85 c0                	test   %eax,%eax
  80089f:	78 37                	js     8008d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a8:	74 32                	je     8008dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b4:	00 00 00 
	stat->st_isdir = 0;
  8008b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008be:	00 00 00 
	stat->st_dev = dev;
  8008c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	53                   	push   %ebx
  8008cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ce:	ff 50 14             	call   *0x14(%eax)
  8008d1:	89 c2                	mov    %eax,%edx
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	eb 09                	jmp    8008e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d8:	89 c2                	mov    %eax,%edx
  8008da:	eb 05                	jmp    8008e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e1:	89 d0                	mov    %edx,%eax
  8008e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	6a 00                	push   $0x0
  8008f2:	ff 75 08             	pushl  0x8(%ebp)
  8008f5:	e8 0c 02 00 00       	call   800b06 <open>
  8008fa:	89 c3                	mov    %eax,%ebx
  8008fc:	83 c4 10             	add    $0x10,%esp
  8008ff:	85 c0                	test   %eax,%eax
  800901:	78 1b                	js     80091e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800903:	83 ec 08             	sub    $0x8,%esp
  800906:	ff 75 0c             	pushl  0xc(%ebp)
  800909:	50                   	push   %eax
  80090a:	e8 5b ff ff ff       	call   80086a <fstat>
  80090f:	89 c6                	mov    %eax,%esi
	close(fd);
  800911:	89 1c 24             	mov    %ebx,(%esp)
  800914:	e8 fd fb ff ff       	call   800516 <close>
	return r;
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	89 f0                	mov    %esi,%eax
}
  80091e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	89 c6                	mov    %eax,%esi
  80092c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800935:	75 12                	jne    800949 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800937:	83 ec 0c             	sub    $0xc,%esp
  80093a:	6a 01                	push   $0x1
  80093c:	e8 11 16 00 00       	call   801f52 <ipc_find_env>
  800941:	a3 00 40 80 00       	mov    %eax,0x804000
  800946:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800949:	6a 07                	push   $0x7
  80094b:	68 00 50 80 00       	push   $0x805000
  800950:	56                   	push   %esi
  800951:	ff 35 00 40 80 00    	pushl  0x804000
  800957:	e8 a2 15 00 00       	call   801efe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80095c:	83 c4 0c             	add    $0xc,%esp
  80095f:	6a 00                	push   $0x0
  800961:	53                   	push   %ebx
  800962:	6a 00                	push   $0x0
  800964:	e8 2c 15 00 00       	call   801e95 <ipc_recv>
}
  800969:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 40 0c             	mov    0xc(%eax),%eax
  80097c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
  800984:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 02 00 00 00       	mov    $0x2,%eax
  800993:	e8 8d ff ff ff       	call   800925 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b5:	e8 6b ff ff ff       	call   800925 <fsipc>
}
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	83 ec 04             	sub    $0x4,%esp
  8009c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009db:	e8 45 ff ff ff       	call   800925 <fsipc>
  8009e0:	85 c0                	test   %eax,%eax
  8009e2:	78 2c                	js     800a10 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e4:	83 ec 08             	sub    $0x8,%esp
  8009e7:	68 00 50 80 00       	push   $0x805000
  8009ec:	53                   	push   %ebx
  8009ed:	e8 5c 11 00 00       	call   801b4e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009fd:	a1 84 50 80 00       	mov    0x805084,%eax
  800a02:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a08:	83 c4 10             	add    $0x10,%esp
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	53                   	push   %ebx
  800a19:	83 ec 08             	sub    $0x8,%esp
  800a1c:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a22:	8b 52 0c             	mov    0xc(%edx),%edx
  800a25:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a2b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a30:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a35:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a38:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a3e:	53                   	push   %ebx
  800a3f:	ff 75 0c             	pushl  0xc(%ebp)
  800a42:	68 08 50 80 00       	push   $0x805008
  800a47:	e8 94 12 00 00       	call   801ce0 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a51:	b8 04 00 00 00       	mov    $0x4,%eax
  800a56:	e8 ca fe ff ff       	call   800925 <fsipc>
  800a5b:	83 c4 10             	add    $0x10,%esp
  800a5e:	85 c0                	test   %eax,%eax
  800a60:	78 1d                	js     800a7f <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  800a62:	39 d8                	cmp    %ebx,%eax
  800a64:	76 19                	jbe    800a7f <devfile_write+0x6a>
  800a66:	68 28 23 80 00       	push   $0x802328
  800a6b:	68 34 23 80 00       	push   $0x802334
  800a70:	68 a3 00 00 00       	push   $0xa3
  800a75:	68 49 23 80 00       	push   $0x802349
  800a7a:	e8 71 0a 00 00       	call   8014f0 <_panic>
	return r;
}
  800a7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a92:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a97:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa2:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa7:	e8 79 fe ff ff       	call   800925 <fsipc>
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	85 c0                	test   %eax,%eax
  800ab0:	78 4b                	js     800afd <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab2:	39 c6                	cmp    %eax,%esi
  800ab4:	73 16                	jae    800acc <devfile_read+0x48>
  800ab6:	68 54 23 80 00       	push   $0x802354
  800abb:	68 34 23 80 00       	push   $0x802334
  800ac0:	6a 7c                	push   $0x7c
  800ac2:	68 49 23 80 00       	push   $0x802349
  800ac7:	e8 24 0a 00 00       	call   8014f0 <_panic>
	assert(r <= PGSIZE);
  800acc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad1:	7e 16                	jle    800ae9 <devfile_read+0x65>
  800ad3:	68 5b 23 80 00       	push   $0x80235b
  800ad8:	68 34 23 80 00       	push   $0x802334
  800add:	6a 7d                	push   $0x7d
  800adf:	68 49 23 80 00       	push   $0x802349
  800ae4:	e8 07 0a 00 00       	call   8014f0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae9:	83 ec 04             	sub    $0x4,%esp
  800aec:	50                   	push   %eax
  800aed:	68 00 50 80 00       	push   $0x805000
  800af2:	ff 75 0c             	pushl  0xc(%ebp)
  800af5:	e8 e6 11 00 00       	call   801ce0 <memmove>
	return r;
  800afa:	83 c4 10             	add    $0x10,%esp
}
  800afd:	89 d8                	mov    %ebx,%eax
  800aff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 20             	sub    $0x20,%esp
  800b0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b10:	53                   	push   %ebx
  800b11:	e8 ff 0f 00 00       	call   801b15 <strlen>
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1e:	7f 67                	jg     800b87 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b26:	50                   	push   %eax
  800b27:	e8 71 f8 ff ff       	call   80039d <fd_alloc>
  800b2c:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	78 57                	js     800b8c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b35:	83 ec 08             	sub    $0x8,%esp
  800b38:	53                   	push   %ebx
  800b39:	68 00 50 80 00       	push   $0x805000
  800b3e:	e8 0b 10 00 00       	call   801b4e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b53:	e8 cd fd ff ff       	call   800925 <fsipc>
  800b58:	89 c3                	mov    %eax,%ebx
  800b5a:	83 c4 10             	add    $0x10,%esp
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	79 14                	jns    800b75 <open+0x6f>
		fd_close(fd, 0);
  800b61:	83 ec 08             	sub    $0x8,%esp
  800b64:	6a 00                	push   $0x0
  800b66:	ff 75 f4             	pushl  -0xc(%ebp)
  800b69:	e8 27 f9 ff ff       	call   800495 <fd_close>
		return r;
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	89 da                	mov    %ebx,%edx
  800b73:	eb 17                	jmp    800b8c <open+0x86>
	}

	return fd2num(fd);
  800b75:	83 ec 0c             	sub    $0xc,%esp
  800b78:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7b:	e8 f6 f7 ff ff       	call   800376 <fd2num>
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	83 c4 10             	add    $0x10,%esp
  800b85:	eb 05                	jmp    800b8c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b87:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b8c:	89 d0                	mov    %edx,%eax
  800b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b99:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9e:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba3:	e8 7d fd ff ff       	call   800925 <fsipc>
}
  800ba8:	c9                   	leave  
  800ba9:	c3                   	ret    

00800baa <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bb0:	68 67 23 80 00       	push   $0x802367
  800bb5:	ff 75 0c             	pushl  0xc(%ebp)
  800bb8:	e8 91 0f 00 00       	call   801b4e <strcpy>
	return 0;
}
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 10             	sub    $0x10,%esp
  800bcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bce:	53                   	push   %ebx
  800bcf:	e8 b7 13 00 00       	call   801f8b <pageref>
  800bd4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bdc:	83 f8 01             	cmp    $0x1,%eax
  800bdf:	75 10                	jne    800bf1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	ff 73 0c             	pushl  0xc(%ebx)
  800be7:	e8 c0 02 00 00       	call   800eac <nsipc_close>
  800bec:	89 c2                	mov    %eax,%edx
  800bee:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bf1:	89 d0                	mov    %edx,%eax
  800bf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bfe:	6a 00                	push   $0x0
  800c00:	ff 75 10             	pushl  0x10(%ebp)
  800c03:	ff 75 0c             	pushl  0xc(%ebp)
  800c06:	8b 45 08             	mov    0x8(%ebp),%eax
  800c09:	ff 70 0c             	pushl  0xc(%eax)
  800c0c:	e8 78 03 00 00       	call   800f89 <nsipc_send>
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c19:	6a 00                	push   $0x0
  800c1b:	ff 75 10             	pushl  0x10(%ebp)
  800c1e:	ff 75 0c             	pushl  0xc(%ebp)
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
  800c24:	ff 70 0c             	pushl  0xc(%eax)
  800c27:	e8 f1 02 00 00       	call   800f1d <nsipc_recv>
}
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c34:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c37:	52                   	push   %edx
  800c38:	50                   	push   %eax
  800c39:	e8 ae f7 ff ff       	call   8003ec <fd_lookup>
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	85 c0                	test   %eax,%eax
  800c43:	78 17                	js     800c5c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c48:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c4e:	39 08                	cmp    %ecx,(%eax)
  800c50:	75 05                	jne    800c57 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c52:	8b 40 0c             	mov    0xc(%eax),%eax
  800c55:	eb 05                	jmp    800c5c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c57:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c5c:	c9                   	leave  
  800c5d:	c3                   	ret    

00800c5e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 1c             	sub    $0x1c,%esp
  800c66:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c6b:	50                   	push   %eax
  800c6c:	e8 2c f7 ff ff       	call   80039d <fd_alloc>
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	85 c0                	test   %eax,%eax
  800c78:	78 1b                	js     800c95 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c7a:	83 ec 04             	sub    $0x4,%esp
  800c7d:	68 07 04 00 00       	push   $0x407
  800c82:	ff 75 f4             	pushl  -0xc(%ebp)
  800c85:	6a 00                	push   $0x0
  800c87:	e8 da f4 ff ff       	call   800166 <sys_page_alloc>
  800c8c:	89 c3                	mov    %eax,%ebx
  800c8e:	83 c4 10             	add    $0x10,%esp
  800c91:	85 c0                	test   %eax,%eax
  800c93:	79 10                	jns    800ca5 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	56                   	push   %esi
  800c99:	e8 0e 02 00 00       	call   800eac <nsipc_close>
		return r;
  800c9e:	83 c4 10             	add    $0x10,%esp
  800ca1:	89 d8                	mov    %ebx,%eax
  800ca3:	eb 24                	jmp    800cc9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ca5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cae:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cba:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cbd:	83 ec 0c             	sub    $0xc,%esp
  800cc0:	50                   	push   %eax
  800cc1:	e8 b0 f6 ff ff       	call   800376 <fd2num>
  800cc6:	83 c4 10             	add    $0x10,%esp
}
  800cc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd9:	e8 50 ff ff ff       	call   800c2e <fd2sockid>
		return r;
  800cde:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	78 1f                	js     800d03 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce4:	83 ec 04             	sub    $0x4,%esp
  800ce7:	ff 75 10             	pushl  0x10(%ebp)
  800cea:	ff 75 0c             	pushl  0xc(%ebp)
  800ced:	50                   	push   %eax
  800cee:	e8 12 01 00 00       	call   800e05 <nsipc_accept>
  800cf3:	83 c4 10             	add    $0x10,%esp
		return r;
  800cf6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	78 07                	js     800d03 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cfc:	e8 5d ff ff ff       	call   800c5e <alloc_sockfd>
  800d01:	89 c1                	mov    %eax,%ecx
}
  800d03:	89 c8                	mov    %ecx,%eax
  800d05:	c9                   	leave  
  800d06:	c3                   	ret    

00800d07 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d10:	e8 19 ff ff ff       	call   800c2e <fd2sockid>
  800d15:	85 c0                	test   %eax,%eax
  800d17:	78 12                	js     800d2b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d19:	83 ec 04             	sub    $0x4,%esp
  800d1c:	ff 75 10             	pushl  0x10(%ebp)
  800d1f:	ff 75 0c             	pushl  0xc(%ebp)
  800d22:	50                   	push   %eax
  800d23:	e8 2d 01 00 00       	call   800e55 <nsipc_bind>
  800d28:	83 c4 10             	add    $0x10,%esp
}
  800d2b:	c9                   	leave  
  800d2c:	c3                   	ret    

00800d2d <shutdown>:

int
shutdown(int s, int how)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	e8 f3 fe ff ff       	call   800c2e <fd2sockid>
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	78 0f                	js     800d4e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d3f:	83 ec 08             	sub    $0x8,%esp
  800d42:	ff 75 0c             	pushl  0xc(%ebp)
  800d45:	50                   	push   %eax
  800d46:	e8 3f 01 00 00       	call   800e8a <nsipc_shutdown>
  800d4b:	83 c4 10             	add    $0x10,%esp
}
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	e8 d0 fe ff ff       	call   800c2e <fd2sockid>
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	78 12                	js     800d74 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d62:	83 ec 04             	sub    $0x4,%esp
  800d65:	ff 75 10             	pushl  0x10(%ebp)
  800d68:	ff 75 0c             	pushl  0xc(%ebp)
  800d6b:	50                   	push   %eax
  800d6c:	e8 55 01 00 00       	call   800ec6 <nsipc_connect>
  800d71:	83 c4 10             	add    $0x10,%esp
}
  800d74:	c9                   	leave  
  800d75:	c3                   	ret    

00800d76 <listen>:

int
listen(int s, int backlog)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	e8 aa fe ff ff       	call   800c2e <fd2sockid>
  800d84:	85 c0                	test   %eax,%eax
  800d86:	78 0f                	js     800d97 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d88:	83 ec 08             	sub    $0x8,%esp
  800d8b:	ff 75 0c             	pushl  0xc(%ebp)
  800d8e:	50                   	push   %eax
  800d8f:	e8 67 01 00 00       	call   800efb <nsipc_listen>
  800d94:	83 c4 10             	add    $0x10,%esp
}
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    

00800d99 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d9f:	ff 75 10             	pushl  0x10(%ebp)
  800da2:	ff 75 0c             	pushl  0xc(%ebp)
  800da5:	ff 75 08             	pushl  0x8(%ebp)
  800da8:	e8 3a 02 00 00       	call   800fe7 <nsipc_socket>
  800dad:	83 c4 10             	add    $0x10,%esp
  800db0:	85 c0                	test   %eax,%eax
  800db2:	78 05                	js     800db9 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800db4:	e8 a5 fe ff ff       	call   800c5e <alloc_sockfd>
}
  800db9:	c9                   	leave  
  800dba:	c3                   	ret    

00800dbb <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	53                   	push   %ebx
  800dbf:	83 ec 04             	sub    $0x4,%esp
  800dc2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dc4:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dcb:	75 12                	jne    800ddf <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	6a 02                	push   $0x2
  800dd2:	e8 7b 11 00 00       	call   801f52 <ipc_find_env>
  800dd7:	a3 04 40 80 00       	mov    %eax,0x804004
  800ddc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800ddf:	6a 07                	push   $0x7
  800de1:	68 00 60 80 00       	push   $0x806000
  800de6:	53                   	push   %ebx
  800de7:	ff 35 04 40 80 00    	pushl  0x804004
  800ded:	e8 0c 11 00 00       	call   801efe <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800df2:	83 c4 0c             	add    $0xc,%esp
  800df5:	6a 00                	push   $0x0
  800df7:	6a 00                	push   $0x0
  800df9:	6a 00                	push   $0x0
  800dfb:	e8 95 10 00 00       	call   801e95 <ipc_recv>
}
  800e00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e03:	c9                   	leave  
  800e04:	c3                   	ret    

00800e05 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	56                   	push   %esi
  800e09:	53                   	push   %ebx
  800e0a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e15:	8b 06                	mov    (%esi),%eax
  800e17:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e21:	e8 95 ff ff ff       	call   800dbb <nsipc>
  800e26:	89 c3                	mov    %eax,%ebx
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	78 20                	js     800e4c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e2c:	83 ec 04             	sub    $0x4,%esp
  800e2f:	ff 35 10 60 80 00    	pushl  0x806010
  800e35:	68 00 60 80 00       	push   $0x806000
  800e3a:	ff 75 0c             	pushl  0xc(%ebp)
  800e3d:	e8 9e 0e 00 00       	call   801ce0 <memmove>
		*addrlen = ret->ret_addrlen;
  800e42:	a1 10 60 80 00       	mov    0x806010,%eax
  800e47:	89 06                	mov    %eax,(%esi)
  800e49:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e4c:	89 d8                	mov    %ebx,%eax
  800e4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	53                   	push   %ebx
  800e59:	83 ec 08             	sub    $0x8,%esp
  800e5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e67:	53                   	push   %ebx
  800e68:	ff 75 0c             	pushl  0xc(%ebp)
  800e6b:	68 04 60 80 00       	push   $0x806004
  800e70:	e8 6b 0e 00 00       	call   801ce0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e75:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e80:	e8 36 ff ff ff       	call   800dbb <nsipc>
}
  800e85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e88:	c9                   	leave  
  800e89:	c3                   	ret    

00800e8a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e90:	8b 45 08             	mov    0x8(%ebp),%eax
  800e93:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ea0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea5:	e8 11 ff ff ff       	call   800dbb <nsipc>
}
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <nsipc_close>:

int
nsipc_close(int s)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb5:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eba:	b8 04 00 00 00       	mov    $0x4,%eax
  800ebf:	e8 f7 fe ff ff       	call   800dbb <nsipc>
}
  800ec4:	c9                   	leave  
  800ec5:	c3                   	ret    

00800ec6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	53                   	push   %ebx
  800eca:	83 ec 08             	sub    $0x8,%esp
  800ecd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed8:	53                   	push   %ebx
  800ed9:	ff 75 0c             	pushl  0xc(%ebp)
  800edc:	68 04 60 80 00       	push   $0x806004
  800ee1:	e8 fa 0d 00 00       	call   801ce0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ee6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800eec:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef1:	e8 c5 fe ff ff       	call   800dbb <nsipc>
}
  800ef6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f01:	8b 45 08             	mov    0x8(%ebp),%eax
  800f04:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f11:	b8 06 00 00 00       	mov    $0x6,%eax
  800f16:	e8 a0 fe ff ff       	call   800dbb <nsipc>
}
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    

00800f1d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f25:	8b 45 08             	mov    0x8(%ebp),%eax
  800f28:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f2d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f33:	8b 45 14             	mov    0x14(%ebp),%eax
  800f36:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f3b:	b8 07 00 00 00       	mov    $0x7,%eax
  800f40:	e8 76 fe ff ff       	call   800dbb <nsipc>
  800f45:	89 c3                	mov    %eax,%ebx
  800f47:	85 c0                	test   %eax,%eax
  800f49:	78 35                	js     800f80 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f4b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f50:	7f 04                	jg     800f56 <nsipc_recv+0x39>
  800f52:	39 c6                	cmp    %eax,%esi
  800f54:	7d 16                	jge    800f6c <nsipc_recv+0x4f>
  800f56:	68 73 23 80 00       	push   $0x802373
  800f5b:	68 34 23 80 00       	push   $0x802334
  800f60:	6a 62                	push   $0x62
  800f62:	68 88 23 80 00       	push   $0x802388
  800f67:	e8 84 05 00 00       	call   8014f0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	50                   	push   %eax
  800f70:	68 00 60 80 00       	push   $0x806000
  800f75:	ff 75 0c             	pushl  0xc(%ebp)
  800f78:	e8 63 0d 00 00       	call   801ce0 <memmove>
  800f7d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f80:	89 d8                	mov    %ebx,%eax
  800f82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
  800f96:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f9b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fa1:	7e 16                	jle    800fb9 <nsipc_send+0x30>
  800fa3:	68 94 23 80 00       	push   $0x802394
  800fa8:	68 34 23 80 00       	push   $0x802334
  800fad:	6a 6d                	push   $0x6d
  800faf:	68 88 23 80 00       	push   $0x802388
  800fb4:	e8 37 05 00 00       	call   8014f0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	53                   	push   %ebx
  800fbd:	ff 75 0c             	pushl  0xc(%ebp)
  800fc0:	68 0c 60 80 00       	push   $0x80600c
  800fc5:	e8 16 0d 00 00       	call   801ce0 <memmove>
	nsipcbuf.send.req_size = size;
  800fca:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fd0:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800fdd:	e8 d9 fd ff ff       	call   800dbb <nsipc>
}
  800fe2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ffd:	8b 45 10             	mov    0x10(%ebp),%eax
  801000:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801005:	b8 09 00 00 00       	mov    $0x9,%eax
  80100a:	e8 ac fd ff ff       	call   800dbb <nsipc>
}
  80100f:	c9                   	leave  
  801010:	c3                   	ret    

00801011 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	ff 75 08             	pushl  0x8(%ebp)
  80101f:	e8 62 f3 ff ff       	call   800386 <fd2data>
  801024:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801026:	83 c4 08             	add    $0x8,%esp
  801029:	68 a0 23 80 00       	push   $0x8023a0
  80102e:	53                   	push   %ebx
  80102f:	e8 1a 0b 00 00       	call   801b4e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801034:	8b 46 04             	mov    0x4(%esi),%eax
  801037:	2b 06                	sub    (%esi),%eax
  801039:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80103f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801046:	00 00 00 
	stat->st_dev = &devpipe;
  801049:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801050:	30 80 00 
	return 0;
}
  801053:	b8 00 00 00 00       	mov    $0x0,%eax
  801058:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    

0080105f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	53                   	push   %ebx
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801069:	53                   	push   %ebx
  80106a:	6a 00                	push   $0x0
  80106c:	e8 7a f1 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801071:	89 1c 24             	mov    %ebx,(%esp)
  801074:	e8 0d f3 ff ff       	call   800386 <fd2data>
  801079:	83 c4 08             	add    $0x8,%esp
  80107c:	50                   	push   %eax
  80107d:	6a 00                	push   $0x0
  80107f:	e8 67 f1 ff ff       	call   8001eb <sys_page_unmap>
}
  801084:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801087:	c9                   	leave  
  801088:	c3                   	ret    

00801089 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	57                   	push   %edi
  80108d:	56                   	push   %esi
  80108e:	53                   	push   %ebx
  80108f:	83 ec 1c             	sub    $0x1c,%esp
  801092:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801095:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801097:	a1 08 40 80 00       	mov    0x804008,%eax
  80109c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a5:	e8 e1 0e 00 00       	call   801f8b <pageref>
  8010aa:	89 c3                	mov    %eax,%ebx
  8010ac:	89 3c 24             	mov    %edi,(%esp)
  8010af:	e8 d7 0e 00 00       	call   801f8b <pageref>
  8010b4:	83 c4 10             	add    $0x10,%esp
  8010b7:	39 c3                	cmp    %eax,%ebx
  8010b9:	0f 94 c1             	sete   %cl
  8010bc:	0f b6 c9             	movzbl %cl,%ecx
  8010bf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010c2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010c8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010cb:	39 ce                	cmp    %ecx,%esi
  8010cd:	74 1b                	je     8010ea <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010cf:	39 c3                	cmp    %eax,%ebx
  8010d1:	75 c4                	jne    801097 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010d3:	8b 42 58             	mov    0x58(%edx),%eax
  8010d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d9:	50                   	push   %eax
  8010da:	56                   	push   %esi
  8010db:	68 a7 23 80 00       	push   $0x8023a7
  8010e0:	e8 e4 04 00 00       	call   8015c9 <cprintf>
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	eb ad                	jmp    801097 <_pipeisclosed+0xe>
	}
}
  8010ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 28             	sub    $0x28,%esp
  8010fe:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801101:	56                   	push   %esi
  801102:	e8 7f f2 ff ff       	call   800386 <fd2data>
  801107:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	bf 00 00 00 00       	mov    $0x0,%edi
  801111:	eb 4b                	jmp    80115e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801113:	89 da                	mov    %ebx,%edx
  801115:	89 f0                	mov    %esi,%eax
  801117:	e8 6d ff ff ff       	call   801089 <_pipeisclosed>
  80111c:	85 c0                	test   %eax,%eax
  80111e:	75 48                	jne    801168 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801120:	e8 22 f0 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801125:	8b 43 04             	mov    0x4(%ebx),%eax
  801128:	8b 0b                	mov    (%ebx),%ecx
  80112a:	8d 51 20             	lea    0x20(%ecx),%edx
  80112d:	39 d0                	cmp    %edx,%eax
  80112f:	73 e2                	jae    801113 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801131:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801134:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801138:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80113b:	89 c2                	mov    %eax,%edx
  80113d:	c1 fa 1f             	sar    $0x1f,%edx
  801140:	89 d1                	mov    %edx,%ecx
  801142:	c1 e9 1b             	shr    $0x1b,%ecx
  801145:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801148:	83 e2 1f             	and    $0x1f,%edx
  80114b:	29 ca                	sub    %ecx,%edx
  80114d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801151:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801155:	83 c0 01             	add    $0x1,%eax
  801158:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80115b:	83 c7 01             	add    $0x1,%edi
  80115e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801161:	75 c2                	jne    801125 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801163:	8b 45 10             	mov    0x10(%ebp),%eax
  801166:	eb 05                	jmp    80116d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80116d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    

00801175 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	57                   	push   %edi
  801179:	56                   	push   %esi
  80117a:	53                   	push   %ebx
  80117b:	83 ec 18             	sub    $0x18,%esp
  80117e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801181:	57                   	push   %edi
  801182:	e8 ff f1 ff ff       	call   800386 <fd2data>
  801187:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801191:	eb 3d                	jmp    8011d0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801193:	85 db                	test   %ebx,%ebx
  801195:	74 04                	je     80119b <devpipe_read+0x26>
				return i;
  801197:	89 d8                	mov    %ebx,%eax
  801199:	eb 44                	jmp    8011df <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80119b:	89 f2                	mov    %esi,%edx
  80119d:	89 f8                	mov    %edi,%eax
  80119f:	e8 e5 fe ff ff       	call   801089 <_pipeisclosed>
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	75 32                	jne    8011da <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011a8:	e8 9a ef ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011ad:	8b 06                	mov    (%esi),%eax
  8011af:	3b 46 04             	cmp    0x4(%esi),%eax
  8011b2:	74 df                	je     801193 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b4:	99                   	cltd   
  8011b5:	c1 ea 1b             	shr    $0x1b,%edx
  8011b8:	01 d0                	add    %edx,%eax
  8011ba:	83 e0 1f             	and    $0x1f,%eax
  8011bd:	29 d0                	sub    %edx,%eax
  8011bf:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011ca:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011cd:	83 c3 01             	add    $0x1,%ebx
  8011d0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011d3:	75 d8                	jne    8011ad <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d8:	eb 05                	jmp    8011df <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011da:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	56                   	push   %esi
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f2:	50                   	push   %eax
  8011f3:	e8 a5 f1 ff ff       	call   80039d <fd_alloc>
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	89 c2                	mov    %eax,%edx
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	0f 88 2c 01 00 00    	js     801331 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	68 07 04 00 00       	push   $0x407
  80120d:	ff 75 f4             	pushl  -0xc(%ebp)
  801210:	6a 00                	push   $0x0
  801212:	e8 4f ef ff ff       	call   800166 <sys_page_alloc>
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	89 c2                	mov    %eax,%edx
  80121c:	85 c0                	test   %eax,%eax
  80121e:	0f 88 0d 01 00 00    	js     801331 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	e8 6d f1 ff ff       	call   80039d <fd_alloc>
  801230:	89 c3                	mov    %eax,%ebx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	0f 88 e2 00 00 00    	js     80131f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80123d:	83 ec 04             	sub    $0x4,%esp
  801240:	68 07 04 00 00       	push   $0x407
  801245:	ff 75 f0             	pushl  -0x10(%ebp)
  801248:	6a 00                	push   $0x0
  80124a:	e8 17 ef ff ff       	call   800166 <sys_page_alloc>
  80124f:	89 c3                	mov    %eax,%ebx
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	0f 88 c3 00 00 00    	js     80131f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80125c:	83 ec 0c             	sub    $0xc,%esp
  80125f:	ff 75 f4             	pushl  -0xc(%ebp)
  801262:	e8 1f f1 ff ff       	call   800386 <fd2data>
  801267:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801269:	83 c4 0c             	add    $0xc,%esp
  80126c:	68 07 04 00 00       	push   $0x407
  801271:	50                   	push   %eax
  801272:	6a 00                	push   $0x0
  801274:	e8 ed ee ff ff       	call   800166 <sys_page_alloc>
  801279:	89 c3                	mov    %eax,%ebx
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	0f 88 89 00 00 00    	js     80130f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801286:	83 ec 0c             	sub    $0xc,%esp
  801289:	ff 75 f0             	pushl  -0x10(%ebp)
  80128c:	e8 f5 f0 ff ff       	call   800386 <fd2data>
  801291:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801298:	50                   	push   %eax
  801299:	6a 00                	push   $0x0
  80129b:	56                   	push   %esi
  80129c:	6a 00                	push   $0x0
  80129e:	e8 06 ef ff ff       	call   8001a9 <sys_page_map>
  8012a3:	89 c3                	mov    %eax,%ebx
  8012a5:	83 c4 20             	add    $0x20,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 55                	js     801301 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012ac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012c1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ca:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012dc:	e8 95 f0 ff ff       	call   800376 <fd2num>
  8012e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e6:	83 c4 04             	add    $0x4,%esp
  8012e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ec:	e8 85 f0 ff ff       	call   800376 <fd2num>
  8012f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ff:	eb 30                	jmp    801331 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	56                   	push   %esi
  801305:	6a 00                	push   $0x0
  801307:	e8 df ee ff ff       	call   8001eb <sys_page_unmap>
  80130c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	ff 75 f0             	pushl  -0x10(%ebp)
  801315:	6a 00                	push   $0x0
  801317:	e8 cf ee ff ff       	call   8001eb <sys_page_unmap>
  80131c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	ff 75 f4             	pushl  -0xc(%ebp)
  801325:	6a 00                	push   $0x0
  801327:	e8 bf ee ff ff       	call   8001eb <sys_page_unmap>
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801331:	89 d0                	mov    %edx,%eax
  801333:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801336:	5b                   	pop    %ebx
  801337:	5e                   	pop    %esi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801340:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801343:	50                   	push   %eax
  801344:	ff 75 08             	pushl  0x8(%ebp)
  801347:	e8 a0 f0 ff ff       	call   8003ec <fd_lookup>
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 18                	js     80136b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	ff 75 f4             	pushl  -0xc(%ebp)
  801359:	e8 28 f0 ff ff       	call   800386 <fd2data>
	return _pipeisclosed(fd, p);
  80135e:	89 c2                	mov    %eax,%edx
  801360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801363:	e8 21 fd ff ff       	call   801089 <_pipeisclosed>
  801368:	83 c4 10             	add    $0x10,%esp
}
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
  801375:	5d                   	pop    %ebp
  801376:	c3                   	ret    

00801377 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80137d:	68 bf 23 80 00       	push   $0x8023bf
  801382:	ff 75 0c             	pushl  0xc(%ebp)
  801385:	e8 c4 07 00 00       	call   801b4e <strcpy>
	return 0;
}
  80138a:	b8 00 00 00 00       	mov    $0x0,%eax
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	57                   	push   %edi
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
  801397:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80139d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a8:	eb 2d                	jmp    8013d7 <devcons_write+0x46>
		m = n - tot;
  8013aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ad:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013af:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013b2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013b7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013ba:	83 ec 04             	sub    $0x4,%esp
  8013bd:	53                   	push   %ebx
  8013be:	03 45 0c             	add    0xc(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	57                   	push   %edi
  8013c3:	e8 18 09 00 00       	call   801ce0 <memmove>
		sys_cputs(buf, m);
  8013c8:	83 c4 08             	add    $0x8,%esp
  8013cb:	53                   	push   %ebx
  8013cc:	57                   	push   %edi
  8013cd:	e8 d8 ec ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013d2:	01 de                	add    %ebx,%esi
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	89 f0                	mov    %esi,%eax
  8013d9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013dc:	72 cc                	jb     8013aa <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f5:	74 2a                	je     801421 <devcons_read+0x3b>
  8013f7:	eb 05                	jmp    8013fe <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f9:	e8 49 ed ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013fe:	e8 c5 ec ff ff       	call   8000c8 <sys_cgetc>
  801403:	85 c0                	test   %eax,%eax
  801405:	74 f2                	je     8013f9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801407:	85 c0                	test   %eax,%eax
  801409:	78 16                	js     801421 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80140b:	83 f8 04             	cmp    $0x4,%eax
  80140e:	74 0c                	je     80141c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801410:	8b 55 0c             	mov    0xc(%ebp),%edx
  801413:	88 02                	mov    %al,(%edx)
	return 1;
  801415:	b8 01 00 00 00       	mov    $0x1,%eax
  80141a:	eb 05                	jmp    801421 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80141c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801429:	8b 45 08             	mov    0x8(%ebp),%eax
  80142c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80142f:	6a 01                	push   $0x1
  801431:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801434:	50                   	push   %eax
  801435:	e8 70 ec ff ff       	call   8000aa <sys_cputs>
}
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <getchar>:

int
getchar(void)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
  801442:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801445:	6a 01                	push   $0x1
  801447:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80144a:	50                   	push   %eax
  80144b:	6a 00                	push   $0x0
  80144d:	e8 00 f2 ff ff       	call   800652 <read>
	if (r < 0)
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	85 c0                	test   %eax,%eax
  801457:	78 0f                	js     801468 <getchar+0x29>
		return r;
	if (r < 1)
  801459:	85 c0                	test   %eax,%eax
  80145b:	7e 06                	jle    801463 <getchar+0x24>
		return -E_EOF;
	return c;
  80145d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801461:	eb 05                	jmp    801468 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801463:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801470:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801473:	50                   	push   %eax
  801474:	ff 75 08             	pushl  0x8(%ebp)
  801477:	e8 70 ef ff ff       	call   8003ec <fd_lookup>
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 11                	js     801494 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801483:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801486:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80148c:	39 10                	cmp    %edx,(%eax)
  80148e:	0f 94 c0             	sete   %al
  801491:	0f b6 c0             	movzbl %al,%eax
}
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <opencons>:

int
opencons(void)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80149c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149f:	50                   	push   %eax
  8014a0:	e8 f8 ee ff ff       	call   80039d <fd_alloc>
  8014a5:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014aa:	85 c0                	test   %eax,%eax
  8014ac:	78 3e                	js     8014ec <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ae:	83 ec 04             	sub    $0x4,%esp
  8014b1:	68 07 04 00 00       	push   $0x407
  8014b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b9:	6a 00                	push   $0x0
  8014bb:	e8 a6 ec ff ff       	call   800166 <sys_page_alloc>
  8014c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 23                	js     8014ec <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014de:	83 ec 0c             	sub    $0xc,%esp
  8014e1:	50                   	push   %eax
  8014e2:	e8 8f ee ff ff       	call   800376 <fd2num>
  8014e7:	89 c2                	mov    %eax,%edx
  8014e9:	83 c4 10             	add    $0x10,%esp
}
  8014ec:	89 d0                	mov    %edx,%eax
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	56                   	push   %esi
  8014f4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014f8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014fe:	e8 25 ec ff ff       	call   800128 <sys_getenvid>
  801503:	83 ec 0c             	sub    $0xc,%esp
  801506:	ff 75 0c             	pushl  0xc(%ebp)
  801509:	ff 75 08             	pushl  0x8(%ebp)
  80150c:	56                   	push   %esi
  80150d:	50                   	push   %eax
  80150e:	68 cc 23 80 00       	push   $0x8023cc
  801513:	e8 b1 00 00 00       	call   8015c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801518:	83 c4 18             	add    $0x18,%esp
  80151b:	53                   	push   %ebx
  80151c:	ff 75 10             	pushl  0x10(%ebp)
  80151f:	e8 54 00 00 00       	call   801578 <vcprintf>
	cprintf("\n");
  801524:	c7 04 24 b8 23 80 00 	movl   $0x8023b8,(%esp)
  80152b:	e8 99 00 00 00       	call   8015c9 <cprintf>
  801530:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801533:	cc                   	int3   
  801534:	eb fd                	jmp    801533 <_panic+0x43>

00801536 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	53                   	push   %ebx
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801540:	8b 13                	mov    (%ebx),%edx
  801542:	8d 42 01             	lea    0x1(%edx),%eax
  801545:	89 03                	mov    %eax,(%ebx)
  801547:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80154a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80154e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801553:	75 1a                	jne    80156f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801555:	83 ec 08             	sub    $0x8,%esp
  801558:	68 ff 00 00 00       	push   $0xff
  80155d:	8d 43 08             	lea    0x8(%ebx),%eax
  801560:	50                   	push   %eax
  801561:	e8 44 eb ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  801566:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80156c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80156f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801573:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801581:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801588:	00 00 00 
	b.cnt = 0;
  80158b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801592:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801595:	ff 75 0c             	pushl  0xc(%ebp)
  801598:	ff 75 08             	pushl  0x8(%ebp)
  80159b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	68 36 15 80 00       	push   $0x801536
  8015a7:	e8 54 01 00 00       	call   801700 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015b5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015bb:	50                   	push   %eax
  8015bc:	e8 e9 ea ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  8015c1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015cf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015d2:	50                   	push   %eax
  8015d3:	ff 75 08             	pushl  0x8(%ebp)
  8015d6:	e8 9d ff ff ff       	call   801578 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	57                   	push   %edi
  8015e1:	56                   	push   %esi
  8015e2:	53                   	push   %ebx
  8015e3:	83 ec 1c             	sub    $0x1c,%esp
  8015e6:	89 c7                	mov    %eax,%edi
  8015e8:	89 d6                	mov    %edx,%esi
  8015ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801601:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801604:	39 d3                	cmp    %edx,%ebx
  801606:	72 05                	jb     80160d <printnum+0x30>
  801608:	39 45 10             	cmp    %eax,0x10(%ebp)
  80160b:	77 45                	ja     801652 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80160d:	83 ec 0c             	sub    $0xc,%esp
  801610:	ff 75 18             	pushl  0x18(%ebp)
  801613:	8b 45 14             	mov    0x14(%ebp),%eax
  801616:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801619:	53                   	push   %ebx
  80161a:	ff 75 10             	pushl  0x10(%ebp)
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	ff 75 e4             	pushl  -0x1c(%ebp)
  801623:	ff 75 e0             	pushl  -0x20(%ebp)
  801626:	ff 75 dc             	pushl  -0x24(%ebp)
  801629:	ff 75 d8             	pushl  -0x28(%ebp)
  80162c:	e8 9f 09 00 00       	call   801fd0 <__udivdi3>
  801631:	83 c4 18             	add    $0x18,%esp
  801634:	52                   	push   %edx
  801635:	50                   	push   %eax
  801636:	89 f2                	mov    %esi,%edx
  801638:	89 f8                	mov    %edi,%eax
  80163a:	e8 9e ff ff ff       	call   8015dd <printnum>
  80163f:	83 c4 20             	add    $0x20,%esp
  801642:	eb 18                	jmp    80165c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	56                   	push   %esi
  801648:	ff 75 18             	pushl  0x18(%ebp)
  80164b:	ff d7                	call   *%edi
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	eb 03                	jmp    801655 <printnum+0x78>
  801652:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801655:	83 eb 01             	sub    $0x1,%ebx
  801658:	85 db                	test   %ebx,%ebx
  80165a:	7f e8                	jg     801644 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	56                   	push   %esi
  801660:	83 ec 04             	sub    $0x4,%esp
  801663:	ff 75 e4             	pushl  -0x1c(%ebp)
  801666:	ff 75 e0             	pushl  -0x20(%ebp)
  801669:	ff 75 dc             	pushl  -0x24(%ebp)
  80166c:	ff 75 d8             	pushl  -0x28(%ebp)
  80166f:	e8 8c 0a 00 00       	call   802100 <__umoddi3>
  801674:	83 c4 14             	add    $0x14,%esp
  801677:	0f be 80 ef 23 80 00 	movsbl 0x8023ef(%eax),%eax
  80167e:	50                   	push   %eax
  80167f:	ff d7                	call   *%edi
}
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801687:	5b                   	pop    %ebx
  801688:	5e                   	pop    %esi
  801689:	5f                   	pop    %edi
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80168f:	83 fa 01             	cmp    $0x1,%edx
  801692:	7e 0e                	jle    8016a2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801694:	8b 10                	mov    (%eax),%edx
  801696:	8d 4a 08             	lea    0x8(%edx),%ecx
  801699:	89 08                	mov    %ecx,(%eax)
  80169b:	8b 02                	mov    (%edx),%eax
  80169d:	8b 52 04             	mov    0x4(%edx),%edx
  8016a0:	eb 22                	jmp    8016c4 <getuint+0x38>
	else if (lflag)
  8016a2:	85 d2                	test   %edx,%edx
  8016a4:	74 10                	je     8016b6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016a6:	8b 10                	mov    (%eax),%edx
  8016a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016ab:	89 08                	mov    %ecx,(%eax)
  8016ad:	8b 02                	mov    (%edx),%eax
  8016af:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b4:	eb 0e                	jmp    8016c4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016b6:	8b 10                	mov    (%eax),%edx
  8016b8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016bb:	89 08                	mov    %ecx,(%eax)
  8016bd:	8b 02                	mov    (%edx),%eax
  8016bf:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016d0:	8b 10                	mov    (%eax),%edx
  8016d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8016d5:	73 0a                	jae    8016e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016da:	89 08                	mov    %ecx,(%eax)
  8016dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016df:	88 02                	mov    %al,(%edx)
}
  8016e1:	5d                   	pop    %ebp
  8016e2:	c3                   	ret    

008016e3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016ec:	50                   	push   %eax
  8016ed:	ff 75 10             	pushl  0x10(%ebp)
  8016f0:	ff 75 0c             	pushl  0xc(%ebp)
  8016f3:	ff 75 08             	pushl  0x8(%ebp)
  8016f6:	e8 05 00 00 00       	call   801700 <vprintfmt>
	va_end(ap);
}
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	57                   	push   %edi
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
  801706:	83 ec 2c             	sub    $0x2c,%esp
  801709:	8b 75 08             	mov    0x8(%ebp),%esi
  80170c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80170f:	8b 7d 10             	mov    0x10(%ebp),%edi
  801712:	eb 12                	jmp    801726 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801714:	85 c0                	test   %eax,%eax
  801716:	0f 84 89 03 00 00    	je     801aa5 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80171c:	83 ec 08             	sub    $0x8,%esp
  80171f:	53                   	push   %ebx
  801720:	50                   	push   %eax
  801721:	ff d6                	call   *%esi
  801723:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801726:	83 c7 01             	add    $0x1,%edi
  801729:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80172d:	83 f8 25             	cmp    $0x25,%eax
  801730:	75 e2                	jne    801714 <vprintfmt+0x14>
  801732:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801736:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80173d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801744:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80174b:	ba 00 00 00 00       	mov    $0x0,%edx
  801750:	eb 07                	jmp    801759 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801752:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801755:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801759:	8d 47 01             	lea    0x1(%edi),%eax
  80175c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80175f:	0f b6 07             	movzbl (%edi),%eax
  801762:	0f b6 c8             	movzbl %al,%ecx
  801765:	83 e8 23             	sub    $0x23,%eax
  801768:	3c 55                	cmp    $0x55,%al
  80176a:	0f 87 1a 03 00 00    	ja     801a8a <vprintfmt+0x38a>
  801770:	0f b6 c0             	movzbl %al,%eax
  801773:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  80177a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80177d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801781:	eb d6                	jmp    801759 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801783:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801786:	b8 00 00 00 00       	mov    $0x0,%eax
  80178b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80178e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801791:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801795:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801798:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80179b:	83 fa 09             	cmp    $0x9,%edx
  80179e:	77 39                	ja     8017d9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017a3:	eb e9                	jmp    80178e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a8:	8d 48 04             	lea    0x4(%eax),%ecx
  8017ab:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017ae:	8b 00                	mov    (%eax),%eax
  8017b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017b6:	eb 27                	jmp    8017df <vprintfmt+0xdf>
  8017b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017c2:	0f 49 c8             	cmovns %eax,%ecx
  8017c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017cb:	eb 8c                	jmp    801759 <vprintfmt+0x59>
  8017cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017d0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017d7:	eb 80                	jmp    801759 <vprintfmt+0x59>
  8017d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017dc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017e3:	0f 89 70 ff ff ff    	jns    801759 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017f6:	e9 5e ff ff ff       	jmp    801759 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017fb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801801:	e9 53 ff ff ff       	jmp    801759 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801806:	8b 45 14             	mov    0x14(%ebp),%eax
  801809:	8d 50 04             	lea    0x4(%eax),%edx
  80180c:	89 55 14             	mov    %edx,0x14(%ebp)
  80180f:	83 ec 08             	sub    $0x8,%esp
  801812:	53                   	push   %ebx
  801813:	ff 30                	pushl  (%eax)
  801815:	ff d6                	call   *%esi
			break;
  801817:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80181d:	e9 04 ff ff ff       	jmp    801726 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801822:	8b 45 14             	mov    0x14(%ebp),%eax
  801825:	8d 50 04             	lea    0x4(%eax),%edx
  801828:	89 55 14             	mov    %edx,0x14(%ebp)
  80182b:	8b 00                	mov    (%eax),%eax
  80182d:	99                   	cltd   
  80182e:	31 d0                	xor    %edx,%eax
  801830:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801832:	83 f8 0f             	cmp    $0xf,%eax
  801835:	7f 0b                	jg     801842 <vprintfmt+0x142>
  801837:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80183e:	85 d2                	test   %edx,%edx
  801840:	75 18                	jne    80185a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801842:	50                   	push   %eax
  801843:	68 07 24 80 00       	push   $0x802407
  801848:	53                   	push   %ebx
  801849:	56                   	push   %esi
  80184a:	e8 94 fe ff ff       	call   8016e3 <printfmt>
  80184f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801852:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801855:	e9 cc fe ff ff       	jmp    801726 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80185a:	52                   	push   %edx
  80185b:	68 46 23 80 00       	push   $0x802346
  801860:	53                   	push   %ebx
  801861:	56                   	push   %esi
  801862:	e8 7c fe ff ff       	call   8016e3 <printfmt>
  801867:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80186d:	e9 b4 fe ff ff       	jmp    801726 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801872:	8b 45 14             	mov    0x14(%ebp),%eax
  801875:	8d 50 04             	lea    0x4(%eax),%edx
  801878:	89 55 14             	mov    %edx,0x14(%ebp)
  80187b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80187d:	85 ff                	test   %edi,%edi
  80187f:	b8 00 24 80 00       	mov    $0x802400,%eax
  801884:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801887:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80188b:	0f 8e 94 00 00 00    	jle    801925 <vprintfmt+0x225>
  801891:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801895:	0f 84 98 00 00 00    	je     801933 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80189b:	83 ec 08             	sub    $0x8,%esp
  80189e:	ff 75 d0             	pushl  -0x30(%ebp)
  8018a1:	57                   	push   %edi
  8018a2:	e8 86 02 00 00       	call   801b2d <strnlen>
  8018a7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018aa:	29 c1                	sub    %eax,%ecx
  8018ac:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018af:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018b2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018bc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018be:	eb 0f                	jmp    8018cf <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	53                   	push   %ebx
  8018c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c9:	83 ef 01             	sub    $0x1,%edi
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 ff                	test   %edi,%edi
  8018d1:	7f ed                	jg     8018c0 <vprintfmt+0x1c0>
  8018d3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018d6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018d9:	85 c9                	test   %ecx,%ecx
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e0:	0f 49 c1             	cmovns %ecx,%eax
  8018e3:	29 c1                	sub    %eax,%ecx
  8018e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ee:	89 cb                	mov    %ecx,%ebx
  8018f0:	eb 4d                	jmp    80193f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018f6:	74 1b                	je     801913 <vprintfmt+0x213>
  8018f8:	0f be c0             	movsbl %al,%eax
  8018fb:	83 e8 20             	sub    $0x20,%eax
  8018fe:	83 f8 5e             	cmp    $0x5e,%eax
  801901:	76 10                	jbe    801913 <vprintfmt+0x213>
					putch('?', putdat);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	ff 75 0c             	pushl  0xc(%ebp)
  801909:	6a 3f                	push   $0x3f
  80190b:	ff 55 08             	call   *0x8(%ebp)
  80190e:	83 c4 10             	add    $0x10,%esp
  801911:	eb 0d                	jmp    801920 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	ff 75 0c             	pushl  0xc(%ebp)
  801919:	52                   	push   %edx
  80191a:	ff 55 08             	call   *0x8(%ebp)
  80191d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801920:	83 eb 01             	sub    $0x1,%ebx
  801923:	eb 1a                	jmp    80193f <vprintfmt+0x23f>
  801925:	89 75 08             	mov    %esi,0x8(%ebp)
  801928:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80192b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80192e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801931:	eb 0c                	jmp    80193f <vprintfmt+0x23f>
  801933:	89 75 08             	mov    %esi,0x8(%ebp)
  801936:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801939:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80193c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80193f:	83 c7 01             	add    $0x1,%edi
  801942:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801946:	0f be d0             	movsbl %al,%edx
  801949:	85 d2                	test   %edx,%edx
  80194b:	74 23                	je     801970 <vprintfmt+0x270>
  80194d:	85 f6                	test   %esi,%esi
  80194f:	78 a1                	js     8018f2 <vprintfmt+0x1f2>
  801951:	83 ee 01             	sub    $0x1,%esi
  801954:	79 9c                	jns    8018f2 <vprintfmt+0x1f2>
  801956:	89 df                	mov    %ebx,%edi
  801958:	8b 75 08             	mov    0x8(%ebp),%esi
  80195b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80195e:	eb 18                	jmp    801978 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801960:	83 ec 08             	sub    $0x8,%esp
  801963:	53                   	push   %ebx
  801964:	6a 20                	push   $0x20
  801966:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801968:	83 ef 01             	sub    $0x1,%edi
  80196b:	83 c4 10             	add    $0x10,%esp
  80196e:	eb 08                	jmp    801978 <vprintfmt+0x278>
  801970:	89 df                	mov    %ebx,%edi
  801972:	8b 75 08             	mov    0x8(%ebp),%esi
  801975:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801978:	85 ff                	test   %edi,%edi
  80197a:	7f e4                	jg     801960 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80197f:	e9 a2 fd ff ff       	jmp    801726 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801984:	83 fa 01             	cmp    $0x1,%edx
  801987:	7e 16                	jle    80199f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801989:	8b 45 14             	mov    0x14(%ebp),%eax
  80198c:	8d 50 08             	lea    0x8(%eax),%edx
  80198f:	89 55 14             	mov    %edx,0x14(%ebp)
  801992:	8b 50 04             	mov    0x4(%eax),%edx
  801995:	8b 00                	mov    (%eax),%eax
  801997:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80199a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80199d:	eb 32                	jmp    8019d1 <vprintfmt+0x2d1>
	else if (lflag)
  80199f:	85 d2                	test   %edx,%edx
  8019a1:	74 18                	je     8019bb <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a6:	8d 50 04             	lea    0x4(%eax),%edx
  8019a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8019ac:	8b 00                	mov    (%eax),%eax
  8019ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019b1:	89 c1                	mov    %eax,%ecx
  8019b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019b9:	eb 16                	jmp    8019d1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019be:	8d 50 04             	lea    0x4(%eax),%edx
  8019c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c4:	8b 00                	mov    (%eax),%eax
  8019c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c9:	89 c1                	mov    %eax,%ecx
  8019cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019d1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019d7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019dc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019e0:	79 74                	jns    801a56 <vprintfmt+0x356>
				putch('-', putdat);
  8019e2:	83 ec 08             	sub    $0x8,%esp
  8019e5:	53                   	push   %ebx
  8019e6:	6a 2d                	push   $0x2d
  8019e8:	ff d6                	call   *%esi
				num = -(long long) num;
  8019ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019f0:	f7 d8                	neg    %eax
  8019f2:	83 d2 00             	adc    $0x0,%edx
  8019f5:	f7 da                	neg    %edx
  8019f7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019fa:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019ff:	eb 55                	jmp    801a56 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a01:	8d 45 14             	lea    0x14(%ebp),%eax
  801a04:	e8 83 fc ff ff       	call   80168c <getuint>
			base = 10;
  801a09:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a0e:	eb 46                	jmp    801a56 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a10:	8d 45 14             	lea    0x14(%ebp),%eax
  801a13:	e8 74 fc ff ff       	call   80168c <getuint>
                        base = 8;
  801a18:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a1d:	eb 37                	jmp    801a56 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a1f:	83 ec 08             	sub    $0x8,%esp
  801a22:	53                   	push   %ebx
  801a23:	6a 30                	push   $0x30
  801a25:	ff d6                	call   *%esi
			putch('x', putdat);
  801a27:	83 c4 08             	add    $0x8,%esp
  801a2a:	53                   	push   %ebx
  801a2b:	6a 78                	push   $0x78
  801a2d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a32:	8d 50 04             	lea    0x4(%eax),%edx
  801a35:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a38:	8b 00                	mov    (%eax),%eax
  801a3a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a3f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a42:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a47:	eb 0d                	jmp    801a56 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a49:	8d 45 14             	lea    0x14(%ebp),%eax
  801a4c:	e8 3b fc ff ff       	call   80168c <getuint>
			base = 16;
  801a51:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a5d:	57                   	push   %edi
  801a5e:	ff 75 e0             	pushl  -0x20(%ebp)
  801a61:	51                   	push   %ecx
  801a62:	52                   	push   %edx
  801a63:	50                   	push   %eax
  801a64:	89 da                	mov    %ebx,%edx
  801a66:	89 f0                	mov    %esi,%eax
  801a68:	e8 70 fb ff ff       	call   8015dd <printnum>
			break;
  801a6d:	83 c4 20             	add    $0x20,%esp
  801a70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a73:	e9 ae fc ff ff       	jmp    801726 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a78:	83 ec 08             	sub    $0x8,%esp
  801a7b:	53                   	push   %ebx
  801a7c:	51                   	push   %ecx
  801a7d:	ff d6                	call   *%esi
			break;
  801a7f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a85:	e9 9c fc ff ff       	jmp    801726 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a8a:	83 ec 08             	sub    $0x8,%esp
  801a8d:	53                   	push   %ebx
  801a8e:	6a 25                	push   $0x25
  801a90:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	eb 03                	jmp    801a9a <vprintfmt+0x39a>
  801a97:	83 ef 01             	sub    $0x1,%edi
  801a9a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a9e:	75 f7                	jne    801a97 <vprintfmt+0x397>
  801aa0:	e9 81 fc ff ff       	jmp    801726 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5f                   	pop    %edi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	83 ec 18             	sub    $0x18,%esp
  801ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801abc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ac0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ac3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801aca:	85 c0                	test   %eax,%eax
  801acc:	74 26                	je     801af4 <vsnprintf+0x47>
  801ace:	85 d2                	test   %edx,%edx
  801ad0:	7e 22                	jle    801af4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ad2:	ff 75 14             	pushl  0x14(%ebp)
  801ad5:	ff 75 10             	pushl  0x10(%ebp)
  801ad8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801adb:	50                   	push   %eax
  801adc:	68 c6 16 80 00       	push   $0x8016c6
  801ae1:	e8 1a fc ff ff       	call   801700 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	eb 05                	jmp    801af9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801af4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b01:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b04:	50                   	push   %eax
  801b05:	ff 75 10             	pushl  0x10(%ebp)
  801b08:	ff 75 0c             	pushl  0xc(%ebp)
  801b0b:	ff 75 08             	pushl  0x8(%ebp)
  801b0e:	e8 9a ff ff ff       	call   801aad <vsnprintf>
	va_end(ap);

	return rc;
}
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b20:	eb 03                	jmp    801b25 <strlen+0x10>
		n++;
  801b22:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b25:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b29:	75 f7                	jne    801b22 <strlen+0xd>
		n++;
	return n;
}
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b33:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b36:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3b:	eb 03                	jmp    801b40 <strnlen+0x13>
		n++;
  801b3d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b40:	39 c2                	cmp    %eax,%edx
  801b42:	74 08                	je     801b4c <strnlen+0x1f>
  801b44:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b48:	75 f3                	jne    801b3d <strnlen+0x10>
  801b4a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	53                   	push   %ebx
  801b52:	8b 45 08             	mov    0x8(%ebp),%eax
  801b55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b58:	89 c2                	mov    %eax,%edx
  801b5a:	83 c2 01             	add    $0x1,%edx
  801b5d:	83 c1 01             	add    $0x1,%ecx
  801b60:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b64:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b67:	84 db                	test   %bl,%bl
  801b69:	75 ef                	jne    801b5a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b6b:	5b                   	pop    %ebx
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b75:	53                   	push   %ebx
  801b76:	e8 9a ff ff ff       	call   801b15 <strlen>
  801b7b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b7e:	ff 75 0c             	pushl  0xc(%ebp)
  801b81:	01 d8                	add    %ebx,%eax
  801b83:	50                   	push   %eax
  801b84:	e8 c5 ff ff ff       	call   801b4e <strcpy>
	return dst;
}
  801b89:	89 d8                	mov    %ebx,%eax
  801b8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8e:	c9                   	leave  
  801b8f:	c3                   	ret    

00801b90 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	56                   	push   %esi
  801b94:	53                   	push   %ebx
  801b95:	8b 75 08             	mov    0x8(%ebp),%esi
  801b98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9b:	89 f3                	mov    %esi,%ebx
  801b9d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba0:	89 f2                	mov    %esi,%edx
  801ba2:	eb 0f                	jmp    801bb3 <strncpy+0x23>
		*dst++ = *src;
  801ba4:	83 c2 01             	add    $0x1,%edx
  801ba7:	0f b6 01             	movzbl (%ecx),%eax
  801baa:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bad:	80 39 01             	cmpb   $0x1,(%ecx)
  801bb0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bb3:	39 da                	cmp    %ebx,%edx
  801bb5:	75 ed                	jne    801ba4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bb7:	89 f0                	mov    %esi,%eax
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	56                   	push   %esi
  801bc1:	53                   	push   %ebx
  801bc2:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc8:	8b 55 10             	mov    0x10(%ebp),%edx
  801bcb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bcd:	85 d2                	test   %edx,%edx
  801bcf:	74 21                	je     801bf2 <strlcpy+0x35>
  801bd1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd5:	89 f2                	mov    %esi,%edx
  801bd7:	eb 09                	jmp    801be2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd9:	83 c2 01             	add    $0x1,%edx
  801bdc:	83 c1 01             	add    $0x1,%ecx
  801bdf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801be2:	39 c2                	cmp    %eax,%edx
  801be4:	74 09                	je     801bef <strlcpy+0x32>
  801be6:	0f b6 19             	movzbl (%ecx),%ebx
  801be9:	84 db                	test   %bl,%bl
  801beb:	75 ec                	jne    801bd9 <strlcpy+0x1c>
  801bed:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bf2:	29 f0                	sub    %esi,%eax
}
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c01:	eb 06                	jmp    801c09 <strcmp+0x11>
		p++, q++;
  801c03:	83 c1 01             	add    $0x1,%ecx
  801c06:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c09:	0f b6 01             	movzbl (%ecx),%eax
  801c0c:	84 c0                	test   %al,%al
  801c0e:	74 04                	je     801c14 <strcmp+0x1c>
  801c10:	3a 02                	cmp    (%edx),%al
  801c12:	74 ef                	je     801c03 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c14:	0f b6 c0             	movzbl %al,%eax
  801c17:	0f b6 12             	movzbl (%edx),%edx
  801c1a:	29 d0                	sub    %edx,%eax
}
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	53                   	push   %ebx
  801c22:	8b 45 08             	mov    0x8(%ebp),%eax
  801c25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c2d:	eb 06                	jmp    801c35 <strncmp+0x17>
		n--, p++, q++;
  801c2f:	83 c0 01             	add    $0x1,%eax
  801c32:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c35:	39 d8                	cmp    %ebx,%eax
  801c37:	74 15                	je     801c4e <strncmp+0x30>
  801c39:	0f b6 08             	movzbl (%eax),%ecx
  801c3c:	84 c9                	test   %cl,%cl
  801c3e:	74 04                	je     801c44 <strncmp+0x26>
  801c40:	3a 0a                	cmp    (%edx),%cl
  801c42:	74 eb                	je     801c2f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c44:	0f b6 00             	movzbl (%eax),%eax
  801c47:	0f b6 12             	movzbl (%edx),%edx
  801c4a:	29 d0                	sub    %edx,%eax
  801c4c:	eb 05                	jmp    801c53 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c53:	5b                   	pop    %ebx
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c60:	eb 07                	jmp    801c69 <strchr+0x13>
		if (*s == c)
  801c62:	38 ca                	cmp    %cl,%dl
  801c64:	74 0f                	je     801c75 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c66:	83 c0 01             	add    $0x1,%eax
  801c69:	0f b6 10             	movzbl (%eax),%edx
  801c6c:	84 d2                	test   %dl,%dl
  801c6e:	75 f2                	jne    801c62 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c81:	eb 03                	jmp    801c86 <strfind+0xf>
  801c83:	83 c0 01             	add    $0x1,%eax
  801c86:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c89:	38 ca                	cmp    %cl,%dl
  801c8b:	74 04                	je     801c91 <strfind+0x1a>
  801c8d:	84 d2                	test   %dl,%dl
  801c8f:	75 f2                	jne    801c83 <strfind+0xc>
			break;
	return (char *) s;
}
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	57                   	push   %edi
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c9f:	85 c9                	test   %ecx,%ecx
  801ca1:	74 36                	je     801cd9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ca3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca9:	75 28                	jne    801cd3 <memset+0x40>
  801cab:	f6 c1 03             	test   $0x3,%cl
  801cae:	75 23                	jne    801cd3 <memset+0x40>
		c &= 0xFF;
  801cb0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cb4:	89 d3                	mov    %edx,%ebx
  801cb6:	c1 e3 08             	shl    $0x8,%ebx
  801cb9:	89 d6                	mov    %edx,%esi
  801cbb:	c1 e6 18             	shl    $0x18,%esi
  801cbe:	89 d0                	mov    %edx,%eax
  801cc0:	c1 e0 10             	shl    $0x10,%eax
  801cc3:	09 f0                	or     %esi,%eax
  801cc5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cc7:	89 d8                	mov    %ebx,%eax
  801cc9:	09 d0                	or     %edx,%eax
  801ccb:	c1 e9 02             	shr    $0x2,%ecx
  801cce:	fc                   	cld    
  801ccf:	f3 ab                	rep stos %eax,%es:(%edi)
  801cd1:	eb 06                	jmp    801cd9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd6:	fc                   	cld    
  801cd7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd9:	89 f8                	mov    %edi,%eax
  801cdb:	5b                   	pop    %ebx
  801cdc:	5e                   	pop    %esi
  801cdd:	5f                   	pop    %edi
  801cde:	5d                   	pop    %ebp
  801cdf:	c3                   	ret    

00801ce0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	57                   	push   %edi
  801ce4:	56                   	push   %esi
  801ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ceb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cee:	39 c6                	cmp    %eax,%esi
  801cf0:	73 35                	jae    801d27 <memmove+0x47>
  801cf2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf5:	39 d0                	cmp    %edx,%eax
  801cf7:	73 2e                	jae    801d27 <memmove+0x47>
		s += n;
		d += n;
  801cf9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cfc:	89 d6                	mov    %edx,%esi
  801cfe:	09 fe                	or     %edi,%esi
  801d00:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d06:	75 13                	jne    801d1b <memmove+0x3b>
  801d08:	f6 c1 03             	test   $0x3,%cl
  801d0b:	75 0e                	jne    801d1b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d0d:	83 ef 04             	sub    $0x4,%edi
  801d10:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d13:	c1 e9 02             	shr    $0x2,%ecx
  801d16:	fd                   	std    
  801d17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d19:	eb 09                	jmp    801d24 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d1b:	83 ef 01             	sub    $0x1,%edi
  801d1e:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d21:	fd                   	std    
  801d22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d24:	fc                   	cld    
  801d25:	eb 1d                	jmp    801d44 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d27:	89 f2                	mov    %esi,%edx
  801d29:	09 c2                	or     %eax,%edx
  801d2b:	f6 c2 03             	test   $0x3,%dl
  801d2e:	75 0f                	jne    801d3f <memmove+0x5f>
  801d30:	f6 c1 03             	test   $0x3,%cl
  801d33:	75 0a                	jne    801d3f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d35:	c1 e9 02             	shr    $0x2,%ecx
  801d38:	89 c7                	mov    %eax,%edi
  801d3a:	fc                   	cld    
  801d3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d3d:	eb 05                	jmp    801d44 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d3f:	89 c7                	mov    %eax,%edi
  801d41:	fc                   	cld    
  801d42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d44:	5e                   	pop    %esi
  801d45:	5f                   	pop    %edi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    

00801d48 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d4b:	ff 75 10             	pushl  0x10(%ebp)
  801d4e:	ff 75 0c             	pushl  0xc(%ebp)
  801d51:	ff 75 08             	pushl  0x8(%ebp)
  801d54:	e8 87 ff ff ff       	call   801ce0 <memmove>
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	56                   	push   %esi
  801d5f:	53                   	push   %ebx
  801d60:	8b 45 08             	mov    0x8(%ebp),%eax
  801d63:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d66:	89 c6                	mov    %eax,%esi
  801d68:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d6b:	eb 1a                	jmp    801d87 <memcmp+0x2c>
		if (*s1 != *s2)
  801d6d:	0f b6 08             	movzbl (%eax),%ecx
  801d70:	0f b6 1a             	movzbl (%edx),%ebx
  801d73:	38 d9                	cmp    %bl,%cl
  801d75:	74 0a                	je     801d81 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d77:	0f b6 c1             	movzbl %cl,%eax
  801d7a:	0f b6 db             	movzbl %bl,%ebx
  801d7d:	29 d8                	sub    %ebx,%eax
  801d7f:	eb 0f                	jmp    801d90 <memcmp+0x35>
		s1++, s2++;
  801d81:	83 c0 01             	add    $0x1,%eax
  801d84:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d87:	39 f0                	cmp    %esi,%eax
  801d89:	75 e2                	jne    801d6d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    

00801d94 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	53                   	push   %ebx
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d9b:	89 c1                	mov    %eax,%ecx
  801d9d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801da0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da4:	eb 0a                	jmp    801db0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da6:	0f b6 10             	movzbl (%eax),%edx
  801da9:	39 da                	cmp    %ebx,%edx
  801dab:	74 07                	je     801db4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dad:	83 c0 01             	add    $0x1,%eax
  801db0:	39 c8                	cmp    %ecx,%eax
  801db2:	72 f2                	jb     801da6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801db4:	5b                   	pop    %ebx
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	57                   	push   %edi
  801dbb:	56                   	push   %esi
  801dbc:	53                   	push   %ebx
  801dbd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc3:	eb 03                	jmp    801dc8 <strtol+0x11>
		s++;
  801dc5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc8:	0f b6 01             	movzbl (%ecx),%eax
  801dcb:	3c 20                	cmp    $0x20,%al
  801dcd:	74 f6                	je     801dc5 <strtol+0xe>
  801dcf:	3c 09                	cmp    $0x9,%al
  801dd1:	74 f2                	je     801dc5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dd3:	3c 2b                	cmp    $0x2b,%al
  801dd5:	75 0a                	jne    801de1 <strtol+0x2a>
		s++;
  801dd7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dda:	bf 00 00 00 00       	mov    $0x0,%edi
  801ddf:	eb 11                	jmp    801df2 <strtol+0x3b>
  801de1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801de6:	3c 2d                	cmp    $0x2d,%al
  801de8:	75 08                	jne    801df2 <strtol+0x3b>
		s++, neg = 1;
  801dea:	83 c1 01             	add    $0x1,%ecx
  801ded:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df8:	75 15                	jne    801e0f <strtol+0x58>
  801dfa:	80 39 30             	cmpb   $0x30,(%ecx)
  801dfd:	75 10                	jne    801e0f <strtol+0x58>
  801dff:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e03:	75 7c                	jne    801e81 <strtol+0xca>
		s += 2, base = 16;
  801e05:	83 c1 02             	add    $0x2,%ecx
  801e08:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e0d:	eb 16                	jmp    801e25 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e0f:	85 db                	test   %ebx,%ebx
  801e11:	75 12                	jne    801e25 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e13:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e18:	80 39 30             	cmpb   $0x30,(%ecx)
  801e1b:	75 08                	jne    801e25 <strtol+0x6e>
		s++, base = 8;
  801e1d:	83 c1 01             	add    $0x1,%ecx
  801e20:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e25:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e2d:	0f b6 11             	movzbl (%ecx),%edx
  801e30:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e33:	89 f3                	mov    %esi,%ebx
  801e35:	80 fb 09             	cmp    $0x9,%bl
  801e38:	77 08                	ja     801e42 <strtol+0x8b>
			dig = *s - '0';
  801e3a:	0f be d2             	movsbl %dl,%edx
  801e3d:	83 ea 30             	sub    $0x30,%edx
  801e40:	eb 22                	jmp    801e64 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e42:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e45:	89 f3                	mov    %esi,%ebx
  801e47:	80 fb 19             	cmp    $0x19,%bl
  801e4a:	77 08                	ja     801e54 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e4c:	0f be d2             	movsbl %dl,%edx
  801e4f:	83 ea 57             	sub    $0x57,%edx
  801e52:	eb 10                	jmp    801e64 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e54:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e57:	89 f3                	mov    %esi,%ebx
  801e59:	80 fb 19             	cmp    $0x19,%bl
  801e5c:	77 16                	ja     801e74 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e5e:	0f be d2             	movsbl %dl,%edx
  801e61:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e64:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e67:	7d 0b                	jge    801e74 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e69:	83 c1 01             	add    $0x1,%ecx
  801e6c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e70:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e72:	eb b9                	jmp    801e2d <strtol+0x76>

	if (endptr)
  801e74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e78:	74 0d                	je     801e87 <strtol+0xd0>
		*endptr = (char *) s;
  801e7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e7d:	89 0e                	mov    %ecx,(%esi)
  801e7f:	eb 06                	jmp    801e87 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e81:	85 db                	test   %ebx,%ebx
  801e83:	74 98                	je     801e1d <strtol+0x66>
  801e85:	eb 9e                	jmp    801e25 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e87:	89 c2                	mov    %eax,%edx
  801e89:	f7 da                	neg    %edx
  801e8b:	85 ff                	test   %edi,%edi
  801e8d:	0f 45 c2             	cmovne %edx,%eax
}
  801e90:	5b                   	pop    %ebx
  801e91:	5e                   	pop    %esi
  801e92:	5f                   	pop    %edi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	56                   	push   %esi
  801e99:	53                   	push   %ebx
  801e9a:	8b 75 08             	mov    0x8(%ebp),%esi
  801e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ea3:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801ea5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801eaa:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801ead:	83 ec 0c             	sub    $0xc,%esp
  801eb0:	50                   	push   %eax
  801eb1:	e8 60 e4 ff ff       	call   800316 <sys_ipc_recv>

	if (r < 0) {
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	79 16                	jns    801ed3 <ipc_recv+0x3e>
		if (from_env_store)
  801ebd:	85 f6                	test   %esi,%esi
  801ebf:	74 06                	je     801ec7 <ipc_recv+0x32>
			*from_env_store = 0;
  801ec1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801ec7:	85 db                	test   %ebx,%ebx
  801ec9:	74 2c                	je     801ef7 <ipc_recv+0x62>
			*perm_store = 0;
  801ecb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ed1:	eb 24                	jmp    801ef7 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801ed3:	85 f6                	test   %esi,%esi
  801ed5:	74 0a                	je     801ee1 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ed7:	a1 08 40 80 00       	mov    0x804008,%eax
  801edc:	8b 40 74             	mov    0x74(%eax),%eax
  801edf:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801ee1:	85 db                	test   %ebx,%ebx
  801ee3:	74 0a                	je     801eef <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801ee5:	a1 08 40 80 00       	mov    0x804008,%eax
  801eea:	8b 40 78             	mov    0x78(%eax),%eax
  801eed:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801eef:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef4:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801ef7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efa:	5b                   	pop    %ebx
  801efb:	5e                   	pop    %esi
  801efc:	5d                   	pop    %ebp
  801efd:	c3                   	ret    

00801efe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 0c             	sub    $0xc,%esp
  801f07:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f10:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f12:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f17:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f1a:	ff 75 14             	pushl  0x14(%ebp)
  801f1d:	53                   	push   %ebx
  801f1e:	56                   	push   %esi
  801f1f:	57                   	push   %edi
  801f20:	e8 ce e3 ff ff       	call   8002f3 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f2b:	75 07                	jne    801f34 <ipc_send+0x36>
			sys_yield();
  801f2d:	e8 15 e2 ff ff       	call   800147 <sys_yield>
  801f32:	eb e6                	jmp    801f1a <ipc_send+0x1c>
		} else if (r < 0) {
  801f34:	85 c0                	test   %eax,%eax
  801f36:	79 12                	jns    801f4a <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f38:	50                   	push   %eax
  801f39:	68 00 27 80 00       	push   $0x802700
  801f3e:	6a 51                	push   $0x51
  801f40:	68 0d 27 80 00       	push   $0x80270d
  801f45:	e8 a6 f5 ff ff       	call   8014f0 <_panic>
		}
	}
}
  801f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5f                   	pop    %edi
  801f50:	5d                   	pop    %ebp
  801f51:	c3                   	ret    

00801f52 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f52:	55                   	push   %ebp
  801f53:	89 e5                	mov    %esp,%ebp
  801f55:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f58:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f5d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f60:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f66:	8b 52 50             	mov    0x50(%edx),%edx
  801f69:	39 ca                	cmp    %ecx,%edx
  801f6b:	75 0d                	jne    801f7a <ipc_find_env+0x28>
			return envs[i].env_id;
  801f6d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f70:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f75:	8b 40 48             	mov    0x48(%eax),%eax
  801f78:	eb 0f                	jmp    801f89 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7a:	83 c0 01             	add    $0x1,%eax
  801f7d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f82:	75 d9                	jne    801f5d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    

00801f8b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f91:	89 d0                	mov    %edx,%eax
  801f93:	c1 e8 16             	shr    $0x16,%eax
  801f96:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa2:	f6 c1 01             	test   $0x1,%cl
  801fa5:	74 1d                	je     801fc4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa7:	c1 ea 0c             	shr    $0xc,%edx
  801faa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb1:	f6 c2 01             	test   $0x1,%dl
  801fb4:	74 0e                	je     801fc4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb6:	c1 ea 0c             	shr    $0xc,%edx
  801fb9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc0:	ef 
  801fc1:	0f b7 c0             	movzwl %ax,%eax
}
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    
  801fc6:	66 90                	xchg   %ax,%ax
  801fc8:	66 90                	xchg   %ax,%ax
  801fca:	66 90                	xchg   %ax,%ax
  801fcc:	66 90                	xchg   %ax,%ax
  801fce:	66 90                	xchg   %ax,%ax

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
