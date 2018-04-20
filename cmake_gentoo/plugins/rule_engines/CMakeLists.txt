set(
	IRODS_RULE_ENGINE_PLUGIN-IRODS_RULE_LANGUAGE_SOURCES
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/arithmetics.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/cache.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/configuration.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/conversion.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/datetime.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/filesystem.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/msiHelper.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/index.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/nre.reHelpers1.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/nre.reHelpers2.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/nre.reLib1.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/parser.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/reStruct.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/reVariableMap.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/reVariableMap.gen.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/restructs.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/rules.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/typing.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/utils.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/rsRe.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/functions.cpp
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/libirods_rule_engine_plugin-irods_rule_language.cpp
)

set(
	IRODS_RULE_ENGINE_PLUGIN-CPP_DEFAULT_POLICY_SOURCES
	${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-cpp_default_policy/libirods_rule_engine_plugin-cpp_default_policy.cpp
)

set(
	IRODS_RULE_ENGINE_PLUGINS
	irods_rule_engine_plugin-irods_rule_language
	irods_rule_engine_plugin-cpp_default_policy
)

foreach( PLUGIN ${IRODS_RULE_ENGINE_PLUGINS} )
	string( TOUPPER ${PLUGIN} PLUGIN_UPPERCASE )

	add_library(
		${PLUGIN}
		MODULE
		${${PLUGIN_UPPERCASE}_SOURCES}
	)

	target_include_directories(
		${PLUGIN}
		PRIVATE
		${CMAKE_BINARY_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/api/include
		${IRODS_SOURCE_DIR}/lib/core/include
		${IRODS_SOURCE_DIR}/lib/hasher/include
		${IRODS_SOURCE_DIR}/plugins/rule_engines/irods_rule_engine_plugin-irods_rule_language/include
		${IRODS_SOURCE_DIR}/server/api/include
		${IRODS_SOURCE_DIR}/server/core/include
		${IRODS_SOURCE_DIR}/server/drivers/include
		${IRODS_SOURCE_DIR}/server/icat/include
		${IRODS_SOURCE_DIR}/server/re/include
		${Boost_INCLUDE_DIRS}
		${JANSSON_INCLUDE_DIRS}
		${OPENSSL_INCLUDE_DIR}
	)

	target_link_libraries(
		${PLUGIN}
		PRIVATE
		irods_server
		irods_common
		${Boost_FILESYSTEM_LIBRARY}
		${Boost_SYSTEM_LIBRARY}
		${Boost_REGEX_LIBRARY}
		dl
	)

	target_compile_definitions( ${PLUGIN} PRIVATE ${IRODS_COMPILE_DEFINITIONS} )
	target_compile_options( ${PLUGIN} PRIVATE -Wno-write-strings )
	set_property( TARGET ${PLUGIN} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD} )
endforeach()

install(
	TARGETS
		${IRODS_RULE_ENGINE_PLUGINS}
	LIBRARY
		DESTINATION ${IRODS_PLUGINS_DIRECTORY}/rule_engines
		COMPONENT irods-server
		# COMPONENT ${IRODS_PACKAGE_COMPONENT_SERVER_NAME}
)
