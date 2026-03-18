import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/providers.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/models/attendance.dart';
import '../../../shared/models/paginated_response.dart';
import '../data/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(dio: ref.watch(dioProvider));
});

class ClassesFilter {
  const ClassesFilter({
    required this.academyId,
    this.page = 1,
    this.search,
    this.classType,
    this.scheduledAfter,
    this.scheduledBefore,
  });
  final int academyId;
  final int page;
  final String? search;
  final ClassTypeEnum? classType;
  final DateTime? scheduledAfter;
  final DateTime? scheduledBefore;

  @override
  bool operator ==(Object other) =>
      other is ClassesFilter &&
      other.academyId == academyId &&
      other.page == page &&
      other.search == search &&
      other.classType == classType;

  @override
  int get hashCode => Object.hash(academyId, page, search, classType);
}

final trainingClassesProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<TrainingClass>, ClassesFilter>((ref, filter) async {
  return ref.watch(attendanceRepositoryProvider).listClasses(
        academyId: filter.academyId,
        page: filter.page,
        search: filter.search,
        classType: filter.classType,
        scheduledAfter: filter.scheduledAfter,
        scheduledBefore: filter.scheduledBefore,
      );
});

final trainingClassDetailProvider =
    FutureProvider.autoDispose.family<TrainingClass, int>((ref, id) async {
  return ref.watch(attendanceRepositoryProvider).getClass(id);
});

// Today's classes for current academy
final todaysClassesProvider = FutureProvider.autoDispose<List<TrainingClass>>((ref) async {
  final academyId = ref.watch(selectedAcademyIdProvider);
  if (academyId == null) return [];
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  final result = await ref.watch(attendanceRepositoryProvider).listClasses(
        academyId: academyId,
        scheduledAfter: start,
        scheduledBefore: end,
      );
  return result.results;
});

final qrCodeProvider =
    FutureProvider.autoDispose.family<QRCode, int>((ref, classId) async {
  return ref.watch(attendanceRepositoryProvider).generateQr(classId);
});

final dropInsProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<DropInVisitor>, int>((ref, academyId) async {
  return ref.watch(attendanceRepositoryProvider).listDropIns(academyId: academyId);
});
