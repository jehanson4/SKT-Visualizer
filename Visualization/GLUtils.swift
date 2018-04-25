//
//  GLUtils.swift
//  SKT Visualizer
//
//  Created by James Hanson on 4/18/18.
//  Copyright © 2018 James Hanson. All rights reserved.
//
//  Portions adapted from GLKMatrix4+Array.swift
//  Created by burt on 2016. 2. 28..
//  Copyright © 2016년 BurtK. All rights reserved.
//  @see https://www.snip2code.com/Snippet/407785/Xcode-6-3-OpenGL-Game-template-ported-to
//  Accessed 4/01/2018
//

import Foundation
import GLKit
//#if os(iOS) || os(tvOS)
//import OpenGLES
//#else
//import OpenGL
//#endif

/// struct with position & normal coords
struct PNVertex {
    var px: GLfloat
    var py: GLfloat
    var pz: GLfloat
    var nx: GLfloat
    var ny: GLfloat
    var nz: GLfloat
    
    init(_ px: GLfloat, _ py: GLfloat, _ pz: GLfloat, _ nx: GLfloat, _ ny: GLfloat, _ nz: GLfloat) {
        self.px = px
        self.py = py
        self.pz = pz
        self.nx = nx
        self.ny = ny
        self.nz = nz
    }
}

func BUFFER_OFFSET(_ n: Int) -> UnsafeRawPointer? {
    // Webz sez n = offset in bytes, so gotta do sizeof(array elem)
    return UnsafeRawPointer(bitPattern: n)
}

extension GLKMatrix4: CustomStringConvertible {
    public var description: String {
        return "["
            + String(format: "[%f, %f, %f, %f]", m00, m01, m02, m03)
            + ", "
            + String(format: "[%f, %f, %f, %f]", m10, m11, m12, m13)
            + ", "
            + String(format: "[%f, %f, %f, %f]", m20, m21, m22, m23)
            + ", "
            + String(format: "[%f, %f, %f, %f]", m30, m31, m32, m33)
            + "]"
    }
}

extension GLKMatrix2 {
    var array: [Float] {
        return (0..<4).map { i in
            self[i]
        }
    }
}


extension GLKMatrix3 {
    var array: [Float] {
        return (0..<9).map { i in
            self[i]
        }
    }
}

extension GLKMatrix4 {
    var array: [Float] {
        return (0..<16).map { i in
            self[i]
        }
    }
}


