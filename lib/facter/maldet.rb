Facter.add(:maldet_version) do
  setcode do
    if File.exists?('/usr/local/maldetect/maldet') then
      %x{/usr/local/maldetect/maldet}.split("\n").first.split.last.gsub('v', '')
    else
      false
    end
  end
end
