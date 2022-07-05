#!/usr/bin/env bash

set -x
set -euo pipefail

# shellcheck disable=SC1091
. lib.sh

export ARCH="${1}"
export BSD_ARCH=
case "${ARCH}" in
    aarch64)
        BSD_ARCH=arm64
        ;;
    x86_64)
        BSD_ARCH=amd64
        ;;
    i686)
        BSD_ARCH=i386
        ;;
    *)
        echo "Unknown architecture for OpenBSD, got ${ARCH}" >&2
        exit 1
        ;;
esac
export BSD_HOME="https://cdn.openbsd.org/pub/OpenBSD/"
export BSD_MAJOR=7

max_openbsd() {
    local best=
    local minor=0
    local version=
    local version_major=
    local version_minor=
    for version in "${@}"; do
        version_major=$(echo "${version}"| cut -d '.' -f 1)
        version_minor=$(echo "${version}"| cut -d '.' -f 2)
        if [ "${version_major}" == "${BSD_MAJOR}" ] && [ "${version_minor}" -gt "${minor}" ]; then
            best="${version}"
            minor="${version_minor}"
        fi
    done
    if [[ -z "$best" ]]; then
        echo "Could not find best release for OpenBSD ${BSD_MAJOR}." 1>&2
        exit 1
    fi
    echo "${best}"
}

latest_openbsd() {
    local html
    local filtered
    local versions
    local max_version

    # this is a bit complex, since we get HTML return
    html=$(curl --silent --list-only "${BSD_HOME}")
    filtered=$(echo "${html}" | grep 'href="'"${BSD_MAJOR}" | grep '>'"${BSD_MAJOR}")
    versions=($(echo "${filtered}" | cut -d '>' -f 2 | cut -d '/' -f 1))
    max_version=$(max_openbsd "${versions[@]}")

    echo "${max_version}"
}

base_release="$(latest_openbsd)"

main() {
    local binutils=2.32 \
          gcc=6.4.0 \
          target="${ARCH}-unknown-openbsd"

    install_packages ca-certificates \
        curl \
        g++ \
        make \
        wget \
        xz-utils

    local td
    td="$(mktemp -d)"

    pushd "${td}"
    mkdir "${td}"/{binutils,gcc}{,-build} "${td}/openbsd"

    curl --retry 3 -sSfL "https://ftp.gnu.org/gnu/binutils/binutils-${binutils}.tar.gz" -O
    tar -C "${td}/binutils" --strip-components=1 -xf "binutils-${binutils}.tar.gz"

    curl --retry 3 -sSfL "https://ftp.gnu.org/gnu/gcc/gcc-${gcc}/gcc-${gcc}.tar.gz" -O
    tar -C "${td}/gcc" --strip-components=1 -xf "gcc-${gcc}.tar.gz"

    cd gcc
    sed -i -e 's/ftp:/https:/g' ./contrib/download_prerequisites
    ./contrib/download_prerequisites
    cd ..

    local home_dir="${BSD_HOME}/${base_release}/${BSD_ARCH}"
    local filename="base${base_release//./}.tgz"
    curl --retry 3 -sSfL "${home_dir}/${filename}" -O
    tar -C "${td}/openbsd" -xf base.txz ./usr/include ./usr/lib

    local destdir="/usr/local/${target}"
    cp -r "${td}/openbsd/usr/include" "${destdir}"
    cp -r "${td}/openbsd/usr/lib" "${destdir}"
    ln -s libc.so.96.1 "${destdir}/lib/libc.so"
    ln -s libc++.so.9.0 "${destdir}/lib/libc++.so"
    ln -s libexecinfo.so.3.0 "${destdir}/lib/libexecinfo.so"
    ln -s libm.so.10.1 "${destdir}/lib/libm.so"
    ln -s libcompiler_rt.a "${destdir}/lib/librt.a"
    ln -s libutil.so.16.0 "${destdir}/lib/libutil.so"
    ln -s libpthread.so.26.1 "${destdir}/lib/libpthread.so"
    ln -s libkvm.so.17.0 "${destdir}/lib/libkvm.so"

    cd binutils-build
    ../binutils/configure \
        --target="${target}"
    make "-j$(nproc)"
    make install
    cd ..

    # TODO(ahuszagh) Starting here...

#    cd gcc-build
#    ../gcc/configure \
#        --disable-libada \
#        --disable-libcilkrt \
#        --disable-libcilkrts \
#        --disable-libgomp \
#        --disable-libquadmath \
#        --disable-libquadmath-support \
#        --disable-libsanitizer \
#        --disable-libssp \
#        --disable-libvtv \
#        --disable-lto \
#        --disable-nls \
#        --enable-languages=c,c++ \
#        --target="${target}"
#    make "-j$(nproc)"
#    make install
#    cd ..
#
#    # clean up
#    popd
#
#    purge_packages
#
#    # store the version info for the FreeBSD release
#    bsd_revision=$(curl --retry 3 -sSfL "${bsd_http}/REVISION")
#    echo "${base_release} (${bsd_revision})" > /opt/freebsd-version
#
#    rm -rf "${td}"
    rm "${0}"
}

main "${@}"
