##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  bzip2 CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# bzip2 Copyright
# Copyright © 1996-2007 Julian Seward.

# bzip2 from bzip.org 2012-12-15
# http://www.bzip.org/

MESSAGE( STATUS " Adding bzip2 library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "bzip2" )

# lib pkg

SET( lib_pkg ${lib_name}-1.0.6 )

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
    bzlib.h
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        bz2
        bz2.1.0
        bz2.1.0.6
    )
ELSE()
    SET( lib_files
        bz2
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
    
    # patch - change from static to shared libs

    IF( CMAKE_SHARED_LIBS )
        IF( APPLE )
            SET( build_patch
                ${copy} ${lib_src_dir}/Makefile.apple ${lib_bin_dir}/${lib_pkg}/Makefile
            )
        ELSE()
            SET( build_patch
                ${copy} ${lib_src_dir}/Makefile.linux ${lib_bin_dir}/${lib_pkg}/Makefile
            )
        ENDIF()
    ENDIF()

    # configure, make and install

    SET( build_make
        ${build_env} &&
    	cd ${lib_pkg} &&
        make PREFIX=${build_dir} install
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
