##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  glew CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# glew Copyright
# Copyright (C) 2002-2007, Milan Ikits <milan ikits[]ieee org>
# Copyright (C) 2002-2007, Marcelo E. Magallon <mmagallo[]debian org>
# Copyright (C) 2002, Lev Povalahev

# flew from sourceforge.net/projects/glew 1.7.0 2011-11-18
# https://sourceforge.net/projects/glew/files/glew/1.7.0

MESSAGE( STATUS " Adding glew library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "glew" )

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

# bin files

SET( bin_files
    glewinfo
    visualinfo
)

# inc dir

SET( inc_dir
    GL
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        GLEW
        GLEW.1.7
        GLEW.1.7.0
    )
ELSE()
    SET( lib_files
        GLEW
    )
ENDIF()

# pkgfiles

SET( pkg_files
    glew.pc
)

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
    
    IF ( CMAKE_SHARED_LIBS )
        SET( build_patch
                patch ${lib_bin_dir}/${lib_pkg}/Makefile 
                      ${lib_src_dir}/Makefile.shared.patch
        )
    ELSE()

	# INFO: includes broken static builds:
	# http://sourceforge.net/tracker/index.php?func=detail&aid=3401566&group_id=67586&atid=523274

        SET( build_patch
                patch ${lib_bin_dir}/${lib_pkg}/Makefile 
                      ${lib_src_dir}/Makefile.static.patch
        )
    ENDIF()

    IF( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )

        SET( build_patch
                ${build_patch} &&
                patch ${lib_bin_dir}/${lib_pkg}/config/Makefile.linux
                      ${lib_src_dir}/Makefile.linux.patch

        )
    ENDIF()

    # make and install

    SET( build_make
        ${build_env} &&
    	cd ${lib_pkg} &&
        export GLEW_DEST=${build_dir} &&
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

