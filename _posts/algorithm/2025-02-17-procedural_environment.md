---
layout: page
title:  "程序化环境"
author: mosfet
category: algorithm
tags: 程序化 环境建模
---
本文总结了一些可能实用环境效果模拟技术。  

选择何种方式？  
我们出于一个最根本的好奇心看待图形编程，找到对"现象"的**模拟**方法，有几种思路——  

①真实物理现象的原理和计算。然后牺牲一部分准确度并近似换取效率和结果，人们很喜欢这样做。  

②彻底的启发式(heuristic)方法。  
人具备一种基本精神能力——通过思考的方式来发现对复杂问题的快捷解决方案，通常会发现更简单的实践模型。  
这不是从现象本质原理进行推理获得正确答案，而是在心理中推测的一种可用方法。启发式过程容易找到最有可能工作或正确的答案和解决方案，但显然它们并不总是正确或最准确的。  

通俗地讲，这是某种"聪明的技巧"。因此绕开了对现象之理论的要求，读者或笔者可能无法精通任何物理、数学、程序其中之一或多数。启发式方法很容易理解并取得效果。
一个例子是，当读者不熟悉大气的颜色如何在宇宙中产生时，我们通常已经知道呈现的结果，因此很容易实现后者。  

**程序化(procedural)**指一种程序的特定效果的算法艺术，例如程序化的天空，用特定算法生成一些可接受的结果。这是一个启发式的例子。  

另一个提示是，研究一个实现通常最好从实际、全面的观察开始。  
并且图形程序员应该意识到——从观察者的角度思考场景。思考观察者会看见什么，然后再采取行动，因为这就是最终目的。  

## B. 天体

## 圆盘
可见的天体通常简化为圆盘表示。如前所述，系统中最好先对时间进行建模，再计算太阳方位，最后才放置圆盘。  
```cpp
float dist = distance(v, sun_rd);
float radius = 0.1;
vec3 disk = vec3(0.0);

// 制作圆盘的基本方法：根据v和sun线的距离划分
if (dist < radius) disk += sun_alb;

// TYPE1 大 模糊边缘 相加
if (dist < radius) {
  float dim = pow(smoothstep(radius, 0.0, dist), 3.0);
  disk += 1.0 * sun_alb * dim;
  disk += 1.0 * mix(vec3(0.0), vec3(1.0), dim);
}

// TYPE 建议使用小圆盘 内部锐利 混合
// 1 // 1 / 1+r2
float core_mask = 1.0 - step(radius * 0.3, dist);
disk += core_mask * sun_alb;
float ring_mask = 1.0 / (1.0 + pow((dist - 0.3 * radius) * 2.0, 2.0));
disk += mix(ring_mask * sun_alb, ring_mask * vec3(1.0), dist); // 光晕 ?--外环过度到白色
```

## 关于体积渲染
类似云的物体在图形中的正确表示通常被认为需要**体积渲染(volumetric rendering)**。  
云是我们下文的目标，因此可能涉及该技术，无论什么方式，读者可以先获取此技术。  

## C. 云
```
https://en.wikipedia.org/wiki/List_of_cloud_types
https://www.shadertoy.com/view/4dSBDt
https://www.shadertoy.com/view/Xls3D2
https://www.shadertoy.com/view/4d2cDy
```
`云学(Nephology)`研究云。悬浮在空气中的较大颗粒物称为`aerosol`，而云是水滴、冰晶等。  
这里有很多你不想深入的云的分布和形状的术语。我们特别说明，接触地球表面的非常低的层状云被赋予了雾或薄雾的俗称，这些名称并不包括在分类中。通常模拟它们的技术也有所不同。
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item5-lg item12 pd0">
      <img src="https://upload.wikimedia.org/wikipedia/commons/5/58/Wolkenstockwerke.png">
    </div>
    <div class="x la item5-lg item12 pd0">
      <img src="https://upload.wikimedia.org/wikipedia/commons/e/e8/Cumulusradiatus1.jpg">
    </div>
  </div>
  <p>引用图片：云类型</p>
</div>

生活观察中，云可以出现在任何角度，即使是远高处的云也可能被水平视线命中。这是地面弧度的差异。并且我们知道距离显著影响视觉大小。  
对于云的颜色，密集的云层外部显示白色，薄者显露背景，被光源方向直接照明的厚云层，底部将额外呈现高对比的黑影。  

另一个有趣的事实是，在许多演示中作者通常只表达一种云，尚不清楚是有意为之还是缺乏概念。  
通常这是不符合现实的，请参考一些真实的照片。  
上述大气的实现也存在一些问题——没有夜晚。通常夜晚就好像暴露在太空中而对大气视而不见。有些演示包含了这些处理。  
有关这些问题的说明您可以检查引用中的参考例子。  

## 流体
原则上对云等流体的模拟最好基于流体动力学(fluid dynamics)，但该笔者从未深入研究该领域。  
根据某些资料的统计，启发式方法占据主流。  

## 启发式云
```
Stratus  层云
低空 水平分层 底部均匀 无特征 高雾 形状像雾 ！整体覆盖
Cirrus   卷须云
高云 纤细 细腻 线条 羽毛状 纤维 ！一条条平行的带
Cumulus  堆(积)云
低空 云底平坦 蓬松、棉花状或蓬松状 一堆 ！单、线、团分布
```
一种最古老的实现是粗暴地将FBM数据映射到一个薄薄的球面上，结果是极其不真实的，并且与我们使用的其他真实技术产生严重的不协调感。  
样本、噪声、位置全都不符合任何一种云的特征。我们至少应该拒绝这种技术并认为最根本的起点必须选择更好的"容器"来表达FBM，至少不能是平面！尽管此FBM可能只能类似地接近一种云，但这至少是合理的并且让我们感到满意的一个开始。  
卷须云的体积可能更难，因此最终决定致力于一种简单形状云的实现。积云符合一般人对云的直觉。  

现在我们使用体积渲染一个环状空间。从技术上讲，体积渲染必须合并背景大气，为了减少Sky函数的调用成本，有时分为两个函数是有意义的。例如，在考虑光照时仅使用不包含体积云的天空。  
```ruby
Lo = Cρ ∫all_line_dx|T(p)T2(p)βS(p)dx
```
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item5-lg item12 pd0">
      <img src="/assets/i/6-2.png">
    </div>
  </div>
  <p>图3：厚度为2.0的云层在特定太阳方向上的照明</p>
</div>
我们看到，这种算法很慢。且位于太阳视野外的云是全黑的，尽管这是有道理的，我们的场景天空较亮，除非我们只看向太阳。如果再考虑天空的贡献将导致该算法成本过高而不可用。  

## 近似云
我们可能期望找到一种更便宜的云。

## D. 
## 便宜的雾
实际上，雾比我们大多数人认为的更普遍。大多数情况下，空气中都有一定程度的阴霾。即使只有少量，我们也可以通过引入雾气来增强室外场景的现实主义。  
除了使用参与介质，存在多种模拟雾的模型。即使是非常简单的方法也可以有效。  
一种这样的方法是基于相机到目标的距离，直到插值到雾本身的颜色。下列是一种非常简单的雾算法。  
```cpp
vec3 fog2( in vec3 col, float d, float start, float end) {
  float amount = clamp(((end - d) / (end - start)), 0.0, 1.0);
  return mix(vec3(0.7, 0.8, 0.9), col, amount);
}
```

## 水下尖刻(caustics)
水底地板上观察到弯曲的光带(bands of ligh)称为`水尖刻(water caustics)`，这是由波浪带传递到下表面的聚光。  
模拟这种基本水下效应可以通过实际追踪射线得到，但是，在大多数情况下，不必完全准确，粗略的模拟也足以传达水下效应。找到与水面上的波一致的方式弯曲的白线就足够了。因此，扭曲相同的波。  
```cpp
float caustic_noise = pow(1.0 - abs(sin(fbm(ro.xy) * 6.28)), 16.0);
vec3 caustic = clamp(sqrt(vec3(caustic_noise) * col2), vec3(0.0), vec3(1.0));
waterfloor = clamp(waterfloor + caustic, vec3(0.0), vec3(1.0));
```
在没有处理水下对从水面进入的光的反应时，你绝对想要尖刻。  
