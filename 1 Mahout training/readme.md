Mahout training part
====================

Introduction
------------

This part is useful for training Mahout before doing any tweets analytics.
Indeed, tweets can cover unwanted topics.

In this project, we will use the #edf hashtag for which we need to separate tweets of Apple company from tweets talking about the fruit.

We will use Mahout classification to distinguish tweets, the first step is to make categories that will train Mahout.

Thus we will:
1. Get some data of EDF by getting .html files
2. Clean these files by removing tags and use a Lucene Analysis to remove stopwords (unessary words).
3. Put them into HDFS
4. Run the Mahout training based on the two categories: computer and food.

Run `prepare.sh` first to accomply task 1 to 3, and `train.sh` for task 4.


Copyright
---------
Benoit JARLIER, Guillaume MAMESSIER, Anthony MAROIS.
