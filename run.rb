#!/usr/bin/env ruby

require 'logger'
require 'telegram_bot'
=begin
maps_all - Выбор из 18 карт
maps_comp - Выбор из 18 карт
callme - Вписаться в оповещения
fuckoff - Выписаться из оповещений
list - Список оповещаемых
iwannaplay - ГО КАТАц!
cocktail - Коктейль
=end
TELEGRAM_BOT_TOKEN = ENV['TOKEN'] 

bot = TelegramBot.new(token: TELEGRAM_BOT_TOKEN, logger: Logger.new(STDOUT))
maps = ['Ancient','Anubis','Cache','Canals','Cobblestone','D2','Engage','Inferno','Mirage','Nuke','Overpass','Train','Vertigo','Agency','Apollo','Italy','Militia','Office']
comp_maps = ['D2','Inferno','Mirage','Nuke','Overpass','Train','Vertigo']
cocktails = ['Молик тебе в темку','Две хаешки на твой банан','Засмочил тебе туалеты','А не сгоришь в молике?','Сейчас я им буст развалю','ХЕ себе под ноги кинь!','Выходи так, там никого','Я белый...','Даю декой в коннектор','Спрей контролить научись, потом проси','Может тебе еще хед флешкой поставить?','Попикай пока, а там посмотрим','А без флешки слабо выйти?']

usernames = []
usersFile = './db/users'

if File.exists?(usersFile)
  marsharr = Marshal.load File.read(usersFile)
  usernames = usernames + marsharr.reject { |e| e.to_s.empty? }
  puts "Read users file:"
  puts usernames
else
  puts "Starting with empty file"
end

bot.get_updates(fail_silently: true) do |message|
  puts "@#{message.from.username}: #{message.text}"
  puts "Chat-ID: #{message.chat.id}"
  command = message.get_command_for(bot)

  message.reply do |reply|
    case command
    when /start/i
      reply.text = "Готов хуячить, #{message.from.first_name}!"
    when /maps_all/i
      reply.text = "Го катнём на #{maps[rand(maps.length)]}"
    when /maps_comp/i
      reply.text = "Го катнём на #{comp_maps[rand(comp_maps.length)]}"
    when /callme/i
      if (message.from.username == "")
        reply.text = "У тебя нет юзернейма #{message.from.first_name} :( Не могу"
      elsif usernames.index(message.from.username)
        reply.text = "А какбэ ты и так в списке..."
      else
        usernames << message.from.username 
        File.open(usersFile, 'wb') {|f| f.write(Marshal.dump(usernames))}
        reply.text = "Готово, #{message.from.username}, добавил!"
      end
    when /fuckoff/i
      if usernames.index(message.from.username)
        usernames.delete_at(usernames.index(message.from.username))
        File.open(usersFile, 'wb') {|f| f.write(Marshal.dump(usernames))}
        reply.text = "Готово, #{message.from.username}, удалил!"
      else
        reply.text = "Расслабься, я и так не собирался."
      end
    when /cocktail/i
      reply.text = cocktails[rand(cocktails.length)]
    when /list/i
      reply.text = "В списке: " + usernames.join(", ")
    when /iwannaplay/i
      reply.text = "Го катать! @" + usernames.join(" @")
    else
      reply.text = ""
    end
    reply.send_with(bot) if reply.text != ''
  end
end
