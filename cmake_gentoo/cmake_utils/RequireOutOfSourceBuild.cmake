# - Issue an error if the source tree is in or equal to the build tree
#
#  include(RequireOutOfSourceBuild)
#

get_filename_component(_cm_src "${CMAKE_SOURCE_DIR}" ABSOLUTE)
get_filename_component(_ir_src "${IRODS_SOURCE_DIR}" ABSOLUTE)
get_filename_component(_cm_bin "${CMAKE_BINARY_DIR}" ABSOLUTE)

if(
	EXISTS "${_cm_bin}/CMakeLists.txt"
	OR _cm_src EQUAL _cm_bin
	OR _ir_src EQUAL _cm_bin
)
	get_filename_component(_parent "${CMAKE_SOURCE_DIR}/.." ABSOLUTE)
	message(FATAL_ERROR
		"You must set a binary directory that is different from your source directory."
		"You might consider ${CMAKE_SOURCE_DIR}/.build or ${_parent}/.build-${CMAKE_PROJECT_NAME}"
	)
endif()
