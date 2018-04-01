module EditTab exposing (..)

import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode
import Mouse
import Dict exposing (Dict)
import List.Extra

import EditTabModel
import EditTabLocalUpdate exposing (localUpdate)
import EditTabLocalView exposing (localView)
import Model exposing (Model, Msg(..))


init : EditTabModel.Model 
init =
    { articles = Dict.empty
    , command = EditTabModel.Dragging Nothing
    , nextId = 0
    , chartName = ""
    }



update : EditTabModel.Msg -> Model -> (Model, Cmd EditTabModel.Msg)
update msg model =
    case msg of 
        otherMsg ->
            let
                newTabList = List.Extra.updateAt model.selectedTab (localUpdate otherMsg) model.tabs
            in
                ({model|tabs=newTabList},Cmd.none)


view : Model -> Html Msg
view model =
    --This shouldn't need any nonlocality.
    case List.Extra.getAt model.selectedTab model.tabs of
        Just tab ->
            tab |> localView
                |> Html.map EditTabMsg
        Nothing ->
            Html.div [] 
                [ Html.p [] [ Html.text "Error! Invalid tab selected!" ]
                , Html.p [] [ Html.text "Honestly, I'm pretty impressed. This tabbing system is far from brittle." ]
                , Html.p [] [ Html.text "If you figure out how to repeat this, please do share with me!" ]
                ]


viewLabel : Bool -> Int -> EditTabModel.Model -> Html Msg
viewLabel selected index tab =
    let
        title = 
            case tab.chartName of
                "" -> "<Untitled Chart>"
                str -> str
        action =
            case selected of
                True ->
                    Html.Attributes.disabled True
                False ->
                    Html.Events.onClick (SwitchTab index)
        defaultButtonOptions = Html.Events.defaultOptions
        stopPropagationOptions =
            {defaultButtonOptions | stopPropagation = True}
        removeButton = 
            [Html.button 
                [ Html.Events.onWithOptions 
                    "click" 
                    stopPropagationOptions 
                    (Json.Decode.succeed (CloseTab index))
                ] 
                [ Html.text "X" ]
            ]
    in
        Html.button [action] ((Html.text (title++" "))::removeButton)

subscriptions : EditTabModel.Model -> Sub EditTabModel.Msg
subscriptions model =
    case model.command of
        EditTabModel.Dragging (Just _) ->
            Sub.batch 
                [ Mouse.moves EditTabModel.DragTo 
                , Mouse.ups <| always <| EditTabModel.SwitchTo EditTabModel.ToDrag 
                ]
        
        _ -> 
            Sub.none