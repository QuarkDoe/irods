find_package(OpenSSL REQUIRED)

set(
	IRODS_AUTH_PLUGIN_native_SOURCES
	${IRODS_SOURCE_DIR}/plugins/auth/native/libnative.cpp
)

set(
	IRODS_AUTH_PLUGIN_osauth_SOURCES
	${IRODS_SOURCE_DIR}/plugins/auth/osauth/libosauth.cpp
)

set(
	IRODS_AUTH_PLUGIN_pam_SOURCES
	${IRODS_SOURCE_DIR}/plugins/auth/pam/libpam.cpp
)

set(
	IRODS_AUTH_PLUGINS
	native
	osauth
	pam
)

set(
	IRODS_AUTH_PLUGIN_COMPILE_DEFINITIONS_client
)

set(
	IRODS_AUTH_PLUGIN_LINK_LIBRARIES_client
	irods_client
)

set(
	IRODS_AUTH_PLUGIN_TYPES
	client
)

if( BUILD_SERVER )
	set( IRODS_AUTH_PLUGIN_COMPILE_DEFINITIONS_server RODS_SERVER ENABLE_RE )
	set( IRODS_AUTH_PLUGIN_LINK_LIBRARIES_server irods_server )
	list( APPEND IRODS_AUTH_PLUGIN_TYPES server )
endif( BUILD_SERVER )

foreach( PLUGIN ${IRODS_AUTH_PLUGINS} )
	foreach( TYPE ${IRODS_AUTH_PLUGIN_TYPES} )
		set( IRODS_CURRENT_PLUGIN_TARGET ${PLUGIN}_${TYPE} )
		add_library(
			${IRODS_CURRENT_PLUGIN_TARGET}
			MODULE
			${IRODS_AUTH_PLUGIN_${PLUGIN}_SOURCES}
		)

		target_include_directories(
			${IRODS_CURRENT_PLUGIN_TARGET}
			PRIVATE
			${CMAKE_BINARY_DIR}/lib/core/include
			${IRODS_SOURCE_DIR}/lib/api/include
			${IRODS_SOURCE_DIR}/lib/core/include
			${IRODS_SOURCE_DIR}/server/api/include
			${IRODS_SOURCE_DIR}/server/core/include
			${IRODS_SOURCE_DIR}/server/drivers/include
			${IRODS_SOURCE_DIR}/server/icat/include
			${IRODS_SOURCE_DIR}/server/re/include
			${Boost_INCLUDE_DIRS}
			${JANSSON_INCLUDE_DIRS}
			${LIBARCHIVE_INCLUDE_DIRS}
			${OPENSSL_INCLUDE_DIR}
		)

		target_link_libraries(
			${IRODS_CURRENT_PLUGIN_TARGET}
			PRIVATE
			${IRODS_AUTH_PLUGIN_LINK_LIBRARIES_${TYPE}}
			irods_common
			irods_plugin_dependencies
			${Boost_FILESYSTEM_LIBRARY}
			${Boost_SYSTEM_LIBRARY}
			${JANSSON_LIBRARIES}
			${LIBARCHIVE_LIBRARIES}
			${OPENSSL_CRYPTO_LIBRARY}
		)

		target_compile_definitions( ${IRODS_CURRENT_PLUGIN_TARGET} PRIVATE ${IRODS_AUTH_PLUGIN_COMPILE_DEFINITIONS_${TYPE}} ${IRODS_COMPILE_DEFINITIONS} )
		target_compile_options( ${IRODS_CURRENT_PLUGIN_TARGET} PRIVATE -Wno-write-strings )
		set_property( TARGET ${IRODS_CURRENT_PLUGIN_TARGET} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )

		install(
			TARGETS
			${IRODS_CURRENT_PLUGIN_TARGET}
			LIBRARY
			DESTINATION ${IRODS_PLUGINS_DIRECTORY}/auth
			COMPONENT irods-runtime
			# COMPONENT ${IRODS_PACKAGE_COMPONENT_RUNTIME_NAME}
		)

	endforeach()
endforeach()
