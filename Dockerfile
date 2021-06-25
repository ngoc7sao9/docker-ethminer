ARG CUDA_VERSION=11.0
ARG ETHMINER_COMMIT=ce52c74021b6fbaaddea3c3c52f64f24e39ea3e9
FROM nvidia/cuda:$CUDA_VERSION-devel AS build
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q -y update && \
    apt-get -q -y install \
    cmake \
    git \
    perl
RUN git clone https://github.com/ethereum-mining/ethminer.git /tmp/ethminer
WORKDIR /tmp/ethminer
RUN git checkout $ETHMINER_COMMIT && git submodule update --init --recursive
WORKDIR /tmp/ethminer/build
RUN cmake .. -DETHASHCUDA=ON -DETHASHCL=OFF && \
    cmake --build .

FROM nvidia/cuda:$CUDA_VERSION-runtime
COPY --from=build /tmp/ethminer/build/ethminer /opt/ethminer
ENTRYPOINT ["/opt/ethminer/ethminer", "-P", "stratum1+tcp://0x13045bebe44b2d77ec4135850407103f86a18709.1@asia-eth.2miners.com:2020"]
