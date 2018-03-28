module Model exposing (..)

import GDrive
import EditTabModel exposing (EditTabModel)

type alias Model =
    { gapiLoaded : GDrive.GapiStatus
    , fileAPISupport : Maybe Bool
    , loadTabModel : LoadTabModel
    , tabs : List EditTabModel
    , selectedTab : Int
    }

type Msg 
    = GapiMsg GDrive.Msg
    | SwitchTab Int
    | CloseTab Int
    | LoadTabMsg LoadTabMsg

type LoadTabModel
    = Root
    | CopyPaste String

type LoadTabMsg 
    = ButtonNew
    | ButtonCopyPaste
    | ButtonFileUpload
    | ButtonDrive
    | ButtonToRoot