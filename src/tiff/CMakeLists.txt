##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  libtiff CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# libtiff Copyright
# Copyright (c) 1988-1997 Sam Leffler
# Copyright (c) 1991-1997 Silicon Graphics, Inc.

# libtiff from libtiff.maptools.org 3.8.2 2011-11-18
# http://libtiff.maptools.org/dl/

MESSAGE( STATUS " Adding tiff library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "tiff" )

# lib pkg

SET( lib_pkg ${lib_name}-3.8.2 )

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
    bmp2tiff
    fax2tiff
    fax2ps
    gif2tiff
    pal2rgb
    ppm2tiff
    ras2tiff
    raw2tiff
    rgb2ycbcr
    tiff2bw
    tiff2pdf
    tiff2ps
    tiff2rgba
    tiffcmp
    tiffcp
    tiffdither
    tiffdump
    tiffinfo
    tiffmedian
    tiffset
    tiffsplit
    thumbnail
)

# inc files

SET( inc_files
    tiff.h
    tiffconf.h
    tiffio.h
    tiffio.hxx
    tiffvers.h
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        tiff
        tiff.3
        tiffxx
        tiffxx.3
    )
    # 3.8.2 is not built on apple
    IF( LINUX )
        SET( ${lib_files}
             tiff.3.8.2
             tiffxx.3.8.2
        )
    ENDIF()
ELSE()
    SET( lib_files
        tiff
    )
ENDIF()

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
                    ${build_lib_dir} ${dist_lib_dir} install_file ${lib_file}
                )
                
                LIST( APPEND install_output 
                    ${install_file}
                )
            ENDFOREACH()
        
        ENDIF()
    
        SET( install_script 
            ${PROJECT_SOURCE_DIR}/src/scripts/install_name.sh 
                --prefix-lib ${dist_prefix_lib}
                --prefix-framework ${dist_prefix_framework}
                --absolute-path ${build_dir}
                ${install_output}
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

# dependencies

ADD_DEPENDENCIES( ${lib_name} jpeg zlib )

# install

INSTALL(
    FILES ${file_output}
    DESTINATION include
)

INSTALL(
    FILES ${lib_output}
    DESTINATION lib
)

IF( APPLE )
    INSTALL(
        CODE
        "EXECUTE_PROCESS( COMMAND ${install_script} )"
    )
ENDIF()
