use core::ptr;

pub const PLIC: PLICDriver = PLICDriver {
  plic: 0x0C00_0000 as _,
};

pub struct PLICDriver {
  plic: *mut u32,
}

impl PLICDriver {
  pub fn get_context(hart: u32, mode: u32) -> u32 {
    (hart << 1) | mode
  }

  pub fn set_priority(&self, src: u32, priority: u32) {
    unsafe {
      ptr::write_volatile(self.plic.add((0x4 * src as usize) >> 2), priority);
    }
  }

  pub fn set_enable(&self, ctx: u32, src: u32) {
    unsafe {
      ptr::write_volatile(
        self
          .plic
          .add((0x002000 + 0x80 * ctx as usize + (src as usize >> 5)) >> 2),
        0b1 << (src & 31),
      );
    }
  }

  pub fn set_threshold(&self, ctx: u32, threshold: u32) {
    unsafe {
      ptr::write_volatile(
        self.plic.add((0x201000 + 0x1000 * ctx as usize) >> 2),
        threshold,
      );
    }
  }

  pub fn claim(&self, ctx: u32) -> u32 {
    unsafe {
      let claim = ptr::read_volatile(self.plic.add((0x201004 + 0x1000 * ctx as usize) >> 2));
      claim
    }
  }

  pub fn complete(&self, ctx: u32, src: u32) {
    unsafe {
      ptr::write_volatile(self.plic.add((0x201004 + 0x1000 * ctx as usize) >> 2), src);
    }
  }
}

pub const UART: UARTDriver = UARTDriver {
  port: 0x1000_0000 as _,
};

pub struct UARTDriver {
  port: *mut u8,
}

impl UARTDriver {
  const IER: usize = 1;
  const FCR: usize = 2;
  const LSR: usize = 5;

  pub fn interrupt_source() -> u32 {
    0xA
  }

  pub fn interrupt_enable(&self, mask: u8) {
    unsafe {
      let current = ptr::read_volatile(self.port.add(UARTDriver::IER));
      ptr::write_volatile(self.port.add(1), current | (mask & 0xf));
    }
  }

  pub fn fifo_enable(&self) {
    unsafe {
      ptr::write_volatile(self.port.add(UARTDriver::FCR), 0x1);
    }
  }

  pub fn read_char(&self) -> u8 {
    unsafe {
      while ptr::read_volatile(self.port.add(UARTDriver::LSR)) & 0x1 == 0 {}
      let mut c = ptr::read_volatile(self.port);
      if c == b'\r' {
        c = b'\n';
      }
      c
    }
  }

  pub fn write_char(&self, c: u8) {
    unsafe {
      while ptr::read_volatile(self.port.add(UARTDriver::LSR)) & 0x20 == 0 {}
      if c == b'\n' {
        ptr::write_volatile(self.port, b'\r');
      }
      ptr::write_volatile(self.port, c);
    };
  }

  pub fn write_str(&self, s: &str) {
    for c in s.bytes() {
      self.write_char(c);
    }
  }

  pub fn flush(&self) {
    unsafe { while ptr::read_volatile(self.port.add(UARTDriver::LSR)) & 0x40 == 0 {} }
  }
}
