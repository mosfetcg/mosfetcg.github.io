---
layout: page
title:  "参与介质"
author: mosfet
category: rendering
tags: 渲染 参与介质
---

重写于2025/10/04。  

## 将体积视为粒子
本文介绍渲染中的`参与介质(participating media)`和`体积(volume)`渲染。  
通常用于建模云、烟(smoke/fog/mist)、水等对象，体积渲染解决它们的表示以及照明问题等。  
另一种有关特性称为`子表面散射(subsurface scattering)`，如皮肤和油画，除表面之外还建模了其内部参与介质的反应。  

在这一主题打开前，习惯上认为光线只是在表面之间识别行为，只需要了解**表面**的可见性和着色。  
体积应当被视为密集的粒子区域，算法通常必须寻找考虑全部内部信息。  

## 活动
当视线上的光**Li**穿越参与介质时，该位置的粒子可能**降低**此光照，发生自我吸收和`外散射(Out-scattering)`(转移能量)；要么释放能量，由自身主动发光`(emission)`。而`内散射(in-scattering)`将光照的一部分直接定向到相机中。除了四种行为外，光线本身会因为穿越距离和比尔法降低。  
下面列出了体积渲染方程，简化形式可以以固定线段上的采样完成。内散射的半球采样是一个理想公式，通常进行简化以忽略评估其他介质，在`单次散射(single scattering)`中，Li仅来自于光源，意味着上述事件仅发生一次。  
```ruby
# 渲染方程         衰减 光源
Lo = ∫all_line_dx|T(p)S(p) dx
     ∫0..INF                   #or INF from full equation 14 volume.28

# 我们使用标准Sigma符号表示密度
σa(p) σs(p)          # 吸收/散射(内外兼用)
σt(p) = σa(p)+σs(p)  # 消光(extinction)
                     # 结果白度：s/t

# 发射率(transmittance) 指多少光可以传达。遵循比尔法衰减S项
T(p) = exp(- )
          ↑ ∫all_line_dx|σt(p)dx   # 这个积分称为光学长度或深度(Optical distance/depth)

# 光照(内散射)
S(p) = σs(p)∫all_sphere|ρLi dv  # 散射密度，内散射强度
                        # Li = Ld + Li, full equation
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

## Delta Tracking

## 结果
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item5-lg item12 pd0">
      <img src="/assets/i/7-1.png">
    </div>
  </div>
  <p></p>
</div>