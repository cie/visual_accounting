Handlebars.registerHelper "accounts", ->
  Account.all()
Handlebars.registerHelper "currencies", ->
  Currency.all()
Handlebars.registerHelper "currency", ->
  Meteor.user().profile?.selectedCurrency
Handlebars.registerHelper "ifCurrency", (currency, options) ->
  if Meteor.user().profile?.selectedCurrency is currency
    options.fn()
  else
    options.inverse()


Template.accountMap.rendered = ->
  unless Meteor.user().profile?.selectedCurrency?
    Meteor.users.update(Meteor.userId(), $set: "profile.selectedCurrency": "HUF")
    return

  svg = d3.select("#accountMap")

  width = svg[0][0].clientWidth
  height = svg[0][0].clientHeight

  zoomHitArea = svg.append("rect")
    .attr("width", width)
    .attr("height", height)
    .style("fill", "none")
    .style("pointer-events", "all")

  zoomTransition = null

  svg.call(
    d3.behavior.zoom()
      .on("zoom", (d,i)->
        target = canvas

        if d3.event.sourceEvent.type in ['wheel']
          target = canvas.transition()
            .ease("cubic-out")
            .duration(200)

        if d3.event.sourceEvent.type in ['dblclick']
          target = canvas.transition()
            .duration(500)

        target.attr("transform", "translate(#{d3.event.translate})scale(#{d3.event.scale})")
      )
  )

  canvas = svg.append("g")



  Deps.autorun ->
    try

      currency = Currency.first(code: Meteor.user().profile.selectedCurrency)
      return unless currency # not loaded yet

      data = Account.all()

      accounts = canvas
        .selectAll(".account")
        .data(data, (a)->a._id)

      r = d3.scale.sqrt().domain([0,100]).range([0,100])

      account = accounts.enter()
        .append("g")
        .attr("class", "account")
        # do not animate on first time
        .attr("transform", (a)-> "translate(#{a.x},#{a.y})")
        .call(
          d3.behavior.drag()
            .on("dragstart", (d,i)->
              d3.event.sourceEvent.stopPropagation()
              d3.select(@).classed("dragging", yes)

              # bring to forward
              @.parentNode.appendChild(@)
            ).on("drag", (d,i)->
              d.x = d3.event.x
              d.y = d3.event.y
              d3.select(this).attr("transform", "translate(" + [ d.x,d.y ] + ")")
            ).on("dragend", (d,i) ->
              d.save(x: d.x, y: d.y)
              d3.select(@).classed("dragging", no)
            )
        )

      account.append("path")
        .attr("d","M-5,0L5,0M0,-5L0,5")
        .attr("class", "crosshair")
      account.append("circle")
      account.append("path")
        .attr("d","M-10,-10L-10,10L10,10L10,-10")
        .attr("class", "hitArea")
        .attr("fill", "none")
        .style("pointer-events", "all")
      account.append("text")
        .attr("class", "name")
        .attr("y", "-40")
        .attr("dy", ".35em")
      account.append("text")
        .attr("class", "amount")
        .attr("dy", ".35em")

      accounts.transition()
        .attr("transform", (a)-> "translate(#{a.x},#{a.y})")

      accounts.select("circle")
        .attr("r", (a) -> r(a.amount()))
        .style("fill", (a)->"#"+a.color)
      accounts.select(".name")
        .text((d)->d.name)
      accounts.select(".amount")
        .text((d)->d.amount())
      accounts.select(".crosshair")
        .attr("stroke", (a)->"#"+a.color)

      accounts.exit().remove()
        


    catch e
      console.error e.message

Template.currencyChooser.helpers
  selected: ->
    @code is Meteor.user().profile.selectedCurrency

Template.currencyChooser.events
  "change #currency": (e) ->
    Meteor.users.update(Meteor.userId(), $set: "profile.selectedCurrency": e.target.value)



Template.timeline.rendered = ->

  svg = d3.select("#timeline")

  width = svg[0][0].clientWidth
  height = svg[0][0].clientHeight

  zoomHitArea = svg.append("rect")
    .attr("width", width)
    .attr("height", height)
    .style("fill", "none")
    .style("pointer-events", "all")

  zoomTransition = null

  x = d3.time.scale()
    .domain([d3.time.month.offset(new Date(), -3), d3.time.month.offset(new Date(), 3)])
    .rangeRound([0,width])

  svg.call(
    d3.behavior.zoom()
      .x(x)
      .scaleExtent([1.0/25 , 30])
      .on("zoom", (d,i)->
        svg.select(".xAxis").call(xAxis)
      )
  )

  xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")
      .ticks(7)
      .tickSize(0)

  svg.append("g")
    .attr("class", "xAxis")
    .attr("transform", "translate(0,#{height/2})")
    .call(xAxis)

  Session.set("timelineZoom", 12)



