/**
 * @file mapping.c
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief Mapping simulation. Implementation.
 * @version 1.0.0
 * @date 2022-06-06
 *
 * @copyright Copyright (c) 2022
 *
 */

#include "mapping.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

/// Default number of workers
#define DEFAULT_WORKER_COUNT 4

/// Default block size for block-cyclic mapping
#define DEFAULT_BLOCK_SIZE 2

/// Mapping count
#define MAPPING_COUNT 4

/**
 * @brief Mapping types.
 *
 */
enum mapping_type { BLOCK, CYCLIC, BLOCK_CYCLIC, DYNAMIC };

typedef struct mapping_result {
  /// Maximum
  size_t maximum;
  /// Speedup
  double speedup;
  /// Efficiency
  double efficiency;
  /// Units-workers array
  size_t* units_workers;
  /// Units processed per worker
  size_t* units_processed;
} mapping_result_t;

/**
 * @brief Mapping data.
 *
 */
typedef struct mapping {
  /// Worker count
  size_t worker_count;
  /// Block size for block-cyclic mapping
  size_t block_size;
  /// Sum of serially processed units
  size_t serial_sum;
  /// Unit count
  size_t unit_count;
  /// Unit capacity
  size_t unit_capacity;
  /// Unit array
  size_t* units;
  /// Mapping results
  mapping_result_t* results;
} mapping_t;

/**
 * @brief Parse arguments from command line.
 *
 * @param mapping Mapping data
 * @param argc Argument count
 * @param argv Argument vector
 * @return Error code
 */
int mapping_parse_arguments(mapping_t* mapping, int argc, char* argv[]);

/**
 * @brief Read work units from standard input
 *
 * @param mapping Mapping data
 * @return int
 */
int mapping_read_units(mapping_t* mapping);

/**
 * @brief Resize unit array.
 *
 * @param mapping Mapping data
 * @return Error code
 */
int mapping_resize_unit_array(mapping_t* mapping);

/**
 * @brief Start mapping calculations.
 *
 * @param mapping Mapping data
 * @return Error code
 */
int mapping_calculate(mapping_t* mapping);

/**
 * @brief Allocate mapping results.
 *
 * @param mapping Mapping data
 * @return Error code
 */
int mapping_allocate_results(mapping_t* mapping);

/**
 * @brief Calculate block mapping.
 *
 * @param mapping Mapping data
 * @return Error code
 */
void mapping_calculate_block(mapping_t* mapping);

/**
 * @brief Find start of range for block mapping.
 *
 * @param mapping Mapping data
 * @param worker_index Worker index
 */
size_t mapping_find_start(mapping_t* mapping, size_t worker_index);

/**
 * @brief Calculate cyclic mapping.
 *
 * @param mapping Mapping data
 * @return Error code
 */
void mapping_calculate_cyclic(mapping_t* mapping);

/**
 * @brief Calculate block-cyclic mapping.
 *
 * @param mapping Mapping data
 * @return Error code
 */
void mapping_calculate_block_cyclic(mapping_t* mapping);

/**
 * @brief Calculate dynamic mapping.
 *
 * @param mapping Mapping data
 * @return Error code
 */
void mapping_calculate_dynamic(mapping_t* mapping);

/**
 * @brief Find index of worker with minimum sum of processed units.
 *
 * @param mapping Mapping data
 * @return Worker index
 */
size_t mapping_find_argmin(mapping_t* mapping);

/**
 * @brief Calculate results for all mappings.
 *
 * @param mapping Mapping data
 */
void mapping_calculate_results(mapping_t* mapping);

/**
 * @brief Print mapping results
 *
 * @param mapping Mapping data
 */
void mapping_print_results(mapping_t* mapping);

mapping_t* mapping_create() {
  mapping_t* mapping = calloc(1, sizeof(mapping_t));
  if (mapping) {
    mapping->worker_count = DEFAULT_WORKER_COUNT;
    mapping->block_size = DEFAULT_BLOCK_SIZE;
    mapping->serial_sum = 0;
    mapping->unit_count = 0;
    mapping->unit_capacity = 0;
    mapping->units = NULL;
    mapping->results = NULL;
  }
  return mapping;
}

int mapping_run(mapping_t* mapping, int argc, char* argv[]) {
  assert(mapping);
  int error = EXIT_SUCCESS;
  error = mapping_parse_arguments(mapping, argc, argv);
  if (error == EXIT_SUCCESS) {
    error = mapping_read_units(mapping);
    if (error == EXIT_SUCCESS) {
      error = mapping_calculate(mapping);
      if (error == EXIT_SUCCESS) {
        mapping_print_results(mapping);
      }
    }
  }
  return error;
}

int mapping_parse_arguments(mapping_t* mapping, int argc, char* argv[]) {
  assert(mapping);
  int error = EXIT_SUCCESS;
  long value = 0;
  if (argc == 3) {
    if (sscanf(argv[1], "%ld", &value) == 1 && value > 0) {
      mapping->worker_count = value;
      if (sscanf(argv[2], "%ld", &value) == 1 && value > 0) {
        mapping->block_size = value;
      } else {
        fprintf(stderr, "%s", "error: invalid block size\n");
        error = EXIT_FAILURE;
      }
    } else {
      fprintf(stderr, "%s", "error: invalid worker count\n");
      error = EXIT_FAILURE;
    }
  }
  return error;
}

int mapping_read_units(mapping_t* mapping) {
  assert(mapping);
  int error = EXIT_SUCCESS;
  long value = 0;
  while (scanf("%ld", &value) == 1) {
    if (mapping->unit_count == mapping->unit_capacity) {
      error = mapping_resize_unit_array(mapping);
    }
    if (error == EXIT_SUCCESS) {
      if (value > 0) {
        mapping->units[mapping->unit_count] = value;
        ++mapping->unit_count;
      }
    } else {
      break;
    }
  }
  return error;
}

int mapping_resize_unit_array(mapping_t* mapping) {
  assert(mapping);
  int error = EXIT_SUCCESS;
  size_t new_capacity = 0;
  // Amortized memory allocation
  if (mapping->units) {
    new_capacity = 10 * mapping->unit_capacity;
  } else {
    new_capacity = 10;
  }
  size_t* new_array = realloc(mapping->units, new_capacity * sizeof(long));
  if (new_array) {
    mapping->units = new_array;
    mapping->unit_capacity = new_capacity;
  } else {
    fprintf(stderr, "%s", "error: cannot resize unit array\n");
    error = EXIT_FAILURE;
  }
  return error;
}

int mapping_calculate(mapping_t* mapping) {
  assert(mapping);
  int error = EXIT_SUCCESS;
  error = mapping_allocate_results(mapping);
  if (error == EXIT_SUCCESS) {
    mapping_calculate_block(mapping);
    mapping_calculate_cyclic(mapping);
    mapping_calculate_block_cyclic(mapping);
    mapping_calculate_dynamic(mapping);
    mapping_calculate_results(mapping);
  }
  return error;
}

int mapping_allocate_results(mapping_t* mapping) {
  assert(mapping);
  int error = EXIT_SUCCESS;
  mapping->results = calloc(MAPPING_COUNT, sizeof(mapping_result_t));
  if (mapping->results) {
    for (size_t mapping_index = 0; mapping_index < MAPPING_COUNT;
         ++mapping_index) {
      mapping->results[mapping_index].units_workers =
          calloc(mapping->unit_count, sizeof(size_t));
      if (mapping->results[mapping_index].units_workers) {
        mapping->results[mapping_index].units_processed =
            calloc(mapping->worker_count, sizeof(size_t));
        if (mapping->results[mapping_index].units_processed) {
        } else {
          fprintf(stderr, "%s",
                  "error: cannot allocate processed units array\n");
          error = EXIT_FAILURE;
        }
      } else {
        fprintf(stderr, "%s", "error: cannot allocate units-workers array\n");
        error = EXIT_FAILURE;
      }
    }
  } else {
    fprintf(stderr, "%s", "error: cannot allocate results\n");
    error = EXIT_FAILURE;
  }
  return error;
}

void mapping_calculate_block(mapping_t* mapping) {
  assert(mapping);
  size_t start = 0;
  size_t stop = 0;
  // Map units to workers.
  // Stopping point for a worker is the starting point for the next worker.
  for (size_t worker_index = 0; worker_index < mapping->worker_count;
       ++worker_index) {
    start = mapping_find_start(mapping, worker_index);
    stop = mapping_find_start(mapping, worker_index + 1);
    for (size_t unit_index = start; unit_index < stop; ++unit_index) {
      mapping->results[BLOCK].units_workers[unit_index] = worker_index;
    }
  }
}

size_t mapping_find_start(mapping_t* mapping, size_t worker_index) {
  long block_size = 0;
  long block_remainder = 0;
  ldiv_t division = ldiv(mapping->unit_count, mapping->worker_count);
  size_t division_quotient = division.quot;
  size_t division_remainder = division.rem;
  block_size = worker_index * division_quotient;
  if (worker_index < division_remainder) {
    block_remainder = worker_index;
  } else {
    block_remainder = division_remainder;
  }
  return block_size + block_remainder;
}

void mapping_calculate_cyclic(mapping_t* mapping) {
  assert(mapping);
  for (size_t unit_index = 0; unit_index < mapping->unit_count; ++unit_index) {
    mapping->results[CYCLIC].units_workers[unit_index] =
        unit_index % mapping->worker_count;
  }
}

void mapping_calculate_block_cyclic(mapping_t* mapping) {
  assert(mapping);
  ldiv_t division = ldiv(mapping->unit_count, mapping->block_size);
  size_t block_count = division.quot;
  for (size_t block_index = 0; block_index < block_count; ++block_index) {
    for (size_t index = 0; index < mapping->block_size; ++index) {
      mapping->results[BLOCK_CYCLIC]
          .units_workers[block_index * mapping->block_size + index] =
          block_index % mapping->worker_count;
    }
  }
}

void mapping_calculate_dynamic(mapping_t* mapping) {
  assert(mapping);
  // Map next unit to worker with minimum sum of processed units.
  for (size_t unit_index = 0; unit_index < mapping->unit_count; ++unit_index) {
    mapping->results[DYNAMIC].units_workers[unit_index] =
        mapping_find_argmin(mapping);
    mapping->results[DYNAMIC]
        .units_processed[mapping->results[DYNAMIC].units_workers[unit_index]] +=
        mapping->units[unit_index];
  }
  // Reset sums of units processed per worker
  for (size_t worker_index = 0; worker_index < mapping->worker_count;
       ++worker_index) {
    mapping->results[DYNAMIC].units_processed[worker_index] = 0;
  }
}

size_t mapping_find_argmin(mapping_t* mapping) {
  assert(mapping);
  size_t argmin = 0;
  for (size_t worker_index = 0; worker_index < mapping->worker_count;
       ++worker_index) {
    if (mapping->results[DYNAMIC].units_processed[worker_index] <
        mapping->results[DYNAMIC].units_processed[argmin]) {
      argmin = worker_index;
    }
  }
  return argmin;
}

void mapping_calculate_results(mapping_t* mapping) {
  assert(mapping);
  // Store sum of serially processed units
  for (size_t unit_index = 0; unit_index < mapping->unit_count; ++unit_index) {
    mapping->serial_sum += mapping->units[unit_index];
  }
  // Compute results for each mapping
  for (size_t mapping_index = 0; mapping_index < MAPPING_COUNT;
       ++mapping_index) {
    // For each worker, find all units that it should process and add them
    for (size_t worker_index = 0; worker_index < mapping->worker_count;
         ++worker_index) {
      for (size_t unit_index = 0; unit_index < mapping->unit_count;
           ++unit_index) {
        if (mapping->results[mapping_index].units_workers[unit_index] ==
            worker_index) {
          mapping->results[mapping_index].units_processed[worker_index] +=
              mapping->units[unit_index];
        }
      }
    }
    // Find index of maximum sum of processed units
    size_t maximum_index = 0;
    for (size_t worker_index = 0; worker_index < mapping->worker_count;
         ++worker_index) {
      if (mapping->results[mapping_index].units_processed[worker_index] >
          mapping->results[mapping_index].units_processed[maximum_index]) {
        maximum_index = worker_index;
      }
    }
    mapping->results[mapping_index].maximum =
        mapping->results[mapping_index].units_processed[maximum_index];
    mapping->results[mapping_index].speedup =
        (double)mapping->serial_sum /
        (double)mapping->results[mapping_index].maximum;
    mapping->results[mapping_index].efficiency =
        mapping->results[mapping_index].speedup / mapping->worker_count;
  }
}

void mapping_print_results(mapping_t* mapping) {
  assert(mapping);
  printf("%zu units\n", mapping->unit_count);
  for (size_t unit_index = 0; unit_index < mapping->unit_count; ++unit_index) {
    printf("%zu ", mapping->units[unit_index]);
  }
  printf("\n");
  printf("Serially processed units: %zu\n", mapping->serial_sum);
  printf("\n");
  for (size_t mapping_index = 0; mapping_index < MAPPING_COUNT;
       ++mapping_index) {
    switch (mapping_index) {
      case BLOCK:
        printf("BLOCK MAPPING\n");
        break;
      case CYCLIC:
        printf("CYCLIC MAPPING\n");
        break;
      case BLOCK_CYCLIC:
        printf("BLOCK-CYCLIC MAPPING\n");
        break;
      case DYNAMIC:
        printf("DYNAMIC MAPPING\n");
        break;
      default:
        break;
    }
    printf("Units-workers mapping\n");
    for (size_t unit_index = 0; unit_index < mapping->unit_count;
         ++unit_index) {
      printf("%zu ", mapping->results[mapping_index].units_workers[unit_index]);
    }
    printf("\n");
    printf("Units processed per worker\n");
    for (size_t worker_index = 0; worker_index < mapping->worker_count;
         ++worker_index) {
      printf("%zu ",
             mapping->results[mapping_index].units_processed[worker_index]);
    }
    printf("\n");
    printf("Maximum:    %zu\n", mapping->results[mapping_index].maximum);
    printf("Speedup:    %2.3lf\n", mapping->results[mapping_index].speedup);
    printf("Efficiency: %2.3lf\n", mapping->results[mapping_index].efficiency);
    printf("\n");
  }
}

void mapping_destroy(mapping_t* mapping) {
  assert(mapping);
  if (mapping->units) {
    free(mapping->units);
  }
  if (mapping->results) {
    for (size_t mapping_index = 0; mapping_index < MAPPING_COUNT;
         ++mapping_index) {
      if (mapping->results[mapping_index].units_workers) {
        free(mapping->results[mapping_index].units_workers);
      }
      if (mapping->results[mapping_index].units_processed) {
        free(mapping->results[mapping_index].units_processed);
      }
    }
    free(mapping->results);
  }
  free(mapping);
}
