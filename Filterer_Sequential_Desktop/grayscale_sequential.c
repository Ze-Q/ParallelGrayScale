#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>

void process(char* input_filename, char* output_filename)
{
  unsigned error;
  unsigned char *image, *new_image;
  unsigned width, height;

  error = lodepng_decode32_file(&image, &width, &height, input_filename);
  if(error) printf("error %u: %s\n", error, lodepng_error_text(error));
  new_image = malloc(width * height * 4 * sizeof(unsigned char));

  // Apply grayscale filter to image
  printf("Apply grayscale filter on %s\n", input_filename);
  int i, j, channel;
  for (i = 0; i < height; i++) {
    for (j = 0; j < width; j++) {
    	int sum = 0;
    	int average = 0;
    	for (channel = 0; channel < 3; channel++) { // RGB
    		sum = sum + image[4*width*i + 4*j + channel];
  		}
  		average = sum / 3;
  		for (channel = 0; channel < 3; channel++) { // RGB
  			new_image[4*width*i + 4*j + channel] = average;
  		}
  		new_image[4*width*i + 4*j + 3] = image[4*width*i + 4*j + 3]; // A
    }
  }

  lodepng_encode32_file(output_filename, new_image, width, height);

  free(image);
  free(new_image);
}

int main(int argc, char *argv[])
{
  char* input_filename = argv[1];
  char* output_filename = argv[2];

  process(input_filename, output_filename);

  return 0;
}
