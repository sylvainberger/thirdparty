##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  QtTest CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# QtTest Copyright
# Copyright 2006-2010 Kitware, Inc.
# Copyright 2006 Alexander Neundorf <neundorf@kde.org>

# QtTest from cmake.org
# http://www.cmake.org/Wiki/BundleUtilitiesExample

MESSAGE( STATUS " Adding QtTest test" )

##-*****************************************************************************
## test configuration
##-*****************************************************************************

# test name

SET( test_name "QtTest" )

# test pkg

SET( test_pkg "QtTest" )

# test src dir

SET( test_src_dir
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Test bin dir

SET( test_bin_dir
    ${CMAKE_CURRENT_BINARY_DIR}
)

# test files

SET( test_files
    QtTest.app
)

IF( UNIX )

    # test files

    FOREACH( test_file ${test_files} )

        LIST( APPEND test_output 
            ${build_test_dir}/${test_file}
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
        ${untar} ${test_src_dir}/${test_pkg}.tar.gz -C ${test_bin_dir}
    )

    # make and install

    SET( build_make
        ${build_env} &&
    	cd QtTest &&
      	cmake -DCMAKE_PREFIX_PATH=${build_dir}
              -DCMAKE_INSTALL_PREFIX=${build_test_dir} &&
        make ${build_flags} &&
        make install
    )
 
    # run    
    
    ADD_CUSTOM_COMMAND( 
        OUTPUT ${test_output}
        COMMAND ${build_uncompress}      
        COMMAND ${build_make}
    )
    
ELSEIF( WIN32 )

    # FIXME(ms@imageplayer.org): add build support for win32

ENDIF()

# custom target, always run

ADD_CUSTOM_TARGET(
    ${test_name} ALL
    DEPENDS ${test_output}
)

# dependencies

ADD_DEPENDENCIES( ${test_name} qt )
