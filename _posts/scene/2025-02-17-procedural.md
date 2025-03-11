---
layout: page
title:  "更真实的环境"
author: mosfet
category: scene
tags: 场景
---
让我们讨论一些实用图形技术。  
我们使用一个非常普通的渲染器作为示例，使用SDF寻找表面，并启用路径积分。以提供体积渲染的可能性。  

## **PHYSICAL BASED**?你真的需要吗
我们出于一个最根本的好奇心看待图形编程，找到对"现象"的**模拟**方法——  
①真实物理现象的结果可以通过精确计算表达。  
②但是一旦有人转向近似，通常会发现更简单的实践模型。这类方法在哲学上称为`启发(heuristic)`，意味，"我发现，我观察的"。启发式的存在说明了这一个事实，人具备一种基本精神能力——通过思考的方式来发现对复杂问题的快捷解决方案，我们强调，这不是从现象本质原理进行推理获得正确答案，而是在心理中推测的一种可用方法。启发式过程容易找到最有可能工作或正确的答案和解决方案，但显然它们并不总是正确或最准确的。  

通俗地讲，这是某种"聪明的技巧"。因此绕开了对现象之理论的要求，读者或笔者可能无法精通任何物理、数学、程序其中之一或多数。启发式方法很容易理解并取得效果。
一个例子是，当读者不熟悉大气的颜色如何在宇宙中产生时，我们通常已经知道呈现的结果，因此很容易实现后者。  

最后我们要说明一种流行的操作计算机的艺术——**程序化(procedural)**旨在用特定算法生成一些奇特的结果，有时它们能很好的符合我们的目的。具体类型取决于算法本身，很难说它们都是启发或物理的。我们建议读者仔细考虑这个问题。  

另一个提示是，研究一个实现通常最好从实际、全面的观察开始。  
并且图形程序员应该意识到——从观察者的角度思考场景。思考观察者会看见什么，然后再采取行动，因为这就是最终目的。  

## 静态图像背景
纹理映射静态图像对场景的构造作用有限。  

## 时间
使用时间映射一切。  
```cpp
#define FIX_DAYTIME true
#define DAYTIME 6.0
float global_time = 0.0;
vec3 wind_dir = normalize(vec3(-0.1, 0.2, 0.51));
vec3 sun_pos;
vec3 sun_rd;
vec3 sun_alb = vec3(1.0, 0.8, 0.0);

global_time = FIX_DAYTIME ? DAYTIME : -sin(u_time * .5) * 6.0 + 12.0;
sun_rd = vec3(
  -sin((global_time + 12.0) / 3.8),
  cos((global_time + 12.0) / 3.8),
  0.0
);
sun_pos = sun_rd * 1000.0;
```
## 大气的形状
大气是环绕行星的气体环，地球半径很大(6300km)，大气高度很低(100KM)。  
有时候对这种形状理解不充足，比如水平线以上的(可视)空间实际上是一**圆段**。朝着水平方向看见比单个垂直高度多得多的空间是很正常的。  
不得不提的是，小球体下方存在一些空隙如何解释？这两个对称的圆段角开始的地方在微分情况下可视为平面，因此很难看到下方。  

有时候需要评估到该大气边缘的距离，我们可以采用真实的数据。除了实际计算交叉地球和大气，如果只是不深思熟虑地在单位球中进行采样将不匹配该形状。  
我将提到一种更简单的非交叉方法。该近似方式根据角度缩放天顶处的单位高度(zenith = 1)以获得比率。因此可在可观的穹掠角获得类似的结果，在到达0.5Pi = 1.7之前将得到很高的值。我们可以只是说该距离大约比到天顶大`d`倍。  
```ruby
d = 1.0 / dot(v, n) #+ 0.01
```

## A. physical based atmosphere
```
https://en.wikipedia.org/wiki/Rayleigh_scattering
https://en.wikipedia.org/wiki/Mie_scattering
https://github.com/wwwtyro/glsl-atmosphere
https://www.scratchapixel.com/lessons/procedural-generation-virtual-worlds/simulating-sky/simulating-colors-of-the-sky.html
```
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item2-lg item12 pd0">
      <img src="https://www.scratchapixel.com/images/atmospheric%20scattering/as-nishita1.png?">
    </div>
  </div>
  <p>引用图片：大气在不同高度下的颜色</p>
</div>

光子在进入大气层后会被空气中的各种粒子散射损失能量，气体中的粒子密度取决于高度。  
```ruby
p(h) = p(0)exp(-h)
```
`雷利散射(Rayleigh scattering)`描述了光或其他电磁辐射因比其**波长小**的多的粒子造成散射时的某种观察。  
从我们的观察角度来说，较短波长（蓝色）的散射比较长波长（红色）的散射更强烈。这导致天空各个区域都会出现间接的蓝光和紫光。人眼对这种波长组合的反应就像是蓝光和白光的组合。在日落时，由于辐射的传播距离更远，大多数蓝光已经散射完，剩下的波长让天空呈现橘红色。  
```ruby
# 本文β符号表示因子，当不标记其他符号时表示散射量βS。后一个后缀R、M表示对应的两种散射。类似的约定适用于HR和HM等常数。  
βR(h,λ) = 8PI³(n²-1)² |* exp(-h/HR)
            (3Nλ^4)   |
# h高度 n空气折射率 N海平面分子密度 HR(scale hieght) = 8KM

# 对于蓝光440 绿光550 红光680 左式为一个常数
βR(h) = (33.1e-6,13.5e-6,5.8e-6) * exp(-h/8e3)
# 例如，在1KM处，该值下降到88%

# extinction lost
βER = βAR(absorb) + βSR(scat) = 0 + βR

# Raleigh phase
cos = dot(v, sun);
ρ(cos) = (3/16PI)(1+cos²)
```
蓝光的波长更短，其初始值将更高。因此其对应的散射感觉越强烈。  
另一种散射称为`米氏散射(Mie scattering)`，描述了更大的颗粒、灰尘、沙子对光的散射作用，使它们呈现灰白色。  
米氏散射造成太阳周围主要白色光晕以及地平线上天空变亮/变暗。雷利散射解释造成天空呈现蓝色/红色/橙色的原因。  
```ruby
βM(h,λ) = βM(0,λ)exp(-h/HM)
# HM(scale height) = 1.2KM
        = 21e-6 exp(-h/HM)

βEM(h) = 1.1βM(h)

ρ(cos) = (3/8PI) * (1-g²)(1+cos²)/(2+g²)(1+g²-2gcos)^1.5
# g = 0.76
```
参考我们的体积渲染方程，所有βE项将用于积分到`T`项。  
```ruby
Lo = ∫all_line_dx|T(p)S(p) dx #(该T沿着视线减弱)
# S(p) = σs(p)∫all_sphere|ρLi dv
```
问题是内散射中使用的光线是什么？(甚至我们正在计算天空光线本身)。  
读者容易发现，该点全局照明评估成本过高。我们近似内散射来自固定太阳的值穿透后到达该点。但是该发射率需要另外计算。  
```ruby
S(p)      =  σs(p)∫all_sphere|ρLi dv
appro_S(p)=                    ↑(C * T2) #(沿着太阳减弱)
          # 由于不再需要积分全球
          =  σs(p)ρ(C * T2(p))           # C是一个光照常数
          =  σs(p)ρ(C * ∫sun_dx_line|σs(p)dx)

# 并且我们发现T只是：
T(p) = exp(-  β(0)*∫all_line_dx|exp(-h/HR)dx)
                    ↑

# 现在合并为
Lo = C * ρ ∫all_line_dx|T(p)T2(p)βS(h)dx

# 另外我们可以合并T，T2到一个exp中
```
最后结果来自于两种散射贡献的和，可放在同一个循环中同步完成。  
```ruby
LoR + LoM
```
到这里我们的理论就结束了，读者也可以直接使用引用中开源的大气函数。  
这是我们的版本。  
```cpp
vec2 iSphere( in vec3 ro, in vec3 rd, in vec3 ce, float ra) {
  vec3 oc = ro - ce;
  float b = dot(oc, rd);
  float c = dot(oc, oc) - ra * ra;
  float h = b * b - c;
  if (h < 0.0) return vec2(-1.0); // no intersection
  h = sqrt(h);
  return vec2(-b - h, -b + h);
}
vec3 atmosphere( in vec3 ro, in vec3 rd, in vec3 sd) {
  const float sunbase = 15.0; // sunbase
  const float re = 6371e3; // unit: meter
  const float ra = 6471e3; // unit: meter
  const vec3 Rbeta0 = vec3(5.8e-6, 13.5e-6, 33.1e-6); // unit: /m
  const vec3 Mbeta0 = vec3(21e-6);
  const float hr = 8e3;
  const float hm = 1.2e3;
  const float g = 0.76;

  // 将输入位置参考到地球中心的位系中，地面处为半径，当前高度为ro - re
  ro += vec3(0.0, re, 0.0);
  float t = iSphere(ro, rd, vec3(0.0), ra).y; // ro -> t

  // 求解方程分解为固定段的积分
  float segement = 16.0;
  float dx = t / segement;

  // 计算常数
  float cos_theta = dot(rd, sd);
  float Rphase = 0.0597 * (1.0 + cos_theta * cos_theta);
  float Mphase = 0.1194 * (1.0 - g * g) * (1.0 + cos_theta * cos_theta) /
    ((2.0 + g * g) * pow(1.0 + g * g - 2.0 * g * cos_theta, 1.5));

  vec3 R = vec3(0.0), M = vec3(0.0); // 重复mie
  float R_tmp = 0.0, M_tmp = 0.0; // 重复mie

  for (int i = 1; i <= int(segement); i++) {
    float h = length(ro) - re;
    // 如果朝着地球，那么始终length(ro) < re，即使太阳在下方也没有意义因为这里是大地而不是空气
    if (h < 0.0) return vec3(0.0);

    // 优化1：存储消光量，减少exp调用
    float Re = exp(-h / hr), Me = exp(-h / hm);
    R_tmp += Re * dx;
    M_tmp += Me * dx; // 重复mie

    // 计算T2(发射sd)
    float segement2 = 8.0;
    vec3 ro2 = ro;
    float t2 = iSphere(ro2, sd, vec3(0.0), ra).y;
    float dx2 = t2 / segement2;
    float R_tmp2, M_tmp2 = 0.0; // 重复mie
    for (int j = 1; j <= int(segement2); j++) {
      float h2 = length(ro2) - re;

      R_tmp2 += exp(-h2 / hr) * dx2;
      M_tmp2 += exp(-h2 / hm) * dx2; // 重复mie

      ro2 += sd * dx2;
    }

    vec3 RTT2 = exp(-Rbeta0 * (R_tmp + R_tmp2));
    vec3 MTT2 = exp(-Mbeta0 * (M_tmp + M_tmp2) * 1.1); // 重复mie 消光 * 1.1

    // 累积到结果，注意R只是积分项。并且我们将Rbeta0 * Re的常数被移动到外面
    R += RTT2 * Re * dx;
    M += MTT2 * Me * dx;

    // 之后再移动
    ro += rd * dx;
  }
  return sunbase * (Rphase * R * Rbeta0 + Mphase * M * Mbeta0);
  return sunbase * Mphase * M * Mbeta0;
  return sunbase * Rphase * R * Rbeta0;
}
```
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item5-lg item12 pd0">
      <img src="/assets/i/6-1.png">
    </div>
  </div>
  <p>图1：地平线：雷利+米氏散射</p>
</div>

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

## 近似大气层
更便宜的大气颜色只需要经验插值。毕竟只是不太准确而不是完全错误。  
实际上，笔者在大多数情况下都使用了它们。但是，这种"低计算"意味着其他成本，整理数据、动画、代码分支。以至于物理实际方法可能比这更容易……  

一个简单的判断基于场景究竟是否具有剧烈的变化，适用于固定时间下硬编码的场景(或者不连续的)，否则，请尽量实现第一个方法。  

我们建议检查两个问题比较这些实现：1，是否会影响该类对象原本的职责？例如天空还可用于照明，这种情况下不会造成影响。但对于其他对象呢？  
2，通常这些实现或多或少会在着色领域上很尴尬。对于天空这个问题不明显，但接下来很严重。我们应该仔细评估这些缺点。  

## 关于体积渲染
类似云的物体在图形中的正确表示通常被认为需要**体积渲染(volumetric rendering)**。  
云是我们下文的目标，因此可能涉及该技术，无论什么方式，读者可以先获取此技术。我们有另一篇有关参与介质的内容。  
先看看是什么样的。  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item4-lg item12 pd0">
      <img src="/assets/i/7-1.png">
    </div>
  </div>
  <p>图2：渲染噪声体积球</p>
</div>

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
## 环境光遮蔽
环境光遮蔽用于计算更好的环境着色。它的结果模拟了表面处于环境光中曝光后的阴影。  
符合环境光源定义的通常是天空，最后乘以该遮挡。  

遮蔽值描述了这样一种情况，对于特定表面光线可能在许多方向上被其他表面遮挡，遮挡越多，该地区就越闭塞，使得它们在环境光的照明下越少。  
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
