import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/region_model.dart';
import '../models/route_model.dart';
import '../services/crag_data_service.dart';

final cragDataProvider = FutureProvider<CragDataStore>((ref) async {
  return CragDataService.instance.load();
});

final regionChildrenProvider = Provider.family<AsyncValue<RegionChildren>, String?>((ref, regionId) {
  return ref.watch(cragDataProvider).whenData((data) {
    return RegionChildren(regions: data.childRegions(regionId), crags: data.cragsByRegion(regionId));
  });
});

final regionByIdProvider = Provider.family<RegionNode?, String>((ref, regionId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.regionById(regionId);
});

final regionSummaryProvider = Provider.family<GradeSummary, String>((ref, regionId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.regionSummary(regionId) ?? const GradeSummary.empty();
});

final cragByIdProvider = Provider.family<Crag?, String>((ref, cragId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.cragById(cragId);
});

final cragSummaryProvider = Provider.family<GradeSummary, String>((ref, cragId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.cragSummary(cragId) ?? const GradeSummary.empty();
});

final cragGradeDistributionProvider = Provider.family<List<GradeCount>, String>((ref, cragId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.gradeDistribution(cragId) ?? const [];
});

final wallsByCragProvider = Provider.family<List<Wall>, String>((ref, cragId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.wallsByCrag(cragId) ?? const [];
});

final routesByCragProvider = Provider.family<List<ClimbRoute>, String>((ref, cragId) {
  final data = ref.watch(cragDataProvider).asData?.value;
  return data?.routesByCrag(cragId) ?? const [];
});
