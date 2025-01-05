cmake_minimum_required(VERSION 3.16)

project(MarketChronicle C CXX)

include(cmake/common.cmake)

get_filename_component(api_proto "../protos/api.proto" ABSOLUTE)
get_filename_component(api_proto_path "${api_proto}" PATH)

set(api_proto_srcs "${CMAKE_CURRENT_BINARY_DIR}/api.pb.cc")
set(api_proto_hdrs "${CMAKE_CURRENT_BINARY_DIR}/api.pb.h")
set(api_grpc_srcs "${CMAKE_CURRENT_BINARY_DIR}/api.grpc.pb.cc")
set(api_grpc_hdrs "${CMAKE_CURRENT_BINARY_DIR}/api.grpc.pb.h")
add_custom_command(
      OUTPUT "${api_proto_srcs}" "${api_proto_hdrs}" "${api_grpc_srcs}" "${api_grpc_hdrs}"
      COMMAND ${_PROTOBUF_PROTOC}
      ARGS --grpc_out "${CMAKE_CURRENT_BINARY_DIR}"
        --cpp_out "${CMAKE_CURRENT_BINARY_DIR}"
        -I "${api_proto_path}"
        --plugin=protoc-gen-grpc="${_GRPC_CPP_PLUGIN_EXECUTABLE}"
        "${api_proto}"
      DEPENDS "${api_proto}")

include_directories("${CMAKE_CURRENT_BINARY_DIR}")

add_library(api_grpc_proto
  ${api_grpc_srcs}
  ${api_grpc_hdrs}
  ${api_proto_srcs}
  ${api_proto_hdrs})
target_link_libraries(api_grpc_proto
  absl::check
  ${_REFLECTION}
  ${_GRPC_GRPCPP}
  ${_PROTOBUF_LIBPROTOBUF})

add_executable(server server.cpp)
target_link_libraries(${_target}
api_grpc_proto
absl::check
absl::flags
absl::flags_parse
absl::log
${_REFLECTION}
${_GRPC_GRPCPP}
${_PROTOBUF_LIBPROTOBUF})


