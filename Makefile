client/build: content/**/* client/src/**/* client/public/**/*
	cd content && rake
	cd client && npm install && elm-app build
