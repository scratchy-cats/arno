// We can't use the standard library, since it requires an already existing OS.
#![no_std]
/*
  (1) In a typical Rust binary that links the standard library, execution starts in a C runtime
    library called crt0 (C runtime 0), which sets up the environment for a C application. This
    includes creating a stack and placing the arguments in the right registers.

  (2) The C runtime then invokes the entry point of the Rust runtime, which is marked by the start
    language item. Rust only has a very minimal runtime, which takes care of some small things such
    as setting up stack overflow guards or printing a backtrace on panic.

  (3) The runtime then finally calls the main function.

  Our freestanding executable doesn't have the crt0 and Rust runtime. The ./asm/entry.S file invokes
  the start( ) function.
*/
#![no_main]

core::arch::global_asm!(include_str!("asm/entry.S"));

#[no_mangle] // Disable name-mangling to ensure that the Rust compiler really outputs a function
             // with the name 'start'. Without the attribute, the compiler would generate some
             // cryptic symbol to give every function a unique name.
pub fn start() -> ! {
  println!("Kernal starting....");
  loop {}
}

use core::panic::PanicInfo;

// The panic_handler attribute defines the function that the compiler should invoke when a panic
// occurs. The standard library provides a panic handler function definition by default.
// Since we're not using the standard library, we need to define the panic handler function ourselves.
#[panic_handler]
fn panic(_info: &PanicInfo<'_>) -> ! {
  loop {}
}

mod console;
