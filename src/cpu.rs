use core::arch::asm;

pub fn mhartid() -> u32 {
  let id: u32;
  unsafe {
    asm!("csrr {0}, mhartid", out(reg) id);
  }
  id
}
