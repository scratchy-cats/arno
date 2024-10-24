use core::arch::asm;

// The satp (Supervisor Address Translation and Protection) registers controls supervisor-mode
// address translation and protection.
// REFER : section 10.1.11 in privileged ISA manual.
pub struct Satp;

impl Satp {
  #[inline]
  pub unsafe fn disablePaging(&self) {
    asm!("csrw satp, {}", in(reg)0);
  }
}
