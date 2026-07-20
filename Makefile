version:
	fvm use 3.44.6

clean:
	fvm flutter clean

pubs:
	fvm flutter pub get

format:
	fvm dart format lib/ test/ --line-length=150

lint:
	fvm flutter analyze

quality: format lint

models:
	fvm dart run build_runner build --delete-conflicting-outputs

rebuild: version pubs models quality

splash:
	fvm dart run flutter_native_splash:create --path=./flutter_native_splash.yaml