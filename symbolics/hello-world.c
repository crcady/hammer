#include "hammer/hammer.h"
#include "klee/klee.h"
#include <stdio.h>

 int main(int argc, char *argv[]) {
    uint8_t input[12];
    size_t inputsize;

    klee_make_symbolic(input, sizeof(input), "input");

    HParser *hello_parser = h_token("Hello World", 11);

    HParseResult *result = h_parse(hello_parser, input, 12);
    if(result) {
        printf("yay!\n");
    } else {
        printf("boo!\n");
    }
}