FROM fafre/luajit-v2.1:latest as lua_builder
FROM debian:stable-slim as o2p_builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    git ca-certificates make cmake g++ libboost-dev libboost-system-dev \
    libboost-filesystem-dev libexpat1-dev zlib1g-dev \
    libbz2-dev libpq-dev libproj-dev pandoc\
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch 1.7.1 https://github.com/openstreetmap/osm2pgsql.git

COPY --from=lua_builder /usr/local/lib/libluajit* /usr/local/lib/
COPY --from=lua_builder /usr/local/include/luajit-2.1/ /usr/local/include/luajit-2.1/

WORKDIR /osm2pgsql/build
RUN cmake -D WITH_LUAJIT=ON .. && make && make install

FROM scratch

COPY --from=o2p_builder /usr/local/bin/osm2pgsql /usr/local/bin/
COPY --from=o2p_builder /usr/local/bin/osm2pgsql-replication /usr/local/bin/