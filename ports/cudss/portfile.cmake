if(VCPKG_TARGET_IS_LINUX)
    file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
    set(VCPKG_POLICY_SKIP_COPYRIGHT_CHECK enabled)
elseif(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    
    vcpkg_download_distfile(ARCHIVE
        URLS "https://developer.download.nvidia.com/compute/cudss/redist/libcudss/windows-x86_64/libcudss-windows-x86_64-0.7.1.4_cuda12-archive.zip"
        FILENAME libcudss-windows-x86_64-0.7.1.4_cuda12-archive.zip
        SHA512 102e3d92ae8babdab97eab7016afdbaa6775367c38d031b0c41b4cca85b39a6bfb917262b2a29b21cd5c48835f3e1a572094ae9bce53ef64305bfd3c706bc6c1
    )

    vcpkg_extract_source_archive(
        SOURCE_PATH
        ARCHIVE "${ARCHIVE}"
    )

    # Copy header files
    file(GLOB HEADER_FILES "${SOURCE_PATH}/include/*.h")
    file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
    file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/include/${PORT}")

    # Copy dll files
    file(GLOB DLL_FILES "${SOURCE_PATH}/bin/*.dll")
    file(COPY ${DLL_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY ${DLL_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")

    # Copy lib files
    file(GLOB LIB_FILES "${SOURCE_PATH}/lib/*.lib")
    file(COPY ${LIB_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY ${LIB_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

    file(INSTALL "${CURRENT_PORT_DIR}/Findcudss.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
    file(INSTALL "${VCPKG_ROOT_DIR}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
else()
    message(FATAL_ERROR "Unsupported system: cudss is not currently ported to VCPKG in ${VCPKG_CMAKE_SYSTEM_NAME}!")
endif()
