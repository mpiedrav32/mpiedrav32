# Workload mapping simulation

This program calculates maximum workload, speedup, and efficiency.

A sequence of data units (positive integers) is read from standard input.

Based on https://jeisson.ecci.ucr.ac.cr/concurrente/2021b/ejemplos/#mapping

## Build

`make`

## Usage

```
./mapping [worker_count] [block_count]
```

- `worker_count`: worker (i.e., thread) count. Default is 4.
- `block_count`: block count for block-cyclic mapping. Default is 2.

## Credits

Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
