#ifndef CONFIG_WR_H
#define CONFIG_WR_H
#include <cstdext/core.h>
#include <cstdext/arraylist.h>
#include <cstdext/jsonparser.h>
#include "rem_error.h"

typedef struct file_change{
    str file_name;
    str file_path;

    i8 *file_cont;
    struct file_chage *next;
}file_change;


typedef struct {
    str user_name;
    str path_to_work_dir;

    str current_dir;
    str current_file;
    file_change *changed_files;
    JSON_OBJ *config;
}Config_main;


//MAIN MENU begin

void remMeinMenu(Config_main *conf);
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


#endif //CONFIG_WR_H
