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