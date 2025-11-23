# Update both, literally.

set(GIT_COMMIT_ID_USER_DEFINE "eee1d07e59680192a38788e15fd99ca113a31db9")

set(COLMAP_REF 3.12.666 ${GIT_COMMIT_ID_USER_DEFINE})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO colmap/colmap
    REF ${GIT_COMMIT_ID_USER_DEFINE}
    SHA512 8ffb6df5f5e59759d614bf1af16bf9012b9132f787c21a9bafcac0252b3ffd285156b0a124540bdafbdbd02c3161ebbd5c229f132fba315da4ffdca6c29d5795
    HEAD_REF main
    PATCHES
        no-glu.diff
        # fix-flann.patch
        fix-colmap2720.patch
)

if (NOT TRIPLET_SYSTEM_ARCH STREQUAL "x64" AND ("cuda" IN_LIST FEATURES OR "cuda-redist" IN_LIST FEATURES))
    message(FATAL_ERROR "Feature cuda and cuda-redist require x64 triplet.")
endif()

# set GIT_COMMIT_ID and GIT_COMMIT_DATE
if(DEFINED VCPKG_HEAD_VERSION)
    set(GIT_COMMIT_ID "${VCPKG_HEAD_VERSION}")
elseif(NOT VERSION IN_LIST COLMAP_REF)
    message(FATAL_ERROR "Version ${VERSION} missing in COLMAP_REF (${COLMAP_REF})")
else()
    list(GET COLMAP_REF 1 GIT_COMMIT_ID)
endif()

string(TIMESTAMP COLMAP_GIT_COMMIT_DATE "%Y-%m-%d")

foreach(FEATURE ${FEATURE_OPTIONS})
    message(STATUS "${FEATURE}")
endforeach()

set(CUDA_ENABLED OFF)
set(GUI_ENABLED OFF)
set(TESTS_ENABLED OFF)
set(CGAL_ENABLED OFF)
set(OPENMP_ENABLED ON)

if("cuda" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "61;70;75;80;86;89;120")
endif()

if("cuda-redist" IN_LIST FEATURES)
    set(CUDA_ENABLED ON)
    set(CUDA_ARCHITECTURES "all-major")
endif()

if("gui" IN_LIST FEATURES)
    set(GUI_ENABLED ON)
endif()

if("tests" IN_LIST FEATURES)
    set(TESTS_ENABLED ON)
endif()

if("cgal" IN_LIST FEATURES)
    set(CGAL_ENABLED ON)
endif()

if (VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    set(OPENMP_ENABLED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DCUDA_ENABLED=${CUDA_ENABLED}
        "-DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}"
        -DGUI_ENABLED=${GUI_ENABLED}
        -DTESTS_ENABLED=${TESTS_ENABLED}
        -DGIT_COMMIT_ID=${GIT_COMMIT_ID}
        -DGIT_COMMIT_DATE=${COLMAP_GIT_COMMIT_DATE}
        -DOPENMP_ENABLED=${OPENMP_ENABLED}
        -DCGAL_ENABLED=${CGAL_ENABLED}
        -DFETCH_POSELIB=OFF
        -DFETCH_FAISS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(GLOB TOOL_FILENAMES "${CURRENT_PACKAGES_DIR}/bin/*")
foreach(TOOL_FILENAME ${TOOL_FILENAMES})
    get_filename_component(TEST_TOOL_NAME ${TOOL_FILENAME} NAME_WLE)
    list(APPEND COLMAP_TOOL_NAMES "${TEST_TOOL_NAME}")
endforeach()

vcpkg_copy_tools(TOOL_NAMES ${COLMAP_TOOL_NAMES} AUTO_CLEAN)

# remove empty folders and unused files
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/include/colmap/exe"
    "${CURRENT_PACKAGES_DIR}/include/colmap/tools"
    "${CURRENT_PACKAGES_DIR}/include/colmap/ui/media"
    "${CURRENT_PACKAGES_DIR}/include/colmap/ui/shaders"
    "${CURRENT_PACKAGES_DIR}/COLMAP.bat"
    "${CURRENT_PACKAGES_DIR}/RUN_TESTS.bat"
    "${CURRENT_PACKAGES_DIR}/debug/COLMAP.bat"
    "${CURRENT_PACKAGES_DIR}/debug/RUN_TESTS.bat"
    "${CURRENT_PACKAGES_DIR}/debug/bin"
)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.txt")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
