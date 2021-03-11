//
//  Empty.metal
//  MetalLive
//
//  Created by Gustavo Branco on 3/10/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void metaltoy(texture2d<float, access::write> output [[texture(0)]],
                    constant float  &iTime [[buffer(0)]],
                    constant float2 &iMouse [[buffer(1)]],
                    uint2 gid [[thread_position_in_grid]]) {
    float2 iResolution = float2(output.get_width(), output.get_height());
    float2 fragCoord = float2(gid);
    
    //float2 p = (2.0 * fragCoord - iResolution ) / iResolution.y;
    float2 p = (-iResolution.xy + 2.0*fragCoord)/iResolution.y;;
    p.y = -p.y; //Make coordinate system match OpenGL
    float time = iTime;
    time *= 1.7;
    output.write(float4(0,0,0, 1.0), uint2(fragCoord.x, fragCoord.y));
}
