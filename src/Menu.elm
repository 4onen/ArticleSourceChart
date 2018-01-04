port module Menu exposing (..)

import Json.Encode
import Json.Decode
import Html exposing (Html)
import Html.Attributes
import Html.Events


--Port for sending strings out to Javascript


port launch : String -> Cmd msg



--Port for getting browser statuses from Javascript


port fileAPI : (Bool -> msg) -> Sub msg


main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type API
    = File Bool


type Button
    = ButtonNew
    | ButtonCopyPaste
    | ButtonFile
    | ButtonGDrive
    | ButtonMainMenu


type Msg
    = Noop
    | APISupport API
    | ButtonDown Button
    | ButtonUp
    | ButtonClick Button
    | UpdateContent String


type State
    = Menu
    | SubMenu SubMenus


type SubMenus
    = CopyPaste String


type alias Model =
    { fileAPISupport : Maybe Bool
    , pressedButtons : List Button
    , state : State
    }


init : ( Model, Cmd Msg )
init =
    ( Model Nothing [] Menu, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        APISupport api ->
            case api of
                File b ->
                    ( { model | fileAPISupport = Just b }
                    , Cmd.none
                    )

        Noop ->
            ( model, Cmd.none )

        ButtonDown button ->
            ( { model | pressedButtons = button :: model.pressedButtons }, Cmd.none )

        ButtonUp ->
            ( { model | pressedButtons = [] }, Cmd.none )

        ButtonClick button ->
            case button of
                ButtonNew ->
                    ( model, launch "" )

                ButtonCopyPaste ->
                    case model.state of
                        Menu ->
                            ( { model | state = SubMenu (CopyPaste "") }, Cmd.none )

                        SubMenu (CopyPaste str) ->
                            ( model, launch str )

                ButtonFile ->
                    ( { model | fileAPISupport = Just False }, Cmd.none )

                ButtonMainMenu ->
                    ( { model | state = Menu }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UpdateContent content ->
            case model.state of
                SubMenu (CopyPaste str) ->
                    ( { model | state = SubMenu (CopyPaste content) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


subscriptions model =
    case model.fileAPISupport of
        Nothing ->
            fileAPI (\b -> APISupport (File b))

        _ ->
            Sub.none


preventDefault =
    let
        defaults =
            Html.Events.defaultOptions
    in
        { defaults | preventDefault = True }


(=>) =
    (,)


view : Model -> Html Msg
view model =
    Html.div
        [ Html.Events.onMouseUp (ButtonUp) ]
        [ Html.div
            (Html.Attributes.id "ScriptDiv" :: [])
            [ Html.node "script"
                [ Html.Attributes.type_ "text/javascript" ]
                [ Html.text """
window.MyApp.ports.fileAPI.send(Boolean(window.File && window.FileReader && window.FileList && window.Blob));
                            """
                ]
            ]
        , case model.state of
            Menu ->
                viewMenu model

            SubMenu (CopyPaste str) ->
                viewCopyMenu str model
        ]


viewMenu : Model -> Html Msg
viewMenu model =
    let
        fileAvailability =
            case model.fileAPISupport of
                Just True ->
                    Just ButtonFile

                _ ->
                    Nothing
    in
        Html.table
            [ Html.Attributes.style
                [ "min-width" => "20em"
                , "margin" => "auto auto"
                , "line-height" => "1em"
                ]
            ]
            [ Html.caption []
                [ Html.h1
                    [ Html.Attributes.style [ "line-height" => "1em" ] ]
                    [ Html.text "Article Sourcing Chart" ]
                ]
            , Html.tr []
                [ Html.td []
                    [ viewButton (Just "imgs/new.svg") (Just ButtonNew) (List.member ButtonNew model.pressedButtons) ]
                , Html.td []
                    [ Html.p [] [ Html.text "New chart" ] ]
                ]
            , Html.tr []
                [ Html.td []
                    [ viewButton (Just "imgs/copy.svg") (Just ButtonCopyPaste) (List.member ButtonCopyPaste model.pressedButtons) ]
                , Html.td []
                    [ Html.p [] [ Html.text "Copy/paste text data" ] ]
                ]
            , Html.tr []
                [ Html.td []
                    [ (viewButton (Just "imgs/upload.svg") (Nothing) (List.member ButtonFile model.pressedButtons)) ]
                , Html.td []
                    [ Html.p [] [ Html.text "Upload file" ]
                    , case model.fileAPISupport of
                        Nothing ->
                            Html.p []
                                [ Html.text "Checking for FileReader API..." ]

                        Just False ->
                            Html.p
                                [ Html.Attributes.style
                                    [ "color" => "red" ]
                                ]
                                [ Html.text "Sorry! This webapp doesn't have this yet." ]

                        _ ->
                            Html.text ""
                    , Html.p
                        [ Html.Attributes.style [ "color" => "red" ] ]
                        [ Html.text "Implementation incomplete. Disabled." ]
                    ]
                ]
            , Html.tr []
                [ Html.td []
                    [ (viewButton (Just "imgs/gdrive.svg") Nothing False) ]
                , Html.td []
                    [ Html.p []
                        [ Html.text "Google Drive"
                        , Html.p
                            [ Html.Attributes.style
                                [ "color" => "red" ]
                            ]
                            [ Html.text "No implementation at all." ]
                        ]
                    ]
                ]
            ]


viewButton : Maybe String -> Maybe Button -> Bool -> Html Msg
viewButton imgurl available pressed =
    Html.div
        (Html.Attributes.style
            [ "display" => "inline-block"
            , "height" => "5em"
            , "width" => "8em"
            , "background-color"
                => (if isJust available then
                        "lightBlue"
                    else
                        "lightGray"
                   )
            , "border-radius" => "1em"
            , "border"
                => ("0.5em "
                        ++ case ( available, pressed ) of
                            ( Just _, True ) ->
                                "inset lightBlue"

                            ( Just _, False ) ->
                                "outset lightCyan"

                            ( Nothing, _ ) ->
                                "ridge lightGray"
                   )
            , "background-image"
                => (case imgurl of
                        Just str ->
                            "url(" ++ str ++ ")"

                        Nothing ->
                            ""
                   )
            , "background-repeat" => "no-repeat"
            , "background-position" => "center center"
            , "background-blend-mode" => "soft-light"
            ]
            :: case available of
                Just msg ->
                    Html.Events.onMouseDown (ButtonDown msg)
                        :: Html.Events.onClick (ButtonClick msg)
                        :: []

                Nothing ->
                    []
        )
        []


viewCopyMenu : String -> Model -> Html Msg
viewCopyMenu content model =
    Html.table
        [ Html.Attributes.style
            [ "margin" => "auto"
            ]
        ]
        [ Html.caption []
            [ Html.h1 [] [ Html.text "Copy/Paste chart" ]
            , Html.p [] [ Html.text "Paste all the text from your previously exported chart in here, then click the right button." ]
            , Html.p [] [ Html.text "Left button to go back to the menu." ]
            ]
        , viewButton (Just "imgs/back.svg") (Just ButtonMainMenu) (List.member ButtonMainMenu model.pressedButtons)
        , Html.textarea
            [ Html.Events.onInput UpdateContent
            , Html.Attributes.value content
            , Html.Attributes.style
                [ "width" => "8em"
                , "height" => "5em"
                , "font-size" => "1em"
                ]
            ]
            []
        , viewButton (Just "imgs/copy.svg") (Just ButtonCopyPaste) (List.member ButtonCopyPaste model.pressedButtons)
        ]


isJust mby =
    case mby of
        Just _ ->
            True

        _ ->
            False
