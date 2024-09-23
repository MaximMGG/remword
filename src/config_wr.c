#include "../headers/config_wr.h"
#include <stdlib.h>
#include <cstdext/estring.h>
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

    FILE *conf_f = fopen(path_to_conf, "r");
    if (conf_f == null) {
        char buf[256] = {0};
        snprintf(buf, 256, STD_PATH_TO_DIR, conf->user_name);
        mkdir(buf, 0700);
        conf_f = fopen(path_to_conf, "w");
        if (conf_f == null) {
            REM_ERROR("Cant create file with path %s\n", path_to_conf);
            return null;
        }
        fwrite(STD_CONFIG_CONTENT, 1, strlen(STD_CONFIG_CONTENT), conf_f);
        fclose(conf_f);
        return conf;
    }

    arraylist *conf_cont = arraylistFromFile(path_to_conf);
    for(i32 i = 0; i < conf_cont->len; i++) {
        i32 find = strFind(arraylistGet(conf_cont, i), "working_dir:", 0);
        if (find != -1) {
            //TODO (maxim) implemet after strSubString will be written
            // str working_dir = strSubString();
        }

    }

    return null;
}
REM_CODE Config_add_dir(Config_main *config, str dir_name);
REM_CODE Config_add_file(Config_main *config, str file_name, str dir_index);
REM_CODE Config_write_config(Config_main *config);
