{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.4.8";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.8-5447777392656384/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "b23683771438e72bffe0a2231168f65a16a0d73ed2c7a8460b311dc5fe0c3c9d9dfc6cbfb7d8755173340071aa4cc5c7a552fb5d1be3fdd31c2b7559d67e404a";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.8-5447777392656384/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "783ee9edd0f73e853af977e2848294ffb97b67b31ee19dccafb001f03f34b033371a2bb3371b61b78843c61bd4817ef1d2863a2d371b26513ea17d921c584bee";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.8-5447777392656384/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "94037c305ab4e15e4dd5d19fad130a4ce2493f01d55d5deed8a2742ef05a49a72e964025140d8786b4c1e4f40fa421e855f7ff6dc3dd6ea9e333ee39c3fbb9c9";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.8-5447777392656384/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "454b469183a4056ff12a15448c5cd3cb2e99bc11a69df3013be97d3e4ea3d1e0e4dd7ac913f9ddffcd0b9c10dc9ee1ddcc766ffdae1a691a8cf17231f6195df1";
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
