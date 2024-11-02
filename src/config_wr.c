#include "../headers/config_wr.h"
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cstdext/estring.h>

#define STD_CONFIG_PATH_FMT "/home/%s/.local/remword/rem.json"
#define STD_PATH_TO_DIR_FMT "/home/%s/.local/remword"
byte STD_CONFIG_PATH[512] = {0};
byte STD_PATH_TO_DIR[512] = {0};

#define PATH_TO_WORK_DIR "path_to_work_dir"
#define USER_FOLDERS "user_folders"

//MAIN MENU begin




void remMeinMenu(Config_main *conf) {

}


void remSetPathToWorkDir(Config_main *conf);
void remCreateFolder(Config_main *conf);
void remExit(Config_main *conf);

//MAIN MENU end

//SELECT FOLDER begin
void remSelectFolderMenu(Config_main *conf);

//SELECT FOLDER end

//FOLDER CONTENT begin
void remFolderContentMenu(Config_main *conf, str folder_name);

//FOLDER CONTENT end

//FILE CONTENT bigin
void remFileContentMenu(Config_main *conf, str file_name);
//FILE CONTENT end


//MEMORISING begin

void remStartMemorise(Config_main *conf, str file_name);

//MEMORISING end

static void remSetUserName(Config_main *conf) {
    conf->user_name = strNew(getlogin());
}
static boolean remConfigExist(Config_main *conf) {
    boolean config_exist = false;
    u32 path_len = strlen(STD_CONFIG_PATH) + strlen(conf->user_name) + 1;
    sprintf(STD_CONFIG_PATH, STD_CONFIG_PATH_FMT, conf->user_name);

    FILE *f = fopen(STD_CONFIG_PATH, "r");
    if (!f) return false;
    else {
        fclose(f);
        return true;
    }
    return false;
}

static void remCreateConfig(Config_main *conf) {

    sprintf(STD_PATH_TO_DIR, STD_PATH_TO_DIR_FMT, conf->user_name);
    i8 buf[1024] = {0};
    sprintf(buf, "mkdir -p %s", STD_PATH_TO_DIR);
    system(buf);

    FILE *f = fopen(STD_CONFIG_PATH, "w");
    if (!f)
        REM_ERROR("Cant create file with path -> %s", STD_CONFIG_PATH);
    fclose(f);
}

static void remLoadConfig(Config_main *conf) {
    conf->config = jsonCreateFromFile(STD_CONFIG_PATH);
}

int main() {
    Config_main *conf = new(Config_main);
    remSetUserName(conf);
    if (remConfigExist(conf)) {
        remLoadConfig(conf);
    } else {
        remCreateConfig(conf);
        remLoadConfig(conf);
    }
    remMainMenu(conf);

    return 0;
}


