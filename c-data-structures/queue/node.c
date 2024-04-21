/**
 * @file node.c
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief Node implementation.
 * @version 1.0.0
 * @date 2022-06-15
 *
 * @copyright Copyright (c) 2022
 *
 */

#include "node.h"

#include <assert.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct node {
  /// Content data.
  int64_t content;
  /// Previous node.
  node_t* previous;
  /// Next node.
  node_t* next;
} node_t;

node_t* node_create() {
  node_t* node = calloc(1, sizeof(node_t));
  if (node) {
    node->content = 0;
    node->previous = NULL;
    node->next = NULL;
  }
  return node;
}

void node_set_content(node_t* node, int64_t content) {
  assert(node);
  node->content = content;
}

int64_t node_get_content(node_t* node) {
  assert(node);
  return node->content;
}

void node_set_previous(node_t* node, node_t* previous) {
  assert(node);
  node->previous = previous;
}

node_t* node_get_previous(node_t* node) {
  assert(node);
  return node->previous;
}

void node_set_next(node_t* node, node_t* next) {
  assert(node);
  node->next = next;
}

node_t* node_get_next(node_t* node) {
  assert(node);
  return node->next;
}

void node_destroy(node_t* node) {
  assert(node);
  free(node);
}
