{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.11";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.11-6132547114106880/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "dad3c015e8964fcdc1639b13b7152f4cb84cb1bde385707e2bcdf095d6f1831f4f6521199aec499cc052f9e99906b7fdbc52c273df064d5cb7c84b068ba3ce50";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.11-6132547114106880/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "5f703c88e01851061c87c07b1a4ca54c1f5a6826ffada9fb005974a099e9a552ddb1f9ba2fe1194e2829803482c86084babf8cf91530a528bc7f659613600585";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.11-6132547114106880/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "ff1f625c2efcff03d2131e3e9dc67bb5d1974b67810706f80ad34317c83769486388226352f1a34ede54fad43f5941220ea9beddefc8b27419023c6e9aa4682c";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.11-6132547114106880/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "1b2c8e1f832e1be9b257c24e4ac75c9029771fef5af9b529ea295fff1aa5b9d3e1e5447200a76ac8a775889aa8399210716f188f84242b3c34a2e9a8a3c2cc7d";
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
