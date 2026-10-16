class MediaUrlResolver {
  MediaUrlResolver._();

  static String resolve(String? url, {String? localPreview}) {
    if (localPreview != null && localPreview.isNotEmpty) {
      return localPreview;
    }
    if (url == null || url.isEmpty) return '';
    if (url.contains('.ngrok-free.dev/uploads/')) {
      final filename = url.split('/uploads/').last;
      return 'http://10.0.2.2:4000/uploads/$filename';
    }
    if (url.contains('localhost:4000/uploads/')) {
      final filename = url.split('/uploads/').last;
      return 'http://10.0.2.2:4000/uploads/$filename';
    }
    return url;
  }
}
