use {
  super::core::Core,
  crate::arch::riscv::{qemu::MAX_CORES, registers::tp::Tp},
  array_macro::array,
};

pub struct _CPU([Core; MAX_CORES]);

impl _CPU {
  pub const fn new() -> Self {
    /*
      (1) We cannot use std::array::from_fn( ), since we cannot depend on the standard library.

      (2) And doing [Core::new( ); MAX_CORES] would require us to derive Copy trait for Core, since
          Rust will try to duplicate / copy Core::new( ) (MAX_CORES - 1) times.

      That's why, using array_macro::array! is appropriate here. It instantiates Core separately,
      MAX_CORES times.
    */
    Self(array![_ => Core::new( ); MAX_CORES])
  }

  // Returns the CPU core on which the invoker is running.
  pub unsafe fn getCurrentCore(&mut self) -> &mut Core {
    let hartID = Tp.read();
    &mut self.0[hartID]
  }
}

pub static mut CPU: _CPU = _CPU::new();
