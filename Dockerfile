FROM ubuntu
LABEL maintainers="Kubernetes Authors"
LABEL description="HostPath Driver"
ARG binary=./bin/hostpathplugin

# Add util-linux to get a new version of losetup.
RUN apt-get update && apt-get install -y util-linux curl
COPY ${binary} /hostpathplugin
ENTRYPOINT ["/hostpathplugin"]
