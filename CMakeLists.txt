cmake_minimum_required(VERSION 3.22.1)

project(CodeSnippets C CXX)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

# find_package(SDL2 REQUIRED)
# find_package(SDL2_image REQUIRED)
# find_package(SDL2_ttf REQUIRED)
# include_directories(${SDL2_INCLUDE_DIR})
# include_directories(${SDL2_IMAGE_INCLUDE_DIR})
# include_directories(${SDL2_TTF_INCLUDE_DIR})

# include_directories(${FFMPEG_INCLUDE_DIRS})
# include_directories(${CMAKE_SOURCE_DIR}/include)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED yes)

add_executable(thread_wrapper thread_wrapper.cpp)
add_executable(check_byteorder check_byteorder.cpp)
add_executable(move_if_noexcept move_if_noexcept.cpp)
add_executable(locking_queue locking_queue.cpp)
add_executable(thread_safe_counter thread_safe_counter.cpp)
add_executable(thread_guard thread_guard.cpp)
