import 'package:tamanna/data/models/category_model.dart';
import 'package:tamanna/data/models/package_model.dart';
import 'package:tamanna/data/models/service_model.dart';
import 'package:tamanna/data/repositories/category_repository.dart';
import 'package:tamanna/data/repositories/package_repository.dart';
import 'package:tamanna/data/repositories/service_repository.dart';

class SearchHit {
  final String type;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String route;

  const SearchHit({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.route,
  });
}

class SearchRepository {
  final _categories = CategoryRepository();
  final _services = ServiceRepository();
  final _packages = PackageRepository();

  Future<List<SearchHit>> search(String term) async {
    final q = term.trim();
    if (q.length < 2) return [];
    final results = await Future.wait([
      _services.search(q),
      _packages.search(q),
      _categories.fetchActive(),
    ]);
    final services = results[0] as List<ServiceModel>;
    final packages = results[1] as List<PackageModel>;
    final categories = (results[2] as List<CategoryModel>)
        .where((c) => c.name.toLowerCase().contains(q.toLowerCase()))
        .take(5)
        .toList();

    return [
      ...categories.map(
        (c) => SearchHit(
          type: 'Category',
          title: c.name,
          subtitle: c.description,
          imageUrl: c.imageUrl,
          route: '/categories/${c.slug}',
        ),
      ),
      ...services.map(
        (s) => SearchHit(
          type: 'Service',
          title: s.name,
          subtitle: s.shortDescription,
          imageUrl: s.imageUrl,
          route: '/services/${s.slug}',
        ),
      ),
      ...packages.map(
        (p) => SearchHit(
          type: 'Package',
          title: p.name,
          subtitle: p.description,
          imageUrl: p.imageUrl,
          route: '/packages/${p.slug}',
        ),
      ),
    ];
  }
}
