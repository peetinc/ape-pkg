# munki-pkg vs apepkg: Feature Comparison

## Overview

| Aspect | munki-pkg | apepkg |
|--------|-----------|----------|
| **Platform** | macOS | Linux / macOS |
| **Purpose** | Build macOS packages on macOS | Build macOS packages on Linux |
| **Project Compatibility** | munki-pkg only | Compatible with munki-pkg projects |
| **Primary Use Case** | Local development on Mac | CI/CD pipelines, Linux development |
| **Signing & Notarization** | Native Apple tools | rcodesign (cross-platform) |

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
| `suppress_bundle_relocation` | ✅ | ✅ | Prevents bundle relocation |
| `preserve_xattr` | ✅ | ✅ | Preserve extended attributes |
| `compression` | ✅ | ✅ | legacy (gzip) or latest (xz) |
| `min-os-version` | ✅ | ✅ | Minimum macOS version |
| `large-payload` | ✅ | ✅ | For very large payloads |
| `signing_info` | ✅ | N/A | Use --sign option instead |
| `notarization_info` | ✅ | N/A | Use --notarize option instead |
| `product id` | ✅ | ✅ | Distribution packages |

## Advanced Features

| Feature | munki-pkg | apepkg | Notes |
|---------|-----------|----------|-------|
| Import existing packages | ✅ Flat & bundle | ✅ Flat only | Bundle packages not supported |
| Export BOM info | ✅ Yes | ✅ Yes | For git tracking |
| Sync from BOM | ✅ Yes | ✅ Yes | Restore permissions |
| Package signing | ✅ Yes | ✅ Yes | Via rcodesign on Linux |
| Notarization | ✅ Yes | ✅ Yes | Via rcodesign on Linux |
| Notarization stapling | ✅ Yes | ✅ Yes | Via rcodesign on Linux |
| Custom requirements plist | ✅ Yes | ❌ No | Could be added |
| Bundle relocation control | ✅ Yes | ✅ Yes | suppress_bundle_relocation |
| Extended attributes | ✅ Yes | ✅ Yes | preserve_xattr |

## Command-Line Options

| Option | munki-pkg | apepkg | Notes |
|--------|-----------|----------|-------|
| `--create` | ✅ | ✅ | Create new project |
| `--import PKG` | ✅ | ✅ | Import existing package (flat only) |
| `--json` | ✅ | ✅ | Use JSON build-info |
| `--yaml` | ✅ | ✅ | Use YAML build-info |
| `--export-bom-info` | ✅ | ✅ | Export BOM to text |
| `--sync` | ✅ | ✅ | Sync from BOM.txt |
| `--quiet` | ✅ | ✅ | Suppress output |
| `--force` | ✅ | ✅ | Force overwrite |
| `--sign` | N/A | ✅ | Sign package (rcodesign) |
| `--p12-file` | N/A | ✅ | Certificate file for signing |
| `--p12-password` / `--p12-password-env` | N/A | ✅ | Certificate password |
| `--notarize` | N/A | ✅ | Submit for notarization |
| `--api-issuer` / `--api-key` | N/A | ✅ | App Store Connect API credentials |
| `--notarize-wait` / `--notarize-no-wait` | N/A | ✅ | Wait for notarization completion |

## Underlying Tools

| Component | munki-pkg | apepkg | Notes |
|-----------|-----------|----------|-------|
| BOM creation | pkgbuild | mkbom (bomutils) | |
| BOM reading | lsbom | lsbom (bomutils) | |
| Payload compression | pkgbuild | cpio + gzip/xz | Configurable compression |
| Distribution building | productbuild | xar | |
| Archive format | xar | xar | |
| Signing | productsign | rcodesign | Cross-platform signing |
| Notarization | notarytool | rcodesign | Cross-platform notarization |

## Dependencies

### munki-pkg Requirements:
- macOS operating system
- Python 3
- Built-in Apple tools (pkgbuild, productbuild, etc.)
- Optional: PyYAML for YAML support

### apepkg Requirements:
- Linux or macOS operating system
- Python 3
- bomutils (mkbom, lsbom)
- xar
- cpio, gzip, xz (usually pre-installed)
- Optional: PyYAML for YAML support
- Optional: rcodesign for signing and notarization

## Use Cases

### When to use munki-pkg:
✅ Building packages on macOS
✅ Prefer native Apple tools (pkgbuild/productbuild)
✅ Need to import bundle-style packages
✅ Local development on Mac

### When to use apepkg:
✅ Building packages in Linux CI/CD pipelines
✅ Don't have access to macOS for building
✅ Need to sign/notarize on Linux (CI/CD)
✅ Using GitHub Actions, GitLab CI, or other Linux-based CI
✅ Cross-platform development teams
✅ Container-based builds
✅ Want to build and sign packages entirely on Linux

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
- Signed/notarized packages: Use apepkg with rcodesign:
  ```bash
  # Build, sign, and notarize entirely on Linux
  ./apepkg MyProject \
    --sign --p12-file cert.p12 --p12-password-env CERT_PASSWORD \
    --notarize --api-issuer TEAM_ID --api-key API_KEY_ID
  ```

## Output Package Compatibility

Both tools produce standard macOS installer packages (.pkg files) that:
- ✅ Work identically when installed on macOS
- ✅ Have the same internal structure
- ✅ Are recognized by macOS Installer.app
- ✅ Can be deployed via MDM
- ✅ Are compatible with Munki, Jamf, and other management tools
- ✅ Can be signed and notarized (apepkg uses rcodesign)

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

**apepkg** is designed to be a Linux-compatible alternative to munki-pkg for building macOS packages. It now supports the full feature set including:
- ✅ All build-info keys (compression, min-os-version, large-payload, etc.)
- ✅ Package signing via rcodesign (cross-platform)
- ✅ Package notarization via rcodesign (cross-platform)
- ✅ Package importing (flat packages)
- ✅ Full munki-pkg project compatibility

Use apepkg when you need to build macOS packages on Linux (especially in CI/CD), or when you want a cross-platform solution. Use munki-pkg when you prefer native Apple tools or need to import bundle-style packages.

The two tools can be used interchangeably for the same projects, making it easy to support both platforms in your workflow.
