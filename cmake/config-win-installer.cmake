include(CPackIFWConfigureFile)

set(CREATE_INSTALLER ON
    CACHE BOOL "Specifies whether installer should be created or not"
)

set(ONLINE_INSTALLER OFF
    CACHE BOOL "Specifies whether online or offline installer should be created"
)
set(ONLINE_REPO_OUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/repository"
    CACHE STRING "If ONLINE_INSTALLER is ON, specifies the directory to store online repository files"
)

if(CMAKE_BUILD_TYPE STREQUAL "Release" AND CREATE_INSTALLER)
    # Configure Qt libraries component
    set(QT_RELEASE_DATE "2023-06-04")
    set(QT_VERSION ${QT_VERSION})
    cpack_ifw_configure_file(
        ${CMAKE_SOURCE_DIR}/config/installer/packages/org.qt.components/meta/package.xml.in
        ${CMAKE_BINARY_DIR}/installer/packages/org.qt.components/meta/package.xml
    )

    # Configure Maintenance tool component
    set(MAINTENANCE_TOOL_RELEASE_DATE "2023-06-04")
    set(MAINTENANCE_TOOL_VERSION "1.0")
    cpack_ifw_configure_file(
        ${CMAKE_SOURCE_DIR}/config/installer/packages/maintenancetool/meta/package.xml.in
        ${CMAKE_BINARY_DIR}/installer/packages/maintenancetool/meta/package.xml
    )
    configure_file(
        ${CMAKE_SOURCE_DIR}/config/installer/packages/maintenancetool/meta/installscript.qs
        ${CMAKE_BINARY_DIR}/installer/packages/maintenancetool/meta/installscript.qs
        COPYONLY
    )

    # Setting components name and versions
    set(GUI_COMPONENT_URL "templateproject.compo.gui")
    set(GUI_COMPONENT_NAME "TemplateProject GUI")
    set(GUI_COMPONENT_RELEASE_DATE "2023-05-31")
    set(GUI_COMPONENT_VERSION "0.1")

    # Configure xml config files required for creating installer
    cpack_ifw_configure_file(
        ${CMAKE_SOURCE_DIR}/config/installer/config/config.xml.in
        ${CMAKE_BINARY_DIR}/installer/config/config.xml
    )

    # Configure gui component
    cpack_ifw_configure_file(
        ${CMAKE_SOURCE_DIR}/config/installer/packages/1/meta/package.xml.in
        ${CMAKE_BINARY_DIR}/installer/packages/${GUI_COMPONENT_URL}/meta/package.xml
    )
    configure_file("${CMAKE_SOURCE_DIR}/LICENSE"
        "${CMAKE_BINARY_DIR}/installer/packages/${GUI_COMPONENT_URL}/meta/LICENSE"
        COPYONLY
    )
    configure_file("${CMAKE_SOURCE_DIR}/config/installer/packages/1/meta/createShortcut.qs"
        "${CMAKE_BINARY_DIR}/installer/packages/${GUI_COMPONENT_URL}/meta/createShortcut.qs"
        COPYONLY
    )

    if(DEFINED ENV{QTIFWDIR})
        if(EXISTS "$ENV{QTDIR}/bin/windeployqt.exe")
            # Copy Qt libraries to Qt component
            add_custom_target(qtComponent ALL
                COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/installer/packages/org.qt.components/data"
                COMMAND $ENV{QTDIR}/bin/windeployqt.exe --dir ${CMAKE_BINARY_DIR}/installer/packages/org.qt.components/data --qmldir ${CMAKE_SOURCE_DIR}/qml --release $<TARGET_FILE:${PROJECT_NAME}>
            )

            # Copy installerbase as MaintenanceTool to maintenancetool component
            add_custom_target(maintenancetool ALL
                DEPENDS qtComponent
                COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/installer/packages/maintenancetool/data"
                COMMAND ${CMAKE_COMMAND} -E copy "$ENV{QTIFWDIR}/bin/installerbase.exe"
                    "${CMAKE_BINARY_DIR}/installer/packages/maintenancetool/data/"
            )
            add_custom_target(maintenancetoolUpdate ALL
                DEPENDS maintenancetool
                COMMAND $ENV{QTIFWDIR}/bin/binarycreator.exe
                    -c ${CMAKE_BINARY_DIR}/installer/config/config.xml
                    -p ${CMAKE_BINARY_DIR}/installer/packages -rcc
                WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/installer/packages/maintenancetool/data/"
            )

            # Gui component
            add_custom_target(guiComponent ALL
                DEPENDS maintenancetoolUpdate
                COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/installer/packages/${GUI_COMPONENT_URL}/data/"
                COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.exe"
                    "${CMAKE_BINARY_DIR}/installer/packages/${GUI_COMPONENT_URL}/data/"
            )

            # Creating the installer
            if (ONLINE_INSTALLER)
                add_custom_target(makeInstaller ALL
                    DEPENDS qtComponent maintenancetool maintenancetoolUpdate guiComponent # And other components if any
                    COMMAND $ENV{QTIFWDIR}/bin/repogen.exe --update --update-new-components -p ${CMAKE_BINARY_DIR}/installer/packages
                        ${ONLINE_REPO_OUT_DIR}

                    COMMAND $ENV{QTIFWDIR}/bin/binarycreator.exe -t $ENV{QTIFWDIR}/bin/installerbase.exe
                        --online-only -p ${CMAKE_BINARY_DIR}/installer/packages/
                        -c ${CMAKE_BINARY_DIR}/installer/config/config.xml
                        "${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}Installer.exe"
                    )
            else()
                add_custom_target(makeInstaller ALL
                    DEPENDS qtComponent maintenancetool maintenancetoolUpdate guiComponent # And other components if any
                    COMMAND $ENV{QTIFWDIR}/bin/binarycreator.exe -t $ENV{QTIFWDIR}/bin/installerbase.exe
                        --offline-only -p ${CMAKE_BINARY_DIR}/installer/packages/
                        -c ${CMAKE_BINARY_DIR}/installer/config/config.xml
                        "${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}Installer.exe"
                    )
            endif()
        else()
            message("Unable to find ${QTDIR}/bin/windeployqt.exe")
        endif()
    else()
        message("\nIf you want to enable target package you can:")
        message("\t* Either pass -DCPACK_IFW_ROOT=<path> to cmake")
        message("\t* Or set the environment variable QTIFWDIR")
        message("To specify the location of the QtIFW tool suite.")
        message("The specified path should not contain 'bin' at the end.\n")
    endif()
endif()
