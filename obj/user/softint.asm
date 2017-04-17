
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 a6 04 00 00       	call   800531 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 6a 22 80 00       	push   $0x80226a
  800104:	6a 23                	push   $0x23
  800106:	68 87 22 80 00       	push   $0x802287
  80010b:	e8 d0 13 00 00       	call   8014e0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 6a 22 80 00       	push   $0x80226a
  800185:	6a 23                	push   $0x23
  800187:	68 87 22 80 00       	push   $0x802287
  80018c:	e8 4f 13 00 00       	call   8014e0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 6a 22 80 00       	push   $0x80226a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 87 22 80 00       	push   $0x802287
  8001ce:	e8 0d 13 00 00       	call   8014e0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 6a 22 80 00       	push   $0x80226a
  800209:	6a 23                	push   $0x23
  80020b:	68 87 22 80 00       	push   $0x802287
  800210:	e8 cb 12 00 00       	call   8014e0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 6a 22 80 00       	push   $0x80226a
  80024b:	6a 23                	push   $0x23
  80024d:	68 87 22 80 00       	push   $0x802287
  800252:	e8 89 12 00 00       	call   8014e0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 6a 22 80 00       	push   $0x80226a
  80028d:	6a 23                	push   $0x23
  80028f:	68 87 22 80 00       	push   $0x802287
  800294:	e8 47 12 00 00       	call   8014e0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 6a 22 80 00       	push   $0x80226a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 87 22 80 00       	push   $0x802287
  8002d6:	e8 05 12 00 00       	call   8014e0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 6a 22 80 00       	push   $0x80226a
  800333:	6a 23                	push   $0x23
  800335:	68 87 22 80 00       	push   $0x802287
  80033a:	e8 a1 11 00 00       	call   8014e0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	b8 0e 00 00 00       	mov    $0xe,%eax
  800357:	89 d1                	mov    %edx,%ecx
  800359:	89 d3                	mov    %edx,%ebx
  80035b:	89 d7                	mov    %edx,%edi
  80035d:	89 d6                	mov    %edx,%esi
  80035f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	05 00 00 00 30       	add    $0x30000000,%eax
  800371:	c1 e8 0c             	shr    $0xc,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	05 00 00 00 30       	add    $0x30000000,%eax
  800381:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800386:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800398:	89 c2                	mov    %eax,%edx
  80039a:	c1 ea 16             	shr    $0x16,%edx
  80039d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a4:	f6 c2 01             	test   $0x1,%dl
  8003a7:	74 11                	je     8003ba <fd_alloc+0x2d>
  8003a9:	89 c2                	mov    %eax,%edx
  8003ab:	c1 ea 0c             	shr    $0xc,%edx
  8003ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b5:	f6 c2 01             	test   $0x1,%dl
  8003b8:	75 09                	jne    8003c3 <fd_alloc+0x36>
			*fd_store = fd;
  8003ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c1:	eb 17                	jmp    8003da <fd_alloc+0x4d>
  8003c3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003c8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003cd:	75 c9                	jne    800398 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003cf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e2:	83 f8 1f             	cmp    $0x1f,%eax
  8003e5:	77 36                	ja     80041d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003e7:	c1 e0 0c             	shl    $0xc,%eax
  8003ea:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ef:	89 c2                	mov    %eax,%edx
  8003f1:	c1 ea 16             	shr    $0x16,%edx
  8003f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fb:	f6 c2 01             	test   $0x1,%dl
  8003fe:	74 24                	je     800424 <fd_lookup+0x48>
  800400:	89 c2                	mov    %eax,%edx
  800402:	c1 ea 0c             	shr    $0xc,%edx
  800405:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040c:	f6 c2 01             	test   $0x1,%dl
  80040f:	74 1a                	je     80042b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800411:	8b 55 0c             	mov    0xc(%ebp),%edx
  800414:	89 02                	mov    %eax,(%edx)
	return 0;
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
  80041b:	eb 13                	jmp    800430 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80041d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800422:	eb 0c                	jmp    800430 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800424:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800429:	eb 05                	jmp    800430 <fd_lookup+0x54>
  80042b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043b:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800440:	eb 13                	jmp    800455 <dev_lookup+0x23>
  800442:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800445:	39 08                	cmp    %ecx,(%eax)
  800447:	75 0c                	jne    800455 <dev_lookup+0x23>
			*dev = devtab[i];
  800449:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	eb 2e                	jmp    800483 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	75 e7                	jne    800442 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045b:	a1 08 40 80 00       	mov    0x804008,%eax
  800460:	8b 40 48             	mov    0x48(%eax),%eax
  800463:	83 ec 04             	sub    $0x4,%esp
  800466:	51                   	push   %ecx
  800467:	50                   	push   %eax
  800468:	68 98 22 80 00       	push   $0x802298
  80046d:	e8 47 11 00 00       	call   8015b9 <cprintf>
	*dev = 0;
  800472:	8b 45 0c             	mov    0xc(%ebp),%eax
  800475:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	56                   	push   %esi
  800489:	53                   	push   %ebx
  80048a:	83 ec 10             	sub    $0x10,%esp
  80048d:	8b 75 08             	mov    0x8(%ebp),%esi
  800490:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800496:	50                   	push   %eax
  800497:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80049d:	c1 e8 0c             	shr    $0xc,%eax
  8004a0:	50                   	push   %eax
  8004a1:	e8 36 ff ff ff       	call   8003dc <fd_lookup>
  8004a6:	83 c4 08             	add    $0x8,%esp
  8004a9:	85 c0                	test   %eax,%eax
  8004ab:	78 05                	js     8004b2 <fd_close+0x2d>
	    || fd != fd2)
  8004ad:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b0:	74 0c                	je     8004be <fd_close+0x39>
		return (must_exist ? r : 0);
  8004b2:	84 db                	test   %bl,%bl
  8004b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b9:	0f 44 c2             	cmove  %edx,%eax
  8004bc:	eb 41                	jmp    8004ff <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c4:	50                   	push   %eax
  8004c5:	ff 36                	pushl  (%esi)
  8004c7:	e8 66 ff ff ff       	call   800432 <dev_lookup>
  8004cc:	89 c3                	mov    %eax,%ebx
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	78 1a                	js     8004ef <fd_close+0x6a>
		if (dev->dev_close)
  8004d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004db:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	74 0b                	je     8004ef <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004e4:	83 ec 0c             	sub    $0xc,%esp
  8004e7:	56                   	push   %esi
  8004e8:	ff d0                	call   *%eax
  8004ea:	89 c3                	mov    %eax,%ebx
  8004ec:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	6a 00                	push   $0x0
  8004f5:	e8 e1 fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	89 d8                	mov    %ebx,%eax
}
  8004ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800502:	5b                   	pop    %ebx
  800503:	5e                   	pop    %esi
  800504:	5d                   	pop    %ebp
  800505:	c3                   	ret    

00800506 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 c4 fe ff ff       	call   8003dc <fd_lookup>
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	85 c0                	test   %eax,%eax
  80051d:	78 10                	js     80052f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	6a 01                	push   $0x1
  800524:	ff 75 f4             	pushl  -0xc(%ebp)
  800527:	e8 59 ff ff ff       	call   800485 <fd_close>
  80052c:	83 c4 10             	add    $0x10,%esp
}
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <close_all>:

void
close_all(void)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	53                   	push   %ebx
  800535:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800538:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	53                   	push   %ebx
  800541:	e8 c0 ff ff ff       	call   800506 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800546:	83 c3 01             	add    $0x1,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	83 fb 20             	cmp    $0x20,%ebx
  80054f:	75 ec                	jne    80053d <close_all+0xc>
		close(i);
}
  800551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	57                   	push   %edi
  80055a:	56                   	push   %esi
  80055b:	53                   	push   %ebx
  80055c:	83 ec 2c             	sub    $0x2c,%esp
  80055f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800562:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800565:	50                   	push   %eax
  800566:	ff 75 08             	pushl  0x8(%ebp)
  800569:	e8 6e fe ff ff       	call   8003dc <fd_lookup>
  80056e:	83 c4 08             	add    $0x8,%esp
  800571:	85 c0                	test   %eax,%eax
  800573:	0f 88 c1 00 00 00    	js     80063a <dup+0xe4>
		return r;
	close(newfdnum);
  800579:	83 ec 0c             	sub    $0xc,%esp
  80057c:	56                   	push   %esi
  80057d:	e8 84 ff ff ff       	call   800506 <close>

	newfd = INDEX2FD(newfdnum);
  800582:	89 f3                	mov    %esi,%ebx
  800584:	c1 e3 0c             	shl    $0xc,%ebx
  800587:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80058d:	83 c4 04             	add    $0x4,%esp
  800590:	ff 75 e4             	pushl  -0x1c(%ebp)
  800593:	e8 de fd ff ff       	call   800376 <fd2data>
  800598:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80059a:	89 1c 24             	mov    %ebx,(%esp)
  80059d:	e8 d4 fd ff ff       	call   800376 <fd2data>
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a8:	89 f8                	mov    %edi,%eax
  8005aa:	c1 e8 16             	shr    $0x16,%eax
  8005ad:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b4:	a8 01                	test   $0x1,%al
  8005b6:	74 37                	je     8005ef <dup+0x99>
  8005b8:	89 f8                	mov    %edi,%eax
  8005ba:	c1 e8 0c             	shr    $0xc,%eax
  8005bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c4:	f6 c2 01             	test   $0x1,%dl
  8005c7:	74 26                	je     8005ef <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d0:	83 ec 0c             	sub    $0xc,%esp
  8005d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d8:	50                   	push   %eax
  8005d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005dc:	6a 00                	push   $0x0
  8005de:	57                   	push   %edi
  8005df:	6a 00                	push   $0x0
  8005e1:	e8 b3 fb ff ff       	call   800199 <sys_page_map>
  8005e6:	89 c7                	mov    %eax,%edi
  8005e8:	83 c4 20             	add    $0x20,%esp
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	78 2e                	js     80061d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f2:	89 d0                	mov    %edx,%eax
  8005f4:	c1 e8 0c             	shr    $0xc,%eax
  8005f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fe:	83 ec 0c             	sub    $0xc,%esp
  800601:	25 07 0e 00 00       	and    $0xe07,%eax
  800606:	50                   	push   %eax
  800607:	53                   	push   %ebx
  800608:	6a 00                	push   $0x0
  80060a:	52                   	push   %edx
  80060b:	6a 00                	push   $0x0
  80060d:	e8 87 fb ff ff       	call   800199 <sys_page_map>
  800612:	89 c7                	mov    %eax,%edi
  800614:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800617:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800619:	85 ff                	test   %edi,%edi
  80061b:	79 1d                	jns    80063a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 00                	push   $0x0
  800623:	e8 b3 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800628:	83 c4 08             	add    $0x8,%esp
  80062b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80062e:	6a 00                	push   $0x0
  800630:	e8 a6 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800635:	83 c4 10             	add    $0x10,%esp
  800638:	89 f8                	mov    %edi,%eax
}
  80063a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063d:	5b                   	pop    %ebx
  80063e:	5e                   	pop    %esi
  80063f:	5f                   	pop    %edi
  800640:	5d                   	pop    %ebp
  800641:	c3                   	ret    

00800642 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	53                   	push   %ebx
  800646:	83 ec 14             	sub    $0x14,%esp
  800649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	53                   	push   %ebx
  800651:	e8 86 fd ff ff       	call   8003dc <fd_lookup>
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	89 c2                	mov    %eax,%edx
  80065b:	85 c0                	test   %eax,%eax
  80065d:	78 6d                	js     8006cc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800665:	50                   	push   %eax
  800666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800669:	ff 30                	pushl  (%eax)
  80066b:	e8 c2 fd ff ff       	call   800432 <dev_lookup>
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	85 c0                	test   %eax,%eax
  800675:	78 4c                	js     8006c3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800677:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80067a:	8b 42 08             	mov    0x8(%edx),%eax
  80067d:	83 e0 03             	and    $0x3,%eax
  800680:	83 f8 01             	cmp    $0x1,%eax
  800683:	75 21                	jne    8006a6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800685:	a1 08 40 80 00       	mov    0x804008,%eax
  80068a:	8b 40 48             	mov    0x48(%eax),%eax
  80068d:	83 ec 04             	sub    $0x4,%esp
  800690:	53                   	push   %ebx
  800691:	50                   	push   %eax
  800692:	68 d9 22 80 00       	push   $0x8022d9
  800697:	e8 1d 0f 00 00       	call   8015b9 <cprintf>
		return -E_INVAL;
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a4:	eb 26                	jmp    8006cc <read+0x8a>
	}
	if (!dev->dev_read)
  8006a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a9:	8b 40 08             	mov    0x8(%eax),%eax
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	74 17                	je     8006c7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b0:	83 ec 04             	sub    $0x4,%esp
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	ff 75 0c             	pushl  0xc(%ebp)
  8006b9:	52                   	push   %edx
  8006ba:	ff d0                	call   *%eax
  8006bc:	89 c2                	mov    %eax,%edx
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb 09                	jmp    8006cc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c3:	89 c2                	mov    %eax,%edx
  8006c5:	eb 05                	jmp    8006cc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006cc:	89 d0                	mov    %edx,%eax
  8006ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d1:	c9                   	leave  
  8006d2:	c3                   	ret    

008006d3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d3:	55                   	push   %ebp
  8006d4:	89 e5                	mov    %esp,%ebp
  8006d6:	57                   	push   %edi
  8006d7:	56                   	push   %esi
  8006d8:	53                   	push   %ebx
  8006d9:	83 ec 0c             	sub    $0xc,%esp
  8006dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e7:	eb 21                	jmp    80070a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e9:	83 ec 04             	sub    $0x4,%esp
  8006ec:	89 f0                	mov    %esi,%eax
  8006ee:	29 d8                	sub    %ebx,%eax
  8006f0:	50                   	push   %eax
  8006f1:	89 d8                	mov    %ebx,%eax
  8006f3:	03 45 0c             	add    0xc(%ebp),%eax
  8006f6:	50                   	push   %eax
  8006f7:	57                   	push   %edi
  8006f8:	e8 45 ff ff ff       	call   800642 <read>
		if (m < 0)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	85 c0                	test   %eax,%eax
  800702:	78 10                	js     800714 <readn+0x41>
			return m;
		if (m == 0)
  800704:	85 c0                	test   %eax,%eax
  800706:	74 0a                	je     800712 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800708:	01 c3                	add    %eax,%ebx
  80070a:	39 f3                	cmp    %esi,%ebx
  80070c:	72 db                	jb     8006e9 <readn+0x16>
  80070e:	89 d8                	mov    %ebx,%eax
  800710:	eb 02                	jmp    800714 <readn+0x41>
  800712:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800714:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800717:	5b                   	pop    %ebx
  800718:	5e                   	pop    %esi
  800719:	5f                   	pop    %edi
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	83 ec 14             	sub    $0x14,%esp
  800723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800726:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	53                   	push   %ebx
  80072b:	e8 ac fc ff ff       	call   8003dc <fd_lookup>
  800730:	83 c4 08             	add    $0x8,%esp
  800733:	89 c2                	mov    %eax,%edx
  800735:	85 c0                	test   %eax,%eax
  800737:	78 68                	js     8007a1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073f:	50                   	push   %eax
  800740:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800743:	ff 30                	pushl  (%eax)
  800745:	e8 e8 fc ff ff       	call   800432 <dev_lookup>
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	85 c0                	test   %eax,%eax
  80074f:	78 47                	js     800798 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800751:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800754:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800758:	75 21                	jne    80077b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075a:	a1 08 40 80 00       	mov    0x804008,%eax
  80075f:	8b 40 48             	mov    0x48(%eax),%eax
  800762:	83 ec 04             	sub    $0x4,%esp
  800765:	53                   	push   %ebx
  800766:	50                   	push   %eax
  800767:	68 f5 22 80 00       	push   $0x8022f5
  80076c:	e8 48 0e 00 00       	call   8015b9 <cprintf>
		return -E_INVAL;
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800779:	eb 26                	jmp    8007a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077e:	8b 52 0c             	mov    0xc(%edx),%edx
  800781:	85 d2                	test   %edx,%edx
  800783:	74 17                	je     80079c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800785:	83 ec 04             	sub    $0x4,%esp
  800788:	ff 75 10             	pushl  0x10(%ebp)
  80078b:	ff 75 0c             	pushl  0xc(%ebp)
  80078e:	50                   	push   %eax
  80078f:	ff d2                	call   *%edx
  800791:	89 c2                	mov    %eax,%edx
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 09                	jmp    8007a1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800798:	89 c2                	mov    %eax,%edx
  80079a:	eb 05                	jmp    8007a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80079c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a1:	89 d0                	mov    %edx,%eax
  8007a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ae:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	ff 75 08             	pushl  0x8(%ebp)
  8007b5:	e8 22 fc ff ff       	call   8003dc <fd_lookup>
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	78 0e                	js     8007cf <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	53                   	push   %ebx
  8007d5:	83 ec 14             	sub    $0x14,%esp
  8007d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007de:	50                   	push   %eax
  8007df:	53                   	push   %ebx
  8007e0:	e8 f7 fb ff ff       	call   8003dc <fd_lookup>
  8007e5:	83 c4 08             	add    $0x8,%esp
  8007e8:	89 c2                	mov    %eax,%edx
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	78 65                	js     800853 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f4:	50                   	push   %eax
  8007f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f8:	ff 30                	pushl  (%eax)
  8007fa:	e8 33 fc ff ff       	call   800432 <dev_lookup>
  8007ff:	83 c4 10             	add    $0x10,%esp
  800802:	85 c0                	test   %eax,%eax
  800804:	78 44                	js     80084a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800806:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800809:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080d:	75 21                	jne    800830 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80080f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800814:	8b 40 48             	mov    0x48(%eax),%eax
  800817:	83 ec 04             	sub    $0x4,%esp
  80081a:	53                   	push   %ebx
  80081b:	50                   	push   %eax
  80081c:	68 b8 22 80 00       	push   $0x8022b8
  800821:	e8 93 0d 00 00       	call   8015b9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80082e:	eb 23                	jmp    800853 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800830:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800833:	8b 52 18             	mov    0x18(%edx),%edx
  800836:	85 d2                	test   %edx,%edx
  800838:	74 14                	je     80084e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	ff 75 0c             	pushl  0xc(%ebp)
  800840:	50                   	push   %eax
  800841:	ff d2                	call   *%edx
  800843:	89 c2                	mov    %eax,%edx
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	eb 09                	jmp    800853 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084a:	89 c2                	mov    %eax,%edx
  80084c:	eb 05                	jmp    800853 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80084e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800853:	89 d0                	mov    %edx,%eax
  800855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	83 ec 14             	sub    $0x14,%esp
  800861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800864:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800867:	50                   	push   %eax
  800868:	ff 75 08             	pushl  0x8(%ebp)
  80086b:	e8 6c fb ff ff       	call   8003dc <fd_lookup>
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	89 c2                	mov    %eax,%edx
  800875:	85 c0                	test   %eax,%eax
  800877:	78 58                	js     8008d1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800879:	83 ec 08             	sub    $0x8,%esp
  80087c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800883:	ff 30                	pushl  (%eax)
  800885:	e8 a8 fb ff ff       	call   800432 <dev_lookup>
  80088a:	83 c4 10             	add    $0x10,%esp
  80088d:	85 c0                	test   %eax,%eax
  80088f:	78 37                	js     8008c8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800891:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800894:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800898:	74 32                	je     8008cc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80089a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80089d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a4:	00 00 00 
	stat->st_isdir = 0;
  8008a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ae:	00 00 00 
	stat->st_dev = dev;
  8008b1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8008be:	ff 50 14             	call   *0x14(%eax)
  8008c1:	89 c2                	mov    %eax,%edx
  8008c3:	83 c4 10             	add    $0x10,%esp
  8008c6:	eb 09                	jmp    8008d1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c8:	89 c2                	mov    %eax,%edx
  8008ca:	eb 05                	jmp    8008d1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d1:	89 d0                	mov    %edx,%eax
  8008d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	6a 00                	push   $0x0
  8008e2:	ff 75 08             	pushl  0x8(%ebp)
  8008e5:	e8 0c 02 00 00       	call   800af6 <open>
  8008ea:	89 c3                	mov    %eax,%ebx
  8008ec:	83 c4 10             	add    $0x10,%esp
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	78 1b                	js     80090e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f3:	83 ec 08             	sub    $0x8,%esp
  8008f6:	ff 75 0c             	pushl  0xc(%ebp)
  8008f9:	50                   	push   %eax
  8008fa:	e8 5b ff ff ff       	call   80085a <fstat>
  8008ff:	89 c6                	mov    %eax,%esi
	close(fd);
  800901:	89 1c 24             	mov    %ebx,(%esp)
  800904:	e8 fd fb ff ff       	call   800506 <close>
	return r;
  800909:	83 c4 10             	add    $0x10,%esp
  80090c:	89 f0                	mov    %esi,%eax
}
  80090e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	89 c6                	mov    %eax,%esi
  80091c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80091e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800925:	75 12                	jne    800939 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800927:	83 ec 0c             	sub    $0xc,%esp
  80092a:	6a 01                	push   $0x1
  80092c:	e8 11 16 00 00       	call   801f42 <ipc_find_env>
  800931:	a3 00 40 80 00       	mov    %eax,0x804000
  800936:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800939:	6a 07                	push   $0x7
  80093b:	68 00 50 80 00       	push   $0x805000
  800940:	56                   	push   %esi
  800941:	ff 35 00 40 80 00    	pushl  0x804000
  800947:	e8 a2 15 00 00       	call   801eee <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80094c:	83 c4 0c             	add    $0xc,%esp
  80094f:	6a 00                	push   $0x0
  800951:	53                   	push   %ebx
  800952:	6a 00                	push   $0x0
  800954:	e8 2c 15 00 00       	call   801e85 <ipc_recv>
}
  800959:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 40 0c             	mov    0xc(%eax),%eax
  80096c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800971:	8b 45 0c             	mov    0xc(%ebp),%eax
  800974:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800979:	ba 00 00 00 00       	mov    $0x0,%edx
  80097e:	b8 02 00 00 00       	mov    $0x2,%eax
  800983:	e8 8d ff ff ff       	call   800915 <fsipc>
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    

0080098a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 40 0c             	mov    0xc(%eax),%eax
  800996:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099b:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a5:	e8 6b ff ff ff       	call   800915 <fsipc>
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	53                   	push   %ebx
  8009b0:	83 ec 04             	sub    $0x4,%esp
  8009b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009cb:	e8 45 ff ff ff       	call   800915 <fsipc>
  8009d0:	85 c0                	test   %eax,%eax
  8009d2:	78 2c                	js     800a00 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d4:	83 ec 08             	sub    $0x8,%esp
  8009d7:	68 00 50 80 00       	push   $0x805000
  8009dc:	53                   	push   %ebx
  8009dd:	e8 5c 11 00 00       	call   801b3e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ed:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009f8:	83 c4 10             	add    $0x10,%esp
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	53                   	push   %ebx
  800a09:	83 ec 08             	sub    $0x8,%esp
  800a0c:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a12:	8b 52 0c             	mov    0xc(%edx),%edx
  800a15:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a1b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a20:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a25:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a28:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a2e:	53                   	push   %ebx
  800a2f:	ff 75 0c             	pushl  0xc(%ebp)
  800a32:	68 08 50 80 00       	push   $0x805008
  800a37:	e8 94 12 00 00       	call   801cd0 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  800a3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a41:	b8 04 00 00 00       	mov    $0x4,%eax
  800a46:	e8 ca fe ff ff       	call   800915 <fsipc>
  800a4b:	83 c4 10             	add    $0x10,%esp
  800a4e:	85 c0                	test   %eax,%eax
  800a50:	78 1d                	js     800a6f <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  800a52:	39 d8                	cmp    %ebx,%eax
  800a54:	76 19                	jbe    800a6f <devfile_write+0x6a>
  800a56:	68 28 23 80 00       	push   $0x802328
  800a5b:	68 34 23 80 00       	push   $0x802334
  800a60:	68 a3 00 00 00       	push   $0xa3
  800a65:	68 49 23 80 00       	push   $0x802349
  800a6a:	e8 71 0a 00 00       	call   8014e0 <_panic>
	return r;
}
  800a6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a82:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a87:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	b8 03 00 00 00       	mov    $0x3,%eax
  800a97:	e8 79 fe ff ff       	call   800915 <fsipc>
  800a9c:	89 c3                	mov    %eax,%ebx
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	78 4b                	js     800aed <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa2:	39 c6                	cmp    %eax,%esi
  800aa4:	73 16                	jae    800abc <devfile_read+0x48>
  800aa6:	68 54 23 80 00       	push   $0x802354
  800aab:	68 34 23 80 00       	push   $0x802334
  800ab0:	6a 7c                	push   $0x7c
  800ab2:	68 49 23 80 00       	push   $0x802349
  800ab7:	e8 24 0a 00 00       	call   8014e0 <_panic>
	assert(r <= PGSIZE);
  800abc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac1:	7e 16                	jle    800ad9 <devfile_read+0x65>
  800ac3:	68 5b 23 80 00       	push   $0x80235b
  800ac8:	68 34 23 80 00       	push   $0x802334
  800acd:	6a 7d                	push   $0x7d
  800acf:	68 49 23 80 00       	push   $0x802349
  800ad4:	e8 07 0a 00 00       	call   8014e0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad9:	83 ec 04             	sub    $0x4,%esp
  800adc:	50                   	push   %eax
  800add:	68 00 50 80 00       	push   $0x805000
  800ae2:	ff 75 0c             	pushl  0xc(%ebp)
  800ae5:	e8 e6 11 00 00       	call   801cd0 <memmove>
	return r;
  800aea:	83 c4 10             	add    $0x10,%esp
}
  800aed:	89 d8                	mov    %ebx,%eax
  800aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	53                   	push   %ebx
  800afa:	83 ec 20             	sub    $0x20,%esp
  800afd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b00:	53                   	push   %ebx
  800b01:	e8 ff 0f 00 00       	call   801b05 <strlen>
  800b06:	83 c4 10             	add    $0x10,%esp
  800b09:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0e:	7f 67                	jg     800b77 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b16:	50                   	push   %eax
  800b17:	e8 71 f8 ff ff       	call   80038d <fd_alloc>
  800b1c:	83 c4 10             	add    $0x10,%esp
		return r;
  800b1f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b21:	85 c0                	test   %eax,%eax
  800b23:	78 57                	js     800b7c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	53                   	push   %ebx
  800b29:	68 00 50 80 00       	push   $0x805000
  800b2e:	e8 0b 10 00 00       	call   801b3e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b43:	e8 cd fd ff ff       	call   800915 <fsipc>
  800b48:	89 c3                	mov    %eax,%ebx
  800b4a:	83 c4 10             	add    $0x10,%esp
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	79 14                	jns    800b65 <open+0x6f>
		fd_close(fd, 0);
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	6a 00                	push   $0x0
  800b56:	ff 75 f4             	pushl  -0xc(%ebp)
  800b59:	e8 27 f9 ff ff       	call   800485 <fd_close>
		return r;
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	89 da                	mov    %ebx,%edx
  800b63:	eb 17                	jmp    800b7c <open+0x86>
	}

	return fd2num(fd);
  800b65:	83 ec 0c             	sub    $0xc,%esp
  800b68:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6b:	e8 f6 f7 ff ff       	call   800366 <fd2num>
  800b70:	89 c2                	mov    %eax,%edx
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	eb 05                	jmp    800b7c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b77:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b7c:	89 d0                	mov    %edx,%eax
  800b7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b93:	e8 7d fd ff ff       	call   800915 <fsipc>
}
  800b98:	c9                   	leave  
  800b99:	c3                   	ret    

00800b9a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba0:	68 67 23 80 00       	push   $0x802367
  800ba5:	ff 75 0c             	pushl  0xc(%ebp)
  800ba8:	e8 91 0f 00 00       	call   801b3e <strcpy>
	return 0;
}
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 10             	sub    $0x10,%esp
  800bbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bbe:	53                   	push   %ebx
  800bbf:	e8 b7 13 00 00       	call   801f7b <pageref>
  800bc4:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bcc:	83 f8 01             	cmp    $0x1,%eax
  800bcf:	75 10                	jne    800be1 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bd1:	83 ec 0c             	sub    $0xc,%esp
  800bd4:	ff 73 0c             	pushl  0xc(%ebx)
  800bd7:	e8 c0 02 00 00       	call   800e9c <nsipc_close>
  800bdc:	89 c2                	mov    %eax,%edx
  800bde:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800be1:	89 d0                	mov    %edx,%eax
  800be3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bee:	6a 00                	push   $0x0
  800bf0:	ff 75 10             	pushl  0x10(%ebp)
  800bf3:	ff 75 0c             	pushl  0xc(%ebp)
  800bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf9:	ff 70 0c             	pushl  0xc(%eax)
  800bfc:	e8 78 03 00 00       	call   800f79 <nsipc_send>
}
  800c01:	c9                   	leave  
  800c02:	c3                   	ret    

00800c03 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c09:	6a 00                	push   $0x0
  800c0b:	ff 75 10             	pushl  0x10(%ebp)
  800c0e:	ff 75 0c             	pushl  0xc(%ebp)
  800c11:	8b 45 08             	mov    0x8(%ebp),%eax
  800c14:	ff 70 0c             	pushl  0xc(%eax)
  800c17:	e8 f1 02 00 00       	call   800f0d <nsipc_recv>
}
  800c1c:	c9                   	leave  
  800c1d:	c3                   	ret    

00800c1e <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c24:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c27:	52                   	push   %edx
  800c28:	50                   	push   %eax
  800c29:	e8 ae f7 ff ff       	call   8003dc <fd_lookup>
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	85 c0                	test   %eax,%eax
  800c33:	78 17                	js     800c4c <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c38:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c3e:	39 08                	cmp    %ecx,(%eax)
  800c40:	75 05                	jne    800c47 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c42:	8b 40 0c             	mov    0xc(%eax),%eax
  800c45:	eb 05                	jmp    800c4c <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c47:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 1c             	sub    $0x1c,%esp
  800c56:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c5b:	50                   	push   %eax
  800c5c:	e8 2c f7 ff ff       	call   80038d <fd_alloc>
  800c61:	89 c3                	mov    %eax,%ebx
  800c63:	83 c4 10             	add    $0x10,%esp
  800c66:	85 c0                	test   %eax,%eax
  800c68:	78 1b                	js     800c85 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c6a:	83 ec 04             	sub    $0x4,%esp
  800c6d:	68 07 04 00 00       	push   $0x407
  800c72:	ff 75 f4             	pushl  -0xc(%ebp)
  800c75:	6a 00                	push   $0x0
  800c77:	e8 da f4 ff ff       	call   800156 <sys_page_alloc>
  800c7c:	89 c3                	mov    %eax,%ebx
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	85 c0                	test   %eax,%eax
  800c83:	79 10                	jns    800c95 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c85:	83 ec 0c             	sub    $0xc,%esp
  800c88:	56                   	push   %esi
  800c89:	e8 0e 02 00 00       	call   800e9c <nsipc_close>
		return r;
  800c8e:	83 c4 10             	add    $0x10,%esp
  800c91:	89 d8                	mov    %ebx,%eax
  800c93:	eb 24                	jmp    800cb9 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c95:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800caa:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	e8 b0 f6 ff ff       	call   800366 <fd2num>
  800cb6:	83 c4 10             	add    $0x10,%esp
}
  800cb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc9:	e8 50 ff ff ff       	call   800c1e <fd2sockid>
		return r;
  800cce:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	78 1f                	js     800cf3 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cd4:	83 ec 04             	sub    $0x4,%esp
  800cd7:	ff 75 10             	pushl  0x10(%ebp)
  800cda:	ff 75 0c             	pushl  0xc(%ebp)
  800cdd:	50                   	push   %eax
  800cde:	e8 12 01 00 00       	call   800df5 <nsipc_accept>
  800ce3:	83 c4 10             	add    $0x10,%esp
		return r;
  800ce6:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce8:	85 c0                	test   %eax,%eax
  800cea:	78 07                	js     800cf3 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cec:	e8 5d ff ff ff       	call   800c4e <alloc_sockfd>
  800cf1:	89 c1                	mov    %eax,%ecx
}
  800cf3:	89 c8                	mov    %ecx,%eax
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	e8 19 ff ff ff       	call   800c1e <fd2sockid>
  800d05:	85 c0                	test   %eax,%eax
  800d07:	78 12                	js     800d1b <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d09:	83 ec 04             	sub    $0x4,%esp
  800d0c:	ff 75 10             	pushl  0x10(%ebp)
  800d0f:	ff 75 0c             	pushl  0xc(%ebp)
  800d12:	50                   	push   %eax
  800d13:	e8 2d 01 00 00       	call   800e45 <nsipc_bind>
  800d18:	83 c4 10             	add    $0x10,%esp
}
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <shutdown>:

int
shutdown(int s, int how)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	e8 f3 fe ff ff       	call   800c1e <fd2sockid>
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	78 0f                	js     800d3e <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d2f:	83 ec 08             	sub    $0x8,%esp
  800d32:	ff 75 0c             	pushl  0xc(%ebp)
  800d35:	50                   	push   %eax
  800d36:	e8 3f 01 00 00       	call   800e7a <nsipc_shutdown>
  800d3b:	83 c4 10             	add    $0x10,%esp
}
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	e8 d0 fe ff ff       	call   800c1e <fd2sockid>
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	78 12                	js     800d64 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d52:	83 ec 04             	sub    $0x4,%esp
  800d55:	ff 75 10             	pushl  0x10(%ebp)
  800d58:	ff 75 0c             	pushl  0xc(%ebp)
  800d5b:	50                   	push   %eax
  800d5c:	e8 55 01 00 00       	call   800eb6 <nsipc_connect>
  800d61:	83 c4 10             	add    $0x10,%esp
}
  800d64:	c9                   	leave  
  800d65:	c3                   	ret    

00800d66 <listen>:

int
listen(int s, int backlog)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	e8 aa fe ff ff       	call   800c1e <fd2sockid>
  800d74:	85 c0                	test   %eax,%eax
  800d76:	78 0f                	js     800d87 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d78:	83 ec 08             	sub    $0x8,%esp
  800d7b:	ff 75 0c             	pushl  0xc(%ebp)
  800d7e:	50                   	push   %eax
  800d7f:	e8 67 01 00 00       	call   800eeb <nsipc_listen>
  800d84:	83 c4 10             	add    $0x10,%esp
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d8f:	ff 75 10             	pushl  0x10(%ebp)
  800d92:	ff 75 0c             	pushl  0xc(%ebp)
  800d95:	ff 75 08             	pushl  0x8(%ebp)
  800d98:	e8 3a 02 00 00       	call   800fd7 <nsipc_socket>
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	85 c0                	test   %eax,%eax
  800da2:	78 05                	js     800da9 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800da4:	e8 a5 fe ff ff       	call   800c4e <alloc_sockfd>
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	53                   	push   %ebx
  800daf:	83 ec 04             	sub    $0x4,%esp
  800db2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800db4:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dbb:	75 12                	jne    800dcf <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	6a 02                	push   $0x2
  800dc2:	e8 7b 11 00 00       	call   801f42 <ipc_find_env>
  800dc7:	a3 04 40 80 00       	mov    %eax,0x804004
  800dcc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dcf:	6a 07                	push   $0x7
  800dd1:	68 00 60 80 00       	push   $0x806000
  800dd6:	53                   	push   %ebx
  800dd7:	ff 35 04 40 80 00    	pushl  0x804004
  800ddd:	e8 0c 11 00 00       	call   801eee <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800de2:	83 c4 0c             	add    $0xc,%esp
  800de5:	6a 00                	push   $0x0
  800de7:	6a 00                	push   $0x0
  800de9:	6a 00                	push   $0x0
  800deb:	e8 95 10 00 00       	call   801e85 <ipc_recv>
}
  800df0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df3:	c9                   	leave  
  800df4:	c3                   	ret    

00800df5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
  800dfa:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800e00:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e05:	8b 06                	mov    (%esi),%eax
  800e07:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e11:	e8 95 ff ff ff       	call   800dab <nsipc>
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	78 20                	js     800e3c <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e1c:	83 ec 04             	sub    $0x4,%esp
  800e1f:	ff 35 10 60 80 00    	pushl  0x806010
  800e25:	68 00 60 80 00       	push   $0x806000
  800e2a:	ff 75 0c             	pushl  0xc(%ebp)
  800e2d:	e8 9e 0e 00 00       	call   801cd0 <memmove>
		*addrlen = ret->ret_addrlen;
  800e32:	a1 10 60 80 00       	mov    0x806010,%eax
  800e37:	89 06                	mov    %eax,(%esi)
  800e39:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e3c:	89 d8                	mov    %ebx,%eax
  800e3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	53                   	push   %ebx
  800e49:	83 ec 08             	sub    $0x8,%esp
  800e4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e52:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e57:	53                   	push   %ebx
  800e58:	ff 75 0c             	pushl  0xc(%ebp)
  800e5b:	68 04 60 80 00       	push   $0x806004
  800e60:	e8 6b 0e 00 00       	call   801cd0 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e65:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e6b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e70:	e8 36 ff ff ff       	call   800dab <nsipc>
}
  800e75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e78:	c9                   	leave  
  800e79:	c3                   	ret    

00800e7a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e80:	8b 45 08             	mov    0x8(%ebp),%eax
  800e83:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e90:	b8 03 00 00 00       	mov    $0x3,%eax
  800e95:	e8 11 ff ff ff       	call   800dab <nsipc>
}
  800e9a:	c9                   	leave  
  800e9b:	c3                   	ret    

00800e9c <nsipc_close>:

int
nsipc_close(int s)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eaa:	b8 04 00 00 00       	mov    $0x4,%eax
  800eaf:	e8 f7 fe ff ff       	call   800dab <nsipc>
}
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	53                   	push   %ebx
  800eba:	83 ec 08             	sub    $0x8,%esp
  800ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec3:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ec8:	53                   	push   %ebx
  800ec9:	ff 75 0c             	pushl  0xc(%ebp)
  800ecc:	68 04 60 80 00       	push   $0x806004
  800ed1:	e8 fa 0d 00 00       	call   801cd0 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ed6:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800edc:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee1:	e8 c5 fe ff ff       	call   800dab <nsipc>
}
  800ee6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efc:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f01:	b8 06 00 00 00       	mov    $0x6,%eax
  800f06:	e8 a0 fe ff ff       	call   800dab <nsipc>
}
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f15:	8b 45 08             	mov    0x8(%ebp),%eax
  800f18:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f1d:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f23:	8b 45 14             	mov    0x14(%ebp),%eax
  800f26:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f2b:	b8 07 00 00 00       	mov    $0x7,%eax
  800f30:	e8 76 fe ff ff       	call   800dab <nsipc>
  800f35:	89 c3                	mov    %eax,%ebx
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 35                	js     800f70 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f3b:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f40:	7f 04                	jg     800f46 <nsipc_recv+0x39>
  800f42:	39 c6                	cmp    %eax,%esi
  800f44:	7d 16                	jge    800f5c <nsipc_recv+0x4f>
  800f46:	68 73 23 80 00       	push   $0x802373
  800f4b:	68 34 23 80 00       	push   $0x802334
  800f50:	6a 62                	push   $0x62
  800f52:	68 88 23 80 00       	push   $0x802388
  800f57:	e8 84 05 00 00       	call   8014e0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f5c:	83 ec 04             	sub    $0x4,%esp
  800f5f:	50                   	push   %eax
  800f60:	68 00 60 80 00       	push   $0x806000
  800f65:	ff 75 0c             	pushl  0xc(%ebp)
  800f68:	e8 63 0d 00 00       	call   801cd0 <memmove>
  800f6d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f70:	89 d8                	mov    %ebx,%eax
  800f72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f75:	5b                   	pop    %ebx
  800f76:	5e                   	pop    %esi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 04             	sub    $0x4,%esp
  800f80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f8b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f91:	7e 16                	jle    800fa9 <nsipc_send+0x30>
  800f93:	68 94 23 80 00       	push   $0x802394
  800f98:	68 34 23 80 00       	push   $0x802334
  800f9d:	6a 6d                	push   $0x6d
  800f9f:	68 88 23 80 00       	push   $0x802388
  800fa4:	e8 37 05 00 00       	call   8014e0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fa9:	83 ec 04             	sub    $0x4,%esp
  800fac:	53                   	push   %ebx
  800fad:	ff 75 0c             	pushl  0xc(%ebp)
  800fb0:	68 0c 60 80 00       	push   $0x80600c
  800fb5:	e8 16 0d 00 00       	call   801cd0 <memmove>
	nsipcbuf.send.req_size = size;
  800fba:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fc0:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc3:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fc8:	b8 08 00 00 00       	mov    $0x8,%eax
  800fcd:	e8 d9 fd ff ff       	call   800dab <nsipc>
}
  800fd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fed:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ff5:	b8 09 00 00 00       	mov    $0x9,%eax
  800ffa:	e8 ac fd ff ff       	call   800dab <nsipc>
}
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	56                   	push   %esi
  801005:	53                   	push   %ebx
  801006:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801009:	83 ec 0c             	sub    $0xc,%esp
  80100c:	ff 75 08             	pushl  0x8(%ebp)
  80100f:	e8 62 f3 ff ff       	call   800376 <fd2data>
  801014:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801016:	83 c4 08             	add    $0x8,%esp
  801019:	68 a0 23 80 00       	push   $0x8023a0
  80101e:	53                   	push   %ebx
  80101f:	e8 1a 0b 00 00       	call   801b3e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801024:	8b 46 04             	mov    0x4(%esi),%eax
  801027:	2b 06                	sub    (%esi),%eax
  801029:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80102f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801036:	00 00 00 
	stat->st_dev = &devpipe;
  801039:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801040:	30 80 00 
	return 0;
}
  801043:	b8 00 00 00 00       	mov    $0x0,%eax
  801048:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	53                   	push   %ebx
  801053:	83 ec 0c             	sub    $0xc,%esp
  801056:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801059:	53                   	push   %ebx
  80105a:	6a 00                	push   $0x0
  80105c:	e8 7a f1 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801061:	89 1c 24             	mov    %ebx,(%esp)
  801064:	e8 0d f3 ff ff       	call   800376 <fd2data>
  801069:	83 c4 08             	add    $0x8,%esp
  80106c:	50                   	push   %eax
  80106d:	6a 00                	push   $0x0
  80106f:	e8 67 f1 ff ff       	call   8001db <sys_page_unmap>
}
  801074:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801077:	c9                   	leave  
  801078:	c3                   	ret    

00801079 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	57                   	push   %edi
  80107d:	56                   	push   %esi
  80107e:	53                   	push   %ebx
  80107f:	83 ec 1c             	sub    $0x1c,%esp
  801082:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801085:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801087:	a1 08 40 80 00       	mov    0x804008,%eax
  80108c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80108f:	83 ec 0c             	sub    $0xc,%esp
  801092:	ff 75 e0             	pushl  -0x20(%ebp)
  801095:	e8 e1 0e 00 00       	call   801f7b <pageref>
  80109a:	89 c3                	mov    %eax,%ebx
  80109c:	89 3c 24             	mov    %edi,(%esp)
  80109f:	e8 d7 0e 00 00       	call   801f7b <pageref>
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	39 c3                	cmp    %eax,%ebx
  8010a9:	0f 94 c1             	sete   %cl
  8010ac:	0f b6 c9             	movzbl %cl,%ecx
  8010af:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010b2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010b8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010bb:	39 ce                	cmp    %ecx,%esi
  8010bd:	74 1b                	je     8010da <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010bf:	39 c3                	cmp    %eax,%ebx
  8010c1:	75 c4                	jne    801087 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c3:	8b 42 58             	mov    0x58(%edx),%eax
  8010c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c9:	50                   	push   %eax
  8010ca:	56                   	push   %esi
  8010cb:	68 a7 23 80 00       	push   $0x8023a7
  8010d0:	e8 e4 04 00 00       	call   8015b9 <cprintf>
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	eb ad                	jmp    801087 <_pipeisclosed+0xe>
	}
}
  8010da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	57                   	push   %edi
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 28             	sub    $0x28,%esp
  8010ee:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010f1:	56                   	push   %esi
  8010f2:	e8 7f f2 ff ff       	call   800376 <fd2data>
  8010f7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010f9:	83 c4 10             	add    $0x10,%esp
  8010fc:	bf 00 00 00 00       	mov    $0x0,%edi
  801101:	eb 4b                	jmp    80114e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801103:	89 da                	mov    %ebx,%edx
  801105:	89 f0                	mov    %esi,%eax
  801107:	e8 6d ff ff ff       	call   801079 <_pipeisclosed>
  80110c:	85 c0                	test   %eax,%eax
  80110e:	75 48                	jne    801158 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801110:	e8 22 f0 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801115:	8b 43 04             	mov    0x4(%ebx),%eax
  801118:	8b 0b                	mov    (%ebx),%ecx
  80111a:	8d 51 20             	lea    0x20(%ecx),%edx
  80111d:	39 d0                	cmp    %edx,%eax
  80111f:	73 e2                	jae    801103 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801121:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801124:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801128:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	c1 fa 1f             	sar    $0x1f,%edx
  801130:	89 d1                	mov    %edx,%ecx
  801132:	c1 e9 1b             	shr    $0x1b,%ecx
  801135:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801138:	83 e2 1f             	and    $0x1f,%edx
  80113b:	29 ca                	sub    %ecx,%edx
  80113d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801141:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801145:	83 c0 01             	add    $0x1,%eax
  801148:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80114b:	83 c7 01             	add    $0x1,%edi
  80114e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801151:	75 c2                	jne    801115 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801153:	8b 45 10             	mov    0x10(%ebp),%eax
  801156:	eb 05                	jmp    80115d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801158:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80115d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 18             	sub    $0x18,%esp
  80116e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801171:	57                   	push   %edi
  801172:	e8 ff f1 ff ff       	call   800376 <fd2data>
  801177:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801181:	eb 3d                	jmp    8011c0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801183:	85 db                	test   %ebx,%ebx
  801185:	74 04                	je     80118b <devpipe_read+0x26>
				return i;
  801187:	89 d8                	mov    %ebx,%eax
  801189:	eb 44                	jmp    8011cf <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80118b:	89 f2                	mov    %esi,%edx
  80118d:	89 f8                	mov    %edi,%eax
  80118f:	e8 e5 fe ff ff       	call   801079 <_pipeisclosed>
  801194:	85 c0                	test   %eax,%eax
  801196:	75 32                	jne    8011ca <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801198:	e8 9a ef ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80119d:	8b 06                	mov    (%esi),%eax
  80119f:	3b 46 04             	cmp    0x4(%esi),%eax
  8011a2:	74 df                	je     801183 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a4:	99                   	cltd   
  8011a5:	c1 ea 1b             	shr    $0x1b,%edx
  8011a8:	01 d0                	add    %edx,%eax
  8011aa:	83 e0 1f             	and    $0x1f,%eax
  8011ad:	29 d0                	sub    %edx,%eax
  8011af:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011ba:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011bd:	83 c3 01             	add    $0x1,%ebx
  8011c0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011c3:	75 d8                	jne    80119d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c8:	eb 05                	jmp    8011cf <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5f                   	pop    %edi
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	56                   	push   %esi
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	e8 a5 f1 ff ff       	call   80038d <fd_alloc>
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	89 c2                	mov    %eax,%edx
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	0f 88 2c 01 00 00    	js     801321 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	68 07 04 00 00       	push   $0x407
  8011fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801200:	6a 00                	push   $0x0
  801202:	e8 4f ef ff ff       	call   800156 <sys_page_alloc>
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	85 c0                	test   %eax,%eax
  80120e:	0f 88 0d 01 00 00    	js     801321 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801214:	83 ec 0c             	sub    $0xc,%esp
  801217:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	e8 6d f1 ff ff       	call   80038d <fd_alloc>
  801220:	89 c3                	mov    %eax,%ebx
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	0f 88 e2 00 00 00    	js     80130f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80122d:	83 ec 04             	sub    $0x4,%esp
  801230:	68 07 04 00 00       	push   $0x407
  801235:	ff 75 f0             	pushl  -0x10(%ebp)
  801238:	6a 00                	push   $0x0
  80123a:	e8 17 ef ff ff       	call   800156 <sys_page_alloc>
  80123f:	89 c3                	mov    %eax,%ebx
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	0f 88 c3 00 00 00    	js     80130f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80124c:	83 ec 0c             	sub    $0xc,%esp
  80124f:	ff 75 f4             	pushl  -0xc(%ebp)
  801252:	e8 1f f1 ff ff       	call   800376 <fd2data>
  801257:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801259:	83 c4 0c             	add    $0xc,%esp
  80125c:	68 07 04 00 00       	push   $0x407
  801261:	50                   	push   %eax
  801262:	6a 00                	push   $0x0
  801264:	e8 ed ee ff ff       	call   800156 <sys_page_alloc>
  801269:	89 c3                	mov    %eax,%ebx
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	85 c0                	test   %eax,%eax
  801270:	0f 88 89 00 00 00    	js     8012ff <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801276:	83 ec 0c             	sub    $0xc,%esp
  801279:	ff 75 f0             	pushl  -0x10(%ebp)
  80127c:	e8 f5 f0 ff ff       	call   800376 <fd2data>
  801281:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801288:	50                   	push   %eax
  801289:	6a 00                	push   $0x0
  80128b:	56                   	push   %esi
  80128c:	6a 00                	push   $0x0
  80128e:	e8 06 ef ff ff       	call   800199 <sys_page_map>
  801293:	89 c3                	mov    %eax,%ebx
  801295:	83 c4 20             	add    $0x20,%esp
  801298:	85 c0                	test   %eax,%eax
  80129a:	78 55                	js     8012f1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80129c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012aa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012b1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ba:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012bf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8012cc:	e8 95 f0 ff ff       	call   800366 <fd2num>
  8012d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012d6:	83 c4 04             	add    $0x4,%esp
  8012d9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012dc:	e8 85 f0 ff ff       	call   800366 <fd2num>
  8012e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ef:	eb 30                	jmp    801321 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	56                   	push   %esi
  8012f5:	6a 00                	push   $0x0
  8012f7:	e8 df ee ff ff       	call   8001db <sys_page_unmap>
  8012fc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	ff 75 f0             	pushl  -0x10(%ebp)
  801305:	6a 00                	push   $0x0
  801307:	e8 cf ee ff ff       	call   8001db <sys_page_unmap>
  80130c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	ff 75 f4             	pushl  -0xc(%ebp)
  801315:	6a 00                	push   $0x0
  801317:	e8 bf ee ff ff       	call   8001db <sys_page_unmap>
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801321:	89 d0                	mov    %edx,%eax
  801323:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801330:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801333:	50                   	push   %eax
  801334:	ff 75 08             	pushl  0x8(%ebp)
  801337:	e8 a0 f0 ff ff       	call   8003dc <fd_lookup>
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 18                	js     80135b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801343:	83 ec 0c             	sub    $0xc,%esp
  801346:	ff 75 f4             	pushl  -0xc(%ebp)
  801349:	e8 28 f0 ff ff       	call   800376 <fd2data>
	return _pipeisclosed(fd, p);
  80134e:	89 c2                	mov    %eax,%edx
  801350:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801353:	e8 21 fd ff ff       	call   801079 <_pipeisclosed>
  801358:	83 c4 10             	add    $0x10,%esp
}
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801360:	b8 00 00 00 00       	mov    $0x0,%eax
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80136d:	68 bf 23 80 00       	push   $0x8023bf
  801372:	ff 75 0c             	pushl  0xc(%ebp)
  801375:	e8 c4 07 00 00       	call   801b3e <strcpy>
	return 0;
}
  80137a:	b8 00 00 00 00       	mov    $0x0,%eax
  80137f:	c9                   	leave  
  801380:	c3                   	ret    

00801381 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	57                   	push   %edi
  801385:	56                   	push   %esi
  801386:	53                   	push   %ebx
  801387:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80138d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801392:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801398:	eb 2d                	jmp    8013c7 <devcons_write+0x46>
		m = n - tot;
  80139a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80139d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80139f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013a2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013a7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013aa:	83 ec 04             	sub    $0x4,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	03 45 0c             	add    0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	57                   	push   %edi
  8013b3:	e8 18 09 00 00       	call   801cd0 <memmove>
		sys_cputs(buf, m);
  8013b8:	83 c4 08             	add    $0x8,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	57                   	push   %edi
  8013bd:	e8 d8 ec ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c2:	01 de                	add    %ebx,%esi
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	89 f0                	mov    %esi,%eax
  8013c9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013cc:	72 cc                	jb     80139a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5f                   	pop    %edi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013e5:	74 2a                	je     801411 <devcons_read+0x3b>
  8013e7:	eb 05                	jmp    8013ee <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013e9:	e8 49 ed ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013ee:	e8 c5 ec ff ff       	call   8000b8 <sys_cgetc>
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	74 f2                	je     8013e9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 16                	js     801411 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013fb:	83 f8 04             	cmp    $0x4,%eax
  8013fe:	74 0c                	je     80140c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801400:	8b 55 0c             	mov    0xc(%ebp),%edx
  801403:	88 02                	mov    %al,(%edx)
	return 1;
  801405:	b8 01 00 00 00       	mov    $0x1,%eax
  80140a:	eb 05                	jmp    801411 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80140c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801419:	8b 45 08             	mov    0x8(%ebp),%eax
  80141c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80141f:	6a 01                	push   $0x1
  801421:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801424:	50                   	push   %eax
  801425:	e8 70 ec ff ff       	call   80009a <sys_cputs>
}
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    

0080142f <getchar>:

int
getchar(void)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801435:	6a 01                	push   $0x1
  801437:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	6a 00                	push   $0x0
  80143d:	e8 00 f2 ff ff       	call   800642 <read>
	if (r < 0)
  801442:	83 c4 10             	add    $0x10,%esp
  801445:	85 c0                	test   %eax,%eax
  801447:	78 0f                	js     801458 <getchar+0x29>
		return r;
	if (r < 1)
  801449:	85 c0                	test   %eax,%eax
  80144b:	7e 06                	jle    801453 <getchar+0x24>
		return -E_EOF;
	return c;
  80144d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801451:	eb 05                	jmp    801458 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801453:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801460:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	ff 75 08             	pushl  0x8(%ebp)
  801467:	e8 70 ef ff ff       	call   8003dc <fd_lookup>
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 11                	js     801484 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801473:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801476:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80147c:	39 10                	cmp    %edx,(%eax)
  80147e:	0f 94 c0             	sete   %al
  801481:	0f b6 c0             	movzbl %al,%eax
}
  801484:	c9                   	leave  
  801485:	c3                   	ret    

00801486 <opencons>:

int
opencons(void)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80148c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148f:	50                   	push   %eax
  801490:	e8 f8 ee ff ff       	call   80038d <fd_alloc>
  801495:	83 c4 10             	add    $0x10,%esp
		return r;
  801498:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 3e                	js     8014dc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80149e:	83 ec 04             	sub    $0x4,%esp
  8014a1:	68 07 04 00 00       	push   $0x407
  8014a6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 a6 ec ff ff       	call   800156 <sys_page_alloc>
  8014b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 23                	js     8014dc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014b9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014ce:	83 ec 0c             	sub    $0xc,%esp
  8014d1:	50                   	push   %eax
  8014d2:	e8 8f ee ff ff       	call   800366 <fd2num>
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	83 c4 10             	add    $0x10,%esp
}
  8014dc:	89 d0                	mov    %edx,%eax
  8014de:	c9                   	leave  
  8014df:	c3                   	ret    

008014e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	56                   	push   %esi
  8014e4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014e5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014e8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014ee:	e8 25 ec ff ff       	call   800118 <sys_getenvid>
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	ff 75 0c             	pushl  0xc(%ebp)
  8014f9:	ff 75 08             	pushl  0x8(%ebp)
  8014fc:	56                   	push   %esi
  8014fd:	50                   	push   %eax
  8014fe:	68 cc 23 80 00       	push   $0x8023cc
  801503:	e8 b1 00 00 00       	call   8015b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801508:	83 c4 18             	add    $0x18,%esp
  80150b:	53                   	push   %ebx
  80150c:	ff 75 10             	pushl  0x10(%ebp)
  80150f:	e8 54 00 00 00       	call   801568 <vcprintf>
	cprintf("\n");
  801514:	c7 04 24 b8 23 80 00 	movl   $0x8023b8,(%esp)
  80151b:	e8 99 00 00 00       	call   8015b9 <cprintf>
  801520:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801523:	cc                   	int3   
  801524:	eb fd                	jmp    801523 <_panic+0x43>

00801526 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	53                   	push   %ebx
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801530:	8b 13                	mov    (%ebx),%edx
  801532:	8d 42 01             	lea    0x1(%edx),%eax
  801535:	89 03                	mov    %eax,(%ebx)
  801537:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80153e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801543:	75 1a                	jne    80155f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	68 ff 00 00 00       	push   $0xff
  80154d:	8d 43 08             	lea    0x8(%ebx),%eax
  801550:	50                   	push   %eax
  801551:	e8 44 eb ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  801556:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80155c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80155f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801563:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801571:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801578:	00 00 00 
	b.cnt = 0;
  80157b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801582:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801585:	ff 75 0c             	pushl  0xc(%ebp)
  801588:	ff 75 08             	pushl  0x8(%ebp)
  80158b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801591:	50                   	push   %eax
  801592:	68 26 15 80 00       	push   $0x801526
  801597:	e8 54 01 00 00       	call   8016f0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80159c:	83 c4 08             	add    $0x8,%esp
  80159f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	e8 e9 ea ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8015b1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015bf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015c2:	50                   	push   %eax
  8015c3:	ff 75 08             	pushl  0x8(%ebp)
  8015c6:	e8 9d ff ff ff       	call   801568 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	57                   	push   %edi
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
  8015d3:	83 ec 1c             	sub    $0x1c,%esp
  8015d6:	89 c7                	mov    %eax,%edi
  8015d8:	89 d6                	mov    %edx,%esi
  8015da:	8b 45 08             	mov    0x8(%ebp),%eax
  8015dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015f1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015f4:	39 d3                	cmp    %edx,%ebx
  8015f6:	72 05                	jb     8015fd <printnum+0x30>
  8015f8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015fb:	77 45                	ja     801642 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015fd:	83 ec 0c             	sub    $0xc,%esp
  801600:	ff 75 18             	pushl  0x18(%ebp)
  801603:	8b 45 14             	mov    0x14(%ebp),%eax
  801606:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801609:	53                   	push   %ebx
  80160a:	ff 75 10             	pushl  0x10(%ebp)
  80160d:	83 ec 08             	sub    $0x8,%esp
  801610:	ff 75 e4             	pushl  -0x1c(%ebp)
  801613:	ff 75 e0             	pushl  -0x20(%ebp)
  801616:	ff 75 dc             	pushl  -0x24(%ebp)
  801619:	ff 75 d8             	pushl  -0x28(%ebp)
  80161c:	e8 9f 09 00 00       	call   801fc0 <__udivdi3>
  801621:	83 c4 18             	add    $0x18,%esp
  801624:	52                   	push   %edx
  801625:	50                   	push   %eax
  801626:	89 f2                	mov    %esi,%edx
  801628:	89 f8                	mov    %edi,%eax
  80162a:	e8 9e ff ff ff       	call   8015cd <printnum>
  80162f:	83 c4 20             	add    $0x20,%esp
  801632:	eb 18                	jmp    80164c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	56                   	push   %esi
  801638:	ff 75 18             	pushl  0x18(%ebp)
  80163b:	ff d7                	call   *%edi
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	eb 03                	jmp    801645 <printnum+0x78>
  801642:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801645:	83 eb 01             	sub    $0x1,%ebx
  801648:	85 db                	test   %ebx,%ebx
  80164a:	7f e8                	jg     801634 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	56                   	push   %esi
  801650:	83 ec 04             	sub    $0x4,%esp
  801653:	ff 75 e4             	pushl  -0x1c(%ebp)
  801656:	ff 75 e0             	pushl  -0x20(%ebp)
  801659:	ff 75 dc             	pushl  -0x24(%ebp)
  80165c:	ff 75 d8             	pushl  -0x28(%ebp)
  80165f:	e8 8c 0a 00 00       	call   8020f0 <__umoddi3>
  801664:	83 c4 14             	add    $0x14,%esp
  801667:	0f be 80 ef 23 80 00 	movsbl 0x8023ef(%eax),%eax
  80166e:	50                   	push   %eax
  80166f:	ff d7                	call   *%edi
}
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801677:	5b                   	pop    %ebx
  801678:	5e                   	pop    %esi
  801679:	5f                   	pop    %edi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80167f:	83 fa 01             	cmp    $0x1,%edx
  801682:	7e 0e                	jle    801692 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801684:	8b 10                	mov    (%eax),%edx
  801686:	8d 4a 08             	lea    0x8(%edx),%ecx
  801689:	89 08                	mov    %ecx,(%eax)
  80168b:	8b 02                	mov    (%edx),%eax
  80168d:	8b 52 04             	mov    0x4(%edx),%edx
  801690:	eb 22                	jmp    8016b4 <getuint+0x38>
	else if (lflag)
  801692:	85 d2                	test   %edx,%edx
  801694:	74 10                	je     8016a6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801696:	8b 10                	mov    (%eax),%edx
  801698:	8d 4a 04             	lea    0x4(%edx),%ecx
  80169b:	89 08                	mov    %ecx,(%eax)
  80169d:	8b 02                	mov    (%edx),%eax
  80169f:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a4:	eb 0e                	jmp    8016b4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016a6:	8b 10                	mov    (%eax),%edx
  8016a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016ab:	89 08                	mov    %ecx,(%eax)
  8016ad:	8b 02                	mov    (%edx),%eax
  8016af:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016bc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016c0:	8b 10                	mov    (%eax),%edx
  8016c2:	3b 50 04             	cmp    0x4(%eax),%edx
  8016c5:	73 0a                	jae    8016d1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016c7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016ca:	89 08                	mov    %ecx,(%eax)
  8016cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016cf:	88 02                	mov    %al,(%edx)
}
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016d9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016dc:	50                   	push   %eax
  8016dd:	ff 75 10             	pushl  0x10(%ebp)
  8016e0:	ff 75 0c             	pushl  0xc(%ebp)
  8016e3:	ff 75 08             	pushl  0x8(%ebp)
  8016e6:	e8 05 00 00 00       	call   8016f0 <vprintfmt>
	va_end(ap);
}
  8016eb:	83 c4 10             	add    $0x10,%esp
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	57                   	push   %edi
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 2c             	sub    $0x2c,%esp
  8016f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016ff:	8b 7d 10             	mov    0x10(%ebp),%edi
  801702:	eb 12                	jmp    801716 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801704:	85 c0                	test   %eax,%eax
  801706:	0f 84 89 03 00 00    	je     801a95 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	53                   	push   %ebx
  801710:	50                   	push   %eax
  801711:	ff d6                	call   *%esi
  801713:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801716:	83 c7 01             	add    $0x1,%edi
  801719:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80171d:	83 f8 25             	cmp    $0x25,%eax
  801720:	75 e2                	jne    801704 <vprintfmt+0x14>
  801722:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801726:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80172d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801734:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80173b:	ba 00 00 00 00       	mov    $0x0,%edx
  801740:	eb 07                	jmp    801749 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801742:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801745:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801749:	8d 47 01             	lea    0x1(%edi),%eax
  80174c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80174f:	0f b6 07             	movzbl (%edi),%eax
  801752:	0f b6 c8             	movzbl %al,%ecx
  801755:	83 e8 23             	sub    $0x23,%eax
  801758:	3c 55                	cmp    $0x55,%al
  80175a:	0f 87 1a 03 00 00    	ja     801a7a <vprintfmt+0x38a>
  801760:	0f b6 c0             	movzbl %al,%eax
  801763:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  80176a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80176d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801771:	eb d6                	jmp    801749 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801773:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801776:	b8 00 00 00 00       	mov    $0x0,%eax
  80177b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80177e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801781:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801785:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801788:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80178b:	83 fa 09             	cmp    $0x9,%edx
  80178e:	77 39                	ja     8017c9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801790:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801793:	eb e9                	jmp    80177e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801795:	8b 45 14             	mov    0x14(%ebp),%eax
  801798:	8d 48 04             	lea    0x4(%eax),%ecx
  80179b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80179e:	8b 00                	mov    (%eax),%eax
  8017a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017a6:	eb 27                	jmp    8017cf <vprintfmt+0xdf>
  8017a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017b2:	0f 49 c8             	cmovns %eax,%ecx
  8017b5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017bb:	eb 8c                	jmp    801749 <vprintfmt+0x59>
  8017bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017c0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017c7:	eb 80                	jmp    801749 <vprintfmt+0x59>
  8017c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017cc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017d3:	0f 89 70 ff ff ff    	jns    801749 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017d9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017df:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017e6:	e9 5e ff ff ff       	jmp    801749 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017eb:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017f1:	e9 53 ff ff ff       	jmp    801749 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f9:	8d 50 04             	lea    0x4(%eax),%edx
  8017fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8017ff:	83 ec 08             	sub    $0x8,%esp
  801802:	53                   	push   %ebx
  801803:	ff 30                	pushl  (%eax)
  801805:	ff d6                	call   *%esi
			break;
  801807:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80180d:	e9 04 ff ff ff       	jmp    801716 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801812:	8b 45 14             	mov    0x14(%ebp),%eax
  801815:	8d 50 04             	lea    0x4(%eax),%edx
  801818:	89 55 14             	mov    %edx,0x14(%ebp)
  80181b:	8b 00                	mov    (%eax),%eax
  80181d:	99                   	cltd   
  80181e:	31 d0                	xor    %edx,%eax
  801820:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801822:	83 f8 0f             	cmp    $0xf,%eax
  801825:	7f 0b                	jg     801832 <vprintfmt+0x142>
  801827:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80182e:	85 d2                	test   %edx,%edx
  801830:	75 18                	jne    80184a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801832:	50                   	push   %eax
  801833:	68 07 24 80 00       	push   $0x802407
  801838:	53                   	push   %ebx
  801839:	56                   	push   %esi
  80183a:	e8 94 fe ff ff       	call   8016d3 <printfmt>
  80183f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801842:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801845:	e9 cc fe ff ff       	jmp    801716 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80184a:	52                   	push   %edx
  80184b:	68 46 23 80 00       	push   $0x802346
  801850:	53                   	push   %ebx
  801851:	56                   	push   %esi
  801852:	e8 7c fe ff ff       	call   8016d3 <printfmt>
  801857:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80185d:	e9 b4 fe ff ff       	jmp    801716 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801862:	8b 45 14             	mov    0x14(%ebp),%eax
  801865:	8d 50 04             	lea    0x4(%eax),%edx
  801868:	89 55 14             	mov    %edx,0x14(%ebp)
  80186b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80186d:	85 ff                	test   %edi,%edi
  80186f:	b8 00 24 80 00       	mov    $0x802400,%eax
  801874:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801877:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80187b:	0f 8e 94 00 00 00    	jle    801915 <vprintfmt+0x225>
  801881:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801885:	0f 84 98 00 00 00    	je     801923 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	ff 75 d0             	pushl  -0x30(%ebp)
  801891:	57                   	push   %edi
  801892:	e8 86 02 00 00       	call   801b1d <strnlen>
  801897:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80189a:	29 c1                	sub    %eax,%ecx
  80189c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80189f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018a2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018ac:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ae:	eb 0f                	jmp    8018bf <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	53                   	push   %ebx
  8018b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8018b7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b9:	83 ef 01             	sub    $0x1,%edi
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	85 ff                	test   %edi,%edi
  8018c1:	7f ed                	jg     8018b0 <vprintfmt+0x1c0>
  8018c3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018c6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018c9:	85 c9                	test   %ecx,%ecx
  8018cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d0:	0f 49 c1             	cmovns %ecx,%eax
  8018d3:	29 c1                	sub    %eax,%ecx
  8018d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8018d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018de:	89 cb                	mov    %ecx,%ebx
  8018e0:	eb 4d                	jmp    80192f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018e6:	74 1b                	je     801903 <vprintfmt+0x213>
  8018e8:	0f be c0             	movsbl %al,%eax
  8018eb:	83 e8 20             	sub    $0x20,%eax
  8018ee:	83 f8 5e             	cmp    $0x5e,%eax
  8018f1:	76 10                	jbe    801903 <vprintfmt+0x213>
					putch('?', putdat);
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	ff 75 0c             	pushl  0xc(%ebp)
  8018f9:	6a 3f                	push   $0x3f
  8018fb:	ff 55 08             	call   *0x8(%ebp)
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	eb 0d                	jmp    801910 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	ff 75 0c             	pushl  0xc(%ebp)
  801909:	52                   	push   %edx
  80190a:	ff 55 08             	call   *0x8(%ebp)
  80190d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801910:	83 eb 01             	sub    $0x1,%ebx
  801913:	eb 1a                	jmp    80192f <vprintfmt+0x23f>
  801915:	89 75 08             	mov    %esi,0x8(%ebp)
  801918:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80191b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80191e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801921:	eb 0c                	jmp    80192f <vprintfmt+0x23f>
  801923:	89 75 08             	mov    %esi,0x8(%ebp)
  801926:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801929:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80192c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80192f:	83 c7 01             	add    $0x1,%edi
  801932:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801936:	0f be d0             	movsbl %al,%edx
  801939:	85 d2                	test   %edx,%edx
  80193b:	74 23                	je     801960 <vprintfmt+0x270>
  80193d:	85 f6                	test   %esi,%esi
  80193f:	78 a1                	js     8018e2 <vprintfmt+0x1f2>
  801941:	83 ee 01             	sub    $0x1,%esi
  801944:	79 9c                	jns    8018e2 <vprintfmt+0x1f2>
  801946:	89 df                	mov    %ebx,%edi
  801948:	8b 75 08             	mov    0x8(%ebp),%esi
  80194b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80194e:	eb 18                	jmp    801968 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	53                   	push   %ebx
  801954:	6a 20                	push   $0x20
  801956:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801958:	83 ef 01             	sub    $0x1,%edi
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	eb 08                	jmp    801968 <vprintfmt+0x278>
  801960:	89 df                	mov    %ebx,%edi
  801962:	8b 75 08             	mov    0x8(%ebp),%esi
  801965:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801968:	85 ff                	test   %edi,%edi
  80196a:	7f e4                	jg     801950 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80196c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80196f:	e9 a2 fd ff ff       	jmp    801716 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801974:	83 fa 01             	cmp    $0x1,%edx
  801977:	7e 16                	jle    80198f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801979:	8b 45 14             	mov    0x14(%ebp),%eax
  80197c:	8d 50 08             	lea    0x8(%eax),%edx
  80197f:	89 55 14             	mov    %edx,0x14(%ebp)
  801982:	8b 50 04             	mov    0x4(%eax),%edx
  801985:	8b 00                	mov    (%eax),%eax
  801987:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80198a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80198d:	eb 32                	jmp    8019c1 <vprintfmt+0x2d1>
	else if (lflag)
  80198f:	85 d2                	test   %edx,%edx
  801991:	74 18                	je     8019ab <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801993:	8b 45 14             	mov    0x14(%ebp),%eax
  801996:	8d 50 04             	lea    0x4(%eax),%edx
  801999:	89 55 14             	mov    %edx,0x14(%ebp)
  80199c:	8b 00                	mov    (%eax),%eax
  80199e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a1:	89 c1                	mov    %eax,%ecx
  8019a3:	c1 f9 1f             	sar    $0x1f,%ecx
  8019a6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019a9:	eb 16                	jmp    8019c1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ae:	8d 50 04             	lea    0x4(%eax),%edx
  8019b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b4:	8b 00                	mov    (%eax),%eax
  8019b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019b9:	89 c1                	mov    %eax,%ecx
  8019bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8019be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019c7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019cc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019d0:	79 74                	jns    801a46 <vprintfmt+0x356>
				putch('-', putdat);
  8019d2:	83 ec 08             	sub    $0x8,%esp
  8019d5:	53                   	push   %ebx
  8019d6:	6a 2d                	push   $0x2d
  8019d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8019da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019e0:	f7 d8                	neg    %eax
  8019e2:	83 d2 00             	adc    $0x0,%edx
  8019e5:	f7 da                	neg    %edx
  8019e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019ea:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019ef:	eb 55                	jmp    801a46 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8019f4:	e8 83 fc ff ff       	call   80167c <getuint>
			base = 10;
  8019f9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019fe:	eb 46                	jmp    801a46 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a00:	8d 45 14             	lea    0x14(%ebp),%eax
  801a03:	e8 74 fc ff ff       	call   80167c <getuint>
                        base = 8;
  801a08:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a0d:	eb 37                	jmp    801a46 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a0f:	83 ec 08             	sub    $0x8,%esp
  801a12:	53                   	push   %ebx
  801a13:	6a 30                	push   $0x30
  801a15:	ff d6                	call   *%esi
			putch('x', putdat);
  801a17:	83 c4 08             	add    $0x8,%esp
  801a1a:	53                   	push   %ebx
  801a1b:	6a 78                	push   $0x78
  801a1d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a22:	8d 50 04             	lea    0x4(%eax),%edx
  801a25:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a28:	8b 00                	mov    (%eax),%eax
  801a2a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a2f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a32:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a37:	eb 0d                	jmp    801a46 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a39:	8d 45 14             	lea    0x14(%ebp),%eax
  801a3c:	e8 3b fc ff ff       	call   80167c <getuint>
			base = 16;
  801a41:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a4d:	57                   	push   %edi
  801a4e:	ff 75 e0             	pushl  -0x20(%ebp)
  801a51:	51                   	push   %ecx
  801a52:	52                   	push   %edx
  801a53:	50                   	push   %eax
  801a54:	89 da                	mov    %ebx,%edx
  801a56:	89 f0                	mov    %esi,%eax
  801a58:	e8 70 fb ff ff       	call   8015cd <printnum>
			break;
  801a5d:	83 c4 20             	add    $0x20,%esp
  801a60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a63:	e9 ae fc ff ff       	jmp    801716 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a68:	83 ec 08             	sub    $0x8,%esp
  801a6b:	53                   	push   %ebx
  801a6c:	51                   	push   %ecx
  801a6d:	ff d6                	call   *%esi
			break;
  801a6f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a75:	e9 9c fc ff ff       	jmp    801716 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a7a:	83 ec 08             	sub    $0x8,%esp
  801a7d:	53                   	push   %ebx
  801a7e:	6a 25                	push   $0x25
  801a80:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	eb 03                	jmp    801a8a <vprintfmt+0x39a>
  801a87:	83 ef 01             	sub    $0x1,%edi
  801a8a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a8e:	75 f7                	jne    801a87 <vprintfmt+0x397>
  801a90:	e9 81 fc ff ff       	jmp    801716 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5f                   	pop    %edi
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    

00801a9d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	83 ec 18             	sub    $0x18,%esp
  801aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aa9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ab0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ab3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801aba:	85 c0                	test   %eax,%eax
  801abc:	74 26                	je     801ae4 <vsnprintf+0x47>
  801abe:	85 d2                	test   %edx,%edx
  801ac0:	7e 22                	jle    801ae4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ac2:	ff 75 14             	pushl  0x14(%ebp)
  801ac5:	ff 75 10             	pushl  0x10(%ebp)
  801ac8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801acb:	50                   	push   %eax
  801acc:	68 b6 16 80 00       	push   $0x8016b6
  801ad1:	e8 1a fc ff ff       	call   8016f0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ad6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ad9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	eb 05                	jmp    801ae9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ae4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ae9:	c9                   	leave  
  801aea:	c3                   	ret    

00801aeb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801af1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801af4:	50                   	push   %eax
  801af5:	ff 75 10             	pushl  0x10(%ebp)
  801af8:	ff 75 0c             	pushl  0xc(%ebp)
  801afb:	ff 75 08             	pushl  0x8(%ebp)
  801afe:	e8 9a ff ff ff       	call   801a9d <vsnprintf>
	va_end(ap);

	return rc;
}
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b10:	eb 03                	jmp    801b15 <strlen+0x10>
		n++;
  801b12:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b15:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b19:	75 f7                	jne    801b12 <strlen+0xd>
		n++;
	return n;
}
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b23:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b26:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2b:	eb 03                	jmp    801b30 <strnlen+0x13>
		n++;
  801b2d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b30:	39 c2                	cmp    %eax,%edx
  801b32:	74 08                	je     801b3c <strnlen+0x1f>
  801b34:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b38:	75 f3                	jne    801b2d <strnlen+0x10>
  801b3a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	53                   	push   %ebx
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
  801b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b48:	89 c2                	mov    %eax,%edx
  801b4a:	83 c2 01             	add    $0x1,%edx
  801b4d:	83 c1 01             	add    $0x1,%ecx
  801b50:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b54:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b57:	84 db                	test   %bl,%bl
  801b59:	75 ef                	jne    801b4a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b5b:	5b                   	pop    %ebx
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	53                   	push   %ebx
  801b62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b65:	53                   	push   %ebx
  801b66:	e8 9a ff ff ff       	call   801b05 <strlen>
  801b6b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b6e:	ff 75 0c             	pushl  0xc(%ebp)
  801b71:	01 d8                	add    %ebx,%eax
  801b73:	50                   	push   %eax
  801b74:	e8 c5 ff ff ff       	call   801b3e <strcpy>
	return dst;
}
  801b79:	89 d8                	mov    %ebx,%eax
  801b7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	56                   	push   %esi
  801b84:	53                   	push   %ebx
  801b85:	8b 75 08             	mov    0x8(%ebp),%esi
  801b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8b:	89 f3                	mov    %esi,%ebx
  801b8d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b90:	89 f2                	mov    %esi,%edx
  801b92:	eb 0f                	jmp    801ba3 <strncpy+0x23>
		*dst++ = *src;
  801b94:	83 c2 01             	add    $0x1,%edx
  801b97:	0f b6 01             	movzbl (%ecx),%eax
  801b9a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b9d:	80 39 01             	cmpb   $0x1,(%ecx)
  801ba0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba3:	39 da                	cmp    %ebx,%edx
  801ba5:	75 ed                	jne    801b94 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ba7:	89 f0                	mov    %esi,%eax
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	56                   	push   %esi
  801bb1:	53                   	push   %ebx
  801bb2:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb8:	8b 55 10             	mov    0x10(%ebp),%edx
  801bbb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bbd:	85 d2                	test   %edx,%edx
  801bbf:	74 21                	je     801be2 <strlcpy+0x35>
  801bc1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bc5:	89 f2                	mov    %esi,%edx
  801bc7:	eb 09                	jmp    801bd2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bc9:	83 c2 01             	add    $0x1,%edx
  801bcc:	83 c1 01             	add    $0x1,%ecx
  801bcf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bd2:	39 c2                	cmp    %eax,%edx
  801bd4:	74 09                	je     801bdf <strlcpy+0x32>
  801bd6:	0f b6 19             	movzbl (%ecx),%ebx
  801bd9:	84 db                	test   %bl,%bl
  801bdb:	75 ec                	jne    801bc9 <strlcpy+0x1c>
  801bdd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bdf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801be2:	29 f0                	sub    %esi,%eax
}
  801be4:	5b                   	pop    %ebx
  801be5:	5e                   	pop    %esi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bf1:	eb 06                	jmp    801bf9 <strcmp+0x11>
		p++, q++;
  801bf3:	83 c1 01             	add    $0x1,%ecx
  801bf6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bf9:	0f b6 01             	movzbl (%ecx),%eax
  801bfc:	84 c0                	test   %al,%al
  801bfe:	74 04                	je     801c04 <strcmp+0x1c>
  801c00:	3a 02                	cmp    (%edx),%al
  801c02:	74 ef                	je     801bf3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c04:	0f b6 c0             	movzbl %al,%eax
  801c07:	0f b6 12             	movzbl (%edx),%edx
  801c0a:	29 d0                	sub    %edx,%eax
}
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    

00801c0e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	53                   	push   %ebx
  801c12:	8b 45 08             	mov    0x8(%ebp),%eax
  801c15:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c18:	89 c3                	mov    %eax,%ebx
  801c1a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c1d:	eb 06                	jmp    801c25 <strncmp+0x17>
		n--, p++, q++;
  801c1f:	83 c0 01             	add    $0x1,%eax
  801c22:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c25:	39 d8                	cmp    %ebx,%eax
  801c27:	74 15                	je     801c3e <strncmp+0x30>
  801c29:	0f b6 08             	movzbl (%eax),%ecx
  801c2c:	84 c9                	test   %cl,%cl
  801c2e:	74 04                	je     801c34 <strncmp+0x26>
  801c30:	3a 0a                	cmp    (%edx),%cl
  801c32:	74 eb                	je     801c1f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c34:	0f b6 00             	movzbl (%eax),%eax
  801c37:	0f b6 12             	movzbl (%edx),%edx
  801c3a:	29 d0                	sub    %edx,%eax
  801c3c:	eb 05                	jmp    801c43 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c3e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c43:	5b                   	pop    %ebx
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c50:	eb 07                	jmp    801c59 <strchr+0x13>
		if (*s == c)
  801c52:	38 ca                	cmp    %cl,%dl
  801c54:	74 0f                	je     801c65 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c56:	83 c0 01             	add    $0x1,%eax
  801c59:	0f b6 10             	movzbl (%eax),%edx
  801c5c:	84 d2                	test   %dl,%dl
  801c5e:	75 f2                	jne    801c52 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    

00801c67 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c71:	eb 03                	jmp    801c76 <strfind+0xf>
  801c73:	83 c0 01             	add    $0x1,%eax
  801c76:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c79:	38 ca                	cmp    %cl,%dl
  801c7b:	74 04                	je     801c81 <strfind+0x1a>
  801c7d:	84 d2                	test   %dl,%dl
  801c7f:	75 f2                	jne    801c73 <strfind+0xc>
			break;
	return (char *) s;
}
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	57                   	push   %edi
  801c87:	56                   	push   %esi
  801c88:	53                   	push   %ebx
  801c89:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c8f:	85 c9                	test   %ecx,%ecx
  801c91:	74 36                	je     801cc9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c93:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c99:	75 28                	jne    801cc3 <memset+0x40>
  801c9b:	f6 c1 03             	test   $0x3,%cl
  801c9e:	75 23                	jne    801cc3 <memset+0x40>
		c &= 0xFF;
  801ca0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ca4:	89 d3                	mov    %edx,%ebx
  801ca6:	c1 e3 08             	shl    $0x8,%ebx
  801ca9:	89 d6                	mov    %edx,%esi
  801cab:	c1 e6 18             	shl    $0x18,%esi
  801cae:	89 d0                	mov    %edx,%eax
  801cb0:	c1 e0 10             	shl    $0x10,%eax
  801cb3:	09 f0                	or     %esi,%eax
  801cb5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cb7:	89 d8                	mov    %ebx,%eax
  801cb9:	09 d0                	or     %edx,%eax
  801cbb:	c1 e9 02             	shr    $0x2,%ecx
  801cbe:	fc                   	cld    
  801cbf:	f3 ab                	rep stos %eax,%es:(%edi)
  801cc1:	eb 06                	jmp    801cc9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc6:	fc                   	cld    
  801cc7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cc9:	89 f8                	mov    %edi,%eax
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5f                   	pop    %edi
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	57                   	push   %edi
  801cd4:	56                   	push   %esi
  801cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cdb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cde:	39 c6                	cmp    %eax,%esi
  801ce0:	73 35                	jae    801d17 <memmove+0x47>
  801ce2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ce5:	39 d0                	cmp    %edx,%eax
  801ce7:	73 2e                	jae    801d17 <memmove+0x47>
		s += n;
		d += n;
  801ce9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cec:	89 d6                	mov    %edx,%esi
  801cee:	09 fe                	or     %edi,%esi
  801cf0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cf6:	75 13                	jne    801d0b <memmove+0x3b>
  801cf8:	f6 c1 03             	test   $0x3,%cl
  801cfb:	75 0e                	jne    801d0b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801cfd:	83 ef 04             	sub    $0x4,%edi
  801d00:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d03:	c1 e9 02             	shr    $0x2,%ecx
  801d06:	fd                   	std    
  801d07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d09:	eb 09                	jmp    801d14 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d0b:	83 ef 01             	sub    $0x1,%edi
  801d0e:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d11:	fd                   	std    
  801d12:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d14:	fc                   	cld    
  801d15:	eb 1d                	jmp    801d34 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d17:	89 f2                	mov    %esi,%edx
  801d19:	09 c2                	or     %eax,%edx
  801d1b:	f6 c2 03             	test   $0x3,%dl
  801d1e:	75 0f                	jne    801d2f <memmove+0x5f>
  801d20:	f6 c1 03             	test   $0x3,%cl
  801d23:	75 0a                	jne    801d2f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d25:	c1 e9 02             	shr    $0x2,%ecx
  801d28:	89 c7                	mov    %eax,%edi
  801d2a:	fc                   	cld    
  801d2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d2d:	eb 05                	jmp    801d34 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d2f:	89 c7                	mov    %eax,%edi
  801d31:	fc                   	cld    
  801d32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d34:	5e                   	pop    %esi
  801d35:	5f                   	pop    %edi
  801d36:	5d                   	pop    %ebp
  801d37:	c3                   	ret    

00801d38 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d3b:	ff 75 10             	pushl  0x10(%ebp)
  801d3e:	ff 75 0c             	pushl  0xc(%ebp)
  801d41:	ff 75 08             	pushl  0x8(%ebp)
  801d44:	e8 87 ff ff ff       	call   801cd0 <memmove>
}
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    

00801d4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	56                   	push   %esi
  801d4f:	53                   	push   %ebx
  801d50:	8b 45 08             	mov    0x8(%ebp),%eax
  801d53:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d56:	89 c6                	mov    %eax,%esi
  801d58:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d5b:	eb 1a                	jmp    801d77 <memcmp+0x2c>
		if (*s1 != *s2)
  801d5d:	0f b6 08             	movzbl (%eax),%ecx
  801d60:	0f b6 1a             	movzbl (%edx),%ebx
  801d63:	38 d9                	cmp    %bl,%cl
  801d65:	74 0a                	je     801d71 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d67:	0f b6 c1             	movzbl %cl,%eax
  801d6a:	0f b6 db             	movzbl %bl,%ebx
  801d6d:	29 d8                	sub    %ebx,%eax
  801d6f:	eb 0f                	jmp    801d80 <memcmp+0x35>
		s1++, s2++;
  801d71:	83 c0 01             	add    $0x1,%eax
  801d74:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d77:	39 f0                	cmp    %esi,%eax
  801d79:	75 e2                	jne    801d5d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    

00801d84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	53                   	push   %ebx
  801d88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d8b:	89 c1                	mov    %eax,%ecx
  801d8d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d90:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d94:	eb 0a                	jmp    801da0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d96:	0f b6 10             	movzbl (%eax),%edx
  801d99:	39 da                	cmp    %ebx,%edx
  801d9b:	74 07                	je     801da4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d9d:	83 c0 01             	add    $0x1,%eax
  801da0:	39 c8                	cmp    %ecx,%eax
  801da2:	72 f2                	jb     801d96 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801da4:	5b                   	pop    %ebx
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	57                   	push   %edi
  801dab:	56                   	push   %esi
  801dac:	53                   	push   %ebx
  801dad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801db3:	eb 03                	jmp    801db8 <strtol+0x11>
		s++;
  801db5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801db8:	0f b6 01             	movzbl (%ecx),%eax
  801dbb:	3c 20                	cmp    $0x20,%al
  801dbd:	74 f6                	je     801db5 <strtol+0xe>
  801dbf:	3c 09                	cmp    $0x9,%al
  801dc1:	74 f2                	je     801db5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dc3:	3c 2b                	cmp    $0x2b,%al
  801dc5:	75 0a                	jne    801dd1 <strtol+0x2a>
		s++;
  801dc7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dca:	bf 00 00 00 00       	mov    $0x0,%edi
  801dcf:	eb 11                	jmp    801de2 <strtol+0x3b>
  801dd1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dd6:	3c 2d                	cmp    $0x2d,%al
  801dd8:	75 08                	jne    801de2 <strtol+0x3b>
		s++, neg = 1;
  801dda:	83 c1 01             	add    $0x1,%ecx
  801ddd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801de2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801de8:	75 15                	jne    801dff <strtol+0x58>
  801dea:	80 39 30             	cmpb   $0x30,(%ecx)
  801ded:	75 10                	jne    801dff <strtol+0x58>
  801def:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801df3:	75 7c                	jne    801e71 <strtol+0xca>
		s += 2, base = 16;
  801df5:	83 c1 02             	add    $0x2,%ecx
  801df8:	bb 10 00 00 00       	mov    $0x10,%ebx
  801dfd:	eb 16                	jmp    801e15 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801dff:	85 db                	test   %ebx,%ebx
  801e01:	75 12                	jne    801e15 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e03:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e08:	80 39 30             	cmpb   $0x30,(%ecx)
  801e0b:	75 08                	jne    801e15 <strtol+0x6e>
		s++, base = 8;
  801e0d:	83 c1 01             	add    $0x1,%ecx
  801e10:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e15:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e1d:	0f b6 11             	movzbl (%ecx),%edx
  801e20:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e23:	89 f3                	mov    %esi,%ebx
  801e25:	80 fb 09             	cmp    $0x9,%bl
  801e28:	77 08                	ja     801e32 <strtol+0x8b>
			dig = *s - '0';
  801e2a:	0f be d2             	movsbl %dl,%edx
  801e2d:	83 ea 30             	sub    $0x30,%edx
  801e30:	eb 22                	jmp    801e54 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e32:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e35:	89 f3                	mov    %esi,%ebx
  801e37:	80 fb 19             	cmp    $0x19,%bl
  801e3a:	77 08                	ja     801e44 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e3c:	0f be d2             	movsbl %dl,%edx
  801e3f:	83 ea 57             	sub    $0x57,%edx
  801e42:	eb 10                	jmp    801e54 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e44:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e47:	89 f3                	mov    %esi,%ebx
  801e49:	80 fb 19             	cmp    $0x19,%bl
  801e4c:	77 16                	ja     801e64 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e4e:	0f be d2             	movsbl %dl,%edx
  801e51:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e54:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e57:	7d 0b                	jge    801e64 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e59:	83 c1 01             	add    $0x1,%ecx
  801e5c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e60:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e62:	eb b9                	jmp    801e1d <strtol+0x76>

	if (endptr)
  801e64:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e68:	74 0d                	je     801e77 <strtol+0xd0>
		*endptr = (char *) s;
  801e6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e6d:	89 0e                	mov    %ecx,(%esi)
  801e6f:	eb 06                	jmp    801e77 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e71:	85 db                	test   %ebx,%ebx
  801e73:	74 98                	je     801e0d <strtol+0x66>
  801e75:	eb 9e                	jmp    801e15 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e77:	89 c2                	mov    %eax,%edx
  801e79:	f7 da                	neg    %edx
  801e7b:	85 ff                	test   %edi,%edi
  801e7d:	0f 45 c2             	cmovne %edx,%eax
}
  801e80:	5b                   	pop    %ebx
  801e81:	5e                   	pop    %esi
  801e82:	5f                   	pop    %edi
  801e83:	5d                   	pop    %ebp
  801e84:	c3                   	ret    

00801e85 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	56                   	push   %esi
  801e89:	53                   	push   %ebx
  801e8a:	8b 75 08             	mov    0x8(%ebp),%esi
  801e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801e93:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801e95:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801e9a:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801e9d:	83 ec 0c             	sub    $0xc,%esp
  801ea0:	50                   	push   %eax
  801ea1:	e8 60 e4 ff ff       	call   800306 <sys_ipc_recv>

	if (r < 0) {
  801ea6:	83 c4 10             	add    $0x10,%esp
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	79 16                	jns    801ec3 <ipc_recv+0x3e>
		if (from_env_store)
  801ead:	85 f6                	test   %esi,%esi
  801eaf:	74 06                	je     801eb7 <ipc_recv+0x32>
			*from_env_store = 0;
  801eb1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801eb7:	85 db                	test   %ebx,%ebx
  801eb9:	74 2c                	je     801ee7 <ipc_recv+0x62>
			*perm_store = 0;
  801ebb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ec1:	eb 24                	jmp    801ee7 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801ec3:	85 f6                	test   %esi,%esi
  801ec5:	74 0a                	je     801ed1 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ec7:	a1 08 40 80 00       	mov    0x804008,%eax
  801ecc:	8b 40 74             	mov    0x74(%eax),%eax
  801ecf:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801ed1:	85 db                	test   %ebx,%ebx
  801ed3:	74 0a                	je     801edf <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801ed5:	a1 08 40 80 00       	mov    0x804008,%eax
  801eda:	8b 40 78             	mov    0x78(%eax),%eax
  801edd:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801edf:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee4:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eea:	5b                   	pop    %ebx
  801eeb:	5e                   	pop    %esi
  801eec:	5d                   	pop    %ebp
  801eed:	c3                   	ret    

00801eee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	57                   	push   %edi
  801ef2:	56                   	push   %esi
  801ef3:	53                   	push   %ebx
  801ef4:	83 ec 0c             	sub    $0xc,%esp
  801ef7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801efa:	8b 75 0c             	mov    0xc(%ebp),%esi
  801efd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f00:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f02:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f07:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f0a:	ff 75 14             	pushl  0x14(%ebp)
  801f0d:	53                   	push   %ebx
  801f0e:	56                   	push   %esi
  801f0f:	57                   	push   %edi
  801f10:	e8 ce e3 ff ff       	call   8002e3 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1b:	75 07                	jne    801f24 <ipc_send+0x36>
			sys_yield();
  801f1d:	e8 15 e2 ff ff       	call   800137 <sys_yield>
  801f22:	eb e6                	jmp    801f0a <ipc_send+0x1c>
		} else if (r < 0) {
  801f24:	85 c0                	test   %eax,%eax
  801f26:	79 12                	jns    801f3a <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f28:	50                   	push   %eax
  801f29:	68 00 27 80 00       	push   $0x802700
  801f2e:	6a 51                	push   $0x51
  801f30:	68 0d 27 80 00       	push   $0x80270d
  801f35:	e8 a6 f5 ff ff       	call   8014e0 <_panic>
		}
	}
}
  801f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5e                   	pop    %esi
  801f3f:	5f                   	pop    %edi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f48:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f4d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f50:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f56:	8b 52 50             	mov    0x50(%edx),%edx
  801f59:	39 ca                	cmp    %ecx,%edx
  801f5b:	75 0d                	jne    801f6a <ipc_find_env+0x28>
			return envs[i].env_id;
  801f5d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f60:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f65:	8b 40 48             	mov    0x48(%eax),%eax
  801f68:	eb 0f                	jmp    801f79 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f6a:	83 c0 01             	add    $0x1,%eax
  801f6d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f72:	75 d9                	jne    801f4d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    

00801f7b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f81:	89 d0                	mov    %edx,%eax
  801f83:	c1 e8 16             	shr    $0x16,%eax
  801f86:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f8d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f92:	f6 c1 01             	test   $0x1,%cl
  801f95:	74 1d                	je     801fb4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f97:	c1 ea 0c             	shr    $0xc,%edx
  801f9a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fa1:	f6 c2 01             	test   $0x1,%dl
  801fa4:	74 0e                	je     801fb4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa6:	c1 ea 0c             	shr    $0xc,%edx
  801fa9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb0:	ef 
  801fb1:	0f b7 c0             	movzwl %ax,%eax
}
  801fb4:	5d                   	pop    %ebp
  801fb5:	c3                   	ret    
  801fb6:	66 90                	xchg   %ax,%ax
  801fb8:	66 90                	xchg   %ax,%ax
  801fba:	66 90                	xchg   %ax,%ax
  801fbc:	66 90                	xchg   %ax,%ax
  801fbe:	66 90                	xchg   %ax,%ax

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
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
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
