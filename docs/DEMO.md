# Rhiza-Go Demo

## Quick Demo (asciinema)

[![asciicast](https://asciinema.org/a/placeholder.svg)](https://asciinema.org/a/placeholder)

> **Note**: Replace the placeholder link above with your actual asciinema recording.

## Recording Instructions

### Prerequisites

```bash
# Install asciinema
brew install asciinema  # macOS
# or: go install github.com/asciinema/asciinema@latest
```

### Record the Demo

```bash
# Start recording
asciinema rec rhiza-go-demo.cast

# Run the demo script (see below)
# Press Ctrl+D or type 'exit' when done

# Upload to asciinema.org
asciinema upload rhiza-go-demo.cast
```

### Demo Script

Run these commands during recording:

```bash
# 1. Show available commands
make help

# 2. Install dependencies
make install

# 3. Run tests
make test

# 4. Format and lint
make fmt

# 5. Run linter
make lint

# 6. Show version bump options
make bump BUMP=patch --dry-run

# 7. Build the application
go build ./cmd/rhiza-go/
```

### Automated Demo Script

Save as `demo.sh` and run with `asciinema rec -c ./demo.sh`:

```bash
#!/bin/bash
# Rhiza-Go Demo Script
# Usage: asciinema rec -c ./demo.sh rhiza-go-demo.cast

set -e

# Simulate typing with delays
type_cmd() {
    echo -e "\n\033[1;32m$\033[0m $1"
    sleep 0.5
    eval "$1"
    sleep 1
}

clear
echo "═══════════════════════════════════════"
echo "     Rhiza-Go — Living Templates       "
echo "═══════════════════════════════════════"
sleep 2

type_cmd "make help | head -40"
sleep 2

type_cmd "make install"
sleep 2

type_cmd "make test"
sleep 2

type_cmd "make fmt"
sleep 2

type_cmd "make lint"
sleep 2

echo -e "\n\033[1;34mDemo complete!\033[0m"
sleep 2
```

## Alternative: GIF Recording

### Using terminalizer

```bash
# Install
npm install -g terminalizer

# Record
terminalizer record rhiza-go-demo

# Generate GIF
terminalizer render rhiza-go-demo -o rhiza-go-demo.gif
```

### Using vhs (by Charmbracelet)

Create `demo.tape`:

```tape
# Rhiza-Go Demo
Output rhiza-go-demo.gif

Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Dracula"

Type "make help | head -30"
Enter
Sleep 3s

Type "make install"
Enter
Sleep 5s

Type "make test"
Enter
Sleep 5s

Type "make fmt"
Enter
Sleep 3s

Type "echo 'Done!'"
Enter
Sleep 2s
```

Run with:

```bash
brew install vhs  # or: go install github.com/charmbracelet/vhs@latest
vhs demo.tape
```

## Embedding in README

### Asciinema (recommended)

```markdown
[![asciicast](https://asciinema.org/a/YOUR_ID.svg)](https://asciinema.org/a/YOUR_ID)
```

### GIF

```markdown
![Rhiza-Go Demo](docs/rhiza-go-demo.gif)
```

### Video (GitHub supports mp4)

```markdown
https://user-images.githubusercontent.com/YOUR_ID/VIDEO_ID.mp4
```

## Suggested Demo Flow

1. **Introduction** (5s) - Show project structure with `ls -la`
2. **Help** (5s) - `make help` to show available commands
3. **Install** (10s) - `make install` showing Go dependency setup
4. **Test** (10s) - `make test` with coverage output
5. **Format** (5s) - `make fmt` for formatting
6. **Lint** (5s) - `make lint` for code quality check
7. **Outro** (3s) - Summary message

Total: ~45 seconds
