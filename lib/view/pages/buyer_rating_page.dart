import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uc_marketplace/viewmodel/rating_viewmodel.dart';

class RatingDialog extends StatefulWidget {
  final int menuId;
  final int? orderId;
  final int? preOrderId;
  final String menuName;

  const RatingDialog({
    super.key,
    required this.menuId,
    required this.menuName,
    this.orderId,
    this.preOrderId,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Kita gunakan ChangeNotifierProvider lokal di sini agar praktis
    return ChangeNotifierProvider(
      create: (_) => RatingViewModel(),
      child: Consumer<RatingViewModel>(
        builder: (context, vm, child) {
          return AlertDialog(
            title: Text("Nilai ${widget.menuName}"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Bagaimana rasa makanannya?"),
                const SizedBox(height: 16),
                
                // Bintang Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < _selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 16),
                
                // Komentar Input
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: "Tulis ulasanmu (opsional)...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final success = await vm.submitRating(
                          menuId: widget.menuId,
                          ratingValue: _selectedRating,
                          comment: _commentController.text,
                          orderId: widget.orderId,
                          preOrderId: widget.preOrderId,
                        );

                        if (success && context.mounted) {
                          Navigator.pop(context); // Tutup dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Terima kasih atas ulasannya!")),
                          );
                        }
                      },
                child: vm.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Kirim"),
              ),
            ],
          );
        },
      ),
    );
  }
}