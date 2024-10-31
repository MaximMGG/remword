#include "../headers/config_wr.h"
#include <stdlib.h>
#include <cstdext/estring.h>
#include <cstdext/jsonparser.h>
#include <unistd.h>
#include <stdio.h>
#include <dirent.h>
#include <sys/stat.h>
#include <string.h>


#define STD_CONFIG_PATH "/home/%s/.local/remword/rem.json"
#define STD_PATH_TO_DIR "/home/%s/.local/remword"

#define PATH_TO_WORK_DIR "path_to_work_dir"
#define USER_FOLDERS "user_folders"


i8 std_config_path[256] = {0};



Config_main *Config_read_config() {
    Config_main *conf = new(Config_main);
    conf->user_name = getlogin();
    snprintf(std_config_path, 256, STD_CONFIG_PATH, conf->user_name);

    JSON_OBJ *config = jsonCreateFromFile(std_config_path);
    if (config == null) {
        config = jsonCreateTable(null);
        JSON_OBJ *user_name = jsonCreateTable(conf->user_name);
        jsonInsertInTable(config, user_name);

        i8 buf[128] = {0};
        printf("Hello diar %s, you are new here, please set path to working dir ->", conf->user_name);
        fread(buf, 1, 128, stdin);
        jsonInsertInTable(config, jsonCreateString(PATH_TO_WORK_DIR, buf));
        conf->config = config;
    }
    conf->config = config;
    return conf;
}
REM_CODE Config_add_dir(Config_main *config, str dir_name);
REM_CODE Config_add_file(Config_main *config, str file_name, str dir_index);
REM_CODE Config_write_config(Config_main *config);

void print_file(arraylist *file_content) {
        for(i32 i = 0; i < file_content->len; i++) {
            printf("%d - %s\n", i + 1, (str) arraylistGet(file_content, i));
        }
}

void print_file_cont_menu(Config_main *conf) {
    arraylist *file_content = arraylistFromFile(conf->current_file);
    printf( "1. Show words\n"
            "2. Add word\n"
            "3. Remove word\n"
            "4. Start learning\n"
            "5. Back to dir menu\n");

    i32 user_select = 0;
    fscanf(stdin, "%d", &user_select);
    switch(user_select) {
        case 1: {
            if (file_content != null) {
                print_file(file_content);
                print_file_cont_menu(conf);
            } else {
                printf("Cant open file with name %s\n", conf->current_file);
                print_dir_cont_menu(conf);
            }
        } break;
        case 2: {
            //addword(conf, file_content);
        } break;
        case 3: {
            //learnWords(conf, file_content)
        } break;
        case 4: {
            print_dir_cont_menu(conf);
        } break;
    }

    if (file_content != null) {
    } else {
        printf("Cant open file with name %s\n", conf->current_file);
        print_dir_cont_menu(conf);
    }

}

void print_dir(JSON_OBJ *dir_cont) {
        printf("Dir content:\n");
        for(i32 i = 0; i < dir_cont->table_len; i++) {
            printf("%d - %s\n", i + 1, dir_cont->table[i]->value);
        }
}

void select_file(Config_main *conf, JSON_OBJ *dir_cont) {
    print_dir(dir_cont);
    i32 user_select = 0;
    printf("Enter number for select file, or -1 for back to previous menu\n");
    fscanf(stdin, "%d", &user_select);
    if (user_select > 0 && user_select <= dir_cont->table_len) {
        conf->current_file = dir_cont->table[user_select - 1]->value;
        print_file_cont_menu(conf);
    }
    if (user_select == -1) {
        print_folder_menu(conf);
    }

}

void print_dir_cont_menu(Config_main *conf) {   
    JSON_OBJ *dir_cont = jsonGetObjByKey(conf->config, conf->current_dir);
    if (dir_cont == null) {
        printf("Error while selecting directory with name %s\n", conf->current_dir);
        Config_destroy(conf);
        exit(1);
    } else {
        printf( "1. Show dir content\n" 
                "2. Add file to dir\n"
                "3. Delete file from dir\n"
                "4. Select the file\n"
                "4. Back to dir menu\n");

        i32 user_select = 0;
        switch(user_select) {
            case 1: {
                print_dir(dir_cont);
            } break;
            case 2: {
                //TODO addFileToDir(dir_cont)
            } break;
            case 3: {
                        //TODO deleteFile
            } break;
            case 4: {
                        select_file(conf, dir_cont);
            } break;
            case 5: {
                print_folder_menu(conf);
            }
        }

        printf("Enter number for select file, or -1 for back to previous menu\n");
        fscanf(stdin, "%d", &user_select);
        if (user_select > 0 && user_select <= dir_cont->table_len) {
            conf->current_file = dir_cont->table[user_select - 1]->value;
            print_file_cont_menu(conf);
        }
        if (user_select == -1) {
            print_folder_menu(conf);
        }
    }
}

void print_folder_menu(Config_main *conf) {
    printf("User folders:\n");
    JSON_OBJ *user_folders = jsonGetObjByKey(conf->config, USER_FOLDERS);
    if (user_folders == null) {
        printf("Diear %s, you dont have any folders, please create it\n", conf->user_name);
        main_menu(conf);
    } else {
        for(i32 i = 0; i < user_folders->table_len; i++) {
            printf("%d. - %s\n", i + 1, user_folders->table[i]->key);
        }
        printf("Please select folder, or enter -1 for back to previous menu\n");
        int user_chose = 0;
        fscanf(stdin, "%d", &user_chose);
        if (user_chose > 0 && user_chose <= user_folders->table_len) {
            conf->current_dir = user_folders->table[user_chose - 1]->key;
        } else if (user_chose == -1) {
            main_menu(conf);
        } 
        else {
            printf("Wrong number, please, try agane\n");
            print_folder_menu(conf);
        }
    }
}


void main_menu(Config_main *conf) {
    int user_chose = 0;
    printf( "1. Select folder\n" 
            "2. Create folder\n"
            "3. Exit\n");
    fscanf(stdin, "%d", &user_chose);
    switch(user_chose) {
        case 1: {

        } break;
        case 2: {

        } break;
        case 3: {
            jsonWriteFile(conf->config, std_config_path);
            free(conf);
            exit(0);
        } break;
     }
}

int main() {
    printf("HELLO IN REMEMBER WORD APPLICATION!!!\n");
    Config_main *conf = Config_read_config();
    main_menu(conf);

    return 0;
}


void Config_destroy(Config_main *conf) {
    jsonDestroy(conf->config);
    free(conf);
}
