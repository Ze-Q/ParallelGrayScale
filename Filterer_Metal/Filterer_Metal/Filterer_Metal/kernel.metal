//
//  kernel.metal
//  Filterer_Metal
//
//  Created by Ze Qian Zhang on 2016-11-27.
//  Copyright © 2016 zexception. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void grayscale(texture2d<float, access::read> inTexture [[texture(0)]],
                     texture2d<float, access::write> outTexture [[texture(1)]],
                     device unsigned int *pixelSize [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    const float4 colorAtPixel = inTexture.read(gid);
    float average = (colorAtPixel.r + colorAtPixel.g + colorAtPixel.b)/3;
    const float4 outputColor = float4(average, average, average, 1);
    outTexture.write(outputColor, gid);
}

