module LoadTab exposing (init,update,view,viewLabel)

import Html exposing (Html)
import Html.Attributes
import Html.Events

import Model exposing (Model, Msg(..), LoadTabMsg(..), LoadTabModel)

init : Model.LoadTabModel
init = Model.Root


update : LoadTabMsg -> Model -> (Model, Cmd LoadTabMsg)
update msg model =
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
        , Html.li [] (googleDriveButton)
        ]

newButton : List (Html Msg)
newButton =
    [ Html.button 
        [ Html.Attributes.classList
            [ ("loadButton",True)
            , ("loadNewButton",True)
            ]
        , Html.Events.onClick (Model.LoadTabMsg ButtonNew)
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
        , Html.Events.onClick (Model.LoadTabMsg ButtonCopyPaste)
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

googleDriveButton : List (Html Msg)
googleDriveButton =
    [ Html.button
        [ Html.Attributes.classList
            [ ("loadButton",True)
            , ("loadFileUploadButton",True)
            ]
        , Html.Attributes.disabled True
        ] []
    , Html.text "Google Drive"
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
        Html.button [action] [Html.text "File"]