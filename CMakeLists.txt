cmake_minimum_required(VERSION 3.22.1)

project(CodeSnippets C CXX)

add_executable(thread_wrapper thread_wrapper.cpp)
add_executable(check_byteorder check_byteorder.cpp)
add_executable(move_if_noexcept move_if_noexcept.cpp)
add_executable(locking_queue locking_queue.cpp)
add_executable(thread_safe_counter thread_safe_counter.cpp)
add_executable(thread_guard thread_guard.cpp)
