// -*-c++-*-

#ifndef DEBUG_H
#define DEBUG_H

#include "parse.h"
#include <vector>

void debug_print_parsed(std::vector<asm_line> &parsed_lines);
void debug_print_bitcode(const std::string &OUTPUT_FN);

#endif
