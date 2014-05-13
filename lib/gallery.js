(function() {
  var Gallery,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Gallery = (function(_super) {
    __extends(Gallery, _super);

    function Gallery() {
      this.destroy = __bind(this.destroy, this);
      return Gallery.__super__.constructor.apply(this, arguments);
    }

    Gallery.prototype.opts = {
      el: null,
      itemCls: "",
      wrapCls: ""
    };

    Gallery._tpl = {
      gallery: "<div class=\"simple-gallery loading\">\n  <div class=\"gallery-img\">\n    <img src=\"\" />\n    <div class=\"loading-indicator\"></div>\n  </div>\n  <div class=\"gallery-detail hide\">\n    <span class=\"name\"></span>\n    <a class=\"link-show-origin\" href=\"\" title=\"在新窗口查看原图\" target=\"_blank\"><i class=\"fa fa-external-link\"></i></a>\n    <a class=\"link-download\" href=\"\" title=\"下载图片\" target=\"_blank\"><i class=\"fa fa-download\"></i></a>\n    <a class=\"turn-right\" href=\"javascript:;\" title=\"旋转图片方向\"><i class=\"fa fa-repeat\"></i></a>\n  </div>\n</div>",
      thumbs: "<div class=\"gallery-list\"></div>",
      thumb: "<p class=\"thumb\"><a class=\"link\" href=\"javascript:;\"><img src=\"\" /></a></p>"
    };

    Gallery.prototype._init = function() {
      if (this.opts.el === null) {
        throw "[Gallery] - 内容不能为空";
      }
      $(".simple-gallery").each(function() {
        return $(this).data("gallery").destroy();
      });
      this._render();
      this._bind();
      return this.galleryWrapper.data("gallery", this);
    };

    Gallery.prototype._render = function() {
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
          _this.imgDetail.fadeIn("fast");
          _this.galleryWrapper.removeClass("loading");
          if (_this.thumbs.length > 1) {
            _this._scrollToThumb();
            _this.thumbsEl.fadeIn("fast");
          }
          return simple.preloadImages(_this.curOriginSrc, function(originImg) {
            if (!originImg || !originImg.src) {
              return;
            }
            if (_this.imgEl) {
              _this.imgEl.attr("src", originImg.src);
            }
            if (_this.galleryEl) {
              _this.galleryEl.removeClass("loading");
            }
            return _this._preloadOthers();
          });
        };
      })(this)), 5);
    };

    Gallery.prototype._bind = function() {
      this.galleryWrapper.on("click.gallery", $.proxy(this.destroy, this));
      this.imgDetail.on("click.gallery", ".name, .link-show-origin, .link-download", function(e) {
        return e.stopPropagation();
      }).on("click.gallery", ".turn-right", $.proxy(function(e) {
        e.preventDefault();
        e.stopPropagation();
        return this._rotate();
      }, this));
      this.thumbsEl.on("click.gallery", ".link", $.proxy(this._onGalleryThumbClick, this));
      return $(document).on("keydown.gallery", $.proxy(function(e) {
        if (/27|32/.test(e.which)) {
          this.destroy();
          return false;
        } else if (/37|38/.test(e.which)) {
          this.thumbsEl.find(".selected").prev(".thumb").find("a").click();
          this._scrollToThumb();
          return false;
        } else if (/39|40/.test(e.which)) {
          this.thumbsEl.find(".selected").next(".thumb").find("a").click();
          this._scrollToThumb();
          return false;
        }
      }, this));
    };

    Gallery.prototype._unbind = function() {
      this.galleryWrapper.off(".gallery");
      this.imgDetail.off(".gallery");
      this.thumbsEl.off(".gallery");
      return $(document).off(".gallery");
    };

    Gallery.prototype._onThumbChange = function() {
      var curThumb, curThumbImg;
      curThumb = this.curThumb;
      if (curThumb.is("[src]")) {
        curThumbImg = curThumb;
      } else {
        curThumbImg = curThumb.find("[src]:first");
      }
      this.curThumbImg = curThumbImg;
      this.curThumbSrc = curThumbImg.attr("src");
      this.curOriginName = curThumb.data("image-name") || curThumb.data("origin-name") || curThumbImg.attr("alt") || "图片";
      this.curOriginSrc = curThumb.data("image-src") || curThumb.data("origin-src") || this.curThumbSrc;
      this.curThumbSize = this._getCurThumbSize();
      this.curOriginSize = this._getCurOriginSize();
      return this.rotatedegrees = 0;
    };

    Gallery.prototype._getCurThumbSize = function() {
      var doc, offset, thumbImg, win;
      doc = $(document);
      win = $(window);
      thumbImg = this.curThumbImg;
      offset = thumbImg.offset();
      return {
        width: thumbImg.width(),
        height: thumbImg.height(),
        top: (offset.top - doc.scrollTop() - (win.height() - thumbImg.height()) / 2) * 2,
        left: (offset.left - doc.scrollLeft() - (win.width() - thumbImg.width()) / 2) * 2
      };
    };

    Gallery.prototype._getCurOriginSize = function() {
      var curOriginSize;
      curOriginSize = this.curThumb.data("image-size") || this.curThumb.data("origin-size");
      curOriginSize = curOriginSize ? curOriginSize.split(",") : [0, 0];
      curOriginSize = {
        width: curOriginSize[0] * 1 || this.curThumbSize.width * 10,
        height: curOriginSize[1] * 1 || this.curThumbSize.height * 10
      };
      return curOriginSize;
    };

    Gallery.prototype._renderImage = function() {
      var originSize, stageSize, thumbImg, win;
      if (!this.galleryEl) {
        return;
      }
      win = $(window);
      thumbImg = this.curThumbImg[0];
      originSize = this.curOriginSize;
      stageSize = {
        width: win.width() - (this.thumbs.length > 1 ? 150 : 40),
        height: win.height() - 90
      };
      this.galleryEl.css(this._fitSize(stageSize, originSize));
      this.imgEl.attr("src", thumbImg.src);
      return this.galleryEl.addClass("loading");
    };

    Gallery.prototype._onGalleryThumbClick = function(e) {
      var galleryItem, link, originThumb;
      link = $(e.currentTarget);
      galleryItem = link.parent(".thumb");
      originThumb = galleryItem.data("originThumb");
      this.curThumb = originThumb;
      this._onThumbChange();
      galleryItem.addClass("selected").siblings(".selected").removeClass("selected");
      this.imgDetail.find(".name").text(this.curOriginName).end().find(".link-show-origin").attr("href", this.curOriginSrc).end().find(".link-download").attr("href", this.curOriginSrc + "&download=true");
      this._renderImage();
      simple.preloadImages(this.curOriginSrc, (function(_this) {
        return function(img) {
          if (img.src.indexOf(_this.curOriginSrc) !== -1) {
            _this.imgEl.attr("src", img.src);
            return _this.galleryEl.removeClass("loading");
          }
        };
      })(this));
      return false;
    };

    Gallery.prototype._createStage = function() {
      this.galleryWrapper = $(Gallery._tpl.gallery);
      this.galleryEl = this.galleryWrapper.find(".gallery-img");
      this.imgDetail = this.galleryWrapper.find(".gallery-detail");
      this.imgEl = this.galleryEl.find("img");
      this.imgEl.attr("src", this.curThumbSrc);
      this.imgDetail.find(".name").text(this.curOriginName).end().find(".link-show-origin").attr("href", this.curOriginSrc).end().find(".link-download").attr("href", this.curOriginSrc + "&download=true");
      this.galleryEl.css(this.curThumbSize);
      if (this.thumbs.length > 1) {
        this.galleryWrapper.addClass("multi");
      }
      this.galleryWrapper.appendTo("body");
      return setTimeout(((function(_this) {
        return function() {
          return _this.galleryWrapper.addClass("modal");
        };
      })(this)), 5);
    };

    Gallery.prototype._createList = function() {
      this.thumbsEl = $(Gallery._tpl.thumbs).appendTo(this.galleryWrapper);
      if (this.thumbs.length <= 1) {
        return false;
      }
      return this.thumbs.each((function(_this) {
        return function(index, event) {
          var cls, img, thumb;
          thumb = $(event);
          img = thumb.is("[src]") ? thumb : thumb.find("[src]:first");
          cls = _this.curThumb.is(thumb) ? "selected" : "";
          return $(Gallery._tpl.thumb).addClass(cls).find("img").attr("src", img.attr("src")).end().data("originThumb", thumb).appendTo(_this.thumbsEl);
        };
      })(this));
    };

    Gallery.prototype._rotate = function() {
      var deg, imgSize, isOrthogonal, originSize, stageSize, win;
      this.rotatedegrees += 90;
      deg = "rotate(" + this.rotatedegrees + "deg)";
      originSize = this.curOriginSize;
      isOrthogonal = this.rotatedegrees / 90 % 2 === 1;
      this.galleryEl.css({
        "-webkit-transform": deg,
        "-moz-transform": deg,
        "-ms-transform": deg,
        "-o-transform": deg,
        transform: deg
      });
      if (isOrthogonal) {
        originSize = {
          width: this.curOriginSize.height,
          height: this.curOriginSize.width
        };
      }
      win = $(window);
      stageSize = {
        width: win.width() - (this.thumbs.length > 1 ? 110 : 0) - 40,
        height: win.height() - 90
      };
      imgSize = this._fitSize(stageSize, originSize);
      if (isOrthogonal) {
        if (simple.browser.firefox && imgSize.height < imgSize.width) {
          imgSize.top = (win.height() + imgSize.top - imgSize.width) / 2;
        }
        return this.galleryEl.css({
          width: imgSize.height,
          height: imgSize.width,
          top: imgSize.top
        });
      } else {
        return this.galleryEl.css({
          width: imgSize.width,
          height: imgSize.height,
          top: imgSize.top
        });
      }
    };

    Gallery.prototype._scrollToThumb = function() {
      var doc, selectedEl;
      doc = $(document);
      selectedEl = this.thumbsEl.find(".selected");
      return this.thumbsEl.scrollTop(this.thumbsEl.scrollTop() + selectedEl.offset().top - doc.scrollTop() - 5);
    };

    Gallery.prototype._preloadOthers = function() {
      var othersEl;
      othersEl = this.thumbs.not(this.curThumb).map(function() {
        return $(this).data("image-src") || $(this).data("origin-src");
      }).get();
      return simple.preloadImages(othersEl);
    };

    Gallery.prototype._fitSize = function(container, size) {
      var result;
      result = {
        width: size.width,
        height: size.height,
        left: (this.thumbs.length > 1 ? 110 : 0),
        top: -50
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

    Gallery.prototype.destroy = function() {
      this._unbind();
      this.galleryWrapper.removeClass("modal");
      this.imgDetail.fadeOut("fast");
      this.thumbsEl.fadeOut("fast");
      this.galleryEl.css(this.curThumbSize);
      return this.galleryEl.one(simple.transitionEnd(), (function(_this) {
        return function(e) {
          _this.galleryWrapper.remove();
          return _this.galleryEl = null;
        };
      })(this));
    };

    return Gallery;

  })(Widget);

  this.simple || (this.simple = {});

  $.extend(this.simple, {
    gallery: function(opts) {
      return new Gallery(opts);
    }
  });

}).call(this);
