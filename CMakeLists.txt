##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  Master CMakeLists.txt for thirdparty
##  
##  Run 'make help' to list helpful options.
##
##-*****************************************************************************

CMAKE_MINIMUM_REQUIRED( VERSION 2.8 )

MESSAGE( STATUS "Project configuration" )

##-*****************************************************************************
## project configuration
##-*****************************************************************************

PROJECT( Thirdparty )

SET( TP_VERSION_MAJOR 0 )
SET( TP_VERSION_MINOR 1 )
SET( TP_VERSION_PATCH 1 )

##-*****************************************************************************
## general configuration
##-*****************************************************************************

MESSAGE( STATUS "General configuration" )

# build variables

SET( build_dir
    ${PROJECT_BINARY_DIR}
    CACHE
    STRING
    "Build dir"
)

SET( build_libs  
    ON
    CACHE
    BOOL
    "Build libs"
)

SET( build_viewers 
    OFF
    CACHE
    BOOL
    "Build viewers"
)

SET( build_tests
    OFF
    CACHE
    BOOL
    "Build tests" 
)

SET( build_media
    OFF
    CACHE
    BOOL
    "Build media" 
)

SET( build_summary
    OFF
    CACHE
    BOOL
    "Build help" 
)

# dist variables

SET( dist_dir
    ${CMAKE_INSTALL_PREFIX}
    CACHE
    STRING
    "Dist dir"
)

# cmake variables

SET( CMAKE_SHARED_LIBS 
    ON 
    CACHE 
    BOOL 
    "Build thirdparty shared libraries"
)

SET( CMAKE_VERBOSE_MAKEFILE 
    ON 
    CACHE 
    BOOL 
    "Build verbose debug or release version"
)

SET( CMAKE_BUILD_TYPE 
    Debug 
    CACHE 
    STRING 
    "Build debug or release version"
)

IF( NOT CMAKE_BUILD_TYPE ) 
    SET( CMAKE_BUILD_TYPE Debug ) 
endif()

# test

IF( ${PROJECT_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR} )
    MESSAGE( FATAL_ERROR "Not allowed to run in-source build!" )
ENDIF()

# define system

# cmake defines APPLE, UNIX and WIN32

IF( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
    SET( LINUX TRUE )
ENDIF()

# define properties

# vcc use folders
set_property( GLOBAL PROPERTY USE_FOLDERS ON )

# define macros

MACRO( ADD_BUILD NAME DIR DESCRIPTION BUILD )
SET( "${NAME}" ${BUILD} CACHE BOOL ${DESCRIPTION} )
    IF ( "${NAME}" )
        ADD_SUBDIRECTORY( ${DIR} )
    ENDIF()
ENDMACRO()

# define dirs

SET( build_bin_dir ${build_dir}/bin )
SET( build_inc_dir ${build_dir}/include )
SET( build_lib_dir ${build_dir}/lib )
SET( build_framework_dir ${build_dir}/Frameworks )
SET( build_test_dir ${build_dir}/test )
SET( build_media_dir ${build_dir}/media )

SET( dist_bin_dir ${dist_dir}/bin )
SET( dist_lib_dir ${dist_dir}/lib )
SET( dist_framework_dir ${dist_dir}/Frameworks )

IF( APPLE )
    SET( build_prefix_lib ${build_lib_dir} )
    SET( build_prefix_framework ${build_framework_dir} )
    SET( dist_prefix_lib ${dist_lib_dir} )
    SET( dist_prefix_framework ${dist_framework_dir} )
ENDIF()

# define commands

IF( CMAKE_VERBOSE_MAKEFILE )
    SET( untar tar -xpvf )
ELSE()
    SET( untar tar -xpf )
ENDIF()

IF( CMAKE_VERBOSE_MAKEFILE )
    SET( unzip unzip -o )
ELSE()
    SET( unzip unzip -oq )
ENDIF()

# FIXME(ms@imageplayer.org): cmake currently does not handle wildcards
# SET( copy cmake -E copy )
SET( copy cp -f )
SET( copy_dir ${CMAKE_COMMAND} -E copy_directory )
SET( make_dir ${CMAKE_COMMAND} -E make_directory )

# define prefix

SET( shared_lib_prefix ${CMAKE_SHARED_LIBRARY_PREFIX} )
SET( static_lib_prefix ${CMAKE_STATIC_LIBRARY_PREFIX} )

IF( CMAKE_SHARED_LIBS )
    SET( lib_prefix ${shared_lib_prefix} ) 
ELSE()
    SET( lib_prefix ${static_lib_prefix} ) 
ENDIF()

# define suffix

SET( shared_lib_suffix ${CMAKE_SHARED_LIBRARY_SUFFIX} )
SET( static_lib_suffix ${CMAKE_STATIC_LIBRARY_SUFFIX} )

IF( CMAKE_SHARED_LIBS )
    SET( lib_suffix ${shared_lib_suffix} ) 
ELSE()
    SET( lib_suffix ${static_lib_suffix} ) 
ENDIF()

# define flags

IF( UNIX )
    IF( APPLE )
        FIND_PROGRAM( cmd_sysctl "sysctl")
        IF( cmd_sysctl )
            EXECUTE_PROCESS( COMMAND ${cmd_sysctl} -n hw.physicalcpu OUTPUT_VARIABLE cpus )
            STRING( REGEX REPLACE "^.*([0-9]+).*$" "\\1" num_cpus "${cpus}" ) 
        ENDIF()
    ELSE()
        SET( cpuinfo_file "/proc/cpuinfo" )
        IF( EXISTS "${cpuinfo_file}" )
            FILE( STRINGS "${cpuinfo_file}" procs REGEX "^processor.: [0-9]+$" )
            LIST( LENGTH procs num_cpus )
        ENDIF()
    ENDIF()
ELSE()
    # FIXME(ms@imageplayer.org): add build support for win32.
ENDIF()

SET( build_flags ${build_flags} -j${num_cpus} --load-average=${num_cpus} )

# define env

IF( UNIX )
    IF( APPLE )
        # dynamic linker (tests during build)
        SET( build_env 
            unset DYLD_LIBRARY_PATH &&
            export DYLD_FALLBACK_LIBRARY_PATH=${build_lib_dir}
        )
    ELSE()
        # important - only use build_env with non cmake projects as it
        # will conflict with CMAKE_PREFIX_PATH, cmake will think libraries
        # were found in native search paths and not use absolute paths
        # for shared libraries and skip defining rpaths for the build_dir 
        # dependencies.
        SET( build_env
            export C_INCLUDE_PATH=${build_inc_dir} &&
            export CPLUS_INCLUDE_PATH=${build_inc_dir} &&
            export LIBRARY_PATH=${build_lib_dir} &&
            export LD_LIBRARY_PATH=${build_lib_dir} # for test programs.
        )
    ENDIF()
ENDIF()

##-*****************************************************************************
## build configuration
##-*****************************************************************************

MESSAGE( STATUS "Build configuration" )

# build libs

MESSAGE( STATUS "Adding libs" )

IF( build_libs )
    ADD_BUILD( alembic
              ${CMAKE_SOURCE_DIR}/src/alembic
              "Alembic"
              ON
    )
    ADD_BUILD( bzip2
              ${CMAKE_SOURCE_DIR}/src/bzip2
              "Bzip2"
              ON
    )
    ADD_BUILD( boost
              ${CMAKE_SOURCE_DIR}/src/boost
              "Boost C++ Libraries"
              ON
    )
    ADD_BUILD( glew
              ${CMAKE_SOURCE_DIR}/src/glew
              "The OpenGL Extension Wrangler Library"
              ON
    )
    ADD_BUILD( gtest
              ${CMAKE_SOURCE_DIR}/src/gtest
              "Google C++ Testing Framework"
              ON
    )
    ADD_BUILD( hdf5
              ${CMAKE_SOURCE_DIR}/src/hdf5
              "HDF5"
              ON
    )
    ADD_BUILD( ilmbase
              ${CMAKE_SOURCE_DIR}/src/ilmbase
              "IlmBase"
              ON
    )
    ADD_BUILD( jasper
              ${CMAKE_SOURCE_DIR}/src/jasper
              "Jasper"
              ON
    )
    ADD_BUILD( jpeg
              ${CMAKE_SOURCE_DIR}/src/jpeg
              "Jpeg"
              ON
    )
    ADD_BUILD( libpng
              ${CMAKE_SOURCE_DIR}/src/libpng
              "LibPNG"
              ON
    )
    ADD_BUILD( oiio
              ${CMAKE_SOURCE_DIR}/src/oiio
              "OpenImageIO"
              ON
    )
    ADD_BUILD( ocio
              ${CMAKE_SOURCE_DIR}/src/ocio
              "OpenColorIO"
              ON
    )
    ADD_BUILD( openexr
              ${CMAKE_SOURCE_DIR}/src/openexr
              "OpenEXR"
              ON
    )
    ADD_BUILD( tiff
              ${CMAKE_SOURCE_DIR}/src/tiff
              "LibTiff - TIFF Libraries and Utilities"
              ON
    )
    ADD_BUILD( qt
              ${CMAKE_SOURCE_DIR}/src/qt
              "Qt framework"
              ON
    )
    ADD_BUILD( zlib
              ${CMAKE_SOURCE_DIR}/src/zlib
              "Zlib"
              ON
    )
ENDIF()

# build viewers

MESSAGE( STATUS "Adding viewers" )

IF( build_viewers )
    # dependencies
    ADD_BUILD( fltk
              ${CMAKE_SOURCE_DIR}/src/fltk
              "Fast Light Tool Kit (FLTK)"
              ON
    )
    ADD_BUILD( ctl
              ${CMAKE_SOURCE_DIR}/src/ctl
              "Color Transformation Language"
              ON
    )
    ADD_BUILD( openexr_ctl
              ${CMAKE_SOURCE_DIR}/src/openexr_ctl
              "OpenEXR CTL"
              ON
    )
    # viewers
    ADD_BUILD( openexr_viewers
              ${CMAKE_SOURCE_DIR}/src/openexr_viewers
              "OpenEXR_Viewers"
              ON
    )
ENDIF()

# build tests

MESSAGE( STATUS "Adding tests" )

IF( build_tests )
    ADD_BUILD( test
              ${CMAKE_SOURCE_DIR}/src/QtTest
              "QtTest test"
              ON
    )
ENDIF()

# build media

MESSAGE( STATUS "Adding media" )

IF( build_media )
    ADD_BUILD( alembic-examples
              ${CMAKE_SOURCE_DIR}/src/alembic-examples
              "Alembic examples"
              ON
    )
    ADD_BUILD( jpeg2000_images
              ${CMAKE_SOURCE_DIR}/src/jpeg2000_images
              "Jpeg2000 images"
              ON
    )
    ADD_BUILD( ocio-images
              ${CMAKE_SOURCE_DIR}/src/ocio-images
              "OpenColorIO images"
              ON
    )
    ADD_BUILD( oiio-images
              ${CMAKE_SOURCE_DIR}/src/oiio-images
              "OpenImageIO images"
              ON
    )
    ADD_BUILD( openexr-images
              ${CMAKE_SOURCE_DIR}/src/openexr-images
              "OpenEXR images"
              ON
    )
ENDIF()

##-*****************************************************************************
## summary
##-*****************************************************************************

IF( build_summary )
MESSAGE( STATUS "Summary" )
MESSAGE( STATUS "Host configuration" )
MESSAGE( STATUS " CMAKE_HOST_SYSTEM_NAME = ${CMAKE_HOST_SYSTEM_NAME}" )
MESSAGE( STATUS " CMAKE_HOST_SYSTEM_PROCESSOR = ${CMAKE_HOST_SYSTEM_PROCESSOR}" )
MESSAGE( STATUS " CMAKE_HOST_SYSTEM_VERSION = ${CMAKE_HOST_SYSTEM_VERSION}" )
MESSAGE( STATUS "CMake configuration" )
MESSAGE( STATUS " CMAKE_BUILD_TYPE = ${CMAKE_BUILD_TYPE}")
MESSAGE( STATUS " CMAKE_INSTALL_PREFIX = ${CMAKE_INSTALL_PREFIX}")
MESSAGE( STATUS " CMAKE_SHARED_LIBS = ${CMAKE_SHARED_LIBS}")
MESSAGE( STATUS " CMAKE_VERBOSE_MAKEFILE = ${CMAKE_VERBOSE_MAKEFILE}")
MESSAGE( STATUS "Build configuration" )
MESSAGE( STATUS " build_dir = ${build_dir}")
MESSAGE( STATUS " build_flags = ${build_flags}")
MESSAGE( STATUS " build_libs = ${build_libs}")
MESSAGE( STATUS " build_viewers = ${build_viewers}")
MESSAGE( STATUS " build_tests = ${build_tests}")
MESSAGE( STATUS " build_media = ${build_media}")
MESSAGE( STATUS "Dist configuration" )
MESSAGE( STATUS " dist_dir = ${dist_dir}")
MESSAGE( STATUS "Usage" )
MESSAGE( STATUS " Change a configuration value with: cmake -D<variable>=<value>" )
ENDIF()

