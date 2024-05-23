// Maximum number of CPUs supported.
#define MAX_CPU_COUNT 8

// Stack used initially by the Kernel.
// Each CPU gets 4KB.
__attribute__ ((aligned (16)))
  char stack0[4096 * MAX_CPU_COUNT];

void start( ) { }