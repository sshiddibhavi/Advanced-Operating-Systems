
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 a6 04 00 00       	call   800545 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 78 22 80 00       	push   $0x802278
  800118:	6a 23                	push   $0x23
  80011a:	68 95 22 80 00       	push   $0x802295
  80011f:	e8 d0 13 00 00       	call   8014f4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 78 22 80 00       	push   $0x802278
  800199:	6a 23                	push   $0x23
  80019b:	68 95 22 80 00       	push   $0x802295
  8001a0:	e8 4f 13 00 00       	call   8014f4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 78 22 80 00       	push   $0x802278
  8001db:	6a 23                	push   $0x23
  8001dd:	68 95 22 80 00       	push   $0x802295
  8001e2:	e8 0d 13 00 00       	call   8014f4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 78 22 80 00       	push   $0x802278
  80021d:	6a 23                	push   $0x23
  80021f:	68 95 22 80 00       	push   $0x802295
  800224:	e8 cb 12 00 00       	call   8014f4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 78 22 80 00       	push   $0x802278
  80025f:	6a 23                	push   $0x23
  800261:	68 95 22 80 00       	push   $0x802295
  800266:	e8 89 12 00 00       	call   8014f4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 78 22 80 00       	push   $0x802278
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 95 22 80 00       	push   $0x802295
  8002a8:	e8 47 12 00 00       	call   8014f4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 78 22 80 00       	push   $0x802278
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 95 22 80 00       	push   $0x802295
  8002ea:	e8 05 12 00 00       	call   8014f4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 78 22 80 00       	push   $0x802278
  800347:	6a 23                	push   $0x23
  800349:	68 95 22 80 00       	push   $0x802295
  80034e:	e8 a1 11 00 00       	call   8014f4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036b:	89 d1                	mov    %edx,%ecx
  80036d:	89 d3                	mov    %edx,%ebx
  80036f:	89 d7                	mov    %edx,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	05 00 00 00 30       	add    $0x30000000,%eax
  800385:	c1 e8 0c             	shr    $0xc,%eax
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	05 00 00 00 30       	add    $0x30000000,%eax
  800395:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80039a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ac:	89 c2                	mov    %eax,%edx
  8003ae:	c1 ea 16             	shr    $0x16,%edx
  8003b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b8:	f6 c2 01             	test   $0x1,%dl
  8003bb:	74 11                	je     8003ce <fd_alloc+0x2d>
  8003bd:	89 c2                	mov    %eax,%edx
  8003bf:	c1 ea 0c             	shr    $0xc,%edx
  8003c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c9:	f6 c2 01             	test   $0x1,%dl
  8003cc:	75 09                	jne    8003d7 <fd_alloc+0x36>
			*fd_store = fd;
  8003ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d5:	eb 17                	jmp    8003ee <fd_alloc+0x4d>
  8003d7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003dc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e1:	75 c9                	jne    8003ac <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f6:	83 f8 1f             	cmp    $0x1f,%eax
  8003f9:	77 36                	ja     800431 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003fb:	c1 e0 0c             	shl    $0xc,%eax
  8003fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800403:	89 c2                	mov    %eax,%edx
  800405:	c1 ea 16             	shr    $0x16,%edx
  800408:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040f:	f6 c2 01             	test   $0x1,%dl
  800412:	74 24                	je     800438 <fd_lookup+0x48>
  800414:	89 c2                	mov    %eax,%edx
  800416:	c1 ea 0c             	shr    $0xc,%edx
  800419:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800420:	f6 c2 01             	test   $0x1,%dl
  800423:	74 1a                	je     80043f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800425:	8b 55 0c             	mov    0xc(%ebp),%edx
  800428:	89 02                	mov    %eax,(%edx)
	return 0;
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	eb 13                	jmp    800444 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800436:	eb 0c                	jmp    800444 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043d:	eb 05                	jmp    800444 <fd_lookup+0x54>
  80043f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044f:	ba 20 23 80 00       	mov    $0x802320,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800454:	eb 13                	jmp    800469 <dev_lookup+0x23>
  800456:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800459:	39 08                	cmp    %ecx,(%eax)
  80045b:	75 0c                	jne    800469 <dev_lookup+0x23>
			*dev = devtab[i];
  80045d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800460:	89 01                	mov    %eax,(%ecx)
			return 0;
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	eb 2e                	jmp    800497 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800469:	8b 02                	mov    (%edx),%eax
  80046b:	85 c0                	test   %eax,%eax
  80046d:	75 e7                	jne    800456 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80046f:	a1 08 40 80 00       	mov    0x804008,%eax
  800474:	8b 40 48             	mov    0x48(%eax),%eax
  800477:	83 ec 04             	sub    $0x4,%esp
  80047a:	51                   	push   %ecx
  80047b:	50                   	push   %eax
  80047c:	68 a4 22 80 00       	push   $0x8022a4
  800481:	e8 47 11 00 00       	call   8015cd <cprintf>
	*dev = 0;
  800486:	8b 45 0c             	mov    0xc(%ebp),%eax
  800489:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800497:	c9                   	leave  
  800498:	c3                   	ret    

00800499 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	56                   	push   %esi
  80049d:	53                   	push   %ebx
  80049e:	83 ec 10             	sub    $0x10,%esp
  8004a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004aa:	50                   	push   %eax
  8004ab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004b1:	c1 e8 0c             	shr    $0xc,%eax
  8004b4:	50                   	push   %eax
  8004b5:	e8 36 ff ff ff       	call   8003f0 <fd_lookup>
  8004ba:	83 c4 08             	add    $0x8,%esp
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	78 05                	js     8004c6 <fd_close+0x2d>
	    || fd != fd2)
  8004c1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004c4:	74 0c                	je     8004d2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004c6:	84 db                	test   %bl,%bl
  8004c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004cd:	0f 44 c2             	cmove  %edx,%eax
  8004d0:	eb 41                	jmp    800513 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d8:	50                   	push   %eax
  8004d9:	ff 36                	pushl  (%esi)
  8004db:	e8 66 ff ff ff       	call   800446 <dev_lookup>
  8004e0:	89 c3                	mov    %eax,%ebx
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	78 1a                	js     800503 <fd_close+0x6a>
		if (dev->dev_close)
  8004e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004ec:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004ef:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	74 0b                	je     800503 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f8:	83 ec 0c             	sub    $0xc,%esp
  8004fb:	56                   	push   %esi
  8004fc:	ff d0                	call   *%eax
  8004fe:	89 c3                	mov    %eax,%ebx
  800500:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	56                   	push   %esi
  800507:	6a 00                	push   $0x0
  800509:	e8 e1 fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	89 d8                	mov    %ebx,%eax
}
  800513:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800516:	5b                   	pop    %ebx
  800517:	5e                   	pop    %esi
  800518:	5d                   	pop    %ebp
  800519:	c3                   	ret    

0080051a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800520:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800523:	50                   	push   %eax
  800524:	ff 75 08             	pushl  0x8(%ebp)
  800527:	e8 c4 fe ff ff       	call   8003f0 <fd_lookup>
  80052c:	83 c4 08             	add    $0x8,%esp
  80052f:	85 c0                	test   %eax,%eax
  800531:	78 10                	js     800543 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	6a 01                	push   $0x1
  800538:	ff 75 f4             	pushl  -0xc(%ebp)
  80053b:	e8 59 ff ff ff       	call   800499 <fd_close>
  800540:	83 c4 10             	add    $0x10,%esp
}
  800543:	c9                   	leave  
  800544:	c3                   	ret    

00800545 <close_all>:

void
close_all(void)
{
  800545:	55                   	push   %ebp
  800546:	89 e5                	mov    %esp,%ebp
  800548:	53                   	push   %ebx
  800549:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80054c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	53                   	push   %ebx
  800555:	e8 c0 ff ff ff       	call   80051a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80055a:	83 c3 01             	add    $0x1,%ebx
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	83 fb 20             	cmp    $0x20,%ebx
  800563:	75 ec                	jne    800551 <close_all+0xc>
		close(i);
}
  800565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800568:	c9                   	leave  
  800569:	c3                   	ret    

0080056a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	57                   	push   %edi
  80056e:	56                   	push   %esi
  80056f:	53                   	push   %ebx
  800570:	83 ec 2c             	sub    $0x2c,%esp
  800573:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800576:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800579:	50                   	push   %eax
  80057a:	ff 75 08             	pushl  0x8(%ebp)
  80057d:	e8 6e fe ff ff       	call   8003f0 <fd_lookup>
  800582:	83 c4 08             	add    $0x8,%esp
  800585:	85 c0                	test   %eax,%eax
  800587:	0f 88 c1 00 00 00    	js     80064e <dup+0xe4>
		return r;
	close(newfdnum);
  80058d:	83 ec 0c             	sub    $0xc,%esp
  800590:	56                   	push   %esi
  800591:	e8 84 ff ff ff       	call   80051a <close>

	newfd = INDEX2FD(newfdnum);
  800596:	89 f3                	mov    %esi,%ebx
  800598:	c1 e3 0c             	shl    $0xc,%ebx
  80059b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005a1:	83 c4 04             	add    $0x4,%esp
  8005a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a7:	e8 de fd ff ff       	call   80038a <fd2data>
  8005ac:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005ae:	89 1c 24             	mov    %ebx,(%esp)
  8005b1:	e8 d4 fd ff ff       	call   80038a <fd2data>
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005bc:	89 f8                	mov    %edi,%eax
  8005be:	c1 e8 16             	shr    $0x16,%eax
  8005c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c8:	a8 01                	test   $0x1,%al
  8005ca:	74 37                	je     800603 <dup+0x99>
  8005cc:	89 f8                	mov    %edi,%eax
  8005ce:	c1 e8 0c             	shr    $0xc,%eax
  8005d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d8:	f6 c2 01             	test   $0x1,%dl
  8005db:	74 26                	je     800603 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e4:	83 ec 0c             	sub    $0xc,%esp
  8005e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ec:	50                   	push   %eax
  8005ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005f0:	6a 00                	push   $0x0
  8005f2:	57                   	push   %edi
  8005f3:	6a 00                	push   $0x0
  8005f5:	e8 b3 fb ff ff       	call   8001ad <sys_page_map>
  8005fa:	89 c7                	mov    %eax,%edi
  8005fc:	83 c4 20             	add    $0x20,%esp
  8005ff:	85 c0                	test   %eax,%eax
  800601:	78 2e                	js     800631 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800603:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800606:	89 d0                	mov    %edx,%eax
  800608:	c1 e8 0c             	shr    $0xc,%eax
  80060b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800612:	83 ec 0c             	sub    $0xc,%esp
  800615:	25 07 0e 00 00       	and    $0xe07,%eax
  80061a:	50                   	push   %eax
  80061b:	53                   	push   %ebx
  80061c:	6a 00                	push   $0x0
  80061e:	52                   	push   %edx
  80061f:	6a 00                	push   $0x0
  800621:	e8 87 fb ff ff       	call   8001ad <sys_page_map>
  800626:	89 c7                	mov    %eax,%edi
  800628:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80062b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062d:	85 ff                	test   %edi,%edi
  80062f:	79 1d                	jns    80064e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 00                	push   $0x0
  800637:	e8 b3 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80063c:	83 c4 08             	add    $0x8,%esp
  80063f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800642:	6a 00                	push   $0x0
  800644:	e8 a6 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	89 f8                	mov    %edi,%eax
}
  80064e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800651:	5b                   	pop    %ebx
  800652:	5e                   	pop    %esi
  800653:	5f                   	pop    %edi
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    

00800656 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
  800659:	53                   	push   %ebx
  80065a:	83 ec 14             	sub    $0x14,%esp
  80065d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800660:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800663:	50                   	push   %eax
  800664:	53                   	push   %ebx
  800665:	e8 86 fd ff ff       	call   8003f0 <fd_lookup>
  80066a:	83 c4 08             	add    $0x8,%esp
  80066d:	89 c2                	mov    %eax,%edx
  80066f:	85 c0                	test   %eax,%eax
  800671:	78 6d                	js     8006e0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800673:	83 ec 08             	sub    $0x8,%esp
  800676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800679:	50                   	push   %eax
  80067a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067d:	ff 30                	pushl  (%eax)
  80067f:	e8 c2 fd ff ff       	call   800446 <dev_lookup>
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	85 c0                	test   %eax,%eax
  800689:	78 4c                	js     8006d7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80068b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068e:	8b 42 08             	mov    0x8(%edx),%eax
  800691:	83 e0 03             	and    $0x3,%eax
  800694:	83 f8 01             	cmp    $0x1,%eax
  800697:	75 21                	jne    8006ba <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800699:	a1 08 40 80 00       	mov    0x804008,%eax
  80069e:	8b 40 48             	mov    0x48(%eax),%eax
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	50                   	push   %eax
  8006a6:	68 e5 22 80 00       	push   $0x8022e5
  8006ab:	e8 1d 0f 00 00       	call   8015cd <cprintf>
		return -E_INVAL;
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b8:	eb 26                	jmp    8006e0 <read+0x8a>
	}
	if (!dev->dev_read)
  8006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bd:	8b 40 08             	mov    0x8(%eax),%eax
  8006c0:	85 c0                	test   %eax,%eax
  8006c2:	74 17                	je     8006db <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c4:	83 ec 04             	sub    $0x4,%esp
  8006c7:	ff 75 10             	pushl  0x10(%ebp)
  8006ca:	ff 75 0c             	pushl  0xc(%ebp)
  8006cd:	52                   	push   %edx
  8006ce:	ff d0                	call   *%eax
  8006d0:	89 c2                	mov    %eax,%edx
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	eb 09                	jmp    8006e0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d7:	89 c2                	mov    %eax,%edx
  8006d9:	eb 05                	jmp    8006e0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006e0:	89 d0                	mov    %edx,%eax
  8006e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	57                   	push   %edi
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
  8006ed:	83 ec 0c             	sub    $0xc,%esp
  8006f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fb:	eb 21                	jmp    80071e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006fd:	83 ec 04             	sub    $0x4,%esp
  800700:	89 f0                	mov    %esi,%eax
  800702:	29 d8                	sub    %ebx,%eax
  800704:	50                   	push   %eax
  800705:	89 d8                	mov    %ebx,%eax
  800707:	03 45 0c             	add    0xc(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	57                   	push   %edi
  80070c:	e8 45 ff ff ff       	call   800656 <read>
		if (m < 0)
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	85 c0                	test   %eax,%eax
  800716:	78 10                	js     800728 <readn+0x41>
			return m;
		if (m == 0)
  800718:	85 c0                	test   %eax,%eax
  80071a:	74 0a                	je     800726 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071c:	01 c3                	add    %eax,%ebx
  80071e:	39 f3                	cmp    %esi,%ebx
  800720:	72 db                	jb     8006fd <readn+0x16>
  800722:	89 d8                	mov    %ebx,%eax
  800724:	eb 02                	jmp    800728 <readn+0x41>
  800726:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800728:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072b:	5b                   	pop    %ebx
  80072c:	5e                   	pop    %esi
  80072d:	5f                   	pop    %edi
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	83 ec 14             	sub    $0x14,%esp
  800737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80073a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80073d:	50                   	push   %eax
  80073e:	53                   	push   %ebx
  80073f:	e8 ac fc ff ff       	call   8003f0 <fd_lookup>
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	89 c2                	mov    %eax,%edx
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 68                	js     8007b5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800757:	ff 30                	pushl  (%eax)
  800759:	e8 e8 fc ff ff       	call   800446 <dev_lookup>
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	85 c0                	test   %eax,%eax
  800763:	78 47                	js     8007ac <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800765:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800768:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80076c:	75 21                	jne    80078f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076e:	a1 08 40 80 00       	mov    0x804008,%eax
  800773:	8b 40 48             	mov    0x48(%eax),%eax
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	53                   	push   %ebx
  80077a:	50                   	push   %eax
  80077b:	68 01 23 80 00       	push   $0x802301
  800780:	e8 48 0e 00 00       	call   8015cd <cprintf>
		return -E_INVAL;
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80078d:	eb 26                	jmp    8007b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800792:	8b 52 0c             	mov    0xc(%edx),%edx
  800795:	85 d2                	test   %edx,%edx
  800797:	74 17                	je     8007b0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800799:	83 ec 04             	sub    $0x4,%esp
  80079c:	ff 75 10             	pushl  0x10(%ebp)
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	50                   	push   %eax
  8007a3:	ff d2                	call   *%edx
  8007a5:	89 c2                	mov    %eax,%edx
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb 09                	jmp    8007b5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ac:	89 c2                	mov    %eax,%edx
  8007ae:	eb 05                	jmp    8007b5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007b5:	89 d0                	mov    %edx,%eax
  8007b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <seek>:

int
seek(int fdnum, off_t offset)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007c2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c5:	50                   	push   %eax
  8007c6:	ff 75 08             	pushl  0x8(%ebp)
  8007c9:	e8 22 fc ff ff       	call   8003f0 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	78 0e                	js     8007e3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007db:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	83 ec 14             	sub    $0x14,%esp
  8007ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f2:	50                   	push   %eax
  8007f3:	53                   	push   %ebx
  8007f4:	e8 f7 fb ff ff       	call   8003f0 <fd_lookup>
  8007f9:	83 c4 08             	add    $0x8,%esp
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	85 c0                	test   %eax,%eax
  800800:	78 65                	js     800867 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	ff 30                	pushl  (%eax)
  80080e:	e8 33 fc ff ff       	call   800446 <dev_lookup>
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	85 c0                	test   %eax,%eax
  800818:	78 44                	js     80085e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80081a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800821:	75 21                	jne    800844 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800823:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800828:	8b 40 48             	mov    0x48(%eax),%eax
  80082b:	83 ec 04             	sub    $0x4,%esp
  80082e:	53                   	push   %ebx
  80082f:	50                   	push   %eax
  800830:	68 c4 22 80 00       	push   $0x8022c4
  800835:	e8 93 0d 00 00       	call   8015cd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800842:	eb 23                	jmp    800867 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800844:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800847:	8b 52 18             	mov    0x18(%edx),%edx
  80084a:	85 d2                	test   %edx,%edx
  80084c:	74 14                	je     800862 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	ff 75 0c             	pushl  0xc(%ebp)
  800854:	50                   	push   %eax
  800855:	ff d2                	call   *%edx
  800857:	89 c2                	mov    %eax,%edx
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	eb 09                	jmp    800867 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	89 c2                	mov    %eax,%edx
  800860:	eb 05                	jmp    800867 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800862:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800867:	89 d0                	mov    %edx,%eax
  800869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	53                   	push   %ebx
  800872:	83 ec 14             	sub    $0x14,%esp
  800875:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800878:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80087b:	50                   	push   %eax
  80087c:	ff 75 08             	pushl  0x8(%ebp)
  80087f:	e8 6c fb ff ff       	call   8003f0 <fd_lookup>
  800884:	83 c4 08             	add    $0x8,%esp
  800887:	89 c2                	mov    %eax,%edx
  800889:	85 c0                	test   %eax,%eax
  80088b:	78 58                	js     8008e5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800893:	50                   	push   %eax
  800894:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800897:	ff 30                	pushl  (%eax)
  800899:	e8 a8 fb ff ff       	call   800446 <dev_lookup>
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	78 37                	js     8008dc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ac:	74 32                	je     8008e0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ae:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008b1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b8:	00 00 00 
	stat->st_isdir = 0;
  8008bb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008c2:	00 00 00 
	stat->st_dev = dev;
  8008c5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	53                   	push   %ebx
  8008cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8008d2:	ff 50 14             	call   *0x14(%eax)
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	83 c4 10             	add    $0x10,%esp
  8008da:	eb 09                	jmp    8008e5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008dc:	89 c2                	mov    %eax,%edx
  8008de:	eb 05                	jmp    8008e5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008e0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e5:	89 d0                	mov    %edx,%eax
  8008e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	56                   	push   %esi
  8008f0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	6a 00                	push   $0x0
  8008f6:	ff 75 08             	pushl  0x8(%ebp)
  8008f9:	e8 0c 02 00 00       	call   800b0a <open>
  8008fe:	89 c3                	mov    %eax,%ebx
  800900:	83 c4 10             	add    $0x10,%esp
  800903:	85 c0                	test   %eax,%eax
  800905:	78 1b                	js     800922 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	50                   	push   %eax
  80090e:	e8 5b ff ff ff       	call   80086e <fstat>
  800913:	89 c6                	mov    %eax,%esi
	close(fd);
  800915:	89 1c 24             	mov    %ebx,(%esp)
  800918:	e8 fd fb ff ff       	call   80051a <close>
	return r;
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	89 f0                	mov    %esi,%eax
}
  800922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	89 c6                	mov    %eax,%esi
  800930:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800932:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800939:	75 12                	jne    80094d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80093b:	83 ec 0c             	sub    $0xc,%esp
  80093e:	6a 01                	push   $0x1
  800940:	e8 11 16 00 00       	call   801f56 <ipc_find_env>
  800945:	a3 00 40 80 00       	mov    %eax,0x804000
  80094a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80094d:	6a 07                	push   $0x7
  80094f:	68 00 50 80 00       	push   $0x805000
  800954:	56                   	push   %esi
  800955:	ff 35 00 40 80 00    	pushl  0x804000
  80095b:	e8 a2 15 00 00       	call   801f02 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800960:	83 c4 0c             	add    $0xc,%esp
  800963:	6a 00                	push   $0x0
  800965:	53                   	push   %ebx
  800966:	6a 00                	push   $0x0
  800968:	e8 2c 15 00 00       	call   801e99 <ipc_recv>
}
  80096d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 40 0c             	mov    0xc(%eax),%eax
  800980:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
  800992:	b8 02 00 00 00       	mov    $0x2,%eax
  800997:	e8 8d ff ff ff       	call   800929 <fsipc>
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    

0080099e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b9:	e8 6b ff ff ff       	call   800929 <fsipc>
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	83 ec 04             	sub    $0x4,%esp
  8009c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009da:	b8 05 00 00 00       	mov    $0x5,%eax
  8009df:	e8 45 ff ff ff       	call   800929 <fsipc>
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	78 2c                	js     800a14 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	68 00 50 80 00       	push   $0x805000
  8009f0:	53                   	push   %ebx
  8009f1:	e8 5c 11 00 00       	call   801b52 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a01:	a1 84 50 80 00       	mov    0x805084,%eax
  800a06:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a0c:	83 c4 10             	add    $0x10,%esp
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a17:	c9                   	leave  
  800a18:	c3                   	ret    

00800a19 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	53                   	push   %ebx
  800a1d:	83 ec 08             	sub    $0x8,%esp
  800a20:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
  800a26:	8b 52 0c             	mov    0xc(%edx),%edx
  800a29:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a2f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a34:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a39:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a3c:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a42:	53                   	push   %ebx
  800a43:	ff 75 0c             	pushl  0xc(%ebp)
  800a46:	68 08 50 80 00       	push   $0x805008
  800a4b:	e8 94 12 00 00       	call   801ce4 <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  800a50:	ba 00 00 00 00       	mov    $0x0,%edx
  800a55:	b8 04 00 00 00       	mov    $0x4,%eax
  800a5a:	e8 ca fe ff ff       	call   800929 <fsipc>
  800a5f:	83 c4 10             	add    $0x10,%esp
  800a62:	85 c0                	test   %eax,%eax
  800a64:	78 1d                	js     800a83 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  800a66:	39 d8                	cmp    %ebx,%eax
  800a68:	76 19                	jbe    800a83 <devfile_write+0x6a>
  800a6a:	68 34 23 80 00       	push   $0x802334
  800a6f:	68 40 23 80 00       	push   $0x802340
  800a74:	68 a3 00 00 00       	push   $0xa3
  800a79:	68 55 23 80 00       	push   $0x802355
  800a7e:	e8 71 0a 00 00       	call   8014f4 <_panic>
	return r;
}
  800a83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    

00800a88 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	8b 40 0c             	mov    0xc(%eax),%eax
  800a96:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a9b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 03 00 00 00       	mov    $0x3,%eax
  800aab:	e8 79 fe ff ff       	call   800929 <fsipc>
  800ab0:	89 c3                	mov    %eax,%ebx
  800ab2:	85 c0                	test   %eax,%eax
  800ab4:	78 4b                	js     800b01 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab6:	39 c6                	cmp    %eax,%esi
  800ab8:	73 16                	jae    800ad0 <devfile_read+0x48>
  800aba:	68 60 23 80 00       	push   $0x802360
  800abf:	68 40 23 80 00       	push   $0x802340
  800ac4:	6a 7c                	push   $0x7c
  800ac6:	68 55 23 80 00       	push   $0x802355
  800acb:	e8 24 0a 00 00       	call   8014f4 <_panic>
	assert(r <= PGSIZE);
  800ad0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad5:	7e 16                	jle    800aed <devfile_read+0x65>
  800ad7:	68 67 23 80 00       	push   $0x802367
  800adc:	68 40 23 80 00       	push   $0x802340
  800ae1:	6a 7d                	push   $0x7d
  800ae3:	68 55 23 80 00       	push   $0x802355
  800ae8:	e8 07 0a 00 00       	call   8014f4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aed:	83 ec 04             	sub    $0x4,%esp
  800af0:	50                   	push   %eax
  800af1:	68 00 50 80 00       	push   $0x805000
  800af6:	ff 75 0c             	pushl  0xc(%ebp)
  800af9:	e8 e6 11 00 00       	call   801ce4 <memmove>
	return r;
  800afe:	83 c4 10             	add    $0x10,%esp
}
  800b01:	89 d8                	mov    %ebx,%eax
  800b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	53                   	push   %ebx
  800b0e:	83 ec 20             	sub    $0x20,%esp
  800b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b14:	53                   	push   %ebx
  800b15:	e8 ff 0f 00 00       	call   801b19 <strlen>
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b22:	7f 67                	jg     800b8b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b24:	83 ec 0c             	sub    $0xc,%esp
  800b27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2a:	50                   	push   %eax
  800b2b:	e8 71 f8 ff ff       	call   8003a1 <fd_alloc>
  800b30:	83 c4 10             	add    $0x10,%esp
		return r;
  800b33:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	78 57                	js     800b90 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b39:	83 ec 08             	sub    $0x8,%esp
  800b3c:	53                   	push   %ebx
  800b3d:	68 00 50 80 00       	push   $0x805000
  800b42:	e8 0b 10 00 00       	call   801b52 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b52:	b8 01 00 00 00       	mov    $0x1,%eax
  800b57:	e8 cd fd ff ff       	call   800929 <fsipc>
  800b5c:	89 c3                	mov    %eax,%ebx
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	85 c0                	test   %eax,%eax
  800b63:	79 14                	jns    800b79 <open+0x6f>
		fd_close(fd, 0);
  800b65:	83 ec 08             	sub    $0x8,%esp
  800b68:	6a 00                	push   $0x0
  800b6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6d:	e8 27 f9 ff ff       	call   800499 <fd_close>
		return r;
  800b72:	83 c4 10             	add    $0x10,%esp
  800b75:	89 da                	mov    %ebx,%edx
  800b77:	eb 17                	jmp    800b90 <open+0x86>
	}

	return fd2num(fd);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7f:	e8 f6 f7 ff ff       	call   80037a <fd2num>
  800b84:	89 c2                	mov    %eax,%edx
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	eb 05                	jmp    800b90 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b8b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b90:	89 d0                	mov    %edx,%eax
  800b92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba7:	e8 7d fd ff ff       	call   800929 <fsipc>
}
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bb4:	68 73 23 80 00       	push   $0x802373
  800bb9:	ff 75 0c             	pushl  0xc(%ebp)
  800bbc:	e8 91 0f 00 00       	call   801b52 <strcpy>
	return 0;
}
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    

00800bc8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 10             	sub    $0x10,%esp
  800bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bd2:	53                   	push   %ebx
  800bd3:	e8 b7 13 00 00       	call   801f8f <pageref>
  800bd8:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800be0:	83 f8 01             	cmp    $0x1,%eax
  800be3:	75 10                	jne    800bf5 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	ff 73 0c             	pushl  0xc(%ebx)
  800beb:	e8 c0 02 00 00       	call   800eb0 <nsipc_close>
  800bf0:	89 c2                	mov    %eax,%edx
  800bf2:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bf5:	89 d0                	mov    %edx,%eax
  800bf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c02:	6a 00                	push   $0x0
  800c04:	ff 75 10             	pushl  0x10(%ebp)
  800c07:	ff 75 0c             	pushl  0xc(%ebp)
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	ff 70 0c             	pushl  0xc(%eax)
  800c10:	e8 78 03 00 00       	call   800f8d <nsipc_send>
}
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c1d:	6a 00                	push   $0x0
  800c1f:	ff 75 10             	pushl  0x10(%ebp)
  800c22:	ff 75 0c             	pushl  0xc(%ebp)
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	ff 70 0c             	pushl  0xc(%eax)
  800c2b:	e8 f1 02 00 00       	call   800f21 <nsipc_recv>
}
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c38:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c3b:	52                   	push   %edx
  800c3c:	50                   	push   %eax
  800c3d:	e8 ae f7 ff ff       	call   8003f0 <fd_lookup>
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	85 c0                	test   %eax,%eax
  800c47:	78 17                	js     800c60 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c4c:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800c52:	39 08                	cmp    %ecx,(%eax)
  800c54:	75 05                	jne    800c5b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c56:	8b 40 0c             	mov    0xc(%eax),%eax
  800c59:	eb 05                	jmp    800c60 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c5b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 1c             	sub    $0x1c,%esp
  800c6a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c6f:	50                   	push   %eax
  800c70:	e8 2c f7 ff ff       	call   8003a1 <fd_alloc>
  800c75:	89 c3                	mov    %eax,%ebx
  800c77:	83 c4 10             	add    $0x10,%esp
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	78 1b                	js     800c99 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c7e:	83 ec 04             	sub    $0x4,%esp
  800c81:	68 07 04 00 00       	push   $0x407
  800c86:	ff 75 f4             	pushl  -0xc(%ebp)
  800c89:	6a 00                	push   $0x0
  800c8b:	e8 da f4 ff ff       	call   80016a <sys_page_alloc>
  800c90:	89 c3                	mov    %eax,%ebx
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	85 c0                	test   %eax,%eax
  800c97:	79 10                	jns    800ca9 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	56                   	push   %esi
  800c9d:	e8 0e 02 00 00       	call   800eb0 <nsipc_close>
		return r;
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	89 d8                	mov    %ebx,%eax
  800ca7:	eb 24                	jmp    800ccd <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ca9:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cbe:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	e8 b0 f6 ff ff       	call   80037a <fd2num>
  800cca:	83 c4 10             	add    $0x10,%esp
}
  800ccd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cda:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdd:	e8 50 ff ff ff       	call   800c32 <fd2sockid>
		return r;
  800ce2:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	78 1f                	js     800d07 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce8:	83 ec 04             	sub    $0x4,%esp
  800ceb:	ff 75 10             	pushl  0x10(%ebp)
  800cee:	ff 75 0c             	pushl  0xc(%ebp)
  800cf1:	50                   	push   %eax
  800cf2:	e8 12 01 00 00       	call   800e09 <nsipc_accept>
  800cf7:	83 c4 10             	add    $0x10,%esp
		return r;
  800cfa:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	78 07                	js     800d07 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d00:	e8 5d ff ff ff       	call   800c62 <alloc_sockfd>
  800d05:	89 c1                	mov    %eax,%ecx
}
  800d07:	89 c8                	mov    %ecx,%eax
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	e8 19 ff ff ff       	call   800c32 <fd2sockid>
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	78 12                	js     800d2f <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d1d:	83 ec 04             	sub    $0x4,%esp
  800d20:	ff 75 10             	pushl  0x10(%ebp)
  800d23:	ff 75 0c             	pushl  0xc(%ebp)
  800d26:	50                   	push   %eax
  800d27:	e8 2d 01 00 00       	call   800e59 <nsipc_bind>
  800d2c:	83 c4 10             	add    $0x10,%esp
}
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <shutdown>:

int
shutdown(int s, int how)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	e8 f3 fe ff ff       	call   800c32 <fd2sockid>
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	78 0f                	js     800d52 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d43:	83 ec 08             	sub    $0x8,%esp
  800d46:	ff 75 0c             	pushl  0xc(%ebp)
  800d49:	50                   	push   %eax
  800d4a:	e8 3f 01 00 00       	call   800e8e <nsipc_shutdown>
  800d4f:	83 c4 10             	add    $0x10,%esp
}
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5d:	e8 d0 fe ff ff       	call   800c32 <fd2sockid>
  800d62:	85 c0                	test   %eax,%eax
  800d64:	78 12                	js     800d78 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d66:	83 ec 04             	sub    $0x4,%esp
  800d69:	ff 75 10             	pushl  0x10(%ebp)
  800d6c:	ff 75 0c             	pushl  0xc(%ebp)
  800d6f:	50                   	push   %eax
  800d70:	e8 55 01 00 00       	call   800eca <nsipc_connect>
  800d75:	83 c4 10             	add    $0x10,%esp
}
  800d78:	c9                   	leave  
  800d79:	c3                   	ret    

00800d7a <listen>:

int
listen(int s, int backlog)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	e8 aa fe ff ff       	call   800c32 <fd2sockid>
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	78 0f                	js     800d9b <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d8c:	83 ec 08             	sub    $0x8,%esp
  800d8f:	ff 75 0c             	pushl  0xc(%ebp)
  800d92:	50                   	push   %eax
  800d93:	e8 67 01 00 00       	call   800eff <nsipc_listen>
  800d98:	83 c4 10             	add    $0x10,%esp
}
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    

00800d9d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800da3:	ff 75 10             	pushl  0x10(%ebp)
  800da6:	ff 75 0c             	pushl  0xc(%ebp)
  800da9:	ff 75 08             	pushl  0x8(%ebp)
  800dac:	e8 3a 02 00 00       	call   800feb <nsipc_socket>
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	78 05                	js     800dbd <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800db8:	e8 a5 fe ff ff       	call   800c62 <alloc_sockfd>
}
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    

00800dbf <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 04             	sub    $0x4,%esp
  800dc6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dc8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dcf:	75 12                	jne    800de3 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	6a 02                	push   $0x2
  800dd6:	e8 7b 11 00 00       	call   801f56 <ipc_find_env>
  800ddb:	a3 04 40 80 00       	mov    %eax,0x804004
  800de0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800de3:	6a 07                	push   $0x7
  800de5:	68 00 60 80 00       	push   $0x806000
  800dea:	53                   	push   %ebx
  800deb:	ff 35 04 40 80 00    	pushl  0x804004
  800df1:	e8 0c 11 00 00       	call   801f02 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800df6:	83 c4 0c             	add    $0xc,%esp
  800df9:	6a 00                	push   $0x0
  800dfb:	6a 00                	push   $0x0
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 95 10 00 00       	call   801e99 <ipc_recv>
}
  800e04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e11:	8b 45 08             	mov    0x8(%ebp),%eax
  800e14:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e19:	8b 06                	mov    (%esi),%eax
  800e1b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e20:	b8 01 00 00 00       	mov    $0x1,%eax
  800e25:	e8 95 ff ff ff       	call   800dbf <nsipc>
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	78 20                	js     800e50 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	ff 35 10 60 80 00    	pushl  0x806010
  800e39:	68 00 60 80 00       	push   $0x806000
  800e3e:	ff 75 0c             	pushl  0xc(%ebp)
  800e41:	e8 9e 0e 00 00       	call   801ce4 <memmove>
		*addrlen = ret->ret_addrlen;
  800e46:	a1 10 60 80 00       	mov    0x806010,%eax
  800e4b:	89 06                	mov    %eax,(%esi)
  800e4d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e50:	89 d8                	mov    %ebx,%eax
  800e52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	53                   	push   %ebx
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
  800e66:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e6b:	53                   	push   %ebx
  800e6c:	ff 75 0c             	pushl  0xc(%ebp)
  800e6f:	68 04 60 80 00       	push   $0x806004
  800e74:	e8 6b 0e 00 00       	call   801ce4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e79:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e7f:	b8 02 00 00 00       	mov    $0x2,%eax
  800e84:	e8 36 ff ff ff       	call   800dbf <nsipc>
}
  800e89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
  800e97:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ea4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea9:	e8 11 ff ff ff       	call   800dbf <nsipc>
}
  800eae:	c9                   	leave  
  800eaf:	c3                   	ret    

00800eb0 <nsipc_close>:

int
nsipc_close(int s)
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ebe:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec3:	e8 f7 fe ff ff       	call   800dbf <nsipc>
}
  800ec8:	c9                   	leave  
  800ec9:	c3                   	ret    

00800eca <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800edc:	53                   	push   %ebx
  800edd:	ff 75 0c             	pushl  0xc(%ebp)
  800ee0:	68 04 60 80 00       	push   $0x806004
  800ee5:	e8 fa 0d 00 00       	call   801ce4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eea:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ef0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ef5:	e8 c5 fe ff ff       	call   800dbf <nsipc>
}
  800efa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
  800f08:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f10:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f15:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1a:	e8 a0 fe ff ff       	call   800dbf <nsipc>
}
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f31:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f37:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f3f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f44:	e8 76 fe ff ff       	call   800dbf <nsipc>
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 35                	js     800f84 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f4f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f54:	7f 04                	jg     800f5a <nsipc_recv+0x39>
  800f56:	39 c6                	cmp    %eax,%esi
  800f58:	7d 16                	jge    800f70 <nsipc_recv+0x4f>
  800f5a:	68 7f 23 80 00       	push   $0x80237f
  800f5f:	68 40 23 80 00       	push   $0x802340
  800f64:	6a 62                	push   $0x62
  800f66:	68 94 23 80 00       	push   $0x802394
  800f6b:	e8 84 05 00 00       	call   8014f4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	50                   	push   %eax
  800f74:	68 00 60 80 00       	push   $0x806000
  800f79:	ff 75 0c             	pushl  0xc(%ebp)
  800f7c:	e8 63 0d 00 00       	call   801ce4 <memmove>
  800f81:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f84:	89 d8                	mov    %ebx,%eax
  800f86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	53                   	push   %ebx
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f97:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9a:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f9f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fa5:	7e 16                	jle    800fbd <nsipc_send+0x30>
  800fa7:	68 a0 23 80 00       	push   $0x8023a0
  800fac:	68 40 23 80 00       	push   $0x802340
  800fb1:	6a 6d                	push   $0x6d
  800fb3:	68 94 23 80 00       	push   $0x802394
  800fb8:	e8 37 05 00 00       	call   8014f4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fbd:	83 ec 04             	sub    $0x4,%esp
  800fc0:	53                   	push   %ebx
  800fc1:	ff 75 0c             	pushl  0xc(%ebp)
  800fc4:	68 0c 60 80 00       	push   $0x80600c
  800fc9:	e8 16 0d 00 00       	call   801ce4 <memmove>
	nsipcbuf.send.req_size = size;
  800fce:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fd4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe1:	e8 d9 fd ff ff       	call   800dbf <nsipc>
}
  800fe6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800ff1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffc:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801001:	8b 45 10             	mov    0x10(%ebp),%eax
  801004:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801009:	b8 09 00 00 00       	mov    $0x9,%eax
  80100e:	e8 ac fd ff ff       	call   800dbf <nsipc>
}
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
  80101a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80101d:	83 ec 0c             	sub    $0xc,%esp
  801020:	ff 75 08             	pushl  0x8(%ebp)
  801023:	e8 62 f3 ff ff       	call   80038a <fd2data>
  801028:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80102a:	83 c4 08             	add    $0x8,%esp
  80102d:	68 ac 23 80 00       	push   $0x8023ac
  801032:	53                   	push   %ebx
  801033:	e8 1a 0b 00 00       	call   801b52 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801038:	8b 46 04             	mov    0x4(%esi),%eax
  80103b:	2b 06                	sub    (%esi),%eax
  80103d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801043:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80104a:	00 00 00 
	stat->st_dev = &devpipe;
  80104d:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801054:	30 80 00 
	return 0;
}
  801057:	b8 00 00 00 00       	mov    $0x0,%eax
  80105c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    

00801063 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	53                   	push   %ebx
  801067:	83 ec 0c             	sub    $0xc,%esp
  80106a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80106d:	53                   	push   %ebx
  80106e:	6a 00                	push   $0x0
  801070:	e8 7a f1 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801075:	89 1c 24             	mov    %ebx,(%esp)
  801078:	e8 0d f3 ff ff       	call   80038a <fd2data>
  80107d:	83 c4 08             	add    $0x8,%esp
  801080:	50                   	push   %eax
  801081:	6a 00                	push   $0x0
  801083:	e8 67 f1 ff ff       	call   8001ef <sys_page_unmap>
}
  801088:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	57                   	push   %edi
  801091:	56                   	push   %esi
  801092:	53                   	push   %ebx
  801093:	83 ec 1c             	sub    $0x1c,%esp
  801096:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801099:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80109b:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010a3:	83 ec 0c             	sub    $0xc,%esp
  8010a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a9:	e8 e1 0e 00 00       	call   801f8f <pageref>
  8010ae:	89 c3                	mov    %eax,%ebx
  8010b0:	89 3c 24             	mov    %edi,(%esp)
  8010b3:	e8 d7 0e 00 00       	call   801f8f <pageref>
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	39 c3                	cmp    %eax,%ebx
  8010bd:	0f 94 c1             	sete   %cl
  8010c0:	0f b6 c9             	movzbl %cl,%ecx
  8010c3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010c6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010cc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010cf:	39 ce                	cmp    %ecx,%esi
  8010d1:	74 1b                	je     8010ee <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010d3:	39 c3                	cmp    %eax,%ebx
  8010d5:	75 c4                	jne    80109b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010d7:	8b 42 58             	mov    0x58(%edx),%eax
  8010da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010dd:	50                   	push   %eax
  8010de:	56                   	push   %esi
  8010df:	68 b3 23 80 00       	push   $0x8023b3
  8010e4:	e8 e4 04 00 00       	call   8015cd <cprintf>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	eb ad                	jmp    80109b <_pipeisclosed+0xe>
	}
}
  8010ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f4:	5b                   	pop    %ebx
  8010f5:	5e                   	pop    %esi
  8010f6:	5f                   	pop    %edi
  8010f7:	5d                   	pop    %ebp
  8010f8:	c3                   	ret    

008010f9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010f9:	55                   	push   %ebp
  8010fa:	89 e5                	mov    %esp,%ebp
  8010fc:	57                   	push   %edi
  8010fd:	56                   	push   %esi
  8010fe:	53                   	push   %ebx
  8010ff:	83 ec 28             	sub    $0x28,%esp
  801102:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801105:	56                   	push   %esi
  801106:	e8 7f f2 ff ff       	call   80038a <fd2data>
  80110b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	bf 00 00 00 00       	mov    $0x0,%edi
  801115:	eb 4b                	jmp    801162 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801117:	89 da                	mov    %ebx,%edx
  801119:	89 f0                	mov    %esi,%eax
  80111b:	e8 6d ff ff ff       	call   80108d <_pipeisclosed>
  801120:	85 c0                	test   %eax,%eax
  801122:	75 48                	jne    80116c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801124:	e8 22 f0 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801129:	8b 43 04             	mov    0x4(%ebx),%eax
  80112c:	8b 0b                	mov    (%ebx),%ecx
  80112e:	8d 51 20             	lea    0x20(%ecx),%edx
  801131:	39 d0                	cmp    %edx,%eax
  801133:	73 e2                	jae    801117 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801138:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80113c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80113f:	89 c2                	mov    %eax,%edx
  801141:	c1 fa 1f             	sar    $0x1f,%edx
  801144:	89 d1                	mov    %edx,%ecx
  801146:	c1 e9 1b             	shr    $0x1b,%ecx
  801149:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80114c:	83 e2 1f             	and    $0x1f,%edx
  80114f:	29 ca                	sub    %ecx,%edx
  801151:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801159:	83 c0 01             	add    $0x1,%eax
  80115c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80115f:	83 c7 01             	add    $0x1,%edi
  801162:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801165:	75 c2                	jne    801129 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801167:	8b 45 10             	mov    0x10(%ebp),%eax
  80116a:	eb 05                	jmp    801171 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80116c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801171:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5f                   	pop    %edi
  801177:	5d                   	pop    %ebp
  801178:	c3                   	ret    

00801179 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801179:	55                   	push   %ebp
  80117a:	89 e5                	mov    %esp,%ebp
  80117c:	57                   	push   %edi
  80117d:	56                   	push   %esi
  80117e:	53                   	push   %ebx
  80117f:	83 ec 18             	sub    $0x18,%esp
  801182:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801185:	57                   	push   %edi
  801186:	e8 ff f1 ff ff       	call   80038a <fd2data>
  80118b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	bb 00 00 00 00       	mov    $0x0,%ebx
  801195:	eb 3d                	jmp    8011d4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801197:	85 db                	test   %ebx,%ebx
  801199:	74 04                	je     80119f <devpipe_read+0x26>
				return i;
  80119b:	89 d8                	mov    %ebx,%eax
  80119d:	eb 44                	jmp    8011e3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80119f:	89 f2                	mov    %esi,%edx
  8011a1:	89 f8                	mov    %edi,%eax
  8011a3:	e8 e5 fe ff ff       	call   80108d <_pipeisclosed>
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	75 32                	jne    8011de <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011ac:	e8 9a ef ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011b1:	8b 06                	mov    (%esi),%eax
  8011b3:	3b 46 04             	cmp    0x4(%esi),%eax
  8011b6:	74 df                	je     801197 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b8:	99                   	cltd   
  8011b9:	c1 ea 1b             	shr    $0x1b,%edx
  8011bc:	01 d0                	add    %edx,%eax
  8011be:	83 e0 1f             	and    $0x1f,%eax
  8011c1:	29 d0                	sub    %edx,%eax
  8011c3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011ce:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011d1:	83 c3 01             	add    $0x1,%ebx
  8011d4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011d7:	75 d8                	jne    8011b1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011dc:	eb 05                	jmp    8011e3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011de:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	e8 a5 f1 ff ff       	call   8003a1 <fd_alloc>
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	85 c0                	test   %eax,%eax
  801203:	0f 88 2c 01 00 00    	js     801335 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	68 07 04 00 00       	push   $0x407
  801211:	ff 75 f4             	pushl  -0xc(%ebp)
  801214:	6a 00                	push   $0x0
  801216:	e8 4f ef ff ff       	call   80016a <sys_page_alloc>
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	89 c2                	mov    %eax,%edx
  801220:	85 c0                	test   %eax,%eax
  801222:	0f 88 0d 01 00 00    	js     801335 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801228:	83 ec 0c             	sub    $0xc,%esp
  80122b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122e:	50                   	push   %eax
  80122f:	e8 6d f1 ff ff       	call   8003a1 <fd_alloc>
  801234:	89 c3                	mov    %eax,%ebx
  801236:	83 c4 10             	add    $0x10,%esp
  801239:	85 c0                	test   %eax,%eax
  80123b:	0f 88 e2 00 00 00    	js     801323 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801241:	83 ec 04             	sub    $0x4,%esp
  801244:	68 07 04 00 00       	push   $0x407
  801249:	ff 75 f0             	pushl  -0x10(%ebp)
  80124c:	6a 00                	push   $0x0
  80124e:	e8 17 ef ff ff       	call   80016a <sys_page_alloc>
  801253:	89 c3                	mov    %eax,%ebx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	0f 88 c3 00 00 00    	js     801323 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801260:	83 ec 0c             	sub    $0xc,%esp
  801263:	ff 75 f4             	pushl  -0xc(%ebp)
  801266:	e8 1f f1 ff ff       	call   80038a <fd2data>
  80126b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80126d:	83 c4 0c             	add    $0xc,%esp
  801270:	68 07 04 00 00       	push   $0x407
  801275:	50                   	push   %eax
  801276:	6a 00                	push   $0x0
  801278:	e8 ed ee ff ff       	call   80016a <sys_page_alloc>
  80127d:	89 c3                	mov    %eax,%ebx
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	0f 88 89 00 00 00    	js     801313 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	ff 75 f0             	pushl  -0x10(%ebp)
  801290:	e8 f5 f0 ff ff       	call   80038a <fd2data>
  801295:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80129c:	50                   	push   %eax
  80129d:	6a 00                	push   $0x0
  80129f:	56                   	push   %esi
  8012a0:	6a 00                	push   $0x0
  8012a2:	e8 06 ef ff ff       	call   8001ad <sys_page_map>
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	83 c4 20             	add    $0x20,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 55                	js     801305 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012b0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8012b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012be:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012c5:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8012cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ce:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012da:	83 ec 0c             	sub    $0xc,%esp
  8012dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e0:	e8 95 f0 ff ff       	call   80037a <fd2num>
  8012e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012ea:	83 c4 04             	add    $0x4,%esp
  8012ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8012f0:	e8 85 f0 ff ff       	call   80037a <fd2num>
  8012f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801303:	eb 30                	jmp    801335 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	56                   	push   %esi
  801309:	6a 00                	push   $0x0
  80130b:	e8 df ee ff ff       	call   8001ef <sys_page_unmap>
  801310:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	ff 75 f0             	pushl  -0x10(%ebp)
  801319:	6a 00                	push   $0x0
  80131b:	e8 cf ee ff ff       	call   8001ef <sys_page_unmap>
  801320:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	ff 75 f4             	pushl  -0xc(%ebp)
  801329:	6a 00                	push   $0x0
  80132b:	e8 bf ee ff ff       	call   8001ef <sys_page_unmap>
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801335:	89 d0                	mov    %edx,%eax
  801337:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133a:	5b                   	pop    %ebx
  80133b:	5e                   	pop    %esi
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    

0080133e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	ff 75 08             	pushl  0x8(%ebp)
  80134b:	e8 a0 f0 ff ff       	call   8003f0 <fd_lookup>
  801350:	83 c4 10             	add    $0x10,%esp
  801353:	85 c0                	test   %eax,%eax
  801355:	78 18                	js     80136f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801357:	83 ec 0c             	sub    $0xc,%esp
  80135a:	ff 75 f4             	pushl  -0xc(%ebp)
  80135d:	e8 28 f0 ff ff       	call   80038a <fd2data>
	return _pipeisclosed(fd, p);
  801362:	89 c2                	mov    %eax,%edx
  801364:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801367:	e8 21 fd ff ff       	call   80108d <_pipeisclosed>
  80136c:	83 c4 10             	add    $0x10,%esp
}
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801374:	b8 00 00 00 00       	mov    $0x0,%eax
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    

0080137b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801381:	68 cb 23 80 00       	push   $0x8023cb
  801386:	ff 75 0c             	pushl  0xc(%ebp)
  801389:	e8 c4 07 00 00       	call   801b52 <strcpy>
	return 0;
}
  80138e:	b8 00 00 00 00       	mov    $0x0,%eax
  801393:	c9                   	leave  
  801394:	c3                   	ret    

00801395 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	57                   	push   %edi
  801399:	56                   	push   %esi
  80139a:	53                   	push   %ebx
  80139b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ac:	eb 2d                	jmp    8013db <devcons_write+0x46>
		m = n - tot;
  8013ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013b3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013b6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013bb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013be:	83 ec 04             	sub    $0x4,%esp
  8013c1:	53                   	push   %ebx
  8013c2:	03 45 0c             	add    0xc(%ebp),%eax
  8013c5:	50                   	push   %eax
  8013c6:	57                   	push   %edi
  8013c7:	e8 18 09 00 00       	call   801ce4 <memmove>
		sys_cputs(buf, m);
  8013cc:	83 c4 08             	add    $0x8,%esp
  8013cf:	53                   	push   %ebx
  8013d0:	57                   	push   %edi
  8013d1:	e8 d8 ec ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013d6:	01 de                	add    %ebx,%esi
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	89 f0                	mov    %esi,%eax
  8013dd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013e0:	72 cc                	jb     8013ae <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e5:	5b                   	pop    %ebx
  8013e6:	5e                   	pop    %esi
  8013e7:	5f                   	pop    %edi
  8013e8:	5d                   	pop    %ebp
  8013e9:	c3                   	ret    

008013ea <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f9:	74 2a                	je     801425 <devcons_read+0x3b>
  8013fb:	eb 05                	jmp    801402 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013fd:	e8 49 ed ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801402:	e8 c5 ec ff ff       	call   8000cc <sys_cgetc>
  801407:	85 c0                	test   %eax,%eax
  801409:	74 f2                	je     8013fd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 16                	js     801425 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80140f:	83 f8 04             	cmp    $0x4,%eax
  801412:	74 0c                	je     801420 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801414:	8b 55 0c             	mov    0xc(%ebp),%edx
  801417:	88 02                	mov    %al,(%edx)
	return 1;
  801419:	b8 01 00 00 00       	mov    $0x1,%eax
  80141e:	eb 05                	jmp    801425 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801420:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801433:	6a 01                	push   $0x1
  801435:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	e8 70 ec ff ff       	call   8000ae <sys_cputs>
}
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <getchar>:

int
getchar(void)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801449:	6a 01                	push   $0x1
  80144b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80144e:	50                   	push   %eax
  80144f:	6a 00                	push   $0x0
  801451:	e8 00 f2 ff ff       	call   800656 <read>
	if (r < 0)
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 0f                	js     80146c <getchar+0x29>
		return r;
	if (r < 1)
  80145d:	85 c0                	test   %eax,%eax
  80145f:	7e 06                	jle    801467 <getchar+0x24>
		return -E_EOF;
	return c;
  801461:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801465:	eb 05                	jmp    80146c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801467:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801477:	50                   	push   %eax
  801478:	ff 75 08             	pushl  0x8(%ebp)
  80147b:	e8 70 ef ff ff       	call   8003f0 <fd_lookup>
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 c0                	test   %eax,%eax
  801485:	78 11                	js     801498 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801487:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148a:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  801490:	39 10                	cmp    %edx,(%eax)
  801492:	0f 94 c0             	sete   %al
  801495:	0f b6 c0             	movzbl %al,%eax
}
  801498:	c9                   	leave  
  801499:	c3                   	ret    

0080149a <opencons>:

int
opencons(void)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a3:	50                   	push   %eax
  8014a4:	e8 f8 ee ff ff       	call   8003a1 <fd_alloc>
  8014a9:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ac:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 3e                	js     8014f0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b2:	83 ec 04             	sub    $0x4,%esp
  8014b5:	68 07 04 00 00       	push   $0x407
  8014ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bd:	6a 00                	push   $0x0
  8014bf:	e8 a6 ec ff ff       	call   80016a <sys_page_alloc>
  8014c4:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 23                	js     8014f0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014cd:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8014d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014db:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014e2:	83 ec 0c             	sub    $0xc,%esp
  8014e5:	50                   	push   %eax
  8014e6:	e8 8f ee ff ff       	call   80037a <fd2num>
  8014eb:	89 c2                	mov    %eax,%edx
  8014ed:	83 c4 10             	add    $0x10,%esp
}
  8014f0:	89 d0                	mov    %edx,%eax
  8014f2:	c9                   	leave  
  8014f3:	c3                   	ret    

008014f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	56                   	push   %esi
  8014f8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014fc:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801502:	e8 25 ec ff ff       	call   80012c <sys_getenvid>
  801507:	83 ec 0c             	sub    $0xc,%esp
  80150a:	ff 75 0c             	pushl  0xc(%ebp)
  80150d:	ff 75 08             	pushl  0x8(%ebp)
  801510:	56                   	push   %esi
  801511:	50                   	push   %eax
  801512:	68 d8 23 80 00       	push   $0x8023d8
  801517:	e8 b1 00 00 00       	call   8015cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80151c:	83 c4 18             	add    $0x18,%esp
  80151f:	53                   	push   %ebx
  801520:	ff 75 10             	pushl  0x10(%ebp)
  801523:	e8 54 00 00 00       	call   80157c <vcprintf>
	cprintf("\n");
  801528:	c7 04 24 c4 23 80 00 	movl   $0x8023c4,(%esp)
  80152f:	e8 99 00 00 00       	call   8015cd <cprintf>
  801534:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801537:	cc                   	int3   
  801538:	eb fd                	jmp    801537 <_panic+0x43>

0080153a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	53                   	push   %ebx
  80153e:	83 ec 04             	sub    $0x4,%esp
  801541:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801544:	8b 13                	mov    (%ebx),%edx
  801546:	8d 42 01             	lea    0x1(%edx),%eax
  801549:	89 03                	mov    %eax,(%ebx)
  80154b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80154e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801552:	3d ff 00 00 00       	cmp    $0xff,%eax
  801557:	75 1a                	jne    801573 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	68 ff 00 00 00       	push   $0xff
  801561:	8d 43 08             	lea    0x8(%ebx),%eax
  801564:	50                   	push   %eax
  801565:	e8 44 eb ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  80156a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801570:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801573:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801577:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801585:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80158c:	00 00 00 
	b.cnt = 0;
  80158f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801596:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801599:	ff 75 0c             	pushl  0xc(%ebp)
  80159c:	ff 75 08             	pushl  0x8(%ebp)
  80159f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	68 3a 15 80 00       	push   $0x80153a
  8015ab:	e8 54 01 00 00       	call   801704 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015bf:	50                   	push   %eax
  8015c0:	e8 e9 ea ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  8015c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015d3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015d6:	50                   	push   %eax
  8015d7:	ff 75 08             	pushl  0x8(%ebp)
  8015da:	e8 9d ff ff ff       	call   80157c <vcprintf>
	va_end(ap);

	return cnt;
}
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	57                   	push   %edi
  8015e5:	56                   	push   %esi
  8015e6:	53                   	push   %ebx
  8015e7:	83 ec 1c             	sub    $0x1c,%esp
  8015ea:	89 c7                	mov    %eax,%edi
  8015ec:	89 d6                	mov    %edx,%esi
  8015ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801602:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801605:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801608:	39 d3                	cmp    %edx,%ebx
  80160a:	72 05                	jb     801611 <printnum+0x30>
  80160c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80160f:	77 45                	ja     801656 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801611:	83 ec 0c             	sub    $0xc,%esp
  801614:	ff 75 18             	pushl  0x18(%ebp)
  801617:	8b 45 14             	mov    0x14(%ebp),%eax
  80161a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80161d:	53                   	push   %ebx
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	ff 75 e4             	pushl  -0x1c(%ebp)
  801627:	ff 75 e0             	pushl  -0x20(%ebp)
  80162a:	ff 75 dc             	pushl  -0x24(%ebp)
  80162d:	ff 75 d8             	pushl  -0x28(%ebp)
  801630:	e8 9b 09 00 00       	call   801fd0 <__udivdi3>
  801635:	83 c4 18             	add    $0x18,%esp
  801638:	52                   	push   %edx
  801639:	50                   	push   %eax
  80163a:	89 f2                	mov    %esi,%edx
  80163c:	89 f8                	mov    %edi,%eax
  80163e:	e8 9e ff ff ff       	call   8015e1 <printnum>
  801643:	83 c4 20             	add    $0x20,%esp
  801646:	eb 18                	jmp    801660 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	56                   	push   %esi
  80164c:	ff 75 18             	pushl  0x18(%ebp)
  80164f:	ff d7                	call   *%edi
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	eb 03                	jmp    801659 <printnum+0x78>
  801656:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801659:	83 eb 01             	sub    $0x1,%ebx
  80165c:	85 db                	test   %ebx,%ebx
  80165e:	7f e8                	jg     801648 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	56                   	push   %esi
  801664:	83 ec 04             	sub    $0x4,%esp
  801667:	ff 75 e4             	pushl  -0x1c(%ebp)
  80166a:	ff 75 e0             	pushl  -0x20(%ebp)
  80166d:	ff 75 dc             	pushl  -0x24(%ebp)
  801670:	ff 75 d8             	pushl  -0x28(%ebp)
  801673:	e8 88 0a 00 00       	call   802100 <__umoddi3>
  801678:	83 c4 14             	add    $0x14,%esp
  80167b:	0f be 80 fb 23 80 00 	movsbl 0x8023fb(%eax),%eax
  801682:	50                   	push   %eax
  801683:	ff d7                	call   *%edi
}
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801693:	83 fa 01             	cmp    $0x1,%edx
  801696:	7e 0e                	jle    8016a6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801698:	8b 10                	mov    (%eax),%edx
  80169a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80169d:	89 08                	mov    %ecx,(%eax)
  80169f:	8b 02                	mov    (%edx),%eax
  8016a1:	8b 52 04             	mov    0x4(%edx),%edx
  8016a4:	eb 22                	jmp    8016c8 <getuint+0x38>
	else if (lflag)
  8016a6:	85 d2                	test   %edx,%edx
  8016a8:	74 10                	je     8016ba <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016aa:	8b 10                	mov    (%eax),%edx
  8016ac:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016af:	89 08                	mov    %ecx,(%eax)
  8016b1:	8b 02                	mov    (%edx),%eax
  8016b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b8:	eb 0e                	jmp    8016c8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016ba:	8b 10                	mov    (%eax),%edx
  8016bc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016bf:	89 08                	mov    %ecx,(%eax)
  8016c1:	8b 02                	mov    (%edx),%eax
  8016c3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016c8:	5d                   	pop    %ebp
  8016c9:	c3                   	ret    

008016ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016ca:	55                   	push   %ebp
  8016cb:	89 e5                	mov    %esp,%ebp
  8016cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016d4:	8b 10                	mov    (%eax),%edx
  8016d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8016d9:	73 0a                	jae    8016e5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016de:	89 08                	mov    %ecx,(%eax)
  8016e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e3:	88 02                	mov    %al,(%edx)
}
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016f0:	50                   	push   %eax
  8016f1:	ff 75 10             	pushl  0x10(%ebp)
  8016f4:	ff 75 0c             	pushl  0xc(%ebp)
  8016f7:	ff 75 08             	pushl  0x8(%ebp)
  8016fa:	e8 05 00 00 00       	call   801704 <vprintfmt>
	va_end(ap);
}
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	57                   	push   %edi
  801708:	56                   	push   %esi
  801709:	53                   	push   %ebx
  80170a:	83 ec 2c             	sub    $0x2c,%esp
  80170d:	8b 75 08             	mov    0x8(%ebp),%esi
  801710:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801713:	8b 7d 10             	mov    0x10(%ebp),%edi
  801716:	eb 12                	jmp    80172a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801718:	85 c0                	test   %eax,%eax
  80171a:	0f 84 89 03 00 00    	je     801aa9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801720:	83 ec 08             	sub    $0x8,%esp
  801723:	53                   	push   %ebx
  801724:	50                   	push   %eax
  801725:	ff d6                	call   *%esi
  801727:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80172a:	83 c7 01             	add    $0x1,%edi
  80172d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801731:	83 f8 25             	cmp    $0x25,%eax
  801734:	75 e2                	jne    801718 <vprintfmt+0x14>
  801736:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80173a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801741:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801748:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80174f:	ba 00 00 00 00       	mov    $0x0,%edx
  801754:	eb 07                	jmp    80175d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801756:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801759:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175d:	8d 47 01             	lea    0x1(%edi),%eax
  801760:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801763:	0f b6 07             	movzbl (%edi),%eax
  801766:	0f b6 c8             	movzbl %al,%ecx
  801769:	83 e8 23             	sub    $0x23,%eax
  80176c:	3c 55                	cmp    $0x55,%al
  80176e:	0f 87 1a 03 00 00    	ja     801a8e <vprintfmt+0x38a>
  801774:	0f b6 c0             	movzbl %al,%eax
  801777:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  80177e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801781:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801785:	eb d6                	jmp    80175d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80178a:	b8 00 00 00 00       	mov    $0x0,%eax
  80178f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801792:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801795:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801799:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80179c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80179f:	83 fa 09             	cmp    $0x9,%edx
  8017a2:	77 39                	ja     8017dd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8017a4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017a7:	eb e9                	jmp    801792 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ac:	8d 48 04             	lea    0x4(%eax),%ecx
  8017af:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017b2:	8b 00                	mov    (%eax),%eax
  8017b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017ba:	eb 27                	jmp    8017e3 <vprintfmt+0xdf>
  8017bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017c6:	0f 49 c8             	cmovns %eax,%ecx
  8017c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017cf:	eb 8c                	jmp    80175d <vprintfmt+0x59>
  8017d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017d4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017db:	eb 80                	jmp    80175d <vprintfmt+0x59>
  8017dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017e0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017e7:	0f 89 70 ff ff ff    	jns    80175d <vprintfmt+0x59>
				width = precision, precision = -1;
  8017ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017f3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017fa:	e9 5e ff ff ff       	jmp    80175d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017ff:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801802:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801805:	e9 53 ff ff ff       	jmp    80175d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80180a:	8b 45 14             	mov    0x14(%ebp),%eax
  80180d:	8d 50 04             	lea    0x4(%eax),%edx
  801810:	89 55 14             	mov    %edx,0x14(%ebp)
  801813:	83 ec 08             	sub    $0x8,%esp
  801816:	53                   	push   %ebx
  801817:	ff 30                	pushl  (%eax)
  801819:	ff d6                	call   *%esi
			break;
  80181b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801821:	e9 04 ff ff ff       	jmp    80172a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801826:	8b 45 14             	mov    0x14(%ebp),%eax
  801829:	8d 50 04             	lea    0x4(%eax),%edx
  80182c:	89 55 14             	mov    %edx,0x14(%ebp)
  80182f:	8b 00                	mov    (%eax),%eax
  801831:	99                   	cltd   
  801832:	31 d0                	xor    %edx,%eax
  801834:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801836:	83 f8 0f             	cmp    $0xf,%eax
  801839:	7f 0b                	jg     801846 <vprintfmt+0x142>
  80183b:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  801842:	85 d2                	test   %edx,%edx
  801844:	75 18                	jne    80185e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801846:	50                   	push   %eax
  801847:	68 13 24 80 00       	push   $0x802413
  80184c:	53                   	push   %ebx
  80184d:	56                   	push   %esi
  80184e:	e8 94 fe ff ff       	call   8016e7 <printfmt>
  801853:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801859:	e9 cc fe ff ff       	jmp    80172a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80185e:	52                   	push   %edx
  80185f:	68 52 23 80 00       	push   $0x802352
  801864:	53                   	push   %ebx
  801865:	56                   	push   %esi
  801866:	e8 7c fe ff ff       	call   8016e7 <printfmt>
  80186b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801871:	e9 b4 fe ff ff       	jmp    80172a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801876:	8b 45 14             	mov    0x14(%ebp),%eax
  801879:	8d 50 04             	lea    0x4(%eax),%edx
  80187c:	89 55 14             	mov    %edx,0x14(%ebp)
  80187f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801881:	85 ff                	test   %edi,%edi
  801883:	b8 0c 24 80 00       	mov    $0x80240c,%eax
  801888:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80188b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80188f:	0f 8e 94 00 00 00    	jle    801929 <vprintfmt+0x225>
  801895:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801899:	0f 84 98 00 00 00    	je     801937 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80189f:	83 ec 08             	sub    $0x8,%esp
  8018a2:	ff 75 d0             	pushl  -0x30(%ebp)
  8018a5:	57                   	push   %edi
  8018a6:	e8 86 02 00 00       	call   801b31 <strnlen>
  8018ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018ae:	29 c1                	sub    %eax,%ecx
  8018b0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018b3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018b6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018bd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018c0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c2:	eb 0f                	jmp    8018d3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	53                   	push   %ebx
  8018c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018cb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018cd:	83 ef 01             	sub    $0x1,%edi
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	85 ff                	test   %edi,%edi
  8018d5:	7f ed                	jg     8018c4 <vprintfmt+0x1c0>
  8018d7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018da:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018dd:	85 c9                	test   %ecx,%ecx
  8018df:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e4:	0f 49 c1             	cmovns %ecx,%eax
  8018e7:	29 c1                	sub    %eax,%ecx
  8018e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f2:	89 cb                	mov    %ecx,%ebx
  8018f4:	eb 4d                	jmp    801943 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018f6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018fa:	74 1b                	je     801917 <vprintfmt+0x213>
  8018fc:	0f be c0             	movsbl %al,%eax
  8018ff:	83 e8 20             	sub    $0x20,%eax
  801902:	83 f8 5e             	cmp    $0x5e,%eax
  801905:	76 10                	jbe    801917 <vprintfmt+0x213>
					putch('?', putdat);
  801907:	83 ec 08             	sub    $0x8,%esp
  80190a:	ff 75 0c             	pushl  0xc(%ebp)
  80190d:	6a 3f                	push   $0x3f
  80190f:	ff 55 08             	call   *0x8(%ebp)
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	eb 0d                	jmp    801924 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	ff 75 0c             	pushl  0xc(%ebp)
  80191d:	52                   	push   %edx
  80191e:	ff 55 08             	call   *0x8(%ebp)
  801921:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801924:	83 eb 01             	sub    $0x1,%ebx
  801927:	eb 1a                	jmp    801943 <vprintfmt+0x23f>
  801929:	89 75 08             	mov    %esi,0x8(%ebp)
  80192c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80192f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801932:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801935:	eb 0c                	jmp    801943 <vprintfmt+0x23f>
  801937:	89 75 08             	mov    %esi,0x8(%ebp)
  80193a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80193d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801940:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801943:	83 c7 01             	add    $0x1,%edi
  801946:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80194a:	0f be d0             	movsbl %al,%edx
  80194d:	85 d2                	test   %edx,%edx
  80194f:	74 23                	je     801974 <vprintfmt+0x270>
  801951:	85 f6                	test   %esi,%esi
  801953:	78 a1                	js     8018f6 <vprintfmt+0x1f2>
  801955:	83 ee 01             	sub    $0x1,%esi
  801958:	79 9c                	jns    8018f6 <vprintfmt+0x1f2>
  80195a:	89 df                	mov    %ebx,%edi
  80195c:	8b 75 08             	mov    0x8(%ebp),%esi
  80195f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801962:	eb 18                	jmp    80197c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	53                   	push   %ebx
  801968:	6a 20                	push   $0x20
  80196a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80196c:	83 ef 01             	sub    $0x1,%edi
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	eb 08                	jmp    80197c <vprintfmt+0x278>
  801974:	89 df                	mov    %ebx,%edi
  801976:	8b 75 08             	mov    0x8(%ebp),%esi
  801979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80197c:	85 ff                	test   %edi,%edi
  80197e:	7f e4                	jg     801964 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801980:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801983:	e9 a2 fd ff ff       	jmp    80172a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801988:	83 fa 01             	cmp    $0x1,%edx
  80198b:	7e 16                	jle    8019a3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80198d:	8b 45 14             	mov    0x14(%ebp),%eax
  801990:	8d 50 08             	lea    0x8(%eax),%edx
  801993:	89 55 14             	mov    %edx,0x14(%ebp)
  801996:	8b 50 04             	mov    0x4(%eax),%edx
  801999:	8b 00                	mov    (%eax),%eax
  80199b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80199e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019a1:	eb 32                	jmp    8019d5 <vprintfmt+0x2d1>
	else if (lflag)
  8019a3:	85 d2                	test   %edx,%edx
  8019a5:	74 18                	je     8019bf <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019aa:	8d 50 04             	lea    0x4(%eax),%edx
  8019ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8019b0:	8b 00                	mov    (%eax),%eax
  8019b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019b5:	89 c1                	mov    %eax,%ecx
  8019b7:	c1 f9 1f             	sar    $0x1f,%ecx
  8019ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019bd:	eb 16                	jmp    8019d5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c2:	8d 50 04             	lea    0x4(%eax),%edx
  8019c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c8:	8b 00                	mov    (%eax),%eax
  8019ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019cd:	89 c1                	mov    %eax,%ecx
  8019cf:	c1 f9 1f             	sar    $0x1f,%ecx
  8019d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019db:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019e0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019e4:	79 74                	jns    801a5a <vprintfmt+0x356>
				putch('-', putdat);
  8019e6:	83 ec 08             	sub    $0x8,%esp
  8019e9:	53                   	push   %ebx
  8019ea:	6a 2d                	push   $0x2d
  8019ec:	ff d6                	call   *%esi
				num = -(long long) num;
  8019ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019f4:	f7 d8                	neg    %eax
  8019f6:	83 d2 00             	adc    $0x0,%edx
  8019f9:	f7 da                	neg    %edx
  8019fb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801a03:	eb 55                	jmp    801a5a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801a05:	8d 45 14             	lea    0x14(%ebp),%eax
  801a08:	e8 83 fc ff ff       	call   801690 <getuint>
			base = 10;
  801a0d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a12:	eb 46                	jmp    801a5a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a14:	8d 45 14             	lea    0x14(%ebp),%eax
  801a17:	e8 74 fc ff ff       	call   801690 <getuint>
                        base = 8;
  801a1c:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a21:	eb 37                	jmp    801a5a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a23:	83 ec 08             	sub    $0x8,%esp
  801a26:	53                   	push   %ebx
  801a27:	6a 30                	push   $0x30
  801a29:	ff d6                	call   *%esi
			putch('x', putdat);
  801a2b:	83 c4 08             	add    $0x8,%esp
  801a2e:	53                   	push   %ebx
  801a2f:	6a 78                	push   $0x78
  801a31:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a33:	8b 45 14             	mov    0x14(%ebp),%eax
  801a36:	8d 50 04             	lea    0x4(%eax),%edx
  801a39:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a3c:	8b 00                	mov    (%eax),%eax
  801a3e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a43:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a46:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a4b:	eb 0d                	jmp    801a5a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a4d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a50:	e8 3b fc ff ff       	call   801690 <getuint>
			base = 16;
  801a55:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a61:	57                   	push   %edi
  801a62:	ff 75 e0             	pushl  -0x20(%ebp)
  801a65:	51                   	push   %ecx
  801a66:	52                   	push   %edx
  801a67:	50                   	push   %eax
  801a68:	89 da                	mov    %ebx,%edx
  801a6a:	89 f0                	mov    %esi,%eax
  801a6c:	e8 70 fb ff ff       	call   8015e1 <printnum>
			break;
  801a71:	83 c4 20             	add    $0x20,%esp
  801a74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a77:	e9 ae fc ff ff       	jmp    80172a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a7c:	83 ec 08             	sub    $0x8,%esp
  801a7f:	53                   	push   %ebx
  801a80:	51                   	push   %ecx
  801a81:	ff d6                	call   *%esi
			break;
  801a83:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a89:	e9 9c fc ff ff       	jmp    80172a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a8e:	83 ec 08             	sub    $0x8,%esp
  801a91:	53                   	push   %ebx
  801a92:	6a 25                	push   $0x25
  801a94:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	eb 03                	jmp    801a9e <vprintfmt+0x39a>
  801a9b:	83 ef 01             	sub    $0x1,%edi
  801a9e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801aa2:	75 f7                	jne    801a9b <vprintfmt+0x397>
  801aa4:	e9 81 fc ff ff       	jmp    80172a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5f                   	pop    %edi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	83 ec 18             	sub    $0x18,%esp
  801ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aba:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801abd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ac0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ac4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ac7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	74 26                	je     801af8 <vsnprintf+0x47>
  801ad2:	85 d2                	test   %edx,%edx
  801ad4:	7e 22                	jle    801af8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ad6:	ff 75 14             	pushl  0x14(%ebp)
  801ad9:	ff 75 10             	pushl  0x10(%ebp)
  801adc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801adf:	50                   	push   %eax
  801ae0:	68 ca 16 80 00       	push   $0x8016ca
  801ae5:	e8 1a fc ff ff       	call   801704 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aed:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	eb 05                	jmp    801afd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801af8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b05:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b08:	50                   	push   %eax
  801b09:	ff 75 10             	pushl  0x10(%ebp)
  801b0c:	ff 75 0c             	pushl  0xc(%ebp)
  801b0f:	ff 75 08             	pushl  0x8(%ebp)
  801b12:	e8 9a ff ff ff       	call   801ab1 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b24:	eb 03                	jmp    801b29 <strlen+0x10>
		n++;
  801b26:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b29:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b2d:	75 f7                	jne    801b26 <strlen+0xd>
		n++;
	return n;
}
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b37:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3f:	eb 03                	jmp    801b44 <strnlen+0x13>
		n++;
  801b41:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b44:	39 c2                	cmp    %eax,%edx
  801b46:	74 08                	je     801b50 <strnlen+0x1f>
  801b48:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b4c:	75 f3                	jne    801b41 <strnlen+0x10>
  801b4e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	53                   	push   %ebx
  801b56:	8b 45 08             	mov    0x8(%ebp),%eax
  801b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b5c:	89 c2                	mov    %eax,%edx
  801b5e:	83 c2 01             	add    $0x1,%edx
  801b61:	83 c1 01             	add    $0x1,%ecx
  801b64:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b68:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b6b:	84 db                	test   %bl,%bl
  801b6d:	75 ef                	jne    801b5e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b6f:	5b                   	pop    %ebx
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	53                   	push   %ebx
  801b76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b79:	53                   	push   %ebx
  801b7a:	e8 9a ff ff ff       	call   801b19 <strlen>
  801b7f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b82:	ff 75 0c             	pushl  0xc(%ebp)
  801b85:	01 d8                	add    %ebx,%eax
  801b87:	50                   	push   %eax
  801b88:	e8 c5 ff ff ff       	call   801b52 <strcpy>
	return dst;
}
  801b8d:	89 d8                	mov    %ebx,%eax
  801b8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b92:	c9                   	leave  
  801b93:	c3                   	ret    

00801b94 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	56                   	push   %esi
  801b98:	53                   	push   %ebx
  801b99:	8b 75 08             	mov    0x8(%ebp),%esi
  801b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9f:	89 f3                	mov    %esi,%ebx
  801ba1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ba4:	89 f2                	mov    %esi,%edx
  801ba6:	eb 0f                	jmp    801bb7 <strncpy+0x23>
		*dst++ = *src;
  801ba8:	83 c2 01             	add    $0x1,%edx
  801bab:	0f b6 01             	movzbl (%ecx),%eax
  801bae:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bb1:	80 39 01             	cmpb   $0x1,(%ecx)
  801bb4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bb7:	39 da                	cmp    %ebx,%edx
  801bb9:	75 ed                	jne    801ba8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bbb:	89 f0                	mov    %esi,%eax
  801bbd:	5b                   	pop    %ebx
  801bbe:	5e                   	pop    %esi
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcc:	8b 55 10             	mov    0x10(%ebp),%edx
  801bcf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bd1:	85 d2                	test   %edx,%edx
  801bd3:	74 21                	je     801bf6 <strlcpy+0x35>
  801bd5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd9:	89 f2                	mov    %esi,%edx
  801bdb:	eb 09                	jmp    801be6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bdd:	83 c2 01             	add    $0x1,%edx
  801be0:	83 c1 01             	add    $0x1,%ecx
  801be3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801be6:	39 c2                	cmp    %eax,%edx
  801be8:	74 09                	je     801bf3 <strlcpy+0x32>
  801bea:	0f b6 19             	movzbl (%ecx),%ebx
  801bed:	84 db                	test   %bl,%bl
  801bef:	75 ec                	jne    801bdd <strlcpy+0x1c>
  801bf1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bf3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bf6:	29 f0                	sub    %esi,%eax
}
  801bf8:	5b                   	pop    %ebx
  801bf9:	5e                   	pop    %esi
  801bfa:	5d                   	pop    %ebp
  801bfb:	c3                   	ret    

00801bfc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c02:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c05:	eb 06                	jmp    801c0d <strcmp+0x11>
		p++, q++;
  801c07:	83 c1 01             	add    $0x1,%ecx
  801c0a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c0d:	0f b6 01             	movzbl (%ecx),%eax
  801c10:	84 c0                	test   %al,%al
  801c12:	74 04                	je     801c18 <strcmp+0x1c>
  801c14:	3a 02                	cmp    (%edx),%al
  801c16:	74 ef                	je     801c07 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c18:	0f b6 c0             	movzbl %al,%eax
  801c1b:	0f b6 12             	movzbl (%edx),%edx
  801c1e:	29 d0                	sub    %edx,%eax
}
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	53                   	push   %ebx
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c31:	eb 06                	jmp    801c39 <strncmp+0x17>
		n--, p++, q++;
  801c33:	83 c0 01             	add    $0x1,%eax
  801c36:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c39:	39 d8                	cmp    %ebx,%eax
  801c3b:	74 15                	je     801c52 <strncmp+0x30>
  801c3d:	0f b6 08             	movzbl (%eax),%ecx
  801c40:	84 c9                	test   %cl,%cl
  801c42:	74 04                	je     801c48 <strncmp+0x26>
  801c44:	3a 0a                	cmp    (%edx),%cl
  801c46:	74 eb                	je     801c33 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c48:	0f b6 00             	movzbl (%eax),%eax
  801c4b:	0f b6 12             	movzbl (%edx),%edx
  801c4e:	29 d0                	sub    %edx,%eax
  801c50:	eb 05                	jmp    801c57 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c52:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c57:	5b                   	pop    %ebx
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    

00801c5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c64:	eb 07                	jmp    801c6d <strchr+0x13>
		if (*s == c)
  801c66:	38 ca                	cmp    %cl,%dl
  801c68:	74 0f                	je     801c79 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c6a:	83 c0 01             	add    $0x1,%eax
  801c6d:	0f b6 10             	movzbl (%eax),%edx
  801c70:	84 d2                	test   %dl,%dl
  801c72:	75 f2                	jne    801c66 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c85:	eb 03                	jmp    801c8a <strfind+0xf>
  801c87:	83 c0 01             	add    $0x1,%eax
  801c8a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c8d:	38 ca                	cmp    %cl,%dl
  801c8f:	74 04                	je     801c95 <strfind+0x1a>
  801c91:	84 d2                	test   %dl,%dl
  801c93:	75 f2                	jne    801c87 <strfind+0xc>
			break;
	return (char *) s;
}
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	57                   	push   %edi
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ca0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ca3:	85 c9                	test   %ecx,%ecx
  801ca5:	74 36                	je     801cdd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ca7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cad:	75 28                	jne    801cd7 <memset+0x40>
  801caf:	f6 c1 03             	test   $0x3,%cl
  801cb2:	75 23                	jne    801cd7 <memset+0x40>
		c &= 0xFF;
  801cb4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cb8:	89 d3                	mov    %edx,%ebx
  801cba:	c1 e3 08             	shl    $0x8,%ebx
  801cbd:	89 d6                	mov    %edx,%esi
  801cbf:	c1 e6 18             	shl    $0x18,%esi
  801cc2:	89 d0                	mov    %edx,%eax
  801cc4:	c1 e0 10             	shl    $0x10,%eax
  801cc7:	09 f0                	or     %esi,%eax
  801cc9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801ccb:	89 d8                	mov    %ebx,%eax
  801ccd:	09 d0                	or     %edx,%eax
  801ccf:	c1 e9 02             	shr    $0x2,%ecx
  801cd2:	fc                   	cld    
  801cd3:	f3 ab                	rep stos %eax,%es:(%edi)
  801cd5:	eb 06                	jmp    801cdd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cda:	fc                   	cld    
  801cdb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cdd:	89 f8                	mov    %edi,%eax
  801cdf:	5b                   	pop    %ebx
  801ce0:	5e                   	pop    %esi
  801ce1:	5f                   	pop    %edi
  801ce2:	5d                   	pop    %ebp
  801ce3:	c3                   	ret    

00801ce4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	57                   	push   %edi
  801ce8:	56                   	push   %esi
  801ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cec:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cf2:	39 c6                	cmp    %eax,%esi
  801cf4:	73 35                	jae    801d2b <memmove+0x47>
  801cf6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf9:	39 d0                	cmp    %edx,%eax
  801cfb:	73 2e                	jae    801d2b <memmove+0x47>
		s += n;
		d += n;
  801cfd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d00:	89 d6                	mov    %edx,%esi
  801d02:	09 fe                	or     %edi,%esi
  801d04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d0a:	75 13                	jne    801d1f <memmove+0x3b>
  801d0c:	f6 c1 03             	test   $0x3,%cl
  801d0f:	75 0e                	jne    801d1f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d11:	83 ef 04             	sub    $0x4,%edi
  801d14:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d17:	c1 e9 02             	shr    $0x2,%ecx
  801d1a:	fd                   	std    
  801d1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d1d:	eb 09                	jmp    801d28 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d1f:	83 ef 01             	sub    $0x1,%edi
  801d22:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d25:	fd                   	std    
  801d26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d28:	fc                   	cld    
  801d29:	eb 1d                	jmp    801d48 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d2b:	89 f2                	mov    %esi,%edx
  801d2d:	09 c2                	or     %eax,%edx
  801d2f:	f6 c2 03             	test   $0x3,%dl
  801d32:	75 0f                	jne    801d43 <memmove+0x5f>
  801d34:	f6 c1 03             	test   $0x3,%cl
  801d37:	75 0a                	jne    801d43 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d39:	c1 e9 02             	shr    $0x2,%ecx
  801d3c:	89 c7                	mov    %eax,%edi
  801d3e:	fc                   	cld    
  801d3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d41:	eb 05                	jmp    801d48 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d43:	89 c7                	mov    %eax,%edi
  801d45:	fc                   	cld    
  801d46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d48:	5e                   	pop    %esi
  801d49:	5f                   	pop    %edi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    

00801d4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d4f:	ff 75 10             	pushl  0x10(%ebp)
  801d52:	ff 75 0c             	pushl  0xc(%ebp)
  801d55:	ff 75 08             	pushl  0x8(%ebp)
  801d58:	e8 87 ff ff ff       	call   801ce4 <memmove>
}
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    

00801d5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	8b 45 08             	mov    0x8(%ebp),%eax
  801d67:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6a:	89 c6                	mov    %eax,%esi
  801d6c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d6f:	eb 1a                	jmp    801d8b <memcmp+0x2c>
		if (*s1 != *s2)
  801d71:	0f b6 08             	movzbl (%eax),%ecx
  801d74:	0f b6 1a             	movzbl (%edx),%ebx
  801d77:	38 d9                	cmp    %bl,%cl
  801d79:	74 0a                	je     801d85 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d7b:	0f b6 c1             	movzbl %cl,%eax
  801d7e:	0f b6 db             	movzbl %bl,%ebx
  801d81:	29 d8                	sub    %ebx,%eax
  801d83:	eb 0f                	jmp    801d94 <memcmp+0x35>
		s1++, s2++;
  801d85:	83 c0 01             	add    $0x1,%eax
  801d88:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d8b:	39 f0                	cmp    %esi,%eax
  801d8d:	75 e2                	jne    801d71 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	53                   	push   %ebx
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d9f:	89 c1                	mov    %eax,%ecx
  801da1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801da4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da8:	eb 0a                	jmp    801db4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801daa:	0f b6 10             	movzbl (%eax),%edx
  801dad:	39 da                	cmp    %ebx,%edx
  801daf:	74 07                	je     801db8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db1:	83 c0 01             	add    $0x1,%eax
  801db4:	39 c8                	cmp    %ecx,%eax
  801db6:	72 f2                	jb     801daa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801db8:	5b                   	pop    %ebx
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	57                   	push   %edi
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc7:	eb 03                	jmp    801dcc <strtol+0x11>
		s++;
  801dc9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dcc:	0f b6 01             	movzbl (%ecx),%eax
  801dcf:	3c 20                	cmp    $0x20,%al
  801dd1:	74 f6                	je     801dc9 <strtol+0xe>
  801dd3:	3c 09                	cmp    $0x9,%al
  801dd5:	74 f2                	je     801dc9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dd7:	3c 2b                	cmp    $0x2b,%al
  801dd9:	75 0a                	jne    801de5 <strtol+0x2a>
		s++;
  801ddb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dde:	bf 00 00 00 00       	mov    $0x0,%edi
  801de3:	eb 11                	jmp    801df6 <strtol+0x3b>
  801de5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801dea:	3c 2d                	cmp    $0x2d,%al
  801dec:	75 08                	jne    801df6 <strtol+0x3b>
		s++, neg = 1;
  801dee:	83 c1 01             	add    $0x1,%ecx
  801df1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dfc:	75 15                	jne    801e13 <strtol+0x58>
  801dfe:	80 39 30             	cmpb   $0x30,(%ecx)
  801e01:	75 10                	jne    801e13 <strtol+0x58>
  801e03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e07:	75 7c                	jne    801e85 <strtol+0xca>
		s += 2, base = 16;
  801e09:	83 c1 02             	add    $0x2,%ecx
  801e0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e11:	eb 16                	jmp    801e29 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e13:	85 db                	test   %ebx,%ebx
  801e15:	75 12                	jne    801e29 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e17:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e1c:	80 39 30             	cmpb   $0x30,(%ecx)
  801e1f:	75 08                	jne    801e29 <strtol+0x6e>
		s++, base = 8;
  801e21:	83 c1 01             	add    $0x1,%ecx
  801e24:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e29:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e31:	0f b6 11             	movzbl (%ecx),%edx
  801e34:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e37:	89 f3                	mov    %esi,%ebx
  801e39:	80 fb 09             	cmp    $0x9,%bl
  801e3c:	77 08                	ja     801e46 <strtol+0x8b>
			dig = *s - '0';
  801e3e:	0f be d2             	movsbl %dl,%edx
  801e41:	83 ea 30             	sub    $0x30,%edx
  801e44:	eb 22                	jmp    801e68 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e46:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e49:	89 f3                	mov    %esi,%ebx
  801e4b:	80 fb 19             	cmp    $0x19,%bl
  801e4e:	77 08                	ja     801e58 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e50:	0f be d2             	movsbl %dl,%edx
  801e53:	83 ea 57             	sub    $0x57,%edx
  801e56:	eb 10                	jmp    801e68 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e58:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e5b:	89 f3                	mov    %esi,%ebx
  801e5d:	80 fb 19             	cmp    $0x19,%bl
  801e60:	77 16                	ja     801e78 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e62:	0f be d2             	movsbl %dl,%edx
  801e65:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e68:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e6b:	7d 0b                	jge    801e78 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e6d:	83 c1 01             	add    $0x1,%ecx
  801e70:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e74:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e76:	eb b9                	jmp    801e31 <strtol+0x76>

	if (endptr)
  801e78:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e7c:	74 0d                	je     801e8b <strtol+0xd0>
		*endptr = (char *) s;
  801e7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e81:	89 0e                	mov    %ecx,(%esi)
  801e83:	eb 06                	jmp    801e8b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e85:	85 db                	test   %ebx,%ebx
  801e87:	74 98                	je     801e21 <strtol+0x66>
  801e89:	eb 9e                	jmp    801e29 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e8b:	89 c2                	mov    %eax,%edx
  801e8d:	f7 da                	neg    %edx
  801e8f:	85 ff                	test   %edi,%edi
  801e91:	0f 45 c2             	cmovne %edx,%eax
}
  801e94:	5b                   	pop    %ebx
  801e95:	5e                   	pop    %esi
  801e96:	5f                   	pop    %edi
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    

00801e99 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	56                   	push   %esi
  801e9d:	53                   	push   %ebx
  801e9e:	8b 75 08             	mov    0x8(%ebp),%esi
  801ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ea7:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801ea9:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801eae:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801eb1:	83 ec 0c             	sub    $0xc,%esp
  801eb4:	50                   	push   %eax
  801eb5:	e8 60 e4 ff ff       	call   80031a <sys_ipc_recv>

	if (r < 0) {
  801eba:	83 c4 10             	add    $0x10,%esp
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	79 16                	jns    801ed7 <ipc_recv+0x3e>
		if (from_env_store)
  801ec1:	85 f6                	test   %esi,%esi
  801ec3:	74 06                	je     801ecb <ipc_recv+0x32>
			*from_env_store = 0;
  801ec5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801ecb:	85 db                	test   %ebx,%ebx
  801ecd:	74 2c                	je     801efb <ipc_recv+0x62>
			*perm_store = 0;
  801ecf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ed5:	eb 24                	jmp    801efb <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801ed7:	85 f6                	test   %esi,%esi
  801ed9:	74 0a                	je     801ee5 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801edb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee0:	8b 40 74             	mov    0x74(%eax),%eax
  801ee3:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801ee5:	85 db                	test   %ebx,%ebx
  801ee7:	74 0a                	je     801ef3 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801ee9:	a1 08 40 80 00       	mov    0x804008,%eax
  801eee:	8b 40 78             	mov    0x78(%eax),%eax
  801ef1:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801ef3:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef8:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801efb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801efe:	5b                   	pop    %ebx
  801eff:	5e                   	pop    %esi
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    

00801f02 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	57                   	push   %edi
  801f06:	56                   	push   %esi
  801f07:	53                   	push   %ebx
  801f08:	83 ec 0c             	sub    $0xc,%esp
  801f0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f14:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f16:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f1b:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f1e:	ff 75 14             	pushl  0x14(%ebp)
  801f21:	53                   	push   %ebx
  801f22:	56                   	push   %esi
  801f23:	57                   	push   %edi
  801f24:	e8 ce e3 ff ff       	call   8002f7 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f29:	83 c4 10             	add    $0x10,%esp
  801f2c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f2f:	75 07                	jne    801f38 <ipc_send+0x36>
			sys_yield();
  801f31:	e8 15 e2 ff ff       	call   80014b <sys_yield>
  801f36:	eb e6                	jmp    801f1e <ipc_send+0x1c>
		} else if (r < 0) {
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	79 12                	jns    801f4e <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f3c:	50                   	push   %eax
  801f3d:	68 00 27 80 00       	push   $0x802700
  801f42:	6a 51                	push   $0x51
  801f44:	68 0d 27 80 00       	push   $0x80270d
  801f49:	e8 a6 f5 ff ff       	call   8014f4 <_panic>
		}
	}
}
  801f4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f51:	5b                   	pop    %ebx
  801f52:	5e                   	pop    %esi
  801f53:	5f                   	pop    %edi
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    

00801f56 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f5c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f61:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f64:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f6a:	8b 52 50             	mov    0x50(%edx),%edx
  801f6d:	39 ca                	cmp    %ecx,%edx
  801f6f:	75 0d                	jne    801f7e <ipc_find_env+0x28>
			return envs[i].env_id;
  801f71:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f74:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f79:	8b 40 48             	mov    0x48(%eax),%eax
  801f7c:	eb 0f                	jmp    801f8d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f7e:	83 c0 01             	add    $0x1,%eax
  801f81:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f86:	75 d9                	jne    801f61 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    

00801f8f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f95:	89 d0                	mov    %edx,%eax
  801f97:	c1 e8 16             	shr    $0x16,%eax
  801f9a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fa1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa6:	f6 c1 01             	test   $0x1,%cl
  801fa9:	74 1d                	je     801fc8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fab:	c1 ea 0c             	shr    $0xc,%edx
  801fae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fb5:	f6 c2 01             	test   $0x1,%dl
  801fb8:	74 0e                	je     801fc8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fba:	c1 ea 0c             	shr    $0xc,%edx
  801fbd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fc4:	ef 
  801fc5:	0f b7 c0             	movzwl %ax,%eax
}
  801fc8:	5d                   	pop    %ebp
  801fc9:	c3                   	ret    
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
