##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  OCIO CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# OCIO Copyright
# Copyright (c) 2003-2010 Sony Pictures Imageworks Inc., et al.

# ocio images from opencolorio.org 1.0v1 2011-11-24
# http://opencolorio.org/downloads.html

MESSAGE( STATUS " Adding ocio-images images" )

##-*****************************************************************************
## media configuration
##-*****************************************************************************

# media name

SET( media_name "ocio-images" )

# media pkg

SET( media_pkg ${media_name}.1.0v1 )

# media src dir

SET( media_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# media bin dir

SET( media_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# media files

SET( media_files
    ${media_name}
)

IF( UNIX )

    # media files

    FOREACH( media_file ${media_files} )

        LIST( APPEND media_output 
            ${build_media_dir}/${media_file}
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
        ${untar} ${media_src_dir}/${media_pkg}.tgz -C ${media_bin_dir}
    )

    # copy images
          
    SET( build_media
        cd _tmp &&
        ${make_dir} ${build_media_dir}/${media_name} &&
        ${copy_dir} ./ ${build_media_dir}/${media_name}
    )

    # run

    ADD_CUSTOM_COMMAND( 
        OUTPUT ${media_output}
        COMMAND ${build_uncompress}
        COMMAND ${build_media}
    )

ELSEIF( WIN32 )

    # FIXME(ms@imageplayer.org): add build support for win32

ENDIF()

# custom target, always build

ADD_CUSTOM_TARGET(
    ${media_name} ALL
    DEPENDS ${media_output}
)
