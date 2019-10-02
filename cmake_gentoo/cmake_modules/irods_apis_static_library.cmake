#====================
#RodsAPIs library
#====================

include(irods_lib_core_sources)

include(irods_lib_api_sources)

include(irods_lib_rbudp_sources)

include(irods_lib_hasher_sources)

include(irods_lib_client_exec_sources)

add_library(
	RodsAPIs
	STATIC
	${IRODS_LIB_CORE_SOURCES}
	${IRODS_LIB_API_SOURCES}
	${IRODS_LIB_RBUDP_SOURCES}
	${IRODS_LIB_HASHER_SOURCES}
	${IRODS_LIB_CLIENT_EXEC_SOURCES}
	$<TARGET_OBJECTS:irods_filesystem_path>
	$<TARGET_OBJECTS:irods_filesystem_client>
)

target_include_directories(
	RodsAPIs
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

target_link_libraries(
	RodsAPIs
	PRIVATE
	${Boost_CHRONO_LIBRARY}
	${Boost_FILESYSTEM_LIBRARY}
	${Boost_REGEX_LIBRARY}
	${Boost_SYSTEM_LIBRARY}
	${Boost_THREAD_LIBRARY}
	${JANSSON_LIBRARIES}
	${OPENSSL_SSL_LIBRARY}
	${OPENSSL_CRYPTO_LIBRARY}
	${CMAKE_DL_LIBS}
)

set_property( TARGET RodsAPIs PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
target_compile_definitions( RodsAPIs PRIVATE ${IRODS_COMPILE_DEFINITIONS} )
target_compile_options( RodsAPIs PRIVATE -Wno-write-strings )

install(
	TARGETS
	RodsAPIs
	ARCHIVE
	DESTINATION ${IRODS_LIBRARY_DIR}
	COMPONENT irods-development
	# COMPONENT ${IRODS_PACKAGE_COMPONENT_DEVELOPMENT_NAME}
)

set(
	IRODS_GENERATED_HEADERS
	${CMAKE_BINARY_DIR}/lib/core/include/irods_version.h
	${CMAKE_BINARY_DIR}/lib/core/include/rodsVersion.h
	${CMAKE_BINARY_DIR}/lib/core/include/server_control_plane_command.hpp
)

include(irods_lib_core_include_headers)

include(irods_lib_hasher_include_headers)

include(irods_lib_api_include_headers)

include(irods_lib_rbudp_include_headers)

include(irods_server_api_include_headers)

include(irods_server_core_include_headers)

include(irods_server_icat_include_headers)

include(irods_server_re_include_headers)

include(irods_server_drivers_include_headers)

install(
	FILES
	${IRODS_GENERATED_HEADERS}
	${IRODS_LIB_CORE_INCLUDE_HEADERS}
	${IRODS_LIB_HASHER_INCLUDE_HEADERS}
	${IRODS_LIB_API_INCLUDE_HEADERS}
	${IRODS_LIB_RBUDP_INLUDE_HEADERS}
	${IRODS_SERVER_API_INCLUDE_HEADERS}
	${IRODS_SERVER_CORE_INCLUDE_HEADERS}
	${IRODS_SERVER_ICAT_INCLUDE_HEADERS}
	${IRODS_SERVER_RE_INCLUDE_HEADERS}
	${IRODS_SERVER_DRIVERS_INCLUDE_HEADERS}
	DESTINATION ${IRODS_INCLUDE_DIR}
	COMPONENT irods-development
)

install(
	EXPORT
	IRODSTargets
	DESTINATION ${IRODS_CMAKE_DIR}
	COMPONENT irods-development
)

include( CMakePackageConfigHelpers )

configure_package_config_file(
	${CMAKE_SOURCE_DIR}/cmake_config/IRODSConfig.cmake.not_yet_installed.in
	${CMAKE_BINARY_DIR}/IRODSConfig.cmake.not_yet_installed # suffix prevents cmake's find_package() from using this copy of the file
	INSTALL_DESTINATION ${IRODS_CMAKE_DIR}
	PATH_VARS IRODS_INCLUDE_DIR
)

install(
	FILES
	${CMAKE_BINARY_DIR}/IRODSConfig.cmake.not_yet_installed
	DESTINATION ${IRODS_CMAKE_DIR}
	COMPONENT irods-development
	RENAME IRODSConfig.cmake
)

write_basic_package_version_file(
	${CMAKE_BINARY_DIR}/IRODSConfigVersion.cmake
	VERSION ${IRODS_VERSION}
	COMPATIBILITY ExactVersion
)

install(
	FILES
	${CMAKE_BINARY_DIR}/IRODSConfigVersion.cmake
	DESTINATION ${IRODS_CMAKE_DIR}
	COMPONENT irods-development
)
