angular.module 'sailsService', ['ngSails', 'angular-underscore']
.config ['$sailsProvider', ($sailsProvider) ->
  $sailsProvider.url = this.location.origin
]
.factory "SailsResource", [ '$sails', '$rootScope', ($sails, $rootScope) ->
  class Resource
    constructor: (@identity, opt={}) ->
      @prefix = opt.prefix||""
      @apiModelUrl = "#{@prefix}/#{@identity}"
      @resources = []
      @resource = {}

      $sails.on @identity, (message) =>
        console.log "on #{@identity}", message
        @[message.verb] message

    emit: (evt, data) ->
      $rootScope.$emit "#{@identity}:#{evt}", data

    created: (message) =>
      @resources.push message.data
      @emit 'created', message.data #emit created event

    updated: (message) =>
      obj = @find id: message.id
      _.extend obj, message.data if obj
      _.extend @resource, message.data if @resource.id? and @resource.id == message.id
      @emit 'updated', message.data #emit created event

    destroyed: (message) =>
      tmp = @resources
      resource = _.findWhere tmp, id: message.id
      tmp.splice tmp.indexOf(resource), 1 if resource
      @emit 'destroyed', message.data #emit destroyed event

    addedTo: (message) =>
      @getRequest message

    removedFrom: (message) =>
      @getRequest message

    getRequest: (message) ->
      request = (resource, verb) =>
        @get resource.id, (data) =>
          _.extend resource, data
          @emit verb, data
      if @resource? and @resource.id
        request @resource, message.verb
      if @resources.length
        resource = _.findWhere @resources, id: message.id
        request resource, message.verb

    find: (query) ->
      _.findWhere @resources, query

    cleanupAngularObject: (value) ->
      angular.fromJson angular.toJson value

    #public
    query: (obj, cb) ->
      $sails.get @apiModelUrl, obj
      .success (data) =>
        @resources = data if typeof data == 'object'
        cb data if cb
      .error (error) -> throw error

    get: (id, cb) ->
      $sails.get "#{@apiModelUrl}/#{id}"
      .success (data) =>
        @resource = data
        cb data if cb
      .error (error) -> throw error

    create: (obj, cb) ->
      $sails.post @apiModelUrl, @cleanupAngularObject obj
      .success (data) =>
        @resources.push data
        cb data if cb
      .error (error) -> throw error

    update: (obj, id, cb) ->
      $sails.put "#{@apiModelUrl}/#{id}", @cleanupAngularObject obj
      .success (data) ->
        cb data, id if cb
      .error (error) -> throw error

    delete: (id, cb) ->
      $sails.delete "#{@apiModelUrl}/#{id}", obj
      .success (data) =>
        @destroyed data, @
        cb data if cb
      .error (error) -> throw error

    addTo: (obj, id, assoc, cb) ->
      @postRequest "#{@apiModelUrl}/#{id}/#{assoc}", obj

    removeFrom: (obj, id, assoc, removeId, cb) ->
      @postRequest "#{@apiModelUrl}/#{id}/#{assoc}/#{removeId}", obj

    postRequest: (url, obj) ->
      $sails.post url, @cleanupAngularObject obj
      .success (data) =>
        @resource = data
        cb data if cb
      .error (error) -> throw error

]