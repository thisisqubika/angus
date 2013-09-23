SimpleCov.start do
  add_filter '/config/'
  add_filter '/db/'
  add_filter '/log/'
  add_filter '/spec/'
  add_filter '.simplecov'
end