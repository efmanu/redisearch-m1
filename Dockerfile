FROM arm64v8/ubuntu:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y build-essential wget

# Download Redis source code
RUN wget http://download.redis.io/releases/redis-6.2.5.tar.gz && \
    tar xzf redis-6.2.5.tar.gz && \
    rm redis-6.2.5.tar.gz

# Build Redis
WORKDIR /redis-6.2.5
RUN make

# Build Redisearch
WORKDIR /redis-6.2.5/deps
RUN git clone https://github.com/RediSearch/RediSearch.git && \
    cd RediSearch && \
    git checkout v2.2.2 && \
    make BUILD_ENV=arm64

# Copy Redisearch module to Redis module directory
WORKDIR /redis-6.2.5/src
RUN cp ../deps/RediSearch/build/RedisModules/redisearch.so ./

# Cleanup
WORKDIR /redis-6.2.5
RUN make distclean && \
    rm -rf deps/RediSearch

# Expose Redis port
EXPOSE 6379

# Start Redis server with Redisearch module loaded
CMD ["./redis-server", "--loadmodule", "./redisearch.so"]
