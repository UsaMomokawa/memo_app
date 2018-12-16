require 'sinatra'
require 'sinatra/reloader'
require 'json'

enable :method_override

get '/' do
  # sort files in descending order
  @filenames = Dir.glob('public/*.json').sort.reverse
  erb :index
end

get '/memos' do
  redirect '/'
end

get '/new' do
  erb :new
end

post '/new' do
  memo_id = Time.now.to_i
  memo_title = params[:title]
  memo_content = params[:content]

  if memo_title == '' || memo_content == ''
    erb :new
  else
    # create hash
    hash = { 'id' => memo_id, 'title' => memo_title, 'content' => memo_content }

    # create json file
    File.open("public/memo_#{memo_id}.json", 'w') do |json_file|
      JSON.dump(hash, json_file)
    end

    redirect "/memos/#{memo_id}"
  end
end

get '/memos/:id' do
  File.open("public/memo_#{params[:id]}.json") do |opened_file|
    @memo = JSON.parse(opened_file.read)
  end
  erb :show
end

delete '/memos/:id' do
  # delete file
  File.delete("public/memo_#{params[:id]}.json")
  redirect '/'
end

get '/memos/:id/edit' do
  File.open("public/memo_#{params[:id]}.json") do |opened_file|
    @memo = JSON.parse(opened_file.read)
  end
  erb :edit
end

patch '/memos/:id/edit' do
  File.open("public/memo_#{params[:id]}.json") do |opened_file|
    memo = JSON.parse(opened_file.read)
    @old_id = memo['id']
  end

  new_id = Time.now.to_i
  new_title = params[:title]
  new_content = params[:content]

  if new_title == '' || new_content == ''
    # return to edit
    erb :edit
  else
    hash = { 'id' => new_id, 'title' => new_title, 'content' => new_content }

    # create new file
    File.open("public/memo_#{new_id}.json", 'w') do |json_file|
      JSON.dump(hash, json_file)
    end
    # delete old file
    File.delete("public/memo_#{@old_id}.json")

    redirect "/memos/#{new_id}"
  end
end
