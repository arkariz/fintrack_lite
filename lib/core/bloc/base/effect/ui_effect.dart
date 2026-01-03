/// Base classes for UI effects
library;

import 'package:equatable/equatable.dart';

/// Base class for one-shot side effects
abstract class UiEffect extends Equatable {
  const UiEffect();

  String get effectId => '$runtimeType@${identityHashCode(this)}';

  @override
  bool? get stringify => true;
}
