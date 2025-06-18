{ pkgs, lib, ... }:

let 
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Platform-specific system defaults and preferences
  
  system = lib.mkIf isDarwin {
    stateVersion = 5 ;

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

    # activationScripts = {
    #   postUserActivation = {
    #     text = ''
    #       # Following line should allow us to avoid a logout/login cycle
    #       /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    #     '';
    #   };
    # };
  };
}