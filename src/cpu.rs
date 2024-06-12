#[macro_export]
macro_rules! wfi {
  () => {
    unsafe {
      core::arch::asm!("wfi");
    }
  };
}

#[macro_export]
macro_rules! mret {
  () => {
    unsafe {
      core::arch::asm!("mret");
      core::hint::unreachable_unchecked();
    }
  };
}

#[macro_export]
macro_rules! csrr {
  ($rd:expr, $csr:literal) => {
    unsafe {
      core::arch::asm!(concat!("csrr {0}, ", $csr), out(reg) $rd);
    }
  };
}

#[macro_export]
macro_rules! csrw {
  ($csr:literal, $rs:expr) => {
    unsafe {
      core::arch::asm!(concat!("csrw ", $csr, ", {0}"), in(reg) $rs);
    }
  };
}

#[macro_export]
macro_rules! csrs {
  ($csr:literal, $rs:expr) => {
    unsafe {
      core::arch::asm!(concat!("csrs ", $csr, ", {0}"), in(reg) $rs);
    }
  };
}

#[macro_export]
macro_rules! csrc {
  ($csr:literal, $rs:expr) => {
    unsafe {
      core::arch::asm!(concat!("csrc ", $csr, ", {0}"), in(reg) $rs);
    }
  };
}

pub const MSTATUS_MIE: u32 = 1 << 3;
pub const MSTATUS_MPIE: u32 = 1 << 7;
// pub const MSTATUS_MPP: u32 = 3 << 11;
pub const MSTATUS_MPP_M: u32 = 3 << 11;
// pub const MSTATUS_MPP_S: u32 = 1 << 11;

// pub const MIE_MSIE: u32 = 1 << 3;
// pub const MIE_MTIE: u32 = 1 << 7;
pub const MIE_MEIE: u32 = 1 << 11;
