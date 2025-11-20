# apepkg

## Introduction

**apepkg** is a tool for building macOS installer packages (.pkg files) on Linux systems. It is designed to be compatible with [munki-pkg](https://github.com/munki/munki-pkg) project directories, allowing you to create the same packages that munki-pkg creates, but without requiring macOS.

While munki-pkg uses Apple's `pkgbuild` and `productbuild` tools (which only run on macOS), apepkg uses open-source alternatives:
- **bomutils** (mkbom/lsbom) for creating Bill of Materials files
- **xar** for creating the package archive
- **cpio** and **gzip** for payload compression

This allows you to build macOS packages in CI/CD pipelines running on Linux, or on Linux development machines.

## Compatibility

apepkg is designed to be compatible with munki-pkg project directories. You can:
- Use the same project directory structure
- Use the same build-info files (plist, JSON, or YAML)
- Switch between munki-pkg (on macOS) and apepkg (on Linux) for the same project

**Supported features:**
- ✅ Component packages
- ✅ Distribution-style packages
- ✅ Scripts (preinstall/postinstall)
- ✅ Custom install locations
- ✅ Postinstall actions (none/logout/restart)
- ✅ BOM export and sync
- ✅ Payload and payload-free packages
- ✅ Package importing (flat packages)

**Not supported (compared to munki-pkg):**
- ❌ Bundle-style package importing (only flat packages supported)

## Linux Prerequisites

### Debian/Ubuntu:
```bash
sudo apt-get update
sudo apt-get install build-essential libssl-dev libz-dev

# Install bomutils
git clone https://github.com/hogliux/bomutils.git
cd bomutils
make
sudo make install
cd ..

# Install xar
git clone https://github.com/mackyle/xar.git
cd xar/xar
./autogen.sh
./configure
make
sudo make install
cd ../..
```

### Red Hat/Fedora/CentOS:
```bash
sudo dnf install gcc make openssl-devel zlib-devel autoconf automake libtool

# Install bomutils
git clone https://github.com/hogliux/bomutils.git
cd bomutils
make
sudo make install
cd ..

# Install xar
git clone https://github.com/mackyle/xar.git
cd xar/xar
./autogen.sh
./configure
make
sudo make install
cd ../..
```

### Python Dependencies:
```bash
# For YAML support (optional)
pip install PyYAML
```

## Basic Usage

### Creating a new project

```bash
./apepkg --create MyPackage
```

This creates a new project directory structure:
```
MyPackage/
├── build-info.plist
├── payload/
├── scripts/
├── build/
└── .gitignore
```

### Building a package

```bash
./apepkg path/to/MyPackage
```

The built package will be created in `MyPackage/build/MyPackage-1.0.pkg`

### Project Directory Structure

A apepkg project directory contains:

```
MyPackage/
├── build-info.plist     # Package metadata and build settings
├── payload/             # Files to be installed
│   ├── usr/
│   │   └── local/
│   │       └── bin/
│   │           └── myapp
│   └── Library/
│       └── LaunchDaemons/
│           └── com.example.plist
├── scripts/             # Installation scripts
│   ├── preinstall
│   └── postinstall
└── build/              # Output directory (created automatically)
```

### Build-info File

The build-info file can be in plist (default), JSON, or YAML format.

#### build-info.plist (default):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>distribution_style</key>
    <true/>
    <key>identifier</key>
    <string>com.example.mypackage</string>
    <key>install_location</key>
    <string>/</string>
    <key>name</key>
    <string>MyPackage-${version}.pkg</string>
    <key>ownership</key>
    <string>recommended</string>
    <key>postinstall_action</key>
    <string>none</string>
    <key>suppress_bundle_relocation</key>
    <true/>
    <key>preserve_xattr</key>
    <false/>
    <key>compression</key>
    <string>legacy</string>
    <key>version</key>
    <string>1.0</string>
</dict>
</plist>
```

#### build-info.json:
```json
{
    "distribution_style": true,
    "identifier": "com.example.mypackage",
    "install_location": "/",
    "name": "MyPackage-${version}.pkg",
    "ownership": "recommended",
    "postinstall_action": "none",
    "suppress_bundle_relocation": true,
    "preserve_xattr": false,
    "compression": "legacy",
    "version": "1.0"
}
```

#### build-info.yaml:
```yaml
distribution_style: true
identifier: com.example.mypackage
install_location: /
name: MyPackage-${version}.pkg
ownership: recommended
postinstall_action: none
suppress_bundle_relocation: true
preserve_xattr: false
compression: legacy
version: '1.0'
```

### Build-info Keys

**identifier** (required)
String. The package identifier (e.g., "com.example.mypackage").

**name** (required)
String. The package filename. Use `${version}` to include the version number.

**version** (required)
String. Package version number.

**install_location**
String. Where the payload will be installed. Default: "/"

**ownership**
String. One of "recommended", "preserve", or "preserve-other". Default: "recommended"

**postinstall_action**
String. One of "none", "logout", or "restart". Default: "none"

**suppress_bundle_relocation**
Boolean. When true, prevents bundle relocation during installation. Default: true

**preserve_xattr**
Boolean. Preserve extended file attributes in installed files. Default: false

**compression**
String. Payload compression format. Options: "legacy" (gzip) or "latest" (xz). Default: "legacy"

**min-os-version**
String. Minimum macOS version required (e.g., "10.13", "11.0"). Optional.

**large-payload**
Boolean. Set to true for packages with very large payloads. Default: false

**distribution_style**
Boolean. Whether to build a distribution-style package. Default: true

## Installation Scripts

Place executable scripts in the `scripts/` directory:

### scripts/preinstall
Runs before installation:
```bash
#!/bin/bash
# Stop service before installing
launchctl unload /Library/LaunchDaemons/com.example.plist 2>/dev/null
exit 0
```

### scripts/postinstall
Runs after installation:
```bash
#!/bin/bash
# Start service after installing
launchctl load /Library/LaunchDaemons/com.example.plist
exit 0
```

**Important:** Scripts must be executable. apepkg will automatically make them executable during build.

## Payload Directory

The `payload/` directory contains the files to be installed. The directory structure in `payload/` mirrors the target system structure.

Example: To install a file at `/usr/local/bin/myapp`, create:
```
payload/
└── usr/
    └── local/
        └── bin/
            └── myapp
```

## Advanced Features

### Exporting BOM Info

Git doesn't track file permissions or empty directories. Use `--export-bom-info` to export this metadata:

```bash
./apepkg --export-bom-info MyPackage
```

This creates `Bom.txt` in your project directory, which you can commit to git.

### Syncing from BOM Info

After cloning a repository, restore permissions and empty directories:

```bash
./apepkg --sync MyPackage
```

### Recommended Git Workflow

1. Build with BOM export:
   ```bash
   ./apepkg --export-bom-info MyPackage
   ```

2. Commit Bom.txt:
   ```bash
   git add MyPackage/Bom.txt
   git commit -m "Update package with permission info"
   ```

3. After cloning or pulling:
   ```bash
   ./apepkg --sync MyPackage
   ```

### Payload-free Packages

You can create packages that only run scripts without installing files:

1. **No payload directory**: Creates a package that leaves no receipt
2. **Empty payload directory**: Creates a package that leaves a receipt but installs no files

## Importing Packages

apepkg can import existing flat packages and convert them into editable project directories. This is useful for:
- Reverse engineering packages
- Modifying existing packages
- Converting packages from other tools to apepkg projects

### Importing a Package

```bash
./apepkg --import /path/to/existing.pkg NewProject
```

This will:
1. Extract the package (xar archive)
2. Parse the Distribution and PackageInfo files
3. Extract payload files to `payload/`
4. Extract installation scripts to `scripts/`
5. Export BOM to `Bom.txt`
6. Create `build-info.plist` with extracted metadata

### Example

```bash
# Import a package
./apepkg --import ~/Downloads/MyApp-1.5.pkg MyAppProject

# Modify the project
# (edit files in payload/, modify scripts/, change build-info.plist)

# Rebuild the package
./apepkg MyAppProject

# Result: MyAppProject/build/MyAppProject-1.5.pkg
```

### What Gets Imported

The import process preserves:
- **Identifier**: Package identifier (e.g., com.example.myapp)
- **Version**: Package version number
- **Install location**: Where files will be installed
- **Postinstall action**: none/logout/restart
- **Payload files**: All installed files with correct permissions
- **Scripts**: preinstall and postinstall scripts
- **BOM**: Bill of Materials exported to Bom.txt
- **Bundle metadata**: .app bundle information
- **Advanced settings**: min-os-version, large-payload, preserve_xattr, etc.

### Limitations

- Only flat packages (xar archives) are supported
- Bundle-style packages (directory format) are not supported
- The package name in build-info will be based on the project directory name, not the original package name

### Using --force

If the project directory already exists, use `--force` to overwrite:

```bash
./apepkg --import existing.pkg MyProject --force
```

## Command-Line Options

**--create**
Create a new empty project directory with default settings.

**--import PKG**
Import an existing flat package and create a project directory from it.

**--json**
Create build-info file in JSON format (use with --create).

**--yaml**
Create build-info file in YAML format (use with --create).

**--export-bom-info**
Export Bill of Materials to Bom.txt after building.

**--sync**
Sync file permissions and create missing directories from Bom.txt.

**--quiet**
Suppress status messages.

**-f, --force**
Force creation of project directory if it already exists.

## Differences from munki-pkg

| Feature | munki-pkg | apepkg |
|---------|-----------|----------|
| Platform | macOS only | Linux/macOS |
| Build tool | pkgbuild/productbuild | bomutils/xar |
| Signing | Supported | Supported (via rcodesign) |
| Notarization | Supported | Supported (via rcodesign) |
| Import packages | Supported (flat & bundle) | Supported (flat only) |
| Bundle relocation | Configurable | Configurable |
| Extended attributes | Configurable | Configurable |
| Project compatibility | - | Compatible with munki-pkg |

## Examples

### Example 1: Simple Application Package

```bash
# Create project
./apepkg --create HelloWorld

# Add application to payload
mkdir -p HelloWorld/payload/Applications
cp -R /path/to/HelloWorld.app HelloWorld/payload/Applications/

# Edit build-info.plist to set identifier and version

# Build
./apepkg HelloWorld
```

### Example 2: LaunchDaemon Package

```bash
# Create project
./apepkg --create MyService

# Add LaunchDaemon plist
mkdir -p MyService/payload/Library/LaunchDaemons
cp com.example.myservice.plist MyService/payload/Library/LaunchDaemons/

# Add executable
mkdir -p MyService/payload/usr/local/bin
cp myservice MyService/payload/usr/local/bin/

# Create postinstall script
cat > MyService/scripts/postinstall << 'EOF'
#!/bin/bash
launchctl load /Library/LaunchDaemons/com.example.myservice.plist
exit 0
EOF

chmod +x MyService/scripts/postinstall

# Build with BOM export
./apepkg --export-bom-info MyService
```

### Example 3: Using JSON Build Info

```bash
# Create project with JSON format
./apepkg --create --json ConfigPackage

# Edit ConfigPackage/build-info.json
cat > ConfigPackage/build-info.json << 'EOF'
{
    "identifier": "com.example.config",
    "version": "2.1",
    "name": "Config-${version}.pkg",
    "install_location": "/",
    "postinstall_action": "logout",
    "distribution_style": true
}
EOF

# Add config files
mkdir -p ConfigPackage/payload/Library/Preferences
cp config.plist ConfigPackage/payload/Library/Preferences/

# Build
./apepkg ConfigPackage
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build macOS Package

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential libssl-dev libz-dev

        # Install bomutils
        git clone https://github.com/hogliux/bomutils.git
        cd bomutils && make && sudo make install && cd ..

        # Install xar
        git clone https://github.com/mackyle/xar.git
        cd xar/xar && ./autogen.sh && ./configure && make && sudo make install && cd ../..

    - name: Build package
      run: |
        ./apepkg MyPackage

    - name: Upload package
      uses: actions/upload-artifact@v2
      with:
        name: package
        path: MyPackage/build/*.pkg
```

### GitLab CI Example

```yaml
build-package:
  image: ubuntu:latest

  before_script:
    - apt-get update
    - apt-get install -y build-essential libssl-dev libz-dev git autoconf automake libtool
    - git clone https://github.com/hogliux/bomutils.git
    - cd bomutils && make && make install && cd ..
    - git clone https://github.com/mackyle/xar.git
    - cd xar/xar && ./autogen.sh && ./configure && make && make install && cd ../..

  script:
    - ./apepkg MyPackage

  artifacts:
    paths:
      - MyPackage/build/*.pkg
```

## Troubleshooting

### "ERROR: Missing required packages"
Install bomutils and xar as described in the Prerequisites section.

### "mkbom failed" or "xar failed"
Ensure bomutils and xar are properly installed and in your PATH:
```bash
which mkbom lsbom xar
```

### "Permission denied" on scripts
Make sure your preinstall/postinstall scripts are executable:
```bash
chmod +x scripts/preinstall scripts/postinstall
```

### Package installs but files have wrong permissions
Use `--export-bom-info` when building and commit the Bom.txt file. After cloning, run `--sync`.

## License

Licensed under the Apache License, Version 2.0. See LICENSE file for details.

## Credits

- Inspired by and compatible with [munki-pkg](https://github.com/munki/munki-pkg) by Greg Neagle
- Uses [bomutils](https://github.com/hogliux/bomutils) by Joseph Coffland
- Uses [xar](https://github.com/mackyle/xar)
- Build process based on research from [GytPol's blog post](https://gytpol.com/blog/automating-mac-software-package-process-on-a-linux-based-os)

## Contributing

Contributions are welcome! Please submit issues and pull requests on GitHub.
