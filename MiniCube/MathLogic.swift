//
//  MagicLogic.swift
//  ES2
//
//  Created by mengyun on 16/2/24.
//  Copyright © 2016年 mengyun. All rights reserved.
//

import GLKit
import OpenGLES

//计算射线方向的下一个点
func getNextPoint(_ point1: CGPoint,point2: CGPoint,inc:GLint)->CGPoint{
    
    let deltaX:CGFloat = point2.x - point1.x;
    let deltaY:CGFloat = point2.y - point1.y;
    
    var point3=CGPoint()
    let t = CGFloat(inc/2)+1.0
    
    point3 = CGPoint(x: point1.x+deltaX*t, y: point1.y+deltaY*t)
    
    return point3
}

//CFPoint映射到轨迹球上
func mapToSphere(_ point: CGPoint)->[Float]{
    let adjustWidth:CGFloat=1.0/((375-1.0)*0.5)
    let adjustHeight:CGFloat=1.0/((667-1.0)*0.5)
    var tmpPoint:CGPoint=CGPoint()
    tmpPoint.x=(point.x*adjustWidth)-1.0
    tmpPoint.y=1.0-(point.y*adjustHeight)
    let length=(tmpPoint.x*tmpPoint.x)+(tmpPoint.y*tmpPoint.y)
    var tmpVec3:[Float]=[Float](repeating: 0.0, count: 3)
    if length>1.0{
        tmpVec3[0]=Float(tmpPoint.x/sqrt(length))
        tmpVec3[1]=Float(tmpPoint.y/sqrt(length))
        tmpVec3[2]=0.0
    }
    else{
        tmpVec3[0]=Float(tmpPoint.x)
        tmpVec3[1]=Float(tmpPoint.y)
        tmpVec3[2]=Float(sqrt(1.0-length))
    }
    return tmpVec3
}

//求得轨迹球旋转四元数
func getQuaternion(_ startVec3: [Float],endVec3: [Float])->[Float]{
    var rotQuaternion:[Float]=[Float](repeating: 0.0, count: 4)
    rotQuaternion[0]=(startVec3[1]*endVec3[2])-(startVec3[2]*endVec3[1])
    rotQuaternion[1]=(startVec3[2]*endVec3[0])-(startVec3[0]*endVec3[2])
    rotQuaternion[2]=(startVec3[0]*endVec3[1])-(startVec3[1]*endVec3[0])
    var length=rotQuaternion[0]*rotQuaternion[0]+rotQuaternion[1]*rotQuaternion[1]
    length=length+rotQuaternion[2]*rotQuaternion[2]
    if length>0.0{
        rotQuaternion[3]=(startVec3[0]*endVec3[0]) + (startVec3[1] * endVec3[1]) + (startVec3[2] * endVec3[2])
    }
    else{
        rotQuaternion[0]=0.0
        rotQuaternion[1]=0.0
        rotQuaternion[2]=0.0
        rotQuaternion[3]=0.0
    }
    return rotQuaternion
}

//求得轨迹球旋转矩阵
func getRotationMatrix(_ rotQuaternion: [Float])->GLKMatrix4{
    let x=rotQuaternion[0];
    let y=rotQuaternion[1];
    let z=rotQuaternion[2];
    let w=rotQuaternion[3];
    let x2 = x * x;
    let y2 = y * y;
    let z2 = z * z;
    let xy = x * y;
    let xz = x * z;
    let yz = y * z;
    let wx = w * x;
    let wy = w * y;
    let wz = w * z;
    
    let m00:Float=1.0-2.0*(y2+z2)
    let m01:Float=2.0*(xy-wz)
    let m02:Float=2.0*(xz+wy)
    let m03:Float=0.0;
    let m10:Float=2.0*(xy+wz);
    let m11:Float=1.0-2.0*(x2+z2)
    let m12:Float=2.0*(yz-wx)
    let m13:Float=0.0
    let m20:Float=2.0*(xz-wy)
    let m21:Float=2.0*(yz+wx)
    let m22:Float=1.0-2.0*(x2 + y2)
    let m23:Float=0.0
    let m30:Float=0.0
    let m31:Float=0.0
    let m32:Float=0.0
    let m33:Float=1.0
    let rotMat=GLKMatrix4Make(m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32, m33)
    return rotMat
    
}





