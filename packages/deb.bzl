load(":deb_pkg.bzl", "deb_pkg")
load(":deb_pkg_src.bzl", "deb_pkg_src")

def _debgetter_select_impl = repository_rule(
    os = ctx.os.name
    if os == 'linux':

    ctx.file("WORKSPACE", "workspace(name = '%s')" % ctx.name)
)

_debgetter_repository_select = repository_rule(
    _debgetter_select_impl,
    attr = {
        "_linux": attr.label(
            default = Label("@debgetter_linux//debgetter_linux"),
            allow_files = True,
            single_file = True,
        ),
        "_darwin": attr.label(
            default = Label("@debgetter_darwin//debgetter_darwin"),
            allow_files = True,
            single_file = True,
        ),
        "_windows": attr.label(
            default = Label("@debgetter_windows//debgetter_windows"),
            allow_files = True,
            single_file = True,
        ),
    }
)

def deb_pkg_repositories():
  native.http_file(
      name="debgetter_linux",
      url = "https://storage.googleapis.com/r2d4minikube/debgetter-linux",
      sha256 = "0be955470c9cf852a90bc03c97e2ee837d0a6481eb51d5203ea6108b93e1709f"
  )
  native.http_file(
      name="debgetter_windows",
      url = "https://storage.googleapis.com/r2d4minikube/debgetter-windows",
      sha256 = "b9c5f65dafaa5afcb7e9a7c721b654de0277dbaaf5b407e2d4a5e9715f9d2772"
  )
  native.http_file(
      name="debgetter_darwin",
      url = "https://storage.googleapis.com/r2d4minikube/debgetter-darwin",
      sha256 = "f3bfb4e0a0fb561a87031c5fed6f585966eae911ae72c79c8f286a3d1b54d520"
  )

  _debgetter_select(
      name = "debgetter_select",
  )