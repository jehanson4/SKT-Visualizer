//
//  SK2ReducedSpaceShaders.metal
//  SKT Visualizer
//
//  Created by James Hanson on 7/24/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// =============================================================================
// uniforms
// =============================================================================

struct Uniforms {
    float4x4 modelViewMatrix;
    float4x4 projectionMatrix;
    float4 netColor;
    float nodeSize;
};

// =============================================================================
// nodes
// =============================================================================

struct NodeVertexIn {
    float3 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
};

struct NodeVertexOut {
    float4 position [[position]];
    float  pointSize [[point_size]];
    float3 fragmentPosition;
    float4 color;
};

vertex NodeVertexOut node_vertex(NodeVertexIn vertexIn [[stage_in]],
                                      const device Uniforms&  uniforms [[ buffer(2) ]]) {
    
    float4x4 mv_Matrix = uniforms.modelViewMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    NodeVertexOut vertexOut;
    vertexOut.position = proj_Matrix * mv_Matrix * float4(vertexIn.position,1);
    vertexOut.pointSize = uniforms.nodeSize;
    vertexOut.fragmentPosition = (mv_Matrix * float4(vertexIn.position,1)).xyz;
    
    vertexOut.color = vertexIn.color;
    
    return vertexOut;
}

fragment float4 node_fragment(NodeVertexOut interpolated           [[ stage_in ]],
                                   const device Uniforms&  uniforms [[ buffer(2) ]]) {
    return interpolated.color;
}

// =============================================================================
// net, descent lines
// =============================================================================


struct NetVertexIn {
    float3 position [[attribute(0)]];
};

struct NetVertexOut {
    float4 position [[position]];
    float3 fragmentPosition;
};

vertex NetVertexOut net_vertex(NetVertexIn vertexIn [[stage_in]],
                                      const device Uniforms&  uniforms [[ buffer(2) ]]) {
    
    float4x4 mv_Matrix = uniforms.modelViewMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    NetVertexOut vertexOut;
    vertexOut.position = proj_Matrix * mv_Matrix * float4(vertexIn.position,1);
    vertexOut.fragmentPosition = (mv_Matrix * float4(vertexIn.position,1)).xyz;
    
    return vertexOut;
}

fragment float4 net_fragment(NetVertexOut interpolated           [[ stage_in ]],
                                   const device Uniforms&  uniforms [[ buffer(2) ]]) {
    return uniforms.netColor;
}
