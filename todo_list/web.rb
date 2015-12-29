require 'sinatra'
require 'data_mapper'
require 'json'
require 'pry'

DataMapper::setup(:default,"sqlite3://#{Dir.pwd}/todo_list.db")

class Item
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required=>true
  property :done, Boolean, :required=>true, :default=>false
  property :createdAt, DateTime
end
DataMapper.finalize.auto_upgrade!

get '/' do
  @items = Item.all(:order => :createdAt.desc)
  redirect '/new' if @items.empty?
  erb :index
end

get '/new' do
  @title = "Add todo item"
  erb :new
end

post '/new' do
  Item.create(:content =>params[:content], :createdAt =>Time.now)
  redirect '/'
end

post '/done' do
  item = Item.first(:id => params[:id])
  #binding.pry
  item.done = !item.done
  item.save
  content_type 'application/json'
  if item.done?
    value = 'done'
  else
    value = 'not done'
  end
  #binding.pry
  {:id => item.id, :status => value}.to_json
end

get '/delete/:id' do
  @item = Item.first(:id => params[:id])
  erb :delete
end

post '/delete/:id' do
  if params.has_key?("ok")
    item = Item.first(:id => params[:id])
	item.destroy
	redirect '/'
	#binding.pry
  else
    #binding.pry
    redirect '/'
  end
end