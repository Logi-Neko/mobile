import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../dto/video.dart';

class EquationDisplay extends StatefulWidget {
  final VideoData videoData;

  const EquationDisplay({
    Key? key,
    required this.videoData,
  }) : super(key: key);

  @override
  State<EquationDisplay> createState() => _EquationDisplayState();
}

class _EquationDisplayState extends State<EquationDisplay> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(EquationDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoData.videoUrl != widget.videoData.videoUrl) {
      _disposeController();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.videoData.videoUrl.isNotEmpty) {
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
    if (_controller != null && _isInitialized) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  void _toggleControls() {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            if (widget.videoData.title.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Text(
                  widget.videoData.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            Expanded(
              child: _buildVideoContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (widget.videoData.videoUrl.isNotEmpty && _isInitialized && !_hasError) {
      return _buildVideoPlayer();
    }

    if (widget.videoData.videoUrl.isNotEmpty && _hasError) {
      return _buildThumbnailWithError();
    }

    if (widget.videoData.videoUrl.isNotEmpty && !_isInitialized && !_hasError) {
      return _buildLoadingVideo();
    }

    if (widget.videoData.thumbnailUrl.isNotEmpty) {
      return _buildThumbnailImage();
    }

    return _buildDefaultPlaceholder();
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: VideoPlayer(_controller!),
              ),
            ),

            if (_showControls) _buildVideoControls(),

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
                    size: 32,
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  _formatDuration(position.inSeconds),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Expanded(
                  child: Slider(
                    value: position.inMilliseconds.toDouble(),
                    max: duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      _controller!.seekTo(Duration(milliseconds: value.toInt()));
                    },
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withOpacity(0.3),
                  ),
                ),
                Text(
                  _formatDuration(duration.inSeconds),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLoadingVideo() {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.videoData.thumbnailUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: widget.videoData.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorWidget: (context, url, error) => Container(color: Colors.grey.shade800),
            ),

          Container(
            color: Colors.black.withOpacity(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Đang tải video...',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailWithError() {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.videoData.thumbnailUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: widget.videoData.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorWidget: (context, url, error) => _buildDefaultPlaceholder(),
            )
          else
            _buildDefaultPlaceholder(),

          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 32),
                SizedBox(height: 8),
                Text(
                  'Video không thể phát',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                    });
                    _initializeVideo();
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

  Widget _buildThumbnailImage() {
    return CachedNetworkImage(
      imageUrl: widget.videoData.thumbnailUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(
                'Đang tải...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildDefaultPlaceholder(),
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
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Video không khả dụng',
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