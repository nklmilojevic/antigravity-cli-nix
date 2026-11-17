{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.10";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.10-5253791805734912/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "713ae840845d74736e2d4a96f5d84e3353d614e73a875793ddf500997ccee09595448cebfd8e94fdd90ce2a0fa97707bd1cc29763dcfe01c945d80c92234378f";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.10-5253791805734912/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "f9f5c7ebc47a8b8de536acca8116b1f5a43dca614cde94008fe5a510517b23535fb281d85416930d76e76478858bf3dc66ea6d1b0c9b6eeadcfabe4d8ef2a807";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.10-5253791805734912/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "060f38f8a9c436178ea58fd8ca84b7e6d9ce5f49600c52a90046945e0c496e25f0b52accb6440a0dc7b484e8a916f08c1da44da4db738adf9c1081c379a170c2";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.10-5253791805734912/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "f192adfc6ca61bc8f0be93b8503c1a0a4e0314f127c9a13fb7e25228343dfbba09ae1a1be083851d9e79a703e535cc19242db44675e40cf7f9a4eaa8cb9b272f";
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
