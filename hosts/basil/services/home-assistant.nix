{
  virtualisation.oci-containers.containers = {
    home-assistant = {
      autoStart = true;
      image = "ghcr.io/home-assistant/home-assistant:stable";
      ports = [ "8123:8123" ];
      volumes = ["/persist/home-assistant/config:/config"];
    };
  };
}
