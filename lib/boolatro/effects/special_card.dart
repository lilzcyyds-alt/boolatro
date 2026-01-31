import 'effect_context.dart';
import 'effect_patch.dart';
import 'effect_trigger.dart';

abstract class SpecialCard {
  const SpecialCard({
    required this.id,
    required this.name,
    required this.cost,
  });

  final String id;
  final String name;
  final int cost;

  /// Return an [EffectPatch] to apply for this trigger.
  EffectPatch onTrigger(EffectContext ctx);

  bool supports(EffectTrigger trigger) => true;
}
