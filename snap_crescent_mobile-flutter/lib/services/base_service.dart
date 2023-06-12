import 'dart:io';

import 'package:dio/dio.dart';
import 'package:snap_crescent/repository/app_config_repository.dart';
import 'package:snap_crescent/utils/constants.dart';

class BaseService {
  Dio? _dio;

  Future<Dio> getDio() async {
    final baseURL = await AppConfigRepository.instance
        .findByKey(Constants.appConfigServerURL);

    if (_dio == null) {
      BaseOptions options = new BaseOptions(
          baseUrl: baseURL.configValue!,
          receiveDataWhenStatusError: true,
          connectTimeout: Duration(hours: 0, minutes: 1, seconds: 0),
          receiveTimeout: Duration(hours: 0, minutes: 5, seconds: 0));

      _dio = new Dio(options);
    } else {
      _dio!.options.baseUrl = baseURL.configValue!;
    }
    return Future.value(_dio);
  }

  Future<String> getServerUrl() async {
    final result = await AppConfigRepository.instance
        .findByKey(Constants.appConfigServerURL);
    return Future.value(result.configValue!);
  }

  Future<bool> isUserLoggedIn() async {
    final result = await AppConfigRepository.instance
        .findByKey(Constants.appConfigLoggedInFlag);
    return Future.value(result.configValue == "true" ? true : false);
  }

  Future<Options> getHeaders() async {
    return Options(
      headers: await getHeadersMap(),
    );
  }

  Future<Map<String, String>> getHeadersMap() async {
    Map<String, String> headers = {};

    final appConfigSessionTokenConfig = await AppConfigRepository.instance
        .findByKey(Constants.appConfigSessionToken);
    headers["Authorization"] =
        "Bearer " + appConfigSessionTokenConfig.configValue!;

    return headers;
  }

  String getQueryString(Map params,
      {String prefix = '&', bool inRecursion = false}) {
    String query = '';

    params.forEach((key, value) {
      if (inRecursion) {
        key = '[$key]';
      }

      if (value is String || value is int || value is double || value is bool) {
        if (query.length > 0) {
          query += '$prefix$key=$value';
        } else {
          query += '$key=$value';
        }
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query +=
              getQueryString({k: v}, prefix: '$prefix$key', inRecursion: true);
        });
      }
    });

    return query;
  }

  Future download(Dio dio, String url, String savePath) async {
    Options options = await getHeaders();
    options.responseType = ResponseType.bytes;
    options.followRedirects = false;
    options.validateStatus = (status) {
      return status! < 500;
    };

    options.responseType = ResponseType.bytes;

    try {
      Response response = await dio.get(
        url,
        //Received data with List<int>
        options: options,
      );
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  /// Downloading by spiting as file in chunks
  Future downloadWithChunks(
    Dio dio,
    url,
    savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {

    Options options = await getHeaders();

    const firstChunkSize = 1 * 1024 * 1024;
    const chunkSize = 50 * 1024 * 1024;
    const maxParallelChunk = 5;

    int total = 0;
    final progress = <int>[];

    void Function(int, int) createCallback(no) {
      return (int received, int _) {
        progress[no] = received;
        if (onReceiveProgress != null && total != 0) {
          onReceiveProgress(progress.reduce((a, b) => a + b), total);
        }
      };
    }

    Future<Response> downloadChunk(url, start, end, savePath, no) async {
      options.headers!["range"] = 'bytes=$start-$end';
      progress.add(0);
      --end;
      return dio.download(
        url,
        savePath + 'temp$no',
        onReceiveProgress: createCallback(no),
        options: options,
      );
    }

    Future processBatch(int batchIndex, var chunkBatch) async {
      final futures = <Future>[];
          
          int batchStart = 0;
          int batchEnd = chunkBatch.elementAt(batchIndex);

          if(batchIndex > 0) {
            batchStart = chunkBatch.elementAt(batchIndex - 1);
          }

          for (int i = batchStart; i < batchEnd; ++i) {
            final start = firstChunkSize + i * chunkSize;
            futures.add(downloadChunk(url, start, start + chunkSize, savePath, i + 1));
          }
          
          await Future.wait(futures);
    }

    Future mergeTempFiles(savePath, chunk) async {
      final f = File(savePath + 'temp0');
      final ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
      for (int i = 1; i <= chunk; ++i) {
        final file = File(savePath + 'temp$i');
        await ioSink.addStream(file.openRead());
        await file.delete();
      }
      await ioSink.close();
      await f.rename(savePath);
    }

    final response = await downloadChunk(url, 0, firstChunkSize, savePath, 0);
    if (response.statusCode == 206) {
      total = int.parse(
        response.headers.value(HttpHeaders.contentRangeHeader)!.split('/').last,
      );
      final reserved = total -
          int.parse(response.headers.value(Headers.contentLengthHeader)!);
      int totalChunks = (reserved / chunkSize).ceil();
      int chunk = totalChunks;
      var chunkBatch = <int>{};

      if (totalChunks > 1) {
        if (totalChunks > maxParallelChunk) {
          int numberOfBatches = (totalChunks / maxParallelChunk).floor();
          int lastBatchSize = totalChunks % maxParallelChunk;

          for (int i = 1; i <= numberOfBatches; i++) {
            chunkBatch.add(i * maxParallelChunk);
          }

          if (lastBatchSize > 0) {
            chunkBatch.add((numberOfBatches * maxParallelChunk) + lastBatchSize);
          }
        } else{
           chunkBatch.add(totalChunks);
        }

        for (int i = 0; i < chunkBatch.length; i++) {
          await processBatch(i, chunkBatch);
        }
      }
      await mergeTempFiles(savePath, chunk);
    }

    
  }
}
