import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class EnqueueDownload extends StatefulWidget {
  const EnqueueDownload({super.key});

  @override
  State<EnqueueDownload> createState() => _EnqueueDownloadState();
}

class _EnqueueDownloadState extends State<EnqueueDownload> {
  List<String> urlList = [
    'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/Sample-MP4-Video-File-Download.mp4',
    'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/Sample-MP4-Video-File-Download.mp4',
    'https://jsoncompare.org/LearningContainer/SampleFiles/Video/MP4/Sample-MP4-Video-File-Download.mp4',
  ];
  List<DownloadTask> downloadTask = [];

  List<double> perList = [];

  @override
  void initState() {
    super.initState();
    taskProgressListener();
  }

  @override
  void dispose() {
    FileDownloader().destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Queue Download',
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
            addDownloadsInQueue();
          },
          child: const Icon(Icons.download_for_offline)),
    );
  }

  taskProgressListener() {
    //This will listen the Updated of onGoing Downloading Tasks such as Progress, Status, File Size, Downloading Time
    FileDownloader().updates.listen((update) {
      switch (update) {
        case TaskStatusUpdate _:
          switch (update.status) {
            case TaskStatus.complete:
              print('Task ${update.task.taskId} success!');

            case TaskStatus.canceled:
              print('Download was canceled');

            case TaskStatus.paused:
              print('Download was paused');

            default:
              print('Download not successful');
          }

        case TaskProgressUpdate _:
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
      }
    });
  }

  assignDownloadTask() {
    for (var element in urlList) {
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

  addDownloadsInQueue() async {
    downloadTask.clear();
    perList.clear();

    assignDownloadTask();
    for (var task in downloadTask) {
      //This will add task in queue with different task IDs and then automatically start downloading
      //Enqueue can be used with upload tasks also.
      await FileDownloader().enqueue(task);
    }
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
