require 'twilio-ruby'
require 'pony'
require 'mail'
require 'resolv-replace'
CTRYCODE = '+233'.freeze
CTRYCODES = '+'.freeze

ERR_EMAIL_SUCCESS = {resp_code: '130', resp_desc: "Email has been sent successfully."}
Email_from1="noreply@mealsandfood.com"
Email_from = ""   #"ghinger@ghingerhealthcare.com.gh"
Email_sub = "Meals & Food"
EMAIL_SENDER = "Meals & Food"
REPLY_TO = "info@mealsandfood"
SIGN_UP_EMAIL_BODY = "You have successfully signed up on Meals & food" 
CURRENCY ="GHS"
  CHANNEL = "mobile_money"
  REQHDR = {'Content-Type' => 'Application/json', 'timeout' => '180'}
  URL='https://api.msmpusher.net'


APP_NAME = "MealsNFood"

APP_ID = "8748007164"
APP_KEY = "43210614"

CONN = Faraday.new(:url=>URL,:headers=>REQHDR) do |f|
  f.response :logger
  f.adapter Faraday.default_adapter
end





def make_payment(mobile, mobile_network, amount)
  reference = genUniqueCodeForMomo

  url = 'https://api.interpayafrica.com/v3/interapi.svc'
  url_endpoint = '/CreateMMPayment'
  conn = Faraday.new(url: url, headers: REQHDR, ssl: {verify: false}) do |f|
    f.response :logger
    f.adapter Faraday.default_adapter
  end


  ts = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  puts
   puts "CUSTOMER NUMBER #{mobile}"
  puts "NETWORK #{mobile_network}"
   puts "AMOUNT #{amount}"
   puts "reference #{reference}"
  puts
  payload = {
      :mobile => mobile,
      :app_id => APP_ID,
      :app_key => APP_KEY,
      :amount => amount,
      :currency => "GHS",
      :order_id => reference,
      :order_desc => "PayTrust Escrow",
      :mobile_network => mobile_network,
      :client_timestamp => ts,
      :feetypecode => "Paytrust"
     
  }

  #  wwtp_transactions(amount,reference,nw,customer_number)
 
  json_payload = JSON.generate(payload)
  msg_endpoint = "#{json_payload}"
  puts
  puts "JSON payload: #{json_payload}"
  puts

  def computeSignature(secret, data)
    digest = OpenSSL::Digest.new('sha256')
    signature = OpenSSL::HMAC.hexdigest(digest, secret.to_s, data)
    return signature
  end

  signature = computeSignature(APP_KEY, json_payload)
  begin
    resp = conn.post do |req|
      req.url url_endpoint
      req.options.timeout = 30 # open/read timeout in seconds
      req.options.open_timeout = 30 # connection open timeout in seconds
      req['Authorization'] = "#{APP_KEY}:#{signature}"
      req.body = json_payload
    end

    bidy = resp.body

    puts bidy.inspect
    puts resp
    puts resp.body
    puts "Result from req : #{resp.body}"
    
    return resp.body 
   return resp.body.to_json 
    puts
    #phone_numbers = validatePhoneNumber(customer_number)
   # logger.info sendmsg(phone_numbers, "Kindly Authorize payment from your momo wallet")

    resp.body
  rescue
    puts "errorrrrrrrrrrrrr"
  end

end

def numberFormatter(mobileNumber)
  wildcard_search = mobileNumber.to_s
  if wildcard_search[0..2] == '233' && wildcard_search.length == 12
    wildcard_search = CTRYCODE + (wildcard_search[3..wildcard_search.length]).to_s
  elsif wildcard_search[0] == '0' && wildcard_search.length == 10
    wildcard_search = CTRYCODE + (wildcard_search[1..wildcard_search.length]).to_s
  elsif wildcard_search[0] == '+' && wildcard_search[1..3] == '233' && wildcard_search[4..wildcard_search.length].length == 9
    wildcard_search = CTRYCODE + (wildcard_search[4..wildcard_search.length]).to_s
  elsif wildcard_search[0] != '+' && wildcard_search[0..2] != '233' && wildcard_search.length == 9
    wildcard_search = CTRYCODE + (wildcard_search[0..wildcard_search.length]).to_s
  end
  wildcard_search
end

def generateAuthCode
  authCode = loop do
    token = rand(999999).to_s.center(6, rand(9).to_s)
    break token unless VerificationCode.exists?(auth_code: token)
  end
  logVerificationCode(authCode)
  puts "Verification Code: #{authCode}"
  authCode
end

def genResetCode
  value = "#{(Time.now.to_f*1000.0).to_i}" #13 digits
  preferedValue =  value[9..13] 
  return preferedValue
  puts "AUTH Code preferedValue: #{preferedValue}"
  
end


def sendMessage(mobile_number,message_body,sender_identifier)
  resp_check = CONN.get do |t|
    t.url "/smsapi?key=#{STR_API_KEY.to_s}&to=#{mobile_number.to_s}&msg=#{message_body}&sender_id=#{sender_identifier}"

  end
  puts "-----API RESPONSE------"
  puts resp_check.body
  puts
  resp_check.body
end

def genUniqueCode
  id = Time.new.strftime("%Y%m%d%H%M%S%L") #Get current date to the milliseconds
  id = id.to_i.to_s(36)
  uniq_id = "PT#{id}"

  uniq_id
end

def genUniqueCodeOrder
  id = Time.new.strftime("%Y%m%d%H%M%S%L") #Get current date to the milliseconds
  id = id.to_i.to_s(36)
  uniq_id = "MNF#{id}"

  uniq_id
end

#Process Order#

def processOrder
  request.body.rewind
  req = JSON.parse request.body.read
  user_id = req["user_id"]
  orders = req["orders"]
  total_price = req ["total_price"]

  if orders.empty?
    ## Orders cant be empty
    ERR_NULL_ORDERS.to_json
  end

  order_id = genUniqueCodeOrder
  orders.each do |order|
    puts "------Orders Here-----"
    puts
    puts order.inspect

    ## Insert order items
    puts insertOrderItems(order_id,order["meals_id"],order["quantity"],order["price"],total_price)
  end
  puts "--------USER ID IS------------------------"
  puts "--------#{user_id}------------------------"
  puts "--------ORDERS IS------------------------"
  puts "--------#{orders}------------------------"
  puts insertOrder(order_id,user_id)

  process_hash = {"order_id" => order_id, "response"=> STR_ORDER_GEN}
  process_hash.to_json
  halt Oj.dump(process_hash)
end




def processFoodOrder
  request.body.rewind
  req = JSON.parse request.body.read
  user_id = req["user_id"]
  orders = req["orders"]
  total_price = req ["total_price"]

  if orders.empty?
    ## Orders cant be empty
    ERR_NULL_ORDERS.to_json
  end

  order_id = genUniqueCodeOrder
  orders.each do |order|
    puts "------Orders Here-----"
    puts
    puts order.inspect

    ## Insert order items
    puts insertFoodOrderItems(order_id,order["food_id"],order["quantity"],order["price"],total_price)
  end
  puts "--------USER ID IS------------------------"
  puts "--------#{user_id}------------------------"
  puts "--------ORDERS IS------------------------"
  puts "--------#{orders}------------------------"
  puts "--------TOTAL PRICE IS #{total_price}------------------------"
  puts insertFoodOrder(order_id,user_id)

  process_hash = {"order_id" => order_id, "response"=> STR_ORDER_GEN}
  process_hash.to_json
  halt Oj.dump(process_hash)
end



def processCateringOrder 
  request.body.rewind
  req = JSON.parse request.body.read
  user_id = req["user_id"]
  orders = req["orders"]
  total_price = req ["total_price"]

  if orders.empty?
    ## Orders cant be empty
    ERR_NULL_ORDERS.to_json
  end

  order_id = genUniqueCodeOrder
  orders.each do |order|
    puts "------Orders Here-----"
    puts
    puts order.inspect

    ## Insert order items
    puts insertCateringOrderItems(order_id,order["catering_meals_id"],order["quantity"],order["price"],total_price)
  end
  puts "--------USER ID IS------------------------"
  puts "--------#{user_id}------------------------"
  puts "--------ORDERS IS------------------------"
  puts "--------#{orders}------------------------"
  puts "--------TOTAL PRICE IS #{total_price}------------------------"
  puts insertCateringOrder(order_id,user_id)

  process_hash = {"order_id" => order_id, "response"=> STR_ORDER_GEN}
  process_hash.to_json
  halt Oj.dump(process_hash)
end

#Login Access#

def loginAccount
  request.body.rewind
  req = JSON.parse request.body.read

  _mobile_number = req["mobile_number"]
  _master_pin = req["master_pin"]
  puts  "----------LOGIN FUNCTION RUNNING---------"
  login(_mobile_number,_master_pin)
end

#Create User Account#

def createAccount
  request.body.rewind
  req = JSON.parse request.body.read
  logAccountCreation(req["first_name"],req["last_name"], req["email"], req["mobile_number"],req["location"])
end

#Activate Account#

def activateAccount
  request.body.rewind
  req = JSON.parse request.body.read
  verifyUser(req['mobile_number'],req['default_pin'],req['master_pin'])
end

##Show User Orders##

def viewOrders
  request.body.rewind
  req = JSON.parse request.body.read
  user_id = req["user_id"]
  fetchOrders(user_id)
end

def viewFoodOrders
  request.body.rewind
  req = JSON.parse request.body.read
  user_id = req["user_id"]
  fetchFoodOrders(user_id)
end


def viewCateringOrders
  request.body.rewind
  req = JSON.parse request.body.read
  user_id = req["user_id"]
  fetchCateringOrders(user_id)
end
##Show customer order details

def viewOrderDetails
  request.body.rewind
  req = JSON.parse request.body.read
  _order_id = req["order_id"]
  fetchOrderDetails(_order_id)
end

def viewFoodOrderDetails
  request.body.rewind
  req = JSON.parse request.body.read
  _order_id = req["order_id"]
  fetchFoodOrderDetails(_order_id)
end

def viewCateringOrderDetails
  request.body.rewind
  req = JSON.parse request.body.read
  _order_id = req["order_id"]
  fetchCateringOrderDetails(_order_id)
end

def accountReset
  request.body.rewind
  req = JSON.parse request.body.read
  puts "---------Data-------"
  puts req["email"]
  puts req["mobile_number"]
  puts "--------------------"
  invalidateOldAccount(req["email"],req["mobile_number"])
end

def invalidateOldAccount(email,mobile_number)
  if User.where(email: email, mobile_number: mobile_number, status: true,verified: true).exists?
    _accounts = User.where(email: email, mobile_number: mobile_number)
    _accounts.each do |account|
      User.where(id: account.id).update_all(status: false, verified: false)
    end
    logAccountCreation(_accounts[0]["first_name"],_accounts[0]["last_name"], email, _accounts[0]["mobile_number"],_accounts[0]["location"])
  elsif User.where(email: email, mobile_number: mobile_number, status: true, verified: false).exists?

    ERR_VERIFY_BEFORE_RESET.to_json
  else

    ERR_NO_RESET.to_json

  end
end

def requestDefaultPIN
  request.body.rewind
  req = JSON.parse request.body.read
  if User.where(mobile_number: req["mobile_number"],status: true, verified: false).exists?
    else
    #Oj.dump(ERR_REQ_DEF_PIN)
    ERR_REQ_DEF_PIN.to_json
  end

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






def send_email(recipient_email, email_body, email_subj)
  
  # puts Pony.mail({
  #   :to => recipient_email,
  #   :from => 'firstnews1975@gmail.com',
  #   :sender => 'firstnews1975@gmail.com',
  #    :subject => email_subj,
  #   :body => email_body,
  #   # :headers => { 'Content-Type' => 'text/html' },
  #   # :subject => email_subj,
  #   # :body =>  "<h1> BOooooo </h1>",
    
    
    
  #   :via => :smtp,
  #   :via_options => {
  #     :address              =>  'smtp.gmail.com',  #smtp.gmail.com',
  #     :port                 => '587',
  #     :enable_starttls_auto => true,
  #     :user_name            => 'firstnews1975@gmail.com', #'ghingerhealthcare1@gmail.com',
  #     :password             => 'amdbestofall',#'lhleljpiskxuegjs', #'wiwkbxgovelwjroi',
  #     :authentication       => :login, # :plain, :login, :cram_md5, no auth by default
  #     :domain               => "localhost.localdomain", # the HELO domain provided by the client to the server
  #     # :openssl_verify_mode  => "none"
  #   }
  # })



    puts Pony.mail({
    :to => recipient_email,
    :from => 'no-reply@ghingerhealth.com',
    :sender => 'no-reply@ghingerhealth.com',
    :subject => email_subj,
    :body => email_body,
    
    
    
    :via => :smtp,
    :via_options => {
      :address              => 'smtp.gmail.com',
      :port                 => '587',
      :enable_starttls_auto => true,
      :user_name            => 'nobkobby@gmail.com', #'ghingerhealthcare1@gmail.com',
      :password             => 'malianaana1',#'lhleljpiskxuegjs', #'wiwkbxgovelwjroi',
      :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain               => "localhost.localdomain", # the HELO domain provided by the client to the server
    }
  })
  

  return ERR_EMAIL_SUCCESS.to_json
end



# def send_email()
#   
  # puts Pony.mail({
    # :to => "nana.osafo.bosompem@gmail.com",
    # :from => 'no-reply@mealsandfood.com',
    # :sender => 'no-reply@mealsandfood.com.com',
    # :subject => "MEALS & FOOD",
    # :body => "TESTING EMAIL",
#     
#     
#     
    # :via => :smtp,
    # :via_options => {
      # :address              => 'smtp.gmail.com',
      # :port                 => '587',
      # :enable_starttls_auto => true,
      # :user_name            => 'nobkobby@gmail.com', #'ghingerhealthcare1@gmail.com',
      # :password             => 'amdbestofall1',#'lhleljpiskxuegjs', #'wiwkbxgovelwjroi',
      # :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
      # :domain               => "localhost.localdomain", # the HELO domain provided by the client to the server
    # }
  # })
#   
# 
  # return ERR_EMAIL_SUCCESS.to_json
# end





def saveTransaction(user_id,order_id,reference,mobile_number,amount,payment_method,mobile_wallet_number,mobile_wallet_network,payment_description,message,success)
  PaymentTransaction.create!(user_id: user_id,order_id: order_id,reference: reference,mobile_number: mobile_number,amount: amount,
                       payment_method: payment_method, mobile_wallet_number: mobile_wallet_number,mobile_wallet_network: mobile_wallet_network,
                       payment_description: payment_description,message: message,success: success, status: 0)
end


def saveCallback(reference,message,success,status)
  PaymentCallbackStatus.create!(reference: reference,message: message,success: success,status: status)
end


#MAKE MOMO PAYMENT
def genUniqueCodeForMomo
  time=Time.new
  strtm=time.strftime("PT%d%L%H%M")
  return strtm
end



def payment(user_id,order_id,customer_name,customer_email,customer_telephone,mobile_wallet_number,mobile_wallet_network,amount,voucher)
  
  reference = genUniqueCodeForMomo
  
  puts "----Reference----"
  puts reference
  puts "-----------------"
  
  url = URI("https://epaygh.com/api/v1/token")
  use_ssl = true

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = use_ssl

  request = Net::HTTP::Post.new(url)
  request["Content-Type"] = "application/json"
  request.body = "{\t\n\t\"merchant_key\" : \"iq9cFQscbBVO1n5n\",\n\t\"app_id\" : \"5cd92d0399d6d\",\n\t\"app_secret\": \"WeMNyH6k0UJsDxFYxASpyLVs6Q7Safyn\"\n}"

  response = http.request(request)
  puts response.read_body
  
  req = JSON.parse response.read_body
  access_token = req ['data']['access_token']
  puts "ACCESS TOKEN IS #{access_token}"
  
  
  
   puts "PAYMENT_METHOD #{PAYMENT_METHOD}"
   puts "PAYMENT_DESCRIPTION #{PAYMENT_DESCRIPTION}"
  ####CHARGE CUSTOMER #######
  
  charge_url = URI("https://epaygh.com/api/v1/charge")
  use_ssl = true

  charge_http = Net::HTTP.new(charge_url.host, charge_url.port)
  charge_http.use_ssl = use_ssl

  charge_request = Net::HTTP::Post.new(charge_url)
  charge_request["Content-Type"] = "application/json"
  charge_request["Authorization"] = "Bearer #{access_token}"
  charge_request.body = "{
  \t\n\t\"reference\" : \"#{reference}\",
  \n\t\"amount\" : \"#{amount}\"\n,
  \n\t\"payment_method\": \"#{PAYMENT_METHOD}\"\n,
  \n\t\"customer_name\": \"#{customer_name}\"\n,
  \n\t\"customer_email\": \"#{customer_email}\"\n,
  \n\t\"customer_telephone\": \"#{customer_telephone}\"\n,
  \n\t\"mobile_wallet_number\": \"#{mobile_wallet_number}\"\n,
  \n\t\"mobile_wallet_network\": \"#{mobile_wallet_network}\"\n,
  \n\t\"payment_description\": \"#{PAYMENT_DESCRIPTION}\"\n,
  \n\t\"voucher\": \"#{voucher}\"\n
  
  }"

  charge_response = charge_http.request(charge_request)
  puts "--------- RESPONSE AFTER CHARGING CUSTOMER----------"
  puts charge_response.read_body
  
  req2 = JSON.parse charge_response.read_body
  success = req2 ['success']
  message = req2 ['message']
  reference = req2 ['data']['transaction']['reference']
  puts "success #{success}"
  puts "message #{message}"
  puts "reference #{reference}"
  puts "--------- end----------"
  
  puts "--------- SAVING TRANSACTION----------"
  # saveTransaction(user_id,order_id,reference,mobile_number,amount,payment_method,mobile_wallet_number,mobile_wallet_network,payment_description,message,success)
  saveTransaction(user_id,order_id,reference,customer_telephone,amount,PAYMENT_METHOD,mobile_wallet_number,mobile_wallet_network,PAYMENT_DESCRIPTION,message,success)
  
 
 
  ######RETRIEVE TRANSACTION#######
 
  trans_url = URI("https://epaygh.com/api/v1/transactions/#{reference}")
  use_ssl = true

  trans_http = Net::HTTP.new(trans_url.host, trans_url.port)
  trans_http.use_ssl = use_ssl

  trans_request = Net::HTTP::Get.new(trans_url)
  trans_request["Content-Type"] = "application/json"
  trans_request["Authorization"] = "Bearer #{access_token}"
 

  trans_response = trans_http.request(trans_request)
  puts "-----------RETRIEVINFG TRANSACION"
  puts trans_response.read_body
  
  req3 = JSON.parse trans_response.read_body
  success = req3 ['success']
  message = req3 ['message']
  reference = req3 ['transaction']['reference']
  status = req3 ['transaction']['status']
  type = req3 ['transaction']['type']
  
  puts "success #{success}"
  puts "message #{message}"
  puts "reference #{reference}"
  puts "status #{status}"
  puts "type #{type}"
  
  puts "--------- SAVING CALLBACK----------"
  puts saveCallback(reference,message,success,status)
  
  puts "-----------RETRIEVINFG TRANSACION END"


end




#RetrieveTOTALFOODSALES
def total_amount_spent_foodstuff
  request.body.rewind
  req = JSON.parse request.body.read
  user_id = req["user_id"]
  retrieve_total_amount_spent(user_id)
end


def paystackPayment(email,amount)
  
  reference = genUniqueCodeForMomo
  
  puts "----Reference----"
  puts reference
  puts "-----------------"
  
 url = URI("https://api.paystack.co/charge")
  #  url="https://api.paystack.co"
  # url_endpoint='/charge'
  use_ssl = true

 http = Net::HTTP.new(url.host, url.port)
 http.use_ssl = use_ssl

  secret_key = "sk_live_fc5631a4ce92c69d759448161079546920929adc"

  conn = Faraday.new(:url => url, :headers => REQHDR, :ssl => {:verify => false}) do |faraday|
      faraday.response :logger # log requests to STDOUT
      faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
    end

  request = Net::HTTP::Post.new(url)
  request["Content-Type"] = "application/json"
  request["Authorization"] = "Bearer #{secret_key}"
 

  request.body ={
        # :email => email,
        # :amount => amount,
        # :currency => CURRENCY,
        # :reference => reference,
        # :callback_url => CALLBACK_URL,
        # :channels => CHANNEL,

          "email": email,
        "amount": amount,
        "currency": CURRENCY,
        "reference": reference,
        "callback_url": CALLBACK_URL,
        "channels": CHANNEL,
        "mobile_money": { 
        "phone": "0204459625", 
          "provider": "vod"
        } 

    }

  # {"email":"nobkobby@gmail.com","amount":"10","currency":"GHS","reference":"MNF012981548","callback_url":"https://api.mealsandfood.com/primary_callback","channels":"mobile_money"}


   request.body =JSON.generate(request.body)
   puts "JSON PAYLOAD #{request.body}"

    #  res = conn.post do |req|
    #   req.url url_endpoint
    #   req.options.timeout = 60 # open/read timeout in seconds
    #   req.options.open_timeout = 60 # connection open timeout in seconds
    #   req["Content-Type"] = "application/json"
    #   req["Authorization"]="Bearer #{secret_key}"
    #   req.body = json_payload
    # end

    # puts "Response from payment #{res.inspect}" 
    # puts "message #{res.response_body}" 

   charge_response = http.request(request)
  puts "--------- RESPONSE AFTER CHARGING CUSTOMER----------"
  puts "Response from payment #{charge_response}" 
  puts charge_response.read_body
  req2 = JSON.parse charge_response.read_body
  status = req2 ['status']
  message = req2 ['message']
  reference = req2 ['data']['reference']
  pay_status = req2 ['data']['status']
  display_text = req2 ['data']['display_text']

   puts "--------- Status: #{status}"
   puts "--------- message: #{message}"
   puts "--------- reference: #{reference}"
   puts "--------- pay_status: #{pay_status}"
   puts "--------- display_text: #{display_text}"
   

  # response = http.request(request)
  # puts "-- RESPNSE BODY0-----"
  # puts response.read_body
  
  # req = JSON.parse response.read_body

  # curl https://api.paystack.co/charge -H "Authorization: Bearer sk_live_fc5631a4ce92c69d759448161079546920929adc" -H "Content-Type: application/json" -d '{ "amount": 100,
  #     "email": "customer@email.com",
  #     "currency": "GHS",
  #     "mobile_money": {
  #       "phone" : "0556624118",
  #       "provider" : "mtn"
  #     }
  #   }' -X POST







  # access_token = req ['data']['access_token']
  # puts "ACCESS TOKEN IS #{access_token}"
  
  
  
  #  puts "PAYMENT_METHOD #{PAYMENT_METHOD}"
  #  puts "PAYMENT_DESCRIPTION #{PAYMENT_DESCRIPTION}"

  # ####CHARGE CUSTOMER #######
  
  # charge_url = URI("https://epaygh.com/api/v1/charge")
  # use_ssl = true

  # charge_http = Net::HTTP.new(charge_url.host, charge_url.port)
  # charge_http.use_ssl = use_ssl

  # charge_request = Net::HTTP::Post.new(charge_url)
  # charge_request["Content-Type"] = "application/json"
  # charge_request["Authorization"] = "Bearer #{access_token}"
  # charge_request.body = "{
  # \t\n\t\"reference\" : \"#{reference}\",
  # \n\t\"amount\" : \"#{amount}\"\n,
  # \n\t\"payment_method\": \"#{PAYMENT_METHOD}\"\n,
  # \n\t\"customer_name\": \"#{customer_name}\"\n,
  # \n\t\"customer_email\": \"#{customer_email}\"\n,
  # \n\t\"customer_telephone\": \"#{customer_telephone}\"\n,
  # \n\t\"mobile_wallet_number\": \"#{mobile_wallet_number}\"\n,
  # \n\t\"mobile_wallet_network\": \"#{mobile_wallet_network}\"\n,
  # \n\t\"payment_description\": \"#{PAYMENT_DESCRIPTION}\"\n,
  # \n\t\"voucher\": \"#{voucher}\"\n
  
  # }"

  # charge_response = charge_http.request(charge_request)
  # puts "--------- RESPONSE AFTER CHARGING CUSTOMER----------"
  # puts charge_response.read_body
  
  # req2 = JSON.parse charge_response.read_body
  # success = req2 ['success']
  # message = req2 ['message']
  # reference = req2 ['data']['transaction']['reference']
  # puts "success #{success}"
  # puts "message #{message}"
  # puts "reference #{reference}"
  # puts "--------- end----------"
  
  # puts "--------- SAVING TRANSACTION----------"
  
  # saveTransaction(user_id,order_id,reference,customer_telephone,amount,PAYMENT_METHOD,mobile_wallet_number,mobile_wallet_network,PAYMENT_DESCRIPTION,message,success)
  

 
  # ######RETRIEVE TRANSACTION#######
 
  # trans_url = URI("https://epaygh.com/api/v1/transactions/#{reference}")
  # use_ssl = true

  # trans_http = Net::HTTP.new(trans_url.host, trans_url.port)
  # trans_http.use_ssl = use_ssl

  # trans_request = Net::HTTP::Get.new(trans_url)
  # trans_request["Content-Type"] = "application/json"
  # trans_request["Authorization"] = "Bearer #{access_token}"
 

  # trans_response = trans_http.request(trans_request)
  # puts "-----------RETRIEVINFG TRANSACION"
  # puts trans_response.read_body
  
  # req3 = JSON.parse trans_response.read_body
  # success = req3 ['success']
  # message = req3 ['message']
  # reference = req3 ['transaction']['reference']
  # status = req3 ['transaction']['status']
  # type = req3 ['transaction']['type']
  
  # puts "success #{success}"
  # puts "message #{message}"
  # puts "reference #{reference}"
  # puts "status #{status}"
  # puts "type #{type}"
  
  # puts "--------- SAVING CALLBACK----------"
  # puts saveCallback(reference,message,success,status)
  
  # puts "-----------RETRIEVINFG TRANSACION END"


end


