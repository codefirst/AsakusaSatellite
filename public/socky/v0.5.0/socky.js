/*!
 * Socky JavaScript Library
 *
 * @version 0.5.0
 * @author  Bernard Potocki <bernard.potocki@imanel.org>
 * @author  Stefano Verna <stefano.verna@welaika.com>
 * @licence The MIT licence.
 * @source  http://github.com/socky/socky-client-js
 */
/*!
 * Simple JavaScript Inheritance
 * By John Resig http://ejohn.org/
 * MIT Licensed.
 *
 * Inspired by base2 and Prototype
 */

(function() {

  var initializing = false, fnTest = /xyz/.test(function(){xyz;}) ? /\b_super\b/ : /.*/;
  // The base Class implementation (does nothing)
  var Class = function(){};

  // Create a new Class that inherits from this class
  Class.extend = function(prop) {
    var _super = this.prototype;

    // Instantiate a base class (but only create the instance,
    // don't run the init constructor)
    initializing = true;
    var prototype = new this();
    initializing = false;

    // Copy the properties over onto the new prototype
    for (var name in prop) {
      // Check if we're overwriting an existing function
      prototype[name] = typeof prop[name] == "function" &&
        typeof _super[name] == "function" && fnTest.test(prop[name]) ?
        (function(name, fn){
          return function() {
            var tmp = this._super;

            // Add a new ._super() method that is the same method
            // but on the super-class
            this._super = _super[name];

            // The method only need to be bound temporarily, so we
            // remove it when we're done executing
            var ret = fn.apply(this, arguments);
            this._super = tmp;

            return ret;
          };
        })(name, prop[name]) :
        prop[name];
    }

    // The dummy class constructor
    function Class() {
      // All construction is actually done in the init method
      if ( !initializing && this.init )
        this.init.apply(this, arguments);
    }

    // Populate our constructed prototype object
    Class.prototype = prototype;

    // Enforce the constructor to be what we expect
    Class.constructor = Class;

    // And make this class extendable
    Class.extend = arguments.callee;

    return Class;
  };


Events = Class.extend({

  // Bind an event, specified by a string name, `ev`, to a `callback` function.
  // Passing `"all"` will bind the callback to all events fired.
  _bind : function(scope, ev, callback) {
    this._callbacks = this._callbacks || {};
    var calls = this._callbacks[scope] || (this._callbacks[scope] = {});
    var list  = this._callbacks[scope][ev] || (this._callbacks[scope][ev] = []);
    list.push(callback);
    return this;
  },

  // Remove one or many callbacks. If `callback` is null, removes all
  // callbacks for the event. If `ev` is null, removes all bound callbacks
  // for all events.
  _unbind : function(scope, ev, callback) {
    var calls;
    if (this._callbacks && !ev) {
      this._callbacks[scope] = {};
    } else if (calls = this._callbacks[scope]) {
      if (!callback) {
        calls[ev] = [];
      } else {
        var list = calls[ev];
        if (!list) return this;
        for (var i = 0, l = list.length; i < l; i++) {
          if (callback === list[i]) {
            list.splice(i, 1);
            break;
          }
        }
      }
    }
    return this;
  },

  // Trigger an event, firing all bound callbacks. Callbacks are passed the
  // same arguments as `trigger` is, apart from the event name.
  // Listening for `"all"` passes the true event name as the first argument.
  _trigger : function(scope, ev) {
    var list, calls, i, l;
    if (!this._callbacks || !(calls = this._callbacks[scope])) return this;
    if (calls[ev]) {
      list = calls[ev].slice(0);
      for (i = 0, l = list.length; i < l; i++) {
        list[i].apply(this, Array.prototype.slice.call(arguments, 2));
      }
    }
    if (calls['all']) {
      list = calls['all'].slice(0);
      for (i = 0, l = list.length; i < l; i++) {
        list[i].apply(this, Array.prototype.slice.call(arguments, 1));
      }
    }
    return this;
  }

});
this.Socky = {};

this.Socky.Client = Events.extend({

  init: function(url, options) {

    if (!Socky.Manager.is_inited()) {
      Socky.Manager.init(options ? options.assets_location : null);
    }

    this._options = Socky.Utils.extend({}, Socky.Manager.default_options(), options, {url: url});
    this._channels = new Socky.ChannelsCollection(this);
    this._is_connected = false;
    this._connection_id = null;
    this._connection = null;

    if (Socky.Manager.is_driver_loaded()) {
      this.connect();
    } else {
      this.log('WebSocket driver still unavailable, waiting...');
    }

    this.raw_event_bind('socky:connection:established', Socky.Utils.bind(this._on_connection_established, this));

    Socky.Manager.add_socky_instance(this);
  },

  auth_transport: function() {
    return this._options.auth_transport;
  },

  auth_endpoint: function() {
    return this._options.auth_endpoint;
  },

  connection_id: function() {
    return this._connection_id;
  },

  is_connected: function() {
    return this._is_connected;
  },

  connect: function() {
    var self = this;

    if (this._connection) {
      return;
    }

    if (window.WebSocket) {
      var url = this._options.url;
      this.log('connecting', url);
      this._connection = new WebSocket(url);
      this._connection.onopen = Socky.Utils.bind(this.on_socket_open, this);
      this._connection.onmessage = Socky.Utils.bind(this.on_socket_message, this);
      this._connection.onclose = Socky.Utils.bind(this.on_socket_close, this);
      this._connection.onerror = Socky.Utils.bind(this.on_socket_error, this);
      setTimeout(Socky.Utils.bind(function() {
        if (!this._connection_open) {
          this._connection = null;
          // simulate a remote event
          this.send_locally({
            event: 'socky:connection:error',
            reason: 'down'
          });
        }
      }, this), 10000);
    } else {
      this.log('WebSocket unavailable');
      this._connection = {};
    }
  },

  on_socket_open: function() {
    this.log('connected to socket, waiting for connection_id');
    this._connection_open = true;
  },

  on_socket_message: function(evt) {
    var params = Socky.Utils.parseJSON(evt.data);

    if (typeof(params.data) == 'string') {
      params.data = Socky.Utils.parseJSON(params.data);
    }

    this.log('received message', JSON.stringify(params));

    // first notify internal handlers
    this._trigger('raw', params.event, params);

    // notify the external (client) handlers
    this._trigger('public', params.event, params);

    if (params.channel) {
      // then notify channels' internal handlers
      var channel = this.channel(params.channel);
      if (channel) {
        channel.receive_event(params.event, params);
      }
    }

  },

  on_socket_error: function(evt) {
    this.log('error', evt.data);
    this._is_connected = false;
  },

  on_socket_close: function() {
    this.log('disconnected');
    this._is_connected = false;
    this.send_locally({
      event: 'socky:connection:closed'
    });
  },

  log: function() {
    Socky.Utils.log.apply(Socky.Manager, arguments);
  },

  subscribe: function(channel_name, permissions, data) {
    var channel = this._channels.add(channel_name, permissions, data);
    if (this._is_connected) {
      channel.subscribe();
    }
    return channel;
  },

  unsubscribe: function(channel_name) {
    var channel = this.channel(channel_name);
    if (channel) {
      if (this._is_connected) {
        channel.unsubscribe();
      }
      this._channels.remove(channel_name);
    } else {
      this.send_locally({
        event: 'socky:unsubscribe:failure',
        channel: channel_name
      });
    }
  },

  send_locally: function(payload) {
    this.on_socket_message({
      data: payload
    });
  },

  send: function(payload) {
    payload.connection_id = this._connection_id;
    var strigified_params = JSON.stringify(payload);
    this.log("sending message", strigified_params);
    this._connection.send(strigified_params);
    return this;
  },

  raw_event_bind: function(event, callback) {
    this._bind('raw', event, callback);
  },

  raw_event_unbind: function(event, callback) {
    this._unbind('raw', event, callback);
  },

  bind: function(event, callback) {
    this._bind('public', event, callback);
  },

  unbind: function(event, callback) {
    this._unbind('public', event, callback);
  },

  channel: function(channel_name) {
    return this._channels.find(channel_name);
  },

  close: function() {
    if (this._connection) {
      this._connection.close();
    }
  },

  // private methods

  _on_connection_established: function(data) {
    Socky.Utils.log("connection_id", data.connection_id);
    this._connection_id = data.connection_id;
    this._is_connected = true;
    this._subscribe_pending_channels();
  },

  _subscribe_pending_channels: function() {
    this._channels.each(function(channel) {
      channel.subscribe();
    });
  }

});
Socky.Utils = {
  breaker: {},
  log: function() {
    if (console && console.log) {
      var args = Array.prototype.slice.call(arguments);
      args.unshift(">> Socky");
      Function.prototype.apply.apply(console.log, [console, args]);
    }
  },
  is_number: function(obj) {
    return !!(obj === 0 || (obj && obj.toExponential && obj.toFixed));
  },
  each: function(obj, iterator, context) {
    if (obj == null) return;
    if (Array.prototype.forEach && obj.forEach === Array.prototype.forEach) {
      obj.forEach(iterator, context);
    } else if (Socky.Utils.is_number(obj.length)) {
      for (var i = 0, l = obj.length; i < l; i++) {
        if (iterator.call(context, obj[i], i, obj) === Socky.Utils.breaker) return;
      }
    } else {
      for (var key in obj) {
        if (hasOwnProperty.call(obj, key)) {
          if (iterator.call(context, obj[key], key, obj) === Socky.Utils.breaker) return;
        }
      }
    }
  },
  find: function(obj, iterator, context) {
    var result;
    Socky.Utils.any(obj, function(value, index, list) {
      if (iterator.call(context, value, index, list)) {
        result = value;
        return true;
      }
    });
    return result;
  },
  any: function(obj, iterator, context) {
    var result = false;
    if (obj == null) return result;
    Socky.Utils.each(obj, function(value, index, list) {
      if (result = iterator.call(context, value, index, list)) return Socky.Utils.breaker;
    });
    return result;
  },
  extend: function(obj) {
    Socky.Utils.each(Array.prototype.slice.call(arguments, 1), function(source) {
      for (var prop in source) {
        obj[prop] = source[prop];
      }
    });
    return obj;
  },
  bind: function(f, context, args) {
    return function() {
      return f.apply(context, Array.prototype.slice.call(args || []).concat(Array.prototype.slice.call(arguments)));
    }
  },
  parseJSON: function(data) {
    try {
      return JSON.parse(data);
    } catch(e) {
      return data;
    }
  }
};

Socky.ChannelsCollection = Class.extend({

  each: function(iterator) {
    Socky.Utils.each(this._channels, function(channel) {
      iterator(channel);
    });
  },

  init: function(socky) {
    this._socky = socky;
    this._channels = {};
  },

  add: function(obj, permissions, data) {
    var self = this;
    if (obj instanceof Socky.ChannelsCollection) {
      Socky.Utils.extend(this._channels, obj._channels);
    } else {
      var channel_name = obj;
      var existing_channel = this.find(channel_name);
      if (!existing_channel) {
        var channel = null;
        if (channel_name.indexOf("private-") === 0) {
          channel = new Socky.PrivateChannel(channel_name, this._socky, permissions);
        } else if (channel_name.indexOf("presence-") === 0) {
          channel = new Socky.PresenceChannel(channel_name, this._socky, permissions, data);
        } else {
          channel = new Socky.Channel(channel_name, this._socky);
        }
        this._channels[channel_name] = channel;
        return channel;
      }
    }
  },

  find: function(channel_name) {
    return this._channels[channel_name];
  },

  remove: function(channel_name) {
    delete this._channels[channel_name];
  },

  channel_names: function() {
    var channel_names = [];
    for (var channel_name in this._channels) {
      channel_names.push(channel_name)
    }
    return channel_names;
  }

});

Socky.Channel = Events.extend({
  init: function(channel_name, socky) {
    this._socky = socky;
    this._name = channel_name;
    this._callbacks = {};
    this._global_callbacks = [];
    this._subscribed = false;
    this._auth = null;
    this.raw_event_bind('socky:subscribe:success', Socky.Utils.bind(this.acknowledge_subscription, this));
  },

  disconnect: function(){
  },

  acknowledge_subscription: function(data){
    this._subscribed = true;
    this._trigger('public', 'socky:subscribe:success', data.members);
  },

  is_private: function(){
    return false;
  },

  is_presence: function(){
    return false;
  },

  subscribe: function() {
    if (this._started_subscribe) {
      return;
    }
    this._started_subscribe = true;
    var self = this;
    this.authorize(
      function(data) {
        self._auth = data.auth;
        self.send_event('socky:subscribe', self.generate_subscription_payload());
      },
      function(data) {
        self._socky.send_locally({
          event: 'socky:subscribe:failure',
          channel: self._name
        });
      }
    );
  },

  generate_subscription_payload: function() {
    return null;
  },

  unsubscribe: function() {
    this.send_event('socky:unsubscribe');
  },

  authorize: function(callback){
    // normal channels don't require auth
    callback({});
  },

  send_event: function(event_name, payload) {
    payload = payload || {};
    payload.event = event_name;
    payload.channel = this._name;
    payload.auth = this._auth;
    this._socky.send(payload);
  },

  receive_event: function(event_name, payload) {
    if(payload.event.match(/^socky:/)) {
      // notify internal handlers
      this._trigger('raw', payload.event, payload);
    } else {
      // notify the external (client) handlers, passing them just the 'data' param
      this._trigger('public', payload.event, payload.data);
    }
  },

  raw_event_bind: function(event, callback) {
    this._bind('raw', event, callback);
  },

  raw_event_unbind: function(event, callback) {
    this._unbind('raw', event, callback);
  },

  bind: function(event, callback) {
    this._bind('public', event, callback);
  },

  unbind: function(event, callback) {
    this._unbind('public', event, callback);
  },

  trigger: function(event, data) {
    this.send_event(event, {data: data});
  }

});

Socky.PrivateChannel = Socky.Channel.extend({

  init: function(channel_name, socky, options) {
    this._super(channel_name, socky);
    var default_permissions = {
      read: true,
      write: false,
      presence: false
    };
    this._permissions = Socky.Utils.extend({}, default_permissions, options);
  },

  is_private: function(){
    return true;
  },

  authorize: function(success_callback, failure_callback){
    if (this._socky.auth_transport() == "ajax") {
      this.authorize_via_ajax(success_callback, failure_callback);
    } else {
      this.authorize_via_jsonp(success_callback, failure_callback);
    }
  },

  generate_subscription_payload: function() {
    var payload = {};
    if (this._permissions.read === false) {
      payload.read = false;
    }
    if (this._permissions.write === true) {
      payload.write = true;
    }
    return payload;
  },

  generate_auth_payload: function() {
    var payload = {
      'event': 'socky:subscribe',
      'channel': this._name,
      'connection_id': this._socky.connection_id()
    };
    Socky.Utils.extend(payload, this.generate_subscription_payload());
    return payload;
  },

  generate_auth_payload_string: function() {
    var params = [];
    var payload = this.generate_auth_payload();
    for (var i in payload) {
      params.push(i + '=' + encodeURIComponent(payload[i]));
    }
    return params.join('&');
  },

  authorize_via_ajax: function(success_callback, failure_callback){
    var self = this;
    var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    xhr.open("POST", this._socky.auth_endpoint(), true);
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function() {
      if (xhr.readyState == 4) {
        if (xhr.status == 200) {
          var data = Socky.Utils.parseJSON(xhr.responseText);
          success_callback(data);
        } else {
          failure_callback();
        }
      } else {
        failure_callback();
      }
    };
    var payload = this.generate_auth_payload_string();
    xhr.send(payload);
  },

  authorize_via_jsonp: function(success_callback, failure_callback) {

    var callback_name = this._name;
    var success_called = false;
    Socky.Manager._jsonp_auth_callbacks[callback_name] = function(data) {
      success_called = true;
      success_callback(data);
    };

    var payload = this.generate_auth_payload_string();

    var full_callback_name = "Socky.Manager._jsonp_auth_callbacks['" + callback_name + "']"
    var script_url = this._socky.auth_endpoint();
    script_url += '?callback=' + encodeURIComponent(full_callback_name);
    script_url += '&' + payload;

    var script = document.createElement("script");
    script.src = script_url;
    var head = document.getElementsByTagName("head")[0] || document.documentElement;
    head.insertBefore(script, head.firstChild);

    setTimeout(function() {
      if (!success_called) {
        failure_callback();
      }
    }, 10000);

  }

});
Socky.PresenceChannel = Socky.PrivateChannel.extend({

  init: function(channel_name, socky, options) {
    this._super(channel_name, socky, options);
    this._members = {};
    this._subscription_data = JSON.stringify(options['data']);
    this.raw_event_bind('socky:member:added', Socky.Utils.bind(this.on_member_added, this));
    this.raw_event_bind('socky:member:removed', Socky.Utils.bind(this.on_member_removed, this));
  },

  disconnect: function(){
    this._members = {};
  },

  is_presence: function() {
    return true;
  },

  acknowledge_subscription: function(data) {
    this._super(data);
    for (var i = 0; i < data.members.length; i++) {
      var member = data.members[i];
      this._members[member.connection_id] = member.data;
    }
  },

  on_member_added: function(data) {
    this._members[data.connection_id] = data.data;
    this._trigger('public', 'socky:member:added', data.data);
  },

  on_member_removed: function(data) {
    var member = this._members[data.connection_id];
    delete this._members[data.connection_id];
    this._trigger('public', 'socky:member:removed', member);
  },

  generate_subscription_payload: function() {
    var payload = this._super();
    if (this._permissions.hide === true) {
      payload.hide = true;
    }
    payload.data = this._subscription_data;
    return payload;
  },

  members: function() {
    return this._members;
  }

});


Socky.Manager = {

  // private attributes
  _is_inited: false,
  _is_websocket_driver_loaded: false,
  _jsonp_auth_callbacks: {},
  _socky_instances: [],
  _assets_location: 'http://js.socky.org/v0.5.0/assets',
  _flash_debug: false,
  _default_options: {
    debug: false,
    url: 'ws://'+window.location.hostname+':'+8080+'/websocket',
    auth_endpoint: "/socky/auth",
    auth_transport: "ajax"
  },

  // public methods

  is_inited: function() {
    return this._is_inited;
  },

  is_driver_loaded: function() {
    return this._is_websocket_driver_loaded;
  },

  add_socky_instance: function(socky) {
    this._socky_instances.push(socky);
  },

  default_options: function() {
    return this._default_options;
  },

  set_default_options: function(default_options) {
    this._default_options = Socky.Utils.extend({}, this._default_options, default_options);
  },

  set_assets_location: function(assets) {
    this._assets_location = assets;
  },

  set_flash_debug: function(debug) {
    this._flash_debug = debug;
  },

  init: function(assets_location) {

    if (this._is_inited) {
      return;
    }

    this._is_inited = true;

    Socky.Utils.log("inited");

    if (assets_location) {
      this.set_assets_location(assets_location);
    }

    var scripts_to_require = [];

    var success_callback = Socky.Utils.bind(function() {
      Socky.Utils.log("Websockets driver loaded");
      this._web_sockets_loaded();
    }, this);

    // Check for JSON dependency
    if (window['JSON'] == undefined) {
      Socky.Utils.log("no JSON support, requiring it");
      scripts_to_require.push(this._assets_location + '/json2.js');
    }

    // Check for Flash fallback dep. Wrap initialization.
    if (window['WebSocket'] == undefined) {

      Socky.Utils.log("no WebSocket driver available, requiring it");

      // Don't let WebSockets.js initialize on load. Inconsistent accross browsers.
      window.WEB_SOCKET_SWF_LOCATION = this._assets_location + "/WebSocketMain.swf";
      window.WEB_SOCKET_DEBUG = this._flash_debug;
      window.WEB_SOCKET_SUPPRESS_CROSS_DOMAIN_SWF_ERROR = true;

      scripts_to_require.push(this._assets_location + '/flashfallback.js');
    }

    if (scripts_to_require.length > 0){
      this._require_scripts(scripts_to_require, success_callback);
    } else {
      success_callback();
    }
  },

  // private methods

  _web_sockets_loaded: function() {
    this._is_websocket_driver_loaded = true;
    Socky.Utils.each(this._socky_instances, function(socky) {
      if (!socky.is_connected()) {
        socky.connect();
      }
    });
  },

  _require_scripts: function(scripts, callback) {

    var scripts_count = 0;
    var handle_script_loaded;

    if (document.addEventListener) {
      handle_script_loaded = function(elem, callback) {
        elem.addEventListener('load', callback, false)
      }
    } else {
      handle_script_loaded = function(elem, callback) {
        elem.attachEvent('onreadystatechange', function() {
          if (elem.readyState == 'loaded' || elem.readyState == 'complete') {
            callback();
          }
        });
      }
    }

    var check_if_ready = Socky.Utils.bind(function(callback) {
      scripts_count++;
      if (scripts.length == scripts_count) {
        // Opera needs the timeout for page initialization weirdness
        Socky.Utils.log("All the require script have been loaded!");
        setTimeout(callback, 0);
      }
    }, this);

    var add_script = Socky.Utils.bind(function(src, callback) {
      callback = callback || function() {}
      var head = document.getElementsByTagName('head')[0];
      var script = document.createElement('script');
      script.setAttribute('src', src);
      script.setAttribute('type', 'text/javascript');
      script.setAttribute('async', true);

      Socky.Utils.log("Adding script", src);

      handle_script_loaded(script, function() {
        check_if_ready(callback);
      });

      head.appendChild(script);
    }, this);

    for (var i = 0; i < scripts.length; i++) {
      add_script(scripts[i], callback);
    }
  }

};

})();
