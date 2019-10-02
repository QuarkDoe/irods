#====================
#
#====================

install(
	FILES ${CMAKE_BINARY_DIR}/VERSION.json.dist
	DESTINATION ${IRODS_HOME_DIRECTORY}
	COMPONENT irods-server
)

install(
	DIRECTORY
	DESTINATION ${IRODS_HOME_DIRECTORY}/log
	COMPONENT irods-server
)

# new dir should be created by 'dodir' command in ebuild-script.
#install(
#	DIRECTORY
#	DESTINATION ${IRODS_ETC_DIR}/irods
#	COMPONENT irods-server
#)

install(
	FILES
	${IRODS_SOURCE_DIR}/packaging/connectControl.config.template
	${IRODS_SOURCE_DIR}/packaging/core.dvm.template
	${IRODS_SOURCE_DIR}/packaging/core.fnm.template
	${IRODS_SOURCE_DIR}/packaging/core.re.template
	${IRODS_SOURCE_DIR}/packaging/database_config.json.template
	${IRODS_SOURCE_DIR}/packaging/host_access_control_config.json.template
	${IRODS_SOURCE_DIR}/packaging/hosts_config.json.template
	${IRODS_SOURCE_DIR}/packaging/irodsMonPerf.config.in
	${IRODS_SOURCE_DIR}/packaging/server_config.json.template
	${IRODS_SOURCE_DIR}/packaging/server_setup_instructions.txt
	DESTINATION ${IRODS_HOME_DIRECTORY}/packaging
	COMPONENT irods-server
	PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
)

install(
	FILES
	${IRODS_SOURCE_DIR}/packaging/find_os.sh
	${IRODS_SOURCE_DIR}/packaging/postinstall.sh
	${IRODS_SOURCE_DIR}/packaging/preremove.sh
	DESTINATION ${IRODS_HOME_DIRECTORY}/packaging
	COMPONENT irods-server
	PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ WORLD_READ
)

# init.d and conf.d files should installed from .ebuild using doinitd and doconfd.
# See Gentoo Devmanual at https://devmanual.gentoo.org/tasks-reference/init-scripts/index.html

#install(
#	FILES
#	${CMAKE_SOURCE_DIR}/gentoo/init.d/irods
#	DESTINATION ${IRODS_ETC_DIR}/init.d
#	COMPONENT irods-server
#	PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
#)

#install(
#	FILES
#	${CMAKE_SOURCE_DIR}/gentoo/conf.d/irods
#	DESTINATION ${IRODS_ETC_DIR}/conf.d
#	COMPONENT irods-server
#	PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
#)

install(
	FILES
	${IRODS_SOURCE_DIR}/README.md
	DESTINATION ${IRODS_DOC_DIR}
	COMPONENT irods-server
	RENAME readme
)

install(
	FILES
	${IRODS_SOURCE_DIR}/LICENSE
	DESTINATION ${IRODS_DOC_DIR}
	COMPONENT irods-server
)

install(
	DIRECTORY ${IRODS_SOURCE_DIR}/scripts
	DESTINATION ${IRODS_HOME_DIRECTORY}
	COMPONENT irods-server
)

install(
	DIRECTORY
	DESTINATION ${IRODS_HOME_DIRECTORY}/config/lockFileDir
	COMPONENT irods-server
)

install(
	DIRECTORY
	DESTINATION ${IRODS_HOME_DIRECTORY}/config/packedRei
	COMPONENT irods-server
)

install(
	FILES
	${IRODS_SOURCE_DIR}/msiExecCmd_bin/irodsServerMonPerf
	${IRODS_SOURCE_DIR}/msiExecCmd_bin/test_execstream.py
	${IRODS_SOURCE_DIR}/msiExecCmd_bin/hello
	DESTINATION ${IRODS_HOME_DIRECTORY}/msiExecCmd_bin
	COMPONENT irods-server
	PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ WORLD_READ
)

install(
	FILES
	${IRODS_SOURCE_DIR}/msiExecCmd_bin/univMSSInterface.sh.template
	DESTINATION ${IRODS_HOME_DIRECTORY}/msiExecCmd_bin
	COMPONENT irods-server
	PERMISSIONS OWNER_READ GROUP_READ WORLD_READ
)

install(
	FILES
	${IRODS_SOURCE_DIR}/test/test_framework_configuration.json
	DESTINATION ${IRODS_HOME_DIRECTORY}/test
	COMPONENT irods-server
)

install(
	DIRECTORY ${IRODS_SOURCE_DIR}/test/filesystem
	DESTINATION ${IRODS_HOME_DIRECTORY}/test
	COMPONENT irods-server
)

install(
	FILES
	${IRODS_SOURCE_DIR}/irodsctl
	DESTINATION ${IRODS_HOME_DIRECTORY}
	COMPONENT irods-server
	PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ WORLD_READ
)

# Install configuration schemas with updated id field
set( IRODS_CONFIGURATION_SCHEMA_VERSION 3 )

set(
	IRODS_CONFIGURATION_SCHEMA_BUILD_DIRECTORY
	${CMAKE_BINARY_DIR}/configuration_schemas/v${IRODS_CONFIGURATION_SCHEMA_VERSION}
)

set(
	IRODS_CONFIGURATION_SCHEMA_FILES
	VERSION.json
	client_environment.json
	client_hints.json
	configuration_directory.json
	database_config.json
	grid_status.json
	host_access_control_config.json
	hosts_config.json
	plugin.json
	resource.json
	rule_engine.json
	server.json
	server_config.json
	server_status.json
	service_account_environment.json
	zone_bundle.json
)

foreach( SCHEMA_FILE ${IRODS_CONFIGURATION_SCHEMA_FILES} )
	configure_file(
		${IRODS_SOURCE_DIR}/configuration_schemas/v${IRODS_CONFIGURATION_SCHEMA_VERSION}/${SCHEMA_FILE}
		${IRODS_CONFIGURATION_SCHEMA_BUILD_DIRECTORY}/${SCHEMA_FILE}
		COPYONLY
	)
	install(
		FILES
		${IRODS_CONFIGURATION_SCHEMA_BUILD_DIRECTORY}/${SCHEMA_FILE}
		DESTINATION ${IRODS_HOME_DIRECTORY}/configuration_schemas/v${IRODS_CONFIGURATION_SCHEMA_VERSION}
		COMPONENT irods-server
	)
endforeach()

install(
	CODE
	"execute_process( COMMAND python ${IRODS_SOURCE_DIR}/configuration_schemas/update_schema_ids_for_cmake.py ${IRODS_CONFIGURATION_SCHEMA_BUILD_DIRECTORY} ${CPACK_PACKAGING_INSTALL_PREFIX}${IRODS_HOME_DIRECTORY}/configuration_schemas/v${IRODS_CONFIGURATION_SCHEMA_VERSION} )"
	COMPONENT irods-server
)
