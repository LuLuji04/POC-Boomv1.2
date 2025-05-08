# See LICENSE for license details.

#*****************************************************************************
# add.S
#-----------------------------------------------------------------------------
#
# Test add instruction.
#

#include "riscv_test.h"
#include "fuzz_test.h"

# entry.S

#if __riscv_xlen == 64
# define STORE    sd
# define LOAD     ld
# define REGBYTES 8
#else
# define STORE    sw
# define LOAD     lw
# define REGBYTES 4
#endif

#define TESTEND gp
#define STACK_TOP (_end + 4096)

  .section ".text.init","ax",@progbits
  .global _start
  .align 2
_start:
  j handle_reset
  
  /* NMI vector */
  .align 2
nmi_vector:
  j wtf

  .align 2
trap_vector:
  j wtf

  .global _fuzz_prefix
  init_mie;
_fuzz_prefix:
_p0:    li t3, 0xFFFFFFF
                         ;
        csrr t1, sepc
                            ;
        addi t0, t1, 0
                           ;
        la t2, _p2
                               ;
        csrw sepc, t2
                            ;
        csrr t1, sepc
                            ;
        csrr t2, stvec
                           ;
        
                                         ;
        csrw mstatus, t3
                         ;
        sret
                                     ;
_p1:    nop
                                      ;
_p2:    nop
                                      ;
                                                  ;
_p3:;
    /* Fuzz Prefix */
    /**/
_end_prefix:
    ret

handle_reset:
INIT_XREGS

  la t0, trap_mtvec 
  csrw mtvec, t0
  la sp, STACK_TOP - SIZEOF_TRAPFRAME_T
  csrr t0, mhartid
  slli t0, t0, 12
  add sp, sp, t0
  csrw mscratch, sp
  li a0, MSTATUS_FS
  csrs mstatus, a0
  call init_freg
  la a0, userstart
  j vm_boot

init_freg:
INIT_FREGS

        ret
        .align;

  .global trap_stvec
trap_stvec:
        clear_sie;
_fuzz_suffix:
_s0:;
        /* Fuzz trap */
        /**/
_end_suffix:
        ecall

  .global trap_mtvec
trap_mtvec:
        clear_mie;
  DUMP_REGS

   write_tohost:
        li TESTEND, 1
        sw TESTEND, tohost, t5;
  _test_end:
#ifdef BP_EN
  BP_END
#endif
        j _test_end;


  .global pop_tf
pop_tf:
  LOAD  t0,33*REGBYTES(a0)
  csrw  sepc, t0
  LOAD  x1,1*REGBYTES(a0)
  LOAD  x2,2*REGBYTES(a0)
  LOAD  x3,3*REGBYTES(a0)
  LOAD  x4,4*REGBYTES(a0)
  LOAD  x5,5*REGBYTES(a0)
  LOAD  x6,6*REGBYTES(a0)
  LOAD  x7,7*REGBYTES(a0)
  LOAD  x8,8*REGBYTES(a0)
  LOAD  x9,9*REGBYTES(a0)
  LOAD  x11,11*REGBYTES(a0)
  LOAD  x12,12*REGBYTES(a0)
  LOAD  x13,13*REGBYTES(a0)
  LOAD  x14,14*REGBYTES(a0)
  LOAD  x15,15*REGBYTES(a0)
  LOAD  x16,16*REGBYTES(a0)
  LOAD  x17,17*REGBYTES(a0)
  LOAD  x18,18*REGBYTES(a0)
  LOAD  x19,19*REGBYTES(a0)
  LOAD  x20,20*REGBYTES(a0)
  LOAD  x21,21*REGBYTES(a0)
  LOAD  x22,22*REGBYTES(a0)
  LOAD  x23,23*REGBYTES(a0)
  LOAD  x24,24*REGBYTES(a0)
  LOAD  x25,25*REGBYTES(a0)
  LOAD  x26,26*REGBYTES(a0)
  LOAD  x27,27*REGBYTES(a0)
  LOAD  x28,28*REGBYTES(a0)
  LOAD  x29,29*REGBYTES(a0)
  LOAD  x30,30*REGBYTES(a0)
  LOAD  x31,31*REGBYTES(a0)
  LOAD  x10,10*REGBYTES(a0)
  sret

  .global trap_entry
  .align 2
trap_entry:
  csrrw sp, sscratch, sp

  STORE x1,1*REGBYTES(sp)
  STORE x3,3*REGBYTES(sp)
  STORE x4,4*REGBYTES(sp)
  STORE x5,5*REGBYTES(sp)
  STORE x6,6*REGBYTES(sp)
  STORE x7,7*REGBYTES(sp)
  STORE x8,8*REGBYTES(sp)
  STORE x9,9*REGBYTES(sp)
  STORE x10,10*REGBYTES(sp)
  STORE x11,11*REGBYTES(sp)
  STORE x12,12*REGBYTES(sp)
  STORE x13,13*REGBYTES(sp)
  STORE x14,14*REGBYTES(sp)
  STORE x15,15*REGBYTES(sp)
  STORE x16,16*REGBYTES(sp)
  STORE x17,17*REGBYTES(sp)
  STORE x18,18*REGBYTES(sp)
  STORE x19,19*REGBYTES(sp)
  STORE x20,20*REGBYTES(sp)
  STORE x21,21*REGBYTES(sp)
  STORE x22,22*REGBYTES(sp)
  STORE x23,23*REGBYTES(sp)
  STORE x24,24*REGBYTES(sp)
  STORE x25,25*REGBYTES(sp)
  STORE x26,26*REGBYTES(sp)
  STORE x27,27*REGBYTES(sp)
  STORE x28,28*REGBYTES(sp)
  STORE x29,29*REGBYTES(sp)
  STORE x30,30*REGBYTES(sp)
  STORE x31,31*REGBYTES(sp)
  csrrw t0,sscratch,sp
  STORE t0,2*REGBYTES(sp)
  csrr  t0,sstatus
  STORE t0,32*REGBYTES(sp)
  csrr  t0,sepc
  STORE t0,33*REGBYTES(sp)
  csrr  t0,sbadaddr
  STORE t0,34*REGBYTES(sp)
  csrr  t0,scause
  STORE t0,35*REGBYTES(sp)

  move  a0, sp
  j handle_trap

RVTEST_RV64U
# RVTEST_CODE_BEGIN
        .text;
        .global extra_boot;
extra_boot:
        EXTRA_INIT
        ret;
        .global userstart;
userstart:
_fuzz_main:
_l0:;
        /* Fuzz main */
        /**/
// RVTEST_CODE_END
        ecall
        unimp
_end_main:
        unimp
        unimp
        unimp
        unimp
        unimp
        unimp
        unimp
        unimp

RVTEST_CODE_END

  .data

RVTEST_DATA_BEGIN

        .align 8
xreg_output_data:
reg_x0_output:  .dword 0x0000000000000000
reg_x1_output:  .dword 0x0000000000000000
reg_x2_output:  .dword 0x0000000000000000
reg_x3_output:  .dword 0x0000000000000000
reg_x4_output:  .dword 0x0000000000000000
reg_x5_output:  .dword 0x0000000000000000
reg_x6_output:  .dword 0x0000000000000000
reg_x7_output:  .dword 0x0000000000000000
reg_x8_output:  .dword 0x0000000000000000
reg_x9_output:  .dword 0x0000000000000000
reg_x10_output: .dword 0x0000000000000000
reg_x11_output: .dword 0x0000000000000000
reg_x12_output: .dword 0x0000000000000000
reg_x13_output: .dword 0x0000000000000000
reg_x14_output: .dword 0x0000000000000000
reg_x15_output: .dword 0x0000000000000000
reg_x16_output: .dword 0x0000000000000000
reg_x17_output: .dword 0x0000000000000000
reg_x18_output: .dword 0x0000000000000000
reg_x19_output: .dword 0x0000000000000000
reg_x20_output: .dword 0x0000000000000000
reg_x21_output: .dword 0x0000000000000000
reg_x22_output: .dword 0x0000000000000000
reg_x23_output: .dword 0x0000000000000000
reg_x24_output: .dword 0x0000000000000000
reg_x25_output: .dword 0x0000000000000000
reg_x26_output: .dword 0x0000000000000000
reg_x27_output: .dword 0x0000000000000000
reg_x28_output: .dword 0x0000000000000000
reg_x29_output: .dword 0x0000000000000000
reg_x30_output: .dword 0x0000000000000000
reg_x31_output: .dword 0x0000000000000000

        .align 8
freg_output_data:
reg_f0_output:  .dword 0x0000000000000000
reg_f1_output:  .dword 0x0000000000000000
reg_f2_output:  .dword 0x0000000000000000
reg_f3_output:  .dword 0x0000000000000000
reg_f4_output:  .dword 0x0000000000000000
reg_f5_output:  .dword 0x0000000000000000
reg_f6_output:  .dword 0x0000000000000000
reg_f7_output:  .dword 0x0000000000000000
reg_f8_output:  .dword 0x0000000000000000
reg_f9_output:  .dword 0x0000000000000000
reg_f10_output: .dword 0x0000000000000000
reg_f11_output: .dword 0x0000000000000000
reg_f12_output: .dword 0x0000000000000000
reg_f13_output: .dword 0x0000000000000000
reg_f14_output: .dword 0x0000000000000000
reg_f15_output: .dword 0x0000000000000000
reg_f16_output: .dword 0x0000000000000000
reg_f17_output: .dword 0x0000000000000000
reg_f18_output: .dword 0x0000000000000000
reg_f19_output: .dword 0x0000000000000000
reg_f20_output: .dword 0x0000000000000000
reg_f21_output: .dword 0x0000000000000000
reg_f22_output: .dword 0x0000000000000000
reg_f23_output: .dword 0x0000000000000000
reg_f24_output: .dword 0x0000000000000000
reg_f25_output: .dword 0x0000000000000000
reg_f26_output: .dword 0x0000000000000000
reg_f27_output: .dword 0x0000000000000000
reg_f28_output: .dword 0x0000000000000000
reg_f29_output: .dword 0x0000000000000000
reg_f30_output: .dword 0x0000000000000000
reg_f31_output: .dword 0x0000000000000000

        .align 8
csr_output_data:
ustatus_output:        .dword 0x0000000000000000                   
uie_output:            .dword 0x0000000000000000               
utvec_output:          .dword 0x0000000000000000                 
uscratch_output:       .dword 0x0000000000000000                    
uepc_output:           .dword 0x0000000000000000                
ucause_output:         .dword 0x0000000000000000                  
utval_output:          .dword 0x0000000000000000                 
uip_output:            .dword 0x0000000000000000               
fflags_output:         .dword 0x0000000000000000                 
frm_output:            .dword 0x0000000000000000               
fcsr_output:           .dword 0x0000000000000000                
sstatus_output:        .dword 0x0000000000000000                   
sedeleg_output:        .dword 0x0000000000000000                   
sideleg_output:        .dword 0x0000000000000000                   
sie_output:            .dword 0x0000000000000000               
stvec_output:          .dword 0x0000000000000000                 
scounteren_output:     .dword 0x0000000000000000 
sscratch_output:       .dword 0x0000000000000000                    
sepc_output:           .dword 0x0000000000000000                
scause_output:         .dword 0x0000000000000000                  
stval_output:          .dword 0x0000000000000000                 
sip_output:            .dword 0x0000000000000000               
satp_output:           .dword 0x0000000000000000                
mhartid_output:        .dword 0x0000000000000000                   
mstatus_output:        .dword 0x0000000000000000                   
medeleg_output:        .dword 0x0000000000000000                   
mideleg_output:        .dword 0x0000000000000000                   
mie_output:            .dword 0x0000000000000000               
mtvec_output:          .dword 0x0000000000000000                 
mcounteren_output:     .dword 0x0000000000000000     
mscratch_output:       .dword 0x0000000000000000                    
mepc_output:           .dword 0x0000000000000000                
mcause_output:         .dword 0x0000000000000000                  
mtval_output:          .dword 0x0000000000000000                 
mip_output:            .dword 0x0000000000000000               
pmpcfg0_output:        .dword 0x0000000000000000                   
pmpcfg1_output:        .dword 0x0000000000000000                   
pmpcfg2_output:        .dword 0x0000000000000000                   
pmpcfg3_output:        .dword 0x0000000000000000                   
pmpaddr0_output:       .dword 0x0000000000000000                    
pmpaddr1_output:       .dword 0x0000000000000000                    
pmpaddr2_output:       .dword 0x0000000000000000                    
pmpaddr3_output:       .dword 0x0000000000000000                    
pmpaddr4_output:       .dword 0x0000000000000000                    
pmpaddr5_output:       .dword 0x0000000000000000                    
pmpaddr6_output:       .dword 0x0000000000000000                    
pmpaddr7_output:       .dword 0x0000000000000000                    
pmpaddr8_output:       .dword 0x0000000000000000                    
pmpaddr9_output:       .dword 0x0000000000000000                    
pmpaddr10_output:      .dword 0x0000000000000000 
pmpaddr11_output:      .dword 0x0000000000000000 
pmpaddr12_output:      .dword 0x0000000000000000 
pmpaddr13_output:      .dword 0x0000000000000000 
pmpaddr14_output:      .dword 0x0000000000000000 
pmpaddr15_output:      .dword 0x0000000000000000 
mcycle_output:         .dword 0x0000000000000000     
minstret_output:       .dword 0x0000000000000000                    
mcycleh_output:        .dword 0x0000000000000000                   
minstreth_output:      .dword 0x0000000000000000         

RVTEST_DATA_END  

    .section .data.random0;
    .align  8;

_random_data0:
                .dword 0xb842c598cc43f188, 0x51cce0f1b8d94738
                .dword 0x26300abef764b9f0, 0x528fe290e3409186
d_0_0:          .dword 0x29911fefb97b146f, 0x8709ea0dc2d5353c
d_0_1:          .dword 0x222bf7896438704f, 0xcd9910e2db760529
d_0_2:          .dword 0xe5375f5254c7ab33, 0xb9007d587eb3e37e
d_0_3:          .dword 0x934905b2e20709b6, 0x32d6a3f7c1298874
d_0_4:          .dword 0xa0d1a33b1dd868fe, 0x40fcba84e1d186f7
d_0_5:          .dword 0x64d0835d7f37a47b, 0xbc002c8d89593c24
d_0_6:          .dword 0x484378d92f314da8, 0x3984e32be03d6ed6
d_0_7:          .dword 0x1b58474c99aff7db, 0xccaa5a4c923c303b
d_0_8:          .dword 0xaac6241530fcc730, 0xbc70c9b5de368eac
d_0_9:          .dword 0xd5ecda20bb422594, 0x18df7a5a03632e70
d_0_10:         .dword 0x3825867fe722e3bb, 0xa92de99894b98b20
d_0_11:         .dword 0x92dbb46327d912fb, 0x21f1d843a289f2aa
d_0_12:         .dword 0x5309604bcccc6678, 0xa2c61c6650812317
d_0_13:         .dword 0x6f91cebf8e3a9240, 0x67216140d402a361
d_0_14:         .dword 0xdb0e16edcf3b8638, 0xd83e1c3a8d40c845
d_0_15:         .dword 0x1e92c417d0443d2b, 0x1f2118f9bf29d474
d_0_16:         .dword 0x8acdc951668b094d, 0xe8f068f8b6ce7cfb
d_0_17:         .dword 0xba5e38dca0622a02, 0x6b8fa68e36b15616
d_0_18:         .dword 0x7a2bac68ec324861, 0x68900f5d9e7668e0
d_0_19:         .dword 0xbd7438c38bec9765, 0xeed5277172d47295
d_0_20:         .dword 0x751e98323571abac, 0x7924e93b32d16596
d_0_21:         .dword 0xf6f46d6f5095b70c, 0x3efb069de39df3d8
d_0_22:         .dword 0x3fcf899553b0dbd7, 0x3500654d1287cb54
d_0_23:         .dword 0x2c4a5e9f6512a4ab, 0xb8a296997b5a6e1e
d_0_24:         .dword 0x3204754cb6470d1c, 0xf8edc759c42ed6bb
d_0_25:         .dword 0x728968a2aa053e1b, 0xee10daafa19f864e
d_0_26:         .dword 0x167ee7540b111752, 0x9f05387a67cb4ce1
d_0_27:         .dword 0x4ebe3b493c201508, 0x0e696c3f69783e77
                .dword 0x2a9bcb8392ece910, 0x1964596953a8db71
                .dword 0x9bb9d469b5bb24a2, 0xb996c15ae34c4a68
        /* Random data */
_end_data0:
                 

    .section .data.random1;
    .align  8;

_random_data1:
                .dword 0x1b2102e379d29bf1, 0x515e7828efb0570c
                .dword 0x3b2c4130baffbe4e, 0x53f7317db55cfa6f
d_1_0:          .dword 0xd7117ce832625180, 0x15bd9dd9f70f8be8
d_1_1:          .dword 0xf779766b3c86e807, 0xb7e4b87fc862f7c5
d_1_2:          .dword 0x07a6b1b55f328e0f, 0x8c39a666e7fe9e21
d_1_3:          .dword 0xcb0e3e960291f2b0, 0x5945da7981aaeea3
d_1_4:          .dword 0xb11e09563c16f9ff, 0xec02209e998b0cc4
d_1_5:          .dword 0x8ae49950b1b92c0b, 0x16d524497dde53ed
d_1_6:          .dword 0xf2d9ac3d45f9dbb6, 0x59bca53c8d03801a
d_1_7:          .dword 0x6e1fb8fa22cda90a, 0x71a7f4a9d441a517
d_1_8:          .dword 0x3c6836871b98784f, 0xb60676f9e6bc0cf4
d_1_9:          .dword 0x616c3aa0fb3cf882, 0x6c3eed8e65d95c29
d_1_10:         .dword 0xc3ab2d39a21715e3, 0x4e128aed67c07ffa
d_1_11:         .dword 0xc41a9ca8e0e2f84f, 0xe5ce0fce5b5c6f53
d_1_12:         .dword 0x80a6c59ad3d37319, 0x2a37e81244b5660f
d_1_13:         .dword 0x253b0edcc5cd6790, 0x734efad19c95edee
d_1_14:         .dword 0xd734453a8ae6fbf2, 0x775bc5cd6674c2b2
d_1_15:         .dword 0xb9469103fff8b066, 0x58747eca29531283
d_1_16:         .dword 0x065d92be779a26f3, 0x0efefb85e420654a
d_1_17:         .dword 0x2cd52790334ada40, 0x78822d2c4c1b14c6
d_1_18:         .dword 0x19f4dc061495b31e, 0x027dfc190bd7dc0c
d_1_19:         .dword 0xf3071fd7adb02937, 0x3200bc4bebb054ba
d_1_20:         .dword 0x502145520e54bcfa, 0xfcbb0c58dc939d3c
d_1_21:         .dword 0x560af429953ae996, 0x0ca175973caf13c7
d_1_22:         .dword 0x2e844b07c0f20ed3, 0x590c7650d7da715c
d_1_23:         .dword 0x71dcdbe869579a66, 0xdc39263d00f584e2
d_1_24:         .dword 0x96fc65c1e886a443, 0x6e21c0be441c737d
d_1_25:         .dword 0x0be243ec8aa40307, 0x99a4f1b0f5eab008
d_1_26:         .dword 0xa13d3883d83e1b93, 0xfc4bbf8eafc70590
d_1_27:         .dword 0x8f00c27378948524, 0x27c57f4e9195bce0
                .dword 0x61818f900b29b9ce, 0x6d705043b7aaf23d
                .dword 0x4a50fe3c5f6a1dee, 0xf307377b877d2898
        /* Random data */
_end_data1:


    .section .data.random2;
    .align  8;

_random_data2:
                .dword 0x4cd8d44511fc47d7, 0x9dbb2435736d8dd1
                .dword 0x123fa7ce61d22bed, 0x3cbd090522e660cb
d_2_0:          .dword 0xbfa282756c6282db, 0x0ec19feca226f560
d_2_1:          .dword 0x4d64762945a2deee, 0xb9acfae1a401056c
d_2_2:          .dword 0xf7ca834b6908447f, 0x764794c24c848c30
d_2_3:          .dword 0x4591e5fcd22c8307, 0x2588e8eb71cec693
d_2_4:          .dword 0xe2fe79219926dd39, 0x0c13f745d716ec00
d_2_5:          .dword 0x8a90419ac3858b29, 0x6333d3d499ece0e9
d_2_6:          .dword 0xb5074fe1fb246a3f, 0x8064fb69f357ee0c
d_2_7:          .dword 0x867a3f22a2bd20db, 0x463ee0c17025630e
d_2_8:          .dword 0xa84712ba1550a73a, 0xb7db236c0245a4b1
d_2_9:          .dword 0x6ce0e6f73e309944, 0x0d3b29b68e5d4e5f
d_2_10:         .dword 0xee6a16161fb1ad70, 0x2145769678acd26b
d_2_11:         .dword 0xb9c404f99dcaaf5f, 0x2f50d91b320b1b06
d_2_12:         .dword 0x8df4e9d0b688f646, 0x04e6a3545e854721
d_2_13:         .dword 0xc02a05074fd507de, 0xe717b77173070b63
d_2_14:         .dword 0x7dcc34e29253056b, 0x03eaf55170f8fd61
d_2_15:         .dword 0x7ae0c620c305c4ab, 0xd723ba8dd7538f26
d_2_16:         .dword 0x7334c15a9f42ab6f, 0xc65571e1a234cf7c
d_2_17:         .dword 0x402b446dfe838fd1, 0x11991377f1e2ac80
d_2_18:         .dword 0xed1ba00b4b58a70b, 0xd617ba41781b37e9
d_2_19:         .dword 0x78eac57807937fc5, 0x926ec31407277be0
d_2_20:         .dword 0x389c847cdfe67e57, 0x38097d00797c0596
d_2_21:         .dword 0xcdbc7707deca749c, 0xdf2cde1b2a909f48
d_2_22:         .dword 0x68d0e9f3abfd3a6b, 0xa55a1277ea0f7823
d_2_23:         .dword 0x0ab6685fbc39fedc, 0xa607b37a5e385abe
d_2_24:         .dword 0x6d03bbcf784f83e0, 0xfbde3fc7d1f9ddfd
d_2_25:         .dword 0xe43db2d567cb732e, 0xfa2ac5baaf58044d
d_2_26:         .dword 0x0120a44ddc3c62b4, 0x40d4df03d0ca89e6
d_2_27:         .dword 0x9fa6a6cb6353d1ef, 0x06a0ae336d21b6b3
                .dword 0x89cb886b2ed2b427, 0xfb81739a6590a4f4
                .dword 0xe6bf2e125b97d971, 0x08ae6b3672b0b2c3
         /* Random data */
_end_data2:
                

    .section .data.random3;
    .align  8;

_random_data3:
                .dword 0x594af89917383f80, 0xbf709b3896ab6f75
                .dword 0x3f6e442f0ad6d984, 0x0170c5f3fa9b7d91
d_3_0:          .dword 0xd5062bb86f7d595a, 0x9af00cd7919d3c95
d_3_1:          .dword 0x59da9e6726da3669, 0x2aeea688ae2bc62a
d_3_2:          .dword 0xe23144f74245746b, 0x1202e87962892607
d_3_3:          .dword 0xc656034375f8c3a1, 0xa2e74753732e5dc2
d_3_4:          .dword 0xb46decb0609122b4, 0x4cc241c2e9b998e7
d_3_5:          .dword 0x278b3ebd17cf3164, 0xf6c161a0015e7309
d_3_6:          .dword 0x60b2ab69df3a7ffa, 0xc95c5e6f68e09fe5
d_3_7:          .dword 0x29c057deb24e61fc, 0x846e4a1ec31ef4c8
d_3_8:          .dword 0x3eaf4dd29047d0ba, 0xd35be3f32cc4b526
d_3_9:          .dword 0xd8554ab42a9aaed4, 0x160992ab82d7bc23
d_3_10:         .dword 0x71b022a8fa9ad637, 0xae19dab82e1e92ea
d_3_11:         .dword 0x6c3efe4bd1b6a05b, 0x59f9b273b47bacf3
d_3_12:         .dword 0xbe380087d9d979b7, 0x91e04b31cd24a57c
d_3_13:         .dword 0xa09bf25edccf183b, 0xd971ee6a0c464059
d_3_14:         .dword 0x1ba3673aa1cf6e30, 0x9ce7ecf6dc7eb929
d_3_15:         .dword 0xc427f4f88230818a, 0x1fe968f2d290ef96
d_3_16:         .dword 0x51106bfe3aedca5b, 0xe83f879e797ecf25
d_3_17:         .dword 0x5d2d271b8d9e591b, 0x886b65eb3dbd30af
d_3_18:         .dword 0x5423bbb8de54a087, 0x8448575a42a24c63
d_3_19:         .dword 0x92e4380954099edf, 0x4dc00b42cd3ef3ef
d_3_20:         .dword 0x6b4769a4c87d8a2d, 0xaae10951034022eb
d_3_21:         .dword 0x378bbcfe681340b6, 0x9a94fcf4991a162d
d_3_22:         .dword 0xdf6988277aa9808d, 0x226e366fb36a5ba4
d_3_23:         .dword 0x50bb06c1ff65d0b2, 0x46249d0d5ea66a11
d_3_24:         .dword 0xedaaa0db5bbab3fa, 0x308bd4bb96c77c25
d_3_25:         .dword 0x151d6b4ac73ba181, 0xe891a53f9efa344b
d_3_26:         .dword 0xaf088edb76a0f21a, 0x6c0090c6a8191d9f
d_3_27:         .dword 0x3c9bfccce9cceb0a, 0x4fb0d91d95fee10f
                .dword 0xd7625d800abe8052, 0x15ca516e6f177cd8
                .dword 0xc7c19da809a5ef0b, 0x445b72913b137352
        /* Random data */
_end_data3:


    .section .data.random4;
    .align  8;

_random_data4:
                .dword 0x1ab9936a621c803c, 0xb123dc76d1d38e19
                .dword 0x20350f3354d02cbe, 0xb35b724b9ef7f974
d_4_0:          .dword 0xe5f4e2b43b2e11f5, 0x72c264178e25b166
d_4_1:          .dword 0x283b1f89ddc3081a, 0x1f557ad7f2d6a7f1
d_4_2:          .dword 0x8e722e39b29f5884, 0x9c75603e290d0df1
d_4_3:          .dword 0x412495c5608d4dbc, 0x709d9c6db5471004
d_4_4:          .dword 0xf3bd314b364a8c6a, 0xf1d5bf83cf3afe63
d_4_5:          .dword 0x0c19c09988eb3306, 0x708ed1cb44b378f6
d_4_6:          .dword 0xd2480127cc7b1541, 0xb4f4e9f6695c11f9
d_4_7:          .dword 0x531671adb979bb55, 0x3a44284ec2c09eaf
d_4_8:          .dword 0x2e0a55b85dc09fca, 0x4ae960fa8ba48955
d_4_9:          .dword 0x66b2ecdf2b0beeb8, 0xe6b3c3b7fcea898a
d_4_10:         .dword 0xb7198118e13ae079, 0x69abde4f44cc9b51
d_4_11:         .dword 0x1e9f520d0edf66ed, 0xbc50e42e4da01c42
d_4_12:         .dword 0x84cb279a31d85a83, 0xe396e2eac040448e
d_4_13:         .dword 0x248cfa0b03815f25, 0xc5c89ce044f86aa2
d_4_14:         .dword 0xaec5ef125904ae6c, 0xc8901b4681ac1d85
d_4_15:         .dword 0x22bce96f87d4a7b6, 0x5379d9b7f76abe40
d_4_16:         .dword 0xa4e7e079636c5dc4, 0x213d0b4970ec0140
d_4_17:         .dword 0x86539ecdb73e55fb, 0x1835fde3ee3380e1
d_4_18:         .dword 0x27f7422f347c1626, 0x546f925b13b645b2
d_4_19:         .dword 0x567553be03a73f98, 0xade4bcbd4f1a3aaf
d_4_20:         .dword 0xad6190cf8057f351, 0x6dc6a574181a074b
d_4_21:         .dword 0x55049b0ccd779b8f, 0x1ffdd8d881e5325e
d_4_22:         .dword 0x16258e2947d435a4, 0x3db4da59f6110b73
d_4_23:         .dword 0x8cb61d1a3907624e, 0x832ca0b88a5bfeab
d_4_24:         .dword 0xdd22908bcabab780, 0xd178e8b6acfaf5c9
d_4_25:         .dword 0x590f04f1c420df6a, 0x6579721e0440194d
d_4_26:         .dword 0x4dc1b2a3b3a48c9f, 0x01a2e87fd991682a
d_4_27:         .dword 0x59844b934e80cb5e, 0x62874b119fa04d7e
                .dword 0x767ec2d4ec85aa53, 0xeb84c19fb09958de
                .dword 0xe03d641430d3bc8c, 0xd1e4a28c0b67df93
        /* Random data */
_end_data4:


    .section .data.random5;
    .align  8;

_random_data5:
                .dword 0x6263b39925c737df, 0xa806ed4b6eafeb1f
                .dword 0x07ec8d62d14226fc, 0x9daf749351eac15c
d_5_0:          .dword 0x2bbde5a0281c77a3, 0x19301223b720b412
d_5_1:          .dword 0xec8246ae18545ca4, 0x30e594fc726beb9e
d_5_2:          .dword 0x852a564f113308bd, 0xcf7815e2fbb9e6a9
d_5_3:          .dword 0xeae2194396620a4a, 0xef2115f6930dc232
d_5_4:          .dword 0x276e3efbc2c02c90, 0x2b93adb06fd6a3bb
d_5_5:          .dword 0x5565953c1cb24baa, 0xce775db878ab9bc0
d_5_6:          .dword 0x70c037e76e5bc428, 0x1b09c7f2fb993a3f
d_5_7:          .dword 0x156bacbc070dbd4a, 0xd3c27558f36edbad
d_5_8:          .dword 0x19e54f59f4902de0, 0x5a3ff6ebd76190d2
d_5_9:          .dword 0x966f40226ec2e7fb, 0x4cf90c9dc8af03ae
d_5_10:         .dword 0xbcf75425014e77f6, 0xbc9f47eae069bd01
d_5_11:         .dword 0x8f01fb12c9e6702f, 0xa7d084f730da0d20
d_5_12:         .dword 0x918134f1b4ef2f1e, 0x1c6e2cc0f3bb94ce
d_5_13:         .dword 0xda8eb66dd38522ed, 0xe78f59946f838d45
d_5_14:         .dword 0xf054c012dcfd67b2, 0x8ea8bab907ad8d28
d_5_15:         .dword 0xdd571e20c95408bd, 0xd644fff703b832d8
d_5_16:         .dword 0x85c042fb3252a6b4, 0x8135b4abe4b9d0d8
d_5_17:         .dword 0x7fc750ebb04af32c, 0x53a83fc9d32452a3
d_5_18:         .dword 0x8462d84602968ba4, 0x978b38709f87dc55
d_5_19:         .dword 0x9879bc534874c1a5, 0xbac6dc2f6b99c125
d_5_20:         .dword 0x4a06843a36a3247c, 0x06d96fd9f1e1d08e
d_5_21:         .dword 0xe5e56d72eb381c52, 0x6bb6a930c4b613be
d_5_22:         .dword 0x586fb4b25f1bd1a7, 0x17b54733c0129b80
d_5_23:         .dword 0x7a16581585531ac9, 0xa6b6b242a88487d7
d_5_24:         .dword 0x1184ce4791e36e10, 0xb16acc2d611d2b13
d_5_25:         .dword 0xf157350db9d09200, 0x900d038841a62631
d_5_26:         .dword 0x9da4a80b0aa87e6f, 0x08b2b7941f951938
d_5_27:         .dword 0xf5a0021a4157ff5b, 0xdb93705886c16060
                .dword 0x5dd32015948e6f76, 0x47c833a2d2fd7ebc
                .dword 0x3b9345776cc5afce, 0x50d0a7e1261cbab7
         /* Random data */
_end_data5:
              
 
