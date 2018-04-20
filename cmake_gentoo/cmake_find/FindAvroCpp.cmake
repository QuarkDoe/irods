#
# Tries to find avro-cpp binaries, headers and libraries.
#
# Usage of this module as follows:
#
#  find_package(AvroCpp)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
#  AVROCPP_ROOT_DIR  Set this variable to the root installation of
#                    AVROCPP if the module has problems finding
#                    the proper installation path.
#
# Variables defined by this module:
#
#  AVROCPP_FOUND              System has avro-cpp libs/headers
#  AVROCPP_GENCPP             avrogencpp
#  AVROCPP_LIBRARIES          The avro-cpp libraries
#  AVROCPP_INCLUDE_DIR        The location of AVROCPP headers

if( NOT AVROCPP_ROOT_DIR )
	if( NOT SEARCH_LIBS_ROOT )
		set( AVROCPP_ROOT_DIR "/usr" )
	else()
		set( AVROCPP_ROOT_DIR "${SEARCH_LIBS_ROOT}" )
	endif()
endif()


find_path(
	AVROCPP_INCLUDE_DIR
	NAMES avro/AvroParse.hh
	HINTS ${AVROCPP_ROOT_DIR}/include
)

if( AVROCPP_INCLUDE_DIR )
	string( REGEX REPLACE "/avro$" "" AVROCPP_INCLUDE_DIR "${AVROCPP_INCLUDE_DIR}" )
endif()

find_library(
	AVROCPP_LIBRARIES
	NAMES avrocpp
	HINTS ${AVROCPP_ROOT_DIR}/lib ${AVROCPP_ROOT_DIR}/lib64
)

if( AVROCPP_LIBRARIES )
	string( REGEX REPLACE "/[^/]*$" "" AVROCPP_LIB_DIR "${AVROCPP_LIBRARIES}" )
endif()

find_program( AVROCPP_AVROGEN NAMES avrogencpp HINTS "${AVROCPP_ROOT_DIR}/bin" )

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args(
    AVROCPP FOUND_VAR AVROCPP_FOUND
    REQUIRED_VARS AVROCPP_LIBRARIES AVROCPP_INCLUDE_DIR AVROCPP_LIB_DIR AVROCPP_AVROGEN
    VERSION_VAR AVROCPP_VERSION_STRING
)

mark_as_advanced(
    AVROCPP_ROOT_DIR
    AVROCPP_LIBRARIES
    AVROCPP_INCLUDE_DIR
    AVROCPP_LIB_DIR
    AVROCPP_AVROGEN
)
