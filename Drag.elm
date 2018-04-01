module Drag exposing (..)

import Mouse

type alias ArticleId = Int
type alias Point = Mouse.Position

type alias Drag =
    { id : ArticleId
    , start : Point
    , current : Point
    }

type alias Draggable a =
    { a | pos : Point }

getRealPosition : Drag -> Draggable a -> Point
getRealPosition drag article =
    Mouse.Position
        (article.pos.x + drag.current.x - drag.start.x)
        (article.pos.y + drag.current.y - drag.start.y)
