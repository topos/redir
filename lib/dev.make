all:
	sudo gem install rake bundler
	bundle install
	bundle exec rake cabal:clobber
	bundle exec rake dev:init
