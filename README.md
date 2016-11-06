# 16623-facial-landmark(Siliang Lu & Ningyan Zhu)
- Summary
      - Our project aims to achieve a facial landmark Computer Vision Application for iOS Mobile Devices. We also want to speed up the performance by applying parallel computing methods.
      - Our project aims to design a fast facial landmark/ face alignment application in iOS devices. The application will use learning-based approach. We will use Accelerate Framework to make use of SIMD operations and might use Metal API to get access to the GPU. 
- Background

Based on the paper named Face Alignment at 3000 FPS via Regressing Local Binary Features,
In addition, the paper itself proposed a new approach which regularizes learning with a “locality” principle. In detail, since the local binary features are tree based and highly sparse, the process of extracting and regressing such features are extremely rapid[1,2]. It is reported in the paper that the proposed face alignment system can achieve 300 fps on a mobile phone for locating a few dozens of landmarks. 
According to the proposed regularizations in the paper, since each local feature mapping function is independent, we can make the use of SIMD operations of Accelerate Framework. In addition, Metal provides the lowest-overhead access to the GPU, enabling us to maximize the graphics and compute potential of your apps on iOS[3]. Hence, we will use these two frameworks to maximize the speedup as much as possible.
Besides this approach, an efficient facial landmark open source named OpenFace [4] has been successfully implemented into many projects. CLM learns a set of local experts and constrains them using shape models. Similarly, once we develop the basic version of facial landmark tracking, we will speed up the application using Accelerate Framework and Metal API. 

