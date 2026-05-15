import 'package:flutter/material.dart';

class IconResolver {
  static IconData getIcon(String? code, {IconData fallback = Icons.category}) {
    if (code == null || code.isEmpty) return fallback;

    // Direct comparison with local codePoints to handle version mismatches
    if (code == Icons.category.codePoint.toString()) return Icons.category;
    if (code == Icons.fitness_center.codePoint.toString()) return Icons.fitness_center;
    if (code == Icons.work.codePoint.toString()) return Icons.work;
    if (code == Icons.spa.codePoint.toString()) return Icons.spa;
    if (code == Icons.self_improvement.codePoint.toString()) return Icons.self_improvement;
    if (code == Icons.book.codePoint.toString()) return Icons.book;
    if (code == Icons.water_drop.codePoint.toString()) return Icons.water_drop;
    if (code == Icons.restaurant.codePoint.toString()) return Icons.restaurant;
    if (code == Icons.nightlight_round.codePoint.toString()) return Icons.nightlight_round;
    if (code == Icons.star.codePoint.toString()) return Icons.star;
    if (code == Icons.favorite.codePoint.toString()) return Icons.favorite;
    if (code == Icons.pets.codePoint.toString()) return Icons.pets;
    if (code == Icons.commute.codePoint.toString()) return Icons.commute;
    if (code == Icons.menu_book.codePoint.toString()) return Icons.menu_book;
    if (code == Icons.home.codePoint.toString()) return Icons.home;
    if (code == Icons.person.codePoint.toString()) return Icons.person;
    if (code == Icons.history.codePoint.toString()) return Icons.history;
    if (code == Icons.settings.codePoint.toString()) return Icons.settings;
    if (code == Icons.edit.codePoint.toString()) return Icons.edit;
    if (code == Icons.search.codePoint.toString()) return Icons.search;
    if (code == Icons.notifications.codePoint.toString()) return Icons.notifications;

    // Activity Icons
    if (code == Icons.directions_run.codePoint.toString()) return Icons.directions_run;
    if (code == Icons.directions_bike.codePoint.toString()) return Icons.directions_bike;
    if (code == Icons.pool.codePoint.toString()) return Icons.pool;
    if (code == Icons.sports_soccer.codePoint.toString()) return Icons.sports_soccer;
    if (code == Icons.sports_basketball.codePoint.toString()) return Icons.sports_basketball;
    if (code == Icons.sports_tennis.codePoint.toString()) return Icons.sports_tennis;
    if (code == Icons.sports_volleyball.codePoint.toString()) return Icons.sports_volleyball;
    if (code == Icons.sports_gymnastics.codePoint.toString()) return Icons.sports_gymnastics;
    if (code == Icons.sports_kabaddi.codePoint.toString()) return Icons.sports_kabaddi;
    if (code == Icons.sports_mma.codePoint.toString()) return Icons.sports_mma;
    if (code == Icons.sports_cricket.codePoint.toString()) return Icons.sports_cricket;
    if (code == Icons.sports_golf.codePoint.toString()) return Icons.sports_golf;
    if (code == Icons.sports_hockey.codePoint.toString()) return Icons.sports_hockey;
    if (code == Icons.sports_martial_arts.codePoint.toString()) return Icons.sports_martial_arts;
    if (code == Icons.sports_motorsports.codePoint.toString()) return Icons.sports_motorsports;
    if (code == Icons.sports_rugby.codePoint.toString()) return Icons.sports_rugby;
    if (code == Icons.sports_score.codePoint.toString()) return Icons.sports_score;
    if (code == Icons.directions_walk.codePoint.toString()) return Icons.directions_walk;
    if (code == Icons.sports_bar.codePoint.toString()) return Icons.sports_bar;
    if (code == Icons.snowboarding.codePoint.toString()) return Icons.snowboarding;
    if (code == Icons.skateboarding.codePoint.toString()) return Icons.skateboarding;

    return fallback;
  }

  static String getCode(IconData icon) {
    return icon.codePoint.toString();
  }
}
