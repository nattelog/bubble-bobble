// -*-c++-*-
#include <string>

#ifndef ASM_LIB_H
#define ASM_LIB_H


/* Constants */
const int ADDR_WIDTH = 1; // In bytes. Used for the calculation of physical addresses
const int NO_OF_GR = 16; // Number of general registers, not yet implemented
const std::string NOT_ASSIGNED = "N\\A"; 
const std::string ERROR = "*";

/* Order doesn't matter */
enum opcodes {
    OPERR, // Error
    ONA, // Not assigned
    LDA, STR, ADD, SUB,
    CMP, BRA, BRG, BNE,
    BRE, JSR, RTS, AND,
    OR,  LSR, LSL, BRC,
};

/* Order doesn't matter */
enum addr_modes {
    ADDRERR, // Error
    MNA, // Not assigned
    DIRECT, IMMEDIATE, INDIRECT, RELATIVE, OPERAND
};

/* Decoded assembly line.
 * NOTE: The left_arg string could also contain data depending on addressing mode */

struct asm_line {
    std::string original_line;   // Used for error messages
    std::string left_arg;        // Contains address or operand
    std::string right_arg;       // Contains register
    std::string label;           // If line is labeled the symbolic name is stored here
    unsigned line_number;        // The line number in the inputed assembly source code file
    unsigned phys_addr;          // The line number of the expected memory address
    opcodes opcode; 
    addr_modes addr_mode;
};                        

/* String helpers */
std::string get_substr(std::string &line, std::string delim);
void str_trim(std::string &line);
void str_to_upper(std::string &line);

/* Arguments */
bool is_empty(std::string &line);
bool is_labeled(std::string &line);
bool is_comment(std::string &line);
bool is_hex(std::string &line);
bool is_reg(std::string &line);

/* Int to str */
std::string int_to_str(unsigned &num);
std::string int_to_hex_str(unsigned &num);

/* String to int */
unsigned str_hex_to_int(std::string &hex);
unsigned str_dec_to_int(std::string &dec);
unsigned str_to_int(std::string val); // Will pass val to appropriate function by checking is_hex

/* Data to bitcode */
unsigned op_to_int(opcodes &opcode);
unsigned addr_mode_to_int(addr_modes &addr_mode);

/* String to enum */
opcodes str_to_opcode(std::string &opcode);
addr_modes str_to_addr_mode(std::string &addr);

/* Enum to string */
std::string opcode_to_str(opcodes &opcode);
std::string addr_mode_to_str(addr_modes &addr_mode);

/* Other */
int no_of_expected_args(opcodes opcode);

#endif
