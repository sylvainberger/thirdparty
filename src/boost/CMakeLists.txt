##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  Boost CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# Boost Copyright
# Copyright Beman Dawes, David Abrahams, 1998-2005.
# Copyright Rene Rivera 2004-2007.

# boost from sourceforge.net 1.47.0 2011-10-16
# http://sourceforge.net/projects/boost/files/boost/1.47.0/

MESSAGE( STATUS " Adding boost lib" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "boost" )

# lib pkg

SET( lib_pkg ${lib_name}_1_47_0 )

# lib config

SET( lib_cfg_without_mpi TRUE )

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
    boost
)

# lib files

SET( lib_files
    boost_chrono
    boost_chrono.1.47.0
    boost_date_time
    boost_date_time.1.47.0
    boost_filesystem
    boost_filesystem.1.47.0
    boost_graph
    boost_graph.1.47.0
    boost_iostreams
    boost_iostreams.1.47.0
    boost_math_c99
    boost_math_c99.1.47.0
    boost_math_c99f
    boost_math_c99f.1.47.0
    boost_math_c99l
    boost_math_c99l.1.47.0
    boost_math_tr1
    boost_math_tr1.1.47.0
    boost_math_tr1f
    boost_math_tr1f.1.47.0
    boost_math_tr1l
    boost_math_tr1l.1.47.0
    boost_prg_exec_monitor
    boost_prg_exec_monitor.1.47.0
    boost_program_options
    boost_program_options.1.47.0
    boost_python
    boost_python.1.47.0
    boost_random
    boost_random.1.47.0
    boost_regex
    boost_regex.1.47.0
    boost_serialization
    boost_serialization.1.47.0
    boost_signals
    boost_signals.1.47.0
    boost_system
    boost_system.1.47.0
    boost_thread
    boost_thread.1.47.0
    boost_unit_test_framework
    boost_unit_test_framework.1.47.0
    boost_wave
    boost_wave.1.47.0
    boost_wserialization
    boost_wserialization.1.47.0
)

IF( UNIX )

    # inc dir

    SET( dir_output ${build_inc_dir}/${inc_dir} )
    
    # lib files

    FOREACH( lib_file ${lib_files} )
    
        IF ( APPLE )
        
            # boost does not write versions on apple
        
            IF( NOT ${lib_file} MATCHES "[.]" )
            
                LIST( APPEND lib_output 
                    ${build_lib_dir}/${lib_prefix}${lib_file}${lib_suffix}
                )
            
            ENDIF()

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
    
    # boost_exception is always built as static
    
    LIST( APPEND lib_output 
        ${build_lib_dir}/${lib_prefix}boost_exception${static_lib_suffix}
    )
    
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
        SET( build_options variant=debug )
    ELSE()
        SET( build_options variant=release )
    ENDIF()

    IF( CMAKE_SHARED_LIBS )
        SET( build_options ${build_options} link=shared )
    ELSE()
        SET( build_options ${build_options} link=static )
    ENDIF()
    
    # config
    
    IF( lib_cfg_without_mpi )
        SET( build_config --without-mpi )
    ENDIF()

    # bootstrap, b2 install

    SET( build_b2
        ${build_env} &&
        cd ${lib_pkg} &&
        ./bootstrap.sh &&
        ./b2 install 
            --prefix=${build_dir}
            ${build_config}
            ${build_options}
    )
    
    
    # scripts
    
    IF ( APPLE )
    
        # build output
        
        SET( build_output ${bin_output} )

        IF ( CMAKE_SHARED_LIBS )
            SET( build_output ${build_output} ${lib_output} )
            
            # remove static boost_exception
            
            LIST( REMOVE_ITEM build_output
                ${build_lib_dir}/${lib_prefix}boost_exception${static_lib_suffix}
            )
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
        COMMAND ${build_b2}
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

# dependencies

ADD_DEPENDENCIES( ${lib_name} bzip2 zlib )

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
