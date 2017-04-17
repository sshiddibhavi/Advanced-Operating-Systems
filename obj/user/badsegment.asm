
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 a6 04 00 00       	call   800535 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 6a 22 80 00       	push   $0x80226a
  800108:	6a 23                	push   $0x23
  80010a:	68 87 22 80 00       	push   $0x802287
  80010f:	e8 d0 13 00 00       	call   8014e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 6a 22 80 00       	push   $0x80226a
  800189:	6a 23                	push   $0x23
  80018b:	68 87 22 80 00       	push   $0x802287
  800190:	e8 4f 13 00 00       	call   8014e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 6a 22 80 00       	push   $0x80226a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 87 22 80 00       	push   $0x802287
  8001d2:	e8 0d 13 00 00       	call   8014e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 6a 22 80 00       	push   $0x80226a
  80020d:	6a 23                	push   $0x23
  80020f:	68 87 22 80 00       	push   $0x802287
  800214:	e8 cb 12 00 00       	call   8014e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 6a 22 80 00       	push   $0x80226a
  80024f:	6a 23                	push   $0x23
  800251:	68 87 22 80 00       	push   $0x802287
  800256:	e8 89 12 00 00       	call   8014e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 6a 22 80 00       	push   $0x80226a
  800291:	6a 23                	push   $0x23
  800293:	68 87 22 80 00       	push   $0x802287
  800298:	e8 47 12 00 00       	call   8014e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 6a 22 80 00       	push   $0x80226a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 87 22 80 00       	push   $0x802287
  8002da:	e8 05 12 00 00       	call   8014e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 6a 22 80 00       	push   $0x80226a
  800337:	6a 23                	push   $0x23
  800339:	68 87 22 80 00       	push   $0x802287
  80033e:	e8 a1 11 00 00       	call   8014e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035b:	89 d1                	mov    %edx,%ecx
  80035d:	89 d3                	mov    %edx,%ebx
  80035f:	89 d7                	mov    %edx,%edi
  800361:	89 d6                	mov    %edx,%esi
  800363:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	05 00 00 00 30       	add    $0x30000000,%eax
  800375:	c1 e8 0c             	shr    $0xc,%eax
}
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	05 00 00 00 30       	add    $0x30000000,%eax
  800385:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80038a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80039c:	89 c2                	mov    %eax,%edx
  80039e:	c1 ea 16             	shr    $0x16,%edx
  8003a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a8:	f6 c2 01             	test   $0x1,%dl
  8003ab:	74 11                	je     8003be <fd_alloc+0x2d>
  8003ad:	89 c2                	mov    %eax,%edx
  8003af:	c1 ea 0c             	shr    $0xc,%edx
  8003b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b9:	f6 c2 01             	test   $0x1,%dl
  8003bc:	75 09                	jne    8003c7 <fd_alloc+0x36>
			*fd_store = fd;
  8003be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	eb 17                	jmp    8003de <fd_alloc+0x4d>
  8003c7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003cc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d1:	75 c9                	jne    80039c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e6:	83 f8 1f             	cmp    $0x1f,%eax
  8003e9:	77 36                	ja     800421 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003eb:	c1 e0 0c             	shl    $0xc,%eax
  8003ee:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003f3:	89 c2                	mov    %eax,%edx
  8003f5:	c1 ea 16             	shr    $0x16,%edx
  8003f8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ff:	f6 c2 01             	test   $0x1,%dl
  800402:	74 24                	je     800428 <fd_lookup+0x48>
  800404:	89 c2                	mov    %eax,%edx
  800406:	c1 ea 0c             	shr    $0xc,%edx
  800409:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800410:	f6 c2 01             	test   $0x1,%dl
  800413:	74 1a                	je     80042f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800415:	8b 55 0c             	mov    0xc(%ebp),%edx
  800418:	89 02                	mov    %eax,(%edx)
	return 0;
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	eb 13                	jmp    800434 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800421:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800426:	eb 0c                	jmp    800434 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800428:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042d:	eb 05                	jmp    800434 <fd_lookup+0x54>
  80042f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043f:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800444:	eb 13                	jmp    800459 <dev_lookup+0x23>
  800446:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800449:	39 08                	cmp    %ecx,(%eax)
  80044b:	75 0c                	jne    800459 <dev_lookup+0x23>
			*dev = devtab[i];
  80044d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800450:	89 01                	mov    %eax,(%ecx)
			return 0;
  800452:	b8 00 00 00 00       	mov    $0x0,%eax
  800457:	eb 2e                	jmp    800487 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800459:	8b 02                	mov    (%edx),%eax
  80045b:	85 c0                	test   %eax,%eax
  80045d:	75 e7                	jne    800446 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045f:	a1 08 40 80 00       	mov    0x804008,%eax
  800464:	8b 40 48             	mov    0x48(%eax),%eax
  800467:	83 ec 04             	sub    $0x4,%esp
  80046a:	51                   	push   %ecx
  80046b:	50                   	push   %eax
  80046c:	68 98 22 80 00       	push   $0x802298
  800471:	e8 47 11 00 00       	call   8015bd <cprintf>
	*dev = 0;
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800487:	c9                   	leave  
  800488:	c3                   	ret    

00800489 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 10             	sub    $0x10,%esp
  800491:	8b 75 08             	mov    0x8(%ebp),%esi
  800494:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800497:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80049a:	50                   	push   %eax
  80049b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a1:	c1 e8 0c             	shr    $0xc,%eax
  8004a4:	50                   	push   %eax
  8004a5:	e8 36 ff ff ff       	call   8003e0 <fd_lookup>
  8004aa:	83 c4 08             	add    $0x8,%esp
  8004ad:	85 c0                	test   %eax,%eax
  8004af:	78 05                	js     8004b6 <fd_close+0x2d>
	    || fd != fd2)
  8004b1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b4:	74 0c                	je     8004c2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004b6:	84 db                	test   %bl,%bl
  8004b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004bd:	0f 44 c2             	cmove  %edx,%eax
  8004c0:	eb 41                	jmp    800503 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c8:	50                   	push   %eax
  8004c9:	ff 36                	pushl  (%esi)
  8004cb:	e8 66 ff ff ff       	call   800436 <dev_lookup>
  8004d0:	89 c3                	mov    %eax,%ebx
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	78 1a                	js     8004f3 <fd_close+0x6a>
		if (dev->dev_close)
  8004d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004dc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004df:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	74 0b                	je     8004f3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004e8:	83 ec 0c             	sub    $0xc,%esp
  8004eb:	56                   	push   %esi
  8004ec:	ff d0                	call   *%eax
  8004ee:	89 c3                	mov    %eax,%ebx
  8004f0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	56                   	push   %esi
  8004f7:	6a 00                	push   $0x0
  8004f9:	e8 e1 fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	89 d8                	mov    %ebx,%eax
}
  800503:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800506:	5b                   	pop    %ebx
  800507:	5e                   	pop    %esi
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800510:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800513:	50                   	push   %eax
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	e8 c4 fe ff ff       	call   8003e0 <fd_lookup>
  80051c:	83 c4 08             	add    $0x8,%esp
  80051f:	85 c0                	test   %eax,%eax
  800521:	78 10                	js     800533 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	6a 01                	push   $0x1
  800528:	ff 75 f4             	pushl  -0xc(%ebp)
  80052b:	e8 59 ff ff ff       	call   800489 <fd_close>
  800530:	83 c4 10             	add    $0x10,%esp
}
  800533:	c9                   	leave  
  800534:	c3                   	ret    

00800535 <close_all>:

void
close_all(void)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	53                   	push   %ebx
  800539:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80053c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800541:	83 ec 0c             	sub    $0xc,%esp
  800544:	53                   	push   %ebx
  800545:	e8 c0 ff ff ff       	call   80050a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80054a:	83 c3 01             	add    $0x1,%ebx
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	83 fb 20             	cmp    $0x20,%ebx
  800553:	75 ec                	jne    800541 <close_all+0xc>
		close(i);
}
  800555:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800558:	c9                   	leave  
  800559:	c3                   	ret    

0080055a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	57                   	push   %edi
  80055e:	56                   	push   %esi
  80055f:	53                   	push   %ebx
  800560:	83 ec 2c             	sub    $0x2c,%esp
  800563:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800566:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800569:	50                   	push   %eax
  80056a:	ff 75 08             	pushl  0x8(%ebp)
  80056d:	e8 6e fe ff ff       	call   8003e0 <fd_lookup>
  800572:	83 c4 08             	add    $0x8,%esp
  800575:	85 c0                	test   %eax,%eax
  800577:	0f 88 c1 00 00 00    	js     80063e <dup+0xe4>
		return r;
	close(newfdnum);
  80057d:	83 ec 0c             	sub    $0xc,%esp
  800580:	56                   	push   %esi
  800581:	e8 84 ff ff ff       	call   80050a <close>

	newfd = INDEX2FD(newfdnum);
  800586:	89 f3                	mov    %esi,%ebx
  800588:	c1 e3 0c             	shl    $0xc,%ebx
  80058b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800591:	83 c4 04             	add    $0x4,%esp
  800594:	ff 75 e4             	pushl  -0x1c(%ebp)
  800597:	e8 de fd ff ff       	call   80037a <fd2data>
  80059c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80059e:	89 1c 24             	mov    %ebx,(%esp)
  8005a1:	e8 d4 fd ff ff       	call   80037a <fd2data>
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ac:	89 f8                	mov    %edi,%eax
  8005ae:	c1 e8 16             	shr    $0x16,%eax
  8005b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b8:	a8 01                	test   $0x1,%al
  8005ba:	74 37                	je     8005f3 <dup+0x99>
  8005bc:	89 f8                	mov    %edi,%eax
  8005be:	c1 e8 0c             	shr    $0xc,%eax
  8005c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c8:	f6 c2 01             	test   $0x1,%dl
  8005cb:	74 26                	je     8005f3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d4:	83 ec 0c             	sub    $0xc,%esp
  8005d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005dc:	50                   	push   %eax
  8005dd:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e0:	6a 00                	push   $0x0
  8005e2:	57                   	push   %edi
  8005e3:	6a 00                	push   $0x0
  8005e5:	e8 b3 fb ff ff       	call   80019d <sys_page_map>
  8005ea:	89 c7                	mov    %eax,%edi
  8005ec:	83 c4 20             	add    $0x20,%esp
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	78 2e                	js     800621 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f6:	89 d0                	mov    %edx,%eax
  8005f8:	c1 e8 0c             	shr    $0xc,%eax
  8005fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800602:	83 ec 0c             	sub    $0xc,%esp
  800605:	25 07 0e 00 00       	and    $0xe07,%eax
  80060a:	50                   	push   %eax
  80060b:	53                   	push   %ebx
  80060c:	6a 00                	push   $0x0
  80060e:	52                   	push   %edx
  80060f:	6a 00                	push   $0x0
  800611:	e8 87 fb ff ff       	call   80019d <sys_page_map>
  800616:	89 c7                	mov    %eax,%edi
  800618:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80061b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061d:	85 ff                	test   %edi,%edi
  80061f:	79 1d                	jns    80063e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	6a 00                	push   $0x0
  800627:	e8 b3 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062c:	83 c4 08             	add    $0x8,%esp
  80062f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800632:	6a 00                	push   $0x0
  800634:	e8 a6 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	89 f8                	mov    %edi,%eax
}
  80063e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800641:	5b                   	pop    %ebx
  800642:	5e                   	pop    %esi
  800643:	5f                   	pop    %edi
  800644:	5d                   	pop    %ebp
  800645:	c3                   	ret    

00800646 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
  800649:	53                   	push   %ebx
  80064a:	83 ec 14             	sub    $0x14,%esp
  80064d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800650:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	53                   	push   %ebx
  800655:	e8 86 fd ff ff       	call   8003e0 <fd_lookup>
  80065a:	83 c4 08             	add    $0x8,%esp
  80065d:	89 c2                	mov    %eax,%edx
  80065f:	85 c0                	test   %eax,%eax
  800661:	78 6d                	js     8006d0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800669:	50                   	push   %eax
  80066a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80066d:	ff 30                	pushl  (%eax)
  80066f:	e8 c2 fd ff ff       	call   800436 <dev_lookup>
  800674:	83 c4 10             	add    $0x10,%esp
  800677:	85 c0                	test   %eax,%eax
  800679:	78 4c                	js     8006c7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80067b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80067e:	8b 42 08             	mov    0x8(%edx),%eax
  800681:	83 e0 03             	and    $0x3,%eax
  800684:	83 f8 01             	cmp    $0x1,%eax
  800687:	75 21                	jne    8006aa <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800689:	a1 08 40 80 00       	mov    0x804008,%eax
  80068e:	8b 40 48             	mov    0x48(%eax),%eax
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	53                   	push   %ebx
  800695:	50                   	push   %eax
  800696:	68 d9 22 80 00       	push   $0x8022d9
  80069b:	e8 1d 0f 00 00       	call   8015bd <cprintf>
		return -E_INVAL;
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a8:	eb 26                	jmp    8006d0 <read+0x8a>
	}
	if (!dev->dev_read)
  8006aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ad:	8b 40 08             	mov    0x8(%eax),%eax
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	74 17                	je     8006cb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b4:	83 ec 04             	sub    $0x4,%esp
  8006b7:	ff 75 10             	pushl  0x10(%ebp)
  8006ba:	ff 75 0c             	pushl  0xc(%ebp)
  8006bd:	52                   	push   %edx
  8006be:	ff d0                	call   *%eax
  8006c0:	89 c2                	mov    %eax,%edx
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 09                	jmp    8006d0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c7:	89 c2                	mov    %eax,%edx
  8006c9:	eb 05                	jmp    8006d0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d0:	89 d0                	mov    %edx,%eax
  8006d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	57                   	push   %edi
  8006db:	56                   	push   %esi
  8006dc:	53                   	push   %ebx
  8006dd:	83 ec 0c             	sub    $0xc,%esp
  8006e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006eb:	eb 21                	jmp    80070e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ed:	83 ec 04             	sub    $0x4,%esp
  8006f0:	89 f0                	mov    %esi,%eax
  8006f2:	29 d8                	sub    %ebx,%eax
  8006f4:	50                   	push   %eax
  8006f5:	89 d8                	mov    %ebx,%eax
  8006f7:	03 45 0c             	add    0xc(%ebp),%eax
  8006fa:	50                   	push   %eax
  8006fb:	57                   	push   %edi
  8006fc:	e8 45 ff ff ff       	call   800646 <read>
		if (m < 0)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	85 c0                	test   %eax,%eax
  800706:	78 10                	js     800718 <readn+0x41>
			return m;
		if (m == 0)
  800708:	85 c0                	test   %eax,%eax
  80070a:	74 0a                	je     800716 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070c:	01 c3                	add    %eax,%ebx
  80070e:	39 f3                	cmp    %esi,%ebx
  800710:	72 db                	jb     8006ed <readn+0x16>
  800712:	89 d8                	mov    %ebx,%eax
  800714:	eb 02                	jmp    800718 <readn+0x41>
  800716:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5f                   	pop    %edi
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	53                   	push   %ebx
  800724:	83 ec 14             	sub    $0x14,%esp
  800727:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	53                   	push   %ebx
  80072f:	e8 ac fc ff ff       	call   8003e0 <fd_lookup>
  800734:	83 c4 08             	add    $0x8,%esp
  800737:	89 c2                	mov    %eax,%edx
  800739:	85 c0                	test   %eax,%eax
  80073b:	78 68                	js     8007a5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80073d:	83 ec 08             	sub    $0x8,%esp
  800740:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800743:	50                   	push   %eax
  800744:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800747:	ff 30                	pushl  (%eax)
  800749:	e8 e8 fc ff ff       	call   800436 <dev_lookup>
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	85 c0                	test   %eax,%eax
  800753:	78 47                	js     80079c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800755:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800758:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80075c:	75 21                	jne    80077f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075e:	a1 08 40 80 00       	mov    0x804008,%eax
  800763:	8b 40 48             	mov    0x48(%eax),%eax
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	53                   	push   %ebx
  80076a:	50                   	push   %eax
  80076b:	68 f5 22 80 00       	push   $0x8022f5
  800770:	e8 48 0e 00 00       	call   8015bd <cprintf>
		return -E_INVAL;
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80077d:	eb 26                	jmp    8007a5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800782:	8b 52 0c             	mov    0xc(%edx),%edx
  800785:	85 d2                	test   %edx,%edx
  800787:	74 17                	je     8007a0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800789:	83 ec 04             	sub    $0x4,%esp
  80078c:	ff 75 10             	pushl  0x10(%ebp)
  80078f:	ff 75 0c             	pushl  0xc(%ebp)
  800792:	50                   	push   %eax
  800793:	ff d2                	call   *%edx
  800795:	89 c2                	mov    %eax,%edx
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	eb 09                	jmp    8007a5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079c:	89 c2                	mov    %eax,%edx
  80079e:	eb 05                	jmp    8007a5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a5:	89 d0                	mov    %edx,%eax
  8007a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007b2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b5:	50                   	push   %eax
  8007b6:	ff 75 08             	pushl  0x8(%ebp)
  8007b9:	e8 22 fc ff ff       	call   8003e0 <fd_lookup>
  8007be:	83 c4 08             	add    $0x8,%esp
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	78 0e                	js     8007d3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	83 ec 14             	sub    $0x14,%esp
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	53                   	push   %ebx
  8007e4:	e8 f7 fb ff ff       	call   8003e0 <fd_lookup>
  8007e9:	83 c4 08             	add    $0x8,%esp
  8007ec:	89 c2                	mov    %eax,%edx
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	78 65                	js     800857 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f2:	83 ec 08             	sub    $0x8,%esp
  8007f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f8:	50                   	push   %eax
  8007f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fc:	ff 30                	pushl  (%eax)
  8007fe:	e8 33 fc ff ff       	call   800436 <dev_lookup>
  800803:	83 c4 10             	add    $0x10,%esp
  800806:	85 c0                	test   %eax,%eax
  800808:	78 44                	js     80084e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80080a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800811:	75 21                	jne    800834 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800813:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800818:	8b 40 48             	mov    0x48(%eax),%eax
  80081b:	83 ec 04             	sub    $0x4,%esp
  80081e:	53                   	push   %ebx
  80081f:	50                   	push   %eax
  800820:	68 b8 22 80 00       	push   $0x8022b8
  800825:	e8 93 0d 00 00       	call   8015bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800832:	eb 23                	jmp    800857 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800834:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800837:	8b 52 18             	mov    0x18(%edx),%edx
  80083a:	85 d2                	test   %edx,%edx
  80083c:	74 14                	je     800852 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	ff 75 0c             	pushl  0xc(%ebp)
  800844:	50                   	push   %eax
  800845:	ff d2                	call   *%edx
  800847:	89 c2                	mov    %eax,%edx
  800849:	83 c4 10             	add    $0x10,%esp
  80084c:	eb 09                	jmp    800857 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084e:	89 c2                	mov    %eax,%edx
  800850:	eb 05                	jmp    800857 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800852:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800857:	89 d0                	mov    %edx,%eax
  800859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	53                   	push   %ebx
  800862:	83 ec 14             	sub    $0x14,%esp
  800865:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800868:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086b:	50                   	push   %eax
  80086c:	ff 75 08             	pushl  0x8(%ebp)
  80086f:	e8 6c fb ff ff       	call   8003e0 <fd_lookup>
  800874:	83 c4 08             	add    $0x8,%esp
  800877:	89 c2                	mov    %eax,%edx
  800879:	85 c0                	test   %eax,%eax
  80087b:	78 58                	js     8008d5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800887:	ff 30                	pushl  (%eax)
  800889:	e8 a8 fb ff ff       	call   800436 <dev_lookup>
  80088e:	83 c4 10             	add    $0x10,%esp
  800891:	85 c0                	test   %eax,%eax
  800893:	78 37                	js     8008cc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800895:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800898:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80089c:	74 32                	je     8008d0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80089e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a8:	00 00 00 
	stat->st_isdir = 0;
  8008ab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008b2:	00 00 00 
	stat->st_dev = dev;
  8008b5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008bb:	83 ec 08             	sub    $0x8,%esp
  8008be:	53                   	push   %ebx
  8008bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8008c2:	ff 50 14             	call   *0x14(%eax)
  8008c5:	89 c2                	mov    %eax,%edx
  8008c7:	83 c4 10             	add    $0x10,%esp
  8008ca:	eb 09                	jmp    8008d5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cc:	89 c2                	mov    %eax,%edx
  8008ce:	eb 05                	jmp    8008d5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d5:	89 d0                	mov    %edx,%eax
  8008d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    

008008dc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	56                   	push   %esi
  8008e0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	6a 00                	push   $0x0
  8008e6:	ff 75 08             	pushl  0x8(%ebp)
  8008e9:	e8 0c 02 00 00       	call   800afa <open>
  8008ee:	89 c3                	mov    %eax,%ebx
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	85 c0                	test   %eax,%eax
  8008f5:	78 1b                	js     800912 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	50                   	push   %eax
  8008fe:	e8 5b ff ff ff       	call   80085e <fstat>
  800903:	89 c6                	mov    %eax,%esi
	close(fd);
  800905:	89 1c 24             	mov    %ebx,(%esp)
  800908:	e8 fd fb ff ff       	call   80050a <close>
	return r;
  80090d:	83 c4 10             	add    $0x10,%esp
  800910:	89 f0                	mov    %esi,%eax
}
  800912:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
  80091e:	89 c6                	mov    %eax,%esi
  800920:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800922:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800929:	75 12                	jne    80093d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80092b:	83 ec 0c             	sub    $0xc,%esp
  80092e:	6a 01                	push   $0x1
  800930:	e8 11 16 00 00       	call   801f46 <ipc_find_env>
  800935:	a3 00 40 80 00       	mov    %eax,0x804000
  80093a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80093d:	6a 07                	push   $0x7
  80093f:	68 00 50 80 00       	push   $0x805000
  800944:	56                   	push   %esi
  800945:	ff 35 00 40 80 00    	pushl  0x804000
  80094b:	e8 a2 15 00 00       	call   801ef2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800950:	83 c4 0c             	add    $0xc,%esp
  800953:	6a 00                	push   $0x0
  800955:	53                   	push   %ebx
  800956:	6a 00                	push   $0x0
  800958:	e8 2c 15 00 00       	call   801e89 <ipc_recv>
}
  80095d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 40 0c             	mov    0xc(%eax),%eax
  800970:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80097d:	ba 00 00 00 00       	mov    $0x0,%edx
  800982:	b8 02 00 00 00       	mov    $0x2,%eax
  800987:	e8 8d ff ff ff       	call   800919 <fsipc>
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    

0080098e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 40 0c             	mov    0xc(%eax),%eax
  80099a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099f:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a9:	e8 6b ff ff ff       	call   800919 <fsipc>
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	53                   	push   %ebx
  8009b4:	83 ec 04             	sub    $0x4,%esp
  8009b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8009cf:	e8 45 ff ff ff       	call   800919 <fsipc>
  8009d4:	85 c0                	test   %eax,%eax
  8009d6:	78 2c                	js     800a04 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d8:	83 ec 08             	sub    $0x8,%esp
  8009db:	68 00 50 80 00       	push   $0x805000
  8009e0:	53                   	push   %ebx
  8009e1:	e8 5c 11 00 00       	call   801b42 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009eb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009fc:	83 c4 10             	add    $0x10,%esp
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	53                   	push   %ebx
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
  800a16:	8b 52 0c             	mov    0xc(%edx),%edx
  800a19:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a1f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a24:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a29:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a2c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a32:	53                   	push   %ebx
  800a33:	ff 75 0c             	pushl  0xc(%ebp)
  800a36:	68 08 50 80 00       	push   $0x805008
  800a3b:	e8 94 12 00 00       	call   801cd4 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  800a40:	ba 00 00 00 00       	mov    $0x0,%edx
  800a45:	b8 04 00 00 00       	mov    $0x4,%eax
  800a4a:	e8 ca fe ff ff       	call   800919 <fsipc>
  800a4f:	83 c4 10             	add    $0x10,%esp
  800a52:	85 c0                	test   %eax,%eax
  800a54:	78 1d                	js     800a73 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  800a56:	39 d8                	cmp    %ebx,%eax
  800a58:	76 19                	jbe    800a73 <devfile_write+0x6a>
  800a5a:	68 28 23 80 00       	push   $0x802328
  800a5f:	68 34 23 80 00       	push   $0x802334
  800a64:	68 a3 00 00 00       	push   $0xa3
  800a69:	68 49 23 80 00       	push   $0x802349
  800a6e:	e8 71 0a 00 00       	call   8014e4 <_panic>
	return r;
}
  800a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 40 0c             	mov    0xc(%eax),%eax
  800a86:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9b:	e8 79 fe ff ff       	call   800919 <fsipc>
  800aa0:	89 c3                	mov    %eax,%ebx
  800aa2:	85 c0                	test   %eax,%eax
  800aa4:	78 4b                	js     800af1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa6:	39 c6                	cmp    %eax,%esi
  800aa8:	73 16                	jae    800ac0 <devfile_read+0x48>
  800aaa:	68 54 23 80 00       	push   $0x802354
  800aaf:	68 34 23 80 00       	push   $0x802334
  800ab4:	6a 7c                	push   $0x7c
  800ab6:	68 49 23 80 00       	push   $0x802349
  800abb:	e8 24 0a 00 00       	call   8014e4 <_panic>
	assert(r <= PGSIZE);
  800ac0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac5:	7e 16                	jle    800add <devfile_read+0x65>
  800ac7:	68 5b 23 80 00       	push   $0x80235b
  800acc:	68 34 23 80 00       	push   $0x802334
  800ad1:	6a 7d                	push   $0x7d
  800ad3:	68 49 23 80 00       	push   $0x802349
  800ad8:	e8 07 0a 00 00       	call   8014e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800add:	83 ec 04             	sub    $0x4,%esp
  800ae0:	50                   	push   %eax
  800ae1:	68 00 50 80 00       	push   $0x805000
  800ae6:	ff 75 0c             	pushl  0xc(%ebp)
  800ae9:	e8 e6 11 00 00       	call   801cd4 <memmove>
	return r;
  800aee:	83 c4 10             	add    $0x10,%esp
}
  800af1:	89 d8                	mov    %ebx,%eax
  800af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	83 ec 20             	sub    $0x20,%esp
  800b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b04:	53                   	push   %ebx
  800b05:	e8 ff 0f 00 00       	call   801b09 <strlen>
  800b0a:	83 c4 10             	add    $0x10,%esp
  800b0d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b12:	7f 67                	jg     800b7b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1a:	50                   	push   %eax
  800b1b:	e8 71 f8 ff ff       	call   800391 <fd_alloc>
  800b20:	83 c4 10             	add    $0x10,%esp
		return r;
  800b23:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	78 57                	js     800b80 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b29:	83 ec 08             	sub    $0x8,%esp
  800b2c:	53                   	push   %ebx
  800b2d:	68 00 50 80 00       	push   $0x805000
  800b32:	e8 0b 10 00 00       	call   801b42 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b42:	b8 01 00 00 00       	mov    $0x1,%eax
  800b47:	e8 cd fd ff ff       	call   800919 <fsipc>
  800b4c:	89 c3                	mov    %eax,%ebx
  800b4e:	83 c4 10             	add    $0x10,%esp
  800b51:	85 c0                	test   %eax,%eax
  800b53:	79 14                	jns    800b69 <open+0x6f>
		fd_close(fd, 0);
  800b55:	83 ec 08             	sub    $0x8,%esp
  800b58:	6a 00                	push   $0x0
  800b5a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5d:	e8 27 f9 ff ff       	call   800489 <fd_close>
		return r;
  800b62:	83 c4 10             	add    $0x10,%esp
  800b65:	89 da                	mov    %ebx,%edx
  800b67:	eb 17                	jmp    800b80 <open+0x86>
	}

	return fd2num(fd);
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6f:	e8 f6 f7 ff ff       	call   80036a <fd2num>
  800b74:	89 c2                	mov    %eax,%edx
  800b76:	83 c4 10             	add    $0x10,%esp
  800b79:	eb 05                	jmp    800b80 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b80:	89 d0                	mov    %edx,%eax
  800b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 08 00 00 00       	mov    $0x8,%eax
  800b97:	e8 7d fd ff ff       	call   800919 <fsipc>
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba4:	68 67 23 80 00       	push   $0x802367
  800ba9:	ff 75 0c             	pushl  0xc(%ebp)
  800bac:	e8 91 0f 00 00       	call   801b42 <strcpy>
	return 0;
}
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 10             	sub    $0x10,%esp
  800bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc2:	53                   	push   %ebx
  800bc3:	e8 b7 13 00 00       	call   801f7f <pageref>
  800bc8:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd0:	83 f8 01             	cmp    $0x1,%eax
  800bd3:	75 10                	jne    800be5 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	ff 73 0c             	pushl  0xc(%ebx)
  800bdb:	e8 c0 02 00 00       	call   800ea0 <nsipc_close>
  800be0:	89 c2                	mov    %eax,%edx
  800be2:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800be5:	89 d0                	mov    %edx,%eax
  800be7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf2:	6a 00                	push   $0x0
  800bf4:	ff 75 10             	pushl  0x10(%ebp)
  800bf7:	ff 75 0c             	pushl  0xc(%ebp)
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	ff 70 0c             	pushl  0xc(%eax)
  800c00:	e8 78 03 00 00       	call   800f7d <nsipc_send>
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c0d:	6a 00                	push   $0x0
  800c0f:	ff 75 10             	pushl  0x10(%ebp)
  800c12:	ff 75 0c             	pushl  0xc(%ebp)
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	ff 70 0c             	pushl  0xc(%eax)
  800c1b:	e8 f1 02 00 00       	call   800f11 <nsipc_recv>
}
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c28:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c2b:	52                   	push   %edx
  800c2c:	50                   	push   %eax
  800c2d:	e8 ae f7 ff ff       	call   8003e0 <fd_lookup>
  800c32:	83 c4 10             	add    $0x10,%esp
  800c35:	85 c0                	test   %eax,%eax
  800c37:	78 17                	js     800c50 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c42:	39 08                	cmp    %ecx,(%eax)
  800c44:	75 05                	jne    800c4b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c46:	8b 40 0c             	mov    0xc(%eax),%eax
  800c49:	eb 05                	jmp    800c50 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c4b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 1c             	sub    $0x1c,%esp
  800c5a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c5f:	50                   	push   %eax
  800c60:	e8 2c f7 ff ff       	call   800391 <fd_alloc>
  800c65:	89 c3                	mov    %eax,%ebx
  800c67:	83 c4 10             	add    $0x10,%esp
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	78 1b                	js     800c89 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c6e:	83 ec 04             	sub    $0x4,%esp
  800c71:	68 07 04 00 00       	push   $0x407
  800c76:	ff 75 f4             	pushl  -0xc(%ebp)
  800c79:	6a 00                	push   $0x0
  800c7b:	e8 da f4 ff ff       	call   80015a <sys_page_alloc>
  800c80:	89 c3                	mov    %eax,%ebx
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	85 c0                	test   %eax,%eax
  800c87:	79 10                	jns    800c99 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	56                   	push   %esi
  800c8d:	e8 0e 02 00 00       	call   800ea0 <nsipc_close>
		return r;
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	89 d8                	mov    %ebx,%eax
  800c97:	eb 24                	jmp    800cbd <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c99:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cae:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	50                   	push   %eax
  800cb5:	e8 b0 f6 ff ff       	call   80036a <fd2num>
  800cba:	83 c4 10             	add    $0x10,%esp
}
  800cbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	e8 50 ff ff ff       	call   800c22 <fd2sockid>
		return r;
  800cd2:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	78 1f                	js     800cf7 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cd8:	83 ec 04             	sub    $0x4,%esp
  800cdb:	ff 75 10             	pushl  0x10(%ebp)
  800cde:	ff 75 0c             	pushl  0xc(%ebp)
  800ce1:	50                   	push   %eax
  800ce2:	e8 12 01 00 00       	call   800df9 <nsipc_accept>
  800ce7:	83 c4 10             	add    $0x10,%esp
		return r;
  800cea:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	78 07                	js     800cf7 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf0:	e8 5d ff ff ff       	call   800c52 <alloc_sockfd>
  800cf5:	89 c1                	mov    %eax,%ecx
}
  800cf7:	89 c8                	mov    %ecx,%eax
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	e8 19 ff ff ff       	call   800c22 <fd2sockid>
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	78 12                	js     800d1f <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d0d:	83 ec 04             	sub    $0x4,%esp
  800d10:	ff 75 10             	pushl  0x10(%ebp)
  800d13:	ff 75 0c             	pushl  0xc(%ebp)
  800d16:	50                   	push   %eax
  800d17:	e8 2d 01 00 00       	call   800e49 <nsipc_bind>
  800d1c:	83 c4 10             	add    $0x10,%esp
}
  800d1f:	c9                   	leave  
  800d20:	c3                   	ret    

00800d21 <shutdown>:

int
shutdown(int s, int how)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	e8 f3 fe ff ff       	call   800c22 <fd2sockid>
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	78 0f                	js     800d42 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d33:	83 ec 08             	sub    $0x8,%esp
  800d36:	ff 75 0c             	pushl  0xc(%ebp)
  800d39:	50                   	push   %eax
  800d3a:	e8 3f 01 00 00       	call   800e7e <nsipc_shutdown>
  800d3f:	83 c4 10             	add    $0x10,%esp
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	e8 d0 fe ff ff       	call   800c22 <fd2sockid>
  800d52:	85 c0                	test   %eax,%eax
  800d54:	78 12                	js     800d68 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	ff 75 10             	pushl  0x10(%ebp)
  800d5c:	ff 75 0c             	pushl  0xc(%ebp)
  800d5f:	50                   	push   %eax
  800d60:	e8 55 01 00 00       	call   800eba <nsipc_connect>
  800d65:	83 c4 10             	add    $0x10,%esp
}
  800d68:	c9                   	leave  
  800d69:	c3                   	ret    

00800d6a <listen>:

int
listen(int s, int backlog)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	e8 aa fe ff ff       	call   800c22 <fd2sockid>
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	78 0f                	js     800d8b <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d7c:	83 ec 08             	sub    $0x8,%esp
  800d7f:	ff 75 0c             	pushl  0xc(%ebp)
  800d82:	50                   	push   %eax
  800d83:	e8 67 01 00 00       	call   800eef <nsipc_listen>
  800d88:	83 c4 10             	add    $0x10,%esp
}
  800d8b:	c9                   	leave  
  800d8c:	c3                   	ret    

00800d8d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d93:	ff 75 10             	pushl  0x10(%ebp)
  800d96:	ff 75 0c             	pushl  0xc(%ebp)
  800d99:	ff 75 08             	pushl  0x8(%ebp)
  800d9c:	e8 3a 02 00 00       	call   800fdb <nsipc_socket>
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	85 c0                	test   %eax,%eax
  800da6:	78 05                	js     800dad <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800da8:	e8 a5 fe ff ff       	call   800c52 <alloc_sockfd>
}
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    

00800daf <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	53                   	push   %ebx
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800db8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dbf:	75 12                	jne    800dd3 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	6a 02                	push   $0x2
  800dc6:	e8 7b 11 00 00       	call   801f46 <ipc_find_env>
  800dcb:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dd3:	6a 07                	push   $0x7
  800dd5:	68 00 60 80 00       	push   $0x806000
  800dda:	53                   	push   %ebx
  800ddb:	ff 35 04 40 80 00    	pushl  0x804004
  800de1:	e8 0c 11 00 00       	call   801ef2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800de6:	83 c4 0c             	add    $0xc,%esp
  800de9:	6a 00                	push   $0x0
  800deb:	6a 00                	push   $0x0
  800ded:	6a 00                	push   $0x0
  800def:	e8 95 10 00 00       	call   801e89 <ipc_recv>
}
  800df4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df7:	c9                   	leave  
  800df8:	c3                   	ret    

00800df9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e09:	8b 06                	mov    (%esi),%eax
  800e0b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e10:	b8 01 00 00 00       	mov    $0x1,%eax
  800e15:	e8 95 ff ff ff       	call   800daf <nsipc>
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	78 20                	js     800e40 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e20:	83 ec 04             	sub    $0x4,%esp
  800e23:	ff 35 10 60 80 00    	pushl  0x806010
  800e29:	68 00 60 80 00       	push   $0x806000
  800e2e:	ff 75 0c             	pushl  0xc(%ebp)
  800e31:	e8 9e 0e 00 00       	call   801cd4 <memmove>
		*addrlen = ret->ret_addrlen;
  800e36:	a1 10 60 80 00       	mov    0x806010,%eax
  800e3b:	89 06                	mov    %eax,(%esi)
  800e3d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e40:	89 d8                	mov    %ebx,%eax
  800e42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 08             	sub    $0x8,%esp
  800e50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e5b:	53                   	push   %ebx
  800e5c:	ff 75 0c             	pushl  0xc(%ebp)
  800e5f:	68 04 60 80 00       	push   $0x806004
  800e64:	e8 6b 0e 00 00       	call   801cd4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e69:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e6f:	b8 02 00 00 00       	mov    $0x2,%eax
  800e74:	e8 36 ff ff ff       	call   800daf <nsipc>
}
  800e79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7c:	c9                   	leave  
  800e7d:	c3                   	ret    

00800e7e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e94:	b8 03 00 00 00       	mov    $0x3,%eax
  800e99:	e8 11 ff ff ff       	call   800daf <nsipc>
}
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eae:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb3:	e8 f7 fe ff ff       	call   800daf <nsipc>
}
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	53                   	push   %ebx
  800ebe:	83 ec 08             	sub    $0x8,%esp
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ecc:	53                   	push   %ebx
  800ecd:	ff 75 0c             	pushl  0xc(%ebp)
  800ed0:	68 04 60 80 00       	push   $0x806004
  800ed5:	e8 fa 0d 00 00       	call   801cd4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eda:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee5:	e8 c5 fe ff ff       	call   800daf <nsipc>
}
  800eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f00:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f05:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0a:	e8 a0 fe ff ff       	call   800daf <nsipc>
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f19:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f21:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f27:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f2f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f34:	e8 76 fe ff ff       	call   800daf <nsipc>
  800f39:	89 c3                	mov    %eax,%ebx
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 35                	js     800f74 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f3f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f44:	7f 04                	jg     800f4a <nsipc_recv+0x39>
  800f46:	39 c6                	cmp    %eax,%esi
  800f48:	7d 16                	jge    800f60 <nsipc_recv+0x4f>
  800f4a:	68 73 23 80 00       	push   $0x802373
  800f4f:	68 34 23 80 00       	push   $0x802334
  800f54:	6a 62                	push   $0x62
  800f56:	68 88 23 80 00       	push   $0x802388
  800f5b:	e8 84 05 00 00       	call   8014e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f60:	83 ec 04             	sub    $0x4,%esp
  800f63:	50                   	push   %eax
  800f64:	68 00 60 80 00       	push   $0x806000
  800f69:	ff 75 0c             	pushl  0xc(%ebp)
  800f6c:	e8 63 0d 00 00       	call   801cd4 <memmove>
  800f71:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f74:	89 d8                	mov    %ebx,%eax
  800f76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	53                   	push   %ebx
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f8f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f95:	7e 16                	jle    800fad <nsipc_send+0x30>
  800f97:	68 94 23 80 00       	push   $0x802394
  800f9c:	68 34 23 80 00       	push   $0x802334
  800fa1:	6a 6d                	push   $0x6d
  800fa3:	68 88 23 80 00       	push   $0x802388
  800fa8:	e8 37 05 00 00       	call   8014e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	53                   	push   %ebx
  800fb1:	ff 75 0c             	pushl  0xc(%ebp)
  800fb4:	68 0c 60 80 00       	push   $0x80600c
  800fb9:	e8 16 0d 00 00       	call   801cd4 <memmove>
	nsipcbuf.send.req_size = size;
  800fbe:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fcc:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd1:	e8 d9 fd ff ff       	call   800daf <nsipc>
}
  800fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fec:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ff9:	b8 09 00 00 00       	mov    $0x9,%eax
  800ffe:	e8 ac fd ff ff       	call   800daf <nsipc>
}
  801003:	c9                   	leave  
  801004:	c3                   	ret    

00801005 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	ff 75 08             	pushl  0x8(%ebp)
  801013:	e8 62 f3 ff ff       	call   80037a <fd2data>
  801018:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80101a:	83 c4 08             	add    $0x8,%esp
  80101d:	68 a0 23 80 00       	push   $0x8023a0
  801022:	53                   	push   %ebx
  801023:	e8 1a 0b 00 00       	call   801b42 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801028:	8b 46 04             	mov    0x4(%esi),%eax
  80102b:	2b 06                	sub    (%esi),%eax
  80102d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801033:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80103a:	00 00 00 
	stat->st_dev = &devpipe;
  80103d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801044:	30 80 00 
	return 0;
}
  801047:	b8 00 00 00 00       	mov    $0x0,%eax
  80104c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80105d:	53                   	push   %ebx
  80105e:	6a 00                	push   $0x0
  801060:	e8 7a f1 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801065:	89 1c 24             	mov    %ebx,(%esp)
  801068:	e8 0d f3 ff ff       	call   80037a <fd2data>
  80106d:	83 c4 08             	add    $0x8,%esp
  801070:	50                   	push   %eax
  801071:	6a 00                	push   $0x0
  801073:	e8 67 f1 ff ff       	call   8001df <sys_page_unmap>
}
  801078:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 1c             	sub    $0x1c,%esp
  801086:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801089:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80108b:	a1 08 40 80 00       	mov    0x804008,%eax
  801090:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	ff 75 e0             	pushl  -0x20(%ebp)
  801099:	e8 e1 0e 00 00       	call   801f7f <pageref>
  80109e:	89 c3                	mov    %eax,%ebx
  8010a0:	89 3c 24             	mov    %edi,(%esp)
  8010a3:	e8 d7 0e 00 00       	call   801f7f <pageref>
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	39 c3                	cmp    %eax,%ebx
  8010ad:	0f 94 c1             	sete   %cl
  8010b0:	0f b6 c9             	movzbl %cl,%ecx
  8010b3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010b6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010bc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010bf:	39 ce                	cmp    %ecx,%esi
  8010c1:	74 1b                	je     8010de <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010c3:	39 c3                	cmp    %eax,%ebx
  8010c5:	75 c4                	jne    80108b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c7:	8b 42 58             	mov    0x58(%edx),%eax
  8010ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010cd:	50                   	push   %eax
  8010ce:	56                   	push   %esi
  8010cf:	68 a7 23 80 00       	push   $0x8023a7
  8010d4:	e8 e4 04 00 00       	call   8015bd <cprintf>
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	eb ad                	jmp    80108b <_pipeisclosed+0xe>
	}
}
  8010de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 28             	sub    $0x28,%esp
  8010f2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010f5:	56                   	push   %esi
  8010f6:	e8 7f f2 ff ff       	call   80037a <fd2data>
  8010fb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	bf 00 00 00 00       	mov    $0x0,%edi
  801105:	eb 4b                	jmp    801152 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801107:	89 da                	mov    %ebx,%edx
  801109:	89 f0                	mov    %esi,%eax
  80110b:	e8 6d ff ff ff       	call   80107d <_pipeisclosed>
  801110:	85 c0                	test   %eax,%eax
  801112:	75 48                	jne    80115c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801114:	e8 22 f0 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801119:	8b 43 04             	mov    0x4(%ebx),%eax
  80111c:	8b 0b                	mov    (%ebx),%ecx
  80111e:	8d 51 20             	lea    0x20(%ecx),%edx
  801121:	39 d0                	cmp    %edx,%eax
  801123:	73 e2                	jae    801107 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801125:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801128:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112f:	89 c2                	mov    %eax,%edx
  801131:	c1 fa 1f             	sar    $0x1f,%edx
  801134:	89 d1                	mov    %edx,%ecx
  801136:	c1 e9 1b             	shr    $0x1b,%ecx
  801139:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113c:	83 e2 1f             	and    $0x1f,%edx
  80113f:	29 ca                	sub    %ecx,%edx
  801141:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801145:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801149:	83 c0 01             	add    $0x1,%eax
  80114c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80114f:	83 c7 01             	add    $0x1,%edi
  801152:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801155:	75 c2                	jne    801119 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801157:	8b 45 10             	mov    0x10(%ebp),%eax
  80115a:	eb 05                	jmp    801161 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80115c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801161:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	57                   	push   %edi
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	83 ec 18             	sub    $0x18,%esp
  801172:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801175:	57                   	push   %edi
  801176:	e8 ff f1 ff ff       	call   80037a <fd2data>
  80117b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	bb 00 00 00 00       	mov    $0x0,%ebx
  801185:	eb 3d                	jmp    8011c4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801187:	85 db                	test   %ebx,%ebx
  801189:	74 04                	je     80118f <devpipe_read+0x26>
				return i;
  80118b:	89 d8                	mov    %ebx,%eax
  80118d:	eb 44                	jmp    8011d3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80118f:	89 f2                	mov    %esi,%edx
  801191:	89 f8                	mov    %edi,%eax
  801193:	e8 e5 fe ff ff       	call   80107d <_pipeisclosed>
  801198:	85 c0                	test   %eax,%eax
  80119a:	75 32                	jne    8011ce <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80119c:	e8 9a ef ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a1:	8b 06                	mov    (%esi),%eax
  8011a3:	3b 46 04             	cmp    0x4(%esi),%eax
  8011a6:	74 df                	je     801187 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a8:	99                   	cltd   
  8011a9:	c1 ea 1b             	shr    $0x1b,%edx
  8011ac:	01 d0                	add    %edx,%eax
  8011ae:	83 e0 1f             	and    $0x1f,%eax
  8011b1:	29 d0                	sub    %edx,%eax
  8011b3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011be:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c1:	83 c3 01             	add    $0x1,%ebx
  8011c4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011c7:	75 d8                	jne    8011a1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011cc:	eb 05                	jmp    8011d3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011ce:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d6:	5b                   	pop    %ebx
  8011d7:	5e                   	pop    %esi
  8011d8:	5f                   	pop    %edi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e6:	50                   	push   %eax
  8011e7:	e8 a5 f1 ff ff       	call   800391 <fd_alloc>
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	0f 88 2c 01 00 00    	js     801325 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	68 07 04 00 00       	push   $0x407
  801201:	ff 75 f4             	pushl  -0xc(%ebp)
  801204:	6a 00                	push   $0x0
  801206:	e8 4f ef ff ff       	call   80015a <sys_page_alloc>
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	89 c2                	mov    %eax,%edx
  801210:	85 c0                	test   %eax,%eax
  801212:	0f 88 0d 01 00 00    	js     801325 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801218:	83 ec 0c             	sub    $0xc,%esp
  80121b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121e:	50                   	push   %eax
  80121f:	e8 6d f1 ff ff       	call   800391 <fd_alloc>
  801224:	89 c3                	mov    %eax,%ebx
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	85 c0                	test   %eax,%eax
  80122b:	0f 88 e2 00 00 00    	js     801313 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801231:	83 ec 04             	sub    $0x4,%esp
  801234:	68 07 04 00 00       	push   $0x407
  801239:	ff 75 f0             	pushl  -0x10(%ebp)
  80123c:	6a 00                	push   $0x0
  80123e:	e8 17 ef ff ff       	call   80015a <sys_page_alloc>
  801243:	89 c3                	mov    %eax,%ebx
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	0f 88 c3 00 00 00    	js     801313 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801250:	83 ec 0c             	sub    $0xc,%esp
  801253:	ff 75 f4             	pushl  -0xc(%ebp)
  801256:	e8 1f f1 ff ff       	call   80037a <fd2data>
  80125b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125d:	83 c4 0c             	add    $0xc,%esp
  801260:	68 07 04 00 00       	push   $0x407
  801265:	50                   	push   %eax
  801266:	6a 00                	push   $0x0
  801268:	e8 ed ee ff ff       	call   80015a <sys_page_alloc>
  80126d:	89 c3                	mov    %eax,%ebx
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	0f 88 89 00 00 00    	js     801303 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	ff 75 f0             	pushl  -0x10(%ebp)
  801280:	e8 f5 f0 ff ff       	call   80037a <fd2data>
  801285:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80128c:	50                   	push   %eax
  80128d:	6a 00                	push   $0x0
  80128f:	56                   	push   %esi
  801290:	6a 00                	push   $0x0
  801292:	e8 06 ef ff ff       	call   80019d <sys_page_map>
  801297:	89 c3                	mov    %eax,%ebx
  801299:	83 c4 20             	add    $0x20,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 55                	js     8012f5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012b5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012be:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d0:	e8 95 f0 ff ff       	call   80036a <fd2num>
  8012d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012da:	83 c4 04             	add    $0x4,%esp
  8012dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e0:	e8 85 f0 ff ff       	call   80036a <fd2num>
  8012e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f3:	eb 30                	jmp    801325 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	56                   	push   %esi
  8012f9:	6a 00                	push   $0x0
  8012fb:	e8 df ee ff ff       	call   8001df <sys_page_unmap>
  801300:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	ff 75 f0             	pushl  -0x10(%ebp)
  801309:	6a 00                	push   $0x0
  80130b:	e8 cf ee ff ff       	call   8001df <sys_page_unmap>
  801310:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	ff 75 f4             	pushl  -0xc(%ebp)
  801319:	6a 00                	push   $0x0
  80131b:	e8 bf ee ff ff       	call   8001df <sys_page_unmap>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801325:	89 d0                	mov    %edx,%eax
  801327:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132a:	5b                   	pop    %ebx
  80132b:	5e                   	pop    %esi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    

0080132e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801334:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	ff 75 08             	pushl  0x8(%ebp)
  80133b:	e8 a0 f0 ff ff       	call   8003e0 <fd_lookup>
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	78 18                	js     80135f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801347:	83 ec 0c             	sub    $0xc,%esp
  80134a:	ff 75 f4             	pushl  -0xc(%ebp)
  80134d:	e8 28 f0 ff ff       	call   80037a <fd2data>
	return _pipeisclosed(fd, p);
  801352:	89 c2                	mov    %eax,%edx
  801354:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801357:	e8 21 fd ff ff       	call   80107d <_pipeisclosed>
  80135c:	83 c4 10             	add    $0x10,%esp
}
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801364:	b8 00 00 00 00       	mov    $0x0,%eax
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801371:	68 bf 23 80 00       	push   $0x8023bf
  801376:	ff 75 0c             	pushl  0xc(%ebp)
  801379:	e8 c4 07 00 00       	call   801b42 <strcpy>
	return 0;
}
  80137e:	b8 00 00 00 00       	mov    $0x0,%eax
  801383:	c9                   	leave  
  801384:	c3                   	ret    

00801385 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	57                   	push   %edi
  801389:	56                   	push   %esi
  80138a:	53                   	push   %ebx
  80138b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801391:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801396:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80139c:	eb 2d                	jmp    8013cb <devcons_write+0x46>
		m = n - tot;
  80139e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013a3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013a6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013ab:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013ae:	83 ec 04             	sub    $0x4,%esp
  8013b1:	53                   	push   %ebx
  8013b2:	03 45 0c             	add    0xc(%ebp),%eax
  8013b5:	50                   	push   %eax
  8013b6:	57                   	push   %edi
  8013b7:	e8 18 09 00 00       	call   801cd4 <memmove>
		sys_cputs(buf, m);
  8013bc:	83 c4 08             	add    $0x8,%esp
  8013bf:	53                   	push   %ebx
  8013c0:	57                   	push   %edi
  8013c1:	e8 d8 ec ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c6:	01 de                	add    %ebx,%esi
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	89 f0                	mov    %esi,%eax
  8013cd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d0:	72 cc                	jb     80139e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5f                   	pop    %edi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013e9:	74 2a                	je     801415 <devcons_read+0x3b>
  8013eb:	eb 05                	jmp    8013f2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013ed:	e8 49 ed ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013f2:	e8 c5 ec ff ff       	call   8000bc <sys_cgetc>
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	74 f2                	je     8013ed <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 16                	js     801415 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013ff:	83 f8 04             	cmp    $0x4,%eax
  801402:	74 0c                	je     801410 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801404:	8b 55 0c             	mov    0xc(%ebp),%edx
  801407:	88 02                	mov    %al,(%edx)
	return 1;
  801409:	b8 01 00 00 00       	mov    $0x1,%eax
  80140e:	eb 05                	jmp    801415 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801410:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80141d:	8b 45 08             	mov    0x8(%ebp),%eax
  801420:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801423:	6a 01                	push   $0x1
  801425:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	e8 70 ec ff ff       	call   80009e <sys_cputs>
}
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <getchar>:

int
getchar(void)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801439:	6a 01                	push   $0x1
  80143b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80143e:	50                   	push   %eax
  80143f:	6a 00                	push   $0x0
  801441:	e8 00 f2 ff ff       	call   800646 <read>
	if (r < 0)
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 0f                	js     80145c <getchar+0x29>
		return r;
	if (r < 1)
  80144d:	85 c0                	test   %eax,%eax
  80144f:	7e 06                	jle    801457 <getchar+0x24>
		return -E_EOF;
	return c;
  801451:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801455:	eb 05                	jmp    80145c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801457:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801464:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	ff 75 08             	pushl  0x8(%ebp)
  80146b:	e8 70 ef ff ff       	call   8003e0 <fd_lookup>
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 11                	js     801488 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801480:	39 10                	cmp    %edx,(%eax)
  801482:	0f 94 c0             	sete   %al
  801485:	0f b6 c0             	movzbl %al,%eax
}
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <opencons>:

int
opencons(void)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801490:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801493:	50                   	push   %eax
  801494:	e8 f8 ee ff ff       	call   800391 <fd_alloc>
  801499:	83 c4 10             	add    $0x10,%esp
		return r;
  80149c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 3e                	js     8014e0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	68 07 04 00 00       	push   $0x407
  8014aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ad:	6a 00                	push   $0x0
  8014af:	e8 a6 ec ff ff       	call   80015a <sys_page_alloc>
  8014b4:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 23                	js     8014e0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014bd:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d2:	83 ec 0c             	sub    $0xc,%esp
  8014d5:	50                   	push   %eax
  8014d6:	e8 8f ee ff ff       	call   80036a <fd2num>
  8014db:	89 c2                	mov    %eax,%edx
  8014dd:	83 c4 10             	add    $0x10,%esp
}
  8014e0:	89 d0                	mov    %edx,%eax
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014ec:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014f2:	e8 25 ec ff ff       	call   80011c <sys_getenvid>
  8014f7:	83 ec 0c             	sub    $0xc,%esp
  8014fa:	ff 75 0c             	pushl  0xc(%ebp)
  8014fd:	ff 75 08             	pushl  0x8(%ebp)
  801500:	56                   	push   %esi
  801501:	50                   	push   %eax
  801502:	68 cc 23 80 00       	push   $0x8023cc
  801507:	e8 b1 00 00 00       	call   8015bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80150c:	83 c4 18             	add    $0x18,%esp
  80150f:	53                   	push   %ebx
  801510:	ff 75 10             	pushl  0x10(%ebp)
  801513:	e8 54 00 00 00       	call   80156c <vcprintf>
	cprintf("\n");
  801518:	c7 04 24 b8 23 80 00 	movl   $0x8023b8,(%esp)
  80151f:	e8 99 00 00 00       	call   8015bd <cprintf>
  801524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801527:	cc                   	int3   
  801528:	eb fd                	jmp    801527 <_panic+0x43>

0080152a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801534:	8b 13                	mov    (%ebx),%edx
  801536:	8d 42 01             	lea    0x1(%edx),%eax
  801539:	89 03                	mov    %eax,(%ebx)
  80153b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801542:	3d ff 00 00 00       	cmp    $0xff,%eax
  801547:	75 1a                	jne    801563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	68 ff 00 00 00       	push   $0xff
  801551:	8d 43 08             	lea    0x8(%ebx),%eax
  801554:	50                   	push   %eax
  801555:	e8 44 eb ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  80155a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80157c:	00 00 00 
	b.cnt = 0;
  80157f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801589:	ff 75 0c             	pushl  0xc(%ebp)
  80158c:	ff 75 08             	pushl  0x8(%ebp)
  80158f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	68 2a 15 80 00       	push   $0x80152a
  80159b:	e8 54 01 00 00       	call   8016f4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a0:	83 c4 08             	add    $0x8,%esp
  8015a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	e8 e9 ea ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  8015b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015c6:	50                   	push   %eax
  8015c7:	ff 75 08             	pushl  0x8(%ebp)
  8015ca:	e8 9d ff ff ff       	call   80156c <vcprintf>
	va_end(ap);

	return cnt;
}
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	57                   	push   %edi
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 1c             	sub    $0x1c,%esp
  8015da:	89 c7                	mov    %eax,%edi
  8015dc:	89 d6                	mov    %edx,%esi
  8015de:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015f8:	39 d3                	cmp    %edx,%ebx
  8015fa:	72 05                	jb     801601 <printnum+0x30>
  8015fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015ff:	77 45                	ja     801646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	ff 75 18             	pushl  0x18(%ebp)
  801607:	8b 45 14             	mov    0x14(%ebp),%eax
  80160a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80160d:	53                   	push   %ebx
  80160e:	ff 75 10             	pushl  0x10(%ebp)
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	ff 75 e4             	pushl  -0x1c(%ebp)
  801617:	ff 75 e0             	pushl  -0x20(%ebp)
  80161a:	ff 75 dc             	pushl  -0x24(%ebp)
  80161d:	ff 75 d8             	pushl  -0x28(%ebp)
  801620:	e8 9b 09 00 00       	call   801fc0 <__udivdi3>
  801625:	83 c4 18             	add    $0x18,%esp
  801628:	52                   	push   %edx
  801629:	50                   	push   %eax
  80162a:	89 f2                	mov    %esi,%edx
  80162c:	89 f8                	mov    %edi,%eax
  80162e:	e8 9e ff ff ff       	call   8015d1 <printnum>
  801633:	83 c4 20             	add    $0x20,%esp
  801636:	eb 18                	jmp    801650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	56                   	push   %esi
  80163c:	ff 75 18             	pushl  0x18(%ebp)
  80163f:	ff d7                	call   *%edi
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	eb 03                	jmp    801649 <printnum+0x78>
  801646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801649:	83 eb 01             	sub    $0x1,%ebx
  80164c:	85 db                	test   %ebx,%ebx
  80164e:	7f e8                	jg     801638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	56                   	push   %esi
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165a:	ff 75 e0             	pushl  -0x20(%ebp)
  80165d:	ff 75 dc             	pushl  -0x24(%ebp)
  801660:	ff 75 d8             	pushl  -0x28(%ebp)
  801663:	e8 88 0a 00 00       	call   8020f0 <__umoddi3>
  801668:	83 c4 14             	add    $0x14,%esp
  80166b:	0f be 80 ef 23 80 00 	movsbl 0x8023ef(%eax),%eax
  801672:	50                   	push   %eax
  801673:	ff d7                	call   *%edi
}
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5f                   	pop    %edi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801683:	83 fa 01             	cmp    $0x1,%edx
  801686:	7e 0e                	jle    801696 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801688:	8b 10                	mov    (%eax),%edx
  80168a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80168d:	89 08                	mov    %ecx,(%eax)
  80168f:	8b 02                	mov    (%edx),%eax
  801691:	8b 52 04             	mov    0x4(%edx),%edx
  801694:	eb 22                	jmp    8016b8 <getuint+0x38>
	else if (lflag)
  801696:	85 d2                	test   %edx,%edx
  801698:	74 10                	je     8016aa <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80169a:	8b 10                	mov    (%eax),%edx
  80169c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80169f:	89 08                	mov    %ecx,(%eax)
  8016a1:	8b 02                	mov    (%edx),%eax
  8016a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a8:	eb 0e                	jmp    8016b8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016aa:	8b 10                	mov    (%eax),%edx
  8016ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016af:	89 08                	mov    %ecx,(%eax)
  8016b1:	8b 02                	mov    (%edx),%eax
  8016b3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016c4:	8b 10                	mov    (%eax),%edx
  8016c6:	3b 50 04             	cmp    0x4(%eax),%edx
  8016c9:	73 0a                	jae    8016d5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016cb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016ce:	89 08                	mov    %ecx,(%eax)
  8016d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d3:	88 02                	mov    %al,(%edx)
}
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    

008016d7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016dd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016e0:	50                   	push   %eax
  8016e1:	ff 75 10             	pushl  0x10(%ebp)
  8016e4:	ff 75 0c             	pushl  0xc(%ebp)
  8016e7:	ff 75 08             	pushl  0x8(%ebp)
  8016ea:	e8 05 00 00 00       	call   8016f4 <vprintfmt>
	va_end(ap);
}
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	c9                   	leave  
  8016f3:	c3                   	ret    

008016f4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	57                   	push   %edi
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
  8016fa:	83 ec 2c             	sub    $0x2c,%esp
  8016fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801700:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801703:	8b 7d 10             	mov    0x10(%ebp),%edi
  801706:	eb 12                	jmp    80171a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801708:	85 c0                	test   %eax,%eax
  80170a:	0f 84 89 03 00 00    	je     801a99 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	53                   	push   %ebx
  801714:	50                   	push   %eax
  801715:	ff d6                	call   *%esi
  801717:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80171a:	83 c7 01             	add    $0x1,%edi
  80171d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801721:	83 f8 25             	cmp    $0x25,%eax
  801724:	75 e2                	jne    801708 <vprintfmt+0x14>
  801726:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80172a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801731:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801738:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80173f:	ba 00 00 00 00       	mov    $0x0,%edx
  801744:	eb 07                	jmp    80174d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801746:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801749:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174d:	8d 47 01             	lea    0x1(%edi),%eax
  801750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801753:	0f b6 07             	movzbl (%edi),%eax
  801756:	0f b6 c8             	movzbl %al,%ecx
  801759:	83 e8 23             	sub    $0x23,%eax
  80175c:	3c 55                	cmp    $0x55,%al
  80175e:	0f 87 1a 03 00 00    	ja     801a7e <vprintfmt+0x38a>
  801764:	0f b6 c0             	movzbl %al,%eax
  801767:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  80176e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801771:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801775:	eb d6                	jmp    80174d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
  80177f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801782:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801785:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801789:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80178c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80178f:	83 fa 09             	cmp    $0x9,%edx
  801792:	77 39                	ja     8017cd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801794:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801797:	eb e9                	jmp    801782 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801799:	8b 45 14             	mov    0x14(%ebp),%eax
  80179c:	8d 48 04             	lea    0x4(%eax),%ecx
  80179f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017a2:	8b 00                	mov    (%eax),%eax
  8017a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017aa:	eb 27                	jmp    8017d3 <vprintfmt+0xdf>
  8017ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017b6:	0f 49 c8             	cmovns %eax,%ecx
  8017b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017bf:	eb 8c                	jmp    80174d <vprintfmt+0x59>
  8017c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017cb:	eb 80                	jmp    80174d <vprintfmt+0x59>
  8017cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017d7:	0f 89 70 ff ff ff    	jns    80174d <vprintfmt+0x59>
				width = precision, precision = -1;
  8017dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ea:	e9 5e ff ff ff       	jmp    80174d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017ef:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017f5:	e9 53 ff ff ff       	jmp    80174d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fd:	8d 50 04             	lea    0x4(%eax),%edx
  801800:	89 55 14             	mov    %edx,0x14(%ebp)
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	53                   	push   %ebx
  801807:	ff 30                	pushl  (%eax)
  801809:	ff d6                	call   *%esi
			break;
  80180b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801811:	e9 04 ff ff ff       	jmp    80171a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801816:	8b 45 14             	mov    0x14(%ebp),%eax
  801819:	8d 50 04             	lea    0x4(%eax),%edx
  80181c:	89 55 14             	mov    %edx,0x14(%ebp)
  80181f:	8b 00                	mov    (%eax),%eax
  801821:	99                   	cltd   
  801822:	31 d0                	xor    %edx,%eax
  801824:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801826:	83 f8 0f             	cmp    $0xf,%eax
  801829:	7f 0b                	jg     801836 <vprintfmt+0x142>
  80182b:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  801832:	85 d2                	test   %edx,%edx
  801834:	75 18                	jne    80184e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801836:	50                   	push   %eax
  801837:	68 07 24 80 00       	push   $0x802407
  80183c:	53                   	push   %ebx
  80183d:	56                   	push   %esi
  80183e:	e8 94 fe ff ff       	call   8016d7 <printfmt>
  801843:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801846:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801849:	e9 cc fe ff ff       	jmp    80171a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80184e:	52                   	push   %edx
  80184f:	68 46 23 80 00       	push   $0x802346
  801854:	53                   	push   %ebx
  801855:	56                   	push   %esi
  801856:	e8 7c fe ff ff       	call   8016d7 <printfmt>
  80185b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801861:	e9 b4 fe ff ff       	jmp    80171a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801866:	8b 45 14             	mov    0x14(%ebp),%eax
  801869:	8d 50 04             	lea    0x4(%eax),%edx
  80186c:	89 55 14             	mov    %edx,0x14(%ebp)
  80186f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801871:	85 ff                	test   %edi,%edi
  801873:	b8 00 24 80 00       	mov    $0x802400,%eax
  801878:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80187b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80187f:	0f 8e 94 00 00 00    	jle    801919 <vprintfmt+0x225>
  801885:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801889:	0f 84 98 00 00 00    	je     801927 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	ff 75 d0             	pushl  -0x30(%ebp)
  801895:	57                   	push   %edi
  801896:	e8 86 02 00 00       	call   801b21 <strnlen>
  80189b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80189e:	29 c1                	sub    %eax,%ecx
  8018a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b2:	eb 0f                	jmp    8018c3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018b4:	83 ec 08             	sub    $0x8,%esp
  8018b7:	53                   	push   %ebx
  8018b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018bd:	83 ef 01             	sub    $0x1,%edi
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	85 ff                	test   %edi,%edi
  8018c5:	7f ed                	jg     8018b4 <vprintfmt+0x1c0>
  8018c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018cd:	85 c9                	test   %ecx,%ecx
  8018cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d4:	0f 49 c1             	cmovns %ecx,%eax
  8018d7:	29 c1                	sub    %eax,%ecx
  8018d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8018dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e2:	89 cb                	mov    %ecx,%ebx
  8018e4:	eb 4d                	jmp    801933 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ea:	74 1b                	je     801907 <vprintfmt+0x213>
  8018ec:	0f be c0             	movsbl %al,%eax
  8018ef:	83 e8 20             	sub    $0x20,%eax
  8018f2:	83 f8 5e             	cmp    $0x5e,%eax
  8018f5:	76 10                	jbe    801907 <vprintfmt+0x213>
					putch('?', putdat);
  8018f7:	83 ec 08             	sub    $0x8,%esp
  8018fa:	ff 75 0c             	pushl  0xc(%ebp)
  8018fd:	6a 3f                	push   $0x3f
  8018ff:	ff 55 08             	call   *0x8(%ebp)
  801902:	83 c4 10             	add    $0x10,%esp
  801905:	eb 0d                	jmp    801914 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	ff 75 0c             	pushl  0xc(%ebp)
  80190d:	52                   	push   %edx
  80190e:	ff 55 08             	call   *0x8(%ebp)
  801911:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801914:	83 eb 01             	sub    $0x1,%ebx
  801917:	eb 1a                	jmp    801933 <vprintfmt+0x23f>
  801919:	89 75 08             	mov    %esi,0x8(%ebp)
  80191c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80191f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801922:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801925:	eb 0c                	jmp    801933 <vprintfmt+0x23f>
  801927:	89 75 08             	mov    %esi,0x8(%ebp)
  80192a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80192d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801930:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801933:	83 c7 01             	add    $0x1,%edi
  801936:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80193a:	0f be d0             	movsbl %al,%edx
  80193d:	85 d2                	test   %edx,%edx
  80193f:	74 23                	je     801964 <vprintfmt+0x270>
  801941:	85 f6                	test   %esi,%esi
  801943:	78 a1                	js     8018e6 <vprintfmt+0x1f2>
  801945:	83 ee 01             	sub    $0x1,%esi
  801948:	79 9c                	jns    8018e6 <vprintfmt+0x1f2>
  80194a:	89 df                	mov    %ebx,%edi
  80194c:	8b 75 08             	mov    0x8(%ebp),%esi
  80194f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801952:	eb 18                	jmp    80196c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	53                   	push   %ebx
  801958:	6a 20                	push   $0x20
  80195a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80195c:	83 ef 01             	sub    $0x1,%edi
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	eb 08                	jmp    80196c <vprintfmt+0x278>
  801964:	89 df                	mov    %ebx,%edi
  801966:	8b 75 08             	mov    0x8(%ebp),%esi
  801969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80196c:	85 ff                	test   %edi,%edi
  80196e:	7f e4                	jg     801954 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801970:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801973:	e9 a2 fd ff ff       	jmp    80171a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801978:	83 fa 01             	cmp    $0x1,%edx
  80197b:	7e 16                	jle    801993 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80197d:	8b 45 14             	mov    0x14(%ebp),%eax
  801980:	8d 50 08             	lea    0x8(%eax),%edx
  801983:	89 55 14             	mov    %edx,0x14(%ebp)
  801986:	8b 50 04             	mov    0x4(%eax),%edx
  801989:	8b 00                	mov    (%eax),%eax
  80198b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80198e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801991:	eb 32                	jmp    8019c5 <vprintfmt+0x2d1>
	else if (lflag)
  801993:	85 d2                	test   %edx,%edx
  801995:	74 18                	je     8019af <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801997:	8b 45 14             	mov    0x14(%ebp),%eax
  80199a:	8d 50 04             	lea    0x4(%eax),%edx
  80199d:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a0:	8b 00                	mov    (%eax),%eax
  8019a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a5:	89 c1                	mov    %eax,%ecx
  8019a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8019aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019ad:	eb 16                	jmp    8019c5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019af:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b2:	8d 50 04             	lea    0x4(%eax),%edx
  8019b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b8:	8b 00                	mov    (%eax),%eax
  8019ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019bd:	89 c1                	mov    %eax,%ecx
  8019bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8019c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019d0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019d4:	79 74                	jns    801a4a <vprintfmt+0x356>
				putch('-', putdat);
  8019d6:	83 ec 08             	sub    $0x8,%esp
  8019d9:	53                   	push   %ebx
  8019da:	6a 2d                	push   $0x2d
  8019dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8019de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019e4:	f7 d8                	neg    %eax
  8019e6:	83 d2 00             	adc    $0x0,%edx
  8019e9:	f7 da                	neg    %edx
  8019eb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019ee:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019f3:	eb 55                	jmp    801a4a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8019f8:	e8 83 fc ff ff       	call   801680 <getuint>
			base = 10;
  8019fd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a02:	eb 46                	jmp    801a4a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a04:	8d 45 14             	lea    0x14(%ebp),%eax
  801a07:	e8 74 fc ff ff       	call   801680 <getuint>
                        base = 8;
  801a0c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a11:	eb 37                	jmp    801a4a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a13:	83 ec 08             	sub    $0x8,%esp
  801a16:	53                   	push   %ebx
  801a17:	6a 30                	push   $0x30
  801a19:	ff d6                	call   *%esi
			putch('x', putdat);
  801a1b:	83 c4 08             	add    $0x8,%esp
  801a1e:	53                   	push   %ebx
  801a1f:	6a 78                	push   $0x78
  801a21:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a23:	8b 45 14             	mov    0x14(%ebp),%eax
  801a26:	8d 50 04             	lea    0x4(%eax),%edx
  801a29:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a2c:	8b 00                	mov    (%eax),%eax
  801a2e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a33:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a36:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a3b:	eb 0d                	jmp    801a4a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a3d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a40:	e8 3b fc ff ff       	call   801680 <getuint>
			base = 16;
  801a45:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a51:	57                   	push   %edi
  801a52:	ff 75 e0             	pushl  -0x20(%ebp)
  801a55:	51                   	push   %ecx
  801a56:	52                   	push   %edx
  801a57:	50                   	push   %eax
  801a58:	89 da                	mov    %ebx,%edx
  801a5a:	89 f0                	mov    %esi,%eax
  801a5c:	e8 70 fb ff ff       	call   8015d1 <printnum>
			break;
  801a61:	83 c4 20             	add    $0x20,%esp
  801a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a67:	e9 ae fc ff ff       	jmp    80171a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a6c:	83 ec 08             	sub    $0x8,%esp
  801a6f:	53                   	push   %ebx
  801a70:	51                   	push   %ecx
  801a71:	ff d6                	call   *%esi
			break;
  801a73:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a79:	e9 9c fc ff ff       	jmp    80171a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a7e:	83 ec 08             	sub    $0x8,%esp
  801a81:	53                   	push   %ebx
  801a82:	6a 25                	push   $0x25
  801a84:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	eb 03                	jmp    801a8e <vprintfmt+0x39a>
  801a8b:	83 ef 01             	sub    $0x1,%edi
  801a8e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a92:	75 f7                	jne    801a8b <vprintfmt+0x397>
  801a94:	e9 81 fc ff ff       	jmp    80171a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5f                   	pop    %edi
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    

00801aa1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	83 ec 18             	sub    $0x18,%esp
  801aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaa:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ab4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ab7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	74 26                	je     801ae8 <vsnprintf+0x47>
  801ac2:	85 d2                	test   %edx,%edx
  801ac4:	7e 22                	jle    801ae8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ac6:	ff 75 14             	pushl  0x14(%ebp)
  801ac9:	ff 75 10             	pushl  0x10(%ebp)
  801acc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801acf:	50                   	push   %eax
  801ad0:	68 ba 16 80 00       	push   $0x8016ba
  801ad5:	e8 1a fc ff ff       	call   8016f4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801add:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	eb 05                	jmp    801aed <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801ae8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801af5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801af8:	50                   	push   %eax
  801af9:	ff 75 10             	pushl  0x10(%ebp)
  801afc:	ff 75 0c             	pushl  0xc(%ebp)
  801aff:	ff 75 08             	pushl  0x8(%ebp)
  801b02:	e8 9a ff ff ff       	call   801aa1 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b14:	eb 03                	jmp    801b19 <strlen+0x10>
		n++;
  801b16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b1d:	75 f7                	jne    801b16 <strlen+0xd>
		n++;
	return n;
}
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    

00801b21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2f:	eb 03                	jmp    801b34 <strnlen+0x13>
		n++;
  801b31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b34:	39 c2                	cmp    %eax,%edx
  801b36:	74 08                	je     801b40 <strnlen+0x1f>
  801b38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b3c:	75 f3                	jne    801b31 <strnlen+0x10>
  801b3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    

00801b42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	53                   	push   %ebx
  801b46:	8b 45 08             	mov    0x8(%ebp),%eax
  801b49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b4c:	89 c2                	mov    %eax,%edx
  801b4e:	83 c2 01             	add    $0x1,%edx
  801b51:	83 c1 01             	add    $0x1,%ecx
  801b54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b58:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b5b:	84 db                	test   %bl,%bl
  801b5d:	75 ef                	jne    801b4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b5f:	5b                   	pop    %ebx
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    

00801b62 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	53                   	push   %ebx
  801b66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b69:	53                   	push   %ebx
  801b6a:	e8 9a ff ff ff       	call   801b09 <strlen>
  801b6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b72:	ff 75 0c             	pushl  0xc(%ebp)
  801b75:	01 d8                	add    %ebx,%eax
  801b77:	50                   	push   %eax
  801b78:	e8 c5 ff ff ff       	call   801b42 <strcpy>
	return dst;
}
  801b7d:	89 d8                	mov    %ebx,%eax
  801b7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b82:	c9                   	leave  
  801b83:	c3                   	ret    

00801b84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	56                   	push   %esi
  801b88:	53                   	push   %ebx
  801b89:	8b 75 08             	mov    0x8(%ebp),%esi
  801b8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8f:	89 f3                	mov    %esi,%ebx
  801b91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b94:	89 f2                	mov    %esi,%edx
  801b96:	eb 0f                	jmp    801ba7 <strncpy+0x23>
		*dst++ = *src;
  801b98:	83 c2 01             	add    $0x1,%edx
  801b9b:	0f b6 01             	movzbl (%ecx),%eax
  801b9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba1:	80 39 01             	cmpb   $0x1,(%ecx)
  801ba4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba7:	39 da                	cmp    %ebx,%edx
  801ba9:	75 ed                	jne    801b98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bab:	89 f0                	mov    %esi,%eax
  801bad:	5b                   	pop    %ebx
  801bae:	5e                   	pop    %esi
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	56                   	push   %esi
  801bb5:	53                   	push   %ebx
  801bb6:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbc:	8b 55 10             	mov    0x10(%ebp),%edx
  801bbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc1:	85 d2                	test   %edx,%edx
  801bc3:	74 21                	je     801be6 <strlcpy+0x35>
  801bc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bc9:	89 f2                	mov    %esi,%edx
  801bcb:	eb 09                	jmp    801bd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bcd:	83 c2 01             	add    $0x1,%edx
  801bd0:	83 c1 01             	add    $0x1,%ecx
  801bd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bd6:	39 c2                	cmp    %eax,%edx
  801bd8:	74 09                	je     801be3 <strlcpy+0x32>
  801bda:	0f b6 19             	movzbl (%ecx),%ebx
  801bdd:	84 db                	test   %bl,%bl
  801bdf:	75 ec                	jne    801bcd <strlcpy+0x1c>
  801be1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801be3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801be6:	29 f0                	sub    %esi,%eax
}
  801be8:	5b                   	pop    %ebx
  801be9:	5e                   	pop    %esi
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    

00801bec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bf5:	eb 06                	jmp    801bfd <strcmp+0x11>
		p++, q++;
  801bf7:	83 c1 01             	add    $0x1,%ecx
  801bfa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bfd:	0f b6 01             	movzbl (%ecx),%eax
  801c00:	84 c0                	test   %al,%al
  801c02:	74 04                	je     801c08 <strcmp+0x1c>
  801c04:	3a 02                	cmp    (%edx),%al
  801c06:	74 ef                	je     801bf7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c08:	0f b6 c0             	movzbl %al,%eax
  801c0b:	0f b6 12             	movzbl (%edx),%edx
  801c0e:	29 d0                	sub    %edx,%eax
}
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    

00801c12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	53                   	push   %ebx
  801c16:	8b 45 08             	mov    0x8(%ebp),%eax
  801c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c1c:	89 c3                	mov    %eax,%ebx
  801c1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c21:	eb 06                	jmp    801c29 <strncmp+0x17>
		n--, p++, q++;
  801c23:	83 c0 01             	add    $0x1,%eax
  801c26:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c29:	39 d8                	cmp    %ebx,%eax
  801c2b:	74 15                	je     801c42 <strncmp+0x30>
  801c2d:	0f b6 08             	movzbl (%eax),%ecx
  801c30:	84 c9                	test   %cl,%cl
  801c32:	74 04                	je     801c38 <strncmp+0x26>
  801c34:	3a 0a                	cmp    (%edx),%cl
  801c36:	74 eb                	je     801c23 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c38:	0f b6 00             	movzbl (%eax),%eax
  801c3b:	0f b6 12             	movzbl (%edx),%edx
  801c3e:	29 d0                	sub    %edx,%eax
  801c40:	eb 05                	jmp    801c47 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c42:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c47:	5b                   	pop    %ebx
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c54:	eb 07                	jmp    801c5d <strchr+0x13>
		if (*s == c)
  801c56:	38 ca                	cmp    %cl,%dl
  801c58:	74 0f                	je     801c69 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c5a:	83 c0 01             	add    $0x1,%eax
  801c5d:	0f b6 10             	movzbl (%eax),%edx
  801c60:	84 d2                	test   %dl,%dl
  801c62:	75 f2                	jne    801c56 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c69:	5d                   	pop    %ebp
  801c6a:	c3                   	ret    

00801c6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c75:	eb 03                	jmp    801c7a <strfind+0xf>
  801c77:	83 c0 01             	add    $0x1,%eax
  801c7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c7d:	38 ca                	cmp    %cl,%dl
  801c7f:	74 04                	je     801c85 <strfind+0x1a>
  801c81:	84 d2                	test   %dl,%dl
  801c83:	75 f2                	jne    801c77 <strfind+0xc>
			break;
	return (char *) s;
}
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	57                   	push   %edi
  801c8b:	56                   	push   %esi
  801c8c:	53                   	push   %ebx
  801c8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c93:	85 c9                	test   %ecx,%ecx
  801c95:	74 36                	je     801ccd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c9d:	75 28                	jne    801cc7 <memset+0x40>
  801c9f:	f6 c1 03             	test   $0x3,%cl
  801ca2:	75 23                	jne    801cc7 <memset+0x40>
		c &= 0xFF;
  801ca4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ca8:	89 d3                	mov    %edx,%ebx
  801caa:	c1 e3 08             	shl    $0x8,%ebx
  801cad:	89 d6                	mov    %edx,%esi
  801caf:	c1 e6 18             	shl    $0x18,%esi
  801cb2:	89 d0                	mov    %edx,%eax
  801cb4:	c1 e0 10             	shl    $0x10,%eax
  801cb7:	09 f0                	or     %esi,%eax
  801cb9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cbb:	89 d8                	mov    %ebx,%eax
  801cbd:	09 d0                	or     %edx,%eax
  801cbf:	c1 e9 02             	shr    $0x2,%ecx
  801cc2:	fc                   	cld    
  801cc3:	f3 ab                	rep stos %eax,%es:(%edi)
  801cc5:	eb 06                	jmp    801ccd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cca:	fc                   	cld    
  801ccb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ccd:	89 f8                	mov    %edi,%eax
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	57                   	push   %edi
  801cd8:	56                   	push   %esi
  801cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cdf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce2:	39 c6                	cmp    %eax,%esi
  801ce4:	73 35                	jae    801d1b <memmove+0x47>
  801ce6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ce9:	39 d0                	cmp    %edx,%eax
  801ceb:	73 2e                	jae    801d1b <memmove+0x47>
		s += n;
		d += n;
  801ced:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf0:	89 d6                	mov    %edx,%esi
  801cf2:	09 fe                	or     %edi,%esi
  801cf4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cfa:	75 13                	jne    801d0f <memmove+0x3b>
  801cfc:	f6 c1 03             	test   $0x3,%cl
  801cff:	75 0e                	jne    801d0f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d01:	83 ef 04             	sub    $0x4,%edi
  801d04:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d07:	c1 e9 02             	shr    $0x2,%ecx
  801d0a:	fd                   	std    
  801d0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d0d:	eb 09                	jmp    801d18 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d0f:	83 ef 01             	sub    $0x1,%edi
  801d12:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d15:	fd                   	std    
  801d16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d18:	fc                   	cld    
  801d19:	eb 1d                	jmp    801d38 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1b:	89 f2                	mov    %esi,%edx
  801d1d:	09 c2                	or     %eax,%edx
  801d1f:	f6 c2 03             	test   $0x3,%dl
  801d22:	75 0f                	jne    801d33 <memmove+0x5f>
  801d24:	f6 c1 03             	test   $0x3,%cl
  801d27:	75 0a                	jne    801d33 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d29:	c1 e9 02             	shr    $0x2,%ecx
  801d2c:	89 c7                	mov    %eax,%edi
  801d2e:	fc                   	cld    
  801d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d31:	eb 05                	jmp    801d38 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d33:	89 c7                	mov    %eax,%edi
  801d35:	fc                   	cld    
  801d36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    

00801d3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d3f:	ff 75 10             	pushl  0x10(%ebp)
  801d42:	ff 75 0c             	pushl  0xc(%ebp)
  801d45:	ff 75 08             	pushl  0x8(%ebp)
  801d48:	e8 87 ff ff ff       	call   801cd4 <memmove>
}
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    

00801d4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	8b 45 08             	mov    0x8(%ebp),%eax
  801d57:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5a:	89 c6                	mov    %eax,%esi
  801d5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d5f:	eb 1a                	jmp    801d7b <memcmp+0x2c>
		if (*s1 != *s2)
  801d61:	0f b6 08             	movzbl (%eax),%ecx
  801d64:	0f b6 1a             	movzbl (%edx),%ebx
  801d67:	38 d9                	cmp    %bl,%cl
  801d69:	74 0a                	je     801d75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d6b:	0f b6 c1             	movzbl %cl,%eax
  801d6e:	0f b6 db             	movzbl %bl,%ebx
  801d71:	29 d8                	sub    %ebx,%eax
  801d73:	eb 0f                	jmp    801d84 <memcmp+0x35>
		s1++, s2++;
  801d75:	83 c0 01             	add    $0x1,%eax
  801d78:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d7b:	39 f0                	cmp    %esi,%eax
  801d7d:	75 e2                	jne    801d61 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	53                   	push   %ebx
  801d8c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d8f:	89 c1                	mov    %eax,%ecx
  801d91:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d94:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d98:	eb 0a                	jmp    801da4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9a:	0f b6 10             	movzbl (%eax),%edx
  801d9d:	39 da                	cmp    %ebx,%edx
  801d9f:	74 07                	je     801da8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da1:	83 c0 01             	add    $0x1,%eax
  801da4:	39 c8                	cmp    %ecx,%eax
  801da6:	72 f2                	jb     801d9a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801da8:	5b                   	pop    %ebx
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	57                   	push   %edi
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801db7:	eb 03                	jmp    801dbc <strtol+0x11>
		s++;
  801db9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbc:	0f b6 01             	movzbl (%ecx),%eax
  801dbf:	3c 20                	cmp    $0x20,%al
  801dc1:	74 f6                	je     801db9 <strtol+0xe>
  801dc3:	3c 09                	cmp    $0x9,%al
  801dc5:	74 f2                	je     801db9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dc7:	3c 2b                	cmp    $0x2b,%al
  801dc9:	75 0a                	jne    801dd5 <strtol+0x2a>
		s++;
  801dcb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dce:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd3:	eb 11                	jmp    801de6 <strtol+0x3b>
  801dd5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dda:	3c 2d                	cmp    $0x2d,%al
  801ddc:	75 08                	jne    801de6 <strtol+0x3b>
		s++, neg = 1;
  801dde:	83 c1 01             	add    $0x1,%ecx
  801de1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801de6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dec:	75 15                	jne    801e03 <strtol+0x58>
  801dee:	80 39 30             	cmpb   $0x30,(%ecx)
  801df1:	75 10                	jne    801e03 <strtol+0x58>
  801df3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801df7:	75 7c                	jne    801e75 <strtol+0xca>
		s += 2, base = 16;
  801df9:	83 c1 02             	add    $0x2,%ecx
  801dfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e01:	eb 16                	jmp    801e19 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e03:	85 db                	test   %ebx,%ebx
  801e05:	75 12                	jne    801e19 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e07:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e0c:	80 39 30             	cmpb   $0x30,(%ecx)
  801e0f:	75 08                	jne    801e19 <strtol+0x6e>
		s++, base = 8;
  801e11:	83 c1 01             	add    $0x1,%ecx
  801e14:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e19:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e21:	0f b6 11             	movzbl (%ecx),%edx
  801e24:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e27:	89 f3                	mov    %esi,%ebx
  801e29:	80 fb 09             	cmp    $0x9,%bl
  801e2c:	77 08                	ja     801e36 <strtol+0x8b>
			dig = *s - '0';
  801e2e:	0f be d2             	movsbl %dl,%edx
  801e31:	83 ea 30             	sub    $0x30,%edx
  801e34:	eb 22                	jmp    801e58 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e36:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e39:	89 f3                	mov    %esi,%ebx
  801e3b:	80 fb 19             	cmp    $0x19,%bl
  801e3e:	77 08                	ja     801e48 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e40:	0f be d2             	movsbl %dl,%edx
  801e43:	83 ea 57             	sub    $0x57,%edx
  801e46:	eb 10                	jmp    801e58 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e48:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e4b:	89 f3                	mov    %esi,%ebx
  801e4d:	80 fb 19             	cmp    $0x19,%bl
  801e50:	77 16                	ja     801e68 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e52:	0f be d2             	movsbl %dl,%edx
  801e55:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e58:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e5b:	7d 0b                	jge    801e68 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e5d:	83 c1 01             	add    $0x1,%ecx
  801e60:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e64:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e66:	eb b9                	jmp    801e21 <strtol+0x76>

	if (endptr)
  801e68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e6c:	74 0d                	je     801e7b <strtol+0xd0>
		*endptr = (char *) s;
  801e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e71:	89 0e                	mov    %ecx,(%esi)
  801e73:	eb 06                	jmp    801e7b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e75:	85 db                	test   %ebx,%ebx
  801e77:	74 98                	je     801e11 <strtol+0x66>
  801e79:	eb 9e                	jmp    801e19 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e7b:	89 c2                	mov    %eax,%edx
  801e7d:	f7 da                	neg    %edx
  801e7f:	85 ff                	test   %edi,%edi
  801e81:	0f 45 c2             	cmovne %edx,%eax
}
  801e84:	5b                   	pop    %ebx
  801e85:	5e                   	pop    %esi
  801e86:	5f                   	pop    %edi
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    

00801e89 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	56                   	push   %esi
  801e8d:	53                   	push   %ebx
  801e8e:	8b 75 08             	mov    0x8(%ebp),%esi
  801e91:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801e97:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801e99:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801e9e:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801ea1:	83 ec 0c             	sub    $0xc,%esp
  801ea4:	50                   	push   %eax
  801ea5:	e8 60 e4 ff ff       	call   80030a <sys_ipc_recv>

	if (r < 0) {
  801eaa:	83 c4 10             	add    $0x10,%esp
  801ead:	85 c0                	test   %eax,%eax
  801eaf:	79 16                	jns    801ec7 <ipc_recv+0x3e>
		if (from_env_store)
  801eb1:	85 f6                	test   %esi,%esi
  801eb3:	74 06                	je     801ebb <ipc_recv+0x32>
			*from_env_store = 0;
  801eb5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801ebb:	85 db                	test   %ebx,%ebx
  801ebd:	74 2c                	je     801eeb <ipc_recv+0x62>
			*perm_store = 0;
  801ebf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ec5:	eb 24                	jmp    801eeb <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801ec7:	85 f6                	test   %esi,%esi
  801ec9:	74 0a                	je     801ed5 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ecb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed0:	8b 40 74             	mov    0x74(%eax),%eax
  801ed3:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801ed5:	85 db                	test   %ebx,%ebx
  801ed7:	74 0a                	je     801ee3 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801ed9:	a1 08 40 80 00       	mov    0x804008,%eax
  801ede:	8b 40 78             	mov    0x78(%eax),%eax
  801ee1:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801ee3:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee8:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801eeb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eee:	5b                   	pop    %ebx
  801eef:	5e                   	pop    %esi
  801ef0:	5d                   	pop    %ebp
  801ef1:	c3                   	ret    

00801ef2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef2:	55                   	push   %ebp
  801ef3:	89 e5                	mov    %esp,%ebp
  801ef5:	57                   	push   %edi
  801ef6:	56                   	push   %esi
  801ef7:	53                   	push   %ebx
  801ef8:	83 ec 0c             	sub    $0xc,%esp
  801efb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801efe:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f04:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f06:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f0b:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f0e:	ff 75 14             	pushl  0x14(%ebp)
  801f11:	53                   	push   %ebx
  801f12:	56                   	push   %esi
  801f13:	57                   	push   %edi
  801f14:	e8 ce e3 ff ff       	call   8002e7 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1f:	75 07                	jne    801f28 <ipc_send+0x36>
			sys_yield();
  801f21:	e8 15 e2 ff ff       	call   80013b <sys_yield>
  801f26:	eb e6                	jmp    801f0e <ipc_send+0x1c>
		} else if (r < 0) {
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	79 12                	jns    801f3e <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f2c:	50                   	push   %eax
  801f2d:	68 00 27 80 00       	push   $0x802700
  801f32:	6a 51                	push   $0x51
  801f34:	68 0d 27 80 00       	push   $0x80270d
  801f39:	e8 a6 f5 ff ff       	call   8014e4 <_panic>
		}
	}
}
  801f3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f41:	5b                   	pop    %ebx
  801f42:	5e                   	pop    %esi
  801f43:	5f                   	pop    %edi
  801f44:	5d                   	pop    %ebp
  801f45:	c3                   	ret    

00801f46 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f4c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f51:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f54:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f5a:	8b 52 50             	mov    0x50(%edx),%edx
  801f5d:	39 ca                	cmp    %ecx,%edx
  801f5f:	75 0d                	jne    801f6e <ipc_find_env+0x28>
			return envs[i].env_id;
  801f61:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f64:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f69:	8b 40 48             	mov    0x48(%eax),%eax
  801f6c:	eb 0f                	jmp    801f7d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f6e:	83 c0 01             	add    $0x1,%eax
  801f71:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f76:	75 d9                	jne    801f51 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f85:	89 d0                	mov    %edx,%eax
  801f87:	c1 e8 16             	shr    $0x16,%eax
  801f8a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f91:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f96:	f6 c1 01             	test   $0x1,%cl
  801f99:	74 1d                	je     801fb8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f9b:	c1 ea 0c             	shr    $0xc,%edx
  801f9e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fa5:	f6 c2 01             	test   $0x1,%dl
  801fa8:	74 0e                	je     801fb8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801faa:	c1 ea 0c             	shr    $0xc,%edx
  801fad:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb4:	ef 
  801fb5:	0f b7 c0             	movzwl %ax,%eax
}
  801fb8:	5d                   	pop    %ebp
  801fb9:	c3                   	ret    
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
