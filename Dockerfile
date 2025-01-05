FROM ubuntu:24.04

RUN apt-get -y update && apt-get install -y --no-install-recommends build-essential gcc git pkg-config curl ca-certificates

WORKDIR /opt/

RUN apt-get install libssl-dev

RUN curl -OL https://github.com/Kitware/CMake/releases/download/v3.31.3/cmake-3.31.3.tar.gz && \
tar -xvf cmake-3.31.3.tar.gz && \ 
cd cmake-3.31.3 && \
./bootstrap && \
make -j  4 && \
make install



WORKDIR /opt/

RUN apt-get install -y --no-install-recommends autoconf libtool

RUN git clone https://github.com/grpc/grpc.git --recurse-submodules --branch v1.69.0 --single-branch --depth=1 --shallow-submodules

RUN cd grpc && git submodule update --init --depth=1

WORKDIR /opt/grpc

RUN mkdir -p cmake/build && \
cd cmake/build && \
cmake ../.. -DgRPC_INSTALL=ON                \
              -DBUILD_DEPS=ON                   \
              -DCMAKE_BUILD_TYPE=Release       \
              -DgRPC_ABSL_PROVIDER=module     \
              -DgRPC_CARES_PROVIDER=module    \
              -DgRPC_PROTOBUF_PROVIDER=module \
              -DgRPC_RE2_PROVIDER=module      \
             -DgRPC_SSL_PROVIDER=module      \
              -DgRPC_ZLIB_PROVIDER=module && \
make -j 4  && \
make install

WORKDIR /app/