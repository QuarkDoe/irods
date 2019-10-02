#====================
#irods_server library
#====================

include(irods_libirods_server_sources)

add_library(
	irods_server
	SHARED
	${IRODS_LIBIRODS_SERVER_SOURCES}
	${IRODS_LIBIRODS_CLIENT_SOURCES}
)

target_link_libraries(
	irods_server
	PRIVATE
	irods_common
	irods_plugin_dependencies
	${AVROCPP_LIBRARIES}
	${Boost_CHRONO_LIBRARY}
	${Boost_FILESYSTEM_LIBRARY}
	${Boost_THREAD_LIBRARY}
	${Boost_REGEX_LIBRARY}
	${Boost_SYSTEM_LIBRARY}
	${JANSSON_LIBRARIES}
	${ZEROMQ_LIBRARIES}
	${OPENSSL_SSL_LIBRARY}
	${OPENSSL_CRYPTO_LIBRARY}
	${CMAKE_DL_LIBS}
	rt
	${CMAKE_THREAD_LIBS_INIT}
)

target_include_directories(
	irods_server
	PRIVATE
	${CMAKE_BINARY_DIR}/lib/core/include
	${IRODS_SOURCE_DIR}/lib/api/include
	${IRODS_SOURCE_DIR}/lib/core/include
	${IRODS_SOURCE_DIR}/lib/hasher/include
	${IRODS_SOURCE_DIR}/lib/rbudp/include
	${IRODS_SOURCE_DIR}/lib/filesystem/include
	${IRODS_SOURCE_DIR}/server/api/include
	${IRODS_SOURCE_DIR}/server/core/include
	${IRODS_SOURCE_DIR}/server/drivers/include
	${IRODS_SOURCE_DIR}/server/icat/include
	${IRODS_SOURCE_DIR}/server/re/include
	${AVROCPP_INCLUDE_DIR}
	${Boost_INCLUDE_DIRS}
	${JANSSON_INCLUDE_DIRS}
	${ZEROMQ_INCLUDE_DIRS}
	${OPENSSL_INCLUDE_DIR}
)

set_property( TARGET irods_server PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
set_property( TARGET irods_server PROPERTY VERSION ${IRODS_VERSION} )
set_property( TARGET irods_server PROPERTY SOVERSION ${IRODS_VERSION} )
target_compile_definitions( irods_server PRIVATE ENABLE_RE RODS_CLERVER ${IRODS_COMPILE_DEFINITIONS} )
target_compile_options( irods_server PRIVATE -Wno-write-strings )

install(
	TARGETS irods_server
	EXPORT IRODSTargets
	LIBRARY
	DESTINATION ${IRODS_LIBRARY_DIR}
	COMPONENT irods-runtime
)
