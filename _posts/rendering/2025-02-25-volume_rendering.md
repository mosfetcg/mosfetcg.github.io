---
layout: page
title:  "参与介质"
author: mosfet
category: rendering
tags: 渲染 参与介质
---

该文件是备份。2025/3/6。  

## 薄雾
类薄雾质(smoke/fog/mist)通常称为`体积(volume)`或`参与介质(participating media)`。  
类似其表面和照明的问题称为体积渲染问题，大多数情况下，我们只处理**表面**的可见性和着色。而然，实际上也不能将内部理解为表面，因为只是粒子密度对光照的反应，算法通常必须寻找考虑全部内部信息。  
另一种有关特性称为`子表面散射(subsurface scattering)`，即将一块稠密薄雾放入另一物体内部。  

## 活动
当光穿越参与介质时，该位置的粒子可能降低光照，发生吸收和`外散射(Out-scattering)`；或获取能量，要么自身主动发光`(emission)`，另外`内散射(in-scattering)`也主要将光照的一部分直接定向到相机中。另外，总体的光照强度会随着距离和比尔法降低。  
```ruby
# 内部开始计算透光率，计算命中边界k(只需要计算一次)
if (total_dx > k) break; // exit
float dx = rand() * 0.1;
total_dx += dx;

# 渲染方程
Lo = ∫all_line_dx|T(total_dx)S(p) dx
# 如果样本dx已经求和所有k，这种方式不需要除以p，否则dx应该取随机总长步骤
Σ = g/p; p=(1.0 / k) => ∫p = dx/k
# 另外一种方式中，+= T * s * dx

# A(p)吸收密度 s(p)散射密度，内外兼用 W = s/s+A

# transmittance 比尔法因子
T(total_dx) = exp(-optical_depth)
t(total_dx) = optical_depth = ∫all_line_dx|(A+s)(p)dx  # 双降低密度，代表dx会损失多少百分比光

# 中间位置光照(内散射)
S(p) = s(p)∫all_sphere|ρLi dv  # 散射密度，内散射强度

# Emission
E = ∫A(p)Le dx
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
  <p>图1：噪声单位体积球</p>
</div>

## 旧方法
旧方法似乎存在问题。该实现将体积视为微型表面，并在随机值后散射，直到dx可以穿过体积边界。  
但是没有说明结果如何计算。  