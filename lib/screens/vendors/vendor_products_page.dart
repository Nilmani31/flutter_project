import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wedding_planner_provider.dart';
import '../../models/vendor_model.dart';

class VendorProductsPage extends StatefulWidget {
  const VendorProductsPage({super.key});

  @override
  State<VendorProductsPage> createState() => _VendorProductsPageState();
}

class _VendorProductsPageState extends State<VendorProductsPage> {
  String _selectedCategory = 'All';
  final List<String> _productCategories = [
    'All',
    'Hotel/Venue',
    'Decoration',
    'Dressing/Makeup',
    'Catering',
    'Photography',
    'Other Services',
  ];

  @override
  void initState() {
    super.initState();
    // Load vendors and products from Firebase when page loads
    final provider = Provider.of<WeddingPlannerProvider>(context, listen: false);
    provider.loadVendors();
    provider.loadProducts();
  }

  void _showVendorDetails(Vendor vendor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(vendor.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Category', value: vendor.category),
              const SizedBox(height: 12),
              _DetailRow(label: 'Description', value: vendor.description),
              const SizedBox(height: 12),
              _DetailRow(label: 'Contact', value: vendor.contact),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Contact request sent to ${vendor.name}'),
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeddingPlannerProvider>(
      builder: (context, provider, _) {
        // Filter products by selected category
        final filteredProducts = _selectedCategory == 'All'
            ? provider.products
            : provider.products.where((p) => p.category == _selectedCategory).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Vendors & Products'),
            elevation: 0,
          ),
          body: provider.loadingVendors || provider.loadingProducts
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: _productCategories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Products List
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No products in this category',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Check back soon!',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              children: filteredProducts.map((product) {
                                // Find vendor for this product
                                final vendor = provider.vendors.firstWhere(
                                  (v) => v.vendorID == product.vendorID,
                                  orElse: () => Vendor(
                                    vendorID: '',
                                    password: '',
                                    name: 'Unknown Vendor',
                                    description: '',
                                    contact: '',
                                    category: '',
                                  ),
                                );
                                return _ProductCard(
                                  productName: product.title,
                                  vendorName: vendor.name,
                                  price: product.price,
                                  description: product.description,
                                  onTap: () => _showVendorDetails(vendor),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

// Detail Row Widget
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Product Card Widget
class _ProductCard extends StatelessWidget {
  final String productName;
  final String vendorName;
  final double price;
  final String description;
  final VoidCallback onTap;

  const _ProductCard({
    required this.productName,
    required this.vendorName,
    required this.price,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      productName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '\$${price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                vendorName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
