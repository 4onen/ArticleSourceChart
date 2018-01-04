port module Interop exposing (..)

import Html exposing (Html)


port copy : String -> Cmd msg


port copyResult : (Bool -> msg) -> Sub msg


copyScript : Html msg
copyScript =
    Html.node "script"
        []
        ((Html.text
            """
window.MyApp.ports.copy.subscribe(function(){
    const copyField = document.getElementById('copyField');
    if(copyField){
        copyField.select();
        document.execCommand('copy');
        window.MyApp.ports.copyResult.send(true);
        return;
    }
    window.MyApp.ports.copyResult.send(false);
    return;
});
            """
         )
            :: []
        )
