import 'package:flutter/material.dart';
import '../../../core/services/repositories/media_api_repository.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_list.dart';
import 'widgets/add_media_sheet.dart';


class MediaFile {
  final String id;
  final String name;
  final String type; // image, video, document, audio
  final String size;
  final DateTime uploadedAt;

  const MediaFile({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.uploadedAt,
  });
}

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final _repo = MediaApiRepository();
  bool _isLoading = false;
  final List<MediaFile> _media = [];

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getMedia();
      if (list.isNotEmpty) {
        _media.clear();
        for (final m in list) {
          final mime = (m['mimeType'] ?? m['type'] ?? 'image').toString().toLowerCase();
          String t = 'document';
          if (mime.contains('image')) t = 'image';
          if (mime.contains('video')) t = 'video';
          if (mime.contains('audio')) t = 'audio';

          final sizeBytes = int.tryParse(m['size']?.toString() ?? '') ?? 0;
          final sizeStr = sizeBytes > 1048576
              ? '${(sizeBytes / 1048576).toStringAsFixed(1)} MB'
              : (sizeBytes > 1024 ? '${(sizeBytes / 1024).toStringAsFixed(0)} KB' : '$sizeBytes B');

          _media.add(MediaFile(
            id: m['id']?.toString() ?? '',
            name: m['name']?.toString() ?? 'Asset',
            type: t,
            size: sizeStr,
            uploadedAt: DateTime.tryParse(m['createdAt']?.toString() ?? '') ?? DateTime.now(),
          ));
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'image':
        return LucideIcons.image;
      case 'video':
        return LucideIcons.video;
      case 'audio':
        return LucideIcons.music;
      case 'document':
      default:
        return LucideIcons.fileText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Media Assets'),
      ),
      body: _isLoading
          ? Center(child: SkeletonList(count: 4, itemHeight: 80))
          : _media.isEmpty
              ? EmptyState(
                  icon: AppIcons.media,
                  title: 'No media uploaded',
                  message: 'Upload images, videos, audio and PDFs for campaign messaging and chatbot media cards',
                )

              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _media.length,
                  itemBuilder: (context, index) {
                    final item = _media[index];
                    return ScaleFadeIn.staggered(
                      index: index,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadii.border2xl,
                          border: Border.all(color: const Color(0x3322C55E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.g50,
                                      borderRadius: AppRadii.borderLg,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(_iconForType(item.type), size: 40, color: AppColors.g700),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () async {
                                        final ok = await ConfirmDialog.show(
                                          context: context,
                                          title: 'Delete Media',
                                          message: 'Are you sure you want to delete "${item.name}"?',
                                          confirmLabel: 'Delete',
                                        );
                                        if (ok == true) {
                                          try {
                                            await _repo.deleteMedia(item.id);
                                            ToastService.success('Media file deleted');
                                            _loadMedia();
                                          } catch (e) {
                                            ToastService.error('Failed to delete: $e');
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(color: Colors.black12, blurRadius: 4),
                                          ],
                                        ),
                                        child: const Icon(LucideIcons.trash2, size: 14, color: AppColors.statusRedText),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${item.size} • ${item.type.toUpperCase()}',
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.uploadCloud, size: 20),
          label: const Text('Upload Media', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            AddMediaSheet.show(
              context,
              onSave: (data) async {
                try {
                  await _repo.addMedia({
                    'name': data['name'],
                    'mimeType': data['mime_type'],
                    'size': data['size'] ?? 1024,
                    'url': data['url'] ?? 'https://storage.waba.com/media/${data['name']}',
                  });
                  ToastService.success('Media asset added successfully');
                  _loadMedia();
                } catch (e) {
                  ToastService.error('Failed to add media: $e');
                }
              },
            );
          },
        ),
      ),
    );
  }

}
