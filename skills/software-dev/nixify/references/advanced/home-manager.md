# Home-Manager Module

For projects that benefit from declarative user configuration, add a home-manager module.

**Create the module structure:**

```bash
mkdir -p nix/modules/hm
```

**Create `nix/modules/hm-module.nix`:**

```nix
{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.<binary-name>;
in
{
  options.programs.<binary-name> = {
    enable = mkEnableOption "<project name>";

    package = mkOption {
      type = types.package;
      default = pkgs.<binary-name>;
      description = "Package to use for <project name>.";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Configuration for <project name>.";
      example = {
        theme.name = "catppuccin";
        terminal.default_shell = "${pkgs.zsh}/bin/zsh";
      };
    };

    shellIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell integration.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."<binary-name>/config.toml".source =
      pkgs.formats.toml {}.generate "config.toml" cfg.settings;

    programs.zsh.initExtra = mkIf cfg.shellIntegration ''
      # Add shell integration for zsh
    '';

    programs.bash.initExtra = mkIf cfg.shellIntegration ''
      # Add shell integration for bash
    '';

    programs.fish.interactiveShellInit = mkIf cfg.shellIntegration ''
      # Add shell integration for fish
    '';
  };
}
```

**Skip if:** The project is a library, not a CLI tool, or configuration is simple enough for manual management.
