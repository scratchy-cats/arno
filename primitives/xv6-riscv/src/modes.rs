// REFER : sections 1.1 (execution environments) and 1.2 (privilege levels) in privileged ISA manual.
/*
  A RISC-V hart runs at some privilege level encoded as a mode in one or more CSRs. Privilege levels
  are used to provide protection between different components of the software stack.

  Attempts to perform operations not permitted by the current privilege mode will cause an exception
  to be raised. These exceptions will normally cause traps into an underlying execution environment.
*/
#[allow(unused)]
pub enum PrivilegeLevels {
  // All hardware implementations must provide M-mode, as this is the only mode that has unfettered
  // access to the whole machine.
  Machine,

  Supervisor,
  User,
}
