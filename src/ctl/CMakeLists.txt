##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  ctl CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# ctl Copyright
# Copyright © 2006 Academy of Motion Picture Arts and Sciences

# ctl from sourceforge.net 1.0.1 2011-11-13
# https://sourceforge.net/projects/ampasctl/files/ctl/

MESSAGE( STATUS " Adding ctl library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "ctl" )

# lib pkg

SET( lib_pkg ${lib_name}-1.4.1 )

# lib src dir

SET( lib_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# lib bin dir

SET( lib_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        IlmCtl
        IlmCtl.2
        IlmCtl.2.0.0
        IlmCtlMath
        IlmCtlMath.2
        IlmCtlMath.2.0.0
        IlmCtlSimd
        IlmCtlSimd.2
        IlmCtlSimd.2.0.0
    )
ELSE()
    SET( lib_files
        IlmCtl
        IlmCtlMath
        IlmCtlSimd
    )
ENDIF()

IF( UNIX )

    # lib files

    FOREACH( lib_file ${lib_files} )
    
        IF ( APPLE )

            LIST( APPEND lib_output 
                ${build_lib_dir}/${lib_prefix}${lib_file}${lib_suffix}
            )

	    ELSE()

            # INFO: on UNIX lib files appends version after suffix

            STRING( REGEX REPLACE 
                "^([^.]+)([.]*)(.*)" 
                "${lib_prefix}\\1${lib_suffix}\\2\\3" 
                lib_file "${lib_file}"
            )

            LIST( APPEND lib_output 
                ${build_lib_dir}/${lib_file}
            )

	    ENDIF()
    
    ENDFOREACH()

ELSEIF( WIN32 )

    # FIXME(ms@imageplayer.org): add build support for win32.
    
ENDIF()

##-*****************************************************************************
## build configuration
##-*****************************************************************************

# unix

IF( UNIX )

    # tar uncompress

    SET( build_uncompress
        ${untar} ${lib_src_dir}/${lib_pkg}.tar.gz -C ${lib_bin_dir}
    )
    
    # patch

    IF (APPLE)

        # darwin kernel versions
        # 9.8.0 > Leopard (Mac OS X v10.5)
        # 10.4.0 -> Snow Leopard (Mac OS X v10.6)
        # 11.0.0 > Lion (Mac OS X v10.7)

        STRING( REGEX MATCH "[0-9]+" DARWIN_VERSION ${CMAKE_HOST_SYSTEM_VERSION})

        IF ( DARWIN_VERSION GREATER 9 )

            SET( build_patch
                patch ${lib_bin_dir}/${lib_pkg}/configure ${lib_src_dir}/configure.patch &&
                patch ${lib_bin_dir}/${lib_pkg}/configure.ac ${lib_src_dir}/configure.ac.patch
            )

        ENDIF()

    ENDIF()

    # stdlib.h, cstring needed on linux

    IF( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )

        SET( build_patch
            patch ${lib_bin_dir}/${lib_pkg}/IlmCtl/CtlLex.cpp ${lib_src_dir}/CtlLex.cpp.patch &&
            patch ${lib_bin_dir}/${lib_pkg}/IlmCtlSimd/CtlSimdReg.h ${lib_src_dir}/CtlSimdReg.h.patch
        )

    ENDIF()

    # options

    IF( CMAKE_BUILD_TYPE STREQUAL Debug )
        SET( build_options --enable-debug )
    ENDIF()

    IF( CMAKE_SHARED_LIBS )
        SET( build_options ${build_options} --enable-shared --disable-static )
    ELSE()
        SET( build_options ${build_options} --enable-static --disable-shared )
    ENDIF()

    IF( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
        SET( build_make export PKG_CONFIG_PATH=${build_lib_dir}/pkgconfig && )
    ENDIF()

    # configure, make and install

    SET( build_make
        ${build_make}
        ${build_env} &&
        cd ${lib_pkg} &&
        ./configure 
            --prefix=${build_dir}
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir}
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    
    IF ( APPLE )
    
        # build output

        IF ( CMAKE_SHARED_LIBS )
            SET( build_output ${lib_output} )
        ENDIF()
    
        SET( build_script 
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
                --prefix-lib @executable_path/../lib
                --prefix-framework @executable_path/../Frameworks
                --absolute-path ${build_dir}
                ${build_output}
        )
    ENDIF()

    # run

    ADD_CUSTOM_COMMAND( 
        OUTPUT ${lib_output}
        COMMAND ${build_uncompress}
        COMMAND ${build_patch}
        COMMAND ${build_make}
        COMMAND ${build_script}
    )

ELSEIF( WIN32 )

    # FIXME(ms@imageplayer.org): add build support for win32

ENDIF()

# custom target, always build

ADD_CUSTOM_TARGET(
    ${lib_name} ALL
    DEPENDS ${lib_output}
)

# dependencies

ADD_DEPENDENCIES( ${lib_name} ilmbase )

