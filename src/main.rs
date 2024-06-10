#![no_std]
#![no_main]

use core::arch::{asm, global_asm};

global_asm!(include_str!("asm/entry.S"));

mod cpu;
mod mmio;

#[no_mangle]
pub fn main() -> ! {
  mmio::UART.fifo_enable();

  mmio::UART.write_str("init\n");

  // // set the trap vector, and enable mie.MEIE
  unsafe {
    asm!("csrw mtvec, {0}", in(reg) irq_handler as usize);
    asm!("csrs mstatus, {0}", in(reg) 1 << 3);
    asm!("csrs mie, {0}", in(reg) 1 << 11);
  }
  mmio::UART.write_str("interrupts enabled\n");

  /* example of configuring external interupts via PLIC */

  // current hart in machine mode
  let context = mmio::PLICDriver::get_context(cpu::mhartid(), 0);
  // Set the priority of the UART interrupt to 1
  mmio::PLIC.set_priority(mmio::UARTDriver::interrupt_source(), 1);
  // Enable the UART interrupt for the current hart
  mmio::PLIC.set_enable(context, mmio::UARTDriver::interrupt_source());
  // Set the threshold to 0, so that all interrupts
  // with priority > 0 will trigger
  mmio::PLIC.set_threshold(context, 0);
  mmio::UART.write_str("uart interupts enabled in plic\n");

  // enable uart interupts
  mmio::UART.interrupt_enable(0x1);
  mmio::UART.write_str("uart interrupts enabled\n");

  // now, whenever a character is received, the uart
  // will trigger an interrupt, which will be handled
  // by the irq_handler function

  mmio::UART.write_str("done\n");

  loop {}
}

#[no_mangle]
pub extern "C" fn irq_handler() {
  mmio::UART.write_str("interrupt\n");
  loop {}
}

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_info: &PanicInfo<'_>) -> ! {
  unsafe {
    loop {
      asm!("ebreak");
      asm!("wfi");
    }
  }
}
