#include <opencv2/opencv.hpp>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs != 1) {
        mexErrMsgIdAndTxt("MyToolbox:image_read:nrhs", "One input required.");
    }
    
    char *filename = mxArrayToString(prhs[0]);
    cv::Mat img = cv::imread(filename);
    if (img.empty()) {
        mexErrMsgIdAndTxt("MyToolbox:image_read:imread", "Could not open or find the image.");
    }
    
    mwSize dims[3] = { img.rows, img.cols, img.channels() };
    plhs[0] = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
    unsigned char *outImg = (unsigned char *)mxGetData(plhs[0]);
    std::memcpy(outImg, img.data, img.total() * img.elemSize());
    
    mxFree(filename);
}
