
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 8c fe 29 f0 00 	cmpl   $0x0,0xf029fe8c
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 8c fe 29 f0    	mov    %esi,0xf029fe8c

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 b9 56 00 00       	call   f010571a <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 63 10 f0       	push   $0xf0106320
f010006d:	e8 df 35 00 00       	call   f0103651 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 af 35 00 00       	call   f010362b <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 37 75 10 f0 	movl   $0xf0107537,(%esp)
f0100083:	e8 c9 35 00 00       	call   f0103651 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 52 08 00 00       	call   f01008e7 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 10 2e f0       	mov    $0xf02e1008,%eax
f01000a6:	2d 50 e8 29 f0       	sub    $0xf029e850,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 50 e8 29 f0       	push   $0xf029e850
f01000b3:	e8 3f 50 00 00       	call   f01050f7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 92 05 00 00       	call   f010064f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 8c 63 10 f0       	push   $0xf010638c
f01000ca:	e8 82 35 00 00       	call   f0103651 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 4c 12 00 00       	call   f0101320 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 a8 2e 00 00       	call   f0102f81 <env_init>
	trap_init();
f01000d9:	e8 57 36 00 00       	call   f0103735 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 2d 53 00 00       	call   f0105410 <mp_init>
	lapic_init();
f01000e3:	e8 4d 56 00 00       	call   f0105735 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 75 34 00 00       	call   f0103562 <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01000ed:	e8 4d 5f 00 00       	call   f010603f <time_init>
	pci_init();
f01000f2:	e8 28 5f 00 00       	call   f010601f <pci_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000f7:	c7 04 24 60 24 12 f0 	movl   $0xf0122460,(%esp)
f01000fe:	e8 85 58 00 00       	call   f0105988 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100103:	83 c4 10             	add    $0x10,%esp
f0100106:	83 3d 94 fe 29 f0 07 	cmpl   $0x7,0xf029fe94
f010010d:	77 16                	ja     f0100125 <i386_init+0x8b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010010f:	68 00 70 00 00       	push   $0x7000
f0100114:	68 44 63 10 f0       	push   $0xf0106344
f0100119:	6a 65                	push   $0x65
f010011b:	68 a7 63 10 f0       	push   $0xf01063a7
f0100120:	e8 1b ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100125:	83 ec 04             	sub    $0x4,%esp
f0100128:	b8 76 53 10 f0       	mov    $0xf0105376,%eax
f010012d:	2d fc 52 10 f0       	sub    $0xf01052fc,%eax
f0100132:	50                   	push   %eax
f0100133:	68 fc 52 10 f0       	push   $0xf01052fc
f0100138:	68 00 70 00 f0       	push   $0xf0007000
f010013d:	e8 02 50 00 00       	call   f0105144 <memmove>
f0100142:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100145:	bb 20 00 2a f0       	mov    $0xf02a0020,%ebx
f010014a:	eb 4d                	jmp    f0100199 <i386_init+0xff>
		if (c == cpus + cpunum())  // We've started already.
f010014c:	e8 c9 55 00 00       	call   f010571a <cpunum>
f0100151:	6b c0 74             	imul   $0x74,%eax,%eax
f0100154:	05 20 00 2a f0       	add    $0xf02a0020,%eax
f0100159:	39 c3                	cmp    %eax,%ebx
f010015b:	74 39                	je     f0100196 <i386_init+0xfc>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010015d:	89 d8                	mov    %ebx,%eax
f010015f:	2d 20 00 2a f0       	sub    $0xf02a0020,%eax
f0100164:	c1 f8 02             	sar    $0x2,%eax
f0100167:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010016d:	c1 e0 0f             	shl    $0xf,%eax
f0100170:	05 00 90 2a f0       	add    $0xf02a9000,%eax
f0100175:	a3 90 fe 29 f0       	mov    %eax,0xf029fe90
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010017a:	83 ec 08             	sub    $0x8,%esp
f010017d:	68 00 70 00 00       	push   $0x7000
f0100182:	0f b6 03             	movzbl (%ebx),%eax
f0100185:	50                   	push   %eax
f0100186:	e8 f8 56 00 00       	call   f0105883 <lapic_startap>
f010018b:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010018e:	8b 43 04             	mov    0x4(%ebx),%eax
f0100191:	83 f8 01             	cmp    $0x1,%eax
f0100194:	75 f8                	jne    f010018e <i386_init+0xf4>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100196:	83 c3 74             	add    $0x74,%ebx
f0100199:	6b 05 c4 03 2a f0 74 	imul   $0x74,0xf02a03c4,%eax
f01001a0:	05 20 00 2a f0       	add    $0xf02a0020,%eax
f01001a5:	39 c3                	cmp    %eax,%ebx
f01001a7:	72 a3                	jb     f010014c <i386_init+0xb2>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001a9:	83 ec 08             	sub    $0x8,%esp
f01001ac:	6a 01                	push   $0x1
f01001ae:	68 84 00 1d f0       	push   $0xf01d0084
f01001b3:	e8 68 2f 00 00       	call   f0103120 <env_create>
	ENV_CREATE(net_ns, ENV_TYPE_NS);
#endif

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001b8:	83 c4 08             	add    $0x8,%esp
f01001bb:	6a 00                	push   $0x0
f01001bd:	68 88 32 21 f0       	push   $0xf0213288
f01001c2:	e8 59 2f 00 00       	call   f0103120 <env_create>
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001c7:	e8 27 04 00 00       	call   f01005f3 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001cc:	e8 bc 3d 00 00       	call   f0103f8d <sched_yield>

f01001d1 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001d1:	55                   	push   %ebp
f01001d2:	89 e5                	mov    %esp,%ebp
f01001d4:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001d7:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001e1:	77 12                	ja     f01001f5 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001e3:	50                   	push   %eax
f01001e4:	68 68 63 10 f0       	push   $0xf0106368
f01001e9:	6a 7c                	push   $0x7c
f01001eb:	68 a7 63 10 f0       	push   $0xf01063a7
f01001f0:	e8 4b fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001f5:	05 00 00 00 10       	add    $0x10000000,%eax
f01001fa:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001fd:	e8 18 55 00 00       	call   f010571a <cpunum>
f0100202:	83 ec 08             	sub    $0x8,%esp
f0100205:	50                   	push   %eax
f0100206:	68 b3 63 10 f0       	push   $0xf01063b3
f010020b:	e8 41 34 00 00       	call   f0103651 <cprintf>

	lapic_init();
f0100210:	e8 20 55 00 00       	call   f0105735 <lapic_init>
	env_init_percpu();
f0100215:	e8 37 2d 00 00       	call   f0102f51 <env_init_percpu>
	trap_init_percpu();
f010021a:	e8 46 34 00 00       	call   f0103665 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010021f:	e8 f6 54 00 00       	call   f010571a <cpunum>
f0100224:	6b d0 74             	imul   $0x74,%eax,%edx
f0100227:	81 c2 20 00 2a f0    	add    $0xf02a0020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010022d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100232:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100236:	c7 04 24 60 24 12 f0 	movl   $0xf0122460,(%esp)
f010023d:	e8 46 57 00 00       	call   f0105988 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100242:	e8 46 3d 00 00       	call   f0103f8d <sched_yield>

f0100247 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100247:	55                   	push   %ebp
f0100248:	89 e5                	mov    %esp,%ebp
f010024a:	53                   	push   %ebx
f010024b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010024e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100251:	ff 75 0c             	pushl  0xc(%ebp)
f0100254:	ff 75 08             	pushl  0x8(%ebp)
f0100257:	68 c9 63 10 f0       	push   $0xf01063c9
f010025c:	e8 f0 33 00 00       	call   f0103651 <cprintf>
	vcprintf(fmt, ap);
f0100261:	83 c4 08             	add    $0x8,%esp
f0100264:	53                   	push   %ebx
f0100265:	ff 75 10             	pushl  0x10(%ebp)
f0100268:	e8 be 33 00 00       	call   f010362b <vcprintf>
	cprintf("\n");
f010026d:	c7 04 24 37 75 10 f0 	movl   $0xf0107537,(%esp)
f0100274:	e8 d8 33 00 00       	call   f0103651 <cprintf>
	va_end(ap);
}
f0100279:	83 c4 10             	add    $0x10,%esp
f010027c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010027f:	c9                   	leave  
f0100280:	c3                   	ret    

f0100281 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100281:	55                   	push   %ebp
f0100282:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100284:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100289:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010028a:	a8 01                	test   $0x1,%al
f010028c:	74 0b                	je     f0100299 <serial_proc_data+0x18>
f010028e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100293:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100294:	0f b6 c0             	movzbl %al,%eax
f0100297:	eb 05                	jmp    f010029e <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010029e:	5d                   	pop    %ebp
f010029f:	c3                   	ret    

f01002a0 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002a0:	55                   	push   %ebp
f01002a1:	89 e5                	mov    %esp,%ebp
f01002a3:	53                   	push   %ebx
f01002a4:	83 ec 04             	sub    $0x4,%esp
f01002a7:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002a9:	eb 2b                	jmp    f01002d6 <cons_intr+0x36>
		if (c == 0)
f01002ab:	85 c0                	test   %eax,%eax
f01002ad:	74 27                	je     f01002d6 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002af:	8b 0d 24 f2 29 f0    	mov    0xf029f224,%ecx
f01002b5:	8d 51 01             	lea    0x1(%ecx),%edx
f01002b8:	89 15 24 f2 29 f0    	mov    %edx,0xf029f224
f01002be:	88 81 20 f0 29 f0    	mov    %al,-0xfd60fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002c4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002ca:	75 0a                	jne    f01002d6 <cons_intr+0x36>
			cons.wpos = 0;
f01002cc:	c7 05 24 f2 29 f0 00 	movl   $0x0,0xf029f224
f01002d3:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002d6:	ff d3                	call   *%ebx
f01002d8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002db:	75 ce                	jne    f01002ab <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002dd:	83 c4 04             	add    $0x4,%esp
f01002e0:	5b                   	pop    %ebx
f01002e1:	5d                   	pop    %ebp
f01002e2:	c3                   	ret    

f01002e3 <kbd_proc_data>:
f01002e3:	ba 64 00 00 00       	mov    $0x64,%edx
f01002e8:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002e9:	a8 01                	test   $0x1,%al
f01002eb:	0f 84 f0 00 00 00    	je     f01003e1 <kbd_proc_data+0xfe>
f01002f1:	ba 60 00 00 00       	mov    $0x60,%edx
f01002f6:	ec                   	in     (%dx),%al
f01002f7:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002f9:	3c e0                	cmp    $0xe0,%al
f01002fb:	75 0d                	jne    f010030a <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002fd:	83 0d 00 f0 29 f0 40 	orl    $0x40,0xf029f000
		return 0;
f0100304:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100309:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010030a:	55                   	push   %ebp
f010030b:	89 e5                	mov    %esp,%ebp
f010030d:	53                   	push   %ebx
f010030e:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100311:	84 c0                	test   %al,%al
f0100313:	79 36                	jns    f010034b <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100315:	8b 0d 00 f0 29 f0    	mov    0xf029f000,%ecx
f010031b:	89 cb                	mov    %ecx,%ebx
f010031d:	83 e3 40             	and    $0x40,%ebx
f0100320:	83 e0 7f             	and    $0x7f,%eax
f0100323:	85 db                	test   %ebx,%ebx
f0100325:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100328:	0f b6 d2             	movzbl %dl,%edx
f010032b:	0f b6 82 40 65 10 f0 	movzbl -0xfef9ac0(%edx),%eax
f0100332:	83 c8 40             	or     $0x40,%eax
f0100335:	0f b6 c0             	movzbl %al,%eax
f0100338:	f7 d0                	not    %eax
f010033a:	21 c8                	and    %ecx,%eax
f010033c:	a3 00 f0 29 f0       	mov    %eax,0xf029f000
		return 0;
f0100341:	b8 00 00 00 00       	mov    $0x0,%eax
f0100346:	e9 9e 00 00 00       	jmp    f01003e9 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010034b:	8b 0d 00 f0 29 f0    	mov    0xf029f000,%ecx
f0100351:	f6 c1 40             	test   $0x40,%cl
f0100354:	74 0e                	je     f0100364 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100356:	83 c8 80             	or     $0xffffff80,%eax
f0100359:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010035b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035e:	89 0d 00 f0 29 f0    	mov    %ecx,0xf029f000
	}

	shift |= shiftcode[data];
f0100364:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100367:	0f b6 82 40 65 10 f0 	movzbl -0xfef9ac0(%edx),%eax
f010036e:	0b 05 00 f0 29 f0    	or     0xf029f000,%eax
f0100374:	0f b6 8a 40 64 10 f0 	movzbl -0xfef9bc0(%edx),%ecx
f010037b:	31 c8                	xor    %ecx,%eax
f010037d:	a3 00 f0 29 f0       	mov    %eax,0xf029f000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100382:	89 c1                	mov    %eax,%ecx
f0100384:	83 e1 03             	and    $0x3,%ecx
f0100387:	8b 0c 8d 20 64 10 f0 	mov    -0xfef9be0(,%ecx,4),%ecx
f010038e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100392:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100395:	a8 08                	test   $0x8,%al
f0100397:	74 1b                	je     f01003b4 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100399:	89 da                	mov    %ebx,%edx
f010039b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010039e:	83 f9 19             	cmp    $0x19,%ecx
f01003a1:	77 05                	ja     f01003a8 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01003a3:	83 eb 20             	sub    $0x20,%ebx
f01003a6:	eb 0c                	jmp    f01003b4 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01003a8:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ab:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003ae:	83 fa 19             	cmp    $0x19,%edx
f01003b1:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003b4:	f7 d0                	not    %eax
f01003b6:	a8 06                	test   $0x6,%al
f01003b8:	75 2d                	jne    f01003e7 <kbd_proc_data+0x104>
f01003ba:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003c0:	75 25                	jne    f01003e7 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003c2:	83 ec 0c             	sub    $0xc,%esp
f01003c5:	68 e3 63 10 f0       	push   $0xf01063e3
f01003ca:	e8 82 32 00 00       	call   f0103651 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cf:	ba 92 00 00 00       	mov    $0x92,%edx
f01003d4:	b8 03 00 00 00       	mov    $0x3,%eax
f01003d9:	ee                   	out    %al,(%dx)
f01003da:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003dd:	89 d8                	mov    %ebx,%eax
f01003df:	eb 08                	jmp    f01003e9 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003e6:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003e7:	89 d8                	mov    %ebx,%eax
}
f01003e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003ec:	c9                   	leave  
f01003ed:	c3                   	ret    

f01003ee <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003ee:	55                   	push   %ebp
f01003ef:	89 e5                	mov    %esp,%ebp
f01003f1:	57                   	push   %edi
f01003f2:	56                   	push   %esi
f01003f3:	53                   	push   %ebx
f01003f4:	83 ec 1c             	sub    $0x1c,%esp
f01003f7:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003f9:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003fe:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100403:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100408:	eb 09                	jmp    f0100413 <cons_putc+0x25>
f010040a:	89 ca                	mov    %ecx,%edx
f010040c:	ec                   	in     (%dx),%al
f010040d:	ec                   	in     (%dx),%al
f010040e:	ec                   	in     (%dx),%al
f010040f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100410:	83 c3 01             	add    $0x1,%ebx
f0100413:	89 f2                	mov    %esi,%edx
f0100415:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100416:	a8 20                	test   $0x20,%al
f0100418:	75 08                	jne    f0100422 <cons_putc+0x34>
f010041a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100420:	7e e8                	jle    f010040a <cons_putc+0x1c>
f0100422:	89 f8                	mov    %edi,%eax
f0100424:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100427:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010042c:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010042d:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100432:	be 79 03 00 00       	mov    $0x379,%esi
f0100437:	b9 84 00 00 00       	mov    $0x84,%ecx
f010043c:	eb 09                	jmp    f0100447 <cons_putc+0x59>
f010043e:	89 ca                	mov    %ecx,%edx
f0100440:	ec                   	in     (%dx),%al
f0100441:	ec                   	in     (%dx),%al
f0100442:	ec                   	in     (%dx),%al
f0100443:	ec                   	in     (%dx),%al
f0100444:	83 c3 01             	add    $0x1,%ebx
f0100447:	89 f2                	mov    %esi,%edx
f0100449:	ec                   	in     (%dx),%al
f010044a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100450:	7f 04                	jg     f0100456 <cons_putc+0x68>
f0100452:	84 c0                	test   %al,%al
f0100454:	79 e8                	jns    f010043e <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100456:	ba 78 03 00 00       	mov    $0x378,%edx
f010045b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010045f:	ee                   	out    %al,(%dx)
f0100460:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100465:	b8 0d 00 00 00       	mov    $0xd,%eax
f010046a:	ee                   	out    %al,(%dx)
f010046b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100470:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100471:	89 fa                	mov    %edi,%edx
f0100473:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100479:	89 f8                	mov    %edi,%eax
f010047b:	80 cc 07             	or     $0x7,%ah
f010047e:	85 d2                	test   %edx,%edx
f0100480:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100483:	89 f8                	mov    %edi,%eax
f0100485:	0f b6 c0             	movzbl %al,%eax
f0100488:	83 f8 09             	cmp    $0x9,%eax
f010048b:	74 74                	je     f0100501 <cons_putc+0x113>
f010048d:	83 f8 09             	cmp    $0x9,%eax
f0100490:	7f 0a                	jg     f010049c <cons_putc+0xae>
f0100492:	83 f8 08             	cmp    $0x8,%eax
f0100495:	74 14                	je     f01004ab <cons_putc+0xbd>
f0100497:	e9 99 00 00 00       	jmp    f0100535 <cons_putc+0x147>
f010049c:	83 f8 0a             	cmp    $0xa,%eax
f010049f:	74 3a                	je     f01004db <cons_putc+0xed>
f01004a1:	83 f8 0d             	cmp    $0xd,%eax
f01004a4:	74 3d                	je     f01004e3 <cons_putc+0xf5>
f01004a6:	e9 8a 00 00 00       	jmp    f0100535 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004ab:	0f b7 05 28 f2 29 f0 	movzwl 0xf029f228,%eax
f01004b2:	66 85 c0             	test   %ax,%ax
f01004b5:	0f 84 e6 00 00 00    	je     f01005a1 <cons_putc+0x1b3>
			crt_pos--;
f01004bb:	83 e8 01             	sub    $0x1,%eax
f01004be:	66 a3 28 f2 29 f0    	mov    %ax,0xf029f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004c4:	0f b7 c0             	movzwl %ax,%eax
f01004c7:	66 81 e7 00 ff       	and    $0xff00,%di
f01004cc:	83 cf 20             	or     $0x20,%edi
f01004cf:	8b 15 2c f2 29 f0    	mov    0xf029f22c,%edx
f01004d5:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004d9:	eb 78                	jmp    f0100553 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004db:	66 83 05 28 f2 29 f0 	addw   $0x50,0xf029f228
f01004e2:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004e3:	0f b7 05 28 f2 29 f0 	movzwl 0xf029f228,%eax
f01004ea:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f0:	c1 e8 16             	shr    $0x16,%eax
f01004f3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004f6:	c1 e0 04             	shl    $0x4,%eax
f01004f9:	66 a3 28 f2 29 f0    	mov    %ax,0xf029f228
f01004ff:	eb 52                	jmp    f0100553 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100501:	b8 20 00 00 00       	mov    $0x20,%eax
f0100506:	e8 e3 fe ff ff       	call   f01003ee <cons_putc>
		cons_putc(' ');
f010050b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100510:	e8 d9 fe ff ff       	call   f01003ee <cons_putc>
		cons_putc(' ');
f0100515:	b8 20 00 00 00       	mov    $0x20,%eax
f010051a:	e8 cf fe ff ff       	call   f01003ee <cons_putc>
		cons_putc(' ');
f010051f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100524:	e8 c5 fe ff ff       	call   f01003ee <cons_putc>
		cons_putc(' ');
f0100529:	b8 20 00 00 00       	mov    $0x20,%eax
f010052e:	e8 bb fe ff ff       	call   f01003ee <cons_putc>
f0100533:	eb 1e                	jmp    f0100553 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100535:	0f b7 05 28 f2 29 f0 	movzwl 0xf029f228,%eax
f010053c:	8d 50 01             	lea    0x1(%eax),%edx
f010053f:	66 89 15 28 f2 29 f0 	mov    %dx,0xf029f228
f0100546:	0f b7 c0             	movzwl %ax,%eax
f0100549:	8b 15 2c f2 29 f0    	mov    0xf029f22c,%edx
f010054f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100553:	66 81 3d 28 f2 29 f0 	cmpw   $0x7cf,0xf029f228
f010055a:	cf 07 
f010055c:	76 43                	jbe    f01005a1 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010055e:	a1 2c f2 29 f0       	mov    0xf029f22c,%eax
f0100563:	83 ec 04             	sub    $0x4,%esp
f0100566:	68 00 0f 00 00       	push   $0xf00
f010056b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100571:	52                   	push   %edx
f0100572:	50                   	push   %eax
f0100573:	e8 cc 4b 00 00       	call   f0105144 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100578:	8b 15 2c f2 29 f0    	mov    0xf029f22c,%edx
f010057e:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100584:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010058a:	83 c4 10             	add    $0x10,%esp
f010058d:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100592:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100595:	39 d0                	cmp    %edx,%eax
f0100597:	75 f4                	jne    f010058d <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100599:	66 83 2d 28 f2 29 f0 	subw   $0x50,0xf029f228
f01005a0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a1:	8b 0d 30 f2 29 f0    	mov    0xf029f230,%ecx
f01005a7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ac:	89 ca                	mov    %ecx,%edx
f01005ae:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005af:	0f b7 1d 28 f2 29 f0 	movzwl 0xf029f228,%ebx
f01005b6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005b9:	89 d8                	mov    %ebx,%eax
f01005bb:	66 c1 e8 08          	shr    $0x8,%ax
f01005bf:	89 f2                	mov    %esi,%edx
f01005c1:	ee                   	out    %al,(%dx)
f01005c2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005c7:	89 ca                	mov    %ecx,%edx
f01005c9:	ee                   	out    %al,(%dx)
f01005ca:	89 d8                	mov    %ebx,%eax
f01005cc:	89 f2                	mov    %esi,%edx
f01005ce:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005d2:	5b                   	pop    %ebx
f01005d3:	5e                   	pop    %esi
f01005d4:	5f                   	pop    %edi
f01005d5:	5d                   	pop    %ebp
f01005d6:	c3                   	ret    

f01005d7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005d7:	80 3d 34 f2 29 f0 00 	cmpb   $0x0,0xf029f234
f01005de:	74 11                	je     f01005f1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005e0:	55                   	push   %ebp
f01005e1:	89 e5                	mov    %esp,%ebp
f01005e3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005e6:	b8 81 02 10 f0       	mov    $0xf0100281,%eax
f01005eb:	e8 b0 fc ff ff       	call   f01002a0 <cons_intr>
}
f01005f0:	c9                   	leave  
f01005f1:	f3 c3                	repz ret 

f01005f3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005f3:	55                   	push   %ebp
f01005f4:	89 e5                	mov    %esp,%ebp
f01005f6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005f9:	b8 e3 02 10 f0       	mov    $0xf01002e3,%eax
f01005fe:	e8 9d fc ff ff       	call   f01002a0 <cons_intr>
}
f0100603:	c9                   	leave  
f0100604:	c3                   	ret    

f0100605 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100605:	55                   	push   %ebp
f0100606:	89 e5                	mov    %esp,%ebp
f0100608:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010060b:	e8 c7 ff ff ff       	call   f01005d7 <serial_intr>
	kbd_intr();
f0100610:	e8 de ff ff ff       	call   f01005f3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100615:	a1 20 f2 29 f0       	mov    0xf029f220,%eax
f010061a:	3b 05 24 f2 29 f0    	cmp    0xf029f224,%eax
f0100620:	74 26                	je     f0100648 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100622:	8d 50 01             	lea    0x1(%eax),%edx
f0100625:	89 15 20 f2 29 f0    	mov    %edx,0xf029f220
f010062b:	0f b6 88 20 f0 29 f0 	movzbl -0xfd60fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100632:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100634:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010063a:	75 11                	jne    f010064d <cons_getc+0x48>
			cons.rpos = 0;
f010063c:	c7 05 20 f2 29 f0 00 	movl   $0x0,0xf029f220
f0100643:	00 00 00 
f0100646:	eb 05                	jmp    f010064d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100648:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010064d:	c9                   	leave  
f010064e:	c3                   	ret    

f010064f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010064f:	55                   	push   %ebp
f0100650:	89 e5                	mov    %esp,%ebp
f0100652:	57                   	push   %edi
f0100653:	56                   	push   %esi
f0100654:	53                   	push   %ebx
f0100655:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100658:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010065f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100666:	5a a5 
	if (*cp != 0xA55A) {
f0100668:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010066f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100673:	74 11                	je     f0100686 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100675:	c7 05 30 f2 29 f0 b4 	movl   $0x3b4,0xf029f230
f010067c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010067f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100684:	eb 16                	jmp    f010069c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100686:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010068d:	c7 05 30 f2 29 f0 d4 	movl   $0x3d4,0xf029f230
f0100694:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100697:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010069c:	8b 3d 30 f2 29 f0    	mov    0xf029f230,%edi
f01006a2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006a7:	89 fa                	mov    %edi,%edx
f01006a9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006aa:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ad:	89 da                	mov    %ebx,%edx
f01006af:	ec                   	in     (%dx),%al
f01006b0:	0f b6 c8             	movzbl %al,%ecx
f01006b3:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006b6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006bb:	89 fa                	mov    %edi,%edx
f01006bd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006be:	89 da                	mov    %ebx,%edx
f01006c0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006c1:	89 35 2c f2 29 f0    	mov    %esi,0xf029f22c
	crt_pos = pos;
f01006c7:	0f b6 c0             	movzbl %al,%eax
f01006ca:	09 c8                	or     %ecx,%eax
f01006cc:	66 a3 28 f2 29 f0    	mov    %ax,0xf029f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006d2:	e8 1c ff ff ff       	call   f01005f3 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006d7:	83 ec 0c             	sub    $0xc,%esp
f01006da:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01006e1:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006e6:	50                   	push   %eax
f01006e7:	e8 fe 2d 00 00       	call   f01034ea <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ec:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f6:	89 f2                	mov    %esi,%edx
f01006f8:	ee                   	out    %al,(%dx)
f01006f9:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006fe:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100703:	ee                   	out    %al,(%dx)
f0100704:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100709:	b8 0c 00 00 00       	mov    $0xc,%eax
f010070e:	89 da                	mov    %ebx,%edx
f0100710:	ee                   	out    %al,(%dx)
f0100711:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100716:	b8 00 00 00 00       	mov    $0x0,%eax
f010071b:	ee                   	out    %al,(%dx)
f010071c:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100721:	b8 03 00 00 00       	mov    $0x3,%eax
f0100726:	ee                   	out    %al,(%dx)
f0100727:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010072c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100731:	ee                   	out    %al,(%dx)
f0100732:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100737:	b8 01 00 00 00       	mov    $0x1,%eax
f010073c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100742:	ec                   	in     (%dx),%al
f0100743:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100745:	83 c4 10             	add    $0x10,%esp
f0100748:	3c ff                	cmp    $0xff,%al
f010074a:	0f 95 05 34 f2 29 f0 	setne  0xf029f234
f0100751:	89 f2                	mov    %esi,%edx
f0100753:	ec                   	in     (%dx),%al
f0100754:	89 da                	mov    %ebx,%edx
f0100756:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100757:	80 f9 ff             	cmp    $0xff,%cl
f010075a:	74 21                	je     f010077d <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f010075c:	83 ec 0c             	sub    $0xc,%esp
f010075f:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f0100766:	25 ef ff 00 00       	and    $0xffef,%eax
f010076b:	50                   	push   %eax
f010076c:	e8 79 2d 00 00       	call   f01034ea <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100771:	83 c4 10             	add    $0x10,%esp
f0100774:	80 3d 34 f2 29 f0 00 	cmpb   $0x0,0xf029f234
f010077b:	75 10                	jne    f010078d <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f010077d:	83 ec 0c             	sub    $0xc,%esp
f0100780:	68 ef 63 10 f0       	push   $0xf01063ef
f0100785:	e8 c7 2e 00 00       	call   f0103651 <cprintf>
f010078a:	83 c4 10             	add    $0x10,%esp
}
f010078d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100790:	5b                   	pop    %ebx
f0100791:	5e                   	pop    %esi
f0100792:	5f                   	pop    %edi
f0100793:	5d                   	pop    %ebp
f0100794:	c3                   	ret    

f0100795 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100795:	55                   	push   %ebp
f0100796:	89 e5                	mov    %esp,%ebp
f0100798:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010079b:	8b 45 08             	mov    0x8(%ebp),%eax
f010079e:	e8 4b fc ff ff       	call   f01003ee <cons_putc>
}
f01007a3:	c9                   	leave  
f01007a4:	c3                   	ret    

f01007a5 <getchar>:

int
getchar(void)
{
f01007a5:	55                   	push   %ebp
f01007a6:	89 e5                	mov    %esp,%ebp
f01007a8:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007ab:	e8 55 fe ff ff       	call   f0100605 <cons_getc>
f01007b0:	85 c0                	test   %eax,%eax
f01007b2:	74 f7                	je     f01007ab <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b4:	c9                   	leave  
f01007b5:	c3                   	ret    

f01007b6 <iscons>:

int
iscons(int fdnum)
{
f01007b6:	55                   	push   %ebp
f01007b7:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007b9:	b8 01 00 00 00       	mov    $0x1,%eax
f01007be:	5d                   	pop    %ebp
f01007bf:	c3                   	ret    

f01007c0 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c0:	55                   	push   %ebp
f01007c1:	89 e5                	mov    %esp,%ebp
f01007c3:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007c6:	68 40 66 10 f0       	push   $0xf0106640
f01007cb:	68 5e 66 10 f0       	push   $0xf010665e
f01007d0:	68 63 66 10 f0       	push   $0xf0106663
f01007d5:	e8 77 2e 00 00       	call   f0103651 <cprintf>
f01007da:	83 c4 0c             	add    $0xc,%esp
f01007dd:	68 cc 66 10 f0       	push   $0xf01066cc
f01007e2:	68 6c 66 10 f0       	push   $0xf010666c
f01007e7:	68 63 66 10 f0       	push   $0xf0106663
f01007ec:	e8 60 2e 00 00       	call   f0103651 <cprintf>
	return 0;
}
f01007f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f6:	c9                   	leave  
f01007f7:	c3                   	ret    

f01007f8 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f8:	55                   	push   %ebp
f01007f9:	89 e5                	mov    %esp,%ebp
f01007fb:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007fe:	68 75 66 10 f0       	push   $0xf0106675
f0100803:	e8 49 2e 00 00       	call   f0103651 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100808:	83 c4 08             	add    $0x8,%esp
f010080b:	68 0c 00 10 00       	push   $0x10000c
f0100810:	68 f4 66 10 f0       	push   $0xf01066f4
f0100815:	e8 37 2e 00 00       	call   f0103651 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010081a:	83 c4 0c             	add    $0xc,%esp
f010081d:	68 0c 00 10 00       	push   $0x10000c
f0100822:	68 0c 00 10 f0       	push   $0xf010000c
f0100827:	68 1c 67 10 f0       	push   $0xf010671c
f010082c:	e8 20 2e 00 00       	call   f0103651 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100831:	83 c4 0c             	add    $0xc,%esp
f0100834:	68 11 63 10 00       	push   $0x106311
f0100839:	68 11 63 10 f0       	push   $0xf0106311
f010083e:	68 40 67 10 f0       	push   $0xf0106740
f0100843:	e8 09 2e 00 00       	call   f0103651 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100848:	83 c4 0c             	add    $0xc,%esp
f010084b:	68 50 e8 29 00       	push   $0x29e850
f0100850:	68 50 e8 29 f0       	push   $0xf029e850
f0100855:	68 64 67 10 f0       	push   $0xf0106764
f010085a:	e8 f2 2d 00 00       	call   f0103651 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010085f:	83 c4 0c             	add    $0xc,%esp
f0100862:	68 08 10 2e 00       	push   $0x2e1008
f0100867:	68 08 10 2e f0       	push   $0xf02e1008
f010086c:	68 88 67 10 f0       	push   $0xf0106788
f0100871:	e8 db 2d 00 00       	call   f0103651 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100876:	b8 07 14 2e f0       	mov    $0xf02e1407,%eax
f010087b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100880:	83 c4 08             	add    $0x8,%esp
f0100883:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100888:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010088e:	85 c0                	test   %eax,%eax
f0100890:	0f 48 c2             	cmovs  %edx,%eax
f0100893:	c1 f8 0a             	sar    $0xa,%eax
f0100896:	50                   	push   %eax
f0100897:	68 ac 67 10 f0       	push   $0xf01067ac
f010089c:	e8 b0 2d 00 00       	call   f0103651 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a6:	c9                   	leave  
f01008a7:	c3                   	ret    

f01008a8 <mon_backtrace>:

// TODO: Implement lab1's backtrace monitor command
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a8:	55                   	push   %ebp
f01008a9:	89 e5                	mov    %esp,%ebp
f01008ab:	56                   	push   %esi
f01008ac:	53                   	push   %ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ad:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t a = read_ebp();

        int i = 8;
        int *ebp = (int*) a;
f01008af:	be 08 00 00 00       	mov    $0x8,%esi
        while(i > 0) {
                cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008b4:	ff 73 18             	pushl  0x18(%ebx)
f01008b7:	ff 73 14             	pushl  0x14(%ebx)
f01008ba:	ff 73 10             	pushl  0x10(%ebx)
f01008bd:	ff 73 0c             	pushl  0xc(%ebx)
f01008c0:	ff 73 08             	pushl  0x8(%ebx)
f01008c3:	ff 73 04             	pushl  0x4(%ebx)
f01008c6:	53                   	push   %ebx
f01008c7:	68 d8 67 10 f0       	push   $0xf01067d8
f01008cc:	e8 80 2d 00 00       	call   f0103651 <cprintf>
                         ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
                ebp = (int*) ebp[0];
f01008d1:	8b 1b                	mov    (%ebx),%ebx
	// Your code here.
	uint32_t a = read_ebp();

        int i = 8;
        int *ebp = (int*) a;
        while(i > 0) {
f01008d3:	83 c4 20             	add    $0x20,%esp
f01008d6:	83 ee 01             	sub    $0x1,%esi
f01008d9:	75 d9                	jne    f01008b4 <mon_backtrace+0xc>
                ebp = (int*) ebp[0];
                i--;
        }

        return 0;
}
f01008db:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008e3:	5b                   	pop    %ebx
f01008e4:	5e                   	pop    %esi
f01008e5:	5d                   	pop    %ebp
f01008e6:	c3                   	ret    

f01008e7 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008e7:	55                   	push   %ebp
f01008e8:	89 e5                	mov    %esp,%ebp
f01008ea:	57                   	push   %edi
f01008eb:	56                   	push   %esi
f01008ec:	53                   	push   %ebx
f01008ed:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008f0:	68 0c 68 10 f0       	push   $0xf010680c
f01008f5:	e8 57 2d 00 00       	call   f0103651 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008fa:	c7 04 24 30 68 10 f0 	movl   $0xf0106830,(%esp)
f0100901:	e8 4b 2d 00 00       	call   f0103651 <cprintf>

	if (tf != NULL)
f0100906:	83 c4 10             	add    $0x10,%esp
f0100909:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010090d:	74 0e                	je     f010091d <monitor+0x36>
		print_trapframe(tf);
f010090f:	83 ec 0c             	sub    $0xc,%esp
f0100912:	ff 75 08             	pushl  0x8(%ebp)
f0100915:	e8 8e 2f 00 00       	call   f01038a8 <print_trapframe>
f010091a:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010091d:	83 ec 0c             	sub    $0xc,%esp
f0100920:	68 8e 66 10 f0       	push   $0xf010668e
f0100925:	e8 5e 45 00 00       	call   f0104e88 <readline>
f010092a:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010092c:	83 c4 10             	add    $0x10,%esp
f010092f:	85 c0                	test   %eax,%eax
f0100931:	74 ea                	je     f010091d <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100933:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010093a:	be 00 00 00 00       	mov    $0x0,%esi
f010093f:	eb 0a                	jmp    f010094b <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100941:	c6 03 00             	movb   $0x0,(%ebx)
f0100944:	89 f7                	mov    %esi,%edi
f0100946:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100949:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010094b:	0f b6 03             	movzbl (%ebx),%eax
f010094e:	84 c0                	test   %al,%al
f0100950:	74 63                	je     f01009b5 <monitor+0xce>
f0100952:	83 ec 08             	sub    $0x8,%esp
f0100955:	0f be c0             	movsbl %al,%eax
f0100958:	50                   	push   %eax
f0100959:	68 92 66 10 f0       	push   $0xf0106692
f010095e:	e8 57 47 00 00       	call   f01050ba <strchr>
f0100963:	83 c4 10             	add    $0x10,%esp
f0100966:	85 c0                	test   %eax,%eax
f0100968:	75 d7                	jne    f0100941 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f010096a:	80 3b 00             	cmpb   $0x0,(%ebx)
f010096d:	74 46                	je     f01009b5 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010096f:	83 fe 0f             	cmp    $0xf,%esi
f0100972:	75 14                	jne    f0100988 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100974:	83 ec 08             	sub    $0x8,%esp
f0100977:	6a 10                	push   $0x10
f0100979:	68 97 66 10 f0       	push   $0xf0106697
f010097e:	e8 ce 2c 00 00       	call   f0103651 <cprintf>
f0100983:	83 c4 10             	add    $0x10,%esp
f0100986:	eb 95                	jmp    f010091d <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100988:	8d 7e 01             	lea    0x1(%esi),%edi
f010098b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010098f:	eb 03                	jmp    f0100994 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100991:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100994:	0f b6 03             	movzbl (%ebx),%eax
f0100997:	84 c0                	test   %al,%al
f0100999:	74 ae                	je     f0100949 <monitor+0x62>
f010099b:	83 ec 08             	sub    $0x8,%esp
f010099e:	0f be c0             	movsbl %al,%eax
f01009a1:	50                   	push   %eax
f01009a2:	68 92 66 10 f0       	push   $0xf0106692
f01009a7:	e8 0e 47 00 00       	call   f01050ba <strchr>
f01009ac:	83 c4 10             	add    $0x10,%esp
f01009af:	85 c0                	test   %eax,%eax
f01009b1:	74 de                	je     f0100991 <monitor+0xaa>
f01009b3:	eb 94                	jmp    f0100949 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009b5:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009bc:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009bd:	85 f6                	test   %esi,%esi
f01009bf:	0f 84 58 ff ff ff    	je     f010091d <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009c5:	83 ec 08             	sub    $0x8,%esp
f01009c8:	68 5e 66 10 f0       	push   $0xf010665e
f01009cd:	ff 75 a8             	pushl  -0x58(%ebp)
f01009d0:	e8 87 46 00 00       	call   f010505c <strcmp>
f01009d5:	83 c4 10             	add    $0x10,%esp
f01009d8:	85 c0                	test   %eax,%eax
f01009da:	74 1e                	je     f01009fa <monitor+0x113>
f01009dc:	83 ec 08             	sub    $0x8,%esp
f01009df:	68 6c 66 10 f0       	push   $0xf010666c
f01009e4:	ff 75 a8             	pushl  -0x58(%ebp)
f01009e7:	e8 70 46 00 00       	call   f010505c <strcmp>
f01009ec:	83 c4 10             	add    $0x10,%esp
f01009ef:	85 c0                	test   %eax,%eax
f01009f1:	75 2f                	jne    f0100a22 <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009f3:	b8 01 00 00 00       	mov    $0x1,%eax
f01009f8:	eb 05                	jmp    f01009ff <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f01009fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01009ff:	83 ec 04             	sub    $0x4,%esp
f0100a02:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100a05:	01 d0                	add    %edx,%eax
f0100a07:	ff 75 08             	pushl  0x8(%ebp)
f0100a0a:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100a0d:	51                   	push   %ecx
f0100a0e:	56                   	push   %esi
f0100a0f:	ff 14 85 60 68 10 f0 	call   *-0xfef97a0(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a16:	83 c4 10             	add    $0x10,%esp
f0100a19:	85 c0                	test   %eax,%eax
f0100a1b:	78 1d                	js     f0100a3a <monitor+0x153>
f0100a1d:	e9 fb fe ff ff       	jmp    f010091d <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a22:	83 ec 08             	sub    $0x8,%esp
f0100a25:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a28:	68 b4 66 10 f0       	push   $0xf01066b4
f0100a2d:	e8 1f 2c 00 00       	call   f0103651 <cprintf>
f0100a32:	83 c4 10             	add    $0x10,%esp
f0100a35:	e9 e3 fe ff ff       	jmp    f010091d <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a3d:	5b                   	pop    %ebx
f0100a3e:	5e                   	pop    %esi
f0100a3f:	5f                   	pop    %edi
f0100a40:	5d                   	pop    %ebp
f0100a41:	c3                   	ret    

f0100a42 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a42:	89 d1                	mov    %edx,%ecx
f0100a44:	c1 e9 16             	shr    $0x16,%ecx
f0100a47:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a4a:	a8 01                	test   $0x1,%al
f0100a4c:	74 52                	je     f0100aa0 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a53:	89 c1                	mov    %eax,%ecx
f0100a55:	c1 e9 0c             	shr    $0xc,%ecx
f0100a58:	3b 0d 94 fe 29 f0    	cmp    0xf029fe94,%ecx
f0100a5e:	72 1b                	jb     f0100a7b <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a60:	55                   	push   %ebp
f0100a61:	89 e5                	mov    %esp,%ebp
f0100a63:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a66:	50                   	push   %eax
f0100a67:	68 44 63 10 f0       	push   $0xf0106344
f0100a6c:	68 b4 03 00 00       	push   $0x3b4
f0100a71:	68 3d 72 10 f0       	push   $0xf010723d
f0100a76:	e8 c5 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a7b:	c1 ea 0c             	shr    $0xc,%edx
f0100a7e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a84:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a8b:	89 c2                	mov    %eax,%edx
f0100a8d:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a95:	85 d2                	test   %edx,%edx
f0100a97:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a9c:	0f 44 c2             	cmove  %edx,%eax
f0100a9f:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100aa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100aa5:	c3                   	ret    

f0100aa6 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100aa6:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aa8:	83 3d 38 f2 29 f0 00 	cmpl   $0x0,0xf029f238
f0100aaf:	75 0f                	jne    f0100ac0 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ab1:	b8 07 20 2e f0       	mov    $0xf02e2007,%eax
f0100ab6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100abb:	a3 38 f2 29 f0       	mov    %eax,0xf029f238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	// TODO: Test if 'panic: out of memory' is working
	result = nextfree;
f0100ac0:	a1 38 f2 29 f0       	mov    0xf029f238,%eax
	if (n > 0) {
f0100ac5:	85 d2                	test   %edx,%edx
f0100ac7:	74 5f                	je     f0100b28 <boot_alloc+0x82>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ac9:	55                   	push   %ebp
f0100aca:	89 e5                	mov    %esp,%ebp
f0100acc:	53                   	push   %ebx
f0100acd:	83 ec 04             	sub    $0x4,%esp
	//
	// LAB 2: Your code here.
	// TODO: Test if 'panic: out of memory' is working
	result = nextfree;
	if (n > 0) {
		if ((uint32_t) PADDR(ROUNDUP(nextfree+n, PGSIZE)) > npages*PGSIZE)
f0100ad0:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100ad7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100add:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100ae3:	77 12                	ja     f0100af7 <boot_alloc+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ae5:	52                   	push   %edx
f0100ae6:	68 68 63 10 f0       	push   $0xf0106368
f0100aeb:	6a 6b                	push   $0x6b
f0100aed:	68 3d 72 10 f0       	push   $0xf010723d
f0100af2:	e8 49 f5 ff ff       	call   f0100040 <_panic>
f0100af7:	8b 0d 94 fe 29 f0    	mov    0xf029fe94,%ecx
f0100afd:	c1 e1 0c             	shl    $0xc,%ecx
f0100b00:	8d 9a 00 00 00 10    	lea    0x10000000(%edx),%ebx
f0100b06:	39 d9                	cmp    %ebx,%ecx
f0100b08:	73 14                	jae    f0100b1e <boot_alloc+0x78>
			panic("boot_alloc: out of memory");
f0100b0a:	83 ec 04             	sub    $0x4,%esp
f0100b0d:	68 49 72 10 f0       	push   $0xf0107249
f0100b12:	6a 6c                	push   $0x6c
f0100b14:	68 3d 72 10 f0       	push   $0xf010723d
f0100b19:	e8 22 f5 ff ff       	call   f0100040 <_panic>
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100b1e:	89 15 38 f2 29 f0    	mov    %edx,0xf029f238
	}
	return result;
}
f0100b24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b27:	c9                   	leave  
f0100b28:	f3 c3                	repz ret 

f0100b2a <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b2a:	55                   	push   %ebp
f0100b2b:	89 e5                	mov    %esp,%ebp
f0100b2d:	57                   	push   %edi
f0100b2e:	56                   	push   %esi
f0100b2f:	53                   	push   %ebx
f0100b30:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b33:	84 c0                	test   %al,%al
f0100b35:	0f 85 91 02 00 00    	jne    f0100dcc <check_page_free_list+0x2a2>
f0100b3b:	e9 9e 02 00 00       	jmp    f0100dde <check_page_free_list+0x2b4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b40:	83 ec 04             	sub    $0x4,%esp
f0100b43:	68 70 68 10 f0       	push   $0xf0106870
f0100b48:	68 e9 02 00 00       	push   $0x2e9
f0100b4d:	68 3d 72 10 f0       	push   $0xf010723d
f0100b52:	e8 e9 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b57:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b5a:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b5d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b60:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b63:	89 c2                	mov    %eax,%edx
f0100b65:	2b 15 9c fe 29 f0    	sub    0xf029fe9c,%edx
f0100b6b:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b71:	0f 95 c2             	setne  %dl
f0100b74:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b77:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b7b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b7d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b81:	8b 00                	mov    (%eax),%eax
f0100b83:	85 c0                	test   %eax,%eax
f0100b85:	75 dc                	jne    f0100b63 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b8a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b90:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b93:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b96:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b98:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b9b:	a3 40 f2 29 f0       	mov    %eax,0xf029f240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ba0:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ba5:	8b 1d 40 f2 29 f0    	mov    0xf029f240,%ebx
f0100bab:	eb 53                	jmp    f0100c00 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bad:	89 d8                	mov    %ebx,%eax
f0100baf:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0100bb5:	c1 f8 03             	sar    $0x3,%eax
f0100bb8:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bbb:	89 c2                	mov    %eax,%edx
f0100bbd:	c1 ea 16             	shr    $0x16,%edx
f0100bc0:	39 f2                	cmp    %esi,%edx
f0100bc2:	73 3a                	jae    f0100bfe <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bc4:	89 c2                	mov    %eax,%edx
f0100bc6:	c1 ea 0c             	shr    $0xc,%edx
f0100bc9:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f0100bcf:	72 12                	jb     f0100be3 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bd1:	50                   	push   %eax
f0100bd2:	68 44 63 10 f0       	push   $0xf0106344
f0100bd7:	6a 58                	push   $0x58
f0100bd9:	68 63 72 10 f0       	push   $0xf0107263
f0100bde:	e8 5d f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100be3:	83 ec 04             	sub    $0x4,%esp
f0100be6:	68 80 00 00 00       	push   $0x80
f0100beb:	68 97 00 00 00       	push   $0x97
f0100bf0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bf5:	50                   	push   %eax
f0100bf6:	e8 fc 44 00 00       	call   f01050f7 <memset>
f0100bfb:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bfe:	8b 1b                	mov    (%ebx),%ebx
f0100c00:	85 db                	test   %ebx,%ebx
f0100c02:	75 a9                	jne    f0100bad <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c04:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c09:	e8 98 fe ff ff       	call   f0100aa6 <boot_alloc>
f0100c0e:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c11:	8b 15 40 f2 29 f0    	mov    0xf029f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c17:	8b 0d 9c fe 29 f0    	mov    0xf029fe9c,%ecx
		assert(pp < pages + npages);
f0100c1d:	a1 94 fe 29 f0       	mov    0xf029fe94,%eax
f0100c22:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c25:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c28:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c2b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c2e:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c33:	e9 52 01 00 00       	jmp    f0100d8a <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c38:	39 ca                	cmp    %ecx,%edx
f0100c3a:	73 19                	jae    f0100c55 <check_page_free_list+0x12b>
f0100c3c:	68 71 72 10 f0       	push   $0xf0107271
f0100c41:	68 7d 72 10 f0       	push   $0xf010727d
f0100c46:	68 03 03 00 00       	push   $0x303
f0100c4b:	68 3d 72 10 f0       	push   $0xf010723d
f0100c50:	e8 eb f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c55:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c58:	72 19                	jb     f0100c73 <check_page_free_list+0x149>
f0100c5a:	68 92 72 10 f0       	push   $0xf0107292
f0100c5f:	68 7d 72 10 f0       	push   $0xf010727d
f0100c64:	68 04 03 00 00       	push   $0x304
f0100c69:	68 3d 72 10 f0       	push   $0xf010723d
f0100c6e:	e8 cd f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c73:	89 d0                	mov    %edx,%eax
f0100c75:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c78:	a8 07                	test   $0x7,%al
f0100c7a:	74 19                	je     f0100c95 <check_page_free_list+0x16b>
f0100c7c:	68 94 68 10 f0       	push   $0xf0106894
f0100c81:	68 7d 72 10 f0       	push   $0xf010727d
f0100c86:	68 05 03 00 00       	push   $0x305
f0100c8b:	68 3d 72 10 f0       	push   $0xf010723d
f0100c90:	e8 ab f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c95:	c1 f8 03             	sar    $0x3,%eax
f0100c98:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c9b:	85 c0                	test   %eax,%eax
f0100c9d:	75 19                	jne    f0100cb8 <check_page_free_list+0x18e>
f0100c9f:	68 a6 72 10 f0       	push   $0xf01072a6
f0100ca4:	68 7d 72 10 f0       	push   $0xf010727d
f0100ca9:	68 08 03 00 00       	push   $0x308
f0100cae:	68 3d 72 10 f0       	push   $0xf010723d
f0100cb3:	e8 88 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cb8:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cbd:	75 19                	jne    f0100cd8 <check_page_free_list+0x1ae>
f0100cbf:	68 b7 72 10 f0       	push   $0xf01072b7
f0100cc4:	68 7d 72 10 f0       	push   $0xf010727d
f0100cc9:	68 09 03 00 00       	push   $0x309
f0100cce:	68 3d 72 10 f0       	push   $0xf010723d
f0100cd3:	e8 68 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cd8:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cdd:	75 19                	jne    f0100cf8 <check_page_free_list+0x1ce>
f0100cdf:	68 c8 68 10 f0       	push   $0xf01068c8
f0100ce4:	68 7d 72 10 f0       	push   $0xf010727d
f0100ce9:	68 0a 03 00 00       	push   $0x30a
f0100cee:	68 3d 72 10 f0       	push   $0xf010723d
f0100cf3:	e8 48 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cf8:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100cfd:	75 19                	jne    f0100d18 <check_page_free_list+0x1ee>
f0100cff:	68 d0 72 10 f0       	push   $0xf01072d0
f0100d04:	68 7d 72 10 f0       	push   $0xf010727d
f0100d09:	68 0b 03 00 00       	push   $0x30b
f0100d0e:	68 3d 72 10 f0       	push   $0xf010723d
f0100d13:	e8 28 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d18:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d1d:	0f 86 de 00 00 00    	jbe    f0100e01 <check_page_free_list+0x2d7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d23:	89 c7                	mov    %eax,%edi
f0100d25:	c1 ef 0c             	shr    $0xc,%edi
f0100d28:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d2b:	77 12                	ja     f0100d3f <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d2d:	50                   	push   %eax
f0100d2e:	68 44 63 10 f0       	push   $0xf0106344
f0100d33:	6a 58                	push   $0x58
f0100d35:	68 63 72 10 f0       	push   $0xf0107263
f0100d3a:	e8 01 f3 ff ff       	call   f0100040 <_panic>
f0100d3f:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d45:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d48:	0f 86 a7 00 00 00    	jbe    f0100df5 <check_page_free_list+0x2cb>
f0100d4e:	68 ec 68 10 f0       	push   $0xf01068ec
f0100d53:	68 7d 72 10 f0       	push   $0xf010727d
f0100d58:	68 0c 03 00 00       	push   $0x30c
f0100d5d:	68 3d 72 10 f0       	push   $0xf010723d
f0100d62:	e8 d9 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d67:	68 ea 72 10 f0       	push   $0xf01072ea
f0100d6c:	68 7d 72 10 f0       	push   $0xf010727d
f0100d71:	68 0e 03 00 00       	push   $0x30e
f0100d76:	68 3d 72 10 f0       	push   $0xf010723d
f0100d7b:	e8 c0 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d80:	83 c6 01             	add    $0x1,%esi
f0100d83:	eb 03                	jmp    f0100d88 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100d85:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d88:	8b 12                	mov    (%edx),%edx
f0100d8a:	85 d2                	test   %edx,%edx
f0100d8c:	0f 85 a6 fe ff ff    	jne    f0100c38 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d92:	85 f6                	test   %esi,%esi
f0100d94:	7f 19                	jg     f0100daf <check_page_free_list+0x285>
f0100d96:	68 07 73 10 f0       	push   $0xf0107307
f0100d9b:	68 7d 72 10 f0       	push   $0xf010727d
f0100da0:	68 16 03 00 00       	push   $0x316
f0100da5:	68 3d 72 10 f0       	push   $0xf010723d
f0100daa:	e8 91 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100daf:	85 db                	test   %ebx,%ebx
f0100db1:	7f 5e                	jg     f0100e11 <check_page_free_list+0x2e7>
f0100db3:	68 19 73 10 f0       	push   $0xf0107319
f0100db8:	68 7d 72 10 f0       	push   $0xf010727d
f0100dbd:	68 17 03 00 00       	push   $0x317
f0100dc2:	68 3d 72 10 f0       	push   $0xf010723d
f0100dc7:	e8 74 f2 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100dcc:	a1 40 f2 29 f0       	mov    0xf029f240,%eax
f0100dd1:	85 c0                	test   %eax,%eax
f0100dd3:	0f 85 7e fd ff ff    	jne    f0100b57 <check_page_free_list+0x2d>
f0100dd9:	e9 62 fd ff ff       	jmp    f0100b40 <check_page_free_list+0x16>
f0100dde:	83 3d 40 f2 29 f0 00 	cmpl   $0x0,0xf029f240
f0100de5:	0f 84 55 fd ff ff    	je     f0100b40 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100deb:	be 00 04 00 00       	mov    $0x400,%esi
f0100df0:	e9 b0 fd ff ff       	jmp    f0100ba5 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100df5:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dfa:	75 89                	jne    f0100d85 <check_page_free_list+0x25b>
f0100dfc:	e9 66 ff ff ff       	jmp    f0100d67 <check_page_free_list+0x23d>
f0100e01:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e06:	0f 85 74 ff ff ff    	jne    f0100d80 <check_page_free_list+0x256>
f0100e0c:	e9 56 ff ff ff       	jmp    f0100d67 <check_page_free_list+0x23d>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e14:	5b                   	pop    %ebx
f0100e15:	5e                   	pop    %esi
f0100e16:	5f                   	pop    %edi
f0100e17:	5d                   	pop    %ebp
f0100e18:	c3                   	ret    

f0100e19 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e19:	55                   	push   %ebp
f0100e1a:	89 e5                	mov    %esp,%ebp
f0100e1c:	57                   	push   %edi
f0100e1d:	56                   	push   %esi
f0100e1e:	53                   	push   %ebx
f0100e1f:	83 ec 0c             	sub    $0xc,%esp
	//	pages[i].pp_ref = 0;
	//	pages[i].pp_link = page_free_list;
	//	page_free_list = &pages[i];
	//}
	//TODO: Check if it's needed to make pp_ref = 0, in the other pages
	pages[0].pp_ref = 0;
f0100e22:	a1 9c fe 29 f0       	mov    0xf029fe9c,%eax
f0100e27:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	pages[0].pp_link = NULL;
f0100e2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	size_t n_mpentry = ROUNDDOWN(MPENTRY_PADDR, PGSIZE)/PGSIZE;
	size_t n_io_hole_start = npages_basemem;
f0100e33:	8b 1d 44 f2 29 f0    	mov    0xf029f244,%ebx
	char *first_free_page = (char *) boot_alloc(0);
f0100e39:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e3e:	e8 63 fc ff ff       	call   f0100aa6 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e43:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e48:	77 15                	ja     f0100e5f <page_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e4a:	50                   	push   %eax
f0100e4b:	68 68 63 10 f0       	push   $0xf0106368
f0100e50:	68 51 01 00 00       	push   $0x151
f0100e55:	68 3d 72 10 f0       	push   $0xf010723d
f0100e5a:	e8 e1 f1 ff ff       	call   f0100040 <_panic>
	size_t first_free_page_number = PGNUM(PADDR(first_free_page));
f0100e5f:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e64:	c1 e8 0c             	shr    $0xc,%eax
f0100e67:	8b 35 40 f2 29 f0    	mov    0xf029f240,%esi

	size_t i;
	for (i = 0; i < npages; i++) {
f0100e6d:	bf 00 00 00 00       	mov    $0x0,%edi
f0100e72:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e77:	eb 4f                	jmp    f0100ec8 <page_init+0xaf>
		if (i == 0 || i == n_mpentry || (n_io_hole_start <= i && i < first_free_page_number)) {
f0100e79:	85 d2                	test   %edx,%edx
f0100e7b:	74 0d                	je     f0100e8a <page_init+0x71>
f0100e7d:	83 fa 07             	cmp    $0x7,%edx
f0100e80:	74 08                	je     f0100e8a <page_init+0x71>
f0100e82:	39 da                	cmp    %ebx,%edx
f0100e84:	72 1b                	jb     f0100ea1 <page_init+0x88>
f0100e86:	39 c2                	cmp    %eax,%edx
f0100e88:	73 17                	jae    f0100ea1 <page_init+0x88>
			pages[i].pp_ref = 0;
f0100e8a:	8b 0d 9c fe 29 f0    	mov    0xf029fe9c,%ecx
f0100e90:	8d 0c d1             	lea    (%ecx,%edx,8),%ecx
f0100e93:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = NULL;
f0100e99:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100e9f:	eb 24                	jmp    f0100ec5 <page_init+0xac>
f0100ea1:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
		} else {
			pages[i].pp_ref = 0;
f0100ea8:	89 cf                	mov    %ecx,%edi
f0100eaa:	03 3d 9c fe 29 f0    	add    0xf029fe9c,%edi
f0100eb0:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100eb6:	89 37                	mov    %esi,(%edi)
			page_free_list = &pages[i];
f0100eb8:	89 ce                	mov    %ecx,%esi
f0100eba:	03 35 9c fe 29 f0    	add    0xf029fe9c,%esi
f0100ec0:	bf 01 00 00 00       	mov    $0x1,%edi
	size_t n_io_hole_start = npages_basemem;
	char *first_free_page = (char *) boot_alloc(0);
	size_t first_free_page_number = PGNUM(PADDR(first_free_page));

	size_t i;
	for (i = 0; i < npages; i++) {
f0100ec5:	83 c2 01             	add    $0x1,%edx
f0100ec8:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f0100ece:	72 a9                	jb     f0100e79 <page_init+0x60>
f0100ed0:	89 f8                	mov    %edi,%eax
f0100ed2:	84 c0                	test   %al,%al
f0100ed4:	74 06                	je     f0100edc <page_init+0xc3>
f0100ed6:	89 35 40 f2 29 f0    	mov    %esi,0xf029f240
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100edc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100edf:	5b                   	pop    %ebx
f0100ee0:	5e                   	pop    %esi
f0100ee1:	5f                   	pop    %edi
f0100ee2:	5d                   	pop    %ebp
f0100ee3:	c3                   	ret    

f0100ee4 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100ee4:	55                   	push   %ebp
f0100ee5:	89 e5                	mov    %esp,%ebp
f0100ee7:	53                   	push   %ebx
f0100ee8:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

	// Test if it is out of memory
	if (!page_free_list)
f0100eeb:	8b 1d 40 f2 29 f0    	mov    0xf029f240,%ebx
f0100ef1:	85 db                	test   %ebx,%ebx
f0100ef3:	74 58                	je     f0100f4d <page_alloc+0x69>
		return NULL;

	// If it is not, release one page
	struct PageInfo *allocated_page;
	allocated_page = page_free_list;
	page_free_list = page_free_list->pp_link;
f0100ef5:	8b 03                	mov    (%ebx),%eax
f0100ef7:	a3 40 f2 29 f0       	mov    %eax,0xf029f240
	allocated_page->pp_link = NULL;
f0100efc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100f02:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f06:	74 45                	je     f0100f4d <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f08:	89 d8                	mov    %ebx,%eax
f0100f0a:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0100f10:	c1 f8 03             	sar    $0x3,%eax
f0100f13:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f16:	89 c2                	mov    %eax,%edx
f0100f18:	c1 ea 0c             	shr    $0xc,%edx
f0100f1b:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f0100f21:	72 12                	jb     f0100f35 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f23:	50                   	push   %eax
f0100f24:	68 44 63 10 f0       	push   $0xf0106344
f0100f29:	6a 58                	push   $0x58
f0100f2b:	68 63 72 10 f0       	push   $0xf0107263
f0100f30:	e8 0b f1 ff ff       	call   f0100040 <_panic>
		memset(page2kva(allocated_page), '\0', PGSIZE);
f0100f35:	83 ec 04             	sub    $0x4,%esp
f0100f38:	68 00 10 00 00       	push   $0x1000
f0100f3d:	6a 00                	push   $0x0
f0100f3f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f44:	50                   	push   %eax
f0100f45:	e8 ad 41 00 00       	call   f01050f7 <memset>
f0100f4a:	83 c4 10             	add    $0x10,%esp
	}
	return allocated_page;
}
f0100f4d:	89 d8                	mov    %ebx,%eax
f0100f4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f52:	c9                   	leave  
f0100f53:	c3                   	ret    

f0100f54 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f54:	55                   	push   %ebp
f0100f55:	89 e5                	mov    %esp,%ebp
f0100f57:	83 ec 08             	sub    $0x8,%esp
f0100f5a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100f5d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f62:	75 05                	jne    f0100f69 <page_free+0x15>
f0100f64:	83 38 00             	cmpl   $0x0,(%eax)
f0100f67:	74 17                	je     f0100f80 <page_free+0x2c>
		panic("page_free: pp->pp_ref is nonzero or pp->pp_link is not NULL.");
f0100f69:	83 ec 04             	sub    $0x4,%esp
f0100f6c:	68 34 69 10 f0       	push   $0xf0106934
f0100f71:	68 8b 01 00 00       	push   $0x18b
f0100f76:	68 3d 72 10 f0       	push   $0xf010723d
f0100f7b:	e8 c0 f0 ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link = page_free_list;
f0100f80:	8b 15 40 f2 29 f0    	mov    0xf029f240,%edx
f0100f86:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f88:	a3 40 f2 29 f0       	mov    %eax,0xf029f240
}
f0100f8d:	c9                   	leave  
f0100f8e:	c3                   	ret    

f0100f8f <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f8f:	55                   	push   %ebp
f0100f90:	89 e5                	mov    %esp,%ebp
f0100f92:	83 ec 08             	sub    $0x8,%esp
f0100f95:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f98:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f9c:	83 e8 01             	sub    $0x1,%eax
f0100f9f:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fa3:	66 85 c0             	test   %ax,%ax
f0100fa6:	75 0c                	jne    f0100fb4 <page_decref+0x25>
		page_free(pp);
f0100fa8:	83 ec 0c             	sub    $0xc,%esp
f0100fab:	52                   	push   %edx
f0100fac:	e8 a3 ff ff ff       	call   f0100f54 <page_free>
f0100fb1:	83 c4 10             	add    $0x10,%esp
}
f0100fb4:	c9                   	leave  
f0100fb5:	c3                   	ret    

f0100fb6 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fb6:	55                   	push   %ebp
f0100fb7:	89 e5                	mov    %esp,%ebp
f0100fb9:	57                   	push   %edi
f0100fba:	56                   	push   %esi
f0100fbb:	53                   	push   %ebx
f0100fbc:	83 ec 1c             	sub    $0x1c,%esp
f0100fbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	uint32_t pgdir_index = PDX(va);
	uint32_t pgtable_index = PTX(va);
f0100fc2:	89 df                	mov    %ebx,%edi
f0100fc4:	c1 ef 0c             	shr    $0xc,%edi
f0100fc7:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
	pte_t *pgdir_entry = pgdir + pgdir_index;
f0100fcd:	c1 eb 16             	shr    $0x16,%ebx
f0100fd0:	c1 e3 02             	shl    $0x2,%ebx
f0100fd3:	03 5d 08             	add    0x8(%ebp),%ebx

	// If pgdir_entry is present
	if (*pgdir_entry & PTE_P) {
f0100fd6:	8b 03                	mov    (%ebx),%eax
f0100fd8:	a8 01                	test   $0x1,%al
f0100fda:	74 33                	je     f010100f <pgdir_walk+0x59>
		physaddr_t pgtable_pa = (physaddr_t) (*pgdir_entry & 0xFFFFF000);
f0100fdc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fe1:	89 c2                	mov    %eax,%edx
f0100fe3:	c1 ea 0c             	shr    $0xc,%edx
f0100fe6:	39 15 94 fe 29 f0    	cmp    %edx,0xf029fe94
f0100fec:	77 15                	ja     f0101003 <pgdir_walk+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fee:	50                   	push   %eax
f0100fef:	68 44 63 10 f0       	push   $0xf0106344
f0100ff4:	68 bd 01 00 00       	push   $0x1bd
f0100ff9:	68 3d 72 10 f0       	push   $0xf010723d
f0100ffe:	e8 3d f0 ff ff       	call   f0100040 <_panic>
		pte_t *pgtable = (pte_t *) KADDR(pgtable_pa);
		return pgtable + pgtable_index;
f0101003:	8d 84 b8 00 00 00 f0 	lea    -0x10000000(%eax,%edi,4),%eax
f010100a:	e9 89 00 00 00       	jmp    f0101098 <pgdir_walk+0xe2>
	// If it is not present
	} else if (create) {
f010100f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101013:	74 77                	je     f010108c <pgdir_walk+0xd6>
		struct PageInfo *new_page = page_alloc(0);
f0101015:	83 ec 0c             	sub    $0xc,%esp
f0101018:	6a 00                	push   $0x0
f010101a:	e8 c5 fe ff ff       	call   f0100ee4 <page_alloc>
f010101f:	89 c6                	mov    %eax,%esi
		// If allocation works
		if (new_page) {
f0101021:	83 c4 10             	add    $0x10,%esp
f0101024:	85 c0                	test   %eax,%eax
f0101026:	74 6b                	je     f0101093 <pgdir_walk+0xdd>
			// Set the page
			new_page->pp_ref += 1;
f0101028:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010102d:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0101033:	c1 f8 03             	sar    $0x3,%eax
f0101036:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101039:	89 c2                	mov    %eax,%edx
f010103b:	c1 ea 0c             	shr    $0xc,%edx
f010103e:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f0101044:	72 12                	jb     f0101058 <pgdir_walk+0xa2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101046:	50                   	push   %eax
f0101047:	68 44 63 10 f0       	push   $0xf0106344
f010104c:	6a 58                	push   $0x58
f010104e:	68 63 72 10 f0       	push   $0xf0107263
f0101053:	e8 e8 ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101058:	2d 00 00 00 10       	sub    $0x10000000,%eax
			pte_t *pgtable = page2kva(new_page);
			memset(pgtable, 0, PGSIZE);
f010105d:	83 ec 04             	sub    $0x4,%esp
f0101060:	68 00 10 00 00       	push   $0x1000
f0101065:	6a 00                	push   $0x0
f0101067:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010106a:	50                   	push   %eax
f010106b:	e8 87 40 00 00       	call   f01050f7 <memset>
			// Set pgdir_entry
			physaddr_t pgtable_pa = page2pa(new_page);
			*pgdir_entry = (pgtable_pa | PTE_P | PTE_W | PTE_U);
f0101070:	2b 35 9c fe 29 f0    	sub    0xf029fe9c,%esi
f0101076:	c1 fe 03             	sar    $0x3,%esi
f0101079:	c1 e6 0c             	shl    $0xc,%esi
f010107c:	83 ce 07             	or     $0x7,%esi
f010107f:	89 33                	mov    %esi,(%ebx)
			// Return the virtual addres of the PTE
			return pgtable + pgtable_index;
f0101081:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101084:	8d 04 b8             	lea    (%eax,%edi,4),%eax
f0101087:	83 c4 10             	add    $0x10,%esp
f010108a:	eb 0c                	jmp    f0101098 <pgdir_walk+0xe2>
		}
	}
	return NULL;
f010108c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101091:	eb 05                	jmp    f0101098 <pgdir_walk+0xe2>
f0101093:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101098:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010109b:	5b                   	pop    %ebx
f010109c:	5e                   	pop    %esi
f010109d:	5f                   	pop    %edi
f010109e:	5d                   	pop    %ebp
f010109f:	c3                   	ret    

f01010a0 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010a0:	55                   	push   %ebp
f01010a1:	89 e5                	mov    %esp,%ebp
f01010a3:	57                   	push   %edi
f01010a4:	56                   	push   %esi
f01010a5:	53                   	push   %ebx
f01010a6:	83 ec 1c             	sub    $0x1c,%esp
f01010a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010ac:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// TODO: Add panic for va an pa aligned
	if (size % PGSIZE != 0)
f01010af:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f01010b5:	74 17                	je     f01010ce <boot_map_region+0x2e>
		panic("boot_map_region: size is not multiple of PGSIZE");
f01010b7:	83 ec 04             	sub    $0x4,%esp
f01010ba:	68 74 69 10 f0       	push   $0xf0106974
f01010bf:	68 e3 01 00 00       	push   $0x1e3
f01010c4:	68 3d 72 10 f0       	push   $0xf010723d
f01010c9:	e8 72 ef ff ff       	call   f0100040 <_panic>
	uint32_t n = size/PGSIZE;
f01010ce:	c1 e9 0c             	shr    $0xc,%ecx
f01010d1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	uint32_t i;
	for (i = 0; i < n; i++) {
f01010d4:	89 c3                	mov    %eax,%ebx
f01010d6:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);
f01010db:	89 d7                	mov    %edx,%edi
f01010dd:	29 c7                	sub    %eax,%edi
		if (!pte)
			panic("boot_map_region: could not allocate page table");
		uint32_t pa_without_offset = (pa & 0xFFFFF000);
		*pte = (pa_without_offset | perm | PTE_P);
f01010df:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010e2:	83 c8 01             	or     $0x1,%eax
f01010e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// TODO: Add panic for va an pa aligned
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not multiple of PGSIZE");
	uint32_t n = size/PGSIZE;
	uint32_t i;
	for (i = 0; i < n; i++) {
f01010e8:	eb 45                	jmp    f010112f <boot_map_region+0x8f>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);
f01010ea:	83 ec 04             	sub    $0x4,%esp
f01010ed:	6a 01                	push   $0x1
f01010ef:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01010f2:	50                   	push   %eax
f01010f3:	ff 75 e0             	pushl  -0x20(%ebp)
f01010f6:	e8 bb fe ff ff       	call   f0100fb6 <pgdir_walk>
		if (!pte)
f01010fb:	83 c4 10             	add    $0x10,%esp
f01010fe:	85 c0                	test   %eax,%eax
f0101100:	75 17                	jne    f0101119 <boot_map_region+0x79>
			panic("boot_map_region: could not allocate page table");
f0101102:	83 ec 04             	sub    $0x4,%esp
f0101105:	68 a4 69 10 f0       	push   $0xf01069a4
f010110a:	68 e9 01 00 00       	push   $0x1e9
f010110f:	68 3d 72 10 f0       	push   $0xf010723d
f0101114:	e8 27 ef ff ff       	call   f0100040 <_panic>
		uint32_t pa_without_offset = (pa & 0xFFFFF000);
		*pte = (pa_without_offset | perm | PTE_P);
f0101119:	89 da                	mov    %ebx,%edx
f010111b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101121:	0b 55 dc             	or     -0x24(%ebp),%edx
f0101124:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
		pa += PGSIZE;
f0101126:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// TODO: Add panic for va an pa aligned
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not multiple of PGSIZE");
	uint32_t n = size/PGSIZE;
	uint32_t i;
	for (i = 0; i < n; i++) {
f010112c:	83 c6 01             	add    $0x1,%esi
f010112f:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101132:	75 b6                	jne    f01010ea <boot_map_region+0x4a>
		uint32_t pa_without_offset = (pa & 0xFFFFF000);
		*pte = (pa_without_offset | perm | PTE_P);
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f0101134:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101137:	5b                   	pop    %ebx
f0101138:	5e                   	pop    %esi
f0101139:	5f                   	pop    %edi
f010113a:	5d                   	pop    %ebp
f010113b:	c3                   	ret    

f010113c <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010113c:	55                   	push   %ebp
f010113d:	89 e5                	mov    %esp,%ebp
f010113f:	53                   	push   %ebx
f0101140:	83 ec 08             	sub    $0x8,%esp
f0101143:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101146:	6a 00                	push   $0x0
f0101148:	ff 75 0c             	pushl  0xc(%ebp)
f010114b:	ff 75 08             	pushl  0x8(%ebp)
f010114e:	e8 63 fe ff ff       	call   f0100fb6 <pgdir_walk>
	if (!pte || !(*pte & PTE_P))
f0101153:	83 c4 10             	add    $0x10,%esp
f0101156:	85 c0                	test   %eax,%eax
f0101158:	74 3c                	je     f0101196 <page_lookup+0x5a>
f010115a:	8b 10                	mov    (%eax),%edx
f010115c:	f6 c2 01             	test   $0x1,%dl
f010115f:	74 3c                	je     f010119d <page_lookup+0x61>
		return NULL;
	physaddr_t page_pa = (*pte & 0xFFFFF000);
f0101161:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (pte_store)
f0101167:	85 db                	test   %ebx,%ebx
f0101169:	74 02                	je     f010116d <page_lookup+0x31>
		*pte_store = pte;
f010116b:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010116d:	c1 ea 0c             	shr    $0xc,%edx
f0101170:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f0101176:	72 14                	jb     f010118c <page_lookup+0x50>
		panic("pa2page called with invalid pa");
f0101178:	83 ec 04             	sub    $0x4,%esp
f010117b:	68 d4 69 10 f0       	push   $0xf01069d4
f0101180:	6a 51                	push   $0x51
f0101182:	68 63 72 10 f0       	push   $0xf0107263
f0101187:	e8 b4 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010118c:	a1 9c fe 29 f0       	mov    0xf029fe9c,%eax
f0101191:	8d 04 d0             	lea    (%eax,%edx,8),%eax
	return pa2page(page_pa);
f0101194:	eb 0c                	jmp    f01011a2 <page_lookup+0x66>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if (!pte || !(*pte & PTE_P))
		return NULL;
f0101196:	b8 00 00 00 00       	mov    $0x0,%eax
f010119b:	eb 05                	jmp    f01011a2 <page_lookup+0x66>
f010119d:	b8 00 00 00 00       	mov    $0x0,%eax
	physaddr_t page_pa = (*pte & 0xFFFFF000);
	if (pte_store)
		*pte_store = pte;
	return pa2page(page_pa);
}
f01011a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011a5:	c9                   	leave  
f01011a6:	c3                   	ret    

f01011a7 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011a7:	55                   	push   %ebp
f01011a8:	89 e5                	mov    %esp,%ebp
f01011aa:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011ad:	e8 68 45 00 00       	call   f010571a <cpunum>
f01011b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01011b5:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f01011bc:	74 16                	je     f01011d4 <tlb_invalidate+0x2d>
f01011be:	e8 57 45 00 00       	call   f010571a <cpunum>
f01011c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01011c6:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01011cc:	8b 55 08             	mov    0x8(%ebp),%edx
f01011cf:	39 50 60             	cmp    %edx,0x60(%eax)
f01011d2:	75 06                	jne    f01011da <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011d7:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011da:	c9                   	leave  
f01011db:	c3                   	ret    

f01011dc <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011dc:	55                   	push   %ebp
f01011dd:	89 e5                	mov    %esp,%ebp
f01011df:	56                   	push   %esi
f01011e0:	53                   	push   %ebx
f01011e1:	83 ec 14             	sub    $0x14,%esp
f01011e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte;
	struct PageInfo *page = page_lookup(pgdir, va, &pte);
f01011ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011ed:	50                   	push   %eax
f01011ee:	56                   	push   %esi
f01011ef:	53                   	push   %ebx
f01011f0:	e8 47 ff ff ff       	call   f010113c <page_lookup>
	if (page) {
f01011f5:	83 c4 10             	add    $0x10,%esp
f01011f8:	85 c0                	test   %eax,%eax
f01011fa:	74 1f                	je     f010121b <page_remove+0x3f>
		page_decref(page);
f01011fc:	83 ec 0c             	sub    $0xc,%esp
f01011ff:	50                   	push   %eax
f0101200:	e8 8a fd ff ff       	call   f0100f8f <page_decref>
		*pte = 0;
f0101205:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101208:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va); // How this works? Is va here ok?
f010120e:	83 c4 08             	add    $0x8,%esp
f0101211:	56                   	push   %esi
f0101212:	53                   	push   %ebx
f0101213:	e8 8f ff ff ff       	call   f01011a7 <tlb_invalidate>
f0101218:	83 c4 10             	add    $0x10,%esp
	}
}
f010121b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010121e:	5b                   	pop    %ebx
f010121f:	5e                   	pop    %esi
f0101220:	5d                   	pop    %ebp
f0101221:	c3                   	ret    

f0101222 <page_insert>:
//
// TODO: It should only be used on pages that are not free? (Allocated pages)
// So it can only be used on pages that were allocated.
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101222:	55                   	push   %ebp
f0101223:	89 e5                	mov    %esp,%ebp
f0101225:	57                   	push   %edi
f0101226:	56                   	push   %esi
f0101227:	53                   	push   %ebx
f0101228:	83 ec 20             	sub    $0x20,%esp
f010122b:	8b 75 08             	mov    0x8(%ebp),%esi
f010122e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101231:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	// TODO: Find a better solution...

	// Corner case
	pte_t *pte;
	if (page_lookup(pgdir, va, &pte) == pp) {
f0101234:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101237:	50                   	push   %eax
f0101238:	57                   	push   %edi
f0101239:	56                   	push   %esi
f010123a:	e8 fd fe ff ff       	call   f010113c <page_lookup>
f010123f:	83 c4 10             	add    $0x10,%esp
f0101242:	39 d8                	cmp    %ebx,%eax
f0101244:	75 20                	jne    f0101266 <page_insert+0x44>
		*pte = (page2pa(pp) | perm | PTE_P);
f0101246:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f010124c:	c1 f8 03             	sar    $0x3,%eax
f010124f:	c1 e0 0c             	shl    $0xc,%eax
f0101252:	8b 55 14             	mov    0x14(%ebp),%edx
f0101255:	83 ca 01             	or     $0x1,%edx
f0101258:	09 d0                	or     %edx,%eax
f010125a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010125d:	89 02                	mov    %eax,(%edx)
		return 0;
f010125f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101264:	eb 44                	jmp    f01012aa <page_insert+0x88>
	}

	// Normal case
	page_remove(pgdir, va);
f0101266:	83 ec 08             	sub    $0x8,%esp
f0101269:	57                   	push   %edi
f010126a:	56                   	push   %esi
f010126b:	e8 6c ff ff ff       	call   f01011dc <page_remove>
	pte = pgdir_walk(pgdir, va, 1);
f0101270:	83 c4 0c             	add    $0xc,%esp
f0101273:	6a 01                	push   $0x1
f0101275:	57                   	push   %edi
f0101276:	56                   	push   %esi
f0101277:	e8 3a fd ff ff       	call   f0100fb6 <pgdir_walk>
	if (!pte)
f010127c:	83 c4 10             	add    $0x10,%esp
f010127f:	85 c0                	test   %eax,%eax
f0101281:	74 22                	je     f01012a5 <page_insert+0x83>
		return -E_NO_MEM;
	pp->pp_ref += 1;
f0101283:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	*pte = (page2pa(pp) | perm | PTE_P);
f0101288:	2b 1d 9c fe 29 f0    	sub    0xf029fe9c,%ebx
f010128e:	c1 fb 03             	sar    $0x3,%ebx
f0101291:	c1 e3 0c             	shl    $0xc,%ebx
f0101294:	8b 55 14             	mov    0x14(%ebp),%edx
f0101297:	83 ca 01             	or     $0x1,%edx
f010129a:	09 d3                	or     %edx,%ebx
f010129c:	89 18                	mov    %ebx,(%eax)
	return 0;
f010129e:	b8 00 00 00 00       	mov    $0x0,%eax
f01012a3:	eb 05                	jmp    f01012aa <page_insert+0x88>

	// Normal case
	page_remove(pgdir, va);
	pte = pgdir_walk(pgdir, va, 1);
	if (!pte)
		return -E_NO_MEM;
f01012a5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref += 1;
	*pte = (page2pa(pp) | perm | PTE_P);
	return 0;
}
f01012aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012ad:	5b                   	pop    %ebx
f01012ae:	5e                   	pop    %esi
f01012af:	5f                   	pop    %edi
f01012b0:	5d                   	pop    %ebp
f01012b1:	c3                   	ret    

f01012b2 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012b2:	55                   	push   %ebp
f01012b3:	89 e5                	mov    %esp,%ebp
f01012b5:	53                   	push   %ebx
f01012b6:	83 ec 04             	sub    $0x4,%esp
f01012b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size_t map_size = ROUNDUP(size, PGSIZE);
f01012bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012bf:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012c5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + map_size > MMIOLIM) {
f01012cb:	a1 00 23 12 f0       	mov    0xf0122300,%eax
f01012d0:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01012d3:	81 fa 00 00 c0 ef    	cmp    $0xefc00000,%edx
f01012d9:	76 17                	jbe    f01012f2 <mmio_map_region+0x40>
		panic("mmio_map_region: overflow on MMIO map region");
f01012db:	83 ec 04             	sub    $0x4,%esp
f01012de:	68 f4 69 10 f0       	push   $0xf01069f4
f01012e3:	68 84 02 00 00       	push   $0x284
f01012e8:	68 3d 72 10 f0       	push   $0xf010723d
f01012ed:	e8 4e ed ff ff       	call   f0100040 <_panic>
	}
	uintptr_t va = base + PGOFF(pa);

	// Map region. va and pa page aligned. map_size multiple of size.
	boot_map_region(kern_pgdir, va, map_size, pa, PTE_W | PTE_PCD | PTE_PWT);
f01012f2:	89 ca                	mov    %ecx,%edx
f01012f4:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f01012fa:	01 c2                	add    %eax,%edx
f01012fc:	83 ec 08             	sub    $0x8,%esp
f01012ff:	6a 1a                	push   $0x1a
f0101301:	51                   	push   %ecx
f0101302:	89 d9                	mov    %ebx,%ecx
f0101304:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f0101309:	e8 92 fd ff ff       	call   f01010a0 <boot_map_region>

	// Update base
	base += map_size;
f010130e:	a1 00 23 12 f0       	mov    0xf0122300,%eax
f0101313:	01 c3                	add    %eax,%ebx
f0101315:	89 1d 00 23 12 f0    	mov    %ebx,0xf0122300

	// Return base of mapped region
	return (void *) (base - map_size);
}
f010131b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010131e:	c9                   	leave  
f010131f:	c3                   	ret    

f0101320 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101320:	55                   	push   %ebp
f0101321:	89 e5                	mov    %esp,%ebp
f0101323:	57                   	push   %edi
f0101324:	56                   	push   %esi
f0101325:	53                   	push   %ebx
f0101326:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101329:	6a 15                	push   $0x15
f010132b:	e8 8c 21 00 00       	call   f01034bc <mc146818_read>
f0101330:	89 c3                	mov    %eax,%ebx
f0101332:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101339:	e8 7e 21 00 00       	call   f01034bc <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010133e:	c1 e0 08             	shl    $0x8,%eax
f0101341:	09 d8                	or     %ebx,%eax
f0101343:	c1 e0 0a             	shl    $0xa,%eax
f0101346:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010134c:	85 c0                	test   %eax,%eax
f010134e:	0f 48 c2             	cmovs  %edx,%eax
f0101351:	c1 f8 0c             	sar    $0xc,%eax
f0101354:	a3 44 f2 29 f0       	mov    %eax,0xf029f244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101359:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101360:	e8 57 21 00 00       	call   f01034bc <mc146818_read>
f0101365:	89 c3                	mov    %eax,%ebx
f0101367:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010136e:	e8 49 21 00 00       	call   f01034bc <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101373:	c1 e0 08             	shl    $0x8,%eax
f0101376:	09 d8                	or     %ebx,%eax
f0101378:	c1 e0 0a             	shl    $0xa,%eax
f010137b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101381:	83 c4 10             	add    $0x10,%esp
f0101384:	85 c0                	test   %eax,%eax
f0101386:	0f 48 c2             	cmovs  %edx,%eax
f0101389:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010138c:	85 c0                	test   %eax,%eax
f010138e:	74 0e                	je     f010139e <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101390:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101396:	89 15 94 fe 29 f0    	mov    %edx,0xf029fe94
f010139c:	eb 0c                	jmp    f01013aa <mem_init+0x8a>
	else
		npages = npages_basemem;
f010139e:	8b 15 44 f2 29 f0    	mov    0xf029f244,%edx
f01013a4:	89 15 94 fe 29 f0    	mov    %edx,0xf029fe94

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013aa:	c1 e0 0c             	shl    $0xc,%eax
f01013ad:	c1 e8 0a             	shr    $0xa,%eax
f01013b0:	50                   	push   %eax
f01013b1:	a1 44 f2 29 f0       	mov    0xf029f244,%eax
f01013b6:	c1 e0 0c             	shl    $0xc,%eax
f01013b9:	c1 e8 0a             	shr    $0xa,%eax
f01013bc:	50                   	push   %eax
f01013bd:	a1 94 fe 29 f0       	mov    0xf029fe94,%eax
f01013c2:	c1 e0 0c             	shl    $0xc,%eax
f01013c5:	c1 e8 0a             	shr    $0xa,%eax
f01013c8:	50                   	push   %eax
f01013c9:	68 24 6a 10 f0       	push   $0xf0106a24
f01013ce:	e8 7e 22 00 00       	call   f0103651 <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013d3:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013d8:	e8 c9 f6 ff ff       	call   f0100aa6 <boot_alloc>
f01013dd:	a3 98 fe 29 f0       	mov    %eax,0xf029fe98
	memset(kern_pgdir, 0, PGSIZE);
f01013e2:	83 c4 0c             	add    $0xc,%esp
f01013e5:	68 00 10 00 00       	push   $0x1000
f01013ea:	6a 00                	push   $0x0
f01013ec:	50                   	push   %eax
f01013ed:	e8 05 3d 00 00       	call   f01050f7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013f2:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013f7:	83 c4 10             	add    $0x10,%esp
f01013fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013ff:	77 15                	ja     f0101416 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101401:	50                   	push   %eax
f0101402:	68 68 63 10 f0       	push   $0xf0106368
f0101407:	68 93 00 00 00       	push   $0x93
f010140c:	68 3d 72 10 f0       	push   $0xf010723d
f0101411:	e8 2a ec ff ff       	call   f0100040 <_panic>
f0101416:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010141c:	83 ca 05             	or     $0x5,%edx
f010141f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101425:	a1 94 fe 29 f0       	mov    0xf029fe94,%eax
f010142a:	c1 e0 03             	shl    $0x3,%eax
f010142d:	e8 74 f6 ff ff       	call   f0100aa6 <boot_alloc>
f0101432:	a3 9c fe 29 f0       	mov    %eax,0xf029fe9c
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101437:	83 ec 04             	sub    $0x4,%esp
f010143a:	8b 0d 94 fe 29 f0    	mov    0xf029fe94,%ecx
f0101440:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101447:	52                   	push   %edx
f0101448:	6a 00                	push   $0x0
f010144a:	50                   	push   %eax
f010144b:	e8 a7 3c 00 00       	call   f01050f7 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101450:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101455:	e8 4c f6 ff ff       	call   f0100aa6 <boot_alloc>
f010145a:	a3 48 f2 29 f0       	mov    %eax,0xf029f248
	memset(envs, 0, NENV * sizeof(struct Env));
f010145f:	83 c4 0c             	add    $0xc,%esp
f0101462:	68 00 f0 01 00       	push   $0x1f000
f0101467:	6a 00                	push   $0x0
f0101469:	50                   	push   %eax
f010146a:	e8 88 3c 00 00       	call   f01050f7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010146f:	e8 a5 f9 ff ff       	call   f0100e19 <page_init>

	check_page_free_list(1);
f0101474:	b8 01 00 00 00       	mov    $0x1,%eax
f0101479:	e8 ac f6 ff ff       	call   f0100b2a <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010147e:	83 c4 10             	add    $0x10,%esp
f0101481:	83 3d 9c fe 29 f0 00 	cmpl   $0x0,0xf029fe9c
f0101488:	75 17                	jne    f01014a1 <mem_init+0x181>
		panic("'pages' is a null pointer!");
f010148a:	83 ec 04             	sub    $0x4,%esp
f010148d:	68 2a 73 10 f0       	push   $0xf010732a
f0101492:	68 28 03 00 00       	push   $0x328
f0101497:	68 3d 72 10 f0       	push   $0xf010723d
f010149c:	e8 9f eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014a1:	a1 40 f2 29 f0       	mov    0xf029f240,%eax
f01014a6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014ab:	eb 05                	jmp    f01014b2 <mem_init+0x192>
		++nfree;
f01014ad:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014b0:	8b 00                	mov    (%eax),%eax
f01014b2:	85 c0                	test   %eax,%eax
f01014b4:	75 f7                	jne    f01014ad <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014b6:	83 ec 0c             	sub    $0xc,%esp
f01014b9:	6a 00                	push   $0x0
f01014bb:	e8 24 fa ff ff       	call   f0100ee4 <page_alloc>
f01014c0:	89 c7                	mov    %eax,%edi
f01014c2:	83 c4 10             	add    $0x10,%esp
f01014c5:	85 c0                	test   %eax,%eax
f01014c7:	75 19                	jne    f01014e2 <mem_init+0x1c2>
f01014c9:	68 45 73 10 f0       	push   $0xf0107345
f01014ce:	68 7d 72 10 f0       	push   $0xf010727d
f01014d3:	68 30 03 00 00       	push   $0x330
f01014d8:	68 3d 72 10 f0       	push   $0xf010723d
f01014dd:	e8 5e eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01014e2:	83 ec 0c             	sub    $0xc,%esp
f01014e5:	6a 00                	push   $0x0
f01014e7:	e8 f8 f9 ff ff       	call   f0100ee4 <page_alloc>
f01014ec:	89 c6                	mov    %eax,%esi
f01014ee:	83 c4 10             	add    $0x10,%esp
f01014f1:	85 c0                	test   %eax,%eax
f01014f3:	75 19                	jne    f010150e <mem_init+0x1ee>
f01014f5:	68 5b 73 10 f0       	push   $0xf010735b
f01014fa:	68 7d 72 10 f0       	push   $0xf010727d
f01014ff:	68 31 03 00 00       	push   $0x331
f0101504:	68 3d 72 10 f0       	push   $0xf010723d
f0101509:	e8 32 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010150e:	83 ec 0c             	sub    $0xc,%esp
f0101511:	6a 00                	push   $0x0
f0101513:	e8 cc f9 ff ff       	call   f0100ee4 <page_alloc>
f0101518:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010151b:	83 c4 10             	add    $0x10,%esp
f010151e:	85 c0                	test   %eax,%eax
f0101520:	75 19                	jne    f010153b <mem_init+0x21b>
f0101522:	68 71 73 10 f0       	push   $0xf0107371
f0101527:	68 7d 72 10 f0       	push   $0xf010727d
f010152c:	68 32 03 00 00       	push   $0x332
f0101531:	68 3d 72 10 f0       	push   $0xf010723d
f0101536:	e8 05 eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010153b:	39 f7                	cmp    %esi,%edi
f010153d:	75 19                	jne    f0101558 <mem_init+0x238>
f010153f:	68 87 73 10 f0       	push   $0xf0107387
f0101544:	68 7d 72 10 f0       	push   $0xf010727d
f0101549:	68 35 03 00 00       	push   $0x335
f010154e:	68 3d 72 10 f0       	push   $0xf010723d
f0101553:	e8 e8 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010155b:	39 c6                	cmp    %eax,%esi
f010155d:	74 04                	je     f0101563 <mem_init+0x243>
f010155f:	39 c7                	cmp    %eax,%edi
f0101561:	75 19                	jne    f010157c <mem_init+0x25c>
f0101563:	68 60 6a 10 f0       	push   $0xf0106a60
f0101568:	68 7d 72 10 f0       	push   $0xf010727d
f010156d:	68 36 03 00 00       	push   $0x336
f0101572:	68 3d 72 10 f0       	push   $0xf010723d
f0101577:	e8 c4 ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010157c:	8b 0d 9c fe 29 f0    	mov    0xf029fe9c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101582:	8b 15 94 fe 29 f0    	mov    0xf029fe94,%edx
f0101588:	c1 e2 0c             	shl    $0xc,%edx
f010158b:	89 f8                	mov    %edi,%eax
f010158d:	29 c8                	sub    %ecx,%eax
f010158f:	c1 f8 03             	sar    $0x3,%eax
f0101592:	c1 e0 0c             	shl    $0xc,%eax
f0101595:	39 d0                	cmp    %edx,%eax
f0101597:	72 19                	jb     f01015b2 <mem_init+0x292>
f0101599:	68 99 73 10 f0       	push   $0xf0107399
f010159e:	68 7d 72 10 f0       	push   $0xf010727d
f01015a3:	68 37 03 00 00       	push   $0x337
f01015a8:	68 3d 72 10 f0       	push   $0xf010723d
f01015ad:	e8 8e ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01015b2:	89 f0                	mov    %esi,%eax
f01015b4:	29 c8                	sub    %ecx,%eax
f01015b6:	c1 f8 03             	sar    $0x3,%eax
f01015b9:	c1 e0 0c             	shl    $0xc,%eax
f01015bc:	39 c2                	cmp    %eax,%edx
f01015be:	77 19                	ja     f01015d9 <mem_init+0x2b9>
f01015c0:	68 b6 73 10 f0       	push   $0xf01073b6
f01015c5:	68 7d 72 10 f0       	push   $0xf010727d
f01015ca:	68 38 03 00 00       	push   $0x338
f01015cf:	68 3d 72 10 f0       	push   $0xf010723d
f01015d4:	e8 67 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01015d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015dc:	29 c8                	sub    %ecx,%eax
f01015de:	c1 f8 03             	sar    $0x3,%eax
f01015e1:	c1 e0 0c             	shl    $0xc,%eax
f01015e4:	39 c2                	cmp    %eax,%edx
f01015e6:	77 19                	ja     f0101601 <mem_init+0x2e1>
f01015e8:	68 d3 73 10 f0       	push   $0xf01073d3
f01015ed:	68 7d 72 10 f0       	push   $0xf010727d
f01015f2:	68 39 03 00 00       	push   $0x339
f01015f7:	68 3d 72 10 f0       	push   $0xf010723d
f01015fc:	e8 3f ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101601:	a1 40 f2 29 f0       	mov    0xf029f240,%eax
f0101606:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101609:	c7 05 40 f2 29 f0 00 	movl   $0x0,0xf029f240
f0101610:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101613:	83 ec 0c             	sub    $0xc,%esp
f0101616:	6a 00                	push   $0x0
f0101618:	e8 c7 f8 ff ff       	call   f0100ee4 <page_alloc>
f010161d:	83 c4 10             	add    $0x10,%esp
f0101620:	85 c0                	test   %eax,%eax
f0101622:	74 19                	je     f010163d <mem_init+0x31d>
f0101624:	68 f0 73 10 f0       	push   $0xf01073f0
f0101629:	68 7d 72 10 f0       	push   $0xf010727d
f010162e:	68 40 03 00 00       	push   $0x340
f0101633:	68 3d 72 10 f0       	push   $0xf010723d
f0101638:	e8 03 ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010163d:	83 ec 0c             	sub    $0xc,%esp
f0101640:	57                   	push   %edi
f0101641:	e8 0e f9 ff ff       	call   f0100f54 <page_free>
	page_free(pp1);
f0101646:	89 34 24             	mov    %esi,(%esp)
f0101649:	e8 06 f9 ff ff       	call   f0100f54 <page_free>
	page_free(pp2);
f010164e:	83 c4 04             	add    $0x4,%esp
f0101651:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101654:	e8 fb f8 ff ff       	call   f0100f54 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101659:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101660:	e8 7f f8 ff ff       	call   f0100ee4 <page_alloc>
f0101665:	89 c6                	mov    %eax,%esi
f0101667:	83 c4 10             	add    $0x10,%esp
f010166a:	85 c0                	test   %eax,%eax
f010166c:	75 19                	jne    f0101687 <mem_init+0x367>
f010166e:	68 45 73 10 f0       	push   $0xf0107345
f0101673:	68 7d 72 10 f0       	push   $0xf010727d
f0101678:	68 47 03 00 00       	push   $0x347
f010167d:	68 3d 72 10 f0       	push   $0xf010723d
f0101682:	e8 b9 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101687:	83 ec 0c             	sub    $0xc,%esp
f010168a:	6a 00                	push   $0x0
f010168c:	e8 53 f8 ff ff       	call   f0100ee4 <page_alloc>
f0101691:	89 c7                	mov    %eax,%edi
f0101693:	83 c4 10             	add    $0x10,%esp
f0101696:	85 c0                	test   %eax,%eax
f0101698:	75 19                	jne    f01016b3 <mem_init+0x393>
f010169a:	68 5b 73 10 f0       	push   $0xf010735b
f010169f:	68 7d 72 10 f0       	push   $0xf010727d
f01016a4:	68 48 03 00 00       	push   $0x348
f01016a9:	68 3d 72 10 f0       	push   $0xf010723d
f01016ae:	e8 8d e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016b3:	83 ec 0c             	sub    $0xc,%esp
f01016b6:	6a 00                	push   $0x0
f01016b8:	e8 27 f8 ff ff       	call   f0100ee4 <page_alloc>
f01016bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016c0:	83 c4 10             	add    $0x10,%esp
f01016c3:	85 c0                	test   %eax,%eax
f01016c5:	75 19                	jne    f01016e0 <mem_init+0x3c0>
f01016c7:	68 71 73 10 f0       	push   $0xf0107371
f01016cc:	68 7d 72 10 f0       	push   $0xf010727d
f01016d1:	68 49 03 00 00       	push   $0x349
f01016d6:	68 3d 72 10 f0       	push   $0xf010723d
f01016db:	e8 60 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016e0:	39 fe                	cmp    %edi,%esi
f01016e2:	75 19                	jne    f01016fd <mem_init+0x3dd>
f01016e4:	68 87 73 10 f0       	push   $0xf0107387
f01016e9:	68 7d 72 10 f0       	push   $0xf010727d
f01016ee:	68 4b 03 00 00       	push   $0x34b
f01016f3:	68 3d 72 10 f0       	push   $0xf010723d
f01016f8:	e8 43 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101700:	39 c7                	cmp    %eax,%edi
f0101702:	74 04                	je     f0101708 <mem_init+0x3e8>
f0101704:	39 c6                	cmp    %eax,%esi
f0101706:	75 19                	jne    f0101721 <mem_init+0x401>
f0101708:	68 60 6a 10 f0       	push   $0xf0106a60
f010170d:	68 7d 72 10 f0       	push   $0xf010727d
f0101712:	68 4c 03 00 00       	push   $0x34c
f0101717:	68 3d 72 10 f0       	push   $0xf010723d
f010171c:	e8 1f e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101721:	83 ec 0c             	sub    $0xc,%esp
f0101724:	6a 00                	push   $0x0
f0101726:	e8 b9 f7 ff ff       	call   f0100ee4 <page_alloc>
f010172b:	83 c4 10             	add    $0x10,%esp
f010172e:	85 c0                	test   %eax,%eax
f0101730:	74 19                	je     f010174b <mem_init+0x42b>
f0101732:	68 f0 73 10 f0       	push   $0xf01073f0
f0101737:	68 7d 72 10 f0       	push   $0xf010727d
f010173c:	68 4d 03 00 00       	push   $0x34d
f0101741:	68 3d 72 10 f0       	push   $0xf010723d
f0101746:	e8 f5 e8 ff ff       	call   f0100040 <_panic>
f010174b:	89 f0                	mov    %esi,%eax
f010174d:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0101753:	c1 f8 03             	sar    $0x3,%eax
f0101756:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101759:	89 c2                	mov    %eax,%edx
f010175b:	c1 ea 0c             	shr    $0xc,%edx
f010175e:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f0101764:	72 12                	jb     f0101778 <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101766:	50                   	push   %eax
f0101767:	68 44 63 10 f0       	push   $0xf0106344
f010176c:	6a 58                	push   $0x58
f010176e:	68 63 72 10 f0       	push   $0xf0107263
f0101773:	e8 c8 e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101778:	83 ec 04             	sub    $0x4,%esp
f010177b:	68 00 10 00 00       	push   $0x1000
f0101780:	6a 01                	push   $0x1
f0101782:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101787:	50                   	push   %eax
f0101788:	e8 6a 39 00 00       	call   f01050f7 <memset>
	page_free(pp0);
f010178d:	89 34 24             	mov    %esi,(%esp)
f0101790:	e8 bf f7 ff ff       	call   f0100f54 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101795:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010179c:	e8 43 f7 ff ff       	call   f0100ee4 <page_alloc>
f01017a1:	83 c4 10             	add    $0x10,%esp
f01017a4:	85 c0                	test   %eax,%eax
f01017a6:	75 19                	jne    f01017c1 <mem_init+0x4a1>
f01017a8:	68 ff 73 10 f0       	push   $0xf01073ff
f01017ad:	68 7d 72 10 f0       	push   $0xf010727d
f01017b2:	68 52 03 00 00       	push   $0x352
f01017b7:	68 3d 72 10 f0       	push   $0xf010723d
f01017bc:	e8 7f e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01017c1:	39 c6                	cmp    %eax,%esi
f01017c3:	74 19                	je     f01017de <mem_init+0x4be>
f01017c5:	68 1d 74 10 f0       	push   $0xf010741d
f01017ca:	68 7d 72 10 f0       	push   $0xf010727d
f01017cf:	68 53 03 00 00       	push   $0x353
f01017d4:	68 3d 72 10 f0       	push   $0xf010723d
f01017d9:	e8 62 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017de:	89 f0                	mov    %esi,%eax
f01017e0:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f01017e6:	c1 f8 03             	sar    $0x3,%eax
f01017e9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017ec:	89 c2                	mov    %eax,%edx
f01017ee:	c1 ea 0c             	shr    $0xc,%edx
f01017f1:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f01017f7:	72 12                	jb     f010180b <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017f9:	50                   	push   %eax
f01017fa:	68 44 63 10 f0       	push   $0xf0106344
f01017ff:	6a 58                	push   $0x58
f0101801:	68 63 72 10 f0       	push   $0xf0107263
f0101806:	e8 35 e8 ff ff       	call   f0100040 <_panic>
f010180b:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101811:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101817:	80 38 00             	cmpb   $0x0,(%eax)
f010181a:	74 19                	je     f0101835 <mem_init+0x515>
f010181c:	68 2d 74 10 f0       	push   $0xf010742d
f0101821:	68 7d 72 10 f0       	push   $0xf010727d
f0101826:	68 56 03 00 00       	push   $0x356
f010182b:	68 3d 72 10 f0       	push   $0xf010723d
f0101830:	e8 0b e8 ff ff       	call   f0100040 <_panic>
f0101835:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101838:	39 d0                	cmp    %edx,%eax
f010183a:	75 db                	jne    f0101817 <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010183c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010183f:	a3 40 f2 29 f0       	mov    %eax,0xf029f240

	// free the pages we took
	page_free(pp0);
f0101844:	83 ec 0c             	sub    $0xc,%esp
f0101847:	56                   	push   %esi
f0101848:	e8 07 f7 ff ff       	call   f0100f54 <page_free>
	page_free(pp1);
f010184d:	89 3c 24             	mov    %edi,(%esp)
f0101850:	e8 ff f6 ff ff       	call   f0100f54 <page_free>
	page_free(pp2);
f0101855:	83 c4 04             	add    $0x4,%esp
f0101858:	ff 75 d4             	pushl  -0x2c(%ebp)
f010185b:	e8 f4 f6 ff ff       	call   f0100f54 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101860:	a1 40 f2 29 f0       	mov    0xf029f240,%eax
f0101865:	83 c4 10             	add    $0x10,%esp
f0101868:	eb 05                	jmp    f010186f <mem_init+0x54f>
		--nfree;
f010186a:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010186d:	8b 00                	mov    (%eax),%eax
f010186f:	85 c0                	test   %eax,%eax
f0101871:	75 f7                	jne    f010186a <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f0101873:	85 db                	test   %ebx,%ebx
f0101875:	74 19                	je     f0101890 <mem_init+0x570>
f0101877:	68 37 74 10 f0       	push   $0xf0107437
f010187c:	68 7d 72 10 f0       	push   $0xf010727d
f0101881:	68 63 03 00 00       	push   $0x363
f0101886:	68 3d 72 10 f0       	push   $0xf010723d
f010188b:	e8 b0 e7 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101890:	83 ec 0c             	sub    $0xc,%esp
f0101893:	68 80 6a 10 f0       	push   $0xf0106a80
f0101898:	e8 b4 1d 00 00       	call   f0103651 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010189d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018a4:	e8 3b f6 ff ff       	call   f0100ee4 <page_alloc>
f01018a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018ac:	83 c4 10             	add    $0x10,%esp
f01018af:	85 c0                	test   %eax,%eax
f01018b1:	75 19                	jne    f01018cc <mem_init+0x5ac>
f01018b3:	68 45 73 10 f0       	push   $0xf0107345
f01018b8:	68 7d 72 10 f0       	push   $0xf010727d
f01018bd:	68 c9 03 00 00       	push   $0x3c9
f01018c2:	68 3d 72 10 f0       	push   $0xf010723d
f01018c7:	e8 74 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018cc:	83 ec 0c             	sub    $0xc,%esp
f01018cf:	6a 00                	push   $0x0
f01018d1:	e8 0e f6 ff ff       	call   f0100ee4 <page_alloc>
f01018d6:	89 c3                	mov    %eax,%ebx
f01018d8:	83 c4 10             	add    $0x10,%esp
f01018db:	85 c0                	test   %eax,%eax
f01018dd:	75 19                	jne    f01018f8 <mem_init+0x5d8>
f01018df:	68 5b 73 10 f0       	push   $0xf010735b
f01018e4:	68 7d 72 10 f0       	push   $0xf010727d
f01018e9:	68 ca 03 00 00       	push   $0x3ca
f01018ee:	68 3d 72 10 f0       	push   $0xf010723d
f01018f3:	e8 48 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018f8:	83 ec 0c             	sub    $0xc,%esp
f01018fb:	6a 00                	push   $0x0
f01018fd:	e8 e2 f5 ff ff       	call   f0100ee4 <page_alloc>
f0101902:	89 c6                	mov    %eax,%esi
f0101904:	83 c4 10             	add    $0x10,%esp
f0101907:	85 c0                	test   %eax,%eax
f0101909:	75 19                	jne    f0101924 <mem_init+0x604>
f010190b:	68 71 73 10 f0       	push   $0xf0107371
f0101910:	68 7d 72 10 f0       	push   $0xf010727d
f0101915:	68 cb 03 00 00       	push   $0x3cb
f010191a:	68 3d 72 10 f0       	push   $0xf010723d
f010191f:	e8 1c e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101924:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101927:	75 19                	jne    f0101942 <mem_init+0x622>
f0101929:	68 87 73 10 f0       	push   $0xf0107387
f010192e:	68 7d 72 10 f0       	push   $0xf010727d
f0101933:	68 ce 03 00 00       	push   $0x3ce
f0101938:	68 3d 72 10 f0       	push   $0xf010723d
f010193d:	e8 fe e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101942:	39 c3                	cmp    %eax,%ebx
f0101944:	74 05                	je     f010194b <mem_init+0x62b>
f0101946:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101949:	75 19                	jne    f0101964 <mem_init+0x644>
f010194b:	68 60 6a 10 f0       	push   $0xf0106a60
f0101950:	68 7d 72 10 f0       	push   $0xf010727d
f0101955:	68 cf 03 00 00       	push   $0x3cf
f010195a:	68 3d 72 10 f0       	push   $0xf010723d
f010195f:	e8 dc e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101964:	a1 40 f2 29 f0       	mov    0xf029f240,%eax
f0101969:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010196c:	c7 05 40 f2 29 f0 00 	movl   $0x0,0xf029f240
f0101973:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101976:	83 ec 0c             	sub    $0xc,%esp
f0101979:	6a 00                	push   $0x0
f010197b:	e8 64 f5 ff ff       	call   f0100ee4 <page_alloc>
f0101980:	83 c4 10             	add    $0x10,%esp
f0101983:	85 c0                	test   %eax,%eax
f0101985:	74 19                	je     f01019a0 <mem_init+0x680>
f0101987:	68 f0 73 10 f0       	push   $0xf01073f0
f010198c:	68 7d 72 10 f0       	push   $0xf010727d
f0101991:	68 d6 03 00 00       	push   $0x3d6
f0101996:	68 3d 72 10 f0       	push   $0xf010723d
f010199b:	e8 a0 e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01019a0:	83 ec 04             	sub    $0x4,%esp
f01019a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01019a6:	50                   	push   %eax
f01019a7:	6a 00                	push   $0x0
f01019a9:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f01019af:	e8 88 f7 ff ff       	call   f010113c <page_lookup>
f01019b4:	83 c4 10             	add    $0x10,%esp
f01019b7:	85 c0                	test   %eax,%eax
f01019b9:	74 19                	je     f01019d4 <mem_init+0x6b4>
f01019bb:	68 a0 6a 10 f0       	push   $0xf0106aa0
f01019c0:	68 7d 72 10 f0       	push   $0xf010727d
f01019c5:	68 d9 03 00 00       	push   $0x3d9
f01019ca:	68 3d 72 10 f0       	push   $0xf010723d
f01019cf:	e8 6c e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019d4:	6a 02                	push   $0x2
f01019d6:	6a 00                	push   $0x0
f01019d8:	53                   	push   %ebx
f01019d9:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f01019df:	e8 3e f8 ff ff       	call   f0101222 <page_insert>
f01019e4:	83 c4 10             	add    $0x10,%esp
f01019e7:	85 c0                	test   %eax,%eax
f01019e9:	78 19                	js     f0101a04 <mem_init+0x6e4>
f01019eb:	68 d8 6a 10 f0       	push   $0xf0106ad8
f01019f0:	68 7d 72 10 f0       	push   $0xf010727d
f01019f5:	68 dc 03 00 00       	push   $0x3dc
f01019fa:	68 3d 72 10 f0       	push   $0xf010723d
f01019ff:	e8 3c e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a04:	83 ec 0c             	sub    $0xc,%esp
f0101a07:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a0a:	e8 45 f5 ff ff       	call   f0100f54 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a0f:	6a 02                	push   $0x2
f0101a11:	6a 00                	push   $0x0
f0101a13:	53                   	push   %ebx
f0101a14:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0101a1a:	e8 03 f8 ff ff       	call   f0101222 <page_insert>
f0101a1f:	83 c4 20             	add    $0x20,%esp
f0101a22:	85 c0                	test   %eax,%eax
f0101a24:	74 19                	je     f0101a3f <mem_init+0x71f>
f0101a26:	68 08 6b 10 f0       	push   $0xf0106b08
f0101a2b:	68 7d 72 10 f0       	push   $0xf010727d
f0101a30:	68 e0 03 00 00       	push   $0x3e0
f0101a35:	68 3d 72 10 f0       	push   $0xf010723d
f0101a3a:	e8 01 e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a3f:	8b 3d 98 fe 29 f0    	mov    0xf029fe98,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a45:	a1 9c fe 29 f0       	mov    0xf029fe9c,%eax
f0101a4a:	89 c1                	mov    %eax,%ecx
f0101a4c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101a4f:	8b 17                	mov    (%edi),%edx
f0101a51:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a5a:	29 c8                	sub    %ecx,%eax
f0101a5c:	c1 f8 03             	sar    $0x3,%eax
f0101a5f:	c1 e0 0c             	shl    $0xc,%eax
f0101a62:	39 c2                	cmp    %eax,%edx
f0101a64:	74 19                	je     f0101a7f <mem_init+0x75f>
f0101a66:	68 38 6b 10 f0       	push   $0xf0106b38
f0101a6b:	68 7d 72 10 f0       	push   $0xf010727d
f0101a70:	68 e1 03 00 00       	push   $0x3e1
f0101a75:	68 3d 72 10 f0       	push   $0xf010723d
f0101a7a:	e8 c1 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a7f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a84:	89 f8                	mov    %edi,%eax
f0101a86:	e8 b7 ef ff ff       	call   f0100a42 <check_va2pa>
f0101a8b:	89 da                	mov    %ebx,%edx
f0101a8d:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a90:	c1 fa 03             	sar    $0x3,%edx
f0101a93:	c1 e2 0c             	shl    $0xc,%edx
f0101a96:	39 d0                	cmp    %edx,%eax
f0101a98:	74 19                	je     f0101ab3 <mem_init+0x793>
f0101a9a:	68 60 6b 10 f0       	push   $0xf0106b60
f0101a9f:	68 7d 72 10 f0       	push   $0xf010727d
f0101aa4:	68 e2 03 00 00       	push   $0x3e2
f0101aa9:	68 3d 72 10 f0       	push   $0xf010723d
f0101aae:	e8 8d e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101ab3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ab8:	74 19                	je     f0101ad3 <mem_init+0x7b3>
f0101aba:	68 42 74 10 f0       	push   $0xf0107442
f0101abf:	68 7d 72 10 f0       	push   $0xf010727d
f0101ac4:	68 e3 03 00 00       	push   $0x3e3
f0101ac9:	68 3d 72 10 f0       	push   $0xf010723d
f0101ace:	e8 6d e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101ad3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ad6:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101adb:	74 19                	je     f0101af6 <mem_init+0x7d6>
f0101add:	68 53 74 10 f0       	push   $0xf0107453
f0101ae2:	68 7d 72 10 f0       	push   $0xf010727d
f0101ae7:	68 e4 03 00 00       	push   $0x3e4
f0101aec:	68 3d 72 10 f0       	push   $0xf010723d
f0101af1:	e8 4a e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101af6:	6a 02                	push   $0x2
f0101af8:	68 00 10 00 00       	push   $0x1000
f0101afd:	56                   	push   %esi
f0101afe:	57                   	push   %edi
f0101aff:	e8 1e f7 ff ff       	call   f0101222 <page_insert>
f0101b04:	83 c4 10             	add    $0x10,%esp
f0101b07:	85 c0                	test   %eax,%eax
f0101b09:	74 19                	je     f0101b24 <mem_init+0x804>
f0101b0b:	68 90 6b 10 f0       	push   $0xf0106b90
f0101b10:	68 7d 72 10 f0       	push   $0xf010727d
f0101b15:	68 e7 03 00 00       	push   $0x3e7
f0101b1a:	68 3d 72 10 f0       	push   $0xf010723d
f0101b1f:	e8 1c e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b24:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b29:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f0101b2e:	e8 0f ef ff ff       	call   f0100a42 <check_va2pa>
f0101b33:	89 f2                	mov    %esi,%edx
f0101b35:	2b 15 9c fe 29 f0    	sub    0xf029fe9c,%edx
f0101b3b:	c1 fa 03             	sar    $0x3,%edx
f0101b3e:	c1 e2 0c             	shl    $0xc,%edx
f0101b41:	39 d0                	cmp    %edx,%eax
f0101b43:	74 19                	je     f0101b5e <mem_init+0x83e>
f0101b45:	68 cc 6b 10 f0       	push   $0xf0106bcc
f0101b4a:	68 7d 72 10 f0       	push   $0xf010727d
f0101b4f:	68 e8 03 00 00       	push   $0x3e8
f0101b54:	68 3d 72 10 f0       	push   $0xf010723d
f0101b59:	e8 e2 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b5e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b63:	74 19                	je     f0101b7e <mem_init+0x85e>
f0101b65:	68 64 74 10 f0       	push   $0xf0107464
f0101b6a:	68 7d 72 10 f0       	push   $0xf010727d
f0101b6f:	68 e9 03 00 00       	push   $0x3e9
f0101b74:	68 3d 72 10 f0       	push   $0xf010723d
f0101b79:	e8 c2 e4 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b7e:	83 ec 0c             	sub    $0xc,%esp
f0101b81:	6a 00                	push   $0x0
f0101b83:	e8 5c f3 ff ff       	call   f0100ee4 <page_alloc>
f0101b88:	83 c4 10             	add    $0x10,%esp
f0101b8b:	85 c0                	test   %eax,%eax
f0101b8d:	74 19                	je     f0101ba8 <mem_init+0x888>
f0101b8f:	68 f0 73 10 f0       	push   $0xf01073f0
f0101b94:	68 7d 72 10 f0       	push   $0xf010727d
f0101b99:	68 ec 03 00 00       	push   $0x3ec
f0101b9e:	68 3d 72 10 f0       	push   $0xf010723d
f0101ba3:	e8 98 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ba8:	6a 02                	push   $0x2
f0101baa:	68 00 10 00 00       	push   $0x1000
f0101baf:	56                   	push   %esi
f0101bb0:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0101bb6:	e8 67 f6 ff ff       	call   f0101222 <page_insert>
f0101bbb:	83 c4 10             	add    $0x10,%esp
f0101bbe:	85 c0                	test   %eax,%eax
f0101bc0:	74 19                	je     f0101bdb <mem_init+0x8bb>
f0101bc2:	68 90 6b 10 f0       	push   $0xf0106b90
f0101bc7:	68 7d 72 10 f0       	push   $0xf010727d
f0101bcc:	68 ef 03 00 00       	push   $0x3ef
f0101bd1:	68 3d 72 10 f0       	push   $0xf010723d
f0101bd6:	e8 65 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bdb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101be0:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f0101be5:	e8 58 ee ff ff       	call   f0100a42 <check_va2pa>
f0101bea:	89 f2                	mov    %esi,%edx
f0101bec:	2b 15 9c fe 29 f0    	sub    0xf029fe9c,%edx
f0101bf2:	c1 fa 03             	sar    $0x3,%edx
f0101bf5:	c1 e2 0c             	shl    $0xc,%edx
f0101bf8:	39 d0                	cmp    %edx,%eax
f0101bfa:	74 19                	je     f0101c15 <mem_init+0x8f5>
f0101bfc:	68 cc 6b 10 f0       	push   $0xf0106bcc
f0101c01:	68 7d 72 10 f0       	push   $0xf010727d
f0101c06:	68 f0 03 00 00       	push   $0x3f0
f0101c0b:	68 3d 72 10 f0       	push   $0xf010723d
f0101c10:	e8 2b e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c15:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c1a:	74 19                	je     f0101c35 <mem_init+0x915>
f0101c1c:	68 64 74 10 f0       	push   $0xf0107464
f0101c21:	68 7d 72 10 f0       	push   $0xf010727d
f0101c26:	68 f1 03 00 00       	push   $0x3f1
f0101c2b:	68 3d 72 10 f0       	push   $0xf010723d
f0101c30:	e8 0b e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c35:	83 ec 0c             	sub    $0xc,%esp
f0101c38:	6a 00                	push   $0x0
f0101c3a:	e8 a5 f2 ff ff       	call   f0100ee4 <page_alloc>
f0101c3f:	83 c4 10             	add    $0x10,%esp
f0101c42:	85 c0                	test   %eax,%eax
f0101c44:	74 19                	je     f0101c5f <mem_init+0x93f>
f0101c46:	68 f0 73 10 f0       	push   $0xf01073f0
f0101c4b:	68 7d 72 10 f0       	push   $0xf010727d
f0101c50:	68 f5 03 00 00       	push   $0x3f5
f0101c55:	68 3d 72 10 f0       	push   $0xf010723d
f0101c5a:	e8 e1 e3 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c5f:	8b 15 98 fe 29 f0    	mov    0xf029fe98,%edx
f0101c65:	8b 02                	mov    (%edx),%eax
f0101c67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c6c:	89 c1                	mov    %eax,%ecx
f0101c6e:	c1 e9 0c             	shr    $0xc,%ecx
f0101c71:	3b 0d 94 fe 29 f0    	cmp    0xf029fe94,%ecx
f0101c77:	72 15                	jb     f0101c8e <mem_init+0x96e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c79:	50                   	push   %eax
f0101c7a:	68 44 63 10 f0       	push   $0xf0106344
f0101c7f:	68 f8 03 00 00       	push   $0x3f8
f0101c84:	68 3d 72 10 f0       	push   $0xf010723d
f0101c89:	e8 b2 e3 ff ff       	call   f0100040 <_panic>
f0101c8e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c96:	83 ec 04             	sub    $0x4,%esp
f0101c99:	6a 00                	push   $0x0
f0101c9b:	68 00 10 00 00       	push   $0x1000
f0101ca0:	52                   	push   %edx
f0101ca1:	e8 10 f3 ff ff       	call   f0100fb6 <pgdir_walk>
f0101ca6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ca9:	8d 51 04             	lea    0x4(%ecx),%edx
f0101cac:	83 c4 10             	add    $0x10,%esp
f0101caf:	39 d0                	cmp    %edx,%eax
f0101cb1:	74 19                	je     f0101ccc <mem_init+0x9ac>
f0101cb3:	68 fc 6b 10 f0       	push   $0xf0106bfc
f0101cb8:	68 7d 72 10 f0       	push   $0xf010727d
f0101cbd:	68 f9 03 00 00       	push   $0x3f9
f0101cc2:	68 3d 72 10 f0       	push   $0xf010723d
f0101cc7:	e8 74 e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ccc:	6a 06                	push   $0x6
f0101cce:	68 00 10 00 00       	push   $0x1000
f0101cd3:	56                   	push   %esi
f0101cd4:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0101cda:	e8 43 f5 ff ff       	call   f0101222 <page_insert>
f0101cdf:	83 c4 10             	add    $0x10,%esp
f0101ce2:	85 c0                	test   %eax,%eax
f0101ce4:	74 19                	je     f0101cff <mem_init+0x9df>
f0101ce6:	68 3c 6c 10 f0       	push   $0xf0106c3c
f0101ceb:	68 7d 72 10 f0       	push   $0xf010727d
f0101cf0:	68 fc 03 00 00       	push   $0x3fc
f0101cf5:	68 3d 72 10 f0       	push   $0xf010723d
f0101cfa:	e8 41 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cff:	8b 3d 98 fe 29 f0    	mov    0xf029fe98,%edi
f0101d05:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d0a:	89 f8                	mov    %edi,%eax
f0101d0c:	e8 31 ed ff ff       	call   f0100a42 <check_va2pa>
f0101d11:	89 f2                	mov    %esi,%edx
f0101d13:	2b 15 9c fe 29 f0    	sub    0xf029fe9c,%edx
f0101d19:	c1 fa 03             	sar    $0x3,%edx
f0101d1c:	c1 e2 0c             	shl    $0xc,%edx
f0101d1f:	39 d0                	cmp    %edx,%eax
f0101d21:	74 19                	je     f0101d3c <mem_init+0xa1c>
f0101d23:	68 cc 6b 10 f0       	push   $0xf0106bcc
f0101d28:	68 7d 72 10 f0       	push   $0xf010727d
f0101d2d:	68 fd 03 00 00       	push   $0x3fd
f0101d32:	68 3d 72 10 f0       	push   $0xf010723d
f0101d37:	e8 04 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d3c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d41:	74 19                	je     f0101d5c <mem_init+0xa3c>
f0101d43:	68 64 74 10 f0       	push   $0xf0107464
f0101d48:	68 7d 72 10 f0       	push   $0xf010727d
f0101d4d:	68 fe 03 00 00       	push   $0x3fe
f0101d52:	68 3d 72 10 f0       	push   $0xf010723d
f0101d57:	e8 e4 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d5c:	83 ec 04             	sub    $0x4,%esp
f0101d5f:	6a 00                	push   $0x0
f0101d61:	68 00 10 00 00       	push   $0x1000
f0101d66:	57                   	push   %edi
f0101d67:	e8 4a f2 ff ff       	call   f0100fb6 <pgdir_walk>
f0101d6c:	83 c4 10             	add    $0x10,%esp
f0101d6f:	f6 00 04             	testb  $0x4,(%eax)
f0101d72:	75 19                	jne    f0101d8d <mem_init+0xa6d>
f0101d74:	68 7c 6c 10 f0       	push   $0xf0106c7c
f0101d79:	68 7d 72 10 f0       	push   $0xf010727d
f0101d7e:	68 ff 03 00 00       	push   $0x3ff
f0101d83:	68 3d 72 10 f0       	push   $0xf010723d
f0101d88:	e8 b3 e2 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d8d:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f0101d92:	f6 00 04             	testb  $0x4,(%eax)
f0101d95:	75 19                	jne    f0101db0 <mem_init+0xa90>
f0101d97:	68 75 74 10 f0       	push   $0xf0107475
f0101d9c:	68 7d 72 10 f0       	push   $0xf010727d
f0101da1:	68 00 04 00 00       	push   $0x400
f0101da6:	68 3d 72 10 f0       	push   $0xf010723d
f0101dab:	e8 90 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101db0:	6a 02                	push   $0x2
f0101db2:	68 00 10 00 00       	push   $0x1000
f0101db7:	56                   	push   %esi
f0101db8:	50                   	push   %eax
f0101db9:	e8 64 f4 ff ff       	call   f0101222 <page_insert>
f0101dbe:	83 c4 10             	add    $0x10,%esp
f0101dc1:	85 c0                	test   %eax,%eax
f0101dc3:	74 19                	je     f0101dde <mem_init+0xabe>
f0101dc5:	68 90 6b 10 f0       	push   $0xf0106b90
f0101dca:	68 7d 72 10 f0       	push   $0xf010727d
f0101dcf:	68 03 04 00 00       	push   $0x403
f0101dd4:	68 3d 72 10 f0       	push   $0xf010723d
f0101dd9:	e8 62 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101dde:	83 ec 04             	sub    $0x4,%esp
f0101de1:	6a 00                	push   $0x0
f0101de3:	68 00 10 00 00       	push   $0x1000
f0101de8:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0101dee:	e8 c3 f1 ff ff       	call   f0100fb6 <pgdir_walk>
f0101df3:	83 c4 10             	add    $0x10,%esp
f0101df6:	f6 00 02             	testb  $0x2,(%eax)
f0101df9:	75 19                	jne    f0101e14 <mem_init+0xaf4>
f0101dfb:	68 b0 6c 10 f0       	push   $0xf0106cb0
f0101e00:	68 7d 72 10 f0       	push   $0xf010727d
f0101e05:	68 04 04 00 00       	push   $0x404
f0101e0a:	68 3d 72 10 f0       	push   $0xf010723d
f0101e0f:	e8 2c e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e14:	83 ec 04             	sub    $0x4,%esp
f0101e17:	6a 00                	push   $0x0
f0101e19:	68 00 10 00 00       	push   $0x1000
f0101e1e:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0101e24:	e8 8d f1 ff ff       	call   f0100fb6 <pgdir_walk>
f0101e29:	83 c4 10             	add    $0x10,%esp
f0101e2c:	f6 00 04             	testb  $0x4,(%eax)
f0101e2f:	74 19                	je     f0101e4a <mem_init+0xb2a>
f0101e31:	68 e4 6c 10 f0       	push   $0xf0106ce4
f0101e36:	68 7d 72 10 f0       	push   $0xf010727d
f0101e3b:	68 05 04 00 00       	push   $0x405
f0101e40:	68 3d 72 10 f0       	push   $0xf010723d
f0101e45:	e8 f6 e1 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e4a:	6a 02                	push   $0x2
f0101e4c:	68 00 00 40 00       	push   $0x400000
f0101e51:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e54:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0101e5a:	e8 c3 f3 ff ff       	call   f0101222 <page_insert>
f0101e5f:	83 c4 10             	add    $0x10,%esp
f0101e62:	85 c0                	test   %eax,%eax
f0101e64:	78 19                	js     f0101e7f <mem_init+0xb5f>
f0101e66:	68 1c 6d 10 f0       	push   $0xf0106d1c
f0101e6b:	68 7d 72 10 f0       	push   $0xf010727d
f0101e70:	68 08 04 00 00       	push   $0x408
f0101e75:	68 3d 72 10 f0       	push   $0xf010723d
f0101e7a:	e8 c1 e1 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e7f:	6a 02                	push   $0x2
f0101e81:	68 00 10 00 00       	push   $0x1000
f0101e86:	53                   	push   %ebx
f0101e87:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0101e8d:	e8 90 f3 ff ff       	call   f0101222 <page_insert>
f0101e92:	83 c4 10             	add    $0x10,%esp
f0101e95:	85 c0                	test   %eax,%eax
f0101e97:	74 19                	je     f0101eb2 <mem_init+0xb92>
f0101e99:	68 54 6d 10 f0       	push   $0xf0106d54
f0101e9e:	68 7d 72 10 f0       	push   $0xf010727d
f0101ea3:	68 0b 04 00 00       	push   $0x40b
f0101ea8:	68 3d 72 10 f0       	push   $0xf010723d
f0101ead:	e8 8e e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101eb2:	83 ec 04             	sub    $0x4,%esp
f0101eb5:	6a 00                	push   $0x0
f0101eb7:	68 00 10 00 00       	push   $0x1000
f0101ebc:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0101ec2:	e8 ef f0 ff ff       	call   f0100fb6 <pgdir_walk>
f0101ec7:	83 c4 10             	add    $0x10,%esp
f0101eca:	f6 00 04             	testb  $0x4,(%eax)
f0101ecd:	74 19                	je     f0101ee8 <mem_init+0xbc8>
f0101ecf:	68 e4 6c 10 f0       	push   $0xf0106ce4
f0101ed4:	68 7d 72 10 f0       	push   $0xf010727d
f0101ed9:	68 0c 04 00 00       	push   $0x40c
f0101ede:	68 3d 72 10 f0       	push   $0xf010723d
f0101ee3:	e8 58 e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ee8:	8b 3d 98 fe 29 f0    	mov    0xf029fe98,%edi
f0101eee:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ef3:	89 f8                	mov    %edi,%eax
f0101ef5:	e8 48 eb ff ff       	call   f0100a42 <check_va2pa>
f0101efa:	89 c1                	mov    %eax,%ecx
f0101efc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101eff:	89 d8                	mov    %ebx,%eax
f0101f01:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0101f07:	c1 f8 03             	sar    $0x3,%eax
f0101f0a:	c1 e0 0c             	shl    $0xc,%eax
f0101f0d:	39 c1                	cmp    %eax,%ecx
f0101f0f:	74 19                	je     f0101f2a <mem_init+0xc0a>
f0101f11:	68 90 6d 10 f0       	push   $0xf0106d90
f0101f16:	68 7d 72 10 f0       	push   $0xf010727d
f0101f1b:	68 0f 04 00 00       	push   $0x40f
f0101f20:	68 3d 72 10 f0       	push   $0xf010723d
f0101f25:	e8 16 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f2a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f2f:	89 f8                	mov    %edi,%eax
f0101f31:	e8 0c eb ff ff       	call   f0100a42 <check_va2pa>
f0101f36:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101f39:	74 19                	je     f0101f54 <mem_init+0xc34>
f0101f3b:	68 bc 6d 10 f0       	push   $0xf0106dbc
f0101f40:	68 7d 72 10 f0       	push   $0xf010727d
f0101f45:	68 10 04 00 00       	push   $0x410
f0101f4a:	68 3d 72 10 f0       	push   $0xf010723d
f0101f4f:	e8 ec e0 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f54:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101f59:	74 19                	je     f0101f74 <mem_init+0xc54>
f0101f5b:	68 8b 74 10 f0       	push   $0xf010748b
f0101f60:	68 7d 72 10 f0       	push   $0xf010727d
f0101f65:	68 12 04 00 00       	push   $0x412
f0101f6a:	68 3d 72 10 f0       	push   $0xf010723d
f0101f6f:	e8 cc e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f74:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f79:	74 19                	je     f0101f94 <mem_init+0xc74>
f0101f7b:	68 9c 74 10 f0       	push   $0xf010749c
f0101f80:	68 7d 72 10 f0       	push   $0xf010727d
f0101f85:	68 13 04 00 00       	push   $0x413
f0101f8a:	68 3d 72 10 f0       	push   $0xf010723d
f0101f8f:	e8 ac e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f94:	83 ec 0c             	sub    $0xc,%esp
f0101f97:	6a 00                	push   $0x0
f0101f99:	e8 46 ef ff ff       	call   f0100ee4 <page_alloc>
f0101f9e:	83 c4 10             	add    $0x10,%esp
f0101fa1:	85 c0                	test   %eax,%eax
f0101fa3:	74 04                	je     f0101fa9 <mem_init+0xc89>
f0101fa5:	39 c6                	cmp    %eax,%esi
f0101fa7:	74 19                	je     f0101fc2 <mem_init+0xca2>
f0101fa9:	68 ec 6d 10 f0       	push   $0xf0106dec
f0101fae:	68 7d 72 10 f0       	push   $0xf010727d
f0101fb3:	68 16 04 00 00       	push   $0x416
f0101fb8:	68 3d 72 10 f0       	push   $0xf010723d
f0101fbd:	e8 7e e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101fc2:	83 ec 08             	sub    $0x8,%esp
f0101fc5:	6a 00                	push   $0x0
f0101fc7:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0101fcd:	e8 0a f2 ff ff       	call   f01011dc <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101fd2:	8b 3d 98 fe 29 f0    	mov    0xf029fe98,%edi
f0101fd8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fdd:	89 f8                	mov    %edi,%eax
f0101fdf:	e8 5e ea ff ff       	call   f0100a42 <check_va2pa>
f0101fe4:	83 c4 10             	add    $0x10,%esp
f0101fe7:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fea:	74 19                	je     f0102005 <mem_init+0xce5>
f0101fec:	68 10 6e 10 f0       	push   $0xf0106e10
f0101ff1:	68 7d 72 10 f0       	push   $0xf010727d
f0101ff6:	68 1a 04 00 00       	push   $0x41a
f0101ffb:	68 3d 72 10 f0       	push   $0xf010723d
f0102000:	e8 3b e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102005:	ba 00 10 00 00       	mov    $0x1000,%edx
f010200a:	89 f8                	mov    %edi,%eax
f010200c:	e8 31 ea ff ff       	call   f0100a42 <check_va2pa>
f0102011:	89 da                	mov    %ebx,%edx
f0102013:	2b 15 9c fe 29 f0    	sub    0xf029fe9c,%edx
f0102019:	c1 fa 03             	sar    $0x3,%edx
f010201c:	c1 e2 0c             	shl    $0xc,%edx
f010201f:	39 d0                	cmp    %edx,%eax
f0102021:	74 19                	je     f010203c <mem_init+0xd1c>
f0102023:	68 bc 6d 10 f0       	push   $0xf0106dbc
f0102028:	68 7d 72 10 f0       	push   $0xf010727d
f010202d:	68 1b 04 00 00       	push   $0x41b
f0102032:	68 3d 72 10 f0       	push   $0xf010723d
f0102037:	e8 04 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010203c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102041:	74 19                	je     f010205c <mem_init+0xd3c>
f0102043:	68 42 74 10 f0       	push   $0xf0107442
f0102048:	68 7d 72 10 f0       	push   $0xf010727d
f010204d:	68 1c 04 00 00       	push   $0x41c
f0102052:	68 3d 72 10 f0       	push   $0xf010723d
f0102057:	e8 e4 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010205c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102061:	74 19                	je     f010207c <mem_init+0xd5c>
f0102063:	68 9c 74 10 f0       	push   $0xf010749c
f0102068:	68 7d 72 10 f0       	push   $0xf010727d
f010206d:	68 1d 04 00 00       	push   $0x41d
f0102072:	68 3d 72 10 f0       	push   $0xf010723d
f0102077:	e8 c4 df ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010207c:	6a 00                	push   $0x0
f010207e:	68 00 10 00 00       	push   $0x1000
f0102083:	53                   	push   %ebx
f0102084:	57                   	push   %edi
f0102085:	e8 98 f1 ff ff       	call   f0101222 <page_insert>
f010208a:	83 c4 10             	add    $0x10,%esp
f010208d:	85 c0                	test   %eax,%eax
f010208f:	74 19                	je     f01020aa <mem_init+0xd8a>
f0102091:	68 34 6e 10 f0       	push   $0xf0106e34
f0102096:	68 7d 72 10 f0       	push   $0xf010727d
f010209b:	68 20 04 00 00       	push   $0x420
f01020a0:	68 3d 72 10 f0       	push   $0xf010723d
f01020a5:	e8 96 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01020aa:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020af:	75 19                	jne    f01020ca <mem_init+0xdaa>
f01020b1:	68 ad 74 10 f0       	push   $0xf01074ad
f01020b6:	68 7d 72 10 f0       	push   $0xf010727d
f01020bb:	68 21 04 00 00       	push   $0x421
f01020c0:	68 3d 72 10 f0       	push   $0xf010723d
f01020c5:	e8 76 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01020ca:	83 3b 00             	cmpl   $0x0,(%ebx)
f01020cd:	74 19                	je     f01020e8 <mem_init+0xdc8>
f01020cf:	68 b9 74 10 f0       	push   $0xf01074b9
f01020d4:	68 7d 72 10 f0       	push   $0xf010727d
f01020d9:	68 22 04 00 00       	push   $0x422
f01020de:	68 3d 72 10 f0       	push   $0xf010723d
f01020e3:	e8 58 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01020e8:	83 ec 08             	sub    $0x8,%esp
f01020eb:	68 00 10 00 00       	push   $0x1000
f01020f0:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f01020f6:	e8 e1 f0 ff ff       	call   f01011dc <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020fb:	8b 3d 98 fe 29 f0    	mov    0xf029fe98,%edi
f0102101:	ba 00 00 00 00       	mov    $0x0,%edx
f0102106:	89 f8                	mov    %edi,%eax
f0102108:	e8 35 e9 ff ff       	call   f0100a42 <check_va2pa>
f010210d:	83 c4 10             	add    $0x10,%esp
f0102110:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102113:	74 19                	je     f010212e <mem_init+0xe0e>
f0102115:	68 10 6e 10 f0       	push   $0xf0106e10
f010211a:	68 7d 72 10 f0       	push   $0xf010727d
f010211f:	68 26 04 00 00       	push   $0x426
f0102124:	68 3d 72 10 f0       	push   $0xf010723d
f0102129:	e8 12 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010212e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102133:	89 f8                	mov    %edi,%eax
f0102135:	e8 08 e9 ff ff       	call   f0100a42 <check_va2pa>
f010213a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010213d:	74 19                	je     f0102158 <mem_init+0xe38>
f010213f:	68 6c 6e 10 f0       	push   $0xf0106e6c
f0102144:	68 7d 72 10 f0       	push   $0xf010727d
f0102149:	68 27 04 00 00       	push   $0x427
f010214e:	68 3d 72 10 f0       	push   $0xf010723d
f0102153:	e8 e8 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102158:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010215d:	74 19                	je     f0102178 <mem_init+0xe58>
f010215f:	68 ce 74 10 f0       	push   $0xf01074ce
f0102164:	68 7d 72 10 f0       	push   $0xf010727d
f0102169:	68 28 04 00 00       	push   $0x428
f010216e:	68 3d 72 10 f0       	push   $0xf010723d
f0102173:	e8 c8 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102178:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010217d:	74 19                	je     f0102198 <mem_init+0xe78>
f010217f:	68 9c 74 10 f0       	push   $0xf010749c
f0102184:	68 7d 72 10 f0       	push   $0xf010727d
f0102189:	68 29 04 00 00       	push   $0x429
f010218e:	68 3d 72 10 f0       	push   $0xf010723d
f0102193:	e8 a8 de ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102198:	83 ec 0c             	sub    $0xc,%esp
f010219b:	6a 00                	push   $0x0
f010219d:	e8 42 ed ff ff       	call   f0100ee4 <page_alloc>
f01021a2:	83 c4 10             	add    $0x10,%esp
f01021a5:	39 c3                	cmp    %eax,%ebx
f01021a7:	75 04                	jne    f01021ad <mem_init+0xe8d>
f01021a9:	85 c0                	test   %eax,%eax
f01021ab:	75 19                	jne    f01021c6 <mem_init+0xea6>
f01021ad:	68 94 6e 10 f0       	push   $0xf0106e94
f01021b2:	68 7d 72 10 f0       	push   $0xf010727d
f01021b7:	68 2c 04 00 00       	push   $0x42c
f01021bc:	68 3d 72 10 f0       	push   $0xf010723d
f01021c1:	e8 7a de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01021c6:	83 ec 0c             	sub    $0xc,%esp
f01021c9:	6a 00                	push   $0x0
f01021cb:	e8 14 ed ff ff       	call   f0100ee4 <page_alloc>
f01021d0:	83 c4 10             	add    $0x10,%esp
f01021d3:	85 c0                	test   %eax,%eax
f01021d5:	74 19                	je     f01021f0 <mem_init+0xed0>
f01021d7:	68 f0 73 10 f0       	push   $0xf01073f0
f01021dc:	68 7d 72 10 f0       	push   $0xf010727d
f01021e1:	68 2f 04 00 00       	push   $0x42f
f01021e6:	68 3d 72 10 f0       	push   $0xf010723d
f01021eb:	e8 50 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01021f0:	8b 0d 98 fe 29 f0    	mov    0xf029fe98,%ecx
f01021f6:	8b 11                	mov    (%ecx),%edx
f01021f8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102201:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0102207:	c1 f8 03             	sar    $0x3,%eax
f010220a:	c1 e0 0c             	shl    $0xc,%eax
f010220d:	39 c2                	cmp    %eax,%edx
f010220f:	74 19                	je     f010222a <mem_init+0xf0a>
f0102211:	68 38 6b 10 f0       	push   $0xf0106b38
f0102216:	68 7d 72 10 f0       	push   $0xf010727d
f010221b:	68 32 04 00 00       	push   $0x432
f0102220:	68 3d 72 10 f0       	push   $0xf010723d
f0102225:	e8 16 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010222a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102230:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102233:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102238:	74 19                	je     f0102253 <mem_init+0xf33>
f010223a:	68 53 74 10 f0       	push   $0xf0107453
f010223f:	68 7d 72 10 f0       	push   $0xf010727d
f0102244:	68 34 04 00 00       	push   $0x434
f0102249:	68 3d 72 10 f0       	push   $0xf010723d
f010224e:	e8 ed dd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102253:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102256:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010225c:	83 ec 0c             	sub    $0xc,%esp
f010225f:	50                   	push   %eax
f0102260:	e8 ef ec ff ff       	call   f0100f54 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102265:	83 c4 0c             	add    $0xc,%esp
f0102268:	6a 01                	push   $0x1
f010226a:	68 00 10 40 00       	push   $0x401000
f010226f:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0102275:	e8 3c ed ff ff       	call   f0100fb6 <pgdir_walk>
f010227a:	89 c7                	mov    %eax,%edi
f010227c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010227f:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f0102284:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102287:	8b 40 04             	mov    0x4(%eax),%eax
f010228a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010228f:	8b 0d 94 fe 29 f0    	mov    0xf029fe94,%ecx
f0102295:	89 c2                	mov    %eax,%edx
f0102297:	c1 ea 0c             	shr    $0xc,%edx
f010229a:	83 c4 10             	add    $0x10,%esp
f010229d:	39 ca                	cmp    %ecx,%edx
f010229f:	72 15                	jb     f01022b6 <mem_init+0xf96>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022a1:	50                   	push   %eax
f01022a2:	68 44 63 10 f0       	push   $0xf0106344
f01022a7:	68 3b 04 00 00       	push   $0x43b
f01022ac:	68 3d 72 10 f0       	push   $0xf010723d
f01022b1:	e8 8a dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01022b6:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01022bb:	39 c7                	cmp    %eax,%edi
f01022bd:	74 19                	je     f01022d8 <mem_init+0xfb8>
f01022bf:	68 df 74 10 f0       	push   $0xf01074df
f01022c4:	68 7d 72 10 f0       	push   $0xf010727d
f01022c9:	68 3c 04 00 00       	push   $0x43c
f01022ce:	68 3d 72 10 f0       	push   $0xf010723d
f01022d3:	e8 68 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01022d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01022db:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01022e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022e5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022eb:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f01022f1:	c1 f8 03             	sar    $0x3,%eax
f01022f4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022f7:	89 c2                	mov    %eax,%edx
f01022f9:	c1 ea 0c             	shr    $0xc,%edx
f01022fc:	39 d1                	cmp    %edx,%ecx
f01022fe:	77 12                	ja     f0102312 <mem_init+0xff2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102300:	50                   	push   %eax
f0102301:	68 44 63 10 f0       	push   $0xf0106344
f0102306:	6a 58                	push   $0x58
f0102308:	68 63 72 10 f0       	push   $0xf0107263
f010230d:	e8 2e dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102312:	83 ec 04             	sub    $0x4,%esp
f0102315:	68 00 10 00 00       	push   $0x1000
f010231a:	68 ff 00 00 00       	push   $0xff
f010231f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102324:	50                   	push   %eax
f0102325:	e8 cd 2d 00 00       	call   f01050f7 <memset>
	page_free(pp0);
f010232a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010232d:	89 3c 24             	mov    %edi,(%esp)
f0102330:	e8 1f ec ff ff       	call   f0100f54 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102335:	83 c4 0c             	add    $0xc,%esp
f0102338:	6a 01                	push   $0x1
f010233a:	6a 00                	push   $0x0
f010233c:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0102342:	e8 6f ec ff ff       	call   f0100fb6 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102347:	89 fa                	mov    %edi,%edx
f0102349:	2b 15 9c fe 29 f0    	sub    0xf029fe9c,%edx
f010234f:	c1 fa 03             	sar    $0x3,%edx
f0102352:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102355:	89 d0                	mov    %edx,%eax
f0102357:	c1 e8 0c             	shr    $0xc,%eax
f010235a:	83 c4 10             	add    $0x10,%esp
f010235d:	3b 05 94 fe 29 f0    	cmp    0xf029fe94,%eax
f0102363:	72 12                	jb     f0102377 <mem_init+0x1057>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102365:	52                   	push   %edx
f0102366:	68 44 63 10 f0       	push   $0xf0106344
f010236b:	6a 58                	push   $0x58
f010236d:	68 63 72 10 f0       	push   $0xf0107263
f0102372:	e8 c9 dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102377:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010237d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102380:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102386:	f6 00 01             	testb  $0x1,(%eax)
f0102389:	74 19                	je     f01023a4 <mem_init+0x1084>
f010238b:	68 f7 74 10 f0       	push   $0xf01074f7
f0102390:	68 7d 72 10 f0       	push   $0xf010727d
f0102395:	68 46 04 00 00       	push   $0x446
f010239a:	68 3d 72 10 f0       	push   $0xf010723d
f010239f:	e8 9c dc ff ff       	call   f0100040 <_panic>
f01023a4:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01023a7:	39 d0                	cmp    %edx,%eax
f01023a9:	75 db                	jne    f0102386 <mem_init+0x1066>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01023ab:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f01023b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023b9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01023bf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01023c2:	89 0d 40 f2 29 f0    	mov    %ecx,0xf029f240

	// free the pages we took
	page_free(pp0);
f01023c8:	83 ec 0c             	sub    $0xc,%esp
f01023cb:	50                   	push   %eax
f01023cc:	e8 83 eb ff ff       	call   f0100f54 <page_free>
	page_free(pp1);
f01023d1:	89 1c 24             	mov    %ebx,(%esp)
f01023d4:	e8 7b eb ff ff       	call   f0100f54 <page_free>
	page_free(pp2);
f01023d9:	89 34 24             	mov    %esi,(%esp)
f01023dc:	e8 73 eb ff ff       	call   f0100f54 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01023e1:	83 c4 08             	add    $0x8,%esp
f01023e4:	68 01 10 00 00       	push   $0x1001
f01023e9:	6a 00                	push   $0x0
f01023eb:	e8 c2 ee ff ff       	call   f01012b2 <mmio_map_region>
f01023f0:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01023f2:	83 c4 08             	add    $0x8,%esp
f01023f5:	68 00 10 00 00       	push   $0x1000
f01023fa:	6a 00                	push   $0x0
f01023fc:	e8 b1 ee ff ff       	call   f01012b2 <mmio_map_region>
f0102401:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102403:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102409:	83 c4 10             	add    $0x10,%esp
f010240c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102412:	76 07                	jbe    f010241b <mem_init+0x10fb>
f0102414:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102419:	76 19                	jbe    f0102434 <mem_init+0x1114>
f010241b:	68 b8 6e 10 f0       	push   $0xf0106eb8
f0102420:	68 7d 72 10 f0       	push   $0xf010727d
f0102425:	68 56 04 00 00       	push   $0x456
f010242a:	68 3d 72 10 f0       	push   $0xf010723d
f010242f:	e8 0c dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102434:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010243a:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102440:	77 08                	ja     f010244a <mem_init+0x112a>
f0102442:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102448:	77 19                	ja     f0102463 <mem_init+0x1143>
f010244a:	68 e0 6e 10 f0       	push   $0xf0106ee0
f010244f:	68 7d 72 10 f0       	push   $0xf010727d
f0102454:	68 57 04 00 00       	push   $0x457
f0102459:	68 3d 72 10 f0       	push   $0xf010723d
f010245e:	e8 dd db ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102463:	89 da                	mov    %ebx,%edx
f0102465:	09 f2                	or     %esi,%edx
f0102467:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010246d:	74 19                	je     f0102488 <mem_init+0x1168>
f010246f:	68 08 6f 10 f0       	push   $0xf0106f08
f0102474:	68 7d 72 10 f0       	push   $0xf010727d
f0102479:	68 59 04 00 00       	push   $0x459
f010247e:	68 3d 72 10 f0       	push   $0xf010723d
f0102483:	e8 b8 db ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102488:	39 c6                	cmp    %eax,%esi
f010248a:	73 19                	jae    f01024a5 <mem_init+0x1185>
f010248c:	68 0e 75 10 f0       	push   $0xf010750e
f0102491:	68 7d 72 10 f0       	push   $0xf010727d
f0102496:	68 5b 04 00 00       	push   $0x45b
f010249b:	68 3d 72 10 f0       	push   $0xf010723d
f01024a0:	e8 9b db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01024a5:	8b 3d 98 fe 29 f0    	mov    0xf029fe98,%edi
f01024ab:	89 da                	mov    %ebx,%edx
f01024ad:	89 f8                	mov    %edi,%eax
f01024af:	e8 8e e5 ff ff       	call   f0100a42 <check_va2pa>
f01024b4:	85 c0                	test   %eax,%eax
f01024b6:	74 19                	je     f01024d1 <mem_init+0x11b1>
f01024b8:	68 30 6f 10 f0       	push   $0xf0106f30
f01024bd:	68 7d 72 10 f0       	push   $0xf010727d
f01024c2:	68 5d 04 00 00       	push   $0x45d
f01024c7:	68 3d 72 10 f0       	push   $0xf010723d
f01024cc:	e8 6f db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01024d1:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01024d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024da:	89 c2                	mov    %eax,%edx
f01024dc:	89 f8                	mov    %edi,%eax
f01024de:	e8 5f e5 ff ff       	call   f0100a42 <check_va2pa>
f01024e3:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01024e8:	74 19                	je     f0102503 <mem_init+0x11e3>
f01024ea:	68 54 6f 10 f0       	push   $0xf0106f54
f01024ef:	68 7d 72 10 f0       	push   $0xf010727d
f01024f4:	68 5e 04 00 00       	push   $0x45e
f01024f9:	68 3d 72 10 f0       	push   $0xf010723d
f01024fe:	e8 3d db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102503:	89 f2                	mov    %esi,%edx
f0102505:	89 f8                	mov    %edi,%eax
f0102507:	e8 36 e5 ff ff       	call   f0100a42 <check_va2pa>
f010250c:	85 c0                	test   %eax,%eax
f010250e:	74 19                	je     f0102529 <mem_init+0x1209>
f0102510:	68 84 6f 10 f0       	push   $0xf0106f84
f0102515:	68 7d 72 10 f0       	push   $0xf010727d
f010251a:	68 5f 04 00 00       	push   $0x45f
f010251f:	68 3d 72 10 f0       	push   $0xf010723d
f0102524:	e8 17 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102529:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010252f:	89 f8                	mov    %edi,%eax
f0102531:	e8 0c e5 ff ff       	call   f0100a42 <check_va2pa>
f0102536:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102539:	74 19                	je     f0102554 <mem_init+0x1234>
f010253b:	68 a8 6f 10 f0       	push   $0xf0106fa8
f0102540:	68 7d 72 10 f0       	push   $0xf010727d
f0102545:	68 60 04 00 00       	push   $0x460
f010254a:	68 3d 72 10 f0       	push   $0xf010723d
f010254f:	e8 ec da ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102554:	83 ec 04             	sub    $0x4,%esp
f0102557:	6a 00                	push   $0x0
f0102559:	53                   	push   %ebx
f010255a:	57                   	push   %edi
f010255b:	e8 56 ea ff ff       	call   f0100fb6 <pgdir_walk>
f0102560:	83 c4 10             	add    $0x10,%esp
f0102563:	f6 00 1a             	testb  $0x1a,(%eax)
f0102566:	75 19                	jne    f0102581 <mem_init+0x1261>
f0102568:	68 d4 6f 10 f0       	push   $0xf0106fd4
f010256d:	68 7d 72 10 f0       	push   $0xf010727d
f0102572:	68 62 04 00 00       	push   $0x462
f0102577:	68 3d 72 10 f0       	push   $0xf010723d
f010257c:	e8 bf da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102581:	83 ec 04             	sub    $0x4,%esp
f0102584:	6a 00                	push   $0x0
f0102586:	53                   	push   %ebx
f0102587:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f010258d:	e8 24 ea ff ff       	call   f0100fb6 <pgdir_walk>
f0102592:	8b 00                	mov    (%eax),%eax
f0102594:	83 c4 10             	add    $0x10,%esp
f0102597:	83 e0 04             	and    $0x4,%eax
f010259a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010259d:	74 19                	je     f01025b8 <mem_init+0x1298>
f010259f:	68 18 70 10 f0       	push   $0xf0107018
f01025a4:	68 7d 72 10 f0       	push   $0xf010727d
f01025a9:	68 63 04 00 00       	push   $0x463
f01025ae:	68 3d 72 10 f0       	push   $0xf010723d
f01025b3:	e8 88 da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01025b8:	83 ec 04             	sub    $0x4,%esp
f01025bb:	6a 00                	push   $0x0
f01025bd:	53                   	push   %ebx
f01025be:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f01025c4:	e8 ed e9 ff ff       	call   f0100fb6 <pgdir_walk>
f01025c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01025cf:	83 c4 0c             	add    $0xc,%esp
f01025d2:	6a 00                	push   $0x0
f01025d4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01025d7:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f01025dd:	e8 d4 e9 ff ff       	call   f0100fb6 <pgdir_walk>
f01025e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01025e8:	83 c4 0c             	add    $0xc,%esp
f01025eb:	6a 00                	push   $0x0
f01025ed:	56                   	push   %esi
f01025ee:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f01025f4:	e8 bd e9 ff ff       	call   f0100fb6 <pgdir_walk>
f01025f9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01025ff:	c7 04 24 20 75 10 f0 	movl   $0xf0107520,(%esp)
f0102606:	e8 46 10 00 00       	call   f0103651 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	uint32_t size = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f010260b:	a1 94 fe 29 f0       	mov    0xf029fe94,%eax
f0102610:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f0102617:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, size, PADDR(pages), PTE_U);
f010261d:	a1 9c fe 29 f0       	mov    0xf029fe9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102622:	83 c4 10             	add    $0x10,%esp
f0102625:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010262a:	77 15                	ja     f0102641 <mem_init+0x1321>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010262c:	50                   	push   %eax
f010262d:	68 68 63 10 f0       	push   $0xf0106368
f0102632:	68 bf 00 00 00       	push   $0xbf
f0102637:	68 3d 72 10 f0       	push   $0xf010723d
f010263c:	e8 ff d9 ff ff       	call   f0100040 <_panic>
f0102641:	83 ec 08             	sub    $0x8,%esp
f0102644:	6a 04                	push   $0x4
f0102646:	05 00 00 00 10       	add    $0x10000000,%eax
f010264b:	50                   	push   %eax
f010264c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102651:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f0102656:	e8 45 ea ff ff       	call   f01010a0 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	size = ROUNDUP(NENV * sizeof(struct Env), PGSIZE);
	boot_map_region(kern_pgdir, UENVS, size, PADDR(envs), PTE_U);
f010265b:	a1 48 f2 29 f0       	mov    0xf029f248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102660:	83 c4 10             	add    $0x10,%esp
f0102663:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102668:	77 15                	ja     f010267f <mem_init+0x135f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010266a:	50                   	push   %eax
f010266b:	68 68 63 10 f0       	push   $0xf0106368
f0102670:	68 ca 00 00 00       	push   $0xca
f0102675:	68 3d 72 10 f0       	push   $0xf010723d
f010267a:	e8 c1 d9 ff ff       	call   f0100040 <_panic>
f010267f:	83 ec 08             	sub    $0x8,%esp
f0102682:	6a 04                	push   $0x4
f0102684:	05 00 00 00 10       	add    $0x10000000,%eax
f0102689:	50                   	push   %eax
f010268a:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010268f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102694:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f0102699:	e8 02 ea ff ff       	call   f01010a0 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010269e:	83 c4 10             	add    $0x10,%esp
f01026a1:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f01026a6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026ab:	77 15                	ja     f01026c2 <mem_init+0x13a2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026ad:	50                   	push   %eax
f01026ae:	68 68 63 10 f0       	push   $0xf0106368
f01026b3:	68 d8 00 00 00       	push   $0xd8
f01026b8:	68 3d 72 10 f0       	push   $0xf010723d
f01026bd:	e8 7e d9 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	extern char bootstack[];
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01026c2:	83 ec 08             	sub    $0x8,%esp
f01026c5:	6a 02                	push   $0x2
f01026c7:	68 00 80 11 00       	push   $0x118000
f01026cc:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026d1:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01026d6:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f01026db:	e8 c0 e9 ff ff       	call   f01010a0 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	size = ((0xFFFFFFFF) - KERNBASE) + 1;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, PTE_W);
f01026e0:	83 c4 08             	add    $0x8,%esp
f01026e3:	6a 02                	push   $0x2
f01026e5:	6a 00                	push   $0x0
f01026e7:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026ec:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026f1:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f01026f6:	e8 a5 e9 ff ff       	call   f01010a0 <boot_map_region>
f01026fb:	c7 45 c4 00 10 2a f0 	movl   $0xf02a1000,-0x3c(%ebp)
f0102702:	83 c4 10             	add    $0x10,%esp
f0102705:	bb 00 10 2a f0       	mov    $0xf02a1000,%ebx
f010270a:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010270f:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102715:	77 15                	ja     f010272c <mem_init+0x140c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102717:	53                   	push   %ebx
f0102718:	68 68 63 10 f0       	push   $0xf0106368
f010271d:	68 1b 01 00 00       	push   $0x11b
f0102722:	68 3d 72 10 f0       	push   $0xf010723d
f0102727:	e8 14 d9 ff ff       	call   f0100040 <_panic>
	uint32_t i;
	for (i = 0; i < NCPU; i++) {
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		uintptr_t kstackbot_i = kstacktop_i - KSTKSIZE;
		physaddr_t kstackpa_i = PADDR(&percpu_kstacks[i]);
		boot_map_region(kern_pgdir, kstackbot_i, KSTKSIZE, kstackpa_i, PTE_W);
f010272c:	83 ec 08             	sub    $0x8,%esp
f010272f:	6a 02                	push   $0x2
f0102731:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102737:	50                   	push   %eax
f0102738:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010273d:	89 f2                	mov    %esi,%edx
f010273f:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
f0102744:	e8 57 e9 ff ff       	call   f01010a0 <boot_map_region>
f0102749:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010274f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uint32_t i;
	for (i = 0; i < NCPU; i++) {
f0102755:	83 c4 10             	add    $0x10,%esp
f0102758:	b8 00 10 2e f0       	mov    $0xf02e1000,%eax
f010275d:	39 d8                	cmp    %ebx,%eax
f010275f:	75 ae                	jne    f010270f <mem_init+0x13ef>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102761:	8b 3d 98 fe 29 f0    	mov    0xf029fe98,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102767:	a1 94 fe 29 f0       	mov    0xf029fe94,%eax
f010276c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010276f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102776:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010277b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010277e:	8b 35 9c fe 29 f0    	mov    0xf029fe9c,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102784:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102787:	bb 00 00 00 00       	mov    $0x0,%ebx
f010278c:	eb 55                	jmp    f01027e3 <mem_init+0x14c3>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010278e:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102794:	89 f8                	mov    %edi,%eax
f0102796:	e8 a7 e2 ff ff       	call   f0100a42 <check_va2pa>
f010279b:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01027a2:	77 15                	ja     f01027b9 <mem_init+0x1499>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027a4:	56                   	push   %esi
f01027a5:	68 68 63 10 f0       	push   $0xf0106368
f01027aa:	68 7b 03 00 00       	push   $0x37b
f01027af:	68 3d 72 10 f0       	push   $0xf010723d
f01027b4:	e8 87 d8 ff ff       	call   f0100040 <_panic>
f01027b9:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01027c0:	39 c2                	cmp    %eax,%edx
f01027c2:	74 19                	je     f01027dd <mem_init+0x14bd>
f01027c4:	68 4c 70 10 f0       	push   $0xf010704c
f01027c9:	68 7d 72 10 f0       	push   $0xf010727d
f01027ce:	68 7b 03 00 00       	push   $0x37b
f01027d3:	68 3d 72 10 f0       	push   $0xf010723d
f01027d8:	e8 63 d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027dd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027e3:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01027e6:	77 a6                	ja     f010278e <mem_init+0x146e>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027e8:	8b 35 48 f2 29 f0    	mov    0xf029f248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027ee:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01027f1:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01027f6:	89 da                	mov    %ebx,%edx
f01027f8:	89 f8                	mov    %edi,%eax
f01027fa:	e8 43 e2 ff ff       	call   f0100a42 <check_va2pa>
f01027ff:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102806:	77 15                	ja     f010281d <mem_init+0x14fd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102808:	56                   	push   %esi
f0102809:	68 68 63 10 f0       	push   $0xf0106368
f010280e:	68 80 03 00 00       	push   $0x380
f0102813:	68 3d 72 10 f0       	push   $0xf010723d
f0102818:	e8 23 d8 ff ff       	call   f0100040 <_panic>
f010281d:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102824:	39 d0                	cmp    %edx,%eax
f0102826:	74 19                	je     f0102841 <mem_init+0x1521>
f0102828:	68 80 70 10 f0       	push   $0xf0107080
f010282d:	68 7d 72 10 f0       	push   $0xf010727d
f0102832:	68 80 03 00 00       	push   $0x380
f0102837:	68 3d 72 10 f0       	push   $0xf010723d
f010283c:	e8 ff d7 ff ff       	call   f0100040 <_panic>
f0102841:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102847:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f010284d:	75 a7                	jne    f01027f6 <mem_init+0x14d6>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010284f:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102852:	c1 e6 0c             	shl    $0xc,%esi
f0102855:	bb 00 00 00 00       	mov    $0x0,%ebx
f010285a:	eb 30                	jmp    f010288c <mem_init+0x156c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010285c:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102862:	89 f8                	mov    %edi,%eax
f0102864:	e8 d9 e1 ff ff       	call   f0100a42 <check_va2pa>
f0102869:	39 c3                	cmp    %eax,%ebx
f010286b:	74 19                	je     f0102886 <mem_init+0x1566>
f010286d:	68 b4 70 10 f0       	push   $0xf01070b4
f0102872:	68 7d 72 10 f0       	push   $0xf010727d
f0102877:	68 84 03 00 00       	push   $0x384
f010287c:	68 3d 72 10 f0       	push   $0xf010723d
f0102881:	e8 ba d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102886:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010288c:	39 f3                	cmp    %esi,%ebx
f010288e:	72 cc                	jb     f010285c <mem_init+0x153c>
f0102890:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102895:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102898:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010289b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010289e:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01028a4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01028a7:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01028a9:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01028ac:	05 00 80 00 20       	add    $0x20008000,%eax
f01028b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028b4:	89 da                	mov    %ebx,%edx
f01028b6:	89 f8                	mov    %edi,%eax
f01028b8:	e8 85 e1 ff ff       	call   f0100a42 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028bd:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01028c3:	77 15                	ja     f01028da <mem_init+0x15ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028c5:	56                   	push   %esi
f01028c6:	68 68 63 10 f0       	push   $0xf0106368
f01028cb:	68 8c 03 00 00       	push   $0x38c
f01028d0:	68 3d 72 10 f0       	push   $0xf010723d
f01028d5:	e8 66 d7 ff ff       	call   f0100040 <_panic>
f01028da:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01028dd:	8d 94 0b 00 10 2a f0 	lea    -0xfd5f000(%ebx,%ecx,1),%edx
f01028e4:	39 d0                	cmp    %edx,%eax
f01028e6:	74 19                	je     f0102901 <mem_init+0x15e1>
f01028e8:	68 dc 70 10 f0       	push   $0xf01070dc
f01028ed:	68 7d 72 10 f0       	push   $0xf010727d
f01028f2:	68 8c 03 00 00       	push   $0x38c
f01028f7:	68 3d 72 10 f0       	push   $0xf010723d
f01028fc:	e8 3f d7 ff ff       	call   f0100040 <_panic>
f0102901:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102907:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f010290a:	75 a8                	jne    f01028b4 <mem_init+0x1594>
f010290c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010290f:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102915:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102918:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010291a:	89 da                	mov    %ebx,%edx
f010291c:	89 f8                	mov    %edi,%eax
f010291e:	e8 1f e1 ff ff       	call   f0100a42 <check_va2pa>
f0102923:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102926:	74 19                	je     f0102941 <mem_init+0x1621>
f0102928:	68 24 71 10 f0       	push   $0xf0107124
f010292d:	68 7d 72 10 f0       	push   $0xf010727d
f0102932:	68 8e 03 00 00       	push   $0x38e
f0102937:	68 3d 72 10 f0       	push   $0xf010723d
f010293c:	e8 ff d6 ff ff       	call   f0100040 <_panic>
f0102941:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102947:	39 de                	cmp    %ebx,%esi
f0102949:	75 cf                	jne    f010291a <mem_init+0x15fa>
f010294b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010294e:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102955:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f010295c:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102962:	81 fe 00 10 2e f0    	cmp    $0xf02e1000,%esi
f0102968:	0f 85 2d ff ff ff    	jne    f010289b <mem_init+0x157b>
f010296e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102973:	eb 2a                	jmp    f010299f <mem_init+0x167f>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102975:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010297b:	83 fa 04             	cmp    $0x4,%edx
f010297e:	77 1f                	ja     f010299f <mem_init+0x167f>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102980:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102984:	75 7e                	jne    f0102a04 <mem_init+0x16e4>
f0102986:	68 39 75 10 f0       	push   $0xf0107539
f010298b:	68 7d 72 10 f0       	push   $0xf010727d
f0102990:	68 99 03 00 00       	push   $0x399
f0102995:	68 3d 72 10 f0       	push   $0xf010723d
f010299a:	e8 a1 d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010299f:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01029a4:	76 3f                	jbe    f01029e5 <mem_init+0x16c5>
				assert(pgdir[i] & PTE_P);
f01029a6:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01029a9:	f6 c2 01             	test   $0x1,%dl
f01029ac:	75 19                	jne    f01029c7 <mem_init+0x16a7>
f01029ae:	68 39 75 10 f0       	push   $0xf0107539
f01029b3:	68 7d 72 10 f0       	push   $0xf010727d
f01029b8:	68 9d 03 00 00       	push   $0x39d
f01029bd:	68 3d 72 10 f0       	push   $0xf010723d
f01029c2:	e8 79 d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01029c7:	f6 c2 02             	test   $0x2,%dl
f01029ca:	75 38                	jne    f0102a04 <mem_init+0x16e4>
f01029cc:	68 4a 75 10 f0       	push   $0xf010754a
f01029d1:	68 7d 72 10 f0       	push   $0xf010727d
f01029d6:	68 9e 03 00 00       	push   $0x39e
f01029db:	68 3d 72 10 f0       	push   $0xf010723d
f01029e0:	e8 5b d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029e5:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01029e9:	74 19                	je     f0102a04 <mem_init+0x16e4>
f01029eb:	68 5b 75 10 f0       	push   $0xf010755b
f01029f0:	68 7d 72 10 f0       	push   $0xf010727d
f01029f5:	68 a0 03 00 00       	push   $0x3a0
f01029fa:	68 3d 72 10 f0       	push   $0xf010723d
f01029ff:	e8 3c d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102a04:	83 c0 01             	add    $0x1,%eax
f0102a07:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a0c:	0f 86 63 ff ff ff    	jbe    f0102975 <mem_init+0x1655>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a12:	83 ec 0c             	sub    $0xc,%esp
f0102a15:	68 48 71 10 f0       	push   $0xf0107148
f0102a1a:	e8 32 0c 00 00       	call   f0103651 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a1f:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a24:	83 c4 10             	add    $0x10,%esp
f0102a27:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a2c:	77 15                	ja     f0102a43 <mem_init+0x1723>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a2e:	50                   	push   %eax
f0102a2f:	68 68 63 10 f0       	push   $0xf0106368
f0102a34:	68 f2 00 00 00       	push   $0xf2
f0102a39:	68 3d 72 10 f0       	push   $0xf010723d
f0102a3e:	e8 fd d5 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102a43:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a48:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a50:	e8 d5 e0 ff ff       	call   f0100b2a <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a55:	0f 20 c0             	mov    %cr0,%eax
f0102a58:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a5b:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102a60:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a63:	83 ec 0c             	sub    $0xc,%esp
f0102a66:	6a 00                	push   $0x0
f0102a68:	e8 77 e4 ff ff       	call   f0100ee4 <page_alloc>
f0102a6d:	89 c3                	mov    %eax,%ebx
f0102a6f:	83 c4 10             	add    $0x10,%esp
f0102a72:	85 c0                	test   %eax,%eax
f0102a74:	75 19                	jne    f0102a8f <mem_init+0x176f>
f0102a76:	68 45 73 10 f0       	push   $0xf0107345
f0102a7b:	68 7d 72 10 f0       	push   $0xf010727d
f0102a80:	68 78 04 00 00       	push   $0x478
f0102a85:	68 3d 72 10 f0       	push   $0xf010723d
f0102a8a:	e8 b1 d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a8f:	83 ec 0c             	sub    $0xc,%esp
f0102a92:	6a 00                	push   $0x0
f0102a94:	e8 4b e4 ff ff       	call   f0100ee4 <page_alloc>
f0102a99:	89 c7                	mov    %eax,%edi
f0102a9b:	83 c4 10             	add    $0x10,%esp
f0102a9e:	85 c0                	test   %eax,%eax
f0102aa0:	75 19                	jne    f0102abb <mem_init+0x179b>
f0102aa2:	68 5b 73 10 f0       	push   $0xf010735b
f0102aa7:	68 7d 72 10 f0       	push   $0xf010727d
f0102aac:	68 79 04 00 00       	push   $0x479
f0102ab1:	68 3d 72 10 f0       	push   $0xf010723d
f0102ab6:	e8 85 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102abb:	83 ec 0c             	sub    $0xc,%esp
f0102abe:	6a 00                	push   $0x0
f0102ac0:	e8 1f e4 ff ff       	call   f0100ee4 <page_alloc>
f0102ac5:	89 c6                	mov    %eax,%esi
f0102ac7:	83 c4 10             	add    $0x10,%esp
f0102aca:	85 c0                	test   %eax,%eax
f0102acc:	75 19                	jne    f0102ae7 <mem_init+0x17c7>
f0102ace:	68 71 73 10 f0       	push   $0xf0107371
f0102ad3:	68 7d 72 10 f0       	push   $0xf010727d
f0102ad8:	68 7a 04 00 00       	push   $0x47a
f0102add:	68 3d 72 10 f0       	push   $0xf010723d
f0102ae2:	e8 59 d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102ae7:	83 ec 0c             	sub    $0xc,%esp
f0102aea:	53                   	push   %ebx
f0102aeb:	e8 64 e4 ff ff       	call   f0100f54 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102af0:	89 f8                	mov    %edi,%eax
f0102af2:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0102af8:	c1 f8 03             	sar    $0x3,%eax
f0102afb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102afe:	89 c2                	mov    %eax,%edx
f0102b00:	c1 ea 0c             	shr    $0xc,%edx
f0102b03:	83 c4 10             	add    $0x10,%esp
f0102b06:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f0102b0c:	72 12                	jb     f0102b20 <mem_init+0x1800>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b0e:	50                   	push   %eax
f0102b0f:	68 44 63 10 f0       	push   $0xf0106344
f0102b14:	6a 58                	push   $0x58
f0102b16:	68 63 72 10 f0       	push   $0xf0107263
f0102b1b:	e8 20 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b20:	83 ec 04             	sub    $0x4,%esp
f0102b23:	68 00 10 00 00       	push   $0x1000
f0102b28:	6a 01                	push   $0x1
f0102b2a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b2f:	50                   	push   %eax
f0102b30:	e8 c2 25 00 00       	call   f01050f7 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b35:	89 f0                	mov    %esi,%eax
f0102b37:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0102b3d:	c1 f8 03             	sar    $0x3,%eax
f0102b40:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b43:	89 c2                	mov    %eax,%edx
f0102b45:	c1 ea 0c             	shr    $0xc,%edx
f0102b48:	83 c4 10             	add    $0x10,%esp
f0102b4b:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f0102b51:	72 12                	jb     f0102b65 <mem_init+0x1845>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b53:	50                   	push   %eax
f0102b54:	68 44 63 10 f0       	push   $0xf0106344
f0102b59:	6a 58                	push   $0x58
f0102b5b:	68 63 72 10 f0       	push   $0xf0107263
f0102b60:	e8 db d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b65:	83 ec 04             	sub    $0x4,%esp
f0102b68:	68 00 10 00 00       	push   $0x1000
f0102b6d:	6a 02                	push   $0x2
f0102b6f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b74:	50                   	push   %eax
f0102b75:	e8 7d 25 00 00       	call   f01050f7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b7a:	6a 02                	push   $0x2
f0102b7c:	68 00 10 00 00       	push   $0x1000
f0102b81:	57                   	push   %edi
f0102b82:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0102b88:	e8 95 e6 ff ff       	call   f0101222 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b8d:	83 c4 20             	add    $0x20,%esp
f0102b90:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b95:	74 19                	je     f0102bb0 <mem_init+0x1890>
f0102b97:	68 42 74 10 f0       	push   $0xf0107442
f0102b9c:	68 7d 72 10 f0       	push   $0xf010727d
f0102ba1:	68 7f 04 00 00       	push   $0x47f
f0102ba6:	68 3d 72 10 f0       	push   $0xf010723d
f0102bab:	e8 90 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bb0:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bb7:	01 01 01 
f0102bba:	74 19                	je     f0102bd5 <mem_init+0x18b5>
f0102bbc:	68 68 71 10 f0       	push   $0xf0107168
f0102bc1:	68 7d 72 10 f0       	push   $0xf010727d
f0102bc6:	68 80 04 00 00       	push   $0x480
f0102bcb:	68 3d 72 10 f0       	push   $0xf010723d
f0102bd0:	e8 6b d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bd5:	6a 02                	push   $0x2
f0102bd7:	68 00 10 00 00       	push   $0x1000
f0102bdc:	56                   	push   %esi
f0102bdd:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0102be3:	e8 3a e6 ff ff       	call   f0101222 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102be8:	83 c4 10             	add    $0x10,%esp
f0102beb:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102bf2:	02 02 02 
f0102bf5:	74 19                	je     f0102c10 <mem_init+0x18f0>
f0102bf7:	68 8c 71 10 f0       	push   $0xf010718c
f0102bfc:	68 7d 72 10 f0       	push   $0xf010727d
f0102c01:	68 82 04 00 00       	push   $0x482
f0102c06:	68 3d 72 10 f0       	push   $0xf010723d
f0102c0b:	e8 30 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102c10:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c15:	74 19                	je     f0102c30 <mem_init+0x1910>
f0102c17:	68 64 74 10 f0       	push   $0xf0107464
f0102c1c:	68 7d 72 10 f0       	push   $0xf010727d
f0102c21:	68 83 04 00 00       	push   $0x483
f0102c26:	68 3d 72 10 f0       	push   $0xf010723d
f0102c2b:	e8 10 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c30:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c35:	74 19                	je     f0102c50 <mem_init+0x1930>
f0102c37:	68 ce 74 10 f0       	push   $0xf01074ce
f0102c3c:	68 7d 72 10 f0       	push   $0xf010727d
f0102c41:	68 84 04 00 00       	push   $0x484
f0102c46:	68 3d 72 10 f0       	push   $0xf010723d
f0102c4b:	e8 f0 d3 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c50:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c57:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c5a:	89 f0                	mov    %esi,%eax
f0102c5c:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0102c62:	c1 f8 03             	sar    $0x3,%eax
f0102c65:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c68:	89 c2                	mov    %eax,%edx
f0102c6a:	c1 ea 0c             	shr    $0xc,%edx
f0102c6d:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f0102c73:	72 12                	jb     f0102c87 <mem_init+0x1967>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c75:	50                   	push   %eax
f0102c76:	68 44 63 10 f0       	push   $0xf0106344
f0102c7b:	6a 58                	push   $0x58
f0102c7d:	68 63 72 10 f0       	push   $0xf0107263
f0102c82:	e8 b9 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c87:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c8e:	03 03 03 
f0102c91:	74 19                	je     f0102cac <mem_init+0x198c>
f0102c93:	68 b0 71 10 f0       	push   $0xf01071b0
f0102c98:	68 7d 72 10 f0       	push   $0xf010727d
f0102c9d:	68 86 04 00 00       	push   $0x486
f0102ca2:	68 3d 72 10 f0       	push   $0xf010723d
f0102ca7:	e8 94 d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cac:	83 ec 08             	sub    $0x8,%esp
f0102caf:	68 00 10 00 00       	push   $0x1000
f0102cb4:	ff 35 98 fe 29 f0    	pushl  0xf029fe98
f0102cba:	e8 1d e5 ff ff       	call   f01011dc <page_remove>
	assert(pp2->pp_ref == 0);
f0102cbf:	83 c4 10             	add    $0x10,%esp
f0102cc2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102cc7:	74 19                	je     f0102ce2 <mem_init+0x19c2>
f0102cc9:	68 9c 74 10 f0       	push   $0xf010749c
f0102cce:	68 7d 72 10 f0       	push   $0xf010727d
f0102cd3:	68 88 04 00 00       	push   $0x488
f0102cd8:	68 3d 72 10 f0       	push   $0xf010723d
f0102cdd:	e8 5e d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ce2:	8b 0d 98 fe 29 f0    	mov    0xf029fe98,%ecx
f0102ce8:	8b 11                	mov    (%ecx),%edx
f0102cea:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102cf0:	89 d8                	mov    %ebx,%eax
f0102cf2:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0102cf8:	c1 f8 03             	sar    $0x3,%eax
f0102cfb:	c1 e0 0c             	shl    $0xc,%eax
f0102cfe:	39 c2                	cmp    %eax,%edx
f0102d00:	74 19                	je     f0102d1b <mem_init+0x19fb>
f0102d02:	68 38 6b 10 f0       	push   $0xf0106b38
f0102d07:	68 7d 72 10 f0       	push   $0xf010727d
f0102d0c:	68 8b 04 00 00       	push   $0x48b
f0102d11:	68 3d 72 10 f0       	push   $0xf010723d
f0102d16:	e8 25 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d1b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d21:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d26:	74 19                	je     f0102d41 <mem_init+0x1a21>
f0102d28:	68 53 74 10 f0       	push   $0xf0107453
f0102d2d:	68 7d 72 10 f0       	push   $0xf010727d
f0102d32:	68 8d 04 00 00       	push   $0x48d
f0102d37:	68 3d 72 10 f0       	push   $0xf010723d
f0102d3c:	e8 ff d2 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d41:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d47:	83 ec 0c             	sub    $0xc,%esp
f0102d4a:	53                   	push   %ebx
f0102d4b:	e8 04 e2 ff ff       	call   f0100f54 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d50:	c7 04 24 dc 71 10 f0 	movl   $0xf01071dc,(%esp)
f0102d57:	e8 f5 08 00 00       	call   f0103651 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d5c:	83 c4 10             	add    $0x10,%esp
f0102d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d62:	5b                   	pop    %ebx
f0102d63:	5e                   	pop    %esi
f0102d64:	5f                   	pop    %edi
f0102d65:	5d                   	pop    %ebp
f0102d66:	c3                   	ret    

f0102d67 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d67:	55                   	push   %ebp
f0102d68:	89 e5                	mov    %esp,%ebp
f0102d6a:	57                   	push   %edi
f0102d6b:	56                   	push   %esi
f0102d6c:	53                   	push   %ebx
f0102d6d:	83 ec 1c             	sub    $0x1c,%esp
f0102d70:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
f0102d73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d76:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t last = ROUNDDOWN((uint32_t) (va+len), PGSIZE);
f0102d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d7f:	03 45 10             	add    0x10(%ebp),%eax
f0102d82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			}
			return -E_FAULT;
		}
		// Second check
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *) addr, 0);
		if (!pte || !(*pte & (perm | PTE_P))) {
f0102d8a:	8b 75 14             	mov    0x14(%ebp),%esi
f0102d8d:	83 ce 01             	or     $0x1,%esi
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
	uint32_t last = ROUNDDOWN((uint32_t) (va+len), PGSIZE);
	while (addr <= last) {
f0102d90:	eb 69                	jmp    f0102dfb <user_mem_check+0x94>
		// TODO: Avoid repeating block of code
		// First check
		if (addr >= ULIM) {
f0102d92:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d98:	76 21                	jbe    f0102dbb <user_mem_check+0x54>
			if (addr < (uint32_t) va) {
f0102d9a:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102d9d:	73 0f                	jae    f0102dae <user_mem_check+0x47>
				user_mem_check_addr = (uint32_t) va;
f0102d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102da2:	a3 3c f2 29 f0       	mov    %eax,0xf029f23c
			} else {
				user_mem_check_addr = addr;
			}
			return -E_FAULT;
f0102da7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102dac:	eb 57                	jmp    f0102e05 <user_mem_check+0x9e>
		// First check
		if (addr >= ULIM) {
			if (addr < (uint32_t) va) {
				user_mem_check_addr = (uint32_t) va;
			} else {
				user_mem_check_addr = addr;
f0102dae:	89 1d 3c f2 29 f0    	mov    %ebx,0xf029f23c
			}
			return -E_FAULT;
f0102db4:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102db9:	eb 4a                	jmp    f0102e05 <user_mem_check+0x9e>
		}
		// Second check
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *) addr, 0);
f0102dbb:	83 ec 04             	sub    $0x4,%esp
f0102dbe:	6a 00                	push   $0x0
f0102dc0:	53                   	push   %ebx
f0102dc1:	ff 77 60             	pushl  0x60(%edi)
f0102dc4:	e8 ed e1 ff ff       	call   f0100fb6 <pgdir_walk>
		if (!pte || !(*pte & (perm | PTE_P))) {
f0102dc9:	83 c4 10             	add    $0x10,%esp
f0102dcc:	85 c0                	test   %eax,%eax
f0102dce:	74 04                	je     f0102dd4 <user_mem_check+0x6d>
f0102dd0:	85 30                	test   %esi,(%eax)
f0102dd2:	75 21                	jne    f0102df5 <user_mem_check+0x8e>
			if (addr < (uint32_t) va) {
f0102dd4:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102dd7:	73 0f                	jae    f0102de8 <user_mem_check+0x81>
				user_mem_check_addr = (uint32_t) va;
f0102dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ddc:	a3 3c f2 29 f0       	mov    %eax,0xf029f23c
			} else {
				user_mem_check_addr = addr;
			}
			return -E_FAULT;
f0102de1:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102de6:	eb 1d                	jmp    f0102e05 <user_mem_check+0x9e>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *) addr, 0);
		if (!pte || !(*pte & (perm | PTE_P))) {
			if (addr < (uint32_t) va) {
				user_mem_check_addr = (uint32_t) va;
			} else {
				user_mem_check_addr = addr;
f0102de8:	89 1d 3c f2 29 f0    	mov    %ebx,0xf029f23c
			}
			return -E_FAULT;
f0102dee:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102df3:	eb 10                	jmp    f0102e05 <user_mem_check+0x9e>
		}
		addr += PGSIZE;
f0102df5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
	uint32_t last = ROUNDDOWN((uint32_t) (va+len), PGSIZE);
	while (addr <= last) {
f0102dfb:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102dfe:	76 92                	jbe    f0102d92 <user_mem_check+0x2b>
			return -E_FAULT;
		}
		addr += PGSIZE;

	}
	return 0;
f0102e00:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e05:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e08:	5b                   	pop    %ebx
f0102e09:	5e                   	pop    %esi
f0102e0a:	5f                   	pop    %edi
f0102e0b:	5d                   	pop    %ebp
f0102e0c:	c3                   	ret    

f0102e0d <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e0d:	55                   	push   %ebp
f0102e0e:	89 e5                	mov    %esp,%ebp
f0102e10:	53                   	push   %ebx
f0102e11:	83 ec 04             	sub    $0x4,%esp
f0102e14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e17:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e1a:	83 c8 04             	or     $0x4,%eax
f0102e1d:	50                   	push   %eax
f0102e1e:	ff 75 10             	pushl  0x10(%ebp)
f0102e21:	ff 75 0c             	pushl  0xc(%ebp)
f0102e24:	53                   	push   %ebx
f0102e25:	e8 3d ff ff ff       	call   f0102d67 <user_mem_check>
f0102e2a:	83 c4 10             	add    $0x10,%esp
f0102e2d:	85 c0                	test   %eax,%eax
f0102e2f:	79 21                	jns    f0102e52 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e31:	83 ec 04             	sub    $0x4,%esp
f0102e34:	ff 35 3c f2 29 f0    	pushl  0xf029f23c
f0102e3a:	ff 73 48             	pushl  0x48(%ebx)
f0102e3d:	68 08 72 10 f0       	push   $0xf0107208
f0102e42:	e8 0a 08 00 00       	call   f0103651 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e47:	89 1c 24             	mov    %ebx,(%esp)
f0102e4a:	e8 33 05 00 00       	call   f0103382 <env_destroy>
f0102e4f:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e55:	c9                   	leave  
f0102e56:	c3                   	ret    

f0102e57 <region_alloc>:
// Panic if any allocation attempt fails.
//
/** ATTENTION: This function does not cover the case where there are overlaps! **/
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102e57:	55                   	push   %ebp
f0102e58:	89 e5                	mov    %esp,%ebp
f0102e5a:	57                   	push   %edi
f0102e5b:	56                   	push   %esi
f0102e5c:	53                   	push   %ebx
f0102e5d:	83 ec 1c             	sub    $0x1c,%esp
f0102e60:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102e62:	89 d6                	mov    %edx,%esi
f0102e64:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	uintptr_t va_end = ROUNDUP(((uintptr_t) va) + len, PGSIZE);
f0102e6a:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax

	uint32_t n = (va_end - va_start)/PGSIZE;
f0102e71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e76:	29 f0                	sub    %esi,%eax
f0102e78:	c1 e8 0c             	shr    $0xc,%eax
f0102e7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	uint32_t va_current = va_start;
	for (i = 0; i < n; i++) {
f0102e7e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e83:	eb 22                	jmp    f0102ea7 <region_alloc+0x50>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // Clear page
f0102e85:	83 ec 0c             	sub    $0xc,%esp
f0102e88:	6a 01                	push   $0x1
f0102e8a:	e8 55 e0 ff ff       	call   f0100ee4 <page_alloc>
		page_insert(e->env_pgdir, pp, (void *) va_current, PTE_U | PTE_W);
f0102e8f:	6a 06                	push   $0x6
f0102e91:	56                   	push   %esi
f0102e92:	50                   	push   %eax
f0102e93:	ff 77 60             	pushl  0x60(%edi)
f0102e96:	e8 87 e3 ff ff       	call   f0101222 <page_insert>
		va_current += PGSIZE;
f0102e9b:	81 c6 00 10 00 00    	add    $0x1000,%esi
	uintptr_t va_end = ROUNDUP(((uintptr_t) va) + len, PGSIZE);

	uint32_t n = (va_end - va_start)/PGSIZE;
	uint32_t i;
	uint32_t va_current = va_start;
	for (i = 0; i < n; i++) {
f0102ea1:	83 c3 01             	add    $0x1,%ebx
f0102ea4:	83 c4 20             	add    $0x20,%esp
f0102ea7:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102eaa:	75 d9                	jne    f0102e85 <region_alloc+0x2e>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // Clear page
		page_insert(e->env_pgdir, pp, (void *) va_current, PTE_U | PTE_W);
		va_current += PGSIZE;
	}
}
f0102eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102eaf:	5b                   	pop    %ebx
f0102eb0:	5e                   	pop    %esi
f0102eb1:	5f                   	pop    %edi
f0102eb2:	5d                   	pop    %ebp
f0102eb3:	c3                   	ret    

f0102eb4 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102eb4:	55                   	push   %ebp
f0102eb5:	89 e5                	mov    %esp,%ebp
f0102eb7:	56                   	push   %esi
f0102eb8:	53                   	push   %ebx
f0102eb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ebc:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102ebf:	85 c0                	test   %eax,%eax
f0102ec1:	75 1a                	jne    f0102edd <envid2env+0x29>
		*env_store = curenv;
f0102ec3:	e8 52 28 00 00       	call   f010571a <cpunum>
f0102ec8:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ecb:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0102ed1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102ed4:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102ed6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102edb:	eb 70                	jmp    f0102f4d <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102edd:	89 c3                	mov    %eax,%ebx
f0102edf:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102ee5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102ee8:	03 1d 48 f2 29 f0    	add    0xf029f248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102eee:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102ef2:	74 05                	je     f0102ef9 <envid2env+0x45>
f0102ef4:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102ef7:	74 10                	je     f0102f09 <envid2env+0x55>
		*env_store = 0;
f0102ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102efc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f02:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f07:	eb 44                	jmp    f0102f4d <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102f09:	84 d2                	test   %dl,%dl
f0102f0b:	74 36                	je     f0102f43 <envid2env+0x8f>
f0102f0d:	e8 08 28 00 00       	call   f010571a <cpunum>
f0102f12:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f15:	3b 98 28 00 2a f0    	cmp    -0xfd5ffd8(%eax),%ebx
f0102f1b:	74 26                	je     f0102f43 <envid2env+0x8f>
f0102f1d:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f20:	e8 f5 27 00 00       	call   f010571a <cpunum>
f0102f25:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f28:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0102f2e:	3b 70 48             	cmp    0x48(%eax),%esi
f0102f31:	74 10                	je     f0102f43 <envid2env+0x8f>
		*env_store = 0;
f0102f33:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f36:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f3c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f41:	eb 0a                	jmp    f0102f4d <envid2env+0x99>
	}

	*env_store = e;
f0102f43:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f46:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f48:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f4d:	5b                   	pop    %ebx
f0102f4e:	5e                   	pop    %esi
f0102f4f:	5d                   	pop    %ebp
f0102f50:	c3                   	ret    

f0102f51 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f51:	55                   	push   %ebp
f0102f52:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102f54:	b8 20 23 12 f0       	mov    $0xf0122320,%eax
f0102f59:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102f5c:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f61:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102f63:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102f65:	b8 10 00 00 00       	mov    $0x10,%eax
f0102f6a:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102f6c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102f6e:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f70:	ea 77 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f77
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f77:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f7c:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f7f:	5d                   	pop    %ebp
f0102f80:	c3                   	ret    

f0102f81 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f81:	55                   	push   %ebp
f0102f82:	89 e5                	mov    %esp,%ebp
f0102f84:	56                   	push   %esi
f0102f85:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1; i >= 0; i--) {
		envs[i].env_id = 0;
f0102f86:	8b 35 48 f2 29 f0    	mov    0xf029f248,%esi
f0102f8c:	8b 15 4c f2 29 f0    	mov    0xf029f24c,%edx
f0102f92:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f98:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f9b:	89 c1                	mov    %eax,%ecx
f0102f9d:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)

		envs[i].env_link = env_free_list;
f0102fa4:	89 50 44             	mov    %edx,0x44(%eax)
		env_free_list = &envs[i];

		envs[i].env_pgdir = NULL;
f0102fa7:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
f0102fae:	83 e8 7c             	sub    $0x7c,%eax
	int i;
	for (i = NENV-1; i >= 0; i--) {
		envs[i].env_id = 0;

		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0102fb1:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1; i >= 0; i--) {
f0102fb3:	39 d8                	cmp    %ebx,%eax
f0102fb5:	75 e4                	jne    f0102f9b <env_init+0x1a>
f0102fb7:	89 35 4c f2 29 f0    	mov    %esi,0xf029f24c
		env_free_list = &envs[i];

		envs[i].env_pgdir = NULL;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102fbd:	e8 8f ff ff ff       	call   f0102f51 <env_init_percpu>
}
f0102fc2:	5b                   	pop    %ebx
f0102fc3:	5e                   	pop    %esi
f0102fc4:	5d                   	pop    %ebp
f0102fc5:	c3                   	ret    

f0102fc6 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102fc6:	55                   	push   %ebp
f0102fc7:	89 e5                	mov    %esp,%ebp
f0102fc9:	53                   	push   %ebx
f0102fca:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102fcd:	8b 1d 4c f2 29 f0    	mov    0xf029f24c,%ebx
f0102fd3:	85 db                	test   %ebx,%ebx
f0102fd5:	0f 84 34 01 00 00    	je     f010310f <env_alloc+0x149>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102fdb:	83 ec 0c             	sub    $0xc,%esp
f0102fde:	6a 01                	push   $0x1
f0102fe0:	e8 ff de ff ff       	call   f0100ee4 <page_alloc>
f0102fe5:	83 c4 10             	add    $0x10,%esp
f0102fe8:	85 c0                	test   %eax,%eax
f0102fea:	0f 84 26 01 00 00    	je     f0103116 <env_alloc+0x150>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref += 1; // TODO: Why?
f0102ff0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ff5:	2b 05 9c fe 29 f0    	sub    0xf029fe9c,%eax
f0102ffb:	c1 f8 03             	sar    $0x3,%eax
f0102ffe:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103001:	89 c2                	mov    %eax,%edx
f0103003:	c1 ea 0c             	shr    $0xc,%edx
f0103006:	3b 15 94 fe 29 f0    	cmp    0xf029fe94,%edx
f010300c:	72 12                	jb     f0103020 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010300e:	50                   	push   %eax
f010300f:	68 44 63 10 f0       	push   $0xf0106344
f0103014:	6a 58                	push   $0x58
f0103016:	68 63 72 10 f0       	push   $0xf0107263
f010301b:	e8 20 d0 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = page2kva(p);
f0103020:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103025:	89 43 60             	mov    %eax,0x60(%ebx)
f0103028:	b8 ec 0e 00 00       	mov    $0xeec,%eax

	// Needs to map everything above UTOP: pages, envs, kernel stack
	// and all physical memory
	// More elegant way: just copy. Less elegant: map with boot_map_region...
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f010302d:	8b 15 98 fe 29 f0    	mov    0xf029fe98,%edx
f0103033:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103036:	8b 53 60             	mov    0x60(%ebx),%edx
f0103039:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010303c:	83 c0 04             	add    $0x4,%eax
	e->env_pgdir = page2kva(p);

	// Needs to map everything above UTOP: pages, envs, kernel stack
	// and all physical memory
	// More elegant way: just copy. Less elegant: map with boot_map_region...
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
f010303f:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103044:	75 e7                	jne    f010302d <env_alloc+0x67>
		e->env_pgdir[i] = kern_pgdir[i];
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103046:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103049:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010304e:	77 15                	ja     f0103065 <env_alloc+0x9f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103050:	50                   	push   %eax
f0103051:	68 68 63 10 f0       	push   $0xf0106368
f0103056:	68 cd 00 00 00       	push   $0xcd
f010305b:	68 69 75 10 f0       	push   $0xf0107569
f0103060:	e8 db cf ff ff       	call   f0100040 <_panic>
f0103065:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010306b:	83 ca 05             	or     $0x5,%edx
f010306e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103074:	8b 43 48             	mov    0x48(%ebx),%eax
f0103077:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010307c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103081:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103086:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103089:	89 da                	mov    %ebx,%edx
f010308b:	2b 15 48 f2 29 f0    	sub    0xf029f248,%edx
f0103091:	c1 fa 02             	sar    $0x2,%edx
f0103094:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010309a:	09 d0                	or     %edx,%eax
f010309c:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f010309f:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030a2:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01030a5:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01030ac:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01030b3:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030ba:	83 ec 04             	sub    $0x4,%esp
f01030bd:	6a 44                	push   $0x44
f01030bf:	6a 00                	push   $0x0
f01030c1:	53                   	push   %ebx
f01030c2:	e8 30 20 00 00       	call   f01050f7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030c7:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01030cd:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01030d3:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01030d9:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01030e0:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01030e6:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01030ed:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01030f4:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01030f8:	8b 43 44             	mov    0x44(%ebx),%eax
f01030fb:	a3 4c f2 29 f0       	mov    %eax,0xf029f24c
	*newenv_store = e;
f0103100:	8b 45 08             	mov    0x8(%ebp),%eax
f0103103:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0103105:	83 c4 10             	add    $0x10,%esp
f0103108:	b8 00 00 00 00       	mov    $0x0,%eax
f010310d:	eb 0c                	jmp    f010311b <env_alloc+0x155>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010310f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103114:	eb 05                	jmp    f010311b <env_alloc+0x155>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103116:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010311b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010311e:	c9                   	leave  
f010311f:	c3                   	ret    

f0103120 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103120:	55                   	push   %ebp
f0103121:	89 e5                	mov    %esp,%ebp
f0103123:	57                   	push   %edi
f0103124:	56                   	push   %esi
f0103125:	53                   	push   %ebx
f0103126:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *e;
	env_alloc(&e, 0);
f0103129:	6a 00                	push   $0x0
f010312b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010312e:	50                   	push   %eax
f010312f:	e8 92 fe ff ff       	call   f0102fc6 <env_alloc>
	load_icode(e, binary);
f0103134:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *) binary;
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff);
f0103137:	8b 45 08             	mov    0x8(%ebp),%eax
f010313a:	89 c3                	mov    %eax,%ebx
f010313c:	03 58 1c             	add    0x1c(%eax),%ebx
	struct Proghdr *last_ph = ph + elf->e_phnum;
f010313f:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f0103143:	c1 e6 05             	shl    $0x5,%esi
f0103146:	01 de                	add    %ebx,%esi
f0103148:	83 c4 10             	add    $0x10,%esp
f010314b:	eb 54                	jmp    f01031a1 <env_create+0x81>
	for (; ph < last_ph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
f010314d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103150:	75 4c                	jne    f010319e <env_create+0x7e>
			region_alloc(e, (uint8_t *) ph->p_va, ph->p_memsz);
f0103152:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103155:	8b 53 08             	mov    0x8(%ebx),%edx
f0103158:	89 f8                	mov    %edi,%eax
f010315a:	e8 f8 fc ff ff       	call   f0102e57 <region_alloc>

			lcr3(PADDR(e->env_pgdir));
f010315f:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103162:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103167:	77 15                	ja     f010317e <env_create+0x5e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103169:	50                   	push   %eax
f010316a:	68 68 63 10 f0       	push   $0xf0106368
f010316f:	68 77 01 00 00       	push   $0x177
f0103174:	68 69 75 10 f0       	push   $0xf0107569
f0103179:	e8 c2 ce ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010317e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103183:	0f 22 d8             	mov    %eax,%cr3

			uint8_t *dst = (uint8_t *) ph->p_va;
			uint8_t *src = binary + ph->p_offset;
			size_t n = (size_t) ph->p_filesz;

			memmove(dst, src, n);
f0103186:	83 ec 04             	sub    $0x4,%esp
f0103189:	ff 73 10             	pushl  0x10(%ebx)
f010318c:	8b 45 08             	mov    0x8(%ebp),%eax
f010318f:	03 43 04             	add    0x4(%ebx),%eax
f0103192:	50                   	push   %eax
f0103193:	ff 73 08             	pushl  0x8(%ebx)
f0103196:	e8 a9 1f 00 00       	call   f0105144 <memmove>
f010319b:	83 c4 10             	add    $0x10,%esp

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *) binary;
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff);
	struct Proghdr *last_ph = ph + elf->e_phnum;
	for (; ph < last_ph; ph++) {
f010319e:	83 c3 20             	add    $0x20,%ebx
f01031a1:	39 de                	cmp    %ebx,%esi
f01031a3:	77 a8                	ja     f010314d <env_create+0x2d>
			memmove(dst, src, n);
		}
	}

	// Put the program entry point in the trapframe
	e->env_tf.tf_eip = elf->e_entry;
f01031a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01031a8:	8b 40 18             	mov    0x18(%eax),%eax
f01031ab:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01031ae:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01031b3:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01031b8:	89 f8                	mov    %edi,%eax
f01031ba:	e8 98 fc ff ff       	call   f0102e57 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *e;
	env_alloc(&e, 0);
	load_icode(e, binary);
	e->env_type = type;
f01031bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031c2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01031c5:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.


	if (type == ENV_TYPE_FS) {
f01031c8:	83 fa 01             	cmp    $0x1,%edx
f01031cb:	75 07                	jne    f01031d4 <env_create+0xb4>
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
f01031cd:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
}
f01031d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031d7:	5b                   	pop    %ebx
f01031d8:	5e                   	pop    %esi
f01031d9:	5f                   	pop    %edi
f01031da:	5d                   	pop    %ebp
f01031db:	c3                   	ret    

f01031dc <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01031dc:	55                   	push   %ebp
f01031dd:	89 e5                	mov    %esp,%ebp
f01031df:	57                   	push   %edi
f01031e0:	56                   	push   %esi
f01031e1:	53                   	push   %ebx
f01031e2:	83 ec 1c             	sub    $0x1c,%esp
f01031e5:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01031e8:	e8 2d 25 00 00       	call   f010571a <cpunum>
f01031ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01031f0:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01031f7:	39 b8 28 00 2a f0    	cmp    %edi,-0xfd5ffd8(%eax)
f01031fd:	75 30                	jne    f010322f <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01031ff:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103204:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103209:	77 15                	ja     f0103220 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010320b:	50                   	push   %eax
f010320c:	68 68 63 10 f0       	push   $0xf0106368
f0103211:	68 b2 01 00 00       	push   $0x1b2
f0103216:	68 69 75 10 f0       	push   $0xf0107569
f010321b:	e8 20 ce ff ff       	call   f0100040 <_panic>
f0103220:	05 00 00 00 10       	add    $0x10000000,%eax
f0103225:	0f 22 d8             	mov    %eax,%cr3
f0103228:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010322f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103232:	89 d0                	mov    %edx,%eax
f0103234:	c1 e0 02             	shl    $0x2,%eax
f0103237:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010323a:	8b 47 60             	mov    0x60(%edi),%eax
f010323d:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103240:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103246:	0f 84 a8 00 00 00    	je     f01032f4 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010324c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103252:	89 f0                	mov    %esi,%eax
f0103254:	c1 e8 0c             	shr    $0xc,%eax
f0103257:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010325a:	39 05 94 fe 29 f0    	cmp    %eax,0xf029fe94
f0103260:	77 15                	ja     f0103277 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103262:	56                   	push   %esi
f0103263:	68 44 63 10 f0       	push   $0xf0106344
f0103268:	68 c1 01 00 00       	push   $0x1c1
f010326d:	68 69 75 10 f0       	push   $0xf0107569
f0103272:	e8 c9 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103277:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010327a:	c1 e0 16             	shl    $0x16,%eax
f010327d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103280:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103285:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010328c:	01 
f010328d:	74 17                	je     f01032a6 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010328f:	83 ec 08             	sub    $0x8,%esp
f0103292:	89 d8                	mov    %ebx,%eax
f0103294:	c1 e0 0c             	shl    $0xc,%eax
f0103297:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010329a:	50                   	push   %eax
f010329b:	ff 77 60             	pushl  0x60(%edi)
f010329e:	e8 39 df ff ff       	call   f01011dc <page_remove>
f01032a3:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032a6:	83 c3 01             	add    $0x1,%ebx
f01032a9:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01032af:	75 d4                	jne    f0103285 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01032b1:	8b 47 60             	mov    0x60(%edi),%eax
f01032b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032b7:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032be:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01032c1:	3b 05 94 fe 29 f0    	cmp    0xf029fe94,%eax
f01032c7:	72 14                	jb     f01032dd <env_free+0x101>
		panic("pa2page called with invalid pa");
f01032c9:	83 ec 04             	sub    $0x4,%esp
f01032cc:	68 d4 69 10 f0       	push   $0xf01069d4
f01032d1:	6a 51                	push   $0x51
f01032d3:	68 63 72 10 f0       	push   $0xf0107263
f01032d8:	e8 63 cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01032dd:	83 ec 0c             	sub    $0xc,%esp
f01032e0:	a1 9c fe 29 f0       	mov    0xf029fe9c,%eax
f01032e5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01032e8:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01032eb:	50                   	push   %eax
f01032ec:	e8 9e dc ff ff       	call   f0100f8f <page_decref>
f01032f1:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01032f4:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01032f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032fb:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103300:	0f 85 29 ff ff ff    	jne    f010322f <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103306:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103309:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010330e:	77 15                	ja     f0103325 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103310:	50                   	push   %eax
f0103311:	68 68 63 10 f0       	push   $0xf0106368
f0103316:	68 cf 01 00 00       	push   $0x1cf
f010331b:	68 69 75 10 f0       	push   $0xf0107569
f0103320:	e8 1b cd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103325:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010332c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103331:	c1 e8 0c             	shr    $0xc,%eax
f0103334:	3b 05 94 fe 29 f0    	cmp    0xf029fe94,%eax
f010333a:	72 14                	jb     f0103350 <env_free+0x174>
		panic("pa2page called with invalid pa");
f010333c:	83 ec 04             	sub    $0x4,%esp
f010333f:	68 d4 69 10 f0       	push   $0xf01069d4
f0103344:	6a 51                	push   $0x51
f0103346:	68 63 72 10 f0       	push   $0xf0107263
f010334b:	e8 f0 cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103350:	83 ec 0c             	sub    $0xc,%esp
f0103353:	8b 15 9c fe 29 f0    	mov    0xf029fe9c,%edx
f0103359:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010335c:	50                   	push   %eax
f010335d:	e8 2d dc ff ff       	call   f0100f8f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103362:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103369:	a1 4c f2 29 f0       	mov    0xf029f24c,%eax
f010336e:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103371:	89 3d 4c f2 29 f0    	mov    %edi,0xf029f24c
}
f0103377:	83 c4 10             	add    $0x10,%esp
f010337a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010337d:	5b                   	pop    %ebx
f010337e:	5e                   	pop    %esi
f010337f:	5f                   	pop    %edi
f0103380:	5d                   	pop    %ebp
f0103381:	c3                   	ret    

f0103382 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103382:	55                   	push   %ebp
f0103383:	89 e5                	mov    %esp,%ebp
f0103385:	53                   	push   %ebx
f0103386:	83 ec 04             	sub    $0x4,%esp
f0103389:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010338c:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103390:	75 19                	jne    f01033ab <env_destroy+0x29>
f0103392:	e8 83 23 00 00       	call   f010571a <cpunum>
f0103397:	6b c0 74             	imul   $0x74,%eax,%eax
f010339a:	3b 98 28 00 2a f0    	cmp    -0xfd5ffd8(%eax),%ebx
f01033a0:	74 09                	je     f01033ab <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01033a2:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01033a9:	eb 33                	jmp    f01033de <env_destroy+0x5c>
	}

	env_free(e);
f01033ab:	83 ec 0c             	sub    $0xc,%esp
f01033ae:	53                   	push   %ebx
f01033af:	e8 28 fe ff ff       	call   f01031dc <env_free>

	if (curenv == e) {
f01033b4:	e8 61 23 00 00       	call   f010571a <cpunum>
f01033b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01033bc:	83 c4 10             	add    $0x10,%esp
f01033bf:	3b 98 28 00 2a f0    	cmp    -0xfd5ffd8(%eax),%ebx
f01033c5:	75 17                	jne    f01033de <env_destroy+0x5c>
		curenv = NULL;
f01033c7:	e8 4e 23 00 00       	call   f010571a <cpunum>
f01033cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01033cf:	c7 80 28 00 2a f0 00 	movl   $0x0,-0xfd5ffd8(%eax)
f01033d6:	00 00 00 
		sched_yield();
f01033d9:	e8 af 0b 00 00       	call   f0103f8d <sched_yield>
	}
}
f01033de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033e1:	c9                   	leave  
f01033e2:	c3                   	ret    

f01033e3 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01033e3:	55                   	push   %ebp
f01033e4:	89 e5                	mov    %esp,%ebp
f01033e6:	53                   	push   %ebx
f01033e7:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01033ea:	e8 2b 23 00 00       	call   f010571a <cpunum>
f01033ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01033f2:	8b 98 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%ebx
f01033f8:	e8 1d 23 00 00       	call   f010571a <cpunum>
f01033fd:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103400:	8b 65 08             	mov    0x8(%ebp),%esp
f0103403:	61                   	popa   
f0103404:	07                   	pop    %es
f0103405:	1f                   	pop    %ds
f0103406:	83 c4 08             	add    $0x8,%esp
f0103409:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010340a:	83 ec 04             	sub    $0x4,%esp
f010340d:	68 74 75 10 f0       	push   $0xf0107574
f0103412:	68 05 02 00 00       	push   $0x205
f0103417:	68 69 75 10 f0       	push   $0xf0107569
f010341c:	e8 1f cc ff ff       	call   f0100040 <_panic>

f0103421 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103421:	55                   	push   %ebp
f0103422:	89 e5                	mov    %esp,%ebp
f0103424:	53                   	push   %ebx
f0103425:	83 ec 04             	sub    $0x4,%esp
f0103428:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// Step 1
	if (curenv && curenv->env_status == ENV_RUNNING)
f010342b:	e8 ea 22 00 00       	call   f010571a <cpunum>
f0103430:	6b c0 74             	imul   $0x74,%eax,%eax
f0103433:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f010343a:	74 29                	je     f0103465 <env_run+0x44>
f010343c:	e8 d9 22 00 00       	call   f010571a <cpunum>
f0103441:	6b c0 74             	imul   $0x74,%eax,%eax
f0103444:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f010344a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010344e:	75 15                	jne    f0103465 <env_run+0x44>
		curenv->env_status = ENV_RUNNABLE;
f0103450:	e8 c5 22 00 00       	call   f010571a <cpunum>
f0103455:	6b c0 74             	imul   $0x74,%eax,%eax
f0103458:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f010345e:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103465:	e8 b0 22 00 00       	call   f010571a <cpunum>
f010346a:	6b c0 74             	imul   $0x74,%eax,%eax
f010346d:	89 98 28 00 2a f0    	mov    %ebx,-0xfd5ffd8(%eax)
	e->env_status = ENV_RUNNING;
f0103473:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs += 1;
f010347a:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f010347e:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103481:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103486:	77 15                	ja     f010349d <env_run+0x7c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103488:	50                   	push   %eax
f0103489:	68 68 63 10 f0       	push   $0xf0106368
f010348e:	68 29 02 00 00       	push   $0x229
f0103493:	68 69 75 10 f0       	push   $0xf0107569
f0103498:	e8 a3 cb ff ff       	call   f0100040 <_panic>
f010349d:	05 00 00 00 10       	add    $0x10000000,%eax
f01034a2:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01034a5:	83 ec 0c             	sub    $0xc,%esp
f01034a8:	68 60 24 12 f0       	push   $0xf0122460
f01034ad:	e8 73 25 00 00       	call   f0105a25 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01034b2:	f3 90                	pause  

	// Step 2
	unlock_kernel();
	env_pop_tf(&(e->env_tf));
f01034b4:	89 1c 24             	mov    %ebx,(%esp)
f01034b7:	e8 27 ff ff ff       	call   f01033e3 <env_pop_tf>

f01034bc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01034bc:	55                   	push   %ebp
f01034bd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034bf:	ba 70 00 00 00       	mov    $0x70,%edx
f01034c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01034c7:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034c8:	ba 71 00 00 00       	mov    $0x71,%edx
f01034cd:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01034ce:	0f b6 c0             	movzbl %al,%eax
}
f01034d1:	5d                   	pop    %ebp
f01034d2:	c3                   	ret    

f01034d3 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034d3:	55                   	push   %ebp
f01034d4:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034d6:	ba 70 00 00 00       	mov    $0x70,%edx
f01034db:	8b 45 08             	mov    0x8(%ebp),%eax
f01034de:	ee                   	out    %al,(%dx)
f01034df:	ba 71 00 00 00       	mov    $0x71,%edx
f01034e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034e7:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034e8:	5d                   	pop    %ebp
f01034e9:	c3                   	ret    

f01034ea <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01034ea:	55                   	push   %ebp
f01034eb:	89 e5                	mov    %esp,%ebp
f01034ed:	56                   	push   %esi
f01034ee:	53                   	push   %ebx
f01034ef:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01034f2:	66 a3 a8 23 12 f0    	mov    %ax,0xf01223a8
	if (!didinit)
f01034f8:	80 3d 50 f2 29 f0 00 	cmpb   $0x0,0xf029f250
f01034ff:	74 5a                	je     f010355b <irq_setmask_8259A+0x71>
f0103501:	89 c6                	mov    %eax,%esi
f0103503:	ba 21 00 00 00       	mov    $0x21,%edx
f0103508:	ee                   	out    %al,(%dx)
f0103509:	66 c1 e8 08          	shr    $0x8,%ax
f010350d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103512:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103513:	83 ec 0c             	sub    $0xc,%esp
f0103516:	68 80 75 10 f0       	push   $0xf0107580
f010351b:	e8 31 01 00 00       	call   f0103651 <cprintf>
f0103520:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103523:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103528:	0f b7 f6             	movzwl %si,%esi
f010352b:	f7 d6                	not    %esi
f010352d:	0f a3 de             	bt     %ebx,%esi
f0103530:	73 11                	jae    f0103543 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103532:	83 ec 08             	sub    $0x8,%esp
f0103535:	53                   	push   %ebx
f0103536:	68 0f 7a 10 f0       	push   $0xf0107a0f
f010353b:	e8 11 01 00 00       	call   f0103651 <cprintf>
f0103540:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103543:	83 c3 01             	add    $0x1,%ebx
f0103546:	83 fb 10             	cmp    $0x10,%ebx
f0103549:	75 e2                	jne    f010352d <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010354b:	83 ec 0c             	sub    $0xc,%esp
f010354e:	68 37 75 10 f0       	push   $0xf0107537
f0103553:	e8 f9 00 00 00       	call   f0103651 <cprintf>
f0103558:	83 c4 10             	add    $0x10,%esp
}
f010355b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010355e:	5b                   	pop    %ebx
f010355f:	5e                   	pop    %esi
f0103560:	5d                   	pop    %ebp
f0103561:	c3                   	ret    

f0103562 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103562:	c6 05 50 f2 29 f0 01 	movb   $0x1,0xf029f250
f0103569:	ba 21 00 00 00       	mov    $0x21,%edx
f010356e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103573:	ee                   	out    %al,(%dx)
f0103574:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103579:	ee                   	out    %al,(%dx)
f010357a:	ba 20 00 00 00       	mov    $0x20,%edx
f010357f:	b8 11 00 00 00       	mov    $0x11,%eax
f0103584:	ee                   	out    %al,(%dx)
f0103585:	ba 21 00 00 00       	mov    $0x21,%edx
f010358a:	b8 20 00 00 00       	mov    $0x20,%eax
f010358f:	ee                   	out    %al,(%dx)
f0103590:	b8 04 00 00 00       	mov    $0x4,%eax
f0103595:	ee                   	out    %al,(%dx)
f0103596:	b8 03 00 00 00       	mov    $0x3,%eax
f010359b:	ee                   	out    %al,(%dx)
f010359c:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035a1:	b8 11 00 00 00       	mov    $0x11,%eax
f01035a6:	ee                   	out    %al,(%dx)
f01035a7:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035ac:	b8 28 00 00 00       	mov    $0x28,%eax
f01035b1:	ee                   	out    %al,(%dx)
f01035b2:	b8 02 00 00 00       	mov    $0x2,%eax
f01035b7:	ee                   	out    %al,(%dx)
f01035b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01035bd:	ee                   	out    %al,(%dx)
f01035be:	ba 20 00 00 00       	mov    $0x20,%edx
f01035c3:	b8 68 00 00 00       	mov    $0x68,%eax
f01035c8:	ee                   	out    %al,(%dx)
f01035c9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035ce:	ee                   	out    %al,(%dx)
f01035cf:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035d4:	b8 68 00 00 00       	mov    $0x68,%eax
f01035d9:	ee                   	out    %al,(%dx)
f01035da:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035df:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01035e0:	0f b7 05 a8 23 12 f0 	movzwl 0xf01223a8,%eax
f01035e7:	66 83 f8 ff          	cmp    $0xffff,%ax
f01035eb:	74 13                	je     f0103600 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01035ed:	55                   	push   %ebp
f01035ee:	89 e5                	mov    %esp,%ebp
f01035f0:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01035f3:	0f b7 c0             	movzwl %ax,%eax
f01035f6:	50                   	push   %eax
f01035f7:	e8 ee fe ff ff       	call   f01034ea <irq_setmask_8259A>
f01035fc:	83 c4 10             	add    $0x10,%esp
}
f01035ff:	c9                   	leave  
f0103600:	f3 c3                	repz ret 

f0103602 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0103602:	55                   	push   %ebp
f0103603:	89 e5                	mov    %esp,%ebp
f0103605:	ba 20 00 00 00       	mov    $0x20,%edx
f010360a:	b8 20 00 00 00       	mov    $0x20,%eax
f010360f:	ee                   	out    %al,(%dx)
f0103610:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103615:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0103616:	5d                   	pop    %ebp
f0103617:	c3                   	ret    

f0103618 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103618:	55                   	push   %ebp
f0103619:	89 e5                	mov    %esp,%ebp
f010361b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010361e:	ff 75 08             	pushl  0x8(%ebp)
f0103621:	e8 6f d1 ff ff       	call   f0100795 <cputchar>
	*cnt++;
}
f0103626:	83 c4 10             	add    $0x10,%esp
f0103629:	c9                   	leave  
f010362a:	c3                   	ret    

f010362b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010362b:	55                   	push   %ebp
f010362c:	89 e5                	mov    %esp,%ebp
f010362e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103631:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103638:	ff 75 0c             	pushl  0xc(%ebp)
f010363b:	ff 75 08             	pushl  0x8(%ebp)
f010363e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103641:	50                   	push   %eax
f0103642:	68 18 36 10 f0       	push   $0xf0103618
f0103647:	e8 27 14 00 00       	call   f0104a73 <vprintfmt>
	return cnt;
}
f010364c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010364f:	c9                   	leave  
f0103650:	c3                   	ret    

f0103651 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103651:	55                   	push   %ebp
f0103652:	89 e5                	mov    %esp,%ebp
f0103654:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103657:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010365a:	50                   	push   %eax
f010365b:	ff 75 08             	pushl  0x8(%ebp)
f010365e:	e8 c8 ff ff ff       	call   f010362b <vcprintf>
	va_end(ap);

	return cnt;
}
f0103663:	c9                   	leave  
f0103664:	c3                   	ret    

f0103665 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103665:	55                   	push   %ebp
f0103666:	89 e5                	mov    %esp,%ebp
f0103668:	57                   	push   %edi
f0103669:	56                   	push   %esi
f010366a:	53                   	push   %ebx
f010366b:	83 ec 1c             	sub    $0x1c,%esp
	lidt(&idt_pd);
	*/

	/* MY CODE */
	// Get cpu index
	uint32_t i = thiscpu->cpu_id;
f010366e:	e8 a7 20 00 00       	call   f010571a <cpunum>
f0103673:	6b c0 74             	imul   $0x74,%eax,%eax
f0103676:	0f b6 b0 20 00 2a f0 	movzbl -0xfd5ffe0(%eax),%esi
f010367d:	89 f0                	mov    %esi,%eax
f010367f:	0f b6 d8             	movzbl %al,%ebx

	// Setup the cpu TSS
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103682:	e8 93 20 00 00       	call   f010571a <cpunum>
f0103687:	6b c0 74             	imul   $0x74,%eax,%eax
f010368a:	89 da                	mov    %ebx,%edx
f010368c:	f7 da                	neg    %edx
f010368e:	c1 e2 10             	shl    $0x10,%edx
f0103691:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103697:	89 90 30 00 2a f0    	mov    %edx,-0xfd5ffd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f010369d:	e8 78 20 00 00       	call   f010571a <cpunum>
f01036a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a5:	66 c7 80 34 00 2a f0 	movw   $0x10,-0xfd5ffcc(%eax)
f01036ac:	10 00 

	// Initialize the TSS slot of the gdt, so the hardware can access it
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01036ae:	83 c3 05             	add    $0x5,%ebx
f01036b1:	e8 64 20 00 00       	call   f010571a <cpunum>
f01036b6:	89 c7                	mov    %eax,%edi
f01036b8:	e8 5d 20 00 00       	call   f010571a <cpunum>
f01036bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01036c0:	e8 55 20 00 00       	call   f010571a <cpunum>
f01036c5:	66 c7 04 dd 40 23 12 	movw   $0x67,-0xfeddcc0(,%ebx,8)
f01036cc:	f0 67 00 
f01036cf:	6b ff 74             	imul   $0x74,%edi,%edi
f01036d2:	81 c7 2c 00 2a f0    	add    $0xf02a002c,%edi
f01036d8:	66 89 3c dd 42 23 12 	mov    %di,-0xfeddcbe(,%ebx,8)
f01036df:	f0 
f01036e0:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f01036e4:	81 c2 2c 00 2a f0    	add    $0xf02a002c,%edx
f01036ea:	c1 ea 10             	shr    $0x10,%edx
f01036ed:	88 14 dd 44 23 12 f0 	mov    %dl,-0xfeddcbc(,%ebx,8)
f01036f4:	c6 04 dd 46 23 12 f0 	movb   $0x40,-0xfeddcba(,%ebx,8)
f01036fb:	40 
f01036fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ff:	05 2c 00 2a f0       	add    $0xf02a002c,%eax
f0103704:	c1 e8 18             	shr    $0x18,%eax
f0103707:	88 04 dd 47 23 12 f0 	mov    %al,-0xfeddcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f010370e:	c6 04 dd 45 23 12 f0 	movb   $0x89,-0xfeddcbb(,%ebx,8)
f0103715:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103716:	89 f0                	mov    %esi,%eax
f0103718:	0f b6 f0             	movzbl %al,%esi
f010371b:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
f0103722:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103725:	b8 ac 23 12 f0       	mov    $0xf01223ac,%eax
f010372a:	0f 01 18             	lidtl  (%eax)
	// Load the TSS selector, so the hardware knows where to find it on the gdt
	ltr(GD_TSS0 + (i << 3));

	// Load the IDT
	lidt(&idt_pd);
}
f010372d:	83 c4 1c             	add    $0x1c,%esp
f0103730:	5b                   	pop    %ebx
f0103731:	5e                   	pop    %esi
f0103732:	5f                   	pop    %edi
f0103733:	5d                   	pop    %ebp
f0103734:	c3                   	ret    

f0103735 <trap_init>:
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	// Processor internal interrupts
	int i;
	for (i = 0; i <= 19; i++) {
f0103735:	b8 00 00 00 00       	mov    $0x0,%eax
		SETGATE(idt[i], 0, GD_KT, handlers[i], 0);
f010373a:	8b 14 85 b2 23 12 f0 	mov    -0xfeddc4e(,%eax,4),%edx
f0103741:	66 89 14 c5 60 f2 29 	mov    %dx,-0xfd60da0(,%eax,8)
f0103748:	f0 
f0103749:	66 c7 04 c5 62 f2 29 	movw   $0x8,-0xfd60d9e(,%eax,8)
f0103750:	f0 08 00 
f0103753:	c6 04 c5 64 f2 29 f0 	movb   $0x0,-0xfd60d9c(,%eax,8)
f010375a:	00 
f010375b:	c6 04 c5 65 f2 29 f0 	movb   $0x8e,-0xfd60d9b(,%eax,8)
f0103762:	8e 
f0103763:	c1 ea 10             	shr    $0x10,%edx
f0103766:	66 89 14 c5 66 f2 29 	mov    %dx,-0xfd60d9a(,%eax,8)
f010376d:	f0 
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	// Processor internal interrupts
	int i;
	for (i = 0; i <= 19; i++) {
f010376e:	83 c0 01             	add    $0x1,%eax
f0103771:	83 f8 14             	cmp    $0x14,%eax
f0103774:	75 c4                	jne    f010373a <trap_init+0x5>
		SETGATE(idt[i], 0, GD_KT, handlers[i], 0);
	}
	SETGATE(idt[T_BRKPT], 0, GD_KT, handlers[T_BRKPT], 3);
f0103776:	a1 be 23 12 f0       	mov    0xf01223be,%eax
f010377b:	66 a3 78 f2 29 f0    	mov    %ax,0xf029f278
f0103781:	66 c7 05 7a f2 29 f0 	movw   $0x8,0xf029f27a
f0103788:	08 00 
f010378a:	c6 05 7c f2 29 f0 00 	movb   $0x0,0xf029f27c
f0103791:	c6 05 7d f2 29 f0 ee 	movb   $0xee,0xf029f27d
f0103798:	c1 e8 10             	shr    $0x10,%eax
f010379b:	66 a3 7e f2 29 f0    	mov    %ax,0xf029f27e

	// For system call
	SETGATE(idt[T_SYSCALL], 0, GD_KT, &handler_syscall, 3);
f01037a1:	b8 9e 3e 10 f0       	mov    $0xf0103e9e,%eax
f01037a6:	66 a3 e0 f3 29 f0    	mov    %ax,0xf029f3e0
f01037ac:	66 c7 05 e2 f3 29 f0 	movw   $0x8,0xf029f3e2
f01037b3:	08 00 
f01037b5:	c6 05 e4 f3 29 f0 00 	movb   $0x0,0xf029f3e4
f01037bc:	c6 05 e5 f3 29 f0 ee 	movb   $0xee,0xf029f3e5
f01037c3:	c1 e8 10             	shr    $0x10,%eax
f01037c6:	66 a3 e6 f3 29 f0    	mov    %ax,0xf029f3e6
f01037cc:	b8 20 00 00 00       	mov    $0x20,%eax

	// External interrupts
	for (i = 0; i <= 15; i++) {
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, handlers_irq[i],0);
f01037d1:	8b 14 85 82 23 12 f0 	mov    -0xfeddc7e(,%eax,4),%edx
f01037d8:	66 89 14 c5 60 f2 29 	mov    %dx,-0xfd60da0(,%eax,8)
f01037df:	f0 
f01037e0:	66 c7 04 c5 62 f2 29 	movw   $0x8,-0xfd60d9e(,%eax,8)
f01037e7:	f0 08 00 
f01037ea:	c6 04 c5 64 f2 29 f0 	movb   $0x0,-0xfd60d9c(,%eax,8)
f01037f1:	00 
f01037f2:	c6 04 c5 65 f2 29 f0 	movb   $0x8e,-0xfd60d9b(,%eax,8)
f01037f9:	8e 
f01037fa:	c1 ea 10             	shr    $0x10,%edx
f01037fd:	66 89 14 c5 66 f2 29 	mov    %dx,-0xfd60d9a(,%eax,8)
f0103804:	f0 
f0103805:	83 c0 01             	add    $0x1,%eax

	// For system call
	SETGATE(idt[T_SYSCALL], 0, GD_KT, &handler_syscall, 3);

	// External interrupts
	for (i = 0; i <= 15; i++) {
f0103808:	83 f8 30             	cmp    $0x30,%eax
f010380b:	75 c4                	jne    f01037d1 <trap_init+0x9c>
extern void* handler_syscall;
extern uint32_t handlers[];
extern uint32_t handlers_irq[];
void
trap_init(void)
{
f010380d:	55                   	push   %ebp
f010380e:	89 e5                	mov    %esp,%ebp
f0103810:	83 ec 08             	sub    $0x8,%esp
	for (i = 0; i <= 15; i++) {
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, handlers_irq[i],0);
	}

	// Per-CPU setup 
	trap_init_percpu();
f0103813:	e8 4d fe ff ff       	call   f0103665 <trap_init_percpu>
}
f0103818:	c9                   	leave  
f0103819:	c3                   	ret    

f010381a <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010381a:	55                   	push   %ebp
f010381b:	89 e5                	mov    %esp,%ebp
f010381d:	53                   	push   %ebx
f010381e:	83 ec 0c             	sub    $0xc,%esp
f0103821:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103824:	ff 33                	pushl  (%ebx)
f0103826:	68 94 75 10 f0       	push   $0xf0107594
f010382b:	e8 21 fe ff ff       	call   f0103651 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103830:	83 c4 08             	add    $0x8,%esp
f0103833:	ff 73 04             	pushl  0x4(%ebx)
f0103836:	68 a3 75 10 f0       	push   $0xf01075a3
f010383b:	e8 11 fe ff ff       	call   f0103651 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103840:	83 c4 08             	add    $0x8,%esp
f0103843:	ff 73 08             	pushl  0x8(%ebx)
f0103846:	68 b2 75 10 f0       	push   $0xf01075b2
f010384b:	e8 01 fe ff ff       	call   f0103651 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103850:	83 c4 08             	add    $0x8,%esp
f0103853:	ff 73 0c             	pushl  0xc(%ebx)
f0103856:	68 c1 75 10 f0       	push   $0xf01075c1
f010385b:	e8 f1 fd ff ff       	call   f0103651 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103860:	83 c4 08             	add    $0x8,%esp
f0103863:	ff 73 10             	pushl  0x10(%ebx)
f0103866:	68 d0 75 10 f0       	push   $0xf01075d0
f010386b:	e8 e1 fd ff ff       	call   f0103651 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103870:	83 c4 08             	add    $0x8,%esp
f0103873:	ff 73 14             	pushl  0x14(%ebx)
f0103876:	68 df 75 10 f0       	push   $0xf01075df
f010387b:	e8 d1 fd ff ff       	call   f0103651 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103880:	83 c4 08             	add    $0x8,%esp
f0103883:	ff 73 18             	pushl  0x18(%ebx)
f0103886:	68 ee 75 10 f0       	push   $0xf01075ee
f010388b:	e8 c1 fd ff ff       	call   f0103651 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103890:	83 c4 08             	add    $0x8,%esp
f0103893:	ff 73 1c             	pushl  0x1c(%ebx)
f0103896:	68 fd 75 10 f0       	push   $0xf01075fd
f010389b:	e8 b1 fd ff ff       	call   f0103651 <cprintf>
}
f01038a0:	83 c4 10             	add    $0x10,%esp
f01038a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01038a6:	c9                   	leave  
f01038a7:	c3                   	ret    

f01038a8 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01038a8:	55                   	push   %ebp
f01038a9:	89 e5                	mov    %esp,%ebp
f01038ab:	56                   	push   %esi
f01038ac:	53                   	push   %ebx
f01038ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01038b0:	e8 65 1e 00 00       	call   f010571a <cpunum>
f01038b5:	83 ec 04             	sub    $0x4,%esp
f01038b8:	50                   	push   %eax
f01038b9:	53                   	push   %ebx
f01038ba:	68 61 76 10 f0       	push   $0xf0107661
f01038bf:	e8 8d fd ff ff       	call   f0103651 <cprintf>
	print_regs(&tf->tf_regs);
f01038c4:	89 1c 24             	mov    %ebx,(%esp)
f01038c7:	e8 4e ff ff ff       	call   f010381a <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01038cc:	83 c4 08             	add    $0x8,%esp
f01038cf:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01038d3:	50                   	push   %eax
f01038d4:	68 7f 76 10 f0       	push   $0xf010767f
f01038d9:	e8 73 fd ff ff       	call   f0103651 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01038de:	83 c4 08             	add    $0x8,%esp
f01038e1:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01038e5:	50                   	push   %eax
f01038e6:	68 92 76 10 f0       	push   $0xf0107692
f01038eb:	e8 61 fd ff ff       	call   f0103651 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01038f0:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01038f3:	83 c4 10             	add    $0x10,%esp
f01038f6:	83 f8 13             	cmp    $0x13,%eax
f01038f9:	77 09                	ja     f0103904 <print_trapframe+0x5c>
		return excnames[trapno];
f01038fb:	8b 14 85 20 79 10 f0 	mov    -0xfef86e0(,%eax,4),%edx
f0103902:	eb 1f                	jmp    f0103923 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103904:	83 f8 30             	cmp    $0x30,%eax
f0103907:	74 15                	je     f010391e <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103909:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f010390c:	83 fa 10             	cmp    $0x10,%edx
f010390f:	b9 2b 76 10 f0       	mov    $0xf010762b,%ecx
f0103914:	ba 18 76 10 f0       	mov    $0xf0107618,%edx
f0103919:	0f 43 d1             	cmovae %ecx,%edx
f010391c:	eb 05                	jmp    f0103923 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010391e:	ba 0c 76 10 f0       	mov    $0xf010760c,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103923:	83 ec 04             	sub    $0x4,%esp
f0103926:	52                   	push   %edx
f0103927:	50                   	push   %eax
f0103928:	68 a5 76 10 f0       	push   $0xf01076a5
f010392d:	e8 1f fd ff ff       	call   f0103651 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103932:	83 c4 10             	add    $0x10,%esp
f0103935:	3b 1d 60 fa 29 f0    	cmp    0xf029fa60,%ebx
f010393b:	75 1a                	jne    f0103957 <print_trapframe+0xaf>
f010393d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103941:	75 14                	jne    f0103957 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103943:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103946:	83 ec 08             	sub    $0x8,%esp
f0103949:	50                   	push   %eax
f010394a:	68 b7 76 10 f0       	push   $0xf01076b7
f010394f:	e8 fd fc ff ff       	call   f0103651 <cprintf>
f0103954:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103957:	83 ec 08             	sub    $0x8,%esp
f010395a:	ff 73 2c             	pushl  0x2c(%ebx)
f010395d:	68 c6 76 10 f0       	push   $0xf01076c6
f0103962:	e8 ea fc ff ff       	call   f0103651 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103967:	83 c4 10             	add    $0x10,%esp
f010396a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010396e:	75 49                	jne    f01039b9 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103970:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103973:	89 c2                	mov    %eax,%edx
f0103975:	83 e2 01             	and    $0x1,%edx
f0103978:	ba 45 76 10 f0       	mov    $0xf0107645,%edx
f010397d:	b9 3a 76 10 f0       	mov    $0xf010763a,%ecx
f0103982:	0f 44 ca             	cmove  %edx,%ecx
f0103985:	89 c2                	mov    %eax,%edx
f0103987:	83 e2 02             	and    $0x2,%edx
f010398a:	ba 57 76 10 f0       	mov    $0xf0107657,%edx
f010398f:	be 51 76 10 f0       	mov    $0xf0107651,%esi
f0103994:	0f 45 d6             	cmovne %esi,%edx
f0103997:	83 e0 04             	and    $0x4,%eax
f010399a:	be ac 77 10 f0       	mov    $0xf01077ac,%esi
f010399f:	b8 5c 76 10 f0       	mov    $0xf010765c,%eax
f01039a4:	0f 44 c6             	cmove  %esi,%eax
f01039a7:	51                   	push   %ecx
f01039a8:	52                   	push   %edx
f01039a9:	50                   	push   %eax
f01039aa:	68 d4 76 10 f0       	push   $0xf01076d4
f01039af:	e8 9d fc ff ff       	call   f0103651 <cprintf>
f01039b4:	83 c4 10             	add    $0x10,%esp
f01039b7:	eb 10                	jmp    f01039c9 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01039b9:	83 ec 0c             	sub    $0xc,%esp
f01039bc:	68 37 75 10 f0       	push   $0xf0107537
f01039c1:	e8 8b fc ff ff       	call   f0103651 <cprintf>
f01039c6:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01039c9:	83 ec 08             	sub    $0x8,%esp
f01039cc:	ff 73 30             	pushl  0x30(%ebx)
f01039cf:	68 e3 76 10 f0       	push   $0xf01076e3
f01039d4:	e8 78 fc ff ff       	call   f0103651 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01039d9:	83 c4 08             	add    $0x8,%esp
f01039dc:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01039e0:	50                   	push   %eax
f01039e1:	68 f2 76 10 f0       	push   $0xf01076f2
f01039e6:	e8 66 fc ff ff       	call   f0103651 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01039eb:	83 c4 08             	add    $0x8,%esp
f01039ee:	ff 73 38             	pushl  0x38(%ebx)
f01039f1:	68 05 77 10 f0       	push   $0xf0107705
f01039f6:	e8 56 fc ff ff       	call   f0103651 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01039fb:	83 c4 10             	add    $0x10,%esp
f01039fe:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103a02:	74 25                	je     f0103a29 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103a04:	83 ec 08             	sub    $0x8,%esp
f0103a07:	ff 73 3c             	pushl  0x3c(%ebx)
f0103a0a:	68 14 77 10 f0       	push   $0xf0107714
f0103a0f:	e8 3d fc ff ff       	call   f0103651 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103a14:	83 c4 08             	add    $0x8,%esp
f0103a17:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103a1b:	50                   	push   %eax
f0103a1c:	68 23 77 10 f0       	push   $0xf0107723
f0103a21:	e8 2b fc ff ff       	call   f0103651 <cprintf>
f0103a26:	83 c4 10             	add    $0x10,%esp
	}
}
f0103a29:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a2c:	5b                   	pop    %ebx
f0103a2d:	5e                   	pop    %esi
f0103a2e:	5d                   	pop    %ebp
f0103a2f:	c3                   	ret    

f0103a30 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103a30:	55                   	push   %ebp
f0103a31:	89 e5                	mov    %esp,%ebp
f0103a33:	57                   	push   %edi
f0103a34:	56                   	push   %esi
f0103a35:	53                   	push   %ebx
f0103a36:	83 ec 1c             	sub    $0x1c,%esp
f0103a39:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103a3c:	0f 20 d6             	mov    %cr2,%esi
	//cprintf("DEBUG-TRAP: Page fault on address %x, err = %x\n", fault_va, tf->tf_err);

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) // Checks last 2 bits are 0
f0103a3f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103a43:	75 17                	jne    f0103a5c <page_fault_handler+0x2c>
		panic("Page fault on kernel mode!");
f0103a45:	83 ec 04             	sub    $0x4,%esp
f0103a48:	68 36 77 10 f0       	push   $0xf0107736
f0103a4d:	68 6c 01 00 00       	push   $0x16c
f0103a52:	68 51 77 10 f0       	push   $0xf0107751
f0103a57:	e8 e4 c5 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0103a5c:	e8 b9 1c 00 00       	call   f010571a <cpunum>
f0103a61:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a64:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103a6a:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103a6e:	0f 84 95 00 00 00    	je     f0103b09 <page_fault_handler+0xd9>
		struct UTrapframe *utf;

		// Recursive case. Pgfault handler pgfaulted.
		if (UXSTACKTOP-PGSIZE <= tf->tf_esp && tf->tf_esp < UXSTACKTOP) {
f0103a74:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103a77:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *) (tf->tf_esp - 4); // Gap
f0103a7d:	83 e8 04             	sub    $0x4,%eax
f0103a80:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103a86:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103a8b:	0f 46 d0             	cmovbe %eax,%edx
f0103a8e:	89 d7                	mov    %edx,%edi
		} else {
			utf = (struct UTrapframe *) UXSTACKTOP;
		}

		// Make utf point to the new top of the exception stack
		utf--;
f0103a90:	8d 42 cc             	lea    -0x34(%edx),%eax
f0103a93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		user_mem_assert(curenv, utf, sizeof(struct UTrapframe), PTE_W);
f0103a96:	e8 7f 1c 00 00       	call   f010571a <cpunum>
f0103a9b:	6a 02                	push   $0x2
f0103a9d:	6a 34                	push   $0x34
f0103a9f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103aa2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103aa5:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0103aab:	e8 5d f3 ff ff       	call   f0102e0d <user_mem_assert>

		// "Push" the info
		utf->utf_fault_va = fault_va;
f0103ab0:	89 fa                	mov    %edi,%edx
f0103ab2:	89 77 cc             	mov    %esi,-0x34(%edi)
		utf->utf_err = tf->tf_err;
f0103ab5:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103ab8:	89 47 d0             	mov    %eax,-0x30(%edi)
		utf->utf_regs = tf->tf_regs;
f0103abb:	8d 7f d4             	lea    -0x2c(%edi),%edi
f0103abe:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103ac3:	89 de                	mov    %ebx,%esi
f0103ac5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0103ac7:	8b 43 30             	mov    0x30(%ebx),%eax
f0103aca:	89 42 f4             	mov    %eax,-0xc(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0103acd:	8b 43 38             	mov    0x38(%ebx),%eax
f0103ad0:	89 42 f8             	mov    %eax,-0x8(%edx)
		utf->utf_esp = tf->tf_esp;
f0103ad3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103ad6:	89 42 fc             	mov    %eax,-0x4(%edx)

		// Branch to curenv->env_pgfault_upcall: back to user mode!
		tf->tf_esp = (uintptr_t) utf;
f0103ad9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103adc:	89 43 3c             	mov    %eax,0x3c(%ebx)
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0103adf:	e8 36 1c 00 00       	call   f010571a <cpunum>
f0103ae4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ae7:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103aed:	8b 40 64             	mov    0x64(%eax),%eax
f0103af0:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f0103af3:	e8 22 1c 00 00       	call   f010571a <cpunum>
f0103af8:	83 c4 04             	add    $0x4,%esp
f0103afb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103afe:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0103b04:	e8 18 f9 ff ff       	call   f0103421 <env_run>

		return;
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103b09:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103b0c:	e8 09 1c 00 00       	call   f010571a <cpunum>

		return;
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103b11:	57                   	push   %edi
f0103b12:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103b13:	6b c0 74             	imul   $0x74,%eax,%eax

		return;
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103b16:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103b1c:	ff 70 48             	pushl  0x48(%eax)
f0103b1f:	68 f8 78 10 f0       	push   $0xf01078f8
f0103b24:	e8 28 fb ff ff       	call   f0103651 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103b29:	89 1c 24             	mov    %ebx,(%esp)
f0103b2c:	e8 77 fd ff ff       	call   f01038a8 <print_trapframe>
	env_destroy(curenv);
f0103b31:	e8 e4 1b 00 00       	call   f010571a <cpunum>
f0103b36:	83 c4 04             	add    $0x4,%esp
f0103b39:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b3c:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0103b42:	e8 3b f8 ff ff       	call   f0103382 <env_destroy>
}
f0103b47:	83 c4 10             	add    $0x10,%esp
f0103b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b4d:	5b                   	pop    %ebx
f0103b4e:	5e                   	pop    %esi
f0103b4f:	5f                   	pop    %edi
f0103b50:	5d                   	pop    %ebp
f0103b51:	c3                   	ret    

f0103b52 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103b52:	55                   	push   %ebp
f0103b53:	89 e5                	mov    %esp,%ebp
f0103b55:	57                   	push   %edi
f0103b56:	56                   	push   %esi
f0103b57:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103b5a:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103b5b:	83 3d 8c fe 29 f0 00 	cmpl   $0x0,0xf029fe8c
f0103b62:	74 01                	je     f0103b65 <trap+0x13>
		asm volatile("hlt");
f0103b64:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103b65:	e8 b0 1b 00 00       	call   f010571a <cpunum>
f0103b6a:	6b d0 74             	imul   $0x74,%eax,%edx
f0103b6d:	81 c2 20 00 2a f0    	add    $0xf02a0020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103b73:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b78:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103b7c:	83 f8 02             	cmp    $0x2,%eax
f0103b7f:	75 10                	jne    f0103b91 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103b81:	83 ec 0c             	sub    $0xc,%esp
f0103b84:	68 60 24 12 f0       	push   $0xf0122460
f0103b89:	e8 fa 1d 00 00       	call   f0105988 <spin_lock>
f0103b8e:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103b91:	9c                   	pushf  
f0103b92:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103b93:	f6 c4 02             	test   $0x2,%ah
f0103b96:	74 19                	je     f0103bb1 <trap+0x5f>
f0103b98:	68 5d 77 10 f0       	push   $0xf010775d
f0103b9d:	68 7d 72 10 f0       	push   $0xf010727d
f0103ba2:	68 35 01 00 00       	push   $0x135
f0103ba7:	68 51 77 10 f0       	push   $0xf0107751
f0103bac:	e8 8f c4 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103bb1:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103bb5:	83 e0 03             	and    $0x3,%eax
f0103bb8:	66 83 f8 03          	cmp    $0x3,%ax
f0103bbc:	0f 85 a0 00 00 00    	jne    f0103c62 <trap+0x110>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0103bc2:	e8 53 1b 00 00       	call   f010571a <cpunum>
f0103bc7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bca:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f0103bd1:	75 19                	jne    f0103bec <trap+0x9a>
f0103bd3:	68 76 77 10 f0       	push   $0xf0107776
f0103bd8:	68 7d 72 10 f0       	push   $0xf010727d
f0103bdd:	68 3c 01 00 00       	push   $0x13c
f0103be2:	68 51 77 10 f0       	push   $0xf0107751
f0103be7:	e8 54 c4 ff ff       	call   f0100040 <_panic>
f0103bec:	83 ec 0c             	sub    $0xc,%esp
f0103bef:	68 60 24 12 f0       	push   $0xf0122460
f0103bf4:	e8 8f 1d 00 00       	call   f0105988 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103bf9:	e8 1c 1b 00 00       	call   f010571a <cpunum>
f0103bfe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c01:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103c07:	83 c4 10             	add    $0x10,%esp
f0103c0a:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103c0e:	75 2d                	jne    f0103c3d <trap+0xeb>
			env_free(curenv);
f0103c10:	e8 05 1b 00 00       	call   f010571a <cpunum>
f0103c15:	83 ec 0c             	sub    $0xc,%esp
f0103c18:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c1b:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0103c21:	e8 b6 f5 ff ff       	call   f01031dc <env_free>
			curenv = NULL;
f0103c26:	e8 ef 1a 00 00       	call   f010571a <cpunum>
f0103c2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c2e:	c7 80 28 00 2a f0 00 	movl   $0x0,-0xfd5ffd8(%eax)
f0103c35:	00 00 00 
			sched_yield();
f0103c38:	e8 50 03 00 00       	call   f0103f8d <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103c3d:	e8 d8 1a 00 00       	call   f010571a <cpunum>
f0103c42:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c45:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103c4b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103c50:	89 c7                	mov    %eax,%edi
f0103c52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103c54:	e8 c1 1a 00 00       	call   f010571a <cpunum>
f0103c59:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c5c:	8b b0 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103c62:	89 35 60 fa 29 f0    	mov    %esi,0xf029fa60
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// TODO: Start using T_* instead of interrupt numbers
	// TODO: Use a switch
	// TODO: Remove debugging printings
	if (tf->tf_trapno == 3) {
f0103c68:	8b 46 28             	mov    0x28(%esi),%eax
f0103c6b:	83 f8 03             	cmp    $0x3,%eax
f0103c6e:	75 11                	jne    f0103c81 <trap+0x12f>
		//cprintf("DEBUG-TRAP: Trap dispatch - Breakpoint\n");
		monitor(tf);
f0103c70:	83 ec 0c             	sub    $0xc,%esp
f0103c73:	56                   	push   %esi
f0103c74:	e8 6e cc ff ff       	call   f01008e7 <monitor>
f0103c79:	83 c4 10             	add    $0x10,%esp
f0103c7c:	e9 d6 00 00 00       	jmp    f0103d57 <trap+0x205>
		return;
	}
	if (tf->tf_trapno == 14) {
f0103c81:	83 f8 0e             	cmp    $0xe,%eax
f0103c84:	75 11                	jne    f0103c97 <trap+0x145>
		//cprintf("DEBUG-TRAP: Trap dispatch - Page fault\n");
		page_fault_handler(tf);
f0103c86:	83 ec 0c             	sub    $0xc,%esp
f0103c89:	56                   	push   %esi
f0103c8a:	e8 a1 fd ff ff       	call   f0103a30 <page_fault_handler>
f0103c8f:	83 c4 10             	add    $0x10,%esp
f0103c92:	e9 c0 00 00 00       	jmp    f0103d57 <trap+0x205>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0103c97:	83 f8 30             	cmp    $0x30,%eax
f0103c9a:	75 24                	jne    f0103cc0 <trap+0x16e>
		//cprintf("DEBUG-TRAP: Trap dispatch - System Call\n");
		struct PushRegs regs = tf->tf_regs;
		int32_t retValue;
		retValue = syscall(regs.reg_eax,// system call number - eax
f0103c9c:	83 ec 08             	sub    $0x8,%esp
f0103c9f:	ff 76 04             	pushl  0x4(%esi)
f0103ca2:	ff 36                	pushl  (%esi)
f0103ca4:	ff 76 10             	pushl  0x10(%esi)
f0103ca7:	ff 76 18             	pushl  0x18(%esi)
f0103caa:	ff 76 14             	pushl  0x14(%esi)
f0103cad:	ff 76 1c             	pushl  0x1c(%esi)
f0103cb0:	e8 a4 03 00 00       	call   f0104059 <syscall>
				regs.reg_edx,	// a1 - edx
				regs.reg_ecx,	// a2 - ecx
				regs.reg_ebx,	// a3 - ebx
				regs.reg_edi,	// a4 - edi
				regs.reg_esi);	// a5 - esi
		tf->tf_regs.reg_eax = retValue;
f0103cb5:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103cb8:	83 c4 20             	add    $0x20,%esp
f0103cbb:	e9 97 00 00 00       	jmp    f0103d57 <trap+0x205>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103cc0:	83 f8 27             	cmp    $0x27,%eax
f0103cc3:	75 1a                	jne    f0103cdf <trap+0x18d>
		cprintf("Spurious interrupt on irq 7\n");
f0103cc5:	83 ec 0c             	sub    $0xc,%esp
f0103cc8:	68 7d 77 10 f0       	push   $0xf010777d
f0103ccd:	e8 7f f9 ff ff       	call   f0103651 <cprintf>
		print_trapframe(tf);
f0103cd2:	89 34 24             	mov    %esi,(%esp)
f0103cd5:	e8 ce fb ff ff       	call   f01038a8 <print_trapframe>
f0103cda:	83 c4 10             	add    $0x10,%esp
f0103cdd:	eb 78                	jmp    f0103d57 <trap+0x205>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0103cdf:	83 f8 20             	cmp    $0x20,%eax
f0103ce2:	75 18                	jne    f0103cfc <trap+0x1aa>
		//cprintf("DEBUG-TRAP: Trap dispatch - Clock interrupt\n");
		lapic_eoi();
f0103ce4:	e8 7c 1b 00 00       	call   f0105865 <lapic_eoi>
		if (cpunum() == 0){
f0103ce9:	e8 2c 1a 00 00       	call   f010571a <cpunum>
f0103cee:	85 c0                	test   %eax,%eax
f0103cf0:	75 05                	jne    f0103cf7 <trap+0x1a5>
			time_tick();
f0103cf2:	e8 57 23 00 00       	call   f010604e <time_tick>
		}
		sched_yield();
f0103cf7:	e8 91 02 00 00       	call   f0103f8d <sched_yield>
	// LAB 6: Your code here.


	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	if(tf->tf_trapno ==  IRQ_OFFSET+IRQ_KBD){
f0103cfc:	83 f8 21             	cmp    $0x21,%eax
f0103cff:	75 07                	jne    f0103d08 <trap+0x1b6>
		kbd_intr();
f0103d01:	e8 ed c8 ff ff       	call   f01005f3 <kbd_intr>
f0103d06:	eb 4f                	jmp    f0103d57 <trap+0x205>
		return;
	}
	if(tf->tf_trapno == IRQ_OFFSET+IRQ_SERIAL){
f0103d08:	83 f8 24             	cmp    $0x24,%eax
f0103d0b:	75 07                	jne    f0103d14 <trap+0x1c2>
		serial_intr();
f0103d0d:	e8 c5 c8 ff ff       	call   f01005d7 <serial_intr>
f0103d12:	eb 43                	jmp    f0103d57 <trap+0x205>
		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	//cprintf("DEBUG-TRAP: Unexpected trap\n");
	print_trapframe(tf);
f0103d14:	83 ec 0c             	sub    $0xc,%esp
f0103d17:	56                   	push   %esi
f0103d18:	e8 8b fb ff ff       	call   f01038a8 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103d1d:	83 c4 10             	add    $0x10,%esp
f0103d20:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103d25:	75 17                	jne    f0103d3e <trap+0x1ec>
		panic("unhandled trap in kernel");
f0103d27:	83 ec 04             	sub    $0x4,%esp
f0103d2a:	68 9a 77 10 f0       	push   $0xf010779a
f0103d2f:	68 1b 01 00 00       	push   $0x11b
f0103d34:	68 51 77 10 f0       	push   $0xf0107751
f0103d39:	e8 02 c3 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0103d3e:	e8 d7 19 00 00       	call   f010571a <cpunum>
f0103d43:	83 ec 0c             	sub    $0xc,%esp
f0103d46:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d49:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0103d4f:	e8 2e f6 ff ff       	call   f0103382 <env_destroy>
f0103d54:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103d57:	e8 be 19 00 00       	call   f010571a <cpunum>
f0103d5c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d5f:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f0103d66:	74 2a                	je     f0103d92 <trap+0x240>
f0103d68:	e8 ad 19 00 00       	call   f010571a <cpunum>
f0103d6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d70:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103d76:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d7a:	75 16                	jne    f0103d92 <trap+0x240>
		env_run(curenv);
f0103d7c:	e8 99 19 00 00       	call   f010571a <cpunum>
f0103d81:	83 ec 0c             	sub    $0xc,%esp
f0103d84:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d87:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0103d8d:	e8 8f f6 ff ff       	call   f0103421 <env_run>
	else
		sched_yield();
f0103d92:	e8 f6 01 00 00       	call   f0103f8d <sched_yield>
f0103d97:	90                   	nop

f0103d98 <handler0>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

# Handlers for process exceptions
TRAPHANDLER_NOEC(handler0, 0)
f0103d98:	6a 00                	push   $0x0
f0103d9a:	6a 00                	push   $0x0
f0103d9c:	e9 03 01 00 00       	jmp    f0103ea4 <_alltraps>
f0103da1:	90                   	nop

f0103da2 <handler1>:
TRAPHANDLER_NOEC(handler1, 1)
f0103da2:	6a 00                	push   $0x0
f0103da4:	6a 01                	push   $0x1
f0103da6:	e9 f9 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103dab:	90                   	nop

f0103dac <handler2>:
TRAPHANDLER_NOEC(handler2, 2)
f0103dac:	6a 00                	push   $0x0
f0103dae:	6a 02                	push   $0x2
f0103db0:	e9 ef 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103db5:	90                   	nop

f0103db6 <handler3>:
TRAPHANDLER_NOEC(handler3, 3)
f0103db6:	6a 00                	push   $0x0
f0103db8:	6a 03                	push   $0x3
f0103dba:	e9 e5 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103dbf:	90                   	nop

f0103dc0 <handler4>:
TRAPHANDLER_NOEC(handler4, 4)
f0103dc0:	6a 00                	push   $0x0
f0103dc2:	6a 04                	push   $0x4
f0103dc4:	e9 db 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103dc9:	90                   	nop

f0103dca <handler5>:
TRAPHANDLER_NOEC(handler5, 5)
f0103dca:	6a 00                	push   $0x0
f0103dcc:	6a 05                	push   $0x5
f0103dce:	e9 d1 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103dd3:	90                   	nop

f0103dd4 <handler6>:
TRAPHANDLER_NOEC(handler6, 6)
f0103dd4:	6a 00                	push   $0x0
f0103dd6:	6a 06                	push   $0x6
f0103dd8:	e9 c7 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103ddd:	90                   	nop

f0103dde <handler7>:
TRAPHANDLER_NOEC(handler7, 7)
f0103dde:	6a 00                	push   $0x0
f0103de0:	6a 07                	push   $0x7
f0103de2:	e9 bd 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103de7:	90                   	nop

f0103de8 <handler8>:
TRAPHANDLER(handler8, 8)
f0103de8:	6a 08                	push   $0x8
f0103dea:	e9 b5 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103def:	90                   	nop

f0103df0 <handler9>:
TRAPHANDLER_NOEC(handler9, 9)
f0103df0:	6a 00                	push   $0x0
f0103df2:	6a 09                	push   $0x9
f0103df4:	e9 ab 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103df9:	90                   	nop

f0103dfa <handler10>:
TRAPHANDLER(handler10, 10)
f0103dfa:	6a 0a                	push   $0xa
f0103dfc:	e9 a3 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103e01:	90                   	nop

f0103e02 <handler11>:
TRAPHANDLER(handler11, 11)
f0103e02:	6a 0b                	push   $0xb
f0103e04:	e9 9b 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103e09:	90                   	nop

f0103e0a <handler12>:
TRAPHANDLER(handler12, 12)
f0103e0a:	6a 0c                	push   $0xc
f0103e0c:	e9 93 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103e11:	90                   	nop

f0103e12 <handler13>:
TRAPHANDLER(handler13, 13)
f0103e12:	6a 0d                	push   $0xd
f0103e14:	e9 8b 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103e19:	90                   	nop

f0103e1a <handler14>:
TRAPHANDLER(handler14, 14)
f0103e1a:	6a 0e                	push   $0xe
f0103e1c:	e9 83 00 00 00       	jmp    f0103ea4 <_alltraps>
f0103e21:	90                   	nop

f0103e22 <handler15>:
TRAPHANDLER_NOEC(handler15, 15)
f0103e22:	6a 00                	push   $0x0
f0103e24:	6a 0f                	push   $0xf
f0103e26:	eb 7c                	jmp    f0103ea4 <_alltraps>

f0103e28 <handler16>:
TRAPHANDLER_NOEC(handler16, 16)
f0103e28:	6a 00                	push   $0x0
f0103e2a:	6a 10                	push   $0x10
f0103e2c:	eb 76                	jmp    f0103ea4 <_alltraps>

f0103e2e <handler17>:
TRAPHANDLER(handler17, 17)
f0103e2e:	6a 11                	push   $0x11
f0103e30:	eb 72                	jmp    f0103ea4 <_alltraps>

f0103e32 <handler18>:
TRAPHANDLER_NOEC(handler18, 18)
f0103e32:	6a 00                	push   $0x0
f0103e34:	6a 12                	push   $0x12
f0103e36:	eb 6c                	jmp    f0103ea4 <_alltraps>

f0103e38 <handler19>:
TRAPHANDLER_NOEC(handler19, 19)
f0103e38:	6a 00                	push   $0x0
f0103e3a:	6a 13                	push   $0x13
f0103e3c:	eb 66                	jmp    f0103ea4 <_alltraps>

f0103e3e <handler_irq0>:

# Handlers for external interrupts
TRAPHANDLER_NOEC(handler_irq0, IRQ_OFFSET + 0)
f0103e3e:	6a 00                	push   $0x0
f0103e40:	6a 20                	push   $0x20
f0103e42:	eb 60                	jmp    f0103ea4 <_alltraps>

f0103e44 <handler_irq1>:
TRAPHANDLER_NOEC(handler_irq1, IRQ_OFFSET + 1)
f0103e44:	6a 00                	push   $0x0
f0103e46:	6a 21                	push   $0x21
f0103e48:	eb 5a                	jmp    f0103ea4 <_alltraps>

f0103e4a <handler_irq2>:
TRAPHANDLER_NOEC(handler_irq2, IRQ_OFFSET + 2)
f0103e4a:	6a 00                	push   $0x0
f0103e4c:	6a 22                	push   $0x22
f0103e4e:	eb 54                	jmp    f0103ea4 <_alltraps>

f0103e50 <handler_irq3>:
TRAPHANDLER_NOEC(handler_irq3, IRQ_OFFSET + 3)
f0103e50:	6a 00                	push   $0x0
f0103e52:	6a 23                	push   $0x23
f0103e54:	eb 4e                	jmp    f0103ea4 <_alltraps>

f0103e56 <handler_irq4>:
TRAPHANDLER_NOEC(handler_irq4, IRQ_OFFSET + 4)
f0103e56:	6a 00                	push   $0x0
f0103e58:	6a 24                	push   $0x24
f0103e5a:	eb 48                	jmp    f0103ea4 <_alltraps>

f0103e5c <handler_irq5>:
TRAPHANDLER_NOEC(handler_irq5, IRQ_OFFSET + 5)
f0103e5c:	6a 00                	push   $0x0
f0103e5e:	6a 25                	push   $0x25
f0103e60:	eb 42                	jmp    f0103ea4 <_alltraps>

f0103e62 <handler_irq6>:
TRAPHANDLER_NOEC(handler_irq6, IRQ_OFFSET + 6)
f0103e62:	6a 00                	push   $0x0
f0103e64:	6a 26                	push   $0x26
f0103e66:	eb 3c                	jmp    f0103ea4 <_alltraps>

f0103e68 <handler_irq7>:
TRAPHANDLER_NOEC(handler_irq7, IRQ_OFFSET + 7)
f0103e68:	6a 00                	push   $0x0
f0103e6a:	6a 27                	push   $0x27
f0103e6c:	eb 36                	jmp    f0103ea4 <_alltraps>

f0103e6e <handler_irq8>:
TRAPHANDLER_NOEC(handler_irq8, IRQ_OFFSET + 8)
f0103e6e:	6a 00                	push   $0x0
f0103e70:	6a 28                	push   $0x28
f0103e72:	eb 30                	jmp    f0103ea4 <_alltraps>

f0103e74 <handler_irq9>:
TRAPHANDLER_NOEC(handler_irq9, IRQ_OFFSET + 9)
f0103e74:	6a 00                	push   $0x0
f0103e76:	6a 29                	push   $0x29
f0103e78:	eb 2a                	jmp    f0103ea4 <_alltraps>

f0103e7a <handler_irq10>:
TRAPHANDLER_NOEC(handler_irq10,IRQ_OFFSET + 10)
f0103e7a:	6a 00                	push   $0x0
f0103e7c:	6a 2a                	push   $0x2a
f0103e7e:	eb 24                	jmp    f0103ea4 <_alltraps>

f0103e80 <handler_irq11>:
TRAPHANDLER_NOEC(handler_irq11,IRQ_OFFSET + 11)
f0103e80:	6a 00                	push   $0x0
f0103e82:	6a 2b                	push   $0x2b
f0103e84:	eb 1e                	jmp    f0103ea4 <_alltraps>

f0103e86 <handler_irq12>:
TRAPHANDLER_NOEC(handler_irq12,IRQ_OFFSET + 12)
f0103e86:	6a 00                	push   $0x0
f0103e88:	6a 2c                	push   $0x2c
f0103e8a:	eb 18                	jmp    f0103ea4 <_alltraps>

f0103e8c <handler_irq13>:
TRAPHANDLER_NOEC(handler_irq13,IRQ_OFFSET + 13)
f0103e8c:	6a 00                	push   $0x0
f0103e8e:	6a 2d                	push   $0x2d
f0103e90:	eb 12                	jmp    f0103ea4 <_alltraps>

f0103e92 <handler_irq14>:
TRAPHANDLER_NOEC(handler_irq14,IRQ_OFFSET + 14)
f0103e92:	6a 00                	push   $0x0
f0103e94:	6a 2e                	push   $0x2e
f0103e96:	eb 0c                	jmp    f0103ea4 <_alltraps>

f0103e98 <handler_irq15>:
TRAPHANDLER_NOEC(handler_irq15,IRQ_OFFSET + 15)
f0103e98:	6a 00                	push   $0x0
f0103e9a:	6a 2f                	push   $0x2f
f0103e9c:	eb 06                	jmp    f0103ea4 <_alltraps>

f0103e9e <handler_syscall>:

# For system call
TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f0103e9e:	6a 00                	push   $0x0
f0103ea0:	6a 30                	push   $0x30
f0103ea2:	eb 00                	jmp    f0103ea4 <_alltraps>

f0103ea4 <_alltraps>:
 */
// TODO: Replace mov with movw
.globl _alltraps
_alltraps:
	# Push values to make the stack look like a struct Trapframe
	pushl %ds
f0103ea4:	1e                   	push   %ds
	pushl %es
f0103ea5:	06                   	push   %es
	pushal
f0103ea6:	60                   	pusha  

	# Load GD_KD into %ds and %es
	mov $GD_KD, %eax
f0103ea7:	b8 10 00 00 00       	mov    $0x10,%eax
	mov %ax, %ds
f0103eac:	8e d8                	mov    %eax,%ds
	mov %ax, %es
f0103eae:	8e c0                	mov    %eax,%es

	# Call trap(tf), where tf=%esp
	pushl %esp
f0103eb0:	54                   	push   %esp
	call trap
f0103eb1:	e8 9c fc ff ff       	call   f0103b52 <trap>
	addl $4, %esp
f0103eb6:	83 c4 04             	add    $0x4,%esp

f0103eb9 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0103eb9:	55                   	push   %ebp
f0103eba:	89 e5                	mov    %esp,%ebp
f0103ebc:	83 ec 08             	sub    $0x8,%esp
f0103ebf:	a1 48 f2 29 f0       	mov    0xf029f248,%eax
f0103ec4:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103ec7:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103ecc:	8b 02                	mov    (%edx),%eax
f0103ece:	83 e8 01             	sub    $0x1,%eax
f0103ed1:	83 f8 02             	cmp    $0x2,%eax
f0103ed4:	76 10                	jbe    f0103ee6 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103ed6:	83 c1 01             	add    $0x1,%ecx
f0103ed9:	83 c2 7c             	add    $0x7c,%edx
f0103edc:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103ee2:	75 e8                	jne    f0103ecc <sched_halt+0x13>
f0103ee4:	eb 08                	jmp    f0103eee <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0103ee6:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103eec:	75 1f                	jne    f0103f0d <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0103eee:	83 ec 0c             	sub    $0xc,%esp
f0103ef1:	68 70 79 10 f0       	push   $0xf0107970
f0103ef6:	e8 56 f7 ff ff       	call   f0103651 <cprintf>
f0103efb:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103efe:	83 ec 0c             	sub    $0xc,%esp
f0103f01:	6a 00                	push   $0x0
f0103f03:	e8 df c9 ff ff       	call   f01008e7 <monitor>
f0103f08:	83 c4 10             	add    $0x10,%esp
f0103f0b:	eb f1                	jmp    f0103efe <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0103f0d:	e8 08 18 00 00       	call   f010571a <cpunum>
f0103f12:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f15:	c7 80 28 00 2a f0 00 	movl   $0x0,-0xfd5ffd8(%eax)
f0103f1c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0103f1f:	a1 98 fe 29 f0       	mov    0xf029fe98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f24:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f29:	77 12                	ja     f0103f3d <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f2b:	50                   	push   %eax
f0103f2c:	68 68 63 10 f0       	push   $0xf0106368
f0103f31:	6a 5a                	push   $0x5a
f0103f33:	68 99 79 10 f0       	push   $0xf0107999
f0103f38:	e8 03 c1 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103f3d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103f42:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0103f45:	e8 d0 17 00 00       	call   f010571a <cpunum>
f0103f4a:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f4d:	81 c2 20 00 2a f0    	add    $0xf02a0020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103f53:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f58:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103f5c:	83 ec 0c             	sub    $0xc,%esp
f0103f5f:	68 60 24 12 f0       	push   $0xf0122460
f0103f64:	e8 bc 1a 00 00       	call   f0105a25 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103f69:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0103f6b:	e8 aa 17 00 00       	call   f010571a <cpunum>
f0103f70:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0103f73:	8b 80 30 00 2a f0    	mov    -0xfd5ffd0(%eax),%eax
f0103f79:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103f7e:	89 c4                	mov    %eax,%esp
f0103f80:	6a 00                	push   $0x0
f0103f82:	6a 00                	push   $0x0
f0103f84:	fb                   	sti    
f0103f85:	f4                   	hlt    
f0103f86:	eb fd                	jmp    f0103f85 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0103f88:	83 c4 10             	add    $0x10,%esp
f0103f8b:	c9                   	leave  
f0103f8c:	c3                   	ret    

f0103f8d <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0103f8d:	55                   	push   %ebp
f0103f8e:	89 e5                	mov    %esp,%ebp
f0103f90:	53                   	push   %ebx
f0103f91:	83 ec 04             	sub    $0x4,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.
	//cprintf("DEBUG-SCHED: CPU %d - In scheduler, curenv = %p\n", cpunum(), curenv);
	struct Env *e;
	if (curenv) {
f0103f94:	e8 81 17 00 00       	call   f010571a <cpunum>
f0103f99:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f9c:	83 b8 28 00 2a f0 00 	cmpl   $0x0,-0xfd5ffd8(%eax)
f0103fa3:	0f 84 83 00 00 00    	je     f010402c <sched_yield+0x9f>
		for (e = curenv + 1; e < envs + NENV; e++) {
f0103fa9:	e8 6c 17 00 00       	call   f010571a <cpunum>
f0103fae:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb1:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0103fb7:	83 c0 7c             	add    $0x7c,%eax
f0103fba:	8b 1d 48 f2 29 f0    	mov    0xf029f248,%ebx
f0103fc0:	8d 93 00 f0 01 00    	lea    0x1f000(%ebx),%edx
f0103fc6:	eb 12                	jmp    f0103fda <sched_yield+0x4d>
			if (e->env_status == ENV_RUNNABLE) {
f0103fc8:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0103fcc:	75 09                	jne    f0103fd7 <sched_yield+0x4a>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
f0103fce:	83 ec 0c             	sub    $0xc,%esp
f0103fd1:	50                   	push   %eax
f0103fd2:	e8 4a f4 ff ff       	call   f0103421 <env_run>

	// LAB 4: Your code here.
	//cprintf("DEBUG-SCHED: CPU %d - In scheduler, curenv = %p\n", cpunum(), curenv);
	struct Env *e;
	if (curenv) {
		for (e = curenv + 1; e < envs + NENV; e++) {
f0103fd7:	83 c0 7c             	add    $0x7c,%eax
f0103fda:	39 d0                	cmp    %edx,%eax
f0103fdc:	72 ea                	jb     f0103fc8 <sched_yield+0x3b>
f0103fde:	eb 12                	jmp    f0103ff2 <sched_yield+0x65>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
			}
		}
		for (e = envs; e < curenv; e++) {
			if (e->env_status == ENV_RUNNABLE) {
f0103fe0:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0103fe4:	75 09                	jne    f0103fef <sched_yield+0x62>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
f0103fe6:	83 ec 0c             	sub    $0xc,%esp
f0103fe9:	53                   	push   %ebx
f0103fea:	e8 32 f4 ff ff       	call   f0103421 <env_run>
			if (e->env_status == ENV_RUNNABLE) {
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
			}
		}
		for (e = envs; e < curenv; e++) {
f0103fef:	83 c3 7c             	add    $0x7c,%ebx
f0103ff2:	e8 23 17 00 00       	call   f010571a <cpunum>
f0103ff7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ffa:	3b 98 28 00 2a f0    	cmp    -0xfd5ffd8(%eax),%ebx
f0104000:	72 de                	jb     f0103fe0 <sched_yield+0x53>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
			}
		}
		// If didn't find any runnable, try to keep running curenv
		if (curenv->env_status == ENV_RUNNING) {
f0104002:	e8 13 17 00 00       	call   f010571a <cpunum>
f0104007:	6b c0 74             	imul   $0x74,%eax,%eax
f010400a:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0104010:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104014:	75 39                	jne    f010404f <sched_yield+0xc2>
			//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), curenv);
			env_run(curenv);
f0104016:	e8 ff 16 00 00       	call   f010571a <cpunum>
f010401b:	83 ec 0c             	sub    $0xc,%esp
f010401e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104021:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f0104027:	e8 f5 f3 ff ff       	call   f0103421 <env_run>
		}
	} else {
		for (e = envs; e < envs + NENV; e++) {
f010402c:	a1 48 f2 29 f0       	mov    0xf029f248,%eax
f0104031:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f0104037:	eb 12                	jmp    f010404b <sched_yield+0xbe>
			if (e->env_status == ENV_RUNNABLE) {
f0104039:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010403d:	75 09                	jne    f0104048 <sched_yield+0xbb>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
f010403f:	83 ec 0c             	sub    $0xc,%esp
f0104042:	50                   	push   %eax
f0104043:	e8 d9 f3 ff ff       	call   f0103421 <env_run>
		if (curenv->env_status == ENV_RUNNING) {
			//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), curenv);
			env_run(curenv);
		}
	} else {
		for (e = envs; e < envs + NENV; e++) {
f0104048:	83 c0 7c             	add    $0x7c,%eax
f010404b:	39 d0                	cmp    %edx,%eax
f010404d:	75 ea                	jne    f0104039 <sched_yield+0xac>
		}
	}

	// sched_halt never returns
	//cprintf("DEBUG-SCHED: CPU %d: no env to run found\n", cpunum());
	sched_halt();
f010404f:	e8 65 fe ff ff       	call   f0103eb9 <sched_halt>
}
f0104054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104057:	c9                   	leave  
f0104058:	c3                   	ret    

f0104059 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104059:	55                   	push   %ebp
f010405a:	89 e5                	mov    %esp,%ebp
f010405c:	57                   	push   %edi
f010405d:	56                   	push   %esi
f010405e:	53                   	push   %ebx
f010405f:	83 ec 1c             	sub    $0x1c,%esp
f0104062:	8b 45 08             	mov    0x8(%ebp),%eax
	// panic("syscall not implemented");

	int32_t ret = 0;

	// TODO: Remove debugging printings
	switch (syscallno) {
f0104065:	83 f8 0e             	cmp    $0xe,%eax
f0104068:	0f 87 9c 05 00 00    	ja     f010460a <syscall+0x5b1>
f010406e:	ff 24 85 ac 79 10 f0 	jmp    *-0xfef8654(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0104075:	e8 a0 16 00 00       	call   f010571a <cpunum>
f010407a:	6a 00                	push   $0x0
f010407c:	ff 75 10             	pushl  0x10(%ebp)
f010407f:	ff 75 0c             	pushl  0xc(%ebp)
f0104082:	6b c0 74             	imul   $0x74,%eax,%eax
f0104085:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f010408b:	e8 7d ed ff ff       	call   f0102e0d <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104090:	83 c4 0c             	add    $0xc,%esp
f0104093:	ff 75 0c             	pushl  0xc(%ebp)
f0104096:	ff 75 10             	pushl  0x10(%ebp)
f0104099:	68 a6 79 10 f0       	push   $0xf01079a6
f010409e:	e8 ae f5 ff ff       	call   f0103651 <cprintf>
f01040a3:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	int32_t ret = 0;
f01040a6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01040ab:	e9 66 05 00 00       	jmp    f0104616 <syscall+0x5bd>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01040b0:	e8 50 c5 ff ff       	call   f0100605 <cons_getc>
f01040b5:	89 c3                	mov    %eax,%ebx
		sys_cputs((char *) a1, (size_t) a2);
		break;
	case SYS_cgetc:
		//cprintf("DEBUG-SYSCALL: Calling sys_cgetc!\n");
		ret = sys_cgetc();
		break;
f01040b7:	e9 5a 05 00 00       	jmp    f0104616 <syscall+0x5bd>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01040bc:	e8 59 16 00 00       	call   f010571a <cpunum>
f01040c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01040c4:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01040ca:	8b 58 48             	mov    0x48(%eax),%ebx
		ret = sys_cgetc();
		break;
	case SYS_getenvid:
		//cprintf("DEBUG-SYSCALL: Calling sys_getenvid!\n");
		ret = (int32_t) sys_getenvid();
		break;
f01040cd:	e9 44 05 00 00       	jmp    f0104616 <syscall+0x5bd>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01040d2:	83 ec 04             	sub    $0x4,%esp
f01040d5:	6a 01                	push   $0x1
f01040d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01040da:	50                   	push   %eax
f01040db:	ff 75 0c             	pushl  0xc(%ebp)
f01040de:	e8 d1 ed ff ff       	call   f0102eb4 <envid2env>
f01040e3:	83 c4 10             	add    $0x10,%esp
		return r;
f01040e6:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01040e8:	85 c0                	test   %eax,%eax
f01040ea:	0f 88 26 05 00 00    	js     f0104616 <syscall+0x5bd>
		return r;
	env_destroy(e);
f01040f0:	83 ec 0c             	sub    $0xc,%esp
f01040f3:	ff 75 e4             	pushl  -0x1c(%ebp)
f01040f6:	e8 87 f2 ff ff       	call   f0103382 <env_destroy>
f01040fb:	83 c4 10             	add    $0x10,%esp
	return 0;
f01040fe:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104103:	e9 0e 05 00 00       	jmp    f0104616 <syscall+0x5bd>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104108:	e8 80 fe ff ff       	call   f0103f8d <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	// Tries to allocate new env in e
	struct Env *e;
	int error = env_alloc(&e, curenv->env_id);
f010410d:	e8 08 16 00 00       	call   f010571a <cpunum>
f0104112:	83 ec 08             	sub    $0x8,%esp
f0104115:	6b c0 74             	imul   $0x74,%eax,%eax
f0104118:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f010411e:	ff 70 48             	pushl  0x48(%eax)
f0104121:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104124:	50                   	push   %eax
f0104125:	e8 9c ee ff ff       	call   f0102fc6 <env_alloc>
	// Check if it failed, and pass the error. Can be -E_NO_FREE_ENV or -E_NO_MEM
	if (error < 0) {
f010412a:	83 c4 10             	add    $0x10,%esp
		return error;
f010412d:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
	// Tries to allocate new env in e
	struct Env *e;
	int error = env_alloc(&e, curenv->env_id);
	// Check if it failed, and pass the error. Can be -E_NO_FREE_ENV or -E_NO_MEM
	if (error < 0) {
f010412f:	85 c0                	test   %eax,%eax
f0104131:	0f 88 df 04 00 00    	js     f0104616 <syscall+0x5bd>
		return error;
	}

	e->env_status = ENV_NOT_RUNNABLE;
f0104137:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010413a:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf; // trap() has copied the tf that is on kstack to curenv
f0104141:	e8 d4 15 00 00       	call   f010571a <cpunum>
f0104146:	6b c0 74             	imul   $0x74,%eax,%eax
f0104149:	8b b0 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%esi
f010414f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104154:	89 df                	mov    %ebx,%edi
f0104156:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

	// Tweak the tf so sys_exofork will appear to return 0.
	// eax holds the return value of the system call, so just make it zero.
	e->env_tf.tf_regs.reg_eax = 0;
f0104158:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010415b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return e->env_id;
f0104162:	8b 58 48             	mov    0x48(%eax),%ebx
f0104165:	e9 ac 04 00 00       	jmp    f0104616 <syscall+0x5bd>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	// Check if the status is valid
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f010416a:	8b 45 10             	mov    0x10(%ebp),%eax
f010416d:	83 e8 02             	sub    $0x2,%eax
f0104170:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104175:	75 2b                	jne    f01041a2 <syscall+0x149>
		return -E_INVAL;
	}

	// Tries to retrieve the env
	struct Env *e;
	int error = envid2env(envid, &e, 1);
f0104177:	83 ec 04             	sub    $0x4,%esp
f010417a:	6a 01                	push   $0x1
f010417c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010417f:	50                   	push   %eax
f0104180:	ff 75 0c             	pushl  0xc(%ebp)
f0104183:	e8 2c ed ff ff       	call   f0102eb4 <envid2env>
	if (error < 0) { // If error <0, it is -E_BAD_ENV
f0104188:	83 c4 10             	add    $0x10,%esp
f010418b:	85 c0                	test   %eax,%eax
f010418d:	78 1d                	js     f01041ac <syscall+0x153>
		return error;
	}

	// Set the environment status
	e->env_status = status;
f010418f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104192:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104195:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0104198:	bb 00 00 00 00       	mov    $0x0,%ebx
f010419d:	e9 74 04 00 00       	jmp    f0104616 <syscall+0x5bd>
	// envid's status.

	// LAB 4: Your code here.
	// Check if the status is valid
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
		return -E_INVAL;
f01041a2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01041a7:	e9 6a 04 00 00       	jmp    f0104616 <syscall+0x5bd>

	// Tries to retrieve the env
	struct Env *e;
	int error = envid2env(envid, &e, 1);
	if (error < 0) { // If error <0, it is -E_BAD_ENV
		return error;
f01041ac:	89 c3                	mov    %eax,%ebx
		ret = (int32_t) sys_exofork();
		break;
	case SYS_env_set_status:
		//cprintf("DEBUG-SYSCALL: Calling sys_env_set_status!\n");
		ret = (int32_t) sys_env_set_status((envid_t) a1, (int) a2);
		break;
f01041ae:	e9 63 04 00 00       	jmp    f0104616 <syscall+0x5bd>
	//   allocated!

	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
f01041b3:	83 ec 04             	sub    $0x4,%esp
f01041b6:	6a 01                	push   $0x1
f01041b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01041bb:	50                   	push   %eax
f01041bc:	ff 75 0c             	pushl  0xc(%ebp)
f01041bf:	e8 f0 ec ff ff       	call   f0102eb4 <envid2env>
	if (!e) {
f01041c4:	83 c4 10             	add    $0x10,%esp
f01041c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01041cb:	74 69                	je     f0104236 <syscall+0x1dd>
		return -E_BAD_ENV;
	}

	// Checks if va is as expected
	if (((uint32_t)va >= UTOP) || ((uint32_t) va)%PGSIZE != 0) {
f01041cd:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01041d4:	77 6a                	ja     f0104240 <syscall+0x1e7>
f01041d6:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01041dd:	75 6b                	jne    f010424a <syscall+0x1f1>
		return -E_INVAL;
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||   // No bit out of PTE_SYSCALL allowed
f01041df:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01041e2:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f01041e8:	75 6a                	jne    f0104254 <syscall+0x1fb>
f01041ea:	f6 45 14 05          	testb  $0x5,0x14(%ebp)
f01041ee:	74 6e                	je     f010425e <syscall+0x205>
	    (perm & (PTE_U | PTE_P)) == 0) {  // These bits must be set
		return -E_INVAL;
	}

	// Tries to allocate a physical page
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f01041f0:	83 ec 0c             	sub    $0xc,%esp
f01041f3:	6a 01                	push   $0x1
f01041f5:	e8 ea cc ff ff       	call   f0100ee4 <page_alloc>
f01041fa:	89 c6                	mov    %eax,%esi
	if (!pp) {
f01041fc:	83 c4 10             	add    $0x10,%esp
f01041ff:	85 c0                	test   %eax,%eax
f0104201:	74 65                	je     f0104268 <syscall+0x20f>
		return -E_NO_MEM;
	}

	// Tries to map the physical page at va
	int error = page_insert(e->env_pgdir, pp, va, perm);
f0104203:	ff 75 14             	pushl  0x14(%ebp)
f0104206:	ff 75 10             	pushl  0x10(%ebp)
f0104209:	50                   	push   %eax
f010420a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010420d:	ff 70 60             	pushl  0x60(%eax)
f0104210:	e8 0d d0 ff ff       	call   f0101222 <page_insert>
	if (error < 0) {
f0104215:	83 c4 10             	add    $0x10,%esp
f0104218:	85 c0                	test   %eax,%eax
f010421a:	0f 89 f6 03 00 00    	jns    f0104616 <syscall+0x5bd>
		page_free(pp);
f0104220:	83 ec 0c             	sub    $0xc,%esp
f0104223:	56                   	push   %esi
f0104224:	e8 2b cd ff ff       	call   f0100f54 <page_free>
f0104229:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f010422c:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104231:	e9 e0 03 00 00       	jmp    f0104616 <syscall+0x5bd>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
	if (!e) {
		return -E_BAD_ENV;
f0104236:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010423b:	e9 d6 03 00 00       	jmp    f0104616 <syscall+0x5bd>
	}

	// Checks if va is as expected
	if (((uint32_t)va >= UTOP) || ((uint32_t) va)%PGSIZE != 0) {
		return -E_INVAL;
f0104240:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104245:	e9 cc 03 00 00       	jmp    f0104616 <syscall+0x5bd>
f010424a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010424f:	e9 c2 03 00 00       	jmp    f0104616 <syscall+0x5bd>
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||   // No bit out of PTE_SYSCALL allowed
	    (perm & (PTE_U | PTE_P)) == 0) {  // These bits must be set
		return -E_INVAL;
f0104254:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104259:	e9 b8 03 00 00       	jmp    f0104616 <syscall+0x5bd>
f010425e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104263:	e9 ae 03 00 00       	jmp    f0104616 <syscall+0x5bd>
	}

	// Tries to allocate a physical page
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if (!pp) {
		return -E_NO_MEM;
f0104268:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		ret = (int32_t) sys_env_set_status((envid_t) a1, (int) a2);
		break;
	case SYS_page_alloc:
		//cprintf("DEBUG-SYSCALL: Calling sys_page_alloc!\n");
		ret = (int32_t) sys_page_alloc((envid_t) a1, (void *) a2, (int) a3);
		break;
f010426d:	e9 a4 03 00 00       	jmp    f0104616 <syscall+0x5bd>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// Tries to retrieve the environments
	struct Env *srcenv, *dstenv;
	envid2env(srcenvid, &srcenv, 1);
f0104272:	83 ec 04             	sub    $0x4,%esp
f0104275:	6a 01                	push   $0x1
f0104277:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010427a:	50                   	push   %eax
f010427b:	ff 75 0c             	pushl  0xc(%ebp)
f010427e:	e8 31 ec ff ff       	call   f0102eb4 <envid2env>
	envid2env(dstenvid, &dstenv, 1);
f0104283:	83 c4 0c             	add    $0xc,%esp
f0104286:	6a 01                	push   $0x1
f0104288:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010428b:	50                   	push   %eax
f010428c:	ff 75 14             	pushl  0x14(%ebp)
f010428f:	e8 20 ec ff ff       	call   f0102eb4 <envid2env>
	if (!srcenv || !dstenv) {
f0104294:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104297:	83 c4 10             	add    $0x10,%esp
f010429a:	85 c0                	test   %eax,%eax
f010429c:	0f 84 9a 00 00 00    	je     f010433c <syscall+0x2e3>
f01042a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01042a6:	0f 84 9a 00 00 00    	je     f0104346 <syscall+0x2ed>
		return -E_BAD_ENV;
	}

	// Checks if va's are as expected
	if (((uint32_t)srcva) >= UTOP || ((uint32_t) srcva)%PGSIZE != 0 ||
f01042ac:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01042b3:	0f 87 97 00 00 00    	ja     f0104350 <syscall+0x2f7>
f01042b9:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01042c0:	0f 85 94 00 00 00    	jne    f010435a <syscall+0x301>
f01042c6:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01042cd:	0f 87 87 00 00 00    	ja     f010435a <syscall+0x301>
	    ((uint32_t)dstva) >= UTOP || ((uint32_t) dstva)%PGSIZE != 0) {
f01042d3:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01042da:	0f 85 84 00 00 00    	jne    f0104364 <syscall+0x30b>
	}

	// Lookup for the physical page that is mapped at srcva
	// If srcva is not mapped in srcenv address space, pp is null
	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f01042e0:	83 ec 04             	sub    $0x4,%esp
f01042e3:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01042e6:	52                   	push   %edx
f01042e7:	ff 75 10             	pushl  0x10(%ebp)
f01042ea:	ff 70 60             	pushl  0x60(%eax)
f01042ed:	e8 4a ce ff ff       	call   f010113c <page_lookup>
	if (!pp) {
f01042f2:	83 c4 10             	add    $0x10,%esp
f01042f5:	85 c0                	test   %eax,%eax
f01042f7:	74 75                	je     f010436e <syscall+0x315>
		return -E_INVAL;
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||
f01042f9:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f01042fc:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104302:	75 74                	jne    f0104378 <syscall+0x31f>
f0104304:	f6 45 1c 05          	testb  $0x5,0x1c(%ebp)
f0104308:	74 78                	je     f0104382 <syscall+0x329>
		return -E_INVAL;
	}

	// Checks if srcva is read-only in srcenv, and it is trying to
	// permit writing in dstenv
	if (!(*pte & PTE_W) && (perm & PTE_W)) {
f010430a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010430d:	f6 02 02             	testb  $0x2,(%edx)
f0104310:	75 06                	jne    f0104318 <syscall+0x2bf>
f0104312:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104316:	75 74                	jne    f010438c <syscall+0x333>
		return -E_INVAL;
	}

	// Tries to map the physical page at dstva on dstenv address space
	// Fails if there is no memory to allocate a page table, if needed
	int error = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f0104318:	ff 75 1c             	pushl  0x1c(%ebp)
f010431b:	ff 75 18             	pushl  0x18(%ebp)
f010431e:	50                   	push   %eax
f010431f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104322:	ff 70 60             	pushl  0x60(%eax)
f0104325:	e8 f8 ce ff ff       	call   f0101222 <page_insert>
	if (error < 0) {
f010432a:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f010432d:	85 c0                	test   %eax,%eax
f010432f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104334:	0f 48 d8             	cmovs  %eax,%ebx
f0104337:	e9 da 02 00 00       	jmp    f0104616 <syscall+0x5bd>
	// Tries to retrieve the environments
	struct Env *srcenv, *dstenv;
	envid2env(srcenvid, &srcenv, 1);
	envid2env(dstenvid, &dstenv, 1);
	if (!srcenv || !dstenv) {
		return -E_BAD_ENV;
f010433c:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104341:	e9 d0 02 00 00       	jmp    f0104616 <syscall+0x5bd>
f0104346:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010434b:	e9 c6 02 00 00       	jmp    f0104616 <syscall+0x5bd>
	}

	// Checks if va's are as expected
	if (((uint32_t)srcva) >= UTOP || ((uint32_t) srcva)%PGSIZE != 0 ||
	    ((uint32_t)dstva) >= UTOP || ((uint32_t) dstva)%PGSIZE != 0) {
		return -E_INVAL;
f0104350:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104355:	e9 bc 02 00 00       	jmp    f0104616 <syscall+0x5bd>
f010435a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010435f:	e9 b2 02 00 00       	jmp    f0104616 <syscall+0x5bd>
f0104364:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104369:	e9 a8 02 00 00       	jmp    f0104616 <syscall+0x5bd>
	// Lookup for the physical page that is mapped at srcva
	// If srcva is not mapped in srcenv address space, pp is null
	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (!pp) {
		return -E_INVAL;
f010436e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104373:	e9 9e 02 00 00       	jmp    f0104616 <syscall+0x5bd>
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||
	    (perm & (PTE_U | PTE_P)) == 0) {
		return -E_INVAL;
f0104378:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010437d:	e9 94 02 00 00       	jmp    f0104616 <syscall+0x5bd>
f0104382:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104387:	e9 8a 02 00 00       	jmp    f0104616 <syscall+0x5bd>
	}

	// Checks if srcva is read-only in srcenv, and it is trying to
	// permit writing in dstenv
	if (!(*pte & PTE_W) && (perm & PTE_W)) {
		return -E_INVAL;
f010438c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104391:	e9 80 02 00 00       	jmp    f0104616 <syscall+0x5bd>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
f0104396:	83 ec 04             	sub    $0x4,%esp
f0104399:	6a 01                	push   $0x1
f010439b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010439e:	50                   	push   %eax
f010439f:	ff 75 0c             	pushl  0xc(%ebp)
f01043a2:	e8 0d eb ff ff       	call   f0102eb4 <envid2env>
	if (!e) {
f01043a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043aa:	83 c4 10             	add    $0x10,%esp
f01043ad:	85 c0                	test   %eax,%eax
f01043af:	74 2d                	je     f01043de <syscall+0x385>
		return -E_BAD_ENV;
	}

	// Checks if va is as expected
	if (((uint32_t)va) >= UTOP || ((uint32_t) va)%PGSIZE != 0) {
f01043b1:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01043b8:	77 2e                	ja     f01043e8 <syscall+0x38f>
f01043ba:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01043c1:	75 2f                	jne    f01043f2 <syscall+0x399>
		return -E_INVAL;
	}

	// Removes page
	page_remove(e->env_pgdir, va);
f01043c3:	83 ec 08             	sub    $0x8,%esp
f01043c6:	ff 75 10             	pushl  0x10(%ebp)
f01043c9:	ff 70 60             	pushl  0x60(%eax)
f01043cc:	e8 0b ce ff ff       	call   f01011dc <page_remove>
f01043d1:	83 c4 10             	add    $0x10,%esp
	return 0;
f01043d4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01043d9:	e9 38 02 00 00       	jmp    f0104616 <syscall+0x5bd>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
	if (!e) {
		return -E_BAD_ENV;
f01043de:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01043e3:	e9 2e 02 00 00       	jmp    f0104616 <syscall+0x5bd>
	}

	// Checks if va is as expected
	if (((uint32_t)va) >= UTOP || ((uint32_t) va)%PGSIZE != 0) {
		return -E_INVAL;
f01043e8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01043ed:	e9 24 02 00 00       	jmp    f0104616 <syscall+0x5bd>
f01043f2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
					     (envid_t) a3, (void *) a4, (int) a5);
		break;
	case SYS_page_unmap:
		//cprintf("DEBUG-SYSCALL: Calling sys_page_unmap!\n");
		ret = (int32_t) sys_page_unmap((envid_t) a1, (void *) a2);
		break;
f01043f7:	e9 1a 02 00 00       	jmp    f0104616 <syscall+0x5bd>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
f01043fc:	83 ec 04             	sub    $0x4,%esp
f01043ff:	6a 01                	push   $0x1
f0104401:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104404:	50                   	push   %eax
f0104405:	ff 75 0c             	pushl  0xc(%ebp)
f0104408:	e8 a7 ea ff ff       	call   f0102eb4 <envid2env>
	if (!e) {
f010440d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104410:	83 c4 10             	add    $0x10,%esp
f0104413:	85 c0                	test   %eax,%eax
f0104415:	74 10                	je     f0104427 <syscall+0x3ce>
		return -E_BAD_ENV;
	}

	// Set the page fault upcall
	e->env_pgfault_upcall = func;
f0104417:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010441a:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0;
f010441d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104422:	e9 ef 01 00 00       	jmp    f0104616 <syscall+0x5bd>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
	if (!e) {
		return -E_BAD_ENV;
f0104427:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		ret = (int32_t) sys_page_unmap((envid_t) a1, (void *) a2);
		break;
	case SYS_env_set_pgfault_upcall:
		//cprintf("DEBUG-SYSCALL: Calling sys_env_set_pgfault_upcall!\n");
		ret = (int32_t) sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
		break;
f010442c:	e9 e5 01 00 00       	jmp    f0104616 <syscall+0x5bd>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 0); // Set to 0: can send to anyone
f0104431:	83 ec 04             	sub    $0x4,%esp
f0104434:	6a 00                	push   $0x0
f0104436:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104439:	50                   	push   %eax
f010443a:	ff 75 0c             	pushl  0xc(%ebp)
f010443d:	e8 72 ea ff ff       	call   f0102eb4 <envid2env>
	if (!e) {
f0104442:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104445:	83 c4 10             	add    $0x10,%esp
f0104448:	85 c0                	test   %eax,%eax
f010444a:	0f 84 fa 00 00 00    	je     f010454a <syscall+0x4f1>
		return -E_BAD_ENV;
	}

	// Checks if the receiver is receiving
	if (!e->env_ipc_recving) {
f0104450:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104454:	0f 84 fa 00 00 00    	je     f0104554 <syscall+0x4fb>
		return -E_IPC_NOT_RECV;
	}

	// If the receiver is accepting a page
	// and the sender is trying to send a page
	if (((uint32_t) e->env_ipc_dstva) < UTOP && ((uint32_t) srcva) < UTOP) {
f010445a:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f0104461:	0f 87 a7 00 00 00    	ja     f010450e <syscall+0x4b5>
f0104467:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f010446e:	0f 87 9a 00 00 00    	ja     f010450e <syscall+0x4b5>
		// Checks if va is page aligned
		if (((uint32_t) srcva) % PGSIZE != 0)
			return -E_INVAL;
f0104474:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx

	// If the receiver is accepting a page
	// and the sender is trying to send a page
	if (((uint32_t) e->env_ipc_dstva) < UTOP && ((uint32_t) srcva) < UTOP) {
		// Checks if va is page aligned
		if (((uint32_t) srcva) % PGSIZE != 0)
f0104479:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104480:	0f 85 90 01 00 00    	jne    f0104616 <syscall+0x5bd>
			return -E_INVAL;

		// Checks if permission is appropiate
		if ((perm & (~PTE_SYSCALL)) != 0 ||   // No bit out of PTE_SYSCALL allowed
f0104486:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f010448d:	0f 85 83 01 00 00    	jne    f0104616 <syscall+0x5bd>
f0104493:	f6 45 18 05          	testb  $0x5,0x18(%ebp)
f0104497:	0f 84 79 01 00 00    	je     f0104616 <syscall+0x5bd>
		}

		// Lookup for the physical page that is mapped at srcva
		// If srcva is not mapped in srcenv address space, pp is null
		pte_t *pte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f010449d:	e8 78 12 00 00       	call   f010571a <cpunum>
f01044a2:	83 ec 04             	sub    $0x4,%esp
f01044a5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01044a8:	52                   	push   %edx
f01044a9:	ff 75 14             	pushl  0x14(%ebp)
f01044ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01044af:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01044b5:	ff 70 60             	pushl  0x60(%eax)
f01044b8:	e8 7f cc ff ff       	call   f010113c <page_lookup>
		if (!pp) {
f01044bd:	83 c4 10             	add    $0x10,%esp
f01044c0:	85 c0                	test   %eax,%eax
f01044c2:	74 36                	je     f01044fa <syscall+0x4a1>
			return -E_INVAL;
		}

		// Checks if srcva is read-only in srcenv, and it is trying to
		// permit writing in dstva
		if (!(*pte & PTE_W) && (perm & PTE_W)) {
f01044c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01044c7:	f6 02 02             	testb  $0x2,(%edx)
f01044ca:	75 0a                	jne    f01044d6 <syscall+0x47d>
f01044cc:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01044d0:	0f 85 40 01 00 00    	jne    f0104616 <syscall+0x5bd>
			return -E_INVAL;
		}

		// Tries to map the physical page at dstva on dstenv address space
		// Fails if there is no memory to allocate a page table, if needed
		int error = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm);
f01044d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01044d9:	ff 75 18             	pushl  0x18(%ebp)
f01044dc:	ff 72 6c             	pushl  0x6c(%edx)
f01044df:	50                   	push   %eax
f01044e0:	ff 72 60             	pushl  0x60(%edx)
f01044e3:	e8 3a cd ff ff       	call   f0101222 <page_insert>
		if (error < 0) {
f01044e8:	83 c4 10             	add    $0x10,%esp
f01044eb:	85 c0                	test   %eax,%eax
f01044ed:	78 15                	js     f0104504 <syscall+0x4ab>
			return -E_NO_MEM;
		}

		// Page successfully transfered
		e->env_ipc_perm = perm;
f01044ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01044f2:	8b 55 18             	mov    0x18(%ebp),%edx
f01044f5:	89 50 78             	mov    %edx,0x78(%eax)
f01044f8:	eb 1b                	jmp    f0104515 <syscall+0x4bc>
		// Lookup for the physical page that is mapped at srcva
		// If srcva is not mapped in srcenv address space, pp is null
		pte_t *pte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pp) {
			return -E_INVAL;
f01044fa:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044ff:	e9 12 01 00 00       	jmp    f0104616 <syscall+0x5bd>

		// Tries to map the physical page at dstva on dstenv address space
		// Fails if there is no memory to allocate a page table, if needed
		int error = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm);
		if (error < 0) {
			return -E_NO_MEM;
f0104504:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104509:	e9 08 01 00 00       	jmp    f0104616 <syscall+0x5bd>

		// Page successfully transfered
		e->env_ipc_perm = perm;
	} else {
	// The receiver isn't accepting a page
		e->env_ipc_perm = 0;
f010450e:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	}

	// Deliver 'value' to the receiver
	e->env_ipc_recving = 0;
f0104515:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104518:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f010451c:	e8 f9 11 00 00       	call   f010571a <cpunum>
f0104521:	6b c0 74             	imul   $0x74,%eax,%eax
f0104524:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f010452a:	8b 40 48             	mov    0x48(%eax),%eax
f010452d:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f0104530:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104533:	8b 55 10             	mov    0x10(%ebp),%edx
f0104536:	89 50 70             	mov    %edx,0x70(%eax)

	// The receiver has successfully received. Make it runnable
	e->env_status = ENV_RUNNABLE;
f0104539:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f0104540:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104545:	e9 cc 00 00 00       	jmp    f0104616 <syscall+0x5bd>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 0); // Set to 0: can send to anyone
	if (!e) {
		return -E_BAD_ENV;
f010454a:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010454f:	e9 c2 00 00 00       	jmp    f0104616 <syscall+0x5bd>
	}

	// Checks if the receiver is receiving
	if (!e->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f0104554:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		break;
	case SYS_ipc_try_send:
		//cprintf("DEBUG-SYSCALL: Calling sys_ipc_try_send!\n");
		ret = (int32_t) sys_ipc_try_send((envid_t) a1, (uint32_t) a2,
						   (void*) a3, (unsigned) a4);
		break;
f0104559:	e9 b8 00 00 00       	jmp    f0104616 <syscall+0x5bd>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// Checks if va is page aligned, given that it is valid
	if (((uint32_t) dstva < UTOP) &&  (((uint32_t) dstva) % PGSIZE != 0)) {
f010455e:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104565:	77 0d                	ja     f0104574 <syscall+0x51b>
f0104567:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010456e:	0f 85 9d 00 00 00    	jne    f0104611 <syscall+0x5b8>
		return -E_INVAL;
	}

	// Record that you want to receive
	curenv->env_ipc_recving = 1;
f0104574:	e8 a1 11 00 00       	call   f010571a <cpunum>
f0104579:	6b c0 74             	imul   $0x74,%eax,%eax
f010457c:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0104582:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104586:	e8 8f 11 00 00       	call   f010571a <cpunum>
f010458b:	6b c0 74             	imul   $0x74,%eax,%eax
f010458e:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f0104594:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104597:	89 50 6c             	mov    %edx,0x6c(%eax)

	// Put the return value manually, since this never returns
	curenv->env_tf.tf_regs.reg_eax = 0;
f010459a:	e8 7b 11 00 00       	call   f010571a <cpunum>
f010459f:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a2:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01045a8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	// Give up the cpu and wait until receiving
	curenv->env_status = ENV_NOT_RUNNABLE;
f01045af:	e8 66 11 00 00       	call   f010571a <cpunum>
f01045b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b7:	8b 80 28 00 2a f0    	mov    -0xfd5ffd8(%eax),%eax
f01045bd:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f01045c4:	e8 c4 f9 ff ff       	call   f0103f8d <sched_yield>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *e;
	int r;
	if ((r = envid2env(envid, &e, 1))){
f01045c9:	83 ec 04             	sub    $0x4,%esp
f01045cc:	6a 01                	push   $0x1
f01045ce:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045d1:	50                   	push   %eax
f01045d2:	ff 75 0c             	pushl  0xc(%ebp)
f01045d5:	e8 da e8 ff ff       	call   f0102eb4 <envid2env>
f01045da:	83 c4 10             	add    $0x10,%esp
f01045dd:	85 c0                	test   %eax,%eax
f01045df:	75 1c                	jne    f01045fd <syscall+0x5a4>
		return r;
	}
	tf->tf_cs |= 0x3;
f01045e1:	8b 7d 10             	mov    0x10(%ebp),%edi
f01045e4:	66 83 4f 34 03       	orw    $0x3,0x34(%edi)
	tf->tf_eflags |= FL_IF;
f01045e9:	81 4f 38 00 02 00 00 	orl    $0x200,0x38(%edi)
	e->env_tf = *tf;
f01045f0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01045f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01045f8:	8b 75 10             	mov    0x10(%ebp),%esi
f01045fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	case SYS_ipc_recv:
		//cprintf("DEBUG-SYSCALL: Calling sys_ipc_recv!\n");
		ret = (int32_t) sys_ipc_recv((void*) a1);
		break;
	case SYS_env_set_trapframe:
		return (int32_t)sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);
f01045fd:	89 c3                	mov    %eax,%ebx
f01045ff:	eb 15                	jmp    f0104616 <syscall+0x5bd>
static int
sys_time_msec(void)
{
	// LAB 6: Your code here.
	
	return time_msec();
f0104601:	e8 77 1a 00 00       	call   f010607d <time_msec>
f0104606:	89 c3                	mov    %eax,%ebx
		break;
	case SYS_env_set_trapframe:
		return (int32_t)sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);
		break;
	case SYS_time_msec:
		return (int32_t)sys_time_msec();
f0104608:	eb 0c                	jmp    f0104616 <syscall+0x5bd>
		break;	
	default:
		return -E_INVAL;
f010460a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010460f:	eb 05                	jmp    f0104616 <syscall+0x5bd>
		ret = (int32_t) sys_ipc_try_send((envid_t) a1, (uint32_t) a2,
						   (void*) a3, (unsigned) a4);
		break;
	case SYS_ipc_recv:
		//cprintf("DEBUG-SYSCALL: Calling sys_ipc_recv!\n");
		ret = (int32_t) sys_ipc_recv((void*) a1);
f0104611:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		break;	
	default:
		return -E_INVAL;
	}
	return ret;
}
f0104616:	89 d8                	mov    %ebx,%eax
f0104618:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010461b:	5b                   	pop    %ebx
f010461c:	5e                   	pop    %esi
f010461d:	5f                   	pop    %edi
f010461e:	5d                   	pop    %ebp
f010461f:	c3                   	ret    

f0104620 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104620:	55                   	push   %ebp
f0104621:	89 e5                	mov    %esp,%ebp
f0104623:	57                   	push   %edi
f0104624:	56                   	push   %esi
f0104625:	53                   	push   %ebx
f0104626:	83 ec 14             	sub    $0x14,%esp
f0104629:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010462c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010462f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104632:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104635:	8b 1a                	mov    (%edx),%ebx
f0104637:	8b 01                	mov    (%ecx),%eax
f0104639:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010463c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104643:	eb 7f                	jmp    f01046c4 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104645:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104648:	01 d8                	add    %ebx,%eax
f010464a:	89 c6                	mov    %eax,%esi
f010464c:	c1 ee 1f             	shr    $0x1f,%esi
f010464f:	01 c6                	add    %eax,%esi
f0104651:	d1 fe                	sar    %esi
f0104653:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104656:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104659:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010465c:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010465e:	eb 03                	jmp    f0104663 <stab_binsearch+0x43>
			m--;
f0104660:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104663:	39 c3                	cmp    %eax,%ebx
f0104665:	7f 0d                	jg     f0104674 <stab_binsearch+0x54>
f0104667:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010466b:	83 ea 0c             	sub    $0xc,%edx
f010466e:	39 f9                	cmp    %edi,%ecx
f0104670:	75 ee                	jne    f0104660 <stab_binsearch+0x40>
f0104672:	eb 05                	jmp    f0104679 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104674:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104677:	eb 4b                	jmp    f01046c4 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104679:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010467c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010467f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104683:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104686:	76 11                	jbe    f0104699 <stab_binsearch+0x79>
			*region_left = m;
f0104688:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010468b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010468d:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104690:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104697:	eb 2b                	jmp    f01046c4 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104699:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010469c:	73 14                	jae    f01046b2 <stab_binsearch+0x92>
			*region_right = m - 1;
f010469e:	83 e8 01             	sub    $0x1,%eax
f01046a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01046a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01046a7:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01046a9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01046b0:	eb 12                	jmp    f01046c4 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01046b2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01046b5:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01046b7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01046bb:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01046bd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01046c4:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01046c7:	0f 8e 78 ff ff ff    	jle    f0104645 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01046cd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01046d1:	75 0f                	jne    f01046e2 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01046d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046d6:	8b 00                	mov    (%eax),%eax
f01046d8:	83 e8 01             	sub    $0x1,%eax
f01046db:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01046de:	89 06                	mov    %eax,(%esi)
f01046e0:	eb 2c                	jmp    f010470e <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01046e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01046e5:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01046e7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01046ea:	8b 0e                	mov    (%esi),%ecx
f01046ec:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01046ef:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01046f2:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01046f5:	eb 03                	jmp    f01046fa <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01046f7:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01046fa:	39 c8                	cmp    %ecx,%eax
f01046fc:	7e 0b                	jle    f0104709 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01046fe:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104702:	83 ea 0c             	sub    $0xc,%edx
f0104705:	39 df                	cmp    %ebx,%edi
f0104707:	75 ee                	jne    f01046f7 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104709:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010470c:	89 06                	mov    %eax,(%esi)
	}
}
f010470e:	83 c4 14             	add    $0x14,%esp
f0104711:	5b                   	pop    %ebx
f0104712:	5e                   	pop    %esi
f0104713:	5f                   	pop    %edi
f0104714:	5d                   	pop    %ebp
f0104715:	c3                   	ret    

f0104716 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104716:	55                   	push   %ebp
f0104717:	89 e5                	mov    %esp,%ebp
f0104719:	57                   	push   %edi
f010471a:	56                   	push   %esi
f010471b:	53                   	push   %ebx
f010471c:	83 ec 2c             	sub    $0x2c,%esp
f010471f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104722:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104725:	c7 06 e8 79 10 f0    	movl   $0xf01079e8,(%esi)
	info->eip_line = 0;
f010472b:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104732:	c7 46 08 e8 79 10 f0 	movl   $0xf01079e8,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104739:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104740:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104743:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010474a:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104750:	0f 87 80 00 00 00    	ja     f01047d6 <debuginfo_eip+0xc0>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// TODO: Not sure if it is correct. Should use PTE_U?
		/* Not sure */
		user_mem_check(curenv, usd, 1, PTE_U);
f0104756:	e8 bf 0f 00 00       	call   f010571a <cpunum>
f010475b:	6a 04                	push   $0x4
f010475d:	6a 01                	push   $0x1
f010475f:	68 00 00 20 00       	push   $0x200000
f0104764:	6b c0 74             	imul   $0x74,%eax,%eax
f0104767:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f010476d:	e8 f5 e5 ff ff       	call   f0102d67 <user_mem_check>
		/* Not sure */

		stabs = usd->stabs;
f0104772:	a1 00 00 20 00       	mov    0x200000,%eax
f0104777:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f010477a:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f0104780:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104786:	89 55 cc             	mov    %edx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104789:	a1 0c 00 20 00       	mov    0x20000c,%eax
f010478e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		// TODO: Not sure if it is correct. Should use PTE_U?
		/* Not sure */
		int len = (stab_end - stabs) * sizeof(struct Stab);
		user_mem_check(curenv, stabs, len, PTE_U);
f0104791:	e8 84 0f 00 00       	call   f010571a <cpunum>
f0104796:	6a 04                	push   $0x4
f0104798:	89 da                	mov    %ebx,%edx
f010479a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010479d:	29 ca                	sub    %ecx,%edx
f010479f:	52                   	push   %edx
f01047a0:	51                   	push   %ecx
f01047a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047a4:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f01047aa:	e8 b8 e5 ff ff       	call   f0102d67 <user_mem_check>

		len = stabstr_end - stabstr;
		user_mem_check(curenv, stabstr, len, PTE_U);
f01047af:	83 c4 20             	add    $0x20,%esp
f01047b2:	e8 63 0f 00 00       	call   f010571a <cpunum>
f01047b7:	6a 04                	push   $0x4
f01047b9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01047bc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01047bf:	29 ca                	sub    %ecx,%edx
f01047c1:	52                   	push   %edx
f01047c2:	51                   	push   %ecx
f01047c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01047c6:	ff b0 28 00 2a f0    	pushl  -0xfd5ffd8(%eax)
f01047cc:	e8 96 e5 ff ff       	call   f0102d67 <user_mem_check>
f01047d1:	83 c4 10             	add    $0x10,%esp
f01047d4:	eb 1a                	jmp    f01047f0 <debuginfo_eip+0xda>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01047d6:	c7 45 d0 0c 72 11 f0 	movl   $0xf011720c,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01047dd:	c7 45 cc cd 31 11 f0 	movl   $0xf01131cd,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01047e4:	bb cc 31 11 f0       	mov    $0xf01131cc,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01047e9:	c7 45 d4 c8 81 10 f0 	movl   $0xf01081c8,-0x2c(%ebp)
		user_mem_check(curenv, stabstr, len, PTE_U);
		/* Not sure */
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01047f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01047f3:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01047f6:	0f 83 32 01 00 00    	jae    f010492e <debuginfo_eip+0x218>
f01047fc:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104800:	0f 85 2f 01 00 00    	jne    f0104935 <debuginfo_eip+0x21f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104806:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010480d:	2b 5d d4             	sub    -0x2c(%ebp),%ebx
f0104810:	c1 fb 02             	sar    $0x2,%ebx
f0104813:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0104819:	83 e8 01             	sub    $0x1,%eax
f010481c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010481f:	83 ec 08             	sub    $0x8,%esp
f0104822:	57                   	push   %edi
f0104823:	6a 64                	push   $0x64
f0104825:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104828:	89 d1                	mov    %edx,%ecx
f010482a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010482d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104830:	89 d8                	mov    %ebx,%eax
f0104832:	e8 e9 fd ff ff       	call   f0104620 <stab_binsearch>
	if (lfile == 0)
f0104837:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010483a:	83 c4 10             	add    $0x10,%esp
f010483d:	85 c0                	test   %eax,%eax
f010483f:	0f 84 f7 00 00 00    	je     f010493c <debuginfo_eip+0x226>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104845:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104848:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010484b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010484e:	83 ec 08             	sub    $0x8,%esp
f0104851:	57                   	push   %edi
f0104852:	6a 24                	push   $0x24
f0104854:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104857:	89 d1                	mov    %edx,%ecx
f0104859:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010485c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f010485f:	89 d8                	mov    %ebx,%eax
f0104861:	e8 ba fd ff ff       	call   f0104620 <stab_binsearch>

	if (lfun <= rfun) {
f0104866:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104869:	83 c4 10             	add    $0x10,%esp
f010486c:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f010486f:	7f 24                	jg     f0104895 <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104871:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104874:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104877:	8d 14 87             	lea    (%edi,%eax,4),%edx
f010487a:	8b 02                	mov    (%edx),%eax
f010487c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010487f:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104882:	29 f9                	sub    %edi,%ecx
f0104884:	39 c8                	cmp    %ecx,%eax
f0104886:	73 05                	jae    f010488d <debuginfo_eip+0x177>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104888:	01 f8                	add    %edi,%eax
f010488a:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010488d:	8b 42 08             	mov    0x8(%edx),%eax
f0104890:	89 46 10             	mov    %eax,0x10(%esi)
f0104893:	eb 06                	jmp    f010489b <debuginfo_eip+0x185>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104895:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104898:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010489b:	83 ec 08             	sub    $0x8,%esp
f010489e:	6a 3a                	push   $0x3a
f01048a0:	ff 76 08             	pushl  0x8(%esi)
f01048a3:	e8 33 08 00 00       	call   f01050db <strfind>
f01048a8:	2b 46 08             	sub    0x8(%esi),%eax
f01048ab:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01048ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01048b1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01048b4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01048b7:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01048ba:	83 c4 10             	add    $0x10,%esp
f01048bd:	eb 06                	jmp    f01048c5 <debuginfo_eip+0x1af>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01048bf:	83 eb 01             	sub    $0x1,%ebx
f01048c2:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01048c5:	39 fb                	cmp    %edi,%ebx
f01048c7:	7c 2d                	jl     f01048f6 <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f01048c9:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01048cd:	80 fa 84             	cmp    $0x84,%dl
f01048d0:	74 0b                	je     f01048dd <debuginfo_eip+0x1c7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01048d2:	80 fa 64             	cmp    $0x64,%dl
f01048d5:	75 e8                	jne    f01048bf <debuginfo_eip+0x1a9>
f01048d7:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01048db:	74 e2                	je     f01048bf <debuginfo_eip+0x1a9>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01048dd:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01048e0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01048e3:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01048e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01048e9:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01048ec:	29 f8                	sub    %edi,%eax
f01048ee:	39 c2                	cmp    %eax,%edx
f01048f0:	73 04                	jae    f01048f6 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01048f2:	01 fa                	add    %edi,%edx
f01048f4:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01048f6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01048f9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01048fc:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104901:	39 cb                	cmp    %ecx,%ebx
f0104903:	7d 43                	jge    f0104948 <debuginfo_eip+0x232>
		for (lline = lfun + 1;
f0104905:	8d 53 01             	lea    0x1(%ebx),%edx
f0104908:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010490b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010490e:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104911:	eb 07                	jmp    f010491a <debuginfo_eip+0x204>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104913:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104917:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010491a:	39 ca                	cmp    %ecx,%edx
f010491c:	74 25                	je     f0104943 <debuginfo_eip+0x22d>
f010491e:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104921:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104925:	74 ec                	je     f0104913 <debuginfo_eip+0x1fd>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104927:	b8 00 00 00 00       	mov    $0x0,%eax
f010492c:	eb 1a                	jmp    f0104948 <debuginfo_eip+0x232>
		/* Not sure */
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010492e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104933:	eb 13                	jmp    f0104948 <debuginfo_eip+0x232>
f0104935:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010493a:	eb 0c                	jmp    f0104948 <debuginfo_eip+0x232>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010493c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104941:	eb 05                	jmp    f0104948 <debuginfo_eip+0x232>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104943:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104948:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010494b:	5b                   	pop    %ebx
f010494c:	5e                   	pop    %esi
f010494d:	5f                   	pop    %edi
f010494e:	5d                   	pop    %ebp
f010494f:	c3                   	ret    

f0104950 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104950:	55                   	push   %ebp
f0104951:	89 e5                	mov    %esp,%ebp
f0104953:	57                   	push   %edi
f0104954:	56                   	push   %esi
f0104955:	53                   	push   %ebx
f0104956:	83 ec 1c             	sub    $0x1c,%esp
f0104959:	89 c7                	mov    %eax,%edi
f010495b:	89 d6                	mov    %edx,%esi
f010495d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104960:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104963:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104966:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104969:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010496c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104971:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104974:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104977:	39 d3                	cmp    %edx,%ebx
f0104979:	72 05                	jb     f0104980 <printnum+0x30>
f010497b:	39 45 10             	cmp    %eax,0x10(%ebp)
f010497e:	77 45                	ja     f01049c5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104980:	83 ec 0c             	sub    $0xc,%esp
f0104983:	ff 75 18             	pushl  0x18(%ebp)
f0104986:	8b 45 14             	mov    0x14(%ebp),%eax
f0104989:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010498c:	53                   	push   %ebx
f010498d:	ff 75 10             	pushl  0x10(%ebp)
f0104990:	83 ec 08             	sub    $0x8,%esp
f0104993:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104996:	ff 75 e0             	pushl  -0x20(%ebp)
f0104999:	ff 75 dc             	pushl  -0x24(%ebp)
f010499c:	ff 75 d8             	pushl  -0x28(%ebp)
f010499f:	e8 ec 16 00 00       	call   f0106090 <__udivdi3>
f01049a4:	83 c4 18             	add    $0x18,%esp
f01049a7:	52                   	push   %edx
f01049a8:	50                   	push   %eax
f01049a9:	89 f2                	mov    %esi,%edx
f01049ab:	89 f8                	mov    %edi,%eax
f01049ad:	e8 9e ff ff ff       	call   f0104950 <printnum>
f01049b2:	83 c4 20             	add    $0x20,%esp
f01049b5:	eb 18                	jmp    f01049cf <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01049b7:	83 ec 08             	sub    $0x8,%esp
f01049ba:	56                   	push   %esi
f01049bb:	ff 75 18             	pushl  0x18(%ebp)
f01049be:	ff d7                	call   *%edi
f01049c0:	83 c4 10             	add    $0x10,%esp
f01049c3:	eb 03                	jmp    f01049c8 <printnum+0x78>
f01049c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01049c8:	83 eb 01             	sub    $0x1,%ebx
f01049cb:	85 db                	test   %ebx,%ebx
f01049cd:	7f e8                	jg     f01049b7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01049cf:	83 ec 08             	sub    $0x8,%esp
f01049d2:	56                   	push   %esi
f01049d3:	83 ec 04             	sub    $0x4,%esp
f01049d6:	ff 75 e4             	pushl  -0x1c(%ebp)
f01049d9:	ff 75 e0             	pushl  -0x20(%ebp)
f01049dc:	ff 75 dc             	pushl  -0x24(%ebp)
f01049df:	ff 75 d8             	pushl  -0x28(%ebp)
f01049e2:	e8 d9 17 00 00       	call   f01061c0 <__umoddi3>
f01049e7:	83 c4 14             	add    $0x14,%esp
f01049ea:	0f be 80 f2 79 10 f0 	movsbl -0xfef860e(%eax),%eax
f01049f1:	50                   	push   %eax
f01049f2:	ff d7                	call   *%edi
}
f01049f4:	83 c4 10             	add    $0x10,%esp
f01049f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049fa:	5b                   	pop    %ebx
f01049fb:	5e                   	pop    %esi
f01049fc:	5f                   	pop    %edi
f01049fd:	5d                   	pop    %ebp
f01049fe:	c3                   	ret    

f01049ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01049ff:	55                   	push   %ebp
f0104a00:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104a02:	83 fa 01             	cmp    $0x1,%edx
f0104a05:	7e 0e                	jle    f0104a15 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104a07:	8b 10                	mov    (%eax),%edx
f0104a09:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104a0c:	89 08                	mov    %ecx,(%eax)
f0104a0e:	8b 02                	mov    (%edx),%eax
f0104a10:	8b 52 04             	mov    0x4(%edx),%edx
f0104a13:	eb 22                	jmp    f0104a37 <getuint+0x38>
	else if (lflag)
f0104a15:	85 d2                	test   %edx,%edx
f0104a17:	74 10                	je     f0104a29 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104a19:	8b 10                	mov    (%eax),%edx
f0104a1b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104a1e:	89 08                	mov    %ecx,(%eax)
f0104a20:	8b 02                	mov    (%edx),%eax
f0104a22:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a27:	eb 0e                	jmp    f0104a37 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104a29:	8b 10                	mov    (%eax),%edx
f0104a2b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104a2e:	89 08                	mov    %ecx,(%eax)
f0104a30:	8b 02                	mov    (%edx),%eax
f0104a32:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104a37:	5d                   	pop    %ebp
f0104a38:	c3                   	ret    

f0104a39 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104a39:	55                   	push   %ebp
f0104a3a:	89 e5                	mov    %esp,%ebp
f0104a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104a3f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104a43:	8b 10                	mov    (%eax),%edx
f0104a45:	3b 50 04             	cmp    0x4(%eax),%edx
f0104a48:	73 0a                	jae    f0104a54 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104a4a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104a4d:	89 08                	mov    %ecx,(%eax)
f0104a4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a52:	88 02                	mov    %al,(%edx)
}
f0104a54:	5d                   	pop    %ebp
f0104a55:	c3                   	ret    

f0104a56 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104a56:	55                   	push   %ebp
f0104a57:	89 e5                	mov    %esp,%ebp
f0104a59:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104a5c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104a5f:	50                   	push   %eax
f0104a60:	ff 75 10             	pushl  0x10(%ebp)
f0104a63:	ff 75 0c             	pushl  0xc(%ebp)
f0104a66:	ff 75 08             	pushl  0x8(%ebp)
f0104a69:	e8 05 00 00 00       	call   f0104a73 <vprintfmt>
	va_end(ap);
}
f0104a6e:	83 c4 10             	add    $0x10,%esp
f0104a71:	c9                   	leave  
f0104a72:	c3                   	ret    

f0104a73 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104a73:	55                   	push   %ebp
f0104a74:	89 e5                	mov    %esp,%ebp
f0104a76:	57                   	push   %edi
f0104a77:	56                   	push   %esi
f0104a78:	53                   	push   %ebx
f0104a79:	83 ec 2c             	sub    $0x2c,%esp
f0104a7c:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a82:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a85:	eb 12                	jmp    f0104a99 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104a87:	85 c0                	test   %eax,%eax
f0104a89:	0f 84 89 03 00 00    	je     f0104e18 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104a8f:	83 ec 08             	sub    $0x8,%esp
f0104a92:	53                   	push   %ebx
f0104a93:	50                   	push   %eax
f0104a94:	ff d6                	call   *%esi
f0104a96:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104a99:	83 c7 01             	add    $0x1,%edi
f0104a9c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104aa0:	83 f8 25             	cmp    $0x25,%eax
f0104aa3:	75 e2                	jne    f0104a87 <vprintfmt+0x14>
f0104aa5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104aa9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104ab0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104ab7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104abe:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ac3:	eb 07                	jmp    f0104acc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ac5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104ac8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104acc:	8d 47 01             	lea    0x1(%edi),%eax
f0104acf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104ad2:	0f b6 07             	movzbl (%edi),%eax
f0104ad5:	0f b6 c8             	movzbl %al,%ecx
f0104ad8:	83 e8 23             	sub    $0x23,%eax
f0104adb:	3c 55                	cmp    $0x55,%al
f0104add:	0f 87 1a 03 00 00    	ja     f0104dfd <vprintfmt+0x38a>
f0104ae3:	0f b6 c0             	movzbl %al,%eax
f0104ae6:	ff 24 85 20 7b 10 f0 	jmp    *-0xfef84e0(,%eax,4)
f0104aed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104af0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104af4:	eb d6                	jmp    f0104acc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104af6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104af9:	b8 00 00 00 00       	mov    $0x0,%eax
f0104afe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104b01:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104b04:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104b08:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104b0b:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104b0e:	83 fa 09             	cmp    $0x9,%edx
f0104b11:	77 39                	ja     f0104b4c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104b13:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104b16:	eb e9                	jmp    f0104b01 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104b18:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b1b:	8d 48 04             	lea    0x4(%eax),%ecx
f0104b1e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104b21:	8b 00                	mov    (%eax),%eax
f0104b23:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104b29:	eb 27                	jmp    f0104b52 <vprintfmt+0xdf>
f0104b2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b2e:	85 c0                	test   %eax,%eax
f0104b30:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104b35:	0f 49 c8             	cmovns %eax,%ecx
f0104b38:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b3e:	eb 8c                	jmp    f0104acc <vprintfmt+0x59>
f0104b40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104b43:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104b4a:	eb 80                	jmp    f0104acc <vprintfmt+0x59>
f0104b4c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b4f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104b52:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104b56:	0f 89 70 ff ff ff    	jns    f0104acc <vprintfmt+0x59>
				width = precision, precision = -1;
f0104b5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104b5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104b62:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104b69:	e9 5e ff ff ff       	jmp    f0104acc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104b6e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b71:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104b74:	e9 53 ff ff ff       	jmp    f0104acc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104b79:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b7c:	8d 50 04             	lea    0x4(%eax),%edx
f0104b7f:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b82:	83 ec 08             	sub    $0x8,%esp
f0104b85:	53                   	push   %ebx
f0104b86:	ff 30                	pushl  (%eax)
f0104b88:	ff d6                	call   *%esi
			break;
f0104b8a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104b90:	e9 04 ff ff ff       	jmp    f0104a99 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104b95:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b98:	8d 50 04             	lea    0x4(%eax),%edx
f0104b9b:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b9e:	8b 00                	mov    (%eax),%eax
f0104ba0:	99                   	cltd   
f0104ba1:	31 d0                	xor    %edx,%eax
f0104ba3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104ba5:	83 f8 0f             	cmp    $0xf,%eax
f0104ba8:	7f 0b                	jg     f0104bb5 <vprintfmt+0x142>
f0104baa:	8b 14 85 80 7c 10 f0 	mov    -0xfef8380(,%eax,4),%edx
f0104bb1:	85 d2                	test   %edx,%edx
f0104bb3:	75 18                	jne    f0104bcd <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104bb5:	50                   	push   %eax
f0104bb6:	68 0a 7a 10 f0       	push   $0xf0107a0a
f0104bbb:	53                   	push   %ebx
f0104bbc:	56                   	push   %esi
f0104bbd:	e8 94 fe ff ff       	call   f0104a56 <printfmt>
f0104bc2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104bc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104bc8:	e9 cc fe ff ff       	jmp    f0104a99 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104bcd:	52                   	push   %edx
f0104bce:	68 8f 72 10 f0       	push   $0xf010728f
f0104bd3:	53                   	push   %ebx
f0104bd4:	56                   	push   %esi
f0104bd5:	e8 7c fe ff ff       	call   f0104a56 <printfmt>
f0104bda:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104bdd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104be0:	e9 b4 fe ff ff       	jmp    f0104a99 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104be5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104be8:	8d 50 04             	lea    0x4(%eax),%edx
f0104beb:	89 55 14             	mov    %edx,0x14(%ebp)
f0104bee:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104bf0:	85 ff                	test   %edi,%edi
f0104bf2:	b8 03 7a 10 f0       	mov    $0xf0107a03,%eax
f0104bf7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104bfa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104bfe:	0f 8e 94 00 00 00    	jle    f0104c98 <vprintfmt+0x225>
f0104c04:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104c08:	0f 84 98 00 00 00    	je     f0104ca6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104c0e:	83 ec 08             	sub    $0x8,%esp
f0104c11:	ff 75 d0             	pushl  -0x30(%ebp)
f0104c14:	57                   	push   %edi
f0104c15:	e8 77 03 00 00       	call   f0104f91 <strnlen>
f0104c1a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104c1d:	29 c1                	sub    %eax,%ecx
f0104c1f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104c22:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104c25:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104c29:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104c2c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104c2f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104c31:	eb 0f                	jmp    f0104c42 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104c33:	83 ec 08             	sub    $0x8,%esp
f0104c36:	53                   	push   %ebx
f0104c37:	ff 75 e0             	pushl  -0x20(%ebp)
f0104c3a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104c3c:	83 ef 01             	sub    $0x1,%edi
f0104c3f:	83 c4 10             	add    $0x10,%esp
f0104c42:	85 ff                	test   %edi,%edi
f0104c44:	7f ed                	jg     f0104c33 <vprintfmt+0x1c0>
f0104c46:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104c49:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104c4c:	85 c9                	test   %ecx,%ecx
f0104c4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c53:	0f 49 c1             	cmovns %ecx,%eax
f0104c56:	29 c1                	sub    %eax,%ecx
f0104c58:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c5b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c5e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c61:	89 cb                	mov    %ecx,%ebx
f0104c63:	eb 4d                	jmp    f0104cb2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104c65:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104c69:	74 1b                	je     f0104c86 <vprintfmt+0x213>
f0104c6b:	0f be c0             	movsbl %al,%eax
f0104c6e:	83 e8 20             	sub    $0x20,%eax
f0104c71:	83 f8 5e             	cmp    $0x5e,%eax
f0104c74:	76 10                	jbe    f0104c86 <vprintfmt+0x213>
					putch('?', putdat);
f0104c76:	83 ec 08             	sub    $0x8,%esp
f0104c79:	ff 75 0c             	pushl  0xc(%ebp)
f0104c7c:	6a 3f                	push   $0x3f
f0104c7e:	ff 55 08             	call   *0x8(%ebp)
f0104c81:	83 c4 10             	add    $0x10,%esp
f0104c84:	eb 0d                	jmp    f0104c93 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0104c86:	83 ec 08             	sub    $0x8,%esp
f0104c89:	ff 75 0c             	pushl  0xc(%ebp)
f0104c8c:	52                   	push   %edx
f0104c8d:	ff 55 08             	call   *0x8(%ebp)
f0104c90:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c93:	83 eb 01             	sub    $0x1,%ebx
f0104c96:	eb 1a                	jmp    f0104cb2 <vprintfmt+0x23f>
f0104c98:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c9b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c9e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104ca1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104ca4:	eb 0c                	jmp    f0104cb2 <vprintfmt+0x23f>
f0104ca6:	89 75 08             	mov    %esi,0x8(%ebp)
f0104ca9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104cac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104caf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104cb2:	83 c7 01             	add    $0x1,%edi
f0104cb5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104cb9:	0f be d0             	movsbl %al,%edx
f0104cbc:	85 d2                	test   %edx,%edx
f0104cbe:	74 23                	je     f0104ce3 <vprintfmt+0x270>
f0104cc0:	85 f6                	test   %esi,%esi
f0104cc2:	78 a1                	js     f0104c65 <vprintfmt+0x1f2>
f0104cc4:	83 ee 01             	sub    $0x1,%esi
f0104cc7:	79 9c                	jns    f0104c65 <vprintfmt+0x1f2>
f0104cc9:	89 df                	mov    %ebx,%edi
f0104ccb:	8b 75 08             	mov    0x8(%ebp),%esi
f0104cce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cd1:	eb 18                	jmp    f0104ceb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104cd3:	83 ec 08             	sub    $0x8,%esp
f0104cd6:	53                   	push   %ebx
f0104cd7:	6a 20                	push   $0x20
f0104cd9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104cdb:	83 ef 01             	sub    $0x1,%edi
f0104cde:	83 c4 10             	add    $0x10,%esp
f0104ce1:	eb 08                	jmp    f0104ceb <vprintfmt+0x278>
f0104ce3:	89 df                	mov    %ebx,%edi
f0104ce5:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ce8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ceb:	85 ff                	test   %edi,%edi
f0104ced:	7f e4                	jg     f0104cd3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cf2:	e9 a2 fd ff ff       	jmp    f0104a99 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104cf7:	83 fa 01             	cmp    $0x1,%edx
f0104cfa:	7e 16                	jle    f0104d12 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0104cfc:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cff:	8d 50 08             	lea    0x8(%eax),%edx
f0104d02:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d05:	8b 50 04             	mov    0x4(%eax),%edx
f0104d08:	8b 00                	mov    (%eax),%eax
f0104d0a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d0d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104d10:	eb 32                	jmp    f0104d44 <vprintfmt+0x2d1>
	else if (lflag)
f0104d12:	85 d2                	test   %edx,%edx
f0104d14:	74 18                	je     f0104d2e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0104d16:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d19:	8d 50 04             	lea    0x4(%eax),%edx
f0104d1c:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d1f:	8b 00                	mov    (%eax),%eax
f0104d21:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d24:	89 c1                	mov    %eax,%ecx
f0104d26:	c1 f9 1f             	sar    $0x1f,%ecx
f0104d29:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104d2c:	eb 16                	jmp    f0104d44 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0104d2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d31:	8d 50 04             	lea    0x4(%eax),%edx
f0104d34:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d37:	8b 00                	mov    (%eax),%eax
f0104d39:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d3c:	89 c1                	mov    %eax,%ecx
f0104d3e:	c1 f9 1f             	sar    $0x1f,%ecx
f0104d41:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104d44:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104d47:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104d4a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104d4f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104d53:	79 74                	jns    f0104dc9 <vprintfmt+0x356>
				putch('-', putdat);
f0104d55:	83 ec 08             	sub    $0x8,%esp
f0104d58:	53                   	push   %ebx
f0104d59:	6a 2d                	push   $0x2d
f0104d5b:	ff d6                	call   *%esi
				num = -(long long) num;
f0104d5d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104d60:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d63:	f7 d8                	neg    %eax
f0104d65:	83 d2 00             	adc    $0x0,%edx
f0104d68:	f7 da                	neg    %edx
f0104d6a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104d6d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0104d72:	eb 55                	jmp    f0104dc9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104d74:	8d 45 14             	lea    0x14(%ebp),%eax
f0104d77:	e8 83 fc ff ff       	call   f01049ff <getuint>
			base = 10;
f0104d7c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0104d81:	eb 46                	jmp    f0104dc9 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0104d83:	8d 45 14             	lea    0x14(%ebp),%eax
f0104d86:	e8 74 fc ff ff       	call   f01049ff <getuint>
                        base = 8;
f0104d8b:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0104d90:	eb 37                	jmp    f0104dc9 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0104d92:	83 ec 08             	sub    $0x8,%esp
f0104d95:	53                   	push   %ebx
f0104d96:	6a 30                	push   $0x30
f0104d98:	ff d6                	call   *%esi
			putch('x', putdat);
f0104d9a:	83 c4 08             	add    $0x8,%esp
f0104d9d:	53                   	push   %ebx
f0104d9e:	6a 78                	push   $0x78
f0104da0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104da2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104da5:	8d 50 04             	lea    0x4(%eax),%edx
f0104da8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104dab:	8b 00                	mov    (%eax),%eax
f0104dad:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104db2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104db5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104dba:	eb 0d                	jmp    f0104dc9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104dbc:	8d 45 14             	lea    0x14(%ebp),%eax
f0104dbf:	e8 3b fc ff ff       	call   f01049ff <getuint>
			base = 16;
f0104dc4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104dc9:	83 ec 0c             	sub    $0xc,%esp
f0104dcc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104dd0:	57                   	push   %edi
f0104dd1:	ff 75 e0             	pushl  -0x20(%ebp)
f0104dd4:	51                   	push   %ecx
f0104dd5:	52                   	push   %edx
f0104dd6:	50                   	push   %eax
f0104dd7:	89 da                	mov    %ebx,%edx
f0104dd9:	89 f0                	mov    %esi,%eax
f0104ddb:	e8 70 fb ff ff       	call   f0104950 <printnum>
			break;
f0104de0:	83 c4 20             	add    $0x20,%esp
f0104de3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104de6:	e9 ae fc ff ff       	jmp    f0104a99 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104deb:	83 ec 08             	sub    $0x8,%esp
f0104dee:	53                   	push   %ebx
f0104def:	51                   	push   %ecx
f0104df0:	ff d6                	call   *%esi
			break;
f0104df2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104df5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104df8:	e9 9c fc ff ff       	jmp    f0104a99 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104dfd:	83 ec 08             	sub    $0x8,%esp
f0104e00:	53                   	push   %ebx
f0104e01:	6a 25                	push   $0x25
f0104e03:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104e05:	83 c4 10             	add    $0x10,%esp
f0104e08:	eb 03                	jmp    f0104e0d <vprintfmt+0x39a>
f0104e0a:	83 ef 01             	sub    $0x1,%edi
f0104e0d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104e11:	75 f7                	jne    f0104e0a <vprintfmt+0x397>
f0104e13:	e9 81 fc ff ff       	jmp    f0104a99 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e1b:	5b                   	pop    %ebx
f0104e1c:	5e                   	pop    %esi
f0104e1d:	5f                   	pop    %edi
f0104e1e:	5d                   	pop    %ebp
f0104e1f:	c3                   	ret    

f0104e20 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104e20:	55                   	push   %ebp
f0104e21:	89 e5                	mov    %esp,%ebp
f0104e23:	83 ec 18             	sub    $0x18,%esp
f0104e26:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e29:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104e2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104e2f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104e33:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104e36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104e3d:	85 c0                	test   %eax,%eax
f0104e3f:	74 26                	je     f0104e67 <vsnprintf+0x47>
f0104e41:	85 d2                	test   %edx,%edx
f0104e43:	7e 22                	jle    f0104e67 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104e45:	ff 75 14             	pushl  0x14(%ebp)
f0104e48:	ff 75 10             	pushl  0x10(%ebp)
f0104e4b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104e4e:	50                   	push   %eax
f0104e4f:	68 39 4a 10 f0       	push   $0xf0104a39
f0104e54:	e8 1a fc ff ff       	call   f0104a73 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104e59:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104e5c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e62:	83 c4 10             	add    $0x10,%esp
f0104e65:	eb 05                	jmp    f0104e6c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104e67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104e6c:	c9                   	leave  
f0104e6d:	c3                   	ret    

f0104e6e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104e6e:	55                   	push   %ebp
f0104e6f:	89 e5                	mov    %esp,%ebp
f0104e71:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104e74:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104e77:	50                   	push   %eax
f0104e78:	ff 75 10             	pushl  0x10(%ebp)
f0104e7b:	ff 75 0c             	pushl  0xc(%ebp)
f0104e7e:	ff 75 08             	pushl  0x8(%ebp)
f0104e81:	e8 9a ff ff ff       	call   f0104e20 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104e86:	c9                   	leave  
f0104e87:	c3                   	ret    

f0104e88 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104e88:	55                   	push   %ebp
f0104e89:	89 e5                	mov    %esp,%ebp
f0104e8b:	57                   	push   %edi
f0104e8c:	56                   	push   %esi
f0104e8d:	53                   	push   %ebx
f0104e8e:	83 ec 0c             	sub    $0xc,%esp
f0104e91:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0104e94:	85 c0                	test   %eax,%eax
f0104e96:	74 11                	je     f0104ea9 <readline+0x21>
		cprintf("%s", prompt);
f0104e98:	83 ec 08             	sub    $0x8,%esp
f0104e9b:	50                   	push   %eax
f0104e9c:	68 8f 72 10 f0       	push   $0xf010728f
f0104ea1:	e8 ab e7 ff ff       	call   f0103651 <cprintf>
f0104ea6:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0104ea9:	83 ec 0c             	sub    $0xc,%esp
f0104eac:	6a 00                	push   $0x0
f0104eae:	e8 03 b9 ff ff       	call   f01007b6 <iscons>
f0104eb3:	89 c7                	mov    %eax,%edi
f0104eb5:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0104eb8:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104ebd:	e8 e3 b8 ff ff       	call   f01007a5 <getchar>
f0104ec2:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104ec4:	85 c0                	test   %eax,%eax
f0104ec6:	79 29                	jns    f0104ef1 <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0104ec8:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0104ecd:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0104ed0:	0f 84 9b 00 00 00    	je     f0104f71 <readline+0xe9>
				cprintf("read error: %e\n", c);
f0104ed6:	83 ec 08             	sub    $0x8,%esp
f0104ed9:	53                   	push   %ebx
f0104eda:	68 df 7c 10 f0       	push   $0xf0107cdf
f0104edf:	e8 6d e7 ff ff       	call   f0103651 <cprintf>
f0104ee4:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0104ee7:	b8 00 00 00 00       	mov    $0x0,%eax
f0104eec:	e9 80 00 00 00       	jmp    f0104f71 <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104ef1:	83 f8 08             	cmp    $0x8,%eax
f0104ef4:	0f 94 c2             	sete   %dl
f0104ef7:	83 f8 7f             	cmp    $0x7f,%eax
f0104efa:	0f 94 c0             	sete   %al
f0104efd:	08 c2                	or     %al,%dl
f0104eff:	74 1a                	je     f0104f1b <readline+0x93>
f0104f01:	85 f6                	test   %esi,%esi
f0104f03:	7e 16                	jle    f0104f1b <readline+0x93>
			if (echoing)
f0104f05:	85 ff                	test   %edi,%edi
f0104f07:	74 0d                	je     f0104f16 <readline+0x8e>
				cputchar('\b');
f0104f09:	83 ec 0c             	sub    $0xc,%esp
f0104f0c:	6a 08                	push   $0x8
f0104f0e:	e8 82 b8 ff ff       	call   f0100795 <cputchar>
f0104f13:	83 c4 10             	add    $0x10,%esp
			i--;
f0104f16:	83 ee 01             	sub    $0x1,%esi
f0104f19:	eb a2                	jmp    f0104ebd <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104f1b:	83 fb 1f             	cmp    $0x1f,%ebx
f0104f1e:	7e 26                	jle    f0104f46 <readline+0xbe>
f0104f20:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104f26:	7f 1e                	jg     f0104f46 <readline+0xbe>
			if (echoing)
f0104f28:	85 ff                	test   %edi,%edi
f0104f2a:	74 0c                	je     f0104f38 <readline+0xb0>
				cputchar(c);
f0104f2c:	83 ec 0c             	sub    $0xc,%esp
f0104f2f:	53                   	push   %ebx
f0104f30:	e8 60 b8 ff ff       	call   f0100795 <cputchar>
f0104f35:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104f38:	88 9e 80 fa 29 f0    	mov    %bl,-0xfd60580(%esi)
f0104f3e:	8d 76 01             	lea    0x1(%esi),%esi
f0104f41:	e9 77 ff ff ff       	jmp    f0104ebd <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104f46:	83 fb 0a             	cmp    $0xa,%ebx
f0104f49:	74 09                	je     f0104f54 <readline+0xcc>
f0104f4b:	83 fb 0d             	cmp    $0xd,%ebx
f0104f4e:	0f 85 69 ff ff ff    	jne    f0104ebd <readline+0x35>
			if (echoing)
f0104f54:	85 ff                	test   %edi,%edi
f0104f56:	74 0d                	je     f0104f65 <readline+0xdd>
				cputchar('\n');
f0104f58:	83 ec 0c             	sub    $0xc,%esp
f0104f5b:	6a 0a                	push   $0xa
f0104f5d:	e8 33 b8 ff ff       	call   f0100795 <cputchar>
f0104f62:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104f65:	c6 86 80 fa 29 f0 00 	movb   $0x0,-0xfd60580(%esi)
			return buf;
f0104f6c:	b8 80 fa 29 f0       	mov    $0xf029fa80,%eax
		}
	}
}
f0104f71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f74:	5b                   	pop    %ebx
f0104f75:	5e                   	pop    %esi
f0104f76:	5f                   	pop    %edi
f0104f77:	5d                   	pop    %ebp
f0104f78:	c3                   	ret    

f0104f79 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104f79:	55                   	push   %ebp
f0104f7a:	89 e5                	mov    %esp,%ebp
f0104f7c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104f7f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f84:	eb 03                	jmp    f0104f89 <strlen+0x10>
		n++;
f0104f86:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104f89:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104f8d:	75 f7                	jne    f0104f86 <strlen+0xd>
		n++;
	return n;
}
f0104f8f:	5d                   	pop    %ebp
f0104f90:	c3                   	ret    

f0104f91 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104f91:	55                   	push   %ebp
f0104f92:	89 e5                	mov    %esp,%ebp
f0104f94:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f97:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104f9a:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f9f:	eb 03                	jmp    f0104fa4 <strnlen+0x13>
		n++;
f0104fa1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104fa4:	39 c2                	cmp    %eax,%edx
f0104fa6:	74 08                	je     f0104fb0 <strnlen+0x1f>
f0104fa8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104fac:	75 f3                	jne    f0104fa1 <strnlen+0x10>
f0104fae:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104fb0:	5d                   	pop    %ebp
f0104fb1:	c3                   	ret    

f0104fb2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104fb2:	55                   	push   %ebp
f0104fb3:	89 e5                	mov    %esp,%ebp
f0104fb5:	53                   	push   %ebx
f0104fb6:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104fbc:	89 c2                	mov    %eax,%edx
f0104fbe:	83 c2 01             	add    $0x1,%edx
f0104fc1:	83 c1 01             	add    $0x1,%ecx
f0104fc4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104fc8:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104fcb:	84 db                	test   %bl,%bl
f0104fcd:	75 ef                	jne    f0104fbe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104fcf:	5b                   	pop    %ebx
f0104fd0:	5d                   	pop    %ebp
f0104fd1:	c3                   	ret    

f0104fd2 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104fd2:	55                   	push   %ebp
f0104fd3:	89 e5                	mov    %esp,%ebp
f0104fd5:	53                   	push   %ebx
f0104fd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104fd9:	53                   	push   %ebx
f0104fda:	e8 9a ff ff ff       	call   f0104f79 <strlen>
f0104fdf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104fe2:	ff 75 0c             	pushl  0xc(%ebp)
f0104fe5:	01 d8                	add    %ebx,%eax
f0104fe7:	50                   	push   %eax
f0104fe8:	e8 c5 ff ff ff       	call   f0104fb2 <strcpy>
	return dst;
}
f0104fed:	89 d8                	mov    %ebx,%eax
f0104fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104ff2:	c9                   	leave  
f0104ff3:	c3                   	ret    

f0104ff4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104ff4:	55                   	push   %ebp
f0104ff5:	89 e5                	mov    %esp,%ebp
f0104ff7:	56                   	push   %esi
f0104ff8:	53                   	push   %ebx
f0104ff9:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ffc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104fff:	89 f3                	mov    %esi,%ebx
f0105001:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105004:	89 f2                	mov    %esi,%edx
f0105006:	eb 0f                	jmp    f0105017 <strncpy+0x23>
		*dst++ = *src;
f0105008:	83 c2 01             	add    $0x1,%edx
f010500b:	0f b6 01             	movzbl (%ecx),%eax
f010500e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105011:	80 39 01             	cmpb   $0x1,(%ecx)
f0105014:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105017:	39 da                	cmp    %ebx,%edx
f0105019:	75 ed                	jne    f0105008 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010501b:	89 f0                	mov    %esi,%eax
f010501d:	5b                   	pop    %ebx
f010501e:	5e                   	pop    %esi
f010501f:	5d                   	pop    %ebp
f0105020:	c3                   	ret    

f0105021 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105021:	55                   	push   %ebp
f0105022:	89 e5                	mov    %esp,%ebp
f0105024:	56                   	push   %esi
f0105025:	53                   	push   %ebx
f0105026:	8b 75 08             	mov    0x8(%ebp),%esi
f0105029:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010502c:	8b 55 10             	mov    0x10(%ebp),%edx
f010502f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105031:	85 d2                	test   %edx,%edx
f0105033:	74 21                	je     f0105056 <strlcpy+0x35>
f0105035:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105039:	89 f2                	mov    %esi,%edx
f010503b:	eb 09                	jmp    f0105046 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010503d:	83 c2 01             	add    $0x1,%edx
f0105040:	83 c1 01             	add    $0x1,%ecx
f0105043:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105046:	39 c2                	cmp    %eax,%edx
f0105048:	74 09                	je     f0105053 <strlcpy+0x32>
f010504a:	0f b6 19             	movzbl (%ecx),%ebx
f010504d:	84 db                	test   %bl,%bl
f010504f:	75 ec                	jne    f010503d <strlcpy+0x1c>
f0105051:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105053:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105056:	29 f0                	sub    %esi,%eax
}
f0105058:	5b                   	pop    %ebx
f0105059:	5e                   	pop    %esi
f010505a:	5d                   	pop    %ebp
f010505b:	c3                   	ret    

f010505c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010505c:	55                   	push   %ebp
f010505d:	89 e5                	mov    %esp,%ebp
f010505f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105062:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105065:	eb 06                	jmp    f010506d <strcmp+0x11>
		p++, q++;
f0105067:	83 c1 01             	add    $0x1,%ecx
f010506a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010506d:	0f b6 01             	movzbl (%ecx),%eax
f0105070:	84 c0                	test   %al,%al
f0105072:	74 04                	je     f0105078 <strcmp+0x1c>
f0105074:	3a 02                	cmp    (%edx),%al
f0105076:	74 ef                	je     f0105067 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105078:	0f b6 c0             	movzbl %al,%eax
f010507b:	0f b6 12             	movzbl (%edx),%edx
f010507e:	29 d0                	sub    %edx,%eax
}
f0105080:	5d                   	pop    %ebp
f0105081:	c3                   	ret    

f0105082 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105082:	55                   	push   %ebp
f0105083:	89 e5                	mov    %esp,%ebp
f0105085:	53                   	push   %ebx
f0105086:	8b 45 08             	mov    0x8(%ebp),%eax
f0105089:	8b 55 0c             	mov    0xc(%ebp),%edx
f010508c:	89 c3                	mov    %eax,%ebx
f010508e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105091:	eb 06                	jmp    f0105099 <strncmp+0x17>
		n--, p++, q++;
f0105093:	83 c0 01             	add    $0x1,%eax
f0105096:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105099:	39 d8                	cmp    %ebx,%eax
f010509b:	74 15                	je     f01050b2 <strncmp+0x30>
f010509d:	0f b6 08             	movzbl (%eax),%ecx
f01050a0:	84 c9                	test   %cl,%cl
f01050a2:	74 04                	je     f01050a8 <strncmp+0x26>
f01050a4:	3a 0a                	cmp    (%edx),%cl
f01050a6:	74 eb                	je     f0105093 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01050a8:	0f b6 00             	movzbl (%eax),%eax
f01050ab:	0f b6 12             	movzbl (%edx),%edx
f01050ae:	29 d0                	sub    %edx,%eax
f01050b0:	eb 05                	jmp    f01050b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01050b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01050b7:	5b                   	pop    %ebx
f01050b8:	5d                   	pop    %ebp
f01050b9:	c3                   	ret    

f01050ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01050ba:	55                   	push   %ebp
f01050bb:	89 e5                	mov    %esp,%ebp
f01050bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01050c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01050c4:	eb 07                	jmp    f01050cd <strchr+0x13>
		if (*s == c)
f01050c6:	38 ca                	cmp    %cl,%dl
f01050c8:	74 0f                	je     f01050d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01050ca:	83 c0 01             	add    $0x1,%eax
f01050cd:	0f b6 10             	movzbl (%eax),%edx
f01050d0:	84 d2                	test   %dl,%dl
f01050d2:	75 f2                	jne    f01050c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01050d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01050d9:	5d                   	pop    %ebp
f01050da:	c3                   	ret    

f01050db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01050db:	55                   	push   %ebp
f01050dc:	89 e5                	mov    %esp,%ebp
f01050de:	8b 45 08             	mov    0x8(%ebp),%eax
f01050e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01050e5:	eb 03                	jmp    f01050ea <strfind+0xf>
f01050e7:	83 c0 01             	add    $0x1,%eax
f01050ea:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01050ed:	38 ca                	cmp    %cl,%dl
f01050ef:	74 04                	je     f01050f5 <strfind+0x1a>
f01050f1:	84 d2                	test   %dl,%dl
f01050f3:	75 f2                	jne    f01050e7 <strfind+0xc>
			break;
	return (char *) s;
}
f01050f5:	5d                   	pop    %ebp
f01050f6:	c3                   	ret    

f01050f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01050f7:	55                   	push   %ebp
f01050f8:	89 e5                	mov    %esp,%ebp
f01050fa:	57                   	push   %edi
f01050fb:	56                   	push   %esi
f01050fc:	53                   	push   %ebx
f01050fd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105100:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105103:	85 c9                	test   %ecx,%ecx
f0105105:	74 36                	je     f010513d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105107:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010510d:	75 28                	jne    f0105137 <memset+0x40>
f010510f:	f6 c1 03             	test   $0x3,%cl
f0105112:	75 23                	jne    f0105137 <memset+0x40>
		c &= 0xFF;
f0105114:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105118:	89 d3                	mov    %edx,%ebx
f010511a:	c1 e3 08             	shl    $0x8,%ebx
f010511d:	89 d6                	mov    %edx,%esi
f010511f:	c1 e6 18             	shl    $0x18,%esi
f0105122:	89 d0                	mov    %edx,%eax
f0105124:	c1 e0 10             	shl    $0x10,%eax
f0105127:	09 f0                	or     %esi,%eax
f0105129:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010512b:	89 d8                	mov    %ebx,%eax
f010512d:	09 d0                	or     %edx,%eax
f010512f:	c1 e9 02             	shr    $0x2,%ecx
f0105132:	fc                   	cld    
f0105133:	f3 ab                	rep stos %eax,%es:(%edi)
f0105135:	eb 06                	jmp    f010513d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105137:	8b 45 0c             	mov    0xc(%ebp),%eax
f010513a:	fc                   	cld    
f010513b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010513d:	89 f8                	mov    %edi,%eax
f010513f:	5b                   	pop    %ebx
f0105140:	5e                   	pop    %esi
f0105141:	5f                   	pop    %edi
f0105142:	5d                   	pop    %ebp
f0105143:	c3                   	ret    

f0105144 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105144:	55                   	push   %ebp
f0105145:	89 e5                	mov    %esp,%ebp
f0105147:	57                   	push   %edi
f0105148:	56                   	push   %esi
f0105149:	8b 45 08             	mov    0x8(%ebp),%eax
f010514c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010514f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105152:	39 c6                	cmp    %eax,%esi
f0105154:	73 35                	jae    f010518b <memmove+0x47>
f0105156:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105159:	39 d0                	cmp    %edx,%eax
f010515b:	73 2e                	jae    f010518b <memmove+0x47>
		s += n;
		d += n;
f010515d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105160:	89 d6                	mov    %edx,%esi
f0105162:	09 fe                	or     %edi,%esi
f0105164:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010516a:	75 13                	jne    f010517f <memmove+0x3b>
f010516c:	f6 c1 03             	test   $0x3,%cl
f010516f:	75 0e                	jne    f010517f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105171:	83 ef 04             	sub    $0x4,%edi
f0105174:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105177:	c1 e9 02             	shr    $0x2,%ecx
f010517a:	fd                   	std    
f010517b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010517d:	eb 09                	jmp    f0105188 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010517f:	83 ef 01             	sub    $0x1,%edi
f0105182:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105185:	fd                   	std    
f0105186:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105188:	fc                   	cld    
f0105189:	eb 1d                	jmp    f01051a8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010518b:	89 f2                	mov    %esi,%edx
f010518d:	09 c2                	or     %eax,%edx
f010518f:	f6 c2 03             	test   $0x3,%dl
f0105192:	75 0f                	jne    f01051a3 <memmove+0x5f>
f0105194:	f6 c1 03             	test   $0x3,%cl
f0105197:	75 0a                	jne    f01051a3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105199:	c1 e9 02             	shr    $0x2,%ecx
f010519c:	89 c7                	mov    %eax,%edi
f010519e:	fc                   	cld    
f010519f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01051a1:	eb 05                	jmp    f01051a8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01051a3:	89 c7                	mov    %eax,%edi
f01051a5:	fc                   	cld    
f01051a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01051a8:	5e                   	pop    %esi
f01051a9:	5f                   	pop    %edi
f01051aa:	5d                   	pop    %ebp
f01051ab:	c3                   	ret    

f01051ac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01051ac:	55                   	push   %ebp
f01051ad:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01051af:	ff 75 10             	pushl  0x10(%ebp)
f01051b2:	ff 75 0c             	pushl  0xc(%ebp)
f01051b5:	ff 75 08             	pushl  0x8(%ebp)
f01051b8:	e8 87 ff ff ff       	call   f0105144 <memmove>
}
f01051bd:	c9                   	leave  
f01051be:	c3                   	ret    

f01051bf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01051bf:	55                   	push   %ebp
f01051c0:	89 e5                	mov    %esp,%ebp
f01051c2:	56                   	push   %esi
f01051c3:	53                   	push   %ebx
f01051c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01051c7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01051ca:	89 c6                	mov    %eax,%esi
f01051cc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01051cf:	eb 1a                	jmp    f01051eb <memcmp+0x2c>
		if (*s1 != *s2)
f01051d1:	0f b6 08             	movzbl (%eax),%ecx
f01051d4:	0f b6 1a             	movzbl (%edx),%ebx
f01051d7:	38 d9                	cmp    %bl,%cl
f01051d9:	74 0a                	je     f01051e5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01051db:	0f b6 c1             	movzbl %cl,%eax
f01051de:	0f b6 db             	movzbl %bl,%ebx
f01051e1:	29 d8                	sub    %ebx,%eax
f01051e3:	eb 0f                	jmp    f01051f4 <memcmp+0x35>
		s1++, s2++;
f01051e5:	83 c0 01             	add    $0x1,%eax
f01051e8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01051eb:	39 f0                	cmp    %esi,%eax
f01051ed:	75 e2                	jne    f01051d1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01051ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01051f4:	5b                   	pop    %ebx
f01051f5:	5e                   	pop    %esi
f01051f6:	5d                   	pop    %ebp
f01051f7:	c3                   	ret    

f01051f8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01051f8:	55                   	push   %ebp
f01051f9:	89 e5                	mov    %esp,%ebp
f01051fb:	53                   	push   %ebx
f01051fc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01051ff:	89 c1                	mov    %eax,%ecx
f0105201:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105204:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105208:	eb 0a                	jmp    f0105214 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010520a:	0f b6 10             	movzbl (%eax),%edx
f010520d:	39 da                	cmp    %ebx,%edx
f010520f:	74 07                	je     f0105218 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105211:	83 c0 01             	add    $0x1,%eax
f0105214:	39 c8                	cmp    %ecx,%eax
f0105216:	72 f2                	jb     f010520a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105218:	5b                   	pop    %ebx
f0105219:	5d                   	pop    %ebp
f010521a:	c3                   	ret    

f010521b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010521b:	55                   	push   %ebp
f010521c:	89 e5                	mov    %esp,%ebp
f010521e:	57                   	push   %edi
f010521f:	56                   	push   %esi
f0105220:	53                   	push   %ebx
f0105221:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105224:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105227:	eb 03                	jmp    f010522c <strtol+0x11>
		s++;
f0105229:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010522c:	0f b6 01             	movzbl (%ecx),%eax
f010522f:	3c 20                	cmp    $0x20,%al
f0105231:	74 f6                	je     f0105229 <strtol+0xe>
f0105233:	3c 09                	cmp    $0x9,%al
f0105235:	74 f2                	je     f0105229 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105237:	3c 2b                	cmp    $0x2b,%al
f0105239:	75 0a                	jne    f0105245 <strtol+0x2a>
		s++;
f010523b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010523e:	bf 00 00 00 00       	mov    $0x0,%edi
f0105243:	eb 11                	jmp    f0105256 <strtol+0x3b>
f0105245:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010524a:	3c 2d                	cmp    $0x2d,%al
f010524c:	75 08                	jne    f0105256 <strtol+0x3b>
		s++, neg = 1;
f010524e:	83 c1 01             	add    $0x1,%ecx
f0105251:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105256:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010525c:	75 15                	jne    f0105273 <strtol+0x58>
f010525e:	80 39 30             	cmpb   $0x30,(%ecx)
f0105261:	75 10                	jne    f0105273 <strtol+0x58>
f0105263:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105267:	75 7c                	jne    f01052e5 <strtol+0xca>
		s += 2, base = 16;
f0105269:	83 c1 02             	add    $0x2,%ecx
f010526c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105271:	eb 16                	jmp    f0105289 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105273:	85 db                	test   %ebx,%ebx
f0105275:	75 12                	jne    f0105289 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105277:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010527c:	80 39 30             	cmpb   $0x30,(%ecx)
f010527f:	75 08                	jne    f0105289 <strtol+0x6e>
		s++, base = 8;
f0105281:	83 c1 01             	add    $0x1,%ecx
f0105284:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105289:	b8 00 00 00 00       	mov    $0x0,%eax
f010528e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105291:	0f b6 11             	movzbl (%ecx),%edx
f0105294:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105297:	89 f3                	mov    %esi,%ebx
f0105299:	80 fb 09             	cmp    $0x9,%bl
f010529c:	77 08                	ja     f01052a6 <strtol+0x8b>
			dig = *s - '0';
f010529e:	0f be d2             	movsbl %dl,%edx
f01052a1:	83 ea 30             	sub    $0x30,%edx
f01052a4:	eb 22                	jmp    f01052c8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01052a6:	8d 72 9f             	lea    -0x61(%edx),%esi
f01052a9:	89 f3                	mov    %esi,%ebx
f01052ab:	80 fb 19             	cmp    $0x19,%bl
f01052ae:	77 08                	ja     f01052b8 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01052b0:	0f be d2             	movsbl %dl,%edx
f01052b3:	83 ea 57             	sub    $0x57,%edx
f01052b6:	eb 10                	jmp    f01052c8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01052b8:	8d 72 bf             	lea    -0x41(%edx),%esi
f01052bb:	89 f3                	mov    %esi,%ebx
f01052bd:	80 fb 19             	cmp    $0x19,%bl
f01052c0:	77 16                	ja     f01052d8 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01052c2:	0f be d2             	movsbl %dl,%edx
f01052c5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01052c8:	3b 55 10             	cmp    0x10(%ebp),%edx
f01052cb:	7d 0b                	jge    f01052d8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01052cd:	83 c1 01             	add    $0x1,%ecx
f01052d0:	0f af 45 10          	imul   0x10(%ebp),%eax
f01052d4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01052d6:	eb b9                	jmp    f0105291 <strtol+0x76>

	if (endptr)
f01052d8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01052dc:	74 0d                	je     f01052eb <strtol+0xd0>
		*endptr = (char *) s;
f01052de:	8b 75 0c             	mov    0xc(%ebp),%esi
f01052e1:	89 0e                	mov    %ecx,(%esi)
f01052e3:	eb 06                	jmp    f01052eb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01052e5:	85 db                	test   %ebx,%ebx
f01052e7:	74 98                	je     f0105281 <strtol+0x66>
f01052e9:	eb 9e                	jmp    f0105289 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01052eb:	89 c2                	mov    %eax,%edx
f01052ed:	f7 da                	neg    %edx
f01052ef:	85 ff                	test   %edi,%edi
f01052f1:	0f 45 c2             	cmovne %edx,%eax
}
f01052f4:	5b                   	pop    %ebx
f01052f5:	5e                   	pop    %esi
f01052f6:	5f                   	pop    %edi
f01052f7:	5d                   	pop    %ebp
f01052f8:	c3                   	ret    
f01052f9:	66 90                	xchg   %ax,%ax
f01052fb:	90                   	nop

f01052fc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01052fc:	fa                   	cli    

	xorw    %ax, %ax
f01052fd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01052ff:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105301:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105303:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105305:	0f 01 16             	lgdtl  (%esi)
f0105308:	74 70                	je     f010537a <mpsearch1+0x3>
	movl    %cr0, %eax
f010530a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010530d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105311:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105314:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010531a:	08 00                	or     %al,(%eax)

f010531c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010531c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105320:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105322:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105324:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105326:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010532a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010532c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010532e:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0105333:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105336:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105339:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010533e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105341:	8b 25 90 fe 29 f0    	mov    0xf029fe90,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105347:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010534c:	b8 d1 01 10 f0       	mov    $0xf01001d1,%eax
	call    *%eax
f0105351:	ff d0                	call   *%eax

f0105353 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105353:	eb fe                	jmp    f0105353 <spin>
f0105355:	8d 76 00             	lea    0x0(%esi),%esi

f0105358 <gdt>:
	...
f0105360:	ff                   	(bad)  
f0105361:	ff 00                	incl   (%eax)
f0105363:	00 00                	add    %al,(%eax)
f0105365:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010536c:	00                   	.byte 0x0
f010536d:	92                   	xchg   %eax,%edx
f010536e:	cf                   	iret   
	...

f0105370 <gdtdesc>:
f0105370:	17                   	pop    %ss
f0105371:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105376 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105376:	90                   	nop

f0105377 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105377:	55                   	push   %ebp
f0105378:	89 e5                	mov    %esp,%ebp
f010537a:	57                   	push   %edi
f010537b:	56                   	push   %esi
f010537c:	53                   	push   %ebx
f010537d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105380:	8b 0d 94 fe 29 f0    	mov    0xf029fe94,%ecx
f0105386:	89 c3                	mov    %eax,%ebx
f0105388:	c1 eb 0c             	shr    $0xc,%ebx
f010538b:	39 cb                	cmp    %ecx,%ebx
f010538d:	72 12                	jb     f01053a1 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010538f:	50                   	push   %eax
f0105390:	68 44 63 10 f0       	push   $0xf0106344
f0105395:	6a 57                	push   $0x57
f0105397:	68 7d 7e 10 f0       	push   $0xf0107e7d
f010539c:	e8 9f ac ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01053a1:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01053a7:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01053a9:	89 c2                	mov    %eax,%edx
f01053ab:	c1 ea 0c             	shr    $0xc,%edx
f01053ae:	39 ca                	cmp    %ecx,%edx
f01053b0:	72 12                	jb     f01053c4 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01053b2:	50                   	push   %eax
f01053b3:	68 44 63 10 f0       	push   $0xf0106344
f01053b8:	6a 57                	push   $0x57
f01053ba:	68 7d 7e 10 f0       	push   $0xf0107e7d
f01053bf:	e8 7c ac ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01053c4:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01053ca:	eb 2f                	jmp    f01053fb <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01053cc:	83 ec 04             	sub    $0x4,%esp
f01053cf:	6a 04                	push   $0x4
f01053d1:	68 8d 7e 10 f0       	push   $0xf0107e8d
f01053d6:	53                   	push   %ebx
f01053d7:	e8 e3 fd ff ff       	call   f01051bf <memcmp>
f01053dc:	83 c4 10             	add    $0x10,%esp
f01053df:	85 c0                	test   %eax,%eax
f01053e1:	75 15                	jne    f01053f8 <mpsearch1+0x81>
f01053e3:	89 da                	mov    %ebx,%edx
f01053e5:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01053e8:	0f b6 0a             	movzbl (%edx),%ecx
f01053eb:	01 c8                	add    %ecx,%eax
f01053ed:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01053f0:	39 d7                	cmp    %edx,%edi
f01053f2:	75 f4                	jne    f01053e8 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01053f4:	84 c0                	test   %al,%al
f01053f6:	74 0e                	je     f0105406 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01053f8:	83 c3 10             	add    $0x10,%ebx
f01053fb:	39 f3                	cmp    %esi,%ebx
f01053fd:	72 cd                	jb     f01053cc <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01053ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0105404:	eb 02                	jmp    f0105408 <mpsearch1+0x91>
f0105406:	89 d8                	mov    %ebx,%eax
}
f0105408:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010540b:	5b                   	pop    %ebx
f010540c:	5e                   	pop    %esi
f010540d:	5f                   	pop    %edi
f010540e:	5d                   	pop    %ebp
f010540f:	c3                   	ret    

f0105410 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105410:	55                   	push   %ebp
f0105411:	89 e5                	mov    %esp,%ebp
f0105413:	57                   	push   %edi
f0105414:	56                   	push   %esi
f0105415:	53                   	push   %ebx
f0105416:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105419:	c7 05 c0 03 2a f0 20 	movl   $0xf02a0020,0xf02a03c0
f0105420:	00 2a f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105423:	83 3d 94 fe 29 f0 00 	cmpl   $0x0,0xf029fe94
f010542a:	75 16                	jne    f0105442 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010542c:	68 00 04 00 00       	push   $0x400
f0105431:	68 44 63 10 f0       	push   $0xf0106344
f0105436:	6a 6f                	push   $0x6f
f0105438:	68 7d 7e 10 f0       	push   $0xf0107e7d
f010543d:	e8 fe ab ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105442:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105449:	85 c0                	test   %eax,%eax
f010544b:	74 16                	je     f0105463 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f010544d:	c1 e0 04             	shl    $0x4,%eax
f0105450:	ba 00 04 00 00       	mov    $0x400,%edx
f0105455:	e8 1d ff ff ff       	call   f0105377 <mpsearch1>
f010545a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010545d:	85 c0                	test   %eax,%eax
f010545f:	75 3c                	jne    f010549d <mp_init+0x8d>
f0105461:	eb 20                	jmp    f0105483 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105463:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010546a:	c1 e0 0a             	shl    $0xa,%eax
f010546d:	2d 00 04 00 00       	sub    $0x400,%eax
f0105472:	ba 00 04 00 00       	mov    $0x400,%edx
f0105477:	e8 fb fe ff ff       	call   f0105377 <mpsearch1>
f010547c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010547f:	85 c0                	test   %eax,%eax
f0105481:	75 1a                	jne    f010549d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105483:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105488:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010548d:	e8 e5 fe ff ff       	call   f0105377 <mpsearch1>
f0105492:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105495:	85 c0                	test   %eax,%eax
f0105497:	0f 84 5d 02 00 00    	je     f01056fa <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010549d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054a0:	8b 70 04             	mov    0x4(%eax),%esi
f01054a3:	85 f6                	test   %esi,%esi
f01054a5:	74 06                	je     f01054ad <mp_init+0x9d>
f01054a7:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01054ab:	74 15                	je     f01054c2 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01054ad:	83 ec 0c             	sub    $0xc,%esp
f01054b0:	68 f0 7c 10 f0       	push   $0xf0107cf0
f01054b5:	e8 97 e1 ff ff       	call   f0103651 <cprintf>
f01054ba:	83 c4 10             	add    $0x10,%esp
f01054bd:	e9 38 02 00 00       	jmp    f01056fa <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01054c2:	89 f0                	mov    %esi,%eax
f01054c4:	c1 e8 0c             	shr    $0xc,%eax
f01054c7:	3b 05 94 fe 29 f0    	cmp    0xf029fe94,%eax
f01054cd:	72 15                	jb     f01054e4 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01054cf:	56                   	push   %esi
f01054d0:	68 44 63 10 f0       	push   $0xf0106344
f01054d5:	68 90 00 00 00       	push   $0x90
f01054da:	68 7d 7e 10 f0       	push   $0xf0107e7d
f01054df:	e8 5c ab ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01054e4:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01054ea:	83 ec 04             	sub    $0x4,%esp
f01054ed:	6a 04                	push   $0x4
f01054ef:	68 92 7e 10 f0       	push   $0xf0107e92
f01054f4:	53                   	push   %ebx
f01054f5:	e8 c5 fc ff ff       	call   f01051bf <memcmp>
f01054fa:	83 c4 10             	add    $0x10,%esp
f01054fd:	85 c0                	test   %eax,%eax
f01054ff:	74 15                	je     f0105516 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105501:	83 ec 0c             	sub    $0xc,%esp
f0105504:	68 20 7d 10 f0       	push   $0xf0107d20
f0105509:	e8 43 e1 ff ff       	call   f0103651 <cprintf>
f010550e:	83 c4 10             	add    $0x10,%esp
f0105511:	e9 e4 01 00 00       	jmp    f01056fa <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105516:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010551a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010551e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105521:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105526:	b8 00 00 00 00       	mov    $0x0,%eax
f010552b:	eb 0d                	jmp    f010553a <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f010552d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105534:	f0 
f0105535:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105537:	83 c0 01             	add    $0x1,%eax
f010553a:	39 c7                	cmp    %eax,%edi
f010553c:	75 ef                	jne    f010552d <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010553e:	84 d2                	test   %dl,%dl
f0105540:	74 15                	je     f0105557 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105542:	83 ec 0c             	sub    $0xc,%esp
f0105545:	68 54 7d 10 f0       	push   $0xf0107d54
f010554a:	e8 02 e1 ff ff       	call   f0103651 <cprintf>
f010554f:	83 c4 10             	add    $0x10,%esp
f0105552:	e9 a3 01 00 00       	jmp    f01056fa <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105557:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f010555b:	3c 01                	cmp    $0x1,%al
f010555d:	74 1d                	je     f010557c <mp_init+0x16c>
f010555f:	3c 04                	cmp    $0x4,%al
f0105561:	74 19                	je     f010557c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105563:	83 ec 08             	sub    $0x8,%esp
f0105566:	0f b6 c0             	movzbl %al,%eax
f0105569:	50                   	push   %eax
f010556a:	68 78 7d 10 f0       	push   $0xf0107d78
f010556f:	e8 dd e0 ff ff       	call   f0103651 <cprintf>
f0105574:	83 c4 10             	add    $0x10,%esp
f0105577:	e9 7e 01 00 00       	jmp    f01056fa <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010557c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105580:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105584:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105589:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010558e:	01 ce                	add    %ecx,%esi
f0105590:	eb 0d                	jmp    f010559f <mp_init+0x18f>
f0105592:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105599:	f0 
f010559a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010559c:	83 c0 01             	add    $0x1,%eax
f010559f:	39 c7                	cmp    %eax,%edi
f01055a1:	75 ef                	jne    f0105592 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01055a3:	89 d0                	mov    %edx,%eax
f01055a5:	02 43 2a             	add    0x2a(%ebx),%al
f01055a8:	74 15                	je     f01055bf <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01055aa:	83 ec 0c             	sub    $0xc,%esp
f01055ad:	68 98 7d 10 f0       	push   $0xf0107d98
f01055b2:	e8 9a e0 ff ff       	call   f0103651 <cprintf>
f01055b7:	83 c4 10             	add    $0x10,%esp
f01055ba:	e9 3b 01 00 00       	jmp    f01056fa <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01055bf:	85 db                	test   %ebx,%ebx
f01055c1:	0f 84 33 01 00 00    	je     f01056fa <mp_init+0x2ea>
		return;
	ismp = 1;
f01055c7:	c7 05 00 00 2a f0 01 	movl   $0x1,0xf02a0000
f01055ce:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01055d1:	8b 43 24             	mov    0x24(%ebx),%eax
f01055d4:	a3 00 10 2e f0       	mov    %eax,0xf02e1000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01055d9:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01055dc:	be 00 00 00 00       	mov    $0x0,%esi
f01055e1:	e9 85 00 00 00       	jmp    f010566b <mp_init+0x25b>
		switch (*p) {
f01055e6:	0f b6 07             	movzbl (%edi),%eax
f01055e9:	84 c0                	test   %al,%al
f01055eb:	74 06                	je     f01055f3 <mp_init+0x1e3>
f01055ed:	3c 04                	cmp    $0x4,%al
f01055ef:	77 55                	ja     f0105646 <mp_init+0x236>
f01055f1:	eb 4e                	jmp    f0105641 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01055f3:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01055f7:	74 11                	je     f010560a <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f01055f9:	6b 05 c4 03 2a f0 74 	imul   $0x74,0xf02a03c4,%eax
f0105600:	05 20 00 2a f0       	add    $0xf02a0020,%eax
f0105605:	a3 c0 03 2a f0       	mov    %eax,0xf02a03c0
			if (ncpu < NCPU) {
f010560a:	a1 c4 03 2a f0       	mov    0xf02a03c4,%eax
f010560f:	83 f8 07             	cmp    $0x7,%eax
f0105612:	7f 13                	jg     f0105627 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105614:	6b d0 74             	imul   $0x74,%eax,%edx
f0105617:	88 82 20 00 2a f0    	mov    %al,-0xfd5ffe0(%edx)
				ncpu++;
f010561d:	83 c0 01             	add    $0x1,%eax
f0105620:	a3 c4 03 2a f0       	mov    %eax,0xf02a03c4
f0105625:	eb 15                	jmp    f010563c <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105627:	83 ec 08             	sub    $0x8,%esp
f010562a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010562e:	50                   	push   %eax
f010562f:	68 c8 7d 10 f0       	push   $0xf0107dc8
f0105634:	e8 18 e0 ff ff       	call   f0103651 <cprintf>
f0105639:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010563c:	83 c7 14             	add    $0x14,%edi
			continue;
f010563f:	eb 27                	jmp    f0105668 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105641:	83 c7 08             	add    $0x8,%edi
			continue;
f0105644:	eb 22                	jmp    f0105668 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105646:	83 ec 08             	sub    $0x8,%esp
f0105649:	0f b6 c0             	movzbl %al,%eax
f010564c:	50                   	push   %eax
f010564d:	68 f0 7d 10 f0       	push   $0xf0107df0
f0105652:	e8 fa df ff ff       	call   f0103651 <cprintf>
			ismp = 0;
f0105657:	c7 05 00 00 2a f0 00 	movl   $0x0,0xf02a0000
f010565e:	00 00 00 
			i = conf->entry;
f0105661:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105665:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105668:	83 c6 01             	add    $0x1,%esi
f010566b:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010566f:	39 c6                	cmp    %eax,%esi
f0105671:	0f 82 6f ff ff ff    	jb     f01055e6 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105677:	a1 c0 03 2a f0       	mov    0xf02a03c0,%eax
f010567c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105683:	83 3d 00 00 2a f0 00 	cmpl   $0x0,0xf02a0000
f010568a:	75 26                	jne    f01056b2 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010568c:	c7 05 c4 03 2a f0 01 	movl   $0x1,0xf02a03c4
f0105693:	00 00 00 
		lapicaddr = 0;
f0105696:	c7 05 00 10 2e f0 00 	movl   $0x0,0xf02e1000
f010569d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01056a0:	83 ec 0c             	sub    $0xc,%esp
f01056a3:	68 10 7e 10 f0       	push   $0xf0107e10
f01056a8:	e8 a4 df ff ff       	call   f0103651 <cprintf>
		return;
f01056ad:	83 c4 10             	add    $0x10,%esp
f01056b0:	eb 48                	jmp    f01056fa <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01056b2:	83 ec 04             	sub    $0x4,%esp
f01056b5:	ff 35 c4 03 2a f0    	pushl  0xf02a03c4
f01056bb:	0f b6 00             	movzbl (%eax),%eax
f01056be:	50                   	push   %eax
f01056bf:	68 97 7e 10 f0       	push   $0xf0107e97
f01056c4:	e8 88 df ff ff       	call   f0103651 <cprintf>

	if (mp->imcrp) {
f01056c9:	83 c4 10             	add    $0x10,%esp
f01056cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056cf:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01056d3:	74 25                	je     f01056fa <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01056d5:	83 ec 0c             	sub    $0xc,%esp
f01056d8:	68 3c 7e 10 f0       	push   $0xf0107e3c
f01056dd:	e8 6f df ff ff       	call   f0103651 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01056e2:	ba 22 00 00 00       	mov    $0x22,%edx
f01056e7:	b8 70 00 00 00       	mov    $0x70,%eax
f01056ec:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01056ed:	ba 23 00 00 00       	mov    $0x23,%edx
f01056f2:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01056f3:	83 c8 01             	or     $0x1,%eax
f01056f6:	ee                   	out    %al,(%dx)
f01056f7:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01056fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01056fd:	5b                   	pop    %ebx
f01056fe:	5e                   	pop    %esi
f01056ff:	5f                   	pop    %edi
f0105700:	5d                   	pop    %ebp
f0105701:	c3                   	ret    

f0105702 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105702:	55                   	push   %ebp
f0105703:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105705:	8b 0d 04 10 2e f0    	mov    0xf02e1004,%ecx
f010570b:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010570e:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105710:	a1 04 10 2e f0       	mov    0xf02e1004,%eax
f0105715:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105718:	5d                   	pop    %ebp
f0105719:	c3                   	ret    

f010571a <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010571a:	55                   	push   %ebp
f010571b:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010571d:	a1 04 10 2e f0       	mov    0xf02e1004,%eax
f0105722:	85 c0                	test   %eax,%eax
f0105724:	74 08                	je     f010572e <cpunum+0x14>
		return lapic[ID] >> 24;
f0105726:	8b 40 20             	mov    0x20(%eax),%eax
f0105729:	c1 e8 18             	shr    $0x18,%eax
f010572c:	eb 05                	jmp    f0105733 <cpunum+0x19>
	return 0;
f010572e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105733:	5d                   	pop    %ebp
f0105734:	c3                   	ret    

f0105735 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105735:	a1 00 10 2e f0       	mov    0xf02e1000,%eax
f010573a:	85 c0                	test   %eax,%eax
f010573c:	0f 84 21 01 00 00    	je     f0105863 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105742:	55                   	push   %ebp
f0105743:	89 e5                	mov    %esp,%ebp
f0105745:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105748:	68 00 10 00 00       	push   $0x1000
f010574d:	50                   	push   %eax
f010574e:	e8 5f bb ff ff       	call   f01012b2 <mmio_map_region>
f0105753:	a3 04 10 2e f0       	mov    %eax,0xf02e1004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105758:	ba 27 01 00 00       	mov    $0x127,%edx
f010575d:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105762:	e8 9b ff ff ff       	call   f0105702 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105767:	ba 0b 00 00 00       	mov    $0xb,%edx
f010576c:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105771:	e8 8c ff ff ff       	call   f0105702 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105776:	ba 20 00 02 00       	mov    $0x20020,%edx
f010577b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105780:	e8 7d ff ff ff       	call   f0105702 <lapicw>
	lapicw(TICR, 10000000); 
f0105785:	ba 80 96 98 00       	mov    $0x989680,%edx
f010578a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010578f:	e8 6e ff ff ff       	call   f0105702 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105794:	e8 81 ff ff ff       	call   f010571a <cpunum>
f0105799:	6b c0 74             	imul   $0x74,%eax,%eax
f010579c:	05 20 00 2a f0       	add    $0xf02a0020,%eax
f01057a1:	83 c4 10             	add    $0x10,%esp
f01057a4:	39 05 c0 03 2a f0    	cmp    %eax,0xf02a03c0
f01057aa:	74 0f                	je     f01057bb <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f01057ac:	ba 00 00 01 00       	mov    $0x10000,%edx
f01057b1:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01057b6:	e8 47 ff ff ff       	call   f0105702 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01057bb:	ba 00 00 01 00       	mov    $0x10000,%edx
f01057c0:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01057c5:	e8 38 ff ff ff       	call   f0105702 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01057ca:	a1 04 10 2e f0       	mov    0xf02e1004,%eax
f01057cf:	8b 40 30             	mov    0x30(%eax),%eax
f01057d2:	c1 e8 10             	shr    $0x10,%eax
f01057d5:	3c 03                	cmp    $0x3,%al
f01057d7:	76 0f                	jbe    f01057e8 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f01057d9:	ba 00 00 01 00       	mov    $0x10000,%edx
f01057de:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01057e3:	e8 1a ff ff ff       	call   f0105702 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01057e8:	ba 33 00 00 00       	mov    $0x33,%edx
f01057ed:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01057f2:	e8 0b ff ff ff       	call   f0105702 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01057f7:	ba 00 00 00 00       	mov    $0x0,%edx
f01057fc:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105801:	e8 fc fe ff ff       	call   f0105702 <lapicw>
	lapicw(ESR, 0);
f0105806:	ba 00 00 00 00       	mov    $0x0,%edx
f010580b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105810:	e8 ed fe ff ff       	call   f0105702 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105815:	ba 00 00 00 00       	mov    $0x0,%edx
f010581a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010581f:	e8 de fe ff ff       	call   f0105702 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105824:	ba 00 00 00 00       	mov    $0x0,%edx
f0105829:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010582e:	e8 cf fe ff ff       	call   f0105702 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105833:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105838:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010583d:	e8 c0 fe ff ff       	call   f0105702 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105842:	8b 15 04 10 2e f0    	mov    0xf02e1004,%edx
f0105848:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010584e:	f6 c4 10             	test   $0x10,%ah
f0105851:	75 f5                	jne    f0105848 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105853:	ba 00 00 00 00       	mov    $0x0,%edx
f0105858:	b8 20 00 00 00       	mov    $0x20,%eax
f010585d:	e8 a0 fe ff ff       	call   f0105702 <lapicw>
}
f0105862:	c9                   	leave  
f0105863:	f3 c3                	repz ret 

f0105865 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105865:	83 3d 04 10 2e f0 00 	cmpl   $0x0,0xf02e1004
f010586c:	74 13                	je     f0105881 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010586e:	55                   	push   %ebp
f010586f:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105871:	ba 00 00 00 00       	mov    $0x0,%edx
f0105876:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010587b:	e8 82 fe ff ff       	call   f0105702 <lapicw>
}
f0105880:	5d                   	pop    %ebp
f0105881:	f3 c3                	repz ret 

f0105883 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105883:	55                   	push   %ebp
f0105884:	89 e5                	mov    %esp,%ebp
f0105886:	56                   	push   %esi
f0105887:	53                   	push   %ebx
f0105888:	8b 75 08             	mov    0x8(%ebp),%esi
f010588b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010588e:	ba 70 00 00 00       	mov    $0x70,%edx
f0105893:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105898:	ee                   	out    %al,(%dx)
f0105899:	ba 71 00 00 00       	mov    $0x71,%edx
f010589e:	b8 0a 00 00 00       	mov    $0xa,%eax
f01058a3:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01058a4:	83 3d 94 fe 29 f0 00 	cmpl   $0x0,0xf029fe94
f01058ab:	75 19                	jne    f01058c6 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01058ad:	68 67 04 00 00       	push   $0x467
f01058b2:	68 44 63 10 f0       	push   $0xf0106344
f01058b7:	68 98 00 00 00       	push   $0x98
f01058bc:	68 b4 7e 10 f0       	push   $0xf0107eb4
f01058c1:	e8 7a a7 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01058c6:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01058cd:	00 00 
	wrv[1] = addr >> 4;
f01058cf:	89 d8                	mov    %ebx,%eax
f01058d1:	c1 e8 04             	shr    $0x4,%eax
f01058d4:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01058da:	c1 e6 18             	shl    $0x18,%esi
f01058dd:	89 f2                	mov    %esi,%edx
f01058df:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01058e4:	e8 19 fe ff ff       	call   f0105702 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01058e9:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01058ee:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01058f3:	e8 0a fe ff ff       	call   f0105702 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01058f8:	ba 00 85 00 00       	mov    $0x8500,%edx
f01058fd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105902:	e8 fb fd ff ff       	call   f0105702 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105907:	c1 eb 0c             	shr    $0xc,%ebx
f010590a:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010590d:	89 f2                	mov    %esi,%edx
f010590f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105914:	e8 e9 fd ff ff       	call   f0105702 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105919:	89 da                	mov    %ebx,%edx
f010591b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105920:	e8 dd fd ff ff       	call   f0105702 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105925:	89 f2                	mov    %esi,%edx
f0105927:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010592c:	e8 d1 fd ff ff       	call   f0105702 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105931:	89 da                	mov    %ebx,%edx
f0105933:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105938:	e8 c5 fd ff ff       	call   f0105702 <lapicw>
		microdelay(200);
	}
}
f010593d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105940:	5b                   	pop    %ebx
f0105941:	5e                   	pop    %esi
f0105942:	5d                   	pop    %ebp
f0105943:	c3                   	ret    

f0105944 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105944:	55                   	push   %ebp
f0105945:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105947:	8b 55 08             	mov    0x8(%ebp),%edx
f010594a:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105950:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105955:	e8 a8 fd ff ff       	call   f0105702 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010595a:	8b 15 04 10 2e f0    	mov    0xf02e1004,%edx
f0105960:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105966:	f6 c4 10             	test   $0x10,%ah
f0105969:	75 f5                	jne    f0105960 <lapic_ipi+0x1c>
		;
}
f010596b:	5d                   	pop    %ebp
f010596c:	c3                   	ret    

f010596d <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010596d:	55                   	push   %ebp
f010596e:	89 e5                	mov    %esp,%ebp
f0105970:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105973:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105979:	8b 55 0c             	mov    0xc(%ebp),%edx
f010597c:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010597f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105986:	5d                   	pop    %ebp
f0105987:	c3                   	ret    

f0105988 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105988:	55                   	push   %ebp
f0105989:	89 e5                	mov    %esp,%ebp
f010598b:	56                   	push   %esi
f010598c:	53                   	push   %ebx
f010598d:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105990:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105993:	74 14                	je     f01059a9 <spin_lock+0x21>
f0105995:	8b 73 08             	mov    0x8(%ebx),%esi
f0105998:	e8 7d fd ff ff       	call   f010571a <cpunum>
f010599d:	6b c0 74             	imul   $0x74,%eax,%eax
f01059a0:	05 20 00 2a f0       	add    $0xf02a0020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01059a5:	39 c6                	cmp    %eax,%esi
f01059a7:	74 07                	je     f01059b0 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01059a9:	ba 01 00 00 00       	mov    $0x1,%edx
f01059ae:	eb 20                	jmp    f01059d0 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01059b0:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01059b3:	e8 62 fd ff ff       	call   f010571a <cpunum>
f01059b8:	83 ec 0c             	sub    $0xc,%esp
f01059bb:	53                   	push   %ebx
f01059bc:	50                   	push   %eax
f01059bd:	68 c4 7e 10 f0       	push   $0xf0107ec4
f01059c2:	6a 41                	push   $0x41
f01059c4:	68 26 7f 10 f0       	push   $0xf0107f26
f01059c9:	e8 72 a6 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01059ce:	f3 90                	pause  
f01059d0:	89 d0                	mov    %edx,%eax
f01059d2:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01059d5:	85 c0                	test   %eax,%eax
f01059d7:	75 f5                	jne    f01059ce <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01059d9:	e8 3c fd ff ff       	call   f010571a <cpunum>
f01059de:	6b c0 74             	imul   $0x74,%eax,%eax
f01059e1:	05 20 00 2a f0       	add    $0xf02a0020,%eax
f01059e6:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01059e9:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01059ec:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01059ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01059f3:	eb 0b                	jmp    f0105a00 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01059f5:	8b 4a 04             	mov    0x4(%edx),%ecx
f01059f8:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01059fb:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01059fd:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105a00:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105a06:	76 11                	jbe    f0105a19 <spin_lock+0x91>
f0105a08:	83 f8 09             	cmp    $0x9,%eax
f0105a0b:	7e e8                	jle    f01059f5 <spin_lock+0x6d>
f0105a0d:	eb 0a                	jmp    f0105a19 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105a0f:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105a16:	83 c0 01             	add    $0x1,%eax
f0105a19:	83 f8 09             	cmp    $0x9,%eax
f0105a1c:	7e f1                	jle    f0105a0f <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105a1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105a21:	5b                   	pop    %ebx
f0105a22:	5e                   	pop    %esi
f0105a23:	5d                   	pop    %ebp
f0105a24:	c3                   	ret    

f0105a25 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105a25:	55                   	push   %ebp
f0105a26:	89 e5                	mov    %esp,%ebp
f0105a28:	57                   	push   %edi
f0105a29:	56                   	push   %esi
f0105a2a:	53                   	push   %ebx
f0105a2b:	83 ec 4c             	sub    $0x4c,%esp
f0105a2e:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105a31:	83 3e 00             	cmpl   $0x0,(%esi)
f0105a34:	74 18                	je     f0105a4e <spin_unlock+0x29>
f0105a36:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105a39:	e8 dc fc ff ff       	call   f010571a <cpunum>
f0105a3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a41:	05 20 00 2a f0       	add    $0xf02a0020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105a46:	39 c3                	cmp    %eax,%ebx
f0105a48:	0f 84 a5 00 00 00    	je     f0105af3 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105a4e:	83 ec 04             	sub    $0x4,%esp
f0105a51:	6a 28                	push   $0x28
f0105a53:	8d 46 0c             	lea    0xc(%esi),%eax
f0105a56:	50                   	push   %eax
f0105a57:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105a5a:	53                   	push   %ebx
f0105a5b:	e8 e4 f6 ff ff       	call   f0105144 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105a60:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105a63:	0f b6 38             	movzbl (%eax),%edi
f0105a66:	8b 76 04             	mov    0x4(%esi),%esi
f0105a69:	e8 ac fc ff ff       	call   f010571a <cpunum>
f0105a6e:	57                   	push   %edi
f0105a6f:	56                   	push   %esi
f0105a70:	50                   	push   %eax
f0105a71:	68 f0 7e 10 f0       	push   $0xf0107ef0
f0105a76:	e8 d6 db ff ff       	call   f0103651 <cprintf>
f0105a7b:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105a7e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105a81:	eb 54                	jmp    f0105ad7 <spin_unlock+0xb2>
f0105a83:	83 ec 08             	sub    $0x8,%esp
f0105a86:	57                   	push   %edi
f0105a87:	50                   	push   %eax
f0105a88:	e8 89 ec ff ff       	call   f0104716 <debuginfo_eip>
f0105a8d:	83 c4 10             	add    $0x10,%esp
f0105a90:	85 c0                	test   %eax,%eax
f0105a92:	78 27                	js     f0105abb <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105a94:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105a96:	83 ec 04             	sub    $0x4,%esp
f0105a99:	89 c2                	mov    %eax,%edx
f0105a9b:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105a9e:	52                   	push   %edx
f0105a9f:	ff 75 b0             	pushl  -0x50(%ebp)
f0105aa2:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105aa5:	ff 75 ac             	pushl  -0x54(%ebp)
f0105aa8:	ff 75 a8             	pushl  -0x58(%ebp)
f0105aab:	50                   	push   %eax
f0105aac:	68 36 7f 10 f0       	push   $0xf0107f36
f0105ab1:	e8 9b db ff ff       	call   f0103651 <cprintf>
f0105ab6:	83 c4 20             	add    $0x20,%esp
f0105ab9:	eb 12                	jmp    f0105acd <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105abb:	83 ec 08             	sub    $0x8,%esp
f0105abe:	ff 36                	pushl  (%esi)
f0105ac0:	68 4d 7f 10 f0       	push   $0xf0107f4d
f0105ac5:	e8 87 db ff ff       	call   f0103651 <cprintf>
f0105aca:	83 c4 10             	add    $0x10,%esp
f0105acd:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105ad0:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105ad3:	39 c3                	cmp    %eax,%ebx
f0105ad5:	74 08                	je     f0105adf <spin_unlock+0xba>
f0105ad7:	89 de                	mov    %ebx,%esi
f0105ad9:	8b 03                	mov    (%ebx),%eax
f0105adb:	85 c0                	test   %eax,%eax
f0105add:	75 a4                	jne    f0105a83 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105adf:	83 ec 04             	sub    $0x4,%esp
f0105ae2:	68 55 7f 10 f0       	push   $0xf0107f55
f0105ae7:	6a 67                	push   $0x67
f0105ae9:	68 26 7f 10 f0       	push   $0xf0107f26
f0105aee:	e8 4d a5 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105af3:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105afa:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105b01:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b06:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105b09:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b0c:	5b                   	pop    %ebx
f0105b0d:	5e                   	pop    %esi
f0105b0e:	5f                   	pop    %edi
f0105b0f:	5d                   	pop    %ebp
f0105b10:	c3                   	ret    

f0105b11 <e1000_attach>:
#include <kern/e1000.h>

// LAB 6: Your driver code here

int e1000_attach(struct pci_func *pcif){
f0105b11:	55                   	push   %ebp
f0105b12:	89 e5                	mov    %esp,%ebp
f0105b14:	83 ec 14             	sub    $0x14,%esp
	pci_func_enable(pcif);
f0105b17:	ff 75 08             	pushl  0x8(%ebp)
f0105b1a:	e8 cd 03 00 00       	call   f0105eec <pci_func_enable>
	return 0;
}
f0105b1f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b24:	c9                   	leave  
f0105b25:	c3                   	ret    

f0105b26 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f0105b26:	55                   	push   %ebp
f0105b27:	89 e5                	mov    %esp,%ebp
f0105b29:	57                   	push   %edi
f0105b2a:	56                   	push   %esi
f0105b2b:	53                   	push   %ebx
f0105b2c:	83 ec 0c             	sub    $0xc,%esp
f0105b2f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105b32:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b35:	8d 58 08             	lea    0x8(%eax),%ebx
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0105b38:	eb 3a                	jmp    f0105b74 <pci_attach_match+0x4e>
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f0105b3a:	39 7b f8             	cmp    %edi,-0x8(%ebx)
f0105b3d:	75 32                	jne    f0105b71 <pci_attach_match+0x4b>
f0105b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b42:	39 56 fc             	cmp    %edx,-0x4(%esi)
f0105b45:	75 2a                	jne    f0105b71 <pci_attach_match+0x4b>
			int r = list[i].attachfn(pcif);
f0105b47:	83 ec 0c             	sub    $0xc,%esp
f0105b4a:	ff 75 14             	pushl  0x14(%ebp)
f0105b4d:	ff d0                	call   *%eax
			if (r > 0)
f0105b4f:	83 c4 10             	add    $0x10,%esp
f0105b52:	85 c0                	test   %eax,%eax
f0105b54:	7f 26                	jg     f0105b7c <pci_attach_match+0x56>
				return r;
			if (r < 0)
f0105b56:	85 c0                	test   %eax,%eax
f0105b58:	79 17                	jns    f0105b71 <pci_attach_match+0x4b>
				cprintf("pci_attach_match: attaching "
f0105b5a:	83 ec 0c             	sub    $0xc,%esp
f0105b5d:	50                   	push   %eax
f0105b5e:	ff 36                	pushl  (%esi)
f0105b60:	ff 75 0c             	pushl  0xc(%ebp)
f0105b63:	57                   	push   %edi
f0105b64:	68 70 7f 10 f0       	push   $0xf0107f70
f0105b69:	e8 e3 da ff ff       	call   f0103651 <cprintf>
f0105b6e:	83 c4 20             	add    $0x20,%esp
f0105b71:	83 c3 0c             	add    $0xc,%ebx
f0105b74:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;

	for (i = 0; list[i].attachfn; i++) {
f0105b76:	8b 03                	mov    (%ebx),%eax
f0105b78:	85 c0                	test   %eax,%eax
f0105b7a:	75 be                	jne    f0105b3a <pci_attach_match+0x14>
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f0105b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b7f:	5b                   	pop    %ebx
f0105b80:	5e                   	pop    %esi
f0105b81:	5f                   	pop    %edi
f0105b82:	5d                   	pop    %ebp
f0105b83:	c3                   	ret    

f0105b84 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f0105b84:	55                   	push   %ebp
f0105b85:	89 e5                	mov    %esp,%ebp
f0105b87:	53                   	push   %ebx
f0105b88:	83 ec 04             	sub    $0x4,%esp
f0105b8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f0105b8e:	3d ff 00 00 00       	cmp    $0xff,%eax
f0105b93:	76 16                	jbe    f0105bab <pci_conf1_set_addr+0x27>
f0105b95:	68 c8 80 10 f0       	push   $0xf01080c8
f0105b9a:	68 7d 72 10 f0       	push   $0xf010727d
f0105b9f:	6a 2c                	push   $0x2c
f0105ba1:	68 d2 80 10 f0       	push   $0xf01080d2
f0105ba6:	e8 95 a4 ff ff       	call   f0100040 <_panic>
	assert(dev < 32);
f0105bab:	83 fa 1f             	cmp    $0x1f,%edx
f0105bae:	76 16                	jbe    f0105bc6 <pci_conf1_set_addr+0x42>
f0105bb0:	68 dd 80 10 f0       	push   $0xf01080dd
f0105bb5:	68 7d 72 10 f0       	push   $0xf010727d
f0105bba:	6a 2d                	push   $0x2d
f0105bbc:	68 d2 80 10 f0       	push   $0xf01080d2
f0105bc1:	e8 7a a4 ff ff       	call   f0100040 <_panic>
	assert(func < 8);
f0105bc6:	83 f9 07             	cmp    $0x7,%ecx
f0105bc9:	76 16                	jbe    f0105be1 <pci_conf1_set_addr+0x5d>
f0105bcb:	68 e6 80 10 f0       	push   $0xf01080e6
f0105bd0:	68 7d 72 10 f0       	push   $0xf010727d
f0105bd5:	6a 2e                	push   $0x2e
f0105bd7:	68 d2 80 10 f0       	push   $0xf01080d2
f0105bdc:	e8 5f a4 ff ff       	call   f0100040 <_panic>
	assert(offset < 256);
f0105be1:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f0105be7:	76 16                	jbe    f0105bff <pci_conf1_set_addr+0x7b>
f0105be9:	68 ef 80 10 f0       	push   $0xf01080ef
f0105bee:	68 7d 72 10 f0       	push   $0xf010727d
f0105bf3:	6a 2f                	push   $0x2f
f0105bf5:	68 d2 80 10 f0       	push   $0xf01080d2
f0105bfa:	e8 41 a4 ff ff       	call   f0100040 <_panic>
	assert((offset & 0x3) == 0);
f0105bff:	f6 c3 03             	test   $0x3,%bl
f0105c02:	74 16                	je     f0105c1a <pci_conf1_set_addr+0x96>
f0105c04:	68 fc 80 10 f0       	push   $0xf01080fc
f0105c09:	68 7d 72 10 f0       	push   $0xf010727d
f0105c0e:	6a 30                	push   $0x30
f0105c10:	68 d2 80 10 f0       	push   $0xf01080d2
f0105c15:	e8 26 a4 ff ff       	call   f0100040 <_panic>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0105c1a:	c1 e1 08             	shl    $0x8,%ecx
f0105c1d:	81 cb 00 00 00 80    	or     $0x80000000,%ebx
f0105c23:	09 cb                	or     %ecx,%ebx
f0105c25:	c1 e2 0b             	shl    $0xb,%edx
f0105c28:	09 d3                	or     %edx,%ebx
f0105c2a:	c1 e0 10             	shl    $0x10,%eax
f0105c2d:	09 d8                	or     %ebx,%eax
f0105c2f:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f0105c34:	ef                   	out    %eax,(%dx)

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f0105c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105c38:	c9                   	leave  
f0105c39:	c3                   	ret    

f0105c3a <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f0105c3a:	55                   	push   %ebp
f0105c3b:	89 e5                	mov    %esp,%ebp
f0105c3d:	53                   	push   %ebx
f0105c3e:	83 ec 10             	sub    $0x10,%esp
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0105c41:	8b 48 08             	mov    0x8(%eax),%ecx
f0105c44:	8b 58 04             	mov    0x4(%eax),%ebx
f0105c47:	8b 00                	mov    (%eax),%eax
f0105c49:	8b 40 04             	mov    0x4(%eax),%eax
f0105c4c:	52                   	push   %edx
f0105c4d:	89 da                	mov    %ebx,%edx
f0105c4f:	e8 30 ff ff ff       	call   f0105b84 <pci_conf1_set_addr>

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f0105c54:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0105c59:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f0105c5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105c5d:	c9                   	leave  
f0105c5e:	c3                   	ret    

f0105c5f <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f0105c5f:	55                   	push   %ebp
f0105c60:	89 e5                	mov    %esp,%ebp
f0105c62:	57                   	push   %edi
f0105c63:	56                   	push   %esi
f0105c64:	53                   	push   %ebx
f0105c65:	81 ec 00 01 00 00    	sub    $0x100,%esp
f0105c6b:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f0105c6d:	6a 48                	push   $0x48
f0105c6f:	6a 00                	push   $0x0
f0105c71:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0105c74:	50                   	push   %eax
f0105c75:	e8 7d f4 ff ff       	call   f01050f7 <memset>
	df.bus = bus;
f0105c7a:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0105c7d:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0105c84:	83 c4 10             	add    $0x10,%esp
}

static int
pci_scan_bus(struct pci_bus *bus)
{
	int totaldev = 0;
f0105c87:	c7 85 00 ff ff ff 00 	movl   $0x0,-0x100(%ebp)
f0105c8e:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0105c91:	ba 0c 00 00 00       	mov    $0xc,%edx
f0105c96:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0105c99:	e8 9c ff ff ff       	call   f0105c3a <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f0105c9e:	89 c2                	mov    %eax,%edx
f0105ca0:	c1 ea 10             	shr    $0x10,%edx
f0105ca3:	83 e2 7f             	and    $0x7f,%edx
f0105ca6:	83 fa 01             	cmp    $0x1,%edx
f0105ca9:	0f 87 4b 01 00 00    	ja     f0105dfa <pci_scan_bus+0x19b>
			continue;

		totaldev++;
f0105caf:	83 85 00 ff ff ff 01 	addl   $0x1,-0x100(%ebp)

		struct pci_func f = df;
f0105cb6:	8d bd 10 ff ff ff    	lea    -0xf0(%ebp),%edi
f0105cbc:	8d 75 a0             	lea    -0x60(%ebp),%esi
f0105cbf:	b9 12 00 00 00       	mov    $0x12,%ecx
f0105cc4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0105cc6:	c7 85 18 ff ff ff 00 	movl   $0x0,-0xe8(%ebp)
f0105ccd:	00 00 00 
f0105cd0:	25 00 00 80 00       	and    $0x800000,%eax
f0105cd5:	83 f8 01             	cmp    $0x1,%eax
f0105cd8:	19 c0                	sbb    %eax,%eax
f0105cda:	83 e0 f9             	and    $0xfffffff9,%eax
f0105cdd:	83 c0 08             	add    $0x8,%eax
f0105ce0:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
			if (PCI_VENDOR(af.dev_id) == 0xffff)
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0105ce6:	8d 9d 58 ff ff ff    	lea    -0xa8(%ebp),%ebx
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0105cec:	e9 f7 00 00 00       	jmp    f0105de8 <pci_scan_bus+0x189>
		     f.func++) {
			struct pci_func af = f;
f0105cf1:	8d bd 58 ff ff ff    	lea    -0xa8(%ebp),%edi
f0105cf7:	8d b5 10 ff ff ff    	lea    -0xf0(%ebp),%esi
f0105cfd:	b9 12 00 00 00       	mov    $0x12,%ecx
f0105d02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f0105d04:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d09:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f0105d0f:	e8 26 ff ff ff       	call   f0105c3a <pci_conf_read>
f0105d14:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f0105d1a:	66 83 f8 ff          	cmp    $0xffff,%ax
f0105d1e:	0f 84 bd 00 00 00    	je     f0105de1 <pci_scan_bus+0x182>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f0105d24:	ba 3c 00 00 00       	mov    $0x3c,%edx
f0105d29:	89 d8                	mov    %ebx,%eax
f0105d2b:	e8 0a ff ff ff       	call   f0105c3a <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f0105d30:	88 45 9c             	mov    %al,-0x64(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f0105d33:	ba 08 00 00 00       	mov    $0x8,%edx
f0105d38:	89 d8                	mov    %ebx,%eax
f0105d3a:	e8 fb fe ff ff       	call   f0105c3a <pci_conf_read>
f0105d3f:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f0105d45:	89 c1                	mov    %eax,%ecx
f0105d47:	c1 e9 18             	shr    $0x18,%ecx
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f0105d4a:	be 10 81 10 f0       	mov    $0xf0108110,%esi
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f0105d4f:	83 f9 06             	cmp    $0x6,%ecx
f0105d52:	77 07                	ja     f0105d5b <pci_scan_bus+0xfc>
		class = pci_class[PCI_CLASS(f->dev_class)];
f0105d54:	8b 34 8d 84 81 10 f0 	mov    -0xfef7e7c(,%ecx,4),%esi

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0105d5b:	8b 95 64 ff ff ff    	mov    -0x9c(%ebp),%edx
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0105d61:	83 ec 08             	sub    $0x8,%esp
f0105d64:	0f b6 7d 9c          	movzbl -0x64(%ebp),%edi
f0105d68:	57                   	push   %edi
f0105d69:	56                   	push   %esi
f0105d6a:	c1 e8 10             	shr    $0x10,%eax
f0105d6d:	0f b6 c0             	movzbl %al,%eax
f0105d70:	50                   	push   %eax
f0105d71:	51                   	push   %ecx
f0105d72:	89 d0                	mov    %edx,%eax
f0105d74:	c1 e8 10             	shr    $0x10,%eax
f0105d77:	50                   	push   %eax
f0105d78:	0f b7 d2             	movzwl %dx,%edx
f0105d7b:	52                   	push   %edx
f0105d7c:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
f0105d82:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
f0105d88:	8b 85 58 ff ff ff    	mov    -0xa8(%ebp),%eax
f0105d8e:	ff 70 04             	pushl  0x4(%eax)
f0105d91:	68 9c 7f 10 f0       	push   $0xf0107f9c
f0105d96:	e8 b6 d8 ff ff       	call   f0103651 <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f0105d9b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0105da1:	83 c4 30             	add    $0x30,%esp
f0105da4:	53                   	push   %ebx
f0105da5:	68 ac 24 12 f0       	push   $0xf01224ac
f0105daa:	89 c2                	mov    %eax,%edx
f0105dac:	c1 ea 10             	shr    $0x10,%edx
f0105daf:	0f b6 d2             	movzbl %dl,%edx
f0105db2:	52                   	push   %edx
f0105db3:	c1 e8 18             	shr    $0x18,%eax
f0105db6:	50                   	push   %eax
f0105db7:	e8 6a fd ff ff       	call   f0105b26 <pci_attach_match>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
f0105dbc:	83 c4 10             	add    $0x10,%esp
f0105dbf:	85 c0                	test   %eax,%eax
f0105dc1:	75 1e                	jne    f0105de1 <pci_scan_bus+0x182>
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f0105dc3:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
f0105dc9:	53                   	push   %ebx
f0105dca:	68 94 24 12 f0       	push   $0xf0122494
f0105dcf:	89 c2                	mov    %eax,%edx
f0105dd1:	c1 ea 10             	shr    $0x10,%edx
f0105dd4:	52                   	push   %edx
f0105dd5:	0f b7 c0             	movzwl %ax,%eax
f0105dd8:	50                   	push   %eax
f0105dd9:	e8 48 fd ff ff       	call   f0105b26 <pci_attach_match>
f0105dde:	83 c4 10             	add    $0x10,%esp

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f0105de1:	83 85 18 ff ff ff 01 	addl   $0x1,-0xe8(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0105de8:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f0105dee:	3b 85 18 ff ff ff    	cmp    -0xe8(%ebp),%eax
f0105df4:	0f 87 f7 fe ff ff    	ja     f0105cf1 <pci_scan_bus+0x92>
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0105dfa:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0105dfd:	83 c0 01             	add    $0x1,%eax
f0105e00:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0105e03:	83 f8 1f             	cmp    $0x1f,%eax
f0105e06:	0f 86 85 fe ff ff    	jbe    f0105c91 <pci_scan_bus+0x32>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f0105e0c:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f0105e12:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e15:	5b                   	pop    %ebx
f0105e16:	5e                   	pop    %esi
f0105e17:	5f                   	pop    %edi
f0105e18:	5d                   	pop    %ebp
f0105e19:	c3                   	ret    

f0105e1a <pci_bridge_attach>:

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0105e1a:	55                   	push   %ebp
f0105e1b:	89 e5                	mov    %esp,%ebp
f0105e1d:	57                   	push   %edi
f0105e1e:	56                   	push   %esi
f0105e1f:	53                   	push   %ebx
f0105e20:	83 ec 1c             	sub    $0x1c,%esp
f0105e23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f0105e26:	ba 1c 00 00 00       	mov    $0x1c,%edx
f0105e2b:	89 d8                	mov    %ebx,%eax
f0105e2d:	e8 08 fe ff ff       	call   f0105c3a <pci_conf_read>
f0105e32:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f0105e34:	ba 18 00 00 00       	mov    $0x18,%edx
f0105e39:	89 d8                	mov    %ebx,%eax
f0105e3b:	e8 fa fd ff ff       	call   f0105c3a <pci_conf_read>

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f0105e40:	83 e7 0f             	and    $0xf,%edi
f0105e43:	83 ff 01             	cmp    $0x1,%edi
f0105e46:	75 1f                	jne    f0105e67 <pci_bridge_attach+0x4d>
		cprintf("PCI: %02x:%02x.%d: 32-bit bridge IO not supported.\n",
f0105e48:	ff 73 08             	pushl  0x8(%ebx)
f0105e4b:	ff 73 04             	pushl  0x4(%ebx)
f0105e4e:	8b 03                	mov    (%ebx),%eax
f0105e50:	ff 70 04             	pushl  0x4(%eax)
f0105e53:	68 d8 7f 10 f0       	push   $0xf0107fd8
f0105e58:	e8 f4 d7 ff ff       	call   f0103651 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f0105e5d:	83 c4 10             	add    $0x10,%esp
f0105e60:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e65:	eb 4e                	jmp    f0105eb5 <pci_bridge_attach+0x9b>
f0105e67:	89 c6                	mov    %eax,%esi
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0105e69:	83 ec 04             	sub    $0x4,%esp
f0105e6c:	6a 08                	push   $0x8
f0105e6e:	6a 00                	push   $0x0
f0105e70:	8d 7d e0             	lea    -0x20(%ebp),%edi
f0105e73:	57                   	push   %edi
f0105e74:	e8 7e f2 ff ff       	call   f01050f7 <memset>
	nbus.parent_bridge = pcif;
f0105e79:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0105e7c:	89 f0                	mov    %esi,%eax
f0105e7e:	0f b6 c4             	movzbl %ah,%eax
f0105e81:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0105e84:	83 c4 08             	add    $0x8,%esp
f0105e87:	89 f2                	mov    %esi,%edx
f0105e89:	c1 ea 10             	shr    $0x10,%edx
f0105e8c:	0f b6 f2             	movzbl %dl,%esi
f0105e8f:	56                   	push   %esi
f0105e90:	50                   	push   %eax
f0105e91:	ff 73 08             	pushl  0x8(%ebx)
f0105e94:	ff 73 04             	pushl  0x4(%ebx)
f0105e97:	8b 03                	mov    (%ebx),%eax
f0105e99:	ff 70 04             	pushl  0x4(%eax)
f0105e9c:	68 0c 80 10 f0       	push   $0xf010800c
f0105ea1:	e8 ab d7 ff ff       	call   f0103651 <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f0105ea6:	83 c4 20             	add    $0x20,%esp
f0105ea9:	89 f8                	mov    %edi,%eax
f0105eab:	e8 af fd ff ff       	call   f0105c5f <pci_scan_bus>
	return 1;
f0105eb0:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0105eb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105eb8:	5b                   	pop    %ebx
f0105eb9:	5e                   	pop    %esi
f0105eba:	5f                   	pop    %edi
f0105ebb:	5d                   	pop    %ebp
f0105ebc:	c3                   	ret    

f0105ebd <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f0105ebd:	55                   	push   %ebp
f0105ebe:	89 e5                	mov    %esp,%ebp
f0105ec0:	56                   	push   %esi
f0105ec1:	53                   	push   %ebx
f0105ec2:	89 cb                	mov    %ecx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0105ec4:	8b 48 08             	mov    0x8(%eax),%ecx
f0105ec7:	8b 70 04             	mov    0x4(%eax),%esi
f0105eca:	8b 00                	mov    (%eax),%eax
f0105ecc:	8b 40 04             	mov    0x4(%eax),%eax
f0105ecf:	83 ec 0c             	sub    $0xc,%esp
f0105ed2:	52                   	push   %edx
f0105ed3:	89 f2                	mov    %esi,%edx
f0105ed5:	e8 aa fc ff ff       	call   f0105b84 <pci_conf1_set_addr>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0105eda:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0105edf:	89 d8                	mov    %ebx,%eax
f0105ee1:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f0105ee2:	83 c4 10             	add    $0x10,%esp
f0105ee5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105ee8:	5b                   	pop    %ebx
f0105ee9:	5e                   	pop    %esi
f0105eea:	5d                   	pop    %ebp
f0105eeb:	c3                   	ret    

f0105eec <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f0105eec:	55                   	push   %ebp
f0105eed:	89 e5                	mov    %esp,%ebp
f0105eef:	57                   	push   %edi
f0105ef0:	56                   	push   %esi
f0105ef1:	53                   	push   %ebx
f0105ef2:	83 ec 1c             	sub    $0x1c,%esp
f0105ef5:	8b 7d 08             	mov    0x8(%ebp),%edi
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0105ef8:	b9 07 00 00 00       	mov    $0x7,%ecx
f0105efd:	ba 04 00 00 00       	mov    $0x4,%edx
f0105f02:	89 f8                	mov    %edi,%eax
f0105f04:	e8 b4 ff ff ff       	call   f0105ebd <pci_conf_write>
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0105f09:	be 10 00 00 00       	mov    $0x10,%esi
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f0105f0e:	89 f2                	mov    %esi,%edx
f0105f10:	89 f8                	mov    %edi,%eax
f0105f12:	e8 23 fd ff ff       	call   f0105c3a <pci_conf_read>
f0105f17:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f0105f1a:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0105f1f:	89 f2                	mov    %esi,%edx
f0105f21:	89 f8                	mov    %edi,%eax
f0105f23:	e8 95 ff ff ff       	call   f0105ebd <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0105f28:	89 f2                	mov    %esi,%edx
f0105f2a:	89 f8                	mov    %edi,%eax
f0105f2c:	e8 09 fd ff ff       	call   f0105c3a <pci_conf_read>
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0105f31:	bb 04 00 00 00       	mov    $0x4,%ebx
		pci_conf_write(f, bar, 0xffffffff);
		uint32_t rv = pci_conf_read(f, bar);

		if (rv == 0)
f0105f36:	85 c0                	test   %eax,%eax
f0105f38:	0f 84 a6 00 00 00    	je     f0105fe4 <pci_func_enable+0xf8>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f0105f3e:	8d 56 f0             	lea    -0x10(%esi),%edx
f0105f41:	c1 ea 02             	shr    $0x2,%edx
f0105f44:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f0105f47:	a8 01                	test   $0x1,%al
f0105f49:	75 2c                	jne    f0105f77 <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f0105f4b:	89 c2                	mov    %eax,%edx
f0105f4d:	83 e2 06             	and    $0x6,%edx
				bar_width = 8;
f0105f50:	83 fa 04             	cmp    $0x4,%edx
f0105f53:	0f 94 c3             	sete   %bl
f0105f56:	0f b6 db             	movzbl %bl,%ebx
f0105f59:	8d 1c 9d 04 00 00 00 	lea    0x4(,%ebx,4),%ebx

			size = PCI_MAPREG_MEM_SIZE(rv);
f0105f60:	83 e0 f0             	and    $0xfffffff0,%eax
f0105f63:	89 c2                	mov    %eax,%edx
f0105f65:	f7 da                	neg    %edx
f0105f67:	21 c2                	and    %eax,%edx
f0105f69:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f0105f6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f6f:	83 e0 f0             	and    $0xfffffff0,%eax
f0105f72:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105f75:	eb 1a                	jmp    f0105f91 <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0105f77:	83 e0 fc             	and    $0xfffffffc,%eax
f0105f7a:	89 c2                	mov    %eax,%edx
f0105f7c:	f7 da                	neg    %edx
f0105f7e:	21 c2                	and    %eax,%edx
f0105f80:	89 55 d8             	mov    %edx,-0x28(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f0105f83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f86:	83 e0 fc             	and    $0xfffffffc,%eax
f0105f89:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);

		bar_width = 4;
f0105f8c:	bb 04 00 00 00       	mov    $0x4,%ebx
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f0105f91:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105f94:	89 f2                	mov    %esi,%edx
f0105f96:	89 f8                	mov    %edi,%eax
f0105f98:	e8 20 ff ff ff       	call   f0105ebd <pci_conf_write>
f0105f9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105fa0:	8d 04 87             	lea    (%edi,%eax,4),%eax
		f->reg_base[regnum] = base;
f0105fa3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105fa6:	89 50 14             	mov    %edx,0x14(%eax)
		f->reg_size[regnum] = size;
f0105fa9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105fac:	89 48 2c             	mov    %ecx,0x2c(%eax)

		if (size && !base)
f0105faf:	85 c9                	test   %ecx,%ecx
f0105fb1:	74 31                	je     f0105fe4 <pci_func_enable+0xf8>
f0105fb3:	85 d2                	test   %edx,%edx
f0105fb5:	75 2d                	jne    f0105fe4 <pci_func_enable+0xf8>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0105fb7:	8b 47 0c             	mov    0xc(%edi),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0105fba:	83 ec 0c             	sub    $0xc,%esp
f0105fbd:	51                   	push   %ecx
f0105fbe:	52                   	push   %edx
f0105fbf:	ff 75 e0             	pushl  -0x20(%ebp)
f0105fc2:	89 c2                	mov    %eax,%edx
f0105fc4:	c1 ea 10             	shr    $0x10,%edx
f0105fc7:	52                   	push   %edx
f0105fc8:	0f b7 c0             	movzwl %ax,%eax
f0105fcb:	50                   	push   %eax
f0105fcc:	ff 77 08             	pushl  0x8(%edi)
f0105fcf:	ff 77 04             	pushl  0x4(%edi)
f0105fd2:	8b 07                	mov    (%edi),%eax
f0105fd4:	ff 70 04             	pushl  0x4(%eax)
f0105fd7:	68 3c 80 10 f0       	push   $0xf010803c
f0105fdc:	e8 70 d6 ff ff       	call   f0103651 <cprintf>
f0105fe1:	83 c4 30             	add    $0x30,%esp
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f0105fe4:	01 de                	add    %ebx,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0105fe6:	83 fe 27             	cmp    $0x27,%esi
f0105fe9:	0f 86 1f ff ff ff    	jbe    f0105f0e <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f0105fef:	8b 47 0c             	mov    0xc(%edi),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0105ff2:	83 ec 08             	sub    $0x8,%esp
f0105ff5:	89 c2                	mov    %eax,%edx
f0105ff7:	c1 ea 10             	shr    $0x10,%edx
f0105ffa:	52                   	push   %edx
f0105ffb:	0f b7 c0             	movzwl %ax,%eax
f0105ffe:	50                   	push   %eax
f0105fff:	ff 77 08             	pushl  0x8(%edi)
f0106002:	ff 77 04             	pushl  0x4(%edi)
f0106005:	8b 07                	mov    (%edi),%eax
f0106007:	ff 70 04             	pushl  0x4(%eax)
f010600a:	68 98 80 10 f0       	push   $0xf0108098
f010600f:	e8 3d d6 ff ff       	call   f0103651 <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0106014:	83 c4 20             	add    $0x20,%esp
f0106017:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010601a:	5b                   	pop    %ebx
f010601b:	5e                   	pop    %esi
f010601c:	5f                   	pop    %edi
f010601d:	5d                   	pop    %ebp
f010601e:	c3                   	ret    

f010601f <pci_init>:

int
pci_init(void)
{
f010601f:	55                   	push   %ebp
f0106020:	89 e5                	mov    %esp,%ebp
f0106022:	83 ec 0c             	sub    $0xc,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0106025:	6a 08                	push   $0x8
f0106027:	6a 00                	push   $0x0
f0106029:	68 80 fe 29 f0       	push   $0xf029fe80
f010602e:	e8 c4 f0 ff ff       	call   f01050f7 <memset>

	return pci_scan_bus(&root_bus);
f0106033:	b8 80 fe 29 f0       	mov    $0xf029fe80,%eax
f0106038:	e8 22 fc ff ff       	call   f0105c5f <pci_scan_bus>
}
f010603d:	c9                   	leave  
f010603e:	c3                   	ret    

f010603f <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f010603f:	55                   	push   %ebp
f0106040:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f0106042:	c7 05 88 fe 29 f0 00 	movl   $0x0,0xf029fe88
f0106049:	00 00 00 
}
f010604c:	5d                   	pop    %ebp
f010604d:	c3                   	ret    

f010604e <time_tick>:
// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
	ticks++;
f010604e:	a1 88 fe 29 f0       	mov    0xf029fe88,%eax
f0106053:	83 c0 01             	add    $0x1,%eax
f0106056:	a3 88 fe 29 f0       	mov    %eax,0xf029fe88
	if (ticks * 10 < ticks)
f010605b:	8d 14 80             	lea    (%eax,%eax,4),%edx
f010605e:	01 d2                	add    %edx,%edx
f0106060:	39 d0                	cmp    %edx,%eax
f0106062:	76 17                	jbe    f010607b <time_tick+0x2d>

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f0106064:	55                   	push   %ebp
f0106065:	89 e5                	mov    %esp,%ebp
f0106067:	83 ec 0c             	sub    $0xc,%esp
	ticks++;
	if (ticks * 10 < ticks)
		panic("time_tick: time overflowed");
f010606a:	68 a0 81 10 f0       	push   $0xf01081a0
f010606f:	6a 13                	push   $0x13
f0106071:	68 bb 81 10 f0       	push   $0xf01081bb
f0106076:	e8 c5 9f ff ff       	call   f0100040 <_panic>
f010607b:	f3 c3                	repz ret 

f010607d <time_msec>:
}

unsigned int
time_msec(void)
{
f010607d:	55                   	push   %ebp
f010607e:	89 e5                	mov    %esp,%ebp
	return ticks * 10;
f0106080:	a1 88 fe 29 f0       	mov    0xf029fe88,%eax
f0106085:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0106088:	01 c0                	add    %eax,%eax
}
f010608a:	5d                   	pop    %ebp
f010608b:	c3                   	ret    
f010608c:	66 90                	xchg   %ax,%ax
f010608e:	66 90                	xchg   %ax,%ax

f0106090 <__udivdi3>:
f0106090:	55                   	push   %ebp
f0106091:	57                   	push   %edi
f0106092:	56                   	push   %esi
f0106093:	53                   	push   %ebx
f0106094:	83 ec 1c             	sub    $0x1c,%esp
f0106097:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010609b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010609f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01060a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01060a7:	85 f6                	test   %esi,%esi
f01060a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01060ad:	89 ca                	mov    %ecx,%edx
f01060af:	89 f8                	mov    %edi,%eax
f01060b1:	75 3d                	jne    f01060f0 <__udivdi3+0x60>
f01060b3:	39 cf                	cmp    %ecx,%edi
f01060b5:	0f 87 c5 00 00 00    	ja     f0106180 <__udivdi3+0xf0>
f01060bb:	85 ff                	test   %edi,%edi
f01060bd:	89 fd                	mov    %edi,%ebp
f01060bf:	75 0b                	jne    f01060cc <__udivdi3+0x3c>
f01060c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01060c6:	31 d2                	xor    %edx,%edx
f01060c8:	f7 f7                	div    %edi
f01060ca:	89 c5                	mov    %eax,%ebp
f01060cc:	89 c8                	mov    %ecx,%eax
f01060ce:	31 d2                	xor    %edx,%edx
f01060d0:	f7 f5                	div    %ebp
f01060d2:	89 c1                	mov    %eax,%ecx
f01060d4:	89 d8                	mov    %ebx,%eax
f01060d6:	89 cf                	mov    %ecx,%edi
f01060d8:	f7 f5                	div    %ebp
f01060da:	89 c3                	mov    %eax,%ebx
f01060dc:	89 d8                	mov    %ebx,%eax
f01060de:	89 fa                	mov    %edi,%edx
f01060e0:	83 c4 1c             	add    $0x1c,%esp
f01060e3:	5b                   	pop    %ebx
f01060e4:	5e                   	pop    %esi
f01060e5:	5f                   	pop    %edi
f01060e6:	5d                   	pop    %ebp
f01060e7:	c3                   	ret    
f01060e8:	90                   	nop
f01060e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01060f0:	39 ce                	cmp    %ecx,%esi
f01060f2:	77 74                	ja     f0106168 <__udivdi3+0xd8>
f01060f4:	0f bd fe             	bsr    %esi,%edi
f01060f7:	83 f7 1f             	xor    $0x1f,%edi
f01060fa:	0f 84 98 00 00 00    	je     f0106198 <__udivdi3+0x108>
f0106100:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106105:	89 f9                	mov    %edi,%ecx
f0106107:	89 c5                	mov    %eax,%ebp
f0106109:	29 fb                	sub    %edi,%ebx
f010610b:	d3 e6                	shl    %cl,%esi
f010610d:	89 d9                	mov    %ebx,%ecx
f010610f:	d3 ed                	shr    %cl,%ebp
f0106111:	89 f9                	mov    %edi,%ecx
f0106113:	d3 e0                	shl    %cl,%eax
f0106115:	09 ee                	or     %ebp,%esi
f0106117:	89 d9                	mov    %ebx,%ecx
f0106119:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010611d:	89 d5                	mov    %edx,%ebp
f010611f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106123:	d3 ed                	shr    %cl,%ebp
f0106125:	89 f9                	mov    %edi,%ecx
f0106127:	d3 e2                	shl    %cl,%edx
f0106129:	89 d9                	mov    %ebx,%ecx
f010612b:	d3 e8                	shr    %cl,%eax
f010612d:	09 c2                	or     %eax,%edx
f010612f:	89 d0                	mov    %edx,%eax
f0106131:	89 ea                	mov    %ebp,%edx
f0106133:	f7 f6                	div    %esi
f0106135:	89 d5                	mov    %edx,%ebp
f0106137:	89 c3                	mov    %eax,%ebx
f0106139:	f7 64 24 0c          	mull   0xc(%esp)
f010613d:	39 d5                	cmp    %edx,%ebp
f010613f:	72 10                	jb     f0106151 <__udivdi3+0xc1>
f0106141:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106145:	89 f9                	mov    %edi,%ecx
f0106147:	d3 e6                	shl    %cl,%esi
f0106149:	39 c6                	cmp    %eax,%esi
f010614b:	73 07                	jae    f0106154 <__udivdi3+0xc4>
f010614d:	39 d5                	cmp    %edx,%ebp
f010614f:	75 03                	jne    f0106154 <__udivdi3+0xc4>
f0106151:	83 eb 01             	sub    $0x1,%ebx
f0106154:	31 ff                	xor    %edi,%edi
f0106156:	89 d8                	mov    %ebx,%eax
f0106158:	89 fa                	mov    %edi,%edx
f010615a:	83 c4 1c             	add    $0x1c,%esp
f010615d:	5b                   	pop    %ebx
f010615e:	5e                   	pop    %esi
f010615f:	5f                   	pop    %edi
f0106160:	5d                   	pop    %ebp
f0106161:	c3                   	ret    
f0106162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106168:	31 ff                	xor    %edi,%edi
f010616a:	31 db                	xor    %ebx,%ebx
f010616c:	89 d8                	mov    %ebx,%eax
f010616e:	89 fa                	mov    %edi,%edx
f0106170:	83 c4 1c             	add    $0x1c,%esp
f0106173:	5b                   	pop    %ebx
f0106174:	5e                   	pop    %esi
f0106175:	5f                   	pop    %edi
f0106176:	5d                   	pop    %ebp
f0106177:	c3                   	ret    
f0106178:	90                   	nop
f0106179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106180:	89 d8                	mov    %ebx,%eax
f0106182:	f7 f7                	div    %edi
f0106184:	31 ff                	xor    %edi,%edi
f0106186:	89 c3                	mov    %eax,%ebx
f0106188:	89 d8                	mov    %ebx,%eax
f010618a:	89 fa                	mov    %edi,%edx
f010618c:	83 c4 1c             	add    $0x1c,%esp
f010618f:	5b                   	pop    %ebx
f0106190:	5e                   	pop    %esi
f0106191:	5f                   	pop    %edi
f0106192:	5d                   	pop    %ebp
f0106193:	c3                   	ret    
f0106194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106198:	39 ce                	cmp    %ecx,%esi
f010619a:	72 0c                	jb     f01061a8 <__udivdi3+0x118>
f010619c:	31 db                	xor    %ebx,%ebx
f010619e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01061a2:	0f 87 34 ff ff ff    	ja     f01060dc <__udivdi3+0x4c>
f01061a8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01061ad:	e9 2a ff ff ff       	jmp    f01060dc <__udivdi3+0x4c>
f01061b2:	66 90                	xchg   %ax,%ax
f01061b4:	66 90                	xchg   %ax,%ax
f01061b6:	66 90                	xchg   %ax,%ax
f01061b8:	66 90                	xchg   %ax,%ax
f01061ba:	66 90                	xchg   %ax,%ax
f01061bc:	66 90                	xchg   %ax,%ax
f01061be:	66 90                	xchg   %ax,%ax

f01061c0 <__umoddi3>:
f01061c0:	55                   	push   %ebp
f01061c1:	57                   	push   %edi
f01061c2:	56                   	push   %esi
f01061c3:	53                   	push   %ebx
f01061c4:	83 ec 1c             	sub    $0x1c,%esp
f01061c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01061cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01061cf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01061d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01061d7:	85 d2                	test   %edx,%edx
f01061d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01061dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01061e1:	89 f3                	mov    %esi,%ebx
f01061e3:	89 3c 24             	mov    %edi,(%esp)
f01061e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01061ea:	75 1c                	jne    f0106208 <__umoddi3+0x48>
f01061ec:	39 f7                	cmp    %esi,%edi
f01061ee:	76 50                	jbe    f0106240 <__umoddi3+0x80>
f01061f0:	89 c8                	mov    %ecx,%eax
f01061f2:	89 f2                	mov    %esi,%edx
f01061f4:	f7 f7                	div    %edi
f01061f6:	89 d0                	mov    %edx,%eax
f01061f8:	31 d2                	xor    %edx,%edx
f01061fa:	83 c4 1c             	add    $0x1c,%esp
f01061fd:	5b                   	pop    %ebx
f01061fe:	5e                   	pop    %esi
f01061ff:	5f                   	pop    %edi
f0106200:	5d                   	pop    %ebp
f0106201:	c3                   	ret    
f0106202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106208:	39 f2                	cmp    %esi,%edx
f010620a:	89 d0                	mov    %edx,%eax
f010620c:	77 52                	ja     f0106260 <__umoddi3+0xa0>
f010620e:	0f bd ea             	bsr    %edx,%ebp
f0106211:	83 f5 1f             	xor    $0x1f,%ebp
f0106214:	75 5a                	jne    f0106270 <__umoddi3+0xb0>
f0106216:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010621a:	0f 82 e0 00 00 00    	jb     f0106300 <__umoddi3+0x140>
f0106220:	39 0c 24             	cmp    %ecx,(%esp)
f0106223:	0f 86 d7 00 00 00    	jbe    f0106300 <__umoddi3+0x140>
f0106229:	8b 44 24 08          	mov    0x8(%esp),%eax
f010622d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106231:	83 c4 1c             	add    $0x1c,%esp
f0106234:	5b                   	pop    %ebx
f0106235:	5e                   	pop    %esi
f0106236:	5f                   	pop    %edi
f0106237:	5d                   	pop    %ebp
f0106238:	c3                   	ret    
f0106239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106240:	85 ff                	test   %edi,%edi
f0106242:	89 fd                	mov    %edi,%ebp
f0106244:	75 0b                	jne    f0106251 <__umoddi3+0x91>
f0106246:	b8 01 00 00 00       	mov    $0x1,%eax
f010624b:	31 d2                	xor    %edx,%edx
f010624d:	f7 f7                	div    %edi
f010624f:	89 c5                	mov    %eax,%ebp
f0106251:	89 f0                	mov    %esi,%eax
f0106253:	31 d2                	xor    %edx,%edx
f0106255:	f7 f5                	div    %ebp
f0106257:	89 c8                	mov    %ecx,%eax
f0106259:	f7 f5                	div    %ebp
f010625b:	89 d0                	mov    %edx,%eax
f010625d:	eb 99                	jmp    f01061f8 <__umoddi3+0x38>
f010625f:	90                   	nop
f0106260:	89 c8                	mov    %ecx,%eax
f0106262:	89 f2                	mov    %esi,%edx
f0106264:	83 c4 1c             	add    $0x1c,%esp
f0106267:	5b                   	pop    %ebx
f0106268:	5e                   	pop    %esi
f0106269:	5f                   	pop    %edi
f010626a:	5d                   	pop    %ebp
f010626b:	c3                   	ret    
f010626c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106270:	8b 34 24             	mov    (%esp),%esi
f0106273:	bf 20 00 00 00       	mov    $0x20,%edi
f0106278:	89 e9                	mov    %ebp,%ecx
f010627a:	29 ef                	sub    %ebp,%edi
f010627c:	d3 e0                	shl    %cl,%eax
f010627e:	89 f9                	mov    %edi,%ecx
f0106280:	89 f2                	mov    %esi,%edx
f0106282:	d3 ea                	shr    %cl,%edx
f0106284:	89 e9                	mov    %ebp,%ecx
f0106286:	09 c2                	or     %eax,%edx
f0106288:	89 d8                	mov    %ebx,%eax
f010628a:	89 14 24             	mov    %edx,(%esp)
f010628d:	89 f2                	mov    %esi,%edx
f010628f:	d3 e2                	shl    %cl,%edx
f0106291:	89 f9                	mov    %edi,%ecx
f0106293:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106297:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010629b:	d3 e8                	shr    %cl,%eax
f010629d:	89 e9                	mov    %ebp,%ecx
f010629f:	89 c6                	mov    %eax,%esi
f01062a1:	d3 e3                	shl    %cl,%ebx
f01062a3:	89 f9                	mov    %edi,%ecx
f01062a5:	89 d0                	mov    %edx,%eax
f01062a7:	d3 e8                	shr    %cl,%eax
f01062a9:	89 e9                	mov    %ebp,%ecx
f01062ab:	09 d8                	or     %ebx,%eax
f01062ad:	89 d3                	mov    %edx,%ebx
f01062af:	89 f2                	mov    %esi,%edx
f01062b1:	f7 34 24             	divl   (%esp)
f01062b4:	89 d6                	mov    %edx,%esi
f01062b6:	d3 e3                	shl    %cl,%ebx
f01062b8:	f7 64 24 04          	mull   0x4(%esp)
f01062bc:	39 d6                	cmp    %edx,%esi
f01062be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01062c2:	89 d1                	mov    %edx,%ecx
f01062c4:	89 c3                	mov    %eax,%ebx
f01062c6:	72 08                	jb     f01062d0 <__umoddi3+0x110>
f01062c8:	75 11                	jne    f01062db <__umoddi3+0x11b>
f01062ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01062ce:	73 0b                	jae    f01062db <__umoddi3+0x11b>
f01062d0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01062d4:	1b 14 24             	sbb    (%esp),%edx
f01062d7:	89 d1                	mov    %edx,%ecx
f01062d9:	89 c3                	mov    %eax,%ebx
f01062db:	8b 54 24 08          	mov    0x8(%esp),%edx
f01062df:	29 da                	sub    %ebx,%edx
f01062e1:	19 ce                	sbb    %ecx,%esi
f01062e3:	89 f9                	mov    %edi,%ecx
f01062e5:	89 f0                	mov    %esi,%eax
f01062e7:	d3 e0                	shl    %cl,%eax
f01062e9:	89 e9                	mov    %ebp,%ecx
f01062eb:	d3 ea                	shr    %cl,%edx
f01062ed:	89 e9                	mov    %ebp,%ecx
f01062ef:	d3 ee                	shr    %cl,%esi
f01062f1:	09 d0                	or     %edx,%eax
f01062f3:	89 f2                	mov    %esi,%edx
f01062f5:	83 c4 1c             	add    $0x1c,%esp
f01062f8:	5b                   	pop    %ebx
f01062f9:	5e                   	pop    %esi
f01062fa:	5f                   	pop    %edi
f01062fb:	5d                   	pop    %ebp
f01062fc:	c3                   	ret    
f01062fd:	8d 76 00             	lea    0x0(%esi),%esi
f0106300:	29 f9                	sub    %edi,%ecx
f0106302:	19 d6                	sbb    %edx,%esi
f0106304:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010630c:	e9 18 ff ff ff       	jmp    f0106229 <__umoddi3+0x69>
