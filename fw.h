#ifndef FW_H
#define FW_H
#include <dirent.h>
#include <cstdext/list.h>

//set path to dir where will save all files with words
void set_path_to_dir(const char *dirpath);
//return work dir
DIR *get_work_dir();
//change the work dir
void change_work_dir(const char *dirpath);
//return list with all files in the dirrectory
list *get_dir_content(DIR *dir);

#endif //FW_H
