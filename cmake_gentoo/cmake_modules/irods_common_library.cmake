#====================
#irods_common library
#====================
set(
	IRODS_LIBIRODS_COMMON_SOURCES
	${IRODS_SOURCE_DIR}/lib/core/src/base64.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/getRodsEnv.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/hashtable.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_buffer_encryption.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_children_parser.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_configuration_parser.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_default_paths.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_environment_properties.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_error.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_exception.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_get_full_path_for_config_file.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_hierarchy_parser.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_hostname.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_kvp_string_parser.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_log.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_pack_table.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_parse_command_line_options.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_path_recursion.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_pluggable_auth_scheme.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_plugin_name_generator.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_random.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_serialization.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_server_properties.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_socket_information.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_stacktrace.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_string_tokenize.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/irods_virtual_path.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/list.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/msParam.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/obf.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/osauth.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/packStruct.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/parseCommandLine.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/rcGlobal.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/rcMisc.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/region.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/rodsLog.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/rodsPath.cpp
	${IRODS_SOURCE_DIR}/lib/core/src/stringOpr.cpp
	${IRODS_SOURCE_DIR}/lib/hasher/src/Hasher.cpp
	${IRODS_SOURCE_DIR}/lib/hasher/src/MD5Strategy.cpp
	${IRODS_SOURCE_DIR}/lib/hasher/src/SHA256Strategy.cpp
	${IRODS_SOURCE_DIR}/lib/hasher/src/checksum.cpp
	${IRODS_SOURCE_DIR}/lib/hasher/src/irods_hasher_factory.cpp
	${IRODS_SOURCE_DIR}/lib/rbudp/src/QUANTAnet_rbudpBase_c.cpp
	${IRODS_SOURCE_DIR}/lib/rbudp/src/QUANTAnet_rbudpReceiver_c.cpp
	${IRODS_SOURCE_DIR}/lib/rbudp/src/QUANTAnet_rbudpSender_c.cpp
)

add_library(
	irods_common
	SHARED
	${IRODS_LIBIRODS_COMMON_SOURCES}
)

target_include_directories(
	irods_common
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
