#!/bin/bash
set -u -e

FLAVOURS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--branch)
            BRANCH="$2"
            shift
            shift
        ;;
        -r|--repo)
            REPO="$2"
            shift
            shift
        ;;
        -a|--builder-args)
            FB_ARGS="$2"
            shift
            shift
        ;;
        -e|--export-args)
            EXPORT_ARGS="$2"
            shift
            shift
        ;;
        -d|--build-dir)
            BUILD_DIR="$2"
            shift
            shift
        ;;
        *)
            FLAVOURS+=("$1")
            shift
        ;;
    esac
done

[ -v "BUILD_DIR" ] || BUILD_DIR="./build"

for flavour in "${FLAVOURS[@]}"; do
    for ARCH in x86_64 i386; do
        set -x
        flatpak-builder --force-clean --ccache --sandbox --delete-build-dirs \
            --arch=${ARCH} --repo="${REPO}" --default-branch="${BRANCH}" \
            ${FB_ARGS} ${EXPORT_ARGS} "${BUILD_DIR}/wine/$flavour/$ARCH" \
            "ua.org.brezblock.q4wine.wine.$flavour.yml"
        set +x
    done
    set -x
    flatpak build-commit-from --verbose ${EXPORT_ARGS} \
        --src-ref="runtime/ua.org.brezblock.q4wine.wine.$flavour/i386/${BRANCH}" "${REPO}" \
        "runtime/ua.org.brezblock.q4wine.wine.$flavour.compat32/x86_64/${BRANCH}"
    set +x
done
