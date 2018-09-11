cmake_minimum_required( VERSION 3.5.0 FATAL_ERROR )
#=====================================================

project( IRODS C CXX )

#-----------------------------------------------------

set(
	CMAKE_MODULE_PATH
	${CMAKE_SOURCE_DIR}/cmake_find/
	${CMAKE_SOURCE_DIR}/cmake_modules/
)

get_filename_component( IRODS_SOURCE_DIR "${CMAKE_SOURCE_DIR}/.." ABSOLUTE )

if( NOT EXISTS "${IRODS_SOURCE_DIR}/irods_schema_messaging/v1/server_control_plane_command.json" )
	message(
		FATAL_ERROR
		"Missing file: ${IRODS_SOURCE_DIR}/irods_schema_messaging/v1/server_control_plane_command.json\n"
		"Are your git submodules initialized? If not, try running the following in the source directory:\n"
		"git submodule update --init\n"
	)
endif()

include( DefineCMakeDefaults )
include( RequireOutOfSourceBuild )

#-----------------------------------------------------

option( BUILD_SERVER "Build server" ON )

include( CheckIncludeFile )
include( CheckIncludeFileCXX )

set( IRODS_VERSION_MAJOR "4" )
set( IRODS_VERSION_MINOR "2" )
set( IRODS_VERSION_PATCH "4" )
set( IRODS_VERSION "${IRODS_VERSION_MAJOR}.${IRODS_VERSION_MINOR}.${IRODS_VERSION_PATCH}" )
set( IRODS_CXX_STANDARD "14" )

set(
	IRODS_COMPILE_DEFINITIONS
	linux_platform
	_LARGEFILE_SOURCE
	_FILE_OFFSET_BITS=64
	_LARGE_FILES
	_LARGEFILE64_SOURCE
	BOOST_SYSTEM_NO_DEPRECATED
)

find_package( PkgConfig REQUIRED )

find_package( Clang REQUIRED )

include( DefineCompilerOptions )
include( DefineIrodsVariables )
message( STATUS "CMAKE_C_COMPILER: ${CMAKE_C_COMPILER}" )
message( STATUS "CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}" )
message( STATUS "CMAKE_EXE_LINKER_FLAGS: ${CMAKE_EXE_LINKER_FLAGS}" ) 
message( STATUS "CMAKE_MODULE_LINKER_FLAGS: ${CMAKE_MODULE_LINKER_FLAGS}" )
message( STATUS "CMAKE_SHARED_LINKER_FLAGS: ${CMAKE_SHARED_LINKER_FLAGS}" )

find_package( Threads REQUIRED )

find_package( OpenSSL REQUIRED )

if ( NOT PAM_LIBRARY )
	find_library( PAM_LIBRARY pam )
	if ( PAM_LIBRARY )
		message( STATUS "Found pam: ${PAM_LIBRARY}" )
	else()
		message( FATAL_ERROR "pam library not found" )
	endif()
endif()

check_include_file_cxx( zmq.hpp HAVE_ZMQ_HPP )
if( NOT HAVE_ZMQ_HPP )
	message( FATAL_ERROR "Require zmq.hpp. HAVE_ZMQ_HPP : ${HAVE_ZMQ_HPP}" )
endif( NOT HAVE_ZMQ_HPP )

find_package( AvroCpp REQUIRED )
message( STATUS "AVROCPP_ROOT_DIR:${AVROCPP_ROOT_DIR}" )
message( STATUS "AVROCPP_LIBRARIES:${AVROCPP_LIBRARIES}" )
message( STATUS "AVROCPP_INCLUDE_DIR:${AVROCPP_INCLUDE_DIR}" )
message( STATUS "AVROCPP_LIB_DIR:${AVROCPP_LIB_DIR}" )
message( STATUS "AVROCPP_AVROGEN:${AVROCPP_AVROGEN}" )

set( Boost_USE_MULTITHREADED ON )
find_package(
	Boost 1.60 REQUIRED
	COMPONENTS
	chrono
	filesystem
	regex
	system
	thread
	program_options
	random
)

pkg_check_modules( LIBARCHIVE libarchive>=3.1.2 REQUIRED )
pkg_check_modules( JANSSON jansson>=2.7 REQUIRED )
pkg_check_modules( ZEROMQ libzmq>=4.2.1 REQUIRED )
pkg_check_modules( CURL libcurl>=7.53 REQUIRED )

link_directories(
	${AVROCPP_LIB_DIR}
	${LIBARCHIVE_LIBRARY_DIRS}
	${JANSSON_LIBRARY_DIRS}
	${ZEROMQ_LIBRARY_DIRS}
	${CURL_LIBRARY_DIRS}
)

#-----------------------------------------------------------------------

add_custom_command(
	OUTPUT ${CMAKE_BINARY_DIR}/lib/core/include/server_control_plane_command.hpp
	COMMAND ${AVROCPP_AVROGEN}
		-n irods
		-o ${CMAKE_BINARY_DIR}/lib/core/include/server_control_plane_command.hpp
		-i ${IRODS_SOURCE_DIR}/irods_schema_messaging/v1/server_control_plane_command.json
	MAIN_DEPENDENCY ${IRODS_SOURCE_DIR}/irods_schema_messaging/v1/server_control_plane_command.json
)

set_source_files_properties(
	${IRODS_SOURCE_DIR}/lib/core/src/irods_server_properties.cpp
	PROPERTIES
	OBJECT_DEPENDS ${CMAKE_BINARY_DIR}/lib/core/include/server_control_plane_command.hpp
)

configure_file(
	${IRODS_SOURCE_DIR}/lib/core/include/rodsVersion.h.in
	${CMAKE_BINARY_DIR}/lib/core/include/rodsVersion.h
	@ONLY
)

configure_file(
	${IRODS_SOURCE_DIR}/lib/core/include/irods_version.h.in
	${CMAKE_BINARY_DIR}/lib/core/include/irods_version.h
	@ONLY
)

include(GetGitRevisionDescription)
get_git_head_revision(IRODS_GIT_REFSPEC IRODS_GIT_SHA1)
configure_file(
	${IRODS_SOURCE_DIR}/VERSION.json.dist.in
	${CMAKE_BINARY_DIR}/VERSION.json.dist
	@ONLY
)

include( irods_common_library )
include( irods_plugin_dependencies_library )
include( irods_client_library )
include( irods_apis_static_library )

if( BUILD_SERVER )
	include( irods_server_library )
	include( irods_main_executables )
	include( irods_plugins )
	include( irods_files )
endif( BUILD_SERVER )
