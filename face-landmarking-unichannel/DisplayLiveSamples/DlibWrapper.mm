//
//  DlibWrapper.m
//  DisplayLiveSamples
//
//  Created by Luis Reisewitz on 16.05.16.
//  Copyright © 2016 ZweiGraf. All rights reserved.
//

#import "DlibWrapper.h"
#import <UIKit/UIKit.h>

#include <dlib/image_processing.h>
#include <dlib/image_io.h>

@interface DlibWrapper ()

@property (assign) BOOL prepared;

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects;

@end
@implementation DlibWrapper {
    dlib::shape_predictor sp;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _prepared = NO;
    }
    return self;
}

- (void)prepare {
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    //NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"sp" ofType:@"dat"];
    std::string modelFileNameCString = [modelFileName UTF8String];
    //printf("string:%s\n",modelFileNameCString.c_str());
    
    dlib::deserialize(modelFileNameCString) >> sp;
    
    // FIXME: test this stuff for memory leaks (cpp object destruction)
    self.prepared = YES;
}

//Can we do without buffer??
- (void)doWorkOnSampleBuffer:(CMSampleBufferRef)sampleBuffer inRects:(NSArray<NSValue *> *)rects {
    
    if (!self.prepared) {
        [self prepare];
    }
    
    //dlib::array2d<dlib::bgr_pixel> img;
    dlib::array2d<unsigned char> img;
    
    // MARK: magic
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    char *baseBuffer = (char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    // set_size expects rows, cols format
    img.set_size(height, width);
    
    // copy samplebuffer image data into dlib image format
    img.reset();
    int position = 0;
    //multithread
    while (img.move_next()) {
        //if(img.move_next()){
        //dlib::bgr_pixel& pixel = img.element();
        unsigned char& pixel = img.element();
        
        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        //char b = baseBuffer[bufferLocation];
        char g = baseBuffer[bufferLocation + 1];
        //char r = baseBuffer[bufferLocation + 2];

        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        //dlib::bgr_pixel newpixel(b, g, r);
        //pixel = newpixel;
        pixel=g;
        
        position++;
        //}
    }
    
    // unlock buffer again until we need it again
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    // convert the face bounds list to dlib format
    std::vector<dlib::rectangle> convertedRectangles = [DlibWrapper convertCGRectValueArray:rects];
    
    // for every detected face
    for (unsigned int j = 0; j < convertedRectangles.size(); ++j)
    {
        dlib::rectangle oneFaceRect = convertedRectangles[j];
        
        //draw the detected face with rectangle
        draw_rectangle(img,oneFaceRect,dlib::rgb_pixel(255,0,255));
        
        // detect all landmarks
        dlib::full_object_detection shape = sp(img, oneFaceRect);
        
        // and draw them into the image (samplebuffer)
        for (unsigned int k = 0; k < shape.num_parts(); k++) {
            dlib::point p = shape.part(k);
            draw_solid_circle(img, p, 3, dlib::rgb_pixel(0, 255, 255));
            dlib::point p_ = dlib::vector<float,2>((shape.part(37).x()+shape.part(40).x())/2,
                                                    (shape.part(37).y()+shape.part(40).y())/2);
            
            // simple emotion detection based on the points coordinates
            if(((shape.part(48).y()+shape.part(54).y())/2 - shape.part(66).y()<-2)){
                draw_solid_circle(img, p_, 3, dlib::rgb_pixel(255, 0, 255));
            }
            else{
                draw_solid_circle(img, p_, 3, dlib::rgb_pixel(0, 255, 255));
            }
        }
        
        
    }
    
    // lets put everything back where it belongs
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // copy dlib image data back into samplebuffer
    img.reset();
    position = 0;
    while (img.move_next()) {
        //if(img.move_next()){
        //dlib::bgr_pixel& pixel = img.element();
        unsigned char &pixel = img.element();
        
        // assuming bgra format here
        long bufferLocation = position * 4; //(row * width + column) * 4;
        //baseBuffer[bufferLocation] = pixel.blue;
        //baseBuffer[bufferLocation] = pixel;
        //baseBuffer[bufferLocation + 1] = pixel.green;
        baseBuffer[bufferLocation+1] = pixel;
        //baseBuffer[bufferLocation + 2] = pixel.red;
        //        we do not need this
        //        char a = baseBuffer[bufferLocation + 3];
        
        position++;
        //}
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

+ (std::vector<dlib::rectangle>)convertCGRectValueArray:(NSArray<NSValue *> *)rects {
    std::vector<dlib::rectangle> myConvertedRects;
    for (NSValue *rectValue in rects) {
        CGRect rect = [rectValue CGRectValue];
        int left = rect.origin.x;
        int top = rect.origin.y;
        int right = left + rect.size.width;
        int bottom = top + rect.size.height;
        dlib::rectangle dlibRect(left, top, right, bottom);

        myConvertedRects.push_back(dlibRect);
    }
    return myConvertedRects;
}

@end
