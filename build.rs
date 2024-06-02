fn main() {
  println!("cargo:rerun-if-changed=linker.ld");
  println!("cargo:rerun-if-changed=src/asm/entry.S");
  println!("cargo:rustc-link-arg=-Tlinker.ld");

  // rust's build system sucks. I want to do this, but
  // the cc, isnt configured the same. It uses a different ABI.
  //
  //     cc::Build::new().file("src/asm/entry.S").compile("entry");

  // Setting the code mode from here is also not possible it seems.
  // Something like below. But there is no such option.
  //
  //     println!("cargo:code-model=medium");
}
