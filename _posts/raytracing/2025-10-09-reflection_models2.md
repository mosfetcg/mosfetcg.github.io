---
layout: page
title:  "反射模型2"
author: mosfet
category: raytracing
tags:
---

<style>code:not(pre code) {color:green!important}</style>

## 微面模型
微面模型在相机中的表面是平坦的，但模型内部由小镜子一样的曲面构成。这些微面全都产生完美镜面反射。  

考虑以下平坦区域"dA"。方向均任意。  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item3-md item6 sk bgw">
      <img src="/assets/m/pt1-14.png">
    </div>
    <div class="x la item3-md item6 sk bgw">
      <img src="/assets/m/pt1-15.png">
    </div>
  </div>
</div>

```ruby
D(ω)   # 与ω方向对齐的微面的密度函数。 NDF函数建模了所有角度微面的分布
dωh(ω) # 特定ω方向的半角方向立体角微元
D(ω)dωh(ω) # 对齐微面的百分比，将抽象的几何ω理解为x轴即可。
∫H²|D(ω)cosθdω = 1 # 密度1约束。cos项是考虑微面的倾斜，投影到dA上的面积修正。

dAm = D(ω)dωh(ω)dA # 如果乘以该百分比，我们就知道有多少dAm实际面积。如果给定dA

dΦom = |ωi·ωh|/ωi·n fr(ωi，ωo) dAmdEi # 分子为微面接受辐照度的投影修正
# 分母为宏观表面dA修正辐照度(dEi)投影效果的取消。
# fr为微面自身的BRDF。  

G(ωi,ωo,ωh) #检查微面被邻居遮挡而无效的函数。进一步影响dAm的有效面积。  
```
G听起来是个很难实现的函数，但实际上只是用观察角度和表面的一个粗糙度参数决定的……  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item6-md item10 sk bgw">
      <img src="/assets/m/pt1-16.png">
    </div>
  </div>
  <p>Torrance-Sparrow BRDF 框架</p>
</div>

#### Beckmann
m即半角方向，a是粗糙常数。  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item4-md item9 sk bgw">
      <img src="/assets/m/pt1-17.png">
    </div>
  </div>
</div>

#### Trowbridge-Reitz (GGX)
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item4-md item9 sk bgw">
      <img src="/assets/m/pt1-18.png">
    </div>
  </div>
</div>

#### 各向异性。Anisotropic GGX
渲染拉丝金属的分布函数。  