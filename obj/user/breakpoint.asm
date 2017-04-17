
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 a6 04 00 00       	call   800530 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 6a 22 80 00       	push   $0x80226a
  800103:	6a 23                	push   $0x23
  800105:	68 87 22 80 00       	push   $0x802287
  80010a:	e8 d0 13 00 00       	call   8014df <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 6a 22 80 00       	push   $0x80226a
  800184:	6a 23                	push   $0x23
  800186:	68 87 22 80 00       	push   $0x802287
  80018b:	e8 4f 13 00 00       	call   8014df <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 6a 22 80 00       	push   $0x80226a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 87 22 80 00       	push   $0x802287
  8001cd:	e8 0d 13 00 00       	call   8014df <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 6a 22 80 00       	push   $0x80226a
  800208:	6a 23                	push   $0x23
  80020a:	68 87 22 80 00       	push   $0x802287
  80020f:	e8 cb 12 00 00       	call   8014df <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 6a 22 80 00       	push   $0x80226a
  80024a:	6a 23                	push   $0x23
  80024c:	68 87 22 80 00       	push   $0x802287
  800251:	e8 89 12 00 00       	call   8014df <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 6a 22 80 00       	push   $0x80226a
  80028c:	6a 23                	push   $0x23
  80028e:	68 87 22 80 00       	push   $0x802287
  800293:	e8 47 12 00 00       	call   8014df <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 6a 22 80 00       	push   $0x80226a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 87 22 80 00       	push   $0x802287
  8002d5:	e8 05 12 00 00       	call   8014df <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 6a 22 80 00       	push   $0x80226a
  800332:	6a 23                	push   $0x23
  800334:	68 87 22 80 00       	push   $0x802287
  800339:	e8 a1 11 00 00       	call   8014df <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	b8 0e 00 00 00       	mov    $0xe,%eax
  800356:	89 d1                	mov    %edx,%ecx
  800358:	89 d3                	mov    %edx,%ebx
  80035a:	89 d7                	mov    %edx,%edi
  80035c:	89 d6                	mov    %edx,%esi
  80035e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800368:	8b 45 08             	mov    0x8(%ebp),%eax
  80036b:	05 00 00 00 30       	add    $0x30000000,%eax
  800370:	c1 e8 0c             	shr    $0xc,%eax
}
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	05 00 00 00 30       	add    $0x30000000,%eax
  800380:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800385:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800392:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 16             	shr    $0x16,%edx
  80039c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	74 11                	je     8003b9 <fd_alloc+0x2d>
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 ea 0c             	shr    $0xc,%edx
  8003ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b4:	f6 c2 01             	test   $0x1,%dl
  8003b7:	75 09                	jne    8003c2 <fd_alloc+0x36>
			*fd_store = fd;
  8003b9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c0:	eb 17                	jmp    8003d9 <fd_alloc+0x4d>
  8003c2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003c7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003cc:	75 c9                	jne    800397 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ce:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e1:	83 f8 1f             	cmp    $0x1f,%eax
  8003e4:	77 36                	ja     80041c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003e6:	c1 e0 0c             	shl    $0xc,%eax
  8003e9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 16             	shr    $0x16,%edx
  8003f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 24                	je     800423 <fd_lookup+0x48>
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 0c             	shr    $0xc,%edx
  800404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 1a                	je     80042a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800410:	8b 55 0c             	mov    0xc(%ebp),%edx
  800413:	89 02                	mov    %eax,(%edx)
	return 0;
  800415:	b8 00 00 00 00       	mov    $0x0,%eax
  80041a:	eb 13                	jmp    80042f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800421:	eb 0c                	jmp    80042f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800428:	eb 05                	jmp    80042f <fd_lookup+0x54>
  80042a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043a:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80043f:	eb 13                	jmp    800454 <dev_lookup+0x23>
  800441:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800444:	39 08                	cmp    %ecx,(%eax)
  800446:	75 0c                	jne    800454 <dev_lookup+0x23>
			*dev = devtab[i];
  800448:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	eb 2e                	jmp    800482 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800454:	8b 02                	mov    (%edx),%eax
  800456:	85 c0                	test   %eax,%eax
  800458:	75 e7                	jne    800441 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045a:	a1 08 40 80 00       	mov    0x804008,%eax
  80045f:	8b 40 48             	mov    0x48(%eax),%eax
  800462:	83 ec 04             	sub    $0x4,%esp
  800465:	51                   	push   %ecx
  800466:	50                   	push   %eax
  800467:	68 98 22 80 00       	push   $0x802298
  80046c:	e8 47 11 00 00       	call   8015b8 <cprintf>
	*dev = 0;
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
  800474:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	83 ec 10             	sub    $0x10,%esp
  80048c:	8b 75 08             	mov    0x8(%ebp),%esi
  80048f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800492:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800495:	50                   	push   %eax
  800496:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80049c:	c1 e8 0c             	shr    $0xc,%eax
  80049f:	50                   	push   %eax
  8004a0:	e8 36 ff ff ff       	call   8003db <fd_lookup>
  8004a5:	83 c4 08             	add    $0x8,%esp
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	78 05                	js     8004b1 <fd_close+0x2d>
	    || fd != fd2)
  8004ac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004af:	74 0c                	je     8004bd <fd_close+0x39>
		return (must_exist ? r : 0);
  8004b1:	84 db                	test   %bl,%bl
  8004b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b8:	0f 44 c2             	cmove  %edx,%eax
  8004bb:	eb 41                	jmp    8004fe <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c3:	50                   	push   %eax
  8004c4:	ff 36                	pushl  (%esi)
  8004c6:	e8 66 ff ff ff       	call   800431 <dev_lookup>
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	78 1a                	js     8004ee <fd_close+0x6a>
		if (dev->dev_close)
  8004d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004da:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	74 0b                	je     8004ee <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004e3:	83 ec 0c             	sub    $0xc,%esp
  8004e6:	56                   	push   %esi
  8004e7:	ff d0                	call   *%eax
  8004e9:	89 c3                	mov    %eax,%ebx
  8004eb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	56                   	push   %esi
  8004f2:	6a 00                	push   $0x0
  8004f4:	e8 e1 fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	89 d8                	mov    %ebx,%eax
}
  8004fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800501:	5b                   	pop    %ebx
  800502:	5e                   	pop    %esi
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050e:	50                   	push   %eax
  80050f:	ff 75 08             	pushl  0x8(%ebp)
  800512:	e8 c4 fe ff ff       	call   8003db <fd_lookup>
  800517:	83 c4 08             	add    $0x8,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	78 10                	js     80052e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	6a 01                	push   $0x1
  800523:	ff 75 f4             	pushl  -0xc(%ebp)
  800526:	e8 59 ff ff ff       	call   800484 <fd_close>
  80052b:	83 c4 10             	add    $0x10,%esp
}
  80052e:	c9                   	leave  
  80052f:	c3                   	ret    

00800530 <close_all>:

void
close_all(void)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	53                   	push   %ebx
  800534:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053c:	83 ec 0c             	sub    $0xc,%esp
  80053f:	53                   	push   %ebx
  800540:	e8 c0 ff ff ff       	call   800505 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800545:	83 c3 01             	add    $0x1,%ebx
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	83 fb 20             	cmp    $0x20,%ebx
  80054e:	75 ec                	jne    80053c <close_all+0xc>
		close(i);
}
  800550:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800553:	c9                   	leave  
  800554:	c3                   	ret    

00800555 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	57                   	push   %edi
  800559:	56                   	push   %esi
  80055a:	53                   	push   %ebx
  80055b:	83 ec 2c             	sub    $0x2c,%esp
  80055e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800561:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800564:	50                   	push   %eax
  800565:	ff 75 08             	pushl  0x8(%ebp)
  800568:	e8 6e fe ff ff       	call   8003db <fd_lookup>
  80056d:	83 c4 08             	add    $0x8,%esp
  800570:	85 c0                	test   %eax,%eax
  800572:	0f 88 c1 00 00 00    	js     800639 <dup+0xe4>
		return r;
	close(newfdnum);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	56                   	push   %esi
  80057c:	e8 84 ff ff ff       	call   800505 <close>

	newfd = INDEX2FD(newfdnum);
  800581:	89 f3                	mov    %esi,%ebx
  800583:	c1 e3 0c             	shl    $0xc,%ebx
  800586:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80058c:	83 c4 04             	add    $0x4,%esp
  80058f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800592:	e8 de fd ff ff       	call   800375 <fd2data>
  800597:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800599:	89 1c 24             	mov    %ebx,(%esp)
  80059c:	e8 d4 fd ff ff       	call   800375 <fd2data>
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a7:	89 f8                	mov    %edi,%eax
  8005a9:	c1 e8 16             	shr    $0x16,%eax
  8005ac:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b3:	a8 01                	test   $0x1,%al
  8005b5:	74 37                	je     8005ee <dup+0x99>
  8005b7:	89 f8                	mov    %edi,%eax
  8005b9:	c1 e8 0c             	shr    $0xc,%eax
  8005bc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c3:	f6 c2 01             	test   $0x1,%dl
  8005c6:	74 26                	je     8005ee <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d7:	50                   	push   %eax
  8005d8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005db:	6a 00                	push   $0x0
  8005dd:	57                   	push   %edi
  8005de:	6a 00                	push   $0x0
  8005e0:	e8 b3 fb ff ff       	call   800198 <sys_page_map>
  8005e5:	89 c7                	mov    %eax,%edi
  8005e7:	83 c4 20             	add    $0x20,%esp
  8005ea:	85 c0                	test   %eax,%eax
  8005ec:	78 2e                	js     80061c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f1:	89 d0                	mov    %edx,%eax
  8005f3:	c1 e8 0c             	shr    $0xc,%eax
  8005f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fd:	83 ec 0c             	sub    $0xc,%esp
  800600:	25 07 0e 00 00       	and    $0xe07,%eax
  800605:	50                   	push   %eax
  800606:	53                   	push   %ebx
  800607:	6a 00                	push   $0x0
  800609:	52                   	push   %edx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 87 fb ff ff       	call   800198 <sys_page_map>
  800611:	89 c7                	mov    %eax,%edi
  800613:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800616:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800618:	85 ff                	test   %edi,%edi
  80061a:	79 1d                	jns    800639 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	6a 00                	push   $0x0
  800622:	e8 b3 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80062d:	6a 00                	push   $0x0
  80062f:	e8 a6 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	89 f8                	mov    %edi,%eax
}
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	53                   	push   %ebx
  800645:	83 ec 14             	sub    $0x14,%esp
  800648:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	53                   	push   %ebx
  800650:	e8 86 fd ff ff       	call   8003db <fd_lookup>
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	89 c2                	mov    %eax,%edx
  80065a:	85 c0                	test   %eax,%eax
  80065c:	78 6d                	js     8006cb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800664:	50                   	push   %eax
  800665:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800668:	ff 30                	pushl  (%eax)
  80066a:	e8 c2 fd ff ff       	call   800431 <dev_lookup>
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	85 c0                	test   %eax,%eax
  800674:	78 4c                	js     8006c2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800676:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800679:	8b 42 08             	mov    0x8(%edx),%eax
  80067c:	83 e0 03             	and    $0x3,%eax
  80067f:	83 f8 01             	cmp    $0x1,%eax
  800682:	75 21                	jne    8006a5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800684:	a1 08 40 80 00       	mov    0x804008,%eax
  800689:	8b 40 48             	mov    0x48(%eax),%eax
  80068c:	83 ec 04             	sub    $0x4,%esp
  80068f:	53                   	push   %ebx
  800690:	50                   	push   %eax
  800691:	68 d9 22 80 00       	push   $0x8022d9
  800696:	e8 1d 0f 00 00       	call   8015b8 <cprintf>
		return -E_INVAL;
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a3:	eb 26                	jmp    8006cb <read+0x8a>
	}
	if (!dev->dev_read)
  8006a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a8:	8b 40 08             	mov    0x8(%eax),%eax
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	74 17                	je     8006c6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006af:	83 ec 04             	sub    $0x4,%esp
  8006b2:	ff 75 10             	pushl  0x10(%ebp)
  8006b5:	ff 75 0c             	pushl  0xc(%ebp)
  8006b8:	52                   	push   %edx
  8006b9:	ff d0                	call   *%eax
  8006bb:	89 c2                	mov    %eax,%edx
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 09                	jmp    8006cb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c2:	89 c2                	mov    %eax,%edx
  8006c4:	eb 05                	jmp    8006cb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006cb:	89 d0                	mov    %edx,%eax
  8006cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d0:	c9                   	leave  
  8006d1:	c3                   	ret    

008006d2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	57                   	push   %edi
  8006d6:	56                   	push   %esi
  8006d7:	53                   	push   %ebx
  8006d8:	83 ec 0c             	sub    $0xc,%esp
  8006db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006de:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e6:	eb 21                	jmp    800709 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e8:	83 ec 04             	sub    $0x4,%esp
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	29 d8                	sub    %ebx,%eax
  8006ef:	50                   	push   %eax
  8006f0:	89 d8                	mov    %ebx,%eax
  8006f2:	03 45 0c             	add    0xc(%ebp),%eax
  8006f5:	50                   	push   %eax
  8006f6:	57                   	push   %edi
  8006f7:	e8 45 ff ff ff       	call   800641 <read>
		if (m < 0)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	85 c0                	test   %eax,%eax
  800701:	78 10                	js     800713 <readn+0x41>
			return m;
		if (m == 0)
  800703:	85 c0                	test   %eax,%eax
  800705:	74 0a                	je     800711 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800707:	01 c3                	add    %eax,%ebx
  800709:	39 f3                	cmp    %esi,%ebx
  80070b:	72 db                	jb     8006e8 <readn+0x16>
  80070d:	89 d8                	mov    %ebx,%eax
  80070f:	eb 02                	jmp    800713 <readn+0x41>
  800711:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5f                   	pop    %edi
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	83 ec 14             	sub    $0x14,%esp
  800722:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800725:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	53                   	push   %ebx
  80072a:	e8 ac fc ff ff       	call   8003db <fd_lookup>
  80072f:	83 c4 08             	add    $0x8,%esp
  800732:	89 c2                	mov    %eax,%edx
  800734:	85 c0                	test   %eax,%eax
  800736:	78 68                	js     8007a0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	ff 30                	pushl  (%eax)
  800744:	e8 e8 fc ff ff       	call   800431 <dev_lookup>
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	85 c0                	test   %eax,%eax
  80074e:	78 47                	js     800797 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800750:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800753:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800757:	75 21                	jne    80077a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800759:	a1 08 40 80 00       	mov    0x804008,%eax
  80075e:	8b 40 48             	mov    0x48(%eax),%eax
  800761:	83 ec 04             	sub    $0x4,%esp
  800764:	53                   	push   %ebx
  800765:	50                   	push   %eax
  800766:	68 f5 22 80 00       	push   $0x8022f5
  80076b:	e8 48 0e 00 00       	call   8015b8 <cprintf>
		return -E_INVAL;
  800770:	83 c4 10             	add    $0x10,%esp
  800773:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800778:	eb 26                	jmp    8007a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077d:	8b 52 0c             	mov    0xc(%edx),%edx
  800780:	85 d2                	test   %edx,%edx
  800782:	74 17                	je     80079b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800784:	83 ec 04             	sub    $0x4,%esp
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	50                   	push   %eax
  80078e:	ff d2                	call   *%edx
  800790:	89 c2                	mov    %eax,%edx
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 09                	jmp    8007a0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800797:	89 c2                	mov    %eax,%edx
  800799:	eb 05                	jmp    8007a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80079b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a0:	89 d0                	mov    %edx,%eax
  8007a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ad:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	ff 75 08             	pushl  0x8(%ebp)
  8007b4:	e8 22 fc ff ff       	call   8003db <fd_lookup>
  8007b9:	83 c4 08             	add    $0x8,%esp
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	78 0e                	js     8007ce <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	83 ec 14             	sub    $0x14,%esp
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	53                   	push   %ebx
  8007df:	e8 f7 fb ff ff       	call   8003db <fd_lookup>
  8007e4:	83 c4 08             	add    $0x8,%esp
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 65                	js     800852 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f3:	50                   	push   %eax
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	ff 30                	pushl  (%eax)
  8007f9:	e8 33 fc ff ff       	call   800431 <dev_lookup>
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	85 c0                	test   %eax,%eax
  800803:	78 44                	js     800849 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080c:	75 21                	jne    80082f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80080e:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800813:	8b 40 48             	mov    0x48(%eax),%eax
  800816:	83 ec 04             	sub    $0x4,%esp
  800819:	53                   	push   %ebx
  80081a:	50                   	push   %eax
  80081b:	68 b8 22 80 00       	push   $0x8022b8
  800820:	e8 93 0d 00 00       	call   8015b8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80082d:	eb 23                	jmp    800852 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80082f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800832:	8b 52 18             	mov    0x18(%edx),%edx
  800835:	85 d2                	test   %edx,%edx
  800837:	74 14                	je     80084d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	ff 75 0c             	pushl  0xc(%ebp)
  80083f:	50                   	push   %eax
  800840:	ff d2                	call   *%edx
  800842:	89 c2                	mov    %eax,%edx
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	eb 09                	jmp    800852 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800849:	89 c2                	mov    %eax,%edx
  80084b:	eb 05                	jmp    800852 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80084d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800852:	89 d0                	mov    %edx,%eax
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	83 ec 14             	sub    $0x14,%esp
  800860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800863:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800866:	50                   	push   %eax
  800867:	ff 75 08             	pushl  0x8(%ebp)
  80086a:	e8 6c fb ff ff       	call   8003db <fd_lookup>
  80086f:	83 c4 08             	add    $0x8,%esp
  800872:	89 c2                	mov    %eax,%edx
  800874:	85 c0                	test   %eax,%eax
  800876:	78 58                	js     8008d0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087e:	50                   	push   %eax
  80087f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800882:	ff 30                	pushl  (%eax)
  800884:	e8 a8 fb ff ff       	call   800431 <dev_lookup>
  800889:	83 c4 10             	add    $0x10,%esp
  80088c:	85 c0                	test   %eax,%eax
  80088e:	78 37                	js     8008c7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800893:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800897:	74 32                	je     8008cb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800899:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80089c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a3:	00 00 00 
	stat->st_isdir = 0;
  8008a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ad:	00 00 00 
	stat->st_dev = dev;
  8008b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8008bd:	ff 50 14             	call   *0x14(%eax)
  8008c0:	89 c2                	mov    %eax,%edx
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	eb 09                	jmp    8008d0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c7:	89 c2                	mov    %eax,%edx
  8008c9:	eb 05                	jmp    8008d0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d0:	89 d0                	mov    %edx,%eax
  8008d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	6a 00                	push   $0x0
  8008e1:	ff 75 08             	pushl  0x8(%ebp)
  8008e4:	e8 0c 02 00 00       	call   800af5 <open>
  8008e9:	89 c3                	mov    %eax,%ebx
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	78 1b                	js     80090d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f2:	83 ec 08             	sub    $0x8,%esp
  8008f5:	ff 75 0c             	pushl  0xc(%ebp)
  8008f8:	50                   	push   %eax
  8008f9:	e8 5b ff ff ff       	call   800859 <fstat>
  8008fe:	89 c6                	mov    %eax,%esi
	close(fd);
  800900:	89 1c 24             	mov    %ebx,(%esp)
  800903:	e8 fd fb ff ff       	call   800505 <close>
	return r;
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	89 f0                	mov    %esi,%eax
}
  80090d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	89 c6                	mov    %eax,%esi
  80091b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80091d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800924:	75 12                	jne    800938 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800926:	83 ec 0c             	sub    $0xc,%esp
  800929:	6a 01                	push   $0x1
  80092b:	e8 11 16 00 00       	call   801f41 <ipc_find_env>
  800930:	a3 00 40 80 00       	mov    %eax,0x804000
  800935:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800938:	6a 07                	push   $0x7
  80093a:	68 00 50 80 00       	push   $0x805000
  80093f:	56                   	push   %esi
  800940:	ff 35 00 40 80 00    	pushl  0x804000
  800946:	e8 a2 15 00 00       	call   801eed <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80094b:	83 c4 0c             	add    $0xc,%esp
  80094e:	6a 00                	push   $0x0
  800950:	53                   	push   %ebx
  800951:	6a 00                	push   $0x0
  800953:	e8 2c 15 00 00       	call   801e84 <ipc_recv>
}
  800958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 40 0c             	mov    0xc(%eax),%eax
  80096b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800970:	8b 45 0c             	mov    0xc(%ebp),%eax
  800973:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	b8 02 00 00 00       	mov    $0x2,%eax
  800982:	e8 8d ff ff ff       	call   800914 <fsipc>
}
  800987:	c9                   	leave  
  800988:	c3                   	ret    

00800989 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 40 0c             	mov    0xc(%eax),%eax
  800995:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
  80099f:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a4:	e8 6b ff ff ff       	call   800914 <fsipc>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	83 ec 04             	sub    $0x4,%esp
  8009b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ca:	e8 45 ff ff ff       	call   800914 <fsipc>
  8009cf:	85 c0                	test   %eax,%eax
  8009d1:	78 2c                	js     8009ff <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d3:	83 ec 08             	sub    $0x8,%esp
  8009d6:	68 00 50 80 00       	push   $0x805000
  8009db:	53                   	push   %ebx
  8009dc:	e8 5c 11 00 00       	call   801b3d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e1:	a1 80 50 80 00       	mov    0x805080,%eax
  8009e6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ec:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009f7:	83 c4 10             	add    $0x10,%esp
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	53                   	push   %ebx
  800a08:	83 ec 08             	sub    $0x8,%esp
  800a0b:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a11:	8b 52 0c             	mov    0xc(%edx),%edx
  800a14:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a1a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a1f:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a24:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a27:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a2d:	53                   	push   %ebx
  800a2e:	ff 75 0c             	pushl  0xc(%ebp)
  800a31:	68 08 50 80 00       	push   $0x805008
  800a36:	e8 94 12 00 00       	call   801ccf <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  800a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a40:	b8 04 00 00 00       	mov    $0x4,%eax
  800a45:	e8 ca fe ff ff       	call   800914 <fsipc>
  800a4a:	83 c4 10             	add    $0x10,%esp
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	78 1d                	js     800a6e <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  800a51:	39 d8                	cmp    %ebx,%eax
  800a53:	76 19                	jbe    800a6e <devfile_write+0x6a>
  800a55:	68 28 23 80 00       	push   $0x802328
  800a5a:	68 34 23 80 00       	push   $0x802334
  800a5f:	68 a3 00 00 00       	push   $0xa3
  800a64:	68 49 23 80 00       	push   $0x802349
  800a69:	e8 71 0a 00 00       	call   8014df <_panic>
	return r;
}
  800a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a81:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a86:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a91:	b8 03 00 00 00       	mov    $0x3,%eax
  800a96:	e8 79 fe ff ff       	call   800914 <fsipc>
  800a9b:	89 c3                	mov    %eax,%ebx
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	78 4b                	js     800aec <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa1:	39 c6                	cmp    %eax,%esi
  800aa3:	73 16                	jae    800abb <devfile_read+0x48>
  800aa5:	68 54 23 80 00       	push   $0x802354
  800aaa:	68 34 23 80 00       	push   $0x802334
  800aaf:	6a 7c                	push   $0x7c
  800ab1:	68 49 23 80 00       	push   $0x802349
  800ab6:	e8 24 0a 00 00       	call   8014df <_panic>
	assert(r <= PGSIZE);
  800abb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac0:	7e 16                	jle    800ad8 <devfile_read+0x65>
  800ac2:	68 5b 23 80 00       	push   $0x80235b
  800ac7:	68 34 23 80 00       	push   $0x802334
  800acc:	6a 7d                	push   $0x7d
  800ace:	68 49 23 80 00       	push   $0x802349
  800ad3:	e8 07 0a 00 00       	call   8014df <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad8:	83 ec 04             	sub    $0x4,%esp
  800adb:	50                   	push   %eax
  800adc:	68 00 50 80 00       	push   $0x805000
  800ae1:	ff 75 0c             	pushl  0xc(%ebp)
  800ae4:	e8 e6 11 00 00       	call   801ccf <memmove>
	return r;
  800ae9:	83 c4 10             	add    $0x10,%esp
}
  800aec:	89 d8                	mov    %ebx,%eax
  800aee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	53                   	push   %ebx
  800af9:	83 ec 20             	sub    $0x20,%esp
  800afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aff:	53                   	push   %ebx
  800b00:	e8 ff 0f 00 00       	call   801b04 <strlen>
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0d:	7f 67                	jg     800b76 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0f:	83 ec 0c             	sub    $0xc,%esp
  800b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b15:	50                   	push   %eax
  800b16:	e8 71 f8 ff ff       	call   80038c <fd_alloc>
  800b1b:	83 c4 10             	add    $0x10,%esp
		return r;
  800b1e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b20:	85 c0                	test   %eax,%eax
  800b22:	78 57                	js     800b7b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b24:	83 ec 08             	sub    $0x8,%esp
  800b27:	53                   	push   %ebx
  800b28:	68 00 50 80 00       	push   $0x805000
  800b2d:	e8 0b 10 00 00       	call   801b3d <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b42:	e8 cd fd ff ff       	call   800914 <fsipc>
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	83 c4 10             	add    $0x10,%esp
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	79 14                	jns    800b64 <open+0x6f>
		fd_close(fd, 0);
  800b50:	83 ec 08             	sub    $0x8,%esp
  800b53:	6a 00                	push   $0x0
  800b55:	ff 75 f4             	pushl  -0xc(%ebp)
  800b58:	e8 27 f9 ff ff       	call   800484 <fd_close>
		return r;
  800b5d:	83 c4 10             	add    $0x10,%esp
  800b60:	89 da                	mov    %ebx,%edx
  800b62:	eb 17                	jmp    800b7b <open+0x86>
	}

	return fd2num(fd);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6a:	e8 f6 f7 ff ff       	call   800365 <fd2num>
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	eb 05                	jmp    800b7b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b76:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b7b:	89 d0                	mov    %edx,%eax
  800b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b92:	e8 7d fd ff ff       	call   800914 <fsipc>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b9f:	68 67 23 80 00       	push   $0x802367
  800ba4:	ff 75 0c             	pushl  0xc(%ebp)
  800ba7:	e8 91 0f 00 00       	call   801b3d <strcpy>
	return 0;
}
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 10             	sub    $0x10,%esp
  800bba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bbd:	53                   	push   %ebx
  800bbe:	e8 b7 13 00 00       	call   801f7a <pageref>
  800bc3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bcb:	83 f8 01             	cmp    $0x1,%eax
  800bce:	75 10                	jne    800be0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	ff 73 0c             	pushl  0xc(%ebx)
  800bd6:	e8 c0 02 00 00       	call   800e9b <nsipc_close>
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800be0:	89 d0                	mov    %edx,%eax
  800be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bed:	6a 00                	push   $0x0
  800bef:	ff 75 10             	pushl  0x10(%ebp)
  800bf2:	ff 75 0c             	pushl  0xc(%ebp)
  800bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf8:	ff 70 0c             	pushl  0xc(%eax)
  800bfb:	e8 78 03 00 00       	call   800f78 <nsipc_send>
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c08:	6a 00                	push   $0x0
  800c0a:	ff 75 10             	pushl  0x10(%ebp)
  800c0d:	ff 75 0c             	pushl  0xc(%ebp)
  800c10:	8b 45 08             	mov    0x8(%ebp),%eax
  800c13:	ff 70 0c             	pushl  0xc(%eax)
  800c16:	e8 f1 02 00 00       	call   800f0c <nsipc_recv>
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c23:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c26:	52                   	push   %edx
  800c27:	50                   	push   %eax
  800c28:	e8 ae f7 ff ff       	call   8003db <fd_lookup>
  800c2d:	83 c4 10             	add    $0x10,%esp
  800c30:	85 c0                	test   %eax,%eax
  800c32:	78 17                	js     800c4b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c37:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c3d:	39 08                	cmp    %ecx,(%eax)
  800c3f:	75 05                	jne    800c46 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c41:	8b 40 0c             	mov    0xc(%eax),%eax
  800c44:	eb 05                	jmp    800c4b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c46:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 1c             	sub    $0x1c,%esp
  800c55:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c5a:	50                   	push   %eax
  800c5b:	e8 2c f7 ff ff       	call   80038c <fd_alloc>
  800c60:	89 c3                	mov    %eax,%ebx
  800c62:	83 c4 10             	add    $0x10,%esp
  800c65:	85 c0                	test   %eax,%eax
  800c67:	78 1b                	js     800c84 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c69:	83 ec 04             	sub    $0x4,%esp
  800c6c:	68 07 04 00 00       	push   $0x407
  800c71:	ff 75 f4             	pushl  -0xc(%ebp)
  800c74:	6a 00                	push   $0x0
  800c76:	e8 da f4 ff ff       	call   800155 <sys_page_alloc>
  800c7b:	89 c3                	mov    %eax,%ebx
  800c7d:	83 c4 10             	add    $0x10,%esp
  800c80:	85 c0                	test   %eax,%eax
  800c82:	79 10                	jns    800c94 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	56                   	push   %esi
  800c88:	e8 0e 02 00 00       	call   800e9b <nsipc_close>
		return r;
  800c8d:	83 c4 10             	add    $0x10,%esp
  800c90:	89 d8                	mov    %ebx,%eax
  800c92:	eb 24                	jmp    800cb8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c94:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ca9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	e8 b0 f6 ff ff       	call   800365 <fd2num>
  800cb5:	83 c4 10             	add    $0x10,%esp
}
  800cb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	e8 50 ff ff ff       	call   800c1d <fd2sockid>
		return r;
  800ccd:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	78 1f                	js     800cf2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cd3:	83 ec 04             	sub    $0x4,%esp
  800cd6:	ff 75 10             	pushl  0x10(%ebp)
  800cd9:	ff 75 0c             	pushl  0xc(%ebp)
  800cdc:	50                   	push   %eax
  800cdd:	e8 12 01 00 00       	call   800df4 <nsipc_accept>
  800ce2:	83 c4 10             	add    $0x10,%esp
		return r;
  800ce5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	78 07                	js     800cf2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800ceb:	e8 5d ff ff ff       	call   800c4d <alloc_sockfd>
  800cf0:	89 c1                	mov    %eax,%ecx
}
  800cf2:	89 c8                	mov    %ecx,%eax
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	e8 19 ff ff ff       	call   800c1d <fd2sockid>
  800d04:	85 c0                	test   %eax,%eax
  800d06:	78 12                	js     800d1a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d08:	83 ec 04             	sub    $0x4,%esp
  800d0b:	ff 75 10             	pushl  0x10(%ebp)
  800d0e:	ff 75 0c             	pushl  0xc(%ebp)
  800d11:	50                   	push   %eax
  800d12:	e8 2d 01 00 00       	call   800e44 <nsipc_bind>
  800d17:	83 c4 10             	add    $0x10,%esp
}
  800d1a:	c9                   	leave  
  800d1b:	c3                   	ret    

00800d1c <shutdown>:

int
shutdown(int s, int how)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d22:	8b 45 08             	mov    0x8(%ebp),%eax
  800d25:	e8 f3 fe ff ff       	call   800c1d <fd2sockid>
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	78 0f                	js     800d3d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d2e:	83 ec 08             	sub    $0x8,%esp
  800d31:	ff 75 0c             	pushl  0xc(%ebp)
  800d34:	50                   	push   %eax
  800d35:	e8 3f 01 00 00       	call   800e79 <nsipc_shutdown>
  800d3a:	83 c4 10             	add    $0x10,%esp
}
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	e8 d0 fe ff ff       	call   800c1d <fd2sockid>
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	78 12                	js     800d63 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	ff 75 10             	pushl  0x10(%ebp)
  800d57:	ff 75 0c             	pushl  0xc(%ebp)
  800d5a:	50                   	push   %eax
  800d5b:	e8 55 01 00 00       	call   800eb5 <nsipc_connect>
  800d60:	83 c4 10             	add    $0x10,%esp
}
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    

00800d65 <listen>:

int
listen(int s, int backlog)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	e8 aa fe ff ff       	call   800c1d <fd2sockid>
  800d73:	85 c0                	test   %eax,%eax
  800d75:	78 0f                	js     800d86 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d77:	83 ec 08             	sub    $0x8,%esp
  800d7a:	ff 75 0c             	pushl  0xc(%ebp)
  800d7d:	50                   	push   %eax
  800d7e:	e8 67 01 00 00       	call   800eea <nsipc_listen>
  800d83:	83 c4 10             	add    $0x10,%esp
}
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d8e:	ff 75 10             	pushl  0x10(%ebp)
  800d91:	ff 75 0c             	pushl  0xc(%ebp)
  800d94:	ff 75 08             	pushl  0x8(%ebp)
  800d97:	e8 3a 02 00 00       	call   800fd6 <nsipc_socket>
  800d9c:	83 c4 10             	add    $0x10,%esp
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	78 05                	js     800da8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800da3:	e8 a5 fe ff ff       	call   800c4d <alloc_sockfd>
}
  800da8:	c9                   	leave  
  800da9:	c3                   	ret    

00800daa <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	53                   	push   %ebx
  800dae:	83 ec 04             	sub    $0x4,%esp
  800db1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800db3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dba:	75 12                	jne    800dce <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dbc:	83 ec 0c             	sub    $0xc,%esp
  800dbf:	6a 02                	push   $0x2
  800dc1:	e8 7b 11 00 00       	call   801f41 <ipc_find_env>
  800dc6:	a3 04 40 80 00       	mov    %eax,0x804004
  800dcb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dce:	6a 07                	push   $0x7
  800dd0:	68 00 60 80 00       	push   $0x806000
  800dd5:	53                   	push   %ebx
  800dd6:	ff 35 04 40 80 00    	pushl  0x804004
  800ddc:	e8 0c 11 00 00       	call   801eed <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800de1:	83 c4 0c             	add    $0xc,%esp
  800de4:	6a 00                	push   $0x0
  800de6:	6a 00                	push   $0x0
  800de8:	6a 00                	push   $0x0
  800dea:	e8 95 10 00 00       	call   801e84 <ipc_recv>
}
  800def:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df2:	c9                   	leave  
  800df3:	c3                   	ret    

00800df4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e04:	8b 06                	mov    (%esi),%eax
  800e06:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800e10:	e8 95 ff ff ff       	call   800daa <nsipc>
  800e15:	89 c3                	mov    %eax,%ebx
  800e17:	85 c0                	test   %eax,%eax
  800e19:	78 20                	js     800e3b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e1b:	83 ec 04             	sub    $0x4,%esp
  800e1e:	ff 35 10 60 80 00    	pushl  0x806010
  800e24:	68 00 60 80 00       	push   $0x806000
  800e29:	ff 75 0c             	pushl  0xc(%ebp)
  800e2c:	e8 9e 0e 00 00       	call   801ccf <memmove>
		*addrlen = ret->ret_addrlen;
  800e31:	a1 10 60 80 00       	mov    0x806010,%eax
  800e36:	89 06                	mov    %eax,(%esi)
  800e38:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e3b:	89 d8                	mov    %ebx,%eax
  800e3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	53                   	push   %ebx
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e56:	53                   	push   %ebx
  800e57:	ff 75 0c             	pushl  0xc(%ebp)
  800e5a:	68 04 60 80 00       	push   $0x806004
  800e5f:	e8 6b 0e 00 00       	call   801ccf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e64:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800e6f:	e8 36 ff ff ff       	call   800daa <nsipc>
}
  800e74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e77:	c9                   	leave  
  800e78:	c3                   	ret    

00800e79 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e82:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e94:	e8 11 ff ff ff       	call   800daa <nsipc>
}
  800e99:	c9                   	leave  
  800e9a:	c3                   	ret    

00800e9b <nsipc_close>:

int
nsipc_close(int s)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea4:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ea9:	b8 04 00 00 00       	mov    $0x4,%eax
  800eae:	e8 f7 fe ff ff       	call   800daa <nsipc>
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ec7:	53                   	push   %ebx
  800ec8:	ff 75 0c             	pushl  0xc(%ebp)
  800ecb:	68 04 60 80 00       	push   $0x806004
  800ed0:	e8 fa 0d 00 00       	call   801ccf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ed5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800edb:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee0:	e8 c5 fe ff ff       	call   800daa <nsipc>
}
  800ee5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    

00800eea <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f00:	b8 06 00 00 00       	mov    $0x6,%eax
  800f05:	e8 a0 fe ff ff       	call   800daa <nsipc>
}
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f14:	8b 45 08             	mov    0x8(%ebp),%eax
  800f17:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f1c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f22:	8b 45 14             	mov    0x14(%ebp),%eax
  800f25:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f2a:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2f:	e8 76 fe ff ff       	call   800daa <nsipc>
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	85 c0                	test   %eax,%eax
  800f38:	78 35                	js     800f6f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f3a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f3f:	7f 04                	jg     800f45 <nsipc_recv+0x39>
  800f41:	39 c6                	cmp    %eax,%esi
  800f43:	7d 16                	jge    800f5b <nsipc_recv+0x4f>
  800f45:	68 73 23 80 00       	push   $0x802373
  800f4a:	68 34 23 80 00       	push   $0x802334
  800f4f:	6a 62                	push   $0x62
  800f51:	68 88 23 80 00       	push   $0x802388
  800f56:	e8 84 05 00 00       	call   8014df <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f5b:	83 ec 04             	sub    $0x4,%esp
  800f5e:	50                   	push   %eax
  800f5f:	68 00 60 80 00       	push   $0x806000
  800f64:	ff 75 0c             	pushl  0xc(%ebp)
  800f67:	e8 63 0d 00 00       	call   801ccf <memmove>
  800f6c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f6f:	89 d8                	mov    %ebx,%eax
  800f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	53                   	push   %ebx
  800f7c:	83 ec 04             	sub    $0x4,%esp
  800f7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f82:	8b 45 08             	mov    0x8(%ebp),%eax
  800f85:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f8a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f90:	7e 16                	jle    800fa8 <nsipc_send+0x30>
  800f92:	68 94 23 80 00       	push   $0x802394
  800f97:	68 34 23 80 00       	push   $0x802334
  800f9c:	6a 6d                	push   $0x6d
  800f9e:	68 88 23 80 00       	push   $0x802388
  800fa3:	e8 37 05 00 00       	call   8014df <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	53                   	push   %ebx
  800fac:	ff 75 0c             	pushl  0xc(%ebp)
  800faf:	68 0c 60 80 00       	push   $0x80600c
  800fb4:	e8 16 0d 00 00       	call   801ccf <memmove>
	nsipcbuf.send.req_size = size;
  800fb9:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fbf:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fc7:	b8 08 00 00 00       	mov    $0x8,%eax
  800fcc:	e8 d9 fd ff ff       	call   800daa <nsipc>
}
  800fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fec:	8b 45 10             	mov    0x10(%ebp),%eax
  800fef:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ff4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff9:	e8 ac fd ff ff       	call   800daa <nsipc>
}
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    

00801000 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	56                   	push   %esi
  801004:	53                   	push   %ebx
  801005:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	ff 75 08             	pushl  0x8(%ebp)
  80100e:	e8 62 f3 ff ff       	call   800375 <fd2data>
  801013:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801015:	83 c4 08             	add    $0x8,%esp
  801018:	68 a0 23 80 00       	push   $0x8023a0
  80101d:	53                   	push   %ebx
  80101e:	e8 1a 0b 00 00       	call   801b3d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801023:	8b 46 04             	mov    0x4(%esi),%eax
  801026:	2b 06                	sub    (%esi),%eax
  801028:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80102e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801035:	00 00 00 
	stat->st_dev = &devpipe;
  801038:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80103f:	30 80 00 
	return 0;
}
  801042:	b8 00 00 00 00       	mov    $0x0,%eax
  801047:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	53                   	push   %ebx
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801058:	53                   	push   %ebx
  801059:	6a 00                	push   $0x0
  80105b:	e8 7a f1 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801060:	89 1c 24             	mov    %ebx,(%esp)
  801063:	e8 0d f3 ff ff       	call   800375 <fd2data>
  801068:	83 c4 08             	add    $0x8,%esp
  80106b:	50                   	push   %eax
  80106c:	6a 00                	push   $0x0
  80106e:	e8 67 f1 ff ff       	call   8001da <sys_page_unmap>
}
  801073:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
  80107e:	83 ec 1c             	sub    $0x1c,%esp
  801081:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801084:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801086:	a1 08 40 80 00       	mov    0x804008,%eax
  80108b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	ff 75 e0             	pushl  -0x20(%ebp)
  801094:	e8 e1 0e 00 00       	call   801f7a <pageref>
  801099:	89 c3                	mov    %eax,%ebx
  80109b:	89 3c 24             	mov    %edi,(%esp)
  80109e:	e8 d7 0e 00 00       	call   801f7a <pageref>
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	39 c3                	cmp    %eax,%ebx
  8010a8:	0f 94 c1             	sete   %cl
  8010ab:	0f b6 c9             	movzbl %cl,%ecx
  8010ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010b1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010b7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010ba:	39 ce                	cmp    %ecx,%esi
  8010bc:	74 1b                	je     8010d9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010be:	39 c3                	cmp    %eax,%ebx
  8010c0:	75 c4                	jne    801086 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c2:	8b 42 58             	mov    0x58(%edx),%eax
  8010c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c8:	50                   	push   %eax
  8010c9:	56                   	push   %esi
  8010ca:	68 a7 23 80 00       	push   $0x8023a7
  8010cf:	e8 e4 04 00 00       	call   8015b8 <cprintf>
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	eb ad                	jmp    801086 <_pipeisclosed+0xe>
	}
}
  8010d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 28             	sub    $0x28,%esp
  8010ed:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010f0:	56                   	push   %esi
  8010f1:	e8 7f f2 ff ff       	call   800375 <fd2data>
  8010f6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	bf 00 00 00 00       	mov    $0x0,%edi
  801100:	eb 4b                	jmp    80114d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801102:	89 da                	mov    %ebx,%edx
  801104:	89 f0                	mov    %esi,%eax
  801106:	e8 6d ff ff ff       	call   801078 <_pipeisclosed>
  80110b:	85 c0                	test   %eax,%eax
  80110d:	75 48                	jne    801157 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80110f:	e8 22 f0 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801114:	8b 43 04             	mov    0x4(%ebx),%eax
  801117:	8b 0b                	mov    (%ebx),%ecx
  801119:	8d 51 20             	lea    0x20(%ecx),%edx
  80111c:	39 d0                	cmp    %edx,%eax
  80111e:	73 e2                	jae    801102 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801120:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801123:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801127:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 fa 1f             	sar    $0x1f,%edx
  80112f:	89 d1                	mov    %edx,%ecx
  801131:	c1 e9 1b             	shr    $0x1b,%ecx
  801134:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801137:	83 e2 1f             	and    $0x1f,%edx
  80113a:	29 ca                	sub    %ecx,%edx
  80113c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801140:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801144:	83 c0 01             	add    $0x1,%eax
  801147:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80114a:	83 c7 01             	add    $0x1,%edi
  80114d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801150:	75 c2                	jne    801114 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801152:	8b 45 10             	mov    0x10(%ebp),%eax
  801155:	eb 05                	jmp    80115c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80115c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 18             	sub    $0x18,%esp
  80116d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801170:	57                   	push   %edi
  801171:	e8 ff f1 ff ff       	call   800375 <fd2data>
  801176:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801180:	eb 3d                	jmp    8011bf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801182:	85 db                	test   %ebx,%ebx
  801184:	74 04                	je     80118a <devpipe_read+0x26>
				return i;
  801186:	89 d8                	mov    %ebx,%eax
  801188:	eb 44                	jmp    8011ce <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80118a:	89 f2                	mov    %esi,%edx
  80118c:	89 f8                	mov    %edi,%eax
  80118e:	e8 e5 fe ff ff       	call   801078 <_pipeisclosed>
  801193:	85 c0                	test   %eax,%eax
  801195:	75 32                	jne    8011c9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801197:	e8 9a ef ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80119c:	8b 06                	mov    (%esi),%eax
  80119e:	3b 46 04             	cmp    0x4(%esi),%eax
  8011a1:	74 df                	je     801182 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a3:	99                   	cltd   
  8011a4:	c1 ea 1b             	shr    $0x1b,%edx
  8011a7:	01 d0                	add    %edx,%eax
  8011a9:	83 e0 1f             	and    $0x1f,%eax
  8011ac:	29 d0                	sub    %edx,%eax
  8011ae:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011b9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011bc:	83 c3 01             	add    $0x1,%ebx
  8011bf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011c2:	75 d8                	jne    80119c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c7:	eb 05                	jmp    8011ce <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011c9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5f                   	pop    %edi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	e8 a5 f1 ff ff       	call   80038c <fd_alloc>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	0f 88 2c 01 00 00    	js     801320 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f4:	83 ec 04             	sub    $0x4,%esp
  8011f7:	68 07 04 00 00       	push   $0x407
  8011fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ff:	6a 00                	push   $0x0
  801201:	e8 4f ef ff ff       	call   800155 <sys_page_alloc>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	89 c2                	mov    %eax,%edx
  80120b:	85 c0                	test   %eax,%eax
  80120d:	0f 88 0d 01 00 00    	js     801320 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801213:	83 ec 0c             	sub    $0xc,%esp
  801216:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	e8 6d f1 ff ff       	call   80038c <fd_alloc>
  80121f:	89 c3                	mov    %eax,%ebx
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	0f 88 e2 00 00 00    	js     80130e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	68 07 04 00 00       	push   $0x407
  801234:	ff 75 f0             	pushl  -0x10(%ebp)
  801237:	6a 00                	push   $0x0
  801239:	e8 17 ef ff ff       	call   800155 <sys_page_alloc>
  80123e:	89 c3                	mov    %eax,%ebx
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	0f 88 c3 00 00 00    	js     80130e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80124b:	83 ec 0c             	sub    $0xc,%esp
  80124e:	ff 75 f4             	pushl  -0xc(%ebp)
  801251:	e8 1f f1 ff ff       	call   800375 <fd2data>
  801256:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801258:	83 c4 0c             	add    $0xc,%esp
  80125b:	68 07 04 00 00       	push   $0x407
  801260:	50                   	push   %eax
  801261:	6a 00                	push   $0x0
  801263:	e8 ed ee ff ff       	call   800155 <sys_page_alloc>
  801268:	89 c3                	mov    %eax,%ebx
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	0f 88 89 00 00 00    	js     8012fe <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801275:	83 ec 0c             	sub    $0xc,%esp
  801278:	ff 75 f0             	pushl  -0x10(%ebp)
  80127b:	e8 f5 f0 ff ff       	call   800375 <fd2data>
  801280:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801287:	50                   	push   %eax
  801288:	6a 00                	push   $0x0
  80128a:	56                   	push   %esi
  80128b:	6a 00                	push   $0x0
  80128d:	e8 06 ef ff ff       	call   800198 <sys_page_map>
  801292:	89 c3                	mov    %eax,%ebx
  801294:	83 c4 20             	add    $0x20,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 55                	js     8012f0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80129b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012b0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012be:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012cb:	e8 95 f0 ff ff       	call   800365 <fd2num>
  8012d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012d5:	83 c4 04             	add    $0x4,%esp
  8012d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8012db:	e8 85 f0 ff ff       	call   800365 <fd2num>
  8012e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ee:	eb 30                	jmp    801320 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	56                   	push   %esi
  8012f4:	6a 00                	push   $0x0
  8012f6:	e8 df ee ff ff       	call   8001da <sys_page_unmap>
  8012fb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	ff 75 f0             	pushl  -0x10(%ebp)
  801304:	6a 00                	push   $0x0
  801306:	e8 cf ee ff ff       	call   8001da <sys_page_unmap>
  80130b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	ff 75 f4             	pushl  -0xc(%ebp)
  801314:	6a 00                	push   $0x0
  801316:	e8 bf ee ff ff       	call   8001da <sys_page_unmap>
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801320:	89 d0                	mov    %edx,%eax
  801322:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    

00801329 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	ff 75 08             	pushl  0x8(%ebp)
  801336:	e8 a0 f0 ff ff       	call   8003db <fd_lookup>
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 18                	js     80135a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801342:	83 ec 0c             	sub    $0xc,%esp
  801345:	ff 75 f4             	pushl  -0xc(%ebp)
  801348:	e8 28 f0 ff ff       	call   800375 <fd2data>
	return _pipeisclosed(fd, p);
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801352:	e8 21 fd ff ff       	call   801078 <_pipeisclosed>
  801357:	83 c4 10             	add    $0x10,%esp
}
  80135a:	c9                   	leave  
  80135b:	c3                   	ret    

0080135c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80135f:	b8 00 00 00 00       	mov    $0x0,%eax
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80136c:	68 bf 23 80 00       	push   $0x8023bf
  801371:	ff 75 0c             	pushl  0xc(%ebp)
  801374:	e8 c4 07 00 00       	call   801b3d <strcpy>
	return 0;
}
  801379:	b8 00 00 00 00       	mov    $0x0,%eax
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	57                   	push   %edi
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
  801386:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80138c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801391:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801397:	eb 2d                	jmp    8013c6 <devcons_write+0x46>
		m = n - tot;
  801399:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80139c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80139e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013a1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013a6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a9:	83 ec 04             	sub    $0x4,%esp
  8013ac:	53                   	push   %ebx
  8013ad:	03 45 0c             	add    0xc(%ebp),%eax
  8013b0:	50                   	push   %eax
  8013b1:	57                   	push   %edi
  8013b2:	e8 18 09 00 00       	call   801ccf <memmove>
		sys_cputs(buf, m);
  8013b7:	83 c4 08             	add    $0x8,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	57                   	push   %edi
  8013bc:	e8 d8 ec ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c1:	01 de                	add    %ebx,%esi
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	89 f0                	mov    %esi,%eax
  8013c8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013cb:	72 cc                	jb     801399 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d0:	5b                   	pop    %ebx
  8013d1:	5e                   	pop    %esi
  8013d2:	5f                   	pop    %edi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	83 ec 08             	sub    $0x8,%esp
  8013db:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013e4:	74 2a                	je     801410 <devcons_read+0x3b>
  8013e6:	eb 05                	jmp    8013ed <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013e8:	e8 49 ed ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013ed:	e8 c5 ec ff ff       	call   8000b7 <sys_cgetc>
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	74 f2                	je     8013e8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 16                	js     801410 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013fa:	83 f8 04             	cmp    $0x4,%eax
  8013fd:	74 0c                	je     80140b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801402:	88 02                	mov    %al,(%edx)
	return 1;
  801404:	b8 01 00 00 00       	mov    $0x1,%eax
  801409:	eb 05                	jmp    801410 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80140b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801418:	8b 45 08             	mov    0x8(%ebp),%eax
  80141b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80141e:	6a 01                	push   $0x1
  801420:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	e8 70 ec ff ff       	call   800099 <sys_cputs>
}
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <getchar>:

int
getchar(void)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801434:	6a 01                	push   $0x1
  801436:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	6a 00                	push   $0x0
  80143c:	e8 00 f2 ff ff       	call   800641 <read>
	if (r < 0)
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	78 0f                	js     801457 <getchar+0x29>
		return r;
	if (r < 1)
  801448:	85 c0                	test   %eax,%eax
  80144a:	7e 06                	jle    801452 <getchar+0x24>
		return -E_EOF;
	return c;
  80144c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801450:	eb 05                	jmp    801457 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801452:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801457:	c9                   	leave  
  801458:	c3                   	ret    

00801459 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801462:	50                   	push   %eax
  801463:	ff 75 08             	pushl  0x8(%ebp)
  801466:	e8 70 ef ff ff       	call   8003db <fd_lookup>
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 11                	js     801483 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801475:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80147b:	39 10                	cmp    %edx,(%eax)
  80147d:	0f 94 c0             	sete   %al
  801480:	0f b6 c0             	movzbl %al,%eax
}
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <opencons>:

int
opencons(void)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80148b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	e8 f8 ee ff ff       	call   80038c <fd_alloc>
  801494:	83 c4 10             	add    $0x10,%esp
		return r;
  801497:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 3e                	js     8014db <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80149d:	83 ec 04             	sub    $0x4,%esp
  8014a0:	68 07 04 00 00       	push   $0x407
  8014a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a8:	6a 00                	push   $0x0
  8014aa:	e8 a6 ec ff ff       	call   800155 <sys_page_alloc>
  8014af:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 23                	js     8014db <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014b8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	50                   	push   %eax
  8014d1:	e8 8f ee ff ff       	call   800365 <fd2num>
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	83 c4 10             	add    $0x10,%esp
}
  8014db:	89 d0                	mov    %edx,%eax
  8014dd:	c9                   	leave  
  8014de:	c3                   	ret    

008014df <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	56                   	push   %esi
  8014e3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014e4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014e7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014ed:	e8 25 ec ff ff       	call   800117 <sys_getenvid>
  8014f2:	83 ec 0c             	sub    $0xc,%esp
  8014f5:	ff 75 0c             	pushl  0xc(%ebp)
  8014f8:	ff 75 08             	pushl  0x8(%ebp)
  8014fb:	56                   	push   %esi
  8014fc:	50                   	push   %eax
  8014fd:	68 cc 23 80 00       	push   $0x8023cc
  801502:	e8 b1 00 00 00       	call   8015b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801507:	83 c4 18             	add    $0x18,%esp
  80150a:	53                   	push   %ebx
  80150b:	ff 75 10             	pushl  0x10(%ebp)
  80150e:	e8 54 00 00 00       	call   801567 <vcprintf>
	cprintf("\n");
  801513:	c7 04 24 b8 23 80 00 	movl   $0x8023b8,(%esp)
  80151a:	e8 99 00 00 00       	call   8015b8 <cprintf>
  80151f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801522:	cc                   	int3   
  801523:	eb fd                	jmp    801522 <_panic+0x43>

00801525 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	53                   	push   %ebx
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80152f:	8b 13                	mov    (%ebx),%edx
  801531:	8d 42 01             	lea    0x1(%edx),%eax
  801534:	89 03                	mov    %eax,(%ebx)
  801536:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801539:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80153d:	3d ff 00 00 00       	cmp    $0xff,%eax
  801542:	75 1a                	jne    80155e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	68 ff 00 00 00       	push   $0xff
  80154c:	8d 43 08             	lea    0x8(%ebx),%eax
  80154f:	50                   	push   %eax
  801550:	e8 44 eb ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  801555:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80155b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80155e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801562:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801565:	c9                   	leave  
  801566:	c3                   	ret    

00801567 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801570:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801577:	00 00 00 
	b.cnt = 0;
  80157a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801581:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801584:	ff 75 0c             	pushl  0xc(%ebp)
  801587:	ff 75 08             	pushl  0x8(%ebp)
  80158a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	68 25 15 80 00       	push   $0x801525
  801596:	e8 54 01 00 00       	call   8016ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80159b:	83 c4 08             	add    $0x8,%esp
  80159e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015a4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	e8 e9 ea ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  8015b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015c1:	50                   	push   %eax
  8015c2:	ff 75 08             	pushl  0x8(%ebp)
  8015c5:	e8 9d ff ff ff       	call   801567 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	57                   	push   %edi
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 1c             	sub    $0x1c,%esp
  8015d5:	89 c7                	mov    %eax,%edi
  8015d7:	89 d6                	mov    %edx,%esi
  8015d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015f0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015f3:	39 d3                	cmp    %edx,%ebx
  8015f5:	72 05                	jb     8015fc <printnum+0x30>
  8015f7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015fa:	77 45                	ja     801641 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015fc:	83 ec 0c             	sub    $0xc,%esp
  8015ff:	ff 75 18             	pushl  0x18(%ebp)
  801602:	8b 45 14             	mov    0x14(%ebp),%eax
  801605:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801608:	53                   	push   %ebx
  801609:	ff 75 10             	pushl  0x10(%ebp)
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801612:	ff 75 e0             	pushl  -0x20(%ebp)
  801615:	ff 75 dc             	pushl  -0x24(%ebp)
  801618:	ff 75 d8             	pushl  -0x28(%ebp)
  80161b:	e8 a0 09 00 00       	call   801fc0 <__udivdi3>
  801620:	83 c4 18             	add    $0x18,%esp
  801623:	52                   	push   %edx
  801624:	50                   	push   %eax
  801625:	89 f2                	mov    %esi,%edx
  801627:	89 f8                	mov    %edi,%eax
  801629:	e8 9e ff ff ff       	call   8015cc <printnum>
  80162e:	83 c4 20             	add    $0x20,%esp
  801631:	eb 18                	jmp    80164b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	56                   	push   %esi
  801637:	ff 75 18             	pushl  0x18(%ebp)
  80163a:	ff d7                	call   *%edi
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	eb 03                	jmp    801644 <printnum+0x78>
  801641:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801644:	83 eb 01             	sub    $0x1,%ebx
  801647:	85 db                	test   %ebx,%ebx
  801649:	7f e8                	jg     801633 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	56                   	push   %esi
  80164f:	83 ec 04             	sub    $0x4,%esp
  801652:	ff 75 e4             	pushl  -0x1c(%ebp)
  801655:	ff 75 e0             	pushl  -0x20(%ebp)
  801658:	ff 75 dc             	pushl  -0x24(%ebp)
  80165b:	ff 75 d8             	pushl  -0x28(%ebp)
  80165e:	e8 8d 0a 00 00       	call   8020f0 <__umoddi3>
  801663:	83 c4 14             	add    $0x14,%esp
  801666:	0f be 80 ef 23 80 00 	movsbl 0x8023ef(%eax),%eax
  80166d:	50                   	push   %eax
  80166e:	ff d7                	call   *%edi
}
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801676:	5b                   	pop    %ebx
  801677:	5e                   	pop    %esi
  801678:	5f                   	pop    %edi
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80167e:	83 fa 01             	cmp    $0x1,%edx
  801681:	7e 0e                	jle    801691 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801683:	8b 10                	mov    (%eax),%edx
  801685:	8d 4a 08             	lea    0x8(%edx),%ecx
  801688:	89 08                	mov    %ecx,(%eax)
  80168a:	8b 02                	mov    (%edx),%eax
  80168c:	8b 52 04             	mov    0x4(%edx),%edx
  80168f:	eb 22                	jmp    8016b3 <getuint+0x38>
	else if (lflag)
  801691:	85 d2                	test   %edx,%edx
  801693:	74 10                	je     8016a5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801695:	8b 10                	mov    (%eax),%edx
  801697:	8d 4a 04             	lea    0x4(%edx),%ecx
  80169a:	89 08                	mov    %ecx,(%eax)
  80169c:	8b 02                	mov    (%edx),%eax
  80169e:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a3:	eb 0e                	jmp    8016b3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016a5:	8b 10                	mov    (%eax),%edx
  8016a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016aa:	89 08                	mov    %ecx,(%eax)
  8016ac:	8b 02                	mov    (%edx),%eax
  8016ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016bf:	8b 10                	mov    (%eax),%edx
  8016c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8016c4:	73 0a                	jae    8016d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016c9:	89 08                	mov    %ecx,(%eax)
  8016cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ce:	88 02                	mov    %al,(%edx)
}
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016db:	50                   	push   %eax
  8016dc:	ff 75 10             	pushl  0x10(%ebp)
  8016df:	ff 75 0c             	pushl  0xc(%ebp)
  8016e2:	ff 75 08             	pushl  0x8(%ebp)
  8016e5:	e8 05 00 00 00       	call   8016ef <vprintfmt>
	va_end(ap);
}
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	57                   	push   %edi
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 2c             	sub    $0x2c,%esp
  8016f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801701:	eb 12                	jmp    801715 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801703:	85 c0                	test   %eax,%eax
  801705:	0f 84 89 03 00 00    	je     801a94 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	53                   	push   %ebx
  80170f:	50                   	push   %eax
  801710:	ff d6                	call   *%esi
  801712:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801715:	83 c7 01             	add    $0x1,%edi
  801718:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80171c:	83 f8 25             	cmp    $0x25,%eax
  80171f:	75 e2                	jne    801703 <vprintfmt+0x14>
  801721:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801725:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80172c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801733:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80173a:	ba 00 00 00 00       	mov    $0x0,%edx
  80173f:	eb 07                	jmp    801748 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801741:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801744:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801748:	8d 47 01             	lea    0x1(%edi),%eax
  80174b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80174e:	0f b6 07             	movzbl (%edi),%eax
  801751:	0f b6 c8             	movzbl %al,%ecx
  801754:	83 e8 23             	sub    $0x23,%eax
  801757:	3c 55                	cmp    $0x55,%al
  801759:	0f 87 1a 03 00 00    	ja     801a79 <vprintfmt+0x38a>
  80175f:	0f b6 c0             	movzbl %al,%eax
  801762:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  801769:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80176c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801770:	eb d6                	jmp    801748 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801775:	b8 00 00 00 00       	mov    $0x0,%eax
  80177a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80177d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801780:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801784:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801787:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80178a:	83 fa 09             	cmp    $0x9,%edx
  80178d:	77 39                	ja     8017c8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80178f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801792:	eb e9                	jmp    80177d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801794:	8b 45 14             	mov    0x14(%ebp),%eax
  801797:	8d 48 04             	lea    0x4(%eax),%ecx
  80179a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80179d:	8b 00                	mov    (%eax),%eax
  80179f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017a5:	eb 27                	jmp    8017ce <vprintfmt+0xdf>
  8017a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017aa:	85 c0                	test   %eax,%eax
  8017ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017b1:	0f 49 c8             	cmovns %eax,%ecx
  8017b4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ba:	eb 8c                	jmp    801748 <vprintfmt+0x59>
  8017bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017bf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017c6:	eb 80                	jmp    801748 <vprintfmt+0x59>
  8017c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017cb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017d2:	0f 89 70 ff ff ff    	jns    801748 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017de:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017e5:	e9 5e ff ff ff       	jmp    801748 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017ea:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017f0:	e9 53 ff ff ff       	jmp    801748 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f8:	8d 50 04             	lea    0x4(%eax),%edx
  8017fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8017fe:	83 ec 08             	sub    $0x8,%esp
  801801:	53                   	push   %ebx
  801802:	ff 30                	pushl  (%eax)
  801804:	ff d6                	call   *%esi
			break;
  801806:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801809:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80180c:	e9 04 ff ff ff       	jmp    801715 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801811:	8b 45 14             	mov    0x14(%ebp),%eax
  801814:	8d 50 04             	lea    0x4(%eax),%edx
  801817:	89 55 14             	mov    %edx,0x14(%ebp)
  80181a:	8b 00                	mov    (%eax),%eax
  80181c:	99                   	cltd   
  80181d:	31 d0                	xor    %edx,%eax
  80181f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801821:	83 f8 0f             	cmp    $0xf,%eax
  801824:	7f 0b                	jg     801831 <vprintfmt+0x142>
  801826:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80182d:	85 d2                	test   %edx,%edx
  80182f:	75 18                	jne    801849 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801831:	50                   	push   %eax
  801832:	68 07 24 80 00       	push   $0x802407
  801837:	53                   	push   %ebx
  801838:	56                   	push   %esi
  801839:	e8 94 fe ff ff       	call   8016d2 <printfmt>
  80183e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801841:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801844:	e9 cc fe ff ff       	jmp    801715 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801849:	52                   	push   %edx
  80184a:	68 46 23 80 00       	push   $0x802346
  80184f:	53                   	push   %ebx
  801850:	56                   	push   %esi
  801851:	e8 7c fe ff ff       	call   8016d2 <printfmt>
  801856:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801859:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80185c:	e9 b4 fe ff ff       	jmp    801715 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801861:	8b 45 14             	mov    0x14(%ebp),%eax
  801864:	8d 50 04             	lea    0x4(%eax),%edx
  801867:	89 55 14             	mov    %edx,0x14(%ebp)
  80186a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80186c:	85 ff                	test   %edi,%edi
  80186e:	b8 00 24 80 00       	mov    $0x802400,%eax
  801873:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801876:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80187a:	0f 8e 94 00 00 00    	jle    801914 <vprintfmt+0x225>
  801880:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801884:	0f 84 98 00 00 00    	je     801922 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80188a:	83 ec 08             	sub    $0x8,%esp
  80188d:	ff 75 d0             	pushl  -0x30(%ebp)
  801890:	57                   	push   %edi
  801891:	e8 86 02 00 00       	call   801b1c <strnlen>
  801896:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801899:	29 c1                	sub    %eax,%ecx
  80189b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80189e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018a1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018a8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018ab:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ad:	eb 0f                	jmp    8018be <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	53                   	push   %ebx
  8018b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8018b6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b8:	83 ef 01             	sub    $0x1,%edi
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	85 ff                	test   %edi,%edi
  8018c0:	7f ed                	jg     8018af <vprintfmt+0x1c0>
  8018c2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018c5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018c8:	85 c9                	test   %ecx,%ecx
  8018ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cf:	0f 49 c1             	cmovns %ecx,%eax
  8018d2:	29 c1                	sub    %eax,%ecx
  8018d4:	89 75 08             	mov    %esi,0x8(%ebp)
  8018d7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018da:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018dd:	89 cb                	mov    %ecx,%ebx
  8018df:	eb 4d                	jmp    80192e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018e5:	74 1b                	je     801902 <vprintfmt+0x213>
  8018e7:	0f be c0             	movsbl %al,%eax
  8018ea:	83 e8 20             	sub    $0x20,%eax
  8018ed:	83 f8 5e             	cmp    $0x5e,%eax
  8018f0:	76 10                	jbe    801902 <vprintfmt+0x213>
					putch('?', putdat);
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	ff 75 0c             	pushl  0xc(%ebp)
  8018f8:	6a 3f                	push   $0x3f
  8018fa:	ff 55 08             	call   *0x8(%ebp)
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	eb 0d                	jmp    80190f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801902:	83 ec 08             	sub    $0x8,%esp
  801905:	ff 75 0c             	pushl  0xc(%ebp)
  801908:	52                   	push   %edx
  801909:	ff 55 08             	call   *0x8(%ebp)
  80190c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80190f:	83 eb 01             	sub    $0x1,%ebx
  801912:	eb 1a                	jmp    80192e <vprintfmt+0x23f>
  801914:	89 75 08             	mov    %esi,0x8(%ebp)
  801917:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80191a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80191d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801920:	eb 0c                	jmp    80192e <vprintfmt+0x23f>
  801922:	89 75 08             	mov    %esi,0x8(%ebp)
  801925:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801928:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80192b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80192e:	83 c7 01             	add    $0x1,%edi
  801931:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801935:	0f be d0             	movsbl %al,%edx
  801938:	85 d2                	test   %edx,%edx
  80193a:	74 23                	je     80195f <vprintfmt+0x270>
  80193c:	85 f6                	test   %esi,%esi
  80193e:	78 a1                	js     8018e1 <vprintfmt+0x1f2>
  801940:	83 ee 01             	sub    $0x1,%esi
  801943:	79 9c                	jns    8018e1 <vprintfmt+0x1f2>
  801945:	89 df                	mov    %ebx,%edi
  801947:	8b 75 08             	mov    0x8(%ebp),%esi
  80194a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80194d:	eb 18                	jmp    801967 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	53                   	push   %ebx
  801953:	6a 20                	push   $0x20
  801955:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801957:	83 ef 01             	sub    $0x1,%edi
  80195a:	83 c4 10             	add    $0x10,%esp
  80195d:	eb 08                	jmp    801967 <vprintfmt+0x278>
  80195f:	89 df                	mov    %ebx,%edi
  801961:	8b 75 08             	mov    0x8(%ebp),%esi
  801964:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801967:	85 ff                	test   %edi,%edi
  801969:	7f e4                	jg     80194f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80196b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80196e:	e9 a2 fd ff ff       	jmp    801715 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801973:	83 fa 01             	cmp    $0x1,%edx
  801976:	7e 16                	jle    80198e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801978:	8b 45 14             	mov    0x14(%ebp),%eax
  80197b:	8d 50 08             	lea    0x8(%eax),%edx
  80197e:	89 55 14             	mov    %edx,0x14(%ebp)
  801981:	8b 50 04             	mov    0x4(%eax),%edx
  801984:	8b 00                	mov    (%eax),%eax
  801986:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801989:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80198c:	eb 32                	jmp    8019c0 <vprintfmt+0x2d1>
	else if (lflag)
  80198e:	85 d2                	test   %edx,%edx
  801990:	74 18                	je     8019aa <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801992:	8b 45 14             	mov    0x14(%ebp),%eax
  801995:	8d 50 04             	lea    0x4(%eax),%edx
  801998:	89 55 14             	mov    %edx,0x14(%ebp)
  80199b:	8b 00                	mov    (%eax),%eax
  80199d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a0:	89 c1                	mov    %eax,%ecx
  8019a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8019a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019a8:	eb 16                	jmp    8019c0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ad:	8d 50 04             	lea    0x4(%eax),%edx
  8019b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b3:	8b 00                	mov    (%eax),%eax
  8019b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019b8:	89 c1                	mov    %eax,%ecx
  8019ba:	c1 f9 1f             	sar    $0x1f,%ecx
  8019bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019cb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019cf:	79 74                	jns    801a45 <vprintfmt+0x356>
				putch('-', putdat);
  8019d1:	83 ec 08             	sub    $0x8,%esp
  8019d4:	53                   	push   %ebx
  8019d5:	6a 2d                	push   $0x2d
  8019d7:	ff d6                	call   *%esi
				num = -(long long) num;
  8019d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019df:	f7 d8                	neg    %eax
  8019e1:	83 d2 00             	adc    $0x0,%edx
  8019e4:	f7 da                	neg    %edx
  8019e6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019ee:	eb 55                	jmp    801a45 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8019f3:	e8 83 fc ff ff       	call   80167b <getuint>
			base = 10;
  8019f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019fd:	eb 46                	jmp    801a45 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8019ff:	8d 45 14             	lea    0x14(%ebp),%eax
  801a02:	e8 74 fc ff ff       	call   80167b <getuint>
                        base = 8;
  801a07:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a0c:	eb 37                	jmp    801a45 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a0e:	83 ec 08             	sub    $0x8,%esp
  801a11:	53                   	push   %ebx
  801a12:	6a 30                	push   $0x30
  801a14:	ff d6                	call   *%esi
			putch('x', putdat);
  801a16:	83 c4 08             	add    $0x8,%esp
  801a19:	53                   	push   %ebx
  801a1a:	6a 78                	push   $0x78
  801a1c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a1e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a21:	8d 50 04             	lea    0x4(%eax),%edx
  801a24:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a27:	8b 00                	mov    (%eax),%eax
  801a29:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a2e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a31:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a36:	eb 0d                	jmp    801a45 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a38:	8d 45 14             	lea    0x14(%ebp),%eax
  801a3b:	e8 3b fc ff ff       	call   80167b <getuint>
			base = 16;
  801a40:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a4c:	57                   	push   %edi
  801a4d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a50:	51                   	push   %ecx
  801a51:	52                   	push   %edx
  801a52:	50                   	push   %eax
  801a53:	89 da                	mov    %ebx,%edx
  801a55:	89 f0                	mov    %esi,%eax
  801a57:	e8 70 fb ff ff       	call   8015cc <printnum>
			break;
  801a5c:	83 c4 20             	add    $0x20,%esp
  801a5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a62:	e9 ae fc ff ff       	jmp    801715 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	53                   	push   %ebx
  801a6b:	51                   	push   %ecx
  801a6c:	ff d6                	call   *%esi
			break;
  801a6e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a71:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a74:	e9 9c fc ff ff       	jmp    801715 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a79:	83 ec 08             	sub    $0x8,%esp
  801a7c:	53                   	push   %ebx
  801a7d:	6a 25                	push   $0x25
  801a7f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	eb 03                	jmp    801a89 <vprintfmt+0x39a>
  801a86:	83 ef 01             	sub    $0x1,%edi
  801a89:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a8d:	75 f7                	jne    801a86 <vprintfmt+0x397>
  801a8f:	e9 81 fc ff ff       	jmp    801715 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a97:	5b                   	pop    %ebx
  801a98:	5e                   	pop    %esi
  801a99:	5f                   	pop    %edi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 18             	sub    $0x18,%esp
  801aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aa8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801aaf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ab2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	74 26                	je     801ae3 <vsnprintf+0x47>
  801abd:	85 d2                	test   %edx,%edx
  801abf:	7e 22                	jle    801ae3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ac1:	ff 75 14             	pushl  0x14(%ebp)
  801ac4:	ff 75 10             	pushl  0x10(%ebp)
  801ac7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801aca:	50                   	push   %eax
  801acb:	68 b5 16 80 00       	push   $0x8016b5
  801ad0:	e8 1a fc ff ff       	call   8016ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ad5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ad8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	eb 05                	jmp    801ae8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ae3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801af0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801af3:	50                   	push   %eax
  801af4:	ff 75 10             	pushl  0x10(%ebp)
  801af7:	ff 75 0c             	pushl  0xc(%ebp)
  801afa:	ff 75 08             	pushl  0x8(%ebp)
  801afd:	e8 9a ff ff ff       	call   801a9c <vsnprintf>
	va_end(ap);

	return rc;
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0f:	eb 03                	jmp    801b14 <strlen+0x10>
		n++;
  801b11:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b14:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b18:	75 f7                	jne    801b11 <strlen+0xd>
		n++;
	return n;
}
  801b1a:	5d                   	pop    %ebp
  801b1b:	c3                   	ret    

00801b1c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b22:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b25:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2a:	eb 03                	jmp    801b2f <strnlen+0x13>
		n++;
  801b2c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b2f:	39 c2                	cmp    %eax,%edx
  801b31:	74 08                	je     801b3b <strnlen+0x1f>
  801b33:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b37:	75 f3                	jne    801b2c <strnlen+0x10>
  801b39:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	53                   	push   %ebx
  801b41:	8b 45 08             	mov    0x8(%ebp),%eax
  801b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b47:	89 c2                	mov    %eax,%edx
  801b49:	83 c2 01             	add    $0x1,%edx
  801b4c:	83 c1 01             	add    $0x1,%ecx
  801b4f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b53:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b56:	84 db                	test   %bl,%bl
  801b58:	75 ef                	jne    801b49 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b5a:	5b                   	pop    %ebx
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	53                   	push   %ebx
  801b61:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b64:	53                   	push   %ebx
  801b65:	e8 9a ff ff ff       	call   801b04 <strlen>
  801b6a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b6d:	ff 75 0c             	pushl  0xc(%ebp)
  801b70:	01 d8                	add    %ebx,%eax
  801b72:	50                   	push   %eax
  801b73:	e8 c5 ff ff ff       	call   801b3d <strcpy>
	return dst;
}
  801b78:	89 d8                	mov    %ebx,%eax
  801b7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	8b 75 08             	mov    0x8(%ebp),%esi
  801b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8a:	89 f3                	mov    %esi,%ebx
  801b8c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b8f:	89 f2                	mov    %esi,%edx
  801b91:	eb 0f                	jmp    801ba2 <strncpy+0x23>
		*dst++ = *src;
  801b93:	83 c2 01             	add    $0x1,%edx
  801b96:	0f b6 01             	movzbl (%ecx),%eax
  801b99:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b9c:	80 39 01             	cmpb   $0x1,(%ecx)
  801b9f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba2:	39 da                	cmp    %ebx,%edx
  801ba4:	75 ed                	jne    801b93 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ba6:	89 f0                	mov    %esi,%eax
  801ba8:	5b                   	pop    %ebx
  801ba9:	5e                   	pop    %esi
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    

00801bac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb7:	8b 55 10             	mov    0x10(%ebp),%edx
  801bba:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bbc:	85 d2                	test   %edx,%edx
  801bbe:	74 21                	je     801be1 <strlcpy+0x35>
  801bc0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bc4:	89 f2                	mov    %esi,%edx
  801bc6:	eb 09                	jmp    801bd1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bc8:	83 c2 01             	add    $0x1,%edx
  801bcb:	83 c1 01             	add    $0x1,%ecx
  801bce:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bd1:	39 c2                	cmp    %eax,%edx
  801bd3:	74 09                	je     801bde <strlcpy+0x32>
  801bd5:	0f b6 19             	movzbl (%ecx),%ebx
  801bd8:	84 db                	test   %bl,%bl
  801bda:	75 ec                	jne    801bc8 <strlcpy+0x1c>
  801bdc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bde:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801be1:	29 f0                	sub    %esi,%eax
}
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bed:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bf0:	eb 06                	jmp    801bf8 <strcmp+0x11>
		p++, q++;
  801bf2:	83 c1 01             	add    $0x1,%ecx
  801bf5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bf8:	0f b6 01             	movzbl (%ecx),%eax
  801bfb:	84 c0                	test   %al,%al
  801bfd:	74 04                	je     801c03 <strcmp+0x1c>
  801bff:	3a 02                	cmp    (%edx),%al
  801c01:	74 ef                	je     801bf2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c03:	0f b6 c0             	movzbl %al,%eax
  801c06:	0f b6 12             	movzbl (%edx),%edx
  801c09:	29 d0                	sub    %edx,%eax
}
  801c0b:	5d                   	pop    %ebp
  801c0c:	c3                   	ret    

00801c0d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	53                   	push   %ebx
  801c11:	8b 45 08             	mov    0x8(%ebp),%eax
  801c14:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c1c:	eb 06                	jmp    801c24 <strncmp+0x17>
		n--, p++, q++;
  801c1e:	83 c0 01             	add    $0x1,%eax
  801c21:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c24:	39 d8                	cmp    %ebx,%eax
  801c26:	74 15                	je     801c3d <strncmp+0x30>
  801c28:	0f b6 08             	movzbl (%eax),%ecx
  801c2b:	84 c9                	test   %cl,%cl
  801c2d:	74 04                	je     801c33 <strncmp+0x26>
  801c2f:	3a 0a                	cmp    (%edx),%cl
  801c31:	74 eb                	je     801c1e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c33:	0f b6 00             	movzbl (%eax),%eax
  801c36:	0f b6 12             	movzbl (%edx),%edx
  801c39:	29 d0                	sub    %edx,%eax
  801c3b:	eb 05                	jmp    801c42 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c3d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c42:	5b                   	pop    %ebx
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c4f:	eb 07                	jmp    801c58 <strchr+0x13>
		if (*s == c)
  801c51:	38 ca                	cmp    %cl,%dl
  801c53:	74 0f                	je     801c64 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c55:	83 c0 01             	add    $0x1,%eax
  801c58:	0f b6 10             	movzbl (%eax),%edx
  801c5b:	84 d2                	test   %dl,%dl
  801c5d:	75 f2                	jne    801c51 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c70:	eb 03                	jmp    801c75 <strfind+0xf>
  801c72:	83 c0 01             	add    $0x1,%eax
  801c75:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c78:	38 ca                	cmp    %cl,%dl
  801c7a:	74 04                	je     801c80 <strfind+0x1a>
  801c7c:	84 d2                	test   %dl,%dl
  801c7e:	75 f2                	jne    801c72 <strfind+0xc>
			break;
	return (char *) s;
}
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c8e:	85 c9                	test   %ecx,%ecx
  801c90:	74 36                	je     801cc8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c92:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c98:	75 28                	jne    801cc2 <memset+0x40>
  801c9a:	f6 c1 03             	test   $0x3,%cl
  801c9d:	75 23                	jne    801cc2 <memset+0x40>
		c &= 0xFF;
  801c9f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ca3:	89 d3                	mov    %edx,%ebx
  801ca5:	c1 e3 08             	shl    $0x8,%ebx
  801ca8:	89 d6                	mov    %edx,%esi
  801caa:	c1 e6 18             	shl    $0x18,%esi
  801cad:	89 d0                	mov    %edx,%eax
  801caf:	c1 e0 10             	shl    $0x10,%eax
  801cb2:	09 f0                	or     %esi,%eax
  801cb4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cb6:	89 d8                	mov    %ebx,%eax
  801cb8:	09 d0                	or     %edx,%eax
  801cba:	c1 e9 02             	shr    $0x2,%ecx
  801cbd:	fc                   	cld    
  801cbe:	f3 ab                	rep stos %eax,%es:(%edi)
  801cc0:	eb 06                	jmp    801cc8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc5:	fc                   	cld    
  801cc6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cc8:	89 f8                	mov    %edi,%eax
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5f                   	pop    %edi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	57                   	push   %edi
  801cd3:	56                   	push   %esi
  801cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cda:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cdd:	39 c6                	cmp    %eax,%esi
  801cdf:	73 35                	jae    801d16 <memmove+0x47>
  801ce1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ce4:	39 d0                	cmp    %edx,%eax
  801ce6:	73 2e                	jae    801d16 <memmove+0x47>
		s += n;
		d += n;
  801ce8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ceb:	89 d6                	mov    %edx,%esi
  801ced:	09 fe                	or     %edi,%esi
  801cef:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cf5:	75 13                	jne    801d0a <memmove+0x3b>
  801cf7:	f6 c1 03             	test   $0x3,%cl
  801cfa:	75 0e                	jne    801d0a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801cfc:	83 ef 04             	sub    $0x4,%edi
  801cff:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d02:	c1 e9 02             	shr    $0x2,%ecx
  801d05:	fd                   	std    
  801d06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d08:	eb 09                	jmp    801d13 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d0a:	83 ef 01             	sub    $0x1,%edi
  801d0d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d10:	fd                   	std    
  801d11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d13:	fc                   	cld    
  801d14:	eb 1d                	jmp    801d33 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d16:	89 f2                	mov    %esi,%edx
  801d18:	09 c2                	or     %eax,%edx
  801d1a:	f6 c2 03             	test   $0x3,%dl
  801d1d:	75 0f                	jne    801d2e <memmove+0x5f>
  801d1f:	f6 c1 03             	test   $0x3,%cl
  801d22:	75 0a                	jne    801d2e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d24:	c1 e9 02             	shr    $0x2,%ecx
  801d27:	89 c7                	mov    %eax,%edi
  801d29:	fc                   	cld    
  801d2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d2c:	eb 05                	jmp    801d33 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d2e:	89 c7                	mov    %eax,%edi
  801d30:	fc                   	cld    
  801d31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d33:	5e                   	pop    %esi
  801d34:	5f                   	pop    %edi
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    

00801d37 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d3a:	ff 75 10             	pushl  0x10(%ebp)
  801d3d:	ff 75 0c             	pushl  0xc(%ebp)
  801d40:	ff 75 08             	pushl  0x8(%ebp)
  801d43:	e8 87 ff ff ff       	call   801ccf <memmove>
}
  801d48:	c9                   	leave  
  801d49:	c3                   	ret    

00801d4a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d52:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d55:	89 c6                	mov    %eax,%esi
  801d57:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d5a:	eb 1a                	jmp    801d76 <memcmp+0x2c>
		if (*s1 != *s2)
  801d5c:	0f b6 08             	movzbl (%eax),%ecx
  801d5f:	0f b6 1a             	movzbl (%edx),%ebx
  801d62:	38 d9                	cmp    %bl,%cl
  801d64:	74 0a                	je     801d70 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d66:	0f b6 c1             	movzbl %cl,%eax
  801d69:	0f b6 db             	movzbl %bl,%ebx
  801d6c:	29 d8                	sub    %ebx,%eax
  801d6e:	eb 0f                	jmp    801d7f <memcmp+0x35>
		s1++, s2++;
  801d70:	83 c0 01             	add    $0x1,%eax
  801d73:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d76:	39 f0                	cmp    %esi,%eax
  801d78:	75 e2                	jne    801d5c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	53                   	push   %ebx
  801d87:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d8a:	89 c1                	mov    %eax,%ecx
  801d8c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d8f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d93:	eb 0a                	jmp    801d9f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d95:	0f b6 10             	movzbl (%eax),%edx
  801d98:	39 da                	cmp    %ebx,%edx
  801d9a:	74 07                	je     801da3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d9c:	83 c0 01             	add    $0x1,%eax
  801d9f:	39 c8                	cmp    %ecx,%eax
  801da1:	72 f2                	jb     801d95 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801da3:	5b                   	pop    %ebx
  801da4:	5d                   	pop    %ebp
  801da5:	c3                   	ret    

00801da6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	57                   	push   %edi
  801daa:	56                   	push   %esi
  801dab:	53                   	push   %ebx
  801dac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801daf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801db2:	eb 03                	jmp    801db7 <strtol+0x11>
		s++;
  801db4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801db7:	0f b6 01             	movzbl (%ecx),%eax
  801dba:	3c 20                	cmp    $0x20,%al
  801dbc:	74 f6                	je     801db4 <strtol+0xe>
  801dbe:	3c 09                	cmp    $0x9,%al
  801dc0:	74 f2                	je     801db4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dc2:	3c 2b                	cmp    $0x2b,%al
  801dc4:	75 0a                	jne    801dd0 <strtol+0x2a>
		s++;
  801dc6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dc9:	bf 00 00 00 00       	mov    $0x0,%edi
  801dce:	eb 11                	jmp    801de1 <strtol+0x3b>
  801dd0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dd5:	3c 2d                	cmp    $0x2d,%al
  801dd7:	75 08                	jne    801de1 <strtol+0x3b>
		s++, neg = 1;
  801dd9:	83 c1 01             	add    $0x1,%ecx
  801ddc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801de1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801de7:	75 15                	jne    801dfe <strtol+0x58>
  801de9:	80 39 30             	cmpb   $0x30,(%ecx)
  801dec:	75 10                	jne    801dfe <strtol+0x58>
  801dee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801df2:	75 7c                	jne    801e70 <strtol+0xca>
		s += 2, base = 16;
  801df4:	83 c1 02             	add    $0x2,%ecx
  801df7:	bb 10 00 00 00       	mov    $0x10,%ebx
  801dfc:	eb 16                	jmp    801e14 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801dfe:	85 db                	test   %ebx,%ebx
  801e00:	75 12                	jne    801e14 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e02:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e07:	80 39 30             	cmpb   $0x30,(%ecx)
  801e0a:	75 08                	jne    801e14 <strtol+0x6e>
		s++, base = 8;
  801e0c:	83 c1 01             	add    $0x1,%ecx
  801e0f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e14:	b8 00 00 00 00       	mov    $0x0,%eax
  801e19:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e1c:	0f b6 11             	movzbl (%ecx),%edx
  801e1f:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e22:	89 f3                	mov    %esi,%ebx
  801e24:	80 fb 09             	cmp    $0x9,%bl
  801e27:	77 08                	ja     801e31 <strtol+0x8b>
			dig = *s - '0';
  801e29:	0f be d2             	movsbl %dl,%edx
  801e2c:	83 ea 30             	sub    $0x30,%edx
  801e2f:	eb 22                	jmp    801e53 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e31:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e34:	89 f3                	mov    %esi,%ebx
  801e36:	80 fb 19             	cmp    $0x19,%bl
  801e39:	77 08                	ja     801e43 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e3b:	0f be d2             	movsbl %dl,%edx
  801e3e:	83 ea 57             	sub    $0x57,%edx
  801e41:	eb 10                	jmp    801e53 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e43:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e46:	89 f3                	mov    %esi,%ebx
  801e48:	80 fb 19             	cmp    $0x19,%bl
  801e4b:	77 16                	ja     801e63 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e4d:	0f be d2             	movsbl %dl,%edx
  801e50:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e53:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e56:	7d 0b                	jge    801e63 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e58:	83 c1 01             	add    $0x1,%ecx
  801e5b:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e5f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e61:	eb b9                	jmp    801e1c <strtol+0x76>

	if (endptr)
  801e63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e67:	74 0d                	je     801e76 <strtol+0xd0>
		*endptr = (char *) s;
  801e69:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e6c:	89 0e                	mov    %ecx,(%esi)
  801e6e:	eb 06                	jmp    801e76 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e70:	85 db                	test   %ebx,%ebx
  801e72:	74 98                	je     801e0c <strtol+0x66>
  801e74:	eb 9e                	jmp    801e14 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e76:	89 c2                	mov    %eax,%edx
  801e78:	f7 da                	neg    %edx
  801e7a:	85 ff                	test   %edi,%edi
  801e7c:	0f 45 c2             	cmovne %edx,%eax
}
  801e7f:	5b                   	pop    %ebx
  801e80:	5e                   	pop    %esi
  801e81:	5f                   	pop    %edi
  801e82:	5d                   	pop    %ebp
  801e83:	c3                   	ret    

00801e84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	56                   	push   %esi
  801e88:	53                   	push   %ebx
  801e89:	8b 75 08             	mov    0x8(%ebp),%esi
  801e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801e92:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801e94:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801e99:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801e9c:	83 ec 0c             	sub    $0xc,%esp
  801e9f:	50                   	push   %eax
  801ea0:	e8 60 e4 ff ff       	call   800305 <sys_ipc_recv>

	if (r < 0) {
  801ea5:	83 c4 10             	add    $0x10,%esp
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	79 16                	jns    801ec2 <ipc_recv+0x3e>
		if (from_env_store)
  801eac:	85 f6                	test   %esi,%esi
  801eae:	74 06                	je     801eb6 <ipc_recv+0x32>
			*from_env_store = 0;
  801eb0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801eb6:	85 db                	test   %ebx,%ebx
  801eb8:	74 2c                	je     801ee6 <ipc_recv+0x62>
			*perm_store = 0;
  801eba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ec0:	eb 24                	jmp    801ee6 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801ec2:	85 f6                	test   %esi,%esi
  801ec4:	74 0a                	je     801ed0 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ec6:	a1 08 40 80 00       	mov    0x804008,%eax
  801ecb:	8b 40 74             	mov    0x74(%eax),%eax
  801ece:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801ed0:	85 db                	test   %ebx,%ebx
  801ed2:	74 0a                	je     801ede <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801ed4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed9:	8b 40 78             	mov    0x78(%eax),%eax
  801edc:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801ede:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee3:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801ee6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee9:	5b                   	pop    %ebx
  801eea:	5e                   	pop    %esi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    

00801eed <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	57                   	push   %edi
  801ef1:	56                   	push   %esi
  801ef2:	53                   	push   %ebx
  801ef3:	83 ec 0c             	sub    $0xc,%esp
  801ef6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801eff:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f01:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f06:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f09:	ff 75 14             	pushl  0x14(%ebp)
  801f0c:	53                   	push   %ebx
  801f0d:	56                   	push   %esi
  801f0e:	57                   	push   %edi
  801f0f:	e8 ce e3 ff ff       	call   8002e2 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f14:	83 c4 10             	add    $0x10,%esp
  801f17:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1a:	75 07                	jne    801f23 <ipc_send+0x36>
			sys_yield();
  801f1c:	e8 15 e2 ff ff       	call   800136 <sys_yield>
  801f21:	eb e6                	jmp    801f09 <ipc_send+0x1c>
		} else if (r < 0) {
  801f23:	85 c0                	test   %eax,%eax
  801f25:	79 12                	jns    801f39 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f27:	50                   	push   %eax
  801f28:	68 00 27 80 00       	push   $0x802700
  801f2d:	6a 51                	push   $0x51
  801f2f:	68 0d 27 80 00       	push   $0x80270d
  801f34:	e8 a6 f5 ff ff       	call   8014df <_panic>
		}
	}
}
  801f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3c:	5b                   	pop    %ebx
  801f3d:	5e                   	pop    %esi
  801f3e:	5f                   	pop    %edi
  801f3f:	5d                   	pop    %ebp
  801f40:	c3                   	ret    

00801f41 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f47:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f4c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f4f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f55:	8b 52 50             	mov    0x50(%edx),%edx
  801f58:	39 ca                	cmp    %ecx,%edx
  801f5a:	75 0d                	jne    801f69 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f5c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f5f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f64:	8b 40 48             	mov    0x48(%eax),%eax
  801f67:	eb 0f                	jmp    801f78 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f69:	83 c0 01             	add    $0x1,%eax
  801f6c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f71:	75 d9                	jne    801f4c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    

00801f7a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f80:	89 d0                	mov    %edx,%eax
  801f82:	c1 e8 16             	shr    $0x16,%eax
  801f85:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f8c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f91:	f6 c1 01             	test   $0x1,%cl
  801f94:	74 1d                	je     801fb3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f96:	c1 ea 0c             	shr    $0xc,%edx
  801f99:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fa0:	f6 c2 01             	test   $0x1,%dl
  801fa3:	74 0e                	je     801fb3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa5:	c1 ea 0c             	shr    $0xc,%edx
  801fa8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801faf:	ef 
  801fb0:	0f b7 c0             	movzwl %ax,%eax
}
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    
  801fb5:	66 90                	xchg   %ax,%ax
  801fb7:	66 90                	xchg   %ax,%ax
  801fb9:	66 90                	xchg   %ax,%ax
  801fbb:	66 90                	xchg   %ax,%ax
  801fbd:	66 90                	xchg   %ax,%ax
  801fbf:	90                   	nop

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
