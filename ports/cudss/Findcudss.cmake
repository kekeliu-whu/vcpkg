#[=======================================================================[.rst:
Findcudss
---------

Find cudss library

IMPORTED Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``cudss``
  The cudss library

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``cudss_FOUND``
  True if the system has the cudss library.
``cudss_VERSION``
  The version of the cudss library which was found.
``cudss_INCLUDE_DIRS``
  Include directories needed to use cudss.
``cudss_LIBRARIES``
  Libraries needed to link to cudss.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``cudss_INCLUDE_DIR``
  The directory containing ``cudss.h``.
``cudss_LIBRARY``
  The path to the cudss library.

#]=======================================================================]

set(cudss_VERSION 0.6.0)

# Get the directory where this file is located (share/cudss)
set(_cudss_share_dir "${CMAKE_CURRENT_LIST_DIR}")
get_filename_component(_cudss_root_dir "${_cudss_share_dir}" DIRECTORY)
get_filename_component(_cudss_root_dir "${_cudss_root_dir}" DIRECTORY)

# Find header file
find_path(cudss_INCLUDE_DIR
    NAMES cudss.h
    PATHS "${_cudss_root_dir}/include/cudss"
    NO_DEFAULT_PATH
)

# Find library files
if(WIN32)
    find_library(cudss_LIBRARY
        NAMES cudss
        PATHS "${_cudss_root_dir}/lib"
        NO_DEFAULT_PATH
    )
    
    find_library(cudss_MTLAYER_LIBRARY
        NAMES cudss_mtlayer_vcomp140
        PATHS "${_cudss_root_dir}/lib"
        NO_DEFAULT_PATH
    )
    
    find_file(cudss_BINARY
        NAMES cudss64_0.dll
        PATHS "${_cudss_root_dir}/bin"
        NO_DEFAULT_PATH
    )
    
    find_file(cudss_MTLAYER_BINARY
        NAMES cudss_mtlayer_vcomp140.dll
        PATHS "${_cudss_root_dir}/bin"
        NO_DEFAULT_PATH
    )
else()
    find_library(cudss_LIBRARY
        NAMES cudss
        PATHS "${_cudss_root_dir}/lib"
        NO_DEFAULT_PATH
    )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(cudss
    FOUND_VAR cudss_FOUND
    REQUIRED_VARS
        cudss_LIBRARY
        cudss_INCLUDE_DIR
    VERSION_VAR cudss_VERSION
)

if(cudss_FOUND)
    set(cudss_LIBRARIES ${cudss_LIBRARY})
    if(WIN32 AND cudss_MTLAYER_LIBRARY)
        list(APPEND cudss_LIBRARIES ${cudss_MTLAYER_LIBRARY})
    endif()
    set(cudss_INCLUDE_DIRS ${cudss_INCLUDE_DIR})
    set(cudss_DEFINITIONS)

    if(NOT TARGET cudss)
        add_library(cudss SHARED IMPORTED)
        target_include_directories(cudss INTERFACE "${cudss_INCLUDE_DIR}")
        
        if(WIN32)
            set_target_properties(cudss PROPERTIES
                IMPORTED_LOCATION "${cudss_BINARY}"
                IMPORTED_IMPLIB "${cudss_LIBRARY}"
            )
        else()
            set_target_properties(cudss PROPERTIES
                IMPORTED_LOCATION "${cudss_LIBRARY}"
            )
        endif()
    endif()
endif()

mark_as_advanced(
    cudss_INCLUDE_DIR
    cudss_LIBRARY
    cudss_MTLAYER_LIBRARY
)

# Cleanup
unset(_cudss_share_dir)
unset(_cudss_root_dir)
