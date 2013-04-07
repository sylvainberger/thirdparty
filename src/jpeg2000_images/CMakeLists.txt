##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  jpeg2000_images CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# jpeg Copyright
# Copyright (C) 1991-1997, Thomas G. Lane.

# jpeg images from ijg.org 8c 2011-11-18
# http://www.ijg.org/files/

MESSAGE( STATUS " Adding jpeg2000_images images" )

##-*****************************************************************************
## media configuration
##-*****************************************************************************

# media name

SET( media_name "jpeg2000_images" )

# media pkg

SET( media_pkg ${media_name} )

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

