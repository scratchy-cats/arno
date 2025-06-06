use {
  crate::locks::spinlock::{SpinLock, SpinLockGuard},
  core::cell::UnsafeCell,
};

pub struct Process {
  pub metadata: SpinLock<ProcessMetadata>,
  pub data: UnsafeCell<ProcessData>,
}

impl Process {
  pub const fn new() -> Self {
    Self {
      metadata: SpinLock::new(ProcessMetadata::new()),
      data: UnsafeCell::new(ProcessData::new()),
    }
  }

  pub fn sleep<T>(&self, _sleepLockSpinLockGuard: SpinLockGuard<'_, T>) {
    unimplemented!()
  }
}

#[derive(PartialEq, Copy, Clone)]
pub enum ProcessState {
  // No memory has yet been allocated for this process.
  UNUSED,

  USED,

  RUNNABLE,

  RUNNING,

  // The process is currently blocked, waiting to acquire a SleepLock / some I/O operation to
  // finish.
  SLEEPING,

  ZOMBIE,

  ALLOCATED,
}

pub struct ProcessMetadata {
  pub state: ProcessState,
}

impl ProcessMetadata {
  pub const fn new() -> Self {
    Self {
      state: ProcessState::UNUSED,
    }
  }
}

pub struct ProcessData {}

impl ProcessData {
  pub const fn new() -> Self {
    Self {}
  }
}
