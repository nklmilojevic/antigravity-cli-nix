{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.4.5";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.5-4952523841339392/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "fd30e8d256e28c4a6d0f5fddaa0f74b47c8c5a8e9fa2285cb03f85093e90eca0406f1c2fa57a0386bb820e21ed427e27c2315a01453dfda401c2223b2639ab30";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.5-4952523841339392/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "cf60004b48015a2737dcb56ce11227fef3a722f2e9329c13318e290951e350c395118bd8680c1042b2fdee9d2ead05fb84bb2596fa2d0012a44bc068655d34eb";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.5-4952523841339392/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "20775c9554d7d89eae1621779133ab8bc4305bd0996b63f671e0b2ede54da2866a21fdfc991997f5037da26040914f5b3969d8cf204b8fe594e4f601ac76e476";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.5-4952523841339392/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "c94eccc4f0121787e62e96b46426c17dfb47ecac324cc5ef3f9111312b8dca04bf5fc7f50bae17270c486956798aec0b38a5fea35990c9d5db415ec90af88c8f";
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
