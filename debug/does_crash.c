#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

int main() {
    fcntl(STDIN_FILENO, F_SETFL, fcntl(STDIN_FILENO, F_GETFL) | O_NONBLOCK);

    while (1) {
        fwrite("   ", 1, 3, stdout);
    }

    return 0;
}
