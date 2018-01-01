module Subs exposing (subscriptions)

import Mouse
import Drag exposing (Drag)
import Msg exposing (..)
import Model exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.command of
        Dragging (Just _) ->
            Sub.batch
                [ Mouse.moves DragTo
                , Mouse.ups <| always <| SwitchTo ToDrag
                ]

        _ ->
            Sub.none
