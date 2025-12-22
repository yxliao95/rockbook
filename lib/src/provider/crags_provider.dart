import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crag_model.dart';
import '../services/fake_data_service.dart';

final provincesProvider = Provider<List<Province>>((ref) {
  return FakeDataService.instance.getProvinces();
});

final regionsByProvinceProvider = Provider.family<List<Region>, String>((ref, provinceId) {
  return FakeDataService.instance.getRegionsByProvince(provinceId);
});

final cragsByRegionProvider = Provider.family<List<CragSummary>, String>((ref, regionId) {
  return FakeDataService.instance.getCragsByRegion(regionId);
});

final cragDetailProvider = Provider.family<CragDetail?, String>((ref, cragId) {
  return FakeDataService.instance.getCragDetailById(cragId);
});

final cragByIdProvider = Provider.family<CragSummary?, String>((ref, cragId) {
  return FakeDataService.instance.getCragById(cragId);
});
