
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
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 10 db 17 f0       	mov    $0xf017db10,%eax
f010004b:	2d ee cb 17 f0       	sub    $0xf017cbee,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 ee cb 17 f0       	push   $0xf017cbee
f0100058:	e8 7a 42 00 00       	call   f01042d7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 ab 04 00 00       	call   f010050d <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 80 47 10 f0       	push   $0xf0104780
f010006f:	e8 a1 2e 00 00       	call   f0102f15 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 b9 0f 00 00       	call   f0101032 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 ae 28 00 00       	call   f010292c <env_init>
	trap_init();
f010007e:	e8 03 2f 00 00       	call   f0102f86 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 7e 1b 13 f0       	push   $0xf0131b7e
f010008d:	e8 5b 2a 00 00       	call   f0102aed <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 48 ce 17 f0    	pushl  0xf017ce48
f010009b:	e8 a1 2d 00 00       	call   f0102e41 <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 00 db 17 f0 00 	cmpl   $0x0,0xf017db00
f01000af:	75 37                	jne    f01000e8 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 00 db 17 f0    	mov    %esi,0xf017db00

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000bc:	83 ec 04             	sub    $0x4,%esp
f01000bf:	ff 75 0c             	pushl  0xc(%ebp)
f01000c2:	ff 75 08             	pushl  0x8(%ebp)
f01000c5:	68 9b 47 10 f0       	push   $0xf010479b
f01000ca:	e8 46 2e 00 00       	call   f0102f15 <cprintf>
	vcprintf(fmt, ap);
f01000cf:	83 c4 08             	add    $0x8,%esp
f01000d2:	53                   	push   %ebx
f01000d3:	56                   	push   %esi
f01000d4:	e8 16 2e 00 00       	call   f0102eef <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 03 58 10 f0 	movl   $0xf0105803,(%esp)
f01000e0:	e8 30 2e 00 00       	call   f0102f15 <cprintf>
	va_end(ap);
f01000e5:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	83 ec 0c             	sub    $0xc,%esp
f01000eb:	6a 00                	push   $0x0
f01000ed:	e8 ba 06 00 00       	call   f01007ac <monitor>
f01000f2:	83 c4 10             	add    $0x10,%esp
f01000f5:	eb f1                	jmp    f01000e8 <_panic+0x48>

f01000f7 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f7:	55                   	push   %ebp
f01000f8:	89 e5                	mov    %esp,%ebp
f01000fa:	53                   	push   %ebx
f01000fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fe:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100101:	ff 75 0c             	pushl  0xc(%ebp)
f0100104:	ff 75 08             	pushl  0x8(%ebp)
f0100107:	68 b3 47 10 f0       	push   $0xf01047b3
f010010c:	e8 04 2e 00 00       	call   f0102f15 <cprintf>
	vcprintf(fmt, ap);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	53                   	push   %ebx
f0100115:	ff 75 10             	pushl  0x10(%ebp)
f0100118:	e8 d2 2d 00 00       	call   f0102eef <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 03 58 10 f0 	movl   $0xf0105803,(%esp)
f0100124:	e8 ec 2d 00 00       	call   f0102f15 <cprintf>
	va_end(ap);
}
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010012f:	c9                   	leave  
f0100130:	c3                   	ret    

f0100131 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100131:	55                   	push   %ebp
f0100132:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100134:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100139:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013a:	a8 01                	test   $0x1,%al
f010013c:	74 0b                	je     f0100149 <serial_proc_data+0x18>
f010013e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100143:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100144:	0f b6 c0             	movzbl %al,%eax
f0100147:	eb 05                	jmp    f010014e <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100149:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010014e:	5d                   	pop    %ebp
f010014f:	c3                   	ret    

f0100150 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp
f0100153:	53                   	push   %ebx
f0100154:	83 ec 04             	sub    $0x4,%esp
f0100157:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100159:	eb 2b                	jmp    f0100186 <cons_intr+0x36>
		if (c == 0)
f010015b:	85 c0                	test   %eax,%eax
f010015d:	74 27                	je     f0100186 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010015f:	8b 0d 24 ce 17 f0    	mov    0xf017ce24,%ecx
f0100165:	8d 51 01             	lea    0x1(%ecx),%edx
f0100168:	89 15 24 ce 17 f0    	mov    %edx,0xf017ce24
f010016e:	88 81 20 cc 17 f0    	mov    %al,-0xfe833e0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100174:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010017a:	75 0a                	jne    f0100186 <cons_intr+0x36>
			cons.wpos = 0;
f010017c:	c7 05 24 ce 17 f0 00 	movl   $0x0,0xf017ce24
f0100183:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100186:	ff d3                	call   *%ebx
f0100188:	83 f8 ff             	cmp    $0xffffffff,%eax
f010018b:	75 ce                	jne    f010015b <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010018d:	83 c4 04             	add    $0x4,%esp
f0100190:	5b                   	pop    %ebx
f0100191:	5d                   	pop    %ebp
f0100192:	c3                   	ret    

f0100193 <kbd_proc_data>:
f0100193:	ba 64 00 00 00       	mov    $0x64,%edx
f0100198:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100199:	a8 01                	test   $0x1,%al
f010019b:	0f 84 f8 00 00 00    	je     f0100299 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001a1:	a8 20                	test   $0x20,%al
f01001a3:	0f 85 f6 00 00 00    	jne    f010029f <kbd_proc_data+0x10c>
f01001a9:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ae:	ec                   	in     (%dx),%al
f01001af:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001b1:	3c e0                	cmp    $0xe0,%al
f01001b3:	75 0d                	jne    f01001c2 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001b5:	83 0d 00 cc 17 f0 40 	orl    $0x40,0xf017cc00
		return 0;
f01001bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01001c1:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001c2:	55                   	push   %ebp
f01001c3:	89 e5                	mov    %esp,%ebp
f01001c5:	53                   	push   %ebx
f01001c6:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001c9:	84 c0                	test   %al,%al
f01001cb:	79 36                	jns    f0100203 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001cd:	8b 0d 00 cc 17 f0    	mov    0xf017cc00,%ecx
f01001d3:	89 cb                	mov    %ecx,%ebx
f01001d5:	83 e3 40             	and    $0x40,%ebx
f01001d8:	83 e0 7f             	and    $0x7f,%eax
f01001db:	85 db                	test   %ebx,%ebx
f01001dd:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001e0:	0f b6 d2             	movzbl %dl,%edx
f01001e3:	0f b6 82 20 49 10 f0 	movzbl -0xfefb6e0(%edx),%eax
f01001ea:	83 c8 40             	or     $0x40,%eax
f01001ed:	0f b6 c0             	movzbl %al,%eax
f01001f0:	f7 d0                	not    %eax
f01001f2:	21 c8                	and    %ecx,%eax
f01001f4:	a3 00 cc 17 f0       	mov    %eax,0xf017cc00
		return 0;
f01001f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01001fe:	e9 a4 00 00 00       	jmp    f01002a7 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100203:	8b 0d 00 cc 17 f0    	mov    0xf017cc00,%ecx
f0100209:	f6 c1 40             	test   $0x40,%cl
f010020c:	74 0e                	je     f010021c <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010020e:	83 c8 80             	or     $0xffffff80,%eax
f0100211:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100213:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100216:	89 0d 00 cc 17 f0    	mov    %ecx,0xf017cc00
	}

	shift |= shiftcode[data];
f010021c:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010021f:	0f b6 82 20 49 10 f0 	movzbl -0xfefb6e0(%edx),%eax
f0100226:	0b 05 00 cc 17 f0    	or     0xf017cc00,%eax
f010022c:	0f b6 8a 20 48 10 f0 	movzbl -0xfefb7e0(%edx),%ecx
f0100233:	31 c8                	xor    %ecx,%eax
f0100235:	a3 00 cc 17 f0       	mov    %eax,0xf017cc00

	c = charcode[shift & (CTL | SHIFT)][data];
f010023a:	89 c1                	mov    %eax,%ecx
f010023c:	83 e1 03             	and    $0x3,%ecx
f010023f:	8b 0c 8d 00 48 10 f0 	mov    -0xfefb800(,%ecx,4),%ecx
f0100246:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010024a:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010024d:	a8 08                	test   $0x8,%al
f010024f:	74 1b                	je     f010026c <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100251:	89 da                	mov    %ebx,%edx
f0100253:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100256:	83 f9 19             	cmp    $0x19,%ecx
f0100259:	77 05                	ja     f0100260 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010025b:	83 eb 20             	sub    $0x20,%ebx
f010025e:	eb 0c                	jmp    f010026c <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f0100260:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100263:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100266:	83 fa 19             	cmp    $0x19,%edx
f0100269:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010026c:	f7 d0                	not    %eax
f010026e:	a8 06                	test   $0x6,%al
f0100270:	75 33                	jne    f01002a5 <kbd_proc_data+0x112>
f0100272:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100278:	75 2b                	jne    f01002a5 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f010027a:	83 ec 0c             	sub    $0xc,%esp
f010027d:	68 cd 47 10 f0       	push   $0xf01047cd
f0100282:	e8 8e 2c 00 00       	call   f0102f15 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100287:	ba 92 00 00 00       	mov    $0x92,%edx
f010028c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100291:	ee                   	out    %al,(%dx)
f0100292:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100295:	89 d8                	mov    %ebx,%eax
f0100297:	eb 0e                	jmp    f01002a7 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010029e:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010029f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002a4:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002a5:	89 d8                	mov    %ebx,%eax
}
f01002a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002aa:	c9                   	leave  
f01002ab:	c3                   	ret    

f01002ac <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002ac:	55                   	push   %ebp
f01002ad:	89 e5                	mov    %esp,%ebp
f01002af:	57                   	push   %edi
f01002b0:	56                   	push   %esi
f01002b1:	53                   	push   %ebx
f01002b2:	83 ec 1c             	sub    $0x1c,%esp
f01002b5:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002b7:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002bc:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002c1:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002c6:	eb 09                	jmp    f01002d1 <cons_putc+0x25>
f01002c8:	89 ca                	mov    %ecx,%edx
f01002ca:	ec                   	in     (%dx),%al
f01002cb:	ec                   	in     (%dx),%al
f01002cc:	ec                   	in     (%dx),%al
f01002cd:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002ce:	83 c3 01             	add    $0x1,%ebx
f01002d1:	89 f2                	mov    %esi,%edx
f01002d3:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002d4:	a8 20                	test   $0x20,%al
f01002d6:	75 08                	jne    f01002e0 <cons_putc+0x34>
f01002d8:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002de:	7e e8                	jle    f01002c8 <cons_putc+0x1c>
f01002e0:	89 f8                	mov    %edi,%eax
f01002e2:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002ea:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002eb:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f0:	be 79 03 00 00       	mov    $0x379,%esi
f01002f5:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fa:	eb 09                	jmp    f0100305 <cons_putc+0x59>
f01002fc:	89 ca                	mov    %ecx,%edx
f01002fe:	ec                   	in     (%dx),%al
f01002ff:	ec                   	in     (%dx),%al
f0100300:	ec                   	in     (%dx),%al
f0100301:	ec                   	in     (%dx),%al
f0100302:	83 c3 01             	add    $0x1,%ebx
f0100305:	89 f2                	mov    %esi,%edx
f0100307:	ec                   	in     (%dx),%al
f0100308:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010030e:	7f 04                	jg     f0100314 <cons_putc+0x68>
f0100310:	84 c0                	test   %al,%al
f0100312:	79 e8                	jns    f01002fc <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100314:	ba 78 03 00 00       	mov    $0x378,%edx
f0100319:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010031d:	ee                   	out    %al,(%dx)
f010031e:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100323:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100328:	ee                   	out    %al,(%dx)
f0100329:	b8 08 00 00 00       	mov    $0x8,%eax
f010032e:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010032f:	89 fa                	mov    %edi,%edx
f0100331:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100337:	89 f8                	mov    %edi,%eax
f0100339:	80 cc 07             	or     $0x7,%ah
f010033c:	85 d2                	test   %edx,%edx
f010033e:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100341:	89 f8                	mov    %edi,%eax
f0100343:	0f b6 c0             	movzbl %al,%eax
f0100346:	83 f8 09             	cmp    $0x9,%eax
f0100349:	74 74                	je     f01003bf <cons_putc+0x113>
f010034b:	83 f8 09             	cmp    $0x9,%eax
f010034e:	7f 0a                	jg     f010035a <cons_putc+0xae>
f0100350:	83 f8 08             	cmp    $0x8,%eax
f0100353:	74 14                	je     f0100369 <cons_putc+0xbd>
f0100355:	e9 99 00 00 00       	jmp    f01003f3 <cons_putc+0x147>
f010035a:	83 f8 0a             	cmp    $0xa,%eax
f010035d:	74 3a                	je     f0100399 <cons_putc+0xed>
f010035f:	83 f8 0d             	cmp    $0xd,%eax
f0100362:	74 3d                	je     f01003a1 <cons_putc+0xf5>
f0100364:	e9 8a 00 00 00       	jmp    f01003f3 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100369:	0f b7 05 28 ce 17 f0 	movzwl 0xf017ce28,%eax
f0100370:	66 85 c0             	test   %ax,%ax
f0100373:	0f 84 e6 00 00 00    	je     f010045f <cons_putc+0x1b3>
			crt_pos--;
f0100379:	83 e8 01             	sub    $0x1,%eax
f010037c:	66 a3 28 ce 17 f0    	mov    %ax,0xf017ce28
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100382:	0f b7 c0             	movzwl %ax,%eax
f0100385:	66 81 e7 00 ff       	and    $0xff00,%di
f010038a:	83 cf 20             	or     $0x20,%edi
f010038d:	8b 15 2c ce 17 f0    	mov    0xf017ce2c,%edx
f0100393:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100397:	eb 78                	jmp    f0100411 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100399:	66 83 05 28 ce 17 f0 	addw   $0x50,0xf017ce28
f01003a0:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003a1:	0f b7 05 28 ce 17 f0 	movzwl 0xf017ce28,%eax
f01003a8:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003ae:	c1 e8 16             	shr    $0x16,%eax
f01003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003b4:	c1 e0 04             	shl    $0x4,%eax
f01003b7:	66 a3 28 ce 17 f0    	mov    %ax,0xf017ce28
f01003bd:	eb 52                	jmp    f0100411 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003bf:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c4:	e8 e3 fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003c9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ce:	e8 d9 fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003d3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d8:	e8 cf fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003dd:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e2:	e8 c5 fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003e7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ec:	e8 bb fe ff ff       	call   f01002ac <cons_putc>
f01003f1:	eb 1e                	jmp    f0100411 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003f3:	0f b7 05 28 ce 17 f0 	movzwl 0xf017ce28,%eax
f01003fa:	8d 50 01             	lea    0x1(%eax),%edx
f01003fd:	66 89 15 28 ce 17 f0 	mov    %dx,0xf017ce28
f0100404:	0f b7 c0             	movzwl %ax,%eax
f0100407:	8b 15 2c ce 17 f0    	mov    0xf017ce2c,%edx
f010040d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100411:	66 81 3d 28 ce 17 f0 	cmpw   $0x7cf,0xf017ce28
f0100418:	cf 07 
f010041a:	76 43                	jbe    f010045f <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010041c:	a1 2c ce 17 f0       	mov    0xf017ce2c,%eax
f0100421:	83 ec 04             	sub    $0x4,%esp
f0100424:	68 00 0f 00 00       	push   $0xf00
f0100429:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010042f:	52                   	push   %edx
f0100430:	50                   	push   %eax
f0100431:	e8 ee 3e 00 00       	call   f0104324 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100436:	8b 15 2c ce 17 f0    	mov    0xf017ce2c,%edx
f010043c:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100442:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100448:	83 c4 10             	add    $0x10,%esp
f010044b:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100450:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100453:	39 d0                	cmp    %edx,%eax
f0100455:	75 f4                	jne    f010044b <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100457:	66 83 2d 28 ce 17 f0 	subw   $0x50,0xf017ce28
f010045e:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010045f:	8b 0d 30 ce 17 f0    	mov    0xf017ce30,%ecx
f0100465:	b8 0e 00 00 00       	mov    $0xe,%eax
f010046a:	89 ca                	mov    %ecx,%edx
f010046c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010046d:	0f b7 1d 28 ce 17 f0 	movzwl 0xf017ce28,%ebx
f0100474:	8d 71 01             	lea    0x1(%ecx),%esi
f0100477:	89 d8                	mov    %ebx,%eax
f0100479:	66 c1 e8 08          	shr    $0x8,%ax
f010047d:	89 f2                	mov    %esi,%edx
f010047f:	ee                   	out    %al,(%dx)
f0100480:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100485:	89 ca                	mov    %ecx,%edx
f0100487:	ee                   	out    %al,(%dx)
f0100488:	89 d8                	mov    %ebx,%eax
f010048a:	89 f2                	mov    %esi,%edx
f010048c:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010048d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100490:	5b                   	pop    %ebx
f0100491:	5e                   	pop    %esi
f0100492:	5f                   	pop    %edi
f0100493:	5d                   	pop    %ebp
f0100494:	c3                   	ret    

f0100495 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100495:	80 3d 34 ce 17 f0 00 	cmpb   $0x0,0xf017ce34
f010049c:	74 11                	je     f01004af <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010049e:	55                   	push   %ebp
f010049f:	89 e5                	mov    %esp,%ebp
f01004a1:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004a4:	b8 31 01 10 f0       	mov    $0xf0100131,%eax
f01004a9:	e8 a2 fc ff ff       	call   f0100150 <cons_intr>
}
f01004ae:	c9                   	leave  
f01004af:	f3 c3                	repz ret 

f01004b1 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004b1:	55                   	push   %ebp
f01004b2:	89 e5                	mov    %esp,%ebp
f01004b4:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004b7:	b8 93 01 10 f0       	mov    $0xf0100193,%eax
f01004bc:	e8 8f fc ff ff       	call   f0100150 <cons_intr>
}
f01004c1:	c9                   	leave  
f01004c2:	c3                   	ret    

f01004c3 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004c3:	55                   	push   %ebp
f01004c4:	89 e5                	mov    %esp,%ebp
f01004c6:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004c9:	e8 c7 ff ff ff       	call   f0100495 <serial_intr>
	kbd_intr();
f01004ce:	e8 de ff ff ff       	call   f01004b1 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004d3:	a1 20 ce 17 f0       	mov    0xf017ce20,%eax
f01004d8:	3b 05 24 ce 17 f0    	cmp    0xf017ce24,%eax
f01004de:	74 26                	je     f0100506 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004e0:	8d 50 01             	lea    0x1(%eax),%edx
f01004e3:	89 15 20 ce 17 f0    	mov    %edx,0xf017ce20
f01004e9:	0f b6 88 20 cc 17 f0 	movzbl -0xfe833e0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004f0:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004f2:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004f8:	75 11                	jne    f010050b <cons_getc+0x48>
			cons.rpos = 0;
f01004fa:	c7 05 20 ce 17 f0 00 	movl   $0x0,0xf017ce20
f0100501:	00 00 00 
f0100504:	eb 05                	jmp    f010050b <cons_getc+0x48>
		return c;
	}
	return 0;
f0100506:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010050b:	c9                   	leave  
f010050c:	c3                   	ret    

f010050d <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010050d:	55                   	push   %ebp
f010050e:	89 e5                	mov    %esp,%ebp
f0100510:	57                   	push   %edi
f0100511:	56                   	push   %esi
f0100512:	53                   	push   %ebx
f0100513:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100516:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010051d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100524:	5a a5 
	if (*cp != 0xA55A) {
f0100526:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010052d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100531:	74 11                	je     f0100544 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100533:	c7 05 30 ce 17 f0 b4 	movl   $0x3b4,0xf017ce30
f010053a:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010053d:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100542:	eb 16                	jmp    f010055a <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100544:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010054b:	c7 05 30 ce 17 f0 d4 	movl   $0x3d4,0xf017ce30
f0100552:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100555:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010055a:	8b 3d 30 ce 17 f0    	mov    0xf017ce30,%edi
f0100560:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100565:	89 fa                	mov    %edi,%edx
f0100567:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100568:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056b:	89 da                	mov    %ebx,%edx
f010056d:	ec                   	in     (%dx),%al
f010056e:	0f b6 c8             	movzbl %al,%ecx
f0100571:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100574:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100579:	89 fa                	mov    %edi,%edx
f010057b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010057c:	89 da                	mov    %ebx,%edx
f010057e:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010057f:	89 35 2c ce 17 f0    	mov    %esi,0xf017ce2c
	crt_pos = pos;
f0100585:	0f b6 c0             	movzbl %al,%eax
f0100588:	09 c8                	or     %ecx,%eax
f010058a:	66 a3 28 ce 17 f0    	mov    %ax,0xf017ce28
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100590:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100595:	b8 00 00 00 00       	mov    $0x0,%eax
f010059a:	89 f2                	mov    %esi,%edx
f010059c:	ee                   	out    %al,(%dx)
f010059d:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005a2:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005a7:	ee                   	out    %al,(%dx)
f01005a8:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005ad:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005b2:	89 da                	mov    %ebx,%edx
f01005b4:	ee                   	out    %al,(%dx)
f01005b5:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01005bf:	ee                   	out    %al,(%dx)
f01005c0:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005c5:	b8 03 00 00 00       	mov    $0x3,%eax
f01005ca:	ee                   	out    %al,(%dx)
f01005cb:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d5:	ee                   	out    %al,(%dx)
f01005d6:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005db:	b8 01 00 00 00       	mov    $0x1,%eax
f01005e0:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005e6:	ec                   	in     (%dx),%al
f01005e7:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005e9:	3c ff                	cmp    $0xff,%al
f01005eb:	0f 95 05 34 ce 17 f0 	setne  0xf017ce34
f01005f2:	89 f2                	mov    %esi,%edx
f01005f4:	ec                   	in     (%dx),%al
f01005f5:	89 da                	mov    %ebx,%edx
f01005f7:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005f8:	80 f9 ff             	cmp    $0xff,%cl
f01005fb:	75 10                	jne    f010060d <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005fd:	83 ec 0c             	sub    $0xc,%esp
f0100600:	68 d9 47 10 f0       	push   $0xf01047d9
f0100605:	e8 0b 29 00 00       	call   f0102f15 <cprintf>
f010060a:	83 c4 10             	add    $0x10,%esp
}
f010060d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100610:	5b                   	pop    %ebx
f0100611:	5e                   	pop    %esi
f0100612:	5f                   	pop    %edi
f0100613:	5d                   	pop    %ebp
f0100614:	c3                   	ret    

f0100615 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100615:	55                   	push   %ebp
f0100616:	89 e5                	mov    %esp,%ebp
f0100618:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010061b:	8b 45 08             	mov    0x8(%ebp),%eax
f010061e:	e8 89 fc ff ff       	call   f01002ac <cons_putc>
}
f0100623:	c9                   	leave  
f0100624:	c3                   	ret    

f0100625 <getchar>:

int
getchar(void)
{
f0100625:	55                   	push   %ebp
f0100626:	89 e5                	mov    %esp,%ebp
f0100628:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010062b:	e8 93 fe ff ff       	call   f01004c3 <cons_getc>
f0100630:	85 c0                	test   %eax,%eax
f0100632:	74 f7                	je     f010062b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100634:	c9                   	leave  
f0100635:	c3                   	ret    

f0100636 <iscons>:

int
iscons(int fdnum)
{
f0100636:	55                   	push   %ebp
f0100637:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100639:	b8 01 00 00 00       	mov    $0x1,%eax
f010063e:	5d                   	pop    %ebp
f010063f:	c3                   	ret    

f0100640 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100646:	68 20 4a 10 f0       	push   $0xf0104a20
f010064b:	68 3e 4a 10 f0       	push   $0xf0104a3e
f0100650:	68 43 4a 10 f0       	push   $0xf0104a43
f0100655:	e8 bb 28 00 00       	call   f0102f15 <cprintf>
f010065a:	83 c4 0c             	add    $0xc,%esp
f010065d:	68 cc 4a 10 f0       	push   $0xf0104acc
f0100662:	68 4c 4a 10 f0       	push   $0xf0104a4c
f0100667:	68 43 4a 10 f0       	push   $0xf0104a43
f010066c:	e8 a4 28 00 00       	call   f0102f15 <cprintf>
f0100671:	83 c4 0c             	add    $0xc,%esp
f0100674:	68 55 4a 10 f0       	push   $0xf0104a55
f0100679:	68 5d 4a 10 f0       	push   $0xf0104a5d
f010067e:	68 43 4a 10 f0       	push   $0xf0104a43
f0100683:	e8 8d 28 00 00       	call   f0102f15 <cprintf>
	return 0;
}
f0100688:	b8 00 00 00 00       	mov    $0x0,%eax
f010068d:	c9                   	leave  
f010068e:	c3                   	ret    

f010068f <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010068f:	55                   	push   %ebp
f0100690:	89 e5                	mov    %esp,%ebp
f0100692:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100695:	68 67 4a 10 f0       	push   $0xf0104a67
f010069a:	e8 76 28 00 00       	call   f0102f15 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010069f:	83 c4 08             	add    $0x8,%esp
f01006a2:	68 0c 00 10 00       	push   $0x10000c
f01006a7:	68 f4 4a 10 f0       	push   $0xf0104af4
f01006ac:	e8 64 28 00 00       	call   f0102f15 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006b1:	83 c4 0c             	add    $0xc,%esp
f01006b4:	68 0c 00 10 00       	push   $0x10000c
f01006b9:	68 0c 00 10 f0       	push   $0xf010000c
f01006be:	68 1c 4b 10 f0       	push   $0xf0104b1c
f01006c3:	e8 4d 28 00 00       	call   f0102f15 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c8:	83 c4 0c             	add    $0xc,%esp
f01006cb:	68 61 47 10 00       	push   $0x104761
f01006d0:	68 61 47 10 f0       	push   $0xf0104761
f01006d5:	68 40 4b 10 f0       	push   $0xf0104b40
f01006da:	e8 36 28 00 00       	call   f0102f15 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006df:	83 c4 0c             	add    $0xc,%esp
f01006e2:	68 ee cb 17 00       	push   $0x17cbee
f01006e7:	68 ee cb 17 f0       	push   $0xf017cbee
f01006ec:	68 64 4b 10 f0       	push   $0xf0104b64
f01006f1:	e8 1f 28 00 00       	call   f0102f15 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006f6:	83 c4 0c             	add    $0xc,%esp
f01006f9:	68 10 db 17 00       	push   $0x17db10
f01006fe:	68 10 db 17 f0       	push   $0xf017db10
f0100703:	68 88 4b 10 f0       	push   $0xf0104b88
f0100708:	e8 08 28 00 00       	call   f0102f15 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010070d:	b8 0f df 17 f0       	mov    $0xf017df0f,%eax
f0100712:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100717:	83 c4 08             	add    $0x8,%esp
f010071a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010071f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100725:	85 c0                	test   %eax,%eax
f0100727:	0f 48 c2             	cmovs  %edx,%eax
f010072a:	c1 f8 0a             	sar    $0xa,%eax
f010072d:	50                   	push   %eax
f010072e:	68 ac 4b 10 f0       	push   $0xf0104bac
f0100733:	e8 dd 27 00 00       	call   f0102f15 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100738:	b8 00 00 00 00       	mov    $0x0,%eax
f010073d:	c9                   	leave  
f010073e:	c3                   	ret    

f010073f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010073f:	55                   	push   %ebp
f0100740:	89 e5                	mov    %esp,%ebp
f0100742:	56                   	push   %esi
f0100743:	53                   	push   %ebx
f0100744:	83 ec 20             	sub    $0x20,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100747:	89 eb                	mov    %ebp,%ebx

	struct Eipdebuginfo info;
	while(pointer)
	{
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",pointer, pointer[1], pointer[2], pointer[3], pointer[4], pointer[5], pointer[6]);
	    debuginfo_eip(pointer[1],&info);
f0100749:	8d 75 e0             	lea    -0x20(%ebp),%esi

	uint32_t *pointer;
	pointer=(uint32_t *) read_ebp();

	struct Eipdebuginfo info;
	while(pointer)
f010074c:	eb 4e                	jmp    f010079c <mon_backtrace+0x5d>
	{
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",pointer, pointer[1], pointer[2], pointer[3], pointer[4], pointer[5], pointer[6]);
f010074e:	ff 73 18             	pushl  0x18(%ebx)
f0100751:	ff 73 14             	pushl  0x14(%ebx)
f0100754:	ff 73 10             	pushl  0x10(%ebx)
f0100757:	ff 73 0c             	pushl  0xc(%ebx)
f010075a:	ff 73 08             	pushl  0x8(%ebx)
f010075d:	ff 73 04             	pushl  0x4(%ebx)
f0100760:	53                   	push   %ebx
f0100761:	68 d8 4b 10 f0       	push   $0xf0104bd8
f0100766:	e8 aa 27 00 00       	call   f0102f15 <cprintf>
	    debuginfo_eip(pointer[1],&info);
f010076b:	83 c4 18             	add    $0x18,%esp
f010076e:	56                   	push   %esi
f010076f:	ff 73 04             	pushl  0x4(%ebx)
f0100772:	e8 1b 31 00 00       	call   f0103892 <debuginfo_eip>
	    cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,(pointer[1]-info.eip_fn_addr));
f0100777:	83 c4 08             	add    $0x8,%esp
f010077a:	8b 43 04             	mov    0x4(%ebx),%eax
f010077d:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100780:	50                   	push   %eax
f0100781:	ff 75 e8             	pushl  -0x18(%ebp)
f0100784:	ff 75 ec             	pushl  -0x14(%ebp)
f0100787:	ff 75 e4             	pushl  -0x1c(%ebp)
f010078a:	ff 75 e0             	pushl  -0x20(%ebp)
f010078d:	68 80 4a 10 f0       	push   $0xf0104a80
f0100792:	e8 7e 27 00 00       	call   f0102f15 <cprintf>
	    pointer=(uint32_t *)pointer[0];
f0100797:	8b 1b                	mov    (%ebx),%ebx
f0100799:	83 c4 20             	add    $0x20,%esp

	uint32_t *pointer;
	pointer=(uint32_t *) read_ebp();

	struct Eipdebuginfo info;
	while(pointer)
f010079c:	85 db                	test   %ebx,%ebx
f010079e:	75 ae                	jne    f010074e <mon_backtrace+0xf>
	    debuginfo_eip(pointer[1],&info);
	    cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,(pointer[1]-info.eip_fn_addr));
	    pointer=(uint32_t *)pointer[0];
	}
return 0;
}
f01007a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007a8:	5b                   	pop    %ebx
f01007a9:	5e                   	pop    %esi
f01007aa:	5d                   	pop    %ebp
f01007ab:	c3                   	ret    

f01007ac <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ac:	55                   	push   %ebp
f01007ad:	89 e5                	mov    %esp,%ebp
f01007af:	57                   	push   %edi
f01007b0:	56                   	push   %esi
f01007b1:	53                   	push   %ebx
f01007b2:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007b5:	68 0c 4c 10 f0       	push   $0xf0104c0c
f01007ba:	e8 56 27 00 00       	call   f0102f15 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007bf:	c7 04 24 30 4c 10 f0 	movl   $0xf0104c30,(%esp)
f01007c6:	e8 4a 27 00 00       	call   f0102f15 <cprintf>

	if (tf != NULL)
f01007cb:	83 c4 10             	add    $0x10,%esp
f01007ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007d2:	74 0e                	je     f01007e2 <monitor+0x36>
		print_trapframe(tf);
f01007d4:	83 ec 0c             	sub    $0xc,%esp
f01007d7:	ff 75 08             	pushl  0x8(%ebp)
f01007da:	e8 70 2b 00 00       	call   f010334f <print_trapframe>
f01007df:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01007e2:	83 ec 0c             	sub    $0xc,%esp
f01007e5:	68 90 4a 10 f0       	push   $0xf0104a90
f01007ea:	e8 91 38 00 00       	call   f0104080 <readline>
f01007ef:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007f1:	83 c4 10             	add    $0x10,%esp
f01007f4:	85 c0                	test   %eax,%eax
f01007f6:	74 ea                	je     f01007e2 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007f8:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007ff:	be 00 00 00 00       	mov    $0x0,%esi
f0100804:	eb 0a                	jmp    f0100810 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100806:	c6 03 00             	movb   $0x0,(%ebx)
f0100809:	89 f7                	mov    %esi,%edi
f010080b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010080e:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100810:	0f b6 03             	movzbl (%ebx),%eax
f0100813:	84 c0                	test   %al,%al
f0100815:	74 63                	je     f010087a <monitor+0xce>
f0100817:	83 ec 08             	sub    $0x8,%esp
f010081a:	0f be c0             	movsbl %al,%eax
f010081d:	50                   	push   %eax
f010081e:	68 94 4a 10 f0       	push   $0xf0104a94
f0100823:	e8 72 3a 00 00       	call   f010429a <strchr>
f0100828:	83 c4 10             	add    $0x10,%esp
f010082b:	85 c0                	test   %eax,%eax
f010082d:	75 d7                	jne    f0100806 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f010082f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100832:	74 46                	je     f010087a <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100834:	83 fe 0f             	cmp    $0xf,%esi
f0100837:	75 14                	jne    f010084d <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100839:	83 ec 08             	sub    $0x8,%esp
f010083c:	6a 10                	push   $0x10
f010083e:	68 99 4a 10 f0       	push   $0xf0104a99
f0100843:	e8 cd 26 00 00       	call   f0102f15 <cprintf>
f0100848:	83 c4 10             	add    $0x10,%esp
f010084b:	eb 95                	jmp    f01007e2 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010084d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100850:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100854:	eb 03                	jmp    f0100859 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100856:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100859:	0f b6 03             	movzbl (%ebx),%eax
f010085c:	84 c0                	test   %al,%al
f010085e:	74 ae                	je     f010080e <monitor+0x62>
f0100860:	83 ec 08             	sub    $0x8,%esp
f0100863:	0f be c0             	movsbl %al,%eax
f0100866:	50                   	push   %eax
f0100867:	68 94 4a 10 f0       	push   $0xf0104a94
f010086c:	e8 29 3a 00 00       	call   f010429a <strchr>
f0100871:	83 c4 10             	add    $0x10,%esp
f0100874:	85 c0                	test   %eax,%eax
f0100876:	74 de                	je     f0100856 <monitor+0xaa>
f0100878:	eb 94                	jmp    f010080e <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f010087a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100881:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100882:	85 f6                	test   %esi,%esi
f0100884:	0f 84 58 ff ff ff    	je     f01007e2 <monitor+0x36>
f010088a:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010088f:	83 ec 08             	sub    $0x8,%esp
f0100892:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100895:	ff 34 85 60 4c 10 f0 	pushl  -0xfefb3a0(,%eax,4)
f010089c:	ff 75 a8             	pushl  -0x58(%ebp)
f010089f:	e8 98 39 00 00       	call   f010423c <strcmp>
f01008a4:	83 c4 10             	add    $0x10,%esp
f01008a7:	85 c0                	test   %eax,%eax
f01008a9:	75 21                	jne    f01008cc <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f01008ab:	83 ec 04             	sub    $0x4,%esp
f01008ae:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008b1:	ff 75 08             	pushl  0x8(%ebp)
f01008b4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008b7:	52                   	push   %edx
f01008b8:	56                   	push   %esi
f01008b9:	ff 14 85 68 4c 10 f0 	call   *-0xfefb398(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008c0:	83 c4 10             	add    $0x10,%esp
f01008c3:	85 c0                	test   %eax,%eax
f01008c5:	78 25                	js     f01008ec <monitor+0x140>
f01008c7:	e9 16 ff ff ff       	jmp    f01007e2 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01008cc:	83 c3 01             	add    $0x1,%ebx
f01008cf:	83 fb 03             	cmp    $0x3,%ebx
f01008d2:	75 bb                	jne    f010088f <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008d4:	83 ec 08             	sub    $0x8,%esp
f01008d7:	ff 75 a8             	pushl  -0x58(%ebp)
f01008da:	68 b6 4a 10 f0       	push   $0xf0104ab6
f01008df:	e8 31 26 00 00       	call   f0102f15 <cprintf>
f01008e4:	83 c4 10             	add    $0x10,%esp
f01008e7:	e9 f6 fe ff ff       	jmp    f01007e2 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008ef:	5b                   	pop    %ebx
f01008f0:	5e                   	pop    %esi
f01008f1:	5f                   	pop    %edi
f01008f2:	5d                   	pop    %ebp
f01008f3:	c3                   	ret    

f01008f4 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01008f4:	55                   	push   %ebp
f01008f5:	89 e5                	mov    %esp,%ebp
f01008f7:	56                   	push   %esi
f01008f8:	53                   	push   %ebx
f01008f9:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01008fb:	83 ec 0c             	sub    $0xc,%esp
f01008fe:	50                   	push   %eax
f01008ff:	e8 aa 25 00 00       	call   f0102eae <mc146818_read>
f0100904:	89 c6                	mov    %eax,%esi
f0100906:	83 c3 01             	add    $0x1,%ebx
f0100909:	89 1c 24             	mov    %ebx,(%esp)
f010090c:	e8 9d 25 00 00       	call   f0102eae <mc146818_read>
f0100911:	c1 e0 08             	shl    $0x8,%eax
f0100914:	09 f0                	or     %esi,%eax
}
f0100916:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100919:	5b                   	pop    %ebx
f010091a:	5e                   	pop    %esi
f010091b:	5d                   	pop    %ebp
f010091c:	c3                   	ret    

f010091d <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010091d:	83 3d 38 ce 17 f0 00 	cmpl   $0x0,0xf017ce38
f0100924:	75 11                	jne    f0100937 <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100926:	ba 0f eb 17 f0       	mov    $0xf017eb0f,%edx
f010092b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100931:	89 15 38 ce 17 f0    	mov    %edx,0xf017ce38
	//
	// LAB 2: Your code here.
	
	
	
	if(n>0)
f0100937:	85 c0                	test   %eax,%eax
f0100939:	74 2e                	je     f0100969 <boot_alloc+0x4c>
	{
	result=nextfree;
f010093b:	8b 0d 38 ce 17 f0    	mov    0xf017ce38,%ecx
	nextfree +=ROUNDUP(n, PGSIZE);
f0100941:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100947:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010094d:	01 ca                	add    %ecx,%edx
f010094f:	89 15 38 ce 17 f0    	mov    %edx,0xf017ce38
	else
	{
	return nextfree;	
    }
    
    if ((uint32_t) nextfree> ((npages * PGSIZE)+KERNBASE))
f0100955:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f010095a:	05 00 00 0f 00       	add    $0xf0000,%eax
f010095f:	c1 e0 0c             	shl    $0xc,%eax
f0100962:	39 c2                	cmp    %eax,%edx
f0100964:	77 09                	ja     f010096f <boot_alloc+0x52>
    {
    panic("Out of memory \n");
    }

	return result;
f0100966:	89 c8                	mov    %ecx,%eax
f0100968:	c3                   	ret    
	nextfree +=ROUNDUP(n, PGSIZE);
	
	}
	else
	{
	return nextfree;	
f0100969:	a1 38 ce 17 f0       	mov    0xf017ce38,%eax
f010096e:	c3                   	ret    
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010096f:	55                   	push   %ebp
f0100970:	89 e5                	mov    %esp,%ebp
f0100972:	83 ec 0c             	sub    $0xc,%esp
	return nextfree;	
    }
    
    if ((uint32_t) nextfree> ((npages * PGSIZE)+KERNBASE))
    {
    panic("Out of memory \n");
f0100975:	68 84 4c 10 f0       	push   $0xf0104c84
f010097a:	6a 7a                	push   $0x7a
f010097c:	68 94 4c 10 f0       	push   $0xf0104c94
f0100981:	e8 1a f7 ff ff       	call   f01000a0 <_panic>

f0100986 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100986:	89 d1                	mov    %edx,%ecx
f0100988:	c1 e9 16             	shr    $0x16,%ecx
f010098b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010098e:	a8 01                	test   $0x1,%al
f0100990:	74 52                	je     f01009e4 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100992:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100997:	89 c1                	mov    %eax,%ecx
f0100999:	c1 e9 0c             	shr    $0xc,%ecx
f010099c:	3b 0d 04 db 17 f0    	cmp    0xf017db04,%ecx
f01009a2:	72 1b                	jb     f01009bf <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009a4:	55                   	push   %ebp
f01009a5:	89 e5                	mov    %esp,%ebp
f01009a7:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009aa:	50                   	push   %eax
f01009ab:	68 8c 4f 10 f0       	push   $0xf0104f8c
f01009b0:	68 41 03 00 00       	push   $0x341
f01009b5:	68 94 4c 10 f0       	push   $0xf0104c94
f01009ba:	e8 e1 f6 ff ff       	call   f01000a0 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009bf:	c1 ea 0c             	shr    $0xc,%edx
f01009c2:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009c8:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009cf:	89 c2                	mov    %eax,%edx
f01009d1:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009d9:	85 d2                	test   %edx,%edx
f01009db:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009e0:	0f 44 c2             	cmove  %edx,%eax
f01009e3:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009e9:	c3                   	ret    

f01009ea <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009ea:	55                   	push   %ebp
f01009eb:	89 e5                	mov    %esp,%ebp
f01009ed:	57                   	push   %edi
f01009ee:	56                   	push   %esi
f01009ef:	53                   	push   %ebx
f01009f0:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009f3:	84 c0                	test   %al,%al
f01009f5:	0f 85 72 02 00 00    	jne    f0100c6d <check_page_free_list+0x283>
f01009fb:	e9 7f 02 00 00       	jmp    f0100c7f <check_page_free_list+0x295>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a00:	83 ec 04             	sub    $0x4,%esp
f0100a03:	68 b0 4f 10 f0       	push   $0xf0104fb0
f0100a08:	68 7f 02 00 00       	push   $0x27f
f0100a0d:	68 94 4c 10 f0       	push   $0xf0104c94
f0100a12:	e8 89 f6 ff ff       	call   f01000a0 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a17:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a1a:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a1d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a20:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a23:	89 c2                	mov    %eax,%edx
f0100a25:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0100a2b:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a31:	0f 95 c2             	setne  %dl
f0100a34:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a37:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a3b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a3d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a41:	8b 00                	mov    (%eax),%eax
f0100a43:	85 c0                	test   %eax,%eax
f0100a45:	75 dc                	jne    f0100a23 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a50:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a53:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a56:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a58:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a5b:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a60:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a65:	8b 1d 40 ce 17 f0    	mov    0xf017ce40,%ebx
f0100a6b:	eb 53                	jmp    f0100ac0 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a6d:	89 d8                	mov    %ebx,%eax
f0100a6f:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0100a75:	c1 f8 03             	sar    $0x3,%eax
f0100a78:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a7b:	89 c2                	mov    %eax,%edx
f0100a7d:	c1 ea 16             	shr    $0x16,%edx
f0100a80:	39 f2                	cmp    %esi,%edx
f0100a82:	73 3a                	jae    f0100abe <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a84:	89 c2                	mov    %eax,%edx
f0100a86:	c1 ea 0c             	shr    $0xc,%edx
f0100a89:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0100a8f:	72 12                	jb     f0100aa3 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a91:	50                   	push   %eax
f0100a92:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0100a97:	6a 56                	push   $0x56
f0100a99:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0100a9e:	e8 fd f5 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100aa3:	83 ec 04             	sub    $0x4,%esp
f0100aa6:	68 80 00 00 00       	push   $0x80
f0100aab:	68 97 00 00 00       	push   $0x97
f0100ab0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ab5:	50                   	push   %eax
f0100ab6:	e8 1c 38 00 00       	call   f01042d7 <memset>
f0100abb:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100abe:	8b 1b                	mov    (%ebx),%ebx
f0100ac0:	85 db                	test   %ebx,%ebx
f0100ac2:	75 a9                	jne    f0100a6d <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ac4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ac9:	e8 4f fe ff ff       	call   f010091d <boot_alloc>
f0100ace:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ad1:	8b 15 40 ce 17 f0    	mov    0xf017ce40,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ad7:	8b 0d 0c db 17 f0    	mov    0xf017db0c,%ecx
		assert(pp < pages + npages);
f0100add:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f0100ae2:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100ae5:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ae8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100aeb:	be 00 00 00 00       	mov    $0x0,%esi
f0100af0:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100af3:	e9 30 01 00 00       	jmp    f0100c28 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100af8:	39 ca                	cmp    %ecx,%edx
f0100afa:	73 19                	jae    f0100b15 <check_page_free_list+0x12b>
f0100afc:	68 ae 4c 10 f0       	push   $0xf0104cae
f0100b01:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100b06:	68 99 02 00 00       	push   $0x299
f0100b0b:	68 94 4c 10 f0       	push   $0xf0104c94
f0100b10:	e8 8b f5 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100b15:	39 fa                	cmp    %edi,%edx
f0100b17:	72 19                	jb     f0100b32 <check_page_free_list+0x148>
f0100b19:	68 cf 4c 10 f0       	push   $0xf0104ccf
f0100b1e:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100b23:	68 9a 02 00 00       	push   $0x29a
f0100b28:	68 94 4c 10 f0       	push   $0xf0104c94
f0100b2d:	e8 6e f5 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b32:	89 d0                	mov    %edx,%eax
f0100b34:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b37:	a8 07                	test   $0x7,%al
f0100b39:	74 19                	je     f0100b54 <check_page_free_list+0x16a>
f0100b3b:	68 d4 4f 10 f0       	push   $0xf0104fd4
f0100b40:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100b45:	68 9b 02 00 00       	push   $0x29b
f0100b4a:	68 94 4c 10 f0       	push   $0xf0104c94
f0100b4f:	e8 4c f5 ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b54:	c1 f8 03             	sar    $0x3,%eax
f0100b57:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b5a:	85 c0                	test   %eax,%eax
f0100b5c:	75 19                	jne    f0100b77 <check_page_free_list+0x18d>
f0100b5e:	68 e3 4c 10 f0       	push   $0xf0104ce3
f0100b63:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100b68:	68 9e 02 00 00       	push   $0x29e
f0100b6d:	68 94 4c 10 f0       	push   $0xf0104c94
f0100b72:	e8 29 f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b77:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b7c:	75 19                	jne    f0100b97 <check_page_free_list+0x1ad>
f0100b7e:	68 f4 4c 10 f0       	push   $0xf0104cf4
f0100b83:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100b88:	68 9f 02 00 00       	push   $0x29f
f0100b8d:	68 94 4c 10 f0       	push   $0xf0104c94
f0100b92:	e8 09 f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b97:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b9c:	75 19                	jne    f0100bb7 <check_page_free_list+0x1cd>
f0100b9e:	68 08 50 10 f0       	push   $0xf0105008
f0100ba3:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100ba8:	68 a0 02 00 00       	push   $0x2a0
f0100bad:	68 94 4c 10 f0       	push   $0xf0104c94
f0100bb2:	e8 e9 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bb7:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bbc:	75 19                	jne    f0100bd7 <check_page_free_list+0x1ed>
f0100bbe:	68 0d 4d 10 f0       	push   $0xf0104d0d
f0100bc3:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100bc8:	68 a1 02 00 00       	push   $0x2a1
f0100bcd:	68 94 4c 10 f0       	push   $0xf0104c94
f0100bd2:	e8 c9 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bd7:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100bdc:	76 3f                	jbe    f0100c1d <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bde:	89 c3                	mov    %eax,%ebx
f0100be0:	c1 eb 0c             	shr    $0xc,%ebx
f0100be3:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100be6:	77 12                	ja     f0100bfa <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100be8:	50                   	push   %eax
f0100be9:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0100bee:	6a 56                	push   $0x56
f0100bf0:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0100bf5:	e8 a6 f4 ff ff       	call   f01000a0 <_panic>
f0100bfa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bff:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c02:	76 1e                	jbe    f0100c22 <check_page_free_list+0x238>
f0100c04:	68 2c 50 10 f0       	push   $0xf010502c
f0100c09:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100c0e:	68 a2 02 00 00       	push   $0x2a2
f0100c13:	68 94 4c 10 f0       	push   $0xf0104c94
f0100c18:	e8 83 f4 ff ff       	call   f01000a0 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c1d:	83 c6 01             	add    $0x1,%esi
f0100c20:	eb 04                	jmp    f0100c26 <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100c22:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c26:	8b 12                	mov    (%edx),%edx
f0100c28:	85 d2                	test   %edx,%edx
f0100c2a:	0f 85 c8 fe ff ff    	jne    f0100af8 <check_page_free_list+0x10e>
f0100c30:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c33:	85 f6                	test   %esi,%esi
f0100c35:	7f 19                	jg     f0100c50 <check_page_free_list+0x266>
f0100c37:	68 27 4d 10 f0       	push   $0xf0104d27
f0100c3c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100c41:	68 aa 02 00 00       	push   $0x2aa
f0100c46:	68 94 4c 10 f0       	push   $0xf0104c94
f0100c4b:	e8 50 f4 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100c50:	85 db                	test   %ebx,%ebx
f0100c52:	7f 42                	jg     f0100c96 <check_page_free_list+0x2ac>
f0100c54:	68 39 4d 10 f0       	push   $0xf0104d39
f0100c59:	68 ba 4c 10 f0       	push   $0xf0104cba
f0100c5e:	68 ab 02 00 00       	push   $0x2ab
f0100c63:	68 94 4c 10 f0       	push   $0xf0104c94
f0100c68:	e8 33 f4 ff ff       	call   f01000a0 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c6d:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f0100c72:	85 c0                	test   %eax,%eax
f0100c74:	0f 85 9d fd ff ff    	jne    f0100a17 <check_page_free_list+0x2d>
f0100c7a:	e9 81 fd ff ff       	jmp    f0100a00 <check_page_free_list+0x16>
f0100c7f:	83 3d 40 ce 17 f0 00 	cmpl   $0x0,0xf017ce40
f0100c86:	0f 84 74 fd ff ff    	je     f0100a00 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c8c:	be 00 04 00 00       	mov    $0x400,%esi
f0100c91:	e9 cf fd ff ff       	jmp    f0100a65 <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c99:	5b                   	pop    %ebx
f0100c9a:	5e                   	pop    %esi
f0100c9b:	5f                   	pop    %edi
f0100c9c:	5d                   	pop    %ebp
f0100c9d:	c3                   	ret    

f0100c9e <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100c9e:	55                   	push   %ebp
f0100c9f:	89 e5                	mov    %esp,%ebp
f0100ca1:	53                   	push   %ebx
f0100ca2:	83 ec 04             	sub    $0x4,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100caa:	eb 4d                	jmp    f0100cf9 <page_init+0x5b>
	if(i==0 ||(i>=(IOPHYSMEM/PGSIZE)&&i<=(((uint32_t)boot_alloc(0)-KERNBASE)/PGSIZE)))
f0100cac:	85 db                	test   %ebx,%ebx
f0100cae:	74 46                	je     f0100cf6 <page_init+0x58>
f0100cb0:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100cb6:	76 16                	jbe    f0100cce <page_init+0x30>
f0100cb8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cbd:	e8 5b fc ff ff       	call   f010091d <boot_alloc>
f0100cc2:	05 00 00 00 10       	add    $0x10000000,%eax
f0100cc7:	c1 e8 0c             	shr    $0xc,%eax
f0100cca:	39 c3                	cmp    %eax,%ebx
f0100ccc:	76 28                	jbe    f0100cf6 <page_init+0x58>
f0100cce:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
	continue;

		pages[i].pp_ref = 0;
f0100cd5:	89 c2                	mov    %eax,%edx
f0100cd7:	03 15 0c db 17 f0    	add    0xf017db0c,%edx
f0100cdd:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100ce3:	8b 0d 40 ce 17 f0    	mov    0xf017ce40,%ecx
f0100ce9:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100ceb:	03 05 0c db 17 f0    	add    0xf017db0c,%eax
f0100cf1:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100cf6:	83 c3 01             	add    $0x1,%ebx
f0100cf9:	3b 1d 04 db 17 f0    	cmp    0xf017db04,%ebx
f0100cff:	72 ab                	jb     f0100cac <page_init+0xe>
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	
	}
}
f0100d01:	83 c4 04             	add    $0x4,%esp
f0100d04:	5b                   	pop    %ebx
f0100d05:	5d                   	pop    %ebp
f0100d06:	c3                   	ret    

f0100d07 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100d07:	55                   	push   %ebp
f0100d08:	89 e5                	mov    %esp,%ebp
f0100d0a:	53                   	push   %ebx
f0100d0b:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo *tempage;
	
	if (page_free_list == NULL)
f0100d0e:	8b 1d 40 ce 17 f0    	mov    0xf017ce40,%ebx
f0100d14:	85 db                	test   %ebx,%ebx
f0100d16:	74 58                	je     f0100d70 <page_alloc+0x69>
		return NULL;

  	tempage= page_free_list;
  	page_free_list = tempage->pp_link;
f0100d18:	8b 03                	mov    (%ebx),%eax
f0100d1a:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
  	tempage->pp_link = NULL;
f0100d1f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (alloc_flags & ALLOC_ZERO)
f0100d25:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d29:	74 45                	je     f0100d70 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d2b:	89 d8                	mov    %ebx,%eax
f0100d2d:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0100d33:	c1 f8 03             	sar    $0x3,%eax
f0100d36:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d39:	89 c2                	mov    %eax,%edx
f0100d3b:	c1 ea 0c             	shr    $0xc,%edx
f0100d3e:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0100d44:	72 12                	jb     f0100d58 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d46:	50                   	push   %eax
f0100d47:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0100d4c:	6a 56                	push   $0x56
f0100d4e:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0100d53:	e8 48 f3 ff ff       	call   f01000a0 <_panic>
		memset(page2kva(tempage), 0, PGSIZE); 
f0100d58:	83 ec 04             	sub    $0x4,%esp
f0100d5b:	68 00 10 00 00       	push   $0x1000
f0100d60:	6a 00                	push   $0x0
f0100d62:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d67:	50                   	push   %eax
f0100d68:	e8 6a 35 00 00       	call   f01042d7 <memset>
f0100d6d:	83 c4 10             	add    $0x10,%esp

  	return tempage;
	

}
f0100d70:	89 d8                	mov    %ebx,%eax
f0100d72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d75:	c9                   	leave  
f0100d76:	c3                   	ret    

f0100d77 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100d77:	55                   	push   %ebp
f0100d78:	89 e5                	mov    %esp,%ebp
f0100d7a:	83 ec 08             	sub    $0x8,%esp
f0100d7d:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref==0)
f0100d80:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100d85:	75 0f                	jne    f0100d96 <page_free+0x1f>
	{
	pp->pp_link=page_free_list;
f0100d87:	8b 15 40 ce 17 f0    	mov    0xf017ce40,%edx
f0100d8d:	89 10                	mov    %edx,(%eax)
	page_free_list=pp;	
f0100d8f:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
	}
	else
	panic("page ref not zero \n");
}
f0100d94:	eb 17                	jmp    f0100dad <page_free+0x36>
	{
	pp->pp_link=page_free_list;
	page_free_list=pp;	
	}
	else
	panic("page ref not zero \n");
f0100d96:	83 ec 04             	sub    $0x4,%esp
f0100d99:	68 4a 4d 10 f0       	push   $0xf0104d4a
f0100d9e:	68 69 01 00 00       	push   $0x169
f0100da3:	68 94 4c 10 f0       	push   $0xf0104c94
f0100da8:	e8 f3 f2 ff ff       	call   f01000a0 <_panic>
}
f0100dad:	c9                   	leave  
f0100dae:	c3                   	ret    

f0100daf <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100daf:	55                   	push   %ebp
f0100db0:	89 e5                	mov    %esp,%ebp
f0100db2:	83 ec 08             	sub    $0x8,%esp
f0100db5:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100db8:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100dbc:	83 e8 01             	sub    $0x1,%eax
f0100dbf:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100dc3:	66 85 c0             	test   %ax,%ax
f0100dc6:	75 0c                	jne    f0100dd4 <page_decref+0x25>
		page_free(pp);
f0100dc8:	83 ec 0c             	sub    $0xc,%esp
f0100dcb:	52                   	push   %edx
f0100dcc:	e8 a6 ff ff ff       	call   f0100d77 <page_free>
f0100dd1:	83 c4 10             	add    $0x10,%esp
}
f0100dd4:	c9                   	leave  
f0100dd5:	c3                   	ret    

f0100dd6 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100dd6:	55                   	push   %ebp
f0100dd7:	89 e5                	mov    %esp,%ebp
f0100dd9:	57                   	push   %edi
f0100dda:	56                   	push   %esi
f0100ddb:	53                   	push   %ebx
f0100ddc:	83 ec 0c             	sub    $0xc,%esp
f0100ddf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	  pde_t * pde; //va(virtual address) point to pa(physical address)
	  pte_t * pgtable; //same as pde
	  struct PageInfo *pp;

	  pde = &pgdir[PDX(va)]; // va->pgdir
f0100de2:	89 de                	mov    %ebx,%esi
f0100de4:	c1 ee 16             	shr    $0x16,%esi
f0100de7:	c1 e6 02             	shl    $0x2,%esi
f0100dea:	03 75 08             	add    0x8(%ebp),%esi
	  if(*pde & PTE_P) { 
f0100ded:	8b 06                	mov    (%esi),%eax
f0100def:	a8 01                	test   $0x1,%al
f0100df1:	74 2f                	je     f0100e22 <pgdir_walk+0x4c>
	  	pgtable = (KADDR(PTE_ADDR(*pde)));
f0100df3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100df8:	89 c2                	mov    %eax,%edx
f0100dfa:	c1 ea 0c             	shr    $0xc,%edx
f0100dfd:	39 15 04 db 17 f0    	cmp    %edx,0xf017db04
f0100e03:	77 15                	ja     f0100e1a <pgdir_walk+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e05:	50                   	push   %eax
f0100e06:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0100e0b:	68 96 01 00 00       	push   $0x196
f0100e10:	68 94 4c 10 f0       	push   $0xf0104c94
f0100e15:	e8 86 f2 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0100e1a:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0100e20:	eb 77                	jmp    f0100e99 <pgdir_walk+0xc3>
	  } else {
		//page table page not exist
		if(!create || 
f0100e22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e26:	74 7f                	je     f0100ea7 <pgdir_walk+0xd1>
f0100e28:	83 ec 0c             	sub    $0xc,%esp
f0100e2b:	6a 01                	push   $0x1
f0100e2d:	e8 d5 fe ff ff       	call   f0100d07 <page_alloc>
f0100e32:	83 c4 10             	add    $0x10,%esp
f0100e35:	85 c0                	test   %eax,%eax
f0100e37:	74 75                	je     f0100eae <pgdir_walk+0xd8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e39:	89 c1                	mov    %eax,%ecx
f0100e3b:	2b 0d 0c db 17 f0    	sub    0xf017db0c,%ecx
f0100e41:	c1 f9 03             	sar    $0x3,%ecx
f0100e44:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e47:	89 ca                	mov    %ecx,%edx
f0100e49:	c1 ea 0c             	shr    $0xc,%edx
f0100e4c:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0100e52:	72 12                	jb     f0100e66 <pgdir_walk+0x90>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e54:	51                   	push   %ecx
f0100e55:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0100e5a:	6a 56                	push   $0x56
f0100e5c:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0100e61:	e8 3a f2 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0100e66:	8d b9 00 00 00 f0    	lea    -0x10000000(%ecx),%edi
f0100e6c:	89 fa                	mov    %edi,%edx
		   !(pp = page_alloc(ALLOC_ZERO)) ||
f0100e6e:	85 ff                	test   %edi,%edi
f0100e70:	74 43                	je     f0100eb5 <pgdir_walk+0xdf>
		   !(pgtable = (pte_t*)page2kva(pp))) 
			return NULL;
		    
		pp->pp_ref++;
f0100e72:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e77:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0100e7d:	77 15                	ja     f0100e94 <pgdir_walk+0xbe>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e7f:	57                   	push   %edi
f0100e80:	68 74 50 10 f0       	push   $0xf0105074
f0100e85:	68 9f 01 00 00       	push   $0x19f
f0100e8a:	68 94 4c 10 f0       	push   $0xf0104c94
f0100e8f:	e8 0c f2 ff ff       	call   f01000a0 <_panic>
		*pde = PADDR(pgtable) | PTE_P | PTE_W | PTE_U;
f0100e94:	83 c9 07             	or     $0x7,%ecx
f0100e97:	89 0e                	mov    %ecx,(%esi)
	}

	return &pgtable[PTX(va)];
f0100e99:	c1 eb 0a             	shr    $0xa,%ebx
f0100e9c:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100ea2:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0100ea5:	eb 13                	jmp    f0100eba <pgdir_walk+0xe4>
	  } else {
		//page table page not exist
		if(!create || 
		   !(pp = page_alloc(ALLOC_ZERO)) ||
		   !(pgtable = (pte_t*)page2kva(pp))) 
			return NULL;
f0100ea7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eac:	eb 0c                	jmp    f0100eba <pgdir_walk+0xe4>
f0100eae:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eb3:	eb 05                	jmp    f0100eba <pgdir_walk+0xe4>
f0100eb5:	b8 00 00 00 00       	mov    $0x0,%eax
		pp->pp_ref++;
		*pde = PADDR(pgtable) | PTE_P | PTE_W | PTE_U;
	}

	return &pgtable[PTX(va)];
}
f0100eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ebd:	5b                   	pop    %ebx
f0100ebe:	5e                   	pop    %esi
f0100ebf:	5f                   	pop    %edi
f0100ec0:	5d                   	pop    %ebp
f0100ec1:	c3                   	ret    

f0100ec2 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100ec2:	55                   	push   %ebp
f0100ec3:	89 e5                	mov    %esp,%ebp
f0100ec5:	57                   	push   %edi
f0100ec6:	56                   	push   %esi
f0100ec7:	53                   	push   %ebx
f0100ec8:	83 ec 1c             	sub    $0x1c,%esp
f0100ecb:	89 45 dc             	mov    %eax,-0x24(%ebp)
	uint32_t x;
	uint32_t i=0;
	pte_t * pt; 
	x=size/PGSIZE;
f0100ece:	c1 e9 0c             	shr    $0xc,%ecx
f0100ed1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	while(i<x)
f0100ed4:	89 d6                	mov    %edx,%esi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	uint32_t x;
	uint32_t i=0;
f0100ed6:	bf 00 00 00 00       	mov    $0x0,%edi
f0100edb:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ede:	29 d0                	sub    %edx,%eax
f0100ee0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pte_t * pt; 
	x=size/PGSIZE;
	while(i<x)
	{
		pt=pgdir_walk(pgdir,(void*)va,1);
		*pt=(PTE_ADDR(pa) | perm | PTE_P);
f0100ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ee6:	83 c8 01             	or     $0x1,%eax
f0100ee9:	89 45 d8             	mov    %eax,-0x28(%ebp)
{
	uint32_t x;
	uint32_t i=0;
	pte_t * pt; 
	x=size/PGSIZE;
	while(i<x)
f0100eec:	eb 25                	jmp    f0100f13 <boot_map_region+0x51>
	{
		pt=pgdir_walk(pgdir,(void*)va,1);
f0100eee:	83 ec 04             	sub    $0x4,%esp
f0100ef1:	6a 01                	push   $0x1
f0100ef3:	56                   	push   %esi
f0100ef4:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ef7:	e8 da fe ff ff       	call   f0100dd6 <pgdir_walk>
		*pt=(PTE_ADDR(pa) | perm | PTE_P);
f0100efc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0100f02:	0b 5d d8             	or     -0x28(%ebp),%ebx
f0100f05:	89 18                	mov    %ebx,(%eax)
		va+=PGSIZE;
f0100f07:	81 c6 00 10 00 00    	add    $0x1000,%esi
		pa+=PGSIZE;
		i++;
f0100f0d:	83 c7 01             	add    $0x1,%edi
f0100f10:	83 c4 10             	add    $0x10,%esp
f0100f13:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f16:	8d 1c 30             	lea    (%eax,%esi,1),%ebx
{
	uint32_t x;
	uint32_t i=0;
	pte_t * pt; 
	x=size/PGSIZE;
	while(i<x)
f0100f19:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0100f1c:	75 d0                	jne    f0100eee <boot_map_region+0x2c>
		va+=PGSIZE;
		pa+=PGSIZE;
		i++;
	}
	// Fill this function in
}
f0100f1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f21:	5b                   	pop    %ebx
f0100f22:	5e                   	pop    %esi
f0100f23:	5f                   	pop    %edi
f0100f24:	5d                   	pop    %ebp
f0100f25:	c3                   	ret    

f0100f26 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f26:	55                   	push   %ebp
f0100f27:	89 e5                	mov    %esp,%ebp
f0100f29:	83 ec 0c             	sub    $0xc,%esp
	pte_t * pt = pgdir_walk(pgdir, va, 0);
f0100f2c:	6a 00                	push   $0x0
f0100f2e:	ff 75 0c             	pushl  0xc(%ebp)
f0100f31:	ff 75 08             	pushl  0x8(%ebp)
f0100f34:	e8 9d fe ff ff       	call   f0100dd6 <pgdir_walk>
	
	if(pt == NULL)
f0100f39:	83 c4 10             	add    $0x10,%esp
f0100f3c:	85 c0                	test   %eax,%eax
f0100f3e:	74 31                	je     f0100f71 <page_lookup+0x4b>
	return NULL;
	
	*pte_store = pt;
f0100f40:	8b 55 10             	mov    0x10(%ebp),%edx
f0100f43:	89 02                	mov    %eax,(%edx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f45:	8b 00                	mov    (%eax),%eax
f0100f47:	c1 e8 0c             	shr    $0xc,%eax
f0100f4a:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0100f50:	72 14                	jb     f0100f66 <page_lookup+0x40>
		panic("pa2page called with invalid pa");
f0100f52:	83 ec 04             	sub    $0x4,%esp
f0100f55:	68 98 50 10 f0       	push   $0xf0105098
f0100f5a:	6a 4f                	push   $0x4f
f0100f5c:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0100f61:	e8 3a f1 ff ff       	call   f01000a0 <_panic>
	return &pages[PGNUM(pa)];
f0100f66:	8b 15 0c db 17 f0    	mov    0xf017db0c,%edx
f0100f6c:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	
  return pa2page(PTE_ADDR(*pt));	
f0100f6f:	eb 05                	jmp    f0100f76 <page_lookup+0x50>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t * pt = pgdir_walk(pgdir, va, 0);
	
	if(pt == NULL)
	return NULL;
f0100f71:	b8 00 00 00 00       	mov    $0x0,%eax
	
	*pte_store = pt;
	
  return pa2page(PTE_ADDR(*pt));	

}
f0100f76:	c9                   	leave  
f0100f77:	c3                   	ret    

f0100f78 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f78:	55                   	push   %ebp
f0100f79:	89 e5                	mov    %esp,%ebp
f0100f7b:	53                   	push   %ebx
f0100f7c:	83 ec 18             	sub    $0x18,%esp
f0100f7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *page = NULL;
	pte_t *pt = NULL;
f0100f82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	if ((page = page_lookup(pgdir, va, &pt)) != NULL){
f0100f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f8c:	50                   	push   %eax
f0100f8d:	53                   	push   %ebx
f0100f8e:	ff 75 08             	pushl  0x8(%ebp)
f0100f91:	e8 90 ff ff ff       	call   f0100f26 <page_lookup>
f0100f96:	83 c4 10             	add    $0x10,%esp
f0100f99:	85 c0                	test   %eax,%eax
f0100f9b:	74 0f                	je     f0100fac <page_remove+0x34>
		page_decref(page);
f0100f9d:	83 ec 0c             	sub    $0xc,%esp
f0100fa0:	50                   	push   %eax
f0100fa1:	e8 09 fe ff ff       	call   f0100daf <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100fa6:	0f 01 3b             	invlpg (%ebx)
f0100fa9:	83 c4 10             	add    $0x10,%esp
		tlb_invalidate(pgdir, va);
	}
	*pt=0;
f0100fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100faf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f0100fb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fb8:	c9                   	leave  
f0100fb9:	c3                   	ret    

f0100fba <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100fba:	55                   	push   %ebp
f0100fbb:	89 e5                	mov    %esp,%ebp
f0100fbd:	57                   	push   %edi
f0100fbe:	56                   	push   %esi
f0100fbf:	53                   	push   %ebx
f0100fc0:	83 ec 10             	sub    $0x10,%esp
f0100fc3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fc6:	8b 7d 10             	mov    0x10(%ebp),%edi
pte_t *pte = pgdir_walk(pgdir, va, 1);
f0100fc9:	6a 01                	push   $0x1
f0100fcb:	57                   	push   %edi
f0100fcc:	ff 75 08             	pushl  0x8(%ebp)
f0100fcf:	e8 02 fe ff ff       	call   f0100dd6 <pgdir_walk>
 

    if (pte != NULL) {
f0100fd4:	83 c4 10             	add    $0x10,%esp
f0100fd7:	85 c0                	test   %eax,%eax
f0100fd9:	74 4a                	je     f0101025 <page_insert+0x6b>
f0100fdb:	89 c3                	mov    %eax,%ebx
     
        if (*pte & PTE_P)
f0100fdd:	f6 00 01             	testb  $0x1,(%eax)
f0100fe0:	74 0f                	je     f0100ff1 <page_insert+0x37>
            page_remove(pgdir, va);
f0100fe2:	83 ec 08             	sub    $0x8,%esp
f0100fe5:	57                   	push   %edi
f0100fe6:	ff 75 08             	pushl  0x8(%ebp)
f0100fe9:	e8 8a ff ff ff       	call   f0100f78 <page_remove>
f0100fee:	83 c4 10             	add    $0x10,%esp
   
       if (page_free_list == pp)
f0100ff1:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f0100ff6:	39 f0                	cmp    %esi,%eax
f0100ff8:	75 07                	jne    f0101001 <page_insert+0x47>
            page_free_list = page_free_list->pp_link;
f0100ffa:	8b 00                	mov    (%eax),%eax
f0100ffc:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40
    }
    else {
    
            return -E_NO_MEM;
    }
    *pte = page2pa(pp) | perm | PTE_P;
f0101001:	89 f0                	mov    %esi,%eax
f0101003:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101009:	c1 f8 03             	sar    $0x3,%eax
f010100c:	c1 e0 0c             	shl    $0xc,%eax
f010100f:	8b 55 14             	mov    0x14(%ebp),%edx
f0101012:	83 ca 01             	or     $0x1,%edx
f0101015:	09 d0                	or     %edx,%eax
f0101017:	89 03                	mov    %eax,(%ebx)
    pp->pp_ref++;
f0101019:	66 83 46 04 01       	addw   $0x1,0x4(%esi)

return 0;
f010101e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101023:	eb 05                	jmp    f010102a <page_insert+0x70>
       if (page_free_list == pp)
            page_free_list = page_free_list->pp_link;
    }
    else {
    
            return -E_NO_MEM;
f0101025:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    *pte = page2pa(pp) | perm | PTE_P;
    pp->pp_ref++;

return 0;
	
}
f010102a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010102d:	5b                   	pop    %ebx
f010102e:	5e                   	pop    %esi
f010102f:	5f                   	pop    %edi
f0101030:	5d                   	pop    %ebp
f0101031:	c3                   	ret    

f0101032 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101032:	55                   	push   %ebp
f0101033:	89 e5                	mov    %esp,%ebp
f0101035:	57                   	push   %edi
f0101036:	56                   	push   %esi
f0101037:	53                   	push   %ebx
f0101038:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010103b:	b8 15 00 00 00       	mov    $0x15,%eax
f0101040:	e8 af f8 ff ff       	call   f01008f4 <nvram_read>
f0101045:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101047:	b8 17 00 00 00       	mov    $0x17,%eax
f010104c:	e8 a3 f8 ff ff       	call   f01008f4 <nvram_read>
f0101051:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101053:	b8 34 00 00 00       	mov    $0x34,%eax
f0101058:	e8 97 f8 ff ff       	call   f01008f4 <nvram_read>
f010105d:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101060:	85 c0                	test   %eax,%eax
f0101062:	74 07                	je     f010106b <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101064:	05 00 40 00 00       	add    $0x4000,%eax
f0101069:	eb 0b                	jmp    f0101076 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f010106b:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101071:	85 f6                	test   %esi,%esi
f0101073:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101076:	89 c2                	mov    %eax,%edx
f0101078:	c1 ea 02             	shr    $0x2,%edx
f010107b:	89 15 04 db 17 f0    	mov    %edx,0xf017db04
	npages_basemem = basemem / (PGSIZE / 1024);
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101081:	89 c2                	mov    %eax,%edx
f0101083:	29 da                	sub    %ebx,%edx
f0101085:	52                   	push   %edx
f0101086:	53                   	push   %ebx
f0101087:	50                   	push   %eax
f0101088:	68 b8 50 10 f0       	push   $0xf01050b8
f010108d:	e8 83 1e 00 00       	call   f0102f15 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101092:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101097:	e8 81 f8 ff ff       	call   f010091d <boot_alloc>
f010109c:	a3 08 db 17 f0       	mov    %eax,0xf017db08
	memset(kern_pgdir, 0, PGSIZE);
f01010a1:	83 c4 0c             	add    $0xc,%esp
f01010a4:	68 00 10 00 00       	push   $0x1000
f01010a9:	6a 00                	push   $0x0
f01010ab:	50                   	push   %eax
f01010ac:	e8 26 32 00 00       	call   f01042d7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01010b1:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01010b6:	83 c4 10             	add    $0x10,%esp
f01010b9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010be:	77 15                	ja     f01010d5 <mem_init+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010c0:	50                   	push   %eax
f01010c1:	68 74 50 10 f0       	push   $0xf0105074
f01010c6:	68 a1 00 00 00       	push   $0xa1
f01010cb:	68 94 4c 10 f0       	push   $0xf0104c94
f01010d0:	e8 cb ef ff ff       	call   f01000a0 <_panic>
f01010d5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01010db:	83 ca 05             	or     $0x5,%edx
f01010de:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages=(struct PageInfo *)boot_alloc(sizeof(struct PageInfo)*npages);
f01010e4:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f01010e9:	c1 e0 03             	shl    $0x3,%eax
f01010ec:	e8 2c f8 ff ff       	call   f010091d <boot_alloc>
f01010f1:	a3 0c db 17 f0       	mov    %eax,0xf017db0c
	memset(pages,0,sizeof(struct PageInfo)*npages);
f01010f6:	83 ec 04             	sub    $0x4,%esp
f01010f9:	8b 3d 04 db 17 f0    	mov    0xf017db04,%edi
f01010ff:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0101106:	52                   	push   %edx
f0101107:	6a 00                	push   $0x0
f0101109:	50                   	push   %eax
f010110a:	e8 c8 31 00 00       	call   f01042d7 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	
	
	envs=(struct Env *)boot_alloc(sizeof(struct Env)*NENV);
f010110f:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101114:	e8 04 f8 ff ff       	call   f010091d <boot_alloc>
f0101119:	a3 48 ce 17 f0       	mov    %eax,0xf017ce48
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010111e:	e8 7b fb ff ff       	call   f0100c9e <page_init>

	check_page_free_list(1);
f0101123:	b8 01 00 00 00       	mov    $0x1,%eax
f0101128:	e8 bd f8 ff ff       	call   f01009ea <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010112d:	83 c4 10             	add    $0x10,%esp
f0101130:	83 3d 0c db 17 f0 00 	cmpl   $0x0,0xf017db0c
f0101137:	75 17                	jne    f0101150 <mem_init+0x11e>
		panic("'pages' is a null pointer!");
f0101139:	83 ec 04             	sub    $0x4,%esp
f010113c:	68 5e 4d 10 f0       	push   $0xf0104d5e
f0101141:	68 bc 02 00 00       	push   $0x2bc
f0101146:	68 94 4c 10 f0       	push   $0xf0104c94
f010114b:	e8 50 ef ff ff       	call   f01000a0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101150:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f0101155:	bb 00 00 00 00       	mov    $0x0,%ebx
f010115a:	eb 05                	jmp    f0101161 <mem_init+0x12f>
		++nfree;
f010115c:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010115f:	8b 00                	mov    (%eax),%eax
f0101161:	85 c0                	test   %eax,%eax
f0101163:	75 f7                	jne    f010115c <mem_init+0x12a>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101165:	83 ec 0c             	sub    $0xc,%esp
f0101168:	6a 00                	push   $0x0
f010116a:	e8 98 fb ff ff       	call   f0100d07 <page_alloc>
f010116f:	89 c7                	mov    %eax,%edi
f0101171:	83 c4 10             	add    $0x10,%esp
f0101174:	85 c0                	test   %eax,%eax
f0101176:	75 19                	jne    f0101191 <mem_init+0x15f>
f0101178:	68 79 4d 10 f0       	push   $0xf0104d79
f010117d:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101182:	68 c4 02 00 00       	push   $0x2c4
f0101187:	68 94 4c 10 f0       	push   $0xf0104c94
f010118c:	e8 0f ef ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101191:	83 ec 0c             	sub    $0xc,%esp
f0101194:	6a 00                	push   $0x0
f0101196:	e8 6c fb ff ff       	call   f0100d07 <page_alloc>
f010119b:	89 c6                	mov    %eax,%esi
f010119d:	83 c4 10             	add    $0x10,%esp
f01011a0:	85 c0                	test   %eax,%eax
f01011a2:	75 19                	jne    f01011bd <mem_init+0x18b>
f01011a4:	68 8f 4d 10 f0       	push   $0xf0104d8f
f01011a9:	68 ba 4c 10 f0       	push   $0xf0104cba
f01011ae:	68 c5 02 00 00       	push   $0x2c5
f01011b3:	68 94 4c 10 f0       	push   $0xf0104c94
f01011b8:	e8 e3 ee ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01011bd:	83 ec 0c             	sub    $0xc,%esp
f01011c0:	6a 00                	push   $0x0
f01011c2:	e8 40 fb ff ff       	call   f0100d07 <page_alloc>
f01011c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011ca:	83 c4 10             	add    $0x10,%esp
f01011cd:	85 c0                	test   %eax,%eax
f01011cf:	75 19                	jne    f01011ea <mem_init+0x1b8>
f01011d1:	68 a5 4d 10 f0       	push   $0xf0104da5
f01011d6:	68 ba 4c 10 f0       	push   $0xf0104cba
f01011db:	68 c6 02 00 00       	push   $0x2c6
f01011e0:	68 94 4c 10 f0       	push   $0xf0104c94
f01011e5:	e8 b6 ee ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01011ea:	39 f7                	cmp    %esi,%edi
f01011ec:	75 19                	jne    f0101207 <mem_init+0x1d5>
f01011ee:	68 bb 4d 10 f0       	push   $0xf0104dbb
f01011f3:	68 ba 4c 10 f0       	push   $0xf0104cba
f01011f8:	68 c9 02 00 00       	push   $0x2c9
f01011fd:	68 94 4c 10 f0       	push   $0xf0104c94
f0101202:	e8 99 ee ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101207:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010120a:	39 c6                	cmp    %eax,%esi
f010120c:	74 04                	je     f0101212 <mem_init+0x1e0>
f010120e:	39 c7                	cmp    %eax,%edi
f0101210:	75 19                	jne    f010122b <mem_init+0x1f9>
f0101212:	68 f4 50 10 f0       	push   $0xf01050f4
f0101217:	68 ba 4c 10 f0       	push   $0xf0104cba
f010121c:	68 ca 02 00 00       	push   $0x2ca
f0101221:	68 94 4c 10 f0       	push   $0xf0104c94
f0101226:	e8 75 ee ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010122b:	8b 0d 0c db 17 f0    	mov    0xf017db0c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101231:	8b 15 04 db 17 f0    	mov    0xf017db04,%edx
f0101237:	c1 e2 0c             	shl    $0xc,%edx
f010123a:	89 f8                	mov    %edi,%eax
f010123c:	29 c8                	sub    %ecx,%eax
f010123e:	c1 f8 03             	sar    $0x3,%eax
f0101241:	c1 e0 0c             	shl    $0xc,%eax
f0101244:	39 d0                	cmp    %edx,%eax
f0101246:	72 19                	jb     f0101261 <mem_init+0x22f>
f0101248:	68 cd 4d 10 f0       	push   $0xf0104dcd
f010124d:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101252:	68 cb 02 00 00       	push   $0x2cb
f0101257:	68 94 4c 10 f0       	push   $0xf0104c94
f010125c:	e8 3f ee ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101261:	89 f0                	mov    %esi,%eax
f0101263:	29 c8                	sub    %ecx,%eax
f0101265:	c1 f8 03             	sar    $0x3,%eax
f0101268:	c1 e0 0c             	shl    $0xc,%eax
f010126b:	39 c2                	cmp    %eax,%edx
f010126d:	77 19                	ja     f0101288 <mem_init+0x256>
f010126f:	68 ea 4d 10 f0       	push   $0xf0104dea
f0101274:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101279:	68 cc 02 00 00       	push   $0x2cc
f010127e:	68 94 4c 10 f0       	push   $0xf0104c94
f0101283:	e8 18 ee ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101288:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010128b:	29 c8                	sub    %ecx,%eax
f010128d:	c1 f8 03             	sar    $0x3,%eax
f0101290:	c1 e0 0c             	shl    $0xc,%eax
f0101293:	39 c2                	cmp    %eax,%edx
f0101295:	77 19                	ja     f01012b0 <mem_init+0x27e>
f0101297:	68 07 4e 10 f0       	push   $0xf0104e07
f010129c:	68 ba 4c 10 f0       	push   $0xf0104cba
f01012a1:	68 cd 02 00 00       	push   $0x2cd
f01012a6:	68 94 4c 10 f0       	push   $0xf0104c94
f01012ab:	e8 f0 ed ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01012b0:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f01012b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01012b8:	c7 05 40 ce 17 f0 00 	movl   $0x0,0xf017ce40
f01012bf:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01012c2:	83 ec 0c             	sub    $0xc,%esp
f01012c5:	6a 00                	push   $0x0
f01012c7:	e8 3b fa ff ff       	call   f0100d07 <page_alloc>
f01012cc:	83 c4 10             	add    $0x10,%esp
f01012cf:	85 c0                	test   %eax,%eax
f01012d1:	74 19                	je     f01012ec <mem_init+0x2ba>
f01012d3:	68 24 4e 10 f0       	push   $0xf0104e24
f01012d8:	68 ba 4c 10 f0       	push   $0xf0104cba
f01012dd:	68 d4 02 00 00       	push   $0x2d4
f01012e2:	68 94 4c 10 f0       	push   $0xf0104c94
f01012e7:	e8 b4 ed ff ff       	call   f01000a0 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01012ec:	83 ec 0c             	sub    $0xc,%esp
f01012ef:	57                   	push   %edi
f01012f0:	e8 82 fa ff ff       	call   f0100d77 <page_free>
	page_free(pp1);
f01012f5:	89 34 24             	mov    %esi,(%esp)
f01012f8:	e8 7a fa ff ff       	call   f0100d77 <page_free>
	page_free(pp2);
f01012fd:	83 c4 04             	add    $0x4,%esp
f0101300:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101303:	e8 6f fa ff ff       	call   f0100d77 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101308:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010130f:	e8 f3 f9 ff ff       	call   f0100d07 <page_alloc>
f0101314:	89 c6                	mov    %eax,%esi
f0101316:	83 c4 10             	add    $0x10,%esp
f0101319:	85 c0                	test   %eax,%eax
f010131b:	75 19                	jne    f0101336 <mem_init+0x304>
f010131d:	68 79 4d 10 f0       	push   $0xf0104d79
f0101322:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101327:	68 db 02 00 00       	push   $0x2db
f010132c:	68 94 4c 10 f0       	push   $0xf0104c94
f0101331:	e8 6a ed ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101336:	83 ec 0c             	sub    $0xc,%esp
f0101339:	6a 00                	push   $0x0
f010133b:	e8 c7 f9 ff ff       	call   f0100d07 <page_alloc>
f0101340:	89 c7                	mov    %eax,%edi
f0101342:	83 c4 10             	add    $0x10,%esp
f0101345:	85 c0                	test   %eax,%eax
f0101347:	75 19                	jne    f0101362 <mem_init+0x330>
f0101349:	68 8f 4d 10 f0       	push   $0xf0104d8f
f010134e:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101353:	68 dc 02 00 00       	push   $0x2dc
f0101358:	68 94 4c 10 f0       	push   $0xf0104c94
f010135d:	e8 3e ed ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101362:	83 ec 0c             	sub    $0xc,%esp
f0101365:	6a 00                	push   $0x0
f0101367:	e8 9b f9 ff ff       	call   f0100d07 <page_alloc>
f010136c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010136f:	83 c4 10             	add    $0x10,%esp
f0101372:	85 c0                	test   %eax,%eax
f0101374:	75 19                	jne    f010138f <mem_init+0x35d>
f0101376:	68 a5 4d 10 f0       	push   $0xf0104da5
f010137b:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101380:	68 dd 02 00 00       	push   $0x2dd
f0101385:	68 94 4c 10 f0       	push   $0xf0104c94
f010138a:	e8 11 ed ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010138f:	39 fe                	cmp    %edi,%esi
f0101391:	75 19                	jne    f01013ac <mem_init+0x37a>
f0101393:	68 bb 4d 10 f0       	push   $0xf0104dbb
f0101398:	68 ba 4c 10 f0       	push   $0xf0104cba
f010139d:	68 df 02 00 00       	push   $0x2df
f01013a2:	68 94 4c 10 f0       	push   $0xf0104c94
f01013a7:	e8 f4 ec ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013af:	39 c7                	cmp    %eax,%edi
f01013b1:	74 04                	je     f01013b7 <mem_init+0x385>
f01013b3:	39 c6                	cmp    %eax,%esi
f01013b5:	75 19                	jne    f01013d0 <mem_init+0x39e>
f01013b7:	68 f4 50 10 f0       	push   $0xf01050f4
f01013bc:	68 ba 4c 10 f0       	push   $0xf0104cba
f01013c1:	68 e0 02 00 00       	push   $0x2e0
f01013c6:	68 94 4c 10 f0       	push   $0xf0104c94
f01013cb:	e8 d0 ec ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f01013d0:	83 ec 0c             	sub    $0xc,%esp
f01013d3:	6a 00                	push   $0x0
f01013d5:	e8 2d f9 ff ff       	call   f0100d07 <page_alloc>
f01013da:	83 c4 10             	add    $0x10,%esp
f01013dd:	85 c0                	test   %eax,%eax
f01013df:	74 19                	je     f01013fa <mem_init+0x3c8>
f01013e1:	68 24 4e 10 f0       	push   $0xf0104e24
f01013e6:	68 ba 4c 10 f0       	push   $0xf0104cba
f01013eb:	68 e1 02 00 00       	push   $0x2e1
f01013f0:	68 94 4c 10 f0       	push   $0xf0104c94
f01013f5:	e8 a6 ec ff ff       	call   f01000a0 <_panic>
f01013fa:	89 f0                	mov    %esi,%eax
f01013fc:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101402:	c1 f8 03             	sar    $0x3,%eax
f0101405:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101408:	89 c2                	mov    %eax,%edx
f010140a:	c1 ea 0c             	shr    $0xc,%edx
f010140d:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0101413:	72 12                	jb     f0101427 <mem_init+0x3f5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101415:	50                   	push   %eax
f0101416:	68 8c 4f 10 f0       	push   $0xf0104f8c
f010141b:	6a 56                	push   $0x56
f010141d:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0101422:	e8 79 ec ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101427:	83 ec 04             	sub    $0x4,%esp
f010142a:	68 00 10 00 00       	push   $0x1000
f010142f:	6a 01                	push   $0x1
f0101431:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101436:	50                   	push   %eax
f0101437:	e8 9b 2e 00 00       	call   f01042d7 <memset>
	page_free(pp0);
f010143c:	89 34 24             	mov    %esi,(%esp)
f010143f:	e8 33 f9 ff ff       	call   f0100d77 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101444:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010144b:	e8 b7 f8 ff ff       	call   f0100d07 <page_alloc>
f0101450:	83 c4 10             	add    $0x10,%esp
f0101453:	85 c0                	test   %eax,%eax
f0101455:	75 19                	jne    f0101470 <mem_init+0x43e>
f0101457:	68 33 4e 10 f0       	push   $0xf0104e33
f010145c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101461:	68 e6 02 00 00       	push   $0x2e6
f0101466:	68 94 4c 10 f0       	push   $0xf0104c94
f010146b:	e8 30 ec ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f0101470:	39 c6                	cmp    %eax,%esi
f0101472:	74 19                	je     f010148d <mem_init+0x45b>
f0101474:	68 51 4e 10 f0       	push   $0xf0104e51
f0101479:	68 ba 4c 10 f0       	push   $0xf0104cba
f010147e:	68 e7 02 00 00       	push   $0x2e7
f0101483:	68 94 4c 10 f0       	push   $0xf0104c94
f0101488:	e8 13 ec ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010148d:	89 f0                	mov    %esi,%eax
f010148f:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101495:	c1 f8 03             	sar    $0x3,%eax
f0101498:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010149b:	89 c2                	mov    %eax,%edx
f010149d:	c1 ea 0c             	shr    $0xc,%edx
f01014a0:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f01014a6:	72 12                	jb     f01014ba <mem_init+0x488>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014a8:	50                   	push   %eax
f01014a9:	68 8c 4f 10 f0       	push   $0xf0104f8c
f01014ae:	6a 56                	push   $0x56
f01014b0:	68 a0 4c 10 f0       	push   $0xf0104ca0
f01014b5:	e8 e6 eb ff ff       	call   f01000a0 <_panic>
f01014ba:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01014c0:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014c6:	80 38 00             	cmpb   $0x0,(%eax)
f01014c9:	74 19                	je     f01014e4 <mem_init+0x4b2>
f01014cb:	68 61 4e 10 f0       	push   $0xf0104e61
f01014d0:	68 ba 4c 10 f0       	push   $0xf0104cba
f01014d5:	68 ea 02 00 00       	push   $0x2ea
f01014da:	68 94 4c 10 f0       	push   $0xf0104c94
f01014df:	e8 bc eb ff ff       	call   f01000a0 <_panic>
f01014e4:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01014e7:	39 d0                	cmp    %edx,%eax
f01014e9:	75 db                	jne    f01014c6 <mem_init+0x494>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01014eb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014ee:	a3 40 ce 17 f0       	mov    %eax,0xf017ce40

	// free the pages we took
	page_free(pp0);
f01014f3:	83 ec 0c             	sub    $0xc,%esp
f01014f6:	56                   	push   %esi
f01014f7:	e8 7b f8 ff ff       	call   f0100d77 <page_free>
	page_free(pp1);
f01014fc:	89 3c 24             	mov    %edi,(%esp)
f01014ff:	e8 73 f8 ff ff       	call   f0100d77 <page_free>
	page_free(pp2);
f0101504:	83 c4 04             	add    $0x4,%esp
f0101507:	ff 75 d4             	pushl  -0x2c(%ebp)
f010150a:	e8 68 f8 ff ff       	call   f0100d77 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010150f:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f0101514:	83 c4 10             	add    $0x10,%esp
f0101517:	eb 05                	jmp    f010151e <mem_init+0x4ec>
		--nfree;
f0101519:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010151c:	8b 00                	mov    (%eax),%eax
f010151e:	85 c0                	test   %eax,%eax
f0101520:	75 f7                	jne    f0101519 <mem_init+0x4e7>
		--nfree;
	assert(nfree == 0);
f0101522:	85 db                	test   %ebx,%ebx
f0101524:	74 19                	je     f010153f <mem_init+0x50d>
f0101526:	68 6b 4e 10 f0       	push   $0xf0104e6b
f010152b:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101530:	68 f7 02 00 00       	push   $0x2f7
f0101535:	68 94 4c 10 f0       	push   $0xf0104c94
f010153a:	e8 61 eb ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010153f:	83 ec 0c             	sub    $0xc,%esp
f0101542:	68 14 51 10 f0       	push   $0xf0105114
f0101547:	e8 c9 19 00 00       	call   f0102f15 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010154c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101553:	e8 af f7 ff ff       	call   f0100d07 <page_alloc>
f0101558:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010155b:	83 c4 10             	add    $0x10,%esp
f010155e:	85 c0                	test   %eax,%eax
f0101560:	75 19                	jne    f010157b <mem_init+0x549>
f0101562:	68 79 4d 10 f0       	push   $0xf0104d79
f0101567:	68 ba 4c 10 f0       	push   $0xf0104cba
f010156c:	68 55 03 00 00       	push   $0x355
f0101571:	68 94 4c 10 f0       	push   $0xf0104c94
f0101576:	e8 25 eb ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010157b:	83 ec 0c             	sub    $0xc,%esp
f010157e:	6a 00                	push   $0x0
f0101580:	e8 82 f7 ff ff       	call   f0100d07 <page_alloc>
f0101585:	89 c3                	mov    %eax,%ebx
f0101587:	83 c4 10             	add    $0x10,%esp
f010158a:	85 c0                	test   %eax,%eax
f010158c:	75 19                	jne    f01015a7 <mem_init+0x575>
f010158e:	68 8f 4d 10 f0       	push   $0xf0104d8f
f0101593:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101598:	68 56 03 00 00       	push   $0x356
f010159d:	68 94 4c 10 f0       	push   $0xf0104c94
f01015a2:	e8 f9 ea ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01015a7:	83 ec 0c             	sub    $0xc,%esp
f01015aa:	6a 00                	push   $0x0
f01015ac:	e8 56 f7 ff ff       	call   f0100d07 <page_alloc>
f01015b1:	89 c6                	mov    %eax,%esi
f01015b3:	83 c4 10             	add    $0x10,%esp
f01015b6:	85 c0                	test   %eax,%eax
f01015b8:	75 19                	jne    f01015d3 <mem_init+0x5a1>
f01015ba:	68 a5 4d 10 f0       	push   $0xf0104da5
f01015bf:	68 ba 4c 10 f0       	push   $0xf0104cba
f01015c4:	68 57 03 00 00       	push   $0x357
f01015c9:	68 94 4c 10 f0       	push   $0xf0104c94
f01015ce:	e8 cd ea ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015d3:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01015d6:	75 19                	jne    f01015f1 <mem_init+0x5bf>
f01015d8:	68 bb 4d 10 f0       	push   $0xf0104dbb
f01015dd:	68 ba 4c 10 f0       	push   $0xf0104cba
f01015e2:	68 5a 03 00 00       	push   $0x35a
f01015e7:	68 94 4c 10 f0       	push   $0xf0104c94
f01015ec:	e8 af ea ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015f1:	39 c3                	cmp    %eax,%ebx
f01015f3:	74 05                	je     f01015fa <mem_init+0x5c8>
f01015f5:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01015f8:	75 19                	jne    f0101613 <mem_init+0x5e1>
f01015fa:	68 f4 50 10 f0       	push   $0xf01050f4
f01015ff:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101604:	68 5b 03 00 00       	push   $0x35b
f0101609:	68 94 4c 10 f0       	push   $0xf0104c94
f010160e:	e8 8d ea ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101613:	a1 40 ce 17 f0       	mov    0xf017ce40,%eax
f0101618:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010161b:	c7 05 40 ce 17 f0 00 	movl   $0x0,0xf017ce40
f0101622:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101625:	83 ec 0c             	sub    $0xc,%esp
f0101628:	6a 00                	push   $0x0
f010162a:	e8 d8 f6 ff ff       	call   f0100d07 <page_alloc>
f010162f:	83 c4 10             	add    $0x10,%esp
f0101632:	85 c0                	test   %eax,%eax
f0101634:	74 19                	je     f010164f <mem_init+0x61d>
f0101636:	68 24 4e 10 f0       	push   $0xf0104e24
f010163b:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101640:	68 62 03 00 00       	push   $0x362
f0101645:	68 94 4c 10 f0       	push   $0xf0104c94
f010164a:	e8 51 ea ff ff       	call   f01000a0 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010164f:	83 ec 04             	sub    $0x4,%esp
f0101652:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101655:	50                   	push   %eax
f0101656:	6a 00                	push   $0x0
f0101658:	ff 35 08 db 17 f0    	pushl  0xf017db08
f010165e:	e8 c3 f8 ff ff       	call   f0100f26 <page_lookup>
f0101663:	83 c4 10             	add    $0x10,%esp
f0101666:	85 c0                	test   %eax,%eax
f0101668:	74 19                	je     f0101683 <mem_init+0x651>
f010166a:	68 34 51 10 f0       	push   $0xf0105134
f010166f:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101674:	68 65 03 00 00       	push   $0x365
f0101679:	68 94 4c 10 f0       	push   $0xf0104c94
f010167e:	e8 1d ea ff ff       	call   f01000a0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101683:	6a 02                	push   $0x2
f0101685:	6a 00                	push   $0x0
f0101687:	53                   	push   %ebx
f0101688:	ff 35 08 db 17 f0    	pushl  0xf017db08
f010168e:	e8 27 f9 ff ff       	call   f0100fba <page_insert>
f0101693:	83 c4 10             	add    $0x10,%esp
f0101696:	85 c0                	test   %eax,%eax
f0101698:	78 19                	js     f01016b3 <mem_init+0x681>
f010169a:	68 6c 51 10 f0       	push   $0xf010516c
f010169f:	68 ba 4c 10 f0       	push   $0xf0104cba
f01016a4:	68 68 03 00 00       	push   $0x368
f01016a9:	68 94 4c 10 f0       	push   $0xf0104c94
f01016ae:	e8 ed e9 ff ff       	call   f01000a0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01016b3:	83 ec 0c             	sub    $0xc,%esp
f01016b6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016b9:	e8 b9 f6 ff ff       	call   f0100d77 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01016be:	6a 02                	push   $0x2
f01016c0:	6a 00                	push   $0x0
f01016c2:	53                   	push   %ebx
f01016c3:	ff 35 08 db 17 f0    	pushl  0xf017db08
f01016c9:	e8 ec f8 ff ff       	call   f0100fba <page_insert>
f01016ce:	83 c4 20             	add    $0x20,%esp
f01016d1:	85 c0                	test   %eax,%eax
f01016d3:	74 19                	je     f01016ee <mem_init+0x6bc>
f01016d5:	68 9c 51 10 f0       	push   $0xf010519c
f01016da:	68 ba 4c 10 f0       	push   $0xf0104cba
f01016df:	68 6c 03 00 00       	push   $0x36c
f01016e4:	68 94 4c 10 f0       	push   $0xf0104c94
f01016e9:	e8 b2 e9 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01016ee:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016f4:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
f01016f9:	89 c1                	mov    %eax,%ecx
f01016fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01016fe:	8b 17                	mov    (%edi),%edx
f0101700:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101706:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101709:	29 c8                	sub    %ecx,%eax
f010170b:	c1 f8 03             	sar    $0x3,%eax
f010170e:	c1 e0 0c             	shl    $0xc,%eax
f0101711:	39 c2                	cmp    %eax,%edx
f0101713:	74 19                	je     f010172e <mem_init+0x6fc>
f0101715:	68 cc 51 10 f0       	push   $0xf01051cc
f010171a:	68 ba 4c 10 f0       	push   $0xf0104cba
f010171f:	68 6d 03 00 00       	push   $0x36d
f0101724:	68 94 4c 10 f0       	push   $0xf0104c94
f0101729:	e8 72 e9 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010172e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101733:	89 f8                	mov    %edi,%eax
f0101735:	e8 4c f2 ff ff       	call   f0100986 <check_va2pa>
f010173a:	89 da                	mov    %ebx,%edx
f010173c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010173f:	c1 fa 03             	sar    $0x3,%edx
f0101742:	c1 e2 0c             	shl    $0xc,%edx
f0101745:	39 d0                	cmp    %edx,%eax
f0101747:	74 19                	je     f0101762 <mem_init+0x730>
f0101749:	68 f4 51 10 f0       	push   $0xf01051f4
f010174e:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101753:	68 6e 03 00 00       	push   $0x36e
f0101758:	68 94 4c 10 f0       	push   $0xf0104c94
f010175d:	e8 3e e9 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101762:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101767:	74 19                	je     f0101782 <mem_init+0x750>
f0101769:	68 76 4e 10 f0       	push   $0xf0104e76
f010176e:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101773:	68 6f 03 00 00       	push   $0x36f
f0101778:	68 94 4c 10 f0       	push   $0xf0104c94
f010177d:	e8 1e e9 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f0101782:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101785:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010178a:	74 19                	je     f01017a5 <mem_init+0x773>
f010178c:	68 87 4e 10 f0       	push   $0xf0104e87
f0101791:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101796:	68 70 03 00 00       	push   $0x370
f010179b:	68 94 4c 10 f0       	push   $0xf0104c94
f01017a0:	e8 fb e8 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017a5:	6a 02                	push   $0x2
f01017a7:	68 00 10 00 00       	push   $0x1000
f01017ac:	56                   	push   %esi
f01017ad:	57                   	push   %edi
f01017ae:	e8 07 f8 ff ff       	call   f0100fba <page_insert>
f01017b3:	83 c4 10             	add    $0x10,%esp
f01017b6:	85 c0                	test   %eax,%eax
f01017b8:	74 19                	je     f01017d3 <mem_init+0x7a1>
f01017ba:	68 24 52 10 f0       	push   $0xf0105224
f01017bf:	68 ba 4c 10 f0       	push   $0xf0104cba
f01017c4:	68 73 03 00 00       	push   $0x373
f01017c9:	68 94 4c 10 f0       	push   $0xf0104c94
f01017ce:	e8 cd e8 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01017d3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01017d8:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f01017dd:	e8 a4 f1 ff ff       	call   f0100986 <check_va2pa>
f01017e2:	89 f2                	mov    %esi,%edx
f01017e4:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f01017ea:	c1 fa 03             	sar    $0x3,%edx
f01017ed:	c1 e2 0c             	shl    $0xc,%edx
f01017f0:	39 d0                	cmp    %edx,%eax
f01017f2:	74 19                	je     f010180d <mem_init+0x7db>
f01017f4:	68 60 52 10 f0       	push   $0xf0105260
f01017f9:	68 ba 4c 10 f0       	push   $0xf0104cba
f01017fe:	68 74 03 00 00       	push   $0x374
f0101803:	68 94 4c 10 f0       	push   $0xf0104c94
f0101808:	e8 93 e8 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f010180d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101812:	74 19                	je     f010182d <mem_init+0x7fb>
f0101814:	68 98 4e 10 f0       	push   $0xf0104e98
f0101819:	68 ba 4c 10 f0       	push   $0xf0104cba
f010181e:	68 75 03 00 00       	push   $0x375
f0101823:	68 94 4c 10 f0       	push   $0xf0104c94
f0101828:	e8 73 e8 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010182d:	83 ec 0c             	sub    $0xc,%esp
f0101830:	6a 00                	push   $0x0
f0101832:	e8 d0 f4 ff ff       	call   f0100d07 <page_alloc>
f0101837:	83 c4 10             	add    $0x10,%esp
f010183a:	85 c0                	test   %eax,%eax
f010183c:	74 19                	je     f0101857 <mem_init+0x825>
f010183e:	68 24 4e 10 f0       	push   $0xf0104e24
f0101843:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101848:	68 78 03 00 00       	push   $0x378
f010184d:	68 94 4c 10 f0       	push   $0xf0104c94
f0101852:	e8 49 e8 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101857:	6a 02                	push   $0x2
f0101859:	68 00 10 00 00       	push   $0x1000
f010185e:	56                   	push   %esi
f010185f:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101865:	e8 50 f7 ff ff       	call   f0100fba <page_insert>
f010186a:	83 c4 10             	add    $0x10,%esp
f010186d:	85 c0                	test   %eax,%eax
f010186f:	74 19                	je     f010188a <mem_init+0x858>
f0101871:	68 24 52 10 f0       	push   $0xf0105224
f0101876:	68 ba 4c 10 f0       	push   $0xf0104cba
f010187b:	68 7b 03 00 00       	push   $0x37b
f0101880:	68 94 4c 10 f0       	push   $0xf0104c94
f0101885:	e8 16 e8 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010188a:	ba 00 10 00 00       	mov    $0x1000,%edx
f010188f:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0101894:	e8 ed f0 ff ff       	call   f0100986 <check_va2pa>
f0101899:	89 f2                	mov    %esi,%edx
f010189b:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f01018a1:	c1 fa 03             	sar    $0x3,%edx
f01018a4:	c1 e2 0c             	shl    $0xc,%edx
f01018a7:	39 d0                	cmp    %edx,%eax
f01018a9:	74 19                	je     f01018c4 <mem_init+0x892>
f01018ab:	68 60 52 10 f0       	push   $0xf0105260
f01018b0:	68 ba 4c 10 f0       	push   $0xf0104cba
f01018b5:	68 7c 03 00 00       	push   $0x37c
f01018ba:	68 94 4c 10 f0       	push   $0xf0104c94
f01018bf:	e8 dc e7 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01018c4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01018c9:	74 19                	je     f01018e4 <mem_init+0x8b2>
f01018cb:	68 98 4e 10 f0       	push   $0xf0104e98
f01018d0:	68 ba 4c 10 f0       	push   $0xf0104cba
f01018d5:	68 7d 03 00 00       	push   $0x37d
f01018da:	68 94 4c 10 f0       	push   $0xf0104c94
f01018df:	e8 bc e7 ff ff       	call   f01000a0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01018e4:	83 ec 0c             	sub    $0xc,%esp
f01018e7:	6a 00                	push   $0x0
f01018e9:	e8 19 f4 ff ff       	call   f0100d07 <page_alloc>
f01018ee:	83 c4 10             	add    $0x10,%esp
f01018f1:	85 c0                	test   %eax,%eax
f01018f3:	74 19                	je     f010190e <mem_init+0x8dc>
f01018f5:	68 24 4e 10 f0       	push   $0xf0104e24
f01018fa:	68 ba 4c 10 f0       	push   $0xf0104cba
f01018ff:	68 81 03 00 00       	push   $0x381
f0101904:	68 94 4c 10 f0       	push   $0xf0104c94
f0101909:	e8 92 e7 ff ff       	call   f01000a0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010190e:	8b 15 08 db 17 f0    	mov    0xf017db08,%edx
f0101914:	8b 02                	mov    (%edx),%eax
f0101916:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010191b:	89 c1                	mov    %eax,%ecx
f010191d:	c1 e9 0c             	shr    $0xc,%ecx
f0101920:	3b 0d 04 db 17 f0    	cmp    0xf017db04,%ecx
f0101926:	72 15                	jb     f010193d <mem_init+0x90b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101928:	50                   	push   %eax
f0101929:	68 8c 4f 10 f0       	push   $0xf0104f8c
f010192e:	68 84 03 00 00       	push   $0x384
f0101933:	68 94 4c 10 f0       	push   $0xf0104c94
f0101938:	e8 63 e7 ff ff       	call   f01000a0 <_panic>
f010193d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101942:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101945:	83 ec 04             	sub    $0x4,%esp
f0101948:	6a 00                	push   $0x0
f010194a:	68 00 10 00 00       	push   $0x1000
f010194f:	52                   	push   %edx
f0101950:	e8 81 f4 ff ff       	call   f0100dd6 <pgdir_walk>
f0101955:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101958:	8d 57 04             	lea    0x4(%edi),%edx
f010195b:	83 c4 10             	add    $0x10,%esp
f010195e:	39 d0                	cmp    %edx,%eax
f0101960:	74 19                	je     f010197b <mem_init+0x949>
f0101962:	68 90 52 10 f0       	push   $0xf0105290
f0101967:	68 ba 4c 10 f0       	push   $0xf0104cba
f010196c:	68 85 03 00 00       	push   $0x385
f0101971:	68 94 4c 10 f0       	push   $0xf0104c94
f0101976:	e8 25 e7 ff ff       	call   f01000a0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010197b:	6a 06                	push   $0x6
f010197d:	68 00 10 00 00       	push   $0x1000
f0101982:	56                   	push   %esi
f0101983:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101989:	e8 2c f6 ff ff       	call   f0100fba <page_insert>
f010198e:	83 c4 10             	add    $0x10,%esp
f0101991:	85 c0                	test   %eax,%eax
f0101993:	74 19                	je     f01019ae <mem_init+0x97c>
f0101995:	68 d0 52 10 f0       	push   $0xf01052d0
f010199a:	68 ba 4c 10 f0       	push   $0xf0104cba
f010199f:	68 88 03 00 00       	push   $0x388
f01019a4:	68 94 4c 10 f0       	push   $0xf0104c94
f01019a9:	e8 f2 e6 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019ae:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f01019b4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019b9:	89 f8                	mov    %edi,%eax
f01019bb:	e8 c6 ef ff ff       	call   f0100986 <check_va2pa>
f01019c0:	89 f2                	mov    %esi,%edx
f01019c2:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f01019c8:	c1 fa 03             	sar    $0x3,%edx
f01019cb:	c1 e2 0c             	shl    $0xc,%edx
f01019ce:	39 d0                	cmp    %edx,%eax
f01019d0:	74 19                	je     f01019eb <mem_init+0x9b9>
f01019d2:	68 60 52 10 f0       	push   $0xf0105260
f01019d7:	68 ba 4c 10 f0       	push   $0xf0104cba
f01019dc:	68 89 03 00 00       	push   $0x389
f01019e1:	68 94 4c 10 f0       	push   $0xf0104c94
f01019e6:	e8 b5 e6 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01019eb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019f0:	74 19                	je     f0101a0b <mem_init+0x9d9>
f01019f2:	68 98 4e 10 f0       	push   $0xf0104e98
f01019f7:	68 ba 4c 10 f0       	push   $0xf0104cba
f01019fc:	68 8a 03 00 00       	push   $0x38a
f0101a01:	68 94 4c 10 f0       	push   $0xf0104c94
f0101a06:	e8 95 e6 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a0b:	83 ec 04             	sub    $0x4,%esp
f0101a0e:	6a 00                	push   $0x0
f0101a10:	68 00 10 00 00       	push   $0x1000
f0101a15:	57                   	push   %edi
f0101a16:	e8 bb f3 ff ff       	call   f0100dd6 <pgdir_walk>
f0101a1b:	83 c4 10             	add    $0x10,%esp
f0101a1e:	f6 00 04             	testb  $0x4,(%eax)
f0101a21:	75 19                	jne    f0101a3c <mem_init+0xa0a>
f0101a23:	68 10 53 10 f0       	push   $0xf0105310
f0101a28:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101a2d:	68 8b 03 00 00       	push   $0x38b
f0101a32:	68 94 4c 10 f0       	push   $0xf0104c94
f0101a37:	e8 64 e6 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101a3c:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0101a41:	f6 00 04             	testb  $0x4,(%eax)
f0101a44:	75 19                	jne    f0101a5f <mem_init+0xa2d>
f0101a46:	68 a9 4e 10 f0       	push   $0xf0104ea9
f0101a4b:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101a50:	68 8c 03 00 00       	push   $0x38c
f0101a55:	68 94 4c 10 f0       	push   $0xf0104c94
f0101a5a:	e8 41 e6 ff ff       	call   f01000a0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a5f:	6a 02                	push   $0x2
f0101a61:	68 00 10 00 00       	push   $0x1000
f0101a66:	56                   	push   %esi
f0101a67:	50                   	push   %eax
f0101a68:	e8 4d f5 ff ff       	call   f0100fba <page_insert>
f0101a6d:	83 c4 10             	add    $0x10,%esp
f0101a70:	85 c0                	test   %eax,%eax
f0101a72:	74 19                	je     f0101a8d <mem_init+0xa5b>
f0101a74:	68 24 52 10 f0       	push   $0xf0105224
f0101a79:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101a7e:	68 8f 03 00 00       	push   $0x38f
f0101a83:	68 94 4c 10 f0       	push   $0xf0104c94
f0101a88:	e8 13 e6 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101a8d:	83 ec 04             	sub    $0x4,%esp
f0101a90:	6a 00                	push   $0x0
f0101a92:	68 00 10 00 00       	push   $0x1000
f0101a97:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101a9d:	e8 34 f3 ff ff       	call   f0100dd6 <pgdir_walk>
f0101aa2:	83 c4 10             	add    $0x10,%esp
f0101aa5:	f6 00 02             	testb  $0x2,(%eax)
f0101aa8:	75 19                	jne    f0101ac3 <mem_init+0xa91>
f0101aaa:	68 44 53 10 f0       	push   $0xf0105344
f0101aaf:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101ab4:	68 90 03 00 00       	push   $0x390
f0101ab9:	68 94 4c 10 f0       	push   $0xf0104c94
f0101abe:	e8 dd e5 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ac3:	83 ec 04             	sub    $0x4,%esp
f0101ac6:	6a 00                	push   $0x0
f0101ac8:	68 00 10 00 00       	push   $0x1000
f0101acd:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101ad3:	e8 fe f2 ff ff       	call   f0100dd6 <pgdir_walk>
f0101ad8:	83 c4 10             	add    $0x10,%esp
f0101adb:	f6 00 04             	testb  $0x4,(%eax)
f0101ade:	74 19                	je     f0101af9 <mem_init+0xac7>
f0101ae0:	68 78 53 10 f0       	push   $0xf0105378
f0101ae5:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101aea:	68 91 03 00 00       	push   $0x391
f0101aef:	68 94 4c 10 f0       	push   $0xf0104c94
f0101af4:	e8 a7 e5 ff ff       	call   f01000a0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101af9:	6a 02                	push   $0x2
f0101afb:	68 00 00 40 00       	push   $0x400000
f0101b00:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b03:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101b09:	e8 ac f4 ff ff       	call   f0100fba <page_insert>
f0101b0e:	83 c4 10             	add    $0x10,%esp
f0101b11:	85 c0                	test   %eax,%eax
f0101b13:	78 19                	js     f0101b2e <mem_init+0xafc>
f0101b15:	68 b0 53 10 f0       	push   $0xf01053b0
f0101b1a:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101b1f:	68 94 03 00 00       	push   $0x394
f0101b24:	68 94 4c 10 f0       	push   $0xf0104c94
f0101b29:	e8 72 e5 ff ff       	call   f01000a0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b2e:	6a 02                	push   $0x2
f0101b30:	68 00 10 00 00       	push   $0x1000
f0101b35:	53                   	push   %ebx
f0101b36:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101b3c:	e8 79 f4 ff ff       	call   f0100fba <page_insert>
f0101b41:	83 c4 10             	add    $0x10,%esp
f0101b44:	85 c0                	test   %eax,%eax
f0101b46:	74 19                	je     f0101b61 <mem_init+0xb2f>
f0101b48:	68 e8 53 10 f0       	push   $0xf01053e8
f0101b4d:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101b52:	68 97 03 00 00       	push   $0x397
f0101b57:	68 94 4c 10 f0       	push   $0xf0104c94
f0101b5c:	e8 3f e5 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b61:	83 ec 04             	sub    $0x4,%esp
f0101b64:	6a 00                	push   $0x0
f0101b66:	68 00 10 00 00       	push   $0x1000
f0101b6b:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101b71:	e8 60 f2 ff ff       	call   f0100dd6 <pgdir_walk>
f0101b76:	83 c4 10             	add    $0x10,%esp
f0101b79:	f6 00 04             	testb  $0x4,(%eax)
f0101b7c:	74 19                	je     f0101b97 <mem_init+0xb65>
f0101b7e:	68 78 53 10 f0       	push   $0xf0105378
f0101b83:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101b88:	68 98 03 00 00       	push   $0x398
f0101b8d:	68 94 4c 10 f0       	push   $0xf0104c94
f0101b92:	e8 09 e5 ff ff       	call   f01000a0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101b97:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101b9d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ba2:	89 f8                	mov    %edi,%eax
f0101ba4:	e8 dd ed ff ff       	call   f0100986 <check_va2pa>
f0101ba9:	89 c1                	mov    %eax,%ecx
f0101bab:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101bae:	89 d8                	mov    %ebx,%eax
f0101bb0:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101bb6:	c1 f8 03             	sar    $0x3,%eax
f0101bb9:	c1 e0 0c             	shl    $0xc,%eax
f0101bbc:	39 c1                	cmp    %eax,%ecx
f0101bbe:	74 19                	je     f0101bd9 <mem_init+0xba7>
f0101bc0:	68 24 54 10 f0       	push   $0xf0105424
f0101bc5:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101bca:	68 9b 03 00 00       	push   $0x39b
f0101bcf:	68 94 4c 10 f0       	push   $0xf0104c94
f0101bd4:	e8 c7 e4 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bd9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bde:	89 f8                	mov    %edi,%eax
f0101be0:	e8 a1 ed ff ff       	call   f0100986 <check_va2pa>
f0101be5:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101be8:	74 19                	je     f0101c03 <mem_init+0xbd1>
f0101bea:	68 50 54 10 f0       	push   $0xf0105450
f0101bef:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101bf4:	68 9c 03 00 00       	push   $0x39c
f0101bf9:	68 94 4c 10 f0       	push   $0xf0104c94
f0101bfe:	e8 9d e4 ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c03:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c08:	74 19                	je     f0101c23 <mem_init+0xbf1>
f0101c0a:	68 bf 4e 10 f0       	push   $0xf0104ebf
f0101c0f:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101c14:	68 9e 03 00 00       	push   $0x39e
f0101c19:	68 94 4c 10 f0       	push   $0xf0104c94
f0101c1e:	e8 7d e4 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101c23:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c28:	74 19                	je     f0101c43 <mem_init+0xc11>
f0101c2a:	68 d0 4e 10 f0       	push   $0xf0104ed0
f0101c2f:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101c34:	68 9f 03 00 00       	push   $0x39f
f0101c39:	68 94 4c 10 f0       	push   $0xf0104c94
f0101c3e:	e8 5d e4 ff ff       	call   f01000a0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c43:	83 ec 0c             	sub    $0xc,%esp
f0101c46:	6a 00                	push   $0x0
f0101c48:	e8 ba f0 ff ff       	call   f0100d07 <page_alloc>
f0101c4d:	83 c4 10             	add    $0x10,%esp
f0101c50:	39 c6                	cmp    %eax,%esi
f0101c52:	75 04                	jne    f0101c58 <mem_init+0xc26>
f0101c54:	85 c0                	test   %eax,%eax
f0101c56:	75 19                	jne    f0101c71 <mem_init+0xc3f>
f0101c58:	68 80 54 10 f0       	push   $0xf0105480
f0101c5d:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101c62:	68 a2 03 00 00       	push   $0x3a2
f0101c67:	68 94 4c 10 f0       	push   $0xf0104c94
f0101c6c:	e8 2f e4 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c71:	83 ec 08             	sub    $0x8,%esp
f0101c74:	6a 00                	push   $0x0
f0101c76:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101c7c:	e8 f7 f2 ff ff       	call   f0100f78 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c81:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101c87:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c8c:	89 f8                	mov    %edi,%eax
f0101c8e:	e8 f3 ec ff ff       	call   f0100986 <check_va2pa>
f0101c93:	83 c4 10             	add    $0x10,%esp
f0101c96:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c99:	74 19                	je     f0101cb4 <mem_init+0xc82>
f0101c9b:	68 a4 54 10 f0       	push   $0xf01054a4
f0101ca0:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101ca5:	68 a6 03 00 00       	push   $0x3a6
f0101caa:	68 94 4c 10 f0       	push   $0xf0104c94
f0101caf:	e8 ec e3 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cb4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cb9:	89 f8                	mov    %edi,%eax
f0101cbb:	e8 c6 ec ff ff       	call   f0100986 <check_va2pa>
f0101cc0:	89 da                	mov    %ebx,%edx
f0101cc2:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0101cc8:	c1 fa 03             	sar    $0x3,%edx
f0101ccb:	c1 e2 0c             	shl    $0xc,%edx
f0101cce:	39 d0                	cmp    %edx,%eax
f0101cd0:	74 19                	je     f0101ceb <mem_init+0xcb9>
f0101cd2:	68 50 54 10 f0       	push   $0xf0105450
f0101cd7:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101cdc:	68 a7 03 00 00       	push   $0x3a7
f0101ce1:	68 94 4c 10 f0       	push   $0xf0104c94
f0101ce6:	e8 b5 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101ceb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cf0:	74 19                	je     f0101d0b <mem_init+0xcd9>
f0101cf2:	68 76 4e 10 f0       	push   $0xf0104e76
f0101cf7:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101cfc:	68 a8 03 00 00       	push   $0x3a8
f0101d01:	68 94 4c 10 f0       	push   $0xf0104c94
f0101d06:	e8 95 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101d0b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d10:	74 19                	je     f0101d2b <mem_init+0xcf9>
f0101d12:	68 d0 4e 10 f0       	push   $0xf0104ed0
f0101d17:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101d1c:	68 a9 03 00 00       	push   $0x3a9
f0101d21:	68 94 4c 10 f0       	push   $0xf0104c94
f0101d26:	e8 75 e3 ff ff       	call   f01000a0 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d2b:	6a 00                	push   $0x0
f0101d2d:	68 00 10 00 00       	push   $0x1000
f0101d32:	53                   	push   %ebx
f0101d33:	57                   	push   %edi
f0101d34:	e8 81 f2 ff ff       	call   f0100fba <page_insert>
f0101d39:	83 c4 10             	add    $0x10,%esp
f0101d3c:	85 c0                	test   %eax,%eax
f0101d3e:	74 19                	je     f0101d59 <mem_init+0xd27>
f0101d40:	68 c8 54 10 f0       	push   $0xf01054c8
f0101d45:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101d4a:	68 ac 03 00 00       	push   $0x3ac
f0101d4f:	68 94 4c 10 f0       	push   $0xf0104c94
f0101d54:	e8 47 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f0101d59:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d5e:	75 19                	jne    f0101d79 <mem_init+0xd47>
f0101d60:	68 e1 4e 10 f0       	push   $0xf0104ee1
f0101d65:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101d6a:	68 ad 03 00 00       	push   $0x3ad
f0101d6f:	68 94 4c 10 f0       	push   $0xf0104c94
f0101d74:	e8 27 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f0101d79:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d7c:	74 19                	je     f0101d97 <mem_init+0xd65>
f0101d7e:	68 ed 4e 10 f0       	push   $0xf0104eed
f0101d83:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101d88:	68 ae 03 00 00       	push   $0x3ae
f0101d8d:	68 94 4c 10 f0       	push   $0xf0104c94
f0101d92:	e8 09 e3 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d97:	83 ec 08             	sub    $0x8,%esp
f0101d9a:	68 00 10 00 00       	push   $0x1000
f0101d9f:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101da5:	e8 ce f1 ff ff       	call   f0100f78 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101daa:	8b 3d 08 db 17 f0    	mov    0xf017db08,%edi
f0101db0:	ba 00 00 00 00       	mov    $0x0,%edx
f0101db5:	89 f8                	mov    %edi,%eax
f0101db7:	e8 ca eb ff ff       	call   f0100986 <check_va2pa>
f0101dbc:	83 c4 10             	add    $0x10,%esp
f0101dbf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dc2:	74 19                	je     f0101ddd <mem_init+0xdab>
f0101dc4:	68 a4 54 10 f0       	push   $0xf01054a4
f0101dc9:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101dce:	68 b2 03 00 00       	push   $0x3b2
f0101dd3:	68 94 4c 10 f0       	push   $0xf0104c94
f0101dd8:	e8 c3 e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ddd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101de2:	89 f8                	mov    %edi,%eax
f0101de4:	e8 9d eb ff ff       	call   f0100986 <check_va2pa>
f0101de9:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dec:	74 19                	je     f0101e07 <mem_init+0xdd5>
f0101dee:	68 00 55 10 f0       	push   $0xf0105500
f0101df3:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101df8:	68 b3 03 00 00       	push   $0x3b3
f0101dfd:	68 94 4c 10 f0       	push   $0xf0104c94
f0101e02:	e8 99 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0101e07:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e0c:	74 19                	je     f0101e27 <mem_init+0xdf5>
f0101e0e:	68 02 4f 10 f0       	push   $0xf0104f02
f0101e13:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101e18:	68 b4 03 00 00       	push   $0x3b4
f0101e1d:	68 94 4c 10 f0       	push   $0xf0104c94
f0101e22:	e8 79 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101e27:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e2c:	74 19                	je     f0101e47 <mem_init+0xe15>
f0101e2e:	68 d0 4e 10 f0       	push   $0xf0104ed0
f0101e33:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101e38:	68 b5 03 00 00       	push   $0x3b5
f0101e3d:	68 94 4c 10 f0       	push   $0xf0104c94
f0101e42:	e8 59 e2 ff ff       	call   f01000a0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e47:	83 ec 0c             	sub    $0xc,%esp
f0101e4a:	6a 00                	push   $0x0
f0101e4c:	e8 b6 ee ff ff       	call   f0100d07 <page_alloc>
f0101e51:	83 c4 10             	add    $0x10,%esp
f0101e54:	85 c0                	test   %eax,%eax
f0101e56:	74 04                	je     f0101e5c <mem_init+0xe2a>
f0101e58:	39 c3                	cmp    %eax,%ebx
f0101e5a:	74 19                	je     f0101e75 <mem_init+0xe43>
f0101e5c:	68 28 55 10 f0       	push   $0xf0105528
f0101e61:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101e66:	68 b8 03 00 00       	push   $0x3b8
f0101e6b:	68 94 4c 10 f0       	push   $0xf0104c94
f0101e70:	e8 2b e2 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101e75:	83 ec 0c             	sub    $0xc,%esp
f0101e78:	6a 00                	push   $0x0
f0101e7a:	e8 88 ee ff ff       	call   f0100d07 <page_alloc>
f0101e7f:	83 c4 10             	add    $0x10,%esp
f0101e82:	85 c0                	test   %eax,%eax
f0101e84:	74 19                	je     f0101e9f <mem_init+0xe6d>
f0101e86:	68 24 4e 10 f0       	push   $0xf0104e24
f0101e8b:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101e90:	68 bb 03 00 00       	push   $0x3bb
f0101e95:	68 94 4c 10 f0       	push   $0xf0104c94
f0101e9a:	e8 01 e2 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e9f:	8b 0d 08 db 17 f0    	mov    0xf017db08,%ecx
f0101ea5:	8b 11                	mov    (%ecx),%edx
f0101ea7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ead:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eb0:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101eb6:	c1 f8 03             	sar    $0x3,%eax
f0101eb9:	c1 e0 0c             	shl    $0xc,%eax
f0101ebc:	39 c2                	cmp    %eax,%edx
f0101ebe:	74 19                	je     f0101ed9 <mem_init+0xea7>
f0101ec0:	68 cc 51 10 f0       	push   $0xf01051cc
f0101ec5:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101eca:	68 be 03 00 00       	push   $0x3be
f0101ecf:	68 94 4c 10 f0       	push   $0xf0104c94
f0101ed4:	e8 c7 e1 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0101ed9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101edf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ee2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ee7:	74 19                	je     f0101f02 <mem_init+0xed0>
f0101ee9:	68 87 4e 10 f0       	push   $0xf0104e87
f0101eee:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101ef3:	68 c0 03 00 00       	push   $0x3c0
f0101ef8:	68 94 4c 10 f0       	push   $0xf0104c94
f0101efd:	e8 9e e1 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0101f02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f05:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f0b:	83 ec 0c             	sub    $0xc,%esp
f0101f0e:	50                   	push   %eax
f0101f0f:	e8 63 ee ff ff       	call   f0100d77 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f14:	83 c4 0c             	add    $0xc,%esp
f0101f17:	6a 01                	push   $0x1
f0101f19:	68 00 10 40 00       	push   $0x401000
f0101f1e:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101f24:	e8 ad ee ff ff       	call   f0100dd6 <pgdir_walk>
f0101f29:	89 c7                	mov    %eax,%edi
f0101f2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f2e:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f0101f33:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f36:	8b 40 04             	mov    0x4(%eax),%eax
f0101f39:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f3e:	8b 0d 04 db 17 f0    	mov    0xf017db04,%ecx
f0101f44:	89 c2                	mov    %eax,%edx
f0101f46:	c1 ea 0c             	shr    $0xc,%edx
f0101f49:	83 c4 10             	add    $0x10,%esp
f0101f4c:	39 ca                	cmp    %ecx,%edx
f0101f4e:	72 15                	jb     f0101f65 <mem_init+0xf33>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f50:	50                   	push   %eax
f0101f51:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0101f56:	68 c7 03 00 00       	push   $0x3c7
f0101f5b:	68 94 4c 10 f0       	push   $0xf0104c94
f0101f60:	e8 3b e1 ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101f65:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101f6a:	39 c7                	cmp    %eax,%edi
f0101f6c:	74 19                	je     f0101f87 <mem_init+0xf55>
f0101f6e:	68 13 4f 10 f0       	push   $0xf0104f13
f0101f73:	68 ba 4c 10 f0       	push   $0xf0104cba
f0101f78:	68 c8 03 00 00       	push   $0x3c8
f0101f7d:	68 94 4c 10 f0       	push   $0xf0104c94
f0101f82:	e8 19 e1 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101f87:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f8a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101f91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f94:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f9a:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f0101fa0:	c1 f8 03             	sar    $0x3,%eax
f0101fa3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fa6:	89 c2                	mov    %eax,%edx
f0101fa8:	c1 ea 0c             	shr    $0xc,%edx
f0101fab:	39 d1                	cmp    %edx,%ecx
f0101fad:	77 12                	ja     f0101fc1 <mem_init+0xf8f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101faf:	50                   	push   %eax
f0101fb0:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0101fb5:	6a 56                	push   $0x56
f0101fb7:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0101fbc:	e8 df e0 ff ff       	call   f01000a0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101fc1:	83 ec 04             	sub    $0x4,%esp
f0101fc4:	68 00 10 00 00       	push   $0x1000
f0101fc9:	68 ff 00 00 00       	push   $0xff
f0101fce:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fd3:	50                   	push   %eax
f0101fd4:	e8 fe 22 00 00       	call   f01042d7 <memset>
	page_free(pp0);
f0101fd9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101fdc:	89 3c 24             	mov    %edi,(%esp)
f0101fdf:	e8 93 ed ff ff       	call   f0100d77 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101fe4:	83 c4 0c             	add    $0xc,%esp
f0101fe7:	6a 01                	push   $0x1
f0101fe9:	6a 00                	push   $0x0
f0101feb:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0101ff1:	e8 e0 ed ff ff       	call   f0100dd6 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ff6:	89 fa                	mov    %edi,%edx
f0101ff8:	2b 15 0c db 17 f0    	sub    0xf017db0c,%edx
f0101ffe:	c1 fa 03             	sar    $0x3,%edx
f0102001:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102004:	89 d0                	mov    %edx,%eax
f0102006:	c1 e8 0c             	shr    $0xc,%eax
f0102009:	83 c4 10             	add    $0x10,%esp
f010200c:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0102012:	72 12                	jb     f0102026 <mem_init+0xff4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102014:	52                   	push   %edx
f0102015:	68 8c 4f 10 f0       	push   $0xf0104f8c
f010201a:	6a 56                	push   $0x56
f010201c:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0102021:	e8 7a e0 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0102026:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010202c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010202f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102035:	f6 00 01             	testb  $0x1,(%eax)
f0102038:	74 19                	je     f0102053 <mem_init+0x1021>
f010203a:	68 2b 4f 10 f0       	push   $0xf0104f2b
f010203f:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102044:	68 d2 03 00 00       	push   $0x3d2
f0102049:	68 94 4c 10 f0       	push   $0xf0104c94
f010204e:	e8 4d e0 ff ff       	call   f01000a0 <_panic>
f0102053:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102056:	39 d0                	cmp    %edx,%eax
f0102058:	75 db                	jne    f0102035 <mem_init+0x1003>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010205a:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f010205f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102065:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102068:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010206e:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102071:	89 3d 40 ce 17 f0    	mov    %edi,0xf017ce40

	// free the pages we took
	page_free(pp0);
f0102077:	83 ec 0c             	sub    $0xc,%esp
f010207a:	50                   	push   %eax
f010207b:	e8 f7 ec ff ff       	call   f0100d77 <page_free>
	page_free(pp1);
f0102080:	89 1c 24             	mov    %ebx,(%esp)
f0102083:	e8 ef ec ff ff       	call   f0100d77 <page_free>
	page_free(pp2);
f0102088:	89 34 24             	mov    %esi,(%esp)
f010208b:	e8 e7 ec ff ff       	call   f0100d77 <page_free>

	cprintf("check_page() succeeded!\n");
f0102090:	c7 04 24 42 4f 10 f0 	movl   $0xf0104f42,(%esp)
f0102097:	e8 79 0e 00 00       	call   f0102f15 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	//static void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm);
	boot_map_region(kern_pgdir, UPAGES, PTSIZE,PADDR(pages), PTE_U | PTE_P);
f010209c:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020a1:	83 c4 10             	add    $0x10,%esp
f01020a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020a9:	77 15                	ja     f01020c0 <mem_init+0x108e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020ab:	50                   	push   %eax
f01020ac:	68 74 50 10 f0       	push   $0xf0105074
f01020b1:	68 ce 00 00 00       	push   $0xce
f01020b6:	68 94 4c 10 f0       	push   $0xf0104c94
f01020bb:	e8 e0 df ff ff       	call   f01000a0 <_panic>
f01020c0:	83 ec 08             	sub    $0x8,%esp
f01020c3:	6a 05                	push   $0x5
f01020c5:	05 00 00 00 10       	add    $0x10000000,%eax
f01020ca:	50                   	push   %eax
f01020cb:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01020d0:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020d5:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f01020da:	e8 e3 ed ff ff       	call   f0100ec2 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, PTSIZE,PADDR(envs), PTE_U | PTE_P);
f01020df:	a1 48 ce 17 f0       	mov    0xf017ce48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020e4:	83 c4 10             	add    $0x10,%esp
f01020e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020ec:	77 15                	ja     f0102103 <mem_init+0x10d1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020ee:	50                   	push   %eax
f01020ef:	68 74 50 10 f0       	push   $0xf0105074
f01020f4:	68 da 00 00 00       	push   $0xda
f01020f9:	68 94 4c 10 f0       	push   $0xf0104c94
f01020fe:	e8 9d df ff ff       	call   f01000a0 <_panic>
f0102103:	83 ec 08             	sub    $0x8,%esp
f0102106:	6a 05                	push   $0x5
f0102108:	05 00 00 00 10       	add    $0x10000000,%eax
f010210d:	50                   	push   %eax
f010210e:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102113:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102118:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f010211d:	e8 a0 ed ff ff       	call   f0100ec2 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102122:	83 c4 10             	add    $0x10,%esp
f0102125:	b8 00 10 11 f0       	mov    $0xf0111000,%eax
f010212a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010212f:	77 15                	ja     f0102146 <mem_init+0x1114>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102131:	50                   	push   %eax
f0102132:	68 74 50 10 f0       	push   $0xf0105074
f0102137:	68 e6 00 00 00       	push   $0xe6
f010213c:	68 94 4c 10 f0       	push   $0xf0104c94
f0102141:	e8 5a df ff ff       	call   f01000a0 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE,PADDR(bootstack), PTE_W );
f0102146:	83 ec 08             	sub    $0x8,%esp
f0102149:	6a 02                	push   $0x2
f010214b:	68 00 10 11 00       	push   $0x111000
f0102150:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102155:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010215a:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f010215f:	e8 5e ed ff ff       	call   f0100ec2 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	uint64_t kern_map_length = 0x100000000 - (uint64_t) KERNBASE;
    boot_map_region(kern_pgdir, KERNBASE,kern_map_length ,0, PTE_W | PTE_P);
f0102164:	83 c4 08             	add    $0x8,%esp
f0102167:	6a 03                	push   $0x3
f0102169:	6a 00                	push   $0x0
f010216b:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102170:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102175:	a1 08 db 17 f0       	mov    0xf017db08,%eax
f010217a:	e8 43 ed ff ff       	call   f0100ec2 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010217f:	8b 1d 08 db 17 f0    	mov    0xf017db08,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102185:	a1 04 db 17 f0       	mov    0xf017db04,%eax
f010218a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010218d:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102194:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102199:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010219c:	8b 3d 0c db 17 f0    	mov    0xf017db0c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021a2:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01021a5:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01021a8:	be 00 00 00 00       	mov    $0x0,%esi
f01021ad:	eb 55                	jmp    f0102204 <mem_init+0x11d2>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021af:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01021b5:	89 d8                	mov    %ebx,%eax
f01021b7:	e8 ca e7 ff ff       	call   f0100986 <check_va2pa>
f01021bc:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01021c3:	77 15                	ja     f01021da <mem_init+0x11a8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021c5:	57                   	push   %edi
f01021c6:	68 74 50 10 f0       	push   $0xf0105074
f01021cb:	68 0f 03 00 00       	push   $0x30f
f01021d0:	68 94 4c 10 f0       	push   $0xf0104c94
f01021d5:	e8 c6 de ff ff       	call   f01000a0 <_panic>
f01021da:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f01021e1:	39 d0                	cmp    %edx,%eax
f01021e3:	74 19                	je     f01021fe <mem_init+0x11cc>
f01021e5:	68 4c 55 10 f0       	push   $0xf010554c
f01021ea:	68 ba 4c 10 f0       	push   $0xf0104cba
f01021ef:	68 0f 03 00 00       	push   $0x30f
f01021f4:	68 94 4c 10 f0       	push   $0xf0104c94
f01021f9:	e8 a2 de ff ff       	call   f01000a0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01021fe:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102204:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102207:	77 a6                	ja     f01021af <mem_init+0x117d>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102209:	8b 3d 48 ce 17 f0    	mov    0xf017ce48,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010220f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102212:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102217:	89 f2                	mov    %esi,%edx
f0102219:	89 d8                	mov    %ebx,%eax
f010221b:	e8 66 e7 ff ff       	call   f0100986 <check_va2pa>
f0102220:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102227:	77 15                	ja     f010223e <mem_init+0x120c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102229:	57                   	push   %edi
f010222a:	68 74 50 10 f0       	push   $0xf0105074
f010222f:	68 14 03 00 00       	push   $0x314
f0102234:	68 94 4c 10 f0       	push   $0xf0104c94
f0102239:	e8 62 de ff ff       	call   f01000a0 <_panic>
f010223e:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f0102245:	39 c2                	cmp    %eax,%edx
f0102247:	74 19                	je     f0102262 <mem_init+0x1230>
f0102249:	68 80 55 10 f0       	push   $0xf0105580
f010224e:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102253:	68 14 03 00 00       	push   $0x314
f0102258:	68 94 4c 10 f0       	push   $0xf0104c94
f010225d:	e8 3e de ff ff       	call   f01000a0 <_panic>
f0102262:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102268:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f010226e:	75 a7                	jne    f0102217 <mem_init+0x11e5>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102270:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102273:	c1 e7 0c             	shl    $0xc,%edi
f0102276:	be 00 00 00 00       	mov    $0x0,%esi
f010227b:	eb 30                	jmp    f01022ad <mem_init+0x127b>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010227d:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102283:	89 d8                	mov    %ebx,%eax
f0102285:	e8 fc e6 ff ff       	call   f0100986 <check_va2pa>
f010228a:	39 c6                	cmp    %eax,%esi
f010228c:	74 19                	je     f01022a7 <mem_init+0x1275>
f010228e:	68 b4 55 10 f0       	push   $0xf01055b4
f0102293:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102298:	68 18 03 00 00       	push   $0x318
f010229d:	68 94 4c 10 f0       	push   $0xf0104c94
f01022a2:	e8 f9 dd ff ff       	call   f01000a0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022a7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01022ad:	39 fe                	cmp    %edi,%esi
f01022af:	72 cc                	jb     f010227d <mem_init+0x124b>
f01022b1:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01022b6:	89 f2                	mov    %esi,%edx
f01022b8:	89 d8                	mov    %ebx,%eax
f01022ba:	e8 c7 e6 ff ff       	call   f0100986 <check_va2pa>
f01022bf:	8d 96 00 90 11 10    	lea    0x10119000(%esi),%edx
f01022c5:	39 c2                	cmp    %eax,%edx
f01022c7:	74 19                	je     f01022e2 <mem_init+0x12b0>
f01022c9:	68 dc 55 10 f0       	push   $0xf01055dc
f01022ce:	68 ba 4c 10 f0       	push   $0xf0104cba
f01022d3:	68 1c 03 00 00       	push   $0x31c
f01022d8:	68 94 4c 10 f0       	push   $0xf0104c94
f01022dd:	e8 be dd ff ff       	call   f01000a0 <_panic>
f01022e2:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01022e8:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01022ee:	75 c6                	jne    f01022b6 <mem_init+0x1284>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01022f0:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01022f5:	89 d8                	mov    %ebx,%eax
f01022f7:	e8 8a e6 ff ff       	call   f0100986 <check_va2pa>
f01022fc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022ff:	74 51                	je     f0102352 <mem_init+0x1320>
f0102301:	68 24 56 10 f0       	push   $0xf0105624
f0102306:	68 ba 4c 10 f0       	push   $0xf0104cba
f010230b:	68 1d 03 00 00       	push   $0x31d
f0102310:	68 94 4c 10 f0       	push   $0xf0104c94
f0102315:	e8 86 dd ff ff       	call   f01000a0 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010231a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010231f:	72 36                	jb     f0102357 <mem_init+0x1325>
f0102321:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102326:	76 07                	jbe    f010232f <mem_init+0x12fd>
f0102328:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010232d:	75 28                	jne    f0102357 <mem_init+0x1325>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010232f:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102333:	0f 85 83 00 00 00    	jne    f01023bc <mem_init+0x138a>
f0102339:	68 5b 4f 10 f0       	push   $0xf0104f5b
f010233e:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102343:	68 26 03 00 00       	push   $0x326
f0102348:	68 94 4c 10 f0       	push   $0xf0104c94
f010234d:	e8 4e dd ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102352:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102357:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010235c:	76 3f                	jbe    f010239d <mem_init+0x136b>
				assert(pgdir[i] & PTE_P);
f010235e:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102361:	f6 c2 01             	test   $0x1,%dl
f0102364:	75 19                	jne    f010237f <mem_init+0x134d>
f0102366:	68 5b 4f 10 f0       	push   $0xf0104f5b
f010236b:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102370:	68 2a 03 00 00       	push   $0x32a
f0102375:	68 94 4c 10 f0       	push   $0xf0104c94
f010237a:	e8 21 dd ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_W);
f010237f:	f6 c2 02             	test   $0x2,%dl
f0102382:	75 38                	jne    f01023bc <mem_init+0x138a>
f0102384:	68 6c 4f 10 f0       	push   $0xf0104f6c
f0102389:	68 ba 4c 10 f0       	push   $0xf0104cba
f010238e:	68 2b 03 00 00       	push   $0x32b
f0102393:	68 94 4c 10 f0       	push   $0xf0104c94
f0102398:	e8 03 dd ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
f010239d:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01023a1:	74 19                	je     f01023bc <mem_init+0x138a>
f01023a3:	68 7d 4f 10 f0       	push   $0xf0104f7d
f01023a8:	68 ba 4c 10 f0       	push   $0xf0104cba
f01023ad:	68 2d 03 00 00       	push   $0x32d
f01023b2:	68 94 4c 10 f0       	push   $0xf0104c94
f01023b7:	e8 e4 dc ff ff       	call   f01000a0 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01023bc:	83 c0 01             	add    $0x1,%eax
f01023bf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01023c4:	0f 86 50 ff ff ff    	jbe    f010231a <mem_init+0x12e8>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01023ca:	83 ec 0c             	sub    $0xc,%esp
f01023cd:	68 54 56 10 f0       	push   $0xf0105654
f01023d2:	e8 3e 0b 00 00       	call   f0102f15 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01023d7:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01023dc:	83 c4 10             	add    $0x10,%esp
f01023df:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023e4:	77 15                	ja     f01023fb <mem_init+0x13c9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023e6:	50                   	push   %eax
f01023e7:	68 74 50 10 f0       	push   $0xf0105074
f01023ec:	68 fe 00 00 00       	push   $0xfe
f01023f1:	68 94 4c 10 f0       	push   $0xf0104c94
f01023f6:	e8 a5 dc ff ff       	call   f01000a0 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01023fb:	05 00 00 00 10       	add    $0x10000000,%eax
f0102400:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102403:	b8 00 00 00 00       	mov    $0x0,%eax
f0102408:	e8 dd e5 ff ff       	call   f01009ea <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010240d:	0f 20 c0             	mov    %cr0,%eax
f0102410:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102413:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102418:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010241b:	83 ec 0c             	sub    $0xc,%esp
f010241e:	6a 00                	push   $0x0
f0102420:	e8 e2 e8 ff ff       	call   f0100d07 <page_alloc>
f0102425:	89 c3                	mov    %eax,%ebx
f0102427:	83 c4 10             	add    $0x10,%esp
f010242a:	85 c0                	test   %eax,%eax
f010242c:	75 19                	jne    f0102447 <mem_init+0x1415>
f010242e:	68 79 4d 10 f0       	push   $0xf0104d79
f0102433:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102438:	68 ed 03 00 00       	push   $0x3ed
f010243d:	68 94 4c 10 f0       	push   $0xf0104c94
f0102442:	e8 59 dc ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0102447:	83 ec 0c             	sub    $0xc,%esp
f010244a:	6a 00                	push   $0x0
f010244c:	e8 b6 e8 ff ff       	call   f0100d07 <page_alloc>
f0102451:	89 c7                	mov    %eax,%edi
f0102453:	83 c4 10             	add    $0x10,%esp
f0102456:	85 c0                	test   %eax,%eax
f0102458:	75 19                	jne    f0102473 <mem_init+0x1441>
f010245a:	68 8f 4d 10 f0       	push   $0xf0104d8f
f010245f:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102464:	68 ee 03 00 00       	push   $0x3ee
f0102469:	68 94 4c 10 f0       	push   $0xf0104c94
f010246e:	e8 2d dc ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0102473:	83 ec 0c             	sub    $0xc,%esp
f0102476:	6a 00                	push   $0x0
f0102478:	e8 8a e8 ff ff       	call   f0100d07 <page_alloc>
f010247d:	89 c6                	mov    %eax,%esi
f010247f:	83 c4 10             	add    $0x10,%esp
f0102482:	85 c0                	test   %eax,%eax
f0102484:	75 19                	jne    f010249f <mem_init+0x146d>
f0102486:	68 a5 4d 10 f0       	push   $0xf0104da5
f010248b:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102490:	68 ef 03 00 00       	push   $0x3ef
f0102495:	68 94 4c 10 f0       	push   $0xf0104c94
f010249a:	e8 01 dc ff ff       	call   f01000a0 <_panic>
	page_free(pp0);
f010249f:	83 ec 0c             	sub    $0xc,%esp
f01024a2:	53                   	push   %ebx
f01024a3:	e8 cf e8 ff ff       	call   f0100d77 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024a8:	89 f8                	mov    %edi,%eax
f01024aa:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f01024b0:	c1 f8 03             	sar    $0x3,%eax
f01024b3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024b6:	89 c2                	mov    %eax,%edx
f01024b8:	c1 ea 0c             	shr    $0xc,%edx
f01024bb:	83 c4 10             	add    $0x10,%esp
f01024be:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f01024c4:	72 12                	jb     f01024d8 <mem_init+0x14a6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024c6:	50                   	push   %eax
f01024c7:	68 8c 4f 10 f0       	push   $0xf0104f8c
f01024cc:	6a 56                	push   $0x56
f01024ce:	68 a0 4c 10 f0       	push   $0xf0104ca0
f01024d3:	e8 c8 db ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01024d8:	83 ec 04             	sub    $0x4,%esp
f01024db:	68 00 10 00 00       	push   $0x1000
f01024e0:	6a 01                	push   $0x1
f01024e2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024e7:	50                   	push   %eax
f01024e8:	e8 ea 1d 00 00       	call   f01042d7 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024ed:	89 f0                	mov    %esi,%eax
f01024ef:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f01024f5:	c1 f8 03             	sar    $0x3,%eax
f01024f8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024fb:	89 c2                	mov    %eax,%edx
f01024fd:	c1 ea 0c             	shr    $0xc,%edx
f0102500:	83 c4 10             	add    $0x10,%esp
f0102503:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f0102509:	72 12                	jb     f010251d <mem_init+0x14eb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010250b:	50                   	push   %eax
f010250c:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0102511:	6a 56                	push   $0x56
f0102513:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0102518:	e8 83 db ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010251d:	83 ec 04             	sub    $0x4,%esp
f0102520:	68 00 10 00 00       	push   $0x1000
f0102525:	6a 02                	push   $0x2
f0102527:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010252c:	50                   	push   %eax
f010252d:	e8 a5 1d 00 00       	call   f01042d7 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102532:	6a 02                	push   $0x2
f0102534:	68 00 10 00 00       	push   $0x1000
f0102539:	57                   	push   %edi
f010253a:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0102540:	e8 75 ea ff ff       	call   f0100fba <page_insert>
	assert(pp1->pp_ref == 1);
f0102545:	83 c4 20             	add    $0x20,%esp
f0102548:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010254d:	74 19                	je     f0102568 <mem_init+0x1536>
f010254f:	68 76 4e 10 f0       	push   $0xf0104e76
f0102554:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102559:	68 f4 03 00 00       	push   $0x3f4
f010255e:	68 94 4c 10 f0       	push   $0xf0104c94
f0102563:	e8 38 db ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102568:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010256f:	01 01 01 
f0102572:	74 19                	je     f010258d <mem_init+0x155b>
f0102574:	68 74 56 10 f0       	push   $0xf0105674
f0102579:	68 ba 4c 10 f0       	push   $0xf0104cba
f010257e:	68 f5 03 00 00       	push   $0x3f5
f0102583:	68 94 4c 10 f0       	push   $0xf0104c94
f0102588:	e8 13 db ff ff       	call   f01000a0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010258d:	6a 02                	push   $0x2
f010258f:	68 00 10 00 00       	push   $0x1000
f0102594:	56                   	push   %esi
f0102595:	ff 35 08 db 17 f0    	pushl  0xf017db08
f010259b:	e8 1a ea ff ff       	call   f0100fba <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01025a0:	83 c4 10             	add    $0x10,%esp
f01025a3:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01025aa:	02 02 02 
f01025ad:	74 19                	je     f01025c8 <mem_init+0x1596>
f01025af:	68 98 56 10 f0       	push   $0xf0105698
f01025b4:	68 ba 4c 10 f0       	push   $0xf0104cba
f01025b9:	68 f7 03 00 00       	push   $0x3f7
f01025be:	68 94 4c 10 f0       	push   $0xf0104c94
f01025c3:	e8 d8 da ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01025c8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025cd:	74 19                	je     f01025e8 <mem_init+0x15b6>
f01025cf:	68 98 4e 10 f0       	push   $0xf0104e98
f01025d4:	68 ba 4c 10 f0       	push   $0xf0104cba
f01025d9:	68 f8 03 00 00       	push   $0x3f8
f01025de:	68 94 4c 10 f0       	push   $0xf0104c94
f01025e3:	e8 b8 da ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f01025e8:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01025ed:	74 19                	je     f0102608 <mem_init+0x15d6>
f01025ef:	68 02 4f 10 f0       	push   $0xf0104f02
f01025f4:	68 ba 4c 10 f0       	push   $0xf0104cba
f01025f9:	68 f9 03 00 00       	push   $0x3f9
f01025fe:	68 94 4c 10 f0       	push   $0xf0104c94
f0102603:	e8 98 da ff ff       	call   f01000a0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102608:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010260f:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102612:	89 f0                	mov    %esi,%eax
f0102614:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f010261a:	c1 f8 03             	sar    $0x3,%eax
f010261d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102620:	89 c2                	mov    %eax,%edx
f0102622:	c1 ea 0c             	shr    $0xc,%edx
f0102625:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f010262b:	72 12                	jb     f010263f <mem_init+0x160d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010262d:	50                   	push   %eax
f010262e:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0102633:	6a 56                	push   $0x56
f0102635:	68 a0 4c 10 f0       	push   $0xf0104ca0
f010263a:	e8 61 da ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010263f:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102646:	03 03 03 
f0102649:	74 19                	je     f0102664 <mem_init+0x1632>
f010264b:	68 bc 56 10 f0       	push   $0xf01056bc
f0102650:	68 ba 4c 10 f0       	push   $0xf0104cba
f0102655:	68 fb 03 00 00       	push   $0x3fb
f010265a:	68 94 4c 10 f0       	push   $0xf0104c94
f010265f:	e8 3c da ff ff       	call   f01000a0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102664:	83 ec 08             	sub    $0x8,%esp
f0102667:	68 00 10 00 00       	push   $0x1000
f010266c:	ff 35 08 db 17 f0    	pushl  0xf017db08
f0102672:	e8 01 e9 ff ff       	call   f0100f78 <page_remove>
	assert(pp2->pp_ref == 0);
f0102677:	83 c4 10             	add    $0x10,%esp
f010267a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010267f:	74 19                	je     f010269a <mem_init+0x1668>
f0102681:	68 d0 4e 10 f0       	push   $0xf0104ed0
f0102686:	68 ba 4c 10 f0       	push   $0xf0104cba
f010268b:	68 fd 03 00 00       	push   $0x3fd
f0102690:	68 94 4c 10 f0       	push   $0xf0104c94
f0102695:	e8 06 da ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010269a:	8b 0d 08 db 17 f0    	mov    0xf017db08,%ecx
f01026a0:	8b 11                	mov    (%ecx),%edx
f01026a2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026a8:	89 d8                	mov    %ebx,%eax
f01026aa:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f01026b0:	c1 f8 03             	sar    $0x3,%eax
f01026b3:	c1 e0 0c             	shl    $0xc,%eax
f01026b6:	39 c2                	cmp    %eax,%edx
f01026b8:	74 19                	je     f01026d3 <mem_init+0x16a1>
f01026ba:	68 cc 51 10 f0       	push   $0xf01051cc
f01026bf:	68 ba 4c 10 f0       	push   $0xf0104cba
f01026c4:	68 00 04 00 00       	push   $0x400
f01026c9:	68 94 4c 10 f0       	push   $0xf0104c94
f01026ce:	e8 cd d9 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f01026d3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01026d9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01026de:	74 19                	je     f01026f9 <mem_init+0x16c7>
f01026e0:	68 87 4e 10 f0       	push   $0xf0104e87
f01026e5:	68 ba 4c 10 f0       	push   $0xf0104cba
f01026ea:	68 02 04 00 00       	push   $0x402
f01026ef:	68 94 4c 10 f0       	push   $0xf0104c94
f01026f4:	e8 a7 d9 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f01026f9:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01026ff:	83 ec 0c             	sub    $0xc,%esp
f0102702:	53                   	push   %ebx
f0102703:	e8 6f e6 ff ff       	call   f0100d77 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102708:	c7 04 24 e8 56 10 f0 	movl   $0xf01056e8,(%esp)
f010270f:	e8 01 08 00 00       	call   f0102f15 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102714:	83 c4 10             	add    $0x10,%esp
f0102717:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010271a:	5b                   	pop    %ebx
f010271b:	5e                   	pop    %esi
f010271c:	5f                   	pop    %edi
f010271d:	5d                   	pop    %ebp
f010271e:	c3                   	ret    

f010271f <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010271f:	55                   	push   %ebp
f0102720:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102722:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102725:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102728:	5d                   	pop    %ebp
f0102729:	c3                   	ret    

f010272a <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010272a:	55                   	push   %ebp
f010272b:	89 e5                	mov    %esp,%ebp
f010272d:	57                   	push   %edi
f010272e:	56                   	push   %esi
f010272f:	53                   	push   %ebx
f0102730:	83 ec 1c             	sub    $0x1c,%esp
f0102733:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	pte_t *pte;
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
f0102736:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102739:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = ROUNDUP((uint32_t) va + len, PGSIZE);
f010273f:	8b 45 10             	mov    0x10(%ebp),%eax
f0102742:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102745:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f010274c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102751:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	perm |= PTE_P;
f0102754:	8b 75 14             	mov    0x14(%ebp),%esi
f0102757:	83 ce 01             	or     $0x1,%esi

	for (; addr < end; addr += PGSIZE) {
f010275a:	eb 3f                	jmp    f010279b <user_mem_check+0x71>
		pte = pgdir_walk(env->env_pgdir, (void*) addr, 0); 
f010275c:	83 ec 04             	sub    $0x4,%esp
f010275f:	6a 00                	push   $0x0
f0102761:	53                   	push   %ebx
f0102762:	ff 77 5c             	pushl  0x5c(%edi)
f0102765:	e8 6c e6 ff ff       	call   f0100dd6 <pgdir_walk>
		
		if (!pte|| addr >= ULIM|| ((*pte & perm) != perm) ) {
f010276a:	83 c4 10             	add    $0x10,%esp
f010276d:	85 c0                	test   %eax,%eax
f010276f:	74 10                	je     f0102781 <user_mem_check+0x57>
f0102771:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102777:	77 08                	ja     f0102781 <user_mem_check+0x57>
f0102779:	89 f2                	mov    %esi,%edx
f010277b:	23 10                	and    (%eax),%edx
f010277d:	39 d6                	cmp    %edx,%esi
f010277f:	74 14                	je     f0102795 <user_mem_check+0x6b>
			user_mem_check_addr = addr < (uint32_t) va ? (uintptr_t) va : addr;
f0102781:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102784:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102788:	89 1d 3c ce 17 f0    	mov    %ebx,0xf017ce3c
			return -E_FAULT;
f010278e:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102793:	eb 10                	jmp    f01027a5 <user_mem_check+0x7b>
	pte_t *pte;
	uint32_t addr = ROUNDDOWN((uint32_t) va, PGSIZE);
	uint32_t end = ROUNDUP((uint32_t) va + len, PGSIZE);
	perm |= PTE_P;

	for (; addr < end; addr += PGSIZE) {
f0102795:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010279b:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010279e:	72 bc                	jb     f010275c <user_mem_check+0x32>
			user_mem_check_addr = addr < (uint32_t) va ? (uintptr_t) va : addr;
			return -E_FAULT;
		}
	}

	return 0;
f01027a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01027a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01027a8:	5b                   	pop    %ebx
f01027a9:	5e                   	pop    %esi
f01027aa:	5f                   	pop    %edi
f01027ab:	5d                   	pop    %ebp
f01027ac:	c3                   	ret    

f01027ad <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01027ad:	55                   	push   %ebp
f01027ae:	89 e5                	mov    %esp,%ebp
f01027b0:	53                   	push   %ebx
f01027b1:	83 ec 04             	sub    $0x4,%esp
f01027b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01027b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01027ba:	83 c8 04             	or     $0x4,%eax
f01027bd:	50                   	push   %eax
f01027be:	ff 75 10             	pushl  0x10(%ebp)
f01027c1:	ff 75 0c             	pushl  0xc(%ebp)
f01027c4:	53                   	push   %ebx
f01027c5:	e8 60 ff ff ff       	call   f010272a <user_mem_check>
f01027ca:	83 c4 10             	add    $0x10,%esp
f01027cd:	85 c0                	test   %eax,%eax
f01027cf:	79 21                	jns    f01027f2 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f01027d1:	83 ec 04             	sub    $0x4,%esp
f01027d4:	ff 35 3c ce 17 f0    	pushl  0xf017ce3c
f01027da:	ff 73 48             	pushl  0x48(%ebx)
f01027dd:	68 14 57 10 f0       	push   $0xf0105714
f01027e2:	e8 2e 07 00 00       	call   f0102f15 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01027e7:	89 1c 24             	mov    %ebx,(%esp)
f01027ea:	e8 02 06 00 00       	call   f0102df1 <env_destroy>
f01027ef:	83 c4 10             	add    $0x10,%esp
	}
}
f01027f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01027f5:	c9                   	leave  
f01027f6:	c3                   	ret    

f01027f7 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01027f7:	55                   	push   %ebp
f01027f8:	89 e5                	mov    %esp,%ebp
f01027fa:	57                   	push   %edi
f01027fb:	56                   	push   %esi
f01027fc:	53                   	push   %ebx
f01027fd:	83 ec 0c             	sub    $0xc,%esp
f0102800:	89 c7                	mov    %eax,%edi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
	uint32_t startadd=(uint32_t)ROUNDDOWN(va,PGSIZE);
f0102802:	89 d3                	mov    %edx,%ebx
f0102804:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t endadd=(uint32_t)ROUNDUP(va+len,PGSIZE);
f010280a:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102811:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	
	while(startadd<endadd)
f0102817:	eb 59                	jmp    f0102872 <region_alloc+0x7b>
	{
	struct PageInfo* p=page_alloc(false);	
f0102819:	83 ec 0c             	sub    $0xc,%esp
f010281c:	6a 00                	push   $0x0
f010281e:	e8 e4 e4 ff ff       	call   f0100d07 <page_alloc>
	
	if(p==NULL)
f0102823:	83 c4 10             	add    $0x10,%esp
f0102826:	85 c0                	test   %eax,%eax
f0102828:	75 17                	jne    f0102841 <region_alloc+0x4a>
	panic("Fail to alloc a page right now in region_alloc");
f010282a:	83 ec 04             	sub    $0x4,%esp
f010282d:	68 4c 57 10 f0       	push   $0xf010574c
f0102832:	68 31 01 00 00       	push   $0x131
f0102837:	68 b2 57 10 f0       	push   $0xf01057b2
f010283c:	e8 5f d8 ff ff       	call   f01000a0 <_panic>
	
	if(page_insert(e->env_pgdir,p,(void *)startadd,PTE_U|PTE_W)==-E_NO_MEM)
f0102841:	6a 06                	push   $0x6
f0102843:	53                   	push   %ebx
f0102844:	50                   	push   %eax
f0102845:	ff 77 5c             	pushl  0x5c(%edi)
f0102848:	e8 6d e7 ff ff       	call   f0100fba <page_insert>
f010284d:	83 c4 10             	add    $0x10,%esp
f0102850:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0102853:	75 17                	jne    f010286c <region_alloc+0x75>
	panic("page insert failed");
f0102855:	83 ec 04             	sub    $0x4,%esp
f0102858:	68 bd 57 10 f0       	push   $0xf01057bd
f010285d:	68 34 01 00 00       	push   $0x134
f0102862:	68 b2 57 10 f0       	push   $0xf01057b2
f0102867:	e8 34 d8 ff ff       	call   f01000a0 <_panic>
	
	startadd+=PGSIZE;
f010286c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	//   (Watch out for corner-cases!)
	
	uint32_t startadd=(uint32_t)ROUNDDOWN(va,PGSIZE);
	uint32_t endadd=(uint32_t)ROUNDUP(va+len,PGSIZE);
	
	while(startadd<endadd)
f0102872:	39 f3                	cmp    %esi,%ebx
f0102874:	72 a3                	jb     f0102819 <region_alloc+0x22>
	
	startadd+=PGSIZE;
		
	}
	
}
f0102876:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102879:	5b                   	pop    %ebx
f010287a:	5e                   	pop    %esi
f010287b:	5f                   	pop    %edi
f010287c:	5d                   	pop    %ebp
f010287d:	c3                   	ret    

f010287e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010287e:	55                   	push   %ebp
f010287f:	89 e5                	mov    %esp,%ebp
f0102881:	8b 55 08             	mov    0x8(%ebp),%edx
f0102884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102887:	85 d2                	test   %edx,%edx
f0102889:	75 11                	jne    f010289c <envid2env+0x1e>
		*env_store = curenv;
f010288b:	a1 44 ce 17 f0       	mov    0xf017ce44,%eax
f0102890:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102893:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102895:	b8 00 00 00 00       	mov    $0x0,%eax
f010289a:	eb 5e                	jmp    f01028fa <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010289c:	89 d0                	mov    %edx,%eax
f010289e:	25 ff 03 00 00       	and    $0x3ff,%eax
f01028a3:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01028a6:	c1 e0 05             	shl    $0x5,%eax
f01028a9:	03 05 48 ce 17 f0    	add    0xf017ce48,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01028af:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f01028b3:	74 05                	je     f01028ba <envid2env+0x3c>
f01028b5:	3b 50 48             	cmp    0x48(%eax),%edx
f01028b8:	74 10                	je     f01028ca <envid2env+0x4c>
		*env_store = 0;
f01028ba:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01028c3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01028c8:	eb 30                	jmp    f01028fa <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01028ca:	84 c9                	test   %cl,%cl
f01028cc:	74 22                	je     f01028f0 <envid2env+0x72>
f01028ce:	8b 15 44 ce 17 f0    	mov    0xf017ce44,%edx
f01028d4:	39 d0                	cmp    %edx,%eax
f01028d6:	74 18                	je     f01028f0 <envid2env+0x72>
f01028d8:	8b 4a 48             	mov    0x48(%edx),%ecx
f01028db:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f01028de:	74 10                	je     f01028f0 <envid2env+0x72>
		*env_store = 0;
f01028e0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01028e9:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01028ee:	eb 0a                	jmp    f01028fa <envid2env+0x7c>
	}

	*env_store = e;
f01028f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01028f3:	89 01                	mov    %eax,(%ecx)
	return 0;
f01028f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01028fa:	5d                   	pop    %ebp
f01028fb:	c3                   	ret    

f01028fc <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01028fc:	55                   	push   %ebp
f01028fd:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01028ff:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0102904:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102907:	b8 23 00 00 00       	mov    $0x23,%eax
f010290c:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010290e:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102910:	b8 10 00 00 00       	mov    $0x10,%eax
f0102915:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102917:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102919:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010291b:	ea 22 29 10 f0 08 00 	ljmp   $0x8,$0xf0102922
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102922:	b8 00 00 00 00       	mov    $0x0,%eax
f0102927:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010292a:	5d                   	pop    %ebp
f010292b:	c3                   	ret    

f010292c <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f010292c:	55                   	push   %ebp
f010292d:	89 e5                	mov    %esp,%ebp
f010292f:	56                   	push   %esi
f0102930:	53                   	push   %ebx
	// LAB 3: Your code here.
	
	env_free_list = 0;
	
	for (int i = NENV - 1 ; i >= 0; i--){
		envs[i].env_link = env_free_list;
f0102931:	8b 35 48 ce 17 f0    	mov    0xf017ce48,%esi
f0102937:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f010293d:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0102940:	ba 00 00 00 00       	mov    $0x0,%edx
f0102945:	89 c1                	mov    %eax,%ecx
f0102947:	89 50 44             	mov    %edx,0x44(%eax)
		envs[i].env_status = ENV_FREE;
f010294a:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
f0102951:	83 e8 60             	sub    $0x60,%eax
		env_free_list = &envs[i];
f0102954:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.
	
	env_free_list = 0;
	
	for (int i = NENV - 1 ; i >= 0; i--){
f0102956:	39 d8                	cmp    %ebx,%eax
f0102958:	75 eb                	jne    f0102945 <env_init+0x19>
f010295a:	89 35 4c ce 17 f0    	mov    %esi,0xf017ce4c
		envs[i].env_link = env_free_list;
		envs[i].env_status = ENV_FREE;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102960:	e8 97 ff ff ff       	call   f01028fc <env_init_percpu>
	
	
}
f0102965:	5b                   	pop    %ebx
f0102966:	5e                   	pop    %esi
f0102967:	5d                   	pop    %ebp
f0102968:	c3                   	ret    

f0102969 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102969:	55                   	push   %ebp
f010296a:	89 e5                	mov    %esp,%ebp
f010296c:	53                   	push   %ebx
f010296d:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102970:	8b 1d 4c ce 17 f0    	mov    0xf017ce4c,%ebx
f0102976:	85 db                	test   %ebx,%ebx
f0102978:	0f 84 5e 01 00 00    	je     f0102adc <env_alloc+0x173>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010297e:	83 ec 0c             	sub    $0xc,%esp
f0102981:	6a 01                	push   $0x1
f0102983:	e8 7f e3 ff ff       	call   f0100d07 <page_alloc>
f0102988:	83 c4 10             	add    $0x10,%esp
f010298b:	85 c0                	test   %eax,%eax
f010298d:	0f 84 50 01 00 00    	je     f0102ae3 <env_alloc+0x17a>
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	
	p->pp_ref++;
f0102993:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102998:	2b 05 0c db 17 f0    	sub    0xf017db0c,%eax
f010299e:	c1 f8 03             	sar    $0x3,%eax
f01029a1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029a4:	89 c2                	mov    %eax,%edx
f01029a6:	c1 ea 0c             	shr    $0xc,%edx
f01029a9:	3b 15 04 db 17 f0    	cmp    0xf017db04,%edx
f01029af:	72 12                	jb     f01029c3 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029b1:	50                   	push   %eax
f01029b2:	68 8c 4f 10 f0       	push   $0xf0104f8c
f01029b7:	6a 56                	push   $0x56
f01029b9:	68 a0 4c 10 f0       	push   $0xf0104ca0
f01029be:	e8 dd d6 ff ff       	call   f01000a0 <_panic>
	
	// set e->env_pgdir and initialize the page directory.
	e->env_pgdir = (pde_t *) page2kva(p);
f01029c3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029c8:	89 43 5c             	mov    %eax,0x5c(%ebx)
f01029cb:	b8 00 00 00 00       	mov    $0x0,%eax
	
	for (i = 0; i < PDX(UTOP); i++)
		e->env_pgdir[i] = 0;
f01029d0:	8b 53 5c             	mov    0x5c(%ebx),%edx
f01029d3:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01029da:	83 c0 04             	add    $0x4,%eax
	p->pp_ref++;
	
	// set e->env_pgdir and initialize the page directory.
	e->env_pgdir = (pde_t *) page2kva(p);
	
	for (i = 0; i < PDX(UTOP); i++)
f01029dd:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01029e2:	75 ec                	jne    f01029d0 <env_alloc+0x67>
		e->env_pgdir[i] = 0;

	for (i = PDX(UTOP); i < NPDENTRIES; i++)
		e->env_pgdir[i] = kern_pgdir[i];	
f01029e4:	8b 15 08 db 17 f0    	mov    0xf017db08,%edx
f01029ea:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01029ed:	8b 53 5c             	mov    0x5c(%ebx),%edx
f01029f0:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01029f3:	83 c0 04             	add    $0x4,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
	
	for (i = 0; i < PDX(UTOP); i++)
		e->env_pgdir[i] = 0;

	for (i = PDX(UTOP); i < NPDENTRIES; i++)
f01029f6:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029fb:	75 e7                	jne    f01029e4 <env_alloc+0x7b>
		
	
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01029fd:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a00:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a05:	77 15                	ja     f0102a1c <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a07:	50                   	push   %eax
f0102a08:	68 74 50 10 f0       	push   $0xf0105074
f0102a0d:	68 d3 00 00 00       	push   $0xd3
f0102a12:	68 b2 57 10 f0       	push   $0xf01057b2
f0102a17:	e8 84 d6 ff ff       	call   f01000a0 <_panic>
f0102a1c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102a22:	83 ca 05             	or     $0x5,%edx
f0102a25:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102a2b:	8b 43 48             	mov    0x48(%ebx),%eax
f0102a2e:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102a33:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102a38:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a3d:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102a40:	89 da                	mov    %ebx,%edx
f0102a42:	2b 15 48 ce 17 f0    	sub    0xf017ce48,%edx
f0102a48:	c1 fa 05             	sar    $0x5,%edx
f0102a4b:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102a51:	09 d0                	or     %edx,%eax
f0102a53:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102a56:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a59:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102a5c:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102a63:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102a6a:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102a71:	83 ec 04             	sub    $0x4,%esp
f0102a74:	6a 44                	push   $0x44
f0102a76:	6a 00                	push   $0x0
f0102a78:	53                   	push   %ebx
f0102a79:	e8 59 18 00 00       	call   f01042d7 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102a7e:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102a84:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102a8a:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102a90:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102a97:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102a9d:	8b 43 44             	mov    0x44(%ebx),%eax
f0102aa0:	a3 4c ce 17 f0       	mov    %eax,0xf017ce4c
	*newenv_store = e;
f0102aa5:	8b 45 08             	mov    0x8(%ebp),%eax
f0102aa8:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102aaa:	8b 53 48             	mov    0x48(%ebx),%edx
f0102aad:	a1 44 ce 17 f0       	mov    0xf017ce44,%eax
f0102ab2:	83 c4 10             	add    $0x10,%esp
f0102ab5:	85 c0                	test   %eax,%eax
f0102ab7:	74 05                	je     f0102abe <env_alloc+0x155>
f0102ab9:	8b 40 48             	mov    0x48(%eax),%eax
f0102abc:	eb 05                	jmp    f0102ac3 <env_alloc+0x15a>
f0102abe:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ac3:	83 ec 04             	sub    $0x4,%esp
f0102ac6:	52                   	push   %edx
f0102ac7:	50                   	push   %eax
f0102ac8:	68 d0 57 10 f0       	push   $0xf01057d0
f0102acd:	e8 43 04 00 00       	call   f0102f15 <cprintf>
	return 0;
f0102ad2:	83 c4 10             	add    $0x10,%esp
f0102ad5:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ada:	eb 0c                	jmp    f0102ae8 <env_alloc+0x17f>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102adc:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102ae1:	eb 05                	jmp    f0102ae8 <env_alloc+0x17f>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102ae3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102ae8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102aeb:	c9                   	leave  
f0102aec:	c3                   	ret    

f0102aed <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102aed:	55                   	push   %ebp
f0102aee:	89 e5                	mov    %esp,%ebp
f0102af0:	57                   	push   %edi
f0102af1:	56                   	push   %esi
f0102af2:	53                   	push   %ebx
f0102af3:	83 ec 34             	sub    $0x34,%esp
f0102af6:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	
	struct Env *env;
	
	int check;
	check = env_alloc(&env, 0);
f0102af9:	6a 00                	push   $0x0
f0102afb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102afe:	50                   	push   %eax
f0102aff:	e8 65 fe ff ff       	call   f0102969 <env_alloc>
	
	if (check < 0) {
f0102b04:	83 c4 10             	add    $0x10,%esp
f0102b07:	85 c0                	test   %eax,%eax
f0102b09:	79 15                	jns    f0102b20 <env_create+0x33>
		panic("env_alloc: %e", check);
f0102b0b:	50                   	push   %eax
f0102b0c:	68 e5 57 10 f0       	push   $0xf01057e5
f0102b11:	68 b9 01 00 00       	push   $0x1b9
f0102b16:	68 b2 57 10 f0       	push   $0xf01057b2
f0102b1b:	e8 80 d5 ff ff       	call   f01000a0 <_panic>
		return;
	}
	
	load_icode(env, binary);
f0102b20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b23:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// LAB 3: Your code here.
	
		// read 1st page off disk
	//readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
	
	lcr3(PADDR(e->env_pgdir));
f0102b26:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b29:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b2e:	77 15                	ja     f0102b45 <env_create+0x58>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b30:	50                   	push   %eax
f0102b31:	68 74 50 10 f0       	push   $0xf0105074
f0102b36:	68 7c 01 00 00       	push   $0x17c
f0102b3b:	68 b2 57 10 f0       	push   $0xf01057b2
f0102b40:	e8 5b d5 ff ff       	call   f01000a0 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b45:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b4a:	0f 22 d8             	mov    %eax,%cr3
	struct Proghdr *ph, *eph;
	struct Elf * ELFHDR=(struct Elf *) binary;
	// is this a valid ELF?
	
	if (ELFHDR->e_magic != ELF_MAGIC)
f0102b4d:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102b53:	74 17                	je     f0102b6c <env_create+0x7f>
		panic("Not an elf file \n");
f0102b55:	83 ec 04             	sub    $0x4,%esp
f0102b58:	68 f3 57 10 f0       	push   $0xf01057f3
f0102b5d:	68 82 01 00 00       	push   $0x182
f0102b62:	68 b2 57 10 f0       	push   $0xf01057b2
f0102b67:	e8 34 d5 ff ff       	call   f01000a0 <_panic>

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0102b6c:	89 fb                	mov    %edi,%ebx
f0102b6e:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0102b71:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102b75:	c1 e6 05             	shl    $0x5,%esi
f0102b78:	01 de                	add    %ebx,%esi
	 
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0102b7a:	8b 47 18             	mov    0x18(%edi),%eax
f0102b7d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102b80:	89 41 30             	mov    %eax,0x30(%ecx)
f0102b83:	eb 60                	jmp    f0102be5 <env_create+0xf8>
	
	
	for (; ph < eph; ph++)
{		
	
	if (ph->p_type != ELF_PROG_LOAD) 
f0102b85:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102b88:	75 58                	jne    f0102be2 <env_create+0xf5>
	continue;
	
	if (ph->p_filesz > ph->p_memsz)
f0102b8a:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102b8d:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102b90:	76 17                	jbe    f0102ba9 <env_create+0xbc>
	panic("file size greater \n");
f0102b92:	83 ec 04             	sub    $0x4,%esp
f0102b95:	68 05 58 10 f0       	push   $0xf0105805
f0102b9a:	68 94 01 00 00       	push   $0x194
f0102b9f:	68 b2 57 10 f0       	push   $0xf01057b2
f0102ba4:	e8 f7 d4 ff ff       	call   f01000a0 <_panic>
	
	region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f0102ba9:	8b 53 08             	mov    0x8(%ebx),%edx
f0102bac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102baf:	e8 43 fc ff ff       	call   f01027f7 <region_alloc>
	
	memcpy((void *) ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0102bb4:	83 ec 04             	sub    $0x4,%esp
f0102bb7:	ff 73 10             	pushl  0x10(%ebx)
f0102bba:	89 f8                	mov    %edi,%eax
f0102bbc:	03 43 04             	add    0x4(%ebx),%eax
f0102bbf:	50                   	push   %eax
f0102bc0:	ff 73 08             	pushl  0x8(%ebx)
f0102bc3:	e8 c4 17 00 00       	call   f010438c <memcpy>
	
	memset((void *) ph->p_va + ph->p_filesz, 0, (ph->p_memsz - ph->p_filesz));
f0102bc8:	8b 43 10             	mov    0x10(%ebx),%eax
f0102bcb:	83 c4 0c             	add    $0xc,%esp
f0102bce:	8b 53 14             	mov    0x14(%ebx),%edx
f0102bd1:	29 c2                	sub    %eax,%edx
f0102bd3:	52                   	push   %edx
f0102bd4:	6a 00                	push   $0x0
f0102bd6:	03 43 08             	add    0x8(%ebx),%eax
f0102bd9:	50                   	push   %eax
f0102bda:	e8 f8 16 00 00       	call   f01042d7 <memset>
f0102bdf:	83 c4 10             	add    $0x10,%esp
	e->env_tf.tf_eip = ELFHDR->e_entry;

	
	
	
	for (; ph < eph; ph++)
f0102be2:	83 c3 20             	add    $0x20,%ebx
f0102be5:	39 de                	cmp    %ebx,%esi
f0102be7:	77 9c                	ja     f0102b85 <env_create+0x98>
	
	memset((void *) ph->p_va + ph->p_filesz, 0, (ph->p_memsz - ph->p_filesz));
	
}
	
   	region_alloc(e, (void *) USTACKTOP - PGSIZE, PGSIZE);
f0102be9:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102bee:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102bf3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102bf6:	e8 fc fb ff ff       	call   f01027f7 <region_alloc>

	lcr3(PADDR(kern_pgdir));
f0102bfb:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c00:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c05:	77 15                	ja     f0102c1c <env_create+0x12f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c07:	50                   	push   %eax
f0102c08:	68 74 50 10 f0       	push   $0xf0105074
f0102c0d:	68 a0 01 00 00       	push   $0x1a0
f0102c12:	68 b2 57 10 f0       	push   $0xf01057b2
f0102c17:	e8 84 d4 ff ff       	call   f01000a0 <_panic>
f0102c1c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c21:	0f 22 d8             	mov    %eax,%cr3
		panic("env_alloc: %e", check);
		return;
	}
	
	load_icode(env, binary);
	env->env_type = type;
f0102c24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c27:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102c2a:	89 50 50             	mov    %edx,0x50(%eax)
}
f0102c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c30:	5b                   	pop    %ebx
f0102c31:	5e                   	pop    %esi
f0102c32:	5f                   	pop    %edi
f0102c33:	5d                   	pop    %ebp
f0102c34:	c3                   	ret    

f0102c35 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102c35:	55                   	push   %ebp
f0102c36:	89 e5                	mov    %esp,%ebp
f0102c38:	57                   	push   %edi
f0102c39:	56                   	push   %esi
f0102c3a:	53                   	push   %ebx
f0102c3b:	83 ec 1c             	sub    $0x1c,%esp
f0102c3e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102c41:	8b 15 44 ce 17 f0    	mov    0xf017ce44,%edx
f0102c47:	39 fa                	cmp    %edi,%edx
f0102c49:	75 29                	jne    f0102c74 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102c4b:	a1 08 db 17 f0       	mov    0xf017db08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c50:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c55:	77 15                	ja     f0102c6c <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c57:	50                   	push   %eax
f0102c58:	68 74 50 10 f0       	push   $0xf0105074
f0102c5d:	68 cf 01 00 00       	push   $0x1cf
f0102c62:	68 b2 57 10 f0       	push   $0xf01057b2
f0102c67:	e8 34 d4 ff ff       	call   f01000a0 <_panic>
f0102c6c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c71:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102c74:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102c77:	85 d2                	test   %edx,%edx
f0102c79:	74 05                	je     f0102c80 <env_free+0x4b>
f0102c7b:	8b 42 48             	mov    0x48(%edx),%eax
f0102c7e:	eb 05                	jmp    f0102c85 <env_free+0x50>
f0102c80:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c85:	83 ec 04             	sub    $0x4,%esp
f0102c88:	51                   	push   %ecx
f0102c89:	50                   	push   %eax
f0102c8a:	68 19 58 10 f0       	push   $0xf0105819
f0102c8f:	e8 81 02 00 00       	call   f0102f15 <cprintf>
f0102c94:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102c97:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102c9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102ca1:	89 d0                	mov    %edx,%eax
f0102ca3:	c1 e0 02             	shl    $0x2,%eax
f0102ca6:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102ca9:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102cac:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102caf:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102cb5:	0f 84 a8 00 00 00    	je     f0102d63 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102cbb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cc1:	89 f0                	mov    %esi,%eax
f0102cc3:	c1 e8 0c             	shr    $0xc,%eax
f0102cc6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102cc9:	39 05 04 db 17 f0    	cmp    %eax,0xf017db04
f0102ccf:	77 15                	ja     f0102ce6 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cd1:	56                   	push   %esi
f0102cd2:	68 8c 4f 10 f0       	push   $0xf0104f8c
f0102cd7:	68 de 01 00 00       	push   $0x1de
f0102cdc:	68 b2 57 10 f0       	push   $0xf01057b2
f0102ce1:	e8 ba d3 ff ff       	call   f01000a0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102ce6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ce9:	c1 e0 16             	shl    $0x16,%eax
f0102cec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102cef:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102cf4:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102cfb:	01 
f0102cfc:	74 17                	je     f0102d15 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102cfe:	83 ec 08             	sub    $0x8,%esp
f0102d01:	89 d8                	mov    %ebx,%eax
f0102d03:	c1 e0 0c             	shl    $0xc,%eax
f0102d06:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102d09:	50                   	push   %eax
f0102d0a:	ff 77 5c             	pushl  0x5c(%edi)
f0102d0d:	e8 66 e2 ff ff       	call   f0100f78 <page_remove>
f0102d12:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102d15:	83 c3 01             	add    $0x1,%ebx
f0102d18:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102d1e:	75 d4                	jne    f0102cf4 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102d20:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d23:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102d26:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d2d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102d30:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0102d36:	72 14                	jb     f0102d4c <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102d38:	83 ec 04             	sub    $0x4,%esp
f0102d3b:	68 98 50 10 f0       	push   $0xf0105098
f0102d40:	6a 4f                	push   $0x4f
f0102d42:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0102d47:	e8 54 d3 ff ff       	call   f01000a0 <_panic>
		page_decref(pa2page(pa));
f0102d4c:	83 ec 0c             	sub    $0xc,%esp
f0102d4f:	a1 0c db 17 f0       	mov    0xf017db0c,%eax
f0102d54:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d57:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102d5a:	50                   	push   %eax
f0102d5b:	e8 4f e0 ff ff       	call   f0100daf <page_decref>
f0102d60:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102d63:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102d67:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d6a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102d6f:	0f 85 29 ff ff ff    	jne    f0102c9e <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102d75:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d78:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d7d:	77 15                	ja     f0102d94 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d7f:	50                   	push   %eax
f0102d80:	68 74 50 10 f0       	push   $0xf0105074
f0102d85:	68 ec 01 00 00       	push   $0x1ec
f0102d8a:	68 b2 57 10 f0       	push   $0xf01057b2
f0102d8f:	e8 0c d3 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = 0;
f0102d94:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d9b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102da0:	c1 e8 0c             	shr    $0xc,%eax
f0102da3:	3b 05 04 db 17 f0    	cmp    0xf017db04,%eax
f0102da9:	72 14                	jb     f0102dbf <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102dab:	83 ec 04             	sub    $0x4,%esp
f0102dae:	68 98 50 10 f0       	push   $0xf0105098
f0102db3:	6a 4f                	push   $0x4f
f0102db5:	68 a0 4c 10 f0       	push   $0xf0104ca0
f0102dba:	e8 e1 d2 ff ff       	call   f01000a0 <_panic>
	page_decref(pa2page(pa));
f0102dbf:	83 ec 0c             	sub    $0xc,%esp
f0102dc2:	8b 15 0c db 17 f0    	mov    0xf017db0c,%edx
f0102dc8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102dcb:	50                   	push   %eax
f0102dcc:	e8 de df ff ff       	call   f0100daf <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102dd1:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102dd8:	a1 4c ce 17 f0       	mov    0xf017ce4c,%eax
f0102ddd:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102de0:	89 3d 4c ce 17 f0    	mov    %edi,0xf017ce4c
}
f0102de6:	83 c4 10             	add    $0x10,%esp
f0102de9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dec:	5b                   	pop    %ebx
f0102ded:	5e                   	pop    %esi
f0102dee:	5f                   	pop    %edi
f0102def:	5d                   	pop    %ebp
f0102df0:	c3                   	ret    

f0102df1 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102df1:	55                   	push   %ebp
f0102df2:	89 e5                	mov    %esp,%ebp
f0102df4:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102df7:	ff 75 08             	pushl  0x8(%ebp)
f0102dfa:	e8 36 fe ff ff       	call   f0102c35 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102dff:	c7 04 24 7c 57 10 f0 	movl   $0xf010577c,(%esp)
f0102e06:	e8 0a 01 00 00       	call   f0102f15 <cprintf>
f0102e0b:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102e0e:	83 ec 0c             	sub    $0xc,%esp
f0102e11:	6a 00                	push   $0x0
f0102e13:	e8 94 d9 ff ff       	call   f01007ac <monitor>
f0102e18:	83 c4 10             	add    $0x10,%esp
f0102e1b:	eb f1                	jmp    f0102e0e <env_destroy+0x1d>

f0102e1d <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102e1d:	55                   	push   %ebp
f0102e1e:	89 e5                	mov    %esp,%ebp
f0102e20:	83 ec 0c             	sub    $0xc,%esp
	asm volatile(
f0102e23:	8b 65 08             	mov    0x8(%ebp),%esp
f0102e26:	61                   	popa   
f0102e27:	07                   	pop    %es
f0102e28:	1f                   	pop    %ds
f0102e29:	83 c4 08             	add    $0x8,%esp
f0102e2c:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102e2d:	68 2f 58 10 f0       	push   $0xf010582f
f0102e32:	68 15 02 00 00       	push   $0x215
f0102e37:	68 b2 57 10 f0       	push   $0xf01057b2
f0102e3c:	e8 5f d2 ff ff       	call   f01000a0 <_panic>

f0102e41 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102e41:	55                   	push   %ebp
f0102e42:	89 e5                	mov    %esp,%ebp
f0102e44:	83 ec 08             	sub    $0x8,%esp
f0102e47:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// env_status : ENV_FREE, ENV_RUNNABLE, ENV_RUNNING, ENV_NOT_RUNNABLE

	if (curenv == NULL || curenv!= e) 
f0102e4a:	8b 15 44 ce 17 f0    	mov    0xf017ce44,%edx
f0102e50:	39 c2                	cmp    %eax,%edx
f0102e52:	75 04                	jne    f0102e58 <env_run+0x17>
f0102e54:	85 d2                	test   %edx,%edx
f0102e56:	75 48                	jne    f0102ea0 <env_run+0x5f>
	{
		if (curenv && curenv->env_status == ENV_RUNNING)
f0102e58:	85 d2                	test   %edx,%edx
f0102e5a:	74 0d                	je     f0102e69 <env_run+0x28>
f0102e5c:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0102e60:	75 07                	jne    f0102e69 <env_run+0x28>
			
			curenv->env_status = ENV_RUNNABLE;
f0102e62:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
		curenv = e;
f0102e69:	a3 44 ce 17 f0       	mov    %eax,0xf017ce44
	
		curenv->env_status = ENV_RUNNING;
f0102e6e:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0102e75:	83 40 58 01          	addl   $0x1,0x58(%eax)
		lcr3(PADDR(curenv->env_pgdir));
f0102e79:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e7c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e81:	77 15                	ja     f0102e98 <env_run+0x57>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e83:	50                   	push   %eax
f0102e84:	68 74 50 10 f0       	push   $0xf0105074
f0102e89:	68 3e 02 00 00       	push   $0x23e
f0102e8e:	68 b2 57 10 f0       	push   $0xf01057b2
f0102e93:	e8 08 d2 ff ff       	call   f01000a0 <_panic>
f0102e98:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e9d:	0f 22 d8             	mov    %eax,%cr3
	}

	

	
	env_pop_tf(&(curenv->env_tf));
f0102ea0:	83 ec 0c             	sub    $0xc,%esp
f0102ea3:	ff 35 44 ce 17 f0    	pushl  0xf017ce44
f0102ea9:	e8 6f ff ff ff       	call   f0102e1d <env_pop_tf>

f0102eae <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102eae:	55                   	push   %ebp
f0102eaf:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102eb1:	ba 70 00 00 00       	mov    $0x70,%edx
f0102eb6:	8b 45 08             	mov    0x8(%ebp),%eax
f0102eb9:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102eba:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ebf:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102ec0:	0f b6 c0             	movzbl %al,%eax
}
f0102ec3:	5d                   	pop    %ebp
f0102ec4:	c3                   	ret    

f0102ec5 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102ec5:	55                   	push   %ebp
f0102ec6:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102ec8:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ecd:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ed0:	ee                   	out    %al,(%dx)
f0102ed1:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ed9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102eda:	5d                   	pop    %ebp
f0102edb:	c3                   	ret    

f0102edc <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102edc:	55                   	push   %ebp
f0102edd:	89 e5                	mov    %esp,%ebp
f0102edf:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102ee2:	ff 75 08             	pushl  0x8(%ebp)
f0102ee5:	e8 2b d7 ff ff       	call   f0100615 <cputchar>
	*cnt++;
}
f0102eea:	83 c4 10             	add    $0x10,%esp
f0102eed:	c9                   	leave  
f0102eee:	c3                   	ret    

f0102eef <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102eef:	55                   	push   %ebp
f0102ef0:	89 e5                	mov    %esp,%ebp
f0102ef2:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102ef5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102efc:	ff 75 0c             	pushl  0xc(%ebp)
f0102eff:	ff 75 08             	pushl  0x8(%ebp)
f0102f02:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f05:	50                   	push   %eax
f0102f06:	68 dc 2e 10 f0       	push   $0xf0102edc
f0102f0b:	e8 a2 0c 00 00       	call   f0103bb2 <vprintfmt>
	return cnt;
}
f0102f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f13:	c9                   	leave  
f0102f14:	c3                   	ret    

f0102f15 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102f15:	55                   	push   %ebp
f0102f16:	89 e5                	mov    %esp,%ebp
f0102f18:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102f1b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102f1e:	50                   	push   %eax
f0102f1f:	ff 75 08             	pushl  0x8(%ebp)
f0102f22:	e8 c8 ff ff ff       	call   f0102eef <vcprintf>
	va_end(ap);

	return cnt;
}
f0102f27:	c9                   	leave  
f0102f28:	c3                   	ret    

f0102f29 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102f29:	55                   	push   %ebp
f0102f2a:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102f2c:	b8 80 d6 17 f0       	mov    $0xf017d680,%eax
f0102f31:	c7 05 84 d6 17 f0 00 	movl   $0xf0000000,0xf017d684
f0102f38:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102f3b:	66 c7 05 88 d6 17 f0 	movw   $0x10,0xf017d688
f0102f42:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102f44:	66 c7 05 48 b3 11 f0 	movw   $0x67,0xf011b348
f0102f4b:	67 00 
f0102f4d:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f0102f53:	89 c2                	mov    %eax,%edx
f0102f55:	c1 ea 10             	shr    $0x10,%edx
f0102f58:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0102f5e:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f0102f65:	c1 e8 18             	shr    $0x18,%eax
f0102f68:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102f6d:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0102f74:	b8 28 00 00 00       	mov    $0x28,%eax
f0102f79:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0102f7c:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f0102f81:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0102f84:	5d                   	pop    %ebp
f0102f85:	c3                   	ret    

f0102f86 <trap_init>:
}


void
trap_init(void)
{
f0102f86:	55                   	push   %ebp
f0102f87:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE],0,GD_KT,divide_zero,DPLKERN);    //CSS=kernel text
f0102f89:	b8 5a 36 10 f0       	mov    $0xf010365a,%eax
f0102f8e:	66 a3 60 ce 17 f0    	mov    %ax,0xf017ce60
f0102f94:	66 c7 05 62 ce 17 f0 	movw   $0x8,0xf017ce62
f0102f9b:	08 00 
f0102f9d:	c6 05 64 ce 17 f0 00 	movb   $0x0,0xf017ce64
f0102fa4:	c6 05 65 ce 17 f0 8e 	movb   $0x8e,0xf017ce65
f0102fab:	c1 e8 10             	shr    $0x10,%eax
f0102fae:	66 a3 66 ce 17 f0    	mov    %ax,0xf017ce66
    SETGATE(idt[T_BRKPT],0,GD_KT,brkpoint,DPLUSR);
f0102fb4:	b8 60 36 10 f0       	mov    $0xf0103660,%eax
f0102fb9:	66 a3 78 ce 17 f0    	mov    %ax,0xf017ce78
f0102fbf:	66 c7 05 7a ce 17 f0 	movw   $0x8,0xf017ce7a
f0102fc6:	08 00 
f0102fc8:	c6 05 7c ce 17 f0 00 	movb   $0x0,0xf017ce7c
f0102fcf:	c6 05 7d ce 17 f0 ee 	movb   $0xee,0xf017ce7d
f0102fd6:	c1 e8 10             	shr    $0x10,%eax
f0102fd9:	66 a3 7e ce 17 f0    	mov    %ax,0xf017ce7e
    SETGATE(idt[T_SEGNP],0,GD_KT,no_seg,DPLKERN);
f0102fdf:	b8 66 36 10 f0       	mov    $0xf0103666,%eax
f0102fe4:	66 a3 b8 ce 17 f0    	mov    %ax,0xf017ceb8
f0102fea:	66 c7 05 ba ce 17 f0 	movw   $0x8,0xf017ceba
f0102ff1:	08 00 
f0102ff3:	c6 05 bc ce 17 f0 00 	movb   $0x0,0xf017cebc
f0102ffa:	c6 05 bd ce 17 f0 8e 	movb   $0x8e,0xf017cebd
f0103001:	c1 e8 10             	shr    $0x10,%eax
f0103004:	66 a3 be ce 17 f0    	mov    %ax,0xf017cebe
    SETGATE(idt[T_DEBUG],0,GD_KT,debug,DPLKERN);
f010300a:	b8 6a 36 10 f0       	mov    $0xf010366a,%eax
f010300f:	66 a3 68 ce 17 f0    	mov    %ax,0xf017ce68
f0103015:	66 c7 05 6a ce 17 f0 	movw   $0x8,0xf017ce6a
f010301c:	08 00 
f010301e:	c6 05 6c ce 17 f0 00 	movb   $0x0,0xf017ce6c
f0103025:	c6 05 6d ce 17 f0 8e 	movb   $0x8e,0xf017ce6d
f010302c:	c1 e8 10             	shr    $0x10,%eax
f010302f:	66 a3 6e ce 17 f0    	mov    %ax,0xf017ce6e
    SETGATE(idt[T_NMI],0,GD_KT,nmi,DPLKERN);
f0103035:	b8 70 36 10 f0       	mov    $0xf0103670,%eax
f010303a:	66 a3 70 ce 17 f0    	mov    %ax,0xf017ce70
f0103040:	66 c7 05 72 ce 17 f0 	movw   $0x8,0xf017ce72
f0103047:	08 00 
f0103049:	c6 05 74 ce 17 f0 00 	movb   $0x0,0xf017ce74
f0103050:	c6 05 75 ce 17 f0 8e 	movb   $0x8e,0xf017ce75
f0103057:	c1 e8 10             	shr    $0x10,%eax
f010305a:	66 a3 76 ce 17 f0    	mov    %ax,0xf017ce76
    SETGATE(idt[T_OFLOW],0,GD_KT,oflow,DPLKERN);
f0103060:	b8 76 36 10 f0       	mov    $0xf0103676,%eax
f0103065:	66 a3 80 ce 17 f0    	mov    %ax,0xf017ce80
f010306b:	66 c7 05 82 ce 17 f0 	movw   $0x8,0xf017ce82
f0103072:	08 00 
f0103074:	c6 05 84 ce 17 f0 00 	movb   $0x0,0xf017ce84
f010307b:	c6 05 85 ce 17 f0 8e 	movb   $0x8e,0xf017ce85
f0103082:	c1 e8 10             	shr    $0x10,%eax
f0103085:	66 a3 86 ce 17 f0    	mov    %ax,0xf017ce86
    SETGATE(idt[T_BOUND],0,GD_KT,bound,DPLKERN);
f010308b:	b8 7c 36 10 f0       	mov    $0xf010367c,%eax
f0103090:	66 a3 88 ce 17 f0    	mov    %ax,0xf017ce88
f0103096:	66 c7 05 8a ce 17 f0 	movw   $0x8,0xf017ce8a
f010309d:	08 00 
f010309f:	c6 05 8c ce 17 f0 00 	movb   $0x0,0xf017ce8c
f01030a6:	c6 05 8d ce 17 f0 8e 	movb   $0x8e,0xf017ce8d
f01030ad:	c1 e8 10             	shr    $0x10,%eax
f01030b0:	66 a3 8e ce 17 f0    	mov    %ax,0xf017ce8e
    SETGATE(idt[T_ILLOP],0,GD_KT,illop,DPLKERN);
f01030b6:	b8 82 36 10 f0       	mov    $0xf0103682,%eax
f01030bb:	66 a3 90 ce 17 f0    	mov    %ax,0xf017ce90
f01030c1:	66 c7 05 92 ce 17 f0 	movw   $0x8,0xf017ce92
f01030c8:	08 00 
f01030ca:	c6 05 94 ce 17 f0 00 	movb   $0x0,0xf017ce94
f01030d1:	c6 05 95 ce 17 f0 8e 	movb   $0x8e,0xf017ce95
f01030d8:	c1 e8 10             	shr    $0x10,%eax
f01030db:	66 a3 96 ce 17 f0    	mov    %ax,0xf017ce96
    SETGATE(idt[T_DEVICE],0,GD_KT,device,DPLKERN);
f01030e1:	b8 88 36 10 f0       	mov    $0xf0103688,%eax
f01030e6:	66 a3 98 ce 17 f0    	mov    %ax,0xf017ce98
f01030ec:	66 c7 05 9a ce 17 f0 	movw   $0x8,0xf017ce9a
f01030f3:	08 00 
f01030f5:	c6 05 9c ce 17 f0 00 	movb   $0x0,0xf017ce9c
f01030fc:	c6 05 9d ce 17 f0 8e 	movb   $0x8e,0xf017ce9d
f0103103:	c1 e8 10             	shr    $0x10,%eax
f0103106:	66 a3 9e ce 17 f0    	mov    %ax,0xf017ce9e
    SETGATE(idt[T_DBLFLT],0,GD_KT,dblflt,DPLKERN);
f010310c:	b8 8e 36 10 f0       	mov    $0xf010368e,%eax
f0103111:	66 a3 a0 ce 17 f0    	mov    %ax,0xf017cea0
f0103117:	66 c7 05 a2 ce 17 f0 	movw   $0x8,0xf017cea2
f010311e:	08 00 
f0103120:	c6 05 a4 ce 17 f0 00 	movb   $0x0,0xf017cea4
f0103127:	c6 05 a5 ce 17 f0 8e 	movb   $0x8e,0xf017cea5
f010312e:	c1 e8 10             	shr    $0x10,%eax
f0103131:	66 a3 a6 ce 17 f0    	mov    %ax,0xf017cea6
    SETGATE(idt[T_TSS], 0, GD_KT, tss, DPLKERN);
f0103137:	b8 92 36 10 f0       	mov    $0xf0103692,%eax
f010313c:	66 a3 b0 ce 17 f0    	mov    %ax,0xf017ceb0
f0103142:	66 c7 05 b2 ce 17 f0 	movw   $0x8,0xf017ceb2
f0103149:	08 00 
f010314b:	c6 05 b4 ce 17 f0 00 	movb   $0x0,0xf017ceb4
f0103152:	c6 05 b5 ce 17 f0 8e 	movb   $0x8e,0xf017ceb5
f0103159:	c1 e8 10             	shr    $0x10,%eax
f010315c:	66 a3 b6 ce 17 f0    	mov    %ax,0xf017ceb6
    SETGATE(idt[T_STACK], 0, GD_KT, stack, DPLKERN);
f0103162:	b8 96 36 10 f0       	mov    $0xf0103696,%eax
f0103167:	66 a3 c0 ce 17 f0    	mov    %ax,0xf017cec0
f010316d:	66 c7 05 c2 ce 17 f0 	movw   $0x8,0xf017cec2
f0103174:	08 00 
f0103176:	c6 05 c4 ce 17 f0 00 	movb   $0x0,0xf017cec4
f010317d:	c6 05 c5 ce 17 f0 8e 	movb   $0x8e,0xf017cec5
f0103184:	c1 e8 10             	shr    $0x10,%eax
f0103187:	66 a3 c6 ce 17 f0    	mov    %ax,0xf017cec6
    SETGATE(idt[T_GPFLT], 0, GD_KT, gpflt, DPLKERN);
f010318d:	b8 9a 36 10 f0       	mov    $0xf010369a,%eax
f0103192:	66 a3 c8 ce 17 f0    	mov    %ax,0xf017cec8
f0103198:	66 c7 05 ca ce 17 f0 	movw   $0x8,0xf017ceca
f010319f:	08 00 
f01031a1:	c6 05 cc ce 17 f0 00 	movb   $0x0,0xf017cecc
f01031a8:	c6 05 cd ce 17 f0 8e 	movb   $0x8e,0xf017cecd
f01031af:	c1 e8 10             	shr    $0x10,%eax
f01031b2:	66 a3 ce ce 17 f0    	mov    %ax,0xf017cece
    SETGATE(idt[T_PGFLT], 0, GD_KT, pgflt, DPLKERN);
f01031b8:	b8 9e 36 10 f0       	mov    $0xf010369e,%eax
f01031bd:	66 a3 d0 ce 17 f0    	mov    %ax,0xf017ced0
f01031c3:	66 c7 05 d2 ce 17 f0 	movw   $0x8,0xf017ced2
f01031ca:	08 00 
f01031cc:	c6 05 d4 ce 17 f0 00 	movb   $0x0,0xf017ced4
f01031d3:	c6 05 d5 ce 17 f0 8e 	movb   $0x8e,0xf017ced5
f01031da:	c1 e8 10             	shr    $0x10,%eax
f01031dd:	66 a3 d6 ce 17 f0    	mov    %ax,0xf017ced6
    SETGATE(idt[T_FPERR], 0, GD_KT, fperr, DPLKERN);
f01031e3:	b8 a2 36 10 f0       	mov    $0xf01036a2,%eax
f01031e8:	66 a3 e0 ce 17 f0    	mov    %ax,0xf017cee0
f01031ee:	66 c7 05 e2 ce 17 f0 	movw   $0x8,0xf017cee2
f01031f5:	08 00 
f01031f7:	c6 05 e4 ce 17 f0 00 	movb   $0x0,0xf017cee4
f01031fe:	c6 05 e5 ce 17 f0 8e 	movb   $0x8e,0xf017cee5
f0103205:	c1 e8 10             	shr    $0x10,%eax
f0103208:	66 a3 e6 ce 17 f0    	mov    %ax,0xf017cee6
    SETGATE(idt[T_ALIGN], 0, GD_KT, align, DPLKERN);
f010320e:	b8 a8 36 10 f0       	mov    $0xf01036a8,%eax
f0103213:	66 a3 e8 ce 17 f0    	mov    %ax,0xf017cee8
f0103219:	66 c7 05 ea ce 17 f0 	movw   $0x8,0xf017ceea
f0103220:	08 00 
f0103222:	c6 05 ec ce 17 f0 00 	movb   $0x0,0xf017ceec
f0103229:	c6 05 ed ce 17 f0 8e 	movb   $0x8e,0xf017ceed
f0103230:	c1 e8 10             	shr    $0x10,%eax
f0103233:	66 a3 ee ce 17 f0    	mov    %ax,0xf017ceee
    SETGATE(idt[T_MCHK], 0, GD_KT, mchk, DPLKERN);
f0103239:	b8 ac 36 10 f0       	mov    $0xf01036ac,%eax
f010323e:	66 a3 f0 ce 17 f0    	mov    %ax,0xf017cef0
f0103244:	66 c7 05 f2 ce 17 f0 	movw   $0x8,0xf017cef2
f010324b:	08 00 
f010324d:	c6 05 f4 ce 17 f0 00 	movb   $0x0,0xf017cef4
f0103254:	c6 05 f5 ce 17 f0 8e 	movb   $0x8e,0xf017cef5
f010325b:	c1 e8 10             	shr    $0x10,%eax
f010325e:	66 a3 f6 ce 17 f0    	mov    %ax,0xf017cef6
    SETGATE(idt[T_SIMDERR], 0, GD_KT, simderr, DPLKERN);
f0103264:	b8 b2 36 10 f0       	mov    $0xf01036b2,%eax
f0103269:	66 a3 f8 ce 17 f0    	mov    %ax,0xf017cef8
f010326f:	66 c7 05 fa ce 17 f0 	movw   $0x8,0xf017cefa
f0103276:	08 00 
f0103278:	c6 05 fc ce 17 f0 00 	movb   $0x0,0xf017cefc
f010327f:	c6 05 fd ce 17 f0 8e 	movb   $0x8e,0xf017cefd
f0103286:	c1 e8 10             	shr    $0x10,%eax
f0103289:	66 a3 fe ce 17 f0    	mov    %ax,0xf017cefe


    SETGATE(idt[T_SYSCALL], 0, GD_KT, syscalls, DPLUSR);
f010328f:	b8 b8 36 10 f0       	mov    $0xf01036b8,%eax
f0103294:	66 a3 e0 cf 17 f0    	mov    %ax,0xf017cfe0
f010329a:	66 c7 05 e2 cf 17 f0 	movw   $0x8,0xf017cfe2
f01032a1:	08 00 
f01032a3:	c6 05 e4 cf 17 f0 00 	movb   $0x0,0xf017cfe4
f01032aa:	c6 05 e5 cf 17 f0 ee 	movb   $0xee,0xf017cfe5
f01032b1:	c1 e8 10             	shr    $0x10,%eax
f01032b4:	66 a3 e6 cf 17 f0    	mov    %ax,0xf017cfe6



	// Per-CPU setup 
	trap_init_percpu();
f01032ba:	e8 6a fc ff ff       	call   f0102f29 <trap_init_percpu>
}
f01032bf:	5d                   	pop    %ebp
f01032c0:	c3                   	ret    

f01032c1 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01032c1:	55                   	push   %ebp
f01032c2:	89 e5                	mov    %esp,%ebp
f01032c4:	53                   	push   %ebx
f01032c5:	83 ec 0c             	sub    $0xc,%esp
f01032c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01032cb:	ff 33                	pushl  (%ebx)
f01032cd:	68 3b 58 10 f0       	push   $0xf010583b
f01032d2:	e8 3e fc ff ff       	call   f0102f15 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01032d7:	83 c4 08             	add    $0x8,%esp
f01032da:	ff 73 04             	pushl  0x4(%ebx)
f01032dd:	68 4a 58 10 f0       	push   $0xf010584a
f01032e2:	e8 2e fc ff ff       	call   f0102f15 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01032e7:	83 c4 08             	add    $0x8,%esp
f01032ea:	ff 73 08             	pushl  0x8(%ebx)
f01032ed:	68 59 58 10 f0       	push   $0xf0105859
f01032f2:	e8 1e fc ff ff       	call   f0102f15 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01032f7:	83 c4 08             	add    $0x8,%esp
f01032fa:	ff 73 0c             	pushl  0xc(%ebx)
f01032fd:	68 68 58 10 f0       	push   $0xf0105868
f0103302:	e8 0e fc ff ff       	call   f0102f15 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103307:	83 c4 08             	add    $0x8,%esp
f010330a:	ff 73 10             	pushl  0x10(%ebx)
f010330d:	68 77 58 10 f0       	push   $0xf0105877
f0103312:	e8 fe fb ff ff       	call   f0102f15 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103317:	83 c4 08             	add    $0x8,%esp
f010331a:	ff 73 14             	pushl  0x14(%ebx)
f010331d:	68 86 58 10 f0       	push   $0xf0105886
f0103322:	e8 ee fb ff ff       	call   f0102f15 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103327:	83 c4 08             	add    $0x8,%esp
f010332a:	ff 73 18             	pushl  0x18(%ebx)
f010332d:	68 95 58 10 f0       	push   $0xf0105895
f0103332:	e8 de fb ff ff       	call   f0102f15 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103337:	83 c4 08             	add    $0x8,%esp
f010333a:	ff 73 1c             	pushl  0x1c(%ebx)
f010333d:	68 a4 58 10 f0       	push   $0xf01058a4
f0103342:	e8 ce fb ff ff       	call   f0102f15 <cprintf>
}
f0103347:	83 c4 10             	add    $0x10,%esp
f010334a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010334d:	c9                   	leave  
f010334e:	c3                   	ret    

f010334f <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010334f:	55                   	push   %ebp
f0103350:	89 e5                	mov    %esp,%ebp
f0103352:	56                   	push   %esi
f0103353:	53                   	push   %ebx
f0103354:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103357:	83 ec 08             	sub    $0x8,%esp
f010335a:	53                   	push   %ebx
f010335b:	68 f1 59 10 f0       	push   $0xf01059f1
f0103360:	e8 b0 fb ff ff       	call   f0102f15 <cprintf>
	print_regs(&tf->tf_regs);
f0103365:	89 1c 24             	mov    %ebx,(%esp)
f0103368:	e8 54 ff ff ff       	call   f01032c1 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010336d:	83 c4 08             	add    $0x8,%esp
f0103370:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103374:	50                   	push   %eax
f0103375:	68 f5 58 10 f0       	push   $0xf01058f5
f010337a:	e8 96 fb ff ff       	call   f0102f15 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010337f:	83 c4 08             	add    $0x8,%esp
f0103382:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103386:	50                   	push   %eax
f0103387:	68 08 59 10 f0       	push   $0xf0105908
f010338c:	e8 84 fb ff ff       	call   f0102f15 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103391:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103394:	83 c4 10             	add    $0x10,%esp
f0103397:	83 f8 13             	cmp    $0x13,%eax
f010339a:	77 09                	ja     f01033a5 <print_trapframe+0x56>
		return excnames[trapno];
f010339c:	8b 14 85 c0 5b 10 f0 	mov    -0xfefa440(,%eax,4),%edx
f01033a3:	eb 10                	jmp    f01033b5 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f01033a5:	83 f8 30             	cmp    $0x30,%eax
f01033a8:	b9 bf 58 10 f0       	mov    $0xf01058bf,%ecx
f01033ad:	ba b3 58 10 f0       	mov    $0xf01058b3,%edx
f01033b2:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01033b5:	83 ec 04             	sub    $0x4,%esp
f01033b8:	52                   	push   %edx
f01033b9:	50                   	push   %eax
f01033ba:	68 1b 59 10 f0       	push   $0xf010591b
f01033bf:	e8 51 fb ff ff       	call   f0102f15 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01033c4:	83 c4 10             	add    $0x10,%esp
f01033c7:	3b 1d 60 d6 17 f0    	cmp    0xf017d660,%ebx
f01033cd:	75 1a                	jne    f01033e9 <print_trapframe+0x9a>
f01033cf:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01033d3:	75 14                	jne    f01033e9 <print_trapframe+0x9a>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01033d5:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01033d8:	83 ec 08             	sub    $0x8,%esp
f01033db:	50                   	push   %eax
f01033dc:	68 2d 59 10 f0       	push   $0xf010592d
f01033e1:	e8 2f fb ff ff       	call   f0102f15 <cprintf>
f01033e6:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01033e9:	83 ec 08             	sub    $0x8,%esp
f01033ec:	ff 73 2c             	pushl  0x2c(%ebx)
f01033ef:	68 3c 59 10 f0       	push   $0xf010593c
f01033f4:	e8 1c fb ff ff       	call   f0102f15 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01033f9:	83 c4 10             	add    $0x10,%esp
f01033fc:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103400:	75 49                	jne    f010344b <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103402:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103405:	89 c2                	mov    %eax,%edx
f0103407:	83 e2 01             	and    $0x1,%edx
f010340a:	ba d9 58 10 f0       	mov    $0xf01058d9,%edx
f010340f:	b9 ce 58 10 f0       	mov    $0xf01058ce,%ecx
f0103414:	0f 44 ca             	cmove  %edx,%ecx
f0103417:	89 c2                	mov    %eax,%edx
f0103419:	83 e2 02             	and    $0x2,%edx
f010341c:	ba eb 58 10 f0       	mov    $0xf01058eb,%edx
f0103421:	be e5 58 10 f0       	mov    $0xf01058e5,%esi
f0103426:	0f 45 d6             	cmovne %esi,%edx
f0103429:	83 e0 04             	and    $0x4,%eax
f010342c:	be 1c 5a 10 f0       	mov    $0xf0105a1c,%esi
f0103431:	b8 f0 58 10 f0       	mov    $0xf01058f0,%eax
f0103436:	0f 44 c6             	cmove  %esi,%eax
f0103439:	51                   	push   %ecx
f010343a:	52                   	push   %edx
f010343b:	50                   	push   %eax
f010343c:	68 4a 59 10 f0       	push   $0xf010594a
f0103441:	e8 cf fa ff ff       	call   f0102f15 <cprintf>
f0103446:	83 c4 10             	add    $0x10,%esp
f0103449:	eb 10                	jmp    f010345b <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010344b:	83 ec 0c             	sub    $0xc,%esp
f010344e:	68 03 58 10 f0       	push   $0xf0105803
f0103453:	e8 bd fa ff ff       	call   f0102f15 <cprintf>
f0103458:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010345b:	83 ec 08             	sub    $0x8,%esp
f010345e:	ff 73 30             	pushl  0x30(%ebx)
f0103461:	68 59 59 10 f0       	push   $0xf0105959
f0103466:	e8 aa fa ff ff       	call   f0102f15 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010346b:	83 c4 08             	add    $0x8,%esp
f010346e:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103472:	50                   	push   %eax
f0103473:	68 68 59 10 f0       	push   $0xf0105968
f0103478:	e8 98 fa ff ff       	call   f0102f15 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010347d:	83 c4 08             	add    $0x8,%esp
f0103480:	ff 73 38             	pushl  0x38(%ebx)
f0103483:	68 7b 59 10 f0       	push   $0xf010597b
f0103488:	e8 88 fa ff ff       	call   f0102f15 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010348d:	83 c4 10             	add    $0x10,%esp
f0103490:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103494:	74 25                	je     f01034bb <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103496:	83 ec 08             	sub    $0x8,%esp
f0103499:	ff 73 3c             	pushl  0x3c(%ebx)
f010349c:	68 8a 59 10 f0       	push   $0xf010598a
f01034a1:	e8 6f fa ff ff       	call   f0102f15 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01034a6:	83 c4 08             	add    $0x8,%esp
f01034a9:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01034ad:	50                   	push   %eax
f01034ae:	68 99 59 10 f0       	push   $0xf0105999
f01034b3:	e8 5d fa ff ff       	call   f0102f15 <cprintf>
f01034b8:	83 c4 10             	add    $0x10,%esp
	}
}
f01034bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01034be:	5b                   	pop    %ebx
f01034bf:	5e                   	pop    %esi
f01034c0:	5d                   	pop    %ebp
f01034c1:	c3                   	ret    

f01034c2 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01034c2:	55                   	push   %ebp
f01034c3:	89 e5                	mov    %esp,%ebp
f01034c5:	53                   	push   %ebx
f01034c6:	83 ec 04             	sub    $0x4,%esp
f01034c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01034cc:	0f 20 d0             	mov    %cr2,%eax

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	if((tf->tf_cs & 3)==0)
f01034cf:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01034d3:	75 17                	jne    f01034ec <page_fault_handler+0x2a>
	    panic("page fault kernel mode");
f01034d5:	83 ec 04             	sub    $0x4,%esp
f01034d8:	68 ac 59 10 f0       	push   $0xf01059ac
f01034dd:	68 1d 01 00 00       	push   $0x11d
f01034e2:	68 c3 59 10 f0       	push   $0xf01059c3
f01034e7:	e8 b4 cb ff ff       	call   f01000a0 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01034ec:	ff 73 30             	pushl  0x30(%ebx)
f01034ef:	50                   	push   %eax
f01034f0:	a1 44 ce 17 f0       	mov    0xf017ce44,%eax
f01034f5:	ff 70 48             	pushl  0x48(%eax)
f01034f8:	68 68 5b 10 f0       	push   $0xf0105b68
f01034fd:	e8 13 fa ff ff       	call   f0102f15 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103502:	89 1c 24             	mov    %ebx,(%esp)
f0103505:	e8 45 fe ff ff       	call   f010334f <print_trapframe>
	env_destroy(curenv);
f010350a:	83 c4 04             	add    $0x4,%esp
f010350d:	ff 35 44 ce 17 f0    	pushl  0xf017ce44
f0103513:	e8 d9 f8 ff ff       	call   f0102df1 <env_destroy>
}
f0103518:	83 c4 10             	add    $0x10,%esp
f010351b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010351e:	c9                   	leave  
f010351f:	c3                   	ret    

f0103520 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103520:	55                   	push   %ebp
f0103521:	89 e5                	mov    %esp,%ebp
f0103523:	57                   	push   %edi
f0103524:	56                   	push   %esi
f0103525:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103528:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103529:	9c                   	pushf  
f010352a:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010352b:	f6 c4 02             	test   $0x2,%ah
f010352e:	74 19                	je     f0103549 <trap+0x29>
f0103530:	68 cf 59 10 f0       	push   $0xf01059cf
f0103535:	68 ba 4c 10 f0       	push   $0xf0104cba
f010353a:	68 f6 00 00 00       	push   $0xf6
f010353f:	68 c3 59 10 f0       	push   $0xf01059c3
f0103544:	e8 57 cb ff ff       	call   f01000a0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103549:	83 ec 08             	sub    $0x8,%esp
f010354c:	56                   	push   %esi
f010354d:	68 e8 59 10 f0       	push   $0xf01059e8
f0103552:	e8 be f9 ff ff       	call   f0102f15 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103557:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010355b:	83 e0 03             	and    $0x3,%eax
f010355e:	83 c4 10             	add    $0x10,%esp
f0103561:	66 83 f8 03          	cmp    $0x3,%ax
f0103565:	75 31                	jne    f0103598 <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f0103567:	a1 44 ce 17 f0       	mov    0xf017ce44,%eax
f010356c:	85 c0                	test   %eax,%eax
f010356e:	75 19                	jne    f0103589 <trap+0x69>
f0103570:	68 03 5a 10 f0       	push   $0xf0105a03
f0103575:	68 ba 4c 10 f0       	push   $0xf0104cba
f010357a:	68 fc 00 00 00       	push   $0xfc
f010357f:	68 c3 59 10 f0       	push   $0xf01059c3
f0103584:	e8 17 cb ff ff       	call   f01000a0 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103589:	b9 11 00 00 00       	mov    $0x11,%ecx
f010358e:	89 c7                	mov    %eax,%edi
f0103590:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103592:	8b 35 44 ce 17 f0    	mov    0xf017ce44,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103598:	89 35 60 d6 17 f0    	mov    %esi,0xf017d660
{
	int rval=0;
		//cprintf("error interruot %x\n", tf->tf_err);
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno==14)
f010359e:	8b 46 28             	mov    0x28(%esi),%eax
f01035a1:	83 f8 0e             	cmp    $0xe,%eax
f01035a4:	75 0e                	jne    f01035b4 <trap+0x94>
       {
        page_fault_handler(tf);
f01035a6:	83 ec 0c             	sub    $0xc,%esp
f01035a9:	56                   	push   %esi
f01035aa:	e8 13 ff ff ff       	call   f01034c2 <page_fault_handler>
f01035af:	83 c4 10             	add    $0x10,%esp
f01035b2:	eb 74                	jmp    f0103628 <trap+0x108>
        return;
	}
	
	if(tf->tf_trapno==3)
f01035b4:	83 f8 03             	cmp    $0x3,%eax
f01035b7:	75 0e                	jne    f01035c7 <trap+0xa7>
	{
	monitor(tf);
f01035b9:	83 ec 0c             	sub    $0xc,%esp
f01035bc:	56                   	push   %esi
f01035bd:	e8 ea d1 ff ff       	call   f01007ac <monitor>
f01035c2:	83 c4 10             	add    $0x10,%esp
f01035c5:	eb 61                	jmp    f0103628 <trap+0x108>
	return;	
		
	}
	
	if(tf->tf_trapno==T_SYSCALL)
f01035c7:	83 f8 30             	cmp    $0x30,%eax
f01035ca:	75 21                	jne    f01035ed <trap+0xcd>
	{
	rval= syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,tf->tf_regs.reg_esi);
f01035cc:	83 ec 08             	sub    $0x8,%esp
f01035cf:	ff 76 04             	pushl  0x4(%esi)
f01035d2:	ff 36                	pushl  (%esi)
f01035d4:	ff 76 10             	pushl  0x10(%esi)
f01035d7:	ff 76 18             	pushl  0x18(%esi)
f01035da:	ff 76 14             	pushl  0x14(%esi)
f01035dd:	ff 76 1c             	pushl  0x1c(%esi)
f01035e0:	e8 ea 00 00 00       	call   f01036cf <syscall>
	tf->tf_regs.reg_eax = rval;
f01035e5:	89 46 1c             	mov    %eax,0x1c(%esi)
f01035e8:	83 c4 20             	add    $0x20,%esp
f01035eb:	eb 3b                	jmp    f0103628 <trap+0x108>
	}

        
        
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01035ed:	83 ec 0c             	sub    $0xc,%esp
f01035f0:	56                   	push   %esi
f01035f1:	e8 59 fd ff ff       	call   f010334f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01035f6:	83 c4 10             	add    $0x10,%esp
f01035f9:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01035fe:	75 17                	jne    f0103617 <trap+0xf7>
		panic("unhandled trap in kernel");
f0103600:	83 ec 04             	sub    $0x4,%esp
f0103603:	68 0a 5a 10 f0       	push   $0xf0105a0a
f0103608:	68 e5 00 00 00       	push   $0xe5
f010360d:	68 c3 59 10 f0       	push   $0xf01059c3
f0103612:	e8 89 ca ff ff       	call   f01000a0 <_panic>
	else {
		env_destroy(curenv);
f0103617:	83 ec 0c             	sub    $0xc,%esp
f010361a:	ff 35 44 ce 17 f0    	pushl  0xf017ce44
f0103620:	e8 cc f7 ff ff       	call   f0102df1 <env_destroy>
f0103625:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103628:	a1 44 ce 17 f0       	mov    0xf017ce44,%eax
f010362d:	85 c0                	test   %eax,%eax
f010362f:	74 06                	je     f0103637 <trap+0x117>
f0103631:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103635:	74 19                	je     f0103650 <trap+0x130>
f0103637:	68 8c 5b 10 f0       	push   $0xf0105b8c
f010363c:	68 ba 4c 10 f0       	push   $0xf0104cba
f0103641:	68 0e 01 00 00       	push   $0x10e
f0103646:	68 c3 59 10 f0       	push   $0xf01059c3
f010364b:	e8 50 ca ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f0103650:	83 ec 0c             	sub    $0xc,%esp
f0103653:	50                   	push   %eax
f0103654:	e8 e8 f7 ff ff       	call   f0102e41 <env_run>
f0103659:	90                   	nop

f010365a <divide_zero>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(divide_zero,T_DIVIDE)
f010365a:	6a 00                	push   $0x0
f010365c:	6a 00                	push   $0x0
f010365e:	eb 5e                	jmp    f01036be <_alltraps>

f0103660 <brkpoint>:
TRAPHANDLER_NOEC(brkpoint,T_BRKPT)
f0103660:	6a 00                	push   $0x0
f0103662:	6a 03                	push   $0x3
f0103664:	eb 58                	jmp    f01036be <_alltraps>

f0103666 <no_seg>:
TRAPHANDLER(no_seg,T_SEGNP)
f0103666:	6a 0b                	push   $0xb
f0103668:	eb 54                	jmp    f01036be <_alltraps>

f010366a <debug>:
TRAPHANDLER_NOEC(debug,T_DEBUG)
f010366a:	6a 00                	push   $0x0
f010366c:	6a 01                	push   $0x1
f010366e:	eb 4e                	jmp    f01036be <_alltraps>

f0103670 <nmi>:
TRAPHANDLER_NOEC(nmi,T_NMI)
f0103670:	6a 00                	push   $0x0
f0103672:	6a 02                	push   $0x2
f0103674:	eb 48                	jmp    f01036be <_alltraps>

f0103676 <oflow>:
TRAPHANDLER_NOEC(oflow,T_OFLOW)
f0103676:	6a 00                	push   $0x0
f0103678:	6a 04                	push   $0x4
f010367a:	eb 42                	jmp    f01036be <_alltraps>

f010367c <bound>:
TRAPHANDLER_NOEC(bound,T_BOUND)
f010367c:	6a 00                	push   $0x0
f010367e:	6a 05                	push   $0x5
f0103680:	eb 3c                	jmp    f01036be <_alltraps>

f0103682 <illop>:
TRAPHANDLER_NOEC(illop,T_ILLOP)
f0103682:	6a 00                	push   $0x0
f0103684:	6a 06                	push   $0x6
f0103686:	eb 36                	jmp    f01036be <_alltraps>

f0103688 <device>:
TRAPHANDLER_NOEC(device,T_DEVICE)
f0103688:	6a 00                	push   $0x0
f010368a:	6a 07                	push   $0x7
f010368c:	eb 30                	jmp    f01036be <_alltraps>

f010368e <dblflt>:
TRAPHANDLER(dblflt,T_DBLFLT)
f010368e:	6a 08                	push   $0x8
f0103690:	eb 2c                	jmp    f01036be <_alltraps>

f0103692 <tss>:
TRAPHANDLER(tss, T_TSS)
f0103692:	6a 0a                	push   $0xa
f0103694:	eb 28                	jmp    f01036be <_alltraps>

f0103696 <stack>:

TRAPHANDLER(stack, T_STACK)
f0103696:	6a 0c                	push   $0xc
f0103698:	eb 24                	jmp    f01036be <_alltraps>

f010369a <gpflt>:
TRAPHANDLER(gpflt, T_GPFLT)
f010369a:	6a 0d                	push   $0xd
f010369c:	eb 20                	jmp    f01036be <_alltraps>

f010369e <pgflt>:
TRAPHANDLER(pgflt, T_PGFLT)
f010369e:	6a 0e                	push   $0xe
f01036a0:	eb 1c                	jmp    f01036be <_alltraps>

f01036a2 <fperr>:

TRAPHANDLER_NOEC(fperr, T_FPERR)
f01036a2:	6a 00                	push   $0x0
f01036a4:	6a 10                	push   $0x10
f01036a6:	eb 16                	jmp    f01036be <_alltraps>

f01036a8 <align>:
TRAPHANDLER(align, T_ALIGN)
f01036a8:	6a 11                	push   $0x11
f01036aa:	eb 12                	jmp    f01036be <_alltraps>

f01036ac <mchk>:
TRAPHANDLER_NOEC(mchk, T_MCHK)
f01036ac:	6a 00                	push   $0x0
f01036ae:	6a 12                	push   $0x12
f01036b0:	eb 0c                	jmp    f01036be <_alltraps>

f01036b2 <simderr>:
TRAPHANDLER_NOEC(simderr, T_SIMDERR)
f01036b2:	6a 00                	push   $0x0
f01036b4:	6a 13                	push   $0x13
f01036b6:	eb 06                	jmp    f01036be <_alltraps>

f01036b8 <syscalls>:



TRAPHANDLER_NOEC(syscalls, T_SYSCALL)
f01036b8:	6a 00                	push   $0x0
f01036ba:	6a 30                	push   $0x30
f01036bc:	eb 00                	jmp    f01036be <_alltraps>

f01036be <_alltraps>:


.globl _alltraps
_alltraps:
	pushl %ds
f01036be:	1e                   	push   %ds
    pushl %es
f01036bf:	06                   	push   %es
	pushal
f01036c0:	60                   	pusha  

	movw $GD_KD, %ax
f01036c1:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f01036c5:	8e d8                	mov    %eax,%ds
	movw %ax, %es 
f01036c7:	8e c0                	mov    %eax,%es

    pushl %esp  /* trap(%esp) */
f01036c9:	54                   	push   %esp
    call trap
f01036ca:	e8 51 fe ff ff       	call   f0103520 <trap>

f01036cf <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01036cf:	55                   	push   %ebp
f01036d0:	89 e5                	mov    %esp,%ebp
f01036d2:	83 ec 18             	sub    $0x18,%esp
f01036d5:	8b 45 08             	mov    0x8(%ebp),%eax
//	SYS_cputs = 0,
//	SYS_cgetc,
//	SYS_getenvid,
//	SYS_env_destroy,al
int rval=0;
	switch(syscallno){
f01036d8:	83 f8 01             	cmp    $0x1,%eax
f01036db:	74 42                	je     f010371f <syscall+0x50>
f01036dd:	83 f8 01             	cmp    $0x1,%eax
f01036e0:	72 0f                	jb     f01036f1 <syscall+0x22>
f01036e2:	83 f8 02             	cmp    $0x2,%eax
f01036e5:	74 3f                	je     f0103726 <syscall+0x57>
f01036e7:	83 f8 03             	cmp    $0x3,%eax
f01036ea:	74 44                	je     f0103730 <syscall+0x61>
f01036ec:	e9 a4 00 00 00       	jmp    f0103795 <syscall+0xc6>
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
    user_mem_assert(curenv, s, len, PTE_U);
f01036f1:	6a 04                	push   $0x4
f01036f3:	ff 75 10             	pushl  0x10(%ebp)
f01036f6:	ff 75 0c             	pushl  0xc(%ebp)
f01036f9:	ff 35 44 ce 17 f0    	pushl  0xf017ce44
f01036ff:	e8 a9 f0 ff ff       	call   f01027ad <user_mem_assert>
	// LAB 3: Your code here.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103704:	83 c4 0c             	add    $0xc,%esp
f0103707:	ff 75 0c             	pushl  0xc(%ebp)
f010370a:	ff 75 10             	pushl  0x10(%ebp)
f010370d:	68 10 5c 10 f0       	push   $0xf0105c10
f0103712:	e8 fe f7 ff ff       	call   f0102f15 <cprintf>
int rval=0;
	switch(syscallno){
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			rval = a2;
			break;
f0103717:	83 c4 10             	add    $0x10,%esp
//	SYS_env_destroy,al
int rval=0;
	switch(syscallno){
		case SYS_cputs:
			sys_cputs((char *)a1, a2);
			rval = a2;
f010371a:	8b 45 10             	mov    0x10(%ebp),%eax
			break;
f010371d:	eb 7b                	jmp    f010379a <syscall+0xcb>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010371f:	e8 9f cd ff ff       	call   f01004c3 <cons_getc>
			sys_cputs((char *)a1, a2);
			rval = a2;
			break;
		case SYS_cgetc:
			rval = sys_cgetc();
			break;
f0103724:	eb 74                	jmp    f010379a <syscall+0xcb>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103726:	a1 44 ce 17 f0       	mov    0xf017ce44,%eax
f010372b:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			rval = sys_cgetc();
			break;
		case SYS_getenvid:
			rval = sys_getenvid();
			break;
f010372e:	eb 6a                	jmp    f010379a <syscall+0xcb>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103730:	83 ec 04             	sub    $0x4,%esp
f0103733:	6a 01                	push   $0x1
f0103735:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103738:	50                   	push   %eax
f0103739:	ff 75 0c             	pushl  0xc(%ebp)
f010373c:	e8 3d f1 ff ff       	call   f010287e <envid2env>
f0103741:	83 c4 10             	add    $0x10,%esp
f0103744:	85 c0                	test   %eax,%eax
f0103746:	78 52                	js     f010379a <syscall+0xcb>
		return r;
	if (e == curenv)
f0103748:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010374b:	8b 15 44 ce 17 f0    	mov    0xf017ce44,%edx
f0103751:	39 d0                	cmp    %edx,%eax
f0103753:	75 15                	jne    f010376a <syscall+0x9b>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103755:	83 ec 08             	sub    $0x8,%esp
f0103758:	ff 70 48             	pushl  0x48(%eax)
f010375b:	68 15 5c 10 f0       	push   $0xf0105c15
f0103760:	e8 b0 f7 ff ff       	call   f0102f15 <cprintf>
f0103765:	83 c4 10             	add    $0x10,%esp
f0103768:	eb 16                	jmp    f0103780 <syscall+0xb1>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010376a:	83 ec 04             	sub    $0x4,%esp
f010376d:	ff 70 48             	pushl  0x48(%eax)
f0103770:	ff 72 48             	pushl  0x48(%edx)
f0103773:	68 30 5c 10 f0       	push   $0xf0105c30
f0103778:	e8 98 f7 ff ff       	call   f0102f15 <cprintf>
f010377d:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103780:	83 ec 0c             	sub    $0xc,%esp
f0103783:	ff 75 f4             	pushl  -0xc(%ebp)
f0103786:	e8 66 f6 ff ff       	call   f0102df1 <env_destroy>
f010378b:	83 c4 10             	add    $0x10,%esp
	return 0;
f010378e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103793:	eb 05                	jmp    f010379a <syscall+0xcb>
			break;
		case SYS_env_destroy:
			rval = sys_env_destroy(a1);
			break;
		default:
			return -E_INVAL; 
f0103795:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	return rval;
}
f010379a:	c9                   	leave  
f010379b:	c3                   	ret    

f010379c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010379c:	55                   	push   %ebp
f010379d:	89 e5                	mov    %esp,%ebp
f010379f:	57                   	push   %edi
f01037a0:	56                   	push   %esi
f01037a1:	53                   	push   %ebx
f01037a2:	83 ec 14             	sub    $0x14,%esp
f01037a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01037a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01037ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01037ae:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01037b1:	8b 1a                	mov    (%edx),%ebx
f01037b3:	8b 01                	mov    (%ecx),%eax
f01037b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01037b8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01037bf:	eb 7f                	jmp    f0103840 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01037c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01037c4:	01 d8                	add    %ebx,%eax
f01037c6:	89 c6                	mov    %eax,%esi
f01037c8:	c1 ee 1f             	shr    $0x1f,%esi
f01037cb:	01 c6                	add    %eax,%esi
f01037cd:	d1 fe                	sar    %esi
f01037cf:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01037d2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01037d5:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01037d8:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01037da:	eb 03                	jmp    f01037df <stab_binsearch+0x43>
			m--;
f01037dc:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01037df:	39 c3                	cmp    %eax,%ebx
f01037e1:	7f 0d                	jg     f01037f0 <stab_binsearch+0x54>
f01037e3:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01037e7:	83 ea 0c             	sub    $0xc,%edx
f01037ea:	39 f9                	cmp    %edi,%ecx
f01037ec:	75 ee                	jne    f01037dc <stab_binsearch+0x40>
f01037ee:	eb 05                	jmp    f01037f5 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01037f0:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01037f3:	eb 4b                	jmp    f0103840 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01037f5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01037f8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01037fb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01037ff:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103802:	76 11                	jbe    f0103815 <stab_binsearch+0x79>
			*region_left = m;
f0103804:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103807:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103809:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010380c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103813:	eb 2b                	jmp    f0103840 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103815:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103818:	73 14                	jae    f010382e <stab_binsearch+0x92>
			*region_right = m - 1;
f010381a:	83 e8 01             	sub    $0x1,%eax
f010381d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103820:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103823:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103825:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010382c:	eb 12                	jmp    f0103840 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010382e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103831:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0103833:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103837:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103839:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103840:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103843:	0f 8e 78 ff ff ff    	jle    f01037c1 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103849:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010384d:	75 0f                	jne    f010385e <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010384f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103852:	8b 00                	mov    (%eax),%eax
f0103854:	83 e8 01             	sub    $0x1,%eax
f0103857:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010385a:	89 06                	mov    %eax,(%esi)
f010385c:	eb 2c                	jmp    f010388a <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010385e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103861:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103863:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103866:	8b 0e                	mov    (%esi),%ecx
f0103868:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010386b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010386e:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103871:	eb 03                	jmp    f0103876 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103873:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103876:	39 c8                	cmp    %ecx,%eax
f0103878:	7e 0b                	jle    f0103885 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010387a:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010387e:	83 ea 0c             	sub    $0xc,%edx
f0103881:	39 df                	cmp    %ebx,%edi
f0103883:	75 ee                	jne    f0103873 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103885:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103888:	89 06                	mov    %eax,(%esi)
	}
}
f010388a:	83 c4 14             	add    $0x14,%esp
f010388d:	5b                   	pop    %ebx
f010388e:	5e                   	pop    %esi
f010388f:	5f                   	pop    %edi
f0103890:	5d                   	pop    %ebp
f0103891:	c3                   	ret    

f0103892 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103892:	55                   	push   %ebp
f0103893:	89 e5                	mov    %esp,%ebp
f0103895:	57                   	push   %edi
f0103896:	56                   	push   %esi
f0103897:	53                   	push   %ebx
f0103898:	83 ec 2c             	sub    $0x2c,%esp
f010389b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010389e:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01038a1:	c7 06 48 5c 10 f0    	movl   $0xf0105c48,(%esi)
	info->eip_line = 0;
f01038a7:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01038ae:	c7 46 08 48 5c 10 f0 	movl   $0xf0105c48,0x8(%esi)
	info->eip_fn_namelen = 9;
f01038b5:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01038bc:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01038bf:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01038c6:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01038cc:	77 73                	ja     f0103941 <debuginfo_eip+0xaf>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		user_mem_check(curenv,usd,sizeof(struct UserStabData),PTE_U|PTE_P);
f01038ce:	6a 05                	push   $0x5
f01038d0:	6a 10                	push   $0x10
f01038d2:	68 00 00 20 00       	push   $0x200000
f01038d7:	ff 35 44 ce 17 f0    	pushl  0xf017ce44
f01038dd:	e8 48 ee ff ff       	call   f010272a <user_mem_check>
		stabs = usd->stabs;
f01038e2:	a1 00 00 20 00       	mov    0x200000,%eax
f01038e7:	89 c1                	mov    %eax,%ecx
f01038e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f01038ec:	8b 1d 04 00 20 00    	mov    0x200004,%ebx
		stabstr = usd->stabstr;
f01038f2:	a1 08 00 20 00       	mov    0x200008,%eax
f01038f7:	89 45 cc             	mov    %eax,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f01038fa:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103900:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if(user_mem_check(curenv,stabs,sizeof(struct Stab),PTE_U|PTE_P))
f0103903:	6a 05                	push   $0x5
f0103905:	6a 0c                	push   $0xc
f0103907:	51                   	push   %ecx
f0103908:	ff 35 44 ce 17 f0    	pushl  0xf017ce44
f010390e:	e8 17 ee ff ff       	call   f010272a <user_mem_check>
f0103913:	83 c4 20             	add    $0x20,%esp
f0103916:	85 c0                	test   %eax,%eax
f0103918:	0f 85 7b 01 00 00    	jne    f0103a99 <debuginfo_eip+0x207>
		return -1;
	
		if(user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U|PTE_P))
f010391e:	6a 05                	push   $0x5
f0103920:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103923:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103926:	29 ca                	sub    %ecx,%edx
f0103928:	52                   	push   %edx
f0103929:	51                   	push   %ecx
f010392a:	ff 35 44 ce 17 f0    	pushl  0xf017ce44
f0103930:	e8 f5 ed ff ff       	call   f010272a <user_mem_check>
f0103935:	83 c4 10             	add    $0x10,%esp
f0103938:	85 c0                	test   %eax,%eax
f010393a:	74 1f                	je     f010395b <debuginfo_eip+0xc9>
f010393c:	e9 5f 01 00 00       	jmp    f0103aa0 <debuginfo_eip+0x20e>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103941:	c7 45 d0 c9 00 11 f0 	movl   $0xf01100c9,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103948:	c7 45 cc 85 d6 10 f0 	movl   $0xf010d685,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010394f:	bb 84 d6 10 f0       	mov    $0xf010d684,%ebx
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103954:	c7 45 d4 60 5e 10 f0 	movl   $0xf0105e60,-0x2c(%ebp)
		
		
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010395b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010395e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0103961:	0f 83 40 01 00 00    	jae    f0103aa7 <debuginfo_eip+0x215>
f0103967:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010396b:	0f 85 3d 01 00 00    	jne    f0103aae <debuginfo_eip+0x21c>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103971:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103978:	2b 5d d4             	sub    -0x2c(%ebp),%ebx
f010397b:	c1 fb 02             	sar    $0x2,%ebx
f010397e:	69 c3 ab aa aa aa    	imul   $0xaaaaaaab,%ebx,%eax
f0103984:	83 e8 01             	sub    $0x1,%eax
f0103987:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010398a:	83 ec 08             	sub    $0x8,%esp
f010398d:	57                   	push   %edi
f010398e:	6a 64                	push   $0x64
f0103990:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103993:	89 d1                	mov    %edx,%ecx
f0103995:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103998:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010399b:	89 d8                	mov    %ebx,%eax
f010399d:	e8 fa fd ff ff       	call   f010379c <stab_binsearch>
	if (lfile == 0)
f01039a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01039a5:	83 c4 10             	add    $0x10,%esp
f01039a8:	85 c0                	test   %eax,%eax
f01039aa:	0f 84 05 01 00 00    	je     f0103ab5 <debuginfo_eip+0x223>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01039b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01039b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01039b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01039b9:	83 ec 08             	sub    $0x8,%esp
f01039bc:	57                   	push   %edi
f01039bd:	6a 24                	push   $0x24
f01039bf:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01039c2:	89 d1                	mov    %edx,%ecx
f01039c4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01039c7:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01039ca:	89 d8                	mov    %ebx,%eax
f01039cc:	e8 cb fd ff ff       	call   f010379c <stab_binsearch>

	if (lfun <= rfun) {
f01039d1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01039d4:	83 c4 10             	add    $0x10,%esp
f01039d7:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f01039da:	7f 24                	jg     f0103a00 <debuginfo_eip+0x16e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01039dc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01039df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01039e2:	8d 14 87             	lea    (%edi,%eax,4),%edx
f01039e5:	8b 02                	mov    (%edx),%eax
f01039e7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01039ea:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01039ed:	29 f9                	sub    %edi,%ecx
f01039ef:	39 c8                	cmp    %ecx,%eax
f01039f1:	73 05                	jae    f01039f8 <debuginfo_eip+0x166>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01039f3:	01 f8                	add    %edi,%eax
f01039f5:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01039f8:	8b 42 08             	mov    0x8(%edx),%eax
f01039fb:	89 46 10             	mov    %eax,0x10(%esi)
f01039fe:	eb 06                	jmp    f0103a06 <debuginfo_eip+0x174>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103a00:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0103a03:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103a06:	83 ec 08             	sub    $0x8,%esp
f0103a09:	6a 3a                	push   $0x3a
f0103a0b:	ff 76 08             	pushl  0x8(%esi)
f0103a0e:	e8 a8 08 00 00       	call   f01042bb <strfind>
f0103a13:	2b 46 08             	sub    0x8(%esi),%eax
f0103a16:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103a1c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103a1f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103a22:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0103a25:	83 c4 10             	add    $0x10,%esp
f0103a28:	eb 06                	jmp    f0103a30 <debuginfo_eip+0x19e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103a2a:	83 eb 01             	sub    $0x1,%ebx
f0103a2d:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a30:	39 fb                	cmp    %edi,%ebx
f0103a32:	7c 2d                	jl     f0103a61 <debuginfo_eip+0x1cf>
	       && stabs[lline].n_type != N_SOL
f0103a34:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0103a38:	80 fa 84             	cmp    $0x84,%dl
f0103a3b:	74 0b                	je     f0103a48 <debuginfo_eip+0x1b6>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103a3d:	80 fa 64             	cmp    $0x64,%dl
f0103a40:	75 e8                	jne    f0103a2a <debuginfo_eip+0x198>
f0103a42:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0103a46:	74 e2                	je     f0103a2a <debuginfo_eip+0x198>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103a48:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103a4b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103a4e:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103a51:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103a54:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103a57:	29 f8                	sub    %edi,%eax
f0103a59:	39 c2                	cmp    %eax,%edx
f0103a5b:	73 04                	jae    f0103a61 <debuginfo_eip+0x1cf>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103a5d:	01 fa                	add    %edi,%edx
f0103a5f:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103a61:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103a64:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103a67:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103a6c:	39 cb                	cmp    %ecx,%ebx
f0103a6e:	7d 51                	jge    f0103ac1 <debuginfo_eip+0x22f>
		for (lline = lfun + 1;
f0103a70:	8d 53 01             	lea    0x1(%ebx),%edx
f0103a73:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103a76:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103a79:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0103a7c:	eb 07                	jmp    f0103a85 <debuginfo_eip+0x1f3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103a7e:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103a82:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103a85:	39 ca                	cmp    %ecx,%edx
f0103a87:	74 33                	je     f0103abc <debuginfo_eip+0x22a>
f0103a89:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103a8c:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0103a90:	74 ec                	je     f0103a7e <debuginfo_eip+0x1ec>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103a92:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a97:	eb 28                	jmp    f0103ac1 <debuginfo_eip+0x22f>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		
		if(user_mem_check(curenv,stabs,sizeof(struct Stab),PTE_U|PTE_P))
		return -1;
f0103a99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a9e:	eb 21                	jmp    f0103ac1 <debuginfo_eip+0x22f>
	
		if(user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U|PTE_P))
		return -1;
f0103aa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103aa5:	eb 1a                	jmp    f0103ac1 <debuginfo_eip+0x22f>
		
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103aa7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103aac:	eb 13                	jmp    f0103ac1 <debuginfo_eip+0x22f>
f0103aae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ab3:	eb 0c                	jmp    f0103ac1 <debuginfo_eip+0x22f>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103aba:	eb 05                	jmp    f0103ac1 <debuginfo_eip+0x22f>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103abc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ac4:	5b                   	pop    %ebx
f0103ac5:	5e                   	pop    %esi
f0103ac6:	5f                   	pop    %edi
f0103ac7:	5d                   	pop    %ebp
f0103ac8:	c3                   	ret    

f0103ac9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103ac9:	55                   	push   %ebp
f0103aca:	89 e5                	mov    %esp,%ebp
f0103acc:	57                   	push   %edi
f0103acd:	56                   	push   %esi
f0103ace:	53                   	push   %ebx
f0103acf:	83 ec 1c             	sub    $0x1c,%esp
f0103ad2:	89 c7                	mov    %eax,%edi
f0103ad4:	89 d6                	mov    %edx,%esi
f0103ad6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ad9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103adc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103adf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103ae2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103ae5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103aea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103aed:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103af0:	39 d3                	cmp    %edx,%ebx
f0103af2:	72 05                	jb     f0103af9 <printnum+0x30>
f0103af4:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103af7:	77 45                	ja     f0103b3e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103af9:	83 ec 0c             	sub    $0xc,%esp
f0103afc:	ff 75 18             	pushl  0x18(%ebp)
f0103aff:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b02:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103b05:	53                   	push   %ebx
f0103b06:	ff 75 10             	pushl  0x10(%ebp)
f0103b09:	83 ec 08             	sub    $0x8,%esp
f0103b0c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103b0f:	ff 75 e0             	pushl  -0x20(%ebp)
f0103b12:	ff 75 dc             	pushl  -0x24(%ebp)
f0103b15:	ff 75 d8             	pushl  -0x28(%ebp)
f0103b18:	e8 c3 09 00 00       	call   f01044e0 <__udivdi3>
f0103b1d:	83 c4 18             	add    $0x18,%esp
f0103b20:	52                   	push   %edx
f0103b21:	50                   	push   %eax
f0103b22:	89 f2                	mov    %esi,%edx
f0103b24:	89 f8                	mov    %edi,%eax
f0103b26:	e8 9e ff ff ff       	call   f0103ac9 <printnum>
f0103b2b:	83 c4 20             	add    $0x20,%esp
f0103b2e:	eb 18                	jmp    f0103b48 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103b30:	83 ec 08             	sub    $0x8,%esp
f0103b33:	56                   	push   %esi
f0103b34:	ff 75 18             	pushl  0x18(%ebp)
f0103b37:	ff d7                	call   *%edi
f0103b39:	83 c4 10             	add    $0x10,%esp
f0103b3c:	eb 03                	jmp    f0103b41 <printnum+0x78>
f0103b3e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103b41:	83 eb 01             	sub    $0x1,%ebx
f0103b44:	85 db                	test   %ebx,%ebx
f0103b46:	7f e8                	jg     f0103b30 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103b48:	83 ec 08             	sub    $0x8,%esp
f0103b4b:	56                   	push   %esi
f0103b4c:	83 ec 04             	sub    $0x4,%esp
f0103b4f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103b52:	ff 75 e0             	pushl  -0x20(%ebp)
f0103b55:	ff 75 dc             	pushl  -0x24(%ebp)
f0103b58:	ff 75 d8             	pushl  -0x28(%ebp)
f0103b5b:	e8 b0 0a 00 00       	call   f0104610 <__umoddi3>
f0103b60:	83 c4 14             	add    $0x14,%esp
f0103b63:	0f be 80 52 5c 10 f0 	movsbl -0xfefa3ae(%eax),%eax
f0103b6a:	50                   	push   %eax
f0103b6b:	ff d7                	call   *%edi
}
f0103b6d:	83 c4 10             	add    $0x10,%esp
f0103b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b73:	5b                   	pop    %ebx
f0103b74:	5e                   	pop    %esi
f0103b75:	5f                   	pop    %edi
f0103b76:	5d                   	pop    %ebp
f0103b77:	c3                   	ret    

f0103b78 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103b78:	55                   	push   %ebp
f0103b79:	89 e5                	mov    %esp,%ebp
f0103b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103b7e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103b82:	8b 10                	mov    (%eax),%edx
f0103b84:	3b 50 04             	cmp    0x4(%eax),%edx
f0103b87:	73 0a                	jae    f0103b93 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103b89:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103b8c:	89 08                	mov    %ecx,(%eax)
f0103b8e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b91:	88 02                	mov    %al,(%edx)
}
f0103b93:	5d                   	pop    %ebp
f0103b94:	c3                   	ret    

f0103b95 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103b95:	55                   	push   %ebp
f0103b96:	89 e5                	mov    %esp,%ebp
f0103b98:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103b9b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103b9e:	50                   	push   %eax
f0103b9f:	ff 75 10             	pushl  0x10(%ebp)
f0103ba2:	ff 75 0c             	pushl  0xc(%ebp)
f0103ba5:	ff 75 08             	pushl  0x8(%ebp)
f0103ba8:	e8 05 00 00 00       	call   f0103bb2 <vprintfmt>
	va_end(ap);
}
f0103bad:	83 c4 10             	add    $0x10,%esp
f0103bb0:	c9                   	leave  
f0103bb1:	c3                   	ret    

f0103bb2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103bb2:	55                   	push   %ebp
f0103bb3:	89 e5                	mov    %esp,%ebp
f0103bb5:	57                   	push   %edi
f0103bb6:	56                   	push   %esi
f0103bb7:	53                   	push   %ebx
f0103bb8:	83 ec 2c             	sub    $0x2c,%esp
f0103bbb:	8b 75 08             	mov    0x8(%ebp),%esi
f0103bbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103bc1:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103bc4:	eb 12                	jmp    f0103bd8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103bc6:	85 c0                	test   %eax,%eax
f0103bc8:	0f 84 42 04 00 00    	je     f0104010 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f0103bce:	83 ec 08             	sub    $0x8,%esp
f0103bd1:	53                   	push   %ebx
f0103bd2:	50                   	push   %eax
f0103bd3:	ff d6                	call   *%esi
f0103bd5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103bd8:	83 c7 01             	add    $0x1,%edi
f0103bdb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103bdf:	83 f8 25             	cmp    $0x25,%eax
f0103be2:	75 e2                	jne    f0103bc6 <vprintfmt+0x14>
f0103be4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103be8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103bef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103bf6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103bfd:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103c02:	eb 07                	jmp    f0103c0b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c04:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103c07:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c0b:	8d 47 01             	lea    0x1(%edi),%eax
f0103c0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103c11:	0f b6 07             	movzbl (%edi),%eax
f0103c14:	0f b6 d0             	movzbl %al,%edx
f0103c17:	83 e8 23             	sub    $0x23,%eax
f0103c1a:	3c 55                	cmp    $0x55,%al
f0103c1c:	0f 87 d3 03 00 00    	ja     f0103ff5 <vprintfmt+0x443>
f0103c22:	0f b6 c0             	movzbl %al,%eax
f0103c25:	ff 24 85 dc 5c 10 f0 	jmp    *-0xfefa324(,%eax,4)
f0103c2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103c2f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103c33:	eb d6                	jmp    f0103c0b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c38:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c3d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103c40:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103c43:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103c47:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103c4a:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103c4d:	83 f9 09             	cmp    $0x9,%ecx
f0103c50:	77 3f                	ja     f0103c91 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103c52:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103c55:	eb e9                	jmp    f0103c40 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103c57:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c5a:	8b 00                	mov    (%eax),%eax
f0103c5c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103c5f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c62:	8d 40 04             	lea    0x4(%eax),%eax
f0103c65:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103c6b:	eb 2a                	jmp    f0103c97 <vprintfmt+0xe5>
f0103c6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c70:	85 c0                	test   %eax,%eax
f0103c72:	ba 00 00 00 00       	mov    $0x0,%edx
f0103c77:	0f 49 d0             	cmovns %eax,%edx
f0103c7a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c80:	eb 89                	jmp    f0103c0b <vprintfmt+0x59>
f0103c82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103c85:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103c8c:	e9 7a ff ff ff       	jmp    f0103c0b <vprintfmt+0x59>
f0103c91:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103c94:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103c97:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103c9b:	0f 89 6a ff ff ff    	jns    f0103c0b <vprintfmt+0x59>
				width = precision, precision = -1;
f0103ca1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103ca4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103ca7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103cae:	e9 58 ff ff ff       	jmp    f0103c0b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103cb3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cb6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103cb9:	e9 4d ff ff ff       	jmp    f0103c0b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103cbe:	8b 45 14             	mov    0x14(%ebp),%eax
f0103cc1:	8d 78 04             	lea    0x4(%eax),%edi
f0103cc4:	83 ec 08             	sub    $0x8,%esp
f0103cc7:	53                   	push   %ebx
f0103cc8:	ff 30                	pushl  (%eax)
f0103cca:	ff d6                	call   *%esi
			break;
f0103ccc:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103ccf:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cd2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103cd5:	e9 fe fe ff ff       	jmp    f0103bd8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103cda:	8b 45 14             	mov    0x14(%ebp),%eax
f0103cdd:	8d 78 04             	lea    0x4(%eax),%edi
f0103ce0:	8b 00                	mov    (%eax),%eax
f0103ce2:	99                   	cltd   
f0103ce3:	31 d0                	xor    %edx,%eax
f0103ce5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103ce7:	83 f8 06             	cmp    $0x6,%eax
f0103cea:	7f 0b                	jg     f0103cf7 <vprintfmt+0x145>
f0103cec:	8b 14 85 34 5e 10 f0 	mov    -0xfefa1cc(,%eax,4),%edx
f0103cf3:	85 d2                	test   %edx,%edx
f0103cf5:	75 1b                	jne    f0103d12 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0103cf7:	50                   	push   %eax
f0103cf8:	68 6a 5c 10 f0       	push   $0xf0105c6a
f0103cfd:	53                   	push   %ebx
f0103cfe:	56                   	push   %esi
f0103cff:	e8 91 fe ff ff       	call   f0103b95 <printfmt>
f0103d04:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103d07:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d0a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103d0d:	e9 c6 fe ff ff       	jmp    f0103bd8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103d12:	52                   	push   %edx
f0103d13:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0103d18:	53                   	push   %ebx
f0103d19:	56                   	push   %esi
f0103d1a:	e8 76 fe ff ff       	call   f0103b95 <printfmt>
f0103d1f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103d22:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103d28:	e9 ab fe ff ff       	jmp    f0103bd8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103d2d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d30:	83 c0 04             	add    $0x4,%eax
f0103d33:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103d36:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d39:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103d3b:	85 ff                	test   %edi,%edi
f0103d3d:	b8 63 5c 10 f0       	mov    $0xf0105c63,%eax
f0103d42:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103d45:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103d49:	0f 8e 94 00 00 00    	jle    f0103de3 <vprintfmt+0x231>
f0103d4f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103d53:	0f 84 98 00 00 00    	je     f0103df1 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103d59:	83 ec 08             	sub    $0x8,%esp
f0103d5c:	ff 75 d0             	pushl  -0x30(%ebp)
f0103d5f:	57                   	push   %edi
f0103d60:	e8 0c 04 00 00       	call   f0104171 <strnlen>
f0103d65:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103d68:	29 c1                	sub    %eax,%ecx
f0103d6a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103d6d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103d70:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103d74:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103d77:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103d7a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103d7c:	eb 0f                	jmp    f0103d8d <vprintfmt+0x1db>
					putch(padc, putdat);
f0103d7e:	83 ec 08             	sub    $0x8,%esp
f0103d81:	53                   	push   %ebx
f0103d82:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d85:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103d87:	83 ef 01             	sub    $0x1,%edi
f0103d8a:	83 c4 10             	add    $0x10,%esp
f0103d8d:	85 ff                	test   %edi,%edi
f0103d8f:	7f ed                	jg     f0103d7e <vprintfmt+0x1cc>
f0103d91:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103d94:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103d97:	85 c9                	test   %ecx,%ecx
f0103d99:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d9e:	0f 49 c1             	cmovns %ecx,%eax
f0103da1:	29 c1                	sub    %eax,%ecx
f0103da3:	89 75 08             	mov    %esi,0x8(%ebp)
f0103da6:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103da9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103dac:	89 cb                	mov    %ecx,%ebx
f0103dae:	eb 4d                	jmp    f0103dfd <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103db0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103db4:	74 1b                	je     f0103dd1 <vprintfmt+0x21f>
f0103db6:	0f be c0             	movsbl %al,%eax
f0103db9:	83 e8 20             	sub    $0x20,%eax
f0103dbc:	83 f8 5e             	cmp    $0x5e,%eax
f0103dbf:	76 10                	jbe    f0103dd1 <vprintfmt+0x21f>
					putch('?', putdat);
f0103dc1:	83 ec 08             	sub    $0x8,%esp
f0103dc4:	ff 75 0c             	pushl  0xc(%ebp)
f0103dc7:	6a 3f                	push   $0x3f
f0103dc9:	ff 55 08             	call   *0x8(%ebp)
f0103dcc:	83 c4 10             	add    $0x10,%esp
f0103dcf:	eb 0d                	jmp    f0103dde <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0103dd1:	83 ec 08             	sub    $0x8,%esp
f0103dd4:	ff 75 0c             	pushl  0xc(%ebp)
f0103dd7:	52                   	push   %edx
f0103dd8:	ff 55 08             	call   *0x8(%ebp)
f0103ddb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103dde:	83 eb 01             	sub    $0x1,%ebx
f0103de1:	eb 1a                	jmp    f0103dfd <vprintfmt+0x24b>
f0103de3:	89 75 08             	mov    %esi,0x8(%ebp)
f0103de6:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103de9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103dec:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103def:	eb 0c                	jmp    f0103dfd <vprintfmt+0x24b>
f0103df1:	89 75 08             	mov    %esi,0x8(%ebp)
f0103df4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103df7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103dfa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103dfd:	83 c7 01             	add    $0x1,%edi
f0103e00:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103e04:	0f be d0             	movsbl %al,%edx
f0103e07:	85 d2                	test   %edx,%edx
f0103e09:	74 23                	je     f0103e2e <vprintfmt+0x27c>
f0103e0b:	85 f6                	test   %esi,%esi
f0103e0d:	78 a1                	js     f0103db0 <vprintfmt+0x1fe>
f0103e0f:	83 ee 01             	sub    $0x1,%esi
f0103e12:	79 9c                	jns    f0103db0 <vprintfmt+0x1fe>
f0103e14:	89 df                	mov    %ebx,%edi
f0103e16:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e1c:	eb 18                	jmp    f0103e36 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103e1e:	83 ec 08             	sub    $0x8,%esp
f0103e21:	53                   	push   %ebx
f0103e22:	6a 20                	push   $0x20
f0103e24:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103e26:	83 ef 01             	sub    $0x1,%edi
f0103e29:	83 c4 10             	add    $0x10,%esp
f0103e2c:	eb 08                	jmp    f0103e36 <vprintfmt+0x284>
f0103e2e:	89 df                	mov    %ebx,%edi
f0103e30:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103e36:	85 ff                	test   %edi,%edi
f0103e38:	7f e4                	jg     f0103e1e <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103e3a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103e3d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e43:	e9 90 fd ff ff       	jmp    f0103bd8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103e48:	83 f9 01             	cmp    $0x1,%ecx
f0103e4b:	7e 19                	jle    f0103e66 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0103e4d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e50:	8b 50 04             	mov    0x4(%eax),%edx
f0103e53:	8b 00                	mov    (%eax),%eax
f0103e55:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e58:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103e5b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e5e:	8d 40 08             	lea    0x8(%eax),%eax
f0103e61:	89 45 14             	mov    %eax,0x14(%ebp)
f0103e64:	eb 38                	jmp    f0103e9e <vprintfmt+0x2ec>
	else if (lflag)
f0103e66:	85 c9                	test   %ecx,%ecx
f0103e68:	74 1b                	je     f0103e85 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0103e6a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e6d:	8b 00                	mov    (%eax),%eax
f0103e6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e72:	89 c1                	mov    %eax,%ecx
f0103e74:	c1 f9 1f             	sar    $0x1f,%ecx
f0103e77:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103e7a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e7d:	8d 40 04             	lea    0x4(%eax),%eax
f0103e80:	89 45 14             	mov    %eax,0x14(%ebp)
f0103e83:	eb 19                	jmp    f0103e9e <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0103e85:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e88:	8b 00                	mov    (%eax),%eax
f0103e8a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e8d:	89 c1                	mov    %eax,%ecx
f0103e8f:	c1 f9 1f             	sar    $0x1f,%ecx
f0103e92:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103e95:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e98:	8d 40 04             	lea    0x4(%eax),%eax
f0103e9b:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103e9e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103ea1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103ea4:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103ea9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103ead:	0f 89 0e 01 00 00    	jns    f0103fc1 <vprintfmt+0x40f>
				putch('-', putdat);
f0103eb3:	83 ec 08             	sub    $0x8,%esp
f0103eb6:	53                   	push   %ebx
f0103eb7:	6a 2d                	push   $0x2d
f0103eb9:	ff d6                	call   *%esi
				num = -(long long) num;
f0103ebb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103ebe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103ec1:	f7 da                	neg    %edx
f0103ec3:	83 d1 00             	adc    $0x0,%ecx
f0103ec6:	f7 d9                	neg    %ecx
f0103ec8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103ecb:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ed0:	e9 ec 00 00 00       	jmp    f0103fc1 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103ed5:	83 f9 01             	cmp    $0x1,%ecx
f0103ed8:	7e 18                	jle    f0103ef2 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0103eda:	8b 45 14             	mov    0x14(%ebp),%eax
f0103edd:	8b 10                	mov    (%eax),%edx
f0103edf:	8b 48 04             	mov    0x4(%eax),%ecx
f0103ee2:	8d 40 08             	lea    0x8(%eax),%eax
f0103ee5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103ee8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103eed:	e9 cf 00 00 00       	jmp    f0103fc1 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0103ef2:	85 c9                	test   %ecx,%ecx
f0103ef4:	74 1a                	je     f0103f10 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0103ef6:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ef9:	8b 10                	mov    (%eax),%edx
f0103efb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103f00:	8d 40 04             	lea    0x4(%eax),%eax
f0103f03:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103f06:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f0b:	e9 b1 00 00 00       	jmp    f0103fc1 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0103f10:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f13:	8b 10                	mov    (%eax),%edx
f0103f15:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103f1a:	8d 40 04             	lea    0x4(%eax),%eax
f0103f1d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103f20:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103f25:	e9 97 00 00 00       	jmp    f0103fc1 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0103f2a:	83 ec 08             	sub    $0x8,%esp
f0103f2d:	53                   	push   %ebx
f0103f2e:	6a 58                	push   $0x58
f0103f30:	ff d6                	call   *%esi
			putch('X', putdat);
f0103f32:	83 c4 08             	add    $0x8,%esp
f0103f35:	53                   	push   %ebx
f0103f36:	6a 58                	push   $0x58
f0103f38:	ff d6                	call   *%esi
			putch('X', putdat);
f0103f3a:	83 c4 08             	add    $0x8,%esp
f0103f3d:	53                   	push   %ebx
f0103f3e:	6a 58                	push   $0x58
f0103f40:	ff d6                	call   *%esi
			break;
f0103f42:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0103f48:	e9 8b fc ff ff       	jmp    f0103bd8 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0103f4d:	83 ec 08             	sub    $0x8,%esp
f0103f50:	53                   	push   %ebx
f0103f51:	6a 30                	push   $0x30
f0103f53:	ff d6                	call   *%esi
			putch('x', putdat);
f0103f55:	83 c4 08             	add    $0x8,%esp
f0103f58:	53                   	push   %ebx
f0103f59:	6a 78                	push   $0x78
f0103f5b:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103f5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f60:	8b 10                	mov    (%eax),%edx
f0103f62:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103f67:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103f6a:	8d 40 04             	lea    0x4(%eax),%eax
f0103f6d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103f70:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103f75:	eb 4a                	jmp    f0103fc1 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103f77:	83 f9 01             	cmp    $0x1,%ecx
f0103f7a:	7e 15                	jle    f0103f91 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0103f7c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f7f:	8b 10                	mov    (%eax),%edx
f0103f81:	8b 48 04             	mov    0x4(%eax),%ecx
f0103f84:	8d 40 08             	lea    0x8(%eax),%eax
f0103f87:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0103f8a:	b8 10 00 00 00       	mov    $0x10,%eax
f0103f8f:	eb 30                	jmp    f0103fc1 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0103f91:	85 c9                	test   %ecx,%ecx
f0103f93:	74 17                	je     f0103fac <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f0103f95:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f98:	8b 10                	mov    (%eax),%edx
f0103f9a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103f9f:	8d 40 04             	lea    0x4(%eax),%eax
f0103fa2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0103fa5:	b8 10 00 00 00       	mov    $0x10,%eax
f0103faa:	eb 15                	jmp    f0103fc1 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0103fac:	8b 45 14             	mov    0x14(%ebp),%eax
f0103faf:	8b 10                	mov    (%eax),%edx
f0103fb1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103fb6:	8d 40 04             	lea    0x4(%eax),%eax
f0103fb9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0103fbc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103fc1:	83 ec 0c             	sub    $0xc,%esp
f0103fc4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103fc8:	57                   	push   %edi
f0103fc9:	ff 75 e0             	pushl  -0x20(%ebp)
f0103fcc:	50                   	push   %eax
f0103fcd:	51                   	push   %ecx
f0103fce:	52                   	push   %edx
f0103fcf:	89 da                	mov    %ebx,%edx
f0103fd1:	89 f0                	mov    %esi,%eax
f0103fd3:	e8 f1 fa ff ff       	call   f0103ac9 <printnum>
			break;
f0103fd8:	83 c4 20             	add    $0x20,%esp
f0103fdb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103fde:	e9 f5 fb ff ff       	jmp    f0103bd8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103fe3:	83 ec 08             	sub    $0x8,%esp
f0103fe6:	53                   	push   %ebx
f0103fe7:	52                   	push   %edx
f0103fe8:	ff d6                	call   *%esi
			break;
f0103fea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103fed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103ff0:	e9 e3 fb ff ff       	jmp    f0103bd8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103ff5:	83 ec 08             	sub    $0x8,%esp
f0103ff8:	53                   	push   %ebx
f0103ff9:	6a 25                	push   $0x25
f0103ffb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103ffd:	83 c4 10             	add    $0x10,%esp
f0104000:	eb 03                	jmp    f0104005 <vprintfmt+0x453>
f0104002:	83 ef 01             	sub    $0x1,%edi
f0104005:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104009:	75 f7                	jne    f0104002 <vprintfmt+0x450>
f010400b:	e9 c8 fb ff ff       	jmp    f0103bd8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104010:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104013:	5b                   	pop    %ebx
f0104014:	5e                   	pop    %esi
f0104015:	5f                   	pop    %edi
f0104016:	5d                   	pop    %ebp
f0104017:	c3                   	ret    

f0104018 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104018:	55                   	push   %ebp
f0104019:	89 e5                	mov    %esp,%ebp
f010401b:	83 ec 18             	sub    $0x18,%esp
f010401e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104021:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104024:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104027:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010402b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010402e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104035:	85 c0                	test   %eax,%eax
f0104037:	74 26                	je     f010405f <vsnprintf+0x47>
f0104039:	85 d2                	test   %edx,%edx
f010403b:	7e 22                	jle    f010405f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010403d:	ff 75 14             	pushl  0x14(%ebp)
f0104040:	ff 75 10             	pushl  0x10(%ebp)
f0104043:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104046:	50                   	push   %eax
f0104047:	68 78 3b 10 f0       	push   $0xf0103b78
f010404c:	e8 61 fb ff ff       	call   f0103bb2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104051:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104054:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104057:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010405a:	83 c4 10             	add    $0x10,%esp
f010405d:	eb 05                	jmp    f0104064 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010405f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104064:	c9                   	leave  
f0104065:	c3                   	ret    

f0104066 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104066:	55                   	push   %ebp
f0104067:	89 e5                	mov    %esp,%ebp
f0104069:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010406c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010406f:	50                   	push   %eax
f0104070:	ff 75 10             	pushl  0x10(%ebp)
f0104073:	ff 75 0c             	pushl  0xc(%ebp)
f0104076:	ff 75 08             	pushl  0x8(%ebp)
f0104079:	e8 9a ff ff ff       	call   f0104018 <vsnprintf>
	va_end(ap);

	return rc;
}
f010407e:	c9                   	leave  
f010407f:	c3                   	ret    

f0104080 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104080:	55                   	push   %ebp
f0104081:	89 e5                	mov    %esp,%ebp
f0104083:	57                   	push   %edi
f0104084:	56                   	push   %esi
f0104085:	53                   	push   %ebx
f0104086:	83 ec 0c             	sub    $0xc,%esp
f0104089:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010408c:	85 c0                	test   %eax,%eax
f010408e:	74 11                	je     f01040a1 <readline+0x21>
		cprintf("%s", prompt);
f0104090:	83 ec 08             	sub    $0x8,%esp
f0104093:	50                   	push   %eax
f0104094:	68 cc 4c 10 f0       	push   $0xf0104ccc
f0104099:	e8 77 ee ff ff       	call   f0102f15 <cprintf>
f010409e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01040a1:	83 ec 0c             	sub    $0xc,%esp
f01040a4:	6a 00                	push   $0x0
f01040a6:	e8 8b c5 ff ff       	call   f0100636 <iscons>
f01040ab:	89 c7                	mov    %eax,%edi
f01040ad:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01040b0:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01040b5:	e8 6b c5 ff ff       	call   f0100625 <getchar>
f01040ba:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01040bc:	85 c0                	test   %eax,%eax
f01040be:	79 18                	jns    f01040d8 <readline+0x58>
			cprintf("read error: %e\n", c);
f01040c0:	83 ec 08             	sub    $0x8,%esp
f01040c3:	50                   	push   %eax
f01040c4:	68 50 5e 10 f0       	push   $0xf0105e50
f01040c9:	e8 47 ee ff ff       	call   f0102f15 <cprintf>
			return NULL;
f01040ce:	83 c4 10             	add    $0x10,%esp
f01040d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01040d6:	eb 79                	jmp    f0104151 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01040d8:	83 f8 08             	cmp    $0x8,%eax
f01040db:	0f 94 c2             	sete   %dl
f01040de:	83 f8 7f             	cmp    $0x7f,%eax
f01040e1:	0f 94 c0             	sete   %al
f01040e4:	08 c2                	or     %al,%dl
f01040e6:	74 1a                	je     f0104102 <readline+0x82>
f01040e8:	85 f6                	test   %esi,%esi
f01040ea:	7e 16                	jle    f0104102 <readline+0x82>
			if (echoing)
f01040ec:	85 ff                	test   %edi,%edi
f01040ee:	74 0d                	je     f01040fd <readline+0x7d>
				cputchar('\b');
f01040f0:	83 ec 0c             	sub    $0xc,%esp
f01040f3:	6a 08                	push   $0x8
f01040f5:	e8 1b c5 ff ff       	call   f0100615 <cputchar>
f01040fa:	83 c4 10             	add    $0x10,%esp
			i--;
f01040fd:	83 ee 01             	sub    $0x1,%esi
f0104100:	eb b3                	jmp    f01040b5 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104102:	83 fb 1f             	cmp    $0x1f,%ebx
f0104105:	7e 23                	jle    f010412a <readline+0xaa>
f0104107:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010410d:	7f 1b                	jg     f010412a <readline+0xaa>
			if (echoing)
f010410f:	85 ff                	test   %edi,%edi
f0104111:	74 0c                	je     f010411f <readline+0x9f>
				cputchar(c);
f0104113:	83 ec 0c             	sub    $0xc,%esp
f0104116:	53                   	push   %ebx
f0104117:	e8 f9 c4 ff ff       	call   f0100615 <cputchar>
f010411c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010411f:	88 9e 00 d7 17 f0    	mov    %bl,-0xfe82900(%esi)
f0104125:	8d 76 01             	lea    0x1(%esi),%esi
f0104128:	eb 8b                	jmp    f01040b5 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010412a:	83 fb 0a             	cmp    $0xa,%ebx
f010412d:	74 05                	je     f0104134 <readline+0xb4>
f010412f:	83 fb 0d             	cmp    $0xd,%ebx
f0104132:	75 81                	jne    f01040b5 <readline+0x35>
			if (echoing)
f0104134:	85 ff                	test   %edi,%edi
f0104136:	74 0d                	je     f0104145 <readline+0xc5>
				cputchar('\n');
f0104138:	83 ec 0c             	sub    $0xc,%esp
f010413b:	6a 0a                	push   $0xa
f010413d:	e8 d3 c4 ff ff       	call   f0100615 <cputchar>
f0104142:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104145:	c6 86 00 d7 17 f0 00 	movb   $0x0,-0xfe82900(%esi)
			return buf;
f010414c:	b8 00 d7 17 f0       	mov    $0xf017d700,%eax
		}
	}
}
f0104151:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104154:	5b                   	pop    %ebx
f0104155:	5e                   	pop    %esi
f0104156:	5f                   	pop    %edi
f0104157:	5d                   	pop    %ebp
f0104158:	c3                   	ret    

f0104159 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104159:	55                   	push   %ebp
f010415a:	89 e5                	mov    %esp,%ebp
f010415c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010415f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104164:	eb 03                	jmp    f0104169 <strlen+0x10>
		n++;
f0104166:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104169:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010416d:	75 f7                	jne    f0104166 <strlen+0xd>
		n++;
	return n;
}
f010416f:	5d                   	pop    %ebp
f0104170:	c3                   	ret    

f0104171 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104171:	55                   	push   %ebp
f0104172:	89 e5                	mov    %esp,%ebp
f0104174:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104177:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010417a:	ba 00 00 00 00       	mov    $0x0,%edx
f010417f:	eb 03                	jmp    f0104184 <strnlen+0x13>
		n++;
f0104181:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104184:	39 c2                	cmp    %eax,%edx
f0104186:	74 08                	je     f0104190 <strnlen+0x1f>
f0104188:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010418c:	75 f3                	jne    f0104181 <strnlen+0x10>
f010418e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104190:	5d                   	pop    %ebp
f0104191:	c3                   	ret    

f0104192 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104192:	55                   	push   %ebp
f0104193:	89 e5                	mov    %esp,%ebp
f0104195:	53                   	push   %ebx
f0104196:	8b 45 08             	mov    0x8(%ebp),%eax
f0104199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010419c:	89 c2                	mov    %eax,%edx
f010419e:	83 c2 01             	add    $0x1,%edx
f01041a1:	83 c1 01             	add    $0x1,%ecx
f01041a4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01041a8:	88 5a ff             	mov    %bl,-0x1(%edx)
f01041ab:	84 db                	test   %bl,%bl
f01041ad:	75 ef                	jne    f010419e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01041af:	5b                   	pop    %ebx
f01041b0:	5d                   	pop    %ebp
f01041b1:	c3                   	ret    

f01041b2 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01041b2:	55                   	push   %ebp
f01041b3:	89 e5                	mov    %esp,%ebp
f01041b5:	53                   	push   %ebx
f01041b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01041b9:	53                   	push   %ebx
f01041ba:	e8 9a ff ff ff       	call   f0104159 <strlen>
f01041bf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01041c2:	ff 75 0c             	pushl  0xc(%ebp)
f01041c5:	01 d8                	add    %ebx,%eax
f01041c7:	50                   	push   %eax
f01041c8:	e8 c5 ff ff ff       	call   f0104192 <strcpy>
	return dst;
}
f01041cd:	89 d8                	mov    %ebx,%eax
f01041cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01041d2:	c9                   	leave  
f01041d3:	c3                   	ret    

f01041d4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01041d4:	55                   	push   %ebp
f01041d5:	89 e5                	mov    %esp,%ebp
f01041d7:	56                   	push   %esi
f01041d8:	53                   	push   %ebx
f01041d9:	8b 75 08             	mov    0x8(%ebp),%esi
f01041dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01041df:	89 f3                	mov    %esi,%ebx
f01041e1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01041e4:	89 f2                	mov    %esi,%edx
f01041e6:	eb 0f                	jmp    f01041f7 <strncpy+0x23>
		*dst++ = *src;
f01041e8:	83 c2 01             	add    $0x1,%edx
f01041eb:	0f b6 01             	movzbl (%ecx),%eax
f01041ee:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01041f1:	80 39 01             	cmpb   $0x1,(%ecx)
f01041f4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01041f7:	39 da                	cmp    %ebx,%edx
f01041f9:	75 ed                	jne    f01041e8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01041fb:	89 f0                	mov    %esi,%eax
f01041fd:	5b                   	pop    %ebx
f01041fe:	5e                   	pop    %esi
f01041ff:	5d                   	pop    %ebp
f0104200:	c3                   	ret    

f0104201 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104201:	55                   	push   %ebp
f0104202:	89 e5                	mov    %esp,%ebp
f0104204:	56                   	push   %esi
f0104205:	53                   	push   %ebx
f0104206:	8b 75 08             	mov    0x8(%ebp),%esi
f0104209:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010420c:	8b 55 10             	mov    0x10(%ebp),%edx
f010420f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104211:	85 d2                	test   %edx,%edx
f0104213:	74 21                	je     f0104236 <strlcpy+0x35>
f0104215:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104219:	89 f2                	mov    %esi,%edx
f010421b:	eb 09                	jmp    f0104226 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010421d:	83 c2 01             	add    $0x1,%edx
f0104220:	83 c1 01             	add    $0x1,%ecx
f0104223:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104226:	39 c2                	cmp    %eax,%edx
f0104228:	74 09                	je     f0104233 <strlcpy+0x32>
f010422a:	0f b6 19             	movzbl (%ecx),%ebx
f010422d:	84 db                	test   %bl,%bl
f010422f:	75 ec                	jne    f010421d <strlcpy+0x1c>
f0104231:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104233:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104236:	29 f0                	sub    %esi,%eax
}
f0104238:	5b                   	pop    %ebx
f0104239:	5e                   	pop    %esi
f010423a:	5d                   	pop    %ebp
f010423b:	c3                   	ret    

f010423c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010423c:	55                   	push   %ebp
f010423d:	89 e5                	mov    %esp,%ebp
f010423f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104242:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104245:	eb 06                	jmp    f010424d <strcmp+0x11>
		p++, q++;
f0104247:	83 c1 01             	add    $0x1,%ecx
f010424a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010424d:	0f b6 01             	movzbl (%ecx),%eax
f0104250:	84 c0                	test   %al,%al
f0104252:	74 04                	je     f0104258 <strcmp+0x1c>
f0104254:	3a 02                	cmp    (%edx),%al
f0104256:	74 ef                	je     f0104247 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104258:	0f b6 c0             	movzbl %al,%eax
f010425b:	0f b6 12             	movzbl (%edx),%edx
f010425e:	29 d0                	sub    %edx,%eax
}
f0104260:	5d                   	pop    %ebp
f0104261:	c3                   	ret    

f0104262 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104262:	55                   	push   %ebp
f0104263:	89 e5                	mov    %esp,%ebp
f0104265:	53                   	push   %ebx
f0104266:	8b 45 08             	mov    0x8(%ebp),%eax
f0104269:	8b 55 0c             	mov    0xc(%ebp),%edx
f010426c:	89 c3                	mov    %eax,%ebx
f010426e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104271:	eb 06                	jmp    f0104279 <strncmp+0x17>
		n--, p++, q++;
f0104273:	83 c0 01             	add    $0x1,%eax
f0104276:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104279:	39 d8                	cmp    %ebx,%eax
f010427b:	74 15                	je     f0104292 <strncmp+0x30>
f010427d:	0f b6 08             	movzbl (%eax),%ecx
f0104280:	84 c9                	test   %cl,%cl
f0104282:	74 04                	je     f0104288 <strncmp+0x26>
f0104284:	3a 0a                	cmp    (%edx),%cl
f0104286:	74 eb                	je     f0104273 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104288:	0f b6 00             	movzbl (%eax),%eax
f010428b:	0f b6 12             	movzbl (%edx),%edx
f010428e:	29 d0                	sub    %edx,%eax
f0104290:	eb 05                	jmp    f0104297 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104292:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104297:	5b                   	pop    %ebx
f0104298:	5d                   	pop    %ebp
f0104299:	c3                   	ret    

f010429a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010429a:	55                   	push   %ebp
f010429b:	89 e5                	mov    %esp,%ebp
f010429d:	8b 45 08             	mov    0x8(%ebp),%eax
f01042a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01042a4:	eb 07                	jmp    f01042ad <strchr+0x13>
		if (*s == c)
f01042a6:	38 ca                	cmp    %cl,%dl
f01042a8:	74 0f                	je     f01042b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01042aa:	83 c0 01             	add    $0x1,%eax
f01042ad:	0f b6 10             	movzbl (%eax),%edx
f01042b0:	84 d2                	test   %dl,%dl
f01042b2:	75 f2                	jne    f01042a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01042b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042b9:	5d                   	pop    %ebp
f01042ba:	c3                   	ret    

f01042bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01042bb:	55                   	push   %ebp
f01042bc:	89 e5                	mov    %esp,%ebp
f01042be:	8b 45 08             	mov    0x8(%ebp),%eax
f01042c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01042c5:	eb 03                	jmp    f01042ca <strfind+0xf>
f01042c7:	83 c0 01             	add    $0x1,%eax
f01042ca:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01042cd:	38 ca                	cmp    %cl,%dl
f01042cf:	74 04                	je     f01042d5 <strfind+0x1a>
f01042d1:	84 d2                	test   %dl,%dl
f01042d3:	75 f2                	jne    f01042c7 <strfind+0xc>
			break;
	return (char *) s;
}
f01042d5:	5d                   	pop    %ebp
f01042d6:	c3                   	ret    

f01042d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01042d7:	55                   	push   %ebp
f01042d8:	89 e5                	mov    %esp,%ebp
f01042da:	57                   	push   %edi
f01042db:	56                   	push   %esi
f01042dc:	53                   	push   %ebx
f01042dd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01042e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01042e3:	85 c9                	test   %ecx,%ecx
f01042e5:	74 36                	je     f010431d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01042e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01042ed:	75 28                	jne    f0104317 <memset+0x40>
f01042ef:	f6 c1 03             	test   $0x3,%cl
f01042f2:	75 23                	jne    f0104317 <memset+0x40>
		c &= 0xFF;
f01042f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01042f8:	89 d3                	mov    %edx,%ebx
f01042fa:	c1 e3 08             	shl    $0x8,%ebx
f01042fd:	89 d6                	mov    %edx,%esi
f01042ff:	c1 e6 18             	shl    $0x18,%esi
f0104302:	89 d0                	mov    %edx,%eax
f0104304:	c1 e0 10             	shl    $0x10,%eax
f0104307:	09 f0                	or     %esi,%eax
f0104309:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010430b:	89 d8                	mov    %ebx,%eax
f010430d:	09 d0                	or     %edx,%eax
f010430f:	c1 e9 02             	shr    $0x2,%ecx
f0104312:	fc                   	cld    
f0104313:	f3 ab                	rep stos %eax,%es:(%edi)
f0104315:	eb 06                	jmp    f010431d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104317:	8b 45 0c             	mov    0xc(%ebp),%eax
f010431a:	fc                   	cld    
f010431b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010431d:	89 f8                	mov    %edi,%eax
f010431f:	5b                   	pop    %ebx
f0104320:	5e                   	pop    %esi
f0104321:	5f                   	pop    %edi
f0104322:	5d                   	pop    %ebp
f0104323:	c3                   	ret    

f0104324 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104324:	55                   	push   %ebp
f0104325:	89 e5                	mov    %esp,%ebp
f0104327:	57                   	push   %edi
f0104328:	56                   	push   %esi
f0104329:	8b 45 08             	mov    0x8(%ebp),%eax
f010432c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010432f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104332:	39 c6                	cmp    %eax,%esi
f0104334:	73 35                	jae    f010436b <memmove+0x47>
f0104336:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104339:	39 d0                	cmp    %edx,%eax
f010433b:	73 2e                	jae    f010436b <memmove+0x47>
		s += n;
		d += n;
f010433d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104340:	89 d6                	mov    %edx,%esi
f0104342:	09 fe                	or     %edi,%esi
f0104344:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010434a:	75 13                	jne    f010435f <memmove+0x3b>
f010434c:	f6 c1 03             	test   $0x3,%cl
f010434f:	75 0e                	jne    f010435f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0104351:	83 ef 04             	sub    $0x4,%edi
f0104354:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104357:	c1 e9 02             	shr    $0x2,%ecx
f010435a:	fd                   	std    
f010435b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010435d:	eb 09                	jmp    f0104368 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010435f:	83 ef 01             	sub    $0x1,%edi
f0104362:	8d 72 ff             	lea    -0x1(%edx),%esi
f0104365:	fd                   	std    
f0104366:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104368:	fc                   	cld    
f0104369:	eb 1d                	jmp    f0104388 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010436b:	89 f2                	mov    %esi,%edx
f010436d:	09 c2                	or     %eax,%edx
f010436f:	f6 c2 03             	test   $0x3,%dl
f0104372:	75 0f                	jne    f0104383 <memmove+0x5f>
f0104374:	f6 c1 03             	test   $0x3,%cl
f0104377:	75 0a                	jne    f0104383 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0104379:	c1 e9 02             	shr    $0x2,%ecx
f010437c:	89 c7                	mov    %eax,%edi
f010437e:	fc                   	cld    
f010437f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104381:	eb 05                	jmp    f0104388 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104383:	89 c7                	mov    %eax,%edi
f0104385:	fc                   	cld    
f0104386:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104388:	5e                   	pop    %esi
f0104389:	5f                   	pop    %edi
f010438a:	5d                   	pop    %ebp
f010438b:	c3                   	ret    

f010438c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010438c:	55                   	push   %ebp
f010438d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010438f:	ff 75 10             	pushl  0x10(%ebp)
f0104392:	ff 75 0c             	pushl  0xc(%ebp)
f0104395:	ff 75 08             	pushl  0x8(%ebp)
f0104398:	e8 87 ff ff ff       	call   f0104324 <memmove>
}
f010439d:	c9                   	leave  
f010439e:	c3                   	ret    

f010439f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010439f:	55                   	push   %ebp
f01043a0:	89 e5                	mov    %esp,%ebp
f01043a2:	56                   	push   %esi
f01043a3:	53                   	push   %ebx
f01043a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01043a7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01043aa:	89 c6                	mov    %eax,%esi
f01043ac:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01043af:	eb 1a                	jmp    f01043cb <memcmp+0x2c>
		if (*s1 != *s2)
f01043b1:	0f b6 08             	movzbl (%eax),%ecx
f01043b4:	0f b6 1a             	movzbl (%edx),%ebx
f01043b7:	38 d9                	cmp    %bl,%cl
f01043b9:	74 0a                	je     f01043c5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01043bb:	0f b6 c1             	movzbl %cl,%eax
f01043be:	0f b6 db             	movzbl %bl,%ebx
f01043c1:	29 d8                	sub    %ebx,%eax
f01043c3:	eb 0f                	jmp    f01043d4 <memcmp+0x35>
		s1++, s2++;
f01043c5:	83 c0 01             	add    $0x1,%eax
f01043c8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01043cb:	39 f0                	cmp    %esi,%eax
f01043cd:	75 e2                	jne    f01043b1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01043cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01043d4:	5b                   	pop    %ebx
f01043d5:	5e                   	pop    %esi
f01043d6:	5d                   	pop    %ebp
f01043d7:	c3                   	ret    

f01043d8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01043d8:	55                   	push   %ebp
f01043d9:	89 e5                	mov    %esp,%ebp
f01043db:	53                   	push   %ebx
f01043dc:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01043df:	89 c1                	mov    %eax,%ecx
f01043e1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01043e4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01043e8:	eb 0a                	jmp    f01043f4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01043ea:	0f b6 10             	movzbl (%eax),%edx
f01043ed:	39 da                	cmp    %ebx,%edx
f01043ef:	74 07                	je     f01043f8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01043f1:	83 c0 01             	add    $0x1,%eax
f01043f4:	39 c8                	cmp    %ecx,%eax
f01043f6:	72 f2                	jb     f01043ea <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01043f8:	5b                   	pop    %ebx
f01043f9:	5d                   	pop    %ebp
f01043fa:	c3                   	ret    

f01043fb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01043fb:	55                   	push   %ebp
f01043fc:	89 e5                	mov    %esp,%ebp
f01043fe:	57                   	push   %edi
f01043ff:	56                   	push   %esi
f0104400:	53                   	push   %ebx
f0104401:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104404:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104407:	eb 03                	jmp    f010440c <strtol+0x11>
		s++;
f0104409:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010440c:	0f b6 01             	movzbl (%ecx),%eax
f010440f:	3c 20                	cmp    $0x20,%al
f0104411:	74 f6                	je     f0104409 <strtol+0xe>
f0104413:	3c 09                	cmp    $0x9,%al
f0104415:	74 f2                	je     f0104409 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104417:	3c 2b                	cmp    $0x2b,%al
f0104419:	75 0a                	jne    f0104425 <strtol+0x2a>
		s++;
f010441b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010441e:	bf 00 00 00 00       	mov    $0x0,%edi
f0104423:	eb 11                	jmp    f0104436 <strtol+0x3b>
f0104425:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010442a:	3c 2d                	cmp    $0x2d,%al
f010442c:	75 08                	jne    f0104436 <strtol+0x3b>
		s++, neg = 1;
f010442e:	83 c1 01             	add    $0x1,%ecx
f0104431:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104436:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010443c:	75 15                	jne    f0104453 <strtol+0x58>
f010443e:	80 39 30             	cmpb   $0x30,(%ecx)
f0104441:	75 10                	jne    f0104453 <strtol+0x58>
f0104443:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104447:	75 7c                	jne    f01044c5 <strtol+0xca>
		s += 2, base = 16;
f0104449:	83 c1 02             	add    $0x2,%ecx
f010444c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104451:	eb 16                	jmp    f0104469 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0104453:	85 db                	test   %ebx,%ebx
f0104455:	75 12                	jne    f0104469 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104457:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010445c:	80 39 30             	cmpb   $0x30,(%ecx)
f010445f:	75 08                	jne    f0104469 <strtol+0x6e>
		s++, base = 8;
f0104461:	83 c1 01             	add    $0x1,%ecx
f0104464:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0104469:	b8 00 00 00 00       	mov    $0x0,%eax
f010446e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104471:	0f b6 11             	movzbl (%ecx),%edx
f0104474:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104477:	89 f3                	mov    %esi,%ebx
f0104479:	80 fb 09             	cmp    $0x9,%bl
f010447c:	77 08                	ja     f0104486 <strtol+0x8b>
			dig = *s - '0';
f010447e:	0f be d2             	movsbl %dl,%edx
f0104481:	83 ea 30             	sub    $0x30,%edx
f0104484:	eb 22                	jmp    f01044a8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0104486:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104489:	89 f3                	mov    %esi,%ebx
f010448b:	80 fb 19             	cmp    $0x19,%bl
f010448e:	77 08                	ja     f0104498 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0104490:	0f be d2             	movsbl %dl,%edx
f0104493:	83 ea 57             	sub    $0x57,%edx
f0104496:	eb 10                	jmp    f01044a8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0104498:	8d 72 bf             	lea    -0x41(%edx),%esi
f010449b:	89 f3                	mov    %esi,%ebx
f010449d:	80 fb 19             	cmp    $0x19,%bl
f01044a0:	77 16                	ja     f01044b8 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01044a2:	0f be d2             	movsbl %dl,%edx
f01044a5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01044a8:	3b 55 10             	cmp    0x10(%ebp),%edx
f01044ab:	7d 0b                	jge    f01044b8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01044ad:	83 c1 01             	add    $0x1,%ecx
f01044b0:	0f af 45 10          	imul   0x10(%ebp),%eax
f01044b4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01044b6:	eb b9                	jmp    f0104471 <strtol+0x76>

	if (endptr)
f01044b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01044bc:	74 0d                	je     f01044cb <strtol+0xd0>
		*endptr = (char *) s;
f01044be:	8b 75 0c             	mov    0xc(%ebp),%esi
f01044c1:	89 0e                	mov    %ecx,(%esi)
f01044c3:	eb 06                	jmp    f01044cb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01044c5:	85 db                	test   %ebx,%ebx
f01044c7:	74 98                	je     f0104461 <strtol+0x66>
f01044c9:	eb 9e                	jmp    f0104469 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01044cb:	89 c2                	mov    %eax,%edx
f01044cd:	f7 da                	neg    %edx
f01044cf:	85 ff                	test   %edi,%edi
f01044d1:	0f 45 c2             	cmovne %edx,%eax
}
f01044d4:	5b                   	pop    %ebx
f01044d5:	5e                   	pop    %esi
f01044d6:	5f                   	pop    %edi
f01044d7:	5d                   	pop    %ebp
f01044d8:	c3                   	ret    
f01044d9:	66 90                	xchg   %ax,%ax
f01044db:	66 90                	xchg   %ax,%ax
f01044dd:	66 90                	xchg   %ax,%ax
f01044df:	90                   	nop

f01044e0 <__udivdi3>:
f01044e0:	55                   	push   %ebp
f01044e1:	57                   	push   %edi
f01044e2:	56                   	push   %esi
f01044e3:	53                   	push   %ebx
f01044e4:	83 ec 1c             	sub    $0x1c,%esp
f01044e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01044eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01044ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01044f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01044f7:	85 f6                	test   %esi,%esi
f01044f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01044fd:	89 ca                	mov    %ecx,%edx
f01044ff:	89 f8                	mov    %edi,%eax
f0104501:	75 3d                	jne    f0104540 <__udivdi3+0x60>
f0104503:	39 cf                	cmp    %ecx,%edi
f0104505:	0f 87 c5 00 00 00    	ja     f01045d0 <__udivdi3+0xf0>
f010450b:	85 ff                	test   %edi,%edi
f010450d:	89 fd                	mov    %edi,%ebp
f010450f:	75 0b                	jne    f010451c <__udivdi3+0x3c>
f0104511:	b8 01 00 00 00       	mov    $0x1,%eax
f0104516:	31 d2                	xor    %edx,%edx
f0104518:	f7 f7                	div    %edi
f010451a:	89 c5                	mov    %eax,%ebp
f010451c:	89 c8                	mov    %ecx,%eax
f010451e:	31 d2                	xor    %edx,%edx
f0104520:	f7 f5                	div    %ebp
f0104522:	89 c1                	mov    %eax,%ecx
f0104524:	89 d8                	mov    %ebx,%eax
f0104526:	89 cf                	mov    %ecx,%edi
f0104528:	f7 f5                	div    %ebp
f010452a:	89 c3                	mov    %eax,%ebx
f010452c:	89 d8                	mov    %ebx,%eax
f010452e:	89 fa                	mov    %edi,%edx
f0104530:	83 c4 1c             	add    $0x1c,%esp
f0104533:	5b                   	pop    %ebx
f0104534:	5e                   	pop    %esi
f0104535:	5f                   	pop    %edi
f0104536:	5d                   	pop    %ebp
f0104537:	c3                   	ret    
f0104538:	90                   	nop
f0104539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104540:	39 ce                	cmp    %ecx,%esi
f0104542:	77 74                	ja     f01045b8 <__udivdi3+0xd8>
f0104544:	0f bd fe             	bsr    %esi,%edi
f0104547:	83 f7 1f             	xor    $0x1f,%edi
f010454a:	0f 84 98 00 00 00    	je     f01045e8 <__udivdi3+0x108>
f0104550:	bb 20 00 00 00       	mov    $0x20,%ebx
f0104555:	89 f9                	mov    %edi,%ecx
f0104557:	89 c5                	mov    %eax,%ebp
f0104559:	29 fb                	sub    %edi,%ebx
f010455b:	d3 e6                	shl    %cl,%esi
f010455d:	89 d9                	mov    %ebx,%ecx
f010455f:	d3 ed                	shr    %cl,%ebp
f0104561:	89 f9                	mov    %edi,%ecx
f0104563:	d3 e0                	shl    %cl,%eax
f0104565:	09 ee                	or     %ebp,%esi
f0104567:	89 d9                	mov    %ebx,%ecx
f0104569:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010456d:	89 d5                	mov    %edx,%ebp
f010456f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104573:	d3 ed                	shr    %cl,%ebp
f0104575:	89 f9                	mov    %edi,%ecx
f0104577:	d3 e2                	shl    %cl,%edx
f0104579:	89 d9                	mov    %ebx,%ecx
f010457b:	d3 e8                	shr    %cl,%eax
f010457d:	09 c2                	or     %eax,%edx
f010457f:	89 d0                	mov    %edx,%eax
f0104581:	89 ea                	mov    %ebp,%edx
f0104583:	f7 f6                	div    %esi
f0104585:	89 d5                	mov    %edx,%ebp
f0104587:	89 c3                	mov    %eax,%ebx
f0104589:	f7 64 24 0c          	mull   0xc(%esp)
f010458d:	39 d5                	cmp    %edx,%ebp
f010458f:	72 10                	jb     f01045a1 <__udivdi3+0xc1>
f0104591:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104595:	89 f9                	mov    %edi,%ecx
f0104597:	d3 e6                	shl    %cl,%esi
f0104599:	39 c6                	cmp    %eax,%esi
f010459b:	73 07                	jae    f01045a4 <__udivdi3+0xc4>
f010459d:	39 d5                	cmp    %edx,%ebp
f010459f:	75 03                	jne    f01045a4 <__udivdi3+0xc4>
f01045a1:	83 eb 01             	sub    $0x1,%ebx
f01045a4:	31 ff                	xor    %edi,%edi
f01045a6:	89 d8                	mov    %ebx,%eax
f01045a8:	89 fa                	mov    %edi,%edx
f01045aa:	83 c4 1c             	add    $0x1c,%esp
f01045ad:	5b                   	pop    %ebx
f01045ae:	5e                   	pop    %esi
f01045af:	5f                   	pop    %edi
f01045b0:	5d                   	pop    %ebp
f01045b1:	c3                   	ret    
f01045b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01045b8:	31 ff                	xor    %edi,%edi
f01045ba:	31 db                	xor    %ebx,%ebx
f01045bc:	89 d8                	mov    %ebx,%eax
f01045be:	89 fa                	mov    %edi,%edx
f01045c0:	83 c4 1c             	add    $0x1c,%esp
f01045c3:	5b                   	pop    %ebx
f01045c4:	5e                   	pop    %esi
f01045c5:	5f                   	pop    %edi
f01045c6:	5d                   	pop    %ebp
f01045c7:	c3                   	ret    
f01045c8:	90                   	nop
f01045c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01045d0:	89 d8                	mov    %ebx,%eax
f01045d2:	f7 f7                	div    %edi
f01045d4:	31 ff                	xor    %edi,%edi
f01045d6:	89 c3                	mov    %eax,%ebx
f01045d8:	89 d8                	mov    %ebx,%eax
f01045da:	89 fa                	mov    %edi,%edx
f01045dc:	83 c4 1c             	add    $0x1c,%esp
f01045df:	5b                   	pop    %ebx
f01045e0:	5e                   	pop    %esi
f01045e1:	5f                   	pop    %edi
f01045e2:	5d                   	pop    %ebp
f01045e3:	c3                   	ret    
f01045e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01045e8:	39 ce                	cmp    %ecx,%esi
f01045ea:	72 0c                	jb     f01045f8 <__udivdi3+0x118>
f01045ec:	31 db                	xor    %ebx,%ebx
f01045ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01045f2:	0f 87 34 ff ff ff    	ja     f010452c <__udivdi3+0x4c>
f01045f8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01045fd:	e9 2a ff ff ff       	jmp    f010452c <__udivdi3+0x4c>
f0104602:	66 90                	xchg   %ax,%ax
f0104604:	66 90                	xchg   %ax,%ax
f0104606:	66 90                	xchg   %ax,%ax
f0104608:	66 90                	xchg   %ax,%ax
f010460a:	66 90                	xchg   %ax,%ax
f010460c:	66 90                	xchg   %ax,%ax
f010460e:	66 90                	xchg   %ax,%ax

f0104610 <__umoddi3>:
f0104610:	55                   	push   %ebp
f0104611:	57                   	push   %edi
f0104612:	56                   	push   %esi
f0104613:	53                   	push   %ebx
f0104614:	83 ec 1c             	sub    $0x1c,%esp
f0104617:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010461b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010461f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104623:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104627:	85 d2                	test   %edx,%edx
f0104629:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010462d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104631:	89 f3                	mov    %esi,%ebx
f0104633:	89 3c 24             	mov    %edi,(%esp)
f0104636:	89 74 24 04          	mov    %esi,0x4(%esp)
f010463a:	75 1c                	jne    f0104658 <__umoddi3+0x48>
f010463c:	39 f7                	cmp    %esi,%edi
f010463e:	76 50                	jbe    f0104690 <__umoddi3+0x80>
f0104640:	89 c8                	mov    %ecx,%eax
f0104642:	89 f2                	mov    %esi,%edx
f0104644:	f7 f7                	div    %edi
f0104646:	89 d0                	mov    %edx,%eax
f0104648:	31 d2                	xor    %edx,%edx
f010464a:	83 c4 1c             	add    $0x1c,%esp
f010464d:	5b                   	pop    %ebx
f010464e:	5e                   	pop    %esi
f010464f:	5f                   	pop    %edi
f0104650:	5d                   	pop    %ebp
f0104651:	c3                   	ret    
f0104652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104658:	39 f2                	cmp    %esi,%edx
f010465a:	89 d0                	mov    %edx,%eax
f010465c:	77 52                	ja     f01046b0 <__umoddi3+0xa0>
f010465e:	0f bd ea             	bsr    %edx,%ebp
f0104661:	83 f5 1f             	xor    $0x1f,%ebp
f0104664:	75 5a                	jne    f01046c0 <__umoddi3+0xb0>
f0104666:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010466a:	0f 82 e0 00 00 00    	jb     f0104750 <__umoddi3+0x140>
f0104670:	39 0c 24             	cmp    %ecx,(%esp)
f0104673:	0f 86 d7 00 00 00    	jbe    f0104750 <__umoddi3+0x140>
f0104679:	8b 44 24 08          	mov    0x8(%esp),%eax
f010467d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104681:	83 c4 1c             	add    $0x1c,%esp
f0104684:	5b                   	pop    %ebx
f0104685:	5e                   	pop    %esi
f0104686:	5f                   	pop    %edi
f0104687:	5d                   	pop    %ebp
f0104688:	c3                   	ret    
f0104689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104690:	85 ff                	test   %edi,%edi
f0104692:	89 fd                	mov    %edi,%ebp
f0104694:	75 0b                	jne    f01046a1 <__umoddi3+0x91>
f0104696:	b8 01 00 00 00       	mov    $0x1,%eax
f010469b:	31 d2                	xor    %edx,%edx
f010469d:	f7 f7                	div    %edi
f010469f:	89 c5                	mov    %eax,%ebp
f01046a1:	89 f0                	mov    %esi,%eax
f01046a3:	31 d2                	xor    %edx,%edx
f01046a5:	f7 f5                	div    %ebp
f01046a7:	89 c8                	mov    %ecx,%eax
f01046a9:	f7 f5                	div    %ebp
f01046ab:	89 d0                	mov    %edx,%eax
f01046ad:	eb 99                	jmp    f0104648 <__umoddi3+0x38>
f01046af:	90                   	nop
f01046b0:	89 c8                	mov    %ecx,%eax
f01046b2:	89 f2                	mov    %esi,%edx
f01046b4:	83 c4 1c             	add    $0x1c,%esp
f01046b7:	5b                   	pop    %ebx
f01046b8:	5e                   	pop    %esi
f01046b9:	5f                   	pop    %edi
f01046ba:	5d                   	pop    %ebp
f01046bb:	c3                   	ret    
f01046bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01046c0:	8b 34 24             	mov    (%esp),%esi
f01046c3:	bf 20 00 00 00       	mov    $0x20,%edi
f01046c8:	89 e9                	mov    %ebp,%ecx
f01046ca:	29 ef                	sub    %ebp,%edi
f01046cc:	d3 e0                	shl    %cl,%eax
f01046ce:	89 f9                	mov    %edi,%ecx
f01046d0:	89 f2                	mov    %esi,%edx
f01046d2:	d3 ea                	shr    %cl,%edx
f01046d4:	89 e9                	mov    %ebp,%ecx
f01046d6:	09 c2                	or     %eax,%edx
f01046d8:	89 d8                	mov    %ebx,%eax
f01046da:	89 14 24             	mov    %edx,(%esp)
f01046dd:	89 f2                	mov    %esi,%edx
f01046df:	d3 e2                	shl    %cl,%edx
f01046e1:	89 f9                	mov    %edi,%ecx
f01046e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01046e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01046eb:	d3 e8                	shr    %cl,%eax
f01046ed:	89 e9                	mov    %ebp,%ecx
f01046ef:	89 c6                	mov    %eax,%esi
f01046f1:	d3 e3                	shl    %cl,%ebx
f01046f3:	89 f9                	mov    %edi,%ecx
f01046f5:	89 d0                	mov    %edx,%eax
f01046f7:	d3 e8                	shr    %cl,%eax
f01046f9:	89 e9                	mov    %ebp,%ecx
f01046fb:	09 d8                	or     %ebx,%eax
f01046fd:	89 d3                	mov    %edx,%ebx
f01046ff:	89 f2                	mov    %esi,%edx
f0104701:	f7 34 24             	divl   (%esp)
f0104704:	89 d6                	mov    %edx,%esi
f0104706:	d3 e3                	shl    %cl,%ebx
f0104708:	f7 64 24 04          	mull   0x4(%esp)
f010470c:	39 d6                	cmp    %edx,%esi
f010470e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104712:	89 d1                	mov    %edx,%ecx
f0104714:	89 c3                	mov    %eax,%ebx
f0104716:	72 08                	jb     f0104720 <__umoddi3+0x110>
f0104718:	75 11                	jne    f010472b <__umoddi3+0x11b>
f010471a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010471e:	73 0b                	jae    f010472b <__umoddi3+0x11b>
f0104720:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104724:	1b 14 24             	sbb    (%esp),%edx
f0104727:	89 d1                	mov    %edx,%ecx
f0104729:	89 c3                	mov    %eax,%ebx
f010472b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010472f:	29 da                	sub    %ebx,%edx
f0104731:	19 ce                	sbb    %ecx,%esi
f0104733:	89 f9                	mov    %edi,%ecx
f0104735:	89 f0                	mov    %esi,%eax
f0104737:	d3 e0                	shl    %cl,%eax
f0104739:	89 e9                	mov    %ebp,%ecx
f010473b:	d3 ea                	shr    %cl,%edx
f010473d:	89 e9                	mov    %ebp,%ecx
f010473f:	d3 ee                	shr    %cl,%esi
f0104741:	09 d0                	or     %edx,%eax
f0104743:	89 f2                	mov    %esi,%edx
f0104745:	83 c4 1c             	add    $0x1c,%esp
f0104748:	5b                   	pop    %ebx
f0104749:	5e                   	pop    %esi
f010474a:	5f                   	pop    %edi
f010474b:	5d                   	pop    %ebp
f010474c:	c3                   	ret    
f010474d:	8d 76 00             	lea    0x0(%esi),%esi
f0104750:	29 f9                	sub    %edi,%ecx
f0104752:	19 d6                	sbb    %edx,%esi
f0104754:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104758:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010475c:	e9 18 ff ff ff       	jmp    f0104679 <__umoddi3+0x69>
