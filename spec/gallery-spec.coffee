gallery = null
galleryEl = null
imageEl = $("""
      <div class="image-list">
        <a href="javascript:;" class="image" data-origin-name="image02" data-origin-size="559,332" data-origin-src="../images/02.png">
          <img alt="image02" src="../images/02.png" title="image02">
        </a>
        <a href="javascript:;" class="image" data-origin-name="image03" data-origin-size="560,337" data-origin-src="../images/03.gif">
          <img alt="image03" src="../images/03.gif" title="image03">
        </a>
        <a href="javascript:;" class="image" data-origin-name="image04" data-origin-size="1330,433" data-origin-src="../images/04.png">
          <img alt="image04" src="../images/04.png" title="image04">
        </a>
      </div>
    """)

beforeEach ->
  imageEl.appendTo("body")

  gallery = simple.gallery
    el: imageEl.find(".image:nth-child(2)")
    itemCls: ".image"
    wrapCls: ".image-list"

  galleryEl = $(".simple-gallery")
  imageEl.css   opacity: 0
  galleryEl.css opacity: 0


afterEach ->
  imageEl.remove()
  $(".simple-gallery").each () ->
    $(@).data("gallery").destroy()



describe "basic usage", ->
  it "displayed", ->
    expect($(".simple-gallery").length).toBe(1)


describe "remove gallery", ->
  it "should remove when click gallery", (done) ->
    galleryEl.click()
    done()


  it "should remove when ESC keydown", (done) ->
    esc = $.Event "keydown.gallery", which: 27
    $(document).trigger(esc)
    done()


  it "should remove when Space keydown", (done) ->
    space = $.Event "keydown.gallery", which: 32
    $(document).trigger(space)
    done()


  afterEach (done) ->
    setTimeout (->
      expect($(".simple-gallery").length).toBe(0)
      done()
    ), 400



describe "picture size", ->
  width = null
  height = null

  it "should not be larger than window", (done) ->
    width = $(".gallery-img").width() - $(window).width()
    height = $(".gallery-img").height() - $(window).height() - 50
    done()


  afterEach (done) ->
    setTimeout (->
      expect(width).toBeLessThan(0)
      expect(height).toBeLessThan(0)
      done()
    ), 400


describe "rotate picture", ->
  scale = null
  newScale = null

  beforeEach (done) ->
    setTimeout (->
      scale = ($(".gallery-img").width() / $(".gallery-img").height()).toFixed(2)
      $(".gallery-detail .turn-right").click()
    ), 400

    setTimeout (->
      newScale = ($(".gallery-img").width() / $(".gallery-img").height()).toFixed(2)
      done()
    ), 800

  it "should rotate the picture when click turn-right button", (done) ->
    expect(scale).toEqual(newScale)
    done()


describe "next picture", ->
  it "should show next picture when Right keydown", (done) ->
    right = $.Event "keydown.gallery", which: 39
    $(document).trigger(right)
    done()


  it "should show next picture when Down keydown", (done) ->
    down = $.Event "keydown.gallery", which: 40
    $(document).trigger(down)
    done()


  afterEach (done) ->
    setTimeout (->
      targetEl = $(".gallery-list .thumb:nth-child(3)")
      console.log targetEl
      expect(targetEl.hasClass("selected")).toBe(true)
      expect($(".link-show-origin").attr("href")).toBe(targetEl.find("img").attr("src"))
      done()
    ), 400


describe "prev picture", ->
  it "should show prev picture when Left keydown", (done) ->
    left = $.Event "keydown.gallery", which: 37
    $(document).trigger(left)
    done()


  it "should show prev picture when Up keydown", (done) ->
    up = $.Event "keydown.gallery", which: 38
    $(document).trigger(up)
    done()


  afterEach (done) ->
    setTimeout (->
      targetEl = $(".gallery-list .thumb:first-child")
      expect(targetEl.hasClass("selected")).toBe(true)
      expect($(".link-show-origin").attr("href")).toBe(targetEl.find("img").attr("src"))
      done()
    ), 400
