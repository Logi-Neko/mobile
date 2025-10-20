import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../dto/video.dart';

class MediaDisplay extends StatefulWidget {
  final VideoData videoData;

  const MediaDisplay({
    Key? key,
    required this.videoData,
  }) : super(key: key);

  @override
  State<MediaDisplay> createState() => _MediaDisplayState();
}

class _MediaDisplayState extends State<MediaDisplay> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = false;
  bool _isImage = false;

  @override
  void initState() {
    super.initState();
    _checkMediaType();
    _initializeMedia();
  }

  @override
  void didUpdateWidget(MediaDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoData.videoUrl != widget.videoData.videoUrl) {
      _disposeController();
      _checkMediaType();
      _initializeMedia();
    }
  }

  void _checkMediaType() {
    final url = widget.videoData.videoUrl.toLowerCase();
    _isImage = url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png') ||
        url.endsWith('.gif') ||
        url.endsWith('.webp') ||
        url.contains('/image/') ||
        url.contains('image.');
  }

  Future<void> _initializeMedia() async {
    if (widget.videoData.videoUrl.isEmpty) return;

    if (_isImage) {
      // For images, just set initialized
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } else {
      // For videos, initialize video player
      try {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoData.videoUrl),
        );

        await _controller!.initialize();

        if (mounted) {
          setState(() {
            _isInitialized = true;
            _hasError = false;
          });
        }

        _controller!.addListener(() {
          if (mounted) {
            setState(() {});
          }
        });

      } catch (e) {
        print('Error initializing video: $e');
        if (mounted) {
          setState(() {
            _hasError = true;
            _isInitialized = false;
          });
        }
      }
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized && !_isImage) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  void _toggleControls() {
    if (!_isImage) {
      setState(() {
        _showControls = !_showControls;
      });

      if (_showControls) {
        Future.delayed(Duration(seconds: 3), () {
          if (mounted && _showControls) {
            setState(() {
              _showControls = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Expanded(
              child: _buildMediaContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (widget.videoData.videoUrl.isEmpty) {
      if (widget.videoData.thumbnailUrl.isNotEmpty) {
        return _buildImage(widget.videoData.thumbnailUrl);
      }
      return _buildDefaultPlaceholder();
    }

    // Handle errors
    if (_hasError) {
      return _buildMediaError();
    }

    // Loading state
    if (!_isInitialized) {
      return _buildLoadingMedia();
    }

    // Display image or video based on type
    if (_isImage) {
      return _buildImage(widget.videoData.videoUrl);
    } else {
      return _buildVideoPlayer();
    }
  }

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'Đang tải hình ảnh...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8),
            Text(
              'Không thể tải hình ảnh',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Force rebuild to retry loading
                });
              },
              child: Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio != 0
                    ? _controller!.value.aspectRatio
                    : 16 / 9,
                child: VideoPlayer(_controller!),
              ),
            ),

            // Controls overlay
            if (_showControls) _buildVideoControls(),

            // Play/pause button
            if (!_controller!.value.isPlaying || _showControls)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                  onPressed: _togglePlayPause,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    final position = _controller!.value.position;
    final duration = _controller!.value.duration;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            // Current time
            Text(
              _formatDuration(position.inSeconds),
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),

            // Progress slider
            Expanded(
              child: Slider(
                value: position.inMilliseconds.toDouble(),
                max: duration.inMilliseconds > 0
                    ? duration.inMilliseconds.toDouble()
                    : 1.0,
                onChanged: (value) {
                  _controller!.seekTo(Duration(milliseconds: value.toInt()));
                },
                activeColor: Colors.white,
                inactiveColor: Colors.white.withOpacity(0.3),
              ),
            ),

            // Total duration
            Text(
              _formatDuration(duration.inSeconds),
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMedia() {
    return Container(
      color: _isImage ? Colors.grey.shade200 : Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Show thumbnail while loading video
          if (!_isImage && widget.videoData.thumbnailUrl.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.videoData.thumbnailUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade800,
                ),
              ),
            ),

          // Loading indicator
          Container(
            color: _isImage ? null : Colors.black.withOpacity(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: _isImage ? null : Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  _isImage ? 'Đang tải hình ảnh...' : 'Đang tải video...',
                  style: TextStyle(
                    color: _isImage ? Colors.grey[700] : Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaError() {
    return Container(
      color: _isImage ? Colors.grey.shade200 : Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Show thumbnail if available
          if (widget.videoData.thumbnailUrl.isNotEmpty)
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: CachedNetworkImage(
                  imageUrl: widget.videoData.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),

          // Error message
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isImage ? Icons.broken_image : Icons.error_outline,
                  color: Colors.red,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  _isImage ? 'Hình ảnh không thể hiển thị' : 'Video không thể phát',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _isInitialized = false;
                    });
                    _initializeMedia();
                  },
                  child: Text('Thử lại'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Không có nội dung',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.videoData.videoQuestion.question.isNotEmpty) ...[
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.videoData.videoQuestion.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}