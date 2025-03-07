---
layout: page
title:  "更真实的环境"
author: mosfet
category: scene
tags: 场景
---
本文不包含特定场景，而是讨论在场景中通常可能使用的一些实用技术。  

图形学中的一个常见词是**程序化(procedural)**，旨在用特定算法生成目标。  
这些主题的实现方式，本质上取决于目的和渲染方式是什么。  
我们使用一个非常普通的渲染器作为示例，使用SDF寻找表面，并启用路径积分。以提供体积渲染的可能性。  
## **PHYSICAL BASED**?你真的需要吗
真实物理现象的结果可以通过精确计算表达。但是一旦有人转向近似，通常会发现更简单的实践模型。  
好处是降低了对理论的要求，读者或者笔者可能不是精通任何物理、数学、程序其中之一的人。但可以获得不错的效果。  

另一个提示是，研究一个实现通常最好从实际、全面的观察开始。  
并且图形程序员应该意识到——从观察者的角度思考场景。思考观察者会看见什么，然后再采取行动，因为这就是最终目的。  
例如，大气通常从来不会被实际建模为几何对象，但可以达成一种大气存在的假象，这就是为什么程序方式很流行。  

## 图像背景
第一种方法是使用图像，如果使用图片作为背景，那么就根本不需要任何操作。  
因此，第一种方式，①使用**图像**在这里一笔带过，典型用法是纹理映射立方体或球形图像。  
程序性背景总是比图像更好。  

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
有时候对这种形状似乎有些理解偏差，水平线以上的可视范围实际上是一种**圆段**。朝着水平方向看见比单个垂直高度多得多的空间是很正常的。  

只是在单位球中进行采样并获取距离点将不匹配该形状。一种方式是参考单位垂直高度和角度进行缩放，穹掠角的实际距离越远(以垂直1为单位)。  
因此评估大气边缘的近似倍率由以下公式近似：  
```
d = 1.0 / dot(v, n)
```

用该因子修正后的距离更容易评估真实情况下最大的距离，以分配远处的云等对象。尽管圆环中任何地方都可能垂直地分布一些云，而不是命中的点附近。  
观察中，远处的云通常很小，接近地平线。距离影响大小。这种差异在现实中很明显。  
对于云的颜色，密集的云层外部显示白色，薄者显露背景，被光源方向直接照明的厚云层，底部将额外呈现高对比的黑影。  

## physical based atmosphere
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
参考我们的体积渲染方程，所有βE项将用于积分到光学深度然后用于`T`项。  
```ruby
Lo = ∫all_line_dx|TS dx #(该T沿着视线减弱)
# S(p) = s(p)∫all_sphere|ρLi dv
```
问题是内散射积分S中的使用的光线是什么？(甚至我们正在计算天空光线)。  
下列给出评估它的方式，有关这一点的区别和影响，笔者不再深入研究。  
要点是每个S中必须重新计算ro到太阳的T，这需要一条完整的子射线完成。  
```ruby
S -> SunBase * T2(sun_dx_line); #(沿着太阳减弱)
  -> SunBase * T2(sun_dx_line) * ρ
  -> SunBase * T2(sun_dx_line) * ρ * βS(h)  # 注意是S不是E
S = ∫all_sphere| ↑

# 只计算右侧的积分更容易计算T。  
T1(total_dx) = exp(-od = ∫βEdx) 
             = exp(-β(0) * ∫all_line_dx|exp(-h/HR)dx)
```
最后结果来自于两种散射贡献的和，可放在同一个循环中同步完成。  
```ruby
LoR + LoM

# 对于每个值，这里有一个代替形式：
Sky = SunBase * ρ ∫all_line_dx|T1T2βS(h)dx
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

  // 将用户输入位置参考到地球中心的位系中，地面处为半径，高度为ro - re
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
  float Rbeta_total = 0.0, Mbeta_total = 0.0; // 重复mie

  for (int i = 1; i <= int(segement); i++) {
    // 计算T1
    float h = length(ro) - re;

    Rbeta_total += exp(-h / hr) * dx;
    vec3 RT1 = exp(-Rbeta0 * Rbeta_total);
    Mbeta_total += exp(-h / hm) * dx; // 重复mie
    vec3 MT1 = exp(-Mbeta0 * Mbeta_total) * 1.1; // betaE * 1.1

    // 计算S、和T2(发射sd)
    float segement2 = 8.0;
    vec3 ro2 = ro;
    float t2 = iSphere(ro2, sd, vec3(0.0), ra).y;
    float dx2 = t2 / segement2;

    float Rbeta_total2, Mbeta_total2 = 0.0; // 重复mie
    for (int j = 1; j <= int(segement2); j++) {
      float h2 = length(ro2) - re;

      Rbeta_total2 += exp(-h2 / hr) * dx2;
      Mbeta_total2 += exp(-h2 / hm) * dx2; // 重复mie

      ro2 += sd * dx2;
    }
    vec3 RT2 = exp(-Rbeta0 * Rbeta_total2);
    vec3 MT2 = exp(-Mbeta0 * Mbeta_total2) * 1.1; // 重复mie

    // 累积到结果，注意只是积分项
    R += RT1 * RT2 * Rbeta0 * exp(-h / hr) * dx;
    M += MT1 * MT2 * Mbeta0 * exp(-h / hm) * dx;

    // 之后再移动
    ro += rd * dx;
  }
  return sunbase * (Rphase * R + Mphase * M);
  return sunbase * Mphase * M;
  return sunbase * Rphase * R;
}
```
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item6-lg item12 pd0">
      <img src="/assets/i/6-1.png">
    </div>
  </div>
  <p>图1：地平线：雷利+米氏散射</p>
</div>

## 圆盘
圆盘简易地表示天体，根据时间移动，通常的一个实例是指示太阳的光源位置。  
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
disk += mix(ring_mask * vec3(1.0, 0.1, 0.0), ring_mask * vec3(1.0), dist); // 光晕不跟随albedo外环过度到白色
```

## 近似插值
比物理更便宜的是直接根据经验插值。  
实际上，笔者在大多数情况下都使用了它们。但是，这种非物理的经验程序化很容易造成混乱。  
因为它们本质上不是真正的对象，第一是几乎无法直接参与场景照明，最后必然出现单独着色的尴尬情况。  

由于缺乏对象，这类系统中本身所含的要素，无法利用任何着色模型。另外，一旦分支，就会造成混乱。  

## 关于体积云
目前对云的正确视觉结果定义来自**体积渲染(volumetric rendering)**。  

先看看是什么样的。参与介质的渲染请见另一篇帖子。  
```
https://graphics.stanford.edu/courses/cs348b-20-spring-content/lectures/17_volume/17_volume_slides.pdf
https://www.scratchapixel.com/lessons/3d-basic-rendering/volume-rendering-for-developers/volume-rendering-summary-equations.html
```
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item4-lg item12 pd0">
      <img src="/assets/i/7-1.png">
    </div>
  </div>
  <p>图1：噪声单位体积球</p>
</div>

## 近似云
我一直最想删除的一段话是提醒自己不要使用2D噪声。以避免遇到一些纹理映射的奇怪问题。  
读者需要先理解2DFBM。然后方便地扩展到3D噪声，这类代码需要重复劳动并且扩展原理很简单。借助AI来查找此类基础代码。顺便一提，分析错误也很有效，特别是一些奇怪的命中交叉问题。  

如前所述，它们通常很难正确着色。使用什么采样也非常困扰。如果都选择在边界附近，那么结果很容易与事实不符。  
用它们的一个基本理由是在白天场景中看不出错误的情况。而晚上或者傍晚则很难、甚至无法近似出正确的颜色。  
至少两个样本总是比单个更好，更有层次感，显著减少聚集或者扁平感。  
对于着色，可以像我这样，低密度混合背景和白色，中间为白色，最高为灰色。  
```cpp
// 处理大气弧度
float d = 1.0 / dot(v, vec3(0.0, 0.0, 1.0));
if (v.z < 0.0) return sky;
float op_curvature_mask = smoothstep(55.0, 1.0, d);

vec3 p1 = v * d + wind_dir * op_curvature_mask * u_time;
vec3 p2 = 1.2 * v * d + wind_dir * op_curvature_mask * u_time;
float dense = (cloudf(p1 + cloudf(p1, 0.5, 2.0, 0.5), 0.5, 2.0, 0.5) +
  cloudf(p2 + cloudf(p2, 0.5, 2.0, 0.5), 0.5, 2.0, 0.5)) * 0.5;
dense = smoothstep(0.5, 0.7, dense * op_curvature_mask);

if (dense == 0.0) return sky;
if (dense < 0.75) return sky + vec3(dense * 1.33);
return vec3(1.0 - 0.1* pow((dense - 0.75) * 4.0, 4.0));
```

<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item4-lg item12 pd0">
      <img src="/assets/i/6-2.png">
    </div>
  </div>
  <p>图2：近似一些云</p>
</div>

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
