use core::arch::asm;

// When a trap is taken into M-mode, the mepc (Machine Exception Program counter) register is
// written with the virtual address of the instruction that was interrupted or that encountered the
// exception.
// REFER : section 3.1.14 in privileged ISA manual.
pub struct Mepc;

impl Mepc {
  #[inline]
  pub unsafe fn set(&self, address: usize) {
    asm!("csrw mepc, {}", in(reg)address);
  }
}
