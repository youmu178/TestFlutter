import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:habit/habit.dart';
import 'package:vibration/vibration.dart';

class PicModel {
  String? url;
  int? sort;

  PicModel({this.url, this.sort});
}

final testPicList = [
  "https://gips2.baidu.com/it/u=1651586290,17201034&fm=3028&app=3028&f=JPEG&fmt=auto&q=100&size=f600_800",
  "http://gips3.baidu.com/it/u=1022347589,1106887837&fm=3028&app=3028&f=JPEG&fmt=auto?w=960&h=1280",
  "http://gips2.baidu.com/it/u=3093819921,829322739&fm=3028&app=3028&f=JPEG&fmt=auto?w=1024&h=1024",
  "http://gips2.baidu.com/it/u=2161708353,627709820&fm=3028&app=3028&f=JPEG&fmt=auto?w=2560&h=1920",
  "http://gips1.baidu.com/it/u=1025173963,4205445645&fm=3028&app=3028&f=JPEG&fmt=auto?w=3200&h=3200",
  "http://gips2.baidu.com/it/u=4231193786,3187314859&fm=3028&app=3028&f=JPEG&fmt=auto?w=1024&h=1024",
  "http://gips3.baidu.com/it/u=3886271102,3123389489&fm=3028&app=3028&f=JPEG&fmt=auto?w=1280&h=960",
  "http://gips3.baidu.com/it/u=3419425165,837936650&fm=3028&app=3028&f=JPEG&fmt=auto?w=1024&h=1024",
  "http://gips2.baidu.com/it/u=3944689179,983354166&fm=3028&app=3028&f=JPEG&fmt=auto?w=1024&h=1024",
  "http://gips2.baidu.com/it/u=3579059838,1031544773&fm=3028&app=3028&f=JPEG&fmt=auto?w=1280&h=720",
  "http://gips3.baidu.com/it/u=3476243082,1256047914&fm=3028&app=3028&f=JPEG&fmt=auto?w=2048&h=2048",
];

class DragExamplePage extends StatefulWidget {
  const DragExamplePage({super.key});

  @override
  State<DragExamplePage> createState() => _DragExamplePageState();
}

class _DragExamplePageState extends State<DragExamplePage> {
  final _itemSize = (ScreenUtil().screenWidth - 59) / 4;

  /// 文件列表
  ValueNotifier<List<PicModel>> fileList = ValueNotifier([]);
  List<PicModel> picList = [];
  ValueNotifier<bool> updateItemsNotifier = ValueNotifier(false);

  updateItems() {
    updateItemsNotifier.value = !updateItemsNotifier.value;
  }

  /// 是否正在拖拽
  ValueNotifier<bool> isDraggingNotifier = ValueNotifier(false);

  bool get isDragging => isDraggingNotifier.value;

  set isDragging(bool value) {
    isDraggingNotifier.value = value;
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < testPicList.length; i++) {
      picList.add(PicModel(url: testPicList[i], sort: i));
    }
    fileList.value = picList;
  }

  /// 当前拖拽的源索引
  int? _dragSourceIndex;

  /// 当前拖拽的目标索引
  int? _dragTargetIndex;

  PicModel? draggingItem;

  /// 更新拖拽源
  void updateDragSource(PicModel sourceItem) {
    _dragSourceIndex = fileList.value.indexOf(sourceItem);
    _dragTargetIndex = null;
    updateItems();
  }

  /// 更新拖拽目标
  void updateDragTarget(PicModel targetItem) {
    final newTargetIndex = fileList.value.indexOf(targetItem);
    if (_dragTargetIndex != newTargetIndex && draggingItem != null) {
      _dragTargetIndex = newTargetIndex;

      // 实时重排序
      final items = List<PicModel>.from(fileList.value);
      final sourceIndex = items.indexOf(draggingItem!);
      if (sourceIndex != -1 && sourceIndex != _dragTargetIndex) {
        // 移除源位置的item
        items.removeAt(sourceIndex);
        // 插入到目标位置
        items.insert(_dragTargetIndex!, draggingItem!);

        // 更新所有项目的排序值
        for (int i = 0; i < items.length; i++) {
          items[i].sort = i;
        }

        fileList.value = items;
      }
      updateItems();
    }
  }

  /// 清除拖拽状态
  void clearDragStates() {
    draggingItem = null;
    _dragSourceIndex = null;
    _dragTargetIndex = null;
    updateItems();
  }

  /// 判断某个位置的透明度
  double getItemOpacity(int index) {
    if (_dragTargetIndex != null && index == _dragTargetIndex) {
      // 如果是目标位置，显示半透明
      return 0.4;
    } else if (_dragTargetIndex == null && index == _dragSourceIndex) {
      // 如果是源位置且还没有目标位置，显示半透明
      return 0.4;
    }
    // 其他情况显示正常
    return 1.0;
  }

  void onDragStart(PicModel item) {
    Vibration.vibrate(duration: 100);
    draggingItem = item;
    updateDragSource(item);
    isDragging = true;
  }

  void onDragEnd() {
    clearDragStates();
    isDragging = false;
  }

  void onDragOver(PicModel item) {
    updateDragTarget(item);
  }

  void onDragLeave() {
    _dragTargetIndex = null;
    updateItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag Example'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildGridView(),
          )
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return ValueListenableBuilder(
      valueListenable: fileList,
      builder: (BuildContext context, List<PicModel> files, Widget? child) {
        if (files.isEmpty) return const SizedBox();
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const ClampingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 9,
            mainAxisSpacing: 9,
            childAspectRatio: 1,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final item = files[index];
            return DragTarget<PicModel>(
              onWillAccept: (data) {
                final accept = data != null;
                if (accept) {
                  onDragOver(item);
                }
                return accept;
              },
              onAccept: (data) {
                // 调用排序方法
              },
              onLeave: (data) {
                onDragLeave();
              },
              builder: (context, candidateData, rejectedData) {
                return LongPressDraggable(
                  data: item,
                  maxSimultaneousDrags: 1,
                  feedback: _buildItem(item, size: 5),
                  onDragStarted: () {
                    onDragStart(item);
                  },
                  onDragEnd: (details) {
                    onDragEnd();
                  },
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: _buildItem(item),
                  ),
                  child: ValueListenableBuilder(
                      valueListenable: updateItemsNotifier,
                      builder: (BuildContext context, value, Widget? child) {
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: getItemOpacity(index),
                          child: _buildItem(item),
                        );
                      }),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildItem(PicModel item, {double? size}) {
    return Container(
      width: _itemSize + (size ?? 0),
      height: _itemSize + (size ?? 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExtendedImage.network(
        item.url ?? '',
        fit: BoxFit.cover,
        loadStateChanged: (ExtendedImageState value) {
          switch (value.extendedImageLoadState) {
            case LoadState.loading:
              return Container(
                alignment: Alignment.center,
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(),
              );
            case LoadState.failed:
              return Container(
                alignment: Alignment.center,
                child: const Icon(Icons.error, size: 30),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
