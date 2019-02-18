#!/bin/bash

BRANCH=${1:-"stable"}
REPO=$2
EXPORT_ARGS=$3
FB_ARGS=$4

set -e -x
for flavour in vanilla staging proton; do
    for ARCH in x86_64 i386; do
        flatpak-builder -v --force-clean --ccache --sandbox --delete-build-dirs \
            --arch=${ARCH} --repo="${REPO}" --default-branch="${BRANCH}" \
            ${FB_ARGS} ${EXPORT_ARGS} "build/wine/$flavour/$ARCH" \
            "ua.org.brezblock.q4wine.wine.$flavour.yml"
    done
    flatpak build-commit-from --verbose ${EXPORT_ARGS} \
        --src-ref="runtime/ua.org.brezblock.q4wine.wine.$flavour/i386/${BRANCH}" "${REPO}" \
        "runtime/ua.org.brezblock.q4wine.wine.$flavour.compat32/x86_64/${BRANCH}"
done
