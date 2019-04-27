.PHONY: default dev-client dev-runner
default:
	cd client && npm install -g elm && elm make src/Main.elm --optimize --output build/elm.js

dev-client:
	cd client && \
		elm-live src/Main.elm --dir build -- --debug --output build/elm.js

dev-runner:
	cd runner && npm install
	cd runner && npm start
