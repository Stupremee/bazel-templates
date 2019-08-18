DEPENDENCY_LIST = [
]

MAVEN_REPOSITORIES = [
    "http://central.maven.org/maven2/",
]

def install_maven_dependencies(fetch_sources = True, **kwargs):
    native.maven_install(
        artifacts = DEPENDENCY_LIST,
        fetch_sources = fetch_sources,
        repositories = MAVEN_REPOSITORIES,
        **kwargs
    )
