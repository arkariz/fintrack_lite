/// Base state with effect property
///
/// Usage: `class MyState extends UiState with EffectClearable<MyState>`
/// Important: Exclude `effect` from `props` to prevent rebuilds
library;

import 'package:equatable/equatable.dart';
import 'package:health_duel/core/bloc/base/effect/ui_effect.dart';

/// Base state with optional effect
abstract class UiState extends Equatable {
  final UiEffect? effect;

  const UiState({this.effect});

  bool get hasEffect => effect != null;
}

/// Mixin for effect manipulation in copyWith
mixin EffectClearable<T extends UiState> on UiState {
  T clearEffect();
  T withEffect(UiEffect? effect);
}
