{ inputs, pkgs, lib, options, ... }:

let
  # Nix-Darwin has the `defaults` attribute, and it requires an integer state
  # this feels like a real hack, but I can't seem to figure out a cleaner way
  # that doesn't cause an infinite recursion

  supportsDarwinDefaults = builtins.hasAttr "defaults" options.system;
  darwinDefaults = lib.optionalAttrs supportsDarwinDefaults {
    defaults = { 
      NSGlobalDomain = {
        # Increase window resize speed for Cocoa applications
        NSWindowResizeTime = 0.001;

        # Expand save panel by default
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Expand print panel by default
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;

        # Save to disk (not to iCloud) by default
        NSDocumentSaveNewDocumentsToCloud = false;

        # Some other configs
        KeyRepeat = 1;
        InitialKeyRepeat = 10;

        "com.apple.springing.enabled" = true;
      };

      ActivityMonitor  = {
        # Show the main window when launching Activity Monitor
        OpenMainWindow = true;

        # start with All Processes, Hierarchally
        ShowCategory = 101;

        # Visualize CPU usage in the Activity Monitor Dock icon
        IconType = 5;

        # Sort Activity Monitor results by CPU usage
        SortColumn = "CPUUsage";
        SortDirection = 0;
      };

      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = true;
      };

      dock = {
        # Enable spring loading for all Dock items
        enable-spring-load-actions-on-all-items = true;

        # Don't show Dashboard as a Space
        dashboard-in-overlay = true;
       
        # Don't automatically rearrange Spaces based on most recent use
        mru-spaces = false;
        
        # Don't show recent applications in Dock
        show-recents = false;
      };

      finder = {
        # set finder to display full path in title bar
        _FXShowPosixPathInTitle = true;
        # Use column view in all Finder windows by default
        # Four-letter codes for the other view modes: `icnv`, `Nslv`, `glyv`
        FXPreferredViewStyle = "clmv";
        # Disable the warning when changing a file extension
        FXEnableExtensionChangeWarning = false;
      };

      screensaver = {
        askForPassword = true ;
        askForPasswordDelay = 0 ;
      };

      spaces = {
        spans-displays = false ;
      };

      CustomSystemPreferences = {
        "NSGlobalDomain" = {
          "WebKitDeveloperExtras" = true ;
        };
       "com.apple.SoftwareUpdate" = {
          AutomaticCheckEnabled = true;
          # Check for software updates daily, not just once per week
          ScheduleFrequency = 1;
          # Download newly available updates in background
          AutomaticDownload = 1;
          # Install System data files & security updates
          CriticalUpdateInstall = 1;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.print.PrintingPrefs" = {
          # Automatically quit printer app once the print jobs complete
          "Quit When Finished" = true;
        };
        "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
        # Prevent Photos from opening automatically when devices are plugged in
        "com.apple.ImageCapture".disableHotPlug = true;
        # Turn on app auto-update
        "com.apple.commerce" = {
          AutoUpdate = true;
          AutoUpdateRestartRequired = true;
        };
        "com.apple.finder" = {
          "QLEnableTextSelection" = true;
        };
        "com.apple.desktopservices" = {
          "DSDontWriteNetworkStores" = true;
          "DSDontWriteUSBStories" = true ;
        };
        "com.apple.Safari" = {
          # Disable AutoFill
          "AutoFillFromAddressBook" = false;
          "AutoFillPasswords" = false;
          "AutoFillCreditCardData" = false;
          "AutoFillMiscellaneousForms" = false;
          # Block pop-up windows 
          "WebKitJavaScriptCanOpenWindowsAutomatically" = false;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
          # Enable "Do Not Track"
          "SendDoNotTrackHTTPHeader" = true;
          # Update extensions automatically
          "InstallExtensionUpdatesAutomatically" = true;
        };
      };
    };
  };

  supportsBoot = builtins.hasAttr "boot" options;
  bootOptions = lib.optionalAttrs supportsBoot {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
        };
        efi = {
          canTouchEfiVariables = true;
        };
      };
    };
  };

  supportsFirewall = builtins.hasAttr "firewall" options.networking;
  firewallConfig = lib.optionalAttrs supportsFirewall {
    networking = {
      firewall = {
        enable = true;
      };
    };
  };

  supportsIPv6 = builtins.hasAttr "enableIPv6" options.networking;
  ipv6Config = lib.optionalAttrs supportsIPv6 {
    networking = {
      enableIPv6 = false;
    };
  };

  supportsResolved = builtins.hasAttr "resolved" options.services;
  resolvedConfig = lib.optionalAttrs supportsResolved {
    services.resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      dnsovertls = "opportunistic";
    };
  };

  supportsNetworkd = builtins.hasAttr "useNetworkd" options.networking;
  networkdConfig = lib.optionalAttrs supportsNetworkd {
    networking = {
      useNetworkd = true;
      useDHCP = false;
    };
    systemd.network.enable = true;
  };

  supportsAutoUpgrade = builtins.hasAttr "autoUpgrade" options;
  autoUpgradeConfig = lib.optionalAttrs supportsAutoUpgrade {
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "--no-write-lock-file"
        "-L" # print build logs
      ];
      dates = "02:00";
      randomizedDelaySec = "45min";
    };
  };
  systemOptions = {
    # Platform-specific system defaults and preferences
    system = (lib.mkMerge [
      darwinDefaults
      autoUpgradeConfig
    ]);
  };
in lib.mkMerge [
  bootOptions
  firewallConfig
  ipv6Config
  resolvedConfig
  networkdConfig
  systemOptions
]
  
