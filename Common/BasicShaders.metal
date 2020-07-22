//
//  BasicShaders.metal
//  SKT Visualizer
//
//  Created by James Hanson on 7/22/20.
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


struct BasicUniforms {
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
    Light light;
};

struct BasicVertexIn {
    packed_float3 position;
    packed_float4 color;
    packed_float3 normal;
};

struct BasicVertexOut {
    float4 position [[position]];
    float3 fragmentPosition;
    float4 color;
    float3 normal;

};

vertex BasicVertexOut basic_vertex(
                              const device BasicVertexIn* vertex_array [[ buffer(0) ]],
                              const device BasicUniforms&  uniforms    [[ buffer(1) ]],
                              unsigned int vid [[ vertex_id ]]) {
    
    float4x4 mv_matrix = uniforms.modelMatrix;
    float4x4 proj_matrix = uniforms.projectionMatrix;
    
    BasicVertexIn vertex_in = vertex_array[vid];
    
    BasicVertexOut vertex_out;
    vertex_out.position = proj_matrix * mv_matrix * float4(vertex_in.position,1);
    vertex_out.fragmentPosition = (mv_matrix * float4(vertex_in.position,1)).xyz;
    
    vertex_out.color = vertex_in.color;
    vertex_out.normal = (mv_matrix * float4(vertex_in.normal, 0.0)).xyz;
    
    return vertex_out;
}

fragment float4 basic_fragment(BasicVertexOut interpolated              [[stage_in]],
                               const device BasicUniforms&  uniforms    [[buffer(1)]]) {
    
    // Ambient
    Light light = uniforms.light;
    float4 ambientColor = float4(light.color * light.ambientIntensity, 1);
    
    // Diffuse
    float diffuseFactor = max(0.0, dot(interpolated.normal, light.direction));
    float4 diffuseColor = float4(light.color * light.diffuseIntensity * diffuseFactor, 1.0);
    
    // Specular
    float3 eye = normalize(interpolated.fragmentPosition);
    float3 reflection = reflect(light.direction, interpolated.normal);
    float specularFactor = pow(max(0.0, dot(reflection, eye)), light.shininess);
    float4 specularColor = float4(light.color * light.specularIntensity * specularFactor, 1.0);

    return interpolated.color * (ambientColor + diffuseColor + specularColor);
}

