#====================
#irods_client library
#====================

include(irods_libirods_client_sources)

add_library(
	irods_client
	SHARED
	${IRODS_LIBIRODS_CLIENT_SOURCES}
)

target_link_libraries(
	irods_client
	PRIVATE
	irods_plugin_dependencies
	irods_common
	${Boost_CHRONO_LIBRARY}
	${Boost_FILESYSTEM_LIBRARY}
	${Boost_REGEX_LIBRARY}
	${Boost_SYSTEM_LIBRARY}
	${Boost_THREAD_LIBRARY}
	${JANSSON_LIBRARIES}
	${OPENSSL_SSL_LIBRARY}
	${OPENSSL_CRYPTO_LIBRARY}
	${CMAKE_THREAD_LIBS_INIT}
)

target_include_directories(
	irods_client
	PRIVATE
	${CMAKE_BINARY_DIR}/lib/core/include
	${IRODS_SOURCE_DIR}/lib/core/include
	${IRODS_SOURCE_DIR}/lib/api/include
	${IRODS_SOURCE_DIR}/lib/hasher/include
	${IRODS_SOURCE_DIR}/lib/rbudp/include
	${IRODS_SOURCE_DIR}/lib/filesystem/include
	${IRODS_SOURCE_DIR}/server/core/include
	${IRODS_SOURCE_DIR}/server/icat/include
	${IRODS_SOURCE_DIR}/server/re/include
	${IRODS_SOURCE_DIR}/server/drivers/include
	${Boost_INCLUDE_DIRS}
	${JANSSON_INCLUDE_DIRS}
	${OPENSSL_INCLUDE_DIR}
)

set_property( TARGET irods_client PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
set_property( TARGET irods_client PROPERTY VERSION ${IRODS_VERSION} )
set_property( TARGET irods_client PROPERTY SOVERSION ${IRODS_VERSION} )
target_compile_options( irods_client PRIVATE -Wno-write-strings )
target_compile_definitions( irods_client PRIVATE ${IRODS_COMPILE_DEFINITIONS} )

install(
	TARGETS irods_client
	EXPORT IRODSTargets
	LIBRARY
	DESTINATION ${IRODS_LIBRARY_DIR}
	COMPONENT irods-runtime
)
