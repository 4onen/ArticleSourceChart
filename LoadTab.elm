module LoadTab exposing (init,update,view,viewLabel)

import Html exposing (Html)
import Html.Attributes
import Html.Events

import Model exposing (Model, Msg(..))
import LoadTabModel
import EditTab
import GDrive
import Import
import SpecialEvents

init : LoadTabModel.Model
init = LoadTabModel.Root


update : LoadTabModel.Msg -> Model -> (Model, Cmd LoadTabModel.Msg)
update msg model =
    case msg of
        LoadTabModel.ButtonNew ->
            ({ model 
                | tabs = (::) EditTab.init model.tabs
                , selectedTab = 0
            }, Cmd.none) 
        
        LoadTabModel.ButtonCopyPaste ->
            case model.loadTabModel of 
                LoadTabModel.Root ->
                    ({model | loadTabModel = LoadTabModel.CopyPaste ""}, Cmd.none)
                LoadTabModel.CopyPaste str ->
                    ({ model 
                        | tabs = (::) (Import.importChart str) model.tabs
                        , selectedTab = 0
                    }, Cmd.none) 
        LoadTabModel.ButtonToRoot ->
            ({model | loadTabModel = LoadTabModel.Root}, Cmd.none)
        _ -> 
            (model, Cmd.none)



(=>) : a -> b -> (a,b)
(=>) =
    (,)

view : Model -> Html Msg
view model =
    case model.loadTabModel of
        LoadTabModel.Root ->
            Html.table [Html.Attributes.id "LoadTab"] 
                [ rowify (newButton)
                , rowify (copyPasteButton)
                , rowify (fileUploadButton)
                , rowify (gDriveButton model)
                ]
        LoadTabModel.CopyPaste str ->
            viewCopyPaste str

rowify : List (Html Msg) -> Html Msg
rowify row =
        row
            |> List.map (flip (::) [])
            |> List.map (Html.td [])
            |> Html.tr []


newButton : List (Html Msg)
newButton =
    [ Html.button 
        [ Html.Attributes.classList
            [ ("loadButton",True)
            , ("loadNewButton",True)
            ]
        , Html.Events.onClick (LoadTabModel.ButtonNew)
        ] []
    , Html.p [] [Html.text "New"]
    ]
    |> List.map (Html.map Model.LoadTabMsg)


copyPasteButton : List (Html Msg)
copyPasteButton =
    [ Html.button
        [ Html.Attributes.classList
            [ ("loadButton",True)
            , ("loadCopyPasteButton",True)
            ]
        , Html.Events.onClick (LoadTabModel.ButtonCopyPaste)
        ] []
    , Html.p [] [Html.text "Copy/Paste"]
    ]
    |> List.map (Html.map Model.LoadTabMsg)


fileUploadButton : List (Html Msg)
fileUploadButton =
    [ Html.button
        [ Html.Attributes.classList
            [ ("loadButton",True)
            , ("loadFileUploadButton",True)
            ]
        , Html.Attributes.disabled True
        ] []
    , Html.p [] [Html.text "Web Platform file upload"]
    ]


gDriveButton : Model -> List (Html Msg)
gDriveButton model =
    let 
        extraAttribute = model
            |> GDrive.viewButtonAttribute
            |> Html.Attributes.map GapiMsg 
        label =
            GDrive.viewStatusText model
    in
        [ Html.button
            [ Html.Attributes.classList
                [ ("loadButton",True)
                , ("loadGDriveButton",True)
                ]
            , extraAttribute
            ] []
        , Html.p [] [Html.text label]
        ]


viewCopyPaste : String -> Html Msg
viewCopyPaste str =
    Html.form 
        [ Html.Attributes.id "LoadTab"
        , Html.Events.onSubmit LoadTabModel.ButtonCopyPaste 
        ] 
        [ Html.button 
            [ SpecialEvents.onClickNoDefault LoadTabModel.ButtonToRoot
            , Html.Attributes.classList
                [ ("loadButton",True)
                , ("loadBackButton",True)
                ]
            ] []
        , Html.textarea [] []
        , Html.button 
            [ SpecialEvents.onClickNoDefault LoadTabModel.ButtonCopyPaste
            , Html.Attributes.classList
                [ ("loadButton",True)
                , ("loadCopyPasteButton",True)
                ]
            ] []
        ]
        |> Html.map Model.LoadTabMsg


viewLabel : Bool -> Html Msg
viewLabel selected =
    let
        action =
            if selected then
                Html.Attributes.disabled True
            else
                Html.Events.onClick (SwitchTab -1)
    in
        Html.button [action] [Html.text "File Menu"]