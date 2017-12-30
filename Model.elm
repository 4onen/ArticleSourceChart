module Model exposing (..)

import Point exposing (Point)
import Article exposing (Article)
import ArticleId exposing (ArticleId)


type Command
    = Add (Maybe ArticleId)
    | Delete ()


type alias Model =
    { articles : List (Maybe Article)
    , command : Command
    }


init : ( Model, Cmd a )
init =
    ( Model [] (Add Nothing)
    , Cmd.none
    )
