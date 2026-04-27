# AGENTS.md - img-installer

Quick context: This repo creates Debian Live-based ISO installers for embedding system images (OpenWrt, Armbian, HAOS, etc.) on x86-64 devices. It's a shell script / build system, not a traditional code project.

## Build Commands

```bash
# Local Armbian build (requires Docker)
./build.sh

# Local custom firmware build (requires Docker, accepts .img.gz/.img.xz/.img.zip URL)
./custom.sh "https://example.com/firmware.img.xz"

# Other distro builds
./haos.sh          # HomeAssistant OS
./imm.sh          # ImmortalWrt
./esir.sh         # eSirOpenWrt
./ezopwrt.sh      # EzOpWrt
./istoreos.sh     # iStoreOS
```

## Architecture

- **Build base**: `debian:buster` Docker image (uses archive.debian.org repos - oldstable)

- **Build flow**: debootstrap → inject ddd script → squashfs-tools compress → xorriso package as hybrid ISO

- **Output**: `output/*.iso` - supports both BIOS and UEFI boot

- **Installer**: Runs `ddd` command in live system to show interactive disk write menu

## Important Constraints

- **Docker required** - the main build.sh runs inside debian:buster container
- **Buster archive repos** - supportFiles/build.sh patches sources.list to archive.debian.org (buster is EOL)
- **CI/CD**: GitHub Actions workflows in .github/workflows/ trigger on workflow_dispatch
- **Custom builds**: build-custom.yml accepts .img.gz/.img.xz/.img.zip URLs only
- **No tests** - this is a build system with no test suite

## Script Locations

| Purpose | Path |
|--------|------|
| Main Armbian builder | `build.sh` |
| Per-distro configs | `supportFiles/<distro>/` (ddd, build.sh, grub.cfg, isolinux.cfg) |
| Install menu script | `supportFiles/ddd` (Armbian default) |
| Auto-build hook | `autobuild/autobuild.sh` |

## What Agents Commonly Miss

- This is NOT a code project - don't search for "functions", "classes", "tests"
- The "code" is shell scripts in supportFiles/ directory
- Build happens inside Docker, local scripts only orchestrate the process
- No npm/pip/other package management - just system apt packages in the container

## Related Projects

- https://github.com/dpowers86/debian-live (base this builds from)
- https://github.com/wukongdaily/armbian-installer (reference armbian images)