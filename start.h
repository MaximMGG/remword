#ifndef START_H
#define START_H
#include <cstdext/list.h>

typedef struct {
    char pathToDir[512];
    list *files;
}dir_cont;

typedef struct {
    char userName[128];
    char pathToLastDir[512];
    list *allDirs;

    int existed;
}M_CONFIG;


//checking mem.config if not exist create it
M_CONFIG *check_config();
//setting current path to dir in M_CONFIG
int set_current_path_to_dir(M_CONFIG *config, const char *path);
//save config to the path of config
int save_config(M_CONFIG *config);

#endif //START_H
