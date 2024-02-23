import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class BatchUpload extends StatefulWidget {
  const BatchUpload({super.key});

  @override
  State<BatchUpload> createState() => _BatchUploadState();
}

class _BatchUploadState extends State<BatchUpload> {
  List urlList = [
    'https://upload-image-and-return-url-by-thichthicodeteam.p.rapidapi.com/api/upload-image',
    'https://upload-image-and-return-url-by-thichthicodeteam.p.rapidapi.com/api/upload-image',
    'https://upload-image-and-return-url-by-thichthicodeteam.p.rapidapi.com/api/upload-image',
  ];
  List<UploadTask> uploadTask = [];
  List<double> perList = [];
  String path = '';

  @override
  void initState() {
    super.initState();
    pickFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Batch Download',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Wrap(
          direction: Axis.horizontal,
          children: List.generate(
            perList.length,
            (index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularPercentIndicator(
                      radius: 50.0,
                      animation: true,
                      animationDuration: 100,
                      lineWidth: 5.0,
                      percent: perList[index],
                      animateFromLastPercent: true,
                      center: Text(
                        "${(perList[index] * 100).toStringAsFixed(2)}%",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14.0),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: Colors.grey.shade300,
                      progressColor: Colors.green,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          onPressed: () async {
                            await cancelUpload(uploadTask[index], index: index);
                          },
                          icon: const Icon(Icons.close)))
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          uploadBatch();
        },
        child: const Icon(Icons.upload),
      ),
    );
  }

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        path = file.path;
      });
    } else {}
  }

  assignUploadTask() {
    for (var element in urlList) {
      UploadTask task = UploadTask(
        url: element,
        filename: path.toString().split('/').last,
        headers: {
          'Accept': '*/*',
          "content-type":
              "multipart/form-data; boundary=---011000010111000001101001",
          'content-Type': "multipart/form-data",
          'X-RapidAPI-Key':
              'c4dacdbc17msh870ca87b1de6fadp136c52jsn70bd723f4658',
          'X-RapidAPI-Host':
              'upload-image-and-return-url-by-thichthicodeteam.p.rapidapi.com',
        },
        httpRequestMethod: 'POST',
        updates: Updates.statusAndProgress,
        //Select Root Directory as it will return custom path
        baseDirectory: BaseDirectory.root,
        /* Provide custom path of your file e.g. File Picker will
          create /data/user/0/com.example.download_progress/cache/file_picker/.
          This path can be changed according to selected file so be careful */
        directory:
            '/data/user/0/com.example.download_progress/cache/file_picker/',
        fields: {
          'file': path.toString(),
        },
      );
      uploadTask.add(task);
    }

//Genreate progress list according to upload task length
    perList = List.generate(
      uploadTask.length,
      (index) => index.toDouble(),
    );
  }

  uploadBatch() async {
    uploadTask.clear();
    perList.clear();
    assignUploadTask();

    //This will upload all the give list of tasks at once
    await FileDownloader().uploadBatch(
      uploadTask,
      taskProgressCallback: (update) {
        for (int i = 0; i < uploadTask.length; i++) {
          if (uploadTask[i].taskId == update.task.taskId) {
            if (!update.progress.isNegative &&
                update.progress <= 1 &&
                update.progress >= 0) {
              perList[i] = update.progress;
              setState(() {});
            }
          }
        }
      },
    );
  }

  cancelUpload(task, {index}) async {
    await FileDownloader().cancelTaskWithId(task.taskId).whenComplete(() {
      perList[index] = 0;
      uploadTask.removeAt(index);
      perList.removeAt(index);
      setState(() {});
    });
  }
}
