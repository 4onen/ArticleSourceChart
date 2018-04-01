module Import exposing (importChart)

import Mouse
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Dict exposing (Dict)
import Set exposing (Set)

import EditTabModel exposing (Model, JavascriptLinked, Article)



type alias ImportModel = 
    { chartName : String
    , articles : List (Int, JavascriptLinked Article)
    }

importChart : String -> Model
importChart str =
    let
        pointDecoder =
            Json.Decode.Pipeline.decode Mouse.Position
                |> required "x" int
                |> required "y" int

        jLinkedArticleDecoder =
            Json.Decode.Pipeline.decode 
                (\pos headline author link links ->
                    { pos = pos
                    , headline = headline
                    , author = author
                    , link = link 
                    , links = links
                    }
                )
                |> required "pos" pointDecoder
                |> required "headline" string
                |> required "author" string
                |> required "link" string
                |> required "links" (list int)
        
        articleListDecoder =
            Json.Decode.list 
                ( Json.Decode.Pipeline.decode (,)
                    |> required "left" int
                    |> required "right" jLinkedArticleDecoder
                )
                
        importDecoder = 
            Json.Decode.Pipeline.decode ImportModel
                |> required "chartName" string
                |> required "articles" articleListDecoder
    in
        str
            |> Json.Decode.decodeString importDecoder
            |> importChartModel

importChartModel : Result err ImportModel -> Model
importChartModel file =
    let
        ( { articles, chartName }, new ) =
            case file of
                Ok obj ->
                    ( obj, False )

                Err _ ->
                    ( { chartName = ""
                      , articles = []
                      } , True )

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
                EditTabModel.Add Nothing
            else
                EditTabModel.Dragging Nothing
    in
        Model articleDict command nextId chartName