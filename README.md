# Walking-gait-features-extraction

## Table of Content

- [Description](#sub-heading)

- [Stride Detection](#sub-heading-2)

- [Features Extraction](#sub-heading-3)

- [Demo with sample data](#sub-heading-4)

- [How to cite this work](#sub-heading-5)

- [How to contribute](#sub-heading-6)


### Description
The following repository presents work on the processing of raw accelerometer data from wearable sensors technologies. It was designed using the activPAL sensor from PAL Technologies Ltd. but can be adapted to other devices. The activPAL sensor is a triaxial accelerometer worn on the thigh. It will give you the tools to extract relevant gait features from labeled accelerometer data. Feature extraction is useful in many domains of gait analysis research such as activity classification or clinical gait characterization. This method was used to isolate walking events from running and other noises from data collected over 14 days. Heart rate data was also collected in this study, although it is possible to use the algorithms without heart rate data. 

## Stride Detection
The proprietary algorithm of the activPAL classifies the data into lying, sitting, standing, stepping, cycling, and driving. The first step of this algorithm is to extract all stepping periods (script: stepping_period.m). Then, we apply a stride detection algorithm (script: stride_detection.m) to each stepping period we isolated. We use a peak detection method to detect each stride. It is important to note that we use the filtered z-axis acceleration in our application because the z-axis points anteriorly out of the thigh and presents the cleanest peaks. However, it might be different with a different sensor or different sensor location. 
Once the strides are detected, we isolate sections of consecutive strides. A section starts when a peak is detected and ends whenever the distance between two consecutive peaks is too large (which can be indicative of a pause in stepping or of an outlier in the stride detection algorithm). 
The figure below shows the filtered z-axis acceleration over time and peak detected with our method are shown with the red circles. The solid and dashed red lines depict respectively the beginning and the end of a section. 

![image](https://user-images.githubusercontent.com/28069281/116933624-c85f5d00-ac31-11eb-9c49-f3f7f7562a27.png)

## Features Extraction
We isolate windows of n strides from which we extract a set of features (script: features_extraction.m & acc_features_extraction.m). The features chosen have different natures, from the basic statistics (mean, standard deviation, etc.), to features specific to gait analysis (stride time, stride frequency, etc.). Some features are normalized using the leg length of participants, measured from the anterior superior iliac spine to the floor, without shoes. A list of the features and their meanings (when applicable) can be found in the file xxx.xxx. 

## Demo with sample data
We conducted a demo of the above framework using sample data provided in the folder "sample data". We show here how the features extraction can be used to visualize the data using PCA. 

## How to cite this work

## How to contribute
