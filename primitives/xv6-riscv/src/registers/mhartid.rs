use core::arch::asm;

// The mhartid register is a read-only register containing the integer ID of the hardware thread
// running the code.
pub struct Mhartid;

impl Mhartid {
  #[inline]
  pub unsafe fn read(&self) -> usize {
    let hartId: usize;
    asm!("csrr {}, mhartid", out(reg)hartId);
    hartId
  }
}
