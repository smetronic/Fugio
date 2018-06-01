
find_package( Qt5
	COMPONENTS Core Concurrent Gui OpenGL Network Widgets
	OPTIONAL_COMPONENTS SerialPort WebSockets QuickWidgets QuickControls2 Quick Qml LinguistTools
	QUIET )

target_link_libraries( ${PROJECT_NAME} Qt5::Core Qt5::Concurrent Qt5::Gui Qt5::Network Qt5::OpenGL Qt5::Widgets )

if( Qt5SerialPort_DIR )
	message( "Qt5::SerialPort: YES" )
	target_link_libraries( ${PROJECT_NAME} Qt5::SerialPort )
endif()

if( Qt5Qml_DIR )
	message( "Qt5::Qml: YES" )
	target_link_libraries( ${PROJECT_NAME} Qt5::Qml )
endif()

if( Qt5Quick_DIR )
	message( "Qt5::Quick: YES" )
	target_link_libraries( ${PROJECT_NAME} Qt5::Quick )
endif()

if( Qt5QuickControls2_DIR )
	message( "Qt5::QuickControls2: YES" )
	target_link_libraries( ${PROJECT_NAME} Qt5::QuickControls2 )
endif()

if( Qt5QuickWidgets_DIR )
	message( "Qt5::QuickWidgets: YES" )
	target_link_libraries( ${PROJECT_NAME} Qt5::QuickWidgets )
endif()

if( Qt5WebSockets_DIR )
	message( "Qt5::WebSockets: YES" )
	target_link_libraries( ${PROJECT_NAME} Qt5::WebSockets )
endif()

# Retrieve the absolute path to qmake and then use that path to find
# the binaries
get_target_property(_qmake_executable Qt5::qmake IMPORTED_LOCATION)
get_filename_component(_qt_bin_dir "${_qmake_executable}" DIRECTORY)

if( WIN32 AND CMAKE_BUILD_TYPE STREQUAL Release )
	find_program( WINDEPLOYQT_EXECUTABLE windeployqt HINTS "${_qt_bin_dir}" )

	get_filename_component( ABS_BINARY_DIR "${CMAKE_INSTALL_PREFIX}" REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")

	add_custom_command( TARGET ${PROJECT_NAME} POST_BUILD
		COMMAND "${WINDEPLOYQT_EXECUTABLE}"
			--compiler-runtime
			--concurrent --opengl --serialport --websockets --no-angle --no-opengl-sw --force --verbose 2
			--qmldir "${CMAKE_SOURCE_DIR}/qml"
			--dir "${ABS_BINARY_DIR}/${PATH_APP}"
			--libdir "${ABS_BINARY_DIR}/${PATH_APP}"
			--plugindir "${ABS_BINARY_DIR}/${PATH_APP}"
			$<TARGET_FILE:${PROJECT_NAME}>
		COMMENT "Running windeployqt on $<TARGET_FILE:${PROJECT_NAME}>"
	)
endif()

if( APPLE AND CMAKE_BUILD_TYPE STREQUAL Release )

	find_program( MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${_qt_bin_dir}" )

	set_target_properties( ${PROJECT_NAME} PROPERTIES INSTALL_RPATH “@loader_path/../Frameworks” )

	add_custom_command( TARGET ${PROJECT_NAME} POST_BUILD
		COMMAND "${MACDEPLOYQT_EXECUTABLE}"
			"$<TARGET_FILE_DIR:${PROJECT_NAME}>/../.."
			-always-overwrite
			-qmldir=${CMAKE_SOURCE_DIR}/qml
		COMMENT "Running macdeployqt..."
	)

endif()

