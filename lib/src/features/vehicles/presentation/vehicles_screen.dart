import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/enums.dart';
import '../../../core/format/vi_date_format.dart';
import '../../../core/strings/strings.dart';
import '../../../theme/app_theme.dart';
import '../data/vehicle_repository.dart';
import 'vehicle_detail_screen.dart';
import 'vehicle_form_sheet.dart';
import 'vehicles_providers.dart';
import 'vehicles_strings.dart';

/// Danh sách xe — mục 3 và mục 8 đặc tả.
///
/// Ba thứ nằm cố định trên đầu (ô tìm kiếm, chip lọc hạn, chip lọc bãi/loại)
/// và chỉ danh sách cuộn. Chủ bãi vừa gõ vừa nhìn kết quả; nếu ô tìm kiếm cuộn
/// theo thì gõ vài chữ là nó biến mất khỏi màn hình.
class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  /// Chờ 300ms sau phím cuối rồi mới truy vấn.
  ///
  /// Mỗi lần đổi từ khoá là dựng lại một stream Drift và một lượt quét bảng.
  /// Gõ "nguyen" mà bắn 6 truy vấn thì trên máy yếu danh sách giật thấy rõ, và
  /// 5 kết quả đầu chẳng ai kịp đọc. 300ms là quãng nghỉ tự nhiên giữa các
  /// phím, đủ ngắn để không thấy độ trễ.
  static const Duration _debounce = Duration(milliseconds: 300);

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void dispose() {
    // Bắt buộc: hẹn giờ còn treo lúc widget bị tháo sẽ gọi `ref` trên một
    // `ConsumerState` đã chết, và trong test thì mọi test đều đỏ với
    // "A Timer is still pending".
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    _clearSearch();
    setState(() {
      _isSearching = false;
    });
  }

  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      if (!mounted) return;
      ref.read(vehicleFilterProvider.notifier).setQuery(value);
    });
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchCtrl.clear();
    ref.read(vehicleFilterProvider.notifier).setQuery('');
  }

  void _clearAllFilters() {
    _debounceTimer?.cancel();
    _searchCtrl.clear();
    ref.read(vehicleFilterProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(vehicleFilterProvider);
    final vehicles = ref.watch(vehicleListProvider);
    final lots = ref.watch(activeLotsProvider).value ?? const <LotRow>[];
    final filtering = isFiltering(filter);
    final loaded = vehicles.value;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: _isSearching ? 0 : null,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: Strings.back,
                onPressed: _stopSearch,
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: _onQueryChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: Strings.searchHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchCtrl,
                    builder: (_, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: Strings.clearFilter,
                            onPressed: _clearSearch,
                          ),
                  ),
                ),
              )
            : const Text(Strings.vehiclesList),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: Strings.search,
              onPressed: _startSearch,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showVehicleFormSheet(context),
        icon: const Icon(Icons.add),
        // Nút chỉ có dấu "+" là rào cản với người dùng lớn tuổi — cùng lý do
        // thanh điều hướng của ứng dụng luôn hiện nhãn.
        label: const Text(Strings.vehicleAdd),
      ),
      body: Column(
        children: [
          _ExpiryChips(
            value: filter.expiry,
            onChanged: (e) =>
                ref.read(vehicleFilterProvider.notifier).setExpiry(e),
          ),
          _ScopeChips(
            filter: filter,
            lots: lots,
            onClearAll: _clearAllFilters,
          ),
          if (loaded != null && loaded.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  VehiclesStrings.matchCount(loaded.length),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          Expanded(
            child: vehicles.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(error: e),
              data: (items) => items.isEmpty
                  ? _EmptyView(filtering: filtering, onClear: _clearAllFilters)
                  : ListView.builder(
                      // Chừa chỗ cho nút "Thêm xe" nổi ở góc dưới, nếu không
                      // nó che mất dòng cuối cùng và người dùng tưởng danh
                      // sách hết ở đó.
                      padding: const EdgeInsets.only(bottom: 96, top: 4),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _VehicleTile(item: items[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bốn chip lọc theo trạng thái hạn.
class _ExpiryChips extends StatelessWidget {
  const _ExpiryChips({required this.value, required this.onChanged});

  final ExpiryFilter value;
  final ValueChanged<ExpiryFilter> onChanged;

  static String label(ExpiryFilter f) => switch (f) {
        ExpiryFilter.all => Strings.all,
        ExpiryFilter.current => VehiclesStrings.expiryCurrent,
        ExpiryFilter.expiringSoon => Strings.vehicleFilterExpiring,
        ExpiryFilter.expired => Strings.vehicleFilterExpired,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final f in ExpiryFilter.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: FilterChip(
                  label: Text(label(f)),
                  selected: value == f,
                  onSelected: (_) => onChanged(f),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Chip lọc theo bãi và theo loại xe, cộng nút bỏ lọc.
class _ScopeChips extends ConsumerWidget {
  const _ScopeChips({
    required this.filter,
    required this.lots,
    required this.onClearAll,
  });

  final VehicleFilter filter;
  final List<LotRow> lots;
  final VoidCallback onClearAll;

  String _lotLabel() {
    final id = filter.lotId;
    if (id == null) return VehiclesStrings.allLots;
    for (final l in lots) {
      if (l.id == id) return l.name;
    }
    return VehiclesStrings.allLots;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotName = _lotLabel();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: _PickerChip(
                label: lotName,
                active: filter.lotId != null,
                icon: Icons.local_parking,
                onTap: () => _pickLot(context, ref),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: _PickerChip(
                label: filter.type == null
                    ? VehiclesStrings.allTypes
                    : vehicleTypeLabel(filter.type!),
                active: filter.type != null,
                icon: Icons.two_wheeler,
                onTap: () => _pickType(context, ref),
              ),
            ),
          ),
          if (isFiltering(filter))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: ActionChip(
                  avatar: const Icon(Icons.filter_alt_off),
                  label: const Text(Strings.clearFilter),
                  onPressed: onClearAll,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Bảng chọn trả về **record một phần tử** chứ không trả thẳng `int?`, vì
  /// `null` từ `showModalBottomSheet` nghĩa là người dùng vuốt đóng bảng — cần
  /// phân biệt với việc họ cố ý chọn "Mọi bãi".
  Future<void> _pickLot(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<(int?,)>(
      context: context,
      useSafeArea: true,
      builder: (ctx) => _PickerSheet(
        title: VehiclesStrings.pickLotTitle,
        children: [
          ListTile(
            title: const Text(VehiclesStrings.allLots),
            selected: filter.lotId == null,
            onTap: () => Navigator.pop(ctx, (null,)),
          ),
          for (final l in lots)
            ListTile(
              title: Text(l.name),
              selected: filter.lotId == l.id,
              onTap: () => Navigator.pop(ctx, (l.id,)),
            ),
        ],
      ),
    );
    if (picked == null) return;
    ref.read(vehicleFilterProvider.notifier).setLot(picked.$1);
  }

  Future<void> _pickType(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<(VehicleType?,)>(
      context: context,
      useSafeArea: true,
      builder: (ctx) => _PickerSheet(
        title: VehiclesStrings.pickTypeTitle,
        children: [
          ListTile(
            title: const Text(VehiclesStrings.allTypes),
            selected: filter.type == null,
            onTap: () => Navigator.pop(ctx, (null,)),
          ),
          for (final t in VehicleType.values)
            ListTile(
              title: Text(vehicleTypeLabel(t)),
              selected: filter.type == t,
              onTap: () => Navigator.pop(ctx, (t,)),
            ),
        ],
      ),
    );
    if (picked == null) return;
    ref.read(vehicleFilterProvider.notifier).setType(picked.$1);
  }
}

class _PickerSheet extends StatelessWidget {
  const _PickerSheet({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({
    required this.label,
    required this.active,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icon, color: active ? colors.onSecondaryContainer : null),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: active ? colors.secondaryContainer : null,
      // Viền dày hơn khi đang lọc: chip đổi màu thôi là chưa đủ cho người phân
      // biệt màu kém.
      side: active ? BorderSide(color: colors.secondary, width: 2) : null,
    );
  }
}

/// Một dòng xe trong danh sách.
class _VehicleTile extends StatelessWidget {
  const _VehicleTile({required this.item});

  final VehicleListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = item.vehicle;

    final expiryLine = item.hasNeverPaid
        ? VehiclesStrings.neverPaidSince(formatDay(v.startDate))
        : '${Strings.paymentPeriodEnd} ${formatDay(v.currentPeriodEnd!)}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => VehicleDetailScreen(vehicleId: v.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Thẻ biển số kiểu mới: viền đậm, font nổi bật như biển xe thật
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          v.plate,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(item: item),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      v.vehicleType == VehicleType.car
                          ? Icons.directions_car
                          : Icons.two_wheeler,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${v.ownerName} · ${item.lotName}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  expiryLine,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thẻ trạng thái hạn của một dòng.
///
/// **Màu không bao giờ là tín hiệu duy nhất** — thẻ luôn mang chữ từ
/// `formatDaysRemaining` ("còn 5 ngày", "quá hạn 70 ngày"), đọc được cả khi in
/// đen trắng hay khi người dùng không phân biệt đỏ với xanh.
///
/// Xe **chưa đóng tiền lần nào** dùng thẻ hình dạng khác hẳn — viền, không tô
/// nền, kèm biểu tượng gạch tiền — chứ không phải cùng thẻ đỏ với xe quá hạn.
/// Hai tình huống này đòi hỏi hai hành động khác nhau: một bên thu kỳ tiếp
/// theo, một bên truy thu từ ngày bắt đầu gửi.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.item});

  final VehicleListItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = context.statusColors;

    if (item.daysLeft == null) {
      return Chip(
        avatar: Icon(Icons.money_off, size: 18, color: status.expired),
        label: const Text(VehiclesStrings.neverPaidChip),
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(color: status.expired, width: 2),
        labelStyle:
            theme.textTheme.labelMedium?.copyWith(color: status.expired),
      );
    }

    final days = item.daysLeft!;
    return Chip(
      label: Text(formatDaysRemaining(days)),
      backgroundColor: status.containerForDaysRemaining(days),
      side: BorderSide.none,
      labelStyle: theme.textTheme.labelMedium,
    );
  }
}

/// Hai câu khác nhau cho hai tình huống khác nhau.
///
/// "Chưa có xe nào" là lời mời nhập liệu; "Không tìm thấy kết quả nào" là lời
/// nhắc rằng dữ liệu vẫn còn đó, chỉ đang bị bộ lọc che. Dùng chung một câu sẽ
/// khiến người dùng đi thêm xe trong khi thứ họ cần là bấm "Bỏ lọc".
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.filtering, required this.onClear});

  final bool filtering;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
        child: Column(
          children: [
            Icon(
              filtering ? Icons.search_off : Icons.two_wheeler_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              filtering ? Strings.noResult : Strings.vehicleEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              filtering
                  ? VehiclesStrings.noResultHint
                  : VehiclesStrings.emptyHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (filtering) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text(Strings.clearFilter),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 40, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 8),
          const Text(Strings.errorGeneric, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
