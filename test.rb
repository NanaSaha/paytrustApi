require 'twilio-ruby'
require 'pony'
require 'mail'
CTRYCODE = '+233'.freeze
CTRYCODES = '+'.freeze


def validatePhoneNumber(mobile_number)
  puts "THE PHONE NUMBER IS "
  wildcard_search = "#{mobile_number}"
 puts  wildcard_search
  puts "THE PHONE NUMBER LENGHT"
 puts  wildcard_search.length
puts "--------------------------"
  if wildcard_search[0..2]=='233' && wildcard_search.length==12
    puts wildcard_search=CTRYCODE+"#{wildcard_search[3..wildcard_search.length]}"
  elsif wildcard_search[0..5]=='233' && wildcard_search.length==12
    puts wildcard_search=CTRYCODE+"#{wildcard_search[3..wildcard_search.length]}"
  elsif wildcard_search[0]=='0' && wildcard_search.length==10
    puts "RUN THIS -------"
    puts wildcard_search = CTRYCODE+"#{wildcard_search[1..wildcard_search.length]}"
  elsif wildcard_search[0]=='0' && wildcard_search.length>10
    puts "RUN THIS IF ITS  STRING AND HAS more THAN 10  -------"
    puts wildcard_search = CTRYCODE+"#{wildcard_search[1..wildcard_search.length]}"
  elsif  wildcard_search.length==10
    puts "RUN THIS IF IS NOT A TRING-------"
    puts wildcard_search = CTRYCODE+"#{wildcard_search[1..wildcard_search.length]}"
  elsif wildcard_search[0] == '+' && wildcard_search[1..3] == '233'&& wildcard_search[4..wildcard_search.length].length == 9
    puts wildcard_search = CTRYCODE+"#{wildcard_search[4..wildcard_search.length]}"
  elsif wildcard_search[0] != "+" && wildcard_search[0..2]!='233' && wildcard_search.length == 9
    puts wildcard_search=CTRYCODE+"#{wildcard_search[0..wildcard_search.length]}"
   elsif wildcard_search[0] != "+" && wildcard_search[0..5]!='233' && wildcard_search.length == 9
    puts wildcard_search=CTRYCODE+"#{wildcard_search[0..wildcard_search.length]}"
  elsif wildcard_search[0..1]=='00'
    puts  wildcard_search=CTRYCODES+"#{wildcard_search[2..wildcard_search.length]}"
  end
  
  return wildcard_search
end

def sendmsg(sender_id, recipient_number, message_body)

    account_sid = ''
    auth_token = ''
    @client = Twilio::REST::Client.new(account_sid, auth_token)
    
    from = sender_id # Your Twilio number
    to = validatePhoneNumber(recipient_number) # Your mobile phone number
    puts "VALID NUMBER #{to}"
    puts @client.messages.create(
    from: from,
    to: to,
    body: message_body
    )
    
    
    end

  #  sendmsg("SWIFT","0501648266", "HEllo World") 


   

    

 
