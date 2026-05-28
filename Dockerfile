FROM cloudron/base:5.0.0

# renovate: datasource=github-releases depName=urlaubsverwaltung/urlaubsverwaltung
ARG URLAUBSVERWALTUNG_VERSION=6.0.0-M5

ENV JAVA_HOME=/opt/jdk \
    PATH=/opt/jdk/bin:$PATH

# Resolve the Liberica JDK version from upstream's .tool-versions at the pinned
# release tag, so the runtime JDK always matches what upstream tests against.
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) liberica_arch=amd64 ;; \
      arm64) liberica_arch=aarch64 ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    tool_versions_url="https://raw.githubusercontent.com/urlaubsverwaltung/urlaubsverwaltung/urlaubsverwaltung-${URLAUBSVERWALTUNG_VERSION}/.tool-versions"; \
    liberica_version="$(curl -fsSL "$tool_versions_url" | awk '$1 == "java" { sub(/^liberica-/, "", $2); print $2 }')"; \
    test -n "$liberica_version" || { echo "could not parse liberica version from $tool_versions_url" >&2; exit 1; }; \
    url="https://download.bell-sw.com/java/${liberica_version}/bellsoft-jdk${liberica_version}-linux-${liberica_arch}.tar.gz"; \
    curl -fsSL "$url" -o /tmp/jdk.tar.gz; \
    mkdir -p /opt/jdk; \
    tar -xzf /tmp/jdk.tar.gz -C /opt/jdk --strip-components=1; \
    rm /tmp/jdk.tar.gz; \
    echo "$liberica_version" > /opt/jdk/.liberica-version; \
    java -version

RUN mkdir -p /app/code /app/data
WORKDIR /app/code

RUN curl -fsSL "https://github.com/urlaubsverwaltung/urlaubsverwaltung/releases/download/urlaubsverwaltung-${URLAUBSVERWALTUNG_VERSION}/urlaubsverwaltung-${URLAUBSVERWALTUNG_VERSION}.jar" \
      -o /app/code/urlaubsverwaltung.jar \
 && echo "${URLAUBSVERWALTUNG_VERSION}" > /app/code/.urlaubsverwaltung-version

COPY start.sh /app/pkg/start.sh
RUN chmod +x /app/pkg/start.sh

CMD ["/app/pkg/start.sh"]
