{ pkgs }:
pkgs.writeShellApplication {
  name = "hello";
  runtimeInputs = with pkgs; [ cowsay lolcat ];
  text = ''
    echo "Hello World!" | cowsay | lolcat
  '';
}
