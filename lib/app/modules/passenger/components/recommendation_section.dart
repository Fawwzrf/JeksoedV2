import 'package:flutter/material.dart';

class Recommendation {
  final String imageResId;
  final String title;
  final String description;
  final String italicWord;

  Recommendation({
    required this.imageResId,
    required this.title,
    required this.description,
    required this.italicWord,
  });
}

class RecommendationSection extends StatelessWidget {
  const RecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk ditampilkan dalam daftar
    final recommendations = [
      Recommendation(
        imageResId: "assets/images/cafe_banner.jpeg",
        title: "Cafe Terbaik di Purwokerto",
        description: "Kunjungi cafe-cafe menarik untuk ngopi santai",
        italicWord: "liat",
      ),
      Recommendation(
        imageResId: "assets/images/wisata_banner.jpeg",
        title: "Destinasi Wisata Populer",
        description: "Jelajahi tempat wisata menarik di sekitar Unsoed",
        italicWord: "jelajahi",
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bagian Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cucu Jendral belum pernah kesini? Rugi dong!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Cari berbagai rekomendasi tempat dan kegiatan seru di sekitar Purwokerto!",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // List rekomendasi
        ...recommendations.map((recommendation) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RecommendationItemCard(
              recommendation: recommendation,
              onClick: () {
                // Handle click
              },
            ),
          );
        }),
      ],
    );
  }
}

class RecommendationItemCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback onClick;

  const RecommendationItemCard({
    super.key,
    required this.recommendation,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onClick,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Image.asset(
                    recommendation.imageResId,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),

              // Konten
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        children: [
                          TextSpan(
                            text: recommendation.description.replaceAll(
                              recommendation.italicWord,
                              "",
                            ),
                          ),
                          TextSpan(
                            text: recommendation.italicWord,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
