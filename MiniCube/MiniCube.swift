//
//  BlockData.swift
//  ES2
//
//  Created by mengyun on 16/2/4.
//  Copyright © 2016年 mengyun. All rights reserved.
//

import GLKit
import OpenGLES

class MiniCube {

    //var hidden:[[[Bool]]]!          //方块是否隐藏
//    var hidden = [[[Bool]]](count: 6, repeatedValue:[[Bool]](count: 6, repeatedValue:
//        [Bool](count: 6, repeatedValue:false)))
    
    var cubes=[CubeOfMini](count: 8, repeatedValue: CubeOfMini())
    var textureArray = [GLuint](count: TextureNum, repeatedValue:0)  //纹理数组
    
    func initMagicCube(flag: Int=0){

        colorFlag2=1
        
        
        for i in 0...1{
            for j in 0...1{
                for k in 0...1{
                    let m_cubes=CubeOfMini()
                    m_cubes.initVecticesData(GLint(i), col: GLint(j), layer: GLint(k))
                    cubes[i*2+j+k*4] = m_cubes
                }
            }
        }
         if flag==1{
            textureArray[0] = loadTextureEXT()
        }
        
        let flag:GLubyte=0
        for i in 0...7{
            if (cubes[i].layer != 0){
                cubes[i].colors[0]=flag
                cubes[i].colors[4]=flag
                cubes[i].colors[8]=flag
                cubes[i].colors[12]=flag
            }
            if (cubes[i].layer != 1){
                cubes[i].colors[32]=flag
                cubes[i].colors[36]=flag
                cubes[i].colors[40]=flag
                cubes[i].colors[44]=flag
            }
            if (cubes[i].row != 0){
                cubes[i].colors[80]=flag
                cubes[i].colors[84]=flag
                cubes[i].colors[88]=flag
                cubes[i].colors[92]=flag
            }
            if (cubes[i].row != 1){
                cubes[i].colors[64]=flag
                cubes[i].colors[68]=flag
                cubes[i].colors[72]=flag
                cubes[i].colors[76]=flag
            }
            if (cubes[i].col != 0){
                cubes[i].colors[48]=flag
                cubes[i].colors[52]=flag
                cubes[i].colors[56]=flag
                cubes[i].colors[60]=flag
            }
            if (cubes[i].col != 1){
                cubes[i].colors[16]=flag
                cubes[i].colors[20]=flag
                cubes[i].colors[24]=flag
                cubes[i].colors[28]=flag
            }
        }

    }
    
    func loadTextureEXT()->GLuint{
        let textureImage=createCGImageEXT()
        let width=CGImageGetWidth(textureImage)
        let height=CGImageGetHeight(textureImage)
        //let textureData=calloc(width*height*4, sizeof(GLubyte))
        let textureData=UnsafeMutablePointer<GLubyte>.alloc(width*height*4*sizeof(GLubyte))
        //let bithiddenInfo = CGBithiddenInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let textureContext=CGBitmapContextCreate(textureData, width, height, 8, width*4, CGImageGetColorSpace(textureImage), UInt32(1))//todo
        
        CGContextDrawImage(textureContext, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), textureImage)
        var textureName:GLuint=0
        glGenTextures(1, &textureName)
        glBindTexture(UInt32(GL_TEXTURE_2D), textureName)
        //    glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        //    glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        //    glEnable(GL_BLEND);
        //    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        //    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glEnable(UInt32(GL_BLEND));
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        
        glBlendFunc(UInt32(GL_SRC_ALPHA), UInt32(GL_ONE_MINUS_SRC_ALPHA));
        glEnable(UInt32(GL_BLEND));
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        
        glGenerateMipmap(UInt32(GL_TEXTURE_2D));
        glEnable(UInt32(GL_TEXTURE_2D));
        
        glTexImage2D(UInt32(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), textureData)
        //print("textureName====",textureName)
        return textureName
    }
    func loadTextureEXTBySavedImage(savedImage: UIImage)->GLuint{
        let textureImage=savedImage.CGImage
        let width=CGImageGetWidth(textureImage)
        let height=CGImageGetHeight(textureImage)
        //let textureData=calloc(width*height*4, sizeof(GLubyte))
        let textureData=UnsafeMutablePointer<GLubyte>.alloc(width*height*4*sizeof(GLubyte))
        //let bithiddenInfo = CGBithiddenInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let textureContext=CGBitmapContextCreate(textureData, width, height, 8, width*4, CGImageGetColorSpace(textureImage), UInt32(1))//todo
        
        CGContextDrawImage(textureContext, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), textureImage)
        var textureName:GLuint=0
        
        var savedTextureName=GLuint(TextureNum)
        glDeleteTextures(1,&savedTextureName)
        
        glGenTextures(1, &textureName)
        glBindTexture(UInt32(GL_TEXTURE_2D), textureName)
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexImage2D(UInt32(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), textureData)
        //print("textureName====loadTextureEXTBySavedImage",textureName)
        return textureName
    }
    
    func createCGImageEXT()-> CGImage{
        let ff = "cc"//f[flages]+f[flages]
        let f1 = "c1"
        let f2 = "c2"
        let f3 = "c3"
        let f4 = "c4"
        let f5 = "c7"
        let f6 = "c6"
        
        let img = UIImage(named: ff)
        let img1 = UIImage(named: f1)
        let img2 = UIImage(named: f2)
        let img3 = UIImage(named: f3)
        let img4 = UIImage(named: f4)
        let img5 = UIImage(named: f5)
        let img6 = UIImage(named: f6)
        return createTextureWithImageEXT(img1!, img2: img2!, img3: img3!, img4: img4!, img5: img5!, img6: img6!, targetIMG: img!).CGImage!
    }
    
    func createTextureWithImageEXT(img1:UIImage,img2:UIImage,img3:UIImage,img4:UIImage,img5:UIImage,img6:UIImage,targetIMG:UIImage)->UIImage{
        let totalWidth = targetIMG.size.width
        let totalHeight = targetIMG.size.height
        let offScreeSize = CGSizeMake(totalWidth, totalHeight)
        UIGraphicsBeginImageContext(offScreeSize)
        let width = totalWidth/3
        let height = totalWidth/3
        
        let rect1 = CGRectMake(0, 0, width, height)
        img1.drawInRect(rect1)
        
        let rect2 = CGRectMake(0, height, width, height)
        img2.drawInRect(rect2)
        
        let rect3 = CGRectMake(0, height*2, width, height)
        img3.drawInRect(rect3)
        
        let rect4 = CGRectMake(width, 0, width, height)
        img4.drawInRect(rect4)
        
        let rect5 = CGRectMake(width, height, width, height)
        img5.drawInRect(rect5)
        
        let rect6 = CGRectMake(width, height*2, width, height)
        img6.drawInRect(rect6)
        
        targetIMG.drawInRect(CGRectMake(0, 0, totalWidth, totalHeight))
        
        let textureImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return textureImage
    }
}















