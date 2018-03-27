module Main exposing (main)

import Html exposing (Html)
import Html.Events
import Html.Attributes
import Json.Decode
import Debug

import Array.NonEmpty exposing (NonEmptyArray)

import GDrive

main : Program Never Model Msg
main = Html.program
    { init = init 
    , update = update 
    , view = view
    , subscriptions = subscriptions
    }

type Msg 
    = GapiMsg GDrive.Msg
    | SwitchTab Int
    | CloseTab Int
    | TEMPAddPage

type alias Model =
    { gapiLoaded : GDrive.GapiStatus 
    , pages : NonEmptyArray Page
    }

--TODO: Fix dummy type
type EditModel = EditModel

type Page
    = LoadTab 
    | EditTab EditModel

init : (Model, Cmd Msg)
init = 
    ( Model (GDrive.init) (Array.NonEmpty.fromElement (LoadTab))
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
            ({model | pages = Array.NonEmpty.setSelectedIndex index model.pages}, Cmd.none)
        CloseTab index ->
            if index>0 then
                ({model | pages = Array.NonEmpty.removeAtSafe index model.pages}, Cmd.none)
            else
                (model, Cmd.none)
        TEMPAddPage ->
            ({model | pages = Array.NonEmpty.push (EditTab EditModel) model.pages}, Cmd.none)


view : Model -> Html Msg
view model = 
    Html.div [Html.Attributes.style [("width","100%")]] 
        [ Html.div [] [viewTabRow model, (Html.map GapiMsg (GDrive.view model))]
        , viewTab model
        ]
    
viewTabRow : Model -> Html Msg
viewTabRow model =
    Html.table [] [ Html.tr [] 
        ( model.pages
            |> Array.NonEmpty.indexedMapSelected viewTabLabel
            |> Array.NonEmpty.toList
        )]

viewTabLabel : Bool -> Int -> Page -> Html Msg
viewTabLabel selected index page =
    let
        title = 
            case page of
                LoadTab ->
                    "Files"
                EditTab editModel ->
                    "TempEditTabHeader"
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
            case index of
                0 -> []
                _ -> 
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



viewTab : Model -> Html Msg
viewTab model =
    case Array.NonEmpty.selectedIndex model.pages of 
        0 ->
            viewLoadTab model
        _ ->
            viewEditTab model

viewLoadTab : Model -> Html Msg
viewLoadTab model =
    Html.div [] 
        [ Html.text "This is the file loading tab!"
        , Html.button [Html.Events.onClick TEMPAddPage] [Html.text "Add tab"]
        ]

viewEditTab : Model -> Html Msg
viewEditTab model =
    Html.text "This is an edit tab! Woooo! There should be a chart here!"

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map GapiMsg (GDrive.subscriptions model)