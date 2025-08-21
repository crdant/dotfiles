{ nixpkgs
, nixos-generators
, system ? "x86_64-linux"
}:

{ modules
, specialArgs ? {}
, name
, domain ? ""  # Optional domain for FQDN
, ram ? 2048  # MB
, cpus ? 2
}:

let
  pkgs = nixpkgs.legacyPackages.${system};
  
  # Construct display name with optional domain
  displayName = if domain != "" then "${name}.${domain}" else name;
  
  # ovftool with EULA accepted
  ovftoolWithEula = pkgs.ovftool.override {
    acceptBroadcomEula = true;
  };
  
  # Generate the base VMware image using nixos-generators
  vmwareImage = nixos-generators.nixosGenerate {
    inherit system modules specialArgs;
    format = "vmware";
  };
  
  # VMX template with placeholders
  vmxTemplate = ''
    .encoding = "UTF-8"
    config.version = "8"
    virtualHW.version = "20"
    displayName = "@NAME@"
    guestOS = "other5xLinux-64"
    memsize = "@RAM@"
    numvcpus = "@CPUS@"
    firmware = "efi"
    powerType.powerOff = "soft"
    powerType.powerOn = "soft"
    powerType.reset = "soft"
    powerType.suspend = "soft"
    tools.syncTime = "TRUE"
    tools.upgrade.policy = "manual"
    
    # SCSI controller
    scsi0.present = "TRUE"
    scsi0.virtualDev = "pvscsi"
    
    # Disk
    scsi0:0.present = "TRUE"
    scsi0:0.fileName = "@VMDK_NAME@"
    scsi0:0.deviceType = "disk"
    
    # Network
    ethernet0.present = "TRUE"
    ethernet0.virtualDev = "e1000"

    # make it easier to work with the console
    isolation.tools.copy.disable = "FALSE"
    isolation.tools.paste.disable = "FALSE"
  '';

in
pkgs.stdenv.mkDerivation {
  pname = "${name}-ova";
  version = "1.0.0";
  
  buildInputs = with pkgs; [
    coreutils
    gnused
    ovftoolWithEula
  ];
  
  # Use the generated VMware image as source
  src = vmwareImage;
  
  buildPhase = ''
    # Find the VMDK file name
    VMDK_FILE=$(find . -name "*.vmdk" | head -n1)
    VMDK_NAME=$(basename "$VMDK_FILE")
    
    # Create the customized VMX file
    echo "${vmxTemplate}" > ${name}.vmx
    
    # Replace placeholders
    sed -i "s/@NAME@/${displayName}/g" ${name}.vmx
    sed -i "s/@RAM@/${toString ram}/g" ${name}.vmx
    sed -i "s/@CPUS@/${toString cpus}/g" ${name}.vmx
    sed -i "s/@VMDK_NAME@/$VMDK_NAME/g" ${name}.vmx
  '';
  
  installPhase = ''
    mkdir -p $out
    
    # Copy VMDK file
    cp *.vmdk $out/
    
    # Copy customized VMX
    cp ${name}.vmx $out/
    
    # Create OVA using ovftool
    cd $out
    ovftool ${name}.vmx ${name}.ova
    
    # Clean up intermediate files, keeping only the OVA
    rm -f *.vmdk *.vmx
  '';
  
  meta = with pkgs.lib; {
    description = "VMware OVA image for ${name}";
    platforms = platforms.linux;
  };
}
