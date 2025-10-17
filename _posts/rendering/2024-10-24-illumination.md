---
layout: page
title:  "光照决策"
author: mosfet
category: rendering
tags: 照明
---
一旦确定基本渲染方式(光栅/光线追踪)，你会如何选择合适的照明技术？  
由于两种框架下的对象定义以及可访问性几乎都不同，同一种照明策略很大程度上不通用，或者至少需要以不同方式实现。已经有多种事实说明这一点。例如，PBR在光栅中仅能被粗略近似。因此，这些技术最好按照类型进行分类，本文期望对这每一种都构建起良好的直觉，本文尊敬GI的真实效果以及近似情况的讨论，以此为目标构建出通常情况下都足够真实可信的照明，不同意这种目的的读者可能需要查看其他风格化方法。  

## 环境光遮蔽
尽管环境光遮蔽(AO)常常被列为近似GI的一种方法。而然这并不是GI。可见人们对此的定义可能是提供了类似GI的部分表现的特定功能。  
```cpp
float ambient_occlusion( in vec3 p, in vec3 n, in float maxDistance, in float falloff) {
  float ao = 0.0;
  const int samples = 4;

  for (int i = 0; i < samples; i++) {
    float move_off = random(float(i)) * maxDistance;
    vec3 direction = n * move_off;
    ao += (move_off - max(scene(p + direction), 1.0)) / maxDistance * falloff;
  }
  return clamp(1.0 - ao / float(samples), 0.0, 1.0);
}
```
AO来自于这样一个事实，互相遮蔽的表面暴露在恒定环境光中将产生特定的阴影，遮蔽值对此衰减进行测量。对于特定表面，光线可能在许多方向上被其他表面遮挡，遮挡越多，该地区就越闭塞，使得它们在环境光的照明下越少。  
这当然不是实现GI反射的技巧，在完整的GI模拟中，闭塞处会自然被阴影。AO期望查找与此类似的表现。  

## 照明的通用概念
最快描述如何正确照明的方法可能不是文字，试想一下以下场景：  
 <div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item4-lg item12 pd0 transformed sk bgh-gunmetal">
      <img src="/assets/i/3-1.png">
    </div>
  </div>
  <p>图1：照明的理念</p>
</div>

太阳强烈的平行光带来太阳阴影，因为背后的间接光不足以提升到周围的相同水平，这就是为什么这里比周围更暗。  
天空光来自于大气散射的次要散射光，具有巨大的体积，AO很好地捕获了该光源的阴影区域。  

不要认为环境光(传统模型)是狭小的，天空光至少应该看得清物体，而太阳光让场景更具戏剧性。  
间接照明是昂贵的！我们将有限的散射补充用于近似另一部分的"环境光"。想想看，因为它照明了背面，不是吗？  
散射量的近似不一定需要乘以颜色，而是视为黑暗中的额外"光亮"，如上所述。  

有的人喜欢反向太阳光来近似散射，但我不喜欢。  

雾，对于大型场景，表现不错。  