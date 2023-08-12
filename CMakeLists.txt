cmake_minimum_required(VERSION 3.24)

# Setting project information
set(PROJECT_NAME "TemplateProject")
set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 1)
set(PROJECT_VERSION_PATCH 0)
set(PROJECT_VERSION_TWEAK 0)
if (PROJECT_VERSION_TWEAK EQUAL 0)
    set(PROJECT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})
else()
    set(PROJECT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}.${PROJECT_VERSION_TWEAK})
endif()
set(PROJECT_VERSION_TYPE "alpha")
set(PROJECT_LICENSE_TYPE "MIT")
set(PROJECT_CREATOR "Alireza Hasani")
set(PROJECT_LANGUAGES "CXX")
set(PROJECT_DESCRIPTION "")
set(PROJECT_HOMEPAGE_URL "")

configure_file(${CMAKE_SOURCE_DIR}/config/config.h.in
    ${CMAKE_BINARY_DIR}/config.h
    @ONLY
)

project(${PROJECT_NAME} VERSION ${PROJECT_VERSION} LANGUAGES ${PROJECT_LANGUAGES})

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Setting application Icon
# set(APP_ICON_RESOURCE_WINDOWS PATH)

set(QML_IMPORT_PATH
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/ui
    ${CMAKE_BINARY_DIR}/imports
    ${CMAKE_BINARY_DIR}/external
    CACHE STRING "" FORCE
)

# Uncomment following if MSVC and resources are big
# if(MSVC)
#     add_compile_options(/bigobj)
# endif()

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Quick)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_resources(PROJECT_RESOURCES
    ui/res.qrc
)

qt_add_executable(${PROJECT_NAME}App
    src/main.cpp
    ${CMAKE_BINARY_DIR}/config.h
    ${PROJECT_RESOURCES}
)

qt_add_qml_module(${PROJECT_NAME}App
    URI ${PROJECT_NAME}
    VERSION 1.0
    RESOURCES # Mainly internal qmldir files

    QML_FILES
        ui/qml/Main.qml
)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    # Expose ui/ folder path in source directory to app for adding to QmlImportPath
    target_compile_definitions(${PROJECT_NAME}App PRIVATE
        QML_UI_ROOT="${CMAKE_SOURCE_DIR}/ui"
    )
endif()

# Adding submodules
add_subdirectory(external/QmlHttpRequest)
add_subdirectory(external/QMdi)

target_include_directories(${PROJECT_NAME}App PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
)

set_target_properties(${PROJECT_NAME}App PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(${PROJECT_NAME}App PRIVATE
    Qt6::Quick
    Qt6::Core
)

install(TARGETS ${PROJECT_NAME}App
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Create Windows installer if its Windows
if(WIN32)
    include("${CMAKE_SOURCE_DIR}/cmake/config-win-installer.cmake")
endif()
