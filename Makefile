.PHONY: client

# PLEASE HELP

client: client/build/elm.js client/build/index.html client/build/index.js client/build/vendor

client/build/elm.js: $(wildcard client/**/*.elm)
	cd client && npm install -g elm && elm make src/Main.elm --optimize --output build/elm.js

client/build/index.html: client/index.html
	cp client/index.html client/build
client/build/index.js: client/index.js
	cp client/index.js client/build
client/build/vendor: client/vendor
	cp -r client/vendor client/build
