PACKAGES=.packages
STATEGDART=lib/src/redux/state.g.dart

$(PACKAGES):
	flutter pub get

get: $(PACKAGES)

$(STATEGDART):
	cd ../cone_lib && make build
	flutter pub run build_runner build

build: $(PACKAGES) $(STATEGDART)

watch:
	flutter pub run build_runner watch

analyze:
	flutter analyze --watch

.PHONY: coverage build
coverage:
	flutter test --coverage
	genhtml -o coverage coverage/lcov.info
	reload-browser 'Google Chrome'

install:
	flutter build apk --flavor=play --target-platform android-arm,android-arm64,android-x64 --split-per-abi
