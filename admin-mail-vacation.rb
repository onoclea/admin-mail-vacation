require 'rubygems'
require 'sinatra'
require 'managesieve'
require 'haml'

include Rack::Utils

get '/' do
 haml :vacation
end

post '/' do

 @username = params[:username]
 @password = params[:password]
 @subject = escape_html(params[:subject])
 @vacation_message = escape_html(params[:vacation_message]).gsub(/^(  )*/, '')

 begin
  m = ManageSieve.new(
    :host     => 'localhost',
    :port     => 4190,
    :user     => @username,
    :password => @password,
    :auth     => 'PLAIN',
    :tls      => false
  )

  if @subject.empty? || @vacation_message.empty?
   m.set_active('')
   m.delete_script('vacation_message')
  else
   sieve_script = erb :sieve_script 

   m.put_script('vacation_message', sieve_script)
   m.set_active('vacation_message')
  end

  m.logout
 rescue SieveCommandError
  @message = "Invalid username or password." unless @message
 end

 if @subject.empty? || @vacation_message.empty? then
  haml :vacation_deleted
 elsif @message then
  haml :vacation
 else
  @message = "Vacation message has been set."

  haml :vacation_set
 end

end
