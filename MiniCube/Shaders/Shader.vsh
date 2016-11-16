//
//  Shader.vsh
//  ES2
//
//  Created by mengyun on 16/2/2.
//  Copyright © 2016年 mengyun. All rights reserved.
//

attribute vec4 positionShader;
//attribute vec3 normal;
attribute vec4 colorShader;

varying lowp vec4 colorVarying;

attribute vec2 TexCoordIn; // New
varying vec2 TexCoordOut; // New
varying vec2 shaderTypeOut; // New

uniform mat4 modelViewProjectionMatrixShader;
//uniform mat3 normalMatrix;
uniform int shaderType;

void main()
{
    //vec3 eyeNormal = normalize(normalMatrix * normal);
    //vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    //vec4 diffuseColor = vec4(1, 1, 1, 1.0);
    
    //float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
    //colorVarying = diffuseColor * nDotVP;
    
    if (shaderType==1){
        TexCoordOut = TexCoordIn;
        shaderTypeOut[1]=0.5;
    }
    else{
        colorVarying = colorShader;//diffuseColor * nDotVP;
        shaderTypeOut[1]=1.5;
    }
    gl_Position = modelViewProjectionMatrixShader * positionShader;
}
