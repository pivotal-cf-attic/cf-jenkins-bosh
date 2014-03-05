source 'https://rubygems.org'

gem 'librarian-chef'

# this fork relaxes the YAJL dependency that otherwise prevents us from using a recent version of foodcritic;
# go back to the main fork when it's been merged.
gem 'foodcritic', github: 'elgalu/foodcritic', ref: '8f7de466719c60856268ffa0f3891268535d5827'

group :test do
  gem 'chefspec', '~> 3.1'
  gem 'jenkins_api_client'

  # Normally builder is installed via chef_gem, but we execute some unit tests that touch that code path
  gem 'builder'
end
