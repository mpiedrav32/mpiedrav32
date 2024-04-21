# atomic_operations

## Introduction

Experiments using C11 atomic operations
(https://en.cppreference.com/w/c/atomic).

Useful for performance comparison between atomic operations
and OS concurrency mechanisms.

Current experiments:

- Concurrent counter update
  - `atomic_count`:
  [C11 threads](https://en.cppreference.com/w/c/thread)
  and
  [C11 atomic operations](https://en.cppreference.com/w/c/atomic)
  
  - `mtx_count`:
  [C11 threads](https://en.cppreference.com/w/c/thread)
  and [C11 mutex](https://en.cppreference.com/w/c/thread/mtx_init)
  
  - `pthread_mutex_count`:
  [POSIX threads](https://man7.org/linux/man-pages/man3/pthread_create.3p.html)
  and
  [POSIX mutex](https://man7.org/linux/man-pages/man3/pthread_mutex_destroy.3p.html)
  
  - `pthread_atomic_count`:
  [POSIX threads](https://man7.org/linux/man-pages/man3/pthread_create.3p.html)
  and
  [C11 atomic operations](https://en.cppreference.com/w/c/atomic)

Future experiments:

- Producer-consumer pattern
  - `atomic_producer_consumer`: Semaphores implemented using atomic operations

## Build

```
cd [directory]
make
```

## Usage

- Concurrent counter update:

```
directory/bin/program cycle-count step-size [thread-count]
```

Default thread count is `_SC_NPROCESSORS_ONLN`
(https://man7.org/linux/man-pages/man3/sysconf.3.html).

Performance statistics can be measured with `perf stat`
(https://man7.org/linux/man-pages/man1/perf-stat.1.html).

## Credits

Marco Piedra Venegas (marco.piedra [at] ucr.ac.cr).
Computer Science student. University of Costa Rica
(https://www.ecci.ucr.ac.cr).

`Makefile` by Jeisson Hidalgo-Céspedes
(http://jeisson.ecci.ucr.ac.cr/misc/Makefile).

## Bibliography

[1] M. Herlihy, "Wait-free synchronization",
ACM Transactions on Programming Languages and Systems, vol. 13, no. 1.
Association for Computing Machinery (ACM), pp. 124--149, Jan-1991 (Online).
Available: https://doi.org/10.1145/114005.102808

[2] M. L. Scott, "Shared-Memory Synchronization",
Synthesis Lectures on Computer Architecture, vol. 8, no. 2.
Morgan & Claypool Publishers LLC, pp. 1--221, 12-Jun-2013 (Online).
Available: https://doi.org/10.2200/S00499ED1V01Y201304CAC023
