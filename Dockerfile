FROM busybox as stage0

ADD https://github.com/LunaMultiplayer/LunaMultiplayer/releases/download/0.27.0/LunaMultiplayer-Release.zip /
RUN unzip LunaMultiplayer-Release.zip

FROM mono
COPY --from=stage0 /LMPServer /LMPServer
VOLUME "/LMPServer/Config" "/LMPServer/Plugins" "/LMPServer/Universe" "/LMPServer/logs"
STOPSIGNAL sigint

WORKDIR /LMPServer
CMD mono Server.exe
