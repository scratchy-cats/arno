use core::fmt::Write;
use core::ptr;

pub struct PLICDriver {
  pub base: *mut u32,
}

impl PLICDriver {
  const PRIORITY: usize = 0x0000;
  const ENABLE: usize = 0x2000 / 4;
  const THRESHOLD: usize = 0x200000 / 4;
  const CLAIM: usize = 0x200004 / 4;
  const COMPLETE: usize = 0x200004 / 4;

  pub fn word_index(mode: usize) -> usize {
    let hart: usize;
    unsafe {
      core::arch::asm!("csrr {}, mhartid", out(reg) hart);
    }
    (hart << 1 | mode) << 10
  }

  pub fn set_priority(&self, src: usize, prio: u32) {
    unsafe {
      ptr::write_volatile(self.base.add(Self::PRIORITY + src), prio);
    }
  }

  pub fn set_enable(&self, idx: usize, src: usize) {
    unsafe {
      ptr::write_volatile(
        self.base.add(Self::ENABLE + ((idx + src) >> 5)),
        1 << (src & 31),
      );
    }
  }

  pub fn set_threshold(&self, idx: usize, th: usize) {
    unsafe {
      ptr::write_volatile(self.base.add(Self::THRESHOLD + idx), th as u32);
    }
  }

  pub fn claim(&self, idx: usize) -> u32 {
    unsafe { ptr::read_volatile(self.base.add(Self::CLAIM + idx)) }
  }

  pub fn complete(&self, idx: usize, src: usize) {
    unsafe {
      ptr::write_volatile(self.base.add(Self::COMPLETE + idx), src as u32);
    }
  }
}

pub struct UARTDriver {
  pub base: *mut u8,
}

impl UARTDriver {
  const RBR: usize = 0x0;
  const THR: usize = 0x0;
  // const DLL: usize = 0x0;
  const IER: usize = 0x1;
  // const DLH: usize = 0x1;
  const IIR: usize = 0x2;
  const FCR: usize = 0x2;
  // const LCR: usize = 0x3;
  // const MCR: usize = 0x4;
  const LSR: usize = 0x5;
  // const MSR: usize = 0x6;
  // const SR: usize = 0x7;

  pub fn write(&self, c: u8) {
    unsafe {
      while ptr::read_volatile(self.base.add(Self::LSR) as *const u8) & 0x20 == 0 {}
      if c == b'\n' {
        ptr::write_volatile(self.base.add(Self::THR) as *mut u8, b'\r');
      }
      ptr::write_volatile(self.base.add(Self::THR) as *mut u8, c);
    }
  }

  pub fn read(&self) -> u8 {
    unsafe {
      while ptr::read_volatile(self.base.add(Self::LSR) as *const u8) & 0x1 == 0 {}
      let mut c = ptr::read_volatile(self.base.add(Self::RBR) as *const u8);
      if c == b'\r' {
        c = b'\n';
      }
      c
    }
  }

  pub fn flush(&self) {
    unsafe { while ptr::read_volatile(self.base.add(Self::LSR) as *const u8) & 0x40 == 0 {} }
  }

  pub fn fifo_init(&self) {
    unsafe {
      ptr::write_volatile(self.base.add(Self::FCR) as *mut u8, 1 | 3 << 1);
    }
  }

  pub fn fifo_status(&self) -> u8 {
    unsafe { ptr::read_volatile(self.base.add(Self::IER) as *const u8) >> 6 & 3 }
  }

  pub fn interrupt_enable(&self, flags: u8) {
    unsafe {
      ptr::write_volatile(self.base.add(Self::IER) as *mut u8, flags & 0xf);
    }
  }

  pub fn interrupt_disable(&self, flags: u8) {
    unsafe {
      ptr::write_volatile(self.base.add(Self::IER) as *mut u8, !(flags & 0xf));
    }
  }

  pub fn interrupt_pending(&self) -> bool {
    unsafe { ptr::read_volatile(self.base.add(Self::IIR) as *const u8) & 1 == 0 }
  }
}

impl Write for UARTDriver {
  fn write_str(&mut self, s: &str) -> core::fmt::Result {
    for c in s.bytes() {
      self.write(c);
    }
    Ok(())
  }
}
