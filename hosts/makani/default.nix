{pkgs, ...}: {
  environment = {
    loginShell = pkgs.zsh;
  };

  # Enable configuration for nixbld group and users
  nix.configureBuildUsers = true;

  # Rnable the nix-daemon service
  services.nix-daemon.enable = true;

  system.defaults = {
    NSGlobalDomain = {
      # Automatically switch between light and dark mode
      AppleInterfaceStyleSwitchesAutomatically = true;

      # Disable popup for character variations - allows key repeat
      ApplePressAndHoldEnabled = false;

      # Show all extensions in Finder
      AppleShowAllExtensions = true;

      # How long to hold a key down before it starts repeating
      InitialKeyRepeat = 20;

      # How fast a held character repeats
      KeyRepeat = 2;

      # Disable automatic capitalisation
      NSAutomaticCapitalizationEnabled = false;

      # Disable automatic em/en-dash substitution
      NSAutomaticDashSubstitutionEnabled = false;

      # Disable smart full-stop substitution
      NSAutomaticPeriodSubstitutionEnabled = false;

      # Disable smart quote substitution
      NSAutomaticQuoteSubstitutionEnabled = false;

      # Stop trying to save new documents to iCloud
      NSDocumentSaveNewDocumentsToCloud = false;

      # Expand the save dialogue panels by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };

    dock = {
      autohide = true;

      # Don't rearrange misson control spaces based on most recently used
      mru-spaces = false;

      orientation = "left";
    };

    finder = {
      AppleShowAllExtensions = true;

      # Default to searching the current folder
      FXDefaultSearchScope = "SCcf";

      FXEnableExtensionChangeWarning = false;
    };

    # Don't allow logins as guests
    loginwindow.GuestEnabled = false;

    # Enable tap to click
    trackpad.Clicking = true;
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}
