#include <cstdext/build.h>


void build(char *prog) {
    executable *exe = buildCreateExecutable("remw");
    buildSetProgName("remw", exe);
    buildAddSrc(BUILD_FOLDER, exe, "src/");
    buildAddLib("cstd", exe);
    buildAddExecutable(exe);
    buildBuild(exe);

    executable *debug = buildCreateExecutable("debug");
    buildSetProgName("remw", debug);
    buildAddSrc(BUILD_FOLDER, debug, "src/");
    buildAddLib("cstd", debug);
    buildAddExecutable(debug);
    buildAddFlags("-g", debug);
    buildBuild(exe);

    buildExecute(prog);
    buildCleanup();
}
