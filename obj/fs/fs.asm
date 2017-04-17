
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 1a 19 00 00       	call   80194b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 e0 3b 80 00       	push   $0x803be0
  8000b7:	e8 c8 19 00 00       	call   801a84 <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 f7 3b 80 00       	push   $0x803bf7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 07 3c 80 00       	push   $0x803c07
  8000e0:	e8 c6 18 00 00       	call   8019ab <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 10 3c 80 00       	push   $0x803c10
  80010b:	68 1d 3c 80 00       	push   $0x803c1d
  800110:	6a 44                	push   $0x44
  800112:	68 07 3c 80 00       	push   $0x803c07
  800117:	e8 8f 18 00 00       	call   8019ab <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 10 3c 80 00       	push   $0x803c10
  8001cf:	68 1d 3c 80 00       	push   $0x803c1d
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 07 3c 80 00       	push   $0x803c07
  8001db:	e8 cb 17 00 00       	call   8019ab <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 34 3c 80 00       	push   $0x803c34
  80029f:	6a 27                	push   $0x27
  8002a1:	68 f0 3c 80 00       	push   $0x803cf0
  8002a6:	e8 00 17 00 00       	call   8019ab <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 64 3c 80 00       	push   $0x803c64
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 f0 3c 80 00       	push   $0x803cf0
  8002c6:	e8 e0 16 00 00       	call   8019ab <_panic>
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:

	addr = (void*) ROUNDDOWN(addr, PGSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if((r = sys_page_alloc(0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 07                	push   $0x7
  8002d6:	53                   	push   %ebx
  8002d7:	6a 00                	push   $0x0
  8002d9:	e8 2e 21 00 00       	call   80240c <sys_page_alloc>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 14                	jns    8002f9 <bc_pgfault+0x85>
		panic("sys alloc failed");
  8002e5:	83 ec 04             	sub    $0x4,%esp
  8002e8:	68 f8 3c 80 00       	push   $0x803cf8
  8002ed:	6a 36                	push   $0x36
  8002ef:	68 f0 3c 80 00       	push   $0x803cf0
  8002f4:	e8 b2 16 00 00       	call   8019ab <_panic>
		
	if ((r = ide_read(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  8002f9:	83 ec 04             	sub    $0x4,%esp
  8002fc:	6a 08                	push   $0x8
  8002fe:	53                   	push   %ebx
  8002ff:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800306:	50                   	push   %eax
  800307:	e8 e0 fd ff ff       	call   8000ec <ide_read>
  80030c:	83 c4 10             	add    $0x10,%esp
  80030f:	85 c0                	test   %eax,%eax
  800311:	79 14                	jns    800327 <bc_pgfault+0xb3>
		panic("ide read failed");
  800313:	83 ec 04             	sub    $0x4,%esp
  800316:	68 09 3d 80 00       	push   $0x803d09
  80031b:	6a 39                	push   $0x39
  80031d:	68 f0 3c 80 00       	push   $0x803cf0
  800322:	e8 84 16 00 00       	call   8019ab <_panic>
	

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800327:	89 d8                	mov    %ebx,%eax
  800329:	c1 e8 0c             	shr    $0xc,%eax
  80032c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	25 07 0e 00 00       	and    $0xe07,%eax
  80033b:	50                   	push   %eax
  80033c:	53                   	push   %ebx
  80033d:	6a 00                	push   $0x0
  80033f:	53                   	push   %ebx
  800340:	6a 00                	push   $0x0
  800342:	e8 08 21 00 00       	call   80244f <sys_page_map>
  800347:	83 c4 20             	add    $0x20,%esp
  80034a:	85 c0                	test   %eax,%eax
  80034c:	79 12                	jns    800360 <bc_pgfault+0xec>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034e:	50                   	push   %eax
  80034f:	68 88 3c 80 00       	push   $0x803c88
  800354:	6a 3f                	push   $0x3f
  800356:	68 f0 3c 80 00       	push   $0x803cf0
  80035b:	e8 4b 16 00 00       	call   8019ab <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800360:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  800367:	74 22                	je     80038b <bc_pgfault+0x117>
  800369:	83 ec 0c             	sub    $0xc,%esp
  80036c:	56                   	push   %esi
  80036d:	e8 5a 03 00 00       	call   8006cc <block_is_free>
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	84 c0                	test   %al,%al
  800377:	74 12                	je     80038b <bc_pgfault+0x117>
		panic("reading free block %08x\n", blockno);
  800379:	56                   	push   %esi
  80037a:	68 19 3d 80 00       	push   $0x803d19
  80037f:	6a 45                	push   $0x45
  800381:	68 f0 3c 80 00       	push   $0x803cf0
  800386:	e8 20 16 00 00       	call   8019ab <_panic>
}
  80038b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    

00800392 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	83 ec 08             	sub    $0x8,%esp
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80039b:	85 c0                	test   %eax,%eax
  80039d:	74 0f                	je     8003ae <diskaddr+0x1c>
  80039f:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8003a5:	85 d2                	test   %edx,%edx
  8003a7:	74 17                	je     8003c0 <diskaddr+0x2e>
  8003a9:	3b 42 04             	cmp    0x4(%edx),%eax
  8003ac:	72 12                	jb     8003c0 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003ae:	50                   	push   %eax
  8003af:	68 a8 3c 80 00       	push   $0x803ca8
  8003b4:	6a 09                	push   $0x9
  8003b6:	68 f0 3c 80 00       	push   $0x803cf0
  8003bb:	e8 eb 15 00 00       	call   8019ab <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003c0:	05 00 00 01 00       	add    $0x10000,%eax
  8003c5:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    

008003ca <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003d0:	89 d0                	mov    %edx,%eax
  8003d2:	c1 e8 16             	shr    $0x16,%eax
  8003d5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e1:	f6 c1 01             	test   $0x1,%cl
  8003e4:	74 0d                	je     8003f3 <va_is_mapped+0x29>
  8003e6:	c1 ea 0c             	shr    $0xc,%edx
  8003e9:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003f0:	83 e0 01             	and    $0x1,%eax
  8003f3:	83 e0 01             	and    $0x1,%eax
}
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	c1 e8 0c             	shr    $0xc,%eax
  800401:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800408:	c1 e8 06             	shr    $0x6,%eax
  80040b:	83 e0 01             	and    $0x1,%eax
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	56                   	push   %esi
  800414:	53                   	push   %ebx
  800415:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800418:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80041e:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800423:	76 12                	jbe    800437 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800425:	53                   	push   %ebx
  800426:	68 32 3d 80 00       	push   $0x803d32
  80042b:	6a 55                	push   $0x55
  80042d:	68 f0 3c 80 00       	push   $0x803cf0
  800432:	e8 74 15 00 00       	call   8019ab <_panic>

	// LAB 5: Your code here.
	
	addr = (void*) ROUNDDOWN(addr, PGSIZE);
  800437:	89 de                	mov    %ebx,%esi
  800439:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi


	int r;
	if (va_is_mapped(addr) && va_is_dirty(addr)) {
  80043f:	83 ec 0c             	sub    $0xc,%esp
  800442:	56                   	push   %esi
  800443:	e8 82 ff ff ff       	call   8003ca <va_is_mapped>
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	84 c0                	test   %al,%al
  80044d:	74 7e                	je     8004cd <flush_block+0xbd>
  80044f:	83 ec 0c             	sub    $0xc,%esp
  800452:	56                   	push   %esi
  800453:	e8 a0 ff ff ff       	call   8003f8 <va_is_dirty>
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	84 c0                	test   %al,%al
  80045d:	74 6e                	je     8004cd <flush_block+0xbd>
		
		if ((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  80045f:	83 ec 04             	sub    $0x4,%esp
  800462:	6a 08                	push   $0x8
  800464:	56                   	push   %esi
  800465:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  80046b:	c1 eb 0c             	shr    $0xc,%ebx
  80046e:	c1 e3 03             	shl    $0x3,%ebx
  800471:	53                   	push   %ebx
  800472:	e8 39 fd ff ff       	call   8001b0 <ide_write>
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	85 c0                	test   %eax,%eax
  80047c:	79 14                	jns    800492 <flush_block+0x82>
			panic("ide wite failed");
  80047e:	83 ec 04             	sub    $0x4,%esp
  800481:	68 4d 3d 80 00       	push   $0x803d4d
  800486:	6a 60                	push   $0x60
  800488:	68 f0 3c 80 00       	push   $0x803cf0
  80048d:	e8 19 15 00 00       	call   8019ab <_panic>
		
		if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800492:	89 f0                	mov    %esi,%eax
  800494:	c1 e8 0c             	shr    $0xc,%eax
  800497:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	25 07 0e 00 00       	and    $0xe07,%eax
  8004a6:	50                   	push   %eax
  8004a7:	56                   	push   %esi
  8004a8:	6a 00                	push   $0x0
  8004aa:	56                   	push   %esi
  8004ab:	6a 00                	push   $0x0
  8004ad:	e8 9d 1f 00 00       	call   80244f <sys_page_map>
  8004b2:	83 c4 20             	add    $0x20,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	79 14                	jns    8004cd <flush_block+0xbd>
			panic("sys page map failed");
  8004b9:	83 ec 04             	sub    $0x4,%esp
  8004bc:	68 5d 3d 80 00       	push   $0x803d5d
  8004c1:	6a 63                	push   $0x63
  8004c3:	68 f0 3c 80 00       	push   $0x803cf0
  8004c8:	e8 de 14 00 00       	call   8019ab <_panic>
	}
}
  8004cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d0:	5b                   	pop    %ebx
  8004d1:	5e                   	pop    %esi
  8004d2:	5d                   	pop    %ebp
  8004d3:	c3                   	ret    

008004d4 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004dd:	68 74 02 80 00       	push   $0x800274
  8004e2:	e8 35 21 00 00       	call   80261c <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004e7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004ee:	e8 9f fe ff ff       	call   800392 <diskaddr>
  8004f3:	83 c4 0c             	add    $0xc,%esp
  8004f6:	68 08 01 00 00       	push   $0x108
  8004fb:	50                   	push   %eax
  8004fc:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800502:	50                   	push   %eax
  800503:	e8 93 1c 00 00       	call   80219b <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800508:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80050f:	e8 7e fe ff ff       	call   800392 <diskaddr>
  800514:	83 c4 08             	add    $0x8,%esp
  800517:	68 71 3d 80 00       	push   $0x803d71
  80051c:	50                   	push   %eax
  80051d:	e8 e7 1a 00 00       	call   802009 <strcpy>
	flush_block(diskaddr(1));
  800522:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800529:	e8 64 fe ff ff       	call   800392 <diskaddr>
  80052e:	89 04 24             	mov    %eax,(%esp)
  800531:	e8 da fe ff ff       	call   800410 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800536:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80053d:	e8 50 fe ff ff       	call   800392 <diskaddr>
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	e8 80 fe ff ff       	call   8003ca <va_is_mapped>
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	84 c0                	test   %al,%al
  80054f:	75 16                	jne    800567 <bc_init+0x93>
  800551:	68 93 3d 80 00       	push   $0x803d93
  800556:	68 1d 3c 80 00       	push   $0x803c1d
  80055b:	6a 74                	push   $0x74
  80055d:	68 f0 3c 80 00       	push   $0x803cf0
  800562:	e8 44 14 00 00       	call   8019ab <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	6a 01                	push   $0x1
  80056c:	e8 21 fe ff ff       	call   800392 <diskaddr>
  800571:	89 04 24             	mov    %eax,(%esp)
  800574:	e8 7f fe ff ff       	call   8003f8 <va_is_dirty>
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	84 c0                	test   %al,%al
  80057e:	74 16                	je     800596 <bc_init+0xc2>
  800580:	68 78 3d 80 00       	push   $0x803d78
  800585:	68 1d 3c 80 00       	push   $0x803c1d
  80058a:	6a 75                	push   $0x75
  80058c:	68 f0 3c 80 00       	push   $0x803cf0
  800591:	e8 15 14 00 00       	call   8019ab <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800596:	83 ec 0c             	sub    $0xc,%esp
  800599:	6a 01                	push   $0x1
  80059b:	e8 f2 fd ff ff       	call   800392 <diskaddr>
  8005a0:	83 c4 08             	add    $0x8,%esp
  8005a3:	50                   	push   %eax
  8005a4:	6a 00                	push   $0x0
  8005a6:	e8 e6 1e 00 00       	call   802491 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b2:	e8 db fd ff ff       	call   800392 <diskaddr>
  8005b7:	89 04 24             	mov    %eax,(%esp)
  8005ba:	e8 0b fe ff ff       	call   8003ca <va_is_mapped>
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	84 c0                	test   %al,%al
  8005c4:	74 16                	je     8005dc <bc_init+0x108>
  8005c6:	68 92 3d 80 00       	push   $0x803d92
  8005cb:	68 1d 3c 80 00       	push   $0x803c1d
  8005d0:	6a 79                	push   $0x79
  8005d2:	68 f0 3c 80 00       	push   $0x803cf0
  8005d7:	e8 cf 13 00 00       	call   8019ab <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	6a 01                	push   $0x1
  8005e1:	e8 ac fd ff ff       	call   800392 <diskaddr>
  8005e6:	83 c4 08             	add    $0x8,%esp
  8005e9:	68 71 3d 80 00       	push   $0x803d71
  8005ee:	50                   	push   %eax
  8005ef:	e8 bf 1a 00 00       	call   8020b3 <strcmp>
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	74 16                	je     800611 <bc_init+0x13d>
  8005fb:	68 cc 3c 80 00       	push   $0x803ccc
  800600:	68 1d 3c 80 00       	push   $0x803c1d
  800605:	6a 7c                	push   $0x7c
  800607:	68 f0 3c 80 00       	push   $0x803cf0
  80060c:	e8 9a 13 00 00       	call   8019ab <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	6a 01                	push   $0x1
  800616:	e8 77 fd ff ff       	call   800392 <diskaddr>
  80061b:	83 c4 0c             	add    $0xc,%esp
  80061e:	68 08 01 00 00       	push   $0x108
  800623:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800629:	52                   	push   %edx
  80062a:	50                   	push   %eax
  80062b:	e8 6b 1b 00 00       	call   80219b <memmove>
	flush_block(diskaddr(1));
  800630:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800637:	e8 56 fd ff ff       	call   800392 <diskaddr>
  80063c:	89 04 24             	mov    %eax,(%esp)
  80063f:	e8 cc fd ff ff       	call   800410 <flush_block>

	cprintf("block cache is good\n");
  800644:	c7 04 24 ad 3d 80 00 	movl   $0x803dad,(%esp)
  80064b:	e8 34 14 00 00       	call   801a84 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800650:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800657:	e8 36 fd ff ff       	call   800392 <diskaddr>
  80065c:	83 c4 0c             	add    $0xc,%esp
  80065f:	68 08 01 00 00       	push   $0x108
  800664:	50                   	push   %eax
  800665:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80066b:	50                   	push   %eax
  80066c:	e8 2a 1b 00 00       	call   80219b <memmove>
}
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	c9                   	leave  
  800675:	c3                   	ret    

00800676 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80067c:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800681:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800687:	74 14                	je     80069d <check_super+0x27>
		panic("bad file system magic number");
  800689:	83 ec 04             	sub    $0x4,%esp
  80068c:	68 c2 3d 80 00       	push   $0x803dc2
  800691:	6a 0f                	push   $0xf
  800693:	68 df 3d 80 00       	push   $0x803ddf
  800698:	e8 0e 13 00 00       	call   8019ab <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80069d:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8006a4:	76 14                	jbe    8006ba <check_super+0x44>
		panic("file system is too large");
  8006a6:	83 ec 04             	sub    $0x4,%esp
  8006a9:	68 e7 3d 80 00       	push   $0x803de7
  8006ae:	6a 12                	push   $0x12
  8006b0:	68 df 3d 80 00       	push   $0x803ddf
  8006b5:	e8 f1 12 00 00       	call   8019ab <_panic>

	cprintf("superblock is good\n");
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	68 00 3e 80 00       	push   $0x803e00
  8006c2:	e8 bd 13 00 00       	call   801a84 <cprintf>
}
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	c9                   	leave  
  8006cb:	c3                   	ret    

008006cc <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	53                   	push   %ebx
  8006d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006d3:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8006d9:	85 d2                	test   %edx,%edx
  8006db:	74 24                	je     800701 <block_is_free+0x35>
		return 0;
  8006dd:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8006e2:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8006e5:	76 1f                	jbe    800706 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8006e7:	89 cb                	mov    %ecx,%ebx
  8006e9:	c1 eb 05             	shr    $0x5,%ebx
  8006ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8006f1:	d3 e0                	shl    %cl,%eax
  8006f3:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8006f9:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8006fc:	0f 95 c0             	setne  %al
  8006ff:	eb 05                	jmp    800706 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800701:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800706:	5b                   	pop    %ebx
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	53                   	push   %ebx
  80070d:	83 ec 04             	sub    $0x4,%esp
  800710:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800713:	85 c9                	test   %ecx,%ecx
  800715:	75 14                	jne    80072b <free_block+0x22>
		panic("attempt to free zero block");
  800717:	83 ec 04             	sub    $0x4,%esp
  80071a:	68 14 3e 80 00       	push   $0x803e14
  80071f:	6a 2d                	push   $0x2d
  800721:	68 df 3d 80 00       	push   $0x803ddf
  800726:	e8 80 12 00 00       	call   8019ab <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  80072b:	89 cb                	mov    %ecx,%ebx
  80072d:	c1 eb 05             	shr    $0x5,%ebx
  800730:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800736:	b8 01 00 00 00       	mov    $0x1,%eax
  80073b:	d3 e0                	shl    %cl,%eax
  80073d:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	56                   	push   %esi
  800749:	53                   	push   %ebx
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	if (!super)
  80074a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 0a                	je     80075d <alloc_block+0x18>
		panic("in alloc_block: super not initialized");

	
	int no;
	for (no = 1; no < super->s_nblocks; no++) {
  800753:	8b 70 04             	mov    0x4(%eax),%esi
  800756:	bb 01 00 00 00       	mov    $0x1,%ebx
  80075b:	eb 6c                	jmp    8007c9 <alloc_block+0x84>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	if (!super)
		panic("in alloc_block: super not initialized");
  80075d:	83 ec 04             	sub    $0x4,%esp
  800760:	68 b4 3e 80 00       	push   $0x803eb4
  800765:	6a 42                	push   $0x42
  800767:	68 df 3d 80 00       	push   $0x803ddf
  80076c:	e8 3a 12 00 00       	call   8019ab <_panic>

	
	int no;
	for (no = 1; no < super->s_nblocks; no++) {
		// If find a free block, mark it used and flush the bitmap block
		if(block_is_free(no)) {
  800771:	83 ec 0c             	sub    $0xc,%esp
  800774:	53                   	push   %ebx
  800775:	e8 52 ff ff ff       	call   8006cc <block_is_free>
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	84 c0                	test   %al,%al
  80077f:	74 45                	je     8007c6 <alloc_block+0x81>
			bitmap[no / 32] &= ~(1<<(no%32));
  800781:	8d 43 1f             	lea    0x1f(%ebx),%eax
  800784:	85 db                	test   %ebx,%ebx
  800786:	0f 49 c3             	cmovns %ebx,%eax
  800789:	c1 f8 05             	sar    $0x5,%eax
  80078c:	c1 e0 02             	shl    $0x2,%eax
  80078f:	89 c2                	mov    %eax,%edx
  800791:	03 15 08 a0 80 00    	add    0x80a008,%edx
  800797:	89 de                	mov    %ebx,%esi
  800799:	c1 fe 1f             	sar    $0x1f,%esi
  80079c:	c1 ee 1b             	shr    $0x1b,%esi
  80079f:	8d 0c 33             	lea    (%ebx,%esi,1),%ecx
  8007a2:	83 e1 1f             	and    $0x1f,%ecx
  8007a5:	29 f1                	sub    %esi,%ecx
  8007a7:	be fe ff ff ff       	mov    $0xfffffffe,%esi
  8007ac:	d3 c6                	rol    %cl,%esi
  8007ae:	21 32                	and    %esi,(%edx)
			flush_block(&bitmap[no/32]);
  8007b0:	83 ec 0c             	sub    $0xc,%esp
  8007b3:	03 05 08 a0 80 00    	add    0x80a008,%eax
  8007b9:	50                   	push   %eax
  8007ba:	e8 51 fc ff ff       	call   800410 <flush_block>
			return no;
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	89 d8                	mov    %ebx,%eax
  8007c4:	eb 0c                	jmp    8007d2 <alloc_block+0x8d>
	if (!super)
		panic("in alloc_block: super not initialized");

	
	int no;
	for (no = 1; no < super->s_nblocks; no++) {
  8007c6:	83 c3 01             	add    $0x1,%ebx
  8007c9:	39 de                	cmp    %ebx,%esi
  8007cb:	77 a4                	ja     800771 <alloc_block+0x2c>
			return no;
		}
	}

	// No block is free
	return -E_NO_DISK;
  8007cd:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8007d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	57                   	push   %edi
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	83 ec 1c             	sub    $0x1c,%esp
  8007e2:	8b 7d 08             	mov    0x8(%ebp),%edi
       // LAB 5: Your code here.
	
	if (filebno >= NDIRECT + NINDIRECT)
  8007e5:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8007eb:	77 76                	ja     800863 <file_block_walk+0x8a>
		return -E_INVAL;
	if (filebno < NDIRECT) {
  8007ed:	83 fa 09             	cmp    $0x9,%edx
  8007f0:	77 10                	ja     800802 <file_block_walk+0x29>
		*ppdiskbno = &(f->f_direct[filebno]);
  8007f2:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8007f9:	89 01                	mov    %eax,(%ecx)
		return 0;
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	eb 74                	jmp    800876 <file_block_walk+0x9d>
  800802:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800805:	89 d3                	mov    %edx,%ebx
  800807:	89 c6                	mov    %eax,%esi
	}
	if (f->f_indirect == 0) {
  800809:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  800810:	75 33                	jne    800845 <file_block_walk+0x6c>
		if (alloc) {
  800812:	89 f8                	mov    %edi,%eax
  800814:	84 c0                	test   %al,%al
  800816:	74 52                	je     80086a <file_block_walk+0x91>
			
			int new;
			if ((new = alloc_block()) < 0)
  800818:	e8 28 ff ff ff       	call   800745 <alloc_block>
  80081d:	89 c7                	mov    %eax,%edi
  80081f:	85 c0                	test   %eax,%eax
  800821:	78 4e                	js     800871 <file_block_walk+0x98>
				return -E_NO_DISK;

			
			memset(blockno_to_va(new), 0, BLKSIZE);
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	68 00 10 00 00       	push   $0x1000
  80082b:	6a 00                	push   $0x0
  80082d:	8d 80 00 00 01 00    	lea    0x10000(%eax),%eax
  800833:	c1 e0 0c             	shl    $0xc,%eax
  800836:	50                   	push   %eax
  800837:	e8 12 19 00 00       	call   80214e <memset>

			
			f->f_indirect = new;
  80083c:	89 be b0 00 00 00    	mov    %edi,0xb0(%esi)
  800842:	83 c4 10             	add    $0x10,%esp
			return -E_NOT_FOUND;
		}
	}

	uint32_t *indirblk = (uint32_t *) blockno_to_va(f->f_indirect);
	*ppdiskbno = &indirblk[filebno - NDIRECT];
  800845:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  80084b:	05 00 00 01 00       	add    $0x10000,%eax
  800850:	c1 e0 0c             	shl    $0xc,%eax
  800853:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800857:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80085a:	89 03                	mov    %eax,(%ebx)
	return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
  800861:	eb 13                	jmp    800876 <file_block_walk+0x9d>
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
	
	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800863:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800868:	eb 0c                	jmp    800876 <file_block_walk+0x9d>
			memset(blockno_to_va(new), 0, BLKSIZE);

			
			f->f_indirect = new;
		} else {
			return -E_NOT_FOUND;
  80086a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80086f:	eb 05                	jmp    800876 <file_block_walk+0x9d>
	if (f->f_indirect == 0) {
		if (alloc) {
			
			int new;
			if ((new = alloc_block()) < 0)
				return -E_NO_DISK;
  800871:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
	}

	uint32_t *indirblk = (uint32_t *) blockno_to_va(f->f_indirect);
	*ppdiskbno = &indirblk[filebno - NDIRECT];
	return 0;
}
  800876:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	5f                   	pop    %edi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800883:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800888:	8b 70 04             	mov    0x4(%eax),%esi
  80088b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800890:	eb 29                	jmp    8008bb <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  800892:	8d 43 02             	lea    0x2(%ebx),%eax
  800895:	50                   	push   %eax
  800896:	e8 31 fe ff ff       	call   8006cc <block_is_free>
  80089b:	83 c4 04             	add    $0x4,%esp
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 16                	je     8008b8 <check_bitmap+0x3a>
  8008a2:	68 2f 3e 80 00       	push   $0x803e2f
  8008a7:	68 1d 3c 80 00       	push   $0x803c1d
  8008ac:	6a 5e                	push   $0x5e
  8008ae:	68 df 3d 80 00       	push   $0x803ddf
  8008b3:	e8 f3 10 00 00       	call   8019ab <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8008b8:	83 c3 01             	add    $0x1,%ebx
  8008bb:	89 d8                	mov    %ebx,%eax
  8008bd:	c1 e0 0f             	shl    $0xf,%eax
  8008c0:	39 f0                	cmp    %esi,%eax
  8008c2:	72 ce                	jb     800892 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8008c4:	83 ec 0c             	sub    $0xc,%esp
  8008c7:	6a 00                	push   $0x0
  8008c9:	e8 fe fd ff ff       	call   8006cc <block_is_free>
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 16                	je     8008eb <check_bitmap+0x6d>
  8008d5:	68 43 3e 80 00       	push   $0x803e43
  8008da:	68 1d 3c 80 00       	push   $0x803c1d
  8008df:	6a 61                	push   $0x61
  8008e1:	68 df 3d 80 00       	push   $0x803ddf
  8008e6:	e8 c0 10 00 00       	call   8019ab <_panic>
	assert(!block_is_free(1));
  8008eb:	83 ec 0c             	sub    $0xc,%esp
  8008ee:	6a 01                	push   $0x1
  8008f0:	e8 d7 fd ff ff       	call   8006cc <block_is_free>
  8008f5:	83 c4 10             	add    $0x10,%esp
  8008f8:	84 c0                	test   %al,%al
  8008fa:	74 16                	je     800912 <check_bitmap+0x94>
  8008fc:	68 55 3e 80 00       	push   $0x803e55
  800901:	68 1d 3c 80 00       	push   $0x803c1d
  800906:	6a 62                	push   $0x62
  800908:	68 df 3d 80 00       	push   $0x803ddf
  80090d:	e8 99 10 00 00       	call   8019ab <_panic>

	cprintf("bitmap is good\n");
  800912:	83 ec 0c             	sub    $0xc,%esp
  800915:	68 67 3e 80 00       	push   $0x803e67
  80091a:	e8 65 11 00 00       	call   801a84 <cprintf>
}
  80091f:	83 c4 10             	add    $0x10,%esp
  800922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  80092f:	e8 2b f7 ff ff       	call   80005f <ide_probe_disk1>
  800934:	84 c0                	test   %al,%al
  800936:	74 0f                	je     800947 <fs_init+0x1e>
               ide_set_disk(1);
  800938:	83 ec 0c             	sub    $0xc,%esp
  80093b:	6a 01                	push   $0x1
  80093d:	e8 81 f7 ff ff       	call   8000c3 <ide_set_disk>
  800942:	83 c4 10             	add    $0x10,%esp
  800945:	eb 0d                	jmp    800954 <fs_init+0x2b>
       else
               ide_set_disk(0);
  800947:	83 ec 0c             	sub    $0xc,%esp
  80094a:	6a 00                	push   $0x0
  80094c:	e8 72 f7 ff ff       	call   8000c3 <ide_set_disk>
  800951:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800954:	e8 7b fb ff ff       	call   8004d4 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800959:	83 ec 0c             	sub    $0xc,%esp
  80095c:	6a 01                	push   $0x1
  80095e:	e8 2f fa ff ff       	call   800392 <diskaddr>
  800963:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800968:	e8 09 fd ff ff       	call   800676 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  80096d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800974:	e8 19 fa ff ff       	call   800392 <diskaddr>
  800979:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  80097e:	e8 fb fe ff ff       	call   80087e <check_bitmap>
	
}
  800983:	83 c4 10             	add    $0x10,%esp
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	53                   	push   %ebx
  80098c:	83 ec 20             	sub    $0x20,%esp
       // LAB 5: Your code here.
	// Retrieve the blockno_entry of the 'filebno'th block of file 'f'
	uint32_t *block_entry;
	int x;
	if ((x = file_block_walk(f, filebno, &block_entry, 1)) < 0) {
  80098f:	6a 01                	push   $0x1
  800991:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	e8 3a fe ff ff       	call   8007d9 <file_block_walk>
  80099f:	83 c4 10             	add    $0x10,%esp
  8009a2:	85 c0                	test   %eax,%eax
  8009a4:	78 52                	js     8009f8 <file_get_block+0x70>
		return x; // -E_INVAL or -E_NO_DISK
	}

	
	if (*block_entry == 0) {
  8009a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a9:	83 38 00             	cmpl   $0x0,(%eax)
  8009ac:	75 2c                	jne    8009da <file_get_block+0x52>
		
		int newblk;
		if ((newblk = alloc_block()) < 0)
  8009ae:	e8 92 fd ff ff       	call   800745 <alloc_block>
  8009b3:	89 c3                	mov    %eax,%ebx
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 3a                	js     8009f3 <file_get_block+0x6b>
			return -E_NO_DISK;
	
		memset(blockno_to_va(newblk), 0, BLKSIZE);
  8009b9:	83 ec 04             	sub    $0x4,%esp
  8009bc:	68 00 10 00 00       	push   $0x1000
  8009c1:	6a 00                	push   $0x0
  8009c3:	8d 80 00 00 01 00    	lea    0x10000(%eax),%eax
  8009c9:	c1 e0 0c             	shl    $0xc,%eax
  8009cc:	50                   	push   %eax
  8009cd:	e8 7c 17 00 00       	call   80214e <memset>
	
		*block_entry = newblk;
  8009d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d5:	89 18                	mov    %ebx,(%eax)
  8009d7:	83 c4 10             	add    $0x10,%esp
	}

	*blk = blockno_to_va(*block_entry);
  8009da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009dd:	8b 00                	mov    (%eax),%eax
  8009df:	05 00 00 01 00       	add    $0x10000,%eax
  8009e4:	c1 e0 0c             	shl    $0xc,%eax
  8009e7:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ea:	89 02                	mov    %eax,(%edx)
	return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb 05                	jmp    8009f8 <file_get_block+0x70>
	
	if (*block_entry == 0) {
		
		int newblk;
		if ((newblk = alloc_block()) < 0)
			return -E_NO_DISK;
  8009f3:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
		*block_entry = newblk;
	}

	*blk = blockno_to_va(*block_entry);
	return 0;
}
  8009f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	57                   	push   %edi
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800a09:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800a0f:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800a15:	eb 03                	jmp    800a1a <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a17:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a1a:	80 38 2f             	cmpb   $0x2f,(%eax)
  800a1d:	74 f8                	je     800a17 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800a1f:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  800a25:	83 c1 08             	add    $0x8,%ecx
  800a28:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800a2e:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800a35:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800a3b:	85 c9                	test   %ecx,%ecx
  800a3d:	74 06                	je     800a45 <walk_path+0x48>
		*pdir = 0;
  800a3f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800a45:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800a4b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800a51:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a56:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800a5c:	e9 5f 01 00 00       	jmp    800bc0 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800a61:	83 c7 01             	add    $0x1,%edi
  800a64:	eb 02                	jmp    800a68 <walk_path+0x6b>
  800a66:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800a68:	0f b6 17             	movzbl (%edi),%edx
  800a6b:	80 fa 2f             	cmp    $0x2f,%dl
  800a6e:	74 04                	je     800a74 <walk_path+0x77>
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 ed                	jne    800a61 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800a74:	89 fb                	mov    %edi,%ebx
  800a76:	29 c3                	sub    %eax,%ebx
  800a78:	83 fb 7f             	cmp    $0x7f,%ebx
  800a7b:	0f 8f 69 01 00 00    	jg     800bea <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a81:	83 ec 04             	sub    $0x4,%esp
  800a84:	53                   	push   %ebx
  800a85:	50                   	push   %eax
  800a86:	56                   	push   %esi
  800a87:	e8 0f 17 00 00       	call   80219b <memmove>
		name[path - p] = '\0';
  800a8c:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800a93:	00 
  800a94:	83 c4 10             	add    $0x10,%esp
  800a97:	eb 03                	jmp    800a9c <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a99:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a9c:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800a9f:	74 f8                	je     800a99 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800aa1:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800aa7:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800aae:	0f 85 3d 01 00 00    	jne    800bf1 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800ab4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800aba:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800abf:	74 19                	je     800ada <walk_path+0xdd>
  800ac1:	68 77 3e 80 00       	push   $0x803e77
  800ac6:	68 1d 3c 80 00       	push   $0x803c1d
  800acb:	68 ef 00 00 00       	push   $0xef
  800ad0:	68 df 3d 80 00       	push   $0x803ddf
  800ad5:	e8 d1 0e 00 00       	call   8019ab <_panic>
	nblock = dir->f_size / BLKSIZE;
  800ada:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800ae0:	85 c0                	test   %eax,%eax
  800ae2:	0f 48 c2             	cmovs  %edx,%eax
  800ae5:	c1 f8 0c             	sar    $0xc,%eax
  800ae8:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800aee:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800af5:	00 00 00 
  800af8:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800afe:	eb 5e                	jmp    800b5e <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800b00:	83 ec 04             	sub    $0x4,%esp
  800b03:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800b09:	50                   	push   %eax
  800b0a:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800b10:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800b16:	e8 6d fe ff ff       	call   800988 <file_get_block>
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	0f 88 ee 00 00 00    	js     800c14 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800b26:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800b2c:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800b32:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800b38:	83 ec 08             	sub    $0x8,%esp
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	e8 71 15 00 00       	call   8020b3 <strcmp>
  800b42:	83 c4 10             	add    $0x10,%esp
  800b45:	85 c0                	test   %eax,%eax
  800b47:	0f 84 ab 00 00 00    	je     800bf8 <walk_path+0x1fb>
  800b4d:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800b53:	39 fb                	cmp    %edi,%ebx
  800b55:	75 db                	jne    800b32 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800b57:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800b5e:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800b64:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800b6a:	75 94                	jne    800b00 <walk_path+0x103>
  800b6c:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800b72:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b77:	80 3f 00             	cmpb   $0x0,(%edi)
  800b7a:	0f 85 a3 00 00 00    	jne    800c23 <walk_path+0x226>
				if (pdir)
  800b80:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b86:	85 c0                	test   %eax,%eax
  800b88:	74 08                	je     800b92 <walk_path+0x195>
					*pdir = dir;
  800b8a:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b90:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800b92:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b96:	74 15                	je     800bad <walk_path+0x1b0>
					strcpy(lastelem, name);
  800b98:	83 ec 08             	sub    $0x8,%esp
  800b9b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800ba1:	50                   	push   %eax
  800ba2:	ff 75 08             	pushl  0x8(%ebp)
  800ba5:	e8 5f 14 00 00       	call   802009 <strcpy>
  800baa:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800bad:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800bb3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800bb9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800bbe:	eb 63                	jmp    800c23 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800bc0:	80 38 00             	cmpb   $0x0,(%eax)
  800bc3:	0f 85 9d fe ff ff    	jne    800a66 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800bc9:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	74 02                	je     800bd5 <walk_path+0x1d8>
		*pdir = dir;
  800bd3:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800bd5:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800bdb:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800be1:	89 08                	mov    %ecx,(%eax)
	return 0;
  800be3:	b8 00 00 00 00       	mov    $0x0,%eax
  800be8:	eb 39                	jmp    800c23 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800bea:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800bef:	eb 32                	jmp    800c23 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800bf1:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800bf6:	eb 2b                	jmp    800c23 <walk_path+0x226>
  800bf8:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800bfe:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800c04:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800c0a:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800c10:	89 f8                	mov    %edi,%eax
  800c12:	eb ac                	jmp    800bc0 <walk_path+0x1c3>
  800c14:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c1a:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800c1d:	0f 84 4f ff ff ff    	je     800b72 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800c31:	6a 00                	push   $0x0
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	e8 ba fd ff ff       	call   8009fd <walk_path>
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 2c             	sub    $0x2c,%esp
  800c4e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c51:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c54:	8b 45 08             	mov    0x8(%ebp),%eax
  800c57:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c62:	39 ca                	cmp    %ecx,%edx
  800c64:	7e 7c                	jle    800ce2 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c66:	29 ca                	sub    %ecx,%edx
  800c68:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c6b:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800c6f:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800c72:	89 ce                	mov    %ecx,%esi
  800c74:	01 d1                	add    %edx,%ecx
  800c76:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800c79:	eb 5d                	jmp    800cd8 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800c7b:	83 ec 04             	sub    $0x4,%esp
  800c7e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c81:	50                   	push   %eax
  800c82:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800c88:	85 f6                	test   %esi,%esi
  800c8a:	0f 49 c6             	cmovns %esi,%eax
  800c8d:	c1 f8 0c             	sar    $0xc,%eax
  800c90:	50                   	push   %eax
  800c91:	ff 75 08             	pushl  0x8(%ebp)
  800c94:	e8 ef fc ff ff       	call   800988 <file_get_block>
  800c99:	83 c4 10             	add    $0x10,%esp
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	78 42                	js     800ce2 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800ca0:	89 f2                	mov    %esi,%edx
  800ca2:	c1 fa 1f             	sar    $0x1f,%edx
  800ca5:	c1 ea 14             	shr    $0x14,%edx
  800ca8:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800cab:	25 ff 0f 00 00       	and    $0xfff,%eax
  800cb0:	29 d0                	sub    %edx,%eax
  800cb2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800cb5:	29 da                	sub    %ebx,%edx
  800cb7:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800cbc:	29 c3                	sub    %eax,%ebx
  800cbe:	39 da                	cmp    %ebx,%edx
  800cc0:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800cc3:	83 ec 04             	sub    $0x4,%esp
  800cc6:	53                   	push   %ebx
  800cc7:	03 45 e4             	add    -0x1c(%ebp),%eax
  800cca:	50                   	push   %eax
  800ccb:	57                   	push   %edi
  800ccc:	e8 ca 14 00 00       	call   80219b <memmove>
		pos += bn;
  800cd1:	01 de                	add    %ebx,%esi
		buf += bn;
  800cd3:	01 df                	add    %ebx,%edi
  800cd5:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800cd8:	89 f3                	mov    %esi,%ebx
  800cda:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800cdd:	77 9c                	ja     800c7b <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800cdf:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800ce2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
  800cf0:	83 ec 2c             	sub    $0x2c,%esp
  800cf3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800cf6:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800cfc:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800cff:	0f 8e a7 00 00 00    	jle    800dac <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800d05:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800d0b:	05 ff 0f 00 00       	add    $0xfff,%eax
  800d10:	0f 49 f8             	cmovns %eax,%edi
  800d13:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800d16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d19:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800d1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d21:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800d27:	0f 49 c2             	cmovns %edx,%eax
  800d2a:	c1 f8 0c             	sar    $0xc,%eax
  800d2d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d30:	89 c3                	mov    %eax,%ebx
  800d32:	eb 39                	jmp    800d6d <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	6a 00                	push   $0x0
  800d39:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800d3c:	89 da                	mov    %ebx,%edx
  800d3e:	89 f0                	mov    %esi,%eax
  800d40:	e8 94 fa ff ff       	call   8007d9 <file_block_walk>
  800d45:	83 c4 10             	add    $0x10,%esp
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	78 4d                	js     800d99 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800d4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d4f:	8b 00                	mov    (%eax),%eax
  800d51:	85 c0                	test   %eax,%eax
  800d53:	74 15                	je     800d6a <file_set_size+0x80>
		free_block(*ptr);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	e8 ab f9 ff ff       	call   800709 <free_block>
		*ptr = 0;
  800d5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800d67:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d6a:	83 c3 01             	add    $0x1,%ebx
  800d6d:	39 df                	cmp    %ebx,%edi
  800d6f:	77 c3                	ja     800d34 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d71:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800d75:	77 35                	ja     800dac <file_set_size+0xc2>
  800d77:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	74 2b                	je     800dac <file_set_size+0xc2>
		free_block(f->f_indirect);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	e8 7f f9 ff ff       	call   800709 <free_block>
		f->f_indirect = 0;
  800d8a:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800d91:	00 00 00 
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	eb 13                	jmp    800dac <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800d99:	83 ec 08             	sub    $0x8,%esp
  800d9c:	50                   	push   %eax
  800d9d:	68 94 3e 80 00       	push   $0x803e94
  800da2:	e8 dd 0c 00 00       	call   801a84 <cprintf>
  800da7:	83 c4 10             	add    $0x10,%esp
  800daa:	eb be                	jmp    800d6a <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daf:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	56                   	push   %esi
  800db9:	e8 52 f6 ff ff       	call   800410 <flush_block>
	return 0;
}
  800dbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 2c             	sub    $0x2c,%esp
  800dd4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800dd7:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800dda:	89 f0                	mov    %esi,%eax
  800ddc:	03 45 10             	add    0x10(%ebp),%eax
  800ddf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800de2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de5:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800deb:	76 72                	jbe    800e5f <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800ded:	83 ec 08             	sub    $0x8,%esp
  800df0:	50                   	push   %eax
  800df1:	51                   	push   %ecx
  800df2:	e8 f3 fe ff ff       	call   800cea <file_set_size>
  800df7:	83 c4 10             	add    $0x10,%esp
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	79 61                	jns    800e5f <file_write+0x94>
  800dfe:	eb 69                	jmp    800e69 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800e00:	83 ec 04             	sub    $0x4,%esp
  800e03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e06:	50                   	push   %eax
  800e07:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800e0d:	85 f6                	test   %esi,%esi
  800e0f:	0f 49 c6             	cmovns %esi,%eax
  800e12:	c1 f8 0c             	sar    $0xc,%eax
  800e15:	50                   	push   %eax
  800e16:	ff 75 08             	pushl  0x8(%ebp)
  800e19:	e8 6a fb ff ff       	call   800988 <file_get_block>
  800e1e:	83 c4 10             	add    $0x10,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	78 44                	js     800e69 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800e25:	89 f2                	mov    %esi,%edx
  800e27:	c1 fa 1f             	sar    $0x1f,%edx
  800e2a:	c1 ea 14             	shr    $0x14,%edx
  800e2d:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800e30:	25 ff 0f 00 00       	and    $0xfff,%eax
  800e35:	29 d0                	sub    %edx,%eax
  800e37:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e3a:	29 d9                	sub    %ebx,%ecx
  800e3c:	89 cb                	mov    %ecx,%ebx
  800e3e:	ba 00 10 00 00       	mov    $0x1000,%edx
  800e43:	29 c2                	sub    %eax,%edx
  800e45:	39 d1                	cmp    %edx,%ecx
  800e47:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	53                   	push   %ebx
  800e4e:	57                   	push   %edi
  800e4f:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e52:	50                   	push   %eax
  800e53:	e8 43 13 00 00       	call   80219b <memmove>
		pos += bn;
  800e58:	01 de                	add    %ebx,%esi
		buf += bn;
  800e5a:	01 df                	add    %ebx,%edi
  800e5c:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e5f:	89 f3                	mov    %esi,%ebx
  800e61:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e64:	77 9a                	ja     800e00 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e66:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800e69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
  800e76:	83 ec 10             	sub    $0x10,%esp
  800e79:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e81:	eb 3c                	jmp    800ebf <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e83:	83 ec 0c             	sub    $0xc,%esp
  800e86:	6a 00                	push   $0x0
  800e88:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e8b:	89 da                	mov    %ebx,%edx
  800e8d:	89 f0                	mov    %esi,%eax
  800e8f:	e8 45 f9 ff ff       	call   8007d9 <file_block_walk>
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	78 21                	js     800ebc <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	74 1a                	je     800ebc <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800ea2:	8b 00                	mov    (%eax),%eax
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	74 14                	je     800ebc <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	50                   	push   %eax
  800eac:	e8 e1 f4 ff ff       	call   800392 <diskaddr>
  800eb1:	89 04 24             	mov    %eax,(%esp)
  800eb4:	e8 57 f5 ff ff       	call   800410 <flush_block>
  800eb9:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800ebc:	83 c3 01             	add    $0x1,%ebx
  800ebf:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800ec5:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800ecb:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800ed1:	85 c9                	test   %ecx,%ecx
  800ed3:	0f 49 c1             	cmovns %ecx,%eax
  800ed6:	c1 f8 0c             	sar    $0xc,%eax
  800ed9:	39 c3                	cmp    %eax,%ebx
  800edb:	7c a6                	jl     800e83 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800edd:	83 ec 0c             	sub    $0xc,%esp
  800ee0:	56                   	push   %esi
  800ee1:	e8 2a f5 ff ff       	call   800410 <flush_block>
	if (f->f_indirect)
  800ee6:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	74 14                	je     800f07 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800ef3:	83 ec 0c             	sub    $0xc,%esp
  800ef6:	50                   	push   %eax
  800ef7:	e8 96 f4 ff ff       	call   800392 <diskaddr>
  800efc:	89 04 24             	mov    %eax,(%esp)
  800eff:	e8 0c f5 ff ff       	call   800410 <flush_block>
  800f04:	83 c4 10             	add    $0x10,%esp
}
  800f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800f1a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800f27:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f30:	e8 c8 fa ff ff       	call   8009fd <walk_path>
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	0f 84 d1 00 00 00    	je     801011 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800f40:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800f43:	0f 85 0c 01 00 00    	jne    801055 <file_create+0x147>
  800f49:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800f4f:	85 f6                	test   %esi,%esi
  800f51:	0f 84 c1 00 00 00    	je     801018 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800f57:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f5d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800f62:	74 19                	je     800f7d <file_create+0x6f>
  800f64:	68 77 3e 80 00       	push   $0x803e77
  800f69:	68 1d 3c 80 00       	push   $0x803c1d
  800f6e:	68 08 01 00 00       	push   $0x108
  800f73:	68 df 3d 80 00       	push   $0x803ddf
  800f78:	e8 2e 0a 00 00       	call   8019ab <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f7d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f83:	85 c0                	test   %eax,%eax
  800f85:	0f 48 c2             	cmovs  %edx,%eax
  800f88:	c1 f8 0c             	sar    $0xc,%eax
  800f8b:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f91:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f96:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800f9c:	eb 3b                	jmp    800fd9 <file_create+0xcb>
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	57                   	push   %edi
  800fa2:	53                   	push   %ebx
  800fa3:	56                   	push   %esi
  800fa4:	e8 df f9 ff ff       	call   800988 <file_get_block>
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	0f 88 a1 00 00 00    	js     801055 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  800fb4:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800fba:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800fc0:	80 38 00             	cmpb   $0x0,(%eax)
  800fc3:	75 08                	jne    800fcd <file_create+0xbf>
				*file = &f[j];
  800fc5:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800fcb:	eb 52                	jmp    80101f <file_create+0x111>
  800fcd:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800fd2:	39 d0                	cmp    %edx,%eax
  800fd4:	75 ea                	jne    800fc0 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800fd6:	83 c3 01             	add    $0x1,%ebx
  800fd9:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800fdf:	75 bd                	jne    800f9e <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800fe1:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800fe8:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800feb:	83 ec 04             	sub    $0x4,%esp
  800fee:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	53                   	push   %ebx
  800ff6:	56                   	push   %esi
  800ff7:	e8 8c f9 ff ff       	call   800988 <file_get_block>
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 52                	js     801055 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  801003:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801009:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80100f:	eb 0e                	jmp    80101f <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  801011:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801016:	eb 3d                	jmp    801055 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  801018:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80101d:	eb 36                	jmp    801055 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801028:	50                   	push   %eax
  801029:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  80102f:	e8 d5 0f 00 00       	call   802009 <strcpy>
	*pf = f;
  801034:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  80103a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103d:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80103f:	83 c4 04             	add    $0x4,%esp
  801042:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801048:	e8 24 fe ff ff       	call   800e71 <file_flush>
	return 0;
  80104d:	83 c4 10             	add    $0x10,%esp
  801050:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801055:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	53                   	push   %ebx
  801061:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801064:	bb 01 00 00 00       	mov    $0x1,%ebx
  801069:	eb 17                	jmp    801082 <fs_sync+0x25>
		flush_block(diskaddr(i));
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	53                   	push   %ebx
  80106f:	e8 1e f3 ff ff       	call   800392 <diskaddr>
  801074:	89 04 24             	mov    %eax,(%esp)
  801077:	e8 94 f3 ff ff       	call   800410 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80107c:	83 c3 01             	add    $0x1,%ebx
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  801087:	39 58 04             	cmp    %ebx,0x4(%eax)
  80108a:	77 df                	ja     80106b <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80108c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801097:	e8 c1 ff ff ff       	call   80105d <fs_sync>
	return 0;
}
  80109c:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  8010ab:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8010b0:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8010b5:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8010b7:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8010ba:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8010c0:	83 c0 01             	add    $0x1,%eax
  8010c3:	83 c2 10             	add    $0x10,%edx
  8010c6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010cb:	75 e8                	jne    8010b5 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8010d7:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	89 d8                	mov    %ebx,%eax
  8010e1:	c1 e0 04             	shl    $0x4,%eax
  8010e4:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8010ea:	e8 cd 1e 00 00       	call   802fbc <pageref>
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	74 07                	je     8010fd <openfile_alloc+0x2e>
  8010f6:	83 f8 01             	cmp    $0x1,%eax
  8010f9:	74 20                	je     80111b <openfile_alloc+0x4c>
  8010fb:	eb 51                	jmp    80114e <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8010fd:	83 ec 04             	sub    $0x4,%esp
  801100:	6a 07                	push   $0x7
  801102:	89 d8                	mov    %ebx,%eax
  801104:	c1 e0 04             	shl    $0x4,%eax
  801107:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80110d:	6a 00                	push   $0x0
  80110f:	e8 f8 12 00 00       	call   80240c <sys_page_alloc>
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	78 43                	js     80115e <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  80111b:	c1 e3 04             	shl    $0x4,%ebx
  80111e:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  801124:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  80112b:	04 00 00 
			*o = &opentab[i];
  80112e:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	68 00 10 00 00       	push   $0x1000
  801138:	6a 00                	push   $0x0
  80113a:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  801140:	e8 09 10 00 00       	call   80214e <memset>
			return (*o)->o_fileid;
  801145:	8b 06                	mov    (%esi),%eax
  801147:	8b 00                	mov    (%eax),%eax
  801149:	83 c4 10             	add    $0x10,%esp
  80114c:	eb 10                	jmp    80115e <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80114e:	83 c3 01             	add    $0x1,%ebx
  801151:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801157:	75 83                	jne    8010dc <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801159:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80115e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801161:	5b                   	pop    %ebx
  801162:	5e                   	pop    %esi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 18             	sub    $0x18,%esp
  80116e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801171:	89 fb                	mov    %edi,%ebx
  801173:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801179:	89 de                	mov    %ebx,%esi
  80117b:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80117e:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801184:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80118a:	e8 2d 1e 00 00       	call   802fbc <pageref>
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	83 f8 01             	cmp    $0x1,%eax
  801195:	7e 17                	jle    8011ae <openfile_lookup+0x49>
  801197:	c1 e3 04             	shl    $0x4,%ebx
  80119a:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  8011a0:	75 13                	jne    8011b5 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  8011a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8011a5:	89 30                	mov    %esi,(%eax)
	return 0;
  8011a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ac:	eb 0c                	jmp    8011ba <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8011ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b3:	eb 05                	jmp    8011ba <openfile_lookup+0x55>
  8011b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8011ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5e                   	pop    %esi
  8011bf:	5f                   	pop    %edi
  8011c0:	5d                   	pop    %ebp
  8011c1:	c3                   	ret    

008011c2 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 18             	sub    $0x18,%esp
  8011c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff 33                	pushl  (%ebx)
  8011d2:	ff 75 08             	pushl  0x8(%ebp)
  8011d5:	e8 8b ff ff ff       	call   801165 <openfile_lookup>
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 14                	js     8011f5 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	ff 73 04             	pushl  0x4(%ebx)
  8011e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ea:	ff 70 04             	pushl  0x4(%eax)
  8011ed:	e8 f8 fa ff ff       	call   800cea <file_set_size>
  8011f2:	83 c4 10             	add    $0x10,%esp
}
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 18             	sub    $0x18,%esp
  801201:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// Lab 5: Your code here:
	
	struct OpenFile *open;
	int x;
	if ((x = openfile_lookup(envid, req->req_fileid, &open)) < 0)
  801204:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801207:	50                   	push   %eax
  801208:	ff 33                	pushl  (%ebx)
  80120a:	ff 75 08             	pushl  0x8(%ebp)
  80120d:	e8 53 ff ff ff       	call   801165 <openfile_lookup>
  801212:	83 c4 10             	add    $0x10,%esp
		return x;
  801215:	89 c2                	mov    %eax,%edx

	// Lab 5: Your code here:
	
	struct OpenFile *open;
	int x;
	if ((x = openfile_lookup(envid, req->req_fileid, &open)) < 0)
  801217:	85 c0                	test   %eax,%eax
  801219:	78 2b                	js     801246 <serve_read+0x4c>
		return x;

	
	struct File *file = open->o_file;
  80121b:	8b 45 f4             	mov    -0xc(%ebp),%eax
	size_t count = req->req_n;
	off_t offset = open->o_fd->fd_offset;
  80121e:	8b 50 0c             	mov    0xc(%eax),%edx
	x = file_read(file, ret, count, offset);
  801221:	ff 72 04             	pushl  0x4(%edx)
  801224:	ff 73 04             	pushl  0x4(%ebx)
  801227:	53                   	push   %ebx
  801228:	ff 70 04             	pushl  0x4(%eax)
  80122b:	e8 15 fa ff ff       	call   800c45 <file_read>

		if (x < 0) {
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	78 0d                	js     801244 <serve_read+0x4a>
		return x;
	} else {
		uint32_t bytes_read = x;
		open->o_fd->fd_offset += bytes_read;
  801237:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80123a:	8b 52 0c             	mov    0xc(%edx),%edx
  80123d:	01 42 04             	add    %eax,0x4(%edx)
		return bytes_read;
  801240:	89 c2                	mov    %eax,%edx
  801242:	eb 02                	jmp    801246 <serve_read+0x4c>
	size_t count = req->req_n;
	off_t offset = open->o_fd->fd_offset;
	x = file_read(file, ret, count, offset);

		if (x < 0) {
		return x;
  801244:	89 c2                	mov    %eax,%edx
	} else {
		uint32_t bytes_read = x;
		open->o_fd->fd_offset += bytes_read;
		return bytes_read;
	}
}
  801246:	89 d0                	mov    %edx,%eax
  801248:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124b:	c9                   	leave  
  80124c:	c3                   	ret    

0080124d <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	53                   	push   %ebx
  801251:	83 ec 18             	sub    $0x18,%esp
  801254:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
	
	struct OpenFile *open;
	int x;
	if ((x = openfile_lookup(envid, req->req_fileid, &open)) < 0)
  801257:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125a:	50                   	push   %eax
  80125b:	ff 33                	pushl  (%ebx)
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 00 ff ff ff       	call   801165 <openfile_lookup>
  801265:	83 c4 10             	add    $0x10,%esp
		return x;
  801268:	89 c2                	mov    %eax,%edx

	// LAB 5: Your code here.
	
	struct OpenFile *open;
	int x;
	if ((x = openfile_lookup(envid, req->req_fileid, &open)) < 0)
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 2e                	js     80129c <serve_write+0x4f>
		return x;

	struct File *file_to_write = open->o_file;
  80126e:	8b 45 f4             	mov    -0xc(%ebp),%eax
	size_t count = req->req_n;
	off_t offset = open->o_fd->fd_offset;
  801271:	8b 50 0c             	mov    0xc(%eax),%edx
	x = file_write(file_to_write, req->req_buf, count, offset);
  801274:	ff 72 04             	pushl  0x4(%edx)
  801277:	ff 73 04             	pushl  0x4(%ebx)
  80127a:	83 c3 08             	add    $0x8,%ebx
  80127d:	53                   	push   %ebx
  80127e:	ff 70 04             	pushl  0x4(%eax)
  801281:	e8 45 fb ff ff       	call   800dcb <file_write>

	if (x < 0) {
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 0d                	js     80129a <serve_write+0x4d>
		return x;
	
	} else {
		uint32_t bytes_written = x;
		open->o_fd->fd_offset += bytes_written;
  80128d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801290:	8b 52 0c             	mov    0xc(%edx),%edx
  801293:	01 42 04             	add    %eax,0x4(%edx)
		return bytes_written;
  801296:	89 c2                	mov    %eax,%edx
  801298:	eb 02                	jmp    80129c <serve_write+0x4f>
	size_t count = req->req_n;
	off_t offset = open->o_fd->fd_offset;
	x = file_write(file_to_write, req->req_buf, count, offset);

	if (x < 0) {
		return x;
  80129a:	89 c2                	mov    %eax,%edx
	} else {
		uint32_t bytes_written = x;
		open->o_fd->fd_offset += bytes_written;
		return bytes_written;
	}
}
  80129c:	89 d0                	mov    %edx,%eax
  80129e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a1:	c9                   	leave  
  8012a2:	c3                   	ret    

008012a3 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	53                   	push   %ebx
  8012a7:	83 ec 18             	sub    $0x18,%esp
  8012aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	ff 33                	pushl  (%ebx)
  8012b3:	ff 75 08             	pushl  0x8(%ebp)
  8012b6:	e8 aa fe ff ff       	call   801165 <openfile_lookup>
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 3f                	js     801301 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c8:	ff 70 04             	pushl  0x4(%eax)
  8012cb:	53                   	push   %ebx
  8012cc:	e8 38 0d 00 00       	call   802009 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8012d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d4:	8b 50 04             	mov    0x4(%eax),%edx
  8012d7:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8012dd:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8012e3:	8b 40 04             	mov    0x4(%eax),%eax
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8012f0:	0f 94 c0             	sete   %al
  8012f3:	0f b6 c0             	movzbl %al,%eax
  8012f6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801301:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801304:	c9                   	leave  
  801305:	c3                   	ret    

00801306 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80130c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130f:	50                   	push   %eax
  801310:	8b 45 0c             	mov    0xc(%ebp),%eax
  801313:	ff 30                	pushl  (%eax)
  801315:	ff 75 08             	pushl  0x8(%ebp)
  801318:	e8 48 fe ff ff       	call   801165 <openfile_lookup>
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 16                	js     80133a <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132a:	ff 70 04             	pushl  0x4(%eax)
  80132d:	e8 3f fb ff ff       	call   800e71 <file_flush>
	return 0;
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	53                   	push   %ebx
  801340:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801346:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801349:	68 00 04 00 00       	push   $0x400
  80134e:	53                   	push   %ebx
  80134f:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	e8 40 0e 00 00       	call   80219b <memmove>
	path[MAXPATHLEN-1] = 0;
  80135b:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80135f:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801365:	89 04 24             	mov    %eax,(%esp)
  801368:	e8 62 fd ff ff       	call   8010cf <openfile_alloc>
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	85 c0                	test   %eax,%eax
  801372:	0f 88 f0 00 00 00    	js     801468 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801378:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80137f:	74 33                	je     8013b4 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801391:	50                   	push   %eax
  801392:	e8 77 fb ff ff       	call   800f0e <file_create>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	79 37                	jns    8013d5 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80139e:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8013a5:	0f 85 bd 00 00 00    	jne    801468 <serve_open+0x12c>
  8013ab:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8013ae:	0f 85 b4 00 00 00    	jne    801468 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	e8 61 f8 ff ff       	call   800c2b <file_open>
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	0f 88 93 00 00 00    	js     801468 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8013d5:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8013dc:	74 17                	je     8013f5 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	6a 00                	push   $0x0
  8013e3:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8013e9:	e8 fc f8 ff ff       	call   800cea <file_set_size>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 73                	js     801468 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	e8 20 f8 ff ff       	call   800c2b <file_open>
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 56                	js     801468 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  801412:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801418:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80141e:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801421:	8b 50 0c             	mov    0xc(%eax),%edx
  801424:	8b 08                	mov    (%eax),%ecx
  801426:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801429:	8b 48 0c             	mov    0xc(%eax),%ecx
  80142c:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801432:	83 e2 03             	and    $0x3,%edx
  801435:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801438:	8b 40 0c             	mov    0xc(%eax),%eax
  80143b:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801441:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801443:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801449:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80144f:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801452:	8b 50 0c             	mov    0xc(%eax),%edx
  801455:	8b 45 10             	mov    0x10(%ebp),%eax
  801458:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  80145a:	8b 45 14             	mov    0x14(%ebp),%eax
  80145d:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801463:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801468:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    

0080146d <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	56                   	push   %esi
  801471:	53                   	push   %ebx
  801472:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801475:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801478:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  80147b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801482:	83 ec 04             	sub    $0x4,%esp
  801485:	53                   	push   %ebx
  801486:	ff 35 44 50 80 00    	pushl  0x805044
  80148c:	56                   	push   %esi
  80148d:	e8 00 12 00 00       	call   802692 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801499:	75 15                	jne    8014b0 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a1:	68 dc 3e 80 00       	push   $0x803edc
  8014a6:	e8 d9 05 00 00       	call   801a84 <cprintf>
				whom);
			continue; // just leave it hanging...
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb cb                	jmp    80147b <serve+0xe>
		}

		pg = NULL;
  8014b0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8014b7:	83 f8 01             	cmp    $0x1,%eax
  8014ba:	75 18                	jne    8014d4 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8014bc:	53                   	push   %ebx
  8014bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	ff 35 44 50 80 00    	pushl  0x805044
  8014c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ca:	e8 6d fe ff ff       	call   80133c <serve_open>
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	eb 3c                	jmp    801510 <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  8014d4:	83 f8 08             	cmp    $0x8,%eax
  8014d7:	77 1e                	ja     8014f7 <serve+0x8a>
  8014d9:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8014e0:	85 d2                	test   %edx,%edx
  8014e2:	74 13                	je     8014f7 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	ff 35 44 50 80 00    	pushl  0x805044
  8014ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f0:	ff d2                	call   *%edx
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb 19                	jmp    801510 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8014f7:	83 ec 04             	sub    $0x4,%esp
  8014fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fd:	50                   	push   %eax
  8014fe:	68 0c 3f 80 00       	push   $0x803f0c
  801503:	e8 7c 05 00 00       	call   801a84 <cprintf>
  801508:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  80150b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801510:	ff 75 f0             	pushl  -0x10(%ebp)
  801513:	ff 75 ec             	pushl  -0x14(%ebp)
  801516:	50                   	push   %eax
  801517:	ff 75 f4             	pushl  -0xc(%ebp)
  80151a:	e8 dc 11 00 00       	call   8026fb <ipc_send>
		sys_page_unmap(0, fsreq);
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	ff 35 44 50 80 00    	pushl  0x805044
  801528:	6a 00                	push   $0x0
  80152a:	e8 62 0f 00 00       	call   802491 <sys_page_unmap>
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	e9 44 ff ff ff       	jmp    80147b <serve+0xe>

00801537 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80153d:	c7 05 60 90 80 00 2f 	movl   $0x803f2f,0x809060
  801544:	3f 80 00 
	cprintf("FS is running\n");
  801547:	68 32 3f 80 00       	push   $0x803f32
  80154c:	e8 33 05 00 00       	call   801a84 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801551:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801556:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80155b:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80155d:	c7 04 24 41 3f 80 00 	movl   $0x803f41,(%esp)
  801564:	e8 1b 05 00 00       	call   801a84 <cprintf>

	serve_init();
  801569:	e8 35 fb ff ff       	call   8010a3 <serve_init>
	fs_init();
  80156e:	e8 b6 f3 ff ff       	call   800929 <fs_init>
	serve();
  801573:	e8 f5 fe ff ff       	call   80146d <serve>

00801578 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80157f:	6a 07                	push   $0x7
  801581:	68 00 10 00 00       	push   $0x1000
  801586:	6a 00                	push   $0x0
  801588:	e8 7f 0e 00 00       	call   80240c <sys_page_alloc>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	79 12                	jns    8015a6 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801594:	50                   	push   %eax
  801595:	68 50 3f 80 00       	push   $0x803f50
  80159a:	6a 12                	push   $0x12
  80159c:	68 63 3f 80 00       	push   $0x803f63
  8015a1:	e8 05 04 00 00       	call   8019ab <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	68 00 10 00 00       	push   $0x1000
  8015ae:	ff 35 08 a0 80 00    	pushl  0x80a008
  8015b4:	68 00 10 00 00       	push   $0x1000
  8015b9:	e8 dd 0b 00 00       	call   80219b <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8015be:	e8 82 f1 ff ff       	call   800745 <alloc_block>
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	79 12                	jns    8015dc <fs_test+0x64>
		panic("alloc_block: %e", r);
  8015ca:	50                   	push   %eax
  8015cb:	68 6d 3f 80 00       	push   $0x803f6d
  8015d0:	6a 17                	push   $0x17
  8015d2:	68 63 3f 80 00       	push   $0x803f63
  8015d7:	e8 cf 03 00 00       	call   8019ab <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8015dc:	8d 50 1f             	lea    0x1f(%eax),%edx
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	0f 49 d0             	cmovns %eax,%edx
  8015e4:	c1 fa 05             	sar    $0x5,%edx
  8015e7:	89 c3                	mov    %eax,%ebx
  8015e9:	c1 fb 1f             	sar    $0x1f,%ebx
  8015ec:	c1 eb 1b             	shr    $0x1b,%ebx
  8015ef:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8015f2:	83 e1 1f             	and    $0x1f,%ecx
  8015f5:	29 d9                	sub    %ebx,%ecx
  8015f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8015fc:	d3 e0                	shl    %cl,%eax
  8015fe:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  801605:	75 16                	jne    80161d <fs_test+0xa5>
  801607:	68 7d 3f 80 00       	push   $0x803f7d
  80160c:	68 1d 3c 80 00       	push   $0x803c1d
  801611:	6a 19                	push   $0x19
  801613:	68 63 3f 80 00       	push   $0x803f63
  801618:	e8 8e 03 00 00       	call   8019ab <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  80161d:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  801623:	85 04 91             	test   %eax,(%ecx,%edx,4)
  801626:	74 16                	je     80163e <fs_test+0xc6>
  801628:	68 f8 40 80 00       	push   $0x8040f8
  80162d:	68 1d 3c 80 00       	push   $0x803c1d
  801632:	6a 1b                	push   $0x1b
  801634:	68 63 3f 80 00       	push   $0x803f63
  801639:	e8 6d 03 00 00       	call   8019ab <_panic>
	cprintf("alloc_block is good\n");
  80163e:	83 ec 0c             	sub    $0xc,%esp
  801641:	68 98 3f 80 00       	push   $0x803f98
  801646:	e8 39 04 00 00       	call   801a84 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80164b:	83 c4 08             	add    $0x8,%esp
  80164e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801651:	50                   	push   %eax
  801652:	68 ad 3f 80 00       	push   $0x803fad
  801657:	e8 cf f5 ff ff       	call   800c2b <file_open>
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801662:	74 1b                	je     80167f <fs_test+0x107>
  801664:	89 c2                	mov    %eax,%edx
  801666:	c1 ea 1f             	shr    $0x1f,%edx
  801669:	84 d2                	test   %dl,%dl
  80166b:	74 12                	je     80167f <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80166d:	50                   	push   %eax
  80166e:	68 b8 3f 80 00       	push   $0x803fb8
  801673:	6a 1f                	push   $0x1f
  801675:	68 63 3f 80 00       	push   $0x803f63
  80167a:	e8 2c 03 00 00       	call   8019ab <_panic>
	else if (r == 0)
  80167f:	85 c0                	test   %eax,%eax
  801681:	75 14                	jne    801697 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801683:	83 ec 04             	sub    $0x4,%esp
  801686:	68 18 41 80 00       	push   $0x804118
  80168b:	6a 21                	push   $0x21
  80168d:	68 63 3f 80 00       	push   $0x803f63
  801692:	e8 14 03 00 00       	call   8019ab <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169d:	50                   	push   %eax
  80169e:	68 d1 3f 80 00       	push   $0x803fd1
  8016a3:	e8 83 f5 ff ff       	call   800c2b <file_open>
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	79 12                	jns    8016c1 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  8016af:	50                   	push   %eax
  8016b0:	68 da 3f 80 00       	push   $0x803fda
  8016b5:	6a 23                	push   $0x23
  8016b7:	68 63 3f 80 00       	push   $0x803f63
  8016bc:	e8 ea 02 00 00       	call   8019ab <_panic>
	cprintf("file_open is good\n");
  8016c1:	83 ec 0c             	sub    $0xc,%esp
  8016c4:	68 f1 3f 80 00       	push   $0x803ff1
  8016c9:	e8 b6 03 00 00       	call   801a84 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8016ce:	83 c4 0c             	add    $0xc,%esp
  8016d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d4:	50                   	push   %eax
  8016d5:	6a 00                	push   $0x0
  8016d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8016da:	e8 a9 f2 ff ff       	call   800988 <file_get_block>
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	79 12                	jns    8016f8 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8016e6:	50                   	push   %eax
  8016e7:	68 04 40 80 00       	push   $0x804004
  8016ec:	6a 27                	push   $0x27
  8016ee:	68 63 3f 80 00       	push   $0x803f63
  8016f3:	e8 b3 02 00 00       	call   8019ab <_panic>
	if (strcmp(blk, msg) != 0)
  8016f8:	83 ec 08             	sub    $0x8,%esp
  8016fb:	68 38 41 80 00       	push   $0x804138
  801700:	ff 75 f0             	pushl  -0x10(%ebp)
  801703:	e8 ab 09 00 00       	call   8020b3 <strcmp>
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	74 14                	je     801723 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  80170f:	83 ec 04             	sub    $0x4,%esp
  801712:	68 60 41 80 00       	push   $0x804160
  801717:	6a 29                	push   $0x29
  801719:	68 63 3f 80 00       	push   $0x803f63
  80171e:	e8 88 02 00 00       	call   8019ab <_panic>
	cprintf("file_get_block is good\n");
  801723:	83 ec 0c             	sub    $0xc,%esp
  801726:	68 17 40 80 00       	push   $0x804017
  80172b:	e8 54 03 00 00       	call   801a84 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801730:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801733:	0f b6 10             	movzbl (%eax),%edx
  801736:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801738:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173b:	c1 e8 0c             	shr    $0xc,%eax
  80173e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	a8 40                	test   $0x40,%al
  80174a:	75 16                	jne    801762 <fs_test+0x1ea>
  80174c:	68 30 40 80 00       	push   $0x804030
  801751:	68 1d 3c 80 00       	push   $0x803c1d
  801756:	6a 2d                	push   $0x2d
  801758:	68 63 3f 80 00       	push   $0x803f63
  80175d:	e8 49 02 00 00       	call   8019ab <_panic>
	file_flush(f);
  801762:	83 ec 0c             	sub    $0xc,%esp
  801765:	ff 75 f4             	pushl  -0xc(%ebp)
  801768:	e8 04 f7 ff ff       	call   800e71 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80176d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801770:	c1 e8 0c             	shr    $0xc,%eax
  801773:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	a8 40                	test   $0x40,%al
  80177f:	74 16                	je     801797 <fs_test+0x21f>
  801781:	68 2f 40 80 00       	push   $0x80402f
  801786:	68 1d 3c 80 00       	push   $0x803c1d
  80178b:	6a 2f                	push   $0x2f
  80178d:	68 63 3f 80 00       	push   $0x803f63
  801792:	e8 14 02 00 00       	call   8019ab <_panic>
	cprintf("file_flush is good\n");
  801797:	83 ec 0c             	sub    $0xc,%esp
  80179a:	68 4b 40 80 00       	push   $0x80404b
  80179f:	e8 e0 02 00 00       	call   801a84 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8017a4:	83 c4 08             	add    $0x8,%esp
  8017a7:	6a 00                	push   $0x0
  8017a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ac:	e8 39 f5 ff ff       	call   800cea <file_set_size>
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	85 c0                	test   %eax,%eax
  8017b6:	79 12                	jns    8017ca <fs_test+0x252>
		panic("file_set_size: %e", r);
  8017b8:	50                   	push   %eax
  8017b9:	68 5f 40 80 00       	push   $0x80405f
  8017be:	6a 33                	push   $0x33
  8017c0:	68 63 3f 80 00       	push   $0x803f63
  8017c5:	e8 e1 01 00 00       	call   8019ab <_panic>
	assert(f->f_direct[0] == 0);
  8017ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017cd:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8017d4:	74 16                	je     8017ec <fs_test+0x274>
  8017d6:	68 71 40 80 00       	push   $0x804071
  8017db:	68 1d 3c 80 00       	push   $0x803c1d
  8017e0:	6a 34                	push   $0x34
  8017e2:	68 63 3f 80 00       	push   $0x803f63
  8017e7:	e8 bf 01 00 00       	call   8019ab <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8017ec:	c1 e8 0c             	shr    $0xc,%eax
  8017ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017f6:	a8 40                	test   $0x40,%al
  8017f8:	74 16                	je     801810 <fs_test+0x298>
  8017fa:	68 85 40 80 00       	push   $0x804085
  8017ff:	68 1d 3c 80 00       	push   $0x803c1d
  801804:	6a 35                	push   $0x35
  801806:	68 63 3f 80 00       	push   $0x803f63
  80180b:	e8 9b 01 00 00       	call   8019ab <_panic>
	cprintf("file_truncate is good\n");
  801810:	83 ec 0c             	sub    $0xc,%esp
  801813:	68 9f 40 80 00       	push   $0x80409f
  801818:	e8 67 02 00 00       	call   801a84 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  80181d:	c7 04 24 38 41 80 00 	movl   $0x804138,(%esp)
  801824:	e8 a7 07 00 00       	call   801fd0 <strlen>
  801829:	83 c4 08             	add    $0x8,%esp
  80182c:	50                   	push   %eax
  80182d:	ff 75 f4             	pushl  -0xc(%ebp)
  801830:	e8 b5 f4 ff ff       	call   800cea <file_set_size>
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	79 12                	jns    80184e <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  80183c:	50                   	push   %eax
  80183d:	68 b6 40 80 00       	push   $0x8040b6
  801842:	6a 39                	push   $0x39
  801844:	68 63 3f 80 00       	push   $0x803f63
  801849:	e8 5d 01 00 00       	call   8019ab <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80184e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801851:	89 c2                	mov    %eax,%edx
  801853:	c1 ea 0c             	shr    $0xc,%edx
  801856:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80185d:	f6 c2 40             	test   $0x40,%dl
  801860:	74 16                	je     801878 <fs_test+0x300>
  801862:	68 85 40 80 00       	push   $0x804085
  801867:	68 1d 3c 80 00       	push   $0x803c1d
  80186c:	6a 3a                	push   $0x3a
  80186e:	68 63 3f 80 00       	push   $0x803f63
  801873:	e8 33 01 00 00       	call   8019ab <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801878:	83 ec 04             	sub    $0x4,%esp
  80187b:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80187e:	52                   	push   %edx
  80187f:	6a 00                	push   $0x0
  801881:	50                   	push   %eax
  801882:	e8 01 f1 ff ff       	call   800988 <file_get_block>
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	85 c0                	test   %eax,%eax
  80188c:	79 12                	jns    8018a0 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  80188e:	50                   	push   %eax
  80188f:	68 ca 40 80 00       	push   $0x8040ca
  801894:	6a 3c                	push   $0x3c
  801896:	68 63 3f 80 00       	push   $0x803f63
  80189b:	e8 0b 01 00 00       	call   8019ab <_panic>
	strcpy(blk, msg);
  8018a0:	83 ec 08             	sub    $0x8,%esp
  8018a3:	68 38 41 80 00       	push   $0x804138
  8018a8:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ab:	e8 59 07 00 00       	call   802009 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b3:	c1 e8 0c             	shr    $0xc,%eax
  8018b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	a8 40                	test   $0x40,%al
  8018c2:	75 16                	jne    8018da <fs_test+0x362>
  8018c4:	68 30 40 80 00       	push   $0x804030
  8018c9:	68 1d 3c 80 00       	push   $0x803c1d
  8018ce:	6a 3e                	push   $0x3e
  8018d0:	68 63 3f 80 00       	push   $0x803f63
  8018d5:	e8 d1 00 00 00       	call   8019ab <_panic>
	file_flush(f);
  8018da:	83 ec 0c             	sub    $0xc,%esp
  8018dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e0:	e8 8c f5 ff ff       	call   800e71 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e8:	c1 e8 0c             	shr    $0xc,%eax
  8018eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	a8 40                	test   $0x40,%al
  8018f7:	74 16                	je     80190f <fs_test+0x397>
  8018f9:	68 2f 40 80 00       	push   $0x80402f
  8018fe:	68 1d 3c 80 00       	push   $0x803c1d
  801903:	6a 40                	push   $0x40
  801905:	68 63 3f 80 00       	push   $0x803f63
  80190a:	e8 9c 00 00 00       	call   8019ab <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80190f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801912:	c1 e8 0c             	shr    $0xc,%eax
  801915:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80191c:	a8 40                	test   $0x40,%al
  80191e:	74 16                	je     801936 <fs_test+0x3be>
  801920:	68 85 40 80 00       	push   $0x804085
  801925:	68 1d 3c 80 00       	push   $0x803c1d
  80192a:	6a 41                	push   $0x41
  80192c:	68 63 3f 80 00       	push   $0x803f63
  801931:	e8 75 00 00 00       	call   8019ab <_panic>
	cprintf("file rewrite is good\n");
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	68 df 40 80 00       	push   $0x8040df
  80193e:	e8 41 01 00 00       	call   801a84 <cprintf>
}
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	56                   	push   %esi
  80194f:	53                   	push   %ebx
  801950:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801953:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801956:	e8 73 0a 00 00       	call   8023ce <sys_getenvid>
  80195b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801960:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801963:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801968:	a3 10 a0 80 00       	mov    %eax,0x80a010

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80196d:	85 db                	test   %ebx,%ebx
  80196f:	7e 07                	jle    801978 <libmain+0x2d>
		binaryname = argv[0];
  801971:	8b 06                	mov    (%esi),%eax
  801973:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	56                   	push   %esi
  80197c:	53                   	push   %ebx
  80197d:	e8 b5 fb ff ff       	call   801537 <umain>

	// exit gracefully
	exit();
  801982:	e8 0a 00 00 00       	call   801991 <exit>
}
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198d:	5b                   	pop    %ebx
  80198e:	5e                   	pop    %esi
  80198f:	5d                   	pop    %ebp
  801990:	c3                   	ret    

00801991 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801997:	e8 b7 0f 00 00       	call   802953 <close_all>
	sys_env_destroy(0);
  80199c:	83 ec 0c             	sub    $0xc,%esp
  80199f:	6a 00                	push   $0x0
  8019a1:	e8 e7 09 00 00       	call   80238d <sys_env_destroy>
}
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	56                   	push   %esi
  8019af:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019b0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019b3:	8b 35 60 90 80 00    	mov    0x809060,%esi
  8019b9:	e8 10 0a 00 00       	call   8023ce <sys_getenvid>
  8019be:	83 ec 0c             	sub    $0xc,%esp
  8019c1:	ff 75 0c             	pushl  0xc(%ebp)
  8019c4:	ff 75 08             	pushl  0x8(%ebp)
  8019c7:	56                   	push   %esi
  8019c8:	50                   	push   %eax
  8019c9:	68 90 41 80 00       	push   $0x804190
  8019ce:	e8 b1 00 00 00       	call   801a84 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019d3:	83 c4 18             	add    $0x18,%esp
  8019d6:	53                   	push   %ebx
  8019d7:	ff 75 10             	pushl  0x10(%ebp)
  8019da:	e8 54 00 00 00       	call   801a33 <vcprintf>
	cprintf("\n");
  8019df:	c7 04 24 76 3d 80 00 	movl   $0x803d76,(%esp)
  8019e6:	e8 99 00 00 00       	call   801a84 <cprintf>
  8019eb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019ee:	cc                   	int3   
  8019ef:	eb fd                	jmp    8019ee <_panic+0x43>

008019f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	53                   	push   %ebx
  8019f5:	83 ec 04             	sub    $0x4,%esp
  8019f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019fb:	8b 13                	mov    (%ebx),%edx
  8019fd:	8d 42 01             	lea    0x1(%edx),%eax
  801a00:	89 03                	mov    %eax,(%ebx)
  801a02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a05:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801a09:	3d ff 00 00 00       	cmp    $0xff,%eax
  801a0e:	75 1a                	jne    801a2a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801a10:	83 ec 08             	sub    $0x8,%esp
  801a13:	68 ff 00 00 00       	push   $0xff
  801a18:	8d 43 08             	lea    0x8(%ebx),%eax
  801a1b:	50                   	push   %eax
  801a1c:	e8 2f 09 00 00       	call   802350 <sys_cputs>
		b->idx = 0;
  801a21:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a27:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801a2a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a3c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a43:	00 00 00 
	b.cnt = 0;
  801a46:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a4d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a50:	ff 75 0c             	pushl  0xc(%ebp)
  801a53:	ff 75 08             	pushl  0x8(%ebp)
  801a56:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a5c:	50                   	push   %eax
  801a5d:	68 f1 19 80 00       	push   $0x8019f1
  801a62:	e8 54 01 00 00       	call   801bbb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a67:	83 c4 08             	add    $0x8,%esp
  801a6a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a70:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a76:	50                   	push   %eax
  801a77:	e8 d4 08 00 00       	call   802350 <sys_cputs>

	return b.cnt;
}
  801a7c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a8a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a8d:	50                   	push   %eax
  801a8e:	ff 75 08             	pushl  0x8(%ebp)
  801a91:	e8 9d ff ff ff       	call   801a33 <vcprintf>
	va_end(ap);

	return cnt;
}
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	57                   	push   %edi
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 1c             	sub    $0x1c,%esp
  801aa1:	89 c7                	mov    %eax,%edi
  801aa3:	89 d6                	mov    %edx,%esi
  801aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aae:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801ab1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ab4:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ab9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801abc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801abf:	39 d3                	cmp    %edx,%ebx
  801ac1:	72 05                	jb     801ac8 <printnum+0x30>
  801ac3:	39 45 10             	cmp    %eax,0x10(%ebp)
  801ac6:	77 45                	ja     801b0d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801ac8:	83 ec 0c             	sub    $0xc,%esp
  801acb:	ff 75 18             	pushl  0x18(%ebp)
  801ace:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801ad4:	53                   	push   %ebx
  801ad5:	ff 75 10             	pushl  0x10(%ebp)
  801ad8:	83 ec 08             	sub    $0x8,%esp
  801adb:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ade:	ff 75 e0             	pushl  -0x20(%ebp)
  801ae1:	ff 75 dc             	pushl  -0x24(%ebp)
  801ae4:	ff 75 d8             	pushl  -0x28(%ebp)
  801ae7:	e8 54 1e 00 00       	call   803940 <__udivdi3>
  801aec:	83 c4 18             	add    $0x18,%esp
  801aef:	52                   	push   %edx
  801af0:	50                   	push   %eax
  801af1:	89 f2                	mov    %esi,%edx
  801af3:	89 f8                	mov    %edi,%eax
  801af5:	e8 9e ff ff ff       	call   801a98 <printnum>
  801afa:	83 c4 20             	add    $0x20,%esp
  801afd:	eb 18                	jmp    801b17 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801aff:	83 ec 08             	sub    $0x8,%esp
  801b02:	56                   	push   %esi
  801b03:	ff 75 18             	pushl  0x18(%ebp)
  801b06:	ff d7                	call   *%edi
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	eb 03                	jmp    801b10 <printnum+0x78>
  801b0d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801b10:	83 eb 01             	sub    $0x1,%ebx
  801b13:	85 db                	test   %ebx,%ebx
  801b15:	7f e8                	jg     801aff <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801b17:	83 ec 08             	sub    $0x8,%esp
  801b1a:	56                   	push   %esi
  801b1b:	83 ec 04             	sub    $0x4,%esp
  801b1e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b21:	ff 75 e0             	pushl  -0x20(%ebp)
  801b24:	ff 75 dc             	pushl  -0x24(%ebp)
  801b27:	ff 75 d8             	pushl  -0x28(%ebp)
  801b2a:	e8 41 1f 00 00       	call   803a70 <__umoddi3>
  801b2f:	83 c4 14             	add    $0x14,%esp
  801b32:	0f be 80 b3 41 80 00 	movsbl 0x8041b3(%eax),%eax
  801b39:	50                   	push   %eax
  801b3a:	ff d7                	call   *%edi
}
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b42:	5b                   	pop    %ebx
  801b43:	5e                   	pop    %esi
  801b44:	5f                   	pop    %edi
  801b45:	5d                   	pop    %ebp
  801b46:	c3                   	ret    

00801b47 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b4a:	83 fa 01             	cmp    $0x1,%edx
  801b4d:	7e 0e                	jle    801b5d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b4f:	8b 10                	mov    (%eax),%edx
  801b51:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b54:	89 08                	mov    %ecx,(%eax)
  801b56:	8b 02                	mov    (%edx),%eax
  801b58:	8b 52 04             	mov    0x4(%edx),%edx
  801b5b:	eb 22                	jmp    801b7f <getuint+0x38>
	else if (lflag)
  801b5d:	85 d2                	test   %edx,%edx
  801b5f:	74 10                	je     801b71 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b61:	8b 10                	mov    (%eax),%edx
  801b63:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b66:	89 08                	mov    %ecx,(%eax)
  801b68:	8b 02                	mov    (%edx),%eax
  801b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6f:	eb 0e                	jmp    801b7f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b71:	8b 10                	mov    (%eax),%edx
  801b73:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b76:	89 08                	mov    %ecx,(%eax)
  801b78:	8b 02                	mov    (%edx),%eax
  801b7a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b87:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b8b:	8b 10                	mov    (%eax),%edx
  801b8d:	3b 50 04             	cmp    0x4(%eax),%edx
  801b90:	73 0a                	jae    801b9c <sprintputch+0x1b>
		*b->buf++ = ch;
  801b92:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b95:	89 08                	mov    %ecx,(%eax)
  801b97:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9a:	88 02                	mov    %al,(%edx)
}
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    

00801b9e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801ba4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801ba7:	50                   	push   %eax
  801ba8:	ff 75 10             	pushl  0x10(%ebp)
  801bab:	ff 75 0c             	pushl  0xc(%ebp)
  801bae:	ff 75 08             	pushl  0x8(%ebp)
  801bb1:	e8 05 00 00 00       	call   801bbb <vprintfmt>
	va_end(ap);
}
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    

00801bbb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	57                   	push   %edi
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	83 ec 2c             	sub    $0x2c,%esp
  801bc4:	8b 75 08             	mov    0x8(%ebp),%esi
  801bc7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bca:	8b 7d 10             	mov    0x10(%ebp),%edi
  801bcd:	eb 12                	jmp    801be1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	0f 84 89 03 00 00    	je     801f60 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801bd7:	83 ec 08             	sub    $0x8,%esp
  801bda:	53                   	push   %ebx
  801bdb:	50                   	push   %eax
  801bdc:	ff d6                	call   *%esi
  801bde:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801be1:	83 c7 01             	add    $0x1,%edi
  801be4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801be8:	83 f8 25             	cmp    $0x25,%eax
  801beb:	75 e2                	jne    801bcf <vprintfmt+0x14>
  801bed:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801bf1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801bf8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801bff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801c06:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0b:	eb 07                	jmp    801c14 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801c10:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c14:	8d 47 01             	lea    0x1(%edi),%eax
  801c17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c1a:	0f b6 07             	movzbl (%edi),%eax
  801c1d:	0f b6 c8             	movzbl %al,%ecx
  801c20:	83 e8 23             	sub    $0x23,%eax
  801c23:	3c 55                	cmp    $0x55,%al
  801c25:	0f 87 1a 03 00 00    	ja     801f45 <vprintfmt+0x38a>
  801c2b:	0f b6 c0             	movzbl %al,%eax
  801c2e:	ff 24 85 00 43 80 00 	jmp    *0x804300(,%eax,4)
  801c35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c38:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c3c:	eb d6                	jmp    801c14 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c41:	b8 00 00 00 00       	mov    $0x0,%eax
  801c46:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c49:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c4c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c50:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c53:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c56:	83 fa 09             	cmp    $0x9,%edx
  801c59:	77 39                	ja     801c94 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c5b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c5e:	eb e9                	jmp    801c49 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c60:	8b 45 14             	mov    0x14(%ebp),%eax
  801c63:	8d 48 04             	lea    0x4(%eax),%ecx
  801c66:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c69:	8b 00                	mov    (%eax),%eax
  801c6b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c71:	eb 27                	jmp    801c9a <vprintfmt+0xdf>
  801c73:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c76:	85 c0                	test   %eax,%eax
  801c78:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c7d:	0f 49 c8             	cmovns %eax,%ecx
  801c80:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c86:	eb 8c                	jmp    801c14 <vprintfmt+0x59>
  801c88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c8b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c92:	eb 80                	jmp    801c14 <vprintfmt+0x59>
  801c94:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c97:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c9a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c9e:	0f 89 70 ff ff ff    	jns    801c14 <vprintfmt+0x59>
				width = precision, precision = -1;
  801ca4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801ca7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801caa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801cb1:	e9 5e ff ff ff       	jmp    801c14 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801cb6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cb9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801cbc:	e9 53 ff ff ff       	jmp    801c14 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801cc1:	8b 45 14             	mov    0x14(%ebp),%eax
  801cc4:	8d 50 04             	lea    0x4(%eax),%edx
  801cc7:	89 55 14             	mov    %edx,0x14(%ebp)
  801cca:	83 ec 08             	sub    $0x8,%esp
  801ccd:	53                   	push   %ebx
  801cce:	ff 30                	pushl  (%eax)
  801cd0:	ff d6                	call   *%esi
			break;
  801cd2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801cd8:	e9 04 ff ff ff       	jmp    801be1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801cdd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ce0:	8d 50 04             	lea    0x4(%eax),%edx
  801ce3:	89 55 14             	mov    %edx,0x14(%ebp)
  801ce6:	8b 00                	mov    (%eax),%eax
  801ce8:	99                   	cltd   
  801ce9:	31 d0                	xor    %edx,%eax
  801ceb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801ced:	83 f8 0f             	cmp    $0xf,%eax
  801cf0:	7f 0b                	jg     801cfd <vprintfmt+0x142>
  801cf2:	8b 14 85 60 44 80 00 	mov    0x804460(,%eax,4),%edx
  801cf9:	85 d2                	test   %edx,%edx
  801cfb:	75 18                	jne    801d15 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801cfd:	50                   	push   %eax
  801cfe:	68 cb 41 80 00       	push   $0x8041cb
  801d03:	53                   	push   %ebx
  801d04:	56                   	push   %esi
  801d05:	e8 94 fe ff ff       	call   801b9e <printfmt>
  801d0a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801d10:	e9 cc fe ff ff       	jmp    801be1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801d15:	52                   	push   %edx
  801d16:	68 2f 3c 80 00       	push   $0x803c2f
  801d1b:	53                   	push   %ebx
  801d1c:	56                   	push   %esi
  801d1d:	e8 7c fe ff ff       	call   801b9e <printfmt>
  801d22:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d28:	e9 b4 fe ff ff       	jmp    801be1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d30:	8d 50 04             	lea    0x4(%eax),%edx
  801d33:	89 55 14             	mov    %edx,0x14(%ebp)
  801d36:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801d38:	85 ff                	test   %edi,%edi
  801d3a:	b8 c4 41 80 00       	mov    $0x8041c4,%eax
  801d3f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801d42:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801d46:	0f 8e 94 00 00 00    	jle    801de0 <vprintfmt+0x225>
  801d4c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d50:	0f 84 98 00 00 00    	je     801dee <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d56:	83 ec 08             	sub    $0x8,%esp
  801d59:	ff 75 d0             	pushl  -0x30(%ebp)
  801d5c:	57                   	push   %edi
  801d5d:	e8 86 02 00 00       	call   801fe8 <strnlen>
  801d62:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d65:	29 c1                	sub    %eax,%ecx
  801d67:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d6a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d6d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d74:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d77:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d79:	eb 0f                	jmp    801d8a <vprintfmt+0x1cf>
					putch(padc, putdat);
  801d7b:	83 ec 08             	sub    $0x8,%esp
  801d7e:	53                   	push   %ebx
  801d7f:	ff 75 e0             	pushl  -0x20(%ebp)
  801d82:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d84:	83 ef 01             	sub    $0x1,%edi
  801d87:	83 c4 10             	add    $0x10,%esp
  801d8a:	85 ff                	test   %edi,%edi
  801d8c:	7f ed                	jg     801d7b <vprintfmt+0x1c0>
  801d8e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d91:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d94:	85 c9                	test   %ecx,%ecx
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9b:	0f 49 c1             	cmovns %ecx,%eax
  801d9e:	29 c1                	sub    %eax,%ecx
  801da0:	89 75 08             	mov    %esi,0x8(%ebp)
  801da3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801da6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801da9:	89 cb                	mov    %ecx,%ebx
  801dab:	eb 4d                	jmp    801dfa <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801dad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801db1:	74 1b                	je     801dce <vprintfmt+0x213>
  801db3:	0f be c0             	movsbl %al,%eax
  801db6:	83 e8 20             	sub    $0x20,%eax
  801db9:	83 f8 5e             	cmp    $0x5e,%eax
  801dbc:	76 10                	jbe    801dce <vprintfmt+0x213>
					putch('?', putdat);
  801dbe:	83 ec 08             	sub    $0x8,%esp
  801dc1:	ff 75 0c             	pushl  0xc(%ebp)
  801dc4:	6a 3f                	push   $0x3f
  801dc6:	ff 55 08             	call   *0x8(%ebp)
  801dc9:	83 c4 10             	add    $0x10,%esp
  801dcc:	eb 0d                	jmp    801ddb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801dce:	83 ec 08             	sub    $0x8,%esp
  801dd1:	ff 75 0c             	pushl  0xc(%ebp)
  801dd4:	52                   	push   %edx
  801dd5:	ff 55 08             	call   *0x8(%ebp)
  801dd8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801ddb:	83 eb 01             	sub    $0x1,%ebx
  801dde:	eb 1a                	jmp    801dfa <vprintfmt+0x23f>
  801de0:	89 75 08             	mov    %esi,0x8(%ebp)
  801de3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801de6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801de9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dec:	eb 0c                	jmp    801dfa <vprintfmt+0x23f>
  801dee:	89 75 08             	mov    %esi,0x8(%ebp)
  801df1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801df4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801df7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801dfa:	83 c7 01             	add    $0x1,%edi
  801dfd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801e01:	0f be d0             	movsbl %al,%edx
  801e04:	85 d2                	test   %edx,%edx
  801e06:	74 23                	je     801e2b <vprintfmt+0x270>
  801e08:	85 f6                	test   %esi,%esi
  801e0a:	78 a1                	js     801dad <vprintfmt+0x1f2>
  801e0c:	83 ee 01             	sub    $0x1,%esi
  801e0f:	79 9c                	jns    801dad <vprintfmt+0x1f2>
  801e11:	89 df                	mov    %ebx,%edi
  801e13:	8b 75 08             	mov    0x8(%ebp),%esi
  801e16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e19:	eb 18                	jmp    801e33 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801e1b:	83 ec 08             	sub    $0x8,%esp
  801e1e:	53                   	push   %ebx
  801e1f:	6a 20                	push   $0x20
  801e21:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801e23:	83 ef 01             	sub    $0x1,%edi
  801e26:	83 c4 10             	add    $0x10,%esp
  801e29:	eb 08                	jmp    801e33 <vprintfmt+0x278>
  801e2b:	89 df                	mov    %ebx,%edi
  801e2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801e30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e33:	85 ff                	test   %edi,%edi
  801e35:	7f e4                	jg     801e1b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e3a:	e9 a2 fd ff ff       	jmp    801be1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e3f:	83 fa 01             	cmp    $0x1,%edx
  801e42:	7e 16                	jle    801e5a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801e44:	8b 45 14             	mov    0x14(%ebp),%eax
  801e47:	8d 50 08             	lea    0x8(%eax),%edx
  801e4a:	89 55 14             	mov    %edx,0x14(%ebp)
  801e4d:	8b 50 04             	mov    0x4(%eax),%edx
  801e50:	8b 00                	mov    (%eax),%eax
  801e52:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e55:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e58:	eb 32                	jmp    801e8c <vprintfmt+0x2d1>
	else if (lflag)
  801e5a:	85 d2                	test   %edx,%edx
  801e5c:	74 18                	je     801e76 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801e5e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e61:	8d 50 04             	lea    0x4(%eax),%edx
  801e64:	89 55 14             	mov    %edx,0x14(%ebp)
  801e67:	8b 00                	mov    (%eax),%eax
  801e69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e6c:	89 c1                	mov    %eax,%ecx
  801e6e:	c1 f9 1f             	sar    $0x1f,%ecx
  801e71:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e74:	eb 16                	jmp    801e8c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801e76:	8b 45 14             	mov    0x14(%ebp),%eax
  801e79:	8d 50 04             	lea    0x4(%eax),%edx
  801e7c:	89 55 14             	mov    %edx,0x14(%ebp)
  801e7f:	8b 00                	mov    (%eax),%eax
  801e81:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e84:	89 c1                	mov    %eax,%ecx
  801e86:	c1 f9 1f             	sar    $0x1f,%ecx
  801e89:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e8f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e92:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e97:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e9b:	79 74                	jns    801f11 <vprintfmt+0x356>
				putch('-', putdat);
  801e9d:	83 ec 08             	sub    $0x8,%esp
  801ea0:	53                   	push   %ebx
  801ea1:	6a 2d                	push   $0x2d
  801ea3:	ff d6                	call   *%esi
				num = -(long long) num;
  801ea5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ea8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801eab:	f7 d8                	neg    %eax
  801ead:	83 d2 00             	adc    $0x0,%edx
  801eb0:	f7 da                	neg    %edx
  801eb2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801eb5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801eba:	eb 55                	jmp    801f11 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ebc:	8d 45 14             	lea    0x14(%ebp),%eax
  801ebf:	e8 83 fc ff ff       	call   801b47 <getuint>
			base = 10;
  801ec4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ec9:	eb 46                	jmp    801f11 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ecb:	8d 45 14             	lea    0x14(%ebp),%eax
  801ece:	e8 74 fc ff ff       	call   801b47 <getuint>
                        base = 8;
  801ed3:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  801ed8:	eb 37                	jmp    801f11 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801eda:	83 ec 08             	sub    $0x8,%esp
  801edd:	53                   	push   %ebx
  801ede:	6a 30                	push   $0x30
  801ee0:	ff d6                	call   *%esi
			putch('x', putdat);
  801ee2:	83 c4 08             	add    $0x8,%esp
  801ee5:	53                   	push   %ebx
  801ee6:	6a 78                	push   $0x78
  801ee8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801eea:	8b 45 14             	mov    0x14(%ebp),%eax
  801eed:	8d 50 04             	lea    0x4(%eax),%edx
  801ef0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801ef3:	8b 00                	mov    (%eax),%eax
  801ef5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801efa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801efd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801f02:	eb 0d                	jmp    801f11 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801f04:	8d 45 14             	lea    0x14(%ebp),%eax
  801f07:	e8 3b fc ff ff       	call   801b47 <getuint>
			base = 16;
  801f0c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801f18:	57                   	push   %edi
  801f19:	ff 75 e0             	pushl  -0x20(%ebp)
  801f1c:	51                   	push   %ecx
  801f1d:	52                   	push   %edx
  801f1e:	50                   	push   %eax
  801f1f:	89 da                	mov    %ebx,%edx
  801f21:	89 f0                	mov    %esi,%eax
  801f23:	e8 70 fb ff ff       	call   801a98 <printnum>
			break;
  801f28:	83 c4 20             	add    $0x20,%esp
  801f2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f2e:	e9 ae fc ff ff       	jmp    801be1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f33:	83 ec 08             	sub    $0x8,%esp
  801f36:	53                   	push   %ebx
  801f37:	51                   	push   %ecx
  801f38:	ff d6                	call   *%esi
			break;
  801f3a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f40:	e9 9c fc ff ff       	jmp    801be1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f45:	83 ec 08             	sub    $0x8,%esp
  801f48:	53                   	push   %ebx
  801f49:	6a 25                	push   $0x25
  801f4b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f4d:	83 c4 10             	add    $0x10,%esp
  801f50:	eb 03                	jmp    801f55 <vprintfmt+0x39a>
  801f52:	83 ef 01             	sub    $0x1,%edi
  801f55:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f59:	75 f7                	jne    801f52 <vprintfmt+0x397>
  801f5b:	e9 81 fc ff ff       	jmp    801be1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    

00801f68 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	83 ec 18             	sub    $0x18,%esp
  801f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f71:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f74:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f77:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f7b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f85:	85 c0                	test   %eax,%eax
  801f87:	74 26                	je     801faf <vsnprintf+0x47>
  801f89:	85 d2                	test   %edx,%edx
  801f8b:	7e 22                	jle    801faf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f8d:	ff 75 14             	pushl  0x14(%ebp)
  801f90:	ff 75 10             	pushl  0x10(%ebp)
  801f93:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f96:	50                   	push   %eax
  801f97:	68 81 1b 80 00       	push   $0x801b81
  801f9c:	e8 1a fc ff ff       	call   801bbb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801fa1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801fa4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801faa:	83 c4 10             	add    $0x10,%esp
  801fad:	eb 05                	jmp    801fb4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801faf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801fb4:	c9                   	leave  
  801fb5:	c3                   	ret    

00801fb6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801fbc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801fbf:	50                   	push   %eax
  801fc0:	ff 75 10             	pushl  0x10(%ebp)
  801fc3:	ff 75 0c             	pushl  0xc(%ebp)
  801fc6:	ff 75 08             	pushl  0x8(%ebp)
  801fc9:	e8 9a ff ff ff       	call   801f68 <vsnprintf>
	va_end(ap);

	return rc;
}
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801fd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdb:	eb 03                	jmp    801fe0 <strlen+0x10>
		n++;
  801fdd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801fe0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801fe4:	75 f7                	jne    801fdd <strlen+0xd>
		n++;
	return n;
}
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    

00801fe8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fee:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ff1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff6:	eb 03                	jmp    801ffb <strnlen+0x13>
		n++;
  801ff8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ffb:	39 c2                	cmp    %eax,%edx
  801ffd:	74 08                	je     802007 <strnlen+0x1f>
  801fff:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  802003:	75 f3                	jne    801ff8 <strnlen+0x10>
  802005:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802007:	5d                   	pop    %ebp
  802008:	c3                   	ret    

00802009 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	53                   	push   %ebx
  80200d:	8b 45 08             	mov    0x8(%ebp),%eax
  802010:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802013:	89 c2                	mov    %eax,%edx
  802015:	83 c2 01             	add    $0x1,%edx
  802018:	83 c1 01             	add    $0x1,%ecx
  80201b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80201f:	88 5a ff             	mov    %bl,-0x1(%edx)
  802022:	84 db                	test   %bl,%bl
  802024:	75 ef                	jne    802015 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802026:	5b                   	pop    %ebx
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	53                   	push   %ebx
  80202d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802030:	53                   	push   %ebx
  802031:	e8 9a ff ff ff       	call   801fd0 <strlen>
  802036:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802039:	ff 75 0c             	pushl  0xc(%ebp)
  80203c:	01 d8                	add    %ebx,%eax
  80203e:	50                   	push   %eax
  80203f:	e8 c5 ff ff ff       	call   802009 <strcpy>
	return dst;
}
  802044:	89 d8                	mov    %ebx,%eax
  802046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802049:	c9                   	leave  
  80204a:	c3                   	ret    

0080204b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	56                   	push   %esi
  80204f:	53                   	push   %ebx
  802050:	8b 75 08             	mov    0x8(%ebp),%esi
  802053:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802056:	89 f3                	mov    %esi,%ebx
  802058:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80205b:	89 f2                	mov    %esi,%edx
  80205d:	eb 0f                	jmp    80206e <strncpy+0x23>
		*dst++ = *src;
  80205f:	83 c2 01             	add    $0x1,%edx
  802062:	0f b6 01             	movzbl (%ecx),%eax
  802065:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802068:	80 39 01             	cmpb   $0x1,(%ecx)
  80206b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80206e:	39 da                	cmp    %ebx,%edx
  802070:	75 ed                	jne    80205f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802072:	89 f0                	mov    %esi,%eax
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    

00802078 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	56                   	push   %esi
  80207c:	53                   	push   %ebx
  80207d:	8b 75 08             	mov    0x8(%ebp),%esi
  802080:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802083:	8b 55 10             	mov    0x10(%ebp),%edx
  802086:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802088:	85 d2                	test   %edx,%edx
  80208a:	74 21                	je     8020ad <strlcpy+0x35>
  80208c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802090:	89 f2                	mov    %esi,%edx
  802092:	eb 09                	jmp    80209d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802094:	83 c2 01             	add    $0x1,%edx
  802097:	83 c1 01             	add    $0x1,%ecx
  80209a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80209d:	39 c2                	cmp    %eax,%edx
  80209f:	74 09                	je     8020aa <strlcpy+0x32>
  8020a1:	0f b6 19             	movzbl (%ecx),%ebx
  8020a4:	84 db                	test   %bl,%bl
  8020a6:	75 ec                	jne    802094 <strlcpy+0x1c>
  8020a8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8020aa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8020ad:	29 f0                	sub    %esi,%eax
}
  8020af:	5b                   	pop    %ebx
  8020b0:	5e                   	pop    %esi
  8020b1:	5d                   	pop    %ebp
  8020b2:	c3                   	ret    

008020b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8020bc:	eb 06                	jmp    8020c4 <strcmp+0x11>
		p++, q++;
  8020be:	83 c1 01             	add    $0x1,%ecx
  8020c1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8020c4:	0f b6 01             	movzbl (%ecx),%eax
  8020c7:	84 c0                	test   %al,%al
  8020c9:	74 04                	je     8020cf <strcmp+0x1c>
  8020cb:	3a 02                	cmp    (%edx),%al
  8020cd:	74 ef                	je     8020be <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8020cf:	0f b6 c0             	movzbl %al,%eax
  8020d2:	0f b6 12             	movzbl (%edx),%edx
  8020d5:	29 d0                	sub    %edx,%eax
}
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    

008020d9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8020d9:	55                   	push   %ebp
  8020da:	89 e5                	mov    %esp,%ebp
  8020dc:	53                   	push   %ebx
  8020dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e3:	89 c3                	mov    %eax,%ebx
  8020e5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8020e8:	eb 06                	jmp    8020f0 <strncmp+0x17>
		n--, p++, q++;
  8020ea:	83 c0 01             	add    $0x1,%eax
  8020ed:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8020f0:	39 d8                	cmp    %ebx,%eax
  8020f2:	74 15                	je     802109 <strncmp+0x30>
  8020f4:	0f b6 08             	movzbl (%eax),%ecx
  8020f7:	84 c9                	test   %cl,%cl
  8020f9:	74 04                	je     8020ff <strncmp+0x26>
  8020fb:	3a 0a                	cmp    (%edx),%cl
  8020fd:	74 eb                	je     8020ea <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8020ff:	0f b6 00             	movzbl (%eax),%eax
  802102:	0f b6 12             	movzbl (%edx),%edx
  802105:	29 d0                	sub    %edx,%eax
  802107:	eb 05                	jmp    80210e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802109:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80210e:	5b                   	pop    %ebx
  80210f:	5d                   	pop    %ebp
  802110:	c3                   	ret    

00802111 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802111:	55                   	push   %ebp
  802112:	89 e5                	mov    %esp,%ebp
  802114:	8b 45 08             	mov    0x8(%ebp),%eax
  802117:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80211b:	eb 07                	jmp    802124 <strchr+0x13>
		if (*s == c)
  80211d:	38 ca                	cmp    %cl,%dl
  80211f:	74 0f                	je     802130 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802121:	83 c0 01             	add    $0x1,%eax
  802124:	0f b6 10             	movzbl (%eax),%edx
  802127:	84 d2                	test   %dl,%dl
  802129:	75 f2                	jne    80211d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80212b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    

00802132 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	8b 45 08             	mov    0x8(%ebp),%eax
  802138:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80213c:	eb 03                	jmp    802141 <strfind+0xf>
  80213e:	83 c0 01             	add    $0x1,%eax
  802141:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802144:	38 ca                	cmp    %cl,%dl
  802146:	74 04                	je     80214c <strfind+0x1a>
  802148:	84 d2                	test   %dl,%dl
  80214a:	75 f2                	jne    80213e <strfind+0xc>
			break;
	return (char *) s;
}
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    

0080214e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	53                   	push   %ebx
  802154:	8b 7d 08             	mov    0x8(%ebp),%edi
  802157:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80215a:	85 c9                	test   %ecx,%ecx
  80215c:	74 36                	je     802194 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80215e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802164:	75 28                	jne    80218e <memset+0x40>
  802166:	f6 c1 03             	test   $0x3,%cl
  802169:	75 23                	jne    80218e <memset+0x40>
		c &= 0xFF;
  80216b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80216f:	89 d3                	mov    %edx,%ebx
  802171:	c1 e3 08             	shl    $0x8,%ebx
  802174:	89 d6                	mov    %edx,%esi
  802176:	c1 e6 18             	shl    $0x18,%esi
  802179:	89 d0                	mov    %edx,%eax
  80217b:	c1 e0 10             	shl    $0x10,%eax
  80217e:	09 f0                	or     %esi,%eax
  802180:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  802182:	89 d8                	mov    %ebx,%eax
  802184:	09 d0                	or     %edx,%eax
  802186:	c1 e9 02             	shr    $0x2,%ecx
  802189:	fc                   	cld    
  80218a:	f3 ab                	rep stos %eax,%es:(%edi)
  80218c:	eb 06                	jmp    802194 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80218e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802191:	fc                   	cld    
  802192:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802194:	89 f8                	mov    %edi,%eax
  802196:	5b                   	pop    %ebx
  802197:	5e                   	pop    %esi
  802198:	5f                   	pop    %edi
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    

0080219b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	57                   	push   %edi
  80219f:	56                   	push   %esi
  8021a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8021a9:	39 c6                	cmp    %eax,%esi
  8021ab:	73 35                	jae    8021e2 <memmove+0x47>
  8021ad:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8021b0:	39 d0                	cmp    %edx,%eax
  8021b2:	73 2e                	jae    8021e2 <memmove+0x47>
		s += n;
		d += n;
  8021b4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021b7:	89 d6                	mov    %edx,%esi
  8021b9:	09 fe                	or     %edi,%esi
  8021bb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8021c1:	75 13                	jne    8021d6 <memmove+0x3b>
  8021c3:	f6 c1 03             	test   $0x3,%cl
  8021c6:	75 0e                	jne    8021d6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8021c8:	83 ef 04             	sub    $0x4,%edi
  8021cb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8021ce:	c1 e9 02             	shr    $0x2,%ecx
  8021d1:	fd                   	std    
  8021d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021d4:	eb 09                	jmp    8021df <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021d6:	83 ef 01             	sub    $0x1,%edi
  8021d9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8021dc:	fd                   	std    
  8021dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021df:	fc                   	cld    
  8021e0:	eb 1d                	jmp    8021ff <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	09 c2                	or     %eax,%edx
  8021e6:	f6 c2 03             	test   $0x3,%dl
  8021e9:	75 0f                	jne    8021fa <memmove+0x5f>
  8021eb:	f6 c1 03             	test   $0x3,%cl
  8021ee:	75 0a                	jne    8021fa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8021f0:	c1 e9 02             	shr    $0x2,%ecx
  8021f3:	89 c7                	mov    %eax,%edi
  8021f5:	fc                   	cld    
  8021f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021f8:	eb 05                	jmp    8021ff <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021fa:	89 c7                	mov    %eax,%edi
  8021fc:	fc                   	cld    
  8021fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021ff:	5e                   	pop    %esi
  802200:	5f                   	pop    %edi
  802201:	5d                   	pop    %ebp
  802202:	c3                   	ret    

00802203 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802203:	55                   	push   %ebp
  802204:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802206:	ff 75 10             	pushl  0x10(%ebp)
  802209:	ff 75 0c             	pushl  0xc(%ebp)
  80220c:	ff 75 08             	pushl  0x8(%ebp)
  80220f:	e8 87 ff ff ff       	call   80219b <memmove>
}
  802214:	c9                   	leave  
  802215:	c3                   	ret    

00802216 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	56                   	push   %esi
  80221a:	53                   	push   %ebx
  80221b:	8b 45 08             	mov    0x8(%ebp),%eax
  80221e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802221:	89 c6                	mov    %eax,%esi
  802223:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802226:	eb 1a                	jmp    802242 <memcmp+0x2c>
		if (*s1 != *s2)
  802228:	0f b6 08             	movzbl (%eax),%ecx
  80222b:	0f b6 1a             	movzbl (%edx),%ebx
  80222e:	38 d9                	cmp    %bl,%cl
  802230:	74 0a                	je     80223c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802232:	0f b6 c1             	movzbl %cl,%eax
  802235:	0f b6 db             	movzbl %bl,%ebx
  802238:	29 d8                	sub    %ebx,%eax
  80223a:	eb 0f                	jmp    80224b <memcmp+0x35>
		s1++, s2++;
  80223c:	83 c0 01             	add    $0x1,%eax
  80223f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802242:	39 f0                	cmp    %esi,%eax
  802244:	75 e2                	jne    802228 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802246:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80224b:	5b                   	pop    %ebx
  80224c:	5e                   	pop    %esi
  80224d:	5d                   	pop    %ebp
  80224e:	c3                   	ret    

0080224f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80224f:	55                   	push   %ebp
  802250:	89 e5                	mov    %esp,%ebp
  802252:	53                   	push   %ebx
  802253:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802256:	89 c1                	mov    %eax,%ecx
  802258:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80225b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80225f:	eb 0a                	jmp    80226b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  802261:	0f b6 10             	movzbl (%eax),%edx
  802264:	39 da                	cmp    %ebx,%edx
  802266:	74 07                	je     80226f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802268:	83 c0 01             	add    $0x1,%eax
  80226b:	39 c8                	cmp    %ecx,%eax
  80226d:	72 f2                	jb     802261 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80226f:	5b                   	pop    %ebx
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    

00802272 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802272:	55                   	push   %ebp
  802273:	89 e5                	mov    %esp,%ebp
  802275:	57                   	push   %edi
  802276:	56                   	push   %esi
  802277:	53                   	push   %ebx
  802278:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80227b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80227e:	eb 03                	jmp    802283 <strtol+0x11>
		s++;
  802280:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802283:	0f b6 01             	movzbl (%ecx),%eax
  802286:	3c 20                	cmp    $0x20,%al
  802288:	74 f6                	je     802280 <strtol+0xe>
  80228a:	3c 09                	cmp    $0x9,%al
  80228c:	74 f2                	je     802280 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80228e:	3c 2b                	cmp    $0x2b,%al
  802290:	75 0a                	jne    80229c <strtol+0x2a>
		s++;
  802292:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802295:	bf 00 00 00 00       	mov    $0x0,%edi
  80229a:	eb 11                	jmp    8022ad <strtol+0x3b>
  80229c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8022a1:	3c 2d                	cmp    $0x2d,%al
  8022a3:	75 08                	jne    8022ad <strtol+0x3b>
		s++, neg = 1;
  8022a5:	83 c1 01             	add    $0x1,%ecx
  8022a8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022ad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8022b3:	75 15                	jne    8022ca <strtol+0x58>
  8022b5:	80 39 30             	cmpb   $0x30,(%ecx)
  8022b8:	75 10                	jne    8022ca <strtol+0x58>
  8022ba:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8022be:	75 7c                	jne    80233c <strtol+0xca>
		s += 2, base = 16;
  8022c0:	83 c1 02             	add    $0x2,%ecx
  8022c3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8022c8:	eb 16                	jmp    8022e0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8022ca:	85 db                	test   %ebx,%ebx
  8022cc:	75 12                	jne    8022e0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8022ce:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022d3:	80 39 30             	cmpb   $0x30,(%ecx)
  8022d6:	75 08                	jne    8022e0 <strtol+0x6e>
		s++, base = 8;
  8022d8:	83 c1 01             	add    $0x1,%ecx
  8022db:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8022e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022e8:	0f b6 11             	movzbl (%ecx),%edx
  8022eb:	8d 72 d0             	lea    -0x30(%edx),%esi
  8022ee:	89 f3                	mov    %esi,%ebx
  8022f0:	80 fb 09             	cmp    $0x9,%bl
  8022f3:	77 08                	ja     8022fd <strtol+0x8b>
			dig = *s - '0';
  8022f5:	0f be d2             	movsbl %dl,%edx
  8022f8:	83 ea 30             	sub    $0x30,%edx
  8022fb:	eb 22                	jmp    80231f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8022fd:	8d 72 9f             	lea    -0x61(%edx),%esi
  802300:	89 f3                	mov    %esi,%ebx
  802302:	80 fb 19             	cmp    $0x19,%bl
  802305:	77 08                	ja     80230f <strtol+0x9d>
			dig = *s - 'a' + 10;
  802307:	0f be d2             	movsbl %dl,%edx
  80230a:	83 ea 57             	sub    $0x57,%edx
  80230d:	eb 10                	jmp    80231f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80230f:	8d 72 bf             	lea    -0x41(%edx),%esi
  802312:	89 f3                	mov    %esi,%ebx
  802314:	80 fb 19             	cmp    $0x19,%bl
  802317:	77 16                	ja     80232f <strtol+0xbd>
			dig = *s - 'A' + 10;
  802319:	0f be d2             	movsbl %dl,%edx
  80231c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80231f:	3b 55 10             	cmp    0x10(%ebp),%edx
  802322:	7d 0b                	jge    80232f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802324:	83 c1 01             	add    $0x1,%ecx
  802327:	0f af 45 10          	imul   0x10(%ebp),%eax
  80232b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80232d:	eb b9                	jmp    8022e8 <strtol+0x76>

	if (endptr)
  80232f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802333:	74 0d                	je     802342 <strtol+0xd0>
		*endptr = (char *) s;
  802335:	8b 75 0c             	mov    0xc(%ebp),%esi
  802338:	89 0e                	mov    %ecx,(%esi)
  80233a:	eb 06                	jmp    802342 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80233c:	85 db                	test   %ebx,%ebx
  80233e:	74 98                	je     8022d8 <strtol+0x66>
  802340:	eb 9e                	jmp    8022e0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802342:	89 c2                	mov    %eax,%edx
  802344:	f7 da                	neg    %edx
  802346:	85 ff                	test   %edi,%edi
  802348:	0f 45 c2             	cmovne %edx,%eax
}
  80234b:	5b                   	pop    %ebx
  80234c:	5e                   	pop    %esi
  80234d:	5f                   	pop    %edi
  80234e:	5d                   	pop    %ebp
  80234f:	c3                   	ret    

00802350 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802350:	55                   	push   %ebp
  802351:	89 e5                	mov    %esp,%ebp
  802353:	57                   	push   %edi
  802354:	56                   	push   %esi
  802355:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802356:	b8 00 00 00 00       	mov    $0x0,%eax
  80235b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80235e:	8b 55 08             	mov    0x8(%ebp),%edx
  802361:	89 c3                	mov    %eax,%ebx
  802363:	89 c7                	mov    %eax,%edi
  802365:	89 c6                	mov    %eax,%esi
  802367:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  802369:	5b                   	pop    %ebx
  80236a:	5e                   	pop    %esi
  80236b:	5f                   	pop    %edi
  80236c:	5d                   	pop    %ebp
  80236d:	c3                   	ret    

0080236e <sys_cgetc>:

int
sys_cgetc(void)
{
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	57                   	push   %edi
  802372:	56                   	push   %esi
  802373:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802374:	ba 00 00 00 00       	mov    $0x0,%edx
  802379:	b8 01 00 00 00       	mov    $0x1,%eax
  80237e:	89 d1                	mov    %edx,%ecx
  802380:	89 d3                	mov    %edx,%ebx
  802382:	89 d7                	mov    %edx,%edi
  802384:	89 d6                	mov    %edx,%esi
  802386:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    

0080238d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80238d:	55                   	push   %ebp
  80238e:	89 e5                	mov    %esp,%ebp
  802390:	57                   	push   %edi
  802391:	56                   	push   %esi
  802392:	53                   	push   %ebx
  802393:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802396:	b9 00 00 00 00       	mov    $0x0,%ecx
  80239b:	b8 03 00 00 00       	mov    $0x3,%eax
  8023a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8023a3:	89 cb                	mov    %ecx,%ebx
  8023a5:	89 cf                	mov    %ecx,%edi
  8023a7:	89 ce                	mov    %ecx,%esi
  8023a9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8023ab:	85 c0                	test   %eax,%eax
  8023ad:	7e 17                	jle    8023c6 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8023af:	83 ec 0c             	sub    $0xc,%esp
  8023b2:	50                   	push   %eax
  8023b3:	6a 03                	push   $0x3
  8023b5:	68 bf 44 80 00       	push   $0x8044bf
  8023ba:	6a 23                	push   $0x23
  8023bc:	68 dc 44 80 00       	push   $0x8044dc
  8023c1:	e8 e5 f5 ff ff       	call   8019ab <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8023c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023c9:	5b                   	pop    %ebx
  8023ca:	5e                   	pop    %esi
  8023cb:	5f                   	pop    %edi
  8023cc:	5d                   	pop    %ebp
  8023cd:	c3                   	ret    

008023ce <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	57                   	push   %edi
  8023d2:	56                   	push   %esi
  8023d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8023d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8023de:	89 d1                	mov    %edx,%ecx
  8023e0:	89 d3                	mov    %edx,%ebx
  8023e2:	89 d7                	mov    %edx,%edi
  8023e4:	89 d6                	mov    %edx,%esi
  8023e6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    

008023ed <sys_yield>:

void
sys_yield(void)
{
  8023ed:	55                   	push   %ebp
  8023ee:	89 e5                	mov    %esp,%ebp
  8023f0:	57                   	push   %edi
  8023f1:	56                   	push   %esi
  8023f2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8023f8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8023fd:	89 d1                	mov    %edx,%ecx
  8023ff:	89 d3                	mov    %edx,%ebx
  802401:	89 d7                	mov    %edx,%edi
  802403:	89 d6                	mov    %edx,%esi
  802405:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802407:	5b                   	pop    %ebx
  802408:	5e                   	pop    %esi
  802409:	5f                   	pop    %edi
  80240a:	5d                   	pop    %ebp
  80240b:	c3                   	ret    

0080240c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80240c:	55                   	push   %ebp
  80240d:	89 e5                	mov    %esp,%ebp
  80240f:	57                   	push   %edi
  802410:	56                   	push   %esi
  802411:	53                   	push   %ebx
  802412:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802415:	be 00 00 00 00       	mov    $0x0,%esi
  80241a:	b8 04 00 00 00       	mov    $0x4,%eax
  80241f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802422:	8b 55 08             	mov    0x8(%ebp),%edx
  802425:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802428:	89 f7                	mov    %esi,%edi
  80242a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80242c:	85 c0                	test   %eax,%eax
  80242e:	7e 17                	jle    802447 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802430:	83 ec 0c             	sub    $0xc,%esp
  802433:	50                   	push   %eax
  802434:	6a 04                	push   $0x4
  802436:	68 bf 44 80 00       	push   $0x8044bf
  80243b:	6a 23                	push   $0x23
  80243d:	68 dc 44 80 00       	push   $0x8044dc
  802442:	e8 64 f5 ff ff       	call   8019ab <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802447:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80244a:	5b                   	pop    %ebx
  80244b:	5e                   	pop    %esi
  80244c:	5f                   	pop    %edi
  80244d:	5d                   	pop    %ebp
  80244e:	c3                   	ret    

0080244f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80244f:	55                   	push   %ebp
  802450:	89 e5                	mov    %esp,%ebp
  802452:	57                   	push   %edi
  802453:	56                   	push   %esi
  802454:	53                   	push   %ebx
  802455:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802458:	b8 05 00 00 00       	mov    $0x5,%eax
  80245d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802460:	8b 55 08             	mov    0x8(%ebp),%edx
  802463:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802466:	8b 7d 14             	mov    0x14(%ebp),%edi
  802469:	8b 75 18             	mov    0x18(%ebp),%esi
  80246c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80246e:	85 c0                	test   %eax,%eax
  802470:	7e 17                	jle    802489 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802472:	83 ec 0c             	sub    $0xc,%esp
  802475:	50                   	push   %eax
  802476:	6a 05                	push   $0x5
  802478:	68 bf 44 80 00       	push   $0x8044bf
  80247d:	6a 23                	push   $0x23
  80247f:	68 dc 44 80 00       	push   $0x8044dc
  802484:	e8 22 f5 ff ff       	call   8019ab <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  802489:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80248c:	5b                   	pop    %ebx
  80248d:	5e                   	pop    %esi
  80248e:	5f                   	pop    %edi
  80248f:	5d                   	pop    %ebp
  802490:	c3                   	ret    

00802491 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802491:	55                   	push   %ebp
  802492:	89 e5                	mov    %esp,%ebp
  802494:	57                   	push   %edi
  802495:	56                   	push   %esi
  802496:	53                   	push   %ebx
  802497:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80249a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80249f:	b8 06 00 00 00       	mov    $0x6,%eax
  8024a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8024aa:	89 df                	mov    %ebx,%edi
  8024ac:	89 de                	mov    %ebx,%esi
  8024ae:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024b0:	85 c0                	test   %eax,%eax
  8024b2:	7e 17                	jle    8024cb <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024b4:	83 ec 0c             	sub    $0xc,%esp
  8024b7:	50                   	push   %eax
  8024b8:	6a 06                	push   $0x6
  8024ba:	68 bf 44 80 00       	push   $0x8044bf
  8024bf:	6a 23                	push   $0x23
  8024c1:	68 dc 44 80 00       	push   $0x8044dc
  8024c6:	e8 e0 f4 ff ff       	call   8019ab <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8024cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024ce:	5b                   	pop    %ebx
  8024cf:	5e                   	pop    %esi
  8024d0:	5f                   	pop    %edi
  8024d1:	5d                   	pop    %ebp
  8024d2:	c3                   	ret    

008024d3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024d3:	55                   	push   %ebp
  8024d4:	89 e5                	mov    %esp,%ebp
  8024d6:	57                   	push   %edi
  8024d7:	56                   	push   %esi
  8024d8:	53                   	push   %ebx
  8024d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8024e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8024ec:	89 df                	mov    %ebx,%edi
  8024ee:	89 de                	mov    %ebx,%esi
  8024f0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024f2:	85 c0                	test   %eax,%eax
  8024f4:	7e 17                	jle    80250d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024f6:	83 ec 0c             	sub    $0xc,%esp
  8024f9:	50                   	push   %eax
  8024fa:	6a 08                	push   $0x8
  8024fc:	68 bf 44 80 00       	push   $0x8044bf
  802501:	6a 23                	push   $0x23
  802503:	68 dc 44 80 00       	push   $0x8044dc
  802508:	e8 9e f4 ff ff       	call   8019ab <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80250d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    

00802515 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802515:	55                   	push   %ebp
  802516:	89 e5                	mov    %esp,%ebp
  802518:	57                   	push   %edi
  802519:	56                   	push   %esi
  80251a:	53                   	push   %ebx
  80251b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80251e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802523:	b8 09 00 00 00       	mov    $0x9,%eax
  802528:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80252b:	8b 55 08             	mov    0x8(%ebp),%edx
  80252e:	89 df                	mov    %ebx,%edi
  802530:	89 de                	mov    %ebx,%esi
  802532:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802534:	85 c0                	test   %eax,%eax
  802536:	7e 17                	jle    80254f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802538:	83 ec 0c             	sub    $0xc,%esp
  80253b:	50                   	push   %eax
  80253c:	6a 09                	push   $0x9
  80253e:	68 bf 44 80 00       	push   $0x8044bf
  802543:	6a 23                	push   $0x23
  802545:	68 dc 44 80 00       	push   $0x8044dc
  80254a:	e8 5c f4 ff ff       	call   8019ab <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80254f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802552:	5b                   	pop    %ebx
  802553:	5e                   	pop    %esi
  802554:	5f                   	pop    %edi
  802555:	5d                   	pop    %ebp
  802556:	c3                   	ret    

00802557 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802557:	55                   	push   %ebp
  802558:	89 e5                	mov    %esp,%ebp
  80255a:	57                   	push   %edi
  80255b:	56                   	push   %esi
  80255c:	53                   	push   %ebx
  80255d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802560:	bb 00 00 00 00       	mov    $0x0,%ebx
  802565:	b8 0a 00 00 00       	mov    $0xa,%eax
  80256a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80256d:	8b 55 08             	mov    0x8(%ebp),%edx
  802570:	89 df                	mov    %ebx,%edi
  802572:	89 de                	mov    %ebx,%esi
  802574:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802576:	85 c0                	test   %eax,%eax
  802578:	7e 17                	jle    802591 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80257a:	83 ec 0c             	sub    $0xc,%esp
  80257d:	50                   	push   %eax
  80257e:	6a 0a                	push   $0xa
  802580:	68 bf 44 80 00       	push   $0x8044bf
  802585:	6a 23                	push   $0x23
  802587:	68 dc 44 80 00       	push   $0x8044dc
  80258c:	e8 1a f4 ff ff       	call   8019ab <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802591:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802594:	5b                   	pop    %ebx
  802595:	5e                   	pop    %esi
  802596:	5f                   	pop    %edi
  802597:	5d                   	pop    %ebp
  802598:	c3                   	ret    

00802599 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802599:	55                   	push   %ebp
  80259a:	89 e5                	mov    %esp,%ebp
  80259c:	57                   	push   %edi
  80259d:	56                   	push   %esi
  80259e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80259f:	be 00 00 00 00       	mov    $0x0,%esi
  8025a4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8025a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8025af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025b5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8025b7:	5b                   	pop    %ebx
  8025b8:	5e                   	pop    %esi
  8025b9:	5f                   	pop    %edi
  8025ba:	5d                   	pop    %ebp
  8025bb:	c3                   	ret    

008025bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8025bc:	55                   	push   %ebp
  8025bd:	89 e5                	mov    %esp,%ebp
  8025bf:	57                   	push   %edi
  8025c0:	56                   	push   %esi
  8025c1:	53                   	push   %ebx
  8025c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025ca:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8025d2:	89 cb                	mov    %ecx,%ebx
  8025d4:	89 cf                	mov    %ecx,%edi
  8025d6:	89 ce                	mov    %ecx,%esi
  8025d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025da:	85 c0                	test   %eax,%eax
  8025dc:	7e 17                	jle    8025f5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025de:	83 ec 0c             	sub    $0xc,%esp
  8025e1:	50                   	push   %eax
  8025e2:	6a 0d                	push   $0xd
  8025e4:	68 bf 44 80 00       	push   $0x8044bf
  8025e9:	6a 23                	push   $0x23
  8025eb:	68 dc 44 80 00       	push   $0x8044dc
  8025f0:	e8 b6 f3 ff ff       	call   8019ab <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8025f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025f8:	5b                   	pop    %ebx
  8025f9:	5e                   	pop    %esi
  8025fa:	5f                   	pop    %edi
  8025fb:	5d                   	pop    %ebp
  8025fc:	c3                   	ret    

008025fd <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8025fd:	55                   	push   %ebp
  8025fe:	89 e5                	mov    %esp,%ebp
  802600:	57                   	push   %edi
  802601:	56                   	push   %esi
  802602:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802603:	ba 00 00 00 00       	mov    $0x0,%edx
  802608:	b8 0e 00 00 00       	mov    $0xe,%eax
  80260d:	89 d1                	mov    %edx,%ecx
  80260f:	89 d3                	mov    %edx,%ebx
  802611:	89 d7                	mov    %edx,%edi
  802613:	89 d6                	mov    %edx,%esi
  802615:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  802617:	5b                   	pop    %ebx
  802618:	5e                   	pop    %esi
  802619:	5f                   	pop    %edi
  80261a:	5d                   	pop    %ebp
  80261b:	c3                   	ret    

0080261c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80261c:	55                   	push   %ebp
  80261d:	89 e5                	mov    %esp,%ebp
  80261f:	53                   	push   %ebx
  802620:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  802623:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  80262a:	75 28                	jne    802654 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  80262c:	e8 9d fd ff ff       	call   8023ce <sys_getenvid>
  802631:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  802633:	83 ec 04             	sub    $0x4,%esp
  802636:	6a 06                	push   $0x6
  802638:	68 00 f0 bf ee       	push   $0xeebff000
  80263d:	50                   	push   %eax
  80263e:	e8 c9 fd ff ff       	call   80240c <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  802643:	83 c4 08             	add    $0x8,%esp
  802646:	68 61 26 80 00       	push   $0x802661
  80264b:	53                   	push   %ebx
  80264c:	e8 06 ff ff ff       	call   802557 <sys_env_set_pgfault_upcall>
  802651:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802654:	8b 45 08             	mov    0x8(%ebp),%eax
  802657:	a3 14 a0 80 00       	mov    %eax,0x80a014
}
  80265c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80265f:	c9                   	leave  
  802660:	c3                   	ret    

00802661 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802661:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802662:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  802667:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802669:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  80266c:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  80266e:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  802671:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  802674:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802677:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  80267a:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  80267d:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  802680:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  802683:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802686:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802689:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  80268c:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  80268f:	61                   	popa   
	popfl
  802690:	9d                   	popf   
	ret
  802691:	c3                   	ret    

00802692 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802692:	55                   	push   %ebp
  802693:	89 e5                	mov    %esp,%ebp
  802695:	56                   	push   %esi
  802696:	53                   	push   %ebx
  802697:	8b 75 08             	mov    0x8(%ebp),%esi
  80269a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80269d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8026a0:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8026a2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8026a7:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8026aa:	83 ec 0c             	sub    $0xc,%esp
  8026ad:	50                   	push   %eax
  8026ae:	e8 09 ff ff ff       	call   8025bc <sys_ipc_recv>

	if (r < 0) {
  8026b3:	83 c4 10             	add    $0x10,%esp
  8026b6:	85 c0                	test   %eax,%eax
  8026b8:	79 16                	jns    8026d0 <ipc_recv+0x3e>
		if (from_env_store)
  8026ba:	85 f6                	test   %esi,%esi
  8026bc:	74 06                	je     8026c4 <ipc_recv+0x32>
			*from_env_store = 0;
  8026be:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8026c4:	85 db                	test   %ebx,%ebx
  8026c6:	74 2c                	je     8026f4 <ipc_recv+0x62>
			*perm_store = 0;
  8026c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8026ce:	eb 24                	jmp    8026f4 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8026d0:	85 f6                	test   %esi,%esi
  8026d2:	74 0a                	je     8026de <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8026d4:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8026d9:	8b 40 74             	mov    0x74(%eax),%eax
  8026dc:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8026de:	85 db                	test   %ebx,%ebx
  8026e0:	74 0a                	je     8026ec <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8026e2:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8026e7:	8b 40 78             	mov    0x78(%eax),%eax
  8026ea:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  8026ec:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8026f1:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8026f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8026f7:	5b                   	pop    %ebx
  8026f8:	5e                   	pop    %esi
  8026f9:	5d                   	pop    %ebp
  8026fa:	c3                   	ret    

008026fb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026fb:	55                   	push   %ebp
  8026fc:	89 e5                	mov    %esp,%ebp
  8026fe:	57                   	push   %edi
  8026ff:	56                   	push   %esi
  802700:	53                   	push   %ebx
  802701:	83 ec 0c             	sub    $0xc,%esp
  802704:	8b 7d 08             	mov    0x8(%ebp),%edi
  802707:	8b 75 0c             	mov    0xc(%ebp),%esi
  80270a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  80270d:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  80270f:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  802714:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  802717:	ff 75 14             	pushl  0x14(%ebp)
  80271a:	53                   	push   %ebx
  80271b:	56                   	push   %esi
  80271c:	57                   	push   %edi
  80271d:	e8 77 fe ff ff       	call   802599 <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  802722:	83 c4 10             	add    $0x10,%esp
  802725:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802728:	75 07                	jne    802731 <ipc_send+0x36>
			sys_yield();
  80272a:	e8 be fc ff ff       	call   8023ed <sys_yield>
  80272f:	eb e6                	jmp    802717 <ipc_send+0x1c>
		} else if (r < 0) {
  802731:	85 c0                	test   %eax,%eax
  802733:	79 12                	jns    802747 <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  802735:	50                   	push   %eax
  802736:	68 ea 44 80 00       	push   $0x8044ea
  80273b:	6a 51                	push   $0x51
  80273d:	68 f7 44 80 00       	push   $0x8044f7
  802742:	e8 64 f2 ff ff       	call   8019ab <_panic>
		}
	}
}
  802747:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80274a:	5b                   	pop    %ebx
  80274b:	5e                   	pop    %esi
  80274c:	5f                   	pop    %edi
  80274d:	5d                   	pop    %ebp
  80274e:	c3                   	ret    

0080274f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80274f:	55                   	push   %ebp
  802750:	89 e5                	mov    %esp,%ebp
  802752:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802755:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80275a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80275d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802763:	8b 52 50             	mov    0x50(%edx),%edx
  802766:	39 ca                	cmp    %ecx,%edx
  802768:	75 0d                	jne    802777 <ipc_find_env+0x28>
			return envs[i].env_id;
  80276a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80276d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802772:	8b 40 48             	mov    0x48(%eax),%eax
  802775:	eb 0f                	jmp    802786 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802777:	83 c0 01             	add    $0x1,%eax
  80277a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80277f:	75 d9                	jne    80275a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802781:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802786:	5d                   	pop    %ebp
  802787:	c3                   	ret    

00802788 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802788:	55                   	push   %ebp
  802789:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80278b:	8b 45 08             	mov    0x8(%ebp),%eax
  80278e:	05 00 00 00 30       	add    $0x30000000,%eax
  802793:	c1 e8 0c             	shr    $0xc,%eax
}
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    

00802798 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802798:	55                   	push   %ebp
  802799:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80279b:	8b 45 08             	mov    0x8(%ebp),%eax
  80279e:	05 00 00 00 30       	add    $0x30000000,%eax
  8027a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8027a8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8027ad:	5d                   	pop    %ebp
  8027ae:	c3                   	ret    

008027af <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8027af:	55                   	push   %ebp
  8027b0:	89 e5                	mov    %esp,%ebp
  8027b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027b5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8027ba:	89 c2                	mov    %eax,%edx
  8027bc:	c1 ea 16             	shr    $0x16,%edx
  8027bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8027c6:	f6 c2 01             	test   $0x1,%dl
  8027c9:	74 11                	je     8027dc <fd_alloc+0x2d>
  8027cb:	89 c2                	mov    %eax,%edx
  8027cd:	c1 ea 0c             	shr    $0xc,%edx
  8027d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8027d7:	f6 c2 01             	test   $0x1,%dl
  8027da:	75 09                	jne    8027e5 <fd_alloc+0x36>
			*fd_store = fd;
  8027dc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8027de:	b8 00 00 00 00       	mov    $0x0,%eax
  8027e3:	eb 17                	jmp    8027fc <fd_alloc+0x4d>
  8027e5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8027ea:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8027ef:	75 c9                	jne    8027ba <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8027f1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8027f7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8027fc:	5d                   	pop    %ebp
  8027fd:	c3                   	ret    

008027fe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8027fe:	55                   	push   %ebp
  8027ff:	89 e5                	mov    %esp,%ebp
  802801:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802804:	83 f8 1f             	cmp    $0x1f,%eax
  802807:	77 36                	ja     80283f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802809:	c1 e0 0c             	shl    $0xc,%eax
  80280c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802811:	89 c2                	mov    %eax,%edx
  802813:	c1 ea 16             	shr    $0x16,%edx
  802816:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80281d:	f6 c2 01             	test   $0x1,%dl
  802820:	74 24                	je     802846 <fd_lookup+0x48>
  802822:	89 c2                	mov    %eax,%edx
  802824:	c1 ea 0c             	shr    $0xc,%edx
  802827:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80282e:	f6 c2 01             	test   $0x1,%dl
  802831:	74 1a                	je     80284d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802833:	8b 55 0c             	mov    0xc(%ebp),%edx
  802836:	89 02                	mov    %eax,(%edx)
	return 0;
  802838:	b8 00 00 00 00       	mov    $0x0,%eax
  80283d:	eb 13                	jmp    802852 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80283f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802844:	eb 0c                	jmp    802852 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802846:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80284b:	eb 05                	jmp    802852 <fd_lookup+0x54>
  80284d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802852:	5d                   	pop    %ebp
  802853:	c3                   	ret    

00802854 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802854:	55                   	push   %ebp
  802855:	89 e5                	mov    %esp,%ebp
  802857:	83 ec 08             	sub    $0x8,%esp
  80285a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80285d:	ba 84 45 80 00       	mov    $0x804584,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  802862:	eb 13                	jmp    802877 <dev_lookup+0x23>
  802864:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802867:	39 08                	cmp    %ecx,(%eax)
  802869:	75 0c                	jne    802877 <dev_lookup+0x23>
			*dev = devtab[i];
  80286b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80286e:	89 01                	mov    %eax,(%ecx)
			return 0;
  802870:	b8 00 00 00 00       	mov    $0x0,%eax
  802875:	eb 2e                	jmp    8028a5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802877:	8b 02                	mov    (%edx),%eax
  802879:	85 c0                	test   %eax,%eax
  80287b:	75 e7                	jne    802864 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80287d:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802882:	8b 40 48             	mov    0x48(%eax),%eax
  802885:	83 ec 04             	sub    $0x4,%esp
  802888:	51                   	push   %ecx
  802889:	50                   	push   %eax
  80288a:	68 04 45 80 00       	push   $0x804504
  80288f:	e8 f0 f1 ff ff       	call   801a84 <cprintf>
	*dev = 0;
  802894:	8b 45 0c             	mov    0xc(%ebp),%eax
  802897:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80289d:	83 c4 10             	add    $0x10,%esp
  8028a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8028a5:	c9                   	leave  
  8028a6:	c3                   	ret    

008028a7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8028a7:	55                   	push   %ebp
  8028a8:	89 e5                	mov    %esp,%ebp
  8028aa:	56                   	push   %esi
  8028ab:	53                   	push   %ebx
  8028ac:	83 ec 10             	sub    $0x10,%esp
  8028af:	8b 75 08             	mov    0x8(%ebp),%esi
  8028b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8028b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028b8:	50                   	push   %eax
  8028b9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8028bf:	c1 e8 0c             	shr    $0xc,%eax
  8028c2:	50                   	push   %eax
  8028c3:	e8 36 ff ff ff       	call   8027fe <fd_lookup>
  8028c8:	83 c4 08             	add    $0x8,%esp
  8028cb:	85 c0                	test   %eax,%eax
  8028cd:	78 05                	js     8028d4 <fd_close+0x2d>
	    || fd != fd2)
  8028cf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8028d2:	74 0c                	je     8028e0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8028d4:	84 db                	test   %bl,%bl
  8028d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8028db:	0f 44 c2             	cmove  %edx,%eax
  8028de:	eb 41                	jmp    802921 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8028e0:	83 ec 08             	sub    $0x8,%esp
  8028e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028e6:	50                   	push   %eax
  8028e7:	ff 36                	pushl  (%esi)
  8028e9:	e8 66 ff ff ff       	call   802854 <dev_lookup>
  8028ee:	89 c3                	mov    %eax,%ebx
  8028f0:	83 c4 10             	add    $0x10,%esp
  8028f3:	85 c0                	test   %eax,%eax
  8028f5:	78 1a                	js     802911 <fd_close+0x6a>
		if (dev->dev_close)
  8028f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028fa:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8028fd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802902:	85 c0                	test   %eax,%eax
  802904:	74 0b                	je     802911 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802906:	83 ec 0c             	sub    $0xc,%esp
  802909:	56                   	push   %esi
  80290a:	ff d0                	call   *%eax
  80290c:	89 c3                	mov    %eax,%ebx
  80290e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802911:	83 ec 08             	sub    $0x8,%esp
  802914:	56                   	push   %esi
  802915:	6a 00                	push   $0x0
  802917:	e8 75 fb ff ff       	call   802491 <sys_page_unmap>
	return r;
  80291c:	83 c4 10             	add    $0x10,%esp
  80291f:	89 d8                	mov    %ebx,%eax
}
  802921:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802924:	5b                   	pop    %ebx
  802925:	5e                   	pop    %esi
  802926:	5d                   	pop    %ebp
  802927:	c3                   	ret    

00802928 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802928:	55                   	push   %ebp
  802929:	89 e5                	mov    %esp,%ebp
  80292b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80292e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802931:	50                   	push   %eax
  802932:	ff 75 08             	pushl  0x8(%ebp)
  802935:	e8 c4 fe ff ff       	call   8027fe <fd_lookup>
  80293a:	83 c4 08             	add    $0x8,%esp
  80293d:	85 c0                	test   %eax,%eax
  80293f:	78 10                	js     802951 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802941:	83 ec 08             	sub    $0x8,%esp
  802944:	6a 01                	push   $0x1
  802946:	ff 75 f4             	pushl  -0xc(%ebp)
  802949:	e8 59 ff ff ff       	call   8028a7 <fd_close>
  80294e:	83 c4 10             	add    $0x10,%esp
}
  802951:	c9                   	leave  
  802952:	c3                   	ret    

00802953 <close_all>:

void
close_all(void)
{
  802953:	55                   	push   %ebp
  802954:	89 e5                	mov    %esp,%ebp
  802956:	53                   	push   %ebx
  802957:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80295a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80295f:	83 ec 0c             	sub    $0xc,%esp
  802962:	53                   	push   %ebx
  802963:	e8 c0 ff ff ff       	call   802928 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802968:	83 c3 01             	add    $0x1,%ebx
  80296b:	83 c4 10             	add    $0x10,%esp
  80296e:	83 fb 20             	cmp    $0x20,%ebx
  802971:	75 ec                	jne    80295f <close_all+0xc>
		close(i);
}
  802973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802976:	c9                   	leave  
  802977:	c3                   	ret    

00802978 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802978:	55                   	push   %ebp
  802979:	89 e5                	mov    %esp,%ebp
  80297b:	57                   	push   %edi
  80297c:	56                   	push   %esi
  80297d:	53                   	push   %ebx
  80297e:	83 ec 2c             	sub    $0x2c,%esp
  802981:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802984:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802987:	50                   	push   %eax
  802988:	ff 75 08             	pushl  0x8(%ebp)
  80298b:	e8 6e fe ff ff       	call   8027fe <fd_lookup>
  802990:	83 c4 08             	add    $0x8,%esp
  802993:	85 c0                	test   %eax,%eax
  802995:	0f 88 c1 00 00 00    	js     802a5c <dup+0xe4>
		return r;
	close(newfdnum);
  80299b:	83 ec 0c             	sub    $0xc,%esp
  80299e:	56                   	push   %esi
  80299f:	e8 84 ff ff ff       	call   802928 <close>

	newfd = INDEX2FD(newfdnum);
  8029a4:	89 f3                	mov    %esi,%ebx
  8029a6:	c1 e3 0c             	shl    $0xc,%ebx
  8029a9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8029af:	83 c4 04             	add    $0x4,%esp
  8029b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8029b5:	e8 de fd ff ff       	call   802798 <fd2data>
  8029ba:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8029bc:	89 1c 24             	mov    %ebx,(%esp)
  8029bf:	e8 d4 fd ff ff       	call   802798 <fd2data>
  8029c4:	83 c4 10             	add    $0x10,%esp
  8029c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8029ca:	89 f8                	mov    %edi,%eax
  8029cc:	c1 e8 16             	shr    $0x16,%eax
  8029cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029d6:	a8 01                	test   $0x1,%al
  8029d8:	74 37                	je     802a11 <dup+0x99>
  8029da:	89 f8                	mov    %edi,%eax
  8029dc:	c1 e8 0c             	shr    $0xc,%eax
  8029df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029e6:	f6 c2 01             	test   $0x1,%dl
  8029e9:	74 26                	je     802a11 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8029eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8029f2:	83 ec 0c             	sub    $0xc,%esp
  8029f5:	25 07 0e 00 00       	and    $0xe07,%eax
  8029fa:	50                   	push   %eax
  8029fb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8029fe:	6a 00                	push   $0x0
  802a00:	57                   	push   %edi
  802a01:	6a 00                	push   $0x0
  802a03:	e8 47 fa ff ff       	call   80244f <sys_page_map>
  802a08:	89 c7                	mov    %eax,%edi
  802a0a:	83 c4 20             	add    $0x20,%esp
  802a0d:	85 c0                	test   %eax,%eax
  802a0f:	78 2e                	js     802a3f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a11:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802a14:	89 d0                	mov    %edx,%eax
  802a16:	c1 e8 0c             	shr    $0xc,%eax
  802a19:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a20:	83 ec 0c             	sub    $0xc,%esp
  802a23:	25 07 0e 00 00       	and    $0xe07,%eax
  802a28:	50                   	push   %eax
  802a29:	53                   	push   %ebx
  802a2a:	6a 00                	push   $0x0
  802a2c:	52                   	push   %edx
  802a2d:	6a 00                	push   $0x0
  802a2f:	e8 1b fa ff ff       	call   80244f <sys_page_map>
  802a34:	89 c7                	mov    %eax,%edi
  802a36:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802a39:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a3b:	85 ff                	test   %edi,%edi
  802a3d:	79 1d                	jns    802a5c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802a3f:	83 ec 08             	sub    $0x8,%esp
  802a42:	53                   	push   %ebx
  802a43:	6a 00                	push   $0x0
  802a45:	e8 47 fa ff ff       	call   802491 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802a4a:	83 c4 08             	add    $0x8,%esp
  802a4d:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a50:	6a 00                	push   $0x0
  802a52:	e8 3a fa ff ff       	call   802491 <sys_page_unmap>
	return r;
  802a57:	83 c4 10             	add    $0x10,%esp
  802a5a:	89 f8                	mov    %edi,%eax
}
  802a5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a5f:	5b                   	pop    %ebx
  802a60:	5e                   	pop    %esi
  802a61:	5f                   	pop    %edi
  802a62:	5d                   	pop    %ebp
  802a63:	c3                   	ret    

00802a64 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802a64:	55                   	push   %ebp
  802a65:	89 e5                	mov    %esp,%ebp
  802a67:	53                   	push   %ebx
  802a68:	83 ec 14             	sub    $0x14,%esp
  802a6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802a6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a71:	50                   	push   %eax
  802a72:	53                   	push   %ebx
  802a73:	e8 86 fd ff ff       	call   8027fe <fd_lookup>
  802a78:	83 c4 08             	add    $0x8,%esp
  802a7b:	89 c2                	mov    %eax,%edx
  802a7d:	85 c0                	test   %eax,%eax
  802a7f:	78 6d                	js     802aee <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802a81:	83 ec 08             	sub    $0x8,%esp
  802a84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a87:	50                   	push   %eax
  802a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a8b:	ff 30                	pushl  (%eax)
  802a8d:	e8 c2 fd ff ff       	call   802854 <dev_lookup>
  802a92:	83 c4 10             	add    $0x10,%esp
  802a95:	85 c0                	test   %eax,%eax
  802a97:	78 4c                	js     802ae5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802a99:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a9c:	8b 42 08             	mov    0x8(%edx),%eax
  802a9f:	83 e0 03             	and    $0x3,%eax
  802aa2:	83 f8 01             	cmp    $0x1,%eax
  802aa5:	75 21                	jne    802ac8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802aa7:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802aac:	8b 40 48             	mov    0x48(%eax),%eax
  802aaf:	83 ec 04             	sub    $0x4,%esp
  802ab2:	53                   	push   %ebx
  802ab3:	50                   	push   %eax
  802ab4:	68 48 45 80 00       	push   $0x804548
  802ab9:	e8 c6 ef ff ff       	call   801a84 <cprintf>
		return -E_INVAL;
  802abe:	83 c4 10             	add    $0x10,%esp
  802ac1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802ac6:	eb 26                	jmp    802aee <read+0x8a>
	}
	if (!dev->dev_read)
  802ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802acb:	8b 40 08             	mov    0x8(%eax),%eax
  802ace:	85 c0                	test   %eax,%eax
  802ad0:	74 17                	je     802ae9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802ad2:	83 ec 04             	sub    $0x4,%esp
  802ad5:	ff 75 10             	pushl  0x10(%ebp)
  802ad8:	ff 75 0c             	pushl  0xc(%ebp)
  802adb:	52                   	push   %edx
  802adc:	ff d0                	call   *%eax
  802ade:	89 c2                	mov    %eax,%edx
  802ae0:	83 c4 10             	add    $0x10,%esp
  802ae3:	eb 09                	jmp    802aee <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ae5:	89 c2                	mov    %eax,%edx
  802ae7:	eb 05                	jmp    802aee <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802ae9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802aee:	89 d0                	mov    %edx,%eax
  802af0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802af3:	c9                   	leave  
  802af4:	c3                   	ret    

00802af5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802af5:	55                   	push   %ebp
  802af6:	89 e5                	mov    %esp,%ebp
  802af8:	57                   	push   %edi
  802af9:	56                   	push   %esi
  802afa:	53                   	push   %ebx
  802afb:	83 ec 0c             	sub    $0xc,%esp
  802afe:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b01:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b04:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b09:	eb 21                	jmp    802b2c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802b0b:	83 ec 04             	sub    $0x4,%esp
  802b0e:	89 f0                	mov    %esi,%eax
  802b10:	29 d8                	sub    %ebx,%eax
  802b12:	50                   	push   %eax
  802b13:	89 d8                	mov    %ebx,%eax
  802b15:	03 45 0c             	add    0xc(%ebp),%eax
  802b18:	50                   	push   %eax
  802b19:	57                   	push   %edi
  802b1a:	e8 45 ff ff ff       	call   802a64 <read>
		if (m < 0)
  802b1f:	83 c4 10             	add    $0x10,%esp
  802b22:	85 c0                	test   %eax,%eax
  802b24:	78 10                	js     802b36 <readn+0x41>
			return m;
		if (m == 0)
  802b26:	85 c0                	test   %eax,%eax
  802b28:	74 0a                	je     802b34 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b2a:	01 c3                	add    %eax,%ebx
  802b2c:	39 f3                	cmp    %esi,%ebx
  802b2e:	72 db                	jb     802b0b <readn+0x16>
  802b30:	89 d8                	mov    %ebx,%eax
  802b32:	eb 02                	jmp    802b36 <readn+0x41>
  802b34:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b39:	5b                   	pop    %ebx
  802b3a:	5e                   	pop    %esi
  802b3b:	5f                   	pop    %edi
  802b3c:	5d                   	pop    %ebp
  802b3d:	c3                   	ret    

00802b3e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802b3e:	55                   	push   %ebp
  802b3f:	89 e5                	mov    %esp,%ebp
  802b41:	53                   	push   %ebx
  802b42:	83 ec 14             	sub    $0x14,%esp
  802b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b4b:	50                   	push   %eax
  802b4c:	53                   	push   %ebx
  802b4d:	e8 ac fc ff ff       	call   8027fe <fd_lookup>
  802b52:	83 c4 08             	add    $0x8,%esp
  802b55:	89 c2                	mov    %eax,%edx
  802b57:	85 c0                	test   %eax,%eax
  802b59:	78 68                	js     802bc3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b5b:	83 ec 08             	sub    $0x8,%esp
  802b5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b61:	50                   	push   %eax
  802b62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b65:	ff 30                	pushl  (%eax)
  802b67:	e8 e8 fc ff ff       	call   802854 <dev_lookup>
  802b6c:	83 c4 10             	add    $0x10,%esp
  802b6f:	85 c0                	test   %eax,%eax
  802b71:	78 47                	js     802bba <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b76:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802b7a:	75 21                	jne    802b9d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802b7c:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802b81:	8b 40 48             	mov    0x48(%eax),%eax
  802b84:	83 ec 04             	sub    $0x4,%esp
  802b87:	53                   	push   %ebx
  802b88:	50                   	push   %eax
  802b89:	68 64 45 80 00       	push   $0x804564
  802b8e:	e8 f1 ee ff ff       	call   801a84 <cprintf>
		return -E_INVAL;
  802b93:	83 c4 10             	add    $0x10,%esp
  802b96:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802b9b:	eb 26                	jmp    802bc3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802b9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ba0:	8b 52 0c             	mov    0xc(%edx),%edx
  802ba3:	85 d2                	test   %edx,%edx
  802ba5:	74 17                	je     802bbe <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802ba7:	83 ec 04             	sub    $0x4,%esp
  802baa:	ff 75 10             	pushl  0x10(%ebp)
  802bad:	ff 75 0c             	pushl  0xc(%ebp)
  802bb0:	50                   	push   %eax
  802bb1:	ff d2                	call   *%edx
  802bb3:	89 c2                	mov    %eax,%edx
  802bb5:	83 c4 10             	add    $0x10,%esp
  802bb8:	eb 09                	jmp    802bc3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bba:	89 c2                	mov    %eax,%edx
  802bbc:	eb 05                	jmp    802bc3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802bbe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802bc3:	89 d0                	mov    %edx,%eax
  802bc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802bc8:	c9                   	leave  
  802bc9:	c3                   	ret    

00802bca <seek>:

int
seek(int fdnum, off_t offset)
{
  802bca:	55                   	push   %ebp
  802bcb:	89 e5                	mov    %esp,%ebp
  802bcd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802bd0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802bd3:	50                   	push   %eax
  802bd4:	ff 75 08             	pushl  0x8(%ebp)
  802bd7:	e8 22 fc ff ff       	call   8027fe <fd_lookup>
  802bdc:	83 c4 08             	add    $0x8,%esp
  802bdf:	85 c0                	test   %eax,%eax
  802be1:	78 0e                	js     802bf1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802be3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802be6:	8b 55 0c             	mov    0xc(%ebp),%edx
  802be9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802bec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802bf1:	c9                   	leave  
  802bf2:	c3                   	ret    

00802bf3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802bf3:	55                   	push   %ebp
  802bf4:	89 e5                	mov    %esp,%ebp
  802bf6:	53                   	push   %ebx
  802bf7:	83 ec 14             	sub    $0x14,%esp
  802bfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802bfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c00:	50                   	push   %eax
  802c01:	53                   	push   %ebx
  802c02:	e8 f7 fb ff ff       	call   8027fe <fd_lookup>
  802c07:	83 c4 08             	add    $0x8,%esp
  802c0a:	89 c2                	mov    %eax,%edx
  802c0c:	85 c0                	test   %eax,%eax
  802c0e:	78 65                	js     802c75 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c10:	83 ec 08             	sub    $0x8,%esp
  802c13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c16:	50                   	push   %eax
  802c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c1a:	ff 30                	pushl  (%eax)
  802c1c:	e8 33 fc ff ff       	call   802854 <dev_lookup>
  802c21:	83 c4 10             	add    $0x10,%esp
  802c24:	85 c0                	test   %eax,%eax
  802c26:	78 44                	js     802c6c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c2b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c2f:	75 21                	jne    802c52 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802c31:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802c36:	8b 40 48             	mov    0x48(%eax),%eax
  802c39:	83 ec 04             	sub    $0x4,%esp
  802c3c:	53                   	push   %ebx
  802c3d:	50                   	push   %eax
  802c3e:	68 24 45 80 00       	push   $0x804524
  802c43:	e8 3c ee ff ff       	call   801a84 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802c48:	83 c4 10             	add    $0x10,%esp
  802c4b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c50:	eb 23                	jmp    802c75 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802c52:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c55:	8b 52 18             	mov    0x18(%edx),%edx
  802c58:	85 d2                	test   %edx,%edx
  802c5a:	74 14                	je     802c70 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802c5c:	83 ec 08             	sub    $0x8,%esp
  802c5f:	ff 75 0c             	pushl  0xc(%ebp)
  802c62:	50                   	push   %eax
  802c63:	ff d2                	call   *%edx
  802c65:	89 c2                	mov    %eax,%edx
  802c67:	83 c4 10             	add    $0x10,%esp
  802c6a:	eb 09                	jmp    802c75 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c6c:	89 c2                	mov    %eax,%edx
  802c6e:	eb 05                	jmp    802c75 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802c70:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802c75:	89 d0                	mov    %edx,%eax
  802c77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c7a:	c9                   	leave  
  802c7b:	c3                   	ret    

00802c7c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802c7c:	55                   	push   %ebp
  802c7d:	89 e5                	mov    %esp,%ebp
  802c7f:	53                   	push   %ebx
  802c80:	83 ec 14             	sub    $0x14,%esp
  802c83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c89:	50                   	push   %eax
  802c8a:	ff 75 08             	pushl  0x8(%ebp)
  802c8d:	e8 6c fb ff ff       	call   8027fe <fd_lookup>
  802c92:	83 c4 08             	add    $0x8,%esp
  802c95:	89 c2                	mov    %eax,%edx
  802c97:	85 c0                	test   %eax,%eax
  802c99:	78 58                	js     802cf3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c9b:	83 ec 08             	sub    $0x8,%esp
  802c9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ca1:	50                   	push   %eax
  802ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ca5:	ff 30                	pushl  (%eax)
  802ca7:	e8 a8 fb ff ff       	call   802854 <dev_lookup>
  802cac:	83 c4 10             	add    $0x10,%esp
  802caf:	85 c0                	test   %eax,%eax
  802cb1:	78 37                	js     802cea <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cb6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802cba:	74 32                	je     802cee <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802cbc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802cbf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802cc6:	00 00 00 
	stat->st_isdir = 0;
  802cc9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802cd0:	00 00 00 
	stat->st_dev = dev;
  802cd3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802cd9:	83 ec 08             	sub    $0x8,%esp
  802cdc:	53                   	push   %ebx
  802cdd:	ff 75 f0             	pushl  -0x10(%ebp)
  802ce0:	ff 50 14             	call   *0x14(%eax)
  802ce3:	89 c2                	mov    %eax,%edx
  802ce5:	83 c4 10             	add    $0x10,%esp
  802ce8:	eb 09                	jmp    802cf3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cea:	89 c2                	mov    %eax,%edx
  802cec:	eb 05                	jmp    802cf3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802cee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802cf3:	89 d0                	mov    %edx,%eax
  802cf5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802cf8:	c9                   	leave  
  802cf9:	c3                   	ret    

00802cfa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802cfa:	55                   	push   %ebp
  802cfb:	89 e5                	mov    %esp,%ebp
  802cfd:	56                   	push   %esi
  802cfe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802cff:	83 ec 08             	sub    $0x8,%esp
  802d02:	6a 00                	push   $0x0
  802d04:	ff 75 08             	pushl  0x8(%ebp)
  802d07:	e8 0c 02 00 00       	call   802f18 <open>
  802d0c:	89 c3                	mov    %eax,%ebx
  802d0e:	83 c4 10             	add    $0x10,%esp
  802d11:	85 c0                	test   %eax,%eax
  802d13:	78 1b                	js     802d30 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802d15:	83 ec 08             	sub    $0x8,%esp
  802d18:	ff 75 0c             	pushl  0xc(%ebp)
  802d1b:	50                   	push   %eax
  802d1c:	e8 5b ff ff ff       	call   802c7c <fstat>
  802d21:	89 c6                	mov    %eax,%esi
	close(fd);
  802d23:	89 1c 24             	mov    %ebx,(%esp)
  802d26:	e8 fd fb ff ff       	call   802928 <close>
	return r;
  802d2b:	83 c4 10             	add    $0x10,%esp
  802d2e:	89 f0                	mov    %esi,%eax
}
  802d30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d33:	5b                   	pop    %ebx
  802d34:	5e                   	pop    %esi
  802d35:	5d                   	pop    %ebp
  802d36:	c3                   	ret    

00802d37 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802d37:	55                   	push   %ebp
  802d38:	89 e5                	mov    %esp,%ebp
  802d3a:	56                   	push   %esi
  802d3b:	53                   	push   %ebx
  802d3c:	89 c6                	mov    %eax,%esi
  802d3e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802d40:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802d47:	75 12                	jne    802d5b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802d49:	83 ec 0c             	sub    $0xc,%esp
  802d4c:	6a 01                	push   $0x1
  802d4e:	e8 fc f9 ff ff       	call   80274f <ipc_find_env>
  802d53:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802d58:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802d5b:	6a 07                	push   $0x7
  802d5d:	68 00 b0 80 00       	push   $0x80b000
  802d62:	56                   	push   %esi
  802d63:	ff 35 00 a0 80 00    	pushl  0x80a000
  802d69:	e8 8d f9 ff ff       	call   8026fb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802d6e:	83 c4 0c             	add    $0xc,%esp
  802d71:	6a 00                	push   $0x0
  802d73:	53                   	push   %ebx
  802d74:	6a 00                	push   $0x0
  802d76:	e8 17 f9 ff ff       	call   802692 <ipc_recv>
}
  802d7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d7e:	5b                   	pop    %ebx
  802d7f:	5e                   	pop    %esi
  802d80:	5d                   	pop    %ebp
  802d81:	c3                   	ret    

00802d82 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802d82:	55                   	push   %ebp
  802d83:	89 e5                	mov    %esp,%ebp
  802d85:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802d88:	8b 45 08             	mov    0x8(%ebp),%eax
  802d8b:	8b 40 0c             	mov    0xc(%eax),%eax
  802d8e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802d93:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d96:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  802da0:	b8 02 00 00 00       	mov    $0x2,%eax
  802da5:	e8 8d ff ff ff       	call   802d37 <fsipc>
}
  802daa:	c9                   	leave  
  802dab:	c3                   	ret    

00802dac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802dac:	55                   	push   %ebp
  802dad:	89 e5                	mov    %esp,%ebp
  802daf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802db2:	8b 45 08             	mov    0x8(%ebp),%eax
  802db5:	8b 40 0c             	mov    0xc(%eax),%eax
  802db8:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802dbd:	ba 00 00 00 00       	mov    $0x0,%edx
  802dc2:	b8 06 00 00 00       	mov    $0x6,%eax
  802dc7:	e8 6b ff ff ff       	call   802d37 <fsipc>
}
  802dcc:	c9                   	leave  
  802dcd:	c3                   	ret    

00802dce <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802dce:	55                   	push   %ebp
  802dcf:	89 e5                	mov    %esp,%ebp
  802dd1:	53                   	push   %ebx
  802dd2:	83 ec 04             	sub    $0x4,%esp
  802dd5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  802ddb:	8b 40 0c             	mov    0xc(%eax),%eax
  802dde:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802de3:	ba 00 00 00 00       	mov    $0x0,%edx
  802de8:	b8 05 00 00 00       	mov    $0x5,%eax
  802ded:	e8 45 ff ff ff       	call   802d37 <fsipc>
  802df2:	85 c0                	test   %eax,%eax
  802df4:	78 2c                	js     802e22 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802df6:	83 ec 08             	sub    $0x8,%esp
  802df9:	68 00 b0 80 00       	push   $0x80b000
  802dfe:	53                   	push   %ebx
  802dff:	e8 05 f2 ff ff       	call   802009 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802e04:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802e09:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802e0f:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802e14:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802e1a:	83 c4 10             	add    $0x10,%esp
  802e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e25:	c9                   	leave  
  802e26:	c3                   	ret    

00802e27 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802e27:	55                   	push   %ebp
  802e28:	89 e5                	mov    %esp,%ebp
  802e2a:	53                   	push   %ebx
  802e2b:	83 ec 08             	sub    $0x8,%esp
  802e2e:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802e31:	8b 55 08             	mov    0x8(%ebp),%edx
  802e34:	8b 52 0c             	mov    0xc(%edx),%edx
  802e37:	89 15 00 b0 80 00    	mov    %edx,0x80b000
  802e3d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802e42:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  802e47:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  802e4a:	89 1d 04 b0 80 00    	mov    %ebx,0x80b004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  802e50:	53                   	push   %ebx
  802e51:	ff 75 0c             	pushl  0xc(%ebp)
  802e54:	68 08 b0 80 00       	push   $0x80b008
  802e59:	e8 3d f3 ff ff       	call   80219b <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  802e5e:	ba 00 00 00 00       	mov    $0x0,%edx
  802e63:	b8 04 00 00 00       	mov    $0x4,%eax
  802e68:	e8 ca fe ff ff       	call   802d37 <fsipc>
  802e6d:	83 c4 10             	add    $0x10,%esp
  802e70:	85 c0                	test   %eax,%eax
  802e72:	78 1d                	js     802e91 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  802e74:	39 d8                	cmp    %ebx,%eax
  802e76:	76 19                	jbe    802e91 <devfile_write+0x6a>
  802e78:	68 98 45 80 00       	push   $0x804598
  802e7d:	68 1d 3c 80 00       	push   $0x803c1d
  802e82:	68 a3 00 00 00       	push   $0xa3
  802e87:	68 a4 45 80 00       	push   $0x8045a4
  802e8c:	e8 1a eb ff ff       	call   8019ab <_panic>
	return r;
}
  802e91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e94:	c9                   	leave  
  802e95:	c3                   	ret    

00802e96 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802e96:	55                   	push   %ebp
  802e97:	89 e5                	mov    %esp,%ebp
  802e99:	56                   	push   %esi
  802e9a:	53                   	push   %ebx
  802e9b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  802ea1:	8b 40 0c             	mov    0xc(%eax),%eax
  802ea4:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802ea9:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802eaf:	ba 00 00 00 00       	mov    $0x0,%edx
  802eb4:	b8 03 00 00 00       	mov    $0x3,%eax
  802eb9:	e8 79 fe ff ff       	call   802d37 <fsipc>
  802ebe:	89 c3                	mov    %eax,%ebx
  802ec0:	85 c0                	test   %eax,%eax
  802ec2:	78 4b                	js     802f0f <devfile_read+0x79>
		return r;
	assert(r <= n);
  802ec4:	39 c6                	cmp    %eax,%esi
  802ec6:	73 16                	jae    802ede <devfile_read+0x48>
  802ec8:	68 af 45 80 00       	push   $0x8045af
  802ecd:	68 1d 3c 80 00       	push   $0x803c1d
  802ed2:	6a 7c                	push   $0x7c
  802ed4:	68 a4 45 80 00       	push   $0x8045a4
  802ed9:	e8 cd ea ff ff       	call   8019ab <_panic>
	assert(r <= PGSIZE);
  802ede:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802ee3:	7e 16                	jle    802efb <devfile_read+0x65>
  802ee5:	68 b6 45 80 00       	push   $0x8045b6
  802eea:	68 1d 3c 80 00       	push   $0x803c1d
  802eef:	6a 7d                	push   $0x7d
  802ef1:	68 a4 45 80 00       	push   $0x8045a4
  802ef6:	e8 b0 ea ff ff       	call   8019ab <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802efb:	83 ec 04             	sub    $0x4,%esp
  802efe:	50                   	push   %eax
  802eff:	68 00 b0 80 00       	push   $0x80b000
  802f04:	ff 75 0c             	pushl  0xc(%ebp)
  802f07:	e8 8f f2 ff ff       	call   80219b <memmove>
	return r;
  802f0c:	83 c4 10             	add    $0x10,%esp
}
  802f0f:	89 d8                	mov    %ebx,%eax
  802f11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f14:	5b                   	pop    %ebx
  802f15:	5e                   	pop    %esi
  802f16:	5d                   	pop    %ebp
  802f17:	c3                   	ret    

00802f18 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802f18:	55                   	push   %ebp
  802f19:	89 e5                	mov    %esp,%ebp
  802f1b:	53                   	push   %ebx
  802f1c:	83 ec 20             	sub    $0x20,%esp
  802f1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802f22:	53                   	push   %ebx
  802f23:	e8 a8 f0 ff ff       	call   801fd0 <strlen>
  802f28:	83 c4 10             	add    $0x10,%esp
  802f2b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802f30:	7f 67                	jg     802f99 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f32:	83 ec 0c             	sub    $0xc,%esp
  802f35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f38:	50                   	push   %eax
  802f39:	e8 71 f8 ff ff       	call   8027af <fd_alloc>
  802f3e:	83 c4 10             	add    $0x10,%esp
		return r;
  802f41:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f43:	85 c0                	test   %eax,%eax
  802f45:	78 57                	js     802f9e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802f47:	83 ec 08             	sub    $0x8,%esp
  802f4a:	53                   	push   %ebx
  802f4b:	68 00 b0 80 00       	push   $0x80b000
  802f50:	e8 b4 f0 ff ff       	call   802009 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802f55:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f58:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802f5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f60:	b8 01 00 00 00       	mov    $0x1,%eax
  802f65:	e8 cd fd ff ff       	call   802d37 <fsipc>
  802f6a:	89 c3                	mov    %eax,%ebx
  802f6c:	83 c4 10             	add    $0x10,%esp
  802f6f:	85 c0                	test   %eax,%eax
  802f71:	79 14                	jns    802f87 <open+0x6f>
		fd_close(fd, 0);
  802f73:	83 ec 08             	sub    $0x8,%esp
  802f76:	6a 00                	push   $0x0
  802f78:	ff 75 f4             	pushl  -0xc(%ebp)
  802f7b:	e8 27 f9 ff ff       	call   8028a7 <fd_close>
		return r;
  802f80:	83 c4 10             	add    $0x10,%esp
  802f83:	89 da                	mov    %ebx,%edx
  802f85:	eb 17                	jmp    802f9e <open+0x86>
	}

	return fd2num(fd);
  802f87:	83 ec 0c             	sub    $0xc,%esp
  802f8a:	ff 75 f4             	pushl  -0xc(%ebp)
  802f8d:	e8 f6 f7 ff ff       	call   802788 <fd2num>
  802f92:	89 c2                	mov    %eax,%edx
  802f94:	83 c4 10             	add    $0x10,%esp
  802f97:	eb 05                	jmp    802f9e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802f99:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802f9e:	89 d0                	mov    %edx,%eax
  802fa0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fa3:	c9                   	leave  
  802fa4:	c3                   	ret    

00802fa5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802fa5:	55                   	push   %ebp
  802fa6:	89 e5                	mov    %esp,%ebp
  802fa8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802fab:	ba 00 00 00 00       	mov    $0x0,%edx
  802fb0:	b8 08 00 00 00       	mov    $0x8,%eax
  802fb5:	e8 7d fd ff ff       	call   802d37 <fsipc>
}
  802fba:	c9                   	leave  
  802fbb:	c3                   	ret    

00802fbc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802fbc:	55                   	push   %ebp
  802fbd:	89 e5                	mov    %esp,%ebp
  802fbf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fc2:	89 d0                	mov    %edx,%eax
  802fc4:	c1 e8 16             	shr    $0x16,%eax
  802fc7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802fce:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fd3:	f6 c1 01             	test   $0x1,%cl
  802fd6:	74 1d                	je     802ff5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802fd8:	c1 ea 0c             	shr    $0xc,%edx
  802fdb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802fe2:	f6 c2 01             	test   $0x1,%dl
  802fe5:	74 0e                	je     802ff5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802fe7:	c1 ea 0c             	shr    $0xc,%edx
  802fea:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802ff1:	ef 
  802ff2:	0f b7 c0             	movzwl %ax,%eax
}
  802ff5:	5d                   	pop    %ebp
  802ff6:	c3                   	ret    

00802ff7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802ff7:	55                   	push   %ebp
  802ff8:	89 e5                	mov    %esp,%ebp
  802ffa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802ffd:	68 c2 45 80 00       	push   $0x8045c2
  803002:	ff 75 0c             	pushl  0xc(%ebp)
  803005:	e8 ff ef ff ff       	call   802009 <strcpy>
	return 0;
}
  80300a:	b8 00 00 00 00       	mov    $0x0,%eax
  80300f:	c9                   	leave  
  803010:	c3                   	ret    

00803011 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  803011:	55                   	push   %ebp
  803012:	89 e5                	mov    %esp,%ebp
  803014:	53                   	push   %ebx
  803015:	83 ec 10             	sub    $0x10,%esp
  803018:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80301b:	53                   	push   %ebx
  80301c:	e8 9b ff ff ff       	call   802fbc <pageref>
  803021:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  803024:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  803029:	83 f8 01             	cmp    $0x1,%eax
  80302c:	75 10                	jne    80303e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  80302e:	83 ec 0c             	sub    $0xc,%esp
  803031:	ff 73 0c             	pushl  0xc(%ebx)
  803034:	e8 c0 02 00 00       	call   8032f9 <nsipc_close>
  803039:	89 c2                	mov    %eax,%edx
  80303b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  80303e:	89 d0                	mov    %edx,%eax
  803040:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803043:	c9                   	leave  
  803044:	c3                   	ret    

00803045 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  803045:	55                   	push   %ebp
  803046:	89 e5                	mov    %esp,%ebp
  803048:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80304b:	6a 00                	push   $0x0
  80304d:	ff 75 10             	pushl  0x10(%ebp)
  803050:	ff 75 0c             	pushl  0xc(%ebp)
  803053:	8b 45 08             	mov    0x8(%ebp),%eax
  803056:	ff 70 0c             	pushl  0xc(%eax)
  803059:	e8 78 03 00 00       	call   8033d6 <nsipc_send>
}
  80305e:	c9                   	leave  
  80305f:	c3                   	ret    

00803060 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  803060:	55                   	push   %ebp
  803061:	89 e5                	mov    %esp,%ebp
  803063:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  803066:	6a 00                	push   $0x0
  803068:	ff 75 10             	pushl  0x10(%ebp)
  80306b:	ff 75 0c             	pushl  0xc(%ebp)
  80306e:	8b 45 08             	mov    0x8(%ebp),%eax
  803071:	ff 70 0c             	pushl  0xc(%eax)
  803074:	e8 f1 02 00 00       	call   80336a <nsipc_recv>
}
  803079:	c9                   	leave  
  80307a:	c3                   	ret    

0080307b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80307b:	55                   	push   %ebp
  80307c:	89 e5                	mov    %esp,%ebp
  80307e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  803081:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803084:	52                   	push   %edx
  803085:	50                   	push   %eax
  803086:	e8 73 f7 ff ff       	call   8027fe <fd_lookup>
  80308b:	83 c4 10             	add    $0x10,%esp
  80308e:	85 c0                	test   %eax,%eax
  803090:	78 17                	js     8030a9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  803092:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803095:	8b 0d 80 90 80 00    	mov    0x809080,%ecx
  80309b:	39 08                	cmp    %ecx,(%eax)
  80309d:	75 05                	jne    8030a4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80309f:	8b 40 0c             	mov    0xc(%eax),%eax
  8030a2:	eb 05                	jmp    8030a9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8030a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8030a9:	c9                   	leave  
  8030aa:	c3                   	ret    

008030ab <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8030ab:	55                   	push   %ebp
  8030ac:	89 e5                	mov    %esp,%ebp
  8030ae:	56                   	push   %esi
  8030af:	53                   	push   %ebx
  8030b0:	83 ec 1c             	sub    $0x1c,%esp
  8030b3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8030b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030b8:	50                   	push   %eax
  8030b9:	e8 f1 f6 ff ff       	call   8027af <fd_alloc>
  8030be:	89 c3                	mov    %eax,%ebx
  8030c0:	83 c4 10             	add    $0x10,%esp
  8030c3:	85 c0                	test   %eax,%eax
  8030c5:	78 1b                	js     8030e2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8030c7:	83 ec 04             	sub    $0x4,%esp
  8030ca:	68 07 04 00 00       	push   $0x407
  8030cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8030d2:	6a 00                	push   $0x0
  8030d4:	e8 33 f3 ff ff       	call   80240c <sys_page_alloc>
  8030d9:	89 c3                	mov    %eax,%ebx
  8030db:	83 c4 10             	add    $0x10,%esp
  8030de:	85 c0                	test   %eax,%eax
  8030e0:	79 10                	jns    8030f2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8030e2:	83 ec 0c             	sub    $0xc,%esp
  8030e5:	56                   	push   %esi
  8030e6:	e8 0e 02 00 00       	call   8032f9 <nsipc_close>
		return r;
  8030eb:	83 c4 10             	add    $0x10,%esp
  8030ee:	89 d8                	mov    %ebx,%eax
  8030f0:	eb 24                	jmp    803116 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8030f2:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8030f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030fb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8030fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803100:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  803107:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80310a:	83 ec 0c             	sub    $0xc,%esp
  80310d:	50                   	push   %eax
  80310e:	e8 75 f6 ff ff       	call   802788 <fd2num>
  803113:	83 c4 10             	add    $0x10,%esp
}
  803116:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803119:	5b                   	pop    %ebx
  80311a:	5e                   	pop    %esi
  80311b:	5d                   	pop    %ebp
  80311c:	c3                   	ret    

0080311d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80311d:	55                   	push   %ebp
  80311e:	89 e5                	mov    %esp,%ebp
  803120:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803123:	8b 45 08             	mov    0x8(%ebp),%eax
  803126:	e8 50 ff ff ff       	call   80307b <fd2sockid>
		return r;
  80312b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  80312d:	85 c0                	test   %eax,%eax
  80312f:	78 1f                	js     803150 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803131:	83 ec 04             	sub    $0x4,%esp
  803134:	ff 75 10             	pushl  0x10(%ebp)
  803137:	ff 75 0c             	pushl  0xc(%ebp)
  80313a:	50                   	push   %eax
  80313b:	e8 12 01 00 00       	call   803252 <nsipc_accept>
  803140:	83 c4 10             	add    $0x10,%esp
		return r;
  803143:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  803145:	85 c0                	test   %eax,%eax
  803147:	78 07                	js     803150 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  803149:	e8 5d ff ff ff       	call   8030ab <alloc_sockfd>
  80314e:	89 c1                	mov    %eax,%ecx
}
  803150:	89 c8                	mov    %ecx,%eax
  803152:	c9                   	leave  
  803153:	c3                   	ret    

00803154 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803154:	55                   	push   %ebp
  803155:	89 e5                	mov    %esp,%ebp
  803157:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80315a:	8b 45 08             	mov    0x8(%ebp),%eax
  80315d:	e8 19 ff ff ff       	call   80307b <fd2sockid>
  803162:	85 c0                	test   %eax,%eax
  803164:	78 12                	js     803178 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  803166:	83 ec 04             	sub    $0x4,%esp
  803169:	ff 75 10             	pushl  0x10(%ebp)
  80316c:	ff 75 0c             	pushl  0xc(%ebp)
  80316f:	50                   	push   %eax
  803170:	e8 2d 01 00 00       	call   8032a2 <nsipc_bind>
  803175:	83 c4 10             	add    $0x10,%esp
}
  803178:	c9                   	leave  
  803179:	c3                   	ret    

0080317a <shutdown>:

int
shutdown(int s, int how)
{
  80317a:	55                   	push   %ebp
  80317b:	89 e5                	mov    %esp,%ebp
  80317d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803180:	8b 45 08             	mov    0x8(%ebp),%eax
  803183:	e8 f3 fe ff ff       	call   80307b <fd2sockid>
  803188:	85 c0                	test   %eax,%eax
  80318a:	78 0f                	js     80319b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80318c:	83 ec 08             	sub    $0x8,%esp
  80318f:	ff 75 0c             	pushl  0xc(%ebp)
  803192:	50                   	push   %eax
  803193:	e8 3f 01 00 00       	call   8032d7 <nsipc_shutdown>
  803198:	83 c4 10             	add    $0x10,%esp
}
  80319b:	c9                   	leave  
  80319c:	c3                   	ret    

0080319d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80319d:	55                   	push   %ebp
  80319e:	89 e5                	mov    %esp,%ebp
  8031a0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8031a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8031a6:	e8 d0 fe ff ff       	call   80307b <fd2sockid>
  8031ab:	85 c0                	test   %eax,%eax
  8031ad:	78 12                	js     8031c1 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8031af:	83 ec 04             	sub    $0x4,%esp
  8031b2:	ff 75 10             	pushl  0x10(%ebp)
  8031b5:	ff 75 0c             	pushl  0xc(%ebp)
  8031b8:	50                   	push   %eax
  8031b9:	e8 55 01 00 00       	call   803313 <nsipc_connect>
  8031be:	83 c4 10             	add    $0x10,%esp
}
  8031c1:	c9                   	leave  
  8031c2:	c3                   	ret    

008031c3 <listen>:

int
listen(int s, int backlog)
{
  8031c3:	55                   	push   %ebp
  8031c4:	89 e5                	mov    %esp,%ebp
  8031c6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8031c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8031cc:	e8 aa fe ff ff       	call   80307b <fd2sockid>
  8031d1:	85 c0                	test   %eax,%eax
  8031d3:	78 0f                	js     8031e4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8031d5:	83 ec 08             	sub    $0x8,%esp
  8031d8:	ff 75 0c             	pushl  0xc(%ebp)
  8031db:	50                   	push   %eax
  8031dc:	e8 67 01 00 00       	call   803348 <nsipc_listen>
  8031e1:	83 c4 10             	add    $0x10,%esp
}
  8031e4:	c9                   	leave  
  8031e5:	c3                   	ret    

008031e6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8031e6:	55                   	push   %ebp
  8031e7:	89 e5                	mov    %esp,%ebp
  8031e9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8031ec:	ff 75 10             	pushl  0x10(%ebp)
  8031ef:	ff 75 0c             	pushl  0xc(%ebp)
  8031f2:	ff 75 08             	pushl  0x8(%ebp)
  8031f5:	e8 3a 02 00 00       	call   803434 <nsipc_socket>
  8031fa:	83 c4 10             	add    $0x10,%esp
  8031fd:	85 c0                	test   %eax,%eax
  8031ff:	78 05                	js     803206 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  803201:	e8 a5 fe ff ff       	call   8030ab <alloc_sockfd>
}
  803206:	c9                   	leave  
  803207:	c3                   	ret    

00803208 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803208:	55                   	push   %ebp
  803209:	89 e5                	mov    %esp,%ebp
  80320b:	53                   	push   %ebx
  80320c:	83 ec 04             	sub    $0x4,%esp
  80320f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  803211:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  803218:	75 12                	jne    80322c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80321a:	83 ec 0c             	sub    $0xc,%esp
  80321d:	6a 02                	push   $0x2
  80321f:	e8 2b f5 ff ff       	call   80274f <ipc_find_env>
  803224:	a3 04 a0 80 00       	mov    %eax,0x80a004
  803229:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80322c:	6a 07                	push   $0x7
  80322e:	68 00 c0 80 00       	push   $0x80c000
  803233:	53                   	push   %ebx
  803234:	ff 35 04 a0 80 00    	pushl  0x80a004
  80323a:	e8 bc f4 ff ff       	call   8026fb <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80323f:	83 c4 0c             	add    $0xc,%esp
  803242:	6a 00                	push   $0x0
  803244:	6a 00                	push   $0x0
  803246:	6a 00                	push   $0x0
  803248:	e8 45 f4 ff ff       	call   802692 <ipc_recv>
}
  80324d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803250:	c9                   	leave  
  803251:	c3                   	ret    

00803252 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803252:	55                   	push   %ebp
  803253:	89 e5                	mov    %esp,%ebp
  803255:	56                   	push   %esi
  803256:	53                   	push   %ebx
  803257:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80325a:	8b 45 08             	mov    0x8(%ebp),%eax
  80325d:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  803262:	8b 06                	mov    (%esi),%eax
  803264:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803269:	b8 01 00 00 00       	mov    $0x1,%eax
  80326e:	e8 95 ff ff ff       	call   803208 <nsipc>
  803273:	89 c3                	mov    %eax,%ebx
  803275:	85 c0                	test   %eax,%eax
  803277:	78 20                	js     803299 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  803279:	83 ec 04             	sub    $0x4,%esp
  80327c:	ff 35 10 c0 80 00    	pushl  0x80c010
  803282:	68 00 c0 80 00       	push   $0x80c000
  803287:	ff 75 0c             	pushl  0xc(%ebp)
  80328a:	e8 0c ef ff ff       	call   80219b <memmove>
		*addrlen = ret->ret_addrlen;
  80328f:	a1 10 c0 80 00       	mov    0x80c010,%eax
  803294:	89 06                	mov    %eax,(%esi)
  803296:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  803299:	89 d8                	mov    %ebx,%eax
  80329b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80329e:	5b                   	pop    %ebx
  80329f:	5e                   	pop    %esi
  8032a0:	5d                   	pop    %ebp
  8032a1:	c3                   	ret    

008032a2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8032a2:	55                   	push   %ebp
  8032a3:	89 e5                	mov    %esp,%ebp
  8032a5:	53                   	push   %ebx
  8032a6:	83 ec 08             	sub    $0x8,%esp
  8032a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8032ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8032af:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8032b4:	53                   	push   %ebx
  8032b5:	ff 75 0c             	pushl  0xc(%ebp)
  8032b8:	68 04 c0 80 00       	push   $0x80c004
  8032bd:	e8 d9 ee ff ff       	call   80219b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8032c2:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  8032c8:	b8 02 00 00 00       	mov    $0x2,%eax
  8032cd:	e8 36 ff ff ff       	call   803208 <nsipc>
}
  8032d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8032d5:	c9                   	leave  
  8032d6:	c3                   	ret    

008032d7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8032d7:	55                   	push   %ebp
  8032d8:	89 e5                	mov    %esp,%ebp
  8032da:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8032dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8032e0:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  8032e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032e8:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  8032ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8032f2:	e8 11 ff ff ff       	call   803208 <nsipc>
}
  8032f7:	c9                   	leave  
  8032f8:	c3                   	ret    

008032f9 <nsipc_close>:

int
nsipc_close(int s)
{
  8032f9:	55                   	push   %ebp
  8032fa:	89 e5                	mov    %esp,%ebp
  8032fc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8032ff:	8b 45 08             	mov    0x8(%ebp),%eax
  803302:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  803307:	b8 04 00 00 00       	mov    $0x4,%eax
  80330c:	e8 f7 fe ff ff       	call   803208 <nsipc>
}
  803311:	c9                   	leave  
  803312:	c3                   	ret    

00803313 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803313:	55                   	push   %ebp
  803314:	89 e5                	mov    %esp,%ebp
  803316:	53                   	push   %ebx
  803317:	83 ec 08             	sub    $0x8,%esp
  80331a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80331d:	8b 45 08             	mov    0x8(%ebp),%eax
  803320:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  803325:	53                   	push   %ebx
  803326:	ff 75 0c             	pushl  0xc(%ebp)
  803329:	68 04 c0 80 00       	push   $0x80c004
  80332e:	e8 68 ee ff ff       	call   80219b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  803333:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  803339:	b8 05 00 00 00       	mov    $0x5,%eax
  80333e:	e8 c5 fe ff ff       	call   803208 <nsipc>
}
  803343:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803346:	c9                   	leave  
  803347:	c3                   	ret    

00803348 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803348:	55                   	push   %ebp
  803349:	89 e5                	mov    %esp,%ebp
  80334b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80334e:	8b 45 08             	mov    0x8(%ebp),%eax
  803351:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  803356:	8b 45 0c             	mov    0xc(%ebp),%eax
  803359:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  80335e:	b8 06 00 00 00       	mov    $0x6,%eax
  803363:	e8 a0 fe ff ff       	call   803208 <nsipc>
}
  803368:	c9                   	leave  
  803369:	c3                   	ret    

0080336a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80336a:	55                   	push   %ebp
  80336b:	89 e5                	mov    %esp,%ebp
  80336d:	56                   	push   %esi
  80336e:	53                   	push   %ebx
  80336f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  803372:	8b 45 08             	mov    0x8(%ebp),%eax
  803375:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  80337a:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  803380:	8b 45 14             	mov    0x14(%ebp),%eax
  803383:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803388:	b8 07 00 00 00       	mov    $0x7,%eax
  80338d:	e8 76 fe ff ff       	call   803208 <nsipc>
  803392:	89 c3                	mov    %eax,%ebx
  803394:	85 c0                	test   %eax,%eax
  803396:	78 35                	js     8033cd <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  803398:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80339d:	7f 04                	jg     8033a3 <nsipc_recv+0x39>
  80339f:	39 c6                	cmp    %eax,%esi
  8033a1:	7d 16                	jge    8033b9 <nsipc_recv+0x4f>
  8033a3:	68 ce 45 80 00       	push   $0x8045ce
  8033a8:	68 1d 3c 80 00       	push   $0x803c1d
  8033ad:	6a 62                	push   $0x62
  8033af:	68 e3 45 80 00       	push   $0x8045e3
  8033b4:	e8 f2 e5 ff ff       	call   8019ab <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8033b9:	83 ec 04             	sub    $0x4,%esp
  8033bc:	50                   	push   %eax
  8033bd:	68 00 c0 80 00       	push   $0x80c000
  8033c2:	ff 75 0c             	pushl  0xc(%ebp)
  8033c5:	e8 d1 ed ff ff       	call   80219b <memmove>
  8033ca:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8033cd:	89 d8                	mov    %ebx,%eax
  8033cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8033d2:	5b                   	pop    %ebx
  8033d3:	5e                   	pop    %esi
  8033d4:	5d                   	pop    %ebp
  8033d5:	c3                   	ret    

008033d6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8033d6:	55                   	push   %ebp
  8033d7:	89 e5                	mov    %esp,%ebp
  8033d9:	53                   	push   %ebx
  8033da:	83 ec 04             	sub    $0x4,%esp
  8033dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8033e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8033e3:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  8033e8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8033ee:	7e 16                	jle    803406 <nsipc_send+0x30>
  8033f0:	68 ef 45 80 00       	push   $0x8045ef
  8033f5:	68 1d 3c 80 00       	push   $0x803c1d
  8033fa:	6a 6d                	push   $0x6d
  8033fc:	68 e3 45 80 00       	push   $0x8045e3
  803401:	e8 a5 e5 ff ff       	call   8019ab <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  803406:	83 ec 04             	sub    $0x4,%esp
  803409:	53                   	push   %ebx
  80340a:	ff 75 0c             	pushl  0xc(%ebp)
  80340d:	68 0c c0 80 00       	push   $0x80c00c
  803412:	e8 84 ed ff ff       	call   80219b <memmove>
	nsipcbuf.send.req_size = size;
  803417:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  80341d:	8b 45 14             	mov    0x14(%ebp),%eax
  803420:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  803425:	b8 08 00 00 00       	mov    $0x8,%eax
  80342a:	e8 d9 fd ff ff       	call   803208 <nsipc>
}
  80342f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803432:	c9                   	leave  
  803433:	c3                   	ret    

00803434 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  803434:	55                   	push   %ebp
  803435:	89 e5                	mov    %esp,%ebp
  803437:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80343a:	8b 45 08             	mov    0x8(%ebp),%eax
  80343d:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  803442:	8b 45 0c             	mov    0xc(%ebp),%eax
  803445:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  80344a:	8b 45 10             	mov    0x10(%ebp),%eax
  80344d:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  803452:	b8 09 00 00 00       	mov    $0x9,%eax
  803457:	e8 ac fd ff ff       	call   803208 <nsipc>
}
  80345c:	c9                   	leave  
  80345d:	c3                   	ret    

0080345e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80345e:	55                   	push   %ebp
  80345f:	89 e5                	mov    %esp,%ebp
  803461:	56                   	push   %esi
  803462:	53                   	push   %ebx
  803463:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803466:	83 ec 0c             	sub    $0xc,%esp
  803469:	ff 75 08             	pushl  0x8(%ebp)
  80346c:	e8 27 f3 ff ff       	call   802798 <fd2data>
  803471:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803473:	83 c4 08             	add    $0x8,%esp
  803476:	68 fb 45 80 00       	push   $0x8045fb
  80347b:	53                   	push   %ebx
  80347c:	e8 88 eb ff ff       	call   802009 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803481:	8b 46 04             	mov    0x4(%esi),%eax
  803484:	2b 06                	sub    (%esi),%eax
  803486:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80348c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803493:	00 00 00 
	stat->st_dev = &devpipe;
  803496:	c7 83 88 00 00 00 9c 	movl   $0x80909c,0x88(%ebx)
  80349d:	90 80 00 
	return 0;
}
  8034a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8034a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8034a8:	5b                   	pop    %ebx
  8034a9:	5e                   	pop    %esi
  8034aa:	5d                   	pop    %ebp
  8034ab:	c3                   	ret    

008034ac <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8034ac:	55                   	push   %ebp
  8034ad:	89 e5                	mov    %esp,%ebp
  8034af:	53                   	push   %ebx
  8034b0:	83 ec 0c             	sub    $0xc,%esp
  8034b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8034b6:	53                   	push   %ebx
  8034b7:	6a 00                	push   $0x0
  8034b9:	e8 d3 ef ff ff       	call   802491 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8034be:	89 1c 24             	mov    %ebx,(%esp)
  8034c1:	e8 d2 f2 ff ff       	call   802798 <fd2data>
  8034c6:	83 c4 08             	add    $0x8,%esp
  8034c9:	50                   	push   %eax
  8034ca:	6a 00                	push   $0x0
  8034cc:	e8 c0 ef ff ff       	call   802491 <sys_page_unmap>
}
  8034d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8034d4:	c9                   	leave  
  8034d5:	c3                   	ret    

008034d6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8034d6:	55                   	push   %ebp
  8034d7:	89 e5                	mov    %esp,%ebp
  8034d9:	57                   	push   %edi
  8034da:	56                   	push   %esi
  8034db:	53                   	push   %ebx
  8034dc:	83 ec 1c             	sub    $0x1c,%esp
  8034df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8034e2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8034e4:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8034e9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8034ec:	83 ec 0c             	sub    $0xc,%esp
  8034ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8034f2:	e8 c5 fa ff ff       	call   802fbc <pageref>
  8034f7:	89 c3                	mov    %eax,%ebx
  8034f9:	89 3c 24             	mov    %edi,(%esp)
  8034fc:	e8 bb fa ff ff       	call   802fbc <pageref>
  803501:	83 c4 10             	add    $0x10,%esp
  803504:	39 c3                	cmp    %eax,%ebx
  803506:	0f 94 c1             	sete   %cl
  803509:	0f b6 c9             	movzbl %cl,%ecx
  80350c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80350f:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  803515:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803518:	39 ce                	cmp    %ecx,%esi
  80351a:	74 1b                	je     803537 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80351c:	39 c3                	cmp    %eax,%ebx
  80351e:	75 c4                	jne    8034e4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803520:	8b 42 58             	mov    0x58(%edx),%eax
  803523:	ff 75 e4             	pushl  -0x1c(%ebp)
  803526:	50                   	push   %eax
  803527:	56                   	push   %esi
  803528:	68 02 46 80 00       	push   $0x804602
  80352d:	e8 52 e5 ff ff       	call   801a84 <cprintf>
  803532:	83 c4 10             	add    $0x10,%esp
  803535:	eb ad                	jmp    8034e4 <_pipeisclosed+0xe>
	}
}
  803537:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80353a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80353d:	5b                   	pop    %ebx
  80353e:	5e                   	pop    %esi
  80353f:	5f                   	pop    %edi
  803540:	5d                   	pop    %ebp
  803541:	c3                   	ret    

00803542 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803542:	55                   	push   %ebp
  803543:	89 e5                	mov    %esp,%ebp
  803545:	57                   	push   %edi
  803546:	56                   	push   %esi
  803547:	53                   	push   %ebx
  803548:	83 ec 28             	sub    $0x28,%esp
  80354b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80354e:	56                   	push   %esi
  80354f:	e8 44 f2 ff ff       	call   802798 <fd2data>
  803554:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803556:	83 c4 10             	add    $0x10,%esp
  803559:	bf 00 00 00 00       	mov    $0x0,%edi
  80355e:	eb 4b                	jmp    8035ab <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803560:	89 da                	mov    %ebx,%edx
  803562:	89 f0                	mov    %esi,%eax
  803564:	e8 6d ff ff ff       	call   8034d6 <_pipeisclosed>
  803569:	85 c0                	test   %eax,%eax
  80356b:	75 48                	jne    8035b5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80356d:	e8 7b ee ff ff       	call   8023ed <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803572:	8b 43 04             	mov    0x4(%ebx),%eax
  803575:	8b 0b                	mov    (%ebx),%ecx
  803577:	8d 51 20             	lea    0x20(%ecx),%edx
  80357a:	39 d0                	cmp    %edx,%eax
  80357c:	73 e2                	jae    803560 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80357e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803581:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803585:	88 4d e7             	mov    %cl,-0x19(%ebp)
  803588:	89 c2                	mov    %eax,%edx
  80358a:	c1 fa 1f             	sar    $0x1f,%edx
  80358d:	89 d1                	mov    %edx,%ecx
  80358f:	c1 e9 1b             	shr    $0x1b,%ecx
  803592:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803595:	83 e2 1f             	and    $0x1f,%edx
  803598:	29 ca                	sub    %ecx,%edx
  80359a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80359e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8035a2:	83 c0 01             	add    $0x1,%eax
  8035a5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8035a8:	83 c7 01             	add    $0x1,%edi
  8035ab:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8035ae:	75 c2                	jne    803572 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8035b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8035b3:	eb 05                	jmp    8035ba <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8035b5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8035ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8035bd:	5b                   	pop    %ebx
  8035be:	5e                   	pop    %esi
  8035bf:	5f                   	pop    %edi
  8035c0:	5d                   	pop    %ebp
  8035c1:	c3                   	ret    

008035c2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8035c2:	55                   	push   %ebp
  8035c3:	89 e5                	mov    %esp,%ebp
  8035c5:	57                   	push   %edi
  8035c6:	56                   	push   %esi
  8035c7:	53                   	push   %ebx
  8035c8:	83 ec 18             	sub    $0x18,%esp
  8035cb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8035ce:	57                   	push   %edi
  8035cf:	e8 c4 f1 ff ff       	call   802798 <fd2data>
  8035d4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8035d6:	83 c4 10             	add    $0x10,%esp
  8035d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8035de:	eb 3d                	jmp    80361d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8035e0:	85 db                	test   %ebx,%ebx
  8035e2:	74 04                	je     8035e8 <devpipe_read+0x26>
				return i;
  8035e4:	89 d8                	mov    %ebx,%eax
  8035e6:	eb 44                	jmp    80362c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8035e8:	89 f2                	mov    %esi,%edx
  8035ea:	89 f8                	mov    %edi,%eax
  8035ec:	e8 e5 fe ff ff       	call   8034d6 <_pipeisclosed>
  8035f1:	85 c0                	test   %eax,%eax
  8035f3:	75 32                	jne    803627 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8035f5:	e8 f3 ed ff ff       	call   8023ed <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8035fa:	8b 06                	mov    (%esi),%eax
  8035fc:	3b 46 04             	cmp    0x4(%esi),%eax
  8035ff:	74 df                	je     8035e0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803601:	99                   	cltd   
  803602:	c1 ea 1b             	shr    $0x1b,%edx
  803605:	01 d0                	add    %edx,%eax
  803607:	83 e0 1f             	and    $0x1f,%eax
  80360a:	29 d0                	sub    %edx,%eax
  80360c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803611:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803614:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  803617:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80361a:	83 c3 01             	add    $0x1,%ebx
  80361d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803620:	75 d8                	jne    8035fa <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803622:	8b 45 10             	mov    0x10(%ebp),%eax
  803625:	eb 05                	jmp    80362c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803627:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80362c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80362f:	5b                   	pop    %ebx
  803630:	5e                   	pop    %esi
  803631:	5f                   	pop    %edi
  803632:	5d                   	pop    %ebp
  803633:	c3                   	ret    

00803634 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803634:	55                   	push   %ebp
  803635:	89 e5                	mov    %esp,%ebp
  803637:	56                   	push   %esi
  803638:	53                   	push   %ebx
  803639:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80363c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80363f:	50                   	push   %eax
  803640:	e8 6a f1 ff ff       	call   8027af <fd_alloc>
  803645:	83 c4 10             	add    $0x10,%esp
  803648:	89 c2                	mov    %eax,%edx
  80364a:	85 c0                	test   %eax,%eax
  80364c:	0f 88 2c 01 00 00    	js     80377e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803652:	83 ec 04             	sub    $0x4,%esp
  803655:	68 07 04 00 00       	push   $0x407
  80365a:	ff 75 f4             	pushl  -0xc(%ebp)
  80365d:	6a 00                	push   $0x0
  80365f:	e8 a8 ed ff ff       	call   80240c <sys_page_alloc>
  803664:	83 c4 10             	add    $0x10,%esp
  803667:	89 c2                	mov    %eax,%edx
  803669:	85 c0                	test   %eax,%eax
  80366b:	0f 88 0d 01 00 00    	js     80377e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803671:	83 ec 0c             	sub    $0xc,%esp
  803674:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803677:	50                   	push   %eax
  803678:	e8 32 f1 ff ff       	call   8027af <fd_alloc>
  80367d:	89 c3                	mov    %eax,%ebx
  80367f:	83 c4 10             	add    $0x10,%esp
  803682:	85 c0                	test   %eax,%eax
  803684:	0f 88 e2 00 00 00    	js     80376c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80368a:	83 ec 04             	sub    $0x4,%esp
  80368d:	68 07 04 00 00       	push   $0x407
  803692:	ff 75 f0             	pushl  -0x10(%ebp)
  803695:	6a 00                	push   $0x0
  803697:	e8 70 ed ff ff       	call   80240c <sys_page_alloc>
  80369c:	89 c3                	mov    %eax,%ebx
  80369e:	83 c4 10             	add    $0x10,%esp
  8036a1:	85 c0                	test   %eax,%eax
  8036a3:	0f 88 c3 00 00 00    	js     80376c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8036a9:	83 ec 0c             	sub    $0xc,%esp
  8036ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8036af:	e8 e4 f0 ff ff       	call   802798 <fd2data>
  8036b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8036b6:	83 c4 0c             	add    $0xc,%esp
  8036b9:	68 07 04 00 00       	push   $0x407
  8036be:	50                   	push   %eax
  8036bf:	6a 00                	push   $0x0
  8036c1:	e8 46 ed ff ff       	call   80240c <sys_page_alloc>
  8036c6:	89 c3                	mov    %eax,%ebx
  8036c8:	83 c4 10             	add    $0x10,%esp
  8036cb:	85 c0                	test   %eax,%eax
  8036cd:	0f 88 89 00 00 00    	js     80375c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8036d3:	83 ec 0c             	sub    $0xc,%esp
  8036d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8036d9:	e8 ba f0 ff ff       	call   802798 <fd2data>
  8036de:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8036e5:	50                   	push   %eax
  8036e6:	6a 00                	push   $0x0
  8036e8:	56                   	push   %esi
  8036e9:	6a 00                	push   $0x0
  8036eb:	e8 5f ed ff ff       	call   80244f <sys_page_map>
  8036f0:	89 c3                	mov    %eax,%ebx
  8036f2:	83 c4 20             	add    $0x20,%esp
  8036f5:	85 c0                	test   %eax,%eax
  8036f7:	78 55                	js     80374e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8036f9:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8036ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803702:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803704:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803707:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80370e:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803714:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803717:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803719:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80371c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803723:	83 ec 0c             	sub    $0xc,%esp
  803726:	ff 75 f4             	pushl  -0xc(%ebp)
  803729:	e8 5a f0 ff ff       	call   802788 <fd2num>
  80372e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803731:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803733:	83 c4 04             	add    $0x4,%esp
  803736:	ff 75 f0             	pushl  -0x10(%ebp)
  803739:	e8 4a f0 ff ff       	call   802788 <fd2num>
  80373e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803741:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803744:	83 c4 10             	add    $0x10,%esp
  803747:	ba 00 00 00 00       	mov    $0x0,%edx
  80374c:	eb 30                	jmp    80377e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80374e:	83 ec 08             	sub    $0x8,%esp
  803751:	56                   	push   %esi
  803752:	6a 00                	push   $0x0
  803754:	e8 38 ed ff ff       	call   802491 <sys_page_unmap>
  803759:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80375c:	83 ec 08             	sub    $0x8,%esp
  80375f:	ff 75 f0             	pushl  -0x10(%ebp)
  803762:	6a 00                	push   $0x0
  803764:	e8 28 ed ff ff       	call   802491 <sys_page_unmap>
  803769:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80376c:	83 ec 08             	sub    $0x8,%esp
  80376f:	ff 75 f4             	pushl  -0xc(%ebp)
  803772:	6a 00                	push   $0x0
  803774:	e8 18 ed ff ff       	call   802491 <sys_page_unmap>
  803779:	83 c4 10             	add    $0x10,%esp
  80377c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80377e:	89 d0                	mov    %edx,%eax
  803780:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803783:	5b                   	pop    %ebx
  803784:	5e                   	pop    %esi
  803785:	5d                   	pop    %ebp
  803786:	c3                   	ret    

00803787 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803787:	55                   	push   %ebp
  803788:	89 e5                	mov    %esp,%ebp
  80378a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80378d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803790:	50                   	push   %eax
  803791:	ff 75 08             	pushl  0x8(%ebp)
  803794:	e8 65 f0 ff ff       	call   8027fe <fd_lookup>
  803799:	83 c4 10             	add    $0x10,%esp
  80379c:	85 c0                	test   %eax,%eax
  80379e:	78 18                	js     8037b8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8037a0:	83 ec 0c             	sub    $0xc,%esp
  8037a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8037a6:	e8 ed ef ff ff       	call   802798 <fd2data>
	return _pipeisclosed(fd, p);
  8037ab:	89 c2                	mov    %eax,%edx
  8037ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037b0:	e8 21 fd ff ff       	call   8034d6 <_pipeisclosed>
  8037b5:	83 c4 10             	add    $0x10,%esp
}
  8037b8:	c9                   	leave  
  8037b9:	c3                   	ret    

008037ba <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8037ba:	55                   	push   %ebp
  8037bb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8037bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8037c2:	5d                   	pop    %ebp
  8037c3:	c3                   	ret    

008037c4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8037c4:	55                   	push   %ebp
  8037c5:	89 e5                	mov    %esp,%ebp
  8037c7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8037ca:	68 1a 46 80 00       	push   $0x80461a
  8037cf:	ff 75 0c             	pushl  0xc(%ebp)
  8037d2:	e8 32 e8 ff ff       	call   802009 <strcpy>
	return 0;
}
  8037d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8037dc:	c9                   	leave  
  8037dd:	c3                   	ret    

008037de <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8037de:	55                   	push   %ebp
  8037df:	89 e5                	mov    %esp,%ebp
  8037e1:	57                   	push   %edi
  8037e2:	56                   	push   %esi
  8037e3:	53                   	push   %ebx
  8037e4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037ea:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8037ef:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037f5:	eb 2d                	jmp    803824 <devcons_write+0x46>
		m = n - tot;
  8037f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8037fa:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8037fc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8037ff:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803804:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803807:	83 ec 04             	sub    $0x4,%esp
  80380a:	53                   	push   %ebx
  80380b:	03 45 0c             	add    0xc(%ebp),%eax
  80380e:	50                   	push   %eax
  80380f:	57                   	push   %edi
  803810:	e8 86 e9 ff ff       	call   80219b <memmove>
		sys_cputs(buf, m);
  803815:	83 c4 08             	add    $0x8,%esp
  803818:	53                   	push   %ebx
  803819:	57                   	push   %edi
  80381a:	e8 31 eb ff ff       	call   802350 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80381f:	01 de                	add    %ebx,%esi
  803821:	83 c4 10             	add    $0x10,%esp
  803824:	89 f0                	mov    %esi,%eax
  803826:	3b 75 10             	cmp    0x10(%ebp),%esi
  803829:	72 cc                	jb     8037f7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80382b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80382e:	5b                   	pop    %ebx
  80382f:	5e                   	pop    %esi
  803830:	5f                   	pop    %edi
  803831:	5d                   	pop    %ebp
  803832:	c3                   	ret    

00803833 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803833:	55                   	push   %ebp
  803834:	89 e5                	mov    %esp,%ebp
  803836:	83 ec 08             	sub    $0x8,%esp
  803839:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80383e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803842:	74 2a                	je     80386e <devcons_read+0x3b>
  803844:	eb 05                	jmp    80384b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803846:	e8 a2 eb ff ff       	call   8023ed <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80384b:	e8 1e eb ff ff       	call   80236e <sys_cgetc>
  803850:	85 c0                	test   %eax,%eax
  803852:	74 f2                	je     803846 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803854:	85 c0                	test   %eax,%eax
  803856:	78 16                	js     80386e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803858:	83 f8 04             	cmp    $0x4,%eax
  80385b:	74 0c                	je     803869 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80385d:	8b 55 0c             	mov    0xc(%ebp),%edx
  803860:	88 02                	mov    %al,(%edx)
	return 1;
  803862:	b8 01 00 00 00       	mov    $0x1,%eax
  803867:	eb 05                	jmp    80386e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803869:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80386e:	c9                   	leave  
  80386f:	c3                   	ret    

00803870 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803870:	55                   	push   %ebp
  803871:	89 e5                	mov    %esp,%ebp
  803873:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803876:	8b 45 08             	mov    0x8(%ebp),%eax
  803879:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80387c:	6a 01                	push   $0x1
  80387e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803881:	50                   	push   %eax
  803882:	e8 c9 ea ff ff       	call   802350 <sys_cputs>
}
  803887:	83 c4 10             	add    $0x10,%esp
  80388a:	c9                   	leave  
  80388b:	c3                   	ret    

0080388c <getchar>:

int
getchar(void)
{
  80388c:	55                   	push   %ebp
  80388d:	89 e5                	mov    %esp,%ebp
  80388f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803892:	6a 01                	push   $0x1
  803894:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803897:	50                   	push   %eax
  803898:	6a 00                	push   $0x0
  80389a:	e8 c5 f1 ff ff       	call   802a64 <read>
	if (r < 0)
  80389f:	83 c4 10             	add    $0x10,%esp
  8038a2:	85 c0                	test   %eax,%eax
  8038a4:	78 0f                	js     8038b5 <getchar+0x29>
		return r;
	if (r < 1)
  8038a6:	85 c0                	test   %eax,%eax
  8038a8:	7e 06                	jle    8038b0 <getchar+0x24>
		return -E_EOF;
	return c;
  8038aa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8038ae:	eb 05                	jmp    8038b5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8038b0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8038b5:	c9                   	leave  
  8038b6:	c3                   	ret    

008038b7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8038b7:	55                   	push   %ebp
  8038b8:	89 e5                	mov    %esp,%ebp
  8038ba:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8038bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8038c0:	50                   	push   %eax
  8038c1:	ff 75 08             	pushl  0x8(%ebp)
  8038c4:	e8 35 ef ff ff       	call   8027fe <fd_lookup>
  8038c9:	83 c4 10             	add    $0x10,%esp
  8038cc:	85 c0                	test   %eax,%eax
  8038ce:	78 11                	js     8038e1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8038d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038d3:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  8038d9:	39 10                	cmp    %edx,(%eax)
  8038db:	0f 94 c0             	sete   %al
  8038de:	0f b6 c0             	movzbl %al,%eax
}
  8038e1:	c9                   	leave  
  8038e2:	c3                   	ret    

008038e3 <opencons>:

int
opencons(void)
{
  8038e3:	55                   	push   %ebp
  8038e4:	89 e5                	mov    %esp,%ebp
  8038e6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8038e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8038ec:	50                   	push   %eax
  8038ed:	e8 bd ee ff ff       	call   8027af <fd_alloc>
  8038f2:	83 c4 10             	add    $0x10,%esp
		return r;
  8038f5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8038f7:	85 c0                	test   %eax,%eax
  8038f9:	78 3e                	js     803939 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8038fb:	83 ec 04             	sub    $0x4,%esp
  8038fe:	68 07 04 00 00       	push   $0x407
  803903:	ff 75 f4             	pushl  -0xc(%ebp)
  803906:	6a 00                	push   $0x0
  803908:	e8 ff ea ff ff       	call   80240c <sys_page_alloc>
  80390d:	83 c4 10             	add    $0x10,%esp
		return r;
  803910:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803912:	85 c0                	test   %eax,%eax
  803914:	78 23                	js     803939 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803916:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  80391c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80391f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803921:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803924:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80392b:	83 ec 0c             	sub    $0xc,%esp
  80392e:	50                   	push   %eax
  80392f:	e8 54 ee ff ff       	call   802788 <fd2num>
  803934:	89 c2                	mov    %eax,%edx
  803936:	83 c4 10             	add    $0x10,%esp
}
  803939:	89 d0                	mov    %edx,%eax
  80393b:	c9                   	leave  
  80393c:	c3                   	ret    
  80393d:	66 90                	xchg   %ax,%ax
  80393f:	90                   	nop

00803940 <__udivdi3>:
  803940:	55                   	push   %ebp
  803941:	57                   	push   %edi
  803942:	56                   	push   %esi
  803943:	53                   	push   %ebx
  803944:	83 ec 1c             	sub    $0x1c,%esp
  803947:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80394b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80394f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803953:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803957:	85 f6                	test   %esi,%esi
  803959:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80395d:	89 ca                	mov    %ecx,%edx
  80395f:	89 f8                	mov    %edi,%eax
  803961:	75 3d                	jne    8039a0 <__udivdi3+0x60>
  803963:	39 cf                	cmp    %ecx,%edi
  803965:	0f 87 c5 00 00 00    	ja     803a30 <__udivdi3+0xf0>
  80396b:	85 ff                	test   %edi,%edi
  80396d:	89 fd                	mov    %edi,%ebp
  80396f:	75 0b                	jne    80397c <__udivdi3+0x3c>
  803971:	b8 01 00 00 00       	mov    $0x1,%eax
  803976:	31 d2                	xor    %edx,%edx
  803978:	f7 f7                	div    %edi
  80397a:	89 c5                	mov    %eax,%ebp
  80397c:	89 c8                	mov    %ecx,%eax
  80397e:	31 d2                	xor    %edx,%edx
  803980:	f7 f5                	div    %ebp
  803982:	89 c1                	mov    %eax,%ecx
  803984:	89 d8                	mov    %ebx,%eax
  803986:	89 cf                	mov    %ecx,%edi
  803988:	f7 f5                	div    %ebp
  80398a:	89 c3                	mov    %eax,%ebx
  80398c:	89 d8                	mov    %ebx,%eax
  80398e:	89 fa                	mov    %edi,%edx
  803990:	83 c4 1c             	add    $0x1c,%esp
  803993:	5b                   	pop    %ebx
  803994:	5e                   	pop    %esi
  803995:	5f                   	pop    %edi
  803996:	5d                   	pop    %ebp
  803997:	c3                   	ret    
  803998:	90                   	nop
  803999:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8039a0:	39 ce                	cmp    %ecx,%esi
  8039a2:	77 74                	ja     803a18 <__udivdi3+0xd8>
  8039a4:	0f bd fe             	bsr    %esi,%edi
  8039a7:	83 f7 1f             	xor    $0x1f,%edi
  8039aa:	0f 84 98 00 00 00    	je     803a48 <__udivdi3+0x108>
  8039b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8039b5:	89 f9                	mov    %edi,%ecx
  8039b7:	89 c5                	mov    %eax,%ebp
  8039b9:	29 fb                	sub    %edi,%ebx
  8039bb:	d3 e6                	shl    %cl,%esi
  8039bd:	89 d9                	mov    %ebx,%ecx
  8039bf:	d3 ed                	shr    %cl,%ebp
  8039c1:	89 f9                	mov    %edi,%ecx
  8039c3:	d3 e0                	shl    %cl,%eax
  8039c5:	09 ee                	or     %ebp,%esi
  8039c7:	89 d9                	mov    %ebx,%ecx
  8039c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8039cd:	89 d5                	mov    %edx,%ebp
  8039cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8039d3:	d3 ed                	shr    %cl,%ebp
  8039d5:	89 f9                	mov    %edi,%ecx
  8039d7:	d3 e2                	shl    %cl,%edx
  8039d9:	89 d9                	mov    %ebx,%ecx
  8039db:	d3 e8                	shr    %cl,%eax
  8039dd:	09 c2                	or     %eax,%edx
  8039df:	89 d0                	mov    %edx,%eax
  8039e1:	89 ea                	mov    %ebp,%edx
  8039e3:	f7 f6                	div    %esi
  8039e5:	89 d5                	mov    %edx,%ebp
  8039e7:	89 c3                	mov    %eax,%ebx
  8039e9:	f7 64 24 0c          	mull   0xc(%esp)
  8039ed:	39 d5                	cmp    %edx,%ebp
  8039ef:	72 10                	jb     803a01 <__udivdi3+0xc1>
  8039f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8039f5:	89 f9                	mov    %edi,%ecx
  8039f7:	d3 e6                	shl    %cl,%esi
  8039f9:	39 c6                	cmp    %eax,%esi
  8039fb:	73 07                	jae    803a04 <__udivdi3+0xc4>
  8039fd:	39 d5                	cmp    %edx,%ebp
  8039ff:	75 03                	jne    803a04 <__udivdi3+0xc4>
  803a01:	83 eb 01             	sub    $0x1,%ebx
  803a04:	31 ff                	xor    %edi,%edi
  803a06:	89 d8                	mov    %ebx,%eax
  803a08:	89 fa                	mov    %edi,%edx
  803a0a:	83 c4 1c             	add    $0x1c,%esp
  803a0d:	5b                   	pop    %ebx
  803a0e:	5e                   	pop    %esi
  803a0f:	5f                   	pop    %edi
  803a10:	5d                   	pop    %ebp
  803a11:	c3                   	ret    
  803a12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803a18:	31 ff                	xor    %edi,%edi
  803a1a:	31 db                	xor    %ebx,%ebx
  803a1c:	89 d8                	mov    %ebx,%eax
  803a1e:	89 fa                	mov    %edi,%edx
  803a20:	83 c4 1c             	add    $0x1c,%esp
  803a23:	5b                   	pop    %ebx
  803a24:	5e                   	pop    %esi
  803a25:	5f                   	pop    %edi
  803a26:	5d                   	pop    %ebp
  803a27:	c3                   	ret    
  803a28:	90                   	nop
  803a29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803a30:	89 d8                	mov    %ebx,%eax
  803a32:	f7 f7                	div    %edi
  803a34:	31 ff                	xor    %edi,%edi
  803a36:	89 c3                	mov    %eax,%ebx
  803a38:	89 d8                	mov    %ebx,%eax
  803a3a:	89 fa                	mov    %edi,%edx
  803a3c:	83 c4 1c             	add    $0x1c,%esp
  803a3f:	5b                   	pop    %ebx
  803a40:	5e                   	pop    %esi
  803a41:	5f                   	pop    %edi
  803a42:	5d                   	pop    %ebp
  803a43:	c3                   	ret    
  803a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803a48:	39 ce                	cmp    %ecx,%esi
  803a4a:	72 0c                	jb     803a58 <__udivdi3+0x118>
  803a4c:	31 db                	xor    %ebx,%ebx
  803a4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803a52:	0f 87 34 ff ff ff    	ja     80398c <__udivdi3+0x4c>
  803a58:	bb 01 00 00 00       	mov    $0x1,%ebx
  803a5d:	e9 2a ff ff ff       	jmp    80398c <__udivdi3+0x4c>
  803a62:	66 90                	xchg   %ax,%ax
  803a64:	66 90                	xchg   %ax,%ax
  803a66:	66 90                	xchg   %ax,%ax
  803a68:	66 90                	xchg   %ax,%ax
  803a6a:	66 90                	xchg   %ax,%ax
  803a6c:	66 90                	xchg   %ax,%ax
  803a6e:	66 90                	xchg   %ax,%ax

00803a70 <__umoddi3>:
  803a70:	55                   	push   %ebp
  803a71:	57                   	push   %edi
  803a72:	56                   	push   %esi
  803a73:	53                   	push   %ebx
  803a74:	83 ec 1c             	sub    $0x1c,%esp
  803a77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  803a7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803a7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803a83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803a87:	85 d2                	test   %edx,%edx
  803a89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803a8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803a91:	89 f3                	mov    %esi,%ebx
  803a93:	89 3c 24             	mov    %edi,(%esp)
  803a96:	89 74 24 04          	mov    %esi,0x4(%esp)
  803a9a:	75 1c                	jne    803ab8 <__umoddi3+0x48>
  803a9c:	39 f7                	cmp    %esi,%edi
  803a9e:	76 50                	jbe    803af0 <__umoddi3+0x80>
  803aa0:	89 c8                	mov    %ecx,%eax
  803aa2:	89 f2                	mov    %esi,%edx
  803aa4:	f7 f7                	div    %edi
  803aa6:	89 d0                	mov    %edx,%eax
  803aa8:	31 d2                	xor    %edx,%edx
  803aaa:	83 c4 1c             	add    $0x1c,%esp
  803aad:	5b                   	pop    %ebx
  803aae:	5e                   	pop    %esi
  803aaf:	5f                   	pop    %edi
  803ab0:	5d                   	pop    %ebp
  803ab1:	c3                   	ret    
  803ab2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803ab8:	39 f2                	cmp    %esi,%edx
  803aba:	89 d0                	mov    %edx,%eax
  803abc:	77 52                	ja     803b10 <__umoddi3+0xa0>
  803abe:	0f bd ea             	bsr    %edx,%ebp
  803ac1:	83 f5 1f             	xor    $0x1f,%ebp
  803ac4:	75 5a                	jne    803b20 <__umoddi3+0xb0>
  803ac6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  803aca:	0f 82 e0 00 00 00    	jb     803bb0 <__umoddi3+0x140>
  803ad0:	39 0c 24             	cmp    %ecx,(%esp)
  803ad3:	0f 86 d7 00 00 00    	jbe    803bb0 <__umoddi3+0x140>
  803ad9:	8b 44 24 08          	mov    0x8(%esp),%eax
  803add:	8b 54 24 04          	mov    0x4(%esp),%edx
  803ae1:	83 c4 1c             	add    $0x1c,%esp
  803ae4:	5b                   	pop    %ebx
  803ae5:	5e                   	pop    %esi
  803ae6:	5f                   	pop    %edi
  803ae7:	5d                   	pop    %ebp
  803ae8:	c3                   	ret    
  803ae9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803af0:	85 ff                	test   %edi,%edi
  803af2:	89 fd                	mov    %edi,%ebp
  803af4:	75 0b                	jne    803b01 <__umoddi3+0x91>
  803af6:	b8 01 00 00 00       	mov    $0x1,%eax
  803afb:	31 d2                	xor    %edx,%edx
  803afd:	f7 f7                	div    %edi
  803aff:	89 c5                	mov    %eax,%ebp
  803b01:	89 f0                	mov    %esi,%eax
  803b03:	31 d2                	xor    %edx,%edx
  803b05:	f7 f5                	div    %ebp
  803b07:	89 c8                	mov    %ecx,%eax
  803b09:	f7 f5                	div    %ebp
  803b0b:	89 d0                	mov    %edx,%eax
  803b0d:	eb 99                	jmp    803aa8 <__umoddi3+0x38>
  803b0f:	90                   	nop
  803b10:	89 c8                	mov    %ecx,%eax
  803b12:	89 f2                	mov    %esi,%edx
  803b14:	83 c4 1c             	add    $0x1c,%esp
  803b17:	5b                   	pop    %ebx
  803b18:	5e                   	pop    %esi
  803b19:	5f                   	pop    %edi
  803b1a:	5d                   	pop    %ebp
  803b1b:	c3                   	ret    
  803b1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803b20:	8b 34 24             	mov    (%esp),%esi
  803b23:	bf 20 00 00 00       	mov    $0x20,%edi
  803b28:	89 e9                	mov    %ebp,%ecx
  803b2a:	29 ef                	sub    %ebp,%edi
  803b2c:	d3 e0                	shl    %cl,%eax
  803b2e:	89 f9                	mov    %edi,%ecx
  803b30:	89 f2                	mov    %esi,%edx
  803b32:	d3 ea                	shr    %cl,%edx
  803b34:	89 e9                	mov    %ebp,%ecx
  803b36:	09 c2                	or     %eax,%edx
  803b38:	89 d8                	mov    %ebx,%eax
  803b3a:	89 14 24             	mov    %edx,(%esp)
  803b3d:	89 f2                	mov    %esi,%edx
  803b3f:	d3 e2                	shl    %cl,%edx
  803b41:	89 f9                	mov    %edi,%ecx
  803b43:	89 54 24 04          	mov    %edx,0x4(%esp)
  803b47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803b4b:	d3 e8                	shr    %cl,%eax
  803b4d:	89 e9                	mov    %ebp,%ecx
  803b4f:	89 c6                	mov    %eax,%esi
  803b51:	d3 e3                	shl    %cl,%ebx
  803b53:	89 f9                	mov    %edi,%ecx
  803b55:	89 d0                	mov    %edx,%eax
  803b57:	d3 e8                	shr    %cl,%eax
  803b59:	89 e9                	mov    %ebp,%ecx
  803b5b:	09 d8                	or     %ebx,%eax
  803b5d:	89 d3                	mov    %edx,%ebx
  803b5f:	89 f2                	mov    %esi,%edx
  803b61:	f7 34 24             	divl   (%esp)
  803b64:	89 d6                	mov    %edx,%esi
  803b66:	d3 e3                	shl    %cl,%ebx
  803b68:	f7 64 24 04          	mull   0x4(%esp)
  803b6c:	39 d6                	cmp    %edx,%esi
  803b6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803b72:	89 d1                	mov    %edx,%ecx
  803b74:	89 c3                	mov    %eax,%ebx
  803b76:	72 08                	jb     803b80 <__umoddi3+0x110>
  803b78:	75 11                	jne    803b8b <__umoddi3+0x11b>
  803b7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  803b7e:	73 0b                	jae    803b8b <__umoddi3+0x11b>
  803b80:	2b 44 24 04          	sub    0x4(%esp),%eax
  803b84:	1b 14 24             	sbb    (%esp),%edx
  803b87:	89 d1                	mov    %edx,%ecx
  803b89:	89 c3                	mov    %eax,%ebx
  803b8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  803b8f:	29 da                	sub    %ebx,%edx
  803b91:	19 ce                	sbb    %ecx,%esi
  803b93:	89 f9                	mov    %edi,%ecx
  803b95:	89 f0                	mov    %esi,%eax
  803b97:	d3 e0                	shl    %cl,%eax
  803b99:	89 e9                	mov    %ebp,%ecx
  803b9b:	d3 ea                	shr    %cl,%edx
  803b9d:	89 e9                	mov    %ebp,%ecx
  803b9f:	d3 ee                	shr    %cl,%esi
  803ba1:	09 d0                	or     %edx,%eax
  803ba3:	89 f2                	mov    %esi,%edx
  803ba5:	83 c4 1c             	add    $0x1c,%esp
  803ba8:	5b                   	pop    %ebx
  803ba9:	5e                   	pop    %esi
  803baa:	5f                   	pop    %edi
  803bab:	5d                   	pop    %ebp
  803bac:	c3                   	ret    
  803bad:	8d 76 00             	lea    0x0(%esi),%esi
  803bb0:	29 f9                	sub    %edi,%ecx
  803bb2:	19 d6                	sbb    %edx,%esi
  803bb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  803bb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803bbc:	e9 18 ff ff ff       	jmp    803ad9 <__umoddi3+0x69>
