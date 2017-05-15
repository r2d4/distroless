def _impl(ctx):
  _hello_go(ctx, ctx.attr.contents, ctx.outputs.out.path)

def _hello_go(ctx, contents, output_path):
  ctx.action(
    executable = ctx.executable.hello_go,
    arguments = [contents, output_path],
    outputs = [ctx.outputs.out],
  )

execute = rule(
  implementation=_impl,
  attrs={
          "hello_go": attr.label(
                                default = Label("//demo:hello_go"),
                                cfg = "host",
                                allow_files=True,
                                executable=True),
          "contents": attr.string(),
          "out": attr.output(mandatory=True),
      },
)
