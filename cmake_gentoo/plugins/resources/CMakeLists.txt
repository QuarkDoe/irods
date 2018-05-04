find_package(OpenSSL REQUIRED)

set(
	IRODS_RESOURCE_PLUGIN_COMPOUND_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/compound/libcompound.cpp
)
set(
	IRODS_RESOURCE_PLUGIN_DEFERRED_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/deferred/libdeferred.cpp
)
set(
	IRODS_RESOURCE_PLUGIN_LOAD_BALANCED_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/load_balanced/libload_balanced.cpp
)
set(
	IRODS_RESOURCE_PLUGIN_MOCKARCHIVE_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/mockarchive/libmockarchive.cpp
)
set(
	IRODS_RESOURCE_PLUGIN_NONBLOCKING_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/nonblocking/libnonblocking.cpp
)
set(
	IRODS_RESOURCE_PLUGIN_PASSTHRU_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/passthru/libpassthru.cpp
)
set(
	IRODS_RESOURCE_PLUGIN_RANDOM_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/random/librandom.cpp
)
set(IRODS_RESOURCE_PLUGIN_REPLICATION_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/replication/irods_create_write_replicator.cpp
	${IRODS_SOURCE_DIR}/plugins/resources/replication/irods_object_oper.cpp
	${IRODS_SOURCE_DIR}/plugins/resources/replication/irods_replicator.cpp
	${IRODS_SOURCE_DIR}/plugins/resources/replication/irods_repl_rebalance.cpp
	${IRODS_SOURCE_DIR}/plugins/resources/replication/irods_repl_retry.cpp	
	${IRODS_SOURCE_DIR}/plugins/resources/replication/irods_unlink_replicator.cpp
	${IRODS_SOURCE_DIR}/plugins/resources/replication/librepl.cpp
)
set(
	IRODS_RESOURCE_PLUGIN_ROUNDROBIN_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/roundrobin/libroundrobin.cpp
)
set(
	IRODS_RESOURCE_PLUGIN_STRUCTFILE_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/structfile/libstructfile.cpp
)
set(
	IRODS_RESOURCE_PLUGIN_UNIVMSS_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/univmss/libunivmss.cpp
)
set(
	IRODS_RESOURCE_PLUGIN_UNIXFILESYSTEM_SOURCES
	${IRODS_SOURCE_DIR}/plugins/resources/unixfilesystem/libunixfilesystem.cpp
)
set(
	IRODS_RESOURCE_PLUGINS
	compound
	deferred
	load_balanced
	mockarchive
	nonblocking
	passthru
	random
	replication
	roundrobin
	structfile
	univmss
	unixfilesystem
)

foreach(PLUGIN ${IRODS_RESOURCE_PLUGINS})
	string(TOUPPER ${PLUGIN} PLUGIN_UPPERCASE)

	add_library(
		${PLUGIN}
		MODULE
		${IRODS_RESOURCE_PLUGIN_${PLUGIN_UPPERCASE}_SOURCES}
	)

	target_include_directories(
		${PLUGIN}
		PRIVATE
		${CMAKE_BINARY_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/api/include
		${IRODS_SOURCE_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/server/api/include
		${IRODS_SOURCE_DIR}/server/core/include
		${IRODS_SOURCE_DIR}/server/drivers/include
		${IRODS_SOURCE_DIR}/server/icat/include
		${IRODS_SOURCE_DIR}/server/re/include
		${LIBARCHIVE_INCLUDE_DIRS}
		${Boost_INCLUDE_DIRS}
		${JANSSON_INCLUDE_DIRS}
		${OPENSSL_INCLUDE_DIR}
	)

	target_link_libraries(
		${PLUGIN}
		PRIVATE
		irods_server
		irods_common
		${LIBARCHIVE_LIBRARIES}
		${Boost_FILESYSTEM_LIBRARY}
		${Boost_SYSTEM_LIBRARY}
		${JANSSON_LIBRARIES}
		${OPENSSL_CRYPTO_LIBRARY}
	)

	target_compile_definitions( ${PLUGIN} PRIVATE ENABLE_RE ${IRODS_COMPILE_DEFINITIONS} )
	target_compile_options( ${PLUGIN} PRIVATE -Wno-write-strings )
	set_property( TARGET ${PLUGIN} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
endforeach()

install(
	TARGETS
	${IRODS_RESOURCE_PLUGINS}
	LIBRARY
	DESTINATION ${IRODS_PLUGINS_DIRECTORY}/resources
	COMPONENT irods-server
	# COMPONENT ${IRODS_PACKAGE_COMPONENT_SERVER_NAME}
)
