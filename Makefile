client/build: $(wildcard content/**/* client/src/**/* client/public/**/*)
	cd content && rake
	cd client && npm install && `npm bin`/elm-app build
