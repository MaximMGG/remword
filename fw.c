#include "fw.h"
#include <string.h>
#include <cstdext/core.h>
#include <cstdext/estring.h>
#include <stdio.h>

#define CONFIG_PATH "/home/%s/.memword/mem.config"
char pathToDir[512];

void set_path_to_dir(const char *dirpath) {
    strcpy(pathToDir, dirpath);
}

DIR *get_work_dir() {
    i32 pathlen = strlen(pathToDir);
    if (pathToDir[pathlen - 1] != '/') {
        pathToDir[pathlen] = '/';
    }
    DIR *d = opendir(pathToDir);
    if (d == NULL) {
        PERR("dir %s does not exist\n", pathToDir);
        return null;
    }
    return d;
}

list *get_dir_content(DIR *dir) {
    list *dircont = newList(0, array_list, L_STRING);

    struct dirent *ddir;
    while((ddir = readdir(dir)) != null) {
        listAdd(dircont, ddir->d_name, -1);
    }

    return dircont;
}


void change_work_dir(const char *dirpath);
