{
  config,
  lib,
  pkgs,
  ...
}: let
  mkPortDef = {
    expose,
    host,
    inner,
  }: let
    ip = if expose then "0.0.0.0" else "127.0.0.1";
  in "${ip}:${toString host}:${toString inner}";

  mkVolumeDef = container: {
    name,
    host,
    inner,
    ...
  }:
    if host != null
    then "${host}:${inner}"
    else "${cfg.volumeBaseDir}/${container.volumeSubDir}/${name}:${inner}";

  shouldPreStart = _name: container: container.pullOnStart;

  mkPreStart = name: container:
    lib.nameValuePair "${cfg.backend}-${name}" {
      preStart =
        if container.pullOnStart
        then "${cfg.backend} pull ${container.image}"
        else "";
    };

  shouldNetworkService = _name: container: container.network != null;

  mkNetworkService = _name: container: let
    package =
      if cfg.backend == "docker"
      then pkgs.docker
      else pkgs.podman;
  in
    lib.nameValuePair "${cfg.backend}-net-${container.network}" {
      description = "Manage the ${container.network} network for ${cfg.backend}";
      preStart = "${package}/bin/${cfg.backend} network rm ${container.network} || true";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${package}/bin/${cfg.backend} network create -d bridge ${container.network}";
        ExecStop = "${package}/bin/${cfg.backend} network rm ${container.network}";
        RemainAfterExit = "yes";
      };
    };

  mkPodService = name: pod: let
    package =
      if cfg.backend == "podman"
      then pkgs.podman
      else throw "mkPodService only supports podman";
    aliases = map (cn: "${name}-${cn}") (lib.attrNames pod.containers);
    ports = lib.concatLists (lib.catAttrs "ports" (lib.attrValues pod.containers));
  in
    lib.nameValuePair "${cfg.backend}-pod-${name}" {
      description = "Manage the ${name} pod for ${cfg.backend}";
      preStart = "${package}/bin/${cfg.backend} pod rm --force --ignore ${name} || true";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = let
          args = map (n: "--network-alias=${n}") aliases ++ map (pd: "-p ${mkPortDef pd}") ports;
        in "${package}/bin/${cfg.backend} pod create ${lib.concatStringsSep " " args} ${name}";
        ExecStop = "${package}/bin/${cfg.backend} pod rm ${name}";
        RemainAfterExit = "yes";
      };
    };

  mkContainer = _name: container: let
    hasNetwork = container.network != null;
    hasPod = container.pod != null;
  in {
    inherit (container) autoStart cmd environment environmentFiles image login;
    dependsOn =
      container.dependsOn
      ++ (
        if hasNetwork
        then ["net-${container.network}"]
        else []
      )
      ++ (
        if hasPod
        then ["pod-${container.pod}"]
        else []
      );
    extraOptions =
      container.extraOptions
      ++ (
        if hasNetwork
        then ["--network=${container.network}"]
        else []
      )
      ++ (
        if hasPod
        then ["--pod=${container.pod}"]
        else []
      );
    ports =
      if hasPod
      then []
      else map mkPortDef container.ports;
    volumes = map (mkVolumeDef container) container.volumes;
  };

  mkVolumeTmpFiles = name: container:
    lib.nameValuePair "${cfg.backend}-${name}" (builtins.listToAttrs
      (map (volume: {
          name =
            if volume.host != null
            then volume.host
            else "${cfg.volumeBaseDir}/${container.volumeSubDir}/${volume.name}";
          value = {
            d = {
              user = volume.user;
              group = volume.group;
              mode = volume.mode;
            };
          };
        })
        container.volumes));

  cfg = config.nixfiles.containers;

  allContainers = let
    mkPodContainer = podName: pod: containerName: container:
      lib.nameValuePair "${podName}-${containerName}" (
        container
        // {
          network =
            if cfg.backend == "docker"
            then podName
            else null;
          pod =
            if cfg.backend == "docker"
            then null
            else podName;
          volumeSubDir = pod.volumeSubDir;
        }
      );
  in
    lib.concatMapAttrs (podName: pod: lib.mapAttrs' (mkPodContainer podName pod) pod.containers) cfg.pods;
in {
  imports = [
    ./options.nix
  ];

  config = {
    virtualisation.${cfg.backend}.autoPrune.enable = true;
    virtualisation.oci-containers.backend = cfg.backend;
    virtualisation.oci-containers.containers = lib.mapAttrs mkContainer allContainers;
    systemd.services = lib.mkMerge [
      (lib.mapAttrs' mkPreStart (lib.filterAttrs shouldPreStart allContainers))
      (lib.mapAttrs' mkNetworkService (lib.filterAttrs shouldNetworkService allContainers))
      (
        if cfg.backend == "podman"
        then lib.mapAttrs' mkPodService cfg.pods
        else {}
      )
    ];
    systemd.tmpfiles.settings = lib.mapAttrs' mkVolumeTmpFiles allContainers;
  };
}
