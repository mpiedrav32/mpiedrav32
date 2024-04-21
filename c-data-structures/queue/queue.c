/**
 * @file queue.c
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief Queue implementation.
 * @remark Thread-safe FIFO queue.
 * @version 1.0.0
 * @date 2022-06-12
 *
 * @copyright Copyright (c) 2022
 *
 */

#include "queue.h"

#include <assert.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct queue {
  /// Queue head.
  node_t* head;
  /// Queue tail.
  node_t* tail;
  /// Queue access.
  pthread_mutex_t* can_access;
} queue_t;

queue_t* queue_create() {
  queue_t* queue = calloc(1, sizeof(queue_t));
  if (queue) {
    queue->head = NULL;
    queue->tail = NULL;
    queue->can_access = NULL;
  }
  return queue;
}

int queue_initialize(queue_t* queue) {
  assert(queue);
  int error = EXIT_SUCCESS;
  queue->can_access = calloc(1, sizeof(pthread_mutex_t));
  if (queue->can_access) {
    error = pthread_mutex_init(queue->can_access, NULL);
    if (error != EXIT_SUCCESS) {
      fprintf(stderr, "%s", "error: cannot initialize queue access\n");
    }
  } else {
    fprintf(stderr, "%s", "error: cannot allocate queue access\n");
    error = EXIT_FAILURE;
  }
  return error;
}

void queue_enqueue(queue_t* queue, node_t* node) {
  assert(queue);
  pthread_mutex_lock(queue->can_access);
  if (queue->head == NULL) {  // Queue is empty.
    node_set_previous(node, node);
    node_set_next(node, node);
    queue->head = node;
    queue->tail = node;
  } else {  // Queue has at least 1 node.
    node_set_previous(node, queue->tail);
    node_set_next(node, queue->head);
    node_set_previous(queue->head, node);
    node_set_next(queue->tail, node);
    queue->head = node;
  }
  pthread_mutex_unlock(queue->can_access);
}

node_t* queue_dequeue(queue_t* queue) {
  assert(queue);
  node_t* node = NULL;
  node_t* new_tail = NULL;
  // Dequeue node from the end of a non-empty queue.
  pthread_mutex_lock(queue->can_access);
  // Check whether queue is not empty.
  if (queue->tail) {
    if (queue->head == queue->tail) {  // Queue has only 1 node.
      node = queue->tail;
      queue->head = NULL;
      queue->tail = NULL;
    } else {  // Queue has at least 2 nodes.
      node = queue->tail;
      new_tail = node_get_previous(queue->tail);
      node_set_next(new_tail, queue->head);
      node_set_previous(queue->head, new_tail);
      queue->tail = new_tail;
    }
  }
  pthread_mutex_unlock(queue->can_access);
  return node;
}

void queue_destroy(queue_t* queue) {
  assert(queue);
  node_t* node;
  while (queue->head) {
    node = queue->head;
    queue->head = node_get_next(queue->head);
    node_destroy(node);
  }
  if (queue->can_access) {
    pthread_mutex_destroy(queue->can_access);
    free(queue->can_access);
  }
  free(queue);
}
