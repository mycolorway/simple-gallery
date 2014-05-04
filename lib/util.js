(function() {
  var k, util, v;

  util = {
    os: (function() {
      if (typeof navigator === "undefined" || navigator === null) {
        return {};
      }
      if (/Mac/.test(navigator.appVersion)) {
        return {
          mac: true
        };
      } else if (/Linux/.test(navigator.appVersion)) {
        return {
          linux: true
        };
      } else if (/Win/.test(navigator.appVersion)) {
        return {
          win: true
        };
      } else if (/X11/.test(navigator.appVersion)) {
        return {
          unix: true
        };
      } else {
        return {};
      }
    })(),
    browser: (function() {
      var chrome, firefox, ie, safari, ua;
      ua = navigator.userAgent;
      ie = /(msie|trident)/i.test(ua);
      chrome = /chrome|crios/i.test(ua);
      safari = /safari/i.test(ua) && !chrome;
      firefox = /firefox/i.test(ua);
      if (ie) {
        return {
          msie: true,
          version: ua.match(/(msie |rv:)(\d+(\.\d+)?)/i)[2]
        };
      } else if (chrome) {
        return {
          webkit: true,
          chrome: true,
          version: ua.match(/(?:chrome|crios)\/(\d+(\.\d+)?)/i)[1]
        };
      } else if (safari) {
        return {
          webkit: true,
          safari: true,
          version: ua.match(/version\/(\d+(\.\d+)?)/i)[1]
        };
      } else if (firefox) {
        return {
          mozilla: true,
          firefox: true,
          version: ua.match(/firefox\/(\d+(\.\d+)?)/i)[1]
        };
      } else {
        return {};
      }
    })(),
    preloadImages: function(images, callback) {
      var imgObj, loadedImages, url, _base, _i, _len, _results;
      (_base = arguments.callee).loadedImages || (_base.loadedImages = {});
      loadedImages = arguments.callee.loadedImages;
      if (Object.prototype.toString.call(images) === "[object String]") {
        images = [images];
      } else if (Object.prototype.toString.call(images) !== "[object Array]") {
        return false;
      }
      _results = [];
      for (_i = 0, _len = images.length; _i < _len; _i++) {
        url = images[_i];
        if (!loadedImages[url] || callback) {
          imgObj = new Image();
          if (callback && Object.prototype.toString.call(callback) === "[object Function]") {
            imgObj.onload = function() {
              loadedImages[url] = true;
              return callback(imgObj);
            };
            imgObj.onerror = function() {
              return callback();
            };
          }
          _results.push(imgObj.src = url);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    },
    transitionEnd: function() {
      if (simple.browser.webkit) {
        return 'webkitTransitionEnd';
      } else {
        return 'transitionend';
      }
    },
    prettyDate: function(d, format) {
      var date, delta, now;
      if (!((typeof moment !== "undefined" && moment !== null) && typeof moment === 'function')) {
        return '';
      }
      date = moment(d, format);
      now = moment();
      delta = now.diff(date);
      if (delta < 0) {
        return "刚刚";
      } else if (date.diff(now.clone().add("d", -1).startOf("day")) < 0) {
        return date.format("M月D日");
      } else if (date.diff(now.clone().startOf("day")) < 0) {
        return "昨天";
      } else if (delta < 60000) {
        return "刚刚";
      } else if (delta >= 60000 && delta < 3600000) {
        return Math.round(delta / 60000).toFixed(0) + "分钟前";
      } else if (delta >= 3600000 && delta < 86400000) {
        return Math.round(delta / 3600000).toFixed(0) + "小时前";
      }
    }
  };

  if (!this.simple) {
    this.simple = {};
  }

  for (k in util) {
    v = util[k];
    this.simple[k] = v;
  }

}).call(this);
