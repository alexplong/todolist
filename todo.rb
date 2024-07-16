require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

# reroute to /lists
# /lists/new routes to Form to save or cancel a new list
# /lists/:number routes to List with button to all lists, complete all, edit list, and Form to add to_do item
  # to_do item has a checkbox and a delete button 

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

before do
  session[:lists] ||= []
end

get "/" do
  redirect "/lists"
end

get "/lists" do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

get "/lists/new" do
  erb :new_list, layout: :layout
end

post "/lists" do
  session[:lists] << { name: params[:list_name], todos: [] }
  redirect "/lists"
end
