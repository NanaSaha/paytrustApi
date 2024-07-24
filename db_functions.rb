PHONE_TYPE_ERR = {resp_code: '101', resp_desc: "Phone Type should exists."}
PHONE_ERR = {resp_code: '101', resp_desc: "Phone should exists."}
ADD_TYPE_ERR = {resp_code: '101', resp_desc: "Address Type should exists."}
ADDRESS_ERR = {resp_code: '101', resp_desc: "Address should exists."}
CITY_ERR = {resp_code: '101', resp_desc: "City should exists."}
STATE_ERR = {resp_code: '101', resp_desc: "State should exists."}
ZIP_ERR = {resp_code: '101', resp_desc: "Zip should exists."}
RELA_ERR = {resp_code: '101', resp_desc: "relationship should exists."}
ASS_URL_ERR = {resp_code: '101', resp_desc: "associateUrl should exists."}
P_TYPE_ERR = {resp_code: '101', resp_desc: "payrollType should exists."}
FED_FIL_ERR = {resp_code: '101', resp_desc: "federalFillingStatus should exists."}
STATE_FIL_ERR = {resp_code: '101', resp_desc: "stateFillingStatus should exists."}
STATE_D_ERR = {resp_code: '101', resp_desc: "stateDeductions should exists."}
DDT_ERR = {resp_code: '101', resp_desc: "startDate should exists."}
SAL_ERR = {resp_code: '101', resp_desc: "salary should exists."}
REG_ERR = {resp_code: '101', resp_desc: "region Url should exists."}
AGENCY_ERR = {resp_code: '101', resp_desc: "agencyName should exists."}
EMAIL_ERR = {resp_code: '101', resp_desc: "Email should exists."}
ORG_ERR = {resp_code: '101', resp_desc: "Organiztion  Url should exists."}
REG_NMA_ERR = {resp_code: '101', resp_desc: "region Name should exists."}
DDC_ERR = {resp_code: '101', resp_desc: "Deduction should exists."}
AMT_ERR = {resp_code: '101', resp_desc: "Amount should exists."}
PAY_TYPE_ERR = {resp_code: '101', resp_desc: "payType should exists."}
SERV_ERR = {resp_code: '101', resp_desc: "serviceDescription should exists."}
WR_ERR = {resp_code: '101', resp_desc: "weekdayRate should exists."}
WNR_ERR = {resp_code: '101', resp_desc: "weekendRate should exists."}
LIC_TYPE_ERR = {resp_code: '101', resp_desc: "License should exists."}
LIC_NUM_ERR = {resp_code: '101', resp_desc: "License number should exists."}
LIC_STAT_ERR = {resp_code: '101', resp_desc: "License state should exists."}
ISSUE_ERR = {resp_code: '101', resp_desc: "Issue Date should exists."}
LIC_SS_ERR = {resp_code: '101', resp_desc: "licenseStatus should exists."}
EX_DATE_ERR = {resp_code: '101', resp_desc: "expirationDate should exists."}
PHY_URL_ERR = {resp_code: '101', resp_desc: "Physicial Url should exists."}
IMG_PATH = '/opt/devdir/saha/escrow_api/public/' 


def  sendEmail(email)


    email_sub = "Pay Trust - Transaction Joined"
    str_email=""
    str_email = "You have successfully joined the transaction: \n\n"
    str_email << "Please proceed to complete the transaction\n"
       
    ############## Send email to applicant #################
    send_email(email, str_email, email_sub)


end


def  sendEmailToCreator(email)


  email_sub = "Pay Trust - Transaction Joined"
  str_email=""
  str_email = "Someone has  joined the transaction: \n\n"
  str_email << "Login to confirm the transaction\n"
     
  ############## Send email to applicant #################
  send_email(email, str_email, email_sub)


end


def  insert_details_patient(email,fullname,phone,password,ghana_card,location,profile_pic)


  final_path = IMG_PATH
  
  Dir.mkdir(final_path) unless File.exists?(final_path)  

  blob = params['file'][:tempfile]
  puts "BLOB::::::----#{blob}"

  if blob.length < 1
    final_path = ""
    upload_success  =  { resp_code: '100',resp_desc: 'The file could not be uploaded successfully.'}
    puts "---------UPLOAD FAILED---------"
    puts upload_success 
  else
  
      
    puts "Save Image final path = #{final_path} + picture_name = #{profile_pic}"
    
    File.open("#{final_path}" + profile_pic, "wb") do |f|
      f.write(blob.read)
    end


  Registration.transaction do

    registration = Registration.new(:email => email.strip,:fullname => fullname, :phone => phone,:password => password, :ghana_card => ghana_card,:location => location,:profile_pic => profile_pic)
    registration.save!

    
    fullname = fullname
    email_sub = "Pay Trust - Account Registration"
    str_email=""
    str_email="Dear #{fullname},\n\n"
    str_email << "Thank you for signing up on Pay Trust. Find below your signup details: \n\n"
    str_email << "Name: #{fullname}.\n"
    str_email << "Email: #{email}.\n"
    str_email << "Mobile Number: #{phone}.\n"
  
    str_email << "Thank you for choosing Pay Trust! \nRegards,\nPay Trust\n"
      
    ############## Send email to applicant #################
    send_email(email, str_email, email_sub)

  end
end

end


def genUniqueID
   

    random = 4.times.map { rand(1..9) }
   puts "OTP Code preferedValue: #{random}"
  return "ESC- #{random}"
end




def insert_transactions(person_name,person_email,user_id,amount,fees,item_name,item_description,item_quantity,status)

  Transaction.transaction do

    save_trans = Transaction.new(
        :person_name => person_name.strip,
        :person_email => person_email.strip,
        :user_id => user_id,
        :amount => amount,
        :fees => fees,
        :transaction_id => genUniqueCode,
        :item_name => item_name,
        :item_description => item_description,
        :item_quantity => item_quantity,
        :status => status

        )
    save_trans.save!

    
  
    email_sub = "Pay Trust - Transaction Created"
    str_email=""
    str_email="Dear #{person_name},\n\n"
    str_email << "A transaction was created and shared with you: Find details below:: \n\n"
    str_email << "Item Name: #{item_name}.\n"
    str_email << "Amount: #{amount}.\n"
    str_email << "Quantity: #{item_quantity}.\n"
    str_email << "Transaction ID: #{genUniqueCode}.\n"
     str_email << "Click here to join the transaction https://paytrust.com/#{genUniqueCode}\n"
  
    str_email << "Thank you for choosing Pay Trust! \nRegards,\Pay Trust!\n"
      
    ############## Send email to applicant #################
    send_email(person_email, str_email, email_sub)

   end

end




def insert_seller_transactions(buyer_name,buyer_email,buyer_phone,seller_id,amount,fees,narration,item_name,item_description,transaction_title,paid_by,status)

  SellerTransaction.transaction do

    save_trans = SellerTransaction.new(
        :buyer_name => buyer_name.strip,
        :buyer_email => buyer_email.strip,
        :buyer_phone => buyer_phone, 
        :seller_id => seller_id,
        :amount => amount,
        :fees => fees,
        :transaction_id => genUniqueID,
        :narration => narration,
        :item_name => item_name,
        :item_description => item_description,
        :transaction_title => transaction_title,
        :paid_by => paid_by,
        :status => status

        )
    save_trans.save!

    
    fullname = fullname
    email_sub = "Pay Trust - Transaction Created"
    str_email=""
    str_email="Dear #{buyer_name},\n\n"
    str_email << "A transaction was created and shared with you: Find details below:: \n\n"
    str_email << "Item Name: #{item_name}.\n"
    str_email << "Amount: #{amount}.\n"
    str_email << "Narration: #{narration}.\n"
    str_email << "Fees paid by: #{paid_by}.\n\n"
     str_email << "Click here to join the transaction https://paytrust.com/#{genUniqueID}\n"
  
    str_email << "Thank you for choosing Pay Trust! \nRegards,\nPay Trust\n"
      
    ############## Send email to applicant #################
    send_email(buyer_email, str_email, email_sub)

   end

end


def send_email(recipient_email, email_body, email_subj)
  
  puts Pony.mail({
    :to => recipient_email,
    :from => 'no-reply@paytrust.com',
    :sender => 'no-reply@paytrust.com',
    :subject => email_subj,
    :body => email_body,
    
    
    
    :via => :smtp,
    :via_options => {
      :address              => 'smtp.gmail.com',
      :port                 => '587',
      :enable_starttls_auto => true,
      :user_name            => '', #'ghingerhealthcare1@gmail.com',
      :password             => '',#'lhleljpiskxuegjs', #'wiwkbxgovelwjroi',
      :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain               => "localhost.localdomain", # the HELO domain provided by the client to the server
    }
  })
  
end







def sendmsg(sender_id, recipient_number, message_body)

account_sid = ''
auth_token = ''
@client = Twilio::REST::Client.new(account_sid, auth_token)

from = sender_id # Your Twilio number
to = recipient_number
# to = validatePhoneNumber(recipient_number) # Your mobile phone number
puts "VALID NUMBER #{to}"
puts @client.messages.create(
from: from,
to: to,
body: message_body
)


end




def  edit_profile(id,email,fullname,phone)
 
 
  check = Registration.where(id: id).update(
  email: email,
  fullname: fullname,
  phone: phone,
  updated_at: Time.new.strftime('%F %R')
  )
  puts check.inspect
  
  
#end     
end


# //SYNERDOC API
def creating_associate(firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl)
  
  
  Associate.create(
    
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    ssn: ssn,
    birthDate: birthDate,
    race: race,
    email: email,
    mobileEmail: mobileEmail,
    schedulingRank: schedulingRank,
    classification: classification,
    discipline: discipline,
    hireDate: hireDate,
    startDate: startDate,
    supervisor: supervisor,
    homeAgency: homeAgency,
    associateNumber: associateNumber,
    associateNPI: associateNPI,
    evvVendorID: evvVendorID,
    evvAdminEmail: evvAdminEmail,
    status: status,
    url: url,
    image: image,
    statusReason: statusReason,
    statusDate: statusDate,
    eligibleForRehire: eligibleForRehire,
    gender: gender,
    organizationUrl: organizationUrl,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_associate(id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl)
    puts "------------------UPDATING PROFILE ------------------"
    puts "url is #{url}}"
   
    check = Associate.where(id: id).update(url: url, firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    ssn: ssn,
    birthDate: birthDate,
    race: race,
    email: email,
    mobileEmail: mobileEmail,
    schedulingRank: schedulingRank,
    classification: classification,
    discipline: discipline,
    hireDate: hireDate,
    startDate: startDate,
    supervisor: supervisor,
    homeAgency: homeAgency,
    associateNumber: associateNumber,
    associateNPI: associateNPI,
    evvVendorID: evvVendorID,
    evvAdminEmail: evvAdminEmail,
    status: status,
     url: url,
    image: image,
    statusReason: statusReason,
    statusDate: statusDate,
    eligibleForRehire: eligibleForRehire,
    gender: gender,
    organizationUrl: organizationUrl,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end


def upload_img(url,image)
    puts "------------------UPDATING PROFILE ------------------"
    puts "url is #{url}}"
   
    check = Associate.where(url: url).update(image: image,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end


########### PYSHICIAN FUNTIONS
def creating_physician(firstName,middleName,lastName,title,speciality,email,physicianGroup,endDate,startDate,status,url,salesRep,organizationUrl,updated)
  
  
  Physician.create(
    
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    title: title,
    email: email,
    physicianGroup: physicianGroup,
    endDate: endDate,
    startDate: startDate,
    status: status,
    url: url,
    speciality: speciality,
    salesRep: salesRep,
    organizationUrl: organizationUrl,
    updated: updated,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_physician(id,firstName,middleName,lastName,title,speciality,email,physicianGroup,endDate,startDate,status,url,salesRep,organizationUrl,updated)
    puts "------------------UPDATING PROFILE ------------------"
    puts "url is #{url}}"
   
    check = Physician.where(id: id).update(
        url: url,
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    title: title,
    email: email,
    physicianGroup: physicianGroup,
    endDate: endDate,
    startDate: startDate,
    status: status,
    url: url,
    salesRep: salesRep,
    speciality: speciality,
    organizationUrl: organizationUrl,
    updated: updated,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end

########### END PYSHICIAN FUNTIONS



########### FACILITIES FUNTIONS
def creating_facility(facilityName,facilityType,email,salesRep,endDate,startDate,status,url,organizationUrl,updated,
    patientID,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,phoneType,phone)   
  Facility.create(
    
    facilityName: facilityName,
    facilityType: facilityType,
    email: email,
    salesRep: salesRep,
    endDate: endDate,
    startDate: startDate,
    status: status,
    url: url,
    organizationUrl: organizationUrl,
    updated: updated,
    patientID: patientID,
    addressType: addressType,
    addressOne: addressOne,
    addressTwo: addressTwo,
    city: city,
    state: state,
    zipcode: zipcode,
    placeOfService: placeOfService,
    phoneType: phoneType,
    phone: phone,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_facility(id,facilityName,facilityType,email,salesRep,endDate,startDate,status,url,organizationUrl,updated,
    patientID,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,phoneType,phone)
    puts "------------------UPDATING FACILITY ------------------"
    puts "url is #{url}}"
   
    check = Facility.where(id: id).update(
      facilityName: facilityName,
    facilityType: facilityType,
    email: email,
    salesRep: salesRep,
    endDate: endDate,
    startDate: startDate,
    status: status,
    url: url,
    organizationUrl: organizationUrl,
    updated: updated,
    patientID: patientID,
    addressType: addressType,
    addressOne: addressOne,
    addressTwo: addressTwo,
    city: city,
    state: state,
    zipcode: zipcode,
    placeOfService: placeOfService,
    phoneType: phoneType,
    phone: phone,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end

########### END Facility FUNTIONS


########### STatus FUNTIONS
def creating_status_history(associateUrl,changedBy,newStatus,date,effective,priorStatus,priorStatusReason,newStatusReason)
   
  StatusHistory.create(
    
    associateUrl: associateUrl,
    changedBy: changedBy,
    newStatus: newStatus,
    date: date,
    effective: effective,
    priorStatus: priorStatus,
    priorStatusReason: priorStatusReason,
    newStatusReason: newStatusReason,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_status(id,associateUrl,changedBy,newStatus,date,effective,priorStatus,priorStatusReason,newStatusReason)
    puts "------------------UPDATING STATUS ------------------"
    puts "associateUrl is #{associateUrl}}"
   
    check = StatusHistory.where(id: id).update(
        associateUrl: associateUrl,
    changedBy: changedBy,
    newStatus: newStatus,
    date: date,
    effective: effective,
    priorStatus: priorStatus,
    priorStatusReason: priorStatusReason,
    newStatusReason: newStatusReason,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end

########### END Facility FUNTIONS

########### WEB ACCESS FUNTIONS
def creating_website_access(associateUrl,userName,password,startDate,email,isActive,isLockedOut,endDate,lastLogin,previousLogin,passwordExpires,created,roles,orgUrl,regionUrls,agencyUrls,updated)
   
  WebAccess.create(
    
    associateUrl: associateUrl,
    userName: userName,
    password: password,
    startDate: startDate,
    email: email,
    isActive: isActive,
    isLockedOut: isLockedOut,
    endDate: endDate,
    lastLogin: lastLogin,
    previousLogin: previousLogin,
    passwordExpires: passwordExpires,
    created: created,
    updated: updated,
    roles: roles,
    orgUrl: orgUrl,
    regionUrls: regionUrls,
    agencyUrls: agencyUrls,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_web_access(id,associateUrl,userName,password,startDate,email,isActive,isLockedOut,endDate,lastLogin,previousLogin,passwordExpires,created,roles,orgUrl,regionUrls,agencyUrls,updated)
    puts "------------------UPDATING STATUS ------------------"
    puts "associateUrl is #{associateUrl}}"
   
    check = WebAccess.where(id: id).update(
        associateUrl: associateUrl,
    userName: userName,
    password: password,
    startDate: startDate,
    email: email,
    isActive: isActive,
    isLockedOut: isLockedOut,
    endDate: endDate,
    lastLogin: lastLogin,
    previousLogin: previousLogin,
    passwordExpires: passwordExpires,
    created: created,
     updated: updated,
    roles: roles,
    orgUrl: orgUrl,
    regionUrls: regionUrls,
    agencyUrls: agencyUrls,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end

########### END Facility FUNTIONS


########### ORG FUNTIONS
def creating_organization(url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate)
   
  Organization.create(
    
    url: url,
    organizationName: organizationName,
    organizationCode: organizationCode,
    email: email,
    primaryContact: primaryContact,
    phoneType: phoneType,
    phone: phone,
    companyStartDate: companyStartDate,
    companyEndDate: companyEndDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_organization(id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate)
    puts "------------------UPDATING STATUS ------------------"
    puts "url is #{url}}"
   
    check = Organization.where(id: id).update(
        url: url,
    organizationName: organizationName,
    organizationCode: organizationCode,
    email: email,
    primaryContact: primaryContact,
    phoneType: phoneType,
    phone: phone,
    companyStartDate: companyStartDate,
    companyEndDate: companyEndDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end

########### ORG FUNTIONS END

########### ASSOCIATE NOTES
def creating_associate_notes(associateUrl,noteBy,noteType,document,note,active,date)
   
  AssociateNote.create(
    
    associateUrl: associateUrl,
    noteBy: noteBy,
    noteType: noteType,
    document: document,
    note: note,
    active: active,
    date: date,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_associate_notes(id,associateUrl,noteBy,noteType,document,note,active,date)
    puts "------------------UPDATING STATUS ------------------"
    puts "associateUrl is #{associateUrl}}"
   
    check = AssociateNote.where(id: id).update(
        associateUrl: associateUrl,
    noteBy: noteBy,
    noteType: noteType,
    document: document,
    note: note,
    active: active,
    date: date,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end

########### ASSOCIATE FUNTIONS END


########### ancillaryPhoneInfo NOTES
def creating_ancillaryPhoneInfo(associateUrl,phoneType,phone,description)
   
  AncillaryPhoneInfo.create(
    
    associateUrl: associateUrl,
    phoneType: phoneType,
    phone: phone,
    description: description,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_ancillaryPhoneInfo(id,associateUrl,phoneType,phone,description)
    puts "------------------UPDATING STATUS ------------------"
    puts "associateUrl is #{associateUrl}}"
   
    check = AncillaryPhoneInfo.where(id: id).update(
        associateUrl: associateUrl,
    phoneType: phoneType,
    phone: phone,
    description: description,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end
########### ancillaryPhoneInfo FUNTIONS END



########### addressPhoneInfo NOTES
def creating_addressPhoneInfo(associateUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
   
  AddressPhoneInfo.create(
    
    associateUrl: associateUrl,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_addressPhoneInfo(id,associateUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
    puts "------------------UPDATING STATUS ------------------"
    puts "associateUrl is #{associateUrl}}"
   
    check = AddressPhoneInfo.where(id: id).update(
    associateUrl: associateUrl,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end
########### addressPhoneInfo FUNTIONS END


########### emergencyContacts NOTES
def creating_emergencyContacts(associateUrl,relationship,firstName,lastName,priority,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)

   
  EmergencyContact.create(
    
    associateUrl: associateUrl,
    relationship: relationship,
    firstName: firstName,
    lastName: lastName,
    priority: priority,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_emergencyContacts(id,associateUrl,relationship,firstName,lastName,priority,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
    puts "------------------UPDATING STATUS ------------------"
    puts "associateUrl is #{associateUrl}}"
   
    check = EmergencyContact.where(id: id).update(
        associateUrl: associateUrl,
   relationship: relationship,
    firstName: firstName,
    lastName: lastName,
    priority: priority,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end
########### addressPhoneInfo FUNTIONS END

########### DOCUMENTS NOTES
def creating_documents(associateUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)

   
  Document.create(
    
    associateUrl: associateUrl,
    file: file,
    documentType: documentType,
    documentStatus: documentStatus,
    description: description,
    note: note,
    uploadedBy: uploadedBy,
    uploadedDate: uploadedDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_documents(id,associateUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
    puts "------------------UPDATING STATUS ------------------"
    puts "ID is #{id}}"
   
    check = Document.where(id: id).update(
    associateUrl: associateUrl,
    file: file,
    documentType: documentType,
    documentStatus: documentStatus,
    description: description,
    note: note,
    uploadedBy: uploadedBy,
    uploadedDate: uploadedDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end
########### DOCUMENTS END

########### DOCUMENTS NOTES
def creating_associate_availability(associateUrl,date,day,start,end_time,availability_type,reason)
   
  AssociateAvailability.create(
    
    associateUrl: associateUrl,
    date: date,
    day: day,
    start: start,
    end: end_time,
    availability_type: availability_type,
    reason: reason,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_associate_availability(id,associateUrl,date,day,start,end_time,availability_type,reason)
    puts "------------------UPDATING STATUS ------------------"
    puts "associateUrl is #{associateUrl}}"
   
    check = AssociateAvailability.where(id: id).update(
        associateUrl: associateUrl,
     date: date,
    day: day,
    start: start,
    end: end_time,
    availability_type: availability_type,
    reason: reason,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end
########### DOCUMENTS END

########### PAYROLL NOTES
def creating_payroll(associateUrl,salary,payrollType,federalFillingStatus,stateFillingStatus,stateDeductions,startDate,wbCheck)
   
  Payroll.create(
    
    associateUrl: associateUrl,
    salary: salary,
    payrollType: payrollType,
    federalFillingStatus: federalFillingStatus,
    stateFillingStatus: stateFillingStatus,
    stateDeductions: stateDeductions,
    startDate: startDate,
    wbCheck: wbCheck,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_payroll(id,associateUrl,salary,payrollType,federalFillingStatus,stateFillingStatus,stateDeductions,startDate,wbCheck)
    puts "------------------UPDATING STATUS ------------------"
    puts "associateUrl is #{associateUrl}}"
   
    check = AssociateAvailability.where(id: id).update(
        associateUrl: associateUrl,
    salary: salary,
    payrollType: payrollType,
    federalFillingStatus: federalFillingStatus,
    stateFillingStatus: stateFillingStatus,
    stateDeductions: stateDeductions,
    startDate: startDate,
    wbCheck: wbCheck,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end



########### AGENCY NOTES
def creating_agency(url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated)
 
  Agency.create(
    
    url: url,
    organizationUrl: organizationUrl,
    regionUrl: regionUrl,
    agencyName: agencyName,
    agencyType: agencyType,
    payrollCutoff: payrollCutoff,
    procActionDate: procActionDate,
    nameOnInvoice: nameOnInvoice,
    agencyCode: agencyCode,
    email: email,
    primaryContact: primaryContact,
    startDate: startDate,
    endDate: endDate,
    externalFacilityID: externalFacilityID,
    agencyReportID: agencyReportID,
    updated: updated,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_agency(id,url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated)
   puts "------------------UPDATING STATUS ------------------"
    puts "url is #{url}}"
   
    check = Agency.where(id: id).update(
        url: url,
    organizationUrl: organizationUrl,
    regionUrl: regionUrl,
    agencyName: agencyName,
    agencyType: agencyType,
    payrollCutoff: payrollCutoff,
    procActionDate: procActionDate,
    nameOnInvoice: nameOnInvoice,
    agencyCode: agencyCode,
    email: email,
    primaryContact: primaryContact,
    startDate: startDate,
    endDate: endDate,
    externalFacilityID: externalFacilityID,
    agencyReportID: agencyReportID,
    updated: updated,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end




########### Regions
def creating_region(url,organizationUrl,regionName,regionCode,email,primaryContact,startDate,endDate,updated)
 
  Region.create(
    
    url: url,
    organizationUrl: organizationUrl,
    regionName: regionName,
    regionCode: regionCode,
    email: email,
    primaryContact: primaryContact,
    startDate: startDate,
    endDate: endDate,
    updated: updated,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_region(id,url,organizationUrl,regionName,regionCode,email,primaryContact,startDate,endDate,updated)
   puts "------------------UPDATING STATUS ------------------"
    puts "url is #{url}}"
   
    check = Region.where(id: id).update(
        url: url,
     organizationUrl: organizationUrl,
    regionName: regionName,
    regionCode: regionCode,
    email: email,
    primaryContact: primaryContact,
    startDate: startDate,
    endDate: endDate,
    updated: updated,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end


########### Deductions
def creating_deductions(associateUrl,deduction,amount,startDate,endDate)
 
  Deduction.create(
    
    associateUrl: associateUrl,
    deduction: deduction,
    amount: amount,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_deduction(id,associateUrl,deduction,amount,startDate,endDate)
   puts "------------------UPDATING Deduction ------------------"
    puts "id is #{id}}"
   
    check = Deduction.where(id: id).update(
    associateUrl: associateUrl,
    deduction: deduction,
    amount: amount,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts "Is is updating ---------- #{check.inspect} "
    
    
  #end     
end



########### Payrates
def creating_payrates(associateUrl,payType,serviceDescription,weekdayRate,weekendRate,allowOverride,startDate)
 
  Payrate.create(
    
    associateUrl: associateUrl,
    payType: payType,
    serviceDescription: serviceDescription,
    weekdayRate: weekdayRate,
    weekendRate: weekendRate,
    allowOverride: allowOverride,
    startDate: startDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_payrates(id,associateUrl,payType,serviceDescription,weekdayRate,weekendRate,allowOverride,startDate)
   puts "------------------UPDATING Deduction ------------------"
    puts "id is #{id}}"
   
    check = Payrate.where(id: id).update(
    associateUrl: associateUrl,
    payType: payType,
    serviceDescription: serviceDescription,
    weekdayRate: weekdayRate,
    weekendRate: weekendRate,
    allowOverride: allowOverride,
    startDate: startDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### Licenses
def creating_license(associateUrl,licenseType,licenseNumber,licenseState,issueDate,licenseStatus,expirationDate)
  
  License.create(
    
    associateUrl: associateUrl,
    licenseType: licenseType,
    licenseNumber: licenseNumber,
    licenseState: licenseState,
    issueDate: issueDate,
    licenseStatus: licenseStatus,
    expirationDate: expirationDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_license(id,associateUrl,licenseType,licenseNumber,licenseState,issueDate,licenseStatus,expirationDate)
   puts "------------------UPDATING Deduction ------------------"
    puts "id is #{id}}"
   
    check = License.where(id: id).update(
     associateUrl: associateUrl,
    licenseType: licenseType,
    licenseNumber: licenseNumber,
    licenseState: licenseState,
    issueDate: issueDate,
    licenseStatus: licenseStatus,
    expirationDate: expirationDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### skills
def creating_skills(associateUrl,skills)
  Skill.create(
    
    associateUrl: associateUrl,
    skills: skills,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_skills(id,associateUrl,skills)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = Skill.where(id: id).update(
    associateUrl: associateUrl,
    skills: skills,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end


########### Compliance
def creating_compliance(associateUrl,item,complianceType,lastModifiedBy,lastModifiedByDate,result,completed,renewal,compliant,notNeeded,comment,narrative)
  Compliance.create(
    
    associateUrl: associateUrl,
    item: item,
    complianceType: complianceType,
    lastModifiedBy: lastModifiedBy,
    lastModifiedByDate: lastModifiedByDate,
    result: result,
    completed: completed,
    renewal: renewal,
    compliant: compliant,
    notNeeded: notNeeded,
    comment:  comment,
   narrative: narrative,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_compliance(id,associateUrl,item,complianceType,lastModifiedBy,lastModifiedByDate,result,completed,renewal,compliant,notNeeded,comment,narrative)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = Compliance.where(id: id).update(
     associateUrl: associateUrl,
    item: item,
    complianceType: complianceType,
    lastModifiedBy: lastModifiedBy,
    lastModifiedByDate: lastModifiedByDate,
    result: result,
    completed: completed,
    renewal: renewal,
    compliant: compliant,
    notNeeded: notNeeded,
    comment:  comment,
   narrative: narrative,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### PHYSICIAN ADDRESS
def creating_physician_address(physicianUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
  PhysicianAddress.create(
    
    physicianUrl: physicianUrl,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_physician_address(id,physicianUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = PhysicianAddress.where(id: id).update(
   physicianUrl: physicianUrl,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### physician_referral_source_contacts 
def creating_physician_referral_source_contacts(physicianUrl,firstName,middleName,lastName,phone1,phone2,information,email,startDate,updatedBy)
  PhysicianReferralSourceContacts.create(
    
    physicianUrl: physicianUrl,
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    phone1: phone1,
    phone2: phone2,
    information: information,
    email: email,
    startDate: startDate,
    updatedBy: updatedBy,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_physician_referral_source_contacts(id,physicianUrl,firstName,middleName,lastName,phone1,phone2,information,email,startDate,updatedBy)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = PhysicianReferralSourceContacts.where(id: id).update(
  physicianUrl: physicianUrl,
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    phone1: phone1,
    phone2: phone2,
    information: information,
    email: email,
    startDate: startDate,
    updatedBy: updatedBy,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end


########### physician_ancillary_phone_info 
def creating_physician_ancillary_phone_info(physicianUrl,phoneType,phone,description,updatedBy)
  PhysicianAncillaryPhoneInfo.create(
    
    physicianUrl: physicianUrl,
    phoneType: phoneType,
    phone: phone,
    description: description,
    updatedBy: updatedBy,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_physician_ancillary_phone_info(id,physicianUrl,phoneType,phone,description,updatedBy)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = PhysicianAncillaryPhoneInfo.where(id: id).update(
   physicianUrl: physicianUrl,
    phoneType: phoneType,
    phone: phone,
    description: description,
    updatedBy: updatedBy,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end




########### creating_physician_notes 
def creating_physician_notes(physicianUrl,date,noteBy,noteType,document,note,active,updatedBy)
  PhysicianNote.create(
    
    physicianUrl: physicianUrl,
    date: date,
    noteBy: noteBy,
    noteType: noteType,
    document: document,
    note: note,
    active: active,
    updatedBy: updatedBy,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_physician_notes(id,physicianUrl,date,noteBy,noteType,document,note,active,updatedBy)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = PhysicianNote.where(id: id).update(
   physicianUrl: physicianUrl,
    date: date,
    noteBy: noteBy,
    noteType: noteType,
    document: document,
    note: note,
    active: active,
    updatedBy: updatedBy,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### Physician_licenses
def creating_physician_licenses(physicianUrl,licenseNumber,state,expirationDate,verificationDate,status)
  PhysicianLicenses.create(
    
    physicianUrl: physicianUrl,
    licenseNumber: licenseNumber,
    expirationDate: expirationDate,
    state: state,
    verificationDate: verificationDate,
    status: status,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_physician_licenses(id,physicianUrl,licenseNumber,state,expirationDate,verificationDate,status)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = PhysicianLicenses.where(id: id).update(
     physicianUrl: physicianUrl,
    licenseNumber: licenseNumber,
    expirationDate: expirationDate,
    state: state,
    verificationDate: verificationDate,
    status: status,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end





########### PhysicianIdentifier
def creating_physician_identifier(physicianUrl,identifierType,identifierValue,startDate,endDate,updatedBy)
  PhysicianIdentifier.create(
    
    physicianUrl: physicianUrl,
    identifierType: identifierType,
    identifierValue: identifierValue,
    startDate: startDate,
    endDate: endDate,
    updatedBy: updatedBy,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_physician_identifier(id,physicianUrl,identifierType,identifierValue,startDate,endDate,updatedBy)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = PhysicianIdentifier.where(id: id).update(
    physicianUrl: physicianUrl,
    identifierType: identifierType,
    identifierValue: identifierValue,
    startDate: startDate,
    endDate: endDate,
    updatedBy: updatedBy,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end




########### PhysicianDocuments
def creating_physician_documents(physicianUrl,attachTo,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
  PhysicianDocuments.create(
    
    physicianUrl: physicianUrl,
    attachTo: attachTo,
    file: file,
    documentType: documentType,
    documentStatus: documentStatus,
    description: description,
    note: note,
    uploadedBy: uploadedBy,
    uploadedDate: uploadedDate,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_physician_documents(id,physicianUrl,attachTo,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = PhysicianDocuments.where(id: id).update(
     physicianUrl: physicianUrl,
    attachTo: attachTo,
    file: file,
    documentType: documentType,
    documentStatus: documentStatus,
    description: description,
    note: note,
    uploadedBy: uploadedBy,
    uploadedDate: uploadedDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### facility_ancillary_phones
def creating_facility_ancillary_phones(facilityUrl,phoneType,phone,description,updatedBy)
  FacilityAncillaryPhone.create(
    
    facilityUrl: facilityUrl,
    phoneType: phoneType,
    phone: phone,
    description: description,
    updatedBy: updatedBy,
    description: description,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_facility_ancillary_phones(id,facilityUrl,phoneType,phone,description,updatedBy)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = FacilityAncillaryPhone.where(id: id).update(
   facilityUrl: facilityUrl,
    phoneType: phoneType,
    phone: phone,
    description: description,
    updatedBy: updatedBy,
    description: description,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### facility_referral_source_contacts
def creating_facility_referral_source_contacts(facilityUrl,firstName,middleName,lastName,phone1,phone2,information,email,startDate,updatedBy)
  FacilityReferralSourceContact.create(
    
    facilityUrl: facilityUrl,
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    phone1: phone1,
    phone2: phone2,
    information: information,
    email: email,
    startDate: startDate,
    updatedBy: updatedBy,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_facility_referral_source_contacts(id,facilityUrl,firstName,middleName,lastName,phone1,phone2,information,email,startDate,updatedBy)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = FacilityReferralSourceContact.where(id: id).update(
    facilityUrl: facilityUrl,
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    phone1: phone1,
    phone2: phone2,
    information: information,
    email: email,
    startDate: startDate,
    updatedBy: updatedBy,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end





########### create_facility_address_phone_infos
 def creating_facility_address_phone_infos(facilityUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones,updatedBy)
  FacilityAddressPhoneInfo.create(
    
    facilityUrl: facilityUrl,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    updatedBy: updatedBy,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_facility_address_phone_infos(id,facilityUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones,updatedBy)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = FacilityAddressPhoneInfo.where(id: id).update(
   facilityUrl: facilityUrl,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    updatedBy: updatedBy,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### create_collector_assignments
 def creating_collector_assignments(agency,level,assignTo,payer,payerCategory,team,patientEncounter)
  CollectorAssignment.create(
    
    agency: agency,
    level: level,
    assignTo: assignTo,
    payer: payer,
    payerCategory: payerCategory,
    team: team,
    patientEncounter: patientEncounter,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_collector_assignments(id,agency,level,assignTo,payer,payerCategory,team,patientEncounter)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = CollectorAssignment.where(id: id).update(
    agency: agency,
    level: level,
    assignTo: assignTo,
    payer: payer,
    payerCategory: payerCategory,
    team: team,
    patientEncounter: patientEncounter,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end

########### create_referralData
 def creating_referralData(
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
skills,
organization_url
)
  ReferralData.create(
    uid: uid,
isCompleted: isCompleted,
status: status,
agency: agency,
 agencyType: agencyType,
referralSourceID: referralSourceID,
modeOfDelivery: modeOfDelivery,
salesRep: salesRep,
referralSourceContact: referralSourceContact,
phoneOne: phoneOne,
phoneOneType: phoneOneType,
phoneTwo: phoneTwo,
phoneTwoType: phoneTwoType,
referralEmail: referralEmail,
referralInformation: referralInformation,
payerCategory: payerCategory,
referralDate: referralDate,
referralSOC: referralSOC,
admissionSource: admissionSource,
admissionType: admissionType,
disciplines: disciplines,
primaryPhysician: primaryPhysician,
physicians: physicians,
physicianType: physicianType,
requestedSOC: requestedSOC,
physicianOrders: physicianOrders,
orderDate: orderDate,
surgicalProcedures: surgicalProcedures,
nutritionalRequirements: nutritionalRequirements,
supplyInformation: supplyInformation,
diagnosisCode: diagnosisCode,
diagnosis: diagnosis,
medications: medications,
zipCode: zipCode,
skills: skills,
organization_url: organization_url,
created_at: Time.new.strftime('%F %R'),
  )
end

def  get_update_referralData(uid, isCompleted,status,agency,
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
  
   
check = ReferralData.where(uid: uid).update(
isCompleted: isCompleted,
status: status,
agency: agency,
 agencyType: agencyType,
referralSourceID: referralSourceID,
modeOfDelivery: modeOfDelivery,
salesRep: salesRep,
referralSourceContact: referralSourceContact,
phoneOne: phoneOne,
phoneOneType: phoneOneType,
phoneTwo: phoneTwo,
phoneTwoType: phoneTwoType,
referralEmail: referralEmail,
referralInformation: referralInformation,
payerCategory: payerCategory,
referralDate: referralDate,
referralSOC: referralSOC,
admissionSource: admissionSource,
admissionType: admissionType,
disciplines: disciplines,
primaryPhysician: primaryPhysician,
physicians: physicians,
physicianType: physicianType,
requestedSOC: requestedSOC,
physicianOrders: physicianOrders,
orderDate: orderDate,
surgicalProcedures: surgicalProcedures,
nutritionalRequirements: nutritionalRequirements,
supplyInformation: supplyInformation,
diagnosisCode: diagnosisCode,
diagnosis: diagnosis,
medications: medications,
zipCode: zipCode,
skills: skills,
organization_url: organization_url,
updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end





########### create_collector_assignments
 def creating_patients(uid,patientType,status,encounterNumber,referralID,presentation,patientInformation,placeOfAdmission,
   	admissionDate,firstName,middleName,lastName,dateOfBirth,gender,race,maritalStatus,email,readmitID,facilities,organization_url,medicalRecord,socialSecurity,
    characteristics,county)

  Patient.create(
    
    uid: uid,
    patientType: patientType,
    status: status,
    encounterNumber: encounterNumber,
    referralID: referralID,
    presentation: presentation,
    patientInformation: patientInformation,
    placeOfAdmission: placeOfAdmission,
    admissionDate: admissionDate,
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    dateOfBirth: dateOfBirth,
    gender: gender,
    race: race,
    maritalStatus: maritalStatus,
    email: email,
    readmitID: readmitID,
    facilities: facilities,
    organization_url: organization_url,
    medicalRecord: medicalRecord,
    socialSecurity: socialSecurity,
    characteristics: characteristics,
    county: county,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_patient(uid,patientType,status,encounterNumber,referralID,presentation,patientInformation,placeOfAdmission,
   	admissionDate,firstName,middleName,lastName,dateOfBirth,gender,race,maritalStatus,email,readmitID,facilities,organization_url,medicalRecord,socialSecurity,
    characteristics,county)

   puts "------------------UPDATING skills ------------------"
   
   
    check = Patient.where(uid: uid).update(
     patientType: patientType,
    status: status,
    encounterNumber: encounterNumber,
    referralID: referralID,
    presentation: presentation,
    patientInformation: patientInformation,
    placeOfAdmission: placeOfAdmission,
    admissionDate: admissionDate,
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    dateOfBirth: dateOfBirth,
    gender: gender,
    race: race,
    maritalStatus: maritalStatus,
    email: email,
    readmitID: readmitID,
    facilities: facilities,
    organization_url: organization_url,
    medicalRecord: medicalRecord,
    socialSecurity: socialSecurity,
    characteristics: characteristics,
    county: county,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### FaciilityDocuments
def creating_facility_documents(facilityUrl,attachTo,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
  FacilityDocuments.create(
    
    facilityUrl: facilityUrl,
    attachTo: attachTo,
    file: file,
    documentType: documentType,
    documentStatus: documentStatus,
    description: description,
    note: note,
    uploadedBy: uploadedBy,
    uploadedDate: uploadedDate,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_facility_documents(id,facilityUrl,attachTo,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = FacilityDocuments.where(id: id).update(
     facilityUrl: facilityUrl,
    attachTo: attachTo,
    file: file,
    documentType: documentType,
    documentStatus: documentStatus,
    description: description,
    note: note,
    uploadedBy: uploadedBy,
    uploadedDate: uploadedDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### FacilityIdentifier
def creating_facility_identifier(facilityUrl,identifierType,identifierValue,startDate,endDate,updatedBy)
  FacilityIdentifier.create(
    
    facilityUrl: facilityUrl,
    identifierType: identifierType,
    identifierValue: identifierValue,
    startDate: startDate,
    endDate: endDate,
    updatedBy: updatedBy,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_facility_identifier(id,facilityUrl,identifierType,identifierValue,startDate,endDate,updatedBy)
      puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = FacilityIdentifier.where(id: id).update(
    facilityUrl: facilityUrl,
    identifierType: identifierType,
    identifierValue: identifierValue,
    startDate: startDate,
    endDate: endDate,
    updatedBy: updatedBy,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end




########### creating_physician_notes 
def creating_facility_notes(facilityUrl,date,noteBy,noteType,document,note,active,updatedBy)
  FacilityNote.create(
    
    facilityUrl: facilityUrl,
    date: date,
    noteBy: noteBy,
    noteType: noteType,
    document: document,
    note: note,
    active: active,
    updatedBy: updatedBy,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_facility_notes(id,facilityUrl,date,noteBy,noteType,document,note,active,updatedBy)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = FacilityNote.where(id: id).update(
   facilityUrl: facilityUrl,
    date: date,
    noteBy: noteBy,
    noteType: noteType,
    document: document,
    note: note,
    active: active,
    updatedBy: updatedBy,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### creating_payments 
def creating_payments(paymentSource,paymentMethod,paymentAmount,remitDate,depositDate,referenceNumber,applyPaymentsTo,
   	noteType,note,agency,paymentType,accountBalance,amountToApply,paymentBalance,appliedToRemit)
  Payment.create(
    
    paymentSource: paymentSource,
    paymentMethod: paymentMethod,
    paymentAmount: paymentAmount,
    remitDate: remitDate,
    depositDate: depositDate,
    referenceNumber: referenceNumber,
    applyPaymentsTo: applyPaymentsTo,
    noteType: noteType,
    note: note,
    agency: agency,
    paymentType: paymentType,
    accountBalance: accountBalance,
    amountToApply: amountToApply,
    paymentBalance: paymentBalance,
    appliedToRemit: appliedToRemit,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_payments(id,paymentSource,paymentMethod,paymentAmount,remitDate,depositDate,referenceNumber,applyPaymentsTo,
   	noteType,note,agency,paymentType,accountBalance,amountToApply,paymentBalance,appliedToRemit)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = Payment.where(id: id).update(
    paymentSource: paymentSource,
    paymentMethod: paymentMethod,
    paymentAmount: paymentAmount,
    remitDate: remitDate,
    depositDate: depositDate,
    referenceNumber: referenceNumber,
    applyPaymentsTo: applyPaymentsTo,
    noteType: noteType,
    note: note,
    agency: agency,
    paymentType: paymentType,
    accountBalance: accountBalance,
    amountToApply: amountToApply,
    paymentBalance: paymentBalance,
    appliedToRemit: appliedToRemit,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### creating_payments 
def creating_payer_notes(payerUrl,date,noteBy,noteType,document,note,active)
  PayerNotes.create(
    
    payerUrl: payerUrl,
    date: date,
    noteBy: noteBy,
    noteType: noteType,
    document: document,
    note: note,
    active: active,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_payerNotes(id,payerUrl,date,noteBy,noteType,document,note,active)
   puts "------------------UPDATING skills ------------------"
    puts "id is #{id}}"
   
    check = PayerNotes.where(id: id).update(
    payerUrl: payerUrl,
    date: date,
    noteBy: noteBy,
    noteType: noteType,
    document: document,
    note: note,
    active: active,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end


########### creating_patient_ancillary_phones 
def creating_patient_ancillary_phones(uid,patientID,phone,phoneType,extension,description)
  PatientAncillaryPhones.create(
    
    uid: uid,
    patientID: patientID,
    phone: phone,
    phoneType: phoneType,
    extension: extension,
    description: description,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_payerNotes(uid,patientID,phone,phoneType,extension,description)
   puts "------------------UPDATING skills ------------------"
    puts "uid is #{uid}}"
   
    check = PatientAncillaryPhones.where(uid: uid).update(
      patientID: patientID,
    phone: phone,
    phoneType: phoneType,
    extension: extension,
    description: description,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end

########### PatientAddressPhoneInfo 
def creating_patient_address_phone_info(uid,patientID,addressType,addressOne,addressTwo,city,state,zipcode,phoneType,phone)
  
  PatientAddressPhoneInfo.create(
    uid: uid,
    patientID: patientID,
    addressType: addressType,
    addressOne: addressOne,
    addressTwo: addressTwo,
    city: city,
    state: state,
    zipcode: zipcode,
    phoneType: phoneType,
    phone: phone,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_patient_address_phone_info(uid,patientID,addressType,addressOne,addressTwo,city,state,zipcode,phoneType,phone)
    
    check = PatientAddressPhoneInfo.where(uid: uid).update(
    patientID: patientID,
    addressType: addressType,
    addressOne: addressOne,
    addressTwo: addressTwo,
    city: city,
    state: state,
    zipcode: zipcode,
    phoneType: phoneType,
    phone: phone,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end


########### PatientAddressPhoneInfo 
def creating_payer_settings(payerUrl,startDate,endDate,lastBilledDay,nextBillingDay,holdBillingDate,processThroughDate,
    reportingGroup,dayOfTheMonth,overrideWeekendingDate,restrictPayer)

    PayerSettings.create(
    
    payerUrl: payerUrl,
    startDate: startDate,
    endDate: endDate,
    lastBilledDay: lastBilledDay,
    nextBillingDay: nextBillingDay,
    holdBillingDate: holdBillingDate,
    processThroughDate: processThroughDate,
    reportingGroup: reportingGroup,
    dayOfTheMonth: dayOfTheMonth,
    overrideWeekendingDate: overrideWeekendingDate,
    restrictPayer: restrictPayer,
    created_at: Time.new.strftime('%F %R'),
  )
end

def  get_update_payer_settings(id,payerUrl,startDate,endDate,lastBilledDay,nextBillingDay,holdBillingDate,processThroughDate,
    reportingGroup,dayOfTheMonth,overrideWeekendingDate,restrictPayer)
       
    check = PayerSettings.where(id: id).update(
    payerUrl: payerUrl,
    startDate: startDate,
    endDate: endDate,
    lastBilledDay: lastBilledDay,
    nextBillingDay: nextBillingDay,
    holdBillingDate: holdBillingDate,
    processThroughDate: processThroughDate,
    reportingGroup: reportingGroup,
    dayOfTheMonth: dayOfTheMonth,
    overrideWeekendingDate: overrideWeekendingDate,
    restrictPayer: restrictPayer,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end




########### ContactInfo
def creating_payer_ContactInfo(payerUrl,addressType,address1,address2,city,state,zip,
    addressPhoneInfoPhones)

    PayerContactInfo.create(
    
    payerUrl: payerUrl,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    created_at: Time.new.strftime('%F %R'),
  )
end

def  get_update_payer_ContactInfo(id,payerUrl,addressType,address1,address2,city,state,zip,
    addressPhoneInfoPhones)
       
    check = PayerContactInfo.where(id: id).update(
    payerUrl: payerUrl,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end




########### ContactInfo
def creating_payer_Contacts(payerUrl,contactName,contactEmail,department,
    addressPhoneInfoPhones)

    PayerContacts.create(
    
    payerUrl: payerUrl,
    contactName: contactName,
    contactEmail: contactEmail,
    department: department,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    created_at: Time.new.strftime('%F %R'),
  )
end

def  get_update_payer_Contacts(id,payerUrl,contactName,contactEmail,department,
    addressPhoneInfoPhones)
       
    check = PayerContacts.where(id: id).update(
   payerUrl: payerUrl,
    contactName: contactName,
    contactEmail: contactEmail,
    department: department,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end



########### Payer
def creating_payer(organizationUrl,payerName,payerCategory,oasisCategory,
    claimFilingType,invoiceType,invoiceCycle,startDate,endDate,payerEmail,applySalesTax,updated,url)

    Payer.create(
    
    organizationUrl: organizationUrl,
    payerName: payerName,
    payerCategory: payerCategory,
    oasisCategory: oasisCategory,
    claimFilingType: claimFilingType,
    invoiceType: invoiceType,
    invoiceCycle: invoiceCycle,
    startDate: startDate,
    endDate: endDate,
    payerEmail: payerEmail,
    applySalesTax: applySalesTax,
    updated: updated,
    url: url,
    created_at: Time.new.strftime('%F %R'),
  )
end

def   get_update_payer(id,organizationUrl,payerName,payerCategory,oasisCategory,
    claimFilingType,invoiceType,invoiceCycle,startDate,endDate,payerEmail,applySalesTax,updated,url)
       
    check = Payer.where(id: id).update(
   organizationUrl: organizationUrl,
    payerName: payerName,
    payerCategory: payerCategory,
    oasisCategory: oasisCategory,
    claimFilingType: claimFilingType,
    invoiceType: invoiceType,
    invoiceCycle: invoiceCycle,
    startDate: startDate,
    endDate: endDate,
    payerEmail: payerEmail,
    applySalesTax: applySalesTax,
    updated: updated,
    url: url,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end





########### creating_payer_ancillary_phone 
def creating_payer_ancillary_phone(uid,payerUrl,phoneType,phone,description)
   
  PayerAncillaryPhone.create(
    
    uid: uid,
    payerUrl: payerUrl,
    phoneType: phoneType,
    phone: phone,
    description: description,
    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_PayerAncillaryPhone(uid,payerUrl,phoneType,phone,description)
    puts "------------------UPDATING STATUS ------------------"
  
   
    check = PayerAncillaryPhone.where(uid: uid).update(
        payerUrl: payerUrl,
    phoneType: phoneType,
    phone: phone,
    description: description,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end




########### creating_patient_notes 
def creating_patient_notes(uid,note,noteType,noteBy,patientID)
   
  PatientNotes.create(
    uid: uid,
    note: note,
    noteType: noteType,
    noteBy: noteBy,
    patientID: patientID,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_patient_notes(uid,note,noteType,noteBy,patientID)
    puts "------------------UPDATING STATUS ------------------"
  
   
    check = PatientNotes.where(uid: uid).update(
    note: note,
    noteType: noteType,
    noteBy: noteBy,
    patientID: patientID,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end





########### creating_patient_contacts 
def creating_patient_contacts(uid,patientID,relationship,contactType,firstName,lastName,dateOfBirth,sequence,email,misc)
  
  PatientContacts.create(
    
    uid: uid,
    patientID: patientID,
    relationship: relationship,
    contactType: contactType,
     firstName: firstName,
      lastName: lastName,
       dateOfBirth: dateOfBirth,
        sequence: sequence,
         email: email,
         misc: misc,

    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_patient_contacts(uid,patientID,relationship,contactType,firstName,lastName,dateOfBirth,sequence,email,misc)
    puts "------------------UPDATING STATUS ------------------"
  
   
    check = PatientContacts.where(uid: uid).update(
    patientID: patientID,
    relationship: relationship,
    contactType: contactType,
     firstName: firstName,
      lastName: lastName,
       dateOfBirth: dateOfBirth,
        sequence: sequence,
         email: email,
         misc: misc,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end




########### ReferralSourceContact 
def creating_referral_source_contacts(uid,firstName,lastName,middleName,email,startDate,phoneOne,phoneTwo,phoneOneType,phoneTwoType,referralSourceID,organizationUrl,information)
  
  ReferralSourceContact.create(
    uid: uid,
    firstName: firstName,
    lastName: lastName,
    middleName: middleName,
    email: email,
      startDate: startDate,
       phoneOne: phoneOne,
        phoneTwo: phoneTwo,
         phoneOneType: phoneOneType,
         phoneTwoType: phoneTwoType,
         referralSourceID: referralSourceID,
         organizationUrl: organizationUrl,
         information: information,

    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_referral_source_contacts(uid,firstName,lastName,middleName,email,startDate,phoneOne,phoneTwo,phoneOneType,phoneTwoType,referralSourceID,organizationUrl,information)
    puts "------------------UPDATING STATUS ------------------"
  
   
    check = ReferralSourceContact.where(uid: uid).update(
     firstName: firstName,
    lastName: lastName,
    middleName: middleName,
    email: email,
      startDate: startDate,
       phoneOne: phoneOne,
        phoneTwo: phoneTwo,
         phoneOneType: phoneOneType,
         phoneTwoType: phoneTwoType,
       referralSourceID: referralSourceID,
         organizationUrl: organizationUrl,
         information: information,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end
########### ancillaryPhoneInfo FUNTIONS END


########### ReferralSource 
def creating_referral_source(uid,referralType,facilityName,facilityType,referralCompany,firstName,lastName,middleName,email,salesRep,startDate,
    endDate,physicianGroup,specialty,title,organizationUrl,status,updated)  
  ReferralSource.create(
     uid: uid,
    referralType: referralType,
    facilityName: facilityName,
    facilityType: facilityType,
    referralCompany: referralCompany,
      firstName: firstName,
       lastName: lastName,
        middleName: middleName,
         email: email,
         salesRep: salesRep,
         startDate: startDate,
         endDate: endDate,
         physicianGroup: physicianGroup,
         specialty: specialty,
         title: title,
         organizationUrl: organizationUrl,
         status: status,
         updated: updated,

    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_referral_source(uid,referralType,facilityName,facilityType,referralCompany,firstName,lastName,middleName,email,salesRep,startDate,
    endDate,physicianGroup,specialty,title,organizationUrl,status,updated)
       puts "------------------UPDATING STATUS ------------------"
  
   
    check = ReferralSource.where(uid: uid).update(
       referralType: referralType,
    facilityName: facilityName,
    facilityType: facilityType,
    referralCompany: referralCompany,
      firstName: firstName,
       lastName: lastName,
        middleName: middleName,
         email: email,
         salesRep: salesRep,
         startDate: startDate,
         endDate: endDate,
         physicianGroup: physicianGroup,
         specialty: specialty,
         title: title,
         organizationUrl: organizationUrl,
          status: status,
         updated: updated,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end



########### ReferralSourceContact 
def creating_associate_medical_compliance(associateUrl,comment,completed,complianceType,compliant,item,lastModifiedBy,lastModifiedByDate,narrative,notNeeded,renewal,result)
  
  AssociateMedicalCompliance.create(
    
    associateUrl: associateUrl,
    comment: comment,
    completed: completed,
    complianceType: complianceType,
    compliant: compliant,
    item: item,
    lastModifiedBy: lastModifiedBy,
    lastModifiedByDate: lastModifiedByDate,
    narrative: narrative,
    notNeeded: notNeeded,
    renewal: renewal,
    result: result,

    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_associate_medical_compliance(id,associateUrl,comment,completed,complianceType,compliant,item,lastModifiedBy,lastModifiedByDate,narrative,notNeeded,renewal,result)
 
   
    check = AssociateMedicalCompliance.where(id: id).update(
     associateUrl: associateUrl,
    comment: comment,
    completed: completed,
    complianceType: complianceType,
    compliant: compliant,
    item: item,
    lastModifiedBy: lastModifiedBy,
    lastModifiedByDate: lastModifiedByDate,
    narrative: narrative,
    notNeeded: notNeeded,
    renewal: renewal,
    result: result,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end



########### AssociateReport 
def creating_associate_reports(associateUrl,reportName,startDate,endDate) 
  AssociateReport.create(
    
    associateUrl: associateUrl,
    reportName: reportName,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_associate_reports(id,associateUrl,reportName,startDate,endDate) 
    check = AssociateReport.where(id: id).update(
     associateUrl: associateUrl,
    reportName: reportName,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end



########### PayerForm 
def creating_payer_form(payerUrl,automatedFormType,uploadDocumentType,orderToRecheck,startDate,endDate)

  PayerForm.create(
    
    payerUrl: payerUrl,
    automatedFormType: automatedFormType,
    uploadDocumentType: uploadDocumentType,
    orderToRecheck: orderToRecheck,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_payer_form(id,payerUrl,automatedFormType,uploadDocumentType,orderToRecheck,startDate,endDate)
 
    check = PayerForm.where(id: id).update(
    payerUrl: payerUrl,
    automatedFormType: automatedFormType,
    uploadDocumentType: uploadDocumentType,
    orderToRecheck: orderToRecheck,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end






########### PayerRule 
def creating_payer_rules(payerUrl,rule,description,groupCode,modifiedBy,modifiedDate,createdDate,startDate,endDate)

  
  PayerRule.create(
    
    payerUrl: payerUrl,
    rule: rule,
    description: description,
    groupCode: groupCode,
    modifiedBy: modifiedBy,
    modifiedDate: modifiedDate,
    createdDate: createdDate,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_payer_rules(id,payerUrl,rule,description,groupCode,modifiedBy,modifiedDate,createdDate,startDate,endDate)
 
    check = PayerRule.where(id: id).update(
    payerUrl: payerUrl,
    rule: rule,
    description: description,
    groupCode: groupCode,
    modifiedBy: modifiedBy,
    modifiedDate: modifiedDate,
    createdDate: createdDate,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





########### PayerDocuments 
def creating_payer_documents(payerUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate,attachTo)


  
  PayerDocuments.create(
    
    payerUrl: payerUrl,
    file: file,
    documentType: documentType,
    documentStatus: documentStatus,
    description: description,
    note: note,
    uploadedBy: uploadedBy,
    uploadedDate: uploadedDate,
    attachTo: attachTo,
    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_payer_documents(id,payerUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate,attachTo)
    check = PayerDocuments.where(id: id).update(
    payerUrl: payerUrl,
    file: file,
    documentType: documentType,
    documentStatus: documentStatus,
    description: description,
    note: note,
    uploadedBy: uploadedBy,
    uploadedDate: uploadedDate,
    attachTo: attachTo,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### PayerBillRates 
def creating_payer_bill_rates(payerUrl,serviceCategory,service,description,unitOfMeasure,payerRate,allowOverride,startDate,revenueCode,hcpcCode,
    agency,assessment,endDate,useAgencyChargeAmount,chargeAmount,serviceType,hcpcModifier1,hcpcModifier2,hcpcModifier3,hcpcModifier4,
    treatmentCodeNeeded,unitMultiplier,incrementalBillingCode,sendBillingDescriptionForEdit,evvProgram,evvGroupedProcedureCode,lastUpdated,modifyUser)

  
  PayerBillRates.create(
    
    payerUrl: payerUrl,
    serviceCategory: serviceCategory,
    service: service,
    description: description,
    unitOfMeasure: unitOfMeasure,
    payerRate: payerRate,
    allowOverride: allowOverride,
    startDate: startDate,
    revenueCode: revenueCode,
    hcpcCode: hcpcCode,
    agency: agency,
    assessment: assessment,
    endDate: endDate,
    useAgencyChargeAmount: useAgencyChargeAmount,
    chargeAmount: chargeAmount,
    serviceType: serviceType,
    hcpcModifier1: hcpcModifier1,
    hcpcModifier2: hcpcModifier2,
    hcpcModifier3: hcpcModifier3,
    hcpcModifier4: hcpcModifier4,
    treatmentCodeNeeded: treatmentCodeNeeded,
    unitMultiplier: unitMultiplier,
    incrementalBillingCode: incrementalBillingCode,
    sendBillingDescriptionForEdit: sendBillingDescriptionForEdit,
    evvProgram: evvProgram,
    evvGroupedProcedureCode: evvGroupedProcedureCode,
    lastUpdated: lastUpdated,
    modifyUser: modifyUser,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_payer_bill_rates(id,payerUrl,serviceCategory,service,description,unitOfMeasure,payerRate,allowOverride,startDate,revenueCode,hcpcCode,
    agency,assessment,endDate,useAgencyChargeAmount,chargeAmount,serviceType,hcpcModifier1,hcpcModifier2,hcpcModifier3,hcpcModifier4,
    treatmentCodeNeeded,unitMultiplier,incrementalBillingCode,sendBillingDescriptionForEdit,evvProgram,evvGroupedProcedureCode,lastUpdated,modifyUser)
   
    check = PayerBillRates.where(id: id).update(
     payerUrl: payerUrl,
    serviceCategory: serviceCategory,
    service: service,
    description: description,
    unitOfMeasure: unitOfMeasure,
    payerRate: payerRate,
    allowOverride: allowOverride,
    startDate: startDate,
    revenueCode: revenueCode,
    hcpcCode: hcpcCode,
    agency: agency,
    assessment: assessment,
    endDate: endDate,
    useAgencyChargeAmount: useAgencyChargeAmount,
    chargeAmount: chargeAmount,
    serviceType: serviceType,
    hcpcModifier1: hcpcModifier1,
    hcpcModifier2: hcpcModifier2,
    hcpcModifier3: hcpcModifier3,
    hcpcModifier4: hcpcModifier4,
    treatmentCodeNeeded: treatmentCodeNeeded,
    unitMultiplier: unitMultiplier,
    incrementalBillingCode: incrementalBillingCode,
    sendBillingDescriptionForEdit: sendBillingDescriptionForEdit,
    evvProgram: evvProgram,
    evvGroupedProcedureCode: evvGroupedProcedureCode,
    lastUpdated: lastUpdated,
    modifyUser: modifyUser,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





########### PayerBillRates 
def creating_payer_requirements(payerUrl,generalReq_patientLevelOverride,authorizationHash,byDiscipline,
    byServiceCode,byVisits,byHours,byAmount,clinicalReq_patientLevelOverride,oasis,certificationPeriodDays,
   noticeOfElection,noticeOfAdmission, assessmentVisits,physiciansOrders,clinicalNotes,copayRep_patientLevelOverride,
   copayType,copaySplit,billOvertime,miscBilling,eligibleRequirement,insuredInformation,invoiceTypeOverride,invoiceFrequencyOverride,patientLevelOverride,serviceDescription)
  
  PayerRequirements.create(
    
    payerUrl: payerUrl,
    generalReq_patientLevelOverride: generalReq_patientLevelOverride,
    authorizationHash: authorizationHash,
    byDiscipline: byDiscipline,
    byServiceCode: byServiceCode,
    byVisits: byVisits,
    byHours: byHours,
    byAmount: byAmount,
    clinicalReq_patientLevelOverride: clinicalReq_patientLevelOverride,
    oasis: oasis,
    certificationPeriodDays: certificationPeriodDays,
    noticeOfElection: noticeOfElection,
    noticeOfAdmission: noticeOfAdmission,
    assessmentVisits: assessmentVisits,
    physiciansOrders: physiciansOrders,
    clinicalNotes: clinicalNotes,
    copayRep_patientLevelOverride: copayRep_patientLevelOverride,
    copayType: copayType,
    copaySplit: copaySplit,
    billOvertime: billOvertime,
    miscBilling: miscBilling,
    eligibleRequirement: eligibleRequirement,
    insuredInformation: insuredInformation,
    invoiceTypeOverride: invoiceTypeOverride,
    invoiceFrequencyOverride: invoiceFrequencyOverride,
    patientLevelOverride: patientLevelOverride,
    serviceDescription: serviceDescription,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_payer_requirements(id,payerUrl,generalReq_patientLevelOverride,authorizationHash,byDiscipline,
    byServiceCode,byVisits,byHours,byAmount,clinicalReq_patientLevelOverride,oasis,certificationPeriodDays,
   noticeOfElection,noticeOfAdmission, assessmentVisits,physiciansOrders,clinicalNotes,copayRep_patientLevelOverride,
   copayType,copaySplit,billOvertime,miscBilling,eligibleRequirement,insuredInformation,invoiceTypeOverride,invoiceFrequencyOverride,patientLevelOverride,serviceDescription)
  
    check = PayerRequirements.where(id: id).update(
    payerUrl: payerUrl,
    generalReq_patientLevelOverride: generalReq_patientLevelOverride,
    authorizationHash: authorizationHash,
    byDiscipline: byDiscipline,
    byServiceCode: byServiceCode,
    byVisits: byVisits,
    byHours: byHours,
    byAmount: byAmount,
    clinicalReq_patientLevelOverride: clinicalReq_patientLevelOverride,
    oasis: oasis,
    certificationPeriodDays: certificationPeriodDays,
    noticeOfElection: noticeOfElection,
    noticeOfAdmission: noticeOfAdmission,
    assessmentVisits: assessmentVisits,
    physiciansOrders: physiciansOrders,
    clinicalNotes: clinicalNotes,
    copayRep_patientLevelOverride: copayRep_patientLevelOverride,
    copayType: copayType,
    copaySplit: copaySplit,
    billOvertime: billOvertime,
    miscBilling: miscBilling,
    eligibleRequirement: eligibleRequirement,
    insuredInformation: insuredInformation,
    invoiceTypeOverride: invoiceTypeOverride,
    invoiceFrequencyOverride: invoiceFrequencyOverride,
    patientLevelOverride: patientLevelOverride,
    serviceDescription: serviceDescription,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### PatientVendors 
def creating_patient_vendors(uid,startDate,endDate,sequence,prefered,patientID)
  
  PatientVendors.create(
    
    uid: uid,
    startDate: startDate,
    endDate: endDate,
    sequence: sequence,
    prefered: prefered,
    patientID: patientID,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_patient_vendors(uid,startDate,endDate,sequence,prefered,patientID)  
    check = PatientVendors.where(uid: uid).update(
      startDate: startDate,
    endDate: endDate,
    sequence: sequence,
    prefered: prefered,
    patientID: patientID,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end


########### PatientVaccine 
def creating_patient_vaccine(description,datePerformed,patientID)
  
  PatientVaccine.create(
    
    description: description,
    datePerformed: datePerformed,
    patientID: patientID,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_patient_vaccine(id,description,datePerformed,patientID)  
    check = PatientVaccine.where(id: id).update(
     description: description,
    datePerformed: datePerformed,
    patientID: patientID,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### PatientVitalSigns 
def creating_patient_vital_signs(uid,description,high,low,patientID)
  
  PatientVitalSigns.create(
    
    uid: uid,
    description: description,
    high: high,
    low: low,
    patientID: patientID,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_patient_vital_signs(uid,description,high,low,patientID) 
    check = PatientVitalSigns.where(uid: uid).update(
      description: description,
    high: high,
    low: low,
    patientID: patientID,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### PatientAllergies 
def creating_patient_allergies(uid,description,status,startDate,endDate,createdBy,modifiedBy,patientID)


  
  PatientAllergies.create(
        uid: uid,
    description: description,
    status: status,
    startDate: startDate,
    endDate: endDate,
    createdBy: createdBy,
    modifiedBy: modifiedBy,
    patientID: patientID,
    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_patient_allergies(uid,description,status,startDate,endDate,createdBy,modifiedBy,patientID)

    check = PatientAllergies.where(uid: uid).update(
    description: description,
    status: status,
    startDate: startDate,
    endDate: endDate,
    createdBy: createdBy,
    modifiedBy: modifiedBy,
    patientID: patientID,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end






########### PatientAdvanceDirectives 
def creating_patient_advance_directives(uid,file,attachTo,documentType,documentStatus,note,description,patientID)


  
  PatientAdvanceDirectives.create(
    uid: uid,
    file: file,
    attachTo: attachTo,
    documentType: documentType,
    documentStatus: documentStatus,
    note: note,
    description: description,
    patientID: patientID,
    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_patient_advance_directives(uid,file,attachTo,documentType,documentStatus,note,description,patientID)
   check = PatientAdvanceDirectives.where(uid: uid).update(
    file: file,
    attachTo: attachTo,
    documentType: documentType,
    documentStatus: documentStatus,
    note: note,
    description: description,
    patientID: patientID,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





########### PatientConsent 
def creating_patient_consent(uid,file,attachTo,documentType,documentStatus,note,description,patientID,uploadedBy)


  
  PatientConsent.create(
    uid: uid,
    file: file,
    attachTo: attachTo,
    documentType: documentType,
    documentStatus: documentStatus,
    note: note,
    description: description,
    patientID: patientID,
    uploadedBy: uploadedBy,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_patient_consent(uid,file,attachTo,documentType,documentStatus,note,description,patientID,uploadedBy)

   check = PatientConsent.where(uid: uid).update(
    file: file,
    attachTo: attachTo,
    documentType: documentType,
    documentStatus: documentStatus,
    note: note,
    description: description,
    patientID: patientID,
    uploadedBy: uploadedBy,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### PatientDme 
def creating_patient_dme(uid,vendor,deliveryDate,returnDate,comment,patientID,description)

  
  PatientDme.create(
    
    uid: uid,
    vendor: vendor,
    deliveryDate: deliveryDate,
    returnDate: returnDate,
    comment: comment,
    patientID: patientID,
    description: description,
   
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_patient_dme(uid,vendor,deliveryDate,returnDate,comment,patientID,description)
   check = PatientDme.where(uid: uid).update(
    vendor: vendor,
    deliveryDate: deliveryDate,
    returnDate: returnDate,
    comment: comment,
    patientID: patientID,
    description: description,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### PayerIdentifiers 
def creating_payer_identifiers(payerUrl,agencyUrl,identifierType,identifierValue,startDate,endDate)


  
  PayerIdentifiers.create(
    
    payerUrl: payerUrl,
    agencyUrl: agencyUrl,
    identifierType: identifierType,
    identifierValue: identifierValue,
    startDate: startDate,
    endDate: endDate,
   
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_payer_identifiers(id,payerUrl,agencyUrl,identifierType,identifierValue,startDate,endDate)

   check = PayerIdentifiers.where(id: id).update(
     payerUrl: payerUrl,
    agencyUrl: agencyUrl,
    identifierType: identifierType,
    identifierValue: identifierValue,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### PayerInvoiceReviews 
def creating_payer_invoice_reviews(payerUrl,title,startDate,endDate)

  
  PayerInvoiceReviews.create(
    
    payerUrl: payerUrl,
    title: title,
    startDate: startDate,
    endDate: endDate,
   
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_payer_invoice_reviews(id,payerUrl,title,startDate,endDate)

   check = PayerInvoiceReviews.where(id: id).update(
      payerUrl: payerUrl,
    title: title,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end






########### PayerHcpc 
def creating_payer_hcpc(payerUrl,placeOfService,serviceCode,hcpcCode,hcpcModifier1,hcpcModifier2,hcpcModifier3,hcpcModifier4,startDate,endDate)
 
  PayerHcpc.create(
    
    payerUrl: payerUrl,
    placeOfService: placeOfService,
    serviceCode: serviceCode,
    hcpcCode: hcpcCode,
    hcpcModifier1: hcpcModifier1,
    hcpcModifier2: hcpcModifier2,
    hcpcModifier3: hcpcModifier3,
    hcpcModifier4: hcpcModifier4,
    startDate: startDate,
    endDate: endDate,
   
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_payer_hcpc(id,payerUrl,placeOfService,serviceCode,hcpcCode,hcpcModifier1,hcpcModifier2,hcpcModifier3,hcpcModifier4,startDate,endDate)

   check = PayerHcpc.where(id: id).update(
     payerUrl: payerUrl,
    placeOfService: placeOfService,
    serviceCode: serviceCode,
    hcpcCode: hcpcCode,
    hcpcModifier1: hcpcModifier1,
    hcpcModifier2: hcpcModifier2,
    hcpcModifier3: hcpcModifier3,
    hcpcModifier4: hcpcModifier4,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### PayerCarrierCode 
def creating_payer_carrier_code(payerUrl,relationalPayer,carrierCode,startDate,endDate)
  PayerCarrierCode.create(
    
    payerUrl: payerUrl,
    relationalPayer: relationalPayer,
    carrierCode: carrierCode,
    startDate: startDate,
    endDate: endDate,
   
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_payer_carrier_code(id,payerUrl,relationalPayer,carrierCode,startDate,endDate)
   check = PayerCarrierCode.where(id: id).update(
   payerUrl: payerUrl,
    relationalPayer: relationalPayer,
    carrierCode: carrierCode,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





########### creating_inactive_reason_types 
def creating_inactive_reason_types(organizationUrl,code,description,groupCode,sortOrder,startDate,endDate)

 
  AssLookupInactiveReasonTypes.create(
    
    organizationUrl: organizationUrl,
    code: code,
    description: description,
    groupCode: groupCode,
    sortOrder: sortOrder,
    endDate: endDate,
    startDate: startDate,  
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_inactive_reason_types(id,organizationUrl,code,description,groupCode,sortOrder,startDate,endDate)
   check = AssLookupInactiveReasonTypes.where(id: id).update(
 organizationUrl: organizationUrl,
    code: code,
    description: description,
    groupCode: groupCode,
    sortOrder: sortOrder,
    endDate: endDate,
    startDate: startDate, 
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### creating_inactive_reason_types 
def creating_discipline_types(organizationUrl,disciplineCode,description,serviceCategoryCode,orderDisciplineCode,sortOrder,startDate,endDate,
    allowConnectionToPhysician,assessmentGroup,payCode)
 
  AssLookupDisciplineTypes.create(
    
    organizationUrl: organizationUrl,
    disciplineCode: disciplineCode,
    description: description,
    serviceCategoryCode: serviceCategoryCode,
    orderDisciplineCode: orderDisciplineCode,
    sortOrder: sortOrder,
    endDate: endDate,
    startDate: startDate, 
    allowConnectionToPhysician: allowConnectionToPhysician,
    assessmentGroup: assessmentGroup, 
    payCode: payCode,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_discipline_types(id,organizationUrl,disciplineCode,description,serviceCategoryCode,orderDisciplineCode,sortOrder,startDate,endDate,
    allowConnectionToPhysician,assessmentGroup,payCode)
  
   check = AssLookupDisciplineTypes.where(id: id).update(
 organizationUrl: organizationUrl,
    disciplineCode: disciplineCode,
    description: description,
    serviceCategoryCode: serviceCategoryCode,
    orderDisciplineCode: orderDisciplineCode,
    sortOrder: sortOrder,
    endDate: endDate,
    startDate: startDate, 
    allowConnectionToPhysician: allowConnectionToPhysician,
    assessmentGroup: assessmentGroup, 
    payCode: payCode,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### creating_inactive_reason_types 
def creating_notes(noteType,payer,followUpDate,note)
 
  Notes.create(
    
    noteType: noteType,
    payer: payer,
    followUpDate: followUpDate,
    note: note,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_notes(id,noteType,payer,followUpDate,note)
  
   check = Notes.where(id: id).update(
  noteType: noteType,
    payer: payer,
    followUpDate: followUpDate,
    note: note,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end







########### creating_lookup_deductions 
def creating_lookup_deductions(organizationUrl,isRecurring,description,isPretax,calculation,coverage,groupCode,sortOrder,
    startDate,endDate)
 
  AssLookupDeductions.create(
    
    organizationUrl: organizationUrl,
    isRecurring: isRecurring,
    description: description,
    isPretax: isPretax,
    calculation: calculation,
    coverage: coverage,
    groupCode: groupCode,
    sortOrder: sortOrder, 
    endDate: endDate,
    startDate: startDate, 
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_lookup_deductions(id,organizationUrl,isRecurring,description,isPretax,calculation,coverage,groupCode,sortOrder,
    startDate,endDate)
  
   check = AssLookupDeductions.where(id: id).update(
    organizationUrl: organizationUrl,
    isRecurring: isRecurring,
    description: description,
    isPretax: isPretax,
    calculation: calculation,
    coverage: coverage,
    groupCode: groupCode,
    sortOrder: sortOrder, 
    endDate: endDate,
    startDate: startDate, 
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### creating_lookup_deductions 
def creating_lookup_noteType(organizationUrl,code,description,doNotGenerateWbTask,groupCode,sortOrder,
    startDate,endDate)
 
  AssLookupNoteType.create(
    
    organizationUrl: organizationUrl,
    code: code,
    description: description,
    doNotGenerateWbTask: doNotGenerateWbTask,
    groupCode: groupCode,
    sortOrder: sortOrder, 
    endDate: endDate,
    startDate: startDate, 
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_lookup_noteType(id,organizationUrl,code,description,doNotGenerateWbTask,groupCode,sortOrder,
    startDate,endDate)
  
   check = AssLookupNoteType.where(id: id).update(
    organizationUrl: organizationUrl,
    code: code,
    description: description,
    doNotGenerateWbTask: doNotGenerateWbTask,
    groupCode: groupCode,
    sortOrder: sortOrder, 
    endDate: endDate,
    startDate: startDate,  
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### creating_lookup_deductions 
def creating_lookup_contractorCompanies(organizationUrl,name,phone)
 
  AssLookupcontractorCompanies.create(
    
    organizationUrl: organizationUrl,
    name: name,
    phone: phone,
    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_lookup_contractorCompanies(id,organizationUrl,name,phone)
  
   check = AssLookupcontractorCompanies.where(id: id).update(
     organizationUrl: organizationUrl,
    name: name,
    phone: phone, 
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### creating_lookup_deductions 
def creating_lookup_compliance(organizationUrl,name,description,category,appliesTo,requiredForScheduling,dateType,
    startDate,endDate,complianceDisciplines)
 
  AssLookupCompliance.create(
    
    organizationUrl: organizationUrl,
    name: name,
    description: description,
    category: category,
    appliesTo: appliesTo,
    requiredForScheduling: requiredForScheduling,
    dateType: dateType,
    startDate: startDate,
    endDate: endDate,
    complianceDisciplines: complianceDisciplines,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_lookup_compliance(id,organizationUrl,name,description,category,appliesTo,requiredForScheduling,dateType,
    startDate,endDate,complianceDisciplines)
  
   check = AssLookupCompliance.where(id: id).update(
      organizationUrl: organizationUrl,
      name: name,
    description: description,
    category: category,
    appliesTo: appliesTo,
    requiredForScheduling: requiredForScheduling,
    dateType: dateType,
    startDate: startDate,
    endDate: endDate,
    complianceDisciplines: complianceDisciplines,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





########### creating_lookup_licenseType 
def creating_lookup_licenseType(organizationUrl,description,code,groupCode,requiredForScheduling,sortOrder,
    startDate,endDate)
 
  AssLookupLicenseType.create(
    
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    requiredForScheduling: requiredForScheduling,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_lookup_licenseType(id,organizationUrl,description,code,groupCode,requiredForScheduling,sortOrder,
    startDate,endDate)
  
   check = AssLookupLicenseType.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    requiredForScheduling: requiredForScheduling,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### creating_lookup_schedulingRankType 
def creating_lookup_schedulingRankType(organizationUrl,description,
    startDate,endDate)
 
  AssLookupSchedulingRankType.create(
    
    organizationUrl: organizationUrl,
    description: description,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def    get_update_lookup_schedulingRankType(id,organizationUrl,description,
    startDate,endDate)
  
   check = AssLookupSchedulingRankType.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### creating_arlookup_hcpcModifierTypes 
def creating_arlookup_hcpcModifierTypes(organizationUrl,description,hcpcModifierCodes,groupCode,sortOrder,
    startDate,endDate)
 
  ArLookupHcpcModifierType.create(
    
    organizationUrl: organizationUrl,
    description: description,
    hcpcModifierCodes: hcpcModifierCodes,
    startDate: startDate,
    groupCode: groupCode,
    sortOrder: sortOrder,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_arlookup_hcpcModifierTypes(id,organizationUrl,description,hcpcModifierCodes,groupCode,sortOrder,
    startDate,endDate)
  
   check = ArLookupHcpcModifierType.where(id: id).update(
     organizationUrl: organizationUrl,
    description: description,
    hcpcModifierCodes: hcpcModifierCodes,
    startDate: startDate,
    groupCode: groupCode,
    sortOrder: sortOrder,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### creating_arlookup_paymentSources 
def creating_arlookup_paymentSources(organizationUrl,paymentSource,paymentMethod)
 
  ArLookupPaymentSources.create(
    
    organizationUrl: organizationUrl,
    paymentSource: paymentSource,
    paymentMethod: paymentMethod,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_arlookup_hcpcModifierTypes(id,organizationUrl,paymentSource,paymentMethod)
  
   check = ArLookupPaymentSources.where(id: id).update(
      organizationUrl: organizationUrl,
    paymentSource: paymentSource,
    paymentMethod: paymentMethod,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end


########### creating_arlookup_eraReasonType 
def creating_arlookup_eraReasonType(organizationUrl,eraReasonCode,arAdjustmentReason,adjustmentLevel,
    startDate,endDate)
 
  ArLookupEraReasonType.create(
    
    organizationUrl: organizationUrl,
    eraReasonCode: eraReasonCode,
    arAdjustmentReason: arAdjustmentReason,
    adjustmentLevel: adjustmentLevel,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_arlookup_eraReasonType(id,organizationUrl,eraReasonCode,arAdjustmentReason,adjustmentLevel,
    startDate,endDate)
  
   check = ArLookupEraReasonType.where(id: id).update(
     eraReasonCode: eraReasonCode,
    arAdjustmentReason: arAdjustmentReason,
    adjustmentLevel: adjustmentLevel,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




####Service Facility

def creating_patient_service_facilities(uid,patientID,facilityName,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,startDate,endDate,phoneType,phone,organizationUrl)
  PatientServiceFacility.create(
    uid: uid,
    patientID: patientID,
    facilityName: facilityName,
    addressType: addressType,
    addressOne: addressOne,
    addressTwo: addressTwo,
    city: city,
    state: state,
    zipcode: zipcode,
    placeOfService: placeOfService,
    startDate: startDate,
    endDate: endDate,
    phoneType: phoneType,
    phone: phone,
    organizationUrl: organizationUrl,
    created_at: Time.new.strftime('%F %R'),
  )
end

def get_update_patient_service_facilities(uid,patientID,facilityName,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,startDate,endDate,phoneType,phone,organizationUrl)
   check = PatientServiceFacility.where(uid: uid).update(
    patientID: patientID,
    facilityName: facilityName,
    addressType: addressType,
    addressOne: addressOne,
    addressTwo: addressTwo,
    city: city,
    state: state,
    zipcode: zipcode,
    placeOfService: placeOfService,
    startDate: startDate,
    endDate: endDate,
    phoneType: phoneType,
    phone: phone,
    organizationUrl: organizationUrl,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
      
end








########### creating_lookup_licenseType 
def creating_lookup_invoice_note_type(organizationUrl,description,code,groupCode,generateWorkflow,followupDays,sortOrder,
    startDate,endDate)
 
  ArLookupInvoiceNoteType.create(
    
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    generateWorkflow: generateWorkflow,
    followupDays: followupDays,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_lookup_invoice_note_type(id,organizationUrl,description,code,groupCode,generateWorkflow,followupDays,sortOrder,
    startDate,endDate)
  
   check = ArLookupInvoiceNoteType.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    generateWorkflow: generateWorkflow,
    followupDays: followupDays,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





########### creating_physician_orders_suggested_text 
def creating_physician_orders_suggested_text(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
 
  PhysicianOrdersSuggestedText.create(
    
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_physician_orders_suggested_text(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
  
   check = PhysicianOrdersSuggestedText.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### PhysicianOrdersQuickPickTypes 
def creating_physician_orders_quick_pick_types(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
 
  PhysicianOrdersQuickPickTypes.create(
    
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_physician_orders_quick_pick_types(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
  
   check = PhysicianOrdersQuickPickTypes.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### PhysicianOrdersQuickPickTypes 
def creating_oasis_void_reason_type(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
 
  OasisVoidReasonType.create(
    
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_oasis_void_reason_type(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
  
   check = OasisVoidReasonType.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





########### CareNeedTaskActionResponse 
def creating_care_need_task_action_response(organizationUrl,description,groupCode,sortOrder,
    startDate,endDate)
 
  CareNeedTaskActionResponse.create(
    
    organizationUrl: organizationUrl,
    description: description,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_care_need_task_action_response(id,organizationUrl,description,groupCode,sortOrder,
    startDate,endDate)
  
   check = CareNeedTaskActionResponse.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





########### Vaccines 
def creating_vaccines(organizationUrl,description,groupCode,sortOrder,
    startDate,endDate)
 
  Vaccines.create(
    
    organizationUrl: organizationUrl,
    description: description,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_vaccines(id,organizationUrl,description,groupCode,sortOrder,
    startDate,endDate)
  
   check = Vaccines.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### GoalStatusTypes 
def creating_goal_status_types(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
 
  GoalStatusTypes.create(
    
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_goal_status_types(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
  
   check = GoalStatusTypes.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end






########### CareNeedLevels 
def creating_care_need_levels(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
 
  CareNeedLevels.create(
    
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_care_need_levels(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
  
   check = CareNeedLevels.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### CareNeedLevels 
def creating_medication_administered_by_type(organizationUrl,description,code,
    startDate,endDate)
 
  MedicationAdministeredByType.create(
    
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_medication_administered_by_type(id,organizationUrl,description,code,
    startDate,endDate)
  
   check = MedicationAdministeredByType.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### creating_vital_type 
def creating_vital_type(organizationUrl,vitalDescription,lowValue,highValue,matchingCode,
    startDate,endDate)
 
  VitalType.create(
    
    organizationUrl: organizationUrl,
    vitalDescription: vitalDescription,
    lowValue: lowValue,
    highValue: highValue,
    matchingCode: matchingCode,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_vital_type(id,organizationUrl,vitalDescription,lowValue,highValue,matchingCode,
    startDate,endDate)
  
   check = VitalType.where(id: id).update(
    organizationUrl: organizationUrl,
    vitalDescription: vitalDescription,
    lowValue: lowValue,
    highValue: highValue,
    matchingCode: matchingCode,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### creating_wound_area 
def creating_wound_area(organizationUrl,woundAreaCode,woundAreaName,groupCode,sortOrder,
    startDate,endDate)
 
  WoundArea.create(
    
    organizationUrl: organizationUrl,
    woundAreaCode: woundAreaCode,
    woundAreaName: woundAreaName,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_wound_area(id,organizationUrl,woundAreaCode,woundAreaName,groupCode,sortOrder,
    startDate,endDate)
  
   check = WoundArea.where(id: id).update(
   organizationUrl: organizationUrl,
    woundAreaCode: woundAreaCode,
    woundAreaName: woundAreaName,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### creating_wound_area 
def creating_wound_area(organizationUrl,woundAreaCode,woundAreaName,groupCode,sortOrder,
    startDate,endDate)
 
  WoundArea.create(
    
    organizationUrl: organizationUrl,
    woundAreaCode: woundAreaCode,
    woundAreaName: woundAreaName,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_wound_area(id,organizationUrl,woundAreaCode,woundAreaName,groupCode,sortOrder,
    startDate,endDate)
  
   check = WoundArea.where(id: id).update(
   organizationUrl: organizationUrl,
    woundAreaCode: woundAreaCode,
    woundAreaName: woundAreaName,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end



########### ReferralSourceNotes 
def creating_referral_source_notes(referralSourceUid,date,noteBy,noteType,document,note,active,updatedBy)
 
  ReferralSourceNotes.create(   
    referralSourceUid: referralSourceUid,
    date: date,
    noteBy: noteBy,
    noteType: noteType,
    document: document,
    note: note,
    active: active,
    updatedBy: updatedBy,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_referral_source_notes(id,referralSourceUid,date,noteBy,noteType,document,note,active,updatedBy)

  
   check = ReferralSourceNotes.where(id: id).update(
    date: date,
    noteBy: noteBy,
    noteType: noteType,
    document: document,
    note: note,
    active: active,
    updatedBy: updatedBy,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




########### ReferralSourceAncillaryPhone 
def creating_referral_source_ancillary_phone(referralSourceUid,phoneType,phone,description)
  ReferralSourceAncillaryPhone.create(   
    referralSourceUid: referralSourceUid,
    phoneType: phoneType,
    phone: phone,
    description: description,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_referral_source_ancillary_phone(id,referralSourceUid,phoneType,phone,description)
  
   check = ReferralSourceAncillaryPhone.where(id: id).update(
    phoneType: phoneType,
    phone: phone,
    description: description,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





########### creating_ar_lookup_agency_payment_types 
def creating_ar_lookup_agency_payment_types(organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
 
  ArLookupAgencyPaymentTypes.create(
    
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_arlookup_agency_payment_type(id,organizationUrl,description,code,groupCode,sortOrder,
    startDate,endDate)
  
   check = ArLookupAgencyPaymentTypes.where(id: id).update(
    organizationUrl: organizationUrl,
    description: description,
    code: code,
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate,
    endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





def creating_ar_adjustment_reason_type(organizationUrl,code,description,arSubcategory,allowForGross,groupCode,sortOrder,
    startDate,endDate)
 
  ArAdjustmentReasonType.create(
    
    organizationUrl: organizationUrl,
    code: code,
    description: description,
    arSubcategory: arSubcategory,
    allowForGross: allowForGross,
    groupCode: groupCode,
    sortOrder: sortOrder, 
    endDate: endDate,
    startDate: startDate, 
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_ar_adjustment_reason_type(id,organizationUrl,code,description,arSubcategory,allowForGross,groupCode,sortOrder,
    startDate,endDate)
  
   check = ArAdjustmentReasonType.where(id: id).update(
    organizationUrl: organizationUrl,
    code: code,
    description: description,
    arSubcategory: arSubcategory,
    allowForGross: allowForGross,
    groupCode: groupCode,
    sortOrder: sortOrder, 
    endDate: endDate,
    startDate: startDate, 
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end






def creating_assessment_void_reason_type(organizationUrl,code,description,followupDays,generateWorkflow,groupCode,sortOrder,
    startDate,endDate) 
 
  AssessmentVoidReasonType.create(
    
    organizationUrl: organizationUrl,
    code: code,
    description: description,
    followupDays: followupDays,
    generateWorkflow: generateWorkflow,
    groupCode: groupCode, 
    sortOrder: sortOrder, 
    endDate: endDate,
    startDate: startDate, 
    created_at: Time.new.strftime('%F %R'),
  )
end


def   get_update_assessment_void_reason_type(id,organizationUrl,code,description,followupDays,generateWorkflow,groupCode,sortOrder,
    startDate,endDate)
  
   check = AssessmentVoidReasonType.where(id: id).update(
     organizationUrl: organizationUrl,
    code: code,
    description: description,
    followupDays: followupDays,
    generateWorkflow: generateWorkflow,
    groupCode: groupCode,
    sortOrder: sortOrder, 
    endDate: endDate,
    startDate: startDate, 
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





def creating_care_needs(organizationUrl,restrictToAgencyType,description,groupCode,sortOrder,
    startDate,endDate)
 
  CareNeeds.create(
    
    organizationUrl: organizationUrl,
    restrictToAgencyType: restrictToAgencyType,
    description: description,
    groupCode: groupCode, 
    sortOrder: sortOrder, 
    endDate: endDate,
    startDate: startDate, 
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_care_needs(id,organizationUrl,restrictToAgencyType,description,groupCode,sortOrder,
    startDate,endDate)
  
   check = CareNeeds.where(id: id).update(
    organizationUrl: organizationUrl,
    restrictToAgencyType: restrictToAgencyType,
    description: description,
    groupCode: groupCode, 
    sortOrder: sortOrder, 
    endDate: endDate,
    startDate: startDate, 
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





def creating_care_plan_prognosis(organizationUrl,code,description,useOnCarePlan,sortOrder)
 
  CarePlanPrognosis.create(
    
    organizationUrl: organizationUrl,
    code: code,
    description: description,
    useOnCarePlan: useOnCarePlan, 
    sortOrder: sortOrder,  
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_care_plan_prognosis(id,organizationUrl,code,description,useOnCarePlan,sortOrder)
  
   check = CarePlanPrognosis.where(id: id).update(
     organizationUrl: organizationUrl,
    code: code,
    description: description,
    useOnCarePlan: useOnCarePlan, 
    sortOrder: sortOrder, 
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





def creating_case_communication_descriptions(organizationUrl,prefix,description,suffix,startDate,endDate)

  CaseCommunicationDescriptions.create(
    
    organizationUrl: organizationUrl,
    prefix: prefix,
    description: description,
    suffix: suffix, 
    startDate: startDate, 
     endDate: endDate,  
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_case_communication_descriptions(id,organizationUrl,prefix,description,suffix,startDate,endDate)
  
   check = CaseCommunicationDescriptions.where(id: id).update(
      organizationUrl: organizationUrl,
    prefix: prefix,
    description: description,
    suffix: suffix, 
    startDate: startDate, 
     endDate: endDate,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




def creating_goals(organizationUrl,relatedToCn,description,disciplineCode,groupCode,sortOrder,startDate,endDate,responseRequired,restrictToAgencyType)

 
  Goals.create(
    
    organizationUrl: organizationUrl,
    relatedToCn: relatedToCn,
    description: description,
    disciplineCode: disciplineCode, 
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate, 
     endDate: endDate,  
     responseRequired: responseRequired,
     restrictToAgencyType: restrictToAgencyType,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_goals(id,organizationUrl,relatedToCn,description,disciplineCode,groupCode,sortOrder,startDate,endDate,responseRequired,restrictToAgencyType)
   check = Goals.where(id: id).update(

      organizationUrl: organizationUrl,
    relatedToCn: relatedToCn,
    description: description,
    disciplineCode: disciplineCode, 
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate, 
     endDate: endDate,  
     responseRequired: responseRequired,
     restrictToAgencyType: restrictToAgencyType,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




def creating_interventions(organizationUrl,relatedToCn,description,disciplineCode,groupCode,sortOrder,startDate,endDate,responseRequired,restrictToAgencyType)

 
  Interventions.create(
    
    organizationUrl: organizationUrl,
    relatedToCn: relatedToCn,
    description: description,
    disciplineCode: disciplineCode, 
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate, 
     endDate: endDate,  
     responseRequired: responseRequired,
     restrictToAgencyType: restrictToAgencyType,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_interventions(id,organizationUrl,relatedToCn,description,disciplineCode,groupCode,sortOrder,startDate,endDate,responseRequired,restrictToAgencyType)
  

   check = Interventions.where(id: id).update(
    
      organizationUrl: organizationUrl,
    relatedToCn: relatedToCn,
    description: description,
    disciplineCode: disciplineCode, 
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate, 
     endDate: endDate,  
     responseRequired: responseRequired,
     restrictToAgencyType: restrictToAgencyType,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end





def creating_quick_pick_medications(organizationUrl,medicationName,dosage,frequency,route,groupCode,sortOrder,startDate,endDate)

 
  QuickPickMedications.create(
    
    organizationUrl: organizationUrl,
    medicationName: medicationName,
    dosage: dosage,
    frequency: frequency,
    route: route, 
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate, 
     endDate: endDate,  
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_quick_pick_medications(id,organizationUrl,medicationName,dosage,frequency,route,groupCode,sortOrder,startDate,endDate)

   check = QuickPickMedications.where(id: id).update(
    
    organizationUrl: organizationUrl,
    medicationName: medicationName,
    dosage: dosage,
    frequency: frequency,
    route: route, 
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate, 
     endDate: endDate, 
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end


def creating_medication_kits(organizationUrl,medicationKit,description,dosage,frequency,route,groupCode,sortOrder,startDate,endDate,type)

  MedicationKits.create(
    
    organizationUrl: organizationUrl,
    medicationKit: medicationKit,
    description: description,
    dosage: dosage,
    frequency: frequency,
    route: route, 
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate, 
     endDate: endDate,  
     type: type,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_medication_kits(id,organizationUrl,medicationKit,description,dosage,frequency,route,groupCode,sortOrder,startDate,endDate,type)

   check = MedicationKits.where(id: id).update(
    
   organizationUrl: organizationUrl,
    medicationKit: medicationKit,
    description: description,
    dosage: dosage,
    frequency: frequency,
    route: route, 
    groupCode: groupCode,
    sortOrder: sortOrder,
    startDate: startDate, 
     endDate: endDate,  
     type: type,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




def creating_supervisory_due_day(organizationUrl,agencyUrl,payerUrl,agencyType,serviceCategory,code,supervisoryDueDays,autoGenerate,service)


  SupervisoryDueDay.create(
    
    organizationUrl: organizationUrl,
    agencyUrl: agencyUrl,
    payerUrl: payerUrl,
    agencyType: agencyType,
    serviceCategory: serviceCategory,
    code: code, 
    supervisoryDueDays: supervisoryDueDays,
    autoGenerate: autoGenerate,
    service: service, 
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_supervisory_due_day(id,organizationUrl,agencyUrl,payerUrl,agencyType,serviceCategory,code,supervisoryDueDays,autoGenerate,service)

   check = SupervisoryDueDay.where(id: id).update(
   organizationUrl: organizationUrl,
    agencyUrl: agencyUrl,
    payerUrl: payerUrl,
    agencyType: agencyType,
    serviceCategory: serviceCategory,
    code: code, 
    supervisoryDueDays: supervisoryDueDays,
    autoGenerate: autoGenerate,
    service: service, 
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end






def creating_patient_certifications(patientUid,certFrom,spanDays,certTo,certType,status,info,associate,physician,
    sent,received,ftfSent,ftfVisit)

  PatientCertifications.create(
    
    patientUid: patientUid,
    certFrom: certFrom,
    spanDays: spanDays,
    certTo: certTo,
    certType: certType,
    status: status, 
    info: info,
    associate: associate,
    physician: physician,
    sent: sent, 
    received: received,
    ftfSent: ftfSent,
    ftfVisit: ftfVisit,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_patient_certifications(id,patientUid,certFrom,spanDays,certTo,certType,status,info,associate,physician,
    sent,received,ftfSent,ftfVisit)

   check = PatientCertifications.where(id: id).update(
    patientUid: patientUid,
    certFrom: certFrom,
    spanDays: spanDays,
    certTo: certTo,
    certType: certType,
    status: status, 
    info: info,
    associate: associate,
    physician: physician,
    sent: sent, 
    received: received,
    ftfSent: ftfSent,
    ftfVisit: ftfVisit,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
  
end




def creating_referralSourceAddressPhoneInfo(referralSourceUid,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
   
  ReferralSourceAddressPhoneInfo.create(
    
    referralSourceUid: referralSourceUid,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    created_at: Time.new.strftime('%F %R'),
  )
end


def get_update_referralSourceAddressPhoneInfo(id,referralSourceUid,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones)
    puts "------------------UPDATING STATUS ------------------"
   
    check = ReferralSourceAddressPhoneInfo.where(id: id).update(
    referralSourceUid: referralSourceUid,
    addressType: addressType,
    address1: address1,
    address2: address2,
    city: city,
    state: state,
    zip: zip,
    addressPhoneInfoPhones: addressPhoneInfoPhones,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
    
  #end     
end




def creating_patient_forms(uid,patientID,formType,agency,status,revisedBy,performedBy,payload,organizationUrl)   
  
  PatientForm.create(
    
    uid: uid,
    patientID: patientID,
    formType: formType,
    agency: agency,
    status: status,
    revisedBy: revisedBy,
    performedBy: performedBy,
    payload: payload,
    organizationUrl: organizationUrl,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_patientForms(uid,patientID,formType,agency,status,revisedBy,performedBy,payload,organizationUrl) 

   puts "------------------UPDATING STATUS ------------------"
   
    check = PatientForm.where(uid: uid).update(
    patientID: patientID,
    formType: formType,
    agency: agency,
    status: status,
    revisedBy: revisedBy,
    performedBy: performedBy,
    payload: payload,
    organizationUrl: organizationUrl,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
end





def creating_patient_documents(uid,patientID,file,relatedTo,status,documentType,description,uploadedBy,organizationUrl)
 
  PatientDocument.create(
    
    uid: uid,
    patientID: patientID,
    file: file,
    relatedTo: relatedTo,
    status: status,
    documentType: documentType,
    description: description,
    uploadedBy: uploadedBy,
    organizationUrl: organizationUrl,
    created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_patient_documents(uid,patientID,file,relatedTo,status,documentType,description,uploadedBy,organizationUrl) 

   puts "------------------UPDATING STATUS ------------------"
   
    check = PatientDocument.where(uid: uid).update(
    patientID: patientID,
    file: file,
    relatedTo: relatedTo,
    status: status,
    documentType: documentType,
    description: description,
    uploadedBy: uploadedBy,
    organizationUrl: organizationUrl,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
end




def creating_patient_medications(uid,entryType,description,dosage,dosageAndFrequency,route,quantity,
    startDate,endDate,medicationType,prescribedBy,administeredBy,reasonForMedication,pharmacy,physicianNotified,approvedBy,
    createInterimCare,effectiveDate,patientID,organizationUrl) 

  PatientMedication.create(
    
  uid: uid,
  entryType: entryType,
  description:  description,
  dosage: dosage,
  dosageAndFrequency: dosageAndFrequency,
  route: route,
  quantity: quantity,
  startDate: startDate,
  endDate: endDate,
  medicationType: medicationType,
  prescribedBy: prescribedBy,
  administeredBy: administeredBy,
  reasonForMedication: reasonForMedication,
  pharmacy: pharmacy,
  physicianNotified: physicianNotified,
  approvedBy: approvedBy,
  createInterimCare: createInterimCare,
  effectiveDate: effectiveDate,
  patientID: patientID,
  organizationUrl: organizationUrl,
  created_at: Time.new.strftime('%F %R'),
  )
end


def  get_update_patient_medications(uid,entryType,description,dosage,dosageAndFrequency,route,quantity,
    startDate,endDate,medicationType,prescribedBy,administeredBy,reasonForMedication,pharmacy,physicianNotified,approvedBy,
    createInterimCare,effectiveDate,patientID,organizationUrl)

   puts "------------------UPDATING STATUS ------------------"
   
    check = PatientMedication.where(uid: uid).update(
   entryType: entryType,
  description:  description,
  dosage: dosage,
  dosageAndFrequency: dosageAndFrequency,
  route: route,
  quantity: quantity,
  startDate: startDate,
  endDate: endDate,
  medicationType: medicationType,
  prescribedBy: prescribedBy,
  administeredBy: administeredBy,
  reasonForMedication: reasonForMedication,
  pharmacy: pharmacy,
  physicianNotified: physicianNotified,
  approvedBy: approvedBy,
  createInterimCare: createInterimCare,
  effectiveDate: effectiveDate,
  patientID: patientID,
  organizationUrl: organizationUrl,
    updated_at: Time.new.strftime('%F %R')
    )
    puts check.inspect
    
end





