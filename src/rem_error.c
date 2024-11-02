#include "../headers/rem_error.h"
#include <stdio.h>
#include <stdarg.h>



void remPrintError(i32 line, const char *function, str file, str fmt, ...) {
    va_list li;
    va_start(li, fmt);
    i8 buf[1024] = {0};
    vsprintf(buf, fmt, li);
    va_end(li);
    fprintf(stderr, "File->%s, Func->%s, Line->%d, error->%s\n", file, function, line, buf);
}
