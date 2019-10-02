
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


# some of thise paths are bad, but scripts and source code use hard-coded relative paths
if( CMAKE_INSTALL_PREFIX STREQUAL "/usr" )
  set( IRODS_HOME_DIR /var/lib/irods )
  set( IRODS_HOME_DIRECTORY ${IRODS_HOME_DIR} )
  set( IRODS_SBIN_DIR /usr/sbin )
  set( IRODS_ETC_DIR /etc )
  set( IRODS_INCLUDE_DIR /usr/include/irods )
  set( IRODS_LIBRARY_DIR /usr/lib )
  set( IRODS_CMAKE_DIR ${IRODS_LIBRARY_DIR}/cmake/irods )
  set( IRODS_PLUGINS_DIR ${IRODS_LIBRARY_DIR}/irods/plugins )
  set( IRODS_PLUGINS_DIRECTORY ${IRODS_PLUGINS_DIR} )
  set( IRODS_DOC_DIR /usr/share/doc/irods )
else()
  set( IRODS_HOME_DIR var/lib/irods )
  set( IRODS_HOME_DIRECTORY ${IRODS_HOME_DIR} )
  set( IRODS_SBIN_DIR usr/sbin )
  set( IRODS_ETC_DIR etc )
  set( IRODS_INCLUDE_DIR include/irods )
  set( IRODS_LIBRARY_DIR usr/lib )
  set( IRODS_CMAKE_DIR ${IRODS_LIBRARY_DIR}/cmake/irods )
  set( IRODS_PLUGINS_DIR ${IRODS_LIBRARY_DIR}/irods/plugins )
  set( IRODS_PLUGINS_DIRECTORY ${IRODS_PLUGINS_DIR} )
  set( IRODS_DOC_DIR usr/share/doc/irods )
endif()
