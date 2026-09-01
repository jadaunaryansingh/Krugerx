class FeatureFlags {
  // Phase A: Tab Management Foundation (reorder, pin, mute, close with undo)
  static const bool enablePhaseA = true;
  
  // Phase B: Session & History Data Layer (Isar session save/restore, kruger://history)
  static const bool enablePhaseB = false;

  // Phase C: Address Bar Autocomplete (tabs + history)
  static const bool enablePhaseC = false;

  // Phase D: Extending the Tab Model (groups, zoom, multi-window drag)
  static const bool enablePhaseD = false;

  // Phase E: Independent Page-Level Features (reader mode, find-in-page, split-screen)
  static const bool enablePhaseE = false;
}
