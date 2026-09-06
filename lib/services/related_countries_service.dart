import '../data/countries_data.dart';
import '../models/country.dart';

/// 基于地区与标签的相关国家推荐
class RelatedCountriesService {
  RelatedCountriesService._();

  static List<Country> relatedTo(Country country, {int limit = 4}) {
    final scored = <Country, int>{};

    for (final other in allCountries) {
      if (other.id == country.id) continue;
      var score = 0;
      if (other.region == country.region) score += 3;
      for (final tag in other.tags) {
        if (country.tags.contains(tag)) score += 2;
      }
      if (score > 0) scored[other] = score;
    }

    final sorted = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }
}
