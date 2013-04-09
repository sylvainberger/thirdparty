##-*****************************************************************************
##  Copyright 2010-2013 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  OCIO CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# OCIO Copyright
# Copyright (c) 2003-2010 Sony Pictures Imageworks Inc., et al.

# ocio from github.com 1.0.7 2013-04-09
# https://nodeload.github.com/imageworks/OpenColorIO/tarball/v1.0.7

MESSAGE( STATUS " Adding ocio lib" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "ocio" )

# lib pkg

SET( lib_pkg "imageworks-OpenColorIO-v1.0.7-0-g87da508" )

# lib config

SET( lib_cfg_cmake_prefix TRUE )

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
    ociobakelut
    ociocheck
    ocioconvert
    ociodisplay
    ociolutimage
)

# inc dir

SET( inc_dir
    OpenColorIO
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        OpenColorIO
        OpenColorIO.1
        OpenColorIO.1.0.7
    )
ELSE()
    SET( lib_files
        OpenColorIO
    )
ENDIF()

IF( UNIX )

    # bin files

    FOREACH( bin_file ${bin_files} )

        LIST( APPEND bin_output 
            ${build_bin_dir}/${bin_file}
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

    SET( build_patch
        patch ${lib_bin_dir}/imageworks-OpenColorIO-b3cb224/src/apps/ocioconvert/main.cpp 
              ${lib_src_dir}/main.cpp.ocioconvert.patch &&
        patch ${lib_bin_dir}/imageworks-OpenColorIO-b3cb224/src/apps/ociodisplay/main.cpp 
              ${lib_src_dir}/main.cpp.ociodisplay.patch &&
        patch ${lib_bin_dir}/imageworks-OpenColorIO-b3cb224/src/apps/ociolutimage/main.cpp 
              ${lib_src_dir}/main.cpp.ociolutimage.patch
    )   

    # options

    IF( CMAKE_BUILD_TYPE STREQUAL Debug )
        SET( build_options -DCMAKE_BUILD_TYPE=Debug )
    ENDIF()

    IF( CMAKE_SHARED_LIBS )
        SET( build_options ${build_options} -DOCIO_BUILD_SHARED=true -DOCIO_BUILD_STATIC=false)
    ELSE()
	# pyglue requires shared library
        SET( build_options ${build_options} -DOCIO_BUILD_STATIC=true -DOCIO_BUILD_SHARED=false -DOCIO_BUILD_PYGLUE=false)
    ENDIF()

    IF( CMAKE_VERBOSE_MAKEFILE )
        SET( build_options ${build_options} -DCMAKE_VERBOSE_MAKEFILE=true )
    ELSE()
        SET( build_options ${build_options} -DCMAKE_VERBOSE_MAKEFILE=false )
    ENDIF()


    IF( lib_cfg_cmake_prefix )
        SET( build_make
            ${build_make}
            export CMAKE_PREFIX_PATH=${build_dir} &&
        )
    ENDIF()
            
    # make and install

    IF( lib_cfg_cmake_prefix )
        SET( build_make
            export CMAKE_PREFIX_PATH=${build_dir} &&
        )
    ENDIF()

    SET( build_make
        ${build_make}
    	cd imageworks-OpenColorIO-b3cb224 &&
        export OIIO_PATH=${build_dir} &&
      	cmake -DCMAKE_PREFIX_PATH=${build_dir}
              -DCMAKE_INSTALL_PREFIX=${build_dir} ${build_options} &&
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
                    ${build_lib_dir} ${dist_lib_dir} install_file ${lib_file}
                )
                
                LIST( APPEND install_output 
                    ${install_file}
                )
            ENDFOREACH()
            
            FOREACH( bin_file ${bin_output} )
            
                STRING( REPLACE 
                    ${build_bin_dir} ${dist_bin_dir} bin_file ${bin_file}
                )
                
                LIST( APPEND install_output
                    ${bin_file}
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

# custom target, always run

ADD_CUSTOM_TARGET(
    ${lib_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# dependencies

ADD_DEPENDENCIES( ${lib_name} oiio )

# install

INSTALL(
    FILES ${bin_output}
    DESTINATION bin
    PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE 
                GROUP_READ GROUP_EXECUTE 
                WORLD_READ WORLD_EXECUTE
)

INSTALL(
    DIRECTORY ${dir_output}
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
