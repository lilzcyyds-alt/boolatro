import '../boolatro/effects/effects.dart';
import '../game/systems/card_system.dart';

class ShopState {
  int money = 0;
  int inventoryLimit = 3;

  final List<SpecialCard> owned = <SpecialCard>[];
  final List<SpecialCard> inventory = <SpecialCard>[];

  void seedDemoInventory() {
    inventory.clear();
    
    // Convert CardConfigs to SpecialCards
    // For now, we still have hardcoded classes, but we should map them by ID
    for (final config in CardSystem.cards) {
      SpecialCard? card;
      if (config.id == 'partner_card_1') card = const PartnerCard();
      else if (config.id == 'alchemy_card_1') card = const AlchemyCard();
      else if (config.id == 'extra_hand_card_1') card = const ExtraHandCard();
      
      if (card != null) {
        inventory.add(card);
      }
    }
  }

  bool canBuy(SpecialCard card) {
    if (owned.length >= inventoryLimit) {
      return false;
    }
    return money >= card.cost;
  }

  bool buy(SpecialCard card) {
    if (!canBuy(card)) {
      return false;
    }
    money -= card.cost;
    owned.add(card);
    inventory.remove(card);
    return true;
  }
}
