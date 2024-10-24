use core::arch::asm;

/*
  By default, all traps at any privilege level are handled in machine mode, though a machine-mode
  handler can redirect traps back to the appropriate level with the MRET instruction.
  To increase performance, implementations can provide individual read/write bits within medeleg (
  Machine Trap Delegation) and mideleg (Machine Interrupt Delegation) registers to indicate that
  certain exceptions and interrupts should be processed directly by a lower privilege level.

  NOTE : Traps never transition from a more-privileged mode to a less-privileged mode.
*/
// REFER : section 3.1.8 in privileged ISA manual.
pub struct Medeleg;

impl Medeleg {
  #[inline]
  pub unsafe fn delegateExceptionsToSMode(&self) {
    asm!("csrw medeleg, {}", in(reg)0xffff);
  }
}
