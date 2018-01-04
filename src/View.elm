module View exposing (view)

--Libs

import Dict exposing (Dict)
import Set exposing (Set)
import Html exposing (Html)
import Html.Events
import Html.Attributes as HAttr
import Svg exposing (Svg)
import Svg.Attributes as SAttr


--Project-specific

import Point exposing (Point)
import SpecialEvents exposing (onClickPoint, onClickNoPassthrough)
import Drag
import Interop
import Export
import Linked exposing (Linked)
import Article exposing (Article, ArticleField(..))
import ArticleId exposing (ArticleId)
import Model exposing (..)
import Msg exposing (Msg(..), Command(..), CommandSwitch(..))


view : Model -> Html Msg
view model =
    case model.command of
        Add (Just id) ->
            case Dict.get id model.articles of
                Just a1 ->
                    viewArticle a1

                _ ->
                    viewArticleTree model

        Exporting m ->
            Export.viewExportBox model m

        _ ->
            viewArticleTree model


viewArticleTree : Model -> Html Msg
viewArticleTree model =
    Html.div
        ([ HAttr.style
            [ ( "height", "100%" )
            , ( "width", "100%" )
            ]
         ]
            ++ noSelect
        )
        [ viewToolbar model
        , viewDrawSpace model
        ]


viewArticle : Linked Article -> Html Msg
viewArticle a =
    Html.div
        [ HAttr.style
            [ "position" => "fixed"
            , ( "height", "100%" )
            , ( "width", "100%" )
            , ( "background-color", "aliceblue" )
            ]
        ]
        [ Html.form
            [ HAttr.style
                [ ( "height", "40em" )
                , ( "width", "35em" )
                , ( "margin", "auto" )
                , ( "margin-top", "1em" )
                , ( "background-color", "white" )
                , ( "border", "1px solid black" )
                , ( "border-radius", "1em" )
                ]
            , Html.Events.onSubmit (SwitchTo ToAdd)
            ]
            [ Html.h3 
                ((HAttr.style ["padding-top"=>"1em"])::displayBlock)
                [ Html.text "Headline:" ]
            , Html.input
                (displayBlock
                    ++ [ HAttr.type_ "text"
                       , HAttr.placeholder "Astronaut eats ice cream and doesn't suffocate!"
                       , HAttr.value a.headline
                       , HAttr.style [ ( "height", "3em" ), ( "width", "95%" ), ( "margin", "auto auto" ), ( "font-size", "120%" ) ]
                       , HAttr.autofocus True
                       , Html.Events.onInput (\s -> ChangeContent (Headline s))
                       ]
                )
                []
            , Html.h3 displayBlock [ Html.text "Author:" ]
            , Html.input
                (displayBlock
                    ++ [ HAttr.type_ "text"
                       , HAttr.placeholder "Jane Doe"
                       , HAttr.value a.author
                       , HAttr.style [ ( "height", "3em" ), ( "width", "95%" ), ( "margin", "auto auto" ), ( "font-size", "120%" ) ]
                       , Html.Events.onInput (\s -> ChangeContent (Author s))
                       ]
                )
                []
            , Html.h3 displayBlock [ Html.text "URL:" ]
            , Html.input
                (displayBlock
                    ++ [ HAttr.type_ "url"
                       , HAttr.placeholder "http://arstechnica.com/not-a-real-story/"
                       , HAttr.value a.link
                       , HAttr.style [ ( "height", "3em" ), ( "width", "95%" ), ( "margin", "auto auto" ), ( "font-size", "120%" ) ]
                       , Html.Events.onInput (\s -> ChangeContent (Link s))
                       ]
                )
                []
            , Html.button
                (displayBlock
                    ++ [ HAttr.style
                            [ ( "height", "3em" )
                            , ( "width", "8em" )
                            , ( "bottom", "2em" )
                            , ( "margin", "2em auto" )
                            , ( "font-size", "120%" )
                            ]
                       ]
                )
                [ Html.text "Confirm" ]
            ]
        ]



--Toolbar


viewToolbar model =
    let
        toolbarStyle =
            [ HAttr.style
                [ "position" => "absolute"
                , "width" => "100%"
                , "height" => "3em"
                , "top" => "0"
                , "left" => "0"
                , "font-size" => "150%"
                , "background-color" => "white"
                , "border-bottom" => "1px solid black"
                ]
            ]

        nameWidth =
            model.name
                |> String.length
                |> max 16
                |> toFloat
                |> (flip (/) 2)
                |> ((+) 0.5)
                |> round
                |> toString
                |> (flip (++) "em")

        ( msgList, labelList ) =
            List.unzip
                [ ( ToDrag, "Drag" )
                , ( ToAdd, "Add/Edit" )
                , ( ToDelete, "Delete" )
                , ( ToLinking, "Link" )
                , ( ToUnlinking, "Unlink" )
                ]

        highlightIndex =
            case model.command of
                Dragging _ ->
                    0

                Add _ ->
                    1

                Delete ->
                    2

                Linking _ ->
                    3

                Unlinking _ ->
                    4

                Exporting _ ->
                    5

        highlightBoolList =
            List.map (\n -> n == highlightIndex) (List.range 0 4)

        buttonList =
            List.map3 viewToolbarButton msgList labelList highlightBoolList
                |> List.reverse
                |> (::) (viewToolbarButton ToExporting "Export" (5 == highlightIndex))
                |> List.reverse
    in
        Html.div
            (toolbarStyle)
            (Html.input
                [ HAttr.type_ "text"
                , HAttr.style
                    [ "display" => "block"
                    , "width" => nameWidth
                    , "height" => "1em"
                    , "max-width" => "99%"
                    , "font-size" => "1em"
                    ]
                , HAttr.value model.name
                , HAttr.placeholder "<Untitled Chart>"
                , Html.Events.onInput NameChange
                ]
                []
                :: buttonList
            )


viewToolbarButton : CommandSwitch -> String -> Bool -> Html Msg
viewToolbarButton cmdMsg cmdLabel highlight =
    Html.button
        [ SpecialEvents.onClickNoPassthrough (SwitchTo cmdMsg)
        , HAttr.style
            [ "margin" => "0.2em"
            , "font-size" => "1em"
            , "background-color"
                => if highlight then
                    "wheat"
                   else
                    "white"
            ]
        ]
        [ Html.text cmdLabel ]



--Drawing space


viewDrawSpace : Model -> Html Msg
viewDrawSpace model =
    let
        svgCursor =
            case model.command of
                Add _ ->
                    "cell"
                Exporting _ ->
                    "alias"

                _ ->
                    "auto"
    in
        Html.div
            ([ HAttr.style
                [ ( "height", "99.9%" )
                , ( "width", "100%" )
                ]
             ]
            )
            ([ Svg.svg
                ((viewDrawSpaceClick model.command)
                    ++ [ HAttr.style
                            [ ( "height", "100%" )
                            , ( "width", "100%" )
                            , ( "cursor", svgCursor )
                            ]
                       ]
                )
                ([ Svg.marker
                    [ SAttr.id "arrow"
                    , SAttr.markerWidth "10"
                    , SAttr.markerHeight "10"
                    , SAttr.refY "3"
                    , SAttr.orient "auto"
                    , SAttr.markerUnits "strokeWidth"
                    ]
                    [ Svg.path [ SAttr.d "M0,0 L0,6 L9,3 z", SAttr.fill "contextFill" ] []
                    ]
                 ]
                    ++ (viewArticleConnections model)
                )
             ]
                ++ viewArticleBoxForms model
            )


viewDrawSpaceClick : Command -> List (Html.Attribute Msg)
viewDrawSpaceClick cmd =
    [ SpecialEvents.onClickPoint DrawspaceClick ]



--Html Article boxes


viewArticleBoxForms : Model -> List (Html Msg)
viewArticleBoxForms model =
    model.articles
        |> Dict.map (viewArticleBox model)
        |> Dict.values


viewArticleBox : Model -> ArticleId -> Linked Article -> Html Msg
viewArticleBox model id article =
    let
        cursor =
            case model.command of
                Dragging _ ->
                    "move"

                Add _ ->
                    "cell"

                Delete ->
                    "alias"

                Linking _ ->
                    "zoom-in"

                Unlinking _ ->
                    "zoom-out"

                Exporting _ ->
                    "alias"

        selectedId =
            case model.command of
                Dragging (Just d) ->
                    d.id

                Add (Just id) ->
                    id

                Linking (Just id) ->
                    id

                Unlinking (Just id) ->
                    id

                _ ->
                    -1

        { x, y } =
            case model.command of
                Dragging (Just drag) ->
                    if id == drag.id then
                        Drag.getRealPosition drag article
                    else
                        article.pos

                _ ->
                    article.pos
    in
        Html.div
            [ HAttr.style
                [ ( "cursor", cursor )
                , ( "position", "absolute" )
                , ( "top", "calc(" ++ (toString y) ++ "px - 4em)" )
                , ( "left", "calc(" ++ (toString x) ++ "px - 4em)" )
                , ( "height", "8em" )
                , ( "width", "8em" )
                , ( "overflow", "hidden" )
                , ( "background-color"
                  , if id == selectedId then
                        "wheat"
                    else
                        "white"
                  )
                , ( "border", "1px solid black" )
                , ( "border-radius", "0.2em" )
                ]
            , SpecialEvents.onMouseDownPoint (Select id)
            ]
            [ Html.code
                (noMargin ++ halfFontSize)
                [ Html.text <| toString id ]
            , Html.h4 (noMargin ++ [ HAttr.style [ ( "white-space", "nowrap" ) ] ]) [ Html.text article.headline ]
            , Html.p noMargin [ Html.text article.author ]
            , Html.a
                ([ HAttr.href article.link ] ++ noMargin)
                [ Html.text article.link ]
            ]



--SVG Article connections


viewArticleConnections : Model -> List (Svg Msg)
viewArticleConnections model =
    model.articles
        |> Dict.toList
        |> List.concatMap (viewArticleConnection model)


viewArticleConnection : Model -> ( ArticleId, Linked Article ) -> List (Svg Msg)
viewArticleConnection model ( linkedId, linkedArticle ) =
    let
        mdrag =
            case model.command of
                Dragging mdrag ->
                    mdrag

                _ ->
                    Nothing

        selectedId =
            case mdrag of
                Just d ->
                    d.id

                Nothing ->
                    -1

        getPos id =
            if id == selectedId then
                Maybe.map2 Drag.getRealPosition mdrag (Dict.get id model.articles)
            else
                Maybe.map .pos (Dict.get id model.articles)

        linkedPos =
            if linkedId == selectedId then
                mdrag
                    |> Maybe.map (flip Drag.getRealPosition linkedArticle)
                    |> Maybe.withDefault linkedArticle.pos
            else
                linkedArticle.pos
    in
        linkedArticle.links
            |> Set.toList
            |> List.filterMap getPos
            |> List.map (drawLine linkedPos)


drawLine : Point -> Point -> Svg Msg
drawLine p1 p2 =
    Svg.polyline
        ([ SAttr.points
            ((Point.toString p1)
                ++ " "
                ++ (Point.toString <| Point.midpoint p1 p2)
                ++ " "
                ++ (Point.toString p2)
            )
         , SAttr.stroke "black"
         , SAttr.strokeWidth "5"
         , SAttr.markerMid "url(#arrow)"
         ]
        )
        []



--Helper styles


(=>) =
    (,)


noMargin =
    [ HAttr.style
        [ ( "margin", "0" )
        , ( "-webkit-margin", "0" )
        , ( "-webkit-margin-before", "0" )
        , ( "-webkit-margin-after", "0" )
        , ( "padding", "0" )
        , ( "-webkit-padding", "0" )
        , ( "line-height", "1" )
        ]
    ]


noSelect =
    [ HAttr.style
        [ ( "user-select", "none" )
        , ( "-ms-user-select", "none" )
        , ( "-moz-user-select", "none" )
        , ( "-webkit-user-select", "none" )
        ]
    ]


displayBlock =
    [ HAttr.style [ ( "display", "block" ) ] ]


halfFontSize =
    [ HAttr.style [ ( "font-size", "50%" ) ] ]
