if(NOT APPLE)
    return()
endif()

# See build.sh and src/cmake/Darwin.cmake
set(CPACK_GENERATOR External)

get_target_property(qmake_executable Qt6::qmake IMPORTED_LOCATION)
get_filename_component(_qt_bin_dir "${qmake_executable}" DIRECTORY)
find_program(MACDEPLOYQT_BIN macdeployqt HINT "${_qt_bin_dir}")

# Link Qt dependencies to TestTarget.app bundle
add_custom_command(TARGET ${DLT_APP_DIR_NAME} POST_BUILD
        COMMAND ${MACDEPLOYQT_BIN} ${BUNDLE_NAME} -always-overwrite
)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/darwin/macdeployqt.cmake.in" "${CMAKE_BINARY_DIR}/macdeployqt.cmake" @ONLY)

set(CPACK_EXTERNAL_PACKAGE_SCRIPT "${CMAKE_BINARY_DIR}/macdeployqt.cmake")

# Must be last
include(CPack)
