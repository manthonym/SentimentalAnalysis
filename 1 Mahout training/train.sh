#!/bin/bash

if [ "$1" = "--help" ] || [ "$1" = "--?" ]; then
  echo "This script runs SGD and Bayes classifiers over Tweets based on the classic 20 News Groups."
  exit
fi

SCRIPT_PATH=${0%/*}
if [ "$0" != "$SCRIPT_PATH" ] && [ "$SCRIPT_PATH" != "" ]; then
  cd $SCRIPT_PATH
fi
START_PATH=`pwd`

WORK_DIR=/tmp/mahout-work-apple-${USER}
algorithm=( cnaivebayes naivebayes sgd clean)
if [ -n "$1" ]; then
  choice=$1
else
  echo "Please select a number to choose the corresponding task to run"
  echo "1. ${algorithm[0]}"
  echo "2. ${algorithm[1]}"
  echo "3. ${algorithm[2]}"
  echo "4. ${algorithm[3]} -- cleans up the work area in $WORK_DIR"
  read -p "Enter your choice : " choice
fi

echo "ok. You chose $choice and we'll use ${algorithm[$choice-1]}"
alg=${algorithm[$choice-1]}

if [ "x$alg" != "xclean" ]; then
  echo "creating work directory at ${WORK_DIR}"

  mkdir -p ${WORK_DIR}
fi
#echo $START_PATH
cd $START_PATH
cd ../..

set -e

if [ "x$alg" == "xnaivebayes"  -o  "x$alg" == "xcnaivebayes" ]; then
  c=""

  if [ "x$alg" == "xcnaivebayes" ]; then
    c=" -c"
  fi

  set -x

  echo "Creating sequence files from Assignment data"
  /root/mahout_git/mahout/bin/mahout seqdirectory \
    -i ouputfolder_hdfs/mahout_data_apple \
    -o ${WORK_DIR}/assignment-seq -ow

  echo "Converting sequence files to vectors"
  /root/mahout_git/mahout/bin/mahout seq2sparse \
    -i ${WORK_DIR}/assignment-seq \
    -o ${WORK_DIR}/assignment-vectors  -lnorm -nv  -wt tfidf

  echo "Creating training and holdout set with a random 80-20 split of the generated vector dataset"
  /root/mahout_git/mahout/bin/mahout split \
    -i ${WORK_DIR}/assignment-vectors/tfidf-vectors \
    --trainingOutput ${WORK_DIR}/assignment-train-vectors \
    --testOutput ${WORK_DIR}/assignment-test-vectors  \
    --randomSelectionPct 40 --overwrite --sequenceFiles -xm sequential

  echo "Training Naive Bayes model"
  /root/mahout_git/mahout/bin/mahout trainnb \
    -i ${WORK_DIR}/assignment-train-vectors -el \
    -o ${WORK_DIR}/model \
    -li ${WORK_DIR}/labelindex \
    -ow $c

  echo "Self testing on training set"

  /root/mahout_git/mahout/bin/mahout testnb \
    -i ${WORK_DIR}/assignment-train-vectors\
    -m ${WORK_DIR}/model \
    -l ${WORK_DIR}/labelindex \
    -ow -o ${WORK_DIR}/assignment-testing $c

  echo "Testing on holdout set"

  /root/mahout_git/mahout/bin/mahout testnb \
    -i ${WORK_DIR}/assignment-test-vectors\
    -m ${WORK_DIR}/model \
    -l ${WORK_DIR}/labelindex \
    -ow -o ${WORK_DIR}/assignment-testing $c

elif [ "x$alg" == "xsgd" ]; then
  if [ ! -e "/tmp/news-group.model" ]; then
    echo "Training on ${WORK_DIR}/assignment-bydate/assignment-bydate-train/"
    /root/mahout_git/mahout/bin/mahout org.apache.mahout.classifier.sgd.TrainNewsGroups ${WORK_DIR}/assignment-bydate/assignment-bydate-train/
  fi
  echo "Testing on ${WORK_DIR}/assignment-bydate/assignment-bydate-test/ with model: /tmp/assignment.model"
  /root/mahout_git/mahout/bin/mahout org.apache.mahout.classifier.sgd.TestNewsGroups --input ${WORK_DIR}/assignment-bydate/assignment-bydate-test/ --model /tmp/assignment.model
elif [ "x$alg" == "xclean" ]; then
  echo "End"
fi
# Remove the work directory
#

echo "Copy new hdfs file to local filesystem"
hadoop fs -get ${WORK_DIR}/labelindex /root/mahout_analysis/labelindex
hadoop fs -get ${WORK_DIR}/model /root/mahout_analysis/model
hadoop fs -get ${WORK_DIR}/assignment-vectors/dictionary.file-0 /root/mahout_analysis/dictionary.file-0
hadoop fs -getmerge ${WORK_DIR}/assignment-vectors/df-count /root/mahout_analysis/df-count
