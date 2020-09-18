#include <string.h>

static char LINESEP = '\n';

char* read_line(char* data) {
    char* _linesep = &LINESEP;
    char* token;
    token = strtok(data, _linesep);
    return token;
}
