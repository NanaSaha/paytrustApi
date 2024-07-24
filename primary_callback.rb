post '/primary_callback' do
    puts '--------- showing CALBACK-------'

  # request.body
  # req = JSON.parse request.body.read
  # puts req.inspect
  
  # success = req ['success']
  # reference = req ['transaction']['reference'] 
  # payment_method = req ['transaction']['payment_method'] 
  # amount = req ['transaction']['amount']
  # status = req ['transaction']['status']
  # description = req ['transaction']['description']
  # customer_name = req ['transaction']['customer']['name']
  # customer_email = req ['transaction']['customer']['email']
  # customer_telephone = req ['transaction']['customer']['telephone']

  content_type :json
  
  # Assuming the form sends data with key 'result'
  status_code = params['status_code']
  status_message = params['status_message']

   puts "The status_code id is #{status_code.to_s}"
  
  # Process the result as needed
  # For demonstration, we'll just echo it back
  { received_result: status_code }.to_json
  
  
  
 
  # puts '--------- showing PARAMETERS-------'
  # puts success
 
  # puts payment_method.to_s
  # puts amount.to_s
  # puts status.to_s
  # puts description.to_s
  # puts customer_name.to_s
  # puts customer_email.to_s
  # puts customer_telephone.to_s
  
  
# if status == "failed"

 
# puts PaymentCallbackStatus.where("reference=?", reference).update(status: status)
#   puts "-----------------"
#   puts "-------TRANSACTION FAILED ----------"
#   puts "-----------------"
#    ############## Send sms to applicant #################
#     #sms_message = "Dear #{customer_name}, Your payment for your Ghinger Appointment failed.\n Regards, Ghinger"
#     #puts "SMS Message = #{sms_message}"
#   #puts sendmsg(APP_NAME, customer_telephone, sms_message)
    
# elsif status == "success"
#     puts "-----------------"
#   puts "-------TRANSACTION PAASEEED!!!!! ----------"
#   puts "-----------------"
#     puts PaymentCallbackStatus.where("reference=?", reference).update(status: status)
  

#   ############## Send sms to applicant #################
#     #sms_message = "Dear #{customer_name}, You have successfully paid for your Ghinger Appointment.\n Regards, Ghinger"
#    # puts "SMS Message = #{sms_message}"
#   #puts sendmsg(APP_NAME, customer_telephone, sms_message)
# else

#     puts "-----------------"
#     puts "-------TRANSACTION FAILED--EROR OCCURED!!!!! ----------"
#     puts "-----------------"
  
  
#  end 

end  
 


  
  
  # tr = Transaction.where(u_code: clientReference).select(:u_code).count
#    
  # puts "---------------Transaction ---Tr #{tr}"
# 
  # if tr.to_i == 1
#     
    # savePaystate(transactionId, responseCode, amountAfterCharges, clientReference, description,externalTransactionId,amount,charges)
    # res = Transaction.where(u_code: clientReference).select(:customer_name,:amount)[0]
    # puts "Display response on console #{res}"  
#   
#     
     # if responseCode.to_s == '0000'
        # #if its successful update the transaction status to 1
#         
        # puts "---------------------------------------------"
        # puts "TRANSACTION SUCCESSFULL SO UPDATING TRANSACTION SOON"
      # update_trans_status(clientReference,"success")
#       
      # puts "-----------------FINISHED UPDATING----------------------------"
#         
    # else
      # #if it fails the status remains 0   
       # puts "---------------------------------------------"
       # puts "TRANSACTION FAILED SO UPDATING TRANSACTION SOON"
       # update_trans_status(clientReference,"fail")
        # puts "-----------------FINISHED UPDATING----------------------------"
    # end
#     
  # else
    # puts "---------------WHEN TRANS FAILs--------------------------"
    # puts "Transaction ID cant be found. Transaction failed" 
     # puts "-----------------------------------------"
  # end










 # "ResponseCode": "0000",
  # "Status": "Success",
  # "Data": {
    # "CheckoutId": "99bb18b5-0745-4de7-ac08-72665431e40b",
    # "SalesInvoiceId": "9f7d11d4d5d44d6eb5a159e6c47dcaec-20180518131450758",
    # "ClientReference": "9246158385",
    # "Status": "Success",
    # "Amount": 600,
    # "CustomerPhoneNumber": "+233541719387",
    # "PaymentDetails": {
      # "MobileMoneyNumber": "+233541719387",
      # "PaymentType": "MobileMoney"
    # },
    # "Description": "Invoice paid successfully"
  # }
# }


