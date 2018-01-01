module Article exposing (..)

import Mouse
import Point exposing (Point)


type alias URL =
    String


type ArticleField
    = Headline String
    | Author String
    | Link URL


type alias Article =
    { pos : Mouse.Position
    , headline : String
    , author : String
    , link : URL
    }
