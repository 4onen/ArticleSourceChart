module GDrive exposing (..)

import Html exposing (Html)
import Html.Events

import GDrivePorts

type Msg 
    = GapiLoaded Bool
    | UpdateSigninStatus Bool
    | SigninStatusClick Bool 

type GapiStatus = NOT_LOADED | SIGNED_OUT | SIGNED_IN

type alias GapiSession a =
    { a | gapiLoaded : GapiStatus }

init : GapiStatus
init = NOT_LOADED

update : Msg -> GapiSession a -> (GapiSession a, Cmd Msg)
update message model =
    case message of
        GapiLoaded _ ->
            (updateGapiStatus SIGNED_OUT model, Cmd.none)
        UpdateSigninStatus bool ->
            ( case bool of
                True ->
                    (updateGapiStatus SIGNED_IN model, Cmd.none)
                False ->
                    (updateGapiStatus SIGNED_OUT model, Cmd.none)
            )
        SigninStatusClick bool ->
            (model, GDrivePorts.signinStatusClick bool)

updateGapiStatus : GapiStatus -> GapiSession a -> GapiSession a
updateGapiStatus newStat model =
    {model | gapiLoaded = newStat}

view : GapiSession a -> Html Msg
view model = 
    case model.gapiLoaded of
        NOT_LOADED ->
            Html.text "Google drive loading..."
        SIGNED_OUT ->
            Html.button 
                [Html.Events.onClick (SigninStatusClick True)] 
                [Html.text "Sign in"]
        SIGNED_IN ->
            Html.button 
                [Html.Events.onClick (SigninStatusClick False)] 
                [Html.text "Sign out"]

subscriptions : GapiSession a -> Sub Msg
subscriptions model =
    case model.gapiLoaded of
        NOT_LOADED ->
            GDrivePorts.gapiloaded GapiLoaded
        _ ->
            GDrivePorts.updateSigninStatus UpdateSigninStatus