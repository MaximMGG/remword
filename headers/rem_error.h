#ifndef REM_ERROR_H
#define REM_ERROR_H
#include <cstdext/core.h>


#define REM_ERROR(fmt, ...) remPrintError(__LINE__, __FUNCTION__, __FILE__, fmt, __VA_ARGS__)

void remPrintError(i32 line, const char *function, str file, str fmt, ...);

typedef enum {
    REM_OK, 
    REM_ERROR,
    REM_FILE_CREATE_ERROR,
    REM_DIR_CREATE_ERROR,
    REM_FILE_OPEN_ERROR,
}REM_CODE;

#endif //REM_ERROR_H
