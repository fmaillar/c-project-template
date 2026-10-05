# C Project Template

Reusable C17 project template with a strict, reproducible development toolchain.

## Requirements

- GCC
- GNU Make
- clangd
- clang-format
- clang-tidy
- GDB
- Bear

## Build

```sh
make
```

## Tests

```sh
make test
```

## Sanitizers

```sh
make run-sanitize
```

## Static analysis

```sh
make tidy
```

## Formatting

```sh
make format
make format-check
```

## Full validation

```sh
make check
```

## Compilation database

```sh
make compdb
```

`compile_commands.json` is generated locally and is not versioned.
