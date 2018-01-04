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
    , name : String
    }


type alias JavascriptLinked a =
    { a | links : List Int }


type alias Flags =
    Maybe
        { name : String
        , articles : List ( Int, JavascriptLinked Article )
        }


init : Flags -> ( Model, Cmd Msg )
init file =
    let
        ( { articles, name }, new ) =
            case file of
                Just obj ->
                    ( obj, False )

                Nothing ->
                    ( { articles = [], name = "" }, True )

        articleDict =
            articles
                |> Dict.fromList
                |> Dict.map (\_ a -> { a | links = Set.fromList a.links })

        nextId =
            articleDict
                |> Dict.keys
                |> List.maximum
                |> Maybe.withDefault 1

        command =
            if new then
                Add Nothing
            else
                Dragging Nothing
    in
        ( Model articleDict command nextId name
        , Cmd.none
        )
