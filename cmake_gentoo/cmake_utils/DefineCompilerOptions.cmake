
set( CMAKE_C_COMPILER "clang" )
set( CMAKE_CXX_COMPILER "clang++" )
set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--export-dynamic" )
set( CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,-z,defs" )
set( CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,defs" )
add_compile_options( -Wall -Wextra -Werror -Wno-unused-function -Wno-unused-parameter )
