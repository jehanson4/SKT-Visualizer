//
//  SK2_Shaders.metal
//  SKT Visualizer
//
//  Created by James Hanson on 6/15/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct SK2_Uniforms {
    
};

struct SK2_VertexIn {
    
};

struct SK2_VertexOut {
    float4 position [[position]];
    float  pointSize [[point_size]];
    float3 fragmentPosition;
    float4 color;
};

vertex SK2_VertexOut sk2_vertex(SK2_VertexIn vertexIn [[stage_in]],
const device SK2_Uniforms&  uniforms    [[ buffer(0) ]]) {
    
    // TODO
}
