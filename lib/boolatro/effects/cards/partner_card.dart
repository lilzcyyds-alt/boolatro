import '../effect_context.dart';
import '../effect_patch.dart';
import '../effect_trigger.dart';
import '../special_card.dart';

/// Demo card: rewards correct proofs.
class PartnerCard extends SpecialCard {
  const PartnerCard({
    String id = 'partner.basic',
    String name = 'Partner',
    int cost = 3,
    String? imagePath,
  }) : super(id: id, name: name, cost: cost, imagePath: imagePath);

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
