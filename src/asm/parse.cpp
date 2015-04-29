#include "parse.h"
#include "asm_lib.h"
#include <map>
#include <sstream>
#include <fstream>
#include <iostream>

void parse_addr(asm_line &data, std::string &line){
    std::string addr = get_substr(line, ",");
    data.addr_mode = str_to_addr_mode(addr);    
    data.left_arg = addr;
    
    if (data.addr_mode == ADDRERR){
	std::cout << "(SYNTAX ERROR) L" << data.line_number << ": " 
		  << data.original_line << " [address]" << std::endl;
    }
}

void parse_reg(asm_line &data, std::string &line){
    std::string reg = get_substr(line, " \t");
    if (is_reg(reg)){
	reg.erase(0, 2);
	data.right_arg = reg;
    }else{
	std::cout << "(SYNTAX ERROR) L" << data.line_number << ": " 
		  << data.original_line << " [register]" << std::endl;  
    }
}

void parse_opcode(asm_line &data, std::string &line){
    std::string opcode = get_substr(line, " \t");
    data.opcode = str_to_opcode(opcode);
    if (data.opcode == OPERR)
	std::cout << "(SYNTAX ERROR) L" << data.line_number << ": " 
		  << data.original_line << " [opcode]" << std::endl;  
}

void parse_line(std::vector<asm_line> &lines, std::string &line, int line_number){
    if (is_comment(line) || is_empty(line))
	return;

    asm_line data;
    data.original_line = line; // Used for syntax error messages
    data.line_number = line_number; // Used for syntax error messages
    data.left_arg = ERROR; // Left and right arg should be assigned later, if not something's bugged
    data.right_arg = ERROR;

    if (is_labeled(line)){
	data.label = get_substr(line, ":");
    }

    parse_opcode(data, line);
    switch(no_of_expected_args(data.opcode)){
    case 2:
	parse_addr(data, line);
	parse_reg(data, line);
	break;
    case 1:
	parse_addr(data, line);
	data.right_arg = NOT_ASSIGNED;
	break;
    case 0:
	data.left_arg = NOT_ASSIGNED;
	data.right_arg = NOT_ASSIGNED;
	data.addr_mode = MNA;
	break;
    default:
	std::cout << "(PROGRAM ERROR) L" << data.line_number << ": " 
		  << data.original_line << " [opcode not handled in no_of_expected_args]" << std::endl;  
    }

    data.phys_addr = lines.size();
    lines.push_back(data);
    
    /* If the addressing mode is immediate the operand is expected to be located
     * on the address beneath the current one. */
    if (data.addr_mode == IMMEDIATE){
	asm_line operand;
	operand.left_arg = data.left_arg;
	operand.addr_mode = OPERAND;
	operand.right_arg = NOT_ASSIGNED;
	operand.opcode = ONA;
	operand.phys_addr = lines.size() * ADDR_WIDTH;
	lines.push_back(operand);
    }
    
    if (!is_empty(line) && !is_comment(line))
	std::cout << "(SYNTAX ERROR) L" << data.line_number << ": " 
		  << data.original_line << " [see EOL, comment requires initial ';']" << std::endl;  
}

void link_labels(std::vector<asm_line> &lines){
    asm_line *cur_line;
    std::map<std::string, unsigned> label_to_phys_addr;
    for (unsigned i = 0; i < lines.size(); ++i){
	cur_line = &lines.at(i);
	if (!cur_line->label.empty())
	    label_to_phys_addr[cur_line->label] = cur_line->phys_addr;
	else if (is_labeled(cur_line->left_arg)){
	    if (label_to_phys_addr.count(cur_line->left_arg))
		cur_line->left_arg = int_to_str(label_to_phys_addr[cur_line->left_arg]);
	    else
		std::cout << "(LABEL ERROR) L" << cur_line->line_number << ": " 
			  << cur_line->original_line << " [\'" 
			  << cur_line->left_arg << "\' is not an assigned label]" << std::endl; 
	}
    }
}


std::vector<asm_line> parse_file(std::string file_name){
    std::ifstream asmsrc;
    std::vector<asm_line> lines;
    std::string line;
    int line_number = 1; // Line number is used for syntax error messages
    asmsrc.open(file_name.c_str());
    while(getline(asmsrc, line)){
	str_to_upper(line);
	parse_line(lines, line, line_number);
	++line_number;
    }
    asmsrc.close();
    link_labels(lines);
    return lines;
}
