# HelloWorld Example Package

This is a simple example package that demonstrates how to use apepkg.

## What it does

This package installs a simple "hello" script at `/usr/local/bin/hello` that prints a greeting message.

## Project Structure

```
HelloWorld/
├── build-info.plist      # Package metadata
├── payload/              # Files to install
│   └── usr/
│       └── local/
│           └── bin/
│               └── hello # The script to install
└── scripts/              # Installation scripts
    └── postinstall       # Runs after installation
```

## Building on Linux

1. Make sure you have apepkg dependencies installed:
   ```bash
   ../../INSTALL.sh
   ```

2. Build the package:
   ```bash
   ../../apepkg .
   ```

3. The package will be created at:
   ```
   build/HelloWorld-1.0.pkg
   ```

## Building on macOS

This project is also compatible with munki-pkg:

```bash
munkipkg .
```

## Testing on macOS

After building, install the package on macOS:

```bash
sudo installer -pkg build/HelloWorld-1.0.pkg -target /
```

Then test it:

```bash
hello
```

You should see:
```
Hello, World!
This script was installed by a package built with apepkg
Package: com.example.helloworld
```

## Package Details

- **Identifier**: com.example.helloworld
- **Version**: 1.0
- **Install Location**: /
- **Type**: Distribution-style package
- **Postinstall Action**: none
