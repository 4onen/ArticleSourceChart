module Drag exposing (..)

import Mouse
import Point exposing (Point)
import Linked exposing (Linked)
import Article exposing (Article)
import ArticleId exposing (ArticleId)


type alias Drag =
    { id : ArticleId
    , start : Point
    , current : Point
    }


getRealPosition : Drag -> Linked Article -> Point
getRealPosition drag article =
    Mouse.Position
        (article.pos.x + drag.current.x - drag.start.x)
        (article.pos.y + drag.current.y - drag.start.y)
