use core::arch::asm;

const MSTATUS_MPP_CLEARER_MASK: usize = 3 << 11;
const MSTATUS_MPP_SUPERVISOR: usize = 1 << 11;

// REFER : section 3.1.6 in privileged ISA manual.
// Keeps track of and controls the hart's current operating state.
pub struct Mstatus;

impl Mstatus {
  #[inline]
  unsafe fn read(&self) -> usize {
    let x: usize;
    asm!("csrr {}, mstatus", out(reg)x);
    x
  }

  #[inline]
  unsafe fn write(&self, x: usize) {
    asm!("csrw mstatus, {}", in(reg)x);
  }

  // This function sets the MPP bits to 01.
  // When the Kernel boots up, we're in M-mode. If any trap occurs in M-mode, it'll fallback to
  // S-mode using the MRET instruction. Then in the S-mode, we can read the MPP bits of this mstatus
  // register to know that a trap occurred in M-mode followed by a fallback.
  /*
    NOTE : A trap is an event of transfer of control to a trap handler caused by either an exception
    or an interrupt.
  */
  pub unsafe fn setMppToSMode(&self) {
    let mut x = self.read();
    x &= !MSTATUS_MPP_CLEARER_MASK; // Clear MPP bits (set them to 0).
    x |= MSTATUS_MPP_SUPERVISOR;
    self.write(x);
  }
}