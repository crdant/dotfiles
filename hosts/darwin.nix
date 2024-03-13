{ pkgs, ... }:
{

  documentation.enable = false ;

  imports = [
    ./common.nix
  ];

  security = {
    pam.enableSudoTouchIdAuth = true;

    pki = {
      installCACerts = true ;
      certificateFiles = [
        ../pki/shortrib-labs-e1.crt
        ../pki/shortrib-labs-r2.crt
      ];
    };
  };

  environment = {
    systemPackages = with pkgs; [
      duti
      iterm2
      karabiner-elements
      m-cli
      mas
      raycast
      slack
      zoom-us
    ];
  }; 
 
  homebrew = {
    enable = true;
    # updates homebrew packages on activation,
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    
    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/core"
      "homebrew/services"
      "OJFord/formulae"
      "vmware-tanzu/carvel"
    ];

    brews = [
      "adr-tools"
      # "tccutil"
      "trash"
      "opa"
      "osxutils"
      "pinentry-mac"
      "watch"
      "pam_yubico"
      # "ojford/formulae/loginitems"
      "replicatedhq/replicated/cli"
      # "vmware-tanzu/carvel/imgpkg"
    ];

    casks = [
      "1password"
      "bartender"
      "carbon-copy-cloner"
      "dash"
      "espanso"
      "firefox"
      "font-bitstream-vera"
      "font-cabin"
      "font-fira-code"
      "font-inconsolata"
      "font-noto-sans"
      "font-open-sans"
      "google-chrome"
      "google-drive"
      "grandperspective"
      "hammerspoon"
      "hex-fiend"
      "jetbrains-toolbox"
      "noun-project"
      "obs"
      "proxyman"
      "quicklook-json"
      "rancher"
      "raspberry-pi-imager"
      "raycast"
      "superhuman"
      "tailscale"
      "yubico-yubikey-manager"
    ];

    masApps = {
     # "1Blocker" = 1365531024;
     "1Password for Safari" = 1569813296;
     "Amphetamine" = 937984704;
     "Bear" = 1091189122;
     "Craft" = 1487937127;
     "Keynote" = 409183694;
     "Matter" = 1548677272;
     "Memory Clean 3" = 1302310792;
     "Microsoft Excel" = 462058435;
     "Microsoft PowerPoint" = 462062816;
     "Microsoft Remote Desktop" = 1295203466;
     "Numbers" = 409203825;
     "Pages" = 409201541;
     "Paprika Recipe Manager 3" = 1303222628;
     "PopClip" = 445189367;
     "Todoist" = 585829637;
     "Twitter" = 1482454543;
     "Transmit" = 403388562;
    };

  };

  system = {
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

        # Don’t show Dashboard as a Space
        dashboard-in-overlay = true;
       
        # Don’t automatically rearrange Spaces based on most recent use
        mru-spaces = false;
        
        # Don’t show recent applications in Dock
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
          # Enable “Do Not Track”
          "SendDoNotTrackHTTPHeader" = true;
          # Update extensions automatically
          "InstallExtensionUpdatesAutomatically" = true;
        };
      };
   };

    activationScripts = {
      postUserActivation = {
        text = ''
          # Following line should allow us to avoid a logout/login cycle
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
        '';
      };
    };
  };

}
