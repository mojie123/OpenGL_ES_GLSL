//
//  CCView.m
//  004---GLSL基础
//
//  Created by 小siri on 2020/5/5.
//  Copyright © 2020 小siri. All rights reserved.
//

#import "CCView.h"
#import <OpenGLES/ES2/gl.h>
@interface CCView()

@property (nonatomic, strong) CAEAGLLayer *myEagLayer;
/**   **/
@property (nonatomic, strong) EAGLContext *myContext;
/**   **/
@property (nonatomic, assign) GLuint myColorRenderBuffer;
/**   **/
@property (nonatomic, assign) GLuint myColorFrameBuffer;
@property (nonatomic, assign) GLuint myPrograme;

@end
@implementation CCView
/*
 思路
 1、创建图层
 2、创建上下文
 3、清空缓存区
 4、设置RenderBuffer
 5、设置FrameBuffer
 6、开始绘制
 */
-(void)layoutSubviews{
      //1.设置图层
      [self setupLayer];
      
      //2.设置图形上下文
      [self setupContext];
      
      //3.清空缓存区
      [self deleteRenderAndFrameBuffer];

      //4.设置RenderBuffer
      [self setupRenderBuffer];
      
      //5.设置FrameBuffer
      [self setupFrameBuffer];
      
      //6.开始绘制
      [self renderLayer];
}
 

-(void)setupLayer{
    self.myEagLayer = (CAEAGLLayer*)self.layer;
    //设置scale
    [self setContentScaleFactor:[[UIScreen mainScreen]scale]];
    //描述属性
    /*
     kEAGLDrawablePropertyColorFormat
     kEAGLDrawablePropertyRetainedBacking:绘图完之后要不要保留状态
     */
    self.myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@false,kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    
}
+(Class)layerClass{
    return [CAEAGLLayer class];
}
//设置上下问
-(void)setupContext{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:api];
    if (!context) {
        NSLog(@"context 失败");
        return;
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"设置context失败");
        return;
    }
    self.myContext = context;
}
//清空缓存区
-(void)deleteRenderAndFrameBuffer{
    //使用之前清空帧缓冲区：RenderBuffer FrameBUffer
    glDeleteBuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
    glDeleteBuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
}
//设置renderBuffer
-(void)setupRenderBuffer{
    //定义缓冲区ID
    GLuint buffer;
    //申请标识符
    glGenBuffers(1, &buffer);
    self.myColorRenderBuffer = buffer;
    //绑定 渲染缓冲区
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    //将可绘制对象CAEAGLayer 绑定 myColorRenderBuffer
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
    
}
//设置frameBuffer
-(void)setupFrameBuffer{
    GLuint buffer;
    glGenBuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    //生成帧缓存区，将渲染缓存和帧缓存区绑定在一起
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
}
//开始绘制
-(void)renderLayer{
    //设置清屏颜色
       glClearColor(0.3f, 0.45f, 0.5f, 1.0f);
       //清除屏幕
       glClear(GL_COLOR_BUFFER_BIT);
       
       //1.设置视口大小
       CGFloat scale = [[UIScreen mainScreen]scale];
       glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
       
       //2.读取顶点着色程序、片元着色程序
       NSString *vertFile = [[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"vsh"];
       NSString *fragFile = [[NSBundle mainBundle]pathForResource:@"shaderf" ofType:@"fsh"];
       //3.加载shader
       self.myPrograme = [self loadShaders:vertFile Withfrag:fragFile];
       
       //4.链接
       glLinkProgram(self.myPrograme);
       GLint linkStatus;
       //获取链接状态
       glGetProgramiv(self.myPrograme, GL_LINK_STATUS, &linkStatus);
    
       if (linkStatus == GL_FALSE) {
           GLchar message[512];
           glGetProgramInfoLog(self.myPrograme, sizeof(message), 0, &message[0]);
           NSString *messageString = [NSString stringWithUTF8String:message];
           NSLog(@"Program Link Error:%@",messageString);
           return;
       }
       
       NSLog(@"Program Link Success!");
       //5.使用program
       glUseProgram(self.myPrograme);
       
       //6.设置顶点、纹理坐标
       //前3个是顶点坐标，后2个是纹理坐标
       GLfloat attrArr[] =
       {
           0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
           -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
           -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
           
           0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
           -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
           0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
       };
       
       
       //7.-----处理顶点数据--------
       //(1)顶点缓存区
       GLuint attrBuffer;
       //(2)申请一个缓存区标识符
       glGenBuffers(1, &attrBuffer);
       //(3)将attrBuffer绑定到GL_ARRAY_BUFFER标识符上
       glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
       //(4)把顶点数据从CPU内存复制到GPU上
       glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);

       //8.将顶点数据通过myPrograme中的传递到顶点着色程序的position
       //1.glGetAttribLocation,用来获取vertex attribute的入口的.
       //2.告诉OpenGL ES,通过glEnableVertexAttribArray，
       //3.最后数据是通过glVertexAttribPointer传递过去的。
       
       //(1)注意：第二参数字符串必须和shaderv.vsh中的输入变量：position保持一致
       GLuint position = glGetAttribLocation(self.myPrograme, "position");
       
       //(2).设置合适的格式从buffer里面读取数据
       glEnableVertexAttribArray(position);
       
       //(3).设置读取方式
       //参数1：index,顶点数据的索引
       //参数2：size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
       //参数3：type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
       //参数4：normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
       //参数5：stride,连续顶点属性之间的偏移量，默认为0；
       //参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
       glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
       
       
       //9.----处理纹理数据-------
       //(1).glGetAttribLocation,用来获取vertex attribute的入口的.
       //注意：第二参数字符串必须和shaderv.vsh中的输入变量：textCoordinate保持一致
       GLuint textCoor = glGetAttribLocation(self.myPrograme, "textCoordinate");
       
       //(2).设置合适的格式从buffer里面读取数据
       glEnableVertexAttribArray(textCoor);
       //(3).设置读取方式
       //参数1：index,顶点数据的索引
       //参数2：size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
       //参数3：type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
       //参数4：normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
       //参数5：stride,连续顶点属性之间的偏移量，默认为0；
       //参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
       glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL + 3);
       
       //10.加载纹理
       [self setupTexture:@"kunkun"];
       
       //11. 设置纹理采样器 sampler2D
       glUniform1i(glGetUniformLocation(self.myPrograme, "colorMap"), 0);
       
       //12.绘图
       glDrawArrays(GL_TRIANGLES, 0, 6);
       
       //13.从渲染缓存区显示到屏幕上
       [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
       
}
// 从图片中加载纹理
-(GLuint)setupTexture:(NSString*)fileName{
    /*
     1、解压图片
     2、绑定纹理
     3、设置纹理参数
     4、加载纹理
     */
    //1.解压缩
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"图片为空");
        exit(1);
    }
    //图片本身宽高
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    //图片大小
    GLubyte *spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));// * 4是因为RGBA
    //创建上下文
    /*
     参数1 ：data,指定要渲染的绘制图像内存地址
     参数2 ：width，bitmap 的宽度，单位为像素
     参数3 ：height，bitmap 的高度，单位为像素
     参数4 ：bitsPerComponent 内存中像素的每个组件位数，比如32位RGBA，就设置为8
     参数5 ：bytesPerRow ，bitmap的每一行内存所占比特(bit 字节)数
     参数6 ：space ，bitmap上使用的颜色空间，
     参数7 ：bitmapInfo 颜色信息  kCGImageAlphaPremultipliedLast:RGBA
     */
    //解压缩
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8 , width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    //5.绘制图片
    CGRect rect = CGRectMake(0,0, width, height);
    //6
    CGContextDrawImage(spriteContext, rect, spriteImage);
    
    //7.释放
    CGContextRelease(spriteContext);
    //8 - 绑定纹理
    glBindTexture(GL_TEXTURE_2D, 0);
    //9 - 设置纹理属性 - 环绕
    /*
     放大过滤
     缩小过滤
     环绕(s,t)
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //10.加载纹理
    float fw = width,fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    //释放
    free(spriteData);
    return 0;
    
}
#pragma mark - shader 链接
-(GLuint)loadShaders:(NSString*)vert Withfrag:(NSString*)frag{
    GLuint verShader,fragShader;
    GLuint program = glCreateProgram();
    //编译
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    //着色器连接到program
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    //连接之后需要删除
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}
#pragma mark - shader 编译
-(void)compileShader:(GLuint*)shader type:(GLenum)type file:(NSString*)file{
    //1。读取文件路径 字符串
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar*)[content UTF8String];
    //2、创建着色器 - 需要指定是顶点着色器还是片元着色器
    *shader = glCreateShader(type);
    /*
     3、着色器 代码 -> 附着到 着色器上面
     参数1：shader 要编译的着色器对象 *shader
     参数2：numberOfString 传递的源码字符串数量 1个
     参数3：strings,着色器程序的源码(真正的着色器程序源码)
     参数4：lenOfStrings,长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
     */
    glShaderSource(*shader, 1, &source, NULL);//1 传的是1个source
    //4.着色器源码编译成目标代码
    glCompileShader(*shader);
    
    
    
}
@end
