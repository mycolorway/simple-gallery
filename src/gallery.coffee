class Gallery extends SimpleModule

  opts:
    el:      null
    itemCls: ''
    wrapCls: ''

  @i18n:
    'zh-CN':
      rotate_image: '旋转'
      download_image: '下载'
      view_full_size: '查看'
      zoomin_image: '放大'
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
        <div class="gallery-img">
          <img src="" />
          <div class="loading-indicator"></div>
          <a class="zoom-in" href="javascript:;" title="#{@_t('zoomin_image')}">
            <i class="icon-zoom-in"><span>#{@_t('zoomin_image')}</span></i>
          </a>
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

      Util.prototype.preloadImages @curOriginSrc, (originImg) =>
        return  if not originImg or not originImg.src

        @img.attr('src', originImg.src) if @img
        @gallery.removeClass 'loading'  if @gallery
        @_preloadOthers()
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


  _unbind: () ->
    @wrapper.off '.gallery'
    @img.off '.gallery'
    @imgDetail.off '.gallery'
    @thumbsEl.off '.gallery'
    $(document).off '.gallery'


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
    @rotatedegrees = 0


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

    @gallery.css
      '-webkit-transform': 'rotate(0deg)'
      '-moz-transform':    'rotate(0deg)'
      '-ms-transform':     'rotate(0deg)'
      '-o-transform':      'rotate(0deg)'
      transform:           'rotate(0deg)'

    galleryItem.addClass 'selected'
      .siblings '.selected'
      .removeClass 'selected'

    @imgDetail.find('.name').text(@curOriginName)
      .end().find('.link-show-origin').attr('href', @curOriginSrc)
      .end().find('.link-download').attr('href', @curDownloadSrc)
    @_renderImage()

    Util.prototype.preloadImages @curOriginSrc, (img) =>
      if img.src.indexOf(@curOriginSrc) isnt -1
        @gallery.removeClass 'loading'
        @img.attr('src', img.src)

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
    @rotatedegrees += 90

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
      if Util.prototype.browser.firefox and imgSize.height < imgSize.width
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


  _scrollToThumb: () ->
    $doc = $(document)
    $selected = @thumbsEl.find('.selected')
    @thumbsEl.scrollTop(@thumbsEl.scrollTop() + $selected.offset().top - $doc.scrollTop() - 5)


  _preloadOthers: () ->
    $others = @thumbs.not(@curThumb).map(->
      $(@).data('image-src') or $(@).data('origin-src')
    ).get()
    Util.prototype.preloadImages $others


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
    @wrapper.find('.natural-image').remove()
    @img.clone()
      .css
        width: @curOriginSize.width
        height: @curOriginSize.height
      .wrap('<div class="natural-image"></div>')
      .parent()
      .appendTo @wrapper

    left = top = 'auto'
    left = 0  if @curOriginSize.width > window.innerWidth
    top = 0  if @curOriginSize.height > window.innerHeight
    @wrapper.find('.natural-image img').css('margin', "#{ top } #{ left }")


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
    @gallery.one Util.prototype.transitionEnd(), (e) =>
      @wrapper.remove()


gallery = (opts) ->
  return new Gallery opts
