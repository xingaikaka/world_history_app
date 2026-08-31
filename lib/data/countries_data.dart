import '../models/country.dart';
import 'asia_countries.dart';
import 'europe_countries.dart';
import 'other_countries.dart';
import 'other_countries_extra.dart';
import 'more_countries.dart';

/// 全部国家历史数据
final List<Country> allCountries = [
  china,
  japan,
  india,
  korea,
  egypt,
  greece,
  italy,
  france,
  spain,
  uk,
  germany,
  russia,
  usa,
  turkey,
  iran,
  mexico,
  brazil,
  australia,
];

/// 按地区分组
final Map<String, List<Country>> countriesByRegion = {
  for (final region in allCountries.map((c) => c.region).toSet())
    region: allCountries.where((c) => c.region == region).toList(),
};

Country? countryById(String id) {
  try {
    return allCountries.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

const allRegions = ['全部', '亚洲', '欧洲', '非洲', '北美洲', '南美洲', '西亚', '欧洲/亚洲', '大洋洲'];
