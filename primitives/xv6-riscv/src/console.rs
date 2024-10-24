use core::{
  fmt::{self, Write},
  ptr::write_volatile,
};

/*
  UART (Universal Asynchronous Receiver/Transmitter) is a hardware protocol used for asynchronous
  serial communication between 2 devices.

  Read in detail : https://www.rohde-schwarz.com/us/products/test-and-measurement/essentials-test-equipment/digital-oscilloscopes/understanding-uart_254524.html.

  NOTE : In recent years, the popularity of UART has decreased: protocols like SPI and I2C have been
  replacing UART between chips and components. Instead of communicating over a serial port, most
  modern computers and peripherals now use technologies like Ethernet and USB.
*/
struct UARTDriver;

/*
  UART emulation in QEMU is modelled after 16550A UART (https://en.wikipedia.org/wiki/16550_UART).

  We have a set of registers through which we use the UART controller (hardware module that
  implements the UART protocol). You can find the list of registers here :
  https://en.wikibooks.org/wiki/Serial_Programming/8250_UART_Programming#UART_Registers.

  These registers are memory mapped - assigned specific addresses within the system's memory address
  space. This allows us to interact with the UART controller using standard memory read-write
  operations. The base register is mapped to the 0x1000_0000 memory address.
*/
const UART_BASE_REGISTER: usize = 0x1000_0000;

const TRANSMIT_HOLDING_REGISTER: usize = UART_BASE_REGISTER;

impl Write for UARTDriver {
  fn write_str(&mut self, s: &str) -> core::fmt::Result {
    for character in s.chars() {
      unsafe {
        write_volatile(TRANSMIT_HOLDING_REGISTER as *mut char, character);
      }
    }
    Ok(())
  }
}

pub fn print(args: fmt::Arguments) {
  UARTDriver.write_fmt(args).unwrap();
}

#[macro_export]
macro_rules! print {
  ($($arg: tt)*) => {
    $crate::console::print(format_args!($($arg)*));
  };
}

#[macro_export]
macro_rules! println {
  ($($arg: tt)*) => {
    $crate::print!("{}\n", format_args!($($arg)*));
  };
}
