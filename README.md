# apepkg - Apple Package Engineer

**Build macOS packages on Linux**

`apepkg` is a tool for building macOS installer packages (.pkg files) on Linux systems, compatible with [munki-pkg](https://github.com/munki/munki-pkg) project directories.

## What does APE stand for?

**APE** = **A**pple **P**ackage **E**ngineer

Just like how munki-pkg helps you build packages on macOS, apepkg engineers your Apple packages on Linux!

## Quick Start

### 1. Install Dependencies (Linux)

```bash
./INSTALL.sh
```

### 2. Create a Package Project

```bash
./apepkg --create MyPackage
```

### 3. Add Your Files

```bash
# Add files to install
mkdir -p MyPackage/payload/usr/local/bin
cp myapp MyPackage/payload/usr/local/bin/

# Add installation scripts (optional)
cat > MyPackage/scripts/postinstall << 'EOF'
#!/bin/bash
echo "Installation complete!"
exit 0
EOF
chmod +x MyPackage/scripts/postinstall
```

### 4. Build the Package

```bash
./apepkg MyPackage
```

Your package is now at `MyPackage/build/MyPackage-1.0.pkg`!

## Why apepkg?

✅ **Linux-based CI/CD** - Build macOS packages in GitHub Actions, GitLab CI, etc.
✅ **munki-pkg compatible** - Use the same project structure
✅ **Open source tools** - Uses bomutils and xar instead of proprietary Apple tools
✅ **Git-friendly** - Export/sync BOM for version control
✅ **Distribution packages** - Ready for deployment via MDM, Munki, Jamf, etc.

## Features

- Build standard macOS installer packages (.pkg files)
- Distribution-style packages
- Pre/post installation scripts
- Custom install locations
- Payload and payload-free packages
- BOM export/sync for git workflows
- Supports plist, JSON, and YAML build-info formats

## Not Supported

❌ Package signing (requires macOS and Apple certificates)
❌ Notarization (requires Apple Developer account)
❌ Package importing (may be added later)

**Note**: You can build unsigned packages with apepkg and sign them later on macOS if needed.

## Documentation

- **[Full Documentation](APEPKG-README.md)** - Complete guide with all features
- **[Quick Start Guide](QUICKSTART.md)** - Step-by-step tutorial
- **[Comparison Table](COMPARISON.md)** - munki-pkg vs apepkg feature comparison
- **[Example Project](examples/HelloWorld/)** - Working example to learn from

## Example Project Structure

```
MyPackage/
├── build-info.plist      # Package metadata (or .json/.yaml)
├── payload/              # Files to install
│   └── usr/
│       └── local/
│           └── bin/
│               └── myapp
├── scripts/              # Installation scripts (optional)
│   ├── preinstall
│   └── postinstall
└── build/               # Output directory (auto-created)
    └── MyPackage-1.0.pkg
```

## CI/CD Example

### GitHub Actions

```yaml
name: Build Package
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install apepkg dependencies
        run: ./INSTALL.sh
      - name: Build package
        run: ./apepkg MyPackage
      - name: Upload artifact
        uses: actions/upload-artifact@v2
        with:
          name: package
          path: MyPackage/build/*.pkg
```

## Requirements

### Linux System:
- Python 3
- bomutils (mkbom/lsbom)
- xar
- cpio, gzip (usually pre-installed)

Install with:
```bash
./INSTALL.sh
```

Supported distributions:
- Debian/Ubuntu
- Red Hat/Fedora/CentOS
- Other Linux distributions (manual install)

## Command-Line Options

```bash
apepkg [options] pkg_project_directory

Options:
  --create              Create new empty project
  --json                Use JSON format for build-info
  --yaml                Use YAML format for build-info
  --export-bom-info     Export BOM to Bom.txt
  --sync                Sync permissions from Bom.txt
  --quiet               Suppress status messages
  -f, --force           Force creation if directory exists
```

## Hybrid Workflow (Linux + macOS)

You can use both apepkg and munki-pkg with the same project:

```bash
# On Linux
./apepkg MyPackage

# On macOS
munkipkg MyPackage
```

Both produce identical packages (except apepkg packages are unsigned).

## License

Licensed under the Apache License, Version 2.0

## Credits

- Compatible with [munki-pkg](https://github.com/munki/munki-pkg) by Greg Neagle
- Uses [bomutils](https://github.com/hogliux/bomutils) by Joseph Coffland
- Uses [xar](https://github.com/mackyle/xar)
- Inspired by [GytPol's blog post](https://gytpol.com/blog/automating-mac-software-package-process-on-a-linux-based-os)

## Contributing

Issues and pull requests welcome!

---

**Happy packaging with APE!** 🦍📦
