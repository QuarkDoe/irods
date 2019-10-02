set (
	IRODS_LIBIRODS_PLUGIN_DEPENDENCIES_SOURCES
	${IRODS_SOURCE_DIR}/lib/core/src/apiHandler.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_auth_factory.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_auth_manager.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_auth_object.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_generic_auth_object.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_gsi_object.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_krb_object.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_native_auth_object.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_network_factory.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_network_manager.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_network_object.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_osauth_auth_object.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_pam_auth_object.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_ssl_object.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_tcp_object.cpp
)
