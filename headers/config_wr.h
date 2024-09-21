#ifndef CONFIG_WR_H
#define CONFIG_WR_H
#include <cstdext/core.h>
#include <cstdext/arraylist.h>
#include "rem_error.h"

typedef struct {
    arraylist *folder_content;
} Config_folder;

typedef struct {
    str path_to_work_folder;
    arraylist *config_folder;

    str user_name;
}Config_main;

Config_main *Config_read_config();
REM_CODE Config_add_dir(Config_main *config, str dir_name);
REM_CODE Config_add_file(Config_main *config, str file_name, str dir_index);
REM_CODE Config_write_config(Config_main *config);


#endif //CONFIG_WR_H
