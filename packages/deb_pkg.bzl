def _impl(ctx):
  args = [
    "-fetch-package",
    "-source-file=" + ctx.file.source.path,
    "-source-url=" + ctx.attr.source.base_url,
    "-pkg-name=" + ctx.attr.pkg_name,
    "-output-file=" + ctx.outputs.deb.path
  ]

  ctx.action(
    executable = ctx.executable.package_getter,
    inputs = [ctx.file.source],
    arguments = args,
    outputs = [ctx.outputs.deb],
  )

deb_pkg = rule(
    attrs = {
        "package_getter": attr.label(
            default = Label("//packages/deb_pkg:deb_pkg"),
            cfg = "host",
            allow_files = True,
            executable = True,
        ),
        "source": attr.label(allow_single_file = True),
        "pkg_name": attr.string(),
    },
    outputs = {
        "deb": "%{pkg_name}.deb",
    },
    implementation = _impl,
)
