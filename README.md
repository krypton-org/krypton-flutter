<p align="center">
  <img src="https://github.com/krypton-org/krypton-flutter/raw/master/img/logo.png" width="150px"/>
</p>
<p align="center">
  <i> Krypton client for Flutter and Dart.</i><br/><br/>
  <a href="https://travis-ci.com/krypton-org/krypton-flutter">
    <img src="https://travis-ci.com/krypton-org/krypton-flutter.svg?branch=master">
  </a>
</p>

This is the Dart library to connect to [Krypton Authentification server](https://github.com/krypton-org/krypton-auth).
It is based on the [Krypton client specification](https://github.com/krypton-org/krypton-drafts/tree/master/client).

## Getting started

### Installation

First, depend on this package:

```yaml
dependencies:
  krypton: ^0.1.0
```

And then import it inside your dart code:

```dart
import 'package:krypton/krypton.dart';
```

### Usage

#### Basic example

```dart
  KryptonClient kryptonClient = KryptonClient("https://localhost:5000"); // assuming Krypton Auth's MongoDB instance is running on this URL
  try {
    await kryptonClient.register("nicolas@example.com", "1234unsecurepassword");
    await kryptonClient.login("nicolas@example.com", "1234unsecurepassword");
  } catch(err) {
    print(err);
```

#### Advanced example

TODO

## Public API

This package follows [Semantic Versioning](https://semver.org/).

TODO: link to the public API documentation. Important to be exhaustive here.

## Contributing

### Contributing policy

TODO

### Development setup

* Install dart
* Clone the repository
* cd to the root directory of the repository
* Run `pub get`
* Start coding!

### Development workflow

* The development follows [TDD](https://en.wikipedia.org/wiki/Test-driven_development)'s principles. Write tests first, then make it pass.
* We follow the ["GitLab Workflow logic"](https://docs.gitlab.com/ee/development/contributing/merge_request_workflow.html), except on GitHub ;). In short:
  * Nothing is pushed directly to master.
  * Every new feature or bug fix start with opening an issue.
  * Then, discuss the issue until a consensus is found.
  * Either:
    * Clone the repository. Create a new branch and work there. <<< Preferred way
    * Fork the repository. Create a new branch and work there.
  * Finally, send a pull-request to the original repository linking to the previously created issue.



## License and copyright

This project is licensed under the [MIT License](LICENSE).
No copyright assignment is necessary to contribute, so copyrights are shared among contributors.
This project relies on third-party packages licensed under various OSI-approved MIT-like licenses - visit [THIRD-PARTY](THIRD-PARTY.md) for details.
