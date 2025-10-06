---
layout: page
title:  "光线追踪-过往明日"
author: mosfet
category: rendering
tags: 渲染 全局照明 路径追踪
---

<style>code:not(pre code) {color:green!important}</style>

## refs
```
cs348b: Image Synthesis Techniques

光线追踪 - lecture1,2
高级直接照明 - lectrue11
经典全局照明 - lectrue12, focg23

1✅ 如下                 LOCKED 10.6
4,5,6,7✅ 无参考
10✅ 直接照明  无参考
11✅ 直接照明2 如下
12✅ 全局照明  如下
```

## 光线追踪
最初与光线追踪相关的渲染算法可追溯到`Ray casting(Appel-1968)`：  
①每像素发出**一条**光线用于寻找对象。  
②在表面另向光源发出**一条**阴影光线检查照明贡献。  

现代术语中这两个过程的目的称为可见性和着色(照明和阴影模型)。由两条主要光线分别完成。这种算法也被划为图像顺序渲染类型，因其典型的迭代方式。  
几个如今熟悉的概念在这里已经存在或揭示，如shadowRay、光源、Scene Object，相机投射的光线称为view ray。现在我们可能习惯更明确的方式定义它们。  

接下来一个的主要改进来自于`An improved Illumination
model for shaded display(Whitted-1979)`。  
Whitted对追踪器的主要改动如下：  
①除了镜子和玻璃，否则总是向光源发送阴影光线。  
②为镜子和玻璃等表面，递归生成新镜面反射光线。  
```cpp
// Ray Tracing
Whitted(ray) {
  L = 0; // 程序层面：顶级堆栈父级评估的表达式，有时需要开始递归调用求解未知量(重用条件分支)，有时结束并归还给上一级使其评估
  if hit_any {
    if that_is_specular_surface      // 若为镜面反射，反射光线，结果未知
      return Whitted(_ray_);
    else if light_not_shadowed       // 若为普通表面，检查遮挡并计算光照 
      L += scatteredIllumination;    // 表示要将光线弹射到光源，可使用简单的直接照明计算，归还给上一级L并计入"总和"(如果存在镜面)
  }
  return L;
}
```
核心要点是区分命中镜面时发生反射，而命中普通对象会结束调用。在反射路径上，会逐步传播最后的结果。  

`路径追踪(path tracing)`被称为一种"Random Walk"，根据渲染方程，其累积值类似为以下程序：  
```cpp
// Path Tracing
PathTrace(ray) {
  L = 0;
  if hit_any {
    L += add_surface_emission;                       // 1
    L += reflection * PathTrace(randomDirection());  // 2
  }
  return L;
}
```
如果不是直接命中光源，Le仅在最后随机命中发光表面(并不是绝对事件)出现一次计入。另外，该代码的逻辑不完整，因为必须声明停止调用，通常遇到Le时，第二部分会被忽略并完成归还。该示例仅说明`L+=`的累积方式，因此，总和中的每个贡献量从光源到初始位置应呈现递减，除非反射率大于1。  

**布林法(Blinn's Law)**  
科技进步时，渲染时间不变。  
As technology advances, rendering time remains constant.  

## 高级直接照明
#### 环境纹理光源(Environment Map Lights)
很容易使用纹理构成的环境光源，处理不同区域亮度差异的采样时(作为光源)，而不是均匀使用PDF，需要进一步考虑问题。  
另外，一起使用环境和单独光源时，也需要注意实现上的区别，但这里并不是关注此问题。  

#### MIS(Multiple Importance Sampling)
Uniform Light Sampling 以均匀的概率对所有光源进行采样。对更重要的光源情况不好。  
Light Importance Sampling 顾名思义，对能量更高、近的光源分配更多，和前者相反。  
BRDF Importance Sampling 根据BRDF采样。仅在对光源反射(前提仍然是光源采样)最强的地方贡献最多。  

注：BSDF(Bidirectional Scattering Distribution Function)比BRDF多折射率信息，就是平时用的那些。  

示例策略：Average of Light + BSDF Sampling。  

使用多个重要样本和pdf平均每个样本。  
```
~= 1/N [Σw1f/p1 + Σw2f/p2+...]
```

#### Splitting(分裂积分器)
略；  

#### 多光采样(Many-Light Sampling)
多光采样设计用于具有数百或数千盏灯的场景，在这些场景中，每个灯的采样在计算上都是昂贵的。  
即使您只随机选择一个光源，计算成本也来自选择在灯表面上选择有效点并确保准确照明的过程。为此有一些代替方法。  

---
## 经典全局照明(Kajiya, 1986)
不同文献导致了这一算法真正理解上的困难。有时错误的渲染结果也难以发现。  

本质上，积分解决了半球环境照明的反射均值问题，即所谓的`Lo`。记住，`Lo/Li`只是对路径上辐射度在两侧不同上下文的不同称呼。对于命中初始光源的`Lo`才有可能贡献整条路径，这类发光表面(照明器)的输出等于`Le`项或者根本没有，无需任何积分计算，因为实践中此次评估的`Lo`不考虑其反射积分，否则需要反复出现求解积分。而对于其他间接表面，大多不发光，也不包含`Le`项，只是传递初始光线。  
因此，算法通常包含到达发现`Le`中止的必要条件，无论从递归还是迭代形式分析都可以得到类似的理解。迭代中，按照相机出发反向查询最方便，可令`Le/Lo/Li`的预计值由`1.0`预留占位，由于当最后被乘以`Li = Lo = Le`时，可以理解到只是延迟了`Li`需要未知值赋值的影响。  
上面这段话，可以验证通常做法与渲染方程的正确匹配性。以避免明显错误。  

#### Energy Balance(能量守恒理论)
不变性(accountability)：系统中放入的能量等于离开的能量，通常通过热。  
```ruby
outgoing - incoming = emit - absorb
                    = emit + incoming - absorb
reflected = incoming - absorb # 反射 = 入 - 吸收
outgoing  = emit + reflected

Lo = Le + Lr = Le + ∫Li
```

#### 问题
尽管全局照明的核心问题已被解决，但通常的渲染方程并非最终有用，除非使用大型灯具或大量样品，否则将导致非常嘈杂的图像。  
这是因为，大多情况下，很难随机命中所谓的`Le`，导致每条路径的贡献都是狭小的。  
如果场景中只有一个很小的灯具，则很难"最终"命中它，产生链式反应，由于所有表面都少接受照明，整体画面非常暗。  

这不符合现实，光源发送更多的光和频率，至少应该直接照亮整个正面，而不是让表面自己尝试命中它(否则是黑暗的)。  
已经开发出有多种强力路径追踪技术的抽象方式来改变这一情况。  

#### 方法1
首先，在每个散射点额外采样一次直接光的结果`dcol`，新建一个变量，持续在路径上累积`col += dcol * rad_li;`直到Li命中Le。  
这种做法不仅可以完全保持独立的路径追踪过程，也考虑了结果中直接光对路径上的累积影响。  
但要注意，取消非漫射材料受到的直接光影响，因为在这一点上只是反射、折射，而不增加光。  
```cpp
col -= dcol * rad_li; // 取消直接贡献
```
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item6-lg item12 pd0">
      <img src="/assets/i/10-1.png">
    </div>
  </div>
  <p>图1：路径追踪 - 方法1[<a href="https://en.wikipedia.org/wiki/Global_illumination" title="">场景参考</a>]</p>
</div>

#### Partitioning The Rendering Equation
```
Li = Lid + Lii
对于Lid，Sample lights+BRDFs, use MIS
对于Lii，递归求解Lo = Le + ∫Lid + ∫Lii
```
`Russian Roulette`基于概率p中止路径，以`1/1-q`缩放贡献。  
```cpp
Spectrum PathLo(Ray ray) {
  BSDF bsdf = isect.GetBSDF();
  Spectrum Ld = DirectLighting(bsdf, wo);
  Spectrum fr = bsdf.Sample_f(wo, & wi, & pdf);
  return (depth == 0 ? isect.Le(wo) : 0.) + Ld +
    fr * PathLo(Ray(isect.P, wi)) * Dot(wi, isect.N) / pdf;
}

Spectrum PathLo(Ray ray) {
  Spectrum Lo = 0, beta = 1;
  while (true) {
    if (depth == 0) Lo += isect.Le(wo);
    BSDF brdf = isect.GetBSDF();

    Lo += beta * DirectLighting(bsdf, wo);

    Spectrum fr = bsdf.Sample_f(wo, &wi, &pdf);
    beta *= fr * Dot(wi, isect.N) / pdf;
  }
  return Lo;
}
// 存在问题
// 度盘
// P(choosing wi |not_terminating) P(not terminating)
    float q = 0.25;
    if (randomFloat() < q) break;
    else beta /= (1-q);
```
改进Russian Roulette。略。  