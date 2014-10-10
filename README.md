simple-gallery
==============

一个基于 [Simple Module](https://github.com/mycolorway/simple-module) 的图片预览组件，[点此预览](http://mycolorway.github.io/simple-gallery/)。


### 一、如何使用

**1. 下载并引用**

通过 `bower install` 下载依赖的第三方库，然后在页面中引入这些文件：

```html
<link rel="stylesheet" type="text/css" href="[style path]/font-awesome.css" />
<link rel="stylesheet" type="text/css" href="[style path]/gallery.css" />

<script type="text/javascript" src="[script path]/jquery.min.js"></script>
<script type="text/javascript" src="[script path]/module.js"></script>
<script type="text/javascript" src="[script path]/util.js"></script>
<script type="text/javascript" src="[script path]/galery.js"></script>
```

**2. 初始化配置**

我们需要在页面的脚本里初始化 simple-gallery：

```javascript
simple.tree({
    el: null,       // * 必须（当前图片）
    itemCls: "",    // 需要预览图片的 Class 名称
    wrapCls: ""     // 需要预览图片上层元素的 Class 名称，可成组预览图片
});
```

`el` 元素可增加 `data-image-name` `data-image-size` `data-image-src` 属性，分别用于显示图片名称、控制图片尺寸、加载原图地址。

```html
<a href="javascript:;" class="image" data-image-name="image02" data-image-size="559,332" data-image-src="images/02.png">
    <img alt="image02" src="images/02.png" title="image02">
</a>
```

### 二、方法

**destroy()**

恢复到初始化之前的状态。

