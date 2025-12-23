import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crag_model.dart';
import '../services/fake_data_service.dart';

// 这是一个 无参数的只读 Provider，作用是：向整个应用提供一份「省份列表」数据。表示同步、不可变、无状态的数据来源。不会自动刷新，不会监听变化
final provincesProvider = Provider<List<Province>>((ref) {
  return FakeDataService.instance.getProvinces();
});

// 这是一个 带参数的 Provider（family），作用是：根据「省份 ID」，动态提供该省份下的区域列表。
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
