Handlebars.registerHelper "accounts", ->
  Account.all()
Handlebars.registerHelper "currencies", ->
  Currency.all()
Handlebars.registerHelper "currency", ->
  Session.get("currency")
Handlebars.registerHelper "ifCurrency", (currency, options) ->
  if Session.equals("currency", currency)
    options.fn()
  else
    options.inverse()


Template.accountMap.rendered = ->
  unless Session.get("currency")
    Session.set("currency", Currency.first().code)

  svg = d3.select("#accountMap")

  zoomHitArea = svg.append("rect")
    .attr("width", svg[0][0].clientWidth)
    .attr("height", svg[0][0].clientHeight)
    .style("fill", "none")
    .style("pointer-events", "all")

  svg.call(
    d3.behavior.zoom()
      .on("zoom", (d,i)->
        canvas.attr("transform", "translate(#{d3.event.translate})scale(#{d3.event.scale})")
      )
  )

  canvas = svg.append("g")



  Deps.autorun ->
    try

      currency = Currency.first(code: Session.get("currency"))
      return unless currency # not loaded yet

      accounts = Account.all()

      circles = canvas
        .selectAll("circle")
        .data(accounts, (a)->a._id)

      r = d3.scale.sqrt().domain([0,100]).range([0,600])

      circles.enter()
        .append("circle")
          .attr("cx", (a) -> a.x)
          .attr("cy", (a) -> a.y)
          .attr("r", (a) -> r(a.amount()))
          .style("fill", (a)->"#"+a.color)
          .style("opacity", (a)->0.7)
          .call(
            d3.behavior.drag()
              .on("dragstart", (d,i)->
                d3.event.sourceEvent.stopPropagation()
              ).on("drag", (d,i)->
                d.x = d3.event.x
                d.y = d3.event.y
                d3.select(this).attr("transform", "translate(" + [ d.x,d.y ] + ")")
              )
          )

    catch e
      console.error e.message



Template.currencyChooser.events
  "change #currency": (e) ->
    Session.set("currency", e.target.value)








