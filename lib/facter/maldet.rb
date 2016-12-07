Facter.add(:maldet_version) do
  setcode do
    if File.exists?('/usr/local/sbin/maldet') then
      %x{/usr/local/sbin/maldet}.split("\n").first.split.last.gsub('v', '')
    else
      false
    end
  end
end
