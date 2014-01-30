
if Accounts.find().count() is 0
  all = Accounts.insert name: "All", parent: null, color: "eeeeee"
  money = Accounts.insert name: "Money", parent: all, color: "2f2f4f"
  cash = Accounts.insert name: "Cash", parent: money, color: "999999"
  bank_acct = Accounts.insert name: "Bank account", parent: money, color: "eeee4f"
  expenses = Accounts.insert name: "Expenses", parent: all, color: "3f8f3f"
  food = Accounts.insert name: "Food", parent: expenses, color: "2f9f3f"

