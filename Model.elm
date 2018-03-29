module Model exposing (Model,Msg(..))

import GDrive
import EditTabModel
import LoadTabModel

type alias Model =
    { gapiLoaded : GDrive.GapiStatus
    , pickerLoaded : GDrive.GapiStatus
    , fileAPISupport : Maybe Bool
    , loadTabModel : LoadTabModel.Model
    , tabs : List EditTabModel.Model
    , selectedTab : Int
    }

type Msg 
    = GapiMsg GDrive.Msg
    | SwitchTab Int
    | CloseTab Int
    | LoadTabMsg LoadTabModel.Msg
    | EditTabMsg EditTabModel.Msg