import '../effect_context.dart';
import '../effect_patch.dart';
import '../effect_trigger.dart';
import '../special_card.dart';

/// Demo card: gives small consolation points on failed submits.
class AlchemyCard extends SpecialCard {
  const AlchemyCard() : super(id: 'alchemy.basic', name: 'Alchemy', cost: 4);

  @override
  EffectPatch onTrigger(EffectContext ctx) {
    if (ctx.trigger != EffectTrigger.onProofSubmitted) {
      return const EffectPatch();
    }
    if (ctx.isProofValid == false) {
      return const EffectPatch(addScore: 3);
    }
    return const EffectPatch();
  }
}
