use core::arch::asm;

#[allow(non_camel_case_types)]
enum BitMasks {
  SUPERVISOR_INTERRUPTS_DISABLER = 0 << 1,
  SUPERVISOR_INTERRUPTS_ENABLER = 1 << 1,
}

// The sstatus (Supervisor Status) register, keeps track of the processor’s current operating state.
// REFER : section 10.1.1 in privileged ISA manual.
pub struct Sstatus;

// The SIE bit enables or disables all interrupts in supervisor mode. When SIE is clear, interrupts
// are not taken while in supervisor mode.
// When the hart is running in user-mode, the value in SIE is ignored, and supervisor-level
// interrupts are enabled. The supervisor can disable individual interrupt sources using the sie
// CSR.
impl Sstatus {
  // Returns whether all interrupts are disabled or not.
  #[inline]
  pub unsafe fn areInterruptsEnabled(&self) -> bool {
    let mut bits: usize;
    asm!("csrr {}, sstatus", out(reg)bits);

    (bits & BitMasks::SUPERVISOR_INTERRUPTS_DISABLER as usize) != 1
  }

  // Disable all interrupts by clearing the SIE bits.
  #[inline]
  pub unsafe fn disableInterrupts(&self) {
    asm!("csrc sstatus, {}", in(reg)BitMasks::SUPERVISOR_INTERRUPTS_DISABLER as usize);
  }

  // Enable all interrupts by setting the SIE bits.
  #[inline]
  pub unsafe fn enableInterrupts(&self) {
    asm!("csrc sstatus, {}", in(reg)BitMasks::SUPERVISOR_INTERRUPTS_ENABLER as usize);
  }
}
