/// A simple, composable patch produced by cards.
///
/// We keep this tiny for Phase 4 baseline. Later we can evolve into a richer
/// modifier system (multipliers, triggers, replacement effects, etc.).
class EffectPatch {
  const EffectPatch({
    this.addScore = 0,
    this.addHands = 0,
  });

  final int addScore;
  final int addHands;

  EffectPatch operator +(EffectPatch other) => EffectPatch(
        addScore: addScore + other.addScore,
        addHands: addHands + other.addHands,
      );
}
