Facter.add("rails_environment") do
  setcode do
    ENV['RAILS_ENV'] || 'development'
  end
end
