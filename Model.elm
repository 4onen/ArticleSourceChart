module Model exposing (..)

import GDrive
import EditTabModel exposing (EditTabModel)

type alias Model =
    { gapiLoaded : GDrive.GapiStatus 
    , tabs : List EditTabModel
    , selectedTab : Int
    }


type Msg 
    = GapiMsg GDrive.Msg
    | SwitchTab Int
    | CloseTab Int
    | TEMPAddTab