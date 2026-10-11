---
layout: page
title:  "关于渲染器……"
author: mosfet
category: rendering
tags: 渲染 全局光照 光线追踪
---

# NNE
回顾我们熟悉的NNE的具体原理过程，第一个命中点计算完了该点的全部直接光照dLoDirect = dEi\*fr。
第二次弹到别人身上，是该位置被同样的直接光源(对其自身)照射反射到第一次的点上的Lo += beta...。
后面的依然假设先弹到第二点，再弹到第一点。这些都构成了次要光源。最后命中光源，啥也不加了。  

镜子和玻璃不采样D，撞击灯光需要显示该颜色。  
如前所述，后面的直接光计算是用于间接路线上的。  
```glsl
vec3 D( in Material M, in vec3 wo) {
  if (M.type == M_MIRROR || M.type == M_DIELECTRIC) return vec3(0.);

  return BSDF(M, wi, wo) * dEi;
}
```
其BSDF返回cos的倒数，以命中就完全固定反射隐式实现。  
```glsl
vec3 BSDF( in Material M, in vec3 wi, in vec3 wo) {
  if (M.type == M_DIFFUSE) {
    return M.rho / C_PI;
  }
  if (M.type == M_MIRROR) {
    return vec3(1.0 / dot(wi, M.n));
  }
  if (M.type == M_DIELECTRIC) {
    return vec3(1.0 / dot(wi, M.n));
  }
  return vec3(.0);
}
```
散射采样函数接口建议
```glsl
vec3 S( in Material M, in vec3 wo, inout vec3 wi, inout float pdf) {
  if (M.type == M_DIFFUSE) {
    wi = H_random_on_hemisphere(M.n);
    if (H_nearlly_zero(wi)) wi = M.n;
    pdf = 1. / C_TWO_PI;
    return BSDF(M, wi, wo);
  }
}
```

# 难点
该框架并不会无脑解决许多复杂的渲染问题。  

类似可能遇到的问题还有：能量守恒、调试、工程方面。  

# 混合密度比较
Peter Shirley混合密度方法是一种MIS，主要是将diffuse材质MIS上灯光、以及玻璃体(指向对象)、自然朗伯散射三种策略。  
可以在"淳朴"型光线追踪中，提升漫反射表面的正确表现，弹射至透明材质以实现高级焦散。  

而在NNE中，漫反射表面本身就被设计的表现良好。  

<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item3-lg item12 pd0">
      <img src="/assets/i/10-1.png">
    </div>
    <div class="x la item5-lg item12 pd0">
      <img src="/assets/i/10-2.png">
    </div>
  </div>
  <p>左图：密度漫射MIS。右图：NNE</p>
</div>

# 能量守恒
如果保持能量守恒。在NEE禁止Lii中漫射表面射向光源的额外Le。并使用漫射三重MIS。我得到了目前看似最好的结果。  

---
# 图集
版权所有。  

<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item6-lg item12 pd0">
      <img src="/assets/i/10-3.png">
    </div>
    <div class="x la item6-lg item12 pd0">
    </div>
  </div>
</div>
