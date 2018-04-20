set(
	IRODS_MICROSERVICE_ADMINISTRATION_PLUGINS
	msisync_to_archive
	msi_update_unixfilesystem_resource_free_space
)

foreach( PLUGIN ${IRODS_MICROSERVICE_ADMINISTRATION_PLUGINS} )
	add_library(
		${PLUGIN}
		MODULE
		${IRODS_SOURCE_DIR}/plugins/microservices/administration/${PLUGIN}/lib${PLUGIN}.cpp
	)

	target_include_directories(
		${PLUGIN}
		PRIVATE
		${CMAKE_BINARY_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/api/include
		${IRODS_SOURCE_DIR}/server/drivers/include
		${IRODS_SOURCE_DIR}/server/api/include
		${IRODS_SOURCE_DIR}/server/core/include
		${IRODS_SOURCE_DIR}/server/icat/include
		${IRODS_SOURCE_DIR}/server/re/include
		${Boost_INCLUDE_DIRS}
		# ${JANSSON_INCLUDE_DIRS}
		${CURL_INCLUDE_DIRS}
	)

	target_link_libraries(
		${PLUGIN}
		PRIVATE
		irods_server
		irods_common
		${Boost_FILESYSTEM_LIBRARY}
		${Boost_SYSTEM_LIBRARY}
		# ${JANSSON_LIBRARIES}
		${CURL_LIBRARIES}
	)

	target_compile_definitions( ${PLUGIN} PRIVATE ENABLE_RE ${IRODS_COMPILE_DEFINITIONS} )
	target_compile_options( ${PLUGIN} PRIVATE -Wno-write-strings )
	set_property( TARGET ${PLUGIN} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
endforeach()

install(
	TARGETS ${IRODS_MICROSERVICE_ADMINISTRATION_PLUGINS}
	LIBRARY
	DESTINATION ${IRODS_PLUGINS_DIRECTORY}/microservices
	COMPONENT irods-server
	# COMPONENT ${IRODS_PACKAGE_COMPONENT_SERVER_NAME}
)
