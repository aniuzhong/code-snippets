# FindFFmpeg
# ----------
#
# Try to find the required ffmpeg components (default: AVFORMAT, AVUTIL, AVCODEC)
#
# Once done this will define
#
# FFMPEG_FOUND         - System has the all required components.
# FFMPEG_INCLUDE_DIRS  - Include directory necessary for using the required components headers.
# FFMPEG_LIBRARIES     - Link these to use the required ffmpeg components.
# FFMPEG_DEFINITIONS   - Compiler switches required for using the required ffmpeg components.
#
# For each of the components it will additionally set.
#
# AVCODEC
# AVDEVICE
# AVFORMAT
# AVFILTER
# AVUTIL
# POSTPROC
# SWSCALE
#
# the following variables will be defined
#
# <component>_FOUND        - System has <component>
# <component>_INCLUDE_DIRS - Include directory necessary for using the <component> headers
# <component>_LIBRARIES    - Link these to use <component>
# <component>_DEFINITIONS  - Compiler switches required for using <component>
# <component>_VERSION      - The components version
#
# the following import targets is created
#
# FFmpeg::FFmpeg - for all components
# FFmpeg::<component> - where <component> in lower case (FFmpeg::avcodec) for each components
#
#
# Credits
# -------
#
# Copyright (c) 2006, Matthias Kretz, <kretz@kde.org>
# Copyright (c) 2008, Alexander Neundorf, <neundorf@kde.org>
# Copyright (c) 2011, Michael Jansen, <kde@michael-jansen.biz>
# Copyright (c) 2017, Alexander Drozdov, <adrozdoff@gmail.com>
# Copyright (c) 2023, Xueyan Zhong, <zhongxy@gmail.com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

include(FindPackageHandleStandardArgs)

# The default components were taken from a survey over other FindFFMPEG.cmake files
if(NOT FFmpeg_FIND_COMPONENTS)
    set(FFmpeg_FIND_COMPONENTS AVCODEC AVFORMAT AVUTIL AVDEVICE AVFILTER SWRESAMPLE POSTPROCESS SWSCALE)
endif()

#
# ## Macro: set_component_found
#
# Marks the given component as found if both *_LIBRARIES AND *_INCLUDE_DIRS is present.
#
macro(set_component_found _component)
    if(${_component}_LIBRARIES AND ${_component}_INCLUDE_DIRS)
        message(STATUS "  - ${_component} found.")
        set(${_component}_FOUND TRUE)
    else()
        message(STATUS "  - ${_component} not found.")
    endif()
endmacro()

#
# ## Macro: find_component
#
# Checks for the given component by invoking pkgconfig and then looking up the libraries and
# include directories.
#
macro(find_component _component _header _library)
    find_path(${_component}_INCLUDE_DIRS ${_header}
        HINTS
        ${FFMPEG}
        $ENV{FFMPEG}
        PATH_SUFFIXES include/ffmpeg include ffmpeg
        i686-w64-mingw32/include/ffmpeg
        x86_64-w64-mingw32/include/ffmpeg
        PATHS
        ~/Library/Frameworks
        /Library/Frameworks
        /usr/local/include/ffmpeg
        /usr/include/ffmpeg
        /sw # Fink
        /opt/local # DarwinPorts
        /opt/csw # Blastwave
        /opt
    )
    message(STATUS "L0:${${_component}_INCLUDE_DIRS}")

    # # Lookup the 64 bit libs on x64
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        find_library(${_component}_LIBRARIES ${_library}
            HINTS
            ${FFMPEG}
            $ENV{FFMPEG}
            PATH_SUFFIXES lib64 lib
            lib/x64
            x86_64-w64-mingw32/lib
            PATHS
            /sw
            /opt/local
            /opt/csw
            /opt
        )

    # On 32bit build find the 32bit libs
    else(CMAKE_SIZEOF_VOID_P EQUAL 8)
        FIND_LIBRARY(${_component}_LIBRARIES ${_library}
            HINTS
            ${FFMPEG}
            $ENV{FFMPEG}
            PATH_SUFFIXES lib
            lib/x86
            i686-w64-mingw32/lib
            PATHS
            /sw
            /opt/local
            /opt/csw
            /opt
        )
    endif(CMAKE_SIZEOF_VOID_P EQUAL 8)

    message(STATUS "L1:${${_component}_LIBRARIES}")

    set_component_found(${_component})
endmacro()

# Check for cached results. If there are skip the costly part.
if(NOT FFMPEG_LIBRARIES)
    # Check for all possible component.
    find_component(AVCODEC libavcodec/avcodec.h avcodec)
    find_component(AVFORMAT libavformat/avformat.h avformat)
    find_component(AVDEVICE libavdevice/avdevice.h avdevice)
    find_component(AVUTIL libavutil/avutil.h avutil)
    find_component(AVFILTER libavfilter/avfilter.h avfilter)
    find_component(SWSCALE libswscale/swscale.h swscale)
    find_component(POSTPROCESS libpostproc/postprocess.h postproc)
    find_component(SWRESAMPLE libswresample/swresample.h swresample)

    # Check if the required components were found and add their stuff to the FFMPEG_* vars.
    foreach(_component ${FFmpeg_FIND_COMPONENTS})
        if(${_component}_FOUND)
            message(STATUS "Required component ${_component} present.")
            set(FFMPEG_LIBRARIES ${FFMPEG_LIBRARIES} ${${_component}_LIBRARY} ${${_component}_LIBRARIES})
            set(FFMPEG_DEFINITIONS ${FFMPEG_DEFINITIONS} ${${_component}_DEFINITIONS})

            list(APPEND FFMPEG_INCLUDE_DIRS ${${_component}_INCLUDE_DIRS})
            list(APPEND FFMPEG_LIBRARY_DIRS ${${_component}_LIBRARY_DIRS})

            string(TOLOWER ${_component} _lowerComponent)

            if(NOT TARGET FFmpeg::${_lowerComponent})
                add_library(FFmpeg::${_lowerComponent} INTERFACE IMPORTED)
                set_target_properties(FFmpeg::${_lowerComponent} PROPERTIES
                    INTERFACE_COMPILE_OPTIONS "${${_component}_DEFINITIONS}"
                    INTERFACE_INCLUDE_DIRECTORIES ${${_component}_INCLUDE_DIRS}
                    INTERFACE_LINK_LIBRARIES "${${_component}_LIBRARY} ${${_component}_LIBRARIES}"
                    IMPORTED_LINK_INTERFACE_MULTIPLICITY 3)
            endif()

            # Build the include path with duplicates removed.
            if(FFMPEG_INCLUDE_DIRS)
                list(REMOVE_DUPLICATES FFMPEG_INCLUDE_DIRS)
            endif()

            # cache the vars.
            set(FFMPEG_INCLUDE_DIRS ${FFMPEG_INCLUDE_DIRS} CACHE STRING "The FFmpeg include directories." FORCE)
            set(FFMPEG_LIBRARIES ${FFMPEG_LIBRARIES} CACHE STRING "The FFmpeg libraries." FORCE)
            set(FFMPEG_DEFINITIONS ${FFMPEG_DEFINITIONS} CACHE STRING "The FFmpeg cflags." FORCE)

            mark_as_advanced(
                FFMPEG_INCLUDE_DIRS
                FFMPEG_LIBRARIES
                FFMPEG_DEFINITIONS)
        else()
            message(STATUS "Required component ${_component} missing.")
        endif()
    endforeach()
endif()

if(NOT TARGET FFmpeg::FFmpeg)
    add_library(FFmpeg INTERFACE)
    set_target_properties(FFmpeg PROPERTIES
        INTERFACE_COMPILE_OPTIONS "${FFMPEG_DEFINITIONS}"
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIRS}
        INTERFACE_LINK_LIBRARIES "${FFMPEG_LIBRARIES}")
    add_library(FFmpeg::FFmpeg ALIAS FFmpeg)
endif()

# Now set the noncached _FOUND vars for the components.
foreach(_component AVCODEC AVDEVICE AVFORMAT AVUTIL POSTPROCESS SWSCALE)
    set_component_found(${_component})
endforeach()

# Compile the list of required vars
set(_FFmpeg_REQUIRED_VARS FFMPEG_LIBRARIES FFMPEG_INCLUDE_DIRS)

foreach(_component ${FFmpeg_FIND_COMPONENTS})
    list(APPEND _FFmpeg_REQUIRED_VARS ${_component}_LIBRARIES ${_component}_INCLUDE_DIRS)
endforeach()

# Give a nice error message if some of the required vars are missing.
find_package_handle_standard_args(FFmpeg DEFAULT_MSG ${_FFmpeg_REQUIRED_VARS})