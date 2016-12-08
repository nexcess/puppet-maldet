require 'fileutils'

Puppet::Type.type(:maldet).provide(:source) do
  desc "Install Linux Malware Detect from source."

  commands :curl  => 'curl'
  commands :tar   => 'tar'

  def version
    if File.exists?('/usr/local/sbin/maldet')
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

  def download_and_extract
    should_version = @resource.should(:version)
    source = "#{@resource[:mirror_url]}/maldetect-#{should_version}.tar.gz"
    outfile = "#{@resource[:extract_dir]}/maldetect.tar.gz"
    FileUtils.mkdir_p(@resource[:extract_dir], :mode => 0700)
    curl( ['-fsSL', '--max-redirs', '5', source, '-o', outfile] )
    tar( ['xzvf', outfile,'-C', @resource[:extract_dir]] )
    return should_version
  end

  def create
    should_version = download_and_extract()
    Dir.chdir("#{@resource[:extract_dir]}/maldetect-#{should_version}") do
      %x{ ./install.sh }
    end
    FileUtils.remove_dir(@resource[:extract_dir])
    if @resource[:cleanup_old_install] and File.exists?('/usr/local/maldetect.last') then
      realpath = File.realpath('/usr/local/maldetect.last')
      FileUtils.remove_dir(realpath)
      File.unlink('/usr/local/maldetect.last')
    end
  end

  def destroy
    Dir.chdir('/usr/local/maldetect/') do
      if File.exists('./uninstall.sh')
        %x{ echo y | ./uninstall.sh }
      else
        puts 'Unable to locate uninstall script (this script is not provided in Maldet versions < 1.5).'
      end
    end
  end

  def exists?
    File.exists?('/usr/local/sbin/maldet')
  end
end
