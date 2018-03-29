module GDrive exposing (..)

import Html exposing (Html)
import Html.Events

import GDrivePorts

type Msg 
    = GapiLoaded Bool
    | PickerLoaded Bool
    | UpdateSigninStatus Bool
    | SigninStatusClick Bool 
    | OpenPicker

type GapiStatus = NOT_LOADED | SIGNED_OUT | SIGNED_IN

type alias GapiSession a =
    { a | 
        gapiLoaded : GapiStatus,
        pickerLoaded : GapiStatus
    }

update : Msg -> GapiSession a -> (GapiSession a, Cmd Msg)
update message model =
    case message of
        GapiLoaded _ ->
            ({model | gapiLoaded = SIGNED_OUT}, Cmd.none)
        PickerLoaded _ ->
            ({model | pickerLoaded = SIGNED_OUT}, Cmd.none)
        UpdateSigninStatus bool ->
            let
                newStatus = if bool then SIGNED_IN else SIGNED_OUT
            in
                ({model | 
                    gapiLoaded =
                        case model.gapiLoaded of 
                            NOT_LOADED ->
                                NOT_LOADED
                            _ -> 
                                newStatus
                    , pickerLoaded =
                        case model.pickerLoaded of
                            NOT_LOADED ->
                                NOT_LOADED
                            _ ->
                                newStatus
                    }, Cmd.none)
        SigninStatusClick bool ->
            (model, GDrivePorts.signinStatusClick bool)
        OpenPicker ->
            (model, GDrivePorts.openPicker ())

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
    let
        authSub = 
            case model.gapiLoaded of
                NOT_LOADED ->
                    GDrivePorts.gapiLoaded GapiLoaded
                _ ->
                    GDrivePorts.updateSigninStatus UpdateSigninStatus
        pickerSub = 
            case model.pickerLoaded of
                NOT_LOADED ->
                    GDrivePorts.gapiPickerLoaded PickerLoaded
                _ ->
                    Sub.none
    in
        Sub.batch [authSub,pickerSub]