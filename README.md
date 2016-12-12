# ParallelGrayScale

## Introduction
Hardware and software advancements within the mobile computing space have enabled powerful applications to be built which can take advantage of the inherent parallelism available on the hardware. The purpose of this project is to explore and exploit the parallelization mechanisms of Apple’s Metal API and measure the potential performance boosts by developing a simple iOS application. Similarly, we developed a desktop version of this application using the CUDA framework to measure the performance boost compared to the Metal API. Apple’s Metal API is a low-level library that gives access to the GPU on mobile devices. CUDA is also a low-level library created by Nvidia designed to allow developers to access the GPU resource of graphics card on the desktop platform. They are generally used in the field of 3D graphics, games, and other graphic intensive applications. For our project, we developed a simple grayscale filter application to demonstrate how powerful these APIs can be when compared to CPU execution and the speedup they provide compared to each other.


## Problem statement				
The goal of the project is to explore the capabilities of Apple’s Metal API and measure the performance increase when this API is exploited versus when it is not. In addition, the performance of the Metal API will be compared to CUDA running on a NVIDIA graphics card.			
## Hypothesis
Our team predicted that the Metal API would provide significant speedup in the range of 15-20 times that of sequential execution and approx 7-10 times that of a parallel execution. This estimation is based off of lab 3 whereby we measured similar speedup numbers when using CUDA vs CPU execution on a laptop device. Likewise, we predict that the speedup of Metal on iOS vs CUDA on the linux server will be similar with CUDA providing a slightly faster speedup. This is due to the Nvidia card being more powerful than the GPU on an iOS device.


## Methodology	
To resolve the problem statement, the team developed five versions of a grayscale filtering application: three on iOS (sequential with CPU, parallel with CPU, Metal API with GPU), two on Linux (sequential with CPU, CUDA with GPU). All iOS versions of the filtering application were built with performance measurement so that differences in computational time can be measured and later plotted. For the iOS versions, the hardware platform being used for testing was the iPhone 6S Plus, running the latest iOS 10.1. For the desktop version, the platform was tested on a Linux machine running CentOS 6.8.


## Notes
1. In the mobile sequential and parallel versions, the helper class called “RGBAImage” was obtained from the [Coursera iOS course](https://www.coursera.org/specializations/app-development).
2. For the Metal version, we referred to [this tutorial](https://www.invasivecode.com/weblog/metal-image-processing) to set up the API.
