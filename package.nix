{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.2";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.2-4951595792859136/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "aa876c0813572efaf85ed47983cc937414705d40490cbdb54f6e255656a4f8744ae38e457823e924fa8270b348124e0521d3cda3fec6824bb2d14b98a7a05baa";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.2-4951595792859136/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "9a141da7b218c640a962188b388905f065cc307425bbeff6e74c07f95266f93526f6d0dee9bad876b79431403f5b30ef4e6514f5f44fbf06dca2a077f54f6175";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.2-4951595792859136/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "e1820cab27aa3462383c15d9d69995f3b3fad9ed7cb5208bb0a5d7b8696ef2690baef6df8604bb769d584a1094cc0ed64afe0173ee45523ec36413695b7966ff";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.2-4951595792859136/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "89c9080f26d99bb94c2aed1bf67e0612dc7803a77fc64963e6c95377de6dd0d6269931f413a21ab2ba885c3f4ee8343727520c5ff94740345ac06b4b73085d67";
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
