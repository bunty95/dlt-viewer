# SPDX-License-Identifier: MPL-2.0
#
# Copyright (C) 2016, Jack S. Smith
#
# This file is part of COVESA DLT-Viewer project.
#
# This Source Code Form is subject to the terms of the
# Mozilla Public License (MPL), v. 2.0.
# If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# For further information see http://www.covesa.global/.
#
# List of changes:
# 01.Oct.2016, Jack Smith <jack.smith@elektrobit.com>, Original Author

cmake_minimum_required (VERSION 3.15)
# implicitly calls version checks
include(scripts/windows/version.cmake)
include(scripts/linux/version.cmake)

project(dlt-viewer
    VERSION ${DLT_PROJECT_VERSION_MAJOR}.${DLT_PROJECT_VERSION_MINOR}.${DLT_PROJECT_VERSION_PATCH}
    DESCRIPTION "DLT Viewer")
message(STATUS "DLT Viewer version: ${DLT_PROJECT_VERSION_MAJOR}.${DLT_PROJECT_VERSION_MINOR}.${DLT_PROJECT_VERSION_PATCH}-${DLT_VERSION_SUFFIX}")

file(WRITE "${CMAKE_BINARY_DIR}/version.txt" "${DLT_PROJECT_VERSION_MAJOR}.${DLT_PROJECT_VERSION_MINOR}.${DLT_PROJECT_VERSION_PATCH}")
file(WRITE "${CMAKE_BINARY_DIR}/full_version.txt" "${DLT_PROJECT_VERSION_MAJOR}.${DLT_PROJECT_VERSION_MINOR}.${DLT_PROJECT_VERSION_PATCH}-${DLT_VERSION_SUFFIX}")

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    set(LINUX TRUE)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_C_STANDARD 11)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

set (CMAKE_AUTOMOC ON)
set (CMAKE_AUTOUIC ON)
set (CMAKE_AUTORCC ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Ensure Qt 6 is being used
find_package(Qt6 REQUIRED COMPONENTS Core Widgets Network Gui)

# Get Qt library paths for RPATH settings
get_target_property(DLT_QT_LIBRARY_PATH Qt6::Core LOCATION)
get_filename_component(DLT_QT_LIB_DIR ${DLT_QT_LIBRARY_PATH} DIRECTORY)

if(NOT WIN32)
    option(DLT_USE_QT_RPATH "Use RPATH for QT_LIBRARY_PATH to support non-standard QT install locations" ON)
    if (DLT_USE_QT_RPATH)
        # Add Qt to the RPATH, so that there is no need to set LD_LIBRARY_PATH at runtime if Qt is installed in a non-standard location
        set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH};${DLT_QT_LIB_DIR}")
    endif()
endif()

# Injection of the GCC-specific compilation flags
if(CMAKE_COMPILER_IS_GNUCXX)
    message(STATUS "GCC detected, adding compile flags")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic -Wno-variadic-macros -Wno-strict-aliasing -fPIC")
endif()

# Define Qt6 compatibility
add_compile_definitions(QT6)

# Remove any Qt5 compatibility code
# This is specific to Qt 6 and does not include older Qt versions
set(QT6_VERSION "6.0")

option(DLT_USE_STANDARD_INSTALLATION_LOCATION "Use standard GNU installation locations" OFF)
option(DLT_INSTALL_SDK "Install in SDK location" ON)
if(NOT WIN32)
    if(NOT DLT_APP_DIR

