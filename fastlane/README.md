fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build

```sh
[bundle exec] fastlane ios build
```

Build a signed App Store .ipa

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build + upload to TestFlight (separate beta channel; live version untouched)

### ios release

```sh
[bundle exec] fastlane ios release
```

Build + push metadata/screenshots + submit for App Store review

### ios pull

```sh
[bundle exec] fastlane ios pull
```

Download the live App Store listing (read-only)

### ios register_id

```sh
[bundle exec] fastlane ios register_id
```

Register the com.nefesapp.ios Bundle ID in the Developer Portal (so it appears in App Store Connect's New App dropdown)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
