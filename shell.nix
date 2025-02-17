{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = [
    pkgs.openjdk17-bootstrap
    pkgs.grafana-alloy
  ];
}
