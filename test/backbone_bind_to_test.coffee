describe "Backbone.BindTo", ->
  sandbox =
    use: (dom) ->
      @dom = $(dom)
      $('body').append dom

    clear: ->
      @dom.remove() if @dom
      @dom = null

  afterEach -> sandbox.clear()

  TestModel = Backbone.Model
  TestView  = Backbone.BindTo.View.extend
    initialize: ->
      @el.innerHTML = @template
      sandbox.use @el

  initView = (opts = {}, properties = {}) ->
    View = TestView.extend properties
    new View(opts)

  describe "#bindToModel", ->
    it "can bind to several model events to view actions", ->
      model = new TestModel
      view  = initView {model},
        template: '<div class="name"></div><div class="email"></div>'

        bindToModel:
          'change:name':  'renderName',
          'change:email': 'renderEmail'

        renderName:  -> @$el.find('.name').html @model.get('name')
        renderEmail: -> @$el.find('.email').html @model.get('email')

      model.set 'name', 'UserName'
      view.$('.name').html().should.be.equal 'UserName'

      model.set 'email', 'UserEmail'
      view.$('.email').html().should.be.equal 'UserEmail'

    it "doesn't throw an error if bindToModel is not specified", ->
      model = new TestModel
      view  = initView {model}
      view.remove()

    it "doesn't throw an error if there isn't a model", ->
      view = initView {model: null},
        bindToModel:
          'event': 'action'
      view.remove()

    it "throws an error if view action doesn't exists", ->
      (->
        model = new TestModel
        view  = initView {model},
          bindToModel:
            'event': 'invalid$Action'
      ).should.throw 'Method invalid$Action does not exist'

    it "throws an error if view action is not an function", ->
      (->
        model = new TestModel
        view  = initView {model},
          action: 'String'
          bindToModel:
            'event': 'action'
      ).should.throw 'action is not a function'

    it "unbinds from all model events when the view is removed removed", ->
      model = new TestModel
      view  = initView {model},
        bindToModel: {'event':  'trackEvent'}
        eventTracked: false
        trackEvent: -> @eventTracked = true

      view.remove()

      model.trigger 'event'

      view.eventTracked.should.not.be.true




