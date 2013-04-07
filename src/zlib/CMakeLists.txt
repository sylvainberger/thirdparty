##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  zlib CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# zlib Copyright
# Copyright (C) 1995-2004 Jean-loup Gailly.

# zlib from zlib.net 2011-11-18
# http://zlib.net/

MESSAGE( STATUS " Adding zlib library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "zlib" )

# lib pkg

SET( lib_pkg ${lib_name}-1.2.5 )

# lib src dir

SET( lib_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# lib bin dir

SET( lib_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# include files

SET( inc_files
    zconf.h
    zlib.h
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        z
        z.1
        z.1.2.5
    )
ELSE()
    SET( lib_files
        z
    )
ENDIF()

IF( UNIX )

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

    IF( CMAKE_SHARED_LIBS )
        SET( build_options -DBUILD_SHARED_LIBS=TRUE )
    ELSE()
        SET( build_options -DBUILD_SHARED_LIBS=FALSE )
    ENDIF()

    # configure, make and install

    SET( build_make
        ${build_env} &&
    	cd ${lib_pkg} &&
        cmake -DCMAKE_INSTALL_PREFIX=${build_dir}
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
        OUTPUT ${inc_output} ${lib_output}
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
    DEPENDS ${lib_output}
)

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
