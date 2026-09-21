---
layout: page
title:  "图元"
author: mosfet
category: math
tags: 数学
---

本文(#267710)按理说应该属于标准，但因为需要经常查询、参考和修改不作为标准。  

关于现有资料的图元的信息整合分布：  
1 光线追踪中，相交测试的内容也出现了一些图形。  
2 渲染领域中，通常称呼它们为曲线，仅有terms一文进行提要，并且那边已将这些概念进行抽象而不涉及具体内容，因此可分离。  
3 而在曲线一文，是对参数近似曲线进行了详细的研究，暂时也不冲突，对于各种形式最终可能都混合在这里。  

## REFs
```
https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/dot-cross-products/v/defining-a-plane-in-r3-with-a-point-and-normal-vector
https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/dot-cross-products/v/normal-vector-from-plane-equation
https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/dot-cross-products/v/point-distance-to-plane
https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/dot-cross-products/v/distance-between-planes
https://www.khanacademy.org/math/linear-algebra/vectors-and-spaces/null-column-space/v/visualizing-a-column-space-as-a-plane-in-r3
```

## 线
```ruby
# linear
y = cx => Ax+By=0
```

根据欧几里得，直线由两个端点（位置）确定。当然，一个点(位置)加斜度、斜度加上截距(间接给出了一个位置)各种各样的方式都可以确定直线。  
我们将隐式点集记为`[xy]`，已知的值记为`[x1y1]、m、i`等。  

①standard `Ax+By+C=0`；一般隐式形式；  
②s-i `y = mx+i`；斜度+截距(间接点)  
③p-s `(y-y1)/(x-x1) = m`；单点+斜度；  
④2p `(y-y1/x-x1)/(y2-y1/x2-x1)`；两点式；这可以视为两组相同斜度的计算。  

最后，平行线斜度相同。正交线互为相反倒数(opposite reciprocal)。互换底高。  

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

**计算点P与平面的距离**  
找一个平面点，再假设P连接垂线构成三角形，用余弦算。  
