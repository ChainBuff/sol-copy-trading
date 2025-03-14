FROM ubuntu:24.04

ENV RUST_LOG=info

RUN sed -i 's@archive.ubuntu.com@mirrors.aliyun.com@g' /etc/apt/sources.list && \
    sed -i 's@security.ubuntu.com@mirrors.aliyun.com@g' /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./run/copy-trading /app/copy-trading

RUN chmod +x /app/copy-trading

# 4. 设置工作目录和启动命令
WORKDIR /app

ENTRYPOINT ["./copy-trading"]