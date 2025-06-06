use {super::process::Process, crate::process::process::ProcessState, array_macro::array};

const MAX_ALLOWED_PROCESSES: usize = 64;

pub struct ProcessManager {
  processes: [Process; MAX_ALLOWED_PROCESSES],
  initProcess: *mut Process,
}

impl ProcessManager {
  pub const fn new() -> Self {
    Self {
      processes: array![_ => Process::new( ); MAX_ALLOWED_PROCESSES],
      initProcess: 0 as *mut Process,
    }
  }

  // Finds a runnable process.
  // Marks it as Allocated and then returns it.
  pub fn findRunnableProcess(&mut self) -> Option<&mut Process> {
    for process in self.processes.iter_mut() {
      let mut processMetadata = process.metadata.acquire();

      match processMetadata.state {
        ProcessState::RUNNABLE => {
          processMetadata.state = ProcessState::ALLOCATED;
          drop(processMetadata);

          return Some(process);
        }

        _ => drop(processMetadata),
      }
    }
    None
  }
}

pub const PROCESS_MANAGER: ProcessManager = ProcessManager::new();
