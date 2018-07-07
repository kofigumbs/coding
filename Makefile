client/build: $(wildcard client/**/*)
	cd client && npm install && `npm bin`/elm-app build
