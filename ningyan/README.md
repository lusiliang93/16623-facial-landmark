# Face Landmarking on iPhone with additional function(smile detection)
This version of app is capable of detecting smile in the face. A point is drawn to the left eye of the detected face and it would turn pink if the person is smiling or blue when the person is not smiling. It is based on the basic version of facial-landmark master.
## Screenshot

![screenshot](WechaIMG2.jpeg)

## Credits

This app uses the Dlib library (<http://dlib.net>) and their default face landmarking model file downloaded from <http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2>. Thanks for the great work.

This project includes a precompiled Dlib. If you want to change something, consider that the ```Preprocessor Macros``` in the project linking Dlib need to be the same as the ```Compiler Flags``` when building the lib.

The project to build Dlib on iOS was generated according to [these](http://stackoverflow.com/a/35058969/972993) instructions. 

Thanks to Satya Mallick from [learnopencv.com](http://www.learnopencv.com). He recommended using the system face detector to me.

## License

Code (except for ```DisplayLiveSamples/lib/*```) is released under MIT license.
