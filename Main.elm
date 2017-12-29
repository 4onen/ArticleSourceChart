module Main exposing (..)

--Libs

import Html


--Project-specific

import Model exposing (..)
import Msg exposing (..)
import Update exposing (update)
import View exposing (view)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
