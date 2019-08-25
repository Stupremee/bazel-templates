load("//:tools/project.bzl", "ARTIFACT_ID", "ARTIFACT_NAME", "DESCRIPTION", "GROUP_ID", "URL", "VERSION")

MavenInfo = provider(
    fields = {
        "maven_artifacts": """
        The Maven coordinates for the artifacts that are exported by this target: i.e. the target
        itself and its transitively exported targets.
        """,
        "maven_dependencies": """
        The Maven coordinates of the direct dependencies, and the transitively exported targets, of
        this target.
        """,
    },
)

_EMPTY_MAVEN_INFO = MavenInfo(
    maven_artifacts = depset(),
    maven_dependencies = depset(),
)

_MAVEN_COORDINATES_PREFIX = "maven_coordinates="

def _maven_artifacts(targets):
    return [target[MavenInfo].maven_artifacts for target in targets if MavenInfo in target]

def _collect_maven_info_impl(_target, ctx):
    tags = getattr(ctx.rule.attr, "tags", [])
    deps = getattr(ctx.rule.attr, "deps", [])
    exports = getattr(ctx.rule.attr, "exports", [])

    maven_artifacts = []
    for tag in tags:
        if tag in ("maven:compile_only", "maven:shaded"):
            return [_EMPTY_MAVEN_INFO]
        if tag.startswith(_MAVEN_COORDINATES_PREFIX):
            maven_artifacts.append(tag[len(_MAVEN_COORDINATES_PREFIX):])

    return [MavenInfo(
        maven_artifacts = depset(maven_artifacts, transitive = _maven_artifacts(exports)),
        maven_dependencies = depset([], transitive = _maven_artifacts(deps + exports)),
    )]

_collect_maven_info = aspect(
    attr_aspects = [
        "deps",
        "exports",
    ],
    doc = """
    Collects the Maven information for targets, their dependencies, and their transitive exports.
    """,
    implementation = _collect_maven_info_impl,
)

def _prefix_index_of(item, prefixes):
    for index, prefix in enumerate(prefixes):
        if item.startswith(prefix):
            return index
    return len(prefixes)

def _sort_artifacts(artifacts, prefixes):
    indexed = []
    for artifact in artifacts:
        parts = artifact.split(":")
        indexed.append((_prefix_index_of(parts[0], prefixes), parts, artifact))

    return [x[-1] for x in sorted(indexed)]

DEP_BLOCK = """
<dependency>
  <groupId>{0}</groupId>
  <artifactId>{1}</artifactId>
  <version>{2}</version>
</dependency>
""".strip()

CLASSIFIER_DEP_BLOCK = """
<dependency>
  <groupId>{0}</groupId>
  <artifactId>{1}</artifactId>
  <version>{2}</version>
  <type>{3}</type>
  <classifier>{4}</classifier>
</dependency>
""".strip()

def _pom_file(ctx):
    mvn_deps = depset(
        [],
        transitive = [target[MavenInfo].maven_dependencies for target in ctx.attr.targets],
    )

    formatted_deps = []
    for dep in _sort_artifacts(mvn_deps.to_list(), ctx.attr.preferred_group_ids):
        parts = dep.split(":")
        if ":".join(parts[0:2]) in ctx.attr.excluded_artifacts:
            continue
        if len(parts) == 3:
            template = DEP_BLOCK
        elif len(parts) == 5:
            template = CLASSIFIER_DEP_BLOCK
        else:
            fail("Unknown dependency format: %s" % dep)

        formatted_deps.append(template.format(*parts))

    substitutions = {}
    substitutions.update(ctx.attr.substitutions)
    substitutions.update({
        "{generated_bzl_deps}": "\n".join(formatted_deps),
    })

    ctx.actions.expand_template(
        template = ctx.file.template_file,
        output = ctx.outputs.pom_file,
        substitutions = substitutions,
    )

pom_file = rule(
    attrs = {
        "template_file": attr.label(
            allow_single_file = True,
        ),
        "substitutions": attr.string_dict(
            allow_empty = True,
            mandatory = False,
        ),
        "targets": attr.label_list(
            mandatory = True,
            aspects = [_collect_maven_info],
        ),
        "preferred_group_ids": attr.string_list(),
        "excluded_artifacts": attr.string_list(),
    },
    outputs = {"pom_file": "%{name}.xml"},
    implementation = _pom_file,
)

def default_pom_file(name, targets, **kwargs):
    pom_file(
        name = name,
        targets = targets,
        preferred_group_ids = [
            GROUP_ID,
        ],
        template_file = "tools/pom-template.xml",
        substitutions = {
            "{group_id}": GROUP_ID,
            "{artifact_id}": ARTIFACT_ID,
            "{project_description}": DESCRIPTION,
            "{project_version}": VERSION,
            "{project_url}": URL,
            "{artifact_name}": ARTIFACT_NAME,
        },
        **kwargs
    )
