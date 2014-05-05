class Gallery extends Widget
  opts:
    el: null
    wrapCls: ""


  @_tpl:
    gallery: """
      <div class="simple-gallery loading">
        <div class="gallery-main">
          <div class="gallery-img">
            <img src="" />
            <div class="loading-indicator"></div>
          </div>
          <div class="gallery-detail hide">
            <span class="name"></span>
            <a href="" class="link-show-origin" target="_blank" title="点击在新窗口查看原图"><i class="fa fa-external-link"></i></a>
            <a href="" class="link-download" target="_blank" title="点击下载图片"><i class="fa fa-download"></i></a>
            <a href="javascript:;" title="点击旋转图片方向" class="turn-right"><i class="fa fa-repeat"></i></a>
          </div>
        </div>
      </div>
    """

    thumbs: """
      <div class="gallery"></div>
    """

    thumb: """
      <p class="thumb"><a href="javascript:;" class="link"><img src="" /></a></p>
    """


  _init: () ->
    if @opts.el is null
      throw "[Gallery] - 内容不能为空"

    Gallery.removeAll()
    @_render()
    @_bind()
    @galleryWrapper.data("gallery", @)


  _render: () ->
    $("body").addClass "no-scroll"
    @curThumb = @opts.el
    @_onThumbChange()

    if @curOriginSrc is null
      return false

    @thumbs = @curThumb.closest( @opts.wrapCls )
                .find( "*[data-origin-src]" )

    @_createStage()
    @_createList()

    that = @
    @galleryEl.one simple.transitionEnd(), (e) ->
      that.imgDetail.fadeIn "fast"

    setTimeout (->
      that._renderImage()
      that.galleryWrapper.removeClass "loading"
      that._scrollToThumb() if that.thumbs.length > 1
      simple.preloadImages that.curOriginSrc, (originImg) ->
        return  if not originImg or not originImg.src
        that.imgEl.attr "src", originImg.src  if that.imgEl
        that.galleryEl.removeClass "loading"  if that.galleryEl
        that._preloadOthers()
    ), 5

  _bind: () ->
    @galleryWrapper.on "click.gallery", $.proxy(@remove, @)

    @imgDetail
    .on("click.gallery", ".name, .link-show-origin, .link-download", (e) ->
      e.stopPropagation()
    ).on "click.gallery", ".turn-right", $.proxy((e) ->
      e.preventDefault()
      e.stopPropagation()
      @_rotate()
    , @)

    @thumbsEl.on "click.gallery", ".link", $.proxy(@_onGalleryThumbClick, @)
    $(document).on "keydown.gallery", $.proxy((e) ->
      if /27|32/.test(e.which)
        @remove()
        return false
      else if /37|38/.test(e.which)
        @thumbsEl.find(".selected").prev(".thumb").find("a").click()
        @_scrollToThumb()
        return false
      else if /39|40/.test(e.which)
        @thumbsEl.find(".selected").next(".thumb").find("a").click()
        @_scrollToThumb()
        return false
    , @)


  _unbind: () ->
    @galleryWrapper.off(".gallery")
    @imgDetail.off(".gallery")
    @thumbsEl.off(".gallery")
    $(document).off(".gallery")


  # 当 curThumb 改变的时候就调用一次，更新当前显示图片的基本信息
  _onThumbChange: () ->
    curThumb = @curThumb

    if curThumb.is("[src]")
      curThumbImg = curThumb
    else
      curThumbImg = curThumb.find("[src]:first")

    @curThumbImg   = curThumbImg
    @curOriginName = curThumb.data("origin-name")
    @curOriginSrc  = curThumb.data("origin-src")
    @curThumbSrc   = curThumbImg.attr("src")
    @curThumbSize  = @_getCurThumbSize()
    @curOriginSize = @_getCurOriginSize()
    @rotatedegrees = 0


  _getCurThumbSize: () ->
    doc = $(document)
    win = $(window)
    thumbImg = @curThumbImg
    offset = thumbImg.offset()

    return {
      width: thumbImg.width()
      height: thumbImg.height()
      top: (offset.top - doc.scrollTop() - (win.height() - thumbImg.height()) / 2) * 2
      left: (offset.left - doc.scrollLeft() - (win.width() - thumbImg.width()) / 2) * 2
    }


  _getCurOriginSize: () ->
    curThumbSize  = @curThumbSize
    curOriginSize = @curThumb.data("origin-size")
    curOriginSize = if curOriginSize then curOriginSize.split(",") else [0,0]
    curOriginSize =
      width: curOriginSize[0] * 1 or curThumbSize.width * 10
      height: curOriginSize[1] * 1 or curThumbSize.height * 10

    curOriginSize


  _renderImage: () ->
    return  unless this.galleryEl

    thumbImg = @curThumbImg[0]
    originSize = @curOriginSize
    win = $(window)
    stageSize =
      width: win.width() - (if @thumbs.length > 1 then 150 else 40)
      height: win.height() - 90

    originSize = originSize or
      width: thumbImg.width
      height: thumbImg.height

    @galleryEl.css @_fitSize(stageSize, originSize)
    @imgEl.attr
      style: ""
      src: thumbImg.src

    @galleryEl.addClass "loading"
    @imgDetail.fadeIn "fast"


  _onGalleryThumbClick: (e) ->
    that = @
    link = $(e.currentTarget)
    galleryItem = link.parent(".thumb")
    originThumb = galleryItem.data("originThumb")
    @curThumb = originThumb
    @_onThumbChange()

    galleryItem.addClass("selected").siblings(".selected").removeClass "selected"
    @imgDetail.find(".name").text(@curOriginName)
      .end().find(".link-show-origin").attr("href", @curOriginSrc)
      .end().find(".link-download").attr("href", @curOriginSrc + "&download=true")
    @_renderImage()

    simple.preloadImages @curOriginSrc, (img) ->
      if img.src.indexOf(that.curOriginSrc) isnt -1
        that.imgEl.attr "src", img.src
        that.galleryEl.removeClass "loading"

    return false


  # 创建当前显示图片的结构
  _createStage: () ->
    @galleryWrapper = $(Gallery._tpl.gallery)

    @galleryEl = @galleryWrapper.find(".gallery-img")
    @imgDetail = @galleryWrapper.find(".gallery-detail")
    @imgEl     = @galleryEl.find("img")

    @imgEl.attr("src", @curThumbSrc)
    @imgDetail.find(".link-show-origin").attr("href", @curOriginSrc)
      .end().find(".link-download").attr("href", @curOriginSrc + "&download=true")
      .end().find(".name").text(@curOriginName)

    @galleryEl.css @curThumbSize
    @galleryWrapper.appendTo "body"
    that = @
    setTimeout (->
      that.galleryWrapper.addClass "modal"
    ), 5


  # 创建图片列表
  _createList: () ->
    that = @
    @thumbsEl = $(Gallery._tpl.thumbs).appendTo(@galleryWrapper)

    return false if @thumbs.length <= 1

    @thumbs.each ->
      thumb = $(@)
      img   = if thumb.is("[src]") then thumb else thumb.find("[src]:first")
      cls   = if that.curThumb.is(thumb) then "selected" else ""

      $(Gallery._tpl.thumb).addClass(cls)
        .find("img").attr("src", img.attr("src"))
        .end().data("originThumb", thumb)
        .appendTo(that.thumbsEl)


  _rotate: () ->
    @rotatedegrees += 90

    # 是否正交，也就是说图片显示的长宽是否有交换
    isOrthogonal = @rotatedegrees / 90 % 2 is 1
    deg = "rotate(" + @rotatedegrees + "deg)"
    originSize = @curOriginSize
    @imgEl.css
      "-webkit-transform": deg
      "-moz-transform": deg
      "-ms-transform": deg
      "-o-transform": deg
      transform: deg

    if isOrthogonal
      originSize =
        width: @curOriginSize.height
        height: @curOriginSize.width

    win = $(window)
    stageSize =
      width: win.width() - (if @thumbs.length > 1 then 110 else 0) - 40
      height: win.height() - 90

    imgSize = @_fitSize(stageSize, originSize)
    @galleryEl.css imgSize

    if isOrthogonal
      offset = (imgSize.width - imgSize.height) / 2
      @imgEl.css
        width: imgSize.height
        height: imgSize.width
        left: offset
    else
      @imgEl.css
        width: imgSize.width
        height: imgSize.height
        left: 0


  _scrollToThumb: () ->
    doc = $(document)
    selectedEl = @thumbsEl.find(".selected")
    @thumbsEl.scrollTop(@thumbsEl.scrollTop() + selectedEl.offset().top - doc.scrollTop() - 5)


  _preloadOthers: () ->
    othersEl = @thumbs.not(@curThumb).map(->
      $(this).data "origin-src"
    ).get()
    simple.preloadImages othersEl


  _fitSize: (container, size) ->
    result =
      width: size.width
      height: size.height
      left: (if @thumbs.length > 1 then 110 else 0)
      top: -50

    if size.width > container.width or size.height > container.height
      if size.width / size.height > container.width / container.height
        result.width = container.width
        result.height = result.width * size.height / size.width
      else
        result.height = container.height
        result.width = result.height * size.width / size.height
    result


  remove: () =>
    @_unbind()
    $("body").removeClass "no-scroll"
    @galleryWrapper.removeClass "modal"
    @imgDetail.fadeOut "fast"
    @thumbsEl.fadeOut "fast"
    @imgEl.attr "style", ""

    that = @
    @galleryEl.css @curThumbSize
    @galleryEl.one simple.transitionEnd(), (e) ->
      that.galleryWrapper.remove()
      that.galleryEl = null
      that = null


  @removeAll: () ->
    $(".simple-gallery").each () ->
      gallery = $(@).data("gallery")
      gallery.remove()



@simple ||= {}

$.extend(@simple, {

  gallery: (opts) ->
    return new Gallery opts

})

@simple.gallery.removeAll = Gallery.removeAll
