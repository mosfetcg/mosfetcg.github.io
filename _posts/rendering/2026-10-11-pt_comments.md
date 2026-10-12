---
layout: page
title:  "关于渲染器……"
author: mosfet
category: rendering
tags: 渲染 全局光照 光线追踪
---

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

---
# NEE
下一事件估计（NEE）是图形学中的一种渲染技术——也称为显式光采样。  
在每个表面交点处，该算法会明确地向光源（如面光源、点光源或太阳）上随机选择的点发射阴影光线。  

具体过程正如我们熟悉，第一个命中点计算完了该点的全部直接光照dLoDirect = dEi\*fr。
第二次弹到别人身上，是该位置被同样的直接光源(对其自身)照射反射到第一次的点上的Lo += beta...。
后面的依然假设先弹到第二点，再弹到第一点。这些都构成了次要光源。最后命中光源，啥也不加了。  

镜子和玻璃不采样D(输出为0)，因为他只能看到单个方向的光来源，直接S，但如果撞击灯光需要显示"倒影"和"折射像"，该部分由间接光线撞击灯负责。   
所以如前所述，NEE大多用于直接影响路径上的漫射材料。  
```glsl
vec3 D( in Material M, in vec3 wo) {
  if (M.type == M_MIRROR || M.type == M_DIELECTRIC) return vec3(0.);

  return BSDF(M, wi, wo) * dEi;
}
```
其BSDF返回cos的倒数，以命中就完全固定反射隐式实现。如果主程序是f/p的形式，请消去其中的cos和pdf项。  
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

# 工程难点
理论和数学只是良好基础，GPU调试可能是地狱。实际中还有各种数值（特别是PDF)、代码问题。  

该框架也并不会直接解决所有渲染表现问题，保持能量守恒、实现焦散等还需要进一步研究。  

# 混合密度比较
Peter Shirley混合密度方法是一种MIS，主要是将diffuse材质MIS上灯光、以及玻璃体(指向对象)、自然朗伯散射三种策略。  
可以在"淳朴"型光线追踪中，提升漫反射表面的正确表现，弹射至透明材质以实现高级焦散。  

<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item3-lg item12 pd0">
      <img src="/assets/i/10-1.png">
    </div>
    <div class="x la item5-lg item12 pd0">
      <img src="/assets/i/10-2.png">
    </div>
  </div>
  <p>左图：密度漫射MIS。右图：NEE自然就有良好的漫射表现</p>
</div>

# 基于能量守恒变体
如果时刻去思考能量守恒。在NEE禁止Lii中漫射表面射向光源的额外Le。并使用漫射三重MIS。我得到了目前看似最好的结果。  