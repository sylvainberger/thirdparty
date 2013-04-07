##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  openexr_viewers CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# openexr_viewers Copyright
# Copyright (c) 2002, Industrial Light & Magic, a division of Lucas Digital Ltd. LLC

# openexr_viewers from openexr.com 1.0.2 2011-10-16
# http://www.openexr.com/downloads.html

MESSAGE( STATUS " Adding openexr viewers" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# viewer name

SET( viewer_name "openexr_viewers" )

# viewer pkg

SET( viewer_pkg ${viewer_name}-1.0.2 )

# viewer src dir

SET( viewer_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# viewer bin dir

SET( viewer_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# viewer files

SET( viewer_files
    exrdisplay
    playexr
)

IF( UNIX )

    # viewer files

    FOREACH( viewer_file ${viewer_files} )

        LIST( APPEND viewer_output 
            ${build_bin_dir}/${viewer_file}
        )
    
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
        ${untar} ${viewer_src_dir}/${viewer_pkg}.tar.gz -C ${viewer_bin_dir}
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
                patch ${viewer_bin_dir}/${viewer_pkg}/configure ${viewer_src_dir}/configure.patch &&
                patch ${viewer_bin_dir}/${viewer_pkg}/configure.ac ${viewer_src_dir}/configure.ac.patch &&
                patch ${viewer_bin_dir}/${viewer_pkg}/exrdisplay/Makefile.am ${viewer_src_dir}/Makefile.am.patch &&
                patch ${viewer_bin_dir}/${viewer_pkg}/exrdisplay/Makefile.in ${viewer_src_dir}/Makefile.in.patch
            )

        ENDIF()

    ENDIF()

    # stdlib.h for ctltest

    IF( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )

        SET( build_patch
            patch ${viewer_bin_dir}/${viewer_pkg}/configure ${viewer_src_dir}/configure.linux.patch &&
            patch ${viewer_bin_dir}/${viewer_pkg}/configure.ac ${viewer_src_dir}/configure.ac.linux.patch &&
            patch ${viewer_bin_dir}/${viewer_pkg}/exrdisplay/applyCtl.cpp ${viewer_src_dir}/applyCtl.cpp.patch &&
            patch ${viewer_bin_dir}/${viewer_pkg}/playexr/ctlToLut.cpp ${viewer_src_dir}/ctlToLut.cpp.patch &&
            patch ${viewer_bin_dir}/${viewer_pkg}/playexr/main.cpp ${viewer_src_dir}/main.cpp.patch
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

    IF( LINUX )
        SET( build_make export PKG_CONFIG_PATH=${build_lib_dir}/pkgconfig && )
    ENDIF()

    # configure, make and install

    SET( build_make
        ${build_make}
        ${build_env} &&
        cd ${viewer_pkg} &&
        ./configure 
            --prefix=${build_dir}
            --with-fltk-config=${build_bin_dir}/fltk-config
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir}
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts

    IF ( APPLE )
        SET( build_script 
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
                --prefix-lib @executable_path/../lib
                --prefix-framework @executable_path/../Frameworks
                --absolute-path ${build_dir}
                ${viewer_output}
        )
    ENDIF()

    # run

    ADD_CUSTOM_COMMAND( 
        OUTPUT ${viewer_output}
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
    ${viewer_name} ALL
    DEPENDS ${viewer_output}
)

# dependencies

ADD_DEPENDENCIES( ${viewer_name} openexr ctl fltk )

