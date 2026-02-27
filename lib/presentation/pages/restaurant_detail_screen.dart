import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/menu.dart';
import '../../data/datasources/remote/menu_remote_datasource.dart';
import '../bloc/settings_bloc.dart';
import 'review_screen.dart';
import 'restaurant_reviews_screen.dart';
import '../widgets/shimmer_widgets.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  final MenuRemoteDatasource _menuService = MenuRemoteDatasource();
  RestaurantMenu? _menu;
  bool _isLoading = true;
  int _selectedSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadMenu();
  }

  void _scrollListener() {
    if (_scrollController.offset > 160 && !_isCollapsed) {
      setState(() => _isCollapsed = true);
    } else if (_scrollController.offset <= 160 && _isCollapsed) {
      setState(() => _isCollapsed = false);
    }
  }

  Future<void> _loadMenu() async {
    try {
      final settingsState = context.read<SettingsBloc>().state;
      final menu = await _menuService.getRestaurantMenu(
        restaurantId: widget.restaurant.id,
        language: settingsState.apiLanguage,
      );
      setState(() {
        _menu = menu;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('error_loading')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard()),
                      const SizedBox(width: 12),
                      _buildCommentButton(l10n),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    l10n.translate('menu'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverToBoxAdapter(child: MenuGridShimmer(count: 6))
          else ...[
            if (_menu != null && _menu!.sections.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _menu!.sections.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildCategoryItem(
                          l10n.translate('all_items'),
                          _selectedSectionIndex == 0,
                          0,
                        );
                      }
                      return _buildCategoryItem(
                        _menu!.sections[index - 1].name,
                        _selectedSectionIndex == index,
                        index,
                      );
                    },
                  ),
                ),
              ),
            _buildMenuGrid(l10n),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.card,
      title: _isCollapsed
          ? Text(
        widget.restaurant.name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          child: widget.restaurant.coverImageUrl != null
              ? Image.network(
            widget.restaurant.coverImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: AppColors.background);
            },
          )
              : Container(color: AppColors.background),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildCircleButton(Icons.arrow_back, () => Navigator.pop(context)),
      ),

    );
  }

  Widget _buildHeaderSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.restaurant.brand?.logoUrl != null
                ? Image.network(
              widget.restaurant.brand!.logoUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.restaurant, color: AppColors.iconSecondary);
              },
            )
                : const Icon(Icons.restaurant, color: AppColors.iconSecondary),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.restaurant.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "${widget.restaurant.category?.name ?? 'Restoran'} • ${widget.restaurant.address ?? ''}",
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid(AppLocalizations l10n) {
    if (_menu == null || _menu!.sections.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              l10n.translate('nothing_found'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    // Index 0 = Barcha (hamma taomlar), boshqasi = sections[index - 1]
    List<MenuItem> currentItems;
    if (_selectedSectionIndex == 0) {
      // Barcha taomlarni yig'ish
      currentItems = _menu!.sections
          .expand((section) => section.items ?? <MenuItem>[])
          .toList();
    } else {
      currentItems = _menu!.sections[_selectedSectionIndex - 1].items ?? [];
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => _buildFoodCard(currentItems[index]),
          childCount: currentItems.length,
        ),
      ),
    );
  }

  Widget _buildFoodCard(MenuItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: item.imageUrl != null
                  ? Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.background,
                    child: const Center(
                      child: Icon(Icons.fastfood, color: AppColors.iconSecondary),
                    ),
                  );
                },
              )
                  : Container(
                color: AppColors.background,
                child: const Center(
                  child: Icon(Icons.fastfood, color: AppColors.iconSecondary),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${item.price?.toStringAsFixed(0) ?? '0'} so'm",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.weight != null)
                  Text(
                    '${item.weight} g',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedSectionIndex = index),
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }

  Widget _buildInfoCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantReviewsScreen(restaurant: widget.restaurant),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: AppColors.starRating, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.restaurant.averageRating?.toStringAsFixed(1) ?? "0.0",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              "(${widget.restaurant.reviewsCount ?? 0})",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.iconSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(restaurant: widget.restaurant),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          l10n.translate('reviews'),
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}