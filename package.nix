{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.15";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.15-5514532022517760/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "af3f0be58b8475940d79f9abea19e762ecc3d265ea9f56cff8dd805e27ba299b44a305a79504a7ffe6ebdfa29a294c56edc4caed1875990bfaf2fef1508ec8b0";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.15-5514532022517760/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "d64ad759781b50dfacfa7d9826c0ad469959d01bdf5a170acd4c83472eba31c677baf0052ac8ab48eef40f0d3f0e26057e752aabd24331c79f4c881d4b872125";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.15-5514532022517760/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "2276e0f189a917e7eaa4b00ece59fe6a1062914472e13247f402b56fe26c9afacd0af494476e31a5610fb0b273400ca4013f273d56d69c6fdd7e2d0ec933f596";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.15-5514532022517760/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "b03a841eb3a29be918a66960b775f68ed4f3bcc02f33962131bbbc26c46ea983ceac6c832ad46efd11d73d9a2cb97df4ab24d4bc92ee47d3d5ece7b8d8b61235";
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
