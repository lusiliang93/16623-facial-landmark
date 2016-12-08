# 16623-facial-landmark(Siliang Lu & Ningyan Zhu)
- Summary
      - Our project aims to design a real-time facial landmark/ face alignment application in iOS devices. The application will use the open source of dlib. We will use multithreading to parallelize in order to speed up.
- Background

  Facial landmark is an application of facial analysis in computer vision. It involves locating the face in an image and marking the accurate position of different facial features. It is also referred to as “face alignment” or “facial keypoint detection”. It has many interesting and potential applications such as face morphing, head pose estimation and virtual makeover.
  
  Based on the paper named Face Alignment at 3000 FPS via Regressing Local Binary Features, the paper itself proposed a new approach which regularizes learning with a “locality” principle. In detail, since the local binary features are tree based and highly sparse, the process of extracting and regressing such features are extremely rapid[1,2]. It is reported in the paper that the proposed face alignment system can achieve 300 fps on a mobile phone for locating a few dozens of landmarks. 
  
  In addition, according to the proposed regularizations in the paper, since each local feature mapping function is independent, we can make the use of SIMD operations of Accelerate Framework. In addition, Metal provides the lowest-overhead access to the GPU, enabling us to maximize the graphics and compute potential of your apps on iOS[3]. Hence, we will use these two frameworks to maximize the speedup as much as possible.
  
  Besides this approach, an efficient facial landmark open source named OpenFace [4] has been successfully implemented into many projects.OpenFace is an open source facial behavior analysis toolkit, which is able to perform a number of facial analysis tasks like facial landmark detection and head pose tracking. Its facial landmark tracking is based on constrained local neural fields（CLNF）method[5],which is a novel landmark detection model based on constrained local model(CLM). CLM learns a set of local experts and constrains them using shape models. Similarly, once we develop the basic version of facial landmark tracking, we will speed up the application using Accelerate Framework and Metal API. 
  
  After looking for the opensource, we've found a swift version of facial landmark tracking (thanks to zweigraf[8]) which is based on dlib.The facial landmark model used in dlib is based on the paper named "One Millisecond Face Alignment with an Ensemble of Regression Trees"[7]. This paper utilized a cascade of tree-like regressors to estimate the face’s landmark positions.
  
- Challenges

  So far, we have found at least two open sources to do face alignment. The one is C++ version of the paper, the other is the matlab version of CLM using dlib and OpenCV. Hence, the challenges can be described as follows:
   - Understanding the codes and check if it is feasible to use these open sources to develop an Xcode project;
   - How to modify the original codes so as to be more robust and have better performance(accuracy and speed);
   - Learn how to use Metal API so as to check if it is feasible to use Metal to get access to the GPU to realize the speedup;
   - Try to realize other functions such as pose estimation depending on the basic version;
   - How to build dlib on iOS;

- Goals and Deliverables
  - Goals:
     - We must successfully develop a facial landmark iOS app
     - We have to speed up the basic version at least 5 times using Accelerate Framework and GPUImage
  - Extra goals:
     - We would try to learn Metal API and get much faster version 
     - We would add additional function like head pose estimation
  - Evaluations:
     - The successful version is that it can realize facial landmark tracking in real time.
     - We will do speed benchmark by comparing execution time running the basic version, the version using Accelerate Frame and the version using Metal API.
     - We will make a demo to show how to use the app.
  - Feasibility:
     - A similar project has been done before in this course. Therefore, if we can follow the schedule strictly, we can complete the project on time.
     - We have found at least two open sources and each of them has a detailed paper to read. As long as we can understand, it can be finished on time.
     
- Schedule:
 - Nov.7 - Nov.13  Literature review and find facial landmark open sources(Completed) 
 - Nov.14 - Nov.16 Basic version of facial landmark in Xcode (Completed. We've found a swift version)
 - Nov.17 - Nov.20 Study the basic code and be familiar with the face landmarking model in dlib library. In addition, learn how to build Dlib in iOS if we want to change something in Dlib. (Completed. We've figured out how to rebuild dlib and link it with Xcode)
 - Nov.21 - Nov.23 Measure fps and develop an accelerated version by optimizing the dlibwrapper.mm. (Completed.We've used CoreAnimation in Profile and use attributes of AVCaptureDevice object to maximize the frame rate)
 - Nov.24 - Dec.27 Try to improve the performance of the output. For instance, when testers rotate the camera within a certain degree range, the face can still be tracked well with multiple landmarks. (Part Completed.)
 - Nov.28 - Dec.1 Add additional function like real-time head tracking by incorporating Smerk into the project. (Completed. Instead of Smerk, we've used functions in the class of AVMetadataface object)
 - Dec.2 - Dec.4 Create a simple UI. Benchmark speedup. (Half Completed. We've finished speed benchmark. But we do not have UI)
 - Dec.5 - Dec.7 Make a demo and prepare for the presentation (Completed)
 - Dec.8 - Dec. 11 Write final report

- References:

  [1] Ren, Shaoqing, Xudong Cao, Yichen Wei, and Jian Sun. "Face alignment at 3000 fps via regressing local binary features." In Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition, pp. 1685-1692. 2014.
  
  [2] https://github.com/yulequan/face-alignment-in-3000fps
  
  [3] https://developer.apple.com/metal/ 
  
  [4] https://github.com/TadasBaltrusaitis/OpenFace.git

  [5] “Constrained Local Neural Fields for robust facial landmark detection in the wild” Tadas Baltrušaitis, Peter Robinson, and Louis-Philippe Morency. in IEEE Int. Conference on Computer Vision Workshops, 300 Faces in-the-Wild Challenge, 2013.
  
  [6] https://github.com/luoyetx/deep-landmark
  
  [7] Kazemi, Vahid, and Josephine Sullivan. "One millisecond face alignment with an ensemble of regression trees." In Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition, pp. 1867-1874. 2014.
  
  [8] https://github.com/zweigraf/face-landmarking-ios

