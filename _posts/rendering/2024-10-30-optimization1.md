---
layout: page
title:  "GI优化技术"
author: mosfet
category: rendering
tags: 全局照明 优化
---

本文需要更新。  

## 辐射度——解析篇
辐射度基础中的一些未能解释的细节以及错误在这里说明，这些缺失在实践中被证明很重要，目前暂时也在本文进行补充。  
笔者习惯上避免重复解释前提知识。本节是一种例外，蒙特卡洛方法的证明链接相当复杂，以至于我需要单独写一个快速回顾的版本，而省去阅读基础的大量时间。
若您现在脑海中还很熟悉它们，请轻松跳过本节。  

#### review

#### 辐射强度
`辐射强度(radiant intensity)`的定义是`I(σ) = ΔΦ/Δσ`，等于立体角上的光谱功率。在这里是一个不常用的术语。  

#### CDF
`cumulative pdf`指PDF的积分累积函数(累积单位概率)，通常用大`P(x)`表示。  

#### CDF逆方法选择事件
可以均匀地划分CDF的域，如每隔1/10，并检查每段概率的累积情况。  
考虑一个均匀随机数`r = rand()`落在CDF的像上，求反找出划分的域在哪里，并且进行插值近似。  
表达式上这是`select_domain = CDF^-1(r)`，这称为逆方法。  

#### 二分方法选择事件
递归求解CDF相等(50%)的地方，停留在合理的深度。然后递归依次产生r检查(>0.5)，选择一侧区域，并在该最小的细分区域随机均匀生成一个样本。  
对于复杂曲线，求解CDF中点可以使用数值估计完成任务。  

---
#### 补充
选择"自然"的度量可能是棘手的部分(14.1.2)：子度量`du = dadbdc...`的点集不应该随着该测量单位的空间系变换而改变结果。  

**(14.4)function inversion, rejection, and Metropolis**  
在不寻常空间(如极空间)的线性(取相同大小)测量形状可能不同，具体取决于位置，尽管这种环扇形片段的半径相同，但在远处的dθ具有更多周长！  
```ruby
# 5-31
#     外周长 环间距
du ~= rdθ * dr 

A = ∫∫ΘR|(rdr)dΘ = 0..1|r²/2 * [2Pi] = Pi
p(r, θ) = r/Pi # 证明有点复杂，涉及某种矩阵转换 应该使用结论
p(r, θ) = p(r)p(θ)

p(θ) = 1/2PI P^-1 = 2PIξ1
p(r) = r2r   P^-1 = sqrt(ξ2) # *R  ?
```
拒绝方法：圆内点，单位方向等(14.4.2, 5-34 etc)。  

**Marginal Density Functions(14.4)**  
```ruby
# 5-41
# sampling triangle?
ξ1a + ξ2b + ori reflect if 1-ξ1ξ2 < 0
```
更好，`边缘密度函数(marginal density functions)`。  
```ruby
p(x)   = ∫p(x,y)dy  # marginal  DF
p(y|x) = p(x,y)/p(x)# condition DF
# check examples in 5-43!
```

---
## 参考1
熟悉[《Ray Tracing: The Rest of Your Life》](https://raytracing.github.io/books/RayTracingTheRestOfYourLife.html)这本书的读者可能记得Peter Shirley列举了几种重要性采样的实践，如朗伯的处理。除此之外第六章开始的方法似乎也不寻常，如果您理解了全局光照的问题，则可以理解各种方法的合理性。我在这里再次强调理解问题本身更重要，而不是推崇某种解决方案，读者需要自己理解可行性并决定自己的使用偏好。  
若不清楚选择PDF以及采样行为对结果的不同影响，请见光线追踪一文。  

朗伯体的常数反射率告诉我们它本质是一个公平的光源。  
这不影响渲染方程，剩下的投影效应引入了光照衰减，积分的形状带有cos项，为了找出更匹配该形状的PDF，  
我们推导：  
```ruby
EST = [R/PI Licos dvi] / ?p
∫hs|Ccosdu = 1 thus C = 1/Pi thus pdf = cosvi / Pi
EST = Li * R
```
注意，为了匹配PDF，您的样本(反射方向)必须按照该分布产生。  

<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item3-lg item12 pd0">
      <img src="/assets/i/4-1.png">
    </div>
  </div>
  <p>图1：结果(也许会更新)</p>
</div>

第七章研究了遵循PDF在半球上生成对应分布方向的方法，利用一个非平行表面N的向量取两次Cross构成子空间系可以从任何表面参考发送此类随机数。  
第十章开头编写了PDF类，一是生成遵循了PDF的随机方向，二为查询特定结果的密度。这两者分别用于弹射dvi以及计算/pvi。  
对于灯光(或任何需要直接采样的东西)的PDF，则单独为其几何表面编写采样随机样本和pdf。  

混合密度方法使用以下公式：  
```ruby
pMix = w0p0 + w1p1 + ……
     #  ΣW = 1
# say
pM1 = 0.5pCos =+ 0.5pLight
```
正确使用的方式是，方向根据产生一个ξ并根据w的比重来随机选择一个即可。PDF的值由该具体方向询问两个PDF并进行W的配重混合得到。  
但我们的估值器是什么呢？"不想用阴影光线来解决任何给定点的直接照明问题，只使用向光源发送更多光线。"在这里是有道理的。  
因此只是渲染方程，这里有个微妙的细节，为了最后一项，在计算灯光时，`pdf2 = r²/cos/A`，而不是`1/A`。  