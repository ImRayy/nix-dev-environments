{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  android-nixpkgs = callPackage <android-nixpkgs> { };

  android-sdk = android-nixpkgs.sdk (sdkPkgs:
    with sdkPkgs; [
      cmdline-tools-latest
      build-tools-34-0-0
      platform-tools
      platforms-android-34
      emulator
    ]);

in mkShell rec {
  ANDROID_SDK_ROOT = "${android-sdk}/libexec/android-sdk";
  buildInputs = [ android-sdk ];
}
