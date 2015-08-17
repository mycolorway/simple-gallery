util =
  os: (->
    return {} unless navigator?

    if /Mac/.test navigator.appVersion
      mac: true
    else if /Linux/.test navigator.appVersion
      linux: true
    else if /Win/.test navigator.appVersion
      win: true
    else if /X11/.test navigator.appVersion
      unix: true
    else
      {}
  )()

  browser: (->
    ua = navigator.userAgent
    ie = /(msie|trident)/i.test(ua)
    chrome = /chrome|crios/i.test(ua)
    safari = /safari/i.test(ua) && !chrome
    firefox = /firefox/i.test(ua)

    if ie
      msie: true
      version: ua.match(/(msie |rv:)(\d+(\.\d+)?)/i)?[2]
    else if chrome
      webkit: true
      chrome: true
      version: ua.match(/(?:chrome|crios)\/(\d+(\.\d+)?)/i)?[1]
    else if safari
      webkit: true
      safari: true
      version: ua.match(/version\/(\d+(\.\d+)?)/i)?[1]
    else if firefox
      mozilla: true
      firefox: true
      version: ua.match(/firefox\/(\d+(\.\d+)?)/i)?[1]
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

  # a wrapper of localStorage & sessionStorage
  storage:
    supported: () ->
      try
        localStorage.setItem '_storageSupported', 'yes'
        localStorage.removeItem '_storageSupported'
        return true
      catch e
        return false
    set: (key, val, session = false) ->
      return unless @supported()
      storage = if session then sessionStorage else localStorage
      storage.setItem key, val

    get: (key, session = false) ->
      return unless @supported()
      storage = if session then sessionStorage else localStorage
      storage[key]

    remove: (key, session = false) ->
      return unless @supported()
      storage = if session then sessionStorage else localStorage
      storage.removeItem key


