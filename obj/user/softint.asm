
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
  800057:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800086:	e8 87 04 00 00       	call   800512 <close_all>
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
  8000ff:	68 ca 1d 80 00       	push   $0x801dca
  800104:	6a 23                	push   $0x23
  800106:	68 e7 1d 80 00       	push   $0x801de7
  80010b:	e8 4a 0f 00 00       	call   80105a <_panic>

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
  800180:	68 ca 1d 80 00       	push   $0x801dca
  800185:	6a 23                	push   $0x23
  800187:	68 e7 1d 80 00       	push   $0x801de7
  80018c:	e8 c9 0e 00 00       	call   80105a <_panic>

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
  8001c2:	68 ca 1d 80 00       	push   $0x801dca
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 e7 1d 80 00       	push   $0x801de7
  8001ce:	e8 87 0e 00 00       	call   80105a <_panic>

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
  800204:	68 ca 1d 80 00       	push   $0x801dca
  800209:	6a 23                	push   $0x23
  80020b:	68 e7 1d 80 00       	push   $0x801de7
  800210:	e8 45 0e 00 00       	call   80105a <_panic>

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
  800246:	68 ca 1d 80 00       	push   $0x801dca
  80024b:	6a 23                	push   $0x23
  80024d:	68 e7 1d 80 00       	push   $0x801de7
  800252:	e8 03 0e 00 00       	call   80105a <_panic>

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
  800288:	68 ca 1d 80 00       	push   $0x801dca
  80028d:	6a 23                	push   $0x23
  80028f:	68 e7 1d 80 00       	push   $0x801de7
  800294:	e8 c1 0d 00 00       	call   80105a <_panic>

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
  8002ca:	68 ca 1d 80 00       	push   $0x801dca
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 e7 1d 80 00       	push   $0x801de7
  8002d6:	e8 7f 0d 00 00       	call   80105a <_panic>

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
  80032e:	68 ca 1d 80 00       	push   $0x801dca
  800333:	6a 23                	push   $0x23
  800335:	68 e7 1d 80 00       	push   $0x801de7
  80033a:	e8 1b 0d 00 00       	call   80105a <_panic>

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

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 11                	je     80039b <fd_alloc+0x2d>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	75 09                	jne    8003a4 <fd_alloc+0x36>
			*fd_store = fd;
  80039b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	eb 17                	jmp    8003bb <fd_alloc+0x4d>
  8003a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ae:	75 c9                	jne    800379 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	eb 13                	jmp    800411 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb 0c                	jmp    800411 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb 05                	jmp    800411 <fd_lookup+0x54>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	eb 13                	jmp    800436 <dev_lookup+0x23>
  800423:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	75 0c                	jne    800436 <dev_lookup+0x23>
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb 2e                	jmp    800464 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 e7                	jne    800423 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 04 40 80 00       	mov    0x804004,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	51                   	push   %ecx
  800448:	50                   	push   %eax
  800449:	68 f8 1d 80 00       	push   $0x801df8
  80044e:	e8 e0 0c 00 00       	call   801133 <cprintf>
	*dev = 0;
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	56                   	push   %esi
  80046a:	53                   	push   %ebx
  80046b:	83 ec 10             	sub    $0x10,%esp
  80046e:	8b 75 08             	mov    0x8(%ebp),%esi
  800471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800477:	50                   	push   %eax
  800478:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047e:	c1 e8 0c             	shr    $0xc,%eax
  800481:	50                   	push   %eax
  800482:	e8 36 ff ff ff       	call   8003bd <fd_lookup>
  800487:	83 c4 08             	add    $0x8,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 05                	js     800493 <fd_close+0x2d>
	    || fd != fd2)
  80048e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800491:	74 0c                	je     80049f <fd_close+0x39>
		return (must_exist ? r : 0);
  800493:	84 db                	test   %bl,%bl
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	0f 44 c2             	cmove  %edx,%eax
  80049d:	eb 41                	jmp    8004e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff 36                	pushl  (%esi)
  8004a8:	e8 66 ff ff ff       	call   800413 <dev_lookup>
  8004ad:	89 c3                	mov    %eax,%ebx
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	78 1a                	js     8004d0 <fd_close+0x6a>
		if (dev->dev_close)
  8004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	74 0b                	je     8004d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c5:	83 ec 0c             	sub    $0xc,%esp
  8004c8:	56                   	push   %esi
  8004c9:	ff d0                	call   *%eax
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	56                   	push   %esi
  8004d4:	6a 00                	push   $0x0
  8004d6:	e8 00 fd ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	89 d8                	mov    %ebx,%eax
}
  8004e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 c4 fe ff ff       	call   8003bd <fd_lookup>
  8004f9:	83 c4 08             	add    $0x8,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 10                	js     800510 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	6a 01                	push   $0x1
  800505:	ff 75 f4             	pushl  -0xc(%ebp)
  800508:	e8 59 ff ff ff       	call   800466 <fd_close>
  80050d:	83 c4 10             	add    $0x10,%esp
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <close_all>:

void
close_all(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	53                   	push   %ebx
  800516:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800519:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	53                   	push   %ebx
  800522:	e8 c0 ff ff ff       	call   8004e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800527:	83 c3 01             	add    $0x1,%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	83 fb 20             	cmp    $0x20,%ebx
  800530:	75 ec                	jne    80051e <close_all+0xc>
		close(i);
}
  800532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	57                   	push   %edi
  80053b:	56                   	push   %esi
  80053c:	53                   	push   %ebx
  80053d:	83 ec 2c             	sub    $0x2c,%esp
  800540:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800543:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800546:	50                   	push   %eax
  800547:	ff 75 08             	pushl  0x8(%ebp)
  80054a:	e8 6e fe ff ff       	call   8003bd <fd_lookup>
  80054f:	83 c4 08             	add    $0x8,%esp
  800552:	85 c0                	test   %eax,%eax
  800554:	0f 88 c1 00 00 00    	js     80061b <dup+0xe4>
		return r;
	close(newfdnum);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	56                   	push   %esi
  80055e:	e8 84 ff ff ff       	call   8004e7 <close>

	newfd = INDEX2FD(newfdnum);
  800563:	89 f3                	mov    %esi,%ebx
  800565:	c1 e3 0c             	shl    $0xc,%ebx
  800568:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056e:	83 c4 04             	add    $0x4,%esp
  800571:	ff 75 e4             	pushl  -0x1c(%ebp)
  800574:	e8 de fd ff ff       	call   800357 <fd2data>
  800579:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057b:	89 1c 24             	mov    %ebx,(%esp)
  80057e:	e8 d4 fd ff ff       	call   800357 <fd2data>
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800589:	89 f8                	mov    %edi,%eax
  80058b:	c1 e8 16             	shr    $0x16,%eax
  80058e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800595:	a8 01                	test   $0x1,%al
  800597:	74 37                	je     8005d0 <dup+0x99>
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 0c             	shr    $0xc,%eax
  80059e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a5:	f6 c2 01             	test   $0x1,%dl
  8005a8:	74 26                	je     8005d0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bd:	6a 00                	push   $0x0
  8005bf:	57                   	push   %edi
  8005c0:	6a 00                	push   $0x0
  8005c2:	e8 d2 fb ff ff       	call   800199 <sys_page_map>
  8005c7:	89 c7                	mov    %eax,%edi
  8005c9:	83 c4 20             	add    $0x20,%esp
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	78 2e                	js     8005fe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d3:	89 d0                	mov    %edx,%eax
  8005d5:	c1 e8 0c             	shr    $0xc,%eax
  8005d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e7:	50                   	push   %eax
  8005e8:	53                   	push   %ebx
  8005e9:	6a 00                	push   $0x0
  8005eb:	52                   	push   %edx
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 a6 fb ff ff       	call   800199 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	79 1d                	jns    80061b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 d2 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060f:	6a 00                	push   $0x0
  800611:	e8 c5 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	89 f8                	mov    %edi,%eax
}
  80061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061e:	5b                   	pop    %ebx
  80061f:	5e                   	pop    %esi
  800620:	5f                   	pop    %edi
  800621:	5d                   	pop    %ebp
  800622:	c3                   	ret    

00800623 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	53                   	push   %ebx
  800627:	83 ec 14             	sub    $0x14,%esp
  80062a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	53                   	push   %ebx
  800632:	e8 86 fd ff ff       	call   8003bd <fd_lookup>
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	89 c2                	mov    %eax,%edx
  80063c:	85 c0                	test   %eax,%eax
  80063e:	78 6d                	js     8006ad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800646:	50                   	push   %eax
  800647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064a:	ff 30                	pushl  (%eax)
  80064c:	e8 c2 fd ff ff       	call   800413 <dev_lookup>
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	78 4c                	js     8006a4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065b:	8b 42 08             	mov    0x8(%edx),%eax
  80065e:	83 e0 03             	and    $0x3,%eax
  800661:	83 f8 01             	cmp    $0x1,%eax
  800664:	75 21                	jne    800687 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800666:	a1 04 40 80 00       	mov    0x804004,%eax
  80066b:	8b 40 48             	mov    0x48(%eax),%eax
  80066e:	83 ec 04             	sub    $0x4,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	68 39 1e 80 00       	push   $0x801e39
  800678:	e8 b6 0a 00 00       	call   801133 <cprintf>
		return -E_INVAL;
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800685:	eb 26                	jmp    8006ad <read+0x8a>
	}
	if (!dev->dev_read)
  800687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068a:	8b 40 08             	mov    0x8(%eax),%eax
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 17                	je     8006a8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	52                   	push   %edx
  80069b:	ff d0                	call   *%eax
  80069d:	89 c2                	mov    %eax,%edx
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 09                	jmp    8006ad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	eb 05                	jmp    8006ad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ad:	89 d0                	mov    %edx,%eax
  8006af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	eb 21                	jmp    8006eb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ca:	83 ec 04             	sub    $0x4,%esp
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	29 d8                	sub    %ebx,%eax
  8006d1:	50                   	push   %eax
  8006d2:	89 d8                	mov    %ebx,%eax
  8006d4:	03 45 0c             	add    0xc(%ebp),%eax
  8006d7:	50                   	push   %eax
  8006d8:	57                   	push   %edi
  8006d9:	e8 45 ff ff ff       	call   800623 <read>
		if (m < 0)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	78 10                	js     8006f5 <readn+0x41>
			return m;
		if (m == 0)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 0a                	je     8006f3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e9:	01 c3                	add    %eax,%ebx
  8006eb:	39 f3                	cmp    %esi,%ebx
  8006ed:	72 db                	jb     8006ca <readn+0x16>
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	eb 02                	jmp    8006f5 <readn+0x41>
  8006f3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	53                   	push   %ebx
  800701:	83 ec 14             	sub    $0x14,%esp
  800704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	53                   	push   %ebx
  80070c:	e8 ac fc ff ff       	call   8003bd <fd_lookup>
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	89 c2                	mov    %eax,%edx
  800716:	85 c0                	test   %eax,%eax
  800718:	78 68                	js     800782 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	ff 30                	pushl  (%eax)
  800726:	e8 e8 fc ff ff       	call   800413 <dev_lookup>
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 c0                	test   %eax,%eax
  800730:	78 47                	js     800779 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800739:	75 21                	jne    80075c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 04 40 80 00       	mov    0x804004,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 55 1e 80 00       	push   $0x801e55
  80074d:	e8 e1 09 00 00       	call   801133 <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075a:	eb 26                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075f:	8b 52 0c             	mov    0xc(%edx),%edx
  800762:	85 d2                	test   %edx,%edx
  800764:	74 17                	je     80077d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	50                   	push   %eax
  800770:	ff d2                	call   *%edx
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 09                	jmp    800782 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	89 c2                	mov    %eax,%edx
  80077b:	eb 05                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800782:	89 d0                	mov    %edx,%eax
  800784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <seek>:

int
seek(int fdnum, off_t offset)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 22 fc ff ff       	call   8003bd <fd_lookup>
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 0e                	js     8007b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 14             	sub    $0x14,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	53                   	push   %ebx
  8007c1:	e8 f7 fb ff ff       	call   8003bd <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 65                	js     800834 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 33 fc ff ff       	call   800413 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 44                	js     80082b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	75 21                	jne    800811 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f5:	8b 40 48             	mov    0x48(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	50                   	push   %eax
  8007fd:	68 18 1e 80 00       	push   $0x801e18
  800802:	e8 2c 09 00 00       	call   801133 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080f:	eb 23                	jmp    800834 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800811:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800814:	8b 52 18             	mov    0x18(%edx),%edx
  800817:	85 d2                	test   %edx,%edx
  800819:	74 14                	je     80082f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	ff 75 0c             	pushl  0xc(%ebp)
  800821:	50                   	push   %eax
  800822:	ff d2                	call   *%edx
  800824:	89 c2                	mov    %eax,%edx
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb 09                	jmp    800834 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	eb 05                	jmp    800834 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800834:	89 d0                	mov    %edx,%eax
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 6c fb ff ff       	call   8003bd <fd_lookup>
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	89 c2                	mov    %eax,%edx
  800856:	85 c0                	test   %eax,%eax
  800858:	78 58                	js     8008b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800864:	ff 30                	pushl  (%eax)
  800866:	e8 a8 fb ff ff       	call   800413 <dev_lookup>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 37                	js     8008a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800879:	74 32                	je     8008ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800885:	00 00 00 
	stat->st_isdir = 0;
  800888:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088f:	00 00 00 
	stat->st_dev = dev;
  800892:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	ff 75 f0             	pushl  -0x10(%ebp)
  80089f:	ff 50 14             	call   *0x14(%eax)
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	eb 09                	jmp    8008b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	eb 05                	jmp    8008b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	6a 00                	push   $0x0
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 0c 02 00 00       	call   800ad7 <open>
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	78 1b                	js     8008ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	50                   	push   %eax
  8008db:	e8 5b ff ff ff       	call   80083b <fstat>
  8008e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 fd fb ff ff       	call   8004e7 <close>
	return r;
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	89 f0                	mov    %esi,%eax
}
  8008ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	89 c6                	mov    %eax,%esi
  8008fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800906:	75 12                	jne    80091a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	6a 01                	push   $0x1
  80090d:	e8 aa 11 00 00       	call   801abc <ipc_find_env>
  800912:	a3 00 40 80 00       	mov    %eax,0x804000
  800917:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091a:	6a 07                	push   $0x7
  80091c:	68 00 50 80 00       	push   $0x805000
  800921:	56                   	push   %esi
  800922:	ff 35 00 40 80 00    	pushl  0x804000
  800928:	e8 3b 11 00 00       	call   801a68 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092d:	83 c4 0c             	add    $0xc,%esp
  800930:	6a 00                	push   $0x0
  800932:	53                   	push   %ebx
  800933:	6a 00                	push   $0x0
  800935:	e8 c5 10 00 00       	call   8019ff <ipc_recv>
}
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 40 0c             	mov    0xc(%eax),%eax
  80094d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 02 00 00 00       	mov    $0x2,%eax
  800964:	e8 8d ff ff ff       	call   8008f6 <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 40 0c             	mov    0xc(%eax),%eax
  800977:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 06 00 00 00       	mov    $0x6,%eax
  800986:	e8 6b ff ff ff       	call   8008f6 <fsipc>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ac:	e8 45 ff ff ff       	call   8008f6 <fsipc>
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 2c                	js     8009e1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b5:	83 ec 08             	sub    $0x8,%esp
  8009b8:	68 00 50 80 00       	push   $0x805000
  8009bd:	53                   	push   %ebx
  8009be:	e8 f5 0c 00 00       	call   8016b8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ce:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d9:	83 c4 10             	add    $0x10,%esp
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	53                   	push   %ebx
  8009ea:	83 ec 08             	sub    $0x8,%esp
  8009ed:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f6:	89 15 00 50 80 00    	mov    %edx,0x805000
  8009fc:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a01:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a06:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a09:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a0f:	53                   	push   %ebx
  800a10:	ff 75 0c             	pushl  0xc(%ebp)
  800a13:	68 08 50 80 00       	push   $0x805008
  800a18:	e8 2d 0e 00 00       	call   80184a <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  800a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a22:	b8 04 00 00 00       	mov    $0x4,%eax
  800a27:	e8 ca fe ff ff       	call   8008f6 <fsipc>
  800a2c:	83 c4 10             	add    $0x10,%esp
  800a2f:	85 c0                	test   %eax,%eax
  800a31:	78 1d                	js     800a50 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  800a33:	39 d8                	cmp    %ebx,%eax
  800a35:	76 19                	jbe    800a50 <devfile_write+0x6a>
  800a37:	68 84 1e 80 00       	push   $0x801e84
  800a3c:	68 90 1e 80 00       	push   $0x801e90
  800a41:	68 a3 00 00 00       	push   $0xa3
  800a46:	68 a5 1e 80 00       	push   $0x801ea5
  800a4b:	e8 0a 06 00 00       	call   80105a <_panic>
	return r;
}
  800a50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a53:	c9                   	leave  
  800a54:	c3                   	ret    

00800a55 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8b 40 0c             	mov    0xc(%eax),%eax
  800a63:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a68:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a73:	b8 03 00 00 00       	mov    $0x3,%eax
  800a78:	e8 79 fe ff ff       	call   8008f6 <fsipc>
  800a7d:	89 c3                	mov    %eax,%ebx
  800a7f:	85 c0                	test   %eax,%eax
  800a81:	78 4b                	js     800ace <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a83:	39 c6                	cmp    %eax,%esi
  800a85:	73 16                	jae    800a9d <devfile_read+0x48>
  800a87:	68 b0 1e 80 00       	push   $0x801eb0
  800a8c:	68 90 1e 80 00       	push   $0x801e90
  800a91:	6a 7c                	push   $0x7c
  800a93:	68 a5 1e 80 00       	push   $0x801ea5
  800a98:	e8 bd 05 00 00       	call   80105a <_panic>
	assert(r <= PGSIZE);
  800a9d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa2:	7e 16                	jle    800aba <devfile_read+0x65>
  800aa4:	68 b7 1e 80 00       	push   $0x801eb7
  800aa9:	68 90 1e 80 00       	push   $0x801e90
  800aae:	6a 7d                	push   $0x7d
  800ab0:	68 a5 1e 80 00       	push   $0x801ea5
  800ab5:	e8 a0 05 00 00       	call   80105a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aba:	83 ec 04             	sub    $0x4,%esp
  800abd:	50                   	push   %eax
  800abe:	68 00 50 80 00       	push   $0x805000
  800ac3:	ff 75 0c             	pushl  0xc(%ebp)
  800ac6:	e8 7f 0d 00 00       	call   80184a <memmove>
	return r;
  800acb:	83 c4 10             	add    $0x10,%esp
}
  800ace:	89 d8                	mov    %ebx,%eax
  800ad0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	53                   	push   %ebx
  800adb:	83 ec 20             	sub    $0x20,%esp
  800ade:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae1:	53                   	push   %ebx
  800ae2:	e8 98 0b 00 00       	call   80167f <strlen>
  800ae7:	83 c4 10             	add    $0x10,%esp
  800aea:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aef:	7f 67                	jg     800b58 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af1:	83 ec 0c             	sub    $0xc,%esp
  800af4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af7:	50                   	push   %eax
  800af8:	e8 71 f8 ff ff       	call   80036e <fd_alloc>
  800afd:	83 c4 10             	add    $0x10,%esp
		return r;
  800b00:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b02:	85 c0                	test   %eax,%eax
  800b04:	78 57                	js     800b5d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b06:	83 ec 08             	sub    $0x8,%esp
  800b09:	53                   	push   %ebx
  800b0a:	68 00 50 80 00       	push   $0x805000
  800b0f:	e8 a4 0b 00 00       	call   8016b8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b17:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b24:	e8 cd fd ff ff       	call   8008f6 <fsipc>
  800b29:	89 c3                	mov    %eax,%ebx
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	79 14                	jns    800b46 <open+0x6f>
		fd_close(fd, 0);
  800b32:	83 ec 08             	sub    $0x8,%esp
  800b35:	6a 00                	push   $0x0
  800b37:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3a:	e8 27 f9 ff ff       	call   800466 <fd_close>
		return r;
  800b3f:	83 c4 10             	add    $0x10,%esp
  800b42:	89 da                	mov    %ebx,%edx
  800b44:	eb 17                	jmp    800b5d <open+0x86>
	}

	return fd2num(fd);
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4c:	e8 f6 f7 ff ff       	call   800347 <fd2num>
  800b51:	89 c2                	mov    %eax,%edx
  800b53:	83 c4 10             	add    $0x10,%esp
  800b56:	eb 05                	jmp    800b5d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b58:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5d:	89 d0                	mov    %edx,%eax
  800b5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 08 00 00 00       	mov    $0x8,%eax
  800b74:	e8 7d fd ff ff       	call   8008f6 <fsipc>
}
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	ff 75 08             	pushl  0x8(%ebp)
  800b89:	e8 c9 f7 ff ff       	call   800357 <fd2data>
  800b8e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b90:	83 c4 08             	add    $0x8,%esp
  800b93:	68 c3 1e 80 00       	push   $0x801ec3
  800b98:	53                   	push   %ebx
  800b99:	e8 1a 0b 00 00       	call   8016b8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b9e:	8b 46 04             	mov    0x4(%esi),%eax
  800ba1:	2b 06                	sub    (%esi),%eax
  800ba3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb0:	00 00 00 
	stat->st_dev = &devpipe;
  800bb3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bba:	30 80 00 
	return 0;
}
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd3:	53                   	push   %ebx
  800bd4:	6a 00                	push   $0x0
  800bd6:	e8 00 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bdb:	89 1c 24             	mov    %ebx,(%esp)
  800bde:	e8 74 f7 ff ff       	call   800357 <fd2data>
  800be3:	83 c4 08             	add    $0x8,%esp
  800be6:	50                   	push   %eax
  800be7:	6a 00                	push   $0x0
  800be9:	e8 ed f5 ff ff       	call   8001db <sys_page_unmap>
}
  800bee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf1:	c9                   	leave  
  800bf2:	c3                   	ret    

00800bf3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 1c             	sub    $0x1c,%esp
  800bfc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bff:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c01:	a1 04 40 80 00       	mov    0x804004,%eax
  800c06:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	ff 75 e0             	pushl  -0x20(%ebp)
  800c0f:	e8 e1 0e 00 00       	call   801af5 <pageref>
  800c14:	89 c3                	mov    %eax,%ebx
  800c16:	89 3c 24             	mov    %edi,(%esp)
  800c19:	e8 d7 0e 00 00       	call   801af5 <pageref>
  800c1e:	83 c4 10             	add    $0x10,%esp
  800c21:	39 c3                	cmp    %eax,%ebx
  800c23:	0f 94 c1             	sete   %cl
  800c26:	0f b6 c9             	movzbl %cl,%ecx
  800c29:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c2c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c32:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c35:	39 ce                	cmp    %ecx,%esi
  800c37:	74 1b                	je     800c54 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c39:	39 c3                	cmp    %eax,%ebx
  800c3b:	75 c4                	jne    800c01 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c3d:	8b 42 58             	mov    0x58(%edx),%eax
  800c40:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c43:	50                   	push   %eax
  800c44:	56                   	push   %esi
  800c45:	68 ca 1e 80 00       	push   $0x801eca
  800c4a:	e8 e4 04 00 00       	call   801133 <cprintf>
  800c4f:	83 c4 10             	add    $0x10,%esp
  800c52:	eb ad                	jmp    800c01 <_pipeisclosed+0xe>
	}
}
  800c54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 28             	sub    $0x28,%esp
  800c68:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c6b:	56                   	push   %esi
  800c6c:	e8 e6 f6 ff ff       	call   800357 <fd2data>
  800c71:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7b:	eb 4b                	jmp    800cc8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c7d:	89 da                	mov    %ebx,%edx
  800c7f:	89 f0                	mov    %esi,%eax
  800c81:	e8 6d ff ff ff       	call   800bf3 <_pipeisclosed>
  800c86:	85 c0                	test   %eax,%eax
  800c88:	75 48                	jne    800cd2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c8a:	e8 a8 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c8f:	8b 43 04             	mov    0x4(%ebx),%eax
  800c92:	8b 0b                	mov    (%ebx),%ecx
  800c94:	8d 51 20             	lea    0x20(%ecx),%edx
  800c97:	39 d0                	cmp    %edx,%eax
  800c99:	73 e2                	jae    800c7d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca5:	89 c2                	mov    %eax,%edx
  800ca7:	c1 fa 1f             	sar    $0x1f,%edx
  800caa:	89 d1                	mov    %edx,%ecx
  800cac:	c1 e9 1b             	shr    $0x1b,%ecx
  800caf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb2:	83 e2 1f             	and    $0x1f,%edx
  800cb5:	29 ca                	sub    %ecx,%edx
  800cb7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cbb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cbf:	83 c0 01             	add    $0x1,%eax
  800cc2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc5:	83 c7 01             	add    $0x1,%edi
  800cc8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ccb:	75 c2                	jne    800c8f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ccd:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd0:	eb 05                	jmp    800cd7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	83 ec 18             	sub    $0x18,%esp
  800ce8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ceb:	57                   	push   %edi
  800cec:	e8 66 f6 ff ff       	call   800357 <fd2data>
  800cf1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf3:	83 c4 10             	add    $0x10,%esp
  800cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfb:	eb 3d                	jmp    800d3a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cfd:	85 db                	test   %ebx,%ebx
  800cff:	74 04                	je     800d05 <devpipe_read+0x26>
				return i;
  800d01:	89 d8                	mov    %ebx,%eax
  800d03:	eb 44                	jmp    800d49 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d05:	89 f2                	mov    %esi,%edx
  800d07:	89 f8                	mov    %edi,%eax
  800d09:	e8 e5 fe ff ff       	call   800bf3 <_pipeisclosed>
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	75 32                	jne    800d44 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d12:	e8 20 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d17:	8b 06                	mov    (%esi),%eax
  800d19:	3b 46 04             	cmp    0x4(%esi),%eax
  800d1c:	74 df                	je     800cfd <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d1e:	99                   	cltd   
  800d1f:	c1 ea 1b             	shr    $0x1b,%edx
  800d22:	01 d0                	add    %edx,%eax
  800d24:	83 e0 1f             	and    $0x1f,%eax
  800d27:	29 d0                	sub    %edx,%eax
  800d29:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d34:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d37:	83 c3 01             	add    $0x1,%ebx
  800d3a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d3d:	75 d8                	jne    800d17 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d3f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d42:	eb 05                	jmp    800d49 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d44:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
  800d56:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5c:	50                   	push   %eax
  800d5d:	e8 0c f6 ff ff       	call   80036e <fd_alloc>
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	89 c2                	mov    %eax,%edx
  800d67:	85 c0                	test   %eax,%eax
  800d69:	0f 88 2c 01 00 00    	js     800e9b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6f:	83 ec 04             	sub    $0x4,%esp
  800d72:	68 07 04 00 00       	push   $0x407
  800d77:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7a:	6a 00                	push   $0x0
  800d7c:	e8 d5 f3 ff ff       	call   800156 <sys_page_alloc>
  800d81:	83 c4 10             	add    $0x10,%esp
  800d84:	89 c2                	mov    %eax,%edx
  800d86:	85 c0                	test   %eax,%eax
  800d88:	0f 88 0d 01 00 00    	js     800e9b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d94:	50                   	push   %eax
  800d95:	e8 d4 f5 ff ff       	call   80036e <fd_alloc>
  800d9a:	89 c3                	mov    %eax,%ebx
  800d9c:	83 c4 10             	add    $0x10,%esp
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	0f 88 e2 00 00 00    	js     800e89 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da7:	83 ec 04             	sub    $0x4,%esp
  800daa:	68 07 04 00 00       	push   $0x407
  800daf:	ff 75 f0             	pushl  -0x10(%ebp)
  800db2:	6a 00                	push   $0x0
  800db4:	e8 9d f3 ff ff       	call   800156 <sys_page_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	0f 88 c3 00 00 00    	js     800e89 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	ff 75 f4             	pushl  -0xc(%ebp)
  800dcc:	e8 86 f5 ff ff       	call   800357 <fd2data>
  800dd1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd3:	83 c4 0c             	add    $0xc,%esp
  800dd6:	68 07 04 00 00       	push   $0x407
  800ddb:	50                   	push   %eax
  800ddc:	6a 00                	push   $0x0
  800dde:	e8 73 f3 ff ff       	call   800156 <sys_page_alloc>
  800de3:	89 c3                	mov    %eax,%ebx
  800de5:	83 c4 10             	add    $0x10,%esp
  800de8:	85 c0                	test   %eax,%eax
  800dea:	0f 88 89 00 00 00    	js     800e79 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	ff 75 f0             	pushl  -0x10(%ebp)
  800df6:	e8 5c f5 ff ff       	call   800357 <fd2data>
  800dfb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e02:	50                   	push   %eax
  800e03:	6a 00                	push   $0x0
  800e05:	56                   	push   %esi
  800e06:	6a 00                	push   $0x0
  800e08:	e8 8c f3 ff ff       	call   800199 <sys_page_map>
  800e0d:	89 c3                	mov    %eax,%ebx
  800e0f:	83 c4 20             	add    $0x20,%esp
  800e12:	85 c0                	test   %eax,%eax
  800e14:	78 55                	js     800e6b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e16:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e24:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e34:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e39:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e40:	83 ec 0c             	sub    $0xc,%esp
  800e43:	ff 75 f4             	pushl  -0xc(%ebp)
  800e46:	e8 fc f4 ff ff       	call   800347 <fd2num>
  800e4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e50:	83 c4 04             	add    $0x4,%esp
  800e53:	ff 75 f0             	pushl  -0x10(%ebp)
  800e56:	e8 ec f4 ff ff       	call   800347 <fd2num>
  800e5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	ba 00 00 00 00       	mov    $0x0,%edx
  800e69:	eb 30                	jmp    800e9b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e6b:	83 ec 08             	sub    $0x8,%esp
  800e6e:	56                   	push   %esi
  800e6f:	6a 00                	push   $0x0
  800e71:	e8 65 f3 ff ff       	call   8001db <sys_page_unmap>
  800e76:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e79:	83 ec 08             	sub    $0x8,%esp
  800e7c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7f:	6a 00                	push   $0x0
  800e81:	e8 55 f3 ff ff       	call   8001db <sys_page_unmap>
  800e86:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e89:	83 ec 08             	sub    $0x8,%esp
  800e8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8f:	6a 00                	push   $0x0
  800e91:	e8 45 f3 ff ff       	call   8001db <sys_page_unmap>
  800e96:	83 c4 10             	add    $0x10,%esp
  800e99:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ead:	50                   	push   %eax
  800eae:	ff 75 08             	pushl  0x8(%ebp)
  800eb1:	e8 07 f5 ff ff       	call   8003bd <fd_lookup>
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	78 18                	js     800ed5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec3:	e8 8f f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800ec8:	89 c2                	mov    %eax,%edx
  800eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ecd:	e8 21 fd ff ff       	call   800bf3 <_pipeisclosed>
  800ed2:	83 c4 10             	add    $0x10,%esp
}
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee7:	68 e2 1e 80 00       	push   $0x801ee2
  800eec:	ff 75 0c             	pushl  0xc(%ebp)
  800eef:	e8 c4 07 00 00       	call   8016b8 <strcpy>
	return 0;
}
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f07:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f12:	eb 2d                	jmp    800f41 <devcons_write+0x46>
		m = n - tot;
  800f14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f17:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f19:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f1c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f21:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f24:	83 ec 04             	sub    $0x4,%esp
  800f27:	53                   	push   %ebx
  800f28:	03 45 0c             	add    0xc(%ebp),%eax
  800f2b:	50                   	push   %eax
  800f2c:	57                   	push   %edi
  800f2d:	e8 18 09 00 00       	call   80184a <memmove>
		sys_cputs(buf, m);
  800f32:	83 c4 08             	add    $0x8,%esp
  800f35:	53                   	push   %ebx
  800f36:	57                   	push   %edi
  800f37:	e8 5e f1 ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3c:	01 de                	add    %ebx,%esi
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	89 f0                	mov    %esi,%eax
  800f43:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f46:	72 cc                	jb     800f14 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	5f                   	pop    %edi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    

00800f50 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	83 ec 08             	sub    $0x8,%esp
  800f56:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f5b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f5f:	74 2a                	je     800f8b <devcons_read+0x3b>
  800f61:	eb 05                	jmp    800f68 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f63:	e8 cf f1 ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f68:	e8 4b f1 ff ff       	call   8000b8 <sys_cgetc>
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	74 f2                	je     800f63 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f71:	85 c0                	test   %eax,%eax
  800f73:	78 16                	js     800f8b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f75:	83 f8 04             	cmp    $0x4,%eax
  800f78:	74 0c                	je     800f86 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7d:	88 02                	mov    %al,(%edx)
	return 1;
  800f7f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f84:	eb 05                	jmp    800f8b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f86:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
  800f96:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f99:	6a 01                	push   $0x1
  800f9b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9e:	50                   	push   %eax
  800f9f:	e8 f6 f0 ff ff       	call   80009a <sys_cputs>
}
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    

00800fa9 <getchar>:

int
getchar(void)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800faf:	6a 01                	push   $0x1
  800fb1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 67 f6 ff ff       	call   800623 <read>
	if (r < 0)
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 0f                	js     800fd2 <getchar+0x29>
		return r;
	if (r < 1)
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	7e 06                	jle    800fcd <getchar+0x24>
		return -E_EOF;
	return c;
  800fc7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fcb:	eb 05                	jmp    800fd2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fcd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    

00800fd4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdd:	50                   	push   %eax
  800fde:	ff 75 08             	pushl  0x8(%ebp)
  800fe1:	e8 d7 f3 ff ff       	call   8003bd <fd_lookup>
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 11                	js     800ffe <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff6:	39 10                	cmp    %edx,(%eax)
  800ff8:	0f 94 c0             	sete   %al
  800ffb:	0f b6 c0             	movzbl %al,%eax
}
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    

00801000 <opencons>:

int
opencons(void)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801006:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801009:	50                   	push   %eax
  80100a:	e8 5f f3 ff ff       	call   80036e <fd_alloc>
  80100f:	83 c4 10             	add    $0x10,%esp
		return r;
  801012:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801014:	85 c0                	test   %eax,%eax
  801016:	78 3e                	js     801056 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	68 07 04 00 00       	push   $0x407
  801020:	ff 75 f4             	pushl  -0xc(%ebp)
  801023:	6a 00                	push   $0x0
  801025:	e8 2c f1 ff ff       	call   800156 <sys_page_alloc>
  80102a:	83 c4 10             	add    $0x10,%esp
		return r;
  80102d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 23                	js     801056 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801033:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801039:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80103e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801041:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	50                   	push   %eax
  80104c:	e8 f6 f2 ff ff       	call   800347 <fd2num>
  801051:	89 c2                	mov    %eax,%edx
  801053:	83 c4 10             	add    $0x10,%esp
}
  801056:	89 d0                	mov    %edx,%eax
  801058:	c9                   	leave  
  801059:	c3                   	ret    

0080105a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	56                   	push   %esi
  80105e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80105f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801062:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801068:	e8 ab f0 ff ff       	call   800118 <sys_getenvid>
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	ff 75 0c             	pushl  0xc(%ebp)
  801073:	ff 75 08             	pushl  0x8(%ebp)
  801076:	56                   	push   %esi
  801077:	50                   	push   %eax
  801078:	68 f0 1e 80 00       	push   $0x801ef0
  80107d:	e8 b1 00 00 00       	call   801133 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801082:	83 c4 18             	add    $0x18,%esp
  801085:	53                   	push   %ebx
  801086:	ff 75 10             	pushl  0x10(%ebp)
  801089:	e8 54 00 00 00       	call   8010e2 <vcprintf>
	cprintf("\n");
  80108e:	c7 04 24 db 1e 80 00 	movl   $0x801edb,(%esp)
  801095:	e8 99 00 00 00       	call   801133 <cprintf>
  80109a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109d:	cc                   	int3   
  80109e:	eb fd                	jmp    80109d <_panic+0x43>

008010a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 04             	sub    $0x4,%esp
  8010a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010aa:	8b 13                	mov    (%ebx),%edx
  8010ac:	8d 42 01             	lea    0x1(%edx),%eax
  8010af:	89 03                	mov    %eax,(%ebx)
  8010b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010bd:	75 1a                	jne    8010d9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010bf:	83 ec 08             	sub    $0x8,%esp
  8010c2:	68 ff 00 00 00       	push   $0xff
  8010c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ca:	50                   	push   %eax
  8010cb:	e8 ca ef ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8010d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010d9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f2:	00 00 00 
	b.cnt = 0;
  8010f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ff:	ff 75 0c             	pushl  0xc(%ebp)
  801102:	ff 75 08             	pushl  0x8(%ebp)
  801105:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80110b:	50                   	push   %eax
  80110c:	68 a0 10 80 00       	push   $0x8010a0
  801111:	e8 54 01 00 00       	call   80126a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801116:	83 c4 08             	add    $0x8,%esp
  801119:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80111f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	e8 6f ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  80112b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801131:	c9                   	leave  
  801132:	c3                   	ret    

00801133 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801139:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80113c:	50                   	push   %eax
  80113d:	ff 75 08             	pushl  0x8(%ebp)
  801140:	e8 9d ff ff ff       	call   8010e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	57                   	push   %edi
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	83 ec 1c             	sub    $0x1c,%esp
  801150:	89 c7                	mov    %eax,%edi
  801152:	89 d6                	mov    %edx,%esi
  801154:	8b 45 08             	mov    0x8(%ebp),%eax
  801157:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80115d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801160:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801163:	bb 00 00 00 00       	mov    $0x0,%ebx
  801168:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80116b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80116e:	39 d3                	cmp    %edx,%ebx
  801170:	72 05                	jb     801177 <printnum+0x30>
  801172:	39 45 10             	cmp    %eax,0x10(%ebp)
  801175:	77 45                	ja     8011bc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801177:	83 ec 0c             	sub    $0xc,%esp
  80117a:	ff 75 18             	pushl  0x18(%ebp)
  80117d:	8b 45 14             	mov    0x14(%ebp),%eax
  801180:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801183:	53                   	push   %ebx
  801184:	ff 75 10             	pushl  0x10(%ebp)
  801187:	83 ec 08             	sub    $0x8,%esp
  80118a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118d:	ff 75 e0             	pushl  -0x20(%ebp)
  801190:	ff 75 dc             	pushl  -0x24(%ebp)
  801193:	ff 75 d8             	pushl  -0x28(%ebp)
  801196:	e8 95 09 00 00       	call   801b30 <__udivdi3>
  80119b:	83 c4 18             	add    $0x18,%esp
  80119e:	52                   	push   %edx
  80119f:	50                   	push   %eax
  8011a0:	89 f2                	mov    %esi,%edx
  8011a2:	89 f8                	mov    %edi,%eax
  8011a4:	e8 9e ff ff ff       	call   801147 <printnum>
  8011a9:	83 c4 20             	add    $0x20,%esp
  8011ac:	eb 18                	jmp    8011c6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	56                   	push   %esi
  8011b2:	ff 75 18             	pushl  0x18(%ebp)
  8011b5:	ff d7                	call   *%edi
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	eb 03                	jmp    8011bf <printnum+0x78>
  8011bc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011bf:	83 eb 01             	sub    $0x1,%ebx
  8011c2:	85 db                	test   %ebx,%ebx
  8011c4:	7f e8                	jg     8011ae <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c6:	83 ec 08             	sub    $0x8,%esp
  8011c9:	56                   	push   %esi
  8011ca:	83 ec 04             	sub    $0x4,%esp
  8011cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d9:	e8 82 0a 00 00       	call   801c60 <__umoddi3>
  8011de:	83 c4 14             	add    $0x14,%esp
  8011e1:	0f be 80 13 1f 80 00 	movsbl 0x801f13(%eax),%eax
  8011e8:	50                   	push   %eax
  8011e9:	ff d7                	call   *%edi
}
  8011eb:	83 c4 10             	add    $0x10,%esp
  8011ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5f                   	pop    %edi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011f9:	83 fa 01             	cmp    $0x1,%edx
  8011fc:	7e 0e                	jle    80120c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011fe:	8b 10                	mov    (%eax),%edx
  801200:	8d 4a 08             	lea    0x8(%edx),%ecx
  801203:	89 08                	mov    %ecx,(%eax)
  801205:	8b 02                	mov    (%edx),%eax
  801207:	8b 52 04             	mov    0x4(%edx),%edx
  80120a:	eb 22                	jmp    80122e <getuint+0x38>
	else if (lflag)
  80120c:	85 d2                	test   %edx,%edx
  80120e:	74 10                	je     801220 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801210:	8b 10                	mov    (%eax),%edx
  801212:	8d 4a 04             	lea    0x4(%edx),%ecx
  801215:	89 08                	mov    %ecx,(%eax)
  801217:	8b 02                	mov    (%edx),%eax
  801219:	ba 00 00 00 00       	mov    $0x0,%edx
  80121e:	eb 0e                	jmp    80122e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801220:	8b 10                	mov    (%eax),%edx
  801222:	8d 4a 04             	lea    0x4(%edx),%ecx
  801225:	89 08                	mov    %ecx,(%eax)
  801227:	8b 02                	mov    (%edx),%eax
  801229:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801236:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80123a:	8b 10                	mov    (%eax),%edx
  80123c:	3b 50 04             	cmp    0x4(%eax),%edx
  80123f:	73 0a                	jae    80124b <sprintputch+0x1b>
		*b->buf++ = ch;
  801241:	8d 4a 01             	lea    0x1(%edx),%ecx
  801244:	89 08                	mov    %ecx,(%eax)
  801246:	8b 45 08             	mov    0x8(%ebp),%eax
  801249:	88 02                	mov    %al,(%edx)
}
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801253:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801256:	50                   	push   %eax
  801257:	ff 75 10             	pushl  0x10(%ebp)
  80125a:	ff 75 0c             	pushl  0xc(%ebp)
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 05 00 00 00       	call   80126a <vprintfmt>
	va_end(ap);
}
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	57                   	push   %edi
  80126e:	56                   	push   %esi
  80126f:	53                   	push   %ebx
  801270:	83 ec 2c             	sub    $0x2c,%esp
  801273:	8b 75 08             	mov    0x8(%ebp),%esi
  801276:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801279:	8b 7d 10             	mov    0x10(%ebp),%edi
  80127c:	eb 12                	jmp    801290 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80127e:	85 c0                	test   %eax,%eax
  801280:	0f 84 89 03 00 00    	je     80160f <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	53                   	push   %ebx
  80128a:	50                   	push   %eax
  80128b:	ff d6                	call   *%esi
  80128d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801290:	83 c7 01             	add    $0x1,%edi
  801293:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801297:	83 f8 25             	cmp    $0x25,%eax
  80129a:	75 e2                	jne    80127e <vprintfmt+0x14>
  80129c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012a7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012ae:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ba:	eb 07                	jmp    8012c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012bf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c3:	8d 47 01             	lea    0x1(%edi),%eax
  8012c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c9:	0f b6 07             	movzbl (%edi),%eax
  8012cc:	0f b6 c8             	movzbl %al,%ecx
  8012cf:	83 e8 23             	sub    $0x23,%eax
  8012d2:	3c 55                	cmp    $0x55,%al
  8012d4:	0f 87 1a 03 00 00    	ja     8015f4 <vprintfmt+0x38a>
  8012da:	0f b6 c0             	movzbl %al,%eax
  8012dd:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8012e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012e7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012eb:	eb d6                	jmp    8012c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012fb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012ff:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801302:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801305:	83 fa 09             	cmp    $0x9,%edx
  801308:	77 39                	ja     801343 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80130a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80130d:	eb e9                	jmp    8012f8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80130f:	8b 45 14             	mov    0x14(%ebp),%eax
  801312:	8d 48 04             	lea    0x4(%eax),%ecx
  801315:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801318:	8b 00                	mov    (%eax),%eax
  80131a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801320:	eb 27                	jmp    801349 <vprintfmt+0xdf>
  801322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801325:	85 c0                	test   %eax,%eax
  801327:	b9 00 00 00 00       	mov    $0x0,%ecx
  80132c:	0f 49 c8             	cmovns %eax,%ecx
  80132f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801335:	eb 8c                	jmp    8012c3 <vprintfmt+0x59>
  801337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80133a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801341:	eb 80                	jmp    8012c3 <vprintfmt+0x59>
  801343:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801346:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801349:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80134d:	0f 89 70 ff ff ff    	jns    8012c3 <vprintfmt+0x59>
				width = precision, precision = -1;
  801353:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801356:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801359:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801360:	e9 5e ff ff ff       	jmp    8012c3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801365:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80136b:	e9 53 ff ff ff       	jmp    8012c3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801370:	8b 45 14             	mov    0x14(%ebp),%eax
  801373:	8d 50 04             	lea    0x4(%eax),%edx
  801376:	89 55 14             	mov    %edx,0x14(%ebp)
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	53                   	push   %ebx
  80137d:	ff 30                	pushl  (%eax)
  80137f:	ff d6                	call   *%esi
			break;
  801381:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801387:	e9 04 ff ff ff       	jmp    801290 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80138c:	8b 45 14             	mov    0x14(%ebp),%eax
  80138f:	8d 50 04             	lea    0x4(%eax),%edx
  801392:	89 55 14             	mov    %edx,0x14(%ebp)
  801395:	8b 00                	mov    (%eax),%eax
  801397:	99                   	cltd   
  801398:	31 d0                	xor    %edx,%eax
  80139a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80139c:	83 f8 0f             	cmp    $0xf,%eax
  80139f:	7f 0b                	jg     8013ac <vprintfmt+0x142>
  8013a1:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013a8:	85 d2                	test   %edx,%edx
  8013aa:	75 18                	jne    8013c4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013ac:	50                   	push   %eax
  8013ad:	68 2b 1f 80 00       	push   $0x801f2b
  8013b2:	53                   	push   %ebx
  8013b3:	56                   	push   %esi
  8013b4:	e8 94 fe ff ff       	call   80124d <printfmt>
  8013b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013bf:	e9 cc fe ff ff       	jmp    801290 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013c4:	52                   	push   %edx
  8013c5:	68 a2 1e 80 00       	push   $0x801ea2
  8013ca:	53                   	push   %ebx
  8013cb:	56                   	push   %esi
  8013cc:	e8 7c fe ff ff       	call   80124d <printfmt>
  8013d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d7:	e9 b4 fe ff ff       	jmp    801290 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8013df:	8d 50 04             	lea    0x4(%eax),%edx
  8013e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013e7:	85 ff                	test   %edi,%edi
  8013e9:	b8 24 1f 80 00       	mov    $0x801f24,%eax
  8013ee:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013f5:	0f 8e 94 00 00 00    	jle    80148f <vprintfmt+0x225>
  8013fb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013ff:	0f 84 98 00 00 00    	je     80149d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	ff 75 d0             	pushl  -0x30(%ebp)
  80140b:	57                   	push   %edi
  80140c:	e8 86 02 00 00       	call   801697 <strnlen>
  801411:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801414:	29 c1                	sub    %eax,%ecx
  801416:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801419:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80141c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801423:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801426:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801428:	eb 0f                	jmp    801439 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	53                   	push   %ebx
  80142e:	ff 75 e0             	pushl  -0x20(%ebp)
  801431:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801433:	83 ef 01             	sub    $0x1,%edi
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	85 ff                	test   %edi,%edi
  80143b:	7f ed                	jg     80142a <vprintfmt+0x1c0>
  80143d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801440:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801443:	85 c9                	test   %ecx,%ecx
  801445:	b8 00 00 00 00       	mov    $0x0,%eax
  80144a:	0f 49 c1             	cmovns %ecx,%eax
  80144d:	29 c1                	sub    %eax,%ecx
  80144f:	89 75 08             	mov    %esi,0x8(%ebp)
  801452:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801455:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801458:	89 cb                	mov    %ecx,%ebx
  80145a:	eb 4d                	jmp    8014a9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80145c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801460:	74 1b                	je     80147d <vprintfmt+0x213>
  801462:	0f be c0             	movsbl %al,%eax
  801465:	83 e8 20             	sub    $0x20,%eax
  801468:	83 f8 5e             	cmp    $0x5e,%eax
  80146b:	76 10                	jbe    80147d <vprintfmt+0x213>
					putch('?', putdat);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	ff 75 0c             	pushl  0xc(%ebp)
  801473:	6a 3f                	push   $0x3f
  801475:	ff 55 08             	call   *0x8(%ebp)
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	eb 0d                	jmp    80148a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	ff 75 0c             	pushl  0xc(%ebp)
  801483:	52                   	push   %edx
  801484:	ff 55 08             	call   *0x8(%ebp)
  801487:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148a:	83 eb 01             	sub    $0x1,%ebx
  80148d:	eb 1a                	jmp    8014a9 <vprintfmt+0x23f>
  80148f:	89 75 08             	mov    %esi,0x8(%ebp)
  801492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801498:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80149b:	eb 0c                	jmp    8014a9 <vprintfmt+0x23f>
  80149d:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a9:	83 c7 01             	add    $0x1,%edi
  8014ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b0:	0f be d0             	movsbl %al,%edx
  8014b3:	85 d2                	test   %edx,%edx
  8014b5:	74 23                	je     8014da <vprintfmt+0x270>
  8014b7:	85 f6                	test   %esi,%esi
  8014b9:	78 a1                	js     80145c <vprintfmt+0x1f2>
  8014bb:	83 ee 01             	sub    $0x1,%esi
  8014be:	79 9c                	jns    80145c <vprintfmt+0x1f2>
  8014c0:	89 df                	mov    %ebx,%edi
  8014c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c8:	eb 18                	jmp    8014e2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	6a 20                	push   $0x20
  8014d0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014d2:	83 ef 01             	sub    $0x1,%edi
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb 08                	jmp    8014e2 <vprintfmt+0x278>
  8014da:	89 df                	mov    %ebx,%edi
  8014dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8014df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e2:	85 ff                	test   %edi,%edi
  8014e4:	7f e4                	jg     8014ca <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e9:	e9 a2 fd ff ff       	jmp    801290 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ee:	83 fa 01             	cmp    $0x1,%edx
  8014f1:	7e 16                	jle    801509 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f6:	8d 50 08             	lea    0x8(%eax),%edx
  8014f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8014fc:	8b 50 04             	mov    0x4(%eax),%edx
  8014ff:	8b 00                	mov    (%eax),%eax
  801501:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801504:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801507:	eb 32                	jmp    80153b <vprintfmt+0x2d1>
	else if (lflag)
  801509:	85 d2                	test   %edx,%edx
  80150b:	74 18                	je     801525 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80150d:	8b 45 14             	mov    0x14(%ebp),%eax
  801510:	8d 50 04             	lea    0x4(%eax),%edx
  801513:	89 55 14             	mov    %edx,0x14(%ebp)
  801516:	8b 00                	mov    (%eax),%eax
  801518:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151b:	89 c1                	mov    %eax,%ecx
  80151d:	c1 f9 1f             	sar    $0x1f,%ecx
  801520:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801523:	eb 16                	jmp    80153b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801525:	8b 45 14             	mov    0x14(%ebp),%eax
  801528:	8d 50 04             	lea    0x4(%eax),%edx
  80152b:	89 55 14             	mov    %edx,0x14(%ebp)
  80152e:	8b 00                	mov    (%eax),%eax
  801530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801533:	89 c1                	mov    %eax,%ecx
  801535:	c1 f9 1f             	sar    $0x1f,%ecx
  801538:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80153b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80153e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801541:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801546:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80154a:	79 74                	jns    8015c0 <vprintfmt+0x356>
				putch('-', putdat);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	53                   	push   %ebx
  801550:	6a 2d                	push   $0x2d
  801552:	ff d6                	call   *%esi
				num = -(long long) num;
  801554:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80155a:	f7 d8                	neg    %eax
  80155c:	83 d2 00             	adc    $0x0,%edx
  80155f:	f7 da                	neg    %edx
  801561:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801564:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801569:	eb 55                	jmp    8015c0 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80156b:	8d 45 14             	lea    0x14(%ebp),%eax
  80156e:	e8 83 fc ff ff       	call   8011f6 <getuint>
			base = 10;
  801573:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801578:	eb 46                	jmp    8015c0 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80157a:	8d 45 14             	lea    0x14(%ebp),%eax
  80157d:	e8 74 fc ff ff       	call   8011f6 <getuint>
                        base = 8;
  801582:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801587:	eb 37                	jmp    8015c0 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	53                   	push   %ebx
  80158d:	6a 30                	push   $0x30
  80158f:	ff d6                	call   *%esi
			putch('x', putdat);
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	53                   	push   %ebx
  801595:	6a 78                	push   $0x78
  801597:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801599:	8b 45 14             	mov    0x14(%ebp),%eax
  80159c:	8d 50 04             	lea    0x4(%eax),%edx
  80159f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015a2:	8b 00                	mov    (%eax),%eax
  8015a4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015a9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015ac:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b1:	eb 0d                	jmp    8015c0 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b6:	e8 3b fc ff ff       	call   8011f6 <getuint>
			base = 16;
  8015bb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c0:	83 ec 0c             	sub    $0xc,%esp
  8015c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c7:	57                   	push   %edi
  8015c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015cb:	51                   	push   %ecx
  8015cc:	52                   	push   %edx
  8015cd:	50                   	push   %eax
  8015ce:	89 da                	mov    %ebx,%edx
  8015d0:	89 f0                	mov    %esi,%eax
  8015d2:	e8 70 fb ff ff       	call   801147 <printnum>
			break;
  8015d7:	83 c4 20             	add    $0x20,%esp
  8015da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015dd:	e9 ae fc ff ff       	jmp    801290 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	53                   	push   %ebx
  8015e6:	51                   	push   %ecx
  8015e7:	ff d6                	call   *%esi
			break;
  8015e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ef:	e9 9c fc ff ff       	jmp    801290 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	53                   	push   %ebx
  8015f8:	6a 25                	push   $0x25
  8015fa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	eb 03                	jmp    801604 <vprintfmt+0x39a>
  801601:	83 ef 01             	sub    $0x1,%edi
  801604:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801608:	75 f7                	jne    801601 <vprintfmt+0x397>
  80160a:	e9 81 fc ff ff       	jmp    801290 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80160f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5f                   	pop    %edi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	83 ec 18             	sub    $0x18,%esp
  80161d:	8b 45 08             	mov    0x8(%ebp),%eax
  801620:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801623:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801626:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80162d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801634:	85 c0                	test   %eax,%eax
  801636:	74 26                	je     80165e <vsnprintf+0x47>
  801638:	85 d2                	test   %edx,%edx
  80163a:	7e 22                	jle    80165e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80163c:	ff 75 14             	pushl  0x14(%ebp)
  80163f:	ff 75 10             	pushl  0x10(%ebp)
  801642:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	68 30 12 80 00       	push   $0x801230
  80164b:	e8 1a fc ff ff       	call   80126a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801650:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801653:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 05                	jmp    801663 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80165e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80166b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80166e:	50                   	push   %eax
  80166f:	ff 75 10             	pushl  0x10(%ebp)
  801672:	ff 75 0c             	pushl  0xc(%ebp)
  801675:	ff 75 08             	pushl  0x8(%ebp)
  801678:	e8 9a ff ff ff       	call   801617 <vsnprintf>
	va_end(ap);

	return rc;
}
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
  80168a:	eb 03                	jmp    80168f <strlen+0x10>
		n++;
  80168c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80168f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801693:	75 f7                	jne    80168c <strlen+0xd>
		n++;
	return n;
}
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a5:	eb 03                	jmp    8016aa <strnlen+0x13>
		n++;
  8016a7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016aa:	39 c2                	cmp    %eax,%edx
  8016ac:	74 08                	je     8016b6 <strnlen+0x1f>
  8016ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016b2:	75 f3                	jne    8016a7 <strnlen+0x10>
  8016b4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	53                   	push   %ebx
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	83 c2 01             	add    $0x1,%edx
  8016c7:	83 c1 01             	add    $0x1,%ecx
  8016ca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016d1:	84 db                	test   %bl,%bl
  8016d3:	75 ef                	jne    8016c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d5:	5b                   	pop    %ebx
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	53                   	push   %ebx
  8016dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016df:	53                   	push   %ebx
  8016e0:	e8 9a ff ff ff       	call   80167f <strlen>
  8016e5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e8:	ff 75 0c             	pushl  0xc(%ebp)
  8016eb:	01 d8                	add    %ebx,%eax
  8016ed:	50                   	push   %eax
  8016ee:	e8 c5 ff ff ff       	call   8016b8 <strcpy>
	return dst;
}
  8016f3:	89 d8                	mov    %ebx,%eax
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
  8016ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801702:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801705:	89 f3                	mov    %esi,%ebx
  801707:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170a:	89 f2                	mov    %esi,%edx
  80170c:	eb 0f                	jmp    80171d <strncpy+0x23>
		*dst++ = *src;
  80170e:	83 c2 01             	add    $0x1,%edx
  801711:	0f b6 01             	movzbl (%ecx),%eax
  801714:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801717:	80 39 01             	cmpb   $0x1,(%ecx)
  80171a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171d:	39 da                	cmp    %ebx,%edx
  80171f:	75 ed                	jne    80170e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801721:	89 f0                	mov    %esi,%eax
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
  80172c:	8b 75 08             	mov    0x8(%ebp),%esi
  80172f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801732:	8b 55 10             	mov    0x10(%ebp),%edx
  801735:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801737:	85 d2                	test   %edx,%edx
  801739:	74 21                	je     80175c <strlcpy+0x35>
  80173b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173f:	89 f2                	mov    %esi,%edx
  801741:	eb 09                	jmp    80174c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801743:	83 c2 01             	add    $0x1,%edx
  801746:	83 c1 01             	add    $0x1,%ecx
  801749:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80174c:	39 c2                	cmp    %eax,%edx
  80174e:	74 09                	je     801759 <strlcpy+0x32>
  801750:	0f b6 19             	movzbl (%ecx),%ebx
  801753:	84 db                	test   %bl,%bl
  801755:	75 ec                	jne    801743 <strlcpy+0x1c>
  801757:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801759:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80175c:	29 f0                	sub    %esi,%eax
}
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801768:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176b:	eb 06                	jmp    801773 <strcmp+0x11>
		p++, q++;
  80176d:	83 c1 01             	add    $0x1,%ecx
  801770:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801773:	0f b6 01             	movzbl (%ecx),%eax
  801776:	84 c0                	test   %al,%al
  801778:	74 04                	je     80177e <strcmp+0x1c>
  80177a:	3a 02                	cmp    (%edx),%al
  80177c:	74 ef                	je     80176d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177e:	0f b6 c0             	movzbl %al,%eax
  801781:	0f b6 12             	movzbl (%edx),%edx
  801784:	29 d0                	sub    %edx,%eax
}
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801792:	89 c3                	mov    %eax,%ebx
  801794:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801797:	eb 06                	jmp    80179f <strncmp+0x17>
		n--, p++, q++;
  801799:	83 c0 01             	add    $0x1,%eax
  80179c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80179f:	39 d8                	cmp    %ebx,%eax
  8017a1:	74 15                	je     8017b8 <strncmp+0x30>
  8017a3:	0f b6 08             	movzbl (%eax),%ecx
  8017a6:	84 c9                	test   %cl,%cl
  8017a8:	74 04                	je     8017ae <strncmp+0x26>
  8017aa:	3a 0a                	cmp    (%edx),%cl
  8017ac:	74 eb                	je     801799 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ae:	0f b6 00             	movzbl (%eax),%eax
  8017b1:	0f b6 12             	movzbl (%edx),%edx
  8017b4:	29 d0                	sub    %edx,%eax
  8017b6:	eb 05                	jmp    8017bd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017bd:	5b                   	pop    %ebx
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ca:	eb 07                	jmp    8017d3 <strchr+0x13>
		if (*s == c)
  8017cc:	38 ca                	cmp    %cl,%dl
  8017ce:	74 0f                	je     8017df <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d0:	83 c0 01             	add    $0x1,%eax
  8017d3:	0f b6 10             	movzbl (%eax),%edx
  8017d6:	84 d2                	test   %dl,%dl
  8017d8:	75 f2                	jne    8017cc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017eb:	eb 03                	jmp    8017f0 <strfind+0xf>
  8017ed:	83 c0 01             	add    $0x1,%eax
  8017f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f3:	38 ca                	cmp    %cl,%dl
  8017f5:	74 04                	je     8017fb <strfind+0x1a>
  8017f7:	84 d2                	test   %dl,%dl
  8017f9:	75 f2                	jne    8017ed <strfind+0xc>
			break;
	return (char *) s;
}
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	57                   	push   %edi
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
  801803:	8b 7d 08             	mov    0x8(%ebp),%edi
  801806:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801809:	85 c9                	test   %ecx,%ecx
  80180b:	74 36                	je     801843 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801813:	75 28                	jne    80183d <memset+0x40>
  801815:	f6 c1 03             	test   $0x3,%cl
  801818:	75 23                	jne    80183d <memset+0x40>
		c &= 0xFF;
  80181a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181e:	89 d3                	mov    %edx,%ebx
  801820:	c1 e3 08             	shl    $0x8,%ebx
  801823:	89 d6                	mov    %edx,%esi
  801825:	c1 e6 18             	shl    $0x18,%esi
  801828:	89 d0                	mov    %edx,%eax
  80182a:	c1 e0 10             	shl    $0x10,%eax
  80182d:	09 f0                	or     %esi,%eax
  80182f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801831:	89 d8                	mov    %ebx,%eax
  801833:	09 d0                	or     %edx,%eax
  801835:	c1 e9 02             	shr    $0x2,%ecx
  801838:	fc                   	cld    
  801839:	f3 ab                	rep stos %eax,%es:(%edi)
  80183b:	eb 06                	jmp    801843 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80183d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801840:	fc                   	cld    
  801841:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801843:	89 f8                	mov    %edi,%eax
  801845:	5b                   	pop    %ebx
  801846:	5e                   	pop    %esi
  801847:	5f                   	pop    %edi
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	57                   	push   %edi
  80184e:	56                   	push   %esi
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	8b 75 0c             	mov    0xc(%ebp),%esi
  801855:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801858:	39 c6                	cmp    %eax,%esi
  80185a:	73 35                	jae    801891 <memmove+0x47>
  80185c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80185f:	39 d0                	cmp    %edx,%eax
  801861:	73 2e                	jae    801891 <memmove+0x47>
		s += n;
		d += n;
  801863:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801866:	89 d6                	mov    %edx,%esi
  801868:	09 fe                	or     %edi,%esi
  80186a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801870:	75 13                	jne    801885 <memmove+0x3b>
  801872:	f6 c1 03             	test   $0x3,%cl
  801875:	75 0e                	jne    801885 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801877:	83 ef 04             	sub    $0x4,%edi
  80187a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80187d:	c1 e9 02             	shr    $0x2,%ecx
  801880:	fd                   	std    
  801881:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801883:	eb 09                	jmp    80188e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801885:	83 ef 01             	sub    $0x1,%edi
  801888:	8d 72 ff             	lea    -0x1(%edx),%esi
  80188b:	fd                   	std    
  80188c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80188e:	fc                   	cld    
  80188f:	eb 1d                	jmp    8018ae <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801891:	89 f2                	mov    %esi,%edx
  801893:	09 c2                	or     %eax,%edx
  801895:	f6 c2 03             	test   $0x3,%dl
  801898:	75 0f                	jne    8018a9 <memmove+0x5f>
  80189a:	f6 c1 03             	test   $0x3,%cl
  80189d:	75 0a                	jne    8018a9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80189f:	c1 e9 02             	shr    $0x2,%ecx
  8018a2:	89 c7                	mov    %eax,%edi
  8018a4:	fc                   	cld    
  8018a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a7:	eb 05                	jmp    8018ae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a9:	89 c7                	mov    %eax,%edi
  8018ab:	fc                   	cld    
  8018ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ae:	5e                   	pop    %esi
  8018af:	5f                   	pop    %edi
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b5:	ff 75 10             	pushl  0x10(%ebp)
  8018b8:	ff 75 0c             	pushl  0xc(%ebp)
  8018bb:	ff 75 08             	pushl  0x8(%ebp)
  8018be:	e8 87 ff ff ff       	call   80184a <memmove>
}
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d0:	89 c6                	mov    %eax,%esi
  8018d2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d5:	eb 1a                	jmp    8018f1 <memcmp+0x2c>
		if (*s1 != *s2)
  8018d7:	0f b6 08             	movzbl (%eax),%ecx
  8018da:	0f b6 1a             	movzbl (%edx),%ebx
  8018dd:	38 d9                	cmp    %bl,%cl
  8018df:	74 0a                	je     8018eb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018e1:	0f b6 c1             	movzbl %cl,%eax
  8018e4:	0f b6 db             	movzbl %bl,%ebx
  8018e7:	29 d8                	sub    %ebx,%eax
  8018e9:	eb 0f                	jmp    8018fa <memcmp+0x35>
		s1++, s2++;
  8018eb:	83 c0 01             	add    $0x1,%eax
  8018ee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f1:	39 f0                	cmp    %esi,%eax
  8018f3:	75 e2                	jne    8018d7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	53                   	push   %ebx
  801902:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801905:	89 c1                	mov    %eax,%ecx
  801907:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80190a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190e:	eb 0a                	jmp    80191a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801910:	0f b6 10             	movzbl (%eax),%edx
  801913:	39 da                	cmp    %ebx,%edx
  801915:	74 07                	je     80191e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801917:	83 c0 01             	add    $0x1,%eax
  80191a:	39 c8                	cmp    %ecx,%eax
  80191c:	72 f2                	jb     801910 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80191e:	5b                   	pop    %ebx
  80191f:	5d                   	pop    %ebp
  801920:	c3                   	ret    

00801921 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	57                   	push   %edi
  801925:	56                   	push   %esi
  801926:	53                   	push   %ebx
  801927:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192d:	eb 03                	jmp    801932 <strtol+0x11>
		s++;
  80192f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801932:	0f b6 01             	movzbl (%ecx),%eax
  801935:	3c 20                	cmp    $0x20,%al
  801937:	74 f6                	je     80192f <strtol+0xe>
  801939:	3c 09                	cmp    $0x9,%al
  80193b:	74 f2                	je     80192f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80193d:	3c 2b                	cmp    $0x2b,%al
  80193f:	75 0a                	jne    80194b <strtol+0x2a>
		s++;
  801941:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801944:	bf 00 00 00 00       	mov    $0x0,%edi
  801949:	eb 11                	jmp    80195c <strtol+0x3b>
  80194b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801950:	3c 2d                	cmp    $0x2d,%al
  801952:	75 08                	jne    80195c <strtol+0x3b>
		s++, neg = 1;
  801954:	83 c1 01             	add    $0x1,%ecx
  801957:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80195c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801962:	75 15                	jne    801979 <strtol+0x58>
  801964:	80 39 30             	cmpb   $0x30,(%ecx)
  801967:	75 10                	jne    801979 <strtol+0x58>
  801969:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80196d:	75 7c                	jne    8019eb <strtol+0xca>
		s += 2, base = 16;
  80196f:	83 c1 02             	add    $0x2,%ecx
  801972:	bb 10 00 00 00       	mov    $0x10,%ebx
  801977:	eb 16                	jmp    80198f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801979:	85 db                	test   %ebx,%ebx
  80197b:	75 12                	jne    80198f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80197d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801982:	80 39 30             	cmpb   $0x30,(%ecx)
  801985:	75 08                	jne    80198f <strtol+0x6e>
		s++, base = 8;
  801987:	83 c1 01             	add    $0x1,%ecx
  80198a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80198f:	b8 00 00 00 00       	mov    $0x0,%eax
  801994:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801997:	0f b6 11             	movzbl (%ecx),%edx
  80199a:	8d 72 d0             	lea    -0x30(%edx),%esi
  80199d:	89 f3                	mov    %esi,%ebx
  80199f:	80 fb 09             	cmp    $0x9,%bl
  8019a2:	77 08                	ja     8019ac <strtol+0x8b>
			dig = *s - '0';
  8019a4:	0f be d2             	movsbl %dl,%edx
  8019a7:	83 ea 30             	sub    $0x30,%edx
  8019aa:	eb 22                	jmp    8019ce <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019ac:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019af:	89 f3                	mov    %esi,%ebx
  8019b1:	80 fb 19             	cmp    $0x19,%bl
  8019b4:	77 08                	ja     8019be <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019b6:	0f be d2             	movsbl %dl,%edx
  8019b9:	83 ea 57             	sub    $0x57,%edx
  8019bc:	eb 10                	jmp    8019ce <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019be:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c1:	89 f3                	mov    %esi,%ebx
  8019c3:	80 fb 19             	cmp    $0x19,%bl
  8019c6:	77 16                	ja     8019de <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019c8:	0f be d2             	movsbl %dl,%edx
  8019cb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019ce:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d1:	7d 0b                	jge    8019de <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019d3:	83 c1 01             	add    $0x1,%ecx
  8019d6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019da:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019dc:	eb b9                	jmp    801997 <strtol+0x76>

	if (endptr)
  8019de:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e2:	74 0d                	je     8019f1 <strtol+0xd0>
		*endptr = (char *) s;
  8019e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e7:	89 0e                	mov    %ecx,(%esi)
  8019e9:	eb 06                	jmp    8019f1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019eb:	85 db                	test   %ebx,%ebx
  8019ed:	74 98                	je     801987 <strtol+0x66>
  8019ef:	eb 9e                	jmp    80198f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8019f1:	89 c2                	mov    %eax,%edx
  8019f3:	f7 da                	neg    %edx
  8019f5:	85 ff                	test   %edi,%edi
  8019f7:	0f 45 c2             	cmovne %edx,%eax
}
  8019fa:	5b                   	pop    %ebx
  8019fb:	5e                   	pop    %esi
  8019fc:	5f                   	pop    %edi
  8019fd:	5d                   	pop    %ebp
  8019fe:	c3                   	ret    

008019ff <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	56                   	push   %esi
  801a03:	53                   	push   %ebx
  801a04:	8b 75 08             	mov    0x8(%ebp),%esi
  801a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801a0d:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a0f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801a14:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	50                   	push   %eax
  801a1b:	e8 e6 e8 ff ff       	call   800306 <sys_ipc_recv>

	if (r < 0) {
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	85 c0                	test   %eax,%eax
  801a25:	79 16                	jns    801a3d <ipc_recv+0x3e>
		if (from_env_store)
  801a27:	85 f6                	test   %esi,%esi
  801a29:	74 06                	je     801a31 <ipc_recv+0x32>
			*from_env_store = 0;
  801a2b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801a31:	85 db                	test   %ebx,%ebx
  801a33:	74 2c                	je     801a61 <ipc_recv+0x62>
			*perm_store = 0;
  801a35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a3b:	eb 24                	jmp    801a61 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801a3d:	85 f6                	test   %esi,%esi
  801a3f:	74 0a                	je     801a4b <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801a41:	a1 04 40 80 00       	mov    0x804004,%eax
  801a46:	8b 40 74             	mov    0x74(%eax),%eax
  801a49:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801a4b:	85 db                	test   %ebx,%ebx
  801a4d:	74 0a                	je     801a59 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801a4f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a54:	8b 40 78             	mov    0x78(%eax),%eax
  801a57:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801a59:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5e:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801a61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5d                   	pop    %ebp
  801a67:	c3                   	ret    

00801a68 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a68:	55                   	push   %ebp
  801a69:	89 e5                	mov    %esp,%ebp
  801a6b:	57                   	push   %edi
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a74:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801a7a:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801a7c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801a81:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801a84:	ff 75 14             	pushl  0x14(%ebp)
  801a87:	53                   	push   %ebx
  801a88:	56                   	push   %esi
  801a89:	57                   	push   %edi
  801a8a:	e8 54 e8 ff ff       	call   8002e3 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a95:	75 07                	jne    801a9e <ipc_send+0x36>
			sys_yield();
  801a97:	e8 9b e6 ff ff       	call   800137 <sys_yield>
  801a9c:	eb e6                	jmp    801a84 <ipc_send+0x1c>
		} else if (r < 0) {
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	79 12                	jns    801ab4 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801aa2:	50                   	push   %eax
  801aa3:	68 20 22 80 00       	push   $0x802220
  801aa8:	6a 51                	push   $0x51
  801aaa:	68 2d 22 80 00       	push   $0x80222d
  801aaf:	e8 a6 f5 ff ff       	call   80105a <_panic>
		}
	}
}
  801ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5f                   	pop    %edi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ac7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad0:	8b 52 50             	mov    0x50(%edx),%edx
  801ad3:	39 ca                	cmp    %ecx,%edx
  801ad5:	75 0d                	jne    801ae4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ad7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ada:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801adf:	8b 40 48             	mov    0x48(%eax),%eax
  801ae2:	eb 0f                	jmp    801af3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae4:	83 c0 01             	add    $0x1,%eax
  801ae7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aec:	75 d9                	jne    801ac7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afb:	89 d0                	mov    %edx,%eax
  801afd:	c1 e8 16             	shr    $0x16,%eax
  801b00:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0c:	f6 c1 01             	test   $0x1,%cl
  801b0f:	74 1d                	je     801b2e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b11:	c1 ea 0c             	shr    $0xc,%edx
  801b14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1b:	f6 c2 01             	test   $0x1,%dl
  801b1e:	74 0e                	je     801b2e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b20:	c1 ea 0c             	shr    $0xc,%edx
  801b23:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2a:	ef 
  801b2b:	0f b7 c0             	movzwl %ax,%eax
}
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <__udivdi3>:
  801b30:	55                   	push   %ebp
  801b31:	57                   	push   %edi
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	83 ec 1c             	sub    $0x1c,%esp
  801b37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b47:	85 f6                	test   %esi,%esi
  801b49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b4d:	89 ca                	mov    %ecx,%edx
  801b4f:	89 f8                	mov    %edi,%eax
  801b51:	75 3d                	jne    801b90 <__udivdi3+0x60>
  801b53:	39 cf                	cmp    %ecx,%edi
  801b55:	0f 87 c5 00 00 00    	ja     801c20 <__udivdi3+0xf0>
  801b5b:	85 ff                	test   %edi,%edi
  801b5d:	89 fd                	mov    %edi,%ebp
  801b5f:	75 0b                	jne    801b6c <__udivdi3+0x3c>
  801b61:	b8 01 00 00 00       	mov    $0x1,%eax
  801b66:	31 d2                	xor    %edx,%edx
  801b68:	f7 f7                	div    %edi
  801b6a:	89 c5                	mov    %eax,%ebp
  801b6c:	89 c8                	mov    %ecx,%eax
  801b6e:	31 d2                	xor    %edx,%edx
  801b70:	f7 f5                	div    %ebp
  801b72:	89 c1                	mov    %eax,%ecx
  801b74:	89 d8                	mov    %ebx,%eax
  801b76:	89 cf                	mov    %ecx,%edi
  801b78:	f7 f5                	div    %ebp
  801b7a:	89 c3                	mov    %eax,%ebx
  801b7c:	89 d8                	mov    %ebx,%eax
  801b7e:	89 fa                	mov    %edi,%edx
  801b80:	83 c4 1c             	add    $0x1c,%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5f                   	pop    %edi
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    
  801b88:	90                   	nop
  801b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b90:	39 ce                	cmp    %ecx,%esi
  801b92:	77 74                	ja     801c08 <__udivdi3+0xd8>
  801b94:	0f bd fe             	bsr    %esi,%edi
  801b97:	83 f7 1f             	xor    $0x1f,%edi
  801b9a:	0f 84 98 00 00 00    	je     801c38 <__udivdi3+0x108>
  801ba0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ba5:	89 f9                	mov    %edi,%ecx
  801ba7:	89 c5                	mov    %eax,%ebp
  801ba9:	29 fb                	sub    %edi,%ebx
  801bab:	d3 e6                	shl    %cl,%esi
  801bad:	89 d9                	mov    %ebx,%ecx
  801baf:	d3 ed                	shr    %cl,%ebp
  801bb1:	89 f9                	mov    %edi,%ecx
  801bb3:	d3 e0                	shl    %cl,%eax
  801bb5:	09 ee                	or     %ebp,%esi
  801bb7:	89 d9                	mov    %ebx,%ecx
  801bb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bbd:	89 d5                	mov    %edx,%ebp
  801bbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bc3:	d3 ed                	shr    %cl,%ebp
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	d3 e2                	shl    %cl,%edx
  801bc9:	89 d9                	mov    %ebx,%ecx
  801bcb:	d3 e8                	shr    %cl,%eax
  801bcd:	09 c2                	or     %eax,%edx
  801bcf:	89 d0                	mov    %edx,%eax
  801bd1:	89 ea                	mov    %ebp,%edx
  801bd3:	f7 f6                	div    %esi
  801bd5:	89 d5                	mov    %edx,%ebp
  801bd7:	89 c3                	mov    %eax,%ebx
  801bd9:	f7 64 24 0c          	mull   0xc(%esp)
  801bdd:	39 d5                	cmp    %edx,%ebp
  801bdf:	72 10                	jb     801bf1 <__udivdi3+0xc1>
  801be1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	d3 e6                	shl    %cl,%esi
  801be9:	39 c6                	cmp    %eax,%esi
  801beb:	73 07                	jae    801bf4 <__udivdi3+0xc4>
  801bed:	39 d5                	cmp    %edx,%ebp
  801bef:	75 03                	jne    801bf4 <__udivdi3+0xc4>
  801bf1:	83 eb 01             	sub    $0x1,%ebx
  801bf4:	31 ff                	xor    %edi,%edi
  801bf6:	89 d8                	mov    %ebx,%eax
  801bf8:	89 fa                	mov    %edi,%edx
  801bfa:	83 c4 1c             	add    $0x1c,%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    
  801c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c08:	31 ff                	xor    %edi,%edi
  801c0a:	31 db                	xor    %ebx,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	89 d8                	mov    %ebx,%eax
  801c22:	f7 f7                	div    %edi
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 c3                	mov    %eax,%ebx
  801c28:	89 d8                	mov    %ebx,%eax
  801c2a:	89 fa                	mov    %edi,%edx
  801c2c:	83 c4 1c             	add    $0x1c,%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5f                   	pop    %edi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	39 ce                	cmp    %ecx,%esi
  801c3a:	72 0c                	jb     801c48 <__udivdi3+0x118>
  801c3c:	31 db                	xor    %ebx,%ebx
  801c3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c42:	0f 87 34 ff ff ff    	ja     801b7c <__udivdi3+0x4c>
  801c48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c4d:	e9 2a ff ff ff       	jmp    801b7c <__udivdi3+0x4c>
  801c52:	66 90                	xchg   %ax,%ax
  801c54:	66 90                	xchg   %ax,%ax
  801c56:	66 90                	xchg   %ax,%ax
  801c58:	66 90                	xchg   %ax,%ax
  801c5a:	66 90                	xchg   %ax,%ax
  801c5c:	66 90                	xchg   %ax,%ax
  801c5e:	66 90                	xchg   %ax,%ax

00801c60 <__umoddi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 1c             	sub    $0x1c,%esp
  801c67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c77:	85 d2                	test   %edx,%edx
  801c79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c81:	89 f3                	mov    %esi,%ebx
  801c83:	89 3c 24             	mov    %edi,(%esp)
  801c86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c8a:	75 1c                	jne    801ca8 <__umoddi3+0x48>
  801c8c:	39 f7                	cmp    %esi,%edi
  801c8e:	76 50                	jbe    801ce0 <__umoddi3+0x80>
  801c90:	89 c8                	mov    %ecx,%eax
  801c92:	89 f2                	mov    %esi,%edx
  801c94:	f7 f7                	div    %edi
  801c96:	89 d0                	mov    %edx,%eax
  801c98:	31 d2                	xor    %edx,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	89 d0                	mov    %edx,%eax
  801cac:	77 52                	ja     801d00 <__umoddi3+0xa0>
  801cae:	0f bd ea             	bsr    %edx,%ebp
  801cb1:	83 f5 1f             	xor    $0x1f,%ebp
  801cb4:	75 5a                	jne    801d10 <__umoddi3+0xb0>
  801cb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cba:	0f 82 e0 00 00 00    	jb     801da0 <__umoddi3+0x140>
  801cc0:	39 0c 24             	cmp    %ecx,(%esp)
  801cc3:	0f 86 d7 00 00 00    	jbe    801da0 <__umoddi3+0x140>
  801cc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ccd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cd1:	83 c4 1c             	add    $0x1c,%esp
  801cd4:	5b                   	pop    %ebx
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	85 ff                	test   %edi,%edi
  801ce2:	89 fd                	mov    %edi,%ebp
  801ce4:	75 0b                	jne    801cf1 <__umoddi3+0x91>
  801ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	f7 f7                	div    %edi
  801cef:	89 c5                	mov    %eax,%ebp
  801cf1:	89 f0                	mov    %esi,%eax
  801cf3:	31 d2                	xor    %edx,%edx
  801cf5:	f7 f5                	div    %ebp
  801cf7:	89 c8                	mov    %ecx,%eax
  801cf9:	f7 f5                	div    %ebp
  801cfb:	89 d0                	mov    %edx,%eax
  801cfd:	eb 99                	jmp    801c98 <__umoddi3+0x38>
  801cff:	90                   	nop
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	83 c4 1c             	add    $0x1c,%esp
  801d07:	5b                   	pop    %ebx
  801d08:	5e                   	pop    %esi
  801d09:	5f                   	pop    %edi
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    
  801d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d10:	8b 34 24             	mov    (%esp),%esi
  801d13:	bf 20 00 00 00       	mov    $0x20,%edi
  801d18:	89 e9                	mov    %ebp,%ecx
  801d1a:	29 ef                	sub    %ebp,%edi
  801d1c:	d3 e0                	shl    %cl,%eax
  801d1e:	89 f9                	mov    %edi,%ecx
  801d20:	89 f2                	mov    %esi,%edx
  801d22:	d3 ea                	shr    %cl,%edx
  801d24:	89 e9                	mov    %ebp,%ecx
  801d26:	09 c2                	or     %eax,%edx
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	89 14 24             	mov    %edx,(%esp)
  801d2d:	89 f2                	mov    %esi,%edx
  801d2f:	d3 e2                	shl    %cl,%edx
  801d31:	89 f9                	mov    %edi,%ecx
  801d33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	89 e9                	mov    %ebp,%ecx
  801d3f:	89 c6                	mov    %eax,%esi
  801d41:	d3 e3                	shl    %cl,%ebx
  801d43:	89 f9                	mov    %edi,%ecx
  801d45:	89 d0                	mov    %edx,%eax
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	09 d8                	or     %ebx,%eax
  801d4d:	89 d3                	mov    %edx,%ebx
  801d4f:	89 f2                	mov    %esi,%edx
  801d51:	f7 34 24             	divl   (%esp)
  801d54:	89 d6                	mov    %edx,%esi
  801d56:	d3 e3                	shl    %cl,%ebx
  801d58:	f7 64 24 04          	mull   0x4(%esp)
  801d5c:	39 d6                	cmp    %edx,%esi
  801d5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d62:	89 d1                	mov    %edx,%ecx
  801d64:	89 c3                	mov    %eax,%ebx
  801d66:	72 08                	jb     801d70 <__umoddi3+0x110>
  801d68:	75 11                	jne    801d7b <__umoddi3+0x11b>
  801d6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d6e:	73 0b                	jae    801d7b <__umoddi3+0x11b>
  801d70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d74:	1b 14 24             	sbb    (%esp),%edx
  801d77:	89 d1                	mov    %edx,%ecx
  801d79:	89 c3                	mov    %eax,%ebx
  801d7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d7f:	29 da                	sub    %ebx,%edx
  801d81:	19 ce                	sbb    %ecx,%esi
  801d83:	89 f9                	mov    %edi,%ecx
  801d85:	89 f0                	mov    %esi,%eax
  801d87:	d3 e0                	shl    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	d3 ea                	shr    %cl,%edx
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	d3 ee                	shr    %cl,%esi
  801d91:	09 d0                	or     %edx,%eax
  801d93:	89 f2                	mov    %esi,%edx
  801d95:	83 c4 1c             	add    $0x1c,%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5e                   	pop    %esi
  801d9a:	5f                   	pop    %edi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    
  801d9d:	8d 76 00             	lea    0x0(%esi),%esi
  801da0:	29 f9                	sub    %edi,%ecx
  801da2:	19 d6                	sbb    %edx,%esi
  801da4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801da8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dac:	e9 18 ff ff ff       	jmp    801cc9 <__umoddi3+0x69>
