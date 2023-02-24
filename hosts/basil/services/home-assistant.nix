{
  virtualisation.oci-containers.containers = {
    home-assistant = {
      autoStart = true;
      image = "ghcr.io/home-assistant/home-assistant:stable";
      volumes = ["/persist/home-assistant/config:/config"];
      extraOptions = ["--network=host" "--privileged"];
    };
  };
}
