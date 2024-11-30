#![no_std]
#![no_main]

core::arch::global_asm!(include_str!("asm/entry.S"));
mod cpu;
mod mmio;

pub static mut PLIC: mmio::PLICDriver = mmio::PLICDriver {
  base: 0x0C00_0000 as _,
};

pub static mut UART: mmio::UARTDriver = mmio::UARTDriver {
  base: 0x1000_0000 as _,
};

pub const PLIC_SRC_UART: usize = 10;

#[no_mangle]
pub extern "C" fn main() {
  println!("intializing...");

  csrw!("mtvec", trap_handler as usize);
  println!("mtvec set");

  unsafe {
    UART.fifo_init();
  }
  println!("UART initialized");

  csrs!("mie", cpu::MIE_MEIE);
  csrs!(
    "mstatus",
    cpu::MSTATUS_MPP_M | cpu::MSTATUS_MPIE | cpu::MSTATUS_MIE
  );
  println!("interrupts enabled");

  let word = mmio::PLICDriver::word_index(0);
  unsafe {
    PLIC.set_priority(PLIC_SRC_UART, 1);
    PLIC.set_enable(word, PLIC_SRC_UART);
    PLIC.set_threshold(word, 0);
  }
  println!("PLIC initialized");

  unsafe {
    UART.interrupt_enable(1);
  }
  println!("UART interrupt enabled");

  println!("done, waiting for interrupt...");
  loop {
    wfi!();
  }
}

#[no_mangle]
pub extern "C" fn trap_handler() {
  println!("trap_handler");
  loop {}
}

#[macro_export]
macro_rules! print {
  ($($arg:tt)*) => {
    {
      use core::fmt::Write;
      unsafe { let _ = write!(crate::UART, $($arg)*); }
    }
  };
}

#[macro_export]
macro_rules! println {
  () => {
    print!("\n");
  };
  ($($arg:tt)*) => {
    {
      print!("{}\n", format_args!($($arg)*));
    }
  };
}

use core::panic::PanicInfo;
#[panic_handler]
fn panic(_info: &PanicInfo<'_>) -> ! {
  println!("panic!");
  loop {}
}
