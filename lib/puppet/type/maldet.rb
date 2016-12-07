Puppet::Type.newtype(:maldet) do
  @doc = "Install Linux Malware Detect from source."

  ensurable do
    desc "Whether Maldet should be installed or not"

    newvalue(:present) do
      provider.create
    end

    aliasvalue(:installed, :present)

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)
  end

  newproperty(:version) do
    desc "Manage what version of Maldet is installed."
    newvalues(/^\d+(?:\.\d+)+$/)
  end

  newparam(:mirror_url) do
    desc "Base URL to download Maldet from"
    isnamevar
  end

  newparam(:extract_dir) do
    desc 'Directory to extract Maldet tarball to.
    Is removed after successful installation.'
    defaultto '/usr/local/.maldet_install'
  end

  newparam(:cleanup_old_install) do
    desc "Maldet's install.sh script will create a .bk directory
    containing the contents of any previous maldet installation's
    /usr/local/maldetect folder. This parameter determines
    whether these directories should be cleaned up upon a successful
    installation.
    This includes backup directories from previous upgrades."
    defaultto true
  end
end
