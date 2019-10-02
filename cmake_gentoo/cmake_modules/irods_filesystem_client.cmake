#====================
#
#====================

add_library(
	irods_filesystem_client
	OBJECT
	${IRODS_SOURCE_DIR}/lib/filesystem/src/filesystem.cpp
	${IRODS_SOURCE_DIR}/lib/filesystem/src/collection_iterator.cpp
	${IRODS_SOURCE_DIR}/lib/filesystem/src/recursive_collection_iterator.cpp
)

target_include_directories(
	irods_filesystem_client
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
	${OPENSSL_INCLUDE_DIR}
)

set_target_properties(irods_filesystem_client PROPERTIES CXX_STANDARD ${IRODS_CXX_STANDARD})

target_compile_options(irods_filesystem_client PRIVATE -fPIC -Wno-write-strings)

target_compile_definitions(irods_filesystem_client PRIVATE ${IRODS_COMPILE_DEFINITIONS})
