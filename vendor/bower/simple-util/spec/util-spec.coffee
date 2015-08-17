describe "preloadImages", ->

  describe "should be right when param images is a img src string", ->
    success = false
    img = "https://avatars1.githubusercontent.com/u/607967?s=1"

    beforeEach (done) ->
      simple.util.preloadImages(img, (image) ->
        success = !!image
        done()
      )

    it "should be right when param images is a img src string", ->
      expect(success).toBeTruthy()



  describe "should only once preload for same image without callback", ->
    img = "https://avatars1.githubusercontent.com/u/607967?s=2"

    beforeEach (done) ->
      simple.util.preloadImages(img, (image) ->
        done()
      )

    it "should only once preload for same image", () ->
      expect(simple.util.preloadImages.loadedImages[img]).toBeTruthy()



  describe "should preload again for same image with callback", ->
    img = "https://avatars1.githubusercontent.com/u/607967?s=6"
    again = false

    beforeEach (done) ->
      simple.util.preloadImages(img, (image) ->
        simple.util.preloadImages(img, (pic) ->
          again = true
          done()
        )
      )

    it "should preload again for same image with callback", () ->
      expect(again).toBeTruthy()




  describe "should be right when param images is a img src array", ->
    success = false

    beforeEach (done) ->
      img = ["https://avatars1.githubusercontent.com/u/607967?s=3"]

      simple.util.preloadImages(img, (image) ->
        success = !!image
        done()
      )

    it "should be right when param images is a img src array", ->
      expect(success).toBeTruthy()



  describe "should exec callback without param imgObj when preload error", ->
    success = false

    beforeEach (done) ->
      simple.util.preloadImages('http://localhost:8000/a.png', (image) ->
        success = !!image
        done()
      )

    it "should exec callback without param imgObj when preload error", ->
      expect(success).toBeFalsy()
