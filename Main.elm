module Main exposing (main)

import Html exposing (Html)
import Html.Attributes
import List.Extra

import GDrive

import LoadTab
import LoadTabModel
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
    ( Model 
        GDrive.NOT_LOADED 
        GDrive.NOT_LOADED 
        (Just False) 
        (LoadTab.init) 
        [] 
        -1
    , Cmd.none
    )

update : Msg -> Model -> (Model, Cmd Msg)
update message model =
    case message of
        GapiMsg msg ->
            let 
                (newModel, cmd) = GDrive.update msg model
            in
                (newModel, Cmd.map GapiMsg cmd)
        SwitchTab index ->
            {model | selectedTab = index} |> cmdNoneWrap
        CloseTab index ->
            if model.selectedTab == index then
                {model | selectedTab = -1, tabs = List.Extra.removeAt index model.tabs} |> cmdNoneWrap
            else if model.selectedTab > index then
                (
                    {model 
                        | selectedTab = model.selectedTab - 1
                        , tabs = List.Extra.removeAt index model.tabs
                    }
                , Cmd.none
                )
            else
                {model | tabs = List.Extra.removeAt index model.tabs} |> cmdNoneWrap
        LoadTabMsg LoadTabModel.ButtonNew ->
            { model 
                | tabs = (::) EditTab.init model.tabs
                , selectedTab = 0
            } |> cmdNoneWrap
            
        LoadTabMsg msg ->
            let
                (newModel, cmd) = LoadTab.update msg model
            in
                (newModel, Cmd.map LoadTabMsg cmd)
        EditTabMsg msg ->
            let
                (newModel, cmd) = EditTab.update msg model
            in
                (newModel, Cmd.map EditTabMsg cmd)

cmdNoneWrap : model -> (model, Cmd msg)
cmdNoneWrap m = (m,Cmd.none)

view : Model -> Html Msg
view model = 
    Html.div 
        [ Html.Attributes.style 
            [ ("width","100%")
            , ("height","100%")
            ] 
        ] 
        [ Html.div [] [viewTabRow model]
        , viewTab model
        ]
    
viewTabRow : Model -> Html Msg
viewTabRow model =
    model.tabs
        |> List.indexedMap (\n p -> EditTab.viewLabel (n==model.selectedTab) n p)
        |> (::) (LoadTab.viewLabel (-1==model.selectedTab))
        |> Html.nav [Html.Attributes.id "TabNav"] 

viewTab : Model -> Html Msg
viewTab model =
    case model.selectedTab of 
        -1 ->
            LoadTab.view model
        _ ->
            EditTab.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch 
        [ model
            |> GDrive.subscriptions
            |> Sub.map GapiMsg
        , model
            |> .tabs
            |> List.Extra.getAt model.selectedTab
            |> Maybe.map EditTab.subscriptions
            |> Maybe.withDefault Sub.none
            |> Sub.map EditTabMsg 
        ]