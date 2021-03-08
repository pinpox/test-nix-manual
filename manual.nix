let
  pkgs = import <nixpkgs> {};
  example = {
    param1 = "foo";
    param2 = "bar";
  };
in  {
  jsonout = pkgs.writeTextFile {
    name = "testfile";
    text = ''
    echo "${example.param1} ${example.param2}"
  '';
  };
}

