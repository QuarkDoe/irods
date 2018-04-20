find_package( ODBC REQUIRED )

set(
	IRODS_DATABASE_PLUGIN_COMPILE_DEFINITIONS_postgres
)
set(
	IRODS_DATABASE_PLUGIN_COMPILE_DEFINITIONS_mysql
	MY_ICAT
)
set(
	IRODS_DATABASE_PLUGIN_COMPILE_DEFINITIONS_oracle
	ORA_ICAT
)

set(
	IRODS_DATABASE_PLUGINS
	postgres
	mysql
	oracle
)

if( NOT IRODS_MYSQL_DEFAULT_STORAGE_ENGINE_KEYWORD )
	if( IRODS_LINUX_DISTRIBUTION_NAME STREQUAL "ubuntu" AND IRODS_LINUX_DISTRIBUTION_VERSION_MAJOR STREQUAL "16" )
		set( IRODS_MYSQL_DEFAULT_STORAGE_ENGINE_KEYWORD "default_storage_engine" CACHE STRING "Keyword used when setting MySQL default storage engine for session." FORCE )
	else()
		set( IRODS_MYSQL_DEFAULT_STORAGE_ENGINE_KEYWORD "storage_engine" CACHE STRING "Keyword used when setting MySQL default storage engine for session." FORCE )
	endif()
	message( STATUS "Setting unspecified IRODS_MYSQL_DEFAULT_STORAGE_ENGINE_KEYWORD to '${IRODS_MYSQL_DEFAULT_STORAGE_ENGINE_KEYWORD}'. This is the correct setting for normal builds." )
endif()

configure_file(
	${IRODS_SOURCE_DIR}/plugins/database/src/icatSysTables.sql.pp.in
	${CMAKE_BINARY_DIR}/plugins/database/src/icatSysTables.sql.pp
	@ONLY
)

configure_file(
	${IRODS_SOURCE_DIR}/plugins/database/src/mysql_functions.sql.in
	${CMAKE_BINARY_DIR}/plugins/database/src/mysql_functions.sql
	@ONLY
)

foreach( PLUGIN ${IRODS_DATABASE_PLUGINS} )
	string( TOUPPER ${PLUGIN} PLUGIN_UPPERCASE )

	add_custom_command(
		OUTPUT ${CMAKE_BINARY_DIR}/icatSysTables_${PLUGIN}.sql
		COMMAND cpp -E -P -D${PLUGIN} ${CMAKE_BINARY_DIR}/plugins/database/src/icatSysTables.sql.pp ${CMAKE_BINARY_DIR}/icatSysTables_${PLUGIN}.sql
		MAIN_DEPENDENCY ${CMAKE_BINARY_DIR}/plugins/database/src/icatSysTables.sql.pp
	)
	# Forces execution of custom_command
	add_custom_target( IRODS_PHONY_TARGET_icatSysTables_${PLUGIN}.sql ALL DEPENDS ${CMAKE_BINARY_DIR}/icatSysTables_${PLUGIN}.sql )

	add_library(
		${PLUGIN}
		MODULE
		${IRODS_SOURCE_DIR}/plugins/database/src/db_plugin.cpp
		${IRODS_SOURCE_DIR}/plugins/database/src/general_query.cpp
		${IRODS_SOURCE_DIR}/plugins/database/src/general_query_setup.cpp
		${IRODS_SOURCE_DIR}/plugins/database/src/general_update.cpp
		${IRODS_SOURCE_DIR}/plugins/database/src/irods_catalog_properties.cpp
		${IRODS_SOURCE_DIR}/plugins/database/src/irods_sql_logger.cpp
		${IRODS_SOURCE_DIR}/plugins/database/src/low_level_odbc.cpp
		${IRODS_SOURCE_DIR}/plugins/database/src/mid_level_routines.cpp
	)

	target_include_directories(
		${PLUGIN}
		PRIVATE
		${CMAKE_BINARY_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/api/include
		${IRODS_SOURCE_DIR}/lib/hasher/include
		${IRODS_SOURCE_DIR}/server/core/include
		${IRODS_SOURCE_DIR}/server/icat/include
		${IRODS_SOURCE_DIR}/server/re/include
		${IRODS_SOURCE_DIR}/plugins/database/include
		${Boost_INCLUDE_DIRS}
		${JANSSON_INCLUDE_DIRS}
		${ODBC_INCLUDE_DIR}
	)

	target_link_libraries(
		${PLUGIN}
		PRIVATE
		irods_server
		irods_plugin_dependencies
		irods_common
		${Boost_SYSTEM_LIBRARY}
		${Boost_REGEX_LIBRARY}
		${JANSSON_LIBRARIES}
		${ODBC_LIBRARIES}
	)

	target_compile_definitions( ${PLUGIN} PRIVATE ENABLE_RE ${IRODS_DATABASE_PLUGIN_COMPILE_DEFINITIONS_${PLUGIN}} ${IRODS_COMPILE_DEFINITIONS}  )
	target_compile_options( ${PLUGIN} PRIVATE -Wno-write-strings )
	set_property( TARGET ${PLUGIN} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )

	install(
		TARGETS
		${PLUGIN}
		LIBRARY
		DESTINATION ${IRODS_PLUGINS_DIRECTORY}/database
		COMPONENT irods-database-plugins
		# COMPONENT ${IRODS_PACKAGE_COMPONENT_${PLUGIN_UPPERCASE}_NAME}
	)

	install(
		FILES
		${IRODS_SOURCE_DIR}/plugins/database/${PLUGIN}/upgrade-3.3.xto4.0.0.sql
		DESTINATION ${IRODS_HOME_DIRECTORY}/packaging
		RENAME ${PLUGIN}-upgrade-3.3.xto4.0.0.sql
		COMPONENT irods-database-plugins
		# COMPONENT ${IRODS_PACKAGE_COMPONENT_${PLUGIN_UPPERCASE}_NAME}
	)

	install(
		FILES
		${IRODS_SOURCE_DIR}/plugins/database/packaging/localhost_setup_${PLUGIN}.input
		DESTINATION ${IRODS_HOME_DIRECTORY}/packaging
		COMPONENT irods-database-plugins
		# COMPONENT ${IRODS_PACKAGE_COMPONENT_${PLUGIN_UPPERCASE}_NAME}
		PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
	)

	install(
		FILES
		${IRODS_SOURCE_DIR}/plugins/database/src/icatDropSysTables.sql
		${IRODS_SOURCE_DIR}/plugins/database/src/icatSysInserts.sql
		${IRODS_SOURCE_DIR}/plugins/database/src/icatPurgeRecycleBin.sql
		DESTINATION ${IRODS_HOME_DIRECTORY}/packaging/sql_${PLUGIN}
		COMPONENT irods-database-plugins
		# COMPONENT ${IRODS_PACKAGE_COMPONENT_${PLUGIN_UPPERCASE}_NAME}
		PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
	)

	install(
		FILES
		${CMAKE_BINARY_DIR}/icatSysTables_${PLUGIN}.sql
		DESTINATION ${IRODS_HOME_DIRECTORY}/packaging/sql_${PLUGIN}
		COMPONENT irods-database-plugins
		# COMPONENT ${IRODS_PACKAGE_COMPONENT_${PLUGIN_UPPERCASE}_NAME}
		RENAME icatSysTables.sql
		PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
	)

endforeach()

install(
	FILES
	${CMAKE_BINARY_DIR}/plugins/database/src/mysql_functions.sql
	DESTINATION ${IRODS_HOME_DIRECTORY}/packaging/sql_mysql
	COMPONENT irods-database-plugins
	# COMPONENT ${IRODS_PACKAGE_COMPONENT_MYSQL_NAME}
)

