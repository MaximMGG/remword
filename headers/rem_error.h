#ifndef REM_ERROR_H
#define REM_ERROR_H
#include <cstdext/core.h>


#define REM_ERROR(...) remPrintError(__LINE__, __FUNCTION__, __FILE__, __VA_ARGS__)

void remPrintError(i32 line, const char *function, str file, str fmt, ...);

typedef enum {
    REM_OK, 
}REM_CODE;

#endif //REM_ERROR_H
