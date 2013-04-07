##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  alembi-examples CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# alembic Copyright
# Copyright 2009-2011 Sony Pictures Imageworks, Inc. and
# Industrial Light and Magic, a division of Lucasfilm Entertainment Company Ltd.

# alembic from code.google.com 1.0.4 2012-01-24
# http://code.google.com/p/alembic/downloads/list

MESSAGE( STATUS " Adding alembic-examples images" )

##-*****************************************************************************
## media configuration
##-*****************************************************************************

# media name

SET( media_name "alembic-examples" )

# media pkg

SET( media_pkg "Alembic_Octopus_Example" )

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
