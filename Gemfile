source 'https://rubygems.org'

gem 'librarian-chef'
gem 'foodcritic'

group :test do
  # TODO: point at the next version of the Gem > 3.0.2 when it is released
  # (Gem update requested in issue https://github.com/sethvargo/chefspec/issues/276 )
  gem 'chefspec', github: 'sethvargo/chefspec', ref: '535e139d132e2295f270cdbdbd9348cb6bdde055'
end

group :integration do
  gem 'test-kitchen'
  gem 'kitchen-vagrant', '~> 0.11'
end
