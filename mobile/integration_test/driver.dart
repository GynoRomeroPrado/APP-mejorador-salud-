import 'package:integration_test/integration_test_driver.dart';

/// Integration test driver
///
/// This file is used to run integration tests from the command line
/// Usage: flutter drive --driver=integration_test/driver.dart --target=integration_test/test_file.dart
Future<void> main() => integrationDriver();
