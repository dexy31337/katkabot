#!/usr/bin/env ruby

require 'telegram/bot'
require 'logger'

=begin
manage - Управлять подпиской
list - список всех кто катает
listCS - список кто катает в КС
listValorant - список кто катает в Valorant
goCS - заколить CS
goValorant - заколить Valorant
maps_all - Выбор из 18 карт CS
maps_comp - Выбор из оф. маппула CS
cocktail - Коктейль
=end

TELEGRAM_BOT_TOKEN = ENV['TOKEN']


maps = ['Ancient','Anubis','Cache','Canals','Cobblestone','D2','Engage','Inferno','Mirage','Nuke','Overpass','Train','Vertigo','Agency','Apollo','Italy','Militia','Office']
comp_maps = ['D2','Inferno','Mirage','Nuke','Overpass','Ancient','Vertigo']
cocktails = ['Молик тебе в темку','Две хаешки на твой банан','Засмочил тебе туалеты','А не сгоришь в молике?','Сейчас я им буст развалю','ХЕ себе под ноги кинь!','Выходи так, там никого','Я белый...','Даю декой в коннектор','Спрей контролить научись, потом проси','Может тебе еще хед флешкой поставить?','Попикай пока, а там посмотрим','А без флешки слабо выйти?']

usernamesCS = []
usernamesValorant = []

csUsersFile = './db/users'
valorantUsersFile = './db/usersValorant'

if File.exists?(csUsersFile)
  marsharr = Marshal.load File.read(csUsersFile)
  usernamesCS = usernamesCS + marsharr.reject { |e| e.to_s.empty? }
  puts "Read CS users file:"
  puts usernamesCS
else
  puts "Starting with empty file"
end

if File.exists?(valorantUsersFile)
  marsharr = Marshal.load File.read(valorantUsersFile)
  usernamesValorant = usernamesValorant + marsharr.reject { |e| e.to_s.empty? }
  puts "Read Valoran users file:"
  puts usernamesValorant
else
  puts "Starting with empty file"
end


Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN, logger: Logger.new(STDOUT)) do |bot|
    bot.listen do |message|
       case message
        when Telegram::Bot::Types::CallbackQuery
        puts "From: @---#{message.from.username}---"
        text = ""
        case message.data
            when 'addCS'
              if (message.from.username == nil)
                text = "У тебя нет юзернейма :( Не могу"
              elsif usernamesCS.index(message.from.username)
                text = "А какбэ ты и так в списке..."
              else
                usernamesCS << message.from.username 
                File.write(csUsersFile,Marshal.dump(usernamesCS))
                text = "Готово, #{message.from.username}, добавил к шпекерам в CS!"
              end
            when 'delCS'
                if (message.from.username == nil)
                    text = "У тебя нет юзернейма :( Не могу"
                elsif usernamesCS.index(message.from.username)
                    usernamesCS.delete_at(usernamesCS.index(message.from.username))
                    File.write(csUsersFile,Marshal.dump(usernamesCS))
                    text = "Готово, #{message.from.username}, больше не буду звать в CS!"
                else
                    text = "Тебя нет в списке шпекеров в CS."
                end
            when 'addValorant'
                if (message.from.username == nil)
                text = "У тебя нет юзернейма :( Не могу"
              elsif usernamesValorant.index(message.from.username)
                text = "А какбэ ты и так в списке..."
              else
                usernamesValorant << message.from.username 
                File.write(valorantUsersFile,Marshal.dump(usernamesValorant))
                text = "Готово, #{message.from.username}, добавил к шпекерам в Valorant!"
              end
            
            when 'delValorant'
                if (message.from.username == nil)
                    text = "У тебя нет юзернейма :( Не могу"
                elsif usernamesValorant.index(message.from.username)
                    usernamesValorant.delete_at(usernamesValorant.index(message.from.username))
                    File.write(valorantUsersFile,Marshal.dump(usernamesValorant))
                    text = "Готово, #{message.from.username}, больше не буду звать в Valorant!"
                else
                    text = "Тебя нет в списке шпекеров в Valorant."
                end
            end
            bot.api.send_message(chat_id: message.from.id, text: text)
        when Telegram::Bot::Types::Message
            puts "@#{message.from.username}: #{message.text}"
            puts "Chat-ID: #{message.chat.id}"
            puts "From-ID: #{message.from.id}"
            
 
            case message.text
            when /stop/i
                kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
                bot.api.send_message(chat_id: message.chat.id, text: 'Disabling', reply_markup: kb)
            when /cocktail/i
                text = cocktails[rand(cocktails.length)]
                bot.api.send_message(chat_id: message.chat.id, text: text)

            when /maps_all/i
                text = "Го катнём на #{maps[rand(maps.length)]}"
                bot.api.send_message(chat_id: message.chat.id, text: text)
            when /maps_comp/i
                text = "Го катнём на #{comp_maps[rand(comp_maps.length)]}"
                bot.api.send_message(chat_id: message.chat.id, text: text)
            when /listCS/i
                text = "В КТ гоняют\n   " + usernamesCS.join("\n   ")
                bot.api.send_message(chat_id: message.chat.id, text: text)
            when /listValorant/i
                text = "В Валорант гоняют\n   " + usernamesValorant.join("\n   ")
                bot.api.send_message(chat_id: message.chat.id, text: text)
            when /list/i
                text = "В КТ гоняют\n   " + usernamesCS.join("\n   ") + "\n\n" + "В Валорант гоняют\n   " + usernamesValorant.join("\n   ")
                bot.api.send_message(chat_id: message.chat.id, text: text)
            when /(manage|start)/i
                kb = [
                    [
                        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Add CS', callback_data: 'addCS'),
                        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Add Valorant', callback_data: 'addValorant')
                    ],
                    [
                        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Del CS', callback_data: 'delCS'),
                        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Del Valorant', callback_data: 'delValorant')
                    ]
                ]
                markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
                #TODO - add 403 handler
                begin
                    bot.api.send_message(chat_id: message.from.id, text: 'Make a choice', reply_markup: markup)
                rescue Telegram::Bot::Exceptions::ResponseError => e
                    if e.error_code == 403
                        bot.api.send_message(chat_id: message.chat.id, text: "Не могу тебе написать, пока ты не начнешь со мной чат... Переходи -> @potnayakatka_bot")
                    else
                        bot.api.send_message(chat_id: message.chat.id, text: e.message)
                    end
                end
            when /goCS/i
                text = "Го катать в CS! @" + usernamesCS.join(" @") 
                bot.api.send_message(chat_id: message.chat.id, text: text)
            when /goValorant/i
                text = "Го катать в Valorant! @" + usernamesValorant.join(" @") 
                bot.api.send_message(chat_id: message.chat.id, text: text)
            end

        end
    end
end
