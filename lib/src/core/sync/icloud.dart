part of 'base.dart';

final class ICloud implements RemoteStorage<ICloudFile> {
  final String containerId;

  ICloud({required this.containerId});

  @override
  Future<void> upload({
    required String relativePath,
    String? localPath,
  }) async {
    final completer = Completer<void>();
    await ICloudStorage.upload(
      containerId: containerId,
      filePath: localPath ?? Paths.doc.joinPath(relativePath),
      destinationRelativePath: relativePath,
      onProgress: (stream) {
        stream.listen(
          null,
          onDone: () => completer.complete(null),
          onError: (Object e) => completer.completeError(e),
        );
      },
    );
    return completer.future;
  }

  @override
  Future<List<ICloudFile>> list() {
    return ICloudStorage.gather(containerId: containerId);
  }

  @override
  Future<void> delete(String relativePath) {
    return ICloudStorage.delete(
      containerId: containerId,
      relativePath: relativePath,
    );
  }

  @override
  Future<void> download({
    required String relativePath,
    String? localPath,
  }) async {
    final completer = Completer<void>();
    await ICloudStorage.download(
      containerId: containerId,
      relativePath: relativePath,
      destinationFilePath: localPath ?? Paths.doc.joinPath(relativePath),
      onProgress: (stream) {
        stream.listen(
          null,
          onDone: () => completer.complete(null),
          onError: (Object e) => completer.completeError(e),
        );
      },
    );
    return completer.future;
  }
}
