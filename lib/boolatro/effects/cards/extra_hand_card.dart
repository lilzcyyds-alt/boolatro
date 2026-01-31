import '../effect_context.dart';
import '../effect_patch.dart';
import '../effect_trigger.dart';
import '../special_card.dart';

/// Demo card: grants an extra hand at round start.
class ExtraHandCard extends SpecialCard {
  const ExtraHandCard()
      : super(id: 'partner.extra_hand', name: 'Spare Hand', cost: 5);

  @override
  EffectPatch onTrigger(EffectContext ctx) {
    if (ctx.trigger != EffectTrigger.onRoundStart) {
      return const EffectPatch();
    }
    return const EffectPatch(addHands: 1);
  }
}
