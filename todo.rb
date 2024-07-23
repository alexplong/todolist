# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect '/lists'
end

# View list of lists
get '/lists' do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

# Render new list form
get '/lists/new' do
  erb :new_list, layout: :layout
end

# Return an error message if the name is invalid. Return nil if name is valid.
def error_for_list_name(name)
  return 'List name must be between 1 and 100 characters.' unless (1..100).cover? name.size
  return 'List name must be unique.' if session[:lists].any? { |list| list[:name] == name }

  nil
end

def error_for_todo(name)
  return 'Todo name must be between 1 and 100 characters.' unless (1..100).cover? name.size

  nil
end


# Create a new list
post '/lists' do
  list_name = params[:list_name].strip
  error = error_for_list_name(list_name)

  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << { name: list_name, todos: [] }
    session[:success] = 'The list has been created.'
    redirect '/lists'
  end
end

# Render a list
get '/lists/:id' do
  @list_id = params[:id].to_i
  @list = session[:lists][@list_id]
  @list[:id] = @list_id

  erb :list, layout: :layout
end

# Edit an exisiting todo list
get '/lists/:id/edit' do
  id = params[:list].to_i
  @list = session[:lists][id]
  erb :edit_list, layout: :layout
end

# Update an existing todo list
post '/lists/:id' do
  list_name = params[:list_name].strip
  error = error_for_list_name(list_name)
  id = params[:list].to_i
  @list = session[:lists][id]

  if error
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    @list[:name] = list_name
    session[:success] = 'The list has been updated.'
    redirect "/lists/#{id}"
  end
end

# Delete an existing todo list
post '/lists/:id/destroy' do
  id = params[:id].to_i
  session[:lists].delete_at(id)
  session[:success] = 'The list has been deleted.'
  redirect '/lists'
end

# Add a new todo to the list
post '/lists/:list_id/todos' do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  new_todo = params[:todo].strip

  error = error_for_todo(new_todo)

  if error
    session[:error] = error
  erb :list, layout: :layout
  else
    @list[:todos] << { name: new_todo, completed: false }
    session[:success] = "The todo was added."
    redirect "/lists/#{@list_id}"
  end
end

# Delete a todo from the list
post '/lists/:list_id/todos/:id/destroy' do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id] 

  todo_id = params[:id].to_i
  @list[:todos].delete_at(todo_id)
  session[:success] = "The todo has been deleted"

  redirect "/lists/#{@list_id}"
end

# Update the status of a todo
post '/lists/:list_id/todos/:id' do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id] 

  todo_id = params[:id].to_i
  is_completed = params[:completed] == "true"
  @list[:todos][todo_id][:completed] = is_completed
  session[:success] = "The todo has been updated."

  redirect "/lists/#{@list_id}"
end

# Mark all todos as complete in a list
post '/lists/:id/complete_all' do
  @list_id = params[:id].to_i
  @list = session[:lists][@list_id] 

  @list[:todos].each do |todo|
    todo[:completed] = true
  end
 
  session[:success] = "All todos have been completed."

  redirect "/lists/#{@list_id}"
end
