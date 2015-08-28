(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module unless amdModuleId is set
    define('simple-gallery', ["jquery","simple-module"], function (a0,b1) {
      return (root['gallery'] = factory(a0,b1));
    });
  } else if (typeof exports === 'object') {
    // Node. Does not work with strict CommonJS, but
    // only CommonJS-like environments that support module.exports,
    // like Node.
    module.exports = factory(require("jquery"),require("simple-module"));
  } else {
    root.simple = root.simple || {};
    root.simple['gallery'] = factory(jQuery,SimpleModule);
  }
}(this, function ($, SimpleModule) {

var Gallery, gallery,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Gallery = (function(superClass) {
  extend(Gallery, superClass);

  function Gallery() {
    this.destroy = bind(this.destroy, this);
    return Gallery.__super__.constructor.apply(this, arguments);
  }

  Gallery.prototype.opts = {
    el: null,
    itemCls: '',
    wrapCls: '',
    save: true
  };

  Gallery.i18n = {
    'zh-CN': {
      rotate_image: '旋转图片',
      download_image: '下载图片',
      view_full_size: '查看原图',
      zoomin_image: '查看大图'
    },
    'en': {
      rotate_image: 'Rotate',
      download_image: 'Download',
      view_full_size: 'View',
      zoomin_image: 'Zoom in'
    }
  };

  Gallery._tpl = {
    thumbs: '<div class=\'gallery-list\'></div>',
    thumb: '<p class=\'thumb\'><a class=\'link\' href=\'javascript:;\'><img src=\'\' /></a></p>'
  };

  Gallery.prototype._init = function() {
    if (this.opts.el === null) {
      throw '[Gallery] - 内容不能为空';
    }
    $('.simple-gallery').each(function() {
      return $(this).data('gallery').destroy();
    });
    this._render();
    this._bind();
    return this.wrapper.data('gallery', this);
  };

  Gallery.prototype._render = function() {
    Gallery._tpl.gallery = "<div class=\"simple-gallery loading\">\n  <a class=\"zoom-in\" href=\"javascript:;\" title=\"" + (this._t('zoomin_image')) + "\">\n    " + (this._t('zoomin_image')) + "\n  </a>\n  <div class=\"gallery-img\">\n    <img src=\"\" />\n    <div class=\"loading-indicator\"></div>\n  </div>\n  <div class=\"gallery-detail hide\">\n    <span class=\"name\"></span>\n    <div class=\"gallery-control\">\n      <a class=\"turn-right\" href=\"javascript:;\" title=\"" + (this._t('rotate_image')) + "\">\n        <i class=\"icon-rotate\"><span>" + (this._t('rotate_image')) + "</span></i>\n      </a>\n      <a class=\"link-download\" href=\"\" title=\"" + (this._t('download_image')) + "\" target=\"_blank\">\n        <i class=\"icon-download\"><span>" + (this._t('download_image')) + "</span></i>\n      </a>\n      <a class=\"link-show-origin\" href=\"\" title=\"" + (this._t('view_full_size')) + "\" target=\"_blank\">\n        <i class=\"icon-external-link\"><span>" + (this._t('view_full_size')) + "</span></i>\n      </a>\n    </div>\n  </div>\n</div>";
    $('html').addClass('simple-gallery-active');
    this.rotatedegrees = 0;
    this.curThumb = this.opts.el;
    this._onThumbChange();
    if (this.curOriginSrc === null) {
      return false;
    }
    this.thumbs = this.curThumb.closest(this.opts.wrapCls).find(this.opts.itemCls);
    this._createStage();
    this._createList();
    return setTimeout(((function(_this) {
      return function() {
        _this._renderImage();
        _this.imgDetail.fadeIn('fast');
        _this.wrapper.removeClass('loading');
        if (_this.thumbs.length > 1) {
          _this._scrollToThumb();
          _this.thumbsEl.fadeIn('fast');
        }
        return _this.util.preloadImages(_this.curOriginSrc, function(originImg) {
          if (!originImg || !originImg.src) {
            return;
          }
          if (_this.img) {
            _this.img.attr('src', originImg.src);
          }
          if (_this.gallery) {
            _this.gallery.removeClass('loading');
          }
          _this._preloadOthers();
          _this._initRoutate();
          return _this.gallery.one(_this.util.transitionEnd(), function(e) {
            return _this._zoomInPosition();
          });
        });
      };
    })(this)), 200);
  };

  Gallery.prototype._bind = function() {
    this.wrapper.on('click.gallery', (function(_this) {
      return function(e) {
        if ($(e.target).closest('.gallery-detail, .gallery-list, .natural-image').length) {
          return;
        }
        return _this.destroy();
      };
    })(this)).on('click.gallery', '.natural-image', function(e) {
      e.stopPropagation();
      return $(this).remove();
    }).on('click.gallery', '.zoom-in', (function(_this) {
      return function(e) {
        e.stopPropagation();
        return _this._renderNatural();
      };
    })(this));
    this.imgDetail.find('.turn-right').on('click.gallery', (function(_this) {
      return function(e) {
        e.stopPropagation();
        return _this._rotate();
      };
    })(this));
    this.thumbsEl.on('click.gallery', '.link', $.proxy(this._onGalleryThumbClick, this));
    $(document).on('keydown.gallery', (function(_this) {
      return function(e) {
        if (/27|32/.test(e.which)) {
          _this.destroy();
          return false;
        } else if (/37|38/.test(e.which)) {
          _this.thumbsEl.find('.selected').prev('.thumb').find('a').click();
          _this._scrollToThumb();
          return false;
        } else if (/39|40/.test(e.which)) {
          _this.thumbsEl.find('.selected').next('.thumb').find('a').click();
          _this._scrollToThumb();
          return false;
        }
      };
    })(this));
    return $(window).on('resize.gallery', (function(_this) {
      return function(e) {
        return _this._zoomInPosition();
      };
    })(this));
  };

  Gallery.prototype._unbind = function() {
    $(document).off('.gallery');
    return $(window).off('.gallery');
  };

  Gallery.prototype._onThumbChange = function() {
    var $curThumb, $curThumbImg;
    $curThumb = this.curThumb;
    if ($curThumb.is('[src]')) {
      $curThumbImg = $curThumb;
    } else {
      $curThumbImg = $curThumb.find('[src]:first');
    }
    this.curThumbImg = $curThumbImg;
    this.curThumbSrc = $curThumbImg.attr('src');
    this.curOriginName = $curThumb.data('image-name') || $curThumb.data('origin-name') || $curThumbImg.attr('alt') || '图片';
    this.curOriginSrc = $curThumb.data('image-src') || $curThumb.data('origin-src') || this.curThumbSrc;
    this.curDownloadSrc = $curThumb.data('download-src');
    this.curThumbSize = this._getCurThumbSize();
    return this.curOriginSize = this._getCurOriginSize();
  };

  Gallery.prototype._getCurThumbSize = function() {
    var $doc, $thumbImg, $win, offset;
    $doc = $(document);
    $win = $(window);
    $thumbImg = this.curThumbImg;
    offset = $thumbImg.offset();
    return {
      width: $thumbImg.width(),
      height: $thumbImg.height(),
      top: (offset.top - $doc.scrollTop() - ($win.height() - $thumbImg.height()) / 2) * 2,
      left: (offset.left - $doc.scrollLeft() - ($win.width() - $thumbImg.width()) / 2) * 2
    };
  };

  Gallery.prototype._getCurOriginSize = function() {
    var curOriginSize;
    curOriginSize = this.curThumb.data('image-size') || this.curThumb.data('origin-size');
    curOriginSize = curOriginSize ? curOriginSize.split(',') : [0, 0];
    curOriginSize = {
      width: curOriginSize[0] * 1 || this.curThumbSize.width * 10,
      height: curOriginSize[1] * 1 || this.curThumbSize.height * 10
    };
    return curOriginSize;
  };

  Gallery.prototype._renderImage = function() {
    var $win, originSize, showZoom, stageSize, thumbImg;
    if (!this.gallery) {
      return;
    }
    $win = $(window);
    thumbImg = this.curThumbImg[0];
    originSize = this.curOriginSize;
    stageSize = {
      width: $win.width() - (this.thumbs.length > 1 ? 150 : 40),
      height: $win.height() - 90
    };
    showZoom = this.curOriginSize.width > stageSize.width || this.curOriginSize.height > stageSize.height;
    this.gallery.css(this._fitSize(stageSize, originSize));
    this.img.attr('src', thumbImg.src);
    this.zoom_in = showZoom ? this.wrapper.find('.zoom-in') : void 0;
    return this.gallery.addClass('loading');
  };

  Gallery.prototype._onGalleryThumbClick = function(e) {
    var galleryItem, link, originThumb;
    if (this.zoom_in) {
      this.zoom_in.hide();
    }
    link = $(e.currentTarget);
    galleryItem = link.parent('.thumb');
    originThumb = galleryItem.data('originThumb');
    this.curThumb = originThumb;
    this._onThumbChange();
    galleryItem.addClass('selected').siblings('.selected').removeClass('selected');
    this.imgDetail.find('.name').text(this.curOriginName).end().find('.link-show-origin').attr('href', this.curOriginSrc).end().find('.link-download').attr('href', this.curDownloadSrc);
    this._renderImage();
    this.util.preloadImages(this.curOriginSrc, (function(_this) {
      return function(img) {
        if (img.src.indexOf(_this.curOriginSrc) !== -1) {
          _this.gallery.removeClass('loading');
          _this.img.attr('src', img.src);
          _this._initRoutate();
          return _this.gallery.one(_this.util.transitionEnd(), function(e) {
            return _this._zoomInPosition();
          });
        }
      };
    })(this));
    return false;
  };

  Gallery.prototype._createStage = function() {
    this.wrapper = $(Gallery._tpl.gallery);
    this.gallery = this.wrapper.find('.gallery-img');
    this.imgDetail = this.wrapper.find('.gallery-detail');
    this.img = this.gallery.find('img');
    this.img.attr('src', this.curThumbSrc);
    this.imgDetail.find('.name').text(this.curOriginName).end().find('.link-show-origin').attr('href', this.curOriginSrc);
    if (this.curDownloadSrc) {
      this.imgDetail.find('.link-download').attr('href', this.curDownloadSrc);
    } else {
      this.imgDetail.find('.link-download').hide();
    }
    this.gallery.css(this.curThumbSize);
    if (this.thumbs.length > 1) {
      this.wrapper.addClass('multi');
    }
    this.wrapper.appendTo('body');
    return setTimeout(((function(_this) {
      return function() {
        return _this.wrapper.addClass('modal');
      };
    })(this)), 5);
  };

  Gallery.prototype._createList = function() {
    this.thumbsEl = $(Gallery._tpl.thumbs).appendTo(this.wrapper);
    if (this.thumbs.length <= 1) {
      return false;
    }
    return this.thumbs.each((function(_this) {
      return function(index, event) {
        var $img, $thumb, cls;
        $thumb = $(event);
        $img = $thumb.is('[src]') ? $thumb : $thumb.find('[src]:first');
        cls = _this.curThumb.is($thumb) ? 'selected' : '';
        return $(Gallery._tpl.thumb).addClass(cls).find('img').attr('src', $img.attr('src')).end().data('originThumb', $thumb).appendTo(_this.thumbsEl);
      };
    })(this));
  };

  Gallery.prototype._rotate = function() {
    var $win, deg, imgSize, isOrthogonal, originSize, stageSize;
    this.rotatedegrees += 90;
    if (this.zoom_in) {
      this.zoom_in.hide();
    }
    if (this.opts.save) {
      this._saveDegree();
    }
    deg = "rotate(" + this.rotatedegrees + "deg)";
    originSize = this.curOriginSize;
    isOrthogonal = this.rotatedegrees / 90 % 2 === 1;
    this.gallery.css({
      '-webkit-transform': deg,
      '-moz-transform': deg,
      '-ms-transform': deg,
      '-o-transform': deg,
      transform: deg
    });
    if (isOrthogonal) {
      originSize = {
        width: this.curOriginSize.height,
        height: this.curOriginSize.width
      };
    }
    $win = $(window);
    stageSize = {
      width: $win.width() - (this.thumbs.length > 1 ? 110 : 0) - 40,
      height: $win.height() - 90
    };
    imgSize = this._fitSize(stageSize, originSize);
    if (isOrthogonal) {
      if (this.util.browser.firefox && imgSize.height < imgSize.width) {
        imgSize.top = ($win.height() + imgSize.top - imgSize.width) / 2;
      }
      this.gallery.css({
        width: imgSize.height,
        height: imgSize.width,
        top: imgSize.top
      });
    } else {
      this.gallery.css({
        width: imgSize.width,
        height: imgSize.height,
        top: imgSize.top
      });
    }
    return this.gallery.one('transitionend webkitTransitionEnd', (function(_this) {
      return function() {
        return _this._zoomInPosition();
      };
    })(this));
  };

  Gallery.prototype._initRoutate = function() {
    var degree, degree_diff, i, key, ref, results, rotate;
    if (this.opts.save) {
      key = "simple-gallery-" + (this.gallery.find('img')[0].src);
      degree = localStorage.getItem(key || 0);
    } else {
      degree = 0;
    }
    degree_diff = ((degree - this.rotatedegrees) % 360 + 360) % 360 / 90;
    results = [];
    for (rotate = i = 0, ref = degree_diff; 0 <= ref ? i < ref : i > ref; rotate = 0 <= ref ? ++i : --i) {
      results.push(this._rotate());
    }
    return results;
  };

  Gallery.prototype._saveDegree = function() {
    var key, value;
    key = "simple-gallery-" + (this.gallery.find('img')[0].src);
    value = this.rotatedegrees % 360;
    return localStorage.setItem(key, value);
  };

  Gallery.prototype._zoomInPosition = function() {
    var diff, left, top;
    if (this.zoom_in) {
      top = this.gallery.prop('offsetTop');
      left = this.gallery.prop('offsetLeft');
      if (this.rotatedegrees % 180 !== 0) {
        diff = (this.gallery.width() - this.gallery.height()) / 2;
        left -= diff;
        top -= diff;
      }
      left = left + this.gallery.width() - this.zoom_in.width() - 16;
      this.zoom_in.css({
        top: top + 5,
        left: left - 5,
        display: 'block'
      });
      return this.zoom_in.show();
    }
  };

  Gallery.prototype._scrollToThumb = function() {
    var $doc, $selected;
    $doc = $(document);
    $selected = this.thumbsEl.find('.selected');
    return this.thumbsEl.scrollTop(this.thumbsEl.scrollTop() + $selected.offset().top - $doc.scrollTop() - 5);
  };

  Gallery.prototype._preloadOthers = function() {
    var $others;
    $others = this.thumbs.not(this.curThumb).map(function() {
      return $(this).data('image-src') || $(this).data('origin-src');
    }).get();
    return this.util.preloadImages($others);
  };

  Gallery.prototype._fitSize = function(container, size) {
    var result;
    result = {
      width: size.width,
      height: size.height,
      top: -50,
      right: (this.thumbs.length > 1 ? 110 : 0),
      left: 0
    };
    if (size.width > container.width || size.height > container.height) {
      if (size.width / size.height > container.width / container.height) {
        result.width = container.width;
        result.height = result.width * size.height / size.width;
      } else {
        result.height = container.height;
        result.width = result.height * size.width / size.height;
      }
    }
    return result;
  };

  Gallery.prototype._renderNatural = function() {
    var deg, height, img, margin_left, margin_top, top, width;
    deg = "rotate(" + this.rotatedegrees + "deg)";
    this.wrapper.find('.natural-image').remove();
    img = this.img.clone().css({
      '-webkit-transform': deg,
      '-moz-transform': deg,
      '-ms-transform': deg,
      '-o-transform': deg,
      transform: deg,
      width: this.curOriginSize.width,
      height: this.curOriginSize.height
    }).wrap('<div class="natural-image"></div>').parent().appendTo(this.wrapper);
    width = this.rotatedegrees % 180 === 0 ? this.curOriginSize.width : this.curOriginSize.height;
    height = this.rotatedegrees % 180 === 0 ? this.curOriginSize.height : this.curOriginSize.width;
    margin_left = width > window.innerWidth ? 0 : 'auto';
    margin_top = height > window.innerHeight ? 0 : 'auto';
    top = (height - this.curOriginSize.height) / 2;
    return this.wrapper.find('.natural-image img').css({
      margin: margin_top + " " + margin_left,
      top: top
    });
  };

  Gallery.prototype.destroy = function() {
    if (this.zoom_in) {
      this.zoom_in.hide();
    }
    $('html').removeClass('simple-gallery-active');
    this._unbind();
    this.wrapper.removeClass('modal').find('.natural-image').remove();
    this.imgDetail.fadeOut('200');
    this.thumbsEl.fadeOut('200');
    if (this.thumbs.length > 1) {
      this.curThumbSize.left += 110;
    }
    this.gallery.css(this.curThumbSize);
    return this.gallery.one(this.util.transitionEnd(), (function(_this) {
      return function(e) {
        return _this.wrapper.remove();
      };
    })(this));
  };

  Gallery.prototype.util = {
    browser: (function() {
      var chrome, firefox, ie, ref, ref1, ref2, ref3, safari, ua;
      ua = navigator.userAgent;
      ie = /(msie|trident)/i.test(ua);
      chrome = /chrome|crios/i.test(ua);
      safari = /safari/i.test(ua) && !chrome;
      firefox = /firefox/i.test(ua);
      if (ie) {
        return {
          msie: true,
          version: ((ref = ua.match(/(msie |rv:)(\d+(\.\d+)?)/i)) != null ? ref[2] : void 0) * 1
        };
      } else if (chrome) {
        return {
          webkit: true,
          chrome: true,
          version: ((ref1 = ua.match(/(?:chrome|crios)\/(\d+(\.\d+)?)/i)) != null ? ref1[1] : void 0) * 1
        };
      } else if (safari) {
        return {
          webkit: true,
          safari: true,
          version: ((ref2 = ua.match(/version\/(\d+(\.\d+)?)/i)) != null ? ref2[1] : void 0) * 1
        };
      } else if (firefox) {
        return {
          mozilla: true,
          firefox: true,
          version: ((ref3 = ua.match(/firefox\/(\d+(\.\d+)?)/i)) != null ? ref3[1] : void 0) * 1
        };
      } else {
        return {};
      }
    })(),
    preloadImages: function(images, callback) {
      var base, i, imgObj, len, loadedImages, results, url;
      (base = arguments.callee).loadedImages || (base.loadedImages = {});
      loadedImages = arguments.callee.loadedImages;
      if (Object.prototype.toString.call(images) === "[object String]") {
        images = [images];
      } else if (Object.prototype.toString.call(images) !== "[object Array]") {
        return false;
      }
      results = [];
      for (i = 0, len = images.length; i < len; i++) {
        url = images[i];
        if (!loadedImages[url] || callback) {
          imgObj = new Image();
          if (callback && Object.prototype.toString.call(callback) === "[object Function]") {
            imgObj.onload = function() {
              loadedImages[url] = true;
              return callback(imgObj);
            };
            imgObj.onerror = function() {
              return callback();
            };
          }
          results.push(imgObj.src = url);
        } else {
          results.push(void 0);
        }
      }
      return results;
    },
    transitionEnd: function() {
      var el, t, transitions;
      el = document.createElement('fakeelement');
      transitions = {
        'transition': 'transitionend',
        'MozTransition': 'transitionend',
        'WebkitTransition': 'webkitTransitionEnd'
      };
      for (t in transitions) {
        if (el.style[t] !== void 0) {
          return transitions[t];
        }
      }
    }
  };

  return Gallery;

})(SimpleModule);

gallery = function(opts) {
  return new Gallery(opts);
};

return gallery;

}));
