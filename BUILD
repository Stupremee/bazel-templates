load("//:tools/pom_file.bzl", "default_pom_file")
load("//:tools/junit5.bzl", "java_junit5_test")

java_library(
    name = "dummy_library",
    srcs = [
        "src/main/java/template/Dummy.java",
    ],
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
