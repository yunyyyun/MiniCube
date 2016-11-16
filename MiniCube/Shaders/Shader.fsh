//
//  Shader.fsh
//  ES2
//
//  Created by mengyun on 16/2/2.
//  Copyright © 2016年 mengyun. All rights reserved.
//
varying lowp vec2 TexCoordOut;
uniform sampler2D Texture; // New
varying lowp vec4 colorVarying;
varying lowp vec2 shaderTypeOut;

void main()
{
    if (shaderTypeOut[1]<1.0){
        gl_FragColor=texture2D(Texture, TexCoordOut);
    }
    else{
        gl_FragColor = colorVarying;
    }
}
