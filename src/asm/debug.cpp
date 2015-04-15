#include "parse.h"
#include <string>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <stdlib.h>

/*| Parsed data   |
  +------+--------+------------+------+-----------+-----------+
  | LINE | OPCODE | $ADDR/#VAL |  GR  |   MODE    |   LABEL   |
  +------+--------+------------+------+-----------+-----------+
  | 0000 |  LDA   | #$FFFFFFFF | GR10 | IMMEDIATE | _LABELED? |
  | .... | ...... | .......... | .... | ......... | ......... |
  
*/


/* Doesn't check for text.size() > size */
std::string fill_with_spaces(std::string text, unsigned size){
    int spaces = size-text.size();
    for (int i = 0; i < spaces; ++i)
	text.append(" ");
    return text;
} 

void debug_print_bitcode(const std::string &OUTPUT_FN){
    std::string command = "xxd -b -c 4 ";
    command += OUTPUT_FN;
    std::cout << "--\nGenerated bitcode:\n" << std::endl;
    system(command.c_str());
}

void debug_print_parsed(std::vector<asm_line> &parsed_lines){
    std::cout << "  --\n Parsed data:" << std::endl;
    std::cout << " +------+--------+------------+------+-----------+-----------+" << std::endl;
    std::cout << " | LINE | OPCODE |  ADDR/VAL  |  GR  |   MODE    |   LABEL   |" << std::endl;
    std::cout << " +------+--------+------------+------+-----------+-----------+" << std::endl;

    for (unsigned i = 0; i < parsed_lines.size(); ++i){
	asm_line line = parsed_lines.at(i);
	std::cout << " | " << fill_with_spaces(int_to_hex_str(line.phys_addr), 4)
		  << " | " << fill_with_spaces(opcode_to_str(line.opcode), 6)
		  << " | " << fill_with_spaces(line.left_arg, 10)
		  << " | " << fill_with_spaces(line.right_arg, 4)
		  << " | " << fill_with_spaces(addr_mode_to_str(line.addr_mode), 9)
		  << " | " << fill_with_spaces(line.label, 9) 
		  << " |"  << std::endl;
    }
    std::cout << " +------+--------+------------+------+-----------+-----------+" << std::endl;
}
