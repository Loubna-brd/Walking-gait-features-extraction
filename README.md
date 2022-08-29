# Walking-gait-features-extraction

## Table of Content

- [Description](#sub-heading-1)

- [Stride Detection](#sub-heading-2)

- [Features Extraction](#sub-heading-3)

- [Demo with sample data](#sub-heading-4)

- [How to cite this work](#sub-heading-5)



## Description
The following repository presents work on the processing of raw accelerometer data from wearable sensors technologies. It was designed using the activPAL sensor from PAL Technologies Ltd. but can be adapted to other devices. The activPAL sensor is a triaxial accelerometer worn on the thigh. It will give you the tools to extract relevant gait features from labeled accelerometer data. Feature extraction is useful in many domains of gait analysis research such as activity classification or clinical gait characterization. This method was used to isolate walking events from running and other noises from data collected over 14 days. Heart rate data was also collected in this study, although it is possible to use the algorithms without heart rate data. 

## Stride Detection
The proprietary algorithm of the activPAL classifies the data into lying, sitting, standing, stepping, cycling, and driving. The first step of this algorithm is to extract all stepping periods (script: stepping_period.m). Then, we apply a stride detection algorithm (script: stride_detection.m) to each stepping period we isolated. We use a peak detection method to detect each stride. It is important to note that we use the smoothed z-axis acceleration in our application because the z-axis points anteriorly out of the thigh and presents the cleanest peaks. However, it might be different with a different sensor or different sensor location. 
Once the strides are detected, we isolate sections of consecutive strides. A section starts when a peak is detected and ends whenever the distance between two consecutive peaks is too large (which can be indicative of a pause in stepping or of an outlier in the stride detection algorithm). 
The figure below shows the filtered z-axis acceleration over time and peak detected with our method are shown with the red circles. The solid and dashed red lines depict respectively the beginning and the end of a section. 

## Features Extraction
We isolate windows of n strides from which we extract a set of features (script: features_extraction.m & acc_features_extraction.m). The features chosen have different natures, from the basic statistics (mean, standard deviation, etc.), to features specific to gait analysis (stride time, stride frequency, etc.). Some features are normalized using the leg length of participants, measured from the anterior superior iliac spine to the floor, without shoes. A list of the features and their meanings (when applicable) can be found in the file xxx.xxx. 

## Demo with sample data
We conducted a demo of the above framework using sample data provided in the folder "sample data". We show here how the features extraction can be used to visualize the data using principal component analysis (PCA). 
From the raw data, we extracted all activities labelled as stepping using the stepping_period algorithm. Then, we used the smoothed z-axis acceleration to apply our stride detection algorithm as shown in the sub-figure "stride detection". The strides are depicted with red dots. Sections of consecutive strides are delineated in the same sub-figure using solid and dashed red lines as the beginning and end of a section respectively. We isolated windows of 5 consecutive strides from which we extracted our features. A PCA was then applied to visualize the data, with each dot representing our windows of 5 strides. We sampled points from different regions of the PCA to examine the different types of data present. 

<img width="1395" alt="Screen Shot 2021-05-05 at 10 31 43" src="https://user-images.githubusercontent.com/28069281/117158236-3d937500-ad8d-11eb-9397-f821bb5883b9.png">

## How to cite this work

If you wish to use this code in your research, kindly acknowledge the authors and the following publication: [Baroudi, L., Yan, X., Newman, M. W., Barton, K., Cain, S. M., & Shorter, K. A. (2022). Investigating walking speed variability of young adults in the real world. Gait & Posture](https://www.sciencedirect.com/user/identity/landing?code=voLNbje-jxVOAzBMIexPoCJ8OcwBQy7GFeJ7t2gq&state=retryCounter%3D0%26csrfToken%3D60628a37-b699-4ff0-a1bf-88d90b94959d%26idpPolicy%3Durn%253Acom%253Aelsevier%253Aidp%253Apolicy%253Aproduct%253Ainst_assoc%26returnUrl%3D%252Fscience%252Farticle%252Fpii%252FS0966636222004775%26prompt%3Dnone%26cid%3Darp-c5b8e6fd-89b5-46de-b557-1ebc8cc6ad50). 
