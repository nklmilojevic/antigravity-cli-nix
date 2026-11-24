{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.16";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.16-5250855658717184/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "3dee9f26e298156db673f6ce2a0f5dfed5b30006e04ceb9809c68070e7b717587b33a3da0f8bc2eda45af81a50bc8b14c82b28ae5832bcfe3e7fd49397117b31";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.16-5250855658717184/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "23c193151499a4986fd5fa0d8132665cc8ffbad6cc0b3ff4fd53a2cb68abb76b149a992b836d53063443cd89add335f14d8134fb02abdcecbf6e1eaef6c53d33";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.16-5250855658717184/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "b3eae073ee633032e9d473cdc7725c30bdfe2e09436bc36cfb3422e7e5fa3733de9591a7f78d02362294e7bf87e345d70e5d839689e526129a6f3fc041857a05";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.16-5250855658717184/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "33f5617dc74fea606d47b2483c6d271c850c9f3c9c55b724c664c3c0d4b82100d819fbcf55714f851765f6628d4296883ac8939b4fdeb55d5e6b9ce923135d18";
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
