##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  alembic CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# alembic Copyright
# Copyright 2009-2011 Sony Pictures Imageworks, Inc. and
# Industrial Light and Magic, a division of Lucasfilm Entertainment Company Ltd.

# alembic from code.google.com 1.0.4 2012-01-24
# http://code.google.com/p/alembic/downloads/list

MESSAGE( STATUS " Adding alembic library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "alembic" )

# lib pkg

SET( lib_pkg ${lib_name} )

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
    SimpleAbcViewer
)

# inc dir

SET( inc_dir
    Alembic
)


# lib files

SET( lib_files
    AlembicAbc
    AlembicAbcCoreAbstract
    AlembicAbcCoreHDF5
    AlembicAbcGeom
    AlembicUtil
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
        ${untar} ${lib_src_dir}/${lib_pkg}.1.0.4.tar.bz2 -C ${lib_bin_dir}
    )
    
    # patch

    SET( build_patch
        patch ${lib_bin_dir}/alembic/CMakeLists.txt
              ${lib_src_dir}/CMakeLists.txt.patch &&  
        patch ${lib_bin_dir}/alembic/examples/bin/CMakeLists.txt 
              ${lib_src_dir}/CMakeLists.txt.bin.patch &&
        patch ${lib_bin_dir}/alembic/build/bootstrap/alembic_bootstrap.py
              ${lib_src_dir}/alembic_bootstrap.py.patch &&
        patch ${lib_bin_dir}/alembic/build/AlembicBoost.cmake 
              ${lib_src_dir}/AlembicBoost.cmake.patch &&
        patch ${lib_bin_dir}/alembic/lib/Alembic/Abc/CMakeLists.txt 
              ${lib_src_dir}/CMakeLists.txt.patch.Abc &&
        patch ${lib_bin_dir}/alembic/lib/Alembic/AbcCoreAbstract/CMakeLists.txt 
              ${lib_src_dir}/CMakeLists.txt.patch.AbcCoreAbstract &&
        patch ${lib_bin_dir}/alembic/lib/Alembic/AbcCoreHDF5/CMakeLists.txt 
              ${lib_src_dir}/CMakeLists.txt.patch.AbcCoreHDF5 &&                      
        patch ${lib_bin_dir}/alembic/lib/Alembic/AbcGeom/CMakeLists.txt
              ${lib_src_dir}/CMakeLists.txt.patch.AbcGeom &&    
        patch ${lib_bin_dir}/alembic/lib/Alembic/Util/CMakeLists.txt 
              ${lib_src_dir}/CMakeLists.txt.patch.Util &&    
        patch ${lib_bin_dir}/alembic/examples/AbcClients/WFObjConvert/CMakeLists.txt 
              ${lib_src_dir}/CMakeLists.txt.patch.WFObjConvert       
    )    

    # options

    IF( CMAKE_BUILD_TYPE STREQUAL Debug )
        SET( build_options --debug )
    ENDIF()

    IF( CMAKE_SHARED_LIBS )
        SET( build_options ${build_options} --shared )
    ENDIF()

    # configure, make and install

    SET( build_make
        ${build_env} &&
    	cd ${lib_pkg} &&
        python ./build/bootstrap/alembic_bootstrap.py 
            --hdf5_include_dir=${build_inc_dir}
            --hdf5_hdf5_library=${build_lib_dir}/${lib_prefix}hdf5${lib_suffix}
            --ilmbase_include_dir=${build_inc_dir}/OpenEXR
            --ilmbase_imath_library=${build_lib_dir}/${lib_prefix}Imath${lib_suffix}
            --boost_include_dir=${build_inc_dir}
            --boost_thread_library=${build_lib_dir}/${lib_prefix}boost_thread${lib_suffix}
            --zlib_include_dir=${build_inc_dir}
            --zlib_library=${build_lib_dir}/${lib_prefix}z${lib_suffix}
            --disable-prman
            --disable-arnold
            --disable-maya
            --install-dir=${build_dir}
            ${build_options}
            . &&
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

# custom target, always build

ADD_CUSTOM_TARGET(
    ${lib_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# dependencies

ADD_DEPENDENCIES( ${lib_name} glew hdf5 ilmbase boost zlib)

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
