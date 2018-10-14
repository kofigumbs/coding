client/build/elm.js: $(wildcard client/**/*.elm)
	cd client && npm install -g elm && elm make src/Main.elm --optimize --output build/elm.js
