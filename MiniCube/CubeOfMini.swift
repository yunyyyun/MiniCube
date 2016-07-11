//
//  Cube.swift
//  ES2
//
//  Created by mengyun on 16/2/3.
//  Copyright © 2016年 mengyun. All rights reserved.
//

import GLKit
import OpenGLES

class CubeOfMini: NSObject {
    
    
    var vertices=[GLfloat](count: 72, repeatedValue: 0.0) //pointX,pointY,pointZ
    var textureCoords=[GLfloat](count: 48, repeatedValue: 0.0) //textureX,textureY
    var colors=[GLubyte](count: 96, repeatedValue: 0)
    var row:GLint=0
    var col:GLint=0
    var layer:GLint=0
    
    var mmm = GLKMatrix4Identity  
    
    
    func initVecticesData(row:GLint, col:GLint,layer:GLint){
        let moveX:GLfloat =   MOVE2 * GLfloat(col)-0.5
        let moveY:GLfloat  =  -MOVE2 * GLfloat(row)+0.5
        let moveZ:GLfloat  =  -MOVE2 * GLfloat(layer)+0.5
        
        var j=0
        //var k=0
        //var vertices=[GLfloat](count: 120, repeatedValue: 0.0)
        let index = Int(row*2+col+layer*4);
        initTextureCoords2()
        for i in 0...71 {
            if i%3==0 {
                vertices[i] = cubeVerticesData2[j] + moveX;
                j=j+1
                vertices[i+1] = cubeVerticesData2[j] + moveY;
                j=j+1
                vertices[i+2] = cubeVerticesData2[j] + moveZ;
                j=j+1
            }
        }

        for i in 0...47 {
            textureCoords[i] = allTextureCoords2[index][i];
        }
        //print(vertices)
        self.row = row;
        self.col = col;
        self.layer = layer;
        
        for i in 0...95 {
            colors[i]=0;
        }
        var color:GLubyte=0
        for i in 0...95{
            if i%16==0{
                color=GLubyte(colorFlag2)
                self.colors[i]=color
                self.colors[i+4]=color
                self.colors[i+8]=color
                self.colors[i+12]=color
                colorFlag2 += 1
            }
        }
    }
}

