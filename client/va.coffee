Handlebars.registerHelper "accounts", ->
  Accounts.find().fetch()

Template.accountMap.rendered = ->
  accounts = Accounts.find().fetch()
  d3.select("#accountMap").selectAll("circle").data(accounts)
    .enter()
      .append("circle")
        .attr("cx", (account) -> Math.random()*800)
        .attr("cy", (account) -> Math.random()*800)
        .attr("r", (account) -> Math.random()*100)
        .style("fill", (account)->"#"+account.color)
        .style("opacity", (account)->0.7)


