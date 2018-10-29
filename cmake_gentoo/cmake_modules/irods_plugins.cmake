add_subdirectory(plugins/auth)
add_subdirectory(plugins/network)

if( BUILD_SERVER )
	add_subdirectory(plugins/api)
	add_subdirectory(plugins/database)
	add_subdirectory(plugins/microservices)
	add_subdirectory(plugins/resources)
	add_subdirectory(plugins/rule_engines)
endif( BUILD_SERVER )

