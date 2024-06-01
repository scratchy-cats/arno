fn main() {
  println!("cargo:rerun-if-changed=linker.ld");
  println!("cargo:rerun-if-changed=src/asm/entry.S");
}
