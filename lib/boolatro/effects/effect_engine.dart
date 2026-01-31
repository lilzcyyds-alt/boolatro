import 'effect_context.dart';
import 'effect_patch.dart';
import 'special_card.dart';

class EffectEngine {
  const EffectEngine();

  EffectPatch computePatch({
    required List<SpecialCard> cards,
    required EffectContext ctx,
  }) {
    var patch = const EffectPatch();
    for (final card in cards) {
      patch = patch + card.onTrigger(ctx);
    }
    return patch;
  }
}
