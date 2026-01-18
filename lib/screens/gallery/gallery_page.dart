import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wedding_planner_provider.dart';
import '../../models/gallery_item_model.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  void initState() {
    super.initState();
    // Load gallery items when page opens
    Future.microtask(() {
      Provider.of<WeddingPlannerProvider>(context, listen: false).loadGallery();
    });
  }

  void _showAddImageDialog(BuildContext context, WeddingPlannerProvider provider) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Saree';
    
    final List<String> categories = ['Saree', 'Lehenga', 'Jewelry', 'Makeup', 'Decoration', 'Venue', 'Other'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Image to Gallery'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (e.g., Red Bridal Saree)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((cat) => 
                  DropdownMenuItem(value: cat, child: Text(cat))
                ).toList(),
                onChanged: (value) => selectedCategory = value ?? 'Saree',
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (why you like it)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                final galleryItem = GalleryItem(
                  title: titleController.text,
                  description: descriptionController.text,
                  url: urlController.text,
                  category: selectedCategory,
                  createdAt: DateTime.now(),
                );
                await provider.addGalleryItem(galleryItem);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image added to gallery!')),
                  );
                }
              }
            },
            child: const Text('Add to Gallery'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingPlannerProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Inspiration Gallery'),
            elevation: 0,
          ),
          body: provider.loadingGallery
              ? const Center(child: CircularProgressIndicator())
              : provider.galleryItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No images saved yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your favorite wedding ideas',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: provider.galleryItems.length,
                      itemBuilder: (context, index) {
                        final item = provider.galleryItems[index];
                        return _GalleryItemCard(
                          item: item,
                          onDelete: () async {
                            await provider.deleteGalleryItem(item.id ?? '');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Image removed from gallery')),
                              );
                            }
                          },
                        );
                      },
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddImageDialog(context, provider),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// Gallery Item Card Widget
class _GalleryItemCard extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback? onDelete;

  const _GalleryItemCard({
    required this.item,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey[300],
                    ),
                    child: item.url.isNotEmpty
                        ? Image.network(
                            item.url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 40, color: Colors.grey[600]),
                                    const SizedBox(height: 8),
                                    Text('Image not found', style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                          ),
                  ),
                ),
                // Title & Description
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(
                            item.category ?? 'Uncategorized',
                            style: const TextStyle(fontSize: 9),
                          ),
                          backgroundColor: Colors.pink.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Flexible(
                            child: Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Delete Button
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                onPressed: onDelete,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  padding: EdgeInsets.zero,
                  fixedSize: const Size(32, 32),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
