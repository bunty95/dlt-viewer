if(NOT APPLE)
    return()
endif()

# See build.sh and src/cmake/Darwin.cmake
set(CPACK_GENERATOR External)

get_target_property(qmake_executable Qt${QT_VERSION_MAJOR}::qmake IMPORTED_LOCATION)
get_filename_component(qt_bin_dir "${qmake_executable}" DIRECTORY)
find_program(MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${qt_bin_dir}")

# get_target_property(MOC_LOCATION ${QT_PREFIX}::Core LOCATION)
# get_filename_component(MACDEPLOYQT_EXECUTABLE ${MOC_LOCATION}/../../../bin/macdeployqt ABSOLUTE)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/darwin/macdeployqt.cmake.in" "${CMAKE_BINARY_DIR}/macdeployqt.cmake" @ONLY)

set(CPACK_EXTERNAL_PACKAGE_SCRIPT "${CMAKE_BINARY_DIR}/macdeployqt.cmake")

# Must be last
include(CPack)
