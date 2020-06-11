//
//  DemoShaders.metal
//  SKT Visualizer
//
//  Created by James Hanson on 6/3/20.
//  Copyright © 2020 James Hanson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// ===============================================
// Common stuff
// ===============================================

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

struct Uniforms{
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
    Light light;
};


// =====================================
// Basic
// =====================================

struct VertexIn {
    packed_float3 position;
    packed_float4 color;
    packed_float2 texCoord;
    packed_float3 normal;
};

struct VertexOut {
    float4 position [[position]];
    float3 fragmentPosition;
    float4 color;
    float2 texCoord;
    float3 normal;
};

vertex VertexOut basic_vertex(
                              const device VertexIn* vertex_array [[ buffer(0) ]],
                              const device Uniforms&  uniforms    [[ buffer(1) ]],
                              unsigned int vid [[ vertex_id ]]) {
    
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    VertexIn VertexIn = vertex_array[vid];
    
    VertexOut VertexOut;
    VertexOut.position = proj_Matrix * mv_Matrix * float4(VertexIn.position,1);
    VertexOut.fragmentPosition = (mv_Matrix * float4(VertexIn.position,1)).xyz;
    
    VertexOut.color = VertexIn.color;
    VertexOut.texCoord = VertexIn.texCoord;
    VertexOut.normal = (mv_Matrix * float4(VertexIn.normal, 0.0)).xyz;
    
    return VertexOut;
}

fragment float4 basic_fragment(VertexOut interpolated [[stage_in]],
                               const device Uniforms&  uniforms    [[ buffer(1) ]],
                               texture2d<float>  tex2D     [[ texture(0) ]],
                               sampler           sampler2D [[ sampler(0) ]]) {
    
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
    
    // IGNORE Texture
    // float4 color = tex2D.sample(sampler2D, interpolated.texCoord);
    float4 color =  interpolated.color;
    
    return color * (ambientColor + diffuseColor + specularColor);
}


// ===============================================
// Cloud
// ===============================================

struct CloudVertexIn {
    float3 position [[attribute(0)]];
    float3 normal   [[attribute(1)]];
    float4 color    [[attribute(2)]];
};

struct CloudVertexOut {
    float4 position [[position]];
    float  pointSize [[point_size]];
    float3 fragmentPosition;
    float3 normal;
    float4 color;
};

vertex CloudVertexOut cloud_vertex(
                                   const device CloudVertexIn* vertex_array [[ buffer(0) ]],
                                   const device Uniforms&  uniforms    [[ buffer(3) ]],
                                   unsigned int vid [[ vertex_id ]]) {
    
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    CloudVertexIn vertexIn = vertex_array[vid];
    
    CloudVertexOut vertexOut;
    vertexOut.position = proj_Matrix * mv_Matrix * float4(vertexIn.position,1);
    vertexOut.pointSize = 0.5;
    vertexOut.fragmentPosition = (mv_Matrix * float4(vertexIn.position,1)).xyz;
    
    vertexOut.color = vertexIn.color;
    vertexOut.normal = (mv_Matrix * float4(vertexIn.normal, 0.0)).xyz;
    
    return vertexOut;
}

fragment float4 cloud_fragment(CloudVertexOut interpolated [[stage_in]],
                               const device Uniforms&  uniforms    [[ buffer(3) ]]) {
    
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

