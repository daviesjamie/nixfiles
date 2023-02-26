{
  virtualisation.oci-containers.containers = {
    home-assistant = {
      autoStart = true;
      image = "ghcr.io/home-assistant/home-assistant:stable";
      ports = [ "1900:1900" "1901:1901" "5353:5353" "8123:8123" "51827:51827" ];
      volumes = ["/persist/home-assistant/config:/config"];
      extraOptions = ["--device=/dev/ttyUSB0:/dev/ttyUSB0"];
    };
  };
}
