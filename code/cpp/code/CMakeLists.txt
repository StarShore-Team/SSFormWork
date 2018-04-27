# ----------------------------------------------------------------------------
# Root CMake file for Drop Star's Project
#
#   From the off-tree build directory, invoke:
#       $ cmake <PATH_TO_Project_ROOT>
#   or:
#       $ cd  <PATH_TO_Build_ROOT>
#       $ cmake -G <Generators> <PATH_TO_Project_ROOT>
#
# ----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.9)

project(SSFormwork)

if(MSVC)
    include(script/msbuild.cmake)
    # include(script/c_flag_overrides.cmake)
endif()
include(script/common.cmake)

include_directories(include)
include_directories(../third/include)
# SSNetwork
add_subdirectory(src/SSNetwork)