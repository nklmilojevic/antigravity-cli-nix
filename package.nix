{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
}:

let
  version = "1.4.7";

  platformInfo = {
    "x86_64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.7-5900205422411776/linux-x64/cli_linux_x64.tar.gz";
      sha512 = "beda760587589f5827b0b516c3ec2c5bd5cd2e91eb0e2533807ba1e990a27dcd63aef0191e0b76fb60feab0d16eaa8210fb79842c34dd4809e257e1712edd152";
    };
    "aarch64-linux" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.7-5900205422411776/linux-arm/cli_linux_arm64.tar.gz";
      sha512 = "6a9fa0df6300633404571f66ec7924098cc70a9f23ac55c3659139bbcbdd2ea5301fe1ef728d4c064fac65104ea14a2b74421f320a82e5bcf218c482b58e3a16";
    };
    "x86_64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.7-5900205422411776/darwin-x64/cli_mac_x64.tar.gz";
      sha512 = "974f91063b2f5f01c89573304f01efb27319ac1228a1f06e1b8e83509b076fdcb77cd52b488b722554aa0a443a2b8addede5daffbd75a41f9d51ec5d108a12d1";
    };
    "aarch64-darwin" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.7-5900205422411776/darwin-arm/cli_mac_arm64.tar.gz";
      sha512 = "0192c9930fc8eccddc7aed96a6afde915f29ee380c81b6b6a835e68e4f1950514d98a596a87fbab9b1d87ba24921e29327af064bac8ced0bb873e78243826de9";
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
