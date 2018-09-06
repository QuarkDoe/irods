
# guess LIB_SUFFIX, don't take debian multiarch into account
if ( NOT DEFINED LIB_SUFFIX )
  if( CMAKE_SYSTEM_NAME MATCHES "Linux"
      AND NOT CMAKE_CROSSCOMPILING
      AND NOT EXISTS "/etc/debian_version"
      AND NOT EXISTS "/etc/arch-release" )
    if ( "${CMAKE_SIZEOF_VOID_P}" EQUAL "8" )
      set ( LIB_SUFFIX 64 )
    endif ()
  endif ()
endif ()

if( CMAKE_INSTALL_PREFIX STREQUAL "/usr" )
  set( _inst_pref "/" )
else()
  set( _inst_pref "" )
endif()

set( APPLICATION_NAME irods )
set( IRODS_HOME_DIR ${_inst_pref}var/lib/${APPLICATION_NAME} )
set( IRODS_HOME_DIRECTORY ${IRODS_HOME_DIR} )
set( IRODS_SBIN_DIR ${CMAKE_INSTALL_PREFIX}/sbin )
set( IRODS_ETC_DIR ${_inst_pref}etc )
set( IRODS_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include/${APPLICATION_NAME} )
set( IRODS_LIBRARY_DIR ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX} )
set( IRODS_CMAKE_DIR ${IRODS_LIBRARY_DIR}/cmake/${APPLICATION_NAME} )
set( IRODS_PLUGINS_DIR ${IRODS_LIBRARY_DIR}/${APPLICATION_NAME}/plugins )
set( IRODS_PLUGINS_DIRECTORY ${IRODS_PLUGINS_DIR} )
set( IRODS_DOC_DIR ${CMAKE_INSTALL_PREFIX}/share/doc/${APPLICATION_NAME} )
