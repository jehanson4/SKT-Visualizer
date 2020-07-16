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
    float4x4 modelViewMatrix;
    float4x4 projectionMatrix;
    float pointSize;

};

struct SK2_NodeVertexIn {
    float3 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
};

struct SK2_NodeVertexOut {
    float4 position [[position]];
    float  pointSize [[point_size]];
    float3 fragmentPosition;
    float4 color;
};

vertex SK2_NodeVertexOut sk2_nodes_vertex(SK2_NodeVertexIn vertexIn [[stage_in]],
                                      const device SK2_Uniforms&  uniforms [[ buffer(2) ]]) {
    
    float4x4 mv_Matrix = uniforms.modelViewMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    SK2_NodeVertexOut vertexOut;
    vertexOut.position = proj_Matrix * mv_Matrix * float4(vertexIn.position,1);
    vertexOut.pointSize = uniforms.pointSize;
    vertexOut.fragmentPosition = (mv_Matrix * float4(vertexIn.position,1)).xyz;
    
    vertexOut.color = vertexIn.color;
    
    return vertexOut;
}

fragment float4 sk2_nodes_fragment(SK2_NodeVertexOut interpolated           [[ stage_in ]],
                                   const device SK2_Uniforms&  uniforms [[ buffer(2) ]]) {
    return interpolated.color;
}

struct SK2_NetVertexIn {
    float3 position [[ attribute(0)]];
};

struct SK2_NetVertexOut {
    float4 position [[position]];
    float3 fragmentPosition;
    float4 color;
};

vertex SK2_NetVertexOut sk2_net_vertex(SK2_NetVertexIn vertexIn [[stage_in]],
                                      const device SK2_Uniforms&  uniforms [[ buffer(2) ]]) {
    
    float4x4 mv_Matrix = uniforms.modelViewMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    SK2_NetVertexOut vertexOut;
    vertexOut.position = proj_Matrix * mv_Matrix * float4(vertexIn.position,1);
    vertexOut.fragmentPosition = (mv_Matrix * float4(vertexIn.position,1)).xyz;
    vertexOut.color = float4(1,1,1,1);
    
    return vertexOut;
}

fragment float4 sk2_net_fragment(SK2_NetVertexOut interpolated           [[ stage_in ]],
                                   const device SK2_Uniforms&  uniforms [[ buffer(2) ]]) {
    return interpolated.color;
}
