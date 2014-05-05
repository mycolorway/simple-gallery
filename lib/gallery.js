(function() {
  var Gallery,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Gallery = (function(_super) {
    __extends(Gallery, _super);

    function Gallery() {
      this.remove = __bind(this.remove, this);
      return Gallery.__super__.constructor.apply(this, arguments);
    }

    Gallery.prototype.opts = {
      el: null,
      wrapCls: ""
    };

    Gallery._tpl = {
      gallery: "<div class=\"gallery-wrapper loading\">\n  <div class=\"gallery-main\">\n    <div class=\"gallery-img\">\n      <img src=\"\" />\n      <div class=\"loading-indicator\"></div>\n    </div>\n    <div class=\"gallery-detail hide\">\n      <span class=\"name\"></span>\n      <a href=\"\" class=\"link-show-origin\" target=\"_blank\" title=\"点击在新窗口查看原图\"><i class=\"fa fa-external-link\"></i></a>\n      <a href=\"\" class=\"link-download\" target=\"_blank\" title=\"点击下载图片\"><i class=\"fa fa-download\"></i></a>\n      <a href=\"javascript:;\" title=\"点击旋转图片方向\" class=\"turn-right\"><i class=\"fa fa-repeat\"></i></a>\n    </div>\n  </div>\n</div>",
      thumbs: "<div class=\"gallery\"></div>",
      thumb: "<p><a href=\"javascript:;\" class=\"link\"><img src=\"\" /></a></p>"
    };

    Gallery.prototype._init = function() {
      if (this.opts.el === null) {
        throw "[Gallery] - 内容不能为空";
      }
      Gallery.removeAll();
      this._render();
      this._bind();
      return this.curThumb.data("gallery", this);
    };

    Gallery.prototype._render = function() {
      var that;
      $("body").addClass("no-scroll");
      this.curThumb = this.opts.el;
      this._onThumbChange();
      if (this.curOriginSrc === null) {
        return false;
      }
      this.thumbs = this.curThumb.closest(this.opts.wrapCls).find("*[data-origin-src]");
      this._createStage();
      this._createList();
      that = this;
      this.galleryEl.one(simple.transitionEnd(), function(e) {
        return that.imgDetail.fadeIn("fast");
      });
      return setTimeout((function() {
        that._renderImage();
        that.galleryWrapper.removeClass("loading");
        if (that.thumbs.length > 1) {
          that._scrollToThumb();
        }
        return simple.preloadImages(that.curOriginSrc, function(originImg) {
          if (!originImg || !originImg.src) {
            return;
          }
          if (that.imgEl) {
            that.imgEl.attr("src", originImg.src);
          }
          if (that.galleryEl) {
            that.galleryEl.removeClass("loading");
          }
          return that._preloadOthers();
        });
      }), 5);
    };

    Gallery.prototype._bind = function() {
      var doc;
      this.galleryWrapper.on("click.gallery", $.proxy(this.remove, this));
      this.imgDetail.on("click.gallery", ".name, .link-show-origin, .link-download", function(e) {
        return e.stopPropagation();
      }).on("click.gallery", ".turn-right", $.proxy(function(e) {
        e.preventDefault();
        e.stopPropagation();
        return this._rotate();
      }, this));
      this.thumbsEl.on("click.gallery", ".link", $.proxy(this._onGalleryThumbClick, this));
      doc = $(document);
      return doc.on("keydown.gallery", $.proxy(function(e) {
        var selectedEl;
        if (/27|32/.test(e.which)) {
          this.remove();
          return false;
        } else if (/37|38/.test(e.which)) {
          this.thumbsEl.find(".selected").prev("p").find("a").click();
          this._scrollToThumb();
          return false;
        } else if (/39|40/.test(e.which)) {
          selectedEl = this.thumbsEl.find(".selected").next("p").find("a").click();
          this._scrollToThumb();
          return false;
        }
      }, this));
    };

    Gallery.prototype._unbind = function() {
      this.galleryWrapper.off('.gallery');
      this.imgDetail.off('.gallery');
      this.thumbsEl.off('.gallery');
      return $(document).off('.gallery');
    };

    Gallery.prototype._onThumbChange = function() {
      var curThumb, curThumbImg;
      curThumb = this.curThumb;
      if (curThumb.is('[src]')) {
        curThumbImg = curThumb;
      } else {
        curThumbImg = curThumb.find('[src]:first');
      }
      this.curThumbImg = curThumbImg;
      this.curOriginName = curThumb.data('origin-name');
      this.curOriginSrc = curThumb.data('origin-src');
      this.curThumbSrc = curThumbImg.attr('src');
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
      var curOriginSize, curThumbSize;
      curOriginSize = this.curThumb.data("origin-size");
      curThumbSize = this.curThumbSize;
      curOriginSize = curOriginSize ? curOriginSize.split(",") : [0, 0];
      curOriginSize = {
        width: curOriginSize[0] * 1 || curThumbSize.width * 10,
        height: curOriginSize[1] * 1 || curThumbSize.height * 10
      };
      return curOriginSize;
    };

    Gallery.prototype._renderImage = function() {
      var imgFitSize, originSize, stageSize, thumbImg, win;
      if (!this.galleryEl) {
        return;
      }
      thumbImg = this.curThumbImg[0];
      originSize = this.curOriginSize;
      win = $(window);
      stageSize = {
        width: win.width() - (this.thumbs.length > 1 ? 110 : 0) - 40,
        height: win.height() - 90
      };
      originSize = originSize || {
        width: thumbImg.width,
        height: thumbImg.height
      };
      imgFitSize = this._fitSize(stageSize, originSize);
      imgFitSize.left = (this.thumbs.length > 1 ? 110 : 0);
      imgFitSize.top = -50;
      this.galleryEl.css(imgFitSize);
      this.imgEl.attr({
        style: "",
        src: thumbImg.src
      });
      this.galleryEl.addClass("loading");
      this.imgDetail.fadeIn("fast");
      return imgFitSize;
    };

    Gallery.prototype._onGalleryThumbClick = function(e) {
      var galleryItem, link, originThumb, that;
      that = this;
      link = $(e.currentTarget);
      galleryItem = link.parent("p");
      originThumb = galleryItem.data("originThumb");
      this.curThumb = originThumb;
      this._onThumbChange();
      galleryItem.addClass("selected").siblings(".selected").removeClass("selected");
      this.imgDetail.find(".name").text(this.curOriginName).end().find(".link-show-origin").attr("href", this.curOriginSrc).end().find(".link-download").attr("href", this.curOriginSrc + "&download=true");
      this._renderImage();
      simple.preloadImages(this.curOriginSrc, function(img) {
        if (img.src.indexOf(that.curOriginSrc) !== -1) {
          that.imgEl.attr("src", img.src);
          return that.galleryEl.removeClass("loading");
        }
      });
      return false;
    };

    Gallery.prototype._createStage = function() {
      var that;
      this.galleryWrapper = $(Gallery._tpl.gallery);
      this.galleryEl = this.galleryWrapper.find(".gallery-img");
      this.imgDetail = this.galleryWrapper.find(".gallery-detail");
      this.imgEl = this.galleryEl.find("img");
      this.imgEl.attr("src", this.curThumbSrc);
      this.imgDetail.find(".link-show-origin").attr("href", this.curOriginSrc).end().find(".link-download").attr("href", this.curOriginSrc + "&download=true").end().find(".name").text(this.curOriginName);
      this.galleryEl.css(this.curThumbSize);
      this.galleryWrapper.appendTo(".container.workspace");
      that = this;
      return setTimeout((function() {
        return that.galleryWrapper.addClass("modal");
      }), 5);
    };

    Gallery.prototype._createList = function() {
      var that;
      that = this;
      this.thumbsEl = $(Gallery._tpl.thumbs).appendTo(this.galleryWrapper);
      if (this.thumbs.length <= 1) {
        return false;
      }
      return this.thumbs.each(function() {
        var cls, img, thumb;
        thumb = $(this);
        img = thumb.is("[src]") ? thumb : thumb.find("[src]:first");
        cls = that.curThumb.is(thumb) ? "selected" : "";
        return $(Gallery._tpl.thumb).addClass(cls).find("img").attr("src", img.attr("src")).end().data("originThumb", thumb).appendTo(that.thumbsEl);
      });
    };

    Gallery.prototype._rotate = function() {
      var deg, imgSize, isOrthogonal, offset, originSize, stageSize, win;
      this.rotatedegrees += 90;
      isOrthogonal = this.rotatedegrees / 90 % 2 === 1;
      deg = "rotate(" + this.rotatedegrees + "deg)";
      originSize = this.curOriginSize;
      this.imgEl.css({
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
      imgSize.left = (this.thumbs.length > 1 ? 110 : 0);
      imgSize.top = -50;
      this.galleryEl.css(imgSize);
      if (isOrthogonal) {
        offset = (imgSize.width - imgSize.height) / 2;
        return this.imgEl.css({
          width: imgSize.height,
          height: imgSize.width,
          left: offset
        });
      } else {
        return this.imgEl.css({
          width: imgSize.width,
          height: imgSize.height,
          left: 0
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
      othersEl = this.curThumb.parents(".file-images").find("a[data-origin-src]").not(this.curThumb).map(function() {
        return $(this).data("origin-src");
      }).get();
      return simple.preloadImages(othersEl);
    };

    Gallery.prototype._fitSize = function(container, size) {
      var result;
      result = {
        width: size.width,
        height: size.height
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

    Gallery.prototype.remove = function() {
      var that;
      this._unbind();
      $("body").removeClass("no-scroll");
      this.galleryWrapper.removeClass("modal");
      this.imgDetail.fadeOut("fast");
      this.thumbsEl.fadeOut("fast");
      this.imgEl.attr("style", "");
      that = this;
      this.galleryEl.css(this.curThumbSize);
      return this.galleryEl.one(simple.transitionEnd(), function(e) {
        that.galleryWrapper.trigger("galleryhide").remove();
        that.galleryEl = null;
        return that = null;
      });
    };

    Gallery.removeAll = function() {
      return $(".gallery-wrapper").each(function() {
        var gallery;
        gallery = $(this).data("gallery");
        return gallery.remove();
      });
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
