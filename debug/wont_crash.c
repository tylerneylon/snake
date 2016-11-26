#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main() {
    fcntl(STDIN_FILENO, F_SETFL, fcntl(STDIN_FILENO, F_GETFL) | O_NONBLOCK);

    while (1) {
        size_t ret = write(STDIN_FILENO, "   ", 3);
        if (ret == -1) {
            char *str = strerror(errno);
            fprintf(stderr, "%s\n", str);
            fflush(stderr);

            if (errno != EAGAIN) exit(1);
        }
    }

    return 0;
}
