#!/bin/bash
#
wget --recursive --mirror -np -A.html  -Q100m -P ouputfolder/raw_data/computer http://www.apple.com
wget --recursive --mirror -np -A.html  -Q100m -P ouputfolder/raw_data/computer http://www.cnet.com

wget --recursive --mirror -np -A.html  -Q100m -P ouputfolder/raw_data/food http://en.wikipedia.org/wiki/Apple
wget --recursive --mirror -np -A.html  -Q100m -P ouputfolder/raw_data/food http://www.pickyourown.org/apples.htm
wget --recursive --mirror -np -A.html  -Q100m -P ouputfolder/raw_data/food http://www.orangepippin.com/apples
wget --recursive --mirror -np -A.html  -Q100m -P ouputfolder/raw_data/food http://southernfood.about.com/cs/apples/a/apple_recipes.htm
wget --recursive --mirror -np -A.html  -Q100m -P ouputfolder/raw_data/food http://www.bbc.co.uk/food/apple

hadoop fs -put ouputfolder/raw_data/food_single ouputfolder_hdfs/mahout_food_files
hadoop fs -put ouputfolder/raw_data/computer_single ouputfolder_hdfs/mahout_computer_files

hadoop jar ./DataLoader/target/DataLoader-0.0.1-jar-with-dependencies.jar ouputfolder_hdfs/mahout_food_files ouputfolder_hdfs/mahout_data_apple/food
hadoop jar ./DataLoader/target/DataLoader-0.0.1-jar-with-dependencies.jar ouputfolder_hdfs/mahout_computer_files ouputfolder_hdfs/mahout_data_apple/computer

