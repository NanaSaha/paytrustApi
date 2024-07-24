   require 'csv' 

 ActiveRecord::Base.establish_connection(
    adapter:  'mysql2',
    host:     'localhost',
    username: 'saha',
    password: 'password',
    database: 'escrow'
)

 



 class Registration < ActiveRecord::Base
  self.table_name = 'registrations'


     def self.retrieve_registration(email)
select("id,email,fullname,phone,password,created_at,profile_pic").where(
    "email = ?","#{email}"
    )
  end

    def self.retrieve_all_registration
select("id,email,fullname,phone,created_at,profile_pic"
    )
  end

  


  end



   class Transaction < ActiveRecord::Base
  self.table_name = 'transactions'

  
    def self.retrieve_all_transactions
select("id,person_name,person_email,user_id,amount,fees,item_name,item_description,item_quantity,status,transaction_id,created_at"
    ).order('id desc')
  end


     def self.retrieve_single_transactions(user_id)
select("id,person_name,person_email,user_id,amount,fees,item_name,item_description,item_quantity,transaction_id,status,created_at").where(
    "user_id = ?","#{user_id}"
    ).order('id desc')
  end


  def self.retrieve_pending_transactions(user_id)
    select("id,person_name,person_email,user_id,amount,fees,item_name,item_description,item_quantity,transaction_id,status,created_at").where('user_id=? and status=?',user_id,"pending").order('id desc')
  end

  def self.retrieve_joined_transactions(user_id)
    select("id,person_name,person_email,user_id,amount,fees,item_name,item_description,item_quantity,transaction_id,status,created_at").where('user_id=? and status=?',user_id,"Joined").order('id desc')
  end

  def self.retrieve_pending_transactions_personEmail(person_email)
    select("id,person_name,person_email,user_id,amount,fees,item_name,item_description,item_quantity,transaction_id,status,created_at").where('person_email=? and status=?',person_email,"pending").order('id desc')
  end


  def self.retrieve_transactions_with_transId(transaction_id)
    select("id,person_name,person_email,user_id,amount,fees,item_name,item_description,item_quantity,transaction_id,status,created_at").where(
        "transaction_id = ?","#{transaction_id}"
        ).order('id desc')
      end

      def self.retrieve_join_buyer_transactions(seller_email)
select("id,seller_name,seller_email,seller_phone,buyer_id,amount,fees,
      narration,item_name,item_description,transaction_title,paid_by,status,created_at").where(
    "seller_email = ?","#{seller_email}"
    ).order('id desc')
  end

  
  end



     class SellerTransaction < ActiveRecord::Base
  self.table_name = 'seller_transactions'

  
    def self.retrieve_seller_transactions
select("id,buyer_name,buyer_email,buyer_phone,seller_id,amount,fees
      ,narration,item_name,item_description,transaction_title,paid_by,status,created_at"
    ).order('id desc')
  end


     def self.retrieve_single_seller_transactions(seller_id)
select("id,buyer_name,buyer_email,buyer_phone,seller_id,amount,fees,
      narration,item_name,item_description,transaction_title,paid_by,status,created_at").where(
    "seller_id = ?","#{seller_id}"
    ).order('id desc')
  end

      def self.retrieve_join_seller_transactions(buyer_email)
select("id,buyer_name,buyer_email,buyer_phone,seller_id,amount,fees,
      narration,item_name,item_description,transaction_title,paid_by,status,created_at").where(
    "buyer_email = ?","#{buyer_email}"
    ).order('id desc')
  end




  
  end


class Associate < ActiveRecord::Base
  self.table_name = 'associates'

   def self.retrieve_associates

    select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,image,url,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  end

  def self.retrieve_single_associate(url)

    # select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl").where(
    # "url = ?","#{url}"
    # )

  puts  physic_obj = Associate.where(url: url).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,image,url,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
    
   
   phys_address_arr = []
     physic_obj.each do |item| 
   
      puts  home_obj = Agency.where(url: item.homeAgency).select("id,url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated")
       puts  org_obj = Organization.where(url: item.organizationUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
       puts  super_obj = Associate.where(url: item.supervisor).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,image,url,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
 


    phys_address_arr << {"id": item.id, "organization_details": org_obj, "agency_details": home_obj,"supervisor_details": super_obj,"firstName": item.firstName,"middleName": item.middleName,"lastName": item.lastName,"ssn": item.ssn,"birthDate": item.birthDate,"race": item.race,"mobileEmail": item.mobileEmail,"schedulingRank": item.schedulingRank,"classification": item.classification,"discipline": item.discipline,"hireDate": item.hireDate,"startDate": item.startDate,"supervisor": item.supervisor,
      "homeAgency": item.homeAgency,"associateNumber": item.associateNumber,"associateNPI": item.associateNPI, "evvVendorID": item.evvVendorID,"evvAdminEmail": item.evvAdminEmail,"status": item.status,"image": item.image,"url": item.url,"statusReason": item.statusReason,"statusDate": item.statusDate,"eligibleForRehire": item.eligibleForRehire,"gender": item.gender,"organizationUrl": item.organizationUrl}
    end
    return phys_address_arr 

  end

   def self.retrieve_associate_with_organizationUrl(organizationUrl)

    
    puts  org_obj = Organization.where(url: organizationUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")

    puts  physic_obj = Associate.where(organizationUrl: organizationUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,image,url,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
    
   
   phys_address_arr = []
     physic_obj.each do |item| 
   
      puts  home_obj = Agency.where(url: item.homeAgency).select("id,url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated")
    
    phys_address_arr << {"id": item.id, "organization_details": org_obj, "agency_details": home_obj,"firstName": item.firstName,"middleName": item.middleName,"lastName": item.lastName,"ssn": item.ssn,"birthDate": item.birthDate,"race": item.race,"mobileEmail": item.mobileEmail,"schedulingRank": item.schedulingRank,"classification": item.classification,"discipline": item.discipline,"hireDate": item.hireDate,"startDate": item.startDate,"supervisor": item.supervisor,
      "homeAgency": item.homeAgency,"associateNumber": item.associateNumber,"associateNPI": item.associateNPI, "evvVendorID": item.evvVendorID,"evvAdminEmail": item.evvAdminEmail,"status": item.status,"image": item.image,"url": item.url,"statusReason": item.statusReason,"statusDate": item.statusDate,"eligibleForRehire": item.eligibleForRehire,"gender": item.gender,"organizationUrl": item.organizationUrl}
    end
    return phys_address_arr 

  end

   def self.delete_associate(url)

    Associate.where(url: url).delete

  end
end


#######Physician
class Physician < ActiveRecord::Base
  self.table_name = 'physicians'

   def self.retrieve_physician

    select("id,firstName,middleName,lastName,title,speciality,email,physicianGroup,endDate,startDate,status,url,salesRep,organizationUrl,updated")
  end

  def self.retrieve_single_physician(url)

    # select("id,firstName,middleName,lastName,title,speciality,email,physicianGroup,endDate,startDate,status,url,salesRep,organizationUrl,updated").where(
    # "url = ?","#{url}"
    # )

    
    puts  physic_obj = Physician.where(url: url).select("id,firstName,middleName,lastName,title,speciality,email,physicianGroup,endDate,startDate,status,url,salesRep,organizationUrl,updated")
    
     phys_address_arr = []
     physic_obj.each do |item| 

      puts  org_obj = Organization.where(url: item.organizationUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")


        puts associate_obj  = Associate.where(url: item.salesRep).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
  

    phys_address_arr << {"id": item.id, "organization_details": org_obj,"salesRep_details": associate_obj,"firstName": item.firstName,"middleName": item.middleName,"lastName": item.lastName,"title": item.title,"speciality": item.speciality,"email": item.email,"physicianGroup": item.physicianGroup,"endDate": item.endDate,"startDate": item.startDate,"status": item.status,"url": item.url,"salesRep": item.salesRep,"updated": item.updated}
    end
    return phys_address_arr 
  end

  def self.retrieve_physician_with_organizationUrl(organizationUrl)

     puts  org_obj = Organization.where(url: organizationUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")

    puts  physic_obj = Physician.where(organizationUrl: organizationUrl).select("id,firstName,middleName,lastName,title,speciality,email,physicianGroup,endDate,startDate,status,url,salesRep,organizationUrl,updated")
    
     phys_address_arr = []
     physic_obj.each do |item| 

        puts associate_obj  = Associate.where(url: item.salesRep).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
   
   

    phys_address_arr << {"id": item.id, "organization_details": org_obj,"salesRep_details": associate_obj,"firstName": item.firstName,"middleName": item.middleName,"lastName": item.lastName,"title": item.title,"speciality": item.speciality,"email": item.email,"physicianGroup": item.physicianGroup,"endDate": item.endDate,"startDate": item.startDate,"status": item.status,"url": item.url,"salesRep": item.salesRep,"updated": item.updated}
    end
    return phys_address_arr 
  end

   def self.delete_physicians(url)

    Physician.where(url: url).delete

  end
end


####### Facilties
class Facility < ActiveRecord::Base
  self.table_name = 'facilities'

   def self.retrieve_facilities

    select("id,facilityName,facilityType,email,salesRep,endDate,startDate,status,url,organizationUrl,updated,
      patientID,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,phoneType,phone")
  end

  def self.retrieve_single_facility(url)

    # select("id,facilityName,facilityType,email,salesRep,endDate,startDate,status,url,organizationUrl,updated").where(
    # "url = ?","#{url}"
    # )


    puts fac_obj = Facility.where(url: url).select("id,facilityName,facilityType,email,salesRep,endDate,startDate,status,url,organizationUrl,updated,patientID,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,phoneType,phone")
    
     
     
     phys_address_arr = []
     fac_obj.each do |item| 

      puts  org_obj = Organization.where(url: item.organizationUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
    

      puts associate_obj  = Associate.where(url: item.salesRep).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
    phys_address_arr << {"id": item.id,"organization_details": org_obj, "salesRep_details": associate_obj,"facilityName": item.facilityName, "facilityType": item.facilityType,"email": item.email, "salesRep": item.salesRep, "endDate": item.endDate, "startDate": item.startDate,"status": item.status,"url": item.url, "organizationUrl": item.organizationUrl, "updated": item.updated}
    end
    return phys_address_arr 
  end


  def self.retrieve_single_facility_with_organizationUrl(organizationUrl)
  puts fac_obj = Facility.where(organizationUrl: organizationUrl).select("id,facilityName,facilityType,email,salesRep,endDate,startDate,status,url,organizationUrl,updated,patientID,addressType,addressOne,addressTwo,city,state,zipcode,placeOfService,phoneType,phone")
    puts  org_obj = Organization.where(url: organizationUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
    
     
     
     phys_address_arr = []
     fac_obj.each do |item| 

      puts associate_obj  = Associate.where(url: item.salesRep).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
    phys_address_arr << {"id": item.id,"organization_details": org_obj, "salesRep_details": associate_obj,"facilityName": item.facilityName, "facilityType": item.facilityType,"email": item.email, "salesRep": item.salesRep, "endDate": item.endDate, "startDate": item.startDate,"status": item.status,"url": item.url, "organizationUrl": item.organizationUrl, "updated": item.updated}
    end
    return phys_address_arr 
  end


end

####### statusHistory
class StatusHistory < ActiveRecord::Base
  self.table_name = 'statusHistory'

   def self.retrieve_status

    select("id,associateUrl,changedBy,newStatus,date,effective,priorStatus,priorStatusReason,newStatusReason")
  end

  def self.retrieve_single_status(associateUrl)

    # select("id,associateUrl,changedBy,newStatus,date,effective,priorStatus,priorStatusReason,newStatusReason").where(
    # "associateUrl = ?","#{associateUrl}"
    # )

    puts  anPhIn_obj = StatusHistory.where(associateUrl: associateUrl).select("id,associateUrl,changedBy,newStatus,date,effective,priorStatus,priorStatusReason,newStatusReason")
    # puts  org_obj = Organization.where(url: item.orgUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
    puts associate_obj  = Associate.where(url: associateUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
     
     phys_address_arr = []
     anPhIn_obj.each do |item| 

    
    phys_address_arr << {"id": item.id, "associate_details": associate_obj,"changedBy": item.changedBy, "newStatus": item.newStatus,"newStatus": item.newStatus,"date": item.date, "effective": item.effective, "priorStatus": item.priorStatus,"priorStatusReason": item.priorStatusReason,"newStatusReason": item.newStatusReason}
    end
    return phys_address_arr 
  end
end



####### WEB ACCESS
class WebAccess < ActiveRecord::Base
  self.table_name = 'website_access'

   def self.retrieve_access

    select("id,associateUrl,userName,password,startDate,email,isActive,isLockedOut,endDate,lastLogin,previousLogin,passwordExpires,created,roles,orgUrl,regionUrls,agencyUrls,updated")
  end

  def self.retrieve_single_access(associateUrl)

    # select("id,associateUrl,userName,password,startDate,email,isActive,isLockedOut,endDate,lastLogin,previousLogin,passwordExpires,created,roles,orgUrl,regionUrls,agencyUrls,updated").where(
    # "associateUrl = ?","#{associateUrl}"
    # )


    
    puts associate_obj  = Associate.where(url: associateUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
    puts  web_Access_obj = WebAccess.where(associateUrl: associateUrl).select("id,associateUrl,userName,password,startDate,email,isActive,isLockedOut,endDate,lastLogin,previousLogin,passwordExpires,created,roles,orgUrl,regionUrls,agencyUrls,updated")
    
     
     phys_address_arr = []
     web_Access_obj.each do |item| 

      puts  org_obj = Organization.where(url: item.orgUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")


    phys_address_arr << {"id": item.id, "associate_details": associate_obj,"organization_details": org_obj,"userName": item.userName,"password": item.password,"startDate": item.startDate,"email": item.email,"isActive": item.isActive,"isLockedOut": item.isLockedOut,"endDate": item.endDate,"lastLogin": item.lastLogin,"previousLogin": item.previousLogin,"passwordExpires": item.passwordExpires,"created": item.created,"roles": item.roles,"regionUrls": item.regionUrls,"agencyUrls": item.agencyUrls,"updated": item.updated}
    end
    return phys_address_arr
  end


  def self.retrieve_access_with_username(userName)

    # select("id,associateUrl,userName,password,startDate,email,isActive,isLockedOut,endDate,lastLogin,previousLogin,passwordExpires,created,roles,orgUrl,regionUrls,agencyUrls,updated").where(
    # "userName = ?","#{userName}"
    # )


    puts  web_Access_obj = WebAccess.where(userName: userName).select("id,associateUrl,userName,password,startDate,email,isActive,isLockedOut,endDate,lastLogin,previousLogin,passwordExpires,created,roles,orgUrl,regionUrls,agencyUrls,updated")
    
     
     phys_address_arr = []
     web_Access_obj.each do |item| 

      puts  org_obj = Organization.where(url: item.orgUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
       puts associate_obj  = Associate.where(url: item.associateUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  

    phys_address_arr << {"id": item.id, "associate_details": associate_obj,"organization_details": org_obj,"userName": item.userName,"startDate": item.startDate,"email": item.email,"isActive": item.isActive,"password": item.password,"isLockedOut": item.isLockedOut,"endDate": item.endDate,"lastLogin": item.lastLogin,"previousLogin": item.previousLogin,"passwordExpires": item.passwordExpires,"created": item.created,"roles": item.roles,"regionUrls": item.regionUrls,"agencyUrls": item.agencyUrls,"updated": item.updated}
    end
    return phys_address_arr 
  end


end


####### Organizations
class Organization < ActiveRecord::Base
  self.table_name = 'organizations'

   def self.retrieve_organizations

    select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
  end

  def self.retrieve_single_organization(url)

    select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate").where(
    "url = ?","#{url}"
    )
  end


   def self.retrieve_single_organization_with_organizationCode(organizationCode)

    # select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate").where(
    # "organizationCode = ?","#{organizationCode}"
    # )

      #puts  anPhIn_obj = Payroll.where(associateUrl: associateUrl).select("id,associateUrl,salary,payrollType,federalFillingStatus,stateFillingStatus,stateDeductions,startDate,wbCheck")
   puts  org_obj = Organization.where(organizationCode: organizationCode).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
    
     
     phys_address_arr = []
     org_obj.each do |item| 

      puts associate_obj  = Associate.where(url: item.primaryContact).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
    phys_address_arr << {"id": item.id, "primaryContact_details": associate_obj,"url": item.url,"organizationName": item.organizationName, "organizationCode": item.organizationCode,"email": item.email, "phoneType": item.phoneType, "phone": item.phone, "companyStartDate": item.companyStartDate,"companyEndDate": item.companyEndDate}
    end
    return phys_address_arr 
  end
end


####### Associate Notes
class AssociateNote < ActiveRecord::Base
  self.table_name = 'associate_notes'

   def self.retrieve_associate_notes

    select("id,associateUrl,noteBy,document,note,active,date,noteType")
  end

  def self.retrieve_single_associate_notes(associateUrl)

    # select("id,associateUrl,noteBy,document,note,active,date,noteType").where(
    # "associateUrl = ?","#{associateUrl}"
    # )

     puts  anPhIn_obj = AssociateNote.where(associateUrl: associateUrl).select("id,associateUrl,noteBy,document,note,active,date,noteType")
    # puts  org_obj = Organization.where(url: item.orgUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
    puts associate_obj  = Associate.where(url: associateUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
     
     phys_address_arr = []
     anPhIn_obj.each do |item| 

    
    phys_address_arr << {"id": item.id, "associate_details": associate_obj,"noteBy": item.noteBy, "document": item.document,"note": item.note,"active": item.active, "date": item.date, "noteType": item.noteType}
    end
    return phys_address_arr 
  end
end

####### ancillaryPhoneInfo 
class AncillaryPhoneInfo < ActiveRecord::Base
  self.table_name = 'ancillaryPhoneInfo'

   def self.retrieve_ancillaryPhoneInfo

    select("id,associateUrl,phoneType,phone,description")


  end

  def self.retrieve_single_ancillaryPhoneInfo(associateUrl)

    # select("id,associateUrl,phoneType,phone,description").where(
    # "associateUrl = ?","#{associateUrl}"
    # )


    puts  anPhIn_obj = AncillaryPhoneInfo.where(associateUrl: associateUrl).select("id,associateUrl,phoneType,phone,description")
    # puts  org_obj = Organization.where(url: item.orgUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
    puts associate_obj  = Associate.where(url: associateUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
     
     phys_address_arr = []
     anPhIn_obj.each do |item| 

    
    phys_address_arr << {"id": item.id, "associate_details": associate_obj,"phoneType": item.phoneType, "phone": item.phone,"description": item.description}
    end
    return phys_address_arr 
  end
end

####### addressPhoneInfo 
class AddressPhoneInfo < ActiveRecord::Base
  self.table_name = 'addressPhoneInfo'

   def self.retrieve_addressPhoneInfo

    select("id,associateUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones")
  end

  def self.retrieve_single_addressPhoneInfo(associateUrl)

    # select("id,associateUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones").where(
    # "associateUrl = ?","#{associateUrl}"
    # )

     puts  anPhIn_obj = AddressPhoneInfo.where(associateUrl: associateUrl).select("id,associateUrl,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones")
    # puts  org_obj = Organization.where(url: item.orgUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
    puts associate_obj  = Associate.where(url: associateUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
     
     phys_address_arr = []
     anPhIn_obj.each do |item| 

    
    phys_address_arr << {"id": item.id, "associate_details": associate_obj,"addressType": item.addressType, "address1": item.address1,"address2": item.address2,"city": item.city, "state": item.state, "zip": item.zip, "addressPhoneInfoPhones": item.addressPhoneInfoPhones}
    end
    return phys_address_arr 
  end
end

####### emergencyContacts 
class EmergencyContact < ActiveRecord::Base
  self.table_name = 'emergencyContacts'

   def self.retrieve_emergencyContacts

    select("id,associateUrl,relationship,firstName,lastName,priority,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones")
  end

  def self.retrieve_single_emergencyContact(associateUrl)

    # select("id,associateUrl,relationship,firstName,lastName,priority,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones").where(
    # "associateUrl = ?","#{associateUrl}"
    # ) 



    puts  emergency_obj = EmergencyContact.where(associateUrl: associateUrl).select("id,associateUrl,relationship,firstName,lastName,priority,addressType,address1,address2,city,state,zip,addressPhoneInfoPhones")

    puts  associate_obj = Associate.where(url: associateUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,image,url,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
    
     phys_address_arr = []
     emergency_obj.each do |item| 
   

    phys_address_arr << {"id": item.id, "associate_details": associate_obj,"relationship": item.relationship,"firstName": item.firstName,"lastName": item.lastName,"priority": item.priority,"addressType": item.addressType,"address1": item.address1,"address2": item.address2,"city": item.city,"state": item.state,"zip": item.zip,"addressPhoneInfoPhones": item.addressPhoneInfoPhones}
    end
    return phys_address_arr 
  end


end

####### documents 
class Document < ActiveRecord::Base
  self.table_name = 'documents'

   def self.retrieve_documents

    select("id,associateUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate")
  end

  def self.retrieve_single_document(id)

    select("id,associateUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate").where(
    "id = ?","#{id}"
    )
  end

   def self.retrieve_single_document_with_associateUrl(associateUrl)

    # select("id,associateUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate").where(
    # "associateUrl = ?","#{associateUrl}"
    # )


      puts  anPhIn_obj = Document.where(associateUrl: associateUrl).select("id,associateUrl,file,documentType,documentStatus,description,note,uploadedBy,uploadedDate")
    # puts  org_obj = Organization.where(url: item.orgUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
    puts associate_obj  = Associate.where(url: associateUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
     
     phys_address_arr = []
     anPhIn_obj.each do |item| 

    
    phys_address_arr << {"id": item.id, "associate_details": associate_obj,"file": item.file, "documentType": item.documentType,"documentStatus": item.documentStatus,"description": item.description, "note": item.note, "uploadedBy": item.uploadedBy, "uploadedDate": item.uploadedDate}
    end
    return phys_address_arr 
  end
end



####### documents 
class AssociateAvailability < ActiveRecord::Base
  self.table_name = 'associate_availabilities'

   def self.retrieve_associate_availabilities

    select("id,associateUrl,date,day,start,end,availability_type,reason")
  end

  def self.retrieve_single_associate_availability(associateUrl)

    # select("id,associateUrl,date,day,start,end,availability_type,reason").where(
    # "associateUrl = ?","#{associateUrl}"
    # )

  puts  anPhIn_obj = AssociateAvailability.where(associateUrl: associateUrl).select("id,associateUrl,date,day,start,end,availability_type,reason")
    # puts  org_obj = Organization.where(url: item.orgUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
    puts associate_obj  = Associate.where(url: associateUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
     
     phys_address_arr = []
     anPhIn_obj.each do |item| 

    
    phys_address_arr << {"id": item.id, "associate_details": associate_obj,"date": item.date, "day": item.day,"start": item.start,"end": item.end, "availability_type": item.availability_type, "reason": item.reason}
    end
    return phys_address_arr 
  end
end

####### payroll 
class Payroll < ActiveRecord::Base
  self.table_name = 'payroll'

   def self.retrieve_payroll

    select("id,associateUrl,salary,payrollType,federalFillingStatus,stateFillingStatus,stateDeductions,startDate,wbCheck")
  end

  def self.retrieve_single_payroll(associateUrl)

    # select("id,associateUrl,salary,payrollType,federalFillingStatus,stateFillingStatus,stateDeductions,startDate,wbCheck").where(
    # "associateUrl = ?","#{associateUrl}"
    # )

     puts  anPhIn_obj = Payroll.where(associateUrl: associateUrl).select("id,associateUrl,salary,payrollType,federalFillingStatus,stateFillingStatus,stateDeductions,startDate,wbCheck")
    # puts  org_obj = Organization.where(url: item.orgUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")
    puts associate_obj  = Associate.where(url: associateUrl).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
  
     
     phys_address_arr = []
     anPhIn_obj.each do |item| 

    
    phys_address_arr << {"id": item.id, "associate_details": associate_obj,"salary": item.salary, "payrollType": item.payrollType,"federalFillingStatus": item.federalFillingStatus,"stateFillingStatus": item.stateFillingStatus, "stateDeductions": item.stateDeductions, "startDate": item.startDate, "wbCheck": item.wbCheck}
    end
    return phys_address_arr 
  end
end


####### agency 
class Agency < ActiveRecord::Base
  self.table_name = 'agencies'

   def self.retrieve_agencies

    select("id,url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated")

  end

  def self.retrieve_single_agency(url)

    select("id,url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated").where(
    "url = ?","#{url}"
    )
  end

   def self.retrieve_single_agency_with_regionUrl(regionUrl)

    # select("id,url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated").where(
    # "regionUrl = ?","#{regionUrl}"
    # )


     puts  org_obj = Region.where(url: regionUrl).select("id,url,organizationUrl,regionName,regionCode,email,primaryContact,startDate,endDate,updated")

    puts  physic_obj = Agency.where(regionUrl: regionUrl).select("id,url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated")
    
     phys_address_arr = []
     physic_obj.each do |item| 
   

    phys_address_arr << {"id": item.id, "region_details": org_obj,"url": item.url,"agencyName": item.agencyName,"agencyType": item.agencyType,"payrollCutoff": item.payrollCutoff,"procActionDate": item.procActionDate,"nameOnInvoice": item.nameOnInvoice,"agencyCode": item.agencyCode,"email": item.email,"primaryContact": item.primaryContact,"startDate": item.startDate,"endDate": item.endDate,"externalFacilityID": item.externalFacilityID,"agencyReportID": item.agencyReportID,"updated": item.updated}
    end
    return phys_address_arr 
  end

  def self.retrieve_single_agency_with_organizationUrl(organizationUrl)

    # select("id,url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated").where(
    # "organizationUrl = ?","#{organizationUrl}"
    # )
     puts  org_obj = Organization.where(url: organizationUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")

    puts  physic_obj = Agency.where(organizationUrl: organizationUrl).select("id,url,organizationUrl,regionUrl,agencyName,agencyType,payrollCutoff,procActionDate,nameOnInvoice,agencyCode,email,primaryContact,startDate,endDate,externalFacilityID,agencyReportID,updated")
    
     phys_address_arr = []
     physic_obj.each do |item| 

    puts  region_obj = Region.where(url: item.regionUrl).select("id,url,organizationUrl,regionName,regionCode,email,primaryContact,startDate,endDate,updated")
     puts primaryContact_obj  = Associate.where(url: item.primaryContact).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
    
   

    phys_address_arr << {"id": item.id, "organization_details": org_obj,"region_details": region_obj,"primary_contact_details": primaryContact_obj,"url": item.url,"agencyName": item.agencyName,"agencyType": item.agencyType,"payrollCutoff": item.payrollCutoff,"procActionDate": item.procActionDate,"nameOnInvoice": item.nameOnInvoice,"agencyCode": item.agencyCode,"email": item.email,"primaryContact": item.primaryContact,"startDate": item.startDate,"endDate": item.endDate,"externalFacilityID": item.externalFacilityID,"agencyReportID": item.agencyReportID,"updated": item.updated}
    end
    return phys_address_arr 
  end
end

####### regions 
class Region < ActiveRecord::Base
  self.table_name = 'regions'

   def self.retrieve_regions

    select("id,url,organizationUrl,regionName,regionCode,email,primaryContact,startDate,endDate,updated")

  end

  def self.retrieve_single_region(url)

    select("id,url,organizationUrl,regionName,regionCode,email,primaryContact,startDate,endDate,updated").where(
    "url = ?","#{url}"
    )
  end

   def self.retrieve_single_region_with_org(organizationUrl)

    select("id,url,organizationUrl,regionName,regionCode,email,primaryContact,startDate,endDate,updated").where(
    "organizationUrl = ?","#{organizationUrl}"
    )



    puts  org_obj = Organization.where(url: organizationUrl).select("id,url,organizationName,organizationCode,email,primaryContact,phoneType,phone,companyStartDate,companyEndDate")

    puts  region_obj = Region.where(organizationUrl: organizationUrl).select("id,url,organizationUrl,regionName,regionCode,email,primaryContact,startDate,endDate,updated")
    
    

     phys_address_arr = []
     region_obj.each do |item| 

      puts primaryContact_obj  = Associate.where(url: item.primaryContact).select("id,firstName,middleName,lastName,ssn,birthDate,race,email,mobileEmail,schedulingRank,classification,discipline,hireDate,startDate,supervisor,homeAgency,associateNumber,associateNPI,evvVendorID,evvAdminEmail,status,url,image,statusReason,statusDate,eligibleForRehire,gender,organizationUrl")
    
   

    phys_address_arr << {"id": item.id, "organization_details": org_obj,"primary_contact_details": primaryContact_obj,"url": item.url,"organizationUrl": item.organizationUrl,"regionName": item.regionName,"regionCode": item.regionCode,"email": item.email,"primaryContact": item.primaryContact,"startDate": item.startDate,"endDate": item.endDate,"updated": item.updated}
    end
    return phys_address_arr 
  end
end




class PatientForm < ActiveRecord::Base
  self.table_name = 'patient_forms'

   def self.retrieve_patient_forms
    select("uid,patientID,formType,agency,status,revisedBy,performedBy,payload,organizationUrl,created_at")
  end


    def self.retrieve_single_patient_forms(uid)
select("uid,patientID,formType,agency,status,revisedBy,performedBy,payload,organizationUrl,created_at").where(
    "uid = ?","#{uid}"
    )
  end

  end



  class PatientDocument < ActiveRecord::Base
  self.table_name = 'patient_documents'

   def self.retrieve_patient_documents
    select("uid,patientID,file,relatedTo,status,documentType,description,uploadedBy,organizationUrl,created_at")
  end


    def self.retrieve_single_patient_documents(uid)
select("uid,patientID,file,relatedTo,status,documentType,description,uploadedBy,organizationUrl,created_at").where(
    "uid = ?","#{uid}"
    )
  end

  end




    class PatientMedication < ActiveRecord::Base
  self.table_name = 'patient_medications'

   def self.retrieve_patient_medications
    select("uid,entryType,description,dosage,dosageAndFrequency,route,quantity,
    startDate,endDate,medicationType,prescribedBy,administeredBy,reasonForMedication,pharmacy,physicianNotified,approvedBy,
    createInterimCare,effectiveDate,patientID,organizationUrl,created_at")
  end


    def self.retrieve_single_patient_medications(uid)
select("uid,entryType,description,dosage,dosageAndFrequency,route,quantity,
    startDate,endDate,medicationType,prescribedBy,administeredBy,reasonForMedication,pharmacy,physicianNotified,approvedBy,
    createInterimCare,effectiveDate,patientID,organizationUrl,created_at").where(
    "uid = ?","#{uid}"
    )
  end

  end



  




###BULK IMPORT
class BulkImport < ActiveRecord::Base
  self.table_name = 'bulk_import'

   def self.import_data(file)
    

      puts "Reading Temp------------------------------ #{file}"  

      
   
            # Thread.new do
              CSV.foreach(file,headers: true, encoding: 'iso-8859-1:utf-8') do |row|
              
                #if row["organizationUrl"].present? && row["resourceType"].present?
                        @store_items = BulkImport.new(name: row["name"], associate_number: row["associate_number"],status: row["status"],
                          discipline: row["discipline"],hire_date: row["hire_date"],start_date: row["start_date"],termination_date: row["termination_date"],
                          territory_name: row["territory_name"],preferred_phone: row["preferred_phone"])
                        @store_items.save!
  
                       puts "RUNNIN HEADER------------------------------"    
  
               
          
          end

   end

end








