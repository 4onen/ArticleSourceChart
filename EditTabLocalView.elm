module EditTabLocalView exposing (localView)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Svg exposing (Svg)
import Svg.Attributes
import Dict exposing (Dict)
import Set exposing (Set)

import SpecialEvents exposing (onClickPoint, onClickNoPassthrough)
import EditTabModel exposing (..)
import Point exposing (Point)
import Drag exposing (Drag)
import Linked exposing (Linked)

localView : Model -> Html Msg
localView model =
    case model.command of
        Add (Just id) ->
            case Dict.get id model.articles of
                Just a1 ->
                    viewArticle a1

                _ ->
                    viewArticleTree model

        _ ->
            viewArticleTree model

viewArticleTree : Model -> Html Msg
viewArticleTree model =
    Html.div 
        ((Html.Attributes.style
            [ ("height", "100%")
            , ("width", "100%")
            ]
        )::noSelect)
        [ viewToolbar model
        , viewDrawSpace model
        ]

viewArticle : Linked Article -> Html Msg
viewArticle a =
    Html.form
        [ Html.Attributes.id "ArticleEditDiv"
        , Html.Events.onSubmit (SwitchTo ToAdd) 
        ]
        [ Html.h3 [] [ Html.text "Headline:" ]
        , Html.input
            [ Html.Attributes.type_ "text"
            , Html.Attributes.placeholder 
                "Astronaut eats ice cream and doesn't suffocate!"
            , Html.Attributes.value a.headline
            , Html.Attributes.autofocus True
            , Html.Events.onInput (\s -> ChangeContent (Headline s))
            ] []
        , Html.h3 [] [ Html.text "Author:" ]
        , Html.input
            [ Html.Attributes.type_ "text"
            , Html.Attributes.placeholder "Jane Doe"
            , Html.Attributes.value a.author
            , Html.Events.onInput (\s -> ChangeContent (Author s))
            ] []
        , Html.h3 [] [ Html.text "URL:" ]
        , Html.input 
            [ Html.Attributes.type_ "url"
            , Html.Attributes.placeholder "http://arstechnica.com/not-a-real-story/"
            , Html.Attributes.value a.link
            , Html.Events.onInput (\s -> ChangeContent (Link s))
            ] []
        , Html.button [] [ Html.text "Confirm" ]
        ]

--Toolbar

viewToolbar : Model -> Html Msg
viewToolbar model =
    let
        nameWidth =
            model.chartName
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
                , ( ToExporting, "Save" )
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
            List.map (\n -> n == highlightIndex) (List.range 0 5)

        buttonList =
            List.map3 viewToolbarButton msgList labelList highlightBoolList
    in
        Html.div 
            [ Html.Attributes.id "ToolbarToolDiv" ]
            <| (Html.input
                [ Html.Attributes.type_ "text"
                , Html.Attributes.value model.chartName
                , Html.Attributes.placeholder "<Untitled Chart>"
                , Html.Attributes.style [("width",nameWidth)]
                , Html.Events.onInput NameChange
                ] [])
                :: buttonList
            

viewToolbarButton : CommandSwitch -> String -> Bool -> Html Msg
viewToolbarButton cmdMsg cmdLabel highlight =
    let
        attribute = 
            if not highlight then 
                [ SpecialEvents.onClickNoPassthrough (SwitchTo cmdMsg) ]
            else
                [ Html.Attributes.disabled True ]
    in
        Html.button attribute [ Html.text cmdLabel ]


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
        Html.div []
            (( Svg.svg
                ((viewDrawSpaceClick model.command)
                    ++ [ Html.Attributes.style
                            [ ( "height", "100%" )
                            , ( "width", "100%" )
                            , ( "cursor", svgCursor )
                            ]
                       ]
                )
                ((Svg.marker
                    [ Svg.Attributes.id "arrow"
                    , Svg.Attributes.markerWidth "10"
                    , Svg.Attributes.markerHeight "10"
                    , Svg.Attributes.refY "3"
                    , Svg.Attributes.orient "auto"
                    , Svg.Attributes.markerUnits "strokeWidth"
                    ]
                    [ Svg.path [ Svg.Attributes.d "M0,0 L0,6 L9,3 z", Svg.Attributes.fill "contextFill" ] []
                    ]
                 ) :: (viewArticleConnections model)
                )
             ) :: (viewArticleBoxForms model)
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
            [ Html.Attributes.class "ArticleDrawBox"
            , Html.Attributes.style
                [ ( "cursor", cursor )
                , ( "top", "calc(" ++ (toString y) ++ "px - 4em)" )
                , ( "left", "calc(" ++ (toString x) ++ "px - 4em)" )
                , ( "background-color"
                  , if id == selectedId then
                        "wheat"
                    else
                        "white"
                  )
                ]
            , SpecialEvents.onMouseDownPoint (Select id)
            ]
            [ Html.code []
                [ Html.text <| toString id ]
            , Html.h4 
                [ Html.Attributes.style 
                    [ ( "margin", "0" )
                    , ( "white-space", "nowrap" ) 
                    ] 
                ] 
                [ Html.text article.headline ]
            , Html.p
                [ Html.Attributes.style [ ( "margin", "0" ) ] ]
                [ Html.text article.author ]
            , Html.a
                [ Html.Attributes.href article.link
                , Html.Attributes.style [ ( "margin", "0" ) ] ]
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

                _ ->
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
        ([ Svg.Attributes.points
            ((Point.toString p1)
                ++ " "
                ++ (Point.toString <| Point.midpoint p1 p2)
                ++ " "
                ++ (Point.toString p2)
            )
         , Svg.Attributes.stroke "black"
         , Svg.Attributes.strokeWidth "5"
         , Svg.Attributes.markerMid "url(#arrow)"
         ]
        ) []


-- Helper styles


noSelect : List (Html.Attribute msg)
noSelect =
    [ Html.Attributes.style
        [ ( "user-select", "none" )
        , ( "-ms-user-select", "none" )
        , ( "-moz-user-select", "none" )
        , ( "-webkit-user-select", "none" )
        ]
    ]