{ ... } : {
  home.file.".config/opencode/opencode.jsonc" = {
    text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "permission": {
        "edit": "ask",
        "bash": {
          "git status": "allow",
          "git diff": "allow",
          "ls": "allow",
          "pwd": "allow",
          "*": "ask"
        }
      }
    }
    '';
  };
}
