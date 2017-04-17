
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 a6 04 00 00       	call   80055c <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 8a 22 80 00       	push   $0x80228a
  80012f:	6a 23                	push   $0x23
  800131:	68 a7 22 80 00       	push   $0x8022a7
  800136:	e8 d0 13 00 00       	call   80150b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 8a 22 80 00       	push   $0x80228a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 a7 22 80 00       	push   $0x8022a7
  8001b7:	e8 4f 13 00 00       	call   80150b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 8a 22 80 00       	push   $0x80228a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 a7 22 80 00       	push   $0x8022a7
  8001f9:	e8 0d 13 00 00       	call   80150b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 8a 22 80 00       	push   $0x80228a
  800234:	6a 23                	push   $0x23
  800236:	68 a7 22 80 00       	push   $0x8022a7
  80023b:	e8 cb 12 00 00       	call   80150b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 8a 22 80 00       	push   $0x80228a
  800276:	6a 23                	push   $0x23
  800278:	68 a7 22 80 00       	push   $0x8022a7
  80027d:	e8 89 12 00 00       	call   80150b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 8a 22 80 00       	push   $0x80228a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 a7 22 80 00       	push   $0x8022a7
  8002bf:	e8 47 12 00 00       	call   80150b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 8a 22 80 00       	push   $0x80228a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 a7 22 80 00       	push   $0x8022a7
  800301:	e8 05 12 00 00       	call   80150b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 8a 22 80 00       	push   $0x80228a
  80035e:	6a 23                	push   $0x23
  800360:	68 a7 22 80 00       	push   $0x8022a7
  800365:	e8 a1 11 00 00       	call   80150b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800382:	89 d1                	mov    %edx,%ecx
  800384:	89 d3                	mov    %edx,%ebx
  800386:	89 d7                	mov    %edx,%edi
  800388:	89 d6                	mov    %edx,%esi
  80038a:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
  800397:	05 00 00 00 30       	add    $0x30000000,%eax
  80039c:	c1 e8 0c             	shr    $0xc,%eax
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c3:	89 c2                	mov    %eax,%edx
  8003c5:	c1 ea 16             	shr    $0x16,%edx
  8003c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003cf:	f6 c2 01             	test   $0x1,%dl
  8003d2:	74 11                	je     8003e5 <fd_alloc+0x2d>
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 0c             	shr    $0xc,%edx
  8003d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	75 09                	jne    8003ee <fd_alloc+0x36>
			*fd_store = fd;
  8003e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ec:	eb 17                	jmp    800405 <fd_alloc+0x4d>
  8003ee:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f8:	75 c9                	jne    8003c3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800400:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040d:	83 f8 1f             	cmp    $0x1f,%eax
  800410:	77 36                	ja     800448 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800412:	c1 e0 0c             	shl    $0xc,%eax
  800415:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80041a:	89 c2                	mov    %eax,%edx
  80041c:	c1 ea 16             	shr    $0x16,%edx
  80041f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800426:	f6 c2 01             	test   $0x1,%dl
  800429:	74 24                	je     80044f <fd_lookup+0x48>
  80042b:	89 c2                	mov    %eax,%edx
  80042d:	c1 ea 0c             	shr    $0xc,%edx
  800430:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800437:	f6 c2 01             	test   $0x1,%dl
  80043a:	74 1a                	je     800456 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80043c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043f:	89 02                	mov    %eax,(%edx)
	return 0;
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	eb 13                	jmp    80045b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800448:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044d:	eb 0c                	jmp    80045b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800454:	eb 05                	jmp    80045b <fd_lookup+0x54>
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800466:	ba 34 23 80 00       	mov    $0x802334,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80046b:	eb 13                	jmp    800480 <dev_lookup+0x23>
  80046d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800470:	39 08                	cmp    %ecx,(%eax)
  800472:	75 0c                	jne    800480 <dev_lookup+0x23>
			*dev = devtab[i];
  800474:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800477:	89 01                	mov    %eax,(%ecx)
			return 0;
  800479:	b8 00 00 00 00       	mov    $0x0,%eax
  80047e:	eb 2e                	jmp    8004ae <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800480:	8b 02                	mov    (%edx),%eax
  800482:	85 c0                	test   %eax,%eax
  800484:	75 e7                	jne    80046d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800486:	a1 08 40 80 00       	mov    0x804008,%eax
  80048b:	8b 40 48             	mov    0x48(%eax),%eax
  80048e:	83 ec 04             	sub    $0x4,%esp
  800491:	51                   	push   %ecx
  800492:	50                   	push   %eax
  800493:	68 b8 22 80 00       	push   $0x8022b8
  800498:	e8 47 11 00 00       	call   8015e4 <cprintf>
	*dev = 0;
  80049d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	56                   	push   %esi
  8004b4:	53                   	push   %ebx
  8004b5:	83 ec 10             	sub    $0x10,%esp
  8004b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c1:	50                   	push   %eax
  8004c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c8:	c1 e8 0c             	shr    $0xc,%eax
  8004cb:	50                   	push   %eax
  8004cc:	e8 36 ff ff ff       	call   800407 <fd_lookup>
  8004d1:	83 c4 08             	add    $0x8,%esp
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	78 05                	js     8004dd <fd_close+0x2d>
	    || fd != fd2)
  8004d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004db:	74 0c                	je     8004e9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004dd:	84 db                	test   %bl,%bl
  8004df:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e4:	0f 44 c2             	cmove  %edx,%eax
  8004e7:	eb 41                	jmp    80052a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ef:	50                   	push   %eax
  8004f0:	ff 36                	pushl  (%esi)
  8004f2:	e8 66 ff ff ff       	call   80045d <dev_lookup>
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 1a                	js     80051a <fd_close+0x6a>
		if (dev->dev_close)
  800500:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800503:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800506:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80050b:	85 c0                	test   %eax,%eax
  80050d:	74 0b                	je     80051a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80050f:	83 ec 0c             	sub    $0xc,%esp
  800512:	56                   	push   %esi
  800513:	ff d0                	call   *%eax
  800515:	89 c3                	mov    %eax,%ebx
  800517:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	56                   	push   %esi
  80051e:	6a 00                	push   $0x0
  800520:	e8 e1 fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	89 d8                	mov    %ebx,%eax
}
  80052a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052d:	5b                   	pop    %ebx
  80052e:	5e                   	pop    %esi
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800537:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053a:	50                   	push   %eax
  80053b:	ff 75 08             	pushl  0x8(%ebp)
  80053e:	e8 c4 fe ff ff       	call   800407 <fd_lookup>
  800543:	83 c4 08             	add    $0x8,%esp
  800546:	85 c0                	test   %eax,%eax
  800548:	78 10                	js     80055a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	6a 01                	push   $0x1
  80054f:	ff 75 f4             	pushl  -0xc(%ebp)
  800552:	e8 59 ff ff ff       	call   8004b0 <fd_close>
  800557:	83 c4 10             	add    $0x10,%esp
}
  80055a:	c9                   	leave  
  80055b:	c3                   	ret    

0080055c <close_all>:

void
close_all(void)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	53                   	push   %ebx
  800560:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800563:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800568:	83 ec 0c             	sub    $0xc,%esp
  80056b:	53                   	push   %ebx
  80056c:	e8 c0 ff ff ff       	call   800531 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800571:	83 c3 01             	add    $0x1,%ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	83 fb 20             	cmp    $0x20,%ebx
  80057a:	75 ec                	jne    800568 <close_all+0xc>
		close(i);
}
  80057c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057f:	c9                   	leave  
  800580:	c3                   	ret    

00800581 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	57                   	push   %edi
  800585:	56                   	push   %esi
  800586:	53                   	push   %ebx
  800587:	83 ec 2c             	sub    $0x2c,%esp
  80058a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800590:	50                   	push   %eax
  800591:	ff 75 08             	pushl  0x8(%ebp)
  800594:	e8 6e fe ff ff       	call   800407 <fd_lookup>
  800599:	83 c4 08             	add    $0x8,%esp
  80059c:	85 c0                	test   %eax,%eax
  80059e:	0f 88 c1 00 00 00    	js     800665 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	56                   	push   %esi
  8005a8:	e8 84 ff ff ff       	call   800531 <close>

	newfd = INDEX2FD(newfdnum);
  8005ad:	89 f3                	mov    %esi,%ebx
  8005af:	c1 e3 0c             	shl    $0xc,%ebx
  8005b2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b8:	83 c4 04             	add    $0x4,%esp
  8005bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005be:	e8 de fd ff ff       	call   8003a1 <fd2data>
  8005c3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c5:	89 1c 24             	mov    %ebx,(%esp)
  8005c8:	e8 d4 fd ff ff       	call   8003a1 <fd2data>
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d3:	89 f8                	mov    %edi,%eax
  8005d5:	c1 e8 16             	shr    $0x16,%eax
  8005d8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005df:	a8 01                	test   $0x1,%al
  8005e1:	74 37                	je     80061a <dup+0x99>
  8005e3:	89 f8                	mov    %edi,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ef:	f6 c2 01             	test   $0x1,%dl
  8005f2:	74 26                	je     80061a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fb:	83 ec 0c             	sub    $0xc,%esp
  8005fe:	25 07 0e 00 00       	and    $0xe07,%eax
  800603:	50                   	push   %eax
  800604:	ff 75 d4             	pushl  -0x2c(%ebp)
  800607:	6a 00                	push   $0x0
  800609:	57                   	push   %edi
  80060a:	6a 00                	push   $0x0
  80060c:	e8 b3 fb ff ff       	call   8001c4 <sys_page_map>
  800611:	89 c7                	mov    %eax,%edi
  800613:	83 c4 20             	add    $0x20,%esp
  800616:	85 c0                	test   %eax,%eax
  800618:	78 2e                	js     800648 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061d:	89 d0                	mov    %edx,%eax
  80061f:	c1 e8 0c             	shr    $0xc,%eax
  800622:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800629:	83 ec 0c             	sub    $0xc,%esp
  80062c:	25 07 0e 00 00       	and    $0xe07,%eax
  800631:	50                   	push   %eax
  800632:	53                   	push   %ebx
  800633:	6a 00                	push   $0x0
  800635:	52                   	push   %edx
  800636:	6a 00                	push   $0x0
  800638:	e8 87 fb ff ff       	call   8001c4 <sys_page_map>
  80063d:	89 c7                	mov    %eax,%edi
  80063f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800642:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800644:	85 ff                	test   %edi,%edi
  800646:	79 1d                	jns    800665 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 00                	push   $0x0
  80064e:	e8 b3 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800653:	83 c4 08             	add    $0x8,%esp
  800656:	ff 75 d4             	pushl  -0x2c(%ebp)
  800659:	6a 00                	push   $0x0
  80065b:	e8 a6 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	89 f8                	mov    %edi,%eax
}
  800665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800668:	5b                   	pop    %ebx
  800669:	5e                   	pop    %esi
  80066a:	5f                   	pop    %edi
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	53                   	push   %ebx
  800671:	83 ec 14             	sub    $0x14,%esp
  800674:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800677:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	53                   	push   %ebx
  80067c:	e8 86 fd ff ff       	call   800407 <fd_lookup>
  800681:	83 c4 08             	add    $0x8,%esp
  800684:	89 c2                	mov    %eax,%edx
  800686:	85 c0                	test   %eax,%eax
  800688:	78 6d                	js     8006f7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800690:	50                   	push   %eax
  800691:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800694:	ff 30                	pushl  (%eax)
  800696:	e8 c2 fd ff ff       	call   80045d <dev_lookup>
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	78 4c                	js     8006ee <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a5:	8b 42 08             	mov    0x8(%edx),%eax
  8006a8:	83 e0 03             	and    $0x3,%eax
  8006ab:	83 f8 01             	cmp    $0x1,%eax
  8006ae:	75 21                	jne    8006d1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8006b5:	8b 40 48             	mov    0x48(%eax),%eax
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	53                   	push   %ebx
  8006bc:	50                   	push   %eax
  8006bd:	68 f9 22 80 00       	push   $0x8022f9
  8006c2:	e8 1d 0f 00 00       	call   8015e4 <cprintf>
		return -E_INVAL;
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006cf:	eb 26                	jmp    8006f7 <read+0x8a>
	}
	if (!dev->dev_read)
  8006d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d4:	8b 40 08             	mov    0x8(%eax),%eax
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	74 17                	je     8006f2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006db:	83 ec 04             	sub    $0x4,%esp
  8006de:	ff 75 10             	pushl  0x10(%ebp)
  8006e1:	ff 75 0c             	pushl  0xc(%ebp)
  8006e4:	52                   	push   %edx
  8006e5:	ff d0                	call   *%eax
  8006e7:	89 c2                	mov    %eax,%edx
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	eb 09                	jmp    8006f7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ee:	89 c2                	mov    %eax,%edx
  8006f0:	eb 05                	jmp    8006f7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006f7:	89 d0                	mov    %edx,%eax
  8006f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fc:	c9                   	leave  
  8006fd:	c3                   	ret    

008006fe <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	57                   	push   %edi
  800702:	56                   	push   %esi
  800703:	53                   	push   %ebx
  800704:	83 ec 0c             	sub    $0xc,%esp
  800707:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800712:	eb 21                	jmp    800735 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800714:	83 ec 04             	sub    $0x4,%esp
  800717:	89 f0                	mov    %esi,%eax
  800719:	29 d8                	sub    %ebx,%eax
  80071b:	50                   	push   %eax
  80071c:	89 d8                	mov    %ebx,%eax
  80071e:	03 45 0c             	add    0xc(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	57                   	push   %edi
  800723:	e8 45 ff ff ff       	call   80066d <read>
		if (m < 0)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 10                	js     80073f <readn+0x41>
			return m;
		if (m == 0)
  80072f:	85 c0                	test   %eax,%eax
  800731:	74 0a                	je     80073d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800733:	01 c3                	add    %eax,%ebx
  800735:	39 f3                	cmp    %esi,%ebx
  800737:	72 db                	jb     800714 <readn+0x16>
  800739:	89 d8                	mov    %ebx,%eax
  80073b:	eb 02                	jmp    80073f <readn+0x41>
  80073d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5f                   	pop    %edi
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	53                   	push   %ebx
  80074b:	83 ec 14             	sub    $0x14,%esp
  80074e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800751:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800754:	50                   	push   %eax
  800755:	53                   	push   %ebx
  800756:	e8 ac fc ff ff       	call   800407 <fd_lookup>
  80075b:	83 c4 08             	add    $0x8,%esp
  80075e:	89 c2                	mov    %eax,%edx
  800760:	85 c0                	test   %eax,%eax
  800762:	78 68                	js     8007cc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076e:	ff 30                	pushl  (%eax)
  800770:	e8 e8 fc ff ff       	call   80045d <dev_lookup>
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	85 c0                	test   %eax,%eax
  80077a:	78 47                	js     8007c3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800783:	75 21                	jne    8007a6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800785:	a1 08 40 80 00       	mov    0x804008,%eax
  80078a:	8b 40 48             	mov    0x48(%eax),%eax
  80078d:	83 ec 04             	sub    $0x4,%esp
  800790:	53                   	push   %ebx
  800791:	50                   	push   %eax
  800792:	68 15 23 80 00       	push   $0x802315
  800797:	e8 48 0e 00 00       	call   8015e4 <cprintf>
		return -E_INVAL;
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a4:	eb 26                	jmp    8007cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 17                	je     8007c7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b0:	83 ec 04             	sub    $0x4,%esp
  8007b3:	ff 75 10             	pushl  0x10(%ebp)
  8007b6:	ff 75 0c             	pushl  0xc(%ebp)
  8007b9:	50                   	push   %eax
  8007ba:	ff d2                	call   *%edx
  8007bc:	89 c2                	mov    %eax,%edx
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	eb 09                	jmp    8007cc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	eb 05                	jmp    8007cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007cc:	89 d0                	mov    %edx,%eax
  8007ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	ff 75 08             	pushl  0x8(%ebp)
  8007e0:	e8 22 fc ff ff       	call   800407 <fd_lookup>
  8007e5:	83 c4 08             	add    $0x8,%esp
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	78 0e                	js     8007fa <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	83 ec 14             	sub    $0x14,%esp
  800803:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800806:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800809:	50                   	push   %eax
  80080a:	53                   	push   %ebx
  80080b:	e8 f7 fb ff ff       	call   800407 <fd_lookup>
  800810:	83 c4 08             	add    $0x8,%esp
  800813:	89 c2                	mov    %eax,%edx
  800815:	85 c0                	test   %eax,%eax
  800817:	78 65                	js     80087e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800823:	ff 30                	pushl  (%eax)
  800825:	e8 33 fc ff ff       	call   80045d <dev_lookup>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	85 c0                	test   %eax,%eax
  80082f:	78 44                	js     800875 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800831:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800834:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800838:	75 21                	jne    80085b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083f:	8b 40 48             	mov    0x48(%eax),%eax
  800842:	83 ec 04             	sub    $0x4,%esp
  800845:	53                   	push   %ebx
  800846:	50                   	push   %eax
  800847:	68 d8 22 80 00       	push   $0x8022d8
  80084c:	e8 93 0d 00 00       	call   8015e4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800859:	eb 23                	jmp    80087e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80085b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085e:	8b 52 18             	mov    0x18(%edx),%edx
  800861:	85 d2                	test   %edx,%edx
  800863:	74 14                	je     800879 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	ff 75 0c             	pushl  0xc(%ebp)
  80086b:	50                   	push   %eax
  80086c:	ff d2                	call   *%edx
  80086e:	89 c2                	mov    %eax,%edx
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	eb 09                	jmp    80087e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800875:	89 c2                	mov    %eax,%edx
  800877:	eb 05                	jmp    80087e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800879:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80087e:	89 d0                	mov    %edx,%eax
  800880:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800883:	c9                   	leave  
  800884:	c3                   	ret    

00800885 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	83 ec 14             	sub    $0x14,%esp
  80088c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800892:	50                   	push   %eax
  800893:	ff 75 08             	pushl  0x8(%ebp)
  800896:	e8 6c fb ff ff       	call   800407 <fd_lookup>
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	78 58                	js     8008fc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ae:	ff 30                	pushl  (%eax)
  8008b0:	e8 a8 fb ff ff       	call   80045d <dev_lookup>
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	78 37                	js     8008f3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c3:	74 32                	je     8008f7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008cf:	00 00 00 
	stat->st_isdir = 0;
  8008d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d9:	00 00 00 
	stat->st_dev = dev;
  8008dc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e2:	83 ec 08             	sub    $0x8,%esp
  8008e5:	53                   	push   %ebx
  8008e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e9:	ff 50 14             	call   *0x14(%eax)
  8008ec:	89 c2                	mov    %eax,%edx
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	eb 09                	jmp    8008fc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f3:	89 c2                	mov    %eax,%edx
  8008f5:	eb 05                	jmp    8008fc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	6a 00                	push   $0x0
  80090d:	ff 75 08             	pushl  0x8(%ebp)
  800910:	e8 0c 02 00 00       	call   800b21 <open>
  800915:	89 c3                	mov    %eax,%ebx
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 1b                	js     800939 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	ff 75 0c             	pushl  0xc(%ebp)
  800924:	50                   	push   %eax
  800925:	e8 5b ff ff ff       	call   800885 <fstat>
  80092a:	89 c6                	mov    %eax,%esi
	close(fd);
  80092c:	89 1c 24             	mov    %ebx,(%esp)
  80092f:	e8 fd fb ff ff       	call   800531 <close>
	return r;
  800934:	83 c4 10             	add    $0x10,%esp
  800937:	89 f0                	mov    %esi,%eax
}
  800939:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093c:	5b                   	pop    %ebx
  80093d:	5e                   	pop    %esi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	89 c6                	mov    %eax,%esi
  800947:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800949:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800950:	75 12                	jne    800964 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800952:	83 ec 0c             	sub    $0xc,%esp
  800955:	6a 01                	push   $0x1
  800957:	e8 11 16 00 00       	call   801f6d <ipc_find_env>
  80095c:	a3 00 40 80 00       	mov    %eax,0x804000
  800961:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800964:	6a 07                	push   $0x7
  800966:	68 00 50 80 00       	push   $0x805000
  80096b:	56                   	push   %esi
  80096c:	ff 35 00 40 80 00    	pushl  0x804000
  800972:	e8 a2 15 00 00       	call   801f19 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800977:	83 c4 0c             	add    $0xc,%esp
  80097a:	6a 00                	push   $0x0
  80097c:	53                   	push   %ebx
  80097d:	6a 00                	push   $0x0
  80097f:	e8 2c 15 00 00       	call   801eb0 <ipc_recv>
}
  800984:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 40 0c             	mov    0xc(%eax),%eax
  800997:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a9:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ae:	e8 8d ff ff ff       	call   800940 <fsipc>
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cb:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d0:	e8 6b ff ff ff       	call   800940 <fsipc>
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	83 ec 04             	sub    $0x4,%esp
  8009de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f6:	e8 45 ff ff ff       	call   800940 <fsipc>
  8009fb:	85 c0                	test   %eax,%eax
  8009fd:	78 2c                	js     800a2b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ff:	83 ec 08             	sub    $0x8,%esp
  800a02:	68 00 50 80 00       	push   $0x805000
  800a07:	53                   	push   %ebx
  800a08:	e8 5c 11 00 00       	call   801b69 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0d:	a1 80 50 80 00       	mov    0x805080,%eax
  800a12:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a18:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a23:	83 c4 10             	add    $0x10,%esp
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	83 ec 08             	sub    $0x8,%esp
  800a37:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	8b 52 0c             	mov    0xc(%edx),%edx
  800a40:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a46:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a4b:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a50:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a53:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a59:	53                   	push   %ebx
  800a5a:	ff 75 0c             	pushl  0xc(%ebp)
  800a5d:	68 08 50 80 00       	push   $0x805008
  800a62:	e8 94 12 00 00       	call   801cfb <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  800a67:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a71:	e8 ca fe ff ff       	call   800940 <fsipc>
  800a76:	83 c4 10             	add    $0x10,%esp
  800a79:	85 c0                	test   %eax,%eax
  800a7b:	78 1d                	js     800a9a <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  800a7d:	39 d8                	cmp    %ebx,%eax
  800a7f:	76 19                	jbe    800a9a <devfile_write+0x6a>
  800a81:	68 48 23 80 00       	push   $0x802348
  800a86:	68 54 23 80 00       	push   $0x802354
  800a8b:	68 a3 00 00 00       	push   $0xa3
  800a90:	68 69 23 80 00       	push   $0x802369
  800a95:	e8 71 0a 00 00       	call   80150b <_panic>
	return r;
}
  800a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 40 0c             	mov    0xc(%eax),%eax
  800aad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ab2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac2:	e8 79 fe ff ff       	call   800940 <fsipc>
  800ac7:	89 c3                	mov    %eax,%ebx
  800ac9:	85 c0                	test   %eax,%eax
  800acb:	78 4b                	js     800b18 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800acd:	39 c6                	cmp    %eax,%esi
  800acf:	73 16                	jae    800ae7 <devfile_read+0x48>
  800ad1:	68 74 23 80 00       	push   $0x802374
  800ad6:	68 54 23 80 00       	push   $0x802354
  800adb:	6a 7c                	push   $0x7c
  800add:	68 69 23 80 00       	push   $0x802369
  800ae2:	e8 24 0a 00 00       	call   80150b <_panic>
	assert(r <= PGSIZE);
  800ae7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aec:	7e 16                	jle    800b04 <devfile_read+0x65>
  800aee:	68 7b 23 80 00       	push   $0x80237b
  800af3:	68 54 23 80 00       	push   $0x802354
  800af8:	6a 7d                	push   $0x7d
  800afa:	68 69 23 80 00       	push   $0x802369
  800aff:	e8 07 0a 00 00       	call   80150b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b04:	83 ec 04             	sub    $0x4,%esp
  800b07:	50                   	push   %eax
  800b08:	68 00 50 80 00       	push   $0x805000
  800b0d:	ff 75 0c             	pushl  0xc(%ebp)
  800b10:	e8 e6 11 00 00       	call   801cfb <memmove>
	return r;
  800b15:	83 c4 10             	add    $0x10,%esp
}
  800b18:	89 d8                	mov    %ebx,%eax
  800b1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	53                   	push   %ebx
  800b25:	83 ec 20             	sub    $0x20,%esp
  800b28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b2b:	53                   	push   %ebx
  800b2c:	e8 ff 0f 00 00       	call   801b30 <strlen>
  800b31:	83 c4 10             	add    $0x10,%esp
  800b34:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b39:	7f 67                	jg     800ba2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b41:	50                   	push   %eax
  800b42:	e8 71 f8 ff ff       	call   8003b8 <fd_alloc>
  800b47:	83 c4 10             	add    $0x10,%esp
		return r;
  800b4a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	78 57                	js     800ba7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b50:	83 ec 08             	sub    $0x8,%esp
  800b53:	53                   	push   %ebx
  800b54:	68 00 50 80 00       	push   $0x805000
  800b59:	e8 0b 10 00 00       	call   801b69 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b61:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b69:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6e:	e8 cd fd ff ff       	call   800940 <fsipc>
  800b73:	89 c3                	mov    %eax,%ebx
  800b75:	83 c4 10             	add    $0x10,%esp
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	79 14                	jns    800b90 <open+0x6f>
		fd_close(fd, 0);
  800b7c:	83 ec 08             	sub    $0x8,%esp
  800b7f:	6a 00                	push   $0x0
  800b81:	ff 75 f4             	pushl  -0xc(%ebp)
  800b84:	e8 27 f9 ff ff       	call   8004b0 <fd_close>
		return r;
  800b89:	83 c4 10             	add    $0x10,%esp
  800b8c:	89 da                	mov    %ebx,%edx
  800b8e:	eb 17                	jmp    800ba7 <open+0x86>
	}

	return fd2num(fd);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	ff 75 f4             	pushl  -0xc(%ebp)
  800b96:	e8 f6 f7 ff ff       	call   800391 <fd2num>
  800b9b:	89 c2                	mov    %eax,%edx
  800b9d:	83 c4 10             	add    $0x10,%esp
  800ba0:	eb 05                	jmp    800ba7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ba2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ba7:	89 d0                	mov    %edx,%eax
  800ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbe:	e8 7d fd ff ff       	call   800940 <fsipc>
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bcb:	68 87 23 80 00       	push   $0x802387
  800bd0:	ff 75 0c             	pushl  0xc(%ebp)
  800bd3:	e8 91 0f 00 00       	call   801b69 <strcpy>
	return 0;
}
  800bd8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	53                   	push   %ebx
  800be3:	83 ec 10             	sub    $0x10,%esp
  800be6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800be9:	53                   	push   %ebx
  800bea:	e8 b7 13 00 00       	call   801fa6 <pageref>
  800bef:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bf7:	83 f8 01             	cmp    $0x1,%eax
  800bfa:	75 10                	jne    800c0c <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	ff 73 0c             	pushl  0xc(%ebx)
  800c02:	e8 c0 02 00 00       	call   800ec7 <nsipc_close>
  800c07:	89 c2                	mov    %eax,%edx
  800c09:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c0c:	89 d0                	mov    %edx,%eax
  800c0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c19:	6a 00                	push   $0x0
  800c1b:	ff 75 10             	pushl  0x10(%ebp)
  800c1e:	ff 75 0c             	pushl  0xc(%ebp)
  800c21:	8b 45 08             	mov    0x8(%ebp),%eax
  800c24:	ff 70 0c             	pushl  0xc(%eax)
  800c27:	e8 78 03 00 00       	call   800fa4 <nsipc_send>
}
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c34:	6a 00                	push   $0x0
  800c36:	ff 75 10             	pushl  0x10(%ebp)
  800c39:	ff 75 0c             	pushl  0xc(%ebp)
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	ff 70 0c             	pushl  0xc(%eax)
  800c42:	e8 f1 02 00 00       	call   800f38 <nsipc_recv>
}
  800c47:	c9                   	leave  
  800c48:	c3                   	ret    

00800c49 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c4f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c52:	52                   	push   %edx
  800c53:	50                   	push   %eax
  800c54:	e8 ae f7 ff ff       	call   800407 <fd_lookup>
  800c59:	83 c4 10             	add    $0x10,%esp
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	78 17                	js     800c77 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c63:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c69:	39 08                	cmp    %ecx,(%eax)
  800c6b:	75 05                	jne    800c72 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800c70:	eb 05                	jmp    800c77 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c72:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c77:	c9                   	leave  
  800c78:	c3                   	ret    

00800c79 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
  800c7e:	83 ec 1c             	sub    $0x1c,%esp
  800c81:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c86:	50                   	push   %eax
  800c87:	e8 2c f7 ff ff       	call   8003b8 <fd_alloc>
  800c8c:	89 c3                	mov    %eax,%ebx
  800c8e:	83 c4 10             	add    $0x10,%esp
  800c91:	85 c0                	test   %eax,%eax
  800c93:	78 1b                	js     800cb0 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c95:	83 ec 04             	sub    $0x4,%esp
  800c98:	68 07 04 00 00       	push   $0x407
  800c9d:	ff 75 f4             	pushl  -0xc(%ebp)
  800ca0:	6a 00                	push   $0x0
  800ca2:	e8 da f4 ff ff       	call   800181 <sys_page_alloc>
  800ca7:	89 c3                	mov    %eax,%ebx
  800ca9:	83 c4 10             	add    $0x10,%esp
  800cac:	85 c0                	test   %eax,%eax
  800cae:	79 10                	jns    800cc0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	56                   	push   %esi
  800cb4:	e8 0e 02 00 00       	call   800ec7 <nsipc_close>
		return r;
  800cb9:	83 c4 10             	add    $0x10,%esp
  800cbc:	89 d8                	mov    %ebx,%eax
  800cbe:	eb 24                	jmp    800ce4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cc0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cd5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	e8 b0 f6 ff ff       	call   800391 <fd2num>
  800ce1:	83 c4 10             	add    $0x10,%esp
}
  800ce4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	e8 50 ff ff ff       	call   800c49 <fd2sockid>
		return r;
  800cf9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	78 1f                	js     800d1e <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cff:	83 ec 04             	sub    $0x4,%esp
  800d02:	ff 75 10             	pushl  0x10(%ebp)
  800d05:	ff 75 0c             	pushl  0xc(%ebp)
  800d08:	50                   	push   %eax
  800d09:	e8 12 01 00 00       	call   800e20 <nsipc_accept>
  800d0e:	83 c4 10             	add    $0x10,%esp
		return r;
  800d11:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	78 07                	js     800d1e <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d17:	e8 5d ff ff ff       	call   800c79 <alloc_sockfd>
  800d1c:	89 c1                	mov    %eax,%ecx
}
  800d1e:	89 c8                	mov    %ecx,%eax
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    

00800d22 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d28:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2b:	e8 19 ff ff ff       	call   800c49 <fd2sockid>
  800d30:	85 c0                	test   %eax,%eax
  800d32:	78 12                	js     800d46 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d34:	83 ec 04             	sub    $0x4,%esp
  800d37:	ff 75 10             	pushl  0x10(%ebp)
  800d3a:	ff 75 0c             	pushl  0xc(%ebp)
  800d3d:	50                   	push   %eax
  800d3e:	e8 2d 01 00 00       	call   800e70 <nsipc_bind>
  800d43:	83 c4 10             	add    $0x10,%esp
}
  800d46:	c9                   	leave  
  800d47:	c3                   	ret    

00800d48 <shutdown>:

int
shutdown(int s, int how)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	e8 f3 fe ff ff       	call   800c49 <fd2sockid>
  800d56:	85 c0                	test   %eax,%eax
  800d58:	78 0f                	js     800d69 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d5a:	83 ec 08             	sub    $0x8,%esp
  800d5d:	ff 75 0c             	pushl  0xc(%ebp)
  800d60:	50                   	push   %eax
  800d61:	e8 3f 01 00 00       	call   800ea5 <nsipc_shutdown>
  800d66:	83 c4 10             	add    $0x10,%esp
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	e8 d0 fe ff ff       	call   800c49 <fd2sockid>
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	78 12                	js     800d8f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d7d:	83 ec 04             	sub    $0x4,%esp
  800d80:	ff 75 10             	pushl  0x10(%ebp)
  800d83:	ff 75 0c             	pushl  0xc(%ebp)
  800d86:	50                   	push   %eax
  800d87:	e8 55 01 00 00       	call   800ee1 <nsipc_connect>
  800d8c:	83 c4 10             	add    $0x10,%esp
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <listen>:

int
listen(int s, int backlog)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	e8 aa fe ff ff       	call   800c49 <fd2sockid>
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	78 0f                	js     800db2 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800da3:	83 ec 08             	sub    $0x8,%esp
  800da6:	ff 75 0c             	pushl  0xc(%ebp)
  800da9:	50                   	push   %eax
  800daa:	e8 67 01 00 00       	call   800f16 <nsipc_listen>
  800daf:	83 c4 10             	add    $0x10,%esp
}
  800db2:	c9                   	leave  
  800db3:	c3                   	ret    

00800db4 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dba:	ff 75 10             	pushl  0x10(%ebp)
  800dbd:	ff 75 0c             	pushl  0xc(%ebp)
  800dc0:	ff 75 08             	pushl  0x8(%ebp)
  800dc3:	e8 3a 02 00 00       	call   801002 <nsipc_socket>
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	78 05                	js     800dd4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dcf:	e8 a5 fe ff ff       	call   800c79 <alloc_sockfd>
}
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    

00800dd6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	53                   	push   %ebx
  800dda:	83 ec 04             	sub    $0x4,%esp
  800ddd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800ddf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800de6:	75 12                	jne    800dfa <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	6a 02                	push   $0x2
  800ded:	e8 7b 11 00 00       	call   801f6d <ipc_find_env>
  800df2:	a3 04 40 80 00       	mov    %eax,0x804004
  800df7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dfa:	6a 07                	push   $0x7
  800dfc:	68 00 60 80 00       	push   $0x806000
  800e01:	53                   	push   %ebx
  800e02:	ff 35 04 40 80 00    	pushl  0x804004
  800e08:	e8 0c 11 00 00       	call   801f19 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e0d:	83 c4 0c             	add    $0xc,%esp
  800e10:	6a 00                	push   $0x0
  800e12:	6a 00                	push   $0x0
  800e14:	6a 00                	push   $0x0
  800e16:	e8 95 10 00 00       	call   801eb0 <ipc_recv>
}
  800e1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e1e:	c9                   	leave  
  800e1f:	c3                   	ret    

00800e20 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e30:	8b 06                	mov    (%esi),%eax
  800e32:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e37:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3c:	e8 95 ff ff ff       	call   800dd6 <nsipc>
  800e41:	89 c3                	mov    %eax,%ebx
  800e43:	85 c0                	test   %eax,%eax
  800e45:	78 20                	js     800e67 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e47:	83 ec 04             	sub    $0x4,%esp
  800e4a:	ff 35 10 60 80 00    	pushl  0x806010
  800e50:	68 00 60 80 00       	push   $0x806000
  800e55:	ff 75 0c             	pushl  0xc(%ebp)
  800e58:	e8 9e 0e 00 00       	call   801cfb <memmove>
		*addrlen = ret->ret_addrlen;
  800e5d:	a1 10 60 80 00       	mov    0x806010,%eax
  800e62:	89 06                	mov    %eax,(%esi)
  800e64:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e67:	89 d8                	mov    %ebx,%eax
  800e69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5d                   	pop    %ebp
  800e6f:	c3                   	ret    

00800e70 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	53                   	push   %ebx
  800e74:	83 ec 08             	sub    $0x8,%esp
  800e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e82:	53                   	push   %ebx
  800e83:	ff 75 0c             	pushl  0xc(%ebp)
  800e86:	68 04 60 80 00       	push   $0x806004
  800e8b:	e8 6b 0e 00 00       	call   801cfb <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e90:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e96:	b8 02 00 00 00       	mov    $0x2,%eax
  800e9b:	e8 36 ff ff ff       	call   800dd6 <nsipc>
}
  800ea0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800eab:	8b 45 08             	mov    0x8(%ebp),%eax
  800eae:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb6:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ebb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec0:	e8 11 ff ff ff       	call   800dd6 <nsipc>
}
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <nsipc_close>:

int
nsipc_close(int s)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ed5:	b8 04 00 00 00       	mov    $0x4,%eax
  800eda:	e8 f7 fe ff ff       	call   800dd6 <nsipc>
}
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 08             	sub    $0x8,%esp
  800ee8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800eee:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ef3:	53                   	push   %ebx
  800ef4:	ff 75 0c             	pushl  0xc(%ebp)
  800ef7:	68 04 60 80 00       	push   $0x806004
  800efc:	e8 fa 0d 00 00       	call   801cfb <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f01:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f07:	b8 05 00 00 00       	mov    $0x5,%eax
  800f0c:	e8 c5 fe ff ff       	call   800dd6 <nsipc>
}
  800f11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    

00800f16 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f27:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f2c:	b8 06 00 00 00       	mov    $0x6,%eax
  800f31:	e8 a0 fe ff ff       	call   800dd6 <nsipc>
}
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	56                   	push   %esi
  800f3c:	53                   	push   %ebx
  800f3d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
  800f43:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f48:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f4e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f51:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f56:	b8 07 00 00 00       	mov    $0x7,%eax
  800f5b:	e8 76 fe ff ff       	call   800dd6 <nsipc>
  800f60:	89 c3                	mov    %eax,%ebx
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 35                	js     800f9b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f66:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f6b:	7f 04                	jg     800f71 <nsipc_recv+0x39>
  800f6d:	39 c6                	cmp    %eax,%esi
  800f6f:	7d 16                	jge    800f87 <nsipc_recv+0x4f>
  800f71:	68 93 23 80 00       	push   $0x802393
  800f76:	68 54 23 80 00       	push   $0x802354
  800f7b:	6a 62                	push   $0x62
  800f7d:	68 a8 23 80 00       	push   $0x8023a8
  800f82:	e8 84 05 00 00       	call   80150b <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	50                   	push   %eax
  800f8b:	68 00 60 80 00       	push   $0x806000
  800f90:	ff 75 0c             	pushl  0xc(%ebp)
  800f93:	e8 63 0d 00 00       	call   801cfb <memmove>
  800f98:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f9b:	89 d8                	mov    %ebx,%eax
  800f9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fae:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb1:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fb6:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fbc:	7e 16                	jle    800fd4 <nsipc_send+0x30>
  800fbe:	68 b4 23 80 00       	push   $0x8023b4
  800fc3:	68 54 23 80 00       	push   $0x802354
  800fc8:	6a 6d                	push   $0x6d
  800fca:	68 a8 23 80 00       	push   $0x8023a8
  800fcf:	e8 37 05 00 00       	call   80150b <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	53                   	push   %ebx
  800fd8:	ff 75 0c             	pushl  0xc(%ebp)
  800fdb:	68 0c 60 80 00       	push   $0x80600c
  800fe0:	e8 16 0d 00 00       	call   801cfb <memmove>
	nsipcbuf.send.req_size = size;
  800fe5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800feb:	8b 45 14             	mov    0x14(%ebp),%eax
  800fee:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800ff3:	b8 08 00 00 00       	mov    $0x8,%eax
  800ff8:	e8 d9 fd ff ff       	call   800dd6 <nsipc>
}
  800ffd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801008:	8b 45 08             	mov    0x8(%ebp),%eax
  80100b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801010:	8b 45 0c             	mov    0xc(%ebp),%eax
  801013:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801018:	8b 45 10             	mov    0x10(%ebp),%eax
  80101b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801020:	b8 09 00 00 00       	mov    $0x9,%eax
  801025:	e8 ac fd ff ff       	call   800dd6 <nsipc>
}
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	56                   	push   %esi
  801030:	53                   	push   %ebx
  801031:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	ff 75 08             	pushl  0x8(%ebp)
  80103a:	e8 62 f3 ff ff       	call   8003a1 <fd2data>
  80103f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801041:	83 c4 08             	add    $0x8,%esp
  801044:	68 c0 23 80 00       	push   $0x8023c0
  801049:	53                   	push   %ebx
  80104a:	e8 1a 0b 00 00       	call   801b69 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80104f:	8b 46 04             	mov    0x4(%esi),%eax
  801052:	2b 06                	sub    (%esi),%eax
  801054:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80105a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801061:	00 00 00 
	stat->st_dev = &devpipe;
  801064:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80106b:	30 80 00 
	return 0;
}
  80106e:	b8 00 00 00 00       	mov    $0x0,%eax
  801073:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801076:	5b                   	pop    %ebx
  801077:	5e                   	pop    %esi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    

0080107a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	53                   	push   %ebx
  80107e:	83 ec 0c             	sub    $0xc,%esp
  801081:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801084:	53                   	push   %ebx
  801085:	6a 00                	push   $0x0
  801087:	e8 7a f1 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80108c:	89 1c 24             	mov    %ebx,(%esp)
  80108f:	e8 0d f3 ff ff       	call   8003a1 <fd2data>
  801094:	83 c4 08             	add    $0x8,%esp
  801097:	50                   	push   %eax
  801098:	6a 00                	push   $0x0
  80109a:	e8 67 f1 ff ff       	call   800206 <sys_page_unmap>
}
  80109f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	57                   	push   %edi
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 1c             	sub    $0x1c,%esp
  8010ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010b0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8010b7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8010c0:	e8 e1 0e 00 00       	call   801fa6 <pageref>
  8010c5:	89 c3                	mov    %eax,%ebx
  8010c7:	89 3c 24             	mov    %edi,(%esp)
  8010ca:	e8 d7 0e 00 00       	call   801fa6 <pageref>
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	39 c3                	cmp    %eax,%ebx
  8010d4:	0f 94 c1             	sete   %cl
  8010d7:	0f b6 c9             	movzbl %cl,%ecx
  8010da:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010dd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010e3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010e6:	39 ce                	cmp    %ecx,%esi
  8010e8:	74 1b                	je     801105 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010ea:	39 c3                	cmp    %eax,%ebx
  8010ec:	75 c4                	jne    8010b2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010ee:	8b 42 58             	mov    0x58(%edx),%eax
  8010f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010f4:	50                   	push   %eax
  8010f5:	56                   	push   %esi
  8010f6:	68 c7 23 80 00       	push   $0x8023c7
  8010fb:	e8 e4 04 00 00       	call   8015e4 <cprintf>
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	eb ad                	jmp    8010b2 <_pipeisclosed+0xe>
	}
}
  801105:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	57                   	push   %edi
  801114:	56                   	push   %esi
  801115:	53                   	push   %ebx
  801116:	83 ec 28             	sub    $0x28,%esp
  801119:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80111c:	56                   	push   %esi
  80111d:	e8 7f f2 ff ff       	call   8003a1 <fd2data>
  801122:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	bf 00 00 00 00       	mov    $0x0,%edi
  80112c:	eb 4b                	jmp    801179 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80112e:	89 da                	mov    %ebx,%edx
  801130:	89 f0                	mov    %esi,%eax
  801132:	e8 6d ff ff ff       	call   8010a4 <_pipeisclosed>
  801137:	85 c0                	test   %eax,%eax
  801139:	75 48                	jne    801183 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80113b:	e8 22 f0 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801140:	8b 43 04             	mov    0x4(%ebx),%eax
  801143:	8b 0b                	mov    (%ebx),%ecx
  801145:	8d 51 20             	lea    0x20(%ecx),%edx
  801148:	39 d0                	cmp    %edx,%eax
  80114a:	73 e2                	jae    80112e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80114c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801153:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801156:	89 c2                	mov    %eax,%edx
  801158:	c1 fa 1f             	sar    $0x1f,%edx
  80115b:	89 d1                	mov    %edx,%ecx
  80115d:	c1 e9 1b             	shr    $0x1b,%ecx
  801160:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801163:	83 e2 1f             	and    $0x1f,%edx
  801166:	29 ca                	sub    %ecx,%edx
  801168:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80116c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801170:	83 c0 01             	add    $0x1,%eax
  801173:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801176:	83 c7 01             	add    $0x1,%edi
  801179:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80117c:	75 c2                	jne    801140 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80117e:	8b 45 10             	mov    0x10(%ebp),%eax
  801181:	eb 05                	jmp    801188 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801183:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	57                   	push   %edi
  801194:	56                   	push   %esi
  801195:	53                   	push   %ebx
  801196:	83 ec 18             	sub    $0x18,%esp
  801199:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80119c:	57                   	push   %edi
  80119d:	e8 ff f1 ff ff       	call   8003a1 <fd2data>
  8011a2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ac:	eb 3d                	jmp    8011eb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011ae:	85 db                	test   %ebx,%ebx
  8011b0:	74 04                	je     8011b6 <devpipe_read+0x26>
				return i;
  8011b2:	89 d8                	mov    %ebx,%eax
  8011b4:	eb 44                	jmp    8011fa <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011b6:	89 f2                	mov    %esi,%edx
  8011b8:	89 f8                	mov    %edi,%eax
  8011ba:	e8 e5 fe ff ff       	call   8010a4 <_pipeisclosed>
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	75 32                	jne    8011f5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011c3:	e8 9a ef ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011c8:	8b 06                	mov    (%esi),%eax
  8011ca:	3b 46 04             	cmp    0x4(%esi),%eax
  8011cd:	74 df                	je     8011ae <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011cf:	99                   	cltd   
  8011d0:	c1 ea 1b             	shr    $0x1b,%edx
  8011d3:	01 d0                	add    %edx,%eax
  8011d5:	83 e0 1f             	and    $0x1f,%eax
  8011d8:	29 d0                	sub    %edx,%eax
  8011da:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011e5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011e8:	83 c3 01             	add    $0x1,%ebx
  8011eb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011ee:	75 d8                	jne    8011c8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f3:	eb 05                	jmp    8011fa <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011f5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fd:	5b                   	pop    %ebx
  8011fe:	5e                   	pop    %esi
  8011ff:	5f                   	pop    %edi
  801200:	5d                   	pop    %ebp
  801201:	c3                   	ret    

00801202 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	56                   	push   %esi
  801206:	53                   	push   %ebx
  801207:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80120a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120d:	50                   	push   %eax
  80120e:	e8 a5 f1 ff ff       	call   8003b8 <fd_alloc>
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	89 c2                	mov    %eax,%edx
  801218:	85 c0                	test   %eax,%eax
  80121a:	0f 88 2c 01 00 00    	js     80134c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801220:	83 ec 04             	sub    $0x4,%esp
  801223:	68 07 04 00 00       	push   $0x407
  801228:	ff 75 f4             	pushl  -0xc(%ebp)
  80122b:	6a 00                	push   $0x0
  80122d:	e8 4f ef ff ff       	call   800181 <sys_page_alloc>
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	89 c2                	mov    %eax,%edx
  801237:	85 c0                	test   %eax,%eax
  801239:	0f 88 0d 01 00 00    	js     80134c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80123f:	83 ec 0c             	sub    $0xc,%esp
  801242:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801245:	50                   	push   %eax
  801246:	e8 6d f1 ff ff       	call   8003b8 <fd_alloc>
  80124b:	89 c3                	mov    %eax,%ebx
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	0f 88 e2 00 00 00    	js     80133a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801258:	83 ec 04             	sub    $0x4,%esp
  80125b:	68 07 04 00 00       	push   $0x407
  801260:	ff 75 f0             	pushl  -0x10(%ebp)
  801263:	6a 00                	push   $0x0
  801265:	e8 17 ef ff ff       	call   800181 <sys_page_alloc>
  80126a:	89 c3                	mov    %eax,%ebx
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	85 c0                	test   %eax,%eax
  801271:	0f 88 c3 00 00 00    	js     80133a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801277:	83 ec 0c             	sub    $0xc,%esp
  80127a:	ff 75 f4             	pushl  -0xc(%ebp)
  80127d:	e8 1f f1 ff ff       	call   8003a1 <fd2data>
  801282:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801284:	83 c4 0c             	add    $0xc,%esp
  801287:	68 07 04 00 00       	push   $0x407
  80128c:	50                   	push   %eax
  80128d:	6a 00                	push   $0x0
  80128f:	e8 ed ee ff ff       	call   800181 <sys_page_alloc>
  801294:	89 c3                	mov    %eax,%ebx
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	85 c0                	test   %eax,%eax
  80129b:	0f 88 89 00 00 00    	js     80132a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a7:	e8 f5 f0 ff ff       	call   8003a1 <fd2data>
  8012ac:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012b3:	50                   	push   %eax
  8012b4:	6a 00                	push   $0x0
  8012b6:	56                   	push   %esi
  8012b7:	6a 00                	push   $0x0
  8012b9:	e8 06 ef ff ff       	call   8001c4 <sys_page_map>
  8012be:	89 c3                	mov    %eax,%ebx
  8012c0:	83 c4 20             	add    $0x20,%esp
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 55                	js     80131c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012c7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012dc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ea:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012f1:	83 ec 0c             	sub    $0xc,%esp
  8012f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012f7:	e8 95 f0 ff ff       	call   800391 <fd2num>
  8012fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ff:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801301:	83 c4 04             	add    $0x4,%esp
  801304:	ff 75 f0             	pushl  -0x10(%ebp)
  801307:	e8 85 f0 ff ff       	call   800391 <fd2num>
  80130c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	ba 00 00 00 00       	mov    $0x0,%edx
  80131a:	eb 30                	jmp    80134c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	56                   	push   %esi
  801320:	6a 00                	push   $0x0
  801322:	e8 df ee ff ff       	call   800206 <sys_page_unmap>
  801327:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	ff 75 f0             	pushl  -0x10(%ebp)
  801330:	6a 00                	push   $0x0
  801332:	e8 cf ee ff ff       	call   800206 <sys_page_unmap>
  801337:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	ff 75 f4             	pushl  -0xc(%ebp)
  801340:	6a 00                	push   $0x0
  801342:	e8 bf ee ff ff       	call   800206 <sys_page_unmap>
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80134c:	89 d0                	mov    %edx,%eax
  80134e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801351:	5b                   	pop    %ebx
  801352:	5e                   	pop    %esi
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    

00801355 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80135b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135e:	50                   	push   %eax
  80135f:	ff 75 08             	pushl  0x8(%ebp)
  801362:	e8 a0 f0 ff ff       	call   800407 <fd_lookup>
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 18                	js     801386 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80136e:	83 ec 0c             	sub    $0xc,%esp
  801371:	ff 75 f4             	pushl  -0xc(%ebp)
  801374:	e8 28 f0 ff ff       	call   8003a1 <fd2data>
	return _pipeisclosed(fd, p);
  801379:	89 c2                	mov    %eax,%edx
  80137b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137e:	e8 21 fd ff ff       	call   8010a4 <_pipeisclosed>
  801383:	83 c4 10             	add    $0x10,%esp
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80138b:	b8 00 00 00 00       	mov    $0x0,%eax
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801398:	68 df 23 80 00       	push   $0x8023df
  80139d:	ff 75 0c             	pushl  0xc(%ebp)
  8013a0:	e8 c4 07 00 00       	call   801b69 <strcpy>
	return 0;
}
  8013a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	57                   	push   %edi
  8013b0:	56                   	push   %esi
  8013b1:	53                   	push   %ebx
  8013b2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013bd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c3:	eb 2d                	jmp    8013f2 <devcons_write+0x46>
		m = n - tot;
  8013c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013c8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013ca:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013cd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013d2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013d5:	83 ec 04             	sub    $0x4,%esp
  8013d8:	53                   	push   %ebx
  8013d9:	03 45 0c             	add    0xc(%ebp),%eax
  8013dc:	50                   	push   %eax
  8013dd:	57                   	push   %edi
  8013de:	e8 18 09 00 00       	call   801cfb <memmove>
		sys_cputs(buf, m);
  8013e3:	83 c4 08             	add    $0x8,%esp
  8013e6:	53                   	push   %ebx
  8013e7:	57                   	push   %edi
  8013e8:	e8 d8 ec ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ed:	01 de                	add    %ebx,%esi
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	89 f0                	mov    %esi,%eax
  8013f4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013f7:	72 cc                	jb     8013c5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013fc:	5b                   	pop    %ebx
  8013fd:	5e                   	pop    %esi
  8013fe:	5f                   	pop    %edi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80140c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801410:	74 2a                	je     80143c <devcons_read+0x3b>
  801412:	eb 05                	jmp    801419 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801414:	e8 49 ed ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801419:	e8 c5 ec ff ff       	call   8000e3 <sys_cgetc>
  80141e:	85 c0                	test   %eax,%eax
  801420:	74 f2                	je     801414 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801422:	85 c0                	test   %eax,%eax
  801424:	78 16                	js     80143c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801426:	83 f8 04             	cmp    $0x4,%eax
  801429:	74 0c                	je     801437 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80142b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80142e:	88 02                	mov    %al,(%edx)
	return 1;
  801430:	b8 01 00 00 00       	mov    $0x1,%eax
  801435:	eb 05                	jmp    80143c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801437:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80143c:	c9                   	leave  
  80143d:	c3                   	ret    

0080143e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80143e:	55                   	push   %ebp
  80143f:	89 e5                	mov    %esp,%ebp
  801441:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801444:	8b 45 08             	mov    0x8(%ebp),%eax
  801447:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80144a:	6a 01                	push   $0x1
  80144c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	e8 70 ec ff ff       	call   8000c5 <sys_cputs>
}
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	c9                   	leave  
  801459:	c3                   	ret    

0080145a <getchar>:

int
getchar(void)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801460:	6a 01                	push   $0x1
  801462:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801465:	50                   	push   %eax
  801466:	6a 00                	push   $0x0
  801468:	e8 00 f2 ff ff       	call   80066d <read>
	if (r < 0)
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	78 0f                	js     801483 <getchar+0x29>
		return r;
	if (r < 1)
  801474:	85 c0                	test   %eax,%eax
  801476:	7e 06                	jle    80147e <getchar+0x24>
		return -E_EOF;
	return c;
  801478:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80147c:	eb 05                	jmp    801483 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80147e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80148b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	ff 75 08             	pushl  0x8(%ebp)
  801492:	e8 70 ef ff ff       	call   800407 <fd_lookup>
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	85 c0                	test   %eax,%eax
  80149c:	78 11                	js     8014af <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80149e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014a7:	39 10                	cmp    %edx,(%eax)
  8014a9:	0f 94 c0             	sete   %al
  8014ac:	0f b6 c0             	movzbl %al,%eax
}
  8014af:	c9                   	leave  
  8014b0:	c3                   	ret    

008014b1 <opencons>:

int
opencons(void)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ba:	50                   	push   %eax
  8014bb:	e8 f8 ee ff ff       	call   8003b8 <fd_alloc>
  8014c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014c5:	85 c0                	test   %eax,%eax
  8014c7:	78 3e                	js     801507 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c9:	83 ec 04             	sub    $0x4,%esp
  8014cc:	68 07 04 00 00       	push   $0x407
  8014d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d4:	6a 00                	push   $0x0
  8014d6:	e8 a6 ec ff ff       	call   800181 <sys_page_alloc>
  8014db:	83 c4 10             	add    $0x10,%esp
		return r;
  8014de:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	78 23                	js     801507 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014e4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ed:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014f9:	83 ec 0c             	sub    $0xc,%esp
  8014fc:	50                   	push   %eax
  8014fd:	e8 8f ee ff ff       	call   800391 <fd2num>
  801502:	89 c2                	mov    %eax,%edx
  801504:	83 c4 10             	add    $0x10,%esp
}
  801507:	89 d0                	mov    %edx,%eax
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	56                   	push   %esi
  80150f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801510:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801513:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801519:	e8 25 ec ff ff       	call   800143 <sys_getenvid>
  80151e:	83 ec 0c             	sub    $0xc,%esp
  801521:	ff 75 0c             	pushl  0xc(%ebp)
  801524:	ff 75 08             	pushl  0x8(%ebp)
  801527:	56                   	push   %esi
  801528:	50                   	push   %eax
  801529:	68 ec 23 80 00       	push   $0x8023ec
  80152e:	e8 b1 00 00 00       	call   8015e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801533:	83 c4 18             	add    $0x18,%esp
  801536:	53                   	push   %ebx
  801537:	ff 75 10             	pushl  0x10(%ebp)
  80153a:	e8 54 00 00 00       	call   801593 <vcprintf>
	cprintf("\n");
  80153f:	c7 04 24 d8 23 80 00 	movl   $0x8023d8,(%esp)
  801546:	e8 99 00 00 00       	call   8015e4 <cprintf>
  80154b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80154e:	cc                   	int3   
  80154f:	eb fd                	jmp    80154e <_panic+0x43>

00801551 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	53                   	push   %ebx
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80155b:	8b 13                	mov    (%ebx),%edx
  80155d:	8d 42 01             	lea    0x1(%edx),%eax
  801560:	89 03                	mov    %eax,(%ebx)
  801562:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801565:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801569:	3d ff 00 00 00       	cmp    $0xff,%eax
  80156e:	75 1a                	jne    80158a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	68 ff 00 00 00       	push   $0xff
  801578:	8d 43 08             	lea    0x8(%ebx),%eax
  80157b:	50                   	push   %eax
  80157c:	e8 44 eb ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  801581:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801587:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80158a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80158e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80159c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015a3:	00 00 00 
	b.cnt = 0;
  8015a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015b0:	ff 75 0c             	pushl  0xc(%ebp)
  8015b3:	ff 75 08             	pushl  0x8(%ebp)
  8015b6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	68 51 15 80 00       	push   $0x801551
  8015c2:	e8 54 01 00 00       	call   80171b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015c7:	83 c4 08             	add    $0x8,%esp
  8015ca:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015d0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015d6:	50                   	push   %eax
  8015d7:	e8 e9 ea ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  8015dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015e2:	c9                   	leave  
  8015e3:	c3                   	ret    

008015e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015ed:	50                   	push   %eax
  8015ee:	ff 75 08             	pushl  0x8(%ebp)
  8015f1:	e8 9d ff ff ff       	call   801593 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015f6:	c9                   	leave  
  8015f7:	c3                   	ret    

008015f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015f8:	55                   	push   %ebp
  8015f9:	89 e5                	mov    %esp,%ebp
  8015fb:	57                   	push   %edi
  8015fc:	56                   	push   %esi
  8015fd:	53                   	push   %ebx
  8015fe:	83 ec 1c             	sub    $0x1c,%esp
  801601:	89 c7                	mov    %eax,%edi
  801603:	89 d6                	mov    %edx,%esi
  801605:	8b 45 08             	mov    0x8(%ebp),%eax
  801608:	8b 55 0c             	mov    0xc(%ebp),%edx
  80160b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80160e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801611:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801614:	bb 00 00 00 00       	mov    $0x0,%ebx
  801619:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80161c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80161f:	39 d3                	cmp    %edx,%ebx
  801621:	72 05                	jb     801628 <printnum+0x30>
  801623:	39 45 10             	cmp    %eax,0x10(%ebp)
  801626:	77 45                	ja     80166d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801628:	83 ec 0c             	sub    $0xc,%esp
  80162b:	ff 75 18             	pushl  0x18(%ebp)
  80162e:	8b 45 14             	mov    0x14(%ebp),%eax
  801631:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801634:	53                   	push   %ebx
  801635:	ff 75 10             	pushl  0x10(%ebp)
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80163e:	ff 75 e0             	pushl  -0x20(%ebp)
  801641:	ff 75 dc             	pushl  -0x24(%ebp)
  801644:	ff 75 d8             	pushl  -0x28(%ebp)
  801647:	e8 a4 09 00 00       	call   801ff0 <__udivdi3>
  80164c:	83 c4 18             	add    $0x18,%esp
  80164f:	52                   	push   %edx
  801650:	50                   	push   %eax
  801651:	89 f2                	mov    %esi,%edx
  801653:	89 f8                	mov    %edi,%eax
  801655:	e8 9e ff ff ff       	call   8015f8 <printnum>
  80165a:	83 c4 20             	add    $0x20,%esp
  80165d:	eb 18                	jmp    801677 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80165f:	83 ec 08             	sub    $0x8,%esp
  801662:	56                   	push   %esi
  801663:	ff 75 18             	pushl  0x18(%ebp)
  801666:	ff d7                	call   *%edi
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	eb 03                	jmp    801670 <printnum+0x78>
  80166d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801670:	83 eb 01             	sub    $0x1,%ebx
  801673:	85 db                	test   %ebx,%ebx
  801675:	7f e8                	jg     80165f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801677:	83 ec 08             	sub    $0x8,%esp
  80167a:	56                   	push   %esi
  80167b:	83 ec 04             	sub    $0x4,%esp
  80167e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801681:	ff 75 e0             	pushl  -0x20(%ebp)
  801684:	ff 75 dc             	pushl  -0x24(%ebp)
  801687:	ff 75 d8             	pushl  -0x28(%ebp)
  80168a:	e8 91 0a 00 00       	call   802120 <__umoddi3>
  80168f:	83 c4 14             	add    $0x14,%esp
  801692:	0f be 80 0f 24 80 00 	movsbl 0x80240f(%eax),%eax
  801699:	50                   	push   %eax
  80169a:	ff d7                	call   *%edi
}
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a2:	5b                   	pop    %ebx
  8016a3:	5e                   	pop    %esi
  8016a4:	5f                   	pop    %edi
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8016aa:	83 fa 01             	cmp    $0x1,%edx
  8016ad:	7e 0e                	jle    8016bd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8016af:	8b 10                	mov    (%eax),%edx
  8016b1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8016b4:	89 08                	mov    %ecx,(%eax)
  8016b6:	8b 02                	mov    (%edx),%eax
  8016b8:	8b 52 04             	mov    0x4(%edx),%edx
  8016bb:	eb 22                	jmp    8016df <getuint+0x38>
	else if (lflag)
  8016bd:	85 d2                	test   %edx,%edx
  8016bf:	74 10                	je     8016d1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016c1:	8b 10                	mov    (%eax),%edx
  8016c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016c6:	89 08                	mov    %ecx,(%eax)
  8016c8:	8b 02                	mov    (%edx),%eax
  8016ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cf:	eb 0e                	jmp    8016df <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016d1:	8b 10                	mov    (%eax),%edx
  8016d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016d6:	89 08                	mov    %ecx,(%eax)
  8016d8:	8b 02                	mov    (%edx),%eax
  8016da:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016eb:	8b 10                	mov    (%eax),%edx
  8016ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8016f0:	73 0a                	jae    8016fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8016f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016f5:	89 08                	mov    %ecx,(%eax)
  8016f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fa:	88 02                	mov    %al,(%edx)
}
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801704:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801707:	50                   	push   %eax
  801708:	ff 75 10             	pushl  0x10(%ebp)
  80170b:	ff 75 0c             	pushl  0xc(%ebp)
  80170e:	ff 75 08             	pushl  0x8(%ebp)
  801711:	e8 05 00 00 00       	call   80171b <vprintfmt>
	va_end(ap);
}
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	c9                   	leave  
  80171a:	c3                   	ret    

0080171b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	57                   	push   %edi
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	83 ec 2c             	sub    $0x2c,%esp
  801724:	8b 75 08             	mov    0x8(%ebp),%esi
  801727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80172a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80172d:	eb 12                	jmp    801741 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80172f:	85 c0                	test   %eax,%eax
  801731:	0f 84 89 03 00 00    	je     801ac0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	53                   	push   %ebx
  80173b:	50                   	push   %eax
  80173c:	ff d6                	call   *%esi
  80173e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801741:	83 c7 01             	add    $0x1,%edi
  801744:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801748:	83 f8 25             	cmp    $0x25,%eax
  80174b:	75 e2                	jne    80172f <vprintfmt+0x14>
  80174d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801751:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801758:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80175f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801766:	ba 00 00 00 00       	mov    $0x0,%edx
  80176b:	eb 07                	jmp    801774 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80176d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801770:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801774:	8d 47 01             	lea    0x1(%edi),%eax
  801777:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80177a:	0f b6 07             	movzbl (%edi),%eax
  80177d:	0f b6 c8             	movzbl %al,%ecx
  801780:	83 e8 23             	sub    $0x23,%eax
  801783:	3c 55                	cmp    $0x55,%al
  801785:	0f 87 1a 03 00 00    	ja     801aa5 <vprintfmt+0x38a>
  80178b:	0f b6 c0             	movzbl %al,%eax
  80178e:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  801795:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801798:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80179c:	eb d6                	jmp    801774 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8017a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8017ac:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8017b0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8017b3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8017b6:	83 fa 09             	cmp    $0x9,%edx
  8017b9:	77 39                	ja     8017f4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017bb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017be:	eb e9                	jmp    8017a9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c3:	8d 48 04             	lea    0x4(%eax),%ecx
  8017c6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017c9:	8b 00                	mov    (%eax),%eax
  8017cb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017d1:	eb 27                	jmp    8017fa <vprintfmt+0xdf>
  8017d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017d6:	85 c0                	test   %eax,%eax
  8017d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017dd:	0f 49 c8             	cmovns %eax,%ecx
  8017e0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017e6:	eb 8c                	jmp    801774 <vprintfmt+0x59>
  8017e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017eb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017f2:	eb 80                	jmp    801774 <vprintfmt+0x59>
  8017f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017f7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017fe:	0f 89 70 ff ff ff    	jns    801774 <vprintfmt+0x59>
				width = precision, precision = -1;
  801804:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801807:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80180a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801811:	e9 5e ff ff ff       	jmp    801774 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801816:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801819:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80181c:	e9 53 ff ff ff       	jmp    801774 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801821:	8b 45 14             	mov    0x14(%ebp),%eax
  801824:	8d 50 04             	lea    0x4(%eax),%edx
  801827:	89 55 14             	mov    %edx,0x14(%ebp)
  80182a:	83 ec 08             	sub    $0x8,%esp
  80182d:	53                   	push   %ebx
  80182e:	ff 30                	pushl  (%eax)
  801830:	ff d6                	call   *%esi
			break;
  801832:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801835:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801838:	e9 04 ff ff ff       	jmp    801741 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80183d:	8b 45 14             	mov    0x14(%ebp),%eax
  801840:	8d 50 04             	lea    0x4(%eax),%edx
  801843:	89 55 14             	mov    %edx,0x14(%ebp)
  801846:	8b 00                	mov    (%eax),%eax
  801848:	99                   	cltd   
  801849:	31 d0                	xor    %edx,%eax
  80184b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80184d:	83 f8 0f             	cmp    $0xf,%eax
  801850:	7f 0b                	jg     80185d <vprintfmt+0x142>
  801852:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  801859:	85 d2                	test   %edx,%edx
  80185b:	75 18                	jne    801875 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80185d:	50                   	push   %eax
  80185e:	68 27 24 80 00       	push   $0x802427
  801863:	53                   	push   %ebx
  801864:	56                   	push   %esi
  801865:	e8 94 fe ff ff       	call   8016fe <printfmt>
  80186a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801870:	e9 cc fe ff ff       	jmp    801741 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801875:	52                   	push   %edx
  801876:	68 66 23 80 00       	push   $0x802366
  80187b:	53                   	push   %ebx
  80187c:	56                   	push   %esi
  80187d:	e8 7c fe ff ff       	call   8016fe <printfmt>
  801882:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801885:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801888:	e9 b4 fe ff ff       	jmp    801741 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80188d:	8b 45 14             	mov    0x14(%ebp),%eax
  801890:	8d 50 04             	lea    0x4(%eax),%edx
  801893:	89 55 14             	mov    %edx,0x14(%ebp)
  801896:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801898:	85 ff                	test   %edi,%edi
  80189a:	b8 20 24 80 00       	mov    $0x802420,%eax
  80189f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8018a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018a6:	0f 8e 94 00 00 00    	jle    801940 <vprintfmt+0x225>
  8018ac:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8018b0:	0f 84 98 00 00 00    	je     80194e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b6:	83 ec 08             	sub    $0x8,%esp
  8018b9:	ff 75 d0             	pushl  -0x30(%ebp)
  8018bc:	57                   	push   %edi
  8018bd:	e8 86 02 00 00       	call   801b48 <strnlen>
  8018c2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018c5:	29 c1                	sub    %eax,%ecx
  8018c7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018ca:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018cd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018d4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018d7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018d9:	eb 0f                	jmp    8018ea <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018db:	83 ec 08             	sub    $0x8,%esp
  8018de:	53                   	push   %ebx
  8018df:	ff 75 e0             	pushl  -0x20(%ebp)
  8018e2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018e4:	83 ef 01             	sub    $0x1,%edi
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	85 ff                	test   %edi,%edi
  8018ec:	7f ed                	jg     8018db <vprintfmt+0x1c0>
  8018ee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018f1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018f4:	85 c9                	test   %ecx,%ecx
  8018f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fb:	0f 49 c1             	cmovns %ecx,%eax
  8018fe:	29 c1                	sub    %eax,%ecx
  801900:	89 75 08             	mov    %esi,0x8(%ebp)
  801903:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801906:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801909:	89 cb                	mov    %ecx,%ebx
  80190b:	eb 4d                	jmp    80195a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80190d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801911:	74 1b                	je     80192e <vprintfmt+0x213>
  801913:	0f be c0             	movsbl %al,%eax
  801916:	83 e8 20             	sub    $0x20,%eax
  801919:	83 f8 5e             	cmp    $0x5e,%eax
  80191c:	76 10                	jbe    80192e <vprintfmt+0x213>
					putch('?', putdat);
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	ff 75 0c             	pushl  0xc(%ebp)
  801924:	6a 3f                	push   $0x3f
  801926:	ff 55 08             	call   *0x8(%ebp)
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	eb 0d                	jmp    80193b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80192e:	83 ec 08             	sub    $0x8,%esp
  801931:	ff 75 0c             	pushl  0xc(%ebp)
  801934:	52                   	push   %edx
  801935:	ff 55 08             	call   *0x8(%ebp)
  801938:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80193b:	83 eb 01             	sub    $0x1,%ebx
  80193e:	eb 1a                	jmp    80195a <vprintfmt+0x23f>
  801940:	89 75 08             	mov    %esi,0x8(%ebp)
  801943:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801946:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801949:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80194c:	eb 0c                	jmp    80195a <vprintfmt+0x23f>
  80194e:	89 75 08             	mov    %esi,0x8(%ebp)
  801951:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801954:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801957:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80195a:	83 c7 01             	add    $0x1,%edi
  80195d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801961:	0f be d0             	movsbl %al,%edx
  801964:	85 d2                	test   %edx,%edx
  801966:	74 23                	je     80198b <vprintfmt+0x270>
  801968:	85 f6                	test   %esi,%esi
  80196a:	78 a1                	js     80190d <vprintfmt+0x1f2>
  80196c:	83 ee 01             	sub    $0x1,%esi
  80196f:	79 9c                	jns    80190d <vprintfmt+0x1f2>
  801971:	89 df                	mov    %ebx,%edi
  801973:	8b 75 08             	mov    0x8(%ebp),%esi
  801976:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801979:	eb 18                	jmp    801993 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	53                   	push   %ebx
  80197f:	6a 20                	push   $0x20
  801981:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801983:	83 ef 01             	sub    $0x1,%edi
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	eb 08                	jmp    801993 <vprintfmt+0x278>
  80198b:	89 df                	mov    %ebx,%edi
  80198d:	8b 75 08             	mov    0x8(%ebp),%esi
  801990:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801993:	85 ff                	test   %edi,%edi
  801995:	7f e4                	jg     80197b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801997:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80199a:	e9 a2 fd ff ff       	jmp    801741 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80199f:	83 fa 01             	cmp    $0x1,%edx
  8019a2:	7e 16                	jle    8019ba <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8019a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a7:	8d 50 08             	lea    0x8(%eax),%edx
  8019aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8019ad:	8b 50 04             	mov    0x4(%eax),%edx
  8019b0:	8b 00                	mov    (%eax),%eax
  8019b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019b8:	eb 32                	jmp    8019ec <vprintfmt+0x2d1>
	else if (lflag)
  8019ba:	85 d2                	test   %edx,%edx
  8019bc:	74 18                	je     8019d6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019be:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c1:	8d 50 04             	lea    0x4(%eax),%edx
  8019c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c7:	8b 00                	mov    (%eax),%eax
  8019c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019cc:	89 c1                	mov    %eax,%ecx
  8019ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8019d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019d4:	eb 16                	jmp    8019ec <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d9:	8d 50 04             	lea    0x4(%eax),%edx
  8019dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8019df:	8b 00                	mov    (%eax),%eax
  8019e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019e4:	89 c1                	mov    %eax,%ecx
  8019e6:	c1 f9 1f             	sar    $0x1f,%ecx
  8019e9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019ef:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019fb:	79 74                	jns    801a71 <vprintfmt+0x356>
				putch('-', putdat);
  8019fd:	83 ec 08             	sub    $0x8,%esp
  801a00:	53                   	push   %ebx
  801a01:	6a 2d                	push   $0x2d
  801a03:	ff d6                	call   *%esi
				num = -(long long) num;
  801a05:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801a08:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801a0b:	f7 d8                	neg    %eax
  801a0d:	83 d2 00             	adc    $0x0,%edx
  801a10:	f7 da                	neg    %edx
  801a12:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a15:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a1a:	eb 55                	jmp    801a71 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a1c:	8d 45 14             	lea    0x14(%ebp),%eax
  801a1f:	e8 83 fc ff ff       	call   8016a7 <getuint>
			base = 10;
  801a24:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a29:	eb 46                	jmp    801a71 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a2b:	8d 45 14             	lea    0x14(%ebp),%eax
  801a2e:	e8 74 fc ff ff       	call   8016a7 <getuint>
                        base = 8;
  801a33:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a38:	eb 37                	jmp    801a71 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a3a:	83 ec 08             	sub    $0x8,%esp
  801a3d:	53                   	push   %ebx
  801a3e:	6a 30                	push   $0x30
  801a40:	ff d6                	call   *%esi
			putch('x', putdat);
  801a42:	83 c4 08             	add    $0x8,%esp
  801a45:	53                   	push   %ebx
  801a46:	6a 78                	push   $0x78
  801a48:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a4a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a4d:	8d 50 04             	lea    0x4(%eax),%edx
  801a50:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a53:	8b 00                	mov    (%eax),%eax
  801a55:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a5a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a5d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a62:	eb 0d                	jmp    801a71 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a64:	8d 45 14             	lea    0x14(%ebp),%eax
  801a67:	e8 3b fc ff ff       	call   8016a7 <getuint>
			base = 16;
  801a6c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a71:	83 ec 0c             	sub    $0xc,%esp
  801a74:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a78:	57                   	push   %edi
  801a79:	ff 75 e0             	pushl  -0x20(%ebp)
  801a7c:	51                   	push   %ecx
  801a7d:	52                   	push   %edx
  801a7e:	50                   	push   %eax
  801a7f:	89 da                	mov    %ebx,%edx
  801a81:	89 f0                	mov    %esi,%eax
  801a83:	e8 70 fb ff ff       	call   8015f8 <printnum>
			break;
  801a88:	83 c4 20             	add    $0x20,%esp
  801a8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a8e:	e9 ae fc ff ff       	jmp    801741 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	53                   	push   %ebx
  801a97:	51                   	push   %ecx
  801a98:	ff d6                	call   *%esi
			break;
  801a9a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801aa0:	e9 9c fc ff ff       	jmp    801741 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801aa5:	83 ec 08             	sub    $0x8,%esp
  801aa8:	53                   	push   %ebx
  801aa9:	6a 25                	push   $0x25
  801aab:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	eb 03                	jmp    801ab5 <vprintfmt+0x39a>
  801ab2:	83 ef 01             	sub    $0x1,%edi
  801ab5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ab9:	75 f7                	jne    801ab2 <vprintfmt+0x397>
  801abb:	e9 81 fc ff ff       	jmp    801741 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ac0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac3:	5b                   	pop    %ebx
  801ac4:	5e                   	pop    %esi
  801ac5:	5f                   	pop    %edi
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	83 ec 18             	sub    $0x18,%esp
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ad4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ad7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801adb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ade:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	74 26                	je     801b0f <vsnprintf+0x47>
  801ae9:	85 d2                	test   %edx,%edx
  801aeb:	7e 22                	jle    801b0f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801aed:	ff 75 14             	pushl  0x14(%ebp)
  801af0:	ff 75 10             	pushl  0x10(%ebp)
  801af3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801af6:	50                   	push   %eax
  801af7:	68 e1 16 80 00       	push   $0x8016e1
  801afc:	e8 1a fc ff ff       	call   80171b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b04:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	eb 05                	jmp    801b14 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b1c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b1f:	50                   	push   %eax
  801b20:	ff 75 10             	pushl  0x10(%ebp)
  801b23:	ff 75 0c             	pushl  0xc(%ebp)
  801b26:	ff 75 08             	pushl  0x8(%ebp)
  801b29:	e8 9a ff ff ff       	call   801ac8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3b:	eb 03                	jmp    801b40 <strlen+0x10>
		n++;
  801b3d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b40:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b44:	75 f7                	jne    801b3d <strlen+0xd>
		n++;
	return n;
}
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b51:	ba 00 00 00 00       	mov    $0x0,%edx
  801b56:	eb 03                	jmp    801b5b <strnlen+0x13>
		n++;
  801b58:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b5b:	39 c2                	cmp    %eax,%edx
  801b5d:	74 08                	je     801b67 <strnlen+0x1f>
  801b5f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b63:	75 f3                	jne    801b58 <strnlen+0x10>
  801b65:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	53                   	push   %ebx
  801b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b73:	89 c2                	mov    %eax,%edx
  801b75:	83 c2 01             	add    $0x1,%edx
  801b78:	83 c1 01             	add    $0x1,%ecx
  801b7b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b7f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b82:	84 db                	test   %bl,%bl
  801b84:	75 ef                	jne    801b75 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b86:	5b                   	pop    %ebx
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	53                   	push   %ebx
  801b8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b90:	53                   	push   %ebx
  801b91:	e8 9a ff ff ff       	call   801b30 <strlen>
  801b96:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b99:	ff 75 0c             	pushl  0xc(%ebp)
  801b9c:	01 d8                	add    %ebx,%eax
  801b9e:	50                   	push   %eax
  801b9f:	e8 c5 ff ff ff       	call   801b69 <strcpy>
	return dst;
}
  801ba4:	89 d8                	mov    %ebx,%eax
  801ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	56                   	push   %esi
  801baf:	53                   	push   %ebx
  801bb0:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb6:	89 f3                	mov    %esi,%ebx
  801bb8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bbb:	89 f2                	mov    %esi,%edx
  801bbd:	eb 0f                	jmp    801bce <strncpy+0x23>
		*dst++ = *src;
  801bbf:	83 c2 01             	add    $0x1,%edx
  801bc2:	0f b6 01             	movzbl (%ecx),%eax
  801bc5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bc8:	80 39 01             	cmpb   $0x1,(%ecx)
  801bcb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bce:	39 da                	cmp    %ebx,%edx
  801bd0:	75 ed                	jne    801bbf <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bd2:	89 f0                	mov    %esi,%eax
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    

00801bd8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	56                   	push   %esi
  801bdc:	53                   	push   %ebx
  801bdd:	8b 75 08             	mov    0x8(%ebp),%esi
  801be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be3:	8b 55 10             	mov    0x10(%ebp),%edx
  801be6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801be8:	85 d2                	test   %edx,%edx
  801bea:	74 21                	je     801c0d <strlcpy+0x35>
  801bec:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bf0:	89 f2                	mov    %esi,%edx
  801bf2:	eb 09                	jmp    801bfd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bf4:	83 c2 01             	add    $0x1,%edx
  801bf7:	83 c1 01             	add    $0x1,%ecx
  801bfa:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bfd:	39 c2                	cmp    %eax,%edx
  801bff:	74 09                	je     801c0a <strlcpy+0x32>
  801c01:	0f b6 19             	movzbl (%ecx),%ebx
  801c04:	84 db                	test   %bl,%bl
  801c06:	75 ec                	jne    801bf4 <strlcpy+0x1c>
  801c08:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c0a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c0d:	29 f0                	sub    %esi,%eax
}
  801c0f:	5b                   	pop    %ebx
  801c10:	5e                   	pop    %esi
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    

00801c13 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c19:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c1c:	eb 06                	jmp    801c24 <strcmp+0x11>
		p++, q++;
  801c1e:	83 c1 01             	add    $0x1,%ecx
  801c21:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c24:	0f b6 01             	movzbl (%ecx),%eax
  801c27:	84 c0                	test   %al,%al
  801c29:	74 04                	je     801c2f <strcmp+0x1c>
  801c2b:	3a 02                	cmp    (%edx),%al
  801c2d:	74 ef                	je     801c1e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c2f:	0f b6 c0             	movzbl %al,%eax
  801c32:	0f b6 12             	movzbl (%edx),%edx
  801c35:	29 d0                	sub    %edx,%eax
}
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	53                   	push   %ebx
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c40:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c43:	89 c3                	mov    %eax,%ebx
  801c45:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c48:	eb 06                	jmp    801c50 <strncmp+0x17>
		n--, p++, q++;
  801c4a:	83 c0 01             	add    $0x1,%eax
  801c4d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c50:	39 d8                	cmp    %ebx,%eax
  801c52:	74 15                	je     801c69 <strncmp+0x30>
  801c54:	0f b6 08             	movzbl (%eax),%ecx
  801c57:	84 c9                	test   %cl,%cl
  801c59:	74 04                	je     801c5f <strncmp+0x26>
  801c5b:	3a 0a                	cmp    (%edx),%cl
  801c5d:	74 eb                	je     801c4a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c5f:	0f b6 00             	movzbl (%eax),%eax
  801c62:	0f b6 12             	movzbl (%edx),%edx
  801c65:	29 d0                	sub    %edx,%eax
  801c67:	eb 05                	jmp    801c6e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c69:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c6e:	5b                   	pop    %ebx
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    

00801c71 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c7b:	eb 07                	jmp    801c84 <strchr+0x13>
		if (*s == c)
  801c7d:	38 ca                	cmp    %cl,%dl
  801c7f:	74 0f                	je     801c90 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c81:	83 c0 01             	add    $0x1,%eax
  801c84:	0f b6 10             	movzbl (%eax),%edx
  801c87:	84 d2                	test   %dl,%dl
  801c89:	75 f2                	jne    801c7d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    

00801c92 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c9c:	eb 03                	jmp    801ca1 <strfind+0xf>
  801c9e:	83 c0 01             	add    $0x1,%eax
  801ca1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801ca4:	38 ca                	cmp    %cl,%dl
  801ca6:	74 04                	je     801cac <strfind+0x1a>
  801ca8:	84 d2                	test   %dl,%dl
  801caa:	75 f2                	jne    801c9e <strfind+0xc>
			break;
	return (char *) s;
}
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cba:	85 c9                	test   %ecx,%ecx
  801cbc:	74 36                	je     801cf4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cbe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cc4:	75 28                	jne    801cee <memset+0x40>
  801cc6:	f6 c1 03             	test   $0x3,%cl
  801cc9:	75 23                	jne    801cee <memset+0x40>
		c &= 0xFF;
  801ccb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ccf:	89 d3                	mov    %edx,%ebx
  801cd1:	c1 e3 08             	shl    $0x8,%ebx
  801cd4:	89 d6                	mov    %edx,%esi
  801cd6:	c1 e6 18             	shl    $0x18,%esi
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	c1 e0 10             	shl    $0x10,%eax
  801cde:	09 f0                	or     %esi,%eax
  801ce0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801ce2:	89 d8                	mov    %ebx,%eax
  801ce4:	09 d0                	or     %edx,%eax
  801ce6:	c1 e9 02             	shr    $0x2,%ecx
  801ce9:	fc                   	cld    
  801cea:	f3 ab                	rep stos %eax,%es:(%edi)
  801cec:	eb 06                	jmp    801cf4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf1:	fc                   	cld    
  801cf2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cf4:	89 f8                	mov    %edi,%eax
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5f                   	pop    %edi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	57                   	push   %edi
  801cff:	56                   	push   %esi
  801d00:	8b 45 08             	mov    0x8(%ebp),%eax
  801d03:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d09:	39 c6                	cmp    %eax,%esi
  801d0b:	73 35                	jae    801d42 <memmove+0x47>
  801d0d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d10:	39 d0                	cmp    %edx,%eax
  801d12:	73 2e                	jae    801d42 <memmove+0x47>
		s += n;
		d += n;
  801d14:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d17:	89 d6                	mov    %edx,%esi
  801d19:	09 fe                	or     %edi,%esi
  801d1b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d21:	75 13                	jne    801d36 <memmove+0x3b>
  801d23:	f6 c1 03             	test   $0x3,%cl
  801d26:	75 0e                	jne    801d36 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d28:	83 ef 04             	sub    $0x4,%edi
  801d2b:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d2e:	c1 e9 02             	shr    $0x2,%ecx
  801d31:	fd                   	std    
  801d32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d34:	eb 09                	jmp    801d3f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d36:	83 ef 01             	sub    $0x1,%edi
  801d39:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d3c:	fd                   	std    
  801d3d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d3f:	fc                   	cld    
  801d40:	eb 1d                	jmp    801d5f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	09 c2                	or     %eax,%edx
  801d46:	f6 c2 03             	test   $0x3,%dl
  801d49:	75 0f                	jne    801d5a <memmove+0x5f>
  801d4b:	f6 c1 03             	test   $0x3,%cl
  801d4e:	75 0a                	jne    801d5a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d50:	c1 e9 02             	shr    $0x2,%ecx
  801d53:	89 c7                	mov    %eax,%edi
  801d55:	fc                   	cld    
  801d56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d58:	eb 05                	jmp    801d5f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d5a:	89 c7                	mov    %eax,%edi
  801d5c:	fc                   	cld    
  801d5d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d5f:	5e                   	pop    %esi
  801d60:	5f                   	pop    %edi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    

00801d63 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d66:	ff 75 10             	pushl  0x10(%ebp)
  801d69:	ff 75 0c             	pushl  0xc(%ebp)
  801d6c:	ff 75 08             	pushl  0x8(%ebp)
  801d6f:	e8 87 ff ff ff       	call   801cfb <memmove>
}
  801d74:	c9                   	leave  
  801d75:	c3                   	ret    

00801d76 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	56                   	push   %esi
  801d7a:	53                   	push   %ebx
  801d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d81:	89 c6                	mov    %eax,%esi
  801d83:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d86:	eb 1a                	jmp    801da2 <memcmp+0x2c>
		if (*s1 != *s2)
  801d88:	0f b6 08             	movzbl (%eax),%ecx
  801d8b:	0f b6 1a             	movzbl (%edx),%ebx
  801d8e:	38 d9                	cmp    %bl,%cl
  801d90:	74 0a                	je     801d9c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d92:	0f b6 c1             	movzbl %cl,%eax
  801d95:	0f b6 db             	movzbl %bl,%ebx
  801d98:	29 d8                	sub    %ebx,%eax
  801d9a:	eb 0f                	jmp    801dab <memcmp+0x35>
		s1++, s2++;
  801d9c:	83 c0 01             	add    $0x1,%eax
  801d9f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801da2:	39 f0                	cmp    %esi,%eax
  801da4:	75 e2                	jne    801d88 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801da6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dab:	5b                   	pop    %ebx
  801dac:	5e                   	pop    %esi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    

00801daf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	53                   	push   %ebx
  801db3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801db6:	89 c1                	mov    %eax,%ecx
  801db8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801dbb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dbf:	eb 0a                	jmp    801dcb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc1:	0f b6 10             	movzbl (%eax),%edx
  801dc4:	39 da                	cmp    %ebx,%edx
  801dc6:	74 07                	je     801dcf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dc8:	83 c0 01             	add    $0x1,%eax
  801dcb:	39 c8                	cmp    %ecx,%eax
  801dcd:	72 f2                	jb     801dc1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dcf:	5b                   	pop    %ebx
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    

00801dd2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	57                   	push   %edi
  801dd6:	56                   	push   %esi
  801dd7:	53                   	push   %ebx
  801dd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dde:	eb 03                	jmp    801de3 <strtol+0x11>
		s++;
  801de0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801de3:	0f b6 01             	movzbl (%ecx),%eax
  801de6:	3c 20                	cmp    $0x20,%al
  801de8:	74 f6                	je     801de0 <strtol+0xe>
  801dea:	3c 09                	cmp    $0x9,%al
  801dec:	74 f2                	je     801de0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dee:	3c 2b                	cmp    $0x2b,%al
  801df0:	75 0a                	jne    801dfc <strtol+0x2a>
		s++;
  801df2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801df5:	bf 00 00 00 00       	mov    $0x0,%edi
  801dfa:	eb 11                	jmp    801e0d <strtol+0x3b>
  801dfc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e01:	3c 2d                	cmp    $0x2d,%al
  801e03:	75 08                	jne    801e0d <strtol+0x3b>
		s++, neg = 1;
  801e05:	83 c1 01             	add    $0x1,%ecx
  801e08:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e0d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e13:	75 15                	jne    801e2a <strtol+0x58>
  801e15:	80 39 30             	cmpb   $0x30,(%ecx)
  801e18:	75 10                	jne    801e2a <strtol+0x58>
  801e1a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e1e:	75 7c                	jne    801e9c <strtol+0xca>
		s += 2, base = 16;
  801e20:	83 c1 02             	add    $0x2,%ecx
  801e23:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e28:	eb 16                	jmp    801e40 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e2a:	85 db                	test   %ebx,%ebx
  801e2c:	75 12                	jne    801e40 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e2e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e33:	80 39 30             	cmpb   $0x30,(%ecx)
  801e36:	75 08                	jne    801e40 <strtol+0x6e>
		s++, base = 8;
  801e38:	83 c1 01             	add    $0x1,%ecx
  801e3b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e40:	b8 00 00 00 00       	mov    $0x0,%eax
  801e45:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e48:	0f b6 11             	movzbl (%ecx),%edx
  801e4b:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e4e:	89 f3                	mov    %esi,%ebx
  801e50:	80 fb 09             	cmp    $0x9,%bl
  801e53:	77 08                	ja     801e5d <strtol+0x8b>
			dig = *s - '0';
  801e55:	0f be d2             	movsbl %dl,%edx
  801e58:	83 ea 30             	sub    $0x30,%edx
  801e5b:	eb 22                	jmp    801e7f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e5d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e60:	89 f3                	mov    %esi,%ebx
  801e62:	80 fb 19             	cmp    $0x19,%bl
  801e65:	77 08                	ja     801e6f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e67:	0f be d2             	movsbl %dl,%edx
  801e6a:	83 ea 57             	sub    $0x57,%edx
  801e6d:	eb 10                	jmp    801e7f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e6f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e72:	89 f3                	mov    %esi,%ebx
  801e74:	80 fb 19             	cmp    $0x19,%bl
  801e77:	77 16                	ja     801e8f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e79:	0f be d2             	movsbl %dl,%edx
  801e7c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e7f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e82:	7d 0b                	jge    801e8f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e84:	83 c1 01             	add    $0x1,%ecx
  801e87:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e8b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e8d:	eb b9                	jmp    801e48 <strtol+0x76>

	if (endptr)
  801e8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e93:	74 0d                	je     801ea2 <strtol+0xd0>
		*endptr = (char *) s;
  801e95:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e98:	89 0e                	mov    %ecx,(%esi)
  801e9a:	eb 06                	jmp    801ea2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e9c:	85 db                	test   %ebx,%ebx
  801e9e:	74 98                	je     801e38 <strtol+0x66>
  801ea0:	eb 9e                	jmp    801e40 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ea2:	89 c2                	mov    %eax,%edx
  801ea4:	f7 da                	neg    %edx
  801ea6:	85 ff                	test   %edi,%edi
  801ea8:	0f 45 c2             	cmovne %edx,%eax
}
  801eab:	5b                   	pop    %ebx
  801eac:	5e                   	pop    %esi
  801ead:	5f                   	pop    %edi
  801eae:	5d                   	pop    %ebp
  801eaf:	c3                   	ret    

00801eb0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	56                   	push   %esi
  801eb4:	53                   	push   %ebx
  801eb5:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ebe:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801ec0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ec5:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801ec8:	83 ec 0c             	sub    $0xc,%esp
  801ecb:	50                   	push   %eax
  801ecc:	e8 60 e4 ff ff       	call   800331 <sys_ipc_recv>

	if (r < 0) {
  801ed1:	83 c4 10             	add    $0x10,%esp
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	79 16                	jns    801eee <ipc_recv+0x3e>
		if (from_env_store)
  801ed8:	85 f6                	test   %esi,%esi
  801eda:	74 06                	je     801ee2 <ipc_recv+0x32>
			*from_env_store = 0;
  801edc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801ee2:	85 db                	test   %ebx,%ebx
  801ee4:	74 2c                	je     801f12 <ipc_recv+0x62>
			*perm_store = 0;
  801ee6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801eec:	eb 24                	jmp    801f12 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801eee:	85 f6                	test   %esi,%esi
  801ef0:	74 0a                	je     801efc <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ef2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef7:	8b 40 74             	mov    0x74(%eax),%eax
  801efa:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801efc:	85 db                	test   %ebx,%ebx
  801efe:	74 0a                	je     801f0a <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801f00:	a1 08 40 80 00       	mov    0x804008,%eax
  801f05:	8b 40 78             	mov    0x78(%eax),%eax
  801f08:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801f0a:	a1 08 40 80 00       	mov    0x804008,%eax
  801f0f:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801f12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	57                   	push   %edi
  801f1d:	56                   	push   %esi
  801f1e:	53                   	push   %ebx
  801f1f:	83 ec 0c             	sub    $0xc,%esp
  801f22:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f25:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f2b:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f2d:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f32:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f35:	ff 75 14             	pushl  0x14(%ebp)
  801f38:	53                   	push   %ebx
  801f39:	56                   	push   %esi
  801f3a:	57                   	push   %edi
  801f3b:	e8 ce e3 ff ff       	call   80030e <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f40:	83 c4 10             	add    $0x10,%esp
  801f43:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f46:	75 07                	jne    801f4f <ipc_send+0x36>
			sys_yield();
  801f48:	e8 15 e2 ff ff       	call   800162 <sys_yield>
  801f4d:	eb e6                	jmp    801f35 <ipc_send+0x1c>
		} else if (r < 0) {
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	79 12                	jns    801f65 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f53:	50                   	push   %eax
  801f54:	68 20 27 80 00       	push   $0x802720
  801f59:	6a 51                	push   $0x51
  801f5b:	68 2d 27 80 00       	push   $0x80272d
  801f60:	e8 a6 f5 ff ff       	call   80150b <_panic>
		}
	}
}
  801f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5e                   	pop    %esi
  801f6a:	5f                   	pop    %edi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f78:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f7b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f81:	8b 52 50             	mov    0x50(%edx),%edx
  801f84:	39 ca                	cmp    %ecx,%edx
  801f86:	75 0d                	jne    801f95 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f88:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f8b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f90:	8b 40 48             	mov    0x48(%eax),%eax
  801f93:	eb 0f                	jmp    801fa4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f95:	83 c0 01             	add    $0x1,%eax
  801f98:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f9d:	75 d9                	jne    801f78 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fa4:	5d                   	pop    %ebp
  801fa5:	c3                   	ret    

00801fa6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fa6:	55                   	push   %ebp
  801fa7:	89 e5                	mov    %esp,%ebp
  801fa9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fac:	89 d0                	mov    %edx,%eax
  801fae:	c1 e8 16             	shr    $0x16,%eax
  801fb1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fb8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fbd:	f6 c1 01             	test   $0x1,%cl
  801fc0:	74 1d                	je     801fdf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fc2:	c1 ea 0c             	shr    $0xc,%edx
  801fc5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fcc:	f6 c2 01             	test   $0x1,%dl
  801fcf:	74 0e                	je     801fdf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd1:	c1 ea 0c             	shr    $0xc,%edx
  801fd4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fdb:	ef 
  801fdc:	0f b7 c0             	movzwl %ax,%eax
}
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    
  801fe1:	66 90                	xchg   %ax,%ax
  801fe3:	66 90                	xchg   %ax,%ax
  801fe5:	66 90                	xchg   %ax,%ax
  801fe7:	66 90                	xchg   %ax,%ax
  801fe9:	66 90                	xchg   %ax,%ax
  801feb:	66 90                	xchg   %ax,%ax
  801fed:	66 90                	xchg   %ax,%ax
  801fef:	90                   	nop

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
