#====================
#
#====================

add_library(
	irods_filesystem_path
	OBJECT
	${IRODS_SOURCE_DIR}/lib/filesystem/src/path.cpp
)

target_include_directories(
	irods_filesystem_path
	PRIVATE
	${IRODS_SOURCE_DIR}/lib/filesystem/include
	${IRODS_SOURCE_DIR}/lib/core/include
	${Boost_INCLUDE_DIRS}
)

set_target_properties(irods_filesystem_path PROPERTIES CXX_STANDARD ${IRODS_CXX_STANDARD})

target_compile_options(irods_filesystem_path PRIVATE -fPIC -Wno-write-strings)

target_compile_definitions(irods_filesystem_path PRIVATE ${IRODS_COMPILE_DEFINITIONS})
