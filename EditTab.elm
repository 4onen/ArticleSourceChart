module EditTab exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode

import EditTabModel exposing (EditTabModel)
import Model exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    Html.text "This is an edit tab! Woooo! There should be a chart here!"


viewLabel : Bool -> Int -> EditTabModel -> Html Msg
viewLabel selected index tab =
    let
        title = "TempEditTabHeader"
        action =
            case selected of
                True ->
                    Html.Attributes.disabled True
                False ->
                    Html.Events.onClick (SwitchTab index)
        defaultButtonOptions = Html.Events.defaultOptions
        stopPropagationOptions =
            {defaultButtonOptions | stopPropagation = True}
        removeButton = 
            [Html.button 
                [ Html.Events.onWithOptions 
                    "click" 
                    stopPropagationOptions 
                    (Json.Decode.succeed (CloseTab index))
                ] 
                [ Html.text "X" ]
            ]
    in
        Html.button [action] ((Html.text (title++" "))::removeButton)