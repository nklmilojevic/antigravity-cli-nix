{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.3.6";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.6-5068262057312256/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "0f95f2ff2474e5926e6ac8d0661a16dab2dd31596518c68d687b3d0ccb6da518bf94fd86aa2ce57f28ff07a8529e9b268a12b217070bac8b44819dce884e9323";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.6-5068262057312256/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "dbe9585460ba8ea30959c6a2599d3bef1e7710331ef8c9e418863a300d19351906e16be63204f7d77434c773796b5ae222ae135ac033db5abf1542b076d02b0e";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.6-5068262057312256/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "117e328adfadb69a7543353fe87b5276c00ae189f2bb19868da6e667297c35c5f68b3537a35428b5b9f5ac3fee419296d9547990b24af81e6848e6a97b4a825c";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.6-5068262057312256/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "473a34b685d0a09d48790e8b86bc3e545dfab889fe0d8fc81cb7e1fdfc336fe78ce57022e3b438c754c93c9cffeb13fdbd177e50fdedc087d52732fa5475183f";
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
