---
layout: page
title:  "03calculusExt"
author: mosfet
category: math
tags: academic hidden 微积分
---

注意本文属于数学核心标准(**academic**字样)的沿续。  

---
```
Differential Calculus     不在本文范围
Integral Calculus         u2
Multivariable calculus    不在本文范围
```

## 表达式快速参考
```
```

## IC3. 应用
**不当积分(improper integrals)**  
如果不当积分存在，那么说它是`聚集的(convergent)`，否则是`散化的(divergent)`。如果无限远积分面积缩小那么它最后可能是聚集的，有限积分也不保证一定聚集，无界渐近显然会散化。求解双端无限远时，我们将它以原点分开。  
```ruby
AD ∫1/x^2 dx = -1/x
∫1..INF|1/x^2 dx = AD(INF)-AD(1) = 1
```

#### 差分方程(differential equations)
差分方程将多个微斜度(包括高次)联系到等式中，通常变量是某种函数`f(x)`！我们可以检验给定函数是否为差分方程的解。  
```ruby
D^2(fx) + Dfx = 3fx
```
类似`dy/dx = -x/y`的差分方程产生某种`斜度场(slope fields)`，它们就像网格点上的隐式旋转信标，通过`x=1 && y =1`来检查方程在此处定义的斜度。如果我们沿着一些斜度拟合曲线，可以找到斜度场中的一些解，我们还说初始位置是`初始条件(initial condition)`。如果我们从初始条件开始以小步进行迭代寻找一条数值上满足差分方程的曲线，这称为`欧拉方法(Euler's method)`。  
**变量分离(separation of variables)**  
如果等式可被分离为单一变量和其差异量同侧的形式，这就是所谓的可分离差分方程。这种代数方法不对所有方程有效。  
```ruby
dy/dx = -x / ye^(x^2) && init[0,1]
ydy = -xe^(-x^2)dx
  ∫ = ∫
y^2/2 + c1 = 1/2 e^-x^2 + c2
           = c          # 验证init并给出常数项
       y^2 = e^-x^2
         y = e^(-x^2/2) # 验证init并去掉负数根
```
一些特解的解决方法。
```ruby
f(7) =40+5e^7
Dfx  =5e^x
fx = ∫... = 5e^x + C
# eval f(7) to find C, and answer f(0)
```
exponential models、logistic equations略。  

#### 审视积分
我们有两种方法重新审视积分，第一是重新查看它的初始几何定义来搜索新的用途；第二者是通过上述一系列推论得到的复杂关系，积分速率等于被引发量(见第二定理)。标准说法是，速率给出`累积/净余变化量(accumulation/net change)`。  

**引发量**  
最常见的引发量可能是位置数值，因此速率积分表示位移量(displacement)。正积分给出正向位移，反之亦然。如果我们考虑总旅行距离，则不应该将符号区域抵消，这给出`∫a..b|abs(f(t))dt`。对于给定加速度，一次积分给出速率，二次积分给出位置。  
**曲线间面积**  
```ruby
f(x) > g(x)
∫f - ∫g = ∫a..b|(fx-gx)dx # 如果有更多曲线，请以它们的交点作为界限分别处理积分
```
**水平面积**  
为什么不能将`x y`进行调换来计算垂直面积？所以这个过程基本上就是在进行转换！该细分单元为`dy * (x = f(y))`。  
```ruby
x = 15/y
∫a..b|15/y dy
```
**交叉截面体积(cross sections Volume)**  
`∫a..b|f(t)^2dt`中尽管这个曲线值仍然应该被视为矩形高度，但甚至可以展开为二维数据(分配相同值`f(t)`)，细分体积单元`dx * ft*ft`为积分提供了更广泛的抽象含义。进一步还可以同时选择`x,y`来决定截面，深度只是`dx、dy`任意一个，这取决于绕哪个轴截取。它还可以是三角形或半圆形。  
**圆盘方法(disc method)**  
圆盘也是对曲线值的一种变形，旋转矩形高度得到的细分单元实际上是一个薄片。其实很容易得到酒杯的形状。  
同理，如果使用圆环面积，则称为`垫圈方法(washer method)`。  
进一步的，我们可以采取一些策略绕任意线进行旋转。  
**弧(arc)的长度**  
```ruby
∫ds = ∫sqrt(dy^2+dx^2) 
    = ∫sqrt(dx^2(1+dy/dx)^2)
    = ∫sqrt(1+Dfx^2)dx
```
积分参数方程。  
**参数弧的长度**  
```ruby
p(t) = [cos(t), sin(t)]

dx = dx/dt *dt = Dx(t)dt
dy = dy/dt *dt = Dy(t)dt
∫0..1/2PI|ds = ∫..|sqrt(Dxt^2+Dyt^2)dt = PI/2 # 四分之一单位圆弧
```

---
## 通用翻译
```
不当积分|improper integrals
聚集|convergent
散化|divergent
```

---
## 关于清单
```
```