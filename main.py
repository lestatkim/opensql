# -*- coding: utf-8 -*-
import telebot
import os
from constants import *


token = "334199785:AAHQO7im7HB8vNFpITksrZ3gSXsyqvN-0-o"
bot = telebot.TeleBot(token)
bot.remove_webhook()
upd = bot.get_updates()


def log(message, answer):
    from datetime import datetime
    print("\n-------\n{0} {1} : {2}".format(
        message.from_user.first_name,
        message.from_user.last_name,
        message.text),
        '  ',
        datetime.now()
    )
    print(answer)


@bot.message_handler(commands=["info"])
def handle_info(message):
    bot.reply_to(message, """
Напиши в поле чата знак вопроса
и t-sql команду, про которую
хочешь узнать. Например :
? update
или
? create index

И я раскажу тебе что мне о ней известно

#sqlcom
    """)


@bot.message_handler(content_types=['text'])
def handle_text_2(message):
    answer = 'command request'
    if message.text in [
        "? insert", "? INSERT", "? insert into", "? INSERT INTO"
    ]:
        log(message, answer)
        bot.reply_to(message, insert+sqlcom)
    elif message.text in [
        "? delete", "? DELETE", "? delete from", "? DELETE FROM"
    ]:
        log(message, answer)
        bot.reply_to(message, delete+sqlcom)
    elif message.text in [
            "? update", "? UPDATE", "? Update"
    ]:
        log(message, answer)
        bot.reply_to(message, update + sqlcom)
    elif message.text.startswith('? '):
        url = 'https://www.w3schools.com/sql/sql_{0}.asp'
        bot.reply_to(message, """
Мы еще не добавили {0} в наш список..
Сделай свой вклад в развитии Бота !
Отправь --> @lestvt описание синтаксиса по формату
    1. *Описание
    2. *Пример
    3. Свою подпись
 и мы добавим его в бот

или можешь почитать тут :
{1}
        """.format(message.text[2::], url.format(message.text[2::]).replace(' ', '_')))
        log(message, 'no syntax')
    else:
        pass


if __name__ == '__main__':
    os.system('clear')
    print('\n--------------\nserver started\n--------------')

    bot.polling(none_stop=True, interval=0)
