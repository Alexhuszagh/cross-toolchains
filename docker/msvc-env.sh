#!/usr/bin/env bash
# shellcheck disable=SC2012

home="/opt/msvc"
tools="${home}/vc/tools"
redist="${home}/vc/Redist"
kits="${home}/kits"
msvcpp_ver=$(ls -t -1 "${tools}/msvc" | head -1)
msvcpp_major=$(echo "${msvcpp_ver}" | cut -d '.' -f 1)
msvcpp_minor=$(echo "${msvcpp_ver}" | cut -d '.' -f 2)
kits_major=$(ls -t -1 "${kits}" | head -1)
kits_ver=$(ls -t -1 "${kits}/${kits_major}/include" | head -1)
kits_base="${kits}/${kits_major}"
kits_base_include="${kits_base}/include/${kits_ver}"
kits_base_lib="${kits_base}/lib/${kits_ver}"

export VCINSTALLDIR="${home}/vc"
export VCTOOLSINSTALLDIR="${tools}/msvc/${msvcpp_ver}"
export VCTOOLSREDISTDIR="${redist}/MSVC/${msvcpp_ver}"
export VCTOOLSVERSION="${msvcpp_ver}"
export VSCMD_ARG_APP_PLAT="Desktop"
export VSCMD_ARG_HOST_ARCH="${MSVC_ARCH}"
export VSCMD_ARG_TGT_ARCH="${MSVC_ARCH}"
export VSINSTALLDIR="${home}"
export INCLUDE="${VCTOOLSINSTALLDIR}/include;${kits_base_include}/ucrt;${kits_base_include}/shared;${kits_base_include}/um;${kits_base_include}/winrt;${kits_base_include}/cppwinrt"
export LIB="${VCTOOLSINSTALLDIR}/lib/${MSVC_ARCH};${kits_base_lib}/ucrt/${MSVC_ARCH};${kits_base_lib}/um/${MSVC_ARCH}"
export LIBPATH="${VCTOOLSINSTALLDIR}/lib/${MSVC_ARCH};${kits_base}/UnionMetadata/${kits_ver};${kits_base}/References/${kits_ver}"
if [[ "${MSVC_ARCH}" == "x86" ]] || [[ "${MSVC_ARCH}" == "x64" ]]; then
    export LIBPATH="${LIBPATH};${VCTOOLSINSTALLDIR}/lib/x86/store/references"
fi

case "${msvcpp_major}.${msvcpp_minor}" in
    5.0)
        VISUALSTUDIOVERSION="5.0"
        ;;
    6.0)
        VISUALSTUDIOVERSION="6.0"
        ;;
    7.0)
        VISUALSTUDIOVERSION="7.0"
        ;;
    7.1)
        VISUALSTUDIOVERSION="7.1"
        ;;
    8.0)
        VISUALSTUDIOVERSION="8.0"
        ;;
    9.0)
        VISUALSTUDIOVERSION="9.0"
        ;;
    10.0)
        VISUALSTUDIOVERSION="10.0"
        ;;
    11.0)
        VISUALSTUDIOVERSION="11.0"
        ;;
    12.0)
        VISUALSTUDIOVERSION="12.0"
        ;;
    14.0)
        VISUALSTUDIOVERSION="14.0"
        ;;
    14.1)
        VISUALSTUDIOVERSION="15.0"
        ;;
    14.11)
        VISUALSTUDIOVERSION="15.3"
        ;;
    14.12)
        VISUALSTUDIOVERSION="15.5"
        ;;
    14.13)
        VISUALSTUDIOVERSION="15.6"
        ;;
    14.14)
        VISUALSTUDIOVERSION="15.7"
        ;;
    14.15)
        VISUALSTUDIOVERSION="15.8"
        ;;
    14.16)
        VISUALSTUDIOVERSION="15.9"
        ;;
    14.20)
        VISUALSTUDIOVERSION="16.0"
        ;;
    14.21)
        VISUALSTUDIOVERSION="16.1"
        ;;
    14.22)
        VISUALSTUDIOVERSION="16.2"
        ;;
    14.23)
        VISUALSTUDIOVERSION="16.3"
        ;;
    14.24)
        VISUALSTUDIOVERSION="16.4"
        ;;
    14.25)
        VISUALSTUDIOVERSION="16.5"
        ;;
    14.26)
        VISUALSTUDIOVERSION="16.6"
        ;;
    14.27)
        VISUALSTUDIOVERSION="16.7"
        ;;
    14.28)
        VISUALSTUDIOVERSION="16.8"
        ;;
    14.29)
        VISUALSTUDIOVERSION="16.10"
        ;;
    14.30)
        VISUALSTUDIOVERSION="17.0"
        ;;
    14.31)
        VISUALSTUDIOVERSION="17.1"
        ;;
    14.32)
        VISUALSTUDIOVERSION="17.2"
        ;;
    *)
        echo "Unknown MSVC++ version, got ${msvcpp_ver}." 1>&2
        ;;
esac

export VISUALSTUDIOVERSION
