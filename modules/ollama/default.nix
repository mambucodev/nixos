{ pkgs, ... }:

{
  # Vulkan backend runs inference on the Intel iGPU.
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
    # Listen beyond loopback so Podman containers can reach it via
    # host.containers.internal. Port 11434 stays closed in the firewall.
    host = "0.0.0.0";
  };
}
