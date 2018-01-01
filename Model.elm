module Model exposing (..)

--Libs

import Dict exposing (Dict)
import Set exposing (Set)


-- Project specific

import Point exposing (Point)
import Linked exposing (Linked)
import Article exposing (Article)
import ArticleId exposing (ArticleId)
import Msg exposing (Msg(..), Command(..))


type alias Model =
    { articles : Dict Int (Linked Article)
    , command : Command
    , nextId : ArticleId
    }


init : ( Model, Cmd a )
init =
    ( Model Dict.empty (Add Nothing) 1
    , Cmd.none
    )


dummyModel : Model
dummyModel =
    { command = Add Nothing
    , articles =
        Dict.fromList
            [ ( 0, { pos = { x = 200, y = 200 }, headline = "HDN1", author = "John Doe", link = "http://fake.com", links = Set.fromList [ 1 ] } )
            , ( 1, { pos = { x = 400, y = 400 }, headline = "HDN2", author = "Jane Doe", link = "https://xkcd.com", links = Set.empty } )
            ]
    , nextId = 2
    }
