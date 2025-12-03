part of 'widgets.dart';

class CustomCardH extends StatefulWidget {
  final String imagePath;
  final String title;
  final double height;
  final String location;
  const CustomCardH({
    super.key,
    required this.imagePath,
    required this.title,

    this.height = 60,
    required this.location,
  });

  @override
  State<CustomCardH> createState() => _CustomCardHState();
}

class _CustomCardHState extends State<CustomCardH> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,

      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 254, 254, 254),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300, // warna border tipis
          width: 1,
        ),
        
      ),
      
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  widget.imagePath, // gunakan variabel dari widget
                  width: 42,
                  height: 42,
                  fit: BoxFit.fill,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    widget.location,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          Text("3,5 km"),
        ],
      ),
    );
  }
}
