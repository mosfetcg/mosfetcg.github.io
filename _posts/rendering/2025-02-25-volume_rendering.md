---
layout: page
title:  "参与介质"
author: mosfet
category: rendering
tags: 渲染 参与介质
---

该文件是备份。2025/3/11。  

## 薄雾
类薄雾质(smoke/fog/mist)通常称为`体积(volume)`或`参与介质(participating media)`。  
类似其表面和照明的问题称为体积渲染问题，大多数情况下，我们只处理**表面**的可见性和着色。而然，实际上也不能将内部理解为表面，因为只是粒子密度对光照的反应，算法通常必须寻找考虑全部内部信息。  
另一种有关特性称为`子表面散射(subsurface scattering)`，即将一块稠密薄雾放入另一物体内部。  

## 活动
当光穿越参与介质时，该位置的粒子可能降低光照，发生吸收和`外散射(Out-scattering)`；或获取能量，要么自身主动发光`(emission)`，另外`内散射(in-scattering)`也主要将光照的一部分直接定向到相机中。另外，总体的光照强度会随着距离和比尔法降低。  
```ruby
# 渲染方程
Lo = ∫all_line_dx|T(p)S(p) dx

# 我们使用标准Sigma符号表示密度
σa(p) σs(p)          # 吸收/散射(内外兼用)
σt(p) = σa(p)+σs(p)  # 消光(extinction)
                     # 结果白度：s/t

# 发射率(transmittance) 指多少光可以传达。遵循比尔法衰减S项
T(p) = exp(- )
          ↑ ∫all_line_dx|σt(p)dx   # 这个积分称为光学长度或深度(Optical distance/depth)

# 光照(内散射)
S(p) = σs(p)∫all_sphere|ρLi dv  # 散射密度，内散射强度
# ρ ~ Phase
Isotropic           1/4Pi
Rayleigh Mie
Henyey-Greenstein   1/4pi * (1-g²)/(1+g²-2gcos)^1.5

# 自发光(emission)
E(p) = σa(p)Le(p) dx
# 可选，加入到S中。
```
```ruby
# 蒙特卡洛求解
Σ(g/p)
# dx可以用随机值，单位概率为1/line，因此概率为dx/line
p = dx / line

# 固定段求解，dx用固定值
+= dx * T S

# 加入背景
Lo += T(final) * S(final) # 如天空等。
```
```
https://graphics.stanford.edu/courses/cs348b-20-spring-content/lectures/17_volume/17_volume_slides.pdf
https://www.scratchapixel.com/lessons/3d-basic-rendering/volume-rendering-for-developers/volume-rendering-summary-equations.html
```

## 评估边界
简单的办法是发现可以交叉时(但在外部)强制进入对象内部。最好选择更合适的交叉函数，让自己知道在外部还是内部。  

## 结果
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item5-lg item12 pd0">
      <img src="/assets/i/7-1.png">
    </div>
    <div class="x la item5-lg item12 pd0">
       <img src="/assets/i/7-2.png">
    </div>
  </div>
  <p></p>
</div>