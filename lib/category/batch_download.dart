import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class BatchDownload extends StatefulWidget {
  const BatchDownload({super.key});

  @override
  State<BatchDownload> createState() => _BatchDownloadState();
}

class _BatchDownloadState extends State<BatchDownload> {
  List<String> urlList = [
    'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/Sample-MP4-Video-File-Download.mp4',
    'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/Sample-MP4-Video-File-Download.mp4',
    'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/Sample-MP4-Video-File-Download.mp4',
  ];
  List<DownloadTask> downloadTask = [];
  List<double> perList = [];

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
        child: Column(
          children: List.generate(
            perList.length,
            (index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: () async {
                              await pauseDownload(downloadTask[index]);
                            },
                            icon: const Icon(Icons.pause),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                            child: IconButton(
                                onPressed: () async {
                                  await resumeDownload(downloadTask[index]);
                                },
                                icon: const Icon(Icons.play_arrow))),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                            child: IconButton(
                                onPressed: () async {
                                  await cancelDownload(downloadTask[index],
                                      index: index);
                                },
                                icon: const Icon(Icons.close))),
                        const SizedBox(
                          width: 20,
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            batchDownload();
          },
          child: const Icon(Icons.download_for_offline)),
    );
  }

  assignDownloadTask() { 
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

    //Genreate progress list according to download task length
    perList = List.generate(
      downloadTask.length,
      (index) => index.toDouble(),
    );
  }

  batchDownload() async {
    downloadTask.clear();
    perList.clear();
    assignDownloadTask();

    //This will download all the give list of tasks at once
    await FileDownloader().downloadBatch(
      downloadTask,
      taskProgressCallback: (update) {
        for (int i = 0; i < downloadTask.length; i++) {
          if (downloadTask[i].taskId == update.task.taskId) {
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

  pauseDownload(task) async {
    await FileDownloader().pause(task);
  }

  cancelDownload(task, {index}) async {
    await FileDownloader().cancelTaskWithId(task.taskId).whenComplete(() {
      perList[index] = 0;
      downloadTask.removeAt(index);
      perList.removeAt(index);
      setState(() {});
    });
  }

  resumeDownload(task) async {
    await FileDownloader().resume(task);
  }
}
