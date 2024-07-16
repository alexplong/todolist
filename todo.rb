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

# View list of lists
get "/lists" do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

# Render new list form
get "/lists/new" do
  erb :new_list, layout: :layout
end

# Create a new list
post "/lists" do
  list_name = params[:list_name].strip
  if (1..100).cover? list_name.size
    session[:lists] << { name: list_name, todos: [] }
    session[:success] = "The list has been created."
    redirect "/lists"
  else
    session[:error] = "List name must be between 1 and 100 characters"
    erb :new_list, layout: :layout
  end
end
