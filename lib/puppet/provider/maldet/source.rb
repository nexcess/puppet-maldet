require 'digest'
require 'fileutils'

Puppet::Type.type(:maldet).provide(:source) do
  desc "Install Linux Malware Detect from a release tarball."

  commands :curl  => 'curl'
  commands :tar   => 'tar'

  def version
    if File.exist?('/usr/local/sbin/maldet')
      header = %x{ /usr/local/sbin/maldet }
      header.split("\n").first.split(" v").last
    else
      :absent
    end
  end

  # Setter method is passed @resource.should[:version] by puppet
  # even though we don't use it here.
  def version=(version)
    create()
  end

  # Unpacks the tarball and returns the directory holding install.sh.
  # 1.x tarballs unpack to maldetect-<version>/, 2.x to maldet-<version>/.
  def download_and_extract
    source = @resource[:source] ||
      "#{@resource[:mirror_url]}/maldetect-#{@resource.should(:version)}.tar.gz"
    extract_dir = @resource[:extract_dir]
    outfile = "#{extract_dir}/maldetect.tar.gz"
    FileUtils.rm_rf(extract_dir)
    FileUtils.mkdir_p(extract_dir, :mode => 0700)
    curl( ['-fsSL', '--max-redirs', '5', source, '-o', outfile] )

    if @resource[:checksum]
      actual = Digest::SHA256.file(outfile).hexdigest
      unless actual == @resource[:checksum]
        FileUtils.rm_rf(extract_dir)
        raise Puppet::Error, "checksum mismatch for #{source}: expected #{@resource[:checksum]}, got #{actual}"
      end
    end

    tar( ['xzf', outfile, '-C', extract_dir] )
    installers = Dir.glob("#{extract_dir}/*/install.sh")
    unless installers.length == 1
      raise Puppet::Error, "expected one install.sh in #{source}, found #{installers.length}"
    end
    File.dirname(installers.first)
  end

  def create
    install_dir = download_and_extract()
    output = Dir.chdir(install_dir) { %x{ ./install.sh 2>&1 } }
    unless $?.success?
      raise Puppet::Error, "maldet install.sh exited #{$?.exitstatus}:\n#{output}"
    end
    FileUtils.remove_dir(@resource[:extract_dir])
    if @resource[:cleanup_old_install] and File.exist?('/usr/local/maldetect.last') then
      realpath = File.realpath('/usr/local/maldetect.last')
      FileUtils.remove_dir(realpath)
      File.unlink('/usr/local/maldetect.last')
    end
  end

  def destroy
    Dir.chdir('/usr/local/maldetect/') do
      if File.exist?('./uninstall.sh')
        %x{ echo y | ./uninstall.sh }
      else
        puts 'Unable to locate uninstall script (this script is not provided in Maldet versions < 1.5).'
      end
    end
  end

  def exists?
    File.exist?('/usr/local/sbin/maldet')
  end
end
