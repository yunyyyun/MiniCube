//
//  MagicViewController.swift
//  Magic
//
//  Created by mengyun on 16/1/30.
//  Copyright © 2016年 mengyun. All rights reserved.
//

import GLKit
import OpenGLES
import UIKit

//func BUFFER_OFFSET(_ i: Int) -> UnsafeRawPointer {
//    let p: UnsafeRawPointer? = nil
//    return p.advancedBy(i)
//}

func BUFFER_OFFSET(_ i: Int) -> UnsafeRawPointer {
    return UnsafeRawPointer(bitPattern: i)!
}

let UNIFORM_MODELVIEWPROJECTION_MATRIX = 0
let UNIFORM_NORMAL_MATRIX = 1
let UNIFORM_TEXTURE=2
let UNIFORM_COLOR=3
var uniforms = [GLint](repeating: 0, count: 4)

class MiniCubeViewController: GLKViewController{
    
    var program: GLuint = 0
    var _isPaused=0
    
    var modelViewProjectionMatrix:GLKMatrix4 = GLKMatrix4Identity
    var normalMatrix: GLKMatrix3 = GLKMatrix3Identity
    var rotation: Float = 0.0
    
    var vertexArray: GLuint = 0
    var vertexBuffer: GLuint = 0
    
    var context: EAGLContext? = nil
    var effect: GLKBaseEffect? = nil
    
    //var cube: cubes!
    var magicCube:MiniCube!
    
    var rotateType=0 //旋转类型，0为整体转
    var move_flag:Bool = true
    var point1:CGPoint!//手指屏幕坐标
    var point2:CGPoint!
    
    
    let ROTATE_NONE = -1
    let ROTATE_ALL = 0
    let ROTATE_X_CLOCKWISE = 1
    let ROTATE_X_ANTICLOCKWISE = 2
    let ROTATE_Y_CLOCKWISE = 3
    let ROTATE_Y_ANTICLOCKWISE = 4
    let ROTATE_Z_CLOCKWISE = 5
    let ROTATE_Z_ANTICLOCKWISE = 6
    
    let FACE_NONE:GLint = -1
    let FACE_FRONT:GLint = 0
    let FACE_RIGHT:GLint = 1
    let FACE_BACK:GLint   = 2
    let FACE_LEFT:GLint   = 3
    let FACE_BOTTOM:GLint = 4
    let FACE_TOP:GLint   = 5
    
    var stepNumber2=0
    
    var rotMat:GLKMatrix4=GLKMatrix4Identity //旋转矩阵
    var tmpMat:GLKMatrix4=GLKMatrix4Identity //上次旋转的矩阵
    //var pickMagicCube:[[Int]]=[[Int]](count: 2, repeatedValue: [Int](count: 3, repeatedValue: 0))
    
    var currentPickPixel:[GLubyte]=[GLubyte](repeating: 0, count: 3)   //当前pick的颜色数据
    var pickPixels:[[GLubyte]]=[[GLubyte]](repeating: [GLubyte](repeating: 0, count: 3), count: 2)  //pick方块的颜色数据
    var pickFlags=0  //0表示选中方块，10表示选中一个
    
    var rotationState = -1//ROTATE_NONE
    var _RotateAngle:GLfloat=0
    var _isSelectMode:Bool=false
    
    var currentSlice=[GLint](repeating: -1, count: 3)
    
    //var mmm = [GLKMatrix4](count: 27, repeatedValue: GLKMatrix4Identity)
    var fff=0
    var ccc=0
//    GLubyte temp[16];
//    int tempqueue[56];GLint squence[56]
    
    var squence = [Int](repeating: 0, count: 32)
    
    //var testNum:GLuint=0
    
    //var timer=0   //帧计数
    var round=StepNumber2{
        didSet{
            //timeLabel.text=NSString(format: "time:%02d:%02d", totalMicrosecond/60, totalMicrosecond%60) as String
             promptLabel.isHidden = (round==0 )
            reset.isEnabled = (round==0)
        }
    }
    var timer:Timer!
    var totalMicrosecond = 0{
        didSet{
            //timeLabel.text=NSString(format: "time:%02d:%02d", totalMicrosecond/60, totalMicrosecond%60) as String
            if totalMicrosecond<600000{
                timeLabel.text=NSString(format: "time:%02d:%02d:%02d", totalMicrosecond/100/60, totalMicrosecond/100%60,totalMicrosecond%100) as String
            }
        }
    }
    var steps:Int = 0{
        didSet{
            stepLabel.text=NSString(format: "step:%d", steps) as String
            stepLabel.textColor=UIColor.blue
            if steps==1{
                stepLabel.textColor=UIColor.blue
                timeLabel.textColor=UIColor.blue
            }
            if steps==0{
                stepLabel.textColor=UIColor.gray
                timeLabel.textColor=UIColor.gray
            }
        }
    }
    
    var isReduction = 0{
        didSet{
            if isReduction%10==1&&isReduction/10==0&&steps>0 {
                successLabel.isHidden=false
            }
            else {
                successLabel.isHidden = true
            }
        }
        willSet{
            
        }
    }
    
    var timeLabel:UILabel!
    var stepLabel:UILabel!
    var promptLabel:UILabel!
    var successLabel:UILabel!
    var reset:UIButton!
    
    var backgroundColorR:GLubyte=0
    var backgroundColorG:GLubyte=0
    var backgroundColorB:GLubyte=0
    var backgroundColorA:GLubyte=180
    
    deinit {
        self.tearDownGL()
        
        if EAGLContext.current() === self.context {
            EAGLContext.setCurrent(nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepNumber2=StepNumber2
        
        self.context = EAGLContext(api: .openGLES2)
        if !(self.context != nil) {
            ////////print("Failed to create ES context")
        }
        
        let view = self.view as! GLKView
        view.context = self.context!
        view.drawableDepthFormat = .format24
        
        self.setupGL()
        self.update()
        
        let width=view.frame.width
        let height = view.frame.height
        
        reset = UIButton(type: .custom)
        reset.frame = CGRect(x: 1, y: 1, width: 55, height: 55)
        reset.backgroundColor=UIColor.clear
        reset.setImage(UIImage(named:"Upset"),for:UIControlState())
        reset.addTarget(self, action: #selector(MiniCubeViewController.clickToSet(_:)), for: .touchUpInside)
        view.addSubview(reset)
        
        timeLabel = UILabel(frame: CGRect(x: width-118, y: 2, width: 114, height: 24))
        timeLabel.backgroundColor=UIColor.clear
        timeLabel.textColor=UIColor.gray
        timeLabel.text="time:00:00:00"
        timeLabel.textAlignment = .left
        view.addSubview(timeLabel)
        
        stepLabel = UILabel(frame: CGRect(x: width-118, y: 30, width: 114, height: 24))
        stepLabel.backgroundColor=UIColor.clear
        stepLabel.textColor=UIColor.gray
        stepLabel.text="step:0"
        stepLabel.textAlignment = .left
        view.addSubview(stepLabel)
        
        promptLabel = UILabel(frame: CGRect(x: 20, y: 66, width: width-40, height: 44))
        promptLabel.backgroundColor=UIColor.clear
        promptLabel.textColor=UIColor.red
        promptLabel.text="请稍等，正在打乱魔方..."
        promptLabel.textAlignment = .center
        promptLabel.isHidden=true
        view.addSubview(promptLabel)
        
        successLabel = UILabel(frame: CGRect(x: 20, y: height-111, width: width-40, height: 44))
        successLabel.backgroundColor=UIColor.clear
        successLabel.textColor=UIColor.red
        successLabel.text="恭喜你，魔方已被还原！"
        successLabel.textAlignment = .center
        successLabel.isHidden=true
        view.addSubview(successLabel)
    }
    
    func clickToSet(_ btn:UIButton){
        ////////print("clicker")
        resetCube()
        stepNumber2=StepNumber2

        
        if round<=0 {
            round=stepNumber2
            steps=0
            if timer != nil {
                timer.invalidate()
                timer = nil;
            }
            totalMicrosecond=0
        }
        //////print("before..........",isReduction)
        isReduction=isReduction%10
        //////print("after..........",isReduction)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        backgroundColorR = GLubyte(backGroundColorR)
        backgroundColorG=GLubyte(backGroundColorG)
        backgroundColorB=GLubyte(backGroundColorB)

        
        super.viewWillAppear(animated)
        
        self.update()
        rotationState = ROTATE_NONE
        _isPaused=0
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector:#selector(UIApplicationDelegate.applicationWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: app)
    }
    
    func applicationWillEnterForeground(_ notification: Notification){
        self.update()
        //rotationState = ROTATE_NONE
        _isPaused=0
        rotationState = ROTATE_NONE
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _isPaused=1
        NotificationCenter.default.removeObserver(self)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if self.isViewLoaded && (self.view.window != nil) {
            self.view = nil
            
            self.tearDownGL()
            
            if EAGLContext.current() === self.context {
                EAGLContext.setCurrent(nil)
            }
            self.context = nil
        }
    }
    
    func setupGL() {
        EAGLContext.setCurrent(self.context)
        self.loadShaders()
        glEnable(UInt32(GL_DEPTH_TEST))
        glEnable(UInt32(GL_SMOOTH))
        glActiveTexture(UInt32(GL_TEXTURE0))

        magicCube=MiniCube()
        magicCube.initMagicCube(1)
    }
    
    func tearDownGL() {
        EAGLContext.setCurrent(self.context)
        
        glDeleteBuffers(1, &vertexBuffer)
        glDeleteVertexArraysOES(1, &vertexArray)
        
        self.effect = nil
        
        if program != 0 {
            glDeleteProgram(program)
            program = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        point1=((touches as NSSet).anyObject()! as AnyObject).location(in: self.view)
        ////////print(point1)
        move_flag=false
        rotateType=rotateType(point1)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if rotateType != 0 {
//            return
//        }
                point2=((touches as NSSet).anyObject()! as AnyObject).location(in: self.view)
        if (point2.x-point1.x)*(point2.x-point1.x)>0-(point2.y-point1.y)*(point2.y-point1.y){
            if move_flag && rotationState == ROTATE_NONE{
                if rotateType != 0 && round==0{
                    _isSelectMode=true
                    return
                }
                var startVec3:[Float]=[Float](repeating: 0.0, count: 3)//轨迹球坐标
                var endVec3:[Float]=[Float](repeating: 0.0, count: 3)
                startVec3=mapToSphere(point2)
                endVec3=mapToSphere(point1)
                var rotQuaternion:[Float]=[Float](repeating: 0.0, count: 4)
                rotQuaternion = getQuaternion(startVec3,endVec3: endVec3)
                rotMat = getRotationMatrix(rotQuaternion)
                rotMat=GLKMatrix4Multiply(rotMat,tmpMat);
            }
            move_flag=true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        tmpMat=rotMat
        if rotationState==ROTATE_ALL {
            rotationState = ROTATE_NONE
        }
//        if rotateType != 0{
//            point2=(touches as NSSet).anyObject()!.locationInView(self.view)
//            _isSelectMode=true
//            return
//        }
//        if(move_flag == false){
//        }
//
//        }
    }
    
    func checkIfCoplanar2(_ i: Int, j: Int, k: Int, l: Int)->Bool {
        if magicCube.cubes[i].row==magicCube.cubes[j].row&&magicCube.cubes[j].row==magicCube.cubes[k].row&&magicCube.cubes[k].row==magicCube.cubes[l].row {
            return true
        }
        if magicCube.cubes[i].col==magicCube.cubes[j].col&&magicCube.cubes[j].col==magicCube.cubes[k].col&&magicCube.cubes[k].col==magicCube.cubes[l].col {
            return true
        }
        if magicCube.cubes[i].layer==magicCube.cubes[j].layer&&magicCube.cubes[j].layer==magicCube.cubes[k].layer&&magicCube.cubes[k].layer==magicCube.cubes[l].layer {
            return true
        }
        return false
    }
    
    func checkStatus() -> Int{
//        for i in 0...7 {
//            if magicCube.cubes[i].row*2+magicCube.cubes[i].col+magicCube.cubes[i].layer*4 != GLint(i){
//                return 0
//            }
//        }
//        if steps > 0 {
//            return 1
//        }
        if checkIfCoplanar2(0, j: 1, k: 2, l: 3)&&checkIfCoplanar2(1, j: 3, k: 5, l: 7)&&checkIfCoplanar2(0, j: 1, k: 4, l: 5)&&checkIfCoplanar2(0, j: 2, k: 4, l: 6)&&checkIfCoplanar2(4, j: 5, k: 6, l: 7)&&checkIfCoplanar2(6, j: 7, k: 2, l: 3)&&steps>0{
            return (isReduction/10)*10+1
        }
        return (isReduction/10)*10
    }
    
    func rotateType(_ point:CGPoint)->Int{
        let viewport=UnsafeMutablePointer<GLint>.allocate(capacity: 4*MemoryLayout<GLint>.size)
        glGetIntegerv(UInt32(GL_VIEWPORT), viewport)
        let tmpPixel=UnsafeMutablePointer<GLubyte>.allocate(capacity: 4*MemoryLayout<GLubyte>.size)
        let x:GLint=2*GLint(point.x)
        let y:GLint=GLint(viewport[3])-2*GLint(point.y)
        glReadPixels(x,y,1,1,GLenum(GL_RGBA),GLenum(GL_UNSIGNED_BYTE),tmpPixel)
        //print("rotateType.....",tmpPixel[0],tmpPixel[1],tmpPixel[2],tmpPixel[3])
        var rlt = 1
        if  (tmpPixel[0]==backgroundColorR&&tmpPixel[1]==backgroundColorG&&tmpPixel[2]==backgroundColorB&&tmpPixel[3]==backgroundColorA) { //背景颜色
            rlt = 0
        }//glClearColor(25.0/255.0, 0.0, 0.0, 0.0)
        //glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0)
        return rlt
    }
    
       
    // MARK: - GLKView and GLKViewController delegate methods
    
    func update() {
        let aspect = fabsf(Float(self.view.bounds.size.width / self.view.bounds.size.height))
        let projectionMatrix=GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0), aspect, 0.1, 100.0);
        var modelViewMatrix:GLKMatrix4=GLKMatrix4MakeTranslation(0.0, 0.0, -8.0)
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix,rotMat);
        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), nil);
        modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        var rotationAngle:GLfloat = -9.0
        //let a=6
        if round>0 {
            //if round%a==a-1{
                let i=Int(arc4random())%3
                let j=Int(arc4random())%2
                currentSlice[0] = -1
                currentSlice[1] = -1
                currentSlice[2] = -1;
                currentSlice[i] = GLint(j)
                if (i==1) {
                    rotationState = 1;
                }else if(i==0){
                    rotationState = 3;
                }else if(i==2){
                    rotationState = 5;
                }
            //}
            rotationAngle = GLfloat(0-90)//*(a-round%a)/a)   //2 1 0
            //round=round-1
        }


        //glClearColor(26.0/255.0, 0.0, 0.0, 0.0)
        glClearColor(GLfloat(backgroundColorR)/255.0,GLfloat(backgroundColorG)/255.0,GLfloat(backgroundColorB)/255.0, GLfloat(backgroundColorA)/255.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        if _isSelectMode && rotationState == ROTATE_NONE{
            //loadShaders()
            selectSlice()
            _isSelectMode=false
        }
        //_isSelectMode=true
        
        loadShaders()
        
        glUseProgram(program)
        glEnable(GLenum(GL_TEXTURE_2D))
        glEnable(GLenum(GL_BLEND))
        //let rotationAngle:GLfloat = -9.0
        
        if(rotationState == ROTATE_X_CLOCKWISE || rotationState == ROTATE_Y_CLOCKWISE || rotationState == ROTATE_Z_CLOCKWISE){
            _RotateAngle += rotationAngle;
        }else if(rotationState == ROTATE_X_ANTICLOCKWISE || rotationState == ROTATE_Y_ANTICLOCKWISE || rotationState == ROTATE_Z_ANTICLOCKWISE){
            _RotateAngle += -rotationAngle;
        }else{
            _RotateAngle = 0;
        }
        
        for i in 1...2{
            for j in 1...2{
                for k in 1...2{
                    
                    let vertices=magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].vertices
                    let textureCoords=magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].textureCoords
                    //let colors=magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].colors
                    ////////print(colors)
                    
                    glBindTexture(GLenum(GL_TEXTURE_2D),magicCube.textureArray[0])
                    
                    glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
                    glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0,vertices)
                    
                    glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
                    glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0,textureCoords)
                    
                    var rotMatrix = GLKMatrix4Identity
                    rotMatrix = magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].mmm
                    

                    
                    if (currentSlice[2]>=0 && magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].layer == currentSlice[2] ) {
                        rotMatrix = GLKMatrix4MakeRotation(_RotateAngle*3.14159265358979323846264338327950288/180.0, 0, 0, 1)
                        rotMatrix = GLKMatrix4Multiply(rotMatrix,magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].mmm)
                        if (_RotateAngle >= 90 || _RotateAngle <= -90) {
                            ////////print(_RotateAngle)
                            for m in 0 ..< 8 {
                                if (magicCube.cubes[m].layer == currentSlice[2]) {
                                    ////////print("_RotateAngle;;;;;;;;;",_RotateAngle,m)
                                    let ympMat = GLKMatrix4MakeRotation(_RotateAngle*3.14159265358979323846264338327950288/180.0, 0, 0, 1)
                                    magicCube.cubes[m].mmm = GLKMatrix4Multiply(ympMat,magicCube.cubes[m].mmm)
                                }
                            }
                            //[GameLogic RotateWith:_currentSlice[2] rotationState:_rotationState cubes:cubes];
                            Rotate(Int(currentSlice[2]),rotationState: rotationState)
                            _RotateAngle = 0;
                            currentSlice[0] = -1
                            currentSlice[1] = -1
                            currentSlice[2] = -1;
                            rotationState = ROTATE_NONE;
                        }
                        //rotMat = GLKMatrix4MakeRotation(_RotateAngle*3.1416/180.0, 0, 0, 1)
                        isReduction = checkStatus()
                    }
                    if (magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].row == currentSlice[0] && currentSlice[0]>=0) {
                        rotMatrix = GLKMatrix4MakeRotation(_RotateAngle*3.14159265358979323846264338327950288/180.0, 0, 1, 0)
                        rotMatrix = GLKMatrix4Multiply(rotMatrix,magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].mmm)
                        if (_RotateAngle >= 90 || _RotateAngle <= -90) {
                            ////////print(_RotateAngle)2
                            for m in 0 ..< 8 {
                                if (magicCube.cubes[m].row == currentSlice[0]) {
                                    let ympMat = GLKMatrix4MakeRotation(_RotateAngle*3.14159265358979323846264338327950288/180.0, 0, 1, 0)
                                    magicCube.cubes[m].mmm = GLKMatrix4Multiply(ympMat,magicCube.cubes[m].mmm)
                                }
                            }
                            Rotate(Int(currentSlice[0]),rotationState: rotationState)
                            _RotateAngle = 0;
                            currentSlice[0] = -1
                            currentSlice[1] = -1
                            currentSlice[2] = -1;
                            rotationState = ROTATE_NONE;
                        }
                        //rotMat = GLKMatrix4MakeRotation(_RotateAngle*3.1416/2.0, 0, 1, 0)
                        isReduction = checkStatus()
                    }
                    if (magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].col == currentSlice[1] && currentSlice[1]>=0) {
                        rotMatrix = GLKMatrix4MakeRotation(_RotateAngle*3.14159265358979323846264338327950288/180.0, 1, 0, 0)
                        rotMatrix = GLKMatrix4Multiply(rotMatrix,magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].mmm)
                        if (_RotateAngle >= 90 || _RotateAngle <= -90 ) {
                            //////print(_RotateAngle)
                            for m in 0 ..< 8 {
                                if (magicCube.cubes[m].col == currentSlice[1]) {
                                    let ympMat = GLKMatrix4MakeRotation(_RotateAngle*3.14159265358979323846264338327950288/180.0, 1, 0, 0)
                                    magicCube.cubes[m].mmm = GLKMatrix4Multiply(ympMat,magicCube.cubes[m].mmm)
                                }
                            }
                            Rotate(Int(currentSlice[1]),rotationState: rotationState)
                            _RotateAngle = 0;
                            currentSlice[0] = -1
                            currentSlice[1] = -1
                            currentSlice[2] = -1;
                            rotationState = ROTATE_NONE;
                        }
                        //rotMat = GLKMatrix4MakeRotation(_RotateAngle*3.1416/180.0, 1, 0, 0)
                        isReduction = checkStatus()
                    }
                    
                   
                    let tempModeviewMatrix=modelViewProjectionMatrix
                    let temp = GLKMatrix4Multiply(tempModeviewMatrix,rotMatrix)
                    modelViewProjectionMatrix = temp
                    
                    withUnsafePointer(to: &modelViewProjectionMatrix, {
                        $0.withMemoryRebound(to: Float.self, capacity: 16, {
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, $0)
                        })
                    })
//                    withUnsafePointer(to: &modelViewProjectionMatrix, {
//                        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, UnsafePointer($0))
//                    })
                    glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLsizei(24));
                    modelViewProjectionMatrix = tempModeviewMatrix
                }
            }
        }
    }
    
    func selectSlice(){
        rotationState=ROTATE_NONE
        var f1 = FACE_NONE
        var f2 = FACE_NONE
        loadShaders()
        glUseProgram(program)
        glDisable(GLenum(GL_TEXTURE_2D))
        glDisable(GLenum(GL_BLEND))
        //glClearColor(26.0/255.0, 0.0, 0.0, 0.0)
        glClearColor(GLfloat(backgroundColorR)/255.0,GLfloat(backgroundColorG)/255.0,GLfloat(backgroundColorB)/255.0, GLfloat(backgroundColorA)/255.0)
        //glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        let viewport=UnsafeMutablePointer<GLint>.allocate(capacity: 4*MemoryLayout<GLint>.size)
        glGetIntegerv(UInt32(GL_VIEWPORT), viewport)
        
        for i in 1...2{
            for j in 1...2{
                for k in 1...2{
                    
                    let vertices=magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].vertices
                    //let textureCoords=magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].textureCoords
                    let colors=magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].colors
                    ////////print(colors)
                    glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
                    glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0,vertices)
                    
                    glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue))
                    glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_UNSIGNED_BYTE), 1, 0,colors)
                    
                    var rotMatrix = GLKMatrix4Identity
                    rotMatrix = magicCube.cubes[(i-1)*2+(j-1)+(k-1)*4].mmm
                    
                    let tempModeviewMatrix=modelViewProjectionMatrix
                    let temp = GLKMatrix4Multiply(tempModeviewMatrix,rotMatrix)
                    modelViewProjectionMatrix = temp
                    
//                    withUnsafePointer(to: &modelViewProjectionMatrix, {
//                        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, UnsafePointer($0))
//                    })
                    withUnsafePointer(to: &modelViewProjectionMatrix, {
                        $0.withMemoryRebound(to: Float.self, capacity: 16, {
                            glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, $0)
                        })
                    })
//                    withUnsafePointer(&colors, {
//                        glUniformMatrix4fv(uniforms[UNIFORM_COLOR], 1, 0, UnsafePointer($0))
//                    })
                    glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLsizei(24));
                    modelViewProjectionMatrix = tempModeviewMatrix
                }
            }
        }
        let pixel=UnsafeMutablePointer<GLubyte>.allocate(capacity: 4*MemoryLayout<GLubyte>.size)
        let tmpPixel=UnsafeMutablePointer<GLubyte>.allocate(capacity: 4*MemoryLayout<GLubyte>.size)
        let x:GLint=2*GLint(point1.x)
        let y:GLint=GLint(viewport[3])-2*GLint(point1.y)
        glReadPixels(x,y,1,1,GLenum(GL_RGBA),GLenum(GL_UNSIGNED_BYTE),pixel)
        //print("pixel",pixel[0],pixel[1],pixel[2])
        var cube1:CubeOfMini?
        var cube2:CubeOfMini?
        f1=FACE_NONE
        for i in 0...7 {
            for j in 0..<92 {
                if j%16==0{
                    if magicCube.cubes[i].colors[j] == pixel[0]{
                        f1 = (GLint(pixel[0]) - 1)%6;
                        cube1 = magicCube.cubes[i]
                        break;
                    }
                }
            }
            if cube1 != nil{
                ////////print("cube1",i,cube1!.row,cube1!.col,cube1!.layer)
                break;
            }
        }
        
        if f1==FACE_NONE {
            ////////print("..........face_none")
            rotationState = ROTATE_ALL;
            currentSlice[0] = -1
            currentSlice[1] = -1
            currentSlice[2] = -1
        }
        var inc:GLint=0;
        var flag:GLint = 1;
        var nextPoint:CGPoint;
        repeat{
            nextPoint=getNextPoint(point1,point2: point2,inc: inc)
            //print("points::::::::::::::::::::::::::::",inc,flag,point1,point2,nextPoint)
            //glReadPixels(nextPoint.x,viewport[3]-nextPoint.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, tempPixelColor);
            //let pixel=UnsafeMutablePointer<GLubyte>.alloc(4*sizeof(GLubyte))
            let x:GLint=2*GLint(nextPoint.x)
            let y:GLint=GLint(viewport[3])-2*GLint(nextPoint.y)
            glReadPixels(x,y,1,1,GLenum(GL_RGBA),GLenum(GL_UNSIGNED_BYTE),tmpPixel)
            //print("tmpPixel",tmpPixel[0],tmpPixel[1],tmpPixel[2])
            inc += flag
            if (pixel[0] == tmpPixel[0]) {
                continue;
            }//pixel[2] == 0 && pixel[1] == 0 && pixel[0] == 26
            if (tmpPixel[0]==backgroundColorR&&tmpPixel[1]==backgroundColorG&&tmpPixel[2]==backgroundColorB&&tmpPixel[3]==backgroundColorA){
                if (inc>0) {
                    ////////print("ssssssss",inc,flag)
                    inc = 0;
                    flag = -1;
                }else{
                    break;
                }
            }
            f2 = FACE_NONE
            for i in 0...7 {
//                for var j=0; j<92; j+=16{
//                    if magicCube.cubes[i].colors[j] == tmpPixel[0]{
//                        //////print("pixel",tmpPixel[0],tmpPixel[1],tmpPixel[2],"+",i,j,magicCube.cubes[i].colors[j])
//                        f2 = (GLint(tmpPixel[0]) - 1)%6;
//                        cube2 = magicCube.cubes[i]
//                        break;
//                    }
//                }
                for j in 0..<92{
                    if j%16==0{
                        if magicCube.cubes[i].colors[j] == tmpPixel[0]{
                            //////print("pixel",tmpPixel[0],tmpPixel[1],tmpPixel[2],"+",i,j,magicCube.cubes[i].colors[j])
                            f2 = (GLint(tmpPixel[0]) - 1)%6;
                            cube2 = magicCube.cubes[i]
                            break;
                        }
                    }
                }
            }
            if cube2 != nil{
                ////////print("cube2",f2,cube2!.row,cube2!.col,cube2!.layer)
            }
            if (f2 != FACE_NONE) {
                ////////print(cube1!.row,cube1!.col,cube1!.layer,"__",cube2!.row,cube2!.col,cube2!.layer,"_",flag)
                checkRotationState(cube1!, face1: f1, _cube2: cube2!, face2: f2, flag: flag)
                ////////print("checkRotationState.......................",f1,f2,rotationState,currentSlice)
                break;
            }
        }while (rotationState == ROTATE_NONE)
        ////////print("rotationState.......",rotationState,currentSlice)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
    }
    
    // MARK: -  OpenGL ES 2 shader compilation
    //loadShaders()步骤：
    //1.创建程序。
    //2.创建并编译顶点着色器和片段着色器。
    //3.把 顶点着色器和片段着色器 与 程序连接起来。
    //4.设置 顶点着色器和片段着色器 的输入参数。
    //5.链接程序。
    //6.获取 uniform 指针。
    //注意：这步只能在5成功后才能调用，在linkProgrom前，uniform位置是不确定的。
    //7.断开 顶点着色器和片段着色器 ，并释放它们。
    //注意：程序并没释放。
    //
    //第4步是会变化的部分，第6步为可选。
    func loadShaders() -> Bool {
        var vertShader: GLuint = 0
        var fragShader: GLuint = 0
        var vertShaderPathname: String
        var fragShaderPathname: String
        
        //创建程序.
        program = glCreateProgram()
        
        //创建并编译顶点着色器.
        if _isSelectMode{
            vertShaderPathname = Bundle.main.path(forResource: "PickerShader", ofType: "vsh")!
            if self.compileShader(&vertShader, type: GLenum(GL_VERTEX_SHADER), file: vertShaderPathname) == false {
                ////////print("Failed to compile vertex shader")
                return false
            }
            //创建并编译片段着色器.
            fragShaderPathname = Bundle.main.path(forResource: "PickerShader", ofType: "fsh")!
            if !self.compileShader(&fragShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragShaderPathname) {
                ////////print("Failed to compile fragment shader")
                return false
            }
        }
        else{
            vertShaderPathname = Bundle.main.path(forResource: "Shader", ofType: "vsh")!
            if self.compileShader(&vertShader, type: GLenum(GL_VERTEX_SHADER), file: vertShaderPathname) == false {
                ////////print("Failed to compile vertex shader")
                return false
            }
            //创建并编译片段着色器.
            fragShaderPathname = Bundle.main.path(forResource: "Shader", ofType: "fsh")!
            if !self.compileShader(&fragShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragShaderPathname) {
                ////////print("Failed to compile fragment shader")
                return false
            }
        }
        
        
        //把顶点着色器与程序连接起来.
        glAttachShader(program, vertShader)
        //把片段着色器与程序连接起来.
        glAttachShader(program, fragShader)
        
        //设置 顶点着色器和片段着色器 的输入参数。
        //"position"和"normal"与着色器代码Shader.vsh里面的2个attribute对应，
        //分别与setupGL加载的顶点数组里面的顶点和法线数据对应起来。
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.position.rawValue), "positionShader")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.color.rawValue), "colorShader")
        
        //链接程序.
        if !self.linkProgram(program) {
            ////////print("Failed to link program: \(program)")
            
            if vertShader != 0 {
                glDeleteShader(vertShader)
                vertShader = 0
            }
            if fragShader != 0 {
                glDeleteShader(fragShader)
                fragShader = 0
            }
            if program != 0 {
                glDeleteProgram(program)
                program = 0
            }
            
            return false
        }
        
        //获取 uniform 指针.
        uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(program, "modelViewProjectionMatrixShader")
        //uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(program, "normalMatrix")
        uniforms[UNIFORM_COLOR] = glGetUniformLocation(program, "colorShader")
        
        //释放着色器
        if vertShader != 0 {
            glDetachShader(program, vertShader)
            glDeleteShader(vertShader)
        }
        if fragShader != 0 {
            glDetachShader(program, fragShader)
            glDeleteShader(fragShader)
        }
        
        return true
    }
    
    
    func compileShader(_ shader: inout GLuint, type: GLenum, file: String) -> Bool {
        var status: GLint = 0
        var source: UnsafePointer<Int8>
        do {
            source = try NSString(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue).utf8String!
        } catch {
            //////(tmpPixel[0]==backgroundColorR&&tmpPixel[1]==backgroundColorG&&tmpPixel[2]==backgroundColorB&&tmpPixel[3]==backgroundColorA)("Failed to load vertex shader")
            return false
        }
        //var castSource = UnsafePointer<GLchar>(source)
        var castSource: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(source)
        shader = glCreateShader(type)
        glShaderSource(shader, 1, &castSource, nil)
        glCompileShader(shader)
        
        //#if defined(DEBUG)
        //        var logLength: GLint = 0
        //        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        //        if logLength > 0 {
        //            var log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
        //            glGetShaderInfoLog(shader, logLength, &logLength, log)
        //            NSLog("Shader compile log: \n%s", log)
        //            free(log)
        //        }
        //#endif
        
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        if status == 0 {
            glDeleteShader(shader)
            return false
        }
        return true
    }
    
    func linkProgram(_ prog: GLuint) -> Bool {
        var status: GLint = 0
        glLinkProgram(prog)
        
        //#if defined(DEBUG)
        //        var logLength: GLint = 0
        //        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        //        if logLength > 0 {
        //            var log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
        //            glGetShaderInfoLog(shader, logLength, &logLength, log)
        //            NSLog("Shader compile log: \n%s", log)
        //            free(log)
        //        }
        //#endif
        
        glGetProgramiv(prog, GLenum(GL_LINK_STATUS), &status)
        if status == 0 {
            return false
        }
        
        return true
    }
    
    func validateProgram(_ prog: GLuint) -> Bool {
        var logLength: GLsizei = 0
        var status: GLint = 0
        
        glValidateProgram(prog)
        glGetProgramiv(prog, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            var log: [GLchar] = [GLchar](repeating: 0, count: Int(logLength))
            glGetProgramInfoLog(prog, logLength, &logLength, &log)
            ////////print("Program validate log: \n\(log)")
        }
        
        glGetProgramiv(prog, GLenum(GL_VALIDATE_STATUS), &status)
        var returnVal = true
        if status == 0 {
            returnVal = false
        }
        return returnVal
    }

    /*******************MagicCubeLogjc************************************************************************************/

    func checkRotationState( _ _cube1:CubeOfMini, face1:GLint, _cube2:CubeOfMini,face2:GLint,flag:GLint){
        var cube1=_cube1
        var cube2=_cube2
        if (flag == -1) {
            let temp = cube1;
            cube1 = cube2;
            cube2 = temp;
        }
        let row1=cube1.row
        let col1=cube1.col
        let layer1=cube1.layer
        let row2=cube2.row
        let col2=cube2.col
        let layer2=cube2.layer
        if ((row1==row2 && col1 < col2 && layer1 == layer2 && layer1 == 0 && face1 == FACE_FRONT) ||
            (row1 == row2 && col1 == col2 && layer1 < layer2 && col1 == 1 && face1 == FACE_RIGHT) ||
            (row1 == row2 && col1 > col2 && layer1 == layer2 && layer1 == 1 && face1 == FACE_BACK) ||
            (row1 == row2 && col1 == col2 && layer1 > layer2 && col1 == 0 && face1 == FACE_LEFT) ||
            (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_LEFT&&face2==FACE_FRONT)||(face1 == FACE_FRONT&&face2==FACE_RIGHT)||(face1 == FACE_RIGHT&&face2==FACE_BACK)||(face1 == FACE_BACK&&face2==FACE_LEFT))) )  {
                rotationState = ROTATE_Y_ANTICLOCKWISE;
                currentSlice[0] = row1;
                currentSlice[1] = -1;
                currentSlice[2] = -1;
        }else if ((row1 == row2 && col1 < col2 && layer1 == layer2 && layer1 == 1 && face1 == FACE_BACK) ||
            (row1 == row2 && col1 == col2 && layer1 < layer2 && col1 == 0 && face1 == FACE_LEFT) ||
            (row1 == row2 && col1 > col2 && layer1 == layer2 && layer1 == 0 && face1 == FACE_FRONT) ||
            (row1 == row2 && col1 == col2 && layer1 > layer2 && col1 == 1 && face1 == FACE_RIGHT) ||
            (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_FRONT&&face2==FACE_LEFT)||(face1 == FACE_RIGHT&&face2==FACE_FRONT)||(face1 == FACE_BACK&&face2==FACE_RIGHT)||(face1 == FACE_LEFT&&face2==FACE_BACK))))  {
                rotationState = ROTATE_Y_CLOCKWISE;
                currentSlice[0] = row1;
                currentSlice[1] = -1;
                currentSlice[2] = -1;
        }else if ((row1 == row2 && col1 == col2 && layer1 < layer2 && row1 == 0  && face1 == FACE_TOP) ||
            (row1 > row2 && col1 == col2 && layer1 == layer2 && layer1 == 0  && face1 == FACE_FRONT) ||
            (row1 < row2 && col1 == col2 && layer1 == layer2 && layer1 == 1  && face1 == FACE_BACK) ||
            (row1 == row2 && col1 == col2 && layer1 > layer2 && row1 == 1  && face1 == FACE_BOTTOM) ||
            (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_FRONT&&face2==FACE_TOP)||(face1 == FACE_TOP&&face2==FACE_BACK)||(face1 == FACE_BACK&&face2==FACE_BOTTOM)||(face1 == FACE_BOTTOM&&face2==FACE_FRONT))))  {
                rotationState = ROTATE_X_CLOCKWISE;
                currentSlice[0] = -1;
                currentSlice[1] = col1;
                currentSlice[2] = -1;
        }else if ((row1 == row2 && col1 == col2 && layer1 < layer2 && row1 == 1 && face1 == FACE_BOTTOM) ||
            (row1 > row2 && col1 == col2 && layer1 == layer2 && layer1 == 1 && face1 == FACE_BACK) ||
            (row1 < row2 && col1 == col2 && layer1 == layer2 && layer1 == 0 && face1 == FACE_FRONT) ||
            (row1 == row2 && col1 == col2 && layer1 > layer2 && row1 == 0 && face1 == FACE_TOP) ||
            (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_TOP&&face2==FACE_FRONT)||(face1 == FACE_BACK&&face2==FACE_TOP)||(face1 == FACE_BOTTOM&&face2==FACE_BACK)||(face1 == FACE_FRONT&&face2==FACE_BOTTOM))))  {
                rotationState = ROTATE_X_ANTICLOCKWISE;
                currentSlice[0] = -1;
                currentSlice[1] = col1;
                currentSlice[2] = -1;
        }else if ((row1 == row2 && col1 < col2 && layer1 == layer2 && row1 == 0 && face1 == FACE_TOP) ||
            (row1 < row2 && col1 == col2 && layer1 == layer2 && col1 == 1 && face1 == FACE_RIGHT) ||
            (row1 == row2 && col1 > col2 && layer1 == layer2 && row1 == 1 && face1 == FACE_BOTTOM) ||
            (row1 > row2 && col1 == col2 && layer1 == layer2 && col1 == 0 && face1 == FACE_LEFT) ||
            (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_TOP&&face2==FACE_RIGHT)||(face1 == FACE_RIGHT&&face2==FACE_BOTTOM)||(face1 == FACE_BOTTOM&&face2==FACE_LEFT)||(face1 == FACE_LEFT&&face2==FACE_TOP))))  {
                rotationState = ROTATE_Z_CLOCKWISE;
                currentSlice[0] = -1;
                currentSlice[1] = -1;
                currentSlice[2] = layer1;
        }else if ((row1 == row2 && col1 < col2 && layer1 == layer2 && row1 == 1 && face1 == FACE_BOTTOM) ||
            (row1 < row2 && col1 == col2 && layer1 == layer2 && col1 == 0 && face1 == FACE_LEFT) ||
            (row1 == row2 && col1 > col2 && layer1 == layer2 && row1 == 0 && face1 == FACE_TOP) ||
            (row1 > row2 && col1 == col2 && layer1 == layer2 && col1 == 1 && face1 == FACE_RIGHT) ||
            (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_RIGHT&&face2==FACE_TOP)||(face1 == FACE_TOP&&face2==FACE_LEFT)||(face1 == FACE_LEFT&&face2==FACE_BOTTOM)||(face1 == FACE_BOTTOM&&face2==FACE_RIGHT))))  {
                rotationState = ROTATE_Z_ANTICLOCKWISE;
                currentSlice[0] = -1;
                currentSlice[1] = -1;
                currentSlice[2] = layer1;
        }
    }
    
    //需要替换的方块和对应面
    func find(_ cubeIndex: Int, face: Int){
        ////////print("find...",cubeIndex,face)
        
        let _cubeIndex=GLint(cubeIndex)
        for i in 0...7{
            if magicCube.cubes[i].row*2+magicCube.cubes[i].col == _cubeIndex-magicCube.cubes[i].layer*4{
                ccc=i;
                break
            }
        }
//        for var i=0;i<92;i+=16{
//            let tmp = Int(magicCube.cubes[ccc].colors[i])-1
//            if tmp%6 == face{
//                fff = i/16
//                return;
//            }
//        }
        for i in 0 ..< 92{
            if i%16==0{
                let tmp = Int(magicCube.cubes[ccc].colors[i])-1
                if tmp%6 == face{
                    fff = i/16
                    return;
                }
            }
        }
//        for var i=0;i<92;i+=16{
//            let tmp = Int(magicCube.cubes[ccc].colors[i])
//            if tmp == 0{
//                fff = i/16
//                return;
//            }
//        }
        for i in 0 ..< 92{
            if i%16==0{
                let tmp = Int(magicCube.cubes[ccc].colors[i])
                if tmp == 0{
                    fff = i/16
                    return;
                }
            }
        }
    }
    
    //调整pickerColor和row,col,layer参数
    func changeColors(_ gap: Int){

        var temp = [GLubyte](repeating: 0, count: 16)
        var tempqueue = [Int](repeating: 0, count: 32)
        
        //        var tempccc=0
        //        var tempfff=0
        for _i in 0..<4{
            let i = _i*8
            find(squence[i]+gap, face: squence[i+1])
            ////////print("yunyyyun1..",i,"...",ccc,fff)
            tempqueue[i]=ccc
            tempqueue[i+1]=fff*16
            
            find(squence[i+2]+gap, face: squence[i+3])
            ////////print("yunyyyun2..",i,"...",ccc,fff)
            tempqueue[i+2]=ccc
            tempqueue[i+3]=fff*16
            
            find(squence[i+4]+gap, face: squence[i+5])
            ////////print("yunyyyun3..",i,"...",ccc,fff)
            tempqueue[i+4]=ccc
            tempqueue[i+5]=fff*16
            
            find(squence[i+6]+gap, face: squence[i+7])
           // //////print("yunyyyun4..",i,"...",ccc,fff)
            tempqueue[i+6]=ccc
            tempqueue[i+7]=fff*16
            
        }
        
        for _ii in 0..<4{
            let ii = _ii*8
            for i in 0 ..< 16 {
                temp[i] = magicCube.cubes[tempqueue[ii]].colors[tempqueue[ii+1]+i]//color2[temp2+i];
            }
            for i in 0 ..< 16 {
                magicCube.cubes[tempqueue[ii]].colors[tempqueue[ii+1]+i] = magicCube.cubes[tempqueue[ii+2]].colors[tempqueue[ii+3]+i]//color2[temp2+i];
            }
            for i in 0 ..< 16 {
                magicCube.cubes[tempqueue[ii+2]].colors[tempqueue[ii+3]+i] = magicCube.cubes[tempqueue[ii+4]].colors[tempqueue[ii+5]+i]//color2[temp2+i];
            }
            for i in 0 ..< 16 {
                magicCube.cubes[tempqueue[ii+4]].colors[tempqueue[ii+5]+i] = magicCube.cubes[tempqueue[ii+6]].colors[tempqueue[ii+7]+i]//color2[temp2+i];
            }
            for i in 0 ..< 16 {
                magicCube.cubes[tempqueue[ii+6]].colors[tempqueue[ii+7]+i] = temp[i]//color2[temp2+i];
            }
        }
        var tr:GLint=0
        var tc:GLint=0
        var tl:GLint=0
        var c1=0
        var c2=0
        var c3=0
        var c4=0
        for _i in 0..<1 {
            let i = _i*8
            find(squence[i]+gap, face: squence[i+1])
            ////////print("yunyyyun111111(i).....",i,"(i)",ccc,fff)
            c1=ccc
            
            find(squence[i+2]+gap, face: squence[i+3])
           // //////print("yunyyyun22222(i).....",i,"(i)",ccc,fff)
            c2=ccc
            
            find(squence[i+4]+gap, face: squence[i+5])
            ////////print("yunyyyun333333(i).....",i,"(i)",ccc,fff)
            c3=ccc
            
            find(squence[i+6]+gap, face: squence[i+7])
            ////////print("yunyyyun444444(i).....",i,"(i)",ccc,fff)
            c4=ccc
            
            tr = magicCube.cubes[c1].row;
            tc = magicCube.cubes[c1].col;
            tl = magicCube.cubes[c1].layer;
            
            magicCube.cubes[c1].row = magicCube.cubes[c2].row;
            magicCube.cubes[c1].col = magicCube.cubes[c2].col;
            magicCube.cubes[c1].layer = magicCube.cubes[c2].layer;
            
            magicCube.cubes[c2].row = magicCube.cubes[c3].row;
            magicCube.cubes[c2].col = magicCube.cubes[c3].col;
            magicCube.cubes[c2].layer = magicCube.cubes[c3].layer;
            
            magicCube.cubes[c3].row = magicCube.cubes[c4].row;
            magicCube.cubes[c3].col = magicCube.cubes[c4].col;
            magicCube.cubes[c3].layer = magicCube.cubes[c4].layer;
            
            magicCube.cubes[c4].row=tr;
            magicCube.cubes[c4].col=tc;
            magicCube.cubes[c4].layer=tl;
            
        }
    }
    
    //层转替换数据
    func Rotate(_ rcl: Int,rotationState:Int){
        //return
        if (rotationState ==  ROTATE_Z_ANTICLOCKWISE) {
            let _squence:[Int] = [//1,5,3,3,7,4,5,1,
                0,3,2,4,3,1,1,5,
                0,5,2,3,3,4,1,1,
                0,0,2,0,3,0,1,0,
                //1,0,3,0,7,0,5,0,
                0,2,2,2,3,2,1,2,
                //1,2,3,2,7,2,5,2
            ]
            squence = _squence
            //////print("ROTATE_Z_ANTICLOCKWISE",rcl)
            changeColors(rcl*4);
        }else if(rotationState == ROTATE_Z_CLOCKWISE ){
            let _squence:[Int] = [//1,5,5,1,7,4,3,3,
                0,3,1,5,3,1,2,4,
                0,5,1,1,3,4,2,3,
                0,0,1,0,3,0,2,0,
                //1,0,5,0,7,0,3,0,
                0,2,1,2,3,2,2,2,
                //1,2,5,2,7,2,3,2
            ]
            squence = _squence
            //////print("ROTATE_Z_CLOCKWISE",rcl)
            changeColors(rcl*4);
        }else if (rotationState == ROTATE_Y_ANTICLOCKWISE ) {
            let _squence:[Int] = [//1,0,11,1,19,2,9,3,
                0,3,1,0,5,1,4,2,
                0,0,1,1,5,2,4,3,
                //1,5,11,5,19,5,9,5,
                0,5,1,5,5,5,4,5,
                //1,4,11,4,19,4,9,4,
                0,4,1,4,5,4,4,4]
            squence = _squence
            //////print("ROTATE_Y_ANTICLOCKWISE",rcl)
          
            changeColors(rcl*2);
          
        }else if(rotationState == ROTATE_Y_CLOCKWISE ){
            let _squence:[Int] = [//1,0,9,3,19,2,11,1,
                0,3,4,2,5,1,1,0,
                0,0,4,3,5,2,1,1,
                //1,5,9,5,19,5,11,5,
                0,5,4,5,5,5,1,5,
                //1,4,9,4,19,4,11,4,
                0,4,4,4,5,4,1,4]
            squence = _squence
            //////print("ROTATE_Y_CLOCKWISE",rcl)
            changeColors(rcl*2);
        }else if (rotationState == ROTATE_X_ANTICLOCKWISE) {
            let _squence:[Int] = [//9,5,3,0,15,4,21,2,
                2,4,6,2,4,5,0,0,
                2,0,6,4,4,2,0,5,
                //3,3,15,3,21,3,9,3,
                0,3,2,3,6,3,4,3,
                //3,1,15,1,21,1,9,1,
                0,1,2,1,6,1,4,1]
            squence = _squence
            //////print("ROTATE_X_ANTICLOCKWISE",rcl)
            changeColors(rcl);
        }else if(rotationState == ROTATE_X_CLOCKWISE ){
            let _squence:[Int] = [//9,5,21,2,15,4,3,0,
                0,0,4,5,6,2,2,4,
                0,5,4,2,6,4,2,0,
                //3,3,9,3,21,3,15,3,
                0,3,4,3,6,3,2,3,
                //3,1,9,1,21,1,15,1,
                0,1,4,1,6,1,2,1]
            squence = _squence
            //////print("ROTATE_X_CLOCKWISE",rcl)
            changeColors(rcl);
        }
        if round<=0 {
            steps+=1
            if timer==nil {
                totalMicrosecond=1
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(MiniCubeViewController.tick(_:)), userInfo: nil, repeats: true)
            }
        }else {
            if round==1{
                totalMicrosecond=0
                steps=0
            }
            round-=1
        }
    }
    
    func resetCube(){
        magicCube.initMagicCube(0)
    }
    
    func tick(_ paramTimer: Timer){
        if isReduction%10==0 {
            totalMicrosecond+=1
        }
    }
    /********************************************************************************************************/
}
