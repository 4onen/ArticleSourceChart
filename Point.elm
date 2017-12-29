module Point exposing (Point)


type alias CoordinateType =
    Int


type alias Point =
    ( CoordinateType, CoordinateType )


toString : Point -> String
toString ( x, y ) =
    (Basics.toString x) ++ "," ++ (Basics.toString y)


getX : Point -> CoordinateType
getX ( x, _ ) =
    x


getY : Point -> CoordinateType
getY ( _, y ) =
    y
