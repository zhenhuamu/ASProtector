# ASProtector

1、目前

利用Objective-C语言的动态特性，采用AOP(Aspect Oriented Programming) 面向切面编程的设计思想，做到无痕植入。在App运行时Crash自动修复，降低app的crash率。

2、功能

Container crash

NSString crash

unrecognized selector crash

KVO crash

KVC crash

3、原理

unrecognized selector crash 

在forwardingTargetForSelector阶段进行消息转发给创建的桩类

KVO Crash

基于hook进行对于观察者，使用NSHashTable保持keyPath和observer的关系，然后利用Proxy进行分发（原理和FBKVOController大体一致，只不过利用hook自动处理添加observer和释放observer）

Container crash 

针对于NSArray／NSMutableArray／NSDictionary／NSMutableDictionary的一些常用的会导致崩溃的API进行method swizzling，然后在swizzle的新方法中加入一些条件限制和判断，从而让这些API变的安全。

NSString crash

NSString／NSMutableString类型的crash的产生原因和防护方案与Container crash大体一致。

KVC crash

和Container crash的防护类似，外加一些异常之后调用的API









