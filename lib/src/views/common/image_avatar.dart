import 'package:flutter/material.dart';

class ImageAvatar extends StatelessWidget {
  final String? url;
  final double size;
  final BoxShape shape;
  final double borderRadiusValue;

  const ImageAvatar({
    super.key,
    this.url,
    this.size = 72,
    this.shape = BoxShape.rectangle,
    this.borderRadiusValue = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isCircle = shape == BoxShape.circle;
    // 圆形则不需要 borderRadius
    final borderRadius = isCircle ? null : BorderRadius.circular(borderRadiusValue);

    // 当 url 为空时显示占位
    if (url == null || url!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: isCircle
            ? BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle)
            : BoxDecoration(color: Colors.grey.shade200, borderRadius: borderRadius),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported),
      );
    }

    // 正常加载网络图片
    final image = Image.network(url!, width: size, height: size, fit: BoxFit.cover);

    // 根据形状裁剪
    return isCircle ? ClipOval(child: image) : ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
