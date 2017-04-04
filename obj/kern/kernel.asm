
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
f0100048:	83 3d 80 7e 20 f0 00 	cmpl   $0x0,0xf0207e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 7e 20 f0    	mov    %esi,0xf0207e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 45 56 00 00       	call   f01056a6 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 40 5d 10 f0       	push   $0xf0105d40
f010006d:	e8 bf 35 00 00       	call   f0103631 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 8f 35 00 00       	call   f010360b <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 57 6f 10 f0 	movl   $0xf0106f57,(%esp)
f0100083:	e8 a9 35 00 00       	call   f0103631 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 48 08 00 00       	call   f01008dd <monitor>
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
f01000a1:	b8 08 90 24 f0       	mov    $0xf0249008,%eax
f01000a6:	2d a8 6f 20 f0       	sub    $0xf0206fa8,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 a8 6f 20 f0       	push   $0xf0206fa8
f01000b3:	e8 cd 4f 00 00       	call   f0105085 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 88 05 00 00       	call   f0100645 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 ac 5d 10 f0       	push   $0xf0105dac
f01000ca:	e8 62 35 00 00       	call   f0103631 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 42 12 00 00       	call   f0101316 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 9e 2e 00 00       	call   f0102f77 <env_init>
	trap_init();
f01000d9:	e8 37 36 00 00       	call   f0103715 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 b9 52 00 00       	call   f010539c <mp_init>
	lapic_init();
f01000e3:	e8 d9 55 00 00       	call   f01056c1 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 6b 34 00 00       	call   f0103558 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 60 04 12 f0 	movl   $0xf0120460,(%esp)
f01000f4:	e8 1b 58 00 00       	call   f0105914 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 7e 20 f0 07 	cmpl   $0x7,0xf0207e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 64 5d 10 f0       	push   $0xf0105d64
f010010f:	6a 5a                	push   $0x5a
f0100111:	68 c7 5d 10 f0       	push   $0xf0105dc7
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 02 53 10 f0       	mov    $0xf0105302,%eax
f0100123:	2d 88 52 10 f0       	sub    $0xf0105288,%eax
f0100128:	50                   	push   %eax
f0100129:	68 88 52 10 f0       	push   $0xf0105288
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 9a 4f 00 00       	call   f01050d2 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 80 20 f0       	mov    $0xf0208020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 5f 55 00 00       	call   f01056a6 <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 80 20 f0       	add    $0xf0208020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 80 20 f0       	sub    $0xf0208020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 10 21 f0       	add    $0xf0211000,%eax
f010016b:	a3 84 7e 20 f0       	mov    %eax,0xf0207e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 8e 56 00 00       	call   f010580f <lapic_startap>
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
f010018f:	6b 05 c4 83 20 f0 74 	imul   $0x74,0xf02083c4,%eax
f0100196:	05 20 80 20 f0       	add    $0xf0208020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 1c 71 1c f0       	push   $0xf01c711c
f01001a9:	e8 68 2f 00 00       	call   f0103116 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 8c e5 1d f0       	push   $0xf01de58c
f01001b8:	e8 59 2f 00 00       	call   f0103116 <env_create>
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 27 04 00 00       	call   f01005e9 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01001c2:	e8 7c 3d 00 00       	call   f0103f43 <sched_yield>

f01001c7 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001c7:	55                   	push   %ebp
f01001c8:	89 e5                	mov    %esp,%ebp
f01001ca:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001cd:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 12                	ja     f01001eb <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 88 5d 10 f0       	push   $0xf0105d88
f01001df:	6a 71                	push   $0x71
f01001e1:	68 c7 5d 10 f0       	push   $0xf0105dc7
f01001e6:	e8 55 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001eb:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f0:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f3:	e8 ae 54 00 00       	call   f01056a6 <cpunum>
f01001f8:	83 ec 08             	sub    $0x8,%esp
f01001fb:	50                   	push   %eax
f01001fc:	68 d3 5d 10 f0       	push   $0xf0105dd3
f0100201:	e8 2b 34 00 00       	call   f0103631 <cprintf>

	lapic_init();
f0100206:	e8 b6 54 00 00       	call   f01056c1 <lapic_init>
	env_init_percpu();
f010020b:	e8 37 2d 00 00       	call   f0102f47 <env_init_percpu>
	trap_init_percpu();
f0100210:	e8 30 34 00 00       	call   f0103645 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100215:	e8 8c 54 00 00       	call   f01056a6 <cpunum>
f010021a:	6b d0 74             	imul   $0x74,%eax,%edx
f010021d:	81 c2 20 80 20 f0    	add    $0xf0208020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0100223:	b8 01 00 00 00       	mov    $0x1,%eax
f0100228:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022c:	c7 04 24 60 04 12 f0 	movl   $0xf0120460,(%esp)
f0100233:	e8 dc 56 00 00       	call   f0105914 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100238:	e8 06 3d 00 00       	call   f0103f43 <sched_yield>

f010023d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010023d:	55                   	push   %ebp
f010023e:	89 e5                	mov    %esp,%ebp
f0100240:	53                   	push   %ebx
f0100241:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100244:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100247:	ff 75 0c             	pushl  0xc(%ebp)
f010024a:	ff 75 08             	pushl  0x8(%ebp)
f010024d:	68 e9 5d 10 f0       	push   $0xf0105de9
f0100252:	e8 da 33 00 00       	call   f0103631 <cprintf>
	vcprintf(fmt, ap);
f0100257:	83 c4 08             	add    $0x8,%esp
f010025a:	53                   	push   %ebx
f010025b:	ff 75 10             	pushl  0x10(%ebp)
f010025e:	e8 a8 33 00 00       	call   f010360b <vcprintf>
	cprintf("\n");
f0100263:	c7 04 24 57 6f 10 f0 	movl   $0xf0106f57,(%esp)
f010026a:	e8 c2 33 00 00       	call   f0103631 <cprintf>
	va_end(ap);
}
f010026f:	83 c4 10             	add    $0x10,%esp
f0100272:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100275:	c9                   	leave  
f0100276:	c3                   	ret    

f0100277 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100277:	55                   	push   %ebp
f0100278:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010027a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010027f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100280:	a8 01                	test   $0x1,%al
f0100282:	74 0b                	je     f010028f <serial_proc_data+0x18>
f0100284:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100289:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010028a:	0f b6 c0             	movzbl %al,%eax
f010028d:	eb 05                	jmp    f0100294 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010028f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100294:	5d                   	pop    %ebp
f0100295:	c3                   	ret    

f0100296 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100296:	55                   	push   %ebp
f0100297:	89 e5                	mov    %esp,%ebp
f0100299:	53                   	push   %ebx
f010029a:	83 ec 04             	sub    $0x4,%esp
f010029d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010029f:	eb 2b                	jmp    f01002cc <cons_intr+0x36>
		if (c == 0)
f01002a1:	85 c0                	test   %eax,%eax
f01002a3:	74 27                	je     f01002cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a5:	8b 0d 24 72 20 f0    	mov    0xf0207224,%ecx
f01002ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01002ae:	89 15 24 72 20 f0    	mov    %edx,0xf0207224
f01002b4:	88 81 20 70 20 f0    	mov    %al,-0xfdf8fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c0:	75 0a                	jne    f01002cc <cons_intr+0x36>
			cons.wpos = 0;
f01002c2:	c7 05 24 72 20 f0 00 	movl   $0x0,0xf0207224
f01002c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002cc:	ff d3                	call   *%ebx
f01002ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002d1:	75 ce                	jne    f01002a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002d3:	83 c4 04             	add    $0x4,%esp
f01002d6:	5b                   	pop    %ebx
f01002d7:	5d                   	pop    %ebp
f01002d8:	c3                   	ret    

f01002d9 <kbd_proc_data>:
f01002d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01002de:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002df:	a8 01                	test   $0x1,%al
f01002e1:	0f 84 f0 00 00 00    	je     f01003d7 <kbd_proc_data+0xfe>
f01002e7:	ba 60 00 00 00       	mov    $0x60,%edx
f01002ec:	ec                   	in     (%dx),%al
f01002ed:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002ef:	3c e0                	cmp    $0xe0,%al
f01002f1:	75 0d                	jne    f0100300 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002f3:	83 0d 00 70 20 f0 40 	orl    $0x40,0xf0207000
		return 0;
f01002fa:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002ff:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100300:	55                   	push   %ebp
f0100301:	89 e5                	mov    %esp,%ebp
f0100303:	53                   	push   %ebx
f0100304:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100307:	84 c0                	test   %al,%al
f0100309:	79 36                	jns    f0100341 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010030b:	8b 0d 00 70 20 f0    	mov    0xf0207000,%ecx
f0100311:	89 cb                	mov    %ecx,%ebx
f0100313:	83 e3 40             	and    $0x40,%ebx
f0100316:	83 e0 7f             	and    $0x7f,%eax
f0100319:	85 db                	test   %ebx,%ebx
f010031b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031e:	0f b6 d2             	movzbl %dl,%edx
f0100321:	0f b6 82 60 5f 10 f0 	movzbl -0xfefa0a0(%edx),%eax
f0100328:	83 c8 40             	or     $0x40,%eax
f010032b:	0f b6 c0             	movzbl %al,%eax
f010032e:	f7 d0                	not    %eax
f0100330:	21 c8                	and    %ecx,%eax
f0100332:	a3 00 70 20 f0       	mov    %eax,0xf0207000
		return 0;
f0100337:	b8 00 00 00 00       	mov    $0x0,%eax
f010033c:	e9 9e 00 00 00       	jmp    f01003df <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100341:	8b 0d 00 70 20 f0    	mov    0xf0207000,%ecx
f0100347:	f6 c1 40             	test   $0x40,%cl
f010034a:	74 0e                	je     f010035a <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010034c:	83 c8 80             	or     $0xffffff80,%eax
f010034f:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100351:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100354:	89 0d 00 70 20 f0    	mov    %ecx,0xf0207000
	}

	shift |= shiftcode[data];
f010035a:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010035d:	0f b6 82 60 5f 10 f0 	movzbl -0xfefa0a0(%edx),%eax
f0100364:	0b 05 00 70 20 f0    	or     0xf0207000,%eax
f010036a:	0f b6 8a 60 5e 10 f0 	movzbl -0xfefa1a0(%edx),%ecx
f0100371:	31 c8                	xor    %ecx,%eax
f0100373:	a3 00 70 20 f0       	mov    %eax,0xf0207000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100378:	89 c1                	mov    %eax,%ecx
f010037a:	83 e1 03             	and    $0x3,%ecx
f010037d:	8b 0c 8d 40 5e 10 f0 	mov    -0xfefa1c0(,%ecx,4),%ecx
f0100384:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100388:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010038b:	a8 08                	test   $0x8,%al
f010038d:	74 1b                	je     f01003aa <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010038f:	89 da                	mov    %ebx,%edx
f0100391:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100394:	83 f9 19             	cmp    $0x19,%ecx
f0100397:	77 05                	ja     f010039e <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100399:	83 eb 20             	sub    $0x20,%ebx
f010039c:	eb 0c                	jmp    f01003aa <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010039e:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003a1:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003a4:	83 fa 19             	cmp    $0x19,%edx
f01003a7:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003aa:	f7 d0                	not    %eax
f01003ac:	a8 06                	test   $0x6,%al
f01003ae:	75 2d                	jne    f01003dd <kbd_proc_data+0x104>
f01003b0:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003b6:	75 25                	jne    f01003dd <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003b8:	83 ec 0c             	sub    $0xc,%esp
f01003bb:	68 03 5e 10 f0       	push   $0xf0105e03
f01003c0:	e8 6c 32 00 00       	call   f0103631 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c5:	ba 92 00 00 00       	mov    $0x92,%edx
f01003ca:	b8 03 00 00 00       	mov    $0x3,%eax
f01003cf:	ee                   	out    %al,(%dx)
f01003d0:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d3:	89 d8                	mov    %ebx,%eax
f01003d5:	eb 08                	jmp    f01003df <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003dc:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003dd:	89 d8                	mov    %ebx,%eax
}
f01003df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003e2:	c9                   	leave  
f01003e3:	c3                   	ret    

f01003e4 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003e4:	55                   	push   %ebp
f01003e5:	89 e5                	mov    %esp,%ebp
f01003e7:	57                   	push   %edi
f01003e8:	56                   	push   %esi
f01003e9:	53                   	push   %ebx
f01003ea:	83 ec 1c             	sub    $0x1c,%esp
f01003ed:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003ef:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003f4:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003fe:	eb 09                	jmp    f0100409 <cons_putc+0x25>
f0100400:	89 ca                	mov    %ecx,%edx
f0100402:	ec                   	in     (%dx),%al
f0100403:	ec                   	in     (%dx),%al
f0100404:	ec                   	in     (%dx),%al
f0100405:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100406:	83 c3 01             	add    $0x1,%ebx
f0100409:	89 f2                	mov    %esi,%edx
f010040b:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010040c:	a8 20                	test   $0x20,%al
f010040e:	75 08                	jne    f0100418 <cons_putc+0x34>
f0100410:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100416:	7e e8                	jle    f0100400 <cons_putc+0x1c>
f0100418:	89 f8                	mov    %edi,%eax
f010041a:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100422:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100423:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100428:	be 79 03 00 00       	mov    $0x379,%esi
f010042d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100432:	eb 09                	jmp    f010043d <cons_putc+0x59>
f0100434:	89 ca                	mov    %ecx,%edx
f0100436:	ec                   	in     (%dx),%al
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	ec                   	in     (%dx),%al
f010043a:	83 c3 01             	add    $0x1,%ebx
f010043d:	89 f2                	mov    %esi,%edx
f010043f:	ec                   	in     (%dx),%al
f0100440:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100446:	7f 04                	jg     f010044c <cons_putc+0x68>
f0100448:	84 c0                	test   %al,%al
f010044a:	79 e8                	jns    f0100434 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100451:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100455:	ee                   	out    %al,(%dx)
f0100456:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010045b:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100460:	ee                   	out    %al,(%dx)
f0100461:	b8 08 00 00 00       	mov    $0x8,%eax
f0100466:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100467:	89 fa                	mov    %edi,%edx
f0100469:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010046f:	89 f8                	mov    %edi,%eax
f0100471:	80 cc 07             	or     $0x7,%ah
f0100474:	85 d2                	test   %edx,%edx
f0100476:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100479:	89 f8                	mov    %edi,%eax
f010047b:	0f b6 c0             	movzbl %al,%eax
f010047e:	83 f8 09             	cmp    $0x9,%eax
f0100481:	74 74                	je     f01004f7 <cons_putc+0x113>
f0100483:	83 f8 09             	cmp    $0x9,%eax
f0100486:	7f 0a                	jg     f0100492 <cons_putc+0xae>
f0100488:	83 f8 08             	cmp    $0x8,%eax
f010048b:	74 14                	je     f01004a1 <cons_putc+0xbd>
f010048d:	e9 99 00 00 00       	jmp    f010052b <cons_putc+0x147>
f0100492:	83 f8 0a             	cmp    $0xa,%eax
f0100495:	74 3a                	je     f01004d1 <cons_putc+0xed>
f0100497:	83 f8 0d             	cmp    $0xd,%eax
f010049a:	74 3d                	je     f01004d9 <cons_putc+0xf5>
f010049c:	e9 8a 00 00 00       	jmp    f010052b <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004a1:	0f b7 05 28 72 20 f0 	movzwl 0xf0207228,%eax
f01004a8:	66 85 c0             	test   %ax,%ax
f01004ab:	0f 84 e6 00 00 00    	je     f0100597 <cons_putc+0x1b3>
			crt_pos--;
f01004b1:	83 e8 01             	sub    $0x1,%eax
f01004b4:	66 a3 28 72 20 f0    	mov    %ax,0xf0207228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ba:	0f b7 c0             	movzwl %ax,%eax
f01004bd:	66 81 e7 00 ff       	and    $0xff00,%di
f01004c2:	83 cf 20             	or     $0x20,%edi
f01004c5:	8b 15 2c 72 20 f0    	mov    0xf020722c,%edx
f01004cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004cf:	eb 78                	jmp    f0100549 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004d1:	66 83 05 28 72 20 f0 	addw   $0x50,0xf0207228
f01004d8:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d9:	0f b7 05 28 72 20 f0 	movzwl 0xf0207228,%eax
f01004e0:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e6:	c1 e8 16             	shr    $0x16,%eax
f01004e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004ec:	c1 e0 04             	shl    $0x4,%eax
f01004ef:	66 a3 28 72 20 f0    	mov    %ax,0xf0207228
f01004f5:	eb 52                	jmp    f0100549 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fc:	e8 e3 fe ff ff       	call   f01003e4 <cons_putc>
		cons_putc(' ');
f0100501:	b8 20 00 00 00       	mov    $0x20,%eax
f0100506:	e8 d9 fe ff ff       	call   f01003e4 <cons_putc>
		cons_putc(' ');
f010050b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100510:	e8 cf fe ff ff       	call   f01003e4 <cons_putc>
		cons_putc(' ');
f0100515:	b8 20 00 00 00       	mov    $0x20,%eax
f010051a:	e8 c5 fe ff ff       	call   f01003e4 <cons_putc>
		cons_putc(' ');
f010051f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100524:	e8 bb fe ff ff       	call   f01003e4 <cons_putc>
f0100529:	eb 1e                	jmp    f0100549 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010052b:	0f b7 05 28 72 20 f0 	movzwl 0xf0207228,%eax
f0100532:	8d 50 01             	lea    0x1(%eax),%edx
f0100535:	66 89 15 28 72 20 f0 	mov    %dx,0xf0207228
f010053c:	0f b7 c0             	movzwl %ax,%eax
f010053f:	8b 15 2c 72 20 f0    	mov    0xf020722c,%edx
f0100545:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100549:	66 81 3d 28 72 20 f0 	cmpw   $0x7cf,0xf0207228
f0100550:	cf 07 
f0100552:	76 43                	jbe    f0100597 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100554:	a1 2c 72 20 f0       	mov    0xf020722c,%eax
f0100559:	83 ec 04             	sub    $0x4,%esp
f010055c:	68 00 0f 00 00       	push   $0xf00
f0100561:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100567:	52                   	push   %edx
f0100568:	50                   	push   %eax
f0100569:	e8 64 4b 00 00       	call   f01050d2 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010056e:	8b 15 2c 72 20 f0    	mov    0xf020722c,%edx
f0100574:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010057a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100580:	83 c4 10             	add    $0x10,%esp
f0100583:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100588:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010058b:	39 d0                	cmp    %edx,%eax
f010058d:	75 f4                	jne    f0100583 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010058f:	66 83 2d 28 72 20 f0 	subw   $0x50,0xf0207228
f0100596:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100597:	8b 0d 30 72 20 f0    	mov    0xf0207230,%ecx
f010059d:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005a2:	89 ca                	mov    %ecx,%edx
f01005a4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005a5:	0f b7 1d 28 72 20 f0 	movzwl 0xf0207228,%ebx
f01005ac:	8d 71 01             	lea    0x1(%ecx),%esi
f01005af:	89 d8                	mov    %ebx,%eax
f01005b1:	66 c1 e8 08          	shr    $0x8,%ax
f01005b5:	89 f2                	mov    %esi,%edx
f01005b7:	ee                   	out    %al,(%dx)
f01005b8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bd:	89 ca                	mov    %ecx,%edx
f01005bf:	ee                   	out    %al,(%dx)
f01005c0:	89 d8                	mov    %ebx,%eax
f01005c2:	89 f2                	mov    %esi,%edx
f01005c4:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005c8:	5b                   	pop    %ebx
f01005c9:	5e                   	pop    %esi
f01005ca:	5f                   	pop    %edi
f01005cb:	5d                   	pop    %ebp
f01005cc:	c3                   	ret    

f01005cd <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005cd:	80 3d 34 72 20 f0 00 	cmpb   $0x0,0xf0207234
f01005d4:	74 11                	je     f01005e7 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005d6:	55                   	push   %ebp
f01005d7:	89 e5                	mov    %esp,%ebp
f01005d9:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005dc:	b8 77 02 10 f0       	mov    $0xf0100277,%eax
f01005e1:	e8 b0 fc ff ff       	call   f0100296 <cons_intr>
}
f01005e6:	c9                   	leave  
f01005e7:	f3 c3                	repz ret 

f01005e9 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005e9:	55                   	push   %ebp
f01005ea:	89 e5                	mov    %esp,%ebp
f01005ec:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005ef:	b8 d9 02 10 f0       	mov    $0xf01002d9,%eax
f01005f4:	e8 9d fc ff ff       	call   f0100296 <cons_intr>
}
f01005f9:	c9                   	leave  
f01005fa:	c3                   	ret    

f01005fb <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005fb:	55                   	push   %ebp
f01005fc:	89 e5                	mov    %esp,%ebp
f01005fe:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100601:	e8 c7 ff ff ff       	call   f01005cd <serial_intr>
	kbd_intr();
f0100606:	e8 de ff ff ff       	call   f01005e9 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010060b:	a1 20 72 20 f0       	mov    0xf0207220,%eax
f0100610:	3b 05 24 72 20 f0    	cmp    0xf0207224,%eax
f0100616:	74 26                	je     f010063e <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100618:	8d 50 01             	lea    0x1(%eax),%edx
f010061b:	89 15 20 72 20 f0    	mov    %edx,0xf0207220
f0100621:	0f b6 88 20 70 20 f0 	movzbl -0xfdf8fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100628:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010062a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100630:	75 11                	jne    f0100643 <cons_getc+0x48>
			cons.rpos = 0;
f0100632:	c7 05 20 72 20 f0 00 	movl   $0x0,0xf0207220
f0100639:	00 00 00 
f010063c:	eb 05                	jmp    f0100643 <cons_getc+0x48>
		return c;
	}
	return 0;
f010063e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    

f0100645 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100645:	55                   	push   %ebp
f0100646:	89 e5                	mov    %esp,%ebp
f0100648:	57                   	push   %edi
f0100649:	56                   	push   %esi
f010064a:	53                   	push   %ebx
f010064b:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010064e:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100655:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010065c:	5a a5 
	if (*cp != 0xA55A) {
f010065e:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100665:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100669:	74 11                	je     f010067c <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010066b:	c7 05 30 72 20 f0 b4 	movl   $0x3b4,0xf0207230
f0100672:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100675:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010067a:	eb 16                	jmp    f0100692 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010067c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100683:	c7 05 30 72 20 f0 d4 	movl   $0x3d4,0xf0207230
f010068a:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010068d:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100692:	8b 3d 30 72 20 f0    	mov    0xf0207230,%edi
f0100698:	b8 0e 00 00 00       	mov    $0xe,%eax
f010069d:	89 fa                	mov    %edi,%edx
f010069f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006a0:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a3:	89 da                	mov    %ebx,%edx
f01006a5:	ec                   	in     (%dx),%al
f01006a6:	0f b6 c8             	movzbl %al,%ecx
f01006a9:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ac:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006b1:	89 fa                	mov    %edi,%edx
f01006b3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b4:	89 da                	mov    %ebx,%edx
f01006b6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006b7:	89 35 2c 72 20 f0    	mov    %esi,0xf020722c
	crt_pos = pos;
f01006bd:	0f b6 c0             	movzbl %al,%eax
f01006c0:	09 c8                	or     %ecx,%eax
f01006c2:	66 a3 28 72 20 f0    	mov    %ax,0xf0207228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006c8:	e8 1c ff ff ff       	call   f01005e9 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006cd:	83 ec 0c             	sub    $0xc,%esp
f01006d0:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006d7:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006dc:	50                   	push   %eax
f01006dd:	e8 fe 2d 00 00       	call   f01034e0 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e2:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ec:	89 f2                	mov    %esi,%edx
f01006ee:	ee                   	out    %al,(%dx)
f01006ef:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006f4:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f9:	ee                   	out    %al,(%dx)
f01006fa:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006ff:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100704:	89 da                	mov    %ebx,%edx
f0100706:	ee                   	out    %al,(%dx)
f0100707:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010070c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100711:	ee                   	out    %al,(%dx)
f0100712:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100717:	b8 03 00 00 00       	mov    $0x3,%eax
f010071c:	ee                   	out    %al,(%dx)
f010071d:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100722:	b8 00 00 00 00       	mov    $0x0,%eax
f0100727:	ee                   	out    %al,(%dx)
f0100728:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010072d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100732:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100733:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100738:	ec                   	in     (%dx),%al
f0100739:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010073b:	83 c4 10             	add    $0x10,%esp
f010073e:	3c ff                	cmp    $0xff,%al
f0100740:	0f 95 05 34 72 20 f0 	setne  0xf0207234
f0100747:	89 f2                	mov    %esi,%edx
f0100749:	ec                   	in     (%dx),%al
f010074a:	89 da                	mov    %ebx,%edx
f010074c:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010074d:	80 f9 ff             	cmp    $0xff,%cl
f0100750:	74 21                	je     f0100773 <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f0100752:	83 ec 0c             	sub    $0xc,%esp
f0100755:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010075c:	25 ef ff 00 00       	and    $0xffef,%eax
f0100761:	50                   	push   %eax
f0100762:	e8 79 2d 00 00       	call   f01034e0 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100767:	83 c4 10             	add    $0x10,%esp
f010076a:	80 3d 34 72 20 f0 00 	cmpb   $0x0,0xf0207234
f0100771:	75 10                	jne    f0100783 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100773:	83 ec 0c             	sub    $0xc,%esp
f0100776:	68 0f 5e 10 f0       	push   $0xf0105e0f
f010077b:	e8 b1 2e 00 00       	call   f0103631 <cprintf>
f0100780:	83 c4 10             	add    $0x10,%esp
}
f0100783:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100786:	5b                   	pop    %ebx
f0100787:	5e                   	pop    %esi
f0100788:	5f                   	pop    %edi
f0100789:	5d                   	pop    %ebp
f010078a:	c3                   	ret    

f010078b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010078b:	55                   	push   %ebp
f010078c:	89 e5                	mov    %esp,%ebp
f010078e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100791:	8b 45 08             	mov    0x8(%ebp),%eax
f0100794:	e8 4b fc ff ff       	call   f01003e4 <cons_putc>
}
f0100799:	c9                   	leave  
f010079a:	c3                   	ret    

f010079b <getchar>:

int
getchar(void)
{
f010079b:	55                   	push   %ebp
f010079c:	89 e5                	mov    %esp,%ebp
f010079e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007a1:	e8 55 fe ff ff       	call   f01005fb <cons_getc>
f01007a6:	85 c0                	test   %eax,%eax
f01007a8:	74 f7                	je     f01007a1 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007aa:	c9                   	leave  
f01007ab:	c3                   	ret    

f01007ac <iscons>:

int
iscons(int fdnum)
{
f01007ac:	55                   	push   %ebp
f01007ad:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007af:	b8 01 00 00 00       	mov    $0x1,%eax
f01007b4:	5d                   	pop    %ebp
f01007b5:	c3                   	ret    

f01007b6 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007b6:	55                   	push   %ebp
f01007b7:	89 e5                	mov    %esp,%ebp
f01007b9:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007bc:	68 60 60 10 f0       	push   $0xf0106060
f01007c1:	68 7e 60 10 f0       	push   $0xf010607e
f01007c6:	68 83 60 10 f0       	push   $0xf0106083
f01007cb:	e8 61 2e 00 00       	call   f0103631 <cprintf>
f01007d0:	83 c4 0c             	add    $0xc,%esp
f01007d3:	68 ec 60 10 f0       	push   $0xf01060ec
f01007d8:	68 8c 60 10 f0       	push   $0xf010608c
f01007dd:	68 83 60 10 f0       	push   $0xf0106083
f01007e2:	e8 4a 2e 00 00       	call   f0103631 <cprintf>
	return 0;
}
f01007e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ec:	c9                   	leave  
f01007ed:	c3                   	ret    

f01007ee <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007ee:	55                   	push   %ebp
f01007ef:	89 e5                	mov    %esp,%ebp
f01007f1:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007f4:	68 95 60 10 f0       	push   $0xf0106095
f01007f9:	e8 33 2e 00 00       	call   f0103631 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007fe:	83 c4 08             	add    $0x8,%esp
f0100801:	68 0c 00 10 00       	push   $0x10000c
f0100806:	68 14 61 10 f0       	push   $0xf0106114
f010080b:	e8 21 2e 00 00       	call   f0103631 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100810:	83 c4 0c             	add    $0xc,%esp
f0100813:	68 0c 00 10 00       	push   $0x10000c
f0100818:	68 0c 00 10 f0       	push   $0xf010000c
f010081d:	68 3c 61 10 f0       	push   $0xf010613c
f0100822:	e8 0a 2e 00 00       	call   f0103631 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100827:	83 c4 0c             	add    $0xc,%esp
f010082a:	68 21 5d 10 00       	push   $0x105d21
f010082f:	68 21 5d 10 f0       	push   $0xf0105d21
f0100834:	68 60 61 10 f0       	push   $0xf0106160
f0100839:	e8 f3 2d 00 00       	call   f0103631 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	68 a8 6f 20 00       	push   $0x206fa8
f0100846:	68 a8 6f 20 f0       	push   $0xf0206fa8
f010084b:	68 84 61 10 f0       	push   $0xf0106184
f0100850:	e8 dc 2d 00 00       	call   f0103631 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100855:	83 c4 0c             	add    $0xc,%esp
f0100858:	68 08 90 24 00       	push   $0x249008
f010085d:	68 08 90 24 f0       	push   $0xf0249008
f0100862:	68 a8 61 10 f0       	push   $0xf01061a8
f0100867:	e8 c5 2d 00 00       	call   f0103631 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010086c:	b8 07 94 24 f0       	mov    $0xf0249407,%eax
f0100871:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100876:	83 c4 08             	add    $0x8,%esp
f0100879:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010087e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100884:	85 c0                	test   %eax,%eax
f0100886:	0f 48 c2             	cmovs  %edx,%eax
f0100889:	c1 f8 0a             	sar    $0xa,%eax
f010088c:	50                   	push   %eax
f010088d:	68 cc 61 10 f0       	push   $0xf01061cc
f0100892:	e8 9a 2d 00 00       	call   f0103631 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100897:	b8 00 00 00 00       	mov    $0x0,%eax
f010089c:	c9                   	leave  
f010089d:	c3                   	ret    

f010089e <mon_backtrace>:

// TODO: Implement lab1's backtrace monitor command
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010089e:	55                   	push   %ebp
f010089f:	89 e5                	mov    %esp,%ebp
f01008a1:	56                   	push   %esi
f01008a2:	53                   	push   %ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008a3:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	uint32_t a = read_ebp();

        int i = 8;
        int *ebp = (int*) a;
f01008a5:	be 08 00 00 00       	mov    $0x8,%esi
        while(i > 0) {
                cprintf("ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",
f01008aa:	ff 73 18             	pushl  0x18(%ebx)
f01008ad:	ff 73 14             	pushl  0x14(%ebx)
f01008b0:	ff 73 10             	pushl  0x10(%ebx)
f01008b3:	ff 73 0c             	pushl  0xc(%ebx)
f01008b6:	ff 73 08             	pushl  0x8(%ebx)
f01008b9:	ff 73 04             	pushl  0x4(%ebx)
f01008bc:	53                   	push   %ebx
f01008bd:	68 f8 61 10 f0       	push   $0xf01061f8
f01008c2:	e8 6a 2d 00 00       	call   f0103631 <cprintf>
                         ebp, ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
                ebp = (int*) ebp[0];
f01008c7:	8b 1b                	mov    (%ebx),%ebx
	// Your code here.
	uint32_t a = read_ebp();

        int i = 8;
        int *ebp = (int*) a;
        while(i > 0) {
f01008c9:	83 c4 20             	add    $0x20,%esp
f01008cc:	83 ee 01             	sub    $0x1,%esi
f01008cf:	75 d9                	jne    f01008aa <mon_backtrace+0xc>
                ebp = (int*) ebp[0];
                i--;
        }

        return 0;
}
f01008d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008d9:	5b                   	pop    %ebx
f01008da:	5e                   	pop    %esi
f01008db:	5d                   	pop    %ebp
f01008dc:	c3                   	ret    

f01008dd <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008dd:	55                   	push   %ebp
f01008de:	89 e5                	mov    %esp,%ebp
f01008e0:	57                   	push   %edi
f01008e1:	56                   	push   %esi
f01008e2:	53                   	push   %ebx
f01008e3:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008e6:	68 2c 62 10 f0       	push   $0xf010622c
f01008eb:	e8 41 2d 00 00       	call   f0103631 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008f0:	c7 04 24 50 62 10 f0 	movl   $0xf0106250,(%esp)
f01008f7:	e8 35 2d 00 00       	call   f0103631 <cprintf>

	if (tf != NULL)
f01008fc:	83 c4 10             	add    $0x10,%esp
f01008ff:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100903:	74 0e                	je     f0100913 <monitor+0x36>
		print_trapframe(tf);
f0100905:	83 ec 0c             	sub    $0xc,%esp
f0100908:	ff 75 08             	pushl  0x8(%ebp)
f010090b:	e8 78 2f 00 00       	call   f0103888 <print_trapframe>
f0100910:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100913:	83 ec 0c             	sub    $0xc,%esp
f0100916:	68 ae 60 10 f0       	push   $0xf01060ae
f010091b:	e8 f6 44 00 00       	call   f0104e16 <readline>
f0100920:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100922:	83 c4 10             	add    $0x10,%esp
f0100925:	85 c0                	test   %eax,%eax
f0100927:	74 ea                	je     f0100913 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100929:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100930:	be 00 00 00 00       	mov    $0x0,%esi
f0100935:	eb 0a                	jmp    f0100941 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100937:	c6 03 00             	movb   $0x0,(%ebx)
f010093a:	89 f7                	mov    %esi,%edi
f010093c:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010093f:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100941:	0f b6 03             	movzbl (%ebx),%eax
f0100944:	84 c0                	test   %al,%al
f0100946:	74 63                	je     f01009ab <monitor+0xce>
f0100948:	83 ec 08             	sub    $0x8,%esp
f010094b:	0f be c0             	movsbl %al,%eax
f010094e:	50                   	push   %eax
f010094f:	68 b2 60 10 f0       	push   $0xf01060b2
f0100954:	e8 ef 46 00 00       	call   f0105048 <strchr>
f0100959:	83 c4 10             	add    $0x10,%esp
f010095c:	85 c0                	test   %eax,%eax
f010095e:	75 d7                	jne    f0100937 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100960:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100963:	74 46                	je     f01009ab <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100965:	83 fe 0f             	cmp    $0xf,%esi
f0100968:	75 14                	jne    f010097e <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010096a:	83 ec 08             	sub    $0x8,%esp
f010096d:	6a 10                	push   $0x10
f010096f:	68 b7 60 10 f0       	push   $0xf01060b7
f0100974:	e8 b8 2c 00 00       	call   f0103631 <cprintf>
f0100979:	83 c4 10             	add    $0x10,%esp
f010097c:	eb 95                	jmp    f0100913 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010097e:	8d 7e 01             	lea    0x1(%esi),%edi
f0100981:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100985:	eb 03                	jmp    f010098a <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100987:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010098a:	0f b6 03             	movzbl (%ebx),%eax
f010098d:	84 c0                	test   %al,%al
f010098f:	74 ae                	je     f010093f <monitor+0x62>
f0100991:	83 ec 08             	sub    $0x8,%esp
f0100994:	0f be c0             	movsbl %al,%eax
f0100997:	50                   	push   %eax
f0100998:	68 b2 60 10 f0       	push   $0xf01060b2
f010099d:	e8 a6 46 00 00       	call   f0105048 <strchr>
f01009a2:	83 c4 10             	add    $0x10,%esp
f01009a5:	85 c0                	test   %eax,%eax
f01009a7:	74 de                	je     f0100987 <monitor+0xaa>
f01009a9:	eb 94                	jmp    f010093f <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009ab:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009b2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009b3:	85 f6                	test   %esi,%esi
f01009b5:	0f 84 58 ff ff ff    	je     f0100913 <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009bb:	83 ec 08             	sub    $0x8,%esp
f01009be:	68 7e 60 10 f0       	push   $0xf010607e
f01009c3:	ff 75 a8             	pushl  -0x58(%ebp)
f01009c6:	e8 1f 46 00 00       	call   f0104fea <strcmp>
f01009cb:	83 c4 10             	add    $0x10,%esp
f01009ce:	85 c0                	test   %eax,%eax
f01009d0:	74 1e                	je     f01009f0 <monitor+0x113>
f01009d2:	83 ec 08             	sub    $0x8,%esp
f01009d5:	68 8c 60 10 f0       	push   $0xf010608c
f01009da:	ff 75 a8             	pushl  -0x58(%ebp)
f01009dd:	e8 08 46 00 00       	call   f0104fea <strcmp>
f01009e2:	83 c4 10             	add    $0x10,%esp
f01009e5:	85 c0                	test   %eax,%eax
f01009e7:	75 2f                	jne    f0100a18 <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009e9:	b8 01 00 00 00       	mov    $0x1,%eax
f01009ee:	eb 05                	jmp    f01009f5 <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f01009f0:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01009f5:	83 ec 04             	sub    $0x4,%esp
f01009f8:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009fb:	01 d0                	add    %edx,%eax
f01009fd:	ff 75 08             	pushl  0x8(%ebp)
f0100a00:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100a03:	51                   	push   %ecx
f0100a04:	56                   	push   %esi
f0100a05:	ff 14 85 80 62 10 f0 	call   *-0xfef9d80(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a0c:	83 c4 10             	add    $0x10,%esp
f0100a0f:	85 c0                	test   %eax,%eax
f0100a11:	78 1d                	js     f0100a30 <monitor+0x153>
f0100a13:	e9 fb fe ff ff       	jmp    f0100913 <monitor+0x36>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a18:	83 ec 08             	sub    $0x8,%esp
f0100a1b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a1e:	68 d4 60 10 f0       	push   $0xf01060d4
f0100a23:	e8 09 2c 00 00       	call   f0103631 <cprintf>
f0100a28:	83 c4 10             	add    $0x10,%esp
f0100a2b:	e9 e3 fe ff ff       	jmp    f0100913 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a30:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a33:	5b                   	pop    %ebx
f0100a34:	5e                   	pop    %esi
f0100a35:	5f                   	pop    %edi
f0100a36:	5d                   	pop    %ebp
f0100a37:	c3                   	ret    

f0100a38 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a38:	89 d1                	mov    %edx,%ecx
f0100a3a:	c1 e9 16             	shr    $0x16,%ecx
f0100a3d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a40:	a8 01                	test   $0x1,%al
f0100a42:	74 52                	je     f0100a96 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a49:	89 c1                	mov    %eax,%ecx
f0100a4b:	c1 e9 0c             	shr    $0xc,%ecx
f0100a4e:	3b 0d 88 7e 20 f0    	cmp    0xf0207e88,%ecx
f0100a54:	72 1b                	jb     f0100a71 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a56:	55                   	push   %ebp
f0100a57:	89 e5                	mov    %esp,%ebp
f0100a59:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a5c:	50                   	push   %eax
f0100a5d:	68 64 5d 10 f0       	push   $0xf0105d64
f0100a62:	68 b4 03 00 00       	push   $0x3b4
f0100a67:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100a6c:	e8 cf f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a71:	c1 ea 0c             	shr    $0xc,%edx
f0100a74:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a7a:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a81:	89 c2                	mov    %eax,%edx
f0100a83:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a8b:	85 d2                	test   %edx,%edx
f0100a8d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a92:	0f 44 c2             	cmove  %edx,%eax
f0100a95:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a9b:	c3                   	ret    

f0100a9c <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a9c:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a9e:	83 3d 38 72 20 f0 00 	cmpl   $0x0,0xf0207238
f0100aa5:	75 0f                	jne    f0100ab6 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aa7:	b8 07 a0 24 f0       	mov    $0xf024a007,%eax
f0100aac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ab1:	a3 38 72 20 f0       	mov    %eax,0xf0207238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	// TODO: Test if 'panic: out of memory' is working
	result = nextfree;
f0100ab6:	a1 38 72 20 f0       	mov    0xf0207238,%eax
	if (n > 0) {
f0100abb:	85 d2                	test   %edx,%edx
f0100abd:	74 5f                	je     f0100b1e <boot_alloc+0x82>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100abf:	55                   	push   %ebp
f0100ac0:	89 e5                	mov    %esp,%ebp
f0100ac2:	53                   	push   %ebx
f0100ac3:	83 ec 04             	sub    $0x4,%esp
	//
	// LAB 2: Your code here.
	// TODO: Test if 'panic: out of memory' is working
	result = nextfree;
	if (n > 0) {
		if ((uint32_t) PADDR(ROUNDUP(nextfree+n, PGSIZE)) > npages*PGSIZE)
f0100ac6:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100acd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ad3:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100ad9:	77 12                	ja     f0100aed <boot_alloc+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100adb:	52                   	push   %edx
f0100adc:	68 88 5d 10 f0       	push   $0xf0105d88
f0100ae1:	6a 6b                	push   $0x6b
f0100ae3:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100ae8:	e8 53 f5 ff ff       	call   f0100040 <_panic>
f0100aed:	8b 0d 88 7e 20 f0    	mov    0xf0207e88,%ecx
f0100af3:	c1 e1 0c             	shl    $0xc,%ecx
f0100af6:	8d 9a 00 00 00 10    	lea    0x10000000(%edx),%ebx
f0100afc:	39 d9                	cmp    %ebx,%ecx
f0100afe:	73 14                	jae    f0100b14 <boot_alloc+0x78>
			panic("boot_alloc: out of memory");
f0100b00:	83 ec 04             	sub    $0x4,%esp
f0100b03:	68 69 6c 10 f0       	push   $0xf0106c69
f0100b08:	6a 6c                	push   $0x6c
f0100b0a:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100b0f:	e8 2c f5 ff ff       	call   f0100040 <_panic>
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100b14:	89 15 38 72 20 f0    	mov    %edx,0xf0207238
	}
	return result;
}
f0100b1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b1d:	c9                   	leave  
f0100b1e:	f3 c3                	repz ret 

f0100b20 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b20:	55                   	push   %ebp
f0100b21:	89 e5                	mov    %esp,%ebp
f0100b23:	57                   	push   %edi
f0100b24:	56                   	push   %esi
f0100b25:	53                   	push   %ebx
f0100b26:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b29:	84 c0                	test   %al,%al
f0100b2b:	0f 85 91 02 00 00    	jne    f0100dc2 <check_page_free_list+0x2a2>
f0100b31:	e9 9e 02 00 00       	jmp    f0100dd4 <check_page_free_list+0x2b4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b36:	83 ec 04             	sub    $0x4,%esp
f0100b39:	68 90 62 10 f0       	push   $0xf0106290
f0100b3e:	68 e9 02 00 00       	push   $0x2e9
f0100b43:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100b48:	e8 f3 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b4d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b50:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b53:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b56:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b59:	89 c2                	mov    %eax,%edx
f0100b5b:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0100b61:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b67:	0f 95 c2             	setne  %dl
f0100b6a:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b6d:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b71:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b73:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b77:	8b 00                	mov    (%eax),%eax
f0100b79:	85 c0                	test   %eax,%eax
f0100b7b:	75 dc                	jne    f0100b59 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b7d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b80:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b86:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b89:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b8c:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b8e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b91:	a3 40 72 20 f0       	mov    %eax,0xf0207240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b96:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b9b:	8b 1d 40 72 20 f0    	mov    0xf0207240,%ebx
f0100ba1:	eb 53                	jmp    f0100bf6 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ba3:	89 d8                	mov    %ebx,%eax
f0100ba5:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0100bab:	c1 f8 03             	sar    $0x3,%eax
f0100bae:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bb1:	89 c2                	mov    %eax,%edx
f0100bb3:	c1 ea 16             	shr    $0x16,%edx
f0100bb6:	39 f2                	cmp    %esi,%edx
f0100bb8:	73 3a                	jae    f0100bf4 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bba:	89 c2                	mov    %eax,%edx
f0100bbc:	c1 ea 0c             	shr    $0xc,%edx
f0100bbf:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0100bc5:	72 12                	jb     f0100bd9 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bc7:	50                   	push   %eax
f0100bc8:	68 64 5d 10 f0       	push   $0xf0105d64
f0100bcd:	6a 58                	push   $0x58
f0100bcf:	68 83 6c 10 f0       	push   $0xf0106c83
f0100bd4:	e8 67 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bd9:	83 ec 04             	sub    $0x4,%esp
f0100bdc:	68 80 00 00 00       	push   $0x80
f0100be1:	68 97 00 00 00       	push   $0x97
f0100be6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100beb:	50                   	push   %eax
f0100bec:	e8 94 44 00 00       	call   f0105085 <memset>
f0100bf1:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bf4:	8b 1b                	mov    (%ebx),%ebx
f0100bf6:	85 db                	test   %ebx,%ebx
f0100bf8:	75 a9                	jne    f0100ba3 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100bfa:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bff:	e8 98 fe ff ff       	call   f0100a9c <boot_alloc>
f0100c04:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c07:	8b 15 40 72 20 f0    	mov    0xf0207240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c0d:	8b 0d 90 7e 20 f0    	mov    0xf0207e90,%ecx
		assert(pp < pages + npages);
f0100c13:	a1 88 7e 20 f0       	mov    0xf0207e88,%eax
f0100c18:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c1b:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c1e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c21:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c24:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c29:	e9 52 01 00 00       	jmp    f0100d80 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c2e:	39 ca                	cmp    %ecx,%edx
f0100c30:	73 19                	jae    f0100c4b <check_page_free_list+0x12b>
f0100c32:	68 91 6c 10 f0       	push   $0xf0106c91
f0100c37:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100c3c:	68 03 03 00 00       	push   $0x303
f0100c41:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100c46:	e8 f5 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c4b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c4e:	72 19                	jb     f0100c69 <check_page_free_list+0x149>
f0100c50:	68 b2 6c 10 f0       	push   $0xf0106cb2
f0100c55:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100c5a:	68 04 03 00 00       	push   $0x304
f0100c5f:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100c64:	e8 d7 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c69:	89 d0                	mov    %edx,%eax
f0100c6b:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c6e:	a8 07                	test   $0x7,%al
f0100c70:	74 19                	je     f0100c8b <check_page_free_list+0x16b>
f0100c72:	68 b4 62 10 f0       	push   $0xf01062b4
f0100c77:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100c7c:	68 05 03 00 00       	push   $0x305
f0100c81:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100c86:	e8 b5 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c8b:	c1 f8 03             	sar    $0x3,%eax
f0100c8e:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c91:	85 c0                	test   %eax,%eax
f0100c93:	75 19                	jne    f0100cae <check_page_free_list+0x18e>
f0100c95:	68 c6 6c 10 f0       	push   $0xf0106cc6
f0100c9a:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100c9f:	68 08 03 00 00       	push   $0x308
f0100ca4:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100ca9:	e8 92 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cae:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cb3:	75 19                	jne    f0100cce <check_page_free_list+0x1ae>
f0100cb5:	68 d7 6c 10 f0       	push   $0xf0106cd7
f0100cba:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100cbf:	68 09 03 00 00       	push   $0x309
f0100cc4:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100cc9:	e8 72 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cce:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cd3:	75 19                	jne    f0100cee <check_page_free_list+0x1ce>
f0100cd5:	68 e8 62 10 f0       	push   $0xf01062e8
f0100cda:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100cdf:	68 0a 03 00 00       	push   $0x30a
f0100ce4:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100ce9:	e8 52 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cee:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100cf3:	75 19                	jne    f0100d0e <check_page_free_list+0x1ee>
f0100cf5:	68 f0 6c 10 f0       	push   $0xf0106cf0
f0100cfa:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100cff:	68 0b 03 00 00       	push   $0x30b
f0100d04:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100d09:	e8 32 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d0e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d13:	0f 86 de 00 00 00    	jbe    f0100df7 <check_page_free_list+0x2d7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d19:	89 c7                	mov    %eax,%edi
f0100d1b:	c1 ef 0c             	shr    $0xc,%edi
f0100d1e:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d21:	77 12                	ja     f0100d35 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d23:	50                   	push   %eax
f0100d24:	68 64 5d 10 f0       	push   $0xf0105d64
f0100d29:	6a 58                	push   $0x58
f0100d2b:	68 83 6c 10 f0       	push   $0xf0106c83
f0100d30:	e8 0b f3 ff ff       	call   f0100040 <_panic>
f0100d35:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d3b:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d3e:	0f 86 a7 00 00 00    	jbe    f0100deb <check_page_free_list+0x2cb>
f0100d44:	68 0c 63 10 f0       	push   $0xf010630c
f0100d49:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100d4e:	68 0c 03 00 00       	push   $0x30c
f0100d53:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100d58:	e8 e3 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d5d:	68 0a 6d 10 f0       	push   $0xf0106d0a
f0100d62:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100d67:	68 0e 03 00 00       	push   $0x30e
f0100d6c:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100d71:	e8 ca f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d76:	83 c6 01             	add    $0x1,%esi
f0100d79:	eb 03                	jmp    f0100d7e <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100d7b:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d7e:	8b 12                	mov    (%edx),%edx
f0100d80:	85 d2                	test   %edx,%edx
f0100d82:	0f 85 a6 fe ff ff    	jne    f0100c2e <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d88:	85 f6                	test   %esi,%esi
f0100d8a:	7f 19                	jg     f0100da5 <check_page_free_list+0x285>
f0100d8c:	68 27 6d 10 f0       	push   $0xf0106d27
f0100d91:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100d96:	68 16 03 00 00       	push   $0x316
f0100d9b:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100da0:	e8 9b f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100da5:	85 db                	test   %ebx,%ebx
f0100da7:	7f 5e                	jg     f0100e07 <check_page_free_list+0x2e7>
f0100da9:	68 39 6d 10 f0       	push   $0xf0106d39
f0100dae:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0100db3:	68 17 03 00 00       	push   $0x317
f0100db8:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100dbd:	e8 7e f2 ff ff       	call   f0100040 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100dc2:	a1 40 72 20 f0       	mov    0xf0207240,%eax
f0100dc7:	85 c0                	test   %eax,%eax
f0100dc9:	0f 85 7e fd ff ff    	jne    f0100b4d <check_page_free_list+0x2d>
f0100dcf:	e9 62 fd ff ff       	jmp    f0100b36 <check_page_free_list+0x16>
f0100dd4:	83 3d 40 72 20 f0 00 	cmpl   $0x0,0xf0207240
f0100ddb:	0f 84 55 fd ff ff    	je     f0100b36 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100de1:	be 00 04 00 00       	mov    $0x400,%esi
f0100de6:	e9 b0 fd ff ff       	jmp    f0100b9b <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100deb:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100df0:	75 89                	jne    f0100d7b <check_page_free_list+0x25b>
f0100df2:	e9 66 ff ff ff       	jmp    f0100d5d <check_page_free_list+0x23d>
f0100df7:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dfc:	0f 85 74 ff ff ff    	jne    f0100d76 <check_page_free_list+0x256>
f0100e02:	e9 56 ff ff ff       	jmp    f0100d5d <check_page_free_list+0x23d>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e0a:	5b                   	pop    %ebx
f0100e0b:	5e                   	pop    %esi
f0100e0c:	5f                   	pop    %edi
f0100e0d:	5d                   	pop    %ebp
f0100e0e:	c3                   	ret    

f0100e0f <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e0f:	55                   	push   %ebp
f0100e10:	89 e5                	mov    %esp,%ebp
f0100e12:	57                   	push   %edi
f0100e13:	56                   	push   %esi
f0100e14:	53                   	push   %ebx
f0100e15:	83 ec 0c             	sub    $0xc,%esp
	//	pages[i].pp_ref = 0;
	//	pages[i].pp_link = page_free_list;
	//	page_free_list = &pages[i];
	//}
	//TODO: Check if it's needed to make pp_ref = 0, in the other pages
	pages[0].pp_ref = 0;
f0100e18:	a1 90 7e 20 f0       	mov    0xf0207e90,%eax
f0100e1d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	pages[0].pp_link = NULL;
f0100e23:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	size_t n_mpentry = ROUNDDOWN(MPENTRY_PADDR, PGSIZE)/PGSIZE;
	size_t n_io_hole_start = npages_basemem;
f0100e29:	8b 1d 44 72 20 f0    	mov    0xf0207244,%ebx
	char *first_free_page = (char *) boot_alloc(0);
f0100e2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e34:	e8 63 fc ff ff       	call   f0100a9c <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e39:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e3e:	77 15                	ja     f0100e55 <page_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e40:	50                   	push   %eax
f0100e41:	68 88 5d 10 f0       	push   $0xf0105d88
f0100e46:	68 51 01 00 00       	push   $0x151
f0100e4b:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100e50:	e8 eb f1 ff ff       	call   f0100040 <_panic>
	size_t first_free_page_number = PGNUM(PADDR(first_free_page));
f0100e55:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e5a:	c1 e8 0c             	shr    $0xc,%eax
f0100e5d:	8b 35 40 72 20 f0    	mov    0xf0207240,%esi

	size_t i;
	for (i = 0; i < npages; i++) {
f0100e63:	bf 00 00 00 00       	mov    $0x0,%edi
f0100e68:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e6d:	eb 4f                	jmp    f0100ebe <page_init+0xaf>
		if (i == 0 || i == n_mpentry || (n_io_hole_start <= i && i < first_free_page_number)) {
f0100e6f:	85 d2                	test   %edx,%edx
f0100e71:	74 0d                	je     f0100e80 <page_init+0x71>
f0100e73:	83 fa 07             	cmp    $0x7,%edx
f0100e76:	74 08                	je     f0100e80 <page_init+0x71>
f0100e78:	39 da                	cmp    %ebx,%edx
f0100e7a:	72 1b                	jb     f0100e97 <page_init+0x88>
f0100e7c:	39 c2                	cmp    %eax,%edx
f0100e7e:	73 17                	jae    f0100e97 <page_init+0x88>
			pages[i].pp_ref = 0;
f0100e80:	8b 0d 90 7e 20 f0    	mov    0xf0207e90,%ecx
f0100e86:	8d 0c d1             	lea    (%ecx,%edx,8),%ecx
f0100e89:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
			pages[i].pp_link = NULL;
f0100e8f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100e95:	eb 24                	jmp    f0100ebb <page_init+0xac>
f0100e97:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
		} else {
			pages[i].pp_ref = 0;
f0100e9e:	89 cf                	mov    %ecx,%edi
f0100ea0:	03 3d 90 7e 20 f0    	add    0xf0207e90,%edi
f0100ea6:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100eac:	89 37                	mov    %esi,(%edi)
			page_free_list = &pages[i];
f0100eae:	89 ce                	mov    %ecx,%esi
f0100eb0:	03 35 90 7e 20 f0    	add    0xf0207e90,%esi
f0100eb6:	bf 01 00 00 00       	mov    $0x1,%edi
	size_t n_io_hole_start = npages_basemem;
	char *first_free_page = (char *) boot_alloc(0);
	size_t first_free_page_number = PGNUM(PADDR(first_free_page));

	size_t i;
	for (i = 0; i < npages; i++) {
f0100ebb:	83 c2 01             	add    $0x1,%edx
f0100ebe:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0100ec4:	72 a9                	jb     f0100e6f <page_init+0x60>
f0100ec6:	89 f8                	mov    %edi,%eax
f0100ec8:	84 c0                	test   %al,%al
f0100eca:	74 06                	je     f0100ed2 <page_init+0xc3>
f0100ecc:	89 35 40 72 20 f0    	mov    %esi,0xf0207240
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ed5:	5b                   	pop    %ebx
f0100ed6:	5e                   	pop    %esi
f0100ed7:	5f                   	pop    %edi
f0100ed8:	5d                   	pop    %ebp
f0100ed9:	c3                   	ret    

f0100eda <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100eda:	55                   	push   %ebp
f0100edb:	89 e5                	mov    %esp,%ebp
f0100edd:	53                   	push   %ebx
f0100ede:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in

	// Test if it is out of memory
	if (!page_free_list)
f0100ee1:	8b 1d 40 72 20 f0    	mov    0xf0207240,%ebx
f0100ee7:	85 db                	test   %ebx,%ebx
f0100ee9:	74 58                	je     f0100f43 <page_alloc+0x69>
		return NULL;

	// If it is not, release one page
	struct PageInfo *allocated_page;
	allocated_page = page_free_list;
	page_free_list = page_free_list->pp_link;
f0100eeb:	8b 03                	mov    (%ebx),%eax
f0100eed:	a3 40 72 20 f0       	mov    %eax,0xf0207240
	allocated_page->pp_link = NULL;
f0100ef2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0100ef8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100efc:	74 45                	je     f0100f43 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100efe:	89 d8                	mov    %ebx,%eax
f0100f00:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0100f06:	c1 f8 03             	sar    $0x3,%eax
f0100f09:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f0c:	89 c2                	mov    %eax,%edx
f0100f0e:	c1 ea 0c             	shr    $0xc,%edx
f0100f11:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0100f17:	72 12                	jb     f0100f2b <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f19:	50                   	push   %eax
f0100f1a:	68 64 5d 10 f0       	push   $0xf0105d64
f0100f1f:	6a 58                	push   $0x58
f0100f21:	68 83 6c 10 f0       	push   $0xf0106c83
f0100f26:	e8 15 f1 ff ff       	call   f0100040 <_panic>
		memset(page2kva(allocated_page), '\0', PGSIZE);
f0100f2b:	83 ec 04             	sub    $0x4,%esp
f0100f2e:	68 00 10 00 00       	push   $0x1000
f0100f33:	6a 00                	push   $0x0
f0100f35:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f3a:	50                   	push   %eax
f0100f3b:	e8 45 41 00 00       	call   f0105085 <memset>
f0100f40:	83 c4 10             	add    $0x10,%esp
	}
	return allocated_page;
}
f0100f43:	89 d8                	mov    %ebx,%eax
f0100f45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f48:	c9                   	leave  
f0100f49:	c3                   	ret    

f0100f4a <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f4a:	55                   	push   %ebp
f0100f4b:	89 e5                	mov    %esp,%ebp
f0100f4d:	83 ec 08             	sub    $0x8,%esp
f0100f50:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100f53:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f58:	75 05                	jne    f0100f5f <page_free+0x15>
f0100f5a:	83 38 00             	cmpl   $0x0,(%eax)
f0100f5d:	74 17                	je     f0100f76 <page_free+0x2c>
		panic("page_free: pp->pp_ref is nonzero or pp->pp_link is not NULL.");
f0100f5f:	83 ec 04             	sub    $0x4,%esp
f0100f62:	68 54 63 10 f0       	push   $0xf0106354
f0100f67:	68 8b 01 00 00       	push   $0x18b
f0100f6c:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100f71:	e8 ca f0 ff ff       	call   f0100040 <_panic>
	}
	pp->pp_link = page_free_list;
f0100f76:	8b 15 40 72 20 f0    	mov    0xf0207240,%edx
f0100f7c:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f7e:	a3 40 72 20 f0       	mov    %eax,0xf0207240
}
f0100f83:	c9                   	leave  
f0100f84:	c3                   	ret    

f0100f85 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f85:	55                   	push   %ebp
f0100f86:	89 e5                	mov    %esp,%ebp
f0100f88:	83 ec 08             	sub    $0x8,%esp
f0100f8b:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f8e:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f92:	83 e8 01             	sub    $0x1,%eax
f0100f95:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f99:	66 85 c0             	test   %ax,%ax
f0100f9c:	75 0c                	jne    f0100faa <page_decref+0x25>
		page_free(pp);
f0100f9e:	83 ec 0c             	sub    $0xc,%esp
f0100fa1:	52                   	push   %edx
f0100fa2:	e8 a3 ff ff ff       	call   f0100f4a <page_free>
f0100fa7:	83 c4 10             	add    $0x10,%esp
}
f0100faa:	c9                   	leave  
f0100fab:	c3                   	ret    

f0100fac <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fac:	55                   	push   %ebp
f0100fad:	89 e5                	mov    %esp,%ebp
f0100faf:	57                   	push   %edi
f0100fb0:	56                   	push   %esi
f0100fb1:	53                   	push   %ebx
f0100fb2:	83 ec 1c             	sub    $0x1c,%esp
f0100fb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	uint32_t pgdir_index = PDX(va);
	uint32_t pgtable_index = PTX(va);
f0100fb8:	89 df                	mov    %ebx,%edi
f0100fba:	c1 ef 0c             	shr    $0xc,%edi
f0100fbd:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
	pte_t *pgdir_entry = pgdir + pgdir_index;
f0100fc3:	c1 eb 16             	shr    $0x16,%ebx
f0100fc6:	c1 e3 02             	shl    $0x2,%ebx
f0100fc9:	03 5d 08             	add    0x8(%ebp),%ebx

	// If pgdir_entry is present
	if (*pgdir_entry & PTE_P) {
f0100fcc:	8b 03                	mov    (%ebx),%eax
f0100fce:	a8 01                	test   $0x1,%al
f0100fd0:	74 33                	je     f0101005 <pgdir_walk+0x59>
		physaddr_t pgtable_pa = (physaddr_t) (*pgdir_entry & 0xFFFFF000);
f0100fd2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd7:	89 c2                	mov    %eax,%edx
f0100fd9:	c1 ea 0c             	shr    $0xc,%edx
f0100fdc:	39 15 88 7e 20 f0    	cmp    %edx,0xf0207e88
f0100fe2:	77 15                	ja     f0100ff9 <pgdir_walk+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fe4:	50                   	push   %eax
f0100fe5:	68 64 5d 10 f0       	push   $0xf0105d64
f0100fea:	68 bd 01 00 00       	push   $0x1bd
f0100fef:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0100ff4:	e8 47 f0 ff ff       	call   f0100040 <_panic>
		pte_t *pgtable = (pte_t *) KADDR(pgtable_pa);
		return pgtable + pgtable_index;
f0100ff9:	8d 84 b8 00 00 00 f0 	lea    -0x10000000(%eax,%edi,4),%eax
f0101000:	e9 89 00 00 00       	jmp    f010108e <pgdir_walk+0xe2>
	// If it is not present
	} else if (create) {
f0101005:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101009:	74 77                	je     f0101082 <pgdir_walk+0xd6>
		struct PageInfo *new_page = page_alloc(0);
f010100b:	83 ec 0c             	sub    $0xc,%esp
f010100e:	6a 00                	push   $0x0
f0101010:	e8 c5 fe ff ff       	call   f0100eda <page_alloc>
f0101015:	89 c6                	mov    %eax,%esi
		// If allocation works
		if (new_page) {
f0101017:	83 c4 10             	add    $0x10,%esp
f010101a:	85 c0                	test   %eax,%eax
f010101c:	74 6b                	je     f0101089 <pgdir_walk+0xdd>
			// Set the page
			new_page->pp_ref += 1;
f010101e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101023:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0101029:	c1 f8 03             	sar    $0x3,%eax
f010102c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010102f:	89 c2                	mov    %eax,%edx
f0101031:	c1 ea 0c             	shr    $0xc,%edx
f0101034:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f010103a:	72 12                	jb     f010104e <pgdir_walk+0xa2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010103c:	50                   	push   %eax
f010103d:	68 64 5d 10 f0       	push   $0xf0105d64
f0101042:	6a 58                	push   $0x58
f0101044:	68 83 6c 10 f0       	push   $0xf0106c83
f0101049:	e8 f2 ef ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010104e:	2d 00 00 00 10       	sub    $0x10000000,%eax
			pte_t *pgtable = page2kva(new_page);
			memset(pgtable, 0, PGSIZE);
f0101053:	83 ec 04             	sub    $0x4,%esp
f0101056:	68 00 10 00 00       	push   $0x1000
f010105b:	6a 00                	push   $0x0
f010105d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101060:	50                   	push   %eax
f0101061:	e8 1f 40 00 00       	call   f0105085 <memset>
			// Set pgdir_entry
			physaddr_t pgtable_pa = page2pa(new_page);
			*pgdir_entry = (pgtable_pa | PTE_P | PTE_W | PTE_U);
f0101066:	2b 35 90 7e 20 f0    	sub    0xf0207e90,%esi
f010106c:	c1 fe 03             	sar    $0x3,%esi
f010106f:	c1 e6 0c             	shl    $0xc,%esi
f0101072:	83 ce 07             	or     $0x7,%esi
f0101075:	89 33                	mov    %esi,(%ebx)
			// Return the virtual addres of the PTE
			return pgtable + pgtable_index;
f0101077:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010107a:	8d 04 b8             	lea    (%eax,%edi,4),%eax
f010107d:	83 c4 10             	add    $0x10,%esp
f0101080:	eb 0c                	jmp    f010108e <pgdir_walk+0xe2>
		}
	}
	return NULL;
f0101082:	b8 00 00 00 00       	mov    $0x0,%eax
f0101087:	eb 05                	jmp    f010108e <pgdir_walk+0xe2>
f0101089:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010108e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101091:	5b                   	pop    %ebx
f0101092:	5e                   	pop    %esi
f0101093:	5f                   	pop    %edi
f0101094:	5d                   	pop    %ebp
f0101095:	c3                   	ret    

f0101096 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101096:	55                   	push   %ebp
f0101097:	89 e5                	mov    %esp,%ebp
f0101099:	57                   	push   %edi
f010109a:	56                   	push   %esi
f010109b:	53                   	push   %ebx
f010109c:	83 ec 1c             	sub    $0x1c,%esp
f010109f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010a2:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// TODO: Add panic for va an pa aligned
	if (size % PGSIZE != 0)
f01010a5:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f01010ab:	74 17                	je     f01010c4 <boot_map_region+0x2e>
		panic("boot_map_region: size is not multiple of PGSIZE");
f01010ad:	83 ec 04             	sub    $0x4,%esp
f01010b0:	68 94 63 10 f0       	push   $0xf0106394
f01010b5:	68 e3 01 00 00       	push   $0x1e3
f01010ba:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01010bf:	e8 7c ef ff ff       	call   f0100040 <_panic>
	uint32_t n = size/PGSIZE;
f01010c4:	c1 e9 0c             	shr    $0xc,%ecx
f01010c7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	uint32_t i;
	for (i = 0; i < n; i++) {
f01010ca:	89 c3                	mov    %eax,%ebx
f01010cc:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);
f01010d1:	89 d7                	mov    %edx,%edi
f01010d3:	29 c7                	sub    %eax,%edi
		if (!pte)
			panic("boot_map_region: could not allocate page table");
		uint32_t pa_without_offset = (pa & 0xFFFFF000);
		*pte = (pa_without_offset | perm | PTE_P);
f01010d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010d8:	83 c8 01             	or     $0x1,%eax
f01010db:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// TODO: Add panic for va an pa aligned
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not multiple of PGSIZE");
	uint32_t n = size/PGSIZE;
	uint32_t i;
	for (i = 0; i < n; i++) {
f01010de:	eb 45                	jmp    f0101125 <boot_map_region+0x8f>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);
f01010e0:	83 ec 04             	sub    $0x4,%esp
f01010e3:	6a 01                	push   $0x1
f01010e5:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01010e8:	50                   	push   %eax
f01010e9:	ff 75 e0             	pushl  -0x20(%ebp)
f01010ec:	e8 bb fe ff ff       	call   f0100fac <pgdir_walk>
		if (!pte)
f01010f1:	83 c4 10             	add    $0x10,%esp
f01010f4:	85 c0                	test   %eax,%eax
f01010f6:	75 17                	jne    f010110f <boot_map_region+0x79>
			panic("boot_map_region: could not allocate page table");
f01010f8:	83 ec 04             	sub    $0x4,%esp
f01010fb:	68 c4 63 10 f0       	push   $0xf01063c4
f0101100:	68 e9 01 00 00       	push   $0x1e9
f0101105:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010110a:	e8 31 ef ff ff       	call   f0100040 <_panic>
		uint32_t pa_without_offset = (pa & 0xFFFFF000);
		*pte = (pa_without_offset | perm | PTE_P);
f010110f:	89 da                	mov    %ebx,%edx
f0101111:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101117:	0b 55 dc             	or     -0x24(%ebp),%edx
f010111a:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
		pa += PGSIZE;
f010111c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// TODO: Add panic for va an pa aligned
	if (size % PGSIZE != 0)
		panic("boot_map_region: size is not multiple of PGSIZE");
	uint32_t n = size/PGSIZE;
	uint32_t i;
	for (i = 0; i < n; i++) {
f0101122:	83 c6 01             	add    $0x1,%esi
f0101125:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101128:	75 b6                	jne    f01010e0 <boot_map_region+0x4a>
		uint32_t pa_without_offset = (pa & 0xFFFFF000);
		*pte = (pa_without_offset | perm | PTE_P);
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f010112a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010112d:	5b                   	pop    %ebx
f010112e:	5e                   	pop    %esi
f010112f:	5f                   	pop    %edi
f0101130:	5d                   	pop    %ebp
f0101131:	c3                   	ret    

f0101132 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101132:	55                   	push   %ebp
f0101133:	89 e5                	mov    %esp,%ebp
f0101135:	53                   	push   %ebx
f0101136:	83 ec 08             	sub    $0x8,%esp
f0101139:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f010113c:	6a 00                	push   $0x0
f010113e:	ff 75 0c             	pushl  0xc(%ebp)
f0101141:	ff 75 08             	pushl  0x8(%ebp)
f0101144:	e8 63 fe ff ff       	call   f0100fac <pgdir_walk>
	if (!pte || !(*pte & PTE_P))
f0101149:	83 c4 10             	add    $0x10,%esp
f010114c:	85 c0                	test   %eax,%eax
f010114e:	74 3c                	je     f010118c <page_lookup+0x5a>
f0101150:	8b 10                	mov    (%eax),%edx
f0101152:	f6 c2 01             	test   $0x1,%dl
f0101155:	74 3c                	je     f0101193 <page_lookup+0x61>
		return NULL;
	physaddr_t page_pa = (*pte & 0xFFFFF000);
f0101157:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (pte_store)
f010115d:	85 db                	test   %ebx,%ebx
f010115f:	74 02                	je     f0101163 <page_lookup+0x31>
		*pte_store = pte;
f0101161:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101163:	c1 ea 0c             	shr    $0xc,%edx
f0101166:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f010116c:	72 14                	jb     f0101182 <page_lookup+0x50>
		panic("pa2page called with invalid pa");
f010116e:	83 ec 04             	sub    $0x4,%esp
f0101171:	68 f4 63 10 f0       	push   $0xf01063f4
f0101176:	6a 51                	push   $0x51
f0101178:	68 83 6c 10 f0       	push   $0xf0106c83
f010117d:	e8 be ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101182:	a1 90 7e 20 f0       	mov    0xf0207e90,%eax
f0101187:	8d 04 d0             	lea    (%eax,%edx,8),%eax
	return pa2page(page_pa);
f010118a:	eb 0c                	jmp    f0101198 <page_lookup+0x66>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if (!pte || !(*pte & PTE_P))
		return NULL;
f010118c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101191:	eb 05                	jmp    f0101198 <page_lookup+0x66>
f0101193:	b8 00 00 00 00       	mov    $0x0,%eax
	physaddr_t page_pa = (*pte & 0xFFFFF000);
	if (pte_store)
		*pte_store = pte;
	return pa2page(page_pa);
}
f0101198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010119b:	c9                   	leave  
f010119c:	c3                   	ret    

f010119d <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010119d:	55                   	push   %ebp
f010119e:	89 e5                	mov    %esp,%ebp
f01011a0:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011a3:	e8 fe 44 00 00       	call   f01056a6 <cpunum>
f01011a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01011ab:	83 b8 28 80 20 f0 00 	cmpl   $0x0,-0xfdf7fd8(%eax)
f01011b2:	74 16                	je     f01011ca <tlb_invalidate+0x2d>
f01011b4:	e8 ed 44 00 00       	call   f01056a6 <cpunum>
f01011b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01011bc:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f01011c2:	8b 55 08             	mov    0x8(%ebp),%edx
f01011c5:	39 50 60             	cmp    %edx,0x60(%eax)
f01011c8:	75 06                	jne    f01011d0 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011cd:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011d0:	c9                   	leave  
f01011d1:	c3                   	ret    

f01011d2 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011d2:	55                   	push   %ebp
f01011d3:	89 e5                	mov    %esp,%ebp
f01011d5:	56                   	push   %esi
f01011d6:	53                   	push   %ebx
f01011d7:	83 ec 14             	sub    $0x14,%esp
f01011da:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011dd:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte;
	struct PageInfo *page = page_lookup(pgdir, va, &pte);
f01011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011e3:	50                   	push   %eax
f01011e4:	56                   	push   %esi
f01011e5:	53                   	push   %ebx
f01011e6:	e8 47 ff ff ff       	call   f0101132 <page_lookup>
	if (page) {
f01011eb:	83 c4 10             	add    $0x10,%esp
f01011ee:	85 c0                	test   %eax,%eax
f01011f0:	74 1f                	je     f0101211 <page_remove+0x3f>
		page_decref(page);
f01011f2:	83 ec 0c             	sub    $0xc,%esp
f01011f5:	50                   	push   %eax
f01011f6:	e8 8a fd ff ff       	call   f0100f85 <page_decref>
		*pte = 0;
f01011fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va); // How this works? Is va here ok?
f0101204:	83 c4 08             	add    $0x8,%esp
f0101207:	56                   	push   %esi
f0101208:	53                   	push   %ebx
f0101209:	e8 8f ff ff ff       	call   f010119d <tlb_invalidate>
f010120e:	83 c4 10             	add    $0x10,%esp
	}
}
f0101211:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101214:	5b                   	pop    %ebx
f0101215:	5e                   	pop    %esi
f0101216:	5d                   	pop    %ebp
f0101217:	c3                   	ret    

f0101218 <page_insert>:
//
// TODO: It should only be used on pages that are not free? (Allocated pages)
// So it can only be used on pages that were allocated.
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101218:	55                   	push   %ebp
f0101219:	89 e5                	mov    %esp,%ebp
f010121b:	57                   	push   %edi
f010121c:	56                   	push   %esi
f010121d:	53                   	push   %ebx
f010121e:	83 ec 20             	sub    $0x20,%esp
f0101221:	8b 75 08             	mov    0x8(%ebp),%esi
f0101224:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101227:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	// TODO: Find a better solution...

	// Corner case
	pte_t *pte;
	if (page_lookup(pgdir, va, &pte) == pp) {
f010122a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010122d:	50                   	push   %eax
f010122e:	57                   	push   %edi
f010122f:	56                   	push   %esi
f0101230:	e8 fd fe ff ff       	call   f0101132 <page_lookup>
f0101235:	83 c4 10             	add    $0x10,%esp
f0101238:	39 d8                	cmp    %ebx,%eax
f010123a:	75 20                	jne    f010125c <page_insert+0x44>
		*pte = (page2pa(pp) | perm | PTE_P);
f010123c:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0101242:	c1 f8 03             	sar    $0x3,%eax
f0101245:	c1 e0 0c             	shl    $0xc,%eax
f0101248:	8b 55 14             	mov    0x14(%ebp),%edx
f010124b:	83 ca 01             	or     $0x1,%edx
f010124e:	09 d0                	or     %edx,%eax
f0101250:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101253:	89 02                	mov    %eax,(%edx)
		return 0;
f0101255:	b8 00 00 00 00       	mov    $0x0,%eax
f010125a:	eb 44                	jmp    f01012a0 <page_insert+0x88>
	}

	// Normal case
	page_remove(pgdir, va);
f010125c:	83 ec 08             	sub    $0x8,%esp
f010125f:	57                   	push   %edi
f0101260:	56                   	push   %esi
f0101261:	e8 6c ff ff ff       	call   f01011d2 <page_remove>
	pte = pgdir_walk(pgdir, va, 1);
f0101266:	83 c4 0c             	add    $0xc,%esp
f0101269:	6a 01                	push   $0x1
f010126b:	57                   	push   %edi
f010126c:	56                   	push   %esi
f010126d:	e8 3a fd ff ff       	call   f0100fac <pgdir_walk>
	if (!pte)
f0101272:	83 c4 10             	add    $0x10,%esp
f0101275:	85 c0                	test   %eax,%eax
f0101277:	74 22                	je     f010129b <page_insert+0x83>
		return -E_NO_MEM;
	pp->pp_ref += 1;
f0101279:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	*pte = (page2pa(pp) | perm | PTE_P);
f010127e:	2b 1d 90 7e 20 f0    	sub    0xf0207e90,%ebx
f0101284:	c1 fb 03             	sar    $0x3,%ebx
f0101287:	c1 e3 0c             	shl    $0xc,%ebx
f010128a:	8b 55 14             	mov    0x14(%ebp),%edx
f010128d:	83 ca 01             	or     $0x1,%edx
f0101290:	09 d3                	or     %edx,%ebx
f0101292:	89 18                	mov    %ebx,(%eax)
	return 0;
f0101294:	b8 00 00 00 00       	mov    $0x0,%eax
f0101299:	eb 05                	jmp    f01012a0 <page_insert+0x88>

	// Normal case
	page_remove(pgdir, va);
	pte = pgdir_walk(pgdir, va, 1);
	if (!pte)
		return -E_NO_MEM;
f010129b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref += 1;
	*pte = (page2pa(pp) | perm | PTE_P);
	return 0;
}
f01012a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012a3:	5b                   	pop    %ebx
f01012a4:	5e                   	pop    %esi
f01012a5:	5f                   	pop    %edi
f01012a6:	5d                   	pop    %ebp
f01012a7:	c3                   	ret    

f01012a8 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012a8:	55                   	push   %ebp
f01012a9:	89 e5                	mov    %esp,%ebp
f01012ab:	53                   	push   %ebx
f01012ac:	83 ec 04             	sub    $0x4,%esp
f01012af:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size_t map_size = ROUNDUP(size, PGSIZE);
f01012b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012b5:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01012bb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + map_size > MMIOLIM) {
f01012c1:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f01012c6:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01012c9:	81 fa 00 00 c0 ef    	cmp    $0xefc00000,%edx
f01012cf:	76 17                	jbe    f01012e8 <mmio_map_region+0x40>
		panic("mmio_map_region: overflow on MMIO map region");
f01012d1:	83 ec 04             	sub    $0x4,%esp
f01012d4:	68 14 64 10 f0       	push   $0xf0106414
f01012d9:	68 84 02 00 00       	push   $0x284
f01012de:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01012e3:	e8 58 ed ff ff       	call   f0100040 <_panic>
	}
	uintptr_t va = base + PGOFF(pa);

	// Map region. va and pa page aligned. map_size multiple of size.
	boot_map_region(kern_pgdir, va, map_size, pa, PTE_W | PTE_PCD | PTE_PWT);
f01012e8:	89 ca                	mov    %ecx,%edx
f01012ea:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
f01012f0:	01 c2                	add    %eax,%edx
f01012f2:	83 ec 08             	sub    $0x8,%esp
f01012f5:	6a 1a                	push   $0x1a
f01012f7:	51                   	push   %ecx
f01012f8:	89 d9                	mov    %ebx,%ecx
f01012fa:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f01012ff:	e8 92 fd ff ff       	call   f0101096 <boot_map_region>

	// Update base
	base += map_size;
f0101304:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f0101309:	01 c3                	add    %eax,%ebx
f010130b:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300

	// Return base of mapped region
	return (void *) (base - map_size);
}
f0101311:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101314:	c9                   	leave  
f0101315:	c3                   	ret    

f0101316 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101316:	55                   	push   %ebp
f0101317:	89 e5                	mov    %esp,%ebp
f0101319:	57                   	push   %edi
f010131a:	56                   	push   %esi
f010131b:	53                   	push   %ebx
f010131c:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010131f:	6a 15                	push   $0x15
f0101321:	e8 8c 21 00 00       	call   f01034b2 <mc146818_read>
f0101326:	89 c3                	mov    %eax,%ebx
f0101328:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010132f:	e8 7e 21 00 00       	call   f01034b2 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0101334:	c1 e0 08             	shl    $0x8,%eax
f0101337:	09 d8                	or     %ebx,%eax
f0101339:	c1 e0 0a             	shl    $0xa,%eax
f010133c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101342:	85 c0                	test   %eax,%eax
f0101344:	0f 48 c2             	cmovs  %edx,%eax
f0101347:	c1 f8 0c             	sar    $0xc,%eax
f010134a:	a3 44 72 20 f0       	mov    %eax,0xf0207244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010134f:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0101356:	e8 57 21 00 00       	call   f01034b2 <mc146818_read>
f010135b:	89 c3                	mov    %eax,%ebx
f010135d:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101364:	e8 49 21 00 00       	call   f01034b2 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101369:	c1 e0 08             	shl    $0x8,%eax
f010136c:	09 d8                	or     %ebx,%eax
f010136e:	c1 e0 0a             	shl    $0xa,%eax
f0101371:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101377:	83 c4 10             	add    $0x10,%esp
f010137a:	85 c0                	test   %eax,%eax
f010137c:	0f 48 c2             	cmovs  %edx,%eax
f010137f:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101382:	85 c0                	test   %eax,%eax
f0101384:	74 0e                	je     f0101394 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101386:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010138c:	89 15 88 7e 20 f0    	mov    %edx,0xf0207e88
f0101392:	eb 0c                	jmp    f01013a0 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101394:	8b 15 44 72 20 f0    	mov    0xf0207244,%edx
f010139a:	89 15 88 7e 20 f0    	mov    %edx,0xf0207e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013a0:	c1 e0 0c             	shl    $0xc,%eax
f01013a3:	c1 e8 0a             	shr    $0xa,%eax
f01013a6:	50                   	push   %eax
f01013a7:	a1 44 72 20 f0       	mov    0xf0207244,%eax
f01013ac:	c1 e0 0c             	shl    $0xc,%eax
f01013af:	c1 e8 0a             	shr    $0xa,%eax
f01013b2:	50                   	push   %eax
f01013b3:	a1 88 7e 20 f0       	mov    0xf0207e88,%eax
f01013b8:	c1 e0 0c             	shl    $0xc,%eax
f01013bb:	c1 e8 0a             	shr    $0xa,%eax
f01013be:	50                   	push   %eax
f01013bf:	68 44 64 10 f0       	push   $0xf0106444
f01013c4:	e8 68 22 00 00       	call   f0103631 <cprintf>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013c9:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013ce:	e8 c9 f6 ff ff       	call   f0100a9c <boot_alloc>
f01013d3:	a3 8c 7e 20 f0       	mov    %eax,0xf0207e8c
	memset(kern_pgdir, 0, PGSIZE);
f01013d8:	83 c4 0c             	add    $0xc,%esp
f01013db:	68 00 10 00 00       	push   $0x1000
f01013e0:	6a 00                	push   $0x0
f01013e2:	50                   	push   %eax
f01013e3:	e8 9d 3c 00 00       	call   f0105085 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013e8:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013ed:	83 c4 10             	add    $0x10,%esp
f01013f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013f5:	77 15                	ja     f010140c <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013f7:	50                   	push   %eax
f01013f8:	68 88 5d 10 f0       	push   $0xf0105d88
f01013fd:	68 93 00 00 00       	push   $0x93
f0101402:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101407:	e8 34 ec ff ff       	call   f0100040 <_panic>
f010140c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101412:	83 ca 05             	or     $0x5,%edx
f0101415:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:

	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f010141b:	a1 88 7e 20 f0       	mov    0xf0207e88,%eax
f0101420:	c1 e0 03             	shl    $0x3,%eax
f0101423:	e8 74 f6 ff ff       	call   f0100a9c <boot_alloc>
f0101428:	a3 90 7e 20 f0       	mov    %eax,0xf0207e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f010142d:	83 ec 04             	sub    $0x4,%esp
f0101430:	8b 0d 88 7e 20 f0    	mov    0xf0207e88,%ecx
f0101436:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010143d:	52                   	push   %edx
f010143e:	6a 00                	push   $0x0
f0101440:	50                   	push   %eax
f0101441:	e8 3f 3c 00 00       	call   f0105085 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101446:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010144b:	e8 4c f6 ff ff       	call   f0100a9c <boot_alloc>
f0101450:	a3 48 72 20 f0       	mov    %eax,0xf0207248
	memset(envs, 0, NENV * sizeof(struct Env));
f0101455:	83 c4 0c             	add    $0xc,%esp
f0101458:	68 00 f0 01 00       	push   $0x1f000
f010145d:	6a 00                	push   $0x0
f010145f:	50                   	push   %eax
f0101460:	e8 20 3c 00 00       	call   f0105085 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101465:	e8 a5 f9 ff ff       	call   f0100e0f <page_init>

	check_page_free_list(1);
f010146a:	b8 01 00 00 00       	mov    $0x1,%eax
f010146f:	e8 ac f6 ff ff       	call   f0100b20 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101474:	83 c4 10             	add    $0x10,%esp
f0101477:	83 3d 90 7e 20 f0 00 	cmpl   $0x0,0xf0207e90
f010147e:	75 17                	jne    f0101497 <mem_init+0x181>
		panic("'pages' is a null pointer!");
f0101480:	83 ec 04             	sub    $0x4,%esp
f0101483:	68 4a 6d 10 f0       	push   $0xf0106d4a
f0101488:	68 28 03 00 00       	push   $0x328
f010148d:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101492:	e8 a9 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101497:	a1 40 72 20 f0       	mov    0xf0207240,%eax
f010149c:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014a1:	eb 05                	jmp    f01014a8 <mem_init+0x192>
		++nfree;
f01014a3:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014a6:	8b 00                	mov    (%eax),%eax
f01014a8:	85 c0                	test   %eax,%eax
f01014aa:	75 f7                	jne    f01014a3 <mem_init+0x18d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014ac:	83 ec 0c             	sub    $0xc,%esp
f01014af:	6a 00                	push   $0x0
f01014b1:	e8 24 fa ff ff       	call   f0100eda <page_alloc>
f01014b6:	89 c7                	mov    %eax,%edi
f01014b8:	83 c4 10             	add    $0x10,%esp
f01014bb:	85 c0                	test   %eax,%eax
f01014bd:	75 19                	jne    f01014d8 <mem_init+0x1c2>
f01014bf:	68 65 6d 10 f0       	push   $0xf0106d65
f01014c4:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01014c9:	68 30 03 00 00       	push   $0x330
f01014ce:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01014d3:	e8 68 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01014d8:	83 ec 0c             	sub    $0xc,%esp
f01014db:	6a 00                	push   $0x0
f01014dd:	e8 f8 f9 ff ff       	call   f0100eda <page_alloc>
f01014e2:	89 c6                	mov    %eax,%esi
f01014e4:	83 c4 10             	add    $0x10,%esp
f01014e7:	85 c0                	test   %eax,%eax
f01014e9:	75 19                	jne    f0101504 <mem_init+0x1ee>
f01014eb:	68 7b 6d 10 f0       	push   $0xf0106d7b
f01014f0:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01014f5:	68 31 03 00 00       	push   $0x331
f01014fa:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01014ff:	e8 3c eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101504:	83 ec 0c             	sub    $0xc,%esp
f0101507:	6a 00                	push   $0x0
f0101509:	e8 cc f9 ff ff       	call   f0100eda <page_alloc>
f010150e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101511:	83 c4 10             	add    $0x10,%esp
f0101514:	85 c0                	test   %eax,%eax
f0101516:	75 19                	jne    f0101531 <mem_init+0x21b>
f0101518:	68 91 6d 10 f0       	push   $0xf0106d91
f010151d:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101522:	68 32 03 00 00       	push   $0x332
f0101527:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010152c:	e8 0f eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101531:	39 f7                	cmp    %esi,%edi
f0101533:	75 19                	jne    f010154e <mem_init+0x238>
f0101535:	68 a7 6d 10 f0       	push   $0xf0106da7
f010153a:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010153f:	68 35 03 00 00       	push   $0x335
f0101544:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101549:	e8 f2 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010154e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101551:	39 c6                	cmp    %eax,%esi
f0101553:	74 04                	je     f0101559 <mem_init+0x243>
f0101555:	39 c7                	cmp    %eax,%edi
f0101557:	75 19                	jne    f0101572 <mem_init+0x25c>
f0101559:	68 80 64 10 f0       	push   $0xf0106480
f010155e:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101563:	68 36 03 00 00       	push   $0x336
f0101568:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010156d:	e8 ce ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101572:	8b 0d 90 7e 20 f0    	mov    0xf0207e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101578:	8b 15 88 7e 20 f0    	mov    0xf0207e88,%edx
f010157e:	c1 e2 0c             	shl    $0xc,%edx
f0101581:	89 f8                	mov    %edi,%eax
f0101583:	29 c8                	sub    %ecx,%eax
f0101585:	c1 f8 03             	sar    $0x3,%eax
f0101588:	c1 e0 0c             	shl    $0xc,%eax
f010158b:	39 d0                	cmp    %edx,%eax
f010158d:	72 19                	jb     f01015a8 <mem_init+0x292>
f010158f:	68 b9 6d 10 f0       	push   $0xf0106db9
f0101594:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101599:	68 37 03 00 00       	push   $0x337
f010159e:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01015a3:	e8 98 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01015a8:	89 f0                	mov    %esi,%eax
f01015aa:	29 c8                	sub    %ecx,%eax
f01015ac:	c1 f8 03             	sar    $0x3,%eax
f01015af:	c1 e0 0c             	shl    $0xc,%eax
f01015b2:	39 c2                	cmp    %eax,%edx
f01015b4:	77 19                	ja     f01015cf <mem_init+0x2b9>
f01015b6:	68 d6 6d 10 f0       	push   $0xf0106dd6
f01015bb:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01015c0:	68 38 03 00 00       	push   $0x338
f01015c5:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01015ca:	e8 71 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01015cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015d2:	29 c8                	sub    %ecx,%eax
f01015d4:	c1 f8 03             	sar    $0x3,%eax
f01015d7:	c1 e0 0c             	shl    $0xc,%eax
f01015da:	39 c2                	cmp    %eax,%edx
f01015dc:	77 19                	ja     f01015f7 <mem_init+0x2e1>
f01015de:	68 f3 6d 10 f0       	push   $0xf0106df3
f01015e3:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01015e8:	68 39 03 00 00       	push   $0x339
f01015ed:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01015f2:	e8 49 ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01015f7:	a1 40 72 20 f0       	mov    0xf0207240,%eax
f01015fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01015ff:	c7 05 40 72 20 f0 00 	movl   $0x0,0xf0207240
f0101606:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101609:	83 ec 0c             	sub    $0xc,%esp
f010160c:	6a 00                	push   $0x0
f010160e:	e8 c7 f8 ff ff       	call   f0100eda <page_alloc>
f0101613:	83 c4 10             	add    $0x10,%esp
f0101616:	85 c0                	test   %eax,%eax
f0101618:	74 19                	je     f0101633 <mem_init+0x31d>
f010161a:	68 10 6e 10 f0       	push   $0xf0106e10
f010161f:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101624:	68 40 03 00 00       	push   $0x340
f0101629:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010162e:	e8 0d ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101633:	83 ec 0c             	sub    $0xc,%esp
f0101636:	57                   	push   %edi
f0101637:	e8 0e f9 ff ff       	call   f0100f4a <page_free>
	page_free(pp1);
f010163c:	89 34 24             	mov    %esi,(%esp)
f010163f:	e8 06 f9 ff ff       	call   f0100f4a <page_free>
	page_free(pp2);
f0101644:	83 c4 04             	add    $0x4,%esp
f0101647:	ff 75 d4             	pushl  -0x2c(%ebp)
f010164a:	e8 fb f8 ff ff       	call   f0100f4a <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010164f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101656:	e8 7f f8 ff ff       	call   f0100eda <page_alloc>
f010165b:	89 c6                	mov    %eax,%esi
f010165d:	83 c4 10             	add    $0x10,%esp
f0101660:	85 c0                	test   %eax,%eax
f0101662:	75 19                	jne    f010167d <mem_init+0x367>
f0101664:	68 65 6d 10 f0       	push   $0xf0106d65
f0101669:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010166e:	68 47 03 00 00       	push   $0x347
f0101673:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101678:	e8 c3 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010167d:	83 ec 0c             	sub    $0xc,%esp
f0101680:	6a 00                	push   $0x0
f0101682:	e8 53 f8 ff ff       	call   f0100eda <page_alloc>
f0101687:	89 c7                	mov    %eax,%edi
f0101689:	83 c4 10             	add    $0x10,%esp
f010168c:	85 c0                	test   %eax,%eax
f010168e:	75 19                	jne    f01016a9 <mem_init+0x393>
f0101690:	68 7b 6d 10 f0       	push   $0xf0106d7b
f0101695:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010169a:	68 48 03 00 00       	push   $0x348
f010169f:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01016a4:	e8 97 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016a9:	83 ec 0c             	sub    $0xc,%esp
f01016ac:	6a 00                	push   $0x0
f01016ae:	e8 27 f8 ff ff       	call   f0100eda <page_alloc>
f01016b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016b6:	83 c4 10             	add    $0x10,%esp
f01016b9:	85 c0                	test   %eax,%eax
f01016bb:	75 19                	jne    f01016d6 <mem_init+0x3c0>
f01016bd:	68 91 6d 10 f0       	push   $0xf0106d91
f01016c2:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01016c7:	68 49 03 00 00       	push   $0x349
f01016cc:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01016d1:	e8 6a e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016d6:	39 fe                	cmp    %edi,%esi
f01016d8:	75 19                	jne    f01016f3 <mem_init+0x3dd>
f01016da:	68 a7 6d 10 f0       	push   $0xf0106da7
f01016df:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01016e4:	68 4b 03 00 00       	push   $0x34b
f01016e9:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01016ee:	e8 4d e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016f6:	39 c7                	cmp    %eax,%edi
f01016f8:	74 04                	je     f01016fe <mem_init+0x3e8>
f01016fa:	39 c6                	cmp    %eax,%esi
f01016fc:	75 19                	jne    f0101717 <mem_init+0x401>
f01016fe:	68 80 64 10 f0       	push   $0xf0106480
f0101703:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101708:	68 4c 03 00 00       	push   $0x34c
f010170d:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101712:	e8 29 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101717:	83 ec 0c             	sub    $0xc,%esp
f010171a:	6a 00                	push   $0x0
f010171c:	e8 b9 f7 ff ff       	call   f0100eda <page_alloc>
f0101721:	83 c4 10             	add    $0x10,%esp
f0101724:	85 c0                	test   %eax,%eax
f0101726:	74 19                	je     f0101741 <mem_init+0x42b>
f0101728:	68 10 6e 10 f0       	push   $0xf0106e10
f010172d:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101732:	68 4d 03 00 00       	push   $0x34d
f0101737:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010173c:	e8 ff e8 ff ff       	call   f0100040 <_panic>
f0101741:	89 f0                	mov    %esi,%eax
f0101743:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0101749:	c1 f8 03             	sar    $0x3,%eax
f010174c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010174f:	89 c2                	mov    %eax,%edx
f0101751:	c1 ea 0c             	shr    $0xc,%edx
f0101754:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f010175a:	72 12                	jb     f010176e <mem_init+0x458>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010175c:	50                   	push   %eax
f010175d:	68 64 5d 10 f0       	push   $0xf0105d64
f0101762:	6a 58                	push   $0x58
f0101764:	68 83 6c 10 f0       	push   $0xf0106c83
f0101769:	e8 d2 e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010176e:	83 ec 04             	sub    $0x4,%esp
f0101771:	68 00 10 00 00       	push   $0x1000
f0101776:	6a 01                	push   $0x1
f0101778:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010177d:	50                   	push   %eax
f010177e:	e8 02 39 00 00       	call   f0105085 <memset>
	page_free(pp0);
f0101783:	89 34 24             	mov    %esi,(%esp)
f0101786:	e8 bf f7 ff ff       	call   f0100f4a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010178b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101792:	e8 43 f7 ff ff       	call   f0100eda <page_alloc>
f0101797:	83 c4 10             	add    $0x10,%esp
f010179a:	85 c0                	test   %eax,%eax
f010179c:	75 19                	jne    f01017b7 <mem_init+0x4a1>
f010179e:	68 1f 6e 10 f0       	push   $0xf0106e1f
f01017a3:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01017a8:	68 52 03 00 00       	push   $0x352
f01017ad:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01017b2:	e8 89 e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01017b7:	39 c6                	cmp    %eax,%esi
f01017b9:	74 19                	je     f01017d4 <mem_init+0x4be>
f01017bb:	68 3d 6e 10 f0       	push   $0xf0106e3d
f01017c0:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01017c5:	68 53 03 00 00       	push   $0x353
f01017ca:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01017cf:	e8 6c e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017d4:	89 f0                	mov    %esi,%eax
f01017d6:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f01017dc:	c1 f8 03             	sar    $0x3,%eax
f01017df:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017e2:	89 c2                	mov    %eax,%edx
f01017e4:	c1 ea 0c             	shr    $0xc,%edx
f01017e7:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f01017ed:	72 12                	jb     f0101801 <mem_init+0x4eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017ef:	50                   	push   %eax
f01017f0:	68 64 5d 10 f0       	push   $0xf0105d64
f01017f5:	6a 58                	push   $0x58
f01017f7:	68 83 6c 10 f0       	push   $0xf0106c83
f01017fc:	e8 3f e8 ff ff       	call   f0100040 <_panic>
f0101801:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101807:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010180d:	80 38 00             	cmpb   $0x0,(%eax)
f0101810:	74 19                	je     f010182b <mem_init+0x515>
f0101812:	68 4d 6e 10 f0       	push   $0xf0106e4d
f0101817:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010181c:	68 56 03 00 00       	push   $0x356
f0101821:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101826:	e8 15 e8 ff ff       	call   f0100040 <_panic>
f010182b:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010182e:	39 d0                	cmp    %edx,%eax
f0101830:	75 db                	jne    f010180d <mem_init+0x4f7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101832:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101835:	a3 40 72 20 f0       	mov    %eax,0xf0207240

	// free the pages we took
	page_free(pp0);
f010183a:	83 ec 0c             	sub    $0xc,%esp
f010183d:	56                   	push   %esi
f010183e:	e8 07 f7 ff ff       	call   f0100f4a <page_free>
	page_free(pp1);
f0101843:	89 3c 24             	mov    %edi,(%esp)
f0101846:	e8 ff f6 ff ff       	call   f0100f4a <page_free>
	page_free(pp2);
f010184b:	83 c4 04             	add    $0x4,%esp
f010184e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101851:	e8 f4 f6 ff ff       	call   f0100f4a <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101856:	a1 40 72 20 f0       	mov    0xf0207240,%eax
f010185b:	83 c4 10             	add    $0x10,%esp
f010185e:	eb 05                	jmp    f0101865 <mem_init+0x54f>
		--nfree;
f0101860:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101863:	8b 00                	mov    (%eax),%eax
f0101865:	85 c0                	test   %eax,%eax
f0101867:	75 f7                	jne    f0101860 <mem_init+0x54a>
		--nfree;
	assert(nfree == 0);
f0101869:	85 db                	test   %ebx,%ebx
f010186b:	74 19                	je     f0101886 <mem_init+0x570>
f010186d:	68 57 6e 10 f0       	push   $0xf0106e57
f0101872:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101877:	68 63 03 00 00       	push   $0x363
f010187c:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101881:	e8 ba e7 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101886:	83 ec 0c             	sub    $0xc,%esp
f0101889:	68 a0 64 10 f0       	push   $0xf01064a0
f010188e:	e8 9e 1d 00 00       	call   f0103631 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101893:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010189a:	e8 3b f6 ff ff       	call   f0100eda <page_alloc>
f010189f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018a2:	83 c4 10             	add    $0x10,%esp
f01018a5:	85 c0                	test   %eax,%eax
f01018a7:	75 19                	jne    f01018c2 <mem_init+0x5ac>
f01018a9:	68 65 6d 10 f0       	push   $0xf0106d65
f01018ae:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01018b3:	68 c9 03 00 00       	push   $0x3c9
f01018b8:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01018bd:	e8 7e e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018c2:	83 ec 0c             	sub    $0xc,%esp
f01018c5:	6a 00                	push   $0x0
f01018c7:	e8 0e f6 ff ff       	call   f0100eda <page_alloc>
f01018cc:	89 c3                	mov    %eax,%ebx
f01018ce:	83 c4 10             	add    $0x10,%esp
f01018d1:	85 c0                	test   %eax,%eax
f01018d3:	75 19                	jne    f01018ee <mem_init+0x5d8>
f01018d5:	68 7b 6d 10 f0       	push   $0xf0106d7b
f01018da:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01018df:	68 ca 03 00 00       	push   $0x3ca
f01018e4:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01018e9:	e8 52 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018ee:	83 ec 0c             	sub    $0xc,%esp
f01018f1:	6a 00                	push   $0x0
f01018f3:	e8 e2 f5 ff ff       	call   f0100eda <page_alloc>
f01018f8:	89 c6                	mov    %eax,%esi
f01018fa:	83 c4 10             	add    $0x10,%esp
f01018fd:	85 c0                	test   %eax,%eax
f01018ff:	75 19                	jne    f010191a <mem_init+0x604>
f0101901:	68 91 6d 10 f0       	push   $0xf0106d91
f0101906:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010190b:	68 cb 03 00 00       	push   $0x3cb
f0101910:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101915:	e8 26 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010191a:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010191d:	75 19                	jne    f0101938 <mem_init+0x622>
f010191f:	68 a7 6d 10 f0       	push   $0xf0106da7
f0101924:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101929:	68 ce 03 00 00       	push   $0x3ce
f010192e:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101933:	e8 08 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101938:	39 c3                	cmp    %eax,%ebx
f010193a:	74 05                	je     f0101941 <mem_init+0x62b>
f010193c:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010193f:	75 19                	jne    f010195a <mem_init+0x644>
f0101941:	68 80 64 10 f0       	push   $0xf0106480
f0101946:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010194b:	68 cf 03 00 00       	push   $0x3cf
f0101950:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101955:	e8 e6 e6 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010195a:	a1 40 72 20 f0       	mov    0xf0207240,%eax
f010195f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101962:	c7 05 40 72 20 f0 00 	movl   $0x0,0xf0207240
f0101969:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010196c:	83 ec 0c             	sub    $0xc,%esp
f010196f:	6a 00                	push   $0x0
f0101971:	e8 64 f5 ff ff       	call   f0100eda <page_alloc>
f0101976:	83 c4 10             	add    $0x10,%esp
f0101979:	85 c0                	test   %eax,%eax
f010197b:	74 19                	je     f0101996 <mem_init+0x680>
f010197d:	68 10 6e 10 f0       	push   $0xf0106e10
f0101982:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101987:	68 d6 03 00 00       	push   $0x3d6
f010198c:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101991:	e8 aa e6 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101996:	83 ec 04             	sub    $0x4,%esp
f0101999:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010199c:	50                   	push   %eax
f010199d:	6a 00                	push   $0x0
f010199f:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f01019a5:	e8 88 f7 ff ff       	call   f0101132 <page_lookup>
f01019aa:	83 c4 10             	add    $0x10,%esp
f01019ad:	85 c0                	test   %eax,%eax
f01019af:	74 19                	je     f01019ca <mem_init+0x6b4>
f01019b1:	68 c0 64 10 f0       	push   $0xf01064c0
f01019b6:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01019bb:	68 d9 03 00 00       	push   $0x3d9
f01019c0:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01019c5:	e8 76 e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019ca:	6a 02                	push   $0x2
f01019cc:	6a 00                	push   $0x0
f01019ce:	53                   	push   %ebx
f01019cf:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f01019d5:	e8 3e f8 ff ff       	call   f0101218 <page_insert>
f01019da:	83 c4 10             	add    $0x10,%esp
f01019dd:	85 c0                	test   %eax,%eax
f01019df:	78 19                	js     f01019fa <mem_init+0x6e4>
f01019e1:	68 f8 64 10 f0       	push   $0xf01064f8
f01019e6:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01019eb:	68 dc 03 00 00       	push   $0x3dc
f01019f0:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01019f5:	e8 46 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01019fa:	83 ec 0c             	sub    $0xc,%esp
f01019fd:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a00:	e8 45 f5 ff ff       	call   f0100f4a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a05:	6a 02                	push   $0x2
f0101a07:	6a 00                	push   $0x0
f0101a09:	53                   	push   %ebx
f0101a0a:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101a10:	e8 03 f8 ff ff       	call   f0101218 <page_insert>
f0101a15:	83 c4 20             	add    $0x20,%esp
f0101a18:	85 c0                	test   %eax,%eax
f0101a1a:	74 19                	je     f0101a35 <mem_init+0x71f>
f0101a1c:	68 28 65 10 f0       	push   $0xf0106528
f0101a21:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101a26:	68 e0 03 00 00       	push   $0x3e0
f0101a2b:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101a30:	e8 0b e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a35:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a3b:	a1 90 7e 20 f0       	mov    0xf0207e90,%eax
f0101a40:	89 c1                	mov    %eax,%ecx
f0101a42:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101a45:	8b 17                	mov    (%edi),%edx
f0101a47:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a4d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a50:	29 c8                	sub    %ecx,%eax
f0101a52:	c1 f8 03             	sar    $0x3,%eax
f0101a55:	c1 e0 0c             	shl    $0xc,%eax
f0101a58:	39 c2                	cmp    %eax,%edx
f0101a5a:	74 19                	je     f0101a75 <mem_init+0x75f>
f0101a5c:	68 58 65 10 f0       	push   $0xf0106558
f0101a61:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101a66:	68 e1 03 00 00       	push   $0x3e1
f0101a6b:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101a70:	e8 cb e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a75:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a7a:	89 f8                	mov    %edi,%eax
f0101a7c:	e8 b7 ef ff ff       	call   f0100a38 <check_va2pa>
f0101a81:	89 da                	mov    %ebx,%edx
f0101a83:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a86:	c1 fa 03             	sar    $0x3,%edx
f0101a89:	c1 e2 0c             	shl    $0xc,%edx
f0101a8c:	39 d0                	cmp    %edx,%eax
f0101a8e:	74 19                	je     f0101aa9 <mem_init+0x793>
f0101a90:	68 80 65 10 f0       	push   $0xf0106580
f0101a95:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101a9a:	68 e2 03 00 00       	push   $0x3e2
f0101a9f:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101aa4:	e8 97 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101aa9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101aae:	74 19                	je     f0101ac9 <mem_init+0x7b3>
f0101ab0:	68 62 6e 10 f0       	push   $0xf0106e62
f0101ab5:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101aba:	68 e3 03 00 00       	push   $0x3e3
f0101abf:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101ac4:	e8 77 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101ac9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101acc:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ad1:	74 19                	je     f0101aec <mem_init+0x7d6>
f0101ad3:	68 73 6e 10 f0       	push   $0xf0106e73
f0101ad8:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101add:	68 e4 03 00 00       	push   $0x3e4
f0101ae2:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101ae7:	e8 54 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101aec:	6a 02                	push   $0x2
f0101aee:	68 00 10 00 00       	push   $0x1000
f0101af3:	56                   	push   %esi
f0101af4:	57                   	push   %edi
f0101af5:	e8 1e f7 ff ff       	call   f0101218 <page_insert>
f0101afa:	83 c4 10             	add    $0x10,%esp
f0101afd:	85 c0                	test   %eax,%eax
f0101aff:	74 19                	je     f0101b1a <mem_init+0x804>
f0101b01:	68 b0 65 10 f0       	push   $0xf01065b0
f0101b06:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101b0b:	68 e7 03 00 00       	push   $0x3e7
f0101b10:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101b15:	e8 26 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b1a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b1f:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f0101b24:	e8 0f ef ff ff       	call   f0100a38 <check_va2pa>
f0101b29:	89 f2                	mov    %esi,%edx
f0101b2b:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0101b31:	c1 fa 03             	sar    $0x3,%edx
f0101b34:	c1 e2 0c             	shl    $0xc,%edx
f0101b37:	39 d0                	cmp    %edx,%eax
f0101b39:	74 19                	je     f0101b54 <mem_init+0x83e>
f0101b3b:	68 ec 65 10 f0       	push   $0xf01065ec
f0101b40:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101b45:	68 e8 03 00 00       	push   $0x3e8
f0101b4a:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101b4f:	e8 ec e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b54:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b59:	74 19                	je     f0101b74 <mem_init+0x85e>
f0101b5b:	68 84 6e 10 f0       	push   $0xf0106e84
f0101b60:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101b65:	68 e9 03 00 00       	push   $0x3e9
f0101b6a:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101b6f:	e8 cc e4 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b74:	83 ec 0c             	sub    $0xc,%esp
f0101b77:	6a 00                	push   $0x0
f0101b79:	e8 5c f3 ff ff       	call   f0100eda <page_alloc>
f0101b7e:	83 c4 10             	add    $0x10,%esp
f0101b81:	85 c0                	test   %eax,%eax
f0101b83:	74 19                	je     f0101b9e <mem_init+0x888>
f0101b85:	68 10 6e 10 f0       	push   $0xf0106e10
f0101b8a:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101b8f:	68 ec 03 00 00       	push   $0x3ec
f0101b94:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101b99:	e8 a2 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b9e:	6a 02                	push   $0x2
f0101ba0:	68 00 10 00 00       	push   $0x1000
f0101ba5:	56                   	push   %esi
f0101ba6:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101bac:	e8 67 f6 ff ff       	call   f0101218 <page_insert>
f0101bb1:	83 c4 10             	add    $0x10,%esp
f0101bb4:	85 c0                	test   %eax,%eax
f0101bb6:	74 19                	je     f0101bd1 <mem_init+0x8bb>
f0101bb8:	68 b0 65 10 f0       	push   $0xf01065b0
f0101bbd:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101bc2:	68 ef 03 00 00       	push   $0x3ef
f0101bc7:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101bcc:	e8 6f e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bd1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bd6:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f0101bdb:	e8 58 ee ff ff       	call   f0100a38 <check_va2pa>
f0101be0:	89 f2                	mov    %esi,%edx
f0101be2:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0101be8:	c1 fa 03             	sar    $0x3,%edx
f0101beb:	c1 e2 0c             	shl    $0xc,%edx
f0101bee:	39 d0                	cmp    %edx,%eax
f0101bf0:	74 19                	je     f0101c0b <mem_init+0x8f5>
f0101bf2:	68 ec 65 10 f0       	push   $0xf01065ec
f0101bf7:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101bfc:	68 f0 03 00 00       	push   $0x3f0
f0101c01:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101c06:	e8 35 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c0b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c10:	74 19                	je     f0101c2b <mem_init+0x915>
f0101c12:	68 84 6e 10 f0       	push   $0xf0106e84
f0101c17:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101c1c:	68 f1 03 00 00       	push   $0x3f1
f0101c21:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101c26:	e8 15 e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c2b:	83 ec 0c             	sub    $0xc,%esp
f0101c2e:	6a 00                	push   $0x0
f0101c30:	e8 a5 f2 ff ff       	call   f0100eda <page_alloc>
f0101c35:	83 c4 10             	add    $0x10,%esp
f0101c38:	85 c0                	test   %eax,%eax
f0101c3a:	74 19                	je     f0101c55 <mem_init+0x93f>
f0101c3c:	68 10 6e 10 f0       	push   $0xf0106e10
f0101c41:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101c46:	68 f5 03 00 00       	push   $0x3f5
f0101c4b:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101c50:	e8 eb e3 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c55:	8b 15 8c 7e 20 f0    	mov    0xf0207e8c,%edx
f0101c5b:	8b 02                	mov    (%edx),%eax
f0101c5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c62:	89 c1                	mov    %eax,%ecx
f0101c64:	c1 e9 0c             	shr    $0xc,%ecx
f0101c67:	3b 0d 88 7e 20 f0    	cmp    0xf0207e88,%ecx
f0101c6d:	72 15                	jb     f0101c84 <mem_init+0x96e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c6f:	50                   	push   %eax
f0101c70:	68 64 5d 10 f0       	push   $0xf0105d64
f0101c75:	68 f8 03 00 00       	push   $0x3f8
f0101c7a:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101c7f:	e8 bc e3 ff ff       	call   f0100040 <_panic>
f0101c84:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c8c:	83 ec 04             	sub    $0x4,%esp
f0101c8f:	6a 00                	push   $0x0
f0101c91:	68 00 10 00 00       	push   $0x1000
f0101c96:	52                   	push   %edx
f0101c97:	e8 10 f3 ff ff       	call   f0100fac <pgdir_walk>
f0101c9c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c9f:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ca2:	83 c4 10             	add    $0x10,%esp
f0101ca5:	39 d0                	cmp    %edx,%eax
f0101ca7:	74 19                	je     f0101cc2 <mem_init+0x9ac>
f0101ca9:	68 1c 66 10 f0       	push   $0xf010661c
f0101cae:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101cb3:	68 f9 03 00 00       	push   $0x3f9
f0101cb8:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101cbd:	e8 7e e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cc2:	6a 06                	push   $0x6
f0101cc4:	68 00 10 00 00       	push   $0x1000
f0101cc9:	56                   	push   %esi
f0101cca:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101cd0:	e8 43 f5 ff ff       	call   f0101218 <page_insert>
f0101cd5:	83 c4 10             	add    $0x10,%esp
f0101cd8:	85 c0                	test   %eax,%eax
f0101cda:	74 19                	je     f0101cf5 <mem_init+0x9df>
f0101cdc:	68 5c 66 10 f0       	push   $0xf010665c
f0101ce1:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101ce6:	68 fc 03 00 00       	push   $0x3fc
f0101ceb:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101cf0:	e8 4b e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cf5:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
f0101cfb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d00:	89 f8                	mov    %edi,%eax
f0101d02:	e8 31 ed ff ff       	call   f0100a38 <check_va2pa>
f0101d07:	89 f2                	mov    %esi,%edx
f0101d09:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0101d0f:	c1 fa 03             	sar    $0x3,%edx
f0101d12:	c1 e2 0c             	shl    $0xc,%edx
f0101d15:	39 d0                	cmp    %edx,%eax
f0101d17:	74 19                	je     f0101d32 <mem_init+0xa1c>
f0101d19:	68 ec 65 10 f0       	push   $0xf01065ec
f0101d1e:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101d23:	68 fd 03 00 00       	push   $0x3fd
f0101d28:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101d2d:	e8 0e e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d32:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d37:	74 19                	je     f0101d52 <mem_init+0xa3c>
f0101d39:	68 84 6e 10 f0       	push   $0xf0106e84
f0101d3e:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101d43:	68 fe 03 00 00       	push   $0x3fe
f0101d48:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101d4d:	e8 ee e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d52:	83 ec 04             	sub    $0x4,%esp
f0101d55:	6a 00                	push   $0x0
f0101d57:	68 00 10 00 00       	push   $0x1000
f0101d5c:	57                   	push   %edi
f0101d5d:	e8 4a f2 ff ff       	call   f0100fac <pgdir_walk>
f0101d62:	83 c4 10             	add    $0x10,%esp
f0101d65:	f6 00 04             	testb  $0x4,(%eax)
f0101d68:	75 19                	jne    f0101d83 <mem_init+0xa6d>
f0101d6a:	68 9c 66 10 f0       	push   $0xf010669c
f0101d6f:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101d74:	68 ff 03 00 00       	push   $0x3ff
f0101d79:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101d7e:	e8 bd e2 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d83:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f0101d88:	f6 00 04             	testb  $0x4,(%eax)
f0101d8b:	75 19                	jne    f0101da6 <mem_init+0xa90>
f0101d8d:	68 95 6e 10 f0       	push   $0xf0106e95
f0101d92:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101d97:	68 00 04 00 00       	push   $0x400
f0101d9c:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101da1:	e8 9a e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101da6:	6a 02                	push   $0x2
f0101da8:	68 00 10 00 00       	push   $0x1000
f0101dad:	56                   	push   %esi
f0101dae:	50                   	push   %eax
f0101daf:	e8 64 f4 ff ff       	call   f0101218 <page_insert>
f0101db4:	83 c4 10             	add    $0x10,%esp
f0101db7:	85 c0                	test   %eax,%eax
f0101db9:	74 19                	je     f0101dd4 <mem_init+0xabe>
f0101dbb:	68 b0 65 10 f0       	push   $0xf01065b0
f0101dc0:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101dc5:	68 03 04 00 00       	push   $0x403
f0101dca:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101dcf:	e8 6c e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101dd4:	83 ec 04             	sub    $0x4,%esp
f0101dd7:	6a 00                	push   $0x0
f0101dd9:	68 00 10 00 00       	push   $0x1000
f0101dde:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101de4:	e8 c3 f1 ff ff       	call   f0100fac <pgdir_walk>
f0101de9:	83 c4 10             	add    $0x10,%esp
f0101dec:	f6 00 02             	testb  $0x2,(%eax)
f0101def:	75 19                	jne    f0101e0a <mem_init+0xaf4>
f0101df1:	68 d0 66 10 f0       	push   $0xf01066d0
f0101df6:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101dfb:	68 04 04 00 00       	push   $0x404
f0101e00:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101e05:	e8 36 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e0a:	83 ec 04             	sub    $0x4,%esp
f0101e0d:	6a 00                	push   $0x0
f0101e0f:	68 00 10 00 00       	push   $0x1000
f0101e14:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101e1a:	e8 8d f1 ff ff       	call   f0100fac <pgdir_walk>
f0101e1f:	83 c4 10             	add    $0x10,%esp
f0101e22:	f6 00 04             	testb  $0x4,(%eax)
f0101e25:	74 19                	je     f0101e40 <mem_init+0xb2a>
f0101e27:	68 04 67 10 f0       	push   $0xf0106704
f0101e2c:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101e31:	68 05 04 00 00       	push   $0x405
f0101e36:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101e3b:	e8 00 e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e40:	6a 02                	push   $0x2
f0101e42:	68 00 00 40 00       	push   $0x400000
f0101e47:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e4a:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101e50:	e8 c3 f3 ff ff       	call   f0101218 <page_insert>
f0101e55:	83 c4 10             	add    $0x10,%esp
f0101e58:	85 c0                	test   %eax,%eax
f0101e5a:	78 19                	js     f0101e75 <mem_init+0xb5f>
f0101e5c:	68 3c 67 10 f0       	push   $0xf010673c
f0101e61:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101e66:	68 08 04 00 00       	push   $0x408
f0101e6b:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101e70:	e8 cb e1 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e75:	6a 02                	push   $0x2
f0101e77:	68 00 10 00 00       	push   $0x1000
f0101e7c:	53                   	push   %ebx
f0101e7d:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101e83:	e8 90 f3 ff ff       	call   f0101218 <page_insert>
f0101e88:	83 c4 10             	add    $0x10,%esp
f0101e8b:	85 c0                	test   %eax,%eax
f0101e8d:	74 19                	je     f0101ea8 <mem_init+0xb92>
f0101e8f:	68 74 67 10 f0       	push   $0xf0106774
f0101e94:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101e99:	68 0b 04 00 00       	push   $0x40b
f0101e9e:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101ea3:	e8 98 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ea8:	83 ec 04             	sub    $0x4,%esp
f0101eab:	6a 00                	push   $0x0
f0101ead:	68 00 10 00 00       	push   $0x1000
f0101eb2:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101eb8:	e8 ef f0 ff ff       	call   f0100fac <pgdir_walk>
f0101ebd:	83 c4 10             	add    $0x10,%esp
f0101ec0:	f6 00 04             	testb  $0x4,(%eax)
f0101ec3:	74 19                	je     f0101ede <mem_init+0xbc8>
f0101ec5:	68 04 67 10 f0       	push   $0xf0106704
f0101eca:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101ecf:	68 0c 04 00 00       	push   $0x40c
f0101ed4:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101ed9:	e8 62 e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ede:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
f0101ee4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ee9:	89 f8                	mov    %edi,%eax
f0101eeb:	e8 48 eb ff ff       	call   f0100a38 <check_va2pa>
f0101ef0:	89 c1                	mov    %eax,%ecx
f0101ef2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ef5:	89 d8                	mov    %ebx,%eax
f0101ef7:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0101efd:	c1 f8 03             	sar    $0x3,%eax
f0101f00:	c1 e0 0c             	shl    $0xc,%eax
f0101f03:	39 c1                	cmp    %eax,%ecx
f0101f05:	74 19                	je     f0101f20 <mem_init+0xc0a>
f0101f07:	68 b0 67 10 f0       	push   $0xf01067b0
f0101f0c:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101f11:	68 0f 04 00 00       	push   $0x40f
f0101f16:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101f1b:	e8 20 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f20:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f25:	89 f8                	mov    %edi,%eax
f0101f27:	e8 0c eb ff ff       	call   f0100a38 <check_va2pa>
f0101f2c:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101f2f:	74 19                	je     f0101f4a <mem_init+0xc34>
f0101f31:	68 dc 67 10 f0       	push   $0xf01067dc
f0101f36:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101f3b:	68 10 04 00 00       	push   $0x410
f0101f40:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101f45:	e8 f6 e0 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f4a:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101f4f:	74 19                	je     f0101f6a <mem_init+0xc54>
f0101f51:	68 ab 6e 10 f0       	push   $0xf0106eab
f0101f56:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101f5b:	68 12 04 00 00       	push   $0x412
f0101f60:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101f65:	e8 d6 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f6a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f6f:	74 19                	je     f0101f8a <mem_init+0xc74>
f0101f71:	68 bc 6e 10 f0       	push   $0xf0106ebc
f0101f76:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101f7b:	68 13 04 00 00       	push   $0x413
f0101f80:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101f85:	e8 b6 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f8a:	83 ec 0c             	sub    $0xc,%esp
f0101f8d:	6a 00                	push   $0x0
f0101f8f:	e8 46 ef ff ff       	call   f0100eda <page_alloc>
f0101f94:	83 c4 10             	add    $0x10,%esp
f0101f97:	85 c0                	test   %eax,%eax
f0101f99:	74 04                	je     f0101f9f <mem_init+0xc89>
f0101f9b:	39 c6                	cmp    %eax,%esi
f0101f9d:	74 19                	je     f0101fb8 <mem_init+0xca2>
f0101f9f:	68 0c 68 10 f0       	push   $0xf010680c
f0101fa4:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101fa9:	68 16 04 00 00       	push   $0x416
f0101fae:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101fb3:	e8 88 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101fb8:	83 ec 08             	sub    $0x8,%esp
f0101fbb:	6a 00                	push   $0x0
f0101fbd:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0101fc3:	e8 0a f2 ff ff       	call   f01011d2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101fc8:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
f0101fce:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fd3:	89 f8                	mov    %edi,%eax
f0101fd5:	e8 5e ea ff ff       	call   f0100a38 <check_va2pa>
f0101fda:	83 c4 10             	add    $0x10,%esp
f0101fdd:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fe0:	74 19                	je     f0101ffb <mem_init+0xce5>
f0101fe2:	68 30 68 10 f0       	push   $0xf0106830
f0101fe7:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0101fec:	68 1a 04 00 00       	push   $0x41a
f0101ff1:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0101ff6:	e8 45 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ffb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102000:	89 f8                	mov    %edi,%eax
f0102002:	e8 31 ea ff ff       	call   f0100a38 <check_va2pa>
f0102007:	89 da                	mov    %ebx,%edx
f0102009:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f010200f:	c1 fa 03             	sar    $0x3,%edx
f0102012:	c1 e2 0c             	shl    $0xc,%edx
f0102015:	39 d0                	cmp    %edx,%eax
f0102017:	74 19                	je     f0102032 <mem_init+0xd1c>
f0102019:	68 dc 67 10 f0       	push   $0xf01067dc
f010201e:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102023:	68 1b 04 00 00       	push   $0x41b
f0102028:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010202d:	e8 0e e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102032:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102037:	74 19                	je     f0102052 <mem_init+0xd3c>
f0102039:	68 62 6e 10 f0       	push   $0xf0106e62
f010203e:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102043:	68 1c 04 00 00       	push   $0x41c
f0102048:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010204d:	e8 ee df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102052:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102057:	74 19                	je     f0102072 <mem_init+0xd5c>
f0102059:	68 bc 6e 10 f0       	push   $0xf0106ebc
f010205e:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102063:	68 1d 04 00 00       	push   $0x41d
f0102068:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010206d:	e8 ce df ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102072:	6a 00                	push   $0x0
f0102074:	68 00 10 00 00       	push   $0x1000
f0102079:	53                   	push   %ebx
f010207a:	57                   	push   %edi
f010207b:	e8 98 f1 ff ff       	call   f0101218 <page_insert>
f0102080:	83 c4 10             	add    $0x10,%esp
f0102083:	85 c0                	test   %eax,%eax
f0102085:	74 19                	je     f01020a0 <mem_init+0xd8a>
f0102087:	68 54 68 10 f0       	push   $0xf0106854
f010208c:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102091:	68 20 04 00 00       	push   $0x420
f0102096:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010209b:	e8 a0 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01020a0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020a5:	75 19                	jne    f01020c0 <mem_init+0xdaa>
f01020a7:	68 cd 6e 10 f0       	push   $0xf0106ecd
f01020ac:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01020b1:	68 21 04 00 00       	push   $0x421
f01020b6:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01020bb:	e8 80 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01020c0:	83 3b 00             	cmpl   $0x0,(%ebx)
f01020c3:	74 19                	je     f01020de <mem_init+0xdc8>
f01020c5:	68 d9 6e 10 f0       	push   $0xf0106ed9
f01020ca:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01020cf:	68 22 04 00 00       	push   $0x422
f01020d4:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01020d9:	e8 62 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01020de:	83 ec 08             	sub    $0x8,%esp
f01020e1:	68 00 10 00 00       	push   $0x1000
f01020e6:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f01020ec:	e8 e1 f0 ff ff       	call   f01011d2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020f1:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
f01020f7:	ba 00 00 00 00       	mov    $0x0,%edx
f01020fc:	89 f8                	mov    %edi,%eax
f01020fe:	e8 35 e9 ff ff       	call   f0100a38 <check_va2pa>
f0102103:	83 c4 10             	add    $0x10,%esp
f0102106:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102109:	74 19                	je     f0102124 <mem_init+0xe0e>
f010210b:	68 30 68 10 f0       	push   $0xf0106830
f0102110:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102115:	68 26 04 00 00       	push   $0x426
f010211a:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010211f:	e8 1c df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102124:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102129:	89 f8                	mov    %edi,%eax
f010212b:	e8 08 e9 ff ff       	call   f0100a38 <check_va2pa>
f0102130:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102133:	74 19                	je     f010214e <mem_init+0xe38>
f0102135:	68 8c 68 10 f0       	push   $0xf010688c
f010213a:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010213f:	68 27 04 00 00       	push   $0x427
f0102144:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102149:	e8 f2 de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010214e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102153:	74 19                	je     f010216e <mem_init+0xe58>
f0102155:	68 ee 6e 10 f0       	push   $0xf0106eee
f010215a:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010215f:	68 28 04 00 00       	push   $0x428
f0102164:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102169:	e8 d2 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010216e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102173:	74 19                	je     f010218e <mem_init+0xe78>
f0102175:	68 bc 6e 10 f0       	push   $0xf0106ebc
f010217a:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010217f:	68 29 04 00 00       	push   $0x429
f0102184:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102189:	e8 b2 de ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010218e:	83 ec 0c             	sub    $0xc,%esp
f0102191:	6a 00                	push   $0x0
f0102193:	e8 42 ed ff ff       	call   f0100eda <page_alloc>
f0102198:	83 c4 10             	add    $0x10,%esp
f010219b:	39 c3                	cmp    %eax,%ebx
f010219d:	75 04                	jne    f01021a3 <mem_init+0xe8d>
f010219f:	85 c0                	test   %eax,%eax
f01021a1:	75 19                	jne    f01021bc <mem_init+0xea6>
f01021a3:	68 b4 68 10 f0       	push   $0xf01068b4
f01021a8:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01021ad:	68 2c 04 00 00       	push   $0x42c
f01021b2:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01021b7:	e8 84 de ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01021bc:	83 ec 0c             	sub    $0xc,%esp
f01021bf:	6a 00                	push   $0x0
f01021c1:	e8 14 ed ff ff       	call   f0100eda <page_alloc>
f01021c6:	83 c4 10             	add    $0x10,%esp
f01021c9:	85 c0                	test   %eax,%eax
f01021cb:	74 19                	je     f01021e6 <mem_init+0xed0>
f01021cd:	68 10 6e 10 f0       	push   $0xf0106e10
f01021d2:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01021d7:	68 2f 04 00 00       	push   $0x42f
f01021dc:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01021e1:	e8 5a de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01021e6:	8b 0d 8c 7e 20 f0    	mov    0xf0207e8c,%ecx
f01021ec:	8b 11                	mov    (%ecx),%edx
f01021ee:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021f7:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f01021fd:	c1 f8 03             	sar    $0x3,%eax
f0102200:	c1 e0 0c             	shl    $0xc,%eax
f0102203:	39 c2                	cmp    %eax,%edx
f0102205:	74 19                	je     f0102220 <mem_init+0xf0a>
f0102207:	68 58 65 10 f0       	push   $0xf0106558
f010220c:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102211:	68 32 04 00 00       	push   $0x432
f0102216:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010221b:	e8 20 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102220:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102226:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102229:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010222e:	74 19                	je     f0102249 <mem_init+0xf33>
f0102230:	68 73 6e 10 f0       	push   $0xf0106e73
f0102235:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010223a:	68 34 04 00 00       	push   $0x434
f010223f:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102244:	e8 f7 dd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102249:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010224c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102252:	83 ec 0c             	sub    $0xc,%esp
f0102255:	50                   	push   %eax
f0102256:	e8 ef ec ff ff       	call   f0100f4a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010225b:	83 c4 0c             	add    $0xc,%esp
f010225e:	6a 01                	push   $0x1
f0102260:	68 00 10 40 00       	push   $0x401000
f0102265:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f010226b:	e8 3c ed ff ff       	call   f0100fac <pgdir_walk>
f0102270:	89 c7                	mov    %eax,%edi
f0102272:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102275:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f010227a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010227d:	8b 40 04             	mov    0x4(%eax),%eax
f0102280:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102285:	8b 0d 88 7e 20 f0    	mov    0xf0207e88,%ecx
f010228b:	89 c2                	mov    %eax,%edx
f010228d:	c1 ea 0c             	shr    $0xc,%edx
f0102290:	83 c4 10             	add    $0x10,%esp
f0102293:	39 ca                	cmp    %ecx,%edx
f0102295:	72 15                	jb     f01022ac <mem_init+0xf96>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102297:	50                   	push   %eax
f0102298:	68 64 5d 10 f0       	push   $0xf0105d64
f010229d:	68 3b 04 00 00       	push   $0x43b
f01022a2:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01022a7:	e8 94 dd ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01022ac:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01022b1:	39 c7                	cmp    %eax,%edi
f01022b3:	74 19                	je     f01022ce <mem_init+0xfb8>
f01022b5:	68 ff 6e 10 f0       	push   $0xf0106eff
f01022ba:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01022bf:	68 3c 04 00 00       	push   $0x43c
f01022c4:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01022c9:	e8 72 dd ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01022ce:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01022d1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01022d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022db:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022e1:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f01022e7:	c1 f8 03             	sar    $0x3,%eax
f01022ea:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022ed:	89 c2                	mov    %eax,%edx
f01022ef:	c1 ea 0c             	shr    $0xc,%edx
f01022f2:	39 d1                	cmp    %edx,%ecx
f01022f4:	77 12                	ja     f0102308 <mem_init+0xff2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022f6:	50                   	push   %eax
f01022f7:	68 64 5d 10 f0       	push   $0xf0105d64
f01022fc:	6a 58                	push   $0x58
f01022fe:	68 83 6c 10 f0       	push   $0xf0106c83
f0102303:	e8 38 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102308:	83 ec 04             	sub    $0x4,%esp
f010230b:	68 00 10 00 00       	push   $0x1000
f0102310:	68 ff 00 00 00       	push   $0xff
f0102315:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010231a:	50                   	push   %eax
f010231b:	e8 65 2d 00 00       	call   f0105085 <memset>
	page_free(pp0);
f0102320:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102323:	89 3c 24             	mov    %edi,(%esp)
f0102326:	e8 1f ec ff ff       	call   f0100f4a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010232b:	83 c4 0c             	add    $0xc,%esp
f010232e:	6a 01                	push   $0x1
f0102330:	6a 00                	push   $0x0
f0102332:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102338:	e8 6f ec ff ff       	call   f0100fac <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010233d:	89 fa                	mov    %edi,%edx
f010233f:	2b 15 90 7e 20 f0    	sub    0xf0207e90,%edx
f0102345:	c1 fa 03             	sar    $0x3,%edx
f0102348:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010234b:	89 d0                	mov    %edx,%eax
f010234d:	c1 e8 0c             	shr    $0xc,%eax
f0102350:	83 c4 10             	add    $0x10,%esp
f0102353:	3b 05 88 7e 20 f0    	cmp    0xf0207e88,%eax
f0102359:	72 12                	jb     f010236d <mem_init+0x1057>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010235b:	52                   	push   %edx
f010235c:	68 64 5d 10 f0       	push   $0xf0105d64
f0102361:	6a 58                	push   $0x58
f0102363:	68 83 6c 10 f0       	push   $0xf0106c83
f0102368:	e8 d3 dc ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010236d:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102373:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102376:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010237c:	f6 00 01             	testb  $0x1,(%eax)
f010237f:	74 19                	je     f010239a <mem_init+0x1084>
f0102381:	68 17 6f 10 f0       	push   $0xf0106f17
f0102386:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010238b:	68 46 04 00 00       	push   $0x446
f0102390:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102395:	e8 a6 dc ff ff       	call   f0100040 <_panic>
f010239a:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010239d:	39 d0                	cmp    %edx,%eax
f010239f:	75 db                	jne    f010237c <mem_init+0x1066>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01023a1:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f01023a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01023ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023af:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01023b5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01023b8:	89 0d 40 72 20 f0    	mov    %ecx,0xf0207240

	// free the pages we took
	page_free(pp0);
f01023be:	83 ec 0c             	sub    $0xc,%esp
f01023c1:	50                   	push   %eax
f01023c2:	e8 83 eb ff ff       	call   f0100f4a <page_free>
	page_free(pp1);
f01023c7:	89 1c 24             	mov    %ebx,(%esp)
f01023ca:	e8 7b eb ff ff       	call   f0100f4a <page_free>
	page_free(pp2);
f01023cf:	89 34 24             	mov    %esi,(%esp)
f01023d2:	e8 73 eb ff ff       	call   f0100f4a <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01023d7:	83 c4 08             	add    $0x8,%esp
f01023da:	68 01 10 00 00       	push   $0x1001
f01023df:	6a 00                	push   $0x0
f01023e1:	e8 c2 ee ff ff       	call   f01012a8 <mmio_map_region>
f01023e6:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01023e8:	83 c4 08             	add    $0x8,%esp
f01023eb:	68 00 10 00 00       	push   $0x1000
f01023f0:	6a 00                	push   $0x0
f01023f2:	e8 b1 ee ff ff       	call   f01012a8 <mmio_map_region>
f01023f7:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01023f9:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01023ff:	83 c4 10             	add    $0x10,%esp
f0102402:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102408:	76 07                	jbe    f0102411 <mem_init+0x10fb>
f010240a:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010240f:	76 19                	jbe    f010242a <mem_init+0x1114>
f0102411:	68 d8 68 10 f0       	push   $0xf01068d8
f0102416:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010241b:	68 56 04 00 00       	push   $0x456
f0102420:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102425:	e8 16 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010242a:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102430:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102436:	77 08                	ja     f0102440 <mem_init+0x112a>
f0102438:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010243e:	77 19                	ja     f0102459 <mem_init+0x1143>
f0102440:	68 00 69 10 f0       	push   $0xf0106900
f0102445:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010244a:	68 57 04 00 00       	push   $0x457
f010244f:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102454:	e8 e7 db ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102459:	89 da                	mov    %ebx,%edx
f010245b:	09 f2                	or     %esi,%edx
f010245d:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102463:	74 19                	je     f010247e <mem_init+0x1168>
f0102465:	68 28 69 10 f0       	push   $0xf0106928
f010246a:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010246f:	68 59 04 00 00       	push   $0x459
f0102474:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102479:	e8 c2 db ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010247e:	39 c6                	cmp    %eax,%esi
f0102480:	73 19                	jae    f010249b <mem_init+0x1185>
f0102482:	68 2e 6f 10 f0       	push   $0xf0106f2e
f0102487:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010248c:	68 5b 04 00 00       	push   $0x45b
f0102491:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102496:	e8 a5 db ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010249b:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi
f01024a1:	89 da                	mov    %ebx,%edx
f01024a3:	89 f8                	mov    %edi,%eax
f01024a5:	e8 8e e5 ff ff       	call   f0100a38 <check_va2pa>
f01024aa:	85 c0                	test   %eax,%eax
f01024ac:	74 19                	je     f01024c7 <mem_init+0x11b1>
f01024ae:	68 50 69 10 f0       	push   $0xf0106950
f01024b3:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01024b8:	68 5d 04 00 00       	push   $0x45d
f01024bd:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01024c2:	e8 79 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01024c7:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01024cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01024d0:	89 c2                	mov    %eax,%edx
f01024d2:	89 f8                	mov    %edi,%eax
f01024d4:	e8 5f e5 ff ff       	call   f0100a38 <check_va2pa>
f01024d9:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01024de:	74 19                	je     f01024f9 <mem_init+0x11e3>
f01024e0:	68 74 69 10 f0       	push   $0xf0106974
f01024e5:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01024ea:	68 5e 04 00 00       	push   $0x45e
f01024ef:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01024f4:	e8 47 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01024f9:	89 f2                	mov    %esi,%edx
f01024fb:	89 f8                	mov    %edi,%eax
f01024fd:	e8 36 e5 ff ff       	call   f0100a38 <check_va2pa>
f0102502:	85 c0                	test   %eax,%eax
f0102504:	74 19                	je     f010251f <mem_init+0x1209>
f0102506:	68 a4 69 10 f0       	push   $0xf01069a4
f010250b:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102510:	68 5f 04 00 00       	push   $0x45f
f0102515:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010251a:	e8 21 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010251f:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102525:	89 f8                	mov    %edi,%eax
f0102527:	e8 0c e5 ff ff       	call   f0100a38 <check_va2pa>
f010252c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010252f:	74 19                	je     f010254a <mem_init+0x1234>
f0102531:	68 c8 69 10 f0       	push   $0xf01069c8
f0102536:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010253b:	68 60 04 00 00       	push   $0x460
f0102540:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102545:	e8 f6 da ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010254a:	83 ec 04             	sub    $0x4,%esp
f010254d:	6a 00                	push   $0x0
f010254f:	53                   	push   %ebx
f0102550:	57                   	push   %edi
f0102551:	e8 56 ea ff ff       	call   f0100fac <pgdir_walk>
f0102556:	83 c4 10             	add    $0x10,%esp
f0102559:	f6 00 1a             	testb  $0x1a,(%eax)
f010255c:	75 19                	jne    f0102577 <mem_init+0x1261>
f010255e:	68 f4 69 10 f0       	push   $0xf01069f4
f0102563:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102568:	68 62 04 00 00       	push   $0x462
f010256d:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102572:	e8 c9 da ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102577:	83 ec 04             	sub    $0x4,%esp
f010257a:	6a 00                	push   $0x0
f010257c:	53                   	push   %ebx
f010257d:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102583:	e8 24 ea ff ff       	call   f0100fac <pgdir_walk>
f0102588:	8b 00                	mov    (%eax),%eax
f010258a:	83 c4 10             	add    $0x10,%esp
f010258d:	83 e0 04             	and    $0x4,%eax
f0102590:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102593:	74 19                	je     f01025ae <mem_init+0x1298>
f0102595:	68 38 6a 10 f0       	push   $0xf0106a38
f010259a:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010259f:	68 63 04 00 00       	push   $0x463
f01025a4:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01025a9:	e8 92 da ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01025ae:	83 ec 04             	sub    $0x4,%esp
f01025b1:	6a 00                	push   $0x0
f01025b3:	53                   	push   %ebx
f01025b4:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f01025ba:	e8 ed e9 ff ff       	call   f0100fac <pgdir_walk>
f01025bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01025c5:	83 c4 0c             	add    $0xc,%esp
f01025c8:	6a 00                	push   $0x0
f01025ca:	ff 75 d4             	pushl  -0x2c(%ebp)
f01025cd:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f01025d3:	e8 d4 e9 ff ff       	call   f0100fac <pgdir_walk>
f01025d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01025de:	83 c4 0c             	add    $0xc,%esp
f01025e1:	6a 00                	push   $0x0
f01025e3:	56                   	push   %esi
f01025e4:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f01025ea:	e8 bd e9 ff ff       	call   f0100fac <pgdir_walk>
f01025ef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01025f5:	c7 04 24 40 6f 10 f0 	movl   $0xf0106f40,(%esp)
f01025fc:	e8 30 10 00 00       	call   f0103631 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	uint32_t size = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0102601:	a1 88 7e 20 f0       	mov    0xf0207e88,%eax
f0102606:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f010260d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	boot_map_region(kern_pgdir, UPAGES, size, PADDR(pages), PTE_U);
f0102613:	a1 90 7e 20 f0       	mov    0xf0207e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102618:	83 c4 10             	add    $0x10,%esp
f010261b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102620:	77 15                	ja     f0102637 <mem_init+0x1321>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102622:	50                   	push   %eax
f0102623:	68 88 5d 10 f0       	push   $0xf0105d88
f0102628:	68 bf 00 00 00       	push   $0xbf
f010262d:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102632:	e8 09 da ff ff       	call   f0100040 <_panic>
f0102637:	83 ec 08             	sub    $0x8,%esp
f010263a:	6a 04                	push   $0x4
f010263c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102641:	50                   	push   %eax
f0102642:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102647:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f010264c:	e8 45 ea ff ff       	call   f0101096 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	size = ROUNDUP(NENV * sizeof(struct Env), PGSIZE);
	boot_map_region(kern_pgdir, UENVS, size, PADDR(envs), PTE_U);
f0102651:	a1 48 72 20 f0       	mov    0xf0207248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102656:	83 c4 10             	add    $0x10,%esp
f0102659:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010265e:	77 15                	ja     f0102675 <mem_init+0x135f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102660:	50                   	push   %eax
f0102661:	68 88 5d 10 f0       	push   $0xf0105d88
f0102666:	68 ca 00 00 00       	push   $0xca
f010266b:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102670:	e8 cb d9 ff ff       	call   f0100040 <_panic>
f0102675:	83 ec 08             	sub    $0x8,%esp
f0102678:	6a 04                	push   $0x4
f010267a:	05 00 00 00 10       	add    $0x10000000,%eax
f010267f:	50                   	push   %eax
f0102680:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102685:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010268a:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f010268f:	e8 02 ea ff ff       	call   f0101096 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102694:	83 c4 10             	add    $0x10,%esp
f0102697:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f010269c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026a1:	77 15                	ja     f01026b8 <mem_init+0x13a2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026a3:	50                   	push   %eax
f01026a4:	68 88 5d 10 f0       	push   $0xf0105d88
f01026a9:	68 d8 00 00 00       	push   $0xd8
f01026ae:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01026b3:	e8 88 d9 ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	extern char bootstack[];
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01026b8:	83 ec 08             	sub    $0x8,%esp
f01026bb:	6a 02                	push   $0x2
f01026bd:	68 00 60 11 00       	push   $0x116000
f01026c2:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026c7:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01026cc:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f01026d1:	e8 c0 e9 ff ff       	call   f0101096 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	size = ((0xFFFFFFFF) - KERNBASE) + 1;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, PTE_W);
f01026d6:	83 c4 08             	add    $0x8,%esp
f01026d9:	6a 02                	push   $0x2
f01026db:	6a 00                	push   $0x0
f01026dd:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026e2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026e7:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f01026ec:	e8 a5 e9 ff ff       	call   f0101096 <boot_map_region>
f01026f1:	c7 45 c4 00 90 20 f0 	movl   $0xf0209000,-0x3c(%ebp)
f01026f8:	83 c4 10             	add    $0x10,%esp
f01026fb:	bb 00 90 20 f0       	mov    $0xf0209000,%ebx
f0102700:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102705:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010270b:	77 15                	ja     f0102722 <mem_init+0x140c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010270d:	53                   	push   %ebx
f010270e:	68 88 5d 10 f0       	push   $0xf0105d88
f0102713:	68 1b 01 00 00       	push   $0x11b
f0102718:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010271d:	e8 1e d9 ff ff       	call   f0100040 <_panic>
	uint32_t i;
	for (i = 0; i < NCPU; i++) {
		uintptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		uintptr_t kstackbot_i = kstacktop_i - KSTKSIZE;
		physaddr_t kstackpa_i = PADDR(&percpu_kstacks[i]);
		boot_map_region(kern_pgdir, kstackbot_i, KSTKSIZE, kstackpa_i, PTE_W);
f0102722:	83 ec 08             	sub    $0x8,%esp
f0102725:	6a 02                	push   $0x2
f0102727:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010272d:	50                   	push   %eax
f010272e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102733:	89 f2                	mov    %esi,%edx
f0102735:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
f010273a:	e8 57 e9 ff ff       	call   f0101096 <boot_map_region>
f010273f:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102745:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uint32_t i;
	for (i = 0; i < NCPU; i++) {
f010274b:	83 c4 10             	add    $0x10,%esp
f010274e:	b8 00 90 24 f0       	mov    $0xf0249000,%eax
f0102753:	39 d8                	cmp    %ebx,%eax
f0102755:	75 ae                	jne    f0102705 <mem_init+0x13ef>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102757:	8b 3d 8c 7e 20 f0    	mov    0xf0207e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010275d:	a1 88 7e 20 f0       	mov    0xf0207e88,%eax
f0102762:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102765:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010276c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102774:	8b 35 90 7e 20 f0    	mov    0xf0207e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010277a:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010277d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102782:	eb 55                	jmp    f01027d9 <mem_init+0x14c3>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102784:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010278a:	89 f8                	mov    %edi,%eax
f010278c:	e8 a7 e2 ff ff       	call   f0100a38 <check_va2pa>
f0102791:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102798:	77 15                	ja     f01027af <mem_init+0x1499>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010279a:	56                   	push   %esi
f010279b:	68 88 5d 10 f0       	push   $0xf0105d88
f01027a0:	68 7b 03 00 00       	push   $0x37b
f01027a5:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01027aa:	e8 91 d8 ff ff       	call   f0100040 <_panic>
f01027af:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01027b6:	39 c2                	cmp    %eax,%edx
f01027b8:	74 19                	je     f01027d3 <mem_init+0x14bd>
f01027ba:	68 6c 6a 10 f0       	push   $0xf0106a6c
f01027bf:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01027c4:	68 7b 03 00 00       	push   $0x37b
f01027c9:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01027ce:	e8 6d d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027d3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027d9:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01027dc:	77 a6                	ja     f0102784 <mem_init+0x146e>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027de:	8b 35 48 72 20 f0    	mov    0xf0207248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027e4:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01027e7:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01027ec:	89 da                	mov    %ebx,%edx
f01027ee:	89 f8                	mov    %edi,%eax
f01027f0:	e8 43 e2 ff ff       	call   f0100a38 <check_va2pa>
f01027f5:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01027fc:	77 15                	ja     f0102813 <mem_init+0x14fd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027fe:	56                   	push   %esi
f01027ff:	68 88 5d 10 f0       	push   $0xf0105d88
f0102804:	68 80 03 00 00       	push   $0x380
f0102809:	68 5d 6c 10 f0       	push   $0xf0106c5d
f010280e:	e8 2d d8 ff ff       	call   f0100040 <_panic>
f0102813:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f010281a:	39 d0                	cmp    %edx,%eax
f010281c:	74 19                	je     f0102837 <mem_init+0x1521>
f010281e:	68 a0 6a 10 f0       	push   $0xf0106aa0
f0102823:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102828:	68 80 03 00 00       	push   $0x380
f010282d:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102832:	e8 09 d8 ff ff       	call   f0100040 <_panic>
f0102837:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010283d:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102843:	75 a7                	jne    f01027ec <mem_init+0x14d6>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102845:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102848:	c1 e6 0c             	shl    $0xc,%esi
f010284b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102850:	eb 30                	jmp    f0102882 <mem_init+0x156c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102852:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102858:	89 f8                	mov    %edi,%eax
f010285a:	e8 d9 e1 ff ff       	call   f0100a38 <check_va2pa>
f010285f:	39 c3                	cmp    %eax,%ebx
f0102861:	74 19                	je     f010287c <mem_init+0x1566>
f0102863:	68 d4 6a 10 f0       	push   $0xf0106ad4
f0102868:	68 9d 6c 10 f0       	push   $0xf0106c9d
f010286d:	68 84 03 00 00       	push   $0x384
f0102872:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102877:	e8 c4 d7 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010287c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102882:	39 f3                	cmp    %esi,%ebx
f0102884:	72 cc                	jb     f0102852 <mem_init+0x153c>
f0102886:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f010288b:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010288e:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102891:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102894:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f010289a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010289d:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010289f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01028a2:	05 00 80 00 20       	add    $0x20008000,%eax
f01028a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028aa:	89 da                	mov    %ebx,%edx
f01028ac:	89 f8                	mov    %edi,%eax
f01028ae:	e8 85 e1 ff ff       	call   f0100a38 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028b3:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01028b9:	77 15                	ja     f01028d0 <mem_init+0x15ba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028bb:	56                   	push   %esi
f01028bc:	68 88 5d 10 f0       	push   $0xf0105d88
f01028c1:	68 8c 03 00 00       	push   $0x38c
f01028c6:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01028cb:	e8 70 d7 ff ff       	call   f0100040 <_panic>
f01028d0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01028d3:	8d 94 0b 00 90 20 f0 	lea    -0xfdf7000(%ebx,%ecx,1),%edx
f01028da:	39 d0                	cmp    %edx,%eax
f01028dc:	74 19                	je     f01028f7 <mem_init+0x15e1>
f01028de:	68 fc 6a 10 f0       	push   $0xf0106afc
f01028e3:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01028e8:	68 8c 03 00 00       	push   $0x38c
f01028ed:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01028f2:	e8 49 d7 ff ff       	call   f0100040 <_panic>
f01028f7:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028fd:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102900:	75 a8                	jne    f01028aa <mem_init+0x1594>
f0102902:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102905:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f010290b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010290e:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102910:	89 da                	mov    %ebx,%edx
f0102912:	89 f8                	mov    %edi,%eax
f0102914:	e8 1f e1 ff ff       	call   f0100a38 <check_va2pa>
f0102919:	83 f8 ff             	cmp    $0xffffffff,%eax
f010291c:	74 19                	je     f0102937 <mem_init+0x1621>
f010291e:	68 44 6b 10 f0       	push   $0xf0106b44
f0102923:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102928:	68 8e 03 00 00       	push   $0x38e
f010292d:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102932:	e8 09 d7 ff ff       	call   f0100040 <_panic>
f0102937:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010293d:	39 de                	cmp    %ebx,%esi
f010293f:	75 cf                	jne    f0102910 <mem_init+0x15fa>
f0102941:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102944:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f010294b:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102952:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102958:	81 fe 00 90 24 f0    	cmp    $0xf0249000,%esi
f010295e:	0f 85 2d ff ff ff    	jne    f0102891 <mem_init+0x157b>
f0102964:	b8 00 00 00 00       	mov    $0x0,%eax
f0102969:	eb 2a                	jmp    f0102995 <mem_init+0x167f>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010296b:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102971:	83 fa 04             	cmp    $0x4,%edx
f0102974:	77 1f                	ja     f0102995 <mem_init+0x167f>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102976:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010297a:	75 7e                	jne    f01029fa <mem_init+0x16e4>
f010297c:	68 59 6f 10 f0       	push   $0xf0106f59
f0102981:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102986:	68 99 03 00 00       	push   $0x399
f010298b:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102990:	e8 ab d6 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102995:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010299a:	76 3f                	jbe    f01029db <mem_init+0x16c5>
				assert(pgdir[i] & PTE_P);
f010299c:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010299f:	f6 c2 01             	test   $0x1,%dl
f01029a2:	75 19                	jne    f01029bd <mem_init+0x16a7>
f01029a4:	68 59 6f 10 f0       	push   $0xf0106f59
f01029a9:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01029ae:	68 9d 03 00 00       	push   $0x39d
f01029b3:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01029b8:	e8 83 d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01029bd:	f6 c2 02             	test   $0x2,%dl
f01029c0:	75 38                	jne    f01029fa <mem_init+0x16e4>
f01029c2:	68 6a 6f 10 f0       	push   $0xf0106f6a
f01029c7:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01029cc:	68 9e 03 00 00       	push   $0x39e
f01029d1:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01029d6:	e8 65 d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029db:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01029df:	74 19                	je     f01029fa <mem_init+0x16e4>
f01029e1:	68 7b 6f 10 f0       	push   $0xf0106f7b
f01029e6:	68 9d 6c 10 f0       	push   $0xf0106c9d
f01029eb:	68 a0 03 00 00       	push   $0x3a0
f01029f0:	68 5d 6c 10 f0       	push   $0xf0106c5d
f01029f5:	e8 46 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01029fa:	83 c0 01             	add    $0x1,%eax
f01029fd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a02:	0f 86 63 ff ff ff    	jbe    f010296b <mem_init+0x1655>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102a08:	83 ec 0c             	sub    $0xc,%esp
f0102a0b:	68 68 6b 10 f0       	push   $0xf0106b68
f0102a10:	e8 1c 0c 00 00       	call   f0103631 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a15:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a1a:	83 c4 10             	add    $0x10,%esp
f0102a1d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a22:	77 15                	ja     f0102a39 <mem_init+0x1723>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a24:	50                   	push   %eax
f0102a25:	68 88 5d 10 f0       	push   $0xf0105d88
f0102a2a:	68 f2 00 00 00       	push   $0xf2
f0102a2f:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102a34:	e8 07 d6 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102a39:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a3e:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a41:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a46:	e8 d5 e0 ff ff       	call   f0100b20 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102a4b:	0f 20 c0             	mov    %cr0,%eax
f0102a4e:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102a51:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102a56:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a59:	83 ec 0c             	sub    $0xc,%esp
f0102a5c:	6a 00                	push   $0x0
f0102a5e:	e8 77 e4 ff ff       	call   f0100eda <page_alloc>
f0102a63:	89 c3                	mov    %eax,%ebx
f0102a65:	83 c4 10             	add    $0x10,%esp
f0102a68:	85 c0                	test   %eax,%eax
f0102a6a:	75 19                	jne    f0102a85 <mem_init+0x176f>
f0102a6c:	68 65 6d 10 f0       	push   $0xf0106d65
f0102a71:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102a76:	68 78 04 00 00       	push   $0x478
f0102a7b:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102a80:	e8 bb d5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a85:	83 ec 0c             	sub    $0xc,%esp
f0102a88:	6a 00                	push   $0x0
f0102a8a:	e8 4b e4 ff ff       	call   f0100eda <page_alloc>
f0102a8f:	89 c7                	mov    %eax,%edi
f0102a91:	83 c4 10             	add    $0x10,%esp
f0102a94:	85 c0                	test   %eax,%eax
f0102a96:	75 19                	jne    f0102ab1 <mem_init+0x179b>
f0102a98:	68 7b 6d 10 f0       	push   $0xf0106d7b
f0102a9d:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102aa2:	68 79 04 00 00       	push   $0x479
f0102aa7:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102aac:	e8 8f d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ab1:	83 ec 0c             	sub    $0xc,%esp
f0102ab4:	6a 00                	push   $0x0
f0102ab6:	e8 1f e4 ff ff       	call   f0100eda <page_alloc>
f0102abb:	89 c6                	mov    %eax,%esi
f0102abd:	83 c4 10             	add    $0x10,%esp
f0102ac0:	85 c0                	test   %eax,%eax
f0102ac2:	75 19                	jne    f0102add <mem_init+0x17c7>
f0102ac4:	68 91 6d 10 f0       	push   $0xf0106d91
f0102ac9:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102ace:	68 7a 04 00 00       	push   $0x47a
f0102ad3:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102ad8:	e8 63 d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102add:	83 ec 0c             	sub    $0xc,%esp
f0102ae0:	53                   	push   %ebx
f0102ae1:	e8 64 e4 ff ff       	call   f0100f4a <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ae6:	89 f8                	mov    %edi,%eax
f0102ae8:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0102aee:	c1 f8 03             	sar    $0x3,%eax
f0102af1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102af4:	89 c2                	mov    %eax,%edx
f0102af6:	c1 ea 0c             	shr    $0xc,%edx
f0102af9:	83 c4 10             	add    $0x10,%esp
f0102afc:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0102b02:	72 12                	jb     f0102b16 <mem_init+0x1800>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b04:	50                   	push   %eax
f0102b05:	68 64 5d 10 f0       	push   $0xf0105d64
f0102b0a:	6a 58                	push   $0x58
f0102b0c:	68 83 6c 10 f0       	push   $0xf0106c83
f0102b11:	e8 2a d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b16:	83 ec 04             	sub    $0x4,%esp
f0102b19:	68 00 10 00 00       	push   $0x1000
f0102b1e:	6a 01                	push   $0x1
f0102b20:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b25:	50                   	push   %eax
f0102b26:	e8 5a 25 00 00       	call   f0105085 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b2b:	89 f0                	mov    %esi,%eax
f0102b2d:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0102b33:	c1 f8 03             	sar    $0x3,%eax
f0102b36:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b39:	89 c2                	mov    %eax,%edx
f0102b3b:	c1 ea 0c             	shr    $0xc,%edx
f0102b3e:	83 c4 10             	add    $0x10,%esp
f0102b41:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0102b47:	72 12                	jb     f0102b5b <mem_init+0x1845>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b49:	50                   	push   %eax
f0102b4a:	68 64 5d 10 f0       	push   $0xf0105d64
f0102b4f:	6a 58                	push   $0x58
f0102b51:	68 83 6c 10 f0       	push   $0xf0106c83
f0102b56:	e8 e5 d4 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b5b:	83 ec 04             	sub    $0x4,%esp
f0102b5e:	68 00 10 00 00       	push   $0x1000
f0102b63:	6a 02                	push   $0x2
f0102b65:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b6a:	50                   	push   %eax
f0102b6b:	e8 15 25 00 00       	call   f0105085 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b70:	6a 02                	push   $0x2
f0102b72:	68 00 10 00 00       	push   $0x1000
f0102b77:	57                   	push   %edi
f0102b78:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102b7e:	e8 95 e6 ff ff       	call   f0101218 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b83:	83 c4 20             	add    $0x20,%esp
f0102b86:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b8b:	74 19                	je     f0102ba6 <mem_init+0x1890>
f0102b8d:	68 62 6e 10 f0       	push   $0xf0106e62
f0102b92:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102b97:	68 7f 04 00 00       	push   $0x47f
f0102b9c:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102ba1:	e8 9a d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ba6:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bad:	01 01 01 
f0102bb0:	74 19                	je     f0102bcb <mem_init+0x18b5>
f0102bb2:	68 88 6b 10 f0       	push   $0xf0106b88
f0102bb7:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102bbc:	68 80 04 00 00       	push   $0x480
f0102bc1:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102bc6:	e8 75 d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bcb:	6a 02                	push   $0x2
f0102bcd:	68 00 10 00 00       	push   $0x1000
f0102bd2:	56                   	push   %esi
f0102bd3:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102bd9:	e8 3a e6 ff ff       	call   f0101218 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102bde:	83 c4 10             	add    $0x10,%esp
f0102be1:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102be8:	02 02 02 
f0102beb:	74 19                	je     f0102c06 <mem_init+0x18f0>
f0102bed:	68 ac 6b 10 f0       	push   $0xf0106bac
f0102bf2:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102bf7:	68 82 04 00 00       	push   $0x482
f0102bfc:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102c01:	e8 3a d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102c06:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c0b:	74 19                	je     f0102c26 <mem_init+0x1910>
f0102c0d:	68 84 6e 10 f0       	push   $0xf0106e84
f0102c12:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102c17:	68 83 04 00 00       	push   $0x483
f0102c1c:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102c21:	e8 1a d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102c26:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c2b:	74 19                	je     f0102c46 <mem_init+0x1930>
f0102c2d:	68 ee 6e 10 f0       	push   $0xf0106eee
f0102c32:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102c37:	68 84 04 00 00       	push   $0x484
f0102c3c:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102c41:	e8 fa d3 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c46:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c4d:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c50:	89 f0                	mov    %esi,%eax
f0102c52:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0102c58:	c1 f8 03             	sar    $0x3,%eax
f0102c5b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c5e:	89 c2                	mov    %eax,%edx
f0102c60:	c1 ea 0c             	shr    $0xc,%edx
f0102c63:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0102c69:	72 12                	jb     f0102c7d <mem_init+0x1967>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c6b:	50                   	push   %eax
f0102c6c:	68 64 5d 10 f0       	push   $0xf0105d64
f0102c71:	6a 58                	push   $0x58
f0102c73:	68 83 6c 10 f0       	push   $0xf0106c83
f0102c78:	e8 c3 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c7d:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c84:	03 03 03 
f0102c87:	74 19                	je     f0102ca2 <mem_init+0x198c>
f0102c89:	68 d0 6b 10 f0       	push   $0xf0106bd0
f0102c8e:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102c93:	68 86 04 00 00       	push   $0x486
f0102c98:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102c9d:	e8 9e d3 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102ca2:	83 ec 08             	sub    $0x8,%esp
f0102ca5:	68 00 10 00 00       	push   $0x1000
f0102caa:	ff 35 8c 7e 20 f0    	pushl  0xf0207e8c
f0102cb0:	e8 1d e5 ff ff       	call   f01011d2 <page_remove>
	assert(pp2->pp_ref == 0);
f0102cb5:	83 c4 10             	add    $0x10,%esp
f0102cb8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102cbd:	74 19                	je     f0102cd8 <mem_init+0x19c2>
f0102cbf:	68 bc 6e 10 f0       	push   $0xf0106ebc
f0102cc4:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102cc9:	68 88 04 00 00       	push   $0x488
f0102cce:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102cd3:	e8 68 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102cd8:	8b 0d 8c 7e 20 f0    	mov    0xf0207e8c,%ecx
f0102cde:	8b 11                	mov    (%ecx),%edx
f0102ce0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102ce6:	89 d8                	mov    %ebx,%eax
f0102ce8:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0102cee:	c1 f8 03             	sar    $0x3,%eax
f0102cf1:	c1 e0 0c             	shl    $0xc,%eax
f0102cf4:	39 c2                	cmp    %eax,%edx
f0102cf6:	74 19                	je     f0102d11 <mem_init+0x19fb>
f0102cf8:	68 58 65 10 f0       	push   $0xf0106558
f0102cfd:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102d02:	68 8b 04 00 00       	push   $0x48b
f0102d07:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102d0c:	e8 2f d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102d11:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d17:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d1c:	74 19                	je     f0102d37 <mem_init+0x1a21>
f0102d1e:	68 73 6e 10 f0       	push   $0xf0106e73
f0102d23:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0102d28:	68 8d 04 00 00       	push   $0x48d
f0102d2d:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102d32:	e8 09 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102d37:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d3d:	83 ec 0c             	sub    $0xc,%esp
f0102d40:	53                   	push   %ebx
f0102d41:	e8 04 e2 ff ff       	call   f0100f4a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d46:	c7 04 24 fc 6b 10 f0 	movl   $0xf0106bfc,(%esp)
f0102d4d:	e8 df 08 00 00       	call   f0103631 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d52:	83 c4 10             	add    $0x10,%esp
f0102d55:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d58:	5b                   	pop    %ebx
f0102d59:	5e                   	pop    %esi
f0102d5a:	5f                   	pop    %edi
f0102d5b:	5d                   	pop    %ebp
f0102d5c:	c3                   	ret    

f0102d5d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d5d:	55                   	push   %ebp
f0102d5e:	89 e5                	mov    %esp,%ebp
f0102d60:	57                   	push   %edi
f0102d61:	56                   	push   %esi
f0102d62:	53                   	push   %ebx
f0102d63:	83 ec 1c             	sub    $0x1c,%esp
f0102d66:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
f0102d69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d6c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t last = ROUNDDOWN((uint32_t) (va+len), PGSIZE);
f0102d72:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d75:	03 45 10             	add    0x10(%ebp),%eax
f0102d78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			}
			return -E_FAULT;
		}
		// Second check
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *) addr, 0);
		if (!pte || !(*pte & (perm | PTE_P))) {
f0102d80:	8b 75 14             	mov    0x14(%ebp),%esi
f0102d83:	83 ce 01             	or     $0x1,%esi
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
	uint32_t last = ROUNDDOWN((uint32_t) (va+len), PGSIZE);
	while (addr <= last) {
f0102d86:	eb 69                	jmp    f0102df1 <user_mem_check+0x94>
		// TODO: Avoid repeating block of code
		// First check
		if (addr >= ULIM) {
f0102d88:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d8e:	76 21                	jbe    f0102db1 <user_mem_check+0x54>
			if (addr < (uint32_t) va) {
f0102d90:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102d93:	73 0f                	jae    f0102da4 <user_mem_check+0x47>
				user_mem_check_addr = (uint32_t) va;
f0102d95:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d98:	a3 3c 72 20 f0       	mov    %eax,0xf020723c
			} else {
				user_mem_check_addr = addr;
			}
			return -E_FAULT;
f0102d9d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102da2:	eb 57                	jmp    f0102dfb <user_mem_check+0x9e>
		// First check
		if (addr >= ULIM) {
			if (addr < (uint32_t) va) {
				user_mem_check_addr = (uint32_t) va;
			} else {
				user_mem_check_addr = addr;
f0102da4:	89 1d 3c 72 20 f0    	mov    %ebx,0xf020723c
			}
			return -E_FAULT;
f0102daa:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102daf:	eb 4a                	jmp    f0102dfb <user_mem_check+0x9e>
		}
		// Second check
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *) addr, 0);
f0102db1:	83 ec 04             	sub    $0x4,%esp
f0102db4:	6a 00                	push   $0x0
f0102db6:	53                   	push   %ebx
f0102db7:	ff 77 60             	pushl  0x60(%edi)
f0102dba:	e8 ed e1 ff ff       	call   f0100fac <pgdir_walk>
		if (!pte || !(*pte & (perm | PTE_P))) {
f0102dbf:	83 c4 10             	add    $0x10,%esp
f0102dc2:	85 c0                	test   %eax,%eax
f0102dc4:	74 04                	je     f0102dca <user_mem_check+0x6d>
f0102dc6:	85 30                	test   %esi,(%eax)
f0102dc8:	75 21                	jne    f0102deb <user_mem_check+0x8e>
			if (addr < (uint32_t) va) {
f0102dca:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102dcd:	73 0f                	jae    f0102dde <user_mem_check+0x81>
				user_mem_check_addr = (uint32_t) va;
f0102dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102dd2:	a3 3c 72 20 f0       	mov    %eax,0xf020723c
			} else {
				user_mem_check_addr = addr;
			}
			return -E_FAULT;
f0102dd7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ddc:	eb 1d                	jmp    f0102dfb <user_mem_check+0x9e>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *) addr, 0);
		if (!pte || !(*pte & (perm | PTE_P))) {
			if (addr < (uint32_t) va) {
				user_mem_check_addr = (uint32_t) va;
			} else {
				user_mem_check_addr = addr;
f0102dde:	89 1d 3c 72 20 f0    	mov    %ebx,0xf020723c
			}
			return -E_FAULT;
f0102de4:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102de9:	eb 10                	jmp    f0102dfb <user_mem_check+0x9e>
		}
		addr += PGSIZE;
f0102deb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
	uint32_t last = ROUNDDOWN((uint32_t) (va+len), PGSIZE);
	while (addr <= last) {
f0102df1:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102df4:	76 92                	jbe    f0102d88 <user_mem_check+0x2b>
			return -E_FAULT;
		}
		addr += PGSIZE;

	}
	return 0;
f0102df6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dfe:	5b                   	pop    %ebx
f0102dff:	5e                   	pop    %esi
f0102e00:	5f                   	pop    %edi
f0102e01:	5d                   	pop    %ebp
f0102e02:	c3                   	ret    

f0102e03 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e03:	55                   	push   %ebp
f0102e04:	89 e5                	mov    %esp,%ebp
f0102e06:	53                   	push   %ebx
f0102e07:	83 ec 04             	sub    $0x4,%esp
f0102e0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e0d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e10:	83 c8 04             	or     $0x4,%eax
f0102e13:	50                   	push   %eax
f0102e14:	ff 75 10             	pushl  0x10(%ebp)
f0102e17:	ff 75 0c             	pushl  0xc(%ebp)
f0102e1a:	53                   	push   %ebx
f0102e1b:	e8 3d ff ff ff       	call   f0102d5d <user_mem_check>
f0102e20:	83 c4 10             	add    $0x10,%esp
f0102e23:	85 c0                	test   %eax,%eax
f0102e25:	79 21                	jns    f0102e48 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102e27:	83 ec 04             	sub    $0x4,%esp
f0102e2a:	ff 35 3c 72 20 f0    	pushl  0xf020723c
f0102e30:	ff 73 48             	pushl  0x48(%ebx)
f0102e33:	68 28 6c 10 f0       	push   $0xf0106c28
f0102e38:	e8 f4 07 00 00       	call   f0103631 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102e3d:	89 1c 24             	mov    %ebx,(%esp)
f0102e40:	e8 33 05 00 00       	call   f0103378 <env_destroy>
f0102e45:	83 c4 10             	add    $0x10,%esp
	}
}
f0102e48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102e4b:	c9                   	leave  
f0102e4c:	c3                   	ret    

f0102e4d <region_alloc>:
// Panic if any allocation attempt fails.
//
/** ATTENTION: This function does not cover the case where there are overlaps! **/
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102e4d:	55                   	push   %ebp
f0102e4e:	89 e5                	mov    %esp,%ebp
f0102e50:	57                   	push   %edi
f0102e51:	56                   	push   %esi
f0102e52:	53                   	push   %ebx
f0102e53:	83 ec 1c             	sub    $0x1c,%esp
f0102e56:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	uintptr_t va_start = ROUNDDOWN((uintptr_t) va, PGSIZE);
f0102e58:	89 d6                	mov    %edx,%esi
f0102e5a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	uintptr_t va_end = ROUNDUP(((uintptr_t) va) + len, PGSIZE);
f0102e60:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax

	uint32_t n = (va_end - va_start)/PGSIZE;
f0102e67:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e6c:	29 f0                	sub    %esi,%eax
f0102e6e:	c1 e8 0c             	shr    $0xc,%eax
f0102e71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	uint32_t va_current = va_start;
	for (i = 0; i < n; i++) {
f0102e74:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e79:	eb 22                	jmp    f0102e9d <region_alloc+0x50>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // Clear page
f0102e7b:	83 ec 0c             	sub    $0xc,%esp
f0102e7e:	6a 01                	push   $0x1
f0102e80:	e8 55 e0 ff ff       	call   f0100eda <page_alloc>
		page_insert(e->env_pgdir, pp, (void *) va_current, PTE_U | PTE_W);
f0102e85:	6a 06                	push   $0x6
f0102e87:	56                   	push   %esi
f0102e88:	50                   	push   %eax
f0102e89:	ff 77 60             	pushl  0x60(%edi)
f0102e8c:	e8 87 e3 ff ff       	call   f0101218 <page_insert>
		va_current += PGSIZE;
f0102e91:	81 c6 00 10 00 00    	add    $0x1000,%esi
	uintptr_t va_end = ROUNDUP(((uintptr_t) va) + len, PGSIZE);

	uint32_t n = (va_end - va_start)/PGSIZE;
	uint32_t i;
	uint32_t va_current = va_start;
	for (i = 0; i < n; i++) {
f0102e97:	83 c3 01             	add    $0x1,%ebx
f0102e9a:	83 c4 20             	add    $0x20,%esp
f0102e9d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102ea0:	75 d9                	jne    f0102e7b <region_alloc+0x2e>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // Clear page
		page_insert(e->env_pgdir, pp, (void *) va_current, PTE_U | PTE_W);
		va_current += PGSIZE;
	}
}
f0102ea2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ea5:	5b                   	pop    %ebx
f0102ea6:	5e                   	pop    %esi
f0102ea7:	5f                   	pop    %edi
f0102ea8:	5d                   	pop    %ebp
f0102ea9:	c3                   	ret    

f0102eaa <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102eaa:	55                   	push   %ebp
f0102eab:	89 e5                	mov    %esp,%ebp
f0102ead:	56                   	push   %esi
f0102eae:	53                   	push   %ebx
f0102eaf:	8b 45 08             	mov    0x8(%ebp),%eax
f0102eb2:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102eb5:	85 c0                	test   %eax,%eax
f0102eb7:	75 1a                	jne    f0102ed3 <envid2env+0x29>
		*env_store = curenv;
f0102eb9:	e8 e8 27 00 00       	call   f01056a6 <cpunum>
f0102ebe:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ec1:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0102ec7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102eca:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102ecc:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ed1:	eb 70                	jmp    f0102f43 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102ed3:	89 c3                	mov    %eax,%ebx
f0102ed5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102edb:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102ede:	03 1d 48 72 20 f0    	add    0xf0207248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102ee4:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102ee8:	74 05                	je     f0102eef <envid2env+0x45>
f0102eea:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102eed:	74 10                	je     f0102eff <envid2env+0x55>
		*env_store = 0;
f0102eef:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ef2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ef8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102efd:	eb 44                	jmp    f0102f43 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102eff:	84 d2                	test   %dl,%dl
f0102f01:	74 36                	je     f0102f39 <envid2env+0x8f>
f0102f03:	e8 9e 27 00 00       	call   f01056a6 <cpunum>
f0102f08:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f0b:	3b 98 28 80 20 f0    	cmp    -0xfdf7fd8(%eax),%ebx
f0102f11:	74 26                	je     f0102f39 <envid2env+0x8f>
f0102f13:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102f16:	e8 8b 27 00 00       	call   f01056a6 <cpunum>
f0102f1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f1e:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0102f24:	3b 70 48             	cmp    0x48(%eax),%esi
f0102f27:	74 10                	je     f0102f39 <envid2env+0x8f>
		*env_store = 0;
f0102f29:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f2c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102f32:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102f37:	eb 0a                	jmp    f0102f43 <envid2env+0x99>
	}

	*env_store = e;
f0102f39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f3c:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102f3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f43:	5b                   	pop    %ebx
f0102f44:	5e                   	pop    %esi
f0102f45:	5d                   	pop    %ebp
f0102f46:	c3                   	ret    

f0102f47 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102f47:	55                   	push   %ebp
f0102f48:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102f4a:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0102f4f:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102f52:	b8 23 00 00 00       	mov    $0x23,%eax
f0102f57:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102f59:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102f5b:	b8 10 00 00 00       	mov    $0x10,%eax
f0102f60:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102f62:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102f64:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102f66:	ea 6d 2f 10 f0 08 00 	ljmp   $0x8,$0xf0102f6d
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102f6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f72:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102f75:	5d                   	pop    %ebp
f0102f76:	c3                   	ret    

f0102f77 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102f77:	55                   	push   %ebp
f0102f78:	89 e5                	mov    %esp,%ebp
f0102f7a:	56                   	push   %esi
f0102f7b:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1; i >= 0; i--) {
		envs[i].env_id = 0;
f0102f7c:	8b 35 48 72 20 f0    	mov    0xf0207248,%esi
f0102f82:	8b 15 4c 72 20 f0    	mov    0xf020724c,%edx
f0102f88:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f8e:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f91:	89 c1                	mov    %eax,%ecx
f0102f93:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)

		envs[i].env_link = env_free_list;
f0102f9a:	89 50 44             	mov    %edx,0x44(%eax)
		env_free_list = &envs[i];

		envs[i].env_pgdir = NULL;
f0102f9d:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
f0102fa4:	83 e8 7c             	sub    $0x7c,%eax
	int i;
	for (i = NENV-1; i >= 0; i--) {
		envs[i].env_id = 0;

		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0102fa7:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1; i >= 0; i--) {
f0102fa9:	39 d8                	cmp    %ebx,%eax
f0102fab:	75 e4                	jne    f0102f91 <env_init+0x1a>
f0102fad:	89 35 4c 72 20 f0    	mov    %esi,0xf020724c
		env_free_list = &envs[i];

		envs[i].env_pgdir = NULL;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102fb3:	e8 8f ff ff ff       	call   f0102f47 <env_init_percpu>
}
f0102fb8:	5b                   	pop    %ebx
f0102fb9:	5e                   	pop    %esi
f0102fba:	5d                   	pop    %ebp
f0102fbb:	c3                   	ret    

f0102fbc <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102fbc:	55                   	push   %ebp
f0102fbd:	89 e5                	mov    %esp,%ebp
f0102fbf:	53                   	push   %ebx
f0102fc0:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102fc3:	8b 1d 4c 72 20 f0    	mov    0xf020724c,%ebx
f0102fc9:	85 db                	test   %ebx,%ebx
f0102fcb:	0f 84 34 01 00 00    	je     f0103105 <env_alloc+0x149>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102fd1:	83 ec 0c             	sub    $0xc,%esp
f0102fd4:	6a 01                	push   $0x1
f0102fd6:	e8 ff de ff ff       	call   f0100eda <page_alloc>
f0102fdb:	83 c4 10             	add    $0x10,%esp
f0102fde:	85 c0                	test   %eax,%eax
f0102fe0:	0f 84 26 01 00 00    	je     f010310c <env_alloc+0x150>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref += 1; // TODO: Why?
f0102fe6:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102feb:	2b 05 90 7e 20 f0    	sub    0xf0207e90,%eax
f0102ff1:	c1 f8 03             	sar    $0x3,%eax
f0102ff4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ff7:	89 c2                	mov    %eax,%edx
f0102ff9:	c1 ea 0c             	shr    $0xc,%edx
f0102ffc:	3b 15 88 7e 20 f0    	cmp    0xf0207e88,%edx
f0103002:	72 12                	jb     f0103016 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103004:	50                   	push   %eax
f0103005:	68 64 5d 10 f0       	push   $0xf0105d64
f010300a:	6a 58                	push   $0x58
f010300c:	68 83 6c 10 f0       	push   $0xf0106c83
f0103011:	e8 2a d0 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = page2kva(p);
f0103016:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010301b:	89 43 60             	mov    %eax,0x60(%ebx)
f010301e:	b8 ec 0e 00 00       	mov    $0xeec,%eax

	// Needs to map everything above UTOP: pages, envs, kernel stack
	// and all physical memory
	// More elegant way: just copy. Less elegant: map with boot_map_region...
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f0103023:	8b 15 8c 7e 20 f0    	mov    0xf0207e8c,%edx
f0103029:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f010302c:	8b 53 60             	mov    0x60(%ebx),%edx
f010302f:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103032:	83 c0 04             	add    $0x4,%eax
	e->env_pgdir = page2kva(p);

	// Needs to map everything above UTOP: pages, envs, kernel stack
	// and all physical memory
	// More elegant way: just copy. Less elegant: map with boot_map_region...
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
f0103035:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010303a:	75 e7                	jne    f0103023 <env_alloc+0x67>
		e->env_pgdir[i] = kern_pgdir[i];
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010303c:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010303f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103044:	77 15                	ja     f010305b <env_alloc+0x9f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103046:	50                   	push   %eax
f0103047:	68 88 5d 10 f0       	push   $0xf0105d88
f010304c:	68 cd 00 00 00       	push   $0xcd
f0103051:	68 89 6f 10 f0       	push   $0xf0106f89
f0103056:	e8 e5 cf ff ff       	call   f0100040 <_panic>
f010305b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103061:	83 ca 05             	or     $0x5,%edx
f0103064:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010306a:	8b 43 48             	mov    0x48(%ebx),%eax
f010306d:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103072:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103077:	ba 00 10 00 00       	mov    $0x1000,%edx
f010307c:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010307f:	89 da                	mov    %ebx,%edx
f0103081:	2b 15 48 72 20 f0    	sub    0xf0207248,%edx
f0103087:	c1 fa 02             	sar    $0x2,%edx
f010308a:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103090:	09 d0                	or     %edx,%eax
f0103092:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103095:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103098:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010309b:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01030a2:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01030a9:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01030b0:	83 ec 04             	sub    $0x4,%esp
f01030b3:	6a 44                	push   $0x44
f01030b5:	6a 00                	push   $0x0
f01030b7:	53                   	push   %ebx
f01030b8:	e8 c8 1f 00 00       	call   f0105085 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01030bd:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01030c3:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01030c9:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01030cf:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01030d6:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01030dc:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01030e3:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01030ea:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01030ee:	8b 43 44             	mov    0x44(%ebx),%eax
f01030f1:	a3 4c 72 20 f0       	mov    %eax,0xf020724c
	*newenv_store = e;
f01030f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01030f9:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01030fb:	83 c4 10             	add    $0x10,%esp
f01030fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103103:	eb 0c                	jmp    f0103111 <env_alloc+0x155>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103105:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010310a:	eb 05                	jmp    f0103111 <env_alloc+0x155>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010310c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103111:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103114:	c9                   	leave  
f0103115:	c3                   	ret    

f0103116 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103116:	55                   	push   %ebp
f0103117:	89 e5                	mov    %esp,%ebp
f0103119:	57                   	push   %edi
f010311a:	56                   	push   %esi
f010311b:	53                   	push   %ebx
f010311c:	83 ec 24             	sub    $0x24,%esp
	// LAB 3: Your code here.
	struct Env *e;
	env_alloc(&e, 0);
f010311f:	6a 00                	push   $0x0
f0103121:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103124:	50                   	push   %eax
f0103125:	e8 92 fe ff ff       	call   f0102fbc <env_alloc>
	load_icode(e, binary);
f010312a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *) binary;
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff);
f010312d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103130:	89 c3                	mov    %eax,%ebx
f0103132:	03 58 1c             	add    0x1c(%eax),%ebx
	struct Proghdr *last_ph = ph + elf->e_phnum;
f0103135:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f0103139:	c1 e6 05             	shl    $0x5,%esi
f010313c:	01 de                	add    %ebx,%esi
f010313e:	83 c4 10             	add    $0x10,%esp
f0103141:	eb 54                	jmp    f0103197 <env_create+0x81>
	for (; ph < last_ph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
f0103143:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103146:	75 4c                	jne    f0103194 <env_create+0x7e>
			region_alloc(e, (uint8_t *) ph->p_va, ph->p_memsz);
f0103148:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010314b:	8b 53 08             	mov    0x8(%ebx),%edx
f010314e:	89 f8                	mov    %edi,%eax
f0103150:	e8 f8 fc ff ff       	call   f0102e4d <region_alloc>

			lcr3(PADDR(e->env_pgdir));
f0103155:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103158:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010315d:	77 15                	ja     f0103174 <env_create+0x5e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010315f:	50                   	push   %eax
f0103160:	68 88 5d 10 f0       	push   $0xf0105d88
f0103165:	68 77 01 00 00       	push   $0x177
f010316a:	68 89 6f 10 f0       	push   $0xf0106f89
f010316f:	e8 cc ce ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103174:	05 00 00 00 10       	add    $0x10000000,%eax
f0103179:	0f 22 d8             	mov    %eax,%cr3

			uint8_t *dst = (uint8_t *) ph->p_va;
			uint8_t *src = binary + ph->p_offset;
			size_t n = (size_t) ph->p_filesz;

			memmove(dst, src, n);
f010317c:	83 ec 04             	sub    $0x4,%esp
f010317f:	ff 73 10             	pushl  0x10(%ebx)
f0103182:	8b 45 08             	mov    0x8(%ebp),%eax
f0103185:	03 43 04             	add    0x4(%ebx),%eax
f0103188:	50                   	push   %eax
f0103189:	ff 73 08             	pushl  0x8(%ebx)
f010318c:	e8 41 1f 00 00       	call   f01050d2 <memmove>
f0103191:	83 c4 10             	add    $0x10,%esp

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *) binary;
	struct Proghdr *ph = (struct Proghdr *) (binary + elf->e_phoff);
	struct Proghdr *last_ph = ph + elf->e_phnum;
	for (; ph < last_ph; ph++) {
f0103194:	83 c3 20             	add    $0x20,%ebx
f0103197:	39 de                	cmp    %ebx,%esi
f0103199:	77 a8                	ja     f0103143 <env_create+0x2d>
			memmove(dst, src, n);
		}
	}

	// Put the program entry point in the trapframe
	e->env_tf.tf_eip = elf->e_entry;
f010319b:	8b 45 08             	mov    0x8(%ebp),%eax
f010319e:	8b 40 18             	mov    0x18(%eax),%eax
f01031a1:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01031a4:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01031a9:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01031ae:	89 f8                	mov    %edi,%eax
f01031b0:	e8 98 fc ff ff       	call   f0102e4d <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *e;
	env_alloc(&e, 0);
	load_icode(e, binary);
	e->env_type = type;
f01031b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01031b8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01031bb:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.


	if (type == ENV_TYPE_FS) {
f01031be:	83 fa 01             	cmp    $0x1,%edx
f01031c1:	75 07                	jne    f01031ca <env_create+0xb4>
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
f01031c3:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
}
f01031ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031cd:	5b                   	pop    %ebx
f01031ce:	5e                   	pop    %esi
f01031cf:	5f                   	pop    %edi
f01031d0:	5d                   	pop    %ebp
f01031d1:	c3                   	ret    

f01031d2 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01031d2:	55                   	push   %ebp
f01031d3:	89 e5                	mov    %esp,%ebp
f01031d5:	57                   	push   %edi
f01031d6:	56                   	push   %esi
f01031d7:	53                   	push   %ebx
f01031d8:	83 ec 1c             	sub    $0x1c,%esp
f01031db:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01031de:	e8 c3 24 00 00       	call   f01056a6 <cpunum>
f01031e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01031e6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01031ed:	39 b8 28 80 20 f0    	cmp    %edi,-0xfdf7fd8(%eax)
f01031f3:	75 30                	jne    f0103225 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f01031f5:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ff:	77 15                	ja     f0103216 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103201:	50                   	push   %eax
f0103202:	68 88 5d 10 f0       	push   $0xf0105d88
f0103207:	68 b2 01 00 00       	push   $0x1b2
f010320c:	68 89 6f 10 f0       	push   $0xf0106f89
f0103211:	e8 2a ce ff ff       	call   f0100040 <_panic>
f0103216:	05 00 00 00 10       	add    $0x10000000,%eax
f010321b:	0f 22 d8             	mov    %eax,%cr3
f010321e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103225:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103228:	89 d0                	mov    %edx,%eax
f010322a:	c1 e0 02             	shl    $0x2,%eax
f010322d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103230:	8b 47 60             	mov    0x60(%edi),%eax
f0103233:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103236:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010323c:	0f 84 a8 00 00 00    	je     f01032ea <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103242:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103248:	89 f0                	mov    %esi,%eax
f010324a:	c1 e8 0c             	shr    $0xc,%eax
f010324d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103250:	39 05 88 7e 20 f0    	cmp    %eax,0xf0207e88
f0103256:	77 15                	ja     f010326d <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103258:	56                   	push   %esi
f0103259:	68 64 5d 10 f0       	push   $0xf0105d64
f010325e:	68 c1 01 00 00       	push   $0x1c1
f0103263:	68 89 6f 10 f0       	push   $0xf0106f89
f0103268:	e8 d3 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010326d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103270:	c1 e0 16             	shl    $0x16,%eax
f0103273:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103276:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010327b:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103282:	01 
f0103283:	74 17                	je     f010329c <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103285:	83 ec 08             	sub    $0x8,%esp
f0103288:	89 d8                	mov    %ebx,%eax
f010328a:	c1 e0 0c             	shl    $0xc,%eax
f010328d:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103290:	50                   	push   %eax
f0103291:	ff 77 60             	pushl  0x60(%edi)
f0103294:	e8 39 df ff ff       	call   f01011d2 <page_remove>
f0103299:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010329c:	83 c3 01             	add    $0x1,%ebx
f010329f:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01032a5:	75 d4                	jne    f010327b <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01032a7:	8b 47 60             	mov    0x60(%edi),%eax
f01032aa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032ad:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01032b7:	3b 05 88 7e 20 f0    	cmp    0xf0207e88,%eax
f01032bd:	72 14                	jb     f01032d3 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01032bf:	83 ec 04             	sub    $0x4,%esp
f01032c2:	68 f4 63 10 f0       	push   $0xf01063f4
f01032c7:	6a 51                	push   $0x51
f01032c9:	68 83 6c 10 f0       	push   $0xf0106c83
f01032ce:	e8 6d cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01032d3:	83 ec 0c             	sub    $0xc,%esp
f01032d6:	a1 90 7e 20 f0       	mov    0xf0207e90,%eax
f01032db:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01032de:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01032e1:	50                   	push   %eax
f01032e2:	e8 9e dc ff ff       	call   f0100f85 <page_decref>
f01032e7:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01032ea:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01032ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032f1:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01032f6:	0f 85 29 ff ff ff    	jne    f0103225 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01032fc:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032ff:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103304:	77 15                	ja     f010331b <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103306:	50                   	push   %eax
f0103307:	68 88 5d 10 f0       	push   $0xf0105d88
f010330c:	68 cf 01 00 00       	push   $0x1cf
f0103311:	68 89 6f 10 f0       	push   $0xf0106f89
f0103316:	e8 25 cd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010331b:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103322:	05 00 00 00 10       	add    $0x10000000,%eax
f0103327:	c1 e8 0c             	shr    $0xc,%eax
f010332a:	3b 05 88 7e 20 f0    	cmp    0xf0207e88,%eax
f0103330:	72 14                	jb     f0103346 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103332:	83 ec 04             	sub    $0x4,%esp
f0103335:	68 f4 63 10 f0       	push   $0xf01063f4
f010333a:	6a 51                	push   $0x51
f010333c:	68 83 6c 10 f0       	push   $0xf0106c83
f0103341:	e8 fa cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103346:	83 ec 0c             	sub    $0xc,%esp
f0103349:	8b 15 90 7e 20 f0    	mov    0xf0207e90,%edx
f010334f:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103352:	50                   	push   %eax
f0103353:	e8 2d dc ff ff       	call   f0100f85 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103358:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010335f:	a1 4c 72 20 f0       	mov    0xf020724c,%eax
f0103364:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103367:	89 3d 4c 72 20 f0    	mov    %edi,0xf020724c
}
f010336d:	83 c4 10             	add    $0x10,%esp
f0103370:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103373:	5b                   	pop    %ebx
f0103374:	5e                   	pop    %esi
f0103375:	5f                   	pop    %edi
f0103376:	5d                   	pop    %ebp
f0103377:	c3                   	ret    

f0103378 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103378:	55                   	push   %ebp
f0103379:	89 e5                	mov    %esp,%ebp
f010337b:	53                   	push   %ebx
f010337c:	83 ec 04             	sub    $0x4,%esp
f010337f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103382:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103386:	75 19                	jne    f01033a1 <env_destroy+0x29>
f0103388:	e8 19 23 00 00       	call   f01056a6 <cpunum>
f010338d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103390:	3b 98 28 80 20 f0    	cmp    -0xfdf7fd8(%eax),%ebx
f0103396:	74 09                	je     f01033a1 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103398:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f010339f:	eb 33                	jmp    f01033d4 <env_destroy+0x5c>
	}

	env_free(e);
f01033a1:	83 ec 0c             	sub    $0xc,%esp
f01033a4:	53                   	push   %ebx
f01033a5:	e8 28 fe ff ff       	call   f01031d2 <env_free>

	if (curenv == e) {
f01033aa:	e8 f7 22 00 00       	call   f01056a6 <cpunum>
f01033af:	6b c0 74             	imul   $0x74,%eax,%eax
f01033b2:	83 c4 10             	add    $0x10,%esp
f01033b5:	3b 98 28 80 20 f0    	cmp    -0xfdf7fd8(%eax),%ebx
f01033bb:	75 17                	jne    f01033d4 <env_destroy+0x5c>
		curenv = NULL;
f01033bd:	e8 e4 22 00 00       	call   f01056a6 <cpunum>
f01033c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01033c5:	c7 80 28 80 20 f0 00 	movl   $0x0,-0xfdf7fd8(%eax)
f01033cc:	00 00 00 
		sched_yield();
f01033cf:	e8 6f 0b 00 00       	call   f0103f43 <sched_yield>
	}
}
f01033d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033d7:	c9                   	leave  
f01033d8:	c3                   	ret    

f01033d9 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01033d9:	55                   	push   %ebp
f01033da:	89 e5                	mov    %esp,%ebp
f01033dc:	53                   	push   %ebx
f01033dd:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01033e0:	e8 c1 22 00 00       	call   f01056a6 <cpunum>
f01033e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01033e8:	8b 98 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%ebx
f01033ee:	e8 b3 22 00 00       	call   f01056a6 <cpunum>
f01033f3:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f01033f6:	8b 65 08             	mov    0x8(%ebp),%esp
f01033f9:	61                   	popa   
f01033fa:	07                   	pop    %es
f01033fb:	1f                   	pop    %ds
f01033fc:	83 c4 08             	add    $0x8,%esp
f01033ff:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103400:	83 ec 04             	sub    $0x4,%esp
f0103403:	68 94 6f 10 f0       	push   $0xf0106f94
f0103408:	68 05 02 00 00       	push   $0x205
f010340d:	68 89 6f 10 f0       	push   $0xf0106f89
f0103412:	e8 29 cc ff ff       	call   f0100040 <_panic>

f0103417 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103417:	55                   	push   %ebp
f0103418:	89 e5                	mov    %esp,%ebp
f010341a:	53                   	push   %ebx
f010341b:	83 ec 04             	sub    $0x4,%esp
f010341e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// Step 1
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103421:	e8 80 22 00 00       	call   f01056a6 <cpunum>
f0103426:	6b c0 74             	imul   $0x74,%eax,%eax
f0103429:	83 b8 28 80 20 f0 00 	cmpl   $0x0,-0xfdf7fd8(%eax)
f0103430:	74 29                	je     f010345b <env_run+0x44>
f0103432:	e8 6f 22 00 00       	call   f01056a6 <cpunum>
f0103437:	6b c0 74             	imul   $0x74,%eax,%eax
f010343a:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103440:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103444:	75 15                	jne    f010345b <env_run+0x44>
		curenv->env_status = ENV_RUNNABLE;
f0103446:	e8 5b 22 00 00       	call   f01056a6 <cpunum>
f010344b:	6b c0 74             	imul   $0x74,%eax,%eax
f010344e:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103454:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f010345b:	e8 46 22 00 00       	call   f01056a6 <cpunum>
f0103460:	6b c0 74             	imul   $0x74,%eax,%eax
f0103463:	89 98 28 80 20 f0    	mov    %ebx,-0xfdf7fd8(%eax)
	e->env_status = ENV_RUNNING;
f0103469:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs += 1;
f0103470:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f0103474:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103477:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010347c:	77 15                	ja     f0103493 <env_run+0x7c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010347e:	50                   	push   %eax
f010347f:	68 88 5d 10 f0       	push   $0xf0105d88
f0103484:	68 29 02 00 00       	push   $0x229
f0103489:	68 89 6f 10 f0       	push   $0xf0106f89
f010348e:	e8 ad cb ff ff       	call   f0100040 <_panic>
f0103493:	05 00 00 00 10       	add    $0x10000000,%eax
f0103498:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010349b:	83 ec 0c             	sub    $0xc,%esp
f010349e:	68 60 04 12 f0       	push   $0xf0120460
f01034a3:	e8 09 25 00 00       	call   f01059b1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01034a8:	f3 90                	pause  

	// Step 2
	unlock_kernel();
	env_pop_tf(&(e->env_tf));
f01034aa:	89 1c 24             	mov    %ebx,(%esp)
f01034ad:	e8 27 ff ff ff       	call   f01033d9 <env_pop_tf>

f01034b2 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01034b2:	55                   	push   %ebp
f01034b3:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034b5:	ba 70 00 00 00       	mov    $0x70,%edx
f01034ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01034bd:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034be:	ba 71 00 00 00       	mov    $0x71,%edx
f01034c3:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01034c4:	0f b6 c0             	movzbl %al,%eax
}
f01034c7:	5d                   	pop    %ebp
f01034c8:	c3                   	ret    

f01034c9 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034c9:	55                   	push   %ebp
f01034ca:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034cc:	ba 70 00 00 00       	mov    $0x70,%edx
f01034d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01034d4:	ee                   	out    %al,(%dx)
f01034d5:	ba 71 00 00 00       	mov    $0x71,%edx
f01034da:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034dd:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034de:	5d                   	pop    %ebp
f01034df:	c3                   	ret    

f01034e0 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01034e0:	55                   	push   %ebp
f01034e1:	89 e5                	mov    %esp,%ebp
f01034e3:	56                   	push   %esi
f01034e4:	53                   	push   %ebx
f01034e5:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01034e8:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f01034ee:	80 3d 50 72 20 f0 00 	cmpb   $0x0,0xf0207250
f01034f5:	74 5a                	je     f0103551 <irq_setmask_8259A+0x71>
f01034f7:	89 c6                	mov    %eax,%esi
f01034f9:	ba 21 00 00 00       	mov    $0x21,%edx
f01034fe:	ee                   	out    %al,(%dx)
f01034ff:	66 c1 e8 08          	shr    $0x8,%ax
f0103503:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103508:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103509:	83 ec 0c             	sub    $0xc,%esp
f010350c:	68 a0 6f 10 f0       	push   $0xf0106fa0
f0103511:	e8 1b 01 00 00       	call   f0103631 <cprintf>
f0103516:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103519:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010351e:	0f b7 f6             	movzwl %si,%esi
f0103521:	f7 d6                	not    %esi
f0103523:	0f a3 de             	bt     %ebx,%esi
f0103526:	73 11                	jae    f0103539 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103528:	83 ec 08             	sub    $0x8,%esp
f010352b:	53                   	push   %ebx
f010352c:	68 2b 74 10 f0       	push   $0xf010742b
f0103531:	e8 fb 00 00 00       	call   f0103631 <cprintf>
f0103536:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103539:	83 c3 01             	add    $0x1,%ebx
f010353c:	83 fb 10             	cmp    $0x10,%ebx
f010353f:	75 e2                	jne    f0103523 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103541:	83 ec 0c             	sub    $0xc,%esp
f0103544:	68 57 6f 10 f0       	push   $0xf0106f57
f0103549:	e8 e3 00 00 00       	call   f0103631 <cprintf>
f010354e:	83 c4 10             	add    $0x10,%esp
}
f0103551:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103554:	5b                   	pop    %ebx
f0103555:	5e                   	pop    %esi
f0103556:	5d                   	pop    %ebp
f0103557:	c3                   	ret    

f0103558 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103558:	c6 05 50 72 20 f0 01 	movb   $0x1,0xf0207250
f010355f:	ba 21 00 00 00       	mov    $0x21,%edx
f0103564:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103569:	ee                   	out    %al,(%dx)
f010356a:	ba a1 00 00 00       	mov    $0xa1,%edx
f010356f:	ee                   	out    %al,(%dx)
f0103570:	ba 20 00 00 00       	mov    $0x20,%edx
f0103575:	b8 11 00 00 00       	mov    $0x11,%eax
f010357a:	ee                   	out    %al,(%dx)
f010357b:	ba 21 00 00 00       	mov    $0x21,%edx
f0103580:	b8 20 00 00 00       	mov    $0x20,%eax
f0103585:	ee                   	out    %al,(%dx)
f0103586:	b8 04 00 00 00       	mov    $0x4,%eax
f010358b:	ee                   	out    %al,(%dx)
f010358c:	b8 03 00 00 00       	mov    $0x3,%eax
f0103591:	ee                   	out    %al,(%dx)
f0103592:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103597:	b8 11 00 00 00       	mov    $0x11,%eax
f010359c:	ee                   	out    %al,(%dx)
f010359d:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035a2:	b8 28 00 00 00       	mov    $0x28,%eax
f01035a7:	ee                   	out    %al,(%dx)
f01035a8:	b8 02 00 00 00       	mov    $0x2,%eax
f01035ad:	ee                   	out    %al,(%dx)
f01035ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01035b3:	ee                   	out    %al,(%dx)
f01035b4:	ba 20 00 00 00       	mov    $0x20,%edx
f01035b9:	b8 68 00 00 00       	mov    $0x68,%eax
f01035be:	ee                   	out    %al,(%dx)
f01035bf:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035c4:	ee                   	out    %al,(%dx)
f01035c5:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035ca:	b8 68 00 00 00       	mov    $0x68,%eax
f01035cf:	ee                   	out    %al,(%dx)
f01035d0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035d5:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01035d6:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01035dd:	66 83 f8 ff          	cmp    $0xffff,%ax
f01035e1:	74 13                	je     f01035f6 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01035e3:	55                   	push   %ebp
f01035e4:	89 e5                	mov    %esp,%ebp
f01035e6:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01035e9:	0f b7 c0             	movzwl %ax,%eax
f01035ec:	50                   	push   %eax
f01035ed:	e8 ee fe ff ff       	call   f01034e0 <irq_setmask_8259A>
f01035f2:	83 c4 10             	add    $0x10,%esp
}
f01035f5:	c9                   	leave  
f01035f6:	f3 c3                	repz ret 

f01035f8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01035f8:	55                   	push   %ebp
f01035f9:	89 e5                	mov    %esp,%ebp
f01035fb:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01035fe:	ff 75 08             	pushl  0x8(%ebp)
f0103601:	e8 85 d1 ff ff       	call   f010078b <cputchar>
	*cnt++;
}
f0103606:	83 c4 10             	add    $0x10,%esp
f0103609:	c9                   	leave  
f010360a:	c3                   	ret    

f010360b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010360b:	55                   	push   %ebp
f010360c:	89 e5                	mov    %esp,%ebp
f010360e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103611:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103618:	ff 75 0c             	pushl  0xc(%ebp)
f010361b:	ff 75 08             	pushl  0x8(%ebp)
f010361e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103621:	50                   	push   %eax
f0103622:	68 f8 35 10 f0       	push   $0xf01035f8
f0103627:	e8 d5 13 00 00       	call   f0104a01 <vprintfmt>
	return cnt;
}
f010362c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010362f:	c9                   	leave  
f0103630:	c3                   	ret    

f0103631 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103631:	55                   	push   %ebp
f0103632:	89 e5                	mov    %esp,%ebp
f0103634:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103637:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010363a:	50                   	push   %eax
f010363b:	ff 75 08             	pushl  0x8(%ebp)
f010363e:	e8 c8 ff ff ff       	call   f010360b <vcprintf>
	va_end(ap);

	return cnt;
}
f0103643:	c9                   	leave  
f0103644:	c3                   	ret    

f0103645 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103645:	55                   	push   %ebp
f0103646:	89 e5                	mov    %esp,%ebp
f0103648:	57                   	push   %edi
f0103649:	56                   	push   %esi
f010364a:	53                   	push   %ebx
f010364b:	83 ec 1c             	sub    $0x1c,%esp
	lidt(&idt_pd);
	*/

	/* MY CODE */
	// Get cpu index
	uint32_t i = thiscpu->cpu_id;
f010364e:	e8 53 20 00 00       	call   f01056a6 <cpunum>
f0103653:	6b c0 74             	imul   $0x74,%eax,%eax
f0103656:	0f b6 b0 20 80 20 f0 	movzbl -0xfdf7fe0(%eax),%esi
f010365d:	89 f0                	mov    %esi,%eax
f010365f:	0f b6 d8             	movzbl %al,%ebx

	// Setup the cpu TSS
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103662:	e8 3f 20 00 00       	call   f01056a6 <cpunum>
f0103667:	6b c0 74             	imul   $0x74,%eax,%eax
f010366a:	89 da                	mov    %ebx,%edx
f010366c:	f7 da                	neg    %edx
f010366e:	c1 e2 10             	shl    $0x10,%edx
f0103671:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103677:	89 90 30 80 20 f0    	mov    %edx,-0xfdf7fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f010367d:	e8 24 20 00 00       	call   f01056a6 <cpunum>
f0103682:	6b c0 74             	imul   $0x74,%eax,%eax
f0103685:	66 c7 80 34 80 20 f0 	movw   $0x10,-0xfdf7fcc(%eax)
f010368c:	10 00 

	// Initialize the TSS slot of the gdt, so the hardware can access it
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f010368e:	83 c3 05             	add    $0x5,%ebx
f0103691:	e8 10 20 00 00       	call   f01056a6 <cpunum>
f0103696:	89 c7                	mov    %eax,%edi
f0103698:	e8 09 20 00 00       	call   f01056a6 <cpunum>
f010369d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01036a0:	e8 01 20 00 00       	call   f01056a6 <cpunum>
f01036a5:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f01036ac:	f0 67 00 
f01036af:	6b ff 74             	imul   $0x74,%edi,%edi
f01036b2:	81 c7 2c 80 20 f0    	add    $0xf020802c,%edi
f01036b8:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f01036bf:	f0 
f01036c0:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f01036c4:	81 c2 2c 80 20 f0    	add    $0xf020802c,%edx
f01036ca:	c1 ea 10             	shr    $0x10,%edx
f01036cd:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f01036d4:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f01036db:	40 
f01036dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01036df:	05 2c 80 20 f0       	add    $0xf020802c,%eax
f01036e4:	c1 e8 18             	shr    $0x18,%eax
f01036e7:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f01036ee:	c6 04 dd 45 03 12 f0 	movb   $0x89,-0xfedfcbb(,%ebx,8)
f01036f5:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01036f6:	89 f0                	mov    %esi,%eax
f01036f8:	0f b6 f0             	movzbl %al,%esi
f01036fb:	8d 34 f5 28 00 00 00 	lea    0x28(,%esi,8),%esi
f0103702:	0f 00 de             	ltr    %si
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103705:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f010370a:	0f 01 18             	lidtl  (%eax)
	// Load the TSS selector, so the hardware knows where to find it on the gdt
	ltr(GD_TSS0 + (i << 3));

	// Load the IDT
	lidt(&idt_pd);
}
f010370d:	83 c4 1c             	add    $0x1c,%esp
f0103710:	5b                   	pop    %ebx
f0103711:	5e                   	pop    %esi
f0103712:	5f                   	pop    %edi
f0103713:	5d                   	pop    %ebp
f0103714:	c3                   	ret    

f0103715 <trap_init>:
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	// Processor internal interrupts
	int i;
	for (i = 0; i <= 19; i++) {
f0103715:	b8 00 00 00 00       	mov    $0x0,%eax
		SETGATE(idt[i], 0, GD_KT, handlers[i], 0);
f010371a:	8b 14 85 b2 03 12 f0 	mov    -0xfedfc4e(,%eax,4),%edx
f0103721:	66 89 14 c5 60 72 20 	mov    %dx,-0xfdf8da0(,%eax,8)
f0103728:	f0 
f0103729:	66 c7 04 c5 62 72 20 	movw   $0x8,-0xfdf8d9e(,%eax,8)
f0103730:	f0 08 00 
f0103733:	c6 04 c5 64 72 20 f0 	movb   $0x0,-0xfdf8d9c(,%eax,8)
f010373a:	00 
f010373b:	c6 04 c5 65 72 20 f0 	movb   $0x8e,-0xfdf8d9b(,%eax,8)
f0103742:	8e 
f0103743:	c1 ea 10             	shr    $0x10,%edx
f0103746:	66 89 14 c5 66 72 20 	mov    %dx,-0xfdf8d9a(,%eax,8)
f010374d:	f0 
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	// Processor internal interrupts
	int i;
	for (i = 0; i <= 19; i++) {
f010374e:	83 c0 01             	add    $0x1,%eax
f0103751:	83 f8 14             	cmp    $0x14,%eax
f0103754:	75 c4                	jne    f010371a <trap_init+0x5>
		SETGATE(idt[i], 0, GD_KT, handlers[i], 0);
	}
	SETGATE(idt[T_BRKPT], 0, GD_KT, handlers[T_BRKPT], 3);
f0103756:	a1 be 03 12 f0       	mov    0xf01203be,%eax
f010375b:	66 a3 78 72 20 f0    	mov    %ax,0xf0207278
f0103761:	66 c7 05 7a 72 20 f0 	movw   $0x8,0xf020727a
f0103768:	08 00 
f010376a:	c6 05 7c 72 20 f0 00 	movb   $0x0,0xf020727c
f0103771:	c6 05 7d 72 20 f0 ee 	movb   $0xee,0xf020727d
f0103778:	c1 e8 10             	shr    $0x10,%eax
f010377b:	66 a3 7e 72 20 f0    	mov    %ax,0xf020727e

	// For system call
	SETGATE(idt[T_SYSCALL], 0, GD_KT, &handler_syscall, 3);
f0103781:	b8 54 3e 10 f0       	mov    $0xf0103e54,%eax
f0103786:	66 a3 e0 73 20 f0    	mov    %ax,0xf02073e0
f010378c:	66 c7 05 e2 73 20 f0 	movw   $0x8,0xf02073e2
f0103793:	08 00 
f0103795:	c6 05 e4 73 20 f0 00 	movb   $0x0,0xf02073e4
f010379c:	c6 05 e5 73 20 f0 ee 	movb   $0xee,0xf02073e5
f01037a3:	c1 e8 10             	shr    $0x10,%eax
f01037a6:	66 a3 e6 73 20 f0    	mov    %ax,0xf02073e6
f01037ac:	b8 20 00 00 00       	mov    $0x20,%eax

	// External interrupts
	for (i = 0; i <= 15; i++) {
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, handlers_irq[i],0);
f01037b1:	8b 14 85 82 03 12 f0 	mov    -0xfedfc7e(,%eax,4),%edx
f01037b8:	66 89 14 c5 60 72 20 	mov    %dx,-0xfdf8da0(,%eax,8)
f01037bf:	f0 
f01037c0:	66 c7 04 c5 62 72 20 	movw   $0x8,-0xfdf8d9e(,%eax,8)
f01037c7:	f0 08 00 
f01037ca:	c6 04 c5 64 72 20 f0 	movb   $0x0,-0xfdf8d9c(,%eax,8)
f01037d1:	00 
f01037d2:	c6 04 c5 65 72 20 f0 	movb   $0x8e,-0xfdf8d9b(,%eax,8)
f01037d9:	8e 
f01037da:	c1 ea 10             	shr    $0x10,%edx
f01037dd:	66 89 14 c5 66 72 20 	mov    %dx,-0xfdf8d9a(,%eax,8)
f01037e4:	f0 
f01037e5:	83 c0 01             	add    $0x1,%eax

	// For system call
	SETGATE(idt[T_SYSCALL], 0, GD_KT, &handler_syscall, 3);

	// External interrupts
	for (i = 0; i <= 15; i++) {
f01037e8:	83 f8 30             	cmp    $0x30,%eax
f01037eb:	75 c4                	jne    f01037b1 <trap_init+0x9c>
extern void* handler_syscall;
extern uint32_t handlers[];
extern uint32_t handlers_irq[];
void
trap_init(void)
{
f01037ed:	55                   	push   %ebp
f01037ee:	89 e5                	mov    %esp,%ebp
f01037f0:	83 ec 08             	sub    $0x8,%esp
	for (i = 0; i <= 15; i++) {
		SETGATE(idt[IRQ_OFFSET + i], 0, GD_KT, handlers_irq[i],0);
	}

	// Per-CPU setup 
	trap_init_percpu();
f01037f3:	e8 4d fe ff ff       	call   f0103645 <trap_init_percpu>
}
f01037f8:	c9                   	leave  
f01037f9:	c3                   	ret    

f01037fa <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01037fa:	55                   	push   %ebp
f01037fb:	89 e5                	mov    %esp,%ebp
f01037fd:	53                   	push   %ebx
f01037fe:	83 ec 0c             	sub    $0xc,%esp
f0103801:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103804:	ff 33                	pushl  (%ebx)
f0103806:	68 b4 6f 10 f0       	push   $0xf0106fb4
f010380b:	e8 21 fe ff ff       	call   f0103631 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103810:	83 c4 08             	add    $0x8,%esp
f0103813:	ff 73 04             	pushl  0x4(%ebx)
f0103816:	68 c3 6f 10 f0       	push   $0xf0106fc3
f010381b:	e8 11 fe ff ff       	call   f0103631 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103820:	83 c4 08             	add    $0x8,%esp
f0103823:	ff 73 08             	pushl  0x8(%ebx)
f0103826:	68 d2 6f 10 f0       	push   $0xf0106fd2
f010382b:	e8 01 fe ff ff       	call   f0103631 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103830:	83 c4 08             	add    $0x8,%esp
f0103833:	ff 73 0c             	pushl  0xc(%ebx)
f0103836:	68 e1 6f 10 f0       	push   $0xf0106fe1
f010383b:	e8 f1 fd ff ff       	call   f0103631 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103840:	83 c4 08             	add    $0x8,%esp
f0103843:	ff 73 10             	pushl  0x10(%ebx)
f0103846:	68 f0 6f 10 f0       	push   $0xf0106ff0
f010384b:	e8 e1 fd ff ff       	call   f0103631 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103850:	83 c4 08             	add    $0x8,%esp
f0103853:	ff 73 14             	pushl  0x14(%ebx)
f0103856:	68 ff 6f 10 f0       	push   $0xf0106fff
f010385b:	e8 d1 fd ff ff       	call   f0103631 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103860:	83 c4 08             	add    $0x8,%esp
f0103863:	ff 73 18             	pushl  0x18(%ebx)
f0103866:	68 0e 70 10 f0       	push   $0xf010700e
f010386b:	e8 c1 fd ff ff       	call   f0103631 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103870:	83 c4 08             	add    $0x8,%esp
f0103873:	ff 73 1c             	pushl  0x1c(%ebx)
f0103876:	68 1d 70 10 f0       	push   $0xf010701d
f010387b:	e8 b1 fd ff ff       	call   f0103631 <cprintf>
}
f0103880:	83 c4 10             	add    $0x10,%esp
f0103883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103886:	c9                   	leave  
f0103887:	c3                   	ret    

f0103888 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103888:	55                   	push   %ebp
f0103889:	89 e5                	mov    %esp,%ebp
f010388b:	56                   	push   %esi
f010388c:	53                   	push   %ebx
f010388d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103890:	e8 11 1e 00 00       	call   f01056a6 <cpunum>
f0103895:	83 ec 04             	sub    $0x4,%esp
f0103898:	50                   	push   %eax
f0103899:	53                   	push   %ebx
f010389a:	68 81 70 10 f0       	push   $0xf0107081
f010389f:	e8 8d fd ff ff       	call   f0103631 <cprintf>
	print_regs(&tf->tf_regs);
f01038a4:	89 1c 24             	mov    %ebx,(%esp)
f01038a7:	e8 4e ff ff ff       	call   f01037fa <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01038ac:	83 c4 08             	add    $0x8,%esp
f01038af:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01038b3:	50                   	push   %eax
f01038b4:	68 9f 70 10 f0       	push   $0xf010709f
f01038b9:	e8 73 fd ff ff       	call   f0103631 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01038be:	83 c4 08             	add    $0x8,%esp
f01038c1:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01038c5:	50                   	push   %eax
f01038c6:	68 b2 70 10 f0       	push   $0xf01070b2
f01038cb:	e8 61 fd ff ff       	call   f0103631 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01038d0:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01038d3:	83 c4 10             	add    $0x10,%esp
f01038d6:	83 f8 13             	cmp    $0x13,%eax
f01038d9:	77 09                	ja     f01038e4 <print_trapframe+0x5c>
		return excnames[trapno];
f01038db:	8b 14 85 40 73 10 f0 	mov    -0xfef8cc0(,%eax,4),%edx
f01038e2:	eb 1f                	jmp    f0103903 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f01038e4:	83 f8 30             	cmp    $0x30,%eax
f01038e7:	74 15                	je     f01038fe <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01038e9:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f01038ec:	83 fa 10             	cmp    $0x10,%edx
f01038ef:	b9 4b 70 10 f0       	mov    $0xf010704b,%ecx
f01038f4:	ba 38 70 10 f0       	mov    $0xf0107038,%edx
f01038f9:	0f 43 d1             	cmovae %ecx,%edx
f01038fc:	eb 05                	jmp    f0103903 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01038fe:	ba 2c 70 10 f0       	mov    $0xf010702c,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103903:	83 ec 04             	sub    $0x4,%esp
f0103906:	52                   	push   %edx
f0103907:	50                   	push   %eax
f0103908:	68 c5 70 10 f0       	push   $0xf01070c5
f010390d:	e8 1f fd ff ff       	call   f0103631 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103912:	83 c4 10             	add    $0x10,%esp
f0103915:	3b 1d 60 7a 20 f0    	cmp    0xf0207a60,%ebx
f010391b:	75 1a                	jne    f0103937 <print_trapframe+0xaf>
f010391d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103921:	75 14                	jne    f0103937 <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103923:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103926:	83 ec 08             	sub    $0x8,%esp
f0103929:	50                   	push   %eax
f010392a:	68 d7 70 10 f0       	push   $0xf01070d7
f010392f:	e8 fd fc ff ff       	call   f0103631 <cprintf>
f0103934:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103937:	83 ec 08             	sub    $0x8,%esp
f010393a:	ff 73 2c             	pushl  0x2c(%ebx)
f010393d:	68 e6 70 10 f0       	push   $0xf01070e6
f0103942:	e8 ea fc ff ff       	call   f0103631 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103947:	83 c4 10             	add    $0x10,%esp
f010394a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010394e:	75 49                	jne    f0103999 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103950:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103953:	89 c2                	mov    %eax,%edx
f0103955:	83 e2 01             	and    $0x1,%edx
f0103958:	ba 65 70 10 f0       	mov    $0xf0107065,%edx
f010395d:	b9 5a 70 10 f0       	mov    $0xf010705a,%ecx
f0103962:	0f 44 ca             	cmove  %edx,%ecx
f0103965:	89 c2                	mov    %eax,%edx
f0103967:	83 e2 02             	and    $0x2,%edx
f010396a:	ba 77 70 10 f0       	mov    $0xf0107077,%edx
f010396f:	be 71 70 10 f0       	mov    $0xf0107071,%esi
f0103974:	0f 45 d6             	cmovne %esi,%edx
f0103977:	83 e0 04             	and    $0x4,%eax
f010397a:	be cc 71 10 f0       	mov    $0xf01071cc,%esi
f010397f:	b8 7c 70 10 f0       	mov    $0xf010707c,%eax
f0103984:	0f 44 c6             	cmove  %esi,%eax
f0103987:	51                   	push   %ecx
f0103988:	52                   	push   %edx
f0103989:	50                   	push   %eax
f010398a:	68 f4 70 10 f0       	push   $0xf01070f4
f010398f:	e8 9d fc ff ff       	call   f0103631 <cprintf>
f0103994:	83 c4 10             	add    $0x10,%esp
f0103997:	eb 10                	jmp    f01039a9 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103999:	83 ec 0c             	sub    $0xc,%esp
f010399c:	68 57 6f 10 f0       	push   $0xf0106f57
f01039a1:	e8 8b fc ff ff       	call   f0103631 <cprintf>
f01039a6:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01039a9:	83 ec 08             	sub    $0x8,%esp
f01039ac:	ff 73 30             	pushl  0x30(%ebx)
f01039af:	68 03 71 10 f0       	push   $0xf0107103
f01039b4:	e8 78 fc ff ff       	call   f0103631 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01039b9:	83 c4 08             	add    $0x8,%esp
f01039bc:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01039c0:	50                   	push   %eax
f01039c1:	68 12 71 10 f0       	push   $0xf0107112
f01039c6:	e8 66 fc ff ff       	call   f0103631 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01039cb:	83 c4 08             	add    $0x8,%esp
f01039ce:	ff 73 38             	pushl  0x38(%ebx)
f01039d1:	68 25 71 10 f0       	push   $0xf0107125
f01039d6:	e8 56 fc ff ff       	call   f0103631 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01039db:	83 c4 10             	add    $0x10,%esp
f01039de:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01039e2:	74 25                	je     f0103a09 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01039e4:	83 ec 08             	sub    $0x8,%esp
f01039e7:	ff 73 3c             	pushl  0x3c(%ebx)
f01039ea:	68 34 71 10 f0       	push   $0xf0107134
f01039ef:	e8 3d fc ff ff       	call   f0103631 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01039f4:	83 c4 08             	add    $0x8,%esp
f01039f7:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01039fb:	50                   	push   %eax
f01039fc:	68 43 71 10 f0       	push   $0xf0107143
f0103a01:	e8 2b fc ff ff       	call   f0103631 <cprintf>
f0103a06:	83 c4 10             	add    $0x10,%esp
	}
}
f0103a09:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a0c:	5b                   	pop    %ebx
f0103a0d:	5e                   	pop    %esi
f0103a0e:	5d                   	pop    %ebp
f0103a0f:	c3                   	ret    

f0103a10 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103a10:	55                   	push   %ebp
f0103a11:	89 e5                	mov    %esp,%ebp
f0103a13:	57                   	push   %edi
f0103a14:	56                   	push   %esi
f0103a15:	53                   	push   %ebx
f0103a16:	83 ec 1c             	sub    $0x1c,%esp
f0103a19:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103a1c:	0f 20 d6             	mov    %cr2,%esi
	//cprintf("DEBUG-TRAP: Page fault on address %x, err = %x\n", fault_va, tf->tf_err);

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) // Checks last 2 bits are 0
f0103a1f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103a23:	75 17                	jne    f0103a3c <page_fault_handler+0x2c>
		panic("Page fault on kernel mode!");
f0103a25:	83 ec 04             	sub    $0x4,%esp
f0103a28:	68 56 71 10 f0       	push   $0xf0107156
f0103a2d:	68 5a 01 00 00       	push   $0x15a
f0103a32:	68 71 71 10 f0       	push   $0xf0107171
f0103a37:	e8 04 c6 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0103a3c:	e8 65 1c 00 00       	call   f01056a6 <cpunum>
f0103a41:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a44:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103a4a:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103a4e:	0f 84 95 00 00 00    	je     f0103ae9 <page_fault_handler+0xd9>
		struct UTrapframe *utf;

		// Recursive case. Pgfault handler pgfaulted.
		if (UXSTACKTOP-PGSIZE <= tf->tf_esp && tf->tf_esp < UXSTACKTOP) {
f0103a54:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103a57:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *) (tf->tf_esp - 4); // Gap
f0103a5d:	83 e8 04             	sub    $0x4,%eax
f0103a60:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103a66:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0103a6b:	0f 46 d0             	cmovbe %eax,%edx
f0103a6e:	89 d7                	mov    %edx,%edi
		} else {
			utf = (struct UTrapframe *) UXSTACKTOP;
		}

		// Make utf point to the new top of the exception stack
		utf--;
f0103a70:	8d 42 cc             	lea    -0x34(%edx),%eax
f0103a73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		user_mem_assert(curenv, utf, sizeof(struct UTrapframe), PTE_W);
f0103a76:	e8 2b 1c 00 00       	call   f01056a6 <cpunum>
f0103a7b:	6a 02                	push   $0x2
f0103a7d:	6a 34                	push   $0x34
f0103a7f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103a82:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a85:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0103a8b:	e8 73 f3 ff ff       	call   f0102e03 <user_mem_assert>

		// "Push" the info
		utf->utf_fault_va = fault_va;
f0103a90:	89 fa                	mov    %edi,%edx
f0103a92:	89 77 cc             	mov    %esi,-0x34(%edi)
		utf->utf_err = tf->tf_err;
f0103a95:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103a98:	89 47 d0             	mov    %eax,-0x30(%edi)
		utf->utf_regs = tf->tf_regs;
f0103a9b:	8d 7f d4             	lea    -0x2c(%edi),%edi
f0103a9e:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103aa3:	89 de                	mov    %ebx,%esi
f0103aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0103aa7:	8b 43 30             	mov    0x30(%ebx),%eax
f0103aaa:	89 42 f4             	mov    %eax,-0xc(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0103aad:	8b 43 38             	mov    0x38(%ebx),%eax
f0103ab0:	89 42 f8             	mov    %eax,-0x8(%edx)
		utf->utf_esp = tf->tf_esp;
f0103ab3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103ab6:	89 42 fc             	mov    %eax,-0x4(%edx)

		// Branch to curenv->env_pgfault_upcall: back to user mode!
		tf->tf_esp = (uintptr_t) utf;
f0103ab9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103abc:	89 43 3c             	mov    %eax,0x3c(%ebx)
		tf->tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f0103abf:	e8 e2 1b 00 00       	call   f01056a6 <cpunum>
f0103ac4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ac7:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103acd:	8b 40 64             	mov    0x64(%eax),%eax
f0103ad0:	89 43 30             	mov    %eax,0x30(%ebx)
		env_run(curenv);
f0103ad3:	e8 ce 1b 00 00       	call   f01056a6 <cpunum>
f0103ad8:	83 c4 04             	add    $0x4,%esp
f0103adb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ade:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0103ae4:	e8 2e f9 ff ff       	call   f0103417 <env_run>

		return;
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ae9:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103aec:	e8 b5 1b 00 00       	call   f01056a6 <cpunum>

		return;
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103af1:	57                   	push   %edi
f0103af2:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103af3:	6b c0 74             	imul   $0x74,%eax,%eax

		return;
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103af6:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103afc:	ff 70 48             	pushl  0x48(%eax)
f0103aff:	68 18 73 10 f0       	push   $0xf0107318
f0103b04:	e8 28 fb ff ff       	call   f0103631 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103b09:	89 1c 24             	mov    %ebx,(%esp)
f0103b0c:	e8 77 fd ff ff       	call   f0103888 <print_trapframe>
	env_destroy(curenv);
f0103b11:	e8 90 1b 00 00       	call   f01056a6 <cpunum>
f0103b16:	83 c4 04             	add    $0x4,%esp
f0103b19:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b1c:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0103b22:	e8 51 f8 ff ff       	call   f0103378 <env_destroy>
}
f0103b27:	83 c4 10             	add    $0x10,%esp
f0103b2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b2d:	5b                   	pop    %ebx
f0103b2e:	5e                   	pop    %esi
f0103b2f:	5f                   	pop    %edi
f0103b30:	5d                   	pop    %ebp
f0103b31:	c3                   	ret    

f0103b32 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103b32:	55                   	push   %ebp
f0103b33:	89 e5                	mov    %esp,%ebp
f0103b35:	57                   	push   %edi
f0103b36:	56                   	push   %esi
f0103b37:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103b3a:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103b3b:	83 3d 80 7e 20 f0 00 	cmpl   $0x0,0xf0207e80
f0103b42:	74 01                	je     f0103b45 <trap+0x13>
		asm volatile("hlt");
f0103b44:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103b45:	e8 5c 1b 00 00       	call   f01056a6 <cpunum>
f0103b4a:	6b d0 74             	imul   $0x74,%eax,%edx
f0103b4d:	81 c2 20 80 20 f0    	add    $0xf0208020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103b53:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b58:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103b5c:	83 f8 02             	cmp    $0x2,%eax
f0103b5f:	75 10                	jne    f0103b71 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103b61:	83 ec 0c             	sub    $0xc,%esp
f0103b64:	68 60 04 12 f0       	push   $0xf0120460
f0103b69:	e8 a6 1d 00 00       	call   f0105914 <spin_lock>
f0103b6e:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103b71:	9c                   	pushf  
f0103b72:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103b73:	f6 c4 02             	test   $0x2,%ah
f0103b76:	74 19                	je     f0103b91 <trap+0x5f>
f0103b78:	68 7d 71 10 f0       	push   $0xf010717d
f0103b7d:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0103b82:	68 23 01 00 00       	push   $0x123
f0103b87:	68 71 71 10 f0       	push   $0xf0107171
f0103b8c:	e8 af c4 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103b91:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103b95:	83 e0 03             	and    $0x3,%eax
f0103b98:	66 83 f8 03          	cmp    $0x3,%ax
f0103b9c:	0f 85 a0 00 00 00    	jne    f0103c42 <trap+0x110>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0103ba2:	e8 ff 1a 00 00       	call   f01056a6 <cpunum>
f0103ba7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103baa:	83 b8 28 80 20 f0 00 	cmpl   $0x0,-0xfdf7fd8(%eax)
f0103bb1:	75 19                	jne    f0103bcc <trap+0x9a>
f0103bb3:	68 96 71 10 f0       	push   $0xf0107196
f0103bb8:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0103bbd:	68 2a 01 00 00       	push   $0x12a
f0103bc2:	68 71 71 10 f0       	push   $0xf0107171
f0103bc7:	e8 74 c4 ff ff       	call   f0100040 <_panic>
f0103bcc:	83 ec 0c             	sub    $0xc,%esp
f0103bcf:	68 60 04 12 f0       	push   $0xf0120460
f0103bd4:	e8 3b 1d 00 00       	call   f0105914 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103bd9:	e8 c8 1a 00 00       	call   f01056a6 <cpunum>
f0103bde:	6b c0 74             	imul   $0x74,%eax,%eax
f0103be1:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103be7:	83 c4 10             	add    $0x10,%esp
f0103bea:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103bee:	75 2d                	jne    f0103c1d <trap+0xeb>
			env_free(curenv);
f0103bf0:	e8 b1 1a 00 00       	call   f01056a6 <cpunum>
f0103bf5:	83 ec 0c             	sub    $0xc,%esp
f0103bf8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bfb:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0103c01:	e8 cc f5 ff ff       	call   f01031d2 <env_free>
			curenv = NULL;
f0103c06:	e8 9b 1a 00 00       	call   f01056a6 <cpunum>
f0103c0b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c0e:	c7 80 28 80 20 f0 00 	movl   $0x0,-0xfdf7fd8(%eax)
f0103c15:	00 00 00 
			sched_yield();
f0103c18:	e8 26 03 00 00       	call   f0103f43 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103c1d:	e8 84 1a 00 00       	call   f01056a6 <cpunum>
f0103c22:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c25:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103c2b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103c30:	89 c7                	mov    %eax,%edi
f0103c32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103c34:	e8 6d 1a 00 00       	call   f01056a6 <cpunum>
f0103c39:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c3c:	8b b0 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103c42:	89 35 60 7a 20 f0    	mov    %esi,0xf0207a60
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// TODO: Start using T_* instead of interrupt numbers
	// TODO: Use a switch
	// TODO: Remove debugging printings
	if (tf->tf_trapno == 3) {
f0103c48:	8b 46 28             	mov    0x28(%esi),%eax
f0103c4b:	83 f8 03             	cmp    $0x3,%eax
f0103c4e:	75 11                	jne    f0103c61 <trap+0x12f>
		//cprintf("DEBUG-TRAP: Trap dispatch - Breakpoint\n");
		monitor(tf);
f0103c50:	83 ec 0c             	sub    $0xc,%esp
f0103c53:	56                   	push   %esi
f0103c54:	e8 84 cc ff ff       	call   f01008dd <monitor>
f0103c59:	83 c4 10             	add    $0x10,%esp
f0103c5c:	e9 ad 00 00 00       	jmp    f0103d0e <trap+0x1dc>
		return;
	}
	if (tf->tf_trapno == 14) {
f0103c61:	83 f8 0e             	cmp    $0xe,%eax
f0103c64:	75 11                	jne    f0103c77 <trap+0x145>
		//cprintf("DEBUG-TRAP: Trap dispatch - Page fault\n");
		page_fault_handler(tf);
f0103c66:	83 ec 0c             	sub    $0xc,%esp
f0103c69:	56                   	push   %esi
f0103c6a:	e8 a1 fd ff ff       	call   f0103a10 <page_fault_handler>
f0103c6f:	83 c4 10             	add    $0x10,%esp
f0103c72:	e9 97 00 00 00       	jmp    f0103d0e <trap+0x1dc>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0103c77:	83 f8 30             	cmp    $0x30,%eax
f0103c7a:	75 21                	jne    f0103c9d <trap+0x16b>
		//cprintf("DEBUG-TRAP: Trap dispatch - System Call\n");
		struct PushRegs regs = tf->tf_regs;
		int32_t retValue;
		retValue = syscall(regs.reg_eax,// system call number - eax
f0103c7c:	83 ec 08             	sub    $0x8,%esp
f0103c7f:	ff 76 04             	pushl  0x4(%esi)
f0103c82:	ff 36                	pushl  (%esi)
f0103c84:	ff 76 10             	pushl  0x10(%esi)
f0103c87:	ff 76 18             	pushl  0x18(%esi)
f0103c8a:	ff 76 14             	pushl  0x14(%esi)
f0103c8d:	ff 76 1c             	pushl  0x1c(%esi)
f0103c90:	e8 7a 03 00 00       	call   f010400f <syscall>
				regs.reg_edx,	// a1 - edx
				regs.reg_ecx,	// a2 - ecx
				regs.reg_ebx,	// a3 - ebx
				regs.reg_edi,	// a4 - edi
				regs.reg_esi);	// a5 - esi
		tf->tf_regs.reg_eax = retValue;
f0103c95:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103c98:	83 c4 20             	add    $0x20,%esp
f0103c9b:	eb 71                	jmp    f0103d0e <trap+0x1dc>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103c9d:	83 f8 27             	cmp    $0x27,%eax
f0103ca0:	75 1a                	jne    f0103cbc <trap+0x18a>
		cprintf("Spurious interrupt on irq 7\n");
f0103ca2:	83 ec 0c             	sub    $0xc,%esp
f0103ca5:	68 9d 71 10 f0       	push   $0xf010719d
f0103caa:	e8 82 f9 ff ff       	call   f0103631 <cprintf>
		print_trapframe(tf);
f0103caf:	89 34 24             	mov    %esi,(%esp)
f0103cb2:	e8 d1 fb ff ff       	call   f0103888 <print_trapframe>
f0103cb7:	83 c4 10             	add    $0x10,%esp
f0103cba:	eb 52                	jmp    f0103d0e <trap+0x1dc>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0103cbc:	83 f8 20             	cmp    $0x20,%eax
f0103cbf:	75 0a                	jne    f0103ccb <trap+0x199>
		//cprintf("DEBUG-TRAP: Trap dispatch - Clock interrupt\n");
		lapic_eoi();
f0103cc1:	e8 2b 1b 00 00       	call   f01057f1 <lapic_eoi>
		sched_yield();
f0103cc6:	e8 78 02 00 00       	call   f0103f43 <sched_yield>
	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	//cprintf("DEBUG-TRAP: Unexpected trap\n");
	print_trapframe(tf);
f0103ccb:	83 ec 0c             	sub    $0xc,%esp
f0103cce:	56                   	push   %esi
f0103ccf:	e8 b4 fb ff ff       	call   f0103888 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103cd4:	83 c4 10             	add    $0x10,%esp
f0103cd7:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103cdc:	75 17                	jne    f0103cf5 <trap+0x1c3>
		panic("unhandled trap in kernel");
f0103cde:	83 ec 04             	sub    $0x4,%esp
f0103ce1:	68 ba 71 10 f0       	push   $0xf01071ba
f0103ce6:	68 09 01 00 00       	push   $0x109
f0103ceb:	68 71 71 10 f0       	push   $0xf0107171
f0103cf0:	e8 4b c3 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0103cf5:	e8 ac 19 00 00       	call   f01056a6 <cpunum>
f0103cfa:	83 ec 0c             	sub    $0xc,%esp
f0103cfd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d00:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0103d06:	e8 6d f6 ff ff       	call   f0103378 <env_destroy>
f0103d0b:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103d0e:	e8 93 19 00 00       	call   f01056a6 <cpunum>
f0103d13:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d16:	83 b8 28 80 20 f0 00 	cmpl   $0x0,-0xfdf7fd8(%eax)
f0103d1d:	74 2a                	je     f0103d49 <trap+0x217>
f0103d1f:	e8 82 19 00 00       	call   f01056a6 <cpunum>
f0103d24:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d27:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103d2d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d31:	75 16                	jne    f0103d49 <trap+0x217>
		env_run(curenv);
f0103d33:	e8 6e 19 00 00       	call   f01056a6 <cpunum>
f0103d38:	83 ec 0c             	sub    $0xc,%esp
f0103d3b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d3e:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0103d44:	e8 ce f6 ff ff       	call   f0103417 <env_run>
	else
		sched_yield();
f0103d49:	e8 f5 01 00 00       	call   f0103f43 <sched_yield>

f0103d4e <handler0>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

# Handlers for process exceptions
TRAPHANDLER_NOEC(handler0, 0)
f0103d4e:	6a 00                	push   $0x0
f0103d50:	6a 00                	push   $0x0
f0103d52:	e9 03 01 00 00       	jmp    f0103e5a <_alltraps>
f0103d57:	90                   	nop

f0103d58 <handler1>:
TRAPHANDLER_NOEC(handler1, 1)
f0103d58:	6a 00                	push   $0x0
f0103d5a:	6a 01                	push   $0x1
f0103d5c:	e9 f9 00 00 00       	jmp    f0103e5a <_alltraps>
f0103d61:	90                   	nop

f0103d62 <handler2>:
TRAPHANDLER_NOEC(handler2, 2)
f0103d62:	6a 00                	push   $0x0
f0103d64:	6a 02                	push   $0x2
f0103d66:	e9 ef 00 00 00       	jmp    f0103e5a <_alltraps>
f0103d6b:	90                   	nop

f0103d6c <handler3>:
TRAPHANDLER_NOEC(handler3, 3)
f0103d6c:	6a 00                	push   $0x0
f0103d6e:	6a 03                	push   $0x3
f0103d70:	e9 e5 00 00 00       	jmp    f0103e5a <_alltraps>
f0103d75:	90                   	nop

f0103d76 <handler4>:
TRAPHANDLER_NOEC(handler4, 4)
f0103d76:	6a 00                	push   $0x0
f0103d78:	6a 04                	push   $0x4
f0103d7a:	e9 db 00 00 00       	jmp    f0103e5a <_alltraps>
f0103d7f:	90                   	nop

f0103d80 <handler5>:
TRAPHANDLER_NOEC(handler5, 5)
f0103d80:	6a 00                	push   $0x0
f0103d82:	6a 05                	push   $0x5
f0103d84:	e9 d1 00 00 00       	jmp    f0103e5a <_alltraps>
f0103d89:	90                   	nop

f0103d8a <handler6>:
TRAPHANDLER_NOEC(handler6, 6)
f0103d8a:	6a 00                	push   $0x0
f0103d8c:	6a 06                	push   $0x6
f0103d8e:	e9 c7 00 00 00       	jmp    f0103e5a <_alltraps>
f0103d93:	90                   	nop

f0103d94 <handler7>:
TRAPHANDLER_NOEC(handler7, 7)
f0103d94:	6a 00                	push   $0x0
f0103d96:	6a 07                	push   $0x7
f0103d98:	e9 bd 00 00 00       	jmp    f0103e5a <_alltraps>
f0103d9d:	90                   	nop

f0103d9e <handler8>:
TRAPHANDLER(handler8, 8)
f0103d9e:	6a 08                	push   $0x8
f0103da0:	e9 b5 00 00 00       	jmp    f0103e5a <_alltraps>
f0103da5:	90                   	nop

f0103da6 <handler9>:
TRAPHANDLER_NOEC(handler9, 9)
f0103da6:	6a 00                	push   $0x0
f0103da8:	6a 09                	push   $0x9
f0103daa:	e9 ab 00 00 00       	jmp    f0103e5a <_alltraps>
f0103daf:	90                   	nop

f0103db0 <handler10>:
TRAPHANDLER(handler10, 10)
f0103db0:	6a 0a                	push   $0xa
f0103db2:	e9 a3 00 00 00       	jmp    f0103e5a <_alltraps>
f0103db7:	90                   	nop

f0103db8 <handler11>:
TRAPHANDLER(handler11, 11)
f0103db8:	6a 0b                	push   $0xb
f0103dba:	e9 9b 00 00 00       	jmp    f0103e5a <_alltraps>
f0103dbf:	90                   	nop

f0103dc0 <handler12>:
TRAPHANDLER(handler12, 12)
f0103dc0:	6a 0c                	push   $0xc
f0103dc2:	e9 93 00 00 00       	jmp    f0103e5a <_alltraps>
f0103dc7:	90                   	nop

f0103dc8 <handler13>:
TRAPHANDLER(handler13, 13)
f0103dc8:	6a 0d                	push   $0xd
f0103dca:	e9 8b 00 00 00       	jmp    f0103e5a <_alltraps>
f0103dcf:	90                   	nop

f0103dd0 <handler14>:
TRAPHANDLER(handler14, 14)
f0103dd0:	6a 0e                	push   $0xe
f0103dd2:	e9 83 00 00 00       	jmp    f0103e5a <_alltraps>
f0103dd7:	90                   	nop

f0103dd8 <handler15>:
TRAPHANDLER_NOEC(handler15, 15)
f0103dd8:	6a 00                	push   $0x0
f0103dda:	6a 0f                	push   $0xf
f0103ddc:	eb 7c                	jmp    f0103e5a <_alltraps>

f0103dde <handler16>:
TRAPHANDLER_NOEC(handler16, 16)
f0103dde:	6a 00                	push   $0x0
f0103de0:	6a 10                	push   $0x10
f0103de2:	eb 76                	jmp    f0103e5a <_alltraps>

f0103de4 <handler17>:
TRAPHANDLER(handler17, 17)
f0103de4:	6a 11                	push   $0x11
f0103de6:	eb 72                	jmp    f0103e5a <_alltraps>

f0103de8 <handler18>:
TRAPHANDLER_NOEC(handler18, 18)
f0103de8:	6a 00                	push   $0x0
f0103dea:	6a 12                	push   $0x12
f0103dec:	eb 6c                	jmp    f0103e5a <_alltraps>

f0103dee <handler19>:
TRAPHANDLER_NOEC(handler19, 19)
f0103dee:	6a 00                	push   $0x0
f0103df0:	6a 13                	push   $0x13
f0103df2:	eb 66                	jmp    f0103e5a <_alltraps>

f0103df4 <handler_irq0>:

# Handlers for external interrupts
TRAPHANDLER_NOEC(handler_irq0, IRQ_OFFSET + 0)
f0103df4:	6a 00                	push   $0x0
f0103df6:	6a 20                	push   $0x20
f0103df8:	eb 60                	jmp    f0103e5a <_alltraps>

f0103dfa <handler_irq1>:
TRAPHANDLER_NOEC(handler_irq1, IRQ_OFFSET + 1)
f0103dfa:	6a 00                	push   $0x0
f0103dfc:	6a 21                	push   $0x21
f0103dfe:	eb 5a                	jmp    f0103e5a <_alltraps>

f0103e00 <handler_irq2>:
TRAPHANDLER_NOEC(handler_irq2, IRQ_OFFSET + 2)
f0103e00:	6a 00                	push   $0x0
f0103e02:	6a 22                	push   $0x22
f0103e04:	eb 54                	jmp    f0103e5a <_alltraps>

f0103e06 <handler_irq3>:
TRAPHANDLER_NOEC(handler_irq3, IRQ_OFFSET + 3)
f0103e06:	6a 00                	push   $0x0
f0103e08:	6a 23                	push   $0x23
f0103e0a:	eb 4e                	jmp    f0103e5a <_alltraps>

f0103e0c <handler_irq4>:
TRAPHANDLER_NOEC(handler_irq4, IRQ_OFFSET + 4)
f0103e0c:	6a 00                	push   $0x0
f0103e0e:	6a 24                	push   $0x24
f0103e10:	eb 48                	jmp    f0103e5a <_alltraps>

f0103e12 <handler_irq5>:
TRAPHANDLER_NOEC(handler_irq5, IRQ_OFFSET + 5)
f0103e12:	6a 00                	push   $0x0
f0103e14:	6a 25                	push   $0x25
f0103e16:	eb 42                	jmp    f0103e5a <_alltraps>

f0103e18 <handler_irq6>:
TRAPHANDLER_NOEC(handler_irq6, IRQ_OFFSET + 6)
f0103e18:	6a 00                	push   $0x0
f0103e1a:	6a 26                	push   $0x26
f0103e1c:	eb 3c                	jmp    f0103e5a <_alltraps>

f0103e1e <handler_irq7>:
TRAPHANDLER_NOEC(handler_irq7, IRQ_OFFSET + 7)
f0103e1e:	6a 00                	push   $0x0
f0103e20:	6a 27                	push   $0x27
f0103e22:	eb 36                	jmp    f0103e5a <_alltraps>

f0103e24 <handler_irq8>:
TRAPHANDLER_NOEC(handler_irq8, IRQ_OFFSET + 8)
f0103e24:	6a 00                	push   $0x0
f0103e26:	6a 28                	push   $0x28
f0103e28:	eb 30                	jmp    f0103e5a <_alltraps>

f0103e2a <handler_irq9>:
TRAPHANDLER_NOEC(handler_irq9, IRQ_OFFSET + 9)
f0103e2a:	6a 00                	push   $0x0
f0103e2c:	6a 29                	push   $0x29
f0103e2e:	eb 2a                	jmp    f0103e5a <_alltraps>

f0103e30 <handler_irq10>:
TRAPHANDLER_NOEC(handler_irq10,IRQ_OFFSET + 10)
f0103e30:	6a 00                	push   $0x0
f0103e32:	6a 2a                	push   $0x2a
f0103e34:	eb 24                	jmp    f0103e5a <_alltraps>

f0103e36 <handler_irq11>:
TRAPHANDLER_NOEC(handler_irq11,IRQ_OFFSET + 11)
f0103e36:	6a 00                	push   $0x0
f0103e38:	6a 2b                	push   $0x2b
f0103e3a:	eb 1e                	jmp    f0103e5a <_alltraps>

f0103e3c <handler_irq12>:
TRAPHANDLER_NOEC(handler_irq12,IRQ_OFFSET + 12)
f0103e3c:	6a 00                	push   $0x0
f0103e3e:	6a 2c                	push   $0x2c
f0103e40:	eb 18                	jmp    f0103e5a <_alltraps>

f0103e42 <handler_irq13>:
TRAPHANDLER_NOEC(handler_irq13,IRQ_OFFSET + 13)
f0103e42:	6a 00                	push   $0x0
f0103e44:	6a 2d                	push   $0x2d
f0103e46:	eb 12                	jmp    f0103e5a <_alltraps>

f0103e48 <handler_irq14>:
TRAPHANDLER_NOEC(handler_irq14,IRQ_OFFSET + 14)
f0103e48:	6a 00                	push   $0x0
f0103e4a:	6a 2e                	push   $0x2e
f0103e4c:	eb 0c                	jmp    f0103e5a <_alltraps>

f0103e4e <handler_irq15>:
TRAPHANDLER_NOEC(handler_irq15,IRQ_OFFSET + 15)
f0103e4e:	6a 00                	push   $0x0
f0103e50:	6a 2f                	push   $0x2f
f0103e52:	eb 06                	jmp    f0103e5a <_alltraps>

f0103e54 <handler_syscall>:

# For system call
TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f0103e54:	6a 00                	push   $0x0
f0103e56:	6a 30                	push   $0x30
f0103e58:	eb 00                	jmp    f0103e5a <_alltraps>

f0103e5a <_alltraps>:
 */
// TODO: Replace mov with movw
.globl _alltraps
_alltraps:
	# Push values to make the stack look like a struct Trapframe
	pushl %ds
f0103e5a:	1e                   	push   %ds
	pushl %es
f0103e5b:	06                   	push   %es
	pushal
f0103e5c:	60                   	pusha  

	# Load GD_KD into %ds and %es
	mov $GD_KD, %eax
f0103e5d:	b8 10 00 00 00       	mov    $0x10,%eax
	mov %ax, %ds
f0103e62:	8e d8                	mov    %eax,%ds
	mov %ax, %es
f0103e64:	8e c0                	mov    %eax,%es

	# Call trap(tf), where tf=%esp
	pushl %esp
f0103e66:	54                   	push   %esp
	call trap
f0103e67:	e8 c6 fc ff ff       	call   f0103b32 <trap>
	addl $4, %esp
f0103e6c:	83 c4 04             	add    $0x4,%esp

f0103e6f <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0103e6f:	55                   	push   %ebp
f0103e70:	89 e5                	mov    %esp,%ebp
f0103e72:	83 ec 08             	sub    $0x8,%esp
f0103e75:	a1 48 72 20 f0       	mov    0xf0207248,%eax
f0103e7a:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103e7d:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103e82:	8b 02                	mov    (%edx),%eax
f0103e84:	83 e8 01             	sub    $0x1,%eax
f0103e87:	83 f8 02             	cmp    $0x2,%eax
f0103e8a:	76 10                	jbe    f0103e9c <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103e8c:	83 c1 01             	add    $0x1,%ecx
f0103e8f:	83 c2 7c             	add    $0x7c,%edx
f0103e92:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103e98:	75 e8                	jne    f0103e82 <sched_halt+0x13>
f0103e9a:	eb 08                	jmp    f0103ea4 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0103e9c:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103ea2:	75 1f                	jne    f0103ec3 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0103ea4:	83 ec 0c             	sub    $0xc,%esp
f0103ea7:	68 90 73 10 f0       	push   $0xf0107390
f0103eac:	e8 80 f7 ff ff       	call   f0103631 <cprintf>
f0103eb1:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103eb4:	83 ec 0c             	sub    $0xc,%esp
f0103eb7:	6a 00                	push   $0x0
f0103eb9:	e8 1f ca ff ff       	call   f01008dd <monitor>
f0103ebe:	83 c4 10             	add    $0x10,%esp
f0103ec1:	eb f1                	jmp    f0103eb4 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0103ec3:	e8 de 17 00 00       	call   f01056a6 <cpunum>
f0103ec8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ecb:	c7 80 28 80 20 f0 00 	movl   $0x0,-0xfdf7fd8(%eax)
f0103ed2:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0103ed5:	a1 8c 7e 20 f0       	mov    0xf0207e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103eda:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103edf:	77 12                	ja     f0103ef3 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ee1:	50                   	push   %eax
f0103ee2:	68 88 5d 10 f0       	push   $0xf0105d88
f0103ee7:	6a 5a                	push   $0x5a
f0103ee9:	68 b9 73 10 f0       	push   $0xf01073b9
f0103eee:	e8 4d c1 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103ef3:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ef8:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0103efb:	e8 a6 17 00 00       	call   f01056a6 <cpunum>
f0103f00:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f03:	81 c2 20 80 20 f0    	add    $0xf0208020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103f09:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f0e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103f12:	83 ec 0c             	sub    $0xc,%esp
f0103f15:	68 60 04 12 f0       	push   $0xf0120460
f0103f1a:	e8 92 1a 00 00       	call   f01059b1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103f1f:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0103f21:	e8 80 17 00 00       	call   f01056a6 <cpunum>
f0103f26:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0103f29:	8b 80 30 80 20 f0    	mov    -0xfdf7fd0(%eax),%eax
f0103f2f:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103f34:	89 c4                	mov    %eax,%esp
f0103f36:	6a 00                	push   $0x0
f0103f38:	6a 00                	push   $0x0
f0103f3a:	fb                   	sti    
f0103f3b:	f4                   	hlt    
f0103f3c:	eb fd                	jmp    f0103f3b <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0103f3e:	83 c4 10             	add    $0x10,%esp
f0103f41:	c9                   	leave  
f0103f42:	c3                   	ret    

f0103f43 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0103f43:	55                   	push   %ebp
f0103f44:	89 e5                	mov    %esp,%ebp
f0103f46:	53                   	push   %ebx
f0103f47:	83 ec 04             	sub    $0x4,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.
	//cprintf("DEBUG-SCHED: CPU %d - In scheduler, curenv = %p\n", cpunum(), curenv);
	struct Env *e;
	if (curenv) {
f0103f4a:	e8 57 17 00 00       	call   f01056a6 <cpunum>
f0103f4f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f52:	83 b8 28 80 20 f0 00 	cmpl   $0x0,-0xfdf7fd8(%eax)
f0103f59:	0f 84 83 00 00 00    	je     f0103fe2 <sched_yield+0x9f>
		for (e = curenv + 1; e < envs + NENV; e++) {
f0103f5f:	e8 42 17 00 00       	call   f01056a6 <cpunum>
f0103f64:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f67:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103f6d:	83 c0 7c             	add    $0x7c,%eax
f0103f70:	8b 1d 48 72 20 f0    	mov    0xf0207248,%ebx
f0103f76:	8d 93 00 f0 01 00    	lea    0x1f000(%ebx),%edx
f0103f7c:	eb 12                	jmp    f0103f90 <sched_yield+0x4d>
			if (e->env_status == ENV_RUNNABLE) {
f0103f7e:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0103f82:	75 09                	jne    f0103f8d <sched_yield+0x4a>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
f0103f84:	83 ec 0c             	sub    $0xc,%esp
f0103f87:	50                   	push   %eax
f0103f88:	e8 8a f4 ff ff       	call   f0103417 <env_run>

	// LAB 4: Your code here.
	//cprintf("DEBUG-SCHED: CPU %d - In scheduler, curenv = %p\n", cpunum(), curenv);
	struct Env *e;
	if (curenv) {
		for (e = curenv + 1; e < envs + NENV; e++) {
f0103f8d:	83 c0 7c             	add    $0x7c,%eax
f0103f90:	39 d0                	cmp    %edx,%eax
f0103f92:	72 ea                	jb     f0103f7e <sched_yield+0x3b>
f0103f94:	eb 12                	jmp    f0103fa8 <sched_yield+0x65>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
			}
		}
		for (e = envs; e < curenv; e++) {
			if (e->env_status == ENV_RUNNABLE) {
f0103f96:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0103f9a:	75 09                	jne    f0103fa5 <sched_yield+0x62>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
f0103f9c:	83 ec 0c             	sub    $0xc,%esp
f0103f9f:	53                   	push   %ebx
f0103fa0:	e8 72 f4 ff ff       	call   f0103417 <env_run>
			if (e->env_status == ENV_RUNNABLE) {
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
			}
		}
		for (e = envs; e < curenv; e++) {
f0103fa5:	83 c3 7c             	add    $0x7c,%ebx
f0103fa8:	e8 f9 16 00 00       	call   f01056a6 <cpunum>
f0103fad:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb0:	3b 98 28 80 20 f0    	cmp    -0xfdf7fd8(%eax),%ebx
f0103fb6:	72 de                	jb     f0103f96 <sched_yield+0x53>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
			}
		}
		// If didn't find any runnable, try to keep running curenv
		if (curenv->env_status == ENV_RUNNING) {
f0103fb8:	e8 e9 16 00 00       	call   f01056a6 <cpunum>
f0103fbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc0:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0103fc6:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103fca:	75 39                	jne    f0104005 <sched_yield+0xc2>
			//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), curenv);
			env_run(curenv);
f0103fcc:	e8 d5 16 00 00       	call   f01056a6 <cpunum>
f0103fd1:	83 ec 0c             	sub    $0xc,%esp
f0103fd4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd7:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0103fdd:	e8 35 f4 ff ff       	call   f0103417 <env_run>
		}
	} else {
		for (e = envs; e < envs + NENV; e++) {
f0103fe2:	a1 48 72 20 f0       	mov    0xf0207248,%eax
f0103fe7:	8d 90 00 f0 01 00    	lea    0x1f000(%eax),%edx
f0103fed:	eb 12                	jmp    f0104001 <sched_yield+0xbe>
			if (e->env_status == ENV_RUNNABLE) {
f0103fef:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0103ff3:	75 09                	jne    f0103ffe <sched_yield+0xbb>
				//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), e);
				env_run(e);
f0103ff5:	83 ec 0c             	sub    $0xc,%esp
f0103ff8:	50                   	push   %eax
f0103ff9:	e8 19 f4 ff ff       	call   f0103417 <env_run>
		if (curenv->env_status == ENV_RUNNING) {
			//cprintf("DEBUG-SCHED: CPU %d: going to run env %p\n", cpunum(), curenv);
			env_run(curenv);
		}
	} else {
		for (e = envs; e < envs + NENV; e++) {
f0103ffe:	83 c0 7c             	add    $0x7c,%eax
f0104001:	39 d0                	cmp    %edx,%eax
f0104003:	75 ea                	jne    f0103fef <sched_yield+0xac>
		}
	}

	// sched_halt never returns
	//cprintf("DEBUG-SCHED: CPU %d: no env to run found\n", cpunum());
	sched_halt();
f0104005:	e8 65 fe ff ff       	call   f0103e6f <sched_halt>
}
f010400a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010400d:	c9                   	leave  
f010400e:	c3                   	ret    

f010400f <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010400f:	55                   	push   %ebp
f0104010:	89 e5                	mov    %esp,%ebp
f0104012:	57                   	push   %edi
f0104013:	56                   	push   %esi
f0104014:	53                   	push   %ebx
f0104015:	83 ec 1c             	sub    $0x1c,%esp
f0104018:	8b 45 08             	mov    0x8(%ebp),%eax
f010401b:	8b 75 10             	mov    0x10(%ebp),%esi
	// panic("syscall not implemented");

	int32_t ret = 0;

	// TODO: Remove debugging printings
	switch (syscallno) {
f010401e:	83 f8 0d             	cmp    $0xd,%eax
f0104021:	0f 87 71 05 00 00    	ja     f0104598 <syscall+0x589>
f0104027:	ff 24 85 cc 73 10 f0 	jmp    *-0xfef8c34(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, 0);
f010402e:	e8 73 16 00 00       	call   f01056a6 <cpunum>
f0104033:	6a 00                	push   $0x0
f0104035:	56                   	push   %esi
f0104036:	ff 75 0c             	pushl  0xc(%ebp)
f0104039:	6b c0 74             	imul   $0x74,%eax,%eax
f010403c:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0104042:	e8 bc ed ff ff       	call   f0102e03 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104047:	83 c4 0c             	add    $0xc,%esp
f010404a:	ff 75 0c             	pushl  0xc(%ebp)
f010404d:	56                   	push   %esi
f010404e:	68 c6 73 10 f0       	push   $0xf01073c6
f0104053:	e8 d9 f5 ff ff       	call   f0103631 <cprintf>
f0104058:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	int32_t ret = 0;
f010405b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104060:	e9 3f 05 00 00       	jmp    f01045a4 <syscall+0x595>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104065:	e8 91 c5 ff ff       	call   f01005fb <cons_getc>
f010406a:	89 c3                	mov    %eax,%ebx
		sys_cputs((char *) a1, (size_t) a2);
		break;
	case SYS_cgetc:
		//cprintf("DEBUG-SYSCALL: Calling sys_cgetc!\n");
		ret = sys_cgetc();
		break;
f010406c:	e9 33 05 00 00       	jmp    f01045a4 <syscall+0x595>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104071:	e8 30 16 00 00       	call   f01056a6 <cpunum>
f0104076:	6b c0 74             	imul   $0x74,%eax,%eax
f0104079:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f010407f:	8b 58 48             	mov    0x48(%eax),%ebx
		ret = sys_cgetc();
		break;
	case SYS_getenvid:
		//cprintf("DEBUG-SYSCALL: Calling sys_getenvid!\n");
		ret = (int32_t) sys_getenvid();
		break;
f0104082:	e9 1d 05 00 00       	jmp    f01045a4 <syscall+0x595>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104087:	83 ec 04             	sub    $0x4,%esp
f010408a:	6a 01                	push   $0x1
f010408c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010408f:	50                   	push   %eax
f0104090:	ff 75 0c             	pushl  0xc(%ebp)
f0104093:	e8 12 ee ff ff       	call   f0102eaa <envid2env>
f0104098:	83 c4 10             	add    $0x10,%esp
		return r;
f010409b:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010409d:	85 c0                	test   %eax,%eax
f010409f:	0f 88 ff 04 00 00    	js     f01045a4 <syscall+0x595>
		return r;
	env_destroy(e);
f01040a5:	83 ec 0c             	sub    $0xc,%esp
f01040a8:	ff 75 e4             	pushl  -0x1c(%ebp)
f01040ab:	e8 c8 f2 ff ff       	call   f0103378 <env_destroy>
f01040b0:	83 c4 10             	add    $0x10,%esp
	return 0;
f01040b3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01040b8:	e9 e7 04 00 00       	jmp    f01045a4 <syscall+0x595>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01040bd:	e8 81 fe ff ff       	call   f0103f43 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	// Tries to allocate new env in e
	struct Env *e;
	int error = env_alloc(&e, curenv->env_id);
f01040c2:	e8 df 15 00 00       	call   f01056a6 <cpunum>
f01040c7:	83 ec 08             	sub    $0x8,%esp
f01040ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01040cd:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f01040d3:	ff 70 48             	pushl  0x48(%eax)
f01040d6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01040d9:	50                   	push   %eax
f01040da:	e8 dd ee ff ff       	call   f0102fbc <env_alloc>
	// Check if it failed, and pass the error. Can be -E_NO_FREE_ENV or -E_NO_MEM
	if (error < 0) {
f01040df:	83 c4 10             	add    $0x10,%esp
		return error;
f01040e2:	89 c3                	mov    %eax,%ebx
	// LAB 4: Your code here.
	// Tries to allocate new env in e
	struct Env *e;
	int error = env_alloc(&e, curenv->env_id);
	// Check if it failed, and pass the error. Can be -E_NO_FREE_ENV or -E_NO_MEM
	if (error < 0) {
f01040e4:	85 c0                	test   %eax,%eax
f01040e6:	0f 88 b8 04 00 00    	js     f01045a4 <syscall+0x595>
		return error;
	}

	e->env_status = ENV_NOT_RUNNABLE;
f01040ec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01040ef:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf; // trap() has copied the tf that is on kstack to curenv
f01040f6:	e8 ab 15 00 00       	call   f01056a6 <cpunum>
f01040fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01040fe:	8b b0 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%esi
f0104104:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104109:	89 df                	mov    %ebx,%edi
f010410b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

	// Tweak the tf so sys_exofork will appear to return 0.
	// eax holds the return value of the system call, so just make it zero.
	e->env_tf.tf_regs.reg_eax = 0;
f010410d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104110:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return e->env_id;
f0104117:	8b 58 48             	mov    0x48(%eax),%ebx
f010411a:	e9 85 04 00 00       	jmp    f01045a4 <syscall+0x595>
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	// Check if the status is valid
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
f010411f:	8d 46 fe             	lea    -0x2(%esi),%eax
f0104122:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104127:	75 28                	jne    f0104151 <syscall+0x142>
		return -E_INVAL;
	}

	// Tries to retrieve the env
	struct Env *e;
	int error = envid2env(envid, &e, 1);
f0104129:	83 ec 04             	sub    $0x4,%esp
f010412c:	6a 01                	push   $0x1
f010412e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104131:	50                   	push   %eax
f0104132:	ff 75 0c             	pushl  0xc(%ebp)
f0104135:	e8 70 ed ff ff       	call   f0102eaa <envid2env>
	if (error < 0) { // If error <0, it is -E_BAD_ENV
f010413a:	83 c4 10             	add    $0x10,%esp
f010413d:	85 c0                	test   %eax,%eax
f010413f:	78 1a                	js     f010415b <syscall+0x14c>
		return error;
	}

	// Set the environment status
	e->env_status = status;
f0104141:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104144:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104147:	bb 00 00 00 00       	mov    $0x0,%ebx
f010414c:	e9 53 04 00 00       	jmp    f01045a4 <syscall+0x595>
	// envid's status.

	// LAB 4: Your code here.
	// Check if the status is valid
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) {
		return -E_INVAL;
f0104151:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104156:	e9 49 04 00 00       	jmp    f01045a4 <syscall+0x595>

	// Tries to retrieve the env
	struct Env *e;
	int error = envid2env(envid, &e, 1);
	if (error < 0) { // If error <0, it is -E_BAD_ENV
		return error;
f010415b:	89 c3                	mov    %eax,%ebx
		ret = (int32_t) sys_exofork();
		break;
	case SYS_env_set_status:
		//cprintf("DEBUG-SYSCALL: Calling sys_env_set_status!\n");
		ret = (int32_t) sys_env_set_status((envid_t) a1, (int) a2);
		break;
f010415d:	e9 42 04 00 00       	jmp    f01045a4 <syscall+0x595>
	//   allocated!

	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
f0104162:	83 ec 04             	sub    $0x4,%esp
f0104165:	6a 01                	push   $0x1
f0104167:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010416a:	50                   	push   %eax
f010416b:	ff 75 0c             	pushl  0xc(%ebp)
f010416e:	e8 37 ed ff ff       	call   f0102eaa <envid2env>
	if (!e) {
f0104173:	83 c4 10             	add    $0x10,%esp
f0104176:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010417a:	74 65                	je     f01041e1 <syscall+0x1d2>
		return -E_BAD_ENV;
	}

	// Checks if va is as expected
	if (((uint32_t)va >= UTOP) || ((uint32_t) va)%PGSIZE != 0) {
f010417c:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104182:	77 67                	ja     f01041eb <syscall+0x1dc>
f0104184:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f010418a:	75 69                	jne    f01041f5 <syscall+0x1e6>
		return -E_INVAL;
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||   // No bit out of PTE_SYSCALL allowed
f010418c:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010418f:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104195:	75 68                	jne    f01041ff <syscall+0x1f0>
f0104197:	f6 45 14 05          	testb  $0x5,0x14(%ebp)
f010419b:	74 6c                	je     f0104209 <syscall+0x1fa>
	    (perm & (PTE_U | PTE_P)) == 0) {  // These bits must be set
		return -E_INVAL;
	}

	// Tries to allocate a physical page
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f010419d:	83 ec 0c             	sub    $0xc,%esp
f01041a0:	6a 01                	push   $0x1
f01041a2:	e8 33 cd ff ff       	call   f0100eda <page_alloc>
f01041a7:	89 c7                	mov    %eax,%edi
	if (!pp) {
f01041a9:	83 c4 10             	add    $0x10,%esp
f01041ac:	85 c0                	test   %eax,%eax
f01041ae:	74 63                	je     f0104213 <syscall+0x204>
		return -E_NO_MEM;
	}

	// Tries to map the physical page at va
	int error = page_insert(e->env_pgdir, pp, va, perm);
f01041b0:	ff 75 14             	pushl  0x14(%ebp)
f01041b3:	56                   	push   %esi
f01041b4:	50                   	push   %eax
f01041b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01041b8:	ff 70 60             	pushl  0x60(%eax)
f01041bb:	e8 58 d0 ff ff       	call   f0101218 <page_insert>
	if (error < 0) {
f01041c0:	83 c4 10             	add    $0x10,%esp
f01041c3:	85 c0                	test   %eax,%eax
f01041c5:	0f 89 d9 03 00 00    	jns    f01045a4 <syscall+0x595>
		page_free(pp);
f01041cb:	83 ec 0c             	sub    $0xc,%esp
f01041ce:	57                   	push   %edi
f01041cf:	e8 76 cd ff ff       	call   f0100f4a <page_free>
f01041d4:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f01041d7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01041dc:	e9 c3 03 00 00       	jmp    f01045a4 <syscall+0x595>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
	if (!e) {
		return -E_BAD_ENV;
f01041e1:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01041e6:	e9 b9 03 00 00       	jmp    f01045a4 <syscall+0x595>
	}

	// Checks if va is as expected
	if (((uint32_t)va >= UTOP) || ((uint32_t) va)%PGSIZE != 0) {
		return -E_INVAL;
f01041eb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01041f0:	e9 af 03 00 00       	jmp    f01045a4 <syscall+0x595>
f01041f5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01041fa:	e9 a5 03 00 00       	jmp    f01045a4 <syscall+0x595>
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||   // No bit out of PTE_SYSCALL allowed
	    (perm & (PTE_U | PTE_P)) == 0) {  // These bits must be set
		return -E_INVAL;
f01041ff:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104204:	e9 9b 03 00 00       	jmp    f01045a4 <syscall+0x595>
f0104209:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010420e:	e9 91 03 00 00       	jmp    f01045a4 <syscall+0x595>
	}

	// Tries to allocate a physical page
	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if (!pp) {
		return -E_NO_MEM;
f0104213:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		ret = (int32_t) sys_env_set_status((envid_t) a1, (int) a2);
		break;
	case SYS_page_alloc:
		//cprintf("DEBUG-SYSCALL: Calling sys_page_alloc!\n");
		ret = (int32_t) sys_page_alloc((envid_t) a1, (void *) a2, (int) a3);
		break;
f0104218:	e9 87 03 00 00       	jmp    f01045a4 <syscall+0x595>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// Tries to retrieve the environments
	struct Env *srcenv, *dstenv;
	envid2env(srcenvid, &srcenv, 1);
f010421d:	83 ec 04             	sub    $0x4,%esp
f0104220:	6a 01                	push   $0x1
f0104222:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104225:	50                   	push   %eax
f0104226:	ff 75 0c             	pushl  0xc(%ebp)
f0104229:	e8 7c ec ff ff       	call   f0102eaa <envid2env>
	envid2env(dstenvid, &dstenv, 1);
f010422e:	83 c4 0c             	add    $0xc,%esp
f0104231:	6a 01                	push   $0x1
f0104233:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104236:	50                   	push   %eax
f0104237:	ff 75 14             	pushl  0x14(%ebp)
f010423a:	e8 6b ec ff ff       	call   f0102eaa <envid2env>
	if (!srcenv || !dstenv) {
f010423f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104242:	83 c4 10             	add    $0x10,%esp
f0104245:	85 c0                	test   %eax,%eax
f0104247:	0f 84 96 00 00 00    	je     f01042e3 <syscall+0x2d4>
f010424d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104251:	0f 84 96 00 00 00    	je     f01042ed <syscall+0x2de>
		return -E_BAD_ENV;
	}

	// Checks if va's are as expected
	if (((uint32_t)srcva) >= UTOP || ((uint32_t) srcva)%PGSIZE != 0 ||
f0104257:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f010425d:	0f 87 94 00 00 00    	ja     f01042f7 <syscall+0x2e8>
f0104263:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104269:	0f 85 92 00 00 00    	jne    f0104301 <syscall+0x2f2>
f010426f:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104276:	0f 87 85 00 00 00    	ja     f0104301 <syscall+0x2f2>
	    ((uint32_t)dstva) >= UTOP || ((uint32_t) dstva)%PGSIZE != 0) {
f010427c:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104283:	0f 85 82 00 00 00    	jne    f010430b <syscall+0x2fc>
	}

	// Lookup for the physical page that is mapped at srcva
	// If srcva is not mapped in srcenv address space, pp is null
	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104289:	83 ec 04             	sub    $0x4,%esp
f010428c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010428f:	52                   	push   %edx
f0104290:	56                   	push   %esi
f0104291:	ff 70 60             	pushl  0x60(%eax)
f0104294:	e8 99 ce ff ff       	call   f0101132 <page_lookup>
	if (!pp) {
f0104299:	83 c4 10             	add    $0x10,%esp
f010429c:	85 c0                	test   %eax,%eax
f010429e:	74 75                	je     f0104315 <syscall+0x306>
		return -E_INVAL;
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||
f01042a0:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f01042a3:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f01042a9:	75 74                	jne    f010431f <syscall+0x310>
f01042ab:	f6 45 1c 05          	testb  $0x5,0x1c(%ebp)
f01042af:	74 78                	je     f0104329 <syscall+0x31a>
		return -E_INVAL;
	}

	// Checks if srcva is read-only in srcenv, and it is trying to
	// permit writing in dstenv
	if (!(*pte & PTE_W) && (perm & PTE_W)) {
f01042b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01042b4:	f6 02 02             	testb  $0x2,(%edx)
f01042b7:	75 06                	jne    f01042bf <syscall+0x2b0>
f01042b9:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01042bd:	75 74                	jne    f0104333 <syscall+0x324>
		return -E_INVAL;
	}

	// Tries to map the physical page at dstva on dstenv address space
	// Fails if there is no memory to allocate a page table, if needed
	int error = page_insert(dstenv->env_pgdir, pp, dstva, perm);
f01042bf:	ff 75 1c             	pushl  0x1c(%ebp)
f01042c2:	ff 75 18             	pushl  0x18(%ebp)
f01042c5:	50                   	push   %eax
f01042c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042c9:	ff 70 60             	pushl  0x60(%eax)
f01042cc:	e8 47 cf ff ff       	call   f0101218 <page_insert>
	if (error < 0) {
f01042d1:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f01042d4:	85 c0                	test   %eax,%eax
f01042d6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01042db:	0f 48 d8             	cmovs  %eax,%ebx
f01042de:	e9 c1 02 00 00       	jmp    f01045a4 <syscall+0x595>
	// Tries to retrieve the environments
	struct Env *srcenv, *dstenv;
	envid2env(srcenvid, &srcenv, 1);
	envid2env(dstenvid, &dstenv, 1);
	if (!srcenv || !dstenv) {
		return -E_BAD_ENV;
f01042e3:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01042e8:	e9 b7 02 00 00       	jmp    f01045a4 <syscall+0x595>
f01042ed:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01042f2:	e9 ad 02 00 00       	jmp    f01045a4 <syscall+0x595>
	}

	// Checks if va's are as expected
	if (((uint32_t)srcva) >= UTOP || ((uint32_t) srcva)%PGSIZE != 0 ||
	    ((uint32_t)dstva) >= UTOP || ((uint32_t) dstva)%PGSIZE != 0) {
		return -E_INVAL;
f01042f7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01042fc:	e9 a3 02 00 00       	jmp    f01045a4 <syscall+0x595>
f0104301:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104306:	e9 99 02 00 00       	jmp    f01045a4 <syscall+0x595>
f010430b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104310:	e9 8f 02 00 00       	jmp    f01045a4 <syscall+0x595>
	// Lookup for the physical page that is mapped at srcva
	// If srcva is not mapped in srcenv address space, pp is null
	pte_t *pte;
	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, &pte);
	if (!pp) {
		return -E_INVAL;
f0104315:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010431a:	e9 85 02 00 00       	jmp    f01045a4 <syscall+0x595>
	}

	// Checks if permission is appropiate
	if ((perm & (~PTE_SYSCALL)) != 0 ||
	    (perm & (PTE_U | PTE_P)) == 0) {
		return -E_INVAL;
f010431f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104324:	e9 7b 02 00 00       	jmp    f01045a4 <syscall+0x595>
f0104329:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010432e:	e9 71 02 00 00       	jmp    f01045a4 <syscall+0x595>
	}

	// Checks if srcva is read-only in srcenv, and it is trying to
	// permit writing in dstenv
	if (!(*pte & PTE_W) && (perm & PTE_W)) {
		return -E_INVAL;
f0104333:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104338:	e9 67 02 00 00       	jmp    f01045a4 <syscall+0x595>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
f010433d:	83 ec 04             	sub    $0x4,%esp
f0104340:	6a 01                	push   $0x1
f0104342:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104345:	50                   	push   %eax
f0104346:	ff 75 0c             	pushl  0xc(%ebp)
f0104349:	e8 5c eb ff ff       	call   f0102eaa <envid2env>
	if (!e) {
f010434e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104351:	83 c4 10             	add    $0x10,%esp
f0104354:	85 c0                	test   %eax,%eax
f0104356:	74 29                	je     f0104381 <syscall+0x372>
		return -E_BAD_ENV;
	}

	// Checks if va is as expected
	if (((uint32_t)va) >= UTOP || ((uint32_t) va)%PGSIZE != 0) {
f0104358:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f010435e:	77 2b                	ja     f010438b <syscall+0x37c>
f0104360:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104366:	75 2d                	jne    f0104395 <syscall+0x386>
		return -E_INVAL;
	}

	// Removes page
	page_remove(e->env_pgdir, va);
f0104368:	83 ec 08             	sub    $0x8,%esp
f010436b:	56                   	push   %esi
f010436c:	ff 70 60             	pushl  0x60(%eax)
f010436f:	e8 5e ce ff ff       	call   f01011d2 <page_remove>
f0104374:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104377:	bb 00 00 00 00       	mov    $0x0,%ebx
f010437c:	e9 23 02 00 00       	jmp    f01045a4 <syscall+0x595>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
	if (!e) {
		return -E_BAD_ENV;
f0104381:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104386:	e9 19 02 00 00       	jmp    f01045a4 <syscall+0x595>
	}

	// Checks if va is as expected
	if (((uint32_t)va) >= UTOP || ((uint32_t) va)%PGSIZE != 0) {
		return -E_INVAL;
f010438b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104390:	e9 0f 02 00 00       	jmp    f01045a4 <syscall+0x595>
f0104395:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
					     (envid_t) a3, (void *) a4, (int) a5);
		break;
	case SYS_page_unmap:
		//cprintf("DEBUG-SYSCALL: Calling sys_page_unmap!\n");
		ret = (int32_t) sys_page_unmap((envid_t) a1, (void *) a2);
		break;
f010439a:	e9 05 02 00 00       	jmp    f01045a4 <syscall+0x595>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
f010439f:	83 ec 04             	sub    $0x4,%esp
f01043a2:	6a 01                	push   $0x1
f01043a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01043a7:	50                   	push   %eax
f01043a8:	ff 75 0c             	pushl  0xc(%ebp)
f01043ab:	e8 fa ea ff ff       	call   f0102eaa <envid2env>
	if (!e) {
f01043b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043b3:	83 c4 10             	add    $0x10,%esp
f01043b6:	85 c0                	test   %eax,%eax
f01043b8:	74 0d                	je     f01043c7 <syscall+0x3b8>
		return -E_BAD_ENV;
	}

	// Set the page fault upcall
	e->env_pgfault_upcall = func;
f01043ba:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f01043bd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01043c2:	e9 dd 01 00 00       	jmp    f01045a4 <syscall+0x595>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 1);
	if (!e) {
		return -E_BAD_ENV;
f01043c7:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		ret = (int32_t) sys_page_unmap((envid_t) a1, (void *) a2);
		break;
	case SYS_env_set_pgfault_upcall:
		//cprintf("DEBUG-SYSCALL: Calling sys_env_set_pgfault_upcall!\n");
		ret = (int32_t) sys_env_set_pgfault_upcall((envid_t) a1, (void *) a2);
		break;
f01043cc:	e9 d3 01 00 00       	jmp    f01045a4 <syscall+0x595>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 0); // Set to 0: can send to anyone
f01043d1:	83 ec 04             	sub    $0x4,%esp
f01043d4:	6a 00                	push   $0x0
f01043d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01043d9:	50                   	push   %eax
f01043da:	ff 75 0c             	pushl  0xc(%ebp)
f01043dd:	e8 c8 ea ff ff       	call   f0102eaa <envid2env>
	if (!e) {
f01043e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01043e5:	83 c4 10             	add    $0x10,%esp
f01043e8:	85 c0                	test   %eax,%eax
f01043ea:	0f 84 f7 00 00 00    	je     f01044e7 <syscall+0x4d8>
		return -E_BAD_ENV;
	}

	// Checks if the receiver is receiving
	if (!e->env_ipc_recving) {
f01043f0:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01043f4:	0f 84 f7 00 00 00    	je     f01044f1 <syscall+0x4e2>
		return -E_IPC_NOT_RECV;
	}

	// If the receiver is accepting a page
	// and the sender is trying to send a page
	if (((uint32_t) e->env_ipc_dstva) < UTOP && ((uint32_t) srcva) < UTOP) {
f01043fa:	81 78 6c ff ff bf ee 	cmpl   $0xeebfffff,0x6c(%eax)
f0104401:	0f 87 a7 00 00 00    	ja     f01044ae <syscall+0x49f>
f0104407:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f010440e:	0f 87 9a 00 00 00    	ja     f01044ae <syscall+0x49f>
		// Checks if va is page aligned
		if (((uint32_t) srcva) % PGSIZE != 0)
			return -E_INVAL;
f0104414:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx

	// If the receiver is accepting a page
	// and the sender is trying to send a page
	if (((uint32_t) e->env_ipc_dstva) < UTOP && ((uint32_t) srcva) < UTOP) {
		// Checks if va is page aligned
		if (((uint32_t) srcva) % PGSIZE != 0)
f0104419:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104420:	0f 85 7e 01 00 00    	jne    f01045a4 <syscall+0x595>
			return -E_INVAL;

		// Checks if permission is appropiate
		if ((perm & (~PTE_SYSCALL)) != 0 ||   // No bit out of PTE_SYSCALL allowed
f0104426:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f010442d:	0f 85 71 01 00 00    	jne    f01045a4 <syscall+0x595>
f0104433:	f6 45 18 05          	testb  $0x5,0x18(%ebp)
f0104437:	0f 84 67 01 00 00    	je     f01045a4 <syscall+0x595>
		}

		// Lookup for the physical page that is mapped at srcva
		// If srcva is not mapped in srcenv address space, pp is null
		pte_t *pte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
f010443d:	e8 64 12 00 00       	call   f01056a6 <cpunum>
f0104442:	83 ec 04             	sub    $0x4,%esp
f0104445:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104448:	52                   	push   %edx
f0104449:	ff 75 14             	pushl  0x14(%ebp)
f010444c:	6b c0 74             	imul   $0x74,%eax,%eax
f010444f:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0104455:	ff 70 60             	pushl  0x60(%eax)
f0104458:	e8 d5 cc ff ff       	call   f0101132 <page_lookup>
		if (!pp) {
f010445d:	83 c4 10             	add    $0x10,%esp
f0104460:	85 c0                	test   %eax,%eax
f0104462:	74 36                	je     f010449a <syscall+0x48b>
			return -E_INVAL;
		}

		// Checks if srcva is read-only in srcenv, and it is trying to
		// permit writing in dstva
		if (!(*pte & PTE_W) && (perm & PTE_W)) {
f0104464:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104467:	f6 02 02             	testb  $0x2,(%edx)
f010446a:	75 0a                	jne    f0104476 <syscall+0x467>
f010446c:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104470:	0f 85 2e 01 00 00    	jne    f01045a4 <syscall+0x595>
			return -E_INVAL;
		}

		// Tries to map the physical page at dstva on dstenv address space
		// Fails if there is no memory to allocate a page table, if needed
		int error = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm);
f0104476:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104479:	ff 75 18             	pushl  0x18(%ebp)
f010447c:	ff 72 6c             	pushl  0x6c(%edx)
f010447f:	50                   	push   %eax
f0104480:	ff 72 60             	pushl  0x60(%edx)
f0104483:	e8 90 cd ff ff       	call   f0101218 <page_insert>
		if (error < 0) {
f0104488:	83 c4 10             	add    $0x10,%esp
f010448b:	85 c0                	test   %eax,%eax
f010448d:	78 15                	js     f01044a4 <syscall+0x495>
			return -E_NO_MEM;
		}

		// Page successfully transfered
		e->env_ipc_perm = perm;
f010448f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104492:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104495:	89 48 78             	mov    %ecx,0x78(%eax)
f0104498:	eb 1b                	jmp    f01044b5 <syscall+0x4a6>
		// Lookup for the physical page that is mapped at srcva
		// If srcva is not mapped in srcenv address space, pp is null
		pte_t *pte;
		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pp) {
			return -E_INVAL;
f010449a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010449f:	e9 00 01 00 00       	jmp    f01045a4 <syscall+0x595>

		// Tries to map the physical page at dstva on dstenv address space
		// Fails if there is no memory to allocate a page table, if needed
		int error = page_insert(e->env_pgdir, pp, e->env_ipc_dstva, perm);
		if (error < 0) {
			return -E_NO_MEM;
f01044a4:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01044a9:	e9 f6 00 00 00       	jmp    f01045a4 <syscall+0x595>

		// Page successfully transfered
		e->env_ipc_perm = perm;
	} else {
	// The receiver isn't accepting a page
		e->env_ipc_perm = 0;
f01044ae:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
	}

	// Deliver 'value' to the receiver
	e->env_ipc_recving = 0;
f01044b5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01044b8:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f01044bc:	e8 e5 11 00 00       	call   f01056a6 <cpunum>
f01044c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c4:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f01044ca:	8b 40 48             	mov    0x48(%eax),%eax
f01044cd:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value;
f01044d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01044d3:	89 70 70             	mov    %esi,0x70(%eax)

	// The receiver has successfully received. Make it runnable
	e->env_status = ENV_RUNNABLE;
f01044d6:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f01044dd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01044e2:	e9 bd 00 00 00       	jmp    f01045a4 <syscall+0x595>
	// LAB 4: Your code here.
	// Tries to retrieve the environment
	struct Env *e;
	envid2env(envid, &e, 0); // Set to 0: can send to anyone
	if (!e) {
		return -E_BAD_ENV;
f01044e7:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01044ec:	e9 b3 00 00 00       	jmp    f01045a4 <syscall+0x595>
	}

	// Checks if the receiver is receiving
	if (!e->env_ipc_recving) {
		return -E_IPC_NOT_RECV;
f01044f1:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
		break;
	case SYS_ipc_try_send:
		//cprintf("DEBUG-SYSCALL: Calling sys_ipc_try_send!\n");
		ret = (int32_t) sys_ipc_try_send((envid_t) a1, (uint32_t) a2,
						   (void*) a3, (unsigned) a4);
		break;
f01044f6:	e9 a9 00 00 00       	jmp    f01045a4 <syscall+0x595>
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// Checks if va is page aligned, given that it is valid
	if (((uint32_t) dstva < UTOP) &&  (((uint32_t) dstva) % PGSIZE != 0)) {
f01044fb:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104502:	77 0d                	ja     f0104511 <syscall+0x502>
f0104504:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f010450b:	0f 85 8e 00 00 00    	jne    f010459f <syscall+0x590>
		return -E_INVAL;
	}

	// Record that you want to receive
	curenv->env_ipc_recving = 1;
f0104511:	e8 90 11 00 00       	call   f01056a6 <cpunum>
f0104516:	6b c0 74             	imul   $0x74,%eax,%eax
f0104519:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f010451f:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104523:	e8 7e 11 00 00       	call   f01056a6 <cpunum>
f0104528:	6b c0 74             	imul   $0x74,%eax,%eax
f010452b:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0104531:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104534:	89 48 6c             	mov    %ecx,0x6c(%eax)

	// Put the return value manually, since this never returns
	curenv->env_tf.tf_regs.reg_eax = 0;
f0104537:	e8 6a 11 00 00       	call   f01056a6 <cpunum>
f010453c:	6b c0 74             	imul   $0x74,%eax,%eax
f010453f:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f0104545:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	// Give up the cpu and wait until receiving
	curenv->env_status = ENV_NOT_RUNNABLE;
f010454c:	e8 55 11 00 00       	call   f01056a6 <cpunum>
f0104551:	6b c0 74             	imul   $0x74,%eax,%eax
f0104554:	8b 80 28 80 20 f0    	mov    -0xfdf7fd8(%eax),%eax
f010455a:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104561:	e8 dd f9 ff ff       	call   f0103f43 <sched_yield>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *e;
	int r;
	if ((r = envid2env(envid, &e, 1))){
f0104566:	83 ec 04             	sub    $0x4,%esp
f0104569:	6a 01                	push   $0x1
f010456b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010456e:	50                   	push   %eax
f010456f:	ff 75 0c             	pushl  0xc(%ebp)
f0104572:	e8 33 e9 ff ff       	call   f0102eaa <envid2env>
f0104577:	83 c4 10             	add    $0x10,%esp
f010457a:	85 c0                	test   %eax,%eax
f010457c:	75 16                	jne    f0104594 <syscall+0x585>
		return r;
	}
	tf->tf_cs |= 0x3;
f010457e:	66 83 4e 34 03       	orw    $0x3,0x34(%esi)
	tf->tf_eflags |= FL_IF;
f0104583:	81 4e 38 00 02 00 00 	orl    $0x200,0x38(%esi)
	e->env_tf = *tf;
f010458a:	b9 11 00 00 00       	mov    $0x11,%ecx
f010458f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104592:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	case SYS_ipc_recv:
		//cprintf("DEBUG-SYSCALL: Calling sys_ipc_recv!\n");
		ret = (int32_t) sys_ipc_recv((void*) a1);
		break;
	case SYS_env_set_trapframe:
		return (int32_t)sys_env_set_trapframe((envid_t) a1, (struct Trapframe *) a2);
f0104594:	89 c3                	mov    %eax,%ebx
f0104596:	eb 0c                	jmp    f01045a4 <syscall+0x595>
		break;	
	default:
		return -E_INVAL;
f0104598:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010459d:	eb 05                	jmp    f01045a4 <syscall+0x595>
		ret = (int32_t) sys_ipc_try_send((envid_t) a1, (uint32_t) a2,
						   (void*) a3, (unsigned) a4);
		break;
	case SYS_ipc_recv:
		//cprintf("DEBUG-SYSCALL: Calling sys_ipc_recv!\n");
		ret = (int32_t) sys_ipc_recv((void*) a1);
f010459f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		break;	
	default:
		return -E_INVAL;
	}
	return ret;
}
f01045a4:	89 d8                	mov    %ebx,%eax
f01045a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01045a9:	5b                   	pop    %ebx
f01045aa:	5e                   	pop    %esi
f01045ab:	5f                   	pop    %edi
f01045ac:	5d                   	pop    %ebp
f01045ad:	c3                   	ret    

f01045ae <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01045ae:	55                   	push   %ebp
f01045af:	89 e5                	mov    %esp,%ebp
f01045b1:	57                   	push   %edi
f01045b2:	56                   	push   %esi
f01045b3:	53                   	push   %ebx
f01045b4:	83 ec 14             	sub    $0x14,%esp
f01045b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01045ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01045bd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01045c0:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01045c3:	8b 1a                	mov    (%edx),%ebx
f01045c5:	8b 01                	mov    (%ecx),%eax
f01045c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01045ca:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01045d1:	eb 7f                	jmp    f0104652 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01045d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01045d6:	01 d8                	add    %ebx,%eax
f01045d8:	89 c6                	mov    %eax,%esi
f01045da:	c1 ee 1f             	shr    $0x1f,%esi
f01045dd:	01 c6                	add    %eax,%esi
f01045df:	d1 fe                	sar    %esi
f01045e1:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01045e4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01045e7:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01045ea:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01045ec:	eb 03                	jmp    f01045f1 <stab_binsearch+0x43>
			m--;
f01045ee:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01045f1:	39 c3                	cmp    %eax,%ebx
f01045f3:	7f 0d                	jg     f0104602 <stab_binsearch+0x54>
f01045f5:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01045f9:	83 ea 0c             	sub    $0xc,%edx
f01045fc:	39 f9                	cmp    %edi,%ecx
f01045fe:	75 ee                	jne    f01045ee <stab_binsearch+0x40>
f0104600:	eb 05                	jmp    f0104607 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104602:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104605:	eb 4b                	jmp    f0104652 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104607:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010460a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010460d:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104611:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104614:	76 11                	jbe    f0104627 <stab_binsearch+0x79>
			*region_left = m;
f0104616:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104619:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010461b:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010461e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104625:	eb 2b                	jmp    f0104652 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104627:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010462a:	73 14                	jae    f0104640 <stab_binsearch+0x92>
			*region_right = m - 1;
f010462c:	83 e8 01             	sub    $0x1,%eax
f010462f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104632:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104635:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104637:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010463e:	eb 12                	jmp    f0104652 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104640:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104643:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104645:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104649:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010464b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104652:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104655:	0f 8e 78 ff ff ff    	jle    f01045d3 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010465b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010465f:	75 0f                	jne    f0104670 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104661:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104664:	8b 00                	mov    (%eax),%eax
f0104666:	83 e8 01             	sub    $0x1,%eax
f0104669:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010466c:	89 06                	mov    %eax,(%esi)
f010466e:	eb 2c                	jmp    f010469c <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104670:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104673:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104675:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104678:	8b 0e                	mov    (%esi),%ecx
f010467a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010467d:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104680:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104683:	eb 03                	jmp    f0104688 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104685:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104688:	39 c8                	cmp    %ecx,%eax
f010468a:	7e 0b                	jle    f0104697 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010468c:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104690:	83 ea 0c             	sub    $0xc,%edx
f0104693:	39 df                	cmp    %ebx,%edi
f0104695:	75 ee                	jne    f0104685 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104697:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010469a:	89 06                	mov    %eax,(%esi)
	}
}
f010469c:	83 c4 14             	add    $0x14,%esp
f010469f:	5b                   	pop    %ebx
f01046a0:	5e                   	pop    %esi
f01046a1:	5f                   	pop    %edi
f01046a2:	5d                   	pop    %ebp
f01046a3:	c3                   	ret    

f01046a4 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01046a4:	55                   	push   %ebp
f01046a5:	89 e5                	mov    %esp,%ebp
f01046a7:	57                   	push   %edi
f01046a8:	56                   	push   %esi
f01046a9:	53                   	push   %ebx
f01046aa:	83 ec 2c             	sub    $0x2c,%esp
f01046ad:	8b 7d 08             	mov    0x8(%ebp),%edi
f01046b0:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01046b3:	c7 06 04 74 10 f0    	movl   $0xf0107404,(%esi)
	info->eip_line = 0;
f01046b9:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01046c0:	c7 46 08 04 74 10 f0 	movl   $0xf0107404,0x8(%esi)
	info->eip_fn_namelen = 9;
f01046c7:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01046ce:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01046d1:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01046d8:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01046de:	0f 87 80 00 00 00    	ja     f0104764 <debuginfo_eip+0xc0>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// TODO: Not sure if it is correct. Should use PTE_U?
		/* Not sure */
		user_mem_check(curenv, usd, 1, PTE_U);
f01046e4:	e8 bd 0f 00 00       	call   f01056a6 <cpunum>
f01046e9:	6a 04                	push   $0x4
f01046eb:	6a 01                	push   $0x1
f01046ed:	68 00 00 20 00       	push   $0x200000
f01046f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046f5:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f01046fb:	e8 5d e6 ff ff       	call   f0102d5d <user_mem_check>
		/* Not sure */

		stabs = usd->stabs;
f0104700:	a1 00 00 20 00       	mov    0x200000,%eax
f0104705:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104708:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f010470e:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104714:	89 55 cc             	mov    %edx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104717:	a1 0c 00 20 00       	mov    0x20000c,%eax
f010471c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		// TODO: Not sure if it is correct. Should use PTE_U?
		/* Not sure */
		int len = (stab_end - stabs) * sizeof(struct Stab);
		user_mem_check(curenv, stabs, len, PTE_U);
f010471f:	e8 82 0f 00 00       	call   f01056a6 <cpunum>
f0104724:	6a 04                	push   $0x4
f0104726:	89 da                	mov    %ebx,%edx
f0104728:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010472b:	29 ca                	sub    %ecx,%edx
f010472d:	52                   	push   %edx
f010472e:	51                   	push   %ecx
f010472f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104732:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f0104738:	e8 20 e6 ff ff       	call   f0102d5d <user_mem_check>

		len = stabstr_end - stabstr;
		user_mem_check(curenv, stabstr, len, PTE_U);
f010473d:	83 c4 20             	add    $0x20,%esp
f0104740:	e8 61 0f 00 00       	call   f01056a6 <cpunum>
f0104745:	6a 04                	push   $0x4
f0104747:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010474a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010474d:	29 ca                	sub    %ecx,%edx
f010474f:	52                   	push   %edx
f0104750:	51                   	push   %ecx
f0104751:	6b c0 74             	imul   $0x74,%eax,%eax
f0104754:	ff b0 28 80 20 f0    	pushl  -0xfdf7fd8(%eax)
f010475a:	e8 fe e5 ff ff       	call   f0102d5d <user_mem_check>
f010475f:	83 c4 10             	add    $0x10,%esp
f0104762:	eb 1a                	jmp    f010477e <debuginfo_eip+0xda>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104764:	c7 45 d0 6d 51 11 f0 	movl   $0xf011516d,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010476b:	c7 45 cc 35 1a 11 f0 	movl   $0xf0111a35,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104772:	bb 34 1a 11 f0       	mov    $0xf0111a34,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104777:	c7 45 d4 90 79 10 f0 	movl   $0xf0107990,-0x2c(%ebp)
		user_mem_check(curenv, stabstr, len, PTE_U);
		/* Not sure */
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010477e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104781:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0104784:	0f 83 32 01 00 00    	jae    f01048bc <debuginfo_eip+0x218>
f010478a:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010478e:	0f 85 2f 01 00 00    	jne    f01048c3 <debuginfo_eip+0x21f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104794:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010479b:	2b 5d d4             	sub    -0x2c(%ebp),%ebx
f010479e:	c1 fb 02             	sar    $0x2,%ebx
f01047a1:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f01047a7:	83 e8 01             	sub    $0x1,%eax
f01047aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01047ad:	83 ec 08             	sub    $0x8,%esp
f01047b0:	57                   	push   %edi
f01047b1:	6a 64                	push   $0x64
f01047b3:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01047b6:	89 d1                	mov    %edx,%ecx
f01047b8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01047bb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01047be:	89 d8                	mov    %ebx,%eax
f01047c0:	e8 e9 fd ff ff       	call   f01045ae <stab_binsearch>
	if (lfile == 0)
f01047c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047c8:	83 c4 10             	add    $0x10,%esp
f01047cb:	85 c0                	test   %eax,%eax
f01047cd:	0f 84 f7 00 00 00    	je     f01048ca <debuginfo_eip+0x226>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01047d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01047d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01047d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01047dc:	83 ec 08             	sub    $0x8,%esp
f01047df:	57                   	push   %edi
f01047e0:	6a 24                	push   $0x24
f01047e2:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01047e5:	89 d1                	mov    %edx,%ecx
f01047e7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01047ea:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01047ed:	89 d8                	mov    %ebx,%eax
f01047ef:	e8 ba fd ff ff       	call   f01045ae <stab_binsearch>

	if (lfun <= rfun) {
f01047f4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01047f7:	83 c4 10             	add    $0x10,%esp
f01047fa:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f01047fd:	7f 24                	jg     f0104823 <debuginfo_eip+0x17f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01047ff:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104802:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104805:	8d 14 87             	lea    (%edi,%eax,4),%edx
f0104808:	8b 02                	mov    (%edx),%eax
f010480a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010480d:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104810:	29 f9                	sub    %edi,%ecx
f0104812:	39 c8                	cmp    %ecx,%eax
f0104814:	73 05                	jae    f010481b <debuginfo_eip+0x177>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104816:	01 f8                	add    %edi,%eax
f0104818:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010481b:	8b 42 08             	mov    0x8(%edx),%eax
f010481e:	89 46 10             	mov    %eax,0x10(%esi)
f0104821:	eb 06                	jmp    f0104829 <debuginfo_eip+0x185>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104823:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104826:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104829:	83 ec 08             	sub    $0x8,%esp
f010482c:	6a 3a                	push   $0x3a
f010482e:	ff 76 08             	pushl  0x8(%esi)
f0104831:	e8 33 08 00 00       	call   f0105069 <strfind>
f0104836:	2b 46 08             	sub    0x8(%esi),%eax
f0104839:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010483c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010483f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104842:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104845:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104848:	83 c4 10             	add    $0x10,%esp
f010484b:	eb 06                	jmp    f0104853 <debuginfo_eip+0x1af>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010484d:	83 eb 01             	sub    $0x1,%ebx
f0104850:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104853:	39 fb                	cmp    %edi,%ebx
f0104855:	7c 2d                	jl     f0104884 <debuginfo_eip+0x1e0>
	       && stabs[lline].n_type != N_SOL
f0104857:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f010485b:	80 fa 84             	cmp    $0x84,%dl
f010485e:	74 0b                	je     f010486b <debuginfo_eip+0x1c7>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104860:	80 fa 64             	cmp    $0x64,%dl
f0104863:	75 e8                	jne    f010484d <debuginfo_eip+0x1a9>
f0104865:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104869:	74 e2                	je     f010484d <debuginfo_eip+0x1a9>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010486b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010486e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104871:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104874:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104877:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010487a:	29 f8                	sub    %edi,%eax
f010487c:	39 c2                	cmp    %eax,%edx
f010487e:	73 04                	jae    f0104884 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104880:	01 fa                	add    %edi,%edx
f0104882:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104884:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104887:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010488a:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010488f:	39 cb                	cmp    %ecx,%ebx
f0104891:	7d 43                	jge    f01048d6 <debuginfo_eip+0x232>
		for (lline = lfun + 1;
f0104893:	8d 53 01             	lea    0x1(%ebx),%edx
f0104896:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104899:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010489c:	8d 04 87             	lea    (%edi,%eax,4),%eax
f010489f:	eb 07                	jmp    f01048a8 <debuginfo_eip+0x204>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01048a1:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01048a5:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01048a8:	39 ca                	cmp    %ecx,%edx
f01048aa:	74 25                	je     f01048d1 <debuginfo_eip+0x22d>
f01048ac:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01048af:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f01048b3:	74 ec                	je     f01048a1 <debuginfo_eip+0x1fd>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01048b5:	b8 00 00 00 00       	mov    $0x0,%eax
f01048ba:	eb 1a                	jmp    f01048d6 <debuginfo_eip+0x232>
		/* Not sure */
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01048bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048c1:	eb 13                	jmp    f01048d6 <debuginfo_eip+0x232>
f01048c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048c8:	eb 0c                	jmp    f01048d6 <debuginfo_eip+0x232>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01048ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01048cf:	eb 05                	jmp    f01048d6 <debuginfo_eip+0x232>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01048d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048d9:	5b                   	pop    %ebx
f01048da:	5e                   	pop    %esi
f01048db:	5f                   	pop    %edi
f01048dc:	5d                   	pop    %ebp
f01048dd:	c3                   	ret    

f01048de <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01048de:	55                   	push   %ebp
f01048df:	89 e5                	mov    %esp,%ebp
f01048e1:	57                   	push   %edi
f01048e2:	56                   	push   %esi
f01048e3:	53                   	push   %ebx
f01048e4:	83 ec 1c             	sub    $0x1c,%esp
f01048e7:	89 c7                	mov    %eax,%edi
f01048e9:	89 d6                	mov    %edx,%esi
f01048eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01048ee:	8b 55 0c             	mov    0xc(%ebp),%edx
f01048f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01048f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01048fa:	bb 00 00 00 00       	mov    $0x0,%ebx
f01048ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104902:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104905:	39 d3                	cmp    %edx,%ebx
f0104907:	72 05                	jb     f010490e <printnum+0x30>
f0104909:	39 45 10             	cmp    %eax,0x10(%ebp)
f010490c:	77 45                	ja     f0104953 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010490e:	83 ec 0c             	sub    $0xc,%esp
f0104911:	ff 75 18             	pushl  0x18(%ebp)
f0104914:	8b 45 14             	mov    0x14(%ebp),%eax
f0104917:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010491a:	53                   	push   %ebx
f010491b:	ff 75 10             	pushl  0x10(%ebp)
f010491e:	83 ec 08             	sub    $0x8,%esp
f0104921:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104924:	ff 75 e0             	pushl  -0x20(%ebp)
f0104927:	ff 75 dc             	pushl  -0x24(%ebp)
f010492a:	ff 75 d8             	pushl  -0x28(%ebp)
f010492d:	e8 6e 11 00 00       	call   f0105aa0 <__udivdi3>
f0104932:	83 c4 18             	add    $0x18,%esp
f0104935:	52                   	push   %edx
f0104936:	50                   	push   %eax
f0104937:	89 f2                	mov    %esi,%edx
f0104939:	89 f8                	mov    %edi,%eax
f010493b:	e8 9e ff ff ff       	call   f01048de <printnum>
f0104940:	83 c4 20             	add    $0x20,%esp
f0104943:	eb 18                	jmp    f010495d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104945:	83 ec 08             	sub    $0x8,%esp
f0104948:	56                   	push   %esi
f0104949:	ff 75 18             	pushl  0x18(%ebp)
f010494c:	ff d7                	call   *%edi
f010494e:	83 c4 10             	add    $0x10,%esp
f0104951:	eb 03                	jmp    f0104956 <printnum+0x78>
f0104953:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104956:	83 eb 01             	sub    $0x1,%ebx
f0104959:	85 db                	test   %ebx,%ebx
f010495b:	7f e8                	jg     f0104945 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010495d:	83 ec 08             	sub    $0x8,%esp
f0104960:	56                   	push   %esi
f0104961:	83 ec 04             	sub    $0x4,%esp
f0104964:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104967:	ff 75 e0             	pushl  -0x20(%ebp)
f010496a:	ff 75 dc             	pushl  -0x24(%ebp)
f010496d:	ff 75 d8             	pushl  -0x28(%ebp)
f0104970:	e8 5b 12 00 00       	call   f0105bd0 <__umoddi3>
f0104975:	83 c4 14             	add    $0x14,%esp
f0104978:	0f be 80 0e 74 10 f0 	movsbl -0xfef8bf2(%eax),%eax
f010497f:	50                   	push   %eax
f0104980:	ff d7                	call   *%edi
}
f0104982:	83 c4 10             	add    $0x10,%esp
f0104985:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104988:	5b                   	pop    %ebx
f0104989:	5e                   	pop    %esi
f010498a:	5f                   	pop    %edi
f010498b:	5d                   	pop    %ebp
f010498c:	c3                   	ret    

f010498d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010498d:	55                   	push   %ebp
f010498e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104990:	83 fa 01             	cmp    $0x1,%edx
f0104993:	7e 0e                	jle    f01049a3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104995:	8b 10                	mov    (%eax),%edx
f0104997:	8d 4a 08             	lea    0x8(%edx),%ecx
f010499a:	89 08                	mov    %ecx,(%eax)
f010499c:	8b 02                	mov    (%edx),%eax
f010499e:	8b 52 04             	mov    0x4(%edx),%edx
f01049a1:	eb 22                	jmp    f01049c5 <getuint+0x38>
	else if (lflag)
f01049a3:	85 d2                	test   %edx,%edx
f01049a5:	74 10                	je     f01049b7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01049a7:	8b 10                	mov    (%eax),%edx
f01049a9:	8d 4a 04             	lea    0x4(%edx),%ecx
f01049ac:	89 08                	mov    %ecx,(%eax)
f01049ae:	8b 02                	mov    (%edx),%eax
f01049b0:	ba 00 00 00 00       	mov    $0x0,%edx
f01049b5:	eb 0e                	jmp    f01049c5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01049b7:	8b 10                	mov    (%eax),%edx
f01049b9:	8d 4a 04             	lea    0x4(%edx),%ecx
f01049bc:	89 08                	mov    %ecx,(%eax)
f01049be:	8b 02                	mov    (%edx),%eax
f01049c0:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01049c5:	5d                   	pop    %ebp
f01049c6:	c3                   	ret    

f01049c7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01049c7:	55                   	push   %ebp
f01049c8:	89 e5                	mov    %esp,%ebp
f01049ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01049cd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01049d1:	8b 10                	mov    (%eax),%edx
f01049d3:	3b 50 04             	cmp    0x4(%eax),%edx
f01049d6:	73 0a                	jae    f01049e2 <sprintputch+0x1b>
		*b->buf++ = ch;
f01049d8:	8d 4a 01             	lea    0x1(%edx),%ecx
f01049db:	89 08                	mov    %ecx,(%eax)
f01049dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01049e0:	88 02                	mov    %al,(%edx)
}
f01049e2:	5d                   	pop    %ebp
f01049e3:	c3                   	ret    

f01049e4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01049e4:	55                   	push   %ebp
f01049e5:	89 e5                	mov    %esp,%ebp
f01049e7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01049ea:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01049ed:	50                   	push   %eax
f01049ee:	ff 75 10             	pushl  0x10(%ebp)
f01049f1:	ff 75 0c             	pushl  0xc(%ebp)
f01049f4:	ff 75 08             	pushl  0x8(%ebp)
f01049f7:	e8 05 00 00 00       	call   f0104a01 <vprintfmt>
	va_end(ap);
}
f01049fc:	83 c4 10             	add    $0x10,%esp
f01049ff:	c9                   	leave  
f0104a00:	c3                   	ret    

f0104a01 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104a01:	55                   	push   %ebp
f0104a02:	89 e5                	mov    %esp,%ebp
f0104a04:	57                   	push   %edi
f0104a05:	56                   	push   %esi
f0104a06:	53                   	push   %ebx
f0104a07:	83 ec 2c             	sub    $0x2c,%esp
f0104a0a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a10:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a13:	eb 12                	jmp    f0104a27 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104a15:	85 c0                	test   %eax,%eax
f0104a17:	0f 84 89 03 00 00    	je     f0104da6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104a1d:	83 ec 08             	sub    $0x8,%esp
f0104a20:	53                   	push   %ebx
f0104a21:	50                   	push   %eax
f0104a22:	ff d6                	call   *%esi
f0104a24:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104a27:	83 c7 01             	add    $0x1,%edi
f0104a2a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104a2e:	83 f8 25             	cmp    $0x25,%eax
f0104a31:	75 e2                	jne    f0104a15 <vprintfmt+0x14>
f0104a33:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104a37:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104a3e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104a45:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104a4c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a51:	eb 07                	jmp    f0104a5a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a53:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104a56:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a5a:	8d 47 01             	lea    0x1(%edi),%eax
f0104a5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104a60:	0f b6 07             	movzbl (%edi),%eax
f0104a63:	0f b6 c8             	movzbl %al,%ecx
f0104a66:	83 e8 23             	sub    $0x23,%eax
f0104a69:	3c 55                	cmp    $0x55,%al
f0104a6b:	0f 87 1a 03 00 00    	ja     f0104d8b <vprintfmt+0x38a>
f0104a71:	0f b6 c0             	movzbl %al,%eax
f0104a74:	ff 24 85 40 75 10 f0 	jmp    *-0xfef8ac0(,%eax,4)
f0104a7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104a7e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104a82:	eb d6                	jmp    f0104a5a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a87:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a8c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104a8f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104a92:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104a96:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104a99:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104a9c:	83 fa 09             	cmp    $0x9,%edx
f0104a9f:	77 39                	ja     f0104ada <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104aa1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104aa4:	eb e9                	jmp    f0104a8f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104aa6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104aa9:	8d 48 04             	lea    0x4(%eax),%ecx
f0104aac:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104aaf:	8b 00                	mov    (%eax),%eax
f0104ab1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ab4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104ab7:	eb 27                	jmp    f0104ae0 <vprintfmt+0xdf>
f0104ab9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104abc:	85 c0                	test   %eax,%eax
f0104abe:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104ac3:	0f 49 c8             	cmovns %eax,%ecx
f0104ac6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ac9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104acc:	eb 8c                	jmp    f0104a5a <vprintfmt+0x59>
f0104ace:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104ad1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104ad8:	eb 80                	jmp    f0104a5a <vprintfmt+0x59>
f0104ada:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104add:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104ae0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104ae4:	0f 89 70 ff ff ff    	jns    f0104a5a <vprintfmt+0x59>
				width = precision, precision = -1;
f0104aea:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104aed:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104af0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104af7:	e9 5e ff ff ff       	jmp    f0104a5a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104afc:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104aff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104b02:	e9 53 ff ff ff       	jmp    f0104a5a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104b07:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b0a:	8d 50 04             	lea    0x4(%eax),%edx
f0104b0d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b10:	83 ec 08             	sub    $0x8,%esp
f0104b13:	53                   	push   %ebx
f0104b14:	ff 30                	pushl  (%eax)
f0104b16:	ff d6                	call   *%esi
			break;
f0104b18:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b1b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104b1e:	e9 04 ff ff ff       	jmp    f0104a27 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104b23:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b26:	8d 50 04             	lea    0x4(%eax),%edx
f0104b29:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b2c:	8b 00                	mov    (%eax),%eax
f0104b2e:	99                   	cltd   
f0104b2f:	31 d0                	xor    %edx,%eax
f0104b31:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104b33:	83 f8 0f             	cmp    $0xf,%eax
f0104b36:	7f 0b                	jg     f0104b43 <vprintfmt+0x142>
f0104b38:	8b 14 85 a0 76 10 f0 	mov    -0xfef8960(,%eax,4),%edx
f0104b3f:	85 d2                	test   %edx,%edx
f0104b41:	75 18                	jne    f0104b5b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104b43:	50                   	push   %eax
f0104b44:	68 26 74 10 f0       	push   $0xf0107426
f0104b49:	53                   	push   %ebx
f0104b4a:	56                   	push   %esi
f0104b4b:	e8 94 fe ff ff       	call   f01049e4 <printfmt>
f0104b50:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104b56:	e9 cc fe ff ff       	jmp    f0104a27 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104b5b:	52                   	push   %edx
f0104b5c:	68 af 6c 10 f0       	push   $0xf0106caf
f0104b61:	53                   	push   %ebx
f0104b62:	56                   	push   %esi
f0104b63:	e8 7c fe ff ff       	call   f01049e4 <printfmt>
f0104b68:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b6e:	e9 b4 fe ff ff       	jmp    f0104a27 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104b73:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b76:	8d 50 04             	lea    0x4(%eax),%edx
f0104b79:	89 55 14             	mov    %edx,0x14(%ebp)
f0104b7c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104b7e:	85 ff                	test   %edi,%edi
f0104b80:	b8 1f 74 10 f0       	mov    $0xf010741f,%eax
f0104b85:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104b88:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104b8c:	0f 8e 94 00 00 00    	jle    f0104c26 <vprintfmt+0x225>
f0104b92:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104b96:	0f 84 98 00 00 00    	je     f0104c34 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b9c:	83 ec 08             	sub    $0x8,%esp
f0104b9f:	ff 75 d0             	pushl  -0x30(%ebp)
f0104ba2:	57                   	push   %edi
f0104ba3:	e8 77 03 00 00       	call   f0104f1f <strnlen>
f0104ba8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104bab:	29 c1                	sub    %eax,%ecx
f0104bad:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104bb0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104bb3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104bb7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104bba:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104bbd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bbf:	eb 0f                	jmp    f0104bd0 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104bc1:	83 ec 08             	sub    $0x8,%esp
f0104bc4:	53                   	push   %ebx
f0104bc5:	ff 75 e0             	pushl  -0x20(%ebp)
f0104bc8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bca:	83 ef 01             	sub    $0x1,%edi
f0104bcd:	83 c4 10             	add    $0x10,%esp
f0104bd0:	85 ff                	test   %edi,%edi
f0104bd2:	7f ed                	jg     f0104bc1 <vprintfmt+0x1c0>
f0104bd4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104bd7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104bda:	85 c9                	test   %ecx,%ecx
f0104bdc:	b8 00 00 00 00       	mov    $0x0,%eax
f0104be1:	0f 49 c1             	cmovns %ecx,%eax
f0104be4:	29 c1                	sub    %eax,%ecx
f0104be6:	89 75 08             	mov    %esi,0x8(%ebp)
f0104be9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104bec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104bef:	89 cb                	mov    %ecx,%ebx
f0104bf1:	eb 4d                	jmp    f0104c40 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104bf3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104bf7:	74 1b                	je     f0104c14 <vprintfmt+0x213>
f0104bf9:	0f be c0             	movsbl %al,%eax
f0104bfc:	83 e8 20             	sub    $0x20,%eax
f0104bff:	83 f8 5e             	cmp    $0x5e,%eax
f0104c02:	76 10                	jbe    f0104c14 <vprintfmt+0x213>
					putch('?', putdat);
f0104c04:	83 ec 08             	sub    $0x8,%esp
f0104c07:	ff 75 0c             	pushl  0xc(%ebp)
f0104c0a:	6a 3f                	push   $0x3f
f0104c0c:	ff 55 08             	call   *0x8(%ebp)
f0104c0f:	83 c4 10             	add    $0x10,%esp
f0104c12:	eb 0d                	jmp    f0104c21 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0104c14:	83 ec 08             	sub    $0x8,%esp
f0104c17:	ff 75 0c             	pushl  0xc(%ebp)
f0104c1a:	52                   	push   %edx
f0104c1b:	ff 55 08             	call   *0x8(%ebp)
f0104c1e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c21:	83 eb 01             	sub    $0x1,%ebx
f0104c24:	eb 1a                	jmp    f0104c40 <vprintfmt+0x23f>
f0104c26:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c29:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c2c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c2f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104c32:	eb 0c                	jmp    f0104c40 <vprintfmt+0x23f>
f0104c34:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c37:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c3a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c3d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104c40:	83 c7 01             	add    $0x1,%edi
f0104c43:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104c47:	0f be d0             	movsbl %al,%edx
f0104c4a:	85 d2                	test   %edx,%edx
f0104c4c:	74 23                	je     f0104c71 <vprintfmt+0x270>
f0104c4e:	85 f6                	test   %esi,%esi
f0104c50:	78 a1                	js     f0104bf3 <vprintfmt+0x1f2>
f0104c52:	83 ee 01             	sub    $0x1,%esi
f0104c55:	79 9c                	jns    f0104bf3 <vprintfmt+0x1f2>
f0104c57:	89 df                	mov    %ebx,%edi
f0104c59:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c5f:	eb 18                	jmp    f0104c79 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104c61:	83 ec 08             	sub    $0x8,%esp
f0104c64:	53                   	push   %ebx
f0104c65:	6a 20                	push   $0x20
f0104c67:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104c69:	83 ef 01             	sub    $0x1,%edi
f0104c6c:	83 c4 10             	add    $0x10,%esp
f0104c6f:	eb 08                	jmp    f0104c79 <vprintfmt+0x278>
f0104c71:	89 df                	mov    %ebx,%edi
f0104c73:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c79:	85 ff                	test   %edi,%edi
f0104c7b:	7f e4                	jg     f0104c61 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c80:	e9 a2 fd ff ff       	jmp    f0104a27 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104c85:	83 fa 01             	cmp    $0x1,%edx
f0104c88:	7e 16                	jle    f0104ca0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0104c8a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c8d:	8d 50 08             	lea    0x8(%eax),%edx
f0104c90:	89 55 14             	mov    %edx,0x14(%ebp)
f0104c93:	8b 50 04             	mov    0x4(%eax),%edx
f0104c96:	8b 00                	mov    (%eax),%eax
f0104c98:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c9b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104c9e:	eb 32                	jmp    f0104cd2 <vprintfmt+0x2d1>
	else if (lflag)
f0104ca0:	85 d2                	test   %edx,%edx
f0104ca2:	74 18                	je     f0104cbc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0104ca4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ca7:	8d 50 04             	lea    0x4(%eax),%edx
f0104caa:	89 55 14             	mov    %edx,0x14(%ebp)
f0104cad:	8b 00                	mov    (%eax),%eax
f0104caf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104cb2:	89 c1                	mov    %eax,%ecx
f0104cb4:	c1 f9 1f             	sar    $0x1f,%ecx
f0104cb7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104cba:	eb 16                	jmp    f0104cd2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0104cbc:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cbf:	8d 50 04             	lea    0x4(%eax),%edx
f0104cc2:	89 55 14             	mov    %edx,0x14(%ebp)
f0104cc5:	8b 00                	mov    (%eax),%eax
f0104cc7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104cca:	89 c1                	mov    %eax,%ecx
f0104ccc:	c1 f9 1f             	sar    $0x1f,%ecx
f0104ccf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104cd2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104cd5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104cd8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104cdd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104ce1:	79 74                	jns    f0104d57 <vprintfmt+0x356>
				putch('-', putdat);
f0104ce3:	83 ec 08             	sub    $0x8,%esp
f0104ce6:	53                   	push   %ebx
f0104ce7:	6a 2d                	push   $0x2d
f0104ce9:	ff d6                	call   *%esi
				num = -(long long) num;
f0104ceb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104cee:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104cf1:	f7 d8                	neg    %eax
f0104cf3:	83 d2 00             	adc    $0x0,%edx
f0104cf6:	f7 da                	neg    %edx
f0104cf8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104cfb:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0104d00:	eb 55                	jmp    f0104d57 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104d02:	8d 45 14             	lea    0x14(%ebp),%eax
f0104d05:	e8 83 fc ff ff       	call   f010498d <getuint>
			base = 10;
f0104d0a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0104d0f:	eb 46                	jmp    f0104d57 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0104d11:	8d 45 14             	lea    0x14(%ebp),%eax
f0104d14:	e8 74 fc ff ff       	call   f010498d <getuint>
                        base = 8;
f0104d19:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f0104d1e:	eb 37                	jmp    f0104d57 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0104d20:	83 ec 08             	sub    $0x8,%esp
f0104d23:	53                   	push   %ebx
f0104d24:	6a 30                	push   $0x30
f0104d26:	ff d6                	call   *%esi
			putch('x', putdat);
f0104d28:	83 c4 08             	add    $0x8,%esp
f0104d2b:	53                   	push   %ebx
f0104d2c:	6a 78                	push   $0x78
f0104d2e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104d30:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d33:	8d 50 04             	lea    0x4(%eax),%edx
f0104d36:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104d39:	8b 00                	mov    (%eax),%eax
f0104d3b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104d40:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104d43:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0104d48:	eb 0d                	jmp    f0104d57 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104d4a:	8d 45 14             	lea    0x14(%ebp),%eax
f0104d4d:	e8 3b fc ff ff       	call   f010498d <getuint>
			base = 16;
f0104d52:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104d57:	83 ec 0c             	sub    $0xc,%esp
f0104d5a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104d5e:	57                   	push   %edi
f0104d5f:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d62:	51                   	push   %ecx
f0104d63:	52                   	push   %edx
f0104d64:	50                   	push   %eax
f0104d65:	89 da                	mov    %ebx,%edx
f0104d67:	89 f0                	mov    %esi,%eax
f0104d69:	e8 70 fb ff ff       	call   f01048de <printnum>
			break;
f0104d6e:	83 c4 20             	add    $0x20,%esp
f0104d71:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d74:	e9 ae fc ff ff       	jmp    f0104a27 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104d79:	83 ec 08             	sub    $0x8,%esp
f0104d7c:	53                   	push   %ebx
f0104d7d:	51                   	push   %ecx
f0104d7e:	ff d6                	call   *%esi
			break;
f0104d80:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104d86:	e9 9c fc ff ff       	jmp    f0104a27 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104d8b:	83 ec 08             	sub    $0x8,%esp
f0104d8e:	53                   	push   %ebx
f0104d8f:	6a 25                	push   $0x25
f0104d91:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104d93:	83 c4 10             	add    $0x10,%esp
f0104d96:	eb 03                	jmp    f0104d9b <vprintfmt+0x39a>
f0104d98:	83 ef 01             	sub    $0x1,%edi
f0104d9b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104d9f:	75 f7                	jne    f0104d98 <vprintfmt+0x397>
f0104da1:	e9 81 fc ff ff       	jmp    f0104a27 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104da9:	5b                   	pop    %ebx
f0104daa:	5e                   	pop    %esi
f0104dab:	5f                   	pop    %edi
f0104dac:	5d                   	pop    %ebp
f0104dad:	c3                   	ret    

f0104dae <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104dae:	55                   	push   %ebp
f0104daf:	89 e5                	mov    %esp,%ebp
f0104db1:	83 ec 18             	sub    $0x18,%esp
f0104db4:	8b 45 08             	mov    0x8(%ebp),%eax
f0104db7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104dba:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104dbd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104dc1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104dc4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104dcb:	85 c0                	test   %eax,%eax
f0104dcd:	74 26                	je     f0104df5 <vsnprintf+0x47>
f0104dcf:	85 d2                	test   %edx,%edx
f0104dd1:	7e 22                	jle    f0104df5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104dd3:	ff 75 14             	pushl  0x14(%ebp)
f0104dd6:	ff 75 10             	pushl  0x10(%ebp)
f0104dd9:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104ddc:	50                   	push   %eax
f0104ddd:	68 c7 49 10 f0       	push   $0xf01049c7
f0104de2:	e8 1a fc ff ff       	call   f0104a01 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104de7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104dea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104df0:	83 c4 10             	add    $0x10,%esp
f0104df3:	eb 05                	jmp    f0104dfa <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104df5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104dfa:	c9                   	leave  
f0104dfb:	c3                   	ret    

f0104dfc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104dfc:	55                   	push   %ebp
f0104dfd:	89 e5                	mov    %esp,%ebp
f0104dff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104e02:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104e05:	50                   	push   %eax
f0104e06:	ff 75 10             	pushl  0x10(%ebp)
f0104e09:	ff 75 0c             	pushl  0xc(%ebp)
f0104e0c:	ff 75 08             	pushl  0x8(%ebp)
f0104e0f:	e8 9a ff ff ff       	call   f0104dae <vsnprintf>
	va_end(ap);

	return rc;
}
f0104e14:	c9                   	leave  
f0104e15:	c3                   	ret    

f0104e16 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104e16:	55                   	push   %ebp
f0104e17:	89 e5                	mov    %esp,%ebp
f0104e19:	57                   	push   %edi
f0104e1a:	56                   	push   %esi
f0104e1b:	53                   	push   %ebx
f0104e1c:	83 ec 0c             	sub    $0xc,%esp
f0104e1f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0104e22:	85 c0                	test   %eax,%eax
f0104e24:	74 11                	je     f0104e37 <readline+0x21>
		cprintf("%s", prompt);
f0104e26:	83 ec 08             	sub    $0x8,%esp
f0104e29:	50                   	push   %eax
f0104e2a:	68 af 6c 10 f0       	push   $0xf0106caf
f0104e2f:	e8 fd e7 ff ff       	call   f0103631 <cprintf>
f0104e34:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0104e37:	83 ec 0c             	sub    $0xc,%esp
f0104e3a:	6a 00                	push   $0x0
f0104e3c:	e8 6b b9 ff ff       	call   f01007ac <iscons>
f0104e41:	89 c7                	mov    %eax,%edi
f0104e43:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0104e46:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104e4b:	e8 4b b9 ff ff       	call   f010079b <getchar>
f0104e50:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104e52:	85 c0                	test   %eax,%eax
f0104e54:	79 29                	jns    f0104e7f <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0104e56:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0104e5b:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0104e5e:	0f 84 9b 00 00 00    	je     f0104eff <readline+0xe9>
				cprintf("read error: %e\n", c);
f0104e64:	83 ec 08             	sub    $0x8,%esp
f0104e67:	53                   	push   %ebx
f0104e68:	68 ff 76 10 f0       	push   $0xf01076ff
f0104e6d:	e8 bf e7 ff ff       	call   f0103631 <cprintf>
f0104e72:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0104e75:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e7a:	e9 80 00 00 00       	jmp    f0104eff <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104e7f:	83 f8 08             	cmp    $0x8,%eax
f0104e82:	0f 94 c2             	sete   %dl
f0104e85:	83 f8 7f             	cmp    $0x7f,%eax
f0104e88:	0f 94 c0             	sete   %al
f0104e8b:	08 c2                	or     %al,%dl
f0104e8d:	74 1a                	je     f0104ea9 <readline+0x93>
f0104e8f:	85 f6                	test   %esi,%esi
f0104e91:	7e 16                	jle    f0104ea9 <readline+0x93>
			if (echoing)
f0104e93:	85 ff                	test   %edi,%edi
f0104e95:	74 0d                	je     f0104ea4 <readline+0x8e>
				cputchar('\b');
f0104e97:	83 ec 0c             	sub    $0xc,%esp
f0104e9a:	6a 08                	push   $0x8
f0104e9c:	e8 ea b8 ff ff       	call   f010078b <cputchar>
f0104ea1:	83 c4 10             	add    $0x10,%esp
			i--;
f0104ea4:	83 ee 01             	sub    $0x1,%esi
f0104ea7:	eb a2                	jmp    f0104e4b <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104ea9:	83 fb 1f             	cmp    $0x1f,%ebx
f0104eac:	7e 26                	jle    f0104ed4 <readline+0xbe>
f0104eae:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104eb4:	7f 1e                	jg     f0104ed4 <readline+0xbe>
			if (echoing)
f0104eb6:	85 ff                	test   %edi,%edi
f0104eb8:	74 0c                	je     f0104ec6 <readline+0xb0>
				cputchar(c);
f0104eba:	83 ec 0c             	sub    $0xc,%esp
f0104ebd:	53                   	push   %ebx
f0104ebe:	e8 c8 b8 ff ff       	call   f010078b <cputchar>
f0104ec3:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104ec6:	88 9e 80 7a 20 f0    	mov    %bl,-0xfdf8580(%esi)
f0104ecc:	8d 76 01             	lea    0x1(%esi),%esi
f0104ecf:	e9 77 ff ff ff       	jmp    f0104e4b <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104ed4:	83 fb 0a             	cmp    $0xa,%ebx
f0104ed7:	74 09                	je     f0104ee2 <readline+0xcc>
f0104ed9:	83 fb 0d             	cmp    $0xd,%ebx
f0104edc:	0f 85 69 ff ff ff    	jne    f0104e4b <readline+0x35>
			if (echoing)
f0104ee2:	85 ff                	test   %edi,%edi
f0104ee4:	74 0d                	je     f0104ef3 <readline+0xdd>
				cputchar('\n');
f0104ee6:	83 ec 0c             	sub    $0xc,%esp
f0104ee9:	6a 0a                	push   $0xa
f0104eeb:	e8 9b b8 ff ff       	call   f010078b <cputchar>
f0104ef0:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104ef3:	c6 86 80 7a 20 f0 00 	movb   $0x0,-0xfdf8580(%esi)
			return buf;
f0104efa:	b8 80 7a 20 f0       	mov    $0xf0207a80,%eax
		}
	}
}
f0104eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f02:	5b                   	pop    %ebx
f0104f03:	5e                   	pop    %esi
f0104f04:	5f                   	pop    %edi
f0104f05:	5d                   	pop    %ebp
f0104f06:	c3                   	ret    

f0104f07 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104f07:	55                   	push   %ebp
f0104f08:	89 e5                	mov    %esp,%ebp
f0104f0a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104f0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f12:	eb 03                	jmp    f0104f17 <strlen+0x10>
		n++;
f0104f14:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104f17:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104f1b:	75 f7                	jne    f0104f14 <strlen+0xd>
		n++;
	return n;
}
f0104f1d:	5d                   	pop    %ebp
f0104f1e:	c3                   	ret    

f0104f1f <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104f1f:	55                   	push   %ebp
f0104f20:	89 e5                	mov    %esp,%ebp
f0104f22:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f25:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104f28:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f2d:	eb 03                	jmp    f0104f32 <strnlen+0x13>
		n++;
f0104f2f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104f32:	39 c2                	cmp    %eax,%edx
f0104f34:	74 08                	je     f0104f3e <strnlen+0x1f>
f0104f36:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104f3a:	75 f3                	jne    f0104f2f <strnlen+0x10>
f0104f3c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104f3e:	5d                   	pop    %ebp
f0104f3f:	c3                   	ret    

f0104f40 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104f40:	55                   	push   %ebp
f0104f41:	89 e5                	mov    %esp,%ebp
f0104f43:	53                   	push   %ebx
f0104f44:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104f4a:	89 c2                	mov    %eax,%edx
f0104f4c:	83 c2 01             	add    $0x1,%edx
f0104f4f:	83 c1 01             	add    $0x1,%ecx
f0104f52:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104f56:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104f59:	84 db                	test   %bl,%bl
f0104f5b:	75 ef                	jne    f0104f4c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104f5d:	5b                   	pop    %ebx
f0104f5e:	5d                   	pop    %ebp
f0104f5f:	c3                   	ret    

f0104f60 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104f60:	55                   	push   %ebp
f0104f61:	89 e5                	mov    %esp,%ebp
f0104f63:	53                   	push   %ebx
f0104f64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104f67:	53                   	push   %ebx
f0104f68:	e8 9a ff ff ff       	call   f0104f07 <strlen>
f0104f6d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104f70:	ff 75 0c             	pushl  0xc(%ebp)
f0104f73:	01 d8                	add    %ebx,%eax
f0104f75:	50                   	push   %eax
f0104f76:	e8 c5 ff ff ff       	call   f0104f40 <strcpy>
	return dst;
}
f0104f7b:	89 d8                	mov    %ebx,%eax
f0104f7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104f80:	c9                   	leave  
f0104f81:	c3                   	ret    

f0104f82 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104f82:	55                   	push   %ebp
f0104f83:	89 e5                	mov    %esp,%ebp
f0104f85:	56                   	push   %esi
f0104f86:	53                   	push   %ebx
f0104f87:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104f8d:	89 f3                	mov    %esi,%ebx
f0104f8f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104f92:	89 f2                	mov    %esi,%edx
f0104f94:	eb 0f                	jmp    f0104fa5 <strncpy+0x23>
		*dst++ = *src;
f0104f96:	83 c2 01             	add    $0x1,%edx
f0104f99:	0f b6 01             	movzbl (%ecx),%eax
f0104f9c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104f9f:	80 39 01             	cmpb   $0x1,(%ecx)
f0104fa2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104fa5:	39 da                	cmp    %ebx,%edx
f0104fa7:	75 ed                	jne    f0104f96 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104fa9:	89 f0                	mov    %esi,%eax
f0104fab:	5b                   	pop    %ebx
f0104fac:	5e                   	pop    %esi
f0104fad:	5d                   	pop    %ebp
f0104fae:	c3                   	ret    

f0104faf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104faf:	55                   	push   %ebp
f0104fb0:	89 e5                	mov    %esp,%ebp
f0104fb2:	56                   	push   %esi
f0104fb3:	53                   	push   %ebx
f0104fb4:	8b 75 08             	mov    0x8(%ebp),%esi
f0104fb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104fba:	8b 55 10             	mov    0x10(%ebp),%edx
f0104fbd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104fbf:	85 d2                	test   %edx,%edx
f0104fc1:	74 21                	je     f0104fe4 <strlcpy+0x35>
f0104fc3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104fc7:	89 f2                	mov    %esi,%edx
f0104fc9:	eb 09                	jmp    f0104fd4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104fcb:	83 c2 01             	add    $0x1,%edx
f0104fce:	83 c1 01             	add    $0x1,%ecx
f0104fd1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104fd4:	39 c2                	cmp    %eax,%edx
f0104fd6:	74 09                	je     f0104fe1 <strlcpy+0x32>
f0104fd8:	0f b6 19             	movzbl (%ecx),%ebx
f0104fdb:	84 db                	test   %bl,%bl
f0104fdd:	75 ec                	jne    f0104fcb <strlcpy+0x1c>
f0104fdf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104fe1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104fe4:	29 f0                	sub    %esi,%eax
}
f0104fe6:	5b                   	pop    %ebx
f0104fe7:	5e                   	pop    %esi
f0104fe8:	5d                   	pop    %ebp
f0104fe9:	c3                   	ret    

f0104fea <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104fea:	55                   	push   %ebp
f0104feb:	89 e5                	mov    %esp,%ebp
f0104fed:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104ff0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104ff3:	eb 06                	jmp    f0104ffb <strcmp+0x11>
		p++, q++;
f0104ff5:	83 c1 01             	add    $0x1,%ecx
f0104ff8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104ffb:	0f b6 01             	movzbl (%ecx),%eax
f0104ffe:	84 c0                	test   %al,%al
f0105000:	74 04                	je     f0105006 <strcmp+0x1c>
f0105002:	3a 02                	cmp    (%edx),%al
f0105004:	74 ef                	je     f0104ff5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105006:	0f b6 c0             	movzbl %al,%eax
f0105009:	0f b6 12             	movzbl (%edx),%edx
f010500c:	29 d0                	sub    %edx,%eax
}
f010500e:	5d                   	pop    %ebp
f010500f:	c3                   	ret    

f0105010 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105010:	55                   	push   %ebp
f0105011:	89 e5                	mov    %esp,%ebp
f0105013:	53                   	push   %ebx
f0105014:	8b 45 08             	mov    0x8(%ebp),%eax
f0105017:	8b 55 0c             	mov    0xc(%ebp),%edx
f010501a:	89 c3                	mov    %eax,%ebx
f010501c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010501f:	eb 06                	jmp    f0105027 <strncmp+0x17>
		n--, p++, q++;
f0105021:	83 c0 01             	add    $0x1,%eax
f0105024:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105027:	39 d8                	cmp    %ebx,%eax
f0105029:	74 15                	je     f0105040 <strncmp+0x30>
f010502b:	0f b6 08             	movzbl (%eax),%ecx
f010502e:	84 c9                	test   %cl,%cl
f0105030:	74 04                	je     f0105036 <strncmp+0x26>
f0105032:	3a 0a                	cmp    (%edx),%cl
f0105034:	74 eb                	je     f0105021 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105036:	0f b6 00             	movzbl (%eax),%eax
f0105039:	0f b6 12             	movzbl (%edx),%edx
f010503c:	29 d0                	sub    %edx,%eax
f010503e:	eb 05                	jmp    f0105045 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105040:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105045:	5b                   	pop    %ebx
f0105046:	5d                   	pop    %ebp
f0105047:	c3                   	ret    

f0105048 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105048:	55                   	push   %ebp
f0105049:	89 e5                	mov    %esp,%ebp
f010504b:	8b 45 08             	mov    0x8(%ebp),%eax
f010504e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105052:	eb 07                	jmp    f010505b <strchr+0x13>
		if (*s == c)
f0105054:	38 ca                	cmp    %cl,%dl
f0105056:	74 0f                	je     f0105067 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105058:	83 c0 01             	add    $0x1,%eax
f010505b:	0f b6 10             	movzbl (%eax),%edx
f010505e:	84 d2                	test   %dl,%dl
f0105060:	75 f2                	jne    f0105054 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105062:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105067:	5d                   	pop    %ebp
f0105068:	c3                   	ret    

f0105069 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105069:	55                   	push   %ebp
f010506a:	89 e5                	mov    %esp,%ebp
f010506c:	8b 45 08             	mov    0x8(%ebp),%eax
f010506f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105073:	eb 03                	jmp    f0105078 <strfind+0xf>
f0105075:	83 c0 01             	add    $0x1,%eax
f0105078:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010507b:	38 ca                	cmp    %cl,%dl
f010507d:	74 04                	je     f0105083 <strfind+0x1a>
f010507f:	84 d2                	test   %dl,%dl
f0105081:	75 f2                	jne    f0105075 <strfind+0xc>
			break;
	return (char *) s;
}
f0105083:	5d                   	pop    %ebp
f0105084:	c3                   	ret    

f0105085 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105085:	55                   	push   %ebp
f0105086:	89 e5                	mov    %esp,%ebp
f0105088:	57                   	push   %edi
f0105089:	56                   	push   %esi
f010508a:	53                   	push   %ebx
f010508b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010508e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105091:	85 c9                	test   %ecx,%ecx
f0105093:	74 36                	je     f01050cb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105095:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010509b:	75 28                	jne    f01050c5 <memset+0x40>
f010509d:	f6 c1 03             	test   $0x3,%cl
f01050a0:	75 23                	jne    f01050c5 <memset+0x40>
		c &= 0xFF;
f01050a2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01050a6:	89 d3                	mov    %edx,%ebx
f01050a8:	c1 e3 08             	shl    $0x8,%ebx
f01050ab:	89 d6                	mov    %edx,%esi
f01050ad:	c1 e6 18             	shl    $0x18,%esi
f01050b0:	89 d0                	mov    %edx,%eax
f01050b2:	c1 e0 10             	shl    $0x10,%eax
f01050b5:	09 f0                	or     %esi,%eax
f01050b7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01050b9:	89 d8                	mov    %ebx,%eax
f01050bb:	09 d0                	or     %edx,%eax
f01050bd:	c1 e9 02             	shr    $0x2,%ecx
f01050c0:	fc                   	cld    
f01050c1:	f3 ab                	rep stos %eax,%es:(%edi)
f01050c3:	eb 06                	jmp    f01050cb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01050c5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01050c8:	fc                   	cld    
f01050c9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01050cb:	89 f8                	mov    %edi,%eax
f01050cd:	5b                   	pop    %ebx
f01050ce:	5e                   	pop    %esi
f01050cf:	5f                   	pop    %edi
f01050d0:	5d                   	pop    %ebp
f01050d1:	c3                   	ret    

f01050d2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01050d2:	55                   	push   %ebp
f01050d3:	89 e5                	mov    %esp,%ebp
f01050d5:	57                   	push   %edi
f01050d6:	56                   	push   %esi
f01050d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01050da:	8b 75 0c             	mov    0xc(%ebp),%esi
f01050dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01050e0:	39 c6                	cmp    %eax,%esi
f01050e2:	73 35                	jae    f0105119 <memmove+0x47>
f01050e4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01050e7:	39 d0                	cmp    %edx,%eax
f01050e9:	73 2e                	jae    f0105119 <memmove+0x47>
		s += n;
		d += n;
f01050eb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01050ee:	89 d6                	mov    %edx,%esi
f01050f0:	09 fe                	or     %edi,%esi
f01050f2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01050f8:	75 13                	jne    f010510d <memmove+0x3b>
f01050fa:	f6 c1 03             	test   $0x3,%cl
f01050fd:	75 0e                	jne    f010510d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01050ff:	83 ef 04             	sub    $0x4,%edi
f0105102:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105105:	c1 e9 02             	shr    $0x2,%ecx
f0105108:	fd                   	std    
f0105109:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010510b:	eb 09                	jmp    f0105116 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010510d:	83 ef 01             	sub    $0x1,%edi
f0105110:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105113:	fd                   	std    
f0105114:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105116:	fc                   	cld    
f0105117:	eb 1d                	jmp    f0105136 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105119:	89 f2                	mov    %esi,%edx
f010511b:	09 c2                	or     %eax,%edx
f010511d:	f6 c2 03             	test   $0x3,%dl
f0105120:	75 0f                	jne    f0105131 <memmove+0x5f>
f0105122:	f6 c1 03             	test   $0x3,%cl
f0105125:	75 0a                	jne    f0105131 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105127:	c1 e9 02             	shr    $0x2,%ecx
f010512a:	89 c7                	mov    %eax,%edi
f010512c:	fc                   	cld    
f010512d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010512f:	eb 05                	jmp    f0105136 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105131:	89 c7                	mov    %eax,%edi
f0105133:	fc                   	cld    
f0105134:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105136:	5e                   	pop    %esi
f0105137:	5f                   	pop    %edi
f0105138:	5d                   	pop    %ebp
f0105139:	c3                   	ret    

f010513a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010513a:	55                   	push   %ebp
f010513b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010513d:	ff 75 10             	pushl  0x10(%ebp)
f0105140:	ff 75 0c             	pushl  0xc(%ebp)
f0105143:	ff 75 08             	pushl  0x8(%ebp)
f0105146:	e8 87 ff ff ff       	call   f01050d2 <memmove>
}
f010514b:	c9                   	leave  
f010514c:	c3                   	ret    

f010514d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010514d:	55                   	push   %ebp
f010514e:	89 e5                	mov    %esp,%ebp
f0105150:	56                   	push   %esi
f0105151:	53                   	push   %ebx
f0105152:	8b 45 08             	mov    0x8(%ebp),%eax
f0105155:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105158:	89 c6                	mov    %eax,%esi
f010515a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010515d:	eb 1a                	jmp    f0105179 <memcmp+0x2c>
		if (*s1 != *s2)
f010515f:	0f b6 08             	movzbl (%eax),%ecx
f0105162:	0f b6 1a             	movzbl (%edx),%ebx
f0105165:	38 d9                	cmp    %bl,%cl
f0105167:	74 0a                	je     f0105173 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105169:	0f b6 c1             	movzbl %cl,%eax
f010516c:	0f b6 db             	movzbl %bl,%ebx
f010516f:	29 d8                	sub    %ebx,%eax
f0105171:	eb 0f                	jmp    f0105182 <memcmp+0x35>
		s1++, s2++;
f0105173:	83 c0 01             	add    $0x1,%eax
f0105176:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105179:	39 f0                	cmp    %esi,%eax
f010517b:	75 e2                	jne    f010515f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010517d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105182:	5b                   	pop    %ebx
f0105183:	5e                   	pop    %esi
f0105184:	5d                   	pop    %ebp
f0105185:	c3                   	ret    

f0105186 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105186:	55                   	push   %ebp
f0105187:	89 e5                	mov    %esp,%ebp
f0105189:	53                   	push   %ebx
f010518a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010518d:	89 c1                	mov    %eax,%ecx
f010518f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105192:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105196:	eb 0a                	jmp    f01051a2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105198:	0f b6 10             	movzbl (%eax),%edx
f010519b:	39 da                	cmp    %ebx,%edx
f010519d:	74 07                	je     f01051a6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010519f:	83 c0 01             	add    $0x1,%eax
f01051a2:	39 c8                	cmp    %ecx,%eax
f01051a4:	72 f2                	jb     f0105198 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01051a6:	5b                   	pop    %ebx
f01051a7:	5d                   	pop    %ebp
f01051a8:	c3                   	ret    

f01051a9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01051a9:	55                   	push   %ebp
f01051aa:	89 e5                	mov    %esp,%ebp
f01051ac:	57                   	push   %edi
f01051ad:	56                   	push   %esi
f01051ae:	53                   	push   %ebx
f01051af:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01051b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01051b5:	eb 03                	jmp    f01051ba <strtol+0x11>
		s++;
f01051b7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01051ba:	0f b6 01             	movzbl (%ecx),%eax
f01051bd:	3c 20                	cmp    $0x20,%al
f01051bf:	74 f6                	je     f01051b7 <strtol+0xe>
f01051c1:	3c 09                	cmp    $0x9,%al
f01051c3:	74 f2                	je     f01051b7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01051c5:	3c 2b                	cmp    $0x2b,%al
f01051c7:	75 0a                	jne    f01051d3 <strtol+0x2a>
		s++;
f01051c9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01051cc:	bf 00 00 00 00       	mov    $0x0,%edi
f01051d1:	eb 11                	jmp    f01051e4 <strtol+0x3b>
f01051d3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01051d8:	3c 2d                	cmp    $0x2d,%al
f01051da:	75 08                	jne    f01051e4 <strtol+0x3b>
		s++, neg = 1;
f01051dc:	83 c1 01             	add    $0x1,%ecx
f01051df:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01051e4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01051ea:	75 15                	jne    f0105201 <strtol+0x58>
f01051ec:	80 39 30             	cmpb   $0x30,(%ecx)
f01051ef:	75 10                	jne    f0105201 <strtol+0x58>
f01051f1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01051f5:	75 7c                	jne    f0105273 <strtol+0xca>
		s += 2, base = 16;
f01051f7:	83 c1 02             	add    $0x2,%ecx
f01051fa:	bb 10 00 00 00       	mov    $0x10,%ebx
f01051ff:	eb 16                	jmp    f0105217 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105201:	85 db                	test   %ebx,%ebx
f0105203:	75 12                	jne    f0105217 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105205:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010520a:	80 39 30             	cmpb   $0x30,(%ecx)
f010520d:	75 08                	jne    f0105217 <strtol+0x6e>
		s++, base = 8;
f010520f:	83 c1 01             	add    $0x1,%ecx
f0105212:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105217:	b8 00 00 00 00       	mov    $0x0,%eax
f010521c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010521f:	0f b6 11             	movzbl (%ecx),%edx
f0105222:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105225:	89 f3                	mov    %esi,%ebx
f0105227:	80 fb 09             	cmp    $0x9,%bl
f010522a:	77 08                	ja     f0105234 <strtol+0x8b>
			dig = *s - '0';
f010522c:	0f be d2             	movsbl %dl,%edx
f010522f:	83 ea 30             	sub    $0x30,%edx
f0105232:	eb 22                	jmp    f0105256 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105234:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105237:	89 f3                	mov    %esi,%ebx
f0105239:	80 fb 19             	cmp    $0x19,%bl
f010523c:	77 08                	ja     f0105246 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010523e:	0f be d2             	movsbl %dl,%edx
f0105241:	83 ea 57             	sub    $0x57,%edx
f0105244:	eb 10                	jmp    f0105256 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105246:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105249:	89 f3                	mov    %esi,%ebx
f010524b:	80 fb 19             	cmp    $0x19,%bl
f010524e:	77 16                	ja     f0105266 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105250:	0f be d2             	movsbl %dl,%edx
f0105253:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105256:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105259:	7d 0b                	jge    f0105266 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010525b:	83 c1 01             	add    $0x1,%ecx
f010525e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105262:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105264:	eb b9                	jmp    f010521f <strtol+0x76>

	if (endptr)
f0105266:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010526a:	74 0d                	je     f0105279 <strtol+0xd0>
		*endptr = (char *) s;
f010526c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010526f:	89 0e                	mov    %ecx,(%esi)
f0105271:	eb 06                	jmp    f0105279 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105273:	85 db                	test   %ebx,%ebx
f0105275:	74 98                	je     f010520f <strtol+0x66>
f0105277:	eb 9e                	jmp    f0105217 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105279:	89 c2                	mov    %eax,%edx
f010527b:	f7 da                	neg    %edx
f010527d:	85 ff                	test   %edi,%edi
f010527f:	0f 45 c2             	cmovne %edx,%eax
}
f0105282:	5b                   	pop    %ebx
f0105283:	5e                   	pop    %esi
f0105284:	5f                   	pop    %edi
f0105285:	5d                   	pop    %ebp
f0105286:	c3                   	ret    
f0105287:	90                   	nop

f0105288 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105288:	fa                   	cli    

	xorw    %ax, %ax
f0105289:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010528b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010528d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010528f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105291:	0f 01 16             	lgdtl  (%esi)
f0105294:	74 70                	je     f0105306 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105296:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105299:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010529d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01052a0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01052a6:	08 00                	or     %al,(%eax)

f01052a8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01052a8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01052ac:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01052ae:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01052b0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01052b2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01052b6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01052b8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01052ba:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f01052bf:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01052c2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01052c5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01052ca:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01052cd:	8b 25 84 7e 20 f0    	mov    0xf0207e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01052d3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01052d8:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f01052dd:	ff d0                	call   *%eax

f01052df <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01052df:	eb fe                	jmp    f01052df <spin>
f01052e1:	8d 76 00             	lea    0x0(%esi),%esi

f01052e4 <gdt>:
	...
f01052ec:	ff                   	(bad)  
f01052ed:	ff 00                	incl   (%eax)
f01052ef:	00 00                	add    %al,(%eax)
f01052f1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01052f8:	00                   	.byte 0x0
f01052f9:	92                   	xchg   %eax,%edx
f01052fa:	cf                   	iret   
	...

f01052fc <gdtdesc>:
f01052fc:	17                   	pop    %ss
f01052fd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105302 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105302:	90                   	nop

f0105303 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105303:	55                   	push   %ebp
f0105304:	89 e5                	mov    %esp,%ebp
f0105306:	57                   	push   %edi
f0105307:	56                   	push   %esi
f0105308:	53                   	push   %ebx
f0105309:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010530c:	8b 0d 88 7e 20 f0    	mov    0xf0207e88,%ecx
f0105312:	89 c3                	mov    %eax,%ebx
f0105314:	c1 eb 0c             	shr    $0xc,%ebx
f0105317:	39 cb                	cmp    %ecx,%ebx
f0105319:	72 12                	jb     f010532d <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010531b:	50                   	push   %eax
f010531c:	68 64 5d 10 f0       	push   $0xf0105d64
f0105321:	6a 57                	push   $0x57
f0105323:	68 9d 78 10 f0       	push   $0xf010789d
f0105328:	e8 13 ad ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010532d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105333:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105335:	89 c2                	mov    %eax,%edx
f0105337:	c1 ea 0c             	shr    $0xc,%edx
f010533a:	39 ca                	cmp    %ecx,%edx
f010533c:	72 12                	jb     f0105350 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010533e:	50                   	push   %eax
f010533f:	68 64 5d 10 f0       	push   $0xf0105d64
f0105344:	6a 57                	push   $0x57
f0105346:	68 9d 78 10 f0       	push   $0xf010789d
f010534b:	e8 f0 ac ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105350:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105356:	eb 2f                	jmp    f0105387 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105358:	83 ec 04             	sub    $0x4,%esp
f010535b:	6a 04                	push   $0x4
f010535d:	68 ad 78 10 f0       	push   $0xf01078ad
f0105362:	53                   	push   %ebx
f0105363:	e8 e5 fd ff ff       	call   f010514d <memcmp>
f0105368:	83 c4 10             	add    $0x10,%esp
f010536b:	85 c0                	test   %eax,%eax
f010536d:	75 15                	jne    f0105384 <mpsearch1+0x81>
f010536f:	89 da                	mov    %ebx,%edx
f0105371:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105374:	0f b6 0a             	movzbl (%edx),%ecx
f0105377:	01 c8                	add    %ecx,%eax
f0105379:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010537c:	39 d7                	cmp    %edx,%edi
f010537e:	75 f4                	jne    f0105374 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105380:	84 c0                	test   %al,%al
f0105382:	74 0e                	je     f0105392 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105384:	83 c3 10             	add    $0x10,%ebx
f0105387:	39 f3                	cmp    %esi,%ebx
f0105389:	72 cd                	jb     f0105358 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010538b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105390:	eb 02                	jmp    f0105394 <mpsearch1+0x91>
f0105392:	89 d8                	mov    %ebx,%eax
}
f0105394:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105397:	5b                   	pop    %ebx
f0105398:	5e                   	pop    %esi
f0105399:	5f                   	pop    %edi
f010539a:	5d                   	pop    %ebp
f010539b:	c3                   	ret    

f010539c <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010539c:	55                   	push   %ebp
f010539d:	89 e5                	mov    %esp,%ebp
f010539f:	57                   	push   %edi
f01053a0:	56                   	push   %esi
f01053a1:	53                   	push   %ebx
f01053a2:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01053a5:	c7 05 c0 83 20 f0 20 	movl   $0xf0208020,0xf02083c0
f01053ac:	80 20 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01053af:	83 3d 88 7e 20 f0 00 	cmpl   $0x0,0xf0207e88
f01053b6:	75 16                	jne    f01053ce <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01053b8:	68 00 04 00 00       	push   $0x400
f01053bd:	68 64 5d 10 f0       	push   $0xf0105d64
f01053c2:	6a 6f                	push   $0x6f
f01053c4:	68 9d 78 10 f0       	push   $0xf010789d
f01053c9:	e8 72 ac ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01053ce:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01053d5:	85 c0                	test   %eax,%eax
f01053d7:	74 16                	je     f01053ef <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01053d9:	c1 e0 04             	shl    $0x4,%eax
f01053dc:	ba 00 04 00 00       	mov    $0x400,%edx
f01053e1:	e8 1d ff ff ff       	call   f0105303 <mpsearch1>
f01053e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01053e9:	85 c0                	test   %eax,%eax
f01053eb:	75 3c                	jne    f0105429 <mp_init+0x8d>
f01053ed:	eb 20                	jmp    f010540f <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01053ef:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01053f6:	c1 e0 0a             	shl    $0xa,%eax
f01053f9:	2d 00 04 00 00       	sub    $0x400,%eax
f01053fe:	ba 00 04 00 00       	mov    $0x400,%edx
f0105403:	e8 fb fe ff ff       	call   f0105303 <mpsearch1>
f0105408:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010540b:	85 c0                	test   %eax,%eax
f010540d:	75 1a                	jne    f0105429 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010540f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105414:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105419:	e8 e5 fe ff ff       	call   f0105303 <mpsearch1>
f010541e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105421:	85 c0                	test   %eax,%eax
f0105423:	0f 84 5d 02 00 00    	je     f0105686 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105429:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010542c:	8b 70 04             	mov    0x4(%eax),%esi
f010542f:	85 f6                	test   %esi,%esi
f0105431:	74 06                	je     f0105439 <mp_init+0x9d>
f0105433:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105437:	74 15                	je     f010544e <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105439:	83 ec 0c             	sub    $0xc,%esp
f010543c:	68 10 77 10 f0       	push   $0xf0107710
f0105441:	e8 eb e1 ff ff       	call   f0103631 <cprintf>
f0105446:	83 c4 10             	add    $0x10,%esp
f0105449:	e9 38 02 00 00       	jmp    f0105686 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010544e:	89 f0                	mov    %esi,%eax
f0105450:	c1 e8 0c             	shr    $0xc,%eax
f0105453:	3b 05 88 7e 20 f0    	cmp    0xf0207e88,%eax
f0105459:	72 15                	jb     f0105470 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010545b:	56                   	push   %esi
f010545c:	68 64 5d 10 f0       	push   $0xf0105d64
f0105461:	68 90 00 00 00       	push   $0x90
f0105466:	68 9d 78 10 f0       	push   $0xf010789d
f010546b:	e8 d0 ab ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105470:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105476:	83 ec 04             	sub    $0x4,%esp
f0105479:	6a 04                	push   $0x4
f010547b:	68 b2 78 10 f0       	push   $0xf01078b2
f0105480:	53                   	push   %ebx
f0105481:	e8 c7 fc ff ff       	call   f010514d <memcmp>
f0105486:	83 c4 10             	add    $0x10,%esp
f0105489:	85 c0                	test   %eax,%eax
f010548b:	74 15                	je     f01054a2 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010548d:	83 ec 0c             	sub    $0xc,%esp
f0105490:	68 40 77 10 f0       	push   $0xf0107740
f0105495:	e8 97 e1 ff ff       	call   f0103631 <cprintf>
f010549a:	83 c4 10             	add    $0x10,%esp
f010549d:	e9 e4 01 00 00       	jmp    f0105686 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01054a2:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01054a6:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01054aa:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01054ad:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01054b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01054b7:	eb 0d                	jmp    f01054c6 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01054b9:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01054c0:	f0 
f01054c1:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01054c3:	83 c0 01             	add    $0x1,%eax
f01054c6:	39 c7                	cmp    %eax,%edi
f01054c8:	75 ef                	jne    f01054b9 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01054ca:	84 d2                	test   %dl,%dl
f01054cc:	74 15                	je     f01054e3 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01054ce:	83 ec 0c             	sub    $0xc,%esp
f01054d1:	68 74 77 10 f0       	push   $0xf0107774
f01054d6:	e8 56 e1 ff ff       	call   f0103631 <cprintf>
f01054db:	83 c4 10             	add    $0x10,%esp
f01054de:	e9 a3 01 00 00       	jmp    f0105686 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01054e3:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01054e7:	3c 01                	cmp    $0x1,%al
f01054e9:	74 1d                	je     f0105508 <mp_init+0x16c>
f01054eb:	3c 04                	cmp    $0x4,%al
f01054ed:	74 19                	je     f0105508 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01054ef:	83 ec 08             	sub    $0x8,%esp
f01054f2:	0f b6 c0             	movzbl %al,%eax
f01054f5:	50                   	push   %eax
f01054f6:	68 98 77 10 f0       	push   $0xf0107798
f01054fb:	e8 31 e1 ff ff       	call   f0103631 <cprintf>
f0105500:	83 c4 10             	add    $0x10,%esp
f0105503:	e9 7e 01 00 00       	jmp    f0105686 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105508:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f010550c:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105510:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105515:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010551a:	01 ce                	add    %ecx,%esi
f010551c:	eb 0d                	jmp    f010552b <mp_init+0x18f>
f010551e:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105525:	f0 
f0105526:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105528:	83 c0 01             	add    $0x1,%eax
f010552b:	39 c7                	cmp    %eax,%edi
f010552d:	75 ef                	jne    f010551e <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010552f:	89 d0                	mov    %edx,%eax
f0105531:	02 43 2a             	add    0x2a(%ebx),%al
f0105534:	74 15                	je     f010554b <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105536:	83 ec 0c             	sub    $0xc,%esp
f0105539:	68 b8 77 10 f0       	push   $0xf01077b8
f010553e:	e8 ee e0 ff ff       	call   f0103631 <cprintf>
f0105543:	83 c4 10             	add    $0x10,%esp
f0105546:	e9 3b 01 00 00       	jmp    f0105686 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010554b:	85 db                	test   %ebx,%ebx
f010554d:	0f 84 33 01 00 00    	je     f0105686 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105553:	c7 05 00 80 20 f0 01 	movl   $0x1,0xf0208000
f010555a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010555d:	8b 43 24             	mov    0x24(%ebx),%eax
f0105560:	a3 00 90 24 f0       	mov    %eax,0xf0249000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105565:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105568:	be 00 00 00 00       	mov    $0x0,%esi
f010556d:	e9 85 00 00 00       	jmp    f01055f7 <mp_init+0x25b>
		switch (*p) {
f0105572:	0f b6 07             	movzbl (%edi),%eax
f0105575:	84 c0                	test   %al,%al
f0105577:	74 06                	je     f010557f <mp_init+0x1e3>
f0105579:	3c 04                	cmp    $0x4,%al
f010557b:	77 55                	ja     f01055d2 <mp_init+0x236>
f010557d:	eb 4e                	jmp    f01055cd <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010557f:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105583:	74 11                	je     f0105596 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105585:	6b 05 c4 83 20 f0 74 	imul   $0x74,0xf02083c4,%eax
f010558c:	05 20 80 20 f0       	add    $0xf0208020,%eax
f0105591:	a3 c0 83 20 f0       	mov    %eax,0xf02083c0
			if (ncpu < NCPU) {
f0105596:	a1 c4 83 20 f0       	mov    0xf02083c4,%eax
f010559b:	83 f8 07             	cmp    $0x7,%eax
f010559e:	7f 13                	jg     f01055b3 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01055a0:	6b d0 74             	imul   $0x74,%eax,%edx
f01055a3:	88 82 20 80 20 f0    	mov    %al,-0xfdf7fe0(%edx)
				ncpu++;
f01055a9:	83 c0 01             	add    $0x1,%eax
f01055ac:	a3 c4 83 20 f0       	mov    %eax,0xf02083c4
f01055b1:	eb 15                	jmp    f01055c8 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01055b3:	83 ec 08             	sub    $0x8,%esp
f01055b6:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01055ba:	50                   	push   %eax
f01055bb:	68 e8 77 10 f0       	push   $0xf01077e8
f01055c0:	e8 6c e0 ff ff       	call   f0103631 <cprintf>
f01055c5:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01055c8:	83 c7 14             	add    $0x14,%edi
			continue;
f01055cb:	eb 27                	jmp    f01055f4 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01055cd:	83 c7 08             	add    $0x8,%edi
			continue;
f01055d0:	eb 22                	jmp    f01055f4 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01055d2:	83 ec 08             	sub    $0x8,%esp
f01055d5:	0f b6 c0             	movzbl %al,%eax
f01055d8:	50                   	push   %eax
f01055d9:	68 10 78 10 f0       	push   $0xf0107810
f01055de:	e8 4e e0 ff ff       	call   f0103631 <cprintf>
			ismp = 0;
f01055e3:	c7 05 00 80 20 f0 00 	movl   $0x0,0xf0208000
f01055ea:	00 00 00 
			i = conf->entry;
f01055ed:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f01055f1:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01055f4:	83 c6 01             	add    $0x1,%esi
f01055f7:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01055fb:	39 c6                	cmp    %eax,%esi
f01055fd:	0f 82 6f ff ff ff    	jb     f0105572 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105603:	a1 c0 83 20 f0       	mov    0xf02083c0,%eax
f0105608:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010560f:	83 3d 00 80 20 f0 00 	cmpl   $0x0,0xf0208000
f0105616:	75 26                	jne    f010563e <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105618:	c7 05 c4 83 20 f0 01 	movl   $0x1,0xf02083c4
f010561f:	00 00 00 
		lapicaddr = 0;
f0105622:	c7 05 00 90 24 f0 00 	movl   $0x0,0xf0249000
f0105629:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010562c:	83 ec 0c             	sub    $0xc,%esp
f010562f:	68 30 78 10 f0       	push   $0xf0107830
f0105634:	e8 f8 df ff ff       	call   f0103631 <cprintf>
		return;
f0105639:	83 c4 10             	add    $0x10,%esp
f010563c:	eb 48                	jmp    f0105686 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010563e:	83 ec 04             	sub    $0x4,%esp
f0105641:	ff 35 c4 83 20 f0    	pushl  0xf02083c4
f0105647:	0f b6 00             	movzbl (%eax),%eax
f010564a:	50                   	push   %eax
f010564b:	68 b7 78 10 f0       	push   $0xf01078b7
f0105650:	e8 dc df ff ff       	call   f0103631 <cprintf>

	if (mp->imcrp) {
f0105655:	83 c4 10             	add    $0x10,%esp
f0105658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010565b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010565f:	74 25                	je     f0105686 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105661:	83 ec 0c             	sub    $0xc,%esp
f0105664:	68 5c 78 10 f0       	push   $0xf010785c
f0105669:	e8 c3 df ff ff       	call   f0103631 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010566e:	ba 22 00 00 00       	mov    $0x22,%edx
f0105673:	b8 70 00 00 00       	mov    $0x70,%eax
f0105678:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105679:	ba 23 00 00 00       	mov    $0x23,%edx
f010567e:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010567f:	83 c8 01             	or     $0x1,%eax
f0105682:	ee                   	out    %al,(%dx)
f0105683:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105686:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105689:	5b                   	pop    %ebx
f010568a:	5e                   	pop    %esi
f010568b:	5f                   	pop    %edi
f010568c:	5d                   	pop    %ebp
f010568d:	c3                   	ret    

f010568e <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010568e:	55                   	push   %ebp
f010568f:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105691:	8b 0d 04 90 24 f0    	mov    0xf0249004,%ecx
f0105697:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010569a:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010569c:	a1 04 90 24 f0       	mov    0xf0249004,%eax
f01056a1:	8b 40 20             	mov    0x20(%eax),%eax
}
f01056a4:	5d                   	pop    %ebp
f01056a5:	c3                   	ret    

f01056a6 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01056a6:	55                   	push   %ebp
f01056a7:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01056a9:	a1 04 90 24 f0       	mov    0xf0249004,%eax
f01056ae:	85 c0                	test   %eax,%eax
f01056b0:	74 08                	je     f01056ba <cpunum+0x14>
		return lapic[ID] >> 24;
f01056b2:	8b 40 20             	mov    0x20(%eax),%eax
f01056b5:	c1 e8 18             	shr    $0x18,%eax
f01056b8:	eb 05                	jmp    f01056bf <cpunum+0x19>
	return 0;
f01056ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01056bf:	5d                   	pop    %ebp
f01056c0:	c3                   	ret    

f01056c1 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01056c1:	a1 00 90 24 f0       	mov    0xf0249000,%eax
f01056c6:	85 c0                	test   %eax,%eax
f01056c8:	0f 84 21 01 00 00    	je     f01057ef <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01056ce:	55                   	push   %ebp
f01056cf:	89 e5                	mov    %esp,%ebp
f01056d1:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01056d4:	68 00 10 00 00       	push   $0x1000
f01056d9:	50                   	push   %eax
f01056da:	e8 c9 bb ff ff       	call   f01012a8 <mmio_map_region>
f01056df:	a3 04 90 24 f0       	mov    %eax,0xf0249004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01056e4:	ba 27 01 00 00       	mov    $0x127,%edx
f01056e9:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01056ee:	e8 9b ff ff ff       	call   f010568e <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01056f3:	ba 0b 00 00 00       	mov    $0xb,%edx
f01056f8:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01056fd:	e8 8c ff ff ff       	call   f010568e <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105702:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105707:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010570c:	e8 7d ff ff ff       	call   f010568e <lapicw>
	lapicw(TICR, 10000000); 
f0105711:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105716:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010571b:	e8 6e ff ff ff       	call   f010568e <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105720:	e8 81 ff ff ff       	call   f01056a6 <cpunum>
f0105725:	6b c0 74             	imul   $0x74,%eax,%eax
f0105728:	05 20 80 20 f0       	add    $0xf0208020,%eax
f010572d:	83 c4 10             	add    $0x10,%esp
f0105730:	39 05 c0 83 20 f0    	cmp    %eax,0xf02083c0
f0105736:	74 0f                	je     f0105747 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105738:	ba 00 00 01 00       	mov    $0x10000,%edx
f010573d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105742:	e8 47 ff ff ff       	call   f010568e <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105747:	ba 00 00 01 00       	mov    $0x10000,%edx
f010574c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105751:	e8 38 ff ff ff       	call   f010568e <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105756:	a1 04 90 24 f0       	mov    0xf0249004,%eax
f010575b:	8b 40 30             	mov    0x30(%eax),%eax
f010575e:	c1 e8 10             	shr    $0x10,%eax
f0105761:	3c 03                	cmp    $0x3,%al
f0105763:	76 0f                	jbe    f0105774 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105765:	ba 00 00 01 00       	mov    $0x10000,%edx
f010576a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010576f:	e8 1a ff ff ff       	call   f010568e <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105774:	ba 33 00 00 00       	mov    $0x33,%edx
f0105779:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010577e:	e8 0b ff ff ff       	call   f010568e <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105783:	ba 00 00 00 00       	mov    $0x0,%edx
f0105788:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010578d:	e8 fc fe ff ff       	call   f010568e <lapicw>
	lapicw(ESR, 0);
f0105792:	ba 00 00 00 00       	mov    $0x0,%edx
f0105797:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010579c:	e8 ed fe ff ff       	call   f010568e <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01057a1:	ba 00 00 00 00       	mov    $0x0,%edx
f01057a6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01057ab:	e8 de fe ff ff       	call   f010568e <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01057b0:	ba 00 00 00 00       	mov    $0x0,%edx
f01057b5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01057ba:	e8 cf fe ff ff       	call   f010568e <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01057bf:	ba 00 85 08 00       	mov    $0x88500,%edx
f01057c4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01057c9:	e8 c0 fe ff ff       	call   f010568e <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01057ce:	8b 15 04 90 24 f0    	mov    0xf0249004,%edx
f01057d4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01057da:	f6 c4 10             	test   $0x10,%ah
f01057dd:	75 f5                	jne    f01057d4 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01057df:	ba 00 00 00 00       	mov    $0x0,%edx
f01057e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01057e9:	e8 a0 fe ff ff       	call   f010568e <lapicw>
}
f01057ee:	c9                   	leave  
f01057ef:	f3 c3                	repz ret 

f01057f1 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01057f1:	83 3d 04 90 24 f0 00 	cmpl   $0x0,0xf0249004
f01057f8:	74 13                	je     f010580d <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01057fa:	55                   	push   %ebp
f01057fb:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01057fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105802:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105807:	e8 82 fe ff ff       	call   f010568e <lapicw>
}
f010580c:	5d                   	pop    %ebp
f010580d:	f3 c3                	repz ret 

f010580f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010580f:	55                   	push   %ebp
f0105810:	89 e5                	mov    %esp,%ebp
f0105812:	56                   	push   %esi
f0105813:	53                   	push   %ebx
f0105814:	8b 75 08             	mov    0x8(%ebp),%esi
f0105817:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010581a:	ba 70 00 00 00       	mov    $0x70,%edx
f010581f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105824:	ee                   	out    %al,(%dx)
f0105825:	ba 71 00 00 00       	mov    $0x71,%edx
f010582a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010582f:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105830:	83 3d 88 7e 20 f0 00 	cmpl   $0x0,0xf0207e88
f0105837:	75 19                	jne    f0105852 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105839:	68 67 04 00 00       	push   $0x467
f010583e:	68 64 5d 10 f0       	push   $0xf0105d64
f0105843:	68 98 00 00 00       	push   $0x98
f0105848:	68 d4 78 10 f0       	push   $0xf01078d4
f010584d:	e8 ee a7 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105852:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105859:	00 00 
	wrv[1] = addr >> 4;
f010585b:	89 d8                	mov    %ebx,%eax
f010585d:	c1 e8 04             	shr    $0x4,%eax
f0105860:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105866:	c1 e6 18             	shl    $0x18,%esi
f0105869:	89 f2                	mov    %esi,%edx
f010586b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105870:	e8 19 fe ff ff       	call   f010568e <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105875:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010587a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010587f:	e8 0a fe ff ff       	call   f010568e <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105884:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105889:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010588e:	e8 fb fd ff ff       	call   f010568e <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105893:	c1 eb 0c             	shr    $0xc,%ebx
f0105896:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105899:	89 f2                	mov    %esi,%edx
f010589b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01058a0:	e8 e9 fd ff ff       	call   f010568e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01058a5:	89 da                	mov    %ebx,%edx
f01058a7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01058ac:	e8 dd fd ff ff       	call   f010568e <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01058b1:	89 f2                	mov    %esi,%edx
f01058b3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01058b8:	e8 d1 fd ff ff       	call   f010568e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01058bd:	89 da                	mov    %ebx,%edx
f01058bf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01058c4:	e8 c5 fd ff ff       	call   f010568e <lapicw>
		microdelay(200);
	}
}
f01058c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01058cc:	5b                   	pop    %ebx
f01058cd:	5e                   	pop    %esi
f01058ce:	5d                   	pop    %ebp
f01058cf:	c3                   	ret    

f01058d0 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01058d0:	55                   	push   %ebp
f01058d1:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01058d3:	8b 55 08             	mov    0x8(%ebp),%edx
f01058d6:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01058dc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01058e1:	e8 a8 fd ff ff       	call   f010568e <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01058e6:	8b 15 04 90 24 f0    	mov    0xf0249004,%edx
f01058ec:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01058f2:	f6 c4 10             	test   $0x10,%ah
f01058f5:	75 f5                	jne    f01058ec <lapic_ipi+0x1c>
		;
}
f01058f7:	5d                   	pop    %ebp
f01058f8:	c3                   	ret    

f01058f9 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01058f9:	55                   	push   %ebp
f01058fa:	89 e5                	mov    %esp,%ebp
f01058fc:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01058ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105905:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105908:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010590b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105912:	5d                   	pop    %ebp
f0105913:	c3                   	ret    

f0105914 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105914:	55                   	push   %ebp
f0105915:	89 e5                	mov    %esp,%ebp
f0105917:	56                   	push   %esi
f0105918:	53                   	push   %ebx
f0105919:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010591c:	83 3b 00             	cmpl   $0x0,(%ebx)
f010591f:	74 14                	je     f0105935 <spin_lock+0x21>
f0105921:	8b 73 08             	mov    0x8(%ebx),%esi
f0105924:	e8 7d fd ff ff       	call   f01056a6 <cpunum>
f0105929:	6b c0 74             	imul   $0x74,%eax,%eax
f010592c:	05 20 80 20 f0       	add    $0xf0208020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105931:	39 c6                	cmp    %eax,%esi
f0105933:	74 07                	je     f010593c <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105935:	ba 01 00 00 00       	mov    $0x1,%edx
f010593a:	eb 20                	jmp    f010595c <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010593c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010593f:	e8 62 fd ff ff       	call   f01056a6 <cpunum>
f0105944:	83 ec 0c             	sub    $0xc,%esp
f0105947:	53                   	push   %ebx
f0105948:	50                   	push   %eax
f0105949:	68 e4 78 10 f0       	push   $0xf01078e4
f010594e:	6a 41                	push   $0x41
f0105950:	68 48 79 10 f0       	push   $0xf0107948
f0105955:	e8 e6 a6 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010595a:	f3 90                	pause  
f010595c:	89 d0                	mov    %edx,%eax
f010595e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105961:	85 c0                	test   %eax,%eax
f0105963:	75 f5                	jne    f010595a <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105965:	e8 3c fd ff ff       	call   f01056a6 <cpunum>
f010596a:	6b c0 74             	imul   $0x74,%eax,%eax
f010596d:	05 20 80 20 f0       	add    $0xf0208020,%eax
f0105972:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105975:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105978:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010597a:	b8 00 00 00 00       	mov    $0x0,%eax
f010597f:	eb 0b                	jmp    f010598c <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105981:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105984:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105987:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105989:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010598c:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105992:	76 11                	jbe    f01059a5 <spin_lock+0x91>
f0105994:	83 f8 09             	cmp    $0x9,%eax
f0105997:	7e e8                	jle    f0105981 <spin_lock+0x6d>
f0105999:	eb 0a                	jmp    f01059a5 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010599b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01059a2:	83 c0 01             	add    $0x1,%eax
f01059a5:	83 f8 09             	cmp    $0x9,%eax
f01059a8:	7e f1                	jle    f010599b <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01059aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01059ad:	5b                   	pop    %ebx
f01059ae:	5e                   	pop    %esi
f01059af:	5d                   	pop    %ebp
f01059b0:	c3                   	ret    

f01059b1 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01059b1:	55                   	push   %ebp
f01059b2:	89 e5                	mov    %esp,%ebp
f01059b4:	57                   	push   %edi
f01059b5:	56                   	push   %esi
f01059b6:	53                   	push   %ebx
f01059b7:	83 ec 4c             	sub    $0x4c,%esp
f01059ba:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01059bd:	83 3e 00             	cmpl   $0x0,(%esi)
f01059c0:	74 18                	je     f01059da <spin_unlock+0x29>
f01059c2:	8b 5e 08             	mov    0x8(%esi),%ebx
f01059c5:	e8 dc fc ff ff       	call   f01056a6 <cpunum>
f01059ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01059cd:	05 20 80 20 f0       	add    $0xf0208020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01059d2:	39 c3                	cmp    %eax,%ebx
f01059d4:	0f 84 a5 00 00 00    	je     f0105a7f <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01059da:	83 ec 04             	sub    $0x4,%esp
f01059dd:	6a 28                	push   $0x28
f01059df:	8d 46 0c             	lea    0xc(%esi),%eax
f01059e2:	50                   	push   %eax
f01059e3:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01059e6:	53                   	push   %ebx
f01059e7:	e8 e6 f6 ff ff       	call   f01050d2 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01059ec:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01059ef:	0f b6 38             	movzbl (%eax),%edi
f01059f2:	8b 76 04             	mov    0x4(%esi),%esi
f01059f5:	e8 ac fc ff ff       	call   f01056a6 <cpunum>
f01059fa:	57                   	push   %edi
f01059fb:	56                   	push   %esi
f01059fc:	50                   	push   %eax
f01059fd:	68 10 79 10 f0       	push   $0xf0107910
f0105a02:	e8 2a dc ff ff       	call   f0103631 <cprintf>
f0105a07:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105a0a:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105a0d:	eb 54                	jmp    f0105a63 <spin_unlock+0xb2>
f0105a0f:	83 ec 08             	sub    $0x8,%esp
f0105a12:	57                   	push   %edi
f0105a13:	50                   	push   %eax
f0105a14:	e8 8b ec ff ff       	call   f01046a4 <debuginfo_eip>
f0105a19:	83 c4 10             	add    $0x10,%esp
f0105a1c:	85 c0                	test   %eax,%eax
f0105a1e:	78 27                	js     f0105a47 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105a20:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105a22:	83 ec 04             	sub    $0x4,%esp
f0105a25:	89 c2                	mov    %eax,%edx
f0105a27:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105a2a:	52                   	push   %edx
f0105a2b:	ff 75 b0             	pushl  -0x50(%ebp)
f0105a2e:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105a31:	ff 75 ac             	pushl  -0x54(%ebp)
f0105a34:	ff 75 a8             	pushl  -0x58(%ebp)
f0105a37:	50                   	push   %eax
f0105a38:	68 58 79 10 f0       	push   $0xf0107958
f0105a3d:	e8 ef db ff ff       	call   f0103631 <cprintf>
f0105a42:	83 c4 20             	add    $0x20,%esp
f0105a45:	eb 12                	jmp    f0105a59 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105a47:	83 ec 08             	sub    $0x8,%esp
f0105a4a:	ff 36                	pushl  (%esi)
f0105a4c:	68 6f 79 10 f0       	push   $0xf010796f
f0105a51:	e8 db db ff ff       	call   f0103631 <cprintf>
f0105a56:	83 c4 10             	add    $0x10,%esp
f0105a59:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105a5c:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105a5f:	39 c3                	cmp    %eax,%ebx
f0105a61:	74 08                	je     f0105a6b <spin_unlock+0xba>
f0105a63:	89 de                	mov    %ebx,%esi
f0105a65:	8b 03                	mov    (%ebx),%eax
f0105a67:	85 c0                	test   %eax,%eax
f0105a69:	75 a4                	jne    f0105a0f <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105a6b:	83 ec 04             	sub    $0x4,%esp
f0105a6e:	68 77 79 10 f0       	push   $0xf0107977
f0105a73:	6a 67                	push   $0x67
f0105a75:	68 48 79 10 f0       	push   $0xf0107948
f0105a7a:	e8 c1 a5 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105a7f:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105a86:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105a8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a92:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105a98:	5b                   	pop    %ebx
f0105a99:	5e                   	pop    %esi
f0105a9a:	5f                   	pop    %edi
f0105a9b:	5d                   	pop    %ebp
f0105a9c:	c3                   	ret    
f0105a9d:	66 90                	xchg   %ax,%ax
f0105a9f:	90                   	nop

f0105aa0 <__udivdi3>:
f0105aa0:	55                   	push   %ebp
f0105aa1:	57                   	push   %edi
f0105aa2:	56                   	push   %esi
f0105aa3:	53                   	push   %ebx
f0105aa4:	83 ec 1c             	sub    $0x1c,%esp
f0105aa7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105aab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105aaf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105ab3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105ab7:	85 f6                	test   %esi,%esi
f0105ab9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105abd:	89 ca                	mov    %ecx,%edx
f0105abf:	89 f8                	mov    %edi,%eax
f0105ac1:	75 3d                	jne    f0105b00 <__udivdi3+0x60>
f0105ac3:	39 cf                	cmp    %ecx,%edi
f0105ac5:	0f 87 c5 00 00 00    	ja     f0105b90 <__udivdi3+0xf0>
f0105acb:	85 ff                	test   %edi,%edi
f0105acd:	89 fd                	mov    %edi,%ebp
f0105acf:	75 0b                	jne    f0105adc <__udivdi3+0x3c>
f0105ad1:	b8 01 00 00 00       	mov    $0x1,%eax
f0105ad6:	31 d2                	xor    %edx,%edx
f0105ad8:	f7 f7                	div    %edi
f0105ada:	89 c5                	mov    %eax,%ebp
f0105adc:	89 c8                	mov    %ecx,%eax
f0105ade:	31 d2                	xor    %edx,%edx
f0105ae0:	f7 f5                	div    %ebp
f0105ae2:	89 c1                	mov    %eax,%ecx
f0105ae4:	89 d8                	mov    %ebx,%eax
f0105ae6:	89 cf                	mov    %ecx,%edi
f0105ae8:	f7 f5                	div    %ebp
f0105aea:	89 c3                	mov    %eax,%ebx
f0105aec:	89 d8                	mov    %ebx,%eax
f0105aee:	89 fa                	mov    %edi,%edx
f0105af0:	83 c4 1c             	add    $0x1c,%esp
f0105af3:	5b                   	pop    %ebx
f0105af4:	5e                   	pop    %esi
f0105af5:	5f                   	pop    %edi
f0105af6:	5d                   	pop    %ebp
f0105af7:	c3                   	ret    
f0105af8:	90                   	nop
f0105af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105b00:	39 ce                	cmp    %ecx,%esi
f0105b02:	77 74                	ja     f0105b78 <__udivdi3+0xd8>
f0105b04:	0f bd fe             	bsr    %esi,%edi
f0105b07:	83 f7 1f             	xor    $0x1f,%edi
f0105b0a:	0f 84 98 00 00 00    	je     f0105ba8 <__udivdi3+0x108>
f0105b10:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105b15:	89 f9                	mov    %edi,%ecx
f0105b17:	89 c5                	mov    %eax,%ebp
f0105b19:	29 fb                	sub    %edi,%ebx
f0105b1b:	d3 e6                	shl    %cl,%esi
f0105b1d:	89 d9                	mov    %ebx,%ecx
f0105b1f:	d3 ed                	shr    %cl,%ebp
f0105b21:	89 f9                	mov    %edi,%ecx
f0105b23:	d3 e0                	shl    %cl,%eax
f0105b25:	09 ee                	or     %ebp,%esi
f0105b27:	89 d9                	mov    %ebx,%ecx
f0105b29:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b2d:	89 d5                	mov    %edx,%ebp
f0105b2f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105b33:	d3 ed                	shr    %cl,%ebp
f0105b35:	89 f9                	mov    %edi,%ecx
f0105b37:	d3 e2                	shl    %cl,%edx
f0105b39:	89 d9                	mov    %ebx,%ecx
f0105b3b:	d3 e8                	shr    %cl,%eax
f0105b3d:	09 c2                	or     %eax,%edx
f0105b3f:	89 d0                	mov    %edx,%eax
f0105b41:	89 ea                	mov    %ebp,%edx
f0105b43:	f7 f6                	div    %esi
f0105b45:	89 d5                	mov    %edx,%ebp
f0105b47:	89 c3                	mov    %eax,%ebx
f0105b49:	f7 64 24 0c          	mull   0xc(%esp)
f0105b4d:	39 d5                	cmp    %edx,%ebp
f0105b4f:	72 10                	jb     f0105b61 <__udivdi3+0xc1>
f0105b51:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105b55:	89 f9                	mov    %edi,%ecx
f0105b57:	d3 e6                	shl    %cl,%esi
f0105b59:	39 c6                	cmp    %eax,%esi
f0105b5b:	73 07                	jae    f0105b64 <__udivdi3+0xc4>
f0105b5d:	39 d5                	cmp    %edx,%ebp
f0105b5f:	75 03                	jne    f0105b64 <__udivdi3+0xc4>
f0105b61:	83 eb 01             	sub    $0x1,%ebx
f0105b64:	31 ff                	xor    %edi,%edi
f0105b66:	89 d8                	mov    %ebx,%eax
f0105b68:	89 fa                	mov    %edi,%edx
f0105b6a:	83 c4 1c             	add    $0x1c,%esp
f0105b6d:	5b                   	pop    %ebx
f0105b6e:	5e                   	pop    %esi
f0105b6f:	5f                   	pop    %edi
f0105b70:	5d                   	pop    %ebp
f0105b71:	c3                   	ret    
f0105b72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105b78:	31 ff                	xor    %edi,%edi
f0105b7a:	31 db                	xor    %ebx,%ebx
f0105b7c:	89 d8                	mov    %ebx,%eax
f0105b7e:	89 fa                	mov    %edi,%edx
f0105b80:	83 c4 1c             	add    $0x1c,%esp
f0105b83:	5b                   	pop    %ebx
f0105b84:	5e                   	pop    %esi
f0105b85:	5f                   	pop    %edi
f0105b86:	5d                   	pop    %ebp
f0105b87:	c3                   	ret    
f0105b88:	90                   	nop
f0105b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105b90:	89 d8                	mov    %ebx,%eax
f0105b92:	f7 f7                	div    %edi
f0105b94:	31 ff                	xor    %edi,%edi
f0105b96:	89 c3                	mov    %eax,%ebx
f0105b98:	89 d8                	mov    %ebx,%eax
f0105b9a:	89 fa                	mov    %edi,%edx
f0105b9c:	83 c4 1c             	add    $0x1c,%esp
f0105b9f:	5b                   	pop    %ebx
f0105ba0:	5e                   	pop    %esi
f0105ba1:	5f                   	pop    %edi
f0105ba2:	5d                   	pop    %ebp
f0105ba3:	c3                   	ret    
f0105ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105ba8:	39 ce                	cmp    %ecx,%esi
f0105baa:	72 0c                	jb     f0105bb8 <__udivdi3+0x118>
f0105bac:	31 db                	xor    %ebx,%ebx
f0105bae:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105bb2:	0f 87 34 ff ff ff    	ja     f0105aec <__udivdi3+0x4c>
f0105bb8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105bbd:	e9 2a ff ff ff       	jmp    f0105aec <__udivdi3+0x4c>
f0105bc2:	66 90                	xchg   %ax,%ax
f0105bc4:	66 90                	xchg   %ax,%ax
f0105bc6:	66 90                	xchg   %ax,%ax
f0105bc8:	66 90                	xchg   %ax,%ax
f0105bca:	66 90                	xchg   %ax,%ax
f0105bcc:	66 90                	xchg   %ax,%ax
f0105bce:	66 90                	xchg   %ax,%ax

f0105bd0 <__umoddi3>:
f0105bd0:	55                   	push   %ebp
f0105bd1:	57                   	push   %edi
f0105bd2:	56                   	push   %esi
f0105bd3:	53                   	push   %ebx
f0105bd4:	83 ec 1c             	sub    $0x1c,%esp
f0105bd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105bdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105bdf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105be7:	85 d2                	test   %edx,%edx
f0105be9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105bed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105bf1:	89 f3                	mov    %esi,%ebx
f0105bf3:	89 3c 24             	mov    %edi,(%esp)
f0105bf6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105bfa:	75 1c                	jne    f0105c18 <__umoddi3+0x48>
f0105bfc:	39 f7                	cmp    %esi,%edi
f0105bfe:	76 50                	jbe    f0105c50 <__umoddi3+0x80>
f0105c00:	89 c8                	mov    %ecx,%eax
f0105c02:	89 f2                	mov    %esi,%edx
f0105c04:	f7 f7                	div    %edi
f0105c06:	89 d0                	mov    %edx,%eax
f0105c08:	31 d2                	xor    %edx,%edx
f0105c0a:	83 c4 1c             	add    $0x1c,%esp
f0105c0d:	5b                   	pop    %ebx
f0105c0e:	5e                   	pop    %esi
f0105c0f:	5f                   	pop    %edi
f0105c10:	5d                   	pop    %ebp
f0105c11:	c3                   	ret    
f0105c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105c18:	39 f2                	cmp    %esi,%edx
f0105c1a:	89 d0                	mov    %edx,%eax
f0105c1c:	77 52                	ja     f0105c70 <__umoddi3+0xa0>
f0105c1e:	0f bd ea             	bsr    %edx,%ebp
f0105c21:	83 f5 1f             	xor    $0x1f,%ebp
f0105c24:	75 5a                	jne    f0105c80 <__umoddi3+0xb0>
f0105c26:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105c2a:	0f 82 e0 00 00 00    	jb     f0105d10 <__umoddi3+0x140>
f0105c30:	39 0c 24             	cmp    %ecx,(%esp)
f0105c33:	0f 86 d7 00 00 00    	jbe    f0105d10 <__umoddi3+0x140>
f0105c39:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105c3d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105c41:	83 c4 1c             	add    $0x1c,%esp
f0105c44:	5b                   	pop    %ebx
f0105c45:	5e                   	pop    %esi
f0105c46:	5f                   	pop    %edi
f0105c47:	5d                   	pop    %ebp
f0105c48:	c3                   	ret    
f0105c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105c50:	85 ff                	test   %edi,%edi
f0105c52:	89 fd                	mov    %edi,%ebp
f0105c54:	75 0b                	jne    f0105c61 <__umoddi3+0x91>
f0105c56:	b8 01 00 00 00       	mov    $0x1,%eax
f0105c5b:	31 d2                	xor    %edx,%edx
f0105c5d:	f7 f7                	div    %edi
f0105c5f:	89 c5                	mov    %eax,%ebp
f0105c61:	89 f0                	mov    %esi,%eax
f0105c63:	31 d2                	xor    %edx,%edx
f0105c65:	f7 f5                	div    %ebp
f0105c67:	89 c8                	mov    %ecx,%eax
f0105c69:	f7 f5                	div    %ebp
f0105c6b:	89 d0                	mov    %edx,%eax
f0105c6d:	eb 99                	jmp    f0105c08 <__umoddi3+0x38>
f0105c6f:	90                   	nop
f0105c70:	89 c8                	mov    %ecx,%eax
f0105c72:	89 f2                	mov    %esi,%edx
f0105c74:	83 c4 1c             	add    $0x1c,%esp
f0105c77:	5b                   	pop    %ebx
f0105c78:	5e                   	pop    %esi
f0105c79:	5f                   	pop    %edi
f0105c7a:	5d                   	pop    %ebp
f0105c7b:	c3                   	ret    
f0105c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105c80:	8b 34 24             	mov    (%esp),%esi
f0105c83:	bf 20 00 00 00       	mov    $0x20,%edi
f0105c88:	89 e9                	mov    %ebp,%ecx
f0105c8a:	29 ef                	sub    %ebp,%edi
f0105c8c:	d3 e0                	shl    %cl,%eax
f0105c8e:	89 f9                	mov    %edi,%ecx
f0105c90:	89 f2                	mov    %esi,%edx
f0105c92:	d3 ea                	shr    %cl,%edx
f0105c94:	89 e9                	mov    %ebp,%ecx
f0105c96:	09 c2                	or     %eax,%edx
f0105c98:	89 d8                	mov    %ebx,%eax
f0105c9a:	89 14 24             	mov    %edx,(%esp)
f0105c9d:	89 f2                	mov    %esi,%edx
f0105c9f:	d3 e2                	shl    %cl,%edx
f0105ca1:	89 f9                	mov    %edi,%ecx
f0105ca3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ca7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105cab:	d3 e8                	shr    %cl,%eax
f0105cad:	89 e9                	mov    %ebp,%ecx
f0105caf:	89 c6                	mov    %eax,%esi
f0105cb1:	d3 e3                	shl    %cl,%ebx
f0105cb3:	89 f9                	mov    %edi,%ecx
f0105cb5:	89 d0                	mov    %edx,%eax
f0105cb7:	d3 e8                	shr    %cl,%eax
f0105cb9:	89 e9                	mov    %ebp,%ecx
f0105cbb:	09 d8                	or     %ebx,%eax
f0105cbd:	89 d3                	mov    %edx,%ebx
f0105cbf:	89 f2                	mov    %esi,%edx
f0105cc1:	f7 34 24             	divl   (%esp)
f0105cc4:	89 d6                	mov    %edx,%esi
f0105cc6:	d3 e3                	shl    %cl,%ebx
f0105cc8:	f7 64 24 04          	mull   0x4(%esp)
f0105ccc:	39 d6                	cmp    %edx,%esi
f0105cce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105cd2:	89 d1                	mov    %edx,%ecx
f0105cd4:	89 c3                	mov    %eax,%ebx
f0105cd6:	72 08                	jb     f0105ce0 <__umoddi3+0x110>
f0105cd8:	75 11                	jne    f0105ceb <__umoddi3+0x11b>
f0105cda:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105cde:	73 0b                	jae    f0105ceb <__umoddi3+0x11b>
f0105ce0:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105ce4:	1b 14 24             	sbb    (%esp),%edx
f0105ce7:	89 d1                	mov    %edx,%ecx
f0105ce9:	89 c3                	mov    %eax,%ebx
f0105ceb:	8b 54 24 08          	mov    0x8(%esp),%edx
f0105cef:	29 da                	sub    %ebx,%edx
f0105cf1:	19 ce                	sbb    %ecx,%esi
f0105cf3:	89 f9                	mov    %edi,%ecx
f0105cf5:	89 f0                	mov    %esi,%eax
f0105cf7:	d3 e0                	shl    %cl,%eax
f0105cf9:	89 e9                	mov    %ebp,%ecx
f0105cfb:	d3 ea                	shr    %cl,%edx
f0105cfd:	89 e9                	mov    %ebp,%ecx
f0105cff:	d3 ee                	shr    %cl,%esi
f0105d01:	09 d0                	or     %edx,%eax
f0105d03:	89 f2                	mov    %esi,%edx
f0105d05:	83 c4 1c             	add    $0x1c,%esp
f0105d08:	5b                   	pop    %ebx
f0105d09:	5e                   	pop    %esi
f0105d0a:	5f                   	pop    %edi
f0105d0b:	5d                   	pop    %ebp
f0105d0c:	c3                   	ret    
f0105d0d:	8d 76 00             	lea    0x0(%esi),%esi
f0105d10:	29 f9                	sub    %edi,%ecx
f0105d12:	19 d6                	sbb    %edx,%esi
f0105d14:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105d18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105d1c:	e9 18 ff ff ff       	jmp    f0105c39 <__umoddi3+0x69>
