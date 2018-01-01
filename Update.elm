module Update exposing (..)

--Libs

import Dict exposing (Dict)
import Set exposing (Set)


--Project specific

import Point exposing (Point)
import Linked exposing (Linked)
import Drag exposing (Drag)
import Article exposing (Article, ArticleField(..))
import ArticleId exposing (ArticleId)
import Model exposing (..)
import Msg exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( updateModel msg model
    , Cmd.none
    )


updateModel : Msg -> Model -> Model
updateModel msg model =
    case msg of
        SwitchTo tgt ->
            updateSwitchCommand tgt model

        DrawspaceClick pt ->
            case model.command of
                Add Nothing ->
                    updateAddArticle pt model

                --WTF How?!
                Add _ ->
                    model

                --Some other tool misclick. Ignore.
                _ ->
                    model

        Select id pt ->
            updateSelect id pt model

        ChangeContent field ->
            case model.command of
                Add (Just id) ->
                    { model
                        | articles =
                            model.articles
                                |> Dict.update id
                                    (Maybe.map
                                        (\old ->
                                            case field of
                                                Headline content ->
                                                    { old | headline = content }

                                                Author content ->
                                                    { old | author = content }

                                                Link content ->
                                                    { old | link = content }
                                        )
                                    )
                    }

                _ ->
                    model

        DragTo pt ->
            { model
                | command =
                    case model.command of
                        Dragging (Just d) ->
                            Dragging (Just { d | current = pt })

                        _ ->
                            model.command
            }


{-| Change the active command
-}
updateSwitchCommand : CommandSwitch -> Model -> Model
updateSwitchCommand tgt model =
    case tgt of
        ToDrag ->
            updateDragEnd model

        ToAdd ->
            { model | command = Add Nothing }

        ToDelete ->
            { model | command = Delete }

        ToLinking ->
            { model | command = Linking (Nothing) }

        ToUnlinking ->
            { model | command = Unlinking (Nothing) }


{-| Pass an article selection to its respective handling command,
depending on the currently active command.
-}
updateSelect : ArticleId -> Point -> Model -> Model
updateSelect id pt model =
    case model.command of
        Dragging Nothing ->
            { model | command = Dragging (Just (Drag id pt pt)) }

        Add Nothing ->
            { model | command = Add (Just id) }

        Delete ->
            { model | articles = Dict.remove id model.articles }

        Linking Nothing ->
            { model | command = Linking (Just id) }

        Linking (Just id1) ->
            updateLinkArticle id1 id model

        Unlinking Nothing ->
            { model | command = Unlinking (Just id) }

        Unlinking (Just id1) ->
            updateUnlinkArticle id1 id model

        --WTF How?!
        Add _ ->
            model

        Dragging _ ->
            model


updateDragEnd : Model -> Model
updateDragEnd model =
    case model.command of
        Dragging (Just drag) ->
            { model
                | articles =
                    model.articles
                        |> Dict.update drag.id (Maybe.map (\a -> { a | pos = Drag.getRealPosition drag a }))
                , command = Dragging Nothing
            }

        _ ->
            { model | command = Dragging Nothing }


updateAddArticle : Point -> Model -> Model
updateAddArticle pt ({ articles, command, nextId } as model) =
    { model
        | articles =
            Dict.insert
                model.nextId
                { pos = pt, headline = "", author = "", link = "", links = Set.empty }
                model.articles
        , command = Add (Just model.nextId)
        , nextId = model.nextId + 1
    }


updateLinkArticle id1 id2 model =
    { model
        | articles =
            if id1 == id2 then
                model.articles
            else
                model.articles |> Dict.update id1 (Maybe.map (\a1 -> Linked.insertLink id2 a1))
        , command = Linking Nothing
    }


updateUnlinkArticle id1 id2 model =
    { model
        | articles =
            case ( Dict.get id1 model.articles, Dict.get id2 model.articles ) of
                ( Just a1, Just a2 ) ->
                    if id1 == id2 then
                        model.articles
                            |> Dict.map
                                (\idn an ->
                                    if idn == id1 then
                                        { an | links = Set.empty }
                                    else
                                        Linked.removeLink id1 an
                                )
                    else
                        model.articles
                            |> Dict.insert id1 (Linked.removeLink id2 a1)
                            |> Dict.insert id2 (Linked.removeLink id1 a2)

                _ ->
                    model.articles
        , command = Unlinking Nothing
    }
