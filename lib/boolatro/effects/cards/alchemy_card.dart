import '../effect_context.dart';
import '../effect_patch.dart';
import '../effect_trigger.dart';
import '../special_card.dart';

/// Demo card: gives small consolation points on failed submits.
class AlchemyCard extends SpecialCard {
  const AlchemyCard({
    String id = 'alchemy.basic',
    String name = 'Alchemy',
    int cost = 4,
    String? imagePath,
  }) : super(id: id, name: name, cost: cost, imagePath: imagePath);

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
