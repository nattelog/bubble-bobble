#include "parse.h"
#include "handle.h"
#include "debug.h"
#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>

int main(int argc, char *argv[]){
    const std::string OUTPUT_FN = "bitcode";
    
    std::vector<asm_line> parsed_lines;
    std::string arg;
    std::string file_name;
    bool disp_bitcode = false;
    bool disp_debug = false;
    
    if (argc < 2){
	std::cout << "(INPUT ERROR) Expected at least 1 argument got " << argc-1 << std::endl; 
	return -1;
    }
    
    for (int i = 1; i < argc; ++i){
	arg = argv[i];
	if (arg == "-b")
	    disp_bitcode = true;
	else if (arg == "-d")
	    disp_debug = true;
	else if (arg[0] == '-')
	    std::cout << "(INPUT ERROR) Unknown argument: " << arg << std::endl;
	else if (arg[0] != '-' && file_name.empty())
	    file_name = argv[i];
	else
	    std::cout << "(INPUT ERROR) O_o" << std::endl;
    }

    std::ifstream fn_test;
    fn_test.open(file_name.c_str());
    if (!fn_test.is_open()){
	std::cout << "(INPUT ERROR) Could not open file \'" << argv[1] << "\'" << std::endl;
	return -1;
    }

    fn_test.close();
    parsed_lines = parse_file(file_name);
    
    if (disp_debug)
	debug_print_parsed(parsed_lines);
    
    std::cout << "\nSaving bitcode to file \"" << OUTPUT_FN << "\"\n" << std::endl;
    gen_bitcode(parsed_lines, OUTPUT_FN);
    
    if (disp_bitcode)
	debug_print_bitcode(OUTPUT_FN);

    return 0;
}
