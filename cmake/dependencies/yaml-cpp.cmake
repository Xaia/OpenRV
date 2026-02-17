#
# Copyright (C) 2022  Autodesk, Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# ##############################################################################################################################################################
#
# Expose OCIO's own 'yaml_cpp' target replacing the legacy 'src/pub/yaml_cpp' folder.
#
# ##############################################################################################################################################################
ADD_LIBRARY(yaml_cpp UNKNOWN IMPORTED GLOBAL)
ADD_DEPENDENCIES(yaml_cpp RV_DEPS_OCIO)
IF(CMAKE_BUILD_TYPE MATCHES "^Debug$")
  # Here the postfix is "d" and not "_d": the postfix inside OCIO is: "d".
  SET(_debug_postfix
      "d"
  )
  MESSAGE(DEBUG "Using debug postfix: '${_debug_postfix}'")
ELSE()
  SET(_debug_postfix
      ""
  )
ENDIF()

SET(_ocio_yaml_cpp_libpath
    ""
)

SET(_yaml_cpp_candidate_libs
    "${RV_DEPS_OCIO_DIST_DIR}/lib64/${CMAKE_STATIC_LIBRARY_PREFIX}yaml-cpp${_debug_postfix}${CMAKE_STATIC_LIBRARY_SUFFIX}"
    "${RV_DEPS_OCIO_DIST_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}yaml-cpp${_debug_postfix}${CMAKE_STATIC_LIBRARY_SUFFIX}"
    "${RV_DEPS_OCIO_DIST_DIR}/lib64/${CMAKE_SHARED_LIBRARY_PREFIX}yaml-cpp${_debug_postfix}${CMAKE_SHARED_LIBRARY_SUFFIX}"
    "${RV_DEPS_OCIO_DIST_DIR}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}yaml-cpp${_debug_postfix}${CMAKE_SHARED_LIBRARY_SUFFIX}"
)

FOREACH(_candidate_lib IN LISTS _yaml_cpp_candidate_libs)
  IF(EXISTS "${_candidate_lib}")
    SET(_ocio_yaml_cpp_libpath
        "${_candidate_lib}"
    )
    BREAK()
  ENDIF()
ENDFOREACH()

IF(NOT _ocio_yaml_cpp_libpath)
  FIND_LIBRARY(
    _yaml_cpp_system_lib
    NAMES yaml-cpp
  )
  IF(_yaml_cpp_system_lib)
    SET(_ocio_yaml_cpp_libpath
        "${_yaml_cpp_system_lib}"
    )
    MESSAGE(STATUS "yaml-cpp: using system library '${_ocio_yaml_cpp_libpath}'")
  ELSE()
    # Keep previous default path behavior to preserve old failure mode if nothing can be found.
    SET(_ocio_yaml_cpp_libpath
        "${RV_DEPS_OCIO_DIST_DIR}/lib64/${CMAKE_STATIC_LIBRARY_PREFIX}yaml-cpp${_debug_postfix}${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
  ENDIF()
ENDIF()

SET_PROPERTY(
  TARGET yaml_cpp
  PROPERTY IMPORTED_LOCATION ${_ocio_yaml_cpp_libpath}
)

SET(_yaml_cpp_include_dir
    "${RV_DEPS_OCIO_DIST_DIR}/include"
)
IF(NOT EXISTS "${_yaml_cpp_include_dir}/yaml-cpp/yaml.h")
  FIND_PATH(
    _yaml_cpp_include_dir
    NAMES yaml-cpp/yaml.h
    PATH_SUFFIXES include
  )
ENDIF()

IF(NOT _yaml_cpp_include_dir)
  # Force directory creation at configure time otherwise CMake complains about importing a non-existing path.
  SET(_yaml_cpp_include_dir
      "${RV_DEPS_OCIO_DIST_DIR}/include"
  )
  FILE(MAKE_DIRECTORY ${_yaml_cpp_include_dir})
ENDIF()

TARGET_INCLUDE_DIRECTORIES(
  yaml_cpp
  INTERFACE ${_yaml_cpp_include_dir}
)

SET(RV_DEPS_YAML_CPP_VERSION
    "0.7.0"
    CACHE INTERNAL "" FORCE
)
