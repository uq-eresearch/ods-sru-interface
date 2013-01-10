# More info at https://github.com/guard/guard#readme

guard :bundler do
  watch('Gemfile')
end

guard :rspec, :cli => "--color --format nested --fail-fast --drb" do
  watch(%r{^app\.rb$})
  watch(%r{^models/(.+)\.rb$})
  watch(%r{^config/(.+)\.rb$})
  watch(%r{^lib/(.+)\.rb$})
  watch(%r{^spec/(.+)\.rb$})
end
