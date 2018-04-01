module Export exposing (viewExportBox, jsonValue, jsonString)

--Libs

import Dict
import Set
import Json.Encode exposing (Value)
import Html exposing (Html)
import Html.Attributes
import Html.Events


--Project specific

import Linked exposing (Linked)
import EditTabModel exposing (..)


(=>) : a -> b -> (a,b)
(=>) = (,)

jsonValue : Model -> Json.Encode.Value
jsonValue model =
    Json.Encode.object
        [   ( "articles"
            , model.articles
                |> Dict.toList
                |> List.map (encode2Tuple Json.Encode.int encodeArticle)
                |> Json.Encode.list
            )
        , ( "name", Json.Encode.string model.chartName)
        ]

jsonString : Model -> String
jsonString model =
    model
        |> jsonValue
        |> Json.Encode.encode 0


viewExportBox : Model -> ExportModel -> Html Msg
viewExportBox model m =
    let
        modelString =
            jsonString model

        dataString =
            "data:application/json;charset=utf-8," ++ modelString
    in
        Html.ul [] 
            [ Html.li [] 
                [ Html.text "Copy to clipboard: "
                , Html.input 
                    [ Html.Attributes.type_ "text"
                    , Html.Attributes.id "copyFromBox"
                    , Html.Attributes.readonly True
                    , Html.Attributes.value modelString
                    , Html.Attributes.attribute "onclick" 
                        """
(function(){
    var box = document.getElementById('copyFromBox');
    if(box){
        box.focus();
        box.select();
        document.execCommand('copy');
        box.value="Copied!";
        box.onclick=null;
        //let successMsg = document.createElement('p');
        //successMsg.style.background = 'lightGray';
        //successMsg.innerHtml = "Copied!";
        //box.appendChild(successMsg);
    }else{
        console.error('onclick select and copy handler called without a copyFromBox in the webpage. How?!');
        document.body.appendChild(document.createElement('p')).innerHtml = 'Somehow, clicking that button made everything break. Try the download link instead, mkay?';
    }
})()
                        """
                    , Html.Attributes.style 
                        [ "background-color" => "lightBlue"
                        , "border" => "0.5em outset lightCyan"
                        , "border-radius" => "1em"
                        , "font-size" => "1em"
                        , "user-select" => "text"
                        ]
                    ] []
                ]
            , Html.li [] 
                [ Html.a 
                    [ Html.Attributes.href dataString
                    , Html.Attributes.download True
                    , Html.Attributes.downloadAs (model.chartName++".json")
                    , Html.Attributes.attribute "onload" 
                        """
(function(){
    console.log('loaded!');
})()
                        """
                    ]
                    [ Html.text "Or download as a file!" ]
                ]
            , Html.li [] 
                [ Html.button
                    [ Html.Attributes.style
                        [ "width" => "8em"
                        , "height" => "5em"
                        , "background-color" => "lightBlue"
                        , "border" => "0.5em outset lightCyan"
                        , "border-radius" => "1em"
                        , "font-size" => "100%"
                        ]
                    , Html.Events.onClick <| Select 0 {x=0,y=0}
                    ]
                    [ Html.text "<= Return" ]
                ]
            ]


encode2Tuple : (a -> Value) -> (b -> Value) -> ( a, b ) -> Value
encode2Tuple enc1 enc2 ( val1, val2 ) =
    Json.Encode.object
        [ ("left",enc1 val1)
        , ("right",enc2 val2)
        ]


encodeArticle : Linked Article -> Value
encodeArticle a =
    Json.Encode.object
        [ ( "pos"
          , Json.Encode.object
              [ ("x", Json.Encode.int a.pos.x)
              , ("y", Json.Encode.int a.pos.y)
              ]
          )
        , ( "headline", Json.Encode.string a.headline )
        , ( "author", Json.Encode.string a.author )
        , ( "link", Json.Encode.string a.link )
        , ( "links"
          , a.links
                |> Set.toList
                |> List.map Json.Encode.int
                |> Json.Encode.list
          )
        ]
