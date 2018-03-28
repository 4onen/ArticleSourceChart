module LoadTab exposing (..)

import Model exposing (Model, Msg(..))
import Html exposing (Html)
import Html.Attributes
import Html.Events

view : Model -> Html Msg
view model =
    Html.div [] 
        [ Html.text "This is the file loading tab!"
        , Html.button [Html.Events.onClick TEMPAddTab] [Html.text "Add tab"]
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