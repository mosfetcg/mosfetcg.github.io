---
layout: page
title:  "图元"
author: mosfet
category: math
tags: 数学
---

<style>code{color:#267710}nav a{color:#267710!important}</style>

本文暂不归入ACA标准，因为需要经常查询、参考和修改，但其重要程度不相上下。  
这里我们会推导所有图元的表达。  

## REFs
```
https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/dot-cross-products/v/defining-a-plane-in-r3-with-a-point-and-normal-vector
https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/dot-cross-products/v/normal-vector-from-plane-equation
https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/dot-cross-products/v/point-distance-to-plane
https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/dot-cross-products/v/distance-between-planes
https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/null-column-space/v/visualizing-a-column-space-as-a-plane-in-r3
关于现有资料的图元的信息整合分布：  
1 光线追踪中，相交测试的内容也出现了一些图形。  
3 而在曲线一文，是对参数近似曲线进行了详细的研究，暂时也不冲突，对于各种形式最终可能都混合在这里。  
```

## 杂项
#### 隐式等值区和梯度
`▼`现在推断。查看▽v-f的定义，如果您沿着与梯度方向垂直的方向走，速率为0。因为梯度自然存在，那么其不动的左右侧区域也存在，进而形成复杂的形状。  
在隐式方程中，不动区域通常是f=C构成区域，如果我们取其一段，则与梯度垂直！换句话说，反过来梯度与其垂直。  
这种思想还可以推导三维梯度必定垂直于f(p)=C曲面。  

## 直线
因为是简单的二元线性关系，隐式方程是：  
```ruby
y = kx => Ax+By+C = 0
```

其他给定形式不常用。  
给定两点，方程为(y-y1/x-x1)=(y2-y1/x2-x1)化简为：(y0-y1)x+(x1-x0)y+x0y1-x1y0=0。  

#### 点距离和垂足
如前所述，▽ = (A,B)必然垂直线。给定点等于直线上的某点p0+kn = p。距离就是kn的大小。  
为了避免计算p0，简化为d = f(p)/sqrt(A²+B²)

一种方式是将直线视为向量，以及点P到直线定点的向量，算出其垂线。  

## 平面
```ruby
dot(n, X-P) = 0 => Ax+By+Cz=D
     #v_plane 至少需要平面一点P和法线N

# 拆解dot即标准形式
# 如n1x、n2y的部分说明了法线的分量。而减号部分会将P隐藏，造成常量总计：
D = -N·P

# 下式给出了如果平面进行平移经过原点的距离，注意任意X本身对原点的距离都不同，在平移距离d时X到达不同的点。  
# 换句话说，沿着N进行平移。
d =  D / len(N)

if norm, sdf = dot(N, Q)+D

# intersection on line, eval sdf = 0 with Q = P(t)
```

#### 点距离 
找一个平面点，再假设P连接垂线构成三角形，用余弦算。  
