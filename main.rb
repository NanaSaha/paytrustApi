require 'sinatra'
require 'rubygems'
require 'active_record'
require 'json'
require 'multi_json'
require 'oj'
require 'net/http'
require 'faraday'
require 'base64'
require 'digest/md5'
require 'uri'
require 'twilio-ruby'
require './constants'
require './functions'
require './db_functions'
require './model'
require './primary_callback'
   require 'csv'

CALLBACK_URL = "https://api.mealsandfood.com/primary_callback"  
PAYMENT_METHOD = "momo"
PAYMENT_DESCRIPTION = "Order Payment for M&F"

ERR_NAME ={ resp_code: '101', resp_desc: "Please provide Customer Name" }
ERR_EMAIL ={ resp_code: '101', resp_desc: "Please provide Customer Email" }
ERR_MOBILE_NUMBER = { resp_code: '101', resp_desc: 'Please provide Customer Phone' }
ERR_MOMO_NUM = { resp_code: '101', resp_desc: 'Please provide Customer MOMO number' }
ERR_MOMO_NET = { resp_code: '101', resp_desc: 'Please provide Customer MOMO Network' }
ERR_AMOUNT = { resp_code: '101', resp_desc: 'Please provide amount' }
ERR_USER_ID = { resp_code: '101', resp_desc: 'Please provide USER ID' }
ERR_ORDER_ID = { resp_code: '101', resp_desc: 'Please provide ORDER ID' }







post '/send_email' do

  request.body.rewind
  req = JSON.parse request.body.read
  #response['Access-Control-Allow-Origin'] = '*'
  puts req

  email = req['email'].strip.downcase
  sendEmail(email)
  
end


post '/paypay' do

request.body.rewind
req = JSON.parse request.body.read  

puts "REQUESTS DATA--->><><>#{req}<><><"

mobile = req['mobile']
mobile_network = req['mobile_network']
amount = req['amount']


pay = make_payment(mobile, mobile_network, amount)

 puts "PAY DATA--->><><>#{pay}<><><"
 regis_success  =  { resp_code: '000',resp_desc: 'Payment Processing....'} 

 return pay
 regis_success.to_json 

end


  post '/sign_up' do


     email = params['email'].strip.downcase
    fullname = params['fullname']
    phone = params['phone']
    password = params['password']
    ghana_card = params['ghana_card']
    location = params['location']
    profile_pic = params['profile_pic']

puts "----FULNNMAEE::: #{fullname}"

  # request.body.rewind
  # req = JSON.parse request.body.read


  # email = req['email'].strip.downcase
  # fullname = req['fullname']
  # phone = req['phone']
  # password = req['password']
  # ghana_card = req['ghana_card']
  # location = req['location']
  # profile_pic = req['profile_pic']
  #  blob = req['blob']
        
    insert_details_patient(email,fullname,phone,password,ghana_card,location,profile_pic)
    regis_success  =  { resp_code: '000',resp_desc: 'You have successfully registered on Pay Trust ! Kindly wait for a confirmation to proceed!'}
    return regis_success.to_json
end


post '/update_profile' do
  puts "------------------UPDATING PROFILE API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  email = req['email'].strip.downcase
  fullname = req['fullname']
  phone = req['phone']
  
    
     if Registration.exists?(:id => req['id'])
    edit_profile(id,email,fullname,phone)

    regis_success = { resp_code: '000',resp_desc: 'You have successfully edited your profile!'}

    regis_success.to_json

                else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end





post '/login' do
  
  
  request.body.rewind
  req = JSON.parse request.body.read

  #response['Access-Control-Allow-Origin'] = '*'
  
  email = req['email'].strip.downcase
  password = req['password']


    puts "EMAIL IS :  #{email} " 
    puts "PASSWORD IS: #{password}"

    if Registration.exists?(:email => email,:password => password) 

   db_password = Registration.where('password=? and email=?',password,email).order('id desc')

    puts "Password CORRECT" 
      puts "THE   SING IN IS #{email}"
        puts "THE   SING IN IS #{db_password[0]}"
   
    if  ((email == db_password[0].email) && (password == db_password[0].password))

      puts "################## START STEP 1 - retrieve_regis1 #################### "
        
        if Registration.retrieve_registration(email).exists?
            retrieve_registration = Registration.retrieve_registration(email)
            p "--------------LOGIN SUCESSFUL---------------"
            p retrieve_registration
            p retrieve_registration.to_json
          
         else
           retrieve_regis1 = ""
           
        end
  
    
      return { 'resp_code'=> "117", 'user_details' => retrieve_registration }.to_json


    else
      regis_success  =  { resp_code: "222",resp_desc: "Wrong Email/Password. Please try again or sign up if you don't have an account"}
      return regis_success.to_json
     end
  else
      regis_success  =  { resp_code: "222",resp_desc: "Account doesnt exist.Sign up if you don't have an account"}
      return  regis_success.to_json
     end
   
  
end


# CREATE TABLE `transactions` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `seller_name` varchar(255) DEFAULT NULL,
#   `seller_email` varchar(255) DEFAULT NULL,
#   `seller_phone` varchar(255) DEFAULT NULL,
#   `buyer_id` varchar(255) DEFAULT NULL,
#   `amount` varchar(255) DEFAULT NULL,
#   `fees` varchar(255) DEFAULT NULL,
#   `transaction_id` varchar(255) DEFAULT NULL,
#   `narration` varchar(255) DEFAULT NULL,
#   `item_name` varchar(255) DEFAULT NULL,
#   `item_description` varchar(255) DEFAULT NULL,
#   `transaction_title` varchar(255) DEFAULT NULL,
#   `paid_by` varchar(255) DEFAULT NULL,
#   `status` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))


  post '/save_transactions' do

  request.body.rewind
  req = JSON.parse request.body.read
  #response['Access-Control-Allow-Origin'] = '*'

  puts req
  person_name = req['person_name']
  person_email = req['person_email']
  user_id = req['user_id']
  amount = req['amount']
  fees = req['fees']
  item_name = req['item_name']
  item_description = req['item_description']
  item_quantity = req['item_quantity']
  status = req['status']



  
    insert_transactions(person_name,person_email,user_id,amount,fees,item_name,item_description,item_quantity,status)
        regis_success  =  { resp_code: '000',resp_desc: 'You have successfully registered!'}
    return regis_success.to_json
end



  post '/save_seller_transactions' do

  request.body.rewind
  req = JSON.parse request.body.read
  #response['Access-Control-Allow-Origin'] = '*'

  puts req
  buyer_name = req['buyer_name']
  buyer_email = req['buyer_email']
  buyer_phone = req['buyer_phone']
  seller_id = req['seller_id']
  amount = req['amount']
  fees = req['fees']
  narration = req['narration']
  item_name = req['item_name']
  item_description = req['item_description']
  transaction_title = req['transaction_title']
  paid_by = req['transaction_title']
  status = req['status']

  
    insert_seller_transactions(buyer_name,buyer_email,buyer_phone,seller_id,amount,fees,narration,item_name,item_description,transaction_title,paid_by,status)
        regis_success  =  { resp_code: '000',resp_desc: 'You have successfully registered!'}
    return regis_success.to_json
end



get '/retrieve_all_users' do
  retrieve_associates = Registration.retrieve_all_registration
  puts retrieve_associates.to_json
  return retrieve_associates.to_json
end

get '/retrieve_all_transactions' do
  retrieve_associates = Transaction.retrieve_all_transactions
  puts retrieve_associates.to_json
  return retrieve_associates.to_json
end






post '/retrieve_user_transactions' do

  request.body.rewind
  req = JSON.parse request.body.read

  user_id = req['user_id']
  if Transaction.exists?(:user_id => req['user_id'])
    retrieve = Transaction.retrieve_single_transactions(user_id)
 
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_transactions_pending' do

  request.body.rewind
  req = JSON.parse request.body.read

  user_id = req['user_id']
  if Transaction.exists?(:user_id => req['user_id'])
    retrieve = Transaction.retrieve_pending_transactions(user_id)
 
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/retrieve_transactions_joined' do

  request.body.rewind
  req = JSON.parse request.body.read

  user_id = req['user_id']
  if Transaction.exists?(:user_id => req['user_id'])
    retrieve = Transaction.retrieve_joined_transactions(user_id)
 
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/retrieve_transactions_pending_with_person_email' do

  request.body.rewind
  req = JSON.parse request.body.read

  person_email = req['person_email']
  if Transaction.exists?(:person_email => req['person_email'])
    retrieve = Transaction.retrieve_pending_transactions_personEmail(person_email)
 
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





post '/retrieve_transactions_with_transId' do

  request.body.rewind
  req = JSON.parse request.body.read

  transaction_id = req['transaction_id']
  if Transaction.exists?(:transaction_id => req['transaction_id'])
    retrieve = Transaction.retrieve_transactions_with_transId(transaction_id)
 
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


get '/retrieve_all_seller_transactions' do
  retrieve_associates = SellerTransaction.retrieve_seller_transactions
  puts retrieve_associates.to_json
  return retrieve_associates.to_json
end



post '/retrieve_seller_transactions' do

  request.body.rewind
  req = JSON.parse request.body.read

  seller_id = req['seller_id']
  if SellerTransaction.exists?(:seller_id => req['seller_id'])
    retrieve = SellerTransaction.retrieve_single_seller_transactions(seller_id)
 
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_join_seller_transactions' do

  request.body.rewind
  req = JSON.parse request.body.read

  buyer_email = req['buyer_email']
  if SellerTransaction.exists?(:buyer_email => req['buyer_email'])
    retrieve = SellerTransaction.retrieve_join_seller_transactions(buyer_email)
 
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/join_seller_transactions' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if SellerTransaction.exists?(:id => req['id'])
    retrieve = SellerTransaction.where(id: id).update(status: "Joined")
 
 
    puts retrieve

    return { 'resp_code'=> "200" }.to_json

  
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_join_buyer_transactions' do

  request.body.rewind
  req = JSON.parse request.body.read

  seller_email = req['seller_email']
  if Transaction.exists?(:seller_email => req['seller_email'])
    retrieve = Transaction.retrieve_join_buyer_transactions(seller_email)
 
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/join_buyer_transactions' do

  request.body.rewind
  req = JSON.parse request.body.read

  transaction_id = req['transaction_id']
  if Transaction.exists?(:transaction_id => req['transaction_id'])
    retrieve = Transaction.where(transaction_id: transaction_id).update(status: "Joined")
    
    creatorEmail = Transaction.where('transaction_id=?',transaction_id).order('id desc')
    mainEMail = Registration.where('id=?',creatorEmail[0].user_id).order('id desc')

    puts "----- EMAIL TO SEND-----" 
      puts "FIRST EMAIL #{creatorEmail[0].person_email}"
   
      sendEmail(creatorEmail[0].person_email)

      sendEmailToCreator(mainEMail[0].email)
 
    puts retrieve

    return { 'resp_code'=> "200" }.to_json
  
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



  


post '/create_associate' do
  request.body.rewind
  req = JSON.parse request.body.read

  firstName = req['firstName']
  middleName = req['middleName']
  lastName = req['lastName']
  ssn = req['ssn']
  birthDate = req['birthDate']
  race = req['race']
  email = req['email']
  mobileEmail = req['mobileEmail']
  schedulingRank = req['schedulingRank']
  classification = req['classification']
  discipline = req['discipline']
  hireDate = req['hireDate']
  startDate = req['startDate']
  supervisor = req['supervisor']
  homeAgency = req['homeAgency']
  associateNumber = req['associateNumber']
  associateNPI = req['associateNPI']
  evvVendorID = req['evvVendorID']
  evvAdminEmail = req['evvAdminEmail']
   gender = req['gender']
  status = req['status']
  url = req['url']
  image = req['image']
  statusReason = req['statusReason']
  statusDate = req['statusDate']
  eligibleForRehire = req['eligibleForRehire']
  organizationUrl = req['organizationUrl']

  puts "DATE OF BIRTH:::: #{birthDate}"
  # puts "birthdayne is #{Date.parse(birthDate).strftime('%Y-%m-%d %I:%M:%S')}"

    if firstName.length < 1 
     halt ERR_FIRST.to_json
   elsif lastName.length< 1
      halt ERR_LAST.to_json
   elsif classification.length< 1
      halt ERR_CLASS.to_json
   elsif hireDate.length< 1
      halt ERR_HIREDATE.to_json
   elsif startDate.length< 1
      halt ERR_STARTDATE.to_json
   # elsif homeAgency.length< 1
   #    halt ERR_AGENCY.to_json
  
   end

   
   p creating_associate(firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl)

   success  =  { resp_code: '000',resp_desc: 'Associate Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_associates' do
  retrieve_associates = Associate.retrieve_associates
  puts retrieve_associates.to_json
  return retrieve_associates.to_json
end

post '/retrieve_single_associates' do

  request.body.rewind
  req = JSON.parse request.body.read

  url = req['url']
  if Associate.exists?(:url => req['url'])
    retrieve = Associate.retrieve_single_associate(url)
    puts "-----------RETRIEVING Associate------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Associate found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_associates_with_org_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if Associate.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = Associate.retrieve_associate_with_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Associate------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Associate found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_associates_with_homeAgency_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  homeAgency = req['homeAgency']
  if Associate.exists?(:homeAgency => req['homeAgency'])
    retrieve = Associate.retrieve_associate_with_homeAgency_url(homeAgency)
    puts "-----------RETRIEVING Associate------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Associate found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/update_associate' do
  puts "------------------UPDATING PROFILE API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   firstName = req['firstName']
  middleName = req['middleName']
  lastName = req['lastName']
  ssn = req['ssn']
  birthDate = req['birthDate']
  race = req['race']
  email = req['email']
  mobileEmail = req['mobileEmail']
  schedulingRank = req['schedulingRank']
  classification = req['classification']
  discipline = req['discipline']
  hireDate = req['hireDate']
  startDate = req['startDate']
  supervisor = req['supervisor']
  homeAgency = req['homeAgency']
  associateNumber = req['associateNumber']
  associateNPI = req['associateNPI']
  evvVendorID = req['evvVendorID']
  evvAdminEmail = req['evvAdminEmail']
  status = req['status']
  url = req['url']
  image = req['image']
  statusReason = req['statusReason']
  statusDate = req['statusDate']
  eligibleForRehire = req['eligibleForRehire']
   gender = req['gender']
   organizationUrl = req['organizationUrl']
    
     if Associate.exists?(:id => req['id'])
    get_update_associate(id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl)

    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated your associate!'}

    regis_success.to_json

                else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end


post '/upload_image' do
  puts "------------------UPDATING PROFILE API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  
  url = req['url']
  image = req['image']

  
   
    upload_img(url,image)

    regis_success = { resp_code: '000',resp_desc: 'Image successfully uploaded!'}

    regis_success.to_json
    
 
end


post '/delete_single_associates' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Associate.exists?(:id => req['id'])

    Associate.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Associate Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Associate found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

#### ASSOCIATES END

### PHYSICIANS START
post '/create_physician' do
  request.body.rewind
  req = JSON.parse request.body.read

  firstName = req['firstName']
  middleName = req['middleName']
  lastName = req['lastName']
  title = req['title']
  speciality = req['speciality']
  email = req['email']
  physicianGroup = req['physicianGroup']
  endDate = req['endDate']
  startDate = req['startDate']
  salesRep = req['salesRep']
  status = req['status']
  url = req['url']
  organizationUrl = req['organizationUrl']
  updated = req['updated']


    if firstName.length < 1 
     halt ERR_FIRST.to_json
   elsif lastName.length< 1
      halt ERR_LAST.to_json
 
   elsif startDate.length< 1
      halt ERR_STARTDATE.to_json
  
   end

   
   p creating_physician(firstName,middleName,lastName,title,speciality,email,physicianGroup,endDate,startDate,status,url,salesRep,organizationUrl,updated)

   success  =  { resp_code: '000',resp_desc: 'Physician Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_physician' do
  retrieve_physician = Physician.retrieve_physician
  puts retrieve_physician.to_json
  return retrieve_physician.to_json
end

post '/retrieve_single_physician' do

  request.body.rewind
  req = JSON.parse request.body.read

  url = req['url']
  if Physician.exists?(:url => req['url'])
    retrieve = Physician.retrieve_single_physician(url)
    puts "-----------RETRIEVING physician------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No physician found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_physician_with_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if Physician.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = Physician.retrieve_physician_with_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING physician------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No physician found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/update_physician' do
  puts "------------------UPDATING physician API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  firstName = req['firstName']
  middleName = req['middleName']
  lastName = req['lastName']
  title = req['title']
  speciality = req['speciality']
  email = req['email']
  physicianGroup = req['physicianGroup']
  endDate = req['endDate']
  startDate = req['startDate']
  status = req['status']
   salesRep = req['salesRep']
  url = req['url']
   organizationUrl = req['organizationUrl']
  updated = req['updated']
    

     if Physician.exists?(:id => req['id'])
   
    get_update_physician(id,firstName,middleName,lastName,title,speciality,email,physicianGroup,endDate,startDate,status,url,salesRep,organizationUrl,updated)

    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated your physician!'}

    regis_success.to_json

                else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_single_physician' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Physician.exists?(:id => req['id'])

    Physician.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Physician Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

### PHYSICIANS END

### FACILITIES START
post '/create_facility' do
  request.body.rewind
  req = JSON.parse request.body.read

  facilityName = req['facilityName']
  facilityType = req['facilityType']
  email = req['email']
  salesRep = req['salesRep']
  endDate = req['endDate']
  startDate = req['startDate']
  status = req['status']
  url = req['url']
  organizationUrl = req['organizationUrl']
  updated = req['updated']
  patientID = req['patientID']
  addressType = req['addressType']
  addressOne = req['addressOne']
  addressTwo = req['addressTwo']
  city = req['city']
  state = req['state']
  zipcode = req['zipcode']
  placeOfService = req['placeOfService']
  phoneType = req['phoneType']
  phone = req['phone']


    if facilityName.length < 1 
     halt ERR_FA_NAME.to_json
 
   elsif startDate.length< 1
      halt ERR_STARTDATE.to_json
  
   end

   
   p creating_facility(facilityName,facilityType,email,salesRep,endDate,startDate,status,url,organizationUrl,updated,
    patientID,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,phoneType,phone)

   success  =  { resp_code: '000',resp_desc: 'Facility Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_facility' do
  retrieve_facility = Facility.retrieve_facilities
  puts retrieve_facility.to_json
  return retrieve_facility.to_json
end

post '/retrieve_single_facility' do

  request.body.rewind
  req = JSON.parse request.body.read

  url = req['url']
  if Facility.exists?(:url => req['url'])
    retrieve = Facility.retrieve_single_facility(url)
    puts "-----------RETRIEVING Facility------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/retrieve_facility_with_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if Facility.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = Facility.retrieve_single_facility_with_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Facility------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/update_facility' do
  puts "------------------UPDATING facility API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  facilityName = req['facilityName']
  facilityType = req['facilityType']
  email = req['email']
  salesRep = req['salesRep']
  endDate = req['endDate']
  startDate = req['startDate']
  status = req['status']
  url = req['url']
  organizationUrl = req['organizationUrl']
  updated = req['updated']
  patientID = req['patientID']
  addressType = req['addressType']
  addressOne = req['addressOne']
  addressTwo = req['addressTwo']
  city = req['city']
  state = req['state']
  zipcode = req['zipcode']
  placeOfService = req['placeOfService']
  phoneType = req['phoneType']
  phone = req['phone']


   if Facility.exists?(:id => req['id'])
   
    get_update_facility(id,facilityName,facilityType,email,salesRep,endDate,startDate,status,url,organizationUrl,updated,
    patientID,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,phoneType,phone)

    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Facility!'}

    regis_success.to_json
                  else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_single_facility' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Facility.exists?(:id => req['id'])

    Facility.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Facility Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

### FACILITIES END



# CREATE TABLE `statusHistory` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `associateUrl` varchar(255) DEFAULT NULL,
#   `changedBy` varchar(255) DEFAULT NULL,
#   `newStatus` varchar(255) DEFAULT NULL,
#   `date` date DEFAULT NULL,
#   `effective` date DEFAULT NULL,
#   `priorStatus` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`)

### STATUS HISTORY START
post '/create_status_history' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  changedBy = req['changedBy']
  newStatus = req['newStatus']
  date = req['date']
  effective = req['effective']
  priorStatus = req['priorStatus']
  priorStatusReason = req['priorStatusReason']
    newStatusReason = req['newStatusReason']
   p creating_status_history(associateUrl,changedBy,newStatus,date,effective,priorStatus,priorStatusReason,newStatusReason)

   success  =  { resp_code: '000',resp_desc: 'Status Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_status' do
  retrieve_status = StatusHistory.retrieve_status
  puts retrieve_status.to_json
  return retrieve_status.to_json
end

post '/retrieve_single_status' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if StatusHistory.exists?(:associateUrl => req['associateUrl'])
    retrieve = StatusHistory.retrieve_single_status(associateUrl)
    puts "-----------RETRIEVING StatusHistory------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No StatusHistory found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/update_status_history' do
  puts "------------------UPDATING update_status_history API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
    associateUrl = req['associateUrl']
  changedBy = req['changedBy']
  newStatus = req['newStatus']
  date = req['date']
  effective = req['effective']
  priorStatus = req['priorStatus']
    priorStatusReason = req['priorStatusReason']
    newStatusReason = req['newStatusReason']
    
     if StatusHistory.exists?(:id => req['id'])
    get_update_status(id,associateUrl,changedBy,newStatus,date,effective,priorStatus,priorStatusReason,newStatusReason)

    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Status!'}

    regis_success.to_json

                 else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_single_status' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if StatusHistory.exists?(:id => req['id'])

    StatusHistory.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Status History Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Status History  found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

### STATUS END



### website_access START
post '/create_website_access' do
  request.body.rewind
  req = JSON.parse request.body.read

  puts "Lets see reqyes coming ---><><>> #{req}" 
  associateUrl = req['associateUrl']
  userName = req['userName']
  password = req['password']
  startDate = req['startDate']
  email = req['email']
  isActive = req['isActive']
  isLockedOut = req['isLockedOut']
  endDate = req['endDate']
  lastLogin = req['lastLogin']
  previousLogin = req['previousLogin']
  passwordExpires = req['passwordExpires']
  created = req['created']
  updated = req['updated']
  roles = req['roles']
  orgUrl  = req['orgUrl']
  regionUrls  = req['regionUrls']
  agencyUrls  = req['agencyUrls']


   p creating_website_access(associateUrl,userName,password,startDate,email,isActive,isLockedOut,endDate,lastLogin,previousLogin,passwordExpires,created,roles,orgUrl,regionUrls,agencyUrls,updated)

   success  =  { resp_code: '000',resp_desc: 'Access Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_web_acess' do
  retrieve_acess = WebAccess.retrieve_access
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_web_access' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if WebAccess.exists?(:associateUrl => req['associateUrl'])
    retrieve = WebAccess.retrieve_single_access(associateUrl)
    puts "-----------RETRIEVING StatusHistory------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No webAccess found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/retrieve_web_access_with_username' do

  request.body.rewind
  req = JSON.parse request.body.read

  userName = req['userName']
  if WebAccess.exists?(:userName => req['userName'])
    retrieve = WebAccess.retrieve_access_with_username(userName)
    puts "-----------RETRIEVING StatusHistory------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No webAccess found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/update_web_access' do
  puts "------------------UPDATING update_status_history API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  associateUrl = req['associateUrl']
  userName = req['userName']
  password = req['password']
  startDate = req['startDate']
  email = req['email']
  isActive = req['isActive']
  isLockedOut = req['isLockedOut']
  endDate = req['endDate']
  lastLogin = req['lastLogin']
  previousLogin = req['previousLogin']
  passwordExpires = req['passwordExpires']
  created = req['created']
   updated = req['updated']
  roles = req['roles']
   orgUrl  = req['orgUrl']
  regionUrls  = req['regionUrls']
  agencyUrls  = req['agencyUrls']
  

    if WebAccess.exists?(:id => req['id'])
    get_update_web_access(id,associateUrl,userName,password,startDate,email,isActive,isLockedOut,endDate,lastLogin,previousLogin,passwordExpires,created,roles,orgUrl,regionUrls,agencyUrls,updated)

    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Web Access!'}

    regis_success.to_json


                 else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_single_access' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if WebAccess.exists?(:id => req['id'])

    WebAccess.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Web Access Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Web Access found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

### website_access END


### ORGANIZATIONS START
post '/create_organization' do
  request.body.rewind
  req = JSON.parse request.body.read

  url = req['url']
  organizationName = req['organizationName']
  organizationCode = req['organizationCode']
  email = req['email']
  primaryContact = req['primaryContact']
  phoneType = req['phoneType']
  phone = req['phone']
  companyStartDate = req['companyStartDate']
  companyEndDate = req['companyEndDate']
 
 
   p creating_organization(url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate)

   success  =  { resp_code: '000',resp_desc: 'Organization Successfully created'} 
   return success.to_json 
     
end




get '/retrieve_all_organizations' do
  retrieve_acess = Organization.retrieve_organizations
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_organization' do

  request.body.rewind
  req = JSON.parse request.body.read

  url = req['url']
  if Organization.exists?(:url => req['url'])
    retrieve = Organization.retrieve_single_organization(url)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Organization found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_single_organization_with_organizationCode' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationCode = req['organizationCode']
  if Organization.exists?(:organizationCode => req['organizationCode'])
    retrieve = Organization.retrieve_single_organization_with_organizationCode(organizationCode)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Organization found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_organization' do
  puts "------------------UPDATING update_status_history API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  url = req['url']
  organizationName = req['organizationName']
  organizationCode = req['organizationCode']
  email = req['email']
  primaryContact = req['primaryContact']
  phoneType = req['phoneType']
  phone = req['phone']
  companyStartDate = req['companyStartDate']
  companyEndDate = req['companyEndDate']


   if Organization.exists?(:id => req['id'])
   
   get_update_organization(id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate)

    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated organization!'}

    regis_success.to_json


                 else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_organization' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Organization.exists?(:id => req['id'])

    Organization.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Organization Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Organization found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

### ORGANIZATIONS END

# CREATE TABLE `associate_notes` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `associateUrl` varchar(255) DEFAULT NULL,
#   `noteBy` varchar(255) DEFAULT NULL,
#   `type` varchar(255) DEFAULT NULL,
#   `document` varchar(255) DEFAULT NULL,
#   `note` varchar(255) DEFAULT NULL,
#   `active` tinyint(1) DEFAULT NULL,
#   `date` date DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`)

### ASSOCIATE NOTE START
post '/create_associate_notes' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  noteBy = req['noteBy']
  noteType = req['noteType']
  document = req['document']
  note = req['note']
  active = req['active']
  date = req['date']
  

   p creating_associate_notes(associateUrl,noteBy,noteType,document,note,active,date)

   success  =  { resp_code: '000',resp_desc: 'Notes Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_associate_notes' do
  retrieve_acess = AssociateNote.retrieve_associate_notes
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_associate_note' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if AssociateNote.exists?(:associateUrl => req['associateUrl'])
    retrieve = AssociateNote.retrieve_single_associate_notes(associateUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Notes found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_associate_note' do
  puts "------------------UPDATING update_status_history API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  associateUrl = req['associateUrl']
  noteBy = req['noteBy']
  noteType = req['noteType']
  document = req['document']
  note = req['note']
  active = req['active']
  date = req['date']
    
      if AssociateNote.exists?(:id => req['id'])
   get_update_associate_notes(id,associateUrl,noteBy,noteType,document,note,active,date)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated notes!'}

    regis_success.to_json

                     else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_associate_note' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssociateNote.exists?(:id => req['id'])

    AssociateNote.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'AssociateNote Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No AssociateNote found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

### ASSOCIATE NOTE END



### ancillaryPhoneInfo NOTE START
post '/create_ancillaryPhoneInfo' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  phoneType = req['phoneType']
  phone = req['phone']
  description = req['description']
  


  if phoneType.length < 1 
     halt PHONE_TYPE_ERR.to_json
   elsif phone.length< 1
      halt PHONE_ERR.to_json
  
   end
  

   p creating_ancillaryPhoneInfo(associateUrl,phoneType,phone,description)

   success  =  { resp_code: '000',resp_desc: 'ancillaryPhoneInfo Successfully created'} 
   return success.to_json 
     
end





get '/retrieve_all_ancillaryPhoneInfos' do
  retrieve_acess = AncillaryPhoneInfo.retrieve_ancillaryPhoneInfo
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_ancillaryPhoneInfo' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if AncillaryPhoneInfo.exists?(:associateUrl => req['associateUrl'])
    retrieve = AncillaryPhoneInfo.retrieve_single_ancillaryPhoneInfo(associateUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No ancillaryPhoneInfos found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_ancillaryPhoneInfo' do
  puts "------------------UPDATING update_status_history API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  associateUrl = req['associateUrl']
  phoneType = req['phoneType']
  phone = req['phone']
  description = req['description']
    
     if AncillaryPhoneInfo.exists?(:id => req['id'])
    get_update_ancillaryPhoneInfo(id,associateUrl,phoneType,phone,description)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated ancillaryPhoneInfos!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_ancillaryPhoneInfos' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AncillaryPhoneInfo.exists?(:id => req['id'])

    AncillaryPhoneInfo.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'AncillaryPhoneInfo Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No AncillaryPhoneInfo found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


### ancillaryPhoneInfo END




  #   CREATE TABLE `addressPhoneInfo` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `associateUrl` varchar(255) DEFAULT NULL,
  # `addressType` varchar(255) DEFAULT NULL,
  # `address1` varchar(255) DEFAULT NULL,
  # `address2` varchar(255) DEFAULT NULL,
  # `city` varchar(255) DEFAULT NULL,
  # `state` varchar(255) DEFAULT NULL,
  # `zip` varchar(255) DEFAULT NULL,
  # `phoneType` varchar(255) DEFAULT NULL,
  # `phone` varchar(255) DEFAULT NULL,
  # `preferred` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)



### AddressPhoneInfo  START
post '/create_addressPhoneInfo' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']
  


  if addressType.length < 1 
     halt ADD_TYPE_ERR.to_json
   elsif address1.length< 1
      halt ADDRESS_ERR.to_json
       elsif city.length< 1
      halt CITY_ERR.to_json
       elsif state.length< 1
      halt STATE_ERR.to_json
       elsif zip.length< 1
      halt ZIP_ERR.to_json
  
   end
  

   p creating_addressPhoneInfo(associateUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)

   success  =  { resp_code: '000',resp_desc: 'addressPhoneInfo Successfully created'} 
   return success.to_json 
     
end




get '/retrieve_all_addressPhoneInfos' do
  retrieve_acess = AddressPhoneInfo.retrieve_addressPhoneInfo
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_addressPhoneInfo' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if AddressPhoneInfo.exists?(:associateUrl => req['associateUrl'])
    retrieve = AddressPhoneInfo.retrieve_single_addressPhoneInfo(associateUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No addressPhoneInfos found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_addressPhoneInfo' do
  puts "------------------UPDATING update_status_history API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   associateUrl = req['associateUrl']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
 addressPhoneInfoPhones = req['addressPhoneInfoPhones']
    

     if AddressPhoneInfo.exists?(:id => req['id'])
    get_update_addressPhoneInfo(id,associateUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated addressPhoneInfos!'}

    regis_success.to_json

                       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_addressPhoneInfos' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AddressPhoneInfo.exists?(:id => req['id'])

    AddressPhoneInfo.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'addressPhoneInfos Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No addressPhoneInfos found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

### AddressPhoneInfo  END



  #   CREATE TABLE `emergencyContacts` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `associateUrl` varchar(255) DEFAULT NULL,
  # `relationship` varchar(255) DEFAULT NULL,
  # `firstName` varchar(255) DEFAULT NULL,
  # `lastName` varchar(255) DEFAULT NULL,
  # `priority` varchar(255) DEFAULT NULL,
  # `addressType` varchar(255) DEFAULT NULL,
  # `address1` varchar(255) DEFAULT NULL,
  # `address2` varchar(255) DEFAULT NULL,
  # `city` varchar(255) DEFAULT NULL,
  # `state` varchar(255) DEFAULT NULL,
  # `zip` varchar(255) DEFAULT NULL,
  # `phoneType` varchar(255) DEFAULT NULL,
  # `phone` varchar(255) DEFAULT NULL,
  # `preferred` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)



### AddressPhoneInfo  START
post '/create_emergencyContacts' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  relationship = req['relationship']
  firstName = req['firstName']
  lastName = req['lastName']
  priority = req['priority']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']

 

  if addressType.length < 1 
     halt ADD_TYPE_ERR.to_json
   elsif address1.length< 1
      halt ADDRESS_ERR.to_json
       elsif city.length< 1
      halt CITY_ERR.to_json
       elsif state.length< 1
      halt STATE_ERR.to_json
       elsif zip.length< 1
      halt ZIP_ERR.to_json
     elsif firstName.length < 1 
     halt ERR_FIRST.to_json
   elsif lastName.length< 1
      halt ERR_LAST.to_json
        elsif relationship.length< 1
      halt RELA_ERR.to_json
  
   end
  

   p creating_emergencyContacts(associateUrl,relationship,firstName,lastName,priority,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)

   success  =  { resp_code: '000',resp_desc: 'emergencyContacts Successfully created'} 
   return success.to_json 
     
end




get '/retrieve_all_emergencyContacts' do
  retrieve_acess = EmergencyContact.retrieve_emergencyContacts
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_emergencyContact' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if EmergencyContact.exists?(:associateUrl => req['associateUrl'])
    retrieve = EmergencyContact.retrieve_single_emergencyContact(associateUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No EmergencyContact found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_emergencyContacts' do
  puts "------------------UPDATING emergencyContacts API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  associateUrl = req['associateUrl']
  relationship = req['relationship']
  firstName = req['firstName']
  lastName = req['lastName']
  priority = req['priority']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']
    

      if EmergencyContact.exists?(:id => req['id'])
    get_update_emergencyContacts(id,associateUrl,relationship,firstName,lastName,priority,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated EmergencyContact!'}

    regis_success.to_json

                        else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_emergencyContacts' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if EmergencyContact.exists?(:id => req['id'])

    EmergencyContact.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'EmergencyContact Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No EmergencyContact found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





  #         CREATE TABLE `documents` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `associateUrl` varchar(255) DEFAULT NULL,
  # `file` varchar(255) DEFAULT NULL,
  # `documentType` varchar(255) DEFAULT NULL,
  # `documentStatus` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `note` varchar(255) DEFAULT NULL,
  # `uploadedBy` varchar(255) DEFAULT NULL,
  # `uploadedDate` date DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)



### DOCUMENTS  START
post '/create_documents' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  file = req['file']
  documentType = req['documentType']
  documentStatus = req['documentStatus']
  description = req['description']
  note = req['note']
  uploadedBy = req['uploadedBy']
  uploadedDate = req['uploadedDate']
 

   p creating_documents(associateUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
   success  =  { resp_code: '000',resp_desc: 'Documents Successfully created'} 
   return success.to_json 
     
end


get '/retrieve_all_documents' do
  retrieve_acess = Document.retrieve_documents
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_documents' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if Document.exists?(:id => req['id'])
    retrieve = Document.retrieve_single_document(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Documents found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/retrieve_documents_with_associateUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if Document.exists?(:associateUrl => req['associateUrl'])
    retrieve = Document.retrieve_single_document_with_associateUrl(associateUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Documents found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_documents' do
  puts "------------------UPDATING documents API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

    id = req['id']
  associateUrl = req['associateUrl']
  file = req['file']
  documentType = req['documentType']
  documentStatus = req['documentStatus']
  description = req['description']
  note = req['note']
  uploadedBy = req['uploadedBy']
  uploadedDate = req['uploadedDate']

    if Document.exists?(:id => req['id'])
   
   get_update_documents(id,associateUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Documents!'}

    regis_success.to_json


                        else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_documents' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Document.exists?(:id => req['id'])

    Document.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Document Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Document found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





  #         CREATE TABLE `associate_availabilities` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `date` date DEFAULT NULL,
  # `day` varchar(255) DEFAULT NULL,
  # `start` varchar(255) DEFAULT NULL,
  # `end` varchar(255) DEFAULT NULL,
  # `availability_type` varchar(255) DEFAULT NULL,
  # `reason` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)



### create_associate_availability  START
post '/create_associate_availability' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  date = req['date']
  day = req['day']
  start = req['start']
  end_time = req['end']
  availability_type = req['availability_type']
  reason = req['reason']
 

   p creating_associate_availability(associateUrl,date,day,start,end_time,availability_type,reason)
   success  =  { resp_code: '000',resp_desc: 'Availability Successfully created'} 
   return success.to_json 
     
end




get '/retrieve_all_associate_availability' do
  retrieve_acess = AssociateAvailability.retrieve_associate_availabilities
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_associate_availability' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if AssociateAvailability.exists?(:associateUrl => req['associateUrl'])
    retrieve = AssociateAvailability.retrieve_single_associate_availability(associateUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Availability found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_associate_availability' do
  puts "------------------UPDATING documents API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  associateUrl = req['associateUrl']
  date = req['date']
  day = req['day']
  start = req['start']
  end_time = req['end']
  availability_type = req['availability_type']
  reason = req['reason']
    
      if AssociateAvailability.exists?(:id => req['id'])
  get_update_associate_availability(id,associateUrl,date,day,start,end_time,availability_type,reason)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Availability!'}

    regis_success.to_json

                            else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_associate_availability' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssociateAvailability.exists?(:id => req['id'])

    AssociateAvailability.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Availability Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Availability found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end







  #         CREATE TABLE `payroll` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `associateUrl` date DEFAULT NULL,
  # `salary` float DEFAULT NULL,
  # `payrollType` varchar(255) DEFAULT NULL,
  # `federalFillingStatus` varchar(255) DEFAULT NULL,
  # `stateFillingStatus` varchar(255) DEFAULT NULL,
  # `stateDeductions` float DEFAULT NULL,
  # `startDate` date DEFAULT NULL,
  # `wbCheck` tinyint DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)



### create_associate_availability  START
post '/create_payroll' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  salary = req['salary']
  payrollType = req['payrollType']
  federalFillingStatus = req['federalFillingStatus']
  stateFillingStatus = req['stateFillingStatus']
  stateDeductions = req['stateDeductions']
  startDate = req['startDate']
  wbCheck = req['wbCheck']



  if associateUrl.length < 1 
     halt ASS_URL_ERR.to_json
   elsif payrollType.length< 1
      halt P_TYPE_ERR.to_json
       elsif federalFillingStatus.length< 1
      halt FED_FIL_ERR.to_json
       elsif stateFillingStatus.length< 1
      halt STATE_FIL_ERR.to_json
       elsif stateDeductions.length< 1
      halt STATE_D_ERR.to_json
     elsif startDate.length < 1 
     halt DDT_ERR.to_json
   elsif payrollType == "Salary"
      if salary.length < 1
      halt SAL_ERR.to_json
    end
  
   end
 

   p creating_payroll(associateUrl,salary,payrollType,federalFillingStatus,stateFillingStatus,stateDeductions,startDate,wbCheck)
   success  =  { resp_code: '000',resp_desc: 'Payroll Successfully created'} 
   return success.to_json 
     
end


get '/retrieve_all_payroll' do
  retrieve_acess = Payroll.retrieve_payroll
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payroll' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if Payroll.exists?(:associateUrl => req['associateUrl'])
    retrieve = Payroll.retrieve_single_payroll(associateUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payroll found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_payroll' do
  puts "------------------UPDATING documents API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  associateUrl = req['associateUrl']
  salary = req['salary']
  payrollType = req['payrollType']
  federalFillingStatus = req['federalFillingStatus']
  stateFillingStatus = req['stateFillingStatus']
  stateDeductions = req['stateDeductions']
  startDate = req['startDate']
  wbCheck = req['wbCheck']
    
     if Payroll.exists?(:id => req['id'])
 get_update_payroll(id,associateUrl,salary,payrollType,federalFillingStatus,stateFillingStatus,stateDeductions,startDate,wbCheck)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Payroll!'}

    regis_success.to_json

                             else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payroll' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Payroll.exists?(:id => req['id'])

    Payroll.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Payroll Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payroll found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





  #  CREATE TABLE `agencies` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `url` varchar(255) DEFAULT NULL,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `regionUrl` varchar(255) DEFAULT NULL,
  # `agencyName` varchar(255) DEFAULT NULL,
  # `agencyType` varchar(255) DEFAULT NULL,
  # `payrollCutoff` varchar(255) DEFAULT NULL,
  # `procActionDate` varchar(255) DEFAULT NULL,
  # `nameOnInvoice` varchar(255) DEFAULT NULL,
  # `agencyCode` varchar(255) DEFAULT NULL,
  # `email` varchar(255) DEFAULT NULL,
  # `primaryContact` varchar(255) DEFAULT NULL,
  # `startDate`varchar(255) DEFAULT NULL,
  # `endDate`varchar(255) DEFAULT NULL,
  # `externalFacilityID`varchar(255) DEFAULT NULL,
  # `agencyReportID`varchar(255) DEFAULT NULL,
  # `updated`varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)



### AGENCIES  START
post '/create_agency' do
  request.body.rewind
  req = JSON.parse request.body.read

  url = req['url']
  organizationUrl = req['organizationUrl']
  regionUrl = req['regionUrl']
  agencyName = req['agencyName']
  agencyType = req['agencyType']
  payrollCutoff = req['payrollCutoff']
  procActionDate = req['procActionDate']
  nameOnInvoice = req['nameOnInvoice']
  agencyCode = req['agencyCode']
  email = req['email']
  primaryContact = req['primaryContact']
  startDate = req['startDate']
  endDate = req['endDate']
  externalFacilityID = req['externalFacilityID']
  agencyReportID = req['agencyReportID']
  updated = req['updated']



  if regionUrl.length < 1 
     halt REG_ERR.to_json
   elsif agencyName.length< 1
      halt AGENCY_ERR.to_json
       elsif email.length< 1
      halt EMAIL_ERR.to_json
       elsif startDate.length< 1
      halt DDT_ERR.to_json
  
   end
 

   p creating_agency(url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated)
   success  =  { resp_code: '000',resp_desc: 'Agency Successfully created'} 
   return success.to_json 
     
end




get '/retrieve_all_agencies' do
  retrieve_acess = Agency.retrieve_agencies
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_agency' do

  request.body.rewind
  req = JSON.parse request.body.read

  url = req['url']
  if Agency.exists?(:url => req['url'])
    retrieve = Agency.retrieve_single_agency(url)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Agency found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/retrieve_agency_with_regionUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  regionUrl = req['regionUrl']
  if Agency.exists?(:regionUrl => req['regionUrl'])
    retrieve = Agency.retrieve_single_agency_with_regionUrl(regionUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Agency found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/retrieve_agency_with_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if Agency.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = Agency.retrieve_single_agency_with_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Agency found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_agency' do
  puts "------------------UPDATING agency API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  url = req['url']
  organizationUrl = req['organizationUrl']
  regionUrl = req['regionUrl']
  agencyName = req['agencyName']
  agencyType = req['agencyType']
  payrollCutoff = req['payrollCutoff']
  procActionDate = req['procActionDate']
  nameOnInvoice = req['nameOnInvoice']
  agencyCode = req['agencyCode']
  email = req['email']
  primaryContact = req['primaryContact']
  startDate = req['startDate']
  endDate = req['endDate']
  externalFacilityID = req['externalFacilityID']
  agencyReportID = req['agencyReportID']
  updated = req['updated']
    

      if Agency.exists?(:id => req['id']) 
 get_update_agency(id,url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated)
 
     regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Agency!'}

    regis_success.to_json

                             else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_agency' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Agency.exists?(:id => req['id'])

    Agency.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Agency Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Agency found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





  #  CREATE TABLE `regions` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `url` varchar(255) DEFAULT NULL,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `regionName` varchar(255) DEFAULT NULL,
  # `regionCode` varchar(255) DEFAULT NULL,
  # `email` varchar(255) DEFAULT NULL,
  # `primaryContact` varchar(255) DEFAULT NULL,
  # `startDate`varchar(255) DEFAULT NULL,
  # `endDate`varchar(255) DEFAULT NULL,
  # `updated`varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)



### AGENCIES  START
post '/create_region' do
  request.body.rewind
  req = JSON.parse request.body.read

  url = req['url']
  organizationUrl = req['organizationUrl']
  regionName = req['regionName']
  regionCode = req['regionCode']
  email = req['email']
  primaryContact = req['primaryContact']
  startDate = req['startDate']
  endDate = req['endDate']
  updated = req['updated']



  if organizationUrl.length < 1 
     halt ORG_ERR.to_json
   elsif regionName.length< 1
      halt REG_NMA_ERR.to_json
       elsif email.length< 1
      halt EMAIL_ERR.to_json
       elsif startDate.length< 1
      halt DDT_ERR.to_json
  
   end
 

   p creating_region(url,organizationUrl,regionName,regionCode,email,primaryContact,startDate,endDate,updated)
   success  =  { resp_code: '000',resp_desc: 'Region Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_regions' do
  retrieve_acess = Region.retrieve_regions
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_region' do

  request.body.rewind
  req = JSON.parse request.body.read

  url = req['url']
  if Region.exists?(:url => req['url'])
    retrieve = Region.retrieve_single_region(url)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Region found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_region_with_org_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if Region.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = Region.retrieve_single_region_with_org(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Region found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/update_region' do
  puts "------------------UPDATING agency API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

    id = req['id']
  url = req['url']
  organizationUrl = req['organizationUrl']
  regionName = req['regionName']
  regionCode = req['regionCode']
  email = req['email']
  primaryContact = req['primaryContact']
  startDate = req['startDate']
  endDate = req['endDate']
  updated = req['updated']
    

    if Region.exists?(:id => req['id'])
 get_update_region(id,url,organizationUrl,regionName,regionCode,email,primaryContact,startDate,endDate,updated)
     regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Region!'}

    regis_success.to_json

                             else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_region' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Region.exists?(:id => req['id'])

    Region.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Region Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Region found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



### AGENCIES  START
post '/create_deductions' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  deduction = req['deduction']
  amount = req['amount']
  startDate = req['startDate']
  endDate = req['endDate']


  if associateUrl.length < 1 
     halt ASS_URL_ERR.to_json
   elsif deduction.length< 1
      halt DDC_ERR.to_json
       elsif amount.length< 1
      halt AMT_ERR.to_json
       elsif startDate.length< 1
      halt DDT_ERR.to_json
  
   end
 

   p creating_deductions(associateUrl,deduction,amount,startDate,endDate)
   success  =  { resp_code: '000',resp_desc: 'Deductions Successfully Created'} 
   return success.to_json 
     
end


get '/retrieve_all_deductions' do
  retrieve_acess = Deduction.retrieve_deductions
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_deduction' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if Deduction.exists?(:id => req['id'])
    retrieve = Deduction.retrieve_single_deduction(id)
    puts "-----------RETRIEVING Deduction------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Deduction found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_deduction_with_associateUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if Deduction.exists?(:associateUrl => req['associateUrl'])
    retrieve = Deduction.retrieve_single_deduction_with_associateUrl(associateUrl)
    puts "-----------RETRIEVING Deduction------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Deduction found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_deduction' do
  puts "------------------UPDATING agency API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
 associateUrl = req['associateUrl']
  deduction = req['deduction']
  amount = req['amount']
  startDate = req['startDate']
  endDate = req['endDate']

  if Deduction.exists?(:id => req['id'])
   
  get_update_deduction(id,associateUrl,deduction,amount,startDate,endDate)
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Deduction!'}

    regis_success.to_json

      else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_deduction' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Deduction.exists?(:id => req['id'])

    Deduction.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Deduction Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Deduction found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





  #  CREATE TABLE `payrates` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `associateUrl` varchar(255) DEFAULT NULL,
  # `payType` varchar(255) DEFAULT NULL,
  # `serviceDescription` varchar(255) DEFAULT NULL,
  # `weekdayRate` varchar(255) DEFAULT NULL,
  # `weekendRate` varchar(255) DEFAULT NULL,
  # `allowOverride` tinyint(1) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


  ### PAYRATES  START
post '/create_payrates' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  payType = req['payType']
  serviceDescription = req['serviceDescription']
  weekdayRate =  req['weekdayRate']
  weekendRate =  req['weekendRate']
  allowOverride =  req['allowOverride']
  startDate = req['startDate']



  if associateUrl.length < 1 
     halt ASS_URL_ERR.to_json
   elsif payType.length< 1
      halt PAY_TYPE_ERR.to_json
       elsif serviceDescription.length< 1
      halt SERV_ERR.to_json
       elsif weekdayRate.length< 1
      halt WR_ERR.to_json
       elsif weekendRate.length< 1
      halt WNR_ERR.to_json
       elsif startDate.length< 1
      halt DDT_ERR.to_json
  
   end
 

   p creating_payrates(associateUrl,payType,serviceDescription,weekdayRate,weekendRate,allowOverride,startDate)
   success  =  { resp_code: '000',resp_desc: 'Payrates Successfully Created'} 
   return success.to_json 
     
end




get '/retrieve_all_payrates' do
  retrieve_acess = Payrate.retrieve_payrates
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payrate' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if Payrate.exists?(:id => req['id'])
    retrieve = Payrate.retrieve_single_payrate(id)
    puts "-----------RETRIEVING Deduction------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payrate found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_payrate_with_ass_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if Payrate.exists?(:associateUrl => req['associateUrl'])
    retrieve = Payrate.retrieve_single_payrate_with_ass_url(associateUrl)
    puts "-----------RETRIEVING Deduction------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payrate found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_payrate' do
  puts "------------------UPDATING payrate API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
 associateUrl = req['associateUrl']
  payType = req['payType']
  serviceDescription = req['serviceDescription']
  weekdayRate =  req['weekdayRate']
  weekendRate =  req['weekendRate']
  allowOverride =  req['allowOverride']
  startDate = req['startDate']

   if Payrate.exists?(:id => req['id'])
   
 get_update_payrates(id,associateUrl,payType,serviceDescription,weekdayRate,weekendRate,allowOverride,startDate)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Payrate!'}

    regis_success.to_json

       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payrate' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Payrate.exists?(:id => req['id'])

    Payrate.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Payrate Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payrate found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



# const newLicense = {
#       associateUrl, --> foreign key of the associate
#       licenseType, --> string
#       licenseNumber, --> number
#       licenseState, --> string
#       issueDate, --> date
#       expirationDate,  --> date
#       licenseStatus, --> string
#     };
  #  CREATE TABLE `licenses` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `associateUrl` varchar(255) DEFAULT NULL,
  # `licenseType` varchar(255) DEFAULT NULL,
  # `licenseNumber` varchar(255) DEFAULT NULL,
  # `licenseState` varchar(255) DEFAULT NULL,
  # `issueDate` varchar(255) DEFAULT NULL,
  # `licenseStatus` varchar(255) DEFAULT NULL,
  # `expirationDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


  ### create_licenses  START
post '/create_licenses' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  licenseType = req['licenseType']
  licenseNumber = req['licenseNumber']
  licenseState =  req['licenseState']
  issueDate =  req['issueDate']
  licenseStatus =  req['licenseStatus']
  expirationDate = req['expirationDate']



  if associateUrl.length < 1 
     halt ASS_URL_ERR.to_json
   elsif licenseType.length< 1
     halt LIC_TYPE_ERR.to_json
   elsif licenseNumber.length< 1
     halt LIC_NUM_ERR.to_json
   elsif licenseState.length< 1
     halt LIC_STAT_ERR.to_json
   elsif issueDate.length< 1
      halt ISSUE_ERR.to_json
   elsif licenseStatus.length< 1
      halt LIC_SS_ERR.to_json
   elsif expirationDate.length< 1
      halt EX_DATE_ERR.to_json
  
   end
 

   p creating_license(associateUrl,licenseType,licenseNumber,licenseState,issueDate,licenseStatus,expirationDate)
   success  =  { resp_code: '000',resp_desc: 'License Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_licenses' do
  retrieve_acess = License.retrieve_licenses
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_license' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if License.exists?(:id => req['id'])
    retrieve = License.retrieve_single_license(id)
    puts "-----------RETRIEVING License------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No License found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/retrieve_license_with_associateUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if License.exists?(:associateUrl => req['associateUrl'])
    retrieve = License.retrieve_single_license_with_assUrl(associateUrl)
    puts "-----------RETRIEVING License------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No License found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_license' do
  puts "------------------UPDATING payrate API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  associateUrl = req['associateUrl']
  licenseType = req['licenseType']
  licenseNumber = req['licenseNumber']
  licenseState =  req['licenseState']
  issueDate =  req['issueDate']
  licenseStatus =  req['licenseStatus']
  expirationDate = req['expirationDate']

   if License.exists?(:id => req['id'])
   
get_update_license(id,associateUrl,licenseType,licenseNumber,licenseState,issueDate,licenseStatus,expirationDate)
 
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated License!'}

    regis_success.to_json

          else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_license' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if License.exists?(:id => req['id'])

    License.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'License Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No License found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




  ### skills  START
post '/create_skills' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  skills = req['skills']
 
 

   p creating_skills(associateUrl,skills)
   success  =  { resp_code: '000',resp_desc: 'skills Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_skills' do
  retrieve_acess = Skill.retrieve_skills
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_skill' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if Skill.exists?(:id => req['id'])
    retrieve = Skill.retrieve_single_skills(id)
    puts "-----------RETRIEVING Skill------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Skill found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_skill_with_AssociateUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if Skill.exists?(:associateUrl => req['associateUrl'])
    retrieve = Skill.retrieve_single_skills_withAssUrl(associateUrl)
    puts "-----------RETRIEVING Skill------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Skill found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_skill' do
  puts "------------------UPDATING Skill API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  associateUrl = req['associateUrl']
  skills = req['skills']
  
    if Skill.exists?(:id => req['id'])
  get_update_skills(id,associateUrl,skills)
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Skill!'}

    regis_success.to_json

              else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_skill' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Skill.exists?(:id => req['id'])

    Skill.where(id: id).destroy_all
    puts "-----------DELETING Skill------------------"
    del = [{resp_code: '000', resp_desc: 'Skill Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Skill found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




  #  CREATE TABLE `compliances` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `associateUrl` varchar(255) DEFAULT NULL,
  # `item` varchar(255) DEFAULT NULL,
  # `complianceType` varchar(255) DEFAULT NULL,
  # `lastModifiedBy` varchar(255) DEFAULT NULL,
  # `lastModifiedByDate` varchar(255) DEFAULT NULL,
  # `result` varchar(255) DEFAULT NULL,
  # `completed` varchar(255) DEFAULT NULL,
  # `renewal` varchar(255) DEFAULT NULL,
  # `compliant` tinyint(1) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


    ### create_compliance  START
post '/create_compliance' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  item = req['item']
  complianceType = req['complianceType']
  lastModifiedBy = req['lastModifiedBy']
  lastModifiedByDate = req['lastModifiedByDate']
  result = req['result']
  completed = req['completed']
  renewal = req['renewal']
  compliant = req['compliant']
  notNeeded =  req['notNeeded']
  comment =  req['comment']
   narrative =  req['narrative']
  
 

   p creating_compliance(associateUrl,item,complianceType,lastModifiedBy,lastModifiedByDate,result,completed,renewal,compliant,notNeeded,comment,narrative)
   success  =  { resp_code: '000',resp_desc: 'Compliance Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_compliance' do
  retrieve_acess = Compliance.retrieve_compliances
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_compliance' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if Compliance.exists?(:id => req['id'])
    retrieve = Compliance.retrieve_single_compliances(id)
    puts "-----------RETRIEVING Compliance------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Compliance found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/retrieve_compliance_with_Ass_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if Compliance.exists?(:associateUrl => req['associateUrl'])
    retrieve = Compliance.retrieve_single_compliances_with_associateUrl(associateUrl)
    puts "-----------RETRIEVING Compliance------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Compliance found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_compliance' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  associateUrl = req['associateUrl']
  item = req['item']
  complianceType = req['complianceType']
  lastModifiedBy = req['lastModifiedBy']
  lastModifiedByDate = req['lastModifiedByDate']
  result = req['result']
  completed = req['completed']
  renewal = req['renewal']
  compliant = req['compliant']
   notNeeded =  req['notNeeded']
   comment =  req['comment']
   narrative =  req['narrative']
    
      if Compliance.exists?(:id => req['id'])
  get_update_compliance(id,associateUrl,item,complianceType,lastModifiedBy,lastModifiedByDate,result,completed,renewal,compliant,notNeeded,comment,narrative)
 
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Compliance!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_compliance' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Compliance.exists?(:id => req['id'])

    Compliance.where(id: id).destroy_all
    puts "-----------DELETING Compliance------------------"
    del = [{resp_code: '000', resp_desc: 'Compliance Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Compliance found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




  #  CREATE TABLE `physician_address` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `physicianUrl` varchar(255) DEFAULT NULL,
  # `addressType` varchar(255) DEFAULT NULL,
  # `address1` varchar(255) DEFAULT NULL,
  # `address2` varchar(255) DEFAULT NULL,
  # `city` varchar(255) DEFAULT NULL,
  # `state` varchar(255) DEFAULT NULL,
  # `zip` varchar(255) DEFAULT NULL,
  # `addressPhoneInfoPhones` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


    ### PHYSICIAN ADDRESSS URL  START
post '/create_physician_address' do
  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']



    if physicianUrl.length < 1 
     halt PHY_URL_ERR.to_json
   elsif addressType.length< 1
     halt ADD_TYPE_ERR.to_json
   elsif address1.length< 1
     halt ADDRESS_ERR.to_json
   elsif city.length< 1
     halt CITY_ERR.to_json
   elsif state.length< 1
      halt STATE_ERR.to_json
   elsif zip.length< 1
      halt ZIP_ERR.to_json
 
   end
  

   p creating_physician_address(physicianUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
   success  =  { resp_code: '000',resp_desc: 'PHYSICIAN ADDRESSS Successfully Created'} 
   return success.to_json 
     
end





get '/retrieve_all_physician_address' do
  retrieve_acess = PhysicianAddress.retrieve_physician_address
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_physician_address' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PhysicianAddress.exists?(:id => req['id'])
    retrieve = PhysicianAddress.retrieve_single_physician_address(id)
    puts "-----------RETRIEVING PhysicianAddress------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Address found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_single_physician_address_with_physicial_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  if PhysicianAddress.exists?(:physicianUrl => req['physicianUrl'])
    retrieve = PhysicianAddress.retrieve_single_physician_address_with_physicianUrl(physicianUrl)
    puts "-----------RETRIEVING PhysicianAddress------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Address found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_physician_address' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  physicianUrl = req['physicianUrl']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']
    
      if PhysicianAddress.exists?(:id => req['id'])
    get_update_physician_address(id,physicianUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Physician Address!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_physician_address' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PhysicianAddress.exists?(:id => req['id'])

    PhysicianAddress.where(id: id).destroy_all
    puts "-----------DELETING PhysicianAddress------------------"
    del = [{resp_code: '000', resp_desc: 'Physician Address Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Address found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





  #  CREATE TABLE `physician_referral_source_contacts` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `physicianUrl` varchar(255) DEFAULT NULL,
  # `firstName` varchar(255) DEFAULT NULL,
  # `middleName` varchar(255) DEFAULT NULL,
  # `lastName` varchar(255) DEFAULT NULL,
  # `phone1` varchar(255) DEFAULT NULL,
  # `phone2` varchar(255) DEFAULT NULL,
  # `information` varchar(255) DEFAULT NULL,
  # `email` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `updatedBy` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


    ### physician_referral_source_contacts URL  START
post '/create_physician_referral_source_contacts' do
  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  firstName = req['firstName']
  middleName = req['middleName']
  lastName = req['lastName']
  phone1 = req['phone1']
  phone2 = req['phone2']
  information = req['information']
  email = req['email']
  startDate = req['startDate']
  updatedBy = req['updatedBy']



    if firstName.length < 1 
     halt ERR_FIRST.to_json
   elsif lastName.length< 1
     halt ERR_LAST.to_json
   elsif startDate.length< 1
     halt DDT_ERR.to_json
 
   end
  

   p creating_physician_referral_source_contacts(physicianUrl,firstName,middleName,lastName,phone1,phone2,information,email,startDate,updatedBy)
   success  =  { resp_code: '000',resp_desc: 'Physician Referral Source Contacts Successfully Created'} 
   return success.to_json 
     
end




get '/retrieve_all_physician_referral_source' do
  retrieve_acess = PhysicianReferralSourceContacts.retrieve_physician_referral_source_contacts
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_physician_referral_source' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PhysicianReferralSourceContacts.exists?(:id => req['id'])
    retrieve = PhysicianReferralSourceContacts.retrieve_single_physician_referral_source_contacts(id)
    puts "-----------RETRIEVING PhysicianReferralSourceContacts------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Referral Source Contacts  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_physician_referral_source_with_physicial_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  if PhysicianReferralSourceContacts.exists?(:physicianUrl => req['physicianUrl'])
    retrieve = PhysicianReferralSourceContacts.retrieve_single_physician_referral_source_contacts_with_physicianUrl(physicianUrl)
    puts "-----------RETRIEVING PhysicianReferralSourceContacts------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Referral Source Contacts found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_physician_referral_source' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
 physicianUrl = req['physicianUrl']
  firstName = req['firstName']
  middleName = req['middleName']
  lastName = req['lastName']
  phone1 = req['phone1']
  phone2 = req['phone2']
  information = req['information']
  email = req['email']
  startDate = req['startDate']
  updatedBy = req['updatedBy']
    
      if PhysicianReferralSourceContacts.exists?(:id => req['id'])
    get_update_physician_referral_source_contacts(id,physicianUrl,firstName,middleName,lastName,phone1,phone2,information,email,startDate,updatedBy)
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Physician Referral Source Contacts!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_physician_referral_source' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PhysicianReferralSourceContacts.exists?(:id => req['id'])

    PhysicianReferralSourceContacts.where(id: id).destroy_all
    puts "-----------DELETING PhysicianReferralSourceContacts------------------"
    del = [{resp_code: '000', resp_desc: 'Physician Address Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Referral Source Contacts found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



    ### physician_ancillary_phone_info URL  START
post '/create_physician_ancillary_phone_info' do
  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  phoneType = req['phoneType']
  phone = req['phone']
  description = req['description']
  updatedBy = req['updatedBy']


    if phone.length < 1 
     halt PHONE_ERR.to_json
 
   end
  
   p creating_physician_ancillary_phone_info(physicianUrl,phoneType,phone,description,updatedBy)
   success  =  { resp_code: '000',resp_desc: 'Physician Ancillary Phone info Successfully Created'} 
   return success.to_json 
     
end


get '/retrieve_all_physician_ancillary_phone_info' do
  retrieve_acess = PhysicianAncillaryPhoneInfo.retrieve_physician_ancillary_phone_info
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_physician_ancillary_phone_info' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PhysicianAncillaryPhoneInfo.exists?(:id => req['id'])
    retrieve = PhysicianAncillaryPhoneInfo.retrieve_single_physician_ancillary_phone_info(id)
    puts "-----------RETRIEVING PhysicianAncillaryPhoneInfo------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Ancillary Phone Info  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_physician_ancillary_phone_info_with_physicial_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  if PhysicianAncillaryPhoneInfo.exists?(:physicianUrl => req['physicianUrl'])
    retrieve = PhysicianAncillaryPhoneInfo.retrieve_physician_ancillary_phone_info_with_physicianUrl(physicianUrl)
    puts "-----------RETRIEVING PhysicianAncillaryPhoneInfo------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Ancillary Phone Info found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_single_physician_ancillary_phone_info' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
  physicianUrl = req['physicianUrl']
  phoneType = req['phoneType']
  phone = req['phone']
  description = req['description']
  updatedBy = req['updatedBy']
    
      if PhysicianAncillaryPhoneInfo.exists?(:id => req['id'])
      get_update_physician_ancillary_phone_info(id,physicianUrl,phoneType,phone,description,updatedBy)
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Physician Ancillary Phone Info!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_physician_ancillary_phone_info' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PhysicianAncillaryPhoneInfo.exists?(:id => req['id'])

    PhysicianAncillaryPhoneInfo.where(id: id).destroy_all
    puts "-----------DELETING PhysicianAncillaryPhoneInfo------------------"
    del = [{resp_code: '000', resp_desc: 'Physician Address Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Ancillary Phone Info found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


  # CREATE TABLE `physician_notes` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `physicianUrl` varchar(255) DEFAULT NULL,
  # `date` varchar(255) DEFAULT NULL,
  # `noteBy` varchar(255) DEFAULT NULL,
  # `noteType` varchar(255) DEFAULT NULL,
  # `document` varchar(255) DEFAULT NULL,
  # `note` varchar(255) DEFAULT NULL,
  # `active` varchar(255) DEFAULT NULL,
  # `updatedBy` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)

    ### physician_notes URL  START
post '/create_physician_notes' do
  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  date = req['date']
  noteBy = req['noteBy']
  noteType = req['noteType']
  document = req['document']
  note = req['note']
  active = req['active']
  updatedBy = req['updatedBy']

  
   p creating_physician_notes(physicianUrl,date,noteBy,noteType,document,note,active,updatedBy)
   success  =  { resp_code: '000',resp_desc: 'Physician Notes Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_physician_notes' do
  retrieve_acess = PhysicianNote.retrieve_physician_notes
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_physician_notes' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PhysicianNote.exists?(:id => req['id'])
    retrieve = PhysicianNote.retrieve_single_physician_notes(id)
    puts "-----------RETRIEVING PhysicianNote------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Note  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_physician_notes_with_physicial_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  if PhysicianNote.exists?(:physicianUrl => req['physicianUrl'])
    retrieve = PhysicianNote.retrieve_physician_notes_with_physicianUrl(physicianUrl)
    puts "-----------RETRIEVING PhysicianNote------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Note found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_single_physician_notes' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
  physicianUrl = req['physicianUrl']
  date = req['date']
  noteBy = req['noteBy']
  noteType = req['noteType']
  document = req['document']
  note = req['note']
  active = req['active']
  updatedBy = req['updatedBy']
    
      if PhysicianNote.exists?(:id => req['id'])
get_update_physician_notes(id,physicianUrl,date,noteBy,noteType,document,note,active,updatedBy)
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Physician Notes!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_physician_notes' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PhysicianNote.exists?(:id => req['id'])

    PhysicianNote.where(id: id).destroy_all
    puts "-----------DELETING PhysicianNote------------------"
    del = [{resp_code: '000', resp_desc: 'Physician notes Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Notes found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



  # CREATE TABLE `physician_licenses` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `physicianUrl` varchar(255) DEFAULT NULL,
  # `licenseNumber` varchar(255) DEFAULT NULL,
  # `state` varchar(255) DEFAULT NULL,
  # `expirationDate` varchar(255) DEFAULT NULL,
  # `verificationDate` varchar(255) DEFAULT NULL,
  # `status` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


    ### physician_licenses URL  START
post '/create_physician_licenses' do
  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  licenseNumber = req['licenseNumber']
  state = req['state']
  expirationDate = req['expirationDate']
  verificationDate = req['verificationDate']
  status = req['status']
  


  if physicianUrl.length < 1 
     halt PHY_URL_ERR.to_json
   elsif licenseNumber.length< 1
     halt LIC_NUM_ERR.to_json
   elsif state.length< 1
      halt STATE_ERR.to_json
   elsif status.length< 1
      halt STATE_ERR.to_json
 
   end

  
   p creating_physician_licenses(physicianUrl,licenseNumber,state,expirationDate,verificationDate,status)
   success  =  { resp_code: '000',resp_desc: 'Physician license Successfully Created'} 
   return success.to_json 
     
end




get '/retrieve_all_physician_licenses' do
  retrieve_acess = PhysicianLicenses.retrieve_physician_licenses
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_physician_licenses' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PhysicianLicenses.exists?(:id => req['id'])
    retrieve = PhysicianLicenses.retrieve_single_physician_licenses(id)
    puts "-----------RETRIEVING PhysicianLicenses------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Licenses  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_physician_licenses_with_physicial_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  if PhysicianLicenses.exists?(:physicianUrl => req['physicianUrl'])
    retrieve = PhysicianLicenses.retrieve_physician_licenses_with_physicianUrl(physicianUrl)
    puts "-----------RETRIEVING PhysicianLicenses------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Licenses found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_single_physician_licenses' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
 physicianUrl = req['physicianUrl']
  licenseNumber = req['licenseNumber']
  state = req['state']
  expirationDate = req['expirationDate']
  verificationDate = req['verificationDate']
  status = req['status']
    
      if PhysicianLicenses.exists?(:id => req['id'])
      get_update_physician_licenses(id,physicianUrl,licenseNumber,state,expirationDate,verificationDate,status)
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Physician Licenses!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_physician_licenses' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PhysicianLicenses.exists?(:id => req['id'])

    PhysicianLicenses.where(id: id).destroy_all
    puts "-----------DELETING Physician Licenses------------------"
    del = [{resp_code: '000', resp_desc: 'Physician Licenses Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Licenses found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end







  # CREATE TABLE `physician_identifier` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `physicianUrl` varchar(255) DEFAULT NULL,
  # `identifierType` varchar(255) DEFAULT NULL,
  # `identifierValue` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `updatedBy` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


    ### physician_identifier URL  START
 post '/create_physician_identifier' do
  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  identifierType = req['identifierType']
  identifierValue = req['identifierValue']
  startDate = req['startDate']
  endDate = req['endDate']
  updatedBy = req['updatedBy']
  

  
   p creating_physician_identifier(physicianUrl,identifierType,identifierValue,startDate,endDate,updatedBy)
   success  =  { resp_code: '000',resp_desc: 'Physician identifier Successfully Created'} 
   return success.to_json 
     
end




get '/retrieve_all_physician_identifier' do
  retrieve_acess = PhysicianIdentifier.retrieve_physician_identifier
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_physician_identifier' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PhysicianIdentifier.exists?(:id => req['id'])
    retrieve = PhysicianIdentifier.retrieve_single_physician_identifier(id)
    puts "-----------RETRIEVING PhysicianIdentifier------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Identifier  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_physician_identifier_with_physician_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  if PhysicianIdentifier.exists?(:physicianUrl => req['physicianUrl'])
    retrieve = PhysicianIdentifier.retrieve_physician_identifier_with_physicianUrl(physicianUrl)
    puts "-----------RETRIEVING PhysicianIdentifier------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No  Physician Identifier found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_single_physician_identifier' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
   physicianUrl = req['physicianUrl']
  identifierType = req['identifierType']
  identifierValue = req['identifierValue']
  startDate = req['startDate']
  endDate = req['endDate']
  updatedBy = req['updatedBy']
    
      if PhysicianIdentifier.exists?(:id => req['id'])
     get_update_physician_identifier(id,physicianUrl,identifierType,identifierValue,startDate,endDate,updatedBy)
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Physician Identifier!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_physician_identifier' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PhysicianIdentifier.exists?(:id => req['id'])

    PhysicianIdentifier.where(id: id).destroy_all
    puts "-----------DELETING Physician Identifier------------------"
    del = [{resp_code: '000', resp_desc: 'Physician Identifier Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Identifier found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




    ### physician_documents URL  START
post '/create_physician_documents' do
  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  attachTo = req['attachTo']
  file = req['file']
  documentType = req['documentType']
  documentStatus = req['documentStatus']
  description = req['description']
  note = req['note']
  uploadedBy = req['uploadedBy']
  uploadedDate = req['uploadedDate']
  
  
   p creating_physician_documents(physicianUrl,attachTo,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
   success  =  { resp_code: '000',resp_desc: 'Physician Documents Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_physician_documents' do
  retrieve_acess = PhysicianDocuments.retrieve_physician_documents
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_physician_documents' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PhysicianDocuments.exists?(:id => req['id'])
    retrieve = PhysicianDocuments.retrieve_single_physician_documents(id)
    puts "-----------RETRIEVING PhysicianDocuments------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Physician Documents  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_physician_documents_with_physician_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  physicianUrl = req['physicianUrl']
  if PhysicianDocuments.exists?(:physicianUrl => req['physicianUrl'])
    retrieve = PhysicianDocuments.retrieve_physician_documents_with_physicianUrl(physicianUrl)
    puts "-----------RETRIEVING PhysicianDocuments------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No  Physician Documents found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_single_physician_documents' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
   physicianUrl = req['physicianUrl']
  attachTo = req['attachTo']
  file = req['file']
  documentType = req['documentType']
  documentStatus = req['documentStatus']
  description = req['description']
  note = req['note']
  uploadedBy = req['uploadedBy']
  uploadedDate = req['uploadedDate']
    
      if PhysicianDocuments.exists?(:id => req['id'])
get_update_physician_documents(id,physicianUrl,attachTo,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
   puts "------------------UPDATING skills ------------------"
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Physician Documents!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_physician_documents' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PhysicianDocuments.exists?(:id => req['id'])

    PhysicianDocuments.where(id: id).destroy_all
    puts "-----------DELETING Physician Documents------------------"
    del = [{resp_code: '000', resp_desc: 'Physician Documents Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No PhysicianDocuments found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




  # CREATE TABLE `facility_ancillary_phones` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `physicianUrl` varchar(255) DEFAULT NULL,
  # `phoneType` varchar(255) DEFAULT NULL,
  # `phone` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `updatedBy` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


      ### facility_ancillary_phones URL  START
post '/create_facility_ancillary_phones' do
  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  phoneType = req['phoneType']
  phone = req['phone']
  description = req['description']
  updatedBy = req['updatedBy']
  
  
   p creating_facility_ancillary_phones(facilityUrl,phoneType,phone,description,updatedBy)
   success  =  { resp_code: '000',resp_desc: 'Facility Ancillary Phones Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_facility_ancillary_phones' do
  retrieve_acess = FacilityAncillaryPhone.retrieve_facility_ancillary_phones
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_facility_ancillary_phones' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if FacilityAncillaryPhone.exists?(:id => req['id'])
    retrieve = FacilityAncillaryPhone.retrieve_single_facility_ancillary_phones(id)
    puts "-----------RETRIEVING FacilityAncillaryPhone------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No FacilityAncillaryPhone  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_facility_ancillary_phones_with_facilityUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  if FacilityAncillaryPhone.exists?(:facilityUrl => req['facilityUrl'])
    retrieve = FacilityAncillaryPhone.retrieve_facility_ancillary_phones_with_facilityUrl(facilityUrl)
    puts "-----------RETRIEVING FacilityAncillaryPhone------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No  FacilityAncillaryPhone found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_single_facility_ancillary_phones' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
  facilityUrl = req['facilityUrl']
  phoneType = req['phoneType']
  phone = req['phone']
  description = req['description']
  updatedBy = req['updatedBy']
    
      if FacilityAncillaryPhone.exists?(:id => req['id'])
    get_update_facility_ancillary_phones(id,facilityUrl,phoneType,phone,description,updatedBy)
   puts "------------------UPDATING skills ------------------"
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated FacilityAncillaryPhone'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_facility_ancillary_phones' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if FacilityAncillaryPhone.exists?(:id => req['id'])

    FacilityAncillaryPhone.where(id: id).destroy_all
    puts "-----------DELETING Physician Documents------------------"
    del = [{resp_code: '000', resp_desc: 'Facility Ancillary Phone Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Ancillary Phone found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




  # CREATE TABLE `facility_referral_source_contacts` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `facilityUrl` varchar(255) DEFAULT NULL,
  # `firstName` varchar(255) DEFAULT NULL,
  # `middleName` varchar(255) DEFAULT NULL,
  # `lastName` varchar(255) DEFAULT NULL,
  # `phone1` varchar(255) DEFAULT NULL,
  # `phone2` varchar(255) DEFAULT NULL,
  # `information` varchar(255) DEFAULT NULL,
  # `email` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `updatedBy` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


      ### facility_ancillary_phones URL  START
post '/create_facility_referral_source_contacts' do
  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  firstName = req['firstName']
  middleName = req['middleName']
  lastName = req['lastName']
  phone1 = req['phone1']
  phone2 = req['phone2']
  information = req['information']
  email = req['email']
  startDate = req['startDate']
  updatedBy = req['updatedBy']
  
  
   p creating_facility_referral_source_contacts(facilityUrl,firstName,middleName,lastName,phone1,phone2,information,email,startDate,updatedBy)
   success  =  { resp_code: '000',resp_desc: 'Facility referral source contacts Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_facility_referral_source_contacts' do
  retrieve_acess = FacilityReferralSourceContact.retrieve_facility_referral_source_contacts
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_facility_referral_source_contacts' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if FacilityReferralSourceContact.exists?(:id => req['id'])
    retrieve = FacilityReferralSourceContact.retrieve_single_facility_referral_source_contacts(id)
    puts "-----------RETRIEVING Facility Referral Source Contact------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Referral Source Contact  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_facility_referral_source_contacts_with_facilityUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  if FacilityReferralSourceContact.exists?(:facilityUrl => req['facilityUrl'])
    retrieve = FacilityReferralSourceContact.retrieve_facility_referral_source_contacts_with_facilityUrl(facilityUrl)
    puts "-----------RETRIEVING FacilityReferralSourceContact------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No  Facility Referral Source Contact found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_facility_referral_source_contacts' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
   facilityUrl = req['facilityUrl']
  firstName = req['firstName']
  middleName = req['middleName']
  lastName = req['lastName']
  phone1 = req['phone1']
  phone2 = req['phone2']
  information = req['information']
  email = req['email']
  startDate = req['startDate']
  updatedBy = req['updatedBy']
    
      if FacilityReferralSourceContact.exists?(:id => req['id'])
    get_update_facility_referral_source_contacts(id,facilityUrl,firstName,middleName,lastName,phone1,phone2,information,email,startDate,updatedBy)
   puts "------------------UPDATING skills ------------------"
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated FacilityReferralSourceContact'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_facility_referral_source_contacts' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if FacilityReferralSourceContact.exists?(:id => req['id'])

    FacilityReferralSourceContact.where(id: id).destroy_all
    puts "-----------DELETING Physician Documents------------------"
    del = [{resp_code: '000', resp_desc: 'Facility Referral Source Contact Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Referral Source Contact found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




# facilityUrl,--> url of the facility
#       addressType,--> string
#       address1,--> string
#       address2, --> string
#       city, --> string
#       state, --> string
#       zip, --> string
#       addressPhoneInfoPhones, --> string
#       updatedBy, --> string


 # CREATE TABLE `facility_address_phone_infos` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `facilityUrl` varchar(255) DEFAULT NULL,
 #  `addressType` varchar(255) DEFAULT NULL,
 #  `address1` varchar(255) DEFAULT NULL,
 #  `address2` varchar(255) DEFAULT NULL,
 #  `city` varchar(255) DEFAULT NULL,
 #  `state` varchar(255) DEFAULT NULL,
 #  `zip` varchar(255) DEFAULT NULL,
 #  `addressPhoneInfoPhones` varchar(255) DEFAULT NULL,
 #  `updatedBy` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`)


      ### facility_ancillary_phones URL  START
post '/create_facility_address_phone_infos' do
  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']
  updatedBy = req['updatedBy']
  
  
   p creating_facility_address_phone_infos(facilityUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones,updatedBy)
   success  =  { resp_code: '000',resp_desc: 'Facility address phone infos Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_facility_address_phone_infos' do
  retrieve_acess = FacilityAddressPhoneInfo.retrieve_facility_address_phone_infos
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_facility_address_phone_infos' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if FacilityAddressPhoneInfo.exists?(:id => req['id'])
    retrieve = FacilityAddressPhoneInfo.retrieve_single_facility_address_phone_infos(id)
    puts "-----------RETRIEVING Facility Referral Source Contact------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Address Phone Infos  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_facility_address_phone_infos_with_facilityUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  if FacilityAddressPhoneInfo.exists?(:facilityUrl => req['facilityUrl'])
    retrieve = FacilityAddressPhoneInfo.retrieve_facility_address_phone_infos_with_facilityUrl(facilityUrl)
    puts "-----------RETRIEVING FacilityAddressPhoneInfo------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No  Facility Address Phone Info found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_facility_address_phone_infos' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
  facilityUrl = req['facilityUrl']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']
  updatedBy = req['updatedBy']
    
      if FacilityAddressPhoneInfo.exists?(:id => req['id'])
    get_update_facility_address_phone_infos(id,facilityUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones,updatedBy)
   puts "------------------UPDATING skills ------------------"
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Facility Address Phone Info'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_facility_address_phone_infos' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if FacilityAddressPhoneInfo.exists?(:id => req['id'])

    FacilityAddressPhoneInfo.where(id: id).destroy_all
    puts "-----------DELETING FacilityAddressPhoneInfo------------------"
    del = [{resp_code: '000', resp_desc: 'Facility Address Phone Info Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Address Phone Info found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





 # CREATE TABLE `collector_assignments` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `agency` varchar(255) DEFAULT NULL,
 #  `level` varchar(255) DEFAULT NULL,
 #  `assignTo` varchar(255) DEFAULT NULL,
 #  `payer` varchar(255) DEFAULT NULL,
 #  `payerCategory` varchar(255) DEFAULT NULL,
 #  `patientEncounter` varchar(255) DEFAULT NULL,
 #  `team` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`)


      ### facility_ancillary_phones URL  START
post '/create_collector_assignments' do
  request.body.rewind
  req = JSON.parse request.body.read

  agency = req['agency']
  level = req['level']
  assignTo = req['assignTo']
  payer = req['payer']
  payerCategory = req['payerCategory']
  team = req['team']
  patientEncounter = req['patientEncounter']
 
  
  
   p creating_collector_assignments(agency,level,assignTo,payer,payerCategory,team,patientEncounter)
   success  =  { resp_code: '000',resp_desc: 'Collector Assignments Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_collector_assignments' do
  retrieve_acess = CollectorAssignment.retrieve_collector_assignments
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_collector_assignments' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if CollectorAssignment.exists?(:id => req['id'])
    retrieve = CollectorAssignment.retrieve_single_collector_assignments(id)
    puts "-----------retrieve_single_collector_assignments------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Collector assignments  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





post '/update_collector_assignments' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
  agency = req['agency']
  level = req['level']
  assignTo = req['assignTo']
  payer = req['payer']
  payerCategory = req['payerCategory']
  team = req['team']
  patientEncounter = req['patientEncounter']
    
      if CollectorAssignment.exists?(:id => req['id'])
    get_update_collector_assignments(id,agency,level,assignTo,payer,payerCategory,team,patientEncounter)
   puts "------------------UPDATING skills ------------------"
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Collector assignments'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_collector_assignments' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if CollectorAssignment.exists?(:id => req['id'])

    CollectorAssignment.where(id: id).destroy_all
    puts "-----------DELETING CollectorAssignment------------------"
    del = [{resp_code: '000', resp_desc: 'Collector assignments Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Collector assignments found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





      ### freferralData
post '/create_referrals' do
  request.body.rewind
  req = JSON.parse request.body.read

   
   uid = req['uid']
    isCompleted = req['isCompleted']
    status = req['status']
    agency = req['agency']
    agencyType = req['agencyType']
    referralSourceID = req['referralSourceID']
    modeOfDelivery = req['modeOfDelivery']
    salesRep = req['salesRep']
    referralSourceContact = req['referralSourceContact']
    phoneOne = req['phoneOne']
    phoneOneType = req['phoneOneType']
    phoneTwo = req['phoneTwo']
    phoneTwoType = req['phoneTwoType']
    referralEmail = req['referralEmail']
    referralInformation = req['referralInformation']
    payerCategory = req['payerCategory']
    referralDate = req['referralDate']
    referralSOC = req['referralSOC']
    admissionSource = req['admissionSource']
    admissionType = req['admissionType']
    disciplines = req['disciplines']
    primaryPhysician = req['primaryPhysician']
    physicians = req['physicians']
    physicianType = req['physicianType']
    requestedSOC = req['requestedSOC']
    physicianOrders = req['physicianOrders']
    orderDate = req['orderDate']
    surgicalProcedures = req['surgicalProcedures']
    nutritionalRequirements = req['nutritionalRequirements']
    supplyInformation = req['supplyInformation']
    diagnosisCode = req['diagnosisCode']
    diagnosis = req['diagnosis']
    medications = req['medications']
    zipCode = req['zipCode']
    skills = req['skills']
    organization_url = req['organization_url']

 
  
  
  p creating_referralData(
    uid,
  isCompleted,status,agency,
 agencyType,
referralSourceID,
modeOfDelivery,salesRep,
referralSourceContact,
phoneOne,
phoneOneType,
phoneTwo,
phoneTwoType,
referralEmail,
referralInformation,
payerCategory,
referralDate,
referralSOC,
admissionSource,
admissionType,
disciplines,
primaryPhysician,
physicians,
physicianType,
requestedSOC,
physicianOrders,
orderDate,
surgicalProcedures,
nutritionalRequirements,
supplyInformation,
diagnosisCode,
diagnosis,
medications,
zipCode,
skills,organization_url
)
   success  =  { resp_code: '000',resp_desc: 'referralData Created'} 
   return success.to_json 
     
end



get '/retrieve_all_referrals' do
  retrieve_acess = ReferralData.retrieve_referralData
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_referrals' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if ReferralData.exists?(:uid => req['uid'])
    retrieve = ReferralData.retrieve_single_referralData(uid)
    puts "-----------retrieve_single_referralData------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No referral Data  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_referrals' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   uid = req['uid']
   isCompleted = req['isCompleted']
    status = req['status']
    agency = req['agency']
    agencyType = req['agencyType']
    referralSourceID = req['referralSourceID']
    modeOfDelivery = req['modeOfDelivery']
    salesRep = req['salesRep']
    referralSourceContact = req['referralSourceContact']
    phoneOne = req['phoneOne']
    phoneOneType = req['phoneOneType']
    phoneTwo = req['phoneTwo']
    phoneTwoType = req['phoneTwoType']
    referralEmail = req['referralEmail']
    referralInformation = req['referralInformation']
    payerCategory = req['payerCategory']
    referralDate = req['referralDate']
    referralSOC = req['referralSOC']
    admissionSource = req['admissionSource']
    admissionType = req['admissionType']
    disciplines = req['disciplines']
    primaryPhysician = req['primaryPhysician']
    physicians = req['physicians']
    physicianType = req['physicianType']
    requestedSOC = req['requestedSOC']
    physicianOrders = req['physicianOrders']
    orderDate = req['orderDate']
    surgicalProcedures = req['surgicalProcedures']
    nutritionalRequirements = req['nutritionalRequirements']
    supplyInformation = req['supplyInformation']
    diagnosisCode = req['diagnosisCode']
    diagnosis = req['diagnosis']
    medications = req['medications']
    zipCode = req['zipCode']
    skills = req['skills']
    organization_url = req['organization_url']
    
      if ReferralData.exists?(:uid => req['uid'])
    get_update_referralData(uid, isCompleted,status,agency,
 agencyType,
referralSourceID,
modeOfDelivery,salesRep,
referralSourceContact,
phoneOne,
phoneOneType,
phoneTwo,
phoneTwoType,
referralEmail,
referralInformation,
payerCategory,
referralDate,
referralSOC,
admissionSource,
admissionType,
disciplines,
primaryPhysician,
physicians,
physicianType,
requestedSOC,
physicianOrders,
orderDate,
surgicalProcedures,
nutritionalRequirements,
supplyInformation,
diagnosisCode,
diagnosis,
medications,
zipCode,
skills,organization_url)
   puts "------------------UPDATING skills ------------------"
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Referral Data'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_referrals' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if ReferralData.exists?(:uid => req['uid'])

    ReferralData.where(uid: uid).destroy_all
    puts "-----------DELETING CollectorAssignment------------------"
    del = [{resp_code: '000', resp_desc: 'Referral Data Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Referral Data found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





  #  CREATE TABLE `patients` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `patientType` varchar(255) DEFAULT NULL,
  # `status` varchar(255) DEFAULT NULL,
  # `encounterNumber` varchar(255) DEFAULT NULL,
  # `referralID` varchar(255) DEFAULT NULL,
  # `presentation` varchar(255) DEFAULT NULL,
  # `patientInformation` varchar(255) DEFAULT NULL,
  # `placeOfAdmission` varchar(255) DEFAULT NULL,
  # `admissionDate` varchar(255) DEFAULT NULL,
  # `firstName` varchar(255) DEFAULT NULL,
  # `middleName` varchar(255) DEFAULT NULL,
  # `lastName` varchar(255) DEFAULT NULL,
  # `dateOfBirth` varchar(255) DEFAULT NULL,
  # `gender` varchar(255) DEFAULT NULL,
  # `race` varchar(255) DEFAULT NULL,
  # `maritalStatus` varchar(255) DEFAULT NULL,
  # `email` varchar(255) DEFAULT NULL,
  # `readmitID` varchar(255) DEFAULT NULL,
  # `facilities` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))


   post '/create_patient' do
  request.body.rewind
  req = JSON.parse request.body.read

uid = req['uid']
  patientType = req['patientType']
  status = req['status']
  encounterNumber = req['encounterNumber']
  referralID = req['referralID']
  presentation = req['presentation']
  patientInformation = req['patientInformation']
  placeOfAdmission = req['placeOfAdmission']
  admissionDate = req['admissionDate']
  firstName = req['firstName']
  middleName = req['middleName']
  lastName = req['lastName']
  dateOfBirth = req['dateOfBirth']
  gender = req['gender']
  race = req['race']
  maritalStatus = req['maritalStatus']
  email = req['email']
  readmitID = req['readmitID']
  facilities = req['facilities']
  organization_url = req['organization_url']
  medicalRecord = req['medicalRecord']
  socialSecurity = req['socialSecurity']
  characteristics = req['characteristics']
  county = req['county']
 
  
  
   p creating_patients(uid,patientType,status,encounterNumber,referralID,presentation,patientInformation,placeOfAdmission,
    admissionDate,firstName,middleName,lastName,dateOfBirth,gender,race,maritalStatus,email,readmitID,facilities,organization_url,medicalRecord,socialSecurity,characteristics,county)
   success  =  { resp_code: '000',resp_desc: 'Patients Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_patients' do
  retrieve_acess = Patient.retrieve_patients
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_patient' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if Patient.exists?(:uid => req['uid'])
    retrieve = Patient.retrieve_single_patient(uid)
    puts "-----------retrieve_patient------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No patient  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_patient_by_org_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  organization_url = req['organization_url']
  if Patient.exists?(:organization_url => req['organization_url'])
    retrieve = Patient.retrieve_single_patient_by_org_url(organization_url)
    puts "-----------retrieve_patient------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No patient  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





post '/update_patient' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   uid = req['uid']
   patientType = req['patientType']
  status = req['status']
  encounterNumber = req['encounterNumber']
  referralID = req['referralID']
  presentation = req['presentation']
  patientInformation = req['patientInformation']
  placeOfAdmission = req['placeOfAdmission']
  admissionDate = req['admissionDate']
  firstName = req['firstName']
  middleName = req['middleName']
  lastName = req['lastName']
  dateOfBirth = req['dateOfBirth']
  gender = req['gender']
  race = req['race']
  maritalStatus = req['maritalStatus']
  email = req['email']
  readmitID = req['readmitID']
  facilities = req['facilities']
  organization_url = req['organization_url']
  medicalRecord = req['medicalRecord']
  socialSecurity = req['socialSecurity']
  characteristics = req['characteristics']
  county = req['county']
    
      if Patient.exists?(:uid => req['uid'])
    get_update_patient(uid,patientType,status,encounterNumber,referralID,presentation,patientInformation,placeOfAdmission,
    admissionDate,firstName,middleName,lastName,dateOfBirth,gender,race,maritalStatus,email,readmitID,facilities,organization_url,medicalRecord,socialSecurity,




    characteristics,county)
   puts "------------------UPDATING Patient ------------------"
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated patient'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if Patient.exists?(:uid => req['uid'])

    Patient.where(uid: uid).destroy_all
    puts "-----------DELETING Patient------------------"
    del = [{resp_code: '000', resp_desc: 'Patient Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end







  #  CREATE TABLE `facility_documents` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `facilityUrl` varchar(255) DEFAULT NULL,
  # `attachTo` varchar(255) DEFAULT NULL,
  # `file` varchar(255) DEFAULT NULL,
  # `documentType` varchar(255) DEFAULT NULL,
  # `documentStatus` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `note` varchar(255) DEFAULT NULL,
  # `uploadedBy` varchar(255) DEFAULT NULL,
  # `uploadedDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))


    ### Facility documents URL  START
post '/create_facility_documents' do
  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  attachTo = req['attachTo']
  file = req['file']
  documentType = req['documentType']
  documentStatus = req['documentStatus']
  description = req['description']
  note = req['note']
  uploadedBy = req['uploadedBy']
  uploadedDate = req['uploadedDate']
  
  
   p creating_facility_documents(facilityUrl,attachTo,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
   success  =  { resp_code: '000',resp_desc: 'Facility Documents Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_facility_documents' do
  retrieve_acess = FacilityDocuments.retrieve_facility_documents
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_facility_documents' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if FacilityDocuments.exists?(:id => req['id'])
    retrieve = FacilityDocuments.retrieve_single_facility_documents(id)
    puts "-----------RETRIEVING FacilityDocuments------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No facility Documents  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_facility_documents_with_facility_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  if FacilityDocuments.exists?(:facilityUrl => req['facilityUrl'])
    retrieve = FacilityDocuments.retrieve_facility_documents_with_facilityUrl(facilityUrl)
    puts "-----------RETRIEVING FacilityDocuments------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Documents found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_single_facility_documents' do
  puts "------------------UPDATING facility API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
   facilityUrl = req['facilityUrl']
  attachTo = req['attachTo']
  file = req['file']
  documentType = req['documentType']
  documentStatus = req['documentStatus']
  description = req['description']
  note = req['note']
  uploadedBy = req['uploadedBy']
  uploadedDate = req['uploadedDate']
    
      if FacilityDocuments.exists?(:id => req['id'])
get_update_facility_documents(id,facilityUrl,attachTo,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
   puts "------------------UPDATING skills ------------------"
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated facility Documents!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_facility_documents' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if FacilityDocuments.exists?(:id => req['id'])

    FacilityDocuments.where(id: id).destroy_all
    puts "-----------DELETING FacilityDocuments------------------"
    del = [{resp_code: '000', resp_desc: 'Facility Documents Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Documents found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end






  # CREATE TABLE `facility_identifier` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `facilityUrl` varchar(255) DEFAULT NULL,
  # `identifierType` varchar(255) DEFAULT NULL,
  # `identifierValue` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `updatedBy` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


    ### physician_identifier URL  START
 post '/create_facility_identifier' do
  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  identifierType = req['identifierType']
  identifierValue = req['identifierValue']
  startDate = req['startDate']
  endDate = req['endDate']
  updatedBy = req['updatedBy']
  

  
   p creating_facility_identifier(facilityUrl,identifierType,identifierValue,startDate,endDate,updatedBy)
   success  =  { resp_code: '000',resp_desc: 'Facility identifier Successfully Created'} 
   return success.to_json 
     
end




get '/retrieve_all_facility_identifier' do
  retrieve_acess = FacilityIdentifier.retrieve_facility_identifier
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_facility_identifier' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if FacilityIdentifier.exists?(:id => req['id'])
    retrieve = FacilityIdentifier.retrieve_single_facility_identifier(id)
    puts "-----------RETRIEVING FacilityIdentifier------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Identifier  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_facility_identifier_with_facility_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  if FacilityIdentifier.exists?(:facilityUrl => req['facilityUrl'])
    retrieve = FacilityIdentifier.retrieve_facility_identifier_with_facilityUrl(facilityUrl)
    puts "-----------RETRIEVING FacilityIdentifier------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No  facility Identifier found' }]
     puts "-------------------- SHITT------------------------"
   halt no_location.to_json 
 end
end


post '/update_single_facility_identifier' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
 facilityUrl = req['facilityUrl']
  identifierType = req['identifierType']
  identifierValue = req['identifierValue']
  startDate = req['startDate']
  endDate = req['endDate']
  updatedBy = req['updatedBy']
    
      if FacilityIdentifier.exists?(:id => req['id'])
     get_update_facility_identifier(id,facilityUrl,identifierType,identifierValue,startDate,endDate,updatedBy)
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Facility Identifier!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_facility_identifier' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if FacilityIdentifier.exists?(:id => req['id'])

    FacilityIdentifier.where(id: id).destroy_all
    puts "-----------DELETING Facility Identifier------------------"
    del = [{resp_code: '000', resp_desc: 'Facility Identifier Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Identifier found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





 # CREATE TABLE `facility_notes` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `physicianUrl` varchar(255) DEFAULT NULL,
 #  `date` varchar(255) DEFAULT NULL,
 #  `noteBy` varchar(255) DEFAULT NULL,
 #  `noteType` varchar(255) DEFAULT NULL,
 #  `document` varchar(255) DEFAULT NULL,
 #  `note` varchar(255) DEFAULT NULL,
 #  `active` varchar(255) DEFAULT NULL,
 #  `updatedBy` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`)

    ### physician_notes URL  START
post '/create_facility_notes' do
  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  date = req['date']
  noteBy = req['noteBy']
  noteType = req['noteType']
  document = req['document']
  note = req['note']
  active = req['active']
  updatedBy = req['updatedBy']

  
   p creating_facility_notes(facilityUrl,date,noteBy,noteType,document,note,active,updatedBy)
   success  =  { resp_code: '000',resp_desc: 'Facility Notes Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_facility_notes' do
  retrieve_acess = FacilityNote.retrieve_facility_notes
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_facility_notes' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if FacilityNote.exists?(:id => req['id'])
    retrieve = FacilityNote.retrieve_single_facility_notes(id)
    puts "-----------RETRIEVING FacilityNote------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Note  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_facility_notes_with_facility_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  facilityUrl = req['facilityUrl']
  if FacilityNote.exists?(:facilityUrl => req['facilityUrl'])
    retrieve = FacilityNote.retrieve_facility_notes_with_facilityUrl(facilityUrl)
    puts "-----------RETRIEVING FacilityNote------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No facility Note found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_single_facility_notes' do
  puts "------------------UPDATING Compliance API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
  facilityUrl = req['facilityUrl']
  date = req['date']
  noteBy = req['noteBy']
  noteType = req['noteType']
  document = req['document']
  note = req['note']
  active = req['active']
  updatedBy = req['updatedBy']
    
      if FacilityNote.exists?(:id => req['id'])
get_update_facility_notes(id,facilityUrl,date,noteBy,noteType,document,note,active,updatedBy)
      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Facility Notes!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_facility_notes' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if FacilityNote.exists?(:id => req['id'])

    FacilityNote.where(id: id).destroy_all
    puts "-----------DELETING FacilityNote------------------"
    del = [{resp_code: '000', resp_desc: 'Facility Note Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Facility Note found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




 # CREATE TABLE `payments` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `paymentSource` varchar(255) DEFAULT NULL,
 #  `paymentMethod` varchar(255) DEFAULT NULL,
 #  `paymentAmount` float DEFAULT NULL,
 #  `remitDate` varchar(255) DEFAULT NULL,
 #  `depositDate` varchar(255) DEFAULT NULL,
 #  `referenceNumber` varchar(255) DEFAULT NULL,
 #  `applyPaymentsTo` varchar(255) DEFAULT NULL,
 #  `noteType` varchar(255) DEFAULT NULL,
 #  `note` varchar(255) DEFAULT NULL,
 #  `agency` varchar(255) DEFAULT NULL,
 #  `paymentType` varchar(255) DEFAULT NULL,
 #  `accountBalance` float DEFAULT NULL,
 #  `amountToApply` float DEFAULT NULL,
 #  `paymentBalance` float DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`)

    ### physician_notes URL  START
post '/create_payments' do
  request.body.rewind
  req = JSON.parse request.body.read

  paymentSource = req['paymentSource']
  paymentMethod = req['paymentMethod']
  paymentAmount = req['paymentAmount']
  remitDate = req['remitDate']
  depositDate = req['depositDate']
  referenceNumber = req['referenceNumber']
  applyPaymentsTo = req['applyPaymentsTo']
  noteType = req['noteType']
  note = req['note']
  agency = req['agency']
  paymentType = req['paymentType']
  accountBalance = req['accountBalance']
  amountToApply = req['amountToApply']
  paymentBalance = req['paymentBalance']
  appliedToRemit  = req['appliedToRemit']


  
   p creating_payments(paymentSource,paymentMethod,paymentAmount,remitDate,depositDate,referenceNumber,applyPaymentsTo,
    noteType,note,agency,paymentType,accountBalance,amountToApply,paymentBalance,appliedToRemit)
   success  =  { resp_code: '000',resp_desc: 'Payments Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_payments' do
  retrieve_acess = Payment.retrieve_payments
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_payments' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if Payment.exists?(:id => req['id'])
    retrieve = Payment.retrieve_single_payments(id)
    puts "-----------RETRIEVING Payment------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payment  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_payments' do
  puts "------------------UPDATING payments API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
  paymentSource = req['paymentSource']
  paymentMethod = req['paymentMethod']
  paymentAmount = req['paymentAmount']
  remitDate = req['remitDate']
  depositDate = req['depositDate']
  referenceNumber = req['referenceNumber']
  applyPaymentsTo = req['applyPaymentsTo']
  noteType = req['noteType']
  note = req['note']
  agency = req['agency']
  paymentType = req['paymentType']
  accountBalance = req['accountBalance']
  amountToApply = req['amountToApply']
  paymentBalance = req['paymentBalance']
  appliedToRemit  = req['appliedToRemit']
    
      if Payment.exists?(:id => req['id'])
    get_update_payments(id,paymentSource,paymentMethod,paymentAmount,remitDate,depositDate,referenceNumber,applyPaymentsTo,
    noteType,note,agency,paymentType,accountBalance,amountToApply,paymentBalance,appliedToRemit)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated payments!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payments' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Payment.exists?(:id => req['id'])

    Payment.where(id: id).destroy_all
    puts "-----------DELETING Payment------------------"
    del = [{resp_code: '000', resp_desc: 'Payment Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payment found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end






 # CREATE TABLE `payer_notes` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `payerUrl` varchar(255) DEFAULT NULL,
 #  `date` varchar(255) DEFAULT NULL,
 #  `noteBy` float DEFAULT NULL,
 #  `noteType` varchar(255) DEFAULT NULL,
 #  `document` varchar(255) DEFAULT NULL,
 #  `note` varchar(255) DEFAULT NULL,
 #  `active` tinyint(1) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`)

    ### physician_notes URL  START
post '/create_payer_notes' do
  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  date = req['date']
  noteBy = req['noteBy']
  noteType = req['noteType']
  document = req['document']
  note = req['note']
  active = req['active']
 

  
   p creating_payer_notes(payerUrl,date,noteBy,noteType,document,note,active)
   success  =  { resp_code: '000',resp_desc: 'Payer Notes Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_notes' do
  retrieve_acess = PayerNotes.retrieve_payer_notes
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_payer_notes' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerNotes.exists?(:id => req['id'])
    retrieve = PayerNotes.retrieve_single_payer_notes(id)
    puts "-----------RETRIEVING Payment------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Notes  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_single_payer_notes_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerNotes.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerNotes.retrieve_single_payer_notes_payerUrl(payerUrl)
    puts "-----------RETRIEVING Payment------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Notes  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_payer_notes' do
  puts "------------------UPDATING payments API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
  payerUrl = req['payerUrl']
  date = req['date']
  noteBy = req['noteBy']
  noteType = req['noteType']
  document = req['document']
  note = req['note']
  active = req['active']
    
      if PayerNotes.exists?(:id => req['id'])
    get_update_payerNotes(id,payerUrl,date,noteBy,noteType,document,note,active)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Payer Notes!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payerNotes' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerNotes.exists?(:id => req['id'])

    PayerNotes.where(id: id).destroy_all
    puts "-----------DELETING PayerNotes------------------"
    del = [{resp_code: '000', resp_desc: 'Payer Notes Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Notes found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




 # CREATE TABLE `patient_ancillary_phones` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `patientID` varchar(255) DEFAULT NULL,
 #  `phone` varchar(255) DEFAULT NULL,
 #  `phoneType` float DEFAULT NULL,
 #  `extension` varchar(255) DEFAULT NULL,
 #  `description` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`)

    ### physician_notes URL  START
post '/create_patient_ancillary_phones' do
  request.body.rewind
  req = JSON.parse request.body.read

   uid = req['uid']
  patientID = req['patientID']
  phone = req['phone']
  phoneType = req['phoneType']
  extension = req['extension']
  description = req['description']
 
  
   p creating_patient_ancillary_phones(uid,patientID,phone,phoneType,extension,description)
   success  =  { resp_code: '000',resp_desc: 'Patient ancillary phones Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_ancillary_phones' do
  retrieve_acess = PatientAncillaryPhones.retrieve_patient_ancillary_phones
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_patient_ancillary_phones' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientAncillaryPhones.exists?(:uid => req['uid'])
    retrieve = PatientAncillaryPhones.retrieve_single_patient_ancillary_phones(uid)
    puts "-----------RETRIEVING ancillary_phones------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Ancillary Phones  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_patient_ancillary_phones' do
  puts "------------------UPDATING payments API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   uid = req['uid']
   patientID = req['patientID']
  phone = req['phone']
  phoneType = req['phoneType']
  extension = req['extension']
  description = req['description']
    
      if PatientAncillaryPhones.exists?(:uid => req['uid'])
    get_update_payerNotes(uid,patientID,phone,phoneType,extension,description)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Patient Ancillary Phones!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_ancillary_phones' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientAncillaryPhones.exists?(:uid => req['uid'])

    PatientAncillaryPhones.where(uid: uid).destroy_all
    puts "-----------DELETING PatientAncillaryPhones------------------"
    del = [{resp_code: '000', resp_desc: 'PatientAncillaryPhonesDeleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Ancillary Phones found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




    ### physician_notes URL  START
post '/create_patient_address_phone_info' do
  request.body.rewind
  req = JSON.parse request.body.read

   uid = req['uid']
  patientID = req['patientID']
  addressType = req['addressType']
  addressOne = req['addressOne']
  addressTwo = req['addressTwo']
  city = req['city']
  state = req['state']
  zipcode = req['zipcode']
  phoneType = req['phoneType']
  phone = req['phone']
 
  
   p creating_patient_address_phone_info(uid,patientID,addressType,addressOne,addressTwo,city,state,zipcode,phoneType,phone)
   success  =  { resp_code: '000',resp_desc: 'Patient ancillary phones Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_address_phone_info' do
  retrieve_acess = PatientAddressPhoneInfo.retrieve_patient_address_phone_info
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_patient_address_phone_info' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientAddressPhoneInfo.exists?(:uid => req['uid'])
    retrieve = PatientAddressPhoneInfo.retrieve_single_patient_address_phone_info(uid)
    puts "-----------RETRIEVING patient_address_phone_info------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No patient_address phone info  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_single_patient_address_phone_info_with_patientID' do

  request.body.rewind
  req = JSON.parse request.body.read

  patientID = req['patientID']
  if PatientAddressPhoneInfo.exists?(:patientID => req['patientID'])
    retrieve = PatientAddressPhoneInfo.retrieve_single_patient_address_phone_info_with_patientID(patientID)
    puts "-----------RETRIEVING patient_address_phone_info------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No patient_address phone info  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_patient_address_phone_info' do
  puts "------------------UPDATING payments API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   uid = req['uid']
  patientID = req['patientID']
  addressType = req['addressType']
  addressOne = req['addressOne']
  addressTwo = req['addressTwo']
  city = req['city']
  state = req['state']
  zipcode = req['zipcode']
  phoneType = req['phoneType']
  phone = req['phone']
    
      if PatientAddressPhoneInfo.exists?(:uid => req['uid'])
    get_update_patient_address_phone_info(uid,patientID,addressType,addressOne,addressTwo,city,state,zipcode,phoneType,phone)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated patient address phone info!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_address_phone_info' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientAddressPhoneInfo.exists?(:uid => req['uid'])

    PatientAddressPhoneInfo.where(uid: uid).destroy_all
    puts "-----------DELETING PatientAddressPhoneInfo------------------"
    del = [{resp_code: '000', resp_desc: 'PatientAddressPhoneInfo' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Address Phone Info found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





 # CREATE TABLE `payer_settings` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `payerUrl` varchar(255) DEFAULT NULL,
 #  `startDate` varchar(255) DEFAULT NULL,
 #  `endDate` varchar(255) DEFAULT NULL,
 #  `lastBilledDay` varchar(255) DEFAULT NULL,
 #  `nextBillingDay` varchar(255) DEFAULT NULL,
 #  `holdBillingDate` varchar(255) DEFAULT NULL,
 #  `processThroughDate` varchar(255) DEFAULT NULL,
 #  `reportingGroup` varchar(255) DEFAULT NULL,
 #  `dayOfTheMonth` varchar(255) DEFAULT NULL,
 #  `overrideWeekendingDate` varchar(255) DEFAULT NULL,
 #  `restrictPayer` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`)

    ### physician_notes URL  START
post '/create_payer_settings' do
  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  startDate = req['startDate']
  endDate = req['endDate']
  lastBilledDay = req['lastBilledDay']
  nextBillingDay = req['nextBillingDay']
  holdBillingDate = req['holdBillingDate']
  processThroughDate = req['processThroughDate']
  reportingGroup = req['reportingGroup']
  dayOfTheMonth = req['dayOfTheMonth']
  overrideWeekendingDate = req['overrideWeekendingDate']
  restrictPayer = req['restrictPayer']
 
  
   p creating_payer_settings(payerUrl,startDate,endDate,lastBilledDay,nextBillingDay,holdBillingDate,processThroughDate,
    reportingGroup,dayOfTheMonth,overrideWeekendingDate,restrictPayer)
   success  =  { resp_code: '000',resp_desc: 'Payer settings Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_settings' do
  retrieve_acess = PayerSettings.retrieve_payer_settings
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_payer_settings' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerSettings.exists?(:id => req['id'])
    retrieve = PayerSettings.retrieve_single_payer_settings(id)
    puts "-----------RETRIEVING payer_settings------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer settings  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_single_payer_settings_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerSettings.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerSettings.retrieve_single_payer_settings_payerUrl(payerUrl)
    puts "-----------RETRIEVING payer_settings------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer settings  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_payer_settings' do
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
     payerUrl = req['payerUrl']
  startDate = req['startDate']
  endDate = req['endDate']
  lastBilledDay = req['lastBilledDay']
  nextBillingDay = req['nextBillingDay']
  holdBillingDate = req['holdBillingDate']
  processThroughDate = req['processThroughDate']
  reportingGroup = req['reportingGroup']
  dayOfTheMonth = req['dayOfTheMonth']
  overrideWeekendingDate = req['overrideWeekendingDate']
  restrictPayer = req['restrictPayer']
    
      if PayerSettings.exists?(:id => req['id'])
    get_update_payer_settings(id,payerUrl,startDate,endDate,lastBilledDay,nextBillingDay,holdBillingDate,processThroughDate,
    reportingGroup,dayOfTheMonth,overrideWeekendingDate,restrictPayer)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated payer settings!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_settings' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerSettings.exists?(:id => req['id'])

    PayerSettings.where(id: id).destroy_all
    puts "-----------DELETING PayerSettings------------------"
    del = [{resp_code: '000', resp_desc: 'Payer Settings Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Settings found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





 # CREATE TABLE `payer_ContactInfo` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `payerUrl` varchar(255) DEFAULT NULL,
 #  `addressType` varchar(255) DEFAULT NULL,
 #  `address1` varchar(255) DEFAULT NULL,
 #  `address2` varchar(255) DEFAULT NULL,
 #  `city` varchar(255) DEFAULT NULL,
 #  `state` varchar(255) DEFAULT NULL,
 #  `zip` varchar(255) DEFAULT NULL,
 #  `addressPhoneInfoPhones` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`)


    ### physician_notes URL  START
post '/create_payer_ContactInfo' do
  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']

 
  
   p creating_payer_ContactInfo(payerUrl,addressType,address1,address2,city,state,zip,
    addressPhoneInfoPhones)
   success  =  { resp_code: '000',resp_desc: 'payer ContactInfo Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_ContactInfo' do
  retrieve_acess = PayerContactInfo.retrieve_payer_ContactInfo
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_payer_ContactInfo' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerContactInfo.exists?(:id => req['id'])
    retrieve = PayerContactInfo.retrieve_single_payer_ContactInfo(id)
    puts "-----------RETRIEVING payer_ContactInfo------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer ContactInfo  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/retrieve_single_payer_ContactInfo_with_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerContactInfo.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerContactInfo.retrieve_single_payer_ContactInfo_with_payerUrl(payerUrl)
    puts "-----------RETRIEVING payer_ContactInfo------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer ContactInfo  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_payer_ContactInfo' do
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
   payerUrl = req['payerUrl']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']
    
      if PayerContactInfo.exists?(:id => req['id'])
    get_update_payer_ContactInfo(id,payerUrl,addressType,address1,address2,city,state,zip,
    addressPhoneInfoPhones)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated payer ContactInfo!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_ContactInfo' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerContactInfo.exists?(:id => req['id'])

    PayerContactInfo.where(id: id).destroy_all
    puts "-----------DELETING PayerContactInfo------------------"
    del = [{resp_code: '000', resp_desc: 'Payer ContactInfo Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer ContactInfo found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





  # CREATE TABLE `payer_Contacts` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `payerUrl` varchar(255) DEFAULT NULL,
  # `contactName` varchar(255) DEFAULT NULL,
  # `contactEmail` varchar(255) DEFAULT NULL,
  # `department` varchar(255) DEFAULT NULL,
  # `addressPhoneInfoPhones` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


    ### physician_notes URL  START
post '/create_payer_Contacts' do
  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  contactName = req['contactName']
  contactEmail = req['contactEmail']
  department = req['department']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']

 
  
   p creating_payer_Contacts(payerUrl,contactName,contactEmail,department,
    addressPhoneInfoPhones)
   success  =  { resp_code: '000',resp_desc: 'payer Contacts Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_Contacts' do
  retrieve_acess = PayerContacts.retrieve_payer_Contacts
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_payer_Contact' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerContacts.exists?(:id => req['id'])
    retrieve = PayerContacts.retrieve_single_payer_Contacts(id)
    puts "-----------RETRIEVING payer_Contacts------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer Contacts  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_single_payer_Contact_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerContacts.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerContacts.retrieve_single_payer_Contacts_payerUrl(payerUrl)
    puts "-----------RETRIEVING payer_Contacts------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer Contacts  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_payer_Contact' do
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
   payerUrl = req['payerUrl']
  contactName = req['contactName']
  contactEmail = req['contactEmail']
  department = req['department']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']
 
    
      if PayerContacts.exists?(:id => req['id'])
    get_update_payer_Contacts(id,payerUrl,contactName,contactEmail,department,
    addressPhoneInfoPhones)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated payer Contact!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_Contact' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerContacts.exists?(:id => req['id'])

    PayerContacts.where(id: id).destroy_all
    puts "-----------DELETING PayerContactInfo------------------"
    del = [{resp_code: '000', resp_desc: 'Payer Contact Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Contact found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end











  # CREATE TABLE `payer` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `payerName` varchar(255) DEFAULT NULL,
  # `payerCategory` varchar(255) DEFAULT NULL,
  # `oasisCategory` varchar(255) DEFAULT NULL,
  # `claimFilingType` varchar(255) DEFAULT NULL,
  # `invoiceType` varchar(255) DEFAULT NULL,
  # `invoiceCycle` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `payerEmail` varchar(255) DEFAULT NULL,
  # `applySalesTax` varchar(255) DEFAULT NULL,
  # `updated` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)


    ### physician_notes URL  START
post '/create_payer' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  payerName = req['payerName']
  payerCategory = req['payerCategory']
  oasisCategory = req['oasisCategory']
  claimFilingType = req['claimFilingType']
  invoiceType = req['invoiceType']
  invoiceCycle = req['invoiceCycle']
  startDate = req['startDate']
  endDate = req['endDate']
  payerEmail = req['payerEmail']
  applySalesTax = req['applySalesTax']
  updated = req['updated']
    url = req['url']

 
  
   p creating_payer(organizationUrl,payerName,payerCategory,oasisCategory,
    claimFilingType,invoiceType,invoiceCycle,startDate,endDate,payerEmail,applySalesTax,updated,url)
   success  =  { resp_code: '000',resp_desc: 'payer Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer' do
  retrieve_acess = Payer.retrieve_payer
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_payer' do

  request.body.rewind
  req = JSON.parse request.body.read

  url = req['url']
  if Payer.exists?(:url => req['url'])
    retrieve = Payer.retrieve_single_payer(url)
    puts "-----------RETRIEVING payer ------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_single_payer_with_org_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if Payer.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = Payer.retrieve_single_payer_with_org_url(organizationUrl)
    puts "-----------RETRIEVING payer ------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_payer' do
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
 organizationUrl = req['organizationUrl']
  payerName = req['payerName']
  payerCategory = req['payerCategory']
  oasisCategory = req['oasisCategory']
  claimFilingType = req['claimFilingType']
  invoiceType = req['invoiceType']
  invoiceCycle = req['invoiceCycle']
  startDate = req['startDate']
  endDate = req['endDate']
  payerEmail = req['payerEmail']
  applySalesTax = req['applySalesTax']
  updated = req['updated']
   url = req['url']
 
    
      if Payer.exists?(:id => req['id'])
    get_update_payer(id,organizationUrl,payerName,payerCategory,oasisCategory,
    claimFilingType,invoiceType,invoiceCycle,startDate,endDate,payerEmail,applySalesTax,updated,url)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated payer!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Payer.exists?(:id => req['id'])

    Payer.where(id: id).destroy_all
    puts "-----------DELETING PayerContactInfo------------------"
    del = [{resp_code: '000', resp_desc: 'Payer Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




  # CREATE TABLE `payer_ancillary_phone` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `payerUrl` varchar(255) DEFAULT NULL,
  # `phoneType` varchar(255) DEFAULT NULL,
  # `phone` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### ancillaryPhoneInfo NOTE START
post '/create_payer_ancillary_phone' do
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  payerUrl = req['payerUrl']
  phoneType = req['phoneType']
  phone = req['phone']
  description = req['description']
  


  if phoneType.length < 1 
     halt PHONE_TYPE_ERR.to_json
   elsif phone.length< 1
      halt PHONE_ERR.to_json
  
   end
  

   p creating_payer_ancillary_phone(uid,payerUrl,phoneType,phone,description)

   success  =  { resp_code: '000',resp_desc: 'payer ancillary phone Successfully created'} 
   return success.to_json 
     
end





get '/retrieve_all_payer_ancillary_phone' do
  retrieve_acess = PayerAncillaryPhone.retrieve_payer_ancillary_phone
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payer_ancillary_phone' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PayerAncillaryPhone.exists?(:uid => req['uid'])
    retrieve = PayerAncillaryPhone.retrieve_single_payer_ancillary_phone(uid)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer ancillary phone found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/retrieve_payer_ancillary_phone_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerAncillaryPhone.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerAncillaryPhone.retrieve_single_payer_ancillary_phone_payerUrl(payerUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer ancillary phone found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_payer_ancillary_phone' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  payerUrl = req['payerUrl']
  phoneType = req['phoneType']
  phone = req['phone']
  description = req['description']
    
     if PayerAncillaryPhone.exists?(:uid => req['uid'])
    get_update_PayerAncillaryPhone(uid,payerUrl,phoneType,phone,description)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated PayerAncillaryPhone!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_PayerAncillaryPhone' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PayerAncillaryPhone.exists?(:uid => req['uid'])

    PayerAncillaryPhone.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'PayerAncillaryPhone Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No PayerAncillaryPhone found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end







  # CREATE TABLE `patient_notes` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `note` varchar(255) DEFAULT NULL,
  # `noteType` varchar(255) DEFAULT NULL,
  # `noteBy` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### ancillaryPhoneInfo NOTE START
post '/create_patient_notes' do
  request.body.rewind
  req = JSON.parse request.body.read

uid = req['uid']
  note = req['note']
  noteType = req['noteType']
  noteBy = req['noteBy']
  patientID = req['patientID']


   p creating_patient_notes(uid,note,noteType,noteBy,patientID)

   success  =  { resp_code: '000',resp_desc: 'patient_notes Successfully created'} 
   return success.to_json 
     
end





get '/retrieve_all_patient_notes' do
  retrieve_acess = PatientNotes.retrieve_patient_notes
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_notes' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientNotes.exists?(:uid => req['uid'])
    retrieve = PatientNotes.retrieve_single_patient_notes(uid)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No patient notes found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_patient_notes' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
note = req['note']
  noteType = req['noteType']
  noteBy = req['noteBy']
  patientID = req['patientID']
    
     if PatientNotes.exists?(:uid => req['uid'])
    get_update_patient_notes(uid,note,noteType,noteBy,patientID)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated patient notes!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_notes' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientNotes.exists?(:uid => req['uid'])

    PatientNotes.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Patient Notes Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Notes found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 










  # CREATE TABLE `patient_contacts` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `patientID` varchar(255) DEFAULT NULL,
  # `relationship` varchar(255) DEFAULT NULL,
  # `contactType` varchar(255) DEFAULT NULL,
  # `firstName` varchar(255) DEFAULT NULL,
  # `lastName` varchar(255) DEFAULT NULL,
  # `dateOfBirth` varchar(255) DEFAULT NULL,
  # `sequence` varchar(255) DEFAULT NULL,
  # `email` varchar(255) DEFAULT NULL,
  # `misc` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### ancillaryPhoneInfo NOTE START
post '/create_patient_contacts' do
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  patientID = req['patientID']
  relationship = req['relationship']
  contactType = req['contactType']
  firstName = req['firstName']
  lastName = req['lastName']
  dateOfBirth = req['dateOfBirth']
  sequence = req['sequence']
  email = req['email']
  misc = req['misc']


   p creating_patient_contacts(uid,patientID,relationship,contactType,firstName,lastName,dateOfBirth,sequence,email,misc)

   success  =  { resp_code: '000',resp_desc: 'patient_notes Successfully created'} 
   return success.to_json 
     
end





get '/retrieve_all_patient_contacts' do
  retrieve_acess = PatientContacts.retrieve_patient_contacts
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_contacts' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientContacts.exists?(:uid => req['uid'])
    retrieve = PatientContacts.retrieve_single_patient_contacts(uid)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Contacts found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_patient_contacts' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
   patientID = req['patientID']
  relationship = req['relationship']
  contactType = req['contactType']
  firstName = req['firstName']
  lastName = req['lastName']
  dateOfBirth = req['dateOfBirth']
  sequence = req['sequence']
  email = req['email']
  misc = req['misc']
    
     if PatientContacts.exists?(:uid => req['uid'])
    get_update_patient_contacts(uid,patientID,relationship,contactType,firstName,lastName,dateOfBirth,sequence,email,misc)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated patient notes!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_contacts' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientContacts.exists?(:uid => req['uid'])

    PatientContacts.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Patient Contacts Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Contacts found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 







  # CREATE TABLE `referral_source_contacts` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `firstName` varchar(255) DEFAULT NULL,
  # `lastName` varchar(255) DEFAULT NULL,
  # `middleName` varchar(255) DEFAULT NULL,
  # `email` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `phoneOne` varchar(255) DEFAULT NULL,
  # `phoneTwo` varchar(255) DEFAULT NULL,
  # `phoneOneType` varchar(255) DEFAULT NULL,
  # `phoneTwoType` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_referral_source_contacts' do
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  firstName = req['firstName']
  lastName = req['lastName']
  middleName = req['middleName']
  email = req['email']
  startDate = req['startDate']
  phoneOne = req['phoneOne']
  phoneTwo = req['phoneTwo']
  phoneOneType = req['phoneOneType']
  phoneTwoType = req['phoneTwoType']
  referralSourceID = req['referralSourceID']
  organizationUrl = req['organizationUrl']
  information = req['information']


   p creating_referral_source_contacts(uid,firstName,lastName,middleName,email,startDate,phoneOne,phoneTwo,phoneOneType,phoneTwoType,referralSourceID,organizationUrl,information)

   success  =  { resp_code: '000',resp_desc: 'referral_source_contacts Successfully created'} 
   return success.to_json 
     
end





get '/retrieve_all_referral_source_contacts' do
  retrieve_acess = ReferralSourceContact.retrieve_referral_source_contacts
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_referral_source_contacts' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if ReferralSourceContact.exists?(:uid => req['uid'])
    retrieve = ReferralSourceContact.retrieve_single_referral_source_contacts(uid)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No referral source contacts found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_single_referral_source_contacts_with_org_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if ReferralSourceContact.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = ReferralSourceContact.retrieve_single_referral_source_contacts_with_org_url(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No referral source contacts found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_single_referral_source_contacts_with_referralSourceID' do

  request.body.rewind
  req = JSON.parse request.body.read

  referralSourceID = req['referralSourceID']
  if ReferralSourceContact.exists?(:referralSourceID => req['referralSourceID'])
    retrieve = ReferralSourceContact.retrieve_single_referral_source_contacts_with_referralSourceID(referralSourceID)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No referral source contacts found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_referral_source_contacts' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  firstName = req['firstName']
  lastName = req['lastName']
  middleName = req['middleName']
  email = req['email']
  startDate = req['startDate']
  phoneOne = req['phoneOne']
  phoneTwo = req['phoneTwo']
  phoneOneType = req['phoneOneType']
  phoneTwoType = req['phoneTwoType']
  referralSourceID = req['referralSourceID']
  organizationUrl = req['organizationUrl']
  information = req['information']
    
     if ReferralSourceContact.exists?(:uid => req['uid'])
    get_update_referral_source_contacts(uid,firstName,lastName,middleName,email,startDate,phoneOne,phoneTwo,phoneOneType,phoneTwoType,referralSourceID,organizationUrl,information)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated referral_source_contacts!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_referral_source_contacts' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if ReferralSourceContact.exists?(:uid => req['uid'])

    ReferralSourceContact.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Referral Source Contact Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Referral Source Contact found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 






  # CREATE TABLE `associate_medical_compliance` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `associateUrl` varchar(255) DEFAULT NULL,
  # `comment` varchar(255) DEFAULT NULL,
  # `completed` varchar(255) DEFAULT NULL,
  # `complianceType` varchar(255) DEFAULT NULL,
  # `compliant` tinyint(1) DEFAULT NULL,
  # `item` varchar(255) DEFAULT NULL,
  # `lastModifiedBy` varchar(255) DEFAULT NULL,
  # `lastModifiedByDate` varchar(255) DEFAULT NULL,
  # `narrative` varchar(255) DEFAULT NULL,
  # `notNeeded` tinyint(1) DEFAULT NULL,
  # `renewal` varchar(255) DEFAULT NULL,
  # `result` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_associate_medical_compliance' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  comment = req['comment']
  completed = req['completed']
  complianceType = req['complianceType']
  compliant = req['compliant']
  item = req['item']
  lastModifiedBy = req['lastModifiedBy']
  lastModifiedByDate = req['lastModifiedByDate']
  narrative = req['narrative']
  notNeeded = req['notNeeded']
  renewal = req['renewal']
  result = req['result']


   p creating_associate_medical_compliance(associateUrl,comment,completed,complianceType,compliant,item,lastModifiedBy,lastModifiedByDate,narrative,notNeeded,renewal,result)

   success  =  { resp_code: '000',resp_desc: 'associate_medical_compliance Successfully created'} 
   return success.to_json 
     
end





get '/retrieve_all_associate_medical_compliance' do
  retrieve_acess = AssociateMedicalCompliance.retrieve_associate_medical_compliance
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_associate_medical_compliance' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssociateMedicalCompliance.exists?(:id => req['id'])
    retrieve = AssociateMedicalCompliance.retrieve_single_associate_medical_compliance(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Associate Medical Compliance found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_associate_medical_compliance_with_ass_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if AssociateMedicalCompliance.exists?(:associateUrl => req['associateUrl'])
    retrieve = AssociateMedicalCompliance.retrieve_single_associate_medical_compliance_with_ass_url(associateUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Associate Medical Compliance found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_associate_medical_compliance' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
    associateUrl = req['associateUrl']
  comment = req['comment']
  completed = req['completed']
  complianceType = req['complianceType']
  compliant = req['compliant']
  item = req['item']
  lastModifiedBy = req['lastModifiedBy']
  lastModifiedByDate = req['lastModifiedByDate']
  narrative = req['narrative']
  notNeeded = req['notNeeded']
  renewal = req['renewal']
  result = req['result']
    
     if AssociateMedicalCompliance.exists?(:id => req['id'])
    get_update_associate_medical_compliance(id,associateUrl,comment,completed,complianceType,compliant,item,lastModifiedBy,lastModifiedByDate,narrative,notNeeded,renewal,result)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Associate Medical Compliance!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_associate_medical_compliance' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssociateMedicalCompliance.exists?(:id => req['id'])

    AssociateMedicalCompliance.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Associate Medical Compliance Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Associate Medical Compliance found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




 # CREATE TABLE `associate_reports` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `associateUrl` varchar(255) DEFAULT NULL,
 #  `reportName` varchar(255) DEFAULT NULL,
 #  `startDate` varchar(255) DEFAULT NULL,
 #  `endDate` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_associate_reports' do
  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  reportName = req['reportName']
  startDate = req['startDate']
  endDate = req['endDate']

   p creating_associate_reports(associateUrl,reportName,startDate,endDate)

   success  =  { resp_code: '000',resp_desc: 'associate_reports Successfully created'} 
   return success.to_json 
     
end





get '/retrieve_all_associate_reports' do
  retrieve_acess = AssociateReport.retrieve_associate_reports
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_associate_reports' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssociateReport.exists?(:id => req['id'])
    retrieve = AssociateReport.retrieve_single_associate_reports(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Associate Report found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_associate_reports_with_ass_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  associateUrl = req['associateUrl']
  if AssociateReport.exists?(:associateUrl => req['associateUrl'])
    retrieve = AssociateReport.retrieve_single_associate_reports_with_ass_url(associateUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Associate Report found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_associate_reports' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   associateUrl = req['associateUrl']
  reportName = req['reportName']
  startDate = req['startDate']
  endDate = req['endDate']
    
     if AssociateReport.exists?(:id => req['id'])
    get_update_associate_reports(id,associateUrl,reportName,startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Associate Report!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_associate_reports' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssociateReport.exists?(:id => req['id'])

    AssociateReport.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Associate Report Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Associate Medical Compliance found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 






 # CREATE TABLE `payer_form` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `payerUrl` varchar(255) DEFAULT NULL,
 #  `automatedFormType` varchar(255) DEFAULT NULL,
 #  `uploadDocumentType` varchar(255) DEFAULT NULL,
 #  `startDate` varchar(255) DEFAULT NULL,
 #  `endDate` varchar(255) DEFAULT NULL,
 #   `orderToRecheck` tinyint(1) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))



### create_payer_form START
post '/create_payer_form' do
  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  automatedFormType = req['automatedFormType']
  uploadDocumentType = req['uploadDocumentType']
  orderToRecheck = req['orderToRecheck']
  startDate = req['startDate']
  endDate = req['endDate']

   p creating_payer_form(payerUrl,automatedFormType,uploadDocumentType,orderToRecheck,startDate,endDate)

   success  =  { resp_code: '000',resp_desc: 'payer_form Successfully created'} 
   return success.to_json 
     
end





get '/retrieve_all_payer_form' do
  retrieve_acess = PayerForm.retrieve_payer_form
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payer_form' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerForm.exists?(:id => req['id'])
    retrieve = PayerForm.retrieve_single_payer_form(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Form found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_payer_form_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerForm.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerForm.retrieve_single_payer_form_payerUrl(payerUrl)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Form found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_payer_form' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   payerUrl = req['payerUrl']
  automatedFormType = req['automatedFormType']
  uploadDocumentType = req['uploadDocumentType']
  orderToRecheck = req['orderToRecheck']
  startDate = req['startDate']
  endDate = req['endDate']
    
     if PayerForm.exists?(:id => req['id'])
    get_update_payer_form(id,payerUrl,automatedFormType,uploadDocumentType,orderToRecheck,startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated PayerForm!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_form' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerForm.exists?(:id => req['id'])

    PayerForm.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Payer Form Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Form found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





 # CREATE TABLE `payer_rules` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `payerUrl` varchar(255) DEFAULT NULL,
 #  `rule` varchar(255) DEFAULT NULL,
 #  `description` varchar(255) DEFAULT NULL,
 #  `startDate` varchar(255) DEFAULT NULL,
 #  `endDate` varchar(255) DEFAULT NULL,
 #   `groupCode`  varchar(255) DEFAULT NULL,
 #   `modifiedBy` varchar(255) DEFAULT NULL,
 #   `modifiedDate` varchar(255) DEFAULT NULL,
 #    `createdDate` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))



### create_payer_form START
post '/create_payer_rules' do
  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  rule = req['rule']
  description = req['description']
  groupCode = req['groupCode']
  modifiedBy = req['modifiedBy']
  modifiedDate = req['modifiedDate']
  createdDate = req['createdDate']
  startDate = req['startDate']
  endDate = req['endDate']

   p creating_payer_rules(payerUrl,rule,description,groupCode,modifiedBy,modifiedDate,createdDate,startDate,endDate)

   success  =  { resp_code: '000',resp_desc: 'payer rules Successfully created'} 
   return success.to_json 
     
end





get '/retrieve_all_payer_rules' do
  retrieve_acess = PayerRule.retrieve_payer_rules
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payer_rules' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerRule.exists?(:id => req['id'])
    retrieve = PayerRule.retrieve_single_payer_rules(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Rule found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_payer_rules_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerRule.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerRule.retrieve_single_payer_rules_payerUrl(payerUrl)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Rule found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_payer_rules' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
    payerUrl = req['payerUrl']
  rule = req['rule']
  description = req['description']
  groupCode = req['groupCode']
  modifiedBy = req['modifiedBy']
  modifiedDate = req['modifiedDate']
  createdDate = req['createdDate']
  startDate = req['startDate']
  endDate = req['endDate']
    
     if PayerRule.exists?(:id => req['id'])
    get_update_payer_rules(id,payerUrl,rule,description,groupCode,modifiedBy,modifiedDate,createdDate,startDate,endDate)
   
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Payer Form!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_rules' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerRule.exists?(:id => req['id'])

    PayerRule.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Payer Rule Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Rule found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 






 # CREATE TABLE `payer_documents` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `payerUrl` varchar(255) DEFAULT NULL,
 #  `file` varchar(255) DEFAULT NULL,
 #  `documentType` varchar(255) DEFAULT NULL,
 #  `documentStatus` varchar(255) DEFAULT NULL,
 #  `description` varchar(255) DEFAULT NULL,
 #  `note`  varchar(255) DEFAULT NULL,
 #  `uploadedBy` varchar(255) DEFAULT NULL,
 #  `uploadedDate` varchar(255) DEFAULT NULL,
 #  `attachTo` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))



### create_payer_documents START
post '/create_payer_documents' do
  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  file = req['file']
  documentType = req['documentType']
  documentStatus = req['documentStatus']
  description = req['description']
  note = req['note']
  uploadedBy = req['uploadedBy']
  uploadedDate = req['uploadedDate']
  attachTo = req['attachTo']

   p creating_payer_documents(payerUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate,attachTo)

   success  =  { resp_code: '000',resp_desc: 'payer documents Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_documents' do
  retrieve_acess = PayerDocuments.retrieve_payer_documents
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payer_documents' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerDocuments.exists?(:id => req['id'])
    retrieve = PayerDocuments.retrieve_single_payer_documents(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer documents found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_payer_documents_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerDocuments.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerDocuments.retrieve_single_payer_documents_payerUrl(payerUrl)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer documents found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_payer_documents' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  payerUrl = req['payerUrl']
  file = req['file']
  documentType = req['documentType']
  documentStatus = req['documentStatus']
  description = req['description']
  note = req['note']
  uploadedBy = req['uploadedBy']
  uploadedDate = req['uploadedDate']
  attachTo = req['attachTo']
    
     if PayerDocuments.exists?(:id => req['id'])
    get_update_payer_documents(id,payerUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate,attachTo)
   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated payer documents!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_document' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerDocuments.exists?(:id => req['id'])

    PayerDocuments.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Payer Documents Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Documents found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




 # CREATE TABLE `payer_bill_rates` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `payerUrl` varchar(255) DEFAULT NULL,
 #  `serviceCategory` varchar(255) DEFAULT NULL,
 #  `service` varchar(255) DEFAULT NULL,
 #  `description` varchar(255) DEFAULT NULL,
 #  `unitOfMeasure` varchar(255) DEFAULT NULL,
 #  `payerRate`  varchar(255) DEFAULT NULL,
 #  `allowOverride` varchar(255) DEFAULT NULL,
 #  `startDate` varchar(255) DEFAULT NULL,
 #  `revenueCode` varchar(255) DEFAULT NULL,
 #  `hcpcCode` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))

# agency
#  serviceType: string
#             assessment: string
#             endDate: date(mm/dd/yyyy)
#             useAgencyChargeAmount: boolean
#             chargeAmount: string
#             payerRate: number
#             hcpcModifier1: string
#             hcpcModifier2: string
#             hcpcModifier3: string
#             hcpcModifier4: string
#             treatmentCodeNeeded: boolean
#             unitMultiplier: string
#             incrementalBillingCode: string
#             incrementalBillingRate: string
#             sendBillingDescriptionForEdit: boolean
#             evvProgram: string
#             evvGroupedProcedureCode: string
#             lastUpdated: date(mm/dd/yyyy)
#             createdAt: date(mm/dd/yyyy),
#             modifyUser: string,



### create_payer_documents START
post '/create_payer_bill_rates' do
  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  serviceCategory = req['serviceCategory']
  service = req['service']
  description = req['description']
  unitOfMeasure = req['unitOfMeasure']
  payerRate = req['payerRate']
  allowOverride = req['allowOverride']
  startDate = req['startDate']
  revenueCode = req['revenueCode']
  hcpcCode = req['hcpcCode']
  agency = req['agency']
  assessment = req['assessment']
  endDate = req['endDate']
  useAgencyChargeAmount = req['useAgencyChargeAmount']
  chargeAmount = req['chargeAmount']
  serviceType = req['serviceType']
  hcpcModifier1 = req['hcpcModifier1']
  hcpcModifier2 = req['hcpcModifier2']
  hcpcModifier3 = req['hcpcModifier3']
  hcpcModifier4 = req['hcpcModifier4']
  treatmentCodeNeeded = req['treatmentCodeNeeded']
  unitMultiplier = req['unitMultiplier']
  incrementalBillingCode = req['incrementalBillingCode']
  sendBillingDescriptionForEdit = req['sendBillingDescriptionForEdit']
  evvProgram = req['evvProgram']
  evvGroupedProcedureCode = req['evvGroupedProcedureCode']
  lastUpdated = req['lastUpdated']
   modifyUser = req['modifyUser']


   p creating_payer_bill_rates(payerUrl,serviceCategory,service,description,unitOfMeasure,payerRate,allowOverride,startDate,revenueCode,hcpcCode,
    agency,assessment,endDate,useAgencyChargeAmount,chargeAmount,serviceType,hcpcModifier1,hcpcModifier2,hcpcModifier3,hcpcModifier4,
    treatmentCodeNeeded,unitMultiplier,incrementalBillingCode,sendBillingDescriptionForEdit,evvProgram,evvGroupedProcedureCode,lastUpdated,modifyUser)

   success  =  { resp_code: '000',resp_desc: 'payer bill rates Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_bill_rates' do
  retrieve_acess = PayerBillRates.retrieve_payer_bill_rates
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payer_bill_rates' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerBillRates.exists?(:id => req['id'])
    retrieve = PayerBillRates.retrieve_single_payer_bill_rates(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer bill rates found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/retrieve_payer_bill_rates_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerBillRates.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerBillRates.retrieve_single_payer_bill_rates_payerUrl(payerUrl)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer bill rates found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_payer_bill_rates' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  payerUrl = req['payerUrl']
  serviceCategory = req['serviceCategory']
  service = req['service']
  description = req['description']
  unitOfMeasure = req['unitOfMeasure']
  payerRate = req['payerRate']
  allowOverride = req['allowOverride']
  startDate = req['startDate']
  revenueCode = req['revenueCode']
  hcpcCode = req['hcpcCode']
  agency = req['agency']
  assessment = req['assessment']
  endDate = req['endDate']
  useAgencyChargeAmount = req['useAgencyChargeAmount']
  chargeAmount = req['chargeAmount']
  serviceType = req['serviceType']
  hcpcModifier1 = req['hcpcModifier1']
  hcpcModifier2 = req['hcpcModifier2']
  hcpcModifier3 = req['hcpcModifier3']
  hcpcModifier4 = req['hcpcModifier4']
  treatmentCodeNeeded = req['treatmentCodeNeeded']
  unitMultiplier = req['unitMultiplier']
  incrementalBillingCode = req['incrementalBillingCode']
  sendBillingDescriptionForEdit = req['sendBillingDescriptionForEdit']
  evvProgram = req['evvProgram']
  evvGroupedProcedureCode = req['evvGroupedProcedureCode']
  lastUpdated = req['lastUpdated']
   modifyUser = req['modifyUser']
    
     if PayerBillRates.exists?(:id => req['id'])
    get_update_payer_bill_rates(id,payerUrl,serviceCategory,service,description,unitOfMeasure,payerRate,allowOverride,startDate,revenueCode,hcpcCode,
    agency,assessment,endDate,useAgencyChargeAmount,chargeAmount,serviceType,hcpcModifier1,hcpcModifier2,hcpcModifier3,hcpcModifier4,
    treatmentCodeNeeded,unitMultiplier,incrementalBillingCode,sendBillingDescriptionForEdit,evvProgram,evvGroupedProcedureCode,lastUpdated,modifyUser)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated payer bill rates!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_bill_rates' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerBillRates.exists?(:id => req['id'])

    PayerBillRates.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Payer Bill Rates Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Bill Rates found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 






### payer_requirements START
post '/create_payer_requirements' do
  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  generalReq_patientLevelOverride = req['generalReq_patientLevelOverride']
  authorizationHash = req['authorizationHash']
  byDiscipline = req['byDiscipline']
  byServiceCode = req['byServiceCode']
  byVisits = req['byVisits']
  byHours = req['byHours']
  byAmount = req['byAmount']
  clinicalReq_patientLevelOverride = req['clinicalReq_patientLevelOverride']
  oasis = req['oasis']
  certificationPeriodDays = req['certificationPeriodDays']
  noticeOfElection = req['noticeOfElection']
  noticeOfAdmission = req['noticeOfAdmission']
  assessmentVisits = req['assessmentVisits']
  physiciansOrders = req['physiciansOrders']
  clinicalNotes = req['clinicalNotes']
  copayRep_patientLevelOverride = req['copayRep_patientLevelOverride']
  copayType = req['copayType']
  copaySplit = req['copaySplit']
  billOvertime = req['billOvertime']
  miscBilling = req['miscBilling']
  eligibleRequirement = req['eligibleRequirement']
  insuredInformation = req['insuredInformation']
  invoiceTypeOverride = req['invoiceTypeOverride']
  invoiceFrequencyOverride = req['invoiceFrequencyOverride']
  patientLevelOverride = req['patientLevelOverride']
  serviceDescription = req['serviceDescription']


   p creating_payer_requirements(payerUrl,generalReq_patientLevelOverride,authorizationHash,byDiscipline,
    byServiceCode,byVisits,byHours,byAmount,clinicalReq_patientLevelOverride,oasis,certificationPeriodDays,
   noticeOfElection,noticeOfAdmission, assessmentVisits,physiciansOrders,clinicalNotes,copayRep_patientLevelOverride,
   copayType,copaySplit,billOvertime,miscBilling,eligibleRequirement,insuredInformation,invoiceTypeOverride,invoiceFrequencyOverride,patientLevelOverride,serviceDescription)

   success  =  { resp_code: '000',resp_desc: 'payer requirements Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_requirements' do
  retrieve_acess = PayerRequirements.retrieve_payer_requirements
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payer_requirements' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerRequirements.exists?(:id => req['id'])
    retrieve = PayerRequirements.retrieve_single_payer_requirements(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer requirements found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_single_payer_requirements_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerRequirements.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerRequirements.retrieve_single_payer_requirements_payerUrl(payerUrl)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No payer requirements found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_payer_requirements' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  payerUrl = req['payerUrl'] 
  generalReq_patientLevelOverride = req['generalReq_patientLevelOverride']
  authorizationHash = req['authorizationHash']
  byDiscipline = req['byDiscipline']
  byServiceCode = req['byServiceCode']
  byVisits = req['byVisits']
  byHours = req['byHours']
  byAmount = req['byAmount']
  clinicalReq_patientLevelOverride = req['clinicalReq_patientLevelOverride']
  oasis = req['oasis']
  certificationPeriodDays = req['certificationPeriodDays']
  noticeOfElection = req['noticeOfElection']
  noticeOfAdmission = req['noticeOfAdmission']
  assessmentVisits = req['assessmentVisits']
  physiciansOrders = req['physiciansOrders']
  clinicalNotes = req['clinicalNotes']
  copayRep_patientLevelOverride = req['copayRep_patientLevelOverride']
  copayType = req['copayType']
  copaySplit = req['copaySplit']
  billOvertime = req['billOvertime']
  miscBilling = req['miscBilling']
  eligibleRequirement = req['eligibleRequirement']
  insuredInformation = req['insuredInformation']
  invoiceTypeOverride = req['invoiceTypeOverride']
  invoiceFrequencyOverride = req['invoiceFrequencyOverride']
  patientLevelOverride = req['patientLevelOverride']
   serviceDescription = req['serviceDescription']
    
     if PayerRequirements.exists?(:id => req['id'])
    get_update_payer_requirements(id,payerUrl,generalReq_patientLevelOverride,authorizationHash,byDiscipline,
    byServiceCode,byVisits,byHours,byAmount,clinicalReq_patientLevelOverride,oasis,certificationPeriodDays,
   noticeOfElection,noticeOfAdmission, assessmentVisits,physiciansOrders,clinicalNotes,copayRep_patientLevelOverride,
   copayType,copaySplit,billOvertime,miscBilling,eligibleRequirement,insuredInformation,invoiceTypeOverride,invoiceFrequencyOverride,patientLevelOverride,serviceDescription)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated payer requirements!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_requirements' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerRequirements.exists?(:id => req['id'])

    PayerRequirements.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Payer Requirements Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Requirements found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




 # CREATE TABLE `patient_vendors` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `startDate` varchar(255) DEFAULT NULL,
 #  `endDate` varchar(255) DEFAULT NULL,
 #  `sequence` varchar(255) DEFAULT NULL,
 #  `prefered` varchar(255) DEFAULT NULL,
 #  `patientID` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))



### patient_vendors START
post '/create_patient_vendors' do
  request.body.rewind
  req = JSON.parse request.body.read

uid = req['uid']
  startDate = req['startDate']
  endDate = req['endDate']
  sequence = req['sequence']
  prefered = req['prefered']
  patientID = req['patientID']
  

   p creating_patient_vendors(uid,startDate,endDate,sequence,prefered,patientID)

   success  =  { resp_code: '000',resp_desc: 'Patient Vendors Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_vendors' do
  retrieve_acess = PatientVendors.retrieve_patient_vendors
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_vendors' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientVendors.exists?(:uid => req['uid'])
    retrieve = PatientVendors.retrieve_single_patient_vendors(uid)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No patient vendors found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_patient_vendors' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
 startDate = req['startDate']
  endDate = req['endDate']
  sequence = req['sequence']
  prefered = req['prefered']
  patientID = req['patientID']
    
     if PatientVendors.exists?(:uid => req['uid'])
    get_update_patient_vendors(uid,startDate,endDate,sequence,prefered,patientID)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated patient vendors!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_vendors' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientVendors.exists?(:uid => req['uid'])

    PatientVendors.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Patient Vendors Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Vendors found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




 # CREATE TABLE `patient_vaccine` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `description` varchar(255) DEFAULT NULL,
 #  `datePerformed` varchar(255) DEFAULT NULL,
 #  `patientID` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))



### patient_vendors START
post '/create_patient_vaccine' do
  request.body.rewind  
  req = JSON.parse request.body.read

  description = req['description']
  datePerformed = req['datePerformed']
  patientID = req['patientID'] 
  

   p creating_patient_vaccine(description,datePerformed,patientID)

   success  =  { resp_code: '000',resp_desc: 'Patient Vaccine Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_vaccine' do
  retrieve_acess = PatientVaccine.retrieve_patient_vaccine
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_vaccine' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PatientVaccine.exists?(:id => req['id'])
    retrieve = PatientVaccine.retrieve_single_patient_vaccine(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No patient vaccine found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_patient_vaccine' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
 description = req['description']
  datePerformed = req['datePerformed']
  patientID = req['patientID']
    
     if PatientVaccine.exists?(:id => req['id'])
    get_update_patient_vaccine(id,description,datePerformed,patientID)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated patient vaccine!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_vaccine' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PatientVaccine.exists?(:id => req['id'])

    PatientVaccine.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Patient Vaccine Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Vaccine found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





 # CREATE TABLE `patient_vital_signs` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `description` varchar(255) DEFAULT NULL,
 #  `high` varchar(255) DEFAULT NULL,
 #   `low` varchar(255) DEFAULT NULL,
 #  `patientID` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))



### patient_vendors START
post '/create_patient_vital_signs' do
  request.body.rewind  
  req = JSON.parse request.body.read



  uid = req['uid']
  description = req['description']
  high = req['high']
    low = req['low']
  patientID = req['patientID'] 
  

   p creating_patient_vital_signs(uid,description,high,low,patientID)

   success  =  { resp_code: '000',resp_desc: 'Patient Vitals Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_vital_signs' do
  retrieve_acess = PatientVitalSigns.retrieve_patient_vital_signs
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_vital_signs' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientVitalSigns.exists?(:uid => req['uid'])
    retrieve = PatientVitalSigns.retrieve_single_patient_vital_signs(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Vital Signs found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_patient_vital_signs' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  description = req['description']
  high = req['high']
    low = req['low']
  patientID = req['patientID'] 
    
     if PatientVitalSigns.exists?(:uid => req['uid'])
    get_update_patient_vital_signs(uid,description,high,low,patientID)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated patient vital signs!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_vital_signs' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientVitalSigns.exists?(:uid => req['uid'])

    PatientVitalSigns.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Patient Vital Signs Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No PatientVitalSigns found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




 # CREATE TABLE `patient_allergies` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `status` varchar(255) DEFAULT NULL,
 #  `description` varchar(255) DEFAULT NULL,
 #  `startDate` varchar(255) DEFAULT NULL,
 #   `endDate` varchar(255) DEFAULT NULL,
 #    `createdBy` varchar(255) DEFAULT NULL,
 #     `modifiedBy` varchar(255) DEFAULT NULL,
 #  `patientID` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))



### patient_vendors START
post '/create_patient_allergies' do
  request.body.rewind  
  req = JSON.parse request.body.read

  uid = req['uid']
  description = req['description']
  status = req['status']
  startDate = req['startDate']
   endDate = req['endDate']
    createdBy = req['createdBy']
     modifiedBy = req['modifiedBy']
  patientID = req['patientID'] 
  

   p creating_patient_allergies(uid,description,status,startDate,endDate,createdBy,modifiedBy,patientID)

   success  =  { resp_code: '000',resp_desc: 'Patient Allergies Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_allergies' do
  retrieve_acess = PatientAllergies.retrieve_patient_allergies
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_allergies' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientAllergies.exists?(:uid => req['uid'])
    retrieve = PatientAllergies.retrieve_single_patient_allergies(uid)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Allergies found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_patient_allergies' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  description = req['description']
  status = req['status']
  startDate = req['startDate']
   endDate = req['endDate']
    createdBy = req['createdBy']
     modifiedBy = req['modifiedBy']
  patientID = req['patientID']
    
     if PatientAllergies.exists?(:uid => req['uid'])
    get_update_patient_allergies(uid,description,status,startDate,endDate,createdBy,modifiedBy,patientID)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated patient allergies!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_allergies' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientAllergies.exists?(:uid => req['uid'])

    PatientAllergies.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: 'Patient Allergies Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No PatientAllergies found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





  #        CREATE TABLE `patients_advance_directives` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `file` varchar(255) DEFAULT NULL,
  # `attachTo` varchar(255) DEFAULT NULL,
  # `documentType` varchar(255) DEFAULT NULL,
  #  `documentStatus` varchar(255) DEFAULT NULL,
  #   `note` varchar(255) DEFAULT NULL,
  #    `description` varchar(255) DEFAULT NULL,
  # `patientID` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### patients_advance_directives START
post '/create_patients_advance_directives' do
  request.body.rewind  
  req = JSON.parse request.body.read

 uid = req['uid']
  file = req['file']
  attachTo = req['attachTo']
  documentType = req['documentType']
   documentStatus = req['endDate']
    note = req['note']
     description = req['description']
  patientID = req['patientID'] 
  

   p creating_patient_advance_directives(uid,file,attachTo,documentType,documentStatus,note,description,patientID)

   success  =  { resp_code: '000',resp_desc: 'Patient Allergies Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_advance_directives' do
  retrieve_acess = PatientAdvanceDirectives.retrieve_patient_advance_directives
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_advance_directives' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientAdvanceDirectives.exists?(:uid => req['uid'])
    retrieve = PatientAdvanceDirectives.retrieve_single_patient_advance_directives(uid)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Advance Directives found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_patient_advance_directives' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
   file = req['file']
  attachTo = req['attachTo']
  documentType = req['documentType']
   documentStatus = req['endDate']
    note = req['note']
     description = req['description']
  patientID = req['patientID'] 
    
     if PatientAdvanceDirectives.exists?(:uid => req['uid'])
    get_update_patient_advance_directives(uid,file,attachTo,documentType,documentStatus,note,description,patientID)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Patient Advance Directives !'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_advance_directives' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientAdvanceDirectives.exists?(:uid => req['uid'])

    PatientAdvanceDirectives.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient Advance Directives found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





  # CREATE TABLE `patients_consent` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `file` varchar(255) DEFAULT NULL,
  # `attachTo` varchar(255) DEFAULT NULL,
  # `documentType` varchar(255) DEFAULT NULL,
  #  `documentStatus` varchar(255) DEFAULT NULL,
  #   `note` varchar(255) DEFAULT NULL,
  #    `description` varchar(255) DEFAULT NULL,
  # `patientID` varchar(255) DEFAULT NULL,
  # `uploadedBy` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### patients_advance_directives START
post '/create_patients_consent' do
  request.body.rewind  
  req = JSON.parse request.body.read

uid =  ['uid']
  file = req['file']
  attachTo = req['attachTo']
  documentType = req['documentType']
   documentStatus = req['endDate']
    note = req['note']
     description = req['description']
  patientID = req['patientID'] 
   uploadedBy = req['uploadedBy'] 
  

   p creating_patient_consent(uid,file,attachTo,documentType,documentStatus,note,description,patientID,uploadedBy)

   success  =  { resp_code: '000',resp_desc: 'Patient consent Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_consent' do
  retrieve_acess = PatientConsent.retrieve_patient_consent
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_consent' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientConsent.exists?(:uid => req['uid'])
    retrieve = PatientConsent.retrieve_single_patient_consent(uid)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient consent found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_patient_consent' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
   file = req['file']
  attachTo = req['attachTo']
  documentType = req['documentType']
   documentStatus = req['endDate']
    note = req['note']
     description = req['description']
  patientID = req['patientID'] 
  uploadedBy = req['uploadedBy'] 
    
     if PatientConsent.exists?(:uid => req['uid'])
    get_update_patient_consent(uid,file,attachTo,documentType,documentStatus,note,description,patientID,uploadedBy)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Patient consent!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_consent' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientConsent.exists?(:uid => req['uid'])

    PatientConsent.where(uid: uid).destroy_all
    puts "-----------DELETING PatientConsent------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted PatientConsent' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No PatientConsent found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





  # CREATE TABLE `patients_dme` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `vendor` varchar(255) DEFAULT NULL,
  # `deliveryDate` varchar(255) DEFAULT NULL,
  # `returnDate` varchar(255) DEFAULT NULL,
  #  `comment` varchar(255) DEFAULT NULL,
  #   `patientID` varchar(255) DEFAULT NULL,
  #    `description` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### patients_advance_directives START
post '/create_patients_dme' do
  request.body.rewind  
  req = JSON.parse request.body.read

uid =  ['uid']
  vendor = req['vendor']
  deliveryDate = req['deliveryDate']
  returnDate = req['returnDate']
   comment = req['comment']
    patientID = req['patientID']
     description = req['description']  

   p creating_patient_dme(uid,vendor,deliveryDate,returnDate,comment,patientID,description)

   success  =  { resp_code: '000',resp_desc: 'Patient dme Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_dme' do
  retrieve_acess = PatientDme.retrieve_patient_dme
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_dme' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientDme.exists?(:uid => req['uid'])
    retrieve = PatientDme.retrieve_single_patient_dme(uid)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Patient dme found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_patient_dme' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  vendor = req['vendor']
  deliveryDate = req['deliveryDate']
  returnDate = req['returnDate']
   comment = req['comment']
    patientID = req['patientID']
     description = req['description'] 
    
     if PatientDme.exists?(:uid => req['uid'])
    get_update_patient_dme(uid,vendor,deliveryDate,returnDate,comment,patientID,description)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated Patient dme!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_dme' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientDme.exists?(:uid => req['uid'])

    PatientDme.where(uid: uid).destroy_all
    puts "-----------DELETING PatientConsent------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted Dme' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Dme found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  # CREATE TABLE `payer_identifiers` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `payerUrl` varchar(255) DEFAULT NULL,
  # `agencyUrl` varchar(255) DEFAULT NULL,
  # `identifierType` varchar(255) DEFAULT NULL,
  #  `startDate` varchar(255) DEFAULT NULL,
  #   `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### create_payer_identifiers START
post '/create_payer_identifiers' do
  request.body.rewind  
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  agencyUrl = req['agencyUrl']
  identifierType = req['identifierType']
  identifierValue= req['identifierValue']
   startDate = req['startDate']
    endDate = req['endDate']
 

   p creating_payer_identifiers(payerUrl,agencyUrl,identifierType,identifierValue,startDate,endDate)

   success  =  { resp_code: '000',resp_desc: 'payer identifiers Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_identifiers' do
  retrieve_acess = PayerIdentifiers.retrieve_payer_identifiers
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payer_identifiers' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerIdentifiers.exists?(:id => req['id'])
    retrieve = PayerIdentifiers.retrieve_single_payer_identifiers(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_payer_identifiers_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerIdentifiers.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerIdentifiers.retrieve_payer_identifiers_payerUrl(payerUrl)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_payer_identifiers' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
 payerUrl = req['payerUrl']
  agencyUrl = req['agencyUrl']
  identifierType = req['identifierType']
  identifierValue= req['identifierValue']
   startDate = req['startDate']
    endDate = req['endDate']
    
     if PayerIdentifiers.exists?(:id => req['id'])
    get_update_payer_identifiers(id,payerUrl,agencyUrl,identifierType,identifierValue,startDate,endDate)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_identifiers' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerIdentifiers.exists?(:id => req['id'])

    PayerIdentifiers.where(id: id).destroy_all
    puts "-----------DELETING PatientConsent------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  
  # CREATE TABLE `payer_invoice_reviews` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `payerUrl` varchar(255) DEFAULT NULL,
  # `title` varchar(255) DEFAULT NULL,
  #  `startDate` varchar(255) DEFAULT NULL,
  #   `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### create_payer_identifiers START
post '/create_payer_invoice_reviews' do
  request.body.rewind  
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  title = req['title']
   startDate = req['startDate']
    endDate = req['endDate']
 

   p creating_payer_invoice_reviews(payerUrl,title,startDate,endDate)

   success  =  { resp_code: '000',resp_desc: 'Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_invoice_reviews' do
  retrieve_acess = PayerInvoiceReviews.retrieve_payer_invoice_reviews
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payer_invoice_reviews' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerInvoiceReviews.exists?(:id => req['id'])
    retrieve = PayerInvoiceReviews.retrieve_single_payer_invoice_reviews(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/retrieve_payer_invoice_reviews_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerInvoiceReviews.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerInvoiceReviews.retrieve_single_payer_invoice_reviews_payerUrl(payerUrl)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_payer_invoice_reviews' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
 payerUrl = req['payerUrl']
  title = req['title']
   startDate = req['startDate']
    endDate = req['endDate']
    
     if PayerInvoiceReviews.exists?(:id => req['id'])
    get_update_payer_invoice_reviews(id,payerUrl,title,startDate,endDate)

   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_invoice_reviews' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerInvoiceReviews.exists?(:id => req['id'])

    PayerInvoiceReviews.where(id: id).destroy_all
   
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 


  
  # CREATE TABLE `payer_hcpc` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `payerUrl` varchar(255) DEFAULT NULL,
  # `placeOfService` varchar(255) DEFAULT NULL,
  # `serviceCode` varchar(255) DEFAULT NULL,
  # `hcpcCode` varchar(255) DEFAULT NULL,
  # `hcpcModifier1` varchar(255) DEFAULT NULL,
  # `hcpcModifier2` varchar(255) DEFAULT NULL,
  # `hcpcModifier3` varchar(255) DEFAULT NULL,
  # `hcpcModifier4` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### create_payer_identifiers START
post '/create_payer_hcpc' do
  request.body.rewind  
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  placeOfService = req['placeOfService']
  serviceCode = req['serviceCode']
  hcpcCode = req['hcpcCode']
  hcpcModifier1 = req['hcpcModifier1']
  hcpcModifier2 = req['hcpcModifier2']
  hcpcModifier3 = req['hcpcModifier3']
  hcpcModifier4 = req['hcpcModifier4']
  startDate = req['startDate']
  endDate = req['endDate']
 

   p creating_payer_hcpc(payerUrl,placeOfService,serviceCode,hcpcCode,hcpcModifier1,hcpcModifier2,hcpcModifier3,hcpcModifier4,startDate,endDate)

   success  =  { resp_code: '000',resp_desc: 'Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_hcpc' do
  retrieve_acess = PayerHcpc.retrieve_payer_hcpc
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payer_hcpc' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerHcpc.exists?(:id => req['id'])
    retrieve = PayerHcpc.retrieve_single_payer_hcpc(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

   

post '/retrieve_payer_hcpc_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerHcpc.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerHcpc.retrieve_single_payer_hcpc_payerUrl(payerUrl)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_payer_hcpc' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  payerUrl = req['payerUrl']
  placeOfService = req['placeOfService']
  serviceCode = req['serviceCode']
  hcpcCode = req['hcpcCode']
  hcpcModifier1 = req['hcpcModifier1']
  hcpcModifier2 = req['hcpcModifier2']
  hcpcModifier3 = req['hcpcModifier3']
  hcpcModifier4 = req['hcpcModifier4']
  startDate = req['startDate']
  endDate = req['endDate']
    
     if PayerHcpc.exists?(:id => req['id'])
    get_update_payer_hcpc(id,payerUrl,placeOfService,serviceCode,hcpcCode,hcpcModifier1,hcpcModifier2,hcpcModifier3,hcpcModifier4,startDate,endDate)


   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_hcpc' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerHcpc.exists?(:id => req['id'])

    PayerHcpc.where(id: id).destroy_all
   
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



 # CREATE TABLE `payer_carrier_code` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `payerUrl` varchar(255) DEFAULT NULL,
 #  `relationalPayer` varchar(255) DEFAULT NULL,
 #  `carrierCode` varchar(255) DEFAULT NULL,
 #  `startDate` varchar(255) DEFAULT NULL,
 #  `endDate` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))



### payer_carrier_code START
post '/create_payer_carrier_code' do
  request.body.rewind  
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  relationalPayer = req['relationalPayer']
  carrierCode = req['carrierCode']
  startDate = req['startDate']
  endDate = req['endDate']
 

   p creating_payer_carrier_code(payerUrl,relationalPayer,carrierCode,startDate,endDate)

   success  =  { resp_code: '000',resp_desc: 'Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_payer_carrier_code' do
  retrieve_acess = PayerCarrierCode.retrieve_payer_carrier_code
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_payer_carrier_code' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PayerCarrierCode.exists?(:id => req['id'])
    retrieve = PayerCarrierCode.retrieve_single_payer_carrier_code(id)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_payer_carrier_code_payerUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  payerUrl = req['payerUrl']
  if PayerCarrierCode.exists?(:payerUrl => req['payerUrl'])
    retrieve = PayerCarrierCode.retrieve_single_payer_carrier_code_payerUrl(payerUrl)
   
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_payer_carrier_code' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
 payerUrl = req['payerUrl']
  relationalPayer = req['relationalPayer']
  carrierCode = req['carrierCode']
  startDate = req['startDate']
  endDate = req['endDate']
    
     if PayerCarrierCode.exists?(:id => req['id'])
    get_update_payer_carrier_code(id,payerUrl,relationalPayer,carrierCode,startDate,endDate)


   regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_payer_carrier_code' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PayerCarrierCode.exists?(:id => req['id'])

    PayerCarrierCode.where(id: id).destroy_all
   
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'None found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





  # CREATE TABLE `referral_source` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `referralType` varchar(255) DEFAULT NULL,
  # `facilityName` varchar(255) DEFAULT NULL,
  # `facilityType` varchar(255) DEFAULT NULL,
  # `referralCompany` varchar(255) DEFAULT NULL,
  # `firstName` varchar(255) DEFAULT NULL,
  # `lastName` varchar(255) DEFAULT NULL,
  # `middleName` varchar(255) DEFAULT NULL,
  # `email` varchar(255) DEFAULT NULL,
  # `salesRep` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `physicianGroup` varchar(255) DEFAULT NULL,
  # `specialty` varchar(255) DEFAULT NULL,
  # `title` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_referral_source' do
  request.body.rewind
  req = JSON.parse request.body.read

   uid = req['uid']
  referralType = req['referralType']
  facilityName = req['facilityName']
  facilityType = req['facilityType']
  referralCompany = req['referralCompany']
  firstName = req['firstName']
  lastName = req['lastName']
  middleName = req['middleName']
  email = req['email']
  salesRep = req['salesRep']
   startDate = req['startDate']
    endDate = req['endDate']
     physicianGroup = req['physicianGroup']
      specialty = req['specialty']
       title = req['title']
       organizationUrl = req['organizationUrl']
       status = req['status']
       updated = req['updated']


   p creating_referral_source(uid,referralType,facilityName,facilityType,referralCompany,firstName,lastName,middleName,email,salesRep,startDate,
    endDate,physicianGroup,specialty,title,organizationUrl,status,updated)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end





get '/retrieve_all_referral_source' do
  retrieve_acess = ReferralSource.retrieve_referral_source
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_referral_source' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if ReferralSource.exists?(:uid => req['uid'])
    retrieve = ReferralSource.retrieve_single_referral_source(uid)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_single_referral_source_with_org_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if ReferralSource.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = ReferralSource.retrieve_single_referral_source_with_org_url(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No referral source contacts found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_referral_source' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  referralType = req['referralType']
  facilityName = req['facilityName']
  facilityType = req['facilityType']
  referralCompany = req['referralCompany']
  firstName = req['firstName']
  lastName = req['lastName']
  middleName = req['middleName']
  email = req['email']
  salesRep = req['salesRep']
   startDate = req['startDate']
    endDate = req['endDate']
     physicianGroup = req['physicianGroup']
      specialty = req['specialty']
       title = req['title']
        organizationUrl = req['organizationUrl']
         status = req['status']
       updated = req['updated']

    
     if ReferralSource.exists?(:uid => req['uid'])
    get_update_referral_source(uid,referralType,facilityName,facilityType,referralCompany,firstName,lastName,middleName,email,salesRep,startDate,
    endDate,physicianGroup,specialty,title,organizationUrl,status,updated)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json



                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_referral_source' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if ReferralSource.exists?(:uid => req['uid'])

    ReferralSource.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 



  # CREATE TABLE `ass_lookup_inactive_reason_types` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `code` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `title` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_inactive_reason_types' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  code = req['code']
  description = req['description']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
   startDate = req['startDate']
    endDate = req['endDate']



   p creating_inactive_reason_types(organizationUrl,code,description,groupCode,sortOrder,startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_inactive_reason_types' do
  retrieve_acess = AssLookupInactiveReasonTypes.retrieve_all_inactive_reason_types
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_inactive_reason_types' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssLookupInactiveReasonTypes.exists?(:id => req['id'])
    retrieve = AssLookupInactiveReasonTypes.retrieve_inactive_reason_types(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_inactive_reason_types_with_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if AssLookupInactiveReasonTypes.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = AssLookupInactiveReasonTypes.retrieve_inactive_reason_types_with_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Facility------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_inactive_reason_types' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  code = req['code']
  description = req['description']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
   startDate = req['startDate']
    endDate = req['endDate']

    
     if AssLookupInactiveReasonTypes.exists?(:id => req['id'])
     get_update_inactive_reason_types(id,organizationUrl,code,description,groupCode,sortOrder,startDate,endDate)

    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_inactive_reason_types' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssLookupInactiveReasonTypes.exists?(:id => req['id'])

    AssLookupInactiveReasonTypes.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  # CREATE TABLE `ass_lookup_discipline_types` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `disciplineCode` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `orderDisciplineCode` varchar(255) DEFAULT NULL,
  # `serviceCategoryCode` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `allowConnectionToPhysician` varchar(255) DEFAULT NULL,
  # `assessmentGroup` varchar(255) DEFAULT NULL,
  # `payCode` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_discipline_types' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  disciplineCode = req['disciplineCode']
  description = req['description']
  serviceCategoryCode = req['serviceCategoryCode']
  orderDisciplineCode = req['orderDisciplineCode']
  sortOrder = req['sortOrder']
   startDate = req['startDate']
    endDate = req['endDate']
    allowConnectionToPhysician = req['allowConnectionToPhysician']
    assessmentGroup = req['assessmentGroup']
    payCode = req['payCode']




   p creating_discipline_types(organizationUrl,disciplineCode,description,serviceCategoryCode,orderDisciplineCode,sortOrder,startDate,endDate,
    allowConnectionToPhysician,assessmentGroup,payCode)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_discipline_types' do
  retrieve_acess = AssLookupDisciplineTypes.retrieve_all_discipline_types
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_discipline_types' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssLookupDisciplineTypes.exists?(:id => req['id'])
    retrieve = AssLookupDisciplineTypes.retrieve_discipline_types(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_discipline_types_with_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if AssLookupDisciplineTypes.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = AssLookupDisciplineTypes.retrieve_discipline_types_with_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Facility------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_discipline_types' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
    organizationUrl = req['organizationUrl']
  disciplineCode = req['disciplineCode']
  description = req['description']
  serviceCategoryCode = req['serviceCategoryCode']
  orderDisciplineCode = req['orderDisciplineCode']
  sortOrder = req['sortOrder']
   startDate = req['startDate']
    endDate = req['endDate']
    allowConnectionToPhysician = req['allowConnectionToPhysician']
    assessmentGroup = req['assessmentGroup']
    payCode = req['payCode']

    
     if AssLookupDisciplineTypes.exists?(:id => req['id'])
     get_update_discipline_types(id,organizationUrl,disciplineCode,description,serviceCategoryCode,orderDisciplineCode,sortOrder,startDate,endDate,
    allowConnectionToPhysician,assessmentGroup,payCode)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_discipline_types' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssLookupDisciplineTypes.exists?(:id => req['id'])

    AssLookupDisciplineTypes.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  # CREATE TABLE `notes` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `noteType` varchar(255) DEFAULT NULL,
  # `payer` varchar(255) DEFAULT NULL,
  # `followUpDate` varchar(255) DEFAULT NULL,
  # `note` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



post '/create_notes' do
  request.body.rewind
  req = JSON.parse request.body.read

   noteType = req['noteType']
  payer = req['payer']
  followUpDate = req['followUpDate']
  note = req['note']


   p creating_notes(noteType,payer,followUpDate,note)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_notes' do
  retrieve_acess = Notes.retrieve_all_notes
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_note' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if Notes.exists?(:id => req['id'])
    retrieve = Notes.retrieve_notes(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_note' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
    noteType = req['noteType']
  payer = req['payer']
  followUpDate = req['followUpDate']
  note = req['note']

    
     if Notes.exists?(:id => req['id'])
     get_update_notes(id,noteType,payer,followUpDate,note)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_note' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Notes.exists?(:id => req['id'])

    Notes.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





  # CREATE TABLE `ass_lookup_deductions` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `isRecurring` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `isPretax` varchar(255) DEFAULT NULL,
  # `calculation` varchar(255) DEFAULT NULL,
  # `coverage` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_lookup_deductions' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  isRecurring = req['isRecurring']
  description = req['description']
  isPretax = req['isPretax']
  calculation = req['calculation']
  coverage = req['coverage']
   groupCode = req['groupCode']
    sortOrder = req['sortOrder']
    startDate = req['startDate']
    endDate = req['endDate']
   


   p creating_lookup_deductions(organizationUrl,isRecurring,description,isPretax,calculation,coverage,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_lookup_deductions' do
  retrieve_acess = AssLookupDeductions.retrieve_all_lookup_deductions
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_lookup_deduction' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssLookupDeductions.exists?(:id => req['id'])
    retrieve = AssLookupDeductions.retrieve_lookup_deduction(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_lookup_deduction_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if AssLookupDeductions.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = AssLookupDeductions.retrieve_lookup_deduction_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_lookup_deduction' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
    organizationUrl = req['organizationUrl']
  isRecurring = req['isRecurring']
  description = req['description']
  isPretax = req['isPretax']
  calculation = req['calculation']
  coverage = req['coverage']
   groupCode = req['groupCode']
    sortOrder = req['sortOrder']
    startDate = req['startDate']
    endDate = req['endDate']

    
     if AssLookupDeductions.exists?(:id => req['id'])
     get_update_lookup_deductions(id,organizationUrl,isRecurring,description,isPretax,calculation,coverage,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_lookup_deduction' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssLookupDeductions.exists?(:id => req['id'])

    AssLookupDeductions.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




 

  # CREATE TABLE `ass_lookup_noteType` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `code` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `doNotGenerateWbTask` tinyint(1) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_lookup_noteType' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  code = req['code']
  description = req['description']
  doNotGenerateWbTask = req['doNotGenerateWbTask']
   groupCode = req['groupCode']
    sortOrder = req['sortOrder']
    startDate = req['startDate']
    endDate = req['endDate']
   


   p creating_lookup_noteType(organizationUrl,code,description,doNotGenerateWbTask,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_lookup_noteType' do
  retrieve_acess = AssLookupNoteType.retrieve_all_lookup_noteType
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_lookup_noteType' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssLookupNoteType.exists?(:id => req['id'])
    retrieve = AssLookupNoteType.retrieve_lookup_noteType(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_lookup_noteType_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if AssLookupNoteType.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = AssLookupNoteType.retrieve_lookup_noteType_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_lookup_noteType' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
    organizationUrl = req['organizationUrl']
  code = req['code']
  description = req['description']
  doNotGenerateWbTask = req['doNotGenerateWbTask']
   groupCode = req['groupCode']
    sortOrder = req['sortOrder']
    startDate = req['startDate']
    endDate = req['endDate']

    
     if AssLookupNoteType.exists?(:id => req['id'])
     get_update_lookup_noteType(id,organizationUrl,code,description,doNotGenerateWbTask,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_lookup_noteType' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssLookupNoteType.exists?(:id => req['id'])

    AssLookupNoteType.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 



 

  # CREATE TABLE `ass_lookup_contractorCompanies` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `name` varchar(255) DEFAULT NULL,
  # `phone` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_lookup_contractorCompanies' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  name = req['name']
  phone = req['phone']
 
   


   p creating_lookup_contractorCompanies(organizationUrl,name,phone)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_lookup_contractorCompanies' do
  retrieve_acess = AssLookupcontractorCompanies.retrieve_all_lookup_contractorCompanies
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_lookup_contractorCompanies' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssLookupcontractorCompanies.exists?(:id => req['id'])
    retrieve = AssLookupcontractorCompanies.retrieve_lookup_contractorCompanies(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_lookup_contractorCompanies_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if AssLookupcontractorCompanies.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = AssLookupcontractorCompanies.retrieve_lookup_contractorCompanies_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_lookup_contractorCompanies' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   organizationUrl = req['organizationUrl']
  name = req['name']
  phone = req['phone']

    
     if AssLookupcontractorCompanies.exists?(:id => req['id'])
     get_update_lookup_contractorCompanies(id,organizationUrl,name,phone)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_lookup_contractorCompanies' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssLookupcontractorCompanies.exists?(:id => req['id'])

    AssLookupcontractorCompanies.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  # CREATE TABLE `ass_lookup_compliance` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `category` varchar(255) DEFAULT NULL,
  # `appliesTo` varchar(255) DEFAULT NULL,
  # `requiredForScheduling` tinyint(1) DEFAULT NULL,
  # `dateType` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `complianceDisciplines` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_lookup_compliance' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
    name = req['name']
  description = req['description']
  category = req['category']
  appliesTo = req['appliesTo']
  requiredForScheduling = req['requiredForScheduling']
  dateType = req['dateType']
  startDate = req['startDate']
  endDate = req['endDate']
  complianceDisciplines = req['complianceDisciplines']
 
   
   p creating_lookup_compliance(organizationUrl,name,description,category,appliesTo,requiredForScheduling,dateType,
    startDate,endDate,complianceDisciplines)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_lookup_compliance' do
  retrieve_acess = AssLookupCompliance.retrieve_all_lookup_compliance
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_lookup_compliance' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssLookupCompliance.exists?(:id => req['id'])
    retrieve = AssLookupCompliance.retrieve_lookup_compliance(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_lookup_compliance_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if AssLookupCompliance.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = AssLookupCompliance.retrieve_lookup_compliance_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_lookup_compliance' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
 organizationUrl = req['organizationUrl']
  name = req['name']
  description = req['description']
  category = req['category']
  appliesTo = req['appliesTo']
  requiredForScheduling = req['requiredForScheduling']
  dateType = req['dateType']
  startDate = req['startDate']
  endDate = req['endDate']
  complianceDisciplines = req['complianceDisciplines']

    
     if AssLookupCompliance.exists?(:id => req['id'])
     get_update_lookup_compliance(id,organizationUrl,name,description,category,appliesTo,requiredForScheduling,dateType,
    startDate,endDate,complianceDisciplines)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_lookup_compliance' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssLookupCompliance.exists?(:id => req['id'])

    AssLookupCompliance.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





  # CREATE TABLE `ass_lookup_licenseType` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `code` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `requiredForScheduling` tinyint(1) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



post '/create_lookup_licenseType' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  groupCode = req['groupCode']
  requiredForScheduling = req['requiredForScheduling']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

 


   p creating_lookup_licenseType(organizationUrl,description,code,groupCode,requiredForScheduling,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_lookup_licenseType' do
  retrieve_acess = AssLookupLicenseType.retrieve_all_lookup_licenseType
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_lookup_licenseType' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssLookupLicenseType.exists?(:id => req['id'])
    retrieve = AssLookupLicenseType.retrieve_lookup_licenseType(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_lookup_licenseType_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if AssLookupLicenseType.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = AssLookupLicenseType.retrieve_lookup_licenseType_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_lookup_licenseType' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  groupCode = req['groupCode']
  requiredForScheduling = req['requiredForScheduling']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if AssLookupLicenseType.exists?(:id => req['id'])
     get_update_lookup_licenseType(id,organizationUrl,description,code,groupCode,requiredForScheduling,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_lookup_licenseType' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssLookupLicenseType.exists?(:id => req['id'])

    AssLookupLicenseType.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  # CREATE TABLE `ass_lookup_schedulingRankType` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



post '/create_lookup_schedulingRankType' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  description = req['description']
  startDate = req['startDate']
  endDate = req['endDate']


   p creating_lookup_schedulingRankType(organizationUrl,description,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_lookup_schedulingRankType' do
  retrieve_acess = AssLookupSchedulingRankType.retrieve_all_lookup_schedulingRankType
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_lookup_schedulingRankType' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssLookupSchedulingRankType.exists?(:id => req['id'])
    retrieve = AssLookupSchedulingRankType.retrieve_lookup_schedulingRankType(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_lookup_schedulingRankType_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if AssLookupSchedulingRankType.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = AssLookupSchedulingRankType.retrieve_lookup_schedulingRankType_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end

post '/update_lookup_schedulingRankType' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
organizationUrl = req['organizationUrl']
  description = req['description']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if AssLookupSchedulingRankType.exists?(:id => req['id'])
     get_update_lookup_schedulingRankType(id,organizationUrl,description,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_lookup_schedulingRankType' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssLookupSchedulingRankType.exists?(:id => req['id'])

    AssLookupSchedulingRankType.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  # CREATE TABLE `ar_lookup_hcpc_modifier_types` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `hcpcModifierCodes` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



post '/create_arlookup_hcpcModifierTypes' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  description = req['description']
   hcpcModifierCodes = req['hcpcModifierCodes']
    groupCode = req['groupCode']
     sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']


   p creating_arlookup_hcpcModifierTypes(organizationUrl,description,hcpcModifierCodes,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_arlookup_hcpcModifierTypes' do
  retrieve_acess = ArLookupHcpcModifierType.retrieve_all_arlookup_hcpcModifierType
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_arlookup_hcpcModifierType' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if ArLookupHcpcModifierType.exists?(:id => req['id'])
    retrieve = ArLookupHcpcModifierType.retrieve_arlookup_hcpcModifierType(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_arlookup_hcpcModifierType_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if ArLookupHcpcModifierType.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = ArLookupHcpcModifierType.retrieve_arlookup_hcpcModifierType_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_arlookup_hcpcModifierType' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
    organizationUrl = req['organizationUrl']
  description = req['description']
   hcpcModifierCodes = req['hcpcModifierCodes']
    groupCode = req['groupCode']
     sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if ArLookupHcpcModifierType.exists?(:id => req['id'])
     get_update_arlookup_hcpcModifierTypes(id,organizationUrl,description,hcpcModifierCodes,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_arlookup_hcpcModifierType' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if ArLookupHcpcModifierType.exists?(:id => req['id'])

    ArLookupHcpcModifierType.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





  # CREATE TABLE `ar_lookup_paymentSources` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `paymentSource` varchar(255) DEFAULT NULL,
  # `paymentMethod` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



post '/create_ar_lookup_paymentSources' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  paymentSource = req['paymentSource']
   paymentMethod = req['paymentMethod']


   p creating_arlookup_paymentSources(organizationUrl,paymentSource,paymentMethod)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_arlookup_paymentSources' do
  retrieve_acess = ArLookupPaymentSources.retrieve_all_arlookup_paymentSources
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_arlookup_paymentSources' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if ArLookupPaymentSources.exists?(:id => req['id'])
    retrieve = ArLookupPaymentSources.retrieve_arlookup_paymentSources(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_arlookup_paymentSources_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if ArLookupPaymentSources.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = ArLookupPaymentSources.retrieve_arlookup_paymentSources_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_arlookup_paymentSources' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   organizationUrl = req['organizationUrl']
  paymentSource = req['paymentSource']
   paymentMethod = req['paymentMethod']

    
     if ArLookupPaymentSources.exists?(:id => req['id'])
     get_update_arlookup_hcpcModifierTypes(id,organizationUrl,paymentSource,paymentMethod)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_arlookup_paymentSources' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if ArLookupPaymentSources.exists?(:id => req['id'])

    ArLookupPaymentSources.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





  # CREATE TABLE `ar_lookup_era_reason_type` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `code` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))

#   organizationUrl: url of organization,
# eraReasonCode: string,
# arAdjustmentReason : string,
# adjustmentLevel : string,
# startDate: date,
# endDate: date,



post '/create_ar_lookup_eraReasonType' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  eraReasonCode = req['eraReasonCode']
   arAdjustmentReason = req['arAdjustmentReason']
    adjustmentLevel = req['adjustmentLevel']
  startDate = req['startDate']
  endDate = req['endDate']


   p creating_arlookup_eraReasonType(organizationUrl,eraReasonCode,arAdjustmentReason,adjustmentLevel,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_arlookup_eraReasonType' do
  retrieve_acess = ArLookupEraReasonType.retrieve_all_arlookup_eraReasonType
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_arlookup_eraReasonType' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if ArLookupEraReasonType.exists?(:id => req['id'])
    retrieve = ArLookupEraReasonType.retrieve_arlookup_eraReasonType(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_arlookup_eraReasonType_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if ArLookupEraReasonType.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = ArLookupEraReasonType.retrieve_arlookup_eraReasonType_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_arlookup_eraReasonType' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   organizationUrl = req['organizationUrl']
  eraReasonCode = req['eraReasonCode']
   arAdjustmentReason = req['arAdjustmentReason']
    adjustmentLevel = req['adjustmentLevel']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if ArLookupEraReasonType.exists?(:id => req['id'])
     get_update_arlookup_eraReasonType(id,organizationUrl,eraReasonCode,arAdjustmentReason,adjustmentLevel,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_arlookup_eraReasonType' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if ArLookupEraReasonType.exists?(:id => req['id'])

    ArLookupEraReasonType.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 


##########SERVICE FACIILITY ############

# CREATE TABLE `patient_service_facilities` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `patientID` varchar(255) DEFAULT NULL,
#   `facilityName` varchar(255) DEFAULT NULL,
#   `addressType` varchar(255) DEFAULT NULL,
#   `addressOne` varchar(255) DEFAULT NULL,
#   `addressTwo` varchar(255) DEFAULT NULL,
#   `city` varchar(255) DEFAULT NULL,
#   `state` varchar(255) DEFAULT NULL,
#   `zipcode` varchar(255) DEFAULT NULL,
#   `placeOfService` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `phoneType` varchar(255) DEFAULT NULL,
#   `phone` varchar(255) DEFAULT NULL,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   `uid` varchar(255) DEFAULT NULL,
#   PRIMARY KEY (`id`)

   
post '/create_patient_service_facilities' do
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  patientID = req['patientID']
  facilityName  = req['facilityName']
  addressType = req['addressType']
  addressOne = req['addressOne']
  addressTwo = req['addressTwo']
  city = req['city']
  state = req['state']
  zipcode = req['zipcode']
  placeOfService = req['placeOfService']
  startDate = req['startDate']
  endDate = req['endDate']
  phoneType = req['phoneType']
  phone = req['phone']
  organizationUrl = req['organizationUrl']
 
  
   p creating_patient_service_facilities(uid,patientID,facilityName,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,startDate,endDate,phoneType,phone,organizationUrl)
   success  =  { resp_code: '000',resp_desc: 'Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_service_facilities' do
  retrieve_acess = PatientServiceFacility.retrieve_patient_service_facilities
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_patient_service_facilities' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientServiceFacility.exists?(:uid => req['uid'])
    retrieve = PatientServiceFacility.retrieve_single_patient_service_facilities(uid)
    puts "-----------RETRIEVING patient_address_phone_info------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_patient_service_facilities_with_org_url' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if PatientServiceFacility.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = PatientServiceFacility.retrieve_patient_service_facilities_with_org_url(organizationUrl)
    puts "-----------RETRIEVING patient_address_phone_info------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No patient_address phone info  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_patient_service_facilities' do
  puts "------------------UPDATING payments API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  patientID = req['patientID']
  facilityName  = req['facilityName']
  addressType = req['addressType']
  addressOne = req['addressOne']
  addressTwo = req['addressTwo']
  city = req['city']
  state = req['state']
  zipcode = req['zipcode']
  placeOfService = req['placeOfService']
  startDate = req['startDate']
  endDate = req['endDate']
  phoneType = req['phoneType']
  phone = req['phone']
  organizationUrl = req['organizationUrl']
    
      if PatientServiceFacility.exists?(:uid => req['uid'])
    get_update_patient_service_facilities(uid,patientID,facilityName,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,startDate,endDate,phoneType,phone,organizationUrl)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_service_facilities' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientServiceFacility.exists?(:uid => req['uid'])

    PatientServiceFacility.where(uid: uid).destroy_all
    puts "-----------DELETING PatientAddressPhoneInfo------------------"
    del = [{resp_code: '000', resp_desc: 'Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end






  # CREATE TABLE `ar_lookup_invoice_note_type` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `code` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `generateWorkflow` tinyint(1) DEFAULT NULL,
  #  `followupDays` tinyint(1) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



post '/create_lookup_invoice_note_type' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  groupCode = req['groupCode']
  generateWorkflow = req['generateWorkflow']
  followupDays = req['followupDays']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

 


   p creating_lookup_invoice_note_type(organizationUrl,description,code,groupCode,generateWorkflow,followupDays,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_lookup_invoice_note_type' do
  retrieve_acess = ArLookupInvoiceNoteType.retrieve_all_lookup_invoice_note_type
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_lookup_invoice_note_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if ArLookupInvoiceNoteType.exists?(:id => req['id'])
    retrieve = ArLookupInvoiceNoteType.retrieve_lookup_invoice_note_type(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_lookup_invoice_note_type_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if ArLookupInvoiceNoteType.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = ArLookupInvoiceNoteType.retrieve_lookup_invoice_note_type_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_lookup_invoice_note_type' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['category']
  groupCode = req['groupCode']
 generateWorkflow = req['generateWorkflow']
  followupDays = req['followupDays']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if ArLookupInvoiceNoteType.exists?(:id => req['id'])
     get_update_lookup_invoice_note_type(id,organizationUrl,description,code,groupCode,generateWorkflow,followupDays,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_lookup_invoice_note_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if ArLookupInvoiceNoteType.exists?(:id => req['id'])

    ArLookupInvoiceNoteType.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




 
####SUPORTED TEXTS physician_orders_suggested_text


# CREATE TABLE `physician_orders_suggested_text` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `description` varchar(255) DEFAULT NULL,
#   `code` varchar(255) DEFAULT NULL,
#   `groupCode` varchar(255) DEFAULT NULL,
#   `sortOrder` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))



post '/create_physician_orders_suggested_text' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

 
   p creating_physician_orders_suggested_text(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_physician_orders_suggested_text' do
  retrieve_acess = PhysicianOrdersSuggestedText.retrieve_all_physician_orders_suggested_text
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_physician_orders_suggested_text' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PhysicianOrdersSuggestedText.exists?(:id => req['id'])
    retrieve = PhysicianOrdersSuggestedText.retrieve_physician_orders_suggested_text(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_physician_orders_suggested_text' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['category']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if PhysicianOrdersSuggestedText.exists?(:id => req['id'])
    get_update_physician_orders_suggested_text(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_physician_orders_suggested_text' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PhysicianOrdersSuggestedText.exists?(:id => req['id'])

    PhysicianOrdersSuggestedText.where(id: id).destroy_all
    puts "-----------DELETING PhysicianOrdersSuggestedText------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





####SUPORTED TEXTS Physician Orders Quick Pick Types

# CREATE TABLE `physician_orders_quick_pick_types` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `description` varchar(255) DEFAULT NULL,
#   `code` varchar(255) DEFAULT NULL,
#   `groupCode` varchar(255) DEFAULT NULL,
#   `sortOrder` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))



post '/create_physician_orders_quick_pick_types' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

 
   p creating_physician_orders_quick_pick_types(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_physician_orders_quick_pick_types' do
  retrieve_acess = PhysicianOrdersQuickPickTypes.retrieve_all_physician_orders_quick_pick_types
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_physician_orders_quick_pick_types' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PhysicianOrdersQuickPickTypes.exists?(:id => req['id'])
    retrieve = PhysicianOrdersQuickPickTypes.retrieve_physician_orders_quick_pick_types(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_physician_orders_quick_pick_types' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['category']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if PhysicianOrdersQuickPickTypes.exists?(:id => req['id'])
    get_update_physician_orders_quick_pick_types(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_physician_orders_quick_pick_types' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PhysicianOrdersQuickPickTypes.exists?(:id => req['id'])

    PhysicianOrdersQuickPickTypes.where(id: id).destroy_all
    puts "-----------DELETING PhysicianOrdersSuggestedText------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




####SUPORTED TEXTS oasis void reason type

# CREATE TABLE `oasis_void_reason_type` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `description` varchar(255) DEFAULT NULL,
#   `code` varchar(255) DEFAULT NULL,
#   `groupCode` varchar(255) DEFAULT NULL,
#   `sortOrder` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))



post '/create_oasis_void_reason_type' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

 
   p creating_oasis_void_reason_type(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_oasis_void_reason_type' do
  retrieve_acess = OasisVoidReasonType.retrieve_all_oasis_void_reason_type
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_oasis_void_reason_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if OasisVoidReasonType.exists?(:id => req['id'])
    retrieve = OasisVoidReasonType.retrieve_oasis_void_reason_type(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_oasis_void_reason_type' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['category']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if OasisVoidReasonType.exists?(:id => req['id'])
    get_update_oasis_void_reason_type(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_oasis_void_reason_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if OasisVoidReasonType.exists?(:id => req['id'])

    OasisVoidReasonType.where(id: id).destroy_all

    puts "-----------DELETING OasisVoidReasonType------------------"

    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





####SUPORTED TEXTS care need task action response

# CREATE TABLE `care_need_task_action_response` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `description` varchar(255) DEFAULT NULL,
#   `code` varchar(255) DEFAULT NULL,
#   `groupCode` varchar(255) DEFAULT NULL,
#   `sortOrder` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))



post '/create_care_need_task_action_response' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  description = req['description']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

 
   p creating_care_need_task_action_response(organizationUrl,description,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_care_need_task_action_response' do
  retrieve_acess = CareNeedTaskActionResponse.retrieve_all_care_need_task_action_response
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_care_need_task_action_response' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if CareNeedTaskActionResponse.exists?(:id => req['id'])
    retrieve = CareNeedTaskActionResponse.retrieve_care_need_task_action_response(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_care_need_task_action_response' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  description = req['description']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if CareNeedTaskActionResponse.exists?(:id => req['id'])
    get_update_care_need_task_action_response(id,organizationUrl,description,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_care_need_task_action_response' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if CareNeedTaskActionResponse.exists?(:id => req['id'])

    CareNeedTaskActionResponse.where(id: id).destroy_all

    puts "-----------DELETING CareNeedTaskActionResponse------------------"
    
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 






####SUPORTED TEXTS care need task action response

# CREATE TABLE `vaccines` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `description` varchar(255) DEFAULT NULL,
#   `code` varchar(255) DEFAULT NULL,
#   `groupCode` varchar(255) DEFAULT NULL,
#   `sortOrder` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))



post '/create_vaccines' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  description = req['description']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

 
   p creating_vaccines(organizationUrl,description,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_vaccines' do
  retrieve_acess = Vaccines.retrieve_all_vaccines
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_vaccine' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if Vaccines.exists?(:id => req['id'])
    retrieve = Vaccines.retrieve_vaccines(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_vaccines' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  description = req['description']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if Vaccines.exists?(:id => req['id'])
    get_update_vaccines(id,organizationUrl,description,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_vaccines' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Vaccines.exists?(:id => req['id'])

    Vaccines.where(id: id).destroy_all

    puts "-----------DELETING Vaccines------------------"
    
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





####SUPORTED TEXTS care need task action response

# CREATE TABLE `goal_status_types` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `description` varchar(255) DEFAULT NULL,
#   `code` varchar(255) DEFAULT NULL,
#   `groupCode` varchar(255) DEFAULT NULL,
#   `sortOrder` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))



post '/create_goal_status_types' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

 
   p creating_goal_status_types(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_goal_status_types' do
  retrieve_acess = GoalStatusTypes.retrieve_all_goal_status_types
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_goal_status_types' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if GoalStatusTypes.exists?(:id => req['id'])
    retrieve = GoalStatusTypes.retrieve_goal_status_types(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_goal_status_types' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if GoalStatusTypes.exists?(:id => req['id'])
    get_update_goal_status_types(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_goal_status_types' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if GoalStatusTypes.exists?(:id => req['id'])

    GoalStatusTypes.where(id: id).destroy_all

    puts "-----------DELETING GoalStatusTypes------------------"
    
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





# CREATE TABLE `care_need_levels` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `description` varchar(255) DEFAULT NULL,
#   `code` varchar(255) DEFAULT NULL,
#   `groupCode` varchar(255) DEFAULT NULL,
#   `sortOrder` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))



post '/create_care_need_levels' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

 
   p creating_care_need_levels(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_care_need_levels' do
  retrieve_acess = CareNeedLevels.retrieve_all_care_need_levels
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_care_need_levels' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if CareNeedLevels.exists?(:id => req['id'])
    retrieve = CareNeedLevels.retrieve_care_need_levels(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_care_need_levels' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if CareNeedLevels.exists?(:id => req['id'])
    get_update_care_need_levels(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_care_need_levels' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if CareNeedLevels.exists?(:id => req['id'])

    CareNeedLevels.where(id: id).destroy_all

    puts "-----------DELETING CareNeedLevels------------------"
    
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 





# CREATE TABLE `medication_administered_by_type` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `description` varchar(255) DEFAULT NULL,
#   `code` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))



post '/create_medication_administered_by_type' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  startDate = req['startDate']
  endDate = req['endDate']

 
   p creating_medication_administered_by_type(organizationUrl,description,code,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_medication_administered_by_type' do
  retrieve_acess = MedicationAdministeredByType.retrieve_all_medication_administered_by_type
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_medication_administered_by_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if MedicationAdministeredByType.exists?(:id => req['id'])
    retrieve = MedicationAdministeredByType.retrieve_medication_administered_by_type(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_medication_administered_by_type' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  description = req['description']
  code = req['code']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if MedicationAdministeredByType.exists?(:id => req['id'])
    get_update_medication_administered_by_type(id,organizationUrl,description,code,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_medication_administered_by_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if MedicationAdministeredByType.exists?(:id => req['id'])

    MedicationAdministeredByType.where(id: id).destroy_all

    puts "-----------DELETING MedicationAdministeredByType------------------"
    
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 







# CREATE TABLE `vital_type` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `vitalDescription` varchar(255) DEFAULT NULL,
#   `lowValue` varchar(255) DEFAULT NULL,
#   `highValue` varchar(255) DEFAULT NULL,
#   `matchingCode` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))



post '/create_care_vital_type' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  vitalDescription = req['vitalDescription']
  lowValue = req['lowValue']
  highValue = req['highValue']
  matchingCode = req['matchingCode']
  startDate = req['startDate']
  endDate = req['endDate']

 
   p creating_vital_type(organizationUrl,vitalDescription,lowValue,highValue,matchingCode,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_vital_type' do
  retrieve_acess = VitalType.retrieve_all_vital_type
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_vital_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if VitalType.exists?(:id => req['id'])
    retrieve = VitalType.retrieve_vital_type(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_vital_type' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  vitalDescription = req['vitalDescription']
  lowValue = req['lowValue']
  highValue = req['highValue']
  matchingCode = req['matchingCode']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if VitalType.exists?(:id => req['id'])
    get_update_vital_type(id,organizationUrl,vitalDescription,lowValue,highValue,matchingCode,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_vital_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if VitalType.exists?(:id => req['id'])

    VitalType.where(id: id).destroy_all

    puts "-----------DELETING VitalType------------------"
    
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 







# CREATE TABLE `wound_area` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `woundAreaCode` varchar(255) DEFAULT NULL,
#   `woundAreaName` varchar(255) DEFAULT NULL,
#   `groupCode` varchar(255) DEFAULT NULL,
#   `sortOrder` varchar(255) DEFAULT NULL,
#   `startDate` varchar(255) DEFAULT NULL,
#   `endDate` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))



post '/create_wound_area' do
  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  woundAreaCode = req['woundAreaCode']
  woundAreaName = req['woundAreaName']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

 
   p creating_wound_area(organizationUrl,woundAreaCode,woundAreaName,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_wound_area' do
  retrieve_acess = WoundArea.retrieve_all_wound_area
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_wound_area' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if WoundArea.exists?(:id => req['id'])
    retrieve = WoundArea.retrieve_wound_area(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_wound_area' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
 organizationUrl = req['organizationUrl']
  woundAreaCode = req['woundAreaCode']
  woundAreaName = req['woundAreaName']
  groupCode = req['groupCode']
  sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if WoundArea.exists?(:id => req['id'])
    get_update_wound_area(id,organizationUrl,woundAreaCode,woundAreaName,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_wound_area' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if WoundArea.exists?(:id => req['id'])

    WoundArea.where(id: id).destroy_all

    puts "-----------DELETING WoundArea------------------"
    
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




 # CREATE TABLE `referral_source_notes` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `referralSourceUid` varchar(255) DEFAULT NULL,
 #  `date` varchar(255) DEFAULT NULL,
 #  `noteBy` float DEFAULT NULL,
 #  `noteType` varchar(255) DEFAULT NULL,
 #  `document` varchar(255) DEFAULT NULL,
 #  `note` varchar(255) DEFAULT NULL,
 #  `active` tinyint(1) DEFAULT NULL,
 #  `updatedBy` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))

    ### physician_notes URL  START
post '/create_referral_source_notes' do
  request.body.rewind
  req = JSON.parse request.body.read

  referralSourceUid = req['referralSourceUid']
  date = req['date']
  noteBy = req['noteBy']
  noteType = req['noteType']
  document = req['document']
  note = req['note']
  active = req['active']
  updatedBy = req['updatedBy']
  
   p creating_referral_source_notes(referralSourceUid,date,noteBy,noteType,document,note,active,updatedBy)
   success  =  { resp_code: '000',resp_desc: 'Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_referral_source_notes' do
  retrieve_acess = ReferralSourceNotes.retrieve_referral_source_notes
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_referral_source_notes' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if ReferralSourceNotes.exists?(:id => req['id'])
    retrieve = ReferralSourceNotes.retrieve_single_referral_source_notes(id)
    puts "-----------RETRIEVING Payment------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Notes  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_single_referral_source_notes_with_referralSourceUid' do

  request.body.rewind
  req = JSON.parse request.body.read

  referralSourceUid = req['referralSourceUid']
  if ReferralSourceNotes.exists?(:referralSourceUid => req['referralSourceUid'])
    retrieve = ReferralSourceNotes.retrieve_single_referral_source_notes_referralSourceUid(referralSourceUid)
    puts "-----------RETRIEVING Payment------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Notes  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




post '/update_referral_source_notes' do
  puts "------------------UPDATING payments API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
 referralSourceUid = req['referralSourceUid']
  date = req['date']
  noteBy = req['noteBy']
  noteType = req['noteType']
  document = req['document']
  note = req['note']
  active = req['active']
  updatedBy = req['updatedBy']
    
      if ReferralSourceNotes.exists?(:id => req['id'])
    get_update_referral_source_notes(id,referralSourceUid,date,noteBy,noteType,document,note,active,updatedBy)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_referral_source_notes' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if ReferralSourceNotes.exists?(:id => req['id'])

    ReferralSourceNotes.where(id: id).destroy_all
    puts "-----------DELETING PayerNotes------------------"
    del = [{resp_code: '000', resp_desc: 'Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





 # CREATE TABLE `referral_source_ancillary_phone` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `referralSourceUid` varchar(255) DEFAULT NULL,
 #  `phoneType` varchar(255) DEFAULT NULL,
 #  `phone` varchar(255) DEFAULT NULL,
 #  `description` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`))

    ### physician_notes URL  START
post '/create_referral_source_ancillary_phone' do
  request.body.rewind
  req = JSON.parse request.body.read

  referralSourceUid = req['referralSourceUid']
  phoneType = req['phoneType']
  phone = req['phone']
  description = req['description']
 
  
   p creating_referral_source_ancillary_phone(referralSourceUid,phoneType,phone,description)
   success  =  { resp_code: '000',resp_desc: 'Successfully Created'} 
   return success.to_json 
     
end



get '/retrieve_all_referral_source_ancillary_phone' do
  retrieve_acess = ReferralSourceAncillaryPhone.retrieve_referral_source_ancillary_phone
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_single_referral_source_ancillary_phone' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if ReferralSourceAncillaryPhone.exists?(:id => req['id'])
    retrieve = ReferralSourceAncillaryPhone.retrieve_single_referral_source_ancillary_phone(id)
    puts "-----------RETRIEVING Payment------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Notes  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_single_referral_source_ancillary_phone_with_referralSourceUid' do

  request.body.rewind
  req = JSON.parse request.body.read

  referralSourceUid = req['referralSourceUid']
  if ReferralSourceAncillaryPhone.exists?(:referralSourceUid => req['referralSourceUid'])
    retrieve = ReferralSourceAncillaryPhone.retrieve_single_referral_source_ancillary_phone_with_referralSourceUid(referralSourceUid)
    puts "-----------RETRIEVING Payment------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'No Payer Notes  found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/update_referral_source_ancillary_phone' do
  puts "------------------UPDATING payments API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   id = req['id']
 referralSourceUid = req['referralSourceUid']
  phoneType = req['phoneType']
  phone = req['phone']
  description = req['description']
    
      if ReferralSourceAncillaryPhone.exists?(:id => req['id'])
    get_update_referral_source_ancillary_phone(id,referralSourceUid,phoneType,phone,description)

      regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

               else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_referral_source_ancillary_phone' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if ReferralSourceAncillaryPhone.exists?(:id => req['id'])

    ReferralSourceAncillaryPhone.where(id: id).destroy_all
    
    del = [{resp_code: '000', resp_desc: 'Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end







  # CREATE TABLE `ar_lookup_agency_payment_types` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `code` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



post '/create_ar_lookup_agency_payment_types' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  description = req['description']
   code = req['code']
    groupCode = req['groupCode']
     sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']


   p creating_ar_lookup_agency_payment_types(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_arlookup_agency_payment_types' do
  retrieve_acess = ArLookupAgencyPaymentTypes.retrieve_all_arlookup_agency_payment_types
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_arlookup_agency_payment_types' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if ArLookupAgencyPaymentTypes.exists?(:id => req['id'])
    retrieve = ArLookupAgencyPaymentTypes.retrieve_arlookup_agency_payment_type(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/retrieve_arlookup_agency_payment_types_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if ArLookupAgencyPaymentTypes.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = ArLookupAgencyPaymentTypes.retrieve_arlookup_agency_payment_type_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_arlookup_agency_payment_type' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   organizationUrl = req['organizationUrl']
  description = req['description']
   code = req['code']
    groupCode = req['groupCode']
     sortOrder = req['sortOrder']
  startDate = req['startDate']
  endDate = req['endDate']

    
     if ArLookupAgencyPaymentTypes.exists?(:id => req['id'])
     get_update_arlookup_agency_payment_type(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_arlookup_agency_payment_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if ArLookupAgencyPaymentTypes.exists?(:id => req['id'])

    ArLookupAgencyPaymentTypes.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 



####



  # CREATE TABLE `ar_adjustment_reason_type` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `code` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `arSubcategory` varchar(255) DEFAULT NULL,
  # `allowForGross` tinyint(1) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))





### referral_source_contacts START
post '/create_ar_adjustment_reason_type' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  code = req['code']
  description = req['description']
  arSubcategory = req['arSubcategory']
   allowForGross = req['allowForGross']
   groupCode = req['groupCode']
    sortOrder = req['sortOrder']
    startDate = req['startDate']
    endDate = req['endDate']
   


   p creating_ar_adjustment_reason_type(organizationUrl,code,description,arSubcategory,allowForGross,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_ar_adjustment_reason_type' do
  retrieve_acess = ArAdjustmentReasonType.retrieve_all_ar_adjustment_reason_type
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_ar_adjustment_reason_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if ArAdjustmentReasonType.exists?(:id => req['id'])
    retrieve = ArAdjustmentReasonType.retrieve_ar_adjustment_reason_type(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_ar_adjustment_reason_type_organizationUrl' do

  request.body.rewind
  req = JSON.parse request.body.read

  organizationUrl = req['organizationUrl']
  if ArAdjustmentReasonType.exists?(:organizationUrl => req['organizationUrl'])
    retrieve = ArAdjustmentReasonType.retrieve_ar_adjustment_reason_type_organizationUrl(organizationUrl)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_ar_adjustment_reason_type' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   organizationUrl = req['organizationUrl']
  code = req['code']
  description = req['description']
  arSubcategory = req['arSubcategory']
   allowForGross = req['allowForGross']
   groupCode = req['groupCode']
    sortOrder = req['sortOrder']
    startDate = req['startDate']
    endDate = req['endDate']

    
     if ArAdjustmentReasonType.exists?(:id => req['id'])
     get_update_ar_adjustment_reason_type(id,organizationUrl,code,description,arSubcategory,allowForGross,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


                    else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
  end

post '/delete_ar_adjustment_reason_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if ArAdjustmentReasonType.exists?(:id => req['id'])

    ArAdjustmentReasonType.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 







  # CREATE TABLE `assessment_void_reason_type` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `code` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `followupDays` varchar(255) DEFAULT NULL,
  # `generateWorkflow` tinyint(1) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_assessment_void_reason_type' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  code = req['code']
  description = req['description']
  followupDays = req['followupDays']
   generateWorkflow = req['generateWorkflow']
   groupCode = req['groupCode']
    sortOrder = req['sortOrder']
    startDate = req['startDate']
    endDate = req['endDate']
   


   p creating_assessment_void_reason_type(organizationUrl,code,description,followupDays,generateWorkflow,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_assessment_void_reason_type' do
  retrieve_acess = AssessmentVoidReasonType.retrieve_all_assessment_void_reason_type
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_assessment_void_reason_type' do  

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if AssessmentVoidReasonType.exists?(:id => req['id'])
    retrieve = AssessmentVoidReasonType.retrieve_assessment_void_reason_type(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_assessment_void_reason_type' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  code = req['code']
  description = req['description']
  followupDays = req['followupDays']
   generateWorkflow = req['generateWorkflow']
   groupCode = req['groupCode']
    sortOrder = req['sortOrder']
    startDate = req['startDate']
    endDate = req['endDate']

    
     if AssessmentVoidReasonType.exists?(:id => req['id'])
     get_update_assessment_void_reason_type(id,organizationUrl,code,description,followupDays,generateWorkflow,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/delete_assessment_void_reason_type' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if AssessmentVoidReasonType.exists?(:id => req['id'])

    AssessmentVoidReasonType.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 







  # CREATE TABLE `care_needs` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `restrictToAgencyType` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_care_needs' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  restrictToAgencyType = req['restrictToAgencyType']
  description = req['description']
   groupCode = req['groupCode']
    sortOrder = req['sortOrder']
    startDate = req['startDate']
    endDate = req['endDate']
   


   p creating_care_needs(organizationUrl,restrictToAgencyType,description,groupCode,sortOrder,
    startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_care_needs' do
  retrieve_acess = CareNeeds.retrieve_all_care_needs
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_care_needs' do  

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if CareNeeds.exists?(:id => req['id'])
    retrieve = CareNeeds.retrieve_care_needs(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_care_needs' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
    organizationUrl = req['organizationUrl']
  restrictToAgencyType = req['code']
  description = req['description']
   groupCode = req['groupCode']
    sortOrder = req['sortOrder']
    startDate = req['startDate']
    endDate = req['endDate']

    
     if CareNeeds.exists?(:id => req['id'])
     get_update_care_needs(id,organizationUrl,restrictToAgencyType,description,groupCode,sortOrder,
    startDate,endDate)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json


       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/delete_care_needs' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if CareNeeds.exists?(:id => req['id'])

    CareNeeds.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  # CREATE TABLE `care_plan_prognosis` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `code` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `useOnCarePlan` tinyint(1) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_care_plan_prognosis' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  code = req['code']
  description = req['description']
   useOnCarePlan = req['useOnCarePlan']
    sortOrder = req['sortOrder']

   p creating_care_plan_prognosis(organizationUrl,code,description,useOnCarePlan,sortOrder)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_care_plan_prognosis' do
  retrieve_acess = CarePlanPrognosis.retrieve_all_care_plan_prognosis
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_care_plan_prognosis' do  

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if CarePlanPrognosis.exists?(:id => req['id'])
    retrieve = CarePlanPrognosis.retrieve_care_plan_prognosis(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_care_plan_prognosis' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
    organizationUrl = req['organizationUrl']
  code = req['code']
  description = req['description']
   useOnCarePlan = req['useOnCarePlan']
    sortOrder = req['sortOrder']

    
     if CarePlanPrognosis.exists?(:id => req['id'])
     get_update_care_plan_prognosis(id,organizationUrl,code,description,useOnCarePlan,sortOrder)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/delete_care_plan_prognosis' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if CarePlanPrognosis.exists?(:id => req['id'])

    CarePlanPrognosis.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  # CREATE TABLE `case_communication_descriptions` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `prefix` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `suffix` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_case_communication_descriptions' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  prefix = req['prefix']
  description = req['description']
   suffix = req['suffix']
    startDate = req['startDate']
     endDate = req['endDate']

   p creating_case_communication_descriptions(organizationUrl,prefix,description,suffix,startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_case_communication_descriptions' do
  retrieve_acess = CaseCommunicationDescriptions.retrieve_all_case_communication_descriptions
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_case_communication_descriptions' do  

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if CaseCommunicationDescriptions.exists?(:id => req['id'])
    retrieve = CaseCommunicationDescriptions.retrieve_case_communication_descriptions(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_case_communication_descriptions' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  prefix = req['prefix']
  description = req['description']
   suffix = req['suffix']
    startDate = req['startDate']
     endDate = req['endDate']

    
     if CaseCommunicationDescriptions.exists?(:id => req['id'])
     get_update_case_communication_descriptions(id,organizationUrl,prefix,description,suffix,startDate,endDate)

regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/delete_case_communication_descriptions' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if CaseCommunicationDescriptions.exists?(:id => req['id'])

    CaseCommunicationDescriptions.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  # CREATE TABLE `goals` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `relatedToCn` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `disciplineCode` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `responseRequired` varchar(255) DEFAULT NULL,
  # `restrictToAgencyType` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_goals' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  relatedToCn = req['relatedToCn']
  description = req['description']
   disciplineCode = req['disciplineCode']
   groupCode = req['groupCode']
   sortOrder = req['sortOrder']
   responseRequired = req['responseRequired']
   restrictToAgencyType = req['restrictToAgencyType']
    startDate = req['startDate']
     endDate = req['endDate']

   p creating_goals(organizationUrl,relatedToCn,description,disciplineCode,groupCode,sortOrder,startDate,endDate,responseRequired,restrictToAgencyType)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_goals' do
  retrieve_acess = Goals.retrieve_all_goals
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_goals' do  

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if Goals.exists?(:id => req['id'])
    retrieve = Goals.retrieve_goals(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_goals' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
     organizationUrl = req['organizationUrl']
  relatedToCn = req['relatedToCn']
  description = req['description']
   disciplineCode = req['disciplineCode']
   groupCode = req['groupCode']
   sortOrder = req['sortOrder']
   responseRequired = req['responseRequired']
   restrictToAgencyType = req['restrictToAgencyType']
    startDate = req['startDate']
     endDate = req['endDate']

    
     if Goals.exists?(:id => req['id'])
     get_update_goals(id,organizationUrl,relatedToCn,description,disciplineCode,groupCode,sortOrder,startDate,endDate,responseRequired,restrictToAgencyType)

regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/delete_goals' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Goals.exists?(:id => req['id'])

    Goals.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 






  # CREATE TABLE `interventions` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `relatedToCn` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `disciplineCode` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `responseRequired` varchar(255) DEFAULT NULL,
  # `restrictToAgencyType` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_interventions' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  relatedToCn = req['relatedToCn']
  description = req['description']
   disciplineCode = req['disciplineCode']
   groupCode = req['groupCode']
   sortOrder = req['sortOrder']
   responseRequired = req['responseRequired']
   restrictToAgencyType = req['restrictToAgencyType']
    startDate = req['startDate']
     endDate = req['endDate']

   p creating_interventions(organizationUrl,relatedToCn,description,disciplineCode,groupCode,sortOrder,startDate,endDate,responseRequired,restrictToAgencyType)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_interventions' do
  retrieve_acess = Interventions.retrieve_all_interventions
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_interventions' do  

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if Interventions.exists?(:id => req['id'])
    retrieve = Interventions.retrieve_interventions(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_interventions' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
     organizationUrl = req['organizationUrl']
  relatedToCn = req['relatedToCn']
  description = req['description']
   disciplineCode = req['disciplineCode']
   groupCode = req['groupCode']
   sortOrder = req['sortOrder']
   responseRequired = req['responseRequired']
   restrictToAgencyType = req['restrictToAgencyType']
    startDate = req['startDate']
     endDate = req['endDate']

    
     if Interventions.exists?(:id => req['id'])
     get_update_interventions(id,organizationUrl,relatedToCn,description,disciplineCode,groupCode,sortOrder,startDate,endDate,responseRequired,restrictToAgencyType)

regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/delete_interventions' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if Interventions.exists?(:id => req['id'])

    Interventions.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 







  # CREATE TABLE `physician_orders_quick_pick_medications` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `medicationName` varchar(255) DEFAULT NULL,
  # `dosage` varchar(255) DEFAULT NULL,
  # `frequency` varchar(255) DEFAULT NULL,
  # `route` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_quick_pick_medications' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  medicationName = req['medicationName']
  dosage = req['dosage']
   frequency = req['frequency']
   route = req['route']
   sortOrder = req['sortOrder']
   groupCode = req['groupCode']
    startDate = req['startDate']
     endDate = req['endDate']

   p creating_quick_pick_medications(organizationUrl,medicationName,dosage,frequency,route,groupCode,sortOrder,startDate,endDate)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_quick_pick_medications' do
  retrieve_acess = QuickPickMedications.retrieve_all_quick_pick_medications
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_quick_pick_medications' do  

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if QuickPickMedications.exists?(:id => req['id'])
    retrieve = QuickPickMedications.retrieve_quick_pick_medications(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_quick_pick_medications' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   organizationUrl = req['organizationUrl']
  medicationName = req['medicationName']
  dosage = req['dosage']
   frequency = req['frequency']
   route = req['route']
   sortOrder = req['sortOrder']
   groupCode = req['groupCode']
    startDate = req['startDate']
     endDate = req['endDate']

    
     if QuickPickMedications.exists?(:id => req['id'])
     get_update_quick_pick_medications(id,organizationUrl,medicationName,dosage,frequency,route,groupCode,sortOrder,startDate,endDate)

regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/delete_quick_pick_medications' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if QuickPickMedications.exists?(:id => req['id'])

    QuickPickMedications.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end 




  # CREATE TABLE `medication_kits` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `medicationKit` varchar(255) DEFAULT NULL,
  # `description` varchar(255) DEFAULT NULL,
  # `dosage` varchar(255) DEFAULT NULL,
  # `frequency` varchar(255) DEFAULT NULL,
  # `route` varchar(255) DEFAULT NULL,
  # `groupCode` varchar(255) DEFAULT NULL,
  # `sortOrder` varchar(255) DEFAULT NULL,
  # `startDate` varchar(255) DEFAULT NULL,
  # `endDate` varchar(255) DEFAULT NULL,
  #  `type` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_medication_kits' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  medicationKit = req['medicationKit']
  description = req['description']
  dosage = req['dosage']
   frequency = req['frequency']
   route = req['route']
   sortOrder = req['sortOrder']
   groupCode = req['groupCode']
    startDate = req['startDate']
     endDate = req['endDate']
       type = req['type']

   p creating_medication_kits(organizationUrl,medicationKit,description,dosage,frequency,route,groupCode,sortOrder,startDate,endDate,type)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_medication_kits' do
  retrieve_acess = MedicationKits.retrieve_all_medication_kits
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_medication_kits' do  

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if MedicationKits.exists?(:id => req['id'])
    retrieve = MedicationKits.retrieve_medication_kits(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_medication_kits' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
   organizationUrl = req['organizationUrl']
  medicationKit = req['medicationKit']
  description = req['description']
  dosage = req['dosage']
   frequency = req['frequency']
   route = req['route']
   sortOrder = req['sortOrder']
   groupCode = req['groupCode']
    startDate = req['startDate']
     endDate = req['endDate']
       type = req['type']

    
     if MedicationKits.exists?(:id => req['id'])
     get_update_medication_kits(id,organizationUrl,medicationKit,description,dosage,frequency,route,groupCode,sortOrder,startDate,endDate,type)

regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/delete_medication_kits' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if MedicationKits.exists?(:id => req['id'])

    MedicationKits.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




  # CREATE TABLE `supervisory_due_day` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `agencyUrl` varchar(255) DEFAULT NULL,
  # `payerUrl` varchar(255) DEFAULT NULL,
  # `agencyType` varchar(255) DEFAULT NULL,
  # `serviceCategory` varchar(255) DEFAULT NULL,
  # `code` varchar(255) DEFAULT NULL,
  # `supervisoryDueDays` varchar(255) DEFAULT NULL,
  # `autoGenerate` tinyint(1) DEFAULT NULL,
  # `service` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



### referral_source_contacts START
post '/create_supervisory_due_day' do
  request.body.rewind
  req = JSON.parse request.body.read

   organizationUrl = req['organizationUrl']
  agencyUrl = req['agencyUrl']
  payerUrl = req['payerUrl']
  agencyType = req['agencyType']
   serviceCategory = req['serviceCategory']
   code = req['code']
   supervisoryDueDays = req['supervisoryDueDays']
   autoGenerate = req['autoGenerate']
    service = req['service']
   
   p creating_supervisory_due_day(organizationUrl,agencyUrl,payerUrl,agencyType,serviceCategory,code,supervisoryDueDays,autoGenerate,service)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_supervisory_due_day' do
  retrieve_acess = SupervisoryDueDay.retrieve_all_supervisory_due_day
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_supervisory_due_day' do  

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if SupervisoryDueDay.exists?(:id => req['id'])
    retrieve = SupervisoryDueDay.retrieve_supervisory_due_day(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_supervisory_due_day' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  organizationUrl = req['organizationUrl']
  agencyUrl = req['agencyUrl']
  payerUrl = req['payerUrl']
  agencyType = req['agencyType']
   serviceCategory = req['serviceCategory']
   code = req['code']
   supervisoryDueDays = req['supervisoryDueDays']
   autoGenerate = req['autoGenerate']
    service = req['service']

    
     if SupervisoryDueDay.exists?(:id => req['id'])
     get_update_supervisory_due_day(id,organizationUrl,agencyUrl,payerUrl,agencyType,serviceCategory,code,supervisoryDueDays,autoGenerate,service)

    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/delete_supervisory_due_day' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if SupervisoryDueDay.exists?(:id => req['id'])

    SupervisoryDueDay.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end





  # CREATE TABLE `patient_certifications` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `patientUid` varchar(255) DEFAULT NULL,
  # `certFrom` varchar(255) DEFAULT NULL,
  # `spanDays` int(11) DEFAULT NULL,
  # `certTo` varchar(255) DEFAULT NULL,
  # `certType` int(11) DEFAULT NULL,
  # `status` varchar(255) DEFAULT NULL,
  # `info` varchar(255) DEFAULT NULL,
  # `associate` varchar(255) DEFAULT NULL,
  # `physician` varchar(255) DEFAULT NULL,
  # `sent` varchar(255) DEFAULT NULL,
  # `received` varchar(255) DEFAULT NULL,
  # `ftfSent` varchar(255) DEFAULT NULL,
  # `ftfVisit` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`))



post '/create_patient_certifications' do
  request.body.rewind
  req = JSON.parse request.body.read

   patientUid = req['patientUid']
  certFrom = req['certFrom']
  spanDays = req['spanDays']
  certTo = req['certTo']
   certType = req['certType']
   status = req['status']
   info = req['info']
   associate = req['associate']
    physician = req['physician']
    sent = req['sent']
    received = req['received']
    ftfSent = req['ftfSent']
    ftfVisit = req['ftfVisit']
   
   p creating_patient_certifications(patientUid,certFrom,spanDays,certTo,certType,status,info,associate,physician,
    sent,received,ftfSent,ftfVisit)

   success  =  { resp_code: '000',resp_desc: ' Successfully created'} 
   return success.to_json 
     
end



get '/retrieve_all_patient_certifications' do
  retrieve_acess = PatientCertifications.retrieve_all_patient_certifications
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_certifications' do  

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  if PatientCertifications.exists?(:id => req['id'])
    retrieve = PatientCertifications.retrieve_patient_certification(id)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/retrieve_patient_certifications_with_patientUid' do  

  request.body.rewind
  req = JSON.parse request.body.read

  patientUid = req['patientUid']
  if PatientCertifications.exists?(:patientUid => req['patientUid'])
    retrieve = PatientCertifications.retrieve_patient_certification_with_patientUid(patientUid)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_patient_certification' do
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
  patientUid = req['patientUid']
  certFrom = req['certFrom']
  spanDays = req['spanDays']
  certTo = req['certTo']
   certType = req['certType']
   status = req['status']
   info = req['info']
   associate = req['associate']
    physician = req['physician']
    sent = req['sent']
    received = req['received']
    ftfSent = req['ftfSent']
    ftfVisit = req['ftfVisit']

    
     if PatientCertifications.exists?(:id => req['id'])
     get_update_patient_certifications(id,patientUid,certFrom,spanDays,certTo,certType,status,info,associate,physician,
    sent,received,ftfSent,ftfVisit)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



post '/delete_patient_certification' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if PatientCertifications.exists?(:id => req['id'])

    PatientCertifications.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end




  # CREATE TABLE `referralSourceAddressPhoneInfo` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `referralSourceUid,` varchar(255) DEFAULT NULL,
  # `addressType` varchar(255) DEFAULT NULL,
  # `address1` varchar(255) DEFAULT NULL,
  # `address2` varchar(255) DEFAULT NULL,
  # `city` varchar(255) DEFAULT NULL,
  # `state` varchar(255) DEFAULT NULL,
  # `zip` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)



### AddressPhoneInfo  START
post '/create_referralSourceAddressPhoneInfo' do
  request.body.rewind
  req = JSON.parse request.body.read

  referralSourceUid = req['referralSourceUid']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
  addressPhoneInfoPhones = req['addressPhoneInfoPhones']
  


  if addressType.length < 1 
     halt ADD_TYPE_ERR.to_json
   elsif address1.length< 1
      halt ADDRESS_ERR.to_json
       elsif city.length< 1
      halt CITY_ERR.to_json
       elsif state.length< 1
      halt STATE_ERR.to_json
       elsif zip.length< 1
      halt ZIP_ERR.to_json
  
   end
  

   p creating_referralSourceAddressPhoneInfo(referralSourceUid,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)

   success  =  { resp_code: '000',resp_desc: 'Successfully created'} 
   return success.to_json 
     
end




get '/retrieve_all_referralSourceAddressPhoneInfo' do
  retrieve_acess = ReferralSourceAddressPhoneInfo.retrieve_referralSourceAddressPhoneInfo
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_referralSourceAddressPhoneInfo' do

  request.body.rewind
  req = JSON.parse request.body.read

  referralSourceUid = req['referralSourceUid']
  if ReferralSourceAddressPhoneInfo.exists?(:referralSourceUid => req['referralSourceUid'])
    retrieve = ReferralSourceAddressPhoneInfo.retrieve_single_referralSourceAddressPhoneInfo(referralSourceUid)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_referralSourceAddressPhoneInfo' do
  puts "------------------UPDATING update_status_history API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']
 referralSourceUid = req['referralSourceUid']
  addressType = req['addressType']
  address1 = req['address1']
  address2 = req['address2']
  city = req['city']
  state = req['state']
  zip = req['zip']
 addressPhoneInfoPhones = req['addressPhoneInfoPhones']
    

     if ReferralSourceAddressPhoneInfo.exists?(:id => req['id'])
    get_update_referralSourceAddressPhoneInfo(id,referralSourceUid,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated addressPhoneInfos!'}

    regis_success.to_json

                       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_referralSourceAddressPhoneInfo' do

  request.body.rewind
  req = JSON.parse request.body.read

  id = req['id']

  if ReferralSourceAddressPhoneInfo.exists?(:id => req['id'])

    ReferralSourceAddressPhoneInfo.where(id: id).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


###PAtient FOrms
  # CREATE TABLE `patient_forms` (
  # `id` int(11) NOT NULL AUTO_INCREMENT,
  # `uid,` varchar(255) DEFAULT NULL,
  # `patientID` varchar(255) DEFAULT NULL,
  # `formType` varchar(255) DEFAULT NULL,
  # `agency` varchar(255) DEFAULT NULL,
  # `status` varchar(255) DEFAULT NULL,
  # `revisedBy` varchar(255) DEFAULT NULL,
  # `performedBy` varchar(255) DEFAULT NULL,
  # `payload` varchar(255) DEFAULT NULL,
  # `organizationUrl` varchar(255) DEFAULT NULL,
  # `created_at` datetime NOT NULL,
  # `updated_at` datetime DEFAULT NULL,
  # PRIMARY KEY (`id`)

# uid: uuid(),
# patientID: '',
# formType,
# agency: 'Sinam Care, LLC',
# status: 'active',
# revisedBy: `Nick Dadzi`,
# performedBy: `${patient?.firstName} ${patient?.lastName}`,
# createdAt: Date.now(),
# payload: ''
# organizationUrl: ""


### AddressPhoneInfo  START
post '/create_patient_forms' do
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  patientID = req['patientID']
  formType = req['formType']
  agency = req['agency']
  status = req['status']
  revisedBy = req['revisedBy']
  performedBy = req['performedBy']
  payload = req['payload']
  organizationUrl = req['organizationUrl']
  


   p creating_patient_forms(uid,patientID,formType,agency,status,revisedBy,performedBy,payload,organizationUrl)

   success  =  { resp_code: '000',resp_desc: 'Successfully created'} 
   return success.to_json 
     
end




get '/retrieve_all_patientForms' do
  retrieve_acess = PatientForm.retrieve_patient_forms
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patientForms' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientForm.exists?(:uid => req['uid'])
    retrieve = PatientForm.retrieve_single_patient_forms(uid)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_patientForms' do
  puts "------------------UPDATING update_status_history API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  patientID = req['patientID']
  formType = req['formType']
  agency = req['agency']
  status = req['status']
  revisedBy = req['revisedBy']
  performedBy = req['performedBy']
  payload = req['payload']
  organizationUrl = req['organizationUrl']
    

     if PatientForm.exists?(:uid => req['uid'])
    get_update_patientForms(uid,patientID,formType,agency,status,revisedBy,performedBy,payload,organizationUrl)
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

                       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patientForms' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientForm.exists?(:uid => req['uid'])

    PatientForm.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end






##PATIENT DOCUMENTS
 # CREATE TABLE `patient_documents` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `uid` varchar(255) DEFAULT NULL,
 #  `patientID` varchar(255) DEFAULT NULL,
 #  `file` varchar(255) DEFAULT NULL,
 #  `relatedTo` varchar(255) DEFAULT NULL,
 #  `status` varchar(255) DEFAULT NULL,
 #  `documentType` varchar(255) DEFAULT NULL,
 #  `description` varchar(255) DEFAULT NULL,
 #  `uploadedBy` varchar(255) DEFAULT NULL,
 #  `organizationUrl` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`)


post '/create_patient_documents' do
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  patientID = req['patientID']
  file = req['file']
  relatedTo = req['relatedTo']
  status = req['status']
  documentType = req['documentType']
  description = req['description']
  uploadedBy = req['uploadedBy']
  organizationUrl = req['organizationUrl']

   p creating_patient_documents(uid,patientID,file,relatedTo,status,documentType,description,uploadedBy,organizationUrl)

   success  =  { resp_code: '000',resp_desc: 'Successfully created'} 
   return success.to_json 
     
end




get '/retrieve_all_patient_documents' do
  retrieve_acess = PatientDocument.retrieve_patient_documents
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_documents' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientDocument.exists?(:uid => req['uid'])
    retrieve = PatientDocument.retrieve_single_patient_documents(uid)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_patient_documents' do
  puts "------------------UPDATING update_status_history API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

   uid = req['uid']
  patientID = req['patientID']
  file = req['file']
  relatedTo = req['relatedTo']
  status = req['status']
  documentType = req['documentType']
  description = req['description']
  uploadedBy = req['uploadedBy']
  organizationUrl = req['organizationUrl']
    

     if PatientDocument.exists?(:uid => req['uid'])
   
   get_update_patient_documents(uid,patientID,file,relatedTo,status,documentType,description,uploadedBy,organizationUrl) 

   
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

                       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_documents' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientDocument.exists?(:uid => req['uid'])

    PatientDocument.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



##PATIENT DOCUMENTS
 # CREATE TABLE `patient_medications` (
 #  `id` int(11) NOT NULL AUTO_INCREMENT,
 #  `uid` varchar(255) DEFAULT NULL,
 #  `entryType` varchar(255) DEFAULT NULL,
 #  `description` varchar(255) DEFAULT NULL,
 #  `dosage` varchar(255) DEFAULT NULL,
 #  `dosageAndFrequency` varchar(255) DEFAULT NULL,
 #  `route` varchar(255) DEFAULT NULL,
 #  `quantity` varchar(255) DEFAULT NULL,
 #  `startDate` varchar(255) DEFAULT NULL,
 #  `endDate` varchar(255) DEFAULT NULL,
 #  `medicationType` varchar(255) DEFAULT NULL,
 #  `prescribedBy` varchar(255) DEFAULT NULL,
 #  `administeredBy` varchar(255) DEFAULT NULL,
 #  `reasonForMedication` varchar(255) DEFAULT NULL,
 #  `pharmacy` varchar(255) DEFAULT NULL,
 #  `physicianNotified` varchar(255) DEFAULT NULL,
 #  `approvedBy` varchar(255) DEFAULT NULL,
 #  `createInterimCare` varchar(255) DEFAULT NULL,
 #  `effectiveDate` varchar(255) DEFAULT NULL,
 #  `patientID` varchar(255) DEFAULT NULL,
 #  `organizationUrl` varchar(255) DEFAULT NULL,
 #  `created_at` datetime NOT NULL,
 #  `updated_at` datetime DEFAULT NULL,
 #  PRIMARY KEY (`id`)


post '/create_patient_medications' do
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  entryType = req['entryType']
  description = req['description']
  dosage = req['dosage']
  dosageAndFrequency = req['dosageAndFrequency']
  route = req['route']
  quantity = req['quantity']
  startDate = req['startDate']
  endDate = req['endDate']
  medicationType = req['medicationType']
  prescribedBy = req['prescribedBy']
  administeredBy = req['administeredBy']
  reasonForMedication = req['reasonForMedication']
  pharmacy = req['pharmacy']
  physicianNotified = req['physicianNotified']
  approvedBy = req['approvedBy']
  createInterimCare = req['createInterimCare']
  effectiveDate = req['effectiveDate']
  patientID = req['patientID']
  organizationUrl = req['organizationUrl']

   p creating_patient_medications(uid,entryType,description,dosage,dosageAndFrequency,route,quantity,
    startDate,endDate,medicationType,prescribedBy,administeredBy,reasonForMedication,pharmacy,physicianNotified,approvedBy,
    createInterimCare,effectiveDate,patientID,organizationUrl)

   success  =  { resp_code: '000',resp_desc: 'Successfully created'} 
   return success.to_json 
     
end




get '/retrieve_all_patient_medications' do
  retrieve_acess = PatientMedication.retrieve_patient_medications
  puts retrieve_acess.to_json
  return retrieve_acess.to_json
end

post '/retrieve_patient_medications' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  if PatientMedication.exists?(:uid => req['uid'])
    retrieve = PatientMedication.retrieve_single_patient_medications(uid)
    puts "-----------RETRIEVING Organization------------------"
    puts retrieve
    puts retrieve.to_json

  return retrieve.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end


post '/update_patient_medications' do
  puts "------------------UPDATING update_status_history API ------------------"
  
  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']
  entryType = req['entryType']
  description = req['description']
  dosage = req['dosage']
  dosageAndFrequency = req['dosageAndFrequency']
  route = req['route']
  quantity = req['quantity']
  startDate = req['startDate']
  endDate = req['endDate']
  medicationType = req['medicationType']
  prescribedBy = req['prescribedBy']
  administeredBy = req['administeredBy']
  reasonForMedication = req['reasonForMedication']
  pharmacy = req['pharmacy']
  physicianNotified = req['physicianNotified']
  approvedBy = req['approvedBy']
  createInterimCare = req['createInterimCare']
  effectiveDate = req['effectiveDate']
  patientID = req['patientID']
  organizationUrl = req['organizationUrl']
    

     if PatientMedication.exists?(:uid => req['uid'])
   
  get_update_patient_medications(uid,entryType,description,dosage,dosageAndFrequency,route,quantity,
    startDate,endDate,medicationType,prescribedBy,administeredBy,reasonForMedication,pharmacy,physicianNotified,approvedBy,
    createInterimCare,effectiveDate,patientID,organizationUrl)
   
    regis_success = { resp_code: '000',resp_desc: 'You have successfully updated!'}

    regis_success.to_json

                       else
     no_location = [{resp_code: '101', resp_desc: 'Cant update -- No id found' }]
     puts "-------------------- SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
    
 
end

post '/delete_patient_medications' do

  request.body.rewind
  req = JSON.parse request.body.read

  uid = req['uid']

  if PatientMedication.exists?(:uid => req['uid'])

    PatientMedication.where(uid: uid).destroy_all
    puts "-----------DELETING Associate------------------"
    del = [{resp_code: '000', resp_desc: ' Deleted' }]
    puts del.to_json

  return del.to_json
   else
     no_location = [{resp_code: '101', resp_desc: 'Not found' }]
     puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
       puts "--------------------------------------------"
   halt no_location.to_json 
 end
end



# CREATE TABLE `bulk_import` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `organizationUrl` varchar(255) DEFAULT NULL,
#   `resourceType` varchar(255) DEFAULT NULL,
#   `created_at` datetime NOT NULL,
#   `updated_at` datetime DEFAULT NULL,
#   PRIMARY KEY (`id`))


post '/import_data' do
 
   
  if params[:file].nil? 
          no_location = [{resp_code: '101', resp_desc: 'Not found' }]
    puts "--------------------LOCATION SHITT------------------------"
     puts no_location.to_json
      else               
        # check = ""        
        check = BulkImport.import_data(params[:file][:tempfile])   
         del = [{resp_code: '000', resp_desc: ' Data successfully imported' }]
          puts del.to_json     
       puts "LETS CHECK:::: #{check.inspect} "
        
      end

end



















