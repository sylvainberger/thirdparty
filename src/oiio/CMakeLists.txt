##-*****************************************************************************
##  Copyright 2010-2013 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  oiio CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# OIIO Copyright
# Copyright 2008 Larry Gritz and the other authors and contributors.
# All Rights Reserved.

# oiio from github.com 1.1 2013-04-09
# https://github.com/OpenImageIO/oiio/tree/RB-1.1

MESSAGE( STATUS " Adding oiio lib" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "oiio" )

# lib pkg

SET( lib_pkg "oiio-RB-1.1" )

# lib config

SET( lib_cfg_thirdparty_tools TRUE )
SET( lib_cfg_cmake_prefix TRUE )
SET( lib_cfg_verbose TRUE )
SET( lib_cfg_iv TRUE )
SET( lib_cfg_jasper TRUE )
SET( lib_cfg_tbb TRUE )

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
    idiff
    igrep
    iinfo
    iprocess
    maketx
    iv
    oiiotool
)

# inc dir

SET( inc_dir
    OpenImageIO
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        OpenImageIO
        OpenImageIO.1.1
        OpenImageIO.1.1.9
    )
ELSE()
    SET( lib_files
        OpenImageIO
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

    IF (APPLE)

        # darwin kernel versions
        # 9.8.0 > Leopard (Mac OS X v10.5)
        # 10.4.0 -> Snow Leopard (Mac OS X v10.6)
        # 11.0.0 > Lion (Mac OS X v10.7)

        STRING( REGEX MATCH "[0-9]+" DARWIN_VERSION ${CMAKE_HOST_SYSTEM_VERSION})

        IF ( DARWIN_VERSION GREATER 9 )

            # NOTE: CMake Qt4ConfigDependentSettings.cmake does not include
            # Cocoa framework for dependent static Qt libraries.

            IF ( NOT CMAKE_SHARED_LIBS )
                SET( build_patch
                    patch ${lib_bin_dir}/${lib_pkg}/src/iv/CMakeLists.txt ${lib_src_dir}/CMakeLists.txt.patch
                )
            ENDIF()

        ENDIF()

    ENDIF()    

    # options

    IF( CMAKE_BUILD_TYPE STREQUAL Debug )
        SET( build_options debug )
    ENDIF()

    IF( CMAKE_SHARED_LIBS )
        SET( build_options ${build_options} LINKSTATIC=0 BUILDSTATIC=0 )
    ELSE()
        SET( build_options ${build_options} LINKSTATIC=1 BUILDSTATIC=1 )
    ENDIF()
    
    # config
    
    IF( lib_cfg_iv )
        SET( build_config ${build_config} USE_QT=1 )
    ELSE()
        SET( build_config ${build_config} USE_QT=0 )
    ENDIF()
    
    IF( lib_cfg_jasper )
        SET( build_config ${build_config} USE_JASPER=1 )
    ELSE()
        SET( build_config ${build_config} USE_JASPER=0 )
    ENDIF()
    
    IF( lib_cfg_verbose )
        SET( build_config ${build_config} VERBOSE=1 )
    ELSE()
        SET( build_config ${build_config} VERBOSE=0 )
    ENDIF()

    # TBB - Use internal.

    SET( build_config ${build_config} USE_TBB=0 )
    
    # THIRD_PARTY_TOOLS_HOME -> Finds IlmBase and OpenEXR
    # CMAKE_PREFIX_PATH -> Finds Png, JPEG and other dependencies
    
    # make and install

    SET( build_make
    	cd ${lib_pkg} &&
    )
    
    IF( lib_cfg_thirdparty_tools )
        SET( build_make
            ${build_make}
            export THIRD_PARTY_TOOLS_HOME=${build_dir} &&
        )
    ENDIF()
    
    IF( lib_cfg_cmake_prefix )
        SET( build_make
            ${build_make}
            export CMAKE_PREFIX_PATH=${build_dir} &&
        )
    ENDIF()
    
    SET( build_make
        ${build_make}
        make
            INSTALLDIR=${build_dir}
            dist_dir=./
            ${build_options}
            ${build_config}
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

ADD_DEPENDENCIES( ${lib_name} boost glew ilmbase jasper jpeg libpng openexr qt tiff )

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
