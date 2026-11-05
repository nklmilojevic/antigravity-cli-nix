{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.1";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.1-4523430503120896/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "f70406654ebd966f211424338259e2d38d099c48734e901dc06975063e5a0137d55b6eb9366b75983c6908bbc20ae92a2617656bb191d8ed6fe429d654bca4f5";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.1-4523430503120896/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "fdf8a463e5bf4ecd8a01b68a53e006e7ae0256e7ae351a39e39c66e04e275c6d08b4b93f423cc572d234871f7bf852c4523e017156a4ef9ea7dea1aaffb0a2c6";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.1-4523430503120896/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "736a0f1210b42edc6ec292e1f8438696f616bf6906ad5e878d415b18aa53accc59a678205c332e5af564fab8d32ca5ac5b41c9baad8ced0a7bc224a0ccfcc3b5";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.1-4523430503120896/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "078399b392c3bfce70bc5d9fb1a447a4b0a2a26bd40c36148f4944028b8f21e358890d5b9bedcde69296677b1da2c026b4e283ae918823429c13b91ddcb913ce";
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
