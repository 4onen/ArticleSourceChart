module SpecialEvents exposing (onClickPoint, onClickNoPassthrough, onClickNoDefault, onClickPointNoDefault, onMouseDownPoint)

import Json.Decode as Json
import Html.Events
import Html
import Mouse

type alias Point = Mouse.Position


targetClickPoint : Json.Decoder Point
targetClickPoint =
    Json.map2 Mouse.Position
        (Json.field "pageX" Json.int)
        (Json.field "pageY" Json.int)

eventOptionsStopPropagation : Html.Events.Options
eventOptionsStopPropagation =
    let
        default =
            Html.Events.defaultOptions
    in
        { default | stopPropagation = True }

eventOptionsStopAll : Html.Events.Options
eventOptionsStopAll =
    let
        default =
            Html.Events.defaultOptions
    in
        { default | stopPropagation = True, preventDefault = True }


onClickPoint : (Point -> msg) -> Html.Attribute msg
onClickPoint tagger =
    Html.Events.on "click" <| Json.map tagger targetClickPoint


onClickNoPassthrough : msg -> Html.Attribute msg
onClickNoPassthrough message =
    Html.Events.onWithOptions "click" eventOptionsStopPropagation <| Json.succeed message


onClickNoDefault : msg -> Html.Attribute msg
onClickNoDefault message =
    Html.Events.onWithOptions "click" eventOptionsStopAll <| Json.succeed message


onClickPointNoDefault : (Point -> msg) -> Html.Attribute msg
onClickPointNoDefault tagger =
    Html.Events.onWithOptions "down" eventOptionsStopAll <| Json.map tagger targetClickPoint


onMouseDownPoint : (Point -> msg) -> Html.Attribute msg
onMouseDownPoint tagger =
    Html.Events.on "mousedown" <| Json.map tagger targetClickPoint
