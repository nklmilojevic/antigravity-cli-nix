{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.4.1";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.1-6385551759245312/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "e291adba20debd0f309297a58fa6355b278c6abc21cfcb2e3245783c4f3708bac14a7639600973e2d03cca5a63b842f6263e99ffe563f7460663004fee07b38c";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.1-6385551759245312/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "51ea9312f378962399faa673b1b2fe4044b801e662505c5c3e05d694fd8498a4c6b65f0f1c322629d2b5be824ef144c8e196b1253f1397a42b96849514f60b3d";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.1-6385551759245312/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "402b1c6811bfdaec49b2c9242c66d4b0d107c1d2cbdbfce4e24abd0a3ccf5f33ca57a49a3a2779e5915e55583d37508ba8faa4558baf99d2411a5bf97dbe3ea0";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.1-6385551759245312/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "a439584f45017bb6b4fb45b37dbeac960b7e99fb2e8c7d601cbcb593854c94ed47f82f1b193d12db0f8feb5f13ada3cbf275e5491be6e8b0a9f6e1d6799b55b1";
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
