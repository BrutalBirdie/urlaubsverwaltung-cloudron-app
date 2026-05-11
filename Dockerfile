# ---------------------------------------------------------------------------
# Builder: clone the slint-ui fork at a pinned ref and build the fat jar.
# Override the ref at build time:
#     cloudron build --build-arg UV_REF=<sha-or-branch-or-tag>
# ---------------------------------------------------------------------------
FROM eclipse-temurin:25-jdk-noble AS builder

ARG UV_REPO=https://github.com/slint-ui/urlaubsverwaltung.git
ARG UV_REF=7547e7bc6b17ab32af17a25d42b7d621504f93ca

ENV MAVEN_OPTS="-Dmaven.repo.local=/root/.m2/repository -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn"

RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN git init . \
 && git remote add origin "${UV_REPO}" \
 && git -c protocol.version=2 fetch --depth 1 origin "${UV_REF}" \
 && git checkout --detach FETCH_HEAD \
 && git rev-parse HEAD > /build/.uv-commit

RUN ./mvnw -B -ntp -DskipTests clean package \
 && cp target/urlaubsverwaltung-*.jar /tmp/urlaubsverwaltung.jar

# ---------------------------------------------------------------------------
# Runtime: Cloudron base + Liberica JRE 25.
# ---------------------------------------------------------------------------
FROM cloudron/base:5.0.0

ENV LIBERICA_VERSION=25.0.2+12 \
    JAVA_HOME=/opt/jdk-25 \
    PATH=/opt/jdk-25/bin:$PATH

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) liberica_arch=amd64 ;; \
      arm64) liberica_arch=aarch64 ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    url="https://download.bell-sw.com/java/${LIBERICA_VERSION}/bellsoft-jdk${LIBERICA_VERSION}-linux-${liberica_arch}.tar.gz"; \
    curl -fsSL "$url" -o /tmp/jdk.tar.gz; \
    mkdir -p /opt/jdk-25; \
    tar -xzf /tmp/jdk.tar.gz -C /opt/jdk-25 --strip-components=1; \
    rm /tmp/jdk.tar.gz; \
    java -version

RUN mkdir -p /app/code /app/data
WORKDIR /app/code

COPY --from=builder /tmp/urlaubsverwaltung.jar /app/code/urlaubsverwaltung.jar
COPY --from=builder /build/.uv-commit /app/code/.uv-commit
COPY cloudron/start.sh /app/code/start.sh
RUN chmod +x /app/code/start.sh

EXPOSE 8080

CMD ["/app/code/start.sh"]
