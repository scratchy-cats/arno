# Arno

## Todos

- [ ] Explain how memory-mapping registers work.

- [ ] SpinLocks.

- [ ] Physical page allocation.

- [ ] Learn in-depth about [constant evaluation](https://doc.rust-lang.org/reference/const_eval.html#const-context).

- [ ] Understand what are `pulse interrupts` (edge triggered).

- [ ] Understand what the `array_macro` crate does, such that we can initialize an array even if the elements don't have the `Copy` trait implemented.

- [x] Read about `atomics` and `memory ordering` in detail.

- [ ] Read : <https://amjad.alsharafi.dev/en/posts/operating-system/spinlocks/> and <https://www.reddit.com/r/rust/comments/18be8fg/blog_operating_systems_spinlocks/>.

- [ ] Learn in-depth about `NonNull`.

## Scope of improvements

- [ ] Support the `multiboot` protocol.

- [ ] Take a look at the [spinning_top](https://github.com/rust-osdev/spinning_top) SpinLock implementation.

- [ ] Use a `Slab allocator` instead of the Buddy allocator.

- [ ] Support multi-threading.

## References

- [Writing an OS in Rust](https://os.phil-opp.com)

- [GWU Operating Systems, Fall 2020](https://www.youtube.com/playlist?list=PLVW70f0xtTUxHXRtZhGEJAiBDFx-ofc_G)

- [The xv6 Kernel](https://www.youtube.com/playlist?list=PLbtzT1TYeoMhTPzyTZboW_j7TPAnjv9XB) by hhp3

- [Source Dive](https://www.youtube.com/playlist?list=PLP29wDx6QmW4Mw8mgvP87Zk33LRcKA9bl) by Low Byte Productions

- [The toolchain file](https://rust-lang.github.io/rustup/overrides.html#the-toolchain-file)

- [Pointer types](https://doc.rust-lang.org/reference/types/pointer.html) | [Raw Pointers](https://web.mit.edu/rust-lang_v1.25/arch/amd64_ubuntu1404/share/doc/rust/html/book/first-edition/raw-pointers.html)

- [Crust of Rust: Atomics and Memory Ordering](https://youtu.be/rMGWeSjctlY?si=xfBF8NWo3NDxZ3OC)

- [Rust Atomics and Locks](https://marabos.nl/atomics/) | [Rust Atomics and Locks Book Club](https://youtube.com/playlist?list=PL8AZrEE2-qZkE3Va-PsMepuUFxALaJheW&si=fgLbAGTkggXgZ-JR)

- [The macro_use attribute](https://doc.rust-lang.org/reference/macros-by-example.html#the-macro_use-attribute)

- [Data alignment: Straighten up and fly right](https://developer.ibm.com/articles/pa-dalign/)

- [Everything You Never Wanted To Know About Linker Script](https://mcyoung.xyz/2021/06/01/linker-script/)

- [Back to Basics: Compiling and Linking - Ben Saks - CppCon 2021](https://www.youtube.com/watch?v=cpkDQaYttR4)

- [GNU Linker Script official docs](https://home.cs.colorado.edu/~main/cs1300/doc/gnu/ld_3.html)

- [The 101 of ELF files on Linux: Understanding and Analysis](https://linux-audit.com/elf-binaries-on-linux-understanding-and-analysis)

- [Lecture 22. Big Endian and Little Endian](https://youtu.be/T1C9Kj_78ek)

- [RISCV assembly manual](https://github.com/riscv-non-isa/riscv-asm-manual/blob/main/riscv-asm.md)

- [Understanding UART](https://www.rohde-schwarz.com/us/products/test-and-measurement/essentials-test-equipment/digital-oscilloscopes/understanding-uart_254524.html)

- [UART Registers](https://en.wikibooks.org/wiki/Serial_Programming/8250_UART_Programming#UART_Registers)

- [How to configure physical memory protection PMP in RISC-V cpu?](https://www.youtube.com/watch?v=cWlEKpCtjes)

- [Gallery of Processor Cache Effects](http://igoro.com/archive/gallery-of-processor-cache-effects/)

- [Buddy Memory Allocation](https://www.kuniga.me/blog/2020/07/31/buddy-memory-allocation.html)

- [RISC-V Platform-Level Interrupt Controller Specification](https://github.com/riscv/riscv-plic-spec/blob/master/riscv-plic.adoc#interrupt-targets-and-hart-contexts)

- [Tuesday @ 0900 RISC V Interrupts Krste Asanović, UC Berkeley & SiFive Inc](https://youtu.be/iPbaG_wnNJY)

- [Memory Model](https://www.youtube.com/watch?v=QkbWgCSAEoo)
