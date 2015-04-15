#include "handle.h"
#include "asm_lib.h"
#include "assert.h"
#include <inttypes.h>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <iostream>
#include <math.h>

/* Line consists of
      16⁷  16⁶  16⁵  16⁴      16²     16⁰
   +----+----+----+----+----------------+
   | OP | GR | M  | -- |     ADDRESS    |
   +----+----+----+----+----------------+
   31      24        16        8       0  
   
*/

void handle_operand(asm_line &data, std::fstream *output){
    uint32_t bytes = str_to_int(data.left_arg);
    /*uint8_t mmsbs = 0;
    uint8_t lmsbs = 0;
    uint8_t mlsbs = 0;
    uint8_t llsbs = 0;
    llsbs = bytes & 0xFF;
    mlsbs = (bytes >> 8) & 0xFF;
    lmsbs = (bytes >> 16) & 0xFF;
    mmsbs = (bytes >> 24) & 0xFF;*/
    output->put(bytes >> 24);
    output->put(bytes >> 16);
    output->put(bytes >> 8);
    output->put(bytes);
}

void handle_op_and_reg(asm_line &data, std::fstream *output){
    uint8_t byte = 0;
    unsigned value = 0;
    value = op_to_int(data.opcode);
    assert(value < 16);
    byte += value;
    byte = byte << 4;
    if (no_of_expected_args(data.opcode) == 2)
	value = str_to_int(data.right_arg);
    else
	value = 0;
    assert(value < 16);
    byte += value;
    output->put(byte);
}

void handle_addr_mode(asm_line &data, std::fstream *output){
    uint8_t byte = 0;
    unsigned value = 0;
    if (no_of_expected_args(data.opcode) != 0)
	value = addr_mode_to_int(data.addr_mode);
    assert(value < 16);
    byte += value;
    byte = byte << 4;
    output->put(byte);
}

void handle_addr(asm_line &data, std::fstream *output){
    uint16_t bytes = 0;
    uint8_t msbs_byte = 0;
    uint8_t lsbs_byte = 0;
    if (no_of_expected_args(data.opcode) != 0)
	bytes = str_to_int(data.left_arg);
    lsbs_byte = bytes & 0xFF;
    msbs_byte = (bytes >> 8) & 0xFF;
    output->put(msbs_byte);
    output->put(lsbs_byte);
}

void gen_bitcode(std::vector<asm_line> &lines, const std::string &OUTPUT_FN){
    std::fstream output;
    asm_line data;
    std::string file_name = OUTPUT_FN;
    output.open(OUTPUT_FN.c_str(), std::fstream::binary | std::fstream::out | std::fstream::trunc);
    for (unsigned i = 0; i < lines.size(); ++i){
	data = lines.at(i);
	if (data.addr_mode == OPERAND)
	    handle_operand(data, &output);
	else{
	    handle_op_and_reg(data, &output);
	    handle_addr_mode(data, &output);
	    handle_addr(data, &output);
	}
    }
    output.close();
}
