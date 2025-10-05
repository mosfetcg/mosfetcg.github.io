---
layout: page
title:  "反射模型"
author: mosfet
category: rendering
tags: 渲染 全局照明 路径追踪
---

<style>code:not(pre code) {color:green!important}</style>

## refs
```
cs348b: Image Synthesis Techniques

反射模型1 - lecture8

8✅ 反射模型1 如下
```

## 反射模型1
反射是光入射到表面产生相互作用并使其从事件侧离开而不改变频率的过程。  
反射具有以下**属性**：  
```
1 光谱分布
平均光照条件下(所有波长为1)却在反射时产生降低(< 1)的不同波长分布

2 极化(polarization)

3 方向性分布
```

以反射为重点解释传输方程时称为反射方程。因为这说明了每束光如何在球体上被反射。  
BRDF描述了将光照导向反射半球的方式。  
```ruby
# The Reflection Equation
Lo(vo) = ∫hsphere| ρ(i,o)  Li(vi)cosθvi   dvi
                  # BRDF   Illumination  sample
ρ(i,o) = Lo/Hi
```
BRDF函数的**属性**如下。  
```ruby
1 线性
因为是一个比率。如果将入射辐射度（光能）加倍，反射辐射度也会加倍

2 reciprocal 可倒(互惠、互换)
即ρ(i,o)=ρ(o,i)
理解：在平面切片上考虑可逆，但散射的辐射度不遵守互惠

3 isotropic(各向同性)
# isotropic/anisotropic，具有在不同方向测量时具有相同/不同值的物理特性。  
各向同性表面具有随机取向的微面。微面在各个方向上都是统计均匀的，因此没有优先方向
围绕表面Normal旋转入射或出射光方向不会改变反射率
BRDF函数被认为是各向同性的

4 能量守恒
ρ = Φo/Φi = ∫/∫ && p in 0..1
```

### 基本反射函数种类
**理想镜面(Mirror/follow Reflection Law)**  
除出射方向是入射方向的完美镜面反射外，BRDF在任何地方都为零。数学上，由`Dirac delta`函数`δ`描述。  
因此方程通常只剩下Li项。  
```ruby
ρr = δ(reflect) / cosθvi    # 为了本文描述方便，将BRDF的原符号ρ记为ρr
```
**理想镜面折射**  
和我们熟悉的一样，斯涅尔法、全内反射、菲涅尔。  
`ρt`称为BT(transmission)DF。BTDF不是互惠的。  
```ruby
ρt = δ(transmission) / cosθvi
ρ = F * ρr + (1-F)* ρt           # 这里从δ推断到下一行等式可能存在不严谨的方式，但我们尊重原文
Lo(vo) = FLi(ref)+(1-F)Li(Tra)
```

理论上，不同的波长会折射到不同角度，基于波长的折射将呈现彩色。  

该模型的光线分叉为两个部分，透射光线和反射光线受到菲涅尔方程分配。通常估值时随机对这两个部分进行采样(单条)，这将产生复杂路径(如图例所示)。实践中使用菲涅尔概率将获得良好结果。这组合反射率称为`BSDF`，尽管透射光来自不同方向，反射率仍然描述其反射率。  

**理想漫射(follow Lambert’s Law)**  
均匀概率向各向反射，就像产生新的光源一样。因此p是比率常数。  
```ruby
Lo(vo) = ∫hsphere| ρrLi(vi)cosθvidvi
       = ρr∫Li(vi)cosθvidvi
       = pr * Hi

albedo = ∫Lo(vo)cosθvo dvo / ∫Li(vi)cosθvi dvi
       = Lo∫cosθvodvo / E
       = LoPi/E
       = (pr_o * E * Pi) / E
       = Pi * pr
pr = albedo/Pi
```

**Coated Diffuse BRDF**  
有一个薄层当作理想镜面，下层是理想漫射。外观像湿的泥巴、油漆。  

**一般镜面(Glossy、方向漫射)**  
没有明确介绍，在对称方向上，呈现椭球局部方向反射。  
在穹掠角反射更高的漫射材料似乎归类于此。  