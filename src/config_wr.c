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

#define JSON_USER_NAME "user_name"
#define JSON_PATH_TO_WORK_DIR "path_to_work_dir"
#define JSON_USER_FOLDERS "user_folders"

//MAIN MENU begin

void remMainMenu(Config_main *conf) {
    printf( "1. Select folder.\n"
            "2. Create folder.\n"
            "3. Set path to working dirrectory.\n"
            "4. Exit\n");

    u32 enter = 0;
    fscanf(stdin, "%d", &enter);

    switch(enter) {
        case 1: {
            remSelectFolderMenu(conf);
        } break;
        case 2: {
            remCreateFolder(conf);
        } break;
        case 3: {
            remSetPathToWorkDir(conf);
        } break;
        case 4: {
            remExit(conf);
        } break;
        default: {
            printf("Don net the opetion %d\nTRY AGANGE\n", enter);
            remMainMenu(conf);
        }
    }

}


void remSetPathToWorkDir(Config_main *conf) {

}
void remCreateFolder(Config_main *conf) {

}
void remExit(Config_main *conf) {

}

//MAIN MENU end

//SELECT FOLDER begin
void remSelectFolderMenu(Config_main *conf) {
    if (conf->files->files_count == 0) {
        printf("0.\nNo dirs in work folder, create new one\n");
        remMainMenu(conf);
    }
    printf("Enter dir number or 0 for back in main menu\n");
    for(i32 i = 0; i < conf->files->files_count; i++) {
        printf("%d. %s\n", i + 1, conf->files[i].name);
    }
    i32 enter = 0;
    fscanf(stdin, "%d", &enter);
    if (enter == 0) {
        remMainMenu(conf);
    } else {
        remFolderContentMenu(conf, conf->files[enter - 1].name);
    }
}

//SELECT FOLDER end

//FOLDER CONTENT begin
void remFolderContentMenu(Config_main *conf, str folder_name) {

}

//FOLDER CONTENT end

//FILE CONTENT bigin
void remFileContentMenu(Config_main *conf, str file_name) {

}
//FILE CONTENT end


//MEMORISING begin

void remStartMemorise(Config_main *conf, str file_name) {

}

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
    if (conf->config == null) {
        conf->config = jsonCreateTable(null);
        jsonInsertInTable(conf->config, jsonCreateString(JSON_USER_NAME, conf->user_name));
        printf("Please, enter the path to user working dir-> ");
        byte buf[512] = {0};
        read(STDIN_FILENO, buf, 512);
        jsonInsertInTable(conf->config, jsonCreateString(JSON_PATH_TO_WORK_DIR, buf));
        conf->path_to_work_dir = strNew(buf);
        conf->files = fileGetDirCont(conf->path_to_work_dir, true);
    } else {
        conf->path_to_work_dir = strNew(jsonGetObjByKey(conf->config, JSON_PATH_TO_WORK_DIR)->value);
        conf->files = fileGetDirCont(conf->path_to_work_dir, true);
    }
}

int main() {
    setbuf(stdout, NULL);
    Config_main *conf = new(Config_main);
    remSetUserName(conf);
    printf("Hello diar %s in REMEMBER WORDS application!!!\n", conf->user_name);
    if (remConfigExist(conf)) {
        remLoadConfig(conf);
    } else {
        remCreateConfig(conf);
        remLoadConfig(conf);
    }
    remMainMenu(conf);

    return 0;
}


