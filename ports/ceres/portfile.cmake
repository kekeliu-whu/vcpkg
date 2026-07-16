set(MSVC_USE_STATIC_CRT_VALUE OFF)
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        message(FATAL_ERROR "Ceres does not support mixing static CRT and dynamic library linkage")
    endif()
    set(MSVC_USE_STATIC_CRT_VALUE ON)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ceres-solver/ceres-solver
    REF b92ade3e116cce9ba53a7639daed93e11aebda0d # 2.3.0(beta)
    SHA512 83e7febb96ca3a74fa0b00c68a6e6cc26f729719a5304f4aacf582c94141fb2b28dfe0526708049cca6c2b88960963772827cc077a9240da7802381e690ddc74
    HEAD_REF master
    PATCHES
        0001_cmakelists_fixes.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/FindGflags.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindGlog.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindEigen.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindMETIS.cmake")
file(REMOVE "${SOURCE_PATH}/cmake/FindSuiteSparse.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "schur"             SCHUR_SPECIALIZATIONS
        "suitesparse"       SUITESPARSE
        "lapack"            LAPACK
        "eigensparse"       EIGENSPARSE
        "cuda"              CUDA
)
if(VCPKG_TARGET_IS_UWP)
    list(APPEND FEATURE_OPTIONS -DMINIGLOG=ON)
endif()

foreach (FEATURE ${FEATURE_OPTIONS})
    message(STATUS "${FEATURE}")
endforeach()

set(USE_CUDA OFF)
if("cuda" IN_LIST FEATURES)
    set(USE_CUDA ON)
    set(CUDA_ARCHITECTURES "75-virtual;90-virtual")
endif()

set(TARGET_OPTIONS )
if(VCPKG_TARGET_IS_IOS)
    # Note: CMake uses "OSX" not just for macOS, but also iOS, watchOS and tvOS.
    list(APPEND TARGET_OPTIONS "-DIOS_DEPLOYMENT_TARGET=${VCPKG_OSX_DEPLOYMENT_TARGET}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${TARGET_OPTIONS}
        "-DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}"
        -DEXPORT_BUILD_DIR=ON
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_BENCHMARKS=OFF
        -DUSE_CUDA=${USE_CUDA}
        -DPROVIDE_UNINSTALL_TARGET=OFF
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT_VALUE}
    MAYBE_UNUSED_VARIABLES
        CUDA
        MSVC_USE_STATIC_CRT
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib${LIB_SUFFIX}/cmake/Ceres")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
