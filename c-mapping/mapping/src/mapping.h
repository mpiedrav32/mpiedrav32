/**
 * @file mapping.h
 * @author Marco Piedra Venegas (marco.piedra@ucr.ac.cr)
 * @brief Mapping simulation. Header.
 * @version 1.0.0
 * @date 2022-06-06
 *
 * @copyright Copyright (c) 2022
 *
 */

#ifndef MAPPING_H
#define MAPPING_H

/**
 * @brief Mapping data.
 * @remark Opaque struct.
 *
 */
typedef struct mapping mapping_t;

/**
 * @brief Create mapping data.
 *
 * @return Mapping data
 */
mapping_t* mapping_create();

/**
 * @brief Run mapping simulation.
 *
 * @param mapping Mapping data
 * @param argc Argument count
 * @param argv Argument vector
 * @return Error code
 */
int mapping_run(mapping_t* mapping, int argc, char* argv[]);

/**
 * @brief Destroy mapping data.
 *
 * @param mapping Mapping data
 */
void mapping_destroy(mapping_t* mapping);

#endif  // MAPPING_H
