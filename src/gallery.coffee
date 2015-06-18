class Gallery extends SimpleModule

  opts:
    el: null
    itemCls: ''
    wrapCls: ''
    save: true

  @i18n:
    'zh-CN':
      rotate_image: '旋转图片'
      download_image: '下载图片'
      view_full_size: '查看原图'
      zoomin_image: '查看大图'
    'en':
      rotate_image: 'Rotate'
      download_image: 'Download'
      view_full_size: 'View'
      zoomin_image: 'Zoom in'

  @_tpl:
    thumbs: '''
      <div class='gallery-list'></div>
    '''

    thumb: '''
      <p class='thumb'><a class='link' href='javascript:;'><img src='' /></a></p>
    '''

  _init: () ->
    if @opts.el is null
      throw '[Gallery] - 内容不能为空'

    $('.simple-gallery').each () ->
      $(@).data('gallery').destroy()

    @_render()
    @_bind()
    @wrapper.data('gallery', @)


  _render: () ->
    Gallery._tpl.gallery = """
      <div class="simple-gallery loading">
        <a class="zoom-in" href="javascript:;" title="#{@_t('zoomin_image')}">
          <i class="icon-rotate">#{@_t('zoomin_image')}</i>
        </a>
        <div class="gallery-img">
          <img src="" />
          <div class="loading-indicator"></div>
        </div>
        <div class="gallery-detail hide">
          <span class="name"></span>
          <div class="gallery-control">
            <a class="turn-right" href="javascript:;" title="#{@_t('rotate_image')}">
              <i class="icon-rotate"><span>#{@_t('rotate_image')}</span></i>
            </a>
            <a class="link-download" href="" title="#{@_t('download_image')}" target="_blank">
              <i class="icon-download"><span>#{@_t('download_image')}</span></i>
            </a>
            <a class="link-show-origin" href="" title="#{@_t('view_full_size')}" target="_blank">
              <i class="icon-external-link"><span>#{@_t('view_full_size')}</span></i>
            </a>
          </div>
        </div>
      </div>
    """

    $('html').addClass 'simple-gallery-active'
    @rotatedegrees = 0
    @curThumb = @opts.el
    @_onThumbChange()

    if @curOriginSrc is null
      return false

    @thumbs = @curThumb.closest(@opts.wrapCls).find(@opts.itemCls)

    @_createStage()
    @_createList()

    setTimeout (=>
      @_renderImage()
      @imgDetail.fadeIn 'fast'
      @wrapper.removeClass 'loading'

      if @thumbs.length > 1
        @_scrollToThumb()
        @thumbsEl.fadeIn 'fast'

      @util.preloadImages @curOriginSrc, (originImg) =>
        return  if not originImg or not originImg.src

        @img.attr('src', originImg.src) if @img
        @gallery.removeClass 'loading'  if @gallery
        @_preloadOthers()
        @_initRoutate()
        @gallery.one 'transitionend webkitTransitionEnd', =>
          @_zoomInPosition()
    ), 5


  _bind: () ->
    @wrapper.on 'click.gallery', (e) =>
      if $(e.target).closest('.gallery-detail, .gallery-list, .natural-image').length
        return
      @destroy()

    .on 'click.gallery', '.natural-image', (e) ->
      e.stopPropagation()
      $(@).remove()

    .on 'click.gallery', '.zoom-in', (e) =>
      e.stopPropagation()
      @_renderNatural()

    @imgDetail.find('.turn-right').on 'click.gallery', (e) =>
      e.stopPropagation()
      @_rotate()

    @thumbsEl.on 'click.gallery', '.link', $.proxy(@_onGalleryThumbClick, @)
    $(document).on 'keydown.gallery', (e) =>
      if /27|32/.test(e.which)
        @destroy()
        return false
      else if /37|38/.test(e.which)
        @thumbsEl.find('.selected').prev('.thumb').find('a').click()
        @_scrollToThumb()
        return false
      else if /39|40/.test(e.which)
        @thumbsEl.find('.selected').next('.thumb').find('a').click()
        @_scrollToThumb()
        return false
    $(window).on 'resize.gallery',(e) =>
      @_zoomInPosition()


  _unbind: () ->
    @wrapper.off '.gallery'
    @img.off '.gallery'
    @imgDetail.off '.gallery'
    @thumbsEl.off '.gallery'
    $(document).off '.gallery'
    $(window).off '.gallery'


  # 当 curThumb 改变的时候就调用一次，更新当前显示图片的基本信息
  _onThumbChange: () ->
    $curThumb = @curThumb

    if $curThumb.is '[src]'
      $curThumbImg = $curThumb
    else
      $curThumbImg = $curThumb.find '[src]:first'

    @curThumbImg = $curThumbImg
    @curThumbSrc = $curThumbImg.attr 'src'
    @curOriginName = $curThumb.data('image-name') or $curThumb.data('origin-name') or $curThumbImg.attr('alt') or '图片'
    @curOriginSrc = $curThumb.data('image-src') or $curThumb.data('origin-src') or @curThumbSrc
    @curDownloadSrc = $curThumb.data('download-src')
    @curThumbSize = @_getCurThumbSize()
    @curOriginSize = @_getCurOriginSize()


  _getCurThumbSize: () ->
    $doc = $(document)
    $win = $(window)
    $thumbImg = @curThumbImg
    offset = $thumbImg.offset()

    return {
      width:  $thumbImg.width()
      height: $thumbImg.height()
      top:    (offset.top - $doc.scrollTop() - ($win.height() - $thumbImg.height()) / 2) * 2
      left:   (offset.left - $doc.scrollLeft() - ($win.width() - $thumbImg.width()) / 2) * 2
    }


  _getCurOriginSize: () ->
    curOriginSize = @curThumb.data('image-size') or @curThumb.data('origin-size')
    curOriginSize = if curOriginSize then curOriginSize.split(',') else [0,0]
    curOriginSize =
      width:  curOriginSize[0] * 1 or @curThumbSize.width * 10
      height: curOriginSize[1] * 1 or @curThumbSize.height * 10

    curOriginSize


  _renderImage: () ->
    return unless @gallery

    $win = $(window)
    thumbImg = @curThumbImg[0]
    originSize = @curOriginSize
    stageSize =
      width: $win.width() - (if @thumbs.length > 1 then 150 else 40)
      height: $win.height() - 90
    showZoom = @curOriginSize.width > stageSize.width or @curOriginSize.height > stageSize.height

    @gallery.css @_fitSize(stageSize, originSize)
    @img.attr('src', thumbImg.src)

    @gallery.addClass 'loading'
      .find('.zoom-in').toggle showZoom


  _onGalleryThumbClick: (e) ->
    link        = $(e.currentTarget)
    galleryItem = link.parent '.thumb'
    originThumb = galleryItem.data 'originThumb'
    @curThumb   = originThumb
    @_onThumbChange()

    galleryItem.addClass 'selected'
      .siblings '.selected'
      .removeClass 'selected'

    @imgDetail.find('.name').text(@curOriginName)
      .end().find('.link-show-origin').attr('href', @curOriginSrc)
      .end().find('.link-download').attr('href', @curDownloadSrc)
    @_renderImage()

    @util.preloadImages @curOriginSrc, (img) =>
      if img.src.indexOf(@curOriginSrc) isnt -1
        @gallery.removeClass 'loading'
        @img.attr('src', img.src)
        @_initRoutate()

    return false


  # 创建当前显示图片的结构
  _createStage: () ->
    @wrapper = $(Gallery._tpl.gallery)

    @gallery = @wrapper.find '.gallery-img'
    @imgDetail = @wrapper.find '.gallery-detail'
    @img = @gallery.find 'img'

    @img.attr('src', @curThumbSrc)
    @imgDetail.find('.name').text(@curOriginName)
      .end().find('.link-show-origin').attr('href', @curOriginSrc)

    if @curDownloadSrc
      @imgDetail.find('.link-download').attr('href', @curDownloadSrc)
    else
      @imgDetail.find('.link-download').hide()

    @gallery.css @curThumbSize
    @wrapper.addClass 'multi' if @thumbs.length > 1
    @wrapper.appendTo 'body'
    setTimeout (=>
      @wrapper.addClass 'modal'
    ), 5


  # 创建图片列表
  _createList: () ->
    @thumbsEl = $(Gallery._tpl.thumbs).appendTo(@wrapper)
    return false  if @thumbs.length <= 1

    @thumbs.each (index, event) =>
      $thumb = $(event)
      $img = if $thumb.is '[src]' then $thumb else $thumb.find '[src]:first'
      cls = if @curThumb.is($thumb) then 'selected' else ''

      $(Gallery._tpl.thumb).addClass(cls)
        .find('img').attr('src', $img.attr('src'))
        .end().data('originThumb', $thumb)
        .appendTo(@thumbsEl)


  _rotate: () ->
    $('.zoom-in').hide()
    @rotatedegrees += 90

    if @opts.save
      @_saveDegree()

    # 是否正交，也就是说图片显示的长宽是否有交换
    deg = 'rotate(' + @rotatedegrees + 'deg)'
    originSize = @curOriginSize
    isOrthogonal = @rotatedegrees / 90 % 2 is 1

    @gallery.css
      '-webkit-transform': deg
      '-moz-transform': deg
      '-ms-transform': deg
      '-o-transform': deg
      transform: deg

    if isOrthogonal
      originSize =
        width: @curOriginSize.height
        height: @curOriginSize.width

    $win = $(window)
    stageSize =
      width: $win.width() - (if @thumbs.length > 1 then 110 else 0) - 40
      height: $win.height() - 90

    imgSize = @_fitSize(stageSize, originSize)

    if isOrthogonal
      # 用于修复 Firefox 下旋转后图片不能居中
      if @util.browser.firefox and imgSize.height < imgSize.width
        imgSize.top = ($win.height() + imgSize.top - imgSize.width) / 2

      @gallery.css
        width:  imgSize.height
        height: imgSize.width
        top:    imgSize.top
    else
      @gallery.css
        width:  imgSize.width
        height: imgSize.height
        top:    imgSize.top

    @gallery.one 'transitionend webkitTransitionEnd', =>
      @_zoomInPosition()


  _initRoutate: () ->
    if @opts.save
      key = "simple-gallery-" + @gallery.find("img")[0].src;
      degree = localStorage.getItem key || 0
    else
      degree = 0
    degree_diff = ((degree - @rotatedegrees) % 360 + 360) % 360 / 90
    for rotate in [0 ... degree_diff]
      @_rotate()


  _saveDegree: () ->
    key =  "simple-gallery-" + @gallery.find('img')[0].src;
    value = @rotatedegrees % 360
    localStorage.setItem key, value


  _zoomInPosition: () ->
    $zoom_in =  $('.zoom-in')
    top = @gallery.offset().top
    left = @gallery.offset().left

    if @rotatedegrees % 180 != 0
      left -= (@gallery.width() - @gallery.height())

    left = left + @gallery.width() - $zoom_in.width() - 16;

    $zoom_in.css
      'top': top
      'left' : left

    $zoom_in.show()

  _scrollToThumb: () ->
    $doc = $(document)
    $selected = @thumbsEl.find('.selected')
    @thumbsEl.scrollTop(@thumbsEl.scrollTop() + $selected.offset().top - $doc.scrollTop() - 5)


  _preloadOthers: () ->
    $others = @thumbs.not(@curThumb).map(->
      $(@).data('image-src') or $(@).data('origin-src')
    ).get()
    @util.preloadImages $others


  _fitSize: (container, size) ->
    result =
      width: size.width
      height: size.height
      top: -50
      right: (if @thumbs.length > 1 then 110 else 0)
      left: 0

    if size.width > container.width or size.height > container.height
      if size.width / size.height > container.width / container.height
        result.width  = container.width
        result.height = result.width * size.height / size.width
      else
        result.height = container.height
        result.width  = result.height * size.width / size.height
    result

  _renderNatural: ->
    deg = 'rotate(' + @rotatedegrees + 'deg)'
    @wrapper.find('.natural-image').remove()
    img =  @img.clone()
            .css
              '-webkit-transform': deg
              '-moz-transform': deg
              '-ms-transform': deg
              '-o-transform': deg
              transform: deg
              'width': @curOriginSize.width
              'height': @curOriginSize.height
            .wrap('<div class="natural-image"></div>')
            .parent()
            .appendTo @wrapper

    width = if @rotatedegrees % 180 is 0 then @curOriginSize.width else @curOriginSize.height
    height = if @rotatedegrees % 180 is 0 then @curOriginSize.height else @curOriginSize.width

    margin_left =  if width > window.innerWidth then 0 else 'auto'
    margin_top =   if height > window.innerHeight then 0 else 'auto'
    top = (height - @curOriginSize.height) / 2
    @wrapper.find('.natural-image img')
      .css
        'margin': "#{margin_top} #{margin_left}"
        'top' : top

  destroy: () =>
    $('html').removeClass 'simple-gallery-active'

    @_unbind()
    @wrapper.removeClass 'modal'
      .find('.natural-image')
      .remove()
    @imgDetail.fadeOut '200'
    @thumbsEl.fadeOut '200'

    @curThumbSize.left += 110 if @thumbs.length > 1
    @gallery.css @curThumbSize
    @gallery.one @util.transitionEnd(), (e) =>
      @wrapper.remove()


  # utils
  util:
    browser: (->
      ua = navigator.userAgent
      ie = /(msie|trident)/i.test(ua)
      chrome = /chrome|crios/i.test(ua)
      safari = /safari/i.test(ua) && !chrome
      firefox = /firefox/i.test(ua)

      if ie
        msie: true
        version: ua.match(/(msie |rv:)(\d+(\.\d+)?)/i)?[2] * 1
      else if chrome
        webkit: true
        chrome: true
        version: ua.match(/(?:chrome|crios)\/(\d+(\.\d+)?)/i)?[1] * 1
      else if safari
        webkit: true
        safari: true
        version: ua.match(/version\/(\d+(\.\d+)?)/i)?[1] * 1
      else if firefox
        mozilla: true
        firefox: true
        version: ua.match(/firefox\/(\d+(\.\d+)?)/i)?[1] * 1
      else
        {}
    )()

    preloadImages: (images, callback) ->
      arguments.callee.loadedImages ||= {}
      loadedImages = arguments.callee.loadedImages

      if Object.prototype.toString.call(images) is "[object String]"
        images = [images]
      else if Object.prototype.toString.call(images) isnt "[object Array]"
        return false

      for url in images
        if !loadedImages[url] or callback
          imgObj = new Image()

          if callback and Object.prototype.toString.call(callback) is "[object Function]"
            imgObj.onload = ->
              loadedImages[url] = true
              callback(imgObj)

            imgObj.onerror = ->
              callback()

          imgObj.src = url

    # cross browser transitionend event name (IE10+ Opera12+)
    transitionEnd: () ->
      el = document.createElement('fakeelement')
      transitions =
        'transition':'transitionend'
        'MozTransition':'transitionend'
        'WebkitTransition':'webkitTransitionEnd'

      for t of transitions
        if el.style[t] isnt undefined
          return transitions[t]



gallery = (opts) ->
  return new Gallery opts
