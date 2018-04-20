#
# Tries to find ODBC binaries, headers and libraries.
#
# Usage of this module as follows:
#
#  find_package(ODBC)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
#  ODBC_ROOT_DIR  Set this variable to the root installation of
#                    ODBC if the module has problems finding
#                    the proper installation path.
#
# Variables defined by this module:
#
#  ODBC_FOUND              System has ODBC libs/headers
#  ODBC_LIBRARIES          The ODBC libraries
#  ODBC_INCLUDE_DIR        The location of ODBC headers

if( NOT ODBC_ROOT_DIR )
	if( NOT SEARCH_LIBS_ROOT )
		set( ODBC_ROOT_DIR "/usr" )
	else()
		set( ODBC_ROOT_DIR "${SEARCH_LIBS_ROOT}" )
	endif()
endif()

find_program( ODBC_CONFIG NAMES odbc_config HINTS "${ODBC_ROOT_DIR}/bin" )

if( ODBC_CONFIG )
	execute_process( COMMAND ${ODBC_CONFIG} --include-prefix RESULT_VARIABLE ODBC_RC OUTPUT_VARIABLE ODBC_INCLUDE_DIR )
	string( STRIP "${ODBC_INCLUDE_DIR}" ODBC_INCLUDE_DIR )
	execute_process( COMMAND ${ODBC_CONFIG} --lib-prefix RESULT_VARIABLE ODBC_RC OUTPUT_VARIABLE ODBC_LIB_DIR )
	string( STRIP "${ODBC_LIB_DIR}" ODBC_LIB_DIR )
	find_library(
		ODBC_LIBRARIES
		NAMES odbc
		HINTS ${ODBC_LIB_DIR}
	)
else()
	find_path(
		ODBC_INCLUDE_DIR
		NAMES sql.h sqlext.h
		HINTS ${ODBC_ROOT_DIR}/include
	)

#	if( ODBC_INCLUDE_DIR )
# 		string( REGEX REPLACE "/avro$" "" ODBC_INCLUDE_DIR "${ODBC_INCLUDE_DIR}" )
#	endif()

	find_library(
		ODBC_LIBRARIES
		NAMES odbc
		HINTS ${ODBC_ROOT_DIR}/lib ${ODBC_ROOT_DIR}/lib64
	)

	if( ODBC_LIBRARIES )
		string( REGEX REPLACE "/[^/]*$" "" ODBC_LIB_DIR "${ODBC_LIBRARIES}" )
	endif()

	# find_program( ODBC_CONFIG NAMES odbc_config HINTS "${ODBC_ROOT_DIR}/bin" )
endif()

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args(
    ODBC FOUND_VAR ODBC_FOUND
    REQUIRED_VARS ODBC_LIBRARIES ODBC_INCLUDE_DIR ODBC_LIB_DIR
    VERSION_VAR ODBC_VERSION_STRING
)

mark_as_advanced(
    ODBC_ROOT_DIR
    ODBC_LIBRARIES
    ODBC_INCLUDE_DIR
    ODBC_LIB_DIR
)
