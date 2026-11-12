{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.7";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.7-6190022064472064/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "60bca280414ed11723f58b3b671962ae394cc2d0c25e3f58e32e1c6847c978cbc77ec6f40e7f3992001c399d80aeb8b64c9ec892abddd591b12413c5ee6d9fce";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.7-6190022064472064/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "bebd69ad1713414b82e370aec6be0e678a413332bf3c835d9ba22e4befff040b6c74e1bf974fd83ebc4c733ed6e37d2bdc1caae58027c2b326dd04d630bfebb1";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.7-6190022064472064/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "554190daa4a9faac612d902121f46bedf2e6200c3a07461f5eee8e7c6772b5192956751ffaf67835057fc666d139875522a2d0f92b45745176e3b95c167d5a48";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.7-6190022064472064/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "c9746409083a9b15c217757aa2ef399ee7d4398602a30038583ea45196fc27d1662745341e45a116c07be19c08587de1e5929e365d2a46aea385fa33f0c2396a";
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
