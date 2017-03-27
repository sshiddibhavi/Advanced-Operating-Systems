
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
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
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
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

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
f0100048:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 fe 22 f0    	mov    %esi,0xf022fe80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 ad 5c 00 00       	call   f0105d0e <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 a0 63 10 f0       	push   $0xf01063a0
f010006d:	e8 96 36 00 00       	call   f0103708 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 66 36 00 00       	call   f01036e2 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 6a 6c 10 f0 	movl   $0xf0106c6a,(%esp)
f0100083:	e8 80 36 00 00       	call   f0103708 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 9c 08 00 00       	call   f0100931 <monitor>
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
f01000a1:	b8 08 10 27 f0       	mov    $0xf0271008,%eax
f01000a6:	2d 10 e9 22 f0       	sub    $0xf022e910,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 10 e9 22 f0       	push   $0xf022e910
f01000b3:	e8 34 56 00 00       	call   f01056ec <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 82 05 00 00       	call   f010063f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 0c 64 10 f0       	push   $0xf010640c
f01000ca:	e8 39 36 00 00       	call   f0103708 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 11 12 00 00       	call   f01012e5 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 11 2e 00 00       	call   f0102eea <env_init>
	trap_init();
f01000d9:	e8 35 37 00 00       	call   f0103813 <trap_init>

	// Lab 4 multiprocessor initialization functions

	
	mp_init();
f01000de:	e8 21 59 00 00       	call   f0105a04 <mp_init>
	lapic_init();
f01000e3:	e8 41 5c 00 00       	call   f0105d29 <lapic_init>
	

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 42 35 00 00       	call   f010362f <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000f4:	e8 83 5e 00 00       	call   f0105f7c <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 fe 22 f0 07 	cmpl   $0x7,0xf022fe88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 c4 63 10 f0       	push   $0xf01063c4
f010010f:	6a 5c                	push   $0x5c
f0100111:	68 27 64 10 f0       	push   $0xf0106427
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 6a 59 10 f0       	mov    $0xf010596a,%eax
f0100123:	2d f0 58 10 f0       	sub    $0xf01058f0,%eax
f0100128:	50                   	push   %eax
f0100129:	68 f0 58 10 f0       	push   $0xf01058f0
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 01 56 00 00       	call   f0105739 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 00 23 f0       	mov    $0xf0230020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 c7 5b 00 00       	call   f0105d0e <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 00 23 f0       	add    $0xf0230020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 00 23 f0       	sub    $0xf0230020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 90 23 f0       	add    $0xf0239000,%eax
f010016b:	a3 84 fe 22 f0       	mov    %eax,0xf022fe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 f6 5c 00 00       	call   f0105e77 <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f0100196:	05 20 00 23 f0       	add    $0xf0230020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	lock_kernel();
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 cc 4e 22 f0       	push   $0xf0224ecc
f01001a9:	e8 55 2f 00 00       	call   f0103103 <env_create>
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);

#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001ae:	e8 89 43 00 00       	call   f010453c <sched_yield>

f01001b3 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b3:	55                   	push   %ebp
f01001b4:	89 e5                	mov    %esp,%ebp
f01001b6:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b9:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c3:	77 12                	ja     f01001d7 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c5:	50                   	push   %eax
f01001c6:	68 e8 63 10 f0       	push   $0xf01063e8
f01001cb:	6a 73                	push   $0x73
f01001cd:	68 27 64 10 f0       	push   $0xf0106427
f01001d2:	e8 69 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01001dc:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001df:	e8 2a 5b 00 00       	call   f0105d0e <cpunum>
f01001e4:	83 ec 08             	sub    $0x8,%esp
f01001e7:	50                   	push   %eax
f01001e8:	68 33 64 10 f0       	push   $0xf0106433
f01001ed:	e8 16 35 00 00       	call   f0103708 <cprintf>

	lapic_init();
f01001f2:	e8 32 5b 00 00       	call   f0105d29 <lapic_init>
	env_init_percpu();
f01001f7:	e8 be 2c 00 00       	call   f0102eba <env_init_percpu>
	trap_init_percpu();
f01001fc:	e8 1b 35 00 00       	call   f010371c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100201:	e8 08 5b 00 00       	call   f0105d0e <cpunum>
f0100206:	6b d0 74             	imul   $0x74,%eax,%edx
f0100209:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010020f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100214:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100218:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010021f:	e8 58 5d 00 00       	call   f0105f7c <spin_lock>
	//
	// Your code here:

	lock_kernel();

	sched_yield();
f0100224:	e8 13 43 00 00       	call   f010453c <sched_yield>

f0100229 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100229:	55                   	push   %ebp
f010022a:	89 e5                	mov    %esp,%ebp
f010022c:	53                   	push   %ebx
f010022d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100230:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100233:	ff 75 0c             	pushl  0xc(%ebp)
f0100236:	ff 75 08             	pushl  0x8(%ebp)
f0100239:	68 49 64 10 f0       	push   $0xf0106449
f010023e:	e8 c5 34 00 00       	call   f0103708 <cprintf>
	vcprintf(fmt, ap);
f0100243:	83 c4 08             	add    $0x8,%esp
f0100246:	53                   	push   %ebx
f0100247:	ff 75 10             	pushl  0x10(%ebp)
f010024a:	e8 93 34 00 00       	call   f01036e2 <vcprintf>
	cprintf("\n");
f010024f:	c7 04 24 6a 6c 10 f0 	movl   $0xf0106c6a,(%esp)
f0100256:	e8 ad 34 00 00       	call   f0103708 <cprintf>
	va_end(ap);
f010025b:	83 c4 10             	add    $0x10,%esp
f010025e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100261:	c9                   	leave  
f0100262:	c3                   	ret    

f0100263 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100263:	55                   	push   %ebp
f0100264:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100266:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026c:	a8 01                	test   $0x1,%al
f010026e:	74 0b                	je     f010027b <serial_proc_data+0x18>
f0100270:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100275:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100276:	0f b6 c0             	movzbl %al,%eax
f0100279:	eb 05                	jmp    f0100280 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010027b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100280:	5d                   	pop    %ebp
f0100281:	c3                   	ret    

f0100282 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100282:	55                   	push   %ebp
f0100283:	89 e5                	mov    %esp,%ebp
f0100285:	53                   	push   %ebx
f0100286:	83 ec 04             	sub    $0x4,%esp
f0100289:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028b:	eb 2b                	jmp    f01002b8 <cons_intr+0x36>
		if (c == 0)
f010028d:	85 c0                	test   %eax,%eax
f010028f:	74 27                	je     f01002b8 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100291:	8b 0d 24 f2 22 f0    	mov    0xf022f224,%ecx
f0100297:	8d 51 01             	lea    0x1(%ecx),%edx
f010029a:	89 15 24 f2 22 f0    	mov    %edx,0xf022f224
f01002a0:	88 81 20 f0 22 f0    	mov    %al,-0xfdd0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002ac:	75 0a                	jne    f01002b8 <cons_intr+0x36>
			cons.wpos = 0;
f01002ae:	c7 05 24 f2 22 f0 00 	movl   $0x0,0xf022f224
f01002b5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b8:	ff d3                	call   *%ebx
f01002ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002bd:	75 ce                	jne    f010028d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bf:	83 c4 04             	add    $0x4,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    

f01002c5 <kbd_proc_data>:
f01002c5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ca:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002cb:	a8 01                	test   $0x1,%al
f01002cd:	0f 84 f8 00 00 00    	je     f01003cb <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002d3:	a8 20                	test   $0x20,%al
f01002d5:	0f 85 f6 00 00 00    	jne    f01003d1 <kbd_proc_data+0x10c>
f01002db:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e0:	ec                   	in     (%dx),%al
f01002e1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002e3:	3c e0                	cmp    $0xe0,%al
f01002e5:	75 0d                	jne    f01002f4 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002e7:	83 0d 00 f0 22 f0 40 	orl    $0x40,0xf022f000
		return 0;
f01002ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002f4:	55                   	push   %ebp
f01002f5:	89 e5                	mov    %esp,%ebp
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002fb:	84 c0                	test   %al,%al
f01002fd:	79 36                	jns    f0100335 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ff:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f0100305:	89 cb                	mov    %ecx,%ebx
f0100307:	83 e3 40             	and    $0x40,%ebx
f010030a:	83 e0 7f             	and    $0x7f,%eax
f010030d:	85 db                	test   %ebx,%ebx
f010030f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 82 c0 65 10 f0 	movzbl -0xfef9a40(%edx),%eax
f010031c:	83 c8 40             	or     $0x40,%eax
f010031f:	0f b6 c0             	movzbl %al,%eax
f0100322:	f7 d0                	not    %eax
f0100324:	21 c8                	and    %ecx,%eax
f0100326:	a3 00 f0 22 f0       	mov    %eax,0xf022f000
		return 0;
f010032b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100330:	e9 a4 00 00 00       	jmp    f01003d9 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100335:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f010033b:	f6 c1 40             	test   $0x40,%cl
f010033e:	74 0e                	je     f010034e <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100340:	83 c8 80             	or     $0xffffff80,%eax
f0100343:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100345:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100348:	89 0d 00 f0 22 f0    	mov    %ecx,0xf022f000
	}

	shift |= shiftcode[data];
f010034e:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100351:	0f b6 82 c0 65 10 f0 	movzbl -0xfef9a40(%edx),%eax
f0100358:	0b 05 00 f0 22 f0    	or     0xf022f000,%eax
f010035e:	0f b6 8a c0 64 10 f0 	movzbl -0xfef9b40(%edx),%ecx
f0100365:	31 c8                	xor    %ecx,%eax
f0100367:	a3 00 f0 22 f0       	mov    %eax,0xf022f000

	c = charcode[shift & (CTL | SHIFT)][data];
f010036c:	89 c1                	mov    %eax,%ecx
f010036e:	83 e1 03             	and    $0x3,%ecx
f0100371:	8b 0c 8d a0 64 10 f0 	mov    -0xfef9b60(,%ecx,4),%ecx
f0100378:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010037c:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010037f:	a8 08                	test   $0x8,%al
f0100381:	74 1b                	je     f010039e <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100383:	89 da                	mov    %ebx,%edx
f0100385:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100388:	83 f9 19             	cmp    $0x19,%ecx
f010038b:	77 05                	ja     f0100392 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010038d:	83 eb 20             	sub    $0x20,%ebx
f0100390:	eb 0c                	jmp    f010039e <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f0100392:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100395:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100398:	83 fa 19             	cmp    $0x19,%edx
f010039b:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039e:	f7 d0                	not    %eax
f01003a0:	a8 06                	test   $0x6,%al
f01003a2:	75 33                	jne    f01003d7 <kbd_proc_data+0x112>
f01003a4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003aa:	75 2b                	jne    f01003d7 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003ac:	83 ec 0c             	sub    $0xc,%esp
f01003af:	68 63 64 10 f0       	push   $0xf0106463
f01003b4:	e8 4f 33 00 00       	call   f0103708 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b9:	ba 92 00 00 00       	mov    $0x92,%edx
f01003be:	b8 03 00 00 00       	mov    $0x3,%eax
f01003c3:	ee                   	out    %al,(%dx)
f01003c4:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c7:	89 d8                	mov    %ebx,%eax
f01003c9:	eb 0e                	jmp    f01003d9 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003d0:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003d6:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d7:	89 d8                	mov    %ebx,%eax
}
f01003d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003dc:	c9                   	leave  
f01003dd:	c3                   	ret    

f01003de <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003de:	55                   	push   %ebp
f01003df:	89 e5                	mov    %esp,%ebp
f01003e1:	57                   	push   %edi
f01003e2:	56                   	push   %esi
f01003e3:	53                   	push   %ebx
f01003e4:	83 ec 1c             	sub    $0x1c,%esp
f01003e7:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003e9:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ee:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f8:	eb 09                	jmp    f0100403 <cons_putc+0x25>
f01003fa:	89 ca                	mov    %ecx,%edx
f01003fc:	ec                   	in     (%dx),%al
f01003fd:	ec                   	in     (%dx),%al
f01003fe:	ec                   	in     (%dx),%al
f01003ff:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100400:	83 c3 01             	add    $0x1,%ebx
f0100403:	89 f2                	mov    %esi,%edx
f0100405:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100406:	a8 20                	test   $0x20,%al
f0100408:	75 08                	jne    f0100412 <cons_putc+0x34>
f010040a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100410:	7e e8                	jle    f01003fa <cons_putc+0x1c>
f0100412:	89 f8                	mov    %edi,%eax
f0100414:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100417:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010041c:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010041d:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100422:	be 79 03 00 00       	mov    $0x379,%esi
f0100427:	b9 84 00 00 00       	mov    $0x84,%ecx
f010042c:	eb 09                	jmp    f0100437 <cons_putc+0x59>
f010042e:	89 ca                	mov    %ecx,%edx
f0100430:	ec                   	in     (%dx),%al
f0100431:	ec                   	in     (%dx),%al
f0100432:	ec                   	in     (%dx),%al
f0100433:	ec                   	in     (%dx),%al
f0100434:	83 c3 01             	add    $0x1,%ebx
f0100437:	89 f2                	mov    %esi,%edx
f0100439:	ec                   	in     (%dx),%al
f010043a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100440:	7f 04                	jg     f0100446 <cons_putc+0x68>
f0100442:	84 c0                	test   %al,%al
f0100444:	79 e8                	jns    f010042e <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100446:	ba 78 03 00 00       	mov    $0x378,%edx
f010044b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010044f:	ee                   	out    %al,(%dx)
f0100450:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100455:	b8 0d 00 00 00       	mov    $0xd,%eax
f010045a:	ee                   	out    %al,(%dx)
f010045b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100460:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100461:	89 fa                	mov    %edi,%edx
f0100463:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100469:	89 f8                	mov    %edi,%eax
f010046b:	80 cc 07             	or     $0x7,%ah
f010046e:	85 d2                	test   %edx,%edx
f0100470:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100473:	89 f8                	mov    %edi,%eax
f0100475:	0f b6 c0             	movzbl %al,%eax
f0100478:	83 f8 09             	cmp    $0x9,%eax
f010047b:	74 74                	je     f01004f1 <cons_putc+0x113>
f010047d:	83 f8 09             	cmp    $0x9,%eax
f0100480:	7f 0a                	jg     f010048c <cons_putc+0xae>
f0100482:	83 f8 08             	cmp    $0x8,%eax
f0100485:	74 14                	je     f010049b <cons_putc+0xbd>
f0100487:	e9 99 00 00 00       	jmp    f0100525 <cons_putc+0x147>
f010048c:	83 f8 0a             	cmp    $0xa,%eax
f010048f:	74 3a                	je     f01004cb <cons_putc+0xed>
f0100491:	83 f8 0d             	cmp    $0xd,%eax
f0100494:	74 3d                	je     f01004d3 <cons_putc+0xf5>
f0100496:	e9 8a 00 00 00       	jmp    f0100525 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010049b:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f01004a2:	66 85 c0             	test   %ax,%ax
f01004a5:	0f 84 e6 00 00 00    	je     f0100591 <cons_putc+0x1b3>
			crt_pos--;
f01004ab:	83 e8 01             	sub    $0x1,%eax
f01004ae:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b4:	0f b7 c0             	movzwl %ax,%eax
f01004b7:	66 81 e7 00 ff       	and    $0xff00,%di
f01004bc:	83 cf 20             	or     $0x20,%edi
f01004bf:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f01004c5:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c9:	eb 78                	jmp    f0100543 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004cb:	66 83 05 28 f2 22 f0 	addw   $0x50,0xf022f228
f01004d2:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d3:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f01004da:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e0:	c1 e8 16             	shr    $0x16,%eax
f01004e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e6:	c1 e0 04             	shl    $0x4,%eax
f01004e9:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
f01004ef:	eb 52                	jmp    f0100543 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004f1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f6:	e8 e3 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f01004fb:	b8 20 00 00 00       	mov    $0x20,%eax
f0100500:	e8 d9 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f0100505:	b8 20 00 00 00       	mov    $0x20,%eax
f010050a:	e8 cf fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f010050f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100514:	e8 c5 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f0100519:	b8 20 00 00 00       	mov    $0x20,%eax
f010051e:	e8 bb fe ff ff       	call   f01003de <cons_putc>
f0100523:	eb 1e                	jmp    f0100543 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100525:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f010052c:	8d 50 01             	lea    0x1(%eax),%edx
f010052f:	66 89 15 28 f2 22 f0 	mov    %dx,0xf022f228
f0100536:	0f b7 c0             	movzwl %ax,%eax
f0100539:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f010053f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100543:	66 81 3d 28 f2 22 f0 	cmpw   $0x7cf,0xf022f228
f010054a:	cf 07 
f010054c:	76 43                	jbe    f0100591 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010054e:	a1 2c f2 22 f0       	mov    0xf022f22c,%eax
f0100553:	83 ec 04             	sub    $0x4,%esp
f0100556:	68 00 0f 00 00       	push   $0xf00
f010055b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100561:	52                   	push   %edx
f0100562:	50                   	push   %eax
f0100563:	e8 d1 51 00 00       	call   f0105739 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100568:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f010056e:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100574:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010057a:	83 c4 10             	add    $0x10,%esp
f010057d:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100582:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100585:	39 d0                	cmp    %edx,%eax
f0100587:	75 f4                	jne    f010057d <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100589:	66 83 2d 28 f2 22 f0 	subw   $0x50,0xf022f228
f0100590:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100591:	8b 0d 30 f2 22 f0    	mov    0xf022f230,%ecx
f0100597:	b8 0e 00 00 00       	mov    $0xe,%eax
f010059c:	89 ca                	mov    %ecx,%edx
f010059e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010059f:	0f b7 1d 28 f2 22 f0 	movzwl 0xf022f228,%ebx
f01005a6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005a9:	89 d8                	mov    %ebx,%eax
f01005ab:	66 c1 e8 08          	shr    $0x8,%ax
f01005af:	89 f2                	mov    %esi,%edx
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b7:	89 ca                	mov    %ecx,%edx
f01005b9:	ee                   	out    %al,(%dx)
f01005ba:	89 d8                	mov    %ebx,%eax
f01005bc:	89 f2                	mov    %esi,%edx
f01005be:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005c2:	5b                   	pop    %ebx
f01005c3:	5e                   	pop    %esi
f01005c4:	5f                   	pop    %edi
f01005c5:	5d                   	pop    %ebp
f01005c6:	c3                   	ret    

f01005c7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005c7:	80 3d 34 f2 22 f0 00 	cmpb   $0x0,0xf022f234
f01005ce:	74 11                	je     f01005e1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005d0:	55                   	push   %ebp
f01005d1:	89 e5                	mov    %esp,%ebp
f01005d3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005d6:	b8 63 02 10 f0       	mov    $0xf0100263,%eax
f01005db:	e8 a2 fc ff ff       	call   f0100282 <cons_intr>
}
f01005e0:	c9                   	leave  
f01005e1:	f3 c3                	repz ret 

f01005e3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005e3:	55                   	push   %ebp
f01005e4:	89 e5                	mov    %esp,%ebp
f01005e6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005e9:	b8 c5 02 10 f0       	mov    $0xf01002c5,%eax
f01005ee:	e8 8f fc ff ff       	call   f0100282 <cons_intr>
}
f01005f3:	c9                   	leave  
f01005f4:	c3                   	ret    

f01005f5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005f5:	55                   	push   %ebp
f01005f6:	89 e5                	mov    %esp,%ebp
f01005f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005fb:	e8 c7 ff ff ff       	call   f01005c7 <serial_intr>
	kbd_intr();
f0100600:	e8 de ff ff ff       	call   f01005e3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100605:	a1 20 f2 22 f0       	mov    0xf022f220,%eax
f010060a:	3b 05 24 f2 22 f0    	cmp    0xf022f224,%eax
f0100610:	74 26                	je     f0100638 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100612:	8d 50 01             	lea    0x1(%eax),%edx
f0100615:	89 15 20 f2 22 f0    	mov    %edx,0xf022f220
f010061b:	0f b6 88 20 f0 22 f0 	movzbl -0xfdd0fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100622:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100624:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010062a:	75 11                	jne    f010063d <cons_getc+0x48>
			cons.rpos = 0;
f010062c:	c7 05 20 f2 22 f0 00 	movl   $0x0,0xf022f220
f0100633:	00 00 00 
f0100636:	eb 05                	jmp    f010063d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100638:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010063d:	c9                   	leave  
f010063e:	c3                   	ret    

f010063f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010063f:	55                   	push   %ebp
f0100640:	89 e5                	mov    %esp,%ebp
f0100642:	57                   	push   %edi
f0100643:	56                   	push   %esi
f0100644:	53                   	push   %ebx
f0100645:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100648:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010064f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100656:	5a a5 
	if (*cp != 0xA55A) {
f0100658:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010065f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100663:	74 11                	je     f0100676 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100665:	c7 05 30 f2 22 f0 b4 	movl   $0x3b4,0xf022f230
f010066c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100674:	eb 16                	jmp    f010068c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100676:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010067d:	c7 05 30 f2 22 f0 d4 	movl   $0x3d4,0xf022f230
f0100684:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100687:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010068c:	8b 3d 30 f2 22 f0    	mov    0xf022f230,%edi
f0100692:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100697:	89 fa                	mov    %edi,%edx
f0100699:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010069a:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069d:	89 da                	mov    %ebx,%edx
f010069f:	ec                   	in     (%dx),%al
f01006a0:	0f b6 c8             	movzbl %al,%ecx
f01006a3:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006ab:	89 fa                	mov    %edi,%edx
f01006ad:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ae:	89 da                	mov    %ebx,%edx
f01006b0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006b1:	89 35 2c f2 22 f0    	mov    %esi,0xf022f22c
	crt_pos = pos;
f01006b7:	0f b6 c0             	movzbl %al,%eax
f01006ba:	09 c8                	or     %ecx,%eax
f01006bc:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006c2:	e8 1c ff ff ff       	call   f01005e3 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006c7:	83 ec 0c             	sub    $0xc,%esp
f01006ca:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006d1:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006d6:	50                   	push   %eax
f01006d7:	e8 db 2e 00 00       	call   f01035b7 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006dc:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e6:	89 f2                	mov    %esi,%edx
f01006e8:	ee                   	out    %al,(%dx)
f01006e9:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006ee:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f3:	ee                   	out    %al,(%dx)
f01006f4:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006f9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006fe:	89 da                	mov    %ebx,%edx
f0100700:	ee                   	out    %al,(%dx)
f0100701:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100706:	b8 00 00 00 00       	mov    $0x0,%eax
f010070b:	ee                   	out    %al,(%dx)
f010070c:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100711:	b8 03 00 00 00       	mov    $0x3,%eax
f0100716:	ee                   	out    %al,(%dx)
f0100717:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010071c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100721:	ee                   	out    %al,(%dx)
f0100722:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100727:	b8 01 00 00 00       	mov    $0x1,%eax
f010072c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100732:	ec                   	in     (%dx),%al
f0100733:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100735:	83 c4 10             	add    $0x10,%esp
f0100738:	3c ff                	cmp    $0xff,%al
f010073a:	0f 95 05 34 f2 22 f0 	setne  0xf022f234
f0100741:	89 f2                	mov    %esi,%edx
f0100743:	ec                   	in     (%dx),%al
f0100744:	89 da                	mov    %ebx,%edx
f0100746:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100747:	80 f9 ff             	cmp    $0xff,%cl
f010074a:	75 10                	jne    f010075c <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f010074c:	83 ec 0c             	sub    $0xc,%esp
f010074f:	68 6f 64 10 f0       	push   $0xf010646f
f0100754:	e8 af 2f 00 00       	call   f0103708 <cprintf>
f0100759:	83 c4 10             	add    $0x10,%esp
}
f010075c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010075f:	5b                   	pop    %ebx
f0100760:	5e                   	pop    %esi
f0100761:	5f                   	pop    %edi
f0100762:	5d                   	pop    %ebp
f0100763:	c3                   	ret    

f0100764 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100764:	55                   	push   %ebp
f0100765:	89 e5                	mov    %esp,%ebp
f0100767:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010076a:	8b 45 08             	mov    0x8(%ebp),%eax
f010076d:	e8 6c fc ff ff       	call   f01003de <cons_putc>
}
f0100772:	c9                   	leave  
f0100773:	c3                   	ret    

f0100774 <getchar>:

int
getchar(void)
{
f0100774:	55                   	push   %ebp
f0100775:	89 e5                	mov    %esp,%ebp
f0100777:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010077a:	e8 76 fe ff ff       	call   f01005f5 <cons_getc>
f010077f:	85 c0                	test   %eax,%eax
f0100781:	74 f7                	je     f010077a <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100783:	c9                   	leave  
f0100784:	c3                   	ret    

f0100785 <iscons>:

int
iscons(int fdnum)
{
f0100785:	55                   	push   %ebp
f0100786:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100788:	b8 01 00 00 00       	mov    $0x1,%eax
f010078d:	5d                   	pop    %ebp
f010078e:	c3                   	ret    

f010078f <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010078f:	55                   	push   %ebp
f0100790:	89 e5                	mov    %esp,%ebp
f0100792:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100795:	68 c0 66 10 f0       	push   $0xf01066c0
f010079a:	68 de 66 10 f0       	push   $0xf01066de
f010079f:	68 e3 66 10 f0       	push   $0xf01066e3
f01007a4:	e8 5f 2f 00 00       	call   f0103708 <cprintf>
f01007a9:	83 c4 0c             	add    $0xc,%esp
f01007ac:	68 a8 67 10 f0       	push   $0xf01067a8
f01007b1:	68 ec 66 10 f0       	push   $0xf01066ec
f01007b6:	68 e3 66 10 f0       	push   $0xf01066e3
f01007bb:	e8 48 2f 00 00       	call   f0103708 <cprintf>
f01007c0:	83 c4 0c             	add    $0xc,%esp
f01007c3:	68 f5 66 10 f0       	push   $0xf01066f5
f01007c8:	68 fd 66 10 f0       	push   $0xf01066fd
f01007cd:	68 e3 66 10 f0       	push   $0xf01066e3
f01007d2:	e8 31 2f 00 00       	call   f0103708 <cprintf>
	return 0;
}
f01007d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01007dc:	c9                   	leave  
f01007dd:	c3                   	ret    

f01007de <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007de:	55                   	push   %ebp
f01007df:	89 e5                	mov    %esp,%ebp
f01007e1:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007e4:	68 07 67 10 f0       	push   $0xf0106707
f01007e9:	e8 1a 2f 00 00       	call   f0103708 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ee:	83 c4 08             	add    $0x8,%esp
f01007f1:	68 0c 00 10 00       	push   $0x10000c
f01007f6:	68 d0 67 10 f0       	push   $0xf01067d0
f01007fb:	e8 08 2f 00 00       	call   f0103708 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	68 0c 00 10 00       	push   $0x10000c
f0100808:	68 0c 00 10 f0       	push   $0xf010000c
f010080d:	68 f8 67 10 f0       	push   $0xf01067f8
f0100812:	e8 f1 2e 00 00       	call   f0103708 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100817:	83 c4 0c             	add    $0xc,%esp
f010081a:	68 91 63 10 00       	push   $0x106391
f010081f:	68 91 63 10 f0       	push   $0xf0106391
f0100824:	68 1c 68 10 f0       	push   $0xf010681c
f0100829:	e8 da 2e 00 00       	call   f0103708 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082e:	83 c4 0c             	add    $0xc,%esp
f0100831:	68 10 e9 22 00       	push   $0x22e910
f0100836:	68 10 e9 22 f0       	push   $0xf022e910
f010083b:	68 40 68 10 f0       	push   $0xf0106840
f0100840:	e8 c3 2e 00 00       	call   f0103708 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100845:	83 c4 0c             	add    $0xc,%esp
f0100848:	68 08 10 27 00       	push   $0x271008
f010084d:	68 08 10 27 f0       	push   $0xf0271008
f0100852:	68 64 68 10 f0       	push   $0xf0106864
f0100857:	e8 ac 2e 00 00       	call   f0103708 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010085c:	b8 07 14 27 f0       	mov    $0xf0271407,%eax
f0100861:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	83 c4 08             	add    $0x8,%esp
f0100869:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010086e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100874:	85 c0                	test   %eax,%eax
f0100876:	0f 48 c2             	cmovs  %edx,%eax
f0100879:	c1 f8 0a             	sar    $0xa,%eax
f010087c:	50                   	push   %eax
f010087d:	68 88 68 10 f0       	push   $0xf0106888
f0100882:	e8 81 2e 00 00       	call   f0103708 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100887:	b8 00 00 00 00       	mov    $0x0,%eax
f010088c:	c9                   	leave  
f010088d:	c3                   	ret    

f010088e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010088e:	55                   	push   %ebp
f010088f:	89 e5                	mov    %esp,%ebp
f0100891:	57                   	push   %edi
f0100892:	56                   	push   %esi
f0100893:	53                   	push   %ebx
f0100894:	83 ec 48             	sub    $0x48,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100897:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t* ebp = (uint32_t*) read_ebp();
	int i;

  cprintf("Stack backtrace:\n");
f0100899:	68 20 67 10 f0       	push   $0xf0106720
f010089e:	e8 65 2e 00 00       	call   f0103708 <cprintf>
  while (ebp) {
f01008a3:	83 c4 10             	add    $0x10,%esp
f01008a6:	eb 78                	jmp    f0100920 <mon_backtrace+0x92>
  	struct Eipdebuginfo info;
	uint32_t ret_addr = ebp[1];
f01008a8:	8b 7e 04             	mov    0x4(%esi),%edi
	uint32_t old_ebp = ebp[0];
f01008ab:	8b 06                	mov    (%esi),%eax
f01008ad:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	debuginfo_eip(ret_addr, &info);
f01008b0:	83 ec 08             	sub    $0x8,%esp
f01008b3:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008b6:	50                   	push   %eax
f01008b7:	57                   	push   %edi
f01008b8:	e8 bd 43 00 00       	call   f0104c7a <debuginfo_eip>
    cprintf("ebp %08x  eip %08x  args", ebp, *(ebp+1));
f01008bd:	83 c4 0c             	add    $0xc,%esp
f01008c0:	ff 76 04             	pushl  0x4(%esi)
f01008c3:	56                   	push   %esi
f01008c4:	68 32 67 10 f0       	push   $0xf0106732
f01008c9:	e8 3a 2e 00 00       	call   f0103708 <cprintf>
f01008ce:	8d 5e 08             	lea    0x8(%esi),%ebx
f01008d1:	83 c6 1c             	add    $0x1c,%esi
f01008d4:	83 c4 10             	add    $0x10,%esp
    for(i=2; i<=6; i++)
       cprintf(" %08x", *(ebp+i));
f01008d7:	83 ec 08             	sub    $0x8,%esp
f01008da:	ff 33                	pushl  (%ebx)
f01008dc:	68 4b 67 10 f0       	push   $0xf010674b
f01008e1:	e8 22 2e 00 00       	call   f0103708 <cprintf>
f01008e6:	83 c3 04             	add    $0x4,%ebx
  	struct Eipdebuginfo info;
	uint32_t ret_addr = ebp[1];
	uint32_t old_ebp = ebp[0];
	debuginfo_eip(ret_addr, &info);
    cprintf("ebp %08x  eip %08x  args", ebp, *(ebp+1));
    for(i=2; i<=6; i++)
f01008e9:	83 c4 10             	add    $0x10,%esp
f01008ec:	39 f3                	cmp    %esi,%ebx
f01008ee:	75 e7                	jne    f01008d7 <mon_backtrace+0x49>
       cprintf(" %08x", *(ebp+i));
    cprintf("\n");
f01008f0:	83 ec 0c             	sub    $0xc,%esp
f01008f3:	68 6a 6c 10 f0       	push   $0xf0106c6a
f01008f8:	e8 0b 2e 00 00       	call   f0103708 <cprintf>
    cprintf("         %s:%d: %.*s+%u\n", info.eip_file,
f01008fd:	83 c4 08             	add    $0x8,%esp
f0100900:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100903:	57                   	push   %edi
f0100904:	ff 75 d8             	pushl  -0x28(%ebp)
f0100907:	ff 75 dc             	pushl  -0x24(%ebp)
f010090a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010090d:	ff 75 d0             	pushl  -0x30(%ebp)
f0100910:	68 51 67 10 f0       	push   $0xf0106751
f0100915:	e8 ee 2d 00 00       	call   f0103708 <cprintf>
                info.eip_fn_namelen,
                info.eip_fn_name,
                ret_addr - info.eip_fn_addr);


    ebp = (uint32_t *)old_ebp;
f010091a:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010091d:	83 c4 20             	add    $0x20,%esp
	// Your code here.
	uint32_t* ebp = (uint32_t*) read_ebp();
	int i;

  cprintf("Stack backtrace:\n");
  while (ebp) {
f0100920:	85 f6                	test   %esi,%esi
f0100922:	75 84                	jne    f01008a8 <mon_backtrace+0x1a>
    ebp = (uint32_t *)old_ebp;
    //ebp = (uint32_t*) *ebp;
  
  }
  return 0;
}
f0100924:	b8 00 00 00 00       	mov    $0x0,%eax
f0100929:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010092c:	5b                   	pop    %ebx
f010092d:	5e                   	pop    %esi
f010092e:	5f                   	pop    %edi
f010092f:	5d                   	pop    %ebp
f0100930:	c3                   	ret    

f0100931 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100931:	55                   	push   %ebp
f0100932:	89 e5                	mov    %esp,%ebp
f0100934:	57                   	push   %edi
f0100935:	56                   	push   %esi
f0100936:	53                   	push   %ebx
f0100937:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010093a:	68 b4 68 10 f0       	push   $0xf01068b4
f010093f:	e8 c4 2d 00 00       	call   f0103708 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100944:	c7 04 24 d8 68 10 f0 	movl   $0xf01068d8,(%esp)
f010094b:	e8 b8 2d 00 00       	call   f0103708 <cprintf>

	if (tf != NULL)
f0100950:	83 c4 10             	add    $0x10,%esp
f0100953:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100957:	74 0e                	je     f0100967 <monitor+0x36>
		print_trapframe(tf);
f0100959:	83 ec 0c             	sub    $0xc,%esp
f010095c:	ff 75 08             	pushl  0x8(%ebp)
f010095f:	e8 2b 35 00 00       	call   f0103e8f <print_trapframe>
f0100964:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100967:	83 ec 0c             	sub    $0xc,%esp
f010096a:	68 6a 67 10 f0       	push   $0xf010676a
f010096f:	e8 21 4b 00 00       	call   f0105495 <readline>
f0100974:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100976:	83 c4 10             	add    $0x10,%esp
f0100979:	85 c0                	test   %eax,%eax
f010097b:	74 ea                	je     f0100967 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010097d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100984:	be 00 00 00 00       	mov    $0x0,%esi
f0100989:	eb 0a                	jmp    f0100995 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010098b:	c6 03 00             	movb   $0x0,(%ebx)
f010098e:	89 f7                	mov    %esi,%edi
f0100990:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100993:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100995:	0f b6 03             	movzbl (%ebx),%eax
f0100998:	84 c0                	test   %al,%al
f010099a:	74 63                	je     f01009ff <monitor+0xce>
f010099c:	83 ec 08             	sub    $0x8,%esp
f010099f:	0f be c0             	movsbl %al,%eax
f01009a2:	50                   	push   %eax
f01009a3:	68 6e 67 10 f0       	push   $0xf010676e
f01009a8:	e8 02 4d 00 00       	call   f01056af <strchr>
f01009ad:	83 c4 10             	add    $0x10,%esp
f01009b0:	85 c0                	test   %eax,%eax
f01009b2:	75 d7                	jne    f010098b <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009b4:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009b7:	74 46                	je     f01009ff <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009b9:	83 fe 0f             	cmp    $0xf,%esi
f01009bc:	75 14                	jne    f01009d2 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009be:	83 ec 08             	sub    $0x8,%esp
f01009c1:	6a 10                	push   $0x10
f01009c3:	68 73 67 10 f0       	push   $0xf0106773
f01009c8:	e8 3b 2d 00 00       	call   f0103708 <cprintf>
f01009cd:	83 c4 10             	add    $0x10,%esp
f01009d0:	eb 95                	jmp    f0100967 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009d2:	8d 7e 01             	lea    0x1(%esi),%edi
f01009d5:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009d9:	eb 03                	jmp    f01009de <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009db:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009de:	0f b6 03             	movzbl (%ebx),%eax
f01009e1:	84 c0                	test   %al,%al
f01009e3:	74 ae                	je     f0100993 <monitor+0x62>
f01009e5:	83 ec 08             	sub    $0x8,%esp
f01009e8:	0f be c0             	movsbl %al,%eax
f01009eb:	50                   	push   %eax
f01009ec:	68 6e 67 10 f0       	push   $0xf010676e
f01009f1:	e8 b9 4c 00 00       	call   f01056af <strchr>
f01009f6:	83 c4 10             	add    $0x10,%esp
f01009f9:	85 c0                	test   %eax,%eax
f01009fb:	74 de                	je     f01009db <monitor+0xaa>
f01009fd:	eb 94                	jmp    f0100993 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009ff:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a06:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a07:	85 f6                	test   %esi,%esi
f0100a09:	0f 84 58 ff ff ff    	je     f0100967 <monitor+0x36>
f0100a0f:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a14:	83 ec 08             	sub    $0x8,%esp
f0100a17:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a1a:	ff 34 85 00 69 10 f0 	pushl  -0xfef9700(,%eax,4)
f0100a21:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a24:	e8 28 4c 00 00       	call   f0105651 <strcmp>
f0100a29:	83 c4 10             	add    $0x10,%esp
f0100a2c:	85 c0                	test   %eax,%eax
f0100a2e:	75 21                	jne    f0100a51 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a30:	83 ec 04             	sub    $0x4,%esp
f0100a33:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a36:	ff 75 08             	pushl  0x8(%ebp)
f0100a39:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a3c:	52                   	push   %edx
f0100a3d:	56                   	push   %esi
f0100a3e:	ff 14 85 08 69 10 f0 	call   *-0xfef96f8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a45:	83 c4 10             	add    $0x10,%esp
f0100a48:	85 c0                	test   %eax,%eax
f0100a4a:	78 25                	js     f0100a71 <monitor+0x140>
f0100a4c:	e9 16 ff ff ff       	jmp    f0100967 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a51:	83 c3 01             	add    $0x1,%ebx
f0100a54:	83 fb 03             	cmp    $0x3,%ebx
f0100a57:	75 bb                	jne    f0100a14 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a59:	83 ec 08             	sub    $0x8,%esp
f0100a5c:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a5f:	68 90 67 10 f0       	push   $0xf0106790
f0100a64:	e8 9f 2c 00 00       	call   f0103708 <cprintf>
f0100a69:	83 c4 10             	add    $0x10,%esp
f0100a6c:	e9 f6 fe ff ff       	jmp    f0100967 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a74:	5b                   	pop    %ebx
f0100a75:	5e                   	pop    %esi
f0100a76:	5f                   	pop    %edi
f0100a77:	5d                   	pop    %ebp
f0100a78:	c3                   	ret    

f0100a79 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a79:	55                   	push   %ebp
f0100a7a:	89 e5                	mov    %esp,%ebp
f0100a7c:	56                   	push   %esi
f0100a7d:	53                   	push   %ebx
f0100a7e:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a80:	83 ec 0c             	sub    $0xc,%esp
f0100a83:	50                   	push   %eax
f0100a84:	e8 00 2b 00 00       	call   f0103589 <mc146818_read>
f0100a89:	89 c6                	mov    %eax,%esi
f0100a8b:	83 c3 01             	add    $0x1,%ebx
f0100a8e:	89 1c 24             	mov    %ebx,(%esp)
f0100a91:	e8 f3 2a 00 00       	call   f0103589 <mc146818_read>
f0100a96:	c1 e0 08             	shl    $0x8,%eax
f0100a99:	09 f0                	or     %esi,%eax
}
f0100a9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a9e:	5b                   	pop    %ebx
f0100a9f:	5e                   	pop    %esi
f0100aa0:	5d                   	pop    %ebp
f0100aa1:	c3                   	ret    

f0100aa2 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100aa2:	55                   	push   %ebp
f0100aa3:	89 e5                	mov    %esp,%ebp
f0100aa5:	53                   	push   %ebx
f0100aa6:	83 ec 04             	sub    $0x4,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aa9:	83 3d 38 f2 22 f0 00 	cmpl   $0x0,0xf022f238
f0100ab0:	75 11                	jne    f0100ac3 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ab2:	ba 07 20 27 f0       	mov    $0xf0272007,%edx
f0100ab7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100abd:	89 15 38 f2 22 f0    	mov    %edx,0xf022f238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;  //return a pointer to the start of the allocated space
f0100ac3:	8b 1d 38 f2 22 f0    	mov    0xf022f238,%ebx

	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100ac9:	8d 8c 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%ecx
f0100ad0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100ad6:	89 0d 38 f2 22 f0    	mov    %ecx,0xf022f238

	if (KERNBASE + npages*PGSIZE < (uint32_t)nextfree)
f0100adc:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0100ae1:	8d 90 00 00 0f 00    	lea    0xf0000(%eax),%edx
f0100ae7:	c1 e2 0c             	shl    $0xc,%edx
f0100aea:	39 d1                	cmp    %edx,%ecx
f0100aec:	76 14                	jbe    f0100b02 <boot_alloc+0x60>
		panic ("boot_alloc - Out of memory \n ");
f0100aee:	83 ec 04             	sub    $0x4,%esp
f0100af1:	68 24 69 10 f0       	push   $0xf0106924
f0100af6:	6a 71                	push   $0x71
f0100af8:	68 42 69 10 f0       	push   $0xf0106942
f0100afd:	e8 3e f5 ff ff       	call   f0100040 <_panic>


	return result;  //return a pointer to the start of the allocated space


}
f0100b02:	89 d8                	mov    %ebx,%eax
f0100b04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b07:	c9                   	leave  
f0100b08:	c3                   	ret    

f0100b09 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b09:	89 d1                	mov    %edx,%ecx
f0100b0b:	c1 e9 16             	shr    $0x16,%ecx
f0100b0e:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b11:	a8 01                	test   $0x1,%al
f0100b13:	74 52                	je     f0100b67 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b1a:	89 c1                	mov    %eax,%ecx
f0100b1c:	c1 e9 0c             	shr    $0xc,%ecx
f0100b1f:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0100b25:	72 1b                	jb     f0100b42 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b27:	55                   	push   %ebp
f0100b28:	89 e5                	mov    %esp,%ebp
f0100b2a:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b2d:	50                   	push   %eax
f0100b2e:	68 c4 63 10 f0       	push   $0xf01063c4
f0100b33:	68 b6 03 00 00       	push   $0x3b6
f0100b38:	68 42 69 10 f0       	push   $0xf0106942
f0100b3d:	e8 fe f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b42:	c1 ea 0c             	shr    $0xc,%edx
f0100b45:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b4b:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b52:	89 c2                	mov    %eax,%edx
f0100b54:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b5c:	85 d2                	test   %edx,%edx
f0100b5e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b63:	0f 44 c2             	cmove  %edx,%eax
f0100b66:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b6c:	c3                   	ret    

f0100b6d <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b6d:	55                   	push   %ebp
f0100b6e:	89 e5                	mov    %esp,%ebp
f0100b70:	57                   	push   %edi
f0100b71:	56                   	push   %esi
f0100b72:	53                   	push   %ebx
f0100b73:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b76:	84 c0                	test   %al,%al
f0100b78:	0f 85 a0 02 00 00    	jne    f0100e1e <check_page_free_list+0x2b1>
f0100b7e:	e9 ad 02 00 00       	jmp    f0100e30 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b83:	83 ec 04             	sub    $0x4,%esp
f0100b86:	68 9c 6c 10 f0       	push   $0xf0106c9c
f0100b8b:	68 e9 02 00 00       	push   $0x2e9
f0100b90:	68 42 69 10 f0       	push   $0xf0106942
f0100b95:	e8 a6 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b9a:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b9d:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ba0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ba3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ba6:	89 c2                	mov    %eax,%edx
f0100ba8:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0100bae:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100bb4:	0f 95 c2             	setne  %dl
f0100bb7:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100bba:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bbe:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bc0:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bc4:	8b 00                	mov    (%eax),%eax
f0100bc6:	85 c0                	test   %eax,%eax
f0100bc8:	75 dc                	jne    f0100ba6 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bcd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bd6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bd9:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bdb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bde:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100be3:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100be8:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0100bee:	eb 53                	jmp    f0100c43 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bf0:	89 d8                	mov    %ebx,%eax
f0100bf2:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0100bf8:	c1 f8 03             	sar    $0x3,%eax
f0100bfb:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bfe:	89 c2                	mov    %eax,%edx
f0100c00:	c1 ea 16             	shr    $0x16,%edx
f0100c03:	39 f2                	cmp    %esi,%edx
f0100c05:	73 3a                	jae    f0100c41 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c07:	89 c2                	mov    %eax,%edx
f0100c09:	c1 ea 0c             	shr    $0xc,%edx
f0100c0c:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100c12:	72 12                	jb     f0100c26 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c14:	50                   	push   %eax
f0100c15:	68 c4 63 10 f0       	push   $0xf01063c4
f0100c1a:	6a 58                	push   $0x58
f0100c1c:	68 4e 69 10 f0       	push   $0xf010694e
f0100c21:	e8 1a f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c26:	83 ec 04             	sub    $0x4,%esp
f0100c29:	68 80 00 00 00       	push   $0x80
f0100c2e:	68 97 00 00 00       	push   $0x97
f0100c33:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c38:	50                   	push   %eax
f0100c39:	e8 ae 4a 00 00       	call   f01056ec <memset>
f0100c3e:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c41:	8b 1b                	mov    (%ebx),%ebx
f0100c43:	85 db                	test   %ebx,%ebx
f0100c45:	75 a9                	jne    f0100bf0 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c47:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c4c:	e8 51 fe ff ff       	call   f0100aa2 <boot_alloc>
f0100c51:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c54:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c5a:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
		assert(pp < pages + npages);
f0100c60:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0100c65:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c68:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c6b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c6e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c71:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c76:	e9 52 01 00 00       	jmp    f0100dcd <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c7b:	39 ca                	cmp    %ecx,%edx
f0100c7d:	73 19                	jae    f0100c98 <check_page_free_list+0x12b>
f0100c7f:	68 5c 69 10 f0       	push   $0xf010695c
f0100c84:	68 68 69 10 f0       	push   $0xf0106968
f0100c89:	68 03 03 00 00       	push   $0x303
f0100c8e:	68 42 69 10 f0       	push   $0xf0106942
f0100c93:	e8 a8 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c98:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c9b:	72 19                	jb     f0100cb6 <check_page_free_list+0x149>
f0100c9d:	68 7d 69 10 f0       	push   $0xf010697d
f0100ca2:	68 68 69 10 f0       	push   $0xf0106968
f0100ca7:	68 04 03 00 00       	push   $0x304
f0100cac:	68 42 69 10 f0       	push   $0xf0106942
f0100cb1:	e8 8a f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cb6:	89 d0                	mov    %edx,%eax
f0100cb8:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cbb:	a8 07                	test   $0x7,%al
f0100cbd:	74 19                	je     f0100cd8 <check_page_free_list+0x16b>
f0100cbf:	68 c0 6c 10 f0       	push   $0xf0106cc0
f0100cc4:	68 68 69 10 f0       	push   $0xf0106968
f0100cc9:	68 05 03 00 00       	push   $0x305
f0100cce:	68 42 69 10 f0       	push   $0xf0106942
f0100cd3:	e8 68 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cd8:	c1 f8 03             	sar    $0x3,%eax
f0100cdb:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cde:	85 c0                	test   %eax,%eax
f0100ce0:	75 19                	jne    f0100cfb <check_page_free_list+0x18e>
f0100ce2:	68 91 69 10 f0       	push   $0xf0106991
f0100ce7:	68 68 69 10 f0       	push   $0xf0106968
f0100cec:	68 08 03 00 00       	push   $0x308
f0100cf1:	68 42 69 10 f0       	push   $0xf0106942
f0100cf6:	e8 45 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cfb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d00:	75 19                	jne    f0100d1b <check_page_free_list+0x1ae>
f0100d02:	68 a2 69 10 f0       	push   $0xf01069a2
f0100d07:	68 68 69 10 f0       	push   $0xf0106968
f0100d0c:	68 09 03 00 00       	push   $0x309
f0100d11:	68 42 69 10 f0       	push   $0xf0106942
f0100d16:	e8 25 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d1b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d20:	75 19                	jne    f0100d3b <check_page_free_list+0x1ce>
f0100d22:	68 f4 6c 10 f0       	push   $0xf0106cf4
f0100d27:	68 68 69 10 f0       	push   $0xf0106968
f0100d2c:	68 0a 03 00 00       	push   $0x30a
f0100d31:	68 42 69 10 f0       	push   $0xf0106942
f0100d36:	e8 05 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d3b:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d40:	75 19                	jne    f0100d5b <check_page_free_list+0x1ee>
f0100d42:	68 bb 69 10 f0       	push   $0xf01069bb
f0100d47:	68 68 69 10 f0       	push   $0xf0106968
f0100d4c:	68 0b 03 00 00       	push   $0x30b
f0100d51:	68 42 69 10 f0       	push   $0xf0106942
f0100d56:	e8 e5 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d5b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d60:	0f 86 f1 00 00 00    	jbe    f0100e57 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d66:	89 c7                	mov    %eax,%edi
f0100d68:	c1 ef 0c             	shr    $0xc,%edi
f0100d6b:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d6e:	77 12                	ja     f0100d82 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d70:	50                   	push   %eax
f0100d71:	68 c4 63 10 f0       	push   $0xf01063c4
f0100d76:	6a 58                	push   $0x58
f0100d78:	68 4e 69 10 f0       	push   $0xf010694e
f0100d7d:	e8 be f2 ff ff       	call   f0100040 <_panic>
f0100d82:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d88:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d8b:	0f 86 b6 00 00 00    	jbe    f0100e47 <check_page_free_list+0x2da>
f0100d91:	68 18 6d 10 f0       	push   $0xf0106d18
f0100d96:	68 68 69 10 f0       	push   $0xf0106968
f0100d9b:	68 0c 03 00 00       	push   $0x30c
f0100da0:	68 42 69 10 f0       	push   $0xf0106942
f0100da5:	e8 96 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100daa:	68 d5 69 10 f0       	push   $0xf01069d5
f0100daf:	68 68 69 10 f0       	push   $0xf0106968
f0100db4:	68 0e 03 00 00       	push   $0x30e
f0100db9:	68 42 69 10 f0       	push   $0xf0106942
f0100dbe:	e8 7d f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100dc3:	83 c6 01             	add    $0x1,%esi
f0100dc6:	eb 03                	jmp    f0100dcb <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100dc8:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dcb:	8b 12                	mov    (%edx),%edx
f0100dcd:	85 d2                	test   %edx,%edx
f0100dcf:	0f 85 a6 fe ff ff    	jne    f0100c7b <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100dd5:	85 f6                	test   %esi,%esi
f0100dd7:	7f 19                	jg     f0100df2 <check_page_free_list+0x285>
f0100dd9:	68 f2 69 10 f0       	push   $0xf01069f2
f0100dde:	68 68 69 10 f0       	push   $0xf0106968
f0100de3:	68 16 03 00 00       	push   $0x316
f0100de8:	68 42 69 10 f0       	push   $0xf0106942
f0100ded:	e8 4e f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100df2:	85 db                	test   %ebx,%ebx
f0100df4:	7f 19                	jg     f0100e0f <check_page_free_list+0x2a2>
f0100df6:	68 04 6a 10 f0       	push   $0xf0106a04
f0100dfb:	68 68 69 10 f0       	push   $0xf0106968
f0100e00:	68 17 03 00 00       	push   $0x317
f0100e05:	68 42 69 10 f0       	push   $0xf0106942
f0100e0a:	e8 31 f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e0f:	83 ec 0c             	sub    $0xc,%esp
f0100e12:	68 60 6d 10 f0       	push   $0xf0106d60
f0100e17:	e8 ec 28 00 00       	call   f0103708 <cprintf>
}
f0100e1c:	eb 49                	jmp    f0100e67 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e1e:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0100e23:	85 c0                	test   %eax,%eax
f0100e25:	0f 85 6f fd ff ff    	jne    f0100b9a <check_page_free_list+0x2d>
f0100e2b:	e9 53 fd ff ff       	jmp    f0100b83 <check_page_free_list+0x16>
f0100e30:	83 3d 40 f2 22 f0 00 	cmpl   $0x0,0xf022f240
f0100e37:	0f 84 46 fd ff ff    	je     f0100b83 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e3d:	be 00 04 00 00       	mov    $0x400,%esi
f0100e42:	e9 a1 fd ff ff       	jmp    f0100be8 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e47:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e4c:	0f 85 76 ff ff ff    	jne    f0100dc8 <check_page_free_list+0x25b>
f0100e52:	e9 53 ff ff ff       	jmp    f0100daa <check_page_free_list+0x23d>
f0100e57:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e5c:	0f 85 61 ff ff ff    	jne    f0100dc3 <check_page_free_list+0x256>
f0100e62:	e9 43 ff ff ff       	jmp    f0100daa <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e6a:	5b                   	pop    %ebx
f0100e6b:	5e                   	pop    %esi
f0100e6c:	5f                   	pop    %edi
f0100e6d:	5d                   	pop    %ebp
f0100e6e:	c3                   	ret    

f0100e6f <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e6f:	55                   	push   %ebp
f0100e70:	89 e5                	mov    %esp,%ebp
f0100e72:	57                   	push   %edi
f0100e73:	56                   	push   %esi
f0100e74:	53                   	push   %ebx
f0100e75:	83 ec 1c             	sub    $0x1c,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t kern_pages = ((uint32_t)boot_alloc(0) - KERNBASE)/PGSIZE;
f0100e78:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e7d:	e8 20 fc ff ff       	call   f0100aa2 <boot_alloc>
f0100e82:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0100e88:	c1 eb 0c             	shr    $0xc,%ebx
	cprintf ("kern_pages = %u\n", kern_pages);
f0100e8b:	83 ec 08             	sub    $0x8,%esp
f0100e8e:	53                   	push   %ebx
f0100e8f:	68 15 6a 10 f0       	push   $0xf0106a15
f0100e94:	e8 6f 28 00 00       	call   f0103708 <cprintf>
		pages[i].pp_link = NULL;

		if (i==0 || i == MPENTRY_PADDR/PGSIZE){
			pages[i].pp_ref = 1;
		}
		else if (i>=npages_basemem && i< EXTPHYSMEM/PGSIZE + kern_pages)
f0100e99:	8b 3d 44 f2 22 f0    	mov    0xf022f244,%edi
f0100e9f:	8b 35 40 f2 22 f0    	mov    0xf022f240,%esi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t kern_pages = ((uint32_t)boot_alloc(0) - KERNBASE)/PGSIZE;
	cprintf ("kern_pages = %u\n", kern_pages);
	for (i = 0; i < npages; i++) {
f0100ea5:	83 c4 10             	add    $0x10,%esp
f0100ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ead:	b8 00 00 00 00       	mov    $0x0,%eax
		pages[i].pp_link = NULL;

		if (i==0 || i == MPENTRY_PADDR/PGSIZE){
			pages[i].pp_ref = 1;
		}
		else if (i>=npages_basemem && i< EXTPHYSMEM/PGSIZE + kern_pages)
f0100eb2:	81 c3 00 01 00 00    	add    $0x100,%ebx
f0100eb8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t kern_pages = ((uint32_t)boot_alloc(0) - KERNBASE)/PGSIZE;
	cprintf ("kern_pages = %u\n", kern_pages);
	for (i = 0; i < npages; i++) {
f0100ebb:	eb 64                	jmp    f0100f21 <page_init+0xb2>
f0100ebd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_link = NULL;
f0100ec4:	8b 1d 90 fe 22 f0    	mov    0xf022fe90,%ebx
f0100eca:	c7 04 c3 00 00 00 00 	movl   $0x0,(%ebx,%eax,8)

		if (i==0 || i == MPENTRY_PADDR/PGSIZE){
f0100ed1:	85 c0                	test   %eax,%eax
f0100ed3:	74 05                	je     f0100eda <page_init+0x6b>
f0100ed5:	83 f8 07             	cmp    $0x7,%eax
f0100ed8:	75 0f                	jne    f0100ee9 <page_init+0x7a>
			pages[i].pp_ref = 1;
f0100eda:	8b 1d 90 fe 22 f0    	mov    0xf022fe90,%ebx
f0100ee0:	66 c7 44 13 04 01 00 	movw   $0x1,0x4(%ebx,%edx,1)
f0100ee7:	eb 35                	jmp    f0100f1e <page_init+0xaf>
		}
		else if (i>=npages_basemem && i< EXTPHYSMEM/PGSIZE + kern_pages)
f0100ee9:	39 f8                	cmp    %edi,%eax
f0100eeb:	72 14                	jb     f0100f01 <page_init+0x92>
f0100eed:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0100ef0:	73 0f                	jae    f0100f01 <page_init+0x92>
		{
			pages[i].pp_ref = 1;
f0100ef2:	8b 1d 90 fe 22 f0    	mov    0xf022fe90,%ebx
f0100ef8:	66 c7 44 13 04 01 00 	movw   $0x1,0x4(%ebx,%edx,1)
f0100eff:	eb 1d                	jmp    f0100f1e <page_init+0xaf>
		} 
		
		else
		{
			pages[i].pp_ref = 0;
f0100f01:	89 d1                	mov    %edx,%ecx
f0100f03:	03 0d 90 fe 22 f0    	add    0xf022fe90,%ecx
f0100f09:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = page_free_list;
f0100f0f:	89 31                	mov    %esi,(%ecx)
			page_free_list = &pages[i];
f0100f11:	89 d6                	mov    %edx,%esi
f0100f13:	03 35 90 fe 22 f0    	add    0xf022fe90,%esi
f0100f19:	b9 01 00 00 00       	mov    $0x1,%ecx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	uint32_t kern_pages = ((uint32_t)boot_alloc(0) - KERNBASE)/PGSIZE;
	cprintf ("kern_pages = %u\n", kern_pages);
	for (i = 0; i < npages; i++) {
f0100f1e:	83 c0 01             	add    $0x1,%eax
f0100f21:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0100f27:	72 94                	jb     f0100ebd <page_init+0x4e>
f0100f29:	84 c9                	test   %cl,%cl
f0100f2b:	74 06                	je     f0100f33 <page_init+0xc4>
f0100f2d:	89 35 40 f2 22 f0    	mov    %esi,0xf022f240
			page_free_list = &pages[i];

		}
	}
	
}
f0100f33:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f36:	5b                   	pop    %ebx
f0100f37:	5e                   	pop    %esi
f0100f38:	5f                   	pop    %edi
f0100f39:	5d                   	pop    %ebp
f0100f3a:	c3                   	ret    

f0100f3b <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f3b:	55                   	push   %ebp
f0100f3c:	89 e5                	mov    %esp,%ebp
f0100f3e:	53                   	push   %ebx
f0100f3f:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo *pp = page_free_list;
f0100f42:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx

	if (pp)
f0100f48:	85 db                	test   %ebx,%ebx
f0100f4a:	74 7c                	je     f0100fc8 <page_alloc+0x8d>
	{
		assert (pp->pp_ref == 0);
f0100f4c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100f51:	74 19                	je     f0100f6c <page_alloc+0x31>
f0100f53:	68 26 6a 10 f0       	push   $0xf0106a26
f0100f58:	68 68 69 10 f0       	push   $0xf0106968
f0100f5d:	68 7e 01 00 00       	push   $0x17e
f0100f62:	68 42 69 10 f0       	push   $0xf0106942
f0100f67:	e8 d4 f0 ff ff       	call   f0100040 <_panic>
		page_free_list = pp->pp_link;
f0100f6c:	8b 03                	mov    (%ebx),%eax
f0100f6e:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
		pp->pp_link = NULL;
f0100f73:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

		

		if(alloc_flags & ALLOC_ZERO)
			memset (page2kva(pp), 0, PGSIZE);
		return pp;
f0100f79:	89 d8                	mov    %ebx,%eax
		page_free_list = pp->pp_link;
		pp->pp_link = NULL;

		

		if(alloc_flags & ALLOC_ZERO)
f0100f7b:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f7f:	74 4c                	je     f0100fcd <page_alloc+0x92>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f81:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0100f87:	c1 f8 03             	sar    $0x3,%eax
f0100f8a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f8d:	89 c2                	mov    %eax,%edx
f0100f8f:	c1 ea 0c             	shr    $0xc,%edx
f0100f92:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100f98:	72 12                	jb     f0100fac <page_alloc+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f9a:	50                   	push   %eax
f0100f9b:	68 c4 63 10 f0       	push   $0xf01063c4
f0100fa0:	6a 58                	push   $0x58
f0100fa2:	68 4e 69 10 f0       	push   $0xf010694e
f0100fa7:	e8 94 f0 ff ff       	call   f0100040 <_panic>
			memset (page2kva(pp), 0, PGSIZE);
f0100fac:	83 ec 04             	sub    $0x4,%esp
f0100faf:	68 00 10 00 00       	push   $0x1000
f0100fb4:	6a 00                	push   $0x0
f0100fb6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fbb:	50                   	push   %eax
f0100fbc:	e8 2b 47 00 00       	call   f01056ec <memset>
f0100fc1:	83 c4 10             	add    $0x10,%esp
		return pp;
f0100fc4:	89 d8                	mov    %ebx,%eax
f0100fc6:	eb 05                	jmp    f0100fcd <page_alloc+0x92>

	}
	else
		return NULL;
f0100fc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100fcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fd0:	c9                   	leave  
f0100fd1:	c3                   	ret    

f0100fd2 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100fd2:	55                   	push   %ebp
f0100fd3:	89 e5                	mov    %esp,%ebp
f0100fd5:	83 ec 08             	sub    $0x8,%esp
f0100fd8:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.

	assert (pp->pp_link == NULL);
f0100fdb:	83 38 00             	cmpl   $0x0,(%eax)
f0100fde:	74 19                	je     f0100ff9 <page_free+0x27>
f0100fe0:	68 36 6a 10 f0       	push   $0xf0106a36
f0100fe5:	68 68 69 10 f0       	push   $0xf0106968
f0100fea:	68 98 01 00 00       	push   $0x198
f0100fef:	68 42 69 10 f0       	push   $0xf0106942
f0100ff4:	e8 47 f0 ff ff       	call   f0100040 <_panic>
	assert (pp->pp_ref == 0);
f0100ff9:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ffe:	74 19                	je     f0101019 <page_free+0x47>
f0101000:	68 26 6a 10 f0       	push   $0xf0106a26
f0101005:	68 68 69 10 f0       	push   $0xf0106968
f010100a:	68 99 01 00 00       	push   $0x199
f010100f:	68 42 69 10 f0       	push   $0xf0106942
f0101014:	e8 27 f0 ff ff       	call   f0100040 <_panic>
	
	pp->pp_link = page_free_list;
f0101019:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
f010101f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101021:	a3 40 f2 22 f0       	mov    %eax,0xf022f240

}
f0101026:	c9                   	leave  
f0101027:	c3                   	ret    

f0101028 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101028:	55                   	push   %ebp
f0101029:	89 e5                	mov    %esp,%ebp
f010102b:	83 ec 08             	sub    $0x8,%esp
f010102e:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101031:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101035:	83 e8 01             	sub    $0x1,%eax
f0101038:	66 89 42 04          	mov    %ax,0x4(%edx)
f010103c:	66 85 c0             	test   %ax,%ax
f010103f:	75 0c                	jne    f010104d <page_decref+0x25>
		page_free(pp);
f0101041:	83 ec 0c             	sub    $0xc,%esp
f0101044:	52                   	push   %edx
f0101045:	e8 88 ff ff ff       	call   f0100fd2 <page_free>
f010104a:	83 c4 10             	add    $0x10,%esp
}
f010104d:	c9                   	leave  
f010104e:	c3                   	ret    

f010104f <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010104f:	55                   	push   %ebp
f0101050:	89 e5                	mov    %esp,%ebp
f0101052:	56                   	push   %esi
f0101053:	53                   	push   %ebx
f0101054:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pde_t *result;
	struct PageInfo *pp;

	pte_t *pt = pgdir + PDX(va);  //address of directory entry
f0101057:	89 f3                	mov    %esi,%ebx
f0101059:	c1 eb 16             	shr    $0x16,%ebx
f010105c:	c1 e3 02             	shl    $0x2,%ebx
f010105f:	03 5d 08             	add    0x8(%ebp),%ebx

	if (!(*pt & PTE_P))   //check whether directory entry is present
f0101062:	f6 03 01             	testb  $0x1,(%ebx)
f0101065:	75 2d                	jne    f0101094 <pgdir_walk+0x45>
	{
		if (create)       //check whether create is true
f0101067:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010106b:	74 62                	je     f01010cf <pgdir_walk+0x80>
		{
			pp = page_alloc (1); //allocate a physical page to pp and memset it to 0
f010106d:	83 ec 0c             	sub    $0xc,%esp
f0101070:	6a 01                	push   $0x1
f0101072:	e8 c4 fe ff ff       	call   f0100f3b <page_alloc>
			if (!pp)             //if unable to allocate, return NULL
f0101077:	83 c4 10             	add    $0x10,%esp
f010107a:	85 c0                	test   %eax,%eax
f010107c:	74 58                	je     f01010d6 <pgdir_walk+0x87>
				return NULL;
			pp->pp_ref++;         
f010107e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			*pt = page2pa (pp) + PTE_P + PTE_W + PTE_U;  //convert the page address to physical address and add permissions
f0101083:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101089:	c1 f8 03             	sar    $0x3,%eax
f010108c:	c1 e0 0c             	shl    $0xc,%eax
f010108f:	83 c0 07             	add    $0x7,%eax
f0101092:	89 03                	mov    %eax,(%ebx)
		else
			return NULL;


	}
	result = KADDR(PTE_ADDR(*pt));  //calculate kernel address of the page table base 
f0101094:	8b 03                	mov    (%ebx),%eax
f0101096:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010109b:	89 c2                	mov    %eax,%edx
f010109d:	c1 ea 0c             	shr    $0xc,%edx
f01010a0:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f01010a6:	72 15                	jb     f01010bd <pgdir_walk+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010a8:	50                   	push   %eax
f01010a9:	68 c4 63 10 f0       	push   $0xf01063c4
f01010ae:	68 d9 01 00 00       	push   $0x1d9
f01010b3:	68 42 69 10 f0       	push   $0xf0106942
f01010b8:	e8 83 ef ff ff       	call   f0100040 <_panic>
	return (result + PTX(va));      //return kernel address of page table entry
f01010bd:	c1 ee 0a             	shr    $0xa,%esi
f01010c0:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010c6:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01010cd:	eb 0c                	jmp    f01010db <pgdir_walk+0x8c>
				return NULL;
			pp->pp_ref++;         
			*pt = page2pa (pp) + PTE_P + PTE_W + PTE_U;  //convert the page address to physical address and add permissions
		}
		else
			return NULL;
f01010cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01010d4:	eb 05                	jmp    f01010db <pgdir_walk+0x8c>
	{
		if (create)       //check whether create is true
		{
			pp = page_alloc (1); //allocate a physical page to pp and memset it to 0
			if (!pp)             //if unable to allocate, return NULL
				return NULL;
f01010d6:	b8 00 00 00 00       	mov    $0x0,%eax


	}
	result = KADDR(PTE_ADDR(*pt));  //calculate kernel address of the page table base 
	return (result + PTX(va));      //return kernel address of page table entry
}
f01010db:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010de:	5b                   	pop    %ebx
f01010df:	5e                   	pop    %esi
f01010e0:	5d                   	pop    %ebp
f01010e1:	c3                   	ret    

f01010e2 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010e2:	55                   	push   %ebp
f01010e3:	89 e5                	mov    %esp,%ebp
f01010e5:	57                   	push   %edi
f01010e6:	56                   	push   %esi
f01010e7:	53                   	push   %ebx
f01010e8:	83 ec 1c             	sub    $0x1c,%esp
f01010eb:	89 c7                	mov    %eax,%edi
f01010ed:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01010f0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	size_t i;
	for(i = 0; i<size; i+=PGSIZE)
f01010f3:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pgdir_walk(pgdir, (void*)va + i, 1) = (pa + i) + (perm | PTE_P);
f01010f8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01010fb:	83 ce 01             	or     $0x1,%esi
f01010fe:	03 75 08             	add    0x8(%ebp),%esi
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	for(i = 0; i<size; i+=PGSIZE)
f0101101:	eb 1f                	jmp    f0101122 <boot_map_region+0x40>
		*pgdir_walk(pgdir, (void*)va + i, 1) = (pa + i) + (perm | PTE_P);
f0101103:	83 ec 04             	sub    $0x4,%esp
f0101106:	6a 01                	push   $0x1
f0101108:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010110b:	01 d8                	add    %ebx,%eax
f010110d:	50                   	push   %eax
f010110e:	57                   	push   %edi
f010110f:	e8 3b ff ff ff       	call   f010104f <pgdir_walk>
f0101114:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0101117:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	for(i = 0; i<size; i+=PGSIZE)
f0101119:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010111f:	83 c4 10             	add    $0x10,%esp
f0101122:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101125:	72 dc                	jb     f0101103 <boot_map_region+0x21>
		*pgdir_walk(pgdir, (void*)va + i, 1) = (pa + i) + (perm | PTE_P);

}
f0101127:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010112a:	5b                   	pop    %ebx
f010112b:	5e                   	pop    %esi
f010112c:	5f                   	pop    %edi
f010112d:	5d                   	pop    %ebp
f010112e:	c3                   	ret    

f010112f <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010112f:	55                   	push   %ebp
f0101130:	89 e5                	mov    %esp,%ebp
f0101132:	53                   	push   %ebx
f0101133:	83 ec 08             	sub    $0x8,%esp
f0101136:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);;
f0101139:	6a 00                	push   $0x0
f010113b:	ff 75 0c             	pushl  0xc(%ebp)
f010113e:	ff 75 08             	pushl  0x8(%ebp)
f0101141:	e8 09 ff ff ff       	call   f010104f <pgdir_walk>

	if (!pte || !(*pte & PTE_P))
f0101146:	83 c4 10             	add    $0x10,%esp
f0101149:	85 c0                	test   %eax,%eax
f010114b:	74 37                	je     f0101184 <page_lookup+0x55>
f010114d:	f6 00 01             	testb  $0x1,(%eax)
f0101150:	74 39                	je     f010118b <page_lookup+0x5c>
		return NULL;
	if (pte_store)
f0101152:	85 db                	test   %ebx,%ebx
f0101154:	74 02                	je     f0101158 <page_lookup+0x29>
		*pte_store = pte;
f0101156:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101158:	8b 00                	mov    (%eax),%eax
f010115a:	c1 e8 0c             	shr    $0xc,%eax
f010115d:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0101163:	72 14                	jb     f0101179 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0101165:	83 ec 04             	sub    $0x4,%esp
f0101168:	68 84 6d 10 f0       	push   $0xf0106d84
f010116d:	6a 51                	push   $0x51
f010116f:	68 4e 69 10 f0       	push   $0xf010694e
f0101174:	e8 c7 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101179:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f010117f:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	return pa2page(PTE_ADDR(*pte));
f0101182:	eb 0c                	jmp    f0101190 <page_lookup+0x61>
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);;

	if (!pte || !(*pte & PTE_P))
		return NULL;
f0101184:	b8 00 00 00 00       	mov    $0x0,%eax
f0101189:	eb 05                	jmp    f0101190 <page_lookup+0x61>
f010118b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store)
		*pte_store = pte;

	return pa2page(PTE_ADDR(*pte));
}
f0101190:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101193:	c9                   	leave  
f0101194:	c3                   	ret    

f0101195 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101195:	55                   	push   %ebp
f0101196:	89 e5                	mov    %esp,%ebp
f0101198:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010119b:	e8 6e 4b 00 00       	call   f0105d0e <cpunum>
f01011a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01011a3:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01011aa:	74 16                	je     f01011c2 <tlb_invalidate+0x2d>
f01011ac:	e8 5d 4b 00 00       	call   f0105d0e <cpunum>
f01011b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01011b4:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01011ba:	8b 55 08             	mov    0x8(%ebp),%edx
f01011bd:	39 50 60             	cmp    %edx,0x60(%eax)
f01011c0:	75 06                	jne    f01011c8 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011c5:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011c8:	c9                   	leave  
f01011c9:	c3                   	ret    

f01011ca <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011ca:	55                   	push   %ebp
f01011cb:	89 e5                	mov    %esp,%ebp
f01011cd:	56                   	push   %esi
f01011ce:	53                   	push   %ebx
f01011cf:	83 ec 14             	sub    $0x14,%esp
f01011d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011d5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t *pte;
	
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f01011d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011db:	50                   	push   %eax
f01011dc:	56                   	push   %esi
f01011dd:	53                   	push   %ebx
f01011de:	e8 4c ff ff ff       	call   f010112f <page_lookup>

	if (pp)
f01011e3:	83 c4 10             	add    $0x10,%esp
f01011e6:	85 c0                	test   %eax,%eax
f01011e8:	74 1f                	je     f0101209 <page_remove+0x3f>
	{
		*pte = 0;
f01011ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01011ed:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(pp);
f01011f3:	83 ec 0c             	sub    $0xc,%esp
f01011f6:	50                   	push   %eax
f01011f7:	e8 2c fe ff ff       	call   f0101028 <page_decref>
		tlb_invalidate(pgdir, va);
f01011fc:	83 c4 08             	add    $0x8,%esp
f01011ff:	56                   	push   %esi
f0101200:	53                   	push   %ebx
f0101201:	e8 8f ff ff ff       	call   f0101195 <tlb_invalidate>
f0101206:	83 c4 10             	add    $0x10,%esp


	}
}
f0101209:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010120c:	5b                   	pop    %ebx
f010120d:	5e                   	pop    %esi
f010120e:	5d                   	pop    %ebp
f010120f:	c3                   	ret    

f0101210 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101210:	55                   	push   %ebp
f0101211:	89 e5                	mov    %esp,%ebp
f0101213:	57                   	push   %edi
f0101214:	56                   	push   %esi
f0101215:	53                   	push   %ebx
f0101216:	83 ec 10             	sub    $0x10,%esp
f0101219:	8b 75 08             	mov    0x8(%ebp),%esi
f010121c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f010121f:	6a 01                	push   $0x1
f0101221:	ff 75 10             	pushl  0x10(%ebp)
f0101224:	56                   	push   %esi
f0101225:	e8 25 fe ff ff       	call   f010104f <pgdir_walk>

	if (!pte)
f010122a:	83 c4 10             	add    $0x10,%esp
f010122d:	85 c0                	test   %eax,%eax
f010122f:	74 44                	je     f0101275 <page_insert+0x65>
f0101231:	89 c7                	mov    %eax,%edi
		return -E_NO_MEM;
	pp->pp_ref++;
f0101233:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)


	if (*pte & PTE_P)
f0101238:	f6 00 01             	testb  $0x1,(%eax)
f010123b:	74 0f                	je     f010124c <page_insert+0x3c>
		page_remove(pgdir, va);
f010123d:	83 ec 08             	sub    $0x8,%esp
f0101240:	ff 75 10             	pushl  0x10(%ebp)
f0101243:	56                   	push   %esi
f0101244:	e8 81 ff ff ff       	call   f01011ca <page_remove>
f0101249:	83 c4 10             	add    $0x10,%esp

	
	
	*pte = page2pa(pp) | perm | PTE_P;
f010124c:	2b 1d 90 fe 22 f0    	sub    0xf022fe90,%ebx
f0101252:	c1 fb 03             	sar    $0x3,%ebx
f0101255:	c1 e3 0c             	shl    $0xc,%ebx
f0101258:	8b 45 14             	mov    0x14(%ebp),%eax
f010125b:	83 c8 01             	or     $0x1,%eax
f010125e:	09 c3                	or     %eax,%ebx
f0101260:	89 1f                	mov    %ebx,(%edi)
	pgdir[PDX(va)] |= perm;
f0101262:	8b 45 10             	mov    0x10(%ebp),%eax
f0101265:	c1 e8 16             	shr    $0x16,%eax
f0101268:	8b 55 14             	mov    0x14(%ebp),%edx
f010126b:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f010126e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101273:	eb 05                	jmp    f010127a <page_insert+0x6a>
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);

	if (!pte)
		return -E_NO_MEM;
f0101275:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	
	
	*pte = page2pa(pp) | perm | PTE_P;
	pgdir[PDX(va)] |= perm;
	return 0;
}
f010127a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010127d:	5b                   	pop    %ebx
f010127e:	5e                   	pop    %esi
f010127f:	5f                   	pop    %edi
f0101280:	5d                   	pop    %ebp
f0101281:	c3                   	ret    

f0101282 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101282:	55                   	push   %ebp
f0101283:	89 e5                	mov    %esp,%ebp
f0101285:	53                   	push   %ebx
f0101286:	83 ec 04             	sub    $0x4,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:

	size = (size_t) ROUNDUP(size, PGSIZE);
f0101289:	8b 45 0c             	mov    0xc(%ebp),%eax
f010128c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101292:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	if (base + size > MMIOLIM)
f0101298:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f010129e:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01012a1:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012a6:	76 17                	jbe    f01012bf <mmio_map_region+0x3d>
		panic ("not enough memory!");
f01012a8:	83 ec 04             	sub    $0x4,%esp
f01012ab:	68 4a 6a 10 f0       	push   $0xf0106a4a
f01012b0:	68 8a 02 00 00       	push   $0x28a
f01012b5:	68 42 69 10 f0       	push   $0xf0106942
f01012ba:	e8 81 ed ff ff       	call   f0100040 <_panic>

	boot_map_region(kern_pgdir, base, size, pa, PTE_W | PTE_PCD | PTE_PWT | PTE_P);
f01012bf:	83 ec 08             	sub    $0x8,%esp
f01012c2:	6a 1b                	push   $0x1b
f01012c4:	ff 75 08             	pushl  0x8(%ebp)
f01012c7:	89 d9                	mov    %ebx,%ecx
f01012c9:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01012ce:	e8 0f fe ff ff       	call   f01010e2 <boot_map_region>

	base += size;
f01012d3:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f01012d8:	01 c3                	add    %eax,%ebx
f01012da:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300




	//panic("mmio_map_region not implemented");
}
f01012e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012e3:	c9                   	leave  
f01012e4:	c3                   	ret    

f01012e5 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01012e5:	55                   	push   %ebp
f01012e6:	89 e5                	mov    %esp,%ebp
f01012e8:	57                   	push   %edi
f01012e9:	56                   	push   %esi
f01012ea:	53                   	push   %ebx
f01012eb:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01012ee:	b8 15 00 00 00       	mov    $0x15,%eax
f01012f3:	e8 81 f7 ff ff       	call   f0100a79 <nvram_read>
f01012f8:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01012fa:	b8 17 00 00 00       	mov    $0x17,%eax
f01012ff:	e8 75 f7 ff ff       	call   f0100a79 <nvram_read>
f0101304:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101306:	b8 34 00 00 00       	mov    $0x34,%eax
f010130b:	e8 69 f7 ff ff       	call   f0100a79 <nvram_read>
f0101310:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101313:	85 c0                	test   %eax,%eax
f0101315:	74 07                	je     f010131e <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101317:	05 00 40 00 00       	add    $0x4000,%eax
f010131c:	eb 0b                	jmp    f0101329 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f010131e:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101324:	85 f6                	test   %esi,%esi
f0101326:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101329:	89 c2                	mov    %eax,%edx
f010132b:	c1 ea 02             	shr    $0x2,%edx
f010132e:	89 15 88 fe 22 f0    	mov    %edx,0xf022fe88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101334:	89 da                	mov    %ebx,%edx
f0101336:	c1 ea 02             	shr    $0x2,%edx
f0101339:	89 15 44 f2 22 f0    	mov    %edx,0xf022f244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010133f:	89 c2                	mov    %eax,%edx
f0101341:	29 da                	sub    %ebx,%edx
f0101343:	52                   	push   %edx
f0101344:	53                   	push   %ebx
f0101345:	50                   	push   %eax
f0101346:	68 a4 6d 10 f0       	push   $0xf0106da4
f010134b:	e8 b8 23 00 00       	call   f0103708 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101350:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101355:	e8 48 f7 ff ff       	call   f0100aa2 <boot_alloc>
f010135a:	a3 8c fe 22 f0       	mov    %eax,0xf022fe8c
	memset(kern_pgdir, 0, PGSIZE);
f010135f:	83 c4 0c             	add    $0xc,%esp
f0101362:	68 00 10 00 00       	push   $0x1000
f0101367:	6a 00                	push   $0x0
f0101369:	50                   	push   %eax
f010136a:	e8 7d 43 00 00       	call   f01056ec <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010136f:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101374:	83 c4 10             	add    $0x10,%esp
f0101377:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010137c:	77 15                	ja     f0101393 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010137e:	50                   	push   %eax
f010137f:	68 e8 63 10 f0       	push   $0xf01063e8
f0101384:	68 9b 00 00 00       	push   $0x9b
f0101389:	68 42 69 10 f0       	push   $0xf0106942
f010138e:	e8 ad ec ff ff       	call   f0100040 <_panic>
f0101393:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101399:	83 ca 05             	or     $0x5,%edx
f010139c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo *) boot_alloc (npages * sizeof (struct PageInfo) );
f01013a2:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f01013a7:	c1 e0 03             	shl    $0x3,%eax
f01013aa:	e8 f3 f6 ff ff       	call   f0100aa2 <boot_alloc>
f01013af:	a3 90 fe 22 f0       	mov    %eax,0xf022fe90
	memset (pages, 0, npages * sizeof (struct PageInfo));
f01013b4:	83 ec 04             	sub    $0x4,%esp
f01013b7:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f01013bd:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01013c4:	52                   	push   %edx
f01013c5:	6a 00                	push   $0x0
f01013c7:	50                   	push   %eax
f01013c8:	e8 1f 43 00 00       	call   f01056ec <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env *) boot_alloc ( NENV * sizeof(struct Env));
f01013cd:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013d2:	e8 cb f6 ff ff       	call   f0100aa2 <boot_alloc>
f01013d7:	a3 48 f2 22 f0       	mov    %eax,0xf022f248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01013dc:	e8 8e fa ff ff       	call   f0100e6f <page_init>

	check_page_free_list(1);
f01013e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01013e6:	e8 82 f7 ff ff       	call   f0100b6d <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013eb:	83 c4 10             	add    $0x10,%esp
f01013ee:	83 3d 90 fe 22 f0 00 	cmpl   $0x0,0xf022fe90
f01013f5:	75 17                	jne    f010140e <mem_init+0x129>
		panic("'pages' is a null pointer!");
f01013f7:	83 ec 04             	sub    $0x4,%esp
f01013fa:	68 5d 6a 10 f0       	push   $0xf0106a5d
f01013ff:	68 2a 03 00 00       	push   $0x32a
f0101404:	68 42 69 10 f0       	push   $0xf0106942
f0101409:	e8 32 ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010140e:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101413:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101418:	eb 05                	jmp    f010141f <mem_init+0x13a>
		++nfree;
f010141a:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010141d:	8b 00                	mov    (%eax),%eax
f010141f:	85 c0                	test   %eax,%eax
f0101421:	75 f7                	jne    f010141a <mem_init+0x135>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101423:	83 ec 0c             	sub    $0xc,%esp
f0101426:	6a 00                	push   $0x0
f0101428:	e8 0e fb ff ff       	call   f0100f3b <page_alloc>
f010142d:	89 c7                	mov    %eax,%edi
f010142f:	83 c4 10             	add    $0x10,%esp
f0101432:	85 c0                	test   %eax,%eax
f0101434:	75 19                	jne    f010144f <mem_init+0x16a>
f0101436:	68 78 6a 10 f0       	push   $0xf0106a78
f010143b:	68 68 69 10 f0       	push   $0xf0106968
f0101440:	68 32 03 00 00       	push   $0x332
f0101445:	68 42 69 10 f0       	push   $0xf0106942
f010144a:	e8 f1 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010144f:	83 ec 0c             	sub    $0xc,%esp
f0101452:	6a 00                	push   $0x0
f0101454:	e8 e2 fa ff ff       	call   f0100f3b <page_alloc>
f0101459:	89 c6                	mov    %eax,%esi
f010145b:	83 c4 10             	add    $0x10,%esp
f010145e:	85 c0                	test   %eax,%eax
f0101460:	75 19                	jne    f010147b <mem_init+0x196>
f0101462:	68 8e 6a 10 f0       	push   $0xf0106a8e
f0101467:	68 68 69 10 f0       	push   $0xf0106968
f010146c:	68 33 03 00 00       	push   $0x333
f0101471:	68 42 69 10 f0       	push   $0xf0106942
f0101476:	e8 c5 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010147b:	83 ec 0c             	sub    $0xc,%esp
f010147e:	6a 00                	push   $0x0
f0101480:	e8 b6 fa ff ff       	call   f0100f3b <page_alloc>
f0101485:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101488:	83 c4 10             	add    $0x10,%esp
f010148b:	85 c0                	test   %eax,%eax
f010148d:	75 19                	jne    f01014a8 <mem_init+0x1c3>
f010148f:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0101494:	68 68 69 10 f0       	push   $0xf0106968
f0101499:	68 34 03 00 00       	push   $0x334
f010149e:	68 42 69 10 f0       	push   $0xf0106942
f01014a3:	e8 98 eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014a8:	39 f7                	cmp    %esi,%edi
f01014aa:	75 19                	jne    f01014c5 <mem_init+0x1e0>
f01014ac:	68 ba 6a 10 f0       	push   $0xf0106aba
f01014b1:	68 68 69 10 f0       	push   $0xf0106968
f01014b6:	68 37 03 00 00       	push   $0x337
f01014bb:	68 42 69 10 f0       	push   $0xf0106942
f01014c0:	e8 7b eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014c8:	39 c6                	cmp    %eax,%esi
f01014ca:	74 04                	je     f01014d0 <mem_init+0x1eb>
f01014cc:	39 c7                	cmp    %eax,%edi
f01014ce:	75 19                	jne    f01014e9 <mem_init+0x204>
f01014d0:	68 e0 6d 10 f0       	push   $0xf0106de0
f01014d5:	68 68 69 10 f0       	push   $0xf0106968
f01014da:	68 38 03 00 00       	push   $0x338
f01014df:	68 42 69 10 f0       	push   $0xf0106942
f01014e4:	e8 57 eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014e9:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014ef:	8b 15 88 fe 22 f0    	mov    0xf022fe88,%edx
f01014f5:	c1 e2 0c             	shl    $0xc,%edx
f01014f8:	89 f8                	mov    %edi,%eax
f01014fa:	29 c8                	sub    %ecx,%eax
f01014fc:	c1 f8 03             	sar    $0x3,%eax
f01014ff:	c1 e0 0c             	shl    $0xc,%eax
f0101502:	39 d0                	cmp    %edx,%eax
f0101504:	72 19                	jb     f010151f <mem_init+0x23a>
f0101506:	68 cc 6a 10 f0       	push   $0xf0106acc
f010150b:	68 68 69 10 f0       	push   $0xf0106968
f0101510:	68 39 03 00 00       	push   $0x339
f0101515:	68 42 69 10 f0       	push   $0xf0106942
f010151a:	e8 21 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010151f:	89 f0                	mov    %esi,%eax
f0101521:	29 c8                	sub    %ecx,%eax
f0101523:	c1 f8 03             	sar    $0x3,%eax
f0101526:	c1 e0 0c             	shl    $0xc,%eax
f0101529:	39 c2                	cmp    %eax,%edx
f010152b:	77 19                	ja     f0101546 <mem_init+0x261>
f010152d:	68 e9 6a 10 f0       	push   $0xf0106ae9
f0101532:	68 68 69 10 f0       	push   $0xf0106968
f0101537:	68 3a 03 00 00       	push   $0x33a
f010153c:	68 42 69 10 f0       	push   $0xf0106942
f0101541:	e8 fa ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101546:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101549:	29 c8                	sub    %ecx,%eax
f010154b:	c1 f8 03             	sar    $0x3,%eax
f010154e:	c1 e0 0c             	shl    $0xc,%eax
f0101551:	39 c2                	cmp    %eax,%edx
f0101553:	77 19                	ja     f010156e <mem_init+0x289>
f0101555:	68 06 6b 10 f0       	push   $0xf0106b06
f010155a:	68 68 69 10 f0       	push   $0xf0106968
f010155f:	68 3b 03 00 00       	push   $0x33b
f0101564:	68 42 69 10 f0       	push   $0xf0106942
f0101569:	e8 d2 ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010156e:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101573:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101576:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f010157d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101580:	83 ec 0c             	sub    $0xc,%esp
f0101583:	6a 00                	push   $0x0
f0101585:	e8 b1 f9 ff ff       	call   f0100f3b <page_alloc>
f010158a:	83 c4 10             	add    $0x10,%esp
f010158d:	85 c0                	test   %eax,%eax
f010158f:	74 19                	je     f01015aa <mem_init+0x2c5>
f0101591:	68 23 6b 10 f0       	push   $0xf0106b23
f0101596:	68 68 69 10 f0       	push   $0xf0106968
f010159b:	68 42 03 00 00       	push   $0x342
f01015a0:	68 42 69 10 f0       	push   $0xf0106942
f01015a5:	e8 96 ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015aa:	83 ec 0c             	sub    $0xc,%esp
f01015ad:	57                   	push   %edi
f01015ae:	e8 1f fa ff ff       	call   f0100fd2 <page_free>
	page_free(pp1);
f01015b3:	89 34 24             	mov    %esi,(%esp)
f01015b6:	e8 17 fa ff ff       	call   f0100fd2 <page_free>
	page_free(pp2);
f01015bb:	83 c4 04             	add    $0x4,%esp
f01015be:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015c1:	e8 0c fa ff ff       	call   f0100fd2 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015cd:	e8 69 f9 ff ff       	call   f0100f3b <page_alloc>
f01015d2:	89 c6                	mov    %eax,%esi
f01015d4:	83 c4 10             	add    $0x10,%esp
f01015d7:	85 c0                	test   %eax,%eax
f01015d9:	75 19                	jne    f01015f4 <mem_init+0x30f>
f01015db:	68 78 6a 10 f0       	push   $0xf0106a78
f01015e0:	68 68 69 10 f0       	push   $0xf0106968
f01015e5:	68 49 03 00 00       	push   $0x349
f01015ea:	68 42 69 10 f0       	push   $0xf0106942
f01015ef:	e8 4c ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015f4:	83 ec 0c             	sub    $0xc,%esp
f01015f7:	6a 00                	push   $0x0
f01015f9:	e8 3d f9 ff ff       	call   f0100f3b <page_alloc>
f01015fe:	89 c7                	mov    %eax,%edi
f0101600:	83 c4 10             	add    $0x10,%esp
f0101603:	85 c0                	test   %eax,%eax
f0101605:	75 19                	jne    f0101620 <mem_init+0x33b>
f0101607:	68 8e 6a 10 f0       	push   $0xf0106a8e
f010160c:	68 68 69 10 f0       	push   $0xf0106968
f0101611:	68 4a 03 00 00       	push   $0x34a
f0101616:	68 42 69 10 f0       	push   $0xf0106942
f010161b:	e8 20 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101620:	83 ec 0c             	sub    $0xc,%esp
f0101623:	6a 00                	push   $0x0
f0101625:	e8 11 f9 ff ff       	call   f0100f3b <page_alloc>
f010162a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010162d:	83 c4 10             	add    $0x10,%esp
f0101630:	85 c0                	test   %eax,%eax
f0101632:	75 19                	jne    f010164d <mem_init+0x368>
f0101634:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0101639:	68 68 69 10 f0       	push   $0xf0106968
f010163e:	68 4b 03 00 00       	push   $0x34b
f0101643:	68 42 69 10 f0       	push   $0xf0106942
f0101648:	e8 f3 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010164d:	39 fe                	cmp    %edi,%esi
f010164f:	75 19                	jne    f010166a <mem_init+0x385>
f0101651:	68 ba 6a 10 f0       	push   $0xf0106aba
f0101656:	68 68 69 10 f0       	push   $0xf0106968
f010165b:	68 4d 03 00 00       	push   $0x34d
f0101660:	68 42 69 10 f0       	push   $0xf0106942
f0101665:	e8 d6 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010166a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010166d:	39 c7                	cmp    %eax,%edi
f010166f:	74 04                	je     f0101675 <mem_init+0x390>
f0101671:	39 c6                	cmp    %eax,%esi
f0101673:	75 19                	jne    f010168e <mem_init+0x3a9>
f0101675:	68 e0 6d 10 f0       	push   $0xf0106de0
f010167a:	68 68 69 10 f0       	push   $0xf0106968
f010167f:	68 4e 03 00 00       	push   $0x34e
f0101684:	68 42 69 10 f0       	push   $0xf0106942
f0101689:	e8 b2 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010168e:	83 ec 0c             	sub    $0xc,%esp
f0101691:	6a 00                	push   $0x0
f0101693:	e8 a3 f8 ff ff       	call   f0100f3b <page_alloc>
f0101698:	83 c4 10             	add    $0x10,%esp
f010169b:	85 c0                	test   %eax,%eax
f010169d:	74 19                	je     f01016b8 <mem_init+0x3d3>
f010169f:	68 23 6b 10 f0       	push   $0xf0106b23
f01016a4:	68 68 69 10 f0       	push   $0xf0106968
f01016a9:	68 4f 03 00 00       	push   $0x34f
f01016ae:	68 42 69 10 f0       	push   $0xf0106942
f01016b3:	e8 88 e9 ff ff       	call   f0100040 <_panic>
f01016b8:	89 f0                	mov    %esi,%eax
f01016ba:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01016c0:	c1 f8 03             	sar    $0x3,%eax
f01016c3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016c6:	89 c2                	mov    %eax,%edx
f01016c8:	c1 ea 0c             	shr    $0xc,%edx
f01016cb:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f01016d1:	72 12                	jb     f01016e5 <mem_init+0x400>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016d3:	50                   	push   %eax
f01016d4:	68 c4 63 10 f0       	push   $0xf01063c4
f01016d9:	6a 58                	push   $0x58
f01016db:	68 4e 69 10 f0       	push   $0xf010694e
f01016e0:	e8 5b e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01016e5:	83 ec 04             	sub    $0x4,%esp
f01016e8:	68 00 10 00 00       	push   $0x1000
f01016ed:	6a 01                	push   $0x1
f01016ef:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016f4:	50                   	push   %eax
f01016f5:	e8 f2 3f 00 00       	call   f01056ec <memset>
	page_free(pp0);
f01016fa:	89 34 24             	mov    %esi,(%esp)
f01016fd:	e8 d0 f8 ff ff       	call   f0100fd2 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101702:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101709:	e8 2d f8 ff ff       	call   f0100f3b <page_alloc>
f010170e:	83 c4 10             	add    $0x10,%esp
f0101711:	85 c0                	test   %eax,%eax
f0101713:	75 19                	jne    f010172e <mem_init+0x449>
f0101715:	68 32 6b 10 f0       	push   $0xf0106b32
f010171a:	68 68 69 10 f0       	push   $0xf0106968
f010171f:	68 54 03 00 00       	push   $0x354
f0101724:	68 42 69 10 f0       	push   $0xf0106942
f0101729:	e8 12 e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010172e:	39 c6                	cmp    %eax,%esi
f0101730:	74 19                	je     f010174b <mem_init+0x466>
f0101732:	68 50 6b 10 f0       	push   $0xf0106b50
f0101737:	68 68 69 10 f0       	push   $0xf0106968
f010173c:	68 55 03 00 00       	push   $0x355
f0101741:	68 42 69 10 f0       	push   $0xf0106942
f0101746:	e8 f5 e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010174b:	89 f0                	mov    %esi,%eax
f010174d:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101753:	c1 f8 03             	sar    $0x3,%eax
f0101756:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101759:	89 c2                	mov    %eax,%edx
f010175b:	c1 ea 0c             	shr    $0xc,%edx
f010175e:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101764:	72 12                	jb     f0101778 <mem_init+0x493>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101766:	50                   	push   %eax
f0101767:	68 c4 63 10 f0       	push   $0xf01063c4
f010176c:	6a 58                	push   $0x58
f010176e:	68 4e 69 10 f0       	push   $0xf010694e
f0101773:	e8 c8 e8 ff ff       	call   f0100040 <_panic>
f0101778:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010177e:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101784:	80 38 00             	cmpb   $0x0,(%eax)
f0101787:	74 19                	je     f01017a2 <mem_init+0x4bd>
f0101789:	68 60 6b 10 f0       	push   $0xf0106b60
f010178e:	68 68 69 10 f0       	push   $0xf0106968
f0101793:	68 58 03 00 00       	push   $0x358
f0101798:	68 42 69 10 f0       	push   $0xf0106942
f010179d:	e8 9e e8 ff ff       	call   f0100040 <_panic>
f01017a2:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017a5:	39 d0                	cmp    %edx,%eax
f01017a7:	75 db                	jne    f0101784 <mem_init+0x49f>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017ac:	a3 40 f2 22 f0       	mov    %eax,0xf022f240

	// free the pages we took
	page_free(pp0);
f01017b1:	83 ec 0c             	sub    $0xc,%esp
f01017b4:	56                   	push   %esi
f01017b5:	e8 18 f8 ff ff       	call   f0100fd2 <page_free>
	page_free(pp1);
f01017ba:	89 3c 24             	mov    %edi,(%esp)
f01017bd:	e8 10 f8 ff ff       	call   f0100fd2 <page_free>
	page_free(pp2);
f01017c2:	83 c4 04             	add    $0x4,%esp
f01017c5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017c8:	e8 05 f8 ff ff       	call   f0100fd2 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017cd:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f01017d2:	83 c4 10             	add    $0x10,%esp
f01017d5:	eb 05                	jmp    f01017dc <mem_init+0x4f7>
		--nfree;
f01017d7:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017da:	8b 00                	mov    (%eax),%eax
f01017dc:	85 c0                	test   %eax,%eax
f01017de:	75 f7                	jne    f01017d7 <mem_init+0x4f2>
		--nfree;
	assert(nfree == 0);
f01017e0:	85 db                	test   %ebx,%ebx
f01017e2:	74 19                	je     f01017fd <mem_init+0x518>
f01017e4:	68 6a 6b 10 f0       	push   $0xf0106b6a
f01017e9:	68 68 69 10 f0       	push   $0xf0106968
f01017ee:	68 65 03 00 00       	push   $0x365
f01017f3:	68 42 69 10 f0       	push   $0xf0106942
f01017f8:	e8 43 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01017fd:	83 ec 0c             	sub    $0xc,%esp
f0101800:	68 00 6e 10 f0       	push   $0xf0106e00
f0101805:	e8 fe 1e 00 00       	call   f0103708 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010180a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101811:	e8 25 f7 ff ff       	call   f0100f3b <page_alloc>
f0101816:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101819:	83 c4 10             	add    $0x10,%esp
f010181c:	85 c0                	test   %eax,%eax
f010181e:	75 19                	jne    f0101839 <mem_init+0x554>
f0101820:	68 78 6a 10 f0       	push   $0xf0106a78
f0101825:	68 68 69 10 f0       	push   $0xf0106968
f010182a:	68 cb 03 00 00       	push   $0x3cb
f010182f:	68 42 69 10 f0       	push   $0xf0106942
f0101834:	e8 07 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101839:	83 ec 0c             	sub    $0xc,%esp
f010183c:	6a 00                	push   $0x0
f010183e:	e8 f8 f6 ff ff       	call   f0100f3b <page_alloc>
f0101843:	89 c3                	mov    %eax,%ebx
f0101845:	83 c4 10             	add    $0x10,%esp
f0101848:	85 c0                	test   %eax,%eax
f010184a:	75 19                	jne    f0101865 <mem_init+0x580>
f010184c:	68 8e 6a 10 f0       	push   $0xf0106a8e
f0101851:	68 68 69 10 f0       	push   $0xf0106968
f0101856:	68 cc 03 00 00       	push   $0x3cc
f010185b:	68 42 69 10 f0       	push   $0xf0106942
f0101860:	e8 db e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101865:	83 ec 0c             	sub    $0xc,%esp
f0101868:	6a 00                	push   $0x0
f010186a:	e8 cc f6 ff ff       	call   f0100f3b <page_alloc>
f010186f:	89 c6                	mov    %eax,%esi
f0101871:	83 c4 10             	add    $0x10,%esp
f0101874:	85 c0                	test   %eax,%eax
f0101876:	75 19                	jne    f0101891 <mem_init+0x5ac>
f0101878:	68 a4 6a 10 f0       	push   $0xf0106aa4
f010187d:	68 68 69 10 f0       	push   $0xf0106968
f0101882:	68 cd 03 00 00       	push   $0x3cd
f0101887:	68 42 69 10 f0       	push   $0xf0106942
f010188c:	e8 af e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101891:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101894:	75 19                	jne    f01018af <mem_init+0x5ca>
f0101896:	68 ba 6a 10 f0       	push   $0xf0106aba
f010189b:	68 68 69 10 f0       	push   $0xf0106968
f01018a0:	68 d0 03 00 00       	push   $0x3d0
f01018a5:	68 42 69 10 f0       	push   $0xf0106942
f01018aa:	e8 91 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018af:	39 c3                	cmp    %eax,%ebx
f01018b1:	74 05                	je     f01018b8 <mem_init+0x5d3>
f01018b3:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018b6:	75 19                	jne    f01018d1 <mem_init+0x5ec>
f01018b8:	68 e0 6d 10 f0       	push   $0xf0106de0
f01018bd:	68 68 69 10 f0       	push   $0xf0106968
f01018c2:	68 d1 03 00 00       	push   $0x3d1
f01018c7:	68 42 69 10 f0       	push   $0xf0106942
f01018cc:	e8 6f e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018d1:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f01018d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018d9:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f01018e0:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018e3:	83 ec 0c             	sub    $0xc,%esp
f01018e6:	6a 00                	push   $0x0
f01018e8:	e8 4e f6 ff ff       	call   f0100f3b <page_alloc>
f01018ed:	83 c4 10             	add    $0x10,%esp
f01018f0:	85 c0                	test   %eax,%eax
f01018f2:	74 19                	je     f010190d <mem_init+0x628>
f01018f4:	68 23 6b 10 f0       	push   $0xf0106b23
f01018f9:	68 68 69 10 f0       	push   $0xf0106968
f01018fe:	68 d8 03 00 00       	push   $0x3d8
f0101903:	68 42 69 10 f0       	push   $0xf0106942
f0101908:	e8 33 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010190d:	83 ec 04             	sub    $0x4,%esp
f0101910:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101913:	50                   	push   %eax
f0101914:	6a 00                	push   $0x0
f0101916:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010191c:	e8 0e f8 ff ff       	call   f010112f <page_lookup>
f0101921:	83 c4 10             	add    $0x10,%esp
f0101924:	85 c0                	test   %eax,%eax
f0101926:	74 19                	je     f0101941 <mem_init+0x65c>
f0101928:	68 20 6e 10 f0       	push   $0xf0106e20
f010192d:	68 68 69 10 f0       	push   $0xf0106968
f0101932:	68 db 03 00 00       	push   $0x3db
f0101937:	68 42 69 10 f0       	push   $0xf0106942
f010193c:	e8 ff e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101941:	6a 02                	push   $0x2
f0101943:	6a 00                	push   $0x0
f0101945:	53                   	push   %ebx
f0101946:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010194c:	e8 bf f8 ff ff       	call   f0101210 <page_insert>
f0101951:	83 c4 10             	add    $0x10,%esp
f0101954:	85 c0                	test   %eax,%eax
f0101956:	78 19                	js     f0101971 <mem_init+0x68c>
f0101958:	68 58 6e 10 f0       	push   $0xf0106e58
f010195d:	68 68 69 10 f0       	push   $0xf0106968
f0101962:	68 de 03 00 00       	push   $0x3de
f0101967:	68 42 69 10 f0       	push   $0xf0106942
f010196c:	e8 cf e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101971:	83 ec 0c             	sub    $0xc,%esp
f0101974:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101977:	e8 56 f6 ff ff       	call   f0100fd2 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010197c:	6a 02                	push   $0x2
f010197e:	6a 00                	push   $0x0
f0101980:	53                   	push   %ebx
f0101981:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101987:	e8 84 f8 ff ff       	call   f0101210 <page_insert>
f010198c:	83 c4 20             	add    $0x20,%esp
f010198f:	85 c0                	test   %eax,%eax
f0101991:	74 19                	je     f01019ac <mem_init+0x6c7>
f0101993:	68 88 6e 10 f0       	push   $0xf0106e88
f0101998:	68 68 69 10 f0       	push   $0xf0106968
f010199d:	68 e2 03 00 00       	push   $0x3e2
f01019a2:	68 42 69 10 f0       	push   $0xf0106942
f01019a7:	e8 94 e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019ac:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019b2:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f01019b7:	89 c1                	mov    %eax,%ecx
f01019b9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019bc:	8b 17                	mov    (%edi),%edx
f01019be:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019c7:	29 c8                	sub    %ecx,%eax
f01019c9:	c1 f8 03             	sar    $0x3,%eax
f01019cc:	c1 e0 0c             	shl    $0xc,%eax
f01019cf:	39 c2                	cmp    %eax,%edx
f01019d1:	74 19                	je     f01019ec <mem_init+0x707>
f01019d3:	68 b8 6e 10 f0       	push   $0xf0106eb8
f01019d8:	68 68 69 10 f0       	push   $0xf0106968
f01019dd:	68 e3 03 00 00       	push   $0x3e3
f01019e2:	68 42 69 10 f0       	push   $0xf0106942
f01019e7:	e8 54 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019ec:	ba 00 00 00 00       	mov    $0x0,%edx
f01019f1:	89 f8                	mov    %edi,%eax
f01019f3:	e8 11 f1 ff ff       	call   f0100b09 <check_va2pa>
f01019f8:	89 da                	mov    %ebx,%edx
f01019fa:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01019fd:	c1 fa 03             	sar    $0x3,%edx
f0101a00:	c1 e2 0c             	shl    $0xc,%edx
f0101a03:	39 d0                	cmp    %edx,%eax
f0101a05:	74 19                	je     f0101a20 <mem_init+0x73b>
f0101a07:	68 e0 6e 10 f0       	push   $0xf0106ee0
f0101a0c:	68 68 69 10 f0       	push   $0xf0106968
f0101a11:	68 e4 03 00 00       	push   $0x3e4
f0101a16:	68 42 69 10 f0       	push   $0xf0106942
f0101a1b:	e8 20 e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101a20:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a25:	74 19                	je     f0101a40 <mem_init+0x75b>
f0101a27:	68 75 6b 10 f0       	push   $0xf0106b75
f0101a2c:	68 68 69 10 f0       	push   $0xf0106968
f0101a31:	68 e5 03 00 00       	push   $0x3e5
f0101a36:	68 42 69 10 f0       	push   $0xf0106942
f0101a3b:	e8 00 e6 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a43:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a48:	74 19                	je     f0101a63 <mem_init+0x77e>
f0101a4a:	68 86 6b 10 f0       	push   $0xf0106b86
f0101a4f:	68 68 69 10 f0       	push   $0xf0106968
f0101a54:	68 e6 03 00 00       	push   $0x3e6
f0101a59:	68 42 69 10 f0       	push   $0xf0106942
f0101a5e:	e8 dd e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a63:	6a 02                	push   $0x2
f0101a65:	68 00 10 00 00       	push   $0x1000
f0101a6a:	56                   	push   %esi
f0101a6b:	57                   	push   %edi
f0101a6c:	e8 9f f7 ff ff       	call   f0101210 <page_insert>
f0101a71:	83 c4 10             	add    $0x10,%esp
f0101a74:	85 c0                	test   %eax,%eax
f0101a76:	74 19                	je     f0101a91 <mem_init+0x7ac>
f0101a78:	68 10 6f 10 f0       	push   $0xf0106f10
f0101a7d:	68 68 69 10 f0       	push   $0xf0106968
f0101a82:	68 e9 03 00 00       	push   $0x3e9
f0101a87:	68 42 69 10 f0       	push   $0xf0106942
f0101a8c:	e8 af e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a91:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a96:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101a9b:	e8 69 f0 ff ff       	call   f0100b09 <check_va2pa>
f0101aa0:	89 f2                	mov    %esi,%edx
f0101aa2:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101aa8:	c1 fa 03             	sar    $0x3,%edx
f0101aab:	c1 e2 0c             	shl    $0xc,%edx
f0101aae:	39 d0                	cmp    %edx,%eax
f0101ab0:	74 19                	je     f0101acb <mem_init+0x7e6>
f0101ab2:	68 4c 6f 10 f0       	push   $0xf0106f4c
f0101ab7:	68 68 69 10 f0       	push   $0xf0106968
f0101abc:	68 ea 03 00 00       	push   $0x3ea
f0101ac1:	68 42 69 10 f0       	push   $0xf0106942
f0101ac6:	e8 75 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101acb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ad0:	74 19                	je     f0101aeb <mem_init+0x806>
f0101ad2:	68 97 6b 10 f0       	push   $0xf0106b97
f0101ad7:	68 68 69 10 f0       	push   $0xf0106968
f0101adc:	68 eb 03 00 00       	push   $0x3eb
f0101ae1:	68 42 69 10 f0       	push   $0xf0106942
f0101ae6:	e8 55 e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101aeb:	83 ec 0c             	sub    $0xc,%esp
f0101aee:	6a 00                	push   $0x0
f0101af0:	e8 46 f4 ff ff       	call   f0100f3b <page_alloc>
f0101af5:	83 c4 10             	add    $0x10,%esp
f0101af8:	85 c0                	test   %eax,%eax
f0101afa:	74 19                	je     f0101b15 <mem_init+0x830>
f0101afc:	68 23 6b 10 f0       	push   $0xf0106b23
f0101b01:	68 68 69 10 f0       	push   $0xf0106968
f0101b06:	68 ee 03 00 00       	push   $0x3ee
f0101b0b:	68 42 69 10 f0       	push   $0xf0106942
f0101b10:	e8 2b e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b15:	6a 02                	push   $0x2
f0101b17:	68 00 10 00 00       	push   $0x1000
f0101b1c:	56                   	push   %esi
f0101b1d:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101b23:	e8 e8 f6 ff ff       	call   f0101210 <page_insert>
f0101b28:	83 c4 10             	add    $0x10,%esp
f0101b2b:	85 c0                	test   %eax,%eax
f0101b2d:	74 19                	je     f0101b48 <mem_init+0x863>
f0101b2f:	68 10 6f 10 f0       	push   $0xf0106f10
f0101b34:	68 68 69 10 f0       	push   $0xf0106968
f0101b39:	68 f1 03 00 00       	push   $0x3f1
f0101b3e:	68 42 69 10 f0       	push   $0xf0106942
f0101b43:	e8 f8 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b48:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b4d:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101b52:	e8 b2 ef ff ff       	call   f0100b09 <check_va2pa>
f0101b57:	89 f2                	mov    %esi,%edx
f0101b59:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101b5f:	c1 fa 03             	sar    $0x3,%edx
f0101b62:	c1 e2 0c             	shl    $0xc,%edx
f0101b65:	39 d0                	cmp    %edx,%eax
f0101b67:	74 19                	je     f0101b82 <mem_init+0x89d>
f0101b69:	68 4c 6f 10 f0       	push   $0xf0106f4c
f0101b6e:	68 68 69 10 f0       	push   $0xf0106968
f0101b73:	68 f2 03 00 00       	push   $0x3f2
f0101b78:	68 42 69 10 f0       	push   $0xf0106942
f0101b7d:	e8 be e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b82:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b87:	74 19                	je     f0101ba2 <mem_init+0x8bd>
f0101b89:	68 97 6b 10 f0       	push   $0xf0106b97
f0101b8e:	68 68 69 10 f0       	push   $0xf0106968
f0101b93:	68 f3 03 00 00       	push   $0x3f3
f0101b98:	68 42 69 10 f0       	push   $0xf0106942
f0101b9d:	e8 9e e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ba2:	83 ec 0c             	sub    $0xc,%esp
f0101ba5:	6a 00                	push   $0x0
f0101ba7:	e8 8f f3 ff ff       	call   f0100f3b <page_alloc>
f0101bac:	83 c4 10             	add    $0x10,%esp
f0101baf:	85 c0                	test   %eax,%eax
f0101bb1:	74 19                	je     f0101bcc <mem_init+0x8e7>
f0101bb3:	68 23 6b 10 f0       	push   $0xf0106b23
f0101bb8:	68 68 69 10 f0       	push   $0xf0106968
f0101bbd:	68 f7 03 00 00       	push   $0x3f7
f0101bc2:	68 42 69 10 f0       	push   $0xf0106942
f0101bc7:	e8 74 e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101bcc:	8b 15 8c fe 22 f0    	mov    0xf022fe8c,%edx
f0101bd2:	8b 02                	mov    (%edx),%eax
f0101bd4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bd9:	89 c1                	mov    %eax,%ecx
f0101bdb:	c1 e9 0c             	shr    $0xc,%ecx
f0101bde:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0101be4:	72 15                	jb     f0101bfb <mem_init+0x916>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101be6:	50                   	push   %eax
f0101be7:	68 c4 63 10 f0       	push   $0xf01063c4
f0101bec:	68 fa 03 00 00       	push   $0x3fa
f0101bf1:	68 42 69 10 f0       	push   $0xf0106942
f0101bf6:	e8 45 e4 ff ff       	call   f0100040 <_panic>
f0101bfb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c03:	83 ec 04             	sub    $0x4,%esp
f0101c06:	6a 00                	push   $0x0
f0101c08:	68 00 10 00 00       	push   $0x1000
f0101c0d:	52                   	push   %edx
f0101c0e:	e8 3c f4 ff ff       	call   f010104f <pgdir_walk>
f0101c13:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c16:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c19:	83 c4 10             	add    $0x10,%esp
f0101c1c:	39 d0                	cmp    %edx,%eax
f0101c1e:	74 19                	je     f0101c39 <mem_init+0x954>
f0101c20:	68 7c 6f 10 f0       	push   $0xf0106f7c
f0101c25:	68 68 69 10 f0       	push   $0xf0106968
f0101c2a:	68 fb 03 00 00       	push   $0x3fb
f0101c2f:	68 42 69 10 f0       	push   $0xf0106942
f0101c34:	e8 07 e4 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c39:	6a 06                	push   $0x6
f0101c3b:	68 00 10 00 00       	push   $0x1000
f0101c40:	56                   	push   %esi
f0101c41:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101c47:	e8 c4 f5 ff ff       	call   f0101210 <page_insert>
f0101c4c:	83 c4 10             	add    $0x10,%esp
f0101c4f:	85 c0                	test   %eax,%eax
f0101c51:	74 19                	je     f0101c6c <mem_init+0x987>
f0101c53:	68 bc 6f 10 f0       	push   $0xf0106fbc
f0101c58:	68 68 69 10 f0       	push   $0xf0106968
f0101c5d:	68 fe 03 00 00       	push   $0x3fe
f0101c62:	68 42 69 10 f0       	push   $0xf0106942
f0101c67:	e8 d4 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c6c:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101c72:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c77:	89 f8                	mov    %edi,%eax
f0101c79:	e8 8b ee ff ff       	call   f0100b09 <check_va2pa>
f0101c7e:	89 f2                	mov    %esi,%edx
f0101c80:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101c86:	c1 fa 03             	sar    $0x3,%edx
f0101c89:	c1 e2 0c             	shl    $0xc,%edx
f0101c8c:	39 d0                	cmp    %edx,%eax
f0101c8e:	74 19                	je     f0101ca9 <mem_init+0x9c4>
f0101c90:	68 4c 6f 10 f0       	push   $0xf0106f4c
f0101c95:	68 68 69 10 f0       	push   $0xf0106968
f0101c9a:	68 ff 03 00 00       	push   $0x3ff
f0101c9f:	68 42 69 10 f0       	push   $0xf0106942
f0101ca4:	e8 97 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ca9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cae:	74 19                	je     f0101cc9 <mem_init+0x9e4>
f0101cb0:	68 97 6b 10 f0       	push   $0xf0106b97
f0101cb5:	68 68 69 10 f0       	push   $0xf0106968
f0101cba:	68 00 04 00 00       	push   $0x400
f0101cbf:	68 42 69 10 f0       	push   $0xf0106942
f0101cc4:	e8 77 e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101cc9:	83 ec 04             	sub    $0x4,%esp
f0101ccc:	6a 00                	push   $0x0
f0101cce:	68 00 10 00 00       	push   $0x1000
f0101cd3:	57                   	push   %edi
f0101cd4:	e8 76 f3 ff ff       	call   f010104f <pgdir_walk>
f0101cd9:	83 c4 10             	add    $0x10,%esp
f0101cdc:	f6 00 04             	testb  $0x4,(%eax)
f0101cdf:	75 19                	jne    f0101cfa <mem_init+0xa15>
f0101ce1:	68 fc 6f 10 f0       	push   $0xf0106ffc
f0101ce6:	68 68 69 10 f0       	push   $0xf0106968
f0101ceb:	68 01 04 00 00       	push   $0x401
f0101cf0:	68 42 69 10 f0       	push   $0xf0106942
f0101cf5:	e8 46 e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101cfa:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101cff:	f6 00 04             	testb  $0x4,(%eax)
f0101d02:	75 19                	jne    f0101d1d <mem_init+0xa38>
f0101d04:	68 a8 6b 10 f0       	push   $0xf0106ba8
f0101d09:	68 68 69 10 f0       	push   $0xf0106968
f0101d0e:	68 02 04 00 00       	push   $0x402
f0101d13:	68 42 69 10 f0       	push   $0xf0106942
f0101d18:	e8 23 e3 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d1d:	6a 02                	push   $0x2
f0101d1f:	68 00 10 00 00       	push   $0x1000
f0101d24:	56                   	push   %esi
f0101d25:	50                   	push   %eax
f0101d26:	e8 e5 f4 ff ff       	call   f0101210 <page_insert>
f0101d2b:	83 c4 10             	add    $0x10,%esp
f0101d2e:	85 c0                	test   %eax,%eax
f0101d30:	74 19                	je     f0101d4b <mem_init+0xa66>
f0101d32:	68 10 6f 10 f0       	push   $0xf0106f10
f0101d37:	68 68 69 10 f0       	push   $0xf0106968
f0101d3c:	68 05 04 00 00       	push   $0x405
f0101d41:	68 42 69 10 f0       	push   $0xf0106942
f0101d46:	e8 f5 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d4b:	83 ec 04             	sub    $0x4,%esp
f0101d4e:	6a 00                	push   $0x0
f0101d50:	68 00 10 00 00       	push   $0x1000
f0101d55:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101d5b:	e8 ef f2 ff ff       	call   f010104f <pgdir_walk>
f0101d60:	83 c4 10             	add    $0x10,%esp
f0101d63:	f6 00 02             	testb  $0x2,(%eax)
f0101d66:	75 19                	jne    f0101d81 <mem_init+0xa9c>
f0101d68:	68 30 70 10 f0       	push   $0xf0107030
f0101d6d:	68 68 69 10 f0       	push   $0xf0106968
f0101d72:	68 06 04 00 00       	push   $0x406
f0101d77:	68 42 69 10 f0       	push   $0xf0106942
f0101d7c:	e8 bf e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d81:	83 ec 04             	sub    $0x4,%esp
f0101d84:	6a 00                	push   $0x0
f0101d86:	68 00 10 00 00       	push   $0x1000
f0101d8b:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101d91:	e8 b9 f2 ff ff       	call   f010104f <pgdir_walk>
f0101d96:	83 c4 10             	add    $0x10,%esp
f0101d99:	f6 00 04             	testb  $0x4,(%eax)
f0101d9c:	74 19                	je     f0101db7 <mem_init+0xad2>
f0101d9e:	68 64 70 10 f0       	push   $0xf0107064
f0101da3:	68 68 69 10 f0       	push   $0xf0106968
f0101da8:	68 07 04 00 00       	push   $0x407
f0101dad:	68 42 69 10 f0       	push   $0xf0106942
f0101db2:	e8 89 e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101db7:	6a 02                	push   $0x2
f0101db9:	68 00 00 40 00       	push   $0x400000
f0101dbe:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101dc1:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101dc7:	e8 44 f4 ff ff       	call   f0101210 <page_insert>
f0101dcc:	83 c4 10             	add    $0x10,%esp
f0101dcf:	85 c0                	test   %eax,%eax
f0101dd1:	78 19                	js     f0101dec <mem_init+0xb07>
f0101dd3:	68 9c 70 10 f0       	push   $0xf010709c
f0101dd8:	68 68 69 10 f0       	push   $0xf0106968
f0101ddd:	68 0a 04 00 00       	push   $0x40a
f0101de2:	68 42 69 10 f0       	push   $0xf0106942
f0101de7:	e8 54 e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101dec:	6a 02                	push   $0x2
f0101dee:	68 00 10 00 00       	push   $0x1000
f0101df3:	53                   	push   %ebx
f0101df4:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101dfa:	e8 11 f4 ff ff       	call   f0101210 <page_insert>
f0101dff:	83 c4 10             	add    $0x10,%esp
f0101e02:	85 c0                	test   %eax,%eax
f0101e04:	74 19                	je     f0101e1f <mem_init+0xb3a>
f0101e06:	68 d4 70 10 f0       	push   $0xf01070d4
f0101e0b:	68 68 69 10 f0       	push   $0xf0106968
f0101e10:	68 0d 04 00 00       	push   $0x40d
f0101e15:	68 42 69 10 f0       	push   $0xf0106942
f0101e1a:	e8 21 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e1f:	83 ec 04             	sub    $0x4,%esp
f0101e22:	6a 00                	push   $0x0
f0101e24:	68 00 10 00 00       	push   $0x1000
f0101e29:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101e2f:	e8 1b f2 ff ff       	call   f010104f <pgdir_walk>
f0101e34:	83 c4 10             	add    $0x10,%esp
f0101e37:	f6 00 04             	testb  $0x4,(%eax)
f0101e3a:	74 19                	je     f0101e55 <mem_init+0xb70>
f0101e3c:	68 64 70 10 f0       	push   $0xf0107064
f0101e41:	68 68 69 10 f0       	push   $0xf0106968
f0101e46:	68 0e 04 00 00       	push   $0x40e
f0101e4b:	68 42 69 10 f0       	push   $0xf0106942
f0101e50:	e8 eb e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e55:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101e5b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e60:	89 f8                	mov    %edi,%eax
f0101e62:	e8 a2 ec ff ff       	call   f0100b09 <check_va2pa>
f0101e67:	89 c1                	mov    %eax,%ecx
f0101e69:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e6c:	89 d8                	mov    %ebx,%eax
f0101e6e:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101e74:	c1 f8 03             	sar    $0x3,%eax
f0101e77:	c1 e0 0c             	shl    $0xc,%eax
f0101e7a:	39 c1                	cmp    %eax,%ecx
f0101e7c:	74 19                	je     f0101e97 <mem_init+0xbb2>
f0101e7e:	68 10 71 10 f0       	push   $0xf0107110
f0101e83:	68 68 69 10 f0       	push   $0xf0106968
f0101e88:	68 11 04 00 00       	push   $0x411
f0101e8d:	68 42 69 10 f0       	push   $0xf0106942
f0101e92:	e8 a9 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e97:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e9c:	89 f8                	mov    %edi,%eax
f0101e9e:	e8 66 ec ff ff       	call   f0100b09 <check_va2pa>
f0101ea3:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ea6:	74 19                	je     f0101ec1 <mem_init+0xbdc>
f0101ea8:	68 3c 71 10 f0       	push   $0xf010713c
f0101ead:	68 68 69 10 f0       	push   $0xf0106968
f0101eb2:	68 12 04 00 00       	push   $0x412
f0101eb7:	68 42 69 10 f0       	push   $0xf0106942
f0101ebc:	e8 7f e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ec1:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101ec6:	74 19                	je     f0101ee1 <mem_init+0xbfc>
f0101ec8:	68 be 6b 10 f0       	push   $0xf0106bbe
f0101ecd:	68 68 69 10 f0       	push   $0xf0106968
f0101ed2:	68 14 04 00 00       	push   $0x414
f0101ed7:	68 42 69 10 f0       	push   $0xf0106942
f0101edc:	e8 5f e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101ee1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ee6:	74 19                	je     f0101f01 <mem_init+0xc1c>
f0101ee8:	68 cf 6b 10 f0       	push   $0xf0106bcf
f0101eed:	68 68 69 10 f0       	push   $0xf0106968
f0101ef2:	68 15 04 00 00       	push   $0x415
f0101ef7:	68 42 69 10 f0       	push   $0xf0106942
f0101efc:	e8 3f e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f01:	83 ec 0c             	sub    $0xc,%esp
f0101f04:	6a 00                	push   $0x0
f0101f06:	e8 30 f0 ff ff       	call   f0100f3b <page_alloc>
f0101f0b:	83 c4 10             	add    $0x10,%esp
f0101f0e:	85 c0                	test   %eax,%eax
f0101f10:	74 04                	je     f0101f16 <mem_init+0xc31>
f0101f12:	39 c6                	cmp    %eax,%esi
f0101f14:	74 19                	je     f0101f2f <mem_init+0xc4a>
f0101f16:	68 6c 71 10 f0       	push   $0xf010716c
f0101f1b:	68 68 69 10 f0       	push   $0xf0106968
f0101f20:	68 18 04 00 00       	push   $0x418
f0101f25:	68 42 69 10 f0       	push   $0xf0106942
f0101f2a:	e8 11 e1 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f2f:	83 ec 08             	sub    $0x8,%esp
f0101f32:	6a 00                	push   $0x0
f0101f34:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f3a:	e8 8b f2 ff ff       	call   f01011ca <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f3f:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101f45:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f4a:	89 f8                	mov    %edi,%eax
f0101f4c:	e8 b8 eb ff ff       	call   f0100b09 <check_va2pa>
f0101f51:	83 c4 10             	add    $0x10,%esp
f0101f54:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f57:	74 19                	je     f0101f72 <mem_init+0xc8d>
f0101f59:	68 90 71 10 f0       	push   $0xf0107190
f0101f5e:	68 68 69 10 f0       	push   $0xf0106968
f0101f63:	68 1c 04 00 00       	push   $0x41c
f0101f68:	68 42 69 10 f0       	push   $0xf0106942
f0101f6d:	e8 ce e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f72:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f77:	89 f8                	mov    %edi,%eax
f0101f79:	e8 8b eb ff ff       	call   f0100b09 <check_va2pa>
f0101f7e:	89 da                	mov    %ebx,%edx
f0101f80:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101f86:	c1 fa 03             	sar    $0x3,%edx
f0101f89:	c1 e2 0c             	shl    $0xc,%edx
f0101f8c:	39 d0                	cmp    %edx,%eax
f0101f8e:	74 19                	je     f0101fa9 <mem_init+0xcc4>
f0101f90:	68 3c 71 10 f0       	push   $0xf010713c
f0101f95:	68 68 69 10 f0       	push   $0xf0106968
f0101f9a:	68 1d 04 00 00       	push   $0x41d
f0101f9f:	68 42 69 10 f0       	push   $0xf0106942
f0101fa4:	e8 97 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101fa9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fae:	74 19                	je     f0101fc9 <mem_init+0xce4>
f0101fb0:	68 75 6b 10 f0       	push   $0xf0106b75
f0101fb5:	68 68 69 10 f0       	push   $0xf0106968
f0101fba:	68 1e 04 00 00       	push   $0x41e
f0101fbf:	68 42 69 10 f0       	push   $0xf0106942
f0101fc4:	e8 77 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101fc9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fce:	74 19                	je     f0101fe9 <mem_init+0xd04>
f0101fd0:	68 cf 6b 10 f0       	push   $0xf0106bcf
f0101fd5:	68 68 69 10 f0       	push   $0xf0106968
f0101fda:	68 1f 04 00 00       	push   $0x41f
f0101fdf:	68 42 69 10 f0       	push   $0xf0106942
f0101fe4:	e8 57 e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101fe9:	6a 00                	push   $0x0
f0101feb:	68 00 10 00 00       	push   $0x1000
f0101ff0:	53                   	push   %ebx
f0101ff1:	57                   	push   %edi
f0101ff2:	e8 19 f2 ff ff       	call   f0101210 <page_insert>
f0101ff7:	83 c4 10             	add    $0x10,%esp
f0101ffa:	85 c0                	test   %eax,%eax
f0101ffc:	74 19                	je     f0102017 <mem_init+0xd32>
f0101ffe:	68 b4 71 10 f0       	push   $0xf01071b4
f0102003:	68 68 69 10 f0       	push   $0xf0106968
f0102008:	68 22 04 00 00       	push   $0x422
f010200d:	68 42 69 10 f0       	push   $0xf0106942
f0102012:	e8 29 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102017:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010201c:	75 19                	jne    f0102037 <mem_init+0xd52>
f010201e:	68 e0 6b 10 f0       	push   $0xf0106be0
f0102023:	68 68 69 10 f0       	push   $0xf0106968
f0102028:	68 23 04 00 00       	push   $0x423
f010202d:	68 42 69 10 f0       	push   $0xf0106942
f0102032:	e8 09 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102037:	83 3b 00             	cmpl   $0x0,(%ebx)
f010203a:	74 19                	je     f0102055 <mem_init+0xd70>
f010203c:	68 ec 6b 10 f0       	push   $0xf0106bec
f0102041:	68 68 69 10 f0       	push   $0xf0106968
f0102046:	68 24 04 00 00       	push   $0x424
f010204b:	68 42 69 10 f0       	push   $0xf0106942
f0102050:	e8 eb df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102055:	83 ec 08             	sub    $0x8,%esp
f0102058:	68 00 10 00 00       	push   $0x1000
f010205d:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102063:	e8 62 f1 ff ff       	call   f01011ca <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102068:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f010206e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102073:	89 f8                	mov    %edi,%eax
f0102075:	e8 8f ea ff ff       	call   f0100b09 <check_va2pa>
f010207a:	83 c4 10             	add    $0x10,%esp
f010207d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102080:	74 19                	je     f010209b <mem_init+0xdb6>
f0102082:	68 90 71 10 f0       	push   $0xf0107190
f0102087:	68 68 69 10 f0       	push   $0xf0106968
f010208c:	68 28 04 00 00       	push   $0x428
f0102091:	68 42 69 10 f0       	push   $0xf0106942
f0102096:	e8 a5 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010209b:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020a0:	89 f8                	mov    %edi,%eax
f01020a2:	e8 62 ea ff ff       	call   f0100b09 <check_va2pa>
f01020a7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020aa:	74 19                	je     f01020c5 <mem_init+0xde0>
f01020ac:	68 ec 71 10 f0       	push   $0xf01071ec
f01020b1:	68 68 69 10 f0       	push   $0xf0106968
f01020b6:	68 29 04 00 00       	push   $0x429
f01020bb:	68 42 69 10 f0       	push   $0xf0106942
f01020c0:	e8 7b df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01020c5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020ca:	74 19                	je     f01020e5 <mem_init+0xe00>
f01020cc:	68 01 6c 10 f0       	push   $0xf0106c01
f01020d1:	68 68 69 10 f0       	push   $0xf0106968
f01020d6:	68 2a 04 00 00       	push   $0x42a
f01020db:	68 42 69 10 f0       	push   $0xf0106942
f01020e0:	e8 5b df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020e5:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020ea:	74 19                	je     f0102105 <mem_init+0xe20>
f01020ec:	68 cf 6b 10 f0       	push   $0xf0106bcf
f01020f1:	68 68 69 10 f0       	push   $0xf0106968
f01020f6:	68 2b 04 00 00       	push   $0x42b
f01020fb:	68 42 69 10 f0       	push   $0xf0106942
f0102100:	e8 3b df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102105:	83 ec 0c             	sub    $0xc,%esp
f0102108:	6a 00                	push   $0x0
f010210a:	e8 2c ee ff ff       	call   f0100f3b <page_alloc>
f010210f:	83 c4 10             	add    $0x10,%esp
f0102112:	39 c3                	cmp    %eax,%ebx
f0102114:	75 04                	jne    f010211a <mem_init+0xe35>
f0102116:	85 c0                	test   %eax,%eax
f0102118:	75 19                	jne    f0102133 <mem_init+0xe4e>
f010211a:	68 14 72 10 f0       	push   $0xf0107214
f010211f:	68 68 69 10 f0       	push   $0xf0106968
f0102124:	68 2e 04 00 00       	push   $0x42e
f0102129:	68 42 69 10 f0       	push   $0xf0106942
f010212e:	e8 0d df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102133:	83 ec 0c             	sub    $0xc,%esp
f0102136:	6a 00                	push   $0x0
f0102138:	e8 fe ed ff ff       	call   f0100f3b <page_alloc>
f010213d:	83 c4 10             	add    $0x10,%esp
f0102140:	85 c0                	test   %eax,%eax
f0102142:	74 19                	je     f010215d <mem_init+0xe78>
f0102144:	68 23 6b 10 f0       	push   $0xf0106b23
f0102149:	68 68 69 10 f0       	push   $0xf0106968
f010214e:	68 31 04 00 00       	push   $0x431
f0102153:	68 42 69 10 f0       	push   $0xf0106942
f0102158:	e8 e3 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010215d:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102163:	8b 11                	mov    (%ecx),%edx
f0102165:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010216b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010216e:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102174:	c1 f8 03             	sar    $0x3,%eax
f0102177:	c1 e0 0c             	shl    $0xc,%eax
f010217a:	39 c2                	cmp    %eax,%edx
f010217c:	74 19                	je     f0102197 <mem_init+0xeb2>
f010217e:	68 b8 6e 10 f0       	push   $0xf0106eb8
f0102183:	68 68 69 10 f0       	push   $0xf0106968
f0102188:	68 34 04 00 00       	push   $0x434
f010218d:	68 42 69 10 f0       	push   $0xf0106942
f0102192:	e8 a9 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102197:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010219d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021a0:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021a5:	74 19                	je     f01021c0 <mem_init+0xedb>
f01021a7:	68 86 6b 10 f0       	push   $0xf0106b86
f01021ac:	68 68 69 10 f0       	push   $0xf0106968
f01021b1:	68 36 04 00 00       	push   $0x436
f01021b6:	68 42 69 10 f0       	push   $0xf0106942
f01021bb:	e8 80 de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01021c0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021c3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021c9:	83 ec 0c             	sub    $0xc,%esp
f01021cc:	50                   	push   %eax
f01021cd:	e8 00 ee ff ff       	call   f0100fd2 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01021d2:	83 c4 0c             	add    $0xc,%esp
f01021d5:	6a 01                	push   $0x1
f01021d7:	68 00 10 40 00       	push   $0x401000
f01021dc:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01021e2:	e8 68 ee ff ff       	call   f010104f <pgdir_walk>
f01021e7:	89 c7                	mov    %eax,%edi
f01021e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01021ec:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01021f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021f4:	8b 40 04             	mov    0x4(%eax),%eax
f01021f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021fc:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f0102202:	89 c2                	mov    %eax,%edx
f0102204:	c1 ea 0c             	shr    $0xc,%edx
f0102207:	83 c4 10             	add    $0x10,%esp
f010220a:	39 ca                	cmp    %ecx,%edx
f010220c:	72 15                	jb     f0102223 <mem_init+0xf3e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010220e:	50                   	push   %eax
f010220f:	68 c4 63 10 f0       	push   $0xf01063c4
f0102214:	68 3d 04 00 00       	push   $0x43d
f0102219:	68 42 69 10 f0       	push   $0xf0106942
f010221e:	e8 1d de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102223:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102228:	39 c7                	cmp    %eax,%edi
f010222a:	74 19                	je     f0102245 <mem_init+0xf60>
f010222c:	68 12 6c 10 f0       	push   $0xf0106c12
f0102231:	68 68 69 10 f0       	push   $0xf0106968
f0102236:	68 3e 04 00 00       	push   $0x43e
f010223b:	68 42 69 10 f0       	push   $0xf0106942
f0102240:	e8 fb dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102245:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102248:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010224f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102252:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102258:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010225e:	c1 f8 03             	sar    $0x3,%eax
f0102261:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102264:	89 c2                	mov    %eax,%edx
f0102266:	c1 ea 0c             	shr    $0xc,%edx
f0102269:	39 d1                	cmp    %edx,%ecx
f010226b:	77 12                	ja     f010227f <mem_init+0xf9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010226d:	50                   	push   %eax
f010226e:	68 c4 63 10 f0       	push   $0xf01063c4
f0102273:	6a 58                	push   $0x58
f0102275:	68 4e 69 10 f0       	push   $0xf010694e
f010227a:	e8 c1 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010227f:	83 ec 04             	sub    $0x4,%esp
f0102282:	68 00 10 00 00       	push   $0x1000
f0102287:	68 ff 00 00 00       	push   $0xff
f010228c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102291:	50                   	push   %eax
f0102292:	e8 55 34 00 00       	call   f01056ec <memset>
	page_free(pp0);
f0102297:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010229a:	89 3c 24             	mov    %edi,(%esp)
f010229d:	e8 30 ed ff ff       	call   f0100fd2 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01022a2:	83 c4 0c             	add    $0xc,%esp
f01022a5:	6a 01                	push   $0x1
f01022a7:	6a 00                	push   $0x0
f01022a9:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01022af:	e8 9b ed ff ff       	call   f010104f <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022b4:	89 fa                	mov    %edi,%edx
f01022b6:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f01022bc:	c1 fa 03             	sar    $0x3,%edx
f01022bf:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022c2:	89 d0                	mov    %edx,%eax
f01022c4:	c1 e8 0c             	shr    $0xc,%eax
f01022c7:	83 c4 10             	add    $0x10,%esp
f01022ca:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01022d0:	72 12                	jb     f01022e4 <mem_init+0xfff>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022d2:	52                   	push   %edx
f01022d3:	68 c4 63 10 f0       	push   $0xf01063c4
f01022d8:	6a 58                	push   $0x58
f01022da:	68 4e 69 10 f0       	push   $0xf010694e
f01022df:	e8 5c dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01022e4:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01022ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01022ed:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01022f3:	f6 00 01             	testb  $0x1,(%eax)
f01022f6:	74 19                	je     f0102311 <mem_init+0x102c>
f01022f8:	68 2a 6c 10 f0       	push   $0xf0106c2a
f01022fd:	68 68 69 10 f0       	push   $0xf0106968
f0102302:	68 48 04 00 00       	push   $0x448
f0102307:	68 42 69 10 f0       	push   $0xf0106942
f010230c:	e8 2f dd ff ff       	call   f0100040 <_panic>
f0102311:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102314:	39 d0                	cmp    %edx,%eax
f0102316:	75 db                	jne    f01022f3 <mem_init+0x100e>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102318:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010231d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102323:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102326:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010232c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010232f:	89 0d 40 f2 22 f0    	mov    %ecx,0xf022f240

	// free the pages we took
	page_free(pp0);
f0102335:	83 ec 0c             	sub    $0xc,%esp
f0102338:	50                   	push   %eax
f0102339:	e8 94 ec ff ff       	call   f0100fd2 <page_free>
	page_free(pp1);
f010233e:	89 1c 24             	mov    %ebx,(%esp)
f0102341:	e8 8c ec ff ff       	call   f0100fd2 <page_free>
	page_free(pp2);
f0102346:	89 34 24             	mov    %esi,(%esp)
f0102349:	e8 84 ec ff ff       	call   f0100fd2 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010234e:	83 c4 08             	add    $0x8,%esp
f0102351:	68 01 10 00 00       	push   $0x1001
f0102356:	6a 00                	push   $0x0
f0102358:	e8 25 ef ff ff       	call   f0101282 <mmio_map_region>
f010235d:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010235f:	83 c4 08             	add    $0x8,%esp
f0102362:	68 00 10 00 00       	push   $0x1000
f0102367:	6a 00                	push   $0x0
f0102369:	e8 14 ef ff ff       	call   f0101282 <mmio_map_region>
f010236e:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102370:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102376:	83 c4 10             	add    $0x10,%esp
f0102379:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010237f:	76 07                	jbe    f0102388 <mem_init+0x10a3>
f0102381:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102386:	76 19                	jbe    f01023a1 <mem_init+0x10bc>
f0102388:	68 38 72 10 f0       	push   $0xf0107238
f010238d:	68 68 69 10 f0       	push   $0xf0106968
f0102392:	68 58 04 00 00       	push   $0x458
f0102397:	68 42 69 10 f0       	push   $0xf0106942
f010239c:	e8 9f dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01023a1:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01023a7:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01023ad:	77 08                	ja     f01023b7 <mem_init+0x10d2>
f01023af:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01023b5:	77 19                	ja     f01023d0 <mem_init+0x10eb>
f01023b7:	68 60 72 10 f0       	push   $0xf0107260
f01023bc:	68 68 69 10 f0       	push   $0xf0106968
f01023c1:	68 59 04 00 00       	push   $0x459
f01023c6:	68 42 69 10 f0       	push   $0xf0106942
f01023cb:	e8 70 dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01023d0:	89 da                	mov    %ebx,%edx
f01023d2:	09 f2                	or     %esi,%edx
f01023d4:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01023da:	74 19                	je     f01023f5 <mem_init+0x1110>
f01023dc:	68 88 72 10 f0       	push   $0xf0107288
f01023e1:	68 68 69 10 f0       	push   $0xf0106968
f01023e6:	68 5b 04 00 00       	push   $0x45b
f01023eb:	68 42 69 10 f0       	push   $0xf0106942
f01023f0:	e8 4b dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01023f5:	39 c6                	cmp    %eax,%esi
f01023f7:	73 19                	jae    f0102412 <mem_init+0x112d>
f01023f9:	68 41 6c 10 f0       	push   $0xf0106c41
f01023fe:	68 68 69 10 f0       	push   $0xf0106968
f0102403:	68 5d 04 00 00       	push   $0x45d
f0102408:	68 42 69 10 f0       	push   $0xf0106942
f010240d:	e8 2e dc ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102412:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0102418:	89 da                	mov    %ebx,%edx
f010241a:	89 f8                	mov    %edi,%eax
f010241c:	e8 e8 e6 ff ff       	call   f0100b09 <check_va2pa>
f0102421:	85 c0                	test   %eax,%eax
f0102423:	74 19                	je     f010243e <mem_init+0x1159>
f0102425:	68 b0 72 10 f0       	push   $0xf01072b0
f010242a:	68 68 69 10 f0       	push   $0xf0106968
f010242f:	68 5f 04 00 00       	push   $0x45f
f0102434:	68 42 69 10 f0       	push   $0xf0106942
f0102439:	e8 02 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010243e:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102444:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102447:	89 c2                	mov    %eax,%edx
f0102449:	89 f8                	mov    %edi,%eax
f010244b:	e8 b9 e6 ff ff       	call   f0100b09 <check_va2pa>
f0102450:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102455:	74 19                	je     f0102470 <mem_init+0x118b>
f0102457:	68 d4 72 10 f0       	push   $0xf01072d4
f010245c:	68 68 69 10 f0       	push   $0xf0106968
f0102461:	68 60 04 00 00       	push   $0x460
f0102466:	68 42 69 10 f0       	push   $0xf0106942
f010246b:	e8 d0 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102470:	89 f2                	mov    %esi,%edx
f0102472:	89 f8                	mov    %edi,%eax
f0102474:	e8 90 e6 ff ff       	call   f0100b09 <check_va2pa>
f0102479:	85 c0                	test   %eax,%eax
f010247b:	74 19                	je     f0102496 <mem_init+0x11b1>
f010247d:	68 04 73 10 f0       	push   $0xf0107304
f0102482:	68 68 69 10 f0       	push   $0xf0106968
f0102487:	68 61 04 00 00       	push   $0x461
f010248c:	68 42 69 10 f0       	push   $0xf0106942
f0102491:	e8 aa db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102496:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010249c:	89 f8                	mov    %edi,%eax
f010249e:	e8 66 e6 ff ff       	call   f0100b09 <check_va2pa>
f01024a3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024a6:	74 19                	je     f01024c1 <mem_init+0x11dc>
f01024a8:	68 28 73 10 f0       	push   $0xf0107328
f01024ad:	68 68 69 10 f0       	push   $0xf0106968
f01024b2:	68 62 04 00 00       	push   $0x462
f01024b7:	68 42 69 10 f0       	push   $0xf0106942
f01024bc:	e8 7f db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024c1:	83 ec 04             	sub    $0x4,%esp
f01024c4:	6a 00                	push   $0x0
f01024c6:	53                   	push   %ebx
f01024c7:	57                   	push   %edi
f01024c8:	e8 82 eb ff ff       	call   f010104f <pgdir_walk>
f01024cd:	83 c4 10             	add    $0x10,%esp
f01024d0:	f6 00 1a             	testb  $0x1a,(%eax)
f01024d3:	75 19                	jne    f01024ee <mem_init+0x1209>
f01024d5:	68 54 73 10 f0       	push   $0xf0107354
f01024da:	68 68 69 10 f0       	push   $0xf0106968
f01024df:	68 64 04 00 00       	push   $0x464
f01024e4:	68 42 69 10 f0       	push   $0xf0106942
f01024e9:	e8 52 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01024ee:	83 ec 04             	sub    $0x4,%esp
f01024f1:	6a 00                	push   $0x0
f01024f3:	53                   	push   %ebx
f01024f4:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01024fa:	e8 50 eb ff ff       	call   f010104f <pgdir_walk>
f01024ff:	8b 00                	mov    (%eax),%eax
f0102501:	83 c4 10             	add    $0x10,%esp
f0102504:	83 e0 04             	and    $0x4,%eax
f0102507:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010250a:	74 19                	je     f0102525 <mem_init+0x1240>
f010250c:	68 98 73 10 f0       	push   $0xf0107398
f0102511:	68 68 69 10 f0       	push   $0xf0106968
f0102516:	68 65 04 00 00       	push   $0x465
f010251b:	68 42 69 10 f0       	push   $0xf0106942
f0102520:	e8 1b db ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102525:	83 ec 04             	sub    $0x4,%esp
f0102528:	6a 00                	push   $0x0
f010252a:	53                   	push   %ebx
f010252b:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102531:	e8 19 eb ff ff       	call   f010104f <pgdir_walk>
f0102536:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010253c:	83 c4 0c             	add    $0xc,%esp
f010253f:	6a 00                	push   $0x0
f0102541:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102544:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010254a:	e8 00 eb ff ff       	call   f010104f <pgdir_walk>
f010254f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102555:	83 c4 0c             	add    $0xc,%esp
f0102558:	6a 00                	push   $0x0
f010255a:	56                   	push   %esi
f010255b:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102561:	e8 e9 ea ff ff       	call   f010104f <pgdir_walk>
f0102566:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010256c:	c7 04 24 53 6c 10 f0 	movl   $0xf0106c53,(%esp)
f0102573:	e8 90 11 00 00       	call   f0103708 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0102578:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010257d:	83 c4 10             	add    $0x10,%esp
f0102580:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102585:	77 15                	ja     f010259c <mem_init+0x12b7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102587:	50                   	push   %eax
f0102588:	68 e8 63 10 f0       	push   $0xf01063e8
f010258d:	68 c6 00 00 00       	push   $0xc6
f0102592:	68 42 69 10 f0       	push   $0xf0106942
f0102597:	e8 a4 da ff ff       	call   f0100040 <_panic>
f010259c:	83 ec 08             	sub    $0x8,%esp
f010259f:	6a 05                	push   $0x5
f01025a1:	05 00 00 00 10       	add    $0x10000000,%eax
f01025a6:	50                   	push   %eax
f01025a7:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01025ac:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025b1:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01025b6:	e8 27 eb ff ff       	call   f01010e2 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f01025bb:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025c0:	83 c4 10             	add    $0x10,%esp
f01025c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025c8:	77 15                	ja     f01025df <mem_init+0x12fa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025ca:	50                   	push   %eax
f01025cb:	68 e8 63 10 f0       	push   $0xf01063e8
f01025d0:	68 d0 00 00 00       	push   $0xd0
f01025d5:	68 42 69 10 f0       	push   $0xf0106942
f01025da:	e8 61 da ff ff       	call   f0100040 <_panic>
f01025df:	83 ec 08             	sub    $0x8,%esp
f01025e2:	6a 05                	push   $0x5
f01025e4:	05 00 00 00 10       	add    $0x10000000,%eax
f01025e9:	50                   	push   %eax
f01025ea:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01025ef:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01025f4:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01025f9:	e8 e4 ea ff ff       	call   f01010e2 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025fe:	83 c4 10             	add    $0x10,%esp
f0102601:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102606:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010260b:	77 15                	ja     f0102622 <mem_init+0x133d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010260d:	50                   	push   %eax
f010260e:	68 e8 63 10 f0       	push   $0xf01063e8
f0102613:	68 df 00 00 00       	push   $0xdf
f0102618:	68 42 69 10 f0       	push   $0xf0106942
f010261d:	e8 1e da ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P );
f0102622:	83 ec 08             	sub    $0x8,%esp
f0102625:	6a 03                	push   $0x3
f0102627:	68 00 60 11 00       	push   $0x116000
f010262c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102631:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102636:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010263b:	e8 a2 ea ff ff       	call   f01010e2 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xFFFFFFFF-KERNBASE, 0, PTE_W | PTE_P);
f0102640:	83 c4 08             	add    $0x8,%esp
f0102643:	6a 03                	push   $0x3
f0102645:	6a 00                	push   $0x0
f0102647:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010264c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102651:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102656:	e8 87 ea ff ff       	call   f01010e2 <boot_map_region>
f010265b:	c7 45 c4 00 10 23 f0 	movl   $0xf0231000,-0x3c(%ebp)
f0102662:	83 c4 10             	add    $0x10,%esp
f0102665:	bb 00 10 23 f0       	mov    $0xf0231000,%ebx
f010266a:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010266f:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102675:	77 15                	ja     f010268c <mem_init+0x13a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102677:	53                   	push   %ebx
f0102678:	68 e8 63 10 f0       	push   $0xf01063e8
f010267d:	68 25 01 00 00       	push   $0x125
f0102682:	68 42 69 10 f0       	push   $0xf0106942
f0102687:	e8 b4 d9 ff ff       	call   f0100040 <_panic>

	for (cpuno = 0; cpuno < NCPU; cpuno++)
	{
		uintptr_t kstktop_i = (uintptr_t) (KSTACKTOP - cpuno * (KSTKSIZE + KSTKGAP));

		boot_map_region(kern_pgdir, kstktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[cpuno]), PTE_W | PTE_P );
f010268c:	83 ec 08             	sub    $0x8,%esp
f010268f:	6a 03                	push   $0x3
f0102691:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102697:	50                   	push   %eax
f0102698:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010269d:	89 f2                	mov    %esi,%edx
f010269f:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01026a4:	e8 39 ea ff ff       	call   f01010e2 <boot_map_region>
f01026a9:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01026af:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//
	// LAB 4: Your code here:

	uint32_t cpuno;

	for (cpuno = 0; cpuno < NCPU; cpuno++)
f01026b5:	83 c4 10             	add    $0x10,%esp
f01026b8:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
f01026bd:	39 d8                	cmp    %ebx,%eax
f01026bf:	75 ae                	jne    f010266f <mem_init+0x138a>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026c1:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026c7:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f01026cc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026cf:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01026d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026de:	8b 35 90 fe 22 f0    	mov    0xf022fe90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026e4:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01026e7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01026ec:	eb 55                	jmp    f0102743 <mem_init+0x145e>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026ee:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01026f4:	89 f8                	mov    %edi,%eax
f01026f6:	e8 0e e4 ff ff       	call   f0100b09 <check_va2pa>
f01026fb:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102702:	77 15                	ja     f0102719 <mem_init+0x1434>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102704:	56                   	push   %esi
f0102705:	68 e8 63 10 f0       	push   $0xf01063e8
f010270a:	68 7d 03 00 00       	push   $0x37d
f010270f:	68 42 69 10 f0       	push   $0xf0106942
f0102714:	e8 27 d9 ff ff       	call   f0100040 <_panic>
f0102719:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102720:	39 c2                	cmp    %eax,%edx
f0102722:	74 19                	je     f010273d <mem_init+0x1458>
f0102724:	68 cc 73 10 f0       	push   $0xf01073cc
f0102729:	68 68 69 10 f0       	push   $0xf0106968
f010272e:	68 7d 03 00 00       	push   $0x37d
f0102733:	68 42 69 10 f0       	push   $0xf0106942
f0102738:	e8 03 d9 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010273d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102743:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102746:	77 a6                	ja     f01026ee <mem_init+0x1409>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102748:	8b 35 48 f2 22 f0    	mov    0xf022f248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010274e:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102751:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102756:	89 da                	mov    %ebx,%edx
f0102758:	89 f8                	mov    %edi,%eax
f010275a:	e8 aa e3 ff ff       	call   f0100b09 <check_va2pa>
f010275f:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102766:	77 15                	ja     f010277d <mem_init+0x1498>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102768:	56                   	push   %esi
f0102769:	68 e8 63 10 f0       	push   $0xf01063e8
f010276e:	68 82 03 00 00       	push   $0x382
f0102773:	68 42 69 10 f0       	push   $0xf0106942
f0102778:	e8 c3 d8 ff ff       	call   f0100040 <_panic>
f010277d:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f0102784:	39 d0                	cmp    %edx,%eax
f0102786:	74 19                	je     f01027a1 <mem_init+0x14bc>
f0102788:	68 00 74 10 f0       	push   $0xf0107400
f010278d:	68 68 69 10 f0       	push   $0xf0106968
f0102792:	68 82 03 00 00       	push   $0x382
f0102797:	68 42 69 10 f0       	push   $0xf0106942
f010279c:	e8 9f d8 ff ff       	call   f0100040 <_panic>
f01027a1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027a7:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01027ad:	75 a7                	jne    f0102756 <mem_init+0x1471>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027af:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01027b2:	c1 e6 0c             	shl    $0xc,%esi
f01027b5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027ba:	eb 30                	jmp    f01027ec <mem_init+0x1507>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027bc:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01027c2:	89 f8                	mov    %edi,%eax
f01027c4:	e8 40 e3 ff ff       	call   f0100b09 <check_va2pa>
f01027c9:	39 c3                	cmp    %eax,%ebx
f01027cb:	74 19                	je     f01027e6 <mem_init+0x1501>
f01027cd:	68 34 74 10 f0       	push   $0xf0107434
f01027d2:	68 68 69 10 f0       	push   $0xf0106968
f01027d7:	68 86 03 00 00       	push   $0x386
f01027dc:	68 42 69 10 f0       	push   $0xf0106942
f01027e1:	e8 5a d8 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027e6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027ec:	39 f3                	cmp    %esi,%ebx
f01027ee:	72 cc                	jb     f01027bc <mem_init+0x14d7>
f01027f0:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01027f5:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01027f8:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01027fb:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01027fe:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102804:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102807:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102809:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010280c:	05 00 80 00 20       	add    $0x20008000,%eax
f0102811:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102814:	89 da                	mov    %ebx,%edx
f0102816:	89 f8                	mov    %edi,%eax
f0102818:	e8 ec e2 ff ff       	call   f0100b09 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010281d:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102823:	77 15                	ja     f010283a <mem_init+0x1555>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102825:	56                   	push   %esi
f0102826:	68 e8 63 10 f0       	push   $0xf01063e8
f010282b:	68 8e 03 00 00       	push   $0x38e
f0102830:	68 42 69 10 f0       	push   $0xf0106942
f0102835:	e8 06 d8 ff ff       	call   f0100040 <_panic>
f010283a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010283d:	8d 94 0b 00 10 23 f0 	lea    -0xfdcf000(%ebx,%ecx,1),%edx
f0102844:	39 d0                	cmp    %edx,%eax
f0102846:	74 19                	je     f0102861 <mem_init+0x157c>
f0102848:	68 5c 74 10 f0       	push   $0xf010745c
f010284d:	68 68 69 10 f0       	push   $0xf0106968
f0102852:	68 8e 03 00 00       	push   $0x38e
f0102857:	68 42 69 10 f0       	push   $0xf0106942
f010285c:	e8 df d7 ff ff       	call   f0100040 <_panic>
f0102861:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102867:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f010286a:	75 a8                	jne    f0102814 <mem_init+0x152f>
f010286c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010286f:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102875:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102878:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010287a:	89 da                	mov    %ebx,%edx
f010287c:	89 f8                	mov    %edi,%eax
f010287e:	e8 86 e2 ff ff       	call   f0100b09 <check_va2pa>
f0102883:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102886:	74 19                	je     f01028a1 <mem_init+0x15bc>
f0102888:	68 a4 74 10 f0       	push   $0xf01074a4
f010288d:	68 68 69 10 f0       	push   $0xf0106968
f0102892:	68 90 03 00 00       	push   $0x390
f0102897:	68 42 69 10 f0       	push   $0xf0106942
f010289c:	e8 9f d7 ff ff       	call   f0100040 <_panic>
f01028a1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01028a7:	39 f3                	cmp    %esi,%ebx
f01028a9:	75 cf                	jne    f010287a <mem_init+0x1595>
f01028ab:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01028ae:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01028b5:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01028bc:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01028c2:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
f01028c7:	39 f0                	cmp    %esi,%eax
f01028c9:	0f 85 2c ff ff ff    	jne    f01027fb <mem_init+0x1516>
f01028cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01028d4:	eb 2a                	jmp    f0102900 <mem_init+0x161b>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01028d6:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01028dc:	83 fa 04             	cmp    $0x4,%edx
f01028df:	77 1f                	ja     f0102900 <mem_init+0x161b>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01028e1:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01028e5:	75 7e                	jne    f0102965 <mem_init+0x1680>
f01028e7:	68 6c 6c 10 f0       	push   $0xf0106c6c
f01028ec:	68 68 69 10 f0       	push   $0xf0106968
f01028f1:	68 9b 03 00 00       	push   $0x39b
f01028f6:	68 42 69 10 f0       	push   $0xf0106942
f01028fb:	e8 40 d7 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102900:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102905:	76 3f                	jbe    f0102946 <mem_init+0x1661>
				assert(pgdir[i] & PTE_P);
f0102907:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010290a:	f6 c2 01             	test   $0x1,%dl
f010290d:	75 19                	jne    f0102928 <mem_init+0x1643>
f010290f:	68 6c 6c 10 f0       	push   $0xf0106c6c
f0102914:	68 68 69 10 f0       	push   $0xf0106968
f0102919:	68 9f 03 00 00       	push   $0x39f
f010291e:	68 42 69 10 f0       	push   $0xf0106942
f0102923:	e8 18 d7 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102928:	f6 c2 02             	test   $0x2,%dl
f010292b:	75 38                	jne    f0102965 <mem_init+0x1680>
f010292d:	68 7d 6c 10 f0       	push   $0xf0106c7d
f0102932:	68 68 69 10 f0       	push   $0xf0106968
f0102937:	68 a0 03 00 00       	push   $0x3a0
f010293c:	68 42 69 10 f0       	push   $0xf0106942
f0102941:	e8 fa d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102946:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f010294a:	74 19                	je     f0102965 <mem_init+0x1680>
f010294c:	68 8e 6c 10 f0       	push   $0xf0106c8e
f0102951:	68 68 69 10 f0       	push   $0xf0106968
f0102956:	68 a2 03 00 00       	push   $0x3a2
f010295b:	68 42 69 10 f0       	push   $0xf0106942
f0102960:	e8 db d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102965:	83 c0 01             	add    $0x1,%eax
f0102968:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010296d:	0f 86 63 ff ff ff    	jbe    f01028d6 <mem_init+0x15f1>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102973:	83 ec 0c             	sub    $0xc,%esp
f0102976:	68 c8 74 10 f0       	push   $0xf01074c8
f010297b:	e8 88 0d 00 00       	call   f0103708 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102980:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102985:	83 c4 10             	add    $0x10,%esp
f0102988:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010298d:	77 15                	ja     f01029a4 <mem_init+0x16bf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010298f:	50                   	push   %eax
f0102990:	68 e8 63 10 f0       	push   $0xf01063e8
f0102995:	68 f9 00 00 00       	push   $0xf9
f010299a:	68 42 69 10 f0       	push   $0xf0106942
f010299f:	e8 9c d6 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01029a4:	05 00 00 00 10       	add    $0x10000000,%eax
f01029a9:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01029b1:	e8 b7 e1 ff ff       	call   f0100b6d <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01029b6:	0f 20 c0             	mov    %cr0,%eax
f01029b9:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01029bc:	0d 23 00 05 80       	or     $0x80050023,%eax
f01029c1:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029c4:	83 ec 0c             	sub    $0xc,%esp
f01029c7:	6a 00                	push   $0x0
f01029c9:	e8 6d e5 ff ff       	call   f0100f3b <page_alloc>
f01029ce:	89 c3                	mov    %eax,%ebx
f01029d0:	83 c4 10             	add    $0x10,%esp
f01029d3:	85 c0                	test   %eax,%eax
f01029d5:	75 19                	jne    f01029f0 <mem_init+0x170b>
f01029d7:	68 78 6a 10 f0       	push   $0xf0106a78
f01029dc:	68 68 69 10 f0       	push   $0xf0106968
f01029e1:	68 7a 04 00 00       	push   $0x47a
f01029e6:	68 42 69 10 f0       	push   $0xf0106942
f01029eb:	e8 50 d6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01029f0:	83 ec 0c             	sub    $0xc,%esp
f01029f3:	6a 00                	push   $0x0
f01029f5:	e8 41 e5 ff ff       	call   f0100f3b <page_alloc>
f01029fa:	89 c7                	mov    %eax,%edi
f01029fc:	83 c4 10             	add    $0x10,%esp
f01029ff:	85 c0                	test   %eax,%eax
f0102a01:	75 19                	jne    f0102a1c <mem_init+0x1737>
f0102a03:	68 8e 6a 10 f0       	push   $0xf0106a8e
f0102a08:	68 68 69 10 f0       	push   $0xf0106968
f0102a0d:	68 7b 04 00 00       	push   $0x47b
f0102a12:	68 42 69 10 f0       	push   $0xf0106942
f0102a17:	e8 24 d6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a1c:	83 ec 0c             	sub    $0xc,%esp
f0102a1f:	6a 00                	push   $0x0
f0102a21:	e8 15 e5 ff ff       	call   f0100f3b <page_alloc>
f0102a26:	89 c6                	mov    %eax,%esi
f0102a28:	83 c4 10             	add    $0x10,%esp
f0102a2b:	85 c0                	test   %eax,%eax
f0102a2d:	75 19                	jne    f0102a48 <mem_init+0x1763>
f0102a2f:	68 a4 6a 10 f0       	push   $0xf0106aa4
f0102a34:	68 68 69 10 f0       	push   $0xf0106968
f0102a39:	68 7c 04 00 00       	push   $0x47c
f0102a3e:	68 42 69 10 f0       	push   $0xf0106942
f0102a43:	e8 f8 d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102a48:	83 ec 0c             	sub    $0xc,%esp
f0102a4b:	53                   	push   %ebx
f0102a4c:	e8 81 e5 ff ff       	call   f0100fd2 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a51:	89 f8                	mov    %edi,%eax
f0102a53:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102a59:	c1 f8 03             	sar    $0x3,%eax
f0102a5c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a5f:	89 c2                	mov    %eax,%edx
f0102a61:	c1 ea 0c             	shr    $0xc,%edx
f0102a64:	83 c4 10             	add    $0x10,%esp
f0102a67:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102a6d:	72 12                	jb     f0102a81 <mem_init+0x179c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a6f:	50                   	push   %eax
f0102a70:	68 c4 63 10 f0       	push   $0xf01063c4
f0102a75:	6a 58                	push   $0x58
f0102a77:	68 4e 69 10 f0       	push   $0xf010694e
f0102a7c:	e8 bf d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a81:	83 ec 04             	sub    $0x4,%esp
f0102a84:	68 00 10 00 00       	push   $0x1000
f0102a89:	6a 01                	push   $0x1
f0102a8b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a90:	50                   	push   %eax
f0102a91:	e8 56 2c 00 00       	call   f01056ec <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a96:	89 f0                	mov    %esi,%eax
f0102a98:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102a9e:	c1 f8 03             	sar    $0x3,%eax
f0102aa1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102aa4:	89 c2                	mov    %eax,%edx
f0102aa6:	c1 ea 0c             	shr    $0xc,%edx
f0102aa9:	83 c4 10             	add    $0x10,%esp
f0102aac:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102ab2:	72 12                	jb     f0102ac6 <mem_init+0x17e1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ab4:	50                   	push   %eax
f0102ab5:	68 c4 63 10 f0       	push   $0xf01063c4
f0102aba:	6a 58                	push   $0x58
f0102abc:	68 4e 69 10 f0       	push   $0xf010694e
f0102ac1:	e8 7a d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ac6:	83 ec 04             	sub    $0x4,%esp
f0102ac9:	68 00 10 00 00       	push   $0x1000
f0102ace:	6a 02                	push   $0x2
f0102ad0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102ad5:	50                   	push   %eax
f0102ad6:	e8 11 2c 00 00       	call   f01056ec <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102adb:	6a 02                	push   $0x2
f0102add:	68 00 10 00 00       	push   $0x1000
f0102ae2:	57                   	push   %edi
f0102ae3:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102ae9:	e8 22 e7 ff ff       	call   f0101210 <page_insert>
	assert(pp1->pp_ref == 1);
f0102aee:	83 c4 20             	add    $0x20,%esp
f0102af1:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102af6:	74 19                	je     f0102b11 <mem_init+0x182c>
f0102af8:	68 75 6b 10 f0       	push   $0xf0106b75
f0102afd:	68 68 69 10 f0       	push   $0xf0106968
f0102b02:	68 81 04 00 00       	push   $0x481
f0102b07:	68 42 69 10 f0       	push   $0xf0106942
f0102b0c:	e8 2f d5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b11:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b18:	01 01 01 
f0102b1b:	74 19                	je     f0102b36 <mem_init+0x1851>
f0102b1d:	68 e8 74 10 f0       	push   $0xf01074e8
f0102b22:	68 68 69 10 f0       	push   $0xf0106968
f0102b27:	68 82 04 00 00       	push   $0x482
f0102b2c:	68 42 69 10 f0       	push   $0xf0106942
f0102b31:	e8 0a d5 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b36:	6a 02                	push   $0x2
f0102b38:	68 00 10 00 00       	push   $0x1000
f0102b3d:	56                   	push   %esi
f0102b3e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102b44:	e8 c7 e6 ff ff       	call   f0101210 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b49:	83 c4 10             	add    $0x10,%esp
f0102b4c:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b53:	02 02 02 
f0102b56:	74 19                	je     f0102b71 <mem_init+0x188c>
f0102b58:	68 0c 75 10 f0       	push   $0xf010750c
f0102b5d:	68 68 69 10 f0       	push   $0xf0106968
f0102b62:	68 84 04 00 00       	push   $0x484
f0102b67:	68 42 69 10 f0       	push   $0xf0106942
f0102b6c:	e8 cf d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102b71:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b76:	74 19                	je     f0102b91 <mem_init+0x18ac>
f0102b78:	68 97 6b 10 f0       	push   $0xf0106b97
f0102b7d:	68 68 69 10 f0       	push   $0xf0106968
f0102b82:	68 85 04 00 00       	push   $0x485
f0102b87:	68 42 69 10 f0       	push   $0xf0106942
f0102b8c:	e8 af d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102b91:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b96:	74 19                	je     f0102bb1 <mem_init+0x18cc>
f0102b98:	68 01 6c 10 f0       	push   $0xf0106c01
f0102b9d:	68 68 69 10 f0       	push   $0xf0106968
f0102ba2:	68 86 04 00 00       	push   $0x486
f0102ba7:	68 42 69 10 f0       	push   $0xf0106942
f0102bac:	e8 8f d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bb1:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bb8:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bbb:	89 f0                	mov    %esi,%eax
f0102bbd:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102bc3:	c1 f8 03             	sar    $0x3,%eax
f0102bc6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bc9:	89 c2                	mov    %eax,%edx
f0102bcb:	c1 ea 0c             	shr    $0xc,%edx
f0102bce:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102bd4:	72 12                	jb     f0102be8 <mem_init+0x1903>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bd6:	50                   	push   %eax
f0102bd7:	68 c4 63 10 f0       	push   $0xf01063c4
f0102bdc:	6a 58                	push   $0x58
f0102bde:	68 4e 69 10 f0       	push   $0xf010694e
f0102be3:	e8 58 d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102be8:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102bef:	03 03 03 
f0102bf2:	74 19                	je     f0102c0d <mem_init+0x1928>
f0102bf4:	68 30 75 10 f0       	push   $0xf0107530
f0102bf9:	68 68 69 10 f0       	push   $0xf0106968
f0102bfe:	68 88 04 00 00       	push   $0x488
f0102c03:	68 42 69 10 f0       	push   $0xf0106942
f0102c08:	e8 33 d4 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c0d:	83 ec 08             	sub    $0x8,%esp
f0102c10:	68 00 10 00 00       	push   $0x1000
f0102c15:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102c1b:	e8 aa e5 ff ff       	call   f01011ca <page_remove>
	assert(pp2->pp_ref == 0);
f0102c20:	83 c4 10             	add    $0x10,%esp
f0102c23:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c28:	74 19                	je     f0102c43 <mem_init+0x195e>
f0102c2a:	68 cf 6b 10 f0       	push   $0xf0106bcf
f0102c2f:	68 68 69 10 f0       	push   $0xf0106968
f0102c34:	68 8a 04 00 00       	push   $0x48a
f0102c39:	68 42 69 10 f0       	push   $0xf0106942
f0102c3e:	e8 fd d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c43:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102c49:	8b 11                	mov    (%ecx),%edx
f0102c4b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102c51:	89 d8                	mov    %ebx,%eax
f0102c53:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102c59:	c1 f8 03             	sar    $0x3,%eax
f0102c5c:	c1 e0 0c             	shl    $0xc,%eax
f0102c5f:	39 c2                	cmp    %eax,%edx
f0102c61:	74 19                	je     f0102c7c <mem_init+0x1997>
f0102c63:	68 b8 6e 10 f0       	push   $0xf0106eb8
f0102c68:	68 68 69 10 f0       	push   $0xf0106968
f0102c6d:	68 8d 04 00 00       	push   $0x48d
f0102c72:	68 42 69 10 f0       	push   $0xf0106942
f0102c77:	e8 c4 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102c7c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102c82:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c87:	74 19                	je     f0102ca2 <mem_init+0x19bd>
f0102c89:	68 86 6b 10 f0       	push   $0xf0106b86
f0102c8e:	68 68 69 10 f0       	push   $0xf0106968
f0102c93:	68 8f 04 00 00       	push   $0x48f
f0102c98:	68 42 69 10 f0       	push   $0xf0106942
f0102c9d:	e8 9e d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102ca2:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102ca8:	83 ec 0c             	sub    $0xc,%esp
f0102cab:	53                   	push   %ebx
f0102cac:	e8 21 e3 ff ff       	call   f0100fd2 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cb1:	c7 04 24 5c 75 10 f0 	movl   $0xf010755c,(%esp)
f0102cb8:	e8 4b 0a 00 00       	call   f0103708 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102cbd:	83 c4 10             	add    $0x10,%esp
f0102cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cc3:	5b                   	pop    %ebx
f0102cc4:	5e                   	pop    %esi
f0102cc5:	5f                   	pop    %edi
f0102cc6:	5d                   	pop    %ebp
f0102cc7:	c3                   	ret    

f0102cc8 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102cc8:	55                   	push   %ebp
f0102cc9:	89 e5                	mov    %esp,%ebp
f0102ccb:	57                   	push   %edi
f0102ccc:	56                   	push   %esi
f0102ccd:	53                   	push   %ebx
f0102cce:	83 ec 1c             	sub    $0x1c,%esp
f0102cd1:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102cd4:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	uintptr_t lower = (uintptr_t )ROUNDDOWN ((uint32_t)va, PGSIZE);
f0102cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102cda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102cdf:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uintptr_t upper = (uintptr_t) va + len;
f0102ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102ce5:	03 4d 10             	add    0x10(%ebp),%ecx
f0102ce8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t lower = (uintptr_t )ROUNDDOWN ((uint32_t)va, PGSIZE);
f0102ceb:	89 c3                	mov    %eax,%ebx
	uintptr_t upper = (uintptr_t) va + len;

	for (lower; lower<upper; lower+=PGSIZE)
f0102ced:	eb 4c                	jmp    f0102d3b <user_mem_check+0x73>
	{
		pde_t *pte = pgdir_walk(env->env_pgdir, (void *)lower, 0);
f0102cef:	83 ec 04             	sub    $0x4,%esp
f0102cf2:	6a 00                	push   $0x0
f0102cf4:	53                   	push   %ebx
f0102cf5:	ff 77 60             	pushl  0x60(%edi)
f0102cf8:	e8 52 e3 ff ff       	call   f010104f <pgdir_walk>
		if (!pte || lower>=ULIM || ((uint32_t)*pte & perm) != perm)
f0102cfd:	83 c4 10             	add    $0x10,%esp
f0102d00:	85 c0                	test   %eax,%eax
f0102d02:	74 10                	je     f0102d14 <user_mem_check+0x4c>
f0102d04:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d0a:	77 08                	ja     f0102d14 <user_mem_check+0x4c>
f0102d0c:	89 f2                	mov    %esi,%edx
f0102d0e:	23 10                	and    (%eax),%edx
f0102d10:	39 d6                	cmp    %edx,%esi
f0102d12:	74 21                	je     f0102d35 <user_mem_check+0x6d>
		{

			if (lower == (uintptr_t) ROUNDDOWN ((uint32_t)va, PGSIZE))
f0102d14:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102d17:	75 0f                	jne    f0102d28 <user_mem_check+0x60>
				user_mem_check_addr = (uintptr_t) va;
f0102d19:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d1c:	a3 3c f2 22 f0       	mov    %eax,0xf022f23c
			else
				user_mem_check_addr = (uintptr_t) lower;	

			return -E_FAULT;	 
f0102d21:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d26:	eb 1d                	jmp    f0102d45 <user_mem_check+0x7d>
		{

			if (lower == (uintptr_t) ROUNDDOWN ((uint32_t)va, PGSIZE))
				user_mem_check_addr = (uintptr_t) va;
			else
				user_mem_check_addr = (uintptr_t) lower;	
f0102d28:	89 1d 3c f2 22 f0    	mov    %ebx,0xf022f23c

			return -E_FAULT;	 
f0102d2e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d33:	eb 10                	jmp    f0102d45 <user_mem_check+0x7d>
{
	// LAB 3: Your code here.
	uintptr_t lower = (uintptr_t )ROUNDDOWN ((uint32_t)va, PGSIZE);
	uintptr_t upper = (uintptr_t) va + len;

	for (lower; lower<upper; lower+=PGSIZE)
f0102d35:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d3b:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102d3e:	72 af                	jb     f0102cef <user_mem_check+0x27>

		}

	}

	return 0;
f0102d40:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d48:	5b                   	pop    %ebx
f0102d49:	5e                   	pop    %esi
f0102d4a:	5f                   	pop    %edi
f0102d4b:	5d                   	pop    %ebp
f0102d4c:	c3                   	ret    

f0102d4d <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102d4d:	55                   	push   %ebp
f0102d4e:	89 e5                	mov    %esp,%ebp
f0102d50:	53                   	push   %ebx
f0102d51:	83 ec 04             	sub    $0x4,%esp
f0102d54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102d57:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d5a:	83 c8 04             	or     $0x4,%eax
f0102d5d:	50                   	push   %eax
f0102d5e:	ff 75 10             	pushl  0x10(%ebp)
f0102d61:	ff 75 0c             	pushl  0xc(%ebp)
f0102d64:	53                   	push   %ebx
f0102d65:	e8 5e ff ff ff       	call   f0102cc8 <user_mem_check>
f0102d6a:	83 c4 10             	add    $0x10,%esp
f0102d6d:	85 c0                	test   %eax,%eax
f0102d6f:	79 21                	jns    f0102d92 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102d71:	83 ec 04             	sub    $0x4,%esp
f0102d74:	ff 35 3c f2 22 f0    	pushl  0xf022f23c
f0102d7a:	ff 73 48             	pushl  0x48(%ebx)
f0102d7d:	68 88 75 10 f0       	push   $0xf0107588
f0102d82:	e8 81 09 00 00       	call   f0103708 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102d87:	89 1c 24             	mov    %ebx,(%esp)
f0102d8a:	e8 78 06 00 00       	call   f0103407 <env_destroy>
f0102d8f:	83 c4 10             	add    $0x10,%esp
	}
}
f0102d92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102d95:	c9                   	leave  
f0102d96:	c3                   	ret    

f0102d97 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102d97:	55                   	push   %ebp
f0102d98:	89 e5                	mov    %esp,%ebp
f0102d9a:	57                   	push   %edi
f0102d9b:	56                   	push   %esi
f0102d9c:	53                   	push   %ebx
f0102d9d:	83 ec 0c             	sub    $0xc,%esp
f0102da0:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)

	int flag;
	void *lower = (void *) ROUNDDOWN(va, PGSIZE);
f0102da2:	89 d3                	mov    %edx,%ebx
f0102da4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *upper = (void *) ROUNDUP(va+len, PGSIZE);
f0102daa:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102db1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	for (; lower<upper; lower+=PGSIZE)
f0102db7:	eb 58                	jmp    f0102e11 <region_alloc+0x7a>
	{
		struct PageInfo *pp = page_alloc(0);
f0102db9:	83 ec 0c             	sub    $0xc,%esp
f0102dbc:	6a 00                	push   $0x0
f0102dbe:	e8 78 e1 ff ff       	call   f0100f3b <page_alloc>
		if (!pp)
f0102dc3:	83 c4 10             	add    $0x10,%esp
f0102dc6:	85 c0                	test   %eax,%eax
f0102dc8:	75 17                	jne    f0102de1 <region_alloc+0x4a>
			panic ("No memory");
f0102dca:	83 ec 04             	sub    $0x4,%esp
f0102dcd:	68 bd 75 10 f0       	push   $0xf01075bd
f0102dd2:	68 3d 01 00 00       	push   $0x13d
f0102dd7:	68 c7 75 10 f0       	push   $0xf01075c7
f0102ddc:	e8 5f d2 ff ff       	call   f0100040 <_panic>
		flag = page_insert(e->env_pgdir, pp, (void *)lower, PTE_U + PTE_P + PTE_W);
f0102de1:	6a 07                	push   $0x7
f0102de3:	53                   	push   %ebx
f0102de4:	50                   	push   %eax
f0102de5:	ff 77 60             	pushl  0x60(%edi)
f0102de8:	e8 23 e4 ff ff       	call   f0101210 <page_insert>
		if (flag!=0)
f0102ded:	83 c4 10             	add    $0x10,%esp
f0102df0:	85 c0                	test   %eax,%eax
f0102df2:	74 17                	je     f0102e0b <region_alloc+0x74>
			panic ("unable to insert page to the page directory");
f0102df4:	83 ec 04             	sub    $0x4,%esp
f0102df7:	68 34 76 10 f0       	push   $0xf0107634
f0102dfc:	68 40 01 00 00       	push   $0x140
f0102e01:	68 c7 75 10 f0       	push   $0xf01075c7
f0102e06:	e8 35 d2 ff ff       	call   f0100040 <_panic>

	int flag;
	void *lower = (void *) ROUNDDOWN(va, PGSIZE);
	void *upper = (void *) ROUNDUP(va+len, PGSIZE);

	for (; lower<upper; lower+=PGSIZE)
f0102e0b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e11:	39 f3                	cmp    %esi,%ebx
f0102e13:	72 a4                	jb     f0102db9 <region_alloc+0x22>
		flag = page_insert(e->env_pgdir, pp, (void *)lower, PTE_U + PTE_P + PTE_W);
		if (flag!=0)
			panic ("unable to insert page to the page directory");

	}
}
f0102e15:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e18:	5b                   	pop    %ebx
f0102e19:	5e                   	pop    %esi
f0102e1a:	5f                   	pop    %edi
f0102e1b:	5d                   	pop    %ebp
f0102e1c:	c3                   	ret    

f0102e1d <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e1d:	55                   	push   %ebp
f0102e1e:	89 e5                	mov    %esp,%ebp
f0102e20:	56                   	push   %esi
f0102e21:	53                   	push   %ebx
f0102e22:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e25:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e28:	85 c0                	test   %eax,%eax
f0102e2a:	75 1a                	jne    f0102e46 <envid2env+0x29>
		*env_store = curenv;
f0102e2c:	e8 dd 2e 00 00       	call   f0105d0e <cpunum>
f0102e31:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e34:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0102e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e3d:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e44:	eb 70                	jmp    f0102eb6 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e46:	89 c3                	mov    %eax,%ebx
f0102e48:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102e4e:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102e51:	03 1d 48 f2 22 f0    	add    0xf022f248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e57:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102e5b:	74 05                	je     f0102e62 <envid2env+0x45>
f0102e5d:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102e60:	74 10                	je     f0102e72 <envid2env+0x55>
		*env_store = 0;
f0102e62:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e6b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e70:	eb 44                	jmp    f0102eb6 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e72:	84 d2                	test   %dl,%dl
f0102e74:	74 36                	je     f0102eac <envid2env+0x8f>
f0102e76:	e8 93 2e 00 00       	call   f0105d0e <cpunum>
f0102e7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e7e:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f0102e84:	74 26                	je     f0102eac <envid2env+0x8f>
f0102e86:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102e89:	e8 80 2e 00 00       	call   f0105d0e <cpunum>
f0102e8e:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e91:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0102e97:	3b 70 48             	cmp    0x48(%eax),%esi
f0102e9a:	74 10                	je     f0102eac <envid2env+0x8f>
		*env_store = 0;
f0102e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ea5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eaa:	eb 0a                	jmp    f0102eb6 <envid2env+0x99>
	}

	*env_store = e;
f0102eac:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102eaf:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102eb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102eb6:	5b                   	pop    %ebx
f0102eb7:	5e                   	pop    %esi
f0102eb8:	5d                   	pop    %ebp
f0102eb9:	c3                   	ret    

f0102eba <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102eba:	55                   	push   %ebp
f0102ebb:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102ebd:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0102ec2:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102ec5:	b8 23 00 00 00       	mov    $0x23,%eax
f0102eca:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102ecc:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102ece:	b8 10 00 00 00       	mov    $0x10,%eax
f0102ed3:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102ed5:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102ed7:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102ed9:	ea e0 2e 10 f0 08 00 	ljmp   $0x8,$0xf0102ee0
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102ee0:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ee5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102ee8:	5d                   	pop    %ebp
f0102ee9:	c3                   	ret    

f0102eea <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102eea:	55                   	push   %ebp
f0102eeb:	89 e5                	mov    %esp,%ebp
f0102eed:	56                   	push   %esi
f0102eee:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL;
f0102eef:	c7 05 4c f2 22 f0 00 	movl   $0x0,0xf022f24c
f0102ef6:	00 00 00 
	memset (envs, 0, NENV*sizeof(struct Env));
f0102ef9:	83 ec 04             	sub    $0x4,%esp
f0102efc:	68 00 f0 01 00       	push   $0x1f000
f0102f01:	6a 00                	push   $0x0
f0102f03:	ff 35 48 f2 22 f0    	pushl  0xf022f248
f0102f09:	e8 de 27 00 00       	call   f01056ec <memset>

	for (int i = NENV-1 ; i>=0 ; i--)
	{

		envs[i].env_id = 0;
f0102f0e:	8b 35 48 f2 22 f0    	mov    0xf022f248,%esi
f0102f14:	8b 15 4c f2 22 f0    	mov    0xf022f24c,%edx
f0102f1a:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f20:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f23:	83 c4 10             	add    $0x10,%esp
f0102f26:	89 c1                	mov    %eax,%ecx
f0102f28:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f0102f2f:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0102f36:	89 50 44             	mov    %edx,0x44(%eax)
f0102f39:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = envs + i;
f0102f3c:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.
	env_free_list = NULL;
	memset (envs, 0, NENV*sizeof(struct Env));

	for (int i = NENV-1 ; i>=0 ; i--)
f0102f3e:	39 d8                	cmp    %ebx,%eax
f0102f40:	75 e4                	jne    f0102f26 <env_init+0x3c>
f0102f42:	89 35 4c f2 22 f0    	mov    %esi,0xf022f24c
		env_free_list = envs + i;

	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0102f48:	e8 6d ff ff ff       	call   f0102eba <env_init_percpu>
}
f0102f4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102f50:	5b                   	pop    %ebx
f0102f51:	5e                   	pop    %esi
f0102f52:	5d                   	pop    %ebp
f0102f53:	c3                   	ret    

f0102f54 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f54:	55                   	push   %ebp
f0102f55:	89 e5                	mov    %esp,%ebp
f0102f57:	56                   	push   %esi
f0102f58:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f59:	8b 1d 4c f2 22 f0    	mov    0xf022f24c,%ebx
f0102f5f:	85 db                	test   %ebx,%ebx
f0102f61:	0f 84 89 01 00 00    	je     f01030f0 <env_alloc+0x19c>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f67:	83 ec 0c             	sub    $0xc,%esp
f0102f6a:	6a 01                	push   $0x1
f0102f6c:	e8 ca df ff ff       	call   f0100f3b <page_alloc>
f0102f71:	83 c4 10             	add    $0x10,%esp
f0102f74:	85 c0                	test   %eax,%eax
f0102f76:	0f 84 7b 01 00 00    	je     f01030f7 <env_alloc+0x1a3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f7c:	89 c2                	mov    %eax,%edx
f0102f7e:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0102f84:	c1 fa 03             	sar    $0x3,%edx
f0102f87:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f8a:	89 d1                	mov    %edx,%ecx
f0102f8c:	c1 e9 0c             	shr    $0xc,%ecx
f0102f8f:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0102f95:	72 12                	jb     f0102fa9 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f97:	52                   	push   %edx
f0102f98:	68 c4 63 10 f0       	push   $0xf01063c4
f0102f9d:	6a 58                	push   $0x58
f0102f9f:	68 4e 69 10 f0       	push   $0xf010694e
f0102fa4:	e8 97 d0 ff ff       	call   f0100040 <_panic>
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);
f0102fa9:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102faf:	89 53 60             	mov    %edx,0x60(%ebx)
f0102fb2:	ba 00 00 00 00       	mov    $0x0,%edx

	for(i = 0; i < PDX(UTOP); i++) {
		e->env_pgdir[i] = 0;		
f0102fb7:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0102fba:	c7 04 11 00 00 00 00 	movl   $0x0,(%ecx,%edx,1)
f0102fc1:	83 c2 04             	add    $0x4,%edx

	// LAB 3: Your code here.

	e->env_pgdir = page2kva(p);

	for(i = 0; i < PDX(UTOP); i++) {
f0102fc4:	81 fa ec 0e 00 00    	cmp    $0xeec,%edx
f0102fca:	75 eb                	jne    f0102fb7 <env_alloc+0x63>
		e->env_pgdir[i] = 0;		
	}

	for(i = PDX(UTOP); i < NPDENTRIES; i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f0102fcc:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102fd2:	8b 34 11             	mov    (%ecx,%edx,1),%esi
f0102fd5:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0102fd8:	89 34 11             	mov    %esi,(%ecx,%edx,1)
f0102fdb:	83 c2 04             	add    $0x4,%edx

	for(i = 0; i < PDX(UTOP); i++) {
		e->env_pgdir[i] = 0;		
	}

	for(i = PDX(UTOP); i < NPDENTRIES; i++) {
f0102fde:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0102fe4:	75 e6                	jne    f0102fcc <env_alloc+0x78>
		e->env_pgdir[i] = kern_pgdir[i];
	}
	
	p->pp_ref++;
f0102fe6:	66 83 40 04 01       	addw   $0x1,0x4(%eax)


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102feb:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ff3:	77 15                	ja     f010300a <env_alloc+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ff5:	50                   	push   %eax
f0102ff6:	68 e8 63 10 f0       	push   $0xf01063e8
f0102ffb:	68 d5 00 00 00       	push   $0xd5
f0103000:	68 c7 75 10 f0       	push   $0xf01075c7
f0103005:	e8 36 d0 ff ff       	call   f0100040 <_panic>
f010300a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103010:	83 ca 05             	or     $0x5,%edx
f0103013:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103019:	8b 43 48             	mov    0x48(%ebx),%eax
f010301c:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103021:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103026:	ba 00 10 00 00       	mov    $0x1000,%edx
f010302b:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010302e:	89 da                	mov    %ebx,%edx
f0103030:	2b 15 48 f2 22 f0    	sub    0xf022f248,%edx
f0103036:	c1 fa 02             	sar    $0x2,%edx
f0103039:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010303f:	09 d0                	or     %edx,%eax
f0103041:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103044:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103047:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010304a:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103051:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103058:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010305f:	83 ec 04             	sub    $0x4,%esp
f0103062:	6a 44                	push   $0x44
f0103064:	6a 00                	push   $0x0
f0103066:	53                   	push   %ebx
f0103067:	e8 80 26 00 00       	call   f01056ec <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010306c:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103072:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103078:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010307e:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103085:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f010308b:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103092:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103099:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010309d:	8b 43 44             	mov    0x44(%ebx),%eax
f01030a0:	a3 4c f2 22 f0       	mov    %eax,0xf022f24c
	*newenv_store = e;
f01030a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01030a8:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01030aa:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01030ad:	e8 5c 2c 00 00       	call   f0105d0e <cpunum>
f01030b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01030b5:	83 c4 10             	add    $0x10,%esp
f01030b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01030bd:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01030c4:	74 11                	je     f01030d7 <env_alloc+0x183>
f01030c6:	e8 43 2c 00 00       	call   f0105d0e <cpunum>
f01030cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ce:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01030d4:	8b 50 48             	mov    0x48(%eax),%edx
f01030d7:	83 ec 04             	sub    $0x4,%esp
f01030da:	53                   	push   %ebx
f01030db:	52                   	push   %edx
f01030dc:	68 d2 75 10 f0       	push   $0xf01075d2
f01030e1:	e8 22 06 00 00       	call   f0103708 <cprintf>
	return 0;
f01030e6:	83 c4 10             	add    $0x10,%esp
f01030e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01030ee:	eb 0c                	jmp    f01030fc <env_alloc+0x1a8>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01030f0:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01030f5:	eb 05                	jmp    f01030fc <env_alloc+0x1a8>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01030f7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01030fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01030ff:	5b                   	pop    %ebx
f0103100:	5e                   	pop    %esi
f0103101:	5d                   	pop    %ebp
f0103102:	c3                   	ret    

f0103103 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103103:	55                   	push   %ebp
f0103104:	89 e5                	mov    %esp,%ebp
f0103106:	57                   	push   %edi
f0103107:	56                   	push   %esi
f0103108:	53                   	push   %ebx
f0103109:	83 ec 34             	sub    $0x34,%esp
f010310c:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env * e;
	int i = env_alloc(&e, 0);
f010310f:	6a 00                	push   $0x0
f0103111:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103114:	50                   	push   %eax
f0103115:	e8 3a fe ff ff       	call   f0102f54 <env_alloc>

	if (i < 0)
f010311a:	83 c4 10             	add    $0x10,%esp
f010311d:	85 c0                	test   %eax,%eax
f010311f:	79 17                	jns    f0103138 <env_create+0x35>
		panic ("Env create failed");
f0103121:	83 ec 04             	sub    $0x4,%esp
f0103124:	68 e7 75 10 f0       	push   $0xf01075e7
f0103129:	68 b0 01 00 00       	push   $0x1b0
f010312e:	68 c7 75 10 f0       	push   $0xf01075c7
f0103133:	e8 08 cf ff ff       	call   f0100040 <_panic>
	
	load_icode(e, binary);
f0103138:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010313b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.

	struct Proghdr *ph, *eph;
	struct Elf *ELFHDR = (struct Elf *) binary;

	if (ELFHDR->e_magic != ELF_MAGIC)
f010313e:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103144:	74 17                	je     f010315d <env_create+0x5a>
		panic ("Not a valid Elf file!");
f0103146:	83 ec 04             	sub    $0x4,%esp
f0103149:	68 f9 75 10 f0       	push   $0xf01075f9
f010314e:	68 80 01 00 00       	push   $0x180
f0103153:	68 c7 75 10 f0       	push   $0xf01075c7
f0103158:	e8 e3 ce ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f010315d:	89 fb                	mov    %edi,%ebx
f010315f:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103162:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103166:	c1 e6 05             	shl    $0x5,%esi
f0103169:	01 de                	add    %ebx,%esi


	lcr3(PADDR(e->env_pgdir));
f010316b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010316e:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103171:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103176:	77 15                	ja     f010318d <env_create+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103178:	50                   	push   %eax
f0103179:	68 e8 63 10 f0       	push   $0xf01063e8
f010317e:	68 86 01 00 00       	push   $0x186
f0103183:	68 c7 75 10 f0       	push   $0xf01075c7
f0103188:	e8 b3 ce ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010318d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103192:	0f 22 d8             	mov    %eax,%cr3
f0103195:	eb 3d                	jmp    f01031d4 <env_create+0xd1>

	for (; ph < eph; ph++)
	{
		
		if (ph->p_type == ELF_PROG_LOAD)
f0103197:	83 3b 01             	cmpl   $0x1,(%ebx)
f010319a:	75 35                	jne    f01031d1 <env_create+0xce>
		{
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010319c:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010319f:	8b 53 08             	mov    0x8(%ebx),%edx
f01031a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031a5:	e8 ed fb ff ff       	call   f0102d97 <region_alloc>

			memset((void *)ph->p_va, 0, ph->p_memsz);
f01031aa:	83 ec 04             	sub    $0x4,%esp
f01031ad:	ff 73 14             	pushl  0x14(%ebx)
f01031b0:	6a 00                	push   $0x0
f01031b2:	ff 73 08             	pushl  0x8(%ebx)
f01031b5:	e8 32 25 00 00       	call   f01056ec <memset>
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01031ba:	83 c4 0c             	add    $0xc,%esp
f01031bd:	ff 73 10             	pushl  0x10(%ebx)
f01031c0:	89 f8                	mov    %edi,%eax
f01031c2:	03 43 04             	add    0x4(%ebx),%eax
f01031c5:	50                   	push   %eax
f01031c6:	ff 73 08             	pushl  0x8(%ebx)
f01031c9:	e8 d3 25 00 00       	call   f01057a1 <memcpy>
f01031ce:	83 c4 10             	add    $0x10,%esp
	eph = ph + ELFHDR->e_phnum;


	lcr3(PADDR(e->env_pgdir));

	for (; ph < eph; ph++)
f01031d1:	83 c3 20             	add    $0x20,%ebx
f01031d4:	39 de                	cmp    %ebx,%esi
f01031d6:	77 bf                	ja     f0103197 <env_create+0x94>
			memset((void *)ph->p_va, 0, ph->p_memsz);
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
		}
	}

	e->env_tf.tf_eip = ELFHDR->e_entry;
f01031d8:	8b 47 18             	mov    0x18(%edi),%eax
f01031db:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01031de:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.

	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE);
f01031e1:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01031e6:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01031eb:	89 f8                	mov    %edi,%eax
f01031ed:	e8 a5 fb ff ff       	call   f0102d97 <region_alloc>

	lcr3(PADDR(kern_pgdir));
f01031f2:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031f7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031fc:	77 15                	ja     f0103213 <env_create+0x110>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031fe:	50                   	push   %eax
f01031ff:	68 e8 63 10 f0       	push   $0xf01063e8
f0103204:	68 9e 01 00 00       	push   $0x19e
f0103209:	68 c7 75 10 f0       	push   $0xf01075c7
f010320e:	e8 2d ce ff ff       	call   f0100040 <_panic>
f0103213:	05 00 00 00 10       	add    $0x10000000,%eax
f0103218:	0f 22 d8             	mov    %eax,%cr3

	if (i < 0)
		panic ("Env create failed");
	
	load_icode(e, binary);
	e->env_type = type;
f010321b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010321e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103221:	89 50 50             	mov    %edx,0x50(%eax)

}
f0103224:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103227:	5b                   	pop    %ebx
f0103228:	5e                   	pop    %esi
f0103229:	5f                   	pop    %edi
f010322a:	5d                   	pop    %ebp
f010322b:	c3                   	ret    

f010322c <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010322c:	55                   	push   %ebp
f010322d:	89 e5                	mov    %esp,%ebp
f010322f:	57                   	push   %edi
f0103230:	56                   	push   %esi
f0103231:	53                   	push   %ebx
f0103232:	83 ec 1c             	sub    $0x1c,%esp
f0103235:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103238:	e8 d1 2a 00 00       	call   f0105d0e <cpunum>
f010323d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103240:	39 b8 28 00 23 f0    	cmp    %edi,-0xfdcffd8(%eax)
f0103246:	75 29                	jne    f0103271 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f0103248:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010324d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103252:	77 15                	ja     f0103269 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103254:	50                   	push   %eax
f0103255:	68 e8 63 10 f0       	push   $0xf01063e8
f010325a:	68 c5 01 00 00       	push   $0x1c5
f010325f:	68 c7 75 10 f0       	push   $0xf01075c7
f0103264:	e8 d7 cd ff ff       	call   f0100040 <_panic>
f0103269:	05 00 00 00 10       	add    $0x10000000,%eax
f010326e:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103271:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103274:	e8 95 2a 00 00       	call   f0105d0e <cpunum>
f0103279:	6b c0 74             	imul   $0x74,%eax,%eax
f010327c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103281:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103288:	74 11                	je     f010329b <env_free+0x6f>
f010328a:	e8 7f 2a 00 00       	call   f0105d0e <cpunum>
f010328f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103292:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103298:	8b 50 48             	mov    0x48(%eax),%edx
f010329b:	83 ec 04             	sub    $0x4,%esp
f010329e:	53                   	push   %ebx
f010329f:	52                   	push   %edx
f01032a0:	68 0f 76 10 f0       	push   $0xf010760f
f01032a5:	e8 5e 04 00 00       	call   f0103708 <cprintf>
f01032aa:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01032ad:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01032b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01032b7:	89 d0                	mov    %edx,%eax
f01032b9:	c1 e0 02             	shl    $0x2,%eax
f01032bc:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032bf:	8b 47 60             	mov    0x60(%edi),%eax
f01032c2:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01032c5:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01032cb:	0f 84 a8 00 00 00    	je     f0103379 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01032d1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032d7:	89 f0                	mov    %esi,%eax
f01032d9:	c1 e8 0c             	shr    $0xc,%eax
f01032dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032df:	39 05 88 fe 22 f0    	cmp    %eax,0xf022fe88
f01032e5:	77 15                	ja     f01032fc <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032e7:	56                   	push   %esi
f01032e8:	68 c4 63 10 f0       	push   $0xf01063c4
f01032ed:	68 d4 01 00 00       	push   $0x1d4
f01032f2:	68 c7 75 10 f0       	push   $0xf01075c7
f01032f7:	e8 44 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032ff:	c1 e0 16             	shl    $0x16,%eax
f0103302:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103305:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010330a:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103311:	01 
f0103312:	74 17                	je     f010332b <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103314:	83 ec 08             	sub    $0x8,%esp
f0103317:	89 d8                	mov    %ebx,%eax
f0103319:	c1 e0 0c             	shl    $0xc,%eax
f010331c:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010331f:	50                   	push   %eax
f0103320:	ff 77 60             	pushl  0x60(%edi)
f0103323:	e8 a2 de ff ff       	call   f01011ca <page_remove>
f0103328:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010332b:	83 c3 01             	add    $0x1,%ebx
f010332e:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103334:	75 d4                	jne    f010330a <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103336:	8b 47 60             	mov    0x60(%edi),%eax
f0103339:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010333c:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103343:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103346:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f010334c:	72 14                	jb     f0103362 <env_free+0x136>
		panic("pa2page called with invalid pa");
f010334e:	83 ec 04             	sub    $0x4,%esp
f0103351:	68 84 6d 10 f0       	push   $0xf0106d84
f0103356:	6a 51                	push   $0x51
f0103358:	68 4e 69 10 f0       	push   $0xf010694e
f010335d:	e8 de cc ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103362:	83 ec 0c             	sub    $0xc,%esp
f0103365:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f010336a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010336d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103370:	50                   	push   %eax
f0103371:	e8 b2 dc ff ff       	call   f0101028 <page_decref>
f0103376:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103379:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010337d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103380:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103385:	0f 85 29 ff ff ff    	jne    f01032b4 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010338b:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010338e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103393:	77 15                	ja     f01033aa <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103395:	50                   	push   %eax
f0103396:	68 e8 63 10 f0       	push   $0xf01063e8
f010339b:	68 e2 01 00 00       	push   $0x1e2
f01033a0:	68 c7 75 10 f0       	push   $0xf01075c7
f01033a5:	e8 96 cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01033aa:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01033b1:	05 00 00 00 10       	add    $0x10000000,%eax
f01033b6:	c1 e8 0c             	shr    $0xc,%eax
f01033b9:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01033bf:	72 14                	jb     f01033d5 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f01033c1:	83 ec 04             	sub    $0x4,%esp
f01033c4:	68 84 6d 10 f0       	push   $0xf0106d84
f01033c9:	6a 51                	push   $0x51
f01033cb:	68 4e 69 10 f0       	push   $0xf010694e
f01033d0:	e8 6b cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01033d5:	83 ec 0c             	sub    $0xc,%esp
f01033d8:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f01033de:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01033e1:	50                   	push   %eax
f01033e2:	e8 41 dc ff ff       	call   f0101028 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033e7:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01033ee:	a1 4c f2 22 f0       	mov    0xf022f24c,%eax
f01033f3:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01033f6:	89 3d 4c f2 22 f0    	mov    %edi,0xf022f24c
}
f01033fc:	83 c4 10             	add    $0x10,%esp
f01033ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103402:	5b                   	pop    %ebx
f0103403:	5e                   	pop    %esi
f0103404:	5f                   	pop    %edi
f0103405:	5d                   	pop    %ebp
f0103406:	c3                   	ret    

f0103407 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103407:	55                   	push   %ebp
f0103408:	89 e5                	mov    %esp,%ebp
f010340a:	53                   	push   %ebx
f010340b:	83 ec 04             	sub    $0x4,%esp
f010340e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103411:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103415:	75 19                	jne    f0103430 <env_destroy+0x29>
f0103417:	e8 f2 28 00 00       	call   f0105d0e <cpunum>
f010341c:	6b c0 74             	imul   $0x74,%eax,%eax
f010341f:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f0103425:	74 09                	je     f0103430 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103427:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010342e:	eb 33                	jmp    f0103463 <env_destroy+0x5c>
	}

	env_free(e);
f0103430:	83 ec 0c             	sub    $0xc,%esp
f0103433:	53                   	push   %ebx
f0103434:	e8 f3 fd ff ff       	call   f010322c <env_free>

	if (curenv == e) {
f0103439:	e8 d0 28 00 00       	call   f0105d0e <cpunum>
f010343e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103441:	83 c4 10             	add    $0x10,%esp
f0103444:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f010344a:	75 17                	jne    f0103463 <env_destroy+0x5c>
		curenv = NULL;
f010344c:	e8 bd 28 00 00       	call   f0105d0e <cpunum>
f0103451:	6b c0 74             	imul   $0x74,%eax,%eax
f0103454:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f010345b:	00 00 00 
		sched_yield();
f010345e:	e8 d9 10 00 00       	call   f010453c <sched_yield>
	}
}
f0103463:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103466:	c9                   	leave  
f0103467:	c3                   	ret    

f0103468 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103468:	55                   	push   %ebp
f0103469:	89 e5                	mov    %esp,%ebp
f010346b:	53                   	push   %ebx
f010346c:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010346f:	e8 9a 28 00 00       	call   f0105d0e <cpunum>
f0103474:	6b c0 74             	imul   $0x74,%eax,%eax
f0103477:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f010347d:	e8 8c 28 00 00       	call   f0105d0e <cpunum>
f0103482:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103485:	8b 65 08             	mov    0x8(%ebp),%esp
f0103488:	61                   	popa   
f0103489:	07                   	pop    %es
f010348a:	1f                   	pop    %ds
f010348b:	83 c4 08             	add    $0x8,%esp
f010348e:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010348f:	83 ec 04             	sub    $0x4,%esp
f0103492:	68 25 76 10 f0       	push   $0xf0107625
f0103497:	68 19 02 00 00       	push   $0x219
f010349c:	68 c7 75 10 f0       	push   $0xf01075c7
f01034a1:	e8 9a cb ff ff       	call   f0100040 <_panic>

f01034a6 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01034a6:	55                   	push   %ebp
f01034a7:	89 e5                	mov    %esp,%ebp
f01034a9:	53                   	push   %ebx
f01034aa:	83 ec 04             	sub    $0x4,%esp
f01034ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e)
f01034b0:	e8 59 28 00 00       	call   f0105d0e <cpunum>
f01034b5:	6b c0 74             	imul   $0x74,%eax,%eax
f01034b8:	39 98 28 00 23 f0    	cmp    %ebx,-0xfdcffd8(%eax)
f01034be:	74 6f                	je     f010352f <env_run+0x89>
	{
		if (curenv && curenv->env_status == ENV_RUNNING)
f01034c0:	e8 49 28 00 00       	call   f0105d0e <cpunum>
f01034c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01034c8:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01034cf:	74 29                	je     f01034fa <env_run+0x54>
f01034d1:	e8 38 28 00 00       	call   f0105d0e <cpunum>
f01034d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01034d9:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01034df:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01034e3:	75 15                	jne    f01034fa <env_run+0x54>
		{
			curenv->env_status = ENV_RUNNABLE;
f01034e5:	e8 24 28 00 00       	call   f0105d0e <cpunum>
f01034ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ed:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01034f3:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
		curenv = e;
f01034fa:	e8 0f 28 00 00       	call   f0105d0e <cpunum>
f01034ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0103502:	89 98 28 00 23 f0    	mov    %ebx,-0xfdcffd8(%eax)
		curenv->env_status = ENV_RUNNING;
f0103508:	e8 01 28 00 00       	call   f0105d0e <cpunum>
f010350d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103510:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103516:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f010351d:	e8 ec 27 00 00       	call   f0105d0e <cpunum>
f0103522:	6b c0 74             	imul   $0x74,%eax,%eax
f0103525:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010352b:	83 40 58 01          	addl   $0x1,0x58(%eax)
		
	}
	lcr3(PADDR(curenv->env_pgdir));
f010352f:	e8 da 27 00 00       	call   f0105d0e <cpunum>
f0103534:	6b c0 74             	imul   $0x74,%eax,%eax
f0103537:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010353d:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103540:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103545:	77 15                	ja     f010355c <env_run+0xb6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103547:	50                   	push   %eax
f0103548:	68 e8 63 10 f0       	push   $0xf01063e8
f010354d:	68 42 02 00 00       	push   $0x242
f0103552:	68 c7 75 10 f0       	push   $0xf01075c7
f0103557:	e8 e4 ca ff ff       	call   f0100040 <_panic>
f010355c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103561:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103564:	83 ec 0c             	sub    $0xc,%esp
f0103567:	68 c0 03 12 f0       	push   $0xf01203c0
f010356c:	e8 a8 2a 00 00       	call   f0106019 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103571:	f3 90                	pause  

	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f0103573:	e8 96 27 00 00       	call   f0105d0e <cpunum>
f0103578:	83 c4 04             	add    $0x4,%esp
f010357b:	6b c0 74             	imul   $0x74,%eax,%eax
f010357e:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0103584:	e8 df fe ff ff       	call   f0103468 <env_pop_tf>

f0103589 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103589:	55                   	push   %ebp
f010358a:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010358c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103591:	8b 45 08             	mov    0x8(%ebp),%eax
f0103594:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103595:	ba 71 00 00 00       	mov    $0x71,%edx
f010359a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010359b:	0f b6 c0             	movzbl %al,%eax
}
f010359e:	5d                   	pop    %ebp
f010359f:	c3                   	ret    

f01035a0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035a0:	55                   	push   %ebp
f01035a1:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035a3:	ba 70 00 00 00       	mov    $0x70,%edx
f01035a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01035ab:	ee                   	out    %al,(%dx)
f01035ac:	ba 71 00 00 00       	mov    $0x71,%edx
f01035b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035b4:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01035b5:	5d                   	pop    %ebp
f01035b6:	c3                   	ret    

f01035b7 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01035b7:	55                   	push   %ebp
f01035b8:	89 e5                	mov    %esp,%ebp
f01035ba:	56                   	push   %esi
f01035bb:	53                   	push   %ebx
f01035bc:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01035bf:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f01035c5:	80 3d 50 f2 22 f0 00 	cmpb   $0x0,0xf022f250
f01035cc:	74 5a                	je     f0103628 <irq_setmask_8259A+0x71>
f01035ce:	89 c6                	mov    %eax,%esi
f01035d0:	ba 21 00 00 00       	mov    $0x21,%edx
f01035d5:	ee                   	out    %al,(%dx)
f01035d6:	66 c1 e8 08          	shr    $0x8,%ax
f01035da:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035df:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01035e0:	83 ec 0c             	sub    $0xc,%esp
f01035e3:	68 60 76 10 f0       	push   $0xf0107660
f01035e8:	e8 1b 01 00 00       	call   f0103708 <cprintf>
f01035ed:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01035f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01035f5:	0f b7 f6             	movzwl %si,%esi
f01035f8:	f7 d6                	not    %esi
f01035fa:	0f a3 de             	bt     %ebx,%esi
f01035fd:	73 11                	jae    f0103610 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f01035ff:	83 ec 08             	sub    $0x8,%esp
f0103602:	53                   	push   %ebx
f0103603:	68 1b 7b 10 f0       	push   $0xf0107b1b
f0103608:	e8 fb 00 00 00       	call   f0103708 <cprintf>
f010360d:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103610:	83 c3 01             	add    $0x1,%ebx
f0103613:	83 fb 10             	cmp    $0x10,%ebx
f0103616:	75 e2                	jne    f01035fa <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103618:	83 ec 0c             	sub    $0xc,%esp
f010361b:	68 6a 6c 10 f0       	push   $0xf0106c6a
f0103620:	e8 e3 00 00 00       	call   f0103708 <cprintf>
f0103625:	83 c4 10             	add    $0x10,%esp
}
f0103628:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010362b:	5b                   	pop    %ebx
f010362c:	5e                   	pop    %esi
f010362d:	5d                   	pop    %ebp
f010362e:	c3                   	ret    

f010362f <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010362f:	c6 05 50 f2 22 f0 01 	movb   $0x1,0xf022f250
f0103636:	ba 21 00 00 00       	mov    $0x21,%edx
f010363b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103640:	ee                   	out    %al,(%dx)
f0103641:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103646:	ee                   	out    %al,(%dx)
f0103647:	ba 20 00 00 00       	mov    $0x20,%edx
f010364c:	b8 11 00 00 00       	mov    $0x11,%eax
f0103651:	ee                   	out    %al,(%dx)
f0103652:	ba 21 00 00 00       	mov    $0x21,%edx
f0103657:	b8 20 00 00 00       	mov    $0x20,%eax
f010365c:	ee                   	out    %al,(%dx)
f010365d:	b8 04 00 00 00       	mov    $0x4,%eax
f0103662:	ee                   	out    %al,(%dx)
f0103663:	b8 03 00 00 00       	mov    $0x3,%eax
f0103668:	ee                   	out    %al,(%dx)
f0103669:	ba a0 00 00 00       	mov    $0xa0,%edx
f010366e:	b8 11 00 00 00       	mov    $0x11,%eax
f0103673:	ee                   	out    %al,(%dx)
f0103674:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103679:	b8 28 00 00 00       	mov    $0x28,%eax
f010367e:	ee                   	out    %al,(%dx)
f010367f:	b8 02 00 00 00       	mov    $0x2,%eax
f0103684:	ee                   	out    %al,(%dx)
f0103685:	b8 01 00 00 00       	mov    $0x1,%eax
f010368a:	ee                   	out    %al,(%dx)
f010368b:	ba 20 00 00 00       	mov    $0x20,%edx
f0103690:	b8 68 00 00 00       	mov    $0x68,%eax
f0103695:	ee                   	out    %al,(%dx)
f0103696:	b8 0a 00 00 00       	mov    $0xa,%eax
f010369b:	ee                   	out    %al,(%dx)
f010369c:	ba a0 00 00 00       	mov    $0xa0,%edx
f01036a1:	b8 68 00 00 00       	mov    $0x68,%eax
f01036a6:	ee                   	out    %al,(%dx)
f01036a7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036ac:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01036ad:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01036b4:	66 83 f8 ff          	cmp    $0xffff,%ax
f01036b8:	74 13                	je     f01036cd <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01036ba:	55                   	push   %ebp
f01036bb:	89 e5                	mov    %esp,%ebp
f01036bd:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01036c0:	0f b7 c0             	movzwl %ax,%eax
f01036c3:	50                   	push   %eax
f01036c4:	e8 ee fe ff ff       	call   f01035b7 <irq_setmask_8259A>
f01036c9:	83 c4 10             	add    $0x10,%esp
}
f01036cc:	c9                   	leave  
f01036cd:	f3 c3                	repz ret 

f01036cf <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01036cf:	55                   	push   %ebp
f01036d0:	89 e5                	mov    %esp,%ebp
f01036d2:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01036d5:	ff 75 08             	pushl  0x8(%ebp)
f01036d8:	e8 87 d0 ff ff       	call   f0100764 <cputchar>
	*cnt++;
}
f01036dd:	83 c4 10             	add    $0x10,%esp
f01036e0:	c9                   	leave  
f01036e1:	c3                   	ret    

f01036e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01036e2:	55                   	push   %ebp
f01036e3:	89 e5                	mov    %esp,%ebp
f01036e5:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01036e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01036ef:	ff 75 0c             	pushl  0xc(%ebp)
f01036f2:	ff 75 08             	pushl  0x8(%ebp)
f01036f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01036f8:	50                   	push   %eax
f01036f9:	68 cf 36 10 f0       	push   $0xf01036cf
f01036fe:	e8 7d 19 00 00       	call   f0105080 <vprintfmt>
	return cnt;
}
f0103703:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103706:	c9                   	leave  
f0103707:	c3                   	ret    

f0103708 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103708:	55                   	push   %ebp
f0103709:	89 e5                	mov    %esp,%ebp
f010370b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010370e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103711:	50                   	push   %eax
f0103712:	ff 75 08             	pushl  0x8(%ebp)
f0103715:	e8 c8 ff ff ff       	call   f01036e2 <vcprintf>
	va_end(ap);

	return cnt;
}
f010371a:	c9                   	leave  
f010371b:	c3                   	ret    

f010371c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010371c:	55                   	push   %ebp
f010371d:	89 e5                	mov    %esp,%ebp
f010371f:	57                   	push   %edi
f0103720:	56                   	push   %esi
f0103721:	53                   	push   %ebx
f0103722:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t)  percpu_kstacks[thiscpu->cpu_id];
f0103725:	e8 e4 25 00 00       	call   f0105d0e <cpunum>
f010372a:	89 c3                	mov    %eax,%ebx
f010372c:	e8 dd 25 00 00       	call   f0105d0e <cpunum>
f0103731:	6b db 74             	imul   $0x74,%ebx,%ebx
f0103734:	6b c0 74             	imul   $0x74,%eax,%eax
f0103737:	0f b6 90 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%edx
f010373e:	c1 e2 0f             	shl    $0xf,%edx
f0103741:	81 c2 00 10 23 f0    	add    $0xf0231000,%edx
f0103747:	89 93 30 00 23 f0    	mov    %edx,-0xfdcffd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f010374d:	e8 bc 25 00 00       	call   f0105d0e <cpunum>
f0103752:	6b c0 74             	imul   $0x74,%eax,%eax
f0103755:	66 c7 80 34 00 23 f0 	movw   $0x10,-0xfdcffcc(%eax)
f010375c:	10 00 
	

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f010375e:	e8 ab 25 00 00       	call   f0105d0e <cpunum>
f0103763:	6b c0 74             	imul   $0x74,%eax,%eax
f0103766:	0f b6 98 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%ebx
f010376d:	83 c3 05             	add    $0x5,%ebx
f0103770:	e8 99 25 00 00       	call   f0105d0e <cpunum>
f0103775:	89 c7                	mov    %eax,%edi
f0103777:	e8 92 25 00 00       	call   f0105d0e <cpunum>
f010377c:	89 c6                	mov    %eax,%esi
f010377e:	e8 8b 25 00 00       	call   f0105d0e <cpunum>
f0103783:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f010378a:	f0 67 00 
f010378d:	6b ff 74             	imul   $0x74,%edi,%edi
f0103790:	81 c7 2c 00 23 f0    	add    $0xf023002c,%edi
f0103796:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f010379d:	f0 
f010379e:	6b d6 74             	imul   $0x74,%esi,%edx
f01037a1:	81 c2 2c 00 23 f0    	add    $0xf023002c,%edx
f01037a7:	c1 ea 10             	shr    $0x10,%edx
f01037aa:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f01037b1:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f01037b8:	99 
f01037b9:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f01037c0:	40 
f01037c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01037c4:	05 2c 00 23 f0       	add    $0xf023002c,%eax
f01037c9:	c1 e8 18             	shr    $0x18,%eax
f01037cc:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f01037d3:	e8 36 25 00 00       	call   f0105d0e <cpunum>
f01037d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01037db:	0f b6 80 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%eax
f01037e2:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f01037e9:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + thiscpu->cpu_id * sizeof(struct Segdesc));
f01037ea:	e8 1f 25 00 00       	call   f0105d0e <cpunum>
f01037ef:	6b c0 74             	imul   $0x74,%eax,%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f01037f2:	0f b6 80 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%eax
f01037f9:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103800:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103803:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103808:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f010380b:	83 c4 0c             	add    $0xc,%esp
f010380e:	5b                   	pop    %ebx
f010380f:	5e                   	pop    %esi
f0103810:	5f                   	pop    %edi
f0103811:	5d                   	pop    %ebp
f0103812:	c3                   	ret    

f0103813 <trap_init>:
}


void
trap_init(void)
{
f0103813:	55                   	push   %ebp
f0103814:	89 e5                	mov    %esp,%ebp
f0103816:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];
	int i;

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0103819:	b8 5e 43 10 f0       	mov    $0xf010435e,%eax
f010381e:	66 a3 60 f2 22 f0    	mov    %ax,0xf022f260
f0103824:	66 c7 05 62 f2 22 f0 	movw   $0x8,0xf022f262
f010382b:	08 00 
f010382d:	c6 05 64 f2 22 f0 00 	movb   $0x0,0xf022f264
f0103834:	c6 05 65 f2 22 f0 8e 	movb   $0x8e,0xf022f265
f010383b:	c1 e8 10             	shr    $0x10,%eax
f010383e:	66 a3 66 f2 22 f0    	mov    %ax,0xf022f266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103844:	b8 68 43 10 f0       	mov    $0xf0104368,%eax
f0103849:	66 a3 68 f2 22 f0    	mov    %ax,0xf022f268
f010384f:	66 c7 05 6a f2 22 f0 	movw   $0x8,0xf022f26a
f0103856:	08 00 
f0103858:	c6 05 6c f2 22 f0 00 	movb   $0x0,0xf022f26c
f010385f:	c6 05 6d f2 22 f0 8e 	movb   $0x8e,0xf022f26d
f0103866:	c1 e8 10             	shr    $0x10,%eax
f0103869:	66 a3 6e f2 22 f0    	mov    %ax,0xf022f26e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f010386f:	b8 72 43 10 f0       	mov    $0xf0104372,%eax
f0103874:	66 a3 70 f2 22 f0    	mov    %ax,0xf022f270
f010387a:	66 c7 05 72 f2 22 f0 	movw   $0x8,0xf022f272
f0103881:	08 00 
f0103883:	c6 05 74 f2 22 f0 00 	movb   $0x0,0xf022f274
f010388a:	c6 05 75 f2 22 f0 8e 	movb   $0x8e,0xf022f275
f0103891:	c1 e8 10             	shr    $0x10,%eax
f0103894:	66 a3 76 f2 22 f0    	mov    %ax,0xf022f276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f010389a:	b8 7c 43 10 f0       	mov    $0xf010437c,%eax
f010389f:	66 a3 78 f2 22 f0    	mov    %ax,0xf022f278
f01038a5:	66 c7 05 7a f2 22 f0 	movw   $0x8,0xf022f27a
f01038ac:	08 00 
f01038ae:	c6 05 7c f2 22 f0 00 	movb   $0x0,0xf022f27c
f01038b5:	c6 05 7d f2 22 f0 ee 	movb   $0xee,0xf022f27d
f01038bc:	c1 e8 10             	shr    $0x10,%eax
f01038bf:	66 a3 7e f2 22 f0    	mov    %ax,0xf022f27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f01038c5:	b8 86 43 10 f0       	mov    $0xf0104386,%eax
f01038ca:	66 a3 80 f2 22 f0    	mov    %ax,0xf022f280
f01038d0:	66 c7 05 82 f2 22 f0 	movw   $0x8,0xf022f282
f01038d7:	08 00 
f01038d9:	c6 05 84 f2 22 f0 00 	movb   $0x0,0xf022f284
f01038e0:	c6 05 85 f2 22 f0 8e 	movb   $0x8e,0xf022f285
f01038e7:	c1 e8 10             	shr    $0x10,%eax
f01038ea:	66 a3 86 f2 22 f0    	mov    %ax,0xf022f286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f01038f0:	b8 90 43 10 f0       	mov    $0xf0104390,%eax
f01038f5:	66 a3 88 f2 22 f0    	mov    %ax,0xf022f288
f01038fb:	66 c7 05 8a f2 22 f0 	movw   $0x8,0xf022f28a
f0103902:	08 00 
f0103904:	c6 05 8c f2 22 f0 00 	movb   $0x0,0xf022f28c
f010390b:	c6 05 8d f2 22 f0 8e 	movb   $0x8e,0xf022f28d
f0103912:	c1 e8 10             	shr    $0x10,%eax
f0103915:	66 a3 8e f2 22 f0    	mov    %ax,0xf022f28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f010391b:	b8 9a 43 10 f0       	mov    $0xf010439a,%eax
f0103920:	66 a3 90 f2 22 f0    	mov    %ax,0xf022f290
f0103926:	66 c7 05 92 f2 22 f0 	movw   $0x8,0xf022f292
f010392d:	08 00 
f010392f:	c6 05 94 f2 22 f0 00 	movb   $0x0,0xf022f294
f0103936:	c6 05 95 f2 22 f0 8e 	movb   $0x8e,0xf022f295
f010393d:	c1 e8 10             	shr    $0x10,%eax
f0103940:	66 a3 96 f2 22 f0    	mov    %ax,0xf022f296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103946:	b8 a4 43 10 f0       	mov    $0xf01043a4,%eax
f010394b:	66 a3 98 f2 22 f0    	mov    %ax,0xf022f298
f0103951:	66 c7 05 9a f2 22 f0 	movw   $0x8,0xf022f29a
f0103958:	08 00 
f010395a:	c6 05 9c f2 22 f0 00 	movb   $0x0,0xf022f29c
f0103961:	c6 05 9d f2 22 f0 8e 	movb   $0x8e,0xf022f29d
f0103968:	c1 e8 10             	shr    $0x10,%eax
f010396b:	66 a3 9e f2 22 f0    	mov    %ax,0xf022f29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103971:	b8 ae 43 10 f0       	mov    $0xf01043ae,%eax
f0103976:	66 a3 a0 f2 22 f0    	mov    %ax,0xf022f2a0
f010397c:	66 c7 05 a2 f2 22 f0 	movw   $0x8,0xf022f2a2
f0103983:	08 00 
f0103985:	c6 05 a4 f2 22 f0 00 	movb   $0x0,0xf022f2a4
f010398c:	c6 05 a5 f2 22 f0 8e 	movb   $0x8e,0xf022f2a5
f0103993:	c1 e8 10             	shr    $0x10,%eax
f0103996:	66 a3 a6 f2 22 f0    	mov    %ax,0xf022f2a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f010399c:	b8 b6 43 10 f0       	mov    $0xf01043b6,%eax
f01039a1:	66 a3 b0 f2 22 f0    	mov    %ax,0xf022f2b0
f01039a7:	66 c7 05 b2 f2 22 f0 	movw   $0x8,0xf022f2b2
f01039ae:	08 00 
f01039b0:	c6 05 b4 f2 22 f0 00 	movb   $0x0,0xf022f2b4
f01039b7:	c6 05 b5 f2 22 f0 8e 	movb   $0x8e,0xf022f2b5
f01039be:	c1 e8 10             	shr    $0x10,%eax
f01039c1:	66 a3 b6 f2 22 f0    	mov    %ax,0xf022f2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f01039c7:	b8 be 43 10 f0       	mov    $0xf01043be,%eax
f01039cc:	66 a3 b8 f2 22 f0    	mov    %ax,0xf022f2b8
f01039d2:	66 c7 05 ba f2 22 f0 	movw   $0x8,0xf022f2ba
f01039d9:	08 00 
f01039db:	c6 05 bc f2 22 f0 00 	movb   $0x0,0xf022f2bc
f01039e2:	c6 05 bd f2 22 f0 8e 	movb   $0x8e,0xf022f2bd
f01039e9:	c1 e8 10             	shr    $0x10,%eax
f01039ec:	66 a3 be f2 22 f0    	mov    %ax,0xf022f2be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f01039f2:	b8 c6 43 10 f0       	mov    $0xf01043c6,%eax
f01039f7:	66 a3 c0 f2 22 f0    	mov    %ax,0xf022f2c0
f01039fd:	66 c7 05 c2 f2 22 f0 	movw   $0x8,0xf022f2c2
f0103a04:	08 00 
f0103a06:	c6 05 c4 f2 22 f0 00 	movb   $0x0,0xf022f2c4
f0103a0d:	c6 05 c5 f2 22 f0 8e 	movb   $0x8e,0xf022f2c5
f0103a14:	c1 e8 10             	shr    $0x10,%eax
f0103a17:	66 a3 c6 f2 22 f0    	mov    %ax,0xf022f2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103a1d:	b8 ce 43 10 f0       	mov    $0xf01043ce,%eax
f0103a22:	66 a3 c8 f2 22 f0    	mov    %ax,0xf022f2c8
f0103a28:	66 c7 05 ca f2 22 f0 	movw   $0x8,0xf022f2ca
f0103a2f:	08 00 
f0103a31:	c6 05 cc f2 22 f0 00 	movb   $0x0,0xf022f2cc
f0103a38:	c6 05 cd f2 22 f0 8e 	movb   $0x8e,0xf022f2cd
f0103a3f:	c1 e8 10             	shr    $0x10,%eax
f0103a42:	66 a3 ce f2 22 f0    	mov    %ax,0xf022f2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103a48:	b8 d6 43 10 f0       	mov    $0xf01043d6,%eax
f0103a4d:	66 a3 d0 f2 22 f0    	mov    %ax,0xf022f2d0
f0103a53:	66 c7 05 d2 f2 22 f0 	movw   $0x8,0xf022f2d2
f0103a5a:	08 00 
f0103a5c:	c6 05 d4 f2 22 f0 00 	movb   $0x0,0xf022f2d4
f0103a63:	c6 05 d5 f2 22 f0 8e 	movb   $0x8e,0xf022f2d5
f0103a6a:	c1 e8 10             	shr    $0x10,%eax
f0103a6d:	66 a3 d6 f2 22 f0    	mov    %ax,0xf022f2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103a73:	b8 da 43 10 f0       	mov    $0xf01043da,%eax
f0103a78:	66 a3 e0 f2 22 f0    	mov    %ax,0xf022f2e0
f0103a7e:	66 c7 05 e2 f2 22 f0 	movw   $0x8,0xf022f2e2
f0103a85:	08 00 
f0103a87:	c6 05 e4 f2 22 f0 00 	movb   $0x0,0xf022f2e4
f0103a8e:	c6 05 e5 f2 22 f0 8e 	movb   $0x8e,0xf022f2e5
f0103a95:	c1 e8 10             	shr    $0x10,%eax
f0103a98:	66 a3 e6 f2 22 f0    	mov    %ax,0xf022f2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103a9e:	b8 e0 43 10 f0       	mov    $0xf01043e0,%eax
f0103aa3:	66 a3 e8 f2 22 f0    	mov    %ax,0xf022f2e8
f0103aa9:	66 c7 05 ea f2 22 f0 	movw   $0x8,0xf022f2ea
f0103ab0:	08 00 
f0103ab2:	c6 05 ec f2 22 f0 00 	movb   $0x0,0xf022f2ec
f0103ab9:	c6 05 ed f2 22 f0 8e 	movb   $0x8e,0xf022f2ed
f0103ac0:	c1 e8 10             	shr    $0x10,%eax
f0103ac3:	66 a3 ee f2 22 f0    	mov    %ax,0xf022f2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103ac9:	b8 e4 43 10 f0       	mov    $0xf01043e4,%eax
f0103ace:	66 a3 f0 f2 22 f0    	mov    %ax,0xf022f2f0
f0103ad4:	66 c7 05 f2 f2 22 f0 	movw   $0x8,0xf022f2f2
f0103adb:	08 00 
f0103add:	c6 05 f4 f2 22 f0 00 	movb   $0x0,0xf022f2f4
f0103ae4:	c6 05 f5 f2 22 f0 8e 	movb   $0x8e,0xf022f2f5
f0103aeb:	c1 e8 10             	shr    $0x10,%eax
f0103aee:	66 a3 f6 f2 22 f0    	mov    %ax,0xf022f2f6

	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103af4:	b8 ea 43 10 f0       	mov    $0xf01043ea,%eax
f0103af9:	66 a3 f8 f2 22 f0    	mov    %ax,0xf022f2f8
f0103aff:	66 c7 05 fa f2 22 f0 	movw   $0x8,0xf022f2fa
f0103b06:	08 00 
f0103b08:	c6 05 fc f2 22 f0 00 	movb   $0x0,0xf022f2fc
f0103b0f:	c6 05 fd f2 22 f0 8e 	movb   $0x8e,0xf022f2fd
f0103b16:	c1 e8 10             	shr    $0x10,%eax
f0103b19:	66 a3 fe f2 22 f0    	mov    %ax,0xf022f2fe


	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103b1f:	b8 f0 43 10 f0       	mov    $0xf01043f0,%eax
f0103b24:	66 a3 e0 f3 22 f0    	mov    %ax,0xf022f3e0
f0103b2a:	66 c7 05 e2 f3 22 f0 	movw   $0x8,0xf022f3e2
f0103b31:	08 00 
f0103b33:	c6 05 e4 f3 22 f0 00 	movb   $0x0,0xf022f3e4
f0103b3a:	c6 05 e5 f3 22 f0 ee 	movb   $0xee,0xf022f3e5
f0103b41:	c1 e8 10             	shr    $0x10,%eax
f0103b44:	66 a3 e6 f3 22 f0    	mov    %ax,0xf022f3e6

	SETGATE(idt[32], 0, GD_KT, irq0, 0);
f0103b4a:	b8 f6 43 10 f0       	mov    $0xf01043f6,%eax
f0103b4f:	66 a3 60 f3 22 f0    	mov    %ax,0xf022f360
f0103b55:	66 c7 05 62 f3 22 f0 	movw   $0x8,0xf022f362
f0103b5c:	08 00 
f0103b5e:	c6 05 64 f3 22 f0 00 	movb   $0x0,0xf022f364
f0103b65:	c6 05 65 f3 22 f0 8e 	movb   $0x8e,0xf022f365
f0103b6c:	c1 e8 10             	shr    $0x10,%eax
f0103b6f:	66 a3 66 f3 22 f0    	mov    %ax,0xf022f366
	SETGATE(idt[33], 0, GD_KT, irq1, 0);
f0103b75:	b8 fc 43 10 f0       	mov    $0xf01043fc,%eax
f0103b7a:	66 a3 68 f3 22 f0    	mov    %ax,0xf022f368
f0103b80:	66 c7 05 6a f3 22 f0 	movw   $0x8,0xf022f36a
f0103b87:	08 00 
f0103b89:	c6 05 6c f3 22 f0 00 	movb   $0x0,0xf022f36c
f0103b90:	c6 05 6d f3 22 f0 8e 	movb   $0x8e,0xf022f36d
f0103b97:	c1 e8 10             	shr    $0x10,%eax
f0103b9a:	66 a3 6e f3 22 f0    	mov    %ax,0xf022f36e
	SETGATE(idt[34], 0, GD_KT, irq2, 0);
f0103ba0:	b8 02 44 10 f0       	mov    $0xf0104402,%eax
f0103ba5:	66 a3 70 f3 22 f0    	mov    %ax,0xf022f370
f0103bab:	66 c7 05 72 f3 22 f0 	movw   $0x8,0xf022f372
f0103bb2:	08 00 
f0103bb4:	c6 05 74 f3 22 f0 00 	movb   $0x0,0xf022f374
f0103bbb:	c6 05 75 f3 22 f0 8e 	movb   $0x8e,0xf022f375
f0103bc2:	c1 e8 10             	shr    $0x10,%eax
f0103bc5:	66 a3 76 f3 22 f0    	mov    %ax,0xf022f376
	SETGATE(idt[35], 0, GD_KT, irq3, 0);
f0103bcb:	b8 08 44 10 f0       	mov    $0xf0104408,%eax
f0103bd0:	66 a3 78 f3 22 f0    	mov    %ax,0xf022f378
f0103bd6:	66 c7 05 7a f3 22 f0 	movw   $0x8,0xf022f37a
f0103bdd:	08 00 
f0103bdf:	c6 05 7c f3 22 f0 00 	movb   $0x0,0xf022f37c
f0103be6:	c6 05 7d f3 22 f0 8e 	movb   $0x8e,0xf022f37d
f0103bed:	c1 e8 10             	shr    $0x10,%eax
f0103bf0:	66 a3 7e f3 22 f0    	mov    %ax,0xf022f37e
	SETGATE(idt[36], 0, GD_KT, irq4, 0);
f0103bf6:	b8 0e 44 10 f0       	mov    $0xf010440e,%eax
f0103bfb:	66 a3 80 f3 22 f0    	mov    %ax,0xf022f380
f0103c01:	66 c7 05 82 f3 22 f0 	movw   $0x8,0xf022f382
f0103c08:	08 00 
f0103c0a:	c6 05 84 f3 22 f0 00 	movb   $0x0,0xf022f384
f0103c11:	c6 05 85 f3 22 f0 8e 	movb   $0x8e,0xf022f385
f0103c18:	c1 e8 10             	shr    $0x10,%eax
f0103c1b:	66 a3 86 f3 22 f0    	mov    %ax,0xf022f386
	SETGATE(idt[37], 0, GD_KT, irq5, 0);
f0103c21:	b8 14 44 10 f0       	mov    $0xf0104414,%eax
f0103c26:	66 a3 88 f3 22 f0    	mov    %ax,0xf022f388
f0103c2c:	66 c7 05 8a f3 22 f0 	movw   $0x8,0xf022f38a
f0103c33:	08 00 
f0103c35:	c6 05 8c f3 22 f0 00 	movb   $0x0,0xf022f38c
f0103c3c:	c6 05 8d f3 22 f0 8e 	movb   $0x8e,0xf022f38d
f0103c43:	c1 e8 10             	shr    $0x10,%eax
f0103c46:	66 a3 8e f3 22 f0    	mov    %ax,0xf022f38e
	SETGATE(idt[38], 0, GD_KT, irq6, 0);
f0103c4c:	b8 1a 44 10 f0       	mov    $0xf010441a,%eax
f0103c51:	66 a3 90 f3 22 f0    	mov    %ax,0xf022f390
f0103c57:	66 c7 05 92 f3 22 f0 	movw   $0x8,0xf022f392
f0103c5e:	08 00 
f0103c60:	c6 05 94 f3 22 f0 00 	movb   $0x0,0xf022f394
f0103c67:	c6 05 95 f3 22 f0 8e 	movb   $0x8e,0xf022f395
f0103c6e:	c1 e8 10             	shr    $0x10,%eax
f0103c71:	66 a3 96 f3 22 f0    	mov    %ax,0xf022f396
	SETGATE(idt[39], 0, GD_KT, irq7, 0);
f0103c77:	b8 20 44 10 f0       	mov    $0xf0104420,%eax
f0103c7c:	66 a3 98 f3 22 f0    	mov    %ax,0xf022f398
f0103c82:	66 c7 05 9a f3 22 f0 	movw   $0x8,0xf022f39a
f0103c89:	08 00 
f0103c8b:	c6 05 9c f3 22 f0 00 	movb   $0x0,0xf022f39c
f0103c92:	c6 05 9d f3 22 f0 8e 	movb   $0x8e,0xf022f39d
f0103c99:	c1 e8 10             	shr    $0x10,%eax
f0103c9c:	66 a3 9e f3 22 f0    	mov    %ax,0xf022f39e
	SETGATE(idt[40], 0, GD_KT, irq8, 0);
f0103ca2:	b8 26 44 10 f0       	mov    $0xf0104426,%eax
f0103ca7:	66 a3 a0 f3 22 f0    	mov    %ax,0xf022f3a0
f0103cad:	66 c7 05 a2 f3 22 f0 	movw   $0x8,0xf022f3a2
f0103cb4:	08 00 
f0103cb6:	c6 05 a4 f3 22 f0 00 	movb   $0x0,0xf022f3a4
f0103cbd:	c6 05 a5 f3 22 f0 8e 	movb   $0x8e,0xf022f3a5
f0103cc4:	c1 e8 10             	shr    $0x10,%eax
f0103cc7:	66 a3 a6 f3 22 f0    	mov    %ax,0xf022f3a6
	SETGATE(idt[41], 0, GD_KT, irq9, 0);
f0103ccd:	b8 2c 44 10 f0       	mov    $0xf010442c,%eax
f0103cd2:	66 a3 a8 f3 22 f0    	mov    %ax,0xf022f3a8
f0103cd8:	66 c7 05 aa f3 22 f0 	movw   $0x8,0xf022f3aa
f0103cdf:	08 00 
f0103ce1:	c6 05 ac f3 22 f0 00 	movb   $0x0,0xf022f3ac
f0103ce8:	c6 05 ad f3 22 f0 8e 	movb   $0x8e,0xf022f3ad
f0103cef:	c1 e8 10             	shr    $0x10,%eax
f0103cf2:	66 a3 ae f3 22 f0    	mov    %ax,0xf022f3ae
	SETGATE(idt[42], 0, GD_KT, irq10, 0);
f0103cf8:	b8 32 44 10 f0       	mov    $0xf0104432,%eax
f0103cfd:	66 a3 b0 f3 22 f0    	mov    %ax,0xf022f3b0
f0103d03:	66 c7 05 b2 f3 22 f0 	movw   $0x8,0xf022f3b2
f0103d0a:	08 00 
f0103d0c:	c6 05 b4 f3 22 f0 00 	movb   $0x0,0xf022f3b4
f0103d13:	c6 05 b5 f3 22 f0 8e 	movb   $0x8e,0xf022f3b5
f0103d1a:	c1 e8 10             	shr    $0x10,%eax
f0103d1d:	66 a3 b6 f3 22 f0    	mov    %ax,0xf022f3b6
	SETGATE(idt[43], 0, GD_KT, irq11, 0);
f0103d23:	b8 38 44 10 f0       	mov    $0xf0104438,%eax
f0103d28:	66 a3 b8 f3 22 f0    	mov    %ax,0xf022f3b8
f0103d2e:	66 c7 05 ba f3 22 f0 	movw   $0x8,0xf022f3ba
f0103d35:	08 00 
f0103d37:	c6 05 bc f3 22 f0 00 	movb   $0x0,0xf022f3bc
f0103d3e:	c6 05 bd f3 22 f0 8e 	movb   $0x8e,0xf022f3bd
f0103d45:	c1 e8 10             	shr    $0x10,%eax
f0103d48:	66 a3 be f3 22 f0    	mov    %ax,0xf022f3be
	SETGATE(idt[44], 0, GD_KT, irq12, 0);
f0103d4e:	b8 3e 44 10 f0       	mov    $0xf010443e,%eax
f0103d53:	66 a3 c0 f3 22 f0    	mov    %ax,0xf022f3c0
f0103d59:	66 c7 05 c2 f3 22 f0 	movw   $0x8,0xf022f3c2
f0103d60:	08 00 
f0103d62:	c6 05 c4 f3 22 f0 00 	movb   $0x0,0xf022f3c4
f0103d69:	c6 05 c5 f3 22 f0 8e 	movb   $0x8e,0xf022f3c5
f0103d70:	c1 e8 10             	shr    $0x10,%eax
f0103d73:	66 a3 c6 f3 22 f0    	mov    %ax,0xf022f3c6
	SETGATE(idt[45], 0, GD_KT, irq13, 0);
f0103d79:	b8 44 44 10 f0       	mov    $0xf0104444,%eax
f0103d7e:	66 a3 c8 f3 22 f0    	mov    %ax,0xf022f3c8
f0103d84:	66 c7 05 ca f3 22 f0 	movw   $0x8,0xf022f3ca
f0103d8b:	08 00 
f0103d8d:	c6 05 cc f3 22 f0 00 	movb   $0x0,0xf022f3cc
f0103d94:	c6 05 cd f3 22 f0 8e 	movb   $0x8e,0xf022f3cd
f0103d9b:	c1 e8 10             	shr    $0x10,%eax
f0103d9e:	66 a3 ce f3 22 f0    	mov    %ax,0xf022f3ce
	SETGATE(idt[46], 0, GD_KT, irq14, 0);
f0103da4:	b8 4a 44 10 f0       	mov    $0xf010444a,%eax
f0103da9:	66 a3 d0 f3 22 f0    	mov    %ax,0xf022f3d0
f0103daf:	66 c7 05 d2 f3 22 f0 	movw   $0x8,0xf022f3d2
f0103db6:	08 00 
f0103db8:	c6 05 d4 f3 22 f0 00 	movb   $0x0,0xf022f3d4
f0103dbf:	c6 05 d5 f3 22 f0 8e 	movb   $0x8e,0xf022f3d5
f0103dc6:	c1 e8 10             	shr    $0x10,%eax
f0103dc9:	66 a3 d6 f3 22 f0    	mov    %ax,0xf022f3d6
	SETGATE(idt[47], 0, GD_KT, irq15, 0);
f0103dcf:	b8 50 44 10 f0       	mov    $0xf0104450,%eax
f0103dd4:	66 a3 d8 f3 22 f0    	mov    %ax,0xf022f3d8
f0103dda:	66 c7 05 da f3 22 f0 	movw   $0x8,0xf022f3da
f0103de1:	08 00 
f0103de3:	c6 05 dc f3 22 f0 00 	movb   $0x0,0xf022f3dc
f0103dea:	c6 05 dd f3 22 f0 8e 	movb   $0x8e,0xf022f3dd
f0103df1:	c1 e8 10             	shr    $0x10,%eax
f0103df4:	66 a3 de f3 22 f0    	mov    %ax,0xf022f3de


	

	// Per-CPU setup 
	trap_init_percpu();
f0103dfa:	e8 1d f9 ff ff       	call   f010371c <trap_init_percpu>
}
f0103dff:	c9                   	leave  
f0103e00:	c3                   	ret    

f0103e01 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e01:	55                   	push   %ebp
f0103e02:	89 e5                	mov    %esp,%ebp
f0103e04:	53                   	push   %ebx
f0103e05:	83 ec 0c             	sub    $0xc,%esp
f0103e08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e0b:	ff 33                	pushl  (%ebx)
f0103e0d:	68 74 76 10 f0       	push   $0xf0107674
f0103e12:	e8 f1 f8 ff ff       	call   f0103708 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e17:	83 c4 08             	add    $0x8,%esp
f0103e1a:	ff 73 04             	pushl  0x4(%ebx)
f0103e1d:	68 83 76 10 f0       	push   $0xf0107683
f0103e22:	e8 e1 f8 ff ff       	call   f0103708 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e27:	83 c4 08             	add    $0x8,%esp
f0103e2a:	ff 73 08             	pushl  0x8(%ebx)
f0103e2d:	68 92 76 10 f0       	push   $0xf0107692
f0103e32:	e8 d1 f8 ff ff       	call   f0103708 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e37:	83 c4 08             	add    $0x8,%esp
f0103e3a:	ff 73 0c             	pushl  0xc(%ebx)
f0103e3d:	68 a1 76 10 f0       	push   $0xf01076a1
f0103e42:	e8 c1 f8 ff ff       	call   f0103708 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e47:	83 c4 08             	add    $0x8,%esp
f0103e4a:	ff 73 10             	pushl  0x10(%ebx)
f0103e4d:	68 b0 76 10 f0       	push   $0xf01076b0
f0103e52:	e8 b1 f8 ff ff       	call   f0103708 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e57:	83 c4 08             	add    $0x8,%esp
f0103e5a:	ff 73 14             	pushl  0x14(%ebx)
f0103e5d:	68 bf 76 10 f0       	push   $0xf01076bf
f0103e62:	e8 a1 f8 ff ff       	call   f0103708 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e67:	83 c4 08             	add    $0x8,%esp
f0103e6a:	ff 73 18             	pushl  0x18(%ebx)
f0103e6d:	68 ce 76 10 f0       	push   $0xf01076ce
f0103e72:	e8 91 f8 ff ff       	call   f0103708 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e77:	83 c4 08             	add    $0x8,%esp
f0103e7a:	ff 73 1c             	pushl  0x1c(%ebx)
f0103e7d:	68 dd 76 10 f0       	push   $0xf01076dd
f0103e82:	e8 81 f8 ff ff       	call   f0103708 <cprintf>
}
f0103e87:	83 c4 10             	add    $0x10,%esp
f0103e8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e8d:	c9                   	leave  
f0103e8e:	c3                   	ret    

f0103e8f <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103e8f:	55                   	push   %ebp
f0103e90:	89 e5                	mov    %esp,%ebp
f0103e92:	56                   	push   %esi
f0103e93:	53                   	push   %ebx
f0103e94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e97:	e8 72 1e 00 00       	call   f0105d0e <cpunum>
f0103e9c:	83 ec 04             	sub    $0x4,%esp
f0103e9f:	50                   	push   %eax
f0103ea0:	53                   	push   %ebx
f0103ea1:	68 41 77 10 f0       	push   $0xf0107741
f0103ea6:	e8 5d f8 ff ff       	call   f0103708 <cprintf>
	print_regs(&tf->tf_regs);
f0103eab:	89 1c 24             	mov    %ebx,(%esp)
f0103eae:	e8 4e ff ff ff       	call   f0103e01 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103eb3:	83 c4 08             	add    $0x8,%esp
f0103eb6:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103eba:	50                   	push   %eax
f0103ebb:	68 5f 77 10 f0       	push   $0xf010775f
f0103ec0:	e8 43 f8 ff ff       	call   f0103708 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ec5:	83 c4 08             	add    $0x8,%esp
f0103ec8:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ecc:	50                   	push   %eax
f0103ecd:	68 72 77 10 f0       	push   $0xf0107772
f0103ed2:	e8 31 f8 ff ff       	call   f0103708 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ed7:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103eda:	83 c4 10             	add    $0x10,%esp
f0103edd:	83 f8 13             	cmp    $0x13,%eax
f0103ee0:	77 09                	ja     f0103eeb <print_trapframe+0x5c>
		return excnames[trapno];
f0103ee2:	8b 14 85 00 7a 10 f0 	mov    -0xfef8600(,%eax,4),%edx
f0103ee9:	eb 1f                	jmp    f0103f0a <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103eeb:	83 f8 30             	cmp    $0x30,%eax
f0103eee:	74 15                	je     f0103f05 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103ef0:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103ef3:	83 fa 10             	cmp    $0x10,%edx
f0103ef6:	b9 0b 77 10 f0       	mov    $0xf010770b,%ecx
f0103efb:	ba f8 76 10 f0       	mov    $0xf01076f8,%edx
f0103f00:	0f 43 d1             	cmovae %ecx,%edx
f0103f03:	eb 05                	jmp    f0103f0a <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103f05:	ba ec 76 10 f0       	mov    $0xf01076ec,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f0a:	83 ec 04             	sub    $0x4,%esp
f0103f0d:	52                   	push   %edx
f0103f0e:	50                   	push   %eax
f0103f0f:	68 85 77 10 f0       	push   $0xf0107785
f0103f14:	e8 ef f7 ff ff       	call   f0103708 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f19:	83 c4 10             	add    $0x10,%esp
f0103f1c:	3b 1d 60 fa 22 f0    	cmp    0xf022fa60,%ebx
f0103f22:	75 1a                	jne    f0103f3e <print_trapframe+0xaf>
f0103f24:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f28:	75 14                	jne    f0103f3e <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103f2a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f2d:	83 ec 08             	sub    $0x8,%esp
f0103f30:	50                   	push   %eax
f0103f31:	68 97 77 10 f0       	push   $0xf0107797
f0103f36:	e8 cd f7 ff ff       	call   f0103708 <cprintf>
f0103f3b:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103f3e:	83 ec 08             	sub    $0x8,%esp
f0103f41:	ff 73 2c             	pushl  0x2c(%ebx)
f0103f44:	68 a6 77 10 f0       	push   $0xf01077a6
f0103f49:	e8 ba f7 ff ff       	call   f0103708 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103f4e:	83 c4 10             	add    $0x10,%esp
f0103f51:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f55:	75 49                	jne    f0103fa0 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f57:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103f5a:	89 c2                	mov    %eax,%edx
f0103f5c:	83 e2 01             	and    $0x1,%edx
f0103f5f:	ba 25 77 10 f0       	mov    $0xf0107725,%edx
f0103f64:	b9 1a 77 10 f0       	mov    $0xf010771a,%ecx
f0103f69:	0f 44 ca             	cmove  %edx,%ecx
f0103f6c:	89 c2                	mov    %eax,%edx
f0103f6e:	83 e2 02             	and    $0x2,%edx
f0103f71:	ba 37 77 10 f0       	mov    $0xf0107737,%edx
f0103f76:	be 31 77 10 f0       	mov    $0xf0107731,%esi
f0103f7b:	0f 45 d6             	cmovne %esi,%edx
f0103f7e:	83 e0 04             	and    $0x4,%eax
f0103f81:	be 84 78 10 f0       	mov    $0xf0107884,%esi
f0103f86:	b8 3c 77 10 f0       	mov    $0xf010773c,%eax
f0103f8b:	0f 44 c6             	cmove  %esi,%eax
f0103f8e:	51                   	push   %ecx
f0103f8f:	52                   	push   %edx
f0103f90:	50                   	push   %eax
f0103f91:	68 b4 77 10 f0       	push   $0xf01077b4
f0103f96:	e8 6d f7 ff ff       	call   f0103708 <cprintf>
f0103f9b:	83 c4 10             	add    $0x10,%esp
f0103f9e:	eb 10                	jmp    f0103fb0 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103fa0:	83 ec 0c             	sub    $0xc,%esp
f0103fa3:	68 6a 6c 10 f0       	push   $0xf0106c6a
f0103fa8:	e8 5b f7 ff ff       	call   f0103708 <cprintf>
f0103fad:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fb0:	83 ec 08             	sub    $0x8,%esp
f0103fb3:	ff 73 30             	pushl  0x30(%ebx)
f0103fb6:	68 c3 77 10 f0       	push   $0xf01077c3
f0103fbb:	e8 48 f7 ff ff       	call   f0103708 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fc0:	83 c4 08             	add    $0x8,%esp
f0103fc3:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103fc7:	50                   	push   %eax
f0103fc8:	68 d2 77 10 f0       	push   $0xf01077d2
f0103fcd:	e8 36 f7 ff ff       	call   f0103708 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103fd2:	83 c4 08             	add    $0x8,%esp
f0103fd5:	ff 73 38             	pushl  0x38(%ebx)
f0103fd8:	68 e5 77 10 f0       	push   $0xf01077e5
f0103fdd:	e8 26 f7 ff ff       	call   f0103708 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103fe2:	83 c4 10             	add    $0x10,%esp
f0103fe5:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fe9:	74 25                	je     f0104010 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103feb:	83 ec 08             	sub    $0x8,%esp
f0103fee:	ff 73 3c             	pushl  0x3c(%ebx)
f0103ff1:	68 f4 77 10 f0       	push   $0xf01077f4
f0103ff6:	e8 0d f7 ff ff       	call   f0103708 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ffb:	83 c4 08             	add    $0x8,%esp
f0103ffe:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104002:	50                   	push   %eax
f0104003:	68 03 78 10 f0       	push   $0xf0107803
f0104008:	e8 fb f6 ff ff       	call   f0103708 <cprintf>
f010400d:	83 c4 10             	add    $0x10,%esp
	}
}
f0104010:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104013:	5b                   	pop    %ebx
f0104014:	5e                   	pop    %esi
f0104015:	5d                   	pop    %ebp
f0104016:	c3                   	ret    

f0104017 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104017:	55                   	push   %ebp
f0104018:	89 e5                	mov    %esp,%ebp
f010401a:	57                   	push   %edi
f010401b:	56                   	push   %esi
f010401c:	53                   	push   %ebx
f010401d:	83 ec 1c             	sub    $0x1c,%esp
f0104020:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104023:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	if (tf->tf_cs == GD_KT)
f0104026:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010402b:	75 20                	jne    f010404d <page_fault_handler+0x36>
	{
		print_trapframe(tf);
f010402d:	83 ec 0c             	sub    $0xc,%esp
f0104030:	53                   	push   %ebx
f0104031:	e8 59 fe ff ff       	call   f0103e8f <print_trapframe>
		panic ("Kernel page fault!");
f0104036:	83 c4 0c             	add    $0xc,%esp
f0104039:	68 16 78 10 f0       	push   $0xf0107816
f010403e:	68 84 01 00 00       	push   $0x184
f0104043:	68 29 78 10 f0       	push   $0xf0107829
f0104048:	e8 f3 bf ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	if (curenv->env_pgfault_upcall)
f010404d:	e8 bc 1c 00 00       	call   f0105d0e <cpunum>
f0104052:	6b c0 74             	imul   $0x74,%eax,%eax
f0104055:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010405b:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010405f:	0f 84 93 00 00 00    	je     f01040f8 <page_fault_handler+0xe1>
	{
		uintptr_t cur_uxtop;
		struct UTrapframe *utf;

		if (tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP)
f0104065:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104068:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			cur_uxtop = tf->tf_esp - 4;
f010406e:	83 e8 04             	sub    $0x4,%eax
f0104071:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104077:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f010407c:	0f 46 f8             	cmovbe %eax,%edi
		else
			cur_uxtop = UXSTACKTOP;

		utf = (struct UTrapframe *) (cur_uxtop - (sizeof(struct UTrapframe)));
f010407f:	8d 47 cc             	lea    -0x34(%edi),%eax
f0104082:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		user_mem_assert(curenv, utf, (sizeof(struct UTrapframe)), PTE_U | PTE_W);
f0104085:	e8 84 1c 00 00       	call   f0105d0e <cpunum>
f010408a:	6a 06                	push   $0x6
f010408c:	6a 34                	push   $0x34
f010408e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104091:	6b c0 74             	imul   $0x74,%eax,%eax
f0104094:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f010409a:	e8 ae ec ff ff       	call   f0102d4d <user_mem_assert>

		utf->utf_fault_va = fault_va;
f010409f:	89 77 cc             	mov    %esi,-0x34(%edi)
		utf->utf_err = tf->tf_err;
f01040a2:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01040a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01040a8:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_regs = tf->tf_regs;
f01040ab:	83 ef 2c             	sub    $0x2c,%edi
f01040ae:	b9 08 00 00 00       	mov    $0x8,%ecx
f01040b3:	89 de                	mov    %ebx,%esi
f01040b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f01040b7:	8b 43 30             	mov    0x30(%ebx),%eax
f01040ba:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01040bd:	8b 43 38             	mov    0x38(%ebx),%eax
f01040c0:	89 d6                	mov    %edx,%esi
f01040c2:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01040c5:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01040c8:	89 42 30             	mov    %eax,0x30(%edx)

		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f01040cb:	e8 3e 1c 00 00       	call   f0105d0e <cpunum>
f01040d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01040d3:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01040d9:	8b 40 64             	mov    0x64(%eax),%eax
f01040dc:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uintptr_t) utf;
f01040df:	89 73 3c             	mov    %esi,0x3c(%ebx)

		env_run (curenv);
f01040e2:	e8 27 1c 00 00       	call   f0105d0e <cpunum>
f01040e7:	83 c4 04             	add    $0x4,%esp
f01040ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ed:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01040f3:	e8 ae f3 ff ff       	call   f01034a6 <env_run>
	}



	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040f8:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01040fb:	e8 0e 1c 00 00       	call   f0105d0e <cpunum>
	}



	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104100:	57                   	push   %edi
f0104101:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104102:	6b c0 74             	imul   $0x74,%eax,%eax
	}



	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104105:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010410b:	ff 70 48             	pushl  0x48(%eax)
f010410e:	68 d0 79 10 f0       	push   $0xf01079d0
f0104113:	e8 f0 f5 ff ff       	call   f0103708 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104118:	89 1c 24             	mov    %ebx,(%esp)
f010411b:	e8 6f fd ff ff       	call   f0103e8f <print_trapframe>
	env_destroy(curenv);
f0104120:	e8 e9 1b 00 00       	call   f0105d0e <cpunum>
f0104125:	83 c4 04             	add    $0x4,%esp
f0104128:	6b c0 74             	imul   $0x74,%eax,%eax
f010412b:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104131:	e8 d1 f2 ff ff       	call   f0103407 <env_destroy>
f0104136:	83 c4 10             	add    $0x10,%esp
f0104139:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010413c:	5b                   	pop    %ebx
f010413d:	5e                   	pop    %esi
f010413e:	5f                   	pop    %edi
f010413f:	5d                   	pop    %ebp
f0104140:	c3                   	ret    

f0104141 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104141:	55                   	push   %ebp
f0104142:	89 e5                	mov    %esp,%ebp
f0104144:	57                   	push   %edi
f0104145:	56                   	push   %esi
f0104146:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104149:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f010414a:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f0104151:	74 01                	je     f0104154 <trap+0x13>
		asm volatile("hlt");
f0104153:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104154:	e8 b5 1b 00 00       	call   f0105d0e <cpunum>
f0104159:	6b d0 74             	imul   $0x74,%eax,%edx
f010415c:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104162:	b8 01 00 00 00       	mov    $0x1,%eax
f0104167:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010416b:	83 f8 02             	cmp    $0x2,%eax
f010416e:	75 10                	jne    f0104180 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104170:	83 ec 0c             	sub    $0xc,%esp
f0104173:	68 c0 03 12 f0       	push   $0xf01203c0
f0104178:	e8 ff 1d 00 00       	call   f0105f7c <spin_lock>
f010417d:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104180:	9c                   	pushf  
f0104181:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104182:	f6 c4 02             	test   $0x2,%ah
f0104185:	74 19                	je     f01041a0 <trap+0x5f>
f0104187:	68 35 78 10 f0       	push   $0xf0107835
f010418c:	68 68 69 10 f0       	push   $0xf0106968
f0104191:	68 4a 01 00 00       	push   $0x14a
f0104196:	68 29 78 10 f0       	push   $0xf0107829
f010419b:	e8 a0 be ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01041a0:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041a4:	83 e0 03             	and    $0x3,%eax
f01041a7:	66 83 f8 03          	cmp    $0x3,%ax
f01041ab:	0f 85 a0 00 00 00    	jne    f0104251 <trap+0x110>
f01041b1:	83 ec 0c             	sub    $0xc,%esp
f01041b4:	68 c0 03 12 f0       	push   $0xf01203c0
f01041b9:	e8 be 1d 00 00       	call   f0105f7c <spin_lock>
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.

		lock_kernel();
		assert(curenv);
f01041be:	e8 4b 1b 00 00       	call   f0105d0e <cpunum>
f01041c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c6:	83 c4 10             	add    $0x10,%esp
f01041c9:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01041d0:	75 19                	jne    f01041eb <trap+0xaa>
f01041d2:	68 4e 78 10 f0       	push   $0xf010784e
f01041d7:	68 68 69 10 f0       	push   $0xf0106968
f01041dc:	68 53 01 00 00       	push   $0x153
f01041e1:	68 29 78 10 f0       	push   $0xf0107829
f01041e6:	e8 55 be ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01041eb:	e8 1e 1b 00 00       	call   f0105d0e <cpunum>
f01041f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01041f3:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01041f9:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01041fd:	75 2d                	jne    f010422c <trap+0xeb>
			env_free(curenv);
f01041ff:	e8 0a 1b 00 00       	call   f0105d0e <cpunum>
f0104204:	83 ec 0c             	sub    $0xc,%esp
f0104207:	6b c0 74             	imul   $0x74,%eax,%eax
f010420a:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104210:	e8 17 f0 ff ff       	call   f010322c <env_free>
			curenv = NULL;
f0104215:	e8 f4 1a 00 00       	call   f0105d0e <cpunum>
f010421a:	6b c0 74             	imul   $0x74,%eax,%eax
f010421d:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f0104224:	00 00 00 
			sched_yield();
f0104227:	e8 10 03 00 00       	call   f010453c <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010422c:	e8 dd 1a 00 00       	call   f0105d0e <cpunum>
f0104231:	6b c0 74             	imul   $0x74,%eax,%eax
f0104234:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010423a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010423f:	89 c7                	mov    %eax,%edi
f0104241:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104243:	e8 c6 1a 00 00       	call   f0105d0e <cpunum>
f0104248:	6b c0 74             	imul   $0x74,%eax,%eax
f010424b:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104251:	89 35 60 fa 22 f0    	mov    %esi,0xf022fa60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	if(tf->tf_trapno == T_PGFLT){
f0104257:	8b 46 28             	mov    0x28(%esi),%eax
f010425a:	83 f8 0e             	cmp    $0xe,%eax
f010425d:	75 11                	jne    f0104270 <trap+0x12f>
		page_fault_handler(tf);
f010425f:	83 ec 0c             	sub    $0xc,%esp
f0104262:	56                   	push   %esi
f0104263:	e8 af fd ff ff       	call   f0104017 <page_fault_handler>
f0104268:	83 c4 10             	add    $0x10,%esp
f010426b:	e9 ad 00 00 00       	jmp    f010431d <trap+0x1dc>
		return;
	}
	if (tf->tf_trapno == T_BRKPT)
f0104270:	83 f8 03             	cmp    $0x3,%eax
f0104273:	75 11                	jne    f0104286 <trap+0x145>
	{
		monitor (tf);
f0104275:	83 ec 0c             	sub    $0xc,%esp
f0104278:	56                   	push   %esi
f0104279:	e8 b3 c6 ff ff       	call   f0100931 <monitor>
f010427e:	83 c4 10             	add    $0x10,%esp
f0104281:	e9 97 00 00 00       	jmp    f010431d <trap+0x1dc>
		return;
	}

	if (tf->tf_trapno == T_SYSCALL)
f0104286:	83 f8 30             	cmp    $0x30,%eax
f0104289:	75 21                	jne    f01042ac <trap+0x16b>
	{
		if((tf->tf_regs.reg_eax = syscall (tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f010428b:	83 ec 08             	sub    $0x8,%esp
f010428e:	ff 76 04             	pushl  0x4(%esi)
f0104291:	ff 36                	pushl  (%esi)
f0104293:	ff 76 10             	pushl  0x10(%esi)
f0104296:	ff 76 18             	pushl  0x18(%esi)
f0104299:	ff 76 14             	pushl  0x14(%esi)
f010429c:	ff 76 1c             	pushl  0x1c(%esi)
f010429f:	e8 41 03 00 00       	call   f01045e5 <syscall>
f01042a4:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042a7:	83 c4 20             	add    $0x20,%esp
f01042aa:	eb 71                	jmp    f010431d <trap+0x1dc>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01042ac:	83 f8 27             	cmp    $0x27,%eax
f01042af:	75 1a                	jne    f01042cb <trap+0x18a>
		cprintf("Spurious interrupt on irq 7\n");
f01042b1:	83 ec 0c             	sub    $0xc,%esp
f01042b4:	68 55 78 10 f0       	push   $0xf0107855
f01042b9:	e8 4a f4 ff ff       	call   f0103708 <cprintf>
		print_trapframe(tf);
f01042be:	89 34 24             	mov    %esi,(%esp)
f01042c1:	e8 c9 fb ff ff       	call   f0103e8f <print_trapframe>
f01042c6:	83 c4 10             	add    $0x10,%esp
f01042c9:	eb 52                	jmp    f010431d <trap+0x1dc>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f01042cb:	83 f8 20             	cmp    $0x20,%eax
f01042ce:	75 0a                	jne    f01042da <trap+0x199>
	{
		lapic_eoi();
f01042d0:	e8 84 1b 00 00       	call   f0105e59 <lapic_eoi>
        sched_yield();
f01042d5:	e8 62 02 00 00       	call   f010453c <sched_yield>
	}



	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01042da:	83 ec 0c             	sub    $0xc,%esp
f01042dd:	56                   	push   %esi
f01042de:	e8 ac fb ff ff       	call   f0103e8f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01042e3:	83 c4 10             	add    $0x10,%esp
f01042e6:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01042eb:	75 17                	jne    f0104304 <trap+0x1c3>
		panic("unhandled trap in kernel");
f01042ed:	83 ec 04             	sub    $0x4,%esp
f01042f0:	68 72 78 10 f0       	push   $0xf0107872
f01042f5:	68 30 01 00 00       	push   $0x130
f01042fa:	68 29 78 10 f0       	push   $0xf0107829
f01042ff:	e8 3c bd ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104304:	e8 05 1a 00 00       	call   f0105d0e <cpunum>
f0104309:	83 ec 0c             	sub    $0xc,%esp
f010430c:	6b c0 74             	imul   $0x74,%eax,%eax
f010430f:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104315:	e8 ed f0 ff ff       	call   f0103407 <env_destroy>
f010431a:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010431d:	e8 ec 19 00 00       	call   f0105d0e <cpunum>
f0104322:	6b c0 74             	imul   $0x74,%eax,%eax
f0104325:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010432c:	74 2a                	je     f0104358 <trap+0x217>
f010432e:	e8 db 19 00 00       	call   f0105d0e <cpunum>
f0104333:	6b c0 74             	imul   $0x74,%eax,%eax
f0104336:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010433c:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104340:	75 16                	jne    f0104358 <trap+0x217>
		env_run(curenv);
f0104342:	e8 c7 19 00 00       	call   f0105d0e <cpunum>
f0104347:	83 ec 0c             	sub    $0xc,%esp
f010434a:	6b c0 74             	imul   $0x74,%eax,%eax
f010434d:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104353:	e8 4e f1 ff ff       	call   f01034a6 <env_run>
	else
		sched_yield();
f0104358:	e8 df 01 00 00       	call   f010453c <sched_yield>
f010435d:	90                   	nop

f010435e <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f010435e:	6a 00                	push   $0x0
f0104360:	6a 00                	push   $0x0
f0104362:	e9 ef 00 00 00       	jmp    f0104456 <_alltraps>
f0104367:	90                   	nop

f0104368 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104368:	6a 00                	push   $0x0
f010436a:	6a 01                	push   $0x1
f010436c:	e9 e5 00 00 00       	jmp    f0104456 <_alltraps>
f0104371:	90                   	nop

f0104372 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104372:	6a 00                	push   $0x0
f0104374:	6a 02                	push   $0x2
f0104376:	e9 db 00 00 00       	jmp    f0104456 <_alltraps>
f010437b:	90                   	nop

f010437c <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f010437c:	6a 00                	push   $0x0
f010437e:	6a 03                	push   $0x3
f0104380:	e9 d1 00 00 00       	jmp    f0104456 <_alltraps>
f0104385:	90                   	nop

f0104386 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0104386:	6a 00                	push   $0x0
f0104388:	6a 04                	push   $0x4
f010438a:	e9 c7 00 00 00       	jmp    f0104456 <_alltraps>
f010438f:	90                   	nop

f0104390 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0104390:	6a 00                	push   $0x0
f0104392:	6a 05                	push   $0x5
f0104394:	e9 bd 00 00 00       	jmp    f0104456 <_alltraps>
f0104399:	90                   	nop

f010439a <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f010439a:	6a 00                	push   $0x0
f010439c:	6a 06                	push   $0x6
f010439e:	e9 b3 00 00 00       	jmp    f0104456 <_alltraps>
f01043a3:	90                   	nop

f01043a4 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f01043a4:	6a 00                	push   $0x0
f01043a6:	6a 07                	push   $0x7
f01043a8:	e9 a9 00 00 00       	jmp    f0104456 <_alltraps>
f01043ad:	90                   	nop

f01043ae <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f01043ae:	6a 08                	push   $0x8
f01043b0:	e9 a1 00 00 00       	jmp    f0104456 <_alltraps>
f01043b5:	90                   	nop

f01043b6 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f01043b6:	6a 0a                	push   $0xa
f01043b8:	e9 99 00 00 00       	jmp    f0104456 <_alltraps>
f01043bd:	90                   	nop

f01043be <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f01043be:	6a 0b                	push   $0xb
f01043c0:	e9 91 00 00 00       	jmp    f0104456 <_alltraps>
f01043c5:	90                   	nop

f01043c6 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f01043c6:	6a 0c                	push   $0xc
f01043c8:	e9 89 00 00 00       	jmp    f0104456 <_alltraps>
f01043cd:	90                   	nop

f01043ce <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f01043ce:	6a 0d                	push   $0xd
f01043d0:	e9 81 00 00 00       	jmp    f0104456 <_alltraps>
f01043d5:	90                   	nop

f01043d6 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f01043d6:	6a 0e                	push   $0xe
f01043d8:	eb 7c                	jmp    f0104456 <_alltraps>

f01043da <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f01043da:	6a 00                	push   $0x0
f01043dc:	6a 10                	push   $0x10
f01043de:	eb 76                	jmp    f0104456 <_alltraps>

f01043e0 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f01043e0:	6a 11                	push   $0x11
f01043e2:	eb 72                	jmp    f0104456 <_alltraps>

f01043e4 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f01043e4:	6a 00                	push   $0x0
f01043e6:	6a 12                	push   $0x12
f01043e8:	eb 6c                	jmp    f0104456 <_alltraps>

f01043ea <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f01043ea:	6a 00                	push   $0x0
f01043ec:	6a 13                	push   $0x13
f01043ee:	eb 66                	jmp    f0104456 <_alltraps>

f01043f0 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f01043f0:	6a 00                	push   $0x0
f01043f2:	6a 30                	push   $0x30
f01043f4:	eb 60                	jmp    f0104456 <_alltraps>

f01043f6 <irq0>:

TRAPHANDLER_NOEC(irq0, 32)
f01043f6:	6a 00                	push   $0x0
f01043f8:	6a 20                	push   $0x20
f01043fa:	eb 5a                	jmp    f0104456 <_alltraps>

f01043fc <irq1>:
TRAPHANDLER_NOEC(irq1, 33)
f01043fc:	6a 00                	push   $0x0
f01043fe:	6a 21                	push   $0x21
f0104400:	eb 54                	jmp    f0104456 <_alltraps>

f0104402 <irq2>:
TRAPHANDLER_NOEC(irq2, 34)
f0104402:	6a 00                	push   $0x0
f0104404:	6a 22                	push   $0x22
f0104406:	eb 4e                	jmp    f0104456 <_alltraps>

f0104408 <irq3>:
TRAPHANDLER_NOEC(irq3, 35)
f0104408:	6a 00                	push   $0x0
f010440a:	6a 23                	push   $0x23
f010440c:	eb 48                	jmp    f0104456 <_alltraps>

f010440e <irq4>:
TRAPHANDLER_NOEC(irq4, 36)
f010440e:	6a 00                	push   $0x0
f0104410:	6a 24                	push   $0x24
f0104412:	eb 42                	jmp    f0104456 <_alltraps>

f0104414 <irq5>:
TRAPHANDLER_NOEC(irq5, 37)
f0104414:	6a 00                	push   $0x0
f0104416:	6a 25                	push   $0x25
f0104418:	eb 3c                	jmp    f0104456 <_alltraps>

f010441a <irq6>:
TRAPHANDLER_NOEC(irq6, 38)
f010441a:	6a 00                	push   $0x0
f010441c:	6a 26                	push   $0x26
f010441e:	eb 36                	jmp    f0104456 <_alltraps>

f0104420 <irq7>:
TRAPHANDLER_NOEC(irq7, 39)
f0104420:	6a 00                	push   $0x0
f0104422:	6a 27                	push   $0x27
f0104424:	eb 30                	jmp    f0104456 <_alltraps>

f0104426 <irq8>:
TRAPHANDLER_NOEC(irq8, 40)
f0104426:	6a 00                	push   $0x0
f0104428:	6a 28                	push   $0x28
f010442a:	eb 2a                	jmp    f0104456 <_alltraps>

f010442c <irq9>:
TRAPHANDLER_NOEC(irq9, 41)
f010442c:	6a 00                	push   $0x0
f010442e:	6a 29                	push   $0x29
f0104430:	eb 24                	jmp    f0104456 <_alltraps>

f0104432 <irq10>:
TRAPHANDLER_NOEC(irq10, 42)
f0104432:	6a 00                	push   $0x0
f0104434:	6a 2a                	push   $0x2a
f0104436:	eb 1e                	jmp    f0104456 <_alltraps>

f0104438 <irq11>:
TRAPHANDLER_NOEC(irq11, 43)
f0104438:	6a 00                	push   $0x0
f010443a:	6a 2b                	push   $0x2b
f010443c:	eb 18                	jmp    f0104456 <_alltraps>

f010443e <irq12>:
TRAPHANDLER_NOEC(irq12, 44)
f010443e:	6a 00                	push   $0x0
f0104440:	6a 2c                	push   $0x2c
f0104442:	eb 12                	jmp    f0104456 <_alltraps>

f0104444 <irq13>:
TRAPHANDLER_NOEC(irq13, 45)
f0104444:	6a 00                	push   $0x0
f0104446:	6a 2d                	push   $0x2d
f0104448:	eb 0c                	jmp    f0104456 <_alltraps>

f010444a <irq14>:
TRAPHANDLER_NOEC(irq14, 46)
f010444a:	6a 00                	push   $0x0
f010444c:	6a 2e                	push   $0x2e
f010444e:	eb 06                	jmp    f0104456 <_alltraps>

f0104450 <irq15>:
TRAPHANDLER_NOEC(irq15, 47)
f0104450:	6a 00                	push   $0x0
f0104452:	6a 2f                	push   $0x2f
f0104454:	eb 00                	jmp    f0104456 <_alltraps>

f0104456 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */

 _alltraps:
	pushl %ds
f0104456:	1e                   	push   %ds
	pushl %es
f0104457:	06                   	push   %es
	pushal 
f0104458:	60                   	pusha  

	movl $GD_KD, %eax
f0104459:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f010445e:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104460:	8e c0                	mov    %eax,%es

	pushl %esp
f0104462:	54                   	push   %esp
	call trap	
f0104463:	e8 d9 fc ff ff       	call   f0104141 <trap>

f0104468 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104468:	55                   	push   %ebp
f0104469:	89 e5                	mov    %esp,%ebp
f010446b:	83 ec 08             	sub    $0x8,%esp
f010446e:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
f0104473:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104476:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010447b:	8b 02                	mov    (%edx),%eax
f010447d:	83 e8 01             	sub    $0x1,%eax
f0104480:	83 f8 02             	cmp    $0x2,%eax
f0104483:	76 10                	jbe    f0104495 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104485:	83 c1 01             	add    $0x1,%ecx
f0104488:	83 c2 7c             	add    $0x7c,%edx
f010448b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104491:	75 e8                	jne    f010447b <sched_halt+0x13>
f0104493:	eb 08                	jmp    f010449d <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104495:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010449b:	75 1f                	jne    f01044bc <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f010449d:	83 ec 0c             	sub    $0xc,%esp
f01044a0:	68 50 7a 10 f0       	push   $0xf0107a50
f01044a5:	e8 5e f2 ff ff       	call   f0103708 <cprintf>
f01044aa:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01044ad:	83 ec 0c             	sub    $0xc,%esp
f01044b0:	6a 00                	push   $0x0
f01044b2:	e8 7a c4 ff ff       	call   f0100931 <monitor>
f01044b7:	83 c4 10             	add    $0x10,%esp
f01044ba:	eb f1                	jmp    f01044ad <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01044bc:	e8 4d 18 00 00       	call   f0105d0e <cpunum>
f01044c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c4:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f01044cb:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044ce:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01044d3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044d8:	77 12                	ja     f01044ec <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01044da:	50                   	push   %eax
f01044db:	68 e8 63 10 f0       	push   $0xf01063e8
f01044e0:	6a 4c                	push   $0x4c
f01044e2:	68 79 7a 10 f0       	push   $0xf0107a79
f01044e7:	e8 54 bb ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01044ec:	05 00 00 00 10       	add    $0x10000000,%eax
f01044f1:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01044f4:	e8 15 18 00 00       	call   f0105d0e <cpunum>
f01044f9:	6b d0 74             	imul   $0x74,%eax,%edx
f01044fc:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104502:	b8 02 00 00 00       	mov    $0x2,%eax
f0104507:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010450b:	83 ec 0c             	sub    $0xc,%esp
f010450e:	68 c0 03 12 f0       	push   $0xf01203c0
f0104513:	e8 01 1b 00 00       	call   f0106019 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104518:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010451a:	e8 ef 17 00 00       	call   f0105d0e <cpunum>
f010451f:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104522:	8b 80 30 00 23 f0    	mov    -0xfdcffd0(%eax),%eax
f0104528:	bd 00 00 00 00       	mov    $0x0,%ebp
f010452d:	89 c4                	mov    %eax,%esp
f010452f:	6a 00                	push   $0x0
f0104531:	6a 00                	push   $0x0
f0104533:	fb                   	sti    
f0104534:	f4                   	hlt    
f0104535:	eb fd                	jmp    f0104534 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104537:	83 c4 10             	add    $0x10,%esp
f010453a:	c9                   	leave  
f010453b:	c3                   	ret    

f010453c <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010453c:	55                   	push   %ebp
f010453d:	89 e5                	mov    %esp,%ebp
f010453f:	53                   	push   %ebx
f0104540:	83 ec 04             	sub    $0x4,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.

	int curenv_id = curenv ? ENVX(curenv->env_id) : 0;
f0104543:	e8 c6 17 00 00       	call   f0105d0e <cpunum>
f0104548:	6b c0 74             	imul   $0x74,%eax,%eax
f010454b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104550:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0104557:	74 17                	je     f0104570 <sched_yield+0x34>
f0104559:	e8 b0 17 00 00       	call   f0105d0e <cpunum>
f010455e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104561:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104567:	8b 48 48             	mov    0x48(%eax),%ecx
f010456a:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
	int i;
	for (i = 0; i < NENV; i++)
	{
		int env_id = ENVX(curenv_id + i);
		if (envs[env_id].env_status == ENV_RUNNABLE)
f0104570:	8b 1d 48 f2 22 f0    	mov    0xf022f248,%ebx
f0104576:	89 ca                	mov    %ecx,%edx
f0104578:	81 c1 00 04 00 00    	add    $0x400,%ecx
f010457e:	89 d0                	mov    %edx,%eax
f0104580:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104585:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104588:	01 d8                	add    %ebx,%eax
f010458a:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010458e:	75 09                	jne    f0104599 <sched_yield+0x5d>
		{
			env_run(&envs[env_id]);
f0104590:	83 ec 0c             	sub    $0xc,%esp
f0104593:	50                   	push   %eax
f0104594:	e8 0d ef ff ff       	call   f01034a6 <env_run>
f0104599:	83 c2 01             	add    $0x1,%edx

	// LAB 4: Your code here.

	int curenv_id = curenv ? ENVX(curenv->env_id) : 0;
	int i;
	for (i = 0; i < NENV; i++)
f010459c:	39 ca                	cmp    %ecx,%edx
f010459e:	75 de                	jne    f010457e <sched_yield+0x42>
		if (envs[env_id].env_status == ENV_RUNNABLE)
		{
			env_run(&envs[env_id]);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
f01045a0:	e8 69 17 00 00       	call   f0105d0e <cpunum>
f01045a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a8:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01045af:	74 2a                	je     f01045db <sched_yield+0x9f>
f01045b1:	e8 58 17 00 00       	call   f0105d0e <cpunum>
f01045b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b9:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01045bf:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01045c3:	75 16                	jne    f01045db <sched_yield+0x9f>
	{
		env_run(curenv);
f01045c5:	e8 44 17 00 00       	call   f0105d0e <cpunum>
f01045ca:	83 ec 0c             	sub    $0xc,%esp
f01045cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d0:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01045d6:	e8 cb ee ff ff       	call   f01034a6 <env_run>
	}

	// sched_halt never returns
	sched_halt();
f01045db:	e8 88 fe ff ff       	call   f0104468 <sched_halt>
}
f01045e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01045e3:	c9                   	leave  
f01045e4:	c3                   	ret    

f01045e5 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01045e5:	55                   	push   %ebp
f01045e6:	89 e5                	mov    %esp,%ebp
f01045e8:	57                   	push   %edi
f01045e9:	56                   	push   %esi
f01045ea:	53                   	push   %ebx
f01045eb:	83 ec 1c             	sub    $0x1c,%esp
f01045ee:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f01045f1:	83 f8 0c             	cmp    $0xc,%eax
f01045f4:	0f 87 74 05 00 00    	ja     f0104b6e <syscall+0x589>
f01045fa:	ff 24 85 c0 7a 10 f0 	jmp    *-0xfef8540(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f0104601:	e8 08 17 00 00       	call   f0105d0e <cpunum>
f0104606:	6a 00                	push   $0x0
f0104608:	ff 75 10             	pushl  0x10(%ebp)
f010460b:	ff 75 0c             	pushl  0xc(%ebp)
f010460e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104611:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104617:	e8 31 e7 ff ff       	call   f0102d4d <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010461c:	83 c4 0c             	add    $0xc,%esp
f010461f:	ff 75 0c             	pushl  0xc(%ebp)
f0104622:	ff 75 10             	pushl  0x10(%ebp)
f0104625:	68 86 7a 10 f0       	push   $0xf0107a86
f010462a:	e8 d9 f0 ff ff       	call   f0103708 <cprintf>
f010462f:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");

	switch (syscallno) {
		case SYS_cputs:
		     sys_cputs((char *) a1, (size_t) a2);
		     return 0;
f0104632:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104637:	e9 3e 05 00 00       	jmp    f0104b7a <syscall+0x595>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010463c:	e8 b4 bf ff ff       	call   f01005f5 <cons_getc>
f0104641:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
		case SYS_cputs:
		     sys_cputs((char *) a1, (size_t) a2);
		     return 0;
		case SYS_cgetc:
			return sys_cgetc();
f0104643:	e9 32 05 00 00       	jmp    f0104b7a <syscall+0x595>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104648:	e8 c1 16 00 00       	call   f0105d0e <cpunum>
f010464d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104650:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104656:	8b 58 48             	mov    0x48(%eax),%ebx
		     sys_cputs((char *) a1, (size_t) a2);
		     return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f0104659:	e9 1c 05 00 00       	jmp    f0104b7a <syscall+0x595>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010465e:	83 ec 04             	sub    $0x4,%esp
f0104661:	6a 01                	push   $0x1
f0104663:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104666:	50                   	push   %eax
f0104667:	ff 75 0c             	pushl  0xc(%ebp)
f010466a:	e8 ae e7 ff ff       	call   f0102e1d <envid2env>
f010466f:	83 c4 10             	add    $0x10,%esp
		return r;
f0104672:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104674:	85 c0                	test   %eax,%eax
f0104676:	0f 88 fe 04 00 00    	js     f0104b7a <syscall+0x595>
		return r;
	if (e == curenv)
f010467c:	e8 8d 16 00 00       	call   f0105d0e <cpunum>
f0104681:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104684:	6b c0 74             	imul   $0x74,%eax,%eax
f0104687:	39 90 28 00 23 f0    	cmp    %edx,-0xfdcffd8(%eax)
f010468d:	75 23                	jne    f01046b2 <syscall+0xcd>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010468f:	e8 7a 16 00 00       	call   f0105d0e <cpunum>
f0104694:	83 ec 08             	sub    $0x8,%esp
f0104697:	6b c0 74             	imul   $0x74,%eax,%eax
f010469a:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01046a0:	ff 70 48             	pushl  0x48(%eax)
f01046a3:	68 8b 7a 10 f0       	push   $0xf0107a8b
f01046a8:	e8 5b f0 ff ff       	call   f0103708 <cprintf>
f01046ad:	83 c4 10             	add    $0x10,%esp
f01046b0:	eb 25                	jmp    f01046d7 <syscall+0xf2>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01046b2:	8b 5a 48             	mov    0x48(%edx),%ebx
f01046b5:	e8 54 16 00 00       	call   f0105d0e <cpunum>
f01046ba:	83 ec 04             	sub    $0x4,%esp
f01046bd:	53                   	push   %ebx
f01046be:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c1:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01046c7:	ff 70 48             	pushl  0x48(%eax)
f01046ca:	68 a6 7a 10 f0       	push   $0xf0107aa6
f01046cf:	e8 34 f0 ff ff       	call   f0103708 <cprintf>
f01046d4:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01046d7:	83 ec 0c             	sub    $0xc,%esp
f01046da:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046dd:	e8 25 ed ff ff       	call   f0103407 <env_destroy>
f01046e2:	83 c4 10             	add    $0x10,%esp
	return 0;
f01046e5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046ea:	e9 8b 04 00 00       	jmp    f0104b7a <syscall+0x595>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01046ef:	e8 48 fe ff ff       	call   f010453c <sched_yield>
	// LAB 4: Your code here.
	
	envid_t result;

	struct Env *e;
	if ((result = env_alloc(&e, curenv?curenv->env_id:0)))
f01046f4:	e8 15 16 00 00       	call   f0105d0e <cpunum>
f01046f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01046fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0104701:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0104708:	74 11                	je     f010471b <syscall+0x136>
f010470a:	e8 ff 15 00 00       	call   f0105d0e <cpunum>
f010470f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104712:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104718:	8b 50 48             	mov    0x48(%eax),%edx
f010471b:	83 ec 08             	sub    $0x8,%esp
f010471e:	52                   	push   %edx
f010471f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104722:	50                   	push   %eax
f0104723:	e8 2c e8 ff ff       	call   f0102f54 <env_alloc>
f0104728:	83 c4 10             	add    $0x10,%esp
		return result;
f010472b:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
	
	envid_t result;

	struct Env *e;
	if ((result = env_alloc(&e, curenv?curenv->env_id:0)))
f010472d:	85 c0                	test   %eax,%eax
f010472f:	0f 85 45 04 00 00    	jne    f0104b7a <syscall+0x595>
		return result;
	e->env_tf = curenv->env_tf;
f0104735:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104738:	e8 d1 15 00 00       	call   f0105d0e <cpunum>
f010473d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104740:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
f0104746:	b9 11 00 00 00       	mov    $0x11,%ecx
f010474b:	89 df                	mov    %ebx,%edi
f010474d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_status = ENV_NOT_RUNNABLE;
f010474f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104752:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104759:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104760:	8b 58 48             	mov    0x48(%eax),%ebx
f0104763:	e9 12 04 00 00       	jmp    f0104b7a <syscall+0x595>
	

	struct Env *e;
	struct PageInfo *pp;
	
	if (envid2env(envid, &e, 1))
f0104768:	83 ec 04             	sub    $0x4,%esp
f010476b:	6a 01                	push   $0x1
f010476d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104770:	50                   	push   %eax
f0104771:	ff 75 0c             	pushl  0xc(%ebp)
f0104774:	e8 a4 e6 ff ff       	call   f0102e1d <envid2env>
f0104779:	83 c4 10             	add    $0x10,%esp
f010477c:	85 c0                	test   %eax,%eax
f010477e:	75 6c                	jne    f01047ec <syscall+0x207>
		return -E_BAD_ENV; 

	if ((uint32_t) va >= UTOP || (uint32_t) va % PGSIZE != 0)
f0104780:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104787:	77 6d                	ja     f01047f6 <syscall+0x211>
f0104789:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104790:	75 6e                	jne    f0104800 <syscall+0x21b>
		return -E_INVAL;

	if (((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U)) || (perm & ~(PTE_SYSCALL)))
f0104792:	8b 45 14             	mov    0x14(%ebp),%eax
f0104795:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010479a:	83 f8 05             	cmp    $0x5,%eax
f010479d:	75 6b                	jne    f010480a <syscall+0x225>
		return -E_INVAL;

	if (!(pp = page_alloc(ALLOC_ZERO)))
f010479f:	83 ec 0c             	sub    $0xc,%esp
f01047a2:	6a 01                	push   $0x1
f01047a4:	e8 92 c7 ff ff       	call   f0100f3b <page_alloc>
f01047a9:	89 c6                	mov    %eax,%esi
f01047ab:	83 c4 10             	add    $0x10,%esp
f01047ae:	85 c0                	test   %eax,%eax
f01047b0:	74 62                	je     f0104814 <syscall+0x22f>
		return -E_NO_MEM;

	

	pp->pp_ref++;
f01047b2:	66 83 40 04 01       	addw   $0x1,0x4(%eax)

	if (page_insert(e->env_pgdir, pp, va, perm))
f01047b7:	ff 75 14             	pushl  0x14(%ebp)
f01047ba:	ff 75 10             	pushl  0x10(%ebp)
f01047bd:	50                   	push   %eax
f01047be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047c1:	ff 70 60             	pushl  0x60(%eax)
f01047c4:	e8 47 ca ff ff       	call   f0101210 <page_insert>
f01047c9:	89 c3                	mov    %eax,%ebx
f01047cb:	83 c4 10             	add    $0x10,%esp
f01047ce:	85 c0                	test   %eax,%eax
f01047d0:	0f 84 a4 03 00 00    	je     f0104b7a <syscall+0x595>
	{
		page_free(pp);
f01047d6:	83 ec 0c             	sub    $0xc,%esp
f01047d9:	56                   	push   %esi
f01047da:	e8 f3 c7 ff ff       	call   f0100fd2 <page_free>
f01047df:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f01047e2:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01047e7:	e9 8e 03 00 00       	jmp    f0104b7a <syscall+0x595>

	struct Env *e;
	struct PageInfo *pp;
	
	if (envid2env(envid, &e, 1))
		return -E_BAD_ENV; 
f01047ec:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01047f1:	e9 84 03 00 00       	jmp    f0104b7a <syscall+0x595>

	if ((uint32_t) va >= UTOP || (uint32_t) va % PGSIZE != 0)
		return -E_INVAL;
f01047f6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01047fb:	e9 7a 03 00 00       	jmp    f0104b7a <syscall+0x595>
f0104800:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104805:	e9 70 03 00 00       	jmp    f0104b7a <syscall+0x595>

	if (((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U)) || (perm & ~(PTE_SYSCALL)))
		return -E_INVAL;
f010480a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010480f:	e9 66 03 00 00       	jmp    f0104b7a <syscall+0x595>

	if (!(pp = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0104814:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
			return 0;	
		case SYS_exofork:
			return sys_exofork();
			break;
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3);
f0104819:	e9 5c 03 00 00       	jmp    f0104b7a <syscall+0x595>
	// LAB 4: Your code here.
	

	struct Env *srcenv, *dstenv;

	if (envid2env(srcenvid, &srcenv, 1))
f010481e:	83 ec 04             	sub    $0x4,%esp
f0104821:	6a 01                	push   $0x1
f0104823:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104826:	50                   	push   %eax
f0104827:	ff 75 0c             	pushl  0xc(%ebp)
f010482a:	e8 ee e5 ff ff       	call   f0102e1d <envid2env>
f010482f:	83 c4 10             	add    $0x10,%esp
f0104832:	85 c0                	test   %eax,%eax
f0104834:	0f 85 97 00 00 00    	jne    f01048d1 <syscall+0x2ec>
		return -E_BAD_ENV;

	if (envid2env(dstenvid, &dstenv, 1))
f010483a:	83 ec 04             	sub    $0x4,%esp
f010483d:	6a 01                	push   $0x1
f010483f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104842:	50                   	push   %eax
f0104843:	ff 75 14             	pushl  0x14(%ebp)
f0104846:	e8 d2 e5 ff ff       	call   f0102e1d <envid2env>
f010484b:	83 c4 10             	add    $0x10,%esp
f010484e:	85 c0                	test   %eax,%eax
f0104850:	0f 85 85 00 00 00    	jne    f01048db <syscall+0x2f6>
		return -E_BAD_ENV;

	if ((uint32_t) srcva >= UTOP || (uint32_t) dstva >= UTOP || 
f0104856:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010485d:	0f 87 82 00 00 00    	ja     f01048e5 <syscall+0x300>
f0104863:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f010486a:	77 79                	ja     f01048e5 <syscall+0x300>
		(uint32_t) srcva % PGSIZE !=0 || (uint32_t) dstva % PGSIZE !=0)
f010486c:	8b 45 10             	mov    0x10(%ebp),%eax
f010486f:	0b 45 18             	or     0x18(%ebp),%eax
f0104872:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104877:	75 76                	jne    f01048ef <syscall+0x30a>
		return -E_INVAL;


	pte_t *pte_store;
	struct PageInfo *pp = page_lookup (srcenv->env_pgdir, srcva, &pte_store);
f0104879:	83 ec 04             	sub    $0x4,%esp
f010487c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010487f:	50                   	push   %eax
f0104880:	ff 75 10             	pushl  0x10(%ebp)
f0104883:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104886:	ff 70 60             	pushl  0x60(%eax)
f0104889:	e8 a1 c8 ff ff       	call   f010112f <page_lookup>

	if (!pp)
f010488e:	83 c4 10             	add    $0x10,%esp
f0104891:	85 c0                	test   %eax,%eax
f0104893:	74 64                	je     f01048f9 <syscall+0x314>
		return -E_INVAL;

	if (((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U)) || (perm & ~(PTE_SYSCALL))
f0104895:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104898:	81 e2 fd f1 ff ff    	and    $0xfffff1fd,%edx
f010489e:	83 fa 05             	cmp    $0x5,%edx
f01048a1:	75 60                	jne    f0104903 <syscall+0x31e>
		|| ((perm & PTE_W) & (*pte_store)) != (perm & PTE_W))
f01048a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048a6:	8b 7d 1c             	mov    0x1c(%ebp),%edi
f01048a9:	23 3a                	and    (%edx),%edi
f01048ab:	89 fa                	mov    %edi,%edx
f01048ad:	33 55 1c             	xor    0x1c(%ebp),%edx
f01048b0:	f6 c2 02             	test   $0x2,%dl
f01048b3:	75 58                	jne    f010490d <syscall+0x328>
		return -E_INVAL;


	return page_insert(dstenv->env_pgdir, pp, dstva, perm);
f01048b5:	ff 75 1c             	pushl  0x1c(%ebp)
f01048b8:	ff 75 18             	pushl  0x18(%ebp)
f01048bb:	50                   	push   %eax
f01048bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048bf:	ff 70 60             	pushl  0x60(%eax)
f01048c2:	e8 49 c9 ff ff       	call   f0101210 <page_insert>
f01048c7:	89 c3                	mov    %eax,%ebx
f01048c9:	83 c4 10             	add    $0x10,%esp
f01048cc:	e9 a9 02 00 00       	jmp    f0104b7a <syscall+0x595>
	

	struct Env *srcenv, *dstenv;

	if (envid2env(srcenvid, &srcenv, 1))
		return -E_BAD_ENV;
f01048d1:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01048d6:	e9 9f 02 00 00       	jmp    f0104b7a <syscall+0x595>

	if (envid2env(dstenvid, &dstenv, 1))
		return -E_BAD_ENV;
f01048db:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01048e0:	e9 95 02 00 00       	jmp    f0104b7a <syscall+0x595>

	if ((uint32_t) srcva >= UTOP || (uint32_t) dstva >= UTOP || 
		(uint32_t) srcva % PGSIZE !=0 || (uint32_t) dstva % PGSIZE !=0)
		return -E_INVAL;
f01048e5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048ea:	e9 8b 02 00 00       	jmp    f0104b7a <syscall+0x595>
f01048ef:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048f4:	e9 81 02 00 00       	jmp    f0104b7a <syscall+0x595>

	pte_t *pte_store;
	struct PageInfo *pp = page_lookup (srcenv->env_pgdir, srcva, &pte_store);

	if (!pp)
		return -E_INVAL;
f01048f9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048fe:	e9 77 02 00 00       	jmp    f0104b7a <syscall+0x595>

	if (((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U)) || (perm & ~(PTE_SYSCALL))
		|| ((perm & PTE_W) & (*pte_store)) != (perm & PTE_W))
		return -E_INVAL;
f0104903:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104908:	e9 6d 02 00 00       	jmp    f0104b7a <syscall+0x595>
f010490d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_exofork();
			break;
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3);
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
f0104912:	e9 63 02 00 00       	jmp    f0104b7a <syscall+0x595>

	// LAB 4: Your code here.

	struct Env *e;

	if (envid2env(envid, &e, 1))
f0104917:	83 ec 04             	sub    $0x4,%esp
f010491a:	6a 01                	push   $0x1
f010491c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010491f:	50                   	push   %eax
f0104920:	ff 75 0c             	pushl  0xc(%ebp)
f0104923:	e8 f5 e4 ff ff       	call   f0102e1d <envid2env>
f0104928:	89 c3                	mov    %eax,%ebx
f010492a:	83 c4 10             	add    $0x10,%esp
f010492d:	85 c0                	test   %eax,%eax
f010492f:	75 2b                	jne    f010495c <syscall+0x377>
		return -E_BAD_ENV;

	if ((uint32_t) va >= UTOP || (uint32_t) va % PGSIZE != 0)
f0104931:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104938:	77 2c                	ja     f0104966 <syscall+0x381>
f010493a:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104941:	75 2d                	jne    f0104970 <syscall+0x38b>
		return -E_INVAL;

	page_remove(e->env_pgdir, va);
f0104943:	83 ec 08             	sub    $0x8,%esp
f0104946:	ff 75 10             	pushl  0x10(%ebp)
f0104949:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010494c:	ff 70 60             	pushl  0x60(%eax)
f010494f:	e8 76 c8 ff ff       	call   f01011ca <page_remove>
f0104954:	83 c4 10             	add    $0x10,%esp
f0104957:	e9 1e 02 00 00       	jmp    f0104b7a <syscall+0x595>
	// LAB 4: Your code here.

	struct Env *e;

	if (envid2env(envid, &e, 1))
		return -E_BAD_ENV;
f010495c:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104961:	e9 14 02 00 00       	jmp    f0104b7a <syscall+0x595>

	if ((uint32_t) va >= UTOP || (uint32_t) va % PGSIZE != 0)
		return -E_INVAL;
f0104966:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010496b:	e9 0a 02 00 00       	jmp    f0104b7a <syscall+0x595>
f0104970:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void*)a2, a3);
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
f0104975:	e9 00 02 00 00       	jmp    f0104b7a <syscall+0x595>
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e;

	if (envid2env(envid, &e, 1))
f010497a:	83 ec 04             	sub    $0x4,%esp
f010497d:	6a 01                	push   $0x1
f010497f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104982:	50                   	push   %eax
f0104983:	ff 75 0c             	pushl  0xc(%ebp)
f0104986:	e8 92 e4 ff ff       	call   f0102e1d <envid2env>
f010498b:	89 c3                	mov    %eax,%ebx
f010498d:	83 c4 10             	add    $0x10,%esp
f0104990:	85 c0                	test   %eax,%eax
f0104992:	75 1b                	jne    f01049af <syscall+0x3ca>
		return -E_BAD_ENV;
	if ((status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE))
f0104994:	8b 45 10             	mov    0x10(%ebp),%eax
f0104997:	83 e8 02             	sub    $0x2,%eax
f010499a:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010499f:	75 18                	jne    f01049b9 <syscall+0x3d4>
		return -E_INVAL;
	e->env_status = status;
f01049a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049a4:	8b 7d 10             	mov    0x10(%ebp),%edi
f01049a7:	89 78 54             	mov    %edi,0x54(%eax)
f01049aa:	e9 cb 01 00 00       	jmp    f0104b7a <syscall+0x595>

	// LAB 4: Your code here.
	struct Env *e;

	if (envid2env(envid, &e, 1))
		return -E_BAD_ENV;
f01049af:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01049b4:	e9 c1 01 00 00       	jmp    f0104b7a <syscall+0x595>
	if ((status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE))
		return -E_INVAL;
f01049b9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_page_map:
			return sys_page_map(a1, (void*)a2, a3, (void*)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
		case SYS_env_set_status:
			return (int32_t)sys_env_set_status((envid_t)a1, (int)a2);
f01049be:	e9 b7 01 00 00       	jmp    f0104b7a <syscall+0x595>
	// LAB 4: Your code here.
	

	struct Env *e;

	if (envid2env(envid, &e, 1))
f01049c3:	83 ec 04             	sub    $0x4,%esp
f01049c6:	6a 01                	push   $0x1
f01049c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049cb:	50                   	push   %eax
f01049cc:	ff 75 0c             	pushl  0xc(%ebp)
f01049cf:	e8 49 e4 ff ff       	call   f0102e1d <envid2env>
f01049d4:	89 c3                	mov    %eax,%ebx
f01049d6:	83 c4 10             	add    $0x10,%esp
f01049d9:	85 c0                	test   %eax,%eax
f01049db:	75 0e                	jne    f01049eb <syscall+0x406>
		return -E_BAD_ENV;

	e->env_pgfault_upcall = func;
f01049dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01049e3:	89 48 64             	mov    %ecx,0x64(%eax)
f01049e6:	e9 8f 01 00 00       	jmp    f0104b7a <syscall+0x595>
	

	struct Env *e;

	if (envid2env(envid, &e, 1))
		return -E_BAD_ENV;
f01049eb:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void*)a2);
		case SYS_env_set_status:
			return (int32_t)sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_env_set_pgfault_upcall:
			return (uint32_t) sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);	
f01049f0:	e9 85 01 00 00       	jmp    f0104b7a <syscall+0x595>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.

	if ((uint32_t)dstva < UTOP && (uint32_t)dstva % PGSIZE != 0)
f01049f5:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01049fc:	77 0d                	ja     f0104a0b <syscall+0x426>
f01049fe:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104a05:	0f 85 6a 01 00 00    	jne    f0104b75 <syscall+0x590>
		return -E_INVAL;
	curenv->env_ipc_recving = 1;
f0104a0b:	e8 fe 12 00 00       	call   f0105d0e <cpunum>
f0104a10:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a13:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104a19:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104a1d:	e8 ec 12 00 00       	call   f0105d0e <cpunum>
f0104a22:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a25:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104a2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104a2e:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104a31:	e8 d8 12 00 00       	call   f0105d0e <cpunum>
f0104a36:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a39:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104a3f:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

	sched_yield();
f0104a46:	e8 f1 fa ff ff       	call   f010453c <sched_yield>

	struct Env *e;
	struct PageInfo *pp;
	pte_t *pte;

	if (envid2env(envid, &e, 0))
f0104a4b:	83 ec 04             	sub    $0x4,%esp
f0104a4e:	6a 00                	push   $0x0
f0104a50:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a53:	50                   	push   %eax
f0104a54:	ff 75 0c             	pushl  0xc(%ebp)
f0104a57:	e8 c1 e3 ff ff       	call   f0102e1d <envid2env>
f0104a5c:	89 c3                	mov    %eax,%ebx
f0104a5e:	83 c4 10             	add    $0x10,%esp
f0104a61:	85 c0                	test   %eax,%eax
f0104a63:	0f 85 d4 00 00 00    	jne    f0104b3d <syscall+0x558>
		return -E_BAD_ENV;

	if (!e->env_ipc_recving)
f0104a69:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a6c:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a70:	0f 84 ce 00 00 00    	je     f0104b44 <syscall+0x55f>
		return -E_IPC_NOT_RECV;

	if (((uint32_t)srcva < UTOP))
f0104a76:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a7d:	0f 87 86 00 00 00    	ja     f0104b09 <syscall+0x524>
	{		

		if ((uint32_t)srcva % PGSIZE != 0)
f0104a83:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104a8a:	0f 85 bb 00 00 00    	jne    f0104b4b <syscall+0x566>
			return -E_INVAL;

		if (((perm & (PTE_P | PTE_U)) != 
f0104a90:	8b 45 18             	mov    0x18(%ebp),%eax
f0104a93:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104a98:	83 f8 05             	cmp    $0x5,%eax
f0104a9b:	0f 85 b1 00 00 00    	jne    f0104b52 <syscall+0x56d>
			((PTE_P | PTE_U)) || (perm & ~(PTE_SYSCALL))))
			return -E_INVAL;

		if (!(pp = page_lookup(curenv->env_pgdir, srcva, &pte)))
f0104aa1:	e8 68 12 00 00       	call   f0105d0e <cpunum>
f0104aa6:	83 ec 04             	sub    $0x4,%esp
f0104aa9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104aac:	52                   	push   %edx
f0104aad:	ff 75 14             	pushl  0x14(%ebp)
f0104ab0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab3:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104ab9:	ff 70 60             	pushl  0x60(%eax)
f0104abc:	e8 6e c6 ff ff       	call   f010112f <page_lookup>
f0104ac1:	83 c4 10             	add    $0x10,%esp
f0104ac4:	85 c0                	test   %eax,%eax
f0104ac6:	0f 84 8d 00 00 00    	je     f0104b59 <syscall+0x574>
			return -E_INVAL;	

		if ((perm & PTE_W) && !(*pte & PTE_W))
f0104acc:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104ad0:	74 0c                	je     f0104ade <syscall+0x4f9>
f0104ad2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ad5:	f6 02 02             	testb  $0x2,(%edx)
f0104ad8:	0f 84 82 00 00 00    	je     f0104b60 <syscall+0x57b>
		return -E_INVAL;	

		if ((uint32_t)e->env_ipc_dstva < UTOP)
f0104ade:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ae1:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104ae4:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104aea:	77 1d                	ja     f0104b09 <syscall+0x524>
		{

			if (page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm))	
f0104aec:	ff 75 18             	pushl  0x18(%ebp)
f0104aef:	51                   	push   %ecx
f0104af0:	50                   	push   %eax
f0104af1:	ff 72 60             	pushl  0x60(%edx)
f0104af4:	e8 17 c7 ff ff       	call   f0101210 <page_insert>
f0104af9:	83 c4 10             	add    $0x10,%esp
f0104afc:	85 c0                	test   %eax,%eax
f0104afe:	75 67                	jne    f0104b67 <syscall+0x582>
				return -E_NO_MEM;
			e->env_ipc_perm = perm;
f0104b00:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b03:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104b06:	89 78 78             	mov    %edi,0x78(%eax)
		}

	}

	e->env_ipc_recving = 0;
f0104b09:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b0c:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	e->env_ipc_from = curenv->env_id;
f0104b10:	e8 f9 11 00 00       	call   f0105d0e <cpunum>
f0104b15:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b18:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104b1e:	8b 40 48             	mov    0x48(%eax),%eax
f0104b21:	89 46 74             	mov    %eax,0x74(%esi)
	e->env_ipc_value = value;
f0104b24:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b27:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104b2a:	89 48 70             	mov    %ecx,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f0104b2d:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	e->env_tf.tf_regs.reg_eax = 0;
f0104b34:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0104b3b:	eb 3d                	jmp    f0104b7a <syscall+0x595>
	struct Env *e;
	struct PageInfo *pp;
	pte_t *pte;

	if (envid2env(envid, &e, 0))
		return -E_BAD_ENV;
f0104b3d:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104b42:	eb 36                	jmp    f0104b7a <syscall+0x595>

	if (!e->env_ipc_recving)
		return -E_IPC_NOT_RECV;
f0104b44:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104b49:	eb 2f                	jmp    f0104b7a <syscall+0x595>

	if (((uint32_t)srcva < UTOP))
	{		

		if ((uint32_t)srcva % PGSIZE != 0)
			return -E_INVAL;
f0104b4b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b50:	eb 28                	jmp    f0104b7a <syscall+0x595>

		if (((perm & (PTE_P | PTE_U)) != 
			((PTE_P | PTE_U)) || (perm & ~(PTE_SYSCALL))))
			return -E_INVAL;
f0104b52:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b57:	eb 21                	jmp    f0104b7a <syscall+0x595>

		if (!(pp = page_lookup(curenv->env_pgdir, srcva, &pte)))
			return -E_INVAL;	
f0104b59:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b5e:	eb 1a                	jmp    f0104b7a <syscall+0x595>

		if ((perm & PTE_W) && !(*pte & PTE_W))
		return -E_INVAL;	
f0104b60:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b65:	eb 13                	jmp    f0104b7a <syscall+0x595>

		if ((uint32_t)e->env_ipc_dstva < UTOP)
		{

			if (page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm))	
				return -E_NO_MEM;
f0104b67:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		case SYS_env_set_pgfault_upcall:
			return (uint32_t) sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);	
		case SYS_ipc_recv:
			return (uint32_t) sys_ipc_recv ((void *)a1);
		case SYS_ipc_try_send:	
			return (uint32_t ) sys_ipc_try_send((envid_t) a1, (uint32_t) a2, (void *)a3, (unsigned) a4);
f0104b6c:	eb 0c                	jmp    f0104b7a <syscall+0x595>
			
		default:
			return -E_INVAL;	
f0104b6e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b73:	eb 05                	jmp    f0104b7a <syscall+0x595>
		case SYS_env_set_status:
			return (int32_t)sys_env_set_status((envid_t)a1, (int)a2);
		case SYS_env_set_pgfault_upcall:
			return (uint32_t) sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);	
		case SYS_ipc_recv:
			return (uint32_t) sys_ipc_recv ((void *)a1);
f0104b75:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return (uint32_t ) sys_ipc_try_send((envid_t) a1, (uint32_t) a2, (void *)a3, (unsigned) a4);
			
		default:
			return -E_INVAL;	
	}
}
f0104b7a:	89 d8                	mov    %ebx,%eax
f0104b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b7f:	5b                   	pop    %ebx
f0104b80:	5e                   	pop    %esi
f0104b81:	5f                   	pop    %edi
f0104b82:	5d                   	pop    %ebp
f0104b83:	c3                   	ret    

f0104b84 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104b84:	55                   	push   %ebp
f0104b85:	89 e5                	mov    %esp,%ebp
f0104b87:	57                   	push   %edi
f0104b88:	56                   	push   %esi
f0104b89:	53                   	push   %ebx
f0104b8a:	83 ec 14             	sub    $0x14,%esp
f0104b8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b90:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104b93:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104b96:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104b99:	8b 1a                	mov    (%edx),%ebx
f0104b9b:	8b 01                	mov    (%ecx),%eax
f0104b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ba0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104ba7:	eb 7f                	jmp    f0104c28 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104bac:	01 d8                	add    %ebx,%eax
f0104bae:	89 c6                	mov    %eax,%esi
f0104bb0:	c1 ee 1f             	shr    $0x1f,%esi
f0104bb3:	01 c6                	add    %eax,%esi
f0104bb5:	d1 fe                	sar    %esi
f0104bb7:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104bba:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104bbd:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104bc0:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104bc2:	eb 03                	jmp    f0104bc7 <stab_binsearch+0x43>
			m--;
f0104bc4:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104bc7:	39 c3                	cmp    %eax,%ebx
f0104bc9:	7f 0d                	jg     f0104bd8 <stab_binsearch+0x54>
f0104bcb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104bcf:	83 ea 0c             	sub    $0xc,%edx
f0104bd2:	39 f9                	cmp    %edi,%ecx
f0104bd4:	75 ee                	jne    f0104bc4 <stab_binsearch+0x40>
f0104bd6:	eb 05                	jmp    f0104bdd <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104bd8:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104bdb:	eb 4b                	jmp    f0104c28 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104bdd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104be0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104be3:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104be7:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104bea:	76 11                	jbe    f0104bfd <stab_binsearch+0x79>
			*region_left = m;
f0104bec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104bef:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104bf1:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104bf4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104bfb:	eb 2b                	jmp    f0104c28 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104bfd:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c00:	73 14                	jae    f0104c16 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104c02:	83 e8 01             	sub    $0x1,%eax
f0104c05:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c08:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c0b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c0d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c14:	eb 12                	jmp    f0104c28 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104c16:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c19:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104c1b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104c1f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c21:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104c28:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104c2b:	0f 8e 78 ff ff ff    	jle    f0104ba9 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104c31:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104c35:	75 0f                	jne    f0104c46 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104c37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c3a:	8b 00                	mov    (%eax),%eax
f0104c3c:	83 e8 01             	sub    $0x1,%eax
f0104c3f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c42:	89 06                	mov    %eax,(%esi)
f0104c44:	eb 2c                	jmp    f0104c72 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c46:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c49:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104c4b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c4e:	8b 0e                	mov    (%esi),%ecx
f0104c50:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c53:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104c56:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c59:	eb 03                	jmp    f0104c5e <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104c5b:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104c5e:	39 c8                	cmp    %ecx,%eax
f0104c60:	7e 0b                	jle    f0104c6d <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104c62:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104c66:	83 ea 0c             	sub    $0xc,%edx
f0104c69:	39 df                	cmp    %ebx,%edi
f0104c6b:	75 ee                	jne    f0104c5b <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104c6d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c70:	89 06                	mov    %eax,(%esi)
	}
}
f0104c72:	83 c4 14             	add    $0x14,%esp
f0104c75:	5b                   	pop    %ebx
f0104c76:	5e                   	pop    %esi
f0104c77:	5f                   	pop    %edi
f0104c78:	5d                   	pop    %ebp
f0104c79:	c3                   	ret    

f0104c7a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104c7a:	55                   	push   %ebp
f0104c7b:	89 e5                	mov    %esp,%ebp
f0104c7d:	57                   	push   %edi
f0104c7e:	56                   	push   %esi
f0104c7f:	53                   	push   %ebx
f0104c80:	83 ec 3c             	sub    $0x3c,%esp
f0104c83:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104c89:	c7 03 f4 7a 10 f0    	movl   $0xf0107af4,(%ebx)
	info->eip_line = 0;
f0104c8f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104c96:	c7 43 08 f4 7a 10 f0 	movl   $0xf0107af4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104c9d:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104ca4:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104ca7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104cae:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104cb4:	0f 87 a3 00 00 00    	ja     f0104d5d <debuginfo_eip+0xe3>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U | PTE_P))
f0104cba:	e8 4f 10 00 00       	call   f0105d0e <cpunum>
f0104cbf:	6a 05                	push   $0x5
f0104cc1:	6a 10                	push   $0x10
f0104cc3:	68 00 00 20 00       	push   $0x200000
f0104cc8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ccb:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104cd1:	e8 f2 df ff ff       	call   f0102cc8 <user_mem_check>
f0104cd6:	83 c4 10             	add    $0x10,%esp
f0104cd9:	85 c0                	test   %eax,%eax
f0104cdb:	0f 85 3e 02 00 00    	jne    f0104f1f <debuginfo_eip+0x2a5>
			return -1;

		stabs = usd->stabs;
f0104ce1:	a1 00 00 20 00       	mov    0x200000,%eax
f0104ce6:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104ce9:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104cef:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104cf5:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104cf8:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104cfd:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if ((user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P)) ||
f0104d00:	e8 09 10 00 00       	call   f0105d0e <cpunum>
f0104d05:	6a 05                	push   $0x5
f0104d07:	89 f2                	mov    %esi,%edx
f0104d09:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104d0c:	29 ca                	sub    %ecx,%edx
f0104d0e:	c1 fa 02             	sar    $0x2,%edx
f0104d11:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104d17:	52                   	push   %edx
f0104d18:	51                   	push   %ecx
f0104d19:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d1c:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104d22:	e8 a1 df ff ff       	call   f0102cc8 <user_mem_check>
f0104d27:	83 c4 10             	add    $0x10,%esp
f0104d2a:	85 c0                	test   %eax,%eax
f0104d2c:	0f 85 f4 01 00 00    	jne    f0104f26 <debuginfo_eip+0x2ac>
			(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P)))
f0104d32:	e8 d7 0f 00 00       	call   f0105d0e <cpunum>
f0104d37:	6a 05                	push   $0x5
f0104d39:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104d3c:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104d3f:	29 ca                	sub    %ecx,%edx
f0104d41:	52                   	push   %edx
f0104d42:	51                   	push   %ecx
f0104d43:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d46:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104d4c:	e8 77 df ff ff       	call   f0102cc8 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if ((user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P)) ||
f0104d51:	83 c4 10             	add    $0x10,%esp
f0104d54:	85 c0                	test   %eax,%eax
f0104d56:	74 1f                	je     f0104d77 <debuginfo_eip+0xfd>
f0104d58:	e9 d0 01 00 00       	jmp    f0104f2d <debuginfo_eip+0x2b3>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104d5d:	c7 45 bc e3 56 11 f0 	movl   $0xf01156e3,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104d64:	c7 45 b8 31 20 11 f0 	movl   $0xf0112031,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104d6b:	be 30 20 11 f0       	mov    $0xf0112030,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104d70:	c7 45 c0 d4 7f 10 f0 	movl   $0xf0107fd4,-0x40(%ebp)
			(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P)))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d77:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104d7a:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104d7d:	0f 83 b1 01 00 00    	jae    f0104f34 <debuginfo_eip+0x2ba>
f0104d83:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104d87:	0f 85 ae 01 00 00    	jne    f0104f3b <debuginfo_eip+0x2c1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104d8d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104d94:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104d97:	c1 fe 02             	sar    $0x2,%esi
f0104d9a:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104da0:	83 e8 01             	sub    $0x1,%eax
f0104da3:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104da6:	83 ec 08             	sub    $0x8,%esp
f0104da9:	57                   	push   %edi
f0104daa:	6a 64                	push   $0x64
f0104dac:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104daf:	89 d1                	mov    %edx,%ecx
f0104db1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104db4:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104db7:	89 f0                	mov    %esi,%eax
f0104db9:	e8 c6 fd ff ff       	call   f0104b84 <stab_binsearch>
	if (lfile == 0)
f0104dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dc1:	83 c4 10             	add    $0x10,%esp
f0104dc4:	85 c0                	test   %eax,%eax
f0104dc6:	0f 84 76 01 00 00    	je     f0104f42 <debuginfo_eip+0x2c8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104dcc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104dcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104dd2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104dd5:	83 ec 08             	sub    $0x8,%esp
f0104dd8:	57                   	push   %edi
f0104dd9:	6a 24                	push   $0x24
f0104ddb:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104dde:	89 d1                	mov    %edx,%ecx
f0104de0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104de3:	89 f0                	mov    %esi,%eax
f0104de5:	e8 9a fd ff ff       	call   f0104b84 <stab_binsearch>

	if (lfun <= rfun) {
f0104dea:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ded:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104df0:	83 c4 10             	add    $0x10,%esp
f0104df3:	39 d0                	cmp    %edx,%eax
f0104df5:	7f 2e                	jg     f0104e25 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104df7:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104dfa:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104dfd:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104e00:	8b 36                	mov    (%esi),%esi
f0104e02:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104e05:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104e08:	39 ce                	cmp    %ecx,%esi
f0104e0a:	73 06                	jae    f0104e12 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e0c:	03 75 b8             	add    -0x48(%ebp),%esi
f0104e0f:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e12:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104e15:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104e18:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104e1b:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104e1d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104e20:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104e23:	eb 0f                	jmp    f0104e34 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104e25:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104e28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e2b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104e2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e31:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e34:	83 ec 08             	sub    $0x8,%esp
f0104e37:	6a 3a                	push   $0x3a
f0104e39:	ff 73 08             	pushl  0x8(%ebx)
f0104e3c:	e8 8f 08 00 00       	call   f01056d0 <strfind>
f0104e41:	2b 43 08             	sub    0x8(%ebx),%eax
f0104e44:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104e47:	83 c4 08             	add    $0x8,%esp
f0104e4a:	57                   	push   %edi
f0104e4b:	6a 44                	push   $0x44
f0104e4d:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104e50:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104e53:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104e56:	89 f8                	mov    %edi,%eax
f0104e58:	e8 27 fd ff ff       	call   f0104b84 <stab_binsearch>
	if(lline > rline)
f0104e5d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e60:	83 c4 10             	add    $0x10,%esp
f0104e63:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104e66:	0f 8f dd 00 00 00    	jg     f0104f49 <debuginfo_eip+0x2cf>
		return -1;
	info->eip_line =  stabs[lline].n_desc;
f0104e6c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104e6f:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104e72:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0104e76:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e7c:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104e80:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e83:	eb 0a                	jmp    f0104e8f <debuginfo_eip+0x215>
f0104e85:	83 e8 01             	sub    $0x1,%eax
f0104e88:	83 ea 0c             	sub    $0xc,%edx
f0104e8b:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104e8f:	39 c7                	cmp    %eax,%edi
f0104e91:	7e 05                	jle    f0104e98 <debuginfo_eip+0x21e>
f0104e93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e96:	eb 47                	jmp    f0104edf <debuginfo_eip+0x265>
	       && stabs[lline].n_type != N_SOL
f0104e98:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104e9c:	80 f9 84             	cmp    $0x84,%cl
f0104e9f:	75 0e                	jne    f0104eaf <debuginfo_eip+0x235>
f0104ea1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ea4:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ea8:	74 1c                	je     f0104ec6 <debuginfo_eip+0x24c>
f0104eaa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104ead:	eb 17                	jmp    f0104ec6 <debuginfo_eip+0x24c>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104eaf:	80 f9 64             	cmp    $0x64,%cl
f0104eb2:	75 d1                	jne    f0104e85 <debuginfo_eip+0x20b>
f0104eb4:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104eb8:	74 cb                	je     f0104e85 <debuginfo_eip+0x20b>
f0104eba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ebd:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104ec1:	74 03                	je     f0104ec6 <debuginfo_eip+0x24c>
f0104ec3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ec6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104ec9:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104ecc:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104ecf:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104ed2:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104ed5:	29 f8                	sub    %edi,%eax
f0104ed7:	39 c2                	cmp    %eax,%edx
f0104ed9:	73 04                	jae    f0104edf <debuginfo_eip+0x265>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104edb:	01 fa                	add    %edi,%edx
f0104edd:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104edf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104ee2:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ee5:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104eea:	39 f2                	cmp    %esi,%edx
f0104eec:	7d 67                	jge    f0104f55 <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
f0104eee:	83 c2 01             	add    $0x1,%edx
f0104ef1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104ef4:	89 d0                	mov    %edx,%eax
f0104ef6:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104ef9:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104efc:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104eff:	eb 04                	jmp    f0104f05 <debuginfo_eip+0x28b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104f01:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104f05:	39 c6                	cmp    %eax,%esi
f0104f07:	7e 47                	jle    f0104f50 <debuginfo_eip+0x2d6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104f09:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f0d:	83 c0 01             	add    $0x1,%eax
f0104f10:	83 c2 0c             	add    $0xc,%edx
f0104f13:	80 f9 a0             	cmp    $0xa0,%cl
f0104f16:	74 e9                	je     f0104f01 <debuginfo_eip+0x287>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f18:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f1d:	eb 36                	jmp    f0104f55 <debuginfo_eip+0x2db>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U | PTE_P))
			return -1;
f0104f1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f24:	eb 2f                	jmp    f0104f55 <debuginfo_eip+0x2db>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if ((user_mem_check(curenv, stabs, stab_end - stabs, PTE_U | PTE_P)) ||
			(user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U | PTE_P)))
			return -1;
f0104f26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f2b:	eb 28                	jmp    f0104f55 <debuginfo_eip+0x2db>
f0104f2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f32:	eb 21                	jmp    f0104f55 <debuginfo_eip+0x2db>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104f34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f39:	eb 1a                	jmp    f0104f55 <debuginfo_eip+0x2db>
f0104f3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f40:	eb 13                	jmp    f0104f55 <debuginfo_eip+0x2db>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f47:	eb 0c                	jmp    f0104f55 <debuginfo_eip+0x2db>
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline > rline)
		return -1;
f0104f49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f4e:	eb 05                	jmp    f0104f55 <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104f50:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f58:	5b                   	pop    %ebx
f0104f59:	5e                   	pop    %esi
f0104f5a:	5f                   	pop    %edi
f0104f5b:	5d                   	pop    %ebp
f0104f5c:	c3                   	ret    

f0104f5d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f5d:	55                   	push   %ebp
f0104f5e:	89 e5                	mov    %esp,%ebp
f0104f60:	57                   	push   %edi
f0104f61:	56                   	push   %esi
f0104f62:	53                   	push   %ebx
f0104f63:	83 ec 1c             	sub    $0x1c,%esp
f0104f66:	89 c7                	mov    %eax,%edi
f0104f68:	89 d6                	mov    %edx,%esi
f0104f6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f6d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f70:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f73:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104f76:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f79:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f7e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f81:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104f84:	39 d3                	cmp    %edx,%ebx
f0104f86:	72 05                	jb     f0104f8d <printnum+0x30>
f0104f88:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104f8b:	77 45                	ja     f0104fd2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104f8d:	83 ec 0c             	sub    $0xc,%esp
f0104f90:	ff 75 18             	pushl  0x18(%ebp)
f0104f93:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f96:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104f99:	53                   	push   %ebx
f0104f9a:	ff 75 10             	pushl  0x10(%ebp)
f0104f9d:	83 ec 08             	sub    $0x8,%esp
f0104fa0:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fa3:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fa6:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fa9:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fac:	e8 5f 11 00 00       	call   f0106110 <__udivdi3>
f0104fb1:	83 c4 18             	add    $0x18,%esp
f0104fb4:	52                   	push   %edx
f0104fb5:	50                   	push   %eax
f0104fb6:	89 f2                	mov    %esi,%edx
f0104fb8:	89 f8                	mov    %edi,%eax
f0104fba:	e8 9e ff ff ff       	call   f0104f5d <printnum>
f0104fbf:	83 c4 20             	add    $0x20,%esp
f0104fc2:	eb 18                	jmp    f0104fdc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104fc4:	83 ec 08             	sub    $0x8,%esp
f0104fc7:	56                   	push   %esi
f0104fc8:	ff 75 18             	pushl  0x18(%ebp)
f0104fcb:	ff d7                	call   *%edi
f0104fcd:	83 c4 10             	add    $0x10,%esp
f0104fd0:	eb 03                	jmp    f0104fd5 <printnum+0x78>
f0104fd2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104fd5:	83 eb 01             	sub    $0x1,%ebx
f0104fd8:	85 db                	test   %ebx,%ebx
f0104fda:	7f e8                	jg     f0104fc4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104fdc:	83 ec 08             	sub    $0x8,%esp
f0104fdf:	56                   	push   %esi
f0104fe0:	83 ec 04             	sub    $0x4,%esp
f0104fe3:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104fe6:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fe9:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fec:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fef:	e8 4c 12 00 00       	call   f0106240 <__umoddi3>
f0104ff4:	83 c4 14             	add    $0x14,%esp
f0104ff7:	0f be 80 fe 7a 10 f0 	movsbl -0xfef8502(%eax),%eax
f0104ffe:	50                   	push   %eax
f0104fff:	ff d7                	call   *%edi
}
f0105001:	83 c4 10             	add    $0x10,%esp
f0105004:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105007:	5b                   	pop    %ebx
f0105008:	5e                   	pop    %esi
f0105009:	5f                   	pop    %edi
f010500a:	5d                   	pop    %ebp
f010500b:	c3                   	ret    

f010500c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010500c:	55                   	push   %ebp
f010500d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f010500f:	83 fa 01             	cmp    $0x1,%edx
f0105012:	7e 0e                	jle    f0105022 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105014:	8b 10                	mov    (%eax),%edx
f0105016:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105019:	89 08                	mov    %ecx,(%eax)
f010501b:	8b 02                	mov    (%edx),%eax
f010501d:	8b 52 04             	mov    0x4(%edx),%edx
f0105020:	eb 22                	jmp    f0105044 <getuint+0x38>
	else if (lflag)
f0105022:	85 d2                	test   %edx,%edx
f0105024:	74 10                	je     f0105036 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105026:	8b 10                	mov    (%eax),%edx
f0105028:	8d 4a 04             	lea    0x4(%edx),%ecx
f010502b:	89 08                	mov    %ecx,(%eax)
f010502d:	8b 02                	mov    (%edx),%eax
f010502f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105034:	eb 0e                	jmp    f0105044 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105036:	8b 10                	mov    (%eax),%edx
f0105038:	8d 4a 04             	lea    0x4(%edx),%ecx
f010503b:	89 08                	mov    %ecx,(%eax)
f010503d:	8b 02                	mov    (%edx),%eax
f010503f:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105044:	5d                   	pop    %ebp
f0105045:	c3                   	ret    

f0105046 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105046:	55                   	push   %ebp
f0105047:	89 e5                	mov    %esp,%ebp
f0105049:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010504c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105050:	8b 10                	mov    (%eax),%edx
f0105052:	3b 50 04             	cmp    0x4(%eax),%edx
f0105055:	73 0a                	jae    f0105061 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105057:	8d 4a 01             	lea    0x1(%edx),%ecx
f010505a:	89 08                	mov    %ecx,(%eax)
f010505c:	8b 45 08             	mov    0x8(%ebp),%eax
f010505f:	88 02                	mov    %al,(%edx)
}
f0105061:	5d                   	pop    %ebp
f0105062:	c3                   	ret    

f0105063 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105063:	55                   	push   %ebp
f0105064:	89 e5                	mov    %esp,%ebp
f0105066:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0105069:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010506c:	50                   	push   %eax
f010506d:	ff 75 10             	pushl  0x10(%ebp)
f0105070:	ff 75 0c             	pushl  0xc(%ebp)
f0105073:	ff 75 08             	pushl  0x8(%ebp)
f0105076:	e8 05 00 00 00       	call   f0105080 <vprintfmt>
	va_end(ap);
}
f010507b:	83 c4 10             	add    $0x10,%esp
f010507e:	c9                   	leave  
f010507f:	c3                   	ret    

f0105080 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0105080:	55                   	push   %ebp
f0105081:	89 e5                	mov    %esp,%ebp
f0105083:	57                   	push   %edi
f0105084:	56                   	push   %esi
f0105085:	53                   	push   %ebx
f0105086:	83 ec 2c             	sub    $0x2c,%esp
f0105089:	8b 75 08             	mov    0x8(%ebp),%esi
f010508c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010508f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105092:	eb 12                	jmp    f01050a6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0105094:	85 c0                	test   %eax,%eax
f0105096:	0f 84 89 03 00 00    	je     f0105425 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f010509c:	83 ec 08             	sub    $0x8,%esp
f010509f:	53                   	push   %ebx
f01050a0:	50                   	push   %eax
f01050a1:	ff d6                	call   *%esi
f01050a3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01050a6:	83 c7 01             	add    $0x1,%edi
f01050a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01050ad:	83 f8 25             	cmp    $0x25,%eax
f01050b0:	75 e2                	jne    f0105094 <vprintfmt+0x14>
f01050b2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01050b6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01050bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01050c4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01050cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01050d0:	eb 07                	jmp    f01050d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f01050d5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050d9:	8d 47 01             	lea    0x1(%edi),%eax
f01050dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01050df:	0f b6 07             	movzbl (%edi),%eax
f01050e2:	0f b6 c8             	movzbl %al,%ecx
f01050e5:	83 e8 23             	sub    $0x23,%eax
f01050e8:	3c 55                	cmp    $0x55,%al
f01050ea:	0f 87 1a 03 00 00    	ja     f010540a <vprintfmt+0x38a>
f01050f0:	0f b6 c0             	movzbl %al,%eax
f01050f3:	ff 24 85 c0 7b 10 f0 	jmp    *-0xfef8440(,%eax,4)
f01050fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01050fd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105101:	eb d6                	jmp    f01050d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105103:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105106:	b8 00 00 00 00       	mov    $0x0,%eax
f010510b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010510e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105111:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0105115:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0105118:	8d 51 d0             	lea    -0x30(%ecx),%edx
f010511b:	83 fa 09             	cmp    $0x9,%edx
f010511e:	77 39                	ja     f0105159 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105120:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105123:	eb e9                	jmp    f010510e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105125:	8b 45 14             	mov    0x14(%ebp),%eax
f0105128:	8d 48 04             	lea    0x4(%eax),%ecx
f010512b:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010512e:	8b 00                	mov    (%eax),%eax
f0105130:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105133:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105136:	eb 27                	jmp    f010515f <vprintfmt+0xdf>
f0105138:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010513b:	85 c0                	test   %eax,%eax
f010513d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105142:	0f 49 c8             	cmovns %eax,%ecx
f0105145:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105148:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010514b:	eb 8c                	jmp    f01050d9 <vprintfmt+0x59>
f010514d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105150:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105157:	eb 80                	jmp    f01050d9 <vprintfmt+0x59>
f0105159:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010515c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f010515f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105163:	0f 89 70 ff ff ff    	jns    f01050d9 <vprintfmt+0x59>
				width = precision, precision = -1;
f0105169:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010516c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010516f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105176:	e9 5e ff ff ff       	jmp    f01050d9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010517b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010517e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105181:	e9 53 ff ff ff       	jmp    f01050d9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105186:	8b 45 14             	mov    0x14(%ebp),%eax
f0105189:	8d 50 04             	lea    0x4(%eax),%edx
f010518c:	89 55 14             	mov    %edx,0x14(%ebp)
f010518f:	83 ec 08             	sub    $0x8,%esp
f0105192:	53                   	push   %ebx
f0105193:	ff 30                	pushl  (%eax)
f0105195:	ff d6                	call   *%esi
			break;
f0105197:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010519a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010519d:	e9 04 ff ff ff       	jmp    f01050a6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01051a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01051a5:	8d 50 04             	lea    0x4(%eax),%edx
f01051a8:	89 55 14             	mov    %edx,0x14(%ebp)
f01051ab:	8b 00                	mov    (%eax),%eax
f01051ad:	99                   	cltd   
f01051ae:	31 d0                	xor    %edx,%eax
f01051b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01051b2:	83 f8 08             	cmp    $0x8,%eax
f01051b5:	7f 0b                	jg     f01051c2 <vprintfmt+0x142>
f01051b7:	8b 14 85 20 7d 10 f0 	mov    -0xfef82e0(,%eax,4),%edx
f01051be:	85 d2                	test   %edx,%edx
f01051c0:	75 18                	jne    f01051da <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f01051c2:	50                   	push   %eax
f01051c3:	68 16 7b 10 f0       	push   $0xf0107b16
f01051c8:	53                   	push   %ebx
f01051c9:	56                   	push   %esi
f01051ca:	e8 94 fe ff ff       	call   f0105063 <printfmt>
f01051cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01051d5:	e9 cc fe ff ff       	jmp    f01050a6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01051da:	52                   	push   %edx
f01051db:	68 7a 69 10 f0       	push   $0xf010697a
f01051e0:	53                   	push   %ebx
f01051e1:	56                   	push   %esi
f01051e2:	e8 7c fe ff ff       	call   f0105063 <printfmt>
f01051e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01051ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051ed:	e9 b4 fe ff ff       	jmp    f01050a6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01051f2:	8b 45 14             	mov    0x14(%ebp),%eax
f01051f5:	8d 50 04             	lea    0x4(%eax),%edx
f01051f8:	89 55 14             	mov    %edx,0x14(%ebp)
f01051fb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01051fd:	85 ff                	test   %edi,%edi
f01051ff:	b8 0f 7b 10 f0       	mov    $0xf0107b0f,%eax
f0105204:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105207:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010520b:	0f 8e 94 00 00 00    	jle    f01052a5 <vprintfmt+0x225>
f0105211:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105215:	0f 84 98 00 00 00    	je     f01052b3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f010521b:	83 ec 08             	sub    $0x8,%esp
f010521e:	ff 75 d0             	pushl  -0x30(%ebp)
f0105221:	57                   	push   %edi
f0105222:	e8 5f 03 00 00       	call   f0105586 <strnlen>
f0105227:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010522a:	29 c1                	sub    %eax,%ecx
f010522c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010522f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105232:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105236:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105239:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010523c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010523e:	eb 0f                	jmp    f010524f <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105240:	83 ec 08             	sub    $0x8,%esp
f0105243:	53                   	push   %ebx
f0105244:	ff 75 e0             	pushl  -0x20(%ebp)
f0105247:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105249:	83 ef 01             	sub    $0x1,%edi
f010524c:	83 c4 10             	add    $0x10,%esp
f010524f:	85 ff                	test   %edi,%edi
f0105251:	7f ed                	jg     f0105240 <vprintfmt+0x1c0>
f0105253:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105256:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0105259:	85 c9                	test   %ecx,%ecx
f010525b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105260:	0f 49 c1             	cmovns %ecx,%eax
f0105263:	29 c1                	sub    %eax,%ecx
f0105265:	89 75 08             	mov    %esi,0x8(%ebp)
f0105268:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010526b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010526e:	89 cb                	mov    %ecx,%ebx
f0105270:	eb 4d                	jmp    f01052bf <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105272:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105276:	74 1b                	je     f0105293 <vprintfmt+0x213>
f0105278:	0f be c0             	movsbl %al,%eax
f010527b:	83 e8 20             	sub    $0x20,%eax
f010527e:	83 f8 5e             	cmp    $0x5e,%eax
f0105281:	76 10                	jbe    f0105293 <vprintfmt+0x213>
					putch('?', putdat);
f0105283:	83 ec 08             	sub    $0x8,%esp
f0105286:	ff 75 0c             	pushl  0xc(%ebp)
f0105289:	6a 3f                	push   $0x3f
f010528b:	ff 55 08             	call   *0x8(%ebp)
f010528e:	83 c4 10             	add    $0x10,%esp
f0105291:	eb 0d                	jmp    f01052a0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105293:	83 ec 08             	sub    $0x8,%esp
f0105296:	ff 75 0c             	pushl  0xc(%ebp)
f0105299:	52                   	push   %edx
f010529a:	ff 55 08             	call   *0x8(%ebp)
f010529d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01052a0:	83 eb 01             	sub    $0x1,%ebx
f01052a3:	eb 1a                	jmp    f01052bf <vprintfmt+0x23f>
f01052a5:	89 75 08             	mov    %esi,0x8(%ebp)
f01052a8:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052ab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052ae:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052b1:	eb 0c                	jmp    f01052bf <vprintfmt+0x23f>
f01052b3:	89 75 08             	mov    %esi,0x8(%ebp)
f01052b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01052b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01052bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01052bf:	83 c7 01             	add    $0x1,%edi
f01052c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01052c6:	0f be d0             	movsbl %al,%edx
f01052c9:	85 d2                	test   %edx,%edx
f01052cb:	74 23                	je     f01052f0 <vprintfmt+0x270>
f01052cd:	85 f6                	test   %esi,%esi
f01052cf:	78 a1                	js     f0105272 <vprintfmt+0x1f2>
f01052d1:	83 ee 01             	sub    $0x1,%esi
f01052d4:	79 9c                	jns    f0105272 <vprintfmt+0x1f2>
f01052d6:	89 df                	mov    %ebx,%edi
f01052d8:	8b 75 08             	mov    0x8(%ebp),%esi
f01052db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01052de:	eb 18                	jmp    f01052f8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01052e0:	83 ec 08             	sub    $0x8,%esp
f01052e3:	53                   	push   %ebx
f01052e4:	6a 20                	push   $0x20
f01052e6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01052e8:	83 ef 01             	sub    $0x1,%edi
f01052eb:	83 c4 10             	add    $0x10,%esp
f01052ee:	eb 08                	jmp    f01052f8 <vprintfmt+0x278>
f01052f0:	89 df                	mov    %ebx,%edi
f01052f2:	8b 75 08             	mov    0x8(%ebp),%esi
f01052f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01052f8:	85 ff                	test   %edi,%edi
f01052fa:	7f e4                	jg     f01052e0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01052fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052ff:	e9 a2 fd ff ff       	jmp    f01050a6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105304:	83 fa 01             	cmp    $0x1,%edx
f0105307:	7e 16                	jle    f010531f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105309:	8b 45 14             	mov    0x14(%ebp),%eax
f010530c:	8d 50 08             	lea    0x8(%eax),%edx
f010530f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105312:	8b 50 04             	mov    0x4(%eax),%edx
f0105315:	8b 00                	mov    (%eax),%eax
f0105317:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010531a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010531d:	eb 32                	jmp    f0105351 <vprintfmt+0x2d1>
	else if (lflag)
f010531f:	85 d2                	test   %edx,%edx
f0105321:	74 18                	je     f010533b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105323:	8b 45 14             	mov    0x14(%ebp),%eax
f0105326:	8d 50 04             	lea    0x4(%eax),%edx
f0105329:	89 55 14             	mov    %edx,0x14(%ebp)
f010532c:	8b 00                	mov    (%eax),%eax
f010532e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105331:	89 c1                	mov    %eax,%ecx
f0105333:	c1 f9 1f             	sar    $0x1f,%ecx
f0105336:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105339:	eb 16                	jmp    f0105351 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f010533b:	8b 45 14             	mov    0x14(%ebp),%eax
f010533e:	8d 50 04             	lea    0x4(%eax),%edx
f0105341:	89 55 14             	mov    %edx,0x14(%ebp)
f0105344:	8b 00                	mov    (%eax),%eax
f0105346:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105349:	89 c1                	mov    %eax,%ecx
f010534b:	c1 f9 1f             	sar    $0x1f,%ecx
f010534e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105351:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105354:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105357:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010535c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105360:	79 74                	jns    f01053d6 <vprintfmt+0x356>
				putch('-', putdat);
f0105362:	83 ec 08             	sub    $0x8,%esp
f0105365:	53                   	push   %ebx
f0105366:	6a 2d                	push   $0x2d
f0105368:	ff d6                	call   *%esi
				num = -(long long) num;
f010536a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010536d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105370:	f7 d8                	neg    %eax
f0105372:	83 d2 00             	adc    $0x0,%edx
f0105375:	f7 da                	neg    %edx
f0105377:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010537a:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010537f:	eb 55                	jmp    f01053d6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105381:	8d 45 14             	lea    0x14(%ebp),%eax
f0105384:	e8 83 fc ff ff       	call   f010500c <getuint>
			base = 10;
f0105389:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010538e:	eb 46                	jmp    f01053d6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105390:	8d 45 14             	lea    0x14(%ebp),%eax
f0105393:	e8 74 fc ff ff       	call   f010500c <getuint>
			base = 8;
f0105398:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010539d:	eb 37                	jmp    f01053d6 <vprintfmt+0x356>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f010539f:	83 ec 08             	sub    $0x8,%esp
f01053a2:	53                   	push   %ebx
f01053a3:	6a 30                	push   $0x30
f01053a5:	ff d6                	call   *%esi
			putch('x', putdat);
f01053a7:	83 c4 08             	add    $0x8,%esp
f01053aa:	53                   	push   %ebx
f01053ab:	6a 78                	push   $0x78
f01053ad:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01053af:	8b 45 14             	mov    0x14(%ebp),%eax
f01053b2:	8d 50 04             	lea    0x4(%eax),%edx
f01053b5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01053b8:	8b 00                	mov    (%eax),%eax
f01053ba:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01053bf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01053c2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01053c7:	eb 0d                	jmp    f01053d6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01053c9:	8d 45 14             	lea    0x14(%ebp),%eax
f01053cc:	e8 3b fc ff ff       	call   f010500c <getuint>
			base = 16;
f01053d1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01053d6:	83 ec 0c             	sub    $0xc,%esp
f01053d9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01053dd:	57                   	push   %edi
f01053de:	ff 75 e0             	pushl  -0x20(%ebp)
f01053e1:	51                   	push   %ecx
f01053e2:	52                   	push   %edx
f01053e3:	50                   	push   %eax
f01053e4:	89 da                	mov    %ebx,%edx
f01053e6:	89 f0                	mov    %esi,%eax
f01053e8:	e8 70 fb ff ff       	call   f0104f5d <printnum>
			break;
f01053ed:	83 c4 20             	add    $0x20,%esp
f01053f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01053f3:	e9 ae fc ff ff       	jmp    f01050a6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01053f8:	83 ec 08             	sub    $0x8,%esp
f01053fb:	53                   	push   %ebx
f01053fc:	51                   	push   %ecx
f01053fd:	ff d6                	call   *%esi
			break;
f01053ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105405:	e9 9c fc ff ff       	jmp    f01050a6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010540a:	83 ec 08             	sub    $0x8,%esp
f010540d:	53                   	push   %ebx
f010540e:	6a 25                	push   $0x25
f0105410:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105412:	83 c4 10             	add    $0x10,%esp
f0105415:	eb 03                	jmp    f010541a <vprintfmt+0x39a>
f0105417:	83 ef 01             	sub    $0x1,%edi
f010541a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010541e:	75 f7                	jne    f0105417 <vprintfmt+0x397>
f0105420:	e9 81 fc ff ff       	jmp    f01050a6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105425:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105428:	5b                   	pop    %ebx
f0105429:	5e                   	pop    %esi
f010542a:	5f                   	pop    %edi
f010542b:	5d                   	pop    %ebp
f010542c:	c3                   	ret    

f010542d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010542d:	55                   	push   %ebp
f010542e:	89 e5                	mov    %esp,%ebp
f0105430:	83 ec 18             	sub    $0x18,%esp
f0105433:	8b 45 08             	mov    0x8(%ebp),%eax
f0105436:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105439:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010543c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105440:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105443:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010544a:	85 c0                	test   %eax,%eax
f010544c:	74 26                	je     f0105474 <vsnprintf+0x47>
f010544e:	85 d2                	test   %edx,%edx
f0105450:	7e 22                	jle    f0105474 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105452:	ff 75 14             	pushl  0x14(%ebp)
f0105455:	ff 75 10             	pushl  0x10(%ebp)
f0105458:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010545b:	50                   	push   %eax
f010545c:	68 46 50 10 f0       	push   $0xf0105046
f0105461:	e8 1a fc ff ff       	call   f0105080 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105466:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105469:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010546c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010546f:	83 c4 10             	add    $0x10,%esp
f0105472:	eb 05                	jmp    f0105479 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105474:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105479:	c9                   	leave  
f010547a:	c3                   	ret    

f010547b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010547b:	55                   	push   %ebp
f010547c:	89 e5                	mov    %esp,%ebp
f010547e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105481:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105484:	50                   	push   %eax
f0105485:	ff 75 10             	pushl  0x10(%ebp)
f0105488:	ff 75 0c             	pushl  0xc(%ebp)
f010548b:	ff 75 08             	pushl  0x8(%ebp)
f010548e:	e8 9a ff ff ff       	call   f010542d <vsnprintf>
	va_end(ap);

	return rc;
}
f0105493:	c9                   	leave  
f0105494:	c3                   	ret    

f0105495 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105495:	55                   	push   %ebp
f0105496:	89 e5                	mov    %esp,%ebp
f0105498:	57                   	push   %edi
f0105499:	56                   	push   %esi
f010549a:	53                   	push   %ebx
f010549b:	83 ec 0c             	sub    $0xc,%esp
f010549e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01054a1:	85 c0                	test   %eax,%eax
f01054a3:	74 11                	je     f01054b6 <readline+0x21>
		cprintf("%s", prompt);
f01054a5:	83 ec 08             	sub    $0x8,%esp
f01054a8:	50                   	push   %eax
f01054a9:	68 7a 69 10 f0       	push   $0xf010697a
f01054ae:	e8 55 e2 ff ff       	call   f0103708 <cprintf>
f01054b3:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01054b6:	83 ec 0c             	sub    $0xc,%esp
f01054b9:	6a 00                	push   $0x0
f01054bb:	e8 c5 b2 ff ff       	call   f0100785 <iscons>
f01054c0:	89 c7                	mov    %eax,%edi
f01054c2:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01054c5:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01054ca:	e8 a5 b2 ff ff       	call   f0100774 <getchar>
f01054cf:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01054d1:	85 c0                	test   %eax,%eax
f01054d3:	79 18                	jns    f01054ed <readline+0x58>
			cprintf("read error: %e\n", c);
f01054d5:	83 ec 08             	sub    $0x8,%esp
f01054d8:	50                   	push   %eax
f01054d9:	68 44 7d 10 f0       	push   $0xf0107d44
f01054de:	e8 25 e2 ff ff       	call   f0103708 <cprintf>
			return NULL;
f01054e3:	83 c4 10             	add    $0x10,%esp
f01054e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01054eb:	eb 79                	jmp    f0105566 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01054ed:	83 f8 08             	cmp    $0x8,%eax
f01054f0:	0f 94 c2             	sete   %dl
f01054f3:	83 f8 7f             	cmp    $0x7f,%eax
f01054f6:	0f 94 c0             	sete   %al
f01054f9:	08 c2                	or     %al,%dl
f01054fb:	74 1a                	je     f0105517 <readline+0x82>
f01054fd:	85 f6                	test   %esi,%esi
f01054ff:	7e 16                	jle    f0105517 <readline+0x82>
			if (echoing)
f0105501:	85 ff                	test   %edi,%edi
f0105503:	74 0d                	je     f0105512 <readline+0x7d>
				cputchar('\b');
f0105505:	83 ec 0c             	sub    $0xc,%esp
f0105508:	6a 08                	push   $0x8
f010550a:	e8 55 b2 ff ff       	call   f0100764 <cputchar>
f010550f:	83 c4 10             	add    $0x10,%esp
			i--;
f0105512:	83 ee 01             	sub    $0x1,%esi
f0105515:	eb b3                	jmp    f01054ca <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105517:	83 fb 1f             	cmp    $0x1f,%ebx
f010551a:	7e 23                	jle    f010553f <readline+0xaa>
f010551c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105522:	7f 1b                	jg     f010553f <readline+0xaa>
			if (echoing)
f0105524:	85 ff                	test   %edi,%edi
f0105526:	74 0c                	je     f0105534 <readline+0x9f>
				cputchar(c);
f0105528:	83 ec 0c             	sub    $0xc,%esp
f010552b:	53                   	push   %ebx
f010552c:	e8 33 b2 ff ff       	call   f0100764 <cputchar>
f0105531:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105534:	88 9e 80 fa 22 f0    	mov    %bl,-0xfdd0580(%esi)
f010553a:	8d 76 01             	lea    0x1(%esi),%esi
f010553d:	eb 8b                	jmp    f01054ca <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010553f:	83 fb 0a             	cmp    $0xa,%ebx
f0105542:	74 05                	je     f0105549 <readline+0xb4>
f0105544:	83 fb 0d             	cmp    $0xd,%ebx
f0105547:	75 81                	jne    f01054ca <readline+0x35>
			if (echoing)
f0105549:	85 ff                	test   %edi,%edi
f010554b:	74 0d                	je     f010555a <readline+0xc5>
				cputchar('\n');
f010554d:	83 ec 0c             	sub    $0xc,%esp
f0105550:	6a 0a                	push   $0xa
f0105552:	e8 0d b2 ff ff       	call   f0100764 <cputchar>
f0105557:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010555a:	c6 86 80 fa 22 f0 00 	movb   $0x0,-0xfdd0580(%esi)
			return buf;
f0105561:	b8 80 fa 22 f0       	mov    $0xf022fa80,%eax
		}
	}
}
f0105566:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105569:	5b                   	pop    %ebx
f010556a:	5e                   	pop    %esi
f010556b:	5f                   	pop    %edi
f010556c:	5d                   	pop    %ebp
f010556d:	c3                   	ret    

f010556e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010556e:	55                   	push   %ebp
f010556f:	89 e5                	mov    %esp,%ebp
f0105571:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105574:	b8 00 00 00 00       	mov    $0x0,%eax
f0105579:	eb 03                	jmp    f010557e <strlen+0x10>
		n++;
f010557b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010557e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105582:	75 f7                	jne    f010557b <strlen+0xd>
		n++;
	return n;
}
f0105584:	5d                   	pop    %ebp
f0105585:	c3                   	ret    

f0105586 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105586:	55                   	push   %ebp
f0105587:	89 e5                	mov    %esp,%ebp
f0105589:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010558c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010558f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105594:	eb 03                	jmp    f0105599 <strnlen+0x13>
		n++;
f0105596:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105599:	39 c2                	cmp    %eax,%edx
f010559b:	74 08                	je     f01055a5 <strnlen+0x1f>
f010559d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01055a1:	75 f3                	jne    f0105596 <strnlen+0x10>
f01055a3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01055a5:	5d                   	pop    %ebp
f01055a6:	c3                   	ret    

f01055a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01055a7:	55                   	push   %ebp
f01055a8:	89 e5                	mov    %esp,%ebp
f01055aa:	53                   	push   %ebx
f01055ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01055ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01055b1:	89 c2                	mov    %eax,%edx
f01055b3:	83 c2 01             	add    $0x1,%edx
f01055b6:	83 c1 01             	add    $0x1,%ecx
f01055b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01055bd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01055c0:	84 db                	test   %bl,%bl
f01055c2:	75 ef                	jne    f01055b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01055c4:	5b                   	pop    %ebx
f01055c5:	5d                   	pop    %ebp
f01055c6:	c3                   	ret    

f01055c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01055c7:	55                   	push   %ebp
f01055c8:	89 e5                	mov    %esp,%ebp
f01055ca:	53                   	push   %ebx
f01055cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01055ce:	53                   	push   %ebx
f01055cf:	e8 9a ff ff ff       	call   f010556e <strlen>
f01055d4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01055d7:	ff 75 0c             	pushl  0xc(%ebp)
f01055da:	01 d8                	add    %ebx,%eax
f01055dc:	50                   	push   %eax
f01055dd:	e8 c5 ff ff ff       	call   f01055a7 <strcpy>
	return dst;
}
f01055e2:	89 d8                	mov    %ebx,%eax
f01055e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01055e7:	c9                   	leave  
f01055e8:	c3                   	ret    

f01055e9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01055e9:	55                   	push   %ebp
f01055ea:	89 e5                	mov    %esp,%ebp
f01055ec:	56                   	push   %esi
f01055ed:	53                   	push   %ebx
f01055ee:	8b 75 08             	mov    0x8(%ebp),%esi
f01055f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01055f4:	89 f3                	mov    %esi,%ebx
f01055f6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01055f9:	89 f2                	mov    %esi,%edx
f01055fb:	eb 0f                	jmp    f010560c <strncpy+0x23>
		*dst++ = *src;
f01055fd:	83 c2 01             	add    $0x1,%edx
f0105600:	0f b6 01             	movzbl (%ecx),%eax
f0105603:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105606:	80 39 01             	cmpb   $0x1,(%ecx)
f0105609:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010560c:	39 da                	cmp    %ebx,%edx
f010560e:	75 ed                	jne    f01055fd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105610:	89 f0                	mov    %esi,%eax
f0105612:	5b                   	pop    %ebx
f0105613:	5e                   	pop    %esi
f0105614:	5d                   	pop    %ebp
f0105615:	c3                   	ret    

f0105616 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105616:	55                   	push   %ebp
f0105617:	89 e5                	mov    %esp,%ebp
f0105619:	56                   	push   %esi
f010561a:	53                   	push   %ebx
f010561b:	8b 75 08             	mov    0x8(%ebp),%esi
f010561e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105621:	8b 55 10             	mov    0x10(%ebp),%edx
f0105624:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105626:	85 d2                	test   %edx,%edx
f0105628:	74 21                	je     f010564b <strlcpy+0x35>
f010562a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010562e:	89 f2                	mov    %esi,%edx
f0105630:	eb 09                	jmp    f010563b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105632:	83 c2 01             	add    $0x1,%edx
f0105635:	83 c1 01             	add    $0x1,%ecx
f0105638:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010563b:	39 c2                	cmp    %eax,%edx
f010563d:	74 09                	je     f0105648 <strlcpy+0x32>
f010563f:	0f b6 19             	movzbl (%ecx),%ebx
f0105642:	84 db                	test   %bl,%bl
f0105644:	75 ec                	jne    f0105632 <strlcpy+0x1c>
f0105646:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105648:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010564b:	29 f0                	sub    %esi,%eax
}
f010564d:	5b                   	pop    %ebx
f010564e:	5e                   	pop    %esi
f010564f:	5d                   	pop    %ebp
f0105650:	c3                   	ret    

f0105651 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105651:	55                   	push   %ebp
f0105652:	89 e5                	mov    %esp,%ebp
f0105654:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105657:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010565a:	eb 06                	jmp    f0105662 <strcmp+0x11>
		p++, q++;
f010565c:	83 c1 01             	add    $0x1,%ecx
f010565f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105662:	0f b6 01             	movzbl (%ecx),%eax
f0105665:	84 c0                	test   %al,%al
f0105667:	74 04                	je     f010566d <strcmp+0x1c>
f0105669:	3a 02                	cmp    (%edx),%al
f010566b:	74 ef                	je     f010565c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010566d:	0f b6 c0             	movzbl %al,%eax
f0105670:	0f b6 12             	movzbl (%edx),%edx
f0105673:	29 d0                	sub    %edx,%eax
}
f0105675:	5d                   	pop    %ebp
f0105676:	c3                   	ret    

f0105677 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105677:	55                   	push   %ebp
f0105678:	89 e5                	mov    %esp,%ebp
f010567a:	53                   	push   %ebx
f010567b:	8b 45 08             	mov    0x8(%ebp),%eax
f010567e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105681:	89 c3                	mov    %eax,%ebx
f0105683:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105686:	eb 06                	jmp    f010568e <strncmp+0x17>
		n--, p++, q++;
f0105688:	83 c0 01             	add    $0x1,%eax
f010568b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010568e:	39 d8                	cmp    %ebx,%eax
f0105690:	74 15                	je     f01056a7 <strncmp+0x30>
f0105692:	0f b6 08             	movzbl (%eax),%ecx
f0105695:	84 c9                	test   %cl,%cl
f0105697:	74 04                	je     f010569d <strncmp+0x26>
f0105699:	3a 0a                	cmp    (%edx),%cl
f010569b:	74 eb                	je     f0105688 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010569d:	0f b6 00             	movzbl (%eax),%eax
f01056a0:	0f b6 12             	movzbl (%edx),%edx
f01056a3:	29 d0                	sub    %edx,%eax
f01056a5:	eb 05                	jmp    f01056ac <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01056a7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01056ac:	5b                   	pop    %ebx
f01056ad:	5d                   	pop    %ebp
f01056ae:	c3                   	ret    

f01056af <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01056af:	55                   	push   %ebp
f01056b0:	89 e5                	mov    %esp,%ebp
f01056b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01056b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01056b9:	eb 07                	jmp    f01056c2 <strchr+0x13>
		if (*s == c)
f01056bb:	38 ca                	cmp    %cl,%dl
f01056bd:	74 0f                	je     f01056ce <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01056bf:	83 c0 01             	add    $0x1,%eax
f01056c2:	0f b6 10             	movzbl (%eax),%edx
f01056c5:	84 d2                	test   %dl,%dl
f01056c7:	75 f2                	jne    f01056bb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01056c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056ce:	5d                   	pop    %ebp
f01056cf:	c3                   	ret    

f01056d0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01056d0:	55                   	push   %ebp
f01056d1:	89 e5                	mov    %esp,%ebp
f01056d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01056d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01056da:	eb 03                	jmp    f01056df <strfind+0xf>
f01056dc:	83 c0 01             	add    $0x1,%eax
f01056df:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01056e2:	38 ca                	cmp    %cl,%dl
f01056e4:	74 04                	je     f01056ea <strfind+0x1a>
f01056e6:	84 d2                	test   %dl,%dl
f01056e8:	75 f2                	jne    f01056dc <strfind+0xc>
			break;
	return (char *) s;
}
f01056ea:	5d                   	pop    %ebp
f01056eb:	c3                   	ret    

f01056ec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01056ec:	55                   	push   %ebp
f01056ed:	89 e5                	mov    %esp,%ebp
f01056ef:	57                   	push   %edi
f01056f0:	56                   	push   %esi
f01056f1:	53                   	push   %ebx
f01056f2:	8b 7d 08             	mov    0x8(%ebp),%edi
f01056f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01056f8:	85 c9                	test   %ecx,%ecx
f01056fa:	74 36                	je     f0105732 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01056fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105702:	75 28                	jne    f010572c <memset+0x40>
f0105704:	f6 c1 03             	test   $0x3,%cl
f0105707:	75 23                	jne    f010572c <memset+0x40>
		c &= 0xFF;
f0105709:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010570d:	89 d3                	mov    %edx,%ebx
f010570f:	c1 e3 08             	shl    $0x8,%ebx
f0105712:	89 d6                	mov    %edx,%esi
f0105714:	c1 e6 18             	shl    $0x18,%esi
f0105717:	89 d0                	mov    %edx,%eax
f0105719:	c1 e0 10             	shl    $0x10,%eax
f010571c:	09 f0                	or     %esi,%eax
f010571e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105720:	89 d8                	mov    %ebx,%eax
f0105722:	09 d0                	or     %edx,%eax
f0105724:	c1 e9 02             	shr    $0x2,%ecx
f0105727:	fc                   	cld    
f0105728:	f3 ab                	rep stos %eax,%es:(%edi)
f010572a:	eb 06                	jmp    f0105732 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010572c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010572f:	fc                   	cld    
f0105730:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105732:	89 f8                	mov    %edi,%eax
f0105734:	5b                   	pop    %ebx
f0105735:	5e                   	pop    %esi
f0105736:	5f                   	pop    %edi
f0105737:	5d                   	pop    %ebp
f0105738:	c3                   	ret    

f0105739 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105739:	55                   	push   %ebp
f010573a:	89 e5                	mov    %esp,%ebp
f010573c:	57                   	push   %edi
f010573d:	56                   	push   %esi
f010573e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105741:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105744:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105747:	39 c6                	cmp    %eax,%esi
f0105749:	73 35                	jae    f0105780 <memmove+0x47>
f010574b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010574e:	39 d0                	cmp    %edx,%eax
f0105750:	73 2e                	jae    f0105780 <memmove+0x47>
		s += n;
		d += n;
f0105752:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105755:	89 d6                	mov    %edx,%esi
f0105757:	09 fe                	or     %edi,%esi
f0105759:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010575f:	75 13                	jne    f0105774 <memmove+0x3b>
f0105761:	f6 c1 03             	test   $0x3,%cl
f0105764:	75 0e                	jne    f0105774 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105766:	83 ef 04             	sub    $0x4,%edi
f0105769:	8d 72 fc             	lea    -0x4(%edx),%esi
f010576c:	c1 e9 02             	shr    $0x2,%ecx
f010576f:	fd                   	std    
f0105770:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105772:	eb 09                	jmp    f010577d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105774:	83 ef 01             	sub    $0x1,%edi
f0105777:	8d 72 ff             	lea    -0x1(%edx),%esi
f010577a:	fd                   	std    
f010577b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010577d:	fc                   	cld    
f010577e:	eb 1d                	jmp    f010579d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105780:	89 f2                	mov    %esi,%edx
f0105782:	09 c2                	or     %eax,%edx
f0105784:	f6 c2 03             	test   $0x3,%dl
f0105787:	75 0f                	jne    f0105798 <memmove+0x5f>
f0105789:	f6 c1 03             	test   $0x3,%cl
f010578c:	75 0a                	jne    f0105798 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010578e:	c1 e9 02             	shr    $0x2,%ecx
f0105791:	89 c7                	mov    %eax,%edi
f0105793:	fc                   	cld    
f0105794:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105796:	eb 05                	jmp    f010579d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105798:	89 c7                	mov    %eax,%edi
f010579a:	fc                   	cld    
f010579b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010579d:	5e                   	pop    %esi
f010579e:	5f                   	pop    %edi
f010579f:	5d                   	pop    %ebp
f01057a0:	c3                   	ret    

f01057a1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01057a1:	55                   	push   %ebp
f01057a2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01057a4:	ff 75 10             	pushl  0x10(%ebp)
f01057a7:	ff 75 0c             	pushl  0xc(%ebp)
f01057aa:	ff 75 08             	pushl  0x8(%ebp)
f01057ad:	e8 87 ff ff ff       	call   f0105739 <memmove>
}
f01057b2:	c9                   	leave  
f01057b3:	c3                   	ret    

f01057b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01057b4:	55                   	push   %ebp
f01057b5:	89 e5                	mov    %esp,%ebp
f01057b7:	56                   	push   %esi
f01057b8:	53                   	push   %ebx
f01057b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01057bc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057bf:	89 c6                	mov    %eax,%esi
f01057c1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01057c4:	eb 1a                	jmp    f01057e0 <memcmp+0x2c>
		if (*s1 != *s2)
f01057c6:	0f b6 08             	movzbl (%eax),%ecx
f01057c9:	0f b6 1a             	movzbl (%edx),%ebx
f01057cc:	38 d9                	cmp    %bl,%cl
f01057ce:	74 0a                	je     f01057da <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01057d0:	0f b6 c1             	movzbl %cl,%eax
f01057d3:	0f b6 db             	movzbl %bl,%ebx
f01057d6:	29 d8                	sub    %ebx,%eax
f01057d8:	eb 0f                	jmp    f01057e9 <memcmp+0x35>
		s1++, s2++;
f01057da:	83 c0 01             	add    $0x1,%eax
f01057dd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01057e0:	39 f0                	cmp    %esi,%eax
f01057e2:	75 e2                	jne    f01057c6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01057e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057e9:	5b                   	pop    %ebx
f01057ea:	5e                   	pop    %esi
f01057eb:	5d                   	pop    %ebp
f01057ec:	c3                   	ret    

f01057ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01057ed:	55                   	push   %ebp
f01057ee:	89 e5                	mov    %esp,%ebp
f01057f0:	53                   	push   %ebx
f01057f1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01057f4:	89 c1                	mov    %eax,%ecx
f01057f6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01057f9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01057fd:	eb 0a                	jmp    f0105809 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01057ff:	0f b6 10             	movzbl (%eax),%edx
f0105802:	39 da                	cmp    %ebx,%edx
f0105804:	74 07                	je     f010580d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105806:	83 c0 01             	add    $0x1,%eax
f0105809:	39 c8                	cmp    %ecx,%eax
f010580b:	72 f2                	jb     f01057ff <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010580d:	5b                   	pop    %ebx
f010580e:	5d                   	pop    %ebp
f010580f:	c3                   	ret    

f0105810 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105810:	55                   	push   %ebp
f0105811:	89 e5                	mov    %esp,%ebp
f0105813:	57                   	push   %edi
f0105814:	56                   	push   %esi
f0105815:	53                   	push   %ebx
f0105816:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105819:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010581c:	eb 03                	jmp    f0105821 <strtol+0x11>
		s++;
f010581e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105821:	0f b6 01             	movzbl (%ecx),%eax
f0105824:	3c 20                	cmp    $0x20,%al
f0105826:	74 f6                	je     f010581e <strtol+0xe>
f0105828:	3c 09                	cmp    $0x9,%al
f010582a:	74 f2                	je     f010581e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010582c:	3c 2b                	cmp    $0x2b,%al
f010582e:	75 0a                	jne    f010583a <strtol+0x2a>
		s++;
f0105830:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105833:	bf 00 00 00 00       	mov    $0x0,%edi
f0105838:	eb 11                	jmp    f010584b <strtol+0x3b>
f010583a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010583f:	3c 2d                	cmp    $0x2d,%al
f0105841:	75 08                	jne    f010584b <strtol+0x3b>
		s++, neg = 1;
f0105843:	83 c1 01             	add    $0x1,%ecx
f0105846:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010584b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105851:	75 15                	jne    f0105868 <strtol+0x58>
f0105853:	80 39 30             	cmpb   $0x30,(%ecx)
f0105856:	75 10                	jne    f0105868 <strtol+0x58>
f0105858:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010585c:	75 7c                	jne    f01058da <strtol+0xca>
		s += 2, base = 16;
f010585e:	83 c1 02             	add    $0x2,%ecx
f0105861:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105866:	eb 16                	jmp    f010587e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105868:	85 db                	test   %ebx,%ebx
f010586a:	75 12                	jne    f010587e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010586c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105871:	80 39 30             	cmpb   $0x30,(%ecx)
f0105874:	75 08                	jne    f010587e <strtol+0x6e>
		s++, base = 8;
f0105876:	83 c1 01             	add    $0x1,%ecx
f0105879:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010587e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105883:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105886:	0f b6 11             	movzbl (%ecx),%edx
f0105889:	8d 72 d0             	lea    -0x30(%edx),%esi
f010588c:	89 f3                	mov    %esi,%ebx
f010588e:	80 fb 09             	cmp    $0x9,%bl
f0105891:	77 08                	ja     f010589b <strtol+0x8b>
			dig = *s - '0';
f0105893:	0f be d2             	movsbl %dl,%edx
f0105896:	83 ea 30             	sub    $0x30,%edx
f0105899:	eb 22                	jmp    f01058bd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010589b:	8d 72 9f             	lea    -0x61(%edx),%esi
f010589e:	89 f3                	mov    %esi,%ebx
f01058a0:	80 fb 19             	cmp    $0x19,%bl
f01058a3:	77 08                	ja     f01058ad <strtol+0x9d>
			dig = *s - 'a' + 10;
f01058a5:	0f be d2             	movsbl %dl,%edx
f01058a8:	83 ea 57             	sub    $0x57,%edx
f01058ab:	eb 10                	jmp    f01058bd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01058ad:	8d 72 bf             	lea    -0x41(%edx),%esi
f01058b0:	89 f3                	mov    %esi,%ebx
f01058b2:	80 fb 19             	cmp    $0x19,%bl
f01058b5:	77 16                	ja     f01058cd <strtol+0xbd>
			dig = *s - 'A' + 10;
f01058b7:	0f be d2             	movsbl %dl,%edx
f01058ba:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01058bd:	3b 55 10             	cmp    0x10(%ebp),%edx
f01058c0:	7d 0b                	jge    f01058cd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01058c2:	83 c1 01             	add    $0x1,%ecx
f01058c5:	0f af 45 10          	imul   0x10(%ebp),%eax
f01058c9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01058cb:	eb b9                	jmp    f0105886 <strtol+0x76>

	if (endptr)
f01058cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01058d1:	74 0d                	je     f01058e0 <strtol+0xd0>
		*endptr = (char *) s;
f01058d3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01058d6:	89 0e                	mov    %ecx,(%esi)
f01058d8:	eb 06                	jmp    f01058e0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01058da:	85 db                	test   %ebx,%ebx
f01058dc:	74 98                	je     f0105876 <strtol+0x66>
f01058de:	eb 9e                	jmp    f010587e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01058e0:	89 c2                	mov    %eax,%edx
f01058e2:	f7 da                	neg    %edx
f01058e4:	85 ff                	test   %edi,%edi
f01058e6:	0f 45 c2             	cmovne %edx,%eax
}
f01058e9:	5b                   	pop    %ebx
f01058ea:	5e                   	pop    %esi
f01058eb:	5f                   	pop    %edi
f01058ec:	5d                   	pop    %ebp
f01058ed:	c3                   	ret    
f01058ee:	66 90                	xchg   %ax,%ax

f01058f0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01058f0:	fa                   	cli    

	xorw    %ax, %ax
f01058f1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01058f3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01058f5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01058f7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01058f9:	0f 01 16             	lgdtl  (%esi)
f01058fc:	74 70                	je     f010596e <mpsearch1+0x3>
	movl    %cr0, %eax
f01058fe:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105901:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105905:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105908:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010590e:	08 00                	or     %al,(%eax)

f0105910 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105910:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105914:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105916:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105918:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010591a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010591e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105920:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105922:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f0105927:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010592a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010592d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105932:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105935:	8b 25 84 fe 22 f0    	mov    0xf022fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010593b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105940:	b8 b3 01 10 f0       	mov    $0xf01001b3,%eax
	call    *%eax
f0105945:	ff d0                	call   *%eax

f0105947 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105947:	eb fe                	jmp    f0105947 <spin>
f0105949:	8d 76 00             	lea    0x0(%esi),%esi

f010594c <gdt>:
	...
f0105954:	ff                   	(bad)  
f0105955:	ff 00                	incl   (%eax)
f0105957:	00 00                	add    %al,(%eax)
f0105959:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105960:	00                   	.byte 0x0
f0105961:	92                   	xchg   %eax,%edx
f0105962:	cf                   	iret   
	...

f0105964 <gdtdesc>:
f0105964:	17                   	pop    %ss
f0105965:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010596a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010596a:	90                   	nop

f010596b <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010596b:	55                   	push   %ebp
f010596c:	89 e5                	mov    %esp,%ebp
f010596e:	57                   	push   %edi
f010596f:	56                   	push   %esi
f0105970:	53                   	push   %ebx
f0105971:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105974:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f010597a:	89 c3                	mov    %eax,%ebx
f010597c:	c1 eb 0c             	shr    $0xc,%ebx
f010597f:	39 cb                	cmp    %ecx,%ebx
f0105981:	72 12                	jb     f0105995 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105983:	50                   	push   %eax
f0105984:	68 c4 63 10 f0       	push   $0xf01063c4
f0105989:	6a 57                	push   $0x57
f010598b:	68 e1 7e 10 f0       	push   $0xf0107ee1
f0105990:	e8 ab a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105995:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010599b:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010599d:	89 c2                	mov    %eax,%edx
f010599f:	c1 ea 0c             	shr    $0xc,%edx
f01059a2:	39 ca                	cmp    %ecx,%edx
f01059a4:	72 12                	jb     f01059b8 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059a6:	50                   	push   %eax
f01059a7:	68 c4 63 10 f0       	push   $0xf01063c4
f01059ac:	6a 57                	push   $0x57
f01059ae:	68 e1 7e 10 f0       	push   $0xf0107ee1
f01059b3:	e8 88 a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01059b8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01059be:	eb 2f                	jmp    f01059ef <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01059c0:	83 ec 04             	sub    $0x4,%esp
f01059c3:	6a 04                	push   $0x4
f01059c5:	68 f1 7e 10 f0       	push   $0xf0107ef1
f01059ca:	53                   	push   %ebx
f01059cb:	e8 e4 fd ff ff       	call   f01057b4 <memcmp>
f01059d0:	83 c4 10             	add    $0x10,%esp
f01059d3:	85 c0                	test   %eax,%eax
f01059d5:	75 15                	jne    f01059ec <mpsearch1+0x81>
f01059d7:	89 da                	mov    %ebx,%edx
f01059d9:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01059dc:	0f b6 0a             	movzbl (%edx),%ecx
f01059df:	01 c8                	add    %ecx,%eax
f01059e1:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01059e4:	39 d7                	cmp    %edx,%edi
f01059e6:	75 f4                	jne    f01059dc <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01059e8:	84 c0                	test   %al,%al
f01059ea:	74 0e                	je     f01059fa <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01059ec:	83 c3 10             	add    $0x10,%ebx
f01059ef:	39 f3                	cmp    %esi,%ebx
f01059f1:	72 cd                	jb     f01059c0 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01059f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01059f8:	eb 02                	jmp    f01059fc <mpsearch1+0x91>
f01059fa:	89 d8                	mov    %ebx,%eax
}
f01059fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059ff:	5b                   	pop    %ebx
f0105a00:	5e                   	pop    %esi
f0105a01:	5f                   	pop    %edi
f0105a02:	5d                   	pop    %ebp
f0105a03:	c3                   	ret    

f0105a04 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105a04:	55                   	push   %ebp
f0105a05:	89 e5                	mov    %esp,%ebp
f0105a07:	57                   	push   %edi
f0105a08:	56                   	push   %esi
f0105a09:	53                   	push   %ebx
f0105a0a:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105a0d:	c7 05 c0 03 23 f0 20 	movl   $0xf0230020,0xf02303c0
f0105a14:	00 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a17:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105a1e:	75 16                	jne    f0105a36 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a20:	68 00 04 00 00       	push   $0x400
f0105a25:	68 c4 63 10 f0       	push   $0xf01063c4
f0105a2a:	6a 6f                	push   $0x6f
f0105a2c:	68 e1 7e 10 f0       	push   $0xf0107ee1
f0105a31:	e8 0a a6 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105a36:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105a3d:	85 c0                	test   %eax,%eax
f0105a3f:	74 16                	je     f0105a57 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105a41:	c1 e0 04             	shl    $0x4,%eax
f0105a44:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a49:	e8 1d ff ff ff       	call   f010596b <mpsearch1>
f0105a4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a51:	85 c0                	test   %eax,%eax
f0105a53:	75 3c                	jne    f0105a91 <mp_init+0x8d>
f0105a55:	eb 20                	jmp    f0105a77 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105a57:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105a5e:	c1 e0 0a             	shl    $0xa,%eax
f0105a61:	2d 00 04 00 00       	sub    $0x400,%eax
f0105a66:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a6b:	e8 fb fe ff ff       	call   f010596b <mpsearch1>
f0105a70:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a73:	85 c0                	test   %eax,%eax
f0105a75:	75 1a                	jne    f0105a91 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105a77:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a7c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105a81:	e8 e5 fe ff ff       	call   f010596b <mpsearch1>
f0105a86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105a89:	85 c0                	test   %eax,%eax
f0105a8b:	0f 84 5d 02 00 00    	je     f0105cee <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105a91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a94:	8b 70 04             	mov    0x4(%eax),%esi
f0105a97:	85 f6                	test   %esi,%esi
f0105a99:	74 06                	je     f0105aa1 <mp_init+0x9d>
f0105a9b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105a9f:	74 15                	je     f0105ab6 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105aa1:	83 ec 0c             	sub    $0xc,%esp
f0105aa4:	68 54 7d 10 f0       	push   $0xf0107d54
f0105aa9:	e8 5a dc ff ff       	call   f0103708 <cprintf>
f0105aae:	83 c4 10             	add    $0x10,%esp
f0105ab1:	e9 38 02 00 00       	jmp    f0105cee <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ab6:	89 f0                	mov    %esi,%eax
f0105ab8:	c1 e8 0c             	shr    $0xc,%eax
f0105abb:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0105ac1:	72 15                	jb     f0105ad8 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ac3:	56                   	push   %esi
f0105ac4:	68 c4 63 10 f0       	push   $0xf01063c4
f0105ac9:	68 90 00 00 00       	push   $0x90
f0105ace:	68 e1 7e 10 f0       	push   $0xf0107ee1
f0105ad3:	e8 68 a5 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ad8:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105ade:	83 ec 04             	sub    $0x4,%esp
f0105ae1:	6a 04                	push   $0x4
f0105ae3:	68 f6 7e 10 f0       	push   $0xf0107ef6
f0105ae8:	53                   	push   %ebx
f0105ae9:	e8 c6 fc ff ff       	call   f01057b4 <memcmp>
f0105aee:	83 c4 10             	add    $0x10,%esp
f0105af1:	85 c0                	test   %eax,%eax
f0105af3:	74 15                	je     f0105b0a <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105af5:	83 ec 0c             	sub    $0xc,%esp
f0105af8:	68 84 7d 10 f0       	push   $0xf0107d84
f0105afd:	e8 06 dc ff ff       	call   f0103708 <cprintf>
f0105b02:	83 c4 10             	add    $0x10,%esp
f0105b05:	e9 e4 01 00 00       	jmp    f0105cee <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b0a:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105b0e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105b12:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b15:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b1a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b1f:	eb 0d                	jmp    f0105b2e <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105b21:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105b28:	f0 
f0105b29:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105b2b:	83 c0 01             	add    $0x1,%eax
f0105b2e:	39 c7                	cmp    %eax,%edi
f0105b30:	75 ef                	jne    f0105b21 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105b32:	84 d2                	test   %dl,%dl
f0105b34:	74 15                	je     f0105b4b <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105b36:	83 ec 0c             	sub    $0xc,%esp
f0105b39:	68 b8 7d 10 f0       	push   $0xf0107db8
f0105b3e:	e8 c5 db ff ff       	call   f0103708 <cprintf>
f0105b43:	83 c4 10             	add    $0x10,%esp
f0105b46:	e9 a3 01 00 00       	jmp    f0105cee <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105b4b:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105b4f:	3c 01                	cmp    $0x1,%al
f0105b51:	74 1d                	je     f0105b70 <mp_init+0x16c>
f0105b53:	3c 04                	cmp    $0x4,%al
f0105b55:	74 19                	je     f0105b70 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105b57:	83 ec 08             	sub    $0x8,%esp
f0105b5a:	0f b6 c0             	movzbl %al,%eax
f0105b5d:	50                   	push   %eax
f0105b5e:	68 dc 7d 10 f0       	push   $0xf0107ddc
f0105b63:	e8 a0 db ff ff       	call   f0103708 <cprintf>
f0105b68:	83 c4 10             	add    $0x10,%esp
f0105b6b:	e9 7e 01 00 00       	jmp    f0105cee <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105b70:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105b74:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b78:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b7d:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105b82:	01 ce                	add    %ecx,%esi
f0105b84:	eb 0d                	jmp    f0105b93 <mp_init+0x18f>
f0105b86:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105b8d:	f0 
f0105b8e:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105b90:	83 c0 01             	add    $0x1,%eax
f0105b93:	39 c7                	cmp    %eax,%edi
f0105b95:	75 ef                	jne    f0105b86 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105b97:	89 d0                	mov    %edx,%eax
f0105b99:	02 43 2a             	add    0x2a(%ebx),%al
f0105b9c:	74 15                	je     f0105bb3 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105b9e:	83 ec 0c             	sub    $0xc,%esp
f0105ba1:	68 fc 7d 10 f0       	push   $0xf0107dfc
f0105ba6:	e8 5d db ff ff       	call   f0103708 <cprintf>
f0105bab:	83 c4 10             	add    $0x10,%esp
f0105bae:	e9 3b 01 00 00       	jmp    f0105cee <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105bb3:	85 db                	test   %ebx,%ebx
f0105bb5:	0f 84 33 01 00 00    	je     f0105cee <mp_init+0x2ea>
		return;
	ismp = 1;
f0105bbb:	c7 05 00 00 23 f0 01 	movl   $0x1,0xf0230000
f0105bc2:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105bc5:	8b 43 24             	mov    0x24(%ebx),%eax
f0105bc8:	a3 00 10 27 f0       	mov    %eax,0xf0271000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105bcd:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105bd0:	be 00 00 00 00       	mov    $0x0,%esi
f0105bd5:	e9 85 00 00 00       	jmp    f0105c5f <mp_init+0x25b>
		switch (*p) {
f0105bda:	0f b6 07             	movzbl (%edi),%eax
f0105bdd:	84 c0                	test   %al,%al
f0105bdf:	74 06                	je     f0105be7 <mp_init+0x1e3>
f0105be1:	3c 04                	cmp    $0x4,%al
f0105be3:	77 55                	ja     f0105c3a <mp_init+0x236>
f0105be5:	eb 4e                	jmp    f0105c35 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105be7:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105beb:	74 11                	je     f0105bfe <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105bed:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f0105bf4:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105bf9:	a3 c0 03 23 f0       	mov    %eax,0xf02303c0
			if (ncpu < NCPU) {
f0105bfe:	a1 c4 03 23 f0       	mov    0xf02303c4,%eax
f0105c03:	83 f8 07             	cmp    $0x7,%eax
f0105c06:	7f 13                	jg     f0105c1b <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105c08:	6b d0 74             	imul   $0x74,%eax,%edx
f0105c0b:	88 82 20 00 23 f0    	mov    %al,-0xfdcffe0(%edx)
				ncpu++;
f0105c11:	83 c0 01             	add    $0x1,%eax
f0105c14:	a3 c4 03 23 f0       	mov    %eax,0xf02303c4
f0105c19:	eb 15                	jmp    f0105c30 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105c1b:	83 ec 08             	sub    $0x8,%esp
f0105c1e:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105c22:	50                   	push   %eax
f0105c23:	68 2c 7e 10 f0       	push   $0xf0107e2c
f0105c28:	e8 db da ff ff       	call   f0103708 <cprintf>
f0105c2d:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105c30:	83 c7 14             	add    $0x14,%edi
			continue;
f0105c33:	eb 27                	jmp    f0105c5c <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105c35:	83 c7 08             	add    $0x8,%edi
			continue;
f0105c38:	eb 22                	jmp    f0105c5c <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105c3a:	83 ec 08             	sub    $0x8,%esp
f0105c3d:	0f b6 c0             	movzbl %al,%eax
f0105c40:	50                   	push   %eax
f0105c41:	68 54 7e 10 f0       	push   $0xf0107e54
f0105c46:	e8 bd da ff ff       	call   f0103708 <cprintf>
			ismp = 0;
f0105c4b:	c7 05 00 00 23 f0 00 	movl   $0x0,0xf0230000
f0105c52:	00 00 00 
			i = conf->entry;
f0105c55:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105c59:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c5c:	83 c6 01             	add    $0x1,%esi
f0105c5f:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105c63:	39 c6                	cmp    %eax,%esi
f0105c65:	0f 82 6f ff ff ff    	jb     f0105bda <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105c6b:	a1 c0 03 23 f0       	mov    0xf02303c0,%eax
f0105c70:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105c77:	83 3d 00 00 23 f0 00 	cmpl   $0x0,0xf0230000
f0105c7e:	75 26                	jne    f0105ca6 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105c80:	c7 05 c4 03 23 f0 01 	movl   $0x1,0xf02303c4
f0105c87:	00 00 00 
		lapicaddr = 0;
f0105c8a:	c7 05 00 10 27 f0 00 	movl   $0x0,0xf0271000
f0105c91:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105c94:	83 ec 0c             	sub    $0xc,%esp
f0105c97:	68 74 7e 10 f0       	push   $0xf0107e74
f0105c9c:	e8 67 da ff ff       	call   f0103708 <cprintf>
		return;
f0105ca1:	83 c4 10             	add    $0x10,%esp
f0105ca4:	eb 48                	jmp    f0105cee <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105ca6:	83 ec 04             	sub    $0x4,%esp
f0105ca9:	ff 35 c4 03 23 f0    	pushl  0xf02303c4
f0105caf:	0f b6 00             	movzbl (%eax),%eax
f0105cb2:	50                   	push   %eax
f0105cb3:	68 fb 7e 10 f0       	push   $0xf0107efb
f0105cb8:	e8 4b da ff ff       	call   f0103708 <cprintf>

	if (mp->imcrp) {
f0105cbd:	83 c4 10             	add    $0x10,%esp
f0105cc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105cc3:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105cc7:	74 25                	je     f0105cee <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105cc9:	83 ec 0c             	sub    $0xc,%esp
f0105ccc:	68 a0 7e 10 f0       	push   $0xf0107ea0
f0105cd1:	e8 32 da ff ff       	call   f0103708 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105cd6:	ba 22 00 00 00       	mov    $0x22,%edx
f0105cdb:	b8 70 00 00 00       	mov    $0x70,%eax
f0105ce0:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105ce1:	ba 23 00 00 00       	mov    $0x23,%edx
f0105ce6:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105ce7:	83 c8 01             	or     $0x1,%eax
f0105cea:	ee                   	out    %al,(%dx)
f0105ceb:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cf1:	5b                   	pop    %ebx
f0105cf2:	5e                   	pop    %esi
f0105cf3:	5f                   	pop    %edi
f0105cf4:	5d                   	pop    %ebp
f0105cf5:	c3                   	ret    

f0105cf6 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105cf6:	55                   	push   %ebp
f0105cf7:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105cf9:	8b 0d 04 10 27 f0    	mov    0xf0271004,%ecx
f0105cff:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105d02:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105d04:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105d09:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105d0c:	5d                   	pop    %ebp
f0105d0d:	c3                   	ret    

f0105d0e <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105d0e:	55                   	push   %ebp
f0105d0f:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105d11:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105d16:	85 c0                	test   %eax,%eax
f0105d18:	74 08                	je     f0105d22 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105d1a:	8b 40 20             	mov    0x20(%eax),%eax
f0105d1d:	c1 e8 18             	shr    $0x18,%eax
f0105d20:	eb 05                	jmp    f0105d27 <cpunum+0x19>
	return 0;
f0105d22:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d27:	5d                   	pop    %ebp
f0105d28:	c3                   	ret    

f0105d29 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105d29:	a1 00 10 27 f0       	mov    0xf0271000,%eax
f0105d2e:	85 c0                	test   %eax,%eax
f0105d30:	0f 84 21 01 00 00    	je     f0105e57 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105d36:	55                   	push   %ebp
f0105d37:	89 e5                	mov    %esp,%ebp
f0105d39:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105d3c:	68 00 10 00 00       	push   $0x1000
f0105d41:	50                   	push   %eax
f0105d42:	e8 3b b5 ff ff       	call   f0101282 <mmio_map_region>
f0105d47:	a3 04 10 27 f0       	mov    %eax,0xf0271004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105d4c:	ba 27 01 00 00       	mov    $0x127,%edx
f0105d51:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105d56:	e8 9b ff ff ff       	call   f0105cf6 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105d5b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105d60:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105d65:	e8 8c ff ff ff       	call   f0105cf6 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105d6a:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105d6f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105d74:	e8 7d ff ff ff       	call   f0105cf6 <lapicw>
	lapicw(TICR, 10000000); 
f0105d79:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105d7e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105d83:	e8 6e ff ff ff       	call   f0105cf6 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105d88:	e8 81 ff ff ff       	call   f0105d0e <cpunum>
f0105d8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d90:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105d95:	83 c4 10             	add    $0x10,%esp
f0105d98:	39 05 c0 03 23 f0    	cmp    %eax,0xf02303c0
f0105d9e:	74 0f                	je     f0105daf <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105da0:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105da5:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105daa:	e8 47 ff ff ff       	call   f0105cf6 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105daf:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105db4:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105db9:	e8 38 ff ff ff       	call   f0105cf6 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105dbe:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105dc3:	8b 40 30             	mov    0x30(%eax),%eax
f0105dc6:	c1 e8 10             	shr    $0x10,%eax
f0105dc9:	3c 03                	cmp    $0x3,%al
f0105dcb:	76 0f                	jbe    f0105ddc <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105dcd:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105dd2:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105dd7:	e8 1a ff ff ff       	call   f0105cf6 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105ddc:	ba 33 00 00 00       	mov    $0x33,%edx
f0105de1:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105de6:	e8 0b ff ff ff       	call   f0105cf6 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105deb:	ba 00 00 00 00       	mov    $0x0,%edx
f0105df0:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105df5:	e8 fc fe ff ff       	call   f0105cf6 <lapicw>
	lapicw(ESR, 0);
f0105dfa:	ba 00 00 00 00       	mov    $0x0,%edx
f0105dff:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105e04:	e8 ed fe ff ff       	call   f0105cf6 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105e09:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e0e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e13:	e8 de fe ff ff       	call   f0105cf6 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105e18:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e1d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e22:	e8 cf fe ff ff       	call   f0105cf6 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105e27:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105e2c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e31:	e8 c0 fe ff ff       	call   f0105cf6 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105e36:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105e3c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105e42:	f6 c4 10             	test   $0x10,%ah
f0105e45:	75 f5                	jne    f0105e3c <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105e47:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e4c:	b8 20 00 00 00       	mov    $0x20,%eax
f0105e51:	e8 a0 fe ff ff       	call   f0105cf6 <lapicw>
}
f0105e56:	c9                   	leave  
f0105e57:	f3 c3                	repz ret 

f0105e59 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105e59:	83 3d 04 10 27 f0 00 	cmpl   $0x0,0xf0271004
f0105e60:	74 13                	je     f0105e75 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105e62:	55                   	push   %ebp
f0105e63:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105e65:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e6a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e6f:	e8 82 fe ff ff       	call   f0105cf6 <lapicw>
}
f0105e74:	5d                   	pop    %ebp
f0105e75:	f3 c3                	repz ret 

f0105e77 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105e77:	55                   	push   %ebp
f0105e78:	89 e5                	mov    %esp,%ebp
f0105e7a:	56                   	push   %esi
f0105e7b:	53                   	push   %ebx
f0105e7c:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105e82:	ba 70 00 00 00       	mov    $0x70,%edx
f0105e87:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105e8c:	ee                   	out    %al,(%dx)
f0105e8d:	ba 71 00 00 00       	mov    $0x71,%edx
f0105e92:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105e97:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e98:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105e9f:	75 19                	jne    f0105eba <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ea1:	68 67 04 00 00       	push   $0x467
f0105ea6:	68 c4 63 10 f0       	push   $0xf01063c4
f0105eab:	68 98 00 00 00       	push   $0x98
f0105eb0:	68 18 7f 10 f0       	push   $0xf0107f18
f0105eb5:	e8 86 a1 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105eba:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105ec1:	00 00 
	wrv[1] = addr >> 4;
f0105ec3:	89 d8                	mov    %ebx,%eax
f0105ec5:	c1 e8 04             	shr    $0x4,%eax
f0105ec8:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105ece:	c1 e6 18             	shl    $0x18,%esi
f0105ed1:	89 f2                	mov    %esi,%edx
f0105ed3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ed8:	e8 19 fe ff ff       	call   f0105cf6 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105edd:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105ee2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ee7:	e8 0a fe ff ff       	call   f0105cf6 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105eec:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105ef1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ef6:	e8 fb fd ff ff       	call   f0105cf6 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105efb:	c1 eb 0c             	shr    $0xc,%ebx
f0105efe:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f01:	89 f2                	mov    %esi,%edx
f0105f03:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f08:	e8 e9 fd ff ff       	call   f0105cf6 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f0d:	89 da                	mov    %ebx,%edx
f0105f0f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f14:	e8 dd fd ff ff       	call   f0105cf6 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f19:	89 f2                	mov    %esi,%edx
f0105f1b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f20:	e8 d1 fd ff ff       	call   f0105cf6 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f25:	89 da                	mov    %ebx,%edx
f0105f27:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f2c:	e8 c5 fd ff ff       	call   f0105cf6 <lapicw>
		microdelay(200);
	}
}
f0105f31:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f34:	5b                   	pop    %ebx
f0105f35:	5e                   	pop    %esi
f0105f36:	5d                   	pop    %ebp
f0105f37:	c3                   	ret    

f0105f38 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105f38:	55                   	push   %ebp
f0105f39:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105f3b:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f3e:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105f44:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f49:	e8 a8 fd ff ff       	call   f0105cf6 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105f4e:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105f54:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f5a:	f6 c4 10             	test   $0x10,%ah
f0105f5d:	75 f5                	jne    f0105f54 <lapic_ipi+0x1c>
		;
}
f0105f5f:	5d                   	pop    %ebp
f0105f60:	c3                   	ret    

f0105f61 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105f61:	55                   	push   %ebp
f0105f62:	89 e5                	mov    %esp,%ebp
f0105f64:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105f67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105f6d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f70:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105f73:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105f7a:	5d                   	pop    %ebp
f0105f7b:	c3                   	ret    

f0105f7c <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105f7c:	55                   	push   %ebp
f0105f7d:	89 e5                	mov    %esp,%ebp
f0105f7f:	56                   	push   %esi
f0105f80:	53                   	push   %ebx
f0105f81:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105f84:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105f87:	74 14                	je     f0105f9d <spin_lock+0x21>
f0105f89:	8b 73 08             	mov    0x8(%ebx),%esi
f0105f8c:	e8 7d fd ff ff       	call   f0105d0e <cpunum>
f0105f91:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f94:	05 20 00 23 f0       	add    $0xf0230020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105f99:	39 c6                	cmp    %eax,%esi
f0105f9b:	74 07                	je     f0105fa4 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105f9d:	ba 01 00 00 00       	mov    $0x1,%edx
f0105fa2:	eb 20                	jmp    f0105fc4 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105fa4:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105fa7:	e8 62 fd ff ff       	call   f0105d0e <cpunum>
f0105fac:	83 ec 0c             	sub    $0xc,%esp
f0105faf:	53                   	push   %ebx
f0105fb0:	50                   	push   %eax
f0105fb1:	68 28 7f 10 f0       	push   $0xf0107f28
f0105fb6:	6a 41                	push   $0x41
f0105fb8:	68 8c 7f 10 f0       	push   $0xf0107f8c
f0105fbd:	e8 7e a0 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105fc2:	f3 90                	pause  
f0105fc4:	89 d0                	mov    %edx,%eax
f0105fc6:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105fc9:	85 c0                	test   %eax,%eax
f0105fcb:	75 f5                	jne    f0105fc2 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105fcd:	e8 3c fd ff ff       	call   f0105d0e <cpunum>
f0105fd2:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fd5:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105fda:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105fdd:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105fe0:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105fe2:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fe7:	eb 0b                	jmp    f0105ff4 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105fe9:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105fec:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105fef:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ff1:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105ff4:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105ffa:	76 11                	jbe    f010600d <spin_lock+0x91>
f0105ffc:	83 f8 09             	cmp    $0x9,%eax
f0105fff:	7e e8                	jle    f0105fe9 <spin_lock+0x6d>
f0106001:	eb 0a                	jmp    f010600d <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106003:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010600a:	83 c0 01             	add    $0x1,%eax
f010600d:	83 f8 09             	cmp    $0x9,%eax
f0106010:	7e f1                	jle    f0106003 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106012:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106015:	5b                   	pop    %ebx
f0106016:	5e                   	pop    %esi
f0106017:	5d                   	pop    %ebp
f0106018:	c3                   	ret    

f0106019 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106019:	55                   	push   %ebp
f010601a:	89 e5                	mov    %esp,%ebp
f010601c:	57                   	push   %edi
f010601d:	56                   	push   %esi
f010601e:	53                   	push   %ebx
f010601f:	83 ec 4c             	sub    $0x4c,%esp
f0106022:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106025:	83 3e 00             	cmpl   $0x0,(%esi)
f0106028:	74 18                	je     f0106042 <spin_unlock+0x29>
f010602a:	8b 5e 08             	mov    0x8(%esi),%ebx
f010602d:	e8 dc fc ff ff       	call   f0105d0e <cpunum>
f0106032:	6b c0 74             	imul   $0x74,%eax,%eax
f0106035:	05 20 00 23 f0       	add    $0xf0230020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010603a:	39 c3                	cmp    %eax,%ebx
f010603c:	0f 84 a5 00 00 00    	je     f01060e7 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106042:	83 ec 04             	sub    $0x4,%esp
f0106045:	6a 28                	push   $0x28
f0106047:	8d 46 0c             	lea    0xc(%esi),%eax
f010604a:	50                   	push   %eax
f010604b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010604e:	53                   	push   %ebx
f010604f:	e8 e5 f6 ff ff       	call   f0105739 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106054:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106057:	0f b6 38             	movzbl (%eax),%edi
f010605a:	8b 76 04             	mov    0x4(%esi),%esi
f010605d:	e8 ac fc ff ff       	call   f0105d0e <cpunum>
f0106062:	57                   	push   %edi
f0106063:	56                   	push   %esi
f0106064:	50                   	push   %eax
f0106065:	68 54 7f 10 f0       	push   $0xf0107f54
f010606a:	e8 99 d6 ff ff       	call   f0103708 <cprintf>
f010606f:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106072:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106075:	eb 54                	jmp    f01060cb <spin_unlock+0xb2>
f0106077:	83 ec 08             	sub    $0x8,%esp
f010607a:	57                   	push   %edi
f010607b:	50                   	push   %eax
f010607c:	e8 f9 eb ff ff       	call   f0104c7a <debuginfo_eip>
f0106081:	83 c4 10             	add    $0x10,%esp
f0106084:	85 c0                	test   %eax,%eax
f0106086:	78 27                	js     f01060af <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106088:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010608a:	83 ec 04             	sub    $0x4,%esp
f010608d:	89 c2                	mov    %eax,%edx
f010608f:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106092:	52                   	push   %edx
f0106093:	ff 75 b0             	pushl  -0x50(%ebp)
f0106096:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106099:	ff 75 ac             	pushl  -0x54(%ebp)
f010609c:	ff 75 a8             	pushl  -0x58(%ebp)
f010609f:	50                   	push   %eax
f01060a0:	68 9c 7f 10 f0       	push   $0xf0107f9c
f01060a5:	e8 5e d6 ff ff       	call   f0103708 <cprintf>
f01060aa:	83 c4 20             	add    $0x20,%esp
f01060ad:	eb 12                	jmp    f01060c1 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01060af:	83 ec 08             	sub    $0x8,%esp
f01060b2:	ff 36                	pushl  (%esi)
f01060b4:	68 b3 7f 10 f0       	push   $0xf0107fb3
f01060b9:	e8 4a d6 ff ff       	call   f0103708 <cprintf>
f01060be:	83 c4 10             	add    $0x10,%esp
f01060c1:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01060c4:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01060c7:	39 c3                	cmp    %eax,%ebx
f01060c9:	74 08                	je     f01060d3 <spin_unlock+0xba>
f01060cb:	89 de                	mov    %ebx,%esi
f01060cd:	8b 03                	mov    (%ebx),%eax
f01060cf:	85 c0                	test   %eax,%eax
f01060d1:	75 a4                	jne    f0106077 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01060d3:	83 ec 04             	sub    $0x4,%esp
f01060d6:	68 bb 7f 10 f0       	push   $0xf0107fbb
f01060db:	6a 67                	push   $0x67
f01060dd:	68 8c 7f 10 f0       	push   $0xf0107f8c
f01060e2:	e8 59 9f ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01060e7:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01060ee:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01060f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01060fa:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01060fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106100:	5b                   	pop    %ebx
f0106101:	5e                   	pop    %esi
f0106102:	5f                   	pop    %edi
f0106103:	5d                   	pop    %ebp
f0106104:	c3                   	ret    
f0106105:	66 90                	xchg   %ax,%ax
f0106107:	66 90                	xchg   %ax,%ax
f0106109:	66 90                	xchg   %ax,%ax
f010610b:	66 90                	xchg   %ax,%ax
f010610d:	66 90                	xchg   %ax,%ax
f010610f:	90                   	nop

f0106110 <__udivdi3>:
f0106110:	55                   	push   %ebp
f0106111:	57                   	push   %edi
f0106112:	56                   	push   %esi
f0106113:	53                   	push   %ebx
f0106114:	83 ec 1c             	sub    $0x1c,%esp
f0106117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010611b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010611f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106123:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106127:	85 f6                	test   %esi,%esi
f0106129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010612d:	89 ca                	mov    %ecx,%edx
f010612f:	89 f8                	mov    %edi,%eax
f0106131:	75 3d                	jne    f0106170 <__udivdi3+0x60>
f0106133:	39 cf                	cmp    %ecx,%edi
f0106135:	0f 87 c5 00 00 00    	ja     f0106200 <__udivdi3+0xf0>
f010613b:	85 ff                	test   %edi,%edi
f010613d:	89 fd                	mov    %edi,%ebp
f010613f:	75 0b                	jne    f010614c <__udivdi3+0x3c>
f0106141:	b8 01 00 00 00       	mov    $0x1,%eax
f0106146:	31 d2                	xor    %edx,%edx
f0106148:	f7 f7                	div    %edi
f010614a:	89 c5                	mov    %eax,%ebp
f010614c:	89 c8                	mov    %ecx,%eax
f010614e:	31 d2                	xor    %edx,%edx
f0106150:	f7 f5                	div    %ebp
f0106152:	89 c1                	mov    %eax,%ecx
f0106154:	89 d8                	mov    %ebx,%eax
f0106156:	89 cf                	mov    %ecx,%edi
f0106158:	f7 f5                	div    %ebp
f010615a:	89 c3                	mov    %eax,%ebx
f010615c:	89 d8                	mov    %ebx,%eax
f010615e:	89 fa                	mov    %edi,%edx
f0106160:	83 c4 1c             	add    $0x1c,%esp
f0106163:	5b                   	pop    %ebx
f0106164:	5e                   	pop    %esi
f0106165:	5f                   	pop    %edi
f0106166:	5d                   	pop    %ebp
f0106167:	c3                   	ret    
f0106168:	90                   	nop
f0106169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106170:	39 ce                	cmp    %ecx,%esi
f0106172:	77 74                	ja     f01061e8 <__udivdi3+0xd8>
f0106174:	0f bd fe             	bsr    %esi,%edi
f0106177:	83 f7 1f             	xor    $0x1f,%edi
f010617a:	0f 84 98 00 00 00    	je     f0106218 <__udivdi3+0x108>
f0106180:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106185:	89 f9                	mov    %edi,%ecx
f0106187:	89 c5                	mov    %eax,%ebp
f0106189:	29 fb                	sub    %edi,%ebx
f010618b:	d3 e6                	shl    %cl,%esi
f010618d:	89 d9                	mov    %ebx,%ecx
f010618f:	d3 ed                	shr    %cl,%ebp
f0106191:	89 f9                	mov    %edi,%ecx
f0106193:	d3 e0                	shl    %cl,%eax
f0106195:	09 ee                	or     %ebp,%esi
f0106197:	89 d9                	mov    %ebx,%ecx
f0106199:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010619d:	89 d5                	mov    %edx,%ebp
f010619f:	8b 44 24 08          	mov    0x8(%esp),%eax
f01061a3:	d3 ed                	shr    %cl,%ebp
f01061a5:	89 f9                	mov    %edi,%ecx
f01061a7:	d3 e2                	shl    %cl,%edx
f01061a9:	89 d9                	mov    %ebx,%ecx
f01061ab:	d3 e8                	shr    %cl,%eax
f01061ad:	09 c2                	or     %eax,%edx
f01061af:	89 d0                	mov    %edx,%eax
f01061b1:	89 ea                	mov    %ebp,%edx
f01061b3:	f7 f6                	div    %esi
f01061b5:	89 d5                	mov    %edx,%ebp
f01061b7:	89 c3                	mov    %eax,%ebx
f01061b9:	f7 64 24 0c          	mull   0xc(%esp)
f01061bd:	39 d5                	cmp    %edx,%ebp
f01061bf:	72 10                	jb     f01061d1 <__udivdi3+0xc1>
f01061c1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01061c5:	89 f9                	mov    %edi,%ecx
f01061c7:	d3 e6                	shl    %cl,%esi
f01061c9:	39 c6                	cmp    %eax,%esi
f01061cb:	73 07                	jae    f01061d4 <__udivdi3+0xc4>
f01061cd:	39 d5                	cmp    %edx,%ebp
f01061cf:	75 03                	jne    f01061d4 <__udivdi3+0xc4>
f01061d1:	83 eb 01             	sub    $0x1,%ebx
f01061d4:	31 ff                	xor    %edi,%edi
f01061d6:	89 d8                	mov    %ebx,%eax
f01061d8:	89 fa                	mov    %edi,%edx
f01061da:	83 c4 1c             	add    $0x1c,%esp
f01061dd:	5b                   	pop    %ebx
f01061de:	5e                   	pop    %esi
f01061df:	5f                   	pop    %edi
f01061e0:	5d                   	pop    %ebp
f01061e1:	c3                   	ret    
f01061e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01061e8:	31 ff                	xor    %edi,%edi
f01061ea:	31 db                	xor    %ebx,%ebx
f01061ec:	89 d8                	mov    %ebx,%eax
f01061ee:	89 fa                	mov    %edi,%edx
f01061f0:	83 c4 1c             	add    $0x1c,%esp
f01061f3:	5b                   	pop    %ebx
f01061f4:	5e                   	pop    %esi
f01061f5:	5f                   	pop    %edi
f01061f6:	5d                   	pop    %ebp
f01061f7:	c3                   	ret    
f01061f8:	90                   	nop
f01061f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106200:	89 d8                	mov    %ebx,%eax
f0106202:	f7 f7                	div    %edi
f0106204:	31 ff                	xor    %edi,%edi
f0106206:	89 c3                	mov    %eax,%ebx
f0106208:	89 d8                	mov    %ebx,%eax
f010620a:	89 fa                	mov    %edi,%edx
f010620c:	83 c4 1c             	add    $0x1c,%esp
f010620f:	5b                   	pop    %ebx
f0106210:	5e                   	pop    %esi
f0106211:	5f                   	pop    %edi
f0106212:	5d                   	pop    %ebp
f0106213:	c3                   	ret    
f0106214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106218:	39 ce                	cmp    %ecx,%esi
f010621a:	72 0c                	jb     f0106228 <__udivdi3+0x118>
f010621c:	31 db                	xor    %ebx,%ebx
f010621e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106222:	0f 87 34 ff ff ff    	ja     f010615c <__udivdi3+0x4c>
f0106228:	bb 01 00 00 00       	mov    $0x1,%ebx
f010622d:	e9 2a ff ff ff       	jmp    f010615c <__udivdi3+0x4c>
f0106232:	66 90                	xchg   %ax,%ax
f0106234:	66 90                	xchg   %ax,%ax
f0106236:	66 90                	xchg   %ax,%ax
f0106238:	66 90                	xchg   %ax,%ax
f010623a:	66 90                	xchg   %ax,%ax
f010623c:	66 90                	xchg   %ax,%ax
f010623e:	66 90                	xchg   %ax,%ax

f0106240 <__umoddi3>:
f0106240:	55                   	push   %ebp
f0106241:	57                   	push   %edi
f0106242:	56                   	push   %esi
f0106243:	53                   	push   %ebx
f0106244:	83 ec 1c             	sub    $0x1c,%esp
f0106247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010624b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010624f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106253:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106257:	85 d2                	test   %edx,%edx
f0106259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010625d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106261:	89 f3                	mov    %esi,%ebx
f0106263:	89 3c 24             	mov    %edi,(%esp)
f0106266:	89 74 24 04          	mov    %esi,0x4(%esp)
f010626a:	75 1c                	jne    f0106288 <__umoddi3+0x48>
f010626c:	39 f7                	cmp    %esi,%edi
f010626e:	76 50                	jbe    f01062c0 <__umoddi3+0x80>
f0106270:	89 c8                	mov    %ecx,%eax
f0106272:	89 f2                	mov    %esi,%edx
f0106274:	f7 f7                	div    %edi
f0106276:	89 d0                	mov    %edx,%eax
f0106278:	31 d2                	xor    %edx,%edx
f010627a:	83 c4 1c             	add    $0x1c,%esp
f010627d:	5b                   	pop    %ebx
f010627e:	5e                   	pop    %esi
f010627f:	5f                   	pop    %edi
f0106280:	5d                   	pop    %ebp
f0106281:	c3                   	ret    
f0106282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106288:	39 f2                	cmp    %esi,%edx
f010628a:	89 d0                	mov    %edx,%eax
f010628c:	77 52                	ja     f01062e0 <__umoddi3+0xa0>
f010628e:	0f bd ea             	bsr    %edx,%ebp
f0106291:	83 f5 1f             	xor    $0x1f,%ebp
f0106294:	75 5a                	jne    f01062f0 <__umoddi3+0xb0>
f0106296:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010629a:	0f 82 e0 00 00 00    	jb     f0106380 <__umoddi3+0x140>
f01062a0:	39 0c 24             	cmp    %ecx,(%esp)
f01062a3:	0f 86 d7 00 00 00    	jbe    f0106380 <__umoddi3+0x140>
f01062a9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01062ad:	8b 54 24 04          	mov    0x4(%esp),%edx
f01062b1:	83 c4 1c             	add    $0x1c,%esp
f01062b4:	5b                   	pop    %ebx
f01062b5:	5e                   	pop    %esi
f01062b6:	5f                   	pop    %edi
f01062b7:	5d                   	pop    %ebp
f01062b8:	c3                   	ret    
f01062b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01062c0:	85 ff                	test   %edi,%edi
f01062c2:	89 fd                	mov    %edi,%ebp
f01062c4:	75 0b                	jne    f01062d1 <__umoddi3+0x91>
f01062c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01062cb:	31 d2                	xor    %edx,%edx
f01062cd:	f7 f7                	div    %edi
f01062cf:	89 c5                	mov    %eax,%ebp
f01062d1:	89 f0                	mov    %esi,%eax
f01062d3:	31 d2                	xor    %edx,%edx
f01062d5:	f7 f5                	div    %ebp
f01062d7:	89 c8                	mov    %ecx,%eax
f01062d9:	f7 f5                	div    %ebp
f01062db:	89 d0                	mov    %edx,%eax
f01062dd:	eb 99                	jmp    f0106278 <__umoddi3+0x38>
f01062df:	90                   	nop
f01062e0:	89 c8                	mov    %ecx,%eax
f01062e2:	89 f2                	mov    %esi,%edx
f01062e4:	83 c4 1c             	add    $0x1c,%esp
f01062e7:	5b                   	pop    %ebx
f01062e8:	5e                   	pop    %esi
f01062e9:	5f                   	pop    %edi
f01062ea:	5d                   	pop    %ebp
f01062eb:	c3                   	ret    
f01062ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01062f0:	8b 34 24             	mov    (%esp),%esi
f01062f3:	bf 20 00 00 00       	mov    $0x20,%edi
f01062f8:	89 e9                	mov    %ebp,%ecx
f01062fa:	29 ef                	sub    %ebp,%edi
f01062fc:	d3 e0                	shl    %cl,%eax
f01062fe:	89 f9                	mov    %edi,%ecx
f0106300:	89 f2                	mov    %esi,%edx
f0106302:	d3 ea                	shr    %cl,%edx
f0106304:	89 e9                	mov    %ebp,%ecx
f0106306:	09 c2                	or     %eax,%edx
f0106308:	89 d8                	mov    %ebx,%eax
f010630a:	89 14 24             	mov    %edx,(%esp)
f010630d:	89 f2                	mov    %esi,%edx
f010630f:	d3 e2                	shl    %cl,%edx
f0106311:	89 f9                	mov    %edi,%ecx
f0106313:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106317:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010631b:	d3 e8                	shr    %cl,%eax
f010631d:	89 e9                	mov    %ebp,%ecx
f010631f:	89 c6                	mov    %eax,%esi
f0106321:	d3 e3                	shl    %cl,%ebx
f0106323:	89 f9                	mov    %edi,%ecx
f0106325:	89 d0                	mov    %edx,%eax
f0106327:	d3 e8                	shr    %cl,%eax
f0106329:	89 e9                	mov    %ebp,%ecx
f010632b:	09 d8                	or     %ebx,%eax
f010632d:	89 d3                	mov    %edx,%ebx
f010632f:	89 f2                	mov    %esi,%edx
f0106331:	f7 34 24             	divl   (%esp)
f0106334:	89 d6                	mov    %edx,%esi
f0106336:	d3 e3                	shl    %cl,%ebx
f0106338:	f7 64 24 04          	mull   0x4(%esp)
f010633c:	39 d6                	cmp    %edx,%esi
f010633e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106342:	89 d1                	mov    %edx,%ecx
f0106344:	89 c3                	mov    %eax,%ebx
f0106346:	72 08                	jb     f0106350 <__umoddi3+0x110>
f0106348:	75 11                	jne    f010635b <__umoddi3+0x11b>
f010634a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010634e:	73 0b                	jae    f010635b <__umoddi3+0x11b>
f0106350:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106354:	1b 14 24             	sbb    (%esp),%edx
f0106357:	89 d1                	mov    %edx,%ecx
f0106359:	89 c3                	mov    %eax,%ebx
f010635b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010635f:	29 da                	sub    %ebx,%edx
f0106361:	19 ce                	sbb    %ecx,%esi
f0106363:	89 f9                	mov    %edi,%ecx
f0106365:	89 f0                	mov    %esi,%eax
f0106367:	d3 e0                	shl    %cl,%eax
f0106369:	89 e9                	mov    %ebp,%ecx
f010636b:	d3 ea                	shr    %cl,%edx
f010636d:	89 e9                	mov    %ebp,%ecx
f010636f:	d3 ee                	shr    %cl,%esi
f0106371:	09 d0                	or     %edx,%eax
f0106373:	89 f2                	mov    %esi,%edx
f0106375:	83 c4 1c             	add    $0x1c,%esp
f0106378:	5b                   	pop    %ebx
f0106379:	5e                   	pop    %esi
f010637a:	5f                   	pop    %edi
f010637b:	5d                   	pop    %ebp
f010637c:	c3                   	ret    
f010637d:	8d 76 00             	lea    0x0(%esi),%esi
f0106380:	29 f9                	sub    %edi,%ecx
f0106382:	19 d6                	sbb    %edx,%esi
f0106384:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010638c:	e9 18 ff ff ff       	jmp    f01062a9 <__umoddi3+0x69>
