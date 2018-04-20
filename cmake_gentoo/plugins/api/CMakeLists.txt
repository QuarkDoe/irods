find_package( OpenSSL REQUIRED )

set(
	IRODS_API_PLUGIN_SOURCES_helloworld_server
	${IRODS_SOURCE_DIR}/plugins/api/src/helloworld.cpp
)

set(
	IRODS_API_PLUGIN_SOURCES_helloworld_client
	${IRODS_SOURCE_DIR}/plugins/api/src/helloworld.cpp
)

set(
	IRODS_API_PLUGIN_COMPILE_DEFINITIONS_helloworld_server
	RODS_SERVER
	ENABLE_RE
)

set(
	IRODS_API_PLUGIN_COMPILE_DEFINITIONS_helloworld_client
)

set(
	IRODS_API_PLUGIN_LINK_LIBRARIES_helloworld_server
	irods_server
)

set(
	IRODS_API_PLUGIN_LINK_LIBRARIES_helloworld_client
	irods_client
)

set(
	IRODS_API_PLUGINS
	helloworld_server
	helloworld_client
)

foreach( PLUGIN ${IRODS_API_PLUGINS} )
	add_library(
		${PLUGIN}
		MODULE
		${IRODS_API_PLUGIN_SOURCES_${PLUGIN}}
	)

	target_include_directories(
		${PLUGIN}
		PRIVATE
		${CMAKE_BINARY_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/api/include
		${IRODS_SOURCE_DIR}/server/drivers/include
		${IRODS_SOURCE_DIR}/server/core/include
		${IRODS_SOURCE_DIR}/server/icat/include
		${IRODS_SOURCE_DIR}/server/re/include
		${Boost_INCLUDE_DIRS}
		${JANSSON_INCLUDE_DIRS}
		${LIBARCHIVE_INCLUDE_DIRS}
		${OPENSSL_INCLUDE_DIR}
	)

	target_link_libraries(
		${PLUGIN}
		PRIVATE
		${IRODS_API_PLUGIN_LINK_LIBRARIES_${PLUGIN}}
		irods_plugin_dependencies
		irods_common
		${Boost_FILESYSTEM_LIBRARY}
		${Boost_SYSTEM_LIBRARY}
		${JANSSON_LIBRARIES}
		${LIBARCHIVE_LIBRARIES}
		${OPENSSL_CRYPTO_LIBRARY}
	)

	target_compile_definitions( ${PLUGIN} PRIVATE ${IRODS_API_PLUGIN_COMPILE_DEFINITIONS_${PLUGIN}} ${IRODS_COMPILE_DEFINITIONS} )
	target_compile_options( ${PLUGIN} PRIVATE -Wno-write-strings )
	set_property( TARGET ${PLUGIN} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
endforeach()

install(
	TARGETS ${IRODS_API_PLUGINS}
	LIBRARY
	DESTINATION ${IRODS_PLUGINS_DIRECTORY}/api
	COMPONENT irods-server
	# COMPONENT ${IRODS_PACKAGE_COMPONENT_SERVER_NAME}
)
