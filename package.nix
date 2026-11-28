{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.19";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.19-4821414830800896/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "8160da6ceef2b7b62bb4a630b54b3fb4ee5283377509230736880c4ba4815e848a25cf346954a98134b647eb2f5d34e0364e77fbf74367ffd7dc29c525ddd82d";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.19-4821414830800896/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "eeecedfc2a63af281e245d73bb69f949a17c6d3ebcd3d023220056ddcc05e204a00d1d0ea77f68741b2fc15a1f66f740bc0e3bf800d734721c60938e61653010";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.19-4821414830800896/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "c989fa40e36858cecebaa1223ed93fbb9aaaba6fbaf3697d5d397cd451b4eea9ba7cebb3b5a6faf8ddec6dbce3730bdfda98b1c182062a522a7b9ea875d30894";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.19-4821414830800896/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "d798b1b2f91eb88a43c304ea5075db13cb069f01219c3b9f370037dc2c89d7e6c36ee96f160f9019947c1f5b55e744d8102e8303271d618f70d71cdb0911b213";
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
