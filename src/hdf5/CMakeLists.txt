##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  hdf5 CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# hdf5 Copyright
# Copyright by The HDF Group.
# Copyright by the Board of Trustees of the University of Illinois.
# All rights reserved. 

# hdf5 from hdfgroup.org 1.8.8 2012-01-25
# http://www.hdfgroup.org/HDF5/release/obtain5.html

MESSAGE( STATUS " Adding hdf5 library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "hdf5" )

# lib pkg

SET( lib_pkg ${lib_name}-1.8.8 )

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
    gif2h5
    h52gif
    h5cc
    h5copy
    h5debug
    h5diff
    h5dump
    h5import
    h5jam
    h5ls
    h5mkgrp
    h5perf_serial
    h5redeploy
    h5repack
    h5repart
    h5stat
    h5unjam
)

# inc files

SET( inc_files
    H5ACpublic.h
    H5Apublic.h
    H5Cpublic.h
    H5DSpublic.h
    H5Dpublic.h
    H5Epubgen.h
    H5Epublic.h
    H5FDcore.h
    H5FDdirect.h
    H5FDfamily.h
    H5FDlog.h
    H5FDmpi.h
    H5FDmpio.h
    H5FDmpiposix.h
    H5FDmulti.h
    H5FDpublic.h
    H5FDsec2.h
    H5FDstdio.h
    H5Fpublic.h
    H5Gpublic.h
    H5IMpublic.h
    H5Ipublic.h
    H5LTpublic.h
    H5Lpublic.h
    H5MMpublic.h
    H5Opublic.h
    H5PTpublic.h
    H5Ppublic.h
    H5Rpublic.h
    H5Spublic.h
    H5TBpublic.h
    H5Tpublic.h
    H5Zpublic.h
    H5api_adpt.h
    H5overflow.h
    H5pubconf.h
    H5public.h
    H5version.h
    hdf5.h
    hdf5_hl.h
)

# lib files

IF ( CMAKE_SHARED_LIBS )
    SET( lib_files
        hdf5
        hdf5.7
        hdf5.7.0.2
        hdf5_hl
        hdf5_hl.7
        hdf5_hl.7.0.2
    )
ELSE()
    SET( lib_files
        hdf5
        hdf5_hl
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

            # hdf5 does not write versions on apple
        
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
                patch ${lib_bin_dir}/${lib_pkg}/config/gnu-flags ${lib_src_dir}/gnu-flags.patch
            )

        ENDIF()

    ENDIF()    

    # options

    IF( CMAKE_SHARED_LIBS )
        SET( build_options --enable-shared --disable-static )
    ELSE()
        SET( build_options --enable-static --disable-shared )
    ENDIF()

    # configure, make and install

    SET( build_make
        ${build_env} &&
    	cd ${lib_pkg} &&
        ./configure 
            --prefix=${build_dir}
            --with-pic
            --enable-production
            --enable-threadsafe --with-pthread=/usr/include,/usr/lib
            CPPFLAGS=-I${build_inc_dir}
            LDFLAGS=-L${build_lib_dir}
            ${build_options} &&
        make ${build_flags} &&
        make check &&
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

ADD_DEPENDENCIES( ${lib_name} zlib )

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

