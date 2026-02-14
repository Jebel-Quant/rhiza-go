# Project Documentation

This directory contains documentation and configuration for generating project documentation.

## Building Documentation

You can build the project documentation using the main project Makefile:

```bash
make book
```

This process involves:
1. Generating API documentation from Go source code using `go doc`.
2. Generating test coverage reports.
3. Combining them into a cohesive documentation structure.

## Documentation Customisation

### API Documentation (godoc)

Go's built-in `godoc` tool generates API documentation from doc comments in your Go source code. Run it locally:

```bash
make docs
```

Write documentation as comments directly above exported types, functions, and packages following [Go doc conventions](https://go.dev/blog/godoc).

### Project Logo

The documentation generation supports embedding a project logo.

**Default Behavior:**
By default, the build looks for `assets/rhiza-logo.svg`.

**Customization:**
You can change the logo by setting the `LOGO_FILE` variable in your project's `Makefile` or `local.mk`.

```makefile
# Example: Use a custom PNG logo
LOGO_FILE := assets/my-company-logo.png
```

To disable the logo entirely, set the variable to an empty string:

```makefile
# Example: Disable logo
LOGO_FILE :=
```
