(function() {
  var gallery, galleryEl, imageEl;

  gallery = null;

  galleryEl = null;

  imageEl = $("<div class=\"image-list\">\n  <a href=\"javascript:;\" class=\"image\" data-origin-name=\"image02\" data-origin-size=\"559,332\" data-origin-src=\"../images/02.png\">\n    <img alt=\"image02\" src=\"../images/02.png\" title=\"image02\">\n  </a>\n  <a href=\"javascript:;\" class=\"image\" data-origin-name=\"image03\" data-origin-size=\"560,337\" data-origin-src=\"../images/03.gif\">\n    <img alt=\"image03\" src=\"../images/03.gif\" title=\"image03\">\n  </a>\n  <a href=\"javascript:;\" class=\"image\" data-origin-name=\"image04\" data-origin-size=\"1330,433\" data-origin-src=\"../images/04.png\">\n    <img alt=\"image04\" src=\"../images/04.png\" title=\"image04\">\n  </a>\n</div>");

  beforeEach(function() {
    imageEl.appendTo("body");
    gallery = simple.gallery({
      el: imageEl.find(".image:nth-child(2)"),
      itemCls: ".image",
      wrapCls: ".image-list"
    });
    galleryEl = $(".simple-gallery");
    imageEl.css({
      opacity: 0
    });
    return galleryEl.css({
      opacity: 0
    });
  });

  afterEach(function() {
    var key;
    imageEl.remove();
    $(".simple-gallery").each(function() {
      return $(this).data("gallery").destroy();
    });
    key = "simple-gallery-" + imageEl.find(".image:nth-child(2)").find("img")[0].src;
    return localStorage.removeItem(key);
  });

  describe("basic usage", function() {
    return it("displayed", function() {
      return expect($(".simple-gallery").length).toBe(1);
    });
  });

  describe("remove gallery", function() {
    it("should remove when click gallery", function(done) {
      galleryEl.click();
      return done();
    });
    it("should remove when ESC keydown", function(done) {
      var esc;
      esc = $.Event("keydown.gallery", {
        which: 27
      });
      $(document).trigger(esc);
      return done();
    });
    it("should remove when Space keydown", function(done) {
      var space;
      space = $.Event("keydown.gallery", {
        which: 32
      });
      $(document).trigger(space);
      return done();
    });
    return afterEach(function(done) {
      return setTimeout((function() {
        expect($(".simple-gallery").length).toBe(0);
        return done();
      }), 400);
    });
  });

  describe("picture size", function() {
    var height, width;
    width = null;
    height = null;
    it("should not be larger than window", function(done) {
      width = $(".gallery-img").width() - $(window).width();
      height = $(".gallery-img").height() - $(window).height() - 50;
      return done();
    });
    return afterEach(function(done) {
      return setTimeout((function() {
        expect(width).toBeLessThan(0);
        expect(height).toBeLessThan(0);
        return done();
      }), 400);
    });
  });

  describe("rotate picture", function() {
    var newScale, scale;
    scale = null;
    newScale = null;
    beforeEach(function(done) {
      setTimeout((function() {
        scale = ($(".gallery-img").width() / $(".gallery-img").height()).toFixed(2);
        return $(".gallery-detail .turn-right").click();
      }), 400);
      return setTimeout((function() {
        newScale = ($(".gallery-img").width() / $(".gallery-img").height()).toFixed(2);
        return done();
      }), 800);
    });
    it("should rotate the picture when click turn-right button", function(done) {
      expect(scale).toEqual(newScale);
      return done();
    });
    it("should save rotation info after rotation", function(done) {
      var key;
      key = "simple-gallery-" + imageEl.find(".image:nth-child(2)").find("img")[0].src;
      expect(localStorage.getItem(key)).toEqual('90');
      return done();
    });
    return it("should rotate to the saved position", function(done) {
      var key;
      imageEl.remove();
      $(".simple-gallery").each(function() {
        return $(this).data("gallery").destroy();
      });
      beforeEach();
      $(".gallery-detail .turn-right").click();
      key = "simple-gallery-" + imageEl.find(".image:nth-child(2)").find("img")[0].src;
      expect(localStorage.getItem(key)).toEqual('180');
      return done();
    });
  });

  describe("next picture", function() {
    it("should show next picture when Right keydown", function(done) {
      var right;
      right = $.Event("keydown.gallery", {
        which: 39
      });
      $(document).trigger(right);
      return done();
    });
    it("should show next picture when Down keydown", function(done) {
      var down;
      down = $.Event("keydown.gallery", {
        which: 40
      });
      $(document).trigger(down);
      return done();
    });
    return afterEach(function(done) {
      return setTimeout((function() {
        var targetEl;
        targetEl = $(".gallery-list .thumb:nth-child(3)");
        console.log(targetEl);
        expect(targetEl.hasClass("selected")).toBe(true);
        expect($(".link-show-origin").attr("href")).toBe(targetEl.find("img").attr("src"));
        return done();
      }), 400);
    });
  });

  describe("prev picture", function() {
    it("should show prev picture when Left keydown", function(done) {
      var left;
      left = $.Event("keydown.gallery", {
        which: 37
      });
      $(document).trigger(left);
      return done();
    });
    it("should show prev picture when Up keydown", function(done) {
      var up;
      up = $.Event("keydown.gallery", {
        which: 38
      });
      $(document).trigger(up);
      return done();
    });
    return afterEach(function(done) {
      return setTimeout((function() {
        var targetEl;
        targetEl = $(".gallery-list .thumb:first-child");
        expect(targetEl.hasClass("selected")).toBe(true);
        expect($(".link-show-origin").attr("href")).toBe(targetEl.find("img").attr("src"));
        return done();
      }), 400);
    });
  });

}).call(this);
