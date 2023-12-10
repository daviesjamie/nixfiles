{lib, ...}: let
  portOptions = {
    host = lib.mkOption {
      type = lib.types.int;
      description = "The host port (on 127.0.0.1) to expose the container port on.";
    };

    inner = lib.mkOption {
      type = lib.types.int;
      description = "The container port to expose to the host.";
    };
  };

  volumeOptions = {
    name = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The name of the volume.";
    };

    host = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The directory on the host to bind-mount into the container.";
    };

    inner = lib.mkOption {
      type = lib.types.str;
      description = "The directory in the container to mount the volume to.";
    };
  };

  containerOptions = {
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to start the container automatically on boot.";
    };

    cmd = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Command-line arguments to pass to the container image's entrypoint.";
    };

    dependsOn = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "A list of other containers that this one depends on.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "An attrset of environment variables to set for this container.";
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      description = "A list of files containing environment variables to set for this container.";
    };

    extraOptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "A list of extra runtime arguments to pass to the container backend for this container.";
    };

    image = lib.mkOption {
      type = lib.types.str;
      description = "The container image to run.";
    };

    login = {
      username = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The username for the container registry.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "A file containing the password for the container registry.";
      };

      registry = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The container registry to authenticate with.";
      };
    };

    ports = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {options = portOptions;});
      default = [];
      description = "A list of ports to expose.";
    };

    pullOnStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to pull the container image when starting";
    };

    volumes = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {options = volumeOptions;});
      default = [];
      description = "A list of volume definitions.";
    };
  };
in {
  options.nixfiles.containers = {
    backend = lib.mkOption {
      type = lib.types.enum ["docker" "podman"];
      default = "docker";
      description = "The container runtime to use.";
    };

    pods = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          containers = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {options = containerOptions;});
            default = {};
            description = "An attrset of container definitions for this pod.";
          };
          volumeSubDir = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "The subdirectory of the `volumeBaseDir` to store bind-mounts under for this pod.";
          };
        };
      }));
      default = {};
      description = "An attrset of pod definitions.";
    };

    volumeBaseDir = lib.mkOption {
      type = lib.types.str;
      description = "The directory to store volume bind-mounts under.";
    };
  };
}
