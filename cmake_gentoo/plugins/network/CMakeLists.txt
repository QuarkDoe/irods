find_package(OpenSSL REQUIRED)

set(
	IRODS_NETWORK_PLUGIN_ssl_SOURCES
	${IRODS_SOURCE_DIR}/plugins/network/ssl/libssl.cpp
)

set(
	IRODS_NETWORK_PLUGIN_tcp_SOURCES
	${IRODS_SOURCE_DIR}/plugins/network/tcp/libtcp.cpp
)

set(
	IRODS_NETWORK_PLUGINS
	ssl
	tcp
)

set(
	IRODS_NETWORK_COMPILE_DEFINTIONS_client
)

set(
	IRODS_NETWORK_LINK_LIBRARIES_client
	irods_client
)

set(
	IRODS_NETWORK_PLUGIN_TYPES
	client
)

if( BUILD_SERVER )
	set( IRODS_NETWORK_COMPILE_DEFINITIONS_server ENABLE_RE )
	set( IRODS_NETWORK_LINK_LIBRARIES_server irods_server )
	list( APPEND IRODS_NETWORK_PLUGIN_TYPES server )
endif( BUILD_SERVER )

foreach(PLUGIN ${IRODS_NETWORK_PLUGINS})
	foreach(TYPE ${IRODS_NETWORK_PLUGIN_TYPES})
		set(IRODS_CURRENT_PLUGIN_TARGET ${PLUGIN}_${TYPE})

		add_library(
			${IRODS_CURRENT_PLUGIN_TARGET}
			MODULE
			${IRODS_NETWORK_PLUGIN_${PLUGIN}_SOURCES}
		)

		target_include_directories(
			${IRODS_CURRENT_PLUGIN_TARGET}
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
			${IRODS_CURRENT_PLUGIN_TARGET}
			PRIVATE
			${IRODS_NETWORK_LINK_LIBRARIES_${TYPE}}
			irods_plugin_dependencies
			irods_common
			${Boost_FILESYSTEM_LIBRARY}
			${Boost_SYSTEM_LIBRARY}
			${LIBARCHIVE_LIBRARIES}
			${OPENSSL_CRYPTO_LIBRARY}
			${OPENSSL_SSL_LIBRARY}
		)

		target_compile_definitions( ${IRODS_CURRENT_PLUGIN_TARGET} PRIVATE ${IRODS_NETWORK_COMPILE_DEFINTIONS_${TYPE}} ${IRODS_COMPILE_DEFINITIONS} )
		target_compile_options( ${IRODS_CURRENT_PLUGIN_TARGET} PRIVATE -Wno-write-strings )
		set_property( TARGET ${IRODS_CURRENT_PLUGIN_TARGET} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )

		install(
			TARGETS
			${IRODS_CURRENT_PLUGIN_TARGET}
			LIBRARY
			DESTINATION ${IRODS_PLUGINS_DIRECTORY}/network
			COMPONENT irods-runtime
			# COMPONENT ${IRODS_PACKAGE_COMPONENT_RUNTIME_NAME}
		)

	endforeach()
endforeach()
