#include <assert.h>

#include "project.h"

int main(void) {
    assert(project_add(20, 22) == 42);
    assert(project_add(-1, 1) == 0);
    assert(project_add(0, 0) == 0);

    return 0;
}
