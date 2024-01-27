# Dart Blog Backend

Minimal Dart Backend example with JWT Authentication & SQLite Database for persistence

![dart](https://github.com/codekeyz/yaroo-starter/actions/workflows/test.yml/badge.svg)

### Setup

```shell
$ dart pub get && dart run build_runner build --delete-conflicting-outputs
```

### Migrate Database

```shell
$ dart run bin/tools/migrator.dart migrate
```

### Start Server

```shell
$ dart run
```

### Tests

```shell
$ dart test
```

### Workflow

Things like adding a new `Entity`, `Middleware`, `Controller` or `Controller Method` require you to re-run the command below.

```shell
$ dart pub run build_runner build --delete-conflicting-outputs
```
