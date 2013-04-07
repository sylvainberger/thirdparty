##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  oiio-images CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# OIIO Copyright
# Copyright (c) 2003-2010 Sony Pictures Imageworks Inc., et al.

# oiio images from github.com 2011-11-24
# https://github.com/OpenImageIO/oiio-images/downloads

MESSAGE( STATUS " Adding oiio-images images" )

##-*****************************************************************************
## media configuration
##-*****************************************************************************

# media name

SET( media_name "oiio-images" )

# media pkg

SET( media_pkg OpenImageIO-oiio-images-3819677 )

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
        ${untar} ${media_src_dir}/${media_pkg}.tar.gz -C ${media_bin_dir}
    )

    # copy images
          
    SET( build_media
        cd ${media_pkg} &&
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

