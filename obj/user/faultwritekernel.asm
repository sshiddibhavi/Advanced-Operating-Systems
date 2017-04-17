
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 a6 04 00 00       	call   800539 <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 6a 22 80 00       	push   $0x80226a
  80010c:	6a 23                	push   $0x23
  80010e:	68 87 22 80 00       	push   $0x802287
  800113:	e8 d0 13 00 00       	call   8014e8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 6a 22 80 00       	push   $0x80226a
  80018d:	6a 23                	push   $0x23
  80018f:	68 87 22 80 00       	push   $0x802287
  800194:	e8 4f 13 00 00       	call   8014e8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 6a 22 80 00       	push   $0x80226a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 87 22 80 00       	push   $0x802287
  8001d6:	e8 0d 13 00 00       	call   8014e8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 6a 22 80 00       	push   $0x80226a
  800211:	6a 23                	push   $0x23
  800213:	68 87 22 80 00       	push   $0x802287
  800218:	e8 cb 12 00 00       	call   8014e8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 6a 22 80 00       	push   $0x80226a
  800253:	6a 23                	push   $0x23
  800255:	68 87 22 80 00       	push   $0x802287
  80025a:	e8 89 12 00 00       	call   8014e8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 6a 22 80 00       	push   $0x80226a
  800295:	6a 23                	push   $0x23
  800297:	68 87 22 80 00       	push   $0x802287
  80029c:	e8 47 12 00 00       	call   8014e8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 6a 22 80 00       	push   $0x80226a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 87 22 80 00       	push   $0x802287
  8002de:	e8 05 12 00 00       	call   8014e8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 6a 22 80 00       	push   $0x80226a
  80033b:	6a 23                	push   $0x23
  80033d:	68 87 22 80 00       	push   $0x802287
  800342:	e8 a1 11 00 00       	call   8014e8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035f:	89 d1                	mov    %edx,%ecx
  800361:	89 d3                	mov    %edx,%ebx
  800363:	89 d7                	mov    %edx,%edi
  800365:	89 d6                	mov    %edx,%esi
  800367:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	05 00 00 00 30       	add    $0x30000000,%eax
  800379:	c1 e8 0c             	shr    $0xc,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800381:	8b 45 08             	mov    0x8(%ebp),%eax
  800384:	05 00 00 00 30       	add    $0x30000000,%eax
  800389:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80038e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a0:	89 c2                	mov    %eax,%edx
  8003a2:	c1 ea 16             	shr    $0x16,%edx
  8003a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ac:	f6 c2 01             	test   $0x1,%dl
  8003af:	74 11                	je     8003c2 <fd_alloc+0x2d>
  8003b1:	89 c2                	mov    %eax,%edx
  8003b3:	c1 ea 0c             	shr    $0xc,%edx
  8003b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003bd:	f6 c2 01             	test   $0x1,%dl
  8003c0:	75 09                	jne    8003cb <fd_alloc+0x36>
			*fd_store = fd;
  8003c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c9:	eb 17                	jmp    8003e2 <fd_alloc+0x4d>
  8003cb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d5:	75 c9                	jne    8003a0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003dd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    

008003e4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ea:	83 f8 1f             	cmp    $0x1f,%eax
  8003ed:	77 36                	ja     800425 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003ef:	c1 e0 0c             	shl    $0xc,%eax
  8003f2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003f7:	89 c2                	mov    %eax,%edx
  8003f9:	c1 ea 16             	shr    $0x16,%edx
  8003fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800403:	f6 c2 01             	test   $0x1,%dl
  800406:	74 24                	je     80042c <fd_lookup+0x48>
  800408:	89 c2                	mov    %eax,%edx
  80040a:	c1 ea 0c             	shr    $0xc,%edx
  80040d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800414:	f6 c2 01             	test   $0x1,%dl
  800417:	74 1a                	je     800433 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800419:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041c:	89 02                	mov    %eax,(%edx)
	return 0;
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	eb 13                	jmp    800438 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042a:	eb 0c                	jmp    800438 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800431:	eb 05                	jmp    800438 <fd_lookup+0x54>
  800433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    

0080043a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800443:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800448:	eb 13                	jmp    80045d <dev_lookup+0x23>
  80044a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80044d:	39 08                	cmp    %ecx,(%eax)
  80044f:	75 0c                	jne    80045d <dev_lookup+0x23>
			*dev = devtab[i];
  800451:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800454:	89 01                	mov    %eax,(%ecx)
			return 0;
  800456:	b8 00 00 00 00       	mov    $0x0,%eax
  80045b:	eb 2e                	jmp    80048b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	75 e7                	jne    80044a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800463:	a1 08 40 80 00       	mov    0x804008,%eax
  800468:	8b 40 48             	mov    0x48(%eax),%eax
  80046b:	83 ec 04             	sub    $0x4,%esp
  80046e:	51                   	push   %ecx
  80046f:	50                   	push   %eax
  800470:	68 98 22 80 00       	push   $0x802298
  800475:	e8 47 11 00 00       	call   8015c1 <cprintf>
	*dev = 0;
  80047a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80047d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048b:	c9                   	leave  
  80048c:	c3                   	ret    

0080048d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	56                   	push   %esi
  800491:	53                   	push   %ebx
  800492:	83 ec 10             	sub    $0x10,%esp
  800495:	8b 75 08             	mov    0x8(%ebp),%esi
  800498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80049e:	50                   	push   %eax
  80049f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a5:	c1 e8 0c             	shr    $0xc,%eax
  8004a8:	50                   	push   %eax
  8004a9:	e8 36 ff ff ff       	call   8003e4 <fd_lookup>
  8004ae:	83 c4 08             	add    $0x8,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 05                	js     8004ba <fd_close+0x2d>
	    || fd != fd2)
  8004b5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b8:	74 0c                	je     8004c6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004ba:	84 db                	test   %bl,%bl
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c1:	0f 44 c2             	cmove  %edx,%eax
  8004c4:	eb 41                	jmp    800507 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004cc:	50                   	push   %eax
  8004cd:	ff 36                	pushl  (%esi)
  8004cf:	e8 66 ff ff ff       	call   80043a <dev_lookup>
  8004d4:	89 c3                	mov    %eax,%ebx
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	78 1a                	js     8004f7 <fd_close+0x6a>
		if (dev->dev_close)
  8004dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	74 0b                	je     8004f7 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004ec:	83 ec 0c             	sub    $0xc,%esp
  8004ef:	56                   	push   %esi
  8004f0:	ff d0                	call   *%eax
  8004f2:	89 c3                	mov    %eax,%ebx
  8004f4:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	56                   	push   %esi
  8004fb:	6a 00                	push   $0x0
  8004fd:	e8 e1 fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	89 d8                	mov    %ebx,%eax
}
  800507:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050a:	5b                   	pop    %ebx
  80050b:	5e                   	pop    %esi
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800517:	50                   	push   %eax
  800518:	ff 75 08             	pushl  0x8(%ebp)
  80051b:	e8 c4 fe ff ff       	call   8003e4 <fd_lookup>
  800520:	83 c4 08             	add    $0x8,%esp
  800523:	85 c0                	test   %eax,%eax
  800525:	78 10                	js     800537 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	6a 01                	push   $0x1
  80052c:	ff 75 f4             	pushl  -0xc(%ebp)
  80052f:	e8 59 ff ff ff       	call   80048d <fd_close>
  800534:	83 c4 10             	add    $0x10,%esp
}
  800537:	c9                   	leave  
  800538:	c3                   	ret    

00800539 <close_all>:

void
close_all(void)
{
  800539:	55                   	push   %ebp
  80053a:	89 e5                	mov    %esp,%ebp
  80053c:	53                   	push   %ebx
  80053d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800540:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800545:	83 ec 0c             	sub    $0xc,%esp
  800548:	53                   	push   %ebx
  800549:	e8 c0 ff ff ff       	call   80050e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80054e:	83 c3 01             	add    $0x1,%ebx
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	83 fb 20             	cmp    $0x20,%ebx
  800557:	75 ec                	jne    800545 <close_all+0xc>
		close(i);
}
  800559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    

0080055e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	57                   	push   %edi
  800562:	56                   	push   %esi
  800563:	53                   	push   %ebx
  800564:	83 ec 2c             	sub    $0x2c,%esp
  800567:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80056d:	50                   	push   %eax
  80056e:	ff 75 08             	pushl  0x8(%ebp)
  800571:	e8 6e fe ff ff       	call   8003e4 <fd_lookup>
  800576:	83 c4 08             	add    $0x8,%esp
  800579:	85 c0                	test   %eax,%eax
  80057b:	0f 88 c1 00 00 00    	js     800642 <dup+0xe4>
		return r;
	close(newfdnum);
  800581:	83 ec 0c             	sub    $0xc,%esp
  800584:	56                   	push   %esi
  800585:	e8 84 ff ff ff       	call   80050e <close>

	newfd = INDEX2FD(newfdnum);
  80058a:	89 f3                	mov    %esi,%ebx
  80058c:	c1 e3 0c             	shl    $0xc,%ebx
  80058f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800595:	83 c4 04             	add    $0x4,%esp
  800598:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059b:	e8 de fd ff ff       	call   80037e <fd2data>
  8005a0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a2:	89 1c 24             	mov    %ebx,(%esp)
  8005a5:	e8 d4 fd ff ff       	call   80037e <fd2data>
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b0:	89 f8                	mov    %edi,%eax
  8005b2:	c1 e8 16             	shr    $0x16,%eax
  8005b5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005bc:	a8 01                	test   $0x1,%al
  8005be:	74 37                	je     8005f7 <dup+0x99>
  8005c0:	89 f8                	mov    %edi,%eax
  8005c2:	c1 e8 0c             	shr    $0xc,%eax
  8005c5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005cc:	f6 c2 01             	test   $0x1,%dl
  8005cf:	74 26                	je     8005f7 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e0:	50                   	push   %eax
  8005e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e4:	6a 00                	push   $0x0
  8005e6:	57                   	push   %edi
  8005e7:	6a 00                	push   $0x0
  8005e9:	e8 b3 fb ff ff       	call   8001a1 <sys_page_map>
  8005ee:	89 c7                	mov    %eax,%edi
  8005f0:	83 c4 20             	add    $0x20,%esp
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	78 2e                	js     800625 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fa:	89 d0                	mov    %edx,%eax
  8005fc:	c1 e8 0c             	shr    $0xc,%eax
  8005ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	25 07 0e 00 00       	and    $0xe07,%eax
  80060e:	50                   	push   %eax
  80060f:	53                   	push   %ebx
  800610:	6a 00                	push   $0x0
  800612:	52                   	push   %edx
  800613:	6a 00                	push   $0x0
  800615:	e8 87 fb ff ff       	call   8001a1 <sys_page_map>
  80061a:	89 c7                	mov    %eax,%edi
  80061c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80061f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800621:	85 ff                	test   %edi,%edi
  800623:	79 1d                	jns    800642 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 00                	push   $0x0
  80062b:	e8 b3 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800630:	83 c4 08             	add    $0x8,%esp
  800633:	ff 75 d4             	pushl  -0x2c(%ebp)
  800636:	6a 00                	push   $0x0
  800638:	e8 a6 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	89 f8                	mov    %edi,%eax
}
  800642:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800645:	5b                   	pop    %ebx
  800646:	5e                   	pop    %esi
  800647:	5f                   	pop    %edi
  800648:	5d                   	pop    %ebp
  800649:	c3                   	ret    

0080064a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	53                   	push   %ebx
  80064e:	83 ec 14             	sub    $0x14,%esp
  800651:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800654:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800657:	50                   	push   %eax
  800658:	53                   	push   %ebx
  800659:	e8 86 fd ff ff       	call   8003e4 <fd_lookup>
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	89 c2                	mov    %eax,%edx
  800663:	85 c0                	test   %eax,%eax
  800665:	78 6d                	js     8006d4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80066d:	50                   	push   %eax
  80066e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800671:	ff 30                	pushl  (%eax)
  800673:	e8 c2 fd ff ff       	call   80043a <dev_lookup>
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	85 c0                	test   %eax,%eax
  80067d:	78 4c                	js     8006cb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80067f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800682:	8b 42 08             	mov    0x8(%edx),%eax
  800685:	83 e0 03             	and    $0x3,%eax
  800688:	83 f8 01             	cmp    $0x1,%eax
  80068b:	75 21                	jne    8006ae <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068d:	a1 08 40 80 00       	mov    0x804008,%eax
  800692:	8b 40 48             	mov    0x48(%eax),%eax
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	53                   	push   %ebx
  800699:	50                   	push   %eax
  80069a:	68 d9 22 80 00       	push   $0x8022d9
  80069f:	e8 1d 0f 00 00       	call   8015c1 <cprintf>
		return -E_INVAL;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006ac:	eb 26                	jmp    8006d4 <read+0x8a>
	}
	if (!dev->dev_read)
  8006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b1:	8b 40 08             	mov    0x8(%eax),%eax
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	74 17                	je     8006cf <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b8:	83 ec 04             	sub    $0x4,%esp
  8006bb:	ff 75 10             	pushl  0x10(%ebp)
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	52                   	push   %edx
  8006c2:	ff d0                	call   *%eax
  8006c4:	89 c2                	mov    %eax,%edx
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	eb 09                	jmp    8006d4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cb:	89 c2                	mov    %eax,%edx
  8006cd:	eb 05                	jmp    8006d4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d4:	89 d0                	mov    %edx,%eax
  8006d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	57                   	push   %edi
  8006df:	56                   	push   %esi
  8006e0:	53                   	push   %ebx
  8006e1:	83 ec 0c             	sub    $0xc,%esp
  8006e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ef:	eb 21                	jmp    800712 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f1:	83 ec 04             	sub    $0x4,%esp
  8006f4:	89 f0                	mov    %esi,%eax
  8006f6:	29 d8                	sub    %ebx,%eax
  8006f8:	50                   	push   %eax
  8006f9:	89 d8                	mov    %ebx,%eax
  8006fb:	03 45 0c             	add    0xc(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	57                   	push   %edi
  800700:	e8 45 ff ff ff       	call   80064a <read>
		if (m < 0)
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	85 c0                	test   %eax,%eax
  80070a:	78 10                	js     80071c <readn+0x41>
			return m;
		if (m == 0)
  80070c:	85 c0                	test   %eax,%eax
  80070e:	74 0a                	je     80071a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800710:	01 c3                	add    %eax,%ebx
  800712:	39 f3                	cmp    %esi,%ebx
  800714:	72 db                	jb     8006f1 <readn+0x16>
  800716:	89 d8                	mov    %ebx,%eax
  800718:	eb 02                	jmp    80071c <readn+0x41>
  80071a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80071c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071f:	5b                   	pop    %ebx
  800720:	5e                   	pop    %esi
  800721:	5f                   	pop    %edi
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	53                   	push   %ebx
  800728:	83 ec 14             	sub    $0x14,%esp
  80072b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	53                   	push   %ebx
  800733:	e8 ac fc ff ff       	call   8003e4 <fd_lookup>
  800738:	83 c4 08             	add    $0x8,%esp
  80073b:	89 c2                	mov    %eax,%edx
  80073d:	85 c0                	test   %eax,%eax
  80073f:	78 68                	js     8007a9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800747:	50                   	push   %eax
  800748:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074b:	ff 30                	pushl  (%eax)
  80074d:	e8 e8 fc ff ff       	call   80043a <dev_lookup>
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	85 c0                	test   %eax,%eax
  800757:	78 47                	js     8007a0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800759:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800760:	75 21                	jne    800783 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800762:	a1 08 40 80 00       	mov    0x804008,%eax
  800767:	8b 40 48             	mov    0x48(%eax),%eax
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	53                   	push   %ebx
  80076e:	50                   	push   %eax
  80076f:	68 f5 22 80 00       	push   $0x8022f5
  800774:	e8 48 0e 00 00       	call   8015c1 <cprintf>
		return -E_INVAL;
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800781:	eb 26                	jmp    8007a9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800783:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800786:	8b 52 0c             	mov    0xc(%edx),%edx
  800789:	85 d2                	test   %edx,%edx
  80078b:	74 17                	je     8007a4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80078d:	83 ec 04             	sub    $0x4,%esp
  800790:	ff 75 10             	pushl  0x10(%ebp)
  800793:	ff 75 0c             	pushl  0xc(%ebp)
  800796:	50                   	push   %eax
  800797:	ff d2                	call   *%edx
  800799:	89 c2                	mov    %eax,%edx
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	eb 09                	jmp    8007a9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a0:	89 c2                	mov    %eax,%edx
  8007a2:	eb 05                	jmp    8007a9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a9:	89 d0                	mov    %edx,%eax
  8007ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007b6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 08             	pushl  0x8(%ebp)
  8007bd:	e8 22 fc ff ff       	call   8003e4 <fd_lookup>
  8007c2:	83 c4 08             	add    $0x8,%esp
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	78 0e                	js     8007d7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	83 ec 14             	sub    $0x14,%esp
  8007e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e6:	50                   	push   %eax
  8007e7:	53                   	push   %ebx
  8007e8:	e8 f7 fb ff ff       	call   8003e4 <fd_lookup>
  8007ed:	83 c4 08             	add    $0x8,%esp
  8007f0:	89 c2                	mov    %eax,%edx
  8007f2:	85 c0                	test   %eax,%eax
  8007f4:	78 65                	js     80085b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007fc:	50                   	push   %eax
  8007fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800800:	ff 30                	pushl  (%eax)
  800802:	e8 33 fc ff ff       	call   80043a <dev_lookup>
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 44                	js     800852 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80080e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800811:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800815:	75 21                	jne    800838 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800817:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80081c:	8b 40 48             	mov    0x48(%eax),%eax
  80081f:	83 ec 04             	sub    $0x4,%esp
  800822:	53                   	push   %ebx
  800823:	50                   	push   %eax
  800824:	68 b8 22 80 00       	push   $0x8022b8
  800829:	e8 93 0d 00 00       	call   8015c1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800836:	eb 23                	jmp    80085b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800838:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083b:	8b 52 18             	mov    0x18(%edx),%edx
  80083e:	85 d2                	test   %edx,%edx
  800840:	74 14                	je     800856 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	ff 75 0c             	pushl  0xc(%ebp)
  800848:	50                   	push   %eax
  800849:	ff d2                	call   *%edx
  80084b:	89 c2                	mov    %eax,%edx
  80084d:	83 c4 10             	add    $0x10,%esp
  800850:	eb 09                	jmp    80085b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800852:	89 c2                	mov    %eax,%edx
  800854:	eb 05                	jmp    80085b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800856:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085b:	89 d0                	mov    %edx,%eax
  80085d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	53                   	push   %ebx
  800866:	83 ec 14             	sub    $0x14,%esp
  800869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086f:	50                   	push   %eax
  800870:	ff 75 08             	pushl  0x8(%ebp)
  800873:	e8 6c fb ff ff       	call   8003e4 <fd_lookup>
  800878:	83 c4 08             	add    $0x8,%esp
  80087b:	89 c2                	mov    %eax,%edx
  80087d:	85 c0                	test   %eax,%eax
  80087f:	78 58                	js     8008d9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800887:	50                   	push   %eax
  800888:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088b:	ff 30                	pushl  (%eax)
  80088d:	e8 a8 fb ff ff       	call   80043a <dev_lookup>
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	85 c0                	test   %eax,%eax
  800897:	78 37                	js     8008d0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a0:	74 32                	je     8008d4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ac:	00 00 00 
	stat->st_isdir = 0;
  8008af:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008b6:	00 00 00 
	stat->st_dev = dev;
  8008b9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	53                   	push   %ebx
  8008c3:	ff 75 f0             	pushl  -0x10(%ebp)
  8008c6:	ff 50 14             	call   *0x14(%eax)
  8008c9:	89 c2                	mov    %eax,%edx
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	eb 09                	jmp    8008d9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d0:	89 c2                	mov    %eax,%edx
  8008d2:	eb 05                	jmp    8008d9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d9:	89 d0                	mov    %edx,%eax
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	56                   	push   %esi
  8008e4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	6a 00                	push   $0x0
  8008ea:	ff 75 08             	pushl  0x8(%ebp)
  8008ed:	e8 0c 02 00 00       	call   800afe <open>
  8008f2:	89 c3                	mov    %eax,%ebx
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	85 c0                	test   %eax,%eax
  8008f9:	78 1b                	js     800916 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	ff 75 0c             	pushl  0xc(%ebp)
  800901:	50                   	push   %eax
  800902:	e8 5b ff ff ff       	call   800862 <fstat>
  800907:	89 c6                	mov    %eax,%esi
	close(fd);
  800909:	89 1c 24             	mov    %ebx,(%esp)
  80090c:	e8 fd fb ff ff       	call   80050e <close>
	return r;
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	89 f0                	mov    %esi,%eax
}
  800916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	89 c6                	mov    %eax,%esi
  800924:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800926:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80092d:	75 12                	jne    800941 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80092f:	83 ec 0c             	sub    $0xc,%esp
  800932:	6a 01                	push   $0x1
  800934:	e8 11 16 00 00       	call   801f4a <ipc_find_env>
  800939:	a3 00 40 80 00       	mov    %eax,0x804000
  80093e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800941:	6a 07                	push   $0x7
  800943:	68 00 50 80 00       	push   $0x805000
  800948:	56                   	push   %esi
  800949:	ff 35 00 40 80 00    	pushl  0x804000
  80094f:	e8 a2 15 00 00       	call   801ef6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800954:	83 c4 0c             	add    $0xc,%esp
  800957:	6a 00                	push   $0x0
  800959:	53                   	push   %ebx
  80095a:	6a 00                	push   $0x0
  80095c:	e8 2c 15 00 00       	call   801e8d <ipc_recv>
}
  800961:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 40 0c             	mov    0xc(%eax),%eax
  800974:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800979:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800981:	ba 00 00 00 00       	mov    $0x0,%edx
  800986:	b8 02 00 00 00       	mov    $0x2,%eax
  80098b:	e8 8d ff ff ff       	call   80091d <fsipc>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
  80099b:	8b 40 0c             	mov    0xc(%eax),%eax
  80099e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a8:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ad:	e8 6b ff ff ff       	call   80091d <fsipc>
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	83 ec 04             	sub    $0x4,%esp
  8009bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ce:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d3:	e8 45 ff ff ff       	call   80091d <fsipc>
  8009d8:	85 c0                	test   %eax,%eax
  8009da:	78 2c                	js     800a08 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009dc:	83 ec 08             	sub    $0x8,%esp
  8009df:	68 00 50 80 00       	push   $0x805000
  8009e4:	53                   	push   %ebx
  8009e5:	e8 5c 11 00 00       	call   801b46 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ea:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ef:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f5:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fa:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	53                   	push   %ebx
  800a11:	83 ec 08             	sub    $0x8,%esp
  800a14:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a17:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1a:	8b 52 0c             	mov    0xc(%edx),%edx
  800a1d:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a23:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a28:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a2d:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a30:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a36:	53                   	push   %ebx
  800a37:	ff 75 0c             	pushl  0xc(%ebp)
  800a3a:	68 08 50 80 00       	push   $0x805008
  800a3f:	e8 94 12 00 00       	call   801cd8 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	b8 04 00 00 00       	mov    $0x4,%eax
  800a4e:	e8 ca fe ff ff       	call   80091d <fsipc>
  800a53:	83 c4 10             	add    $0x10,%esp
  800a56:	85 c0                	test   %eax,%eax
  800a58:	78 1d                	js     800a77 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  800a5a:	39 d8                	cmp    %ebx,%eax
  800a5c:	76 19                	jbe    800a77 <devfile_write+0x6a>
  800a5e:	68 28 23 80 00       	push   $0x802328
  800a63:	68 34 23 80 00       	push   $0x802334
  800a68:	68 a3 00 00 00       	push   $0xa3
  800a6d:	68 49 23 80 00       	push   $0x802349
  800a72:	e8 71 0a 00 00       	call   8014e8 <_panic>
	return r;
}
  800a77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a95:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9f:	e8 79 fe ff ff       	call   80091d <fsipc>
  800aa4:	89 c3                	mov    %eax,%ebx
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	78 4b                	js     800af5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aaa:	39 c6                	cmp    %eax,%esi
  800aac:	73 16                	jae    800ac4 <devfile_read+0x48>
  800aae:	68 54 23 80 00       	push   $0x802354
  800ab3:	68 34 23 80 00       	push   $0x802334
  800ab8:	6a 7c                	push   $0x7c
  800aba:	68 49 23 80 00       	push   $0x802349
  800abf:	e8 24 0a 00 00       	call   8014e8 <_panic>
	assert(r <= PGSIZE);
  800ac4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac9:	7e 16                	jle    800ae1 <devfile_read+0x65>
  800acb:	68 5b 23 80 00       	push   $0x80235b
  800ad0:	68 34 23 80 00       	push   $0x802334
  800ad5:	6a 7d                	push   $0x7d
  800ad7:	68 49 23 80 00       	push   $0x802349
  800adc:	e8 07 0a 00 00       	call   8014e8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae1:	83 ec 04             	sub    $0x4,%esp
  800ae4:	50                   	push   %eax
  800ae5:	68 00 50 80 00       	push   $0x805000
  800aea:	ff 75 0c             	pushl  0xc(%ebp)
  800aed:	e8 e6 11 00 00       	call   801cd8 <memmove>
	return r;
  800af2:	83 c4 10             	add    $0x10,%esp
}
  800af5:	89 d8                	mov    %ebx,%eax
  800af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	53                   	push   %ebx
  800b02:	83 ec 20             	sub    $0x20,%esp
  800b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b08:	53                   	push   %ebx
  800b09:	e8 ff 0f 00 00       	call   801b0d <strlen>
  800b0e:	83 c4 10             	add    $0x10,%esp
  800b11:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b16:	7f 67                	jg     800b7f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1e:	50                   	push   %eax
  800b1f:	e8 71 f8 ff ff       	call   800395 <fd_alloc>
  800b24:	83 c4 10             	add    $0x10,%esp
		return r;
  800b27:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	78 57                	js     800b84 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b2d:	83 ec 08             	sub    $0x8,%esp
  800b30:	53                   	push   %ebx
  800b31:	68 00 50 80 00       	push   $0x805000
  800b36:	e8 0b 10 00 00       	call   801b46 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b46:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4b:	e8 cd fd ff ff       	call   80091d <fsipc>
  800b50:	89 c3                	mov    %eax,%ebx
  800b52:	83 c4 10             	add    $0x10,%esp
  800b55:	85 c0                	test   %eax,%eax
  800b57:	79 14                	jns    800b6d <open+0x6f>
		fd_close(fd, 0);
  800b59:	83 ec 08             	sub    $0x8,%esp
  800b5c:	6a 00                	push   $0x0
  800b5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b61:	e8 27 f9 ff ff       	call   80048d <fd_close>
		return r;
  800b66:	83 c4 10             	add    $0x10,%esp
  800b69:	89 da                	mov    %ebx,%edx
  800b6b:	eb 17                	jmp    800b84 <open+0x86>
	}

	return fd2num(fd);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	ff 75 f4             	pushl  -0xc(%ebp)
  800b73:	e8 f6 f7 ff ff       	call   80036e <fd2num>
  800b78:	89 c2                	mov    %eax,%edx
  800b7a:	83 c4 10             	add    $0x10,%esp
  800b7d:	eb 05                	jmp    800b84 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b84:	89 d0                	mov    %edx,%eax
  800b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
  800b96:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9b:	e8 7d fd ff ff       	call   80091d <fsipc>
}
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba8:	68 67 23 80 00       	push   $0x802367
  800bad:	ff 75 0c             	pushl  0xc(%ebp)
  800bb0:	e8 91 0f 00 00       	call   801b46 <strcpy>
	return 0;
}
  800bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 10             	sub    $0x10,%esp
  800bc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc6:	53                   	push   %ebx
  800bc7:	e8 b7 13 00 00       	call   801f83 <pageref>
  800bcc:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd4:	83 f8 01             	cmp    $0x1,%eax
  800bd7:	75 10                	jne    800be9 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	ff 73 0c             	pushl  0xc(%ebx)
  800bdf:	e8 c0 02 00 00       	call   800ea4 <nsipc_close>
  800be4:	89 c2                	mov    %eax,%edx
  800be6:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800be9:	89 d0                	mov    %edx,%eax
  800beb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf6:	6a 00                	push   $0x0
  800bf8:	ff 75 10             	pushl  0x10(%ebp)
  800bfb:	ff 75 0c             	pushl  0xc(%ebp)
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	ff 70 0c             	pushl  0xc(%eax)
  800c04:	e8 78 03 00 00       	call   800f81 <nsipc_send>
}
  800c09:	c9                   	leave  
  800c0a:	c3                   	ret    

00800c0b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c11:	6a 00                	push   $0x0
  800c13:	ff 75 10             	pushl  0x10(%ebp)
  800c16:	ff 75 0c             	pushl  0xc(%ebp)
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	ff 70 0c             	pushl  0xc(%eax)
  800c1f:	e8 f1 02 00 00       	call   800f15 <nsipc_recv>
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c2c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c2f:	52                   	push   %edx
  800c30:	50                   	push   %eax
  800c31:	e8 ae f7 ff ff       	call   8003e4 <fd_lookup>
  800c36:	83 c4 10             	add    $0x10,%esp
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	78 17                	js     800c54 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c40:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c46:	39 08                	cmp    %ecx,(%eax)
  800c48:	75 05                	jne    800c4f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c4a:	8b 40 0c             	mov    0xc(%eax),%eax
  800c4d:	eb 05                	jmp    800c54 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c4f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c54:	c9                   	leave  
  800c55:	c3                   	ret    

00800c56 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 1c             	sub    $0x1c,%esp
  800c5e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c63:	50                   	push   %eax
  800c64:	e8 2c f7 ff ff       	call   800395 <fd_alloc>
  800c69:	89 c3                	mov    %eax,%ebx
  800c6b:	83 c4 10             	add    $0x10,%esp
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	78 1b                	js     800c8d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c72:	83 ec 04             	sub    $0x4,%esp
  800c75:	68 07 04 00 00       	push   $0x407
  800c7a:	ff 75 f4             	pushl  -0xc(%ebp)
  800c7d:	6a 00                	push   $0x0
  800c7f:	e8 da f4 ff ff       	call   80015e <sys_page_alloc>
  800c84:	89 c3                	mov    %eax,%ebx
  800c86:	83 c4 10             	add    $0x10,%esp
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	79 10                	jns    800c9d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	56                   	push   %esi
  800c91:	e8 0e 02 00 00       	call   800ea4 <nsipc_close>
		return r;
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	89 d8                	mov    %ebx,%eax
  800c9b:	eb 24                	jmp    800cc1 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c9d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cb2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb5:	83 ec 0c             	sub    $0xc,%esp
  800cb8:	50                   	push   %eax
  800cb9:	e8 b0 f6 ff ff       	call   80036e <fd2num>
  800cbe:	83 c4 10             	add    $0x10,%esp
}
  800cc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	e8 50 ff ff ff       	call   800c26 <fd2sockid>
		return r;
  800cd6:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	78 1f                	js     800cfb <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cdc:	83 ec 04             	sub    $0x4,%esp
  800cdf:	ff 75 10             	pushl  0x10(%ebp)
  800ce2:	ff 75 0c             	pushl  0xc(%ebp)
  800ce5:	50                   	push   %eax
  800ce6:	e8 12 01 00 00       	call   800dfd <nsipc_accept>
  800ceb:	83 c4 10             	add    $0x10,%esp
		return r;
  800cee:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	78 07                	js     800cfb <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf4:	e8 5d ff ff ff       	call   800c56 <alloc_sockfd>
  800cf9:	89 c1                	mov    %eax,%ecx
}
  800cfb:	89 c8                	mov    %ecx,%eax
  800cfd:	c9                   	leave  
  800cfe:	c3                   	ret    

00800cff <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d05:	8b 45 08             	mov    0x8(%ebp),%eax
  800d08:	e8 19 ff ff ff       	call   800c26 <fd2sockid>
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	78 12                	js     800d23 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d11:	83 ec 04             	sub    $0x4,%esp
  800d14:	ff 75 10             	pushl  0x10(%ebp)
  800d17:	ff 75 0c             	pushl  0xc(%ebp)
  800d1a:	50                   	push   %eax
  800d1b:	e8 2d 01 00 00       	call   800e4d <nsipc_bind>
  800d20:	83 c4 10             	add    $0x10,%esp
}
  800d23:	c9                   	leave  
  800d24:	c3                   	ret    

00800d25 <shutdown>:

int
shutdown(int s, int how)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	e8 f3 fe ff ff       	call   800c26 <fd2sockid>
  800d33:	85 c0                	test   %eax,%eax
  800d35:	78 0f                	js     800d46 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d37:	83 ec 08             	sub    $0x8,%esp
  800d3a:	ff 75 0c             	pushl  0xc(%ebp)
  800d3d:	50                   	push   %eax
  800d3e:	e8 3f 01 00 00       	call   800e82 <nsipc_shutdown>
  800d43:	83 c4 10             	add    $0x10,%esp
}
  800d46:	c9                   	leave  
  800d47:	c3                   	ret    

00800d48 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	e8 d0 fe ff ff       	call   800c26 <fd2sockid>
  800d56:	85 c0                	test   %eax,%eax
  800d58:	78 12                	js     800d6c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d5a:	83 ec 04             	sub    $0x4,%esp
  800d5d:	ff 75 10             	pushl  0x10(%ebp)
  800d60:	ff 75 0c             	pushl  0xc(%ebp)
  800d63:	50                   	push   %eax
  800d64:	e8 55 01 00 00       	call   800ebe <nsipc_connect>
  800d69:	83 c4 10             	add    $0x10,%esp
}
  800d6c:	c9                   	leave  
  800d6d:	c3                   	ret    

00800d6e <listen>:

int
listen(int s, int backlog)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	e8 aa fe ff ff       	call   800c26 <fd2sockid>
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	78 0f                	js     800d8f <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d80:	83 ec 08             	sub    $0x8,%esp
  800d83:	ff 75 0c             	pushl  0xc(%ebp)
  800d86:	50                   	push   %eax
  800d87:	e8 67 01 00 00       	call   800ef3 <nsipc_listen>
  800d8c:	83 c4 10             	add    $0x10,%esp
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d97:	ff 75 10             	pushl  0x10(%ebp)
  800d9a:	ff 75 0c             	pushl  0xc(%ebp)
  800d9d:	ff 75 08             	pushl  0x8(%ebp)
  800da0:	e8 3a 02 00 00       	call   800fdf <nsipc_socket>
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	85 c0                	test   %eax,%eax
  800daa:	78 05                	js     800db1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dac:	e8 a5 fe ff ff       	call   800c56 <alloc_sockfd>
}
  800db1:	c9                   	leave  
  800db2:	c3                   	ret    

00800db3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	53                   	push   %ebx
  800db7:	83 ec 04             	sub    $0x4,%esp
  800dba:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dbc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc3:	75 12                	jne    800dd7 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	6a 02                	push   $0x2
  800dca:	e8 7b 11 00 00       	call   801f4a <ipc_find_env>
  800dcf:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dd7:	6a 07                	push   $0x7
  800dd9:	68 00 60 80 00       	push   $0x806000
  800dde:	53                   	push   %ebx
  800ddf:	ff 35 04 40 80 00    	pushl  0x804004
  800de5:	e8 0c 11 00 00       	call   801ef6 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dea:	83 c4 0c             	add    $0xc,%esp
  800ded:	6a 00                	push   $0x0
  800def:	6a 00                	push   $0x0
  800df1:	6a 00                	push   $0x0
  800df3:	e8 95 10 00 00       	call   801e8d <ipc_recv>
}
  800df8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e0d:	8b 06                	mov    (%esi),%eax
  800e0f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e14:	b8 01 00 00 00       	mov    $0x1,%eax
  800e19:	e8 95 ff ff ff       	call   800db3 <nsipc>
  800e1e:	89 c3                	mov    %eax,%ebx
  800e20:	85 c0                	test   %eax,%eax
  800e22:	78 20                	js     800e44 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e24:	83 ec 04             	sub    $0x4,%esp
  800e27:	ff 35 10 60 80 00    	pushl  0x806010
  800e2d:	68 00 60 80 00       	push   $0x806000
  800e32:	ff 75 0c             	pushl  0xc(%ebp)
  800e35:	e8 9e 0e 00 00       	call   801cd8 <memmove>
		*addrlen = ret->ret_addrlen;
  800e3a:	a1 10 60 80 00       	mov    0x806010,%eax
  800e3f:	89 06                	mov    %eax,(%esi)
  800e41:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e44:	89 d8                	mov    %ebx,%eax
  800e46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	53                   	push   %ebx
  800e51:	83 ec 08             	sub    $0x8,%esp
  800e54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e5f:	53                   	push   %ebx
  800e60:	ff 75 0c             	pushl  0xc(%ebp)
  800e63:	68 04 60 80 00       	push   $0x806004
  800e68:	e8 6b 0e 00 00       	call   801cd8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e6d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e73:	b8 02 00 00 00       	mov    $0x2,%eax
  800e78:	e8 36 ff ff ff       	call   800db3 <nsipc>
}
  800e7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e93:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e98:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9d:	e8 11 ff ff ff       	call   800db3 <nsipc>
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ead:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb2:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb7:	e8 f7 fe ff ff       	call   800db3 <nsipc>
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	53                   	push   %ebx
  800ec2:	83 ec 08             	sub    $0x8,%esp
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed0:	53                   	push   %ebx
  800ed1:	ff 75 0c             	pushl  0xc(%ebp)
  800ed4:	68 04 60 80 00       	push   $0x806004
  800ed9:	e8 fa 0d 00 00       	call   801cd8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ede:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee9:	e8 c5 fe ff ff       	call   800db3 <nsipc>
}
  800eee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f04:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f09:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0e:	e8 a0 fe ff ff       	call   800db3 <nsipc>
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f20:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f25:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2e:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f33:	b8 07 00 00 00       	mov    $0x7,%eax
  800f38:	e8 76 fe ff ff       	call   800db3 <nsipc>
  800f3d:	89 c3                	mov    %eax,%ebx
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 35                	js     800f78 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f43:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f48:	7f 04                	jg     800f4e <nsipc_recv+0x39>
  800f4a:	39 c6                	cmp    %eax,%esi
  800f4c:	7d 16                	jge    800f64 <nsipc_recv+0x4f>
  800f4e:	68 73 23 80 00       	push   $0x802373
  800f53:	68 34 23 80 00       	push   $0x802334
  800f58:	6a 62                	push   $0x62
  800f5a:	68 88 23 80 00       	push   $0x802388
  800f5f:	e8 84 05 00 00       	call   8014e8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f64:	83 ec 04             	sub    $0x4,%esp
  800f67:	50                   	push   %eax
  800f68:	68 00 60 80 00       	push   $0x806000
  800f6d:	ff 75 0c             	pushl  0xc(%ebp)
  800f70:	e8 63 0d 00 00       	call   801cd8 <memmove>
  800f75:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f78:	89 d8                	mov    %ebx,%eax
  800f7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	53                   	push   %ebx
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f93:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f99:	7e 16                	jle    800fb1 <nsipc_send+0x30>
  800f9b:	68 94 23 80 00       	push   $0x802394
  800fa0:	68 34 23 80 00       	push   $0x802334
  800fa5:	6a 6d                	push   $0x6d
  800fa7:	68 88 23 80 00       	push   $0x802388
  800fac:	e8 37 05 00 00       	call   8014e8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb1:	83 ec 04             	sub    $0x4,%esp
  800fb4:	53                   	push   %ebx
  800fb5:	ff 75 0c             	pushl  0xc(%ebp)
  800fb8:	68 0c 60 80 00       	push   $0x80600c
  800fbd:	e8 16 0d 00 00       	call   801cd8 <memmove>
	nsipcbuf.send.req_size = size;
  800fc2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd5:	e8 d9 fd ff ff       	call   800db3 <nsipc>
}
  800fda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ffd:	b8 09 00 00 00       	mov    $0x9,%eax
  801002:	e8 ac fd ff ff       	call   800db3 <nsipc>
}
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
  80100e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	ff 75 08             	pushl  0x8(%ebp)
  801017:	e8 62 f3 ff ff       	call   80037e <fd2data>
  80101c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80101e:	83 c4 08             	add    $0x8,%esp
  801021:	68 a0 23 80 00       	push   $0x8023a0
  801026:	53                   	push   %ebx
  801027:	e8 1a 0b 00 00       	call   801b46 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102c:	8b 46 04             	mov    0x4(%esi),%eax
  80102f:	2b 06                	sub    (%esi),%eax
  801031:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801037:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80103e:	00 00 00 
	stat->st_dev = &devpipe;
  801041:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801048:	30 80 00 
	return 0;
}
  80104b:	b8 00 00 00 00       	mov    $0x0,%eax
  801050:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	53                   	push   %ebx
  80105b:	83 ec 0c             	sub    $0xc,%esp
  80105e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801061:	53                   	push   %ebx
  801062:	6a 00                	push   $0x0
  801064:	e8 7a f1 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801069:	89 1c 24             	mov    %ebx,(%esp)
  80106c:	e8 0d f3 ff ff       	call   80037e <fd2data>
  801071:	83 c4 08             	add    $0x8,%esp
  801074:	50                   	push   %eax
  801075:	6a 00                	push   $0x0
  801077:	e8 67 f1 ff ff       	call   8001e3 <sys_page_unmap>
}
  80107c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	57                   	push   %edi
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	83 ec 1c             	sub    $0x1c,%esp
  80108a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80108d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80108f:	a1 08 40 80 00       	mov    0x804008,%eax
  801094:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	ff 75 e0             	pushl  -0x20(%ebp)
  80109d:	e8 e1 0e 00 00       	call   801f83 <pageref>
  8010a2:	89 c3                	mov    %eax,%ebx
  8010a4:	89 3c 24             	mov    %edi,(%esp)
  8010a7:	e8 d7 0e 00 00       	call   801f83 <pageref>
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	39 c3                	cmp    %eax,%ebx
  8010b1:	0f 94 c1             	sete   %cl
  8010b4:	0f b6 c9             	movzbl %cl,%ecx
  8010b7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010ba:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010c0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c3:	39 ce                	cmp    %ecx,%esi
  8010c5:	74 1b                	je     8010e2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010c7:	39 c3                	cmp    %eax,%ebx
  8010c9:	75 c4                	jne    80108f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010cb:	8b 42 58             	mov    0x58(%edx),%eax
  8010ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d1:	50                   	push   %eax
  8010d2:	56                   	push   %esi
  8010d3:	68 a7 23 80 00       	push   $0x8023a7
  8010d8:	e8 e4 04 00 00       	call   8015c1 <cprintf>
  8010dd:	83 c4 10             	add    $0x10,%esp
  8010e0:	eb ad                	jmp    80108f <_pipeisclosed+0xe>
	}
}
  8010e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 28             	sub    $0x28,%esp
  8010f6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010f9:	56                   	push   %esi
  8010fa:	e8 7f f2 ff ff       	call   80037e <fd2data>
  8010ff:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	bf 00 00 00 00       	mov    $0x0,%edi
  801109:	eb 4b                	jmp    801156 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80110b:	89 da                	mov    %ebx,%edx
  80110d:	89 f0                	mov    %esi,%eax
  80110f:	e8 6d ff ff ff       	call   801081 <_pipeisclosed>
  801114:	85 c0                	test   %eax,%eax
  801116:	75 48                	jne    801160 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801118:	e8 22 f0 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80111d:	8b 43 04             	mov    0x4(%ebx),%eax
  801120:	8b 0b                	mov    (%ebx),%ecx
  801122:	8d 51 20             	lea    0x20(%ecx),%edx
  801125:	39 d0                	cmp    %edx,%eax
  801127:	73 e2                	jae    80110b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801129:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801130:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801133:	89 c2                	mov    %eax,%edx
  801135:	c1 fa 1f             	sar    $0x1f,%edx
  801138:	89 d1                	mov    %edx,%ecx
  80113a:	c1 e9 1b             	shr    $0x1b,%ecx
  80113d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801140:	83 e2 1f             	and    $0x1f,%edx
  801143:	29 ca                	sub    %ecx,%edx
  801145:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801149:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80114d:	83 c0 01             	add    $0x1,%eax
  801150:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801153:	83 c7 01             	add    $0x1,%edi
  801156:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801159:	75 c2                	jne    80111d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80115b:	8b 45 10             	mov    0x10(%ebp),%eax
  80115e:	eb 05                	jmp    801165 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801160:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801165:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5f                   	pop    %edi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	57                   	push   %edi
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	83 ec 18             	sub    $0x18,%esp
  801176:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801179:	57                   	push   %edi
  80117a:	e8 ff f1 ff ff       	call   80037e <fd2data>
  80117f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	bb 00 00 00 00       	mov    $0x0,%ebx
  801189:	eb 3d                	jmp    8011c8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80118b:	85 db                	test   %ebx,%ebx
  80118d:	74 04                	je     801193 <devpipe_read+0x26>
				return i;
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	eb 44                	jmp    8011d7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801193:	89 f2                	mov    %esi,%edx
  801195:	89 f8                	mov    %edi,%eax
  801197:	e8 e5 fe ff ff       	call   801081 <_pipeisclosed>
  80119c:	85 c0                	test   %eax,%eax
  80119e:	75 32                	jne    8011d2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011a0:	e8 9a ef ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a5:	8b 06                	mov    (%esi),%eax
  8011a7:	3b 46 04             	cmp    0x4(%esi),%eax
  8011aa:	74 df                	je     80118b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ac:	99                   	cltd   
  8011ad:	c1 ea 1b             	shr    $0x1b,%edx
  8011b0:	01 d0                	add    %edx,%eax
  8011b2:	83 e0 1f             	and    $0x1f,%eax
  8011b5:	29 d0                	sub    %edx,%eax
  8011b7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011c2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c5:	83 c3 01             	add    $0x1,%ebx
  8011c8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011cb:	75 d8                	jne    8011a5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d0:	eb 05                	jmp    8011d7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011da:	5b                   	pop    %ebx
  8011db:	5e                   	pop    %esi
  8011dc:	5f                   	pop    %edi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	56                   	push   %esi
  8011e3:	53                   	push   %ebx
  8011e4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ea:	50                   	push   %eax
  8011eb:	e8 a5 f1 ff ff       	call   800395 <fd_alloc>
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	89 c2                	mov    %eax,%edx
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	0f 88 2c 01 00 00    	js     801329 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011fd:	83 ec 04             	sub    $0x4,%esp
  801200:	68 07 04 00 00       	push   $0x407
  801205:	ff 75 f4             	pushl  -0xc(%ebp)
  801208:	6a 00                	push   $0x0
  80120a:	e8 4f ef ff ff       	call   80015e <sys_page_alloc>
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	89 c2                	mov    %eax,%edx
  801214:	85 c0                	test   %eax,%eax
  801216:	0f 88 0d 01 00 00    	js     801329 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80121c:	83 ec 0c             	sub    $0xc,%esp
  80121f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	e8 6d f1 ff ff       	call   800395 <fd_alloc>
  801228:	89 c3                	mov    %eax,%ebx
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	0f 88 e2 00 00 00    	js     801317 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801235:	83 ec 04             	sub    $0x4,%esp
  801238:	68 07 04 00 00       	push   $0x407
  80123d:	ff 75 f0             	pushl  -0x10(%ebp)
  801240:	6a 00                	push   $0x0
  801242:	e8 17 ef ff ff       	call   80015e <sys_page_alloc>
  801247:	89 c3                	mov    %eax,%ebx
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	85 c0                	test   %eax,%eax
  80124e:	0f 88 c3 00 00 00    	js     801317 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801254:	83 ec 0c             	sub    $0xc,%esp
  801257:	ff 75 f4             	pushl  -0xc(%ebp)
  80125a:	e8 1f f1 ff ff       	call   80037e <fd2data>
  80125f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801261:	83 c4 0c             	add    $0xc,%esp
  801264:	68 07 04 00 00       	push   $0x407
  801269:	50                   	push   %eax
  80126a:	6a 00                	push   $0x0
  80126c:	e8 ed ee ff ff       	call   80015e <sys_page_alloc>
  801271:	89 c3                	mov    %eax,%ebx
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	85 c0                	test   %eax,%eax
  801278:	0f 88 89 00 00 00    	js     801307 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127e:	83 ec 0c             	sub    $0xc,%esp
  801281:	ff 75 f0             	pushl  -0x10(%ebp)
  801284:	e8 f5 f0 ff ff       	call   80037e <fd2data>
  801289:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801290:	50                   	push   %eax
  801291:	6a 00                	push   $0x0
  801293:	56                   	push   %esi
  801294:	6a 00                	push   $0x0
  801296:	e8 06 ef ff ff       	call   8001a1 <sys_page_map>
  80129b:	89 c3                	mov    %eax,%ebx
  80129d:	83 c4 20             	add    $0x20,%esp
  8012a0:	85 c0                	test   %eax,%eax
  8012a2:	78 55                	js     8012f9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012b9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012ce:	83 ec 0c             	sub    $0xc,%esp
  8012d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d4:	e8 95 f0 ff ff       	call   80036e <fd2num>
  8012d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012dc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012de:	83 c4 04             	add    $0x4,%esp
  8012e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e4:	e8 85 f0 ff ff       	call   80036e <fd2num>
  8012e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f7:	eb 30                	jmp    801329 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	56                   	push   %esi
  8012fd:	6a 00                	push   $0x0
  8012ff:	e8 df ee ff ff       	call   8001e3 <sys_page_unmap>
  801304:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	ff 75 f0             	pushl  -0x10(%ebp)
  80130d:	6a 00                	push   $0x0
  80130f:	e8 cf ee ff ff       	call   8001e3 <sys_page_unmap>
  801314:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	ff 75 f4             	pushl  -0xc(%ebp)
  80131d:	6a 00                	push   $0x0
  80131f:	e8 bf ee ff ff       	call   8001e3 <sys_page_unmap>
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801329:	89 d0                	mov    %edx,%eax
  80132b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5e                   	pop    %esi
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801338:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133b:	50                   	push   %eax
  80133c:	ff 75 08             	pushl  0x8(%ebp)
  80133f:	e8 a0 f0 ff ff       	call   8003e4 <fd_lookup>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 18                	js     801363 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80134b:	83 ec 0c             	sub    $0xc,%esp
  80134e:	ff 75 f4             	pushl  -0xc(%ebp)
  801351:	e8 28 f0 ff ff       	call   80037e <fd2data>
	return _pipeisclosed(fd, p);
  801356:	89 c2                	mov    %eax,%edx
  801358:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135b:	e8 21 fd ff ff       	call   801081 <_pipeisclosed>
  801360:	83 c4 10             	add    $0x10,%esp
}
  801363:	c9                   	leave  
  801364:	c3                   	ret    

00801365 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801368:	b8 00 00 00 00       	mov    $0x0,%eax
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801375:	68 bf 23 80 00       	push   $0x8023bf
  80137a:	ff 75 0c             	pushl  0xc(%ebp)
  80137d:	e8 c4 07 00 00       	call   801b46 <strcpy>
	return 0;
}
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	57                   	push   %edi
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
  80138f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801395:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80139a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a0:	eb 2d                	jmp    8013cf <devcons_write+0x46>
		m = n - tot;
  8013a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013a7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013aa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013af:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	03 45 0c             	add    0xc(%ebp),%eax
  8013b9:	50                   	push   %eax
  8013ba:	57                   	push   %edi
  8013bb:	e8 18 09 00 00       	call   801cd8 <memmove>
		sys_cputs(buf, m);
  8013c0:	83 c4 08             	add    $0x8,%esp
  8013c3:	53                   	push   %ebx
  8013c4:	57                   	push   %edi
  8013c5:	e8 d8 ec ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ca:	01 de                	add    %ebx,%esi
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	89 f0                	mov    %esi,%eax
  8013d1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d4:	72 cc                	jb     8013a2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013ed:	74 2a                	je     801419 <devcons_read+0x3b>
  8013ef:	eb 05                	jmp    8013f6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f1:	e8 49 ed ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013f6:	e8 c5 ec ff ff       	call   8000c0 <sys_cgetc>
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	74 f2                	je     8013f1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013ff:	85 c0                	test   %eax,%eax
  801401:	78 16                	js     801419 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801403:	83 f8 04             	cmp    $0x4,%eax
  801406:	74 0c                	je     801414 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801408:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140b:	88 02                	mov    %al,(%edx)
	return 1;
  80140d:	b8 01 00 00 00       	mov    $0x1,%eax
  801412:	eb 05                	jmp    801419 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801414:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801421:	8b 45 08             	mov    0x8(%ebp),%eax
  801424:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801427:	6a 01                	push   $0x1
  801429:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142c:	50                   	push   %eax
  80142d:	e8 70 ec ff ff       	call   8000a2 <sys_cputs>
}
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <getchar>:

int
getchar(void)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80143d:	6a 01                	push   $0x1
  80143f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	6a 00                	push   $0x0
  801445:	e8 00 f2 ff ff       	call   80064a <read>
	if (r < 0)
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 0f                	js     801460 <getchar+0x29>
		return r;
	if (r < 1)
  801451:	85 c0                	test   %eax,%eax
  801453:	7e 06                	jle    80145b <getchar+0x24>
		return -E_EOF;
	return c;
  801455:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801459:	eb 05                	jmp    801460 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80145b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801468:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146b:	50                   	push   %eax
  80146c:	ff 75 08             	pushl  0x8(%ebp)
  80146f:	e8 70 ef ff ff       	call   8003e4 <fd_lookup>
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	85 c0                	test   %eax,%eax
  801479:	78 11                	js     80148c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80147b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801484:	39 10                	cmp    %edx,(%eax)
  801486:	0f 94 c0             	sete   %al
  801489:	0f b6 c0             	movzbl %al,%eax
}
  80148c:	c9                   	leave  
  80148d:	c3                   	ret    

0080148e <opencons>:

int
opencons(void)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	e8 f8 ee ff ff       	call   800395 <fd_alloc>
  80149d:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 3e                	js     8014e4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a6:	83 ec 04             	sub    $0x4,%esp
  8014a9:	68 07 04 00 00       	push   $0x407
  8014ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b1:	6a 00                	push   $0x0
  8014b3:	e8 a6 ec ff ff       	call   80015e <sys_page_alloc>
  8014b8:	83 c4 10             	add    $0x10,%esp
		return r;
  8014bb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 23                	js     8014e4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	50                   	push   %eax
  8014da:	e8 8f ee ff ff       	call   80036e <fd2num>
  8014df:	89 c2                	mov    %eax,%edx
  8014e1:	83 c4 10             	add    $0x10,%esp
}
  8014e4:	89 d0                	mov    %edx,%eax
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	56                   	push   %esi
  8014ec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014ed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014f0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014f6:	e8 25 ec ff ff       	call   800120 <sys_getenvid>
  8014fb:	83 ec 0c             	sub    $0xc,%esp
  8014fe:	ff 75 0c             	pushl  0xc(%ebp)
  801501:	ff 75 08             	pushl  0x8(%ebp)
  801504:	56                   	push   %esi
  801505:	50                   	push   %eax
  801506:	68 cc 23 80 00       	push   $0x8023cc
  80150b:	e8 b1 00 00 00       	call   8015c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801510:	83 c4 18             	add    $0x18,%esp
  801513:	53                   	push   %ebx
  801514:	ff 75 10             	pushl  0x10(%ebp)
  801517:	e8 54 00 00 00       	call   801570 <vcprintf>
	cprintf("\n");
  80151c:	c7 04 24 b8 23 80 00 	movl   $0x8023b8,(%esp)
  801523:	e8 99 00 00 00       	call   8015c1 <cprintf>
  801528:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80152b:	cc                   	int3   
  80152c:	eb fd                	jmp    80152b <_panic+0x43>

0080152e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	53                   	push   %ebx
  801532:	83 ec 04             	sub    $0x4,%esp
  801535:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801538:	8b 13                	mov    (%ebx),%edx
  80153a:	8d 42 01             	lea    0x1(%edx),%eax
  80153d:	89 03                	mov    %eax,(%ebx)
  80153f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801542:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801546:	3d ff 00 00 00       	cmp    $0xff,%eax
  80154b:	75 1a                	jne    801567 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	68 ff 00 00 00       	push   $0xff
  801555:	8d 43 08             	lea    0x8(%ebx),%eax
  801558:	50                   	push   %eax
  801559:	e8 44 eb ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  80155e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801564:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801567:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80156b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801579:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801580:	00 00 00 
	b.cnt = 0;
  801583:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80158a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80158d:	ff 75 0c             	pushl  0xc(%ebp)
  801590:	ff 75 08             	pushl  0x8(%ebp)
  801593:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	68 2e 15 80 00       	push   $0x80152e
  80159f:	e8 54 01 00 00       	call   8016f8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	e8 e9 ea ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8015b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015bf:	c9                   	leave  
  8015c0:	c3                   	ret    

008015c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015ca:	50                   	push   %eax
  8015cb:	ff 75 08             	pushl  0x8(%ebp)
  8015ce:	e8 9d ff ff ff       	call   801570 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d3:	c9                   	leave  
  8015d4:	c3                   	ret    

008015d5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	57                   	push   %edi
  8015d9:	56                   	push   %esi
  8015da:	53                   	push   %ebx
  8015db:	83 ec 1c             	sub    $0x1c,%esp
  8015de:	89 c7                	mov    %eax,%edi
  8015e0:	89 d6                	mov    %edx,%esi
  8015e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015f9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015fc:	39 d3                	cmp    %edx,%ebx
  8015fe:	72 05                	jb     801605 <printnum+0x30>
  801600:	39 45 10             	cmp    %eax,0x10(%ebp)
  801603:	77 45                	ja     80164a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801605:	83 ec 0c             	sub    $0xc,%esp
  801608:	ff 75 18             	pushl  0x18(%ebp)
  80160b:	8b 45 14             	mov    0x14(%ebp),%eax
  80160e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801611:	53                   	push   %ebx
  801612:	ff 75 10             	pushl  0x10(%ebp)
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161b:	ff 75 e0             	pushl  -0x20(%ebp)
  80161e:	ff 75 dc             	pushl  -0x24(%ebp)
  801621:	ff 75 d8             	pushl  -0x28(%ebp)
  801624:	e8 97 09 00 00       	call   801fc0 <__udivdi3>
  801629:	83 c4 18             	add    $0x18,%esp
  80162c:	52                   	push   %edx
  80162d:	50                   	push   %eax
  80162e:	89 f2                	mov    %esi,%edx
  801630:	89 f8                	mov    %edi,%eax
  801632:	e8 9e ff ff ff       	call   8015d5 <printnum>
  801637:	83 c4 20             	add    $0x20,%esp
  80163a:	eb 18                	jmp    801654 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	56                   	push   %esi
  801640:	ff 75 18             	pushl  0x18(%ebp)
  801643:	ff d7                	call   *%edi
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	eb 03                	jmp    80164d <printnum+0x78>
  80164a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80164d:	83 eb 01             	sub    $0x1,%ebx
  801650:	85 db                	test   %ebx,%ebx
  801652:	7f e8                	jg     80163c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	56                   	push   %esi
  801658:	83 ec 04             	sub    $0x4,%esp
  80165b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165e:	ff 75 e0             	pushl  -0x20(%ebp)
  801661:	ff 75 dc             	pushl  -0x24(%ebp)
  801664:	ff 75 d8             	pushl  -0x28(%ebp)
  801667:	e8 84 0a 00 00       	call   8020f0 <__umoddi3>
  80166c:	83 c4 14             	add    $0x14,%esp
  80166f:	0f be 80 ef 23 80 00 	movsbl 0x8023ef(%eax),%eax
  801676:	50                   	push   %eax
  801677:	ff d7                	call   *%edi
}
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5f                   	pop    %edi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801687:	83 fa 01             	cmp    $0x1,%edx
  80168a:	7e 0e                	jle    80169a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80168c:	8b 10                	mov    (%eax),%edx
  80168e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801691:	89 08                	mov    %ecx,(%eax)
  801693:	8b 02                	mov    (%edx),%eax
  801695:	8b 52 04             	mov    0x4(%edx),%edx
  801698:	eb 22                	jmp    8016bc <getuint+0x38>
	else if (lflag)
  80169a:	85 d2                	test   %edx,%edx
  80169c:	74 10                	je     8016ae <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80169e:	8b 10                	mov    (%eax),%edx
  8016a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a3:	89 08                	mov    %ecx,(%eax)
  8016a5:	8b 02                	mov    (%edx),%eax
  8016a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ac:	eb 0e                	jmp    8016bc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016ae:	8b 10                	mov    (%eax),%edx
  8016b0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b3:	89 08                	mov    %ecx,(%eax)
  8016b5:	8b 02                	mov    (%edx),%eax
  8016b7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016c4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016c8:	8b 10                	mov    (%eax),%edx
  8016ca:	3b 50 04             	cmp    0x4(%eax),%edx
  8016cd:	73 0a                	jae    8016d9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016cf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016d2:	89 08                	mov    %ecx,(%eax)
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	88 02                	mov    %al,(%edx)
}
  8016d9:	5d                   	pop    %ebp
  8016da:	c3                   	ret    

008016db <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016e1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016e4:	50                   	push   %eax
  8016e5:	ff 75 10             	pushl  0x10(%ebp)
  8016e8:	ff 75 0c             	pushl  0xc(%ebp)
  8016eb:	ff 75 08             	pushl  0x8(%ebp)
  8016ee:	e8 05 00 00 00       	call   8016f8 <vprintfmt>
	va_end(ap);
}
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	57                   	push   %edi
  8016fc:	56                   	push   %esi
  8016fd:	53                   	push   %ebx
  8016fe:	83 ec 2c             	sub    $0x2c,%esp
  801701:	8b 75 08             	mov    0x8(%ebp),%esi
  801704:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801707:	8b 7d 10             	mov    0x10(%ebp),%edi
  80170a:	eb 12                	jmp    80171e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80170c:	85 c0                	test   %eax,%eax
  80170e:	0f 84 89 03 00 00    	je     801a9d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	53                   	push   %ebx
  801718:	50                   	push   %eax
  801719:	ff d6                	call   *%esi
  80171b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80171e:	83 c7 01             	add    $0x1,%edi
  801721:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801725:	83 f8 25             	cmp    $0x25,%eax
  801728:	75 e2                	jne    80170c <vprintfmt+0x14>
  80172a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80172e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801735:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80173c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801743:	ba 00 00 00 00       	mov    $0x0,%edx
  801748:	eb 07                	jmp    801751 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80174d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801751:	8d 47 01             	lea    0x1(%edi),%eax
  801754:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801757:	0f b6 07             	movzbl (%edi),%eax
  80175a:	0f b6 c8             	movzbl %al,%ecx
  80175d:	83 e8 23             	sub    $0x23,%eax
  801760:	3c 55                	cmp    $0x55,%al
  801762:	0f 87 1a 03 00 00    	ja     801a82 <vprintfmt+0x38a>
  801768:	0f b6 c0             	movzbl %al,%eax
  80176b:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  801772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801775:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801779:	eb d6                	jmp    801751 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80177e:	b8 00 00 00 00       	mov    $0x0,%eax
  801783:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801786:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801789:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80178d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801790:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801793:	83 fa 09             	cmp    $0x9,%edx
  801796:	77 39                	ja     8017d1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801798:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80179b:	eb e9                	jmp    801786 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80179d:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a0:	8d 48 04             	lea    0x4(%eax),%ecx
  8017a3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017a6:	8b 00                	mov    (%eax),%eax
  8017a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017ae:	eb 27                	jmp    8017d7 <vprintfmt+0xdf>
  8017b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017ba:	0f 49 c8             	cmovns %eax,%ecx
  8017bd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c3:	eb 8c                	jmp    801751 <vprintfmt+0x59>
  8017c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017c8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017cf:	eb 80                	jmp    801751 <vprintfmt+0x59>
  8017d1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017db:	0f 89 70 ff ff ff    	jns    801751 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017e7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017ee:	e9 5e ff ff ff       	jmp    801751 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017f3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017f9:	e9 53 ff ff ff       	jmp    801751 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801801:	8d 50 04             	lea    0x4(%eax),%edx
  801804:	89 55 14             	mov    %edx,0x14(%ebp)
  801807:	83 ec 08             	sub    $0x8,%esp
  80180a:	53                   	push   %ebx
  80180b:	ff 30                	pushl  (%eax)
  80180d:	ff d6                	call   *%esi
			break;
  80180f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801812:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801815:	e9 04 ff ff ff       	jmp    80171e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80181a:	8b 45 14             	mov    0x14(%ebp),%eax
  80181d:	8d 50 04             	lea    0x4(%eax),%edx
  801820:	89 55 14             	mov    %edx,0x14(%ebp)
  801823:	8b 00                	mov    (%eax),%eax
  801825:	99                   	cltd   
  801826:	31 d0                	xor    %edx,%eax
  801828:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80182a:	83 f8 0f             	cmp    $0xf,%eax
  80182d:	7f 0b                	jg     80183a <vprintfmt+0x142>
  80182f:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  801836:	85 d2                	test   %edx,%edx
  801838:	75 18                	jne    801852 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80183a:	50                   	push   %eax
  80183b:	68 07 24 80 00       	push   $0x802407
  801840:	53                   	push   %ebx
  801841:	56                   	push   %esi
  801842:	e8 94 fe ff ff       	call   8016db <printfmt>
  801847:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80184d:	e9 cc fe ff ff       	jmp    80171e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801852:	52                   	push   %edx
  801853:	68 46 23 80 00       	push   $0x802346
  801858:	53                   	push   %ebx
  801859:	56                   	push   %esi
  80185a:	e8 7c fe ff ff       	call   8016db <printfmt>
  80185f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801862:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801865:	e9 b4 fe ff ff       	jmp    80171e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80186a:	8b 45 14             	mov    0x14(%ebp),%eax
  80186d:	8d 50 04             	lea    0x4(%eax),%edx
  801870:	89 55 14             	mov    %edx,0x14(%ebp)
  801873:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801875:	85 ff                	test   %edi,%edi
  801877:	b8 00 24 80 00       	mov    $0x802400,%eax
  80187c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80187f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801883:	0f 8e 94 00 00 00    	jle    80191d <vprintfmt+0x225>
  801889:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80188d:	0f 84 98 00 00 00    	je     80192b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801893:	83 ec 08             	sub    $0x8,%esp
  801896:	ff 75 d0             	pushl  -0x30(%ebp)
  801899:	57                   	push   %edi
  80189a:	e8 86 02 00 00       	call   801b25 <strnlen>
  80189f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018a2:	29 c1                	sub    %eax,%ecx
  8018a4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018a7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018aa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018b4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b6:	eb 0f                	jmp    8018c7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018b8:	83 ec 08             	sub    $0x8,%esp
  8018bb:	53                   	push   %ebx
  8018bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8018bf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c1:	83 ef 01             	sub    $0x1,%edi
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	85 ff                	test   %edi,%edi
  8018c9:	7f ed                	jg     8018b8 <vprintfmt+0x1c0>
  8018cb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018ce:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018d1:	85 c9                	test   %ecx,%ecx
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d8:	0f 49 c1             	cmovns %ecx,%eax
  8018db:	29 c1                	sub    %eax,%ecx
  8018dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e6:	89 cb                	mov    %ecx,%ebx
  8018e8:	eb 4d                	jmp    801937 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018ea:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ee:	74 1b                	je     80190b <vprintfmt+0x213>
  8018f0:	0f be c0             	movsbl %al,%eax
  8018f3:	83 e8 20             	sub    $0x20,%eax
  8018f6:	83 f8 5e             	cmp    $0x5e,%eax
  8018f9:	76 10                	jbe    80190b <vprintfmt+0x213>
					putch('?', putdat);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	ff 75 0c             	pushl  0xc(%ebp)
  801901:	6a 3f                	push   $0x3f
  801903:	ff 55 08             	call   *0x8(%ebp)
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	eb 0d                	jmp    801918 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80190b:	83 ec 08             	sub    $0x8,%esp
  80190e:	ff 75 0c             	pushl  0xc(%ebp)
  801911:	52                   	push   %edx
  801912:	ff 55 08             	call   *0x8(%ebp)
  801915:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801918:	83 eb 01             	sub    $0x1,%ebx
  80191b:	eb 1a                	jmp    801937 <vprintfmt+0x23f>
  80191d:	89 75 08             	mov    %esi,0x8(%ebp)
  801920:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801923:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801926:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801929:	eb 0c                	jmp    801937 <vprintfmt+0x23f>
  80192b:	89 75 08             	mov    %esi,0x8(%ebp)
  80192e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801931:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801934:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801937:	83 c7 01             	add    $0x1,%edi
  80193a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80193e:	0f be d0             	movsbl %al,%edx
  801941:	85 d2                	test   %edx,%edx
  801943:	74 23                	je     801968 <vprintfmt+0x270>
  801945:	85 f6                	test   %esi,%esi
  801947:	78 a1                	js     8018ea <vprintfmt+0x1f2>
  801949:	83 ee 01             	sub    $0x1,%esi
  80194c:	79 9c                	jns    8018ea <vprintfmt+0x1f2>
  80194e:	89 df                	mov    %ebx,%edi
  801950:	8b 75 08             	mov    0x8(%ebp),%esi
  801953:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801956:	eb 18                	jmp    801970 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	53                   	push   %ebx
  80195c:	6a 20                	push   $0x20
  80195e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801960:	83 ef 01             	sub    $0x1,%edi
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	eb 08                	jmp    801970 <vprintfmt+0x278>
  801968:	89 df                	mov    %ebx,%edi
  80196a:	8b 75 08             	mov    0x8(%ebp),%esi
  80196d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801970:	85 ff                	test   %edi,%edi
  801972:	7f e4                	jg     801958 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801974:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801977:	e9 a2 fd ff ff       	jmp    80171e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80197c:	83 fa 01             	cmp    $0x1,%edx
  80197f:	7e 16                	jle    801997 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801981:	8b 45 14             	mov    0x14(%ebp),%eax
  801984:	8d 50 08             	lea    0x8(%eax),%edx
  801987:	89 55 14             	mov    %edx,0x14(%ebp)
  80198a:	8b 50 04             	mov    0x4(%eax),%edx
  80198d:	8b 00                	mov    (%eax),%eax
  80198f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801992:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801995:	eb 32                	jmp    8019c9 <vprintfmt+0x2d1>
	else if (lflag)
  801997:	85 d2                	test   %edx,%edx
  801999:	74 18                	je     8019b3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80199b:	8b 45 14             	mov    0x14(%ebp),%eax
  80199e:	8d 50 04             	lea    0x4(%eax),%edx
  8019a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a4:	8b 00                	mov    (%eax),%eax
  8019a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019a9:	89 c1                	mov    %eax,%ecx
  8019ab:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019b1:	eb 16                	jmp    8019c9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b6:	8d 50 04             	lea    0x4(%eax),%edx
  8019b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8019bc:	8b 00                	mov    (%eax),%eax
  8019be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c1:	89 c1                	mov    %eax,%ecx
  8019c3:	c1 f9 1f             	sar    $0x1f,%ecx
  8019c6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019cf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019d4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019d8:	79 74                	jns    801a4e <vprintfmt+0x356>
				putch('-', putdat);
  8019da:	83 ec 08             	sub    $0x8,%esp
  8019dd:	53                   	push   %ebx
  8019de:	6a 2d                	push   $0x2d
  8019e0:	ff d6                	call   *%esi
				num = -(long long) num;
  8019e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019e8:	f7 d8                	neg    %eax
  8019ea:	83 d2 00             	adc    $0x0,%edx
  8019ed:	f7 da                	neg    %edx
  8019ef:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019f2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019f7:	eb 55                	jmp    801a4e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8019fc:	e8 83 fc ff ff       	call   801684 <getuint>
			base = 10;
  801a01:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a06:	eb 46                	jmp    801a4e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a08:	8d 45 14             	lea    0x14(%ebp),%eax
  801a0b:	e8 74 fc ff ff       	call   801684 <getuint>
                        base = 8;
  801a10:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a15:	eb 37                	jmp    801a4e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a17:	83 ec 08             	sub    $0x8,%esp
  801a1a:	53                   	push   %ebx
  801a1b:	6a 30                	push   $0x30
  801a1d:	ff d6                	call   *%esi
			putch('x', putdat);
  801a1f:	83 c4 08             	add    $0x8,%esp
  801a22:	53                   	push   %ebx
  801a23:	6a 78                	push   $0x78
  801a25:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a27:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2a:	8d 50 04             	lea    0x4(%eax),%edx
  801a2d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a30:	8b 00                	mov    (%eax),%eax
  801a32:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a37:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a3a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a3f:	eb 0d                	jmp    801a4e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a41:	8d 45 14             	lea    0x14(%ebp),%eax
  801a44:	e8 3b fc ff ff       	call   801684 <getuint>
			base = 16;
  801a49:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a55:	57                   	push   %edi
  801a56:	ff 75 e0             	pushl  -0x20(%ebp)
  801a59:	51                   	push   %ecx
  801a5a:	52                   	push   %edx
  801a5b:	50                   	push   %eax
  801a5c:	89 da                	mov    %ebx,%edx
  801a5e:	89 f0                	mov    %esi,%eax
  801a60:	e8 70 fb ff ff       	call   8015d5 <printnum>
			break;
  801a65:	83 c4 20             	add    $0x20,%esp
  801a68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a6b:	e9 ae fc ff ff       	jmp    80171e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a70:	83 ec 08             	sub    $0x8,%esp
  801a73:	53                   	push   %ebx
  801a74:	51                   	push   %ecx
  801a75:	ff d6                	call   *%esi
			break;
  801a77:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a7d:	e9 9c fc ff ff       	jmp    80171e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a82:	83 ec 08             	sub    $0x8,%esp
  801a85:	53                   	push   %ebx
  801a86:	6a 25                	push   $0x25
  801a88:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	eb 03                	jmp    801a92 <vprintfmt+0x39a>
  801a8f:	83 ef 01             	sub    $0x1,%edi
  801a92:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a96:	75 f7                	jne    801a8f <vprintfmt+0x397>
  801a98:	e9 81 fc ff ff       	jmp    80171e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5f                   	pop    %edi
  801aa3:	5d                   	pop    %ebp
  801aa4:	c3                   	ret    

00801aa5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	83 ec 18             	sub    $0x18,%esp
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ab8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801abb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	74 26                	je     801aec <vsnprintf+0x47>
  801ac6:	85 d2                	test   %edx,%edx
  801ac8:	7e 22                	jle    801aec <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801aca:	ff 75 14             	pushl  0x14(%ebp)
  801acd:	ff 75 10             	pushl  0x10(%ebp)
  801ad0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad3:	50                   	push   %eax
  801ad4:	68 be 16 80 00       	push   $0x8016be
  801ad9:	e8 1a fc ff ff       	call   8016f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ade:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	eb 05                	jmp    801af1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af1:	c9                   	leave  
  801af2:	c3                   	ret    

00801af3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801af9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801afc:	50                   	push   %eax
  801afd:	ff 75 10             	pushl  0x10(%ebp)
  801b00:	ff 75 0c             	pushl  0xc(%ebp)
  801b03:	ff 75 08             	pushl  0x8(%ebp)
  801b06:	e8 9a ff ff ff       	call   801aa5 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    

00801b0d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b13:	b8 00 00 00 00       	mov    $0x0,%eax
  801b18:	eb 03                	jmp    801b1d <strlen+0x10>
		n++;
  801b1a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b21:	75 f7                	jne    801b1a <strlen+0xd>
		n++;
	return n;
}
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b33:	eb 03                	jmp    801b38 <strnlen+0x13>
		n++;
  801b35:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b38:	39 c2                	cmp    %eax,%edx
  801b3a:	74 08                	je     801b44 <strnlen+0x1f>
  801b3c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b40:	75 f3                	jne    801b35 <strnlen+0x10>
  801b42:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    

00801b46 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	53                   	push   %ebx
  801b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b50:	89 c2                	mov    %eax,%edx
  801b52:	83 c2 01             	add    $0x1,%edx
  801b55:	83 c1 01             	add    $0x1,%ecx
  801b58:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b5c:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b5f:	84 db                	test   %bl,%bl
  801b61:	75 ef                	jne    801b52 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b63:	5b                   	pop    %ebx
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	53                   	push   %ebx
  801b6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b6d:	53                   	push   %ebx
  801b6e:	e8 9a ff ff ff       	call   801b0d <strlen>
  801b73:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b76:	ff 75 0c             	pushl  0xc(%ebp)
  801b79:	01 d8                	add    %ebx,%eax
  801b7b:	50                   	push   %eax
  801b7c:	e8 c5 ff ff ff       	call   801b46 <strcpy>
	return dst;
}
  801b81:	89 d8                	mov    %ebx,%eax
  801b83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    

00801b88 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b93:	89 f3                	mov    %esi,%ebx
  801b95:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b98:	89 f2                	mov    %esi,%edx
  801b9a:	eb 0f                	jmp    801bab <strncpy+0x23>
		*dst++ = *src;
  801b9c:	83 c2 01             	add    $0x1,%edx
  801b9f:	0f b6 01             	movzbl (%ecx),%eax
  801ba2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ba5:	80 39 01             	cmpb   $0x1,(%ecx)
  801ba8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bab:	39 da                	cmp    %ebx,%edx
  801bad:	75 ed                	jne    801b9c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801baf:	89 f0                	mov    %esi,%eax
  801bb1:	5b                   	pop    %ebx
  801bb2:	5e                   	pop    %esi
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	56                   	push   %esi
  801bb9:	53                   	push   %ebx
  801bba:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc0:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bc5:	85 d2                	test   %edx,%edx
  801bc7:	74 21                	je     801bea <strlcpy+0x35>
  801bc9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bcd:	89 f2                	mov    %esi,%edx
  801bcf:	eb 09                	jmp    801bda <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd1:	83 c2 01             	add    $0x1,%edx
  801bd4:	83 c1 01             	add    $0x1,%ecx
  801bd7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bda:	39 c2                	cmp    %eax,%edx
  801bdc:	74 09                	je     801be7 <strlcpy+0x32>
  801bde:	0f b6 19             	movzbl (%ecx),%ebx
  801be1:	84 db                	test   %bl,%bl
  801be3:	75 ec                	jne    801bd1 <strlcpy+0x1c>
  801be5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801be7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bea:	29 f0                	sub    %esi,%eax
}
  801bec:	5b                   	pop    %ebx
  801bed:	5e                   	pop    %esi
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    

00801bf0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bf6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bf9:	eb 06                	jmp    801c01 <strcmp+0x11>
		p++, q++;
  801bfb:	83 c1 01             	add    $0x1,%ecx
  801bfe:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c01:	0f b6 01             	movzbl (%ecx),%eax
  801c04:	84 c0                	test   %al,%al
  801c06:	74 04                	je     801c0c <strcmp+0x1c>
  801c08:	3a 02                	cmp    (%edx),%al
  801c0a:	74 ef                	je     801bfb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c0c:	0f b6 c0             	movzbl %al,%eax
  801c0f:	0f b6 12             	movzbl (%edx),%edx
  801c12:	29 d0                	sub    %edx,%eax
}
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	53                   	push   %ebx
  801c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c25:	eb 06                	jmp    801c2d <strncmp+0x17>
		n--, p++, q++;
  801c27:	83 c0 01             	add    $0x1,%eax
  801c2a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c2d:	39 d8                	cmp    %ebx,%eax
  801c2f:	74 15                	je     801c46 <strncmp+0x30>
  801c31:	0f b6 08             	movzbl (%eax),%ecx
  801c34:	84 c9                	test   %cl,%cl
  801c36:	74 04                	je     801c3c <strncmp+0x26>
  801c38:	3a 0a                	cmp    (%edx),%cl
  801c3a:	74 eb                	je     801c27 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3c:	0f b6 00             	movzbl (%eax),%eax
  801c3f:	0f b6 12             	movzbl (%edx),%edx
  801c42:	29 d0                	sub    %edx,%eax
  801c44:	eb 05                	jmp    801c4b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c46:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c4b:	5b                   	pop    %ebx
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	8b 45 08             	mov    0x8(%ebp),%eax
  801c54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c58:	eb 07                	jmp    801c61 <strchr+0x13>
		if (*s == c)
  801c5a:	38 ca                	cmp    %cl,%dl
  801c5c:	74 0f                	je     801c6d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c5e:	83 c0 01             	add    $0x1,%eax
  801c61:	0f b6 10             	movzbl (%eax),%edx
  801c64:	84 d2                	test   %dl,%dl
  801c66:	75 f2                	jne    801c5a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c79:	eb 03                	jmp    801c7e <strfind+0xf>
  801c7b:	83 c0 01             	add    $0x1,%eax
  801c7e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c81:	38 ca                	cmp    %cl,%dl
  801c83:	74 04                	je     801c89 <strfind+0x1a>
  801c85:	84 d2                	test   %dl,%dl
  801c87:	75 f2                	jne    801c7b <strfind+0xc>
			break;
	return (char *) s;
}
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	57                   	push   %edi
  801c8f:	56                   	push   %esi
  801c90:	53                   	push   %ebx
  801c91:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c97:	85 c9                	test   %ecx,%ecx
  801c99:	74 36                	je     801cd1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c9b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca1:	75 28                	jne    801ccb <memset+0x40>
  801ca3:	f6 c1 03             	test   $0x3,%cl
  801ca6:	75 23                	jne    801ccb <memset+0x40>
		c &= 0xFF;
  801ca8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cac:	89 d3                	mov    %edx,%ebx
  801cae:	c1 e3 08             	shl    $0x8,%ebx
  801cb1:	89 d6                	mov    %edx,%esi
  801cb3:	c1 e6 18             	shl    $0x18,%esi
  801cb6:	89 d0                	mov    %edx,%eax
  801cb8:	c1 e0 10             	shl    $0x10,%eax
  801cbb:	09 f0                	or     %esi,%eax
  801cbd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cbf:	89 d8                	mov    %ebx,%eax
  801cc1:	09 d0                	or     %edx,%eax
  801cc3:	c1 e9 02             	shr    $0x2,%ecx
  801cc6:	fc                   	cld    
  801cc7:	f3 ab                	rep stos %eax,%es:(%edi)
  801cc9:	eb 06                	jmp    801cd1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cce:	fc                   	cld    
  801ccf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd1:	89 f8                	mov    %edi,%eax
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    

00801cd8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	57                   	push   %edi
  801cdc:	56                   	push   %esi
  801cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce6:	39 c6                	cmp    %eax,%esi
  801ce8:	73 35                	jae    801d1f <memmove+0x47>
  801cea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ced:	39 d0                	cmp    %edx,%eax
  801cef:	73 2e                	jae    801d1f <memmove+0x47>
		s += n;
		d += n;
  801cf1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf4:	89 d6                	mov    %edx,%esi
  801cf6:	09 fe                	or     %edi,%esi
  801cf8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cfe:	75 13                	jne    801d13 <memmove+0x3b>
  801d00:	f6 c1 03             	test   $0x3,%cl
  801d03:	75 0e                	jne    801d13 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d05:	83 ef 04             	sub    $0x4,%edi
  801d08:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d0b:	c1 e9 02             	shr    $0x2,%ecx
  801d0e:	fd                   	std    
  801d0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d11:	eb 09                	jmp    801d1c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d13:	83 ef 01             	sub    $0x1,%edi
  801d16:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d19:	fd                   	std    
  801d1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d1c:	fc                   	cld    
  801d1d:	eb 1d                	jmp    801d3c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1f:	89 f2                	mov    %esi,%edx
  801d21:	09 c2                	or     %eax,%edx
  801d23:	f6 c2 03             	test   $0x3,%dl
  801d26:	75 0f                	jne    801d37 <memmove+0x5f>
  801d28:	f6 c1 03             	test   $0x3,%cl
  801d2b:	75 0a                	jne    801d37 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d2d:	c1 e9 02             	shr    $0x2,%ecx
  801d30:	89 c7                	mov    %eax,%edi
  801d32:	fc                   	cld    
  801d33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d35:	eb 05                	jmp    801d3c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d37:	89 c7                	mov    %eax,%edi
  801d39:	fc                   	cld    
  801d3a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d3c:	5e                   	pop    %esi
  801d3d:	5f                   	pop    %edi
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d43:	ff 75 10             	pushl  0x10(%ebp)
  801d46:	ff 75 0c             	pushl  0xc(%ebp)
  801d49:	ff 75 08             	pushl  0x8(%ebp)
  801d4c:	e8 87 ff ff ff       	call   801cd8 <memmove>
}
  801d51:	c9                   	leave  
  801d52:	c3                   	ret    

00801d53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	56                   	push   %esi
  801d57:	53                   	push   %ebx
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5e:	89 c6                	mov    %eax,%esi
  801d60:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d63:	eb 1a                	jmp    801d7f <memcmp+0x2c>
		if (*s1 != *s2)
  801d65:	0f b6 08             	movzbl (%eax),%ecx
  801d68:	0f b6 1a             	movzbl (%edx),%ebx
  801d6b:	38 d9                	cmp    %bl,%cl
  801d6d:	74 0a                	je     801d79 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d6f:	0f b6 c1             	movzbl %cl,%eax
  801d72:	0f b6 db             	movzbl %bl,%ebx
  801d75:	29 d8                	sub    %ebx,%eax
  801d77:	eb 0f                	jmp    801d88 <memcmp+0x35>
		s1++, s2++;
  801d79:	83 c0 01             	add    $0x1,%eax
  801d7c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d7f:	39 f0                	cmp    %esi,%eax
  801d81:	75 e2                	jne    801d65 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d88:	5b                   	pop    %ebx
  801d89:	5e                   	pop    %esi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	53                   	push   %ebx
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d93:	89 c1                	mov    %eax,%ecx
  801d95:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d98:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d9c:	eb 0a                	jmp    801da8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9e:	0f b6 10             	movzbl (%eax),%edx
  801da1:	39 da                	cmp    %ebx,%edx
  801da3:	74 07                	je     801dac <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da5:	83 c0 01             	add    $0x1,%eax
  801da8:	39 c8                	cmp    %ecx,%eax
  801daa:	72 f2                	jb     801d9e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dac:	5b                   	pop    %ebx
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    

00801daf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801daf:	55                   	push   %ebp
  801db0:	89 e5                	mov    %esp,%ebp
  801db2:	57                   	push   %edi
  801db3:	56                   	push   %esi
  801db4:	53                   	push   %ebx
  801db5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801db8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dbb:	eb 03                	jmp    801dc0 <strtol+0x11>
		s++;
  801dbd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc0:	0f b6 01             	movzbl (%ecx),%eax
  801dc3:	3c 20                	cmp    $0x20,%al
  801dc5:	74 f6                	je     801dbd <strtol+0xe>
  801dc7:	3c 09                	cmp    $0x9,%al
  801dc9:	74 f2                	je     801dbd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dcb:	3c 2b                	cmp    $0x2b,%al
  801dcd:	75 0a                	jne    801dd9 <strtol+0x2a>
		s++;
  801dcf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dd2:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd7:	eb 11                	jmp    801dea <strtol+0x3b>
  801dd9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dde:	3c 2d                	cmp    $0x2d,%al
  801de0:	75 08                	jne    801dea <strtol+0x3b>
		s++, neg = 1;
  801de2:	83 c1 01             	add    $0x1,%ecx
  801de5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df0:	75 15                	jne    801e07 <strtol+0x58>
  801df2:	80 39 30             	cmpb   $0x30,(%ecx)
  801df5:	75 10                	jne    801e07 <strtol+0x58>
  801df7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801dfb:	75 7c                	jne    801e79 <strtol+0xca>
		s += 2, base = 16;
  801dfd:	83 c1 02             	add    $0x2,%ecx
  801e00:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e05:	eb 16                	jmp    801e1d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e07:	85 db                	test   %ebx,%ebx
  801e09:	75 12                	jne    801e1d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e0b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e10:	80 39 30             	cmpb   $0x30,(%ecx)
  801e13:	75 08                	jne    801e1d <strtol+0x6e>
		s++, base = 8;
  801e15:	83 c1 01             	add    $0x1,%ecx
  801e18:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e22:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e25:	0f b6 11             	movzbl (%ecx),%edx
  801e28:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e2b:	89 f3                	mov    %esi,%ebx
  801e2d:	80 fb 09             	cmp    $0x9,%bl
  801e30:	77 08                	ja     801e3a <strtol+0x8b>
			dig = *s - '0';
  801e32:	0f be d2             	movsbl %dl,%edx
  801e35:	83 ea 30             	sub    $0x30,%edx
  801e38:	eb 22                	jmp    801e5c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e3a:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e3d:	89 f3                	mov    %esi,%ebx
  801e3f:	80 fb 19             	cmp    $0x19,%bl
  801e42:	77 08                	ja     801e4c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e44:	0f be d2             	movsbl %dl,%edx
  801e47:	83 ea 57             	sub    $0x57,%edx
  801e4a:	eb 10                	jmp    801e5c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e4c:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e4f:	89 f3                	mov    %esi,%ebx
  801e51:	80 fb 19             	cmp    $0x19,%bl
  801e54:	77 16                	ja     801e6c <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e56:	0f be d2             	movsbl %dl,%edx
  801e59:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e5c:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e5f:	7d 0b                	jge    801e6c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e61:	83 c1 01             	add    $0x1,%ecx
  801e64:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e68:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e6a:	eb b9                	jmp    801e25 <strtol+0x76>

	if (endptr)
  801e6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e70:	74 0d                	je     801e7f <strtol+0xd0>
		*endptr = (char *) s;
  801e72:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e75:	89 0e                	mov    %ecx,(%esi)
  801e77:	eb 06                	jmp    801e7f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e79:	85 db                	test   %ebx,%ebx
  801e7b:	74 98                	je     801e15 <strtol+0x66>
  801e7d:	eb 9e                	jmp    801e1d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e7f:	89 c2                	mov    %eax,%edx
  801e81:	f7 da                	neg    %edx
  801e83:	85 ff                	test   %edi,%edi
  801e85:	0f 45 c2             	cmovne %edx,%eax
}
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5f                   	pop    %edi
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    

00801e8d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	56                   	push   %esi
  801e91:	53                   	push   %ebx
  801e92:	8b 75 08             	mov    0x8(%ebp),%esi
  801e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801e9b:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801e9d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ea2:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801ea5:	83 ec 0c             	sub    $0xc,%esp
  801ea8:	50                   	push   %eax
  801ea9:	e8 60 e4 ff ff       	call   80030e <sys_ipc_recv>

	if (r < 0) {
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	79 16                	jns    801ecb <ipc_recv+0x3e>
		if (from_env_store)
  801eb5:	85 f6                	test   %esi,%esi
  801eb7:	74 06                	je     801ebf <ipc_recv+0x32>
			*from_env_store = 0;
  801eb9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801ebf:	85 db                	test   %ebx,%ebx
  801ec1:	74 2c                	je     801eef <ipc_recv+0x62>
			*perm_store = 0;
  801ec3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ec9:	eb 24                	jmp    801eef <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801ecb:	85 f6                	test   %esi,%esi
  801ecd:	74 0a                	je     801ed9 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ecf:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed4:	8b 40 74             	mov    0x74(%eax),%eax
  801ed7:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801ed9:	85 db                	test   %ebx,%ebx
  801edb:	74 0a                	je     801ee7 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801edd:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee2:	8b 40 78             	mov    0x78(%eax),%eax
  801ee5:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801ee7:	a1 08 40 80 00       	mov    0x804008,%eax
  801eec:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801eef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef2:	5b                   	pop    %ebx
  801ef3:	5e                   	pop    %esi
  801ef4:	5d                   	pop    %ebp
  801ef5:	c3                   	ret    

00801ef6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	57                   	push   %edi
  801efa:	56                   	push   %esi
  801efb:	53                   	push   %ebx
  801efc:	83 ec 0c             	sub    $0xc,%esp
  801eff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f02:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f08:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f0a:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f0f:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f12:	ff 75 14             	pushl  0x14(%ebp)
  801f15:	53                   	push   %ebx
  801f16:	56                   	push   %esi
  801f17:	57                   	push   %edi
  801f18:	e8 ce e3 ff ff       	call   8002eb <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f23:	75 07                	jne    801f2c <ipc_send+0x36>
			sys_yield();
  801f25:	e8 15 e2 ff ff       	call   80013f <sys_yield>
  801f2a:	eb e6                	jmp    801f12 <ipc_send+0x1c>
		} else if (r < 0) {
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	79 12                	jns    801f42 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f30:	50                   	push   %eax
  801f31:	68 00 27 80 00       	push   $0x802700
  801f36:	6a 51                	push   $0x51
  801f38:	68 0d 27 80 00       	push   $0x80270d
  801f3d:	e8 a6 f5 ff ff       	call   8014e8 <_panic>
		}
	}
}
  801f42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f45:	5b                   	pop    %ebx
  801f46:	5e                   	pop    %esi
  801f47:	5f                   	pop    %edi
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    

00801f4a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f50:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f55:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f58:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f5e:	8b 52 50             	mov    0x50(%edx),%edx
  801f61:	39 ca                	cmp    %ecx,%edx
  801f63:	75 0d                	jne    801f72 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f65:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f68:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f6d:	8b 40 48             	mov    0x48(%eax),%eax
  801f70:	eb 0f                	jmp    801f81 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f72:	83 c0 01             	add    $0x1,%eax
  801f75:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7a:	75 d9                	jne    801f55 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f81:	5d                   	pop    %ebp
  801f82:	c3                   	ret    

00801f83 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f89:	89 d0                	mov    %edx,%eax
  801f8b:	c1 e8 16             	shr    $0x16,%eax
  801f8e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f95:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9a:	f6 c1 01             	test   $0x1,%cl
  801f9d:	74 1d                	je     801fbc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f9f:	c1 ea 0c             	shr    $0xc,%edx
  801fa2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fa9:	f6 c2 01             	test   $0x1,%dl
  801fac:	74 0e                	je     801fbc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fae:	c1 ea 0c             	shr    $0xc,%edx
  801fb1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb8:	ef 
  801fb9:	0f b7 c0             	movzwl %ax,%eax
}
  801fbc:	5d                   	pop    %ebp
  801fbd:	c3                   	ret    
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
