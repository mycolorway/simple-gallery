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
    'en':
      rotate_image: 'Rotate'
      download_image: 'Download'
      view_full_size: 'View'

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
    @galleryWrapper.data('gallery', @)


  _render: () ->
    Gallery._tpl.gallery = """
      <div class="simple-gallery loading">
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
      @galleryWrapper.removeClass 'loading'

      if @thumbs.length > 1
        @_scrollToThumb()
        @thumbsEl.fadeIn 'fast'

      simple.util.preloadImages @curOriginSrc, (originImg) =>
        return  if not originImg or not originImg.src

        @imgEl.attr('src', originImg.src) if @imgEl
        @galleryEl.removeClass 'loading'  if @galleryEl
        @_preloadOthers()
    ), 5


  _bind: () ->
    @galleryWrapper.on 'click.gallery', (e) =>
      if $(e.target).closest('.gallery-detail, .gallery-list, .natural-image').length
        return
      @destroy()

    .on 'click.gallery', '.natural-image img', (e) ->
      e.stopPropagation()
      $(@).parent().remove()

    @imgEl.on 'click.gallery', (e) =>
      e.stopPropagation()
      @_renderNatural()

    @imgDetail.find('.turn-right').on 'click.gallery', (e) =>
      e.preventDefault()
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
    @galleryWrapper.off '.gallery'
    @imgEl.off '.gallery'
    @imgDetail.off '.gallery'
    @thumbsEl.off '.gallery'
    $(document).off '.gallery'


  # 当 curThumb 改变的时候就调用一次，更新当前显示图片的基本信息
  _onThumbChange: () ->
    curThumb = @curThumb

    if curThumb.is '[src]'
      curThumbImg = curThumb
    else
      curThumbImg = curThumb.find '[src]:first'

    @curThumbImg    = curThumbImg
    @curThumbSrc    = curThumbImg.attr 'src'
    @curOriginName  = curThumb.data('image-name') or curThumb.data('origin-name') or curThumbImg.attr('alt') or '图片'
    @curOriginSrc   = curThumb.data('image-src') or curThumb.data('origin-src') or @curThumbSrc
    @curDownloadSrc = curThumb.data('download-src')
    @curThumbSize   = @_getCurThumbSize()
    @curOriginSize  = @_getCurOriginSize()
    @rotatedegrees  = 0


  _getCurThumbSize: () ->
    doc      = $(document)
    win      = $(window)
    thumbImg = @curThumbImg
    offset   = thumbImg.offset()

    return {
      width:  thumbImg.width()
      height: thumbImg.height()
      top:    (offset.top - doc.scrollTop() - (win.height() - thumbImg.height()) / 2) * 2
      left:   (offset.left - doc.scrollLeft() - (win.width() - thumbImg.width()) / 2) * 2
    }


  _getCurOriginSize: () ->
    curOriginSize = @curThumb.data('image-size') or @curThumb.data('origin-size')
    curOriginSize = if curOriginSize then curOriginSize.split(',') else [0,0]
    curOriginSize =
      width:  curOriginSize[0] * 1 or @curThumbSize.width * 10
      height: curOriginSize[1] * 1 or @curThumbSize.height * 10

    curOriginSize


  _renderImage: () ->
    return unless this.galleryEl

    win        = $(window)
    thumbImg   = @curThumbImg[0]
    originSize = @curOriginSize
    stageSize  =
      width:  win.width() - (if @thumbs.length > 1 then 150 else 40)
      height: win.height() - 90

    @galleryEl.css @_fitSize(stageSize, originSize)
    @imgEl.attr('src', thumbImg.src)

    @galleryEl.addClass 'loading'


  _onGalleryThumbClick: (e) ->
    link        = $(e.currentTarget)
    galleryItem = link.parent '.thumb'
    originThumb = galleryItem.data 'originThumb'
    @curThumb   = originThumb
    @_onThumbChange()

    @galleryEl.css
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

    simple.util.preloadImages @curOriginSrc, (img) =>
      if img.src.indexOf(@curOriginSrc) isnt -1
        @galleryEl.removeClass 'loading'
        @imgEl.attr('src', img.src)

    return false


  # 创建当前显示图片的结构
  _createStage: () ->
    @galleryWrapper = $(Gallery._tpl.gallery)

    @galleryEl = @galleryWrapper.find '.gallery-img'
    @imgDetail = @galleryWrapper.find '.gallery-detail'
    @imgEl     = @galleryEl.find 'img'

    @imgEl.attr('src', @curThumbSrc)
    @imgDetail.find('.name').text(@curOriginName)
      .end().find('.link-show-origin').attr('href', @curOriginSrc)

    if @curDownloadSrc
      @imgDetail.find('.link-download').attr('href', @curDownloadSrc)
    else
      @imgDetail.find('.link-download').hide()

    @galleryEl.css @curThumbSize
    @galleryWrapper.addClass 'multi' if @thumbs.length > 1
    @galleryWrapper.appendTo 'body'
    setTimeout (=>
      @galleryWrapper.addClass 'modal'
    ), 5


  # 创建图片列表
  _createList: () ->
    @thumbsEl = $(Gallery._tpl.thumbs).appendTo(@galleryWrapper)

    return false if @thumbs.length <= 1

    @thumbs.each (index, event) =>
      thumb = $(event)
      img   = if thumb.is '[src]' then thumb else thumb.find '[src]:first'
      cls   = if @curThumb.is(thumb) then 'selected' else ''

      $(Gallery._tpl.thumb).addClass(cls)
        .find('img').attr('src', img.attr('src'))
        .end().data('originThumb', thumb)
        .appendTo(@thumbsEl)


  _rotate: () ->
    @rotatedegrees += 90

    # 是否正交，也就是说图片显示的长宽是否有交换
    deg          = 'rotate(' + @rotatedegrees + 'deg)'
    originSize   = @curOriginSize
    isOrthogonal = @rotatedegrees / 90 % 2 is 1
    @galleryEl.css
      '-webkit-transform': deg
      '-moz-transform':    deg
      '-ms-transform':     deg
      '-o-transform':      deg
      transform:           deg

    if isOrthogonal
      originSize =
        width:  @curOriginSize.height
        height: @curOriginSize.width

    win = $(window)
    stageSize =
      width: win.width() - (if @thumbs.length > 1 then 110 else 0) - 40
      height: win.height() - 90

    imgSize = @_fitSize(stageSize, originSize)

    if isOrthogonal
      # 用于修复 Firefox 下旋转后图片不能居中
      if simple.util.browser.firefox and imgSize.height < imgSize.width
        imgSize.top = (win.height() + imgSize.top - imgSize.width) / 2

      @galleryEl.css
        width:  imgSize.height
        height: imgSize.width
        top:    imgSize.top
    else
      @galleryEl.css
        width:  imgSize.width
        height: imgSize.height
        top:    imgSize.top


  _scrollToThumb: () ->
    doc        = $(document)
    selectedEl = @thumbsEl.find('.selected')
    @thumbsEl.scrollTop(@thumbsEl.scrollTop() + selectedEl.offset().top - doc.scrollTop() - 5)


  _preloadOthers: () ->
    othersEl = @thumbs.not(@curThumb).map(->
      $(this).data('image-src') or $(this).data('origin-src')
    ).get()
    simple.util.preloadImages othersEl


  _fitSize: (container, size) ->
    result =
      width:  size.width
      height: size.height
      left:   0
      right: (if @thumbs.length > 1 then 110 else 0)
      top:    -50

    if size.width > container.width or size.height > container.height
      if size.width / size.height > container.width / container.height
        result.width  = container.width
        result.height = result.width * size.height / size.width
      else
        result.height = container.height
        result.width  = result.height * size.width / size.height
    result


  _renderNatural: ->
    @galleryWrapper.find('.natural-image').remove()
    @imgEl.clone()
      .css
        width: @curOriginSize.width
        height: @curOriginSize.height
      .wrap('<div class="natural-image"></div>')
      .parent()
      .appendTo @galleryWrapper

    left = top = 'auto'
    left = 0  if @curOriginSize.width > window.innerWidth
    top = 0  if @curOriginSize.height > window.innerHeight
    @galleryWrapper.find('.natural-image img').css('margin', "#{ top } #{ left }")


  destroy: () =>
    $('html').removeClass 'simple-gallery-active'

    @_unbind()
    @galleryWrapper.removeClass 'modal'
      .find('.natural-image')
      .remove()
    @imgDetail.fadeOut '200'
    @thumbsEl.fadeOut '200'

    @curThumbSize.left += 110 if @thumbs.length > 1
    @galleryEl.css @curThumbSize
    @galleryEl.one simple.util.transitionEnd(), (e) =>
      @galleryWrapper.remove()
      @galleryEl = null


gallery = (opts) ->
  return new Gallery opts

