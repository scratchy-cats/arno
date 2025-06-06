use super::DRAM_SIZE;

// This is how the physical memory layout looks like :
// https://clownote.github.io/2021/03/06/xv6/Xv6-page-table/Xv6-page-table/kernel-address-space.png.

// The actual hardware is mapped to the portion between the KERNBASE and PHYSTOP in the diagram.
pub const DRAM_STARTING_ADDRESS: usize = 0x80000000; // KERNBASE.
pub const DRAM_ENDING_ADDRESS: usize = DRAM_STARTING_ADDRESS + DRAM_SIZE; // PHYSTOP.

// const UART_BASE_REGISTER: usize = 0x1000_0000;
