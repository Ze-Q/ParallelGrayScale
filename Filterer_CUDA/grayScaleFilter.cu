#include <stdio.h>
#include "lodepng.h"

// kernel run on each thread
__global__ void grayScaleFilter(unsigned char * d_out, unsigned char * d_in){
  int idx = blockDim.x * blockIdx.x + threadIdx.x;
  int rgbAverage = 0;
  int sum = 0;
  for (int i = 0; i < 3; i++) { 
    sum = sum + d_in[4*idx+i];
  }
  rgbAverage = sum/3;
  for (int i = 0; i < 3; i++) { // for RGB channels, apply grayScaleFilter
    d_out[4*idx+i] = rgbAverage;
  }
  d_out[4*idx + 3] = d_in[4*idx + 3]; // keep the same value for alpha channel
}

int main(int argc, char ** argv) {
  char * in_filename = argv[1];
  char * out_filename = argv[2];
  printf("Applying grayscale filter on %s\n", in_filename);

  // load input image 
  unsigned error;
  unsigned char *h_in_img, *h_out_img, *d_in_img, *d_out_img;
  unsigned width, height;

  // error handling
  error = lodepng_decode32_file(&h_in_img, &width, &height, in_filename);
  if (error) printf("error %u: %s\n", error, lodepng_error_text(error));

  const int IMAGE_PIXELS = width*height;
  const int IMAGE_BYTES = IMAGE_PIXELS * 4 * sizeof(unsigned char);
  const int THREADS_PER_BLOCK = 1024;
  const int BLOCK_COUNT = IMAGE_PIXELS/THREADS_PER_BLOCK;
  
  // allocate CPU memory
  h_out_img = (unsigned char *) malloc(IMAGE_BYTES);

  // allocate GPU memory
  cudaMalloc(&d_in_img, IMAGE_BYTES);
  cudaMalloc(&d_out_img, IMAGE_BYTES);

  // transfer image to GPU
  cudaMemcpy(d_in_img, h_in_img, IMAGE_BYTES, cudaMemcpyHostToDevice);

  // launch kernel
  grayScaleFilter<<<BLOCK_COUNT, THREADS_PER_BLOCK>>>(d_out_img, d_in_img);
  
  // copy back result array to CPU
  cudaMemcpy(h_out_img, d_out_img, IMAGE_BYTES, cudaMemcpyDeviceToHost);

  int rgbAverage = 0;
  int sum = 0;

  // process remainder on CPU since image size not always evenly divisible by block size
  int remainder = IMAGE_PIXELS % THREADS_PER_BLOCK;
  for (int idx = IMAGE_PIXELS - remainder; idx < IMAGE_PIXELS; idx++) {
    for (int i = 0; i < 3; i++) { // for RGB channels, apply grayScaleFilter
      sum = sum + h_in_img[4*idx+i];
    }
  	h_out_img[4*idx + 3] = h_in_img[4*idx + 3]; // keep the same value for alpha channel
  }

  rgbAverage = sum/3;
  for (int idx = IMAGE_PIXELS - remainder; idx < IMAGE_PIXELS; idx++) {
    for (int i = 0; i < 3; i++) { // for RGB channels, apply grayScaleFilter
       h_out_img[4*idx + i] = rgbAverage; // keep the same value for alpha channel
    }
  }

  // save output image 
  lodepng_encode32_file(out_filename, h_out_img, width, height);

  // cleanup
  cudaFree(d_in_img);
  cudaFree(d_out_img);
  free(h_in_img);
  free(h_out_img);

  return 0;
}