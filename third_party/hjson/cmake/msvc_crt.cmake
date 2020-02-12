if(NOT MSVC)
  message(FATAL_ERROR "CRT options are available only for MSVC")
endif()

if(${BUILD_WITH_STATIC_CRT} MATCHES "Yes")
  foreach(flag_var
          CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
          CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
          CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
          CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    if(${flag_var} MATCHES "/MD")
      string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
    endif()
    if(${flag_var} MATCHES "/MDd")
      string(REGEX REPLACE "/MDd" "/MTd" ${flag_var} "${${flag_var}}")
    endif()
    set(${flag_var} "${${flag_var}}" CACHE STRING "" FORCE)
  endforeach(flag_var)

  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:atlthunk.lib /NODEFAULTLIB:msvcrt.lib /NODEFAULTLIB:msvcrtd.lib")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} /NODEFAULTLIB:libcmt.lib")
  set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /NODEFAULTLIB:libcmtd.lib")
elseif(${BUILD_WITH_STATIC_CRT} MATCHES "No")
  foreach(flag_var
          CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
          CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
          CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
          CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    if(${flag_var} MATCHES "/MT")
      string(REGEX REPLACE "/MT" "/MD" ${flag_var} "${${flag_var}}")
    endif()
    if(${flag_var} MATCHES "/MTd")
      string(REGEX REPLACE "/MTd" "/MDd" ${flag_var} "${${flag_var}}")
    endif()
    set(${flag_var} "${${flag_var}}" CACHE STRING "" FORCE)
  endforeach(flag_var)
endif()
