/**
 * @file node.c
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief Node header.
 * @version 1.0.0
 * @date 2022-06-15
 *
 * @copyright Copyright (c) 2022
 *
 */

#ifndef NODE_H
#define NODE_H

#include <stdint.h>

/**
 * @brief Node data.
 *
 */
typedef struct node node_t;

/**
 * @brief Create a node.
 *
 * @return Node data.
 */
node_t* node_create();

/**
 * @brief Set content data in node.
 *
 * @param node Node data.
 * @param content Content data.
 */
void node_set_content(node_t* node, int64_t content);

/**
 * @brief Get content data from node.
 *
 * @param node Node data.
 * @return Content data.
 */
int64_t node_get_content(node_t* node);

/**
 * @brief Set previous node.
 *
 * @param node Node data.
 * @param previous Node data.
 */
void node_set_previous(node_t* node, node_t* previous);

/**
 * @brief Get previous node.
 *
 * @param node Node data.
 * @return Node data.
 */
node_t* node_get_previous(node_t* node);

/**
 * @brief Set next node.
 *
 * @param node Node data.
 * @param next Node data.
 */
void node_set_next(node_t* node, node_t* next);

/**
 * @brief Get next node.
 *
 * @param node Node data.
 * @return Node data.
 */
node_t* node_get_next(node_t* node);

/**
 * @brief Destroy node.
 *
 * @param node Node data.
 */
void node_destroy(node_t* node);

#endif  // NODE_H
