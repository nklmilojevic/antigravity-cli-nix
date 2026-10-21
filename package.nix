{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.4.4";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.4-4783783166214144/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "7ce149d350344c1046c7b59b6659bcc5d659f351bf3a07c6c085887d93427ceb89d927752e4ccd0844b53ffb91d33d6a49f72835ceb276c7cffdd13cfb8023b8";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.4-4783783166214144/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "7bfc4f7e5e2dda4cd0c536c72cf9725c2918a038028ad11fa4f7f5e57db77e9ff7d6b9beca05cd85618b77dd3e77de64b63629d33e5779f29111390dc53c7aaf";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.4-4783783166214144/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "aec91417bde35e690d55af4e1ae4ff621fdd67d6b68a7a9ab50ebb506bf99d6b8a3b40395a385a42f8cf97109df22febb67dbde5ca498e75cbbca57a0dadc9ac";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.4-4783783166214144/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "cd12c4609b8b44aa94c2fe50eed8f3884f1ace506584630cbffcff428b0d557b883db0cc5fb9cfcc92528829c519857829070590c15ed6d673adf1916e609111";
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
