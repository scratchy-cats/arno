pub mod entry;
pub mod kernel;

use {
  super::address::{physical::PhysicalAddress, r#virtual::VirtualAddress},
  crate::memory::address::Address,
  alloc::boxed::Box,
  entry::{PTEBitFlags, PageTableEntry},
};

const PAGE_TABLE_ENTRY_COUNT: usize = 512;
const MAX_VA: usize = 1 << (9 + 9 + 9 + 12 - 1); // TODO : Understand.

/*
  In RV64, three paged virtual-memory schemes are defined: Sv39, Sv48, and Sv57.
  We'll be implementing the Sv39 scheme.

  In order to enable the Sv39 scheme, you need to write 8 into the MODE bits of the satp CSR.

  Sv39 implementations support a 39-bit virtual address space, divided into pages. Instruction
  fetch addresses and load and store effective addresses, which are 64 bits, must have bits 63–39
  all equal to bit 38, or else a page-fault exception will occur.

  The Virtual Address Translation (VAT) process :

    (1) The 27-bit VPN (Virtual Page Number) in the Virtual Address (VA), is translated into a
        44-bit PPN (Physical Page Number) via a three-level page table.

    (2) The 12-bit page offset is then appended to the 44-bit PPN to get the 56 bit Physical
        Address (PA).

  Sv39 page tables contain 512 page table entries (PTEs), eight bytes each. A Page Table is exactly
  the size of a page and must always be aligned to a page boundary.

  Each Page is identified using a Page Number (PN).

                            PN x 4096 (page size) = Address of the page

  REFERENCE : https://www.youtube.com/watch?v=g7B0WS5Xu-A.
              An amazing blog explaining the paging system in RiscV : https://clownote.github.io/2021/03/06/xv6/Xv6-page-table/.
*/
#[repr(C, align(4096))]
pub struct PageTable {
  pub entries: [PageTableEntry; PAGE_TABLE_ENTRY_COUNT],
}

impl PageTable {
  pub const fn empty() -> Self {
    Self {
      entries: [PageTableEntry(0); PAGE_TABLE_ENTRY_COUNT],
    }
  }
}

impl PageTable {
  // Maps the pages present in the given Virtual Address (VA) space range to the pages present in
  // the given Physical Address (PA) space range.
  // A Page Table Entry (PTE) is created for each mapping.
  // NOTE : The starting VA and range size may not be page alligned.
  fn map(
    &mut self,
    startingVA: VirtualAddress,
    startingPA: PhysicalAddress,
    rangeSize: usize, // (in bytes)
    bitFlags: PTEBitFlags,
  ) {
    assert!(rangeSize > 0, "Memory range size must be more than 0");

    // TODO : Page align the starting VA and rangeSize.
    // Though in xv6-riscv, the starting VA and rangeSize are always page-aligned.

    let endingVA = VirtualAddress::new(startingVA.asUsize() + rangeSize);

    let (mut currentVA, mut currentPA) = (startingVA, startingPA);
    while currentVA != endingVA {
      let leafPTE = self.getLeafPTE(currentVA);

      assert!(!leafPTE.isValid(), "Virtual Address (VA) is already mapped");
      leafPTE.setPhysicalAddress(currentPA.asUsize(), bitFlags);

      currentVA.increaseByAPage();
      currentPA.increaseByAPage();
    }
  }

  // Walks the Page Table and returns the leaf Page Table Entry (PTE) corresponding to the given
  // Virtual Address (VA).
  fn getLeafPTE(&mut self, va: VirtualAddress) -> &mut PageTableEntry {
    assert!(
      va.asUsize() > MAX_VA,
      "Virtual Address (VA) is greater than the allowed maximum"
    );

    // NOTE : The Page Table is a Radix Trie.

    let mut currentNode = self as *mut PageTable;

    // NOTE : Level 2 is the topmost level. And the level index decreases as we go downwards.
    for level in (1..=2).rev() {
      let currentPTE = unsafe { &mut (*currentNode).entries[va.getCorrespondingPPN(level)] };

      match currentPTE.isValid() {
        // If the current PTE is invalid (the V bit is set to 0), that means the child PTE
        // currently doesn't exist.
        false => {
          // So, we'll first create the child PTE.
          let createdChildPTE = unsafe { Box::into_raw(Box::new_zeroed().assume_init()) };
          //
          // Then make the current PTE point to that child PTE.
          // NOTE : When all of the R, W and X bits are zero, the PTE is a pointer to the next
          //				level of the page table. otherwise, it is a leaf PTE.
          currentPTE.setPhysicalAddress(createdChildPTE as usize, PTEBitFlags::V);

          currentNode = createdChildPTE;
        }

        _ => currentNode = currentPTE.toPhysicalAddress() as *mut PageTable,
      }
    }

    unsafe { &mut (*currentNode).entries[va.getCorrespondingPPN(0)] }
  }
}
