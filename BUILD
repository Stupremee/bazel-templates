load("//:tools/pom_file.bzl", "default_pom_file")
load("//:tools/junit5.bzl", "java_junit5_test")
load("//:tools/javadoc.bzl", "javadoc_library")

DUMMY_SRCS = [
    "src/main/java/template/Dummy.java",
]

java_library(
    name = "dummy_library",
    srcs = DUMMY_SRCS,
)

javadoc_library(
    name = "dummy_javadoc",
    srcs = DUMMY_SRCS,
    root_packages = ["template"],
    deps = [":dummy_library"],
)

default_pom_file(
    name = "dummy_pom_xml",
    targets = [
        ":dummy_library",
    ],
)

java_junit5_test(
    name = "dummy_test",
    srcs = [
        "src/test/java/template/DummyTest.java",
    ],
    test_package = "template",
    deps = [
        ":dummy_library",
    ],
)
