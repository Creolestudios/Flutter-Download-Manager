
# Download and Upload files with Background_Downloader

  
## Overview
This is an example project to demonstrate and simplified Downloading and Uploading tasks with ease with the help of [background_downloader](https://pub.dev/packages/background_downloader) package.

  

## Contents

- Single file download/upload.

- Queue download

- Batch download/upload

- pause, resume and cancel download


## Getting Started

##### Add [background_downloader](https://pub.dev/packages/background_downloader) package to your `pubspec.yaml` file.

```yaml
dependencies:
  flutter:
    sdk: flutter
  background_downloader: ^8.0.0
```

Import package to your file

```dart
import  'package:background_downloader/background_downloader.dart';
```

#### 1) Single file download

```dart
DownloadTask task = DownloadTask(
          url:
              "https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/Sample-MP4-Video-File-Download.mp4",
          filename: "sampleVideo",
          directory: 'my_sub_directory',
          updates: Updates.statusAndProgress,
          requiresWiFi: true,
          retries: 5,
          allowPause: true,
          metaData: 'data for me');

      await FileDownloader().download(
        task,
        onProgress: (value) {
          if (!value.isNegative) {
            progressPer = value;
            setState(() {});
          }
        },
        onStatus: (status) {
          print(status);
        },
      );
```

#### 2) Single file upload

```dart
task = UploadTask(
        url: YOUR_UPLOAD_URL,
        //'fileName' Field can create trouble if it is not same as the picked file's name.
        //So be careful to assign fileName. It must be a picked file's name with file extension.
        filename: path.toString().split('/').last,

        headers: {
            //Add any required headers 
          'Accept': '*/*',
          "content-type":
              "multipart/form-data; boundary=---011000010111000001101001",
          'content-Type': "multipart/form-data",
        },

        // Specify http method i.e. POST, GET etc.
        httpRequestMethod: 'POST',
        updates: Updates.statusAndProgress,

        //Select Root Directory as it will return custom path
        baseDirectory: BaseDirectory.root,
        /* Provide custom path of your file e.g. File Picker will
          create /data/user/0/com.example.download_progress/cache/file_picker/.
          This path can be changed according to selected file so be careful */

        directory:
            '/data/user/0/com.example.download_progress/cache/file_picker/',

        //Assign your picked file path here.
        fields: {
          'file': path.toString(),
        },
      );

      //Perform Upload Task
      await FileDownloader().upload(task, onProgress: (value) {
        setState(() {
          if (!value.isNegative) {
            progressPer = value;
          }
        });
      }).then((value) => print(value.responseBody));
```
  
### 3) Queue download

```dart
//Create download task
DownloadTask task = DownloadTask(
          url: element,
          filename: "sampleVideo",
          directory: 'my_sub_directory',
          updates: Updates.progress,
          requiresWiFi: true,
          retries: 5,
          allowPause: true,
          metaData: 'data for me');

//Assign this task to enqueue. and it will automatically starts download.
await FileDownloader().enqueue(task);
```

### 4) Batch download

```dart
   for (var element in urlList) { 
      //Create download tasks for each download items
      DownloadTask task = DownloadTask(
          url: element,
          filename: "sampleVideo",
          directory: 'my_sub_directory',
          updates: Updates.progress,
          requiresWiFi: true,
          retries: 5,
          allowPause: true,
          metaData: 'data for me');
      downloadTask.add(task);
    }

// Assign Download Task list to downloadBatch method and it will start downloading all the files.
    await FileDownloader().downloadBatch(downloadTask);
```

### 5) Batch upload

```dart
 for (var element in pathList) {
      UploadTask task = UploadTask(
        url: YOUR_UPLOAD_URL,
        //'fileName' Field can create trouble if it is not same as the picked file's name.
        //So be careful to assign fileName. It must be a picked file's name with file extension.
        filename: element.toString().split('/').last,

        headers: {
            //Add any required headers 
          'Accept': '*/*',
          "content-type":
              "multipart/form-data; boundary=---011000010111000001101001",
          'content-Type': "multipart/form-data",
        },

        // Specify http method i.e. POST, GET etc.
        httpRequestMethod: 'POST',
        updates: Updates.statusAndProgress,

        //Select Root Directory as it will return custom path
        baseDirectory: BaseDirectory.root,

        /* Provide custom path of your file e.g. File Picker will
          create /data/user/0/com.example.download_progress/cache/file_picker/.
          This path can be changed according to selected file so be careful */
        directory:
            '/data/user/0/com.example.download_progress/cache/file_picker/',

        //Assign your picked file path here.
        fields: {
          'file': path.toString(),
        },
      );
      uploadTaskList.add(task);
    }

// Assign UploadTask List to uploadBatch method.
 await FileDownloader().uploadBatch(uploadTask);
 ```

 ### 6) Pause, Resume and Cancel download/upload

 ##### Pause
 ```dart
 await FileDownloader().pause(task);
 ```

##### Resume
 ```dart
 await FileDownloader().presumeause(task);
 ```

##### Cancel
 ```dart
 await FileDownloader().cancelTaskWithId(task.taskId).
 ```

#### These are the main things you can do with this package. But there are also other cool things to check out, like getting notifications, keeping track of downloads in a local database, and easily opening downloaded files etc.


## Authors

- [@NirmalsinhRathod](https://github.com/NirmalsinhRathod)

![Logo](https://cdn-ggkmd.nitrocdn.com/BzULJouLEmmtjCpJwHCmTIgakvECFbms/assets/images/optimized/rev-f1e70e0/www.creolestudios.com/wp-content/uploads/2021/07/cs-logo.svg)
