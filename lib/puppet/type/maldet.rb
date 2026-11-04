Puppet::Type.newtype(:maldet) do
  @doc = "Install Linux Malware Detect from a release tarball."

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

  newparam(:source) do
    desc "Optional full URL of the tarball to install. When unset, the
    tarball is downloaded from <mirror_url>/maldetect-<version>.tar.gz,
    which only serves 1.x; maldet::install sets this to the GitHub release
    for 2.x."
  end

  newparam(:checksum) do
    desc "Optional SHA-256 of the tarball at source. When set, the download
    is checked before it is unpacked and the install fails on a mismatch."
    validate do |value|
      unless value.nil? || value =~ /\A[0-9a-f]{64}\z/
        raise ArgumentError, "checksum must be a lowercase hex SHA-256, got #{value}"
      end
    end
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
