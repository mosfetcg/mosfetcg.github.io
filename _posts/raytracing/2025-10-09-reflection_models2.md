---
layout: page
title:  "反射模型2"
author: mosfet
category: raytracing
tags:
---

<!-- ## 反射模型2
**微面**  
`微面反射/散射(microfacet reflection)`模型为宏观(macroscale)平整的表面(dA)定义了内部不可见排列的微面，这导致了其内部的粗糙建模，光线在波长尺寸下发现每个微面仍然是平滑的，每个微面被视为一个镜子元素。  

由于每个镜子朝向不同方向，第一个想法可能是得到统计下Normal近似，以此计算反射光集中到哪里，而然我们需要求解给定方向的光亮。相反，首先计算已知`vi vo`的中间向量，随后我们检查微面Normal与其**对齐**的统计程度。  
这称为微面模型中的`标准向量分布函数(normal distribution function)，D`。  
微面的内部几何情况存在互相遮挡，这导致了散射光的减少，数学描述称为`衰减函数(attenuation function)，G`。这给出了观测情况中的散射能量分数。或者已经对齐中间向量的微面在入射或出射方向的可见比率，有些函数分别测量两个方向比率综合起来。  
实践中使用的几何函数选择依赖于已知的D分布函数。  
```ruby
α # surface roughness parameter

# Torrance-Sparrow BRDF
ρr = D(vm)G(vi,vo)F(vo) / 4cosθvicosθvo

# Beckmann
D(vm) = (1/Piα²(cosθm)^4) * exp(-(tanθm)²/α²)
# Trowbridge-Reitz(GGX)
D(vm) = 1/ [Piα²(cosθm)^4)(1+(tanθm)²/α²)²]
# Smith Self-Shadowing
# GGX--
G1(v) = 2/ 1+sqrt(1+α²(tanθ)²) #θ surface normal and a direction v
G(vi,vo) = G1(vi)G1(vo)        # measure individually
```
31页提供了一些重要性采样的技巧，请见。  
Glints？Interreflection？Wave Effects？

**层(layered)**  
层模型在每一层材料都使用不同的BSDF。   -->