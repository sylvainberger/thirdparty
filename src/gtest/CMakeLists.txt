##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  gtest CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# gtest Copyright
# Copyright 2005, Google Inc.

# guest from code.google.com 1.6.0 2011-11-21
# http://code.google.com/p/googletest/downloads/list

MESSAGE( STATUS " Adding gtest library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "gtest" )

# lib pkg

SET( lib_pkg ${lib_name}-1.6.0 )

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
    gtest
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        gtest_main
        gtest_main.0
        gtest
        gtest.0
    )
ELSE()
    SET( lib_files
        gtest_main
        gtest
    )
ENDIF()

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
        ${unzip} ${lib_src_dir}/${lib_pkg}.zip -d ${lib_bin_dir}
    )

    # options

    IF( CMAKE_SHARED_LIBS )
        SET( build_options --enable-shared --disable-static )
    ELSE()
        SET( build_options --enable-static --disable-shared )
    ENDIF()

    # configure, make and install

    SET( build_make
        cd ${lib_pkg} &&
        ./configure 
            --prefix=${build_dir}
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir}
            ${build_options} &&
        make ${build_flags}
    )

    # copy bin
    
    SET( build_bin
        cd ${lib_pkg} &&
        ${make_dir} ${build_dir}/bin &&
        ${copy} ./scripts/gtest-config ${build_dir}/bin
    )

    # copy include

    SET( build_include
        cd ${lib_pkg} &&
        ${make_dir} ${build_dir}/include &&
        ${copy_dir} ./include/gtest ${build_dir}/include/gtest
    )
    
    # copy lib
    
    IF( CMAKE_SHARED_LIBS )
        SET( build_lib
            cd ${lib_pkg} &&
            ${make_dir} ${build_dir}/lib &&
            ${copy} ./lib/.libs/${shared_lib_prefix}gtest*${lib_suffix} ${build_dir}/lib
        )
    ELSE()
        SET( build_lib
            ${build_env} &&
            cd ${lib_pkg} &&
            ${make_dir} ${build_dir}/lib &&
            ${copy} ./lib/.libs/${static_lib_prefix}gtest*${lib_suffix} ${build_dir}/lib
        )
    ENDIF()

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
        COMMAND ${build_make}
        COMMAND ${build_bin}
        COMMAND ${build_include}
        COMMAND ${build_lib}
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
