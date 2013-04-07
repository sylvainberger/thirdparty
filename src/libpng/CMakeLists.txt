##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  libpng CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# libpng Copyright
# Copyright (c) 1998-2009 Glenn Randers-Pehrson
# (Version 0.96 Copyright (c) 1996, 1997 Andreas Dilger)
# (Version 0.88 Copyright (c) 1995, 1996 Guy Eric Schalnat, Group 42, Inc.)

# libpng from sourceforge.net/projects/libpng 1.2.40 2011-11-18
# https://sourceforge.net/projects/libpng/files/libpng15/1.5.6

MESSAGE( STATUS " Adding libpng library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "libpng" )

# lib pkg

SET( lib_pkg ${lib_name}-1.5.6 )

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
    libpng15-config
)

# inc files

SET( inc_files
    png.h
    pngconf.h
    pnglibconf.h
)

# inc dir

SET( inc_dir
    libpng15
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        png
        png15
        png15.15
    )
    # 15.6.0 is not built on apple
    IF( LINUX )
        SET( ${lib_files}
             png15.15.6.0
        )
    ENDIF()
ELSE()
    SET( lib_files
        png
    )
ENDIF()

# pkgfiles

SET( pkg_files
    libpng.pc
    libpng15.pc
)

IF( UNIX )

    # bin files

    FOREACH( bin_file ${bin_files} )

        LIST( APPEND bin_output 
            ${build_bin_dir}/${bin_file}
        )
    
    ENDFOREACH()

    # inc files

    FOREACH( inc_file ${inc_files} )
    
        LIST( APPEND file_output 
            ${build_inc_dir}/${inc_file}
        )
    
    ENDFOREACH()

    # inc dir

    SET( dir_output ${build_inc_dir}/${inc_dir} )

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

    # pkg files

    FOREACH( pkg_file ${pkg_files} )

            LIST( APPEND pkg_output 
                ${build_lib_dir}/pkgconfig/${pkg_file}
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
        ${untar} ${lib_src_dir}/${lib_pkg}.tar.gz -C ${lib_bin_dir}
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
            ${build_options} &&
        make ${build_flags} &&
        make install
    )

    # scripts
    
    IF ( APPLE )
    
        # build output
        
        SET( build_output ${bin_output} )

        IF ( CMAKE_SHARED_LIBS )
            SET( build_output ${build_output} ${lib_output} )
        ENDIF()
    
        SET( build_script 
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
                --prefix-lib ${build_prefix_lib}
                --prefix-framework ${build_prefix_framework}
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
    
    # install
    
    IF ( APPLE )
    
        # install output

        IF ( CMAKE_SHARED_LIBS )
            FOREACH( lib_file ${lib_output} )
            
                STRING( REPLACE 
                    ${build_lib_dir} ${dist_lib_dir} lib_file ${lib_file}
                )
                
                LIST( APPEND lib_install
                    ${lib_file}
                )
            ENDFOREACH()
        
        ENDIF()
    
        SET( lib_script
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
                --prefix-lib ${dist_prefix_lib}
                --prefix-framework ${dist_prefix_framework}
                --absolute-path ${build_dir}
                ${lib_install}
        )
    ENDIF()    

ELSEIF( WIN32 )

    # FIXME(ms@imageplayer.org): add build support for win32

ENDIF()

# custom target, always build

ADD_CUSTOM_TARGET(
    ${lib_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# install

INSTALL(
    FILES ${file_output}
    DESTINATION include
)

INSTALL(
    DIRECTORY ${dir_output}
    DESTINATION include
)

INSTALL(
    FILES ${lib_output}
    DESTINATION lib
)

INSTALL(
    FILES ${pkg_output}
    DESTINATION lib/pkgconfig
)

IF( UNIX )

    IF( APPLE )
        INSTALL(
            CODE
            "EXECUTE_PROCESS( COMMAND ${lib_script} )"
        )
    ENDIF()

    # pkgconfig

    IF ( CMAKE_SHARED_LIBS )
        FOREACH( pkg_file ${pkg_output} )
        
            STRING( REPLACE 
                ${build_lib_dir} ${dist_lib_dir} pkg_file ${pkg_file}
            )
            
            LIST( APPEND pkg_install
                ${pkg_file}
            )
        ENDFOREACH()
    
    ENDIF()

    SET( pkg_script
        ${PROJECT_SOURCE_DIR}/src/scripts/install_pkg.sh 
            --build-path ${build_dir}
            --dist-path ${dist_dir}
            ${pkg_install}
    )

    INSTALL(
        CODE
        "EXECUTE_PROCESS( COMMAND ${pkg_script} )"
    )

ENDIF()

