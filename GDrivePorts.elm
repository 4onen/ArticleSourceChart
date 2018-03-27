port module GDrivePorts exposing (..)

--Port telling us when the gapi has loaded
port gapiloaded : (Bool -> msg) -> Sub msg

--Port telling us when the user has signed in or out
port updateSigninStatus : (Bool -> msg) -> Sub msg

--Signs in user if true, signs out if false
port signinStatusClick : Bool -> Cmd msg