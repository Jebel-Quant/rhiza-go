# Installation Guide

This guide covers multiple ways to install `rhiza-go` on your system.

## Quick Install

### macOS and Linux

The fastest way to install `rhiza-go` is using our installation script:

```bash
curl -sSfL https://raw.githubusercontent.com/Jebel-Quant/rhiza-go/main/install.sh | sh
```

This will download the latest release binary for your platform and install it to `/usr/local/bin`.

#### Custom Installation Directory

To install to a custom directory:

```bash
curl -sSfL https://raw.githubusercontent.com/Jebel-Quant/rhiza-go/main/install.sh | sh -s -- -b /custom/path
```

#### Specific Version

To install a specific version:

```bash
curl -sSfL https://raw.githubusercontent.com/Jebel-Quant/rhiza-go/main/install.sh | sh -s -- -v v0.1.0
```

### Windows

For Windows users, download the appropriate `.zip` file from the [releases page](https://github.com/Jebel-Quant/rhiza-go/releases/latest) and extract it to a directory in your PATH.

Alternatively, use PowerShell:

```powershell
# Download and extract to current directory
$version = (Invoke-WebRequest -Uri "https://api.github.com/repos/Jebel-Quant/rhiza-go/releases/latest" -UseBasicParsing | ConvertFrom-Json).tag_name
$arch = if ([System.Environment]::Is64BitOperatingSystem) {
    if ([System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -eq 'Arm64') { "arm64" } else { "amd64" }
} else { "386" }
$url = "https://github.com/Jebel-Quant/rhiza-go/releases/download/$version/rhiza-go_${version}_windows_${arch}.zip"
Invoke-WebRequest -Uri $url -OutFile "rhiza-go.zip"
Expand-Archive -Path "rhiza-go.zip" -DestinationPath "." -Force
Remove-Item "rhiza-go.zip"
```

## Package Managers

### Homebrew (macOS and Linux)

If you use [Homebrew](https://brew.sh/), you can install `rhiza-go` from our tap:

```bash
brew tap Jebel-Quant/tap
brew install rhiza-go
```

To upgrade to the latest version:

```bash
brew update
brew upgrade rhiza-go
```

### Go Install

If you have Go installed, you can install `rhiza-go` using `go install`:

```bash
go install github.com/jebel-quant/rhiza-go/cmd/rhiza-go@latest
```

This installs the binary to `$GOPATH/bin` (typically `~/go/bin`). Make sure this directory is in your PATH.

To install a specific version:

```bash
go install github.com/jebel-quant/rhiza-go/cmd/rhiza-go@v0.1.0
```

## Manual Download

You can manually download pre-built binaries from the [GitHub Releases](https://github.com/Jebel-Quant/rhiza-go/releases) page.

1. Visit the [releases page](https://github.com/Jebel-Quant/rhiza-go/releases/latest)
2. Download the appropriate archive for your OS and architecture:
   - Linux: `rhiza-go_VERSION_linux_ARCH.tar.gz`
   - macOS: `rhiza-go_VERSION_darwin_ARCH.tar.gz`
   - Windows: `rhiza-go_VERSION_windows_ARCH.zip`
3. Extract the archive
4. Move the `rhiza-go` binary to a directory in your PATH

### Verifying Downloads

Each release includes a `checksums.txt` file. To verify your download:

```bash
# Download the checksums file
curl -LO https://github.com/Jebel-Quant/rhiza-go/releases/download/VERSION/checksums.txt

# Verify the downloaded archive (Linux)
sha256sum -c --ignore-missing checksums.txt

# Verify the downloaded archive (macOS)
shasum -a 256 -c --ignore-missing checksums.txt
```

## Building from Source

### Prerequisites

- **Go 1.23+** (check the `.go-version` file for the exact version)
- **Git**
- **Make**

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/Jebel-Quant/rhiza-go.git
   cd rhiza-go
   ```

2. Install dependencies:
   ```bash
   make install
   ```

3. Build the binary:
   ```bash
   go build -o rhiza-go ./cmd/rhiza-go
   ```

4. (Optional) Install to your PATH:
   ```bash
   sudo mv rhiza-go /usr/local/bin/
   ```

### Development Build

For development, you can use:

```bash
make install  # Install dependencies
make test     # Run tests
make fmt      # Format code
make lint     # Run linters
```

## Docker

You can also run `rhiza-go` using Docker:

```bash
docker run --rm ghcr.io/jebel-quant/rhiza-go:latest --version
```

For interactive use:

```bash
docker run --rm -it -v $(pwd):/workspace ghcr.io/jebel-quant/rhiza-go:latest
```

## Devcontainer

If you're using [Development Containers](https://containers.dev/), the devcontainer image is available:

```bash
docker pull ghcr.io/jebel-quant/rhiza-go/devcontainer:VERSION
```

Or open the repository in GitHub Codespaces or VS Code with the Dev Containers extension.

## Verifying Installation

After installation, verify that `rhiza-go` is available:

```bash
rhiza-go --version
```

You should see output showing the version information.

## Upgrading

### Using the Install Script

Re-run the install script to upgrade to the latest version:

```bash
curl -sSfL https://raw.githubusercontent.com/Jebel-Quant/rhiza-go/main/install.sh | sh
```

### Using Homebrew

```bash
brew update
brew upgrade rhiza-go
```

### Using Go Install

```bash
go install github.com/jebel-quant/rhiza-go/cmd/rhiza-go@latest
```

## Uninstalling

### Manual Installation

Simply remove the binary:

```bash
sudo rm /usr/local/bin/rhiza-go
```

### Homebrew

```bash
brew uninstall rhiza-go
brew untap Jebel-Quant/tap
```

### Go Install

Remove the binary from your `$GOPATH/bin`:

```bash
rm $(go env GOPATH)/bin/rhiza-go
```

## Troubleshooting

### Permission Denied

If you encounter permission errors when running the install script, ensure the installation directory is writable or use `sudo`:

```bash
curl -sSfL https://raw.githubusercontent.com/Jebel-Quant/rhiza-go/main/install.sh | sudo sh
```

### Binary Not Found

Ensure the installation directory is in your PATH. Add it to your shell configuration:

```bash
# For bash (~/.bashrc) or zsh (~/.zshrc)
export PATH="$PATH:/usr/local/bin"
```

### Checksum Verification Failed

If checksum verification fails, the download may be corrupted. Try downloading again or use a different mirror.

## Support

For issues, questions, or contributions:

- **Issues**: [GitHub Issues](https://github.com/Jebel-Quant/rhiza-go/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Jebel-Quant/rhiza-go/discussions)
- **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md)
