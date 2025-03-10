---
layout: page
title:  "更多交叉测试"
author: mosfet
category: scene
tags: 场景
---
我们讨论几种十分特别的交叉方式，它们的某些细节决定了渲染它们所指定的对象时起到的正确性。  

## 体素与电介质
体素是空间划分形式建模的一种例子，首先要用某种数据表示单元的状态，通常可以是任何函数，只不过域强制评估整数。  
随后必须为单元配置几何的表现形式以及交叉方式，通常全部都结合在遍历算法中，遍历算法会直接返回该体素对应表面交点。表面的表达受到遍历行为以及体素的访问顺序限制。  

下面这个算法**永远**不会访问初始位置的体素。  
根据图例，第一次命中前方的第一个`[4,0]`体素并返回它前方的黄色点`1`，然后是绿色点(视为命中上面的体素)。  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item4-lg item12 pd0 sk bg-raisin01">
      <img src="/assets/i/8-1.png">
    </div>
  </div>
  <p>图1：快速体素交叉草稿</p>
</div>

直接使用`t`会造成令人不安的**伪影**。我尝试了几种算法，似乎都存在这种情况。可以临时设置**(t - C_EPS)**。  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item6-lg item12 pd0 sk bg-raisin01">
      <img src="/assets/i/8-2.png">
    </div>
    <div class="x la item6-lg item12 pd0 sk bg-raisin01">
      <img src="/assets/i/8-3.png">
    </div>
  </div>
  <p>图2：伪像（左侧）</p>
</div>

一个非常难以解决的问题是在这种算法中将它们渲染为介电材料，因为它们本质上没有被作为正常的3D对象进行表示，缺少"体积"。  
如果我们试图将临近的体素设置为它的另一面呢？那么那个体素本身由谁表示？  
事实上这完全受到了算法牵制。特征上讲，应当始终保留每个体素的基本独立性以及互斥的访问行为。而然，当我们考虑电介质的体素时，必须为它产生多个交点，并且视为访问同一个体素原子，其原子序号不应该增加，缺少的只是另一个交点，我们可以临时设置这种信息，并且算法保证下一次可以重新以正确方式访问下一个普通体素。  

总的来说，现在当一束光线访问体素时：  
```
在MAP检查过程中标记出潜在的介电体素，设置为正在访问的状态。将过程设置为1。
正常命中该体素，着色器已被提示正在访问介电体素。
0：未知
1：刚刚访问正面（普通体素的情况） 设置折射率等 结束后progress+1
2：模拟新交点，这次我们不检查map(这将导致重新设置状态，并且索引递增后是错误的)，强制视周围全部存在体素，以便命中一个"背面"
？：当2结束时候，就应该离开了体素，接下来关闭访问状态，并使索引访问恢复
```
理论上确实有可能成功。而然，笔者似乎疏忽了某种情况，这导致了该方案可行性的存疑。在连续的介电排列中，这些虚构的面可能会以错误的方式重叠，并使得状态控制更加复杂。  
本节还提供了一个不带介电的演示，请见下。  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item6-lg item12 pd0 sk bg-raisin01">
      <img src="/assets/i/8-4.png">
    </div>
    <div class="x la item6-lg item12 pd0 sk bg-raisin01">
      <img src="/assets/i/8-5.png">
    </div>
  </div>
  <p>图3：孤零零的水方块</p>
</div>

<iframe src="https://editor.p5js.org/mosfet-archive/full/SkgyxJINS" width="740" height="740" class="x la dspln dsplb-md"></iframe>

---
## SDF与电介质
介电材料同样很难在使用SDF的光线行进中默认实现。因为光线必须继续穿过在通常情况下已停靠并结束的正面，然后穿越内部(SDF)以便发现第二个交点。  
①第一个问题是距离场在内部原本是负值，此时必须设为绝对值。  
②表面吸附现象。当光线停靠表面太近时，重复发现过小的SDF值会导致重复的交点判定。对于散射而言这是致命的，如果被吸附了，必须丢弃当前的表面并沿续到下一个表面。
```cpp
float marching( in vec3 start, in vec3 dir, out int id) {
  float traveled = 0.0;
  bool adsorbed = abs(scene(start, id)) < C_EPS;

  for (int i = 0; i < RM_MAXDETCS; ++i) {
    vec3 current = start + traveled * dir;
    float safe_step = abs(scene(current, id));
    if (adsorbed && safe_step > C_EPS) adsorbed = false;

    // 勿使用误差，因为不是单次行进
    if (!adsorbed && safe_step < C_EPS) return traveled;
    if (traveled > RM_ABORT_MAXDIST) break;
    traveled += safe_step;
  }
  return INF;
}
```
③小心内部SDF定义的破碎。SDF必须正确实现内部场。从而令负值内部距离的绝对值也为正确。  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item3-lg item12 pd0 sk bg-raisin01">
      <img src="/assets/i/8-6.png">
    </div>
  </div>
  <p>图4：内部破碎的场</p>
</div>

④最后一个极端问题发生在介电内部还存在其他物体时，SDF将拒绝所有> 0的对象，应该使SDF只返回`[0, INF]`。  

基本上，这些就是一个SDF路径追踪器的全部差异。  
```cpp
vec3 transport( in vec3 ray_origin, in vec3 ray_path) {
  for (i = 1; i <= RT_RECURSION; i++) {
    vec3 normal;
    float t = marching(ray_origin, ray_path, id);

    if (t < INF) {
      vec3 p = ray_origin + t * ray_path;
      normal = gradnormal(p);
      bool front_face = H_set_faced_normal(ray_path, normal);
      Material material = object_mat(id, p, normal);

      // COPY BRDF
      if (material.mid == M_DIFFUSE) {
        ray_path = normal + H_random_unit_vector();
        albedo *= material.albedo;
      } 
      //...
      ray_origin = p;
    } else
  }
}
 // 分层速度很慢，因此。仅单位像素采样
st -= half_pixel;
half_pixel *= 2.0;
vec3 lens_origin = camera + vec3(lens_radius * H_disk_random(), 0.0);
vec3 viep_hole = camera + vec3(st + vec2(half_pixel.x * rand(), half_pixel.y * rand()), focus_dist);
vec3 rd = normalize(vec3(viep_hole - lens_origin));
rd = camera_rotation * rd;
return transport(lens_origin, rd);
```
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item6-lg item12 pd0 sk bg-raisin01">
      <img src="/assets/i/8-7.png">
    </div>
  </div>
  <p>图5：SDF中的电介质</p>
</div>