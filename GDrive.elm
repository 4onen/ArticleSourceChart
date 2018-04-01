module GDrive exposing (..)

import Html exposing (Html, Attribute)
import Html.Events
import Html.Attributes

import GDrivePorts

type Msg 
    = GapiLoaded Bool
    | PickerLoaded Bool
    | UpdateSigninStatus Bool
    | SigninStatusClick Bool 
    | OpenPicker
    | PickerFile String
    | PickerError String

type GapiStatus = NOT_LOADED | SIGNED_OUT | SIGNED_IN

type alias GapiSession a =
    { a | 
        gapiLoaded : GapiStatus,
        pickerLoaded : GapiStatus,
        pickerError : Maybe String
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
        PickerFile str ->
            (model, Cmd.none) --Should never run.
        PickerError str ->
            ({model | pickerError = Just str}, Cmd.none)

viewButtonAttribute : GapiSession a -> Html.Attribute Msg
viewButtonAttribute {gapiLoaded,pickerLoaded} =
    case (gapiLoaded,pickerLoaded) of 
        (NOT_LOADED,_) ->
            Html.Attributes.disabled True
        (SIGNED_OUT,_) ->
            Html.Events.onClick (SigninStatusClick True)
        (SIGNED_IN,NOT_LOADED) ->
            Html.Attributes.disabled True
        (SIGNED_IN,_) ->
            Html.Events.onClick (OpenPicker)

viewStatusText : GapiSession a -> String
viewStatusText {gapiLoaded,pickerLoaded} =
    case (gapiLoaded,pickerLoaded) of
        (NOT_LOADED,_) -> "Loading Google Drive™..."
        (SIGNED_OUT,_) -> "Sign in to Google Drive™"
        (SIGNED_IN,NOT_LOADED) -> "Unspecified error loading Google Drive™ apis"
        (SIGNED_IN,_) -> "Open file from Google Drive™"

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
                    Sub.batch 
                        [ GDrivePorts.pickerFile PickerFile
                        , GDrivePorts.pickerError PickerError
                        ]
    in
        Sub.batch [authSub,pickerSub]