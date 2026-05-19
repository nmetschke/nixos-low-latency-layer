{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  vulkan-headers,
  vulkan-utility-libraries,
  vulkan-loader,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "low-latency-layer";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Korthos-Software";
    repo = "low_latency_layer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YYQpLC3yCvqbArhqeWkZ8rRhVT69qz31SHr5dxXc0zM=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    vulkan-headers
    vulkan-loader
    vulkan-utility-libraries
  ];

  meta = {
    description = "Vulkan layer for hardware agnostic input latency reduction ";
    homepage = "https://github.com/Korthos-Software/low_latency_layer";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
