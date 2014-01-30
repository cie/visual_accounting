class @Account extends Minimongoid
  @_collection: new Meteor.Collection2("accounts"
    schema:
      name:          type:String, max:50
      parent_id:     type:String, max:50, optional:yes
      color:         type:String, max:50
      initialAmount: type:Number, decimal:yes
  )

  @has_many: [
    {name: 'transactions', class_name: 'Transaction'}
    {name: 'subaccounts',  class_name: 'Account', foreign_key: 'parent_id'}
  ]

  @belongs_to: [
    {name: 'parent', class_name: 'Account'}
  ]
  
  @before_create: (attr) ->
    attr.initialAmount = 0
    attr

  amount: () ->
    @initialAmount
    30



if Meteor.isServer
  if Account.count() is 0
    all       = Account.create name: "All",          parent_id: null,        color: "eeeeee"
    money     = Account.create name: "Money",        parent_id: all.id,      color: "2f2f4f"
    cash      = Account.create name: "Cash",         parent_id: money.id,    color: "999999"
    bank_acct = Account.create name: "Bank account", parent_id: money.id,    color: "eeee4f"
    expenses  = Account.create name: "Expenses",     parent_id: all.id,      color: "3f8f3f"
    food      = Account.create name: "Food",         parent_id: expenses.id, color: "2f9f3f"


class @Transaction extends Minimongoid
  @_collection: new Meteor.Collection("transactions"
    schema:
      src_id:  type:String, max:50
      dest_id: type:String, max:50
  )


class @Currency extends Minimongoid
  @_collection: new Meteor.Collection("currencies"
    schema:
      code:  type:String,max:5
      name:  type:String,max:50
      value: type:Number,min:0,decimal:yes
  )

  figure: (n) -> n / @value


if Meteor.isServer
  if Currency.count() is 0
    Currency.create code: "EUR", name: "€",  value: 1.000
    Currency.create code: "HUF", name: "Ft", value: 0.00323
    Currency.create code: "USD", name: "$",  value: 0.7322
