//
//  Shader.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/4/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import OpenGLES
#else
import OpenGL
#endif

class Shader {
    private var program: GLuint

    init(vertexShader: String, fragmentShader: String) {
        
        program = glCreateProgram()
        if program == 0 {
            NSLog("Program creation failed")
            // exit(1)
        }
        
        let vertexShaderName = self.compileShader(vertexShader, shaderType: GLenum(GL_VERTEX_SHADER))
        let fragmentShaderName = self.compileShader(fragmentShader, shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        glAttachShader(self.program, vertexShaderName)
        glAttachShader(self.program, fragmentShaderName)
        
        glBindAttribLocation(self.program, 0, "a_Position")
        glLinkProgram(self.program)
        
        var linkStatus : GLint = 0
        glGetProgramiv(self.program, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var infoLength : GLsizei = 0
            let bufferLength : GLsizei = 1024
            glGetProgramiv(self.program, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0
            
            glGetProgramInfoLog(self.program, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            NSLog(String(validatingUTF8: info)!)
            // exit(1)
        }
    }
    
    deinit {
        glDeleteProgram(program)
    }
    
    func compileShader(_ shaderName: String, shaderType: GLenum) -> GLuint {
        let path = Bundle.main.path(forResource: shaderName, ofType: nil)
        
        do {
            let shaderString = try NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue)
            let shaderHandle = glCreateShader(shaderType)
            var shaderStringLength : GLint = GLint(Int32(shaderString.length))
            var shaderCString = shaderString.utf8String
            glShaderSource(
                shaderHandle,
                GLsizei(1),
                &shaderCString,
                &shaderStringLength)
            
            glCompileShader(shaderHandle)
            var compileStatus : GLint = 0
            glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileStatus)
            
            if compileStatus == GL_FALSE {
                var infoLength : GLsizei = 0
                let bufferLength : GLsizei = 1024
                glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
                
                let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
                var actualLength : GLsizei = 0
                
                glGetShaderInfoLog(shaderHandle, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
                NSLog(String(validatingUTF8: info)!)
                // exit(1)
            }
            
            return shaderHandle
            
        } catch {
            exit(1)
        }
    }
}
