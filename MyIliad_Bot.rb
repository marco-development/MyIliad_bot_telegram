#!/usr/bin/env ruby

require 'mechanize'
require 'telegram/bot'
require 'httparty'
require 'nokogiri'
require 'open-uri'

def iliad(u_id, psw)
  client = Mechanize.new
  login = client.get('https://www.iliad.it/account/')
  form = login.forms.first  
    form['login-ident'] = u_id
    form['login-pwd'] = psw
    result = form.submit

  page = client.get('https://www.iliad.it/account/')
  File.open("cache.html","w") { |file|
    file.write page.body }

  parsed_content = File.open("cache.html") { |f| Nokogiri::HTML(f) }
  tab = parsed_content.css('.remodal-bg').css('.page-container').css('.page-content').css('.p-conso').css('.red').map(&:text)
  
  File.open("cache.html","w") { |file|       # pulisco il file 
    file.write '000' }
  
  return tab
end

def italia(u_id, psw)
  tab = iliad(u_id, psw)
  return "User_Id o Password Errate o SIM non attiva" if tab == []
  return "- Consumi Italia\nCredito Residuo: #{tab[0]}\nChiamate: #{tab[1]}, #{tab[2]}\nSMS: #{tab[3]}, #{tab[4]}\nDati: #{tab[7]} #{tab[8]}, #{tab[6]}\nMMS: #{tab[9]}, #{tab[10]}\n\nConsumo totale: #{tab[21]}"
end

def estero(u_id, psw)
  tab = iliad(u_id, psw)
  return "User_Id o Password Errate o SIM non attiva" if tab == []
  return "- Consumi estero\n\nCredito Residuo: #{tab[0]}\nChiamate: #{tab[11]}, #{tab[12]}\nSMS: #{tab[13]}, #{tab[14]}\nDati: #{tab[18]} #{tab[19]}, #{tab[16]}\nMMS: #{tab[20]}, #{tab[21]}\n\nConsumo totale: #{tab[21]}"
end

def credito(u_id, psw)
  tab = iliad(u_id, psw)
  return "User_Id o Password Errate o SIM non attiva" if tab == []
  return "Credito Residuo: #{tab[0]}"
end

token  = '## token del bot ##'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    
    mex = message.text.split(' ')
    case 
      when (message.text == '/start' or mex[0] == '/start')
        bot.api.send_message(chat_id: message.chat.id, text: "Ciao #{message.from.first_name}")
      when (message.text == '/help' or mex[0] == '/help')
        bot.api.send_message(chat_id: message.chat.id, text: "Lista Comandi:\n/start - avvio bot\nPer ricevere le informazioni scrivere\n/\"comando\" \"user_id\" \"password\"\nI comandi sono:\n/italia - credito e consumi italia\n/estero - credito e consumi europa\n/credito - solo credito residuo")
      when mex[0] == '/italia'
        bot.api.send_message(chat_id: message.chat.id, text: "#{italia(mex[1], mex[2])}")
      when mex[0] == '/estero'
        bot.api.send_message(chat_id: message.chat.id, text: "#{tmp = estero(mex[1], mex[2])}")
      when mex[0] == '/credito'
        bot.api.send_message(chat_id: message.chat.id, text: "#{credito(mex[1], mex[2])}")
      else
        bot.api.send_message(chat_id: message.chat.id, text: "Comando Errato\n/help - lista comandi")
    end
  end
end
