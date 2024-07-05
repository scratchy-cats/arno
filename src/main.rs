use crate::println;

#[no_mangle]
pub extern "C" fn main() {
  println!("Switched to Supervisor mode and jumped to main");
}
