# apepkg Quick Start Guide

This guide will help you get started building macOS packages on Linux.

## 1. Install Dependencies

Run the installation script:

```bash
./INSTALL-LINUX.sh
```

This will install:
- Build tools (gcc, make, etc.)
- bomutils (for creating Bill of Materials)
- xar (for creating package archives)

**Verify installation:**
```bash
which mkbom lsbom xar
```

You should see paths to all three tools.

## 2. Create Your First Package

### Create a new project:

```bash
./apepkg --create MyFirstPackage
```

This creates:
```
MyFirstPackage/
├── build-info.plist
├── payload/
├── scripts/
└── build/
```

### Add files to install:

Let's install a simple script at `/usr/local/bin/myscript`:

```bash
# Create the directory structure
mkdir -p MyFirstPackage/payload/usr/local/bin

# Create the script
cat > MyFirstPackage/payload/usr/local/bin/myscript << 'EOF'
#!/bin/bash
echo "Hello from my first package!"
EOF

# Make it executable
chmod +x MyFirstPackage/payload/usr/local/bin/myscript
```

### Edit package metadata:

Edit `MyFirstPackage/build-info.plist` to customize:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>identifier</key>
    <string>com.mycompany.myfirstpackage</string>
    <key>name</key>
    <string>MyFirstPackage-${version}.pkg</string>
    <key>version</key>
    <string>1.0</string>
    <key>install_location</key>
    <string>/</string>
    <key>postinstall_action</key>
    <string>none</string>
</dict>
</plist>
```

### Build the package:

```bash
./apepkg MyFirstPackage
```

The package will be created at:
```
MyFirstPackage/build/MyFirstPackage-1.0.pkg
```

## 3. Add Installation Scripts (Optional)

### Create a postinstall script:

```bash
cat > MyFirstPackage/scripts/postinstall << 'EOF'
#!/bin/bash

echo "Package installed successfully!"
echo "You can now run: myscript"

exit 0
EOF

chmod +x MyFirstPackage/scripts/postinstall
```

### Rebuild:

```bash
./apepkg MyFirstPackage
```

## 4. Test on macOS

Transfer the package to a macOS system and install:

```bash
sudo installer -pkg MyFirstPackage-1.0.pkg -target /
```

Test your script:
```bash
myscript
```

## 5. Version Control with Git

### Export BOM info for git:

```bash
./apepkg --export-bom-info MyFirstPackage
```

This creates `MyFirstPackage/Bom.txt` with file permissions and ownership info.

### Initialize git repository:

```bash
cd MyFirstPackage
git init
git add .
git commit -m "Initial package"
```

### After cloning:

When someone clones your repository, they should run:

```bash
./apepkg --sync MyFirstPackage
```

This restores file permissions and creates empty directories from the Bom.txt file.

## 6. Use in CI/CD

### GitHub Actions Example:

Create `.github/workflows/build.yml`:

```yaml
name: Build Package

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Install apepkg dependencies
      run: ./INSTALL-LINUX.sh

    - name: Build package
      run: ./apepkg MyFirstPackage

    - name: Upload package
      uses: actions/upload-artifact@v2
      with:
        name: package
        path: MyFirstPackage/build/*.pkg
```

## Common Package Types

### LaunchDaemon Package

```bash
./apepkg --create MyService

# Add LaunchDaemon plist
mkdir -p MyService/payload/Library/LaunchDaemons
cat > MyService/payload/Library/LaunchDaemons/com.example.myservice.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.myservice</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/myservice</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# Add service binary
mkdir -p MyService/payload/usr/local/bin
cp /path/to/myservice MyService/payload/usr/local/bin/

# Add postinstall to load service
cat > MyService/scripts/postinstall << 'EOF'
#!/bin/bash
launchctl load /Library/LaunchDaemons/com.example.myservice.plist
exit 0
EOF

chmod +x MyService/scripts/postinstall

# Build
./apepkg MyService
```

### Configuration Package

```bash
./apepkg --create --json MyConfig

# Edit build-info.json
cat > MyConfig/build-info.json << 'EOF'
{
    "identifier": "com.example.config",
    "version": "1.0",
    "name": "MyConfig-${version}.pkg",
    "install_location": "/",
    "postinstall_action": "logout"
}
EOF

# Add configuration files
mkdir -p MyConfig/payload/Library/Preferences
cp config.plist MyConfig/payload/Library/Preferences/

# Build
./apepkg MyConfig
```

## Next Steps

- Read the full documentation in `APEPKG-README.md`
- Check out the example package in `examples/HelloWorld/`
- Learn about BOM export/sync for git workflows
- Integrate into your CI/CD pipeline

## Troubleshooting

**Problem**: `ERROR: Missing required packages: bomutils xar`

**Solution**: Run `./INSTALL-LINUX.sh` to install dependencies

---

**Problem**: Package builds but scripts don't execute

**Solution**: Make sure scripts are executable:
```bash
chmod +x scripts/preinstall scripts/postinstall
```

---

**Problem**: Files have wrong permissions after installation

**Solution**: Use `--export-bom-info` when building and `--sync` after cloning

---

**Problem**: `xar: command not found`

**Solution**: Add `/usr/local/bin` to your PATH or run `sudo ldconfig`

## Getting Help

- Check the full README: `APEPKG-README.md`
- Review munki-pkg documentation (mostly compatible): https://github.com/munki/munki-pkg
- File an issue on GitHub

Happy packaging! 🎉
