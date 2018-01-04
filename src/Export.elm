module Export exposing (viewExportBox)

--Libs

import Dict
import Set
import Json.Encode exposing (Value)
import Html exposing (Html)
import Html.Attributes
import Html.Events


--Project specific

import Linked exposing (Linked)
import Article exposing (Article)
import Model exposing (Model)
import Msg exposing (..)


(=>) = (,)

viewExportBox : Model -> ExportModel -> Html Msg
viewExportBox model m =
    let
        valueModel =
            Json.Encode.object
                [ ( "articles"
                  , model.articles
                        |> Dict.toList
                        |> List.map (encode2Tuple Json.Encode.int encodeArticle)
                        |> Json.Encode.list
                  )
                , ( "name", Json.Encode.string model.name)
                ]

        modelString =
            Json.Encode.encode 0 valueModel

        dataString =
            "data:text/javascript;charset=utf-8," ++ modelString
    in
        Html.div 
            [ Html.Attributes.style
                [ "position"=>"fixed"
                , "width"=>"100%"
                , "height"=>"100%"
                , "background-color"=>"aliceBlue"
                ]
            ] 
            [ Html.div 
                [ Html.Attributes.style 
                    [ "margin" => "1em"
                    , "padding" => "1em"
                    , "background-color" => "white"
                    , "border" => "1px solid black"
                    , "border-radius" => "1em"
                    , "font-size" => "180%"
                    ]
                ]
                [ Html.div [] 
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
                            , "font-size" => "1em"
                            , "user-select" => "text"
                            ]
                        ] []
                    ]
                , Html.div []
                    [ Html.a 
                        [ Html.Attributes.href dataString
                        , Html.Attributes.download True
                        , Html.Attributes.downloadAs (model.name++".json")
                        ]
                        [ Html.text "Or download as a file!"
                        , Html.p
                            [ Html.Attributes.style ["color"=>"red"] ]
                            [ Html.text "(You'll have to open the file and copy the contents to re-import it.)" ]
                        ]
                    ]
                ]
            ]


encode2Tuple : (a -> Value) -> (b -> Value) -> ( a, b ) -> Value
encode2Tuple enc1 enc2 ( val1, val2 ) =
    Json.Encode.list
        [ enc1 val1
        , enc2 val2
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
