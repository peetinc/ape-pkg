# munki-pkg vs apepkg: Feature Comparison

## Overview

| Aspect | munki-pkg | apepkg |
|--------|-----------|----------|
| **Platform** | macOS | Linux |
| **Purpose** | Build macOS packages on macOS | Build macOS packages on Linux |
| **Project Compatibility** | munki-pkg only | Compatible with munki-pkg projects |
| **Primary Use Case** | Local development on Mac | CI/CD pipelines, Linux development |

## Core Functionality

| Feature | munki-pkg | apepkg | Notes |
|---------|-----------|----------|-------|
| Create new projects | ✅ Yes | ✅ Yes | Identical structure |
| Build component packages | ✅ Yes | ✅ Yes | |
| Build distribution packages | ✅ Yes | ✅ Yes | Default in apepkg |
| Custom install locations | ✅ Yes | ✅ Yes | |
| Pre/post install scripts | ✅ Yes | ✅ Yes | |
| Postinstall actions | ✅ Yes | ✅ Yes | none/logout/restart |
| Payload-free packages | ✅ Yes | ✅ Yes | |
| Version variable substitution | ✅ Yes | ✅ Yes | `${version}` in package name |

## Build Info Formats

| Format | munki-pkg | apepkg | Notes |
|--------|-----------|----------|-------|
| XML plist | ✅ Yes | ✅ Yes | Default format |
| JSON | ✅ Yes | ✅ Yes | Requires `--json` flag |
| YAML | ✅ Yes (with PyYAML) | ✅ Yes (with PyYAML) | Requires `--yaml` flag |

## Build Info Keys Support

| Key | munki-pkg | apepkg | Notes |
|-----|-----------|----------|-------|
| `identifier` | ✅ | ✅ | Package identifier |
| `name` | ✅ | ✅ | Package filename |
| `version` | ✅ | ✅ | Version string |
| `install_location` | ✅ | ✅ | Install path |
| `ownership` | ✅ | ✅ | recommended/preserve/preserve-other |
| `postinstall_action` | ✅ | ✅ | none/logout/restart |
| `distribution_style` | ✅ | ✅ | Always true in apepkg |
| `suppress_bundle_relocation` | ✅ | ❌ | macOS-specific |
| `preserve_xattr` | ✅ | ❌ | macOS-specific |
| `compression` | ✅ | ❌ | macOS 12+ feature |
| `min-os-version` | ✅ | ❌ | Could be added |
| `large-payload` | ✅ | ❌ | macOS 12+ feature |
| `signing_info` | ✅ | ❌ | Requires macOS tools |
| `notarization_info` | ✅ | ❌ | Requires macOS tools |
| `product id` | ✅ | ❌ | Distribution packages |

## Advanced Features

| Feature | munki-pkg | apepkg | Notes |
|---------|-----------|----------|-------|
| Import existing packages | ✅ Yes | ❌ No | May be added in future |
| Export BOM info | ✅ Yes | ✅ Yes | For git tracking |
| Sync from BOM | ✅ Yes | ✅ Yes | Restore permissions |
| Package signing | ✅ Yes | ❌ No | Requires Apple certificates |
| Notarization | ✅ Yes | ❌ No | Requires Apple Developer account |
| Custom requirements plist | ✅ Yes | ❌ No | Could be added |
| Bundle relocation control | ✅ Yes | ❌ No | macOS-specific |
| Extended attributes | ✅ Yes | ❌ No | macOS-specific |

## Command-Line Options

| Option | munki-pkg | apepkg | Notes |
|--------|-----------|----------|-------|
| `--create` | ✅ | ✅ | Create new project |
| `--import PKG` | ✅ | ❌ | Import existing package |
| `--json` | ✅ | ✅ | Use JSON build-info |
| `--yaml` | ✅ | ✅ | Use YAML build-info |
| `--export-bom-info` | ✅ | ✅ | Export BOM to text |
| `--sync` | ✅ | ✅ | Sync from BOM.txt |
| `--quiet` | ✅ | ✅ | Suppress output |
| `--force` | ✅ | ✅ | Force overwrite |
| `--skip-signing` | ✅ | N/A | Not applicable |
| `--skip-notarization` | ✅ | N/A | Not applicable |
| `--skip-stapling` | ✅ | N/A | Not applicable |

## Underlying Tools

| Component | munki-pkg | apepkg | Notes |
|-----------|-----------|----------|-------|
| BOM creation | pkgbuild | mkbom (bomutils) | |
| BOM reading | lsbom | lsbom (bomutils) | |
| Package building | pkgbuild | cpio + gzip | |
| Distribution building | productbuild | xar | |
| Archive format | pkgbuild | xar | |
| Signing | productsign | - | Not supported |

## Dependencies

### munki-pkg Requirements:
- macOS operating system
- Python 3
- Built-in Apple tools (pkgbuild, productbuild, etc.)
- Optional: PyYAML for YAML support

### apepkg Requirements:
- Linux operating system
- Python 3
- bomutils (mkbom, lsbom)
- xar
- cpio, gzip (usually pre-installed)
- Optional: PyYAML for YAML support

## Use Cases

### When to use munki-pkg:
✅ Building packages on macOS
✅ Need to sign packages
✅ Need to notarize packages
✅ Want to import existing packages
✅ Working with extended attributes
✅ Local development on Mac

### When to use apepkg:
✅ Building packages in Linux CI/CD pipelines
✅ Don't have access to macOS
✅ Building unsigned packages for internal distribution
✅ Using GitHub Actions, GitLab CI, or other Linux-based CI
✅ Cross-platform development teams
✅ Container-based builds

### When you can use either:
- Creating new packages from scratch
- Building simple installer packages
- Version-controlled package projects
- Git-based workflows with BOM export/sync
- Distribution-style packages
- Packages with scripts
- Building from same project structure

## Migration Path

### From munki-pkg to apepkg:
1. Copy your existing munki-pkg project directory to Linux
2. Run `./apepkg --sync ProjectName` to restore permissions
3. Build with `./apepkg ProjectName`

**Note**: Features like signing_info and notarization_info in build-info will be ignored.

### From apepkg to munki-pkg:
1. Copy your apepkg project directory to macOS
2. Run `munkipkg --sync ProjectName` to restore permissions
3. Build with `munkipkg ProjectName`

**Note**: You can add signing_info and notarization_info to build-info if desired.

## Workflow Recommendations

### Hybrid Workflow (Best of Both):

**Development**: Use whichever platform you prefer
```bash
# On macOS
munkipkg MyProject

# On Linux
./apepkg MyProject
```

**Version Control**: Use BOM export/sync
```bash
# Before committing
munkipkg --export-bom-info MyProject  # or apepkg
git add MyProject/Bom.txt
git commit

# After cloning
munkipkg --sync MyProject  # or apepkg
```

**CI/CD**: Use apepkg on Linux runners
```yaml
# GitHub Actions
runs-on: ubuntu-latest
steps:
  - name: Build package
    run: ./apepkg MyProject
```

**Distribution**:
- Unsigned packages: Use apepkg output directly
- Signed/notarized packages: Build with apepkg, then sign on macOS:
  ```bash
  # Sign on macOS after building on Linux
  productsign --sign "Developer ID Installer" \
    MyProject.pkg MyProject-signed.pkg
  ```

## Output Package Compatibility

Both tools produce standard macOS installer packages (.pkg files) that:
- ✅ Work identically when installed on macOS
- ✅ Have the same internal structure
- ✅ Are recognized by macOS Installer.app
- ✅ Can be deployed via MDM
- ✅ Are compatible with Munki, Jamf, and other management tools

The only difference is that apepkg packages are unsigned by default.

## Project Structure Compatibility

Both tools use identical project structures:

```
MyProject/
├── build-info.{plist,json,yaml}  # ✅ Compatible
├── payload/                       # ✅ Compatible
│   └── [files to install]        # ✅ Compatible
├── scripts/                       # ✅ Compatible
│   ├── preinstall                # ✅ Compatible
│   └── postinstall               # ✅ Compatible
├── build/                         # ✅ Compatible
└── Bom.txt                        # ✅ Compatible
```

## Summary

**apepkg** is designed to be a Linux-compatible alternative to munki-pkg for building macOS packages. While it doesn't support signing or notarization (which require macOS), it handles the core package building functionality and maintains full compatibility with munki-pkg project structures.

Use apepkg when you need to build macOS packages on Linux (especially in CI/CD), and use munki-pkg when you need the full feature set including signing and notarization on macOS.

The two tools can be used interchangeably for the same projects, making it easy to support both platforms in your workflow.
