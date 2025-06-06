use {
  super::buddy::BuddyAllocator,
  crate::{
    arch::riscv::qemu::physical_memory_layout::DRAM_ENDING_ADDRESS, locks::spinlock::SpinLock,
  },
  core::alloc::GlobalAlloc,
};

// Arno allocater uses a Buddy allocator under the hood.
// TODO : Use Slab allocator instead.
//
// It'll allocate memory within (DRAM_STARTING_ADDRESS + loaded kernel code size) and
// DRAM_ENDING_ADDRESS for processes.
pub struct ArnoAllocator(SpinLock<BuddyAllocator>);

impl ArnoAllocator {
  pub const fn new() -> Self {
    Self(SpinLock::new(BuddyAllocator::new()))
  }

  // Initializes the underlying Buddy allocator.
  pub unsafe fn init(&mut self) {
    println!("INFO : Initializing Arno allocator (using Buddy Allocator under the hood)");

    // Determine where the loaded Kernel code has ended.
    extern "C" {
      fn _kernelEndAddress(); // This (not a) function pointer points to the _kernelEndAddress
                              // linker symbol.
    }
    let kernelEndAddress = _kernelEndAddress as usize;
    println!(
      "DEBUG : Loaded Kernel code ends at : {:#x}",
      kernelEndAddress
    );

    self.0.acquire().init(
      kernelEndAddress,
      DRAM_ENDING_ADDRESS,
      16,   // Leaf size = 16 bytes.
      4096, // Max alignment size = 4 KB.
    );
  }
}

unsafe impl GlobalAlloc for ArnoAllocator {
  unsafe fn alloc(&self, layout: core::alloc::Layout) -> *mut u8 {
    self.0.acquire().alloc(layout)
  }

  unsafe fn dealloc(&self, ptr: *mut u8, layout: core::alloc::Layout) {
    self.0.acquire().dealloc(ptr, layout);
  }
}
