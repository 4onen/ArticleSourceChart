module Main exposing (main)

import Html exposing (Html)
import Html.Attributes
import Debug
import List.Extra

import GDrive

import LoadTab
import EditTab

import Model exposing (Model, Msg(..))

main : Program Never Model Msg
main = Html.program
    { init = init 
    , update = update 
    , view = view
    , subscriptions = subscriptions
    }

init : (Model, Cmd Msg)
init = 
    ( Model (GDrive.init) [] -1
    , Cmd.none
    )

update : Msg -> Model -> (Model, Cmd Msg)
update message model =
    case (Debug.log "Update message" message) of
        GapiMsg msg ->
            let 
                (newModel, cmd) = GDrive.update msg model
            in
                (newModel, Cmd.map GapiMsg cmd)
        SwitchTab index ->
            ({model | selectedTab = index}, Cmd.none)
        CloseTab index ->
            if model.selectedTab == index then
                ({model | selectedTab = -1, tabs = List.Extra.removeAt index model.tabs}, Cmd.none)
            else
                ({model | tabs = List.Extra.removeAt index model.tabs}, Cmd.none)
        TEMPAddTab ->
            ({model | tabs = List.append model.tabs [()]}, Cmd.none)


view : Model -> Html Msg
view model = 
    Html.div [Html.Attributes.style [("width","100%")]] 
        [ Html.div [] [(Html.map GapiMsg (GDrive.view model)), viewTabRow model]
        , viewTab model
        ]
    
viewTabRow : Model -> Html Msg
viewTabRow model =
    Html.table [] 
        [ Html.tr [] 
            ( model.tabs
                |> List.indexedMap (\n p -> EditTab.viewLabel (n==model.selectedTab) n p)
                |> (::) (LoadTab.viewLabel (-1==model.selectedTab))
            )
        ]

viewTab : Model -> Html Msg
viewTab model =
    case model.selectedTab of 
        -1 ->
            LoadTab.view model
        _ ->
            EditTab.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map GapiMsg (GDrive.subscriptions model)