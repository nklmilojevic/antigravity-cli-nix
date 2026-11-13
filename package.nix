{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.8";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.8-4602374149505024/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "f08faaee588327dba8722bdc60f26a14f6915a8f2d756ed7959cde0a706d4e62fd9f831ab1a077dace5f947caaa6e851457df5023180bb8d3f54386804a3787f";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.8-4602374149505024/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "7b040bfb8fb96f7550a8a66cd0ac28cb3e6e40e427f1e9810bfe1bf23c417cb9b363e36b2fc8ed645fe1ee518b0106f50f03de7084e95ede4591a893527360d1";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.8-4602374149505024/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "cf9dd8f22ca034305750044c19bec3d91d2106af6dbd6f9bd071d68de821906216265ea011e95870e7178e1ca059c8005019869269a416b7d6240cf6073bfcd1";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.8-4602374149505024/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "046d3cffcdbba11f45a620ee6727afa928e5dfe409aa1c8be14e5645eb407c3aa737e9f2dac7d7e6fbde4396e7737d9d376eef7530ab142e85be473ab7ce454e";
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
