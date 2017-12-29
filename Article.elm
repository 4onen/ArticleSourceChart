module Article exposing (..)

import Point exposing (Point)


type alias URL =
    String


type alias Article =
    { pos : Point
    , headline : String
    , author : String
    , link : URL
    }
