/*
  Physical Memory Protection (PMP) :

  The Physical Memory Protection (PMP) unit provides per-hart machine-mode control registers to
  allow physical memory access privileges (read, write, execute) to be specified for each physical
  memory region.

  The granularity of PMP access control settings are platform-specific, but the standard PMP
  encoding supports regions as small as four bytes.

  PMP checks are applied to all accesses whose effective privilege mode is S or U, including
  instruction fetches and data accesses in S and U mode, and data accesses in M-mode when the MPRV
  bit in mstatus is set and the MPP field in mstatus contains S or U. PMP checks are also applied
  to page-table accesses for virtual-address translation, for which the effective privilege mode is
  S.

  PMP CSRs :

  PMP entries are described by an 8-bit configuration register and one MXLEN-bit address register.
  Up to 64 PMP entries are supported.

  (1) PMP configuration registers are densely packed into CSRs to minimize context-switch time. For
      RV64, eight even-numbered CSRs (pmpcfg0, pmpcfg2, …, pmpcfg14) hold the configurations for
      the 64 PMP entries. PMP CSRs are only accessible to M-mode.

  (2) The PMP address registers are CSRs named pmpaddr0-pmpaddr63. For RV64, each PMP address
      register encodes bits 55-2 of a 56-bit physical address.

  REFER : section 3.7 in privileged ISA manual and https://youtu.be/cWlEKpCtjes.
*/

use core::arch::asm;

/*
  A PMP configuration register contains the following bits (from right to left) :

  (1) The R, W, and X bits when set, indicate that the PMP entry permits read, write, and
      instruction execution, respectively. When one of these bits is clear, the corresponding access
      type is denied.

      NOTE : Attempting to fetch an instruction from a PMP region that does not have execute
      permissions raises an instruction access-fault exception.

  (2) The A field encodes the address-matching mode of the associated PMP address register.

  (3) The L bit indicates that the PMP entry is locked, i.e., writes to the configuration register
      and associated address registers are ignored. Locked PMP entries remain locked until the hart
      is reset.
      In addition to locking the PMP entry, the L bit indicates whether the R/W/X permissions are
      enforced on M-mode accesses. When the L bit is set, these permissions are enforced for all
      privilege modes. When the L bit is clear, any M-mode access matching the PMP entry will
      succeed; the R/W/X permissions apply only to S and U modes.
*/
pub struct PmpCfg0;

#[allow(unused)]
pub enum PermissionLevel {
  NONE = 0b000,
  R = 0b001,
  W = 0b010,
  RW = 0b011,
  X = 0b100,
  RX = 0b101,
  WX = 0b110,
  RWX = 0b111,
}

// The A field in a PMP entry’s configuration register encodes the address-matching mode of the
// associated PMP address register.
#[allow(unused)]
pub enum AddressMatchingMode {
  OFF = 0b00,

  // TOR (Top Of Range) : The associated address register forms the top of the address range, and
  // the preceding PMP address register forms the bottom of the address range.
  TOR = 0b01,

  NA4 = 0b10, // Naturally Aligned 4-byte Region.

  // NAPOT (Naturally Aligned Power-Of-Two Region) makes use of the low-order bits of the associated
  // pmpaddr register to encode the size of the range.
  NAPOT = 0b11,
}

impl PmpCfg0 {
  // Sets bits of the PMP configuration register (which corresponds to some pmpaddr register) in the
  // pmpcfg0 CSR.
  pub unsafe fn setPmpaddrConfig(
    &self,
    index: usize, // (of the PMP configuration register in the pmpcfg0 CSR).
    addressMatchingMode: AddressMatchingMode,
    permissionLevel: PermissionLevel,
    isLocked: bool,
  ) {
    assert!(index < 8);

    self.clearPmpConfigurationRegisterBits(index);

    let pmpaddrConfigBitMask =
      (isLocked as usize) << 7 | (addressMatchingMode as usize) << 3 | (permissionLevel as usize);

    let pmpcfgBitMask = pmpaddrConfigBitMask << (index * 8);

    asm!("csrs pmpcfg0, {}", in(reg)pmpcfgBitMask);
  }

  // Clears bits of a PMP configuration register in the pmpcfg0 CSR.
  unsafe fn clearPmpConfigurationRegisterBits(
    &self,
    index: usize, // (of the PMP configuration register in the pmpcfg0 CSR).
  ) {
    let bitMask = 0xff << (index * 8);
    asm!("csrc pmpcfg0, {}", in(reg)bitMask as usize);
  }
}

pub struct Pmpaddr0;

impl Pmpaddr0 {
  #[inline]
  pub unsafe fn defineMemoryRegion(&self, memoryAddress: usize) {
    asm!("csrw pmpaddr0, {}", in(reg)memoryAddress);
  }

  pub unsafe fn defineFullPhysicalMemoryAsRegion(&self) {
    Self.defineMemoryRegion(0x3fffffffffffff);
  }
}
