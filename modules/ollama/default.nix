{ pkgs, ... }:

{
  # Vulkan backend runs inference on the Intel iGPU.
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
  };
}
