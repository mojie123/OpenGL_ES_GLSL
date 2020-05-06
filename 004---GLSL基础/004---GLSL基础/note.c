/*
 openGL ES 3中变量修饰符（uniform,attribute,varying）
 1.uniform
    1).uniform 变量。修饰符
        外部(客户端，OC/swift/C --> CPU来帮你解决问题)，传递vertext 和 fragment
        A.客户端提供非常多接口。glUniform**  提供赋值功能
        B.类似于const 被uniform 修饰变量就在顶点、片元着色器就只能用不能修改
        一般变换矩阵
        uniform mate4 viewP;//
 2.attribute 修饰符
 只能在顶点着色器使用
 attribute vec4 pj;
 
 3.varying  中间传递(顶点 片元 之间传递)
    1).顶点着色器
        attribute vec4 tj;
        varting  vec4 pj;
        void main(){
            pj = tj;
        }
    2).片元着色器
        varting  vec4 pj;
 */
