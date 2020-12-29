FROM alpine:edge as builder

RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib wget bash git mono@testing && \
    wget https://dot.net/v1/dotnet-install.sh && \
    chmod +x ./dotnet-install.sh && ./dotnet-install.sh -c 5.0

ADD https://github.com/LunaMultiplayer/LunaMultiplayer/tarball/master /master.tgz
RUN tar xvf master.tgz && mv LunaMultiplayer-LunaMultiplayer* LunaMultiplayer && \
    cd LunaMultiplayer/Server && \
    export PATH=$PATH:/root/.dotnet && \
    export FrameworkPathOverride=/usr/lib/mono/4.6-api/ && \
    dotnet publish -r linux-musl-x64 -o Publish

FROM alpine:edge
RUN apk add icu-libs libstdc++ libgcc
COPY --from=builder /LunaMultiplayer/Server/Publish/ /LMPServer/
VOLUME "/LMPServer/Config" "/LMPServer/Plugins" "/LMPServer/Universe" "/LMPServer/logs"
STOPSIGNAL sigint
WORKDIR /LMPServer
CMD ./Server

# Image needs a tty to send the int signal so the server can properly shutdown
# IE: docker run ... -t dazoe/lunamultiplayer:...
