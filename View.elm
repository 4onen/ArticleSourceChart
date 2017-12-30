module View exposing (view)

--Libs

import Html exposing (Html)
import Html.Events


--Project-specific

import Model exposing (..)
import Msg exposing (Msg(..))


view : Model -> Html Msg
view model =
    Html.div []
        [ viewToolbar model
        , viewDrawSpace model
        ]



--Toolbar


viewToolbar model =
    Html.div []
        [ viewToolbarButton ToAdd "Add"
        , viewToolbarButton ToDelete "Delete"
        , viewToolbarButton ToLink "Link"
        , viewToolbarButton ToUnlink "Unlink"
        ]


viewToolbarButton cmdMsg cmdLabel =
    Html.button [ Html.Events.onClick <| cmdMsg ] [ Html.text cmdLabel ]



--Drawing space


viewDrawSpace model =
    Html.p [] [ Html.text "Still working..." ]
