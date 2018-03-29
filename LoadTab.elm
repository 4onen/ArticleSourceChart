module LoadTab exposing (init,update,view,viewLabel)

import Html exposing (Html)
import Html.Attributes
import Html.Events

import Model exposing (Model, Msg(..))
import LoadTabModel
import GDrive

init : LoadTabModel.Model
init = LoadTabModel.Root


update : LoadTabModel.Msg -> Model -> (Model, Cmd LoadTabModel.Msg)
update msg model =
    case msg of
        _ ->
            (model, Cmd.none)



(=>) : a -> b -> (a,b)
(=>) =
    (,)

view : Model -> Html Msg
view model =
    Html.ul [] 
        [ Html.li [] (newButton)
        , Html.li [] (copyPasteButton)
        , Html.li [] (fileUploadButton)
        , Html.li [] (gDriveButton model.gapiLoaded model.pickerLoaded)
        ]

newButton : List (Html Msg)
newButton =
    [ Html.button 
        [ Html.Attributes.classList
            [ ("loadButton",True)
            , ("loadNewButton",True)
            ]
        , Html.Events.onClick (Model.LoadTabMsg LoadTabModel.ButtonNew)
        ] []
    , Html.text "New"
    ]

copyPasteButton : List (Html Msg)
copyPasteButton =
    [ Html.button
        [ Html.Attributes.classList
            [ ("loadButton",True)
            , ("loadCopyPasteButton",True)
            ]
        , Html.Events.onClick (Model.LoadTabMsg LoadTabModel.ButtonCopyPaste)
        ] []
    , Html.text "Copy/Paste"
    ]

fileUploadButton : List (Html Msg)
fileUploadButton =
    [ Html.button
        [ Html.Attributes.classList
            [ ("loadButton",True)
            , ("loadFileUploadButton",True)
            ]
        , Html.Attributes.disabled True
        ] []
    , Html.text "File upload"
    ]

gDriveButton : GDrive.GapiStatus -> GDrive.GapiStatus -> List (Html Msg)
gDriveButton gapiLoaded pickerLoaded =
    let 
        extraAttribute =
            case (gapiLoaded,pickerLoaded) of 
                (GDrive.NOT_LOADED,_) ->
                    Html.Attributes.disabled True
                (GDrive.SIGNED_OUT,_) ->
                    Html.Events.onClick 
                        (GapiMsg (GDrive.SigninStatusClick True))
                (GDrive.SIGNED_IN,GDrive.NOT_LOADED) ->
                    Html.Attributes.disabled True
                (GDrive.SIGNED_IN,_) ->
                    Html.Events.onClick
                        (GapiMsg GDrive.OpenPicker)
        label =
            case (gapiLoaded,pickerLoaded) of
                (GDrive.NOT_LOADED,_) ->
                    "Google Drive support loading..."
                (GDrive.SIGNED_OUT,_) ->
                    "Sign in with Google Drive"
                (GDrive.SIGNED_IN,GDrive.NOT_LOADED) ->
                    "Google Drive picker missing. Huh."
                (GDrive.SIGNED_IN,_) ->
                    "Open from Google Drive"
    in
        [ Html.button
            [ Html.Attributes.classList
                [ ("loadButton",True)
                , ("loadGDriveButton",True)
                ]
            , extraAttribute
            ] []
        , Html.text label
        ]


viewLabel : Bool -> Html Msg
viewLabel selected =
    let
        action =
            if selected then
                Html.Attributes.disabled True
            else
                Html.Events.onClick (SwitchTab -1)
    in
        Html.button [action] [Html.text "File Menu"]