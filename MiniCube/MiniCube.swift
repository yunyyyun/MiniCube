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
    
    var cubes=[CubeOfMini](repeating: CubeOfMini(), count: 8)
    var textureArray = [GLuint](repeating: 0, count: TextureNum)  //纹理数组
    
    func initMagicCube(_ flag: Int=0){

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
        let width=textureImage.width
        let height=textureImage.height
        //let textureData=calloc(width*height*4, sizeof(GLubyte))
        let textureData=UnsafeMutablePointer<GLubyte>.allocate(capacity: width*height*4*MemoryLayout<GLubyte>.size)
        //let bithiddenInfo = CGBithiddenInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let textureContext=CGContext(data: textureData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width*4, space: textureImage.colorSpace!, bitmapInfo: UInt32(1))//todo
        
        textureContext?.draw(textureImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
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
    func loadTextureEXTBySavedImage(_ savedImage: UIImage)->GLuint{
        let textureImage=savedImage.cgImage
        let width=textureImage?.width
        let height=textureImage?.height
        //let textureData=calloc(width*height*4, sizeof(GLubyte))
        let textureData=UnsafeMutablePointer<GLubyte>.allocate(capacity: width!*height!*4*MemoryLayout<GLubyte>.size)
        //let bithiddenInfo = CGBithiddenInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let textureContext=CGContext(data: textureData, width: width!, height: height!, bitsPerComponent: 8, bytesPerRow: width!*4, space: (textureImage?.colorSpace!)!, bitmapInfo: UInt32(1))//todo
        
        textureContext?.draw(textureImage!, in: CGRect(x: 0, y: 0, width: CGFloat(width!), height: CGFloat(height!)))
        var textureName:GLuint=0
        
        var savedTextureName=GLuint(TextureNum)
        glDeleteTextures(1,&savedTextureName)
        
        glGenTextures(1, &textureName)
        glBindTexture(UInt32(GL_TEXTURE_2D), textureName)
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(UInt32(GL_TEXTURE_2D), UInt32(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexImage2D(UInt32(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(width!), GLsizei(height!), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), textureData)
        //print("textureName====loadTextureEXTBySavedImage",textureName)
        return textureName
    }
    
    func createCGImageEXT()-> CGImage{
        let ff = "ff"//f[flages]+f[flages]
        let f1 = "f1"
        let f2 = "f2"
        let f3 = "f3"
        let f4 = "f4"
        let f5 = "f5"
        let f6 = "f6"
        
        let img = UIImage(named: ff)
        let img1 = UIImage(named: f1)
        let img2 = UIImage(named: f2)
        let img3 = UIImage(named: f3)
        let img4 = UIImage(named: f4)
        let img5 = UIImage(named: f5)
        let img6 = UIImage(named: f6)
        return createTextureWithImageEXT(img1!, img2: img2!, img3: img3!, img4: img4!, img5: img5!, img6: img6!, targetIMG: img!).cgImage!
    }
    
    func createTextureWithImageEXT(_ img1:UIImage,img2:UIImage,img3:UIImage,img4:UIImage,img5:UIImage,img6:UIImage,targetIMG:UIImage)->UIImage{
        let totalWidth = targetIMG.size.width
        let totalHeight = targetIMG.size.height
        let offScreeSize = CGSize(width: totalWidth, height: totalHeight)
        UIGraphicsBeginImageContext(offScreeSize)
        let width = totalWidth/3
        let height = totalWidth/3
        
        let rect1 = CGRect(x: 0, y: 0, width: width, height: height)
        img1.draw(in: rect1)
        
        let rect2 = CGRect(x: 0, y: height, width: width, height: height)
        img2.draw(in: rect2)
        
        let rect3 = CGRect(x: 0, y: height*2, width: width, height: height)
        img3.draw(in: rect3)
        
        let rect4 = CGRect(x: width, y: 0, width: width, height: height)
        img4.draw(in: rect4)
        
        let rect5 = CGRect(x: width, y: height, width: width, height: height)
        img5.draw(in: rect5)
        
        let rect6 = CGRect(x: width, y: height*2, width: width, height: height)
        img6.draw(in: rect6)
        
        targetIMG.draw(in: CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))
        
        let textureImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return textureImage!
    }
}















