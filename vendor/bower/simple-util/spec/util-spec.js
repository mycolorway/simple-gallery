describe("preloadImages", function() {
  describe("should be right when param images is a img src string", function() {
    var img, success;
    success = false;
    img = "https://avatars1.githubusercontent.com/u/607967?s=1";
    beforeEach(function(done) {
      return simple.util.preloadImages(img, function(image) {
        success = !!image;
        return done();
      });
    });
    return it("should be right when param images is a img src string", function() {
      return expect(success).toBeTruthy();
    });
  });
  describe("should only once preload for same image without callback", function() {
    var img;
    img = "https://avatars1.githubusercontent.com/u/607967?s=2";
    beforeEach(function(done) {
      return simple.util.preloadImages(img, function(image) {
        return done();
      });
    });
    return it("should only once preload for same image", function() {
      return expect(simple.util.preloadImages.loadedImages[img]).toBeTruthy();
    });
  });
  describe("should preload again for same image with callback", function() {
    var again, img;
    img = "https://avatars1.githubusercontent.com/u/607967?s=6";
    again = false;
    beforeEach(function(done) {
      return simple.util.preloadImages(img, function(image) {
        return simple.util.preloadImages(img, function(pic) {
          again = true;
          return done();
        });
      });
    });
    return it("should preload again for same image with callback", function() {
      return expect(again).toBeTruthy();
    });
  });
  describe("should be right when param images is a img src array", function() {
    var success;
    success = false;
    beforeEach(function(done) {
      var img;
      img = ["https://avatars1.githubusercontent.com/u/607967?s=3"];
      return simple.util.preloadImages(img, function(image) {
        success = !!image;
        return done();
      });
    });
    return it("should be right when param images is a img src array", function() {
      return expect(success).toBeTruthy();
    });
  });
  return describe("should exec callback without param imgObj when preload error", function() {
    var success;
    success = false;
    beforeEach(function(done) {
      return simple.util.preloadImages('http://localhost:8000/a.png', function(image) {
        success = !!image;
        return done();
      });
    });
    return it("should exec callback without param imgObj when preload error", function() {
      return expect(success).toBeFalsy();
    });
  });
});
