module Manytree exposing (Manytree)


type alias Datatype =
    Int


type alias Manytree =
    { data : Datatype
    , children : Manytree
    }
