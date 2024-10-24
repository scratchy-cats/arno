use core::arch::asm;

#[allow(non_camel_case_types)]
enum BitMasks {
  MSTATUS_MPP_CLEARER = 3 << 11,
  MSTATUS_MPP_SUPERVISOR = 1 << 11,
}

// The mstatus (Machine Status) register keeps track of and controls the hart's current operating
// state.
// REFER : section 3.1.6 in privileged ISA manual.
pub struct Mstatus;

impl Mstatus {
  // NOTE : xPP (x = current privilege mode) bits represent the privilege mode prior to the trap.

  // Clears the MPP bits.
  #[inline]
  unsafe fn clearMppBits(&self) {
    asm!("csrc mstatus, {}", in(reg)BitMasks::MSTATUS_MPP_CLEARER as usize);
  }

  // Before switching to S-mode, we'll set the MPP bits to 01. If any trap occurs in S-mode, and we
  // fallback to M-mode using the MRET instruction, then in M-mode, we'll read the MPP bits and
  // know that we fell back from S-mode.
  #[inline]
  pub unsafe fn setMppBitsToSMode(&self) {
    self.clearMppBits();
    asm!("csrs mstatus, {}", in(reg)BitMasks::MSTATUS_MPP_SUPERVISOR as usize);
  }
}
