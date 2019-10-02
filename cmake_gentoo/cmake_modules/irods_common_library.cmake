#====================
#irods_common library
#====================

include(irods_libirods_common_sources)

add_library(
	irods_common
	SHARED
	${IRODS_LIBIRODS_COMMON_SOURCES}
	$<TARGET_OBJECTS:irods_filesystem_path>
)

target_include_directories(
	irods_common
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
	${JANSSON_INCLUDE_DIRS}
	${Boost_INCLUDE_DIRS}
)

target_link_libraries(
	irods_common
	PRIVATE
	${Boost_FILESYSTEM_LIBRARY}
	${Boost_PROGRAM_OPTIONS_LIBRARY}
	${Boost_RANDOM_LIBRARY}
	${Boost_REGEX_LIBRARY}
	${Boost_SYSTEM_LIBRARY}
	${JANSSON_LIBRARIES}
	${OPENSSL_SSL_LIBRARY}
	${OPENSSL_CRYPTO_LIBRARY}
	${CMAKE_DL_LIBS}
)

set_property( TARGET irods_common PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
set_property( TARGET irods_common PROPERTY VERSION ${IRODS_VERSION} )
set_property( TARGET irods_common PROPERTY SOVERSION ${IRODS_VERSION} )
target_compile_definitions( irods_common PRIVATE ${IRODS_COMPILE_DEFINITIONS} )
target_compile_options( irods_common PRIVATE -Wno-write-strings )

install(
	TARGETS	irods_common
	EXPORT IRODSTargets
	LIBRARY
	DESTINATION ${IRODS_LIBRARY_DIR}
	COMPONENT irods-runtime
)
