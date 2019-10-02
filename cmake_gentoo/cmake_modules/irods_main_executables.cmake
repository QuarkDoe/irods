#====================
#
#====================

include(irods_main_executable_irodsserver_sources)

include(irods_main_executable_irodsxmsgserver_sources)

include(irods_main_executable_hostname_resolves_to_local_address_sources)

set(
	IRODS_MAIN_EXECUTABLES
	#  irodsAgent
	irodsServer
	irodsXmsgServer
	hostname_resolves_to_local_address
)

foreach( EXECUTABLE ${IRODS_MAIN_EXECUTABLES} )

	string( TOUPPER ${EXECUTABLE} EXECUTABLE_UPPERCASE )

	add_executable(
		${EXECUTABLE}
		${IRODS_MAIN_EXECUTABLE_${EXECUTABLE_UPPERCASE}_SOURCES}
	)

	target_include_directories(
		${EXECUTABLE}
		PRIVATE
		${IRODS_SOURCE_DIR}/server/re/include
		${IRODS_SOURCE_DIR}/server/core/include
		${IRODS_SOURCE_DIR}/server/drivers/include
		${IRODS_SOURCE_DIR}/server/icat/include
		${CMAKE_BINARY_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/hasher/include
		${IRODS_SOURCE_DIR}/lib/api/include
		${IRODS_SOURCE_DIR}/lib/rbudp/include
		${Boost_INCLUDE_DIRS}
		${JANSSON_INCLUDE_DIRS}
		${AVROCPP_INCLUDE_DIR}
		${ZEROMQ_INCLUDE_DIRS}
		${OPENSSL_INCLUDE_DIR}
	)

	target_link_libraries(
		${EXECUTABLE}
		PRIVATE
		irods_common
		irods_plugin_dependencies
		irods_server
		${Boost_SYSTEM_LIBRARY}
		${Boost_FILESYSTEM_LIBRARY}
		${Boost_REGEX_LIBRARY}
		${Boost_THREAD_LIBRARY}
		${Boost_CHRONO_LIBRARY}
		${JANSSON_LIBRARIES}
		${AVROCPP_LIBRARIES}
		${ZEROMQ_LIBRARIES}
		${OPENSSL_CRYPTO_LIBRARY}
		${OPENSSL_SSL_LIBRARY}
		rt
		${CMAKE_THREAD_LIBS_INIT}
		${CMAKE_DL_LIBS}
		m
	)

	set_property( TARGET ${EXECUTABLE} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
	target_compile_definitions( ${EXECUTABLE} PRIVATE ENABLE_RE ${IRODS_COMPILE_DEFINITIONS} )
	target_compile_options( ${EXECUTABLE} PRIVATE -Wno-write-strings )

endforeach()

add_executable(
	irodsReServer
	${IRODS_SOURCE_DIR}/server/core/src/irodsReServer.cpp
)

target_link_libraries(
	irodsReServer
	PRIVATE
	irods_server
	irods_client
	irods_common
	irods_plugin_dependencies
	${Boost_SYSTEM_LIBRARY}
	${Boost_FILESYSTEM_LIBRARY}
	${Boost_REGEX_LIBRARY}
	${Boost_THREAD_LIBRARY}
	${Boost_CHRONO_LIBRARY}
	${JANSSON_LIBRARIES}
	${AVROCPP_LIBRARIES}
	${ZEROMQ_LIBRARIES}
	${OPENSSL_CRYPTO_LIBRARY}
	${OPENSSL_SSL_LIBRARY}
	rt
	${CMAKE_THREAD_LIBS_INIT}
	${CMAKE_DL_LIBS}
	m
)

target_include_directories(
	irodsReServer
	PRIVATE
	${IRODS_SOURCE_DIR}/server/re/include
	${IRODS_SOURCE_DIR}/server/core/include
	${IRODS_SOURCE_DIR}/server/drivers/include
	${IRODS_SOURCE_DIR}/server/icat/include
	${CMAKE_BINARY_DIR}/lib/core/include
	${IRODS_SOURCE_DIR}/lib/core/include
	${IRODS_SOURCE_DIR}/lib/hasher/include
	${IRODS_SOURCE_DIR}/lib/api/include
	${IRODS_SOURCE_DIR}/lib/rbudp/include
	${Boost_INCLUDE_DIRS}
	${JANSSON_INCLUDE_DIRS}
	${AVROCPP_INCLUDE_DIR}
	${ZEROMQ_INCLUDE_DIRS}
	${OPENSSL_INCLUDE_DIR}
)
set_property( TARGET irodsReServer PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
target_compile_definitions( irodsReServer PRIVATE ${IRODS_COMPILE_DEFINITIONS} )
target_compile_options( irodsReServer PRIVATE -Wno-write-strings )

add_executable(
	irodsPamAuthCheck
	${IRODS_SOURCE_DIR}/server/auth/src/irodsPamAuthCheck.cpp
)

target_link_libraries(
	irodsPamAuthCheck
	PRIVATE
	${PAM_LIBRARY}
)

set_property( TARGET irodsPamAuthCheck PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )

add_executable(
	genOSAuth
	${IRODS_SOURCE_DIR}/server/auth/src/genOSAuth.cpp
)

target_include_directories(
	genOSAuth
	PRIVATE
	${IRODS_SOURCE_DIR}/lib/core/include
	${IRODS_SOURCE_DIR}/server/core/include
	${IRODS_SOURCE_DIR}/server/icat/include
	${IRODS_SOURCE_DIR}/lib/api/include
	${CMAKE_BINARY_DIR}/lib/core/include
)

target_link_libraries(
	genOSAuth
	PRIVATE
	irods_client
	irods_plugin_dependencies
	irods_common
	${AVROCPP_LIBRARIES}
	${Boost_FILESYSTEM_LIBRARY}
	${Boost_THREAD_LIBRARY}
	${Boost_REGEX_LIBRARY}
	${JANSSON_LIBRARIES}
	${ZEROMQ_LIBRARIES}
)

set_property( TARGET genOSAuth PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
target_compile_definitions( genOSAuth PRIVATE ${IRODS_COMPILE_DEFINITIONS} )
target_compile_options( genOSAuth PRIVATE -Wno-write-strings )

install(
	TARGETS
	irodsServer
	irodsReServer
	irodsXmsgServer
	hostname_resolves_to_local_address
	RUNTIME
	DESTINATION ${IRODS_SBIN_DIR}
	COMPONENT irods-server
)

install(
	TARGETS
	irodsPamAuthCheck
	RUNTIME
	DESTINATION ${IRODS_SBIN_DIR}
	COMPONENT irods-server
	PERMISSIONS SETUID OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
)

install(
	TARGETS
	genOSAuth
	RUNTIME
	DESTINATION ${IRODS_HOME_DIR}/clients/bin
	COMPONENT irods-server
)
