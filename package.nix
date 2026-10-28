{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.4.9";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.9-4962164969177088/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "96a259b7475ae70a5b002ea8a83b804bba9b6ad2171af0cd0839b3959d9e6046ba36e181bc2d5597522aeceaacc06023564c46232fdb958f26f8c72267d9f0fd";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.9-4962164969177088/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "a703d10ea96d20d35c2ab6a056ce07ac196fac215cdf1ac3a8750a519fa42c3ac1bc4ac8776c98c94e0a816b6b37beaf0e5d98d30eed3e60a90d18ac9a060130";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.9-4962164969177088/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "cd4df27844a6585da9af155fef02b344deb18213910cff27ddb7ea54411358318a50901a3d348997f67744c31e64fdda7ead3ab48e2c66fc10510b4d8ae9843f";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.9-4962164969177088/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "d7d83634b0c236659ee530f448e9aa1c5dc00a010631edd72bf11a920006892b319be7e51c8defae226f204660544e4d915bb5e733f1ceb50c065f4cbe45d3d0";
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
