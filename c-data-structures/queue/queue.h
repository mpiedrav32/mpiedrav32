/**
 * @file queue.h
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief Queue header.
 * @remark Thread-safe FIFO queue.
 * @version 1.0.0
 * @date 2022-06-12
 *
 * @copyright Copyright (c) 2022
 *
 */

#ifndef QUEUE_H
#define QUEUE_H

#include <stdbool.h>

#include "node.h"

/**
 * @brief Queue data.
 *
 */
typedef struct queue queue_t;

/**
 * @brief Create a queue.
 *
 * @return Queue data.
 */
queue_t* queue_create();

/**
 * @brief Initialize a queue.
 *
 * @param queue Queue data.
 * @return Error code.
 */
int queue_initialize(queue_t* queue);

/**
 * @brief Enqueue a node in a queue.
 *
 * @param queue Queue data.
 * @param node Node content.
 */
void queue_enqueue(queue_t* queue, node_t* node);

/**
 * @brief Dequeue a node from a queue.
 *
 * @param queue Queue data.
 * @return Node content. Void if queue is empty.
 */
node_t* queue_dequeue(queue_t* queue);

/**
 * @brief Destroy a queue.
 *
 * @param queue Queue data.
 */
void queue_destroy(queue_t* queue);

#endif  // QUEUE_H
