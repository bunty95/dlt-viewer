# set properties for the bundle Info.plist file
set(MACOSX_BUNDLE_EXECUTABLE_NAME "dlt-viewer")
set(MACOSX_BUNDLE_INFO_STRING "DLT Viewer")
set(MACOSX_BUNDLE_SHORT_VERSION_STRING "${DLT_PROJECT_VERSION_MAJOR}.${DLT_PROJECT_VERSION_MINOR}.${DLT_PROJECT_VERSION_PATCH}")
set(MACOSX_BUNDLE_BUNDLE_VERSION "${MACOSX_BUNDLE_SHORT_VERSION_STRING}")
set(MACOSX_BUNDLE_LONG_VERSION_STRING "${MACOSX_BUNDLE_SHORT_VERSION_STRING}-${DLT_VERSION_SUFFIX}")
set(MACOSX_BUNDLE_BUNDLE_NAME "DLT Viewer")
set(MACOSX_BUNDLE_GUI_IDENTIFIER "dhillonengineering.dlt-viewer")
set(MACOSX_BUNDLE_ICON_FILE icon)
set(MACOSX_BUNDLE_COPYRIGHT "Copyright (C) 2024")

install(FILES
    resources/icon/icon.icns
    DESTINATION "${DLT_RESOURCE_INSTALLATION_PATH}"
    COMPONENT dlt_viewer)

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/../scripts/darwin/Info.plist.in" "${CMAKE_BINARY_DIR}/Info.plist" @ONLY)
install(PROGRAMS
  "${CMAKE_BINARY_DIR}/Info.plist"
  DESTINATION "${DLT_EXECUTABLE_INSTALLATION_PATH}/.."
  COMPONENT dlt_viewer)

# COMMAND ${MAC_DEPLOY_TOOL} $<TARGET_FILE_DIR:dlt-viewer>/../.. -always-overwrite

# # enable high-DPI displays support
# add_custom_command(TARGET dlt-viewer POST_BUILD
#   COMMAND plutil -replace NSPrincipalClass -string NSApplication $<TARGET_FILE_DIR:dlt-viewer>/../Info.plist
#   COMMAND plutil -replace NSHighResolutionCapable -bool true $<TARGET_FILE_DIR:dlt-viewer>/../Info.plist)
