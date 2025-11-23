vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kekeliu-whu/faiss
    REF dbb54d2e1f819d013f5386eafcfa76fea8157d80
    SHA512 2e6f8ae9043161e97182d0e606b128055ceebec40ae79089e23672caa9238d7c9231d131e4b1effc379fe2b27d31fea6a5236e8e6cd3c8345a32eebbef704bc6
    HEAD_REF master
    PATCHES
        # fix-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gpu FAISS_ENABLE_GPU
)

if ("${FAISS_ENABLE_GPU}")
    if (NOT VCPKG_CMAKE_SYSTEM_NAME AND NOT ENV{CUDACXX})
        set(ENV{CUDACXX} "$ENV{CUDA_PATH}/bin/nvcc.exe")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFAISS_ENABLE_PYTHON=OFF  # Requires SWIG
        -DBUILD_TESTING=OFF
        "-DCMAKE_CUDA_ARCHITECTURES=61;70;75;80;86;89;120"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
