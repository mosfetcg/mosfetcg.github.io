---
layout: page
title:  "综合"
author: mosfet
category: raytracing
tags:
---

---
# 相关计算
## 平行光
```ruby
Li(ω) = Lδ(ω-ωlight)
Lo(p,ωo) = ∫H²|fr(p,ωlight->ωo)Lδ(ω-ωlight)cosθidωi
         = fr(p,ωlight->ωo)LV(p,wlight)cosθlight
```

## 圆锥球光源采样
待整理！同时检查10.20。  

<!-- ```ruby
dist = len(c-x)
sinα = R/d or cosα = sqrt(1 - sinα²)  # α最大半边角度 α = asin/ acos

q = 1/ 2Pi(1-cosα)                    # 均匀密度
cosθ = 1-ξ1+ξ1cosα                    # 确定后，可知uvw中的采样位置
   φ = 2PIξ2
q = p(x2)cosθ2 / len(x, x2)           # 球面上的点
p(x2) = cosθ2 / 2PIlen(x,x2)(1-cosα)
``` -->

下图显示了不对球正面进行重要性采样的方差差别。  
视线立体角区域的立体角采样通常方差都更小。  
<div class="x gr txac">
  <div class="x la flex mg0 mgb3">
    <div class="x la item3-md item6">
      <img src="/assets/m/pt1-19.png">
    </div>
    <div class="x la item3-md item6">
      <img src="/assets/m/pt1-26.png">
    </div>
  </div>
</div>

## 显示方差
根据方差公式以及估值器，我们可以设计一种debug程序来检查方差值。而且对应场景！
```ruby
V(x) = EST(x²)-EST(x)²
```

减小单样本方差是有代价的。如果为了p去贴合f，但计算一根光线的时间（Cost）翻了100倍。最终相乘，效率可能反而下降了。  

## 环境贴图光源采样
需要辐射度图作为辐射度，亮度图作为PDF(u,v)。亮度是RGB的一个固定点积。  
11.14推导了一个条件采样的逆。第一步是选择横轴总密度更高的纵坐标v，再在v条件下抽样u。  

因为PDF与亮度相似，方差更小。  

<div class="x gr txac">
  <div class="x la flex mg0 mgb2">
    <div class="x la item5-md item6">
      <img src="/assets/m/pt1-21.png">
    </div>
    <div class="x la item5-md item6">
      <img src="/assets/m/pt1-20.png">
    </div>
  </div>
</div>

## MIS
一种重要性采样策略通常只能解决单一方差来源问题。这里我们为了简单，f/p的大方差(p在某些地方与f不太相同！)，直观来说就是描述样本出现为0或者极大值的情况。  

例子：如果光源较小的PDF处对准了BRDF值较高的区域，则总是有f大/p小的尖端值。  
如果把其他一种策略两种结果一加呢？并不会降低这些方差！这是最直观但错误的融合尝试。它没有在数学上真正降低方差，只是极端样本依然被乘以了0.5的权重，因此画面中同时保留了两种采样的缺陷。  

<div class="x gr txac">
  <div class="x la flex mg0 mgb2">
    <div class="x la item4-md item6">
      <img src="/assets/m/pt1-22.png">
    </div>
  </div>
</div>

给定多种策略，产生一系列不同策略的样本，每个样本有一个精心计算的权重(注意不需要考虑其他样本)。  
```ruby
EST * N = a1 A1+ b1 B1 + ...
```
启发式权重被用于在保持总量不变的情况下，尽可能消除方差。其中，任意系数为  
```ruby
  factor = p0 / (p0+p1+p2...)
# 例如，a1       这里每种策略前面分配百分比系数，总和必须为1
```
尽管一个样本之和他当前的系数有关，每个样本都是独立的，但是观察权重，你必须计算在选中p0策略的参数(如反射方向)时所有策略的对应PDF。  

原理：
在A1中，p0会被消去，结果是f/加权PDF。如果PDF有一个出问题，其他补上，就会减少方差。分母本质上是个平均PDF。  

---
# 全局光照
所有全局光照问题就是加入间接照明，通常通过反弹光线来计算。  

## BOUNCING
第一次，所有点P1对光源直接光照采样。(如镜子的木框)。第二次，随机反射命中一个点P2，计算其直接光照作为光输入，**累加在一起**。  
这种方法保证了有一个直接光，然后再"试探"间接光。  

注意，通过随机反弹出去的间接光射线，如果在后续的飞行中，一头撞上了可被直接采样的光源，渲染器会直接将这个光源的自身发光完全忽略掉。  
```ruby
Li(p,ωi) = Li,d(p,ωi) + Li,i(p,ωi)
Lo(p,ωo) = Le(p,ωo) + ∫H²| DIRECT + ∫H²| INDIRECT
```

<div class="x gr txac">
  <div class="x la flex mg0 mgb2">
    <div class="x la item4-md item6">
      <img src="/assets/m/pt1-23.png">
    </div>
    <div class="x la item4-md item6">
      <img src="/assets/m/pt1-24.png">
    </div>
  </div>
</div>

`▼`可能注意到渲染方程的隐蔽的"天真"性，但它主要表达物理正确(积分所有入射光这一概念)。实现上，必须使用现代方法。  
`▼`关于beta值。定义：除去Li的值的一路累计。与从开始将间接颜色设为1的做法没什么区别。一个疑问可能是这里beta也影响了直接光呢?其实是间接部分的直接光系数吧。第一次直接等于1,就不影响第一次直接光了，也不采集任何间接光。  

<div class="x gr txac">
  <div class="x la flex mg0 mgb2">
    <div class="x la item6-md item12">
      <img src="/assets/m/pt1-25.png">
    </div>
  </div>
</div>

## 轮盘赌
定义中止路径的概率q, 基于该概率随机中止，如果路径存活，贡献乘以1/1-q。主流做法是直接乘在beta里。  

## 小结
明白了，我们不再用乱撞撞到光源才算间接照明，而是一路累计beta和直接光照最后产生一个(最后在第一次命中的表面)积分整个半球，产生一个漂亮的间接光照。