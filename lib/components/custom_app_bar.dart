import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSync;
  final VoidCallback? onDownload;
  final VoidCallback? onSearch;
  final bool showSyncButton;
  final bool showDownloadButton;
  final bool showSearchButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSync,
    this.onDownload,
    this.onSearch,
    this.showSyncButton = true,
    this.showDownloadButton = true,
    this.showSearchButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: const Color(0xFF8A124F),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (showSearchButton)
          IconButton(
            tooltip: 'Cari',
            icon: const Icon(Icons.search),
            onPressed: onSearch,
          ),

        if (showDownloadButton)
          IconButton(
            tooltip: 'Unduh Data',
            icon: const Icon(Icons.download),
            onPressed: onDownload,
            color: Colors.white,
          ),
      ],
    );
  }
}