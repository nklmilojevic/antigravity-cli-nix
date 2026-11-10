{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.5";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.5-6740358537805824/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "746a2bd73f83b65d9b44f2fc55d0f0f511ff7f89702846213eeabd76d06bc9c98576b424c2babc7b947f15e518447b946ba02dca260b778363c55c07a7f7a277";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.5-6740358537805824/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "eb3e025c125c1c60a1493a0c1d9cdf15e8372277d6d3b015e8d29e1bd095344eece5cbc2447f238148bd259d5f2daa0f75641adc0ac02b5fad57edc4ed842d59";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.5-6740358537805824/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "54bbe42eee81d75d746ed560995bfa7cc9d14c601b4b1a3756f5e9c0f2b79ffb9ca64894368e326e211445de2075cf54ecaecb0c26ad79d231ed819feba3618d";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.5-6740358537805824/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "ca6424867a4527698e54b805c2456605b905a49ffc9b664ae2ee0fd4510fcd7b82d9721b2622a1d46048156a44431dc894359177fae44207363c8c878687b647";
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
