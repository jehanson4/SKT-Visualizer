//
//  SK2_Shaders.metal
//  SKT Visualizer
//
//  Created by James Hanson on 6/15/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct Light {
    packed_float3 color;      // 0 - 2
    float ambientIntensity;   // 3
    packed_float3 direction;  // 4 - 6
    float diffuseIntensity;   // 7
    float shininess;          // 8
    float specularIntensity;  // 9
    
    /*
     _______________________
     |0 1 2 3|4 5 6 7|8 9    |
     -----------------------
     |       |       |       |
     | chunk0| chunk1| chunk2|
     */
};

struct SK2_Uniforms {
    float4x4 modelViewMatrix;
    float4x4 projectionMatrix;
    Light light;
    float pointSize;

};

struct SK2_VertexIn {
    float3 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
    float3 normal   [[attribute(2)]];
};

struct SK2_VertexOut {
    float4 position [[position]];
    float  pointSize [[point_size]];
    float3 fragmentPosition;
    float4 color;
};

vertex SK2_VertexOut sk2_nodes_vertex(SK2_VertexIn vertexIn [[stage_in]],
                                      const device SK2_Uniforms&  uniforms [[ buffer(3) ]]) {
    
    float4x4 mv_Matrix = uniforms.modelViewMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    SK2_VertexOut vertexOut;
    vertexOut.position = proj_Matrix * mv_Matrix * float4(vertexIn.position,1);
    vertexOut.pointSize = uniforms.pointSize;
    vertexOut.fragmentPosition = (mv_Matrix * float4(vertexIn.position,1)).xyz;
    
    vertexOut.color = vertexIn.color;
    
    return vertexOut;
}

fragment float4 sk2_nodes_fragment(SK2_VertexOut interpolated           [[ stage_in ]],
                                   const device SK2_Uniforms&  uniforms [[ buffer(3) ]]) {
    return interpolated.color;
}
