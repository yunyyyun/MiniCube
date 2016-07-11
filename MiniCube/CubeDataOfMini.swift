//
//  TestVertexData.swift
//  ES2
//
//  Created by mengyun on 16/2/15.
//  Copyright © 2016年 mengyun. All rights reserved.
//

import Foundation
import OpenGLES

let MOVE2:GLfloat=1.0
var colorFlag2=1
var allTextureCoords2=[[GLfloat]](count: 8, repeatedValue: [GLfloat](count: 48, repeatedValue: 0.0))

let StepNumber2=22
let backGroundColorR=11
let backGroundColorG=11
let backGroundColorB=11
let TextureNum=1


var cubeVerticesData2: [GLfloat] = [
    -0.5,-0.5, 0.5,  0.5,-0.5, 0.5, -0.5, 0.5, 0.5,  0.5, 0.5, 0.5,     // Front face
    0.5, 0.5, 0.5,  0.5,-0.5, 0.5,  0.5, 0.5,-0.5,  0.5,-0.5,-0.5,     // Right face
    0.5,-0.5,-0.5, -0.5,-0.5,-0.5,  0.5, 0.5,-0.5, -0.5, 0.5,-0.5,     // Back face
    -0.5, 0.5,-0.5, -0.5,-0.5,-0.5, -0.5, 0.5, 0.5, -0.5,-0.5, 0.5,     // Left face
    -0.5,-0.5, 0.5, -0.5,-0.5,-0.5,  0.5,-0.5, 0.5,  0.5,-0.5,-0.5,     // Bottom face
    -0.5, 0.5, 0.5,  0.5, 0.5, 0.5, -0.5, 0.5,-0.5,  0.5, 0.5,-0.5      // Top Face
    ]

var FC2: [GLfloat] = [1.00/3,1.00, 1.00/3,2.00/3, 2.00/3,1.00, 2.00/3,2.00/3]  //1 Front face
var RC2: [GLfloat] = [2.00/3,2.00/3, 1.00/3,2.00/3, 2.00/3,1.00/3, 1.00/3,1.00/3]  //2 Right face
var BC2: [GLfloat] = [1.00/3,1.00/3, 1.00/3,0.00, 2.00/3,1.00/3, 2.00/3,0.00]  //3 Back face
var LC2: [GLfloat] = [1.00/3,1.00, 0.00,1.00, 1.00/3,2.00/3, 0.00,2.00/3]  //4 Left face
var DC2: [GLfloat] = [1.00/3,2.00/3, 0.00,2.00/3, 1.00/3,1.00/3, 0.00,1.00/3]  //5  down face
var TC2: [GLfloat] = [0.00,1.00/3, 0.00,0.00, 1.00/3,1.00/3, 1.00/3,0.00]  //6  Top face
var NC2: [GLfloat] = [1.00,1.00, 1.00,1.00, 1.00,1.00, 1.00,1.00]  //no color

var textureCoordsOld2:[[GLfloat]]=[
    FC2,NC2,NC2,LC2,NC2,TC2,  FC2,RC2,NC2,NC2,NC2,TC2,  FC2,NC2,NC2,LC2,DC2,NC2,   FC2,RC2,NC2,NC2,DC2,NC2,
    NC2,NC2,BC2,LC2,NC2,TC2,  NC2,RC2,BC2,NC2,NC2,TC2,  NC2,NC2,BC2,LC2,DC2,NC2,   NC2,RC2,BC2,NC2,DC2,NC2
]

var Blue2: [GLubyte] = [3,3,253]
var Red2: [GLubyte] = [253,3,3]
var Green2: [GLubyte] = [3,253,3]
var Gray2: [GLubyte] = [223,223,253]
var Yello2: [GLubyte] = [253,243,73]
var Brown2: [GLubyte] = [223,123,253]

var faceColors2:[[GLubyte]] = [Blue2,Red2,Green2,Gray2,Yello2,Brown2]

func initTextureCoords2(){
    var ii=0
    for i in 0 ..< textureCoordsOld2.count {
        for j in 0 ..< textureCoordsOld2[i].count {
            allTextureCoords2[ii/48][ii%48] = textureCoordsOld2[i][j]
            ii += 1;
        }
    }
}











