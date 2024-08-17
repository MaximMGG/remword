#include <stdio.h>
#include "start.h"
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

#define CONFIG_PATH "/home/%s/.memwords/mem.config"

#define CONFIG_CONT                             \
                        "USER:                  \
                            %s\n"               \
                        "USER_DIRS:             \
                            %s\n"




static char *get_user_name() {
    char *username = getlogin();
    if (username != NULL)
        return username;
    else {
      fprintf(stderr, "username is NULL, thomething went wrong\n");
      return null;
    }
}

static list *read_config(FILE *f) {
    char buf[512];
    list *configl = newList(0, array_list, L_STRING);
    while(!feof(f)) {
        fgets(buf, 512, f);
        listAdd(configl, buf, -1);
    }
    return configl;
}

M_CONFIG *check_config() {
    char *username = get_user_name();
    if (username == null) {
        _exit(EXIT_FAILURE);
    }
    char pathToConfig[128];
    sprintf(pathToConfig, CONFIG_PATH, username);

    FILE *f = fopen(pathToConfig, "r");
    if (f == null) {
        f = fopen(pathToConfig, "w");
        printf("HELLO FOR THE FIRST TIME IN MEMWORDS APP!!!\n");
        M_CONFIG *conf = malloc(sizeof(M_CONFIG));
        strcpy(conf->userName, username);
        conf->existed = false;
        return conf;
    }

    list *configlist = read_config(f);
    fclose(f);
    M_CONFIG *conf = malloc(sizeof(M_CONFIG));
    strcpy(conf->userName, username);
    conf->existed = true;
    char *confUser = listGet(configlist, 1);
    if (strcmp(confUser, username) != 0) {
      fprintf(stderr, "Thomething went wrong, maybe you change your username\n");
      listAdd(configlist, username, 1);
    }

    return null;
}
//setting current path to dir in M_CONFIG
int set_current_path_to_dir(M_CONFIG *config, const char *path);
//save config to the path of config
int save_config(M_CONFIG *config);

int main() {


    return 0;
}
