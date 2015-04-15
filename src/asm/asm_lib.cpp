#include "asm_lib.h"
#include <string>
#include <sstream>
#include <iostream>
#include <assert.h>

/* -------------- *
 * String helpers *
 * -------------- */

/* NOTE: Modifies the passed string and _discards_the_delimiter_
 * Accepts arbitrary number of spaces between arguments 
 * If no delimiter is found the full line will be returned.
 * Every character that is returned is discarded from line. */

std::string get_substr(std::string &line, std::string delim){
    str_trim(line);
    std::string substr;
    size_t delim_pos = line.find_first_of(delim);
    if (delim_pos != std::string::npos){
	substr = line.substr(0, delim_pos);
	line.erase(0, delim_pos+1);
    }
    else{
	substr = line;
	line.clear();
    }
    return substr;
}

/* Removes every character up until the first character that
 * is not a space or tab from line */
void str_trim(std::string &line){
    size_t start_pos = line.find_first_not_of(" \t");
    if (start_pos != std::string::npos)
	line = line.substr(start_pos);
}

void str_to_upper(std::string &line){
    for (unsigned i = 0; i < line.size(); ++i){
	line[i] = std::toupper(line[i]);
    }
}

std::string int_to_str(unsigned &num){
    std::stringstream convert;
    convert << num;
    assert(!convert.fail());
    return convert.str();
}

std::string int_to_hex_str(unsigned &num){
    std::stringstream convert;
    convert << std::hex << num;
    assert(!convert.fail());
    return convert.str();
}

unsigned str_hex_to_int(std::string &hex){
    unsigned result;
    std::stringstream convert;
    convert << std::hex << hex;
    convert >> result;
    if (convert.fail()){
	std::cout << "(PROGRAM ERROR) Convertion of string to integer failed, str: " << hex << std::endl;
	assert(!convert.fail());
    }
    return result;
}

unsigned str_dec_to_int(std::string &dec){
    unsigned result;
    std::stringstream convert;
    convert << dec;
    convert >> result;
    if (convert.fail()){
	std::cout << "(PROGRAM ERROR) Convertion of string to integer failed, str: " << dec << std::endl;
	assert(!convert.fail());
    }
    return result;
}

unsigned str_to_int(std::string val){
    if (is_hex(val)){
	val.erase(0, 1);
	return str_hex_to_int(val);
    }
    else
	return str_dec_to_int(val);
}

/*Considers strings that only consists of spaces and tabs as empty */
bool is_empty(std::string &line){
    size_t pos = line.find_first_not_of(" \t");
    if (pos == std::string::npos)
	return true;
    return false;
}

bool is_labeled(std::string &line){
    str_trim(line);
    return line[0] == '_';
}

bool is_comment(std::string &line){
    str_trim(line);
    return line[0] == ';';
}

bool is_hex(std::string &line){
    return line[0] == '$';
}

bool is_reg(std::string &line){
    if (line[0] == 'G' && line[1] == 'R'){
        return true;
    }
    return false;
}

/* --------------- *
 * Data to bitcode *
 * --------------- */

unsigned op_to_int(opcodes &opcode){
    switch(opcode){
    case LDA:
	return 0;
    case STR:
	return 1;
    case ADD:
	return 2;
    case SUB:
	return 3;
    case CMP:
	return 4;
    case BRA:
	return 5;
    case BRG:
	return 6;
    case BNE:
	return 7;
    case BRE:
	return 8;
    case JSR:
	return 9;
    case RTS:
	return 10;
    case AND:
	return 11;
    case OR:
	return 12;
    case LSR:
	return 13;
    case LSL:
	return 14;
    case BRC:
	return 15;
    default:
	std::cout << "(PROGRAM ERROR): Unhandled opcode in asm_lib.cpp op_to_bitcode: #" << opcode << std::endl;
    }
    return 0;
}

unsigned addr_mode_to_int(addr_modes &addr_mode){
    switch(addr_mode){
    case DIRECT:
	return 0;
    case IMMEDIATE:
	return 1;
    case INDIRECT:
	return 2;
    case RELATIVE:
	return 3;
    default:
	std::cout << "(PROGRAM ERROR): Unhandled address mode in asm_lib.cpp addr_mode_to_bitcode: #" << addr_mode << std::endl;
    }
    return 0;
}


/* -------------- *
 * String to enum *
 * -------------- */

opcodes str_to_opcode(std::string &opcode){
    if (opcode == "LDA"){
	return LDA;
    }
    else if (opcode == "STR"){
        return STR;
    }
    else if (opcode == "ADD"){
        return ADD;
    }
    else if (opcode == "SUB"){
        return SUB;
    }
    else if (opcode == "CMP"){
	return CMP;
    }
    else if (opcode == "BRA"){
	return BRA;
    }
    else if (opcode == "BRG"){
        return BRG;
    }
    else if (opcode == "BNE"){
	return BNE;
    }
    else if (opcode == "BRE"){
        return BRE;
    }
    else if (opcode == "JSR"){
        return JSR;
    }
    else if (opcode == "RTS"){
        return RTS;
    }
    else if (opcode == "AND"){
        return AND;
    }
    else if (opcode == "OR"){
        return OR;
    }
    else if (opcode == "LSR"){
	return LSR;
    }
    else if (opcode == "LSL"){
	return LSL;
    }
    else if (opcode == "BRC"){
	return BRC;
    }
    else if (opcode == "ONA"){
	return ONA;
    }
    return OPERR;
}

/* NOTE: Relative missing 
 * Modifies addr, removes the addressing mode identifiers.
 * '$', '_' are not primarily addressing mode identifiers,
 * '$' indicates a ucpoming hexadecimal value '_' indicates
 * label. */

addr_modes str_to_addr_mode(std::string &addr){
    if (addr[0] == '$'){
	return DIRECT;
    }
    else if (addr[0] == '_'){
	return DIRECT;
    }
    else if (addr[0] == '(' && addr[addr.size()-1] == ')'){
	addr.erase(0, 1);
	addr.erase(addr.size()-1, 1);
	return INDIRECT;
    }
    else if (addr[0] == '#'){
	addr.erase(0, 1);
	return IMMEDIATE;
    }
    return ADDRERR;
}

/* ----- *
 * OTHER *
 * ----- */

int no_of_expected_args(opcodes opcode){
    switch(opcode){
    case LDA:
    case STR:
    case ADD:
    case SUB:
    case CMP:
    case AND:
    case OR:
	return 2;
    case BRA:
    case BRG:
    case BNE:
    case BRE:
    case BRC:
    case JSR:
	return 1;
    case RTS:
    case OPERR:
	return 0;
    default:
        std::cout << "(PROGRAM ERROR): Unhandled opcode in asm_lib.cpp no_of_expected_args: #" << opcode << std::endl;
    }
    return -1;
}

/* -------------- *
 * Enum to string *
 * -------------- */

std::string opcode_to_str(opcodes &opcode){
    switch(opcode){
    case LDA:
	return "LDA";
    case STR:
	return "STR";
    case ADD:
	return "ADD";
    case SUB:
	return "SUB";
    case CMP:
	return "CMP";
    case BRA:
	return "BRA";
    case BRG:
	return "BRG";
    case BNE:
	return "BNE";
    case BRE:
	return "BRE";
    case JSR:
	return "JSR";
    case RTS:
	return "RTS";
    case AND:
	return "AND";
    case OR:
	return "OR";
    case LSR:
	return "LSR";
    case LSL:
	return "LSL";
    case BRC:
	return "BRC";
    case ONA:
	return "N/A";
    default:
	std::cout << "(PROGRAM ERROR): Unhandled opcode in asm_lib.cpp opcode_to_string: #" << opcode << std::endl;
	return "ERR";
    }
}

std::string addr_mode_to_str(addr_modes &addr_mode){
    switch(addr_mode){
    case DIRECT:
	return "DIRECT";
    case IMMEDIATE:
	return "IMMEDIATE";
    case INDIRECT:
	return "INDIRECT";
    case RELATIVE:
	return "RELATIVE";
    case OPERAND:
	return "OPERAND";
    case MNA:
	return "N/A";
    default:
	std::cout << "(PROGRAM ERROR): Unhandled address mode in asm_lib.cpp addr_mode_to_string: #" << addr_mode << std::endl;
	return "MODE_ERROR";
    }
}
