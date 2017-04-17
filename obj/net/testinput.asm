
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 fb 06 00 00       	call   80072c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 7c             	sub    $0x7c,%esp
	envid_t ns_envid = sys_getenvid();
  80003c:	e8 6e 11 00 00       	call   8011af <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800043:	c7 05 00 40 80 00 60 	movl   $0x802c60,0x804000
  80004a:	2c 80 00 

	output_envid = fork();
  80004d:	e8 5f 15 00 00       	call   8015b1 <fork>
  800052:	a3 04 50 80 00       	mov    %eax,0x805004
	if (output_envid < 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	79 14                	jns    80006f <umain+0x3c>
		panic("error forking");
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	68 6a 2c 80 00       	push   $0x802c6a
  800063:	6a 4d                	push   $0x4d
  800065:	68 78 2c 80 00       	push   $0x802c78
  80006a:	e8 1d 07 00 00       	call   80078c <_panic>
	else if (output_envid == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 11                	jne    800084 <umain+0x51>
		output(ns_envid);
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	53                   	push   %ebx
  800077:	e8 bd 03 00 00       	call   800439 <output>
		return;
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	e9 0b 03 00 00       	jmp    80038f <umain+0x35c>
	}

	input_envid = fork();
  800084:	e8 28 15 00 00       	call   8015b1 <fork>
  800089:	a3 00 50 80 00       	mov    %eax,0x805000
	if (input_envid < 0)
  80008e:	85 c0                	test   %eax,%eax
  800090:	79 14                	jns    8000a6 <umain+0x73>
		panic("error forking");
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	68 6a 2c 80 00       	push   $0x802c6a
  80009a:	6a 55                	push   $0x55
  80009c:	68 78 2c 80 00       	push   $0x802c78
  8000a1:	e8 e6 06 00 00       	call   80078c <_panic>
	else if (input_envid == 0) {
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 11                	jne    8000bb <umain+0x88>
		input(ns_envid);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	53                   	push   %ebx
  8000ae:	e8 77 03 00 00       	call   80042a <input>
		return;
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	e9 d4 02 00 00       	jmp    80038f <umain+0x35c>
	}

	cprintf("Sending ARP announcement...\n");
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 88 2c 80 00       	push   $0x802c88
  8000c3:	e8 9d 07 00 00       	call   800865 <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000c8:	c6 45 98 52          	movb   $0x52,-0x68(%ebp)
  8000cc:	c6 45 99 54          	movb   $0x54,-0x67(%ebp)
  8000d0:	c6 45 9a 00          	movb   $0x0,-0x66(%ebp)
  8000d4:	c6 45 9b 12          	movb   $0x12,-0x65(%ebp)
  8000d8:	c6 45 9c 34          	movb   $0x34,-0x64(%ebp)
  8000dc:	c6 45 9d 56          	movb   $0x56,-0x63(%ebp)
	uint32_t myip = inet_addr(IP);
  8000e0:	c7 04 24 a5 2c 80 00 	movl   $0x802ca5,(%esp)
  8000e7:	e8 0e 06 00 00       	call   8006fa <inet_addr>
  8000ec:	89 45 90             	mov    %eax,-0x70(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000ef:	c7 04 24 af 2c 80 00 	movl   $0x802caf,(%esp)
  8000f6:	e8 ff 05 00 00       	call   8006fa <inet_addr>
  8000fb:	89 45 94             	mov    %eax,-0x6c(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  8000fe:	83 c4 0c             	add    $0xc,%esp
  800101:	6a 07                	push   $0x7
  800103:	68 00 b0 fe 0f       	push   $0xffeb000
  800108:	6a 00                	push   $0x0
  80010a:	e8 de 10 00 00       	call   8011ed <sys_page_alloc>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	85 c0                	test   %eax,%eax
  800114:	79 12                	jns    800128 <umain+0xf5>
		panic("sys_page_map: %e", r);
  800116:	50                   	push   %eax
  800117:	68 b8 2c 80 00       	push   $0x802cb8
  80011c:	6a 19                	push   $0x19
  80011e:	68 78 2c 80 00       	push   $0x802c78
  800123:	e8 64 06 00 00       	call   80078c <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800128:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  80012f:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800132:	83 ec 04             	sub    $0x4,%esp
  800135:	6a 06                	push   $0x6
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	68 04 b0 fe 0f       	push   $0xffeb004
  800141:	e8 e9 0d 00 00       	call   800f2f <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800146:	83 c4 0c             	add    $0xc,%esp
  800149:	6a 06                	push   $0x6
  80014b:	8d 5d 98             	lea    -0x68(%ebp),%ebx
  80014e:	53                   	push   %ebx
  80014f:	68 0a b0 fe 0f       	push   $0xffeb00a
  800154:	e8 8b 0e 00 00       	call   800fe4 <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  800159:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800160:	e8 7c 03 00 00       	call   8004e1 <htons>
  800165:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80016b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800172:	e8 6a 03 00 00       	call   8004e1 <htons>
  800177:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  80017d:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  800184:	e8 58 03 00 00       	call   8004e1 <htons>
  800189:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  80018f:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  800196:	e8 46 03 00 00       	call   8004e1 <htons>
  80019b:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a8:	e8 34 03 00 00       	call   8004e1 <htons>
  8001ad:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001b3:	83 c4 0c             	add    $0xc,%esp
  8001b6:	6a 06                	push   $0x6
  8001b8:	53                   	push   %ebx
  8001b9:	68 1a b0 fe 0f       	push   $0xffeb01a
  8001be:	e8 21 0e 00 00       	call   800fe4 <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001c3:	83 c4 0c             	add    $0xc,%esp
  8001c6:	6a 04                	push   $0x4
  8001c8:	8d 45 90             	lea    -0x70(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 20 b0 fe 0f       	push   $0xffeb020
  8001d1:	e8 0e 0e 00 00       	call   800fe4 <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  8001d6:	83 c4 0c             	add    $0xc,%esp
  8001d9:	6a 06                	push   $0x6
  8001db:	6a 00                	push   $0x0
  8001dd:	68 24 b0 fe 0f       	push   $0xffeb024
  8001e2:	e8 48 0d 00 00       	call   800f2f <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  8001e7:	83 c4 0c             	add    $0xc,%esp
  8001ea:	6a 04                	push   $0x4
  8001ec:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	68 2a b0 fe 0f       	push   $0xffeb02a
  8001f5:	e8 ea 0d 00 00       	call   800fe4 <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  8001fa:	6a 07                	push   $0x7
  8001fc:	68 00 b0 fe 0f       	push   $0xffeb000
  800201:	6a 0b                	push   $0xb
  800203:	ff 35 04 50 80 00    	pushl  0x805004
  800209:	e8 01 15 00 00       	call   80170f <ipc_send>
	sys_page_unmap(0, pkt);
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	68 00 b0 fe 0f       	push   $0xffeb000
  800216:	6a 00                	push   $0x0
  800218:	e8 55 10 00 00       	call   801272 <sys_page_unmap>
  80021d:	83 c4 10             	add    $0x10,%esp

void
umain(int argc, char **argv)
{
	envid_t ns_envid = sys_getenvid();
	int i, r, first = 1;
  800220:	c7 85 7c ff ff ff 01 	movl   $0x1,-0x84(%ebp)
  800227:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800230:	50                   	push   %eax
  800231:	68 00 b0 fe 0f       	push   $0xffeb000
  800236:	8d 45 90             	lea    -0x70(%ebp),%eax
  800239:	50                   	push   %eax
  80023a:	e8 67 14 00 00       	call   8016a6 <ipc_recv>
		if (req < 0)
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	85 c0                	test   %eax,%eax
  800244:	79 12                	jns    800258 <umain+0x225>
			panic("ipc_recv: %e", req);
  800246:	50                   	push   %eax
  800247:	68 c9 2c 80 00       	push   $0x802cc9
  80024c:	6a 64                	push   $0x64
  80024e:	68 78 2c 80 00       	push   $0x802c78
  800253:	e8 34 05 00 00       	call   80078c <_panic>
		if (whom != input_envid)
  800258:	8b 55 90             	mov    -0x70(%ebp),%edx
  80025b:	3b 15 00 50 80 00    	cmp    0x805000,%edx
  800261:	74 12                	je     800275 <umain+0x242>
			panic("IPC from unexpected environment %08x", whom);
  800263:	52                   	push   %edx
  800264:	68 20 2d 80 00       	push   $0x802d20
  800269:	6a 66                	push   $0x66
  80026b:	68 78 2c 80 00       	push   $0x802c78
  800270:	e8 17 05 00 00       	call   80078c <_panic>
		if (req != NSREQ_INPUT)
  800275:	83 f8 0a             	cmp    $0xa,%eax
  800278:	74 12                	je     80028c <umain+0x259>
			panic("Unexpected IPC %d", req);
  80027a:	50                   	push   %eax
  80027b:	68 d6 2c 80 00       	push   $0x802cd6
  800280:	6a 68                	push   $0x68
  800282:	68 78 2c 80 00       	push   $0x802c78
  800287:	e8 00 05 00 00       	call   80078c <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  80028c:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800291:	89 45 84             	mov    %eax,-0x7c(%ebp)
hexdump(const char *prefix, const void *data, int len)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
  800294:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < len; i++) {
  800299:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
		if (i % 16 == 15 || i == len - 1)
  80029e:	83 e8 01             	sub    $0x1,%eax
  8002a1:	89 45 80             	mov    %eax,-0x80(%ebp)
  8002a4:	e9 a5 00 00 00       	jmp    80034e <umain+0x31b>
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
  8002a9:	89 df                	mov    %ebx,%edi
  8002ab:	f6 c3 0f             	test   $0xf,%bl
  8002ae:	75 22                	jne    8002d2 <umain+0x29f>
			out = buf + snprintf(buf, end - buf,
  8002b0:	83 ec 0c             	sub    $0xc,%esp
  8002b3:	53                   	push   %ebx
  8002b4:	68 e8 2c 80 00       	push   $0x802ce8
  8002b9:	68 f0 2c 80 00       	push   $0x802cf0
  8002be:	6a 50                	push   $0x50
  8002c0:	8d 45 98             	lea    -0x68(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 ce 0a 00 00       	call   800d97 <snprintf>
  8002c9:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  8002cc:	8d 34 01             	lea    (%ecx,%eax,1),%esi
  8002cf:	83 c4 20             	add    $0x20,%esp
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  8002d2:	b8 04 b0 fe 0f       	mov    $0xffeb004,%eax
  8002d7:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
  8002db:	50                   	push   %eax
  8002dc:	68 fa 2c 80 00       	push   $0x802cfa
  8002e1:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002e4:	29 f0                	sub    %esi,%eax
  8002e6:	50                   	push   %eax
  8002e7:	56                   	push   %esi
  8002e8:	e8 aa 0a 00 00       	call   800d97 <snprintf>
  8002ed:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8002ef:	89 d8                	mov    %ebx,%eax
  8002f1:	c1 f8 1f             	sar    $0x1f,%eax
  8002f4:	c1 e8 1c             	shr    $0x1c,%eax
  8002f7:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
  8002fa:	83 e7 0f             	and    $0xf,%edi
  8002fd:	29 c7                	sub    %eax,%edi
  8002ff:	83 c4 10             	add    $0x10,%esp
  800302:	83 ff 0f             	cmp    $0xf,%edi
  800305:	74 05                	je     80030c <umain+0x2d9>
  800307:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  80030a:	75 1c                	jne    800328 <umain+0x2f5>
			cprintf("%.*s\n", out - buf, buf);
  80030c:	83 ec 04             	sub    $0x4,%esp
  80030f:	8d 45 98             	lea    -0x68(%ebp),%eax
  800312:	50                   	push   %eax
  800313:	89 f0                	mov    %esi,%eax
  800315:	8d 4d 98             	lea    -0x68(%ebp),%ecx
  800318:	29 c8                	sub    %ecx,%eax
  80031a:	50                   	push   %eax
  80031b:	68 ff 2c 80 00       	push   $0x802cff
  800320:	e8 40 05 00 00       	call   800865 <cprintf>
  800325:	83 c4 10             	add    $0x10,%esp
		if (i % 2 == 1)
  800328:	89 da                	mov    %ebx,%edx
  80032a:	c1 ea 1f             	shr    $0x1f,%edx
  80032d:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800330:	83 e0 01             	and    $0x1,%eax
  800333:	29 d0                	sub    %edx,%eax
  800335:	83 f8 01             	cmp    $0x1,%eax
  800338:	75 06                	jne    800340 <umain+0x30d>
			*(out++) = ' ';
  80033a:	c6 06 20             	movb   $0x20,(%esi)
  80033d:	8d 76 01             	lea    0x1(%esi),%esi
		if (i % 16 == 7)
  800340:	83 ff 07             	cmp    $0x7,%edi
  800343:	75 06                	jne    80034b <umain+0x318>
			*(out++) = ' ';
  800345:	c6 06 20             	movb   $0x20,(%esi)
  800348:	8d 76 01             	lea    0x1(%esi),%esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  80034b:	83 c3 01             	add    $0x1,%ebx
  80034e:	3b 5d 84             	cmp    -0x7c(%ebp),%ebx
  800351:	0f 8c 52 ff ff ff    	jl     8002a9 <umain+0x276>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	68 1b 2d 80 00       	push   $0x802d1b
  80035f:	e8 01 05 00 00       	call   800865 <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800364:	83 c4 10             	add    $0x10,%esp
  800367:	83 bd 7c ff ff ff 00 	cmpl   $0x0,-0x84(%ebp)
  80036e:	74 10                	je     800380 <umain+0x34d>
			cprintf("Waiting for packets...\n");
  800370:	83 ec 0c             	sub    $0xc,%esp
  800373:	68 05 2d 80 00       	push   $0x802d05
  800378:	e8 e8 04 00 00       	call   800865 <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp
		first = 0;
  800380:	c7 85 7c ff ff ff 00 	movl   $0x0,-0x84(%ebp)
  800387:	00 00 00 
	}
  80038a:	e9 9b fe ff ff       	jmp    80022a <umain+0x1f7>
}
  80038f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 1c             	sub    $0x1c,%esp
  8003a0:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  8003a3:	e8 36 10 00 00       	call   8013de <sys_time_msec>
  8003a8:	03 45 0c             	add    0xc(%ebp),%eax
  8003ab:	89 c3                	mov    %eax,%ebx

	binaryname = "ns_timer";
  8003ad:	c7 05 00 40 80 00 45 	movl   $0x802d45,0x804000
  8003b4:	2d 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003b7:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  8003ba:	eb 05                	jmp    8003c1 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  8003bc:	e8 0d 0e 00 00       	call   8011ce <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  8003c1:	e8 18 10 00 00       	call   8013de <sys_time_msec>
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	78 04                	js     8003d0 <timer+0x39>
  8003cc:	39 c3                	cmp    %eax,%ebx
  8003ce:	77 ec                	ja     8003bc <timer+0x25>
			sys_yield();
		}
		if (r < 0)
  8003d0:	85 c0                	test   %eax,%eax
  8003d2:	79 12                	jns    8003e6 <timer+0x4f>
			panic("sys_time_msec: %e", r);
  8003d4:	52                   	push   %edx
  8003d5:	68 4e 2d 80 00       	push   $0x802d4e
  8003da:	6a 0f                	push   $0xf
  8003dc:	68 60 2d 80 00       	push   $0x802d60
  8003e1:	e8 a6 03 00 00       	call   80078c <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8003e6:	6a 00                	push   $0x0
  8003e8:	6a 00                	push   $0x0
  8003ea:	6a 0c                	push   $0xc
  8003ec:	56                   	push   %esi
  8003ed:	e8 1d 13 00 00       	call   80170f <ipc_send>
  8003f2:	83 c4 10             	add    $0x10,%esp

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8003f5:	83 ec 04             	sub    $0x4,%esp
  8003f8:	6a 00                	push   $0x0
  8003fa:	6a 00                	push   $0x0
  8003fc:	57                   	push   %edi
  8003fd:	e8 a4 12 00 00       	call   8016a6 <ipc_recv>
  800402:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  800404:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	39 f0                	cmp    %esi,%eax
  80040c:	74 13                	je     800421 <timer+0x8a>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	50                   	push   %eax
  800412:	68 6c 2d 80 00       	push   $0x802d6c
  800417:	e8 49 04 00 00       	call   800865 <cprintf>
				continue;
  80041c:	83 c4 10             	add    $0x10,%esp
  80041f:	eb d4                	jmp    8003f5 <timer+0x5e>
			}

			stop = sys_time_msec() + to;
  800421:	e8 b8 0f 00 00       	call   8013de <sys_time_msec>
  800426:	01 c3                	add    %eax,%ebx
  800428:	eb 97                	jmp    8003c1 <timer+0x2a>

0080042a <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  80042d:	c7 05 00 40 80 00 a7 	movl   $0x802da7,0x804000
  800434:	2d 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  800437:	5d                   	pop    %ebp
  800438:	c3                   	ret    

00800439 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_output";
  80043c:	c7 05 00 40 80 00 b0 	movl   $0x802db0,0x804000
  800443:	2d 80 00 

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
}
  800446:	5d                   	pop    %ebp
  800447:	c3                   	ret    

00800448 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800451:	8b 45 08             	mov    0x8(%ebp),%eax
  800454:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800457:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  80045a:	c7 45 e0 08 50 80 00 	movl   $0x805008,-0x20(%ebp)
  800461:	0f b6 0f             	movzbl (%edi),%ecx
  800464:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800469:	0f b6 d9             	movzbl %cl,%ebx
  80046c:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  80046f:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800472:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800475:	66 c1 e8 0b          	shr    $0xb,%ax
  800479:	89 c3                	mov    %eax,%ebx
  80047b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047e:	01 c0                	add    %eax,%eax
  800480:	29 c1                	sub    %eax,%ecx
  800482:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800484:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800486:	8d 72 01             	lea    0x1(%edx),%esi
  800489:	0f b6 d2             	movzbl %dl,%edx
  80048c:	83 c0 30             	add    $0x30,%eax
  80048f:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800493:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800495:	84 db                	test   %bl,%bl
  800497:	75 d0                	jne    800469 <inet_ntoa+0x21>
  800499:	c6 07 00             	movb   $0x0,(%edi)
  80049c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049f:	eb 0d                	jmp    8004ae <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  8004a1:	0f b6 c2             	movzbl %dl,%eax
  8004a4:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  8004a9:	88 01                	mov    %al,(%ecx)
  8004ab:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8004ae:	83 ea 01             	sub    $0x1,%edx
  8004b1:	80 fa ff             	cmp    $0xff,%dl
  8004b4:	75 eb                	jne    8004a1 <inet_ntoa+0x59>
  8004b6:	89 f0                	mov    %esi,%eax
  8004b8:	0f b6 f0             	movzbl %al,%esi
  8004bb:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  8004be:	8d 46 01             	lea    0x1(%esi),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  8004c7:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8004ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004cd:	39 c7                	cmp    %eax,%edi
  8004cf:	75 90                	jne    800461 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  8004d1:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  8004d4:	b8 08 50 80 00       	mov    $0x805008,%eax
  8004d9:	83 c4 14             	add    $0x14,%esp
  8004dc:	5b                   	pop    %ebx
  8004dd:	5e                   	pop    %esi
  8004de:	5f                   	pop    %edi
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8004e4:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8004e8:	66 c1 c0 08          	rol    $0x8,%ax
}
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  return htons(n);
  8004f1:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8004f5:	66 c1 c0 08          	rol    $0x8,%ax
}
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800501:	89 d1                	mov    %edx,%ecx
  800503:	c1 e1 18             	shl    $0x18,%ecx
  800506:	89 d0                	mov    %edx,%eax
  800508:	c1 e8 18             	shr    $0x18,%eax
  80050b:	09 c8                	or     %ecx,%eax
  80050d:	89 d1                	mov    %edx,%ecx
  80050f:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800515:	c1 e1 08             	shl    $0x8,%ecx
  800518:	09 c8                	or     %ecx,%eax
  80051a:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800520:	c1 ea 08             	shr    $0x8,%edx
  800523:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800525:	5d                   	pop    %ebp
  800526:	c3                   	ret    

00800527 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	57                   	push   %edi
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	83 ec 20             	sub    $0x20,%esp
  800530:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800533:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800536:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  800539:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80053c:	0f b6 ca             	movzbl %dl,%ecx
  80053f:	83 e9 30             	sub    $0x30,%ecx
  800542:	83 f9 09             	cmp    $0x9,%ecx
  800545:	0f 87 94 01 00 00    	ja     8006df <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  80054b:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  800552:	83 fa 30             	cmp    $0x30,%edx
  800555:	75 2b                	jne    800582 <inet_aton+0x5b>
      c = *++cp;
  800557:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80055b:	89 d1                	mov    %edx,%ecx
  80055d:	83 e1 df             	and    $0xffffffdf,%ecx
  800560:	80 f9 58             	cmp    $0x58,%cl
  800563:	74 0f                	je     800574 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800565:	83 c0 01             	add    $0x1,%eax
  800568:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  80056b:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800572:	eb 0e                	jmp    800582 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800574:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800578:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  80057b:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800582:	83 c0 01             	add    $0x1,%eax
  800585:	be 00 00 00 00       	mov    $0x0,%esi
  80058a:	eb 03                	jmp    80058f <inet_aton+0x68>
  80058c:	83 c0 01             	add    $0x1,%eax
  80058f:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800592:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800595:	0f b6 fa             	movzbl %dl,%edi
  800598:	8d 4f d0             	lea    -0x30(%edi),%ecx
  80059b:	83 f9 09             	cmp    $0x9,%ecx
  80059e:	77 0d                	ja     8005ad <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  8005a0:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8005a4:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8005a8:	0f be 10             	movsbl (%eax),%edx
  8005ab:	eb df                	jmp    80058c <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  8005ad:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8005b1:	75 32                	jne    8005e5 <inet_aton+0xbe>
  8005b3:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  8005b6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bc:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  8005c2:	83 e9 41             	sub    $0x41,%ecx
  8005c5:	83 f9 05             	cmp    $0x5,%ecx
  8005c8:	77 1b                	ja     8005e5 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8005ca:	c1 e6 04             	shl    $0x4,%esi
  8005cd:	83 c2 0a             	add    $0xa,%edx
  8005d0:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  8005d4:	19 c9                	sbb    %ecx,%ecx
  8005d6:	83 e1 20             	and    $0x20,%ecx
  8005d9:	83 c1 41             	add    $0x41,%ecx
  8005dc:	29 ca                	sub    %ecx,%edx
  8005de:	09 d6                	or     %edx,%esi
        c = *++cp;
  8005e0:	0f be 10             	movsbl (%eax),%edx
  8005e3:	eb a7                	jmp    80058c <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  8005e5:	83 fa 2e             	cmp    $0x2e,%edx
  8005e8:	75 23                	jne    80060d <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8005ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ed:	8d 7d f0             	lea    -0x10(%ebp),%edi
  8005f0:	39 f8                	cmp    %edi,%eax
  8005f2:	0f 84 ee 00 00 00    	je     8006e6 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  8005f8:	83 c0 04             	add    $0x4,%eax
  8005fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005fe:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800601:	8d 43 01             	lea    0x1(%ebx),%eax
  800604:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800608:	e9 2f ff ff ff       	jmp    80053c <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80060d:	85 d2                	test   %edx,%edx
  80060f:	74 25                	je     800636 <inet_aton+0x10f>
  800611:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800614:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800619:	83 f9 5f             	cmp    $0x5f,%ecx
  80061c:	0f 87 d0 00 00 00    	ja     8006f2 <inet_aton+0x1cb>
  800622:	83 fa 20             	cmp    $0x20,%edx
  800625:	74 0f                	je     800636 <inet_aton+0x10f>
  800627:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80062a:	83 ea 09             	sub    $0x9,%edx
  80062d:	83 fa 04             	cmp    $0x4,%edx
  800630:	0f 87 bc 00 00 00    	ja     8006f2 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800636:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800639:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80063c:	29 c2                	sub    %eax,%edx
  80063e:	c1 fa 02             	sar    $0x2,%edx
  800641:	83 c2 01             	add    $0x1,%edx
  800644:	83 fa 02             	cmp    $0x2,%edx
  800647:	74 20                	je     800669 <inet_aton+0x142>
  800649:	83 fa 02             	cmp    $0x2,%edx
  80064c:	7f 0f                	jg     80065d <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  80064e:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  800653:	85 d2                	test   %edx,%edx
  800655:	0f 84 97 00 00 00    	je     8006f2 <inet_aton+0x1cb>
  80065b:	eb 67                	jmp    8006c4 <inet_aton+0x19d>
  80065d:	83 fa 03             	cmp    $0x3,%edx
  800660:	74 1e                	je     800680 <inet_aton+0x159>
  800662:	83 fa 04             	cmp    $0x4,%edx
  800665:	74 38                	je     80069f <inet_aton+0x178>
  800667:	eb 5b                	jmp    8006c4 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800669:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80066e:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  800674:	77 7c                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  800676:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800679:	c1 e0 18             	shl    $0x18,%eax
  80067c:	09 c6                	or     %eax,%esi
    break;
  80067e:	eb 44                	jmp    8006c4 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800680:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800685:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  80068b:	77 65                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80068d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800690:	c1 e2 18             	shl    $0x18,%edx
  800693:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800696:	c1 e0 10             	shl    $0x10,%eax
  800699:	09 d0                	or     %edx,%eax
  80069b:	09 c6                	or     %eax,%esi
    break;
  80069d:	eb 25                	jmp    8006c4 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80069f:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8006a4:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  8006aa:	77 46                	ja     8006f2 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8006ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006af:	c1 e2 18             	shl    $0x18,%edx
  8006b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8006b5:	c1 e0 10             	shl    $0x10,%eax
  8006b8:	09 c2                	or     %eax,%edx
  8006ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bd:	c1 e0 08             	shl    $0x8,%eax
  8006c0:	09 d0                	or     %edx,%eax
  8006c2:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  8006c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006c8:	74 23                	je     8006ed <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  8006ca:	56                   	push   %esi
  8006cb:	e8 2b fe ff ff       	call   8004fb <htonl>
  8006d0:	83 c4 04             	add    $0x4,%esp
  8006d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d6:	89 03                	mov    %eax,(%ebx)
  return (1);
  8006d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8006dd:	eb 13                	jmp    8006f2 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	eb 0c                	jmp    8006f2 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	eb 05                	jmp    8006f2 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8006ed:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8006f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5e                   	pop    %esi
  8006f7:	5f                   	pop    %edi
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800700:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800703:	50                   	push   %eax
  800704:	ff 75 08             	pushl  0x8(%ebp)
  800707:	e8 1b fe ff ff       	call   800527 <inet_aton>
  80070c:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80070f:	85 c0                	test   %eax,%eax
  800711:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800716:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80071f:	ff 75 08             	pushl  0x8(%ebp)
  800722:	e8 d4 fd ff ff       	call   8004fb <htonl>
  800727:	83 c4 04             	add    $0x4,%esp
}
  80072a:	c9                   	leave  
  80072b:	c3                   	ret    

0080072c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800734:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800737:	e8 73 0a 00 00       	call   8011af <sys_getenvid>
  80073c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800741:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800744:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800749:	a3 20 50 80 00       	mov    %eax,0x805020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80074e:	85 db                	test   %ebx,%ebx
  800750:	7e 07                	jle    800759 <libmain+0x2d>
		binaryname = argv[0];
  800752:	8b 06                	mov    (%esi),%eax
  800754:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	56                   	push   %esi
  80075d:	53                   	push   %ebx
  80075e:	e8 d0 f8 ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800763:	e8 0a 00 00 00       	call   800772 <exit>
}
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800778:	e8 ea 11 00 00       	call   801967 <close_all>
	sys_env_destroy(0);
  80077d:	83 ec 0c             	sub    $0xc,%esp
  800780:	6a 00                	push   $0x0
  800782:	e8 e7 09 00 00       	call   80116e <sys_env_destroy>
}
  800787:	83 c4 10             	add    $0x10,%esp
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	56                   	push   %esi
  800790:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800791:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800794:	8b 35 00 40 80 00    	mov    0x804000,%esi
  80079a:	e8 10 0a 00 00       	call   8011af <sys_getenvid>
  80079f:	83 ec 0c             	sub    $0xc,%esp
  8007a2:	ff 75 0c             	pushl  0xc(%ebp)
  8007a5:	ff 75 08             	pushl  0x8(%ebp)
  8007a8:	56                   	push   %esi
  8007a9:	50                   	push   %eax
  8007aa:	68 c4 2d 80 00       	push   $0x802dc4
  8007af:	e8 b1 00 00 00       	call   800865 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8007b4:	83 c4 18             	add    $0x18,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	ff 75 10             	pushl  0x10(%ebp)
  8007bb:	e8 54 00 00 00       	call   800814 <vcprintf>
	cprintf("\n");
  8007c0:	c7 04 24 1b 2d 80 00 	movl   $0x802d1b,(%esp)
  8007c7:	e8 99 00 00 00       	call   800865 <cprintf>
  8007cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8007cf:	cc                   	int3   
  8007d0:	eb fd                	jmp    8007cf <_panic+0x43>

008007d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 04             	sub    $0x4,%esp
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8007dc:	8b 13                	mov    (%ebx),%edx
  8007de:	8d 42 01             	lea    0x1(%edx),%eax
  8007e1:	89 03                	mov    %eax,(%ebx)
  8007e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8007ea:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007ef:	75 1a                	jne    80080b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	68 ff 00 00 00       	push   $0xff
  8007f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8007fc:	50                   	push   %eax
  8007fd:	e8 2f 09 00 00       	call   801131 <sys_cputs>
		b->idx = 0;
  800802:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800808:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80080b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80080f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800812:	c9                   	leave  
  800813:	c3                   	ret    

00800814 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80081d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800824:	00 00 00 
	b.cnt = 0;
  800827:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80082e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800831:	ff 75 0c             	pushl  0xc(%ebp)
  800834:	ff 75 08             	pushl  0x8(%ebp)
  800837:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80083d:	50                   	push   %eax
  80083e:	68 d2 07 80 00       	push   $0x8007d2
  800843:	e8 54 01 00 00       	call   80099c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800848:	83 c4 08             	add    $0x8,%esp
  80084b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800851:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800857:	50                   	push   %eax
  800858:	e8 d4 08 00 00       	call   801131 <sys_cputs>

	return b.cnt;
}
  80085d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800863:	c9                   	leave  
  800864:	c3                   	ret    

00800865 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80086b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80086e:	50                   	push   %eax
  80086f:	ff 75 08             	pushl  0x8(%ebp)
  800872:	e8 9d ff ff ff       	call   800814 <vcprintf>
	va_end(ap);

	return cnt;
}
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	57                   	push   %edi
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	83 ec 1c             	sub    $0x1c,%esp
  800882:	89 c7                	mov    %eax,%edi
  800884:	89 d6                	mov    %edx,%esi
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800892:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800895:	bb 00 00 00 00       	mov    $0x0,%ebx
  80089a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80089d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8008a0:	39 d3                	cmp    %edx,%ebx
  8008a2:	72 05                	jb     8008a9 <printnum+0x30>
  8008a4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8008a7:	77 45                	ja     8008ee <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8008a9:	83 ec 0c             	sub    $0xc,%esp
  8008ac:	ff 75 18             	pushl  0x18(%ebp)
  8008af:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8008b5:	53                   	push   %ebx
  8008b6:	ff 75 10             	pushl  0x10(%ebp)
  8008b9:	83 ec 08             	sub    $0x8,%esp
  8008bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8008c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8008c8:	e8 03 21 00 00       	call   8029d0 <__udivdi3>
  8008cd:	83 c4 18             	add    $0x18,%esp
  8008d0:	52                   	push   %edx
  8008d1:	50                   	push   %eax
  8008d2:	89 f2                	mov    %esi,%edx
  8008d4:	89 f8                	mov    %edi,%eax
  8008d6:	e8 9e ff ff ff       	call   800879 <printnum>
  8008db:	83 c4 20             	add    $0x20,%esp
  8008de:	eb 18                	jmp    8008f8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	56                   	push   %esi
  8008e4:	ff 75 18             	pushl  0x18(%ebp)
  8008e7:	ff d7                	call   *%edi
  8008e9:	83 c4 10             	add    $0x10,%esp
  8008ec:	eb 03                	jmp    8008f1 <printnum+0x78>
  8008ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8008f1:	83 eb 01             	sub    $0x1,%ebx
  8008f4:	85 db                	test   %ebx,%ebx
  8008f6:	7f e8                	jg     8008e0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	56                   	push   %esi
  8008fc:	83 ec 04             	sub    $0x4,%esp
  8008ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800902:	ff 75 e0             	pushl  -0x20(%ebp)
  800905:	ff 75 dc             	pushl  -0x24(%ebp)
  800908:	ff 75 d8             	pushl  -0x28(%ebp)
  80090b:	e8 f0 21 00 00       	call   802b00 <__umoddi3>
  800910:	83 c4 14             	add    $0x14,%esp
  800913:	0f be 80 e7 2d 80 00 	movsbl 0x802de7(%eax),%eax
  80091a:	50                   	push   %eax
  80091b:	ff d7                	call   *%edi
}
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800923:	5b                   	pop    %ebx
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80092b:	83 fa 01             	cmp    $0x1,%edx
  80092e:	7e 0e                	jle    80093e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800930:	8b 10                	mov    (%eax),%edx
  800932:	8d 4a 08             	lea    0x8(%edx),%ecx
  800935:	89 08                	mov    %ecx,(%eax)
  800937:	8b 02                	mov    (%edx),%eax
  800939:	8b 52 04             	mov    0x4(%edx),%edx
  80093c:	eb 22                	jmp    800960 <getuint+0x38>
	else if (lflag)
  80093e:	85 d2                	test   %edx,%edx
  800940:	74 10                	je     800952 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800942:	8b 10                	mov    (%eax),%edx
  800944:	8d 4a 04             	lea    0x4(%edx),%ecx
  800947:	89 08                	mov    %ecx,(%eax)
  800949:	8b 02                	mov    (%edx),%eax
  80094b:	ba 00 00 00 00       	mov    $0x0,%edx
  800950:	eb 0e                	jmp    800960 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800952:	8b 10                	mov    (%eax),%edx
  800954:	8d 4a 04             	lea    0x4(%edx),%ecx
  800957:	89 08                	mov    %ecx,(%eax)
  800959:	8b 02                	mov    (%edx),%eax
  80095b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800968:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80096c:	8b 10                	mov    (%eax),%edx
  80096e:	3b 50 04             	cmp    0x4(%eax),%edx
  800971:	73 0a                	jae    80097d <sprintputch+0x1b>
		*b->buf++ = ch;
  800973:	8d 4a 01             	lea    0x1(%edx),%ecx
  800976:	89 08                	mov    %ecx,(%eax)
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	88 02                	mov    %al,(%edx)
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800985:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800988:	50                   	push   %eax
  800989:	ff 75 10             	pushl  0x10(%ebp)
  80098c:	ff 75 0c             	pushl  0xc(%ebp)
  80098f:	ff 75 08             	pushl  0x8(%ebp)
  800992:	e8 05 00 00 00       	call   80099c <vprintfmt>
	va_end(ap);
}
  800997:	83 c4 10             	add    $0x10,%esp
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 2c             	sub    $0x2c,%esp
  8009a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8009ae:	eb 12                	jmp    8009c2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	0f 84 89 03 00 00    	je     800d41 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8009b8:	83 ec 08             	sub    $0x8,%esp
  8009bb:	53                   	push   %ebx
  8009bc:	50                   	push   %eax
  8009bd:	ff d6                	call   *%esi
  8009bf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8009c2:	83 c7 01             	add    $0x1,%edi
  8009c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009c9:	83 f8 25             	cmp    $0x25,%eax
  8009cc:	75 e2                	jne    8009b0 <vprintfmt+0x14>
  8009ce:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8009d2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8009d9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8009e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8009e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ec:	eb 07                	jmp    8009f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8009f1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009f5:	8d 47 01             	lea    0x1(%edi),%eax
  8009f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009fb:	0f b6 07             	movzbl (%edi),%eax
  8009fe:	0f b6 c8             	movzbl %al,%ecx
  800a01:	83 e8 23             	sub    $0x23,%eax
  800a04:	3c 55                	cmp    $0x55,%al
  800a06:	0f 87 1a 03 00 00    	ja     800d26 <vprintfmt+0x38a>
  800a0c:	0f b6 c0             	movzbl %al,%eax
  800a0f:	ff 24 85 20 2f 80 00 	jmp    *0x802f20(,%eax,4)
  800a16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a19:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a1d:	eb d6                	jmp    8009f5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a22:	b8 00 00 00 00       	mov    $0x0,%eax
  800a27:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800a2a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800a2d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800a31:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800a34:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800a37:	83 fa 09             	cmp    $0x9,%edx
  800a3a:	77 39                	ja     800a75 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800a3c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800a3f:	eb e9                	jmp    800a2a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800a41:	8b 45 14             	mov    0x14(%ebp),%eax
  800a44:	8d 48 04             	lea    0x4(%eax),%ecx
  800a47:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800a4a:	8b 00                	mov    (%eax),%eax
  800a4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800a52:	eb 27                	jmp    800a7b <vprintfmt+0xdf>
  800a54:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a57:	85 c0                	test   %eax,%eax
  800a59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a5e:	0f 49 c8             	cmovns %eax,%ecx
  800a61:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a67:	eb 8c                	jmp    8009f5 <vprintfmt+0x59>
  800a69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800a6c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800a73:	eb 80                	jmp    8009f5 <vprintfmt+0x59>
  800a75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a78:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800a7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a7f:	0f 89 70 ff ff ff    	jns    8009f5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800a85:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a88:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a8b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a92:	e9 5e ff ff ff       	jmp    8009f5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800a97:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800a9d:	e9 53 ff ff ff       	jmp    8009f5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa5:	8d 50 04             	lea    0x4(%eax),%edx
  800aa8:	89 55 14             	mov    %edx,0x14(%ebp)
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	53                   	push   %ebx
  800aaf:	ff 30                	pushl  (%eax)
  800ab1:	ff d6                	call   *%esi
			break;
  800ab3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ab6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800ab9:	e9 04 ff ff ff       	jmp    8009c2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800abe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac1:	8d 50 04             	lea    0x4(%eax),%edx
  800ac4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac7:	8b 00                	mov    (%eax),%eax
  800ac9:	99                   	cltd   
  800aca:	31 d0                	xor    %edx,%eax
  800acc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ace:	83 f8 0f             	cmp    $0xf,%eax
  800ad1:	7f 0b                	jg     800ade <vprintfmt+0x142>
  800ad3:	8b 14 85 80 30 80 00 	mov    0x803080(,%eax,4),%edx
  800ada:	85 d2                	test   %edx,%edx
  800adc:	75 18                	jne    800af6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800ade:	50                   	push   %eax
  800adf:	68 ff 2d 80 00       	push   $0x802dff
  800ae4:	53                   	push   %ebx
  800ae5:	56                   	push   %esi
  800ae6:	e8 94 fe ff ff       	call   80097f <printfmt>
  800aeb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800af1:	e9 cc fe ff ff       	jmp    8009c2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800af6:	52                   	push   %edx
  800af7:	68 42 32 80 00       	push   $0x803242
  800afc:	53                   	push   %ebx
  800afd:	56                   	push   %esi
  800afe:	e8 7c fe ff ff       	call   80097f <printfmt>
  800b03:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b09:	e9 b4 fe ff ff       	jmp    8009c2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800b0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b11:	8d 50 04             	lea    0x4(%eax),%edx
  800b14:	89 55 14             	mov    %edx,0x14(%ebp)
  800b17:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800b19:	85 ff                	test   %edi,%edi
  800b1b:	b8 f8 2d 80 00       	mov    $0x802df8,%eax
  800b20:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800b23:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b27:	0f 8e 94 00 00 00    	jle    800bc1 <vprintfmt+0x225>
  800b2d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800b31:	0f 84 98 00 00 00    	je     800bcf <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800b37:	83 ec 08             	sub    $0x8,%esp
  800b3a:	ff 75 d0             	pushl  -0x30(%ebp)
  800b3d:	57                   	push   %edi
  800b3e:	e8 86 02 00 00       	call   800dc9 <strnlen>
  800b43:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b46:	29 c1                	sub    %eax,%ecx
  800b48:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800b4b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800b4e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800b52:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b55:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800b58:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b5a:	eb 0f                	jmp    800b6b <vprintfmt+0x1cf>
					putch(padc, putdat);
  800b5c:	83 ec 08             	sub    $0x8,%esp
  800b5f:	53                   	push   %ebx
  800b60:	ff 75 e0             	pushl  -0x20(%ebp)
  800b63:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800b65:	83 ef 01             	sub    $0x1,%edi
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	85 ff                	test   %edi,%edi
  800b6d:	7f ed                	jg     800b5c <vprintfmt+0x1c0>
  800b6f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800b72:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800b75:	85 c9                	test   %ecx,%ecx
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	0f 49 c1             	cmovns %ecx,%eax
  800b7f:	29 c1                	sub    %eax,%ecx
  800b81:	89 75 08             	mov    %esi,0x8(%ebp)
  800b84:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800b87:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800b8a:	89 cb                	mov    %ecx,%ebx
  800b8c:	eb 4d                	jmp    800bdb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800b8e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b92:	74 1b                	je     800baf <vprintfmt+0x213>
  800b94:	0f be c0             	movsbl %al,%eax
  800b97:	83 e8 20             	sub    $0x20,%eax
  800b9a:	83 f8 5e             	cmp    $0x5e,%eax
  800b9d:	76 10                	jbe    800baf <vprintfmt+0x213>
					putch('?', putdat);
  800b9f:	83 ec 08             	sub    $0x8,%esp
  800ba2:	ff 75 0c             	pushl  0xc(%ebp)
  800ba5:	6a 3f                	push   $0x3f
  800ba7:	ff 55 08             	call   *0x8(%ebp)
  800baa:	83 c4 10             	add    $0x10,%esp
  800bad:	eb 0d                	jmp    800bbc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800baf:	83 ec 08             	sub    $0x8,%esp
  800bb2:	ff 75 0c             	pushl  0xc(%ebp)
  800bb5:	52                   	push   %edx
  800bb6:	ff 55 08             	call   *0x8(%ebp)
  800bb9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800bbc:	83 eb 01             	sub    $0x1,%ebx
  800bbf:	eb 1a                	jmp    800bdb <vprintfmt+0x23f>
  800bc1:	89 75 08             	mov    %esi,0x8(%ebp)
  800bc4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bc7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800bcd:	eb 0c                	jmp    800bdb <vprintfmt+0x23f>
  800bcf:	89 75 08             	mov    %esi,0x8(%ebp)
  800bd2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800bd5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800bd8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800bdb:	83 c7 01             	add    $0x1,%edi
  800bde:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800be2:	0f be d0             	movsbl %al,%edx
  800be5:	85 d2                	test   %edx,%edx
  800be7:	74 23                	je     800c0c <vprintfmt+0x270>
  800be9:	85 f6                	test   %esi,%esi
  800beb:	78 a1                	js     800b8e <vprintfmt+0x1f2>
  800bed:	83 ee 01             	sub    $0x1,%esi
  800bf0:	79 9c                	jns    800b8e <vprintfmt+0x1f2>
  800bf2:	89 df                	mov    %ebx,%edi
  800bf4:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bfa:	eb 18                	jmp    800c14 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800bfc:	83 ec 08             	sub    $0x8,%esp
  800bff:	53                   	push   %ebx
  800c00:	6a 20                	push   $0x20
  800c02:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c04:	83 ef 01             	sub    $0x1,%edi
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	eb 08                	jmp    800c14 <vprintfmt+0x278>
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c14:	85 ff                	test   %edi,%edi
  800c16:	7f e4                	jg     800bfc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c1b:	e9 a2 fd ff ff       	jmp    8009c2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c20:	83 fa 01             	cmp    $0x1,%edx
  800c23:	7e 16                	jle    800c3b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800c25:	8b 45 14             	mov    0x14(%ebp),%eax
  800c28:	8d 50 08             	lea    0x8(%eax),%edx
  800c2b:	89 55 14             	mov    %edx,0x14(%ebp)
  800c2e:	8b 50 04             	mov    0x4(%eax),%edx
  800c31:	8b 00                	mov    (%eax),%eax
  800c33:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c36:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800c39:	eb 32                	jmp    800c6d <vprintfmt+0x2d1>
	else if (lflag)
  800c3b:	85 d2                	test   %edx,%edx
  800c3d:	74 18                	je     800c57 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800c3f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c42:	8d 50 04             	lea    0x4(%eax),%edx
  800c45:	89 55 14             	mov    %edx,0x14(%ebp)
  800c48:	8b 00                	mov    (%eax),%eax
  800c4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c4d:	89 c1                	mov    %eax,%ecx
  800c4f:	c1 f9 1f             	sar    $0x1f,%ecx
  800c52:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800c55:	eb 16                	jmp    800c6d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800c57:	8b 45 14             	mov    0x14(%ebp),%eax
  800c5a:	8d 50 04             	lea    0x4(%eax),%edx
  800c5d:	89 55 14             	mov    %edx,0x14(%ebp)
  800c60:	8b 00                	mov    (%eax),%eax
  800c62:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800c65:	89 c1                	mov    %eax,%ecx
  800c67:	c1 f9 1f             	sar    $0x1f,%ecx
  800c6a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800c6d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c70:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800c73:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800c78:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c7c:	79 74                	jns    800cf2 <vprintfmt+0x356>
				putch('-', putdat);
  800c7e:	83 ec 08             	sub    $0x8,%esp
  800c81:	53                   	push   %ebx
  800c82:	6a 2d                	push   $0x2d
  800c84:	ff d6                	call   *%esi
				num = -(long long) num;
  800c86:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800c89:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800c8c:	f7 d8                	neg    %eax
  800c8e:	83 d2 00             	adc    $0x0,%edx
  800c91:	f7 da                	neg    %edx
  800c93:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800c96:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800c9b:	eb 55                	jmp    800cf2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800c9d:	8d 45 14             	lea    0x14(%ebp),%eax
  800ca0:	e8 83 fc ff ff       	call   800928 <getuint>
			base = 10;
  800ca5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800caa:	eb 46                	jmp    800cf2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800cac:	8d 45 14             	lea    0x14(%ebp),%eax
  800caf:	e8 74 fc ff ff       	call   800928 <getuint>
                        base = 8;
  800cb4:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
  800cb9:	eb 37                	jmp    800cf2 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800cbb:	83 ec 08             	sub    $0x8,%esp
  800cbe:	53                   	push   %ebx
  800cbf:	6a 30                	push   $0x30
  800cc1:	ff d6                	call   *%esi
			putch('x', putdat);
  800cc3:	83 c4 08             	add    $0x8,%esp
  800cc6:	53                   	push   %ebx
  800cc7:	6a 78                	push   $0x78
  800cc9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800ccb:	8b 45 14             	mov    0x14(%ebp),%eax
  800cce:	8d 50 04             	lea    0x4(%eax),%edx
  800cd1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800cd4:	8b 00                	mov    (%eax),%eax
  800cd6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800cdb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800cde:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800ce3:	eb 0d                	jmp    800cf2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ce5:	8d 45 14             	lea    0x14(%ebp),%eax
  800ce8:	e8 3b fc ff ff       	call   800928 <getuint>
			base = 16;
  800ced:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800cf9:	57                   	push   %edi
  800cfa:	ff 75 e0             	pushl  -0x20(%ebp)
  800cfd:	51                   	push   %ecx
  800cfe:	52                   	push   %edx
  800cff:	50                   	push   %eax
  800d00:	89 da                	mov    %ebx,%edx
  800d02:	89 f0                	mov    %esi,%eax
  800d04:	e8 70 fb ff ff       	call   800879 <printnum>
			break;
  800d09:	83 c4 20             	add    $0x20,%esp
  800d0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d0f:	e9 ae fc ff ff       	jmp    8009c2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d14:	83 ec 08             	sub    $0x8,%esp
  800d17:	53                   	push   %ebx
  800d18:	51                   	push   %ecx
  800d19:	ff d6                	call   *%esi
			break;
  800d1b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d21:	e9 9c fc ff ff       	jmp    8009c2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800d26:	83 ec 08             	sub    $0x8,%esp
  800d29:	53                   	push   %ebx
  800d2a:	6a 25                	push   $0x25
  800d2c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	eb 03                	jmp    800d36 <vprintfmt+0x39a>
  800d33:	83 ef 01             	sub    $0x1,%edi
  800d36:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800d3a:	75 f7                	jne    800d33 <vprintfmt+0x397>
  800d3c:	e9 81 fc ff ff       	jmp    8009c2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	83 ec 18             	sub    $0x18,%esp
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d55:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d58:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d5c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d66:	85 c0                	test   %eax,%eax
  800d68:	74 26                	je     800d90 <vsnprintf+0x47>
  800d6a:	85 d2                	test   %edx,%edx
  800d6c:	7e 22                	jle    800d90 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d6e:	ff 75 14             	pushl  0x14(%ebp)
  800d71:	ff 75 10             	pushl  0x10(%ebp)
  800d74:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d77:	50                   	push   %eax
  800d78:	68 62 09 80 00       	push   $0x800962
  800d7d:	e8 1a fc ff ff       	call   80099c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d85:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d8b:	83 c4 10             	add    $0x10,%esp
  800d8e:	eb 05                	jmp    800d95 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d9d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800da0:	50                   	push   %eax
  800da1:	ff 75 10             	pushl  0x10(%ebp)
  800da4:	ff 75 0c             	pushl  0xc(%ebp)
  800da7:	ff 75 08             	pushl  0x8(%ebp)
  800daa:	e8 9a ff ff ff       	call   800d49 <vsnprintf>
	va_end(ap);

	return rc;
}
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800db7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbc:	eb 03                	jmp    800dc1 <strlen+0x10>
		n++;
  800dbe:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800dc1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dc5:	75 f7                	jne    800dbe <strlen+0xd>
		n++;
	return n;
}
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	eb 03                	jmp    800ddc <strnlen+0x13>
		n++;
  800dd9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ddc:	39 c2                	cmp    %eax,%edx
  800dde:	74 08                	je     800de8 <strnlen+0x1f>
  800de0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800de4:	75 f3                	jne    800dd9 <strnlen+0x10>
  800de6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	53                   	push   %ebx
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800df4:	89 c2                	mov    %eax,%edx
  800df6:	83 c2 01             	add    $0x1,%edx
  800df9:	83 c1 01             	add    $0x1,%ecx
  800dfc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800e00:	88 5a ff             	mov    %bl,-0x1(%edx)
  800e03:	84 db                	test   %bl,%bl
  800e05:	75 ef                	jne    800df6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800e07:	5b                   	pop    %ebx
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e11:	53                   	push   %ebx
  800e12:	e8 9a ff ff ff       	call   800db1 <strlen>
  800e17:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800e1a:	ff 75 0c             	pushl  0xc(%ebp)
  800e1d:	01 d8                	add    %ebx,%eax
  800e1f:	50                   	push   %eax
  800e20:	e8 c5 ff ff ff       	call   800dea <strcpy>
	return dst;
}
  800e25:	89 d8                	mov    %ebx,%eax
  800e27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2a:	c9                   	leave  
  800e2b:	c3                   	ret    

00800e2c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	8b 75 08             	mov    0x8(%ebp),%esi
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	89 f3                	mov    %esi,%ebx
  800e39:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e3c:	89 f2                	mov    %esi,%edx
  800e3e:	eb 0f                	jmp    800e4f <strncpy+0x23>
		*dst++ = *src;
  800e40:	83 c2 01             	add    $0x1,%edx
  800e43:	0f b6 01             	movzbl (%ecx),%eax
  800e46:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e49:	80 39 01             	cmpb   $0x1,(%ecx)
  800e4c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e4f:	39 da                	cmp    %ebx,%edx
  800e51:	75 ed                	jne    800e40 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e53:	89 f0                	mov    %esi,%eax
  800e55:	5b                   	pop    %ebx
  800e56:	5e                   	pop    %esi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    

00800e59 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	56                   	push   %esi
  800e5d:	53                   	push   %ebx
  800e5e:	8b 75 08             	mov    0x8(%ebp),%esi
  800e61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e64:	8b 55 10             	mov    0x10(%ebp),%edx
  800e67:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e69:	85 d2                	test   %edx,%edx
  800e6b:	74 21                	je     800e8e <strlcpy+0x35>
  800e6d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800e71:	89 f2                	mov    %esi,%edx
  800e73:	eb 09                	jmp    800e7e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e75:	83 c2 01             	add    $0x1,%edx
  800e78:	83 c1 01             	add    $0x1,%ecx
  800e7b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e7e:	39 c2                	cmp    %eax,%edx
  800e80:	74 09                	je     800e8b <strlcpy+0x32>
  800e82:	0f b6 19             	movzbl (%ecx),%ebx
  800e85:	84 db                	test   %bl,%bl
  800e87:	75 ec                	jne    800e75 <strlcpy+0x1c>
  800e89:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e8b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e8e:	29 f0                	sub    %esi,%eax
}
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e9d:	eb 06                	jmp    800ea5 <strcmp+0x11>
		p++, q++;
  800e9f:	83 c1 01             	add    $0x1,%ecx
  800ea2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ea5:	0f b6 01             	movzbl (%ecx),%eax
  800ea8:	84 c0                	test   %al,%al
  800eaa:	74 04                	je     800eb0 <strcmp+0x1c>
  800eac:	3a 02                	cmp    (%edx),%al
  800eae:	74 ef                	je     800e9f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800eb0:	0f b6 c0             	movzbl %al,%eax
  800eb3:	0f b6 12             	movzbl (%edx),%edx
  800eb6:	29 d0                	sub    %edx,%eax
}
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	53                   	push   %ebx
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec4:	89 c3                	mov    %eax,%ebx
  800ec6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ec9:	eb 06                	jmp    800ed1 <strncmp+0x17>
		n--, p++, q++;
  800ecb:	83 c0 01             	add    $0x1,%eax
  800ece:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ed1:	39 d8                	cmp    %ebx,%eax
  800ed3:	74 15                	je     800eea <strncmp+0x30>
  800ed5:	0f b6 08             	movzbl (%eax),%ecx
  800ed8:	84 c9                	test   %cl,%cl
  800eda:	74 04                	je     800ee0 <strncmp+0x26>
  800edc:	3a 0a                	cmp    (%edx),%cl
  800ede:	74 eb                	je     800ecb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ee0:	0f b6 00             	movzbl (%eax),%eax
  800ee3:	0f b6 12             	movzbl (%edx),%edx
  800ee6:	29 d0                	sub    %edx,%eax
  800ee8:	eb 05                	jmp    800eef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800eef:	5b                   	pop    %ebx
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800efc:	eb 07                	jmp    800f05 <strchr+0x13>
		if (*s == c)
  800efe:	38 ca                	cmp    %cl,%dl
  800f00:	74 0f                	je     800f11 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f02:	83 c0 01             	add    $0x1,%eax
  800f05:	0f b6 10             	movzbl (%eax),%edx
  800f08:	84 d2                	test   %dl,%dl
  800f0a:	75 f2                	jne    800efe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800f0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f1d:	eb 03                	jmp    800f22 <strfind+0xf>
  800f1f:	83 c0 01             	add    $0x1,%eax
  800f22:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f25:	38 ca                	cmp    %cl,%dl
  800f27:	74 04                	je     800f2d <strfind+0x1a>
  800f29:	84 d2                	test   %dl,%dl
  800f2b:	75 f2                	jne    800f1f <strfind+0xc>
			break;
	return (char *) s;
}
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f3b:	85 c9                	test   %ecx,%ecx
  800f3d:	74 36                	je     800f75 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f45:	75 28                	jne    800f6f <memset+0x40>
  800f47:	f6 c1 03             	test   $0x3,%cl
  800f4a:	75 23                	jne    800f6f <memset+0x40>
		c &= 0xFF;
  800f4c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f50:	89 d3                	mov    %edx,%ebx
  800f52:	c1 e3 08             	shl    $0x8,%ebx
  800f55:	89 d6                	mov    %edx,%esi
  800f57:	c1 e6 18             	shl    $0x18,%esi
  800f5a:	89 d0                	mov    %edx,%eax
  800f5c:	c1 e0 10             	shl    $0x10,%eax
  800f5f:	09 f0                	or     %esi,%eax
  800f61:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800f63:	89 d8                	mov    %ebx,%eax
  800f65:	09 d0                	or     %edx,%eax
  800f67:	c1 e9 02             	shr    $0x2,%ecx
  800f6a:	fc                   	cld    
  800f6b:	f3 ab                	rep stos %eax,%es:(%edi)
  800f6d:	eb 06                	jmp    800f75 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f72:	fc                   	cld    
  800f73:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f75:	89 f8                	mov    %edi,%eax
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	57                   	push   %edi
  800f80:	56                   	push   %esi
  800f81:	8b 45 08             	mov    0x8(%ebp),%eax
  800f84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f8a:	39 c6                	cmp    %eax,%esi
  800f8c:	73 35                	jae    800fc3 <memmove+0x47>
  800f8e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f91:	39 d0                	cmp    %edx,%eax
  800f93:	73 2e                	jae    800fc3 <memmove+0x47>
		s += n;
		d += n;
  800f95:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f98:	89 d6                	mov    %edx,%esi
  800f9a:	09 fe                	or     %edi,%esi
  800f9c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800fa2:	75 13                	jne    800fb7 <memmove+0x3b>
  800fa4:	f6 c1 03             	test   $0x3,%cl
  800fa7:	75 0e                	jne    800fb7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800fa9:	83 ef 04             	sub    $0x4,%edi
  800fac:	8d 72 fc             	lea    -0x4(%edx),%esi
  800faf:	c1 e9 02             	shr    $0x2,%ecx
  800fb2:	fd                   	std    
  800fb3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fb5:	eb 09                	jmp    800fc0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fb7:	83 ef 01             	sub    $0x1,%edi
  800fba:	8d 72 ff             	lea    -0x1(%edx),%esi
  800fbd:	fd                   	std    
  800fbe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800fc0:	fc                   	cld    
  800fc1:	eb 1d                	jmp    800fe0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fc3:	89 f2                	mov    %esi,%edx
  800fc5:	09 c2                	or     %eax,%edx
  800fc7:	f6 c2 03             	test   $0x3,%dl
  800fca:	75 0f                	jne    800fdb <memmove+0x5f>
  800fcc:	f6 c1 03             	test   $0x3,%cl
  800fcf:	75 0a                	jne    800fdb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800fd1:	c1 e9 02             	shr    $0x2,%ecx
  800fd4:	89 c7                	mov    %eax,%edi
  800fd6:	fc                   	cld    
  800fd7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fd9:	eb 05                	jmp    800fe0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fdb:	89 c7                	mov    %eax,%edi
  800fdd:	fc                   	cld    
  800fde:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fe0:	5e                   	pop    %esi
  800fe1:	5f                   	pop    %edi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fe7:	ff 75 10             	pushl  0x10(%ebp)
  800fea:	ff 75 0c             	pushl  0xc(%ebp)
  800fed:	ff 75 08             	pushl  0x8(%ebp)
  800ff0:	e8 87 ff ff ff       	call   800f7c <memmove>
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801002:	89 c6                	mov    %eax,%esi
  801004:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801007:	eb 1a                	jmp    801023 <memcmp+0x2c>
		if (*s1 != *s2)
  801009:	0f b6 08             	movzbl (%eax),%ecx
  80100c:	0f b6 1a             	movzbl (%edx),%ebx
  80100f:	38 d9                	cmp    %bl,%cl
  801011:	74 0a                	je     80101d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801013:	0f b6 c1             	movzbl %cl,%eax
  801016:	0f b6 db             	movzbl %bl,%ebx
  801019:	29 d8                	sub    %ebx,%eax
  80101b:	eb 0f                	jmp    80102c <memcmp+0x35>
		s1++, s2++;
  80101d:	83 c0 01             	add    $0x1,%eax
  801020:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801023:	39 f0                	cmp    %esi,%eax
  801025:	75 e2                	jne    801009 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801027:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	53                   	push   %ebx
  801034:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801037:	89 c1                	mov    %eax,%ecx
  801039:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80103c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801040:	eb 0a                	jmp    80104c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801042:	0f b6 10             	movzbl (%eax),%edx
  801045:	39 da                	cmp    %ebx,%edx
  801047:	74 07                	je     801050 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801049:	83 c0 01             	add    $0x1,%eax
  80104c:	39 c8                	cmp    %ecx,%eax
  80104e:	72 f2                	jb     801042 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801050:	5b                   	pop    %ebx
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	57                   	push   %edi
  801057:	56                   	push   %esi
  801058:	53                   	push   %ebx
  801059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80105f:	eb 03                	jmp    801064 <strtol+0x11>
		s++;
  801061:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801064:	0f b6 01             	movzbl (%ecx),%eax
  801067:	3c 20                	cmp    $0x20,%al
  801069:	74 f6                	je     801061 <strtol+0xe>
  80106b:	3c 09                	cmp    $0x9,%al
  80106d:	74 f2                	je     801061 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80106f:	3c 2b                	cmp    $0x2b,%al
  801071:	75 0a                	jne    80107d <strtol+0x2a>
		s++;
  801073:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801076:	bf 00 00 00 00       	mov    $0x0,%edi
  80107b:	eb 11                	jmp    80108e <strtol+0x3b>
  80107d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801082:	3c 2d                	cmp    $0x2d,%al
  801084:	75 08                	jne    80108e <strtol+0x3b>
		s++, neg = 1;
  801086:	83 c1 01             	add    $0x1,%ecx
  801089:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80108e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801094:	75 15                	jne    8010ab <strtol+0x58>
  801096:	80 39 30             	cmpb   $0x30,(%ecx)
  801099:	75 10                	jne    8010ab <strtol+0x58>
  80109b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80109f:	75 7c                	jne    80111d <strtol+0xca>
		s += 2, base = 16;
  8010a1:	83 c1 02             	add    $0x2,%ecx
  8010a4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010a9:	eb 16                	jmp    8010c1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8010ab:	85 db                	test   %ebx,%ebx
  8010ad:	75 12                	jne    8010c1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8010af:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8010b4:	80 39 30             	cmpb   $0x30,(%ecx)
  8010b7:	75 08                	jne    8010c1 <strtol+0x6e>
		s++, base = 8;
  8010b9:	83 c1 01             	add    $0x1,%ecx
  8010bc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8010c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010c9:	0f b6 11             	movzbl (%ecx),%edx
  8010cc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010cf:	89 f3                	mov    %esi,%ebx
  8010d1:	80 fb 09             	cmp    $0x9,%bl
  8010d4:	77 08                	ja     8010de <strtol+0x8b>
			dig = *s - '0';
  8010d6:	0f be d2             	movsbl %dl,%edx
  8010d9:	83 ea 30             	sub    $0x30,%edx
  8010dc:	eb 22                	jmp    801100 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8010de:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010e1:	89 f3                	mov    %esi,%ebx
  8010e3:	80 fb 19             	cmp    $0x19,%bl
  8010e6:	77 08                	ja     8010f0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8010e8:	0f be d2             	movsbl %dl,%edx
  8010eb:	83 ea 57             	sub    $0x57,%edx
  8010ee:	eb 10                	jmp    801100 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8010f0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010f3:	89 f3                	mov    %esi,%ebx
  8010f5:	80 fb 19             	cmp    $0x19,%bl
  8010f8:	77 16                	ja     801110 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8010fa:	0f be d2             	movsbl %dl,%edx
  8010fd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801100:	3b 55 10             	cmp    0x10(%ebp),%edx
  801103:	7d 0b                	jge    801110 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801105:	83 c1 01             	add    $0x1,%ecx
  801108:	0f af 45 10          	imul   0x10(%ebp),%eax
  80110c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80110e:	eb b9                	jmp    8010c9 <strtol+0x76>

	if (endptr)
  801110:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801114:	74 0d                	je     801123 <strtol+0xd0>
		*endptr = (char *) s;
  801116:	8b 75 0c             	mov    0xc(%ebp),%esi
  801119:	89 0e                	mov    %ecx,(%esi)
  80111b:	eb 06                	jmp    801123 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80111d:	85 db                	test   %ebx,%ebx
  80111f:	74 98                	je     8010b9 <strtol+0x66>
  801121:	eb 9e                	jmp    8010c1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801123:	89 c2                	mov    %eax,%edx
  801125:	f7 da                	neg    %edx
  801127:	85 ff                	test   %edi,%edi
  801129:	0f 45 c2             	cmovne %edx,%eax
}
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5f                   	pop    %edi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	57                   	push   %edi
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
  80113c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113f:	8b 55 08             	mov    0x8(%ebp),%edx
  801142:	89 c3                	mov    %eax,%ebx
  801144:	89 c7                	mov    %eax,%edi
  801146:	89 c6                	mov    %eax,%esi
  801148:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80114a:	5b                   	pop    %ebx
  80114b:	5e                   	pop    %esi
  80114c:	5f                   	pop    %edi
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <sys_cgetc>:

int
sys_cgetc(void)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	57                   	push   %edi
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801155:	ba 00 00 00 00       	mov    $0x0,%edx
  80115a:	b8 01 00 00 00       	mov    $0x1,%eax
  80115f:	89 d1                	mov    %edx,%ecx
  801161:	89 d3                	mov    %edx,%ebx
  801163:	89 d7                	mov    %edx,%edi
  801165:	89 d6                	mov    %edx,%esi
  801167:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801169:	5b                   	pop    %ebx
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801177:	b9 00 00 00 00       	mov    $0x0,%ecx
  80117c:	b8 03 00 00 00       	mov    $0x3,%eax
  801181:	8b 55 08             	mov    0x8(%ebp),%edx
  801184:	89 cb                	mov    %ecx,%ebx
  801186:	89 cf                	mov    %ecx,%edi
  801188:	89 ce                	mov    %ecx,%esi
  80118a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80118c:	85 c0                	test   %eax,%eax
  80118e:	7e 17                	jle    8011a7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801190:	83 ec 0c             	sub    $0xc,%esp
  801193:	50                   	push   %eax
  801194:	6a 03                	push   $0x3
  801196:	68 df 30 80 00       	push   $0x8030df
  80119b:	6a 23                	push   $0x23
  80119d:	68 fc 30 80 00       	push   $0x8030fc
  8011a2:	e8 e5 f5 ff ff       	call   80078c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5f                   	pop    %edi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ba:	b8 02 00 00 00       	mov    $0x2,%eax
  8011bf:	89 d1                	mov    %edx,%ecx
  8011c1:	89 d3                	mov    %edx,%ebx
  8011c3:	89 d7                	mov    %edx,%edi
  8011c5:	89 d6                	mov    %edx,%esi
  8011c7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <sys_yield>:

void
sys_yield(void)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011de:	89 d1                	mov    %edx,%ecx
  8011e0:	89 d3                	mov    %edx,%ebx
  8011e2:	89 d7                	mov    %edx,%edi
  8011e4:	89 d6                	mov    %edx,%esi
  8011e6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	57                   	push   %edi
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f6:	be 00 00 00 00       	mov    $0x0,%esi
  8011fb:	b8 04 00 00 00       	mov    $0x4,%eax
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	8b 55 08             	mov    0x8(%ebp),%edx
  801206:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801209:	89 f7                	mov    %esi,%edi
  80120b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80120d:	85 c0                	test   %eax,%eax
  80120f:	7e 17                	jle    801228 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801211:	83 ec 0c             	sub    $0xc,%esp
  801214:	50                   	push   %eax
  801215:	6a 04                	push   $0x4
  801217:	68 df 30 80 00       	push   $0x8030df
  80121c:	6a 23                	push   $0x23
  80121e:	68 fc 30 80 00       	push   $0x8030fc
  801223:	e8 64 f5 ff ff       	call   80078c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801228:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801239:	b8 05 00 00 00       	mov    $0x5,%eax
  80123e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801241:	8b 55 08             	mov    0x8(%ebp),%edx
  801244:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801247:	8b 7d 14             	mov    0x14(%ebp),%edi
  80124a:	8b 75 18             	mov    0x18(%ebp),%esi
  80124d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80124f:	85 c0                	test   %eax,%eax
  801251:	7e 17                	jle    80126a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801253:	83 ec 0c             	sub    $0xc,%esp
  801256:	50                   	push   %eax
  801257:	6a 05                	push   $0x5
  801259:	68 df 30 80 00       	push   $0x8030df
  80125e:	6a 23                	push   $0x23
  801260:	68 fc 30 80 00       	push   $0x8030fc
  801265:	e8 22 f5 ff ff       	call   80078c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80126a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126d:	5b                   	pop    %ebx
  80126e:	5e                   	pop    %esi
  80126f:	5f                   	pop    %edi
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	57                   	push   %edi
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
  801278:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801280:	b8 06 00 00 00       	mov    $0x6,%eax
  801285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801288:	8b 55 08             	mov    0x8(%ebp),%edx
  80128b:	89 df                	mov    %ebx,%edi
  80128d:	89 de                	mov    %ebx,%esi
  80128f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801291:	85 c0                	test   %eax,%eax
  801293:	7e 17                	jle    8012ac <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801295:	83 ec 0c             	sub    $0xc,%esp
  801298:	50                   	push   %eax
  801299:	6a 06                	push   $0x6
  80129b:	68 df 30 80 00       	push   $0x8030df
  8012a0:	6a 23                	push   $0x23
  8012a2:	68 fc 30 80 00       	push   $0x8030fc
  8012a7:	e8 e0 f4 ff ff       	call   80078c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8012ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012af:	5b                   	pop    %ebx
  8012b0:	5e                   	pop    %esi
  8012b1:	5f                   	pop    %edi
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    

008012b4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	57                   	push   %edi
  8012b8:	56                   	push   %esi
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c2:	b8 08 00 00 00       	mov    $0x8,%eax
  8012c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cd:	89 df                	mov    %ebx,%edi
  8012cf:	89 de                	mov    %ebx,%esi
  8012d1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	7e 17                	jle    8012ee <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	50                   	push   %eax
  8012db:	6a 08                	push   $0x8
  8012dd:	68 df 30 80 00       	push   $0x8030df
  8012e2:	6a 23                	push   $0x23
  8012e4:	68 fc 30 80 00       	push   $0x8030fc
  8012e9:	e8 9e f4 ff ff       	call   80078c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f1:	5b                   	pop    %ebx
  8012f2:	5e                   	pop    %esi
  8012f3:	5f                   	pop    %edi
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801304:	b8 09 00 00 00       	mov    $0x9,%eax
  801309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80130c:	8b 55 08             	mov    0x8(%ebp),%edx
  80130f:	89 df                	mov    %ebx,%edi
  801311:	89 de                	mov    %ebx,%esi
  801313:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801315:	85 c0                	test   %eax,%eax
  801317:	7e 17                	jle    801330 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801319:	83 ec 0c             	sub    $0xc,%esp
  80131c:	50                   	push   %eax
  80131d:	6a 09                	push   $0x9
  80131f:	68 df 30 80 00       	push   $0x8030df
  801324:	6a 23                	push   $0x23
  801326:	68 fc 30 80 00       	push   $0x8030fc
  80132b:	e8 5c f4 ff ff       	call   80078c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801330:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5f                   	pop    %edi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	57                   	push   %edi
  80133c:	56                   	push   %esi
  80133d:	53                   	push   %ebx
  80133e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801341:	bb 00 00 00 00       	mov    $0x0,%ebx
  801346:	b8 0a 00 00 00       	mov    $0xa,%eax
  80134b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80134e:	8b 55 08             	mov    0x8(%ebp),%edx
  801351:	89 df                	mov    %ebx,%edi
  801353:	89 de                	mov    %ebx,%esi
  801355:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801357:	85 c0                	test   %eax,%eax
  801359:	7e 17                	jle    801372 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80135b:	83 ec 0c             	sub    $0xc,%esp
  80135e:	50                   	push   %eax
  80135f:	6a 0a                	push   $0xa
  801361:	68 df 30 80 00       	push   $0x8030df
  801366:	6a 23                	push   $0x23
  801368:	68 fc 30 80 00       	push   $0x8030fc
  80136d:	e8 1a f4 ff ff       	call   80078c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5f                   	pop    %edi
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	57                   	push   %edi
  80137e:	56                   	push   %esi
  80137f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801380:	be 00 00 00 00       	mov    $0x0,%esi
  801385:	b8 0c 00 00 00       	mov    $0xc,%eax
  80138a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80138d:	8b 55 08             	mov    0x8(%ebp),%edx
  801390:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801393:	8b 7d 14             	mov    0x14(%ebp),%edi
  801396:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	57                   	push   %edi
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013ab:	b8 0d 00 00 00       	mov    $0xd,%eax
  8013b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b3:	89 cb                	mov    %ecx,%ebx
  8013b5:	89 cf                	mov    %ecx,%edi
  8013b7:	89 ce                	mov    %ecx,%esi
  8013b9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	7e 17                	jle    8013d6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013bf:	83 ec 0c             	sub    $0xc,%esp
  8013c2:	50                   	push   %eax
  8013c3:	6a 0d                	push   $0xd
  8013c5:	68 df 30 80 00       	push   $0x8030df
  8013ca:	6a 23                	push   $0x23
  8013cc:	68 fc 30 80 00       	push   $0x8030fc
  8013d1:	e8 b6 f3 ff ff       	call   80078c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	57                   	push   %edi
  8013e2:	56                   	push   %esi
  8013e3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e9:	b8 0e 00 00 00       	mov    $0xe,%eax
  8013ee:	89 d1                	mov    %edx,%ecx
  8013f0:	89 d3                	mov    %edx,%ebx
  8013f2:	89 d7                	mov    %edx,%edi
  8013f4:	89 d6                	mov    %edx,%esi
  8013f6:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8013f8:	5b                   	pop    %ebx
  8013f9:	5e                   	pop    %esi
  8013fa:	5f                   	pop    %edi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	53                   	push   %ebx
  801401:	83 ec 04             	sub    $0x4,%esp
	int r;
	void * address = (void *)(pn*PGSIZE);
  801404:	89 d3                	mov    %edx,%ebx
  801406:	c1 e3 0c             	shl    $0xc,%ebx
	
	if((uvpt[pn] & PTE_SHARE))
  801409:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801410:	f6 c5 04             	test   $0x4,%ch
  801413:	74 38                	je     80144d <duppage+0x50>
	{
		if ((r = sys_page_map(0, address, envid, address, (uvpt[pn] | PTE_SYSCALL))) < 0)
  801415:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80141c:	83 ec 0c             	sub    $0xc,%esp
  80141f:	81 ca 07 0e 00 00    	or     $0xe07,%edx
  801425:	52                   	push   %edx
  801426:	53                   	push   %ebx
  801427:	50                   	push   %eax
  801428:	53                   	push   %ebx
  801429:	6a 00                	push   $0x0
  80142b:	e8 00 fe ff ff       	call   801230 <sys_page_map>
  801430:	83 c4 20             	add    $0x20,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	0f 89 b8 00 00 00    	jns    8014f3 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  80143b:	50                   	push   %eax
  80143c:	68 b8 2c 80 00       	push   $0x802cb8
  801441:	6a 4e                	push   $0x4e
  801443:	68 0a 31 80 00       	push   $0x80310a
  801448:	e8 3f f3 ff ff       	call   80078c <_panic>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  80144d:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801454:	f6 c1 02             	test   $0x2,%cl
  801457:	75 0c                	jne    801465 <duppage+0x68>
  801459:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801460:	f6 c5 08             	test   $0x8,%ch
  801463:	74 57                	je     8014bc <duppage+0xbf>
	{
		int perm = 0;
		perm |= PTE_P|PTE_U|PTE_COW;
	
		if ((r = sys_page_map(0, address, envid, address, perm)) < 0)
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	68 05 08 00 00       	push   $0x805
  80146d:	53                   	push   %ebx
  80146e:	50                   	push   %eax
  80146f:	53                   	push   %ebx
  801470:	6a 00                	push   $0x0
  801472:	e8 b9 fd ff ff       	call   801230 <sys_page_map>
  801477:	83 c4 20             	add    $0x20,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	79 12                	jns    801490 <duppage+0x93>
			panic("sys_page_map: %e", r);
  80147e:	50                   	push   %eax
  80147f:	68 b8 2c 80 00       	push   $0x802cb8
  801484:	6a 56                	push   $0x56
  801486:	68 0a 31 80 00       	push   $0x80310a
  80148b:	e8 fc f2 ff ff       	call   80078c <_panic>
		if ((r = sys_page_map(0, address, 0, address, perm)) < 0)
  801490:	83 ec 0c             	sub    $0xc,%esp
  801493:	68 05 08 00 00       	push   $0x805
  801498:	53                   	push   %ebx
  801499:	6a 00                	push   $0x0
  80149b:	53                   	push   %ebx
  80149c:	6a 00                	push   $0x0
  80149e:	e8 8d fd ff ff       	call   801230 <sys_page_map>
  8014a3:	83 c4 20             	add    $0x20,%esp
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	79 49                	jns    8014f3 <duppage+0xf6>
			panic("sys_page_map: %e", r);
  8014aa:	50                   	push   %eax
  8014ab:	68 b8 2c 80 00       	push   $0x802cb8
  8014b0:	6a 58                	push   $0x58
  8014b2:	68 0a 31 80 00       	push   $0x80310a
  8014b7:	e8 d0 f2 ff ff       	call   80078c <_panic>
	}
	else if((uvpt[pn] & ~PTE_U) == 0)
  8014bc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014c3:	f7 c2 fb ff ff ff    	test   $0xfffffffb,%edx
  8014c9:	75 28                	jne    8014f3 <duppage+0xf6>
	{
		//cprintf("im here");
		if ((r = sys_page_map(0, address, envid, address, PTE_P|PTE_U)) < 0)
  8014cb:	83 ec 0c             	sub    $0xc,%esp
  8014ce:	6a 05                	push   $0x5
  8014d0:	53                   	push   %ebx
  8014d1:	50                   	push   %eax
  8014d2:	53                   	push   %ebx
  8014d3:	6a 00                	push   $0x0
  8014d5:	e8 56 fd ff ff       	call   801230 <sys_page_map>
  8014da:	83 c4 20             	add    $0x20,%esp
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	79 12                	jns    8014f3 <duppage+0xf6>
			panic("sys_page_map: %e", r);	
  8014e1:	50                   	push   %eax
  8014e2:	68 b8 2c 80 00       	push   $0x802cb8
  8014e7:	6a 5e                	push   $0x5e
  8014e9:	68 0a 31 80 00       	push   $0x80310a
  8014ee:	e8 99 f2 ff ff       	call   80078c <_panic>
	}
	return 0;
}
  8014f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fb:	c9                   	leave  
  8014fc:	c3                   	ret    

008014fd <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	53                   	push   %ebx
  801501:	83 ec 08             	sub    $0x8,%esp
	void *addr = (void *) utf->utf_fault_va;
  801504:	8b 45 08             	mov    0x8(%ebp),%eax
  801507:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	unsigned pn = ((uint32_t)addr)/PGSIZE;
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	c1 e8 0c             	shr    $0xc,%eax
	pte_t pte = uvpt[pn];
  80150e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// Allocate a new page, mapped at temp location
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801515:	6a 07                	push   $0x7
  801517:	68 00 f0 7f 00       	push   $0x7ff000
  80151c:	6a 00                	push   $0x0
  80151e:	e8 ca fc ff ff       	call   8011ed <sys_page_alloc>
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	79 12                	jns    80153c <pgfault+0x3f>
		panic("sys_page_alloc: %e", r);
  80152a:	50                   	push   %eax
  80152b:	68 15 31 80 00       	push   $0x803115
  801530:	6a 2b                	push   $0x2b
  801532:	68 0a 31 80 00       	push   $0x80310a
  801537:	e8 50 f2 ff ff       	call   80078c <_panic>

	// Copy the data from the old page to this new page
	void *addr_pgstart = (void *) ROUNDDOWN(addr, PGSIZE);
  80153c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr_pgstart, PGSIZE);
  801542:	83 ec 04             	sub    $0x4,%esp
  801545:	68 00 10 00 00       	push   $0x1000
  80154a:	53                   	push   %ebx
  80154b:	68 00 f0 7f 00       	push   $0x7ff000
  801550:	e8 27 fa ff ff       	call   800f7c <memmove>

	// Move the new page to the old page's address
	if ((r = sys_page_map(0, PFTEMP, 0, addr_pgstart, PTE_P|PTE_U|PTE_W)) < 0)
  801555:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80155c:	53                   	push   %ebx
  80155d:	6a 00                	push   $0x0
  80155f:	68 00 f0 7f 00       	push   $0x7ff000
  801564:	6a 00                	push   $0x0
  801566:	e8 c5 fc ff ff       	call   801230 <sys_page_map>
  80156b:	83 c4 20             	add    $0x20,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	79 12                	jns    801584 <pgfault+0x87>
		panic("sys_page_map: %e", r);
  801572:	50                   	push   %eax
  801573:	68 b8 2c 80 00       	push   $0x802cb8
  801578:	6a 33                	push   $0x33
  80157a:	68 0a 31 80 00       	push   $0x80310a
  80157f:	e8 08 f2 ff ff       	call   80078c <_panic>

	// Unmap the temp location
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)
  801584:	83 ec 08             	sub    $0x8,%esp
  801587:	68 00 f0 7f 00       	push   $0x7ff000
  80158c:	6a 00                	push   $0x0
  80158e:	e8 df fc ff ff       	call   801272 <sys_page_unmap>
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	85 c0                	test   %eax,%eax
  801598:	79 12                	jns    8015ac <pgfault+0xaf>
		panic("sys_page_unmap: %e", r);
  80159a:	50                   	push   %eax
  80159b:	68 28 31 80 00       	push   $0x803128
  8015a0:	6a 37                	push   $0x37
  8015a2:	68 0a 31 80 00       	push   $0x80310a
  8015a7:	e8 e0 f1 ff ff       	call   80078c <_panic>
}
  8015ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	56                   	push   %esi
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	// Set up page fault handler
	set_pgfault_handler(&pgfault);
  8015b9:	68 fd 14 80 00       	push   $0x8014fd
  8015be:	e8 53 13 00 00       	call   802916 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8015c3:	b8 07 00 00 00       	mov    $0x7,%eax
  8015c8:	cd 30                	int    $0x30

	// Create child
	envid_t envid = sys_exofork();
  8015ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (envid < 0) {
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	79 12                	jns    8015e6 <fork+0x35>
		panic("sys_exofork: %e", envid);
  8015d4:	50                   	push   %eax
  8015d5:	68 3b 31 80 00       	push   $0x80313b
  8015da:	6a 7c                	push   $0x7c
  8015dc:	68 0a 31 80 00       	push   $0x80310a
  8015e1:	e8 a6 f1 ff ff       	call   80078c <_panic>
		return envid;
	}
	if (envid == 0) {
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	75 1e                	jne    801608 <fork+0x57>
		// We are the child.
		thisenv = &envs[ENVX(sys_getenvid())]; // Fix thisenv
  8015ea:	e8 c0 fb ff ff       	call   8011af <sys_getenvid>
  8015ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8015f4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8015fc:	a3 20 50 80 00       	mov    %eax,0x805020
		return 0;
  801601:	b8 00 00 00 00       	mov    $0x0,%eax
  801606:	eb 7d                	jmp    801685 <fork+0xd4>

	// Set page fault handler on the child.
	// The parent needs to do it, else the child wouldn't be able to handle
	// the fault when trying to access it's stack (which happens as soon it starts)
	extern void _pgfault_upcall(void);
	sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801608:	83 ec 04             	sub    $0x4,%esp
  80160b:	6a 07                	push   $0x7
  80160d:	68 00 f0 bf ee       	push   $0xeebff000
  801612:	50                   	push   %eax
  801613:	e8 d5 fb ff ff       	call   8011ed <sys_page_alloc>
	sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  801618:	83 c4 08             	add    $0x8,%esp
  80161b:	68 5b 29 80 00       	push   $0x80295b
  801620:	ff 75 f4             	pushl  -0xc(%ebp)
  801623:	e8 10 fd ff ff       	call   801338 <sys_env_set_pgfault_upcall>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801628:	be 04 80 80 00       	mov    $0x808004,%esi
  80162d:	c1 ee 0c             	shr    $0xc,%esi
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	bb 00 08 00 00       	mov    $0x800,%ebx
  801638:	eb 0d                	jmp    801647 <fork+0x96>
		duppage(envid, pn);
  80163a:	89 da                	mov    %ebx,%edx
  80163c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163f:	e8 b9 fd ff ff       	call   8013fd <duppage>

	// We are the parent.
	// Copy our address space to child
	unsigned pn;
	extern unsigned char end[];
	for (pn = UTEXT/PGSIZE; pn <= ((uint32_t)end)/PGSIZE; pn++) {
  801644:	83 c3 01             	add    $0x1,%ebx
  801647:	39 f3                	cmp    %esi,%ebx
  801649:	76 ef                	jbe    80163a <fork+0x89>
	}

	// Also copy the stack we are currently running on
	// I think it should loop from ustacktop to this page, since the stack
	// can have more than 1 page
	duppage(envid, ((uint32_t) &envid)/PGSIZE);
  80164b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80164e:	c1 ea 0c             	shr    $0xc,%edx
  801651:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801654:	e8 a4 fd ff ff       	call   8013fd <duppage>

	// Start the child environmnet running
	int r;
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  801659:	83 ec 08             	sub    $0x8,%esp
  80165c:	6a 02                	push   $0x2
  80165e:	ff 75 f4             	pushl  -0xc(%ebp)
  801661:	e8 4e fc ff ff       	call   8012b4 <sys_env_set_status>
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	79 15                	jns    801682 <fork+0xd1>
		panic("sys_env_set_status: %e", r);
  80166d:	50                   	push   %eax
  80166e:	68 4b 31 80 00       	push   $0x80314b
  801673:	68 9c 00 00 00       	push   $0x9c
  801678:	68 0a 31 80 00       	push   $0x80310a
  80167d:	e8 0a f1 ff ff       	call   80078c <_panic>
		return r;
	}

	return envid;
  801682:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801685:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801688:	5b                   	pop    %ebx
  801689:	5e                   	pop    %esi
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <sfork>:

// Challenge!
int
sfork(void)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801692:	68 62 31 80 00       	push   $0x803162
  801697:	68 a7 00 00 00       	push   $0xa7
  80169c:	68 0a 31 80 00       	push   $0x80310a
  8016a1:	e8 e6 f0 ff ff       	call   80078c <_panic>

008016a6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	56                   	push   %esi
  8016aa:	53                   	push   %ebx
  8016ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	void *va;

	if (pg) {
  8016b4:	85 c0                	test   %eax,%eax
		va = pg;
	} else {
		va = (void *) KERNBASE;
  8016b6:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
  8016bb:	0f 44 c2             	cmove  %edx,%eax
	}

	r = sys_ipc_recv(va);
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	50                   	push   %eax
  8016c2:	e8 d6 fc ff ff       	call   80139d <sys_ipc_recv>

	if (r < 0) {
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	79 16                	jns    8016e4 <ipc_recv+0x3e>
		if (from_env_store)
  8016ce:	85 f6                	test   %esi,%esi
  8016d0:	74 06                	je     8016d8 <ipc_recv+0x32>
			*from_env_store = 0;
  8016d2:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

		if (perm_store)
  8016d8:	85 db                	test   %ebx,%ebx
  8016da:	74 2c                	je     801708 <ipc_recv+0x62>
			*perm_store = 0;
  8016dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016e2:	eb 24                	jmp    801708 <ipc_recv+0x62>

		return r;
	} else {
		if (from_env_store)
  8016e4:	85 f6                	test   %esi,%esi
  8016e6:	74 0a                	je     8016f2 <ipc_recv+0x4c>
			*from_env_store = thisenv->env_ipc_from;
  8016e8:	a1 20 50 80 00       	mov    0x805020,%eax
  8016ed:	8b 40 74             	mov    0x74(%eax),%eax
  8016f0:	89 06                	mov    %eax,(%esi)

		if (perm_store)
  8016f2:	85 db                	test   %ebx,%ebx
  8016f4:	74 0a                	je     801700 <ipc_recv+0x5a>
			*perm_store = thisenv->env_ipc_perm;
  8016f6:	a1 20 50 80 00       	mov    0x805020,%eax
  8016fb:	8b 40 78             	mov    0x78(%eax),%eax
  8016fe:	89 03                	mov    %eax,(%ebx)

		return thisenv->env_ipc_value;
  801700:	a1 20 50 80 00       	mov    0x805020,%eax
  801705:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801708:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	57                   	push   %edi
  801713:	56                   	push   %esi
  801714:	53                   	push   %ebx
  801715:	83 ec 0c             	sub    $0xc,%esp
  801718:	8b 7d 08             	mov    0x8(%ebp),%edi
  80171b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80171e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	void *va;
	if (pg) {
  801721:	85 db                	test   %ebx,%ebx
		va = pg;
	} else {
		va = (void *) KERNBASE;
  801723:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
  801728:	0f 44 d8             	cmove  %eax,%ebx
	}

	int r = -1;
	while (r < 0) {
		r = sys_ipc_try_send(to_env, val, va, perm);
  80172b:	ff 75 14             	pushl  0x14(%ebp)
  80172e:	53                   	push   %ebx
  80172f:	56                   	push   %esi
  801730:	57                   	push   %edi
  801731:	e8 44 fc ff ff       	call   80137a <sys_ipc_try_send>
		if (r == -E_IPC_NOT_RECV) {
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80173c:	75 07                	jne    801745 <ipc_send+0x36>
			sys_yield();
  80173e:	e8 8b fa ff ff       	call   8011ce <sys_yield>
  801743:	eb e6                	jmp    80172b <ipc_send+0x1c>
		} else if (r < 0) {
  801745:	85 c0                	test   %eax,%eax
  801747:	79 12                	jns    80175b <ipc_send+0x4c>
			panic("ipc_send: %e", r);
  801749:	50                   	push   %eax
  80174a:	68 78 31 80 00       	push   $0x803178
  80174f:	6a 51                	push   $0x51
  801751:	68 85 31 80 00       	push   $0x803185
  801756:	e8 31 f0 ff ff       	call   80078c <_panic>
		}
	}
}
  80175b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5f                   	pop    %edi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801769:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80176e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801771:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801777:	8b 52 50             	mov    0x50(%edx),%edx
  80177a:	39 ca                	cmp    %ecx,%edx
  80177c:	75 0d                	jne    80178b <ipc_find_env+0x28>
			return envs[i].env_id;
  80177e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801781:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801786:	8b 40 48             	mov    0x48(%eax),%eax
  801789:	eb 0f                	jmp    80179a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80178b:	83 c0 01             	add    $0x1,%eax
  80178e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801793:	75 d9                	jne    80176e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801795:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179a:	5d                   	pop    %ebp
  80179b:	c3                   	ret    

0080179c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	05 00 00 00 30       	add    $0x30000000,%eax
  8017a7:	c1 e8 0c             	shr    $0xc,%eax
}
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8017af:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8017b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8017bc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8017ce:	89 c2                	mov    %eax,%edx
  8017d0:	c1 ea 16             	shr    $0x16,%edx
  8017d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017da:	f6 c2 01             	test   $0x1,%dl
  8017dd:	74 11                	je     8017f0 <fd_alloc+0x2d>
  8017df:	89 c2                	mov    %eax,%edx
  8017e1:	c1 ea 0c             	shr    $0xc,%edx
  8017e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017eb:	f6 c2 01             	test   $0x1,%dl
  8017ee:	75 09                	jne    8017f9 <fd_alloc+0x36>
			*fd_store = fd;
  8017f0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8017f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f7:	eb 17                	jmp    801810 <fd_alloc+0x4d>
  8017f9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017fe:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801803:	75 c9                	jne    8017ce <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801805:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80180b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801810:	5d                   	pop    %ebp
  801811:	c3                   	ret    

00801812 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801818:	83 f8 1f             	cmp    $0x1f,%eax
  80181b:	77 36                	ja     801853 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80181d:	c1 e0 0c             	shl    $0xc,%eax
  801820:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801825:	89 c2                	mov    %eax,%edx
  801827:	c1 ea 16             	shr    $0x16,%edx
  80182a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801831:	f6 c2 01             	test   $0x1,%dl
  801834:	74 24                	je     80185a <fd_lookup+0x48>
  801836:	89 c2                	mov    %eax,%edx
  801838:	c1 ea 0c             	shr    $0xc,%edx
  80183b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801842:	f6 c2 01             	test   $0x1,%dl
  801845:	74 1a                	je     801861 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80184a:	89 02                	mov    %eax,(%edx)
	return 0;
  80184c:	b8 00 00 00 00       	mov    $0x0,%eax
  801851:	eb 13                	jmp    801866 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801858:	eb 0c                	jmp    801866 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80185a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185f:	eb 05                	jmp    801866 <fd_lookup+0x54>
  801861:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	83 ec 08             	sub    $0x8,%esp
  80186e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801871:	ba 10 32 80 00       	mov    $0x803210,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801876:	eb 13                	jmp    80188b <dev_lookup+0x23>
  801878:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80187b:	39 08                	cmp    %ecx,(%eax)
  80187d:	75 0c                	jne    80188b <dev_lookup+0x23>
			*dev = devtab[i];
  80187f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801882:	89 01                	mov    %eax,(%ecx)
			return 0;
  801884:	b8 00 00 00 00       	mov    $0x0,%eax
  801889:	eb 2e                	jmp    8018b9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80188b:	8b 02                	mov    (%edx),%eax
  80188d:	85 c0                	test   %eax,%eax
  80188f:	75 e7                	jne    801878 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801891:	a1 20 50 80 00       	mov    0x805020,%eax
  801896:	8b 40 48             	mov    0x48(%eax),%eax
  801899:	83 ec 04             	sub    $0x4,%esp
  80189c:	51                   	push   %ecx
  80189d:	50                   	push   %eax
  80189e:	68 90 31 80 00       	push   $0x803190
  8018a3:	e8 bd ef ff ff       	call   800865 <cprintf>
	*dev = 0;
  8018a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 10             	sub    $0x10,%esp
  8018c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8018c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018cc:	50                   	push   %eax
  8018cd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8018d3:	c1 e8 0c             	shr    $0xc,%eax
  8018d6:	50                   	push   %eax
  8018d7:	e8 36 ff ff ff       	call   801812 <fd_lookup>
  8018dc:	83 c4 08             	add    $0x8,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 05                	js     8018e8 <fd_close+0x2d>
	    || fd != fd2)
  8018e3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8018e6:	74 0c                	je     8018f4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8018e8:	84 db                	test   %bl,%bl
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	0f 44 c2             	cmove  %edx,%eax
  8018f2:	eb 41                	jmp    801935 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018fa:	50                   	push   %eax
  8018fb:	ff 36                	pushl  (%esi)
  8018fd:	e8 66 ff ff ff       	call   801868 <dev_lookup>
  801902:	89 c3                	mov    %eax,%ebx
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	78 1a                	js     801925 <fd_close+0x6a>
		if (dev->dev_close)
  80190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801911:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801916:	85 c0                	test   %eax,%eax
  801918:	74 0b                	je     801925 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	56                   	push   %esi
  80191e:	ff d0                	call   *%eax
  801920:	89 c3                	mov    %eax,%ebx
  801922:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801925:	83 ec 08             	sub    $0x8,%esp
  801928:	56                   	push   %esi
  801929:	6a 00                	push   $0x0
  80192b:	e8 42 f9 ff ff       	call   801272 <sys_page_unmap>
	return r;
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	89 d8                	mov    %ebx,%eax
}
  801935:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801938:	5b                   	pop    %ebx
  801939:	5e                   	pop    %esi
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801942:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801945:	50                   	push   %eax
  801946:	ff 75 08             	pushl  0x8(%ebp)
  801949:	e8 c4 fe ff ff       	call   801812 <fd_lookup>
  80194e:	83 c4 08             	add    $0x8,%esp
  801951:	85 c0                	test   %eax,%eax
  801953:	78 10                	js     801965 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801955:	83 ec 08             	sub    $0x8,%esp
  801958:	6a 01                	push   $0x1
  80195a:	ff 75 f4             	pushl  -0xc(%ebp)
  80195d:	e8 59 ff ff ff       	call   8018bb <fd_close>
  801962:	83 c4 10             	add    $0x10,%esp
}
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <close_all>:

void
close_all(void)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80196e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	53                   	push   %ebx
  801977:	e8 c0 ff ff ff       	call   80193c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80197c:	83 c3 01             	add    $0x1,%ebx
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	83 fb 20             	cmp    $0x20,%ebx
  801985:	75 ec                	jne    801973 <close_all+0xc>
		close(i);
}
  801987:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	57                   	push   %edi
  801990:	56                   	push   %esi
  801991:	53                   	push   %ebx
  801992:	83 ec 2c             	sub    $0x2c,%esp
  801995:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801998:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80199b:	50                   	push   %eax
  80199c:	ff 75 08             	pushl  0x8(%ebp)
  80199f:	e8 6e fe ff ff       	call   801812 <fd_lookup>
  8019a4:	83 c4 08             	add    $0x8,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	0f 88 c1 00 00 00    	js     801a70 <dup+0xe4>
		return r;
	close(newfdnum);
  8019af:	83 ec 0c             	sub    $0xc,%esp
  8019b2:	56                   	push   %esi
  8019b3:	e8 84 ff ff ff       	call   80193c <close>

	newfd = INDEX2FD(newfdnum);
  8019b8:	89 f3                	mov    %esi,%ebx
  8019ba:	c1 e3 0c             	shl    $0xc,%ebx
  8019bd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8019c3:	83 c4 04             	add    $0x4,%esp
  8019c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019c9:	e8 de fd ff ff       	call   8017ac <fd2data>
  8019ce:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8019d0:	89 1c 24             	mov    %ebx,(%esp)
  8019d3:	e8 d4 fd ff ff       	call   8017ac <fd2data>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8019de:	89 f8                	mov    %edi,%eax
  8019e0:	c1 e8 16             	shr    $0x16,%eax
  8019e3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019ea:	a8 01                	test   $0x1,%al
  8019ec:	74 37                	je     801a25 <dup+0x99>
  8019ee:	89 f8                	mov    %edi,%eax
  8019f0:	c1 e8 0c             	shr    $0xc,%eax
  8019f3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019fa:	f6 c2 01             	test   $0x1,%dl
  8019fd:	74 26                	je     801a25 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a06:	83 ec 0c             	sub    $0xc,%esp
  801a09:	25 07 0e 00 00       	and    $0xe07,%eax
  801a0e:	50                   	push   %eax
  801a0f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801a12:	6a 00                	push   $0x0
  801a14:	57                   	push   %edi
  801a15:	6a 00                	push   $0x0
  801a17:	e8 14 f8 ff ff       	call   801230 <sys_page_map>
  801a1c:	89 c7                	mov    %eax,%edi
  801a1e:	83 c4 20             	add    $0x20,%esp
  801a21:	85 c0                	test   %eax,%eax
  801a23:	78 2e                	js     801a53 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a25:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a28:	89 d0                	mov    %edx,%eax
  801a2a:	c1 e8 0c             	shr    $0xc,%eax
  801a2d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a34:	83 ec 0c             	sub    $0xc,%esp
  801a37:	25 07 0e 00 00       	and    $0xe07,%eax
  801a3c:	50                   	push   %eax
  801a3d:	53                   	push   %ebx
  801a3e:	6a 00                	push   $0x0
  801a40:	52                   	push   %edx
  801a41:	6a 00                	push   $0x0
  801a43:	e8 e8 f7 ff ff       	call   801230 <sys_page_map>
  801a48:	89 c7                	mov    %eax,%edi
  801a4a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801a4d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a4f:	85 ff                	test   %edi,%edi
  801a51:	79 1d                	jns    801a70 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a53:	83 ec 08             	sub    $0x8,%esp
  801a56:	53                   	push   %ebx
  801a57:	6a 00                	push   $0x0
  801a59:	e8 14 f8 ff ff       	call   801272 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a5e:	83 c4 08             	add    $0x8,%esp
  801a61:	ff 75 d4             	pushl  -0x2c(%ebp)
  801a64:	6a 00                	push   $0x0
  801a66:	e8 07 f8 ff ff       	call   801272 <sys_page_unmap>
	return r;
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	89 f8                	mov    %edi,%eax
}
  801a70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a73:	5b                   	pop    %ebx
  801a74:	5e                   	pop    %esi
  801a75:	5f                   	pop    %edi
  801a76:	5d                   	pop    %ebp
  801a77:	c3                   	ret    

00801a78 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 14             	sub    $0x14,%esp
  801a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a85:	50                   	push   %eax
  801a86:	53                   	push   %ebx
  801a87:	e8 86 fd ff ff       	call   801812 <fd_lookup>
  801a8c:	83 c4 08             	add    $0x8,%esp
  801a8f:	89 c2                	mov    %eax,%edx
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 6d                	js     801b02 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a95:	83 ec 08             	sub    $0x8,%esp
  801a98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9b:	50                   	push   %eax
  801a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a9f:	ff 30                	pushl  (%eax)
  801aa1:	e8 c2 fd ff ff       	call   801868 <dev_lookup>
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	78 4c                	js     801af9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801aad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ab0:	8b 42 08             	mov    0x8(%edx),%eax
  801ab3:	83 e0 03             	and    $0x3,%eax
  801ab6:	83 f8 01             	cmp    $0x1,%eax
  801ab9:	75 21                	jne    801adc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801abb:	a1 20 50 80 00       	mov    0x805020,%eax
  801ac0:	8b 40 48             	mov    0x48(%eax),%eax
  801ac3:	83 ec 04             	sub    $0x4,%esp
  801ac6:	53                   	push   %ebx
  801ac7:	50                   	push   %eax
  801ac8:	68 d4 31 80 00       	push   $0x8031d4
  801acd:	e8 93 ed ff ff       	call   800865 <cprintf>
		return -E_INVAL;
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ada:	eb 26                	jmp    801b02 <read+0x8a>
	}
	if (!dev->dev_read)
  801adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adf:	8b 40 08             	mov    0x8(%eax),%eax
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	74 17                	je     801afd <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ae6:	83 ec 04             	sub    $0x4,%esp
  801ae9:	ff 75 10             	pushl  0x10(%ebp)
  801aec:	ff 75 0c             	pushl  0xc(%ebp)
  801aef:	52                   	push   %edx
  801af0:	ff d0                	call   *%eax
  801af2:	89 c2                	mov    %eax,%edx
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	eb 09                	jmp    801b02 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801af9:	89 c2                	mov    %eax,%edx
  801afb:	eb 05                	jmp    801b02 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801afd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801b02:	89 d0                	mov    %edx,%eax
  801b04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	57                   	push   %edi
  801b0d:	56                   	push   %esi
  801b0e:	53                   	push   %ebx
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b15:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b18:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b1d:	eb 21                	jmp    801b40 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b1f:	83 ec 04             	sub    $0x4,%esp
  801b22:	89 f0                	mov    %esi,%eax
  801b24:	29 d8                	sub    %ebx,%eax
  801b26:	50                   	push   %eax
  801b27:	89 d8                	mov    %ebx,%eax
  801b29:	03 45 0c             	add    0xc(%ebp),%eax
  801b2c:	50                   	push   %eax
  801b2d:	57                   	push   %edi
  801b2e:	e8 45 ff ff ff       	call   801a78 <read>
		if (m < 0)
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 10                	js     801b4a <readn+0x41>
			return m;
		if (m == 0)
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	74 0a                	je     801b48 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b3e:	01 c3                	add    %eax,%ebx
  801b40:	39 f3                	cmp    %esi,%ebx
  801b42:	72 db                	jb     801b1f <readn+0x16>
  801b44:	89 d8                	mov    %ebx,%eax
  801b46:	eb 02                	jmp    801b4a <readn+0x41>
  801b48:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4d:	5b                   	pop    %ebx
  801b4e:	5e                   	pop    %esi
  801b4f:	5f                   	pop    %edi
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	53                   	push   %ebx
  801b56:	83 ec 14             	sub    $0x14,%esp
  801b59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b5f:	50                   	push   %eax
  801b60:	53                   	push   %ebx
  801b61:	e8 ac fc ff ff       	call   801812 <fd_lookup>
  801b66:	83 c4 08             	add    $0x8,%esp
  801b69:	89 c2                	mov    %eax,%edx
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	78 68                	js     801bd7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b6f:	83 ec 08             	sub    $0x8,%esp
  801b72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b75:	50                   	push   %eax
  801b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b79:	ff 30                	pushl  (%eax)
  801b7b:	e8 e8 fc ff ff       	call   801868 <dev_lookup>
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 47                	js     801bce <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b8e:	75 21                	jne    801bb1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b90:	a1 20 50 80 00       	mov    0x805020,%eax
  801b95:	8b 40 48             	mov    0x48(%eax),%eax
  801b98:	83 ec 04             	sub    $0x4,%esp
  801b9b:	53                   	push   %ebx
  801b9c:	50                   	push   %eax
  801b9d:	68 f0 31 80 00       	push   $0x8031f0
  801ba2:	e8 be ec ff ff       	call   800865 <cprintf>
		return -E_INVAL;
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801baf:	eb 26                	jmp    801bd7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801bb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb4:	8b 52 0c             	mov    0xc(%edx),%edx
  801bb7:	85 d2                	test   %edx,%edx
  801bb9:	74 17                	je     801bd2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801bbb:	83 ec 04             	sub    $0x4,%esp
  801bbe:	ff 75 10             	pushl  0x10(%ebp)
  801bc1:	ff 75 0c             	pushl  0xc(%ebp)
  801bc4:	50                   	push   %eax
  801bc5:	ff d2                	call   *%edx
  801bc7:	89 c2                	mov    %eax,%edx
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	eb 09                	jmp    801bd7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bce:	89 c2                	mov    %eax,%edx
  801bd0:	eb 05                	jmp    801bd7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801bd2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801bd7:	89 d0                	mov    %edx,%eax
  801bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <seek>:

int
seek(int fdnum, off_t offset)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
  801be1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801be7:	50                   	push   %eax
  801be8:	ff 75 08             	pushl  0x8(%ebp)
  801beb:	e8 22 fc ff ff       	call   801812 <fd_lookup>
  801bf0:	83 c4 08             	add    $0x8,%esp
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	78 0e                	js     801c05 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801bf7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bfd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801c00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	53                   	push   %ebx
  801c0b:	83 ec 14             	sub    $0x14,%esp
  801c0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c14:	50                   	push   %eax
  801c15:	53                   	push   %ebx
  801c16:	e8 f7 fb ff ff       	call   801812 <fd_lookup>
  801c1b:	83 c4 08             	add    $0x8,%esp
  801c1e:	89 c2                	mov    %eax,%edx
  801c20:	85 c0                	test   %eax,%eax
  801c22:	78 65                	js     801c89 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c24:	83 ec 08             	sub    $0x8,%esp
  801c27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2a:	50                   	push   %eax
  801c2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2e:	ff 30                	pushl  (%eax)
  801c30:	e8 33 fc ff ff       	call   801868 <dev_lookup>
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	78 44                	js     801c80 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c3f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c43:	75 21                	jne    801c66 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c45:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c4a:	8b 40 48             	mov    0x48(%eax),%eax
  801c4d:	83 ec 04             	sub    $0x4,%esp
  801c50:	53                   	push   %ebx
  801c51:	50                   	push   %eax
  801c52:	68 b0 31 80 00       	push   $0x8031b0
  801c57:	e8 09 ec ff ff       	call   800865 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801c64:	eb 23                	jmp    801c89 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801c66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c69:	8b 52 18             	mov    0x18(%edx),%edx
  801c6c:	85 d2                	test   %edx,%edx
  801c6e:	74 14                	je     801c84 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c70:	83 ec 08             	sub    $0x8,%esp
  801c73:	ff 75 0c             	pushl  0xc(%ebp)
  801c76:	50                   	push   %eax
  801c77:	ff d2                	call   *%edx
  801c79:	89 c2                	mov    %eax,%edx
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	eb 09                	jmp    801c89 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c80:	89 c2                	mov    %eax,%edx
  801c82:	eb 05                	jmp    801c89 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c84:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801c89:	89 d0                	mov    %edx,%eax
  801c8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	53                   	push   %ebx
  801c94:	83 ec 14             	sub    $0x14,%esp
  801c97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c9d:	50                   	push   %eax
  801c9e:	ff 75 08             	pushl  0x8(%ebp)
  801ca1:	e8 6c fb ff ff       	call   801812 <fd_lookup>
  801ca6:	83 c4 08             	add    $0x8,%esp
  801ca9:	89 c2                	mov    %eax,%edx
  801cab:	85 c0                	test   %eax,%eax
  801cad:	78 58                	js     801d07 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801caf:	83 ec 08             	sub    $0x8,%esp
  801cb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb5:	50                   	push   %eax
  801cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb9:	ff 30                	pushl  (%eax)
  801cbb:	e8 a8 fb ff ff       	call   801868 <dev_lookup>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	78 37                	js     801cfe <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cca:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801cce:	74 32                	je     801d02 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801cd0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801cd3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801cda:	00 00 00 
	stat->st_isdir = 0;
  801cdd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ce4:	00 00 00 
	stat->st_dev = dev;
  801ce7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ced:	83 ec 08             	sub    $0x8,%esp
  801cf0:	53                   	push   %ebx
  801cf1:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf4:	ff 50 14             	call   *0x14(%eax)
  801cf7:	89 c2                	mov    %eax,%edx
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	eb 09                	jmp    801d07 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cfe:	89 c2                	mov    %eax,%edx
  801d00:	eb 05                	jmp    801d07 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801d02:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801d07:	89 d0                	mov    %edx,%eax
  801d09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	56                   	push   %esi
  801d12:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d13:	83 ec 08             	sub    $0x8,%esp
  801d16:	6a 00                	push   $0x0
  801d18:	ff 75 08             	pushl  0x8(%ebp)
  801d1b:	e8 0c 02 00 00       	call   801f2c <open>
  801d20:	89 c3                	mov    %eax,%ebx
  801d22:	83 c4 10             	add    $0x10,%esp
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 1b                	js     801d44 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801d29:	83 ec 08             	sub    $0x8,%esp
  801d2c:	ff 75 0c             	pushl  0xc(%ebp)
  801d2f:	50                   	push   %eax
  801d30:	e8 5b ff ff ff       	call   801c90 <fstat>
  801d35:	89 c6                	mov    %eax,%esi
	close(fd);
  801d37:	89 1c 24             	mov    %ebx,(%esp)
  801d3a:	e8 fd fb ff ff       	call   80193c <close>
	return r;
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	89 f0                	mov    %esi,%eax
}
  801d44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d47:	5b                   	pop    %ebx
  801d48:	5e                   	pop    %esi
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	56                   	push   %esi
  801d4f:	53                   	push   %ebx
  801d50:	89 c6                	mov    %eax,%esi
  801d52:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801d54:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  801d5b:	75 12                	jne    801d6f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d5d:	83 ec 0c             	sub    $0xc,%esp
  801d60:	6a 01                	push   $0x1
  801d62:	e8 fc f9 ff ff       	call   801763 <ipc_find_env>
  801d67:	a3 18 50 80 00       	mov    %eax,0x805018
  801d6c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d6f:	6a 07                	push   $0x7
  801d71:	68 00 60 80 00       	push   $0x806000
  801d76:	56                   	push   %esi
  801d77:	ff 35 18 50 80 00    	pushl  0x805018
  801d7d:	e8 8d f9 ff ff       	call   80170f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d82:	83 c4 0c             	add    $0xc,%esp
  801d85:	6a 00                	push   $0x0
  801d87:	53                   	push   %ebx
  801d88:	6a 00                	push   $0x0
  801d8a:	e8 17 f9 ff ff       	call   8016a6 <ipc_recv>
}
  801d8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d92:	5b                   	pop    %ebx
  801d93:	5e                   	pop    %esi
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    

00801d96 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9f:	8b 40 0c             	mov    0xc(%eax),%eax
  801da2:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801daa:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801daf:	ba 00 00 00 00       	mov    $0x0,%edx
  801db4:	b8 02 00 00 00       	mov    $0x2,%eax
  801db9:	e8 8d ff ff ff       	call   801d4b <fsipc>
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc9:	8b 40 0c             	mov    0xc(%eax),%eax
  801dcc:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801dd1:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd6:	b8 06 00 00 00       	mov    $0x6,%eax
  801ddb:	e8 6b ff ff ff       	call   801d4b <fsipc>
}
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	53                   	push   %ebx
  801de6:	83 ec 04             	sub    $0x4,%esp
  801de9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	8b 40 0c             	mov    0xc(%eax),%eax
  801df2:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801df7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dfc:	b8 05 00 00 00       	mov    $0x5,%eax
  801e01:	e8 45 ff ff ff       	call   801d4b <fsipc>
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 2c                	js     801e36 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e0a:	83 ec 08             	sub    $0x8,%esp
  801e0d:	68 00 60 80 00       	push   $0x806000
  801e12:	53                   	push   %ebx
  801e13:	e8 d2 ef ff ff       	call   800dea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e18:	a1 80 60 80 00       	mov    0x806080,%eax
  801e1d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e23:	a1 84 60 80 00       	mov    0x806084,%eax
  801e28:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e2e:	83 c4 10             	add    $0x10,%esp
  801e31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	53                   	push   %ebx
  801e3f:	83 ec 08             	sub    $0x8,%esp
  801e42:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e45:	8b 55 08             	mov    0x8(%ebp),%edx
  801e48:	8b 52 0c             	mov    0xc(%edx),%edx
  801e4b:	89 15 00 60 80 00    	mov    %edx,0x806000
  801e51:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e56:	bb f8 0f 00 00       	mov    $0xff8,%ebx
  801e5b:	0f 46 d8             	cmovbe %eax,%ebx
	
	size_t n_real = min_size(n, sizeof(fsipcbuf.write.req_buf));
	fsipcbuf.write.req_n = n_real;
  801e5e:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	
	memmove(fsipcbuf.write.req_buf, buf, n_real);
  801e64:	53                   	push   %ebx
  801e65:	ff 75 0c             	pushl  0xc(%ebp)
  801e68:	68 08 60 80 00       	push   $0x806008
  801e6d:	e8 0a f1 ff ff       	call   800f7c <memmove>

	
	int r;
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) 
  801e72:	ba 00 00 00 00       	mov    $0x0,%edx
  801e77:	b8 04 00 00 00       	mov    $0x4,%eax
  801e7c:	e8 ca fe ff ff       	call   801d4b <fsipc>
  801e81:	83 c4 10             	add    $0x10,%esp
  801e84:	85 c0                	test   %eax,%eax
  801e86:	78 1d                	js     801ea5 <devfile_write+0x6a>
		return r;
	assert(r <= n_real); 
  801e88:	39 d8                	cmp    %ebx,%eax
  801e8a:	76 19                	jbe    801ea5 <devfile_write+0x6a>
  801e8c:	68 24 32 80 00       	push   $0x803224
  801e91:	68 30 32 80 00       	push   $0x803230
  801e96:	68 a3 00 00 00       	push   $0xa3
  801e9b:	68 45 32 80 00       	push   $0x803245
  801ea0:	e8 e7 e8 ff ff       	call   80078c <_panic>
	return r;
}
  801ea5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	56                   	push   %esi
  801eae:	53                   	push   %ebx
  801eaf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb5:	8b 40 0c             	mov    0xc(%eax),%eax
  801eb8:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801ebd:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ec3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec8:	b8 03 00 00 00       	mov    $0x3,%eax
  801ecd:	e8 79 fe ff ff       	call   801d4b <fsipc>
  801ed2:	89 c3                	mov    %eax,%ebx
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	78 4b                	js     801f23 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ed8:	39 c6                	cmp    %eax,%esi
  801eda:	73 16                	jae    801ef2 <devfile_read+0x48>
  801edc:	68 50 32 80 00       	push   $0x803250
  801ee1:	68 30 32 80 00       	push   $0x803230
  801ee6:	6a 7c                	push   $0x7c
  801ee8:	68 45 32 80 00       	push   $0x803245
  801eed:	e8 9a e8 ff ff       	call   80078c <_panic>
	assert(r <= PGSIZE);
  801ef2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ef7:	7e 16                	jle    801f0f <devfile_read+0x65>
  801ef9:	68 57 32 80 00       	push   $0x803257
  801efe:	68 30 32 80 00       	push   $0x803230
  801f03:	6a 7d                	push   $0x7d
  801f05:	68 45 32 80 00       	push   $0x803245
  801f0a:	e8 7d e8 ff ff       	call   80078c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801f0f:	83 ec 04             	sub    $0x4,%esp
  801f12:	50                   	push   %eax
  801f13:	68 00 60 80 00       	push   $0x806000
  801f18:	ff 75 0c             	pushl  0xc(%ebp)
  801f1b:	e8 5c f0 ff ff       	call   800f7c <memmove>
	return r;
  801f20:	83 c4 10             	add    $0x10,%esp
}
  801f23:	89 d8                	mov    %ebx,%eax
  801f25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f28:	5b                   	pop    %ebx
  801f29:	5e                   	pop    %esi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    

00801f2c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	53                   	push   %ebx
  801f30:	83 ec 20             	sub    $0x20,%esp
  801f33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f36:	53                   	push   %ebx
  801f37:	e8 75 ee ff ff       	call   800db1 <strlen>
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f44:	7f 67                	jg     801fad <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f46:	83 ec 0c             	sub    $0xc,%esp
  801f49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4c:	50                   	push   %eax
  801f4d:	e8 71 f8 ff ff       	call   8017c3 <fd_alloc>
  801f52:	83 c4 10             	add    $0x10,%esp
		return r;
  801f55:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f57:	85 c0                	test   %eax,%eax
  801f59:	78 57                	js     801fb2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f5b:	83 ec 08             	sub    $0x8,%esp
  801f5e:	53                   	push   %ebx
  801f5f:	68 00 60 80 00       	push   $0x806000
  801f64:	e8 81 ee ff ff       	call   800dea <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6c:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f74:	b8 01 00 00 00       	mov    $0x1,%eax
  801f79:	e8 cd fd ff ff       	call   801d4b <fsipc>
  801f7e:	89 c3                	mov    %eax,%ebx
  801f80:	83 c4 10             	add    $0x10,%esp
  801f83:	85 c0                	test   %eax,%eax
  801f85:	79 14                	jns    801f9b <open+0x6f>
		fd_close(fd, 0);
  801f87:	83 ec 08             	sub    $0x8,%esp
  801f8a:	6a 00                	push   $0x0
  801f8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f8f:	e8 27 f9 ff ff       	call   8018bb <fd_close>
		return r;
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	89 da                	mov    %ebx,%edx
  801f99:	eb 17                	jmp    801fb2 <open+0x86>
	}

	return fd2num(fd);
  801f9b:	83 ec 0c             	sub    $0xc,%esp
  801f9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa1:	e8 f6 f7 ff ff       	call   80179c <fd2num>
  801fa6:	89 c2                	mov    %eax,%edx
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	eb 05                	jmp    801fb2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801fad:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801fb2:	89 d0                	mov    %edx,%eax
  801fb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb7:	c9                   	leave  
  801fb8:	c3                   	ret    

00801fb9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801fbf:	ba 00 00 00 00       	mov    $0x0,%edx
  801fc4:	b8 08 00 00 00       	mov    $0x8,%eax
  801fc9:	e8 7d fd ff ff       	call   801d4b <fsipc>
}
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801fd6:	68 63 32 80 00       	push   $0x803263
  801fdb:	ff 75 0c             	pushl  0xc(%ebp)
  801fde:	e8 07 ee ff ff       	call   800dea <strcpy>
	return 0;
}
  801fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    

00801fea <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	53                   	push   %ebx
  801fee:	83 ec 10             	sub    $0x10,%esp
  801ff1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ff4:	53                   	push   %ebx
  801ff5:	e8 92 09 00 00       	call   80298c <pageref>
  801ffa:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ffd:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  802002:	83 f8 01             	cmp    $0x1,%eax
  802005:	75 10                	jne    802017 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  802007:	83 ec 0c             	sub    $0xc,%esp
  80200a:	ff 73 0c             	pushl  0xc(%ebx)
  80200d:	e8 c0 02 00 00       	call   8022d2 <nsipc_close>
  802012:	89 c2                	mov    %eax,%edx
  802014:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  802017:	89 d0                	mov    %edx,%eax
  802019:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802024:	6a 00                	push   $0x0
  802026:	ff 75 10             	pushl  0x10(%ebp)
  802029:	ff 75 0c             	pushl  0xc(%ebp)
  80202c:	8b 45 08             	mov    0x8(%ebp),%eax
  80202f:	ff 70 0c             	pushl  0xc(%eax)
  802032:	e8 78 03 00 00       	call   8023af <nsipc_send>
}
  802037:	c9                   	leave  
  802038:	c3                   	ret    

00802039 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80203f:	6a 00                	push   $0x0
  802041:	ff 75 10             	pushl  0x10(%ebp)
  802044:	ff 75 0c             	pushl  0xc(%ebp)
  802047:	8b 45 08             	mov    0x8(%ebp),%eax
  80204a:	ff 70 0c             	pushl  0xc(%eax)
  80204d:	e8 f1 02 00 00       	call   802343 <nsipc_recv>
}
  802052:	c9                   	leave  
  802053:	c3                   	ret    

00802054 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802054:	55                   	push   %ebp
  802055:	89 e5                	mov    %esp,%ebp
  802057:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80205a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80205d:	52                   	push   %edx
  80205e:	50                   	push   %eax
  80205f:	e8 ae f7 ff ff       	call   801812 <fd_lookup>
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	85 c0                	test   %eax,%eax
  802069:	78 17                	js     802082 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80206b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80206e:	8b 0d 20 40 80 00    	mov    0x804020,%ecx
  802074:	39 08                	cmp    %ecx,(%eax)
  802076:	75 05                	jne    80207d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802078:	8b 40 0c             	mov    0xc(%eax),%eax
  80207b:	eb 05                	jmp    802082 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80207d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802082:	c9                   	leave  
  802083:	c3                   	ret    

00802084 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  802084:	55                   	push   %ebp
  802085:	89 e5                	mov    %esp,%ebp
  802087:	56                   	push   %esi
  802088:	53                   	push   %ebx
  802089:	83 ec 1c             	sub    $0x1c,%esp
  80208c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80208e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802091:	50                   	push   %eax
  802092:	e8 2c f7 ff ff       	call   8017c3 <fd_alloc>
  802097:	89 c3                	mov    %eax,%ebx
  802099:	83 c4 10             	add    $0x10,%esp
  80209c:	85 c0                	test   %eax,%eax
  80209e:	78 1b                	js     8020bb <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8020a0:	83 ec 04             	sub    $0x4,%esp
  8020a3:	68 07 04 00 00       	push   $0x407
  8020a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ab:	6a 00                	push   $0x0
  8020ad:	e8 3b f1 ff ff       	call   8011ed <sys_page_alloc>
  8020b2:	89 c3                	mov    %eax,%ebx
  8020b4:	83 c4 10             	add    $0x10,%esp
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	79 10                	jns    8020cb <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8020bb:	83 ec 0c             	sub    $0xc,%esp
  8020be:	56                   	push   %esi
  8020bf:	e8 0e 02 00 00       	call   8022d2 <nsipc_close>
		return r;
  8020c4:	83 c4 10             	add    $0x10,%esp
  8020c7:	89 d8                	mov    %ebx,%eax
  8020c9:	eb 24                	jmp    8020ef <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8020cb:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8020d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8020d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8020e0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8020e3:	83 ec 0c             	sub    $0xc,%esp
  8020e6:	50                   	push   %eax
  8020e7:	e8 b0 f6 ff ff       	call   80179c <fd2num>
  8020ec:	83 c4 10             	add    $0x10,%esp
}
  8020ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f2:	5b                   	pop    %ebx
  8020f3:	5e                   	pop    %esi
  8020f4:	5d                   	pop    %ebp
  8020f5:	c3                   	ret    

008020f6 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020f6:	55                   	push   %ebp
  8020f7:	89 e5                	mov    %esp,%ebp
  8020f9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ff:	e8 50 ff ff ff       	call   802054 <fd2sockid>
		return r;
  802104:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  802106:	85 c0                	test   %eax,%eax
  802108:	78 1f                	js     802129 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80210a:	83 ec 04             	sub    $0x4,%esp
  80210d:	ff 75 10             	pushl  0x10(%ebp)
  802110:	ff 75 0c             	pushl  0xc(%ebp)
  802113:	50                   	push   %eax
  802114:	e8 12 01 00 00       	call   80222b <nsipc_accept>
  802119:	83 c4 10             	add    $0x10,%esp
		return r;
  80211c:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80211e:	85 c0                	test   %eax,%eax
  802120:	78 07                	js     802129 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  802122:	e8 5d ff ff ff       	call   802084 <alloc_sockfd>
  802127:	89 c1                	mov    %eax,%ecx
}
  802129:	89 c8                	mov    %ecx,%eax
  80212b:	c9                   	leave  
  80212c:	c3                   	ret    

0080212d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80212d:	55                   	push   %ebp
  80212e:	89 e5                	mov    %esp,%ebp
  802130:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802133:	8b 45 08             	mov    0x8(%ebp),%eax
  802136:	e8 19 ff ff ff       	call   802054 <fd2sockid>
  80213b:	85 c0                	test   %eax,%eax
  80213d:	78 12                	js     802151 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80213f:	83 ec 04             	sub    $0x4,%esp
  802142:	ff 75 10             	pushl  0x10(%ebp)
  802145:	ff 75 0c             	pushl  0xc(%ebp)
  802148:	50                   	push   %eax
  802149:	e8 2d 01 00 00       	call   80227b <nsipc_bind>
  80214e:	83 c4 10             	add    $0x10,%esp
}
  802151:	c9                   	leave  
  802152:	c3                   	ret    

00802153 <shutdown>:

int
shutdown(int s, int how)
{
  802153:	55                   	push   %ebp
  802154:	89 e5                	mov    %esp,%ebp
  802156:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802159:	8b 45 08             	mov    0x8(%ebp),%eax
  80215c:	e8 f3 fe ff ff       	call   802054 <fd2sockid>
  802161:	85 c0                	test   %eax,%eax
  802163:	78 0f                	js     802174 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802165:	83 ec 08             	sub    $0x8,%esp
  802168:	ff 75 0c             	pushl  0xc(%ebp)
  80216b:	50                   	push   %eax
  80216c:	e8 3f 01 00 00       	call   8022b0 <nsipc_shutdown>
  802171:	83 c4 10             	add    $0x10,%esp
}
  802174:	c9                   	leave  
  802175:	c3                   	ret    

00802176 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80217c:	8b 45 08             	mov    0x8(%ebp),%eax
  80217f:	e8 d0 fe ff ff       	call   802054 <fd2sockid>
  802184:	85 c0                	test   %eax,%eax
  802186:	78 12                	js     80219a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  802188:	83 ec 04             	sub    $0x4,%esp
  80218b:	ff 75 10             	pushl  0x10(%ebp)
  80218e:	ff 75 0c             	pushl  0xc(%ebp)
  802191:	50                   	push   %eax
  802192:	e8 55 01 00 00       	call   8022ec <nsipc_connect>
  802197:	83 c4 10             	add    $0x10,%esp
}
  80219a:	c9                   	leave  
  80219b:	c3                   	ret    

0080219c <listen>:

int
listen(int s, int backlog)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a5:	e8 aa fe ff ff       	call   802054 <fd2sockid>
  8021aa:	85 c0                	test   %eax,%eax
  8021ac:	78 0f                	js     8021bd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8021ae:	83 ec 08             	sub    $0x8,%esp
  8021b1:	ff 75 0c             	pushl  0xc(%ebp)
  8021b4:	50                   	push   %eax
  8021b5:	e8 67 01 00 00       	call   802321 <nsipc_listen>
  8021ba:	83 c4 10             	add    $0x10,%esp
}
  8021bd:	c9                   	leave  
  8021be:	c3                   	ret    

008021bf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8021bf:	55                   	push   %ebp
  8021c0:	89 e5                	mov    %esp,%ebp
  8021c2:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8021c5:	ff 75 10             	pushl  0x10(%ebp)
  8021c8:	ff 75 0c             	pushl  0xc(%ebp)
  8021cb:	ff 75 08             	pushl  0x8(%ebp)
  8021ce:	e8 3a 02 00 00       	call   80240d <nsipc_socket>
  8021d3:	83 c4 10             	add    $0x10,%esp
  8021d6:	85 c0                	test   %eax,%eax
  8021d8:	78 05                	js     8021df <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8021da:	e8 a5 fe ff ff       	call   802084 <alloc_sockfd>
}
  8021df:	c9                   	leave  
  8021e0:	c3                   	ret    

008021e1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8021e1:	55                   	push   %ebp
  8021e2:	89 e5                	mov    %esp,%ebp
  8021e4:	53                   	push   %ebx
  8021e5:	83 ec 04             	sub    $0x4,%esp
  8021e8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8021ea:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  8021f1:	75 12                	jne    802205 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8021f3:	83 ec 0c             	sub    $0xc,%esp
  8021f6:	6a 02                	push   $0x2
  8021f8:	e8 66 f5 ff ff       	call   801763 <ipc_find_env>
  8021fd:	a3 1c 50 80 00       	mov    %eax,0x80501c
  802202:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802205:	6a 07                	push   $0x7
  802207:	68 00 70 80 00       	push   $0x807000
  80220c:	53                   	push   %ebx
  80220d:	ff 35 1c 50 80 00    	pushl  0x80501c
  802213:	e8 f7 f4 ff ff       	call   80170f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802218:	83 c4 0c             	add    $0xc,%esp
  80221b:	6a 00                	push   $0x0
  80221d:	6a 00                	push   $0x0
  80221f:	6a 00                	push   $0x0
  802221:	e8 80 f4 ff ff       	call   8016a6 <ipc_recv>
}
  802226:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802229:	c9                   	leave  
  80222a:	c3                   	ret    

0080222b <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	56                   	push   %esi
  80222f:	53                   	push   %ebx
  802230:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802233:	8b 45 08             	mov    0x8(%ebp),%eax
  802236:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80223b:	8b 06                	mov    (%esi),%eax
  80223d:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802242:	b8 01 00 00 00       	mov    $0x1,%eax
  802247:	e8 95 ff ff ff       	call   8021e1 <nsipc>
  80224c:	89 c3                	mov    %eax,%ebx
  80224e:	85 c0                	test   %eax,%eax
  802250:	78 20                	js     802272 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802252:	83 ec 04             	sub    $0x4,%esp
  802255:	ff 35 10 70 80 00    	pushl  0x807010
  80225b:	68 00 70 80 00       	push   $0x807000
  802260:	ff 75 0c             	pushl  0xc(%ebp)
  802263:	e8 14 ed ff ff       	call   800f7c <memmove>
		*addrlen = ret->ret_addrlen;
  802268:	a1 10 70 80 00       	mov    0x807010,%eax
  80226d:	89 06                	mov    %eax,(%esi)
  80226f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  802272:	89 d8                	mov    %ebx,%eax
  802274:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5d                   	pop    %ebp
  80227a:	c3                   	ret    

0080227b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80227b:	55                   	push   %ebp
  80227c:	89 e5                	mov    %esp,%ebp
  80227e:	53                   	push   %ebx
  80227f:	83 ec 08             	sub    $0x8,%esp
  802282:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802285:	8b 45 08             	mov    0x8(%ebp),%eax
  802288:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80228d:	53                   	push   %ebx
  80228e:	ff 75 0c             	pushl  0xc(%ebp)
  802291:	68 04 70 80 00       	push   $0x807004
  802296:	e8 e1 ec ff ff       	call   800f7c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80229b:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8022a1:	b8 02 00 00 00       	mov    $0x2,%eax
  8022a6:	e8 36 ff ff ff       	call   8021e1 <nsipc>
}
  8022ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022ae:	c9                   	leave  
  8022af:	c3                   	ret    

008022b0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8022be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8022c6:	b8 03 00 00 00       	mov    $0x3,%eax
  8022cb:	e8 11 ff ff ff       	call   8021e1 <nsipc>
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <nsipc_close>:

int
nsipc_close(int s)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8022d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022db:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8022e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8022e5:	e8 f7 fe ff ff       	call   8021e1 <nsipc>
}
  8022ea:	c9                   	leave  
  8022eb:	c3                   	ret    

008022ec <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	53                   	push   %ebx
  8022f0:	83 ec 08             	sub    $0x8,%esp
  8022f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8022f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f9:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8022fe:	53                   	push   %ebx
  8022ff:	ff 75 0c             	pushl  0xc(%ebp)
  802302:	68 04 70 80 00       	push   $0x807004
  802307:	e8 70 ec ff ff       	call   800f7c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80230c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802312:	b8 05 00 00 00       	mov    $0x5,%eax
  802317:	e8 c5 fe ff ff       	call   8021e1 <nsipc>
}
  80231c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80231f:	c9                   	leave  
  802320:	c3                   	ret    

00802321 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802321:	55                   	push   %ebp
  802322:	89 e5                	mov    %esp,%ebp
  802324:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802327:	8b 45 08             	mov    0x8(%ebp),%eax
  80232a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80232f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802332:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802337:	b8 06 00 00 00       	mov    $0x6,%eax
  80233c:	e8 a0 fe ff ff       	call   8021e1 <nsipc>
}
  802341:	c9                   	leave  
  802342:	c3                   	ret    

00802343 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802343:	55                   	push   %ebp
  802344:	89 e5                	mov    %esp,%ebp
  802346:	56                   	push   %esi
  802347:	53                   	push   %ebx
  802348:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80234b:	8b 45 08             	mov    0x8(%ebp),%eax
  80234e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802353:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802359:	8b 45 14             	mov    0x14(%ebp),%eax
  80235c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802361:	b8 07 00 00 00       	mov    $0x7,%eax
  802366:	e8 76 fe ff ff       	call   8021e1 <nsipc>
  80236b:	89 c3                	mov    %eax,%ebx
  80236d:	85 c0                	test   %eax,%eax
  80236f:	78 35                	js     8023a6 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  802371:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802376:	7f 04                	jg     80237c <nsipc_recv+0x39>
  802378:	39 c6                	cmp    %eax,%esi
  80237a:	7d 16                	jge    802392 <nsipc_recv+0x4f>
  80237c:	68 6f 32 80 00       	push   $0x80326f
  802381:	68 30 32 80 00       	push   $0x803230
  802386:	6a 62                	push   $0x62
  802388:	68 84 32 80 00       	push   $0x803284
  80238d:	e8 fa e3 ff ff       	call   80078c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802392:	83 ec 04             	sub    $0x4,%esp
  802395:	50                   	push   %eax
  802396:	68 00 70 80 00       	push   $0x807000
  80239b:	ff 75 0c             	pushl  0xc(%ebp)
  80239e:	e8 d9 eb ff ff       	call   800f7c <memmove>
  8023a3:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  8023a6:	89 d8                	mov    %ebx,%eax
  8023a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023ab:	5b                   	pop    %ebx
  8023ac:	5e                   	pop    %esi
  8023ad:	5d                   	pop    %ebp
  8023ae:	c3                   	ret    

008023af <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8023af:	55                   	push   %ebp
  8023b0:	89 e5                	mov    %esp,%ebp
  8023b2:	53                   	push   %ebx
  8023b3:	83 ec 04             	sub    $0x4,%esp
  8023b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8023b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8023bc:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8023c1:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8023c7:	7e 16                	jle    8023df <nsipc_send+0x30>
  8023c9:	68 90 32 80 00       	push   $0x803290
  8023ce:	68 30 32 80 00       	push   $0x803230
  8023d3:	6a 6d                	push   $0x6d
  8023d5:	68 84 32 80 00       	push   $0x803284
  8023da:	e8 ad e3 ff ff       	call   80078c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023df:	83 ec 04             	sub    $0x4,%esp
  8023e2:	53                   	push   %ebx
  8023e3:	ff 75 0c             	pushl  0xc(%ebp)
  8023e6:	68 0c 70 80 00       	push   $0x80700c
  8023eb:	e8 8c eb ff ff       	call   800f7c <memmove>
	nsipcbuf.send.req_size = size;
  8023f0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8023f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8023f9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8023fe:	b8 08 00 00 00       	mov    $0x8,%eax
  802403:	e8 d9 fd ff ff       	call   8021e1 <nsipc>
}
  802408:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80240b:	c9                   	leave  
  80240c:	c3                   	ret    

0080240d <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802413:	8b 45 08             	mov    0x8(%ebp),%eax
  802416:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80241b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80241e:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802423:	8b 45 10             	mov    0x10(%ebp),%eax
  802426:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80242b:	b8 09 00 00 00       	mov    $0x9,%eax
  802430:	e8 ac fd ff ff       	call   8021e1 <nsipc>
}
  802435:	c9                   	leave  
  802436:	c3                   	ret    

00802437 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802437:	55                   	push   %ebp
  802438:	89 e5                	mov    %esp,%ebp
  80243a:	56                   	push   %esi
  80243b:	53                   	push   %ebx
  80243c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80243f:	83 ec 0c             	sub    $0xc,%esp
  802442:	ff 75 08             	pushl  0x8(%ebp)
  802445:	e8 62 f3 ff ff       	call   8017ac <fd2data>
  80244a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80244c:	83 c4 08             	add    $0x8,%esp
  80244f:	68 9c 32 80 00       	push   $0x80329c
  802454:	53                   	push   %ebx
  802455:	e8 90 e9 ff ff       	call   800dea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80245a:	8b 46 04             	mov    0x4(%esi),%eax
  80245d:	2b 06                	sub    (%esi),%eax
  80245f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802465:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80246c:	00 00 00 
	stat->st_dev = &devpipe;
  80246f:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802476:	40 80 00 
	return 0;
}
  802479:	b8 00 00 00 00       	mov    $0x0,%eax
  80247e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802481:	5b                   	pop    %ebx
  802482:	5e                   	pop    %esi
  802483:	5d                   	pop    %ebp
  802484:	c3                   	ret    

00802485 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802485:	55                   	push   %ebp
  802486:	89 e5                	mov    %esp,%ebp
  802488:	53                   	push   %ebx
  802489:	83 ec 0c             	sub    $0xc,%esp
  80248c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80248f:	53                   	push   %ebx
  802490:	6a 00                	push   $0x0
  802492:	e8 db ed ff ff       	call   801272 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802497:	89 1c 24             	mov    %ebx,(%esp)
  80249a:	e8 0d f3 ff ff       	call   8017ac <fd2data>
  80249f:	83 c4 08             	add    $0x8,%esp
  8024a2:	50                   	push   %eax
  8024a3:	6a 00                	push   $0x0
  8024a5:	e8 c8 ed ff ff       	call   801272 <sys_page_unmap>
}
  8024aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024ad:	c9                   	leave  
  8024ae:	c3                   	ret    

008024af <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8024af:	55                   	push   %ebp
  8024b0:	89 e5                	mov    %esp,%ebp
  8024b2:	57                   	push   %edi
  8024b3:	56                   	push   %esi
  8024b4:	53                   	push   %ebx
  8024b5:	83 ec 1c             	sub    $0x1c,%esp
  8024b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8024bb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8024bd:	a1 20 50 80 00       	mov    0x805020,%eax
  8024c2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8024c5:	83 ec 0c             	sub    $0xc,%esp
  8024c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8024cb:	e8 bc 04 00 00       	call   80298c <pageref>
  8024d0:	89 c3                	mov    %eax,%ebx
  8024d2:	89 3c 24             	mov    %edi,(%esp)
  8024d5:	e8 b2 04 00 00       	call   80298c <pageref>
  8024da:	83 c4 10             	add    $0x10,%esp
  8024dd:	39 c3                	cmp    %eax,%ebx
  8024df:	0f 94 c1             	sete   %cl
  8024e2:	0f b6 c9             	movzbl %cl,%ecx
  8024e5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8024e8:	8b 15 20 50 80 00    	mov    0x805020,%edx
  8024ee:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8024f1:	39 ce                	cmp    %ecx,%esi
  8024f3:	74 1b                	je     802510 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8024f5:	39 c3                	cmp    %eax,%ebx
  8024f7:	75 c4                	jne    8024bd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8024f9:	8b 42 58             	mov    0x58(%edx),%eax
  8024fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8024ff:	50                   	push   %eax
  802500:	56                   	push   %esi
  802501:	68 a3 32 80 00       	push   $0x8032a3
  802506:	e8 5a e3 ff ff       	call   800865 <cprintf>
  80250b:	83 c4 10             	add    $0x10,%esp
  80250e:	eb ad                	jmp    8024bd <_pipeisclosed+0xe>
	}
}
  802510:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802513:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802516:	5b                   	pop    %ebx
  802517:	5e                   	pop    %esi
  802518:	5f                   	pop    %edi
  802519:	5d                   	pop    %ebp
  80251a:	c3                   	ret    

0080251b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80251b:	55                   	push   %ebp
  80251c:	89 e5                	mov    %esp,%ebp
  80251e:	57                   	push   %edi
  80251f:	56                   	push   %esi
  802520:	53                   	push   %ebx
  802521:	83 ec 28             	sub    $0x28,%esp
  802524:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802527:	56                   	push   %esi
  802528:	e8 7f f2 ff ff       	call   8017ac <fd2data>
  80252d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80252f:	83 c4 10             	add    $0x10,%esp
  802532:	bf 00 00 00 00       	mov    $0x0,%edi
  802537:	eb 4b                	jmp    802584 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802539:	89 da                	mov    %ebx,%edx
  80253b:	89 f0                	mov    %esi,%eax
  80253d:	e8 6d ff ff ff       	call   8024af <_pipeisclosed>
  802542:	85 c0                	test   %eax,%eax
  802544:	75 48                	jne    80258e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802546:	e8 83 ec ff ff       	call   8011ce <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80254b:	8b 43 04             	mov    0x4(%ebx),%eax
  80254e:	8b 0b                	mov    (%ebx),%ecx
  802550:	8d 51 20             	lea    0x20(%ecx),%edx
  802553:	39 d0                	cmp    %edx,%eax
  802555:	73 e2                	jae    802539 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802557:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80255a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80255e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802561:	89 c2                	mov    %eax,%edx
  802563:	c1 fa 1f             	sar    $0x1f,%edx
  802566:	89 d1                	mov    %edx,%ecx
  802568:	c1 e9 1b             	shr    $0x1b,%ecx
  80256b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80256e:	83 e2 1f             	and    $0x1f,%edx
  802571:	29 ca                	sub    %ecx,%edx
  802573:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802577:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80257b:	83 c0 01             	add    $0x1,%eax
  80257e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802581:	83 c7 01             	add    $0x1,%edi
  802584:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802587:	75 c2                	jne    80254b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802589:	8b 45 10             	mov    0x10(%ebp),%eax
  80258c:	eb 05                	jmp    802593 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80258e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802596:	5b                   	pop    %ebx
  802597:	5e                   	pop    %esi
  802598:	5f                   	pop    %edi
  802599:	5d                   	pop    %ebp
  80259a:	c3                   	ret    

0080259b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80259b:	55                   	push   %ebp
  80259c:	89 e5                	mov    %esp,%ebp
  80259e:	57                   	push   %edi
  80259f:	56                   	push   %esi
  8025a0:	53                   	push   %ebx
  8025a1:	83 ec 18             	sub    $0x18,%esp
  8025a4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8025a7:	57                   	push   %edi
  8025a8:	e8 ff f1 ff ff       	call   8017ac <fd2data>
  8025ad:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025af:	83 c4 10             	add    $0x10,%esp
  8025b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025b7:	eb 3d                	jmp    8025f6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8025b9:	85 db                	test   %ebx,%ebx
  8025bb:	74 04                	je     8025c1 <devpipe_read+0x26>
				return i;
  8025bd:	89 d8                	mov    %ebx,%eax
  8025bf:	eb 44                	jmp    802605 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8025c1:	89 f2                	mov    %esi,%edx
  8025c3:	89 f8                	mov    %edi,%eax
  8025c5:	e8 e5 fe ff ff       	call   8024af <_pipeisclosed>
  8025ca:	85 c0                	test   %eax,%eax
  8025cc:	75 32                	jne    802600 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8025ce:	e8 fb eb ff ff       	call   8011ce <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8025d3:	8b 06                	mov    (%esi),%eax
  8025d5:	3b 46 04             	cmp    0x4(%esi),%eax
  8025d8:	74 df                	je     8025b9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8025da:	99                   	cltd   
  8025db:	c1 ea 1b             	shr    $0x1b,%edx
  8025de:	01 d0                	add    %edx,%eax
  8025e0:	83 e0 1f             	and    $0x1f,%eax
  8025e3:	29 d0                	sub    %edx,%eax
  8025e5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8025ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025ed:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8025f0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025f3:	83 c3 01             	add    $0x1,%ebx
  8025f6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8025f9:	75 d8                	jne    8025d3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8025fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8025fe:	eb 05                	jmp    802605 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802600:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802605:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802608:	5b                   	pop    %ebx
  802609:	5e                   	pop    %esi
  80260a:	5f                   	pop    %edi
  80260b:	5d                   	pop    %ebp
  80260c:	c3                   	ret    

0080260d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80260d:	55                   	push   %ebp
  80260e:	89 e5                	mov    %esp,%ebp
  802610:	56                   	push   %esi
  802611:	53                   	push   %ebx
  802612:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802615:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802618:	50                   	push   %eax
  802619:	e8 a5 f1 ff ff       	call   8017c3 <fd_alloc>
  80261e:	83 c4 10             	add    $0x10,%esp
  802621:	89 c2                	mov    %eax,%edx
  802623:	85 c0                	test   %eax,%eax
  802625:	0f 88 2c 01 00 00    	js     802757 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80262b:	83 ec 04             	sub    $0x4,%esp
  80262e:	68 07 04 00 00       	push   $0x407
  802633:	ff 75 f4             	pushl  -0xc(%ebp)
  802636:	6a 00                	push   $0x0
  802638:	e8 b0 eb ff ff       	call   8011ed <sys_page_alloc>
  80263d:	83 c4 10             	add    $0x10,%esp
  802640:	89 c2                	mov    %eax,%edx
  802642:	85 c0                	test   %eax,%eax
  802644:	0f 88 0d 01 00 00    	js     802757 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80264a:	83 ec 0c             	sub    $0xc,%esp
  80264d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802650:	50                   	push   %eax
  802651:	e8 6d f1 ff ff       	call   8017c3 <fd_alloc>
  802656:	89 c3                	mov    %eax,%ebx
  802658:	83 c4 10             	add    $0x10,%esp
  80265b:	85 c0                	test   %eax,%eax
  80265d:	0f 88 e2 00 00 00    	js     802745 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802663:	83 ec 04             	sub    $0x4,%esp
  802666:	68 07 04 00 00       	push   $0x407
  80266b:	ff 75 f0             	pushl  -0x10(%ebp)
  80266e:	6a 00                	push   $0x0
  802670:	e8 78 eb ff ff       	call   8011ed <sys_page_alloc>
  802675:	89 c3                	mov    %eax,%ebx
  802677:	83 c4 10             	add    $0x10,%esp
  80267a:	85 c0                	test   %eax,%eax
  80267c:	0f 88 c3 00 00 00    	js     802745 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802682:	83 ec 0c             	sub    $0xc,%esp
  802685:	ff 75 f4             	pushl  -0xc(%ebp)
  802688:	e8 1f f1 ff ff       	call   8017ac <fd2data>
  80268d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80268f:	83 c4 0c             	add    $0xc,%esp
  802692:	68 07 04 00 00       	push   $0x407
  802697:	50                   	push   %eax
  802698:	6a 00                	push   $0x0
  80269a:	e8 4e eb ff ff       	call   8011ed <sys_page_alloc>
  80269f:	89 c3                	mov    %eax,%ebx
  8026a1:	83 c4 10             	add    $0x10,%esp
  8026a4:	85 c0                	test   %eax,%eax
  8026a6:	0f 88 89 00 00 00    	js     802735 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026ac:	83 ec 0c             	sub    $0xc,%esp
  8026af:	ff 75 f0             	pushl  -0x10(%ebp)
  8026b2:	e8 f5 f0 ff ff       	call   8017ac <fd2data>
  8026b7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8026be:	50                   	push   %eax
  8026bf:	6a 00                	push   $0x0
  8026c1:	56                   	push   %esi
  8026c2:	6a 00                	push   $0x0
  8026c4:	e8 67 eb ff ff       	call   801230 <sys_page_map>
  8026c9:	89 c3                	mov    %eax,%ebx
  8026cb:	83 c4 20             	add    $0x20,%esp
  8026ce:	85 c0                	test   %eax,%eax
  8026d0:	78 55                	js     802727 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8026d2:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8026d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026db:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8026dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026e0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8026e7:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  8026ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026f0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8026f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8026f5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8026fc:	83 ec 0c             	sub    $0xc,%esp
  8026ff:	ff 75 f4             	pushl  -0xc(%ebp)
  802702:	e8 95 f0 ff ff       	call   80179c <fd2num>
  802707:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80270a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80270c:	83 c4 04             	add    $0x4,%esp
  80270f:	ff 75 f0             	pushl  -0x10(%ebp)
  802712:	e8 85 f0 ff ff       	call   80179c <fd2num>
  802717:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80271a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80271d:	83 c4 10             	add    $0x10,%esp
  802720:	ba 00 00 00 00       	mov    $0x0,%edx
  802725:	eb 30                	jmp    802757 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802727:	83 ec 08             	sub    $0x8,%esp
  80272a:	56                   	push   %esi
  80272b:	6a 00                	push   $0x0
  80272d:	e8 40 eb ff ff       	call   801272 <sys_page_unmap>
  802732:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802735:	83 ec 08             	sub    $0x8,%esp
  802738:	ff 75 f0             	pushl  -0x10(%ebp)
  80273b:	6a 00                	push   $0x0
  80273d:	e8 30 eb ff ff       	call   801272 <sys_page_unmap>
  802742:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802745:	83 ec 08             	sub    $0x8,%esp
  802748:	ff 75 f4             	pushl  -0xc(%ebp)
  80274b:	6a 00                	push   $0x0
  80274d:	e8 20 eb ff ff       	call   801272 <sys_page_unmap>
  802752:	83 c4 10             	add    $0x10,%esp
  802755:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802757:	89 d0                	mov    %edx,%eax
  802759:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80275c:	5b                   	pop    %ebx
  80275d:	5e                   	pop    %esi
  80275e:	5d                   	pop    %ebp
  80275f:	c3                   	ret    

00802760 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802769:	50                   	push   %eax
  80276a:	ff 75 08             	pushl  0x8(%ebp)
  80276d:	e8 a0 f0 ff ff       	call   801812 <fd_lookup>
  802772:	83 c4 10             	add    $0x10,%esp
  802775:	85 c0                	test   %eax,%eax
  802777:	78 18                	js     802791 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802779:	83 ec 0c             	sub    $0xc,%esp
  80277c:	ff 75 f4             	pushl  -0xc(%ebp)
  80277f:	e8 28 f0 ff ff       	call   8017ac <fd2data>
	return _pipeisclosed(fd, p);
  802784:	89 c2                	mov    %eax,%edx
  802786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802789:	e8 21 fd ff ff       	call   8024af <_pipeisclosed>
  80278e:	83 c4 10             	add    $0x10,%esp
}
  802791:	c9                   	leave  
  802792:	c3                   	ret    

00802793 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802793:	55                   	push   %ebp
  802794:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802796:	b8 00 00 00 00       	mov    $0x0,%eax
  80279b:	5d                   	pop    %ebp
  80279c:	c3                   	ret    

0080279d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80279d:	55                   	push   %ebp
  80279e:	89 e5                	mov    %esp,%ebp
  8027a0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8027a3:	68 bb 32 80 00       	push   $0x8032bb
  8027a8:	ff 75 0c             	pushl  0xc(%ebp)
  8027ab:	e8 3a e6 ff ff       	call   800dea <strcpy>
	return 0;
}
  8027b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8027b5:	c9                   	leave  
  8027b6:	c3                   	ret    

008027b7 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8027b7:	55                   	push   %ebp
  8027b8:	89 e5                	mov    %esp,%ebp
  8027ba:	57                   	push   %edi
  8027bb:	56                   	push   %esi
  8027bc:	53                   	push   %ebx
  8027bd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027c3:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027c8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027ce:	eb 2d                	jmp    8027fd <devcons_write+0x46>
		m = n - tot;
  8027d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027d3:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8027d5:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8027d8:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8027dd:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027e0:	83 ec 04             	sub    $0x4,%esp
  8027e3:	53                   	push   %ebx
  8027e4:	03 45 0c             	add    0xc(%ebp),%eax
  8027e7:	50                   	push   %eax
  8027e8:	57                   	push   %edi
  8027e9:	e8 8e e7 ff ff       	call   800f7c <memmove>
		sys_cputs(buf, m);
  8027ee:	83 c4 08             	add    $0x8,%esp
  8027f1:	53                   	push   %ebx
  8027f2:	57                   	push   %edi
  8027f3:	e8 39 e9 ff ff       	call   801131 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027f8:	01 de                	add    %ebx,%esi
  8027fa:	83 c4 10             	add    $0x10,%esp
  8027fd:	89 f0                	mov    %esi,%eax
  8027ff:	3b 75 10             	cmp    0x10(%ebp),%esi
  802802:	72 cc                	jb     8027d0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802804:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802807:	5b                   	pop    %ebx
  802808:	5e                   	pop    %esi
  802809:	5f                   	pop    %edi
  80280a:	5d                   	pop    %ebp
  80280b:	c3                   	ret    

0080280c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80280c:	55                   	push   %ebp
  80280d:	89 e5                	mov    %esp,%ebp
  80280f:	83 ec 08             	sub    $0x8,%esp
  802812:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802817:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80281b:	74 2a                	je     802847 <devcons_read+0x3b>
  80281d:	eb 05                	jmp    802824 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80281f:	e8 aa e9 ff ff       	call   8011ce <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802824:	e8 26 e9 ff ff       	call   80114f <sys_cgetc>
  802829:	85 c0                	test   %eax,%eax
  80282b:	74 f2                	je     80281f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80282d:	85 c0                	test   %eax,%eax
  80282f:	78 16                	js     802847 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802831:	83 f8 04             	cmp    $0x4,%eax
  802834:	74 0c                	je     802842 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802836:	8b 55 0c             	mov    0xc(%ebp),%edx
  802839:	88 02                	mov    %al,(%edx)
	return 1;
  80283b:	b8 01 00 00 00       	mov    $0x1,%eax
  802840:	eb 05                	jmp    802847 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802842:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802847:	c9                   	leave  
  802848:	c3                   	ret    

00802849 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802849:	55                   	push   %ebp
  80284a:	89 e5                	mov    %esp,%ebp
  80284c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80284f:	8b 45 08             	mov    0x8(%ebp),%eax
  802852:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802855:	6a 01                	push   $0x1
  802857:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80285a:	50                   	push   %eax
  80285b:	e8 d1 e8 ff ff       	call   801131 <sys_cputs>
}
  802860:	83 c4 10             	add    $0x10,%esp
  802863:	c9                   	leave  
  802864:	c3                   	ret    

00802865 <getchar>:

int
getchar(void)
{
  802865:	55                   	push   %ebp
  802866:	89 e5                	mov    %esp,%ebp
  802868:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80286b:	6a 01                	push   $0x1
  80286d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802870:	50                   	push   %eax
  802871:	6a 00                	push   $0x0
  802873:	e8 00 f2 ff ff       	call   801a78 <read>
	if (r < 0)
  802878:	83 c4 10             	add    $0x10,%esp
  80287b:	85 c0                	test   %eax,%eax
  80287d:	78 0f                	js     80288e <getchar+0x29>
		return r;
	if (r < 1)
  80287f:	85 c0                	test   %eax,%eax
  802881:	7e 06                	jle    802889 <getchar+0x24>
		return -E_EOF;
	return c;
  802883:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802887:	eb 05                	jmp    80288e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802889:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80288e:	c9                   	leave  
  80288f:	c3                   	ret    

00802890 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802890:	55                   	push   %ebp
  802891:	89 e5                	mov    %esp,%ebp
  802893:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802896:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802899:	50                   	push   %eax
  80289a:	ff 75 08             	pushl  0x8(%ebp)
  80289d:	e8 70 ef ff ff       	call   801812 <fd_lookup>
  8028a2:	83 c4 10             	add    $0x10,%esp
  8028a5:	85 c0                	test   %eax,%eax
  8028a7:	78 11                	js     8028ba <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8028a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ac:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8028b2:	39 10                	cmp    %edx,(%eax)
  8028b4:	0f 94 c0             	sete   %al
  8028b7:	0f b6 c0             	movzbl %al,%eax
}
  8028ba:	c9                   	leave  
  8028bb:	c3                   	ret    

008028bc <opencons>:

int
opencons(void)
{
  8028bc:	55                   	push   %ebp
  8028bd:	89 e5                	mov    %esp,%ebp
  8028bf:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028c5:	50                   	push   %eax
  8028c6:	e8 f8 ee ff ff       	call   8017c3 <fd_alloc>
  8028cb:	83 c4 10             	add    $0x10,%esp
		return r;
  8028ce:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028d0:	85 c0                	test   %eax,%eax
  8028d2:	78 3e                	js     802912 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028d4:	83 ec 04             	sub    $0x4,%esp
  8028d7:	68 07 04 00 00       	push   $0x407
  8028dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8028df:	6a 00                	push   $0x0
  8028e1:	e8 07 e9 ff ff       	call   8011ed <sys_page_alloc>
  8028e6:	83 c4 10             	add    $0x10,%esp
		return r;
  8028e9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028eb:	85 c0                	test   %eax,%eax
  8028ed:	78 23                	js     802912 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8028ef:	8b 15 58 40 80 00    	mov    0x804058,%edx
  8028f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028f8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028fd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802904:	83 ec 0c             	sub    $0xc,%esp
  802907:	50                   	push   %eax
  802908:	e8 8f ee ff ff       	call   80179c <fd2num>
  80290d:	89 c2                	mov    %eax,%edx
  80290f:	83 c4 10             	add    $0x10,%esp
}
  802912:	89 d0                	mov    %edx,%eax
  802914:	c9                   	leave  
  802915:	c3                   	ret    

00802916 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802916:	55                   	push   %ebp
  802917:	89 e5                	mov    %esp,%ebp
  802919:	53                   	push   %ebx
  80291a:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  80291d:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802924:	75 28                	jne    80294e <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		envid_t envid = sys_getenvid();
  802926:	e8 84 e8 ff ff       	call   8011af <sys_getenvid>
  80292b:	89 c3                	mov    %eax,%ebx
		sys_page_alloc(envid, (void *) (UXSTACKTOP - PGSIZE), PTE_U | PTE_W);
  80292d:	83 ec 04             	sub    $0x4,%esp
  802930:	6a 06                	push   $0x6
  802932:	68 00 f0 bf ee       	push   $0xeebff000
  802937:	50                   	push   %eax
  802938:	e8 b0 e8 ff ff       	call   8011ed <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, (void *) _pgfault_upcall);
  80293d:	83 c4 08             	add    $0x8,%esp
  802940:	68 5b 29 80 00       	push   $0x80295b
  802945:	53                   	push   %ebx
  802946:	e8 ed e9 ff ff       	call   801338 <sys_env_set_pgfault_upcall>
  80294b:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80294e:	8b 45 08             	mov    0x8(%ebp),%eax
  802951:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802956:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802959:	c9                   	leave  
  80295a:	c3                   	ret    

0080295b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80295b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80295c:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802961:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802963:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here.

	# My method is different. Copy the values to the other stack
	# in a convinient way, and then pop everything.
	movl %esp, %ebp		# ebp refers to the exception stack
  802966:	89 e5                	mov    %esp,%ebp
	movl 48(%ebp), %esp 	# go to other stack
  802968:	8b 65 30             	mov    0x30(%ebp),%esp

	pushl 40(%ebp)		# eip - ORDER SWITCHED WITH EFLAGS
  80296b:	ff 75 28             	pushl  0x28(%ebp)
	pushl 44(%ebp)      	# eflags
  80296e:	ff 75 2c             	pushl  0x2c(%ebp)
	pushl 36(%ebp)		# all the 8 remaining regs
  802971:	ff 75 24             	pushl  0x24(%ebp)
	pushl 32(%ebp)
  802974:	ff 75 20             	pushl  0x20(%ebp)
	pushl 28(%ebp)
  802977:	ff 75 1c             	pushl  0x1c(%ebp)
	pushl 24(%ebp)
  80297a:	ff 75 18             	pushl  0x18(%ebp)
	pushl 20(%ebp)
  80297d:	ff 75 14             	pushl  0x14(%ebp)
	pushl 16(%ebp)
  802980:	ff 75 10             	pushl  0x10(%ebp)
	pushl 12(%ebp)
  802983:	ff 75 0c             	pushl  0xc(%ebp)
	pushl 8(%ebp)
  802986:	ff 75 08             	pushl  0x8(%ebp)

	popal			# now just pop everything!
  802989:	61                   	popa   
	popfl
  80298a:	9d                   	popf   
	ret
  80298b:	c3                   	ret    

0080298c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80298c:	55                   	push   %ebp
  80298d:	89 e5                	mov    %esp,%ebp
  80298f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802992:	89 d0                	mov    %edx,%eax
  802994:	c1 e8 16             	shr    $0x16,%eax
  802997:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80299e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8029a3:	f6 c1 01             	test   $0x1,%cl
  8029a6:	74 1d                	je     8029c5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8029a8:	c1 ea 0c             	shr    $0xc,%edx
  8029ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8029b2:	f6 c2 01             	test   $0x1,%dl
  8029b5:	74 0e                	je     8029c5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8029b7:	c1 ea 0c             	shr    $0xc,%edx
  8029ba:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8029c1:	ef 
  8029c2:	0f b7 c0             	movzwl %ax,%eax
}
  8029c5:	5d                   	pop    %ebp
  8029c6:	c3                   	ret    
  8029c7:	66 90                	xchg   %ax,%ax
  8029c9:	66 90                	xchg   %ax,%ax
  8029cb:	66 90                	xchg   %ax,%ax
  8029cd:	66 90                	xchg   %ax,%ax
  8029cf:	90                   	nop

008029d0 <__udivdi3>:
  8029d0:	55                   	push   %ebp
  8029d1:	57                   	push   %edi
  8029d2:	56                   	push   %esi
  8029d3:	53                   	push   %ebx
  8029d4:	83 ec 1c             	sub    $0x1c,%esp
  8029d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8029db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8029df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8029e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8029e7:	85 f6                	test   %esi,%esi
  8029e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029ed:	89 ca                	mov    %ecx,%edx
  8029ef:	89 f8                	mov    %edi,%eax
  8029f1:	75 3d                	jne    802a30 <__udivdi3+0x60>
  8029f3:	39 cf                	cmp    %ecx,%edi
  8029f5:	0f 87 c5 00 00 00    	ja     802ac0 <__udivdi3+0xf0>
  8029fb:	85 ff                	test   %edi,%edi
  8029fd:	89 fd                	mov    %edi,%ebp
  8029ff:	75 0b                	jne    802a0c <__udivdi3+0x3c>
  802a01:	b8 01 00 00 00       	mov    $0x1,%eax
  802a06:	31 d2                	xor    %edx,%edx
  802a08:	f7 f7                	div    %edi
  802a0a:	89 c5                	mov    %eax,%ebp
  802a0c:	89 c8                	mov    %ecx,%eax
  802a0e:	31 d2                	xor    %edx,%edx
  802a10:	f7 f5                	div    %ebp
  802a12:	89 c1                	mov    %eax,%ecx
  802a14:	89 d8                	mov    %ebx,%eax
  802a16:	89 cf                	mov    %ecx,%edi
  802a18:	f7 f5                	div    %ebp
  802a1a:	89 c3                	mov    %eax,%ebx
  802a1c:	89 d8                	mov    %ebx,%eax
  802a1e:	89 fa                	mov    %edi,%edx
  802a20:	83 c4 1c             	add    $0x1c,%esp
  802a23:	5b                   	pop    %ebx
  802a24:	5e                   	pop    %esi
  802a25:	5f                   	pop    %edi
  802a26:	5d                   	pop    %ebp
  802a27:	c3                   	ret    
  802a28:	90                   	nop
  802a29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a30:	39 ce                	cmp    %ecx,%esi
  802a32:	77 74                	ja     802aa8 <__udivdi3+0xd8>
  802a34:	0f bd fe             	bsr    %esi,%edi
  802a37:	83 f7 1f             	xor    $0x1f,%edi
  802a3a:	0f 84 98 00 00 00    	je     802ad8 <__udivdi3+0x108>
  802a40:	bb 20 00 00 00       	mov    $0x20,%ebx
  802a45:	89 f9                	mov    %edi,%ecx
  802a47:	89 c5                	mov    %eax,%ebp
  802a49:	29 fb                	sub    %edi,%ebx
  802a4b:	d3 e6                	shl    %cl,%esi
  802a4d:	89 d9                	mov    %ebx,%ecx
  802a4f:	d3 ed                	shr    %cl,%ebp
  802a51:	89 f9                	mov    %edi,%ecx
  802a53:	d3 e0                	shl    %cl,%eax
  802a55:	09 ee                	or     %ebp,%esi
  802a57:	89 d9                	mov    %ebx,%ecx
  802a59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a5d:	89 d5                	mov    %edx,%ebp
  802a5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802a63:	d3 ed                	shr    %cl,%ebp
  802a65:	89 f9                	mov    %edi,%ecx
  802a67:	d3 e2                	shl    %cl,%edx
  802a69:	89 d9                	mov    %ebx,%ecx
  802a6b:	d3 e8                	shr    %cl,%eax
  802a6d:	09 c2                	or     %eax,%edx
  802a6f:	89 d0                	mov    %edx,%eax
  802a71:	89 ea                	mov    %ebp,%edx
  802a73:	f7 f6                	div    %esi
  802a75:	89 d5                	mov    %edx,%ebp
  802a77:	89 c3                	mov    %eax,%ebx
  802a79:	f7 64 24 0c          	mull   0xc(%esp)
  802a7d:	39 d5                	cmp    %edx,%ebp
  802a7f:	72 10                	jb     802a91 <__udivdi3+0xc1>
  802a81:	8b 74 24 08          	mov    0x8(%esp),%esi
  802a85:	89 f9                	mov    %edi,%ecx
  802a87:	d3 e6                	shl    %cl,%esi
  802a89:	39 c6                	cmp    %eax,%esi
  802a8b:	73 07                	jae    802a94 <__udivdi3+0xc4>
  802a8d:	39 d5                	cmp    %edx,%ebp
  802a8f:	75 03                	jne    802a94 <__udivdi3+0xc4>
  802a91:	83 eb 01             	sub    $0x1,%ebx
  802a94:	31 ff                	xor    %edi,%edi
  802a96:	89 d8                	mov    %ebx,%eax
  802a98:	89 fa                	mov    %edi,%edx
  802a9a:	83 c4 1c             	add    $0x1c,%esp
  802a9d:	5b                   	pop    %ebx
  802a9e:	5e                   	pop    %esi
  802a9f:	5f                   	pop    %edi
  802aa0:	5d                   	pop    %ebp
  802aa1:	c3                   	ret    
  802aa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802aa8:	31 ff                	xor    %edi,%edi
  802aaa:	31 db                	xor    %ebx,%ebx
  802aac:	89 d8                	mov    %ebx,%eax
  802aae:	89 fa                	mov    %edi,%edx
  802ab0:	83 c4 1c             	add    $0x1c,%esp
  802ab3:	5b                   	pop    %ebx
  802ab4:	5e                   	pop    %esi
  802ab5:	5f                   	pop    %edi
  802ab6:	5d                   	pop    %ebp
  802ab7:	c3                   	ret    
  802ab8:	90                   	nop
  802ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ac0:	89 d8                	mov    %ebx,%eax
  802ac2:	f7 f7                	div    %edi
  802ac4:	31 ff                	xor    %edi,%edi
  802ac6:	89 c3                	mov    %eax,%ebx
  802ac8:	89 d8                	mov    %ebx,%eax
  802aca:	89 fa                	mov    %edi,%edx
  802acc:	83 c4 1c             	add    $0x1c,%esp
  802acf:	5b                   	pop    %ebx
  802ad0:	5e                   	pop    %esi
  802ad1:	5f                   	pop    %edi
  802ad2:	5d                   	pop    %ebp
  802ad3:	c3                   	ret    
  802ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ad8:	39 ce                	cmp    %ecx,%esi
  802ada:	72 0c                	jb     802ae8 <__udivdi3+0x118>
  802adc:	31 db                	xor    %ebx,%ebx
  802ade:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802ae2:	0f 87 34 ff ff ff    	ja     802a1c <__udivdi3+0x4c>
  802ae8:	bb 01 00 00 00       	mov    $0x1,%ebx
  802aed:	e9 2a ff ff ff       	jmp    802a1c <__udivdi3+0x4c>
  802af2:	66 90                	xchg   %ax,%ax
  802af4:	66 90                	xchg   %ax,%ax
  802af6:	66 90                	xchg   %ax,%ax
  802af8:	66 90                	xchg   %ax,%ax
  802afa:	66 90                	xchg   %ax,%ax
  802afc:	66 90                	xchg   %ax,%ax
  802afe:	66 90                	xchg   %ax,%ax

00802b00 <__umoddi3>:
  802b00:	55                   	push   %ebp
  802b01:	57                   	push   %edi
  802b02:	56                   	push   %esi
  802b03:	53                   	push   %ebx
  802b04:	83 ec 1c             	sub    $0x1c,%esp
  802b07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802b0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  802b0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802b13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b17:	85 d2                	test   %edx,%edx
  802b19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802b1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b21:	89 f3                	mov    %esi,%ebx
  802b23:	89 3c 24             	mov    %edi,(%esp)
  802b26:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b2a:	75 1c                	jne    802b48 <__umoddi3+0x48>
  802b2c:	39 f7                	cmp    %esi,%edi
  802b2e:	76 50                	jbe    802b80 <__umoddi3+0x80>
  802b30:	89 c8                	mov    %ecx,%eax
  802b32:	89 f2                	mov    %esi,%edx
  802b34:	f7 f7                	div    %edi
  802b36:	89 d0                	mov    %edx,%eax
  802b38:	31 d2                	xor    %edx,%edx
  802b3a:	83 c4 1c             	add    $0x1c,%esp
  802b3d:	5b                   	pop    %ebx
  802b3e:	5e                   	pop    %esi
  802b3f:	5f                   	pop    %edi
  802b40:	5d                   	pop    %ebp
  802b41:	c3                   	ret    
  802b42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802b48:	39 f2                	cmp    %esi,%edx
  802b4a:	89 d0                	mov    %edx,%eax
  802b4c:	77 52                	ja     802ba0 <__umoddi3+0xa0>
  802b4e:	0f bd ea             	bsr    %edx,%ebp
  802b51:	83 f5 1f             	xor    $0x1f,%ebp
  802b54:	75 5a                	jne    802bb0 <__umoddi3+0xb0>
  802b56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  802b5a:	0f 82 e0 00 00 00    	jb     802c40 <__umoddi3+0x140>
  802b60:	39 0c 24             	cmp    %ecx,(%esp)
  802b63:	0f 86 d7 00 00 00    	jbe    802c40 <__umoddi3+0x140>
  802b69:	8b 44 24 08          	mov    0x8(%esp),%eax
  802b6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802b71:	83 c4 1c             	add    $0x1c,%esp
  802b74:	5b                   	pop    %ebx
  802b75:	5e                   	pop    %esi
  802b76:	5f                   	pop    %edi
  802b77:	5d                   	pop    %ebp
  802b78:	c3                   	ret    
  802b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b80:	85 ff                	test   %edi,%edi
  802b82:	89 fd                	mov    %edi,%ebp
  802b84:	75 0b                	jne    802b91 <__umoddi3+0x91>
  802b86:	b8 01 00 00 00       	mov    $0x1,%eax
  802b8b:	31 d2                	xor    %edx,%edx
  802b8d:	f7 f7                	div    %edi
  802b8f:	89 c5                	mov    %eax,%ebp
  802b91:	89 f0                	mov    %esi,%eax
  802b93:	31 d2                	xor    %edx,%edx
  802b95:	f7 f5                	div    %ebp
  802b97:	89 c8                	mov    %ecx,%eax
  802b99:	f7 f5                	div    %ebp
  802b9b:	89 d0                	mov    %edx,%eax
  802b9d:	eb 99                	jmp    802b38 <__umoddi3+0x38>
  802b9f:	90                   	nop
  802ba0:	89 c8                	mov    %ecx,%eax
  802ba2:	89 f2                	mov    %esi,%edx
  802ba4:	83 c4 1c             	add    $0x1c,%esp
  802ba7:	5b                   	pop    %ebx
  802ba8:	5e                   	pop    %esi
  802ba9:	5f                   	pop    %edi
  802baa:	5d                   	pop    %ebp
  802bab:	c3                   	ret    
  802bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802bb0:	8b 34 24             	mov    (%esp),%esi
  802bb3:	bf 20 00 00 00       	mov    $0x20,%edi
  802bb8:	89 e9                	mov    %ebp,%ecx
  802bba:	29 ef                	sub    %ebp,%edi
  802bbc:	d3 e0                	shl    %cl,%eax
  802bbe:	89 f9                	mov    %edi,%ecx
  802bc0:	89 f2                	mov    %esi,%edx
  802bc2:	d3 ea                	shr    %cl,%edx
  802bc4:	89 e9                	mov    %ebp,%ecx
  802bc6:	09 c2                	or     %eax,%edx
  802bc8:	89 d8                	mov    %ebx,%eax
  802bca:	89 14 24             	mov    %edx,(%esp)
  802bcd:	89 f2                	mov    %esi,%edx
  802bcf:	d3 e2                	shl    %cl,%edx
  802bd1:	89 f9                	mov    %edi,%ecx
  802bd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  802bd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802bdb:	d3 e8                	shr    %cl,%eax
  802bdd:	89 e9                	mov    %ebp,%ecx
  802bdf:	89 c6                	mov    %eax,%esi
  802be1:	d3 e3                	shl    %cl,%ebx
  802be3:	89 f9                	mov    %edi,%ecx
  802be5:	89 d0                	mov    %edx,%eax
  802be7:	d3 e8                	shr    %cl,%eax
  802be9:	89 e9                	mov    %ebp,%ecx
  802beb:	09 d8                	or     %ebx,%eax
  802bed:	89 d3                	mov    %edx,%ebx
  802bef:	89 f2                	mov    %esi,%edx
  802bf1:	f7 34 24             	divl   (%esp)
  802bf4:	89 d6                	mov    %edx,%esi
  802bf6:	d3 e3                	shl    %cl,%ebx
  802bf8:	f7 64 24 04          	mull   0x4(%esp)
  802bfc:	39 d6                	cmp    %edx,%esi
  802bfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c02:	89 d1                	mov    %edx,%ecx
  802c04:	89 c3                	mov    %eax,%ebx
  802c06:	72 08                	jb     802c10 <__umoddi3+0x110>
  802c08:	75 11                	jne    802c1b <__umoddi3+0x11b>
  802c0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  802c0e:	73 0b                	jae    802c1b <__umoddi3+0x11b>
  802c10:	2b 44 24 04          	sub    0x4(%esp),%eax
  802c14:	1b 14 24             	sbb    (%esp),%edx
  802c17:	89 d1                	mov    %edx,%ecx
  802c19:	89 c3                	mov    %eax,%ebx
  802c1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  802c1f:	29 da                	sub    %ebx,%edx
  802c21:	19 ce                	sbb    %ecx,%esi
  802c23:	89 f9                	mov    %edi,%ecx
  802c25:	89 f0                	mov    %esi,%eax
  802c27:	d3 e0                	shl    %cl,%eax
  802c29:	89 e9                	mov    %ebp,%ecx
  802c2b:	d3 ea                	shr    %cl,%edx
  802c2d:	89 e9                	mov    %ebp,%ecx
  802c2f:	d3 ee                	shr    %cl,%esi
  802c31:	09 d0                	or     %edx,%eax
  802c33:	89 f2                	mov    %esi,%edx
  802c35:	83 c4 1c             	add    $0x1c,%esp
  802c38:	5b                   	pop    %ebx
  802c39:	5e                   	pop    %esi
  802c3a:	5f                   	pop    %edi
  802c3b:	5d                   	pop    %ebp
  802c3c:	c3                   	ret    
  802c3d:	8d 76 00             	lea    0x0(%esi),%esi
  802c40:	29 f9                	sub    %edi,%ecx
  802c42:	19 d6                	sbb    %edx,%esi
  802c44:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c4c:	e9 18 ff ff ff       	jmp    802b69 <__umoddi3+0x69>
