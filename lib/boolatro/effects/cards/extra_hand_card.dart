import '../effect_context.dart';
import '../effect_patch.dart';
import '../effect_trigger.dart';
import '../special_card.dart';

/// Demo card: grants an extra hand at round start.
class ExtraHandCard extends SpecialCard {
  const ExtraHandCard({
    String id = 'partner.extra_hand',
    String name = 'Spare Hand',
    int cost = 5,
    String? imagePath,
  }) : super(id: id, name: name, cost: cost, imagePath: imagePath);

  @override
  EffectPatch onTrigger(EffectContext ctx) {
    if (ctx.trigger != EffectTrigger.onRoundStart) {
      return const EffectPatch();
    }
    return const EffectPatch(addHands: 1);
  }
}
