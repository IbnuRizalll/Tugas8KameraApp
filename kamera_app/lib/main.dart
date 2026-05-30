import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF2563EB);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Kamera',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF111827),
        ),
      ),
      home: const CameraPage(),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _photos = <File>[];
  int? _selectedPhotoIndex;
  bool _isPickingImage = false;

  File? get _selectedPhoto {
    final index = _selectedPhotoIndex;
    if (index == null || index < 0 || index >= _photos.length) {
      return null;
    }
    return _photos[index];
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (!mounted || image == null) return;

      setState(() {
        _photos.insert(0, File(image.path));
        _selectedPhotoIndex = 0;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka kamera atau galeri. Coba lagi.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _deleteSelectedPhoto() {
    final index = _selectedPhotoIndex;
    if (index == null) return;

    setState(() {
      _photos.removeAt(index);
      _selectedPhotoIndex = _photos.isEmpty ? null : 0;
    });
  }

  void _clearPhotos() {
    setState(() {
      _photos.clear();
      _selectedPhotoIndex = null;
    });
  }

  void _openPhotoPreview(File photo) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.7,
                  maxScale: 4,
                  child: Image.file(photo, fit: BoxFit.contain),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton.filledTonal(
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kamera Studio',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_photos.isNotEmpty)
            IconButton(
              tooltip: 'Bersihkan semua foto',
              onPressed: _clearPhotos,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderCard(photoCount: _photos.length),
                    const SizedBox(height: 18),
                    _PhotoPreview(
                      photo: _selectedPhoto,
                      isBusy: _isPickingImage,
                      onOpenPreview: _selectedPhoto == null
                          ? null
                          : () => _openPhotoPreview(_selectedPhoto!),
                      onDelete: _selectedPhoto == null
                          ? null
                          : _deleteSelectedPhoto,
                    ),
                    const SizedBox(height: 16),
                    _ActionButtons(
                      isBusy: _isPickingImage,
                      onTakePhoto: () => _pickImage(ImageSource.camera),
                      onPickGallery: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Text(
                          'Gallery hasil foto',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        Text(
                          '${_photos.length} foto',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _PhotoGallery(
                      photos: _photos,
                      selectedIndex: _selectedPhotoIndex,
                      onSelect: (index) {
                        setState(() {
                          _selectedPhotoIndex = index;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.photoCount});

  final int photoCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.photo_camera_back_outlined,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tangkap momen terbaik',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  photoCount == 0
                      ? 'Ambil foto baru atau pilih dari galeri.'
                      : 'Foto terbaru siap dilihat dan dikelola.',
                  style: TextStyle(color: colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.photo,
    required this.isBusy,
    required this.onOpenPreview,
    required this.onDelete,
  });

  final File? photo;
  final bool isBusy;
  final VoidCallback? onOpenPreview;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photo == null)
              _EmptyPreview(isBusy: isBusy)
            else
              InkWell(
                onTap: onOpenPreview,
                child: Image.file(photo!, fit: BoxFit.cover),
              ),
            if (photo != null)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Lihat foto',
                      onPressed: onOpenPreview,
                      icon: const Icon(Icons.open_in_full),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Hapus foto',
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.isBusy});

  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: isBusy
                  ? const Padding(
                      padding: EdgeInsets.all(22),
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 36,
                      color: colorScheme.primary,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              isBusy ? 'Membuka media...' : 'Belum ada foto',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Hasil foto akan langsung tampil di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isBusy,
    required this.onTakePhoto,
    required this.onPickGallery,
  });

  final bool isBusy;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickGallery;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isBusy ? null : onTakePhoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Ambil Foto'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isBusy ? null : onPickGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Pilih Galeri'),
          ),
        ),
      ],
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({
    required this.photos,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<File> photos;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (photos.isEmpty) {
      return Container(
        height: 104,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          'Gallery masih kosong',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 88,
              padding: EdgeInsets.all(isSelected ? 3 : 0),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.file(photos[index], fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}
