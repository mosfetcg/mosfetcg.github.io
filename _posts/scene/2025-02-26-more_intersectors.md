---
layout: page
title:  "更多交叉测试"
author: mosfet
category: scene
tags: 场景
---
本文不包含特定场景，而是讨论几种十分特别的交叉方式，它们某些细节的决定了渲染它们所指定的对象时起到的正确性。  

## 体素与电介质
体素的想法是将空间划分成具有单独意义的小块，这些块在自己的整数体素空间中索引。  
单数值上来讲，你可以将它们与正常空间以完全重叠的方式匹配。想象一下每隔一个`1(floor)`方块的某个角落有一个原子，你可以询问它。  

遍历体素理论上每次只在轨迹上访问一个体素，并且特定体素仅在周期内访问一次。  
下面这个算法**永远**不会访问初始位置的体素，根据图例，这将命中前方的第一个`[4,0]`体素并返回它前方的黄色点`1`，然后是绿色点(视为命中上面的体素)。  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item4-lg item12 pd0 sk bg-raisin01">
      <img src="/assets/i/8-1.png">
    </div>
  </div>
  <p>图1：快速体素交叉草稿</p>
</div>

使用`t`会造成令人不安的精度**伪影**。可以通过设置**(t - C_EPS)**解决。  
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

另一个非常难以解决的问题是在体素中渲染介电表面，尽管体素看上去具有立方体的外形，它们本质上无法解释为封闭图形。换句话说，它们根本不是一个完整几何对象。  
如果我们试图将临近的体素设置为它的另一面呢？那么那个体素本身由谁表示？  
这些疑问迫使我们不得不重新思考一般的遍历算法。特征上讲，始终应该保留每个体素的独立性以及顺序访问。而然，当我们考虑电介质的体素时，必须为它产生多个交点，并且视为访问同一个体素原子，其原子序号不应该增加，那么缺少的只是另一个交点，我们可以临时设置这种信息，并且算法保证下一次可以重新以正确方式访问下一个普通体素。  

总的来说，现在当一束光线访问体素时：  
```
在MAP检查过程中标记出潜在的介电体素，设置为正在访问的状态。将过程设置为1。
正常命中该体素，但提示着色器正在访问介电体素。
0：未知
1：刚刚访问正面（像其他体素一样的情况） 设置折射率等 结束后progress+1
2：模拟新交点，这次我们不检查map，强制视周围全部存在体素，以便命中一个"背面"
？：当2结束时候，就应该离开了体素，接下来关闭访问状态
```
一旦我们这样做，理论上确实有可能成功。而然，笔者疏忽了连续介电体素的情况。这导致了该方案的存疑，因为显然这些虚构的面可能会以错误的方式重叠，并使得状态控制更加复杂。  
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
