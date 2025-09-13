# Stage 1: Precompile TestRunner
FROM swift:6.1.2 AS builder
RUN swift --version

# Build TestRunner executable
WORKDIR /TestRunner
COPY src/TestRunner .
RUN swift build --configuration release --enable-experimental-prebuilts

# Stage 2: Prepare docker container image
FROM swift:6.1.2
RUN apt-get update && apt-get install -y jq

WORKDIR /opt/test-runner

# Build TestEnvironment package
# Build directory and final working paths should be equal for reuse of ModuleCache.
COPY src/TestEnvironment .
RUN swift build --build-tests

COPY bin/run.sh bin/run-test.sh bin/
COPY --from=builder /TestRunner/.build/release/TestRunner bin/

ENV RUN_IN_DOCKER=TRUE

ENTRYPOINT ["./bin/run.sh"]
