String levelDisplayName(String? levelId) {
  switch (levelId) {
    case 'l1': return 'Level 1';
    case 'l2': return 'Level 2';
    case 'l3': return 'Level 3';
    default: return levelId ?? 'No Level';
  }
}

String levelIdFromDisplay(String display) {
  switch (display) {
    case 'Level 1': return 'l1';
    case 'Level 2': return 'l2';
    case 'Level 3': return 'l3';
    default: return display;
  }
}
