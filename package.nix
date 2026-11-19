{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.5.12";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.12-5281398513336320/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "26de25fccb3fbf0b093e090ce14a14ac1df1ec3e90ef4ea6106887d3a81b0cc9edb0dadea7b9101d07f9606eba159062a6fb7b78e91b73f7520684a24db73428";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.12-5281398513336320/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "1030d89ce9e5cb39509e272cb89b71fde0e0d5d6527b7392525d5ef2683da54fb49230449107486d91c02ded39a678faaa649b2041304a6cf82a3a332d5819d9";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.12-5281398513336320/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "b392e94e593a3c93e90b14e277c80e9712c1442dba0f68a7b48918bbeb990250a544eedf791426d3afd95162128b4de320f549f2639640d20e1d25b567784c7f";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.12-5281398513336320/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "f0d951b41bddb62cbee0199a60cc9a9aba16cecb95c5cf7d5c71349c745c578f2d2bbce1194b058e867e85456030ac1b1ec72772ee17b31de1d606f34cce3154";
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
