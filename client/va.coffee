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

      data = Account.all()

      accounts = canvas
        .selectAll(".account")
        .data(data, (a)->a._id)

      r = d3.scale.sqrt().domain([0,100]).range([0,100])

      account = accounts.enter()
        .append("g")
        .attr("class", "account")
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

      account.append("circle")
      account.append("text")
        .attr("class", "name")
        .attr("y", "-40")
        .attr("dy", ".35em")
      account.append("text")
        .attr("class", "amount")
        .attr("dy", ".35em")

      accounts.transition().attr("transform", (a)-> "translate(#{a.x},#{a.y})")

      accounts.select("circle")
        .attr("r", (a) -> r(a.amount()))
        .style("fill", (a)->"#"+a.color)
      accounts.select(".name")
        .text((d)->d.name)
      accounts.select(".amount")
        .text((d)->d.amount())

      accounts.exit().remove()
        


    catch e
      console.error e.message



Template.currencyChooser.events
  "change #currency": (e) ->
    Session.set("currency", e.target.value)








