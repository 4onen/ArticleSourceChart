module SpecialEvents exposing (onClickPoint, onClickNoPassthrough, onClickNoDefault, onClickPointNoDefault, onMouseDownPoint)

import Json.Decode as Json
import Html.Events as Events
import Html
import Mouse
import Point exposing (Point)


targetClickPoint : Json.Decoder Point
targetClickPoint =
    Json.map2 Mouse.Position
        (Json.field "pageX" Json.int)
        (Json.field "pageY" Json.int)


eventOptionsStopPropagation =
    let
        default =
            Events.defaultOptions
    in
        { default | stopPropagation = True }


eventOptionsStopAll =
    let
        default =
            Events.defaultOptions
    in
        { default | stopPropagation = True, preventDefault = True }


onClickPoint : (Point -> msg) -> Html.Attribute msg
onClickPoint tagger =
    Events.on "click" (Json.map tagger targetClickPoint)


onClickNoPassthrough : msg -> Html.Attribute msg
onClickNoPassthrough message =
    Events.onWithOptions "click" eventOptionsStopPropagation (Json.succeed message)


onClickNoDefault : msg -> Html.Attribute msg
onClickNoDefault message =
    Events.onWithOptions "click" eventOptionsStopAll (Json.succeed message)


onClickPointNoDefault : (Point -> msg) -> Html.Attribute msg
onClickPointNoDefault tagger =
    Events.onWithOptions "down" eventOptionsStopAll (Json.map tagger targetClickPoint)


onMouseDownPoint : (Point -> msg) -> Html.Attribute msg
onMouseDownPoint tagger =
    Events.on "mousedown" (Json.map tagger targetClickPoint)
