{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.4.11";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.11-5180209989812224/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "2935601efa745ed6e314d32b415c71f44d9d455f0e6a2583372584be5a9074c28154cf81d5eec65b4416579453a3b3b05d3abe4d4f176754d5ef93a84af6cf28";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.11-5180209989812224/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "a5f80d76ea95b3973f4daab6f7ffd88f1cfd9c7f7f70dda951ba74b2e7309a53f64d2224a0db39c949c4b74f7c56a16a3ab04fa4b8fed6a45d7486b2692a4e25";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.11-5180209989812224/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "543975f3c141dc88da947d06c036c43ae163ad16e59531812c346299105f0c555cd0ac01a868846dbab37104217fdb50d812d0241a8dbe45edb28b70544da246";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.11-5180209989812224/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "ff94cda02d46864950243d3c7b497fc13d8d5036f47e02099d3112228a841f1e8298cf37fbfd3f70b25c264b79400600932b2599f9aba649bc6c7cf3c867fd1e";
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
