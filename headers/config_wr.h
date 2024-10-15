#ifndef CONFIG_WR_H
#define CONFIG_WR_H
#include <cstdext/core.h>
#include <cstdext/arraylist.h>
#include <cstdext/jsonparser.h>
#include "rem_error.h"

typedef struct {
    str user_name;
    str path_to_work_dir;

    str current_dir;
    str current_file;
    JSON_OBJ *config;
}Config_main;

Config_main *Config_read_config();
REM_CODE Config_add_dir(Config_main *config, str dir_name);
REM_CODE Config_add_file(Config_main *config, str file_name, str dir_index);
REM_CODE Config_write_config(Config_main *config);
void Config_destroy(Config_main *conf);

void print_dir_cont_menu(Config_main *conf);
void main_menu(Config_main *conf);
void print_folder_menu(Config_main *conf);

#endif //CONFIG_WR_H
