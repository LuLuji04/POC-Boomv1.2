# BOOMv1.2 Store Access Fault Vulnerability POC

## Vulnerability Description

A critical vulnerability has been identified in the BOOMv1.2 processor implementation affecting its virtual memory system. The vulnerability manifests as an incorrect Store/AMO access fault during store instructions (sd) when operating with valid virtual-to-physical address translations that have write permissions (PTE_W) configured in SV39 mode.

### Impact
- Triggers unexpected Store/AMO access faults despite proper page table entries
- Affects store operations in mapped kernel memory after virtual memory transition
- May cause system instability through kernel panics
- Potential denial of service in affected systems

## Technical Details

### Page Table Setup
The vulnerability can be observed during the following page table configuration in SV39 mode:

```c
#elif SATP_MODE_CHOICE == SATP_MODE_SV39
  l1pt[PTES_PER_PT-1] = ((pte_t)kernel_l2pt >> PGSHIFT << PTE_PPN_SHIFT) | PTE_V;
  kernel_l2pt[PTES_PER_PT-1] = (DRAM_BASE/RISCV_PGSIZE << PTE_PPN_SHIFT) | PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D;
  user_l2pt[0] = ((pte_t)user_llpt >> PGSHIFT << PTE_PPN_SHIFT) | PTE_V;
#elif SATP_MODE_CHOICE == SATP_MODE_SV32
  l1pt[PTES_PER_PT-1] = (DRAM_BASE/RISCV_PGSIZE << PTE_PPN_SHIFT) | PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D;
#else
```

### Mode Transition Code
The following assembly code(in `$PWD/id_0.si-mcause7`) triggers the vulnerability during M-mode to S-mode transition with paging enabled:

```assembly
_p0:    li t3, 0xFFFFFFF
        csrr t1, sepc
        addi t0, t1, 0
        la t2, _p2
        csrw sepc, t2
        csrr t1, sepc
        csrr t2, stvec
        
        csrw mstatus, t3
        sret
_p1:    nop
_p2:    nop
```

### Vulnerability Manifestation
The bug manifests at PC=ffe00464 during the execution of `sd ra, 8(sp)` instruction, which triggers an unexpected MCLAUSE: 7 exception. This behavior diverges from the reference SPIKE implementation, which executes the instruction without fault. The discrepancy indicates a potential flaw in the memory management unit (MMU), physical memory protection (PMP), or memory access enforcement logic.

Below is the relevant execution `$PWD/log-mcause7` showing the divergence between RTL and ISA simulation:

```
----------------------------------------------------
PC:  ffe00464 ffe00464
ISA:  sd      ra, 8(sp)
RTL:  00113423
MODE:  1 1
WDATA:  0000000000000000 0000000000000000
MSTATUS:  8000000a007c79a8 8000000a007e79a8
FRM:  0 0
FFLAGS:  00 00
MCLAUSE:  0 0
SCLAUSE:  c c
MEDELEG:  000000000000b100 000000000000b100
----------------------------------------------------
PC:  ffe00468 80000194
ISA:  sd      gp, 24(sp)
RTL:  00003097
MODE:  1 3
WDATA:  0000000000000000 0000000080003194
MSTATUS:  8000000a007c79a8 8000000a007e69a0
FRM:  0 0
FFLAGS:  00 00
MCLAUSE:  0 7           # RTL triggers MCLAUSE 7 (Store/AMO access fault)
SCLAUSE:  c c
MEDELEG:  000000000000b100 000000000000b100
PC MISMATCH: ISA - ffe00468, RTL - 80000194
```

Key observations from the execution trace:
1. The RTL implementation triggers an MCLAUSE value of 7 (Store/AMO access fault)
2. The ISA reference model (SPIKE) continues normal execution without raising any exception
3. This leads to a PC mismatch between RTL (0x80000194) and ISA (0xffe00468)
4. The fault occurs in S-mode (MODE: 1) during a store operation

## Reproduction Steps

1. Clone the repository:
```bash
git clone https://github.com/LuLuji04/POC-Boomv1.2
cd POC-Boomv1.2
```

2. Run the fuzzing script:
```bash
./start_fuzzing_boom.sh > mylog
```

### Test Location
- Test programs can be found in: `$PWD/Fuzzer/batchboom/mismatch`
- Execution logs are written to: `$PWD/mylog`

## Additional Information
This vulnerability potentially impacts systems utilizing BOOMv1.2 for privileged operations, particularly those involving virtual memory management and kernel-mode store operations.