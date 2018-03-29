module Point exposing (..)

import Mouse


type alias Point =
    Mouse.Position


toString : Point -> String
toString { x, y } =
    (Basics.toString x) ++ "," ++ (Basics.toString y)


getX : Point -> Int
getX { x, y } =
    x


getY : Point -> Int
getY { x, y } =
    y


midpoint : Point -> Point -> Point
midpoint p1 p2 =
    let
        ( x1, y1 ) =
            ( p1.x, p1.y )

        ( x2, y2 ) =
            ( p2.x, p2.y )
    in
        { x = (x1 + x2) // 2, y = (y1 + y2) // 2 }
