#
# Tries to find ZMQPP binaries, headers and libraries.
#
# Usage of this module as follows:
#
#  find_package(Zmqpp)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
#  ZMQPP_ROOT_DIR  Set this variable to the root installation of
#                    ZMQPP if the module has problems finding
#                    the proper installation path.
#
# Variables defined by this module:
#
#  ZMQPP_FOUND              System has avro-cpp libs/headers
#  ZMQPP_LIBRARIES          The ZMQPP libraries
#  ZMQPP_INCLUDE_DIR        The location of ZMQPP headers

if( NOT ZMQPP_ROOT_DIR )
	if( NOT SEARCH_LIBS_ROOT )
		set( ZMQPP_ROOT_DIR "/usr" )
	else()
		set( ZMQPP_ROOT_DIR "${SEARCH_LIBS_ROOT}" )
	endif()
endif()

find_path(
	ZMQPP_INCLUDE_DIR
	NAMES zmqpp/zmqpp.hpp
	HINTS ${ZMQPP_ROOT_DIR}/include
)

if( ZMQPP_INCLUDE_DIR )
	string( REGEX REPLACE "/zmqpp$" "" ZMQPP_INCLUDE_DIR "${ZMQPP_INCLUDE_DIR}" )
endif()

if( ZMQPP_INCLUDE_DIR )
	file(
		WRITE
		${CMAKE_BINARY_DIR}/getzmqppver.cpp
"/* get zmqpp version */
#include <zmqpp/zmqpp.hpp>
#include <iostream>
using namespace std;

int main(){
	#ifdef ZMQPP_VERSION_MAJOR
		cout << ZMQPP_VERSION_MAJOR;
	#ifdef ZMQPP_VERSION_MINOR
		cout << \".\";
		cout << ZMQPP_VERSION_MINOR;
	#ifdef ZMQPP_VERSION_REVISION
		cout << \".\";
		cout << ZMQPP_VERSION_REVISION;
	#endif
	#endif
		//cout << endl;
	#endif
}
"
	)
	separate_arguments( COMPFLAGS UNIX_COMMAND "${CMAKE_CXX_FLAGS}" )
	execute_process(
		COMMAND ${CMAKE_CXX_COMPILER} ${COMPFLAGS} --std=c++11 -o getzmqppver getzmqppver.cpp
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		RESULT_VARIABLE COMPILERC
		OUTPUT_FILE getzmqppver.out
		ERROR_FILE getzmqppver.err
	)
	message( STATUS "COMPILERC:${COMPILERC}" )
	if( COMPILERC )
		message( FATAL_ERROR "Compile ${CMAKE_BINARY_DIR}/getzmqppver.cpp failed. For details see ${CMAKE_BINARY_DIR}/getzmqppver.err" )
	endif()
	execute_process(
		COMMAND ./getzmqppver
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		RESULT_VARIABLE EXECRC
		OUTPUT_VARIABLE ZMQPP_VERSION_STRING
		ERROR_FILE getzmqppver.err
	)
	message( STATUS "EXECRC:${EXECRC}" )
	message( STATUS "ZMQPP_VERSION_STRING:${ZMQPP_VERSION_STRING}" )
	if( EXECRC )
		message( FATAL_ERROR "Execution ${CMAKE_BINARY_DIR}/getzmqppver failed. For details see ${CMAKE_BINARY_DIR}/getzmqppver.err" )
	endif()
endif()

find_library(
	ZMQPP_LIBRARIES
	NAMES zmqpp
	HINTS ${ZMQPP_ROOT_DIR}/lib
)

if( ZMQPP_LIBRARIES )
	string( REGEX REPLACE "/[^/]*$" "" ZMQPP_LIB_DIR "${ZMQPP_LIBRARIES}" )
endif()

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args(
    ZMQPP FOUND_VAR ZMQPP_FOUND
    REQUIRED_VARS ZMQPP_LIBRARIES ZMQPP_INCLUDE_DIR ZMQPP_LIB_DIR
    VERSION_VAR ZMQPP_VERSION_STRING
)

mark_as_advanced(
    ZMQPP_ROOT_DIR
    ZMQPP_LIBRARIES
    ZMQPP_INCLUDE_DIR
    ZMQPP_LIB_DIR
    ZMQPP_AVROGEN
)
