##-*****************************************************************************
##  Copyright 2010-2012 Mikael Sundell and the other authors and contributors.
##  All Rights Reserved.
##
##  qt CMakeLists.txt for thirdparty
##
##-*****************************************************************************

# qt Copyright
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies)

# qt from get.qt.nokia.com 4.8.4 2011-10-11
# http://get.qt.nokia.com/qt/source

MESSAGE( STATUS " Adding qt library" )

##-*****************************************************************************
## lib configuration
##-*****************************************************************************

# lib name

SET( lib_name "qt" )

# lib pkg

SET( lib_pkg ${lib_name}-everywhere-opensource-src-4.8.4 )

# lib config
# ./configure --help for available configurations

SET( lib_cfg_demos FALSE )
SET( lib_cfg_examples FALSE )
SET( lib_cfg_tools FALSE )
SET( lib_cfg_translations FALSE )

SET( lib_cfg_qtgui TRUE )
SET( lib_cfg_qtphonon TRUE )
SET( lib_cfg_qtmultimedia TRUE )
SET( lib_cfg_dbus FALSE )
SET( lib_cfg_webkit FALSE )
SET( lib_cfg_script FALSE )
SET( lib_cfg_scripttools FALSE )

# framework (Apple only)

IF( APPLE )

    # INFO: Only shared libs can be used with frameworks.

    IF( CMAKE_SHARED_LIBS )
        SET( lib_cfg_framework TRUE )
    ELSE()
        SET( lib_cfg_framework FALSE )
    ENDIF()
ENDIF()

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
    qmake
    moc
    rcc
    uic
)

# inc dir

SET( inc_dirs
    Qt
    QtCore
    QtNetwork
    QtSvg
    QtSql
    QtTest
    QtXml
    QtXmlPatterns
)

IF( lib_cfg_qtgui )
    LIST( APPEND inc_dirs QtGui )
    LIST( APPEND inc_dirs QtOpenGL )
ENDIF()

IF( lib_cfg_qtphonon )
    LIST( APPEND inc_dirs phonon )
ENDIF()

IF( lib_cfg_qtmultimedia )
    LIST( APPEND inc_dirs QtMultimedia )
ENDIF()

IF( lib_cfg_dbus )
    LIST( APPEND inc_dirs QtDBus )
ENDIF()

IF( lib_cfg_webkit )
    LIST( APPEND inc_dirs QtWebKit )
    LIST( APPEND inc_dirs QtSvg )
ENDIF()

IF( lib_cfg_script )
    LIST( APPEND inc_dirs QtScript )
    LIST( APPEND inc_dirs QtDeclarative )
ENDIF()

IF( lib_cfg_scripttools )
    LIST( APPEND inc_dirs QtScriptTools )
ENDIF()

# plugins dir

SET( plugins_dirs
    plugins
)

# lib files

SET( lib_files
    QtCore
    QtCore.4
    QtCore.4.8
    QtCore.4.8.4
    QtNetwork
    QtNetwork.4
    QtNetwork.4.8
    QtNetwork.4.8.4
    QtSvg
    QtSvg.4
    QtSvg.4.8
    QtSvg.4.8.4
    QtSql
    QtSql.4
    QtSql.4.8
    QtSql.4.8.4
    QtTest
    QtTest.4
    QtTest.4.8
    QtTest.4.8.4
    QtXml
    QtXml.4
    QtXml.4.8
    QtXml.4.8.4
    QtXmlPatterns
    QtXmlPatterns.4
    QtXmlPatterns.4.8
    QtXmlPatterns.4.8.4
)

# pkgfiles

SET( pkg_files
    QtCore.pc
    QtNetwork.pc
    QtSvg.pc
    QtSql.pc
    QtTest.pc
    QtXml.pc
    QtXmlPatterns.pc
)

# prlfiles

SET( prl_files
    QtCore
    QtNetwork
    QtSvg
    QtSql
    QtTest
    QtXml
    QtXmlPatterns
)

# framework dirs

IF( lib_cfg_framework )
    SET( framework_dirs )
ENDIF()

IF( lib_cfg_qtgui )
    LIST( APPEND lib_files QtGui )
    LIST( APPEND lib_files QtGui.4 )
    LIST( APPEND lib_files QtGui.4.8 )
    LIST( APPEND lib_files QtGui.4.8.4 )
    LIST( APPEND pkg_files QtGui.pc )
    LIST( APPEND prl_files QtGui )
    LIST( APPEND lib_files QtOpenGL )
    LIST( APPEND lib_files QtOpenGL.4 )
    LIST( APPEND lib_files QtOpenGL.4.8 )
    LIST( APPEND lib_files QtOpenGL.4.8.4 )
    LIST( APPEND pkg_files QtOpenGL.pc )
    LIST( APPEND prl_files QtOpenGL )
ENDIF()

IF( lib_cfg_qtphonon )
    LIST( APPEND lib_files phonon )
    LIST( APPEND lib_files phonon.4 )
    LIST( APPEND lib_files phonon.4.4 )
    LIST( APPEND lib_files phonon.4.4.0 )
    LIST( APPEND pkg_files phonon.pc )
    LIST( APPEND prl_files phonon )
ENDIF()

IF( lib_cfg_qtmultimedia )
    LIST( APPEND lib_files QtMultimedia )
    LIST( APPEND lib_files QtMultimedia.4 )
    LIST( APPEND lib_files QtMultimedia.4.8 )
    LIST( APPEND lib_files QtMultimedia.4.8.4 )
    LIST( APPEND pkg_files QtMultimedia.pc )
    LIST( APPEND prl_files QtMultimedia )
ENDIF()

IF( lib_cfg_dbus )
    LIST( APPEND lib_files QtDBus )
    LIST( APPEND lib_files QtDBus.4 )
    LIST( APPEND lib_files QtDBus.4.8 )
    LIST( APPEND lib_files QtDBus.4.8.4 )  
    LIST( APPEND pkg_files QtDBus.pc )
    LIST( APPEND prl_files QtDBus ) 
ENDIF()

IF( lib_cfg_webkit )
    LIST( APPEND lib_files QtWebKit )
    LIST( APPEND lib_files QtWebKit.4 )
    LIST( APPEND lib_files QtWebKit.4.8 )
    LIST( APPEND lib_files QtWebKit.4.8.4 )
    LIST( APPEND pkg_files QtWebKit.pc )
    LIST( APPEND prl_files QtWebKit )
ENDIF()

IF( lib_cfg_script )
    LIST( APPEND lib_files QtScript )
    LIST( APPEND lib_files QtScript.4 )
    LIST( APPEND lib_files QtScript.4.8 )
    LIST( APPEND lib_files QtScript.4.8.4 )
    LIST( APPEND pkg_files QtScript.pc )
    LIST( APPEND pkg_files QtScript.prl )
    LIST( APPEND lib_files QtDeclarative )
    LIST( APPEND lib_files QtDeclarative.4 )
    LIST( APPEND lib_files QtDeclarative.4.8 )
    LIST( APPEND lib_files QtDeclarative.4.8.4 )
    LIST( APPEND pkg_files QtDeclarative.pc )
    LIST( APPEND prl_files QtDeclarative )
ENDIF()

IF( lib_cfg_scripttools )
    LIST( APPEND lib_files QtScriptTools )
    LIST( APPEND lib_files QtScriptTools.4 )
    LIST( APPEND lib_files QtScriptTools.4.8 )
    LIST( APPEND lib_files QtScriptTools.4.8.4 )
    LIST( APPEND pkg_files QtScriptTools.pc )
    LIST( APPEND prl_files QtScriptTools )
ENDIF()

IF( UNIX )

    # bin files

    FOREACH( bin_file ${bin_files} )

        LIST( APPEND bin_output 
            ${build_bin_dir}/${bin_file}
        )

    ENDFOREACH()
    
    # inc dirs

    FOREACH( inc_dir ${inc_dirs} )
    
        LIST( APPEND dir_output 
            ${build_inc_dir}/${inc_dir}
        )
    
    ENDFOREACH()
    
    # plugins dirs
    
    FOREACH( plugins_dir ${plugins_dirs} )
    
        LIST( APPEND plugins_output 
            ${build_dir}/${plugins_dir}
        )
    
    ENDFOREACH()

    # lib files

    FOREACH( lib_file ${lib_files} )
    
        IF( lib_cfg_framework )
        
            # INFO: debug-only framework builds are not supported. 
            # Configure with -no-framework for a pure debug build.
        
            # framework

            # framework does not write versions

            IF( NOT ${lib_file} MATCHES "[.]" )
            
                SET( framework_dir ${build_framework_dir}/${lib_file}.framework )
            
                IF( CMAKE_BUILD_TYPE STREQUAL Debug )
            
                    # fallback to -debug-and-release
            
                    LIST( APPEND lib_output 
                        ${framework_dir}/Versions/Current/${lib_file}
                        ${framework_dir}/Versions/Current/${lib_file}_debug
                    )
            
                ELSE()
                    LIST( APPEND lib_output 
                        ${framework_dir}/Versions/Current/${lib_file}
                    )
                ENDIF()
            
                LIST( APPEND framework_dirs ${framework_dir} )

            ENDIF()

        ELSE()

            IF( APPLE )
        
                IF( CMAKE_BUILD_TYPE STREQUAL Debug )
                    LIST( APPEND lib_output 
                        ${build_lib_dir}/${lib_prefix}${lib_file}_debug${lib_suffix}
                    )
                ELSE()
                    LIST( APPEND lib_output 
                        ${build_lib_dir}/${lib_prefix}${lib_file}${lib_suffix}
                    )
                ENDIF()

            ELSE()
                STRING( REGEX REPLACE 
                    "^([^.]+)([.]*)(.*)" 
                    "${lib_prefix}\\1${lib_suffix}\\2\\3" 
                    lib_file "${lib_file}"
                )

                LIST( APPEND lib_output 
                    ${build_lib_dir}/${lib_file}
                )

            ENDIF()
        ENDIF()
        
    ENDFOREACH()

    # pkg files

    FOREACH( pkg_file ${pkg_files} )

            LIST( APPEND pkg_output 
                ${build_lib_dir}/pkgconfig/${pkg_file}
            )

    ENDFOREACH()
    
    # prl files

    FOREACH( prl_file ${prl_files} )

            IF( lib_cfg_framework )

                SET( framework_dir ${build_framework_dir}/${prl_file}.framework )
            
                IF( CMAKE_BUILD_TYPE STREQUAL Debug )
            
                    # fallback to -debug-and-release
            
                    LIST( APPEND prl_output 
                        ${framework_dir}/${prl_file}.prl
                        ${framework_dir}/${prl_file}_debug.prl
                    )
                    
                ELSE()
                    LIST( APPEND prl_output 
                        ${framework_dir}/${prl_file}
                    )
                ENDIF()

            ELSE()

                LIST( APPEND prl_output 
                    ${build_lib_dir}/${prl_file}
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
    
    IF( APPLE )
        SET( build_patch
            ${copy} ${lib_src_dir}/qcocoawindow.h ${lib_bin_dir}/${lib_pkg}/src/plugins/platforms/cocoa/qcocoawindow.h &&
            ${copy} ${lib_src_dir}/qcocoawindow.mm ${lib_bin_dir}/${lib_pkg}/src/plugins/platforms/cocoa/qcocoawindow.mm &&
            ${copy} ${lib_src_dir}/qnsview.mm ${lib_bin_dir}/${lib_pkg}/src/plugins/platforms/cocoa/qnsview.mm
        )
    ENDIF()

    #SET( build_patch
    #    patch ${lib_bin_dir}/${lib_pkg}/src/gui/styles/qstylesheetstyle.cpp
    #          ${lib_src_dir}/qstylesheetstyle.patch
    #)

    IF( APPLE )

        # darwin kernel versions
        # 9.8.0 > Leopard (Mac OS X v10.5)
        # 10.4.0 -> Snow Leopard (Mac OS X v10.6)
        # 11.0.0 > Lion (Mac OS X v10.7)

        STRING( REGEX MATCH "[0-9]+" DARWIN_VERSION ${CMAKE_HOST_SYSTEM_VERSION})

        IF ( DARWIN_VERSION GREATER 9 )

            # NOTE: Static build requires bundles + copy qtmenu.nib.
            # https://bugreports.qt-project.org//browse/QTBUG-5952
            
            # Patch: "Workaround QTBUG-5952, ignore error so that static build will run."
            # Frameworks are recommended for Qt on Mac!

            IF ( NOT CMAKE_SHARED_LIBS )
                SET( build_patch
                    ${build_patch} &&
                    patch ${lib_bin_dir}/${lib_pkg}/src/gui/kernel/qapplication_mac.mm ${lib_src_dir}/qapplication_mac.mm.patch
                )
            ENDIF()

        ENDIF()

    ENDIF()

    # options

    IF( CMAKE_BUILD_TYPE STREQUAL Debug )
        IF( lib_cfg_framework )
        
            # fallback to -debug-and-release
        
            SET( build_options -debug-and-release )
        ELSE()
            SET( build_options -debug )
        ENDIF()
    ELSE()
        SET( build_options -release )
    ENDIF()

    IF( CMAKE_SHARED_LIBS )
        SET( build_options ${build_options} -shared )
    ELSE()
        SET( build_options ${build_options} -static )
    ENDIF()
    
    IF( CMAKE_VERBOSE_MAKEFILE )
        SET( build_options ${build_options} -verbose )
    ENDIF()
    
    # config

    IF ( APPLE )
        IF( lib_cfg_framework )
            SET( build_config -framework )
    	ELSE()
            SET( build_config -no-framework )
    	ENDIF()
    ENDIF()

    IF( lib_cfg_demos )
        SET( build_config ${build_config} -make demos )
    ELSE()
        SET( build_config ${build_config} -nomake demos )
    ENDIF()
    
    IF( lib_cfg_examples )
        SET( build_config ${build_config} -make examples )
    ELSE()
        SET( build_config ${build_config} -nomake examples )
    ENDIF()

    IF( lib_cfg_tools )
        SET( build_config ${build_config} -make tools )
    ELSE()
        SET( build_config ${build_config} -nomake tools )
    ENDIF()

    IF( lib_cfg_translations )
        SET( build_config ${build_config} -make translations )
    ELSE()
        SET( build_config ${build_config} -nomake translations )
    ENDIF()
    
    IF( NOT lib_cfg_qtgui )
        SET( build_config ${build_config} -no-gui -no-opengl )
    ENDIF()

    IF( lib_cfg_qtaudio )
        SET( build_config ${build_config} -audio-backend )
    ELSE()
        SET( build_config ${build_config} -no-audio-backend )
    ENDIF()

    IF( lib_cfg_qtmultimedia )
        SET( build_config ${build_config} -multimedia )
    ELSE()
        SET( build_config ${build_config} -no-multimedia )
    ENDIF()
    
    IF( lib_cfg_qtphonon )
        SET( build_config ${build_config} -phonon )
    ELSE()
        SET( build_config ${build_config} -no-phonon )
    ENDIF()
    
    IF( lib_cfg_dbus )
        SET( build_config ${build_config} -dbus )
    ELSE()
        SET( build_config ${build_config} -no-dbus )
    ENDIF()
    
    IF( lib_cfg_webkit )
        SET( build_config ${build_config} -webkit )
    ELSE()
        SET( build_config ${build_config} -no-webkit )
    ENDIF()
    
    IF( lib_cfg_script )
        SET( build_config ${build_config} -script )
    ELSE()
        SET( build_config ${build_config} -no-script )
    ENDIF()
    
    IF( lib_cfg_scripttools )
        SET( build_config ${build_config} -scripttools )
    ELSE()
        SET( build_config ${build_config} -no-scripttools )
    ENDIF()
    
    # lib dir
    
    IF( lib_cfg_framework )
        SET( build_libdir ${build_framework_dir} )
    ELSE()
        SET( build_libdir ${build_lib_dir} )
    ENDIF()

    # configure, make and install

    SET( build_make
    	cd ${lib_pkg} &&
        ./configure 
            -prefix ${build_dir}
            -libdir ${build_libdir}
            -opensource
            -confirm-license
            -no-qt3support
            -system-libpng
            -system-libtiff
            -system-libjpeg
            -system-zlib
            -I${build_inc_dir}
            -L${build_lib_dir}
            ${build_config}
            ${build_options} &&
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
                --suffix-debug _debug
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
            
                IF( lib_cfg_framework )
                    STRING( REPLACE 
                        ${build_framework_dir} ${dist_framework_dir} lib_file ${lib_file}
                    )
                ELSE()
                    STRING( REPLACE 
                        ${build_lib_dir} ${dist_lib_dir} lib_file ${lib_file}
                    )
                ENDIF()
                
                LIST( APPEND install_output
                    ${lib_file}
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
		--suffix-debug _debug
                --absolute-path ${build_dir}
                ${install_output}
        )

    ENDIF()

ELSEIF( WIN32 )

    # FIXME(ms@imageplayer.org): add build support for win32.

ENDIF()

# custom target, always build

ADD_CUSTOM_TARGET(
    ${lib_name} ALL
    DEPENDS ${bin_output} ${lib_output}
)

# dependencies

ADD_DEPENDENCIES( ${lib_name} libpng tiff jpeg zlib )

# install

# moc bin needed by CMake FindQt

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
    DIRECTORY ${plugins_output}
    DESTINATION .
)

IF( lib_cfg_framework )
    INSTALL(
        DIRECTORY ${framework_dirs}
        DESTINATION Frameworks
        REGEX "4/4$" EXCLUDE
    )
ELSE()
    INSTALL(
        FILES ${lib_output}
        DESTINATION lib
    )

    INSTALL(
        FILES ${pkg_output}
        DESTINATION lib/pkgconfig
    )
ENDIF()

IF( UNIX )

    IF( APPLE )
        INSTALL(
            CODE
            "EXECUTE_PROCESS( COMMAND ${install_script} )"
        )
    ENDIF()

    # pkgconfig

    IF( CMAKE_SHARED_LIBS AND NOT lib_cfg_framework )
        FOREACH( pkg_file ${pkg_output} )
        
            STRING( REPLACE 
                ${build_lib_dir} ${dist_lib_dir} pkg_file ${pkg_file}
            )
            
            LIST( APPEND pkg_install
                ${pkg_file}
            )
        ENDFOREACH()

    	SET( pkg_script
            ${PROJECT_SOURCE_DIR}/src/scripts/install_pkg.sh 
                --build-path ${build_dir}
                --dist-path ${dist_dir}
                ${pkg_install}
        )

        INSTALL(
            CODE
            "EXECUTE_PROCESS( COMMAND ${pkg_script} )"
        )
    ENDIF()
    
    # prl

    FOREACH( prl_file ${prl_output} )
    
        STRING( REPLACE 
            ${build_dir} ${dist_dir} prl_file ${prl_file}
        )
        
        LIST( APPEND prl_install
            ${prl_file}
        )
    ENDFOREACH()

    SET( prl_script
        ${PROJECT_SOURCE_DIR}/src/scripts/install_prl.sh 
            --build-path ${build_dir}
            --dist-path ${dist_dir}
            ${prl_install}
    )

    INSTALL(
        CODE
        "EXECUTE_PROCESS( COMMAND ${prl_script} )"
    )
    
    # qt.conf
    # INFO(ms@imageplayer.org): write a qt.conf to make sure the dist qmake binary reports
    # correct prefixed path. FindQt4 uses "qmake -query QT_INSTALL_LIBS".

    IF( lib_cfg_framework )
    
        INSTALL( CODE
             "SET(dist_bin_dir ${dist_bin_dir})
             FILE(WRITE \"\${dist_bin_dir}/qt.conf\" 
             \"[Paths]\nPrefix = ${dist_dir}\nLibraries = Frameworks\")"
             COMPONENT Runtime
        )
    
    ELSE()
    
        INSTALL( CODE
             "SET(dist_bin_dir ${dist_bin_dir})
             FILE(WRITE \"\${dist_bin_dir}/qt.conf\" 
             \"[Paths]\nPrefix = ${dist_dir}\")"
             COMPONENT Runtime
        )
        
    ENDIF()
    
ENDIF()
