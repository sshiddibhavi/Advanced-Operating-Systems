
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 a6 04 00 00       	call   80053e <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 6a 22 80 00       	push   $0x80226a
  800111:	6a 23                	push   $0x23
  800113:	68 87 22 80 00       	push   $0x802287
  800118:	e8 d0 13 00 00       	call   8014ed <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 6a 22 80 00       	push   $0x80226a
  800192:	6a 23                	push   $0x23
  800194:	68 87 22 80 00       	push   $0x802287
  800199:	e8 4f 13 00 00       	call   8014ed <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 6a 22 80 00       	push   $0x80226a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 87 22 80 00       	push   $0x802287
  8001db:	e8 0d 13 00 00       	call   8014ed <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 6a 22 80 00       	push   $0x80226a
  800216:	6a 23                	push   $0x23
  800218:	68 87 22 80 00       	push   $0x802287
  80021d:	e8 cb 12 00 00       	call   8014ed <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 6a 22 80 00       	push   $0x80226a
  800258:	6a 23                	push   $0x23
  80025a:	68 87 22 80 00       	push   $0x802287
  80025f:	e8 89 12 00 00       	call   8014ed <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 6a 22 80 00       	push   $0x80226a
  80029a:	6a 23                	push   $0x23
  80029c:	68 87 22 80 00       	push   $0x802287
  8002a1:	e8 47 12 00 00       	call   8014ed <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 6a 22 80 00       	push   $0x80226a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 87 22 80 00       	push   $0x802287
  8002e3:	e8 05 12 00 00       	call   8014ed <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 6a 22 80 00       	push   $0x80226a
  800340:	6a 23                	push   $0x23
  800342:	68 87 22 80 00       	push   $0x802287
  800347:	e8 a1 11 00 00       	call   8014ed <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800364:	89 d1                	mov    %edx,%ecx
  800366:	89 d3                	mov    %edx,%ebx
  800368:	89 d7                	mov    %edx,%edi
  80036a:	89 d6                	mov    %edx,%esi
  80036c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800376:	8b 45 08             	mov    0x8(%ebp),%eax
  800379:	05 00 00 00 30       	add    $0x30000000,%eax
  80037e:	c1 e8 0c             	shr    $0xc,%eax
}
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800386:	8b 45 08             	mov    0x8(%ebp),%eax
  800389:	05 00 00 00 30       	add    $0x30000000,%eax
  80038e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800393:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a5:	89 c2                	mov    %eax,%edx
  8003a7:	c1 ea 16             	shr    $0x16,%edx
  8003aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b1:	f6 c2 01             	test   $0x1,%dl
  8003b4:	74 11                	je     8003c7 <fd_alloc+0x2d>
  8003b6:	89 c2                	mov    %eax,%edx
  8003b8:	c1 ea 0c             	shr    $0xc,%edx
  8003bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c2:	f6 c2 01             	test   $0x1,%dl
  8003c5:	75 09                	jne    8003d0 <fd_alloc+0x36>
			*fd_store = fd;
  8003c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ce:	eb 17                	jmp    8003e7 <fd_alloc+0x4d>
  8003d0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003da:	75 c9                	jne    8003a5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003dc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ef:	83 f8 1f             	cmp    $0x1f,%eax
  8003f2:	77 36                	ja     80042a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f4:	c1 e0 0c             	shl    $0xc,%eax
  8003f7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fc:	89 c2                	mov    %eax,%edx
  8003fe:	c1 ea 16             	shr    $0x16,%edx
  800401:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800408:	f6 c2 01             	test   $0x1,%dl
  80040b:	74 24                	je     800431 <fd_lookup+0x48>
  80040d:	89 c2                	mov    %eax,%edx
  80040f:	c1 ea 0c             	shr    $0xc,%edx
  800412:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800419:	f6 c2 01             	test   $0x1,%dl
  80041c:	74 1a                	je     800438 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800421:	89 02                	mov    %eax,(%edx)
	return 0;
  800423:	b8 00 00 00 00       	mov    $0x0,%eax
  800428:	eb 13                	jmp    80043d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042f:	eb 0c                	jmp    80043d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800436:	eb 05                	jmp    80043d <fd_lookup+0x54>
  800438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043d:	5d                   	pop    %ebp
  80043e:	c3                   	ret    

0080043f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800448:	ba 14 23 80 00       	mov    $0x802314,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044d:	eb 13                	jmp    800462 <dev_lookup+0x23>
  80044f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800452:	39 08                	cmp    %ecx,(%eax)
  800454:	75 0c                	jne    800462 <dev_lookup+0x23>
			*dev = devtab[i];
  800456:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800459:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
  800460:	eb 2e                	jmp    800490 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800462:	8b 02                	mov    (%edx),%eax
  800464:	85 c0                	test   %eax,%eax
  800466:	75 e7                	jne    80044f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800468:	a1 08 40 80 00       	mov    0x804008,%eax
  80046d:	8b 40 48             	mov    0x48(%eax),%eax
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	51                   	push   %ecx
  800474:	50                   	push   %eax
  800475:	68 98 22 80 00       	push   $0x802298
  80047a:	e8 47 11 00 00       	call   8015c6 <cprintf>
	*dev = 0;
  80047f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800482:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800490:	c9                   	leave  
  800491:	c3                   	ret    

00800492 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800492:	55                   	push   %ebp
  800493:	89 e5                	mov    %esp,%ebp
  800495:	56                   	push   %esi
  800496:	53                   	push   %ebx
  800497:	83 ec 10             	sub    $0x10,%esp
  80049a:	8b 75 08             	mov    0x8(%ebp),%esi
  80049d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a3:	50                   	push   %eax
  8004a4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004aa:	c1 e8 0c             	shr    $0xc,%eax
  8004ad:	50                   	push   %eax
  8004ae:	e8 36 ff ff ff       	call   8003e9 <fd_lookup>
  8004b3:	83 c4 08             	add    $0x8,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 05                	js     8004bf <fd_close+0x2d>
	    || fd != fd2)
  8004ba:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bd:	74 0c                	je     8004cb <fd_close+0x39>
		return (must_exist ? r : 0);
  8004bf:	84 db                	test   %bl,%bl
  8004c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c6:	0f 44 c2             	cmove  %edx,%eax
  8004c9:	eb 41                	jmp    80050c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d1:	50                   	push   %eax
  8004d2:	ff 36                	pushl  (%esi)
  8004d4:	e8 66 ff ff ff       	call   80043f <dev_lookup>
  8004d9:	89 c3                	mov    %eax,%ebx
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	78 1a                	js     8004fc <fd_close+0x6a>
		if (dev->dev_close)
  8004e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e5:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	74 0b                	je     8004fc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f1:	83 ec 0c             	sub    $0xc,%esp
  8004f4:	56                   	push   %esi
  8004f5:	ff d0                	call   *%eax
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	56                   	push   %esi
  800500:	6a 00                	push   $0x0
  800502:	e8 e1 fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	89 d8                	mov    %ebx,%eax
}
  80050c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050f:	5b                   	pop    %ebx
  800510:	5e                   	pop    %esi
  800511:	5d                   	pop    %ebp
  800512:	c3                   	ret    

00800513 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800519:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051c:	50                   	push   %eax
  80051d:	ff 75 08             	pushl  0x8(%ebp)
  800520:	e8 c4 fe ff ff       	call   8003e9 <fd_lookup>
  800525:	83 c4 08             	add    $0x8,%esp
  800528:	85 c0                	test   %eax,%eax
  80052a:	78 10                	js     80053c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	6a 01                	push   $0x1
  800531:	ff 75 f4             	pushl  -0xc(%ebp)
  800534:	e8 59 ff ff ff       	call   800492 <fd_close>
  800539:	83 c4 10             	add    $0x10,%esp
}
  80053c:	c9                   	leave  
  80053d:	c3                   	ret    

0080053e <close_all>:

void
close_all(void)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	53                   	push   %ebx
  800542:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800545:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80054a:	83 ec 0c             	sub    $0xc,%esp
  80054d:	53                   	push   %ebx
  80054e:	e8 c0 ff ff ff       	call   800513 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800553:	83 c3 01             	add    $0x1,%ebx
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	83 fb 20             	cmp    $0x20,%ebx
  80055c:	75 ec                	jne    80054a <close_all+0xc>
		close(i);
}
  80055e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800561:	c9                   	leave  
  800562:	c3                   	ret    

00800563 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	57                   	push   %edi
  800567:	56                   	push   %esi
  800568:	53                   	push   %ebx
  800569:	83 ec 2c             	sub    $0x2c,%esp
  80056c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800572:	50                   	push   %eax
  800573:	ff 75 08             	pushl  0x8(%ebp)
  800576:	e8 6e fe ff ff       	call   8003e9 <fd_lookup>
  80057b:	83 c4 08             	add    $0x8,%esp
  80057e:	85 c0                	test   %eax,%eax
  800580:	0f 88 c1 00 00 00    	js     800647 <dup+0xe4>
		return r;
	close(newfdnum);
  800586:	83 ec 0c             	sub    $0xc,%esp
  800589:	56                   	push   %esi
  80058a:	e8 84 ff ff ff       	call   800513 <close>

	newfd = INDEX2FD(newfdnum);
  80058f:	89 f3                	mov    %esi,%ebx
  800591:	c1 e3 0c             	shl    $0xc,%ebx
  800594:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80059a:	83 c4 04             	add    $0x4,%esp
  80059d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a0:	e8 de fd ff ff       	call   800383 <fd2data>
  8005a5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a7:	89 1c 24             	mov    %ebx,(%esp)
  8005aa:	e8 d4 fd ff ff       	call   800383 <fd2data>
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b5:	89 f8                	mov    %edi,%eax
  8005b7:	c1 e8 16             	shr    $0x16,%eax
  8005ba:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c1:	a8 01                	test   $0x1,%al
  8005c3:	74 37                	je     8005fc <dup+0x99>
  8005c5:	89 f8                	mov    %edi,%eax
  8005c7:	c1 e8 0c             	shr    $0xc,%eax
  8005ca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d1:	f6 c2 01             	test   $0x1,%dl
  8005d4:	74 26                	je     8005fc <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dd:	83 ec 0c             	sub    $0xc,%esp
  8005e0:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e5:	50                   	push   %eax
  8005e6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e9:	6a 00                	push   $0x0
  8005eb:	57                   	push   %edi
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 b3 fb ff ff       	call   8001a6 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	78 2e                	js     80062a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ff:	89 d0                	mov    %edx,%eax
  800601:	c1 e8 0c             	shr    $0xc,%eax
  800604:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	25 07 0e 00 00       	and    $0xe07,%eax
  800613:	50                   	push   %eax
  800614:	53                   	push   %ebx
  800615:	6a 00                	push   $0x0
  800617:	52                   	push   %edx
  800618:	6a 00                	push   $0x0
  80061a:	e8 87 fb ff ff       	call   8001a6 <sys_page_map>
  80061f:	89 c7                	mov    %eax,%edi
  800621:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800624:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800626:	85 ff                	test   %edi,%edi
  800628:	79 1d                	jns    800647 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 00                	push   $0x0
  800630:	e8 b3 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800635:	83 c4 08             	add    $0x8,%esp
  800638:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063b:	6a 00                	push   $0x0
  80063d:	e8 a6 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	89 f8                	mov    %edi,%eax
}
  800647:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064a:	5b                   	pop    %ebx
  80064b:	5e                   	pop    %esi
  80064c:	5f                   	pop    %edi
  80064d:	5d                   	pop    %ebp
  80064e:	c3                   	ret    

0080064f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064f:	55                   	push   %ebp
  800650:	89 e5                	mov    %esp,%ebp
  800652:	53                   	push   %ebx
  800653:	83 ec 14             	sub    $0x14,%esp
  800656:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800659:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065c:	50                   	push   %eax
  80065d:	53                   	push   %ebx
  80065e:	e8 86 fd ff ff       	call   8003e9 <fd_lookup>
  800663:	83 c4 08             	add    $0x8,%esp
  800666:	89 c2                	mov    %eax,%edx
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 6d                	js     8006d9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800672:	50                   	push   %eax
  800673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800676:	ff 30                	pushl  (%eax)
  800678:	e8 c2 fd ff ff       	call   80043f <dev_lookup>
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	85 c0                	test   %eax,%eax
  800682:	78 4c                	js     8006d0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800684:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800687:	8b 42 08             	mov    0x8(%edx),%eax
  80068a:	83 e0 03             	and    $0x3,%eax
  80068d:	83 f8 01             	cmp    $0x1,%eax
  800690:	75 21                	jne    8006b3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800692:	a1 08 40 80 00       	mov    0x804008,%eax
  800697:	8b 40 48             	mov    0x48(%eax),%eax
  80069a:	83 ec 04             	sub    $0x4,%esp
  80069d:	53                   	push   %ebx
  80069e:	50                   	push   %eax
  80069f:	68 d9 22 80 00       	push   $0x8022d9
  8006a4:	e8 1d 0f 00 00       	call   8015c6 <cprintf>
		return -E_INVAL;
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b1:	eb 26                	jmp    8006d9 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b6:	8b 40 08             	mov    0x8(%eax),%eax
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	74 17                	je     8006d4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bd:	83 ec 04             	sub    $0x4,%esp
  8006c0:	ff 75 10             	pushl  0x10(%ebp)
  8006c3:	ff 75 0c             	pushl  0xc(%ebp)
  8006c6:	52                   	push   %edx
  8006c7:	ff d0                	call   *%eax
  8006c9:	89 c2                	mov    %eax,%edx
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	eb 09                	jmp    8006d9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d0:	89 c2                	mov    %eax,%edx
  8006d2:	eb 05                	jmp    8006d9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d9:	89 d0                	mov    %edx,%eax
  8006db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	57                   	push   %edi
  8006e4:	56                   	push   %esi
  8006e5:	53                   	push   %ebx
  8006e6:	83 ec 0c             	sub    $0xc,%esp
  8006e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f4:	eb 21                	jmp    800717 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f6:	83 ec 04             	sub    $0x4,%esp
  8006f9:	89 f0                	mov    %esi,%eax
  8006fb:	29 d8                	sub    %ebx,%eax
  8006fd:	50                   	push   %eax
  8006fe:	89 d8                	mov    %ebx,%eax
  800700:	03 45 0c             	add    0xc(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	57                   	push   %edi
  800705:	e8 45 ff ff ff       	call   80064f <read>
		if (m < 0)
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	85 c0                	test   %eax,%eax
  80070f:	78 10                	js     800721 <readn+0x41>
			return m;
		if (m == 0)
  800711:	85 c0                	test   %eax,%eax
  800713:	74 0a                	je     80071f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800715:	01 c3                	add    %eax,%ebx
  800717:	39 f3                	cmp    %esi,%ebx
  800719:	72 db                	jb     8006f6 <readn+0x16>
  80071b:	89 d8                	mov    %ebx,%eax
  80071d:	eb 02                	jmp    800721 <readn+0x41>
  80071f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800721:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800724:	5b                   	pop    %ebx
  800725:	5e                   	pop    %esi
  800726:	5f                   	pop    %edi
  800727:	5d                   	pop    %ebp
  800728:	c3                   	ret    

00800729 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800729:	55                   	push   %ebp
  80072a:	89 e5                	mov    %esp,%ebp
  80072c:	53                   	push   %ebx
  80072d:	83 ec 14             	sub    $0x14,%esp
  800730:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800733:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800736:	50                   	push   %eax
  800737:	53                   	push   %ebx
  800738:	e8 ac fc ff ff       	call   8003e9 <fd_lookup>
  80073d:	83 c4 08             	add    $0x8,%esp
  800740:	89 c2                	mov    %eax,%edx
  800742:	85 c0                	test   %eax,%eax
  800744:	78 68                	js     8007ae <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074c:	50                   	push   %eax
  80074d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800750:	ff 30                	pushl  (%eax)
  800752:	e8 e8 fc ff ff       	call   80043f <dev_lookup>
  800757:	83 c4 10             	add    $0x10,%esp
  80075a:	85 c0                	test   %eax,%eax
  80075c:	78 47                	js     8007a5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800761:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800765:	75 21                	jne    800788 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800767:	a1 08 40 80 00       	mov    0x804008,%eax
  80076c:	8b 40 48             	mov    0x48(%eax),%eax
  80076f:	83 ec 04             	sub    $0x4,%esp
  800772:	53                   	push   %ebx
  800773:	50                   	push   %eax
  800774:	68 f5 22 80 00       	push   $0x8022f5
  800779:	e8 48 0e 00 00       	call   8015c6 <cprintf>
		return -E_INVAL;
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800786:	eb 26                	jmp    8007ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800788:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078b:	8b 52 0c             	mov    0xc(%edx),%edx
  80078e:	85 d2                	test   %edx,%edx
  800790:	74 17                	je     8007a9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800792:	83 ec 04             	sub    $0x4,%esp
  800795:	ff 75 10             	pushl  0x10(%ebp)
  800798:	ff 75 0c             	pushl  0xc(%ebp)
  80079b:	50                   	push   %eax
  80079c:	ff d2                	call   *%edx
  80079e:	89 c2                	mov    %eax,%edx
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	eb 09                	jmp    8007ae <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a5:	89 c2                	mov    %eax,%edx
  8007a7:	eb 05                	jmp    8007ae <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ae:	89 d0                	mov    %edx,%eax
  8007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	ff 75 08             	pushl  0x8(%ebp)
  8007c2:	e8 22 fc ff ff       	call   8003e9 <fd_lookup>
  8007c7:	83 c4 08             	add    $0x8,%esp
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	78 0e                	js     8007dc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	83 ec 14             	sub    $0x14,%esp
  8007e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007eb:	50                   	push   %eax
  8007ec:	53                   	push   %ebx
  8007ed:	e8 f7 fb ff ff       	call   8003e9 <fd_lookup>
  8007f2:	83 c4 08             	add    $0x8,%esp
  8007f5:	89 c2                	mov    %eax,%edx
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 65                	js     800860 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800801:	50                   	push   %eax
  800802:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800805:	ff 30                	pushl  (%eax)
  800807:	e8 33 fc ff ff       	call   80043f <dev_lookup>
  80080c:	83 c4 10             	add    $0x10,%esp
  80080f:	85 c0                	test   %eax,%eax
  800811:	78 44                	js     800857 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800813:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800816:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081a:	75 21                	jne    80083d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800821:	8b 40 48             	mov    0x48(%eax),%eax
  800824:	83 ec 04             	sub    $0x4,%esp
  800827:	53                   	push   %ebx
  800828:	50                   	push   %eax
  800829:	68 b8 22 80 00       	push   $0x8022b8
  80082e:	e8 93 0d 00 00       	call   8015c6 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083b:	eb 23                	jmp    800860 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800840:	8b 52 18             	mov    0x18(%edx),%edx
  800843:	85 d2                	test   %edx,%edx
  800845:	74 14                	je     80085b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	50                   	push   %eax
  80084e:	ff d2                	call   *%edx
  800850:	89 c2                	mov    %eax,%edx
  800852:	83 c4 10             	add    $0x10,%esp
  800855:	eb 09                	jmp    800860 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800857:	89 c2                	mov    %eax,%edx
  800859:	eb 05                	jmp    800860 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800860:	89 d0                	mov    %edx,%eax
  800862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	83 ec 14             	sub    $0x14,%esp
  80086e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800871:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	ff 75 08             	pushl  0x8(%ebp)
  800878:	e8 6c fb ff ff       	call   8003e9 <fd_lookup>
  80087d:	83 c4 08             	add    $0x8,%esp
  800880:	89 c2                	mov    %eax,%edx
  800882:	85 c0                	test   %eax,%eax
  800884:	78 58                	js     8008de <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088c:	50                   	push   %eax
  80088d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800890:	ff 30                	pushl  (%eax)
  800892:	e8 a8 fb ff ff       	call   80043f <dev_lookup>
  800897:	83 c4 10             	add    $0x10,%esp
  80089a:	85 c0                	test   %eax,%eax
  80089c:	78 37                	js     8008d5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a5:	74 32                	je     8008d9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008aa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b1:	00 00 00 
	stat->st_isdir = 0;
  8008b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008bb:	00 00 00 
	stat->st_dev = dev;
  8008be:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	53                   	push   %ebx
  8008c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8008cb:	ff 50 14             	call   *0x14(%eax)
  8008ce:	89 c2                	mov    %eax,%edx
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	eb 09                	jmp    8008de <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d5:	89 c2                	mov    %eax,%edx
  8008d7:	eb 05                	jmp    8008de <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008de:	89 d0                	mov    %edx,%eax
  8008e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    

008008e5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	6a 00                	push   $0x0
  8008ef:	ff 75 08             	pushl  0x8(%ebp)
  8008f2:	e8 0c 02 00 00       	call   800b03 <open>
  8008f7:	89 c3                	mov    %eax,%ebx
  8008f9:	83 c4 10             	add    $0x10,%esp
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	78 1b                	js     80091b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800900:	83 ec 08             	sub    $0x8,%esp
  800903:	ff 75 0c             	pushl  0xc(%ebp)
  800906:	50                   	push   %eax
  800907:	e8 5b ff ff ff       	call   800867 <fstat>
  80090c:	89 c6                	mov    %eax,%esi
	close(fd);
  80090e:	89 1c 24             	mov    %ebx,(%esp)
  800911:	e8 fd fb ff ff       	call   800513 <close>
	return r;
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	89 f0                	mov    %esi,%eax
}
  80091b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	89 c6                	mov    %eax,%esi
  800929:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800932:	75 12                	jne    800946 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800934:	83 ec 0c             	sub    $0xc,%esp
  800937:	6a 01                	push   $0x1
  800939:	e8 11 16 00 00       	call   801f4f <ipc_find_env>
  80093e:	a3 00 40 80 00       	mov    %eax,0x804000
  800943:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800946:	6a 07                	push   $0x7
  800948:	68 00 50 80 00       	push   $0x805000
  80094d:	56                   	push   %esi
  80094e:	ff 35 00 40 80 00    	pushl  0x804000
  800954:	e8 a2 15 00 00       	call   801efb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800959:	83 c4 0c             	add    $0xc,%esp
  80095c:	6a 00                	push   $0x0
  80095e:	53                   	push   %ebx
  80095f:	6a 00                	push   $0x0
  800961:	e8 2c 15 00 00       	call   801e92 <ipc_recv>
}
  800966:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 40 0c             	mov    0xc(%eax),%eax
  800979:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800981:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800986:	ba 00 00 00 00       	mov    $0x0,%edx
  80098b:	b8 02 00 00 00       	mov    $0x2,%eax
  800990:	e8 8d ff ff ff       	call   800922 <fsipc>
}
  800995:	c9                   	leave  
  800996:	c3                   	ret    

00800997 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ad:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b2:	e8 6b ff ff ff       	call   800922 <fsipc>
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	83 ec 04             	sub    $0x4,%esp
  8009c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d8:	e8 45 ff ff ff       	call   800922 <fsipc>
  8009dd:	85 c0                	test   %eax,%eax
  8009df:	78 2c                	js     800a0d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e1:	83 ec 08             	sub    $0x8,%esp
  8009e4:	68 00 50 80 00       	push   $0x805000
  8009e9:	53                   	push   %ebx
  8009ea:	e8 5c 11 00 00       	call   801b4b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ef:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009fa:	a1 84 50 80 00       	mov    0x805084,%eax
  8009ff:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a05:	83 c4 10             	add    $0x10,%esp
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	83 ec 08             	sub    $0x8,%esp
  800a19:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a22:	89 15 00 50 80 00    	mov    %edx,0x805000
  800a28:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a2d:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  800a32:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  800a35:	89 1d 04 50 80 00    	mov    %ebx,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  800a3b:	53                   	push   %ebx
  800a3c:	ff 75 0c             	pushl  0xc(%ebp)
  800a3f:	68 08 50 80 00       	push   $0x805008
  800a44:	e8 94 12 00 00       	call   801cdd <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4e:	b8 04 00 00 00       	mov    $0x4,%eax
  800a53:	e8 ca fe ff ff       	call   800922 <fsipc>
  800a58:	83 c4 10             	add    $0x10,%esp
  800a5b:	85 c0                	test   %eax,%eax
  800a5d:	78 1d                	js     800a7c <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  800a5f:	39 d8                	cmp    %ebx,%eax
  800a61:	76 19                	jbe    800a7c <devfile_write+0x6a>
  800a63:	68 28 23 80 00       	push   $0x802328
  800a68:	68 34 23 80 00       	push   $0x802334
  800a6d:	68 a3 00 00 00       	push   $0xa3
  800a72:	68 49 23 80 00       	push   $0x802349
  800a77:	e8 71 0a 00 00       	call   8014ed <_panic>
	return r;
}
  800a7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a94:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa4:	e8 79 fe ff ff       	call   800922 <fsipc>
  800aa9:	89 c3                	mov    %eax,%ebx
  800aab:	85 c0                	test   %eax,%eax
  800aad:	78 4b                	js     800afa <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aaf:	39 c6                	cmp    %eax,%esi
  800ab1:	73 16                	jae    800ac9 <devfile_read+0x48>
  800ab3:	68 54 23 80 00       	push   $0x802354
  800ab8:	68 34 23 80 00       	push   $0x802334
  800abd:	6a 7c                	push   $0x7c
  800abf:	68 49 23 80 00       	push   $0x802349
  800ac4:	e8 24 0a 00 00       	call   8014ed <_panic>
	assert(r <= PGSIZE);
  800ac9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ace:	7e 16                	jle    800ae6 <devfile_read+0x65>
  800ad0:	68 5b 23 80 00       	push   $0x80235b
  800ad5:	68 34 23 80 00       	push   $0x802334
  800ada:	6a 7d                	push   $0x7d
  800adc:	68 49 23 80 00       	push   $0x802349
  800ae1:	e8 07 0a 00 00       	call   8014ed <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae6:	83 ec 04             	sub    $0x4,%esp
  800ae9:	50                   	push   %eax
  800aea:	68 00 50 80 00       	push   $0x805000
  800aef:	ff 75 0c             	pushl  0xc(%ebp)
  800af2:	e8 e6 11 00 00       	call   801cdd <memmove>
	return r;
  800af7:	83 c4 10             	add    $0x10,%esp
}
  800afa:	89 d8                	mov    %ebx,%eax
  800afc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	53                   	push   %ebx
  800b07:	83 ec 20             	sub    $0x20,%esp
  800b0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b0d:	53                   	push   %ebx
  800b0e:	e8 ff 0f 00 00       	call   801b12 <strlen>
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1b:	7f 67                	jg     800b84 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b23:	50                   	push   %eax
  800b24:	e8 71 f8 ff ff       	call   80039a <fd_alloc>
  800b29:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 57                	js     800b89 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b32:	83 ec 08             	sub    $0x8,%esp
  800b35:	53                   	push   %ebx
  800b36:	68 00 50 80 00       	push   $0x805000
  800b3b:	e8 0b 10 00 00       	call   801b4b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b50:	e8 cd fd ff ff       	call   800922 <fsipc>
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	79 14                	jns    800b72 <open+0x6f>
		fd_close(fd, 0);
  800b5e:	83 ec 08             	sub    $0x8,%esp
  800b61:	6a 00                	push   $0x0
  800b63:	ff 75 f4             	pushl  -0xc(%ebp)
  800b66:	e8 27 f9 ff ff       	call   800492 <fd_close>
		return r;
  800b6b:	83 c4 10             	add    $0x10,%esp
  800b6e:	89 da                	mov    %ebx,%edx
  800b70:	eb 17                	jmp    800b89 <open+0x86>
	}

	return fd2num(fd);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	ff 75 f4             	pushl  -0xc(%ebp)
  800b78:	e8 f6 f7 ff ff       	call   800373 <fd2num>
  800b7d:	89 c2                	mov    %eax,%edx
  800b7f:	83 c4 10             	add    $0x10,%esp
  800b82:	eb 05                	jmp    800b89 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b84:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b89:	89 d0                	mov    %edx,%eax
  800b8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba0:	e8 7d fd ff ff       	call   800922 <fsipc>
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bad:	68 67 23 80 00       	push   $0x802367
  800bb2:	ff 75 0c             	pushl  0xc(%ebp)
  800bb5:	e8 91 0f 00 00       	call   801b4b <strcpy>
	return 0;
}
  800bba:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 10             	sub    $0x10,%esp
  800bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bcb:	53                   	push   %ebx
  800bcc:	e8 b7 13 00 00       	call   801f88 <pageref>
  800bd1:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd9:	83 f8 01             	cmp    $0x1,%eax
  800bdc:	75 10                	jne    800bee <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	ff 73 0c             	pushl  0xc(%ebx)
  800be4:	e8 c0 02 00 00       	call   800ea9 <nsipc_close>
  800be9:	89 c2                	mov    %eax,%edx
  800beb:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bee:	89 d0                	mov    %edx,%eax
  800bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bfb:	6a 00                	push   $0x0
  800bfd:	ff 75 10             	pushl  0x10(%ebp)
  800c00:	ff 75 0c             	pushl  0xc(%ebp)
  800c03:	8b 45 08             	mov    0x8(%ebp),%eax
  800c06:	ff 70 0c             	pushl  0xc(%eax)
  800c09:	e8 78 03 00 00       	call   800f86 <nsipc_send>
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c16:	6a 00                	push   $0x0
  800c18:	ff 75 10             	pushl  0x10(%ebp)
  800c1b:	ff 75 0c             	pushl  0xc(%ebp)
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	ff 70 0c             	pushl  0xc(%eax)
  800c24:	e8 f1 02 00 00       	call   800f1a <nsipc_recv>
}
  800c29:	c9                   	leave  
  800c2a:	c3                   	ret    

00800c2b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c31:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c34:	52                   	push   %edx
  800c35:	50                   	push   %eax
  800c36:	e8 ae f7 ff ff       	call   8003e9 <fd_lookup>
  800c3b:	83 c4 10             	add    $0x10,%esp
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	78 17                	js     800c59 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c45:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c4b:	39 08                	cmp    %ecx,(%eax)
  800c4d:	75 05                	jne    800c54 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c4f:	8b 40 0c             	mov    0xc(%eax),%eax
  800c52:	eb 05                	jmp    800c59 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c54:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c59:	c9                   	leave  
  800c5a:	c3                   	ret    

00800c5b <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 1c             	sub    $0x1c,%esp
  800c63:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c68:	50                   	push   %eax
  800c69:	e8 2c f7 ff ff       	call   80039a <fd_alloc>
  800c6e:	89 c3                	mov    %eax,%ebx
  800c70:	83 c4 10             	add    $0x10,%esp
  800c73:	85 c0                	test   %eax,%eax
  800c75:	78 1b                	js     800c92 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c77:	83 ec 04             	sub    $0x4,%esp
  800c7a:	68 07 04 00 00       	push   $0x407
  800c7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800c82:	6a 00                	push   $0x0
  800c84:	e8 da f4 ff ff       	call   800163 <sys_page_alloc>
  800c89:	89 c3                	mov    %eax,%ebx
  800c8b:	83 c4 10             	add    $0x10,%esp
  800c8e:	85 c0                	test   %eax,%eax
  800c90:	79 10                	jns    800ca2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c92:	83 ec 0c             	sub    $0xc,%esp
  800c95:	56                   	push   %esi
  800c96:	e8 0e 02 00 00       	call   800ea9 <nsipc_close>
		return r;
  800c9b:	83 c4 10             	add    $0x10,%esp
  800c9e:	89 d8                	mov    %ebx,%eax
  800ca0:	eb 24                	jmp    800cc6 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ca2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cab:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cb7:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	e8 b0 f6 ff ff       	call   800373 <fd2num>
  800cc3:	83 c4 10             	add    $0x10,%esp
}
  800cc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd6:	e8 50 ff ff ff       	call   800c2b <fd2sockid>
		return r;
  800cdb:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	78 1f                	js     800d00 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce1:	83 ec 04             	sub    $0x4,%esp
  800ce4:	ff 75 10             	pushl  0x10(%ebp)
  800ce7:	ff 75 0c             	pushl  0xc(%ebp)
  800cea:	50                   	push   %eax
  800ceb:	e8 12 01 00 00       	call   800e02 <nsipc_accept>
  800cf0:	83 c4 10             	add    $0x10,%esp
		return r;
  800cf3:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	78 07                	js     800d00 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf9:	e8 5d ff ff ff       	call   800c5b <alloc_sockfd>
  800cfe:	89 c1                	mov    %eax,%ecx
}
  800d00:	89 c8                	mov    %ecx,%eax
  800d02:	c9                   	leave  
  800d03:	c3                   	ret    

00800d04 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	e8 19 ff ff ff       	call   800c2b <fd2sockid>
  800d12:	85 c0                	test   %eax,%eax
  800d14:	78 12                	js     800d28 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d16:	83 ec 04             	sub    $0x4,%esp
  800d19:	ff 75 10             	pushl  0x10(%ebp)
  800d1c:	ff 75 0c             	pushl  0xc(%ebp)
  800d1f:	50                   	push   %eax
  800d20:	e8 2d 01 00 00       	call   800e52 <nsipc_bind>
  800d25:	83 c4 10             	add    $0x10,%esp
}
  800d28:	c9                   	leave  
  800d29:	c3                   	ret    

00800d2a <shutdown>:

int
shutdown(int s, int how)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d30:	8b 45 08             	mov    0x8(%ebp),%eax
  800d33:	e8 f3 fe ff ff       	call   800c2b <fd2sockid>
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	78 0f                	js     800d4b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d3c:	83 ec 08             	sub    $0x8,%esp
  800d3f:	ff 75 0c             	pushl  0xc(%ebp)
  800d42:	50                   	push   %eax
  800d43:	e8 3f 01 00 00       	call   800e87 <nsipc_shutdown>
  800d48:	83 c4 10             	add    $0x10,%esp
}
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	e8 d0 fe ff ff       	call   800c2b <fd2sockid>
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	78 12                	js     800d71 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d5f:	83 ec 04             	sub    $0x4,%esp
  800d62:	ff 75 10             	pushl  0x10(%ebp)
  800d65:	ff 75 0c             	pushl  0xc(%ebp)
  800d68:	50                   	push   %eax
  800d69:	e8 55 01 00 00       	call   800ec3 <nsipc_connect>
  800d6e:	83 c4 10             	add    $0x10,%esp
}
  800d71:	c9                   	leave  
  800d72:	c3                   	ret    

00800d73 <listen>:

int
listen(int s, int backlog)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	e8 aa fe ff ff       	call   800c2b <fd2sockid>
  800d81:	85 c0                	test   %eax,%eax
  800d83:	78 0f                	js     800d94 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d85:	83 ec 08             	sub    $0x8,%esp
  800d88:	ff 75 0c             	pushl  0xc(%ebp)
  800d8b:	50                   	push   %eax
  800d8c:	e8 67 01 00 00       	call   800ef8 <nsipc_listen>
  800d91:	83 c4 10             	add    $0x10,%esp
}
  800d94:	c9                   	leave  
  800d95:	c3                   	ret    

00800d96 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d9c:	ff 75 10             	pushl  0x10(%ebp)
  800d9f:	ff 75 0c             	pushl  0xc(%ebp)
  800da2:	ff 75 08             	pushl  0x8(%ebp)
  800da5:	e8 3a 02 00 00       	call   800fe4 <nsipc_socket>
  800daa:	83 c4 10             	add    $0x10,%esp
  800dad:	85 c0                	test   %eax,%eax
  800daf:	78 05                	js     800db6 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800db1:	e8 a5 fe ff ff       	call   800c5b <alloc_sockfd>
}
  800db6:	c9                   	leave  
  800db7:	c3                   	ret    

00800db8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 04             	sub    $0x4,%esp
  800dbf:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dc1:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc8:	75 12                	jne    800ddc <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	6a 02                	push   $0x2
  800dcf:	e8 7b 11 00 00       	call   801f4f <ipc_find_env>
  800dd4:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800ddc:	6a 07                	push   $0x7
  800dde:	68 00 60 80 00       	push   $0x806000
  800de3:	53                   	push   %ebx
  800de4:	ff 35 04 40 80 00    	pushl  0x804004
  800dea:	e8 0c 11 00 00       	call   801efb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800def:	83 c4 0c             	add    $0xc,%esp
  800df2:	6a 00                	push   $0x0
  800df4:	6a 00                	push   $0x0
  800df6:	6a 00                	push   $0x0
  800df8:	e8 95 10 00 00       	call   801e92 <ipc_recv>
}
  800dfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e12:	8b 06                	mov    (%esi),%eax
  800e14:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e19:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1e:	e8 95 ff ff ff       	call   800db8 <nsipc>
  800e23:	89 c3                	mov    %eax,%ebx
  800e25:	85 c0                	test   %eax,%eax
  800e27:	78 20                	js     800e49 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e29:	83 ec 04             	sub    $0x4,%esp
  800e2c:	ff 35 10 60 80 00    	pushl  0x806010
  800e32:	68 00 60 80 00       	push   $0x806000
  800e37:	ff 75 0c             	pushl  0xc(%ebp)
  800e3a:	e8 9e 0e 00 00       	call   801cdd <memmove>
		*addrlen = ret->ret_addrlen;
  800e3f:	a1 10 60 80 00       	mov    0x806010,%eax
  800e44:	89 06                	mov    %eax,(%esi)
  800e46:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e49:	89 d8                	mov    %ebx,%eax
  800e4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	53                   	push   %ebx
  800e56:	83 ec 08             	sub    $0x8,%esp
  800e59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e64:	53                   	push   %ebx
  800e65:	ff 75 0c             	pushl  0xc(%ebp)
  800e68:	68 04 60 80 00       	push   $0x806004
  800e6d:	e8 6b 0e 00 00       	call   801cdd <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e72:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e78:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7d:	e8 36 ff ff ff       	call   800db8 <nsipc>
}
  800e82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e85:	c9                   	leave  
  800e86:	c3                   	ret    

00800e87 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e90:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e98:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e9d:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea2:	e8 11 ff ff ff       	call   800db8 <nsipc>
}
  800ea7:	c9                   	leave  
  800ea8:	c3                   	ret    

00800ea9 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb7:	b8 04 00 00 00       	mov    $0x4,%eax
  800ebc:	e8 f7 fe ff ff       	call   800db8 <nsipc>
}
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	53                   	push   %ebx
  800ec7:	83 ec 08             	sub    $0x8,%esp
  800eca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed5:	53                   	push   %ebx
  800ed6:	ff 75 0c             	pushl  0xc(%ebp)
  800ed9:	68 04 60 80 00       	push   $0x806004
  800ede:	e8 fa 0d 00 00       	call   801cdd <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ee3:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee9:	b8 05 00 00 00       	mov    $0x5,%eax
  800eee:	e8 c5 fe ff ff       	call   800db8 <nsipc>
}
  800ef3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800efe:	8b 45 08             	mov    0x8(%ebp),%eax
  800f01:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f09:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f13:	e8 a0 fe ff ff       	call   800db8 <nsipc>
}
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f22:	8b 45 08             	mov    0x8(%ebp),%eax
  800f25:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f2a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f30:	8b 45 14             	mov    0x14(%ebp),%eax
  800f33:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f38:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3d:	e8 76 fe ff ff       	call   800db8 <nsipc>
  800f42:	89 c3                	mov    %eax,%ebx
  800f44:	85 c0                	test   %eax,%eax
  800f46:	78 35                	js     800f7d <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f48:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f4d:	7f 04                	jg     800f53 <nsipc_recv+0x39>
  800f4f:	39 c6                	cmp    %eax,%esi
  800f51:	7d 16                	jge    800f69 <nsipc_recv+0x4f>
  800f53:	68 73 23 80 00       	push   $0x802373
  800f58:	68 34 23 80 00       	push   $0x802334
  800f5d:	6a 62                	push   $0x62
  800f5f:	68 88 23 80 00       	push   $0x802388
  800f64:	e8 84 05 00 00       	call   8014ed <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f69:	83 ec 04             	sub    $0x4,%esp
  800f6c:	50                   	push   %eax
  800f6d:	68 00 60 80 00       	push   $0x806000
  800f72:	ff 75 0c             	pushl  0xc(%ebp)
  800f75:	e8 63 0d 00 00       	call   801cdd <memmove>
  800f7a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f7d:	89 d8                	mov    %ebx,%eax
  800f7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	53                   	push   %ebx
  800f8a:	83 ec 04             	sub    $0x4,%esp
  800f8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
  800f93:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f98:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f9e:	7e 16                	jle    800fb6 <nsipc_send+0x30>
  800fa0:	68 94 23 80 00       	push   $0x802394
  800fa5:	68 34 23 80 00       	push   $0x802334
  800faa:	6a 6d                	push   $0x6d
  800fac:	68 88 23 80 00       	push   $0x802388
  800fb1:	e8 37 05 00 00       	call   8014ed <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	53                   	push   %ebx
  800fba:	ff 75 0c             	pushl  0xc(%ebp)
  800fbd:	68 0c 60 80 00       	push   $0x80600c
  800fc2:	e8 16 0d 00 00       	call   801cdd <memmove>
	nsipcbuf.send.req_size = size;
  800fc7:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fcd:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fd5:	b8 08 00 00 00       	mov    $0x8,%eax
  800fda:	e8 d9 fd ff ff       	call   800db8 <nsipc>
}
  800fdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fea:	8b 45 08             	mov    0x8(%ebp),%eax
  800fed:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff5:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ffa:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801002:	b8 09 00 00 00       	mov    $0x9,%eax
  801007:	e8 ac fd ff ff       	call   800db8 <nsipc>
}
  80100c:	c9                   	leave  
  80100d:	c3                   	ret    

0080100e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	56                   	push   %esi
  801012:	53                   	push   %ebx
  801013:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	ff 75 08             	pushl  0x8(%ebp)
  80101c:	e8 62 f3 ff ff       	call   800383 <fd2data>
  801021:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801023:	83 c4 08             	add    $0x8,%esp
  801026:	68 a0 23 80 00       	push   $0x8023a0
  80102b:	53                   	push   %ebx
  80102c:	e8 1a 0b 00 00       	call   801b4b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801031:	8b 46 04             	mov    0x4(%esi),%eax
  801034:	2b 06                	sub    (%esi),%eax
  801036:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80103c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801043:	00 00 00 
	stat->st_dev = &devpipe;
  801046:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80104d:	30 80 00 
	return 0;
}
  801050:	b8 00 00 00 00       	mov    $0x0,%eax
  801055:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	53                   	push   %ebx
  801060:	83 ec 0c             	sub    $0xc,%esp
  801063:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801066:	53                   	push   %ebx
  801067:	6a 00                	push   $0x0
  801069:	e8 7a f1 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80106e:	89 1c 24             	mov    %ebx,(%esp)
  801071:	e8 0d f3 ff ff       	call   800383 <fd2data>
  801076:	83 c4 08             	add    $0x8,%esp
  801079:	50                   	push   %eax
  80107a:	6a 00                	push   $0x0
  80107c:	e8 67 f1 ff ff       	call   8001e8 <sys_page_unmap>
}
  801081:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	57                   	push   %edi
  80108a:	56                   	push   %esi
  80108b:	53                   	push   %ebx
  80108c:	83 ec 1c             	sub    $0x1c,%esp
  80108f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801092:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801094:	a1 08 40 80 00       	mov    0x804008,%eax
  801099:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a2:	e8 e1 0e 00 00       	call   801f88 <pageref>
  8010a7:	89 c3                	mov    %eax,%ebx
  8010a9:	89 3c 24             	mov    %edi,(%esp)
  8010ac:	e8 d7 0e 00 00       	call   801f88 <pageref>
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	39 c3                	cmp    %eax,%ebx
  8010b6:	0f 94 c1             	sete   %cl
  8010b9:	0f b6 c9             	movzbl %cl,%ecx
  8010bc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010bf:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010c5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c8:	39 ce                	cmp    %ecx,%esi
  8010ca:	74 1b                	je     8010e7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010cc:	39 c3                	cmp    %eax,%ebx
  8010ce:	75 c4                	jne    801094 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010d0:	8b 42 58             	mov    0x58(%edx),%eax
  8010d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d6:	50                   	push   %eax
  8010d7:	56                   	push   %esi
  8010d8:	68 a7 23 80 00       	push   $0x8023a7
  8010dd:	e8 e4 04 00 00       	call   8015c6 <cprintf>
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	eb ad                	jmp    801094 <_pipeisclosed+0xe>
	}
}
  8010e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 28             	sub    $0x28,%esp
  8010fb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010fe:	56                   	push   %esi
  8010ff:	e8 7f f2 ff ff       	call   800383 <fd2data>
  801104:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801106:	83 c4 10             	add    $0x10,%esp
  801109:	bf 00 00 00 00       	mov    $0x0,%edi
  80110e:	eb 4b                	jmp    80115b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801110:	89 da                	mov    %ebx,%edx
  801112:	89 f0                	mov    %esi,%eax
  801114:	e8 6d ff ff ff       	call   801086 <_pipeisclosed>
  801119:	85 c0                	test   %eax,%eax
  80111b:	75 48                	jne    801165 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80111d:	e8 22 f0 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801122:	8b 43 04             	mov    0x4(%ebx),%eax
  801125:	8b 0b                	mov    (%ebx),%ecx
  801127:	8d 51 20             	lea    0x20(%ecx),%edx
  80112a:	39 d0                	cmp    %edx,%eax
  80112c:	73 e2                	jae    801110 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80112e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801131:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801135:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801138:	89 c2                	mov    %eax,%edx
  80113a:	c1 fa 1f             	sar    $0x1f,%edx
  80113d:	89 d1                	mov    %edx,%ecx
  80113f:	c1 e9 1b             	shr    $0x1b,%ecx
  801142:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801145:	83 e2 1f             	and    $0x1f,%edx
  801148:	29 ca                	sub    %ecx,%edx
  80114a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80114e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801152:	83 c0 01             	add    $0x1,%eax
  801155:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801158:	83 c7 01             	add    $0x1,%edi
  80115b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80115e:	75 c2                	jne    801122 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801160:	8b 45 10             	mov    0x10(%ebp),%eax
  801163:	eb 05                	jmp    80116a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801165:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80116a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116d:	5b                   	pop    %ebx
  80116e:	5e                   	pop    %esi
  80116f:	5f                   	pop    %edi
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 18             	sub    $0x18,%esp
  80117b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80117e:	57                   	push   %edi
  80117f:	e8 ff f1 ff ff       	call   800383 <fd2data>
  801184:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118e:	eb 3d                	jmp    8011cd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801190:	85 db                	test   %ebx,%ebx
  801192:	74 04                	je     801198 <devpipe_read+0x26>
				return i;
  801194:	89 d8                	mov    %ebx,%eax
  801196:	eb 44                	jmp    8011dc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801198:	89 f2                	mov    %esi,%edx
  80119a:	89 f8                	mov    %edi,%eax
  80119c:	e8 e5 fe ff ff       	call   801086 <_pipeisclosed>
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	75 32                	jne    8011d7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011a5:	e8 9a ef ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011aa:	8b 06                	mov    (%esi),%eax
  8011ac:	3b 46 04             	cmp    0x4(%esi),%eax
  8011af:	74 df                	je     801190 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b1:	99                   	cltd   
  8011b2:	c1 ea 1b             	shr    $0x1b,%edx
  8011b5:	01 d0                	add    %edx,%eax
  8011b7:	83 e0 1f             	and    $0x1f,%eax
  8011ba:	29 d0                	sub    %edx,%eax
  8011bc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011c7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011ca:	83 c3 01             	add    $0x1,%ebx
  8011cd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011d0:	75 d8                	jne    8011aa <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d5:	eb 05                	jmp    8011dc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	56                   	push   %esi
  8011e8:	53                   	push   %ebx
  8011e9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ef:	50                   	push   %eax
  8011f0:	e8 a5 f1 ff ff       	call   80039a <fd_alloc>
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	0f 88 2c 01 00 00    	js     80132e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	68 07 04 00 00       	push   $0x407
  80120a:	ff 75 f4             	pushl  -0xc(%ebp)
  80120d:	6a 00                	push   $0x0
  80120f:	e8 4f ef ff ff       	call   800163 <sys_page_alloc>
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	89 c2                	mov    %eax,%edx
  801219:	85 c0                	test   %eax,%eax
  80121b:	0f 88 0d 01 00 00    	js     80132e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801221:	83 ec 0c             	sub    $0xc,%esp
  801224:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	e8 6d f1 ff ff       	call   80039a <fd_alloc>
  80122d:	89 c3                	mov    %eax,%ebx
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	85 c0                	test   %eax,%eax
  801234:	0f 88 e2 00 00 00    	js     80131c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80123a:	83 ec 04             	sub    $0x4,%esp
  80123d:	68 07 04 00 00       	push   $0x407
  801242:	ff 75 f0             	pushl  -0x10(%ebp)
  801245:	6a 00                	push   $0x0
  801247:	e8 17 ef ff ff       	call   800163 <sys_page_alloc>
  80124c:	89 c3                	mov    %eax,%ebx
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	0f 88 c3 00 00 00    	js     80131c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801259:	83 ec 0c             	sub    $0xc,%esp
  80125c:	ff 75 f4             	pushl  -0xc(%ebp)
  80125f:	e8 1f f1 ff ff       	call   800383 <fd2data>
  801264:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801266:	83 c4 0c             	add    $0xc,%esp
  801269:	68 07 04 00 00       	push   $0x407
  80126e:	50                   	push   %eax
  80126f:	6a 00                	push   $0x0
  801271:	e8 ed ee ff ff       	call   800163 <sys_page_alloc>
  801276:	89 c3                	mov    %eax,%ebx
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	0f 88 89 00 00 00    	js     80130c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801283:	83 ec 0c             	sub    $0xc,%esp
  801286:	ff 75 f0             	pushl  -0x10(%ebp)
  801289:	e8 f5 f0 ff ff       	call   800383 <fd2data>
  80128e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801295:	50                   	push   %eax
  801296:	6a 00                	push   $0x0
  801298:	56                   	push   %esi
  801299:	6a 00                	push   $0x0
  80129b:	e8 06 ef ff ff       	call   8001a6 <sys_page_map>
  8012a0:	89 c3                	mov    %eax,%ebx
  8012a2:	83 c4 20             	add    $0x20,%esp
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	78 55                	js     8012fe <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012be:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012cc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012d3:	83 ec 0c             	sub    $0xc,%esp
  8012d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d9:	e8 95 f0 ff ff       	call   800373 <fd2num>
  8012de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e3:	83 c4 04             	add    $0x4,%esp
  8012e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e9:	e8 85 f0 ff ff       	call   800373 <fd2num>
  8012ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fc:	eb 30                	jmp    80132e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	56                   	push   %esi
  801302:	6a 00                	push   $0x0
  801304:	e8 df ee ff ff       	call   8001e8 <sys_page_unmap>
  801309:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	ff 75 f0             	pushl  -0x10(%ebp)
  801312:	6a 00                	push   $0x0
  801314:	e8 cf ee ff ff       	call   8001e8 <sys_page_unmap>
  801319:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	ff 75 f4             	pushl  -0xc(%ebp)
  801322:	6a 00                	push   $0x0
  801324:	e8 bf ee ff ff       	call   8001e8 <sys_page_unmap>
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80132e:	89 d0                	mov    %edx,%eax
  801330:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	ff 75 08             	pushl  0x8(%ebp)
  801344:	e8 a0 f0 ff ff       	call   8003e9 <fd_lookup>
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 18                	js     801368 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801350:	83 ec 0c             	sub    $0xc,%esp
  801353:	ff 75 f4             	pushl  -0xc(%ebp)
  801356:	e8 28 f0 ff ff       	call   800383 <fd2data>
	return _pipeisclosed(fd, p);
  80135b:	89 c2                	mov    %eax,%edx
  80135d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801360:	e8 21 fd ff ff       	call   801086 <_pipeisclosed>
  801365:	83 c4 10             	add    $0x10,%esp
}
  801368:	c9                   	leave  
  801369:	c3                   	ret    

0080136a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80137a:	68 bf 23 80 00       	push   $0x8023bf
  80137f:	ff 75 0c             	pushl  0xc(%ebp)
  801382:	e8 c4 07 00 00       	call   801b4b <strcpy>
	return 0;
}
  801387:	b8 00 00 00 00       	mov    $0x0,%eax
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
  801391:	57                   	push   %edi
  801392:	56                   	push   %esi
  801393:	53                   	push   %ebx
  801394:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80139a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80139f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a5:	eb 2d                	jmp    8013d4 <devcons_write+0x46>
		m = n - tot;
  8013a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013aa:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013ac:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013af:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013b4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b7:	83 ec 04             	sub    $0x4,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	03 45 0c             	add    0xc(%ebp),%eax
  8013be:	50                   	push   %eax
  8013bf:	57                   	push   %edi
  8013c0:	e8 18 09 00 00       	call   801cdd <memmove>
		sys_cputs(buf, m);
  8013c5:	83 c4 08             	add    $0x8,%esp
  8013c8:	53                   	push   %ebx
  8013c9:	57                   	push   %edi
  8013ca:	e8 d8 ec ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013cf:	01 de                	add    %ebx,%esi
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	89 f0                	mov    %esi,%eax
  8013d6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d9:	72 cc                	jb     8013a7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013de:	5b                   	pop    %ebx
  8013df:	5e                   	pop    %esi
  8013e0:	5f                   	pop    %edi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f2:	74 2a                	je     80141e <devcons_read+0x3b>
  8013f4:	eb 05                	jmp    8013fb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f6:	e8 49 ed ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013fb:	e8 c5 ec ff ff       	call   8000c5 <sys_cgetc>
  801400:	85 c0                	test   %eax,%eax
  801402:	74 f2                	je     8013f6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801404:	85 c0                	test   %eax,%eax
  801406:	78 16                	js     80141e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801408:	83 f8 04             	cmp    $0x4,%eax
  80140b:	74 0c                	je     801419 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80140d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801410:	88 02                	mov    %al,(%edx)
	return 1;
  801412:	b8 01 00 00 00       	mov    $0x1,%eax
  801417:	eb 05                	jmp    80141e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801419:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801426:	8b 45 08             	mov    0x8(%ebp),%eax
  801429:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80142c:	6a 01                	push   $0x1
  80142e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	e8 70 ec ff ff       	call   8000a7 <sys_cputs>
}
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	c9                   	leave  
  80143b:	c3                   	ret    

0080143c <getchar>:

int
getchar(void)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801442:	6a 01                	push   $0x1
  801444:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801447:	50                   	push   %eax
  801448:	6a 00                	push   $0x0
  80144a:	e8 00 f2 ff ff       	call   80064f <read>
	if (r < 0)
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 0f                	js     801465 <getchar+0x29>
		return r;
	if (r < 1)
  801456:	85 c0                	test   %eax,%eax
  801458:	7e 06                	jle    801460 <getchar+0x24>
		return -E_EOF;
	return c;
  80145a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80145e:	eb 05                	jmp    801465 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801460:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801465:	c9                   	leave  
  801466:	c3                   	ret    

00801467 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801470:	50                   	push   %eax
  801471:	ff 75 08             	pushl  0x8(%ebp)
  801474:	e8 70 ef ff ff       	call   8003e9 <fd_lookup>
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 11                	js     801491 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801483:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801489:	39 10                	cmp    %edx,(%eax)
  80148b:	0f 94 c0             	sete   %al
  80148e:	0f b6 c0             	movzbl %al,%eax
}
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <opencons>:

int
opencons(void)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801499:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149c:	50                   	push   %eax
  80149d:	e8 f8 ee ff ff       	call   80039a <fd_alloc>
  8014a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 3e                	js     8014e9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ab:	83 ec 04             	sub    $0x4,%esp
  8014ae:	68 07 04 00 00       	push   $0x407
  8014b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b6:	6a 00                	push   $0x0
  8014b8:	e8 a6 ec ff ff       	call   800163 <sys_page_alloc>
  8014bd:	83 c4 10             	add    $0x10,%esp
		return r;
  8014c0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 23                	js     8014e9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014db:	83 ec 0c             	sub    $0xc,%esp
  8014de:	50                   	push   %eax
  8014df:	e8 8f ee ff ff       	call   800373 <fd2num>
  8014e4:	89 c2                	mov    %eax,%edx
  8014e6:	83 c4 10             	add    $0x10,%esp
}
  8014e9:	89 d0                	mov    %edx,%eax
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	56                   	push   %esi
  8014f1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014f5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014fb:	e8 25 ec ff ff       	call   800125 <sys_getenvid>
  801500:	83 ec 0c             	sub    $0xc,%esp
  801503:	ff 75 0c             	pushl  0xc(%ebp)
  801506:	ff 75 08             	pushl  0x8(%ebp)
  801509:	56                   	push   %esi
  80150a:	50                   	push   %eax
  80150b:	68 cc 23 80 00       	push   $0x8023cc
  801510:	e8 b1 00 00 00       	call   8015c6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801515:	83 c4 18             	add    $0x18,%esp
  801518:	53                   	push   %ebx
  801519:	ff 75 10             	pushl  0x10(%ebp)
  80151c:	e8 54 00 00 00       	call   801575 <vcprintf>
	cprintf("\n");
  801521:	c7 04 24 b8 23 80 00 	movl   $0x8023b8,(%esp)
  801528:	e8 99 00 00 00       	call   8015c6 <cprintf>
  80152d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801530:	cc                   	int3   
  801531:	eb fd                	jmp    801530 <_panic+0x43>

00801533 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 04             	sub    $0x4,%esp
  80153a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80153d:	8b 13                	mov    (%ebx),%edx
  80153f:	8d 42 01             	lea    0x1(%edx),%eax
  801542:	89 03                	mov    %eax,(%ebx)
  801544:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801547:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80154b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801550:	75 1a                	jne    80156c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	68 ff 00 00 00       	push   $0xff
  80155a:	8d 43 08             	lea    0x8(%ebx),%eax
  80155d:	50                   	push   %eax
  80155e:	e8 44 eb ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  801563:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801569:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80156c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801570:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801573:	c9                   	leave  
  801574:	c3                   	ret    

00801575 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801575:	55                   	push   %ebp
  801576:	89 e5                	mov    %esp,%ebp
  801578:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80157e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801585:	00 00 00 
	b.cnt = 0;
  801588:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80158f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801592:	ff 75 0c             	pushl  0xc(%ebp)
  801595:	ff 75 08             	pushl  0x8(%ebp)
  801598:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80159e:	50                   	push   %eax
  80159f:	68 33 15 80 00       	push   $0x801533
  8015a4:	e8 54 01 00 00       	call   8016fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a9:	83 c4 08             	add    $0x8,%esp
  8015ac:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	e8 e9 ea ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  8015be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015cf:	50                   	push   %eax
  8015d0:	ff 75 08             	pushl  0x8(%ebp)
  8015d3:	e8 9d ff ff ff       	call   801575 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	57                   	push   %edi
  8015de:	56                   	push   %esi
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 1c             	sub    $0x1c,%esp
  8015e3:	89 c7                	mov    %eax,%edi
  8015e5:	89 d6                	mov    %edx,%esi
  8015e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015fe:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801601:	39 d3                	cmp    %edx,%ebx
  801603:	72 05                	jb     80160a <printnum+0x30>
  801605:	39 45 10             	cmp    %eax,0x10(%ebp)
  801608:	77 45                	ja     80164f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80160a:	83 ec 0c             	sub    $0xc,%esp
  80160d:	ff 75 18             	pushl  0x18(%ebp)
  801610:	8b 45 14             	mov    0x14(%ebp),%eax
  801613:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801616:	53                   	push   %ebx
  801617:	ff 75 10             	pushl  0x10(%ebp)
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801620:	ff 75 e0             	pushl  -0x20(%ebp)
  801623:	ff 75 dc             	pushl  -0x24(%ebp)
  801626:	ff 75 d8             	pushl  -0x28(%ebp)
  801629:	e8 a2 09 00 00       	call   801fd0 <__udivdi3>
  80162e:	83 c4 18             	add    $0x18,%esp
  801631:	52                   	push   %edx
  801632:	50                   	push   %eax
  801633:	89 f2                	mov    %esi,%edx
  801635:	89 f8                	mov    %edi,%eax
  801637:	e8 9e ff ff ff       	call   8015da <printnum>
  80163c:	83 c4 20             	add    $0x20,%esp
  80163f:	eb 18                	jmp    801659 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801641:	83 ec 08             	sub    $0x8,%esp
  801644:	56                   	push   %esi
  801645:	ff 75 18             	pushl  0x18(%ebp)
  801648:	ff d7                	call   *%edi
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	eb 03                	jmp    801652 <printnum+0x78>
  80164f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801652:	83 eb 01             	sub    $0x1,%ebx
  801655:	85 db                	test   %ebx,%ebx
  801657:	7f e8                	jg     801641 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801659:	83 ec 08             	sub    $0x8,%esp
  80165c:	56                   	push   %esi
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	ff 75 e4             	pushl  -0x1c(%ebp)
  801663:	ff 75 e0             	pushl  -0x20(%ebp)
  801666:	ff 75 dc             	pushl  -0x24(%ebp)
  801669:	ff 75 d8             	pushl  -0x28(%ebp)
  80166c:	e8 8f 0a 00 00       	call   802100 <__umoddi3>
  801671:	83 c4 14             	add    $0x14,%esp
  801674:	0f be 80 ef 23 80 00 	movsbl 0x8023ef(%eax),%eax
  80167b:	50                   	push   %eax
  80167c:	ff d7                	call   *%edi
}
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801684:	5b                   	pop    %ebx
  801685:	5e                   	pop    %esi
  801686:	5f                   	pop    %edi
  801687:	5d                   	pop    %ebp
  801688:	c3                   	ret    

00801689 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801689:	55                   	push   %ebp
  80168a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80168c:	83 fa 01             	cmp    $0x1,%edx
  80168f:	7e 0e                	jle    80169f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801691:	8b 10                	mov    (%eax),%edx
  801693:	8d 4a 08             	lea    0x8(%edx),%ecx
  801696:	89 08                	mov    %ecx,(%eax)
  801698:	8b 02                	mov    (%edx),%eax
  80169a:	8b 52 04             	mov    0x4(%edx),%edx
  80169d:	eb 22                	jmp    8016c1 <getuint+0x38>
	else if (lflag)
  80169f:	85 d2                	test   %edx,%edx
  8016a1:	74 10                	je     8016b3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8016a3:	8b 10                	mov    (%eax),%edx
  8016a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016a8:	89 08                	mov    %ecx,(%eax)
  8016aa:	8b 02                	mov    (%edx),%eax
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	eb 0e                	jmp    8016c1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8016b3:	8b 10                	mov    (%eax),%edx
  8016b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8016b8:	89 08                	mov    %ecx,(%eax)
  8016ba:	8b 02                	mov    (%edx),%eax
  8016bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016cd:	8b 10                	mov    (%eax),%edx
  8016cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8016d2:	73 0a                	jae    8016de <sprintputch+0x1b>
		*b->buf++ = ch;
  8016d4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016d7:	89 08                	mov    %ecx,(%eax)
  8016d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dc:	88 02                	mov    %al,(%edx)
}
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    

008016e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016e9:	50                   	push   %eax
  8016ea:	ff 75 10             	pushl  0x10(%ebp)
  8016ed:	ff 75 0c             	pushl  0xc(%ebp)
  8016f0:	ff 75 08             	pushl  0x8(%ebp)
  8016f3:	e8 05 00 00 00       	call   8016fd <vprintfmt>
	va_end(ap);
}
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    

008016fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	57                   	push   %edi
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	83 ec 2c             	sub    $0x2c,%esp
  801706:	8b 75 08             	mov    0x8(%ebp),%esi
  801709:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80170c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80170f:	eb 12                	jmp    801723 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801711:	85 c0                	test   %eax,%eax
  801713:	0f 84 89 03 00 00    	je     801aa2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	53                   	push   %ebx
  80171d:	50                   	push   %eax
  80171e:	ff d6                	call   *%esi
  801720:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801723:	83 c7 01             	add    $0x1,%edi
  801726:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80172a:	83 f8 25             	cmp    $0x25,%eax
  80172d:	75 e2                	jne    801711 <vprintfmt+0x14>
  80172f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801733:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80173a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801741:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801748:	ba 00 00 00 00       	mov    $0x0,%edx
  80174d:	eb 07                	jmp    801756 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801752:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801756:	8d 47 01             	lea    0x1(%edi),%eax
  801759:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80175c:	0f b6 07             	movzbl (%edi),%eax
  80175f:	0f b6 c8             	movzbl %al,%ecx
  801762:	83 e8 23             	sub    $0x23,%eax
  801765:	3c 55                	cmp    $0x55,%al
  801767:	0f 87 1a 03 00 00    	ja     801a87 <vprintfmt+0x38a>
  80176d:	0f b6 c0             	movzbl %al,%eax
  801770:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  801777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80177a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80177e:	eb d6                	jmp    801756 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801780:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801783:	b8 00 00 00 00       	mov    $0x0,%eax
  801788:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80178b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80178e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801792:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801795:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801798:	83 fa 09             	cmp    $0x9,%edx
  80179b:	77 39                	ja     8017d6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80179d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8017a0:	eb e9                	jmp    80178b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8017a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a5:	8d 48 04             	lea    0x4(%eax),%ecx
  8017a8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8017ab:	8b 00                	mov    (%eax),%eax
  8017ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017b3:	eb 27                	jmp    8017dc <vprintfmt+0xdf>
  8017b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017bf:	0f 49 c8             	cmovns %eax,%ecx
  8017c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c8:	eb 8c                	jmp    801756 <vprintfmt+0x59>
  8017ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017cd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017d4:	eb 80                	jmp    801756 <vprintfmt+0x59>
  8017d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017d9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017e0:	0f 89 70 ff ff ff    	jns    801756 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ec:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017f3:	e9 5e ff ff ff       	jmp    801756 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017f8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017fe:	e9 53 ff ff ff       	jmp    801756 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801803:	8b 45 14             	mov    0x14(%ebp),%eax
  801806:	8d 50 04             	lea    0x4(%eax),%edx
  801809:	89 55 14             	mov    %edx,0x14(%ebp)
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	53                   	push   %ebx
  801810:	ff 30                	pushl  (%eax)
  801812:	ff d6                	call   *%esi
			break;
  801814:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801817:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80181a:	e9 04 ff ff ff       	jmp    801723 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80181f:	8b 45 14             	mov    0x14(%ebp),%eax
  801822:	8d 50 04             	lea    0x4(%eax),%edx
  801825:	89 55 14             	mov    %edx,0x14(%ebp)
  801828:	8b 00                	mov    (%eax),%eax
  80182a:	99                   	cltd   
  80182b:	31 d0                	xor    %edx,%eax
  80182d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80182f:	83 f8 0f             	cmp    $0xf,%eax
  801832:	7f 0b                	jg     80183f <vprintfmt+0x142>
  801834:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80183b:	85 d2                	test   %edx,%edx
  80183d:	75 18                	jne    801857 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80183f:	50                   	push   %eax
  801840:	68 07 24 80 00       	push   $0x802407
  801845:	53                   	push   %ebx
  801846:	56                   	push   %esi
  801847:	e8 94 fe ff ff       	call   8016e0 <printfmt>
  80184c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801852:	e9 cc fe ff ff       	jmp    801723 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801857:	52                   	push   %edx
  801858:	68 46 23 80 00       	push   $0x802346
  80185d:	53                   	push   %ebx
  80185e:	56                   	push   %esi
  80185f:	e8 7c fe ff ff       	call   8016e0 <printfmt>
  801864:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801867:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80186a:	e9 b4 fe ff ff       	jmp    801723 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80186f:	8b 45 14             	mov    0x14(%ebp),%eax
  801872:	8d 50 04             	lea    0x4(%eax),%edx
  801875:	89 55 14             	mov    %edx,0x14(%ebp)
  801878:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80187a:	85 ff                	test   %edi,%edi
  80187c:	b8 00 24 80 00       	mov    $0x802400,%eax
  801881:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801884:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801888:	0f 8e 94 00 00 00    	jle    801922 <vprintfmt+0x225>
  80188e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801892:	0f 84 98 00 00 00    	je     801930 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801898:	83 ec 08             	sub    $0x8,%esp
  80189b:	ff 75 d0             	pushl  -0x30(%ebp)
  80189e:	57                   	push   %edi
  80189f:	e8 86 02 00 00       	call   801b2a <strnlen>
  8018a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018a7:	29 c1                	sub    %eax,%ecx
  8018a9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8018ac:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018af:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018b9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018bb:	eb 0f                	jmp    8018cc <vprintfmt+0x1cf>
					putch(padc, putdat);
  8018bd:	83 ec 08             	sub    $0x8,%esp
  8018c0:	53                   	push   %ebx
  8018c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c6:	83 ef 01             	sub    $0x1,%edi
  8018c9:	83 c4 10             	add    $0x10,%esp
  8018cc:	85 ff                	test   %edi,%edi
  8018ce:	7f ed                	jg     8018bd <vprintfmt+0x1c0>
  8018d0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018d3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8018d6:	85 c9                	test   %ecx,%ecx
  8018d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018dd:	0f 49 c1             	cmovns %ecx,%eax
  8018e0:	29 c1                	sub    %eax,%ecx
  8018e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018eb:	89 cb                	mov    %ecx,%ebx
  8018ed:	eb 4d                	jmp    80193c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018f3:	74 1b                	je     801910 <vprintfmt+0x213>
  8018f5:	0f be c0             	movsbl %al,%eax
  8018f8:	83 e8 20             	sub    $0x20,%eax
  8018fb:	83 f8 5e             	cmp    $0x5e,%eax
  8018fe:	76 10                	jbe    801910 <vprintfmt+0x213>
					putch('?', putdat);
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	ff 75 0c             	pushl  0xc(%ebp)
  801906:	6a 3f                	push   $0x3f
  801908:	ff 55 08             	call   *0x8(%ebp)
  80190b:	83 c4 10             	add    $0x10,%esp
  80190e:	eb 0d                	jmp    80191d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801910:	83 ec 08             	sub    $0x8,%esp
  801913:	ff 75 0c             	pushl  0xc(%ebp)
  801916:	52                   	push   %edx
  801917:	ff 55 08             	call   *0x8(%ebp)
  80191a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80191d:	83 eb 01             	sub    $0x1,%ebx
  801920:	eb 1a                	jmp    80193c <vprintfmt+0x23f>
  801922:	89 75 08             	mov    %esi,0x8(%ebp)
  801925:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801928:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80192b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80192e:	eb 0c                	jmp    80193c <vprintfmt+0x23f>
  801930:	89 75 08             	mov    %esi,0x8(%ebp)
  801933:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801936:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801939:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80193c:	83 c7 01             	add    $0x1,%edi
  80193f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801943:	0f be d0             	movsbl %al,%edx
  801946:	85 d2                	test   %edx,%edx
  801948:	74 23                	je     80196d <vprintfmt+0x270>
  80194a:	85 f6                	test   %esi,%esi
  80194c:	78 a1                	js     8018ef <vprintfmt+0x1f2>
  80194e:	83 ee 01             	sub    $0x1,%esi
  801951:	79 9c                	jns    8018ef <vprintfmt+0x1f2>
  801953:	89 df                	mov    %ebx,%edi
  801955:	8b 75 08             	mov    0x8(%ebp),%esi
  801958:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80195b:	eb 18                	jmp    801975 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80195d:	83 ec 08             	sub    $0x8,%esp
  801960:	53                   	push   %ebx
  801961:	6a 20                	push   $0x20
  801963:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801965:	83 ef 01             	sub    $0x1,%edi
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	eb 08                	jmp    801975 <vprintfmt+0x278>
  80196d:	89 df                	mov    %ebx,%edi
  80196f:	8b 75 08             	mov    0x8(%ebp),%esi
  801972:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801975:	85 ff                	test   %edi,%edi
  801977:	7f e4                	jg     80195d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801979:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80197c:	e9 a2 fd ff ff       	jmp    801723 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801981:	83 fa 01             	cmp    $0x1,%edx
  801984:	7e 16                	jle    80199c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801986:	8b 45 14             	mov    0x14(%ebp),%eax
  801989:	8d 50 08             	lea    0x8(%eax),%edx
  80198c:	89 55 14             	mov    %edx,0x14(%ebp)
  80198f:	8b 50 04             	mov    0x4(%eax),%edx
  801992:	8b 00                	mov    (%eax),%eax
  801994:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801997:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80199a:	eb 32                	jmp    8019ce <vprintfmt+0x2d1>
	else if (lflag)
  80199c:	85 d2                	test   %edx,%edx
  80199e:	74 18                	je     8019b8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8019a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a3:	8d 50 04             	lea    0x4(%eax),%edx
  8019a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a9:	8b 00                	mov    (%eax),%eax
  8019ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ae:	89 c1                	mov    %eax,%ecx
  8019b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019b6:	eb 16                	jmp    8019ce <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8019b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bb:	8d 50 04             	lea    0x4(%eax),%edx
  8019be:	89 55 14             	mov    %edx,0x14(%ebp)
  8019c1:	8b 00                	mov    (%eax),%eax
  8019c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c6:	89 c1                	mov    %eax,%ecx
  8019c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8019cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019d1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019d9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019dd:	79 74                	jns    801a53 <vprintfmt+0x356>
				putch('-', putdat);
  8019df:	83 ec 08             	sub    $0x8,%esp
  8019e2:	53                   	push   %ebx
  8019e3:	6a 2d                	push   $0x2d
  8019e5:	ff d6                	call   *%esi
				num = -(long long) num;
  8019e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8019ea:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8019ed:	f7 d8                	neg    %eax
  8019ef:	83 d2 00             	adc    $0x0,%edx
  8019f2:	f7 da                	neg    %edx
  8019f4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019fc:	eb 55                	jmp    801a53 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019fe:	8d 45 14             	lea    0x14(%ebp),%eax
  801a01:	e8 83 fc ff ff       	call   801689 <getuint>
			base = 10;
  801a06:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801a0b:	eb 46                	jmp    801a53 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801a0d:	8d 45 14             	lea    0x14(%ebp),%eax
  801a10:	e8 74 fc ff ff       	call   801689 <getuint>
                        base = 8;
  801a15:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801a1a:	eb 37                	jmp    801a53 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	53                   	push   %ebx
  801a20:	6a 30                	push   $0x30
  801a22:	ff d6                	call   *%esi
			putch('x', putdat);
  801a24:	83 c4 08             	add    $0x8,%esp
  801a27:	53                   	push   %ebx
  801a28:	6a 78                	push   $0x78
  801a2a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a2c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2f:	8d 50 04             	lea    0x4(%eax),%edx
  801a32:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801a35:	8b 00                	mov    (%eax),%eax
  801a37:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a3c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801a3f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801a44:	eb 0d                	jmp    801a53 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801a46:	8d 45 14             	lea    0x14(%ebp),%eax
  801a49:	e8 3b fc ff ff       	call   801689 <getuint>
			base = 16;
  801a4e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a53:	83 ec 0c             	sub    $0xc,%esp
  801a56:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a5a:	57                   	push   %edi
  801a5b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5e:	51                   	push   %ecx
  801a5f:	52                   	push   %edx
  801a60:	50                   	push   %eax
  801a61:	89 da                	mov    %ebx,%edx
  801a63:	89 f0                	mov    %esi,%eax
  801a65:	e8 70 fb ff ff       	call   8015da <printnum>
			break;
  801a6a:	83 c4 20             	add    $0x20,%esp
  801a6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a70:	e9 ae fc ff ff       	jmp    801723 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	53                   	push   %ebx
  801a79:	51                   	push   %ecx
  801a7a:	ff d6                	call   *%esi
			break;
  801a7c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a82:	e9 9c fc ff ff       	jmp    801723 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a87:	83 ec 08             	sub    $0x8,%esp
  801a8a:	53                   	push   %ebx
  801a8b:	6a 25                	push   $0x25
  801a8d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	eb 03                	jmp    801a97 <vprintfmt+0x39a>
  801a94:	83 ef 01             	sub    $0x1,%edi
  801a97:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a9b:	75 f7                	jne    801a94 <vprintfmt+0x397>
  801a9d:	e9 81 fc ff ff       	jmp    801723 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801aa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa5:	5b                   	pop    %ebx
  801aa6:	5e                   	pop    %esi
  801aa7:	5f                   	pop    %edi
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	83 ec 18             	sub    $0x18,%esp
  801ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ab6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ab9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801abd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ac0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	74 26                	je     801af1 <vsnprintf+0x47>
  801acb:	85 d2                	test   %edx,%edx
  801acd:	7e 22                	jle    801af1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801acf:	ff 75 14             	pushl  0x14(%ebp)
  801ad2:	ff 75 10             	pushl  0x10(%ebp)
  801ad5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ad8:	50                   	push   %eax
  801ad9:	68 c3 16 80 00       	push   $0x8016c3
  801ade:	e8 1a fc ff ff       	call   8016fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ae3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ae6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	eb 05                	jmp    801af6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801af1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801af6:	c9                   	leave  
  801af7:	c3                   	ret    

00801af8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801af8:	55                   	push   %ebp
  801af9:	89 e5                	mov    %esp,%ebp
  801afb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801afe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b01:	50                   	push   %eax
  801b02:	ff 75 10             	pushl  0x10(%ebp)
  801b05:	ff 75 0c             	pushl  0xc(%ebp)
  801b08:	ff 75 08             	pushl  0x8(%ebp)
  801b0b:	e8 9a ff ff ff       	call   801aaa <vsnprintf>
	va_end(ap);

	return rc;
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1d:	eb 03                	jmp    801b22 <strlen+0x10>
		n++;
  801b1f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b22:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b26:	75 f7                	jne    801b1f <strlen+0xd>
		n++;
	return n;
}
  801b28:	5d                   	pop    %ebp
  801b29:	c3                   	ret    

00801b2a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b30:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b33:	ba 00 00 00 00       	mov    $0x0,%edx
  801b38:	eb 03                	jmp    801b3d <strnlen+0x13>
		n++;
  801b3a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b3d:	39 c2                	cmp    %eax,%edx
  801b3f:	74 08                	je     801b49 <strnlen+0x1f>
  801b41:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801b45:	75 f3                	jne    801b3a <strnlen+0x10>
  801b47:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	53                   	push   %ebx
  801b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b55:	89 c2                	mov    %eax,%edx
  801b57:	83 c2 01             	add    $0x1,%edx
  801b5a:	83 c1 01             	add    $0x1,%ecx
  801b5d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801b61:	88 5a ff             	mov    %bl,-0x1(%edx)
  801b64:	84 db                	test   %bl,%bl
  801b66:	75 ef                	jne    801b57 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801b68:	5b                   	pop    %ebx
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    

00801b6b <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	53                   	push   %ebx
  801b6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b72:	53                   	push   %ebx
  801b73:	e8 9a ff ff ff       	call   801b12 <strlen>
  801b78:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801b7b:	ff 75 0c             	pushl  0xc(%ebp)
  801b7e:	01 d8                	add    %ebx,%eax
  801b80:	50                   	push   %eax
  801b81:	e8 c5 ff ff ff       	call   801b4b <strcpy>
	return dst;
}
  801b86:	89 d8                	mov    %ebx,%eax
  801b88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	56                   	push   %esi
  801b91:	53                   	push   %ebx
  801b92:	8b 75 08             	mov    0x8(%ebp),%esi
  801b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b98:	89 f3                	mov    %esi,%ebx
  801b9a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b9d:	89 f2                	mov    %esi,%edx
  801b9f:	eb 0f                	jmp    801bb0 <strncpy+0x23>
		*dst++ = *src;
  801ba1:	83 c2 01             	add    $0x1,%edx
  801ba4:	0f b6 01             	movzbl (%ecx),%eax
  801ba7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801baa:	80 39 01             	cmpb   $0x1,(%ecx)
  801bad:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bb0:	39 da                	cmp    %ebx,%edx
  801bb2:	75 ed                	jne    801ba1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bb4:	89 f0                	mov    %esi,%eax
  801bb6:	5b                   	pop    %ebx
  801bb7:	5e                   	pop    %esi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	56                   	push   %esi
  801bbe:	53                   	push   %ebx
  801bbf:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc5:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bca:	85 d2                	test   %edx,%edx
  801bcc:	74 21                	je     801bef <strlcpy+0x35>
  801bce:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bd2:	89 f2                	mov    %esi,%edx
  801bd4:	eb 09                	jmp    801bdf <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bd6:	83 c2 01             	add    $0x1,%edx
  801bd9:	83 c1 01             	add    $0x1,%ecx
  801bdc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801bdf:	39 c2                	cmp    %eax,%edx
  801be1:	74 09                	je     801bec <strlcpy+0x32>
  801be3:	0f b6 19             	movzbl (%ecx),%ebx
  801be6:	84 db                	test   %bl,%bl
  801be8:	75 ec                	jne    801bd6 <strlcpy+0x1c>
  801bea:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801bec:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801bef:	29 f0                	sub    %esi,%eax
}
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bfe:	eb 06                	jmp    801c06 <strcmp+0x11>
		p++, q++;
  801c00:	83 c1 01             	add    $0x1,%ecx
  801c03:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c06:	0f b6 01             	movzbl (%ecx),%eax
  801c09:	84 c0                	test   %al,%al
  801c0b:	74 04                	je     801c11 <strcmp+0x1c>
  801c0d:	3a 02                	cmp    (%edx),%al
  801c0f:	74 ef                	je     801c00 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c11:	0f b6 c0             	movzbl %al,%eax
  801c14:	0f b6 12             	movzbl (%edx),%edx
  801c17:	29 d0                	sub    %edx,%eax
}
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	53                   	push   %ebx
  801c1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c22:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c25:	89 c3                	mov    %eax,%ebx
  801c27:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c2a:	eb 06                	jmp    801c32 <strncmp+0x17>
		n--, p++, q++;
  801c2c:	83 c0 01             	add    $0x1,%eax
  801c2f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c32:	39 d8                	cmp    %ebx,%eax
  801c34:	74 15                	je     801c4b <strncmp+0x30>
  801c36:	0f b6 08             	movzbl (%eax),%ecx
  801c39:	84 c9                	test   %cl,%cl
  801c3b:	74 04                	je     801c41 <strncmp+0x26>
  801c3d:	3a 0a                	cmp    (%edx),%cl
  801c3f:	74 eb                	je     801c2c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c41:	0f b6 00             	movzbl (%eax),%eax
  801c44:	0f b6 12             	movzbl (%edx),%edx
  801c47:	29 d0                	sub    %edx,%eax
  801c49:	eb 05                	jmp    801c50 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801c4b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c50:	5b                   	pop    %ebx
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    

00801c53 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
  801c59:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c5d:	eb 07                	jmp    801c66 <strchr+0x13>
		if (*s == c)
  801c5f:	38 ca                	cmp    %cl,%dl
  801c61:	74 0f                	je     801c72 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c63:	83 c0 01             	add    $0x1,%eax
  801c66:	0f b6 10             	movzbl (%eax),%edx
  801c69:	84 d2                	test   %dl,%dl
  801c6b:	75 f2                	jne    801c5f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801c6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    

00801c74 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c7e:	eb 03                	jmp    801c83 <strfind+0xf>
  801c80:	83 c0 01             	add    $0x1,%eax
  801c83:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801c86:	38 ca                	cmp    %cl,%dl
  801c88:	74 04                	je     801c8e <strfind+0x1a>
  801c8a:	84 d2                	test   %dl,%dl
  801c8c:	75 f2                	jne    801c80 <strfind+0xc>
			break;
	return (char *) s;
}
  801c8e:	5d                   	pop    %ebp
  801c8f:	c3                   	ret    

00801c90 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	57                   	push   %edi
  801c94:	56                   	push   %esi
  801c95:	53                   	push   %ebx
  801c96:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c99:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c9c:	85 c9                	test   %ecx,%ecx
  801c9e:	74 36                	je     801cd6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ca0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ca6:	75 28                	jne    801cd0 <memset+0x40>
  801ca8:	f6 c1 03             	test   $0x3,%cl
  801cab:	75 23                	jne    801cd0 <memset+0x40>
		c &= 0xFF;
  801cad:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cb1:	89 d3                	mov    %edx,%ebx
  801cb3:	c1 e3 08             	shl    $0x8,%ebx
  801cb6:	89 d6                	mov    %edx,%esi
  801cb8:	c1 e6 18             	shl    $0x18,%esi
  801cbb:	89 d0                	mov    %edx,%eax
  801cbd:	c1 e0 10             	shl    $0x10,%eax
  801cc0:	09 f0                	or     %esi,%eax
  801cc2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	09 d0                	or     %edx,%eax
  801cc8:	c1 e9 02             	shr    $0x2,%ecx
  801ccb:	fc                   	cld    
  801ccc:	f3 ab                	rep stos %eax,%es:(%edi)
  801cce:	eb 06                	jmp    801cd6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd3:	fc                   	cld    
  801cd4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cd6:	89 f8                	mov    %edi,%eax
  801cd8:	5b                   	pop    %ebx
  801cd9:	5e                   	pop    %esi
  801cda:	5f                   	pop    %edi
  801cdb:	5d                   	pop    %ebp
  801cdc:	c3                   	ret    

00801cdd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	57                   	push   %edi
  801ce1:	56                   	push   %esi
  801ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ce8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ceb:	39 c6                	cmp    %eax,%esi
  801ced:	73 35                	jae    801d24 <memmove+0x47>
  801cef:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf2:	39 d0                	cmp    %edx,%eax
  801cf4:	73 2e                	jae    801d24 <memmove+0x47>
		s += n;
		d += n;
  801cf6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf9:	89 d6                	mov    %edx,%esi
  801cfb:	09 fe                	or     %edi,%esi
  801cfd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d03:	75 13                	jne    801d18 <memmove+0x3b>
  801d05:	f6 c1 03             	test   $0x3,%cl
  801d08:	75 0e                	jne    801d18 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d0a:	83 ef 04             	sub    $0x4,%edi
  801d0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d10:	c1 e9 02             	shr    $0x2,%ecx
  801d13:	fd                   	std    
  801d14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d16:	eb 09                	jmp    801d21 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d18:	83 ef 01             	sub    $0x1,%edi
  801d1b:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d1e:	fd                   	std    
  801d1f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d21:	fc                   	cld    
  801d22:	eb 1d                	jmp    801d41 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d24:	89 f2                	mov    %esi,%edx
  801d26:	09 c2                	or     %eax,%edx
  801d28:	f6 c2 03             	test   $0x3,%dl
  801d2b:	75 0f                	jne    801d3c <memmove+0x5f>
  801d2d:	f6 c1 03             	test   $0x3,%cl
  801d30:	75 0a                	jne    801d3c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d32:	c1 e9 02             	shr    $0x2,%ecx
  801d35:	89 c7                	mov    %eax,%edi
  801d37:	fc                   	cld    
  801d38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d3a:	eb 05                	jmp    801d41 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d3c:	89 c7                	mov    %eax,%edi
  801d3e:	fc                   	cld    
  801d3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d41:	5e                   	pop    %esi
  801d42:	5f                   	pop    %edi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    

00801d45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801d48:	ff 75 10             	pushl  0x10(%ebp)
  801d4b:	ff 75 0c             	pushl  0xc(%ebp)
  801d4e:	ff 75 08             	pushl  0x8(%ebp)
  801d51:	e8 87 ff ff ff       	call   801cdd <memmove>
}
  801d56:	c9                   	leave  
  801d57:	c3                   	ret    

00801d58 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	56                   	push   %esi
  801d5c:	53                   	push   %ebx
  801d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d60:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d63:	89 c6                	mov    %eax,%esi
  801d65:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d68:	eb 1a                	jmp    801d84 <memcmp+0x2c>
		if (*s1 != *s2)
  801d6a:	0f b6 08             	movzbl (%eax),%ecx
  801d6d:	0f b6 1a             	movzbl (%edx),%ebx
  801d70:	38 d9                	cmp    %bl,%cl
  801d72:	74 0a                	je     801d7e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801d74:	0f b6 c1             	movzbl %cl,%eax
  801d77:	0f b6 db             	movzbl %bl,%ebx
  801d7a:	29 d8                	sub    %ebx,%eax
  801d7c:	eb 0f                	jmp    801d8d <memcmp+0x35>
		s1++, s2++;
  801d7e:	83 c0 01             	add    $0x1,%eax
  801d81:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d84:	39 f0                	cmp    %esi,%eax
  801d86:	75 e2                	jne    801d6a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801d88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5d                   	pop    %ebp
  801d90:	c3                   	ret    

00801d91 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	53                   	push   %ebx
  801d95:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d98:	89 c1                	mov    %eax,%ecx
  801d9a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801d9d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da1:	eb 0a                	jmp    801dad <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da3:	0f b6 10             	movzbl (%eax),%edx
  801da6:	39 da                	cmp    %ebx,%edx
  801da8:	74 07                	je     801db1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801daa:	83 c0 01             	add    $0x1,%eax
  801dad:	39 c8                	cmp    %ecx,%eax
  801daf:	72 f2                	jb     801da3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801db1:	5b                   	pop    %ebx
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    

00801db4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	57                   	push   %edi
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc0:	eb 03                	jmp    801dc5 <strtol+0x11>
		s++;
  801dc2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc5:	0f b6 01             	movzbl (%ecx),%eax
  801dc8:	3c 20                	cmp    $0x20,%al
  801dca:	74 f6                	je     801dc2 <strtol+0xe>
  801dcc:	3c 09                	cmp    $0x9,%al
  801dce:	74 f2                	je     801dc2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dd0:	3c 2b                	cmp    $0x2b,%al
  801dd2:	75 0a                	jne    801dde <strtol+0x2a>
		s++;
  801dd4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801dd7:	bf 00 00 00 00       	mov    $0x0,%edi
  801ddc:	eb 11                	jmp    801def <strtol+0x3b>
  801dde:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801de3:	3c 2d                	cmp    $0x2d,%al
  801de5:	75 08                	jne    801def <strtol+0x3b>
		s++, neg = 1;
  801de7:	83 c1 01             	add    $0x1,%ecx
  801dea:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801def:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df5:	75 15                	jne    801e0c <strtol+0x58>
  801df7:	80 39 30             	cmpb   $0x30,(%ecx)
  801dfa:	75 10                	jne    801e0c <strtol+0x58>
  801dfc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e00:	75 7c                	jne    801e7e <strtol+0xca>
		s += 2, base = 16;
  801e02:	83 c1 02             	add    $0x2,%ecx
  801e05:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e0a:	eb 16                	jmp    801e22 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e0c:	85 db                	test   %ebx,%ebx
  801e0e:	75 12                	jne    801e22 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e10:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e15:	80 39 30             	cmpb   $0x30,(%ecx)
  801e18:	75 08                	jne    801e22 <strtol+0x6e>
		s++, base = 8;
  801e1a:	83 c1 01             	add    $0x1,%ecx
  801e1d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e22:	b8 00 00 00 00       	mov    $0x0,%eax
  801e27:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e2a:	0f b6 11             	movzbl (%ecx),%edx
  801e2d:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e30:	89 f3                	mov    %esi,%ebx
  801e32:	80 fb 09             	cmp    $0x9,%bl
  801e35:	77 08                	ja     801e3f <strtol+0x8b>
			dig = *s - '0';
  801e37:	0f be d2             	movsbl %dl,%edx
  801e3a:	83 ea 30             	sub    $0x30,%edx
  801e3d:	eb 22                	jmp    801e61 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801e3f:	8d 72 9f             	lea    -0x61(%edx),%esi
  801e42:	89 f3                	mov    %esi,%ebx
  801e44:	80 fb 19             	cmp    $0x19,%bl
  801e47:	77 08                	ja     801e51 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801e49:	0f be d2             	movsbl %dl,%edx
  801e4c:	83 ea 57             	sub    $0x57,%edx
  801e4f:	eb 10                	jmp    801e61 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801e51:	8d 72 bf             	lea    -0x41(%edx),%esi
  801e54:	89 f3                	mov    %esi,%ebx
  801e56:	80 fb 19             	cmp    $0x19,%bl
  801e59:	77 16                	ja     801e71 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801e5b:	0f be d2             	movsbl %dl,%edx
  801e5e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801e61:	3b 55 10             	cmp    0x10(%ebp),%edx
  801e64:	7d 0b                	jge    801e71 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801e66:	83 c1 01             	add    $0x1,%ecx
  801e69:	0f af 45 10          	imul   0x10(%ebp),%eax
  801e6d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801e6f:	eb b9                	jmp    801e2a <strtol+0x76>

	if (endptr)
  801e71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e75:	74 0d                	je     801e84 <strtol+0xd0>
		*endptr = (char *) s;
  801e77:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e7a:	89 0e                	mov    %ecx,(%esi)
  801e7c:	eb 06                	jmp    801e84 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e7e:	85 db                	test   %ebx,%ebx
  801e80:	74 98                	je     801e1a <strtol+0x66>
  801e82:	eb 9e                	jmp    801e22 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801e84:	89 c2                	mov    %eax,%edx
  801e86:	f7 da                	neg    %edx
  801e88:	85 ff                	test   %edi,%edi
  801e8a:	0f 45 c2             	cmovne %edx,%eax
}
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    

00801e92 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	8b 75 08             	mov    0x8(%ebp),%esi
  801e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  801ea0:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801ea2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  801ea7:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	50                   	push   %eax
  801eae:	e8 60 e4 ff ff       	call   800313 <sys_ipc_recv>

	if (r < 0) {
  801eb3:	83 c4 10             	add    $0x10,%esp
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	79 16                	jns    801ed0 <ipc_recv+0x3e>
		if (from_env_store)
  801eba:	85 f6                	test   %esi,%esi
  801ebc:	74 06                	je     801ec4 <ipc_recv+0x32>
			*from_env_store = 0;
  801ebe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  801ec4:	85 db                	test   %ebx,%ebx
  801ec6:	74 2c                	je     801ef4 <ipc_recv+0x62>
			*perm_store = 0;
  801ec8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ece:	eb 24                	jmp    801ef4 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  801ed0:	85 f6                	test   %esi,%esi
  801ed2:	74 0a                	je     801ede <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  801ed4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ed9:	8b 40 74             	mov    0x74(%eax),%eax
  801edc:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  801ede:	85 db                	test   %ebx,%ebx
  801ee0:	74 0a                	je     801eec <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  801ee2:	a1 08 40 80 00       	mov    0x804008,%eax
  801ee7:	8b 40 78             	mov    0x78(%eax),%eax
  801eea:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801eec:	a1 08 40 80 00       	mov    0x804008,%eax
  801ef1:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801ef4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef7:	5b                   	pop    %ebx
  801ef8:	5e                   	pop    %esi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    

00801efb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	57                   	push   %edi
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	83 ec 0c             	sub    $0xc,%esp
  801f04:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f07:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801f0d:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801f0f:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801f14:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  801f17:	ff 75 14             	pushl  0x14(%ebp)
  801f1a:	53                   	push   %ebx
  801f1b:	56                   	push   %esi
  801f1c:	57                   	push   %edi
  801f1d:	e8 ce e3 ff ff       	call   8002f0 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f28:	75 07                	jne    801f31 <ipc_send+0x36>
			sys_yield();
  801f2a:	e8 15 e2 ff ff       	call   800144 <sys_yield>
  801f2f:	eb e6                	jmp    801f17 <ipc_send+0x1c>
		} else if (r < 0) {
  801f31:	85 c0                	test   %eax,%eax
  801f33:	79 12                	jns    801f47 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801f35:	50                   	push   %eax
  801f36:	68 00 27 80 00       	push   $0x802700
  801f3b:	6a 51                	push   $0x51
  801f3d:	68 0d 27 80 00       	push   $0x80270d
  801f42:	e8 a6 f5 ff ff       	call   8014ed <_panic>
		}
	}
}
  801f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f55:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f5a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f5d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f63:	8b 52 50             	mov    0x50(%edx),%edx
  801f66:	39 ca                	cmp    %ecx,%edx
  801f68:	75 0d                	jne    801f77 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f6a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f6d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f72:	8b 40 48             	mov    0x48(%eax),%eax
  801f75:	eb 0f                	jmp    801f86 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f77:	83 c0 01             	add    $0x1,%eax
  801f7a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7f:	75 d9                	jne    801f5a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8e:	89 d0                	mov    %edx,%eax
  801f90:	c1 e8 16             	shr    $0x16,%eax
  801f93:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9f:	f6 c1 01             	test   $0x1,%cl
  801fa2:	74 1d                	je     801fc1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa4:	c1 ea 0c             	shr    $0xc,%edx
  801fa7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fae:	f6 c2 01             	test   $0x1,%dl
  801fb1:	74 0e                	je     801fc1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb3:	c1 ea 0c             	shr    $0xc,%edx
  801fb6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fbd:	ef 
  801fbe:	0f b7 c0             	movzwl %ax,%eax
}
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    
  801fc3:	66 90                	xchg   %ax,%ax
  801fc5:	66 90                	xchg   %ax,%ax
  801fc7:	66 90                	xchg   %ax,%ax
  801fc9:	66 90                	xchg   %ax,%ax
  801fcb:	66 90                	xchg   %ax,%ax
  801fcd:	66 90                	xchg   %ax,%ax
  801fcf:	90                   	nop

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
