module Main exposing (..)

--Libs

import Html


--Project-specific

import Model exposing (..)
import Msg exposing (..)
import Update exposing (update)
import View exposing (view)
import Subs exposing (subscriptions)


main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
