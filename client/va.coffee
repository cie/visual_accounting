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

  Deps.autorun ->
    try

      currency = Currency.first(code: Session.get("currency"))
      return unless currency # not loaded yet

      accounts = Account.all()

      circles = d3.select("#accountMap")
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

    catch e
      console.error e.message



Template.currencyChooser.events
  "change #currency": (e) ->
    Session.set("currency", e.target.value)






