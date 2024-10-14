// Copyright (c) 2021 Marco Piedra Venegas

#include <pthread.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

enum error_code {
  ERROR_ARGC = EXIT_FAILURE,
  ERROR_CYCLE_COUNT,
  ERROR_STEP_SIZE,
  ERROR_THREAD_COUNT
};

typedef struct thread_data {
  atomic_long counter;
  size_t cycle_count;
  size_t step_size;
} thread_data_t;

void* accumulate(void* data) {
  thread_data_t* shared_data = (thread_data_t*)data;

  for (size_t index = 0; index < shared_data->cycle_count; ++index) {
    atomic_fetch_add(&shared_data->counter, shared_data->step_size);
  }

  return NULL;
}

void run_acc(size_t cycle_count, size_t step_size, size_t thread_count) {
  pthread_t* threads = (pthread_t*)calloc(thread_count, sizeof(pthread_t));
  thread_data_t* shared_data = (thread_data_t*)calloc(1, sizeof(thread_data_t));

  atomic_store(&shared_data->counter, 0);
  shared_data->cycle_count = cycle_count;
  shared_data->step_size = step_size;

  for (size_t index = 0; index < thread_count; ++index) {
    pthread_create(&threads[index], NULL, accumulate, (void*)shared_data);
  }

  for (size_t index = 0; index < thread_count; ++index) {
    pthread_join(threads[index], NULL);
  }

  printf("counter = %zu\n", shared_data->counter);

  free(threads);
  free(shared_data);
}

void print_usage(char* argv[]) {
  printf(
      "Counter using pthread mutex\n"
      "Usage: %s loop-cycles step-size [thread-count]\n",
      argv[0]);
}

int main(int argc, char* argv[]) {
  int error = EXIT_SUCCESS;
  size_t cycle_count = 0;
  size_t step_size = 0;
  size_t thread_count = sysconf(_SC_NPROCESSORS_ONLN);
  char* end_cycle_count = NULL;
  char* end_step_size = NULL;
  char* end_thread_count = NULL;

  if (argc >= 3 && argc <= 4) {
    cycle_count = strtoul(argv[1], &end_cycle_count, 0);
    step_size = strtoul(argv[2], &end_step_size, 0);

    if (end_cycle_count == argv[1]) {
      fprintf(stderr, "Error: invalid loop cycles\n");
      print_usage(argv);
      error = ERROR_CYCLE_COUNT;
    }

    if (end_step_size == argv[2]) {
      fprintf(stderr, "Error: invalid step size\n");
      print_usage(argv);
      error = ERROR_STEP_SIZE;
    }

    if (argc == 4) {
      thread_count = strtoul(argv[3], &end_thread_count, 0);

      if (end_step_size == argv[3]) {
        fprintf(stderr, "Error: invalid thread count\n");
        print_usage(argv);
        error = ERROR_THREAD_COUNT;
      }
    }

    if (!error) {
      run_acc(cycle_count, step_size, thread_count);
    }
  } else {
    fprintf(stderr, "Error: not enough arguments\n");
    print_usage(argv);
    error = ERROR_ARGC;
  }

  return error;
}
