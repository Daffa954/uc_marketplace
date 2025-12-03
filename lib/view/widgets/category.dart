part of 'widgets.dart';

class CategoryItem extends StatelessWidget {
  final String label;
  final String emoji;

  const CategoryItem({super.key, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      height: 35,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Text(
        "$emoji $label",
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 12
        ),
      ),
    );
  }
}
