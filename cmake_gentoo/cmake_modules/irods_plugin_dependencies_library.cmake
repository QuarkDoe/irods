#====================
#irods_plugin_dependencies library
#====================

include(irods_libirods_plugin_dependencies_sources)

add_library(
	irods_plugin_dependencies
	SHARED
	${IRODS_LIBIRODS_PLUGIN_DEPENDENCIES_SOURCES}
)

target_link_libraries(
	irods_plugin_dependencies
	PRIVATE
	irods_common
	${Boost_FILESYSTEM_LIBRARY}
	${Boost_RANDOM_LIBRARY}
	${Boost_SYSTEM_LIBRARY}
	${CMAKE_DL_LIBS}
)

target_include_directories(
	irods_plugin_dependencies
	PRIVATE
	${CMAKE_BINARY_DIR}/lib/core/include
	${IRODS_SOURCE_DIR}/lib/core/include
	${IRODS_SOURCE_DIR}/lib/api/include
	${IRODS_SOURCE_DIR}/lib/hasher/include
	${IRODS_SOURCE_DIR}/lib/rbudp/include
	${IRODS_SOURCE_DIR}/server/core/include
	${IRODS_SOURCE_DIR}/server/icat/include
	${IRODS_SOURCE_DIR}/server/re/include
	${IRODS_SOURCE_DIR}/server/drivers/include
	${Boost_INCLUDE_DIRS}
	${JANSSON_INCLUDE_DIRS}
)

set_property( TARGET irods_plugin_dependencies PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
set_property( TARGET irods_plugin_dependencies PROPERTY VERSION ${IRODS_VERSION} )
set_property( TARGET irods_plugin_dependencies PROPERTY SOVERSION ${IRODS_VERSION} )
target_compile_definitions( irods_plugin_dependencies PRIVATE ${IRODS_COMPILE_DEFINITIONS} )
target_compile_options( irods_plugin_dependencies PRIVATE -Wno-write-strings )

install(
	TARGETS irods_plugin_dependencies
	EXPORT IRODSTargets
	LIBRARY
	DESTINATION ${IRODS_LIBRARY_DIR}
	COMPONENT irods-runtime
)
