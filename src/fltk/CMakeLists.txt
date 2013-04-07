##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  FLTK CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# FLTK Copyright
# Copyright 1998-2011 by Bill Spitzak and others.

# fltk from fltk.org 1.3.0 2011-10-11
# http://www.fltk.org/software.php

MESSAGE( STATUS " Adding fltk library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "fltk" )

# lib pkg

SET( lib_pkg ${lib_name}-1.3.0 )

# lib src dir

SET( lib_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# lib bin dir

SET( lib_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# bin files

SET( bin_files
    fltk-config
    fluid
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        fltk
        fltk.1.3
        fltk_forms
        fltk_forms.1.3
        fltk_gl
        fltk_gl.1.3
        fltk_images
        fltk_images.1.3
    )
ELSE()
    SET( lib_files
        fltk
        fltk_forms
        fltk_gl
        fltk_images
    )
ENDIF()

IF( UNIX )

    # bin files

    FOREACH( bin_file ${bin_files} )

        LIST( APPEND bin_output 
            ${build_bin_dir}/${bin_file}
        )
    
    ENDFOREACH()

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
        ${untar} ${lib_src_dir}/${lib_pkg}-source.tar.gz -C ${lib_bin_dir}
    )

    # options

    IF( CMAKE_BUILD_TYPE STREQUAL Debug )
        SET( build_options --enable-debug )
    ENDIF()

    IF( CMAKE_SHARED_LIBS )
        SET( build_options ${build_options} --enable-shared --disable-static )
    ELSE()
        SET( build_options ${build_options} --enable-static --disable-shared )
    ENDIF()

    # configure, make and install

    SET( build_make
        ${build_env} &&
        cd ${lib_pkg} &&
        ./configure 
            --prefix=${build_dir}
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir}
            ${build_options} &&
        ${copy} makeinclude makeinclude.orig &&
      	sed s="-L../lib"="-L../lib -L${build_dir}/lib"=g makeinclude.orig > makeinclude &&
        make ${build_flags} &&
        make install
    )

    # scripts
    
    IF ( APPLE )
    
        # build output

        SET( build_output ${bin_output} )

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
        OUTPUT ${bin_output} ${lib_output}
        COMMAND ${build_uncompress}
        COMMAND ${build_make}
        COMMAND ${build_script}
    )

ELSEIF( WIN32 )

    # FIXME(ms@imageplayer.org): add build support for win32

ENDIF()

# custom target, always build

ADD_CUSTOM_TARGET(
    ${lib_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# dependencies

ADD_DEPENDENCIES( ${lib_name} jpeg libpng zlib tiff )

