STR_APP_NAME = "Meals & Foods"
STR_API_KEY = "a46a10abfc516476286c"
MNOTIFY_URL = 'https://apps.mnotify.net'.freeze
HEADER = { 'Content-Type' => 'Application/json', 'timeout' => '180', 'accept' => 'application/json' }.freeze
CONN = Faraday.new(url: MNOTIFY_URL, headers: HEADER) do |f|
  f.response :logger
  f.adapter Faraday.default_adapter
end


STROPENTIMEOUT='180'
STRREADTIMEOUT='180'
CTRYCODE = "233"
STR_SIGN_UP_PASS = {'resp_desc' => "Success", 'resp_code' => "000", 'message' => "Successfully signed up. Kindly verify your account."}
STR_SIGN_IN_PASS = { 'resp_desc' => "Success", 'resp_code' => "000", 'message' => "Login Successful"}
STR_VERIFY_PASS = {'resp_desc' => "Success", 'resp_code' => "000", 'message' => "Account verification successful. Please login" }
STR_CHANGE_PIN_PASS = {'resp_desc' => "Success", 'resp_code' => "000", 'message' => "Your PIN was successfully changed. Kindly verify your account" }
ERR_SIGN_UP_FAIL = {'resp_desc' => "Error", 'resp_code' => "101", 'message' => ""}
ERR_SIGN_IN_FAIL = {'resp_desc' => "Error", 'resp_code' => "102", 'message' => "Incorrect phone number or pin.Could not retrieve your details."}
ERR_VERIFY_FAIL = {'resp_desc' => "Error", 'resp_code' => "103", 'message' => "There was a problem verifying your account.Please try again later"}
ERR_SYS_FAIL = {'resp_desc' => "Error", 'resp_code' => "104", 'message' => "There was a problem verifying your account.Please try again later."}
ERR_SYS_VER =  {'resp_desc' => "Error", 'resp_code' => "105", 'message' => "Please verify your account!"}
ERR_EXIST_ACC = {'resp_desc' => "Error", 'resp_code' => "106", 'message' => "Customer account exists!"}
STR_DISP_ACC_SUCC = {'resp_desc' => "Success", 'resp_code' => "107", 'message' => "Dispatcher Account Created Successfully!"}
ERR_DISP_ACC_SUCC = {'resp_desc' => "error", 'resp_code' => "108", 'message' => "Dispatcher With Mobile Number Does Not Exist!"}
ERR_INV_PASS = {'resp_desc' => "error", 'resp_code' => "109", 'message' => "Invalid Unique Code"}
STR_ORDER_GEN = {'resp_desc' => "Success", 'resp_code' => "110", 'message' => "Order Processed Successfully"}
ERR_NULL_ORDERS =  {'resp_desc' => "Error", 'resp_code' => "111", 'message' => "Order's Can't Be Empty"}
ERR_NO_ORDERS =  {'resp_desc' => "Error", 'resp_code' => "112", 'message' => "No orders Available"}
ERR_NO_RESET =  {'resp_desc' => "Error", 'resp_code' => "119", 'message' => "We didn't find your account"}
ERR_VERIFY_BEFORE_RESET =  {'resp_desc' => "Error", 'resp_code' => "120", 'message' => "Please verify your account first"}
ERR_REQ_DEF_PIN =  {'resp_desc' => "Error", 'resp_code' => "121", 'message' => "There was a problem requesting your default PIN.Make sure you are signed up"}    



ERR_FA_NAME ={ resp_code: '101', resp_desc: "facilityName is required." }
ERR_FIRST ={ resp_code: '101', resp_desc: "First Name is required." }
ERR_LAST ={ resp_code: '101', resp_desc: "Last name is required." }
ERR_CLASS ={ resp_code: '101', resp_desc: "Classification is required." }
ERR_STARTDATE={ resp_code: '101', resp_desc: "Start Date is required." }
ERR_HIREDATE ={ resp_code: '101', resp_desc: "Hire Date is required." }
ERR_AGENCY ={ resp_code: '101', resp_desc: "Home Agency is required." }

ERR_EMAIL = { resp_code: '101', resp_desc: 'Enter Email.' }
ERR_MOBILE = { resp_code: '101', resp_desc: 'Enter Mobile Number' }   
ERR_PASSWORD = { resp_code: '101', resp_desc: 'Enter Password' }
ERR_PASSCHECK = { resp_code: '102', resp_desc: 'Passwords didnt match' }
ALREADY_REGIS = { resp_code: '103', resp_desc: "Already registered" }
REGIS_SUCC = { resp_code: '200', resp_desc: "Registration Successful" }
LOGIN_SUC ={ resp_code: '200', resp_desc: "Login successful" }
LOGIN_FAIL ={ resp_code: '201', resp_desc: "Login failed. Wrong username or password. Please try again." }
REGIS_BEFOR = { resp_code: '202', resp_desc: "Sign up before you login." }                                                                                                                                                               