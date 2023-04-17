#ifndef MIPS_TEST_EXCEPTION
#define MIPS_TEST_EXCEPTION

#ifndef START_USE_EXCEPTION
#error exception.S can only be included by start.S.in
#endif

#include <asm.h>
#include <regdef.h>
#include <cpu_cde.h>

//! NOTE: section .text must start from 0xBFC00000

//! TLB exceptions
.org 0x200
tlb_ex_handler:
    //! no exception expected, go fail directly
    b exception_failure
    nop

//! any other exceptions
.org 0x380
exception_dispatch:
    mfhi k0
    mflo k1
    li  k0, 0x800d0000
    lbu k1, 0x0(k0)

    //! syscall
    li  k0, 0x01
    beq k1, k0, syscall_ex
    nop

    //! break
    li  k0, 0x02
    beq k1, k0, break_ex
    nop

    //! overflow
    li  k0, 0x03
    beq k1, k0, overflow_ex
    nop

    //! adel (load)
    li  k0, 0x04
    beq k1, k0, adel_load_ex
    nop

    //! ades
    li  k0, 0x05
    beq k1, k0, ades_ex
    nop

    //! adel (inst fetch)
    li  k0, 0x06
    beq k1, k0, adel_if_ex
    nop

    //! reserved inst
    li  k0, 0x07
    beq k1, k0, reserved_inst_ex
    nop

    //! int
    li  k0, 0x08
    beq k1, k0, int_ex
    nop

    //! no exception matched, go fail
    b exception_failure
    nop

exception_finish:
    mfc0  k0, c0_cause
    lui   k1, 0x8000
    and   k0, k0, k1
    mfc0  k1, c0_epc
    addiu k1, k1, 0x4
    beq   k0, zero, 1f
    nop
    addiu k1, k1, 0x4
1:
    mtc0  k1,c0_epc
    nop
    bne   s2, zero, exception_return
    nop
    lui   s2, 0xffff

exception_return:
    .set mips32
    eret
    .set mips1
    nop

exception_failure:
    sll	t1, s0, 24
    or	t0, t1, s3
    sw	t0, 0(s1)
    jr	ra
    nop

    //! FIXME: code below is questionable
    b exception_finish
    nop

/*!
 * exception handlers begin
 */

syscall_ex:
    addu s2, zero, zero
    mfc0 k0, c0_epc
    bne  k0, s4, exception_finish
    nop
    mfc0 k0, c0_cause
    andi k0, k0, 0x7c               //!< 6..2
    li   k1, 0x20                   //!< 010_0000
    bne  k0, k1, exception_finish
    nop
    mfc0 k0, c0_status
    andi k0, k0, 0x02
    li   k1, 0x02
    bne  k0, k1, exception_finish
    nop
    lui  s2, 0x1
    b exception_finish
    nop

break_ex:
    addu s2, zero, zero
    mfc0 k0, c0_epc
    bne  k0, s4, exception_finish
    nop
    mfc0 k0, c0_cause
    andi k0, k0, 0x7c               //!< 6..2
    li   k1, 0x24                   //!< 010_0100
    bne  k0, k1, exception_finish
    nop
    mfc0 k0, c0_status
    andi k0, k0, 0x02               //!< exl
    li   k1, 0x02                   //!< exl = 1
    bne  k0, k1, exception_finish
    nop
    lui  s2, 0x2
    b exception_finish
    nop

overflow_ex:
    addu s2, zero, zero
    mfc0 k0, c0_epc
    bne  k0, s4, exception_finish
    mfc0 k0, c0_cause
    andi k0, k0, 0x7c               //!< 6..2 exc code
    li   k1, 0x30                   //!< 011_0000
    bne  k0, k1, exception_finish
    nop
    mfc0 k0, c0_status
    andi k0, k0, 0x02               //!< exl
    li   k1, 0x02                   //!< exl = 1
    bne  k0, k1, exception_finish
    nop
    lui s2, 0x3
    b exception_finish
    nop

adel_load_ex:
    addu s2, zero, zero
    mfc0 k0, c0_epc
    bne  k0, s4, exception_finish
    nop
    mfc0 k0, c0_cause
    andi k0, k0, 0x7c               //!< 6..2 exc code
    li   k1, 0x10                   //!< 001_0000
    bne  k0, k1, exception_finish
    nop
    mfc0 k0, c0_status
    andi k0, k0, 0x02               //!< exl
    li k1, 0x02                     //!< exl = 1
    bne k0, k1, exception_finish
    nop
    lui s2, 0x4
    b exception_finish
    nop

ades_ex:
    addu s2, zero, zero
    mfc0 k0, c0_epc
    bne  k0, s4, exception_finish
    nop
    mfc0 k0, c0_cause
    andi k0, k0, 0x7c               //!< 6..2 exc code
    li   k1, 0x14                   //!< 001_0100
    bne  k0, k1, exception_finish
    nop
    mfc0 k0, c0_status
    andi k0, k0, 0x02               //!< exl
    li k1, 0x02                     //!< exl = 1
    bne k0, k1, exception_finish
    nop
    lui s2, 0x5
    b exception_finish
    nop

adel_if_ex:
    addu s2, zero, zero
    mfc0 k0, c0_epc
    bne  k0, s4, exception_finish
    nop
    mtc0 s5, c0_epc
    mfc0 k0, c0_cause
    andi k0, k0, 0x7c               //!< 6..2 exc code
    li   k1, 0x10                   //!< 001_0000
    bne  k0, k1, exception_finish
    nop
    mfc0 k0, c0_status
    andi k0, k0, 0x02               //!< exl
    li k1, 0x02                     //!< exl = 1
    bne k0, k1, exception_finish
    nop
    lui s2, 0x6
    b exception_finish
    nop

reserved_inst_ex:
    addu s2, zero, zero
    mfc0 k0, c0_epc
    bne  k0, s4, exception_finish
    nop
    mfc0 k0, c0_cause
    andi k0, k0, 0x7c               //!< 6..2 exc code
    li   k1, 0x28                   //!< 010_1000
    bne  k0, k1, exception_finish
    nop
    mfc0 k0, c0_status
    andi k0, k0, 0x02               //!< exl
    li k1, 0x02                     //!< exl = 1
    bne k0, k1, exception_finish
    nop
    lui s2, 0x7
    b exception_finish
    nop

int_ex:
    addu s2, zero, zero
    mfc0 k0, c0_epc
    bne  k0, s4, exception_finish
    nop
    addiu k0, k0, 8
    mtc0  k0, c0_epc                //!< epc + 8
    disable_trace_cmp_s
    mfc0 k0, c0_cause               //!< don't compare cause.bd
    enable_trace_cmp_s
    andi k0, k0, 0x7c               //!< 6..2 exc code
    li   k1, 0x00                   //!< 000_0000
    bne  k0, k1, exception_finish
    nop
    mfc0 k0, c0_status
    andi k0, k0, 0x02               //!< exl
    li k1, 0x02                     //!< exl = 1
    bne k0, k1, exception_finish
    nop
    li   k0, 0xffffffff
    li   k1, 0x00000000
    mtc0 k0, c0_compare             //!< clear c0 compare
    mtc0 k1, c0_cause
    lui s2, 0x8
    b exception_return
    nop

#endif
