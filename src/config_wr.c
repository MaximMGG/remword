#include "../headers/config_wr.h"
#include <stdlib.h>
#include <cstdext/estring.h>
#include <cstdext/jsonparser.h>
#include <unistd.h>
#include <stdio.h>
#include <dirent.h>
#include <sys/stat.h>
#include <string.h>


#define STD_CONFIG_PATH "/home/%s/.local/remword/rem.config"
#define STD_PATH_TO_DIR "/home/%s/.local/remword"
#define STD_CONFIG_CONTENT  "working_dir:\n"    \
                            "-dir:\n"           \
                            "--file:\n"


Config_main *Config_read_config() {
    Config_main *conf = new(Config_main);
    conf->config_folder = null;
    conf->path_to_work_folder = null;
    conf->user_name = getlogin();
    str path_to_conf = news(256);
    snprintf(path_to_conf, 256, STD_CONFIG_PATH, conf->user_name);

    JSON_OBJ *config = jsonCreateFromFile(path_to_conf);
    


    return null;
}
REM_CODE Config_add_dir(Config_main *config, str dir_name);
REM_CODE Config_add_file(Config_main *config, str file_name, str dir_index);
REM_CODE Config_write_config(Config_main *config);
