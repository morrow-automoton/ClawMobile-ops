#include <unistd.h>

uid_t getuid(void) { return 2000; }
uid_t geteuid(void) { return 2000; }
gid_t getgid(void) { return 2000; }
gid_t getegid(void) { return 2000; }
