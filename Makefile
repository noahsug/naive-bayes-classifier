make:
	coffee coffee/main.coffee

test:
	jasmine-node --coffee spec/
