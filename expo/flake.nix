{
  description = "Expo 50.0.x";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        cmakeVersion = "3.22.1";
        buildToolsVersion = "34.0.0";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [ buildToolsVersion "30.0.3" "33.0.1" ];
          platformVersions = [ "34" "28" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
          includeNDK = true;
          ndkVersions = [ "25.1.8937393" ];
          cmakeVersions = [ cmakeVersion ];
        };
        androidSdk = androidComposition.androidsdk;
      in {
        devShell = with pkgs;
          mkShell rec {
            buildInputs = [
              androidSdk
              jdk17
            ];

            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            ANDROID_NDK_ROOT = "${ANDROID_SDK_ROOT}/ndk-bundle";
            ANDROID_HOME = "${ANDROID_SDK_ROOT}";
            GRADLE_OPTS =
              "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildToolsVersion}/aapt2";
            shellHook = ''
              export PATH="$(echo "$ANDROID_SDK_ROOT/cmake/${cmakeVersion}".*/bin):$PATH"
            '';
          };
      });
}
