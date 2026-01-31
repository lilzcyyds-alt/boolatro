import '../effect_context.dart';
import '../effect_patch.dart';
import '../effect_trigger.dart';
import '../special_card.dart';

/// Demo card: rewards correct proofs.
class PartnerCard extends SpecialCard {
  const PartnerCard() : super(id: 'partner.basic', name: 'Partner', cost: 3);

  @override
  EffectPatch onTrigger(EffectContext ctx) {
    if (ctx.trigger != EffectTrigger.onProofSubmitted) {
      return const EffectPatch();
    }
    if (ctx.isProofValid == true) {
      return const EffectPatch(addScore: 10);
    }
    return const EffectPatch();
  }
}
