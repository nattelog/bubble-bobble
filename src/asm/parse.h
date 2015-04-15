// -*-c++-*-

#ifndef PARSE_H
#define PARSE_H

#include <string>
#include <vector>
#include "asm_lib.h"

/* The scope of parse is to divide the line of code into different types of data.
 * Syntax checking is done but data verification is not done which means that invalid data 
 * can be passed and saved in the asm_line struct. Data needs to be verified later. */

void parse_addr(asm_line &data, std::string &line);
void parse_reg(asm_line &data, std::string &line);
void parse_opcode(asm_line &data, std::string &line);
void parse_line(std::vector<asm_line> &lines, asm_line data, std::string &line);
std::vector<asm_line> parse_file(std::string file_name);

#endif
