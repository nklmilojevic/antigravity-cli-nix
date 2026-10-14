{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.3.5";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.5-6164039479459840/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "0fa5ff7ca8661ef6379da219dd30552327b0deaf112ea896882daaba8bd6abff76ff097ef7b38211bffb78be6871f7494a1739b7160b483cb68481a24d435c47";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.5-6164039479459840/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "8b57ef509bdddf6ed02824ba8cdf44ec4bcefef91066e1215d5c39566181d10f7b93206545b97fa2683595a595e12311b10cd34c12cd58b3afed65d4a70ac4dd";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.5-6164039479459840/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "f82152f8cc6fb01f59b63ed9e7f17b5ca4ae4e8d5d0ded864d60f909b54a37fc1158cd93b416bb843bd2662d6b5ed5843e8cc0a5dfc7e7622bbd1372cb1ddf91";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.5-6164039479459840/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "8ed16057c9bd9e452b99f7bd424a4c63959faae75e5fa94b4f9b1bf20769f7c6deb8ec9c88f3c17944f09bcfaa04950b981fcb1eb6994bf65ae74772a9ffe080";
    };
  };

  currentPlatform = platformInfo.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

in stdenv.mkDerivation {
  pname = "antigravity-cli";
  inherit version;

  src = fetchurl {
    inherit (currentPlatform) url sha512;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 antigravity $out/libexec/antigravity-cli/agy
    makeWrapper $out/libexec/antigravity-cli/agy $out/bin/agy \
      --set AGY_CLI_DISABLE_AUTO_UPDATE 1

    runHook postInstall
  '';

  meta = with lib; {
    description = "Antigravity CLI - Google's agentic coding assistant in your terminal";
    homepage = "https://antigravity.google";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "agy";
  };
}
