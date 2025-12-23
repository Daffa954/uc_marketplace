part of 'widgets.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    // Akses ViewModel
    final homeVM = Provider.of<HomeViewModel>(context);
    final categories = homeVM.categories;

    if (homeVM.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 0), // Sesuaikan padding
          child: Text(
            "Category",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 110, // Tinggi area scroll
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            // Jumlah item = Total Kategori + 1 (untuk tombol "All")
            itemCount: categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              // ITEM 1: Tombol "All"
              if (index == 0) {
                final isSelected = homeVM.selectedCategoryId == 0;
                return _CategoryItem(
                  label: "All",
                  // Gunakan icon static untuk All
                  iconWidget: Icon(
                    Icons.grid_view_rounded,
                    color: isSelected ? Colors.white : const Color(0xFFFF7F27),
                  ),
                  isSelected: isSelected,
                  onTap: () => homeVM.selectCategory(0),
                );
              }

              // ITEM 2 dst: Kategori dari Database
              final category = categories[index - 1];
              final isSelected =
                  homeVM.selectedCategoryId == category.generalCategoryId;

              return _CategoryItem(
                label: category.name ?? 'Unknown',
                // Tampilkan gambar dari URL, atau icon placeholder jika null
                iconWidget: category.imageUrl != null
                    ? Image.network(category.imageUrl!, width: 40, height: 40)
                    : Icon(
                        Icons.fastfood,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFFF7F27),
                      ),
                isSelected: isSelected,
                onTap: () =>
                    homeVM.selectCategory(category.generalCategoryId ?? 0),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Widget Helper Kecil untuk Kotak Kategori
class _CategoryItem extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.iconWidget,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 90, // Lebar fix kotak
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7F27) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
          border: isSelected ? null : Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lingkaran Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey[50],
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Center(child: iconWidget),
            ),
            const SizedBox(height: 8),
            // Text Label
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
