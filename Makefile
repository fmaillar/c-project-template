.RECIPEPREFIX := >

PROJECT := $(notdir $(CURDIR))

CC := gcc

CPPFLAGS := -Iinclude
CSTD := -std=c17
WARNINGS := -Wall -Wextra -Wpedantic
DEPFLAGS := -MMD -MP

COMMON_CFLAGS := $(CSTD) $(WARNINGS) $(DEPFLAGS)

SRC := $(wildcard src/*.c)
HEADERS := $(wildcard include/*.h)
LIB_SRC := $(filter-out src/main.c,$(SRC))
TEST_SRC := $(wildcard tests/test_*.c)

DEBUG_DIR := build/debug
RELEASE_DIR := build/release
SANITIZE_DIR := build/sanitize
TEST_DIR := build/test

DEBUG_OBJ := $(patsubst src/%.c,$(DEBUG_DIR)/%.o,$(SRC))
RELEASE_OBJ := $(patsubst src/%.c,$(RELEASE_DIR)/%.o,$(SRC))
SANITIZE_OBJ := $(patsubst src/%.c,$(SANITIZE_DIR)/%.o,$(SRC))

TEST_LIB_OBJ := $(patsubst src/%.c,$(TEST_DIR)/lib/%.o,$(LIB_SRC))
TEST_BINS := $(patsubst tests/%.c,$(TEST_DIR)/%,$(TEST_SRC))

DEBUG_BIN := $(DEBUG_DIR)/$(PROJECT)
RELEASE_BIN := $(RELEASE_DIR)/$(PROJECT)
SANITIZE_BIN := $(SANITIZE_DIR)/$(PROJECT)

.PHONY: all debug release sanitize run run-release run-sanitize
.PHONY: test format format-check tidy compdb check clean

all: debug

debug: $(DEBUG_BIN)

release: $(RELEASE_BIN)

sanitize: $(SANITIZE_BIN)

$(DEBUG_BIN): $(DEBUG_OBJ)
>mkdir -p $(@D)
>$(CC) $^ -o $@

$(DEBUG_DIR)/%.o: src/%.c
>mkdir -p $(@D)
>$(CC) $(CPPFLAGS) $(COMMON_CFLAGS) -g3 -O0 -c $< -o $@

$(RELEASE_BIN): $(RELEASE_OBJ)
>mkdir -p $(@D)
>$(CC) $^ -o $@

$(RELEASE_DIR)/%.o: src/%.c
>mkdir -p $(@D)
>$(CC) $(CPPFLAGS) $(COMMON_CFLAGS) -O3 -DNDEBUG -c $< -o $@

$(SANITIZE_BIN): $(SANITIZE_OBJ)
>mkdir -p $(@D)
>$(CC) -fsanitize=address,undefined $^ -o $@

$(SANITIZE_DIR)/%.o: src/%.c
>mkdir -p $(@D)
>$(CC) $(CPPFLAGS) $(COMMON_CFLAGS) \
>    -g3 -O1 \
>    -fsanitize=address,undefined \
>    -fno-omit-frame-pointer \
>    -c $< -o $@

run: debug
>$(DEBUG_BIN)

run-release: release
>$(RELEASE_BIN)

run-sanitize: sanitize
>$(SANITIZE_BIN)

$(TEST_DIR)/lib/%.o: src/%.c
>mkdir -p $(@D)
>$(CC) $(CPPFLAGS) $(COMMON_CFLAGS) -g3 -O0 -c $< -o $@

$(TEST_DIR)/%: tests/%.c $(TEST_LIB_OBJ)
>mkdir -p $(@D)
>$(CC) $(CPPFLAGS) $(CSTD) $(WARNINGS) -g3 -O0 \
>    $< $(TEST_LIB_OBJ) -o $@

test: $(TEST_BINS)
>@set -e; \
>for test_bin in $(TEST_BINS); do \
>    printf 'TEST %s\n' "$$test_bin"; \
>    "$$test_bin"; \
>done

format:
>clang-format -i $(SRC) $(HEADERS) $(TEST_SRC)

format-check:
>clang-format --dry-run --Werror $(SRC) $(HEADERS) $(TEST_SRC)

compile_commands.json: Makefile
>bear -- $(MAKE) -B debug

compdb:
>rm -f compile_commands.json
>$(MAKE) compile_commands.json

tidy: compile_commands.json
>clang-tidy --quiet -p . -header-filter='.*' $(SRC)

check: format-check tidy test

clean:
>rm -rf build compile_commands.json

-include $(DEBUG_OBJ:.o=.d)
-include $(RELEASE_OBJ:.o=.d)
-include $(SANITIZE_OBJ:.o=.d)
-include $(TEST_LIB_OBJ:.o=.d)
