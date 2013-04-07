##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  openexr CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# openexr Copyright
# Copyright (c) 2002, Industrial Light & Magic, a division of Lucas Digital Ltd. LLC

# openexr from openexr.com 1.7.0 2011-10-16
# http://www.openexr.com/downloads.html

MESSAGE( STATUS " Adding openexr library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "openexr" )

# lib pkg

SET( lib_pkg ${lib_name}-1.7.0 )

# lib src dir

SET( lib_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# lib bin dir

SET( lib_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# inc dir

SET( inc_dir
    OpenEXR
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        IlmImf
        IlmImf.6
        IlmImf.6.0.0
    )
ELSE()
    SET( lib_files
        IlmImf
    )
ENDIF()

# pkgfiles

SET( pkg_files
    OpenEXR.pc
)

IF( UNIX )

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

    IF( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )

        SET( build_patch              
                patch ${lib_bin_dir}/${lib_pkg}/exrenvmap/blurImage.cpp
                      ${lib_src_dir}/blurImage.cpp.patch
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

    # configure, make and install

    SET( build_make
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
        OUTPUT ${lib_output}
        COMMAND ${build_uncompress}
        COMMAND ${build_patch}
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
    DEPENDS ${lib_output}
)

# dependencies

ADD_DEPENDENCIES( ${lib_name} ilmbase zlib )

# install

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

