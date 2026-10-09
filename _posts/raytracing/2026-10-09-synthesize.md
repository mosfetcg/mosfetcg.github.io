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
# spherical luminaire/ cone sampling
dist = len(c-x)
sinα = R/d or cosα = sqrt(1 - sinα²)  # α最大半边角度 α = asin/ acos
# 均匀密度
q = 1/ 2Pi(1-cosα)
cosθ = 1-ξ1+ξ1cosα                    # 确定后，可知uvw中的采样位置
   φ = 2PIξ2
q = p(x2)cosθ2 / len(x, x2)           # 球面上的点
p(x2) = cosθ2 / 2PIlen(x,x2)(1-cosα)
``` -->

下图显示了不对球正面进行重要性采样的方差差别。  
视线立体角区域的立体角采样通常方差都更小。  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item3-md item6">
      <img src="/assets/m/pt1-19.png">
    </div>
  </div>
</div>

## 显示方差
根据方差公式以及估值器，我们可以设计一种debug程序来检查方差值。而且对应场景！
```ruby
V(x) = EST(x²)-EST(x)²
```

减小单样本方差是有代价的。如果为了p去贴合f，但计算一根光线的时间（Cost）翻了100倍。最终相乘，效率可能反而下降了。  