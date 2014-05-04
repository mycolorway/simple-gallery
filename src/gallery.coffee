class Gallery extends Widget
  opts:
    el: null # required


  @_tpl:
    gallery: """
      <div class="gallery-wrapper loading">
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
      <p><a href="javascript:;" class="link"><img src="" /></a></p>
    """


  _init: () ->
    if @opts.el is null
      throw "[Gallery] - 内容不能为空"

    Gallery.removeAll()
    @_render()
    @_bind()
    @curThumb.data("gallery", @)


  _render: () ->
    $("body").addClass "no-scroll"
    @curThumb = @opts.el
    @_onThumbChange()

    if @curOriginSrc is null
      return false

    @thumbs = @curThumb.closest( ".attachments, .attachments-preview" )
                .find( "*[data-origin-src]" )

    @_createStage()
    @_createList()

    that = @
    @galleryEl.one simple.transitionEnd(), (e) ->
      that.imgDetail.fadeIn "fast"

    setTimeout (->
      that._renderImage()
      that.galleryWrapper.removeClass "loading"
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
        @_prevThumb()
        return false
      else if /39|40/.test(e.which)
        @_nextThumb()
        return false
    , @)


  _unbind: () ->
    @galleryWrapper.off('.gallery')
    @imgDetail.off('.gallery')
    @thumbsEl.off('.gallery')
    $(document).off('.gallery')


  # 当 curThumb 改变的时候就调用一次，更新当前显示图片的基本信息
  _onThumbChange: () ->
    curThumb = @curThumb

    if curThumb.is('[src]')
      curThumbImg = curThumb
    else
      curThumbImg = curThumb.find('[src]:first')

    @curThumbImg   = curThumbImg
    @curOriginName = curThumb.data('origin-name')
    @curOriginSrc  = curThumb.data('origin-src')
    @curThumbSrc   = curThumbImg.attr('src')
    @curThumbSize  = @_getCurThumbSize()
    @curOriginSize = @_getCurOriginSize()

    @rotatedegrees = 0


  _getCurThumbSize: () ->
    doc = $(document)
    thumbImg = @curThumbImg
    offset = thumbImg.offset()

    return {
      width: thumbImg.width()
      height: thumbImg.height()
    }

  _getCurOriginSize: () ->
    curOriginSize = @curThumb.data("origin-size")
    curThumbSize  = @curThumbSize
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
      width: win.width() - (if @thumbs.length > 1 then 110 else 0) - 40
      height: win.height() - 90

    originSize = originSize or
      width: thumbImg.width
      height: thumbImg.height

    # 根据可视区域的大小计算出图片应该显示成多大
    imgFitSize = @_fitSize(stageSize, originSize)
    imgFitSize.left = (if @thumbs.length > 1 then 110 else 0)
    imgFitSize.top = -50

    @galleryEl.css imgFitSize
    @imgEl.attr
      style: ""
      src: thumbImg.src

    @galleryEl.addClass "loading"
    @imgDetail.fadeIn "fast"

    imgFitSize;


  _onGalleryThumbClick: (e) ->
    that = @
    link = $(e.currentTarget)
    galleryItem = link.parent("p")
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
    @loadingEl = @galleryEl.find(".loading-indicator")

    @imgEl.attr("src", @curThumbSrc)
    @imgDetail.find(".link-show-origin").attr("href", @curOriginSrc)
      .end().find(".link-download").attr("href", @curOriginSrc + "&download=true")
      .end().find(".name").text(@curOriginName)

    @galleryEl.css @curThumbSize
    @galleryWrapper.appendTo ".container.workspace"
    that = @
    setTimeout (->
      that.galleryWrapper.addClass "modal"
    ), 5


  # 创建图片列表
  _createList: () ->
    that = @
    @thumbsEl   = $(Gallery._tpl.thumbs).appendTo(@galleryWrapper)
    galleryMask = @thumbsEl.siblings(".gallery-mask")

    return false if @thumbs.length <= 1

    @thumbs.each ->
      thumb = $(@)
      img   = if thumb.is("[src]") then thumb else thumb.find("[src]:first")
      cls   = if that.curThumb.is(thumb) then "selected" else ""

      $(Gallery._tpl.thumb).addClass(cls)
        .find("img").attr("src", img.attr("src"))
        .end().data("originThumb", thumb)
        .appendTo(that.thumbsEl)

    galleryMask.fadeIn "fast"


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
    imgSize.left = (if @thumbs.length > 1 then 110 else 0)
    imgSize.top = -50

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


  _nextThumb: () ->
    return  if @thumbsEl.find("p:animated").length

    @thumbsEl.find(".selected").next("p").find("a").click()
    if @thumbsEl.find(".selected:hidden").length and @thumbsEl.find("p:visible").next("p:hidden").length
      @thumbsEl.find("p:visible").first().animate(
        width: "0"
        opacity: "0"
        margin: "0"
      , 300, ->
        $(this).hide()
        return
      ).end().next("p:hidden").attr("style", "").fadeIn 300


  _prevThumb: () ->
    return  if @thumbsEl.find("p:animated").length

    @thumbsEl.find(".selected").prev("p").find("a").click()
    if @thumbsEl.find(".selected:hidden").length and @thumbsEl.find("p:visible").prev("p:hidden").length
      @thumbsEl.find("p:visible").last().fadeOut(300)
        .end().prev("p:hidden").attr("style", "opacity:0").animate
          width: "toggle"
          opacity: "1"
        , 300


  _preloadOthers: () ->
    othersEl = @curThumb.parents(".file-images").find("a[data-origin-src]").not(@curThumb).map(->
      $(this).data "origin-src"
    ).get()
    simple.preloadImages othersEl


  _fitSize: (container, size, opts) ->
    opts = $.extend(
      stretch: false
      minWidth: 0
      minHeight: 0
    , opts)
    result =
      width: size.width
      height: size.height

    if opts.stretch or size.width > container.width or size.height > container.height or size.width < opts.minWidth or size.height < opts.minHeight
      if size.width / size.height > container.width / container.height
        result.width = Math.max(container.width, opts.minWidth)
        result.height = result.width * size.height / size.width
      else
        result.height = Math.max(container.height, opts.minHeight)
        result.width = result.height * size.width / size.height
    # result.left = (container.width - result.width) / 2
    # result.top = (container.height - result.height) / 2
    result


  remove: () =>
    @_unbind()
    $("body").removeClass "no-scroll"
    @galleryWrapper.removeClass "modal"
    @imgDetail.fadeOut "fast"
    @thumbsEl.fadeOut "fast"
    @thumbsEl.siblings(".gallery-mask").fadeOut "fast"
    @imgEl.attr "style", ""

    # 这里没有用 this.curThumbSize 的原因是有可能滚动条的位置发生了变化
    # this.curThumbSize 里面的 top,left 值已经不准确了
    # 没有在页面滚动的时候就去更新 this.curThumbSize 的原因
    # 是 top 和 left 只在 show 和 remove 的时候用到，为了效率
    that = @
    curThumbSize = @_getCurThumbSize()

    @galleryEl.css curThumbSize
    @galleryEl.one simple.transitionEnd(), (e) ->
      that.galleryWrapper.trigger("galleryhide").remove()
      that.galleryEl = null
      that = null

  @removeAll: () ->
    $(".gallery-wrapper").each () ->
      gallery = $(@).data("gallery")
      gallery.remove()



@simple ||= {}

$.extend(@simple, {

  gallery: (opts) ->
    return new Gallery opts

})
