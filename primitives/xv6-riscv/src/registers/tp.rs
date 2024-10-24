use core::arch::asm;

// The tp (Thread Pointer) register stores the id of the hardware thread on which we're currently
// running.
// Before switching to U-mode, the Kernel saves the value of this register in the stack. On return
// from the U-mode, that value is restored back.
pub struct Tp;

impl Tp {
  #[inline]
  pub unsafe fn write(&self, hartId: usize) {
    asm!("mv tp, {}", in(reg)hartId);
  }
}
