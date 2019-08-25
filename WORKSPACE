workspace(name = "template")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Download jvm external rules
RULES_JVM_EXTERNAL_TAG = "2.6.1"

RULES_JVM_EXTERNAL_SHA = "45203b89aaf8b266440c6b33f1678f516a85b3e22552364e7ce6f7c0d7bdc772"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

# Load JUnit5
load("//:tools/junit5.bzl", "junit_jupiter_java_repositories", "junit_platform_java_repositories")

# Initialize JUnit5
JUNIT_JUPITER_VERSION = "5.5.1"

JUNIT_PLATFORM_VERSION = "1.5.1"

junit_jupiter_java_repositories(
    version = JUNIT_JUPITER_VERSION,
)

junit_platform_java_repositories(
    version = JUNIT_PLATFORM_VERSION,
)

load("//:tools/dependencies.bzl", "install_maven_dependencies")

install_maven_dependencies()
